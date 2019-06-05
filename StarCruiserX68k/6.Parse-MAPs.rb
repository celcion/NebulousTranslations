puts
puts "Parse-MAPs"
start_time = Time.now

require "csv"
require "pp"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/mapsExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/mapsImport.csv"

if mode == "export"
	exportArr = Array.new
	Dir[@patchedFilesPath+"/disk1/*MAP"].each do |map|
		mapName = map.split("/").last
		dataFile = readFile("original",mapName)
		["block1","block2"].each do |mapBlock|
			if mapBlock == "block1"
				startOffset = 0x1e00
				entries = 112
			else
				startOffset = 0x2500
				entries = ((dataFile[startOffset+1] << 8) + dataFile[startOffset])/2
				#puts entries
			end
			entries.times do |tm|
				ptrOffset = startOffset + tm*2
				strOffset = (dataFile[ptrOffset+1] << 8) + dataFile[ptrOffset] + startOffset
				#puts "%04X" % ptrOffset + " => %04X" % strOffset
				if mapBlock == "block1"
					strBytes = readBytes(dataFile,strOffset)
				else
					strBytes = Array.new
					currentOffset = strOffset
					2.times do 
						while dataFile[currentOffset] != 0 && currentOffset < dataFile.size
							strBytes.push dataFile[currentOffset]
							currentOffset += 1
						end
						strBytes.push dataFile[currentOffset]
						currentOffset += 1
					end
					strBytes = strBytes[0..-2]
				end
				exportArr.push ({ 	"fileName" => mapName,\
									"mapBlock" => mapBlock,\
									"ptrOffset" => ("%04X" % ptrOffset),\
									"strOffset" => ("%04X" % strOffset),\
									"strBytes" => (strBytes.join(" ")),\
									"strText" => (decodeString strBytes),\
									"translation" => "" })
			end
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	groupArr = (importArr.group_by{|line| line["fileName"]})
	groupArr.each do |file|
		dataFile = readFile("patched",file[0])
		mapBlocks = (file[1].group_by{|line| line["mapBlock"]})
		mapBlocks.each do |mapBlock|
			if mapBlock[0] == "block1"
				blockSize = 0x600
				blockInsertOffset = 0x1e00
			else
				blockSize = 0x300
				blockInsertOffset = 0x2500
			end
				#puts mapBlock
				mapBlockPtrs = Array.new
				mapBlockStrs = Array.new
				#strsStart = mapBlock[1].size * 2
				mapLinesDict = Hash.new
				mapBlock[1].each do |mapLine|
					if mapLine["translation"].to_s.length == 0
						strBytes = mapLine["strBytes"].to_s.split(" ").map{|b| b.to_i}
					else
						if mapBlock[0] == "block1"
							strBytes = encodeString prepareString(mapLine["translation"],false)
							strBytes.push 0x0d
						else
							strBytes = encodeString mapLine["translation"]
						end
						if mapLine["translation"].split("[")[0].length > 23 && mapBlock[0] == "block2"
							puts "String '" + mapLine["translation"] + "' is longer than allowed space! Cut at least " + (mapLine["translation"].length-23).to_s + " bytes!"
						end
					end
					strBytes.push 0
					if mapLinesDict[strBytes].nil?
						ptrData = mapBlock[1].size * 2 + mapBlockStrs.size
						mapLinesDict[strBytes] = ptrData
						mapBlockStrs += strBytes
					else
						ptrData = mapLinesDict[strBytes]
					end
					mapBlockPtrs.push ptrData & 0x00ff
					mapBlockPtrs.push (ptrData & 0xff00) >> 8
				end
				mapBlockData = mapBlockPtrs + mapBlockStrs
				while mapBlockData.size < blockSize
					mapBlockData.push 0xff
				end
				if mapBlockData.size > blockSize
					puts "Block '" + mapBlock[0] + "' in file '" + file[0] + "' is too big! You need to cut at least " + (mapBlockData.size-blockSize).to_s + " bytes. Skipping..."
				else
					mapBlockData.size.times {|i| dataFile[blockInsertOffset+i] = mapBlockData[i]}
				end
			#end
		end
		if !writeFile("patched",file[0],dataFile)
			puts "Unable to write byte patch for '" + file[0] + "' file!"
		end
	end
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
