require 'rubygems'
require 'sinatra'
require 'slim'
require_relative 'project3'

=begin
		puts "Frame#\tProcID\tSegment\tPage#"
		i = 0
		while i < @numOfPages do
			puts "#{@frames[i]}\t#{@ids[i]}\t#{@segments[i]}\t#{@pageNums[i]}"
			i += 1

			td.id = #{$memory.ids[i]}
			td.segment = #{$memory.segments[i]}
			td.page = #{$memory.pageNums[i]}
=end
#
#	Main
#
get '/next' do
	$container.nextStep()
	$memory = $container.getMemory()
	slim :memoryTable
end

get '/' do
	$container = Container.new(8)
	$memory = $container.getMemory()
	slim :memoryTable
end

__END__

@@memoryTable
h2 Memory Table
- i = 0
- h = $memory.getNumOfPages()
table
	thead
		tr
			th.frame = "Frame #"
			th.id = "Proc ID"
			td.segment = "Segment"
			td.page = "Page #"
	tbody
		-while i < h
			tr
				td #{$memory.getFrame(i)}
				td #{$memory.getId(i)}
				td #{$memory.getSegment(i)}
				td #{$memory.getPage(i)}
				-i += 1
- if !$container.endOfInstructions()
	form method="get" action ="/next"
		input class="btn btn-primary" type="submit" value="Next"

