@ops = {0x69 => {:opName => "ADC", :opHex => "69", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Add With Carry (ADC)"},
        0x65 => {:opName => "ADC", :opHex => "65", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Add With Carry (ADC)"},
        0x75 => {:opName => "ADC", :opHex => "75", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Add With Carry (ADC)"},
        0x72 => {:opName => "ADC", :opHex => "72", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Add With Carry (ADC)"},
        0x61 => {:opName => "ADC", :opHex => "61", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Add With Carry (ADC)"},
        0x71 => {:opName => "ADC", :opHex => "71", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Add With Carry (ADC)"},
        0x6D => {:opName => "ADC", :opHex => "6D", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Add With Carry (ADC)"},
        0x7D => {:opName => "ADC", :opHex => "7D", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Add With Carry (ADC)"},
        0x79 => {:opName => "ADC", :opHex => "79", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Add With Carry (ADC)"},
        0x29 => {:opName => "AND", :opHex => "29", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "And Accumulator with Memory (AND)"},
        0x25 => {:opName => "AND", :opHex => "25", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "And Accumulator with Memory (AND)"},
        0x35 => {:opName => "AND", :opHex => "35", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "And Accumulator with Memory (AND)"},
        0x32 => {:opName => "AND", :opHex => "32", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "And Accumulator with Memory (AND)"},
        0x21 => {:opName => "AND", :opHex => "21", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "And Accumulator with Memory (AND)"},
        0x31 => {:opName => "AND", :opHex => "31", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "And Accumulator with Memory (AND)"},
        0x2D => {:opName => "AND", :opHex => "2D", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "And Accumulator with Memory (AND)"},
        0x3D => {:opName => "AND", :opHex => "3D", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "And Accumulator with Memory (AND)"},
        0x39 => {:opName => "AND", :opHex => "39", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "And Accumulator with Memory (AND)"},
        0x06 => {:opName => "ASL", :opHex => "06", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Shift Memory or Accumulator Left (ASL)"},
        0x16 => {:opName => "ASL", :opHex => "16", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Shift Memory or Accumulator Left (ASL)"},
        0x0E => {:opName => "ASL", :opHex => "0E", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Shift Memory or Accumulator Left (ASL)"},
        0x1E => {:opName => "ASL", :opHex => "1E", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Shift Memory or Accumulator Left (ASL)"},
        0x0A => {:opName => "ASL", :opHex => "0A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Shift Memory or Accumulator Left (ASL)"},
        0x0F => {:opName => "BBR0", :opHex => "0F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR0)"},
        0x1F => {:opName => "BBR1", :opHex => "1F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR1)"},
        0x2F => {:opName => "BBR2", :opHex => "2F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR2)"},
        0x3F => {:opName => "BBR3", :opHex => "3F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR3)"},
        0x4F => {:opName => "BBR4", :opHex => "4F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR4)"},
        0x5F => {:opName => "BBR5", :opHex => "5F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR5)"},
        0x6F => {:opName => "BBR6", :opHex => "6F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR6)"},
        0x7F => {:opName => "BBR7", :opHex => "7F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Reset (BBR7)"},
        0x90 => {:opName => "BCC", :opHex => "90", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch on Carry Clear (BCC)"},
        0x8F => {:opName => "BBS0", :opHex => "8F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS0)"},
        0x9F => {:opName => "BBS1", :opHex => "9F", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS1)"},
        0xAF => {:opName => "BBS2", :opHex => "AF", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS2)"},
        0xBF => {:opName => "BBS3", :opHex => "BF", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS3)"},
        0xCF => {:opName => "BBS4", :opHex => "CF", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS4)"},
        0xDF => {:opName => "BBS5", :opHex => "DF", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS5)"},
        0xEF => {:opName => "BBS6", :opHex => "EF", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS6)"},
        0xFF => {:opName => "BBS7", :opHex => "FF", :opLen => 3, :opSyntax => '$ZZ,$hhll', :opBytes => "ZZ rr", :opDesc => "Branch on Bit Set (BBS7)"},
        0xB0 => {:opName => "BCS", :opHex => "B0", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch on Carry Set (BCS)"},
        0xF0 => {:opName => "BEQ", :opHex => "F0", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch on Equal (BEQ)"},
        0x89 => {:opName => "BIT", :opHex => "89", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Test Memory Bits against Accumulator (BIT)"},
        0x24 => {:opName => "BIT", :opHex => "24", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Test Memory Bits against Accumulator (BIT)"},
        0x34 => {:opName => "BIT", :opHex => "34", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Test Memory Bits against Accumulator (BIT)"},
        0x2C => {:opName => "BIT", :opHex => "2C", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Test Memory Bits against Accumulator (BIT)"},
        0x3C => {:opName => "BIT", :opHex => "3C", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Test Memory Bits against Accumulator (BIT)"},
        0x30 => {:opName => "BMI", :opHex => "30", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch on Minus (BMI)"},
        0xD0 => {:opName => "BNE", :opHex => "D0", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch on Not Equal (BNE)"},
        0x10 => {:opName => "BPL", :opHex => "10", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch on Plus (BPL)"},
        0x80 => {:opName => "BRA", :opHex => "80", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch Always (BRA)"},
        0x00 => {:opName => "BRK", :opHex => "00", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Break (BRK)"},
        0x44 => {:opName => "BSR", :opHex => "44", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch to Subroutine (BSR)"},
        0x70 => {:opName => "BVS", :opHex => "70", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch if Overflow Set (BVS)"},
        0x50 => {:opName => "BVC", :opHex => "50", :opLen => 2, :opSyntax => '$hhll', :opBytes => "rr", :opDesc => "Branch if Overflow Clear (BVC)"},
        0x18 => {:opName => "CLC", :opHex => "18", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear Carry Flag (CLC)"},
        0x62 => {:opName => "CLA", :opHex => "62", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear Accumulator (CLA)"},
        0xD8 => {:opName => "CLD", :opHex => "D8", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear Decimal Flag (CLD)"},
        0x58 => {:opName => "CLI", :opHex => "58", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear Interrupt Disable Flag (CLI)"},
        0xB8 => {:opName => "CLV", :opHex => "B8", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear Overflow Flag (CLV)"},
        0xC2 => {:opName => "CLY", :opHex => "C2", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear Y Register (CLY)"},
        0x82 => {:opName => "CLX", :opHex => "82", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Clear X Register (CLX)"},
        0xC0 => {:opName => "CPY", :opHex => "C0", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Compare Y Register with Memory (CPY)"},
        0xC4 => {:opName => "CPY", :opHex => "C4", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Compare Y Register with Memory (CPY)"},
        0xCC => {:opName => "CPY", :opHex => "CC", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Compare Y Register with Memory (CPY)"},
        0xE0 => {:opName => "CPX", :opHex => "E0", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Compare X Register with Memory (CPX)"},
        0xE4 => {:opName => "CPX", :opHex => "E4", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Compare X Register with Memory (CPX)"},
        0xEC => {:opName => "CPX", :opHex => "EC", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Compare X Register with Memory (CPX)"},
        0xD4 => {:opName => "CSH", :opHex => "D4", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Change Speed High (CSH)"},
        0x54 => {:opName => "CSL", :opHex => "54", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Change Speed Low (CSL)"},
        0xC9 => {:opName => "CMP", :opHex => "C9", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xC5 => {:opName => "CMP", :opHex => "C5", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xD5 => {:opName => "CMP", :opHex => "D5", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xD2 => {:opName => "CMP", :opHex => "D2", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xC1 => {:opName => "CMP", :opHex => "C1", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xD1 => {:opName => "CMP", :opHex => "D1", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xCD => {:opName => "CMP", :opHex => "CD", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xDD => {:opName => "CMP", :opHex => "DD", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xD9 => {:opName => "CMP", :opHex => "D9", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Compare Accumulator with Memory (CMP)"},
        0xCA => {:opName => "DEX", :opHex => "CA", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Decrement X (DEX)"},
        0xC6 => {:opName => "DEC", :opHex => "C6", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Decrement (DEC)"},
        0xD6 => {:opName => "DEC", :opHex => "D6", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Decrement (DEC)"},
        0xCE => {:opName => "DEC", :opHex => "CE", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Decrement (DEC)"},
        0xDE => {:opName => "DEC", :opHex => "DE", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Decrement (DEC)"},
        0x3A => {:opName => "DEC", :opHex => "3A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Decrement (DEC)"},
        0x49 => {:opName => "EOR", :opHex => "49", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x45 => {:opName => "EOR", :opHex => "45", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x55 => {:opName => "EOR", :opHex => "55", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x52 => {:opName => "EOR", :opHex => "52", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x41 => {:opName => "EOR", :opHex => "41", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x51 => {:opName => "EOR", :opHex => "51", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x4D => {:opName => "EOR", :opHex => "4D", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x5D => {:opName => "EOR", :opHex => "5D", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0x59 => {:opName => "EOR", :opHex => "59", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Exclusive OR Accumulator with Memory (EOR)"},
        0xE6 => {:opName => "INC", :opHex => "E6", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Increment (INC)"},
        0xF6 => {:opName => "INC", :opHex => "F6", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Increment (INC)"},
        0xEE => {:opName => "INC", :opHex => "EE", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Increment (INC)"},
        0xFE => {:opName => "INC", :opHex => "FE", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Increment (INC)"},
        0x1A => {:opName => "INC", :opHex => "1A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Increment (INC)"},
        0xE8 => {:opName => "INX", :opHex => "E8", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Increment X (INX)"},
        0x88 => {:opName => "DEY", :opHex => "88", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Decrement Y (DEY)"},
        0xC8 => {:opName => "INY", :opHex => "C8", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Increment Y (INY)"},
        0x4C => {:opName => "JMP", :opHex => "4C", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Jump (JMP)"},
        0x6C => {:opName => "JMP", :opHex => "6C", :opLen => 3, :opSyntax => '($hhll)', :opBytes => "ll hh", :opDesc => "Jump (JMP)"},
        0x7C => {:opName => "JMP", :opHex => "7C", :opLen => 3, :opSyntax => '($hhll,X)', :opBytes => "ll hh", :opDesc => "Jump (JMP)"},
        0x20 => {:opName => "JSR", :opHex => "20", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Jump to Subroutine (JSR)"},
        0xA9 => {:opName => "LDA", :opHex => "A9", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xA5 => {:opName => "LDA", :opHex => "A5", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xB5 => {:opName => "LDA", :opHex => "B5", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xB2 => {:opName => "LDA", :opHex => "B2", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xA1 => {:opName => "LDA", :opHex => "A1", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xB1 => {:opName => "LDA", :opHex => "B1", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xAD => {:opName => "LDA", :opHex => "AD", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xBD => {:opName => "LDA", :opHex => "BD", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xB9 => {:opName => "LDA", :opHex => "B9", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Load Accumulator from Memory (LDA)"},
        0xA2 => {:opName => "LDX", :opHex => "A2", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Load X Register from Memory (LDX)"},
        0xA6 => {:opName => "LDX", :opHex => "A6", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Load X Register from Memory (LDX)"},
        0xB6 => {:opName => "LDX", :opHex => "B6", :opLen => 2, :opSyntax => '$ZZ,Y', :opBytes => "ZZ", :opDesc => "Load X Register from Memory (LDX)"},
        0xAE => {:opName => "LDX", :opHex => "AE", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Load X Register from Memory (LDX)"},
        0xBE => {:opName => "LDX", :opHex => "BE", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Load X Register from Memory (LDX)"},
        0xA0 => {:opName => "LDY", :opHex => "A0", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Load Y Register from Memory (LDY)"},
        0xA4 => {:opName => "LDY", :opHex => "A4", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Load Y Register from Memory (LDY)"},
        0xB4 => {:opName => "LDY", :opHex => "B4", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Load Y Register from Memory (LDY)"},
        0xAC => {:opName => "LDY", :opHex => "AC", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Load Y Register from Memory (LDY)"},
        0xBC => {:opName => "LDY", :opHex => "BC", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Load Y Register from Memory (LDY)"},
        0x46 => {:opName => "LSR", :opHex => "46", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Logical Shift Memory or Accumulator Right (LSR)"},
        0x56 => {:opName => "LSR", :opHex => "56", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Logical Shift Memory or Accumulator Right (LSR)"},
        0x4E => {:opName => "LSR", :opHex => "4E", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Logical Shift Memory or Accumulator Right (LSR)"},
        0x5E => {:opName => "LSR", :opHex => "5E", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Logical Shift Memory or Accumulator Right (LSR)"},
        0x4A => {:opName => "LSR", :opHex => "4A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Logical Shift Memory or Accumulator Right (LSR)"},
        0x09 => {:opName => "ORA", :opHex => "09", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x05 => {:opName => "ORA", :opHex => "05", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x15 => {:opName => "ORA", :opHex => "15", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x12 => {:opName => "ORA", :opHex => "12", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x01 => {:opName => "ORA", :opHex => "01", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x11 => {:opName => "ORA", :opHex => "11", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x0D => {:opName => "ORA", :opHex => "0D", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x1D => {:opName => "ORA", :opHex => "1D", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Or Accumulator with Memory (ORA)"},
        0x19 => {:opName => "ORA", :opHex => "19", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Or Accumulator with Memory (ORA)"},
        0xEA => {:opName => "NOP", :opHex => "EA", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "No Operation (NOP)"},
        0x48 => {:opName => "PHA", :opHex => "48", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Push Accumulator (PHA)"},
        0x08 => {:opName => "PHP", :opHex => "08", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Push Processor Status Register (PHP)"},
        0xDA => {:opName => "PHX", :opHex => "DA", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Push X Register (PHX)"},
        0x5A => {:opName => "PHY", :opHex => "5A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Push Y Register (PHY)"},
        0x68 => {:opName => "PLA", :opHex => "68", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Pull Accumulator (PLA)"},
        0x28 => {:opName => "PLP", :opHex => "28", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Pull Processor Status Register (PLP)"},
        0xFA => {:opName => "PLX", :opHex => "FA", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Pull X Register (PLX)"},
        0x7A => {:opName => "PLY", :opHex => "7A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Pull Y Register (PLY)"},
        0x26 => {:opName => "ROL", :opHex => "26", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Rotate Memory or Accumulator Left (ROL)"},
        0x36 => {:opName => "ROL", :opHex => "36", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Rotate Memory or Accumulator Left (ROL)"},
        0x2E => {:opName => "ROL", :opHex => "2E", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Rotate Memory or Accumulator Left (ROL)"},
        0x3E => {:opName => "ROL", :opHex => "3E", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Rotate Memory or Accumulator Left (ROL)"},
        0x2A => {:opName => "ROL", :opHex => "2A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Rotate Memory or Accumulator Left (ROL)"},
        0x07 => {:opName => "RMB0", :opHex => "07", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB0)"},
        0x17 => {:opName => "RMB1", :opHex => "17", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB1)"},
        0x27 => {:opName => "RMB2", :opHex => "27", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB2)"},
        0x37 => {:opName => "RMB3", :opHex => "37", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB3)"},
        0x47 => {:opName => "RMB4", :opHex => "47", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB4)"},
        0x57 => {:opName => "RMB5", :opHex => "57", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB5)"},
        0x67 => {:opName => "RMB6", :opHex => "67", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB6)"},
        0x77 => {:opName => "RMB7", :opHex => "77", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Reset Memory Bit i (RMB7)"},
        0x66 => {:opName => "ROR", :opHex => "66", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Rotate Memory or Accumulator Right (ROR)"},
        0x76 => {:opName => "ROR", :opHex => "76", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Rotate Memory or Accumulator Right (ROR)"},
        0x6E => {:opName => "ROR", :opHex => "6E", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Rotate Memory or Accumulator Right (ROR)"},
        0x7E => {:opName => "ROR", :opHex => "7E", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Rotate Memory or Accumulator Right (ROR)"},
        0x6A => {:opName => "ROR", :opHex => "6A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Rotate Memory or Accumulator Right (ROR)"},
        0x40 => {:opName => "RTI", :opHex => "40", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Return from Interrupt (RTI)"},
        0x60 => {:opName => "RTS", :opHex => "60", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Return from Subroutine (RTS)"},
        0x22 => {:opName => "SAX", :opHex => "22", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Swap Accumulator and X Register (SAX)"},
        0x42 => {:opName => "SAY", :opHex => "42", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Swap Accumulator and Y Register (SAY)"},
        0xE9 => {:opName => "SBC", :opHex => "E9", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xE5 => {:opName => "SBC", :opHex => "E5", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xF5 => {:opName => "SBC", :opHex => "F5", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xF2 => {:opName => "SBC", :opHex => "F2", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xE1 => {:opName => "SBC", :opHex => "E1", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xF1 => {:opName => "SBC", :opHex => "F1", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xED => {:opName => "SBC", :opHex => "ED", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xFD => {:opName => "SBC", :opHex => "FD", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xF9 => {:opName => "SBC", :opHex => "F9", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Subtract with Borrow from Accumulator (SBC)"},
        0xF8 => {:opName => "SED", :opHex => "F8", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Set Decimal Mode Flag (SED)"},
        0x38 => {:opName => "SEC", :opHex => "38", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Set Carry Flag (SEC)"},
        0x78 => {:opName => "SEI", :opHex => "78", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Set Interrupt Disable Flag (SEI)"},
        0xF4 => {:opName => "SET", :opHex => "F4", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Set T Flag (SET)"},
        0x03 => {:opName => "ST0", :opHex => "03", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Store HuC6270 No. 0 (ST0)"},
        0x13 => {:opName => "ST1", :opHex => "13", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Store HuC6270 No. 1 (ST1)"},
        0x23 => {:opName => "ST2", :opHex => "23", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Store HuC6270 No. 2 (ST2)"},
        0x87 => {:opName => "SMB0", :opHex => "87", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB0)"},
        0x97 => {:opName => "SMB1", :opHex => "97", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB1)"},
        0xA7 => {:opName => "SMB2", :opHex => "A7", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB2)"},
        0xB7 => {:opName => "SMB3", :opHex => "B7", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB3)"},
        0xC7 => {:opName => "SMB4", :opHex => "C7", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB4)"},
        0xD7 => {:opName => "SMB5", :opHex => "D7", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB5)"},
        0xE7 => {:opName => "SMB6", :opHex => "E7", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB6)"},
        0xF7 => {:opName => "SMB7", :opHex => "F7", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Set Memory Bit i (SMB7)"},
        0x85 => {:opName => "STA", :opHex => "85", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Store Accumulator to Memory (STA)"},
        0x95 => {:opName => "STA", :opHex => "95", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Store Accumulator to Memory (STA)"},
        0x92 => {:opName => "STA", :opHex => "92", :opLen => 2, :opSyntax => '($ZZ)', :opBytes => "ZZ", :opDesc => "Store Accumulator to Memory (STA)"},
        0x81 => {:opName => "STA", :opHex => "81", :opLen => 2, :opSyntax => '($ZZ,X)', :opBytes => "ZZ", :opDesc => "Store Accumulator to Memory (STA)"},
        0x91 => {:opName => "STA", :opHex => "91", :opLen => 2, :opSyntax => '($ZZ),Y', :opBytes => "ZZ", :opDesc => "Store Accumulator to Memory (STA)"},
        0x8D => {:opName => "STA", :opHex => "8D", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Store Accumulator to Memory (STA)"},
        0x9D => {:opName => "STA", :opHex => "9D", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Store Accumulator to Memory (STA)"},
        0x99 => {:opName => "STA", :opHex => "99", :opLen => 3, :opSyntax => '$hhll,Y', :opBytes => "ll hh", :opDesc => "Store Accumulator to Memory (STA)"},
        0x86 => {:opName => "STX", :opHex => "86", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Store X Register to Memory (STX)"},
        0x96 => {:opName => "STX", :opHex => "96", :opLen => 2, :opSyntax => '$ZZ,Y', :opBytes => "ZZ", :opDesc => "Store X Register to Memory (STX)"},
        0x8E => {:opName => "STX", :opHex => "8E", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Store X Register to Memory (STX)"},
        0x84 => {:opName => "STY", :opHex => "84", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Store Y Register to Memory (STY)"},
        0x94 => {:opName => "STY", :opHex => "94", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Store Y Register to Memory (STY)"},
        0x8C => {:opName => "STY", :opHex => "8C", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Store Y Register to Memory (STY)"},
        0x64 => {:opName => "STZ", :opHex => "64", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Store Zero to Memory (STZ)"},
        0x74 => {:opName => "STZ", :opHex => "74", :opLen => 2, :opSyntax => '$ZZ,X', :opBytes => "ZZ", :opDesc => "Store Zero to Memory (STZ)"},
        0x9C => {:opName => "STZ", :opHex => "9C", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Store Zero to Memory (STZ)"},
        0x9E => {:opName => "STZ", :opHex => "9E", :opLen => 3, :opSyntax => '$hhll,X', :opBytes => "ll hh", :opDesc => "Store Zero to Memory (STZ)"},
        0x02 => {:opName => "SXY", :opHex => "02", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Swap X and Y Registers (SXY)"},
        0x53 => {:opName => "TAM", :opHex => "53", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Transfer Accumulator to MPRi (TAM)"},
        0xAA => {:opName => "TAX", :opHex => "AA", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Transfer Accumulator to X Register (TAX)"},
        0xA8 => {:opName => "TAY", :opHex => "A8", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Transfer Accumulator to Y Register (TAY)"},
        0xF3 => {:opName => "TAI", :opHex => "F3", :opLen => 7, :opSyntax => '$SHSL,$DHDL,$LHLL', :opBytes => "SL SH DL DH LL LH", :opDesc => "Transfer Alternate Increment (TAI)"},
        0xE3 => {:opName => "TIA", :opHex => "E3", :opLen => 7, :opSyntax => '$SHSL,$DHDL,$LHLL', :opBytes => "SL SH DL DH LL LH", :opDesc => "Transfer Increment Alternate (TIA)"},
        0xC3 => {:opName => "TDD", :opHex => "C3", :opLen => 7, :opSyntax => '$SHSL,$DHDL,$LHLL', :opBytes => "SL SH DL DH LL LH", :opDesc => "Transfer Decrement Decrement (TDD)"},
        0xD3 => {:opName => "TIN", :opHex => "D3", :opLen => 7, :opSyntax => '$SHSL,$DHDL,$LHLL', :opBytes => "SL SH DL DH LL LH", :opDesc => "Transfer Increment None (TIN)"},
        0x73 => {:opName => "TII", :opHex => "73", :opLen => 7, :opSyntax => '$SHSL,$DHDL,$LHLL', :opBytes => "SL SH DL DH LL LH", :opDesc => "Transfer Increment Increment (TII)"},
        0x43 => {:opName => "TMA", :opHex => "43", :opLen => 2, :opSyntax => '#$nn', :opBytes => "nn", :opDesc => "Transfer MPRi to Accumulator (TMA)"},
        0x14 => {:opName => "TRB", :opHex => "14", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Test and Reset Memory Bits Against Accumulator (TRB)"},
        0x1C => {:opName => "TRB", :opHex => "1C", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Test and Reset Memory Bits Against Accumulator (TRB)"},
        0x04 => {:opName => "TSB", :opHex => "04", :opLen => 2, :opSyntax => '$ZZ', :opBytes => "ZZ", :opDesc => "Test and Set Memory Bits Against Accumulator (TSB)"},
        0x0C => {:opName => "TSB", :opHex => "0C", :opLen => 3, :opSyntax => '$hhll', :opBytes => "ll hh", :opDesc => "Test and Set Memory Bits Against Accumulator (TSB)"},
        0x83 => {:opName => "TST", :opHex => "83", :opLen => 3, :opSyntax => '#$nn,ZZ', :opBytes => "nn ZZ", :opDesc => "Test and Reset Memory Bits (TST)"},
        0xA3 => {:opName => "TST", :opHex => "A3", :opLen => 3, :opSyntax => '#$nn,ZZ,X', :opBytes => "nn ZZ", :opDesc => "Test and Reset Memory Bits (TST)"},
        0x93 => {:opName => "TST", :opHex => "93", :opLen => 4, :opSyntax => '#$nn,$hhll', :opBytes => "nn ll hh", :opDesc => "Test and Reset Memory Bits (TST)"},
        0xB3 => {:opName => "TST", :opHex => "B3", :opLen => 4, :opSyntax => '#$nn,$hhll,X', :opBytes => "nn ll hh", :opDesc => "Test and Reset Memory Bits (TST)"},
        0xBA => {:opName => "TSX", :opHex => "BA", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Transfer Stack Pointer to X Register (TSX)"},
        0x8A => {:opName => "TXA", :opHex => "8A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Transfer X Register to Accumulator (TXA)"},
        0x98 => {:opName => "TYA", :opHex => "98", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Transfer Y Register to Accumulator (TYA)"},
        0x9A => {:opName => "TXS", :opHex => "9A", :opLen => 1, :opSyntax => nil, :opBytes => nil, :opDesc => "Transfer X Register to Stack Pointer (TXS)"}}

def describe_ops(decLine)
  # add some code to add comments to decompiled lines
end

def disassemble(bytes, start_offset, defines = [])
  current_offset = 0
  op_lines = Hash.new
  while current_offset < bytes.size
    op_offset = current_offset + start_offset
    op = @ops[bytes[current_offset]]
    if op.nil?
      printf "Unknown opcode 0x%02X at offset 0x%04X! exiting...", bytes[current_offset], current_offset
      exit
    end
    decLine = op[:opName]
    op_lines[op_offset] = Hash.new
    op_lines[op_offset][:op] = op[:opName]
    current_offset += 1
    decString = String.new
    if op[:opLen] > 1
      opBytes = Hash.new
      op[:opBytes].split(" ").each do |b|
        opBytes[b] = "%02X" % bytes[current_offset]
        add = 0
        if b == "rr"
          add = 1 if op[:opBytes].split(" ").size > 1
          if bytes[current_offset] < 0x80
            jmpOffset = op_offset + bytes[current_offset] + 2 + add
          else
            jmpOffset = op_offset - (0xff - bytes[current_offset]) + 1 + add
          end
          op_lines[op_offset][:jump] = jmpOffset
          opBytes["hhll"] = "%04X" % jmpOffset
        end
        current_offset += 1
      end
      if op[:opHex] == "20" || op[:opHex] == "4C" # calculate direct jumps
        op_lines[op_offset][:jump] = (opBytes["hh"] + opBytes["ll"]).to_i(16)
      end
      decString = op[:opSyntax]
      opBytes.keys.each do |k|
        decString = decString.gsub(k, opBytes[k])
      end
      op_lines[op_offset][:arg] = decString
    end
  end
  op_lines.select {|k, v| !v[:jump].nil?}.each do |i|
    label = "_lb" + ("%04x" % i[1][:jump])
    if !op_lines[i[1][:jump]].nil?
      op_lines[i[1][:jump]][:label] = label
      op_lines[i[0]][:link] = label
    else
      i[1][:jump] = nil
    end
  end
  start = "start: 0x" + "%04X" % start_offset
  result_line = []
  op_lines.each do |i|
    dec_line = String.new
    dec_line += "\t" + i[1][:op]
    if !i[1][:jump].nil?
      if i[1][:arg].include?(",")
        dec_line += " " + i[1][:arg].split(",")[0] + "," + i[1][:link]
      else
        dec_line += " " + i[1][:link]
      end
    elsif !i[1][:arg].nil?
      dec_line += " " + i[1][:arg]
    end
    dec_line = i[1][:label] + ":\n" + dec_line unless i[1][:label].nil?
    result_line.push(dec_line)
  end
  vars = {}
  defines.each do |fname|
    lines = File.readlines(fname)
    lines.each do |line|
      next if line.match(/^\s*;/)
      line.gsub!(/\s*;.+$/, '')
      m = line.match(/^%define\s+([a-zA-Z0-9_]+)\s+(.+?)\r?\n?$/)
      if m
        name, value = m.captures
        vars[value] = {:name => name, :fname => fname}
      end
    end
  end
  includes = {}
  result_line.each do |line|
    next if line.include?('#$')
    vars.each do |v, d|
      if line.gsub!(v, d[:name]) != nil
        includes[d[:fname]] = true
      end
    end
  end
  includes.each do |fname, x|
    line = '%include "' + fname + '"'
    result_line.unshift(line)
  end
  result_line.unshift(start)
  result_line.join("\n")
end

def preprocess_includes(source, includedirs)
  result = []
  source.each do |line|
    if line.match(/^\s*;/)
      next
    end
    line = line.split(';')[0]
    line.gsub!(/\s+$/, '')
    m = line.match(/^%include\s+"?(.+?)"?\r?\n?$/)
    if m
      fname = m.captures[0]
      lines = []
      includedirs.each do |dir|
        dir.gsub!('\\', '/')
        include_file = File.join(dir, fname)
        if File.exist?(include_file)
          lines = preprocess_includes(File.readlines(include_file), includedirs)
          break
        end
      end
      if lines.length == 0
        puts "Can't find #include file " + fname
        exit
      end
      result += lines
    else
      result.push(line)
    end
  end
  result
end

# простой трехпроходной препроцессор
# 1. обрабатываем инклюды
# 2. собираем макросы
# 3. раскрываем макросы
def expand_macro(source, includedirs)
  source = preprocess_includes(source, includedirs)
  parsed = []
  vars = {}
  source.each do |line|
    m = line.match(/^%define\s+([a-zA-Z0-9_]+)\s+(.+?)\r?\n?$/)
    if m
      name, value = m.captures
      vars[name] = value
      next
    end
    parsed.push(line)
  end
  parsed.each do |line|
    vars.each do |k, v|
      line.gsub!(k, v)
    end
  end
  parsed
end

def parse_db(line)
  line = line.gsub(/\t?\.db\s+/, '').chomp
  if line[0] == '"'
    line.gsub(/^"/, '').gsub('\n', "\n").gsub('\0', "\0").chomp.gsub(/"$/, '').bytes
  else
    line.split(/,\s*/).map {|s| s.gsub(/#?\$?/, '').to_i(16)}
  end
end

def assemble(source, includedirs = ['./'])
  source = expand_macro(source, includedirs)
  unless source[0].include?("start: 0x")
    puts "Absent or incorrect start: label. Exiting."
    exit
  end
  start_offset = source[0].split(";")[0].strip.split(":")[1].to_i(16)
  if start_offset.nil? || start_offset > 0xffff
    puts "Incorrect start offset. Exiting."
    exit
  end
  opcodes = (@ops.group_by {|line| line[1][:opName]})
  lines = Array.new
  label = nil
  current_offset = start_offset
  source[1..(source.size - 1)].each do |line|
    if line[0] == "\t"
      # сделаем поддержку битовых литералов вида #%00110101
      line = line.gsub(/%([01]{8})/) {|x| '$' + x.gsub('%', '').to_i(2).to_s(16)}
      line_data = Hash.new
      raw = false
      if line.include? ".db"
        line_data = {:argBin => parse_db(line), :offset => current_offset}
        line_data[:len] = line_data[:argBin].length
        current_offset += line_data[:len]
        raw = true
      else
        op_line = line.split(";")[0].strip.split(" ")
        op_line = [op_line[0], (op_line[1..(op_line.size - 1)].join)] if op_line.size > 2
        line_data[:offset] = current_offset
        line_data[:op] = op_line[0].strip.upcase
        if op_line[1].nil?
          line_data[:arg] = nil
        elsif op_line[1].include?("_")
          tmp_args = op_line[1].split(",")
          if tmp_args.size > 1
            line_data[:arg] = tmp_args[0].upcase
            line_data[:link] = op_line[1].split(",")[1]
          else
            line_data[:arg] = nil
            line_data[:link] = op_line[1]
          end
        else
          line_data[:arg] = op_line[1].upcase
        end
      end

      unless label.nil?
        line_data[:label] = label
        label = nil
      end
      if !raw && !line_data[:arg].nil? && line_data[:link].nil?
        opdata = opcodes[line_data[:op]].select {|u| u[1][:opLen] > 1}
        opcode = opdata.select {|u| (u[1][:opSyntax].delete "h,l,n,D,H,L,S,Z") == (line_data[:arg].delete "0-9,A-F") && (u[1][:opSyntax].delete '$#(),X,Y').length == (line_data[:arg].delete '$#(),X,Y').length}
        if opcode.size != 1
          printf "Error finding opcode for line %s! Exiting.\n", line
          exit
        end
        args = line_data[:arg].delete '$#(),X,Y'
        mask = opcode[0][1][:opSyntax].delete '$#(),X,Y'
        arg_bytes = Array.new
        arg_names = Hash.new
        (mask.length / 2).times do |i|
          name = mask[i * 2] + mask[i * 2 + 1]
          arg_names[name] = (args[i * 2] + args[i * 2 + 1]).to_i(16)
        end
        opcode[0][1][:opBytes].split(" ").each do |i|
          if !arg_names[i].nil?
            arg_bytes.push arg_names[i]
          else
            if i == "rr"
              jmp_offset = (arg_names["hh"] << 8) + arg_names["ll"]
              if jmp_offset > line_data[:offset]
                arg_bytes.push ((jmp_offset - line_data[:offset]) - 3)
              else
                arg_bytes.push (0xff - (line_data[:offset] - jmp_offset) - 2)
              end
            else
              puts "Error parsing opcode! Exiting."
              exit
            end
          end
        end
        line_data[:opBin] = opcode[0][0]
        line_data[:argBin] = arg_bytes
        line_data[:len] = opcode[0][1][:opLen]
        current_offset += arg_bytes.size + 1
      elsif line_data[:link].nil? && line_data[:arg].nil? && !raw
        opcode = opcodes[line_data[:op]].select {|u| u[1][:opLen] == 1}
        line_data[:opBin] = opcode[0][0]
        line_data[:len] = opcode[0][1][:opLen]
        current_offset += line_data[:len]
      elsif !line_data[:link].nil? && !raw
        opcode = opcodes[line_data[:op]]
        opcode = opcode.select {|u| u[1][:opHex] == "4C"} if opcode.size > 1 && line_data[:op] == "JMP" # Shitty code!
        line_data[:opBin] = opcode[0][0]
        line_data[:len] = opcode[0][1][:opLen]
        current_offset += line_data[:len]
      else

      end
      lines.push line_data
    elsif line[0] == ";"
      # Commented line
    elsif line.include?(":")
      label = line.split(":")[0].strip
    else
      puts "Incorrect line: " + line.rstrip + ". Skipping."
    end
  end
  lines.select {|u| !u[:link].nil?}.each do |i|
    link_name = i[:link]
    high_byte = link_name.include?('#high')
    low_byte = link_name.include?('#low')
    if high_byte || low_byte
      link_name.gsub!(/#(high|low)\(/, '')
      link_name.gsub!(/\)/, '')
    end
    linked_line = lines.select {|n| n[:label] == link_name}
    if linked_line.size == 0
      puts "Label " + link_name + " links to nowhere! Exiting."
      exit
    end
    link_offset = linked_line[0][:offset]
    arg_bytes = Array.new
    if i[:len] == 2 || i[:op].include?("BB")
      add = 0
      unless i[:arg].nil?
        add = 1
        arg_bytes.push i[:arg].gsub('$', "").to_i(16)
      end
      if high_byte
        # поддержка сохранения только старшего байта ссылки #high(_link)
        arg_bytes.push((link_offset & 0xff00) >> 8)
      elsif low_byte
        # #low(_link)
        arg_bytes.push(link_offset & 0x00ff)
      elsif link_offset > i[:offset]
        arg_bytes.push ((link_offset - i[:offset]) - 2) - add
      else
        arg_bytes.push (0xff - (i[:offset] - link_offset) - 1) - add
      end
    elsif i[:len] == 3
      arg_bytes.push (link_offset & 0x00ff)
      arg_bytes.push ((link_offset & 0xff00) >> 8)
    else
      puts "Error in branching calculation. Exiting."
      exit
    end
    i[:argBin] = arg_bytes
  end
  assembled_bytes = Array.new
  lines.each do |l|
    assembled_bytes.push l[:opBin] unless l[:opBin].nil?
    assembled_bytes += l[:argBin] unless l[:argBin].nil?
  end
  assembled_bytes
end

def assemble_file(filename, includedirs = ['./'])
  lines = File.readlines(filename)
  first_line = lines[0]
  asm = assemble(lines, includedirs)
  start_offset = first_line.split(";")[0].strip.split(":")[1].to_i(16)
  [asm, start_offset]
end
