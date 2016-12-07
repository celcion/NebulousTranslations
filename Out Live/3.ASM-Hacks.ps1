Write-Host
Write-Host "ASM-Hacks"

$mainPath = "D:\Translations\OutLive\"
$originalRomPath = $mainPath + "ROM_Original\Out Live - It's Far a Future on Planet (J).pce"
$patchedRomPath = $mainPath + "ROM_Patched\Out Live - It's Far a Future on Planet (WIP).pce"
$file = [System.IO.File]::ReadAllBytes($patchedRomPath)

# Fix level 50 bug

0..2 | % {$file[114788+$_] = [byte]255}

# Make fonts 8x8
# NOPs
0..2 | % {
	$file[15218+$_] = 234
	$file[15225+$_] = 234
	$file[15254+$_] = 234
	$file[15261+$_] = 234
}

# Make characters White

$file[15185] = 160

# Don't skip even lines on character table

$file[15275] = 24

# Move enemies names lower and left

$file[16999] = 207
$file[17053] = 207

# Change move cursor in cycle

# E79D (0x099D)
# CMP #$61			C9 61
# BNE <to RTS>		D0 06
# LDA #$01			A9 01
# STA $4E			85 4E

$bytes = @(201,97,208,6,169,1,133,78,234,234,234,234)
$importOffset = 2461
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# E7C3 (0x09C3)
# CMP #$FF			C9 FF
# BNE <to RTS>		D0 06
# LDA #$5F			A9 5F
# STA $4E			85 4E

$bytes = @(201,255,208,6,169,95,133,78,234,234,234,234)
$importOffset = 2499
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# 2651 - money
# 99E4 - read

# Fix numbers

# In shops
# 9A25 (3C25) - 20 A1 99 -> 20 F5 DF
$file[15398] = 245
$file[15399] = 223

# In battles
# 9A8C (3C8C) - 20 A1 99 -> 20 F5 DF
$file[15501] = 245
$file[15502] = 223

# In status - 20 A1 99 -> 20 A0 FF
$file[15097] = 160
$file[15098] = 255
# Replace @ with x
$file[23337] = 72

# DFF5 (81F5)
# CLC	  - 18
# ADC #$30  - 69 30
# JSR $99A1 - 20 A1 99
# RTS       - 60

$bytes = @(24,105,48,32,161,153,96)
$importOffset = 33269
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Additional function (for status/passwords)
# FFA0 (21A0)
# PHA		- 48
# TMA $04	- 43 04
# CMP #$1C	- C9 1C
# BNE <PLA> - D0 06
# PLA		- 68
# CLC	  	- 18
# ADC #$30  - 69 30
# BRA <JSR> - 80 01
# PLA		- 68
# JSR $99A1 - 20 A1 99
# RTS       - 60

$bytes = @(72,67,4,201,28,208,6,104,24,105,48,128,1,104,32,161,153,96)
$importOffset = 8608
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# --------------------------------
# Switch pages for single lines in extended space, ASM hack

# DO NOT RELY ON 2067!!!!!
# USE STA $3600 for TMA!


# 3A79 (9879)
# JSR $DFDA		- 20 DA DF
# LDA #$22		- A9 22
# TAM $04		- 53 04
# JSR $4000		- 20 00 40
# JSR $DFEA		- 20 EA DF
# NOP			- EA

$bytes = @(32,218,223,169,34,83,4,32,0,64,32,234,223,234)
$importOffset = 14969
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# ------

# 3A8F (988F)
# JSR $DFE0		- 20 E0 DF

$file[14991] = 32
$file[14992] = 224
$file[14993] = 223

# ------

# 81DA
# TMA $04		- 43 04
# STA $3600		- 8D 00 36
# RTS			- 60

# 81E0
# LDA #$22		- A9 22
# TAM $04		- 53 04
# INC			- 1A
# TAM $08		- 53 08
# JSR $4017		- 20 17 40
# PHA			- 48
# LDA $3600		- AD 00 36
# TAM $04		- 53 04
# INC			- 1A
# TAM $08		- 53 08
# PLA			- 68
# RTS			- 60

$bytes = @(67,4,141,0,54,96,169,34,83,4,26,83,8,32,23,64,72,173,0,54,83,4,26,83,8,104,96)
$importOffset = 33242
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# ------

# 44200
# INC			- 1A
# TAM $08		- 53 08
# LDA $51		- A5 51
# STA $3601		- 8D 01 36
# LDA ($00),Y	- B1 00
# STA $02		- 85 02
# INY			- C8
# LDA ($00),Y	- B1 00
# STA $03		- 85 03
# CLY			- C2
# LDA ($02),Y	- B1 02
# STA $A4		- 85 A4
# RTS			- 60

# 44216
# LDA ($02),Y	- B1 02
# CMP #$FE		- C9 FE
# BNE $C11C		- D0 14
# LDA $3601		- AD 01 36
# CLC			- 18
# ADC #$41		- 69 40 - Don't skip each line
# STA $51		- 85 51
# STA $3601		- 8D 01 36
# BCC $C118		- 90 02
# INC $52		- E6 52
# INY			- C8
# DEC $A4		- C6 A4
# BRA $C100		- 80 E6
# INY			- C8
# RTS			- 60

$bytes = @(26,83,8,165,81,141,1,54,177,0,133,2,200,177,0,133,3,194,177,2,133,164,96,177,2,201,254,208,20,173,1,54,24,105,64,133,81,141,1,54,144,2,230,82,200,198,164,128,230,200,96,255)
$importOffset = 279040
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# --------------------------------

# Switch pages for multiline text in extended space, ASM hack

# Jumps

# Pointers
# C0F0 (62F0)
#
# JSR $DFDA		- 20 DA DF
# LDA #$20		- A9 20
# TAM $04		- 53 04
# JSR $4000		- 20 00 40
# JSR $DFEA		- 20 EA DF
# NOP			- EA

# Text
# C101 (6301)
# 
# LDA #$20		- A9 20
# TAM $04		- 53 04
# INC			- 1A
# TAM $08		- 53 08
# JSR $4012		- 20 12 40
# PHA			- 48
# LDA $3600		- AD 00 36
# TAM $04		- 53 04
# INC			- 1A
# TAM $08		- 53 08
# PLA			- 68
# NOP


$bytes = @(32,218,223,169,32,83,4,32,0,64,32,234,223,234,170,160,1,169,32,83,4,26,83,8,32,18,64,72,173,0,54,83,4,26,83,8,104,234,234,234,234,234,234,234,234)
$importOffset = 25328
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Translanted code

# Pointers
# 6000 (40200)
# 
# INC			- 1A
# TAM $08		- 53 08
# LDA ($00),Y	- B1 00
# STA $02		- 85 02
# INY			- C8
# LDA ($00),Y	- B1 00
# STA $03		- 85 03
# CLY			- C2
# LDA ($02),Y	- B1 02
# STA $A4		- 85 A4
# RTS			- 60

# Text
# 6010 (40210)
# 
# LDA ($02),Y	- B1 02
# CMP #$FE		- C9 FE
# BNE $C11D		- D0 16
# LDA $51		- A5 51
# AND $E0		- 29 E0
# STA $51		- 85 51
# CLC			- 18
# LDA $51		- A5 51
# ADC #$4C		- 69 4C - Don't skip each line
# STA $51		- 85 51
# BCC $C118		- 90 02
# INC $52		- E6 52
# INY			- C8
# DEC $A4		- C6 A4
# BRA $C101		- 80 E4
# RTS			- 60


$bytes = @(26,83,8,177,0,133,2,200,177,0,133,3,194,177,2,133,164,96,177,2,201,254,208,22,165,81,41,224,133,81,24,165,81,105,76,133,81,144,2,230,82,200,198,164,128,228,96)
$importOffset = 262656
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# TODO
# Add ASM hack for coordinated strings.
# 97DB - Read first coordination byte and check for FF
# 97DB (39DB)
# JSR $FF70		- 20 70 FF
# NOP			- EA
$file[14811] = 32
$file[14812] = 112
$file[14813] = 255
$file[14814] = 234

# 97A7 - Read second coordination byte
# 97AA (39AA)
# JSR $FF70		- 20 85 FF
# STA $51		- 85 51

# 97AF - Read line length
# 97AF (39AF)
# JSR $FF70		- 20 85 FF
# STA $A4		- 85 A4

$bytes = @(32,133,255,133,81,32,133,255,133,164)
$importOffset = 14762
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# 97BE - Read characters
# 97BE (39BE)
# JSR $FF70		- 20 85 FF
$file[14782] = 32
$file[14783] = 133
$file[14784] = 255

# First character
# TMA $04		- 43 04
# STA $3602		- 8D 02 36
# LDA #$24		- A9 24
# TAM $04		- 53 04
# LDA ($00),Y	- B1 00
# PHA			- 48
# LDA $3602		- AD 02 36
# TAM $04		- 53 04
# PLA			- 68
# CMP #$FF		- C9 FF
# RTS			- 60
# Rest characters and string
# TMA $04		- 43 04
# STA $3602		- 8D 02 36
# LDA #$24		- A9 24
# TAM $04		- 53 04
# LDA ($00),Y	- B1 00
# PHA			- 48
# LDA $3602		- AD 02 36
# TAM $04		- 53 04
# PLA			- 68
# INY			- C8
# RTS			- 60

$bytes = @(67,4,141,2,54,169,36,83,4,177,0,72,173,2,54,83,4,104,201,255,96,67,4,141,2,54,169,36,83,4,177,0,72,173,2,54,83,4,104,200,96)
$importOffset = 8560
0..($bytes.count-1) | % {$file[$_+$importOffset] = $bytes[$_]}

# Money
# Memory (206E)
# Break 9A89

[System.IO.File]::WriteAllBytes($patchedRomPath,$file)
