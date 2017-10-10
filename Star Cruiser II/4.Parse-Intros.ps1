Write-Host
Write-Host "Parse-IntroFiles"
$mode = "import" # export, import

$mainPath = "D:\Translations\SC2\"
$strsDir = $mainPath + "HDI_FilesExport\"
$compiledStrsDir = $mainPath + "HDI_FilesImport\"
$exportCsvFile = $mainPath + "SCRIPT_Export\introsExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\introsImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

#******************************************************
#"DEMOSUB.BIN|0x17d2-0x2801"
$intros = @("OPENING.BIN|0x30e7-0x33ff",
			"OPENING.BIN|0x3410-0x35f0",
			"OPENING.BIN|0x364b-0x37f0",
			"DEMOSUB.BIN|0x17d2-0x18de",
			"DEMOSUB.BIN|0x18e5-0x1ab1",
			"DEMOSUB.BIN|0x1abc-0x1c3b",
			"DEMOSUB.BIN|0x1c43-0x1dcd",
			"DEMOSUB.BIN|0x1dde-0x1f88",
			"DEMOSUB.BIN|0x1f8d-0x2165",
			"DEMOSUB.BIN|0x216a-0x2214",
			"DEMOSUB.BIN|0x2219-0x22a1",
			"DEMOSUB.BIN|0x22a6-0x2377",
			"DEMOSUB.BIN|0x237c-0x23f4",
			"DEMOSUB.BIN|0x23f9-0x2495",
			"DEMOSUB.BIN|0x249b-0x24f6",
			"DEMOSUB.BIN|0x24fb-0x2539",
			"DEMOSUB.BIN|0x253f-0x26c7",
			"DEMOSUB.BIN|0x26de-0x280b")

function StringToBytes ($string) {
	$stringBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($string)
	$resultArr = New-Object System.Collections.Generic.List[System.Object]
	$pos = 0
	while ($pos -le $stringBytes.count-1) {
		if ($stringBytes[$pos] -eq 91 -and $stringBytes[$pos+3] -eq 93) {
			$resultArr.Add([byte]([Convert]::ToInt32(([char]$stringBytes[$pos+1] + [char]$stringBytes[$pos+2]),16)))
			$pos += 3
		} else {
			$byte = $stringBytes[$pos]+0x61
			if ($byte -ge 0xc1) {$byte++}
			$resultArr.Add($byte)
		}
		$pos++
	}
	$resultArr
}

