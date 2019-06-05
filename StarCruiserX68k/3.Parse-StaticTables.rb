puts
puts "Parse-StaticTables"
start_time = Time.now

require "csv"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/staticExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/staticImport.csv"

if mode == "export"
	staticTable = [{:file=>"EVENT.X",  :offset=>0x12e2,:length=>16,:entries=>47},
				   {:file=>"USEITEM.X",:offset=>0x007a,:length=>16,:entries=>47}]
	
	exportArr = Array.new
	staticTable.each do |staticBlock|
		dataFile = readFile("original",staticBlock[:file])
		staticBlock[:entries].times do |tm|
			strOffset = staticBlock[:offset] + (tm * staticBlock[:length])
			currentStrOffset = strOffset
			strBytes = Array.new
			while dataFile[currentStrOffset] != 0
				strBytes.push dataFile[currentStrOffset]
				currentStrOffset += 1
			end
			while dataFile[currentStrOffset] == 0 && currentStrOffset < (strOffset + staticBlock[:length])
				currentStrOffset += 1
			end
			strLimit = currentStrOffset - strOffset - 1
			extraBytes = Array.new
			while currentStrOffset <= (strOffset + staticBlock[:length]-1)
				extraBytes.push dataFile[currentStrOffset]
				currentStrOffset += 1
			end
			exportArr.push ({ 	"fileName" => staticBlock[:file],\
								"strOffset" => ("%04X" % strOffset),\
								"strBytes" => (strBytes.join(" ")),\
								"extraBytes" => (extraBytes.join(" ")),\
								"strLimit" => strLimit,\
								"strText" => (decodeString strBytes),\
								"translation" => "" })
		end
	end
	CSV.open(exportCsvFile, "wb", :write_headers => true, :headers => exportArr.first.keys, :encoding => "utf-8", :col_sep => "\t", :row_sep => "\r\n", :force_quotes => true) do |csv| exportArr.each{|row| csv << row.values} end
elsif mode == "import"
	importArr = CSV.read(importCsvFile, :encoding => "utf-8", :headers => true, :col_sep => "\t")
	groupArr = (importArr.group_by{|line| line["fileName"]})
	groupArr.each do |file|
		dataFile = readFile("patched",file[0])
		file[1].each do |staticString|
			strOffset = staticString["strOffset"].to_i(16)
			if !(staticString["translation"].nil? || staticString["translation"].length == 0)
				strLength = staticString["strLimit"].to_i
				strOffset = staticString["strOffset"].to_i(16)
				if staticString["translation"].length > strLength
					puts "Translation string '" + staticString["translation"] + "' is too long! Skipping..."
				else
					strBytes = encodeString staticString["translation"]
					while strBytes.size < strLength
						strBytes.push 0
					end
					strBytes.push 0
					strBytes += staticString["extraBytes"].split(" ").map{|b| b.to_i}
					strBytes.size.times {|i| dataFile[strOffset+i] = strBytes[i]}
				end
			end
		end
		if !writeFile("patched",file[0],dataFile)
			puts "Unable to write byte patch for '" + file[0] + "' file!"
		end
	end
end

end_time = Time.now
puts "Done!"
puts "Running time: " + (end_time - start_time).to_s + " seconds."
