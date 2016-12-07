Add-Type -AssemblyName System.Windows.Forms

$form = New-Object Windows.Forms.Form

$form.Size = New-Object Drawing.Size @(800,600)
$form.FormBorderStyle = "FixedToolWindow"

$form.StartPosition = "CenterScreen"

$labelROM = New-Object System.Windows.Forms.Label
$loadROMButton = New-Object System.Windows.Forms.Button
$labelFile = New-Object System.Windows.Forms.Label
$loadFileButton = New-Object System.Windows.Forms.Button
$checkBoxDefense = New-Object System.Windows.Forms.CheckBox
$saveButton = New-Object System.Windows.Forms.Button
$OpenROMDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

$Script:romFile = @()

function checkValue ($number, $double) {
	if ($double) {
		if ($number -gt 0xffff) {
			#return 0xffff
			return @(0xff,0xff)
		} else {
			$arr = @()
			$arr += $number -band 0x00ff
			$arr += ($number -band 0xff00) -shr 8
			return $arr
		}
	} else {
		if ($number -gt 0xff) {return 0xff} else {return $number}
	}
}

$loadROM_click={
	$OpenROMDialog.ShowDialog() | Out-Null
	if ($OpenROMDialog.filename) {
		$Script:romFile = [System.IO.File]::ReadAllBytes($OpenROMDialog.filename)
		if (-not $romFile.Count) {[System.Windows.Forms.MessageBox]::Show("ROM cannot be read!" , "Error!")}
	} else {
		[System.Windows.Forms.MessageBox]::Show("ROM is not selected!" , "Warning")
	}
}

$loadStats_click={
	$OpenFileDialog.ShowDialog() | Out-Null
	if ($OpenFileDialog.filename) {
		$statsFile = Import-Csv -Encoding Unicode -Delimiter "`t" $OpenFileDialog.filename
		if (-not $statsFile.Count) {
			[System.Windows.Forms.MessageBox]::Show("Stats file is not open or cannot be read!" , "Error!")
		} else {
			$statData = New-Object System.Collections.ArrayList
			$statData.AddRange( $statsFile )
			$dataGrid.DataSource = $statData
			$dataGrid.AutoResizeColumns( "AllCells" )
			$dataGrid.Columns[0].ReadOnly = $true
			$dataGrid.Columns[1].ReadOnly = $true
			$dataGrid.Refresh()
		}
	} else {
		[System.Windows.Forms.MessageBox]::Show("Stats file is not selected!" , "Warning")
	}
}

$saveFile_click={
	if ($Script:romFile.Count -and ($dataGrid.Rows).Count){
		$currentData = $dataGrid.Rows | % {$_.DataBoundItem} | Sort-Object @{E={([int]$_.id)}}
		$tableAddress = 0x1b860
		$insertData = @()
		if ($checkBoxDefense.Checked) {
			$Script:romFile[0x1af6] = 0xea
		} else {
			$Script:romFile[0x1af6] = 0x6a
		}
		foreach ($currentEnemy in $currentData) {
			$patchedData = @()
			$patchedData += checkValue ([int]($currentEnemy.enemyHP)) $true
			
			$attackLv = [int]($currentEnemy.attackLv)
			if ($attackLv -gt 50) {$attackLv = 50}
			$patchedData += $attackLv
			$defenseLv = [int]($currentEnemy.defenseLv)
			if ($defenseLv -gt 50) {$defenseLv = 50}
			$patchedData += $defenseLv
			
			$patchedData += checkValue ([int]($currentEnemy.unk1)) $true
			$patchedData += checkValue ([int]($currentEnemy.attackEXP)) $true
			$patchedData += checkValue ([int]($currentEnemy.targetPoints)) $true
			$patchedData += checkValue ([int]($currentEnemy.unk2)) $false
			$patchedData += checkValue ([int]($currentEnemy.unk3)) $false
			
			$insertData += $patchedData
			#Write-Host $patchedData
		}
		0..($insertData.Count-1) | % {$Script:romFile[$tableAddress+$_] = $insertData[$_]}
		[System.IO.File]::WriteAllBytes($OpenROMDialog.filename,$Script:romFile)
		$currentData | Export-Csv -Encoding Unicode -Delimiter "`t" -NoTypeInformation $OpenFileDialog.filename
	} else {
		[System.Windows.Forms.MessageBox]::Show("ROM or stats file wasn't loaded!" , "Warning")
	}
}

$labelROM.Text = "Load ROM file"
$labelROM.Location = '5, 5'
$labelROM.Size = '100, 23'
$labelROM.Font = "Microsoft Sans Serif, 8pt, style=Bold" 

$loadROMButton.add_click($loadROM_click)
$loadROMButton.Location = '5, 35'
$loadROMButton.Text = "Load ROM"


$labelFile.Text = "Load Stats file"
$labelFile.Location = '135, 5'
$labelFile.Size = '100, 23'
$labelFile.Font = "Microsoft Sans Serif, 8pt, style=Bold" 


$loadFileButton.add_click($loadStats_click)
$loadFileButton.Location = '135, 35'
$loadFileButton.Text = "Load File"


$checkBoxDefense.Location = '290, 35'
$checkBoxDefense.Size = '200, 23'
$checkBoxDefense.Text = "Double Defense EXP Gain"

$saveButton.add_click($saveFile_click)
$saveButton.Location = '700, 25'
$saveButton.Text = "Save"

$OpenROMDialog.initialDirectory = (Get-Location).Path
$OpenROMDialog.filter = "OutLive ROM (*.pce)| *.pce"


$OpenFileDialog.initialDirectory = (Get-Location).Path
$OpenFileDialog.filter = "OutLive Stats file (*.csv)| *.csv"

$dataGrid = New-Object System.Windows.Forms.DataGridView 
$dataGrid.Location = '5, 70'
$dataGrid.Size = '774, 480'
$dataGrid.AllowUserToAddRows = $False
$dataGrid.AllowUserToDeleteRows = $False 
#$dataGrid.ReadOnly = $True
$dataGrid.ColumnHeadersHeightSizeMode = 'AutoSize'
$dataGrid.Visible = $true


$form.Controls.Add($labelROM)
$form.Controls.Add($loadROMButton)
$form.Controls.Add($labelFile)
$form.Controls.Add($loadFileButton)
$form.Controls.Add($checkBoxDefense)
$form.Controls.Add($saveButton)
$form.Controls.Add($dataGrid)

$drc = $form.ShowDialog()

