<script language="Javascript" type="text/Javascript">

// Alternate Row Colors
function AplicarCebra (tableid)  {
   var table   = document.getElementById(tableid);
   var current = "evenline";   
   for (var i = 2; i < table.rows.length; i++) {
     table.rows[i].className = table.rows[i].className.replace(/ oddline/g, '');
     table.rows[i].className = table.rows[i].className.replace(/ evenline/g, '');
     table.rows[i].className += " " + current;
     current =   current == "evenline" ? "oddline" : "evenline";
   }
}

function SelectInstance(index,action){
 var id = 'tr_'+index;	 
 var tr = document.getElementById(id);
 if (action == 1) {
 	tr.className += ' highlighted';
 }
 else {
 	tr.className = tr.className.replace(/ highlighted/g, '');
 }
 return true;	
}


//Select Instance - PTTD REVIEW!!!
function SelectInstanceOrig (Object,Checkbox) {
   tr = Checkbox.parentNode.parentNode;
   mark_element = document.getElementById ('marked');
   if (mark_element) {
      mark_value = parseInt(mark_element.innerHTML);
   }
   cookie_text = GetCookie(Object+'_SELECTED');
   if (cookie_text == null)
   {
      SetCookie(Object+'_SELECTED','');
   }
   cookie_text = GetCookie(Object+'_UNSELECTED');
   if (cookie_text == null)
   {
      SetCookie(Object+'_UNSELECTED','');
   }
   if (Checkbox.checked)
   {
      if (mark_element)
      {
         mark_value += 1;
         mark_element.innerHTML = mark_value;
      }
      tr.className += ' highlighted';
      AddToCookie(Object+'_SELECTED',Checkbox.value);
      RemoveFromCookie(Object+'_UNSELECTED',Checkbox.value);
      return(true);
   }
   else
   {
      if (mark_element)
      {
         mark_value -= 1;
         mark_element.innerHTML = mark_value;
      }
      tr.className = tr.className.replace(/ highlighted/g, '');

      AddToCookie(Object+'_UNSELECTED',Checkbox.value);
      RemoveFromCookie(Object+'_SELECTED',Checkbox.value);
      return(false);
   }
}


//******************************* end DROPDOWN CONTENT ******************************
var slideDownInitHeight = new Array();
	var slidedown_direction = new Array();

	var slidedownActive = false;
	var contentHeight = false;
	var slidedownSpeed = 3; 	// Higher value = faster script
	var slidedownTimer = 7;	// Lower value = faster script
	function slidedown_showHide(boxId)
	{
		if(!slidedown_direction[boxId])slidedown_direction[boxId] = 1;
		if(!slideDownInitHeight[boxId])slideDownInitHeight[boxId] = 0;
		
		if(slideDownInitHeight[boxId]==0)slidedown_direction[boxId]=slidedownSpeed; else slidedown_direction[boxId] = slidedownSpeed*-1;
		
		slidedownContentBox = document.getElementById(boxId);
		var subDivs = slidedownContentBox.getElementsByTagName('DIV');
		for(var no=0;no<subDivs.length;no++){
			if(subDivs[no].className.match(/.*dhtmlgoodies_content.*/))slidedownContent = subDivs[no];	
		}

		contentHeight = slidedownContent.offsetHeight;
	
		slidedownContentBox.style.visibility='visible';
		slidedownActive = true;
		slidedown_showHide_start(slidedownContentBox,slidedownContent);
	}
	function slidedown_showHide_start(slidedownContentBox,slidedownContent)
	{

		if(!slidedownActive)return;
		slideDownInitHeight[slidedownContentBox.id] = slideDownInitHeight[slidedownContentBox.id]/1 + slidedown_direction[slidedownContentBox.id];
		if(slideDownInitHeight[slidedownContentBox.id] <= 0){
			slidedownActive = false;	
			slidedownContentBox.style.visibility='hidden';
			slideDownInitHeight[slidedownContentBox.id] = 0;
		}
		if(slideDownInitHeight[slidedownContentBox.id]>contentHeight){
			slidedownActive = false;	
		}
		slidedownContentBox.style.height = slideDownInitHeight[slidedownContentBox.id] + 'px';
		slidedownContent.style.top = slideDownInitHeight[slidedownContentBox.id] - contentHeight + 'px';
		aux = slidedownContent.innerHTML;
		slidedownContent.innerHTML = aux.replace(/\\n/gim, "<br>"); 

		setTimeout('slidedown_showHide_start(document.getElementById("' + slidedownContentBox.id + '"),document.getElementById("' + slidedownContent.id + '"))',slidedownTimer);	// Choose a lower value than 10 to make the script move faster
	}
	
	function setSlideDownSpeed(newSpeed)
	{
		slidedownSpeed = newSpeed;
		
	}
