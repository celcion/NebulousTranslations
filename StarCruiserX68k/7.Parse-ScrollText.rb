puts
puts "Parse-ScrollText"
start_time = Time.now

require "csv"
require "pp"
require_relative 'common'

mode = "import" # export, import

exportTextPath = @mainPath + "/SCRIPT_Export/"
importTextPath = @mainPath + "/SCRIPT_Import/"

if mode == "export"
	dataFile = readFile("original","DEMO.X")
	linksOffsets = (dataFile[0x0e] << 8) + dataFile[0x0f]
	currentOffset = 0x40
	while currentOffset < (linksOffsets+0x40-2)
		if dataFile[currentOffset] == 0x41 && dataFile[currentOffset+1] == 0xfa
			if dataFile[currentOffset+4] == 0x23 && dataFile[currentOffset+5] == 0xc8 && (dataFile[currentOffset+9] == 0x2a || dataFile[currentOffset+9] == 0x4a)
				linkData = (dataFile[currentOffset+2] << 8) + dataFile[currentOffset+3]
				linkOffset = calculateLink(linkData,currentOffset)
				currentStrOffset = linkOffset
				if dataFile[currentOffset+9] == 0x2a
					strText = String.new
					while dataFile[currentStrOffset] != 0 || dataFile[currentStrOffset+1] != 0 || dataFile[currentStrOffset+2] != 0 || dataFile[currentStrOffset+3] != 0
						if dataFile[currentStrOffset] == 0 && dataFile[currentStrOffset+1] == 0
							strText += "\n"
						else
							strText += dataFile[currentStrOffset..currentStrOffset+1].pack('c*').encode!('UTF-8', 'Shift_JIS')
						end
						currentStrOffset += 2
					end
					exportSize = currentStrOffset - linkOffset
				else
					strBytes = readBytes(dataFile,linkOffset)
					strText = decodeString strBytes
					exportSize = strBytes.size
				end
				exportTextFile = exportTextPath + ("0x%04X" % (currentOffset+2)) + "_" + ("0x%04X" % linkOffset) + "_" + exportSize.to_s + ".txt"
				IO.write(exportTextFile, strText)
				
				currentOffset += 10
			else
				currentOffset += 1
			end
		else
			currentOffset += 1
		end
	end
elsif mode == "import"
	dataFile = readFile("patched","DEMO.X")
	linksOffsets = (dataFile[0x0e] << 8) + dataFile[0x0f]
	originalOffset = 0x257c
	overflowOffset = linksOffsets + 0x40
	originalLimit = 1690
	insertArray = Array.new
	overflowArray = Array.new
	
	Dir[importTextPath+"*.txt"].each do |textFile|
		#puts textFile
		fileData = textFile.split("/").last.split(".")[0].split("_")
		ptrOffset = fileData[0].to_i(16)
		originalStrOffset = fileData[1].to_i(16)
		originalStrLength = fileData[2].to_i
		if fileData[0] == "0x5086"
			newData = encodeString IO.binread(textFile)
		else
			newData =  IO.binread(textFile).gsub("\n","\x00").gsub("\r","").bytes
		end
		newData.push 0
		newData.push 0 if newData.size.modulo(2) != 0
		#puts newData.size
		if insertArray.size + newData.size < originalLimit
			strOffset = originalOffset + insertArray.size
			insertArray += newData
		else
			strOffset = overflowOffset + overflowArray.size
			overflowArray += newData
		end
		relOffset = strOffset - ptrOffset
		if relOffset < 0
			relOffset = 0xffff + relOffset + 1
		end
		dataFile[ptrOffset] = (relOffset & 0xff00) >> 8
		dataFile[ptrOffset+1] = relOffset & 0x00ff
		#puts "%04X" % relOffset
	end
	originalLimit.times {|t| dataFile[originalOffset+t] = 0}
	insertArray.size.times {|i| dataFile[originalOffset+i] = insertArray[i]}
	dataFile = dataFile[0..linksOffsets+0x40-1] + overflowArray + dataFile[linksOffsets+0x40..dataFile.size-1]
	linksOffsets += overflowArray.size
	dataFile[0x0e] = (linksOffsets & 0xff00) >> 8
	dataFile[0x0f] = (linksOffsets & 0x00ff)
	if !writeFile("patched","DEMO.X",dataFile)
		puts "Unable to write byte patch for '" + file[0] + "' file!"
	end
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
