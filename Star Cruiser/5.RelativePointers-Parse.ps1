cls

# Относительные двухбайтные указатели на адрес в роме. Им предшествуют два байта - 48 79 (процессорная инструкция PEA), поэтому просканиваем весь ром на предмет наличия этих двух байт, берем следующие два байта и прибавляем их к текущему смещению, чтобы получить смещение строки, на которую ссылается данный пойнтер.
# Окончанием строки является 0.
# Т.к. пойнтеры не дают возможности перемапить текст на более-менее отдаленное место рома, поэтому их придется заменять на том месте, где они были, соблюдая размерность байт (не больше, чем было изначально).
# К счастью, таких пойнтеров немного.

$mode = "import" # export, import
$translateRus = $false

$mainPath = "D:\Translations\StarCruiserMD\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Original\Star Cruiser (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Star Cruiser (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\relativepointers_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\relativepointers_import.csv"


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
	while ($currByte -lt $file.count) {
		$posOffset = ([int]$file[$currByte+2] -shl 8) + [int]$file[$currByte+3]
		$prefix = (("{0:X2}" -f $file[$currByte]) + ("{0:X2}" -f $file[$currByte+1]))
		if ($prefix -eq "487A" -and $file[$currByte+4] -eq 160) {
			$string = @()
			$posFile = ($currByte + $posOffset +2)
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
			$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f ([int]$currByte+2))}},
									@{N="ptrData";E={("{0:X4}" -f $posOffset)}},
									@{N="strOffset";E={("{0:X8}" -f ($currByte + $posOffset + 2))}},
									@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
									@{N="romData";E={$string}},
									@{N="resolvedString";E={$resString}},
									engTranslation,rusTranslation
			$currByte += 3
		}
		$currByte++
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	# Прочитать csv файл
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$importArr | ? {$_.engTranslation} | % {
		$strBytes = StringToBytes $_.engTranslation
		$initialBytes = ($_.RomData).Split(" ") | % {[byte]$_}
		$strOffset = ([Convert]::ToInt32($_.strOffset,16))
		if ($strBytes.count -le $initialBytes.count) {
			$strBytes += [byte]0
			0..($strBytes.count-1) | % {
				$file[$_+$strOffset] = $strBytes[$_]
			}
		} else {
			Write-Warning ("This string is longer than it was in ROM and won't be inserted: " + ($_.engTranslation))
		}
	}
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds