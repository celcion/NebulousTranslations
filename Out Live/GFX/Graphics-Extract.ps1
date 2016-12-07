$mainPath = "D:\Translations\OutLive\"
$bitmapExport = $mainPath + "GFX\fonts-export.bmp"
$originalRomPath = $mainPath + "ROM_Original\Out Live - It's Far a Future on Planet (J).pce"

$file = [System.IO.File]::ReadAllBytes($originalRomPath)
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
$bmp = New-Object System.Drawing.Bitmap(576, 128)

$start = 33280
$end = 36784
#$end = 33343
$currentOffset = $start
$xPixel = 0
$yPixel = 0

function DrawTile ($charByte, $localX, $localY, $bitmap){
	7..0 | %{
		$mask = 1 -shl $_
		if ($charByte -band $mask) {$bitmap.SetPixel($localX, $localY, 'White')} else {$bitmap.SetPixel($localX, $localY, 'Black')}
		$localX++
	}
}

$lines = 0
$chars= 0
$layer = 0

while ($currentOffset -le $end) {
	$bytes = @()
	if ($layer -gt 3) {$layer = 0;$chars++}
	if ($chars -gt 15) {$xPixel = 0;$yPixel +=8;$chars = 0;$lines++}
	$xPixel = ($chars*8) + ($layer*144)
	$yPixel = ($lines * 8)
	$control = $file[$currentOffset]
	$rotate = $control -band 128
	$currentOffset++
	if ($rotate) {
		$tile = New-Object System.Drawing.Bitmap(8, 8)
		$tileX = 0
		$tileY = 0
	}
	7..0 | % {
		$mask = 1 -shl $_
		if (($control -band $mask) -and ($_ -lt 7)) {$currentOffset++}
		if ($rotate) {
			DrawTile $file[$currentOffset] $tileX $tileY $tile
			$tileY++
		} else {
			DrawTile $file[$currentOffset] $xPixel $yPixel $bmp
			$yPixel++
		}
	}
	if ($tile) {
		$tile.RotateFlip("Rotate90FlipX")
		$tileX = 0
		$tileY = 0
		0..7 | % {
			$str = ""
			0..7 | % {
				if ($tile.GetPixel($tileX,$tileY).R) {$bmp.SetPixel($xPixel, $yPixel, "White")} else {$bmp.SetPixel($xPixel, $yPixel, "Black")}
				$xPixel++
				$tileX++
			}
			$tileX -= 8
			$xPixel -= 8
			$yPixel++
			$tileY++
		}
		$yPixel -= 8
	}
	$layer++
	$currentOffset++
	$tile = $nothing
}

$bmp.Save($bitmapExport)
Remove-Variable bmp
