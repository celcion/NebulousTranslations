puts
puts "Resize and ASM Hacks"
start_time = Time.now

require_relative 'common'

# Expand the ROM

nesFile = IO.binread(@originalROMPath).bytes
newFile = nesFile[0x0..0x0f] + Array.new(0x20000,0x00) + nesFile[0x10..(nesFile.size-1)]
newFile[4] = 0x10

# Transfer text to expanded space block 0x0f

text = nesFile[0x4010..0x4cad]
moveOffset = 0x0f*0x2000+0x10
text.size.times {|i| newFile[moveOffset+i] = text[i]}
newFile[0x03c3b9] = 0x0f
newFile[0x03c3c6] = 0x0f

# Dirty hacks for top screen info

# SWORD
newFile[0x023458] = 0xc8
newFile[0x023459] = 0xfe

# LIFE
newFile[0x02345d] = 0x41
newFile[0x02345e] = 0xb0
newFile[0x02345f] = 0xfe


# Header string
newFile[0x0233a0] = 0xa0
newFile[0x0233a1] = 0xbf
bytes = [0x20,0x2b,0x7C,0x7F,0x80,0x81,0x82,0x00,0x7D,0x83,0x84,0x00,0x85,0x81,0x86,0x00,0x7E,0x87,0x7D,0x85,0x81,0x88,0xFE]
bytes.size.times {|i| newFile[0x023fb0+i] = bytes[i]}

# Move money counter
newFile[0x0378ff] = 0x6b

# Move swordbar to right
newFile[0x03cf6d] = 0x22
# Move lifebar to below swordbar
newFile[0x03cf6f] = 0x42

# Move life counter
newFile[0x0234cf] = 0x62
# Move pass counter
newFile[0x0234d5] = 0x67

# Move attack item
newFile[0x03cc22] = 0x51
# Move defense item
newFile[0x03cc6d] = 0x55

# Move compass letters
newFile[0x023547] = 0x77


# Nulls to unneeded lines
([0x023497,0x023498,0x02349c,0x02349d,0x0234a1,0x0234a2,0x0234a6,0x0234a7] + (0x0234ab..0x0234af).to_a + (0x0234b3..0x0234b7).to_a).each {|i| newFile[i] = 0x00}

# Pause screen replacement

bytes = [0x00,0x20,0x7E,0x00,0x24,0x00,0x8A,0xA2,0xA3,0x00,0x41,0x74,0x74,0x61,0x63,0x6b,0x00,0x10,0xA3,
		0x81,0xA7,0x05,0x00,0x81,0xA4,0x19,0x00,0x81,0xA4,0x05,0x00,0x81,0xA4,0x19,0x00,0x81,0xA4,0x05,
		0x00,0x81,0xA4,0x19,0x00,0x81,0xA4,0x05,0x00,0x81,0xA5,0x19,0xA3,0x81,0xA6,0x45,0x00,0x8B,0xA2,
		0xA3,0x00,0x44,0x65,0x66,0x65,0x6e,0x73,0x65,0x00,0x0F,0xA3,0x81,0xA7,0x05,0x00,0x81,0xA4,0x19,
		0x00,0x81,0xA4,0x05,0x00,0x81,0xA4,0x19,0x00,0x81,0xA4,0x05,0x00,0x81,0xA4,0x19,0x00,0x81,0xA4,
		0x05,0x00,0x81,0xA5,0x19,0xA3,0x81,0xA6,0x49,0x00,0x85,0x50,0x75,0x6c,0x73,0x65,0x09,0x00,0x85,
		0x44,0x65,0x6d,0x6f,0x6e,0x09,0x00,0x9B,0xA2,0xA3,0xA3,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f,0xA3,
		0xA3,0xA7,0x00,0xA2,0xA3,0xA3,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f,0xA3,0xA3,0xA7,0x05,0x00,0x81,
		0xA4,0x0B,0x00,0x83,0xA4,0x00,0xA4,0x0B,0x00,0x81,0xA4,0x05,0x00,0x81,0xA4,0x0B,0x00,0x83,0xA4,
		0x00,0xA4,0x0B,0x00,0x81,0xA4,0x05,0x00,0x81,0xA4,0x0B,0x00,0x83,0xA4,0x00,0xA4,0x0B,0x00,0x81,
		0xA4,0x05,0x00,0x81,0xA4,0x0B,0x00,0x83,0xA4,0x00,0xA4,0x0B,0x00,0x81,0xA4,0x05,0x00,0x81,0xA5,
		0x0B,0xA3,0x83,0xA6,0x00,0xA5,0x0B,0xA3,0x81,0xA6,0x7E,0x00,0x05,0x00,0x20,0xFF,0x87,0x3F,0xFF,
		0xFF,0x0F,0x0F,0xFF,0x3F,0x0D,0xFF,0x03,0x0F,0x81,0xFF,0x08,0x0F,0xFF]

bytes.size.times {|i| newFile[0x023dc9+i] = bytes[i]}

# Title screen tiles mapping

