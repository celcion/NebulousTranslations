
$mainPath = "D:\Translations\SaiyuukiWorld\"
$exportTblFile = $mainPath + "TBLs\sjis_sw.tbl"
$importTblFile = $mainPath + "TBLs\eng_sw.tbl"
$originalRomPath = $mainPath + "ROM_Original\Saiyuuki World (J).nes"
$patchedRomPath = $mainPath + "ROM_Patched\Saiyuuki World (WIP).nes"
$exportPath = $mainPath + "SCRIPT_Export\"
$importPath = $mainPath + "SCRIPT_Import\"

$tblFile = [System.IO.File]::ReadAllBytes($exportTblFile)
$exportTbl = @{}
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $exportTbl[([convert]::ToInt32($tmp[0].Trim(),16))] = $tmp[1].Replace("`r","")}
$tblFile = [System.IO.File]::ReadAllBytes($importTblFile)
$importTbl = New-Object Collections.Hashtable ([StringComparer]::CurrentCulture)
[System.Text.Encoding]::GetEncoding("shift-jis").GetString($tblFile).Trim() -split '[\n]' | % {$tmp = $_ -split "="; $importTbl[($tmp[1].Replace("`r",""))] = ([convert]::ToInt32($tmp[0],16))}

$iterator = @"
	public class AddBytes {
		public static byte[] Add(byte[]newArr, byte[]fileArr, int startByte, int times) {
			byte[] localArr = newArr;
			int lastcount = 0;
			do {
				{
					int currentByte = lastcount + startByte;
					localArr[lastcount] = fileArr[currentByte];
				}
				lastcount++;
			} while (lastcount <= times);
			return localArr;
		}
	}
"@

Add-Type -TypeDefinition $iterator

function DrawTile ($charTile, $tileNum){
	$localX = ($tileNum % 16) * 8
	$localY = ([math]::floor($tileNum / 16)) * 8
	0..15 | % {
		$charByte = $charTile[$_]
		$tileX = $localX
		$tileY = $localY+$_
		if ($_ -gt 7) {$tileX += 129;$tileY -= 8}
		7..0 | %{
			$mask = 1 -shl $_
			if ($charByte -band $mask) {$bmp.SetPixel($tileX, $tileY, 'Black')} else {$bmp.SetPixel($tileX, $tileY, 'White')}
			$tileX++
		}
	}
}

function BytesToString ($bstring) {
	$string = ""
	$charNum = 0
	while ($charNum -lt $bstring.count) {
		$char = ""
		$currByte = [int]$bstring[$charNum]
		$char = $exportTbl[$currByte]
		$nextByte = [int]$bstring[$charNum+1]
		$charNext = 0
		if ($exportTbl[$nextByte]) {$charNext = [int][char]($exportTbl[$nextByte])}
		if ($char) {
			if ($charNext -eq 12443 -or $charNext -eq 12444) {
				$charInt = [int][char]$char
				$add = $charNext - 12442
				if ($charInt -eq 12358 -or $charInt -eq 12454) {$add = 78}
				if ($charInt -ge 12527 -and $charInt -le 12530) {$add = 8}
				$string += [char]($charInt + $add)
				$charNum++
			} else {
				$string += $char
			}
		} else {
			$string += ("["+("{0:X2}" -f $currByte)+"]")
		}
		$charNum++
	}
	$string
}

function StringToBytes ($string) {
	$resultArr = New-Object System.Collections.Generic.List[System.Object]
	$stringArr = $string.ToCharArray()
	$charNum = 0
	while ($charNum -lt $stringArr.Count) {
		if ($stringArr[$charNum] -eq "[" -and $stringArr[$charNum+3] -eq "]") {
			$resultArr.Add([byte]([Convert]::ToInt32(([char]$stringArr[$charNum+1] + [char]$stringArr[$charNum+2]),16)))
			$charNum += 3
		} else {
			$char = $importTbl[[string]$stringArr[$charNum]]
			if ($char -gt 255) {
				$resultArr.Add([byte](($char -band 0xff00) -shr 8))
				$resultArr.Add([byte]($char -band 0x00ff))
			} else {
				$resultArr.Add([byte]$char)
			}
		}
		$charNum++
	}
	$resultArr
}