//******************************* end DROPDOWN CONTENT ******************************

//******************************* SELECT/DESELECT ALL ******************************
function seleccionar_todo(Object)
{
	var checkboxes = getElementsByAttribute(document.body, "input", "type", "checkbox");

	for (i=0; i<checkboxes.length; i++)
	{
		if (!checkboxes[i].checked)
		{
			checkboxes[i].checked=1;
			SelectInstance(Object, checkboxes[i]);
		}
	}
} 

function deseleccionar_todo(Object)
{
	var checkboxes = getElementsByAttribute(document.body, "input", "type", "checkbox");

	for (i=0; i<checkboxes.length; i++)
	{
		if (checkboxes[i].checked)
		{
			checkboxes[i].checked=0;
			SelectInstance(Object, checkboxes[i]);
		}
	}
} 
//******************************* end SELECT/DESELECT ALL  ******************************

//******************************* RESIZE COLUMNS ******************************
var markerHTML = "<>";
var minWidth = 1;
var dragingColumn = null;
var startingX = 0;
var currentX = 0;

function getNewWidth () 
{
	var newWidth = minWidth;
        if (dragingColumn != null) 
	{
		newWidth = parseInt (dragingColumn.parentNode.style.width);
                if (isNaN (newWidth)) 
		{
                    newWidth = 0;
                }
                newWidth += currentX - startingX;
                if (newWidth < minWidth) 
		{
                    newWidth = minWidth;
                }
	}
	return newWidth;
}

function columnMouseDown (event) 
{
	if (!event) 
	{
		event = window.event;
	}
        if (dragingColumn != null) 
	{
		ColumnGrabberMouseUp ();
	}
        startingX = event.clientX;
        currentX = startingX;
        dragingColumn = this;
        return true;
}

function columnMouseUp () 
{
	if (dragingColumn != null) 
	{
		dragingColumn.parentNode.style.width = getNewWidth ();
                dragingColumn = null;
	}
	return true;
}

function columnMouseMove (event) 
{
	if (!event) 
	{
		event = window.event;
	}
        if (dragingColumn != null) 
	{
		currentX = event.clientX;
                dragingColumn.parentNode.style.width = getNewWidth ();
                startingX = event.clientX;
                currentX = startingX;
	}
	return true;
}

function installTable (tableId) 
{
	var table = document.getElementById (tableId);
        if (table != null) 
	{
		document.body.onmouseup = columnMouseUp;
                document.body.onmousemove = columnMouseMove;
		var firstrow = 0;
		var tableHead;
		//if (document.tableform.active_editor.value == 1)
		//{
		//	firstrow = 1;
		//}
		tableHead = table.rows[firstrow];
		//alert(document.tableform.active_editor.value);
		//alert(document.tableform.show.value);
		//var spanes = tableHead.getElementsByTagName('span');
                for (j = 3; j < tableHead.cells.length-1; j++) 
		{
			var spanes  = tableHead.cells[j].getElementsByTagName('span');
			var column = tableHead.cells[j];
                        //var marker = document.createElement ("span");
                        //marker.innerHTML = markerHTML;
			spanes[spanes.length-1].style.cursor = "e-resize";
			spanes[spanes.length-1].onmousedown = columnMouseDown;
                        //marker.style.cursor = "move";
                        //marker.onmousedown = columnMouseDown;
                        //column.appendChild (marker);
                        if (column.offsetWidth < minWidth) 
			{
				column.style.width = minWidth;
			}
                        else 
			{
				column.style.width = column.offsetWidth;
			}
		}
		//spanes[spanes.length-1].innerHTML = '';
		var lastSpan = tableHead.cells[tableHead.cells.length-1].getElementsByTagName('span');
		lastSpan[lastSpan.length-1].innerHTML = '';
		
		//tableHead.cells[tableHead.cells.length-1].removeChild(spanes[tableHead.cells.length-3]);
                table.style.tableLayout = "fixed";
	}
}
//******************************* end RESIZE COLUMNS ******************************
 
//******************************* TOOLTIPS ******************************
addEvent(window, "load", enableTooltips);

