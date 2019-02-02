puts
puts "Resize and ASM Hacks"
start_time = Time.now

require_relative 'common'

# Need to check the byte that switch page for text and increment it for needed (if offset >= 0xd000) - ASM HACK. Additional space at 0x38f40

nesFile = IO.binread(@originalROMPath).bytes
newFile = nesFile

# Fix mapper information
newFile[0x06] = 0x62
newFile[0x07] = 0x70

# Remove palette change for some entries in UI panes
# Palette codes starts from 0x014b16 (0x8b06 in the game), break at C5C9 in the game.
4.times {|t| newFile[0x014b91+t] = 0x00}

# Set overlay strings on title screen
importBytes = encodeString "New Game"
importBytes.size.times {|t| newFile[0x02c294+t] = importBytes[t]}
importBytes = encodeString "Delete "
importBytes.size.times {|t| newFile[0x02c29e+t] = importBytes[t]}
newFile[0x02c28c] = 0x2d # Fix "Delete" placement
newFile[0x02c3b5] = 0x2d # Fix "Delete" blanking
# Empty slot warning
importBytes = encodeString " Empty slot  "
importBytes.size.times {|t| newFile[0x02c2db+t] = importBytes[t]}
# Set overlay strings on save delete screen
importBytes = encodeString "Which one?"
importBytes.size.times {|t| newFile[0x02c3bb+t] = importBytes[t]}
# Set overlay strings on man/woman selection screen
importBytes = encodeString "Man   Woman"
importBytes.size.times {|t| newFile[0x02c477+t] = importBytes[t]}
newFile[0x02c45e] = 0x80 # Fix cursor
# Set bet string in casino
importBytes = encodeString "Bet:  Spin"
(importBytes.size-1).times {|t| newFile[0x34428+t] = importBytes[t]}
#newFile[0x034438] = 0x45 # Fix cursor

# Fix cursor location after changes (0x2000 - y, 0x2003 - x)
# Fix cursor on start screen
newFile[0x02c228] = 0x60
# Fix cursor delete save screen
newFile[0x02c365] = 0x60
#Fix cursor on goal selection
newFile[0x02ca07] = 0x28
newFile[0x02ca0b] = 0x28
newFile[0x02ca0f] = 0x28
# Fix cursor on confirm screen
newFile[0x02ca21] = 0xc0

# Fix top bar numbers placement
newFile[0x03d26c] = 0xa5
newFile[0x03d270] = 0xac
# Fix goal placement
newFile[0x03d175] = 0x74 # top bar
newFile[0x03d177] = 0xeb # status screen
newFile[0x03d178] = 0x20 # status screen
# Fix name placement
newFile[0x03d152] = 0xab # status screen

# Fix adding yen sign at the end of the lines
#newFile[0x03fa51] = 0x24 # FA41 - inventory

# Fix placement on info screen (break at E84D)
# WIS
newFile[0x03d27c] = 0xf9
# END
newFile[0x03d280] = 0x39
# TRU
newFile[0x03d284] = 0x79
# LCK
newFile[0x03d288] = 0xb9

# Replace letter codes for name entries
importBytes = encodeString "ABCDEabcdeFGHIJfghijKLMNOklmnoPQRSTpqrstUVWXYuvwxyZ.,!?z():;"
(importBytes.size-1).times {|t| newFile[0x02c746+t] = importBytes[t]}

# Change bank for pointers to 1D (0x03A010 in the ROM)
newFile[0x03ff23] = 0x93 # FF12
newFile[0x03ff29] = 0x15 # FF18

# DIRTY HACK!
# Fix save selection.
importBytes = encodeString "Save1"
importBytes.size.times {|t| newFile[0x02d7ec+t] = importBytes[t]}
importBytes.size.times {|t| newFile[0x0359c9+t] = importBytes[t]}
importBytes = encodeString "Save2"
importBytes.size.times {|t| newFile[0x02d7f2+t] = importBytes[t]}
importBytes.size.times {|t| newFile[0x0359cf+t] = importBytes[t]}

#newFile = nesFile[0x0..0x01c00f] + Array.new((0x2000*nesFile[4]*2),0x00) + nesFile[0x1c010..(nesFile.size-1)]
#newFile[4] = nesFile[4]*2

# Replace message parsing code for imported function
newFile[0x03e032] = 0x99 # FF12
newFile[0x03e033] = 0xfc # FF18

# Make item call the same function in messages and gym
newFile[0x03fd9f] = 0x58
newFile[0x03fda1] = 0x58

#fix cursor on entering name
# 1) press down on last line with letters
block_offset = 0x22010
code_offset = 0xa548
8.times do |i|
	newFile[block_offset + code_offset + i] = 0xea
end
# 2) Don't go left from END
code_offset = 0xa585
replacement = [0xea, 0xea, 0xa9, 0x05, 0x85, 0x79]
replacement.length.times do |i|
	newFile[block_offset + code_offset + i] = replacement[i]
end
# 3) Don't go right from END
newFile[block_offset + 0xa5ae] = 0x05
# 4) press UP on first line with letters
code_offset = 0xA529
8.times do |i|
	newFile[block_offset + code_offset + i] = 0xea
end

# Fix palette on name and genre screens
newFile[block_offset + 0xa06f] = 0xf
newFile[block_offset + 0xa074] = 0xf
newFile[block_offset + 0xa079] = 0x3

# dictionary for title screen
sprite_dict = [
0x00, 0x01, 0x10, 0x11,   0x20, 0x21, 0x20, 0x21,   0x30, 0x21, 0x20, 0x21,   0x20, 0x21, 0x20, 0x21,   0x00, 0x04, 0x10, 0x24,   0x04, 0x04, 0x14, 0x14,   0x05, 0x34, 0x15, 0x16,   0x06, 0x06, 0x16, 0x16,
0x25, 0x36, 0x35, 0x36,   0x36, 0x00, 0x36, 0x10,   0x36, 0x20, 0x36, 0x20,   0x36, 0x30, 0x36, 0x88,   0x36, 0x05, 0x36, 0x15,   0x01, 0x36, 0x11, 0x36,   0x21, 0x36, 0x21, 0x36,   0x30, 0x31, 0x88, 0x89,
0x26, 0x36, 0x35, 0x36,   0x23, 0x36, 0x33, 0x36,   0x30, 0x02, 0x88, 0x96,   0x22, 0x03, 0x98, 0x97,   0x05, 0x26, 0x15, 0x35,   0x04, 0x04, 0x24, 0x14,   0x04, 0x23, 0x14, 0x33,   0x02, 0x22, 0x96, 0x98,
0x03, 0x36, 0x97, 0x36,   0x34, 0x06, 0x16, 0x16,   0x06, 0x25, 0x16, 0x35,   0x36, 0x36, 0x36, 0x36,   0x36, 0x07, 0x36, 0x17,   0x28, 0x09, 0x38, 0x19,   0x2A, 0x0B, 0x3A, 0x1B,   0x08, 0x27, 0x18, 0x37,
0x36, 0x29, 0x36, 0x39,   0x0C, 0x2B, 0x1C, 0x3B,   0x36, 0x29, 0x36, 0x39,   0x0D, 0x09, 0x1D, 0x2D,   0x36, 0x36, 0x84, 0x44,   0x36, 0x36, 0x36, 0x43,   0x36, 0x36, 0x83, 0x80,   0x36, 0x36, 0x81, 0x36,
0x36, 0x36, 0x36, 0xB3,   0x36, 0x36, 0xA1, 0x92,   0x36, 0x36, 0x44, 0xB1,   0x36, 0x36, 0x95, 0x36,   0x36, 0x36, 0x53, 0x94,   0x36, 0x6B, 0x36, 0x7B,   0x4D, 0x5E, 0x5D, 0x6E,   0x6B, 0x4D, 0x7B, 0x5D,
0x36, 0x36, 0x85, 0x36,   0x0A, 0x36, 0x1A, 0x36,   0x0A, 0x36, 0x3D, 0x36,   0x2C, 0x09, 0x3C, 0x19,   0x7A, 0x5B, 0x74, 0x4C,   0x36, 0x5C, 0x36, 0x6C,   0x6D, 0x7E, 0x7C, 0x7D,   0x5C, 0x4E, 0x6C, 0x36,
0x5E, 0x4F, 0x6E, 0x5F,   0x1E, 0x1F, 0x2E, 0x2F,   0x86, 0x87, 0x86, 0x87,   0x36, 0x36, 0x36, 0xB4,   0x36, 0x36, 0x81, 0x82,   0x36, 0x36, 0x36, 0xB1,   0x36, 0x36, 0xA3, 0xB3,   0x36, 0x36, 0xB0, 0x36,
0x36, 0x6F, 0x36, 0x0E,   0x3E, 0x0F, 0x3F, 0x7F,   0x36, 0x36, 0x36, 0xB5,   0x36, 0x36, 0x36, 0x80,   0x36, 0x36, 0x81, 0x81,   0x36, 0x36, 0x94, 0xA1,   0x36, 0x36, 0x95, 0xA1,   0x36, 0x36, 0x91, 0x94,
0x36, 0x36, 0x93, 0xA2,   0x36, 0x36, 0x36, 0xB2,   0x36, 0x36, 0xA3, 0xB1,   0x36, 0x36, 0xA4, 0x84,   0x36, 0x36, 0xB3, 0x36,   0x36, 0x36, 0x92, 0x94,   0x36, 0x36, 0x91, 0xA0,   0x36, 0x36, 0xB1, 0xA1,
0x36, 0x36, 0xA5, 0x36,   0x36, 0x36, 0x36, 0xA4,   0x36, 0x36, 0x91, 0xB0,   0x36, 0x36, 0x91, 0x94,   0x36, 0x36, 0x91, 0x36,   0x36, 0x36, 0x90, 0x36,   0x36, 0x36, 0x83, 0x36,   0x36, 0x36, 0x85, 0x94,
0x36, 0x36, 0xA1, 0x95,   0x36, 0x36, 0xA1, 0xB3,   0x36, 0x36, 0xA4, 0x95,   0x36, 0x86, 0x36, 0x86,   0x87, 0x36, 0x87, 0x36,   0x31, 0x36, 0x89, 0x36]
dict_insert_addr = 0x1401E
sprite_dict.length.times do |i|
	newFile[dict_insert_addr + i] = sprite_dict[i]
