puts
puts "Parse-Menus"
start_time = Time.now

require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/menusExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/menusImport.csv"

if mode == "export"
	ptrTable = [{:offset=>0x02ea06,:entries=>20,:comment=>"game_menu"},
				{:offset=>0x00d86c,:entries=>1, :comment=>"m_out-of-ammo"},
				{:offset=>0x00daa2,:entries=>1, :comment=>"m_out-of-mp"},
				{:offset=>0x00f6a0,:entries=>1, :comment=>"m_supply-complete"},
				{:offset=>0x010480,:entries=>1, :comment=>"m_saving-complete"},
				{:offset=>0x01063e,:entries=>1, :comment=>"m_game-speed"},
				{:offset=>0x010644,:entries=>1, :comment=>"m_animations"},
				{:offset=>0x01064a,:entries=>1, :comment=>"m_map-status"},
				{:offset=>0x010682,:entries=>1, :comment=>"m_low-medium-high"},
				{:offset=>0x01069a,:entries=>1, :comment=>"m_on-off"},
				{:offset=>0x0106b2,:entries=>1, :comment=>"m_on-off"},
				{:offset=>0x010252,:entries=>1, :comment=>"victory-conditions"},
				{:offset=>0x010272,:entries=>1, :comment=>"defeat-conditions"}]
	
	exportArr = Array.new
	ptrTable.each do |menu|
		menu[:entries].times do |mEntry|
			ptrOffset = menu[:offset] + mEntry*4
			strOffset = bytesToNum(@romBytes[ptrOffset..ptrOffset+3],false)
			strBytes = Array.new
			currentOffset = strOffset
			idx = 0
			while @romBytes[currentOffset] != 0
				strBytes.push @romBytes[currentOffset]
				currentOffset += 1
				if @romBytes[currentOffset] == 0 && @romBytes[currentOffset+1] == 0xfe && idx < 2
					strBytes.push @romBytes[currentOffset]
					currentOffset += 1
					idx += 1
				end
			end
			exportArr.push ({"menu" => menu[:comment],\
							 "ptrOffset" => ("%06X" % ptrOffset),\
							 "strOffset" => ("%06X" % strOffset),\
							 "size" => (strBytes.size+1),\
							 "strBytes" => (strBytes.map{|b| "%02X" % b}.join(" ")),\
							 "strText" => (decodeWithTable(strBytes,"export_menu.tbl")),\
							 "translation" => "" })
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	addSpace([[0x02ea56,56]])
	importArr.each do |mEntry|
		if mEntry["translation"].to_s.length > 0
			strBytes = encodeString mEntry["translation"]
		else
			strBytes = mEntry["strBytes"].split(" ").map{|b| b.to_i(16)}
		end
		strBytes.push 0
		insertData(strBytes,mEntry["ptrOffset"].to_i(16))
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
