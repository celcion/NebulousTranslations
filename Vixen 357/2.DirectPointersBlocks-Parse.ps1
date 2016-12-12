Write-Host
Write-Host "DirectPointersBlocks-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\Vixen357\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\directpointerblocks_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\directpointerblocks_import.csv"

$importStartOffset = 1052672 # 00101000

# 000102BC - 32
# 00048706 - 36
# 000488E0 - 44

$blocks = @("66236|32","296710|36","297184|44")


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
	foreach ($block in $blocks) {
		$startOffset = [int]($block.Split("|")[0])
		$numStr = [int]($block.Split("|")[1])
		$currentOffset = $startOffset
		1..$numStr | % {
			$string = @()
			$strOffset = ([int]$file[$currentOffset] -shl 24) + ([int]$file[$currentOffset+1] -shl 16) + ([int]$file[$currentOffset+2] -shl 8) + [int]$file[$currentOffset+3]
			$strPos = $strOffset
			while($file[$strPos]){
				$string += $file[$strPos]
				$strPos++
			}
			$resString = ResolveString $string
			$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f $currentOffset)}},
						@{N="strOffset";E={("{0:X8}" -f $strOffset)}},
						@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
						@{N="romData";E={$string}},
						@{N="resolvedString";E={$resString}},
						engTranslation,rusTranslation
			$currentOffset += 4
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
	}
	# Сохранить ром
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds