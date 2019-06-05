@mainPath = File.expand_path(__dir__)
@originalDisksPath = @mainPath + "/HDM_Disks/Original/"
@patchedDisksPath = @mainPath + "/HDM_Disks/Patched/"
@originalFilesPath = @mainPath + "/HDM_Files/Original/"
@patchedFilesPath = @mainPath + "/HDM_Files/Patched/"
@ndcPath = @mainPath + "/Libs/NDC.EXE"

def resolvePath (sourceType,fileName)
	if sourceType == "original"
		sourcePath = @originalFilesPath
	elsif sourceType == "patched"
		sourcePath = @patchedFilesPath
	else
		puts "Incorrect source type'" + sourceType + "'!"
		return nil
	end
	file = Dir[(sourcePath+"**/"+fileName)]
	if file.size == 1
		return file[0]
	elsif file.size > 1
		puts "More than one file was found for '" + fileName + "'!"
		return nil
	else
		puts "Nothing was found for '" + fileName + "'!"
		return nil
	end
end

def readFile (sourceType,fileName)
	filePath = resolvePath(sourceType,fileName)
	if filePath.nil?
		puts "Wasn't able to open '" + fileName + "'!"
		return nil
	else
		return IO.binread(filePath).bytes
	end
end

def writeFile (sourceType,fileName,fileBytes)
	filePath = resolvePath(sourceType,fileName)
	if filePath.nil?
		puts "Wasn't able to find '" + fileName + "'!"
		return false
	else
		IO.binwrite(filePath, fileBytes.pack('c*'))
		return true
	end
end

def readBytes (dataFile,offset)
	strBytes = Array.new
	# 0x01 - 0x07 - text color (0x08 - probably black?)
	# 0x09 + 2 bytes - position
	# 0x0a - switch to Shift-JIS
	# 0x0b - switch to custom font
	# 0x0c - new box
	# 0x0d - new line
	# 0x0e, 0x0f + 3 bytes - output some value from RAM?
	# 0x10 + 2 bytes - output some value from RAM?
	# 0x11 - ?
	
	while dataFile[offset] != 0 && offset < dataFile.size
		if dataFile[offset] == 0x09 || dataFile[offset] == 0x10
			strBytes += dataFile[offset..offset+2]
			offset += 3
		elsif dataFile[offset] == 0x0e || dataFile[offset] == 0x0f
			strBytes += dataFile[offset..offset+3]
			offset += 4
		else
			strBytes.push dataFile[offset]
			offset += 1
		end
	end
	return strBytes
end

@convTable = (readFile("original","CRUISER.X"))[0x3150..0x330f]

def decodeString (strBytes)
	decodedString = Array.new
	offset = 0
	kanaSwitch = true
	
	while offset < strBytes.size
		if strBytes[offset] == 0x1e
			if kanaSwitch then kanaSwitch = false else kanaSwitch = true end
		elsif strBytes[offset] == 0x09 || strBytes[offset] == 0x10
			3.times do |t|
				decodedString += ("[" + "%02X" % strBytes[offset] + "]").bytes
				offset += 1
			end
			offset -= 1
		elsif strBytes[offset] == 0x0e || strBytes[offset] == 0xf
			4.times do |t|
				decodedString += ("[" + "%02X" % strBytes[offset] + "]").bytes
				offset += 1
			end
			offset -= 1
		elsif strBytes[offset] == 0x0c
			decodedString += "\n_\n".bytes
		elsif strBytes[offset] == 0x0d
			decodedString.push "\n".ord
		elsif (strBytes[offset] >= 0x80 && strBytes[offset] <= 0x9f) || (strBytes[offset] >= 0xe0 && strBytes[offset] <= 0xef)
			decodedString += [strBytes[offset],strBytes[offset+1]]
			offset += 1
		elsif (strBytes[offset] >= 0x20 && strBytes[offset] <= 0x7f) || (strBytes[offset] >= 0xa0 && strBytes[offset] <= 0xdf)
			if strBytes[offset] >= 0xa0
				if kanaSwitch
					letterCode = (strBytes[offset])*2
				else
					letterCode = (strBytes[offset]-0x40)*2
				end
			else
				letterCode = (strBytes[offset]-0x20)*2
			end
			decodedString += [@convTable[letterCode],@convTable[letterCode+1]]
		else
			decodedString += ("[" + "%02X" % strBytes[offset] + "]").bytes
		end
		offset += 1
	end
	return decodedString.pack('c*').encode!('UTF-8', 'Shift_JIS')
