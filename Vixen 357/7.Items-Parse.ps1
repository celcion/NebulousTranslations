Write-Host
Write-Host "Items-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\Vixen357\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Original\Vixen 357 (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\items_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\items_import.csv"

$itemsOffsets = @(135106,135136,135166,135196,135226,135256,135286,135316,135346,135376,135406,135436,135466,135496)

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
$tblFile = [System.IO.File]::ReadAllBytes($tblFile)
$tblFileNoHK = [System.IO.File]::ReadAllBytes($tblFileNoHK)
$tblDic = @{}
$tblDicNoHK = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $tblDic[$tmp[0]] = $tmp[1].Replace("`r","")}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFileNoHK).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $tblDicNoHK[$tmp[0]] = $tmp[1].Replace("`r","")}

function TakeMarks ($char,$mark) {
	$markAdd = ([int]$mark) - 221
	$charInt = [int]([System.Text.Encoding]::GetEncoding("Unicode").GetString($char).ToCharArray()[0])
	if ($charInt -eq 12358 -or $charInt -eq 12454) {$markAdd = 78}
	if ($charInt -ge 12527 -and $charInt -le 12530) {$markAdd = 8}
	[System.Text.Encoding]::GetEncoding("Unicode").GetBytes([char]($charInt+$markAdd))
}

function ResolveString ($bstring) {
	$string = ""
	$charNum = 0
	$hk = 0
	while ($charNum -lt $bstring.count) {
		if ($bstring[$charNum] -eq 2) {$hk = 1; $charNum++}
		if ($bstring[$charNum] -eq 3) {$hk = 0; $charNum++}
		$currByte = $bstring[$charNum]
		$nextByte = $bstring[$charNum+1]
		if ($hk) {
			$char = $tblDic[("{0:X2}" -f ($currByte))]
		} else {
			$char = $tblDicNoHK[("{0:X2}" -f ($currByte))]
		}
		if ($char) {
			$unBytes = @()
			$unByte = [System.Text.Encoding]::GetEncoding("Unicode").GetBytes($char)
			if ($nextByte -eq 222 -or $nextByte -eq 223) {
				$unBytes += TakeMarks $unByte $nextByte
				$charNum++
			} else {
				$unBytes += $unByte
			}
			$string += [System.Text.Encoding]::GetEncoding("Unicode").GetString($unBytes)
		} else {
			$string += ("["+("{0:X2}" -f $currByte)+"]")
		}
		$charNum++
	}
	$string
}

function StringToBytes ($string) {
	# Преобразование в массив байт. Пока кодировка тупо ASCII. Для русского (и универсальности) надо будет потом реализовать преобразование через .tbl
	$stringBytes = [System.Text.Encoding]::ASCII.GetBytes($string)
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
	#Write-Host $string $resultArr
	$resultArr
}

if ($mode -eq "export") {
	$strings = @()
	foreach ($offset in $itemsOffsets) {
		$posFile = $offset
		$string = @()
		while($file[$posFile]){
			$string += $file[$posFile]
			$posFile++
		}
		$resString = ResolveString $string
		$strings += "" | Select @{N="strOffset";E={("{0:X8}" -f $offset)}},
								@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
								@{N="romData";E={$string}},
								@{N="resolvedString";E={$resString}},
								engTranslation
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$importArr | ? {$_.engTranslation} | % {
		$strOffset = [Convert]::ToInt32($_.strOffset,16)
		$strBytes = StringToBytes $_.engTranslation
		if ($strBytes.Count -le 7) {
			while ($strBytes.Count -le 10) {$strBytes += [byte]0}
			0..($strBytes.count-1) | % {
				$file[$_+$strOffset] = $strBytes[$_]
			}
		} else {
			Write-Warning $_.strOffset "too long!"
		}
		# Сохранить ром
		[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds