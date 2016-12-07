Write-Host
Write-Host "MemoryArrays-Parse"
$mode = "import" # export, import

$mainPath = "D:\Translations\OutLive\"
$exportTblFile = $mainPath + "TBLs\sjis_outlive.tbl"
$importTblFile = $mainPath + "TBLs\eng_outlive.tbl"
$originalRomPath = $mainPath + "ROM_Original\Out Live - It's Far a Future on Planet (J).pce"
$patchedRomPath = $mainPath + "ROM_Patched\Out Live - It's Far a Future on Planet (WIP).pce"
$exportCsvFile = $mainPath + "SCRIPT_Export\memoryarrays_export.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\memoryarrays_import.csv"
$headerSize = 512
$importOffset = 295424

$dataStrings = @(213299,213355,213418,213462,197148,197402,197587,149575,149364,98885,98910,115200,115245,115315)
# 149575 -> 59A0 - Status
# 149364 -> 5BF8 - Armor Class
# 98885  -> 4264 - Enemy found
# 98910  -> 4283 - Danger!

$stopWatch = [system.diagnostics.stopwatch]::startNew()
if ($mode -eq "export") {$file = [System.IO.File]::ReadAllBytes($originalRomPath)} else {$file = [System.IO.File]::ReadAllBytes($patchedRomPath)}
$tblFile = [System.IO.File]::ReadAllBytes($exportTblFile)
$exportTbl = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $exportTbl[([convert]::ToInt32($tmp[0].Trim(),16))] = $tmp[1].Replace("`r","")}
$tblFile = [System.IO.File]::ReadAllBytes($importTblFile)
$importTbl = New-Object Collections.Hashtable ([StringComparer]::CurrentCulture)
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $importTbl[($tmp[1].Replace("`r",""))] = ([convert]::ToInt32($tmp[0],16))}

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

if ($mode -eq "export") {
	$strings = @()
	foreach ($dataString in $dataStrings) {
		$currentOffset = $dataString
		$bytes = @()
		$text = ""
		while ($file[$currentOffset] -ne 255) {
			$txtBytes = @() 
			0..2 | % {$text += ("["+("{0:X2}" -f $file[$currentOffset])+"]"); $bytes += $file[$currentOffset]; $currentOffset++}
			1..$bytes[($bytes.Count -1)] | % {$txtBytes += $file[$currentOffset]; $bytes += $file[$currentOffset]; $currentOffset++}
			$text += BytesToString $txtBytes
		}
		$string += [byte]255
		$text += "[FF]"
		$strings += "" | Select @{N="strOffset";E={("{0:X8}" -f $dataString)}},ptrOffset,
			@{N="romBytes";E={-join ($bytes | % {"{0:X2}" -f $_})}},
			@{N="romData";E={$bytes}},
			@{N="resolvedString";E={$text}},
			engTranslation
	}
	$strings | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$strings = @()
	$ptr = 16384
	foreach ($importString in $importArr) {
		#$importOffset = [convert]::toint32($importString.importOffset,16)
		if ($importString.engTranslation) {
			$strBytes = StringToBytes $importString.engTranslation
		} else {
			$strBytes = ($importString.romData).Split(" ") | % {[byte]$_}
		}
		if ($strBytes.count -le 256) {
			$strings += $strBytes
			if ($importString.ptrOffset) {
				($importString.ptrOffset).Split(",") | % {
					$ptrOffset = [convert]::toint32($_,16)
					$file[$ptrOffset] = [byte]($ptr -band 0x00ff)
					$file[$ptrOffset+1] = [byte](($ptr -band 0xff00) -shr 8)
				}
			}
		} else {
			Write-Warning ("String at " + $importString.importOffset + " is too long! Won't be inserted!")
		}
		$ptr += $strBytes.Count
	}
	0..($strings.count-1) | % {$file[$_+$importOffset] = $strings[$_]}
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
