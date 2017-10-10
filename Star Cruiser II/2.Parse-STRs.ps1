Write-Host
Write-Host "Parse-STRs"
$mode = "import" # export, import

$mainPath = "D:\Translations\SC2\"
$strsDir = $mainPath + "HDI_FilesExport\"
$compiledStrsDir = $mainPath + "HDI_FilesImport\"
$exportCsvFile = $mainPath + "SCRIPT_Export\linesExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\linesImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

function PrepareString ($string, $lineFinish) {
	if (-not $string) {return $string}
	if ($string.Contains("[")) {return $string}
	$lengthLimit = 59
	$linesLimit = 2
	$textArr = $string.Split(" ")
	$resultString = ""
	$tmpString = ""
	$lines = 1
	0..($textArr.Count-1) | % {  
		if (($tmpString.Length + " " +  $textArr[$_].Length) -gt $lengthLimit) {
			$char = "[0D]"; if ($lines -ge $linesLimit) {$char = "[1F][0C]"; $lines = 0; Write-Host "This line was broken: " $string}
			$resultString += $tmpString.TrimEnd(" ") + $char
			$tmpString = ""
			$tmpString += $textArr[$_] + " "
			$lines++
		} else {
			$tmpString += $textArr[$_]
			$tmpString += " "
		}
		#$tmpString += $textArr[$_]
	} 
	$resultString += $tmpString.TrimEnd(" ") + $lineFinish
	$resultString
}

function ParseString ($string) {
	$currentByte = 0
	$kanaShift = 0x40
	$byteString = @()
	while ($currentByte -lt $string.Count) {
		if ($string[$currentByte] -eq 0x1e) {
			if ($kanaShift) {$kanaShift = 0} else {$kanaShift = 0x40}
		} elseif (($string[$currentByte] -ge 1 -and $string[$currentByte] -le 8) -or ($string[$currentByte] -ge 0x17 -and $string[$currentByte] -le 0x1d)) {
			$byteString += ParseString ($lineEndings[[int]$string[$currentByte]])
		} elseif ($string[$currentByte] -ge 0x20 -and $string[$currentByte] -le 0x7f) {
			$byteString += $replacementChars[[int]$string[$currentByte]]
		} elseif ($string[$currentByte] -ge 0xa0 -and $string[$currentByte] -le 0xdf) {
			$byteString += $replacementChars[([int]$string[$currentByte] + $kanaShift)]
		} elseif (($string[$currentByte] -ge 0x80 -and $string[$currentByte] -le 0x9f) -or ($string[$currentByte] -ge 0xe0 -and $string[$currentByte] -le 0xef)) {
			$byteString += @($string[$currentByte],$string[$currentByte+1])
			$currentByte++
		} else {$byteString += [System.Text.Encoding]::ASCII.GetBytes(("[" + ("{0:X2}" -f $string[$currentByte]) + "]"))}
		$currentByte++
	}
	$byteString
}

