puts
puts "Parse-GFX"
start_time = Time.now

require_relative 'common'
require_relative 'Libs/gfx'

mode = "import" # export, import

if mode == "export"
	tilemapOffsets = [0x045010,0x04b010,0x04f010,0x050010,0x053010,0x057010,0x05f010]
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
