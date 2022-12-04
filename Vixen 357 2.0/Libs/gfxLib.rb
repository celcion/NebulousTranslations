def drawFonts(bytes)
	imgWidth = 128
	imgHeight = 1024
	image = ChunkyPNG::Image.new(imgWidth, imgHeight, ChunkyPNG::Color::TRANSPARENT)
	xAxis = 0
	yAxis = 0

	bytes.each do | byte|
		1.downto(0) do |bp|
			4.times do |p|
				if byte[p + bp*4] > 0
					image[xAxis,yAxis+(p*256)] = "white"
				else
					image[xAxis,yAxis+(p*256)] = "black"
				end
			end
			xAxis +=1
			if xAxis.modulo(8) == 0
				xAxis -= 8
				yAxis += 1
				if yAxis.modulo(8) == 0
					xAxis += 8
					yAxis -= 8
					if xAxis >= imgWidth
						xAxis = 0
						yAxis += 8
					end
				end
			end
		end
	end
	return image
end

def readFonts(imgPath)
	img = ChunkyPNG::Image.from_file(imgPath)
	tileBytes = Array.new
	12.times do |y|
		16.times do |x|
			part = img.crop(x * 8, (y+4) * 8, 8, 8)
			byte = 0
			8.times do |line|
				8.times do |pixel|
					byte = byte << 4
					if part[pixel,line] > 0xff
						#byte += 8
						byte += 15
					else
						byte += 0
					end
				end
			end
			tileBytes += numToBytes(byte,32,false)
		end
	end
	return tileBytes
end
