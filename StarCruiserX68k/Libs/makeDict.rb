def makeDictionary (stringsArr,keysLimit,dictSizeLimit)
	stripValues = true
	
	tmpDict = Hash.new
	wordSize = 3
	stringsArr.each do |message|
		windowSize = message.length
		while windowSize >= wordSize
			(message.length - windowSize + 1).times do |t|
				part = message[t..(t+windowSize-1)]
				if tmpDict[part].nil?
					tmpDict[part] = 1
				else
					tmpDict[part] += 1
				end
			end
			windowSize -= 1
		end
	end

	tmpDict.select!{|k,v| v > 3}
	finDict = Hash.new

	groupArr = (tmpDict.group_by{|count| count[1]})

	groupArr.keys.each do |key|
		tmpVars = Array.new
		lastValue = nil
		filtered = Hash.new
		groupArr[key].sort{|x, y| y[0].length <=> x[0].length}.each do |gVal|
			if tmpVars.size < 1
				tmpVars.push gVal[0]
				#finDict[gVal[0]] = key
				finDict[gVal[0]] = key*(gVal[0].length-2)
			else
				uniquePart = true
				tmpVars.each {|var| if !(var.index(gVal[0]).nil?) then uniquePart = false end}
				if uniquePart
					tmpVars.push gVal[0]
					#finDict[gVal[0]] = key
					finDict[gVal[0]] = key*(gVal[0].length-2)
				end
			end
		end
	end

	finDict = finDict.sort{|x, y| y[0].length <=> x[0].length}

	sorted = Hash.new
	stringsAll = stringsArr.join("\t")
	stringsAllSize = stringsAll.size
	finDict.each do |dEntry|
		if stripValues
			string = dEntry[0].strip
		else
			string = dEntry[0]
		end
		#if (!(string.include?("[") || string.include?("]")) and string.length > 4) || ((string.include?("[") && string.include?("]")) and string.length > 6)
		if (!(string.include?("[") || string.include?("]")) and string.length > 3)
		#if string.length > 4
			numHits = stringsAll.scan(string)
			if numHits.size > 3
				stringsAll.gsub!(string,"  ")
				sorted[string] = (string.length-2)*numHits.size
			end
		end
	end
	maxSave = stringsAllSize - stringsAll.size
	sorted = sorted.sort_by { |word, count| count }.reverse

	dictExport = Array.new
	dictLength = 0
	dictKeys = 0
	dictSave = 0
	sorted.each do |dictKey|
		if ((dictKey[0].length + dictLength) + (dictKeys * 2)) <= dictSizeLimit && dictKeys < keysLimit
			dictExport.push dictKey[0]
			dictLength += dictKey[0].length + 3
			dictSave += dictKey[1]
			dictKeys += 1
		end
	end
	
	return dictExport
end