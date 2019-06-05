puts
puts "Parse-PTRBlocks"
start_time = Time.now

require "csv"
require "pp"
require_relative 'common'

mode = "import" # export, import

exportCsvFile = @mainPath + "/SCRIPT_Export/ptrBlocksExport.csv"
importCsvFile = @mainPath + "/SCRIPT_Import/ptrBlocksImport.csv"

# WIP: Add duplicates searching on insertion

if mode == "export"
	ptrTable = [{:file=>"CRUISER.X",:offset=>0x73bc,:extraBytes=>0},
                {:file=>"DEMO.X",   :offset=>0x23ee,:extraBytes=>0},
				{:file=>"EVENT.X",  :offset=>0x175a,:extraBytes=>0},
				{:file=>"USEITEM.X",:offset=>0x0374,:extraBytes=>0},
				{:file=>"USEITEM.X",:offset=>0x075c,:extraBytes=>2},
				{:file=>"USEITEM.X",:offset=>0x0808,:extraBytes=>2},
				{:file=>"USEITEM.X",:offset=>0x08ae,:extraBytes=>2},
				{:file=>"USEITEM.X",:offset=>0x0970,:extraBytes=>2}]
	
	exportArr = Array.new
	ptrTable.each do |ptrBlock|
		dataFile = readFile("original",ptrBlock[:file])
		firstStringOffset = (dataFile[ptrBlock[:offset]] << 8) + dataFile[ptrBlock[:offset]+1] + ptrBlock[:offset]
		entries = (firstStringOffset - ptrBlock[:offset])/2
		lastStrOffset = 0
		entries.times do |tm|
			ptrOffset = ptrBlock[:offset] + tm*2
			strOffset = (dataFile[ptrOffset] << 8) + dataFile[ptrOffset+1] + ptrBlock[:offset]
			if lastStrOffset > strOffset && ptrBlock[:file] == "EVENT.X"
				shiftBack = "-" + (lastStrOffset - strOffset).to_s
			else
				shiftBack = String.new
			end
			strBytes = readBytes(dataFile,strOffset)
			currentStrOffset = strOffset + strBytes.size + 1
			extraBytes = Array.new
			ptrBlock[:extraBytes].times do |et|
				extraBytes.push dataFile[(currentStrOffset+et)]
			end
			if shiftBack.length > 0
				strBytes = Array.new
			end
			lastStrOffset = currentStrOffset
			exportArr.push ({ 	"fileName" => ptrBlock[:file],\
								"ptrBlock" => ("%04X" % ptrBlock[:offset]),\
								"ptrOffset" => ("%04X" % ptrOffset + shiftBack),\
								"strOffset" => ("%04X" % strOffset),\
								"strBytes" => (strBytes.join(" ")),\
								"extraBytes" => (extraBytes.join(" ")),\
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
		linksOffsets = (dataFile[0x0e] << 8) + dataFile[0x0f]
		groupBlocks = (file[1].group_by{|line| line["ptrBlock"]})
		groupBlocks.values.each do |ptrBlock|
			insertBytes = Array.new
			overFlowBytes = Array.new
			ptrBlockOriginalSize = 0
			ptrBlock.each {|ptr| ptrBlockOriginalSize += (ptr["strBytes"].to_s.split(" ").size + ptr["extraBytes"].to_s.split(" ").size + 1) }
            ptrBlockOriginalSize = 72 if file[0] == "DEMO.X"
			insertOffset = ptrBlock[0]["strOffset"].to_i(16)
			overflowOffset = (dataFile[0x0e] << 8) + dataFile[0x0f] + 0x40
			ptrBlockOffset = ptrBlock[0]["ptrBlock"].to_i(16)
			
			currentInsertOffset = insertOffset
			currentOverflowOffset = overflowOffset
			lastOffset = 0
			ptrBlock.each do |ptrLine|
				ptrOffsetArr = ptrLine["ptrOffset"].split("-")
				ptrOffset = ptrOffsetArr[0].to_i(16)
				if ptrOffsetArr.size > 1
					relOffset = lastOffset - ptrBlockOffset - ptrOffsetArr[1].to_i
					ptrBytes = [((relOffset & 0xff00) >> 8),(relOffset & 0x00ff)]
					dataFile[ptrOffset..ptrOffset+1] = ptrBytes
					ptrBlockOriginalSize -= 1
					next
				end
				if ptrLine["translation"].nil? || ptrLine["translation"].length == 0
					appendLine = ptrLine["strBytes"].split(" ").map{|b| b.to_i}
					appendLine.push 0
					appendLine += ptrLine["extraBytes"].to_s.split(" ").map{|b| b.to_i}
				else
					if ptrLine["fileName"] == "USEITEM.X" && ptrLine["ptrBlock"] == "0374"
						prepLine = prepareString(ptrLine["translation"],true)
						#prepLine = prepareString("[0B]"+ptrLine["translation"],false)
						appendLine = encodeString prepLine
					else
						appendLine = encodeString ptrLine["translation"]
					end
					appendLine.push 0
					appendLine += ptrLine["extraBytes"].to_s.split(" ").map{|b| b.to_i}
				end
				
				if (insertBytes.size + appendLine.size) <= ptrBlockOriginalSize # change back to <= !!!
					relOffset = currentInsertOffset - ptrBlockOffset
					ptrBytes = [((relOffset & 0xff00) >> 8),(relOffset & 0x00ff)]
					insertBytes += appendLine
					currentInsertOffset += appendLine.size
					lastOffset = currentInsertOffset
				else
					relOffset = currentOverflowOffset - ptrBlockOffset
					ptrBytes = [((relOffset & 0xff00) >> 8),(relOffset & 0x00ff)]
					overFlowBytes += appendLine
					currentOverflowOffset += appendLine.size
					lastOffset = currentOverflowOffset
				end
				dataFile[ptrOffset..ptrOffset+1] = ptrBytes
			end
			ptrBlockOriginalSize.times {|t| dataFile[insertOffset+t] = 0}
			insertBytes.size.times {|i| dataFile[insertOffset+i] = insertBytes[i]}
			if overFlowBytes.size > 0
				overFlowBytes.push 0 if overFlowBytes.size.modulo(2) != 0
				dataFile = dataFile[0..overflowOffset-1] + overFlowBytes + dataFile[overflowOffset..dataFile.size-1]
				linksOffsets += overFlowBytes.size
				dataFile[0x0e] = (linksOffsets & 0xff00) >> 8
				dataFile[0x0f] = (linksOffsets & 0x00ff)
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
