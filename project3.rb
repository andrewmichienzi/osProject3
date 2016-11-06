#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
# encoding: utf-8
$PAGESIZE = 512
$NUMOFPAGES = 8
$TEXTTYPE = 'Text'
$DATATYPE = 'Data'
$FILE = "input3a.data"

#
#	Page Table Class
#
class PageTable
	def initialize(id, textSize, dataSize)
		@id = id
		@textSize = textSize
		@dataSize = dataSize
		self.createTable()
		self.addToMemory()
	end		
	def createTable()
		numOfTextPages = (@textSize.to_i/$PAGESIZE.to_f).ceil
		numOfDataPages = (@dataSize.to_i/$PAGESIZE.to_f).ceil
		@numTotalPages = numOfTextPages + numOfDataPages
		@textTable = Table.new(@id, $TEXTTYPE, numOfTextPages)
		
		@dataTable = Table.new(@id, $DATATYPE, numOfDataPages)
	end
	def addToMemory()
		@textTable.addTableToMemory()
		@dataTable.addTableToMemory()	
	end
end

#
#	Table Class
#
class Table
	def initialize(id, type, pagesNum)
		@type = type
		@pagesNum = pagesNum
		@id = id
		self.createTable()
	end
	def createTable()
		i = 0
		@pages = Array(0..@pagesNum)
		@frames = Array.new(@pagesNum)
	end
	def addTableToMemory() 
		i = 0
		while i < @pagesNum do
			frame = $memory.addPage(@id, @type, i)
			@frames[i] = frame
			i += 1
		end
	end
end


#
# 	Memory Class
#
class Memory
	def initialize(numOfPages)
		arrayHelp = numOfPages - 1
		@frames = Array(0..arrayHelp)
		@ids = Array.new(numOfPages, -1)
		@segments = Array.new(numOfPages, -1)
		@pageNums = Array.new(numOfPages, -1)
		@numOfPages = numOfPages	
	end
	def addPage(id, segment, pageNum)
		frame = self.getNextEmptyFrame()
		@ids[frame] = id
		@segments[frame] = segment
		@pageNums[frame] = pageNum
		return frame
	end
	def getNextEmptyFrame()
		i = 0
		while @ids[i] != -1
			i+=1
		end
		return i
	end
	def printMemory()
		puts "Frame#\tProcID\tSegment\tPage#"
		i = 0
		while i < @numOfPages do
			puts "#{@frames[i]}\t#{@ids[i]}\t#{@segments[i]}\t#{@pageNums[i]}"
			i += 1
		end
	end
	def removeMemory(id)
		i = 0
		while i < @numOfPages do
			if @ids[i] == id
				@ids[i] = -1
				@segments[i] = -1
				@pageNums[i] = -1
			end
		i +=1
		end
	end
end

















