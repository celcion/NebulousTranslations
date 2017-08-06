Write-Host
Write-Host "Parse-MesFiles"
$mode = "import" # export, import

$mainPath = "D:\Translations\Macross\"
$mesFilesPath = $mainPath + "HDI_Unpack\SKULL_CD\BIN\"
$compiledBinsDir = $mainPath + "HDI_FilesImport\BIN\"
$exportCsvFile = $mainPath + "SCRIPT_Export\mesExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\mesImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

if ($mode -eq "export") {
	$mesFiles = ls ($mesFilesPath + "*_MES.BIN")
	$mesStringsArr = @()
	foreach ($mesFile in $mesFiles) {
		$mesFileData = [System.IO.File]::ReadAllBytes($mesFile)
		$mesCount = $mesFileData[0] / 2
		0..($mesCount-1) | % {
			$mesOffset = (([int]$mesFileData[($_*2)+1]) -shl 8)+[int]$mesFileData[$_*2]
			#$mesFileData[$_*2]
			#"{0:X4}" -f $mesOffset
			$currentMesOffset = $mesOffset
			$mesStringsCount = $mesFileData[$mesOffset]
			$currentMesOffset++
			$mesString = @()
			1..$mesStringsCount | % {
				while ($mesFileData[$currentMesOffset]) {
					$mesString += $mesFileData[$currentMesOffset]
					$currentMesOffset++
				}
				$mesString += [byte]0
				$currentMesOffset++
			}
			$mesStringsArr += "" | Select @{N="mesFile";E={$mesFile.Name}},
					@{N="mesOffset";E={("{0:X4}" -f $mesOffset)}},
					@{N="mesBytes";E={$mesString}},
					@{N="mesLines";E={$mesStringsCount}},
					@{N="mesString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($mesString).Replace(([char]0),"`n").TrimEnd("`n")}},
					engTranslation
		}
	}
	$mesStringsArr | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$mesFiles = $importArr | group mesFile
	foreach ($mesFile in $mesFiles) {
		$originalMesFile = [System.IO.File]::ReadAllBytes(($mesFilesPath + $mesFile.Name))
		$newMesPtrs = @()
		$newMesBytes = @()
		$mesBytesOffset = $mesFile.Group.Count * 2
		foreach ($mesLine in $mesFile.Group) {
			$newMesPtrs += [byte]($mesBytesOffset -band 0x00ff)
			$newMesPtrs += [byte](($mesBytesOffset -band 0xff00) -shr 8)
			if ($mesLine.engTranslation) {
				$mesArr = ($mesLine.engTranslation).Split("`n")
				$mesLines = $mesArr.Count
				$mesLineBytes = @()
				$mesLineBytes += [byte]$mesLines
				$mesArr | % {
					$mesTmpLine = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($_.Trim())
					if ($mesTmpLine.Count -gt 40) {Write-Warning ("Line " + $_ +" is too long! Exiting..."); exit}
					$mesLineBytes += $mesTmpLine
					$mesLineBytes += [byte]0
				}
			} else {
				$mesLines = $mesLine.mesLines
				$mesLineBytes = @()
				$mesLineBytes += [byte]$mesLines
				$mesLineBytes += ($mesLine.mesBytes).Split(" ") | % {[byte]$_}
			}
			#$mesLines
			#$mesLineBytes -join " "
			$newMesBytes += $mesLineBytes
			$mesBytesOffset += $mesLineBytes.Count
		}
		$newMesFile = $newMesPtrs + $newMesBytes
		if ($newMesFile.Count -le $originalMesFile.Count) {
			[System.IO.File]::WriteAllBytes(($compiledBinsDir + $mesFile.Name),$newMesFile)
		} else {Write-Warning ("File " + $mesFile.Name + " are larger than original, skipping!")}
	}
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