function StringToBytes ($string) {
	$stringBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($string)
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

if ($mode -eq "export") {
	$lineEndings = @{}
	$replacementChars = @{}
	$comFile = [System.IO.File]::ReadAllBytes($strsDir + "CRUISER.COM")
	0..7 | % {
		$lineAddr = (([int]$comFile[0xf70e+($_*2)+1] -shl 8) + [int]$comFile[0xf70e+($_*2)]) - 0x100
		$lineLength = $comFile[$lineAddr]
		$lineBytes = @()
		1..$lineLength | % {
			$lineBytes += $comFile[$lineAddr+$_]
		}
		$lineEndings[$_+1] = $lineBytes
	}

	0..6 | % {
		$lineAddr = (([int]$comFile[0xf76f+($_*2)+1] -shl 8) + [int]$comFile[0xf76f+($_*2)]) - 0x100
		$lineLength = $comFile[$lineAddr]
		$lineBytes = @()
		1..$lineLength | % {
			$lineBytes += $comFile[$lineAddr+$_]
		}
		$lineEndings[$_+0x17] = $lineBytes
	}

	0..0x60 | % {$replacementChars[$_+0x20] = @(($comFile[0x47af+($_*2)]),($comFile[0x47af+($_*2)+1]))}
	0..0x7F | % {$replacementChars[$_+0xa0] = @(($comFile[0x486f+($_*2)]),($comFile[0x486f+($_*2)+1]))}

	$strFiles = ls ($strsDir + "*STR*.BIN")
	$blocksNum = 415
	$libPtrBlockStart = 2
	$lineArr = @()

	foreach ($strFile in $strFiles) {
		$filePath = $strFile.FullName
		Write-Host "Parsing file:" $filePath
		$file = [System.IO.File]::ReadAllBytes($filePath)
		$libPtrBlockEnd = ([int]$file[3] -shl 8)+[int]$file[2] - 1
		$textPtrBlockStart = ([int]$file[1] -shl 8)+[int]$file[0]
		
		$currPtrByte = $libPtrBlockStart
		
		$i = 0
		$insDict = @{}
		while ($currPtrByte -le $libPtrBlockEnd) {
			$ptrData = ([int]$file[$currPtrByte+1] -shl 8)+[int]$file[$currPtrByte]
			$blockStart = $ptrData + 16
			$currentString = $blockStart
			0..15 | % {
				$string = @()
				0..([int]$file[$ptrData+$_]-1) | % {
					$string += $file[$currentString]
					$currentString++
				}
				$insDict[$i+0xf000] = $string
				$i++
			}
			$currPtrByte += 2
		}
		
		$totalBytes = @()
		$lineNum = 0
		
		0..($blocksNum -1) | % {
			$blockNum = $_
			$currBlockPtr = $textPtrBlockStart + ($blockNum * 2)
			$ptrData = ([int]$file[$currBlockPtr+1] -shl 8)+[int]$file[$currBlockPtr]
			$blockStart = $ptrData + 16
			$currentString = $blockStart
			0..15 | % {
				$localLineNum = $_
				$currentLineNum = $lineNum + $localLineNum
				$origBytes = @()
				$unpackedBytes = @()
				$compiledBytes = @()
				$origString = ""
				$normalizedString = ""
				$strLen = 0
				if ($ptrData) {
					$strLen = $file[$ptrData+$_]
					if ($strLen) {
						$crSr = 0
						while ($crSr -lt $strLen) {
							if ($file[$currentString+$crSr] -ge 0xf0) {
								$origBytes += @($file[$currentString+$crSr],$file[$currentString+$crSr+1])
								$dicLink = ([int]$file[$currentString+$crSr] -shl 8)+[int]$file[$currentString+$crSr+1]
								$unpackedBytes += $insDict[$dicLink]
								$crSr++
							} elseif (($file[$currentString+$crSr] -ge 0x80 -and $file[$currentString+$crSr] -le 0x9f) -or  ($file[$currentString+$crSr] -ge 0xe0 -and $file[$currentString+$crSr] -le 0xef)) {
								$origBytes += @($file[$currentString+$crSr],$file[$currentString+$crSr+1])
								$unpackedBytes += @($file[$currentString+$crSr],$file[$currentString+$crSr+1])
								$crSr++
							} else {
								$origBytes += $file[$currentString+$crSr]
								$unpackedBytes += $file[$currentString+$crSr]
							}
							$crSr++
						}
						$currentString += $strLen
						$lineArr += "" | Select @{N="fileName";E={$strFile.Name}},
							@{N="blockNum";E={$blockNum}},
							@{N="blockLineNum";E={$localLineNum}},
							@{N="lineNumHex";E={("{0:X4}" -f $currentLineNum)}},
							@{N="ptrOffset";E={("{0:X4}" -f $ptrData)}},
							@{N="origBytes";E={$origBytes}},
							@{N="unpackedBytes";E={$unpackedBytes}},
							@{N="textString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString((ParseString $unpackedBytes))}},
							engTranslation
					}
				}
				$totalBytes += $unpackedBytes
			}
			$lineNum += 16
		}
	}
	$lineArr | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
	
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$importFiles = $importArr | group Filename

	foreach ($importFile in $importFiles) {
		Write-Host "Processing file:" $importFile.Name
		$blockData = @{}
		$importFile.Group | Group blockNum | % {$blockData[[int]$_.Name] = $_.Group}
		$ptrs = @()
		$dataBlocks = @()
		$prtOffset = (415 * 2) + 2
		0..414 | % {
			$idxs = @()
			$strs = @()
			if ($blockData[$_].Count) {
				$ptrs += [byte]($prtOffset -band 0x00ff)
				$ptrs += [byte](($prtOffset -band 0xff00) -shr 8)
				$linesData = @{}
				$blockData[$_] | group blockLineNum | % {$linesData[[int]$_.Name] = $_.Group}
				0..15 | % {
					if ($linesData[$_].Count) {
						if ($linesData[$_].engTranslation) {
							#$strBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($linesData[$_].engTranslation)
							$lineFinish = (($linesData[$_].textString).ToCharArray() | Select -Last 4) -join ""
							# Temporal checking fix!!!
							if ($lineFinish -eq "[0D]") {$lineFinish = "[1F][0C]"}
							#
							if (-not ($lineFinish.Contains("["))) {$lineFinish = $null}
							$preparedString = PrepareString $linesData[$_].engTranslation $lineFinish
							#$strBytes = StringToBytes $linesData[$_].engTranslation
							$strBytes = StringToBytes $preparedString
						} else {
							$strBytes = ($linesData[$_].unpackedBytes).Split(" ") | % {[byte]$_}
						}
						#$bytesCount = $strBytes.Count
						#if ($strBytes[0] -eq 0x5e) {Write-Host "12345"}
						$idxs += [byte]($strBytes.Count)
						$strs += $strBytes
					} else {
						$idxs += [byte]0
					}
				}
				$dataBlock = ($idxs + $strs)
				$dataBlocks += $dataBlock
				$prtOffset += $dataBlock.Count
			} else {
				$ptrs += @([byte]0,[byte]0)
			}
		}
		$exportData = @([byte]2,[byte]0) + $ptrs + $dataBlocks
		[System.IO.File]::WriteAllBytes(($compiledStrsDir + $importFile.Name),$exportData)
	}
	Write-Host "Translated" ($importArr | ? {$_.engTranslation}).count "strings out of" $importArr.count "-" ([int](($importArr | ? {$_.engTranslation}).count / $importArr.count * 100)) "percent."
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds