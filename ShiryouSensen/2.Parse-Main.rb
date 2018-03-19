puts
puts "Parse-Main"
start_time = Time.now

require "csv"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/mainExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/mainImport.csv"

if mode == "export"
    exportArr = Array.new

	names = Array.new
	0.upto(21) do |c|
		ptrData = (@romBytes[0xe74d+(c*2)] + (@romBytes[0xe74d+(c*2)+1] << 8))
		strOffset = ptrData + 0xa200
		strArr = Array.new
		0.upto(13) {|i| strArr.push @romBytes[strOffset+i]}
		names.push decodeMultiString(strArr,7,2)
	end

	0.upto(405) do |c|
		ptrOffset = 0xe89f+(c*4)
		ptrData = (@romBytes[ptrOffset] + (@romBytes[ptrOffset+1] << 8))
		strOffset = ptrData + 0xa200

		name = (names[@romBytes[ptrOffset+2]] if @romBytes[ptrOffset+2] != 0x80) || ""

		strBytes = Array.new
		tmpOffset = strOffset
		while @romBytes[tmpOffset] != 0xff
			strBytes.push @romBytes[tmpOffset]
			tmpOffset += 1
		end

		exportArr.push ({ "ptrOffset" => ("%08X" % ptrOffset),\
				"ptrBytes" => ("%04X" % ptrData),\
				"strOffset" => ("%08X" % strOffset),\
				"type" => "dialogue",\
				"name" => name,\
				"name_translation" => "",\
				"strText" => (decodeString strBytes),\
				"translation" => "" })
	end
	
	0.upto(25) do |c|
		ptrOffset = 0xe4a7+(c*2)
		ptrData = (@romBytes[ptrOffset] + (@romBytes[ptrOffset+1] << 8))
		strOffset = ptrData + 0xa200

		strBytes = Array.new
		tmpOffset = strOffset
		while @romBytes[tmpOffset] != 0xff
			strBytes.push @romBytes[tmpOffset]
			tmpOffset += 1
		end

		exportArr.push ({ "ptrOffset" => ("%08X" % ptrOffset),\
				"ptrBytes" => ("%04X" % ptrData),\
				"strOffset" => ("%08X" % strOffset),\
				"type" => "other",\
				"name" => "",\
				"name_translation" => "",\
				"strText" => (decodeString strBytes),\
				"translation" => "" })
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	groupArr = (importArr.group_by{|line| line["type"]})
	currentAddr = 0x4cf7
	groupArr["other"].each do |irow|
		strArr = encodeString(irow["translation"],irow["strOffset"])
		ptrOffset = irow["ptrOffset"].to_i(16)
		strOffset = currentAddr + 0xa200
		@romBytes[ptrOffset] = (currentAddr & 0x00ff)
		@romBytes[ptrOffset+1] = ((currentAddr & 0xff00) >> 8)
		0.upto(strArr.size-1) { |i| @romBytes[i+strOffset] = strArr[i] }
		currentAddr += strArr.size
	end
	firstBlockOffset = currentAddr + 0xa200
	blocks = Array.new
	blockEnd = 0x5fdf
	blockArr = Array.new
	dBlock = -1
	groupArr["dialogue"].each do |drow|
		strArr = encodeString((prepareString drow["translation"]),drow["strOffset"])
		if (strArr.size + currentAddr) > blockEnd
			while currentAddr <= blockEnd
				blockArr.push 0xff
				currentAddr += 1
			end
			currentAddr = 0x6000
			blockEnd = 0x7fff
			dBlock += 1
			blocks.push blockArr 
			blockArr = Array.new
		end
		blockArr += strArr
		ptrOffset = drow["ptrOffset"].to_i(16)
		@romBytes[ptrOffset] = (currentAddr & 0x00ff)
		@romBytes[ptrOffset+1] = ((currentAddr & 0xff00) >> 8)
		@romBytes[ptrOffset+3] = dBlock if dBlock > 0
		
		if @romBytes[ptrOffset+2] < 0x80
			namePtr = (@romBytes[ptrOffset+2]*2)+0xe74d
			nameOffset = (@romBytes[namePtr] + (@romBytes[namePtr+1] << 8)) + 0xa200
			#nameTranslation = prepareString drow["name_translation"]
			nameTranslation = prepareString drow["name_translation"].upcase
			nameTranslation += " " while nameTranslation.size < 14
			nameBytes = encodeString(nameTranslation,0)
			0.upto(nameBytes.size-2) { |i| @romBytes[i+nameOffset] = nameBytes[i] }
		end
		
		currentAddr += strArr.size
	end
	if blockArr.size > 0
		while currentAddr <= blockEnd
			blockArr.push 0xff
			currentAddr += 1
		end
		blocks.push blockArr
	end
	0.upto(blocks.size-1) do |bn|
		block = blocks[bn]
		if bn == 0
			0.upto(block.size-1) { |i| @romBytes[i+firstBlockOffset] = block[i] }
		elsif bn == 1
			0.upto(block.size-1) { |i| @romBytes[i+0x010200] = block[i] }
		else
			@romBytes += block
		end
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
