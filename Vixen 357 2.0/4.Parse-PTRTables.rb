puts
puts "Parse-PTRTables"
start_time = Time.now

require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/ptrTablesExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/ptrTablesImport.csv"


if mode == "export"
	exportArr = Array.new
	
	ptrTable = [{:offset=>0x0102bc,:entries=>32,:size=>285,:comment=>"Battle conditions"},
                {:offset=>0x048706,:entries=>36,:size=>329,:comment=>"Character names"},
				{:offset=>0x0488e0,:entries=>44,:size=>356,:comment=>"Unit names"}]
	
	ptrTable.each do |table|
		table[:entries].times do |ptr|
			ptrOffset = table[:offset] + ptr * 4
			strOffset = bytesToNum(@romBytes[ptrOffset..ptrOffset+3],false)
			strBytes = Array.new
			currentOffset = strOffset
			while @romBytes[currentOffset] != 0
				strBytes.push @romBytes[currentOffset]
				currentOffset += 1
			end
			exportArr.push ({ 	"table" => table[:comment],\
								"ptrOffset" => ("%06X" % ptrOffset),\
								"strOffset" => ("%06X" % strOffset),\
								"size" => table[:size],\
								"strBytes" => (strBytes.map{|b| "%02X" % b}.join(" ")),\
								"strText" => (decodeString strBytes),\
								"translation" => "" })
		end
	end
	
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	
	groupTables = (importArr.group_by{|line| line["table"]})
	groupTables.each do |table|
		blockSize = table[1][0]["size"].to_i
		ptrs = Array.new
		strs = Array.new
		linesDict = Hash.new
		ptrsOffset = table[1][0]["ptrOffset"].to_i(16)
		startOffset = table[1][0]["strOffset"].to_i(16)
		blockSize.times {|t| @romBytes[startOffset+t] = 0xff}
		table[1].each do |tableLine|
			if tableLine["translation"].to_s.length > 0
				strBytes = encodeString tableLine["translation"]
			else
				strBytes = tableLine["strBytes"].split(" ").map{|b| b.to_i(16)}
			end
			strBytes.push 0
			if linesDict[strBytes].nil?
				if (strs + strBytes).size <= blockSize
					ptr = numToBytes((startOffset + strs.size),4,false)
					linesDict[strBytes] = ptr
					strs += strBytes
					ptrs += ptr
				else
					#puts "Can't apped line '" + tableLine["table"] + ": " + tableLine["strOffset"] + "' to the main block! Using extended space"
					extraOffset = getSpace strBytes.size
					if extraOffset.nil?
						puts "Can't get external space to insert data!"
					else
						ptr = numToBytes(extraOffset,4,false)
						linesDict[strBytes] = ptr
						ptrs += ptr
						strBytes.size.times {|i| @romBytes[extraOffset+i] = strBytes[i]}
					end
				end
			else
				ptrs += linesDict[strBytes]
			end
		end
		ptrs.size.times {|i| @romBytes[ptrsOffset+i] = ptrs[i]}
		strs.size.times {|i| @romBytes[startOffset+i] = strs[i]}
	
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
