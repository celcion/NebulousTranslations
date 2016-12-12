Write-Host
Write-Host "ChangeCoordinates-Parse"

$mainPath = "D:\Translations\Vixen357\"
$patchedRomPath = $mainPath + "ROM_Patched\Vixen 357 (WIP).md"

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$file = [System.IO.File]::ReadAllBytes($patchedRomPath)

# Patch menu lines allocations

# Top menu with stats spheres - move to the right
# 0000F763
# 0000F77F
# 0000F79B
# 0000F7B7
@(63331,63359,63387,63415) | % {$file[$_] = 23}

# Move first column to the right by two characters
# 0000F84D - "Melee   Shoot"
# 0000F86B - "Wepn, Pwr, Num, Rang, Left"
# 0000F8B7 - "AP, DP, HR, ER"
@(63565,63595,63671) | % {$file[$_] = 9}

# Move second column to the right by one character
# 0000F96F - "Wepn, Pwr, Num, Rang, Left"
# 0000F9BB - "AP, DP, HR, ER"
@(63855,63931) | % {$file[$_] = 17}

# Move "Melee  Shoot Special" one line upper
# 0000F84F
$file[63567] = 8

# Move "Wepn, Pwr, Num, Rang, Left" one line upper
# 0000F7E1 - "Wepn, Pwr, Num, Rang"
# 0000F86D - "Wepn, Pwr, Num, Rang, Left" 1st column
# 0000F971 - "Wepn, Pwr, Num, Rang, Left" 2nd column
@(63457,63597,63857) | % {$file[$_] = 10}

# Move "AP, DP, HR, ER" one line upper
# 0000F8C3 - "AP, DP, HR, ER" 1st column
# 0000F9C7 - "AP, DP, HR, ER" 2nd column
@(63683,63943) | % {$file[$_] = 16}

# Current MP
# 0000FA8B - X
# 0000FA8D - Y
$file[64139] = 33
$file[64141] = 10

# MP cost
# 0000FAA7 - "MP consume" move, X - 19
# 0000FAA9 - "MP consume" move, Y - 0C
$file[64167] = 25
$file[64169] = 12

# Move "None" to the right
# 0000FBC1 - People, 7 chars
# 0000FC71 - Units, 6 chars
$file[64449] = 20
$file[64625] = 19

# Move "Lev." at characters select screen one line upper
# 0000F2BB - 10
$file[62139] = 16

# Change message windows
# Resupply note 1
# 0000D853 - X - 0A
# 0000D855 - Y
# 0000D859 - Width - 15
# 0000D85B - Height - 5
# 0000D867 - String X - 0B
# 0000D869 - String Y
$file[55379] = 8
$file[55385] = 25
$file[55387] = 5
$file[55399] = 10

# Resupply note 2
# 0000DA89 - X - 0A
# 0000DA8B - Y
# 0000DA8F - Width - 15
# 0000DA91 - Height - 5
# 0000DA9D - String X - 0B
# 0000DA9F - String Y
$file[55945] = 9
$file[55951] = 23
$file[55953] = 5
$file[55965] = 11

# No pilots can deploy
# 0000F5EF - X - 8
# 0000F5F1 - Y
# 0000F5F5 - Width - 18
# 0000F5F7 - Height
# 0000F603 - String X - 9
# 0000F605 - String Y
$file[62959] = 9
$file[62965] = 23
$file[62979] = 11

# Scene completed!
# 00009FA3 - X - 9
# 00009FA5 - Y - 9
# 00009FA9 - Width - 17
# 00009FAB - Height - 5
# 00009FB3 - String X - B
# 00009FB5 - String Y
# 00009FC1 - Number X - 11
$file[40867] = 9
$file[40869] = 9
$file[40873] = 23
$file[40875] = 5
$file[40883] = 11
$file[40897] = 17

# Supply
# 0000F687 - X - 0B
# 0000F689 - Y
# 0000F68D - Width - 14
# 0000F68F - Height - 5
# 0000F69B - String X - 0C
# 0000F69D - String Y
$file[63111] = 10
$file[63117] = 22
$file[63119] = 5
$file[63131] = 12

# Save
# 00010467 - X - 0C
# 00010469 - Y
# 0001046D - Width - 11
# 0001046F - Height - 05
# 0001047B - String X - 0D
# 0001047D - String Y
$file[66663] = 11
$file[66669] = 19
$file[66671] = 5
$file[66683] = 13

# Config
# 000104AD - X - 07 *
$file[66733] = 7
# 000104AF - Y - 07 *
$file[66735] = 7
# 000104B3 - Width - 1A *
$file[66739] = 26
# 000104B5 - Height - 9 *
$file[66741] = 9
# "-" separator
# 000104CB - Separator code, 2D *
$file[66763] = 45
# 000104C7 - X, All - 17 *
$file[66759] = 23
# 000104C9 - Y, 1st - 09
# 000104D1 - Y, 2nd - 0A
# 000104D7 - Y, 3rd - 0B
# Lines
# 0001065D - X, All - 09 *
$file[67165] = 9
# 0001065F - Y, 1st - 09
# 00010669 - Y, 2nd - 0A
# 00010671 - Y, 3rd - 0B
# Settings
# 00010689 - X, 1st - 19 *
# 0001068B - Y, 1st - 09
# 000106A1 - X, 2nd - 19 *
# 000106A3 - Y, 2nd - 0A
# 000106B9 - X, 3rd - 19 *
# 000106BB - Y, 3rd - 0B
@(67209,67233,67257) | % {$file[$_] = 25}


# Enemy out of range
# 0000DC91 - X - 9
# 0000DC97 - Width - 16
$file[56465] = 7
$file[56471] = 25

# Conditions
# 0001024D - Winning, X - C
$file[66125] = 11
# 0001026D - Loosing, X - C
$file[66157] = 11

# PUSH START quick fix

$bytes = @(1,216,252,0,6,224,252,0,8,232,252,0,3,240,252,0,3,248,252,0,3,8,252,0,7,16,252,0,5,24,252,8)
$importOffset = 1048592
$pointerOffset = 108306
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}
# Remap pointer
$file[$pointerOffset] = [byte](($importOffset -band 0xff000000) -shr 24)
$file[$pointerOffset+1] = [byte](($importOffset -band 0x00ff0000) -shr 16)
$file[$pointerOffset+2] = [byte](($importOffset -band 0x0000ff00) -shr 8)
$file[$pointerOffset+3] = [byte]($importOffset -band 0x000000ff)

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds
