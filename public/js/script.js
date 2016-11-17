function setTableOnClicks()
{
	var memoryTable = document.getElementById("memoryTable");
	if (memoryTable != null)
	{
		for (var i = 0; i < memoryTable.rows.length; i++)
		{
			memoryTable.rows[i].onclick = (function setCurrentPage(){
				return function () {
				alert ("Hello from row " + i);
			};
		}
	}
}

function test()
{
	alert ("HI");
}
