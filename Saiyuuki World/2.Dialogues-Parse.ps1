Write-Host
Write-Host "Dialogues-Parse"
$mode = "import" # export, import

. .\Common.ps1

$exportCsvFile = $exportPath + "dialogs_export.csv"
$importCsvFile = $importPath + "dialogs_import.csv"

$exportOffset = 0xde87
$exportShift = 0x4010
$lines = 213
$importPtrsOffset = $exportOffset
$importLinesStart = 0x1c010
$importAddressStart = 0x8000

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}

if ($mode -eq "export") {
	$strings = @()
	$currentOffset = $exportOffset
	1..$lines | % {
		$string = @()
		$strOffset = (([int]$file[$currentOffset+1] -shl 8) + [int]$file[$currentOffset]) + $exportShift
		$strPos = $strOffset
		$strHeader = $file[$strPos]
		$strPos++
		$strLength = $file[$strPos]
		$strPos++
		$extraHeader = @()
		if ($strHeader -eq 16 -or $strHeader -eq 48) {
			0..1 | % {
				$extraHeader += $file[$strPos]
				$strPos++
			}
		}
		$currentLength = 1
		while($currentLength -le $strLength){
			$string += $file[$strPos]
			$currentLength++
			$strPos++
		}
		$resString = BytesToString $string
		$strings += "" | Select @{N="ptrOffset";E={("{0:X8}" -f $currentOffset)}},
					@{N="strOffset";E={("{0:X8}" -f $strOffset)}},
					@{N="strHeader";E={$strHeader}},
					@{N="strLength";E={$strLength}},
					@{N="romBytes";E={-join ($string | % {"{0:X2}" -f $_})}},
					@{N="romData";E={$string}},
					@{N="extraHeader";E={$extraHeader}},
					@{N="resolvedString";E={$resString}},
					engTranslation
		$currentOffset += 2
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$ptrs = @()
	$strs = @()
	$currentStrOffset = $importAddressStart
	foreach ($importString in $importArr) {
		$string = @()
		if ($importString.engTranslation) {
			$strBytes = StringToBytes $importString.engTranslation
		} else {
			$strBytes = ($importString.romData).Split(" ") | % {[byte]$_}
		}
		$string += [byte]$importString.strHeader
		$string += [byte]($strBytes.Count)
		if ($importString.extraHeader) {
			$string += ($importString.extraHeader).Split(" ") | % {[byte]$_}
		}
		$string += $strBytes
		$strs += $string
		$ptrs += [byte]($currentStrOffset -band 0x00ff)
		$ptrs += [byte](($currentStrOffset -band 0xff00) -shr 8)
		$currentStrOffset += $string.Count
	}
	0..($ptrs.Count -1) | % {$file[$importPtrsOffset+$_] = $ptrs[$_]}
	0..($strs.Count -1) | % {$file[$importLinesStart+$_] = $strs[$_]}
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds