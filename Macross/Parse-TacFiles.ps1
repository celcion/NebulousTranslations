Write-Host
Write-Host "Parse-TACFiles"
$mode = "import" # export, import

$mainPath = "D:\Translations\Macross\"
$binsDir = $mainPath + "HDI_Unpack\SKULL_CD\BIN\"
$compiledBinsDir = $mainPath + "HDI_FilesImport\BIN\"
$exportCsvFile = $mainPath + "SCRIPT_Export\tacExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\tacImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

if ($mode -eq "export") {
	$tacArr = @()
	$tacFiles = ls ($binsDir + "TAC*.BIN")
	foreach ($tacFile in $tacFiles) {
		$tacFileData = [System.IO.File]::ReadAllBytes($tacFile)
		$tacBytes = 0x1e..0x27 | % {$tacFileData[$_]}
		$tacString = [System.Text.Encoding]::GetEncoding("shift-jis").GetString($tacBytes)
		$tacArr += "" | Select @{N="fileName";E={$tacFile.Name}},
						@{N="tacBytes";E={$tacBytes}},
						@{N="textString";E={$tacString}},
						engTranslation
	}
	$tacArr | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	foreach ($tacString in $importArr) {
		$tacFileData = [System.IO.File]::ReadAllBytes(($binsDir + $tacString.fileName))
		if ($tacString.engTranslation) {
			$strBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($tacString.engTranslation)
		} else {
			$strBytes = ($tacString.engTranslation).Split(" ") | % {[byte]$_}
		}
		while ($strBytes.Count -lt 10) {$strBytes += 0x20}
		0..($strBytes.Count -1) | % {$tacFileData[0x1e+$_] = $strBytes[$_]}
		[System.IO.File]::WriteAllBytes(($compiledBinsDir + $tacString.fileName),$tacFileData)
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds