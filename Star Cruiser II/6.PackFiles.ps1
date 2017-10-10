Write-Host
Write-Host "Pack-Files"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

Import-Module .\Tools\DiscUtils\DiscUtils.psd1
New-PSDrive hdi -PSProvider VirtualDisk -Root ".\HDI_Patched\Star Cruiser II.hdi" -ReadWrite | out-null

$gameFolder = "hdi:\Volume0\CRUISER2"
$importFolder = (Get-Item .\HDI_FilesImport)
foreach ($file in (ls .\HDI_FilesImport\ -Recurse -File)) {
	$filePath = ($file.FullName).Replace($importFolder,"")
	#($gameFolder + $filePath)
	del ($gameFolder + $filePath)
	$newFile = [System.IO.File]::ReadAllBytes($file.FullName)
	New-Item ($gameFolder + $filePath) -Type File
	Set-Content -Value $newFile -Encoding Byte -Path ($gameFolder + $filePath)
}

Remove-PSDrive hdi

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
