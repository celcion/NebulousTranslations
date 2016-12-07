Write-Host
Write-Host "Import-Fonts"

$mainPath = "D:\Translations\OutLive\"
$originalRomPath = $mainPath + "ROM_Original\Out Live - It's Far a Future on Planet (J).pce"
$patchedRomPath = $mainPath + "ROM_Patched\Out Live - It's Far a Future on Planet (WIP).pce"
$bitmapPackedFile = $mainPath + "GFX\fonts-import.bin"

$importOffset = 33280

$file = [System.IO.File]::ReadAllBytes($patchedRomPath)
$bytes = [System.IO.File]::ReadAllBytes($bitmapPackedFile)

while ($bytes.Count -le 3500) {$bytes += [byte]255}

0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
