puts
puts "Pack files to floppy images"
start_time = Time.now

require_relative 'common'
require 'fileutils'
require 'digest/md5'
require 'open3'

FileUtils.cp_r( (@originalDisksPath+"."), @patchedDisksPath, :preserve => false )

Dir.glob(@originalFilesPath + "*/*").each do |file|
	originalFile = IO.binread(file)
	patchedPath = file.gsub("/Original/","/Patched/")
	patchedFile = IO.binread(patchedPath)
	if (Digest::MD5.hexdigest originalFile) != (Digest::MD5.hexdigest patchedFile)
		nameArr = file.split("/")
		diskName = nameArr[-2]
		fileName = nameArr[-1]
		patchedDiskPath = @patchedDisksPath + "/" + diskName + ".xdf"
		stdin, stdout, stderr = Open3.popen3(@ndcPath + " d " + patchedDiskPath + " 0 " + fileName)
		if stdout.read.encode('UTF-8', 'Shift_JIS').strip != "正常に終了しました。"
			puts "Error deleting original file '" + fileName + "'!"
			puts stdout.read.encode('UTF-8', 'Shift_JIS')
		end
		stdin, stdout, stderr = Open3.popen3(@ndcPath + " p " + patchedDiskPath + " 0 " + patchedPath)
		if stdout.read.encode('UTF-8', 'Shift_JIS').strip != "正常に終了しました。"
			puts "Error inserting patched file '" + fileName + "'!"
			puts stdout.read.encode('UTF-8', 'Shift_JIS')
		end
		#puts stdout.read.encode('UTF-8', 'Shift_JIS')
	end
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
