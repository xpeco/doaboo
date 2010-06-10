<script type="text/Javascript">

// Alternate Row Colors
function AplicarCebra ()  {
   var table   = document.getElementById('DataTable');
   var current = "evenline";   
   for (var i = 1; i < table.rows.length-1; i++) {
     table.rows[i].className = table.rows[i].className.replace(/ oddline/g, '');
     table.rows[i].className = table.rows[i].className.replace(/ evenline/g, '');
     table.rows[i].className += " " + current;
     current =   current == "evenline" ? "oddline" : "evenline";
   }
   return true;
}

//ActivateTab selected #DEBUG
/*
function ActivateTab(id,total){
 for (var i = 1; i <= total; i++) {
 	var tabid = 't' + i;
	if (tabid != id) {
		var taboff = document.getElementById(tabid);
		taboff.className = taboff.className.replace(/ active-tab/g, '');
	} 
 }	
 var tabon = document.getElementById(id);
 tabon.className += ' active-tab';
 return true;
}
*/

// Mark/Unmark Record 
function MarkRecord(index,action){
 var id = 'tr_'+index;	 
 var tr = document.getElementById(id);
 if (action == 1) {
 	tr.className += ' highlighted';
 } else {
    tr.className = tr.className.replace(/ highlighted/g, '');	
 }
 return true;	
}

//Remove unselected items from cookie
function RemoveFromCookie (cookie_name,cookie_value) {
  var cookie_text=GetCookie(cookie_name);
  if (cookie_text != null) {
  	cookie_text=','+cookie_text; //Look for the exact number BETWEEN COMMAS 
	var init=1; //Avoid at the end the first artificial comma previously inserted
	var begin;
		begin=cookie_text.indexOf(','+cookie_value+','); //Look for the exact number BETWEEN COMMAS 
        if (begin != -1) {
	      var end = begin+cookie_value.length+1;
	      if (begin == 0) { begin=1; end = end + 1; } //Tuning when extracting the first number (position 0) 
          cookie_text=cookie_text.substring(init,begin)+cookie_text.substring(end,cookie_text.length); 
        }
	//Eliminate the first artificial comma in case it has not been eliminated yet	
	if (cookie_text.indexOf(',')==0) {
	 cookie_text=cookie_text.substring(1,cookie_text.length);
	}
	//And set the cookie again
	document.cookie = cookie_name + '=' + escape(cookie_text);
  }
  return true;
}


//Remove unselected items from cookie //REVIEW CDA
function RemoveFromCookieCDA (cookie_name,cookie_value) {
  var cookie_text=GetCookie(cookie_name);
  if (cookie_text != null) {
  	cookie_text=','+cookie_text; //Look for the exact number BETWEEN COMMAS 
	var init=1; //Avoid at the end the first artificial comma previously inserted
	var begin;
	//do { //CDA
		begin=cookie_text.indexOf(','+cookie_value+','); //Look for the exact number BETWEEN COMMAS 
	
	    alert(cookie_value+' Begin='+begin+' c_text='+cookie_text);//CDA
        if (begin != -1) {
	      var end = begin+cookie_value.length+1;
	      //if (begin == 0) { begin=1; end = end + 1; } //Tuning when extracting the first number (position 0) 
	      //alert(begin+' / '+end+' / '+cookie_text); //DEBUG
          cookie_text=cookie_text.substring(init,begin)+cookie_text.substring(end,cookie_text.length); 
        }
	//} while (begin != -1); //Repeat in case it is more than once by error
	//Eliminate the first artificial comma in case it has not been eliminated yet	
	if (cookie_text.indexOf(',')==0) {
	  alert('yes');
	  cookie_text=cookie_text.substring(1,cookie_text.length);
	}
	alert('final='+cookie_text); //DEBUG
	//And set the cookie again
	document.cookie = cookie_name + '=' + escape(cookie_text);
  }
  return true;
}

