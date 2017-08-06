Write-Host
Write-Host "Parse-MacData"
$mode = "import" # export, import

$mainPath = "D:\Translations\Macross\"
$dataFilePath = $mainPath + "HDI_Unpack\SKULL_CD\BIN\MAC_DATA.BIN"
$compiledBinsDir = $mainPath + "HDI_FilesImport\"
$exportCsvFile = $mainPath + "SCRIPT_Export\macExport.csv"
$importCsvFile = $mainPath + "SCRIPT_Import\macImport.csv"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

if ($mode -eq "export") {
	$dataFile = [System.IO.File]::ReadAllBytes($dataFilePath)
	$macDataArr = @()

	0..17 | % {
		$arrAll = @()
		$start = $_ * 9 + 0x0c
		0..8 | % {$arrAll += $dataFile[$_+$start]}
		$macDataArr += "" | Select @{N="macOffset";E={("{0:X8}" -f $start)}},
					@{N="macType";E={"characterRanks"}},
					@{N="macBytes";E={$arrAll}},
					@{N="macBytesCount";E={$arrAll.Count}},
					@{N="macData";E={[byte]0}},
					@{N="macLettersCount";E={$arrAll.Count-1}},
					@{N="macString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($arrAll)}},
					engTranslation	
	}

	0..42 | % {
		$arrAll = @()
		$arrText = @()
		$arrData = @()
		$start = $_ * 39 + 0xae
		0..19 | % {$arrAll += $dataFile[$_+$start];$arrText += $dataFile[$_+$start]}
		20..38 | % {$arrAll += $dataFile[$_+$start];$arrData += $dataFile[$_+$start]}
		$macDataArr += "" | Select @{N="macOffset";E={("{0:X8}" -f $start)}},
					@{N="macType";E={"unitNames"}},
					@{N="macBytes";E={$arrAll}},
					@{N="macBytesCount";E={$arrAll.Count}},
					@{N="macData";E={$arrData}},
					@{N="macLettersCount";E={$arrText.Count}},
					@{N="macString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($arrText)}},
					engTranslation
	}
	
	0..77 | % {
		$arrAll = @()
		$arrText = @()
		$arrData = @()
		$start = $_ * 39 + 0x073b
		0..15 | % {$arrAll += $dataFile[$_+$start];$arrText += $dataFile[$_+$start]}
		16..38 | % {$arrAll += $dataFile[$_+$start];$arrData += $dataFile[$_+$start]}
		$macDataArr += "" | Select @{N="macOffset";E={("{0:X8}" -f $start)}},
					@{N="macType";E={"characterNames"}},
					@{N="macBytes";E={$arrAll}},
					@{N="macBytesCount";E={$arrAll.Count}},
					@{N="macData";E={$arrData}},
					@{N="macLettersCount";E={$arrText.Count}},
					@{N="macString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($arrText)}},
					engTranslation
	}
	
	0..130 | % {
		$arrAll = @()
		$arrText = @()
		$arrData = @()
		$start = $_ * 52 + 0x1d87
		0..37 | % {$arrAll += $dataFile[$_+$start];$arrText += $dataFile[$_+$start]}
		38..51 | % {$arrAll += $dataFile[$_+$start];$arrData += $dataFile[$_+$start]}
		$arrText[23] = 0x7c
		$macDataArr += "" | Select @{N="macOffset";E={("{0:X8}" -f $start)}},
					@{N="macType";E={"unitTypes"}},
					@{N="macBytes";E={$arrAll}},
					@{N="macBytesCount";E={$arrAll.Count}},
					@{N="macData";E={$arrData}},
					@{N="macLettersCount";E={$arrText.Count}},
					@{N="macString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($arrText)}},
					engTranslation
	}
	
	0..60 | % {
		$arrAll = @()
		$arrText = @()
		$arrData = @()
		$start = $_ * 29 + 0x3823
		0..19 | % {$arrAll += $dataFile[$_+$start];$arrText += $dataFile[$_+$start]}
		20..28 | % {$arrAll += $dataFile[$_+$start];$arrData += $dataFile[$_+$start]}
		$macDataArr += "" | Select @{N="macOffset";E={("{0:X8}" -f $start)}},
					@{N="macType";E={"weaponsData"}},
					@{N="macBytes";E={$arrAll}},
					@{N="macBytesCount";E={$arrAll.Count}},
					@{N="macData";E={$arrData}},
					@{N="macLettersCount";E={$arrText.Count}},
					@{N="macString";E={[System.Text.Encoding]::GetEncoding("shift-jis").GetString($arrText)}},
					engTranslation
	}
	
	$macDataArr | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $exportCsvFile
} elseif ($mode -eq "import") {
	$macFile = [System.IO.File]::ReadAllBytes($dataFilePath)
	$importArr = Import-Csv -Encoding Unicode -Delimiter "`t" $importCsvFile
	$importArr | ? {$_.engTranslation} | % {
		$macLine = $_.engTranslation
		$macLineOffset = [Convert]::ToInt32($_.macOffset, 16)
		if ($_.macType -eq "unitTypes") {
			$tmpArr = $macLine.Split("|")
			$unitName = $tmpArr[0].Trim()
			$unitType = $tmpArr[1].Trim()
			# 23 + 1 + 14
			while ($unitName.Length -lt 23) {$unitName += " "}
			while ($unitType.Length -lt 14) {$unitType += " "}
			$macImportBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($unitName)
			$macImportBytes += [byte]0
			$macImportBytes += [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($unitType)
		} else {
			while ($macLine.Length -lt $_.macLettersCount) {$macLine += " "}
			$macImportBytes = [System.Text.Encoding]::GetEncoding("shift-jis").GetBytes($macLine)
		}
		if ($macImportBytes.Count -ne $_.macLettersCount) {
			Write-Warning ("Wrong line length at " + ("{0:X8}" -f $macLineOffset) + " - " + $macImportBytes.Count)
		} else {
			0..($macImportBytes.Count -1) | % {$macFile[$macLineOffset+$_] = $macImportBytes[$_]}
		}
	}
	[System.IO.File]::WriteAllBytes(($compiledBinsDir + "BIN\MAC_DATA.BIN"),$macFile)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
