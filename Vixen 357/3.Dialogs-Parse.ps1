Write-Host
Write-Host "Dialogs-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\Vixen357\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$ramFiles = $mainPath + "RAM_Dumps\"
$nameCodesCsvFile = $mainPath + "name-codes.csv"
$exportCsvFile = $mainPath + "SCRIPT_Export\dialogue_export_all.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\dialogue_import_all.csv"

#$exportStartOffset = 14602 # 0000390A
$exportStartOffset = 23938 # 00005D82 - from GSX file
$importStartOffset = 1069056 # 00105000


$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "import") {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
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
	$resultArr
}

function PrepareString ($string) {
	if (-not $string) {return $string}
	if ($string.Contains("[")) {return $string}
	$lengthLimit = 20
	$linesLimit = 4
	$textArr = $string.Split(" ")
	$resultString = ""
	$tmpString = ""
	$lines = 1
	0..($textArr.Count-1) | % {  
		if (($tmpString.Length + " " +  $textArr[$_].Length) -gt $lengthLimit) {
			$char = "[01]"; if ($lines -ge $linesLimit) {$char = "[08][07]"; $lines = 0}
			$resultString += $tmpString + $char
			$tmpString = " "
			$lines++
		} else {
			$tmpString += " "
		}
		$tmpString += $textArr[$_] 
	} 
	$resultString += $tmpString + "[08]"
	$resultString
}

if ($mode -eq "export") {
	$ramCodesArr = Import-Csv -Encoding Unicode -Delimiter "`t" $nameCodesCsvFile
	$ramCodesDict = @{}
	$ramCodesArr | % {$ramCodesDict[([int]$_.Code)] = $_.Name}
	$strings = @()
	foreach ($ramFile in (ls $ramFiles)) {
		$file = [System.IO.File]::ReadAllBytes($ramFile.FullName)
		$exportCurrentOffset = $exportStartOffset
		while($file[$exportCurrentOffset] + $file[$exportCurrentOffset+1]){
			$ptrOffset = ([int]$file[$exportCurrentOffset] -shl 8) + $file[$exportCurrentOffset+1]
			$strOffset = $exportStartOffset + $ptrOffset
			$strPos = $strOffset
			$string = @()
			$binString = @()
			$prefix = @()
			1..4 | % {
				$prefix += $file[$strPos]
				$strPos++
			}
			$char = $file[$strPos]
			$strPos++
			while($file[$strPos]){
				if ($file[$strPos] -eq 10) {
					$string += [System.Text.Encoding]::ASCII.GetBytes(("["+("{0:X2}" -f $file[$strPos])+"]"))
					$string += [System.Text.Encoding]::ASCII.GetBytes(("["+("{0:X2}" -f $file[$strPos+1])+"]"))
					$binString += $file[$strPos]
					$binString += $file[$strPos+1]
					$strPos++
				} elseif ($file[$strPos] -eq 6) {
					$string += [System.Text.Encoding]::ASCII.GetBytes(("["+("{0:X2}" -f $file[$strPos])+"]"))
					$string += [System.Text.Encoding]::ASCII.GetBytes(("["+("{0:X2}" -f $file[$strPos+1])+"]"))
					$string += [System.Text.Encoding]::ASCII.GetBytes(("#"+$ramCodesDict[([int]$file[$strPos+1])]+"#"))
					$binString += $file[$strPos]
					$binString += $file[$strPos+1]
					$strPos++
				} else {
					$string += $file[$strPos]
					$binString += $file[$strPos]
				}
				$strPos++
			}
			$resString = ResolveString $string
			$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f $exportCurrentOffset)}},
							@{N="strOffset";E={("{0:X8}" -f $strOffset)}},
							insertPtrOffset,
							@{N="stringBytes";E={$binString}},
							@{N="prefix";E={$prefix}},
							@{N="char";E={$char}},
							@{N="scene";E={$ramFile.BaseName}},
							@{N="name";E={$ramCodesDict[([int]$char)]}},
							@{N="resolvedString";E={$resString}},
							engTranslation
			$exportCurrentOffset +=2
		}
		$strings = $strings | Select -First ($strings.Count-1)
	}
	
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	
	$currentPos = $importStartOffset
	$currentScenePtr = 1068992 # 00104FC0
	
	$scenesGrp = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile | group scene
	foreach ($scene in $scenesGrp) {
		$ptrs = @()
		$strings = @()
		$currentPtr = ($scene.Group).Count * 2 + 2
		foreach ($importString in $scene.Group) {
			$ptrs += [byte](($currentPtr -band 0xff00) -shr 8)
			$ptrs += [byte]($currentPtr -band 0xff)
			$prefix = ($importString.prefix).Split(" ") | % {[byte]$_}
			$char = @([byte]$importString.char)
			if ($importString.engTranslation) {
				$strText = PrepareString $importString.engTranslation
				$strBytes = StringToBytes $strText
			} else {
				$strBytes = ($importString.stringBytes).Split(" ") | % {[byte]$_}
			}
			$insertString = $prefix + $char + $strBytes + [byte]0
			$strings += $insertString
			#Write-Host ("{0:X4}" -f $currentPtr) ("{0:X4}" -f $currentPtr) $insertString
			$currentPtr += $insertString.Count
		}
		$ptrs += [byte](($currentPtr -band 0xff00) -shr 8)
		$ptrs += [byte]($currentPtr -band 0xff)
		$insertBlock = $ptrs + $strings + [byte]0
		if ($insertBlock.Count%2) {$insertBlock += [byte]0}
		0..($insertBlock.count-1) | % {
			$file[$_+$currentPos] = $insertBlock[$_]
		}
		$file[$currentScenePtr] = [byte](($currentPos -band 0xff000000) -shr 24)
		$file[$currentScenePtr+1] = [byte](($currentPos -band 0x00ff0000) -shr 16)
		$file[$currentScenePtr+2] = [byte](($currentPos -band 0x0000ff00) -shr 8)
		$file[$currentScenePtr+3] = [byte]($currentPos -band 0x000000ff)
		$currentScenePtr += 4
		$currentPos += $insertBlock.Count
	}
	
	# ASM Hack for dialogues
	
	# move.l d0,-(sp) 	; сохраняем d0 в стэк
	# move.l #0,d0		; обнуляем d0
	# move.b $00FFB789,d0	; пишем в d0 текущий уровень
	# mulu.w #$0004,d0	; получаем смещение указателя от начала карты
	# move.l #$00104fc0,a0 ; пишем в a0 начало карты
	# add.l d0,a0  		; добавляем смещение
	# move.l (a0),d0		; пишем в d0 значение по адресу, хранящемуся в a0
	# move.l d0,a0		; теперь это значение возвращаем в a0
	# move.l (sp)+,d0		; восстанавливаем стэк
	# rts
	
	$mapJumpAsm = @(78,185,0,16,79,144)
	$mapJumpAsmOffset = 43318 # 0000A936
	0..($mapJumpAsm.count-1) | %{
		$file[$_+$mapJumpAsmOffset] = $mapJumpAsm[$_]
	}
	
	$mapSelectAsm = @(47,0,32,60,0,0,0,0,16,57,0,255,183,137,192,252,0,4,32,124,0,16,79,192,209,192,32,16,32,64,32,31,78,117)
	$mapSelectAsmOffset = 1068944 # 00104F90
	0..($mapSelectAsm.count-1) | %{
		$file[$_+$mapSelectAsmOffset] = $mapSelectAsm[$_]
	}
	
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds