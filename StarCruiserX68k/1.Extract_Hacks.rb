puts
puts "Extract files and apply ASM Hacks"
start_time = Time.now

require_relative 'common'
require 'fileutils'

FileUtils.cp_r( (@originalFilesPath+"."), @patchedFilesPath, :preserve => false )

Dir[@mainPath+"/ASM/*.bin"].each do |bin|
	asmBin = IO.binread(bin).bytes
	fileName = bin.split("/").last[0..-5]
	modFileName = fileName.split("_")[1]
	modFile = readFile("patched",modFileName)
	insData = fileName.split("_")[2]
	if insData == "append"
		linksOffsets = (modFile[0x0e] << 8) + modFile[0x0f]
		modFile = modFile[0..linksOffsets+0x40-1] + asmBin + modFile[linksOffsets+0x40..modFile.size-1]
		linksOffsets += asmBin.size
		modFile[0x0e] = (linksOffsets & 0xff00) >> 8
		modFile[0x0f] = (linksOffsets & 0x00ff)
	else
		insOffset = insData.to_i(16)
		asmBin.size.times {|i| modFile[i+insOffset] = asmBin[i]}
	end
	if !writeFile("patched",modFileName,modFile)
		puts "Unable to write ASM patch for '" + modFileName + "' file!"
	end
end

modFile = readFile("patched","DEMO.X")
# Replace char reading in opening text
insOffset = 0x151c
[0x61,0x00,0x45,0x82,0x4e,0x71,0x4e,0x71,0x4e,0x71,0x4e,0x71].each do |b|
	modFile[insOffset] = b
	insOffset += 1
end
# Replace TST.W (A0) with TST.B (A0)
modFile[0x14eb] = 0x10
modFile[0x358b] = 0x10
modFile[0x3745] = 0x10
# Replace MOVE.W (A1),D0 with MOVE.B (A1),D0
modFile[0x14fc] = 0x10

# Fix text positioning
modFile[0x1504] = 0xe3
modFile[0x150e] = 0x00
modFile[0x150f] = 0xd0

if !writeFile("patched","DEMO.X",modFile)
	puts "Unable to write byte patch for 'DEMO.X' file!"
end


modFile = readFile("patched","EVENT.X")
# Remove moving some registers to stack causing shops to mulfuction
#2.times do |t|
#	modFile[0x0c92+(t*2)] = 0x4e
#	modFile[0x0c93+(t*2)] = 0x71
#end

# Remove EXT.W for jump code (because back jumps aren't used)
modFile[0x1daa] = 0x4e
modFile[0x1dab] = 0x71

if !writeFile("patched","EVENT.X",modFile)
	puts "Unable to write byte patch for 'EVENT.X' file!"
end


modFile = readFile("patched","CRUISER.X")
# Replace char table with 8x16 codes
0x5e.times do |t|
	modFile[0x3150+(t*2)] = 0x80
	modFile[0x3151+(t*2)] = t+0x20
end
# Remove replacing $
0x6.times do |t|
	modFile[0x3100+(t*2)] = 0x4e
	modFile[0x3101+(t*2)] = 0x71
end

if !writeFile("patched","CRUISER.X",modFile)
	puts "Unable to write byte patch for 'CRUISER.X' file!"
end


modFile = readFile("patched","USEITEM.X")
statusStrings = encodeString "Normal[00][00][02]Damaged[07][00]"
#saveString = encodeString "[05]00:[07]00y 00m 00d   00m 00s /"

linksOffsets = (modFile[0x0e] << 8) + modFile[0x0f]
[0x1032,0x1076,0x1094].each do |off|
	ptrData = (linksOffsets + 0x40 - off)
	modFile[off] = (ptrData & 0xff00) >> 8
	modFile[off+1] = (ptrData & 0x00ff)
end
[0x0ffa,0x1020,0x103e,0x1064,0x1082,0x10a0].each do |off|
	ptrData = (linksOffsets + 0x40 - off) + 8
	modFile[off] = (ptrData & 0xff00) >> 8
	modFile[off+1] = (ptrData & 0x00ff)
end

modFile = modFile[0..linksOffsets+0x40-1] + statusStrings + modFile[linksOffsets+0x40..modFile.size-1]
linksOffsets += statusStrings.size
modFile[0x0e] = (linksOffsets & 0xff00) >> 8
modFile[0x0f] = (linksOffsets & 0x00ff)

# Backspace width
modFile[0x2455] = 0x08
modFile[0x2463] = 0x08

insOffset = 0x2643
[0x80,0x2e,0x30,0x30,0x80,0x2e,0x30,0x30,0x80,0x20,0x20,0x30,0x30,0x80,0x3a,0x30,0x30,0x80,0x20].each do |b|
	modFile[insOffset] = b
	insOffset += 1
end

# Move weapon number to the right a little
modFile[0x1475] = 0x5c

if !writeFile("patched","USEITEM.X",modFile)
	puts "Unable to write byte patch for 'USEITEM.X' file!"
end


modFile = readFile("patched","MAZE.X")
# Quick hack for names in status (better to do it properly later)
text = encodeString "C. Sark "
insOffset = 0x21f1
text.each do |b|
	modFile[insOffset] = b
	insOffset += 1
end
text = encodeString "RedScorpion"
insOffset = 0x2205
text.each do |b|
	modFile[insOffset] = b
	insOffset += 1
end

if !writeFile("patched","MAZE.X",modFile)
	puts "Unable to write byte patch for 'MAZE.X' file!"
end

modFile = readFile("patched","FLIGHT.X")
# "hidrogen" fix
modFile[0x3f19] = 0x79

if !writeFile("patched","FLIGHT.X",modFile)
	puts "Unable to write byte patch for 'FLIGHT.X' file!"
end


=begin
# Patch event file
modFile = readFile("patched","CRUISER.X")

[0x2e3f,0x2e4f,0x2e61,0x2e71,0x2e83,0x2e93,0x2ea5,0x2eb5,0x2ecf,0x2edf,0x2ef1,0x2f01,0x2f13,0x2f23,0x2f35,0x2f45].each {|off| modFile[off] -= 2}

patch = IO.binread((@mainPath+"/ASM/test1.dat")).bytes
while patch.size < 252
	patch.push 0
end
patch.size.times {|i| modFile[0x2f58+i] = patch[i]}

0x5e.times do |t|
	modFile[0x3150+(t*2)] = 0x80
	modFile[0x3151+(t*2)] = t+0x20
end
=end

=begin
#modFile[0x261b] = 0x1c # Fix absolute path fixing
#modFile[0x261d] = 0x4a # Fix the next path too

modFile[0x2f58..0x2f5b] = [0x60,0x00,0x57,0x0c]

patch = IO.binread((@mainPath+"/ASM/test1.dat")).bytes

linksOffsets = (modFile[0x0e] << 8) + modFile[0x0f]
overflowOffset = linksOffsets + 0x40
modFile = modFile[0..overflowOffset-1] + patch + modFile[overflowOffset..modFile.size-1]
linksOffsets += patch.size
modFile[0x0e] = (linksOffsets & 0xff00) >> 8
modFile[0x0f] = (linksOffsets & 0x00ff)

if !writeFile("patched","CRUISER.X",modFile)
	puts "Unable to write byte patch for '" + modFileName + "' file!"
end
=end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
