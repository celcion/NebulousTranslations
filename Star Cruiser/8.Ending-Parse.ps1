cls

# Вставка требует перемапливания пойнтера, указывающего на начало блока. Однако, пойтер относительный (LEA (PC)), соответственно необходимо сделать оттуда джамп, затерев частично следующую команду и по адресу джампа заменить относительный указатель на абсолютный, вставить затертую джампом комманду и вертуться обратно.
# Изначальный код по адресу 00018AEA
# LEA $18F2C(PC),A1
# MOVE.W $0(A1,D3.W),D3
# LEA $0(A1,D3.W),A1

$mode = "import" # export, import
$translateRus = $false

$mainPath = "D:\Translations\StarCruiserMD\"
$tblFile = $mainPath + "TBLs\sjis_romtable.tbl"
$tblFileNoHK = $mainPath + "TBLs\sjis_romtable_nohk.tbl"
$originalRomPath = $mainPath + "ROM_Original\Star Cruiser (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Star Cruiser (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\ending_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\ending_import.csv"

$blockOffsetExport = 102188 # 00018F2C
$blockOffsetImport = 532480 # 00082000
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
	# Получаем смещение до начала блока пойнтеров текущего блока
	$pointersOffset = $blockOffsetExport
	# Получаем начало блока пойнтеров
	$blockStart = $pointersOffset
	# Задаем временную переменную предыдущего пойнтера
	$previousPtrShift = 0
	$posPtr = $blockStart
	while ($true) {
		$bytes = @()
		# Строку надо резолвить на каждую итерацию, потому что сбрасывается байт переключения катаканы/хираганы после каждого 0x0
		$resString = ""
		$currentPtrShift = ([int]$file[$posPtr] -shl 8) + $file[$posPtr+1]
		# Проверяю окончание таблицы пойнтеров тем, что следующее смещение не должно быть больше, чем на 512 больше предыдущего. Не лучший способ, но работает.
		if (($currentPtrShift - $previousPtrShift) -gt 512) {break}
		$stringOffset = $blockStart + $currentPtrShift
		$posFile = $stringOffset
		# Если строка начинается с 0x1, или 0x2 - это текст с портретом, у которого в начале отдельный блок, после которого идет основной.
		if ($file[$posFile] -le 2) {
			$numStr = $file[$posFile]
			# Первый байт обозначает номер картинки, его копируем как есть.
			$resString += ("[" + ("{0:X2}" -f $file[$posFile]) + "]")
			$bytes += $file[$posFile]
			$posFile++
			while ($numStr) {
				$string = @()
				$numStr = $numStr - 1
				$string += [System.Text.Encoding]::ASCII.GetBytes("[" + ("{0:X2}" -f $file[$posFile]) + "]")
				$bytes += $file[$posFile]
				# Из-за того, что ссылка на персонажа делается одним байтом 0x24, приходится впиливать дополнительный костыль...
				if ($file[$posFile] -eq 36) {$posFile++;break}
				$posFile++
				while($file[$posFile]){
					$string += $file[$posFile]
					$posFile++
					$bytes += $file[$posFile]
				}
				$string += 0
				$resString += ResolveString $string
				$posFile++
			}
		}
		# Основной блок, здесь количество строк определяет первый байт, от которого отнято 0x10.
		$numStr = $file[$posFile] - 16
		while ($numStr) {
			$string = @()
			$numStr = $numStr - 1
			while($file[$posFile]){
				$bytes += $file[$posFile]
				$string += $file[$posFile]
				$posFile++
			}
			$string += 0
			$resString += ResolveString $string
			$bytes += $file[$posFile]
			$posFile++
		}

		$strings += "" | Select @{N="ptrBytes";E={("{0:X4}" -f $currentPtrShift)}},
								@{N="strOffset";E={("{0:X8}" -f $stringOffset)}},
								@{N="romBytes";E={$bytes}},
								@{N="resolvedString";E={$resString}},
								engTranslation,rusTranslation
		$previousPtrShift = $currentPtrShift
		$posPtr+=2
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	# Прочитать csv файл
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	# Начальная позиция смещения = количество строк * 2 (по два байта на строку)
	$ptrPos = ($importArr.Count)*2
	$ptrs = @()
	$strings = @()
	$importArr | % {
		$ptrs += [byte](($ptrPos -band 0xff00) -shr 8)
		$ptrs += [byte]($ptrPos -band 0xff)
		$currentString = @()
		if ($translateRus) { $transString = $_.rusTranslation } else { $transString = $_.engTranslation }
		$initialBytes = ($_.RomBytes).Split(" ") | % {[byte]$_}
		if ($transString) {
			$currentString += StringToBytes $transString
		} else {
			$currentString += $initialBytes
		}
		$strings += $currentString
		$ptrPos += $currentString.Count
	}
	$insertData = $ptrs + $strings
	0..($insertData.count-1) | % {
		$file[$_+$blockOffsetImport] = $insertData[$_]
	}
	# ASM Haxxx
	#################
	# Original bytes
	# 43 FA 04 40
	# 36 31 30 00
	#################
	
	# Add jump and NOP
	# 4E B9 00 08 1F F0
	# 4E 71

	$changeBytes = @(78,185,0,8,31,240,78,113)
	0..($changeBytes.count-1) | % {
		$file[$_+101098] = $changeBytes[$_]
	}

	# Insert changed
	# 43 F9 00 08 20 00
	# 36 31 30 00
	# 4E 75

	$insertBytes = @(67,249,0,8,32,0,54,49,48,0,78,117)
	0..($insertBytes.count-1) | % {
		$file[$_+532464] = $insertBytes[$_]
	}
	
	# Поправить кредитсы - заменить 25 на 5B, а 27 на 5C
	103543..104262 | % {
		if ($file[$_] -eq 37) {$file[$_] = 91}
		if ($file[$_] -eq 39) {$file[$_] = 92}
	}
		
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
Get-FileHash -Algorithm MD5 $patchedRomPath | Select Path,Algorithm,@{N="Hash";E={$_.Hash.ToLower()}}
