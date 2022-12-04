puts
puts "ASM-Hacks"
start_time = Time.now

require_relative 'common'

# {:offset=>0x00965c,:bytes=>208,:comment=>"scene-decompression"}
codeOffsets =  [{:offset=>0x008126,:bytes=>50,:comment=>"checksum-check"},
				{:offset=>0x00f6cc,:bytes=>1162,:comment=>"stats-menu"},
				{:offset=>0x00cf82,:bytes=>176,:comment=>"menu-hack"},
				{:offset=>0x00d0fc,:bytes=>70,:comment=>"menu-hack-add"}]

mode = "import" # export, import

if mode == "export"
	codeOffsets.each do |o|
		fileName = @mainPath + "/ASM_Export/" + o[:comment] + "_0x%08x" % o[:offset] + "_0x%04x" % o[:bytes] + ".asm"
		stdin, stdout, stderr = Open3.popen3(@vdaPath + ' "' + @originalROMPath + '" ' + ("0x%06x" % o[:offset]) + ' ' + ("0x%06x" % (o[:offset] + o[:bytes])) )
		decData = stdout.read.to_s.split("\n").map {|s| "\t" + s[36..-1].gsub("0x","$")}.join("\n")
		decData = "\torg $" + ("%08x" % o[:offset]) + "\nstart:\n" + decData
		File.write(fileName, decData)
	end
elsif mode == "import"
	Dir[@mainPath + "/ASM_Import/*.asm"].each do |f|
		aFile = f.split("/").last.split(".")[0].split("_")
		sizeLimit = aFile[2].to_i(16)
		insertOffset = aFile[1].to_i(16)
		tempAsm = @tempPath+"tmpAsm.bin"
		stdin, stdout, stderr = Open3.popen3(@vasmPath + ' -no-opt -Fbin -o "' + tempAsm + '" "' + f + '"')
		error = stderr.read.to_s
		if error.length > 0
			puts "Error assembling file '" + f + "', error:\n" + error
		elsif !File.file?(tempAsm)
			puts "Compiled file not found!"
		else
			compBytes = IO.binread(tempAsm).bytes
			if sizeLimit == 0
				compBytes.size.times {|i| @romBytes[insertOffset+i] = compBytes[i]}
			elsif compBytes.size > sizeLimit
				puts "Assembled data for file '" + f + "' is too big!"
			else
				while compBytes.size < sizeLimit
					compBytes.push 0x4e
					compBytes.push 0x71
				end
				compBytes.size.times {|i| @romBytes[insertOffset+i] = compBytes[i]}
			end
		end
		#FileUtils.rm_f(tempAsm)
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
