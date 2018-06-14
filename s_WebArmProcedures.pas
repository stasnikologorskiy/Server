unit s_WebArmProcedures; // ��������� ��� Web

interface
uses Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
     DB, IBDatabase, IBSQL, IBQuery,
     n_free_functions, v_constants, v_Functions, v_DataTrans,
     n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common,IniFiles,s_Utils,JPEG,EncdDecd;

procedure prGeneralNewSystemProcWebArm(Stream: TBoBMemoryStream; ThreadData: TThreadData);
function fnHeader(var userInf:TEmplInfo;Autenticated: Boolean=true) : string;
function fnFooter(var userInf:TEmplInfo): string;
function fnGetWebArmDirModelPage(PageType: byte; PageName:String; Stream: TBoBMemoryStream): string; // �������� ����� ����������/����


const
  StandartErrorMessage        : string = '��������� ������ ����������. ���� ��� ������ ���������� ���������, �������� �� ���� �� ������ ';
  coReloginText               : string = '������� � ������� ������ ����� ���� ����� � ������.'; //������ �����.
  SessionTimeMin              : integer = 30;
  constPayInvoiceFilterHeader : integer = 165;
  coNonSavedColor:string='#ffd2d2';

type
 GetPageData=function (Stream: TBoBMemoryStream): string;


var
  TechWork           : string = 'techwork.html';
  OnReadyScript      : string = '';

  BaseUrl            : string;
  BaseDir            : string;
  DescrUrl           : string;
  DescrImageUrl      : string;
  TmpDir             : string;
  DescrDir           : string;
  iniFileName        : string;
  globToHeader       : string;
  JSVersion          : string = 'v2.11.4';
  GoogleAnalytics     : string='<script type="text/javascript" > '#13#10'  (function(i,s,o,g,r,a,m){i[''GoogleAnalyticsObject'']=r;i[r]=i[r]||function(){'#13#10+
                               '  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),'#13#10+
                               '  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)'#13#10+
                               '  })(window,document,''script'',''//www.google-analytics.com/analytics.js'',''ga'');'#13#10#13#10+
                               '  ga(''create'', ''UA-41098000-1'', ''vladislav.ua'');'#13#10'  ga(''send'', ''pageview'');'#13#10#13#10'</script>'#13#10;

  ScriptName         : string;
  TitleStr           : string;
  globToScript     : string;


implementation
uses  s_CommandFunc,n_CSSservice, n_CSSThreads, n_IBCntsPool, n_DataCacheObjects,n_WebArmProcedures,t_function,t_WebArmProcedures,n_OnlinePocedures;


// ������ ����� ������+ ������ ������ ��� ������� � �.�.
function fnSearchForm(var userInf:TEmplInfo; Deliveries, Compare, OE: boolean; ContractId:integer): string;
var
  shift, width: integer;
begin
  Result:='';
  Result:=Result+'<div id=waresearchdiv>';
  if flNewModeCGI  then
    Result:=Result+'<form id="searchform" name="searchform" action="'+ScriptName+'/abj" onSubmit="return ws();">'
  else
    Result:=Result+'<form id="searchform" name="searchform" action="'+ScriptName+fnIfStr(flNewModeCGI,'/newbj','/abj')+'" onSubmit="return ws();">';
  Result:=Result+'<input type=text id=waresearch name=waresearch insearchtext="����� ������" maxlength=32 value="" onfocus="waresearchfocus(this);" onblur="waresearchblur(this);"  style="width: 136px;">';
  Result:=Result+'<input type=submit style=''display: none;''>';
  Result:=Result+'<input type=hidden name=forfirmid id=forfirmid value="0">';
  Result:=Result+'<input type=hidden name=act id=act value="waresearch">';
  Result:=Result+'<input type=hidden name=addlines id=addlines value="">';
  Result:=Result+'<input type=hidden name=contract id=contract value="'+IntToStr(ContractId)+'">';
  Result:=Result+'</form>';
  Shift:=0;

  width:=19;  Shift:=Shift+width-1; //
  Result:=Result+'<a class="abgslide" style="width: '+IntToStr(width)+'px; height: 22px; right: -'+IntToStr(Shift)+'px; top: 0px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/combobox.png'');" '
                +'href="#"  title="��������� ��������� ������� �� �������" onclick=''var auto=$("#waresearch"); if (auto.attr("opened")=="true") {auto.autocomplete("close")} else {auto.autocomplete("search" , "");} auto[0].focus();''></a>';

  width:=23;  Shift:=Shift+width+3; //
  Result:=Result+'<a class="abgslide" style="width: '+IntToStr(width)+'px; height: 22px; right: -'+IntToStr(Shift)+'px; top: 0px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/lupa.png'');" '
//                  +'href="#" title="�����" onclick="$(''#searchform'').trigger(''submit'');"></a>';
                  +'href="#" title="����� ������" onclick="ws();"></a>';

  if OE then begin
    //Result:=Result+'<form id=searchbyvinform onsubmit="flNewModeCGI='+BoolToStr(flNewModeCGI)+'; vs(this); return false;">';
    Result:=Result+'<form id=searchbyvinform onsubmit="vs(this); return false;">';
    width:=136;  Shift:=Shift+width+3+4+12; // 4 - ��� ������ margin � border input`a, 12 - ������ �� ������ �� ������
    Result:=Result+'<input type=text id=vinsearch name=vinsearch insearchtext="����� �� VIN" maxlength=17 value="" onfocus="waresearchfocus(this);" onblur="waresearchblur(this);"  style="position: absolute; top: 0px; right: -'+IntToStr(Shift)+'px; width: '+IntToStr(width)+'px;">';
    Result:=Result+'<input type=submit style=''display: none;''>';
    Result:=Result+'<input type=hidden name=act id=act value="FindByVIN">';
    Result:=Result+'</form>';

    width:=19;  Shift:=Shift+width-1; //
    Result:=Result+'<a class="abgslide" style="width: '+IntToStr(width)+'px; height: 22px; right: -'+IntToStr(Shift)+'px; top: 0px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/combobox.png'');" '
                  +'href="#"  title="��������� ��������� ������� �� VIN" onclick=''var auto=$("#vinsearch"); if (auto.attr("opened")=="true") {auto.autocomplete("close")} else {auto.autocomplete("search" , "");} auto[0].focus();''></a>';

    width:=23;  Shift:=Shift+width+3; //
    Result:=Result+'<a class="abgslide" style="width: '+IntToStr(width)+'px; height: 22px; right: -'+IntToStr(Shift)+'px; top: 0px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/lupa.png'');" '
                  +'href="#" title="����� �� VIN" onclick="$(''#searchbyvinform'').submit();"></a>';
  end;

(*
  Shift:=Shift+30;
  Result:=Result+'<a id="selbymodauto" class="abgslide" style="width: 24px; height: 24px; right: -'+IntToStr(Shift)+'px; top: -1px; background-image: url(''/images/autoicon.png'');" '
                +'href="#" onclick="ec(''openselbymodwindow'', ''selname=manuflistauto&sys='+IntToStr(10+constIsAuto)+'&id=-1&objdiv=selbymodelautoobj&top10=autotop10'', ''difdict'');" title="������ �� ������ ����������"></a>';

  Shift:=Shift+30;
  Result:=Result+'<a id="selbymodengine" class="abgslide" style="width: 24px; height: 24px; right: -'+IntToStr(Shift)+'px; top: -1px; background-image: url(''/images/engineicon.png'');" '
                +'href="#" onclick="ec(''openselbymodwindow'', ''selname=manuflistautoengine&sys='+IntToStr(30+constIsAuto)+'&id=-1&objdiv=selbymodelauenobj&top10=auentop10'', ''difdict'');" title="������ �� ��������� ����������"></a>';

  Shift:=Shift+107;
  Result:=Result+'<a id="selbymod" class="abgslide" style="width: 101px; height: 24px; right: -'+IntToStr(Shift)+'px; top: -1px; background-image: url(''/images/alloftheworld.png'');" '
                  +'href="#" onclick="ec(''openselbymodwindow'', ''selname=manuflist&sys='+IntToStr(10+constIsMoto)+'&id=-1&objdiv=selbymodelmotoobj&top10=mototop10'', ''difdict'');" title="������ �� ���� ������������� ��������"></a>';


  Shift:=Shift+30;
  Result:=Result+'<a id="selbyattr" class="abgslide" style="width: 24px; height: 24px; right: -'+IntToStr(Shift)+'px; top: -1px; background-image: url(''/images/rule.png'');" '
                +'href="#" title="������ ������ �� ����������"></a>';

  Shift:=Shift+34;
//  Result:=Result+'<input type=button style=''position: absolute; right: -'+IntToStr(Shift)+'px; top: -1px; width: 31px;'' value="OE" onclick=''$.fancybox.open($("#origprogs"), {"modal" : false, "padding": 0});$("#oetopdiv").css("top", "0px");'' title="������ �� ������������ ����������">';
  Result:=Result+'<input type=button style=''position: absolute; right: -'+IntToStr(Shift)+'px; top: -1px; width: 31px;'' value="OE" onclick=''tuneheader();'' title="������ �� ������������ ����������">';
*)


  width:=46;  Shift:=Shift+width+3+12; //  12 - ������ �� ������ �� ������ ��� VIN
  Result:=Result+'<a class="abgslide" style="width: '+IntToStr(width)+'px; height: 22px; right: -'+IntToStr(Shift)+'px; top: 0px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/lupa-wide.png'');"'+
  ' href=# onclick=''$("#podbortabs").dialog("open");'' title="��� ������� � ����� ����"></a> ';

//  Shift:=Shift+79;
//  Result:=Result+'<input type=button value="��������" disabled id=warecomparebtn style=''position: absolute; right: -'+IntToStr(Shift)+'px; top: -1px; width: 76px;'' onclick=''warecompare();''>';

  width:=70;  Shift:=Shift+width+3;
  if flNewModeCGI then
    Result:=Result+'<input type=button id=deliverieslistbtn style=''position: absolute; right: -'+IntToStr(Shift)+'px; top: -1px; width: '+IntToStr(width)+'px; display: none;'' value="��������" onclick=''ec("getdeliverieslist", "priceinuah="+$("#invoicecurrency").val, "newbj");'' title="������ �������� ��� ���������� � ����">'
  else
    Result:=Result+'<input type=button id=deliverieslistbtn style=''position: absolute; right: -'+IntToStr(Shift)+'px; top: -1px; width: '+IntToStr(width)+'px; display: none;'' value="��������" onclick=''ec("getdeliverieslist", "priceinuah="+$("#invoicecurrency").val, "abj");'' title="������ �������� ��� ���������� � ����">';
  Result:=Result+'</div>';

end;



function fnAutenticationForm(leftform: boolean): string;
//leftform - �������� �� ����� �� ����� ������
begin
  Result:='';
  Result:=Result+'<div id=autdiv_ord>';
  if flNewModeCGI then
   Result:=Result+'<form  action="'+ScriptName+'/newbj" onsubmit="return sfbaNew(this);">'
  else begin
   Result:=Result+'<form  action="'+ScriptName+'/anbj" onsubmit="return sfba(this);">';
  end;
//  Result:=Result+'<form  action="'+Request.ScriptName+'/anbj" onsubmit="alert(''111''); return false;">';
  Result:=Result+'<input type=hidden name=act value="autenticate">';
  Result:=Result+'<nobr>�����&nbsp;<input type=text class=input1 name=psw '+fnIfStr(leftform, 'id=leftpsw', '')+'></nobr><br>';
  Result:=Result+'<nobr>������&nbsp;<input type=password class=input1 name=lgn></nobr><br>';
//  Result:=Result+'<a href='+Request.ScriptName+'/registration>�����������'+GetQueryField(Request, 'ttt')+'</a>';
  if leftform then begin
    Result:=Result+'<input type=submit class=input1 style=position: relative;" value="����">';
    Result:=Result+'<input type=hidden name=leftform value=true>';
    Result:=Result+'</form>';
    Result:=Result+'<br/><br/><input type=button class=input1 style="position: relative; left: 1px; width: auto;" value="������������ ������" '
                +'onclick=''if (mtrim($("#leftpsw").val())=="") {alert("�� �� ������� ���� �����")} else {ec("restorepass", "login="+mtrim($("#leftpsw").val()), "anbj");}''><br>';
  end else begin
    Result:=Result+'<input type=submit class=input1 style="display: none;" value="����">';
    Result:=Result+'</form>';
  end;
  Result:=Result+'</div>';
end;


function fnPodborWindow(OE, Moto, Auto: boolean): string;
var
  i, j: integer;
  ar: array of tas;
  s: string;
begin
  Result:=Result+'<div id="podbortabs" style="overflow: hidden;">'#13#10;
  Result:=Result+' <ul>'#13#10;
  if OE then begin
    Result:=Result+'    <li><a href="#origprogs" title="������ �� ������������ ����������">������������ ��������</a></li>'#13#10;
  end;
  if Auto then begin
    Result:=Result+'    <li><a href="#selectbymodelautodiv" title="������ �� ������ ����������">����</a></li>'#13#10;
    Result:=Result+'    <li><a href="#selectbyengineautodiv" title="������ �� ��������� ����������">���������</a></li>'#13#10;
    Result:=Result+'    <li><a href="#autolampdiv" title="������ �� �������� �� ������">�����</a></li>'#13#10;

  end;
  if Moto then begin
    Result:=Result+'    <li><a href="#selectbymodelmotodiv" title="������ �� ������ ���������">����</a></li>'#13#10;
    Result:=Result+'    <li><a href="#selectbyattributemotodiv" title="������ �� ����������">�� ����������</a></li>'#13#10;
  end;
  Result:=Result+' </ul>'#13#10;

  if OE then begin
    Result:=Result+'  <div id="origprogs" style="position: relative;">';
    Result:=Result+'<div id="origprogsheader" class="selectpartsdivheader"><h1 class="grayline" style="height: 26px; padding: 14px 0 0; width: 100%;">'
            +'<a href=# style="vertical-align: 75%; margin-left: 78px;" class="origyears" onclick=''setpodborsubdiv(0, -1);''>������</a></h1>';
    Result:=Result+'<img src="/images/back.png" style="top: 2px;" class="backimage" title="�����" onclick=''setpodborsubdiv(-1, -1);''>';
    Result:=Result+'<div id=origheaderlogo style="background-size: 200% 100%; width: 41px; height: 41px; position: absolute; top: 0; left: 34px;"></div></div>';
    for i:=0 to 9 do begin
      Result:=Result+'<div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader"')+' number="'+IntToStr(i)+'"></div>';
    end;
//    Result:=Result+laximostartpage;
    Result:=Result+'</div>'#13#10;
  end;


  if Moto then begin
  // ++++++++++++++++++++++++++ ���� ������� �� ��������� ���� +++++++++++++++++++++++++++++++++++++++++++++++++++
    Result:=Result+'  <div id="selectbyattributemotodiv" style="position: relative;">';
    Result:=Result+'<div class=selectpartsdiv id=selbyattrdiv number="0"><div>';
    Result:=Result+'<table id=motoattrlisttable style="position: relative; white-space: nowrap; margin: 10px;">';
    Result:=Result+'</table>';
    Result:=Result+'</div></div>';  //selbyattrdiv

    Result:=Result+' <div class="selectpartsdivheader"  id="motoattrheaderdiv">'; //
    Result:=Result+'<h1 class="grayline" style="margin: 0px;">������� �������� ��� �������</h1>';
    Result:=Result+'<img src="/images/back.png" class="backimage" title="� ������ ����� ����������" '
                  +'onclick="setpodborsubdiv(-1, -1); ">';  //
    Result:=Result+'</div>';

    Result:=Result+'<div class="selectpartsdiv" id=selmotobyattrdiv  number="1" headerdiv="motoattrheaderdiv"> ';
    Result:=Result+'<table id=motoattrtable style="position: relative; white-space: nowrap; font-size: 12px;">';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  //selmotobyattrdiv
    Result:=Result+'</div>'#13#10; // id="selectbyattributemotodiv"
  // -------------------------- ���� ������� �� ��������� ���� ---------------------------------------------------

  // ++++++++++++++++++++++++++ ���� ������� �� ������ ���� +++++++++++++++++++++++++++++++++++++++++++++++++++
    Result:=Result+'  <div id="selectbymodelmotodiv" style="position: relative;">';
    Result:=Result+'<div class=selectpartsdiv id=selbymodeldiv number="0"><div><table>';
    Result:=Result+'<tr><td>�������������: </td><td><select id=manuflist     style="width: 550px; margin-right: 20px;" onchange="loadmodellinelist(this, ''modellisttable'', ''modellinelist'', '+IntToStr(constIsMoto)+');"></select></td></tr>';
    Result:=Result+'<tr><td>��������� ���: </td><td><select id=modellinelist style="width: 550px; margin-right: 20px;" onchange="loadmodelslist(this, ''modellisttable'', '+IntToStr(constIsMoto)+');"></select></td></tr>';
    Result:=Result+'</table><div style="height: 200px; width: 100%; overflow-y: auto;" > ';
    Result:=Result+'<table id=modellisttable style="width: 100%;">';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  //
    Result:=Result+'</div>';

    Result:=Result+'<div  style="text-align: left; height: 220px; width: 100%; overflow-y: auto;" >'; // +++ ��� ��� ���10
    Result:=Result+'<h1 class="grayline" style="margin-bottom: 0px;">��������� ������</h1>';
    Result:=Result+'<table class="top10tbl" id=mototop10 style="width: 100%;">';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  // --- ��� ��� ���10

    Result:=Result+'</div>'#13#10;  //selbymodeldiv

    Result:=Result+' <div class="selectpartsdivheader"  id="motomodelheaderdiv">'; //
    Result:=Result+'<h1 class="grayline" id=motomodeltreeheader style=''height: 32px;''>������� ���� �� ���� - ������� � ����������� �������</h1><br/>';
    Result:=Result+'<img src="/images/back.png" class="backimage" title="� ������ �������" '
                  +'onclick="setpodborsubdiv(-1, -1); ">';  //
    Result:=Result+'</div>';

    Result:=Result+'<div class="treeview selectpartsdiv" id=selbymodeltreediv number="1" headerdiv="motomodelheaderdiv">'; //
    Result:=Result+'<ul id=sel_ul_0 style=''position: relative;''></ul>';  //
    Result:=Result+'</div>';

    Result:=Result+'</div>'#13#10; //  id="selectbymodelmotodiv"
  // -------------------------- ���� ������� �� ������ ���� ---------------------------------------------------
  end;

  if Auto then begin
  // ++++++++++++++++++++++++++ ���� ������� �� ������ ���� +++++++++++++++++++++++++++++++++++++++++++++++++++
    Result:=Result+'<div id="selectbymodelautodiv" style="position: relative;">';
    Result:=Result+'<div class=selectpartsdiv id=selbymodeldivauto number="0"><div><table>';
    Result:=Result+'<tr><td>�������������: </td><td><select id=manuflistauto     style="width: 550px; margin-right: 16px;" onchange=''loadmodellinelist(this, "modellisttableauto", "modellinelistauto", '+IntToStr(constIsAuto)+');''></select></td></tr>';
    Result:=Result+'<tr><td>��������� ���: </td><td><select id=modellinelistauto style="width: 550px; margin-right: 16px;"  onchange=''loadmodelslist(this, "modellisttableauto", '+IntToStr(constIsAuto)+');''></select></td></tr>';
    Result:=Result+'</table><div style="height: 200px; width: 100%; overflow-y: auto;" > ';
    Result:=Result+'<table id=modellisttableauto style="width: 100%;">';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  //
    Result:=Result+'</div>';

    Result:=Result+'<div  style="text-align: left; height: 220px; width: 100%; overflow-y: auto;" >'; // +++ ��� ��� ���10                                                                                                                        Result:=Result+'<h1 class="grayline" style="margin-bottom: 0px;">��������� ������</h1>';
    Result:=Result+'<table class="top10tbl" id=autotop10 width=100%>';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  // --- ��� ��� ���10

    Result:=Result+'</div>';  //selbymodeldivauto

    Result:=Result+'<div class="selectpartsdivheader"  id="automodelheaderdiv">';
    Result:=Result+'<img src="/images/back.png" class="backimage" title="� ������ �������" '
//                  +'onclick="showseldiv(''selbymodeldivauto'', ''selbymodelautoobj''); ">';  //
                  +'onclick="setpodborsubdiv(-1, -1); ">';  //
    Result:=Result+'<h1 class="grayline" id=automodeltreeheader style=''height: 32px;''>������� ���� �� ���� - ������� � ����������� �������</h1><br/>';
    Result:=Result+'<form onSubmit="search_node2(''sel_auto'', ''autotreediv'', ''nodesearchauto''); return false;" ><div style="width: 300px; position: relative; margin-left: 20px;">'+
                   '<input type=text id=nodesearchauto style="width: 280px;"> '+
  //                '<a class=abANew href=# onClick="alert(this.parentNode.parentNode.submit());" style="background-image: url(/images/search_16.png); display: block; right: 0px; padding: 0;"></a></div></form>';  //
                  '<a class=abANew href=# onClick="search_node2(''sel_auto'', ''autotreediv'', ''nodesearchauto'');" style="background-image: url(/images/search_16.png); display: block; right: 0px; padding: 0;"></a></div></form>';  //
    Result:=Result+'</div>'#13#10;// id="automodeldivheader"

    Result:=Result+'<div class="treeview selectpartsdiv" id=selbymodeltreedivauto number="1" headerdiv="automodelheaderdiv">';
    Result:=Result+'<div id=autotreediv><ul id=sel_auto_ul_0 style=''position: relative;''></ul>';  //
    Result:=Result+'</div></div>';  //selbymodeltreedivauto
    Result:=Result+'</div>'#13#10;// id="selectbymodelautodiv"
  // -------------------------- ���� ������� �� ������ ���� ---------------------------------------------------

  // ++++++++++++++++++++++++++ ���� ������� �� ��������� ���� +++++++++++++++++++++++++++++++++++++++++++++++++++
    Result:=Result+'  <div id="selectbyengineautodiv" style="position: relative;">';
    Result:=Result+'<div class="selectpartsdiv" id=selbyenginedivauto number="0"><div>';
    if flNewModeCGI then
      Result:=Result+'�������������: <select id=manuflistautoengine style="width: 350px; margin-right: 16px;" onchange=''$("#listautoengine")[0].options.length=0; if (this.value!=-1) ec("loadengines", "id="+this.value, "newbj");''></select><br />'
    else
      Result:=Result+'�������������: <select id=manuflistautoengine style="width: 350px; margin-right: 16px;" onchange=''$("#listautoengine")[0].options.length=0; if (this.value!=-1) ec("loadengines", "id="+this.value, "abj");''></select><br />';
    Result:=Result+'<span style=''margin-right: 72px;''>��������� . . . ����� . . . ��� . . . �.�. . . . �-�� ���������</span><br />';
    Result:=Result+'���������: <select id=listautoengine style="width: 350px; margin-right: 16px;"></select><br />';
    if flNewModeCGI  then
      Result:=Result+'<img src="/images/details.jpg" onclick=''if ($("#listautoengine")[0].options.length) ec("showengineoptions", "engineid="+$("#listautoengine").val(), "newbj");'' style=''cursor: pointer;''>'
    else
      Result:=Result+'<img src="/images/details.jpg" onclick=''if ($("#listautoengine")[0].options.length) ec("showengineoptions", "engineid="+$("#listautoengine").val(), "abj");'' style=''cursor: pointer;''>';
    Result:=Result+'<img src="/images/ok.jpg" onclick=''if ($("#listautoengine")[0].options.length) showmodtree($("#listautoengine").val(), "selbymodeltreedivautoengine", "selbymodelauenobj", "sel_auen");'' style=''cursor: pointer; margin-right: 16px; margin-top: 8px;''>';
  (*
    Result:=Result+'<table style="text-align: center; font-weight: bold; background-image: url(''/images/gray_line.png'');"><tr><td width=125>���������</td><td width=57>�����</td><td width=74>���</td><td width=74>�.�.</td><td width=132>�-�� ���������</td></tr>';
    Result:=Result+'</table>';
    Result:=Result+'<div style="height: 200px; width: 100%; overflow-y: auto;" > ';

    Result:=Result+'<table id=enginetableauto style="width: 100%; text-align: center;">';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  //
  *)
    Result:=Result+'</div>';

    Result:=Result+'<div  style="text-align: left; height: 250px; width: 100%; overflow-y: auto;" >'; // +++ ��� ��� ���10
    Result:=Result+'<h1 class="grayline" style="margin-bottom: 0px;">��������� ���������</h1>';
    Result:=Result+'<table class="top10tbl" id=auentop10 style="width: 100%;">';
    Result:=Result+'</table>';
    Result:=Result+'</div>';  // --- ��� ��� ���10

    Result:=Result+'</div>';  //selbyenginedivauto

    Result:=Result+' <div class="selectpartsdivheader"  id="engineheaderdiv">'; //
    Result:=Result+'<h1 class="grayline" id=auenmodeltreeheader style=''height: 32px;''>������� ���� �� ���� - ������� � ����������� �������</h1><br/>';
    Result:=Result+'<img src="/images/back.png" class="backimage" title="� ������ ����������" '
                  +'onclick="setpodborsubdiv(-1, -1); ">';  //
    Result:=Result+'<form onSubmit="search_node2(''sel_auto'', ''auentreediv''); return false;" ><div style="width: 300px; position: relative; margin-left: 20px;">'+
                   '<input type=text id=nodesearchauen style="width: 280px;">'+
                  '<a class=abANew href=# onClick="search_node2(''sel_auto'', ''autotreediv'');" style="background-image: url(/images/search_16.png); display: block; right: 0px; padding: 0;"></a></div></form>';  //
    Result:=Result+'</div>';

    Result:=Result+'<div class="selectpartsdiv" id="selbymodeltreedivautoengine"  number="1" headerdiv="engineheaderdiv">';
    Result:=Result+'<div class="treeview" id=auentreediv ><ul id=sel_auen_ul_0 style=''position: relative;''></ul>';  //
    Result:=Result+'</div>';  //auentreediv
    Result:=Result+'</div>';  //selbymodeltreedivautoengine
    Result:=Result+'</div>'#13#10; // id="selectbyengineautodiv"
  // -------------------------- ���� ������� �� ��������� ���� ---------------------------------------------------
  end;
  Result:=Result+'</div><!-- podbortabs -->'#13#10; //<div id="podbortabs">
end;  // fnPodborWindow




// �����, ��������� ��� ���� ������� ������
function fnHeader(var userInf:TEmplInfo; Autenticated: Boolean=true) : string;

