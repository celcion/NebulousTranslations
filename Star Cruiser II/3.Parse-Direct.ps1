Write-Host
Write-Host "Parse-Direct"
$mode = "import" # export, import

$mainPath = "D:\Translations\SC2\"
$strsDir = $mainPath + "HDI_FilesExport\"
$compiledStrsDir = $mainPath + "HDI_FilesImport\"
$exportCsvFile = $mainPath + "SCRIPT_Export\directExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\directImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

# CRUISER.COM - 0x16eb
# search in 59a8 for "cd44"

#"OPENING.BIN|p|0x30dc|???",
#"OPENING.BIN|p|0x30de|???",
#"OPENING.BIN|p|0x30e0|???"

$lineOffsets = @("SCSUB.BIN|p|0x3e85|???",
				 "SCSUB.BIN|p|0x3e87|???",
				 "SCSUB.BIN|p|0x3e89|???",
				 "SCSUB.BIN|p|0x3e8b|???",
				 "SCSUB.BIN|p|0x3e8d|???",
				 "SCSUB.BIN|p|0x3e8f|???",
				 "SCSUB.BIN|p|0x4396|???",
				 "SCSUB.BIN|p|0x43af|???",
				 "SCSUB.BIN|p|0x43ba|???",
				 "SCSUB.BIN|p|0x43ce|???",
				 "SCSUB.BIN|p|0x43e2|???",
				 "SCSUB.BIN|p|0x44c1|???",
				 "SCSUB.BIN|p|0x44c6|???",
				 "SCSUB.BIN|p|0x4290|???",
				 "SCSUB.BIN|p|0x429b|???",
				 "SCSUB.BIN|p|0x53ce|???",
				 "SCSUB.BIN|p|0x665c|???",
				 "SCSUB.BIN|p|0xde81|???",
				 "SCSUB.BIN|p|0xdec3|???",
				 "CMDSUB.BIN|p|0x022f|???",
				 "CMDSUB.BIN|p|0x0237|???",
				 "CMDSUB.BIN|p|0x0881|???",
				 "CMDSUB.BIN|p|0x0b72|???",
				 "CMDSUB.BIN|p|0x0b74|???",
				 "CMDSUB.BIN|p|0x0b76|???",
				 "CMDSUB.BIN|p|0x0b78|???",
				 "CMDSUB.BIN|p|0x0b7a|???",
				 "CMDSUB.BIN|p|0x0b7c|???",
				 "CMDSUB.BIN|p|0x0b7e|???",
				 "CMDSUB.BIN|p|0x0b7a|???",
				 "CMDSUB.BIN|p|0x0b80|???",
				 "CMDSUB.BIN|p|0x0b82|???",
				 "CMDSUB.BIN|p|0x0b84|???",
				 "CMDSUB.BIN|p|0x0b86|???",
				 "CMDSUB.BIN|p|0x0b88|???",
				 "CMDSUB.BIN|p|0x0b8a|???",
				 "CMDSUB.BIN|p|0x0b8c|???",
				 "CMDSUB.BIN|p|0x229f|???",
				 "CMDSUB.BIN|p|0x22f3|???",
				 "CMDSUB.BIN|p|0x23e2|???",
				 "CMDSUB.BIN|p|0x23eb|???",
				 "CMDSUB.BIN|p|0x2471|???",
				 "CMDSUB.BIN|p|0x26ae|???",
				 "CMDSUB.BIN|p|0x2730|???",
				 "CMDSUB.BIN|p|0x274a|???",
				 "CMDSUB.BIN|p|0x2751|???",
				 "CRUISER.COM|p|0x0d59|???",
				 "CRUISER.COM|p|0x0d65|???",
				 "CRUISER.COM|p|0x0d71|???",
				 "CRUISER.COM|p|0x0d76|???",
				 "CRUISER.COM|p|0x0dd3|???",
				 "CRUISER.COM|p|0x1999|???",
				 "CRUISER.COM|p|0xe903|???",
				 "CRUISER.COM|p|0x4c4a|???",
				 "CRUISER.COM|p|0x28bc|???",
				 "CRUISER.COM|p|0x28be|???",
				 "CRUISER.COM|p|0x28c0|???",
				 "CRUISER.COM|p|0x28c2|???",
				 "CRUISER.COM|p|0x28c4|???",
				 "CRUISER.COM|p|0x28c6|???",
				 "CRUISER.COM|p|0x28c8|???",
				 "CRUISER.COM|p|0x28ca|???",
				 "CRUISER.COM|p|0x28cc|???",
				 "CRUISER.COM|p|0x28ce|???",
				 "CRUISER.COM|p|0x28d0|???",
				 "CRUISER.COM|p|0x2d1f|???",
				 "CRUISER.COM|p|0x2e09|???",
				 "CRUISER.COM|p|0x2f0e|???",
				 "CRUISER.COM|p|0xb5dd|???",
				 "CRUISER.COM|p|0xb69e|???",
				 "CRUISER.COM|p|0xb6a0|???",
				 "CRUISER.COM|p|0xb6a2|???",
				 "CRUISER.COM|p|0xb6a4|???",
				 "CRUISER.COM|p|0xb6a6|???",
				 "CRUISER.COM|p|0xb6a8|???",
				 "CRUISER.COM|p|0xb6aa|???",
				 "CRUISER.COM|p|0xb6ac|???",
				 "CRUISER.COM|p|0xb766|???",
				 "CRUISER.COM|p|0xb768|???",
				 "CRUISER.COM|p|0xb76a|???",
				 "CRUISER.COM|p|0xb76c|???",
				 "CRUISER.COM|p|0xe8f8|???")

