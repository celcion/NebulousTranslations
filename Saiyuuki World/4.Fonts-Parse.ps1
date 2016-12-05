Write-Host
Write-Host "Fonts-Parse"
$mode = "import" # export, import

. .\Common.ps1

$bitmapExport = $mainPath + "GFX\fonts-export.bmp"
$bitmapImport = $mainPath + "GFX\fonts-import.bmp"
$exportOffset = 0xdba6
$exportTiles = 5 * 16

$stopWatch = [system.diagnostics.stopwatch]::startNew()
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$file = [System.IO.File]::ReadAllBytes($patchedRomPath)

$currentTiles = 0
$currentOffset = $exportOffset
$currentTile = @()

if ($mode -eq "export") {
	$bmp = New-Object System.Drawing.Bitmap((16*8*2+1), (5*8))
	while ($currentTiles -lt $exportTiles) {
		$currentByte = $file[$currentOffset]
		if ($currentByte -eq 0xfa){
			$currentOffset++
			$count = $file[$currentOffset]
			$currentOffset++
			1..($count) | % {
				$currentTile += $file[$currentOffset]
				if ($currentTile.Count -eq 16) {
					DrawTile $currentTile $currentTiles
					$currentTile = @()
					$currentTiles++
				}
			}
		} else {
			$currentTile += $currentByte
			if ($currentTile.Count -eq 16) {
				DrawTile $currentTile $currentTiles
				$currentTile = @()
				$currentTiles++
			}
		}
		$currentOffset++
	}

	Write-Host "Read" ($currentOffset - $exportOffset) "bytes"
	$bmp.Save($bitmapExport)
	Remove-Variable bmp
} elseif ($mode -eq "import") {
	$tile = New-Object System.Drawing.Bitmap($bitmapImport)
	$rawBytes = @()
	$compressedBytes = @()
	while ($currentTiles -lt $exportTiles) {
		$localX = ($currentTiles % 16) * 8
		$localY = ([math]::floor($currentTiles / 16)) * 8
		0..15 | % {
			$tileX = $localX
			$tileY = $localY+$_
			if ($_ -gt 7) {$tileX += 129;$tileY -= 8}
			$lineBin = [byte]0
			0..7 | % {
				if ($tile.GetPixel($tileX,$tileY).R) {
					$lineBin = ($lineBin -shl 1)
				} else {
					$lineBin = ($lineBin -shl 1) + 1
				}
				$tileX++
			}
			$rawBytes += $lineBin
		}
		$currentTiles++
	}
	$tmpBytes = @()
	foreach ($gfxByte in $rawBytes) {
		if (-not $tmpBytes) {
			$tmpBytes += $gfxByte
		} else {
			if ($gfxByte -eq $tmpBytes[$tmpBytes.Count-1]) {
				$tmpBytes += $gfxByte
			} else {
				if ($tmpBytes.Count -gt 3) {
					$compressedBytes += 0xfa
					$compressedBytes += [byte]$tmpBytes.Count
					$compressedBytes += $tmpBytes[0]
				} else {
					$compressedBytes += $tmpBytes
				}
				$tmpBytes = @()
				$tmpBytes += $gfxByte
			}
		}
	}
	$compressedBytes += $tmpBytes
	Write-Host "Compressed bytes" $compressedBytes.Count
	if ($compressedBytes.Count -gt 737) {Write-Warning "Compressed size is more than original! Won't be written."; exit}
	#[System.IO.File]::WriteAllBytes("D:\Translations\SaiyuukiWorld\Temp\1.bin",$rawBytes)
	#[System.IO.File]::WriteAllBytes("D:\Translations\SaiyuukiWorld\Temp\2.bin",$compressedBytes)
	0..($compressedBytes.Count -1) | % {$file[$exportOffset+$_] = $compressedBytes[$_]}
	[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
} else {exit}

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