if ($mode -eq "export") {
	$introsExport = @()
	foreach ($intro in $intros) {
		$introFile = [System.IO.File]::ReadAllBytes($strsDir + $intro.Split("|")[0])
		$introStartOffset = [int]($intro.Split("|")[1].Split("-")[0])
		$introStopOffset = [int]($intro.Split("|")[1].Split("-")[1])
		
		$currentOffset = $introStartOffset
		$bytesStr = @()
		$textStr = ""
		while ($currentOffset -le $introStopOffset) {
			if ($introFile[$currentOffset] -lt 0x80) {
				if ($introFile[$currentOffset] -le 0x10) {
					switch ($introFile[$currentOffset]) {
						0x0 {$bytesStr += [byte]0;$textStr += "[00]"}
						0x1 {0..2 | % {$bytesStr += $introFile[$currentOffset+$_];$textStr += ("[" + ("{0:X2}" -f $introFile[$currentOffset+$_]) + "]")};$currentOffset += 2}
						0x2 {$bytesStr += [byte]0x2;$textStr += "[02]"}
						0x3 {$bytesStr += [byte]0x3;$textStr += "[03]"}
						0x4 {$bytesStr += [byte]0x4;$textStr += "[04]"}
						0x6 {$bytesStr += [byte]0x6;$textStr += "[06]"}
						0x7 {0..2 | % {$bytesStr += $introFile[$currentOffset+$_];$textStr += ("[" + ("{0:X2}" -f $introFile[$currentOffset+$_]) + "]")};$currentOffset += 2}
						0x8 {$bytesStr += [byte]0x8;$textStr += "[08]"}
						0x9 {0..1 | % {$bytesStr += $introFile[$currentOffset+$_];$textStr += ("[" + ("{0:X2}" -f $introFile[$currentOffset+$_]) + "]")};$currentOffset++}
						0xa {$bytesStr += [byte]0xa;$textStr += "[0A]"}
						0xb {$bytesStr += [byte]0xb;$textStr += "[0B]"}
						0x10 {$bytesStr += [byte]0x10;$textStr += "[10]"}
						default {Write-Warning ("Unknown character " + $introFile[$currentOffset] + " at " + ("{0:X4}" -f $currentOffset));exit}
					}
				} else {
					$bytesStr += $introFile[$currentOffset]
					$textStr += ("[" + ("{0:X2}" -f $introFile[$currentOffset]) + "]")
				}
				$currentOffset++
			} else {
				$bytesStr += $introFile[$currentOffset]
				$bytesStr += $introFile[$currentOffset+1]
				$textStr += [System.Text.Encoding]::GetEncoding("shift-jis").GetString(@($introFile[$currentOffset],$introFile[$currentOffset+1]))
				$currentOffset += 2
			}
		}
		$introsExport += "" | Select @{N="introFile";E={$intro.Split("|")[0]}},
					@{N="introOffset";E={"{0:X8}" -f $introStartOffset}},
					@{N="introBytes";E={$bytesStr}},
					@{N="introByteCount";E={$introStopOffset - $introStartOffset + 1}},
					@{N="introString";E={$textStr}},
					engTranslation
		
	}
	$introsExport | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$introFiles = $importArr | group introFile
	foreach ($intro in $introFiles) {
		Write-Host "Processing file" $intro.Name
		if ($intro.Name -eq "OPENING.BIN") {
			#$introFilePath = $strsDir + $intro.Name
			$patchCodeOffsets = @(0x2f37,0x2f90,0x3000)
		} else {
			#$introFilePath = $compiledStrsDir + $intro.Name
			$patchCodeOffsets = @(0x056e,0x05c7,0x062d)
		}
		
		$introFile = [System.IO.File]::ReadAllBytes($strsDir + $intro.Name)
		foreach ($introLine in $intro.Group) {
			$introLineBytes = StringToBytes $introLine.engTranslation
			if ($introLineBytes.Count -le $introLine.introByteCount) {
				$importOffset = [convert]::toint32($introLine.introOffset, 16)
				0..($introLineBytes.Count -1) | % {$introFile[$importOffset+$_] = $introLineBytes[$_]}
			} else {
				Write-Warning ("Line at file " + $intro.Name + " and " + $introLine.introOffset + " is too long! Need to cut " + ($introLineBytes.Count - $introLine.introByteCount) + " bytes. Skipping...")
			}
		}
		
		$injectedCode = @(0x75,0x01,0x43,0x3c,0x10,0x73,0x01,0xc3,0x43,0x3c,0x80,0x73,0x09,0x32,0xe4,0x2d,0x0f,0x00,0x03,0xf8,0xeb,0xe6,0xb4,0x85)
		0..($injectedCode.Count -1) | % {$introFile[$patchCodeOffsets[0]+$_] = $injectedCode[$_]}
		
		$injectedCode = @(0x83,0xc7,0x01)
		0..($injectedCode.Count -1) | % {$introFile[$patchCodeOffsets[1]+$_] = $injectedCode[$_]}
		
		$injectedCode = @(0x2c,0x42)
		0..($injectedCode.Count -1) | % {$introFile[$patchCodeOffsets[2]+$_] = $injectedCode[$_]}
		
		[System.IO.File]::WriteAllBytes(($compiledStrsDir + $intro.Name),$introFile)
	}
} else {exit}

<#
$injectedCode = @(0x1f,0x07,0x5f,0x59,0x5b,0x58,0x3c,0x85,0x74,0x04,0x80,0x46,0x08,0x01,0x80,0x46,0x08,0x01,0xc3)
0..($injectedCode.Count -1) | % {$comFile[0xfd51+$_] = $injectedCode[$_]}
#>

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
