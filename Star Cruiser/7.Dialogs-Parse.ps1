cls

# Массив вставок идет сразу за текстовым блоком.
# Начало пойнтерного блока 00052400. Начало ссылок на 00052406, работают по тому же принципу, что и у словаря - каждые 16 идет абсолютное значение смещения относительно начала, после него - количество байт для чтения.
# Первые четыре байта указывают на то, через сколько байт начинается блок вставок. 0FF0 - предположительно, длина пойнтерного блока, минус 272, которые, видимо, создаются двухбайтными пойнтерами. Следующий блок инкрементирует первый байт до 01.
# Ссылка на массив - 00016BEE

$mode = "import" # export, import
$translateRus = $false

$mainPath = "D:\Translations\StarCruiserMD\"
$tblFileDiag = $mainPath + "TBLs\sjis_romtable_dialog_script.tbl"
$originalRomPath = $mainPath + "ROM_Original\Star Cruiser (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Star Cruiser (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\dialog_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\dialog_import.csv"

$blockMapper = 93166 # 00016BEE
$importOffset = 589824 # 00090000

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
$tblDiag = [System.IO.File]::ReadAllBytes($tblFileDiag)
$tblDicDiag = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblDiag).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $tblDicDiag[$tmp[0]] = $tmp[1].Replace("`r","")}

# Глобальные словари
$insDict = @{}
$stringDict = @{}

# Номер строки, с которой начинается в второй блок текста (после FFFF в первом блоке).
$global:secondBlockStrNum = 0

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
	while ($charNum -lt $bstring.count) {
		$currByte = $bstring[$charNum]
		$nextByte = $bstring[$charNum+1]
		$char = $tblDicDiag[("{0:X2}" -f ($currByte))]
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

function GetDictionary ($ptrBlockStart, $ptrBlockEnd, $strings) {
	$currentPtr = $ptrBlockStart
	$previousPtr = 0
	$currentOffset = 0
	$previousOffset = 0
	$dictCount = 0
	$i = 0
	while ($currentPtr -le $ptrBlockEnd) {
		$previousPtr = $currentPtr
		if ($i -gt 15) {$i = 0}
		if ($i -eq 0) {
			$currentOffset = $ptrBlockStart + ([int]$file[$currentPtr] -shl 8) + $file[$currentPtr+1]
			$currentPtr += 2
			$i += 2
		} else {
			$currentOffset = $currentOffset + $file[$currentPtr]
			$currentPtr++
			$i++
		}
		if ($currentOffset -lt $previousOffset) {$currentOffset += (1 -shl 16)}
		if ($previousOffset) {
			$word = @()
			$previousOffsetIter = $previousOffset
			while ($currentOffset -gt $previousOffsetIter) {
				$word += $file[$previousOffsetIter]
				$previousOffsetIter++
			}
			if ($strings) {
				$byteString = @()
				$wordByte = 0
				while ($wordByte -ne $word.count) {
					if ($word[$wordByte] -le 4) {
						$ptrDicLink = ([int]$word[$wordByte] -shl 8) + $word[$wordByte+1]
						$byteString += $insDict[$ptrDicLink]
						$wordByte += 2
					} else {
						$byteString += $word[$wordByte]
						$wordByte++
					}
				}
				$stringDict[$dictCount] = "" | Select @{N="numLink";E={("{0:X4}" -f $dictCount)}},
														@{N="ptrOffset";E={("{0:X8}" -f $previousPtr)}},
														@{N="ptrJumpOffset";E={("{0:X8}" -f $previousOffset)}},
														@{N="byteLength";E={($currentOffset - $previousOffset)}},
														@{N="romBytes";E={-join ($word | % {"{0:X2}" -f $_})}},
														@{N="romData";E={$word}},
														@{N="resolvedBytes";E={-join ($bytestring | % {"{0:X2}" -f $_})}},
														@{N="resolvedData";E={$bytestring}},
														@{N="resolvedString";E={-join ($byteString | % {$tblDicDiag[("{0:X2}" -f $_)]})}},
														@{N="resolvedAndNormalizedString";E={ResolveString $byteString}},
														engTranslation,rusTranslation
			} else {
				$insDict[$dictCount] = $word
			}
			$dictCount++
		}
		$previousOffset = $currentOffset
	}
}

function CalculatePtr ($sArray) {
	$ptrArr = @()
	$textStart = 0; 1..($sArray.count) | % {if($_%15) {$textStart++} else {$textStart+=2}}; $textStart+=4
	$ptrArr += [byte]($textStart -shr 8); $ptrArr += [byte]($textStart -band 0x00ff)
	$pos = $textStart
	1..($sArray.count) | % {
		$pos += $sArray[$_-1].count
		# Строка для переключения блока - номер строки, после которой длина текста уже превышает 65535, догнанный до следующего числа, кратного 15 (адрес первого однобайтного смещения).
		# Возможно, в некоторых случаях нужна проверка двухбайтного числа. Надо проверить.
		if ($pos -gt 65535 -and $secondBlockStrNum -eq 0) {
			$lineNumExt = $_+1
			#$global:secondBlockStrNum = $lineNumExt + (15 - ($lineNumExt%15))
			$global:secondBlockStrNum = $lineNumExt - 1 # Needs to be redone!!!
		}
		if ($_%15){
			$ptrArr += [byte]($sArray[$_-1].count)
		} else {
			$ptrArr += [byte](($pos -band 0xffff) -shr 8); $ptrArr += [byte]($pos -band 0x00ff)
		}
	}
	$ptrArr
}

if ($mode -eq "export") {
	# Получить начало блока из $blockMapper
	$blockStart = ([int]$file[$blockMapper] -shl 24) + ([int]$file[$blockMapper+1] -shl 16) + ([int]$file[$blockMapper+2] -shl 8) + [int]$file[$blockMapper+3]
	# Получить начало блока словаря вставок (первые четыре байта + адрес смещения)
	$insDictStart = $blockStart + ([int]$file[$blockStart] -shl 24) + ([int]$file[$blockStart+1] -shl 16) +	([int]$file[$blockStart+2] -shl 8) + [int]$file[$blockStart+3]
	# Конец блока вставок равен адресу начала блока + смещение на значение первых двух байт - 1.
	$insDictEnd = $insDictStart + ([int]$file[$insDictStart] -shl 8) + [int]$file[$insDictStart+1] - 1
	# Получить словарь вставок
	GetDictionary $insDictStart $insDictEnd
	# Получить начало блока словаря строк (седьмой байт от начала блока)
	$strDictStart = $blockStart + 6
	# Конец блока вставок равен адресу начала блока + смещение на значение первых двух байт - 1. (два байта в конце - лишние)
	$strDictEnd = $strDictStart + ([int]$file[$strDictStart] -shl 8) + [int]$file[$strDictStart+1] - 3
	# Поправить несколько значений в словаре (расчитаны на работу со словарем и не нужны при развернутых строках).
	# 1F0C - это FF, 1F0D - предположительно, 82 (задержка)
	$insDict[0] = @([byte]33,[byte]255)
	$insDict[1] = @([byte]33,[byte]130)
	$insDict[2] = @([byte]33,[byte]63,[byte]130)
	$insDict[5] = @([byte]63,[byte]255)
	$insDict[6] = @([byte]63,[byte]130)	
	# Получить словарь строк
	GetDictionary $strDictStart $strDictEnd $true
	# Сохранить массив строк в файл
	$stringDict.values | Sort numLink | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	# Прочитать csv файл
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	# Получить массив строк
	$stringArray = @{}
	0..($importArr.count-1) | % {
		if ($translateRus) { $transString = $importArr[$_].rusTranslation } else { $transString = $importArr[$_].engTranslation }
		$initialBytes = ($importArr[$_].ResolvedData).Split(" ") | % {[byte]$_}
		if ($transString) {
			$stringArray[$_] = StringToBytes $transString
		} else {
			$stringArray[$_] = $initialBytes
		}
	}
	# Кривое преобразование, чтобы получить из словаря массивов байтов один массив байтов, надо сделать как-то оптимальнее
	$strBytes = New-Object System.Collections.Generic.List[System.Object]
	0..($stringArray.count-1) | % {$stringArray[$_] | % {$strBytes.Add($_)}}
	#Считаем пойнтеры
	$pointers = CalculatePtr $stringArray
	# Это порядковый номер строки, двухбайтный номер которой начинается сразу после FFFF (следующий текстовый блок).
	$secondBank = @([byte](($secondBlockStrNum -band 0xffff) -shr 8), [byte]($secondBlockStrNum -band 0x00ff))
	# Какие-то непонятные дополнительные байты. Просто вставить как есть.
	#$unk_bytes1 = @([byte]15,[byte]240) 
	$unk_bytes2 = @([byte]6,[byte]16)
	# Собираем основной блок данных
	$dataBlock = $secondBank + $pointers + $unk_bytes2 + $strBytes
	# Считаем длину основного блока данных, прибавляем 4 (размер ссылки) и собираем байты указателя на дополнительный словарик
	$dataBlockLength = ($dataBlock.count+4)
	$dicLinkBytes = @([byte](($dataBlockLength -band 0xff000000) -shr 24),[byte](($dataBlockLength -band 0x00ff0000) -shr 16),[byte](($dataBlockLength -band 0x0000ff00) -shr 8),[byte]($dataBlockLength -band 0x000000ff))
	# Подготовить общий массив байтов
	$allDiagData = $dicLinkBytes + $dataBlock
	# Записать данные в ром
	0..($allDiagData.count-1) | % {
		$file[$_+$importOffset] = $allDiagData[$_]
	}
	# Перемапить пойнтер
	$file[$blockMapper] = [byte](($importOffset -band 0xff000000) -shr 24)
	$file[$blockMapper+1] = [byte](($importOffset -band 0x00ff0000) -shr 16)
	$file[$blockMapper+2] = [byte](($importOffset -band 0x0000ff00) -shr 8)
	$file[$blockMapper+3] = [byte]($importOffset -band 0x000000ff)
	# Сохранить ром
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
Write-Host "Translated" ($importArr | ? {$_.engTranslation}).count "strings out of" $importArr.count "-" ([int](($importArr | ? {$_.engTranslation}).count / $importArr.count * 100)) "percent."
Get-FileHash -Algorithm MD5 $patchedRomPath | Select Path,Algorithm,@{N="Hash";E={$_.Hash.ToLower()}}
