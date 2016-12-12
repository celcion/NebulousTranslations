Write-Host
Write-Host "KanjiText-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\Vixen357\"
$tblFile = $mainPath + "TBLs\sjis_opening_ending.tbl"
$asmHackFile = $mainPath + "asm\kanji\add.bin"
$fontFile = $mainPath + "font.bin"
$originalRomPath = $mainPath + "ROM_Original\Vixen 357 (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"
$exportCsvFile = $mainPath + "SCRIPT_Export\kanjitext_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\kanjitext_import.csv"

$blocks = @("117576|1","192504|16","113374|1","113462|1","113550|1","113814|1","113726|1","113638|1","113134|1","113198|1","113286|1","112692|1","112782|1","112386|1","111748|1")

$asmImportOffset = 1130496 # 00114000
$fontImportOffset = 1134592 # 00115000 - Need to reflect this in the ASM code!
$textImportOffset = 1142784 # 00117000

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
$tblFile = [System.IO.File]::ReadAllBytes($tblFile)
$tblDic = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $tblDic[$tmp[0]] = $tmp[1].Replace("`r","")}

function ResolveString ($bstring) {
	$string = ""
	$charNum = 0
	while ($charNum -lt $bstring.count) {
		$currByte = ([int]$bstring[$charNum] -shl 8) + [int]$bstring[$charNum+1]
		$char = $tblDic[("{0:X4}" -f ($currByte))]
		if ($char) {
			$string += $char
		} else {
			$string += ("["+("{0:X4}" -f $currByte)+"]")
		}
		$charNum += 2
	}
	$string
}

function PrepareString ($string) {
	if (-not $string) {return $string}
	if ($string.Contains("[")) {return $string}
	$lengthLimit = 32
	$resultString = ""
	$chompEnd = $false
	if ($string.Substring($string.Length-1) -eq "^") {
		$chompEnd = $true
		$string = $string.TrimEnd("^")
	}

	foreach ($strPart in ($string.Split("|"))) {
		$tmpString = ""
		if ($strPart) {
			$textArr = $strPart.Split(" ")
			0..($textArr.Count-1) | % {  
				if (($tmpString.Length + " " +  $textArr[$_].Length) -ge $lengthLimit) {
					if ($tmpString.Length -lt 30) {
						if ($tmpString.Length%2) {$tmpString += " "}
						$tmpString += "[FF][FF]"
					} else {
						$tmpString = "{0,-32}" -f $tmpString
					}
					$resultString += $tmpString
					$tmpString = ""
				} else {
					$tmpString += " "
				}
				$tmpString += $textArr[$_]
			}
			if ($tmpString.Length%2) {$tmpString += " "}
			$resultString += $tmpString + "[FF][FF]"
		} else {
			$resultString += "[FF][FF]"
		}
	}
	if ($chompEnd) {
		$resultString.TrimEnd("[FF][FF]").Replace("_"," ")
	} else {
		$resultString.Replace("_"," ")
	}
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
			while($file[$strPos]+$file[$strPos+1]){
				$string += $file[$strPos]
				$string += $file[$strPos+1]
				$strPos += 2
			}
			$resString = ResolveString $string
			$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f $currentOffset)}},
						@{N="strOffset";E={("{0:X8}" -f $strOffset)}},
						@{N="resolvedString";E={$resString}},
						engTranslation
			$currentOffset += 4
		}
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	# Insert jump
	# 0000B114
	$file[45332] = 78
	$file[45333] = 185
	$file[45334] = [byte](($asmImportOffset -band 0xff000000) -shr 24)
	$file[45335] = [byte](($asmImportOffset -band 0x00ff0000) -shr 16)
	$file[45336] = [byte](($asmImportOffset -band 0x0000ff00) -shr 8)
	$file[45337] = [byte]($asmImportOffset -band 0x000000ff)
	$file[45338] = 78
	$file[45339] = 117
	
	# Insert ASM code
	$asmHack = [System.IO.File]::ReadAllBytes($asmHackFile)
	0..($asmHack.count-1) | %{
		$file[$_+$asmImportOffset] = $asmHack[$_]
	}
	
	# Insert Font file
	$font = [System.IO.File]::ReadAllBytes($fontFile)
	0..($font.count-1) | %{
		$file[$_+$fontImportOffset] = $font[$_]
	}
	
	# Прочитать csv файл
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$currentPos = $textImportOffset
	$importArr | ? {$_.engTranslation} | % {
		$strText = PrepareString $_.engTranslation
		$strBytes = StringToBytes $strText
		$strBytes += [byte]0
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
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds