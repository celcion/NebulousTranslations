puts
puts "Parse-CodePTRs"
start_time = Time.now

require "csv"
require "pp"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/codePtrsExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/codePtrsImport.csv"

if mode == "export"
	exportArr = Array.new
	xFiles = ["CRUISER.X","DEMO.X","EVENT.X","FLIGHT.X","MAZE.X","USEITEM.X"]
	#manualPtrs = [{"CRUISER.X" => ""}]
	xFiles.each do |xFile|
		dataFile = readFile("original",xFile)
		linksOffsets = (dataFile[0x0e] << 8) + dataFile[0x0f]
		
		currentOffset = 0x40
		while currentOffset < (linksOffsets+0x40-2)
			#puts currentOffset
			if dataFile[currentOffset] == 0x48 && dataFile[currentOffset+1] == 0x7a
				if dataFile[currentOffset+4] == 0xa0 && dataFile[currentOffset+5] == 0x27
					linkData = (dataFile[currentOffset+2] << 8) + dataFile[currentOffset+3]
					strOffset = calculateLink(linkData,currentOffset)
					#puts ("%04X" % (currentOffset+2))
					strBytes = readBytes(dataFile,strOffset)
					exportArr.push ({ 	"fileName" => xFile,\
										"codePtrOffset" => ("%04X" % (currentOffset+2)),\
										"codePtrType" => "relative",\
										"strOffset" => ("%04X" % strOffset),\
										"strBytes" => (strBytes.join(" ")),\
										"strText" => (decodeString strBytes),\
										"translation" => "" })
					
					currentOffset += 6
				elsif dataFile[currentOffset+4] == 0x48 && dataFile[currentOffset+5] == 0x7a && dataFile[currentOffset+8] == 0x48 && dataFile[currentOffset+9] == 0x7a && dataFile[currentOffset+12] == 0x61 && dataFile[currentOffset+13] == 0x00
					3.times do |t|
						#puts xFile
						#puts t
						if xFile == "USEITEM.X" && t == 1
							currentOffset += 4
							next
						end
						linkData = (dataFile[currentOffset+2] << 8) + dataFile[currentOffset+3]
						strOffset = calculateLink(linkData,currentOffset)
						#puts ("%04X" % (currentOffset+2))
						#puts "\t%04X" % strOffset
						#puts
						strBytes = readBytes(dataFile,strOffset)
						exportArr.push ({ 	"fileName" => xFile,\
											"codePtrOffset" => ("%04X" % (currentOffset+2)),\
											"codePtrType" => "relative",\
											"strOffset" => ("%04X" % strOffset),\
											"strBytes" => (strBytes.join(" ")),\
											"strText" => (decodeString strBytes),\
											"translation" => "" })
						currentOffset += 4
					end
					currentOffset += 2
				else
					currentOffset += 1
				end
			elsif dataFile[currentOffset] == 0x48 && dataFile[currentOffset+1] == 0x79
				#puts currentOffset
				if dataFile[currentOffset+6] == 0xa0 && dataFile[currentOffset+7] == 0x27
					#puts xFile + " => %04X" % currentOffset
					strOffset = (dataFile[currentOffset+2] << 24) + (dataFile[currentOffset+3] << 16) + (dataFile[currentOffset+4] << 8) + dataFile[currentOffset+5] + 0x40
					strBytes = readBytes(dataFile,strOffset)
					#puts ("%04X" % (currentOffset+2))
					exportArr.push ({ 	"fileName" => xFile,\
										"codePtrOffset" => ("%04X" % (currentOffset+2)),\
										"codePtrType" => "direct",\
										"strOffset" => ("%04X" % strOffset),\
										"strBytes" => (strBytes.join(" ")),\
										"strText" => (decodeString strBytes),\
										"translation" => "" })
					currentOffset += 8
				else
					currentOffset += 1
				end
=begin
			elsif dataFile[currentOffset] == 0x43 && dataFile[currentOffset+1] == 0xfa
				if dataFile[currentOffset+4] == 0x2f && dataFile[currentOffset+5] == 0x09 && dataFile[currentOffset+6] == 0xa0 && dataFile[currentOffset+7] == 0x27
					linkData = (dataFile[currentOffset+2] << 8) + dataFile[currentOffset+3]
					strOffset = calculateLink(linkData,currentOffset)
					strBytes = readBytes(dataFile,strOffset)
					exportArr.push ({ 	"fileName" => xFile,\
										"codePtrOffset" => ("%04X" % (currentOffset+2)),\
										"codePtrType" => "relative_lea",\
										"strOffset" => ("%04X" % strOffset),\
										"strBytes" => (strBytes.join(" ")),\
										"strText" => (decodeString strBytes),\
										"translation" => "" })
					
					currentOffset += 8
				else
					linkData = (dataFile[currentOffset+2] << 8) + dataFile[currentOffset+3]
					strOffset = calculateLink(linkData,currentOffset)
					strBytes = readBytes(dataFile,strOffset)
					puts xFile + " %04X" % (currentOffset + 2) + " => %04X" % strOffset
					puts decodeString strBytes if xFile == "USEITEM.X"
					currentOffset += 1
				end
=end
			else
				currentOffset += 1
			end
		end
		
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	groupArr = (importArr.group_by{|line| line["fileName"]})
	groupArr.each do |file|
		dataFile = readFile("patched",file[0])
		linksOffsets = (dataFile[0x0e] << 8) + dataFile[0x0f]
		appendBytes = Array.new
		file[1].each do |codeLine|
			if codeLine["translation"].to_s.length > 0
				originalSize = codeLine["strBytes"].to_s.split(" ").size + 1
				originalStrOffset = codeLine["strOffset"].to_i(16)
				ptrOffset = codeLine["codePtrOffset"].to_i(16)
				translatedStringBytes = encodeString codeLine["translation"]
				translatedStringBytes.push 0
				if translatedStringBytes.size > originalSize
					translatedStringBytes.push 0 if translatedStringBytes.size.modulo(2) > 0
					newStrOffset = linksOffsets + appendBytes.size
					# Add checking for the items that hardcoded to the main items table and skip deleting it
					if !(codeLine["strOffset"].match?('0..A') && codeLine["fileName"] == "USEITEM.X")
						originalSize.times {|t| dataFile[originalStrOffset+t] = 0}
					end
					if codeLine["codePtrType"] == "direct"
						ptrData = newStrOffset
						dataFile[ptrOffset+2] = (ptrData & 0xff00) >> 8
						dataFile[ptrOffset+3] = ptrData & 0x00ff
					elsif codeLine["codePtrType"] == "relative"
						ptrData = newStrOffset - ptrOffset + 0x40
						if ptrData < 0x7ff0
							dataFile[ptrOffset] = (ptrData & 0xff00) >> 8
							dataFile[ptrOffset+1] = ptrData & 0x00ff
						else
							puts "Appended string is out of reach for string '" + codeLine["translation"] + "'! Not changing pointer..."
						end
					end
					appendBytes += translatedStringBytes
				else
					translatedStringBytes.size.times {|i| dataFile[originalStrOffset+i] = translatedStringBytes[i]}
				end
				
				if codeLine["fileName"] == "USEITEM.X" && codeLine["codePtrOffset"] == "0FD0"
					# Replacements for maximums on status screen. Better add autodetect.
					#dataFile[0x0fb5] = 0x07
					#dataFile[0x0fc3] = 0x1d
					dataFile[0x0fb5] = 0x0b
					dataFile[0x0fc3] = 0x22
				end
				if codeLine["fileName"] == "MAZE.X" && codeLine["codePtrOffset"] == "4060" && translatedStringBytes.size > originalSize
					# Change adding letter for gates/elevators
					dataFile[0x4028] = ((newStrOffset+2) & 0xff00) >> 8
					dataFile[0x4029] = (newStrOffset+2) & 0x00ff
				end
				#puts decodeString translatedStringBytes
				#puts codeLine["codePtrOffset"]
			end
		end
		dataFile = dataFile[0..linksOffsets+0x40-1] + appendBytes + dataFile[linksOffsets+0x40..dataFile.size-1]
		linksOffsets += appendBytes.size
		dataFile[0x0e] = (linksOffsets & 0xff00) >> 8
		dataFile[0x0f] = (linksOffsets & 0x00ff)
		if !writeFile("patched",file[0],dataFile)
			puts "Unable to write byte patch for '" + file[0] + "' file!"
		end
	end
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
