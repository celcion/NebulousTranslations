puts
puts "Parse-UI"
start_time = Time.now

require "csv"
require_relative 'common'
require_relative 'Libs/gfx'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/uiExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/uiImport.csv"

if mode == "export"
	exportArr = Array.new
	@colors = [ChunkyPNG::Color(:black),ChunkyPNG::Color(:lightblue),ChunkyPNG::Color(:blue),ChunkyPNG::Color(:white)]
	chrOffset = 0x041010
	tiles = drawMap(chrOffset,16,16)
	mappingTableOffset = 0x014716
=begin
	256.times do |t|
		tileMappingOffset = t*4 + mappingTableOffset
		puts "%02X" % t
		puts "\t" + @exportTable[@romBytes[tileMappingOffset]] + @exportTable[@romBytes[tileMappingOffset+1]]
		puts "\t" + @exportTable[@romBytes[tileMappingOffset+2]] + @exportTable[@romBytes[tileMappingOffset+3]]
	end
=end
	# address of first map
	startOffset = 0x014c26
	currentOffset = startOffset
	13.times do |t|
		image = ChunkyPNG::Image.new(256, 240, ChunkyPNG::Color::TRANSPARENT)
		xPos = 0
		yPos = 0
		currentMapOffset = startOffset + (0xf0*t)
		currentOffset = currentMapOffset
		while yPos < 15
			lineBytesArray = Array.new
			lineCharArray = Array.new
			2.times {lineBytesArray.push Hash.new}
			2.times {lineCharArray.push Hash.new}
			while xPos < 16
				tileMappingOffset = @romBytes[currentOffset].to_i*4 + mappingTableOffset

				4.times do |tm|
					xHash = xPos * 2
					yHash = yPos * 2
					xName = ("x"+(xHash+tm.modulo(2)).to_s)
					if tm > 1 then idx = 1 else idx = 0 end
					mByte = @romBytes[tileMappingOffset+tm]
					lineBytesArray[idx][xName] = "%02X" % mByte
					if mByte < 0xb0
						lineCharArray[idx]["t"+xName] = @exportTable[mByte]
					else
						lineCharArray[idx]["t"+xName] = "\u0019"
					end
				end
				
				decodedTile = Array.new
				4.times do |tm|
					xTilesPos = @romBytes[tileMappingOffset+tm] & 0x0f
					yTilesPos = (@romBytes[tileMappingOffset+tm] & 0xf0) >> 4
					decodedTile.push tiles.crop(xTilesPos * 8, yTilesPos * 8, 8, 8)
				end
				xImagePos = xPos * 16
				yImagePos = yPos * 16
				image.replace!(decodedTile[0],xImagePos,yImagePos)
				image.replace!(decodedTile[1],(xImagePos+8),yImagePos)
				image.replace!(decodedTile[2],xImagePos,(yImagePos+8))
				image.replace!(decodedTile[3],(xImagePos+8),(yImagePos+8))
				
				currentOffset += 1
				xPos += 1
			end
			2.times {|n| exportArr.push ({ "tileMappingOffset" => ("%08X" % currentMapOffset)}).merge(lineBytesArray[n]).merge(lineCharArray[n])}
			yPos += 1
			xPos = 0
		end
		imagePath = @mainPath + "/GFX_Export/UI/" + ("%08X" % currentMapOffset) + ".png"
		image.save(imagePath, :interlace => true)
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	@colors = [ChunkyPNG::Color(:black),ChunkyPNG::Color(:lightblue),ChunkyPNG::Color(:blue),ChunkyPNG::Color(:white)]
	tiles = drawMap(0x041010,16,16)
	groupArr = (importArr.group_by{|line| line["tileMappingOffset"]})
	mapDict = Hash.new
	mapDictIdx = 0
	mapDictIdxAdd = 220
	mapDictOffset = 0x014716
	screenMaps = Array.new
	screenMapsOffset = 0x014c26
	groupArr.each do |screen|
		image = ChunkyPNG::Image.new(256, 240, ChunkyPNG::Color::TRANSPARENT)
		screenMap = Array.new
		xPos = 0
		yPos = 0
		15.times do |yLine|
			16.times do |xLine|
				entry = Array.new
				entry.push encodeUI(screen[1][yLine*2]["x"+(xLine*2).to_s],screen[1][yLine*2]["tx"+(xLine*2).to_s])
				entry.push encodeUI(screen[1][yLine*2]["x"+(xLine*2+1).to_s],screen[1][yLine*2]["tx"+(xLine*2+1).to_s])
				entry.push encodeUI(screen[1][yLine*2+1]["x"+(xLine*2).to_s],screen[1][yLine*2+1]["tx"+(xLine*2).to_s])
				entry.push encodeUI(screen[1][yLine*2+1]["x"+(xLine*2+1).to_s],screen[1][yLine*2+1]["tx"+(xLine*2+1).to_s])
				decodedTile = Array.new
				4.times do |tm|
					xTilesPos = entry[tm] & 0x0f
					yTilesPos = (entry[tm] & 0xf0) >> 4
					decodedTile.push tiles.crop(xTilesPos * 8, yTilesPos * 8, 8, 8)
				end
				xImagePos = xLine * 16
				yImagePos = yLine * 16
				image.replace!(decodedTile[0],xImagePos,yImagePos)
				image.replace!(decodedTile[1],(xImagePos+8),yImagePos)
				image.replace!(decodedTile[2],xImagePos,(yImagePos+8))
				image.replace!(decodedTile[3],(xImagePos+8),(yImagePos+8))
				addIdx = false
				entry.each {|e| if e > 0xbf then addIdx = true end}
				if mapDict[entry].nil?
					if addIdx
						idx = mapDictIdxAdd
						mapDictIdxAdd += 1
					else
						idx = mapDictIdx
						mapDictIdx += 1
					end
					mapDict[entry] = idx
					screenMap.push idx
				else
					screenMap.push mapDict[entry]
				end
			end
		end
		screenMaps += screenMap
		#exit
		imagePath = @mainPath + "/GFX_Import/UI/" + screen[0] + ".png"
		image.save(imagePath, :interlace => true)
	end
	#puts mapDict.size
	#screenMaps.size.times {|i| @romBytes[i+screenMapsOffset] = screenMaps[i]}
	dictArr = Array.new
	tmpHash = mapDict.invert
	#puts tmpHash
	256.times do |t|
		if tmpHash[t].nil?
			dictArr += [0xff,0xff,0xff,0xff]
		else
			dictArr += tmpHash[t]
		end
	end
	#mapDict.keys.each {|mk| dictArr += mk}
	dictArr.size.times {|i| @romBytes[i+mapDictOffset] = dictArr[i]}
	screenMaps.size.times {|i| @romBytes[i+screenMapsOffset] = screenMaps[i]}
	
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
