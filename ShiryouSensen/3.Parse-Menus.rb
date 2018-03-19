puts
puts "Parse-Menus"
start_time = Time.now

require "csv"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/menuExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/menuImport.csv"

if mode == "export"
    exportArr = Array.new
	0.upto(63) do |i|
		entryOffset = 0x03f63a+(i*8)
		strLength = @romBytes[entryOffset]
		strCount = @romBytes[entryOffset+1]
		strXpos = @romBytes[entryOffset+2]
		strYpos = @romBytes[entryOffset+3]
		strColor = @romBytes[entryOffset+4]
		ptrData = (@romBytes[entryOffset+6] + (@romBytes[entryOffset+7] << 8))
		if strLength > 4 && strXpos > 0 && ptrData != 17496
			#puts (strLength.to_s + " " + strCount.to_s + " " + strXpos.to_s + " " + strYpos.to_s + " " + strColor.to_s + " " + ("%04X" % ptrData))
			if ptrData > 0x4000 && ptrData < 0x6000
				strOffset = (ptrData + 0x034200)
			elsif ptrData > 0x6000 && ptrData < 0x8000
				strOffset = (ptrData + 0x06200)
			elsif ptrData > 0x8000 && ptrData < 0xa000
				strOffset = (ptrData + 0x036200)
			elsif ptrData > 0xc000 && ptrData < 0xe000
				strOffset = (ptrData - 0x9e00)
			end
			strByteArr = Array.new
			0.upto((strLength*strCount)-1) do |d|
				strByteArr.push @romBytes[strOffset+d]
			end
			
			exportArr.push ({ "entryOffset" => ("%08X" % entryOffset),\
					"strLength" => strLength,\
					"strCount" => strCount,\
					"strXpos" => strXpos,\
					"strYpos" => strYpos,\
					"strColor" => strColor,\
					"ptrBytes" => ("%04X" % ptrData),\
					"strOffset" => ("%08X" % strOffset),\
					"strSize" => strByteArr.size,\
					"strText" => (decodeMultiString(strByteArr,strLength,strCount)),\
					"translation" => "" })
			
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	importArr.each do |row|
		if !row["translation"].nil?
			#puts row["translation"]
			strBytes = encodeString(row["translation"],row["entryOffset"])
			entryOffset = row["entryOffset"].to_i(16)
			strOffset = row["strOffset"].to_i(16)
			if (strBytes.size-1) <= row["strSize"].to_i
				@romBytes[entryOffset] = row["strLength"].to_i
				@romBytes[entryOffset+1] = row["strCount"].to_i
				@romBytes[entryOffset+2] = row["strXpos"].to_i
				@romBytes[entryOffset+3] = row["strYpos"].to_i
				@romBytes[entryOffset+4] = row["strColor"].to_i
				@romBytes[entryOffset+6] = (row["ptrBytes"].to_i(16) & 0x00ff)
				@romBytes[entryOffset+7] = ((row["ptrBytes"].to_i(16) & 0xff00) >> 8)
				0.upto(strBytes.size-2) { |i| @romBytes[i+strOffset] = strBytes[i] }
				if entryOffset == 0x03f812
					strBytes -= [0x70]
					0.upto(strBytes.size-11) { |i| @romBytes[i+0x0397e2] = strBytes[i] }
				end
			else
				puts ("String at offset " + row["strOffset"] + " is too long (longer by " + (strBytes.size - (row["strSize"].to_i) - 1).to_s + " bytes), skipping...")
			end
		end
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
