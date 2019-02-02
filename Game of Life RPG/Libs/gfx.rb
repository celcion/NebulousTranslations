require 'chunky_png'

#@colors = [ChunkyPNG::Color('black'),ChunkyPNG::Color('black @ 0.7'),ChunkyPNG::Color('black @ 0.3'),ChunkyPNG::Color('white')]
@colors = [ChunkyPNG::Color.rgba(0,0,0,255),ChunkyPNG::Color.rgba(85,85,85,255),ChunkyPNG::Color.rgba(170,170,170,255),ChunkyPNG::Color.rgba(255,255,255,255)]

def drawTile(image,bytes,xPos,yPos)
	bp1 = bytes[0..7]
	bp2 = bytes[8..15]
	8.times do |r|
		8.times do |b|
			image[xPos,yPos] = @colors[(("%08b" % bp1[r])[b] + ("%08b" % bp2[r])[b]).to_i(2)]
			xPos += 1
		end
		yPos += 1
		xPos -= 8
	end
	return image
end

def readTile(image,xPos,yPos)
	#puts "%02b" % @colors.index(image[2,3])
	bp1Bytes = Array.new
	bp2Bytes = Array.new
	8.times do |r|
		bp1 = String.new
		bp2 = String.new
		8.times do |p|
			if @colors.index(image[xPos,yPos]).nil?
				#puts image[xPos,yPos]
				#puts ChunkyPNG::Color.to_hex(image[xPos,yPos])
				color = ChunkyPNG::Color.rgba(0,0,0,255)
				puts "Warning! Unknown color " + ChunkyPNG::Color.to_hex(image[xPos,yPos],include_alpha = false) + " at x: " + xPos.to_s + ", y: " + yPos.to_s + "! Using black instead."
			else
				color = @colors.index(image[xPos,yPos])
			end
			#puts ChunkyPNG::Color.to_hex(image[xPos,yPos])
			bps = "%02b" % color
			bp1 += bps[0]
			bp2 += bps[1]
			xPos += 1
		end
		bp1Bytes.push bp1.to_i(2)
		bp2Bytes.push bp2.to_i(2)
		yPos += 1
		xPos -= 8
	end
	return bp1Bytes + bp2Bytes
end

def drawMap(offset,tiles,lines)
	image = ChunkyPNG::Image.new(tiles*8, lines*8, ChunkyPNG::Color::TRANSPARENT)
	lines.times do |y|
		tiles.times do |x|
			bytes = @romBytes[offset..(offset+15)]
			image = drawTile(image,bytes,(x*8),(y*8))
			offset += 16
		end
	end
	return image
end

def drawMap16(offset,tiles,lines)
	image = ChunkyPNG::Image.new(tiles*16, lines*16, ChunkyPNG::Color::TRANSPARENT)
	lines.times do |y|
		tiles.times do |x|
			2.times do |xt|
				2.times do |yt|
					bytes = @romBytes[offset..(offset+15)]
					image = drawTile(image,bytes,(xt*8+x*16),(yt*8+y*16))
					offset += 16
				end
			end
			
		end
	end
	return image
end

def readMap(imagePath)
	image = ChunkyPNG::Image.from_file(imagePath)
	tiles = image.width / 8
	lines = image.height / 8
	imageArr = Array.new
	lines.times do |y|
		tiles.times do |x|
			imageArr += readTile(image,(x*8),(y*8))
		end
	end
	return imageArr
end