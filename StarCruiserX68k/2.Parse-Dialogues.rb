puts
puts "Parse-Text"
start_time = Time.now

require "csv"
require "pp"
require "digest/md5"
require_relative 'common'
require_relative 'Libs/makeDict'

mode = "import" # export, import

exportStringsFile = @mainPath + "/SCRIPT_Export/dialoguesStringsExport.csv"
exportCsvFile = @mainPath + "/SCRIPT_Export/dialoguesExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/dialoguesImport.csv"

# Break at 078DDC

if mode == "export"
	exportArr = Array.new
	stringsData = readFile("original","MSTRING")
	#stringsData = readFile("patched","MSTRING_TEST")
	stringsArr = Array.new
	ptrTableOffset = 4
	ptrFirstStr = (stringsData[ptrTableOffset] + (stringsData[ptrTableOffset+1] << 8))
	entries = (ptrFirstStr - ptrTableOffset)/3+2
	entries.times do |t|
		ptrOffset = ptrTableOffset + (t*3)
		ptrData = (stringsData[ptrOffset] + (stringsData[ptrOffset+1] << 8))
		strLength = stringsData[ptrOffset+2]
		strBytes = Array.new
		strOffset = ptrData+4
		strLength.times {|st| strBytes.push stringsData[strOffset+st]}
		stringsArr.push ({ 	"strNum" => t,
							"strNumHex" => ("%04X" % t),
							"ptrOffset" => ("%08X" % ptrOffset),\
							"strOffset" => ("%08X" % strOffset),\
							"strBytes" => (strBytes.join(" ")),\
							"strText" => (decodeString strBytes),\
							"translation" => "" })
	end
	CSV.open(exportStringsFile, "wb", :write_headers => true, :headers => stringsArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| stringsArr.each{|row| csv << row.values} end
	
	eventsData = readFile("original","MIVENTS")
	#eventsData = readFile("patched","MIVENTS_TEST")
	eventsArr = Array.new
	ptrTableOffset = 4
	ptrFirstStr = (eventsData[ptrTableOffset] + (eventsData[ptrTableOffset+1] << 8))
	entries = (ptrFirstStr - ptrTableOffset)/4+1
	entries.times do |t|
		ptrOffset = ptrTableOffset + (t*4)
		evOffset = (eventsData[ptrOffset] + (eventsData[ptrOffset+1] << 8)) + 4
		evLength = (eventsData[ptrOffset+2] + (eventsData[ptrOffset+3] << 8))
		currentLength = 0
		if evLength == 0
			exportArr.push ({ 	"evPtrOffset" => ("%04X" % ptrOffset),
								"evType" => "null",
								"evOffset" => ("%04X" % evOffset),
								"evPartOffset" => "",\
								"codeBytes" => "",\
								"codeData" => "",\
								"linesUsed" => "",\
								"strText" => "",\
								"translation" => "" })
		end
		while currentLength < evLength
			currentEvOffset = evOffset + currentLength
			combinedLine = String.new
			combinedLineBytes = Array.new
			linesUsed = Array.new
			evLineOffset = 0
			while currentEvOffset < eventsData.size && eventsData[currentEvOffset] >= 0x10 && eventsData[currentEvOffset] <= 0x1a
				if evLineOffset == 0 then evLineOffset = currentEvOffset end
				lineIndex = ((eventsData[currentEvOffset] - 0x10) << 8) + eventsData[currentEvOffset+1]
				combinedLine += stringsArr[lineIndex]["strText"]
				linesUsed.push lineIndex
				currentEvOffset += 2
				currentLength += 2
				break if currentEvOffset == 0x3012 # Dirty hack for one line that breaks intentially in the game.
			end
			if combinedLine.length > 0
				exportArr.push ({ 	"evPtrOffset" => ("%04X" % ptrOffset),
									"evType" => "text",
									"evOffset" => ("%04X" % evOffset),
									"evPartOffset" => ("%04X" % evLineOffset),\
									"codeBytes" => "",\
									"codeData" => "",\
									"linesUsed" => (linesUsed.join(" ")),\
									"strText" => combinedLine,\
									"translation" => "" })
			else
				codeBytes = "%02X" % eventsData[currentEvOffset] + " " + "%02X" % eventsData[currentEvOffset+1]
				codeData = (eventsData[currentEvOffset] << 8) + eventsData[currentEvOffset+1]
				#puts parseCode codeData
				currentLength += 2
				exportArr.push ({ 	"evPtrOffset" => ("%04X" % ptrOffset),
									"evType" => "code",
									"evOffset" => ("%04X" % evOffset),
									"evPartOffset" => ("%04X" % currentEvOffset),\
									"codeBytes" => codeBytes,\
									"codeData" => (parseCode(currentEvOffset,codeData)),\
									"linesUsed" => "",\
									"strText" => "",\
									"translation" => "" })
			end
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	
	dontCompressLines = "20F2,2AFC,2B30,2B3E,2B66,3174,319C,3BFC,3C30,3C4A"
	
	strHash = Hash.new
	importArr.each do |row|
		if !(row["translation"].nil? || row["translation"].length == 0)
			strHash[row["translation"].strip] = nil
		end
	end
	stringsArr = strHash.keys
	stringsArrHash = Digest::MD5.hexdigest stringsArr.join
	dictFile = @mainPath + "/Temp/" + stringsArrHash + ".txt"
	if File.exist?(dictFile)
		compressDict = File.read(dictFile).split("####")
	else
		print "Import file changed or dictionary file doesn't exist, regenerating dictionary file... "
		compressDict = makeDictionary(strHash.keys, 690, 16384)
		IO.write(dictFile, compressDict.join("####"))
		puts "Done."
	end
	
	linesDict = Hash.new
	eventsArray = Array.new
	eventsPtrs = Array.new
	stringsArray = Array.new
	strIdx = 0
	skipCodes = Hash.new
	eventHash = Hash.new
	
	linesDictTmp = Hash.new
	
	groupArr = (importArr.group_by{|line| line["evPtrOffset"]})
	eventStartOffset = groupArr.size * 4

	eventLastOffset = eventStartOffset
	groupArr.keys.each do |key|
		event = groupArr[key]
		highRes = true
		event.size.times do |t|
			compressCurrentString = true
			#highRes = false
			# A dirty workaround for some scenes with mixed low and high res modes
			if event[t]["evPartOffset"] == "15F8" || event[t]["evPartOffset"] == "1608" || event[t]["evPartOffset"] == "19BA" || event[t]["evPartOffset"] == "19C0"
				highRes = false
			end
			# A dirty workaround for the strings that too long to met jump code
			if !(dontCompressLines.split(",").index(event[t]["evPartOffset"]).nil?)
				compressCurrentString = false
			end
			#if event[t]["evPartOffset"] == "20F2" || event[t]["evPartOffset"] == "2AFC" || event[t]["evPartOffset"] == "2B30" || event[t]["evPartOffset"] == "2B3E" || event[t]["evPartOffset"] == "2B66"
			#	compressCurrentString = false
			#end
			
			if event[t]["evType"] == "code"
				if event[t]["codeData"].include?("skipNext") && event[t+1]["evType"] == "text" # Don't compress the text line if it needs to have a single event code!
					compressCurrentString = false # Dont forget to switch it back!
				end
				if event[t]["codeData"].include?("skipCodes")
					#skipNum = event[t]["codeBytes"].gsub(" ", "").to_i(16) & 0x0fff
					skipCodes[event[t]["evPartOffset"]] = event[t]["codeData"].split(">")[1].strip
				end
				if event[t]["codeData"].include?("screenMode: high res")
					highRes = true
				elsif event[t]["codeData"].include?("screenMode: low res")
					highRes = false
				end
				eventCode = event[t]["codeBytes"].split(" ").map{|b| b.to_i(16)}
				if eventCode[0] >= 0xa4 && eventCode[0] <= 0xaf
					eventCode[0] -= 3
				end
				eventHash[event[t]["evPartOffset"]] = eventCode
			elsif event[t]["evType"] == "null"
				# Nothing for null string
			elsif event[t]["evType"] == "text"
				if event[t]["translation"].nil? || event[t]["translation"].length == 0
					puts "No translation for string '" + event[t]["strText"] + "' on " + event[t]["evPartOffset"] + "! Skipping..."
				else
					lineText = event[t]["translation"].strip
					if event[t]["strText"][event[t]["strText"].length-1] == "]"
						lineText += event[t]["strText"][event[t]["strText"].length-4..event[t]["strText"].length-1]
					elsif event[t]["strText"][event[t]["strText"].length-2] == "]"
						lineText += event[t]["strText"][event[t]["strText"].length-5..event[t]["strText"].length-2]
					elsif event[t]["strText"][event[t]["strText"].length-1] == "\n"
						lineText += "[0D]"
					end
					preparedLine = prepareString(lineText,highRes)
					if compressCurrentString
						#preparedLine
						compressDict.each do |cs|
							if !preparedLine.index(cs).nil?
								#puts preparedLine
								preparedLine.gsub!(cs,("###" + cs + "###"))
							end
						end
					else
						
						compressCurrentString = true
					end
					#puts preparedLine
					tmpIdx = 0
					preparedLine.split("###").each do |pl|
						preparedPart = encodeString pl
						if preparedPart.size > 0
							if tmpIdx > 0
								addEvt = "_" + tmpIdx.to_s
							else
								addEvt = ""
							end
							if linesDict[preparedPart].nil?
								idxCode = strIdx + 0x1000
								eventHash[event[t]["evPartOffset"] + addEvt] = [(idxCode & 0xff00) >> 8, (idxCode & 0x00ff)]
								linesDict[preparedPart] = strIdx
								strIdx += 1
							else
								idxCode = linesDict[preparedPart] + 0x1000
								eventHash[event[t]["evPartOffset"] + addEvt] = [(idxCode & 0xff00) >> 8, (idxCode & 0x00ff)]
							end
							tmpIdx += 1
						end
					end
				end
			end
		end
		eventsPtrs += [(eventLastOffset & 0x00ff), (eventLastOffset & 0xff00) >> 8]
		eventSize = eventHash.size*2 + eventStartOffset - eventLastOffset
		eventsPtrs += [(eventSize & 0x00ff), (eventSize & 0xff00) >> 8]
		eventLastOffset = eventHash.size*2 + eventStartOffset
	end
	#pp eventHash
	if skipCodes.size > 0
		skipCodes.each do |sc|
			if eventHash[sc[1]].nil?
				puts "Dead link at '" + sc[1] + "'!"
			else
				skipNum = eventHash.keys.index(sc[1]) - eventHash.keys.index(sc[0]) - 1 + 0x6000
				if skipNum > 0x60ff
					puts "Jump at " + sc[1] + " is too long! => %04X" % skipNum
				end
				eventHash[sc[0]] = [(skipNum & 0xff00) >> 8, (skipNum & 0x00ff)]
			end
		end
	end
	
	eventsArray = eventHash.values.flatten(1)
	eventData = eventsPtrs + eventsArray
	eventFile = [0,0x20,(eventData.size & 0x00ff), (eventData.size & 0xff00) >> 8] + eventData
	
	puts "Text entries: " + linesDict.keys.size.to_s
	puts "Text size: " + linesDict.keys.flatten(1).size.to_s
	
	linesPtrs = Array.new
	linesStartOffset = linesDict.size * 3
	linesLastOffset = linesStartOffset
	linesDict.keys.each do |line|
		linesPtrs += [(linesLastOffset & 0x00ff), (linesLastOffset & 0xff00) >> 8]
		linesPtrs.push line.size
		linesLastOffset += line.size
	end
	linesArray = linesDict.keys.flatten(1)
	linesData = linesPtrs + linesArray
	linesFile = [0,0x20,(linesData.size & 0x00ff), (linesData.size & 0xff00) >> 8] + linesData
	
	if !writeFile("patched","MIVENTS",eventFile)
		puts "Unable to write byte patch for 'MIVENTS' file!"
	end
	if !writeFile("patched","MSTRING",linesFile)
		puts "Unable to write byte patch for 'MSTRING' file!"
	end
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
