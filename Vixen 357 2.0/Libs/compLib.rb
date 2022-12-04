require 'compress/lzss'

def unpack02(bytes,offset)
	patternTableOffset = offset + 4
	patternTableSize = bytesToNum(bytes[offset+2..offset+3],false)
	patternDataOffset = patternTableOffset + patternTableSize
	
	currentPTableOffset = patternTableOffset
	currentPDataOffset = patternDataOffset
	decodedData = Array.new
	
	while currentPTableOffset < patternDataOffset
		pattern = bytesToNum(bytes[currentPTableOffset..currentPTableOffset+3],false)

		decodedPattern = Array.new
		31.downto(0) do |b|
			if pattern[b] > 0
				decodedPattern.push bytes[currentPDataOffset]
				currentPDataOffset += 1
			else
				decodedPattern.push 0
			end
		end
		
		pArr = Array.new
		pArr.push bytesToNum(decodedPattern[0x18..0x1f],false)
		pArr.push bytesToNum(decodedPattern[0x08..0x0f],false)
		pArr.push bytesToNum(decodedPattern[0x10..0x17],false)
		pArr.push bytesToNum(decodedPattern[0x00..0x07],false)

		decodedNum = 0
		63.downto(0) do |b|
			4.times do |pt|
				decodedNum = decodedNum << 1
				decodedNum += pArr[pt][b]
			end
		end
		decodedData += numToBytes(decodedNum,32,false)
		
		currentPTableOffset += 4
	end
	#puts "Compressed size: " + (currentPDataOffset-offset-1).to_s + " bytes."
	return decodedData
end

def pack02(bytes)
	codedData = Array.new
	(bytes.size/32).times do |t|
		tile = bytes[t*32..t*32+31]
		tileNum = bytesToNum(tile,false)
		pArr = Array.new(4,0)
		255.downto(0) do |b|
			pIdx = b % 4
			pArr[pIdx] = pArr[pIdx] << 1
			pArr[pIdx] += tileNum[b]
		end
		[0,2,1,3].each {|n| codedData += numToBytes(pArr[n],8,false)}
	end
	packedDict = Array.new
	packedData = Array.new
	(codedData.size/8).times do |p|
		dictPart = 0
		packPart = codedData[p*8..p*8+7]
		packPart.each do |byte|
			if byte > 0
				packedData.push byte
				dictNum = 1
			else
				dictNum = 0
			end
			dictPart = dictPart << 1
			dictPart += dictNum
		end
		packedDict.push dictPart
	end
	compressedData = [2,1] + numToBytes(packedDict.size,2,false) + packedDict + packedData
	return compressedData
end

def unpack03(bytes,offset)
	currentOffset = offset+1
	size = bytesToNum(bytes[currentOffset..currentOffset+1],false)
	currentOffset += 2
	decodedData = (Compress::LZSS.decode bytes[currentOffset..currentOffset+10000].pack('c*')).byteslice(0,size).bytes
	return decodedData
end

def pack03(bytes)
	compData = (Compress::LZSS.encode bytes.pack('c*')).bytes
	compressedData = [3] + numToBytes(bytes.size,2,false) + compData
	return compressedData
end

def unpackData(bytes,offset)
	if bytes[offset] == 3
		return unpack03(bytes,offset)
	elsif bytes[offset] == 2 && bytes[offset+1] == 1
		return unpack02(bytes,offset)
	else
		puts "Unknown packing algorithm or setting!"
	end
end