# local arrays: SCSUB: 0x3e85 - 6 times

function ParseString ($string) {
	$currentByte = 0
	$kanaShift = 0
	$byteString = @()
	while ($currentByte -lt $string.Count) {
		if ($string[$currentByte] -eq 0x1e) {
			if ($kanaShift) {$kanaShift = 0} else {$kanaShift = 0x40}
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

function ParseBytes ($parseFile, $parseOffset) {
	$lineStrBytes = @()
	$lineCurrentOffset = $parseOffset
	if (-not $parseFile[$lineCurrentOffset]) {
		$lineStrBytes += $parseFile[$lineCurrentOffset]
		$lineCurrentOffset++
	}
	while ($parseFile[$lineCurrentOffset]) {
		if ($parseFile[$lineCurrentOffset] -eq 9) {
			$lineStrBytes += @($parseFile[$lineCurrentOffset],$parseFile[$lineCurrentOffset+1],$parseFile[$lineCurrentOffset+2])
			$lineCurrentOffset += 3
		} elseif ($parseFile[$lineCurrentOffset] -eq 0x11) {
			$lineStrBytes += @($parseFile[$lineCurrentOffset],$parseFile[$lineCurrentOffset+1])
			$lineCurrentOffset += 2
		} else {
			$lineStrBytes += $parseFile[$lineCurrentOffset]
			$lineCurrentOffset++
		}
	}
	$lineStrBytes
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

	0..0x60 | % {$replacementChars[$_+0x20] = @(($comFile[0x47af+($_*2)]),($comFile[0x47af+($_*2)+1]))}
	0..0x7F | % {$replacementChars[$_+0xa0] = @(($comFile[0x486f+($_*2)]),($comFile[0x486f+($_*2)+1]))}
	
	$lineArr = @()
	
	$linesObj = @()
	@("CMDSUB.BIN","SCSUB.BIN") | % {
		$lineOffset = 0
		$lineFileName = $_
		Write-Host "Processing file:" $lineFileName
		$lineFile = [System.IO.File]::ReadAllBytes($strsDir + $lineFileName)
		while ($lineOffset -lt $lineFile.Count) {
			$possiblePtr = ([int]$lineFile[$lineOffset+2] -shl 8)+[int]$lineFile[$lineOffset+1]
			 # E150 - ?
			if (($lineFile[$lineOffset] -eq 0xb9) `
				   -and ($possiblePtr -ge 0x00d4) `
				   -and ($possiblePtr -ne 0x0138) `
				   -and ($possiblePtr -ne 0x0140) `
				   -and ($possiblePtr -ne 0x0190) `
				   -and ($possiblePtr -ne 0x01f4) `
				   -and ($possiblePtr -ne 0xf182) `
				   -and ($possiblePtr -ne 0x0200) `
				   -and ($possiblePtr -ne 0x027c) `
				   -and ($possiblePtr -ne 0x02bc) `
				   -and ($possiblePtr -ne 0x02f8) `
				   -and ($possiblePtr -ne 0x02f9) `
				   -and ($possiblePtr -ne 0x06eb) `
				   -and ($possiblePtr -ne 0x0774) `
				   -and ($possiblePtr -ne 0x07d0) `
				   -and ($possiblePtr -ne 0x0800) `
				   -and ($possiblePtr -ne 0x03fe) `
				   -and ($possiblePtr -ne 0x03e8) `
				   -and ($possiblePtr -ne 0x05eb) `
				   -and ($possiblePtr -ne 0x0bb8) `
				   -and ($possiblePtr -ne 0x0fc7) `
				   -and ($possiblePtr -ne 0x1000) `
				   -and ($possiblePtr -ne 0x15da) `
				   -and ($possiblePtr -ne 0x1688) `
				   -and ($possiblePtr -ne 0x1f40) `
				   -and ($possiblePtr -ne 0x20d0) `
				   -and ($possiblePtr -ne 0x211d) `
				   -and ($possiblePtr -ne 0x2bc0) `
				   -and ($possiblePtr -ne 0x2903) `
				   -and ($possiblePtr -ne 0x2913) `
				   -and ($possiblePtr -ne 0x04ad) `
				   -and ($possiblePtr -ne 0x0435) `
				   -and ($possiblePtr -ne 0x0449) `
				   -and ($possiblePtr -ne 0x0499) `
				   -and ($possiblePtr -ne 0x0485) `
				   -and ($possiblePtr -ne 0x08ec) `
				   -and ($possiblePtr -ne 0x4000) `
				   -and ($possiblePtr -ne 0x474f) `
				   -and ($possiblePtr -ne 0x53b8) `
				   -and ($possiblePtr -ne 0x5522) `
				   -and ($possiblePtr -ne 0x5532) `
				   -and ($possiblePtr -ne 0x63d2) `
				   -and ($possiblePtr -ne 0x797c) `
				   -and ($possiblePtr -ne 0x9d8f) `
				   -and ($possiblePtr -ne 0xa53b) `
				   -and ($possiblePtr -ne 0xb3d6) `
				   -and ($possiblePtr -ne 0xb582) `
				   -and ($possiblePtr -ne 0xb88e) `
				   -and ($possiblePtr -ne 0xbb82) `
				   -and ($possiblePtr -ne 0xbbe0) `
				   -and ($possiblePtr -ne 0xbbe9) `
				   -and ($possiblePtr -ne 0xbbf2) `
				   -and ($possiblePtr -ne 0xbccf) `
				   -and ($possiblePtr -ne 0xbcd0) `
				   -and ($possiblePtr -ne 0xbf02) `
				   -and ($possiblePtr -ne 0xcc00) `
				   -and ($possiblePtr -ne 0xcfbc) `
				   -and ($possiblePtr -ne 0xd814) `
				   -and ($possiblePtr -ne 0xe150) `
				   -and ($possiblePtr -ne 0xe4cf) `
				   -and ($possiblePtr -ne 0xe800) `
				   -and ($possiblePtr -ne 0xe804) `
				   -and ($possiblePtr -ne 0xe842) `
				   -and ($possiblePtr -ne 0xeb55) `
				   -and ($possiblePtr -ne 0xbdd0)) {
				$lineBytes = ParseBytes $lineFile $possiblePtr
				if ($lineBytes.Count -gt 3) {
					$linesObj += "" | Select @{N="fileName";E={$lineFileName}},
								@{N="ptrOffset";E={("{0:X4}" -f ($lineOffset+1))}},
								@{N="lineOffset";E={("{0:X4}" -f $possiblePtr)}},
								@{N="lineBytes";E={$lineBytes}},
								@{N="textString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString((ParseString $lineBytes))}},
								engTranslation
				}
			}
			$lineOffset++
		}
	}
	
	
	$lineOffsets | % {
		$lineStrBytes = @()
		$lineOffset = $null
		$lineArr = $_.Split("|")
		$lineFile = [System.IO.File]::ReadAllBytes($strsDir + $lineArr[0])
		if ($lineArr[1] -eq "p") {$linePtr = [int]$lineArr[2]} else {$lineOffset = [int]$lineArr[2]}
		$lineDescr = $lineArr[3]
		if (-not $lineOffset) {
			$lineOffset = ([int]$lineFile[$linePtr+1] -shl 8)+[int]$lineFile[$linePtr]
		}
		if ($lineArr[0] -eq "CRUISER.COM") {$lineOffset -= 0x100}
		$lineBytes = ParseBytes $lineFile $lineOffset

		$linesObj += "" | Select @{N="fileName";E={$lineArr[0]}},
			@{N="ptrOffset";E={("{0:X4}" -f $linePtr)}},
			@{N="lineOffset";E={("{0:X4}" -f $lineOffset)}},newOffset,
			@{N="lineBytes";E={$lineBytes}},
			@{N="textString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString((ParseString $lineBytes))}},
			engTranslation
		
	}
	
	$linesObj | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$importFiles = $importArr | group Filename
	foreach ($importFile in $importFiles) {
		Write-Host "Processing file:" $importFile.Name
		$subFile = [System.IO.File]::ReadAllBytes($strsDir + $importFile.Name)
		if ($importFile.Name -eq "CRUISER.COM") {$subFile = [System.IO.File]::ReadAllBytes($compiledStrsDir + $importFile.Name)}
		$lines = $importFile.Group | Group lineOffset
		foreach ($line in $lines) {
			$linesTranslated = $line.Group | ? {$_.engTranslation}
			if ($linesTranslated) {
				$originalBytes = ($linesTranslated[0].lineBytes).Split(" ") | % {[byte]$_}
				$translatedBytes = StringToBytes $linesTranslated[0].engTranslation
				if ($linesTranslated[0].newOffset) {
					$translatedBytes += [byte]0
					$lineOffset = [convert]::toint32($linesTranslated[0].newOffset,16)
					0..($translatedBytes.Count -1) | % {$subFile[($lineOffset+$_)] = $translatedBytes[$_]}
					$ptrOffset = [convert]::toint32($linesTranslated[0].ptrOffset,16)
					if ($importFile.Name -eq "CRUISER.COM") {$lineOffset += 0x100}
					$subFile[$ptrOffset] = [byte]($lineOffset -band 0x00ff)
					$subFile[$ptrOffset+1] = [byte](($lineOffset -band 0xff00) -shr 8)
				} else {
					if ($translatedBytes.Count -le $originalBytes.Count) {
						$translatedBytes += [byte]0
						$lineOffset = [convert]::toint32($linesTranslated[0].lineOffset,16)
						0..($translatedBytes.Count -1) | % {$subFile[($lineOffset+$_)] = $translatedBytes[$_]}
					} else {
						Write-Warning ("In file " + ($linesTranslated[0].fileName) + " line 0x" + ($linesTranslated[0].lineOffset) + " is longer than original one by " + ($translatedBytes.Count - $originalBytes.Count) + " bytes! Skipping...")
					}
				}
			}
		}
		if ($importFile.Name -eq "SCSUB.BIN") {
			# Hack for saves display and save name length
			$subFile[0x5163] = 0x85
			$subFile[0x5164] = 0x4e
			$subFile[0x516a] = 0x85
			$subFile[0x516b] = 0x3f
			#$subFile[0x5102] = 0xbd # saves length in bars (and maybe somewhere else), not done! breakpoints 59a8:5100; 59a8:e387
			
			# Change for Status red markings line at 0x46bc (59a8:4410 - set colour variables)
			# Energy
			@(0x4413,0x4422) | % {
				$subFile[$_] = 0xd9
				$subFile[$_+1] = 0x46
			}
			# Shield
			@(0x4428,0x4436,0x4460,0x446b) | % {
				$subFile[$_] = 0xf1
				$subFile[$_+1] = 0x46
			}
			# Temperature
			@(0x443c,0x444b) | % {
				$subFile[$_] = 0x1a
				$subFile[$_+1] = 0x47
			}
			# Pressure
			@(0x4451) | % {
				$subFile[$_] = 0x32
				$subFile[$_+1] = 0x47
			}
			
			# Fix for price placement - ss:[048d] - current pos var
			$subFile[0xdd67] = 0x1b
			$subFile[0xe0de] = 0x24
			
			# Move save/load strings to right
			$subFile[0x5108] = 0x0a
			
			# Fix string length for saves at bars and other "clickable" locations.
			$subFile[0xe3a2] = 0xbd
		}
		if ($importFile.Name -eq "CMDSUB.BIN") {
			# Hack for options name length
			$subFile[0x0229] = 0x1d
		}
		[System.IO.File]::WriteAllBytes(($compiledStrsDir + $importFile.Name),$subFile)
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds