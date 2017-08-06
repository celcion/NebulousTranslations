Write-Host
Write-Host "Parse-EXE"
$mode = "import" # export, import

$mainPath = "D:\Translations\Macross\"
$exeFilePath = $mainPath + "HDI_Unpack\SKULL_CD\MAC4.EXE"
$compiledBinsDir = $mainPath + "HDI_FilesImport\"
$exportCsvFile = $mainPath + "SCRIPT_Export\ExeExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\ExeImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

function StringToBytes ($string) {
	$stringBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($string)
	$resultArr = New-Object System.Collections.Generic.List[System.Object]
	$pos = 0
	while ($pos -le $stringBytes.count-1) {
		if ($stringBytes[$pos] -eq 91 -and $stringBytes[$pos+3] -eq 93) {
			$resultArr.Add([byte]([Convert]::ToInt32(([char]$stringBytes[$pos+1] + [char]$stringBytes[$pos+2]),16)))
			$pos += 3
		} else {
			$resultArr.Add($stringBytes[$pos])
		}
		$pos++
	}
	$resultArr
}

if ($mode -eq "export") {
	$exeFile = [System.IO.File]::ReadAllBytes($exeFilePath)
	$exeArr = @()
	$startPoints = @("0x16edb-108","0x17b6f-28","0x17dfc-11","0x180d2-7","0x1817f-5","0x181ea-2","0x18263-17","0x184c9-1")
	foreach ($block in $startPoints) {
		$strOffset = [int]($block.Split("-")[0])
		$lineNum = [int]($block.Split("-")[1])
		$currentOffset = $strOffset
		1..$lineNum | % {
			$exeOffset = $currentOffset
			$stringBytes = @()
			while ($exeFile[$currentOffset]) {
				$stringBytes += $exeFile[$currentOffset]
				$currentOffset++
			}
			#[System.Text.Encoding]::GetEncoding("shift-jis").GetString($stringBytes)
			$exeArr += "" | Select @{N="exeOffset";E={("{0:X8}" -f $exeOffset)}},
								   @{N="exeBytes";E={$stringBytes}},
								   @{N="exeBytesCount";E={$stringBytes.Count}},
								   @{N="textString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($stringBytes)}},
								   engTranslation
			$currentOffset++
		}
	}
	$exeArr | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$exeFile = [System.IO.File]::ReadAllBytes($exeFilePath)
	$importArr | ? {$_.engTranslation} | % {
		$exeLine = $_.engTranslation
		$exeLineOffset = [Convert]::ToInt32($_.exeOffset, 16)
		while ($exeLine.Length -lt $_.exeBytesCount) {$exeLine += " "}
		$exeLineBytes = StringToBytes $exeLine
		if ($exeLineBytes.Count -le $_.exeBytesCount) {
			0..($exeLineBytes.Count -1) | % {$exeFile[$exeLineOffset+$_] = $exeLineBytes[$_]}
		} else {Write-Warning ("Line " + $_.exeOffset + " is too long! Skipping...")}
		#Write-Host (StringToBytes $exeLine) $_.exeBytesCount (StringToBytes $exeLine).Count
	}
	[System.IO.File]::WriteAllBytes(($compiledBinsDir + "MAC4.EXE"),$exeFile)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds