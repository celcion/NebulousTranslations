puts
puts "ASM-Hacks"
start_time = Time.now

require_relative 'common'
require_relative 'Libs/asm_6280'

codeOffsets = [{:offset=>0x01e010,:start=>0x8000,:bytes=>248,:comment=>"two-lines"},{:offset=>0x023297,:start=>0xB287,:bytes=>193,:comment=>"tiles-load"}]

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
		insertOffset = aFile[1].to_i(16)
		compBytes.size.times {|i| @romBytes[insertOffset+i] = compBytes[i]}
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
