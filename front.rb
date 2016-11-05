require 'rubygems'
require 'sinatra'
require 'slim'
require_relative 'project3'

#
#	Main
#
get '/' do
	$memory = Memory.new($NUMOFPAGES)
	slim :memoryTable
end
=begin
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

test1 = PageTable.new(0, 1044, 940)
$memory.printMemory()
test2 = PageTable.new(1, 536, 256)
=end
get '/' do
	slim :memoryTable
end
__END__

@@memoryTable
h2 Memory Table
table
	-$memory.frames.each do |i|
	tr
		td.frame = $memory.frames[i]
		td.id = $memory.ids[i]
		td.segment = $memory.segments[i]
		td.pageNum = $memory.pageNums[i]