{ ##############################################################################
  �������, ������������� ������� ����
  MenuText - ����� �������� ����
  Address - ����� �������� ��������
  aPageName - ��� �������� ��� ��������� � �������
  Collapsed - false - ���������� �������, true - ���������
  ##############################################################################}

function fnDrawMenuItem(MenuText, Address, aPageName, Title : string; Func: string=''): string;
var
  s: string;
  CurMenuItem: boolean;
begin
  if aPageName='' then aPageName:=Address;
  CurMenuItem:=((aPageName=userInf.PageName) or ((aPageName='balance') and (userInf.PageName='check')));

  s:='';
  if ((flNewModeCGI) and  (Address<>'info')) or (Address='treemotul') or (Address='motulsite&kindofpage=3') or (Address='logotypes') then begin
    s:=s+'<a id="mmenu_'+Address+'" class="leftmenuitem'+fnIfStr(CurMenuItem, ' curmenuitem', '')+'" title='''+Title+''' href='''+fnIfStr(Func='', ScriptName+'/universal'+'?act='+Address+'&'+floatTostr(random)+'''', 'javascript: '+Func+'''');
  end
  else begin
    s:=s+'<a id="mmenu_'+Address+'" class="leftmenuitem'+fnIfStr(CurMenuItem, ' curmenuitem', '')+'" title='''+Title+''' href='''+fnIfStr(Func='', ScriptName+'/'+Address+'?'+floatTostr(random)+'''', 'javascript: '+Func+'''');
  end;  s:=s+'><span>'+MenuText+'</span></a>'#13#10;
  Result:=s;
end;

var
  s,serverDate: string;
begin
  Result:='';
  Result:=Result+'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/strict.dtd">'#13#10;
//  Result:=Result+'<!DOCTYPE>'#13#10;
  Result:=Result+'<html>'#13#10;
  Result:=Result+'<head>'#13#10;
  Result:=Result+'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">'#13#10;
  Result:=Result+'<meta http-equiv="Content-Language" content="ru">'#13#10;
  Result:=Result+'<meta http-equiv="Cache-Control" content="no-cache">'#13#10;
  Result:=Result+'<meta http-equiv="Pragma" content="no-cache">'#13#10;
  Randomize;

  Result:=Result+'<script language=JavaScript> flNewModeCGI='+BoolToStr(flNewModeCGI)+';</script>'#13#10;
  Result:=Result+'<script language=JavaScript src="'+DescrImageUrl+'/cookies.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  //Result:=Result+'<script language=JavaScript src="http://code.jquery.com/jquery-1.8.3.min.js"></script>'#13#10;
  Result:=Result+'<script language=JavaScript src="'+DescrImageUrl+'/fancybox/jquery-1.8.3.min.js"></script>'#13#10;
  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/jquery.mousewheel.js"></script>'#13#10;
  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/jquery.dragscrollable.js"></script>'#13#10;

  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/jqueryui.custom.js"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/fancybox/jqueryui.custom.css" />'#13#10;

  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/jquery.fancybox.js?v=2.0.5"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/fancybox/jquery.fancybox.css?v=2.0.5" media="screen" />'#13#10;
  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/datepicker-ru.js"></script>'#13#10;

  Result:=Result+'<script language=JavaScript src="'+DescrImageUrl+'/common.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="/webarm.css?'+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/common.css?'+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
  Result:=Result+'<script language=JavaScript src="/webarm.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/jquery.timepicker-ui.min.js"></script>'#13#10;   //!!
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/fancybox/jquery.timepicker-ui.min.css" >'#13#10;//!!
  //Result:=Result+'<link rel="stylesheet" href="timepicker-ui.css" type="text/css"/>'#13#10;
  Result:=Result+'<script type="text/javascript" language=JavaScript src="'+DescrImageUrl+'/tooltip.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/fancybox/tooltipster.css?'+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
  Result:=Result+'<script type="text/javascript" src="'+DescrImageUrl+'/fancybox/jquery.tooltipster.min.js"></script>'#13#10;

  Result:=Result+'</script>'#13#10;

  if userInf.NeedCalendar then begin
    Result:=Result+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/calendar.css'+(*floatTostr(random)+*)'">'#13#10;
    Result:=Result+'<script language=JavaScript src="'+DescrImageUrl+'/calendar.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  end;


  if userInf.NeedTinyMCE or userInf.NeedTinyMCEAction then begin
    Result:=Result+'<script type="text/javascript" src="/tinymce/tiny_mce_src.js"></script>'#13#10;
    Result:=Result+'<script type="text/javascript"> tinyMCE.init(';
    Result:=Result+'  {';
// General options
    Result:=Result+'  mode : "textareas",';
    Result:=Result+'  theme : "advanced",';
    Result:=Result+'  plugins : "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,'+'insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,wordcount,images",';

// Theme options
    Result:=Result+'  theme_advanced_buttons1 : "newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,formatselect,fontselect,fontsizeselect,images",';
    Result:=Result+'  theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",';
    Result:=Result+'  theme_advanced_buttons3 : "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",';
    Result:=Result+'  theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak",';
    Result:=Result+'  theme_advanced_toolbar_location : "top",';
    Result:=Result+'  theme_advanced_toolbar_align : "left",';
    Result:=Result+'  theme_advanced_statusbar_location : "bottom",';
    Result:=Result+'  theme_advanced_resizing : true,';
    Result:=Result+'  language : "ru",';
    Result:=Result+'  valid_styles : {''*'' : ''color,font-size,font-weight,font-style,text-decoration''},';

// Example content CSS (should be your site CSS)';
    Result:=Result+'  content_css : "/tiny.css",';

// Drop lists for link/image/media/template dialogs';
    Result:=Result+'  template_external_list_url : "lists/template_list.js",';
    Result:=Result+'  external_link_list_url : "lists/link_list.js",';
    Result:=Result+'  external_image_list_url : "lists/image_list.js",';
    Result:=Result+'  media_external_list_url : "lists/media_list.js",';

// Replace values for the template plugin';
    Result:=Result+'  template_replace_values : {';
    Result:=Result+'    username : "Some User",';
    Result:=Result+'    staffid : "991234"';
    Result:=Result+'  },';
    Result:=Result+'  relative_urls : false,';
    Result:=Result+'  remove_script_host : true';
    Result:=Result+'});</script>'#13#10;
  end;  // if NeedTinyMCE

  Result:=Result+globToHeader+#13#10;

  Result:=Result+'<title>'+TitleStr+'</title>'#13#10;
  Result:=Result+'<script type="text/javascript">'#13#10;
  Result:=Result+'flNewModeCGI='+BoolToStr(flNewModeCGI)+';'#13#10;
  Result:=Result+'scriptname="'+ScriptName+'";'#13#10;
  Result:=Result+'descrimageurl="'+DescrImageUrl+'";'#13#10;


  DateTimeToString(s, 'm', userInf.ServerTime);
  DateTimeToString(s, 'yyyy, '+IntToStr(StrToInt(s)-1)+', d, h, n, s', userInf.ServerTime);
  s:=StringReplace(s, ', ', '", "', [rfReplaceAll]);


   if flNewModeCGI then begin
     Result:=Result+'var flNewModeCGI=true;'#13#10;
   end
   else begin
     Result:=Result+'var flNewModeCGI=false;'#13#10;
   end;
  Result:=Result+'var ServerDate=new Date("'+s+'");'#13#10;
  Result:=Result+'DeltaDate=DeltaDate-ServerDate;'#13#10;
  Result:=Result+'page="'+userInf.PageName+'";'#13#10;
  Result:=Result+'var descrurl="'+ScriptName+'";'#13#10;
  Result:=Result+globToScript+#13#10;

  Result:=Result+'$(document).ready(function() {'#13#10;
  Result:=Result+'  initFunc();'#13#10;
  if userInf.NeedTinyMCE then begin
    Result:=Result+'drawborder("TinyEditDIV");'#13#10;
  end;
  if userInf.NeedTinyMCEAction then begin
    Result:=Result+'drawborder("TinyEditActionFilesDIV");'#13#10;
  end;


  Result:=Result+'  $(''#mmenu_import'').attr(''disabled'', '+fnIfStr(userInf.Links23Loaded, 'true', 'false')+');'#13#10;

  if (fnInIntArray(rolProduct, userInf.Roles)>-1) then begin
    if flNewModeCGI then begin
      Result:=Result+'  ec(''getmanufacturerlist'', ''selname=manufacturerid_addornum&sys=21'', ''newbj'');'#13#10;
    end
    else begin
      Result:=Result+'  ec(''getmanufacturerlist'', ''selname=manufacturerid_addornum&sys=21'', ''abj'');'#13#10;
    end;
  end;

  if (userInf.PageName='accountsreestr') then begin
    Result:=Result+'  $("#contractdatadiv").dialog({ autoOpen: false, title:"��������", resizeStop: savefloatingwinparams, dragStop: savefloatingwinparams, open: readfloatingwinparams});'#13#10;
    Result:=Result+'  $("#warerestsdiv").dialog({ autoOpen: false, resizeStop: savefloatingwinparams, dragStop: savefloatingwinparams, open: readfloatingwinparams});'#13#10;
  end;

  if (userInf.PageName='import') then begin
    Result:=Result+'  if ($("#divmodeltable").length) {$("#divmodeltable").dialog({autoOpen: false, width:"auto"});};'#13#10;
    Result:=Result+'  if ($("#divautotree").length) {$("#divautotree").dialog({autoOpen: false, width:500, maxHeigth:$( window ).height()});$("#divautotree").height($( window ).height())};'#13#10;
//    Result:=Result+'  if ($("#divtypetree").length) {$("#divtypetree").dialog({autoOpen: false, width:500});};'#13#10;
  end;


  Result:=Result+'});'#13#10;  //$(document).ready



  Result:=Result+'</script>'#13#10;
  Result:=Result+GoogleAnalytics;
  Result:=Result+'</head>'#13#10;
  Result:=Result+'<body onResize="set_sizesWA (left_block_expand);">'#13#10;     //   onResize=''set_sizes(left_block_expand);''

  Result:=Result+'<div id="jqdialog" style="display: none;"></div>'; // ��� ��� ������� jQuery
  Result:=Result+'<div id="jqdialoginfo" style="display: none;"></div>'; // ��� ��� ������� jQuery
  //Result:=Result+'<div id="jqdialoginfocreate" style="display: none;"></div>'; // ��� ��� ������� jQuery
  Result:=Result+'<div id=jqueryuidiv></div>'#13#10;
  Result:=Result+'<div style=''background: #aaa; filter:alpha(opacity=40); opacity: 0.4; width:100%; height: 100%; position: absolute; display: none; z-index: 1000;'' id=''loadingdiv''>';
  Result:=Result+'  <img src="/images/208_.gif" style=''position: absolute;''>';
  Result:=Result+'</div>';
  Result:=Result+'<div style="position: absolute; left: -200000px;">'#13#10; // ����� �������� ���������� ����, � ����� �� fancybox ������ ����������, hide � ��� �����

  Result:=Result+'<div id=aaformdiv style="width: 270px; margin: 10px; overflow: hidden;">'+coReloginText+fnAutenticationForm(false)+'</div>'#13#10;

  if Autenticated  then begin

    if userInf.PageName='accountsreestr' then begin
      Result:=Result+'<div id=warerestsdiv defwidth=250 defheight=400 defleft=2 deftop=715><form action="'+ScriptName+fnIfStr(flNewModeCGI,'/newbj','/abj')+'" onsubmit="return false;"><input type=hidden id=warecodeforinvoice><div></div><input type=text size=6 maxlength=6 id=wareqtyforinvoice>'
                    +'<button onclick=''ec("addwaretoinvoice", "wareid="+$("#warecodeforinvoice").val()+"&forfirmid="+$("#forfirmid").val()+"&accid="+$("#invoicecode").val()+"&wareqty="+$("#wareqtyforinvoice").val(),'+fnIfStr(flNewModeCGI,'"newbj"','"abj"')+');'' id=btnwaretoinvoice>� ����</button></form></div>'#13#10;

      Result:=Result+'<div id=contractdatadiv defwidth=250 defheight=400 defleft=2 deftop=515>'#13#10;
//      Result:=Result+'<div id=clientdatadiv style="position: absolute; top:30px; right: 0px; display: none; max-width: 250px;">'#13#10;
//      Result:=Result+'��������� �����: <span id=credlimit></span><br>�������� �������: <span id=paydelay></span> ����<br><span id=debtsum></span><br> ������: <span id=reserv></span><br>';
//      Result:=Result+'<span id=blockingmessage></span>';
      Result:=Result+'</div>'#13#10;
      Result:=Result+'<div id=contractlistdiv style="">'+'</div>';
    end;

    if userInf.PageName='import' then begin
      Result:=Result+'<div id=divmodeltable style="width: 500px; margin: 10px; overflow: hidden;" title="������"><table id=modeltable style="cursor: default;" ></table></div>'#13#10;
      Result:=Result+'<div id=divautotree style="width: 1000px; margin: 10px; overflow: auto;" class="treeview" title="����"><ul id=rep_auto_ul_0  style=''position: relative;''></ul></div>';
    end;

     Result:=Result+fnPodborWindow(true, true, true);


    if (fnInIntArray(rolProduct, userInf.Roles)>-1) then begin
      Result:=Result+'<div id="addorignumbyhanddiv" style="padding: 10px;">';
      Result:=Result+'<select id=manufacturerid_addornum>';
      Result:=Result+'<option value="-5"> </option>';
      Result:=Result+'</select>';
      Result:=Result+'<br /><input type=text id=ornumtext_addornum value="">';
      if flNewModeCGI then
        Result:=Result+'<input type=button value="��������" onclick=''ec("addornum", "ornumware="+$("#addornumbyhand").attr("name")+"&ornumtext="+$("#ornumtext_addornum").val()+"&manufacturerid="+$("#manufacturerid_addornum").val(), "newbj");''>'
      else
        Result:=Result+'<input type=button value="��������" onclick=''ec("addornum", "ornumware="+$("#addornumbyhand").attr("name")+"&ornumtext="+$("#ornumtext_addornum").val()+"&manufacturerid="+$("#manufacturerid_addornum").val(), "pabj");''>';
      Result:=Result+'</div>';  //addorignumbyhanddiv
    end;


    if userInf.PageName='mppregord' then begin
      Result:=Result+'<div id=divtabl1>';
      if flNewModeCGI then
        Result:=Result+'<form onsubmit="return sfbaNew(this);" method=post action="'+scriptname+'/mppactions">'
      else
        Result:=Result+'<form onsubmit="return sfba(this);" method=post action="'+scriptname+'/mppactions">';
      Result:=Result+'<input type=hidden name=act value=confirmregord>';
      Result:=Result+'<input type=hidden name=id ><table>';
      Result:=Result+'<table id=tabl1 style="position: relative; font-size: 11px;">';
      Result:=Result+'<tr>';
      Result:=Result+'  <td style="text-align: right;">�����: </td>';
      Result:=Result+'  <td><input type=text maxlength=20 name=login id=selpersonlogin value=""></td>';
      Result:=Result+'</tr>';

      Result:=Result+'<tr>';
      Result:=Result+'  <td style="text-align: right;">����������: </td>';
      Result:=Result+'  <td><input type=hidden name=firm id=selfirmhidden><input type=text id=selfirm class=firmlist disabled style=''width: 294px;'' oldval="">';
      Result:=Result+'</tr>';

      Result:=Result+'<tr>';
      Result:=Result+'  <td style="text-align: right;">�����. ����: </td>';
      Result:=Result+'  <td><SELECT style="width: 400px;" name=person id=selperson></select>';
      Result:=Result+'</tr>';
{
      Result:=Result+'<tr>';
      Result:=Result+'  <td style="text-align: center;" colspan=2><input type=submit value="��������� ������">&nbsp;<input type=button value="�������" onclick="$.fancybox.close();"></td>';
      Result:=Result+'</tr>';
}
        Result:=Result+'</table>';
        Result:=Result+'</form>';
        Result:=Result+'</div>';
    end;
  end;


  Result:=Result+'</div><!-- hidded divs -->'#13#10;  //hidded divs

  // ++++++++++++++++++++++++++ tinyMCEEditor +++++++++++++++++++++++++++++++++++++++++++++++++++
  if userInf.NeedTinyMCE then begin
    Result:=Result+'<div id=TinyEditDIV>';
    Result:=Result+'  <div class=wareinfoimgdiv>';
    Result:=Result+'    <div id="selectimagesdivcaption">���������� ������ �����������:</div>';
    Result:=Result+'    <div id="selectimagesdiv">������ �����������';
    Result:=Result+'<table id="filenamestablecontent" cellspacing="0" cellpadding="2" border="0"> ';
    Result:=Result+' <tbody> ';
    Result:=Result+'   </tbody> ';
    Result:=Result+'   </table>';
    Result:=Result+'    </div>';

    Result:=Result+'<div class=imgloaddiv><form method="GET" enctype="multipart/form-data" '+
                   'onSubmit="'+
                   'if ($(''#ffile'').attr(''value'')=='''') { alert(''�� �� ������� ����''); $(''#ffile'')[0].focus();} '+
                   'return sendfile(this);">'+
                   '<input type=hidden name=act value=savewareinfoimg><input type=hidden name=curUserInfo.UserID value="'+userInf.UserID+'">'+
                   '<input type=hidden name=editor value="tinyeditor">'+
                   '<input type=hidden name=wareid id=wareid value="">'+
                   '�������� ���� ��� ��������: '+
                   //'<input type="file" multiple="multiple" id="ffile" name="ffile" size="30">'+
                   '<input type="file" multiple="multiple" id="ffile" name=name="files[]" size="30">'+
                   '<input type=submit value=''��������� �� ������''></form>'+
                   '</div>';
                  // '<input type=button id=waredelbtn value=''������� �����������'' onClick=''ecq("delwareimg", "editor=tinyeditor&wareid="+$(".imgloaddiv #wareid")[0].value, "difdict", "�� ������������� ������ ������� �����������?");''></div>';
    Result:=Result+'  </div>';
    Result:=Result+'  <form method="POST" action="'+ScriptName+'/difdict" onSubmit="prepwareinfo(); return sfba(this);">';
    Result:=Result+'  <input type=hidden name=act value="savewareinfo">';
    Result:=Result+'  <input type=hidden name="wareid" id="id" value="">';
    Result:=Result+'  <textarea id=tinyeditor name=tinyeditor>';
    Result:=Result+'  </textarea>';

    Result:=Result+'  <div id=tebottompanel>';
    Result:=Result+'  <input id=tesavebtn type=submit value="���������">'
                  +'&nbsp;<input type=button value="�������" onclick="$(''#TinyEditDIV'').css(''display'', ''none'')"></form>';
//    Result:=Result+'  <input id=tesavebtn type=button value="���������" onclick=''ec("savewareinfo", "id="+this.name+"&text="+tinyserialize(tinyMCE.get("tinyeditor").getContent(), "tinyeditor"), "difdict");''>'
    Result:=Result+'  </div>';
    Result:=Result+'</div>';
  end;
// -------------------------- tinyMCEEditor ---------------------------------------------------
  if userInf.NeedTinyMCEAction then begin
    Result:=Result+'<div id="TinyEditActionFilesDIV">';
    Result:=Result+'  <form method="POST" class="motul-action-main-form" action="'+ScriptName+'/newbj" onSubmit="if (prepwareactionfiles()){ return sfbaNew(this);} else {return false;}">';
    Result:=Result+'  <div id="header-action-div">'+
      '<span id="action-header-caption">��������� �����:</span><input type=text size="80" id="action-header" name="action-header" value="">'+
      '<br><br>'+
      '<span class="action-check-span">��������� ��������:</span><input id="action-is-plex" name="action-is-plex" type=checkbox  disabled="disabled" title="" >'+
      '<span class="action-check-span">��������� CIPHER: </span><input id="action-is-chex" name="action-is-chex" type=checkbox  disabled="disabled" title="" >'+
      '<span class="action-join-span">��������� �����: </span><select id="join-action-select" onchange="changeMotulJoinWaresAction();"></select>'+
    '</div>';
    Result:=Result+'  <div id="header-action-date-div">'+
     '<span class="action-date-span">���� ������: </span><input id="action-fromdate" name="action-fromdate" maxlength="8" size="8" value="" type="text">'+
     '<img src="/images/calendar.png" style="margin: -3px 2px; cursor: pointer; width: 17px; height: 17px;" onclick="show_calendar(''action-fromdate'');">'+
     '<span class="action-date-span">���� ���������: </span><input id="action-todate" name="action-todate" maxlength="8" size="8" value="" type="text">'+
     '<img src="/images/calendar.png" style="margin: -3px 2px; cursor: pointer; width: 17px; height: 17px;" onclick="show_calendar(''action-todate'');">';
    Result:=Result+'</div>';
    Result:=Result+'  <input type=hidden name="act" value="motulsitemanage">';
    Result:=Result+'  <input type=hidden id="action-code" name="action-code" value="">';
    Result:=Result+'  <input type=hidden id="ware-code" name="ware-code" value="">';
    Result:=Result+'  <input type=hidden id="kindofoperation" name="kindofoperation" value="">';
    Result:=Result+'  <input type=hidden id="num-action-record" name="num-action-record" value="">';
    Result:=Result+'  <input type=hidden id="join-action-header" name="join-action-header" value="">';
    Result:=Result+'  <input type=hidden id="join-action-code" name="join-action-code" value="">';
    Result:=Result+'  <textarea id="tinyeditorinfo" name="tinyeditorinfo">';
    Result:=Result+'  </textarea>';
    Result:=Result+'  <div id=tebottompanel>';
    Result:=Result+'  <input id=tesavebtn type=submit value="���������">'
                  +'&nbsp;<input type=button value="�������" onclick="$(''#TinyEditActionFilesDIV'').css(''display'', ''none'')"></form>';
    Result:=Result+'  </div>';
    Result:=Result+'<div class="wareinfoimgdiv">';
    Result:=Result+'    <div class="selectimagesdivcaption">������� ����������� ������:</div>';
    Result:=Result+'      <div class="current-ware-image-div">';
    Result:=Result+'        <img id="current-ware-image">';
    Result:=Result+'      </div>';
    Result:=Result+'   <div class="imgloaddiv">'+
                   '   <form method="GET" enctype="multipart/form-data" onSubmit="'+
                   '   if ($(''#ffile-image'').attr(''value'')=='''') { alert(''�� �� ������� ����''); $(''#ffile'')[0].focus();} '+
                   '   return sendfile(this);">'+
                   '   <input type=hidden name=act value="save-ware-motul-img">'+
                   '   <input type=hidden id="ware-code-for-image" name="ware-code-for-image" value="">'+
                   '   �������� ���� ��� ��������: '+
                   '   <input type="file" multiple="multiple" id="ffile-image" name="files[]" size="30">'+
                   '   <input type=submit value=''��������� �� ������''></form>'+
                   '  </div>';
    Result:=Result+'</div>';

    Result:=Result+'</div>';
 end;
// -------------------------- tinyMCEEditorAction ---------------------------------------------------

  if Autenticated then begin
    if userInf.NeedDropFirmList then begin
      Result:=Result+'<div id=fagd><ul style="list-style-type: none;"></ul></div>';
    end;
    Result:=Result+fnSearchForm(userInf,(fnInIntArray(rolOPRSK, userInf.Roles)>-1) and (userInf.PageName='accounts'), true, true, userInf.ContractID);
    Result:=Result+'<div id=headerdiv><div id=overheader></div>';
    Result:=Result+'<div id=usernamediv>'+userInf.UserName+'</div>';
    Result:=Result+'</div>'; //  headerdiv
    end else begin
      Result:=Result+'<div id=headerdiv><div id=overheader></div></div>';
    end;

    Result:=Result+'<a href="http://www.vladislav.ua" target=_blank><img src=''/images/logo-Vladislav-rus.png'' id=''vladlogo''></a>'#13#10;

    Result:=Result+'<div id=leftmenudiv>'#13#10;
    Result:=Result+'<img id=lefttopmenuimgwide src=''/images/mainmenu/top-window-wide.png'''+fnIfStr(userInf.Short,' style="display: none;"','')+'>'#13#10;
    Result:=Result+'<img id=lefttopmenuimgshort src=''/images/mainmenu/top-window-short.png'''+fnIfStr(userInf.Short,'',' style="display: none;"')+'>'#13#10;
    if Autenticated then begin

      if (userInf.ShowImportPage)
        then Result:=Result+fnDrawMenuItem('������' , 'import',  'import', '�������� ������� �� ������', '');
      if (fnInIntArray(rolProduct, userInf.Roles)>-1) or (fnInIntArray(rolUiK , userInf.Roles)>-1) then
        Result:=Result+fnDrawMenuItem('������' , 'wares',  '', '', '');
      if (fnInIntArray(rolOPRSK, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('�����' , 'accountsreestr',  '', '', '');
      if (fnInIntArray(rolOPRSK, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('������ ��������' , 'order',  '', '', '');
      if ((fnInIntArray(rolRegional, userInf.Roles)>-1) or (fnInIntArray(rolManageSprav, userInf.Roles)>-1) or (fnInIntArray(rolUiK, userInf.Roles)>-1)  or (fnInIntArray(rolCustomerService, userInf.Roles)>-1)) then Result:=Result+fnDrawMenuItem('�����������' , 'mpp',  'mpp', '���������� ��������������', '');
      if ((fnInIntArray(rolModelManageAuto, userInf.Roles)>-1) or (fnInIntArray(rolModelManageMoto, userInf.Roles)>-1)) then Result:=Result+fnDrawMenuItem('������������' , 'cou',  'COUPage', '���������� ��������� ������������', '');

      if (fnInIntArray(rolRegional, userInf.Roles)>-1)
        or (fnInIntArray(rolSuperRegional, userInf.Roles)>-1)
        or (fnInIntArray(rolSaleDirector, userInf.Roles)>-1)
        or (fnInIntArray(rolUiK, userInf.Roles)>-1)
        or (fnInIntArray(rolCustomerService, userInf.Roles)>-1)
        then Result:=Result+fnDrawMenuItem('������' , 'mppregord',  'mppregord', '������ �� �����������', '');

      if (fnInIntArray(rolSaleDirector, userInf.Roles)>-1)
        then Result:=Result+fnDrawMenuItem('�������' , 'mppregzones',  'mppregzones', '���� ������������', '');


      if (fnInIntArray(rolManageUsers, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('������������' , 'webarmusers',  'webarmusers', '���������� webarm-��������������', '');
      if (fnInIntArray(rolManageBrands, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('������' , 'brandcross',  'brandcross', '���������� �������������� ������� GrossBee � TecDoc', '');
      if (fnInIntArray(rolManageBrands, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('��������' , 'logotypes',  'logotypes', '���������� ������������ ��������� � ��������� �� ������� ��������������', '');
      if (fnInIntArray(rolTNAManageAuto, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('���� ����������' , 'treeauto',  'TNAManagePageAuto', '���������� ������������ ����� ����������', '');
      if (fnInIntArray(rolTNAManageMoto, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('���� ���������' , 'treemoto',  'TNAManagePageMoto', '���������� ������������ ����� ���������', '');
      if flMotulTree then
        if (fnInIntArray(rolTNAManageMotul, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('���� Motul' , 'treemotul',  'TNAManagePageMotul', '���������� ������������ ����� Motul', '');
      if (fnInIntArray(rolModelManageAuto, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('���. ���. ����' , 'dirmodauto',  'prDirModelPageAuto', '���������� ������������ ��������������/��������� �����/������� �����������', '');
      if (fnInIntArray(rolModelManageMoto, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('���. ���. ����' , 'dirmodmoto',  'DirModelPageMoto', '���������� ������������ ��������������/��������� �����/������� ����������', '');

      if (fnInIntArray(rolNewsManage, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('�������' , 'newsmanage',  'newsmanage', '���������� ������� � ������', '');
      if (fnInIntArray(rolNewsManage, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('�����������' , 'notifications',  'notifications', '���������� �������������', '');


      //if (fnInIntArray(rolUiK, userInf.Roles)>-1) then Result:=Result+fnDrawMenuItem('���' , 'uik',  'uik', '�������� � ��������������� ������ ����� � ��������', '');

      if (userInf.SysOptions)
        then Result:=Result+fnDrawMenuItem('��������� �������' , 'sysoptions',  'sysoptions', '�������� �������� �������', '');
      Result:=Result+fnDrawMenuItem('���������' , 'options',  'options', '���������', '');
      if ((fnInIntArray(rolManageSprav, userInf.Roles)>-1) or (fnInIntArray(rolUiK, userInf.Roles)>-1)) then
        Result:=Result+fnDrawMenuItem('����������' , 'info',  'info', '����������', '');
      if ((fnInIntArray(rolRegional, userInf.Roles)>-1) or (fnInIntArray(rolSuperRegional, userInf.Roles)>-1) or (fnInIntArray(rolSaleDirector, userInf.Roles)>-1)) then  //vv
        Result:=Result+fnDrawMenuItem('������ �I' , 'mpbireports',  'mpbireports', '�������� ������� �� ������', '');  //vv
      if (fnInIntArray(rolManageMotulSite, userInf.Roles)>-1) then
        Result:=Result+fnDrawMenuItem('motul.vladislav.ua' , 'motulsite&kindofpage=3',  'motulsite', '�������� ���������� ���������� ����� motul.vladislav.ua', '');
      if flNewModeCGI then begin
        Result:=Result+fnDrawMenuItem('�����' , 'quit',  'quit', '', 'ec("quit", "", "newbj")');
      end
      else begin
        Result:=Result+fnDrawMenuItem('�����' , 'quit',  'quit', '', 'ec("quit", "", "anbj")');
      end;
    end else begin
      Result:=Result+fnAutenticationForm(true);
    end;
  Result:=Result+'<a href="http://www.motul.de" target=_blank id=leftbottommenuimgwide'+fnIfStr(userInf.Short,'style="display: none;"','')+'><img src=''/images/mainmenu/bottom-window-wide-motul.png''></a>'#13#10;
  Result:=Result+'<img id=leftbottommenuimgshort src=''/images/mainmenu/bottom-window-short.png'''+fnIfStr(userInf.Short,'',' style="display: none;"')+'>'#13#10;
  Result:=Result+'</div>';

 Result:=Result+'<iframe id="downloadframe" style="visibility: hidden;"></iframe>'; // ����� ��� �������� ������
  Result:=Result+'<div id=maindiv style="left: '+fnIfStr(userInf.Short, '100', '220')+'px;">'#13#10;

  Result:=Result+'<div id=WSRwrapper>'#13#10;
  Result:=Result+'  <div id=srchl>&nbsp;</div>'#13#10;
  Result:=Result+'  <div id=stht></div><img id=sthlt src="/images/window/corner-top-left.png"><img id=sthrt src="/images/window/corner-top-right.png">'#13#10;
  Result:=Result+'  <div id=smfb></div><img id=smflb src="/images/window/corner-bottom-left.png">'#13#10;
  Result:=Result+'  <img id=smfrb src="/images/window/corner-bottom-right.png">'#13#10;
  Result:=Result+'  <img id=smfrt src="/images/window/corner-top-right.png">'#13#10;
  Result:=Result+'  <h1>��������� ������</h1>'#13#10;
  Result:=Result+'    <table class=st cellspacing=0 id=WSRtableheader></table>'#13#10;
  Result:=Result+'  <div id=WSRcontentdiv><div id=wsrcbackdiv>&nbsp;</div>'#13#10;
  Result:=Result+'    <table class=st cellspacing=0 id=WSRtablecontent></table>'#13#10;
  Result:=Result+'  </div>'#13#10;// WSRcontentdiv
  Result:=Result+'</div>'#13#10;//WSRwrapper
  Result:=Result+'<div id=searchslider></div>'#13#10;

 if (userInf.PageName='accountsreestr')  then begin
   Result:=Result+'<div id="deliveryshedulerdiv"  tt="-1" deliverydate="-1">';//��� ������� ����������
   Result:=Result+'<div id="deliveryshedulerdiv_caption" >�������� � ������ �� ����������</div>';
   Result:=Result+'<table id=deliveryshedulerdiv_table class="st" cellspacing="5">&nbsp;</table>';
   Result:=Result+'<div id="deliverysheduler_viewall" ><button id=showalldeliverybtn title="�������� ��������� ��������" Onclick="ShowAllSchedulerDelivery();">'+
   '��� ����������</button></div>';
   Result:=Result+'</div>';

  Result:=Result+'<div id=fillheaderbeforeprocessingdiv style="width: 800px;"><form onsubmit="return false">';
  Result:=Result+'<input type=hidden name="act" value="so">';
  Result:=Result+'<input type=hidden id="ordr" name="ordr">';
  Result:=Result+'<input type=hidden id="forfirmiddeliv" name="forfirmiddeliv">';
  Result:=Result+'<input type=hidden id="shedulercode" name="shedulercode">';
  Result:=Result+'<input type=hidden id="sendordermark" name="sendordermark" value="1">';
  Result:=Result+'<input type=hidden id="deliverydatetext" name="deliverydatetext">';
  Result:=Result+'<fieldset><legend>������ ��������� ������</legend>';
  Result:=Result+'<input name=typeofgetting type=radio id=getting1 value=1 checked title=""><span title="������������ ����� ����� �������������� ��� ��� �� ������ ��������">������ </span>';
  Result:=Result+'<input name=typeofgetting type=radio id=getting2 value=2 title=""><span title="������������ ����� ����� ������ ��� ���������� � ��������� ���� � �������">���������</span> ';
  Result:=Result+'<input name=typeofgetting type=radio id=getting0 value=0 title=""><span title="'+
  ' ">��������</span>';
  Result:=Result+'<input name=typeofgetting type=radio id=getting3 value=3 title=""><span title="'+
  ' ">������ �� ������</span>';
  Result:=Result+'</fieldset>';

  Result:=Result+'<fieldset id=datetimediv_field>';
  Result:=Result+'<div name=datetimediv>';
  Result:=Result+'<table ><tbody><tr>';
  Result:=Result+'<td>����: </td><td><select name=deliverydate  onChange="checkWareOnStorage();  ';
  Result:=Result+' var tt=$(''#fillheaderbeforeprocessingdiv [name^=\''tt\'']'').val(); ';
  Result:=Result+' $(''#deliverykind'').empty(); $(''#deliverytimeout'').empty(); $(''#deliverytimein'').empty();$(''#shedulercode'').val(''0'');  ';
  Result:=Result+' fillHelpDesk(); ';
  Result:=Result+' var deliverydate=$(''#fillheaderbeforeprocessingdiv select[name^=\''deliverydate\''] option:selected'').text();  var v=$(''#fillheaderbeforeprocessingdiv input[name^=\''typeofgetting\'']:checked'').val(); ';
  Result:=Result+' $(''#deliverydatetext'').val(deliverydate.substring(0,10)); ';
  Result:=Result+'if (v==2){ ec(''gettimelistselfdelivery'',''date=''+deliverydate.substring(0,10)+''&OldTime=''+$(''#pickuptimespan select[name^=\''pickuptime\'']'').val()+''&contract=''+$(''#contract'').val()+''&forfirmid=''+$(''#forfirmid'').val(),'+fnIfStr(flNewModeCGI,'''newbj''','''abj''')+');}   ';
  Result:=Result+'"></select></td>';
  Result:=Result+'<td><span id=pickuptimespan> �����: <select name=pickuptime  onClick=" fillHelpDesk(); '+
  'var deliverydate=$(''#fillheaderbeforeprocessingdiv select[name^=\''deliverydate\''] option:selected'').text(); if (deliverydate !=''''){'+
  ' this.style.backgroundColor=this.options[this.selectedIndex].style.backgroundColor;';
  Result:=Result+' for(var i = 1; i < this.options.length; i++){ this.options[i].style.backgroundColor=''#FFFFFF''; } }';
  Result:=Result+' "></select></span></td></tr>';
  Result:=Result+'<tr><td><span id=ttCaption>�������� �����:</span></td><td><select id=_ttorderselect name=tt _deliverykind="-1" _deliverytimeout="-1" _deliverytimein="-1" _shedulercode="-1" onClick="fillHelpDesk(); checkWareOnStorage(); ';
  Result:=Result+' var deliverydate=$(''#fillheaderbeforeprocessingdiv select[name^=\''deliverydate\''] option:selected'').text(); var btn = document.getElementById(''showdeliveriesbtn''); ';
  Result:=Result+' if ((this.value !=0) && (deliverydate !='''')) { ';
  Result:=Result+' btn.disabled = false;}else {if (!btn.disabled){btn.disabled = true;} };">';
  Result:=Result+' </select></td><td></td></tr>'#13#10;
  Result:=Result+'<tr><td></td>';
  Result:=Result+'<td align="left">';
  Result:=Result+'    <button disabled="disabled" id=showdeliveriesbtn title="�������� ��������� ��������" style=" font-color:#000000;"  onClick=" fillHelpDesk(); if (!this.disabled) {'+
  ' var tt=$(''#fillheaderbeforeprocessingdiv [name^=\''tt\'']'').val();'+
  ' var deliverydate=$(''#fillheaderbeforeprocessingdiv select[name^=\''deliverydate\''] option:selected'').text(); '+
  ' var shedulercode=$(''#shedulercode'').val(); '+
  ' var forfirmid=$(''#forfirmid'').val(); '+
  ' var contractid=$(''#contract'').val(); '+
  'if ( ($(''#deliveryshedulerdiv'').attr(''tt'')!=tt) '+
  '|| ($(''#deliveryshedulerdiv'').attr(''deliverydate'')!=deliverydate) ){ '+
  ' ec(''filldeliverysheduler'', ''_tt=''+tt+''&forfirmid=''+forfirmid+''&contractid=''+contractid+''&_deliverydate=''+deliverydate.substring(0,10)+''&_shedulercode=''+shedulercode,'+fnIfStr(flNewModeCGI,'''newbj''','''abj''')+');}else {$(''#deliveryshedulerdiv'').dialog(''open'');}'+
  ' }">������� ����������</button>';
  Result:=Result+' </td><td></td>';
  Result:=Result+' </tr></tbody></table>'#13#10;
  Result:=Result+'</div>';
  Result:=Result+'<div id=deliverychoicediv>';
  Result:=Result+'  <div id=deliverydescribe style="width: 100%; height: 100px;">';
  Result:=Result+'    <span></span>';
  Result:=Result+'   <br>';
  Result:=Result+' <table class="st" cellspacing="5" id=dopdatatable style="font-size:14px;"><tbody>';
  Result:=Result+'<tr class="grayline"><td align="left">����� �������� �� ������</td> <td align="left" >������ ��������</td><td align=left" >����������� ��������</td>';
  Result:=Result+'</tr>';
  Result:=Result+'<tr >';
  Result:=Result+' <td> <span id=deliverytimeout  style="color: #2F4F4F;font-weight:bold;"></span></td>';
  Result:=Result+' <td><span id=deliverykind style="color: #2F4F4F;font-weight:bold;" ></span></td>';
  Result:=Result+' <td><span id=deliverytimein style="color: #2F4F4F;font-weight:bold;" ></span> </td></tr>';
  Result:=Result+' </tbody></table>';
  Result:=Result+'  </div>';
  Result:=Result+'</div>';
  Result:=Result+'<div  style="display: block;"><span id=helpdesk ></span></div>';
  Result:=Result+'</fieldset>';
  Result:=Result+'</form></div>'; //fillheaderbeforeprocessingdiv

  prOnReadyScriptAdd('  InitUIDialogDelivery(); '#13#10);

  prOnReadyScriptAdd('  InitUIDialog(''deliveryshedulerdiv'',''�������� ����������'',500); '#13#10);
  prOnReadyScriptAdd('  DeliveryFormEvent();  '#13#10);

 end;


  // ��� �������������� ��������
  Result:=Result+'<div id=conteinernewseditdiv ></div>'#13#10;    //���� ������ �������������� �������
  prOnReadyScriptAdd('  InitUIDialog(''conteinernewseditdiv'',''�������������� �������'',800); '#13#10);

  Result:=Result+'<div id=warenodefilterdialog ></div>'#13#10;    //���� ������� ������������ ���������
  prOnReadyScriptAdd('  InitUIDialog(''warenodefilterdialog'',''����� ���������'',400); '#13#10);

  // ��� ���������� ������
  Result:=Result+'<div id=viewsearchingwarediv _oldcodeproduct="-1" _model="-1" _node="-1"></div>'#13#10;    //���� ������ �������� ������ ��� ������
  prOnReadyScriptAdd('  InitUIDialog(''viewsearchingwarediv'',''�������� ������'',800); '#13#10);

  // ��� �������� ������� ������
  Result:=Result+'<div id=viewimagewarediv ><img id=viewimagewareimg></div>'#13#10;    //���� ������ ������������ �������
  prOnReadyScriptAdd('  InitUIDialog(''viewimagewarediv'',''�������� ���������� �������'',800); '#13#10);

  Result:=Result+'<script>'#13#10;
  Result:=Result+'$(document).ready(function() {'#13#10+OnReadyScript+'});'#13#10;
  Result:=Result+'</script>'#13#10;
end;

// �����, ��������� ��� ���� ������� ���������
function fnFooter(var userInf:TEmplInfo): string;
begin
  Result:='';
  // ����������� ���� contentdiv(�������) � maindiv
  Result:=Result+'</div>';
  Result:=Result+'<script>';
  Result:=Result+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
  Result:=Result+OnReadyScript;
  Result:=Result+'</script>';
  Result:=Result+'</body>';
end;



//---------------------------------------------------------------
// ������ �������� ������
function fnGetWebArmNewsList(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
 var
  s, Link, Pict: string;
  i, j: integer; // loop local var
  MainHeader, Code: string;
  HeaderHeight: integer;
begin
 Result:=Result+'';
 //createTableWebArmNewsList()
 OnReadyScript:='';
 MainHeader:='';
 HeaderHeight:=0;
 MainHeader:=MainHeader+'<div style=''text-align: right;''></div>';
 j:=Stream.ReadInt;
 prOnReadyScriptAdd(' TStream.arlen='+IntToStr(j)+'; '#13#10);
 prOnReadyScriptAdd(' TStream.artable= new Array(); '#13#10);
 for i:=1 to j do begin
  Code:=IntToStr(Stream.ReadInt);
  prOnReadyScriptAdd(' TStream.artable['+IntToStr(i-1)+']=new Array('+Code+','+BoolToStr(Stream.ReadBool)+','+BoolToStr(Stream.ReadBool)+','+BoolToStr(Stream.ReadBool)+','''+Stream.ReadStr+''','''+Stream.ReadStr+''','''+GetHTMLSafeString(Stream.ReadStr) );
  Pict:=Stream.ReadStr; // ��������
  Link:=Stream.ReadStr; // ������
  prOnReadyScriptAdd(''','''+Pict+''','''+Link+''','''+fnGetThumb(fnTestDirEnd(BaseDir, true)+'/images/actions/'+Pict, 160, 300,'server.ini')+''','''+Stream.ReadStr+''','''+Stream.ReadStr+''','+IntToStr(Stream.ReadInt)+');' );
 end;
 prOnReadyScriptAdd(' getWABodyNewsManage(TStream,'''+DescrImageUrl+'''); '#13#10);
 // ############################################################################
 (*TableHeader:=TableHeader+'<tr>';
 TableHeader:=TableHeader+'<td title="�������">���</td>';
 TableHeader:=TableHeader+'<td>����</td>';
 TableHeader:=TableHeader+'<td>Mo�o</td>';
 TableHeader:=TableHeader+'<td>������</td>';
 TableHeader:=TableHeader+'<td>���������</td>';
 TableHeader:=TableHeader+'<td>��������</td>';
 TableHeader:=TableHeader+'<td>������</td>';
 TableHeader:=TableHeader+'<td>������.</td>';
 TableHeader:=TableHeader+'<td>���� ���.</td>';
 TableHeader:=TableHeader+'<td>���-�� ������</td>';
 TableHeader:=TableHeader+'<td><input type=button value=''��������'' onclick=''shownewsaedialog();''></td>';
 TableHeader:=TableHeader+'</tr>'#13#10;

 TableBody:='';
 j:=Stream.ReadInt;
 for i:=1 to j do begin
   Code:=IntToStr(Stream.ReadInt);
   TableBody:=TableBody+'<tr  onclick="ec(''editactionnews'', ''id='+(Code)+''', ''difdict'');" id=newsln' +Code+' class="lblchoice'+fnIfStr((i mod 2)=0, ' altrow', '')+'" >'#13#10;
   TableBody:=TableBody+'  <td><img src="/images/acckind'+fnIfStr(Stream.ReadBool, '1', '0')+'.gif"></td>'#13#10;
   TableBody:=TableBody+'  <td><img src="/images/acckind'+fnIfStr(Stream.ReadBool, '1', '0')+'.gif"></td>'#13#10;
   TableBody:=TableBody+'  <td><img src="/images/acckind'+fnIfStr(Stream.ReadBool, '1', '0')+'.gif"></td>'#13#10;
   TableBody:=TableBody+'  <td>'+(Stream.ReadStr)+'</td>'#13#10;
   TableBody:=TableBody+'  <td>'+(Stream.ReadStr)+'</td>'#13#10;

   TableBody:=TableBody+'  <td>'+GetHTMLSafeString(Stream.ReadStr)+'</td>'#13#10;
   Pict:=Stream.ReadStr; // ��������
   Link:=Stream.ReadStr; // ������

   TableBody:=TableBody+'  <td style="text-align: left;"><a class=atooltip href="'+Link+'" title="<img src='+fnGetThumb(fnTestDirEnd(BaseDir, true)+'/images/actions/'+Pict, 160, 300,'server.ini')+'>">'+Link+'</td>'#13#10;  //vv
   TableBody:=TableBody+'  <td>'+(Stream.ReadStr)+'</td>'#13#10;
   TableBody:=TableBody+'  <td>'+(Stream.ReadStr)+'</td>'#13#10;
   TableBody:=TableBody+'  <td>'+(IntToStr(Stream.ReadInt))+'</td>'#13#10;
   TableBody:=TableBody+'  <td>'
     +'<a class="abgslide" style="background-image: url('+DescrImageUrl+'/images/wedit.png); position: static; float: left;" '
     +'href="#" title="������������� �������" onclick="ec(''editactionnews'', ''id='+(Code)+''', ''difdict'')"></a>'
     +'<a class="abgslide" style="background-image: url('+DescrImageUrl+'/images/wdell.png); position: static; float: left;" '
     +'href="#" title="������� �������" onclick="ec(''delactionnews'', ''id='+(Code)+''', ''difdict'')"></a>'
     +'</td>'#13#10;
   TableBody:=TableBody+'</tr>'#13#10;
 end;
 *)

 //Result:=Result+fnWriteTableData(MainHeader, TableHeader, TableBody, HeaderHeight);
 Result:=Result+fnWriteTableData(MainHeader, '', '', HeaderHeight);
 Result:=Result+'<script>';
 Result:=Result+'$(document).ready(function() {'#13#10+OnReadyScript+''#13#10;
 Result:=Result+' $(".atooltip").easyTooltip();'#13#10;
 Result:=Result+'});'#13#10;
 Result:=Result+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
 Result:=Result+'</script>';
end;
//-------------------------------------------------------------

//---------------------------------------------------------------
// ������ ������ ������
function fnGetWebArmAccounts(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
 var
  s: string;
  i, Count: integer; // loop local var
  MainHeader, TableHeader, TableBody: string;
  HeaderHeight: integer;
begin
  s:='';
  MainHeader:='';
  Result:='';
  Count:=Stream.ReadInt;
  s:=s+'<script> TStream.arlen='+IntToStr(Count)+';  '#13#10;
  s:=s+' TStream.artable= new Array(); '#13#10;
  for i:=0 to Count-1 do begin
    s:=s+' TStream.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','''+GetJSSafeString(Stream.ReadStr)+''','''+GetJSSafeString(Stream.ReadStr)+''','+BoolToStr(Stream.ReadBool)+');';
  end;
  Count:=Stream.ReadInt;
  s:=s+' TStream2.arlen='+IntToStr(Count)+';  '#13#10;
  s:=s+' TStream2.artable= new Array(); '#13#10;
  for i:=0 to Count-1 do begin
    s:=s+' TStream2.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','''+GetJSSafeString(Stream.ReadStr)+''');';
  end;
  Count:=Stream.ReadInt;
  s:=s+' TStream3.arlen='+IntToStr(Count)+';  '#13#10;
  s:=s+' TStream3.artable= new Array(); '#13#10;
  for i:=0 to Count-1 do begin
    s:=s+' TStream3.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','+IntToStr(Stream.ReadInt)+','''+GetJSSafeString(Stream.ReadStr)+''','''+GetJSSafeString(Stream.ReadStr)+''');';
  end;
  Count:=Stream.ReadInt;
  s:=s+' TStream4.arlen='+IntToStr(Count)+';  '#13#10;
  s:=s+' TStream4.artable= new Array(); '#13#10;
  for i:=0 to Count-1 do begin
    s:=s+' TStream4.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','''+GetJSSafeString(Stream.ReadStr)+''');';
  end;

  Count:=Stream.ReadInt;
  s:=s+' TStream5.arlen='+IntToStr(Count)+';  '#13#10;
  s:=s+' TStream5.artable= new Array(); '#13#10;
  for i:=0 to Count-1 do begin
    s:=s+' TStream5.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','''+GetJSSafeString(Stream.ReadStr)+''','+BoolToStr(Stream.ReadBool)+','+BoolToStr(Stream.ReadBool)+');';
  end;
  Count:=Stream.ReadInt;
  s:=s+' TStream6.arlen='+IntToStr(Count)+';  '#13#10;
  s:=s+' TStream6.artable= new Array(); '#13#10;
  for i:=0 to Count-1 do begin
    s:=s+' TStream6.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','''+GetJSSafeString(Stream.ReadStr)+''');';
  end;
   s:=s+' getWATableAccounts(TStream,TStream2,TStream3,TStream4,TStream5,TStream6,"'+FormatDateTime('dd.mm.yy', SysUtils.Date-7)+'"); '#13#10;
   s:=s+'</script> ';
 TableBody:='';
 TableHeader:='<tr>';
 TableHeader:=TableHeader+'</tr>';

 Result:=Result+fnWriteTableData('', TableHeader, TableBody, constPayInvoiceFilterHeader);
 Result:=Result+s;
 Result:=Result+'<script>';
 Result:=Result+'$(document).ready(function() {'#13#10+OnReadyScript+''#13#10;
 Result:=Result+' $(".atooltip").easyTooltip();'#13#10;
 Result:=Result+'});'#13#10;
 Result:=Result+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
 Result:=Result+'</script>';
end;
//-------------------------------------------------------------


//---------------------------------------------------------------
// ������ ������� ������
function fnGetWebArmWaresList(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
 var
  s, Error: string;
       i, j: integer; // loop local var
  iMaxBrand: integer; // m�x ���. �������
  iMaxGroup: integer; // max ���. ����� � ������

  _Top, _Left, WorkAreaTop,
  LeftBlockWidth,
  TreeViewWidth,
  TreeViewHeight,
  Margins  : integer;
//  BlockHeight: integer;
begin
  s:='';
  _Top:=45;
  _Left:=0;
  LeftBlockWidth:=620;
  TreeViewWidth:=250;
  TreeViewHeight:=200;
  Margins:=10;
//BlockHeight:=150;
  WorkAreaTop:=246;

  s:=s+'<div id=treeviewWrap '+fnGetLTWHStyle(_Left, _Top, TreeViewWidth, TreeViewHeight)+'><div id=treeview class=treeview style="width: auto; right: 10px;"><ul id=ulmain></ul></div></div>';
  s:=s+'<div id=searchresWrap '+fnGetLTWHStyle(_Left+TreeViewWidth+Margins, _Top, LeftBlockWidth-TreeViewWidth-Margins, TreeViewHeight)+'class=divh1><h1>���������� ������</h1><div class=inborder id=searchres><table id=searchrestable class=st></table></div></div>';
  if flNewModeCGI then
    s:=s+'<div id=searcform ><form action="'+ScriptName+'/newbj" onSubmit="return sfbaNew(this);"><input type=hidden name=act value=getwareforproduct>'
  else
   s:=s+'<div id=searcform ><form action="'+ScriptName+'/pabj" onSubmit="return sfba(this);"><input type=hidden name=act value=getwareforproduct>';

   s:=s+'������ ������:<input type=text name=templ id=templ style="width: 250px;">'+
    '<input type=checkbox name=ignorespec id=ignorespec onClick=''setCookie_("ignorespec", this.checked?1:0, getExpDate_(365,0,0),"/",0,0);'' '+
    fnIfStr(userInf.strCookie.Values['ignorespec']='1',' checked','')+
  ' title="� ����. ������� �� ����� ����������� ��� ������� # ! (������) , ; : - . [ ] / + � (  ) \ '' ">&nbsp;���.����.<input type=submit value=''�����''></form></div>';



  // +++ ���� ��� ������ �� �������� � ����� ������ +++
  s:=s+'<div id=csrWrap class=divh1 style="left: '+IntToStr(_Left+LeftBlockWidth+Margins)+'px; top:'+IntToStr(_Top)+'px;'+
                                                 'height: 92px; right: '+IntToStr(Margins)+'px;">';
  s:=s+' <h1>������� ����������</h1>'#13#10;
  s:=s+'<div class=inborder id=csrdiv>';
  s:=s+'<a href="#" onclick=''$("#downloadframe")[0].src="'+ScriptName+'/ifbj?act=getlocalfile&filename=product-managers_functional.docx'+'";''>���������� �������-���������</a>';


  s:=s+'</div></div>'#13#10;   // inborder clientsearchreport

  // ��������
  s:=s+'<div id=workareaWrap class=noactive style="left: '+IntToStr(0)+'px; top:'+IntToStr(WorkAreaTop)+'px;'+
                                         'bottom: 1px;"><div id=workareaheader></div>';
  s:=s+'<div style=''position: absolute; left: 0px; top: 33px; bottom: 10px; width: 10px; background-image: url(/images/window/left.png)''></div>';
  s:=s+'<div style=''position: absolute; left: 10px; right: 10px;  bottom: 0px; height: 10px; background-image: url(/images/window/bottom.png)''></div>';
  s:=s+'<div style=''position: absolute; right: 0px; top: 33px; bottom: 10px; width: 10px; background-image: url(/images/window/right.png)''></div>';
  s:=s+'<div style=''position: absolute; left: 370px; right: 10px;  top: 23px; height: 10px; background-image: url(/images/window/top.png)''></div>';
  s:=s+'<img style=''position: absolute; left: 0px; bottom: 0px;'' src=''/images/window/corner-bottom-left.png''>';
  s:=s+'<img style=''position: absolute; right: 0px; bottom: 0px;'' src=''/images/window/corner-bottom-right.png''>';
  s:=s+'<img style=''position: absolute; right: 0px; top: 23px;'' src=''/images/window/corner-top-right.png''>';
  iMaxBrand:=0;
  s:=s+'<a href="#" id=tab'+IntToStr(iMaxBrand+1)+' class="tablabel" style=''left:' +IntToStr((iMaxBrand)*90)+'px;'' onClick="tabvis(' +IntToStr(fnNextInt(iMaxBrand))+');" title="������������ ������">OE</a>';
  s:=s+'<a href="#" id=tab'+IntToStr(iMaxBrand+1)+' class="tablabel" style=''left:' +IntToStr((iMaxBrand)*90)+'px;'' onClick="tabvis(' +IntToStr(fnNextInt(iMaxBrand))+');" title="�������, �������� � GrossBee">�������(GB)</a>';
  s:=s+'<a href="#" id=tab'+IntToStr(iMaxBrand+1)+' class="tablabel" style=''left:' +IntToStr((iMaxBrand)*90)+'px;'' onClick="tabvis(' +IntToStr(fnNextInt(iMaxBrand))+');" title="�������, ��������� ����� ���������� ������������ �������">�������(��)</a>';
  s:=s+'<a href="#" id=tab'+IntToStr(iMaxBrand+1)+' class="tablabel" style=''left:' +IntToStr((iMaxBrand)*90+1)+'px;'' onClick="tabvis(' +IntToStr(fnNextInt(iMaxBrand))+');" title="�����, `�������������` �������"> �������������</a>';
  s:=s+'<a href="#" id=tab'+IntToStr(iMaxBrand+1)+' class="tablabel" style=''left:' +IntToStr((iMaxBrand)*90)+'px;'' onClick="tabvis(' +IntToStr(fnNextInt(iMaxBrand))+');" title="������ �� ������, ������� ��� � ����� ������������"></a>';

  s:=s+'<div class="divh1 tabdiv" id=waredetdiv1 style=''top: 22px; bottom: 5px; left: 5px; right: 5px;''>'#13#10;
  s:=s+'<h1></h1><a class=abgslide id=addornumbyhand title=''�������� ������������ ����� �������'' href=''#'' onClick=''addornum(this.name, -1, 1, "", "");'' '+
       'style=''background-image: url(/images/wplus.png); right: 13px; top: 15px; display: none;''></a>'#13#10;

  s:=s+'<div class=divh1 style=''top: 20px; left: 0px; width: 50%; height: 36px;''>'#13#10;
  s:=s+'<h1>���������� ������������ ������ </h1>';
  s:=s+'</div>';
  s:=s+'<div class=divh1 style=''top: 20px; right: 0px; width: 50%; height: 36px;''>'#13#10;
  s:=s+'<h1>������������ ������������ ������ </h1>';
  s:=s+'</div>';

  s:=s+'<div style=''position:absolute; bottom: 0; width: 50%; left:0; top:56px; overflow:auto''>'#13#10;
  s:=s+'<table id=orignumstable class=st style=''width: 100%;''></table>'#13#10;
  s:=s+'</div>'#13#10;   //

  s:=s+'<div style=''position:absolute; bottom: 0; width: 50%; right:0; top:56px; overflow:auto''>'#13#10;
  s:=s+'<table id=wrongoetable class=st style=''width: 100%;''></table>'#13#10;
  s:=s+'</div>'#13#10;   //

  s:=s+'</div>';   //waredetdiv1

  s:=s+'<div class="divh1 tabdiv" id=waredetdiv2 style=''top: 22px; bottom: 5px; left: 5px; right: 5px; display: none;''>'#13#10;
  s:=s+'<h1></h1>'#13#10;

  s:=s+'<div class=inborder id=gbanalogsdiv style=''''>'#13#10;
  s:=s+'<table id=gbanalogtable class=st></table>'#13#10;
  s:=s+'</div>'#13#10;   //gbanalogsdiv
  s:=s+'</div>';   //waredetdiv2

  s:=s+'<div class="divh1 tabdiv" id=waredetdiv3 style=''top: 22px; bottom: 5px; left: 5px; right: 5px; display: none;''>'#13#10;
  s:=s+'<h1></h1>'#13#10;

  s:=s+'<div class=inborder id=onanalogsdiv style=''''>'#13#10;
  s:=s+'<table id=onanalogtable class=st></table>'#13#10;
  s:=s+'</div>'#13#10;   //onanalogsdiv
  s:=s+'</div>';   //waredetdiv3

  s:=s+'<div class="divh1 tabdiv" id=waredetdiv4 style=''top: 22px; bottom: 5px; left: 5px; right: 5px; display: none;''>'#13#10;
  s:=s+'<h1></h1>'#13#10;
  s:=s+'<a class=abgslide title=''��������� �����, ��� �������������, �������'' href=''#'' onClick=''addODanalog();'' '+
       'style=''background-image: url(/images/wplus.png); right: 13px; top: 15px; z-index: 10;''></a>'#13#10;
  s:=s+'<div class=divh1 style=''top: 20px; left: 0px; width: 50%; height: 36px;''>'#13#10;
  s:=s+'<h1>����������</h1>';
  s:=s+'</div>';
  s:=s+'<div class=divh1 style=''top: 20px; right: 0px; width: 50%; height: 36px;''>'#13#10;
  s:=s+'<h1>������������</h1>';
  s:=s+'</div>';

  s:=s+'<div style=''position:absolute; bottom: 0; width: 50%; left:0; top:56px; overflow:auto''>'#13#10;
  s:=s+'<table id=onediractanalogstable class=st style=''width: 100%;''></table>'#13#10;
  s:=s+'</div>'#13#10;   //

  s:=s+'<div style=''position:absolute; bottom: 0; width: 50%; right:0; top:56px; overflow:auto''>'#13#10;
  s:=s+'<table id=wrongonediractanalogstable class=st style=''width: 100%;''></table>'#13#10;
  s:=s+'</div>'#13#10;   //


  s:=s+'</div>';   //waredetdiv4

  s:=s+'<div class="divh1 tabdiv" id=waredetdiv5 style=''top: 22px; bottom: 5px; left: 5px; right: 5px; display: none;''>'#13#10;
  s:=s+'<h1></h1>'#13#10;

  s:=s+'</div>';   //waredetdiv5


  s:=s+'</div>';   // workareaWrap

  s:=s+'<script>'#13#10;

  iMaxBrand := Stream.ReadInt;
  for i := 1 to iMaxBrand do begin
    s := s + 'addbrand(' + IntToStr(Stream.ReadInt) + ', "' + Stream.ReadStr + '");'#13#10;
    iMaxGroup := Stream.ReadInt;
    for j := 1 to iMaxGroup do
      s := s + 'addgroup(' + IntToStr(Stream.ReadInt) + ', "' + Stream.ReadStr + '");'#13#10;
    end;

  s:=s+'drawborder("treeviewWrap");'#13#10;
  s:=s+'drawborder("searchresWrap");'#13#10;
  s:=s+'drawborder("orignumsWrap");'#13#10;
  s:=s+'drawborder("excelWrap");'#13#10;
  s:=s+'drawborder("csrWrap");'#13#10;
  s:=s+'$(''a[id^="ali_"]'').bind(''dblclick'', function(event) {'#13#10;
  if flNewModeCGI then
    s:=s+'  ec("getwareforproduct", "id="+this.id.substr(4), "newbj") ;'#13#10
  else
    s:=s+'  ec("getwareforproduct", "id="+this.id.substr(4), "pabj") ;'#13#10 ;

  s:=s+'});'#13#10;

  s:=s+'$(''a[id^="ali_"]'').attr(''title'', ''������ ������� ��������� �� �������� ����� �� ������ ��� ������'');'#13#10;

  s:=s+'$(''a[id^="ali_"]'').bind(''click'', function(event) {'#13#10;
  s:=s+'  $(''#biftdid'').attr(''value'', this.id.substr(4));'#13#10;
  s:=s+'  $(''#biftd'').attr(''value'', ''������ �� TecDoc �� ''+((this.previousSibling)?''������ '':''������ '')+this.innerHTML);'#13#10;
  s:=s+'  $(''#biftd'').css(''visibility'', ''visible'');'#13#10;
  s:=s+'  $(''#bpra'').attr(''value'', ''����� �� �������� �� ''+((this.previousSibling)?''������ '':''������ '')+this.innerHTML);'#13#10;
  s:=s+'  $(''#bpra'').attr(''disabled'', false);'#13#10;
  s:=s+'});'#13#10;

// ��������� ���������� ���������� ������
  iMaxBrand := Stream.ReadInt;
  s:=s+'var sourceofdata=[];'#13#10;
  for i := 1 to iMaxBrand do begin
    s := s + 'sourceofdata[' + IntToStr(Stream.ReadInt) + ']="' + Stream.ReadStr + '";'#13#10;
  end;

  s:=s+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
  s:=s+'</script>'#13#10;
  s:=fnWriteSimpleText(s);
  Result:=s;
end;
//-------------------------------------------------------------

// ������ ������ ������
//-------------------------------------------------------------
function fnGetWebArmImport(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
 var
  s, s1, s2: string;
  ForImport, ForExport: string;
  i, Count: integer;
begin
  s:='';
  s:=s+'<iframe id=jobframe name=jobframe></iframe>';
  ForImport:='';
  ForExport:='';
  Count:=Stream.ReadInt;
  for i:=0 to Count do begin
    s1:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    ForExport:=ForExport+'<option value='+s1+'>'+s2+'</option>'';'#13#10;
  end;
  Count:=Stream.ReadInt;
  for i:=0 to Count do begin
    s1:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    ForImport:=ForImport+'<option value='+s1+'>'+s2+'</option>'';'#13#10;
  end;


  if (ForExport<>'') then begin
    s:=s+'<form id=exportform method="POST">';
    s:=s+'<h1>�������� ��������� ������</h1>';
    s:=s+'<input type=hidden name=act value=commonimport><input type=hidden name=curUserInfo.UserID value="'+userInf.UserID+'">'+
         '<input type=hidden name=scrname value="'+ScriptName+'/ifbj">';
    s:=s+'��� ������: <select name=imptype id=exptype>';
    s:=s+ForExport+#13#10;
    s:=s+'</select>'#13#10;
    s:=s+'<div id=changeableinputs><br />'#13#10;
    s:=s+'</div>'#13#10;
    s:=s+'���.e-mail:<input type=text id="dop_email" name="dop_email" value="" style="width:450px;"><br>'#13#10;     //
    s:=s+'<input type=button value=''�������� ������'' onclick=''getreport();''>&nbsp;';
    s:=s+'</form><br />'#13#10;
  end;


  if (ForImport<>'') then begin
    s:=s+'<form id=importform name=importform method="POST" enctype="multipart/form-data" action="'+ScriptName+'/af" '+
    'onSubmit="'+
    'if ($(''#ffile'').attr(''value'')=='''') { alert(''�� �� ������� ����''); $(''#ffile'')[0].focus();} '+
    'return sendfile(this);">';
    s:=s+'<h1>�������� ������� �� ������</h1>';
    s:=s+'<input type=hidden name=act value=commonimport><input type=hidden name=curUserInfo.UserID value="'+userInf.UserID+'">'+
    '�������� ���� ��� ��������: <input type="file" id="ffile" name="ffile" size="50"><br />'+
    '��� ����� �������: <select name=imptype id=imptype>';
    s:=s+ForImport+#13#10;
    s:=s+'</select>'#13#10;
    s:=s+'<a id=getimporthelp href=#  style="display: none;"><img src="/images/help_2022.png"></a>';
    s:=s+'<br />���.e-mail:<input type=text id="dop_emailimp" name="dop_email" value="" style="width:500px;">'#13#10;
    s:=s+'<br /><input type=submit value=''�������� ������''>&nbsp;';
    s:=s+'</form>'#13#10;
  end;

  s:=s+'<h1 id=currentopsh>������� �������� <span></span> <input type=button value="��������" onClick="ec(''showoplist'', '''', ''difdict'');"></h1>';
  s:=s+'<table class=st id=currentopstable><tr><td>����� ������</td><td>��������</td><td>��������</td><td colspan=2>~% ����������</td></tr></table>';
  s:=s+'<div id=currentopsdiv>� ��������� ������ �������� �������/�������� �� �����������</div>'#13#10;

  s:=s+'<script>'#13#10;
  s:=s+'  $(''#exptype'').bind(''change'', function(event) {;'#13#10;
  s:=s+'    ec(''getdopinputforimpex'', $(this).serialize(), ''difdict'');'#13#10;
  s:=s+'  });'#13#10;

  s:=s+'  $(''#imptype'').bind(''change'', function(event) {;'#13#10;
  s:=s+'    ec(''checkimporthelp'', $(this).serialize(), ''difdict'');'#13#10;
  s:=s+'  });'#13#10;
  s:=s+'$("#getimporthelp").fancybox({'#13#10;
  s:=s+'  width                   : "75%",   '#13#10;
  s:=s+'  height 		        : "75%",   '#13#10;
  s:=s+'  autoScale        	: "false", '#13#10;
  s:=s+'  transitionIn		: "none",  '#13#10;
  s:=s+'  transitionOut		: "none",  '#13#10;
	s:=s+'  type			: "iframe", '#13#10;
  s:=s+'  onComplete		: function() {$("#fancybox-title").css("bottom", "none");$("#fancybox-title").css("top", -10); $(''.fancybox-iframe'').css(''width'', ''100%'');} '#13#10;
  s:=s+'});'#13#10;
  s:=s+'ec(''getdopinputforimpex'', $(''#exptype'').serialize(), ''difdict'');'#13#10;
  s:=s+'ec("showoplist", "", "difdict");'#13#10;
  s:=s+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
  s:=s+'</script>'#13#10;
  s:=fnWriteSimpleText(s);
  Result:=s;
end;
//-------------------------------------------------------------

// ������ ����������� ������
//-------------------------------------------------------------
function fnGetWebArmNotificationsPart1(Stream: TBoBMemoryStream): string;
var
  s, FirmName: string;
  i: integer; // loop local var
  MainHeader, TableHeader, TableBody, Code, forscript: string;
  HeaderHeight, Count: integer;
  ColumnWidth: integer;
begin
  s:='';
  forscript:='';
  MainHeader:='';
  HeaderHeight:=0;
  MainHeader:=MainHeader+'<div style=''position: absolute; left: -2000000px;''>';
  MainHeader:=MainHeader+'<div id=aenotificationdiv style='''' code=0>';
  MainHeader:=MainHeader+'������: <input type=text id=fromdate name=fromdate maxlength=8 size=8 ><img src="/images/calendar.png" style="margin: -3px 2px; cursor: pointer; width: 17px; height: 17px;" onClick="show_calendar(''fromdate'');">';
  MainHeader:=MainHeader+'&nbsp;���������: <input type=text id=todate name=todate maxlength=8 size=8 ><img src="/images/calendar.png" style="margin: -3px 2px; cursor: pointer; width: 17px; height: 17px;" onClick="show_calendar(''todate'');">';
  MainHeader:=MainHeader+'&nbsp;<input type=checkbox id=clientauto related=clientmoto checked> ����&nbsp;<input type=checkbox id=clientmoto related=clientauto checked> ����';
  MainHeader:=MainHeader+'<br/>�����: <input id=notiftext maxlength=255 style="width: 600px;">';
  MainHeader:=MainHeader+'<table><tr>';
  MainHeader:=MainHeader+'<td>��� �������:</br><select multiple id=clienttype style="height: 500px;">'#13#10;
  MainHeader:=MainHeader+fnListToOptions(Stream);
  MainHeader:=MainHeader+'</select></td>'#13#10;
  MainHeader:=MainHeader+'<td>��������� �������:</br><select multiple id=clientcategory style="height: 500px;">'#13#10;
  MainHeader:=MainHeader+fnListToOptions(Stream);
  MainHeader:=MainHeader+'</select></td>'#13#10;
  MainHeader:=MainHeader+'<td>������ �������:</br><select multiple id=clientfilial style="height: 500px;">'#13#10;
  MainHeader:=MainHeader+fnListToOptions(Stream);
  MainHeader:=MainHeader+'</select></td>'#13#10;
  ColumnWidth:=300;
  MainHeader:=MainHeader+'<td><select id=individualclientsmethod><option value=0>�������������</option><option value=1>��������</option></select><br/>'
                         +'<input type=text id=notiffirms style="width:'+IntToStr(ColumnWidth-8)+'px;">'
                         +'<div style="height: 400px; width: '+IntToStr(ColumnWidth)+'px;"><table class=st id=individualclientstbl width=100%></table></div></td>';
  MainHeader:=MainHeader+'</tr></table>';
  MainHeader:=MainHeader+'</div>';
  MainHeader:=MainHeader+'</div>';

  // ������ ��� �������������� ������������ +++
  forscript:=forscript+'  firms=[';
  Count:=Stream.ReadInt;
  for i := 0 to Count-1 do begin
    Code:=IntToStr(Stream.ReadInt);
    FirmName:=GetJSSafeString(Stream.ReadStr+'||'+Stream.ReadStr);
    forscript:=forscript+'{value:"'+Code+'", label: "'+FirmName+'"}';
    if i<(Count-1) then begin
      forscript:=forscript+',';
    end;
  end;
  forscript:=forscript+'];'#13#10;
  forscript:=forscript+'  $("#notiffirms").autocomplete({minLength: 2, source: firms '
                      +', select: function(event, ui) {$(event.target).attr(''code'', ui.item.value).attr(''firmname'', ui.item.label);addnotifyfirtotbl();}'
                      +', close: function(event, ui) {$(event.target).val($(event.target).attr(''firmname''));}'
                      +'});'#13#10;
  // ������ ��������� ������������� ����������
  forscript:=forscript+'  $(''input[related]'').bind(''change'', function(event) {'#13#10;
  forscript:=forscript+'    var related=$(''input[related="''+this.id+''"]'')[0];'#13#10;
  forscript:=forscript+'    if (!this.checked && !related.checked) related.checked=true;'#13#10;
  forscript:=forscript+'  });'#13#10;

// ############################################################################

  TableHeader:=TableHeader+'<tr>';
  TableHeader:=TableHeader+'<td>������</td>';
  TableHeader:=TableHeader+'<td>���������</td>';
  TableHeader:=TableHeader+'<td>�����</td>';
  TableHeader:=TableHeader+'<td>������.</td>';
  TableHeader:=TableHeader+'<td>���� ���.</td>';
  TableHeader:=TableHeader+'<td>����� �/�</td>';
  TableHeader:=TableHeader+'<td>�����. �/�</td>';
  TableHeader:=TableHeader+'<td>�����. �������������</td>';
  TableHeader:=TableHeader+'<td><a class="abgslide" style="position: static; background-image: url(''/images/wplus.png'');" '
                          +'href="#" title="��������" onclick="$(''#aenotificationdiv'').attr(''code'', 0).dialog({ title: ''�������� �����������''}).dialog(''open'');"></a></td>';
  TableHeader:=TableHeader+'</tr>'#13#10;

  TableBody:='';
  s:=s+fnWriteTableData(MainHeader, TableHeader, TableBody, HeaderHeight);
  s:=s+'<script>';
  s:=s+'$(document).ready(function() {'#13#10;
  Result:=s;
end;
//-------------------------------------------------------------
//-------------------------------------------------------------
function fnGetWebArmNotificationsPart2(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
var
  s: string;
  i, j: integer; // loop local var
  forscript: string;
begin
 s:='';
 j:=Stream.ReadInt;
 for i:=1 to j do begin
   s:=s+'aenotifyrow(';
   s:=s+IntToStr(Stream.ReadInt); //code
   s:=s+', "'+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+'"'; //from
   s:=s+', "'+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+'"'; //to
   s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; //text
   s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // ������
   s:=s+', "'+FormatDateTime('dd.mm.yy hh:nn', Stream.ReadDouble)+'"'; // ���� ���.
   s:=s+', '+IntToStr(Stream.ReadInt); // ����� �/�
   s:=s+', '+IntToStr(Stream.ReadInt); // ������������� �/�
   s:=s+', '+IntToStr(Stream.ReadInt); // ������������� �������������
   s:=s+');'#13#10;
 end;
 s:=s+'  zebratable($("#tablecontent")[0]);'#13#10;
 s:=s+'  set_sizes();'#13#10;
 s:=s+'  $("#aenotificationdiv").dialog({autoOpen: false, title:"�������������� �����������" ,width: $("#aenotificationdiv table").width(), close: clearnotifydlg, buttons: {"���������": savenotification}});'#13#10;
 s:=s+'});'#13#10;
 s:=s+forscript;
 s:=s+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
 s:=s+'</script>';
 Result:=s;
end;
//-------------------------------------------------------------

//��������� ������� ������
function fnGetWebArmSysOptions(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
var
  s: string;
  i, j, ConstType: integer; // loop local var
  MainHeader, TableHeader, TableBody, Code,Grouping,Name,FIO,GetAdapted: string;
  HeaderHeight: integer;
  CanEdited, CanManaged: boolean;
  LastTime:Double;

begin
  s:='';
  CanManaged:=Stream.ReadBool;
  MainHeader:='';
  HeaderHeight:=0;

// ############################################################################
  (*TableHeader:=TableHeader+'<tr>';
  TableHeader:=TableHeader+'<td>���</td>';
  TableHeader:=TableHeader+'<td>������</td>';
  TableHeader:=TableHeader+'<td>������������</td>';
  TableHeader:=TableHeader+'<td>��������</td>';
  TableHeader:=TableHeader+'<td>&nbsp;</td>';
  TableHeader:=TableHeader+'<td>������������</td>';
  TableHeader:=TableHeader+'<td>���� ���.</td>';
  TableHeader:=TableHeader+'</tr>'#13#10;
  TableBody:='';
  *)
 j:=Stream.ReadInt;
 prOnReadyScriptAdd(' TStream.arlen='+IntToStr(j)+'; '#13#10);
 prOnReadyScriptAdd(' TStream.artable= new Array(); '#13#10);
 for i:=0 to j-1 do begin
  Code:=IntToStr(Stream.ReadInt);
  Grouping:=Stream.ReadStr;
  Name:=Stream.ReadStr;
  ConstType:=Stream.ReadInt;
  CAnEdited:=Stream.ReadBool;
  GetAdapted:=Stream.ReadStr;
  FIO:=Stream.ReadStr;
  LastTime:=Stream.ReadDouble;
  prOnReadyScriptAdd(' TStream.artable['+IntToStr(i)+']=new Array('+Code+','''
  +GetHTMLSafeString(Grouping)+''','''+GetHTMLSafeString(Name) );

  prOnReadyScriptAdd(''','''+GetHTMLSafeString(GetAdapted)+''','+IntToStr(ConstType)+','''
  +BoolToStr(CAnEdited)+''','''+GetHTMLSafeString(FIO)+''','''
  +FormatDateTime(cDateTimeFormatY4N, LastTime)+''');' );
 end;
 prOnReadyScriptAdd(' getWABodySysOptions(TStream,'+BoolToStr(CanManaged)+','+BoolToStr(CAnEdited)+'); '#13#10);


 (* for i:=0 to j do begin
    Code:=IntToStr(Stream.ReadInt);
    TableBody:=TableBody+'<tr id=so_ln'+Code+' class="lblchoice'+fnIfStr((i mod 2)=0, ' altrow', '')+'">'#13#10;
    TableBody:=TableBody+'  <td>'+Code+'</td>'#13#10;
    TableBody:=TableBody+'  <td>'+GetHTMLSafeString(Stream.ReadStr)+'</td>'#13#10;
    TableBody:=TableBody+'  <td style="text-align: left;">'+GetHTMLSafeString(Stream.ReadStr)+'</td>'#13#10;
    ConstType:=Stream.ReadInt;
    CAnEdited:=Stream.ReadBool;
    TableBody:=TableBody+'  <td id=so_td'+Code+' style="text-align: left; white-space: normal;">'+GetHTMLSafeString(Stream.ReadStr)+'</td>'#13#10;
    TableBody:=TableBody+'  <td><div style="width: 35px; height: 19px; position: relative;">';
    if (CanEdited) then begin
      TableBody:=TableBody+'<a class="abgslide" style="background-image: url(/images/wedit.png); left: 0px;" '
                          +'href="#" title="�������� ��������"';
      case StrToInt(Code) of
        pcEmplID_list_Rep30, pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto, pcTestingSending1, pcTestingSending2, pcTestingSending3,
        pcEmpl_list_UnBlock, pcEmpl_list_TmpBlock, pcEmpl_list_FinalBlock, pcVINmailFilial_list, pcVINmailFirmClass_list, pcVINmailEmpl_list, pcVINmailFirmTypes_list,
        pcPriceLoadFirmClasses
        :begin
           TableBody:=TableBody+' onclick="ec(''editsysoption'', ''id='+Code+''', ''difdict'');">'
        end;
      else
        TableBody:=TableBody+' onclick="editsysoption('''+Code+''', '''+IntToStr(ConstType)+''');">'
       end;
      TableBody:=TableBody+'</a>';
    end;
    if (CanManaged) then begin
      TableBody:=TableBody+'<a class="abgslide" style="background-image: url(/images/user1.png);  width: 19px; height: 19px; right: 0px;" '
                          +'href="#" title="��������� ����������" onclick="ec(''showconstroles'', ''id='+Code+''', ''difdict'');"></a>';
    end;

    TableBody:=TableBody+'</div></td>'#13#10;
    TableBody:=TableBody+'  <td style="text-align: left;">'+GetHTMLSafeString(Stream.ReadStr)+'</td>'#13#10; // ������������
    TableBody:=TableBody+'  <td style="text-align: left;">'+FormatDateTime(cDateTimeFormatY4N, Stream.ReadDouble)+'</td>'#13#10;

    TableBody:=TableBody+'</tr>'#13#10;
  end; *)


  //s:=s+fnWriteTableData(MainHeader, TableHeader, TableBody, HeaderHeight);
  Result:=Result+fnWriteTableData(MainHeader, '', '', HeaderHeight);
  Result:=Result+'<script>';
  Result:=Result+'$(document).ready(function() {'#13#10+OnReadyScript+''#13#10;
  Result:=Result+'});'#13#10;
  Result:=Result+'set_sizes();';
  Result:=Result+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
  Result:=Result+'</script>';

end;
//--------------------------------------------------------------------
//������������ ������
function fnGetWebArmUsers(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
var
  s, s1, s2, Error: string;
  i, Count, Count1: integer;
  MainHeader, TableHeader, TableBody: string;
begin
  MainHeader:='';
  TableHeader:='';
  TableBody:='';
  s:='';
  Count:=Stream.ReadInt;
  MainHeader:=MainHeader+'<script>'#13#10;
  MainHeader:=MainHeader+' var altrow=false;'#13#10;
  Count1:=Stream.ReadInt;
  MainHeader:=MainHeader+' var empl=[];'#13#10;
  for i:=0 to Count1-1 do begin
    s1:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    MainHeader:=MainHeader+'empl['+s1+']="'+s2+'";'#13#10;
  end;

  Count1:=Stream.ReadInt;
  MainHeader:=MainHeader+' var dprt=[];'#13#10;
  MainHeader:=MainHeader+' var dprtstr='''';'#13#10;
  for i:=0 to Count1 do begin
    s1:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    MainHeader:=MainHeader+'dprtstr+=''<option value='+s1+'>'+s2+'</option>'';'#13#10;
    MainHeader:=MainHeader+'dprt['+s1+']="'+s2+'";'#13#10;
  end;

  Count1:=Stream.ReadInt;
  MainHeader:=MainHeader+' var roles=[];'#13#10;
  for i:=0 to Count1-1 do begin
    s1:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    MainHeader:=MainHeader+'roles['+s1+']="'+s2+'";'#13#10;
  end;

  MainHeader:=MainHeader+'</script>'#13#10;
  TableHeader:=TableHeader+'<td>���</td>';
  TableHeader:=TableHeader+'<td>�����</td>';
  TableHeader:=TableHeader+'<td>���</td>';
  TableHeader:=TableHeader+'<td>�������������</td>';
  TableHeader:=TableHeader+'<td>����� GrossBee</td>';
  TableHeader:=TableHeader+'<td><input type=button value="�������� ������������" onclick="ec(''aewausers'', ''id=new'','+fnIfStr(flNewModeCGI,'''newbj''','''abj''')+');"></td>';

  TableBody:='<script>';
  for i:=0 to Count-1 do begin
     TableBody:=TableBody+'waul(-1, '+IntToStr(Stream.ReadInt)+', '; // ���
     TableBody:=TableBody+'"'+Stream.ReadStr+'", '; // �����
     TableBody:=TableBody+''+IntToStr(Stream.ReadInt)+', '; // ��� �������������
     TableBody:=TableBody+'"'+Stream.ReadStr+'", '; // ����� GrossBee
     TableBody:=TableBody+BoBBoolToStr(Stream.ReadBool); // ������� ���������������
     TableBody:=TableBody+');'#13#10; //
  end;
  TableBody:=TableBody+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;

  TableBody:=TableBody+'</script>';

  s:=s+fnWriteTableData(MainHeader, TableHeader, TableBody);
  Result:=s;
end; //WebModule1waiWebArmUsersAction

//������������ ������
function fnGetWebArmMPP(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
var
  s: string;
begin
  s:='';
  s:=s+'<h1>���������� ��������������</h1>'#13#10;
  if flNewModeCGI then
    //s:=s+'<form action="'+ScriptName+'/mppactions" onSubmit="if ($(''#firmtempl'').val()!=''''){return sfbaNew(this);} else{jqswMessage(''������� ������ ������''); return false;}"><input type=text size=25 id=firmtempl name=firmtempl>'
    s:=s+'<form action="'+ScriptName+'/newbj" onSubmit="return sfbaNew(this);"><input type=text size=50 id=firmtempl name=firmtempl>'

  else
    s:=s+'<form action="'+ScriptName+'/mppactions" onSubmit="return sfba(this);"><input type=text size=25 id=firmtempl name=firmtempl>';
  s:=s+'<input type=hidden name=act value=loadfirms><input type=submit value="�����"></form>'#13#10;
  s:=s+'<div id=firmsdivWrap style=''position: absolute; top: 70px; left: '+IntToStr(0)+'px; bottom: 300px; right: 10px;'''#13#10;
  s:=s+'class=divh1><h1>�����������</h1>'
      +'<div id=firmsdiv class=inborder><table id=firmstable class=st></table></div>';
  s:=s+'</div>'#13#10;
  s:=s+'<div id=personsdivWrap style=''position: absolute; height: 290px; left: '+IntToStr(0)+'px; bottom: 0px; right: 10px;'''#13#10;
  s:=s+'class=divh1><h1>����������� ����</h1>'
      +'<div id=personsdiv class=inborder><table id=personstable class=st></table></div>';
  s:=s+'</div>'#13#10;

  s:=s+'<script>'#13#10;
  s:=s+'  drawborder("firmsdivWrap");'#13#10;
  s:=s+'  drawborder("personsdivWrap");'#13#10;
  s:=s+'</script>'#13#10;

  Result:=s;
end; //WebModule1waiWebArmUsersAction

function fnGetWebArmOrders(var userInf:TEmplInfo; Stream: TBoBMemoryStream): string;
var
  s: string;
  MainHeader, TableHeader, TableBody: string;

begin
  MainHeader:='';
  TableHeader:='';
  TableBody:='';
  s:='';
  MainHeader:=MainHeader+'<form onsubmit=''var inp=$("#ordernuminp"); inp.val(mtrim(inp.val())); if (inp.val().length<5) {jqswMessage("�� �� ����� ����� ������");} else {sfbaNew(this)} return false;''>'
                          +'<input type=hidden name=act value="loadorder">'
                          +'������� ����� ������: <input type=text name=ordernuminp id=ordernuminp><input type=submit value="������"></form>';
  MainHeader:=MainHeader+' <span id=orderdata4 style="font-size: 14px;"></span><br>';
  MainHeader:=MainHeader+' <span id=orderdata1 style="font-size: 14px;"></span><br>';
  MainHeader:=MainHeader+' <span id=orderdata2 style="font-size: 14px;"></span><br>';
  MainHeader:=MainHeader+' <span id=orderdata3 style="font-size: 14px;"></span><br>';
  MainHeader:=MainHeader+' <span id=orderdata6 style="font-size: 14px;"></span><br>';
  MainHeader:=MainHeader+' <span id=orderdata5 style="font-size: 14px;"></span><br>';


  TableHeader:=TableHeader+'<td>������������</td>';
  TableHeader:=TableHeader+'<td>���-�o</td>';
  TableHeader:=TableHeader+'<td>��.���.</td>';
  TableHeader:=TableHeader+'<td>����</td>';
  TableHeader:=TableHeader+'<td>�����</td>';

  s:=fnWriteTableData(MainHeader, TableHeader, TableBody);
  Result:=s;
end;

function fnGetWebArmMPPRegOrdPage(var userInf:TEmplInfo;Stream: TBoBMemoryStream): string;
var
  s: string;
  MainHeader, TableHeader, TableBody: string;
begin
  MainHeader:='';
  TableHeader:='';
  TableBody:='';
  MainHeader:=MainHeader+'<h1 style="margin-top:0;">������ �� �����������</h1>';

  MainHeader:=MainHeader+'<form action="'+ScriptName+'/newbj" onSubmit="return sfbaNew(this);"><input type=hidden name=act value=getmppregords>';
  MainHeader:=MainHeader+'<div id=filterdivWrap style=''position: relative; top: -5px; left: 0px; width: 550px; height: 110px;'''#13#10;
  MainHeader:=MainHeader+'class=divh1><h1>������</h1>'
            +'<div id=filterdiv class=inborder></div>';

  MainHeader:=MainHeader+'<table style=''position: relative; top: 34px; left: 12px;''><tr>'#13#10;
  MainHeader:=MainHeader+'<td>'#13#10;
  MainHeader:=MainHeader+'������ ������ <br />�&nbsp;<input type=text id=fromdate name=fromdate maxlength=8 size=8 value=01.'+FormatDateTime('mm.yy', Date)+'><img src="/images/calendar.png" style="margin: -3px 2px; cursor: pointer; width: 17px; height: 17px;" onClick="show_calendar(''fromdate'');">';
  MainHeader:=MainHeader+'��&nbsp;<input type=text id=todate name=todate maxlength=8 size=8 value='+FormatDateTime('dd.mm.yy', Date)+'><img src="/images/calendar.png" style="margin: -3px 2px; cursor: pointer; width: 17px; height: 17px;" onClick="show_calendar(''todate'');"><br />';
  MainHeader:=MainHeader+'������:&nbsp;<select name=dprt id=dprt '+fnIfStr((fnInIntArray(rolSaleDirector, userInf.Roles)>-1) or (fnInIntArray(rolUiK, userInf.Roles)>-1), '', 'disabled')+'></select>'#13#10;
  MainHeader:=MainHeader+'</td>'#13#10;
  MainHeader:=MainHeader+'<td style=''padding: 5px;''>'#13#10;
  MainHeader:=MainHeader+'<input type=checkbox name=new>��������������<br />'#13#10;
  MainHeader:=MainHeader+'<input type=checkbox name=processed>��������<br />'#13#10;
  MainHeader:=MainHeader+'<input type=checkbox name=annulated>�����������<br />'#13#10;
  MainHeader:=MainHeader+''#13#10;
  MainHeader:=MainHeader+'</td>'#13#10;
  MainHeader:=MainHeader+'<td>'#13#10;
  MainHeader:=MainHeader+''#13#10;
  MainHeader:=MainHeader+'��������:&nbsp;<br />'#13#10;
  MainHeader:=MainHeader+'<input type=text name=nametempl><br />'#13#10;
  MainHeader:=MainHeader+'<input type=submit value=''�������� ������''>';
  MainHeader:=MainHeader+''#13#10;
  MainHeader:=MainHeader+'</td>'#13#10;
  MainHeader:=MainHeader+'</tr></table>'#13#10;

  MainHeader:=MainHeader+'</div>'#13#10;
  MainHeader:=MainHeader+'</form>';

  TableHeader:=TableHeader+'<td>���� ������</td>';
  TableHeader:=TableHeader+'<td><a title="������ ������">��.</a></td>';
  TableHeader:=TableHeader+'<td><a title="��������">�����</a></td>';
  TableHeader:=TableHeader+'<td>������</a></td>';
  TableHeader:=TableHeader+'<td>������������</td>';
  TableHeader:=TableHeader+'<td>�������</td>';
//        TableHeader:=TableHeader+'<td>���</td>';
//        TableHeader:=TableHeader+'<td>���������</td>';
  TableHeader:=TableHeader+'<td><a title="�������� �� �������� �����">��</a></td>';
  TableHeader:=TableHeader+'<td>�����</td>';
//        TableHeader:=TableHeader+'<td>�������</td>';

   s:=s+fnWriteTableData(MainHeader, TableHeader, TableBody);

   prOnReadyScriptAdd('$(document).ready(function(){'#13#10);
   prOnReadyScriptAdd('  $(''#divtabl1'').dialog({'#13#10);
   prOnReadyScriptAdd('    autoOpen: false,'#13#10);
   prOnReadyScriptAdd('    show: ''fade'','#13#10);
   prOnReadyScriptAdd('    draggable: true,'#13#10);
   prOnReadyScriptAdd('    resize: false,'#13#10);
   prOnReadyScriptAdd('    hide: ''fade'','#13#10);
   prOnReadyScriptAdd('    width:''auto'','#13#10);
   prOnReadyScriptAdd('    buttons: {'#13#10);
   prOnReadyScriptAdd('      "���������" : function() {'#13#10);
   prOnReadyScriptAdd('        $(''#divtabl1 form'')[0].onsubmit();'#13#10);
   prOnReadyScriptAdd('      },'#13#10);
   prOnReadyScriptAdd('      "������� ����" : function() {'#13#10);
   prOnReadyScriptAdd('        $(this).dialog("close");'#13#10);
   prOnReadyScriptAdd('      }'#13#10);
   prOnReadyScriptAdd('    }'#13#10);
   prOnReadyScriptAdd('  });'#13#10);
   prOnReadyScriptAdd(''#13#10);
   prOnReadyScriptAdd('});'#13#10);


   s:=s+'<script>'#13#10;
   s:=s+'  drawborder("filterdivWrap");'#13#10;
   s:=s+'  $(document).ready(function(){'#13#10;
   s:=s+'    ec("getdprtlist", "dest=dprt", "newbj");'#13#10;
   s:=s+'    $(".ahint").easyTooltip();'#13#10;
   s:=s+'  });'#13#10;
   s:=s+'</script>'#13#10;

  Result:=s;
end;

function fnGetWebArmMPPRegZonesPage(UserID:String;Stream: TBoBMemoryStream;ThreadData: TThreadData): string;
var
  s, s1, Error: string;
  i, k, Count1: integer;
  MainHeader, TableHeader, TableBody: string;
  a: Tas;
begin
  MainHeader:='';
  TableHeader:='';
  TableBody:='';
  s:='';
  Count1:=Stream.ReadInt;
  SetLength(a, 0);
  TableHeader:=TableHeader+'<script>var dprtstr='''';'#13#10;
  for i:=0 to Count1 do begin
    k:=Stream.ReadInt;
    s1:=IntToStr(k);
    if Length(a)<(k-1) then SetLength(a, k+10);
      a[k]:=GetJSSafeString(Stream.ReadStr);
      TableHeader:=TableHeader+'dprtstr+=''<option id=dprtopt'+s1+' value='+s1+'>'+a[k]+'</option>'';'#13#10;
    end;
    TableHeader:=TableHeader+'</script>'#13#10;

    TableHeader:=TableHeader+'<style type="text/css">'#13#10;
    TableHeader:=TableHeader+'#tablecontent td {text-align: left;}'#13#10;
    TableHeader:=TableHeader+'</style>'#13#10;

    Stream.Clear;
    Stream.WriteInt(StrToInt(UserID));
    prWebArmGetRegionalZones(Stream,ThreadData);
    if Stream.ReadInt=aeSuccess then begin
      MainHeader:=MainHeader+'<h1 style="margin:0;">������ � ������ ������������'
      +'<a class="abgslide" style="background-image: url(''/images/wplus.png''); position: static; float:left; display: block;" onclick="aeregzone('''');" href="#" title="�������� ���� ������������"></a></h1>';

      TableHeader:=TableHeader+'<td>���� ������������';
      TableHeader:=TableHeader+'</td>';
      TableHeader:=TableHeader+'<td title="E-mail, �� ������� ������ ������� ������ � �����������">E-mail</td>';
      TableHeader:=TableHeader+'<td>������</td>';

      Count1:=Stream.ReadInt;
      for i:=0 to Count1-1 do begin
        k:=Stream.ReadInt;
        s1:=IntToStr(k);
        TableBody:=TableBody+'<tr id="regzone'+s1+'"><td><div style="position: relative; width: 100%;"><span>'+GetHTMLSafeString(Stream.ReadStr)+'</span>'
                 +'<a class="abgslide" style="background-image: url('+DescrImageUrl+'/images/wedit.png); right: 16px; top: 0px;" '
                                     +'onclick="aeregzone('+s1+');" href="#" title="������������� ������� �������"></a>'
                 +'<a class="abgslide" style="background-image: url('+DescrImageUrl+'/images/wdell.png); right: 0px; top: 0px;" '
                 +'onclick="ecq(''delregzone'', ''id='+s1+''', ''newbj'', ''�� ������������� ������ ������� ���� �������?'');" href="#" title="������� ���� �������"></a>'

                 +'</td><td>'+GetHTMLSafeString(Stream.ReadStr)+'</div></td><td>';
        k:=Stream.ReadInt;
        TableBody:=TableBody+GetHTMLSafeString(a[k])+'</td></tr><span style="display: none;" id=hspan'+s1+'>'+IntToStr(k)+'</span>';
      end;

      s:=s+fnWriteTableData(MainHeader, TableHeader, TableBody);

      s:=s+'<script>'#13#10;
      s:=s+'zebratable("#tablecontent");'#13#10;
      s:=s+'</script>'#13#10;

    end else begin
       Error:=Stream.ReadStr;
       s:=s+fnWriteSimpleText('������ ����������: '+GetHTMLSafeString(Error));
    end;

  Result:=s;
end; // prMPPRegZonesPage



function fnGetWebArmDirModelPage(PageType: byte; PageName:String; Stream: TBoBMemoryStream): string; // �������� ����� ����������/����
var
  s: string;
   DivWidth, DivTop: integer;
begin
  DivWidth:=350;
  DivTop:=40;
  s:='';
  case PageType of
    constIsAuto: PageName:=PageName+'Auto';
    constIsMoto: PageName:=PageName+'Moto';
  end;
  try
    s:=s+'<script>;'#13#10;
    s:=s+'  flNewModeCGI=true;'#13#10;
    s:=s+'</script>;'#13#10;
    s:=s+'<h1>������ co ������������ �������</h1>'#13#10;
    s:=s+'<div id=manufdivWrap style=''position: absolute; top: '+IntToStr(DivTop)+'px; left: '+IntToStr(0)+'px; bottom: 10px; width: '+IntToStr(DivWidth)+'px;'''#13#10;
    s:=s+'class=divh1><h1>�������������</h1>'
        +'<a class="abgslide" style="background-image: url(''/images/wplus.png''); right: 13px; top: 15px; display: block;" onclick="aemanufacturerNew(0, '''', false, '+IntToStr(PageType)+');" href="#" title="�������� �������������"></a>'
        +'<div id=manufdiv class=inborder><table id=manuftable class=st></table></div>';
    s:=s+'</div>'#13#10;

    s:=s+'<div id=modellinedivWrap style=''position: absolute; top: '+IntToStr(DivTop)+'px; left: '+IntToStr(DivWidth+10)+'px; bottom: 10px; width: '+IntToStr(DivWidth)+'px;'''#13#10;
    s:=s+'class=divh1><h1>��������� ����</h1>';
    s:=s+'<a class=abgslide id=addmodelline title=''�������� ��������� ���'' href=''#'' onClick=''aemodellineNew(0, this.name, '+IntToStr(PageType)+', "", false);'' ';
    s:=s+'style=''background-image: url(/images/wplus.png); right: 13px; top: 15px; display: none;''></a>';
    s:=s+'<div id=modellinediv class=inborder><table id=modellinetable class=st></table></div>';




    s:=s+'</div>'#13#10;
    s:=s+'<div id=modeldivWrap style=''position: absolute; top: '+IntToStr(DivTop)+'px; left: '+IntToStr(DivWidth+10+DivWidth+10)+'px; bottom: 10px; width: '+IntToStr(DivWidth)+'px;'''#13#10;
    s:=s+'class=divh1><h1>������</h1>';
    s:=s+'<div id=modeldiv class=inborder><table id=modeltable class=st></table></div>';
    s:=s+'<a class=abgslide id=addmodel title=''�������� ������'' href=''#'' onclick=''d'+fnIfStr(PageType=constIsAuto, 'a', 'm')+'mw("");'' ';
    s:=s+'style=''background-image: url(/images/wplus.png); right: 13px; top: 15px; display: none;''></a>';
    s:=s+'</div>'#13#10;

    s:=s+'<script>;'#13#10;
    s:=s+'  drawborder("manufdivWrap");'#13#10;
    s:=s+'  drawborder("modellinedivWrap");'#13#10;
    s:=s+'  drawborder("modeldivWrap");'#13#10;
    s:=s+'  $(document).ready(function(){'#13#10;
    s:=s+'    ec("loadmanuf", "sys='+IntToStr(PageType)+'", "newbj");'#13#10;
    s:=s+'  });'#13#10;
    s:=s+'</script>;'#13#10;
  finally
    Result:=s;
  end;
end;  // prDirModelPage


function fnGetWebArmTNAManagePage(UserID:string;PageType: byte;Stream: TBoBMemoryStream; ThreadData: TThreadData) :String ;
var
  s: string;
  i, j: integer; // loop local var
  TreeDivWidth, TreeDivTop: integer;
begin
  TreeDivWidth:=600;
  TreeDivTop:=35;
  s:='';
  s:=s+'<h1>������ �����</h1>';

  s:=s+'<form onSubmit="search_node2(''tv'', ''treediv'', ''nodesearch''); return false;" ><div style="width: 300px; position: relative; margin-left: 20px;">'+
       '<input type=text id=nodesearch style="width: 280px;">'+
       '<a class=abANew href=# onclick="search_node2(''tv'', ''treediv'', ''nodesearch'');" style="background-image: url(/images/search_16.png); display: block; right: 0px; padding: 0;"></a></div></form>';  //

  s:=s+'<div id=treediv class=treeview style=''overflow: auto; width: '+IntToStr(TreeDivWidth)+'px; position: absolute; top: '+IntToStr(TreeDivTop+32)+'px; bottom: 10px; left: 0px;''>'#13#10;


  s:=s+'<ul id=tv_ul_0 style=''position: relative;''></ul></div>'#13#10;

  s:=s+'<div id=treenodeedit style=''position: absolute; top: '+IntToStr(TreeDivTop)+'px; left: '+IntToStr(TreeDivWidth+10)+'px;''>'#13#10;
  s:=s+'<table>'#13#10;
  s:=s+'  <tr><td style="width: 160px;">��������� ����:</td>'#13#10;
  s:=s+'  <td id=curnodetd style="text-align: left;">���</td></tr>'#13#10;
  s:=s+'  <tr><td colspan=2>����������� ���� (��� �������):</td></tr>'#13#10;
  s:=s+'  <tr><td colspan=2><input type=text id=outername maxlength=100></td></tr>'#13#10;
  s:=s+'  <tr><td colspan=2>����������� ���� (��� �������):</td></tr>'#13#10;
  s:=s+'  <tr><td colspan=2><input type=text id=innername maxlength=100></td></tr>'#13#10;
  if (PageType<>cbrMotul) then begin
    s:=s+'  <tr><td>����������� �������� ����:</td>'#13#10;
    s:=s+'  <td style="text-align: left;"><span id=mainnodename></span><input type=hidden name=mainnodecode id=mainnodecode ></td></tr>'#13#10;
  end;
  s:=s+'  <tr><td>���������:</td>'#13#10;
  s:=s+'  <td style="text-align: left;"><input type=checkbox id=nodevisibility></td></tr>'#13#10;
  s:=s+'</table>'#13#10;
  s:=s+'<input type=button value="�������� ����" ';
  s:=s+'  onclick="ec(''addtreenode'', ''id=''+curnode.parentNode.parentNode.parentNode.parentNode.id.substr(6)+''&newname=''+$(''#outername'').val()+''&newsysname=''+$(''#innername'').val()+''&sys='+IntToStr(PageType)+'&vis=''+$(''#nodevisibility'')[0].checked+''&mainnode=''+$(''#mainnodecode'').val(), ''newbj'');"';
  s:=s+'>';
  s:=s+' <input type=button value="�������� �������"';
  s:=s+'  onclick="ec(''addtreesubnode'', ''id=''+curnode.id.substr(6)+''&newname=''+$(''#outername'').val()+''&newsysname=''+$(''#innername'').val()+''&sys='+IntToStr(PageType)+'&vis=''+$(''#nodevisibility'')[0].checked+''&mainnode=''+$(''#mainnodecode'').val(), ''newbj'');"';
  s:=s+'>';
  s:=s+'<br /><br /><input type=button value="������ ���������" onclick="if (!curnode) {alert(''�� ������ ������������� ����'')} else {ec(''edittreenode'', ''id=''+curnode.id.substr(6)+''&newname=''+$(''#outername'').val()+''&newsysname=''+$(''#innername'').val()+''&sys='+IntToStr(PageType)+'&vis=''+$(''#nodevisibility'')[0].checked+''&mainnode=''+$(''#mainnodecode'').val(), ''newbj'')}">';
  s:=s+'<br /><br /><input type=button value="������� ����" onclick="if (confirm(''�� ������������� ������ ������� ����?'')){if (!curnode) {alert(''�� ������ ���� ��� ��������'')} else {ec(''deltreenode'', ''id=''+curnode.id.substr(6)+''&sys='+IntToStr(PageType)+''', ''newbj'');}}">';
  if (PageType<>cbrMotul) then
    s:=s+' <input type=button value="����������� �� �������" onclick="if (!curnode) {alert(''�� ������ ����'')} else {ec(''detachfrommainnode'', ''id=''+curnode.id.substr(6)+''&sys='+IntToStr(PageType)+''', ''newbj'');}">';
  s:=s+#13#10;
  s:=s+'</div>'#13#10;
  Stream.Clear;
  Stream.WriteInt(isWe);
  Stream.WriteInt(StrToInt(UserID));
  Stream.WriteByte(PageType);
  prTNAGet(Stream,ThreadData);
  if Stream.ReadInt=aeSuccess then begin
    s:=s+'<script>'#13#10'var curnode=null;'#13#10;
    j:=Stream.ReadInt-1;
    for i:=0  to j do begin
      s:=s+'addbranchNew('+IntToStr(Stream.ReadInt)+', '+IntToStr(Stream.ReadInt)+', "'+GetJSSafeStringArg(Stream.ReadStr)+'", "'+GetJSSafeStringArg(Stream.ReadStr)+'", '+fnIfStr(Stream.ReadBool, 'true', 'false')+', '+IntToSTr(Stream.ReadInt)+', '+fnIfStr(Stream.ReadBool, 'true', 'false')+');'#13#10;
    end;
// �������� ������� ������������/�������������� �����
    s:=s+fnBindFuncToNewNodes('');
    s:=s+'</script>'#13#10;
  end
  else begin
    s:='jqswMessageError('''+GetHTMLSafeString(Stream.ReadStr)+'<br>'');';
  end;
  Result:=s;
end;

function fnGetWebArmCOUPage(Stream: TBoBMemoryStream):string;
var
  s: string;
  i, Count: integer;
begin
  try
    s:='';
    s:=s+'<div style="display: none;">';
    s:=s+'<input type=hidden id=inp_modelid>';
    s:=s+'<input type=hidden id=inp_nodeid>';
    s:=s+'<input type=hidden id=inp_wareid>';
    s:=s+'<div id="addcoudiv" style="padding: 10px;">';
    s:=s+'������������ ��������:<br>';
    s:=s+'<select id=critname style="width: 400px;" onchange=''ec("getcriteriavalues", "criteria="+this.value+"&value="+$("#critvalue").val(), "newbj")''>';
    Count:=Stream.ReadInt-1;
    s:=s+'<option> ';
    for i:=0 to Count do begin
      s:=s+'<option>'+Stream.ReadStr;
    end;
    s:=s+'</select><br>';
    s:=s+'�������� ��������:<br>';
    s:=s+'<input id=critvalue style="width: 380px;">';
  //        s:=s+'<a class=abANew href=# id=critsearchbtn onclick="$(''#critvalue'').autocomplete(''search'' , $(''#critvalue'').val());" style="background-image: url(/images/search_16.png); top: 73px; right: 5px; display: none;"></a><br>';
    s:=s+'<a class=abANew href=# id=critsearchbtn  style="background-image: url(/images/search_16.png); top: 73px; right: 5px; display: none;"></a><br>';
    s:=s+'<center>';
  //        s:=s+'<input type=button id=btnSaveCriteria value="��������" onclick="add_criteria();">&nbsp;<input type=button value="�������" onclick="$.fancybox().close();">';
    s:=s+'<input type=button id=btnSaveCriteria value="��������" onclick="add_criteria();">&nbsp;<input type=button value="�������" onclick="$(''#addcoudiv'').dialog(''close'');">';
    s:=s+'</center>';
    s:=s+'</div>'; // addcoudiv
    s:=s+'</div>'; // ������� div

    s:=s+'<h1>�� ������ ����� ��� �������������� ������� ������������</h1>';
    s:=s+'<input type=button id=btn_addportion value="�������� ���� �������" onclick="ec(''showportion'', ''portion=-1'', ''newbj'');" style="display: none;">';
    s:=s+'<div id=portions></div>'#13#10; //
    s:=s+'<style type="text/css">'#13#10;
    s:=s+'  .ui-autocomplete {'#13#10;
    s:=s+'  max-height: 200px;'#13#10;
    s:=s+'  overflow-y: auto;'#13#10;
    s:=s+'  overflow-x: hidden;'#13#10;
    s:=s+'  padding-right: 20px;'#13#10;
    s:=s+'}'#13#10;
    s:=s+'</style>'#13#10;
    s:=s+'<script>'#13#10;
    s:=s+'$(document).ready(function() {'#13#10;
    s:=s+' $("#addcoudiv").dialog({autoOpen:false, width:"auto"});'#13#10;
    s:=s+'});'#13#10;
    s:=s+'</script>'#13#10;
  finally
     Result:=s;
  end;
end;   // ConditionsOfUseAction

function fnGetWebArmBrandsCross(var userInf:TEmplInfo;Stream: TBoBMemoryStream):string;
var
  s, s1, s2, Error: string;
  i, j, Count: integer;
  MainHeader, TableHeader, TableBody: string;
//  GBBrands, TDBrands: Tas;
begin
  MainHeader:='';
  TableHeader:='';
  TableBody:='';
  s:='';
  MainHeader:=MainHeader+'<script>';

 // ������� �������� ������� Grossbee
  Stream.Clear;
  Stream.WriteInt(StrToInt(userInf.UserID));
  if fnSendReceiveData(csGetBrandsGB, Stream, csWebArm) then begin
    if Stream.ReadInt=aeSuccess then begin
      Count:=Stream.ReadInt;
      MainHeader:=MainHeader+' var GBBrands=[];'#13#10;
      MainHeader:=MainHeader+' var GBBrandsstr='''';'#13#10;
      for i:=0 to Count-1 do begin
        j:=Stream.ReadInt;
        s1:=IntToStr(j);
        s2:=GetJSSafeString(Stream.ReadStr);
        MainHeader:=MainHeader+'GBBrands['+s1+']="'+s2+'";'#13#10;
        MainHeader:=MainHeader+'GBBrandsstr+=''<option value='+s1+'>'+s2+'</option>'';'#13#10;
      end;
    end else begin
           s:='jqswMessageError("1 - '+GetJSSafeString(StripHTMLTags(Stream.ReadStr))+'");';
         end;
       end else begin
         s:='jqswMessageError("1-1 - '+GetJSSafeString(StripHTMLTags(Stream.ReadStr))+'");';
       end;

        // ������� �������� ������� TecDoc
    Stream.Clear;
    Stream.WriteInt(StrToInt(userInf.UserID));
    if fnSendReceiveData(csGetBrandsTD, Stream, csWebArm) then begin
      if Stream.ReadInt=aeSuccess then begin
        Count:=Stream.ReadInt;
        MainHeader:=MainHeader+' var TDBrands=[];'#13#10;
        MainHeader:=MainHeader+' var TDBrandsstr='''';'#13#10;
//         SetLength(GBBrands, Count);
        for i:=0 to Count-1 do begin
          j:=Stream.ReadInt;
          s1:=IntToStr(j);
          s2:=GetJSSafeString(Stream.ReadStr);
//             GBBrands[j]:=
          MainHeader:=MainHeader+'TDBrands['+s1+']="'+s2+'";'#13#10;
          MainHeader:=MainHeader+'TDBrandsstr+=''<option value='+s1+'>'+s2+'</option>'';'#13#10;
        end;
      end else begin
           s:='jqswMessageError("2 - '+GetJSSafeString(StripHTMLTags(Stream.ReadStr))+'");';
         end;
    end else begin
         s:='jqswMessageError("2-2 - '+GetJSSafeString(StripHTMLTags(Stream.ReadStr))+'");';
       end;
       MainHeader:=MainHeader+'</script>';


// ������ ���������� ������������

    TableHeader:=TableHeader+'<td>����� GrossBee</td>';
    TableHeader:=TableHeader+'<td>����� TecDoc</td>';
    TableHeader:=TableHeader+'<td><input type=button value="�������� coo���������" onclick="getbrandslink();"></td>';
    TableBody:='<script>';
    TableBody:=TableBody+' var altrow=false;'#13#10;
    Stream.Clear;
    Stream.WriteInt(StrToInt(userInf.UserID));
    if fnSendReceiveData(csGetLinkBrandsGBTD, Stream, csWebArm) then begin
      if Stream.ReadInt=aeSuccess then begin
            // ������
         Count:=Stream.ReadInt;
         for i:=0 to Count-1 do begin
           TableBody:=TableBody+'ablr(-1, '; //
           TableBody:=TableBody+''+IntToStr(Stream.ReadInt)+', '; // ��� GrossBee
           TableBody:=TableBody+''+IntToStr(Stream.ReadInt)+' '; // ��� TecDoc
           TableBody:=TableBody+');'#13#10; //
         end;
      end else begin
            s:='jqswMessageError("3 - '+GetJSSafeString(StripHTMLTags(Stream.ReadStr))+'");';
          end;
    end else begin
         s:='jqswMessageError("3-3 - '+GetJSSafeString(StripHTMLTags(Stream.ReadStr))+'");';
        end;

    s:=s+'setCookie_("sid", "'+userInf.SessionID+'", getExpDate_(0,0,'+userInf.SessionTimeMinStr+'),"/",0,0);'#13#10;
    TableBody:=TableBody+s+'</script>';

    s:=fnWriteTableData(MainHeader, TableHeader, TableBody);
    Result:=s;
end;

function fnGetWebArmLogotypes(Stream: TBoBMemoryStream):string;
var
  s: string;
  i, Count: integer;
  MainHeader, TableHeader, TableBody: string;
  BrandID: integer;
  BrandName: string;
  BrandNameWWW: string;
  BrandWarePrefix: string;
  BrandadressWWW: string;
  BrandDownLoadExclude, BrandDownLoadPict: boolean;

begin
  MainHeader:='';
  TableHeader:='';
  TableBody:='';
  s:='';
  Count:=Stream.ReadInt;
  TableHeader:=TableHeader+'<td>�����</td>';
  TableHeader:=TableHeader+'<td>����������</td>';
  TableHeader:=TableHeader+'<td>�������</td>';
  TableHeader:=TableHeader+'<td>������</td>';
  TableHeader:=TableHeader+'<td>�� ���������� � ������</td>';
  if flPictNotShow then
    TableHeader:=TableHeader+'<td>�� ���������� ������� TD</td>';

  for i:=0 to Count-1 do begin
    BrandID:=Stream.ReadInt;
    BrandName:=Stream.ReadStr;
    BrandNameWWW:=Stream.ReadStr;
    BrandWarePrefix:=Stream.ReadStr;
    BrandadressWWW:=Stream.ReadStr;
    BrandDownLoadExclude:=Stream.ReadBool;
    if flPictNotShow then
      BrandDownLoadPict:=Stream.ReadBool;
    TableBody:=TableBody+'<tr id=brandtr'+IntToStr(BrandID)+' code="'+IntToStr(BrandID)+'" class="lblchoice">'#13#10;
    TableBody:=TableBody+'<td>'+BrandName+'</td>'#13#10;
    TableBody:=TableBody+'<td>'+BrandWarePrefix+'</td>'#13#10;
    TableBody:=TableBody+'<td style="text-align: center;" value="'+BrandNameWWW+'"><img style="height: 16px;" src="'+fnIfStr(BrandNameWWW='', '/images/tr.gif', 'http://www.vladislav.ua/images/logo/'+BrandNameWWW+'.png')+'"></td>'#13#10;
    TableBody:=TableBody+'<td><a target=_blank onclick="event.stopPropagation();" href="http://'+BrandadressWWW+'">'+BrandadressWWW+'</a></td>'#13#10;
    TableBody:=TableBody+'<td style="text-align: center;"  value="'+BoBBoolToStr(BrandDownLoadExclude)+'"><img src="'+DescrImageUrl+'/images/'+fnIfStr(BrandDownLoadExclude, 'checked01.png', 'tr.gif')+'"></td>'#13#10;
    if flPictNotShow then
      TableBody:=TableBody+'<td style="text-align: center;"  value="'+BoBBoolToStr(BrandDownLoadPict)+'"><img src="'+DescrImageUrl+'/images/'+fnIfStr(BrandDownLoadPict, 'checked01.png', 'tr.gif')+'"></td>'#13#10;
    TableBody:=TableBody+'</tr>'#13#10;
  end;
//        TableBody:=TableBody+'setCookie_("sid", "'+webarm_common.SessionID+'", getExpDate_(0,0,'+SessionTimeMinStr+'),"/",0,0);'#13#10;
  OnReadyScript:=OnReadyScript+'flPictNotShow='+BoolToStr(flPictNotShow)+';'#13#10;
  OnReadyScript:=OnReadyScript+'zebratable($("#tablecontent")[0]);'#13#10;
  OnReadyScript:=OnReadyScript+'$("#tablecontent tr").bind(''click'', function(event) {'#13#10;
  OnReadyScript:=OnReadyScript+'  openbrandeditwindowNew(this);'#13#10;
  OnReadyScript:=OnReadyScript+'});'#13#10;
  OnReadyScript:=OnReadyScript+'synqcols();'#13#10;
  s:=fnWriteTableData(MainHeader, TableHeader, TableBody);
  Result:=s;
end;

//---------------------------------------------------------------
// ������ ������ ������
function fnShowGBAccount(var userInf:TEmplInfo;Stream: TBoBMemoryStream):string;
 var
  DocNum,ContractNum,DocDate,SubHeader,ORDRCode,ORDRNum,Commentary,DeliveryText: string;
  WareTitle,WareName,Order,Acc,Ed,Price,Sum,TotalQty,BallsQty, BallsName:String;
  AccMeetText,TitleDop,addr,FirmName: string;
  i, LineQty: integer; // loop local var

begin
   Result:='';
   DocNum:=Stream.ReadStr;
   DocDate:=Stream.ReadStr;
   ContractNum:=Stream.ReadStr;
   SubHeader:=Stream.ReadStr;
   ORDRCode:=Stream.ReadStr;
   ORDRNum:=Stream.ReadStr;
   Commentary:=Stream.ReadStr;
   DeliveryText:=GetJSSafeString(Stream.ReadStr);
   if flMeetPerson then begin
      AccMeetText:=Stream.ReadStr;
   end;
   LineQty:=Stream.ReadInt;
   TitleDop:='<strong>'+fnGetGBDocName(docAccount)+'</strong> � '+DocNum+' �� '+DocDate+', <strong>��������</strong> � '+ContractNum+'';        //!!!����!!!
   Result:=Result+'<div id=thw><div id=tht></div><img id=thlt src="/images/window/corner-top-left.png"><img id=thrt src="/images/window/corner-top-right.png">'#13#10;
   Result:=Result+'</div>'#13#10; // <div id=thw>

  Result:=Result+'<div id=tcdbackground></div><div id=mfb></div><img id=mflb src="/images/window/corner-bottom-left.png"><img id=mfrb src="/images/window/corner-bottom-right.png">';
  Result:=Result+'<div id=mainheaderwrap>';
  Result:=Result+'<div id=mainheader>';
  Result:=Result+'<h1 id="acc-firmname" class=doctitle>';
  Result:=Result+'<h1 id=ordernumh1 class=doctitle>'+TitleDop;
  Result:=Result+'<br>'+SubHeader+'';
  //if (ORDRNum<>'') then begin
  //   Result:=Result+', �� <strong>������</strong> � <a href="'+ScriptName+'/order?order='+ORDRNum+'">'+ORDRCode+'</a>';
  // end;
  Result:=Result+'</h1>';
  Commentary:=StringReplace(StringReplace(Commentary, '''', '`', [rfReplaceAll]), '"', '`', [rfReplaceAll]);
  if Commentary='' then begin
    Commentary:='���'
  end;
  Result:=Result+'<div id=acccomdiv><div id=deliverydatadivshowdoc>'+DeliveryText+'</div><strong>�����������:</strong> <i>'+Commentary+'</i>'#13#10;
  if flMeetPerson then
    Result:=Result+' <span class="meet"><strong >&nbsp; &nbsp;�����������:</strong> <i>'+AccMeetText+'</i></span>'#13#10;
  Result:=Result+'</div>';
  Result:=Result+'</div></div>'; //  mainheader, mainheaderwrap
  Result:=Result+'<div id=tableheaderdiv class="showdoc"><table id="tableheader" class="st showdoc" cellspacing=0></table></div>'#13#10;
  Result:=Result+'<div id=tablecontentdiv class="showdoc">'#13#10;
  Result:=Result+'<table class="st showdoc" cellspacing=0 id="tablecontent"></table>'#13#10;
  Result:=Result+'<table class="st showdoc" cellspacing=0 id="tablecontent2" ></table>'#13#10;
  Result:=Result+'</div>'#13#10; // <div id=tablecontentdiv>
  Result:=Result+'<script>'#13#10;
  Result:= Result+'var arrTableHeaderColName=[];'#13#10;
  Result:=Result+'arrTableHeaderColName[0]=new Array("������������ ������","�����","������","��.���","����","�����"); '#13#10;
  Result:=Result+'TStream.arlen='+IntToStr(LineQty)+';  '#13#10;
  Result:=Result+' TStream.artable= new Array(); '#13#10;
  for i:=0 to LineQty-1 do begin
    WareTitle:=Stream.ReadStr;
    WareName:=Stream.ReadStr;
    Order:=Stream.ReadStr;
    Acc:=Stream.ReadStr;
    Ed:=Stream.ReadStr;
    Price:=StringReplace(Stream.ReadStr,' ','',[rfReplaceAll]);
    Sum:=StringReplace(Stream.ReadStr,' ','',[rfReplaceAll]);
    Stream.ReadStr;
    Result:= Result+' TStream.artable['+IntToStr(i)+']={'+
      'WareTitle:'''+WareTitle+''', WareName:'''+WareName+''', Order:'''+Order+''', Acc:'''+Acc+
      ''',  Ed:'''+ Ed+''', Price:'''+StringReplace(Price,',','.',[rfReplaceAll])+''', Sum: '''+StringReplace(Sum,',','.',[rfReplaceAll])+
      '''};'#13#10;
  end;
  TotalQty:=Stream.ReadStr;
  BallsQty:=Stream.ReadStr;
  BallsName:=Stream.ReadStr;
  FirmName:=Stream.ReadStr;
  FirmName:=GetJSSafeString(FirmName);
  Result:= Result+' TStream.TotalQty="'+TotalQty+'";'#13#10;
  Result:= Result+' TStream.BallsQty="'+BallsQty+'";'#13#10;
  Result:= Result+' TStream.BallsName="'+BallsName+'";'#13#10;
  Result:= Result+ 'TStream.FirmName="'+FirmName+'";'#13#10;
  Result:= Result+'fillAnyHeader();'#13#10;
  Result:= Result+'fillBodyForGBAccount();'#13#10;
  Result:= Result+'</script>'#13#10;
  OnReadyScript:='';
  OnReadyScript:=OnReadyScript+'$("#tablecontentdiv.showdoc").css("top","147px").css("width",$("#tablecontentdiv.showdoc").width()+"px"); '#13#10;
  OnReadyScript:=OnReadyScript+'synqcolsForShowDoc("#tablecontentdiv","tableheader","tablecontent",'+IntToStr(LineQty)+');'#13#10;
  Result:=Result+'<script>'#13#10;
  Result:=Result+'$(document).ready(function() {'#13#10+OnReadyScript+'});'#13#10;
  Result:=Result+'</script>'#13#10;
end;
//-------------------------------------------------------------

//---------------------------------------------------------------
// ������ ������ ������
function fnShowGBOutInvoice(var userInf:TEmplInfo;Stream: TBoBMemoryStream):string;
 var
  DocNum,ContractNum,DocDate: string;
  WareTitle,WareName,Qv,Ed,Price,Sum,TotalQty,BallsQty, BallsName:String;
  AccMeetText,TitleDop,addr,FirmName: string;
  i, LineQty: integer; // loop local var

begin
  Result:='';
  DocNum:=Stream.ReadStr;
  DocDate:=Stream.ReadStr;
  ContractNum:=Stream.ReadStr;
  BallsQty:=FormatFloat('# ##0.##',  Stream.ReadDouble);
  BallsName:=Stream.ReadStr;
  if flMeetPerson then begin
     AccMeetText:=Stream.ReadStr;
  end;
  LineQty:=Stream.ReadInt;
  TitleDop:=fnGetGBDocName(docInvoice)+' � '+DocNum+' �� '+DocDate+', �������� � '+ContractNum; //!!!��������� �!!!
  Result:=Result+'<div id=thw><div id=tht></div><img id=thlt src="/images/window/corner-top-left.png"><img id=thrt src="/images/window/corner-top-right.png">'#13#10;
  Result:=Result+'</div>'#13#10; // <div id=thw>
  Result:=Result+'<div id=tcdbackground></div><div id=mfb></div><img id=mflb src="/images/window/corner-bottom-left.png"><img id=mfrb src="/images/window/corner-bottom-right.png">';
  Result:=Result+'<div id=mainheaderwrap>';
  Result:=Result+'<div id=mainheader>';
  Result:=Result+'<h1 id="gboutinvoice-firmname" class=doctitle>';
  Result:=Result+'<h1 id=ordernumh1 class=doctitle>'+TitleDop;
  if flMeetPerson then
    Result:=Result+'<br>�����������: '+AccMeetText+'</h1><br clear=both>'
  else
    Result:=Result+'</h1><br clear=both>';
  Result:=Result+'</div></div>'; //  mainheader, mainheaderwrap
  Result:=Result+'<div id=tableheaderdiv class="showdoc"><table id="tableheader" class="st showdoc" cellspacing=0></table></div>'#13#10;
  Result:=Result+'<div id=tablecontentdiv class="showdoc">'#13#10;
  Result:=Result+'<table class="st showdoc" cellspacing=0 id="tablecontent"></table>'#13#10;
  Result:=Result+'<table class="st showdoc" cellspacing=0 id="tablecontent2" ></table>'#13#10;
  Result:=Result+'</div>'#13#10; // <div id=tablecontentdiv>
  Result:=Result+'<script>'#13#10;
  Result:= Result+'var arrTableHeaderColName=[];'#13#10;
  Result:=Result+'arrTableHeaderColName[0]=new Array("������������ ������","�-��","��.���","����","�����"); '#13#10;
  Result:=Result+'TStream.arlen='+IntToStr(LineQty)+';  '#13#10;
  Result:=Result+' TStream.artable= new Array(); '#13#10;
  for i:=0 to LineQty-1 do begin
    WareTitle:=Stream.ReadStr;
    WareName:=Stream.ReadStr;
    Qv:=Stream.ReadStr;
    Ed:=Stream.ReadStr;
    Price:=StringReplace(Stream.ReadStr,' ','',[rfReplaceAll]);
    Sum:=StringReplace(Stream.ReadStr,' ','',[rfReplaceAll]);
    Result:= Result+' TStream.artable['+IntToStr(i)+']={'+
      'WareTitle:'''+WareTitle+''', WareName:'''+WareName+''', Qv:'''+Qv+''',  Ed:'''+ Ed+
      ''', Price:'''+StringReplace(Price,',','.',[rfReplaceAll])+''', Sum: '''+StringReplace(Sum,',','.',[rfReplaceAll])+
      '''};'#13#10;
  end;
  TotalQty:=Stream.ReadStr;
  FirmName:=Stream.ReadStr;
  FirmName:=GetJSSafeString(FirmName);
  Result:= Result+' TStream.TotalQty="'+TotalQty+'";'#13#10;
  Result:= Result+' TStream.BallsQty="'+BallsQty+'";'#13#10;
  Result:= Result+' TStream.BallsName="'+BallsName+'";'#13#10;
  Result:= Result+ 'TStream.FirmName="'+FirmName+'";'#13#10;
  Result:= Result+' fillAnyHeader();'#13#10;
  Result:= Result+' fillBodyForGBOutInvoice();'#13#10;
  Result:= Result+'</script>'#13#10;
  OnReadyScript:='';
 // OnReadyScript:=OnReadyScript+'$("#tablecontentdiv.showdoc").css("top","117px").css("width",$("#tablecontentdiv.showdoc").width()+"px"); '#13#10;
  OnReadyScript:=OnReadyScript+'synqcolsForShowDoc("#tablecontentdiv","tableheader","tablecontent",'+IntToStr(LineQty)+');'#13#10;
  Result:=Result+'<script>'#13#10;
  Result:=Result+'$(document).ready(function() {'#13#10+OnReadyScript+'});'#13#10;
  Result:=Result+'</script>'#13#10;
end;
//-------------------------------------------------------------

// �������� ���������� ����� Motul
function fnShowMotulSitePage(var userInf:TEmplInfo; Stream:TBoBMemoryStream; KindOfPage:string; NeedFullPage: boolean=true):string;
 var
  Count,ActionCode,i,WareCode,fsize:integer;
  ActionHeader, WareName: string;
  ActionBeginDate,ActionEndDate: TDateTime;
  IsPlex,IsChex,IsAct:boolean;
  ActionMemoText:string;
  TMPStream: TBoBMemoryStream;
  temp:RawByteString;
begin
  Result:='';
  if (KindOfPage='3') then begin
    if (NeedFullPage)  then begin
      Result:=Result+'<div id=thw><div id=tht></div><img id=thlt src="/images/window/corner-top-left.png"><img id=thrt src="/images/window/corner-top-right.png">'#13#10;
      Result:=Result+'</div>'#13#10; // <div id=thw>
      Result:=Result+'<div id=tcdbackground></div><div id=mfb></div><img id=mflb src="/images/window/corner-bottom-left.png"><img id=mfrb src="/images/window/corner-bottom-right.png">';
      Result:=Result+'<div id=mainheaderwrap>';
      Result:=Result+'<div id=mainheader>';
      Result:=Result+'</div></div>'; //  mainheader, mainheaderwrap
      Result:=Result+'<div id=tablecontentdiv class="show-content-motul-site">'#13#10;
      Result:=Result+'  <ul>'#13#10;
      Result:=Result+'    <li><a href="#motul-action-div" onclick="ec(''motulsitetab'',''kindofpage=3'',''newbj'');" title="�����">�����</a></li>'#13#10;
      Result:=Result+'    <li><a href="#motul-wares-div" onclick="if (document.getElementById(''tablecontent-wares'').rows.length==0){ ec(''motulsitetab'',''kindofpage=4'',''newbj'');}" title="��������">��������</a></li>'#13#10;
      Result:=Result+'    <li><a href="#motul-info-div" onclick="if (document.getElementById(''tablecontent-info'').rows.length==0){ ec(''motulsitetab'',''kindofpage=5'',''newbj'');}" title="�����/���������� ����������">�����/���������� ����������</a></li>'#13#10;
      Result:=Result+'  </ul>'#13#10;
      Result:=Result+' <div id="motul-action-div"  style="margin: 10px 0 0 10px;">';
      Result:=Result+'  <table id="tableheader-action" class="st" cellspacing="0"></table>';
      Result:=Result+'  <div id="tablecontentdiv-action" class="">'#13#10;
      Result:=Result+'    <table id="tablecontent-action" class="st" cellspacing="0"></table>';
      Result:=Result+'  </div>'#13#10;
      Result:=Result+' </div>'#13#10;
      Result:=Result+' <div id="motul-wares-div"  style="margin: 10px 0 0 10px;">';
      Result:=Result+'  <table id="tableheader-wares" class="st tableheader" cellspacing="0"></table>';
      Result:=Result+'  <div id="tablecontentdiv-wares" class="tablecontentdiv">'#13#10;
      Result:=Result+'    <table id="tablecontent-wares" class="st tablecontent" cellspacing="0"></table>';
      Result:=Result+'  </div>'#13#10;
      Result:=Result+' </div>'#13#10;
      Result:=Result+' <div id="motul-info-div"  style="margin: 10px 0 0 10px;">';
      Result:=Result+'  <table id="tableheader-info" class="st tableheader" cellspacing="0"></table>';
      Result:=Result+'  <div id="tablecontentdiv-info" class="tablecontentdiv">'#13#10;
      Result:=Result+'    <table id="tablecontent-info" class="st tablecontent" cellspacing="0"></table>';
      Result:=Result+'  </div>'#13#10;
      Result:=Result+' </div>'#13#10;
      Result:=Result+'<table id="tablecontent2" class="st" style="width: 1669px;" cellspacing="0"> '#13#10;
      Result:=Result+'</div>'#13#10; // <div id=tablecontentdiv>
    end;
    Result:=Result+'<script>'#13#10;
    Result:=Result+'  $("#tablecontentdiv").tabs({selected: 0, show: function(event, ui) {}});'#13#10;
    Result:=Result+'TStream.length=0;'#13#10;
    Result:=Result+'TStream.arrMotulAction=new Array();'#13#10;
    Result:=Result+'TStream.arrMotulWares=new Array();'#13#10;
    Result:=Result+'TStream.arrMotulInfo=new Array();'#13#10;
    Count:=Stream.ReadInt;
    for i := 0 to Count-1 do begin
      ActionCode:=Stream.ReadInt;
      ActionHeader:=Stream.ReadStr;
      ActionBeginDate:=Stream.ReadDouble;
      ActionEndDate:=Stream.ReadDouble;
      if (Trunc(ActionEndDate)>=Date) then
        IsAct:=true
      else
        IsAct:=false;
      ActionMemoText:=Stream.ReadLongStr;
      ActionMemoText:=StringReplace(ActionMemoText,#13#10,'',[rfReplaceAll]);
      ActionMemoText:= StringReplace(ActionMemoText, #39, '`', [rfReplaceAll]);
      IsPlex:=Stream.ReadBool;
      IsChex:=Stream.ReadBool;
      Result:=Result+'TStream.arrMotulAction['+IntToStr(i)+']={';
      Result:=Result+'ActionCode:'+IntToStr(ActionCode)+', ActionHeader:"'+ActionHeader+'", ';
      Result:=Result+'ActionBeginDate:"'+FormatDateTime('dd.mm.yy', ActionBeginDate)+'", ActionEndDate:"'+FormatDateTime('dd.mm.yy', ActionEndDate)+'", ';
      Result:=Result+'ActionMemoText:'''+ActionMemoText+''', ';
      Result:=Result+'IsPlex:'+BoolToStr(IsPlex)+', IsChex:'+BoolToStr(IsChex)+', IsAct:'+BoolToStr(IsAct);
      Result:=Result+'};'#13#10;
    end;
    Result:=Result+'fillHeaderForMotulSiteAction(); '#13#10;
    Result:=Result+'fillBodyForMotulSiteAction(); '#13#10;
    Result:=Result+'synqcolsForMPP("#tablecontentdiv-action","tableheader-action","tablecontent-action",TStream.arrMotulAction.length);'#13#10;
    Result:=Result+'</script>'#13#10;
  end;
  if (KindOfPage='4') then begin
    Count:=Stream.ReadInt;
    Result:=Result+'TStream.arrMotulWares.length=0;'#13#10;
    for i := 0 to Count-1 do begin
      WareCode:=Stream.ReadInt;
      WareName:=Stream.ReadStr;
      fsize:=Stream.ReadInt;
      Result:=Result+'TStream.arrMotulWares['+IntToStr(i)+']={';
      if fsize=0 then begin
        Result:=Result+'ImageSize:0, '; // ������ ��������
        Result:=Result+'Image:"", '
      end
      else begin
        Result:=Result+'ImageSize:'+IntToStr(fsize)+', '; // ������ ��������
        try
          temp:='';
          SetLength(temp, fsize);
          Stream.Read(Pointer(temp)^, fsize);
          Result:=Result+'Image:"'+StringReplace(string(temp),#13#10,'',[rfReplaceAll])+'", '
        except
          Result:=Result+'ImageSize:0, '; // ������ ��������
          Result:=Result+'Image:"", '
        end;
      end;
      ActionCode:=Stream.ReadInt;
      ActionHeader:=Stream.ReadStr;
      Result:=Result+'WareCode:'+IntToStr(WareCode)+', WareName:"'+WareName+'", ';
      Result:=Result+'ActionCode:'+IntToStr(ActionCode)+', ActionHeader:"'+ActionHeader+'" ';
      Result:=Result+'};'#13#10;
    end;
    Result:=Result+'fillHeaderForMotulSiteWares(); '#13#10;
    Result:=Result+'fillBodyForMotulSiteWares(); '#13#10;
    Result:=Result+'synqcolsForMPP("#tablecontentdiv-wares","tableheader-wares","tablecontent-wares",TStream.arrMotulWares.length);'#13#10;
  end;
  if (KindOfPage='5') then begin
    Result:=Result+'TStream.arrMotulInfo.length=0;'#13#10;
    Count:=Stream.ReadInt;
    for i := 0 to Count-1 do begin
      ActionCode:=Stream.ReadInt;
      ActionHeader:=Stream.ReadStr;
      ActionMemoText:=Stream.ReadLongStr;
      ActionMemoText:=StringReplace(ActionMemoText,#13#10,'',[rfReplaceAll]);
      ActionMemoText:= StringReplace(ActionMemoText, #39, '`', [rfReplaceAll]);
      Result:=Result+'TStream.arrMotulInfo['+IntToStr(i)+']={';
      Result:=Result+'ActionCode:'+IntToStr(ActionCode)+', ActionHeader:"'+ActionHeader+'", ';
      Result:=Result+'ActionMemoText:'''+ActionMemoText+'''};'#13#10;
    end;
    Result:=Result+'fillHeaderForMotulSiteInfo(); '#13#10;
    Result:=Result+'fillBodyForMotulSiteInfo(); '#13#10;
    Result:=Result+'synqcolsForMPP("#tablecontentdiv-info","tableheader-info","tablecontent-info",TStream.arrMotulInfo.length);'#13#10;
  end;
end;
//-------------------------------------------------------------

procedure prGeneralNewSystemProcWebArm(Stream: TBoBMemoryStream; ThreadData: TThreadData);
 var
  StreamNew: TBoBMemoryStream;
  Res,nmProc,s,s1,s2,lastuserid:String;
  result,pos, TabNum,Sys: integer;
  byear, bmonth, eyear, emonth,Position,OperationCode: integer;
  Date: TDateTime;
  i,j:integer;
  a: tai;
  Template: string;
  IgnoreSpec: byte;
  c:  Char;
  wizardsearch,InfoOnly,flag,NotPictShow: boolean;
  ShortFilter: boolean;
  curUserInfo:TEmplInfo;
  Top10Cookie,oldShedulercode:String;
  temp,sid:String;
  DateBegin, DateEnd: TDateTime;
  v,kindSave:integer;
begin
  Stream.Position:= 0;
  try
    curUserInfo.Short := false;
    curUserInfo.UserLogin:= '';
    curUserInfo.SessionID:= '';
    curUserInfo.strPost:=TStringList.Create;
    curUserInfo.strGet:=TStringList.Create;
    curUserInfo.strCookie:=TStringList.Create;
    curUserInfo.strOther:=TStringList.Create;
    curUserInfo.strPost.Text:=Stream.ReadStr;
    curUserInfo.strGet.Text:=Stream.ReadStr;
    curUserInfo.strCookie.Text:=Stream.ReadStr;
    curUserInfo.strOther.Text:=Stream.ReadStr;
    ScriptName:=curUserInfo.strOther.Values['scriptname'];
    curUserInfo.MustChangePass:=false;
    curUserInfo.LogText:='';
    curUserInfo.SessionTimeMinStr:='3650';
    if FileExists('.\'+'server.ini') then begin
      IniFile:=TINIFile.Create('.\'+'server.ini');
    end else begin
      raise Exception.Create('�� ������ ini-����');
    end;
    TmpDir:=IniFile.ReadString('Options', 'TmpDir', '.\tmp');
    DescrDir:=IniFile.ReadString('Options', 'DescrDir', '..\orders');
    BaseDir:=IniFile.ReadString('Options', 'BaseDir', '..\orders');
    BaseUrl:='';
    DescrUrl:=IniFile.ReadString('Options', 'DescrUrl', '..\orders');
    DescrImageUrl:=IniFile.ReadString('Options', 'DescrImageUrl', '..\orders');


    StreamNew:=TBoBMemoryStream.Create;
    try
      sid:=curUserInfo.strCookie.Values['sid'];
    finally
      s:=StringReplace(curUserInfo.strCookie.Text, '; ', #13#10, [rfReplaceAll]);
      s:=StringReplace(s, '%7C', '|', [rfReplaceAll]);
      s:=StringReplace(s, '%2C', ',', [rfReplaceAll]);
      curUserInfo.strCookie.Text:=s;
      sid:=curUserInfo.strCookie.Values['sid'];
    end;
    sid:=trim(sid);



    if (( (trim(curUserInfo.strGet.Values['psw'])<>'') and (trim(curUserInfo.strGet.Values['lgn'])<>'') ) or ( (trim(curUserInfo.strPost.Values['psw'])<>'') and (trim(curUserInfo.strPost.Values['lgn'])<>'') ) or (curUserInfo.strCookie.Values['sid']<>'')) then begin
      StreamNew.Clear;
     // StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'psw'));
      //StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'lgn'));
      //StreamNew.WriteStr(curUserInfo.strCookie.Values['sid']);
      //StreamNew.WriteStr(curUserInfo.strOther.Values['ip']);
      //StreamNew.WriteStr(curUserInfo.strOther.Values['agent']);
      //prWebArmAutenticate(StreamNew, ThreadData);

      result:=fnWebArmAutenticateNew(curUserInfo,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'psw'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'lgn'),sid,curUserInfo.strOther.Values['ip'],curUserInfo.strOther.Values['agent'],ThreadData);

        //StreamNew.Position:=0;
        //result:=StreamNew.ReadInt;
        if result=aeSuccess then begin
          //curUserInfo.UserID:=IntToStr(StreamNew.ReadInt);
          //SessionID:=StreamNew.ReadStr;
          //ServerTime:=StreamNew.ReadDouble;
          //Roles:=StreamNew.ReadIntArray;
          //ShowImportPage:=StreamNew.ReadBool;
          //Links23Loaded:=StreamNew.ReadBool;
          //SysOptions:=StreamNew.ReadBool;
          //UserName:=StreamNew.ReadStr;

          curUserInfo.FirmID:=curUserInfo.strOther.Values['FirmID'];


          s:='';
          if (curUserInfo.strOther.Values['act']='changepass') then begin
            nmProc := 'fnChangePasswordWebarm'; // ��� ���������/�������
            Res:=fnChangePasswordWebarm(StrToInt(curUserInfo.UserID),curUserInfo.strPost.Values['opass'], curUserInfo.strPost.Values['npass1'], curUserInfo.strPost.Values['npass2']);
            if Res<>'' then begin
              raise EBOBError.Create('jqswMessageError('''+res+''');');
            end else  begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(' jqswMessage(''������ ������� �������''); ');
            end;
          end

          else if (curUserInfo.strOther.Values['act']='newsmanage') then begin
            nmProc := 'prNewsPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prNewsPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.NeedCalendar:=true;
              curUserInfo.Short:=true and (curUserInfo.strCookie.Values['left_block_expand']='0');
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmNewsList(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,Stream,StreamNew);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='autenticate') then begin //
            s:='';
            s:=s+'setCookie_("sid", "'+curUserInfo.SessionID+'", getExpDate_(0,0,'+curUserInfo.SessionTimeMinStr+'),"/",0,0);'#13#10;
            lastuserid:='';
            pos:=0;
            if (curUserInfo.strOther.Values['leftform']<>'true') then begin
              pos:=System.Pos('|', curUserInfo.strCookie.Values['sid']);
              if (pos>0) then begin
                lastuserid:=Copy(curUserInfo.strCookie.Values['sid'], 1, pos);
              end;
              pos:=System.Pos('|', curUserInfo.SessionID);
            end;
            if ((curUserInfo.strOther.Values['leftform']<>'true') and (pos>0) and (Copy(curUserInfo.SessionID, 1, pos)=lastuserid)) then begin
              s:=s+'$(''#aaformdiv'').dialog(''close'');'#13#10;
            end else begin
              s:=s+'reloadpage();'#13#10;
            end;
            Stream.Clear;
            Stream.WriteInt(aeSuccess);
            Stream.WriteStr(s);
          end

          else if (curUserInfo.strOther.Values['act']='quit') then begin //
            Stream.Clear;
            Stream.WriteInt(aeSuccess);
            s:='';
            s:=s+'setCookie_("sid", "", getExpDate_(0,0,0),"/",0,0);'#13#10;
            s:=s+'s=document.location.href;'#13#10;
            s:=s+'s=(s.substr(s.length-1)==''#'')?s.substr(0, s.length-1):s;'#13#10;
            s:=s+'document.location.href=s;';
            Stream.WriteStr(s);
          end

          else if (curUserInfo.strOther.Values['act']='shownotification') then begin
            nmProc := 'prShowNotificationOrd'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'notifcode')));
            prShowNotificationOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnShowNotification(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'notifcode')));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='editactionnews') then begin
            nmProc := 'prShowActionNews'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            prShowActionNews(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnShowActionNews(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='savenotification') then begin
            nmProc := 'prAEDNotification'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'code'), 0));
            s:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'fromdate');
            if (Length(s)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(s, 7, 2), 0), StrToIntDef(Copy(s, 4, 2), 0), StrToIntDef(Copy(s, 1, 2), 0), Date) then begin
             setErrorCommandStr(Stream,'������������ ���� - "'+s+'"');
            end
            else begin
              StreamNew.WriteDouble(Date);
              s:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'todate');
              if (Length(s)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(s, 7, 2), 0), StrToIntDef(Copy(s, 4, 2), 0), StrToIntDef(Copy(s, 1, 2), 0), Date) then begin
               setErrorCommandStr(Stream,'������������ ���� - "'+s+'"');
              end
              else begin
                StreamNew.WriteDouble(Date);
                StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'notiftext'))));
                StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'clienttype'));
                StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'clientcategory'));
                StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'clientfilial'));
                StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'firms'));
                StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'individualclientsmethod')='0');
                StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'auto')='true');
                StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'moto')='true');
                prAEDNotification(StreamNew, ThreadData);
                if StreamNew.ReadInt=aeSuccess then begin
                  Stream.Clear;
                  Stream.WriteInt(aeSuccess);
                  Stream.WriteStr(fnSaveNotification(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'code'),ThreadData));
                end else begin
                   setErrorCommand(StreamNew,Stream);
                end;
              end;
            end;
          end

          else if (curUserInfo.strOther.Values['act']='aeactionnews') then begin
            nmProc := 'prAEActionNews'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newsid'), -1));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'forauto')='on');
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'formoto')='on');
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'inframe')='on');
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'link')));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'caption')));
            s:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'todate');
            if (Length(s)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(s, 7, 2), 0), StrToIntDef(Copy(s, 4, 2), 0), StrToIntDef(Copy(s, 1, 2), 0), Date) then begin
             setErrorCommandStr(Stream,'������������ ���� ���������- "'+s+'"');
            end
            else begin
              StreamNew.WriteDouble(Date);
              s:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'fromdate');
              if (Length(s)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(s, 7, 2), 0), StrToIntDef(Copy(s, 4, 2), 0), StrToIntDef(Copy(s, 1, 2), 0), Date) then begin
               setErrorCommandStr(Stream,'������������ ���� ������ - "'+s+'"');
              end
              else begin
                StreamNew.WriteDouble(Date);
                StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'priority'), -1));
                prAEActionNews(StreamNew, ThreadData);
                if StreamNew.ReadInt=aeSuccess then begin
                  Stream.Clear;
                  Stream.WriteInt(aeSuccess);
                  Stream.WriteStr(fnAEActionNews(curUserInfo,StreamNew,ThreadData,StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newsid'), -1)));
                end else begin
                   setErrorCommand(StreamNew,Stream);
                end;
              end;
            end;
          end


          else if (curUserInfo.strOther.Values['act']='showNotificationWA') then begin
            nmProc := 'fnShowNotificationWA'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'code'), 0));
            prShowNotification(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnShowNotificationWA(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'code')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='delactionnews') then begin
            nmProc := 'prEditSysOption'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'), 0));
            prEditSysOption(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnEditSysOptions(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
          end

           else if (curUserInfo.strOther.Values['act']='editsysoption') then begin
            nmProc := 'prEditSysOption'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'), 0));
            prEditSysOption(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnEditSysOptions(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
          end


           else if (curUserInfo.strOther.Values['act']='savesysoption') then begin
            nmProc := 'prSaveSysOption'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'value'));
            prSaveSysOption(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnSaveSysOptions(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='aewausers') then begin
            nmProc := 'prAEWebArmUser'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'), -1));
            prAEWebArmUser(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              Stream.WriteLongStr(fnAewausers(StreamNew,StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'), -1)));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='savewausers') then begin
            nmProc := 'prSaveWebArmUsers'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'), -1));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'login'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pass'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'code'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dprt'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'gbuser'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'gbuserreport'));
            SetLength(curUserInfo.Roles, 0);
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if (Copy(curUserInfo.strPost.Names[i], 1, 2)='r_') then begin
                SetLength(curUserInfo.Roles, Length(curUserInfo.Roles)+1);
                curUserInfo.Roles[Length(curUserInfo.Roles)-1]:=StrToInt(Copy(curUserInfo.strPost.Names[i], 3, 1000));
              end;
            end;
            Stream.WriteIntArray(curUserInfo.Roles);
              if fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'disableoutipcheck')='on' then
                Stream.WriteBool(true)
              else
                Stream.WriteBool(false);
            prSaveWebArmUsers(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnSaveWebArmUser(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='blockuser') then begin
            nmProc := 'prBlockWebArmUser'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'),0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'command'));
            prBlockWebArmUser(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnBlockWebArmUser(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'command')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getwareforproduct') then begin
            nmProc := 'prProductWareSearch'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteByte(1); // ��������� �� ������������ ���������
            StreamNew.WriteByte(0); // ������� �������� ������ ���������� ������ - Id ������, ������, ������, ������������ ������
            if (trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))<>'') then begin
              StreamNew.WriteByte(0); // ������� ������� ������ �� ���� ������
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
            end else begin
              StreamNew.WriteByte(1); // ������� ������� ������ �� ���� ������
              StreamNew.WriteByte(byte(UpperCase(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ignorespec')))='ON')); //
              StreamNew.WriteStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'templ')));
            end;
            prProductWareSearch(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              Stream.WriteLongStr(fnGetWareForProduct(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ignorespec'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'templ')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getmanufacturerlist') then begin
            nmProc := 'prGetManufacturerList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            j:=StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'sys'));
            StreamNew.WriteInt(j); // 0 - ��� �������������
            if (j=21) then begin
               StreamNew.WriteBool(false);    // ����� ���������� ���������,  ��� ��� ��� ������� �� ��
            end else begin
               StreamNew.WriteBool(true);    // � ��������� ������� - �� ���������� ���������
            end;
            prGetManufacturerList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              Stream.WriteLongStr(fnGetmanufacturerlist(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'selname'),j));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='loadfirms') then begin
            nmProc := 'prWebArmGetRegionalFirms'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'firmtempl')));
            prWebArmGetRegionalFirms(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              Stream.WriteLongStr(fnLoadFirms(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='loadorder') then begin
            nmProc := 'prLoadOrder'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordernuminp')));
            prLoadOrder(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              Stream.WriteLongStr(fnLoadOrder(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end



           else if (curUserInfo.strOther.Values['act']='waresearch') then begin
            nmProc := 'prCommonWareSearch'; // ��� ���������/�������
            s:='';
            Template:=AnsiUpperCase(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch')));
            if length(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'))<3 then begin
              s:=s+'document.getElementById("waresearch").value="'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch')+'";';
              s:=s+'jqswMessage("������ ������ ������ ��������� �� ����� ���� ��������, �� ������ ���������� � ����������� ��������.");';
            end else begin
              if ((fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groups')='') and (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'lampbase')<>'true'))then Template:=UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'));
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
              StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
              StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
              StreamNew.WriteStr(Template);
              if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'lampbase')='true') then begin
                IgnoreSpec:=coLampBaseIgnoreSpec;
              end else begin
                IgnoreSpec:=fnIfInt(curUserInfo.strCookie.Values['ignorspec']='false', 0, 2);
              end;
              StreamNew.WriteByte(IgnoreSpec);
              StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groups'));
              prCommonWareSearch(StreamNew, ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccessLong);
                s:=s+fnWareSearch(curUserInfo,StreamNew,curUserInfo.LogText,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groups'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'),curUserInfo.strCookie.Values['ignorspec'],curUserInfo.strCookie.Values['one_line_mode'],fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'),AnsiUpperCase(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'))));
                Stream.WriteLongStr(s);
              end else begin
                 setErrorCommand(StreamNew,Stream);
              end;
            end;
           end

          else if (curUserInfo.strOther.Values['act']='getsatellites') then begin
            nmProc := 'prGetWareSatellites'; // ��� ���������/�������
            s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(s1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            prGetWareSatellites(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              s:=fnGetSatellites(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
              Stream.WriteLongStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end



          else if (curUserInfo.strOther.Values['act']='loadinvoice') then begin
            nmProc := 'prWebArmShowAccount'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            prWebArmShowAccount(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              s:=fnLoadInvoice(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
              Stream.WriteLongStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='saveaccheaderpart') then begin
            nmProc := 'prWebArmEditAccountHeader'; // ��� ���������/�������
            s:='';
            OperationCode:=csWebArmEditAccountHeader;
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid')));
            i:=-1;
            if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicestorage') then i:=ceahChangeStorage
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicecurr') then i:=ceahChangeCurrency
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoiceprocessed') then i:=ceahChangeProcessed
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicemaincomment') then i:=ceahChangeEmplComm
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoiceclientcomment') then i:=ceahChangeClientComm
            //else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid')='invoicedeliverydate') then i:=ceahChangeShipDate
            // else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid')='invoicedeliverytype') then i:=ceahChangeShipMethod
            //else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid')='invoicedeliverytime') then i:=ceahChangeShipTime
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicefirm') then i:=ceahChangeRecipient
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicedate') then i:=ceahChangeDocmDate
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicedeliverylabelcode') then i:=ceahChangeLabel
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='refreshprices') then i:=ceahRecalcPrices
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='recalccounts') then i:=ceahRecalcCounts
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='makeinvoice') then i:=ceahMakeInvoice
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='annulating') then i:=ceahAnnulateInvoice
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='invoicecontract') then i:=ceahChangeContract
            ;
            if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='makeinvoice') then begin
              OperationCode:=csWebArmMakeInvoiceFromAccount;
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'val')));
            end
            else if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')='annulating') then begin
            //      OperationCode:=csAnnulateInvoice;
              StreamNew.WriteInt(i);
              StreamNew.WriteStr(fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'annul')='true', 'T', 'F'));
              StreamNew.WriteStr(fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'reason')='true', 'T', 'F'));
            end else begin
              StreamNew.WriteInt(i);
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'val'));
            end;
            prWebArmEditAccountHeader(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:=fnSaveAccHeaderPart(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'val'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'annul'));
              Stream.WriteStr(s);
            end else begin
              s1:=StreamNew.ReadStr;
              s:='';
              s:=s+'alert("'+GetJSSafeString(s1)+'");';
              case i of
                ceahChangeCurrency, ceahChangeStorage, ceahChangeShipMethod, ceahChangeShipTime: begin
                  s:=s+'$("#'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')+'").val($("#'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'partid')+'").attr("oldval"));'#13#10;
                end;
                ceahChangeRecipient: begin
                  s:=s+'loadpayinvoice(-1, '+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid')+');'#13#10;
                end;
              end;
            end;
           end

           else if (curUserInfo.strOther.Values['act']='checkcontracts') then begin
            nmProc := 'prCheckContracts'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'firmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contractid'), 0));
            InfoOnly:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'infoonly')='true';
            prCheckContracts(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:=fnCheckContracts(StreamNew);
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

          else if (curUserInfo.strOther.Values['act']='showwarecompare') then begin
            nmProc := 'prGetCompareWaresInfo'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            SetLength(a, 0);
            i:=0;
            while (trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareid'+IntToStr(i)))<>'') do begin
              SetLength(a, i+1);
              a[i]:=StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareid'+IntToStr(i))));
              Inc(i);
            end;
            StreamNew.WriteIntArray(a);
            prGetCompareWaresInfo(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              Stream.WriteLongStr(fnShowWareCompare(StreamNew,curUserInfo.FirmID,ScriptName,curUserInfo.ContractId));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='selectcontract') then begin
            nmProc := 'rWebarmContractList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'firmid'), 0));
            prWebarmContractList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnSelectContract(StreamNew,StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'invoiceid')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end


           else if (curUserInfo.strOther.Values['act']='loadaccountlist') then begin
            nmProc := 'prWebArmGetFilteredAccountList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            ShortFilter:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'shortfilter')='true';
            if (ShortFilter) then begin
               StreamNew.WriteDouble(System.SysUtils.Date-14); // �� ��� ������
            end else begin
               temp:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterfromdate'));
               if temp='' then begin
                 Stream.WriteDouble(0);
                 DateBegin:=0;
               end else begin
                 if (Length(temp)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(temp, 7, 2), 0), StrToIntDef(Copy(temp, 4, 2), 0), StrToIntDef(Copy(temp, 1, 2), 0), Date) then begin
                   raise EBOBError.Create('������������ ���� - '+temp);
                 end;
                StreamNew.WriteDouble(Date);
                DateBegin:=Date;
               end;
            end;

            temp:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filtertodate'));
            if temp='' then begin
              StreamNew.WriteDouble(0);
              DateEnd:=System.SysUtils.Date;
            end else begin
                 if (Length(temp)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(temp, 7, 2), 0), StrToIntDef(Copy(temp, 4, 2), 0), StrToIntDef(Copy(temp, 1, 2), 0), Date) then begin
                   raise EBOBError.Create('������������ ���� - '+temp);
                 end;
                 StreamNew.WriteDouble(Date);
                 DateEnd:=Date;
               end;
            i:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterselectedfirm'), -1);
            if ((fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterexecuted')<>'') and ((DateEnd-DateBegin)<>0) and (i=-1)) then begin
               raise EBOBError.Create('������ ����������� ������ ������ ������� ����� �����������. ���������� ��������� �������� ��� �� ������ ��� ��� ������� ����������� �����������.');
            end;
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filtercurrency'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterstorage'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterdeliverytype'), -1));

            temp:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterdeliverydate'));
            if temp='' then begin
              StreamNew.WriteDouble(0);
            end else begin
              if (Length(temp)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(temp, 7, 2), 0), StrToIntDef(Copy(temp, 4, 2), 0), StrToIntDef(Copy(temp, 1, 2), 0), Date) then begin
                 raise EBOBError.Create('������������ ���� - '+temp);
              end;
              StreamNew.WriteDouble(Date);
            end;

            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterdeliverytime'), -1));

            StreamNew.WriteBool(ShortFilter or (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterexecuted')<>''));
            StreamNew.WriteBool(ShortFilter or (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterannulated')<>''));

            StreamNew.WriteInt(fnIfInt(ShortFilter, -1, fnGetValueFromPairCheckBoxes(curUserInfo, 'filterprocessed', 'filternonprocessed')));
            StreamNew.WriteInt(fnIfInt(ShortFilter, -1, fnGetValueFromPairCheckBoxes(curUserInfo, 'filterwebinvoice', 'filternonwebinvoice')));
            StreamNew.WriteInt(fnIfInt(ShortFilter, -1, fnGetValueFromPairCheckBoxes(curUserInfo, 'filterblocked', 'filternonblocked')));

            StreamNew.WriteInt(i);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filtercontract'), 0));
            prWebArmGetFilteredAccountList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnLoadAccountList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filterselectedfirm')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='showtransinvfororder') then begin
            nmProc := 'prWebArmGetTransInvoicesList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteDouble(SysUtils.Date-7);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'from'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'to'), 0));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'only')='true');
            prWebArmGetTransInvoicesList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnWebArmGetTransInvoicesList(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='createsubacc') then begin
            nmProc := 'prWebArmMakeSecondAccount'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            prWebArmMakeSecondAccount(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnCreateSubAcc(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='dellinefrominvoice') then begin
            nmProc := 'prWebArmEditAccountLine'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid')));
            StreamNew.WriteInt(constOpDel);
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'linecode')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareid')));
            StreamNew.WriteDouble(0);
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'old'), 0));
            prWebArmEditAccountLine(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnDelLineFromInvoice(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareid'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'linecode')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getdeliverieslist') then begin
            nmProc := 'prWebarmGetDeliveries'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'priceinuah')='1');
            prWebarmGetDeliveries(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

          else if (curUserInfo.strOther.Values['act']='fillheaderbeforeprocessing') then begin
            nmProc := 'fillheaderbeforeprocessing'; // ��� ���������/�������
            StreamNew.Clear;
            s:='';
            s:=s+'$("#fillheaderbeforeprocessingdiv").dialog("open");'#13#10;
            s:=s+'$("#fillheaderbeforeprocessingdiv input[name^=''typeofgetting'']:checked").trigger("change");'#13#10;
            s:=s+''#13#10;
            s:=s+''#13#10;
            s:=s+''#13#10;
            Stream.Clear;
            Stream.WriteInt(aeSuccess);
            Stream.WriteStr(s);
           end

           else if (curUserInfo.strOther.Values['act']='gettimelistselfdelivery') then begin
            nmProc := 'prgetTimeListSelfDelivery'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteDouble(StrToDate(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'date')));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'OldTime'), 0));
            prgetTimeListSelfDelivery(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetTimeListSelfDelivery(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'OldTime')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getcontractdestpointslist') then begin
            nmProc := 'prGetContractDestPointsList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contractid'), 0));
            StreamNew.WriteBool(true);   //������� ����������� ������. ���� - ������� � ����            prGetWareSatellites(StreamNew, ThreadData);
            prGetContractDestPointsList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetContractDestPointsList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'value'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'isEmpty')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='fillparametrsallorder') then begin
            nmProc := 'prGetAccountShipParams'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid'));
            prGetAccountShipParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnfillParametrsAllWebArm(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='saveparametrsfromorder') then begin
            nmProc := 'prSetAccountShipParams'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmiddeliv'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));
            v:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'typeofgetting'),0);
            StreamNew.WriteInt(v);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'t'),0));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverydate'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'shedulercode'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pickuptime'),0));
            prSetAccountShipParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnsaveParametrsFromWebArm(StreamNew,v,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverytext'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverydate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='filldeliverysheduler') then begin
            nmProc := 'prGetAvailableTimeTablesList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_tt'),0));
            StreamNew.WriteDouble(StrToDateDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_deliverydate'),0));
            oldShedulercode:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_shedulercode');
            prGetAvailableTimeTablesList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnFillDeliverySheduler(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_tt'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_deliverydate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getdatelistselfdelivery') then begin
            nmProc := 'prGetDprtAvailableShipDates'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contractid'), 0));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate'),0));
            i:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate'),0);
            flag:=true;
            prGetDprtAvailableShipDates(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetDateListSelfDelivery(StreamNew,flag,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattrlistselected') then begin
            nmProc := 'prGetFilteredGBGroupAttValues'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groupid'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'count'),0));
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if ((curUserInfo.strPost.Names[i]<>'act')
                 and (curUserInfo.strPost.Names[i]<>'selectname')
                 and (curUserInfo.strPost.Names[i]<>'groupid')
                 and (curUserInfo.strPost.Names[i]<>'count')
                 and (curUserInfo.strPost.Names[i]<>'')
              ) then begin
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Names[i]));
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]]));
              end;
            end;
            prGetFilteredGBGroupAttValues(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetAttrListSelected(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'selectname')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='fillattrlistselected') then begin
            nmProc := 'prGetFilteredGBGroupAttValues'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groupid'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'count'),0));
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if ((curUserInfo.strPost.Names[i]<>'act')
                 and (curUserInfo.strPost.Names[i]<>'selectname')
                 and (curUserInfo.strPost.Names[i]<>'groupid')
                 and (curUserInfo.strPost.Names[i]<>'count')
                 and (curUserInfo.strPost.Names[i]<>'')
              ) then begin
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Names[i]));
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]]));
              end;
            end;
            prGetFilteredGBGroupAttValues(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnFillAttrListSelected(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'selectname')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattrlist') then begin
            nmProc := 'prGetListGroupAttrs'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'), 0));
            prGetListGroupAttrs(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetAttrList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getwaresbyattr') then begin
            nmProc := 'prCommonSearchWaresByAttr'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Pos:=StreamNew.Position;
            v:=0; //WareCount
            StreamNew.WriteInt(0);
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if ((curUserInfo.strPost.Names[i]<>'act')
                and (curUserInfo.strPost.Names[i]<>'forfirmid')
                and (curUserInfo.strPost.Names[i]<>'contract')
                and (curUserInfo.strPost.Names[i]<>'')) then begin
                  StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Names[i]));
                  StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]]));
                  Inc(v);
                end;
            end;
            StreamNew.Position:=Pos;
            StreamNew.WriteInt(v);
            StreamNew.Position:=StreamNew.Size;
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            prCommonSearchWaresByAttr(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetWaresByAttr(curUserInfo,StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end



           else if (curUserInfo.strOther.Values['act']='getanalogs') then begin
            nmProc := 'prGetWareAnalogs'; // ��� ���������/�������
            s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(s1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            StreamNew.WriteByte(fnIfInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'is_on')='0', constThisIsWare, constThisIsOrNum));
            prGetWareAnalogs(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              s:=fnGetAnalogs(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'is_on'));
              Stream.WriteLongStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getaresdescrview') then begin
            nmProc := 'prWebArmGetWaresDescrView'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecodes'));
            prWebArmGetWaresDescrView(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnWebArmGetWaresDescrView(StreamNew));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='gettop10') then begin
            nmProc := 'prGetTop10Model'; // ��� ���������/�������
            Top10Cookie:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'objdiv');
            Sys:=0;
            if (Top10Cookie='autotop10') or (Top10Cookie='mototop10') or (Top10Cookie='auentop10') then begin
              if (Top10Cookie='autotop10') then begin
                Sys:=constIsAuto;
              end;
              if (Top10Cookie='mototop10') then begin
                Sys:=constIsMoto;
              end;
              if (Top10Cookie='auentop10') then begin
                Sys:=30+constIsAuto;
              end;
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(Sys);
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'))); // ��� ������
              StreamNew.WriteStr(curUserInfo.strCookie.Values[Top10Cookie]);
              prGetTop10Model(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                s:=fnRefreshTop10List(StreamNew,Top10Cookie,Sys);
                Stream.WriteStr(s);
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
            end
            else begin
              setErrorCommandStr(Stream,'������� ������ ������� ��� ���������� - '+Top10Cookie+' , �������� �� ���� ������ ������������');
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattributegrouplist') then begin
            nmProc := 'prGetListAttrGroupNames'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'sys'))); // ��� ������
            prGetListAttrGroupNames(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(fnGetAttributeGroupList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'tablename')));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end

           else if (curUserInfo.strOther.Values['act']='getattributegrouplist') then begin
            nmProc := 'prGetListAttrGroupNames'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'model'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'node'), -1));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecodes'));
            prCommonGetRestsOfWares(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                s:='';
                i:=Stream.ReadInt;
                for i:=1 to i do begin
                 j:=Stream.ReadInt; //Code
                 v:=Stream.ReadInt; //Qty
                 s:=s+'$(''.rm'+IntToStr(j)+''').css(''background-image'', ''url('+fnIfStr(curUserInfo.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/restmark'+IntToStr(v)+'.png)'');'#13#10;
                 s:=s+'$(''.rm'+IntToStr(j)+'[title=""]'').attr(''title'', '''+fnIfStr(v=0, '��� � �������', '���� � �������')+''');'#13#10;
               end;
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(s);
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end

           else if (curUserInfo.strOther.Values['act']='getnodewares') then begin
            nmProc := 'prCommonGetNodeWares'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'node'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'model'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), -1));
            StreamNew.WriteBool(true);
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pref')='sel_auen');
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filter'));
            prCommonGetNodeWares(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(fnGetNodeWares(StreamNew,curUserInfo,ScriptName));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end

           else if (curUserInfo.strOther.Values['act']='showfilter') then begin
            nmProc := 'prGetFilterValues'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'node'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'model'), -1));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pref')='sel_auen');
            prGetFilterValues(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnShowFilter(StreamNew,curUserInfo));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='loadmodeltree') then begin
            nmProc := 'prGetListAttrGroupNames'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),0));
            StreamNew.WriteBool(false);
            s1:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pref');
            if s1='sel_auen' then begin
              prGetEngineTree(StreamNew,ThreadData);
            end
            else
              prGetModelTree(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnLoadModelTree(StreamNew,curUserInfo,s1));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='wareinfo') then begin
            nmProc := 'prGetWareInfoView'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToIntDef(curUserInfo.FirmID,-1));
            StreamNew.WriteInt(StrToIntDef(curUserInfo.UserID,-1));
            StreamNew.WriteInt(curUserInfo.ContractId);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'model'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'node'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), -1));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'eng')='true');
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filter'));
            if curUserInfo.FirmID<>IntToStr(isWe) then
              prGetWareInfoView(StreamNew,ThreadData)
            else
              prGetWareInfoView(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccessLong);
                Stream.WriteLongStr(fnShareWareinfoAction(StreamNew,curUserInfo,DescrImageUrl,ScriptName));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end






           (*else if (curUserInfo.strOther.Values['act']='FindByVIN') then begin
             if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'vin')<>'') then begin
               wizardsearch:=false;
               if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frame')<>'') then begin
                 s:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frame')+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frameNo');
                 s1:= ' FRAME ';
               end;
               for i:= 1 to length(s) do begin
                 c:= s[i];
                 if not SysUtils.CharInSet(c, ['a'..'z', 'A'..'Z', '0'..'9']) then begin
                   wizardsearch:= true;
                   break;
                 end;
               end;
               if (length(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'vin'))=17) and (not wizardsearch) then begin
                 s:= '';
                 s1:= '';
                 StreamNew.Clear;
                 StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
                 StreamNew.WriteInt(StrToInt(FirmID));
                 StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'),StrToInt(FirmID)));
                 if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'command'))<>'' then begin
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'manuf'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'vin'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'cat'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'command'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ssd'));
                   i:= oecExecCustomOperation;
                 end
                 else begin
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'manuf'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'vin'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frame'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frameNo'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'WizardId'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'cat'));
                   StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ssd'));
                   i:= oecFindByVIN;
                 end;
                 if fnSendReceiveData(i, StreamNew, csServerManage) then begin
                    if StreamNew.ReadInt=aeSuccess then begin
                      Stream.WriteInt(aeSuccessLong);
                      Stream.WriteLongStr(fnFindByVIN(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'icon'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'izardId'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frame'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'frameNo'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'inputid')));
                    end
                    else begin
                      s1:=StreamNew.ReadStr;
                      s1:=' �� ���������� ������ ���������� �� �������.'#13#10+fnIfStr((System.Pos('URL',s1)>0),copy(s1,1,System.Pos('URL',s1)-1),s1);
                      setErrorCommandStr(Stream,'jqswMessageError("������ : '+GetJSSafeString(s)+'");');
                    end;
                 end
                 else begin
                   setErrorCommand(StreamNew,Stream);
                 end;

               end
               else begin
                 if (length(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'vin'))<>17) then begin
                   setErrorCommandStr(Stream,'jqswMessageError("������ : '+GetJSSafeString('VIN-��� ������ �������� �� 17 ��������!')+'");');
                 end;
                 if (wizardsearch) then begin
                   setErrorCommandStr(Stream,'jqswMessageError("alert("������: '+GetJSSafeString('� ��������� �������� '+s1+' ������������ ����������� �������!')+'");');
                 end;

               end;
             end;
           end *)


          else if (curUserInfo.strOther.Values['act']='getorignumandanalogs') then begin
             nmProc := 'getorignumandanalogs'; // ��� ���������/�������
             TabNum:=StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'tab'));
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             s:='';
             if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'newware')='1') then begin
               s:=s+'clearwaredopinfo();'#13#10;
             end;
             s:=s+'flNewModeCGI='+BoolToStr(flNewModeCGI)+';'#13#10;
             s:=s+'var qvColPrice='+IntToStr(Length(arPriceColNames))+';'#13#10;
             s:=s+'var arColHeaders= []; ' ;
             s:=s+'var arColHeadersTitle=[]; ';
             for i := 0 to Length(arPriceColNames)-1 do  begin
               s:=s+'arColHeaders['+IntToStr(i)+']="'+arPriceColNames[i].ColName+'";';
               s:=s+'arColHeadersTitle['+IntToStr(i)+']="'+arPriceColNames[i].FullName+'";';
             end;
             s:=s+'$(''#addornumbyhand'').attr(''name'', '''+trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'))+''');'#13#10;
             s:=s+fnGetOrignumAndAnalogs(curUserInfo,StreamNew,TabNum,ThreadData,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'));
             Stream.Clear;
             Stream.WriteInt(aeSuccess);
             Stream.WriteStr(s);
          end


          else if (curUserInfo.strOther.Values['act']='loadpersons') then begin
             nmProc := 'prWebArmGetFirmUsers'; // ��� ���������/�������
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),0));
             prWebArmGetFirmUsers(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnLoadPersons(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;

          end

          else if (curUserInfo.strOther.Values['act']='loadmanuf') then begin
             nmProc := 'prGetManufacturerList'; // ��� ���������/�������
             StreamNew.Clear;
             StreamNew.WriteInt(isWe);
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
             StreamNew.WriteInt(10+StrToInt(s)); //
             StreamNew.WriteBool(false);    // ���������� ���������, ��� ��� ��� ����� ����������
             prGetManufacturerList(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnLoadManufactures(StreamNew,s));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end



           else if (curUserInfo.strOther.Values['act']='addornum') then begin
             nmProc := 'prProductAddOrigNum'; // ��� ���������/�������
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ornumware')));     // ���� ������������
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'manufacturerid')));// ��� ������������� ����
             StreamNew.WriteStr(trim(UTF8ToANSI(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ornumtext'))));             // ���������� ������������ �����
             prProductAddOrigNum(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               j:=StreamNew.ReadInt; //NewId
               s:='';
               s:=s+'  var tbl_=document.getElementById(''orignumstable'');'#13#10;
               s:=s+'  while (tbl_.rows.length) tbl_.deleteRow(0);'#13#10;
               s:=s+'  tbl_=document.getElementById(''wrongoetable'');'#13#10;
               s:=s+'  while (tbl_.rows.length) tbl_.deleteRow(0);'#13#10;
               s:=s+'  ec("getorignumandanalogs", "id='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ornumware')+'&newware=0&tab=1", "newbj") ;'#13#10;
               s:=s+'$.fancybox.close();'#13#10;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='delornum') then begin
             nmProc := 'prProductDelOrigNum'; // ��� ���������/�������
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'wareid')));     // ������ ���������
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'numid')));      // ��� ���������
             prProductDelOrigNum(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               s:='';
               s:=s+'var tbl_=document.getElementById(''orignumstable'');'#13#10;
               s:=s+'tbl_.deleteRow($("#trornum_'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'numid')+'")[0].rowIndex);'#13#10;
               s:=s+'zebratable(tbl_);'#13#10;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='getwareforaddtoanalog') then begin
             nmProc := 'prProductWareSearch'; // ��� ���������/�������
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             StreamNew.WriteByte(0); // ��������� �� ������������ ��������� 0=���
             StreamNew.WriteByte(1); // ������� �������� �������� ������ - Id ������, �����, ������, ������������ ������
             StreamNew.WriteByte(1); // ������� ������� ������ �� ������� ������
             StreamNew.WriteByte(byte(UpperCase(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ignorespec')))='ON')); //
             StreamNew.WriteStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'templ')));
             prProductWareSearch(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               s:='';
               s:=s+'var tbl_=document.getElementById(''gbanalogsforaddtable'');'#13#10;
               s:=s+'while (tbl_.rows.length) tbl_.deleteRow(0);'#13#10;
               s:=s+'var altrow=false;'#13#10;

               j := Stream.ReadInt; //iMaxWare
               for i := 1 to j do begin
                 s:=s+'addwaretosearchlist1(' + IntToStr(StreamNew.ReadInt)+ {��� ������}
                 ', "' + (StreamNew.ReadStr)+'"'+ {�����}
                 ', "' + (StreamNew.ReadStr)+'"'+ {������}
                 ', "'+ StringReplace(Stream.ReadStr, '"', '`',[rfReplaceAll, rfIgnoreCase]) +'", -1, -1, false);'#13#10; {������������ ������}
               end;

               s:=s+'$(''a[id^="srware_"]'').bind(''click'', function(event) {'#13#10;
               s:=s+'  tabvis(tabnum_);'#13#10;
               s:=s+'  this.title="�������� ��������� ������";'#13#10;
               s:=s+'});'#13#10;
               s:=s+'$(''#GrossBeediv div.inborder'').scrollTop(0);'#13#10;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='getwareforaddtoanalog') then begin
             nmProc := 'prProductWareSearch'; // ��� ���������/�������
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'wareid')));     // �����
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'numid')));      // ��
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'wrong')));      // �� ����� ������� ������
             StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'srcid')));      // ��� ���������
             prProductWareSearch(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               s:='';
               s:=s+'  var tbl_=document.getElementById(''orignumstable'');'#13#10;
               s:=s+'  while (tbl_.rows.length) tbl_.deleteRow(0);'#13#10;
               s:=s+'  tbl_=document.getElementById(''wrongoetable'');'#13#10;
               s:=s+'  while (tbl_.rows.length) tbl_.deleteRow(0);'#13#10;

               s:=s+'  ec("getorignumandanalogs", "id='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'wareid')+'&newware=0&tab=1", "newbj") ;'#13#10;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='loadmodelline') then begin
             nmProc := 'prGetModelLineList'; // ��� ���������/�������
             if fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'rep')='rep' then s:= 'addmodellinerowrep'
             else s:= 'addmodellinerow';
             StreamNew.Clear;
             StreamNew.WriteInt(isWe);
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
             StreamNew.WriteInt(StrToInt(s1)); //
             StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
             StreamNew.WriteBool(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'top'))='1');
             StreamNew.WriteBool(false);    // ���������� ���������
             prGetModelLineList(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnLoadModelLine(s,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'rep'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;

          end

          else if (curUserInfo.strOther.Values['act']='addmanufacturer') then begin
            nmProc := 'prManufacturerAdd'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteStr(UTF8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name'))));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_top')<>'');
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_vis')<>'');
            prManufacturerAdd(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr('reloadpage();');
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='addmodelline') then begin
            nmProc := 'prModelLineAdd'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            StreamNew.WriteInt(StrToInt(s)); //
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'pid'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteStr(UTF8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name'))));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_top')<>'');
            byear:=StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'byear')), 0);  //
            bmonth:=StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'bmonth')), 0); //
            eyear:=StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'eyear')), 0);  //
            emonth:=StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'emonth')), 0); //
            StreamNew.WriteInt(byear);  //
            StreamNew.WriteInt(bmonth); //
            StreamNew.WriteInt(eyear);  //
            StreamNew.WriteInt(emonth); //
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_vis')<>'');
            prModelLineAdd(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='var tbl=$("#modellinetable")[0];'#13#10;
              s:=s+'var altrow=false;'#13#10;
              s:=s+' addmodellinerow(' + IntToStr(Stream.ReadInt) + ', "' + UTF8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name')))
              + '", '+fnIfStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_vis'))='', '0', '1')+', '+fnIfStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_top'))='', '0', '1')+', '+trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'))+', "';
              s1:='';
              s1:=fnGetYMBE(byear, bmonth, eyear, emonth);
              s:=s+s1+'", '+IntToStr(byear)+', '+IntToStr(bmonth)+', '+IntToStr(eyear)+', '+IntToStr(emonth)+', '+fnIfStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_vis'))='', '0', '1')
              +', '+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')+');'#13#10;
              s:=s+'zebratable("#modellinetable");'#13#10;
              s:=s+'$.fancybox.close();'#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='editmodelline') then begin
            nmProc := 'prModelLineEdit'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteStr(UTF8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name'))));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_top')<>'');
            StreamNew.WriteInt(StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'byear')), 0));  //
            StreamNew.WriteInt(StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'bmonth')), 0)); //
            StreamNew.WriteInt(StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'eyear')), 0));  //
            StreamNew.WriteInt(StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'emonth')), 0)); //
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_vis')<>'');
            prModelLineEdit(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='';
              s:=s+'$.fancybox.close();'#13#10;
              s:=s+'$("#manuftr'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'pid')+' td div span a").click();'#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='editmanufacturer') then begin
            nmProc := 'prManufacturerEdit'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'));
            StreamNew.WriteInt(StrToInt(s)); //
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteStr(UTF8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name'))));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_top')<>'');
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_vis')<>'');
            prManufacturerEdit(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr('reloadpage();');
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='delmodelline') then begin
            nmProc := 'prModelLineDel'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            prModelLineDel(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='';
              s:=s+'$("#modellinetr'+trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))+'").remove();'#13#10;
              s:=s+'zebratable("#modellinetable");'#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='delmanufacturer') then begin
            nmProc := 'prManufacturerDel'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            prManufacturerDel(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               s:='';
               s:=s+'$("#manuftr'+trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))+'").remove();'#13#10;
               s:=s+'zebratable("#manuftable");'#13#10;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='changenodevisibility') then begin
            nmProc := 'prTNANodeEdit'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            StreamNew.WriteStr('');                                               // ��� ����
            StreamNew.WriteStr('');                                               // ��������� ��� ����
            StreamNew.WriteInt(fnIfInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis')='true', 1, 0));  // ���������
            StreamNew.WriteInt(-1);                                                // ������� ����
            prTNANodeEdit(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               s:='';
               s:=s+'if (curnode && ($(curnode).attr(''code'')=='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')+')) $("#nodevisibility")[0].checked='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis')+';'#13#10;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='makesuper') then begin
            nmProc := 'prWebArmSetFirmMainUser'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'pid')));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'login'));
            prWebArmSetFirmMainUser(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               s:='';
               s:=s+'ec("loadpersons", "id='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'pid')+'", "newbj");';
               if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_login')<>'') then begin
                 s:=s+'$.fancybox.close();'#13#10;
                 s:=s+'jqswMessage("������� ������ ��� ������ �������� ������������ ������� �������. ����� � ������ ���������� �� email ������������.");'#13#10;
               end;
               Stream.WriteStr(s);
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end


          else if (curUserInfo.strOther.Values['act']='loadmodellist') then begin
            Sys:=StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys')), -1);
            s1:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'tablename');
            if not (Sys in constAllSys) then begin
              setErrorCommandStr(StreamNew,'����������� ��� ������� - '+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'));
            end
            else begin
              nmProc := 'prGetModelLineModels'; // ��� ���������/�������
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
              StreamNew.WriteBool(true); // ���� �����
              StreamNew.WriteBool(true); // �� ���������� ���������
              prGetModelLineModels(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(fnLoadModelList(StreamNew,s1,Sys));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
            end;
          end

          else if (curUserInfo.strOther.Values['act']='loadmodellinelist') then begin
            nmProc := 'prGetModelLineList'; // ��� ���������/�������
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'select'));
            StreamNew.Clear;
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(s));
            StreamNew.WriteInt(StrToIntDef(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')), -1));
            StreamNew.WriteBool(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'top'))='1');
            StreamNew.WriteBool(true);    // �� ���������� ���������
            prGetModelLineList(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnLoadModellineList(StreamNew,s1));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end


          else if (curUserInfo.strOther.Values['act']='deltreenode') then begin
            nmProc := 'prTNANodeDel'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'));
            StreamNew.WriteInt(StrToInt(s)); //
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            prTNANodeDel(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnDelTreeNode(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='edittreenode') then begin
            nmProc := 'prTNANodeEdit'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'))));
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newname'))));
            StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newsysname'))));
            StreamNew.WriteInt(fnIfInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis')='true', 1, 0));  // ���������
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'mainnode')));         // ������� ����
            prTNANodeEdit(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               s1:=StreamNew.ReadStr;
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnEditTreeNode(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'),s1,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'mainnode')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='addtreenode') then begin
            nmProc := 'prTNANodeAdd'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'))));
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newname'))));
            StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newsysname'))));
            StreamNew.WriteInt(fnIfInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis')='true', 1, 0));  // ���������
            StreamNew.WriteInt(-1);         // ������� ����
            prTNANodeAdd(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               i:=StreamNew.ReadInt;
               s1:=StreamNew.ReadStr;
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnAddTreeNode(StreamNew,i,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'),s1,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newname')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='addtreesubnode') then begin
            nmProc := 'prTNANodeAdd'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'sys'))));
            StreamNew.WriteInt(StrToInt(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'))));
            StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newname'))));
            StreamNew.WriteStr((trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newsysname'))));
            StreamNew.WriteInt(fnIfInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis')='true', 1, 0));  // ���������
            StreamNew.WriteInt(-1);         // ������� ����
            prTNANodeAdd(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               i:=StreamNew.ReadInt;
               s1:=StreamNew.ReadStr;
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnAddSubTreeNode(StreamNew,i,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'),s1,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newname')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='showportion') then begin
            nmProc := 'prShowPortion'; // ��� ���������/�������
            if fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'portion')='-1' then begin
              s1:='';
              s1:=s1+'<table id="criteriatbl">';
              s1:=s1+'</table>';
              s:=s+'$("#jqueryuidiv").html('''+fnGetPortionWindow(s1)+''');'#13#10;
              s:=s+'$("button").button();'#13#10;
              s:=s+'$("#uiSavePortion").button( "option", "disabled", true );'#13#10;
              s:=s+'$("#jqueryuidiv").dialog({ modal: true, zIndex: 950, width: "auto", title: "����� ���� ������� ������������" });'#13#10;
              s:=s+'$("#blocknum").val(-1);'#13#10;
            end else begin
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model')));
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node')));
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware')));
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'portion')));
              prShowPortion(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnShowPortion(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'portion'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'mode'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware'),curUserInfo.UserID,ThreadData));
              end else begin
               setErrorCommand(StreamNew,Stream);
             end;
            end;
          end

          else if (curUserInfo.strOther.Values['act']='getcriteriavalues') then begin
            nmProc := 'prGetCateroryValues'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteStr((fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'criteria')));
            prGetCateroryValues(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnGetCriteriaValues(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'value')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='markportion') then begin
            nmProc := 'prMarkPortions'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'portion')));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'mark'));
            prMarkPortions(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnAddSubTreeNode(StreamNew,i,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id'),s1,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'vis'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'newname')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end


          else if (curUserInfo.strOther.Values['act']='getcriteriavalues') then begin
            nmProc := 'prGetCateroryValues'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteStr((fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'criteria')));
            prGetCateroryValues(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnGetCriteriaValues(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'value')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='getrestsofwares') then begin
            nmProc := 'prCommonGetRestsOfWares'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            Stream.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'forfirmid'), 0));
            Stream.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'contract'), 0));
            Stream.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model'), -1));
            Stream.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node'), -1));
            Stream.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'warecodes'));
            prCommonGetRestsOfWares(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnGetRestsOfWares(StreamNew));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end


          else if (curUserInfo.strOther.Values['act']='showconditionportions') then begin
            nmProc := 'prShowConditionPortions'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware')));
            prShowConditionPortions(StreamNew,ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fnShowConditionPortions(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model')));
             end else begin
               setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='saveportion') then begin
            nmProc := 'prSavePortion'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'code')));
            Position:=Stream.Position;
            Stream.WriteInt(0);
            i:=0;
            while (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'crit'+IntToStr(i))<>'') do begin
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'crit'+IntToStr(i)));
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'val'+IntToStr(i)));
              Inc(i);
           end;
           Stream.Position:=Position;
           Stream.WriteInt(i);
           prSavePortion(StreamNew,ThreadData);
           if StreamNew.ReadInt=aeSuccess then begin
             Stream.Clear;
             Stream.WriteInt(aeSuccess);
             Stream.WriteStr(fnSavePortion(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'node'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'model')));
           end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='addbrandlink') then begin
            nmProc := 'prAddLinkBrandsGBTD'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'gbcode')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'tdcode')));
            prAddLinkBrandsGBTD(StreamNew,ThreadData);
           if StreamNew.ReadInt=aeSuccess then begin
             Stream.Clear;
             Stream.WriteInt(aeSuccess);
             Stream.WriteStr(fnAddBrandLink(StreamNew));
           end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='delregzone') then begin
            nmProc := 'prWebArmDeleteRegionalZone'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
            prWebArmDeleteRegionalZone(StreamNew,ThreadData);
           if StreamNew.ReadInt=aeSuccess then begin
             s:='';
             Stream.Clear;
             Stream.WriteInt(aeSuccess);
             s:=s+'s=document.location.href;'#13#10;
             s:=s+'s=(s.substr(s.length-1)==''#'')?s.substr(0, s.length-1):s;'#13#10;
             s:=s+'document.location.href=s;';
             Stream.WriteStr(s);
           end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='editregzone') then begin
            nmProc := 'prWebArmDeleteRegionalZone'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name')));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_email')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_dprt')));
            prWebArmUpdateRegionalZone(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              s:='';
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:=s+'s=document.location.href;'#13#10;
              s:=s+'s=(s.substr(s.length-1)==''#'')?s.substr(0, s.length-1):s;'#13#10;
              s:=s+'document.location.href=s;';
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='addregzone') then begin
            nmProc := 'prWebArmInsertRegionalZone'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_name')));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_email')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, '_dprt')));
            prWebArmInsertRegionalZone(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              s:='';
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:=s+'s=document.location.href;'#13#10;
              s:=s+'s=(s.substr(s.length-1)==''#'')?s.substr(0, s.length-1):s;'#13#10;
              s:=s+'document.location.href=s;';
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='annregord') then begin
            nmProc := 'annregord'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
            StreamNew.WriteStr(AnsiToUtf8(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'reason')));            prWebArmInsertRegionalZone(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              s:='';
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:=s+'$("#regordertr'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')+'")[0].cells[1].innerHTML="<a class=ahint title=''������������''>2</a>";'#13#10;
              s:=s+'$("#regordertr'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')+'")[0].cells[2].innerHTML="&nbsp;";'#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='getmppregords') then begin
            nmProc := 'prWebArmGetOrdersToRegister'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'new')<>'');
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'processed')<>'');
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'annulated')<>'');
            s1:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'fromdate');
            if (Length(s1)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(s1, 7, 2), 0), StrToIntDef(Copy(s1, 4, 2), 0), StrToIntDef(Copy(s1, 1, 2), 0), DateBegin) then begin
              setErrorCommandStr(Stream,'������������ ���� - '+s1);
            end else begin
              s1:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'todate');
              if (Length(s1)<8) or not TryEncodeDate(2000+StrToIntDef(Copy(s1, 7, 2), 0), StrToIntDef(Copy(s1, 4, 2), 0), StrToIntDef(Copy(s1, 1, 2), 0), DateEnd) then begin
                setErrorCommandStr(Stream,'������������ ���� - '+s1);
              end else begin
                StreamNew.WriteDouble(DateBegin);
                StreamNew.WriteDouble(DateEnd);

                StreamNew.WriteStr(UTF8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'nametempl'))));
                StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'dprt'), -1));

                prWebArmGetOrdersToRegister(StreamNew,ThreadData);
                if StreamNew.ReadInt=aeSuccess then begin
                  Stream.Clear;
                  Stream.WriteInt(aeSuccessLong );
                  Stream.WriteLongStr(fnGetMPPRegOrds(StreamNew));
                end else begin
                  setErrorCommand(StreamNew,Stream);
                end;
              end;
            end;
          end

          else if (curUserInfo.strOther.Values['act']='getdprtlist') then begin
            nmProc := 'prGetFilialList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prGetFilialList(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              j:=StreamNew.ReadInt; //Count1
              s:='';
              s:=s+'var dprtstr='''';'#13#10;
              s:=s+'dprtstr+=''<option value=-1> </option>'';'#13#10;
              for i:=0 to j do begin
                s1:=IntToStr(Stream.ReadInt);
                s2:=GetJSSafeString(Stream.ReadStr);
                s:=s+'dprtstr+=''<option id=dprtopt'+s1+' value='+s1+'>'+s2+'</option>'';'#13#10;
              end;
              s:=s+'$("#'+trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'dest'))+'").html(dprtstr);'#13#10;
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end



          else if (curUserInfo.strOther.Values['act']='delbrandlink') then begin
            nmProc := 'prDelLinkBrandsGBTD'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'GBCode')));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'TDCode')));
            prDelLinkBrandsGBTD(StreamNew,ThreadData);
           if StreamNew.ReadInt=aeSuccess then begin
             s:='';
             s:=s+'$("#tablecontent")[0].deleteRow($("#tablecontent #tr'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'GBCode')+'_'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'TDCode')+'")[0].rowIndex);'#13#10; //
             s:=s+'zebratable($("#tablecontent")[0]);'#13#10;
             Stream.Clear;
             Stream.WriteInt(aeSuccess);
             Stream.WriteStr(s);
           end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='getfirmlist') then begin
            nmProc := 'getfirmlist'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'GBCode')));
            prAccountsGetFirmList(StreamNew,ThreadData);
           if StreamNew.ReadInt=aeSuccess then begin
             Stream.Clear;
             Stream.WriteInt(aeSuccess);
             Stream.WriteStr(fnWebArmGetFirmList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'inputid'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'templ')));
           end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='getfirmaccountlist') then begin
            nmProc := 'prWebArmGetFirmAccountList'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'id')));
            prWebArmGetFirmAccountList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:=fnGetMPPAccountList(StreamNew,curUserInfo);
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end


          else if (curUserInfo.strOther.Values['act']='wares') then begin
            nmProc := 'prProductPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prProductPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.NeedCalendar:=true;
              curUserInfo.NeedTinyMCE:=true;
              curUserInfo.Short:=true and (curUserInfo.strCookie.Values['left_block_expand']='0');
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmWaresList(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='cou') then begin
            nmProc := 'prCOUPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prCOUPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.NeedCalendar:=true;
              curUserInfo.NeedTinyMCE:=true;
              curUserInfo.Short:=true and (curUserInfo.strCookie.Values['left_block_expand']='0');
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmCOUPage(StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='logotypes') then begin
            nmProc := 'prManageLogotypesPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prManageLogotypesPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.Short:=true and (curUserInfo.strCookie.Values['left_block_expand']='0');
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmLogotypes(StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end


          else if (curUserInfo.strOther.Values['act']='brandcross') then begin
            nmProc := 'prManageBrands'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prManageBrands(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.Short:=true and (curUserInfo.strCookie.Values['left_block_expand']='0');
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmBrandsCross(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          {else if (curUserInfo.strOther.Values['act']='accountsreestr') then begin
            nmProc := 'prProductPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prAccountsReestrPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.NeedCalendar:=true;
              curUserInfo.NeedTinyMCE:=true;
              curUserInfo.NeedDropFirmList:=true;
              curUserInfo.Short:=true and (curUserInfo.strCookie.Values['left_block_expand']='0');
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmAccountList(StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end}

          else if (curUserInfo.strOther.Values['act']='showdoc') then begin
            StreamNew.Clear;
            if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'type')='99') then   begin
              nmProc := 'prShowGBAccountOrd'; // ��� ���������/�������
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(isWe);
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'code'));
              StreamNew.WriteBool(True); //�������  ������ ������
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'emplid')));
              prShowGBAccountOrd(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                OnReadyScript:='';
                globToHeader:='';
                globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
                globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
                globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
                curUserInfo.PageName:=curUserInfo.strOther.Values['act']+'_acc';
                curUserInfo.NeedCalendar:=true;
                Stream.WriteInt(aeSuccess);
                Stream.WriteLongStr(fnHeader(curUserInfo));
                Stream.WriteLongStr(fnShowGBAccount(curUserInfo,StreamNew));
                Stream.WriteLongStr(fnFooter(curUserInfo));
              end else begin
                setErrorStrs(curUserInfo,StreamNew,Stream);
              end;
            end;
            if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'type')='102') then   begin
              nmProc := 'prShowGBOutInvoice'; // ��� ���������/�������
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(isWe);
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'code'));
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'emplid')));
              prShowGBOutInvoice(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                OnReadyScript:='';
                globToHeader:='';
                globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
                globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
                globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
                curUserInfo.PageName:=curUserInfo.strOther.Values['act']+'_gbinvoice';
                curUserInfo.NeedCalendar:=true;
                Stream.WriteInt(aeSuccess);
                Stream.WriteLongStr(fnHeader(curUserInfo));
                Stream.WriteLongStr(fnShowGBOutInvoice(curUserInfo,StreamNew));
                Stream.WriteLongStr(fnFooter(curUserInfo));
              end else begin
                setErrorStrs(curUserInfo,StreamNew,Stream);
              end;
            end
          end

          else if (curUserInfo.strOther.Values['act']='motulsite') then begin
            StreamNew.Clear;
            nmProc := 'prMotulSitePage'; // ��� ���������/�������
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofpage'),mspAllActs));
            prMotulSitePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.NeedCalendar:=true;
              curUserInfo.NeedTinyMCEAction:=true;
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnShowMotulSitePage(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofpage')));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='motulsitetab') then begin
            StreamNew.Clear;
            nmProc := 'prMotulSitePage'; // ��� ���������/�������
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofpage'),mspAllActs));
            prMotulSitePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofpage')='4') then begin
                Stream.WriteInt(aeSuccessLong);
                Stream.WriteLongStr(fnShowMotulSitePage(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofpage'),false));
              end
              else begin
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(fnShowMotulSitePage(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofpage'),false));
              end;
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end


          else if (curUserInfo.strOther.Values['act']='motulsitemanage') then begin
            StreamNew.Clear;
            nmProc := 'prMotulSiteManage'; // ��� ���������/�������
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation')));
            if (StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation'))=mspDelAct) then
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-code')));
            if (StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation'))=mspDelPLine) then
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware-code')));
            if (StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation'))=mspAddAct) then  begin
               StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-header')));
               try
                 DateBegin:=StrToDate(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-fromdate'));
               except
                 setErrorCommandStr(StreamNew,'������������ ���� ������ �����');
               end;
               try
                 DateEnd:=StrToDate(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-todate'));
               except
                 setErrorCommandStr(StreamNew,'������������ ���� ��������� �����');
               end;
               StreamNew.WriteDouble(DateBegin);
               StreamNew.WriteDouble(DateEnd);
               StreamNew.WriteLongStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'tinyeditorinfo')));
            end;
            if (StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation'))=mspEditAct) then  begin
               OperationCode:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-code'),0);
               StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-code'),0));
               StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-header')));
               StreamNew.WriteLongStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'tinyeditorinfo')));
               if (OperationCode in [mspResumeCode, mspInfoCode]) then   begin
                 StreamNew.WriteDouble(0);
                 StreamNew.WriteDouble(0);
               end
               else begin
                 try
                   DateBegin:=StrToDate(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-fromdate'));
                 except
                   setErrorCommandStr(StreamNew,'������������ ���� ������ �����');
                 end;
                 try
                   DateEnd:=StrToDate(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-todate'));
                 except
                   setErrorCommandStr(StreamNew,'������������ ���� ��������� �����');
                 end;
                 StreamNew.WriteDouble(DateBegin);
                 StreamNew.WriteDouble(DateEnd);
               end;
            end;
            if (StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation'))=mspEditPLine) then  begin
               StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'ware-code'),0));
               StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-header')));
               StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'join-action-code'),0));
            end;
            if (StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'kindofoperation'))=mspAddPLine) then  begin
               StreamNew.WriteStr(UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'action-header')));
               StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'join-action-code'),0));
               StreamNew.WriteInt(0);
            end;
            prMotulSiteManage(StreamNew,ThreadData);
            StreamNew.Position:= 0;
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetMotulSiteManageResult(StreamNew,curUserInfo));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='savebranddetails') then begin
            StreamNew.Clear;
            nmProc := 'prLogotypeEdit'; // ��� ���������/�������
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'code'));
            flag:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'hideinprice'))='on';
            if flPictNotShow then
              NotPictShow:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'hidepintTD'))='on';
            StreamNew.WriteInt(StrToInt(s));
            StreamNew.WriteStr(Utf8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'brandwww'))));
            StreamNew.WriteStr(Utf8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'brandshort'))));
            StreamNew.WriteStr(Utf8ToAnsi(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'brandaddrwww'))));
            StreamNew.WriteBool(flag);
            if flPictNotShow then
              StreamNew.WriteBool(NotPictShow);
            prLogotypeEdit(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnSaveBrandDetails(StreamNew,curUserInfo,s,flag,NotPictShow));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='import') then begin
            nmProc := 'prImportPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prImportPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.NeedCalendar:=true;
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmImport(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='notifications') then begin
            nmProc := 'prWebArmGetNotificationsParams'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prNotificationPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.NeedCalendar:=true;
              s:=fnGetWebArmNotificationsPart1(StreamNew);
              nmProc := 'prWebArmGetNotificationsParams'; // ��� ���������/�������
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(0);
              prWebArmGetNotificationsParams(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                s:=s+fnGetWebArmNotificationsPart2(curUserInfo,StreamNew);
                Stream.WriteInt(aeSuccess);
                Stream.WriteLongStr(fnHeader(curUserInfo));
                Stream.WriteLongStr(s);
                Stream.WriteLongStr(fnFooter(curUserInfo));
              end else begin
                setErrorStrs(curUserInfo,StreamNew,Stream);
              end;
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='sysoptions') then begin
            nmProc := 'prShowSysOptionsPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prShowSysOptionsPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.NeedCalendar:=true;
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmSysOptions(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='accountsreestr') then begin
            nmProc := 'prAccountsReestrPage'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prAccountsReestrPage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              curUserInfo.NeedCalendar:=true;
              curUserInfo.NeedDropFirmList:=true;
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmAccounts(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end


          else if (curUserInfo.strOther.Values['act']='options') then begin
            nmProc := 'prAccountsReestrPage'; // ��� ���������/�������
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            Stream.WriteInt(aeSuccess);
            Stream.WriteLongStr(fnHeader(curUserInfo));
            Stream.WriteLongStr(fnGetWebArmOptions(curUserInfo));
            Stream.WriteLongStr(fnFooter(curUserInfo));
          end


           else if (curUserInfo.strOther.Values['act']='webarmusers') then begin
            nmProc := 'prShowWebArmUsers'; // ��� ���������/�������
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prShowWebArmUsers(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              OnReadyScript:='';
              globToHeader:='';
              globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmUsers(curUserInfo,StreamNew));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='mpp') then begin
            nmProc := 'mpp'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            Stream.WriteInt(aeSuccess);
            Stream.WriteLongStr(fnHeader(curUserInfo));
            Stream.WriteLongStr(fnWriteSimpleText(fnGetWebArmMPP(curUserInfo,StreamNew)));
            Stream.WriteLongStr(fnFooter(curUserInfo));
          end

          else if (curUserInfo.strOther.Values['act']='order') then begin
            nmProc := 'order'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            Stream.WriteInt(aeSuccess);
            Stream.WriteLongStr(fnHeader(curUserInfo));
            Stream.WriteLongStr(fnGetWebArmOrders(curUserInfo,StreamNew));
            Stream.WriteLongStr(fnFooter(curUserInfo));
          end


          else if (curUserInfo.strOther.Values['act']='dirmodmoto') then begin
            nmProc := 'prTNAManagePage'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Stream.WriteByte(constIsMoto);
            prTNAManagePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnWriteSimpleText(fnGetWebArmDirModelPage(constIsMoto,curUserInfo.PageName,StreamNew)));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end
            else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='dirmodauto') then begin
            nmProc := 'prTNAManagePage'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Stream.WriteByte(constIsMoto);
            prTNAManagePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnWriteSimpleText(fnGetWebArmDirModelPage(constIsAuto,curUserInfo.PageName,StreamNew)));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end
            else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='treemoto') then begin
            nmProc := 'prTNAManagePage'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Stream.WriteByte(constIsMoto);
            prTNAManagePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnWriteSimpleText(fnGetWebArmTNAManagePage(curUserInfo.UserID,constIsMoto,StreamNew,ThreadData)));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end
            else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='treeauto') then begin
            nmProc := 'prTNAManagePage'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Stream.WriteByte(constIsAuto);
            prTNAManagePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnWriteSimpleText(fnGetWebArmTNAManagePage(curUserInfo.UserID,constIsAuto,StreamNew,ThreadData)));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end
            else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='treemotul') then begin
            nmProc := 'prTNAManagePage'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Stream.WriteByte(cbrMotul);
            prTNAManagePage(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnWriteSimpleText(fnGetWebArmTNAManagePage(curUserInfo.UserID,cbrMotul,StreamNew,ThreadData)));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end
            else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end



          else if (curUserInfo.strOther.Values['act']='mppregord') then begin
            nmProc := 'mppregord'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            curUserInfo.NeedCalendar:=true;
            Stream.WriteInt(aeSuccess);
            Stream.WriteLongStr(fnHeader(curUserInfo));
            Stream.WriteLongStr(fnGetWebArmMPPRegOrdPage(curUserInfo,StreamNew));
            Stream.WriteLongStr(fnFooter(curUserInfo));
          end

          else if (curUserInfo.strOther.Values['act']='mppregzones') then begin
            nmProc := 'prGetFilialList'; // ��� ���������/�������
            Stream.Clear;
            OnReadyScript:='';
            globToHeader:='';
            globToHeader:=globToHeader+'<link rel="stylesheet" type="text/css" href="/product.css'+(*floatTostr(random)+*)'">'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/product.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            globToHeader:=globToHeader+'<script language=JavaScript src="/accounts.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
            curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            prGetFilialList(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeader(curUserInfo));
              Stream.WriteLongStr(fnGetWebArmMPPRegZonesPage(curUserInfo.UserID,StreamNew,ThreadData));
              Stream.WriteLongStr(fnFooter(curUserInfo));
            end
            else begin
              setErrorStrs(curUserInfo,StreamNew,Stream);
            end;
          end





        end else if result=aeResetPassword then begin
          curUserInfo.MustChangePass:=true;
          //curUserInfo.UserID:=IntToStr(Stream.ReadInt);

        end else begin
          if (curUserInfo.strOther.Values['kindofrequest']='page') then   begin
            OnReadyScript:='';
            Stream.Clear;
            Stream.WriteInt(aeCommonError);
            s:=fnHeader(curUserInfo,false);
            Stream.WriteLongStr(s);
            s:=nonAutenticatedMessage(false, false);
            Stream.WriteStr(fnWriteSimpleText(s));
            Stream.WriteLongStr(fnFooter(curUserInfo));
        end
        else if (curUserInfo.strOther.Values['kindofrequest']='command') then begin
              if (curUserInfo.strOther.Values['act']='quit') then begin //
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                s:='';
                s:=s+'setCookie_("sid", "", getExpDate_(0,0,0),"/",0,0);'#13#10;
                s:=s+'s=document.location.href;'#13#10;
                s:=s+'s=(s.substr(s.length-1)==''#'')?s.substr(0, s.length-1):s;'#13#10;
                s:=s+'document.location.href=s;';
                Stream.WriteStr(s);
              end
              else
                setErrorCommandStr(Stream,curUserInfo.Error);
              end;
            end;
    end else begin
      if (curUserInfo.strOther.Values['kindofrequest']='page') then   begin
        OnReadyScript:='';
        Stream.Clear;
        Stream.WriteInt(aeCommonError);
        s:=fnHeader(curUserInfo,false);
        Stream.WriteLongStr(s);
        Stream.WriteStr(fnWriteSimpleText('������� � ������� ������ ����� ���� ����� � ������.'));
        Stream.WriteLongStr(fnFooter(curUserInfo));
      end
      else if (curUserInfo.strOther.Values['kindofrequest']='command') then begin
        Stream.Clear;
        Stream.WriteInt(aeCommonError);
        Stream.WriteStr(' jqswMessageError(''����������� ����� ��� ������.'');');
      end;

    end;


  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  StreamNew.Free;
  curUserInfo.strPost.Free;
  curUserInfo.strGet.Free;
  curUserInfo.strCookie.Free;
  curUserInfo.strOther.Free;
  Stream.Position:= 0;

  end;


end.