function enableTooltips(id){
var links,i,h;
if(!document.getElementById || !document.getElementsByTagName) return;
h=document.createElement("span");
h.id="btc";
h.setAttribute("id","btc");
h.style.position="absolute";
document.getElementsByTagName("body")[0].appendChild(h);
//if(id==null) 
links=document.getElementsByTagName("a");
//else links=document.getElementById(id).getElementsByTagName("a");
for(i=0;i<links.length;i++){
    Prepare(links[i]);
    }
}

function Prepare(el){
var tooltip,t,b,s,l;
t=el.getAttribute("title");
if(t==null || t.length==0) return;
el.removeAttribute("title");
tooltip=CreateEl("span","tooltip");
s=CreateEl("span","top");
s.appendChild(document.createTextNode(t));
tooltip.appendChild(s);
b=CreateEl("b","bottom");
//l=el.getAttribute("href");
//if(l.length>30) l=l.substr(0,27)+"...";
//b.appendChild(document.createTextNode(l));
tooltip.appendChild(b);
setOpacity(tooltip);
el.tooltip=tooltip;
el.onmouseover=showTooltip;
el.onmouseout=hideTooltip;
el.onmousemove=Locate;
}

function showTooltip(e){
document.getElementById("btc").appendChild(this.tooltip);
Locate(e);
}

function hideTooltip(e){
var d=document.getElementById("btc");
if(d.childNodes.length>0) d.removeChild(d.firstChild);
}

function setOpacity(el){
el.style.filter="alpha(opacity:95)";
el.style.KHTMLOpacity="0.95";
el.style.MozOpacity="0.95";
el.style.opacity="0.95";
}

function CreateEl(t,c){
var x=document.createElement(t);
x.className=c;
x.style.display="block";
return(x);
}

function Locate(e){
var posx=0,posy=0;
if(e==null) e=window.event;
if(e.pageX || e.pageY){
    posx=e.pageX; posy=e.pageY;
    }
else if(e.clientX || e.clientY){
    if(document.documentElement.scrollTop){
        posx=e.clientX+document.documentElement.scrollLeft;
        posy=e.clientY+document.documentElement.scrollTop;
        }
    else{
        posx=e.clientX+document.body.scrollLeft;
        posy=e.clientY+document.body.scrollTop;
        }
    }
document.getElementById("btc").style.top=(posy+10)+"px";
document.getElementById("btc").style.left=(posx-20)+"px";
}
//**************************** end TOOLTIPS ***************************


//**************************** SORT TABLE *******************************

var SORT_COLUMN_INDEX;

function sortables_init() {
    // Find all tables with class sortable and make them sortable
    if (!document.getElementsByTagName) return;
    tbls = document.getElementsByTagName("table");
    for (ti=0;ti<tbls.length;ti++) {
        thisTbl = tbls[ti];
        if (((' '+thisTbl.className+' ').indexOf("sortable") != -1) && (thisTbl.id)) {
            //initTable(thisTbl.id);
            ts_makeSortable(thisTbl);
        }
    }
}

function ts_makeSortable(table) {
    if (table.rows && table.rows.length > 3) {
        var firstRow = table.rows[0];
    }
    if (!firstRow) return;
    
    // We have a first row: assume it's the header, and make its contents clickable links
    for (var i=3;i<firstRow.cells.length;i++) {
        var cell = firstRow.cells[i];
	var span1 = cell.getElementsByTagName('span')[0];
        var txt = ts_getInnerText(span1);
        span1.innerHTML = '<a href="#" class="sortheader" '+ 
        'onclick="ts_resortTable(this, '+i+');return false;">' + 
        txt+'<span class="sortarrow">&nbsp;&nbsp;&nbsp;</span></a>';
    }
}