end
sprite_map = [
0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x1C, 0x1F, 0x1D, 0x31, 0x20, 0x1E, 0x21, 0x33, 0x31, 0x22, 0x23, 0x32, 0x1B, 0x1B,
0x1B, 0x1B, 0x00, 0x1B, 0x1B, 0x09, 0x0D, 0x1B, 0x04, 0x05, 0x11, 0x09, 0x15, 0x16, 0x1B, 0x1B,
0x1B, 0x1B, 0x01, 0x1B, 0x1B, 0x0A, 0x0E, 0x1B, 0x01, 0x1B, 0x1B, 0x0A, 0x0E, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x0F, 0x1B, 0x1B, 0x0B, 0x5D, 0x1B, 0x12, 0x13, 0x1B, 0x0B, 0x17, 0x18, 0x1B, 0x1B,
0x1B, 0x1B, 0x3A, 0x1B, 0x1B, 0x5B, 0x5C, 0x1B, 0x3A, 0x1B, 0x1B, 0x5B, 0x5C, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x06, 0x07, 0x08, 0x0C, 0x10, 0x1B, 0x14, 0x1B, 0x1B, 0x0C, 0x19, 0x1A, 0x42, 0x1B,
0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x2D, 0x2E, 0x2F, 0x38, 0x39, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x35, 0x36, 0x37, 0x40, 0x41, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x3B, 0x43, 0x3C, 0x56, 0x3D, 0x3E, 0x3F, 0x45, 0x46, 0x47, 0x48, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x3B, 0x43, 0x44, 0x55, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x1B, 0x1B,
0x1B, 0x1B, 0x3B, 0x51, 0x52, 0x53, 0x54, 0x43, 0x44, 0x55, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x1B, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x24, 0x2B, 0x2C, 0x24, 0x30, 0x1B, 0x1B,
0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B,
0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B, 0x1B,
]
map_insert_addr = 0x1461E
sprite_map.length.times do |i|
	newFile[map_insert_addr + i] = sprite_map[i]
end

IO.binwrite(@patchedROMPath, newFile.pack('c*'))

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."


