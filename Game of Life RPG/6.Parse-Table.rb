puts
puts "Parse-Table"
start_time = Time.now

require "csv"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/tableExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/tableImport.csv"

if mode == "export"
	exportArr = Array.new
	#{"name" => "unk3", "offset" => 0x03fbc1, "count" => 10},
	tables =  [{"name" => "skills", "offset" => 0x03f718, "shift" => 0x030010, "count" => 49},
				{"name" => "goals", "offset" => 0x03d17b, "shift" => 0x030010, "count" => 8},
				{"name" => "unk1", "offset" => 0x03fabf, "shift" => 0x030010, "count" => 11},
				{"name" => "inventory", "offset" => 0x03fb14, "shift" => 0x030010, "count" => 19},
				{"name" => "items", "offset" => 0x03fc73, "shift" => 0x030010, "count" => 27},
				{"name" => "trainings", "offset" => 0x035420, "shift" => 0x02a010, "count" => 12},
				{"name" => "gender", "offset" => 0x03d1cc, "shift" => 0x030010, "count" => 8},
				{"name" => "cities", "offset" => 0x034d93, "shift" => 0x02a010, "count" => 10}]
	tables.each do |table|
		ptrTableOffset = table["offset"]
		table["count"].times do |t|
			ptrOffset = ptrTableOffset + (t*2)
			ptrData = (@romBytes[ptrOffset] + (@romBytes[ptrOffset+1] << 8))
			strOffset = ptrData + table["shift"]
			#puts "%08X" % ptrOffset
			currentOffset = strOffset
			strBytes = Array.new
			while @romBytes[currentOffset] != 0xff
				strBytes.push @romBytes[currentOffset]
				currentOffset += 1
			end
			exportArr.push ({ "tableName" => table["name"],\
							  "insertOverride" => "",\
							  "ptrOffset" => ("%08X" % ptrOffset),\
							  "ptrBytes" => ("%04X" % ptrData),\
							  "ptrShift" => ("%08X" % table["shift"]),\
							  "strOffset" => ("%08X" % strOffset),\
							  "strBytes" => (strBytes.join(" ")),\
							  "strText" => (decodeString strBytes),\
							  "translation" => "" })
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	linesDict = Hash.new
	groupArr = (importArr.group_by{|line| line["tableName"]})
	groupArr.each do |table|
		if table[1][0]["insertOverride"].nil? || table[1][0]["insertOverride"].length == 0
			strsOffset = table[1][0]["strOffset"].to_i(16)
			ptrShift = table[1][0]["ptrShift"].to_i(16)
		else
			strsOffset = table[1][0]["insertOverride"].split(";")[0].to_i(16)
			ptrShift = table[1][0]["insertOverride"].split(";")[1].to_i(16)
		end
		startOffset = strsOffset - ptrShift
		#puts "%04X" % startOffset
		
		strs = Array.new
		currentOffset = startOffset
		table[1].each do |row|
			ptrOffset = row["ptrOffset"].to_i(16)
			if row["translation"].nil? || row["translation"].length == 0
				strBytes = row["strBytes"].split(" ").map {|b| b.to_i}
				strBytes.push 0xff
			else
				strBytes = encodeString row["translation"]
				if strBytes.size > 11
					puts "The line '" + row["translation"] + "' is too long! Cut at least " + (strBytes.size - 10).to_s + " bytes."
				end
			end
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
		end
		strs.size.times {|i| @romBytes[i+strsOffset] = strs[i]}
	end
=begin
	#strings limit - CA50
	ptrs = Array.new
	strs = Array.new
	linesDict = Hash.new
	ptrTableOffset = 0x02b310
	strsOffset = 0x01a010
	startOffset = 0
	currentOffset = startOffset
	importArr.each do |row|
		if row["translation"].nil? || row["translation"].length == 0
			strBytes = row["strBytes"].split(" ").map {|b| b.to_i}
			strBytes.push 0xff
		else
			strBytes = encodeString row["translation"]
			if strBytes.size > 64
				puts "The line '" + row["translation"] + "' is too long! Cut at least " + (strBytes.size - 64).to_s + " bytes."
			end
		end
		if linesDict[strBytes].nil?
			ptr = (currentOffset & 0x00ff), ((currentOffset & 0xff00) >> 8)
			linesDict[strBytes] = ptr
			ptrs += ptr
			strs += strBytes
			currentOffset += strBytes.size
		else
			ptrs += linesDict[strBytes]
		end
	end
	if strs.size > 0xd000
		puts "Text block is too big! You need to cut at least " + (strs.size - 0xd000).to_s + " bytes."
	else
		ptrs.size.times {|i| @romBytes[i+ptrTableOffset] = ptrs[i]}
		strs.size.times {|i| @romBytes[i+strsOffset] = strs[i]}
	end
	#puts strs.size
=end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
