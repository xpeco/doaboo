<script language="Javascript" type="text/Javascript">

// Alternate Row Colors
function AplicarCebra (tableid)  {
   var table   = document.getElementById(tableid);
   var current = "evenline";   
   for (var i = 2; i < table.rows.length-1; i++) {
     table.rows[i].className = table.rows[i].className.replace(/ oddline/g, '');
     table.rows[i].className = table.rows[i].className.replace(/ evenline/g, '');
     table.rows[i].className += " " + current;
     current =   current == "evenline" ? "oddline" : "evenline";
   }
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

//Remove From Cookie
function RemoveFromCookie (cookie_name,cookie_value) {
  cookie_text=GetCookie(cookie_name);
  if (cookie_text != null) {
    begin=cookie_text.indexOf(cookie_value+',');
    if (begin != -1) {
      end=cookie_text.indexOf(',',begin+1);
      end=end+1;
      cookie_text=cookie_text.substring(0,begin)+cookie_text.substring(end,cookie_text.length);
      document.cookie = cookie_name + '=' + escape(cookie_text);
    }
  }
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
  cookie_text=cookie_value;
  var expiration = getCookieExpirDate();
  document.cookie = cookie_name + '=' + escape(cookie_text) + '; ' + 'expires='+expiration+'; ' ;
}

//GetCookie
function GetCookie(cookie_name) {
  if (document.cookie.length > 0) {
    begin = document.cookie.indexOf(cookie_name+'=');
    if (begin != -1) {
      begin += cookie_name.length+1;
      end = document.cookie.indexOf(';', begin);
      if (end == -1) end = document.cookie.length;
      return unescape(document.cookie.substring(begin, end));
    }
  }
  return null;
}

//Browser Size //Review idem with scriptaculous
function getBrowserWindowSize()
{
 var myWidth = 0, myHeight = 0;
 if( typeof( window.innerWidth ) == 'number' )
 {
  //Non-IE
  myWidth = window.innerWidth;
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
</script>
