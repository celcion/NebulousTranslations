puts
puts "Parse-Menus"
start_time = Time.now

require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/cpointersExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/cpointersImport.csv"

if mode == "export"
	exportArr = Array.new
	
	currentOffset = 0
	while currentOffset < (@romBytes.size-4)
		if (@romBytes[currentOffset] == 0x41 && @romBytes[currentOffset+1] == 0xf9 && @romBytes[currentOffset+6] == 0x61 && @romBytes[currentOffset+7] == 0) || (@romBytes[currentOffset] == 0x41 && @romBytes[currentOffset+1] == 0xf9 && @romBytes[currentOffset+6] == 0x4e && @romBytes[currentOffset+7] == 0xb9)
			if @romBytes[currentOffset+6] == 0x4e
				jumpTarget = bytesToNum(@romBytes[currentOffset+10..currentOffset+11],false)
			else
				jump = bytesToNum(@romBytes[currentOffset+8..currentOffset+9],false)
				if jump > 0x7fff
					jumpTarget = currentOffset - (0xffff - jump) + 7
				else
					jumpTarget = currentOffset + jump + 8
				end
			end
			if jumpTarget == 0xa339 || jumpTarget == 0xa33a || jumpTarget == 0xf244 || jumpTarget == 0xf262
				ptrOffset = currentOffset+2
				strOffset = bytesToNum(@romBytes[ptrOffset..ptrOffset+3],false)
				strBytes = Array.new
				currentStringOffset = strOffset
				while @romBytes[currentStringOffset] != 0
					strBytes.push @romBytes[currentStringOffset]
					currentStringOffset += 1
				end
				exportArr.push ({"ptrOffset" => ("%06X" % ptrOffset),\
								"strOffset" => ("%06X" % strOffset),\
								"size" => (strBytes.size+1),\
								"strBytes" => (strBytes.map{|b| "%02X" % b}.join(" ")),\
								"strText" => (decodeString strBytes),\
								"translation" => "" })
			end
		end
		currentOffset += 1
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	importArr.each do |cString|
		if cString["translation"].to_s.length > 0
			strBytes = encodeString cString["translation"]
			strBytes.push 0
			insertData(strBytes,cString["ptrOffset"].to_i(16))
		end
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
