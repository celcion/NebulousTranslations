puts
puts "Parse-GFX"
start_time = Time.now

require_relative 'common'
require_relative 'Libs/gfx'

mode = "import" # export, import

@colors = [ChunkyPNG::Color(:black),ChunkyPNG::Color(:lightblue),ChunkyPNG::Color(:blue),ChunkyPNG::Color(:white)]
if mode == "export"
	tilemapOffsets = [0x041010, 0x40010]
	tilemapOffsets.each do |tm|
		image = drawMap(tm,16,16)
		imageName = @mainPath + "/GFX_Export/0x%08x" % tm.to_s + ".png"
		image.save(imageName, :interlace => true)
	end
elsif mode == "import"
	Dir[@mainPath + "/GFX_Import/*.png"].each do |f|
		tm = f.split("/").last.split(".")[0].to_i(16)
		imageData = readMap(f)
		imageData.size.times { |i| @romBytes[i+tm] = imageData[i] }
		
	end
	IO.binwrite(@patchedROMPath, @romBytes.pack('c*'))
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
