puts
puts "ASM-Hacks"
start_time = Time.now

require_relative 'common'
require_relative 'Libs/asm_6280'

codeOffsets =  [{:offset=>0x03fe4d,:start=>0xfe3d,:bytes=>19,:comment=>"stat-name"},
				{:offset=>0x03fe68,:start=>0xfe58,:bytes=>38,:comment=>"stat-number"},
				{:offset=>0x03f66d,:start=>0xf65d,:bytes=>125,:comment=>"items-load"},
				{:offset=>0x03f8fd,:start=>0xf8ed,:bytes=>132,:comment=>"inventory-load"},
				{:offset=>0x03f9f6,:start=>0xf9e6,:bytes=>150,:comment=>"inventory-list"},
				{:offset=>0x03539f,:start=>0xb38f,:bytes=>117,:comment=>"trainings-load"},
				{:offset=>0x03fe8e,:start=>0xfe7e,:bytes=>22,:comment=>"items-message"},
				{:offset=>0x03fea6,:start=>0xfe96,:bytes=>20,:comment=>"inventory-message"},
				{:offset=>0x03d156,:start=>0xd146,:bytes=>31,:comment=>"goals"},
				{:offset=>0x03d1b1,:start=>0xd1a1,:bytes=>27,:comment=>"gender"},
				{:offset=>0x034c53,:start=>0xac43,:bytes=>138,:comment=>"cities-list"},
				{:offset=>0x03fd5d,:start=>0xfd4d,:bytes=>58,:comment=>"message-parse"}]

mode = "import" # export, import

if mode == "export"
	codeOffsets.each do |o|
		bytes = @romBytes[o[:offset]..(o[:offset]+o[:bytes]-1)]
		decData = disassemble(bytes,o[:start])
		fileName = @mainPath + "/ASM_Export/" + o[:comment] + "_0x%08x" % o[:offset] + "_0x%04x" % o[:bytes] + ".asm"
		File.write(fileName, decData)
	end
elsif mode == "import"
	Dir[@mainPath + "/ASM_Import/*.asm"].each do |f|
		aFile = f.split("/").last.split(".")[0].split("_")
		source = File.open(f).readlines
		compBytes = assemble(source)
		while compBytes.size < aFile[2].to_i(16)
			compBytes.push 0x00
		end
		#puts compBytes.size
		insertOffset = aFile[1].to_i(16)
		insertSize = aFile[2].to_i(16)
		if insertSize > 0
			if compBytes.size > insertSize
				puts "Compiled size for '" + aFile[0] + "' is bigger than specified! Cut at least " + (compBytes.size - insertSize).to_s + " bytes."
			else
				while compBytes.size < insertSize
					compBytes.push 0xff
				end
				compBytes.size.times {|i| @romBytes[insertOffset+i] = compBytes[i]}
			end
		else
			compBytes.size.times {|i| @romBytes[insertOffset+i] = compBytes[i]}
		end
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
