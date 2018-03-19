@mainPath = File.expand_path(__dir__)
@originalROMPath = @mainPath + "/ROM_Patched/Shiryou Sensen (WIP).pce"
@patchedROMPath = @mainPath + "/ROM_Patched/Shiryou Sensen (WIP).pce"
exportTBL = @mainPath + "/TBLs/export.tbl"
importTBL = @mainPath + "/TBLs/import_new.tbl"

@exportTable = Hash.new
File.open(exportTBL, encoding: 'UTF-8').each {|i| @exportTable[i.split("=")[0].to_i(16)] = i.split("=")[1].rstrip}

@importTable = Hash.new
File.open(importTBL, encoding: 'ASCII').each {|i| @importTable[i.split("=")[1].gsub("\n","")] = i.split("=")[0].to_i(16)}
# SHITTY CODE! Needs to be fixed!
@importTable["="] = 0x73

#puts @importTable

@romBytes = IO.binread(@originalROMPath).bytes

@dakuten = @romBytes[0xe462..0xe492]
@handakuten = @romBytes[0xe458..0xe461]

def decodeString (strBytes)
	strTextArr = Array.new
	tmpOffset = 0
	while tmpOffset < strBytes.size
		if strBytes[tmpOffset] == 0xfe
			strTextArr.push "\n"
		else
			strTextArr.push @exportTable[strBytes[tmpOffset]]
		end
		tmpOffset += 1
	end
	return strTextArr.join
end

def decodeDoubleString (strBytes)
	halfSize = strBytes.size/2
	strLine = Array.new
	0.upto(halfSize-1) do |ch|
		if strBytes[ch] == 0
			strLine.push @exportTable[strBytes[ch+halfSize]]
		else
			if strBytes[ch] == 0x6d || strBytes[ch] == 0xb7
				char = @dakuten.index(strBytes[ch+halfSize])+0xc0
			else
				char = @handakuten.index(strBytes[ch+halfSize])+0xf0
			end
			strLine.push @exportTable[char]
		end
	end
	return strLine.join
end

def decodeMultiString (strBytes,length,count)
	fullStrArr = Array.new
	tmpOffset = 0
	previousLine = Array.new(length,0)
	0.upto(count-1) do |l|
		binArr = Array.new
		strArr = Array.new
		0.upto(length-1) do |c|
			binArr.push strBytes[tmpOffset]
			if strBytes[tmpOffset] == 0x6d || strBytes[tmpOffset] == 0x6e || strBytes[tmpOffset] == 0xb7 || strBytes[tmpOffset] == 0xb8
				strArr.push @exportTable[0]
			elsif previousLine[c] == 0x6d || previousLine[c] == 0xb7
				if strBytes[tmpOffset] != 0
					char = @dakuten.index(strBytes[tmpOffset])+0xc0
				else
					char = previousLine[c]
				end
				strArr.push @exportTable[char]
			elsif previousLine[c] == 0x6e || previousLine[c] == 0xb8
				if strBytes[tmpOffset] != 0
					char = @handakuten.index(strBytes[tmpOffset])+0xf0
				else
					char = previousLine[c]
				end
				strArr.push @exportTable[char]
			else
				strArr.push @exportTable[strBytes[tmpOffset]]
			end
			tmpOffset += 1
		end
		previousLine = binArr
		fullStrArr += strArr + ["\n"]
	end
	return fullStrArr.join
end

def encodeString (strText,strOffset)
	if strText.nil?
		puts ("No translation for line at offset: " + strOffset + ", inserting empty line.")
		return [0xff]
	end
	strTextArr = strText.chars
	strBytesArr = Array.new
	tmpOffset = 0
	while tmpOffset < strTextArr.size
		if strTextArr[tmpOffset] == "[" && strTextArr[tmpOffset+3] == "]"
			strBytesArr.push (strTextArr[tmpOffset+1]+strTextArr[tmpOffset+2]).to_i(16)
			tmpOffset += 3
			#puts "123"
		else
			#if !@importTable[strTextArr[tmpOffset].upcase].nil?
			if !@importTable[strTextArr[tmpOffset]].nil?
				#strBytesArr.push @importTable[strTextArr[tmpOffset].upcase]
				strBytesArr.push @importTable[strTextArr[tmpOffset]]
			else
				puts ("Unknown character: " + strTextArr[tmpOffset] + ", skipping...")
			end
		end
		tmpOffset += 1
	end
	strBytesArr.push 0xff
	return strBytesArr
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
	resultString += tmpString.rstrip
	return resultString
end
