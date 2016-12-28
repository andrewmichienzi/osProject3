#!/usr/bin/ruby 
# encoding: utf-8
$PAGESIZE = 512
$NUMOFPAGES = 8
$TEXTTYPE = 'Text'
$DATATYPE = 'Data'
$FILE = "input3c.data"

#
#	Page Table Class
#	This class will hold the size of the Process pages and holds two Table
#	Classes to distinguish between text and data pages
#
class PageTable
	def initialize(id, textSize, dataSize)
		@id = id
		@textSize = textSize
		@dataSize = dataSize
		self.createTable()
		@deleted = false;
	end		
	def createTable()
		numOfTextPages = (@textSize.to_i/$PAGESIZE.to_f).ceil
		numOfDataPages = (@dataSize.to_i/$PAGESIZE.to_f).ceil
		@numTotalPages = numOfTextPages + numOfDataPages
		@textTable = Table.new(@id, $TEXTTYPE, numOfTextPages, @textSize)
		@dataTable = Table.new(@id, $DATATYPE, numOfDataPages, @dataSize)
	end
	def addToMemory(memory)
		@textTable.addTableToMemory(memory)
		@dataTable.addTableToMemory(memory)	
	end

	def getId()
		return @id
	end

	def setDelete(value)
		@deleted = value
	end
		
	def getTextTable()
		return @textTable
	end

	def getDataTable()
		return @dataTable
	end
end

#
#	Table Class
#	Table class actually holds the information needed in each page. It
#	holds the page id, the sizes of each frame, the page numbers of where
#	the pages are in memory, and the type (text or data)
#
class Table
	def initialize(id, type, pagesNum, size)
		@type = type
		@pagesNum = pagesNum
		@id = id
		@size = size
		@sizes = Array(@pagesNum)
		self.createTable()
	end
	def createTable()
		i = 0
		tempSize = @size.to_i
		while i < (@pagesNum - 1)
			@sizes[i] = $PAGESIZE
			tempSize -= $PAGESIZE
			i += 1
		end
		@sizes[@pagesNum-1] = tempSize
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

	def getSize()
		return @pagesNum
	end
	
	def getPageSize(i)
		return @sizes[i]		
	end

	def getFrame(i)
		return @frames[i]
	end
end


#
# 	Memory Class
# 	This class holds all meta data for where pages are stored, the process
# 	ids that are associated with each frame, the segment type (text or data)
# 	and the number of pages in the memory. This is designed to be variable
# 	if need be.
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
		if @ids[i] == -1 
			return " "
		end
		return @ids[i]
	end

	def getSegment(i)
		if @segments[i] == -1
			return " "
		end
		return @segments[i]
	end
	
	def getPage(i)
		if @pageNums[i] == -1
			return " "
		end
		return @pageNums[i]
	end
end

# 
# 	Container 
# 	The container holds memory and instructions as well as new page tables
# 	that are coming in. Some issues that I would have changed if I had
# 	more time. 
#
# 	Previous button is basically just reversing the last instruction. 
# 	There is a bug though. It will store instructions by the first available
# 	frame and not by where the frames were originally. If I had more time,
# 	I would change it by looking at the old process' page table. I could
# 	Do this in 2 hours
#
# 	I'm holding all of the page tables in the array, but I feel like
# 	the page tables are just thrown into the array. I don't have an
# 	elegant way of holding them. This was low priority.
#

class Container
	def initialize(numOfPages)
		@memory = Memory.new(numOfPages)
		@instruction = 0;
		@instructions = Array.new
		@pageTables = Array.new
		@numOfInstructions = 0
		@name = "Andrew"
		@currentPage = -1
		self.loadInstructions()
	end

	def loadInstructions()
		File.open($FILE).each do |line|
			@instructions.push line
			@numOfInstructions += 1
		end
	end

	def isFirstInstruction()
		if @instruction == 0
			return true
		else
			return false
		end
	end

	def nextStep()
		array = @instructions[@instruction].split(/ /)
		if array[2] == nil
			@memory.removeMemory(array[0])
			if array[0] == @currentPage
				@currentPage = -1
				puts 'current page reset'
			end
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
			removePageTable(array[0])
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

	def getPageTable(id)
		i = 0
		while i < $memory.getNumOfPages()
			page = @pageTables[i]
			if page.class == PageTable
				pageId = page.getId()
				if pageId.to_i == id.to_i
					return @pageTables[i]
				end
			end
			i += 1	
		end
	end
	
	def getCurrentPage()
		if @currentPage == -1
			return -1
		else
			return self.getPageTable(@currentPage)
		end
	end
	
	def setCurrentPage(id)
		@currentPage = id	
	end
	def pageExists(id)
		num = $memory.getNumOfPages().to_i
		i = 0
		while i < num
			if $memory.getId(i).to_i == id.to_i
				return true
			end
			i += 1
		end
		return false
	end
	def getLastInstruction()
		if @instruction != 0
			return @instructions[@instruction - 1]
		else
			return " "
		end
	end
	
	def getInstructionNum()
		return @instruction
	end
end

#
# MAIN
#

=begin
container = Container.new($NUMOFPAGES)
container.start()
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


