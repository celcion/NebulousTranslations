Write-Host
Write-Host "Parse-Ending"
$mode = "import" # export, import

$mainPath = "D:\Translations\SC2\"
$strsDir = $mainPath + "HDI_FilesExport\"
$compiledStrsDir = $mainPath + "HDI_FilesImport\"
$exportCsvFile = $mainPath + "SCRIPT_Export\endingExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\endingImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

if ($mode -eq "export") {
	$endingExport = @()
	$endingFile = [System.IO.File]::ReadAllBytes($strsDir + "ENDING.BIN")
	$endingLinesOffset = 0x2012
	$endingNamesOffset = 0x2145
	
	$endingNamesList = @{}
	$currentNamesOffset = $endingNamesOffset
	while ($endingFile[$currentNamesOffset]) {
		$currentOffset = $currentNamesOffset
		$currentName = ""
		while ($endingFile[$currentNamesOffset]) {$currentName += [char]$endingFile[$currentNamesOffset]; $currentNamesOffset++}
		$endingNamesList[$currentOffset] = $currentName
		$currentNamesOffset++
	}
	
	$currentLineOffset = $endingLinesOffset
	while ($endingFile[$currentLineOffset]) {
		$firstByte = $endingFile[$currentLineOffset]
		$currentLineOffset++
		$lineTypeByte = $endingFile[$currentLineOffset]
		$currentLineOffset++
		$lineType = ""
		$line = ""
		$color = $null
		if ($lineTypeByte -eq 1) {
			$lineType = "linkedName"
			$linkNum = ([int]$endingFile[$currentLineOffset+1] -shl 8) + [int]$endingFile[$currentLineOffset]
			$line = $endingNamesList[$linkNum]
			$currentLineOffset += 2
		} elseif ($lineTypeByte -eq 2) {
			$lineType = "textLine"
			$color = $endingFile[$currentLineOffset]
			$currentLineOffset++
			while ($endingFile[$currentLineOffset] -gt 0x10) {$line += [char]$endingFile[$currentLineOffset]; $currentLineOffset++}
		} elseif ($lineTypeByte -eq 0x0b) {
			$lineType = "finishingLine"
			while ($endingFile[$currentLineOffset] -gt 0x10) {$line += [char]$endingFile[$currentLineOffset]; $currentLineOffset++}
		} else {
			break
		}
		$endingExport += "" | Select @{N="lineFirstByte";E={$firstByte}},
					@{N="lineTypeByte";E={$lineTypeByte}},
					@{N="lineColorByte";E={$color}},
					@{N="lineType";E={$lineType}},
					@{N="lineText";E={$line}}
		$endingExport | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
	}
} elseif ($mode -eq "import") {
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$endingFile = [System.IO.File]::ReadAllBytes($strsDir + "ENDING.BIN")
	
	$endingNamesBlockStart = 0x6900
	$endingNamesBlockCurrent = $endingNamesBlockStart
	$endingNamesList = $importArr | ? {$_.lineType -eq "linkedName"} | % {$_.lineText} | Select -unique
	$endingNamesDict = @{}
	$endingNamesArr = @()
	0..($endingNamesList.Count-1) | % {
		$endingNamesDict[$endingNamesList[$_]] = $endingNamesBlockCurrent
		$endingNamesArr += [System.Text.Encoding]::ASCII.GetBytes($endingNamesList[$_])
		$endingNamesArr += [byte]0
		$endingNamesBlockCurrent += $endingNamesList[$_].Length + 1
	}
	$endingBlock = @()
	foreach ($endingLine in $importArr) {
		$endingBlock += [byte]$endingLine.lineFirstByte
		$endingBlock += [byte]$endingLine.lineTypeByte
		if ($endingLine.lineTypeByte -eq 1) {
			$link = $endingNamesDict[$endingLine.lineText]
			$endingBlock += [byte]($link -band 0x00ff)
			$endingBlock += [byte](($link -band 0xff00) -shr 8)
		} elseif ($endingLine.lineTypeByte -eq 2) {
			$endingBlock += [byte]$endingLine.lineColorByte
			$endingBlock += [System.Text.Encoding]::ASCII.GetBytes($endingLine.lineText)
		} else {
			$endingBlock += [System.Text.Encoding]::ASCII.GetBytes($endingLine.lineText)
		}
	}
	$endingBlock += [byte]0x0d
	$endingBlock += [System.Text.Encoding]::ASCII.GetBytes("2017 Nebulous Translations")
	$endingBlock += [byte]0x0b
	$endingBlock += [byte]0
	
	0..($endingBlock.Count-1) | % {$endingFile[0x2012+$_] = $endingBlock[$_]}
	0..($endingNamesArr.Count-1) | % {$endingFile[0x6900+$_] = $endingNamesArr[$_]}
	
	[System.IO.File]::WriteAllBytes(($compiledStrsDir + "ENDING.BIN"),$endingFile)

} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
