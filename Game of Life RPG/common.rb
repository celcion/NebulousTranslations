@mainPath = File.expand_path(__dir__)
@originalROMPath = @mainPath + "/ROM_Original/RPG Jinsei Game (Japan).nes"
@patchedROMPath = @mainPath + "/ROM_Patched/RPG Jinsei Game (WIP).nes"

exportTBL = @mainPath + "/TBLs/export.tbl"
exportUITBL = @mainPath + "/TBLs/export_ui.tbl"
importTBL = @mainPath + "/TBLs/import.tbl"


@exportTable = Hash.new
File.open(exportTBL, encoding: 'SJIS').each {|i| @exportTable[i.split("=")[0].to_i(16)] = i.split("=")[1].rstrip}
@exportUITable = Hash.new
File.open(exportUITBL, encoding: 'SJIS').each {|i| @exportUITable[i.split("=")[0].to_i(16)] = i.split("=")[1].rstrip}

@importTable = Hash.new
File.open(importTBL, encoding: 'SJIS').each {|i| @importTable[i.split("=")[1].gsub("\n","")] = i.split("=")[0].to_i(16)}
@importTable["="] = 0x8d

@romBytes = IO.binread(@patchedROMPath).bytes if File.exist?(@patchedROMPath)

def decodeString (strBytes)
	decodedString = Array.new
	offset = 0
	while offset < strBytes.size
		if strBytes[offset] == 0xfd
			offset += 1
			decodedString.push ("[FD %02X]" % strBytes[offset])
		elsif strBytes[offset] == 0xfe
			decodedString.push "\n"
		else
			if @exportTable[strBytes[offset]].nil?
				decodedString.push ("[%02X]" % strBytes[offset])
			else
				decodedString.push @exportTable[strBytes[offset]]
			end
		end
		offset += 1
	end
	return decodedString.join
end

def encodeString (strText)
	strBytesArr = Array.new
	currentOffset = 0
	#strText = strText.upcase
	while currentOffset < strText.length
		if strText[currentOffset] == "\n"
			strBytesArr.push 0xfe
		elsif strText[currentOffset] == "[" && strText[currentOffset+6] == "]"
			strBytesArr.push (strText[currentOffset+1] + strText[currentOffset+2]).to_i(16)
			strBytesArr.push (strText[currentOffset+4] + strText[currentOffset+5]).to_i(16)
			currentOffset += 6
		elsif @importTable[strText[currentOffset]].nil?
			puts ("Not can't find character " + strText[currentOffset] + " in the string " + strText)
		else
			strBytesArr.push @importTable[strText[currentOffset]]
		end
		currentOffset += 1
	end
	strBytesArr.push 0xff
	return strBytesArr
end

def encodeUI (x,tx)
	if tx == "\u0019"
		return x.to_i(16)
	elsif tx == "\u3000" || tx.nil?
		return (encodeString " ")[0]
	elsif tx.length == 2
		return tx.to_i(16)
	else
		return (encodeString tx)[0]
	end
end

def prepareString (string)
	if string.nil? 
		return string
	end
	if string.include? "[FE]"
		return string
	end
	lengthLimit = 20
	textArr = string.split(" ")
	resultString = ""
	tmpString = ""
	lines = 1
	0.upto(textArr.size-1) do |ct|
		if (tmpString + " " + textArr[ct]).size > lengthLimit
			resultString += tmpString.rstrip + "[FE]"
			tmpString = ""
			tmpString += textArr[ct] + " "
			lines += 1
		else
			tmpString += textArr[ct]
			tmpString += " "
		end
	end
	if lines > 3
		puts ("The line: '" + string + "' is too long, skipping...")
		return nil
	else
		resultString += tmpString.rstrip
		return resultString
	end
end
