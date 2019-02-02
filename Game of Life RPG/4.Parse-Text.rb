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
	ptrTableOffset = 0x01a010
	1452.times do |t|
		ptrOffset = ptrTableOffset + (t*2)
		#puts "%04X" % ptrOffset
		ptrData = (@romBytes[ptrOffset] + (@romBytes[ptrOffset+1] << 8))
		#puts "%04X" % ptrData
		strOffset = ptrData + ptrTableOffset
		currentOffset = strOffset
		strBytes = Array.new
		while @romBytes[currentOffset] != 0xff
			strBytes.push @romBytes[currentOffset]
			currentOffset += 1
		end
		exportArr.push ({ "ptrOffset" => ("%08X" % ptrOffset),\
						  "ptrBytes" => ("%04X" % ptrData),\
						  "strOffset" => ("%08X" % strOffset),\
						  "strBytes" => (strBytes.join(" ")),\
						  "strText" => (decodeString strBytes),\
						  "translation" => "" })
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	#strings limit - CA50
	ptrs = Array.new
	strs = Array.new
	linesDict = Hash.new
	ptrTableOffset = 0x02b310
	strsOffset = 0x01a010
	startOffset = 0
	currentOffset = startOffset
	
	# Creating dictionary for strings compression
	dict = Hash.new
	importArr.each do |row|
		if !(row["translation"].nil? || row["translation"].length == 0)
			row["translation"].split(/[^'\w]+/).each do |word|
				tmp = word.gsub("[","").gsub("]","").gsub("00's","")
				if tmp.length > 2
					if dict[tmp].nil?
						dict[tmp] = 1
					else
						dict[tmp] += 1
					end
				end
			end
		end
	end
	sorted = dict.sort_by { |word, count| count }.reverse
	dictBlockSize = 4092
	dictStrings = Hash.new
	dictStrLength = 0
	idx = 0
	sorted.each do |entry|
		if entry[1] > 2 && ((entry[0].length + 3) + (idx*2) + dictStrLength) < dictBlockSize
			# Dirty hack to avoid usage multiple of 0xff (stop byte)
			if idx % 0xff == 0
				dictStrings[("FF%04X" % idx)] = idx
				dictStrLength += 7
			else
				dictStrings[entry[0]] = idx
				dictStrLength += entry[0].length + 1
			end
			idx += 1
		end
	end
	# Prepare and insert dictionary block
	dictPtrs = Array.new
	dictStrs = Array.new
	dictOffset = 0
	tmpDict = dictStrings.invert
	tmpDict.size.times do |t|
		ptr = 0x9000 + (tmpDict.size*2) + dictOffset
		dictPtrs += [(ptr & 0x00ff), ((ptr & 0xff00) >> 8)]
		stBytes = encodeString tmpDict[t]
		dictOffset += stBytes.size
		dictStrs += stBytes
	end
	dictData = dictPtrs + dictStrs
	(dictData.size-1).times {|t| @romBytes[0x39010+t] = dictData[t]}
	
	importArr.each do |row|
		if row["translation"].nil? || row["translation"].length == 0
			strBytes = row["strBytes"].split(" ").map {|b| b.to_i}
			strBytes.push 0xff
		else
			if row["translation"].gsub(/\[FD ..\]/,"  ").length > 64 # A dirty way, can make errors for strings with byte insertions!
				puts "The line '" + row["translation"] + "' is too long! Cut at least " + (row["translation"].length - 64).to_s + " bytes."
			else
				string = row["translation"]
				# Add check for lines that longer than 20 letters
				msgLines = string.split("\n")
				msgLines.each do |line|
					#if line.length > 20 && !line.include?("]")
					if line.gsub(/\[FD ..\]/,"    ").length > 20
						puts "Line '" + line + "' is longer than 20 letters and will overlap the box!"
					end
				end
				# And check for messages that has more than 3 lines
				if msgLines.size > 3
					puts "Message '" + string + "' has more than three lines!"
				end
				
				words = string.split(/[^'\w]+/)
				foundWords = Array.new
				words.each do |word|
					if !dictStrings[word].nil?
						foundWords.push [word, dictStrings[word]]
					end
				end
				foundWords = foundWords.sort{|x, y| y[0].length <=> x[0].length} # Sort by words length from bigger to smaller, to prevent taking wrong ones
				foundWords.each do |dictWord|
					link = dictWord[1] + 0xfa00
					replace = "["+ ("%02X" % ((link & 0xff00) >> 8)) + " " + ("%02X" % (link & 0x00ff)) + "]"
					string.gsub!(dictWord[0],replace)
				end
				strBytes = encodeString string
			end
		end
		if linesDict[strBytes].nil?
			ptr = (currentOffset & 0x00ff), ((currentOffset & 0xff00) >> 8)
			linesDict[strBytes] = ptr
			ptrs += ptr
			strs += strBytes
			currentOffset += strBytes.size
		else
			ptrs += linesDict[strBytes]
		end
	end
	if strs.size > 0xd000
		puts "Text block is too big! You need to cut at least " + (strs.size - 0xd000).to_s + " bytes."
	else
		ptrs.size.times {|i| @romBytes[i+ptrTableOffset] = ptrs[i]}
		strs.size.times {|i| @romBytes[i+strsOffset] = strs[i]}
	end
	#puts strs.size
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
