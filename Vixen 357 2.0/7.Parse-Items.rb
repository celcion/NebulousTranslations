puts
puts "Parse-Menus"
start_time = Time.now

require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/itemsExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/itemsImport.csv"

if mode == "export"
	exportArr = Array.new
	itemsOffset = 0x020fc2
	14.times do |t|
		itemOffset = itemsOffset + t*30
		strBytes = Array.new
		currentStringOffset = itemOffset
		itemValues = @romBytes[currentStringOffset+12..currentStringOffset+29]
		while @romBytes[currentStringOffset] != 0
			strBytes.push @romBytes[currentStringOffset]
			currentStringOffset += 1
		end
		exportArr.push ({"itemOffset" => ("%06X" % itemOffset),\
						 "itemValues" => (itemValues.map{|b| "%02X" % b}.join(" ")),\
						 "itemText" => (decodeString strBytes),\
						 "translation" => "" })
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	importArr.each do |itemString|
		if itemString["translation"].to_s.length > 0
			strBytes = encodeString itemString["translation"]
			strBytes.push 0
			while strBytes.size < 12
				strBytes.push 0
			end
			if strBytes.size == 12
				itemValues = itemString["itemValues"].split(" ").map{|b| b.to_i(16)}
				itemData = strBytes + itemValues
				itemOffset = itemString["itemOffset"].to_i(16)
				itemData.size.times {|t| @romBytes[itemOffset+t] = itemData[t]}
			else
				puts "Incorrect item name size for '" + itemString["translation"] + "'! Skipping..."
			end
		end
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
