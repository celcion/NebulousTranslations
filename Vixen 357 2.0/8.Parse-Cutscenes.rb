puts
puts "Parse-Cutscenes"
start_time = Time.now

require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/cutscenesExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/cutscenesImport.csv"

fontsOffset = 0x054018

if mode == "export"
	ptrTable = [{:offset=>0x02eff8,:entries=>16,:tbl=>"export_cutscenes.tbl",:comment=>"intros"},
				{:offset=>0x01b484,:entries=>1, :tbl=>"export_cutscenes.tbl",:comment=>"credits"},
				{:offset=>0x01b702,:entries=>1, :tbl=>"export_cutscenes.tbl",:comment=>"ending01"},
				{:offset=>0x01b834,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending02"},
				{:offset=>0x01b88e,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending03"},
				{:offset=>0x01b9ee,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-ben"},
				{:offset=>0x01ba2e,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-kiel"},
				{:offset=>0x01ba86,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-takuya"},
				{:offset=>0x01bade,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-mack"},
				{:offset=>0x01bb36,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-harry"},
				{:offset=>0x01bb8e,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-eddie"},
				{:offset=>0x01bbe6,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-nina"},
				{:offset=>0x01bc3e,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-chay"},
				{:offset=>0x01bc96,:entries=>1, :tbl=>"export_opening.tbl",:comment=>"ending-reiko"},
				{:offset=>0x01cb48,:entries=>1, :tbl=>"export_opening.tbl",  :comment=>"opening"}]
	
	ptrTable.each do |cScene|
		exportTBLFile = @mainPath + "/TBLs/" + cScene[:tbl]
		exportTBLHash = Hash.new
		File.open(exportTBLFile, encoding: 'SJIS').each {|i| exportTBLHash[i.split("=")[0].to_i(16)] = i.split("=")[1].gsub("\n", "").gsub("\r", "")}
		cScene[:entries].times do |entry|
			ptrOffset = cScene[:offset] + entry*4
			strOffset = bytesToNum(@romBytes[ptrOffset..ptrOffset+3],false)
			strBytes = Array.new
			strText = String.new
			currentOffset = strOffset
			width = 0
			while @romBytes[currentOffset] != 0 || @romBytes[currentOffset+1] != 0
				strBytes += @romBytes[currentOffset..currentOffset+1]
				charCode = bytesToNum(@romBytes[currentOffset..currentOffset+1],false)
				if charCode == 0xffff
					strText += "\n"
					width = 0
				else
					strText += exportTBLHash[charCode]
					width += 1
				end
				if width == 16
					strText += "\n"
					width = 0
				end
				currentOffset += 2
			end
			if cScene[:comment] == "intros"
				path = @mainPath + "/SCRIPT_Export/cutscenes/intros/scene%02d_" %  (entry+1) + strBytes.size.to_s + "_0x%06x.txt" % ptrOffset
			else
				path = @mainPath + "/SCRIPT_Export/cutscenes/others/" + cScene[:comment]  + "_" + strBytes.size.to_s + "_0x%06x.txt" % ptrOffset
			end
			File.write(path,strText.encode('sjis').encode('utf-8'))
		end
	end
	2.times do |font|
		ptrsOffset = fontsOffset + font*8
		fontsData = Array.new
		2.times do |t|
			ptrOffset = ptrsOffset + t*4
			fontOffset = bytesToNum(@romBytes[ptrOffset..ptrOffset+3],false)
			fontsData += unpackData(@romBytes,fontOffset)
		end
		image = drawFonts fontsData
		path = @mainPath + "/GFX_Export/font_%01d.png" % (font+1)
		image.save(path, :interlace => true)
	end
elsif mode == "import"
	lineLimit = 32
	addSpace([[0x02f038,4028],[0x044b58,1524],[0x045d66,1126],[0x04660a,1376]])
	
	Dir.glob(@mainPath+"/SCRIPT_Import/cutscenes/**/*.txt").each do |csFile|
		csBytes = Array.new
		ptrOffset = csFile.split("/").last.split(".")[0].split("_").last.to_i(16)
		File.readlines(csFile, encoding: 'bom|utf-8').each do |line|
			csLine = line.rstrip
			if csLine.length.modulo(2) > 0
				csLine += " "
			end
			if csLine.length > lineLimit
				put "Line '" + csLine + "' in the file " + csFile + " is too long! Skipping..."
			end
			byteLine = csLine.bytes
			if byteLine.size < 32
				byteLine += [0xff,0xff]
			end
			csBytes += byteLine
		end
		csBytes += [0,0]
		insertData(csBytes,ptrOffset)
		#IO.binwrite((@tempPath+"test2/"+(csFile.split("/").last)+".bin"), csBytes.pack('c*'))
	end
	
	fontBytes = readFonts @insertFont
	fontsData = pack03 fontBytes
	addSpace([[0x058dd4,20960]])
	ptr = insertData(fontsData,fontsOffset)
	1.upto(3) do |t|
		ptrOffset = fontsOffset + t*4
		@romBytes[ptrOffset..ptrOffset+3] = ptr
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