function ts_getInnerText(el) {
	if (typeof el == "string") return el;
	if (typeof el == "undefined") { return el };
	if (el.innerText) return el.innerText;	//Not needed but it is faster
	var str = "";
	
	var cs = el.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		switch (cs[i].nodeType) {
			case 1: //ELEMENT_NODE
				str += ts_getInnerText(cs[i]);
				break;
			case 3:	//TEXT_NODE
				str += cs[i].nodeValue;
				break;
		}
	}
	return str;
}
function ts_resortTable(lnk,clid) {
    // get the span
    var span;
    for (var ci=0;ci<lnk.childNodes.length;ci++) {
        if (lnk.childNodes[ci].tagName && lnk.childNodes[ci].tagName.toLowerCase() == 'span') span = lnk.childNodes[ci];
    }
    var spantext = ts_getInnerText(span);
    var td = lnk.parentNode;
    var column = clid || td.cellIndex;
    var table = getParent(td,'TABLE');
    
    // Work out a type for the column
    if (table.rows.length <= 2) return;
    var itm = ts_getInnerText(table.rows[1].cells[column]);
    sortfn = ts_sort_caseinsensitive;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d\d\d$/)) sortfn = ts_sort_date;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d$/)) sortfn = ts_sort_date;
    if (itm.match(/^[�$]/)) sortfn = ts_sort_currency;
    if (itm.match(/^[\d\.]+$/)) sortfn = ts_sort_numeric;
    SORT_COLUMN_INDEX = column;
    var firstRow = new Array();
    var newRows = new Array();
    for (i=0;i<table.rows[0].length;i++) { firstRow[i] = table.rows[1][i]; }
    for (j=1;j<table.rows.length-1;j++) { newRows[j-1] = table.rows[j]; }

    newRows.sort(sortfn);

    if (span.getAttribute("sortdir") == 'down') {
        ARROW = '&nbsp;&nbsp;&uarr;';
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        ARROW = '&nbsp;&nbsp;&darr;';
        span.setAttribute('sortdir','down');
    }
    
    // We appendChild rows that already exist to the tbody, so it moves them rather than creating new ones
    // don't do sortbottom rows
    for (i=0;i<newRows.length;i++) { if (!newRows[i].className || (newRows[i].className && (newRows[i].className.indexOf('sortbottom') == -1))) table.tBodies[0].appendChild(newRows[i]);}
    // do sortbottom rows only
    for (i=0;i<newRows.length;i++) { if (newRows[i].className && (newRows[i].className.indexOf('sortbottom') != -1)) table.tBodies[0].appendChild(newRows[i]);}
    
    // Delete any other arrows there may be showing
    var allspans = document.getElementsByTagName("span");
    for (var ci=0;ci<allspans.length;ci++) {
        if (allspans[ci].className == 'sortarrow') {
            if (getParent(allspans[ci],"table") == getParent(lnk,"table")) { // in the same table as us?
                allspans[ci].innerHTML = '&nbsp;&nbsp;&nbsp;';
            }
        }
    }
        
    span.innerHTML = ARROW;
	 AplicarCebra();
}

function getParent(el, pTagName) {
	if (el == null) return null;
	else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
		return el;
	else
		return getParent(el.parentNode, pTagName);
}
function ts_sort_date(a,b) {
    // y2k notes: two digit years less than 50 are treated as 20XX, greater than 50 are treated as 19XX
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    if (aa.length == 10) {
        dt1 = aa.substr(6,4)+aa.substr(3,2)+aa.substr(0,2);
    } else {
        yr = aa.substr(6,2);
        if (parseInt(yr) < 50) { yr = '20'+yr; } else { yr = '19'+yr; }
        dt1 = yr+aa.substr(3,2)+aa.substr(0,2);
    }
    if (bb.length == 10) {
        dt2 = bb.substr(6,4)+bb.substr(3,2)+bb.substr(0,2);
    } else {
        yr = bb.substr(6,2);
        if (parseInt(yr) < 50) { yr = '20'+yr; } else { yr = '19'+yr; }
        dt2 = yr+bb.substr(3,2)+bb.substr(0,2);
    }
    if (dt1==dt2) return 0;
    if (dt1<dt2) return -1;
    return 1;
}

function ts_sort_currency(a,b) { 
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
    return parseFloat(aa) - parseFloat(bb);
}

function ts_sort_numeric(a,b) { 
    aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]));
    if (isNaN(aa)) aa = 0;
    bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX])); 
    if (isNaN(bb)) bb = 0;
    return aa-bb;
}

function ts_sort_caseinsensitive(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).toLowerCase();
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).toLowerCase();
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}

function ts_sort_default(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}


function addEvent(elm, evType, fn, useCapture)
// addEvent and removeEvent
// cross-browser event handling for IE5+,  NS6 and Mozilla
// By Scott Andrew
{
  if (elm.addEventListener){
    elm.addEventListener(evType, fn, useCapture);
    return true;
  } else if (elm.attachEvent){
    var r = elm.attachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
} 

//**************************** end SORT TABLE **************************

</script>
