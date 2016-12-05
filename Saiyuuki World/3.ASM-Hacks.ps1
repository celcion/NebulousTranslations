Write-Host
Write-Host "ASM-Hacks"

. .\Common.ps1

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$file = [System.IO.File]::ReadAllBytes($patchedRomPath)

# Strings start
$file[0xecc8] = 0x26
$file[0xecce] = 0x66
# Items
$file[0xed1c] = 0x26

# Clean window jump
$file[0xebf4] = 0x40
$file[0xebf5] = 0xc0
$file[0xec6d] = 0x40
$file[0xec6e] = 0xc0

# Read chars - FD62 (0x3FD72) and FD6B (0x3FD7B) => C080

$bytes = @(32,112,192,234,234)
0..($bytes.Count -1) | % {
	$file[0x3fd72+$_] = $bytes[$_]
	$file[0x3fd7b+$_] = $bytes[$_]
}

# Read header
# AB4E - AB51 (0xEB5E) => C0A0
$bytes = @(32,160,192,234,234,234)
0..($bytes.Count -1) | % {$file[0xeb5e+$_] = $bytes[$_]}

# AB68 - AB6A (0xEB78) => C0B0
$bytes = @(32,176,192)
0..($bytes.Count -1) | % {$file[0xeb78+$_] = $bytes[$_]}

# AB81 - AB89 (0xEB91) => C0C0
$bytes = @(32,192,192,234,234,234,234,234,234)
0..($bytes.Count -1) | % {$file[0xeb91+$_] = $bytes[$_]}

# AC32 - AC35 (0xEC42) => C0D0
$bytes = @(32,208,192,234)
0..($bytes.Count -1) | % {$file[0xec42+$_] = $bytes[$_]}

# Transferred code

# Clear
# C040
# LDA #$F8		A9 F8
# STA $02			85 02
# LDA #$AC		A9 AC
# STA $03			85 03
# LDA #$26		A9 26
# STA $04			85 04
# LDY #$14		A0 14
# JSR $FF76		20 76 FF
# LDA #$46		A9 46
# STA $04			85 04
# LDY #$14		A0 14
# JSR $FF76		20 76 FF
# LDA #$66		A9 66
# STA $04			85 04
# LDY #$14		A0 14
# JSR $FF76		20 76 FF
# LDA #$86		A9 86
# STA $04			85 04
# LDY #$14		A0 14
# JSR $FF76		20 76 FF
# RTS			60

# C070
# LDA $10			A5 10
# CMP #$03		C9 03
# BNE <BYPASS>		D0 23
# CLC			18
# JSR $C0E0		20 E0 C0
# LDA ($02),Y		B1 02
# CMP #$AF		C9 AF
# BNE <TO STA>		D0 11
# CLC			18
# LDA $56			A5 56
# SBC $54			E5 54
# STA $56			85 56
# LDA #$1F		A9 1F
# STA $54			85 54
# ADC $56			65 56
# STA $56			85 56
# LDA #$B0		A9 B0
# STA $06FF,X		9D FF 06
# JSR $C0E8		20 E8 C0
# CLC			18
# RTS			60
# LDA ($02),Y		B1 02
# STA $06FF,X		9D FF 06
# RTS			60

# C0A0
# JSR $C0E0		20 E0 C0
# ORA ($02),Y		11 02
# STA $59			85 59
# LDA ($02),Y		B1 02
# JSR $C0E8		20 E8 C0
# RTS			60

# C0B0
# JSR $C0E0		20 E0 C0
# INY			C8
# LDA ($02),Y		B1 02
# JSR $C0E8		20 E8 C0
# RTS			60

# C0C0
# JSR $C0E0		20 E0 C0
# LDA ($02),Y		B1 02
# STA $04			85 04
# INY			C8
# LDA ($02),Y		B1 02
# STA $05			85 05
# JSR $C0E8		20 E8 C0
# RTS			60

# C0D0
# JSR $C0E0		20 E0 C0
# LDY #$00		A0 00
# LDA ($02),Y		B1 02
# JSR $C0E8		20 E8 C0
# RTS			60

# C0E0
# PHA			48
# LDA #$07		A9 07
# STA $FF66		8D 66 FF
# PLA			68
# RTS			60

# C0E8
# PHA			48
# LDA #$03		A9 03
# STA $FF62		8D 62 FF
# PLA			68
# RTS			60

$bytes = @(169,248,133,2,169,172,133,3,169,38,133,4,160,20,32,118,255,169,70,133,4,160,20,32,118,255,169,102,133,4,160,20,32,118,255,169,134,133,4,160,20,32,118,255,96,255,255,255,165,16,201,3,208,35,24,32,224,192,177,2,201,175,208,17,24,165,86,229,84,133,86,169,31,133,84,101,86,133,86,169,176,157,255,6,32,232,192,24,96,177,2,157,255,6,96,255,32,224,192,17,2,133,89,177,2,32,232,192,96,255,255,255,32,224,192,200,177,2,32,232,192,96,255,255,255,255,255,255,32,224,192,177,2,133,4,200,177,2,133,5,32,232,192,96,32,224,192,160,0,177,2,32,232,192,96,255,255,255,255,255,72,169,7,141,102,255,104,96,72,169,3,141,98,255,104,96)
0..($bytes.Count -1) | % {$file[0x3c050+$_] = $bytes[$_]}

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)

$stopWatch.Stop()
Write-Host "Done!"
Write-Host "Running time:" $stopWatch.Elapsed.TotalSeconds