$mainPath = "D:\Translations\OutLive\"
$bitmapImport = $mainPath + "GFX\fonts-import.bmp"
$bitmapPackedFile = $mainPath + "GFX\fonts-import.bin"
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
$tile = New-Object System.Drawing.Bitmap($bitmapImport)

$maxLines = 16

$bytes = @()

for ($lines = 0; $lines -lt $maxLines; $lines++) {
	for ($chars = 0; $chars -le 15; $chars++) {
		for ($layer = 0; $layer -le 3; $layer++) {
			$tileControl = ""
			$previousLine = "a"
			$tileX = ($chars*8) + ($layer*144)
			$tileY = ($lines * 8)
			$tileCurrent = @()
			0..7 | % {
				$lineBin = [byte]0
				0..7 | % {
					if ($tile.GetPixel($tileX,$tileY).R) {
						$lineBin = ($lineBin -shl 1) + 1
					} else {
						$lineBin = ($lineBin -shl 1)
					}
					$tileX++
				}
				if ($lineBin -ne $previousLine -and $_) {
					$tileControl = ($tileControl -shl 1) + 1
					$tileCurrent += $lineBin
				} else {
					$tileControl = ($tileControl -shl 1)
				}
				if (-not $_) {$tileCurrent += $lineBin}
				$previousLine = $lineBin
				$tileX -= 8
				$tileY++
			}
			if (-not $tileCurrent) {$tileCurrent = $previousLine}
			$bytes += $tileControl
			$bytes += $tileCurrent
		}
	}
}

Remove-Variable tile
[System.IO.File]::WriteAllBytes($bitmapPackedFile,$bytes)
