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
	menus =  [{"name" => "options", "offset" => 0x03d381, "shift" => 0x030010, "count" => 9},
				{"name" => "roulette", "offset" => 0x034664, "shift" => 0x02a010, "count" => 4}]
	menus.each do |menu|
		ptrTableOffset = menu["offset"]
		menu["count"].times do |t|
			ptrOffset = ptrTableOffset + (t*2)
			ptrData = (@romBytes[ptrOffset] + (@romBytes[ptrOffset+1] << 8))
			menuSetOffset = ptrData + menu["shift"]
			currentOffset = menuSetOffset
			while @romBytes[currentOffset] != 0xff && @romBytes[currentOffset+1] != 0xff
				linePos = (@romBytes[currentOffset] + (@romBytes[currentOffset+1] << 8))
				linePtr = (@romBytes[currentOffset+2] + (@romBytes[currentOffset+3] << 8))
				lineOffset = linePtr + menu["shift"]
				lineCurrentOffset = lineOffset
				lineBytes = Array.new
				while @romBytes[lineCurrentOffset] != 0xff
					lineBytes.push @romBytes[lineCurrentOffset]
					lineCurrentOffset += 1
				end
				exportArr.push ({ "name" => menu["name"],\
							  "ptrOffset" => ("%08X" % ptrOffset),\
							  "ptrBytes" => ("%04X" % ptrData),\
							  "ptrShift" => ("%08X" % menu["shift"]),\
							  "mapLineOffset" => ("%08X" % menuSetOffset),\
							  "mapLineEntryOffset" => ("%08X" % currentOffset),\
							  "mapLineAddr" => ("%04X" % linePos),\
							  "lineOffset" => ("%08X" % lineOffset),\
							  "lineBytes" => (lineBytes.join(" ")),\
							  "lineSetPtr" => "",\
							  "lineText" => (decodeString lineBytes),\
							  "translation" => "" })
				currentOffset += 4
			end
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	linesDict = Hash.new
	groupArr = (importArr.group_by{|line| line["name"]})
	groupArr.each do |menu|
		strsOffset = menu[1][0]["lineOffset"].to_i(16)
		ptrShift = menu[1][0]["ptrShift"].to_i(16)
		startOffset = strsOffset - ptrShift
		strs = Array.new
		
		if menu[1][0]["name"] == "options"
			bytesLimit = 60
		elsif menu[1][0]["name"] == "roulette"
			bytesLimit = 212
		end
		
		currentOffset = startOffset
		menu[1].each do |row|
			ptrOffset = row["mapLineEntryOffset"].to_i(16) + 2
			if row["translation"].nil? || row["translation"].length == 0
				strBytes = row["strBytes"].split(" ").map {|b| b.to_i}
				strBytes.push 0xff
			else
				strBytes = encodeString row["translation"]
				if strBytes.size > 5 && row["name"] == "options"
					puts "The line '" + row["translation"] + "' is too long! Cut at least " + (strBytes.size - 5).to_s + " bytes."
				end
			end
			if row["lineSetPtr"].nil? || row["lineSetPtr"].length == 0
				if linesDict[strBytes].nil?
					ptr = (currentOffset & 0x00ff), ((currentOffset & 0xff00) >> 8)
					linesDict[strBytes] = ptr
					strs += strBytes
					@romBytes[ptrOffset] = ptr[0]
					@romBytes[ptrOffset+1] = ptr[1]
					currentOffset += strBytes.size
				else
					@romBytes[ptrOffset] = linesDict[strBytes][0]
					@romBytes[ptrOffset+1] = linesDict[strBytes][1]
				end
			else
				ptrData = row["lineSetPtr"].to_i(16)
				@romBytes[ptrOffset] = (ptrData & 0x00ff)
				@romBytes[ptrOffset+1] = ((ptrData & 0xff00) >> 8)
				insertOffset = ptrData + ptrShift
				strBytes.size.times {|i| @romBytes[i+insertOffset] = strBytes[i]}
			end
		end
		#puts "%02X" % strs.size
		if strs.size <= bytesLimit
			strs.size.times {|i| @romBytes[i+strsOffset] = strs[i]}
		else
			puts "Size of main block is too big! Cut at least " + (strs.size - bytesLimit).to_s + " bytes."
		end
	
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
