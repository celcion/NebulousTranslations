puts
puts "Parse-Dialogues"
start_time = Time.now

require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/dialoguesExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/dialoguesImport.csv"
#sceneTableOffset = 0x017c8e
#sceneDataOffset = 0x021216

if mode == "export"
	exportArr = Array.new
	sceneTableOffset = 0x017c8e
	16.times do |scene|
		sceneEntryOffset = sceneTableOffset + (scene*4)
		sceneCompOffset = bytesToNum(@romBytes[sceneEntryOffset..sceneEntryOffset+3],false)
		sceneDecData = unpackData(@romBytes,sceneCompOffset)
		sceneOffset = 0
		sceneLinePtr = bytesToNum(sceneDecData[sceneOffset..sceneOffset+1],false)
		while sceneLinePtr != 0
			sceneStr = Array.new
			currentOffset = sceneLinePtr
			if currentOffset < sceneDecData.size && sceneDecData[currentOffset] > 0
				prefix = sceneDecData[currentOffset..currentOffset+4]
				char = @nameCodes[prefix[4]]
				currentOffset += 5
				while sceneDecData[currentOffset] != 0
					sceneStr.push sceneDecData[currentOffset]
					currentOffset += 1
				end
				exportArr.push ({ 	"scenePtrOffset" => ("%06X" % sceneEntryOffset),\
									"ptrOffset" => ("%04X" % sceneOffset),\
									"lineOffset" => ("%04X" % sceneLinePtr),\
									"strBytes" => (sceneStr.map{|b| "%02X" % b}.join(" ")),\
									"prefix" => (prefix.map{|b| "%02X" % b}.join(" ")),\
									"scene" => ("scene%02d" % (scene+1)),\
									"name" => char,\
									"strText" => (decodeString sceneStr),\
									"translation" => "" })
			end			
			sceneOffset += 2
			sceneLinePtr = bytesToNum(sceneDecData[sceneOffset..sceneOffset+1],false)
		end
	end
	
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	
	addSpace([[0x021216,23088],[0x01cd80,12920],[0x0504b0,14925],[0x0d5280,44410]])
	
	#allTextSize = 23089
	#allTextSize.times {|t| @romBytes[sceneDataOffset+t] = 0xff}
	
	tablePtrs = Array.new
	tableStrs = Array.new
	groupScenes = (importArr.group_by{|line| line["scene"]})
	groupScenes.each do |scene|
		#tablePtrs += numToBytes((sceneDataOffset + tableStrs.size),4,false)
		ptrStart = scene[1].size * 2
		ptrs = Array.new
		strs = Array.new
		scene[1].each do |scLine|
			prefix = scLine["prefix"].split(" ").map{|b| b.to_i(16)}
			origLine = scLine["strBytes"].split(" ").map{|b| b.to_i(16)}
			ptrs += numToBytes((ptrStart + strs.size),2,false)
			if scLine["translation"].to_s.length > 0
				prepStr = prepareString scLine["translation"]
				encodedStr = encodeString prepStr
				if origLine[0] == 0x0a
					encodedStr = origLine[0..1] + encodedStr
				end
				encodedStr.push origLine.last
				strs += (prefix + encodedStr)
			else
				strs += (prefix + origLine)
			end
			strs.push 0
		end
		sceneData = ptrs+strs
		compData = pack03 sceneData
		insertData(compData,scene[1][0]["scenePtrOffset"].to_i(16))
=begin
		if (tableStrs + compData).size < allTextSize
			tablePtrs += numToBytes((sceneDataOffset + tableStrs.size),4,false)
			tableStrs += compData
		else
			#puts "Can't append block '" + scene[0].to_s + "' to original space! Appending to external space..."
			extraOffset = getSpace compData.size
			if extraOffset.nil?
				puts "Can't get external space to insert data!"
			else
				tablePtrs += numToBytes(extraOffset,4,false)
				compData.size.times {|i| @romBytes[extraOffset+i] = compData[i]}
			end
		end
		if tableStrs.size.modulo(2) != 0 then tableStrs.push 0xff end
		
		IO.binwrite((@tempPath+"test1/"+scene[0].to_s+".bin"), sceneData.pack('c*'))
		IO.binwrite((@tempPath+"test1/"+scene[0].to_s+"_pack.bin"), compData.pack('c*'))
=end
	end
	#tablePtrs.size.times {|i| @romBytes[sceneTableOffset+i] = tablePtrs[i]}
	#tableStrs.size.times {|i| @romBytes[sceneDataOffset+i] = tableStrs[i]}
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
