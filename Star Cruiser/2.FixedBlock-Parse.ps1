cls

# Блок названий предметов, брони и оружия со строками фиксированной длины. Указатели раскиданы в разные места рома.
# Не имеет разделителей, состоит из 16-байтных строк, в которых 14 байт под строку, 15 байт всегда 00, последний байт, судя по всему, тип предмета.
# В менюшках видимое количество символов - 10, в левом нижнем углу - 8.
# pointers offsets:
# bottom-left: 00005798
# menu-stats: 0000B540
# menu-weapon: 0000B92E
# dialogs: 00015AD0
# item use: 0000C038
# produce weapon2: 0000C40E
# produce weapon1: 0000C452

$mode = "import" # export, import
$translateRus = $false

$mainPath = "D:\Translations\StarCruiserMD\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Original\Star Cruiser (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Star Cruiser (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\fixed_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\fixed_import.csv"

$importOffset = 524288 # 00080000
$startOffset = 50942 # 0000C6FE
$stringLength = 16
$stringsToExport = 46
$visibleLength = 10
$pointersOffsets = @(22424,46400,47406,49208,50190,50258,88784)

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

if ($mode -eq "export") {
	$pos = $startOffset
	$strings = @()
	0..($stringsToExport-1) | % {
		$num = $_
		$string = @()
		0..15 | % {
			$string += $file[$pos]
			$pos++
		}
		$resString = ResolveString $string
		$strings += "" | Select @{N="numLink";E={("{0:X4}" -f $num)}},
								@{N="strOffset";E={("{0:X8}" -f $pos)}},
								@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
								@{N="romData";E={$string}},
								@{N="resolvedString";E={$resString}},
								engTranslation,rusTranslation
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$stringsArray = @()
	$importArr | % {
		if ($translateRus) { $transString = $_.rusTranslation } else { $transString = $_.engTranslation }
		$initialBytes = ($_.RomData).Split(" ") | % {[byte]$_}
		if ($transString) {
			if ($transString.length -gt $visibleLength) { Write-Warning ("This string is longer than visible length: " + ($transString))}
			# Преобразование в массив байт. Пока кодировка тупо ASCII. Для русского (и универсальности) надо будет потом реализовать преобразование через .tbl
			$stringsArray += [System.Text.Encoding]::ASCII.GetBytes($transString.PadRight(14))
			$stringsArray += $initialBytes[14]; $stringsArray += $initialBytes[15]
		} else {
			$stringsArray += $initialBytes
		}
	}
	# Записать данные в ром
	0..($stringsArray.count-1) | % {
		$file[$_+$importOffset] = $stringsArray[$_]
	}
	# Перемапить пойнтеры
	$pointersOffsets | % {
		$file[$_] = [byte](($importOffset -band 0xff000000) -shr 24)
		$file[$_+1] = [byte](($importOffset -band 0x00ff0000) -shr 16)
		$file[$_+2] = [byte](($importOffset -band 0x0000ff00) -shr 8)
		$file[$_+3] = [byte]($importOffset -band 0x000000ff)
	}
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds