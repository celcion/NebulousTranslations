Write-Host
Write-Host "CongfigMenu-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\Vixen357\"
$tblFile = $mainPath + "TBLs\kanji.tbl"
$originalRomPath = $mainPath + "ROM_Original\Vixen 357 (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\configmenu_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\configmenu_import.csv"

$importStartOffset = 1049088 # 00100200

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
$tblFile = [System.IO.File]::ReadAllBytes($tblFile)
$tblDic = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $tblDic[$tmp[0]] = $tmp[1].Replace("`r","")}

function ResolveString ($bstring) {
	$string = ""
	$charNum = 0
	while ($charNum -lt $bstring.count) {
		$currByte = $bstring[$charNum]
		$nextByte = $bstring[$charNum+1]
		$char = $tblDic[("{0:X2}" -f ($currByte))]
		if ($char) {
			$string += $char
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
	$currByte = 40000
	$strings = @()
	while ($currByte -lt $file.count-5) {
		$posOffset = ([int]$file[$currByte+2] -shl 24) + ([int]$file[$currByte+3] -shl 16) + ([int]$file[$currByte+4] -shl 8) + [int]$file[$currByte+5]
		if (($file[$currByte] -eq 65 -or $file[$currByte] -eq 67 -or $file[$currByte] -eq 69 -or $file[$currByte] -eq 71) -and $file[$currByte+1] -eq 249 -and $posOffset -le $file.count -and $file[$posOffset] -eq 254) {
			$string = @()
			$posFile = $posOffset
			while($file[$posFile]){
				$string += $file[$posFile]
				$posFile++
				if ($file[$posFile] -eq 0 -and $file[$posFile+1] -eq 254) {
					$string += [byte]0
					$posFile++
				}
			}
			$resString = ResolveString $string
			$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f ($currByte+2))}},
									@{N="strOffset";E={("{0:X8}" -f $posOffset)}},
									@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
									@{N="romData";E={$string}},
									@{N="resolvedString";E={$resString}},
									engTranslation
			$currByte += 6
		} else {
			$currByte++
		}
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
		
		# Change menu width
		# 00010655, settings names - B
		$file[67157] = 16
		# 0001067F, Speed - 9
		# 00010697, Animate - 9
		# 000106AF, Stats - 9
		(67199,67223,67247) | % {$file[$_] = 9}
		# Сохранить ром
		[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds