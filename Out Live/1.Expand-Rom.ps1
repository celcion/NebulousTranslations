cls
Write-Host
Write-Host "Expand Rom"

$mainPath = "D:\Translations\OutLive\"
$originalRomPath = $mainPath + "ROM_Original\Out Live - It's Far a Future on Planet (J).pce"
$patchedRomPath = $mainPath + "ROM_Patched\Out Live - It's Far a Future on Planet (WIP).pce"

$bytesToAdd = 40960

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$file = [System.IO.File]::ReadAllBytes($originalRomPath)
$file += [Byte[]] (,0xFF * $bytesToAdd)

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
