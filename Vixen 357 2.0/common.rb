require 'open3'
require 'fileutils'
require 'csv'
require 'chunky_png'
require_relative 'Libs/compLib'
require_relative 'Libs/gfxLib'

@mainPath = File.expand_path(__dir__)
@originalROMPath = @mainPath + "/ROM_Original/Vixen 357 (Japan).md"
@patchedROMPath = @mainPath + "/ROM_Patched/Vixen 357 (WIP).md"
@vdaPath = @mainPath + "/Libs/ASM/vda68k.exe"
@vasmPath = @mainPath + "/Libs/ASM/vasmm68k_mot_win32.exe"
@tempPath = @mainPath + "/Temp/"
@emptySpaceCsvFile = @mainPath + "/Data/empty-spaces.csv"
@insertFont = @mainPath + "/GFX_Import/font3_8x16.png"
#@insertFont = @mainPath + "/GFX_Import/sgi_iris_4d_8x16.png"
namesCsvFile = @mainPath + "/Data/name-codes.csv"
exportHiraganaTBL = @mainPath + "/TBLs/export_dialogues_hiragana.tbl"
exportKatakanaTBL = @mainPath + "/TBLs/export_dialogues_katakana.tbl"

@exportHiragana = Hash.new
File.open(exportHiraganaTBL, encoding: 'SJIS').each {|i| @exportHiragana[i.split("=")[0].to_i(16)] = i.split("=")[1].gsub("\n", "").gsub("\r", "")}
@exportKatakana = Hash.new
File.open(exportKatakanaTBL, encoding: 'SJIS').each {|i| @exportKatakana[i.split("=")[0].to_i(16)] = i.split("=")[1].gsub("\n", "").gsub("\r", "")}
@nameCodes = Hash.new
CSV.read(namesCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t").each {|name| @nameCodes[name["Code"].to_i] = name["Name"]}


@romBytes = IO.binread(@patchedROMPath).bytes if File.exist?(@patchedROMPath)

def addSpace(spaces)
	if File.file?(@emptySpaceCsvFile)
		emptySpaces = CSV.read(@emptySpaceCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t").map{|r| r.to_h}
	else
		emptySpaces = Array.new
	end
	addArray = Array.new
	spaces.each do |space|
		addArray.push ({"offset" => ("0x%06x" % space[0]),"size" => space[1]})
		space[1].times {|t| @romBytes[space[0]+t] = 0xff}
	end
	emptySpaces = addArray + emptySpaces
	CSV.open(@emptySpaceCsvFile, "wb", :write_headers => true, :headers => emptySpaces.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| emptySpaces.each{|row| csv << row.values} end
end

def getSpace(size)
	size += 1 if size.modulo(2) > 0
	emptySpaces = CSV.read(@emptySpaceCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	proposedAddress = 0
	emptySpaces.each do |entry|
		next if proposedAddress > 0
		if entry["size"].to_i > size
			proposedAddress = entry["offset"].to_i(16)
			entry["size"] = entry["size"].to_i - size
			entry["offset"] = "0x%06x" % (entry["offset"].to_i(16) + size)
		end
	end
	if proposedAddress > 0
		CSV.open(@emptySpaceCsvFile, "wb", :write_headers => true, :headers => emptySpaces.headers, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| emptySpaces.each{|row| csv << row} end
		return proposedAddress
	else
		puts "No empty space left in the ROM!"
		return nil
	end
end

def insertData(bytes,ptrOffset)
	spaceOffset = getSpace bytes.size
	if spaceOffset.nil?
		puts "Can't find space to insert data!"
		return false
	else
		bytes.size.times {|i| @romBytes[spaceOffset+i] = bytes[i]}
		ptr = numToBytes(spaceOffset,4,false)
		@romBytes[ptrOffset..ptrOffset+3] = ptr
		return ptr
	end
end

def showBytes(bytes)
	puts "\t" + bytes.map{|b| "%02X" % b}.join(" ")
end

def bytesToNum(bytes,isLE)
	num = 0
	if isLE
		counter = 0.upto((bytes.size-1)).map {|b| b}
	else
		counter = (bytes.size-1).downto(0).map {|b| b}
	end
	bytes.size.times do |t|
		num += bytes[t] << (counter[t] * 8)
	end
	return num
end

def numToBytes(num,count,isLE)
	bytes = Array.new
	if isLE
		counter = 0.upto((count-1)).map {|b| b}
	else
		counter = (count-1).downto(0).map {|b| b}
	end
	counter.size.times do |t|
		bytes.push ((num >> (counter[t] * 8)) & 0xff)
	end
	return bytes
end

def readBytes(offset,counter)
	bytes = Array.new
	counter.times {|t| bytes.push @romBytes[offset+t]}
	return bytes
end

def decodeWithTable(strBytes,table)
	decodedString = String.new
	exportTBLFile = @mainPath + "/TBLs/" + table
	exportTBLHash = Hash.new
	File.open(exportTBLFile, encoding: 'SJIS').each {|i| exportTBLHash[i.split("=")[0].to_i(16)] = i.split("=")[1].gsub("\n", "").gsub("\r", "")}
	strBytes.each do |byte|
		if exportTBLHash[byte].nil?
			decodedString += ("[%02X]" % byte)
		else
			decodedString += exportTBLHash[byte]
		end
	end
	return decodedString
end

def decodeString (strBytes)
	decodedString = String.new
	offset = 0
	charTable = @exportHiragana
	while offset < strBytes.size
		if strBytes[offset] == 0x01
			decodedString += "\n"
		elsif strBytes[offset] == 0x02
			charTable = @exportKatakana
		elsif strBytes[offset] == 0x03
			charTable = @exportHiragana
		elsif strBytes[offset] == 0x06
			decodedString += "[portrait: %02X]#" % strBytes[offset+1] + @nameCodes[strBytes[offset+1]] + "#"
			offset += 1
		elsif strBytes[offset] == 0x07
			decodedString += "\n_________________\n"
		elsif strBytes[offset] == 0x08
			decodedString += "[pause]"
		elsif strBytes[offset] == 0x09
			decodedString += "[pause09]"
		elsif strBytes[offset] == 0x0a
			decodedString += "[music: %02X] " % strBytes[offset+1]
			offset += 1
		else
			currentByte = strBytes[offset]
			if charTable[currentByte].nil?
				decodedString += ("[%02X]" % strBytes[offset])
			else
				currentChar = charTable[currentByte]
				if strBytes[offset+1] == 0xde
					if currentChar.ord == 0x8345
						78.times {currentChar = currentChar.next}
					else
						currentChar = currentChar.next
					end
					offset += 1
				elsif strBytes[offset+1] == 0xdf
					2.times {currentChar = currentChar.next}
					offset += 1
				end
				decodedString += currentChar
			end
		end
		offset += 1
	end
	return decodedString
end

def encodeString (strText)
	strBytesArr = Array.new
	currentOffset = 0
	strText = strText
	while currentOffset < strText.length
		if strText[currentOffset] == "[" && strText[currentOffset+3] == "]"
			strBytesArr.push (strText[currentOffset+1] + strText[currentOffset+2]).to_i(16)
			currentOffset += 3
		else
			strBytesArr.push strText[currentOffset].ord
		end
		currentOffset += 1
	end
	return strBytesArr
end

def prepareString (text)
	lengthLimit = 20
	linesLimit = 4
	originalLine = text
	resultString = " "
	lineOffset = 0
	currentLineLength = 1
	currentLinesCount = 0
	while lineOffset <= text.length
		if text[lineOffset..lineOffset+2] == "\n_\n"
			resultString += "[08][07] "
			#resultString += "\n_______\n "
			lineOffset += 3
			currentLineLength = 1
			currentLinesCount = 0
		end
		if text[lineOffset] == "\n"
			resultString += "[01] "
			#resultString += "\n "
			lineOffset += 1
			currentLineLength = 1
			currentLinesCount += 1
		end
		if text[lineOffset] == "["
			commandString = String.new
			while text[lineOffset] != "]"
				commandString += text[lineOffset]
				lineOffset += 1
			end
			if commandString.length > 4
				if commandString.include?("[music:")
					resultString += "[0A][" + commandString.gsub("[music: ","")
				elsif commandString.include?("[portrait:")
					resultString += "[06][" + commandString.gsub("[portrait: ","")
				elsif commandString.include?("[pause")
					resultString += "[08"
				else
					puts "Unknown command '" + commandString + "'. Ignored."
				end
			else
				resultString += commandString
			end
		end
		if currentLineLength > lengthLimit || (currentLineLength == lengthLimit && text[lineOffset] != " ")
			lessThanLimit = false
			while resultString[-1] != " "
				lineOffset -= 1
				if lineOffset < 0
					puts "Error parsing line '" + originalLine + "'! Probably some words are too long."
					return originalLine
				end
				resultString = resultString[0..resultString.length-2]
				lessThanLimit = true
			end
			lineOffset -= 1
			resultString.rstrip!
			if lessThanLimit || text[lineOffset] == " "
				lineOffset += 1
			end
			currentLineLength = 1
			if (currentLinesCount + 1) > (linesLimit-1)
				if linesLimit == 1
					puts "Message '" + text + "' contains multiple lines with single line restriction!\n\n"
				end
				resultString += "[08][07] "
				#resultString += "\n_______\n "
				currentLinesCount = 0
			else
				resultString += "[01] "
				#resultString += "\n "
				currentLinesCount += 1
			end
		else
			if !text[lineOffset].nil?
				resultString += text[lineOffset]
			end
			currentLineLength += 1
			lineOffset += 1
		end
	end
	return resultString
end
