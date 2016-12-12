Write-Host
Write-Host "GameMenu-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\Vixen357\"
$tblFile = $mainPath + "TBLs\kanji.tbl"
$originalRomPath = $mainPath + "ROM_Original\Vixen 357 (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\gamemenu_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\gamemenu_import.csv"

$importStartOffset = 1048832 # 00100100

# 0002EA06 - 20

$blocks = @("190982|20")


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
						engTranslation
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
		
		#ASM hacks
		
		# Change characters offset
		# 0000CF9A
		$file[53148] = 0
		$file[53149] = 1
		
		#Change:
		#	0000D012 - 1 (0x52)
		#	0000D018 - 1 (0x52)
		@(53266,53272) | % {$file[$_] = 82}
		
		#NOPs:
		#	0000CFA2 - 0000CFC6
		#	0000CF88 - 2 # not sure, just note, not replaced for now
		#	0000CF8C - 4
		#	0000D100 - 2
		#	0000D134
		#	0000D13C
		@(53154,53156,53158,53160,53162,53164,53166,53168,53170,53172,53174,53176,53178,53180,53182,53184,53186,53188,53132,53134,53136,53138,53504,53506,53556,53564) | % {$file[$_] = 78; $file[$_+1] = 113;}
		
		
		# Сохранить ром
		[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds