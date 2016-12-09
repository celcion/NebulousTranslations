cls

# Массив, состоящий из трех блоков пойнтеры-текст, в начале блока даются указатели на начало указателей каждого блока, затем идут двухбайтные сдвиги, указывающие на каждую строку
# ВАЖНО! Ремапинг в конец рома по каким-то причинам не работает на новых эмуляторах (и, видимо, на "железе"), вероятно из-за выхода за два байта.
# Пока привел таблицу в размерность старой (общий объем не более 1225 байт) и вставил на старое место.
# Но надо переделать нормально.
# UPD: ремапинг работает, если размер вставки остается таким же, как был. Где-то задается размерность?
# UPD2: похоже, загвоздка была в том, что первый указатель смещения блока (в заголовке) должен быть кратен 2. Внес изменения, теперь, вроде бы, все работает корректно.

# В роме три ссылки на адрес этого блока
# 0000BAEE => 0000C9EE
# 0000BC78 => 0000C9EE
# 0000BD2E => 0000C9EE
# Вероятно, так вызываются разные блоки.

$mode = "import" # export, import
$translateRus = $false

$mainPath = "D:\Translations\StarCruiserMD\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Original\Star Cruiser (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Star Cruiser (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\2bpointers_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\2bpointers_import.csv"

$importOffset = 525024 # 000802E0
#$importOffset = 51694 # 0000C9EE
$startOffset = 51694 # 0000C9EE
$pointersOffsets = @(47854,48248,48430)
#$pointersOffsets = @()

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
	$strings = @()
	for($block=0;$block -le 2;$block++) {
		# Получаем смещение до начала блока пойнтеров текущего блока
		$pointersOffset = ([int]$file[$startOffset+($block*2)] -shl 8) + $file[$startOffset+($block*2)+1]
		# Получаем начало блока пойнтеров
		$blockStart = $startOffset + $pointersOffset
		# Задаем временную переменную предыдущего пойнтера
		$previousPtrShift = 0
		$posPtr = $blockStart
		while ($true) {
			$currentPtrShift = ([int]$file[$posPtr] -shl 8) + $file[$posPtr+1]
			# Проверяю окончание таблицы пойнтеров тем, что следующее смещение не должно быть больше, чем на 256 больше предыдущего. Не лучший способ, но работает.
			if (($currentPtrShift - $previousPtrShift) -gt 256) {break}
			$stringOffset = $blockStart + $currentPtrShift
			$posFile = $stringOffset
			$string = @()
			# Разделителем является 0
			while($file[$posFile]){
				$string += $file[$posFile]
				$posFile++
			}
			# Надо добавить стоповый ноль в конце каждой строки, но делать это лучше при импорте
			$resString = ResolveString $string
			$strings += "" | Select @{N="block";E={$block}},
									@{N="ptrBytes";E={("{0:X4}" -f $currentPtrShift)}},
									@{N="strOffset";E={("{0:X8}" -f $stringOffset)}},
									@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
									@{N="romData";E={$string}},
									@{N="resolvedString";E={$resString}},
									engTranslation,rusTranslation
			$previousPtrShift = $currentPtrShift
			$posPtr+=2
		}
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	# Прочитать csv файл
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile

	$blocks = @{}
	$blocksGrp = $importArr | group block
	foreach($blockPart in $blocksGrp) {
		$blockData = $blockPart.Group
		# Начальная позиция смещения = количество строк * 2 (по два байта на строку)
		$ptrPos = ($blockData.Count)*2
		$ptrs = @()
		$previousPtrBytes = 0
		$previousStrCount = 0
		$strings = @()
		$offset = 0
		$stringPtrDict = @{}
		# Алгоритм: перебираем словарь строк, отсеивая повторы по принципу "текущий пойнтер = предыдущий пойнтер + длина предыдущей строки", добавляя смещение по блоку, а так же приписывая изначальный пойнтер в словаре.
		# Потом на основании этого сращиваем повторным прогоном, используя полученный словарь строк. Не лучший алгоритм, но, вроде, работает.
		0..($blockData.count-1) | %{
			$i = $_
			$currentPtrBytes = [Convert]::ToInt32(($blockData[$i].ptrBytes),16)
			$initialBytes = ($blockData[$i].romData).Split(" ") | % {[byte]$_}
			if ($translateRus) { $transString = $blockData[$i].rusTranslation } else { $transString = $blockData[$i].engTranslation }
			if ($currentPtrBytes -eq ($previousPtrBytes+$previousStrCount) -or $i -eq 0) {
				$string = @()
				if ($transString) {
					# Преобразование в массив байт. Пока кодировка тупо ASCII. Для русского (и универсальности) надо будет потом реализовать преобразование через .tbl
					$string += [System.Text.Encoding]::ASCII.GetBytes($transString)
				} else {
					$string += $initialBytes
				}
				$string += [byte]0
				$strings += $string
				#$stringDict[$blockData[$i].ptrBytes] = "" | Select @{N="string";E={$transString}},@{N="bytes";E={$string}},@{N="offset";E={$offset}}
				$stringPtrDict[$blockData[$i].ptrBytes] = $offset
				
				$offset += $string.count
				$previousPtrBytes = $currentPtrBytes
				$previousStrCount = $initialBytes.count+1
			}
			
		}
		0..($blockData.count-1) | %{
			$ptr = $stringPtrDict[$blockData[$_].ptrBytes]+$ptrPos
			$ptrs += [byte](($ptr -band 0xff00) -shr 8)
			$ptrs += [byte]($ptr -band 0xff)
		}
		# Размер блока должен быть четным
		$blockInsertData = $ptrs + $strings
		if ($blockInsertData.count%2) {$blockInsertData += [byte]0}
		$blocks[[int]$blockPart.Name] = $blockInsertData
	}
	$header = @()
	$currentBlockShift = ($blocks.count * 2)
	0..($blocks.count-1) | % {
		$header += [byte](($currentBlockShift -band 0xff00) -shr 8)
		$header += [byte]($currentBlockShift -band 0xff)
		$currentBlockShift += $blocks[$_].count
	}
	$strBytes = New-Object System.Collections.Generic.List[System.Object]
	0..($blocks.count-1) | % {$blocks[$_] | % {$strBytes.Add($_)}}
	$strBytes = $header + $strBytes
	#if ($strBytes.count -gt 1225) {Write-Warning "Importing data is longer than in ROM. Importing aborted...";exit}
	0..($strBytes.count-1) | % {
		$file[$_+$importOffset] = $strBytes[$_]
	}
	# Перемапить пойнтеры
	$pointersOffsets | % {
		$file[$_] = [byte](($importOffset -band 0xff000000) -shr 24)
		$file[$_+1] = [byte](($importOffset -band 0x00ff0000) -shr 16)
		$file[$_+2] = [byte](($importOffset -band 0x0000ff00) -shr 8)
		$file[$_+3] = [byte]($importOffset -band 0x000000ff)
	}
	# Сохранить ром
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
Get-FileHash -Algorithm MD5 $patchedRomPath | Select Path,Algorithm,@{N="Hash";E={$_.Hash.ToLower()}}
