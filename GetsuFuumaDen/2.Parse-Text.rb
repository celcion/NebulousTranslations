puts
puts "Parse-Text"
start_time = Time.now

require "csv"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/textExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/textImport.csv"

if mode == "export"
    exportArr = Array.new
	textBlockOffset = 0x0f*0x2000+0x10
	ptrTableOffset = textBlockOffset + 0xfc
	148.times do |i|
		ptrOffset = ptrTableOffset+i*2
		ptrData = (@romBytes[ptrOffset] + (@romBytes[ptrOffset+1] << 8))
		#puts "%04X" % ptrData
		strOffset = textBlockOffset + ptrData - 0x8000
		#puts "\t%08X" % strOffset
		strBytes = Array.new
		tmpOffset = strOffset
		while @romBytes[tmpOffset] != 0xff
			strBytes.push @romBytes[tmpOffset]
			tmpOffset += 1
		end
		exportArr.push ({ "ptrOffset" => ("%08X" % ptrOffset),\
				"ptrBytes" => ("%04X" % ptrData),\
				"strOffset" => ("%08X" % strOffset),\
				"strText" => (decodeString strBytes),\
				"translation" => "" })
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	startOffset = 0x8240
	currentOffset = startOffset
	strArr = Array.new
	importArr.each do |row|
		ptrOffset = row["ptrOffset"].to_i(16)
		@romBytes[ptrOffset] = (currentOffset & 0x00ff)
		@romBytes[ptrOffset+1] = ((currentOffset & 0xff00) >> 8)
		strBytes = encodeString(row["translation"],row["ptrOffset"])
		strArr += strBytes
		currentOffset += strBytes.size
	end
	strArr.size.times {|i| @romBytes[0x01e250+i] = strArr[i]}
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
