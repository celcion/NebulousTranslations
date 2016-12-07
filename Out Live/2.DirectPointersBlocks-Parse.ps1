Write-Host
Write-Host "DirectPointersBlocks-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\OutLive\"
$exportTblFile = $mainPath + "TBLs\sjis_outlive.tbl"
$importTblFile = $mainPath + "TBLs\eng_outlive.tbl"
$originalRomPath = $mainPath + "ROM_Original\Out Live - It's Far a Future on Planet (J).pce"
$patchedRomPath = $mainPath + "ROM_Patched\Out Live - It's Far a Future on Planet (WIP).pce"
$exportCsvFile = $mainPath + "SCRIPT_Export\directpointerblocks_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\directpointerblocks_import.csv"
$sectionCodesFile = $mainPath + "section_names.txt"
$headerSize = 512

#$importStartOffset = 1052672 # 00101000

# 0000C166 - 12
# 0000C200 - 63
# 0000C445 - 52
# 0001349D - 180
# 00013D83 - 50
# 0001883C - 90
# 00035336 - 139
# 00039DB9 - 78
# 0003A13D - 27
# 0003A45F - 92
# 0003ACA0 - 12
# 0003AD7B - 12
# 0003AE83 - 12

$blocks = @("49510|12|4","49664|63|2","50245|52|2","79005|180|3","81283|50|3","100412|90|2","217910|139|2","236985|78|2","237885|27|3","238687|92|3","240800|12|3","241019|12|3","241283|12|3","101275|6|2","149666|4|2","98842|4|2","22587|3|-8","98816|4|2","213149|12|4","79001|1|3","123599|2|3")


# TODO: Add 18 block (Direction) mapping. 00 40
# 10 - 26025

$blocksPtrs = @("1-30555","2-2119|2141|2163|2185|9682|9703|9724","3-9748|9769|9790|9811|","4-4552","5-33069","6-17015|17068|17163|17316","7-3610","8-25022|22024+6|23433+6|22892+64|23241+64|23512+134|23534+148|22364+40|23322+40|23839+120|23860+122|23881+124","9-24940|17359+24","10-26351|26040","11-26812","12-27101","13-27667|28150","14-21647","15-23124","16-17144|17186|17224|17297|17434","17-22510","18-17496|17520|17542","19-29856|29787|29805","20-4531","21-4076|4134","22-30583")
$importStartOffset = 262912

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
$tblFile = [System.IO.File]::ReadAllBytes($exportTblFile)
$exportTbl = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $exportTbl[([convert]::ToInt32($tmp[0].Trim(),16))] = $tmp[1].Replace("`r","")}
$tblFile = [System.IO.File]::ReadAllBytes($importTblFile)
$importTbl = New-Object Collections.Hashtable ([StringComparer]::CurrentCulture)
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $importTbl[($tmp[1].Replace("`r",""))] = ([convert]::ToInt32($tmp[0],16))}

$blocksPrtsDict = @{}
$blocksPtrs | % {$blocksPrtsDict[($_.Split("-")[0])] = (($_.Split("-")[1]))}

function BytesToString ($bstring) {
	$string = ""
	$charNum = 0
	while ($charNum -lt $bstring.count) {
		$char = ""
		$currByte = [int]$bstring[$charNum]
		$char = $exportTbl[$currByte]
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
	$resultArr = New-Object System.Collections.Generic.List[System.Object]
	$stringArr = $string.ToCharArray()
	$charNum = 0
	while ($charNum -lt $stringArr.Count) {
		if ($stringArr[$charNum] -eq "[" -and $stringArr[$charNum+3] -eq "]") {
			$resultArr.Add([byte]([Convert]::ToInt32(([char]$stringArr[$charNum+1] + [char]$stringArr[$charNum+2]),16)))
			$charNum += 3
		} else {
			$char = $importTbl[[string]$stringArr[$charNum]]
			if ($char -gt 255) {
				$resultArr.Add([byte](($char -band 0xff00) -shr 8))
				$resultArr.Add([byte]($char -band 0x00ff))
			} else {
				$resultArr.Add([byte]$char)
			}
		}
		$charNum++
	}
	$resultArr
}

function PrepareString ($string,$section) {
	if (-not $string) {return $string}
	if ($string.Contains("[")) {return $string}
	$lengthLimit = 17
	if($section -eq "4") {$lengthLimit = 16}
	$linesLimit = 5
	$textArr = $string.Split(" ")
	$resultString = ""
	$tmpString = ""
	$lines = 1
	0..($textArr.Count-1) | % {  
		if (($tmpString.Length + " " +  $textArr[$_].Length) -gt $lengthLimit) {
			$char = "[FE]"; if ($lines -gt $linesLimit) {Write-Warning ("This string has more than 6 lines! " + $string)}
			$resultString += $tmpString + $char
			$tmpString = ""
			$lines++
		} else {
			$tmpString += " "
		}
		$tmpString += $textArr[$_] 
	} 
	$resultString += $tmpString
	$resultString.TrimStart(" ")
}

if ($mode -eq "export") {
	$ramCodesArr = gc $sectionCodesFile
	$ramCodesDict = @{}
	$ramCodesArr | % {$ramCodesDict[([int](($_.Split("-")[0]).Trim()))] = $_.Split("-")[1].Trim()}
	$strings = @()
	$section = 1
	foreach ($block in $blocks) {
		$startOffset = [int]($block.Split("|")[0])
		$numStr = [int]($block.Split("|")[1])
		$mprOffset = ([int]($block.Split("|")[2])) * 8192
		$currentOffset = $startOffset
		1..$numStr | % {
			$string = @()
			$strOffset = (([int]$file[$currentOffset+1] -shl 8) + [int]$file[$currentOffset]) + ($startOffset - ($startOffset % 8192)) + $headerSize - $mprOffset
			$strPos = $strOffset
			$strLength = $file[$strPos]
			$strPos++
			$currentLength = 1
			while($currentLength -le $strLength){
				$string += $file[$strPos]
				$currentLength++
				$strPos++
			}
			$resString = BytesToString $string
			$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f $currentOffset)}},
						@{N="strOffset";E={("{0:X8}" -f $strOffset)}},
						@{N="strLength";E={$strLength}},
						@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
						@{N="romData";E={$string}},
						@{N="section";E={$section}},
						@{N="sectionName";E={$ramCodesDict[$section]}},
						@{N="resolvedString";E={$resString}},
						engTranslation
			$currentOffset += 2
		}
		$section++
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
	
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$blockStart = 16640
	$blocksGrp = $importArr | group block
	foreach ($blockData in $blocksGrp) {
		$ptrs = @()
		$strs = @()
		$ptrBlockSize = $blockData.Group.Count * 2
		$sectionGrp = $blockData.Group | group section
		$blockImportOffset = $importStartOffset + (16384 * [int]$blockData.Name)
		$ptrNum = 0
		$currentStrOffset = $blockStart + $ptrBlockSize
		foreach ($section in $sectionGrp) {
			if ($blocksPrtsDict[$section.Name]) {
				$blocksPrtsDict[$section.Name].Split("|") | % {
					$ptrShift = 0
					if ($_.Contains("+")) {
						$nums = $_.Split("+")
						$ptrShift = [int]$nums[1]
						$blockPtrOffset = [int]$nums[0]
					} else {
						$blockPtrOffset = [int]$_
					}
					$blockPtr = $blockStart + $ptrNum + $ptrShift
					$file[$blockPtrOffset] = [byte]($blockPtr -band 0x00ff)
					$file[$blockPtrOffset+1] = [byte](($blockPtr -band 0xff00) -shr 8)
				}
			}
			foreach ($importString in $section.Group) {
				$string = @()
				if ($importString.engTranslation) {
					$strText = PrepareString $importString.engTranslation $importString.section
					$strBytes = StringToBytes $strText
				} else {
					$strBytes = ($importString.romData).Split(" ") | % {[byte]$_}
				}
				$string += [byte]($strBytes.Count)
				$string += $strBytes
				$strs += $string
				$ptrs += [byte]($currentStrOffset -band 0x00ff)
				$ptrs += [byte](($currentStrOffset -band 0xff00) -shr 8)
				$currentStrOffset += $string.Count
				$ptrNum += 2
			}
		}
		$blockInsertData = $ptrs + $strs
		if ($blockInsertData.Count -le 16384) {
			0..($blockInsertData.Count-1) | % {$file[$blockImportOffset+$_] = $blockInsertData[$_]}
		} else {
			Write-Warning ("Block " + $blockData + " data is to big to fit the limits! Won't be inserted.")
		}
	}
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds