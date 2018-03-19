@mainPath = File.expand_path(__dir__)
@originalROMPath = @mainPath + "/ROM_Original/Getsu Fuuma Den (Japan).nes"
@patchedROMPath = @mainPath + "/ROM_Patched/Getsu Fuuma Den (WIP).nes"
exportTBL = @mainPath + "/TBLs/export.tbl"
importTBL = @mainPath + "/TBLs/import.tbl"

@exportTable = Hash.new
File.open(exportTBL, encoding: 'UTF-8').each {|i| @exportTable[i.split("=")[0].to_i(16)] = i.split("=")[1].rstrip}

@importTable = Hash.new
File.open(importTBL, encoding: 'ASCII').each {|i| @importTable[i.split("=")[1].gsub("\n","")] = i.split("=")[0].to_i(16)}

@romBytes = IO.binread(@patchedROMPath).bytes if File.exist?(@patchedROMPath)


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

def encodeString (strText,strOffset)
	if strText.nil?
		puts ("No translation for line at offset: " + strOffset + ", inserting empty line.")
		return [0xff]
	end
	#strTextArr = strText.chars
	strBytesArr = Array.new
	#puts strTextArr[0..2]
	strArr = strText.split("[n]")
	2.times do |t|
		strBytes = Array.new
		if !strArr[t].nil?
			strTextArr = strArr[t].chars
			puts 'The line "' + strArr[t] + '" is too long!' if strTextArr.length > 0x1a
			strTextArr.each do |chr|
				#puts @importTable[chr]
				if !@importTable[chr].nil?
					strBytes.push @importTable[chr]
				else
					puts ("Unknown character: " + chr + " on " + strOffset + ", skipping...")
				end
			end
			strBytes.push 0xff
		else
			strBytes = [0x00,0xff]
		end
		strBytesArr += strBytes
	end
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
