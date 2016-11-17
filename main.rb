require 'rubygems'
require 'sinatra'
require 'slim'
require_relative 'project3'

#
#	Main
#
get '/next' do
	$container.nextStep()
	$memory = $container.getMemory()
	if ($container.pageExists($pageId))
		$page = $container.getPageTable($pageId)
	else
		$pageId = -1
	end
	slim :memoryTable
end

get '/page/:pageId' do	
	$pageId = params['pageId'].to_i
	if $container.pageExists($pageId)
		$page = $container.getPageTable($pageId)
	else
		$pageId = -1
	end
	$memory = $container.getMemory()
	slim :memoryTable
end

get '/' do
	$pageId = -1
	$container = Container.new(8)
	$memory = $container.getMemory()
	slim :memoryTable
end

__END__

@@memoryTable
head
	title OS Project 3
	link href="css/style.css" rel='stylesheet' type='text/css'
	link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
	script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
	script src="https://maxcdn.bootstraapcdn.com/bootstrap/3.3.7js/bootstrap.min.js"
	script src="js/script.js"
h2 Memory Table
- i = 0
- h = $memory.getNumOfPages()
table class="table table-hover"
	thead
		tr
			td = "Frame #"
			td = "Proc ID"
			td = "Segment"
			td = "Page #"
	tbody
		-while i < h
			tr id="row_#{i}"
				td #{$memory.getFrame(i)}
				td #{$memory.getId(i)}
				td #{$memory.getSegment(i)}
				td #{$memory.getPage(i)}
				-i += 1
- if !$container.endOfInstructions()
	form method="get" action ="/next"
		input class="button" type="submit" value="Next"
- if $pageId != -1 and $page.class == PageTable
	h2 #{$page}
	- i = 0
	- index = 0
	- textTable = $page.getTextTable()
	- dataTable = $page.getDataTable()
	- textSize = textTable.getSize()
	- dataSize = dataTable.getSize()
	table class = "table table-hover"
		thead
			tr
				td = " "
				td = "Frame Number"
				td = "Size"
				td = "Segment"
		tbody
			-while i < textSize
				tr
					td #{index}
					td #{textTable.getFrame(i)}
					td #{textTable.getPageSize(i)}
					td = "Text"
					- i+= 1
					- index += 1
			- i = 0
			- while i < dataSize			
				tr 
					td #{index}
					td #{dataTable.getFrame(i)}
					td #{dataTable.getPageSize(i)}
					td = "Data"
					- i += 1
					- index += 1
javascript:
	var i = 0;
	var row = document.getElementById("row_"+i);
	while(row != null)
	{
		row.addEventListener('click', setPage, false);
		row.id = 2;
		i++;
		row = document.getElementById("row_"+i);
	}

	function setPage(evt)
	{
		
		row = evt.target.parentNode	
		id = row.cells[1].innerHTML
		if( id.trim() != "")
			window.location.href='/page/' + id;
	}