bytes = [0x6B,0x00,0x8B,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x14,0x00,0x8C,0x0C,0x0D,
		0x0E,0x0F,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x14,0x00,0x82,0x18,0x19,0x3C,0x00,0x90,0x1A,
		0x1B,0x1C,0x1D,0x00,0x1E,0x1F,0x20,0x21,0x1D,0x22,0x23,0x24,0x25,0x26,0x27,0x2E,0x00,0x94,0x28,
		0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,
		0x0A,0x00,0x97,0x3C,0x3D,0x3E,0x3F,0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,
		0x4C,0x4D,0x4E,0x4F,0x50,0x51,0x52,0x08,0x00,0x9A,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x5B,
		0x55,0x5C,0x5D,0x5E,0x5F,0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,0x6B,0x06,0x00,
		0x9C,0x6C,0x55,0x6D,0x6E,0x6F,0x70,0x55,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x48,
		0x7B,0x7C,0x7D,0x7E,0x7F,0x80,0x81,0x82,0x83,0x84,0x05,0x00,0x9C,0x85,0x86,0x87,0x88,0x55,0x89,
		0x8A,0x8B,0x8C,0x48,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x48,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9A,
		0x9B,0x9C,0x9D,0x04,0x00,0x98,0x9E,0x9F,0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,
		0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0x00,0xB2,0xB3,0xB4,0x09,0x00,0x82,0xB5,0xB6,0x43,0x00,0x8D,
		0xB7,0x00,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0x00,0xBE,0xBF,0xC0,0xC1,0x7E,0x00,0x7E,0x00,0x7E,0x00,
		0x11,0x00,0x84,0x40,0x50,0x50,0x10,0x04,0x00,0x84,0x04,0x05,0x05,0x01,0x13,0x00,0x82,0xA0,0xA8,
		0x03,0xAA,0x87,0xA0,0xA0,0x88,0xAA,0xA2,0xAA,0x0A,0x04,0x00,0x84,0x08,0xAA,0xAA,0x0A,0x0B,0x0A,
		0xFF]

bytes.size.times {|i| newFile[0x023c96+i] = bytes[i]}

# Title strings
# Copyright
bytes = [0x22,0x2A,0xB7,0x00,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0x00,0xBE,0xBF,0xC0,0xC1,0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xBA,0xCA,0xCB,0xCC,0xCD,0xCE,0xCC,0xCF,0x00,0xC8,
		0xD0,0xD1,0xD2,0xCF,0xCD,0xD1,0xD3,0xD4,0xCE,0xD2,0xCF,0x00,0xC2,0xC3,0xBE,0xC0,0xFE]
bytes.size.times {|i| newFile[0x023fc8+i] = bytes[i]}

[0x023362,0x023364,0x02336A,0x02338A,0x02339E,0x023428].each do |i|
	newFile[i] = 0xb8
	newFile[i+1] = 0xbf
end

# START
bytes = [0x22,0xAD,0xC7,0xC8,0xBB,0xC6,0xC8,0xFE]
bytes.size.times {|i| newFile[0x02344e+i] = bytes[i]}

# CONTINUE
newFile[0x023368] = 0xf0
newFile[0x023369] = 0xbf
bytes = [0x23,0x0D,0xC4,0xB9,0xBA,0xC8,0xBD,0xBA,0xC9,0xC5,0xFE]
bytes.size.times {|i| newFile[0x024000+i] = bytes[i]}

# Move cursor to the left
newFile[0x03c809] = 0x50

# Secret password
bytes = [0x50,0x45,0x41,0x43,0x45,0x46,0x55,0x4C,0x53,0x4F,0x4C,0x55,0x54,0x49,0x4F,0x4E]
bytes.size.times {|i| newFile[0x02bc17+i] = bytes[i]}

# "Wrong passcode" string
bytes = [0x6E,0x57,0x6C,0x69,0x68,0x61,0x6E,0x6E,0x6A,0x5B,0x6D,0x6D,0x5D,0x69,0x5E,0x5F]
bytes.size.times {|i| newFile[0x02bd75+i] = bytes[i]}

# Gameover screen lines align
newFile[0x03dd86] = 0x83
newFile[0x03dd88] = 0xc3
newFile[0x03dd8a] = 0x03
newFile[0x03dd8c] = 0x43
newFile[0x03dd8e] = 0xcc
newFile[0x03dd90] = 0x0c
newFile[0x03dd91] = 0x22

# Show password lines align
newFile[0x03dd92] = 0x83
newFile[0x03dd96] = 0x03

# Death screen, break: 8129
newFile[0x03443F] = 0xe0
newFile[0x034442] = 0xe8
newFile[0x034445] = 0xf0
newFile[0x034448] = 0xf8
newFile[0x034449] = 0xe1
newFile[0x03444B] = 0x00
newFile[0x03444C] = 0xe1
newFile[0x03444E] = 0x08
newFile[0x03444F] = 0xe1
newFile[0x034451] = 0x10
newFile[0x034452] = 0xe1
newFile[0x034454] = 0x18

IO.binwrite(@patchedROMPath, newFile.pack('c*'))

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