end
# Offset in RAM for the first event: 0E8ADA
def parseCode (offset,code)
	codeHeader = (code >> 12)
	case codeHeader
		when 0x0
			codeType = "exit"
			return codeType
		when 0x2
			codeType = "sceneChange"
			sceneNumber = (code & 0x0fff)
			return (codeType + ": " + sceneNumber.to_s + " => " + "%04X" % (sceneNumber*4+4))
		when 0x3
			codeType = "skipNextOnBitCheck"
			bitNum = (code & 0x0007)
			var = (code & 0x07ff) >> 3
			if (code & 0x0800) != 0
				op = "set"
			else
				op = "clear"
			end
			return (codeType + ", bit " + bitNum.to_s + " is " + op + " on var 0x" + "%02X" % var.to_s)
		when 0x4
			codeType = "skipNextOnEqualOrHigher"
			var = (code & 0x00ff)
			value = (code & 0x0f00) >> 8
			return (codeType + ", var " + var.to_s + " compared with " + value.to_s)
		when 0x5
			codeType = "skipNextOnEqual"
			var = (code & 0x00ff)
			value = (code & 0x0f00) >> 8
			return (codeType + ", var " + var.to_s + " compared with " + value.to_s)
		when 0x6
			codeType = "skipCodes"
			skip = (code & 0x00ff)
			return (codeType + ": " + skip.to_s + " => " + "%04X" % (offset + 2 + skip*2))
		when 0x7
			codeType = "control7"
			cCode = (code & 0x0f00) >> 8
			function = ""
			case cCode
				when 0x0
					function = ": check if money is greater than value x 100"
				when 0x1
					function = ": Reduce money, value x 100"
				when 0x2
					function = ": Add money, value x 100"
				when 0x3
					function = ": Reduce energy, value x 100"
				when 0x4
					function = ": Add energy, value x 100"
				when 0x5
					function = ": Receive damage"
				when 0x6
					function = ": Change scene"
				when 0x7
					function = ": Set location"
				when 0x8
					function = ": Setting some scene vars?"
				when 0xc
					function = ": Set BG effect"
				when 0xd
					function = ": Set scene timeout"
				when 0xe
					function = ": Start battle"
				when 0xf
					function = ": Set facing direction"
			end
			# 0x0 => set bit 6 on A6(0x040b30)+0x0b47 if (yy * 100) > ($077144), clear if not ; check if enough money
			# 0x1 => value x 0x64 and subtract from A6(0x040b30)+0x09aa ; remove money
			# 0x2 => value x 0x64 and add to A6(0x040b30)+0x09aa ; add money
			# 0x5 => if value < 0x80 - AND with 0x3f and store to A6(0x040b30)+0x09d8
			# 0x9 => off = 0x077138, copy (off+2) to (off+3), copy (off+1) to (off+2), copy (off) to (off+1), copy value to (off); some cycled four bytes?
			# 0xa - ?
			# 0xb - ?
			# 0xF => write value to A6(0x040b30)+0x09a4 ; set facing direction
			value = (code & 0x00ff)
			return (codeType + ", cCode: " + cCode.to_s + ", value: " + value.to_s + function)
		when 0x8
			codeType = "bitOps"
			bitNum = (code & 0x0007)
			var = (code & 0x07ff) >> 3
			if (code & 0x0800) != 0
				op = "set"
			else
				op = "clear"
			end
			return (codeType + ", " + op + " bit " + bitNum.to_s + " on var 0x" + "%02X" % var.to_s)
		when 0x9
			codeType = "addVar"
			var = (code & 0x00ff)
			value = (code & 0x0f00) >> 8
			return (codeType + ", var " + var.to_s + " += " + value.to_s)
		when 0xa
			codeType = "textControl"
			speed = (code & 0x0f00) >> 8
			sfx = (code & 0x00ff)
			return (codeType + ", speed: " + speed.to_s + ", sfx: " + sfx.to_s)
		when 0xb
			codeType = "waitFrames"
			count = (code & 0x00ff)
			return (codeType + ": " + count.to_s)
		when 0xc
			codeType = "soundFX"
			count = (code & 0x00ff)
			return (codeType + ": " + count.to_s)
		when 0xd
			codeType = "screenMode"
			portraitCodes = {0x00 => "Daniel Gibson",
							 0x01 => "Brian Wright",
							 0x02 => "Drunk guy",
							 0x03 => "Girl_1",
							 0x04 => "Girl_2",
							 0x05 => "Girl_3",
							 0x06 => "Yoko Hidari",
							 0x07 => "MechanicShop",
							 0x08 => "Masashi Clark",
							 0x09 => "Ed Huey",
							 0x0a => "David Gede",
							 0x0b => "Max Todd",
							 0x0c => "Joshua Aykroyd",
							 0x0d => "Daigo Hidari",
							 0x0e => "UpgradeShop",
							 0x0f => "Carlin",
							 0x10 => "Max Boyd",
							 0x11 => "Man_1",
							 0x12 => "Man_2",
							 0x13 => "Peach",
							 0x14 => "Diana Gaddis",
							 0x15 => "Kenny Jones",
							 0x16 => "Girl_4",
							 0x17 => "Gaby Todd",
							 0x18 => "Girl_5",
							 0x19 => "Man_3",
							 0x1a => "Leonov",
							 0x1b => "Robot_1",
							 0x1c => "Robot_2",
							 0x1d => "Man_4",
							 0x1e => "Lean Kirk",
							 0x1f => "Man_5",
							 0x20 => "Max_wounded",
							 0x21 => "James Nicole",
							 0x22 => "Kent Mercury",
							 0x23 => "White Wolf's Leader",
							 0x24 => "Jack Unaia",
							 0x25 => "Cherenkov",
							 0x26 => "Max Boyd_alien"}
			placeCodes = {   0x32 => "Spaceship Workshop",
							 0x33 => "Shop Guns",
							 0x34 => "Bar",
							 0x35 => "Gravity Catapult",
							 0x36 => "Room",
							 0x37 => "Corridor"}
			sCode = (code & 0x00ff)
			if sCode < 0x63
				mode = "high res"
				if sCode < 0x32
					mode += ", op: setPortrait = " + portraitCodes[sCode].to_s
				else
					mode += ", op: setBackground = "  + placeCodes[sCode].to_s
				end
			else
				mode = "low res"
			end
			return (codeType + ": " + mode)
		when 0xe
			codeType = "wait" # not sure!
			mode = (code & 0x0f00) >> 8
			return (codeType + ", mode: " + mode.to_s)
		when 0xf
			codeType = "setBGM"
			tune = (code & 0x00ff)
			return (codeType + ": " + tune.to_s)
	end
