cls

# Пойнтеры с текстом, найденные по другим адресам (с префиксами 41F9 43F9). Строк по ним немного, так что систематизировать отдельным скриптом нет особого смысла.
# Разделитель 0, его надо добавлять при вставке, соответственно.

$mode = "import" # export, import
$translateRus = $false

$mainPath = "D:\Translations\StarCruiserMD\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Original\Star Cruiser (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Star Cruiser (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\otherpointers_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\otherpointers_import.csv"

$importStartOffset = 527616 # 00080D00

$ptrs = @("0000B604",
		  "0000B610",
		  "0000F318",
		  "0000F320",
		  "0000104A",
		  "00017A0C",
		  "00005798",
		  "0000B540",
		  "0000B92E",
		  "0000C038",
		  "0000C40E",
		  "0000C452",
		  "00015AD0",
		  "00000F72",
		  "000095C2",
		  "000057C6")

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
		if ($bstring[$charNum] -eq 30 -and $hk -eq 0) {$hk = 1; $charNum++}
		elseif ($bstring[$charNum] -eq 30 -and $hk -eq 1) {$hk = 0; $charNum++}
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
	$currByte = 0
	$strings = @()
	
	$ptrs | % {
		$ptrOffset = ([Convert]::ToInt32($_,16))
		$strOffset = ([int]$file[$ptrOffset] -shl 24) + ([int]$file[$ptrOffset+1] -shl 16) + ([int]$file[$ptrOffset+2] -shl 8) + [int]$file[$ptrOffset+3]
		$posFile = $strOffset
		$string = @()
		while($file[$posFile]){
			if ($file[$posFile] -eq 14 -or $file[$posFile] -eq 15) {
				$string += $file[$posFile]
				$string += $file[$posFile+1]
				$string += $file[$posFile+2]
				$string += $file[$posFile+3]
				$posFile += 3
			} else {
				$string += $file[$posFile]
			}
			$posFile++
		}
		$resString = ResolveString $string
		$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f $ptrOffset)}},
								@{N="strOffset";E={("{0:X8}" -f $strOffset)}},
								@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
								@{N="romData";E={$string}},
								@{N="resolvedString";E={$resString}},
								engTranslation,rusTranslation
	}
	
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	# Прочитать csv файл
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$currentPos = $importStartOffset
	$importArr | ? {$_.engTranslation} | % {
		$strBytes = StringToBytes $_.engTranslation
		$strBytes += [byte]0
		# Записать новую строку в ром
		0..($strBytes.count-1) | % {
			$file[$_+$currentPos] = $strBytes[$_]
		}
		# Перемапить пойнтеры
		$currPtr = ([Convert]::ToInt32($_.ptrOffset,16))
		$file[$currPtr] = [byte](($currentPos -band 0xff000000) -shr 24)
		$file[$currPtr+1] = [byte](($currentPos -band 0x00ff0000) -shr 16)
		$file[$currPtr+2] = [byte](($currentPos -band 0x0000ff00) -shr 8)
		$file[$currPtr+3] = [byte]($currentPos -band 0x000000ff)
		$currentPos += $strBytes.count
		# Сохранить ром
		[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds