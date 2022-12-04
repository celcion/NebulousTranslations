puts
puts "Initial Hacks"
start_time = Time.now

require_relative 'common'

if File.file?(@emptySpaceCsvFile)
	File.delete(@emptySpaceCsvFile)
end

newFile = IO.binread(@originalROMPath).bytes

# JMP to cutscenes fonts parser
newFile[0xb114..0xb119] = [0x4e,0xf9,0x00,0x05,0x3f,0x20]

# Adjust coordinates and vars
valuesFile = CSV.read((@mainPath+"/Data/coordinates.csv"), :encoding => "utf-8", :headers => true, :col_sep => "\t")
valuesFile.each {|v| newFile[v["offset"].to_i(16)] = v["value"].to_i}

IO.binwrite(@patchedROMPath, newFile.pack('c*'))

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."

