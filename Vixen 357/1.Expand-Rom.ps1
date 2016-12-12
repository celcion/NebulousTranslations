cls
Write-Host
Write-Host "Expand-Rom"
$mainPath = "D:\Translations\Vixen357\"
$originalRomPath = $mainPath + "ROM_Original\Vixen 357 (Japan).md"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"

$bytesToAdd = 262144
$romEndPtr = 420

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$file = [System.IO.File]::ReadAllBytes($originalRomPath)
$file += [Byte[]] (,0xFF * $bytesToAdd)

$file[$romEndPtr] = [byte](($file.count -band 0xff000000) -shr 24)
$file[$romEndPtr+1] = [byte](($file.count -band 0x00ff0000) -shr 16)
$file[$romEndPtr+2] = [byte](($file.count -band 0x0000ff00) -shr 8)
$file[$romEndPtr+3] = [byte]($file.count -band 0x000000ff)

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
