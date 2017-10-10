Write-Host
Write-Host "Hack-COMfile"
$mode = "import" # export, import

$mainPath = "D:\Translations\SC2\"
$strsDir = $mainPath + "HDI_FilesExport\"
$compiledStrsDir = $mainPath + "HDI_FilesImport\"

$stopWatch = [system.diagnostics.stopwatch]::startNew()

$comFile = [System.IO.File]::ReadAllBytes($strsDir + "CRUISER.COM")

$comFile += [Byte[]] (,0xFF * 0x1b0)

# Remove copy protection
$comFile[0x03bd] = 0xeb
$comFile[0x03de] = 0xeb

# Extend STR file RAM space
$comFile[0x04d1] = 0xf0
$comFile[0x04d2] = 0x0f

# Make single wide characters work

$jumpCode = @(0xe9,0x09,0xaf,0x90)
0..($jumpCode.Count -1) | % {$comFile[0x4e35+$_] = $jumpCode[$_]}

# pop ax - 58
# cmp al,85 - 3c85
# jz (skip next) 7404
# add [bp+08],01 80460801
# add [bp+08],01 80460801
# pop bp - 5d
# pop dx - 5a
# ret c3

$injectedCode = @(0x58,0x3c,0x85,0x74,0x04,0x80,0x46,0x08,0x01,0x80,0x46,0x08,0x01,0x5d,0x5a,0xc3)
0..($injectedCode.Count -1) | % {$comFile[0xfd41+$_] = $injectedCode[$_]}

# Portrait lines

$jumpCode = @(0xe9,0x86,0xad,0x90)
0..($jumpCode.Count -1) | % {$comFile[0x4fc8+$_] = $jumpCode[$_]}

# pop ds - 1f
# pop es - 07
# pop di - 5f
# pop cx - 59
# pop bx - 5b
# pop ax - 58
# cmp al,85 - 3c85
# jz (skip next) 7404
# add [bp+08],01 80460801
# add [bp+08],01 80460801
# ret c3

$injectedCode = @(0x1f,0x07,0x5f,0x59,0x5b,0x58,0x3c,0x85,0x74,0x04,0x80,0x46,0x08,0x01,0x80,0x46,0x08,0x01,0xc3)
0..($injectedCode.Count -1) | % {$comFile[0xfd51+$_] = $injectedCode[$_]}

# Fix characters number for portrait - LINE NEEDS TO BE MOVED SOMEWHERE!!!
# $comFile[0xb510] = 0x48
# OVERLAPS COORDINATES AT 1ca8:0950!!!

# Fix name length for location (read from original string)
$comFile[0x1d98] = 0xbd

# Tune replacement characters to single-wide
#0..94 | % {
#	if ($comFile[0x47af+($_*2)] -eq 0x82) {$comFile[0x47af+($_*2)] = 0x85}
#}

0..61 | % {
	$comFile[0x47af+($_*2)] = 0x85
	$comFile[0x47af+($_*2)+1] = ($_ + 0x3f)
}

0..31 | % {
	$comFile[0x482d+($_*2)] = 0x85
	$comFile[0x482d+($_*2)+1] = ($_ + 0x7f)
}

# Fix saves descriptions

0..1 | % {
	$comFile[0x1d8c+$_] = 0x20
	$comFile[0x2558+$_] = 0x20
}
$comFile[0x1d9d+$_] = 0x20
$comFile[0x1d9f+$_] = 0xac
$comFile[0x1da4+$_] = 0xaa
0..4 | % {$comFile[0xf5ea+$_] = 0x90}
$comFile[0xf57f] = 0xd0

#0..20 | % {[System.Text.Encoding]::GetEncoding("shift-jis").GetString( @($comFile[0x47af+($_*2)],$comFile[0x47af+($_*2)+1]) )}

[System.IO.File]::WriteAllBytes(($compiledStrsDir + "CRUISER.COM"),$comFile)

# Additional fix for EVENTS.BIN file (looks like an original game error)
$binFile = [System.IO.File]::ReadAllBytes($strsDir + "EVENTS.BIN")
$binFile[0x6e80] = 0xd9
$binFile[0x6e81] = 0x68
$binFile[0x6e82] = 0x14

# Fix for Gibson name in dialogue at bar after Star Cruiser destruction
$binFile[0x1a1f] = 0xc5


[System.IO.File]::WriteAllBytes(($compiledStrsDir + "EVENTS.BIN"),$binFile)

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
