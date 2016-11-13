#!/usr/bin/ruby 
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
	end		
	def createTable()
		numOfTextPages = (@textSize.to_i/$PAGESIZE.to_f).ceil
		numOfDataPages = (@dataSize.to_i/$PAGESIZE.to_f).ceil
		@numTotalPages = numOfTextPages + numOfDataPages
		@textTable = Table.new(@id, $TEXTTYPE, numOfTextPages)
		
		@dataTable = Table.new(@id, $DATATYPE, numOfDataPages)
	end
	def addToMemory(memory)
		@textTable.addTableToMemory(memory)
		@dataTable.addTableToMemory(memory)	
	end
	def getId()
		return @id
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
	def addTableToMemory(memory) 
		i = 0
		while i < @pagesNum do
			frame = memory.addPage(@id, @type, i)
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
	
	def getNumOfPages()
		return @numOfPages
	end
	
	def getFrame(i)
		return @frames[i]
	end
	
	def getId(i)
		return @ids[i]
	end

	def getSegment(i)
		return @segments[i]
	end
	
	def getPage(i)
		return @pageNums[i]
	end
end

# 
# Container 
#

class Container
	def initialize(numOfPages)
		@memory = Memory.new(numOfPages)
		@instruction = 0;
		@instructions = Array.new
		@pageTables = Array.new
		@numOfInstructions = 0
		@name = "Andrew"
		loadInstructions()
	end

	def loadInstructions()
		File.open($FILE).each do |line|
			@instructions.push line
			@numOfInstructions += 1
		end
	end

	def nextStep()
		array = @instructions[@instruction].split(/ /)
		if array[2] == nil
			@memory.removeMemory(array[0])
			removePageTable(array[0])
		else
			pageTable = PageTable.new(array[0], array[1], array[2])
			pageTable.addToMemory(@memory)
			@pageTables.push pageTable
		end
		@instruction+=1
	end
	
	def previousStep()
		@instruction-=1
		array = @instructions[@instruction].split(/ /)
		if array[2] == nil 
			#must find the instruction that put this page into memory so we can re-store it
			findStoreInstruction(array[0])
		else
			@memory.removeMemory(array[0])
			#removePageTable(array[0])
		end
	end
	
	def removePageTable(id)
		@pageTables.delete_if do |pageTable|
			if pageTable.getId() == id
				true
			end
		end		
	end
		
	def findStoreInstruction(id)
		i = @instruction 
		while i > -1 do
			array = @instructions[i].split(/ /)
			if array[0] == id and array[2] != nil
				pageTable = PageTable.new(array[0], array[1], array[2])
				pageTable.addToMemory(@memory)
				@pageTables.push pageTable
				return
			end
			i -= 1
		end
	end

	def endOfInstructions()
		if @instruction == @numOfInstructions
			return true
		end
		return false
	end
	
	def printMemory()
		@memory.printMemory()
	end
	
	def start()
		while !self.endOfInstructions do
			
			print "instruction #{@instruction} > "
			i = gets.chomp
			if i == "n"
				self.nextStep()
			elsif i == "p"
				self.previousStep()
			end
			self.printMemory()		
		end
	end
	def getName()
		return @name
	end
	def getMemory()
		return @memory
	end
end

#
# MAIN
#

#container = Container.new($NUMOFPAGES)
#container.start()
=begin
$memory = Memory.new($NUMOFPAGES)
File.open($FILE).each do |line|
	puts "\n#{line}\n"
	array = line.split(/ /)
	if array[2] == nil	#halt
		$memory.removeMemory(array[0])
	else
		pageTable = PageTable.new(array[0], array[1], array[2])
	end
	$memory.printMemory()
	
end
=end



