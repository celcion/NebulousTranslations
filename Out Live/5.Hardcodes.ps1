Write-Host
Write-Host "Hardcodes"

$mainPath = "D:\Translations\OutLive\"
$patchedRomPath = $mainPath + "ROM_Patched\Out Live - It's Far a Future on Planet (WIP).pce"
$file = [System.IO.File]::ReadAllBytes($patchedRomPath)

# Input name screen
# 4 Lines
$file[2891] = 4
$file[2541] = 96
$file[2561] = 96
$file[2568] = 96

# Password chars table
$bytes = @(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,33,63)
$importOffset = 6302
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Input name/Input password
$bytes = @(3,3,25,32,32,127,80,108,101,97,115,101,32,101,110,116,101,114,32,117,110,105,116,32,110,97,109,101,255,3,6,19,32,32,127,69,110,116,101,114,32,112,97,115,115,119,111,114,100,32,32,255)
$importOffset = 49342
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Incorrect
$bytes= @(5,10,12,127,73,110,99,111,114,114,101,99,116,32,32,255)
$importOffset = 3591
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Letters table
$bytes = @(0,65,66,67,68,69,0,70,71,72,73,74,0,97,98,99,100,101,0,102,103,104,105,106,0,75,76,77,78,79,0,80,81,82,83,84,0,107,108,109,110,111,0,112,113,114,115,116,0,85,86,87,88,89,0,90,45,47,33,63,0,117,118,119,120,121,0,122,38,46,44,32,0,48,49,50,51,52,0,53,54,55,56,57,0,35,36,37,40,41,0,58,59,60,61,62,0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96)
$importOffset = 49509
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Move table upper
$file[2749] = 67
$file[2820] = 68

# Move name text upper
$file[2896] = 204
$file[2900] = 01
$file[2954] = 204
$file[2958] = 01

# Jump to new table
$bytes = @(101,127)
0..1 | % {
	$file[2581+$_] = $bytes[$_]
	$file[2612+$_] = $bytes[$_]
	$file[2804+$_] = $bytes[$_]
	$file[2831+$_] = $bytes[$_]
	$file[2848+$_] = $bytes[$_]
	$file[3222+$_] = $bytes[$_]
	$file[3253+$_] = $bytes[$_]
}

# Jump delimiters
$file[2734] = 197
$file[2735] = 127
# Increase jumps number
$file[2740] = 17

# Default username
$bytes = @(66,114,97,117,100,105,115,32)
$importOffset = 2993
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Fix scroll down at the shops
$file[25899] = 246
$file[25900] = 247

# Fix current city placement
# 00007768
$file[30568] = 148

# Move item lines
# 00005977

# Place Items Upper
#$file[23221] = 180
# Move Options Upper
$file[23302] = 179

# Cleanup
# Strings to clean
$file[14985] = 4

# Break B25B
# Read/Write on 26AD-26FF
# Read/Write 2012/2013!

# Place money lower at shops
$file[25564] = 108

# Options and guns spacing
$file[23364] = 128
$file[23445] = 128
# Items spacing
$file[23253] = 64

# Move Target Points
$file[29904] = 150
# Money 
$file[29986] = 20
# Total Money
$file[30048] = 148

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