end

def encodeString (strText)
	strBytesArr = Array.new
	currentOffset = 0
	#strText = strText.upcase
	while currentOffset < strText.length
		if strText[currentOffset] == "\n"
			strBytesArr.push 0xfe
		elsif strText[currentOffset] == "[" && strText[currentOffset+3] == "]"
			strBytesArr.push (strText[currentOffset+1] + strText[currentOffset+2]).to_i(16)
			currentOffset += 3
		else
			strBytesArr.push strText[currentOffset].ord
		end
		currentOffset += 1
	end
	return strBytesArr
end

def prepareString (text,highRes)
	#puts text
	originalLine = text
	linesLimit = 8
	resultString = String.new
	
	if highRes
		#lengthLimit = 20
		lengthLimit = 30
	else
		lengthLimit = 39
		resultString += "[0B]"
		#lengthLimit = 28
	end
	lineOffset = 0
	currentLineLength = 0
	currentLinesCount = 0
	while lineOffset <= text.length
		if text[lineOffset] == "["
			resultString += text[lineOffset..(lineOffset+3)]
			lineOffset += 4
		end
		if text[lineOffset..lineOffset+2] == "\n_\n"
			resultString += "[1F][0C]"
			lineOffset += 3
			currentLineLength = 0
			currentLinesCount = 0
		elsif text[lineOffset] == "\n"
			resultString += "[0D]"
			lineOffset += 1
			currentLineLength = 0
			currentLinesCount += 1
		end
		if currentLineLength >= lengthLimit
			lessThanLimit = false
			while text[lineOffset] != " "
				#puts text
				#puts lineOffset
				lineOffset -= 1
				if lineOffset < 0
					puts "Error parsing line '" + originalLine + "'! Probably some words are too long."
					return originalLine
				end
				resultString = resultString[0..resultString.length-2]
				lessThanLimit = true
			end
			if lessThanLimit || text[lineOffset] == " "
				text[lineOffset] = "\n"
			end
			currentLineLength = 0
			currentLinesCount += 1
		else
			if !text[lineOffset].nil?
				resultString += text[lineOffset]
			end
			lineOffset += 1
			currentLineLength += 1
		end
	end
	#puts resultString
	#puts
	#puts currentLinesCount
	if currentLinesCount > linesLimit
		#puts "Line '" + text + "' takes more than required lines!\n\n\n"
	end
	return resultString
end

def calculateLink (linkData,offset)
	if linkData < 0x8000
		return (linkData + offset + 2)
	else
		return ((offset + 1) - (0xffff - linkData))
	end
end