// Select / Unselect Record
// Mark record if selected and set or unset Cookie 
function SelectRecord(index,action){
 var cookie_text;
 //Select record
 if (action == 1) { 
 	MarkRecord(index,'1'); //line color
	cookie_text = GetCookie('sel_recs');
	if (cookie_text == null) {
		cookie_text = index+',';
	}
	else {
		cookie_text = cookie_text + index + ',';
	}
	SetCookie('sel_recs',cookie_text);
	//Increase selected records number
	var totalselrecs = document.getElementById('totalselrecs');
	var totsel = parseInt(totalselrecs.innerHTML);
    totsel += 1;
	totalselrecs.innerHTML = totsel;	
 }
 //Unselect record
 else { 
 	MarkRecord(index,'0'); //line color
    RemoveFromCookie('sel_recs',index);
	//Decrease selected records number
	var totalselrecs = document.getElementById('totalselrecs');
	var totsel = parseInt(totalselrecs.innerHTML);
    totsel -= 1;
	totalselrecs.innerHTML = totsel;	
 }
 return true;	
}

//Select/Unselect all records shown in page
//action=1 for Select, action=0 for Unselect
function SelectAllViewed(from,end,action) 
{
 from =from-1;
 //Select
 if (action == 1) {
 	for (var i = from; i < end; i++) {
	   var checkb = document.getElementById('check_'+i);
	   if  (!checkb.checked) {
	   	checkb.checked = 1;
 		SelectRecord(i,'1');
 	   }
 	}
 }
 //Unselect
 else {
 	for (var i = from; i < end; i++) {
	   var checkb = document.getElementById('check_'+i);
	   if (checkb.checked) {
		 checkb.checked=0;
		 SelectRecord(i,'0');
		}
	}
 }
 return true;
} 


//Select/Unselect all the records (not only those shown in page)
//action=1 for Select, action=0 for Unselect
function SelectAllRecs(from,end,total,action)
{
 //Select 
 if (action == 1) {
 	//Clean the cookie first
 	SetCookie('sel_recs','');
 	//Mark (color) those viewed/shown
 	for (var i = from-1; i < end; i++) {
	   var checkb = document.getElementById('check_'+i);
	   if (!checkb.checked) {
	   	checkb.checked = 1;
 		MarkRecord(i,'1'); //line color
 	   }
 	}
	//Include all the records in the sel_recs cookie 
	var cookie_text = GetCookie('sel_recs');
	for (var j=0; j<total; j++) {
	 cookie_text = cookie_text + j + ',';
	}
	SetCookie('sel_recs',cookie_text);		
	//And update selected records number
	var totalselrecs = document.getElementById('totalselrecs');
	totalselrecs.innerHTML = total;	
 }
 //Unselect
 else {
 	//Unmark (color) those viewed/shown
 	for (var i = from-1; i < end; i++) {
	   var checkb = document.getElementById('check_'+i);
	   if (checkb.checked) {
		 checkb.checked=0;
		 MarkRecord(i,'0'); //line color
		}
	}
	//Exclude all the records from the sel_recs cookie 
	SetCookie('sel_recs','');		
	//And update selected records number
	var totalselrecs = document.getElementById('totalselrecs');
	totalselrecs.innerHTML = 0;	
 }  	
 return true;
}

//CookieExpirationDate
function getCookieExpirDate() {
 var expdate = new Date()
 var milisec = expdate.getTime(); //Get the milliseconds since Jan 1, 1970
 milisec += 7200*1000;  //7200*1000 expires in 2 hours(milliseconds)
 expdate.setTime(milisec);
 return expdate.toGMTString();
}

//SetCookie
function SetCookie(cookie_name,cookie_value) {
  var expiration  = getCookieExpirDate();
  document.cookie = cookie_name + '=' + escape(cookie_value) + '; ' + 'expires='+expiration+'; ' ;
  return true;
}

//GetCookie 
function GetCookie(cookie_name) {
  if (document.cookie.length > 0) {
    var begin = document.cookie.indexOf(cookie_name+'=');
    if (begin != -1) {
      begin += cookie_name.length+1;
      var end = document.cookie.indexOf(';', begin);
      if (end == -1) end = document.cookie.length;
      return unescape(document.cookie.substring(begin, end));
    }
  }
  return null;
}

//StoreKeys
function StoreKeys(mod) {
//DEBUG
//The list of marked recs include those not shown which key is not present... 
//all the keys should be saved in a relation with the record number and taken afterwards either for sel or unsel!!!
//DEBUG	
//mod var to make the difference on Selected (1) or Unselected (0) => if record checked 
  var cookie_value = '';
  var list   = document.getElementById('tablediv').getElementsByTagName('span');
  for (var i=1; i<list.length; i++) {
  	 if (list[i].className == 'key') {
	   var fieldname = document.getElementById('Field_'+list[i].id).innerHTML;
	   cookie_value = cookie_value + list[i].innerHTML + ',';
	   //DEBUG
	   //If the fieldname changes => a new column is key => make array of cookie_names and store them all (for)
	  }
  }
  var cookie_name = 'SELECTED_'+fieldname;
  var cookie_text = GetCookie(cookie_name);
  if (cookie_text == null) {
  	cookie_text = cookie_value;
  }
  else {
  	cookie_text = cookie_text + cookie_value;
  }
  var expiration  = getCookieExpirDate();
  document.cookie = cookie_name + '=' + escape(cookie_text) + '; ' + 'expires='+expiration+'; ' ;
  return true;
}


//Browser Size //Review idem with scriptaculous
function getBrowserWindowSize()
{
 var myWidth = 0, myHeight = 0;
 if( typeof( window.innerWidth ) == 'number' )
 {
  //Non-IE
  myWidth  = window.innerWidth;
  myHeight = window.innerHeight; 
 }
 else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) )
 {
  //IE 6+ in 'standards compliant mode'
  myWidth = document.documentElement.clientWidth;
  myHeight = document.documentElement.clientHeight;
 }
 else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) )
 {
  //IE 4 compatible
  myWidth = document.body.clientWidth;
  myHeight = document.body.clientHeight;
 }

 return {width:myWidth, height:myHeight};
}

function AdjustWidth(){
 var browser = getBrowserWindowSize();
 if (browser.width < 1274) {
   $('nomenubar').setStyle({width: '64%'});
   $('viewiconsspan').setStyle({ margin: '0 0 0 4px' });
   $('pulsoboxspan').setStyle({ margin: '0 0 0 12px' });
 }
 if (browser.width < 1200) {
 	$('nomenubar').setStyle({width: '54%'})
  	$('infobutton').hide();  
	$('pulsoboxspan').setStyle({ margin: '0 0 0 2px' });
	$('pulso_search').setStyle({ width: '120px', margin: '0 0 0 0px' });	
 } 
 if (browser.width < 950) {
   $('userspan').hide();
   $('nomenubar').setStyle({width: '80%'}); 
   $('pulsoboxspan').setStyle({ margin: '0 0 0 15px' });
   $('pulso_search').setStyle({ width: '100px' });
   $('exttopbar').setStyle({ margin: '0 0 40px 0' });
 }
}


// *********** PINTAX UTILS ***********************

// ******** RESIZE COLUMNS ***************
// NOT WORKING YET --- CDA DEBUG
var markerHTML = "<>"; //CDA
var minWidth   = 1;
var dragingColumn = null;
var startingX = 0;
var currentX  = 0;

function getNewWidth () 
{
	var newWidth = minWidth;
    if (dragingColumn != null) {
	  newWidth = parseInt (dragingColumn.parentNode.style.width);
      if (isNaN (newWidth)) {
        newWidth = 0;
      }
      newWidth += currentX - startingX;
      if (newWidth < minWidth) {
        newWidth = minWidth;
      }
	}
	return newWidth;
}

function columnMouseDown (event) 
{
	if (!event) {
	 event = window.event;
	}
    if (dragingColumn != null) {
	 ColumnGrabberMouseUp ();
	}
    startingX = event.clientX;
    currentX = startingX;
    dragingColumn = this;
    return true;
}

function columnMouseUp () 
{
	if (dragingColumn != null) {
	  dragingColumn.parentNode.style.width = getNewWidth ();
      dragingColumn = null;
	}
	return true;
}

function columnMouseMove (event) 
{
	if (!event) {
	  event = window.event;
	}
    if (dragingColumn != null) {
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
		tableHead = table.rows[firstrow];
		
        for (var j=3; j<tableHead.cells.length-1; j++)
		{
			var spanes = tableHead.cells[j].getElementsByTagName('span');
			var column = tableHead.cells[j];
                        
			spanes[spanes.length-1].style.cursor = "e-resize";
			spanes[spanes.length-1].onmousedown = columnMouseDown;
                       
            if (column.offsetWidth < minWidth) {
			  column.style.width = minWidth;
			}
            else {
			  column.style.width = column.offsetWidth;
			}
		}
		var lastSpan = tableHead.cells[tableHead.cells.length-1].getElementsByTagName('span');
		lastSpan[lastSpan.length-1].innerHTML = '';
        table.style.tableLayout = "fixed";
	}
}
//****** end RESIZE COLUMNS *****************
 
//****** SORT TABLE BY COLUMN ***************

var SORT_COLUMN_INDEX;

function sortables_init() {
    // Find all tables with class sortable and make them sortable
    if (!document.getElementsByTagName) return;
    var tbls = document.getElementsByTagName("table");
    for (var ti=0;ti<tbls.length;ti++) {
        var thisTbl = tbls[ti];
        if (((' '+thisTbl.className+' ').indexOf("sortable") != -1) && (thisTbl.id)) {
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
    var sortfn = ts_sort_caseinsensitive;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d\d\d$/)) sortfn = ts_sort_date;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d$/)) sortfn = ts_sort_date;
    if (itm.match(/^[�$]/)) sortfn = ts_sort_currency;
    if (itm.match(/^[\d\.]+$/)) sortfn = ts_sort_numeric;
    SORT_COLUMN_INDEX = column;
    var firstRow = new Array();
    var newRows = new Array();
    for (var i=0;i<table.rows[0].length;i++) { firstRow[i]  = table.rows[1][i]; }
    for (var j=1;j<table.rows.length;j++)    { newRows[j-1] = table.rows[j]; } //CDA

    newRows.sort(sortfn);

    var ARROW;
    if (span.getAttribute("sortdir") == 'down') {
        ARROW = '&nbsp;&nbsp;&uarr;';
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        ARROW = '&nbsp;&nbsp;&darr;';
        span.setAttribute('sortdir','down');
    }
    
    // We appendChild rows that already exist to the tbody, so it moves them rather than creating new ones
    // Don't do sortbottom rows
    for (var i=0;i<newRows.length;i++) { if (!newRows[i].className || (newRows[i].className && (newRows[i].className.indexOf('sortbottom') == -1))) table.tBodies[0].appendChild(newRows[i]);}
    // Do sortbottom rows only
    for (var i=0;i<newRows.length;i++) { if (newRows[i].className && (newRows[i].className.indexOf('sortbottom') != -1)) table.tBodies[0].appendChild(newRows[i]);}
    
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
	var dt1; var dt2;
    var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
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
    var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
    var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
    return parseFloat(aa) - parseFloat(bb);
}

function ts_sort_numeric(a,b) { 
    var aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]));
    if (isNaN(aa)) aa = 0;
    var bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX])); 
    if (isNaN(bb)) bb = 0;
    return aa-bb;
}

function ts_sort_caseinsensitive(a,b) {
    var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).toLowerCase();
    var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).toLowerCase();
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}

function ts_sort_default(a,b) {
    var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
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
//************ end SORT TABLE BY COLUMN ***************

//************** DROPDOWN CONTENT ********************
    var slideDownInitHeight = new Array();
	var slidedown_direction = new Array();

	var slidedownActive = false;
	var contentHeight = false;
	var slidedownSpeed = 3; // Higher value = faster script
	var slidedownTimer = 7;	// Lower value  = faster script
	
	function slidedown_showHide(boxId)
	{
		if(!slidedown_direction[boxId])slidedown_direction[boxId] = 1;
		if(!slideDownInitHeight[boxId])slideDownInitHeight[boxId] = 0;
		
		if(slideDownInitHeight[boxId]==0)slidedown_direction[boxId]=slidedownSpeed; else slidedown_direction[boxId] = slidedownSpeed*-1;
		
		var slidedownContentBox = document.getElementById(boxId);
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
		var aux = slidedownContent.innerHTML;
		slidedownContent.innerHTML = aux.replace(/\\n/gim, "<br>"); 

		setTimeout('slidedown_showHide_start(document.getElementById("' + slidedownContentBox.id + '"),document.getElementById("' + slidedownContent.id + '"))',slidedownTimer);	// Choose a lower value than 10 to make the script move faster
	}
	
	function setSlideDownSpeed(newSpeed)
	{
	 slidedownSpeed = newSpeed;	
	}
//************ end DROPDOWN CONTENT ***************


//************* END OF PINTAX **********************

</script>
