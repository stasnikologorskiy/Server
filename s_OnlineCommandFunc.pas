unit s_OnlineCommandFunc;

interface

uses Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
     DB, IBDatabase, IBSQL, IBQuery,
     n_free_functions, v_constants, v_Functions, v_DataTrans,
     n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common,IniFiles, HTTPApp,s_Utils,JPEG,EncdDecd;

function fnOpenOrdersList(Stream: TBoBMemoryStream;ordrcode,warecode,wareqty,inline_,contract,dialogname:String): string;
function fnfillParametrsAllOrder(Stream: TBoBMemoryStream): string;   //���������� ��� ���������� ���� ������ ���� ������ ��� ��� ��������
function fnsaveParametrsFromOrder(Stream: TBoBMemoryStream;v: integer;kindSave: integer;deliverydatetext:String; deliverydate: String): string;   //���������� ��� ���������� ������ ���� ������
function fngetNewBankAccountParams(Stream: TBoBMemoryStream) :String;
function fnsaveNewBankAccountParams(Stream: TBoBMemoryStream;ScriptName:String;IsFromInfo:boolean=false):String;
function fnWareSearch(var userInf:TUserInfo; Stream: TBoBMemoryStream;var LogText: string;groups:String;waresearch:String;ignorspec:String;one_line_mode:String;forfirmid:String;Template: string): string;
function fnGetSatellites(var userInf:TUserInfo; Stream: TBoBMemoryStream;id: String): string;
function fnGetNodeWares(Stream:TBoBMemoryStream; var userInf:TUserInfo;ScriptName:String): string;
function fnSendWareList(var userInf:TUserInfo; Stream: TBoBMemoryStream; var Wares: string; ErrMessKind: integer; suffix: string=''): string;
function fnGetWaresByAttr(var userInf:TUserInfo;Stream: TBoBMemoryStream ): string;
function fnGetAnalogs(var userInf:TUserInfo; Stream: TBoBMemoryStream;id: String; is_on:String): string;
function fnGetQtyByAnalogsAndStorages(Stream: TBoBMemoryStream;bonus:String; ordr:String): string;
function fnaddLinesToOrder(Stream: TBoBMemoryStream;ScriptName:String;contract:String):String;
function fnOpenOrdersListRedisign(Stream: TBoBMemoryStream;ordrcode,warecode,wareqty,inline_,contract,dialogname:String): string;  // ���������� ������ �������� ������� ��� ������� �� ������ ��������
function fnOpenOrdersListQtyRedisign(Stream: TBoBMemoryStream;strPost,strGet:TStringList): string;  // ���������� ������ �������� ������� ��� ������� �� ������ �������� �� ����� �������� �-��
function fngetMeetPersonsList(Stream: TBoBMemoryStream;id: String;value: String): string;  //��������� ������ �����������
function fnGetNodeWares_Motul(Stream:TBoBMemoryStream; var userInf:TUserInfo;ScriptName:String): string;
function fnCreateNewUser(Stream:TBoBMemoryStream; var userInf:TUserInfo) :string;// ������ ���������. �������� ������������
function fnGetContractList(Stream:TBoBMemoryStream;edit:String; ContractId:integer) :string;// ���� ������ ����������
function fnGetDestPointParams(Stream:TBoBMemoryStream) :string;// ���� ������ �������� �����
function fnGetObm_JMAction(Stream:TBoBMemoryStream;ScriptName:string):string;

implementation
uses s_OnlineProcedures, n_CSSThreads,n_WebArmProcedures,t_function,s_CommandFunc;

function fnGetAnalogs(var userInf:TUserInfo; Stream: TBoBMemoryStream;id: String; is_on:String): string;
var
  s, WareCode, Wares: string;
  WareCount, i: integer;
begin
  s:='';
  Wares:='-1';
  WareCode:=trim(id);
  WareCount:=Stream.ReadInt;
  if wareCount=0 then begin
    s:='jqswMessage(''�� ��������� ������ �������� �� �������.'');';
    Stream.ReadStr;
  end else begin
    s:=s+#13#10'var tbl; var i; var WareCode; '#13#10;
    s:=s+'pao('+WareCode+', '+is_on+');'#13#10;
    s:=s+'var MasterIsOn='+is_on+';'#13#10;
    s:=s+'var ii=0;'#13#10;
    s:=s+'var qvColPrice='+IntToStr(Length(arPriceColNames))+';'#13#10;
    s:=s+'var arColHeaders= []; ' ;
    s:=s+'var arColHeadersTitle=[]; ';
    for i := 0 to Length(arPriceColNames)-1 do  begin
       s:=s+'arColHeaders['+IntToStr(i)+']="'+arPriceColNames[i].ColName+'";';
       s:=s+'arColHeadersTitle['+IntToStr(i)+']="'+arPriceColNames[i].FullName+'";';
    end;
    for i:=0 to wareCount-1 do begin
      s:=s+fnGetAnalogForSearch(Stream, userInf.FirmId=IntToStr(isWe), Wares,WareCode);
    end;
    s:=s+'ssr();'#13#10;
    s:=s+'var aaa=$(''#analog_'+fnIfStr(is_on='0','w_','on_')+WareCode+''');'#13#10;
    s:=s+'aaa.css("backgroundImage", "url(''/images/wac.png'')");'#13#10;
    s:=s+'aaa.attr("title", "������ �������");'#13#10;
    s:=s+'checkListWaresForFind ();'#13#10;
    s:=s+' setActionTooltip();'#13#10;
    s:=s+' setActionTooltip();'#13#10;
    s:=s+'setFindFilter(1);'#13#10;
  end;
  Result:=s;
end; //fnGetAnalogs


function fnGetSatellites(var userInf:TUserInfo; Stream: TBoBMemoryStream;id: String): string;
var
  s, WareCode, Wares: string;
  WareCount, i: integer;
begin
  s:='';
  Wares:='-1';
  WareCode:=trim(id);
  WareCount:=Stream.ReadInt;
  if wareCount=0 then begin
    s:='jqswMessage(''� ��������� ������ �� ������� ������������� ������.'');';
  end else begin
    s:=s+'var qvColPrice='+IntToStr(Length(arPriceColNames))+';'#13#10;
    s:=s+'var arColHeaders= []; ' ;
    s:=s+'var arColHeadersTitle=[]; ';
    for i := 0 to Length(arPriceColNames)-1 do  begin
      s:=s+'arColHeaders['+IntToStr(i)+']="'+arPriceColNames[i].ColName+'";';
      s:=s+'arColHeadersTitle['+IntToStr(i)+']="'+arPriceColNames[i].FullName+'";';
    end;
    s:=s+#13#10'var tbl; var i; var WareCode; '#13#10;
    s:=s+'var lastline=$("tr[id^=''an'+WareCode+'_'']:last")[0];'#13#10;
    s:=s+'if (!lastline) lastline=$("#tr'+WareCode+'")[0];'#13#10;
    s:=s+'baserow=lastline.rowIndex;'#13#10;
    s:=s+'WareCode='+WareCode+';'#13#10;
    s:=s+'tbl=$("#WSRtablecontent")[0];'#13#10;
    s:=s+'i=0;'#13#10;
    s:=s+'var MasterIsOn=false;'#13#10;
    s:=s+'var ii=0;'#13#10;
    for i:=0 to wareCount-1 do begin
      s:=s+fnGetAnalogForSearch(Stream, userInf.FirmId=IntToStr(isWe), Wares,WareCode, 1);
    end;
    s:=s+'ssr();'#13#10;
    s:=s+'var aaa=$(''#sat_w_'+WareCode+''');'#13#10;
    s:=s+'aaa.css("backgroundImage", "url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), userInf.DescrImageUrl, '')+'/images/wsc.png'')");'#13#10;
    s:=s+'aaa.attr("title", "������ ������������� ������");'#13#10;
    s:=s+'setcomparebtnvis();'#13#10;
    s:=s+'checkListWaresForFind ();'#13#10;
    s:=s+' setActionTooltip();'#13#10;
  end;
  Result:=s;
end; //fnGetSatellites

function fnSendWareList(var userInf:TUserInfo; Stream: TBoBMemoryStream; var Wares: string; ErrMessKind: integer; suffix: string=''): string;
var
  WareCode, s: string;
  AnalogCount, i, j,k : integer;
  ShowAnalogs: boolean;
begin
  s:=s+'var s='''';'#13#10;
  s:=s+'var i=0;'#13#10;
  s:=s+'var altrow=false;'#13#10;
  s:=s+'filtersuff='''+suffix+''';'#13#10;
  s:=s+'var qvColPrice='+IntToStr(Length(arPriceColNames))+';'#13#10;
  s:=s+'var arColHeaders= []; ' ;
  s:=s+'var arColHeadersTitle=[];'#13#10;
   for k := 0 to Length(arPriceColNames)-1 do  begin
    s:=s+'arColHeaders['+IntToStr(k)+']="'+arPriceColNames[k].ColName+'";'#13#10;
    s:=s+'arColHeadersTitle['+IntToStr(k)+']="'+arPriceColNames[k].FullName+'";'#13#10;
  end;

  s:=s+'arrFindResRed.length=0;';
  s:=s+'arrFindResGreen.length=0;';
  s:=s+'arrFindResNone.length=0;';
  s:=s+'arrFindAnalogGreen.length=0;';
  s:=s+'arrFindAnalogRed.length=0;';
  s:=s+'arrFindAnalogNone.length=0;';
  s:=s+'arrAnalogCodeGener.length=0;';
  s:=s+'arrSateliteCodeGener.length=0;';
  s:=s+'arrFindResOriginal.length=0;'#13#10;
  s:=s+'arrFindSateliteGreen.length=0;';
  s:=s+'arrFindSateliteRed.length=0;';
  s:=s+'arrFindSateliteNone.length=0;';
  s:=s+'arrFindResCheck.length=0;';
  s:=s+'tbl=dwsth_('''+GetHTMLSafeString(Stream.ReadStr)+''');'#13#10;
  //s:=s+'var qvColPrice=0;'#13#10;
  // ��������� ������
  ShowAnalogs:=Stream.ReadBool;
  j:=Stream.ReadInt;
  for i:=0 to j-1 do begin
    s:=s+fnGetWareForSearch(Stream, -100, 'WSRtablecontent', WareCode, AnalogCount, Wares, userInf.FirmId=IntToStr(isWe));
    if ShowAnalogs then begin  //���� ����� ���������� ������� ����� � ��� ����, �� ����������
      if AnalogCount>0 then begin
        s:=s+'var MasterIsOn=0;'#13#10;
        s:=s+'var ii=0;'#13#10;
        s:=s+'pao('+WareCode+', 0);'#13#10;
        for j:=0 to  AnalogCount-1 do begin
          s:=s+fnGetAnalogForSearch(Stream, userInf.FirmId=IntToStr(isWe), Wares,WareCode);
        end;
        s:=s+'document.getElementById("analog_w_'+WareCode+'").style.backgroundImage="url(''/images/wac.png'')";'#13#10;
      end;
    end;
  end;
  s:=s+'ssr();'#13#10;
  s:=s+'$.fancybox.close(true);'#13#10;
  s:=s+'$(".fw").fancybox({ajax: ''post''});'#13#10;
  s:=s+'setcomparebtnvis();'#13#10;
  s:=s+'checkListWaresForFind ();'#13#10;
  s:=s+' setActionTooltip();'#13#10;

  result:=s;
end; //fnSendWareList


function fnGetWaresByAttr(var userInf:TUserInfo;Stream: TBoBMemoryStream ): string;
var
  s, Wares: string;
  i, WareCount, Pos: integer;
begin
  s:='';
  Wares:='';
  s:=s+'drawattrseltitle();'#13#10;
  s:=s+fnSendWareList(userInf,Stream, Wares, constWrongAttribute);
  //if not flNewSearchLine then
  //  s:=s+fnGetModelApplicability(Stream, Wares, FirmId=IntToStr(isWe), (FirmId=IntToStr(isWe)) and (Request.CookieFields.Values['one_line_mode']<>'true') and (fnInIntArray(rolOPRSK, Roles)>-1) and (StrToIntDef(fnGetField(Request, 'forfirmid'),0)>0));
  s:=s+'$("#podbortabs").dialog("close");'#13#10;
  s:=s+'checkListWaresForFind ();'#13#10;
  s:=s+'setFindFilter();'#13#10;
  Result:=s;
end; //fnGetWaresByAttr

function fnGetNodeWares(Stream:TBoBMemoryStream; var userInf:TUserInfo;ScriptName:String): string;
var
  s, s1, s2, temp, NodeName, Wares: string;
  filter:String;
  Count, TypeSys: integer;
begin
  Wares:='';
  TypeSys:=Stream.ReadInt;
  if (TypeSys=constIsMoto) then begin
    s2:=', \"selbymodeltreediv\", \"selbymodelmotoobj\", \"sel\"';
  end else
    if (TypeSys=constIsAuto) then begin
      s2:=', \"selbymodeltreedivauto\", \"selbymodelautoobj\", \"sel_auto\"';
    end  else begin
      s2:=', \"selbymodeltreedivautoengine\", \"selbymodelauenobj\", \"sel_auen\"';
    end;
  s1:=Stream.ReadStr;
  if (Stream.ReadBool) then begin//    // ���� �� ������ ����� �������� ������ ��������
    s:=s+'var NodeWithModel="&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'";'#13#10;
  end else begin
    s:=s+'var NodeWithModel="";'#13#10;
  end;
  s:=s+'searchmodelcode="'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'";'#13#10;

  NodeName:=Stream.ReadStr;
  filter:=Stream.ReadStr;
  s:=s+'$("#WSRwrapper h1").html("���������� ������� ������ �� ���� <span id=''modelnodesearch_node'' _code='''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'''>'+GetHTMLSafeString(NodeName)+'</span> '+
       fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', '���������', '������')+' <a id=''modelnodesearch_engine''  _code='''+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'true', 'false')+''' '+
       'href=# onclick=''showmodtree('+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+s2+');''><span id=''modelnodesearch_model'' _code='''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'''>'+s1+'</span></a>'+
       fnIfStr(filter='', '', ' � �������� �� ����� ��������� <a href=# onclick=''ec(\"showfilter\", \"model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&pref='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')+'\", \"newbj\");''><span id=''#modelnodesearch_filter'' _code='''+trim(fnGetFieldStrList(userInf.strPost,userinf.strGet,'filter'))+'''>'+filter+'</span></a>')+
       '")'#13#10;
  s:=s+fnSendWareList(userInf,Stream, Wares, fnIfInt(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', constWrongEngineNode, constWrongModelNode), '&model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&eng='+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'true', 'false')+'&filter='+filter);
  // ������ �������� ��������� �� �������
  Count:=Stream.ReadInt;
  s:=s+'arrFindResInfoIcon.length=0;'#13#10;
  while (Count>0) do begin
    s1:=IntToStr(Stream.ReadInt);
    temp:=Stream.ReadStr;
    temp:=GetHTMLSafeString(temp, true);
    temp:=fnDeCodeBracketsInWeb(temp);
    s2:='';
    s2:=s2+' arrFindResInfoIcon[arrFindResInfoIcon.length]=';
    s2:=s2+'{WareCode: '+s1+',TitleText: '''+GetJSSafeStringArg(temp)+''',Href: '''+ScriptName+''',model:'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+', ';
    s2:=s2+' node: '+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+',eng: '+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'true', 'false')+', filter: '''+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'filter')='','0',fnGetFieldStrList(userInf.strPost,userinf.strGet,'filter'))+''',' ;
    s2:=s2+' bonus: false ,';

    s:=s+'descrdiv=$("#tr'+s1+' .descrdiv")[0];'#13#10;
    s:=s+'if (descrdiv) { '#13#10;
    //nclick="return viewWareSearchDialog(this);" href="'+Request.ScriptName+'/wareinfo?id='+CurWareCode+'&model=
    //&node=&eng=&filter=" target="_blank" warecode="'+CurWareCode+'" style="color: #000;">
    s:=s+'  descrdiv.innerHTML="<a  target=''_blank'' warecode='''+s1+''' onclick=''return viewWareSearchDialog(this);''  class=''ahint1 '' '+
         ' href='''+ScriptName+'/wareinfo?id='+s1+'&model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&eng='+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'true', 'false')+'&filter='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'filter')+'&bonus=false'+''' title='''+GetHTMLSafeString(temp)+''' style=''color: #000;''><img src=/images/attention.png ></a> "+descrdiv.innerHTML;'#13#10;
    s:=s+'}'#13#10;
    s2:=s2+'isWA: 0};'#13#10;
    s:=s+s2;
    Dec(Count);
  end;
  s:=s+'$(".ahint1").easyTooltip();'#13#10;
  s:=s+'$(".ahint1").fancybox({ajax: ''post'',  helpers: {title:  null}});'#13#10;
  s:=s+'$("#podbortabs").dialog("close");'#13#10;
  s:=s+'checkListWaresForFind ();'#13#10;
  s:=s+'$("#warenodefilterdialog").dialog("close");'#13#10;
  //if not flNewSearchLine then
  //  s:=s+fnGetModelApplicability(Stream, Wares, FirmId=IntToStr(isWe), ((FirmId=IntToStr(isWe)) and (Request.CookieFields.Values['one_line_mode']<>'true') and (fnInIntArray(rolOPRSK, Roles)>-1) and (StrToIntDef(fnGetField(Request, 'forfirmid'),0)>0)));
  Result:=s;
end; // fnGetNodeWares



function fnWareSearch(var userInf:TUserInfo; Stream: TBoBMemoryStream;var LogText: string;groups:String;waresearch:String;ignorspec:String;one_line_mode:String;forfirmid:String;Template: string): string;
var
  s, s1, s2, CurWareCode, WareCode, currency,Brand,WareName,WareFullName,Code : string;
  WareCount, OrNumCount, i, j, AnalogCount: integer;
  ShowAnalogs, NeedTypes: boolean;
  Wares: string;
  IgnoreSpec: byte;
  ae:integer;

begin
  s:='';
  s1:='';
  s2:='';
  Wares:='-1';
  try
    NeedTypes:=Stream.ReadBool;
    if not NeedTypes then begin // ���� ������� ������ ������������� ��������, �� �������� ������������� ����� � �� ���������� ������
      Currency:=Stream.ReadStr;
      ShowAnalogs:=Stream.ReadBool;
      WareCount:=Stream.ReadInt;
      if (IgnoreSpec=coLampBaseIgnoreSpec) then begin
         s:=s+'$("#WSRwrapper h1").html("���������� ������� ���� <span>'''+GetHTMLSafeString(Template)+'''</span>");'#13#10;
      end else begin
         s:=s+'$("#WSRwrapper h1").html("���������� ������ �� ������ <span>'''+GetHTMLSafeString(Template)+'''</span>");'#13#10;
      end;
      s:=s+'var qvColPrice='+IntToStr(Length(arPriceColNames))+';'#13#10;
      s:=s+'var arColHeaders= []; ' ;
      s:=s+'var arColHeadersTitle=[]; ';
      s:=s+'arrFindAnalogGreen.length=0;';
      s:=s+'arrFindAnalogRed.length=0;';
      s:=s+'arrFindAnalogNone.length=0;';
      s:=s+'arrAnalogCodeGener.length=0;';
      s:=s+'arrFindResRed.length=0;';
      s:=s+'arrFindResGreen.length=0;';
      s:=s+'arrFindResNone.length=0;';
      s:=s+'arrFindResOriginal.length=0;';

      for i := 0 to Length(arPriceColNames)-1 do  begin
        s:=s+'arColHeaders['+IntToStr(i)+']="'+arPriceColNames[i].ColName+'";';
        s:=s+'arColHeadersTitle['+IntToStr(i)+']="'+arPriceColNames[i].FullName+'";';
      end;
      //s:=s+'var qvColPrice=0;'#13#10;
      s:=s+'tbl=dwsth_('''+GetHTMLSafeString(Currency)+''');'#13#10;
      s:=s+'var s='''';'#13#10;
      s:=s+'var i=0;'#13#10;
      s:=s+'var altrow=false;'#13#10;
      s1:='';
      // ��������� ������
      for i:=0 to WareCount-1 do begin
        s:=s+fnGetWareForSearch(Stream, -100, 'WSRtablecontent', WareCode, AnalogCount, Wares, userInf.FirmId=IntToStr(isWe));
        if ShowAnalogs then begin  //���� ����� ���������� ������� ����� � ��� ����, �� ����������
          if AnalogCount>0 then begin
            s1:=s1+'var MasterIsOn=0;'#13#10;
            s1:=s1+'var ii=0;'#13#10;
            s1:=s1+'pao('+WareCode+', 0);'#13#10;
            for j:=0 to  AnalogCount-1 do begin
              s1:=s1+fnGetAnalogForSearch(Stream, userInf.FirmId=IntToStr(isWe), Wares,WareCode);
            end;
            s1:=s1+'document.getElementById("analog_w_'+WareCode+'").style.backgroundImage="url(''/images/wac.png'')";'#13#10;
          end;
        end;
      end;

      // ��������� ������������ ������
      OrNumCount:=Stream.ReadInt;
      for i:=0 to OrNumCount-1 do begin
        CurWareCode:=IntToStr(Stream.ReadInt);
        WareCode:=CurWareCode;
        Code:=IntToStr(Stream.ReadInt);
        Brand:=GetJSSafeString(Stream.ReadStr);
        WareName:= GetJSSafeString(Stream.ReadStr);
        WareFullName:=GetJSSafeString(Stream.ReadStr);
        s:=s+'awstl_on('+CurWareCode+', '+Code+', '''+Brand+''', '''
            +WareName+''', '''+WareName+''');'#13#10;
        s:=s+' arrFindResOriginal[arrFindResOriginal.length]=';
        s:=s+'{CurWareCode: '+CurWareCode+', Code:'+Code+', ';
        s:=s+'Brand: "'+Brand+'", '              //  Brand
            +'WareName: "'+WareName+'", '    //  WareShortName
            +'WareFullName: "'+WareFullName+'" };'#13#10;

        if ShowAnalogs then begin  //���� ����� ���������� ������� ����� � ��� ����, �� ����������
          AnalogCount:=Stream.ReadInt;
          if AnalogCount>0 then begin
            s1:=s1+'pao('+WareCode+', 1);'#13#10;
            s1:=s1+'var MasterIsOn=1;'#13#10;
            s1:=s1+'var ii=0;'#13#10;
            for j:=0 to  AnalogCount-1 do begin
              s1:=s1+fnGetAnalogForSearch(Stream, userInf.FirmId=IntToStr(isWe), Wares,WareCode);
            end;
            s1:=s1+'document.getElementById("analog_on_'+WareCode+'").style.backgroundImage="url(''/images/wac.png'')";'#13#10;
          end;
        end;
      end;
      s:=s+s1;
      s:=s+'ssr();'#13#10;
      s:=s+'$(''#WSRcontentdiv'').scrollTop(0);'#13#10;
      s:=s+'$(".fw").fancybox({ajax: ''post''});'#13#10;
      s:=s+'$.fancybox.close();'#13#10;
      s:=s+'setcomparebtnvis();'#13#10;
      if (groups='') then begin
        s:=s+'$(''#WSRtablecontent'').attr(''lastwaresearch'', '''+waresearch+''');'#13#10;
      end;

      LogText:=('����="'+Template+'" �����='+fnIfStr(ignorspec='unchecked', '����', '���')+' ���-��_���='+IntToStr(wareCount+OrNumCount)+' �����="'+groups+'"');
    end else begin  //  ���������� �� ������, � ������ ��� ���������
      WareCount:=Stream.ReadInt;
      s1:='';
      s1:=s1+'<div style=''font-size: 12px;''>������� ������� - '+IntToStr(WareCount)+'. ��� ��������� ������� �������� ��� ������.<hr /></div>';
      s1:=s1+'<div id=waregrouplistdiv>';
      WareCount:=Stream.ReadInt;
      for i:=0 to WareCount-1 do begin
        if (I>0) then s1:=s1+'<br />';
          s1:=s1+'<input type=checkbox value='+IntToStr(Stream.ReadInt)+'> '+GetJSSafeString(Stream.ReadStr);
        end;
        s1:=s1+'</div>'; // s1:=s1+'<div id=waregrouplistdiv>';
        s1:=s1+'<div class=bottombuttonsdiv><input type=button value=''��������'' onclick=searchwaresbygroup();> <input type=button value=''�������''onclick=''$.fancybox.close();''></div>';
        s:=s+'sw("'+s1+'");'#13#10;
        s:=s+'var h=window.innerHeight-130;'#13#10;
        s:=s+'if (h<38) {'#13#10;
        s:=s+'  h=38;'#13#10;
        s:=s+'} else {'#13#10;
        s:=s+'  if (h>'+IntToStr(WareCount*19)+') {'#13#10; // 19 �������� - ������ ������
        s:=s+'    h='+IntToStr(WareCount*19)+';'#13#10;
        s:=s+'  }'#13#10;
        s:=s+'}'#13#10;
        s:=s+'$(''#waregrouplistdiv'').height(h);'#13#10;
        LogText:='�-�� ����� ������� - '+IntToStr(WareCount);
      end;
        s:=s+'$("#podbortabs").dialog("close");'#13#10;
        s:=s+'checkListWaresForFind ();'#13#10;
        s:=s+' setActionTooltip();'#13#10;
        s:=s+'setFindFilter();'#13#10;
  finally
    Result:=s;
  end;
end; // fnWareSearch




function fnOpenOrdersList(Stream: TBoBMemoryStream;ordrcode,warecode,wareqty,inline_,contract,dialogname:String): string;  // ���������� ������ �������� ������� ��� ������� �� ������ ��������
var
  s, s1,s2,CurOrderID,WarningMessage,ComentSum: string;
  OrdersCount, i, ii,CurContractID: integer;
  Commentary, CurContractName,orderDate,orderSum,orderCurrency,orderNum: string;
begin
  s:='';
  try
    WarningMessage:=Stream.ReadStr;
    OrdersCount:=Stream.ReadInt;
    if OrdersCount>0 then   begin
      if WarningMessage<>'' then begin
         i:=Pos(',',WarningMessage);
         s1:=Copy(WarningMessage,1,i);
         s2:=Copy(WarningMessage,i+1,Length(WarningMessage));
         s:=s+'<div class="warnmesorddiv">'+s1+'</div>';
         s:=s+'<div class="warnmesorddiv">'+s2+'</div>';
      end;
      s:=s+'<table class=st style="white-space: nowrap; font-size: 11px;">';
      s:=s+'<tr style="font-size: 14px;" class="grayline">';
      s:=s+'<td>���� ������</td>';
      s:=s+'<td>����� ������</td>';
      s:=s+'<td>��������</td>';
      s:=s+'<td>����� ������</td>';
      s:=s+'<td>������</td>';
      s:=s+'<td>�������</td>';
      s:=s+'</tr>';
      for i := 0 to OrdersCount-1 do begin
        CurOrderID:=IntToStr(Stream.ReadInt);
        CurContractID:=Stream.ReadInt;
        CurContractName:=Stream.ReadStr;
        orderDate:=Stream.ReadStr;
        orderNum:=Stream.ReadStr;
        ComentSum:=Stream.ReadStr;
        orderSum:=Stream.ReadStr;
        orderCurrency:=Stream.ReadStr;
        Commentary:=Stream.ReadStr;
        //s:=s+'<tr onclick=\'''+fnIfStr(dialogname='','','$("#'+dialogname+'").dialog("close");')+'  '+fnIfStr(inline_='true','parent.','')+'document.location.href="'+ScriptName+'/order?order='+CurOrderID+'"; ec("linefromsearchtoorder", "ordr='+CurOrderID+'&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+contract+'"); \'' id="tr'+CurOrderID+'" class="lblchoice'+fnIfStr(i mod 2 =0, ' altrow', '')+'" style="background-color: #FF8C00;">';
        s:=s+'<tr onclick=\'' ec("moveincurrentorder", "ordr='+CurOrderID+'&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+IntToStr(CurContractID)+'&dialogname='+dialogname+'","newbj"); \'' id="tr'+CurOrderID+'" class="lblchoice'+fnIfStr(OrdersCount mod 2 =0, ' altrow', '')+'" style="background-color: #FF8C00;">';
        s:=s+'<td>'+orderDate+'</td>';
        s:=s+'<td>'+orderNum+'</td>';
        s:=s+'<td title="'+CurContractName+'">'+CurContractName+'</td>';
        s:=s+'<td title="'+fnIfStr(ComentSum<>'', ComentSum, '')+'" style="'+fnIfStr(ComentSum<>'','color: red; font-weight: bold;', '')+'" >'+orderSum+'</td>'; //����� ������
        s:=s+'<td >'+orderCurrency+'</td>';//
        s:=s+'<td >'+Commentary+'</td>';//
        s:=s+'</tr>';
      end;
      s:=s+'<tr onclick=\'' ec("linefromsearchtoorder", "ordr=&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+contract+'"); '+fnIfStr(dialogname='','','$("#'+dialogname+'").dialog("close");')+'\'' id="tr'+CurOrderID+'" class="lblchoice'+fnIfStr(OrdersCount mod 2 =0, ' altrow', '')+'" style="background-color: #FF8C00;">';
      s:=s+'<td colspan="6">� ����� �����</td>';
      s:=s+'</tr>';
      s:=s+'</table>';
      s:=' jqswInfoOutOk("�������� ����� ��� ���������� ������",'''+s+''',"center"); ';
    end
    else
      s:=s+fnIfStr(dialogname='','','$("#'+dialogname+'").dialog("close");')+ 'ec("linefromsearchtoorder", "ordr=&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+contract+'"); ';

  finally
   Result:=s;
  end;
end;  // fnOpenOrdersList

function fnOpenOrdersListRedisign(Stream: TBoBMemoryStream;ordrcode,warecode,wareqty,inline_,contract,dialogname:String): string;  // ���������� ������ �������� ������� ��� ������� �� ������ ��������
var
  s, s1,s2,CurOrderID,WarningMessage,ComentSum: string;
  OrdersCount, i, ii,CurContractID: integer;
  Commentary, CurContractName,orderDate,orderSum,orderCurrency,orderNum: string;
begin
  s:='';
  try
    WarningMessage:=Stream.ReadStr;
    OrdersCount:=Stream.ReadInt;
    if OrdersCount>0 then   begin
      if WarningMessage<>'' then begin
         i:=Pos(',',WarningMessage);
         s1:=Copy(WarningMessage,1,i);
         s2:=Copy(WarningMessage,i+1,Length(WarningMessage));
         s:=s+'<div class="warnmesorddiv">'+s1+'</div>';
         s:=s+'<div class="warnmesorddiv">'+s2+'</div>';
      end;
      s:=s+' <div class="order-table-body-wrap contracts-body" id="orders-choice-body-wrap" data-mcs-theme="inset-dark"> ';
      s:=s+'   <table class="table table-body" id="orders-choice-table-body"> ';
      s:=s+'      <tr style="font-size: 14px;" class="grayline debt-header">';
      s:=s+'        <td class="col">���� ������</td>';
      s:=s+'        <td class="col">����� ������</td>';
      s:=s+'        <td class="col">��������</td>';
      s:=s+'        <td class="col">����� ������</td>';
      s:=s+'        <td class="col">������</td>';
      s:=s+'        <td class="col">�������</td>';
      s:=s+'      </tr>';
      for i := 0 to OrdersCount-1 do begin
        CurOrderID:=IntToStr(Stream.ReadInt);
        CurContractID:=Stream.ReadInt;
        CurContractName:=Stream.ReadStr;
        orderDate:=Stream.ReadStr;
        orderNum:=Stream.ReadStr;
        ComentSum:=Stream.ReadStr;
        orderSum:=Stream.ReadStr;
        orderCurrency:=Stream.ReadStr;
        Commentary:=Stream.ReadStr;
        //s:=s+'<tr onclick=\'''+fnIfStr(dialogname='','','$("#'+dialogname+'").dialog("close");')+'  '+fnIfStr(inline_='true','parent.','')+'document.location.href="'+ScriptName+'/order?order='+CurOrderID+'"; ec("linefromsearchtoorder", "ordr='+CurOrderID+'&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+contract+'"); \'' id="tr'+CurOrderID+'" class="lblchoice'+fnIfStr(i mod 2 =0, ' altrow', '')+'" style="background-color: #FF8C00;">';
        s:=s+'<tr onclick=\'' ec("moveincurrentorder", "ordr='+CurOrderID+'&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+IntToStr(CurContractID)+'&dialogname='+dialogname+'","newbj"); \'' id="tr'+CurOrderID+'" >';
        s:=s+'<td class="col with-border">'+orderDate+'</td>';
        s:=s+'<td class="col with-border">'+orderNum+'</td>';
        s:=s+'<td class="col with-border" title="'+CurContractName+'">'+CurContractName+'</td>';
        s:=s+'<td class="col with-border" title="'+fnIfStr(ComentSum<>'', ComentSum, '')+'" style="'+fnIfStr(ComentSum<>'','color: red; font-weight: bold;', '')+'" >'+orderSum+'</td>'; //����� ������
        s:=s+'<td class="col with-border">'+orderCurrency+'</td>';//
        s:=s+'<td class="col">'+Commentary+'</td>';//
        s:=s+'</tr>';;
      end;
      s:=s+'<tr onclick=\'' ec("linefromsearchtoorder", "ordr=&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+contract+'"); '+fnIfStr(dialogname='','','$("#'+dialogname+'").dialog("close");')+'\'' id="tr'+CurOrderID+'" >';
      s:=s+'<td class="col" colspan="6">� ����� �����</td>';
      s:=s+'</tr>';
      s:=s+'</table>';
      s:=s+'</div>';
      s:=s+'<a class="close-btn btn info-close" onclick="$(\''#general-info-tree\'').toggleClass(\''hide\'');">�������</a>';
      s:=' jqswfillInfo('''+s+''',"�������� ����� ��� ���������� ������",5,0,60); '#13#10;
      s:=s+'$("#orders-choice-body-wrap").mCustomScrollbar({'#13#10+
         '    alwaysShowScrollbar: 1 '#13#10+
         '  });'#13#10;
    end
    else
      s:=s+ 'ec("linefromsearchtoorder", "ordr=&warecode='+warecode+'&wareqty='+wareqty+'&inline='+inline_+'&contract='+contract+'"); ';
  finally
   Result:=s;
  end;
end;  // fnOpenOrdersList

function fnOpenOrdersListQtyRedisign(Stream: TBoBMemoryStream;strPost,strGet:TStringList): string;  // ���������� ������ �������� ������� ��� ������� �� ������ �������� �� ����� �������� �-��
 var
  s, s1,s2,s3, CurOrderID,WarningMessage,ComentSum: string;
  OrdersCount, i, ii,CurContractID: integer;
  Commentary, CurContractName,orderDate,orderSum,orderCurrency,orderNum: string;
begin
  s:='';
  strPost.Delete(0);
  s1:=StringReplace( strPost.Text,#13#10,'&',[rfReplaceAll]);
  s1:=StringReplace(s1,#$D#$A,'&',[rfReplaceAll]);
  try
    WarningMessage:=Stream.ReadStr;
    OrdersCount:=Stream.ReadInt;
    if OrdersCount>0 then   begin
      if WarningMessage<>'' then begin
         i:=Pos(',',WarningMessage);
         s3:=Copy(WarningMessage,1,i);
         s2:=Copy(WarningMessage,i+1,Length(WarningMessage));
         s:=s+'<div class="warnmesorddiv">'+s3+'</div>';
         s:=s+'<div class="warnmesorddiv">'+s2+'</div>';
      end;
      s:=s+' <div class="order-table-body-wrap contracts-body" id="orders-choice-body-wrap" data-mcs-theme="inset-dark"> ';
      s:=s+'   <table class="table table-body" id="orders-choice-table-body"> ';
      s:=s+'      <tr style="font-size: 14px;" class="grayline debt-header">';
      s:=s+'        <td class="col">���� ������</td>';
      s:=s+'        <td class="col">����� ������</td>';
      s:=s+'        <td class="col">��������</td>';
      s:=s+'        <td class="col">����� ������</td>';
      s:=s+'        <td class="col">������</td>';
      s:=s+'        <td class="col">�������</td>';
      s:=s+'      </tr>';
      for i := 0 to OrdersCount-1 do begin
        CurOrderID:=IntToStr(Stream.ReadInt);
        CurContractID:=Stream.ReadInt;
        CurContractName:=Stream.ReadStr;
        orderDate:=Stream.ReadStr;
        orderNum:=Stream.ReadStr;
        ComentSum:=Stream.ReadStr;
        orderSum:=Stream.ReadStr;
        orderCurrency:=Stream.ReadStr;
        Commentary:=Stream.ReadStr;
        s2:=s1;
        Insert(CurOrderID,s2,Pos('&ordr=',s1)+6);
        Delete(s2,1,Pos('&',s2)-1);
        Insert('contract='+IntToStr(CurContractID),s2,1);
        s:=s+'<tr onclick=\'' ec("moveincurrentorderfromformqty", "'+s2+'","newbj"); \'' id="tr'+CurOrderID+'" >';
        s:=s+'<td class="col with-border">'+orderDate+'</td>';
        s:=s+'<td class="col with-border">'+orderNum+'</td>';
        s:=s+'<td class="col with-border" title="'+CurContractName+'">'+CurContractName+'</td>';
        s:=s+'<td class="col with-border" title="'+fnIfStr(ComentSum<>'', ComentSum, '')+'" style="'+fnIfStr(ComentSum<>'','color: red; font-weight: bold;', '')+'" >'+orderSum+'</td>'; //����� ������
        s:=s+'<td class="col with-border">'+orderCurrency+'</td>';//
        s:=s+'<td class="col">'+Commentary+'</td>';//
        s:=s+'</tr>';
      end;
      s:=s+'<tr onclick=\'' ec("linestoorder", "'+s1+'"); '+fnIfStr(fnGetFieldStrList(strPost,strGet,'dialogname')='','','$("#'+fnGetFieldStrList(strPost,strGet,'dialogname')+'").dialog("close");')+'\'' id="tr'+CurOrderID+'" >';
      s:=s+'<td class="col" colspan="6">� ����� �����</td>';
      s:=s+'</tr>';
      s:=s+'</table>';
      s:=s+'</div>';
      s:=s+'<a class="close-btn btn info-close" onclick="$(\''#general-info-tree\'').toggleClass(\''hide\'');">�������</a>';
      s:=s+'</div>';
      s:=' jqswfillInfo('''+s+''',"�������� ����� ��� ���������� ������",5,0,60); '#13#10;
      s:=s+'$("#orders-choice-body-wrap").mCustomScrollbar({'#13#10+
         '    alwaysShowScrollbar: 1 '#13#10+
         '  });'#13#10;
    end
    else
      s:=s+' $("#general-info-tree").toggleClass("hide");'+ 'ec("linestoorder", "'+s1+'"); ';
  finally
   Result:=s;
  end;
end;


function fnfillParametrsAllOrder(Stream: TBoBMemoryStream): string;   //���������� ��� ���������� ���� ������ ���� ������ ��� ��� ��������
var
  s,DestName,DestAdr,name,deliverydate,SelfCommentary: string;
  v,DestID,code,paymenttype,code_date: integer;
  d_date,w_date:double;
//  Ini: Tinifile;
begin
  s:='';
  s:=s+'$("#sendordermark").val(''1''); '#13#10;
  s:=s+'$("#forcheckorder").val(''1''); '#13#10;
  s:=s+' $("#warrantnum").val('''+AnsiToUtf8(Stream.ReadStr)+''');'#13#10;
  s:=s+' $("#warrantperson").val('''+AnsiToUtf8(Stream.ReadStr)+''');'#13#10;
  w_date:=Stream.ReadDouble ;
  if fnNotZero(w_date) then
    s:=s+' $("#fillheaderbeforeprocessingdiv [name^=''warrantdate'']").val('''+FormatDateTime('dd.mm.yy',w_date)+''');'#13#10;
    s:=s+' $("#ordercomment").val('''+AnsiToUtf8(Stream.ReadStr)+''');'#13#10;
    SelfCommentary:=Stream.ReadStr;
    v:=Stream.ReadInt;
    s:=s+' $("#getting'+IntToStr(v)+'").prop(''checked'', true);  '#13#10;
    s:=s+' $("#getting'+IntToStr(v)+'").trigger(''change''); '#13#10;
    paymenttype:=Stream.ReadInt;
    s:=s+' $("#paymenttype").val('''+IntToStr(paymenttype)+''');'#13#10;
    //if paymenttype=0 then
    s:=s+' $("#warrantydiv").css(''display'', ''none''); '#13#10;
    s:=s+'var list=$("#fillheaderbeforeprocessingdiv select[name^=''tt'']")[0];'#13#10;  //��������� ������
    s:=s+'list.options.length=0;'#13#10;
    DestID:=Stream.ReadInt;
    s:=s+'ec(''getcontractdestpointslist'',''value='+IntToStr(DestID)+'&id=_ttorderselect&isEmpty=0'', ''abj'');'#13#10;
    DestName:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
    DestAdr:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
//        s:=s+'list.options[0]= new Option('''+DestName+','+DestAdr+''','+IntToStr(DestID)+', false, false);'#13#10;
    d_date:=Stream.ReadDouble ;
    if fnNotZero(d_date) then begin
      s:=s+' $("#deliverydatetext").val('''+FormatDateTime('dd.mm.yy',d_date)+''');'#13#10;
      code_date:=Trunc(d_date);
      s:=s+'list=$("#fillheaderbeforeprocessingdiv select[name^=''deliverydate'']")[0];'#13#10;  //���������� ������
      s:=s+'list.options.length=0;'#13#10;
      s:=s+'list.options[0]= new Option('''+FormatDateTime('dd.mm.yy', d_date)+''', '+IntToStr(ABS(code_date))+', false, false);'#13#10;
      s:=s+'ec("getDateListSelfDelivery","Olddate='+IntToStr(code_date)+'&contract="+$("#contract").val(),"abj"); '#13#10;
    end
    else begin
      s:=s+'ec("getDateListSelfDelivery","Olddate=0&contract="+$("#contract").val(),"abj"); '#13#10;
    end;
    s:=s+' $("#shedulercode").val('''+IntToStr(Stream.ReadInt)+''');'#13#10;
    if v=0 then
      s:=s+' $("#deliverykind").text('''+Stream.ReadStr+''');'#13#10
    else
      Stream.ReadStr;
    s:=s+'list=$("#pickuptimespan select[name^=''pickuptime'']")[0];'#13#10;  //���������� ������
    s:=s+'list.options.length=0;'#13#10;
    code:=Stream.ReadInt;
    name:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
    s:=s+'list.options[0]= new Option('''+name+''', '+IntToStr(ABS(code))+', false, false);'#13#10;
    s:=s+' var deliverydate=$("#fillheaderbeforeprocessingdiv select[name^=''deliverydate''] option:selected").text(); '#13#10;
    s:=s+' if (deliverydate!=''''){ ec("getTimeListSelfDelivery","date="+deliverydate.substring(0,10)+"&OldTime="+$("#pickuptimespan select[name^=''pickuptime'']").val()+"&contract="+$("#contract").val(),"abj");} '#13#10;
    if v=0 then begin
      s:=s+' $("#deliverytimeout").text('''+name+''');'#13#10;
      s:=s+' $("#deliverytimein").text('''+Stream.ReadStr+''');'#13#10;
    end
    else
      Stream.ReadStr;
    //s:=s+' var btn = document.getElementById(''showdeliveriesbtn'');'#13#10;
    //s:=s+' var tt = $("#fillheaderbeforeprocessingdiv [name^=''tt'']").val();'#13#10;
    //s:=s+' var dd = $("#fillheaderbeforeprocessingdiv select[name^=''deliverydate'']").text();'#13#10;
    //s:=s+' if(tt!=0 && dd!=''''){if (btn.disabled){btn.disabled = false;}}    '#13#10;
    s:=s+'$("#forcheckorder").val(''0''); '#13#10;
    s:=s+'fillHelpDesk();'#13#10;
    s:=s+''#13#10;
    Result:=s;
end;  // fnfillParametrsFromOrder

function fnsaveParametrsFromOrder(Stream: TBoBMemoryStream;v: integer;kindSave: integer;deliverydatetext:String; deliverydate: String): string;   //���������� ��� ���������� ������ ���� ������
var
  s: string;
 begin
  s:='';
  case v of
    0:begin
       s:=s+'var deliverytimeout=$("#deliverytimeout").text();'#13#10;
       s:=s+'var deliverytimein=$("#deliverytimein").text();'#13#10;
       s:=s+'var deliverykind=$("#deliverykind").text();'#13#10;
       s:=s+'var str1=''��������: '+deliverydatetext+''';       '#13#10;
       s:=s+'var tt=$("#_ttorderselect :selected").text(); '#13#10;
       s:=s+'if ((deliverytimeout!='''') && (str1 !=''��������: '')) {str1+='' , '';} '#13#10;
       s:=s+'if ( (deliverykind !='''') && ((deliverytimeout!='''') || (str1 !=''��������: '')) ) {deliverytimeout+='' , '';} '#13#10;
       s:=s+'if ( (tt !='''') && ((deliverytimeout!='''') || (str1 !=''��������: '') || (deliverykind !='''')) ) {deliverykind+='' , '';}                                   '#13#10;
       s:=s+'if ((deliverytimein !='''') && ((deliverytimeout!='''') || (str1 !=''��������: '') || (deliverykind !='''') || (tt !='''')) )  {deliverytimein='', ����. ����. ''+deliverytimein;} '#13#10;
       s:=s+' else{ if (deliverytimein !='''')  {deliverytimein=''����. ����. ''+deliverytimein;} }'#13#10;

       s:=s+'$(''#orderdeliverydata'').text(str1+deliverytimeout+deliverykind+tt+deliverytimein);'#13#10;
      end;
    1:begin
       s:=s+'$(''#orderdeliverydata'').text(''��������������'');'#13#10;
      end;
    2:begin
       s:=s+'var deliverytime=$("#pickuptimespan select[name^=''pickuptime''] :selected").text();        ;'#13#10;
       s:=s+'var str1=''��������: '+deliverydatetext+''';       '#13#10;
       s:=s+'var str2=''���������''      '#13#10;
       s:=s+'if ((deliverytime !='''') && (str1 !=''��������: '')) {str1+='' , '';deliverytime+='' , '';} '#13#10;
       s:=s+'if ($("#btim_toprocessingbonus").length){ '#13#10;
       s:=s+'$("#orderdeliverydataBonus").text(str1+deliverytime+str2); '#13#10;
       s:=s+'}'#13#10;
       s:=s+'else {'#13#10;
       s:=s+'$(''#orderdeliverydata'').text(str1+deliverytime+str2);'#13#10;
       s:=s+' }'#13#10;
      end;
   end;
   if kindSave=1 then begin
     s:=s+'jqswConfirmOrderComplete("����� ��������� �� ���������")'#13#10;
     //s:=s+'reloadpage();'#13#10;
   end;
   s:=s+' $(''#fillheaderbeforeprocessingdiv'').dialog(''close'');'#13#10;
   s:=s+''#13#10;
   Result:=s;
end;  // fnsaveParametrsFromOrder


function fngetNewBankAccountParams(Stream: TBoBMemoryStream) :String;
 var
  s,Name,Code: string;
  i, j,k,l: integer; // loop local var
  Limit:double;
begin
 j:=Stream.ReadInt;  //���������
 s:=s+' TStream1.arlen='+IntToStr(j)+'; '#13#10;
 s:=s+' TStream1.artable= new Array(); '#13#10;
 for i:=1 to j do begin
  Code:=IntToStr(Stream.ReadInt);
  Name:=Stream.ReadStr;
  s:=s+' TStream1.artable['+IntToStr(i-1)+']=new Array('+Code+','''+Name+''');'#13#10;
 end;

 j:=Stream.ReadInt;     //�������
 s:=s+' TStream2.arlen='+IntToStr(j)+'; '#13#10;
 s:=s+' TStream2.artable= new Array(); '#13#10;
 for i:=1 to j do begin
   Code:=IntToStr(Stream.ReadInt);
   Name:=Stream.ReadStr;
   Name:=StringReplace(Name,'''','`',[rfReplaceAll]);
   Name:=StringReplace(Name,'"','`',[rfReplaceAll]);
   Limit:=Stream.ReadDouble;
   k:=Stream.ReadInt;     //��������
   s:=s+' TStream2.artable['+IntToStr(i-1)+']=new Array('+Code+','''+Name+''','''+FormatFloat('# ##0.00', Limit)+''' ,'+IntToStr(k)+',';
   if k>0 then begin
     s:=s+'new Array(';
     for l:=0 to k-1 do begin
       Name:=Stream.ReadStr;
       if l<>k-1 then
         s:=s+'"'+Name+'",'
       else
         s:=s+'"'+Name+'"';
     end;
   s:=s+') ,';
   end;

   k:=Stream.ReadInt;     //e-mail
   s:=s+IntToStr(k);
   if k>0 then begin
     s:=s+', new Array(';
     for l:=0 to k-1 do begin
       Name:=Stream.ReadStr;
       if l<>k-1 then
         s:=s+'"'+Name+'",'
       else
         s:=s+'"'+Name+'"';
     end;
   s:=s+') ); '#13#10;
   end
   else
     s:=s+' ); '#13#10;
 end;
 s:=s+' fillAccountParametr(TStream1,TStream2); '#13#10;
 Result:=s;
end;

function fnsaveNewBankAccountParams(Stream: TBoBMemoryStream;ScriptName:String;IsFromInfo:boolean=false):String;
 var
  s,AccCode,Contract,AccNum,Privat,FIO: string;
  AccSum:double;
  AccSms:boolean;
begin
 AccCode:=IntToStr(Stream.ReadInt);
 Contract:=Stream.ReadStr;
 AccNum:=Stream.ReadStr;
 AccSum:=Stream.ReadDouble;
 FIO:=Stream.ReadStr;
 Privat:=Stream.ReadStr;
 AccSms:=Stream.ReadBool;
 s:=' TStream1.length=0; '#13#10;
 s:=s+' TStream1.arlen=1; '#13#10;
 s:=s+' TStream1.artable[0]=new Array('+AccCode+','''+Contract+''','''+AccNum+''','''+FormatFloat('# ##0.00', AccSum)+''','''+FIO+''','''+Privat+''','''+BoolToStr(AccSms)+''');'#13#10;
 if not IsFromInfo then
   s:=s+'addrowacc(TStream1);'#13#10
 else
   s:=s+'document.location.href=scriptname+"/debt?act=acc";'#13#10;
 s:=s+'$("#general-info-tree").addClass("hide"); '#13#10;
 Result:=s;
end;


function fnGetQtyByAnalogsAndStorages(Stream: TBoBMemoryStream;bonus:String; ordr:String): string;
var
  WareRequestQty, CurrencyName, WareCodeStr, CurWareCode, CutPriceReason, s, s1, s2: string;
  ChekingQty, WareQtyD: double;
  LineCount, StorageCount, i, j,k,ActionCode: integer;
  Storages: TaSD;
  CutPrice,IsSale,NonReturn: boolean;
  List: TStringList;
  b: byte;
  DirectName,ActionTitle,ActionText,Brand,WareName:string;
begin
  s:='';
  LineCount:=Stream.ReadInt;
  CurrencyName:=Stream.ReadStr;
  WareRequestQty:=Stream.ReadStr;
  WareCodeStr:=Stream.ReadStr;
  s:=s+'var s="";'#13#10;
  s:=s+'var Storages = ['#13#10;
  Storages:=fnReceiveStorages(Stream);
  StorageCount:=Length(Storages);
  for i:=0 to StorageCount-1 do begin
    if (Copy(Storages[i].FullName, 1, 1)='-') then begin
      Storages[i].FullName:=Copy(Storages[i].FullName, 2, 100000);
    end else begin
             end;
    s:=s+'['+fnIfStr(Storages[i].IsReserve, '1', '0')+', "'+Storages[i].Code+'", "'+StringReplace(Storages[i].FullName, '�����', '', [])+'", "'+Storages[i].ShortName+'"]';
    s:=s+fnIfStr(i=(StorageCount-1), '', ',')+#13#10;
  end;
  s:=s+'];'#13#10;
  s:=s+'var altrow=0;'#13#10;
  s:=s+'var qvColPrice='+IntToStr(Length(arPriceColNames))+';'#13#10;
  s:=s+'var arColHeaders= []; ' ;
  s:=s+'var arColHeadersTitle=[]; ';
  for i := 0 to Length(arPriceColNames)-1 do  begin
    s:=s+'arColHeaders['+IntToStr(i)+']="'+arPriceColNames[i].ColName+'";';
    s:=s+'arColHeadersTitle['+IntToStr(i)+']="'+arPriceColNames[i].FullName+'";';
  end;
  // s:=s+'var qvColPrice=0;'#13#10;  ���� ��������, �������    �� ����� �����������

  if  (StrToBoolDef(bonus,false)=true) then begin
    s:=s+'s=s+dwwath("'+CurrencyName+'", "'+WareRequestQty+'", "'+WareCodeStr+'","0" ';   // ������������ ������
    for i:=0 to StorageCount-1 do begin
      s:=s+',"'+Storages[i].FullName+'","'+Storages[i].ShortName+'"';
    end;
    s:=s+');'#13#10;
  end
  else begin
    s:=s+'s=s+dwwath("'+CurrencyName+'", "'+WareRequestQty+'", "'+WareCodeStr+'" ,"'+ordr+'"';   // ������������ ������
    for i:=0 to StorageCount-1 do begin
      s:=s+',"'+Storages[i].FullName+'","'+Storages[i].ShortName+'"';
    end;
    s:=s+');'#13#10;
  end;

  List:=TStringList.Create;
  for j:=0 to LineCount-1 do begin
    CurWareCode:=IntToStr(Stream.ReadInt);
    Brand:=Stream.ReadStr;
    WareName:=GetJSSafeStringArg(Stream.ReadStr);        // ������������
    IsSale:=Stream.ReadBool;      // ������� ����������
    NonReturn:=Stream.ReadBool;      // ������� ����������
    CutPrice:=Stream.ReadBool;      // ������� ������
    DirectName:=LowerCase(Stream.ReadStr);    //�������� ����������� ��� ������
    ActionCode:=Stream.ReadInt;         // ��� �����
    ActionTitle:=Stream.ReadStr;      // ���������
    ActionText:=Stream.ReadStr;       // �����
    ActionText:=StringReplace(ActionText,'\n','<br>',[rfReplaceAll]);
    ActionText:=GetJSSafeStringArg(ActionText);



    s:=s+'s=s+dwwatb('+CurWareCode; // WareCode
    b:=3;
    s:=s+',"'+arAnalogColors[b]+'"'; // ����
    s:=s+',"'+Brand+'"'; // Brand
    s:=s+',"'+WareName+'"'; // WareName
    s:=s+','+BoBBoolToStr(IsSale)+''; // Sale
    s:=s+','+BoBBoolToStr(NonReturn)+''; // NonReturn
    s:=s+','+BoBBoolToStr(CutPrice)+''; // CutPrice
    s:=s+','+IntToStr(ActionCode)+'';
    s:=s+',"'+ActionTitle+'"';
    s:=s+',"'+ActionText+'"';
    if (CutPrice and FileExists(DescrDir+'\waredescr\'+CurWareCode+'.html')) then begin
      try
        List.LoadFromFile(DescrDir+'\waredescr\'+CurWareCode+'.html');
        CutPriceReason:=StripHTMLTags(GetJSSafeStringArg(List.Text));
        if Length(CutPriceReason)<4 then CutPriceReason:='';
      finally
      end;
    end;
    s:=s+',"'+CutPriceReason+'"';                              //
    k:=0;s:=s+',[';
    while (k<Length(arPriceColNames)) do begin
      if k<>Length(arPriceColNames)-1 then
        s:=s+'"'+Stream.ReadStr+'",'
      else
        s:=s+'"'+Stream.ReadStr+'"';
        inc(k);
    end;
    s:=s+']," "';
    s:=s+',"'+Stream.ReadStr+'"'; // ��.���
    s:=s+',"'+CurrencyName+'"';

    for i:=0 to StorageCount-1 do begin
      s1:=Stream.ReadStr;
      if Copy(s1, 1, 4)='&gt;' then s2:=Copy(s1, 5, 100000) else s2:=s1;
        WareQtyD:=StrToFloatDef(s2, 1);
      if WareQtyD>=ChekingQty then begin
        s:=s+',"<b style=''color: green;''>����</b>"'; // �������
      end else
            if WareQtyD>8 then begin
              s:=s+',"<b style=''color: red;''>&lt;'+trim(FormatFloat('# ##0.##', ChekingQty))+'</b>"'; // �������
            end else begin
              s:=s+',"<b style=''color: red;''>'+s2+'</b>"'; // �������
            end;

           if Storages[i].IsReserve then s:=s+',"'+Stream.ReadStr+'"'; // ���-�� � ������
          end;
      s:=s+');'#13#10;
    end;
    s:=s+'s=s+"</tbody></table></form> ";'#13#10;
    if bonus='true' then begin
      s:=s+'$(''#wareanalogdialogbonus'').html(s); ';
      s:=s+'$(''#wareanalogdialogbonus'').dialog(''open''); ';
      s:=s+' var f=$("#of table").width();';
      s:=s+'  $("#wareanalogdialogbonus").dialog({';//������ ������� ����������
      s:=s+'   width: $("#of table").width()+10 ';
      s:=s+'      });';
      s:=s+'$(''#t1 td'').css(''width'', ''10px'');'#13#10;
      s:=s+'$(''#of'').width($(''#of table'').width());'#13#10;
      s:=s+'calctotalqty();';
      s:=s+'$(''#wareanalogdialogbonus'').dialog(''option'', ''position'', ''center''); ';
    end
    else begin
      s:=s+'$(''#wareanalogdialog'').html(s); ';
      s:=s+'$(''#wareanalogdialog'').dialog(''open''); ';
      s:=s+' var f=$("#of table").width();';
      s:=s+'  $("#wareanalogdialog").dialog({';//������ ������� ����������
      s:=s+'   width: $("#of table").width()+10 ';
      s:=s+'      });';
      s:=s+'$(''#t1 td'').css(''width'', ''10px'');'#13#10;
      s:=s+'$(''#of'').width($(''#of table'').width());'#13#10;
      s:=s+'calctotalqty();';
      s:=s+'$(''#wareanalogdialog'').dialog(''option'', ''position'', ''center''); ';
    end;

 Result:=s;

end;  // fnGetQtyByAnalogsAndStorages

function fnaddLinesToOrder(Stream: TBoBMemoryStream;ScriptName:String;contract:String):String;
 var
  LineCount,StorageCount, Action: integer;
  s, s1, AccType, UserMessage,newSum,currencyName,ComentSum: string;
  i,j: integer;
  Storages: TaSD;
begin
 if boolean(Stream.ReadByte) then begin // ����� ������
   LineCount:=Stream.ReadInt;
   AccType:=Stream.ReadStr;

   s:=s+'var s="";'#13#10;
   s:=s+'var Storages = ['#13#10;
   Storages:=fnReceiveStorages(Stream);
   StorageCount:=Length(Storages);
   for i:=0 to StorageCount-1 do begin
     s:=s+'['+fnIfStr(Storages[i].IsReserve, '1', '0')+', "'+Storages[i].Code+'", "'+Storages[i].FullName+'", "'+Storages[i].ShortName+'"]';
     s:=s+fnIfStr(i=(StorageCount-1), '', ',')+#13#10;
   end;
   s:=s+'];'#13#10;
   s:=s+'$("#toorderbtn").attr("disabled", false);'#13#10;

   for i:=1 to LineCount do begin
     Action:=Stream.ReadByte;
     case Action of
       constOpAdd: begin
         s:=s+'alsto('+IntToStr(Stream.ReadInt) // ��� ������ ������
             +', '+Stream.ReadStr              // ��� ������
//                         +', '+AccType                     // ��� ������
             +', '''+Stream.ReadStr+''''       // ������
             +', '''+Stream.ReadStr+''''       // �����
             +', '''+Stream.ReadStr+''''       // WareName
             +', '''+Stream.ReadStr+''''       // �����
             +', '''+Stream.ReadStr+''''       // �����
             +', '''+Stream.ReadStr+''''       // ����
             +', '''+Stream.ReadStr+''''       // �����
             +', '''+Stream.ReadStr+'''';      // ����� ������
         for j:=0 to StorageCount-1 do begin
// ������ ����� - ��� �������� � ������������ ��������� �� �������
//                         s:=s+', '''+Stream.ReadStr+'''';  // �������
           if Storages[j].IsReserve then begin
             s:=s+', '''+Stream.ReadStr+'''';// ����� �� ������
           end;
         end;
         s:=s+');'#13#10;
       end; // constOpAdd
       constOpEdit: begin
         s:=s+'elio('+IntToStr(Stream.ReadInt); // ��� ������ ������
         Stream.ReadStr;                   // ��� ������
         Stream.ReadStr;                   // ������
         Stream.ReadStr;                   // �����
         Stream.ReadStr;                   // WareName
         s:=s +', '''+Stream.ReadStr+''''       // �����
              +', '''+Stream.ReadStr+''''       // �����
              +', '''+Stream.ReadStr+''''       // ����
              +', '''+Stream.ReadStr+''''       // �����
              +', '''+Stream.ReadStr+'''';      // ����� ������
         for j:=0 to StorageCount-1 do begin
// ������ ����� - ��� �������� � ������������ ��������� �� �������
//                         s:=s+', '''+Stream.ReadStr+'''';  // �������
           if Storages[j].IsReserve then begin
             s:=s+', '''+Stream.ReadStr+'''';// ����� �� ������
           end;
         end;
         s:=s+');'#13#10;
       end; //constOpEdit
       constOpDel: begin
         s:=s+'dlfo('+Stream.ReadStr+');'#13#10; // ��� ������
        end; //constOpDel
     end;  // case Action of
   end;
   newSum:=Stream.ReadStr;
   currencyName:=Stream.ReadStr;
   s:=s+'var elem=$("#sumcell"); if (elem.length) elem.html("&#8721; '+newSum+' '+currencyName+'");'#13#10;
   //s:=s+'elem=$("#sumcellbonus"); if (elem.length) elem.html("&#8721; '+newSum+' '+currencyName+'");'#13#10;
   s:=s+'elem=$("#totalballs"); if (elem.length) elem.html('''+Stream.ReadStr+''');'#13#10; // ����� ����� ������ �� ������
   s:=s+'mkt(''tablecontent'');'#13#10;
   s:=s+'$.fancybox.close();'#13#10;
   UserMessage:=Stream.ReadStr;
    if (UserMessage<>'') then begin
      s:=s+'jqswMessage('''+GetJSSafeString(UserMessage)+''');'#13#10;
    end;
   ComentSum:=Stream.ReadStr;
   s:=s+'$("#sumcommentdiv").text('''+ComentSum+''');'#13#10;
 end else begin  // ���� ������� �� ����� �����
   s1:='document.location.href="'+ScriptName+'/order?order='+IntToStr(Stream.ReadInt)+'&contract='+contract+'";'#13#10;
   UserMessage:=Stream.ReadStr;
   if (UserMessage<>'') then begin
     s:=s+'jqswMessage('''+GetJSSafeString(UserMessage)+''');'#13#10;
   end;
   s:=s+s1;
 end;
 Result:=s;
end;

function fngetMeetPersonsList(Stream: TBoBMemoryStream;id: String;value: String): string;  //��������� ������ �������� �����
var
  s, MeetPersonName,s2: string;
  i,j, MeetPersonID: integer;
begin
  s:='';
  s:=s+'var list=$("#'+id+'")[0];'#13#10;  //��������� ������
  s:=s+'list.options.length=0;'#13#10;
  s:=s+'var j=0;'#13#10;
  j := Stream.ReadInt; //��������� ��������� ������ ��
  if (value='0')  then
    s:=s+'list.options[j++]= new Option('''',0, false, false);'#13#10;
  for i := 1 to j do begin
    MeetPersonID:=Stream.ReadInt;
    MeetPersonName:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
    s:=s+'list.options[j++]= new Option('''+MeetPersonName+''','+IntToStr(MeetPersonID)+', false, false);'#13#10;
  end;
  s:=s+'list.value='+value+';'#13#10;
  s:=s+'$("#meet-person-select").selectmenu("refresh"); '#13#10;
  s:=s+'$("#meet-person-select-button").find("span.ui-selectmenu-icon").bind("click", function(event){ '#13#10;
  s:=s+'  $("#meet-person-select-menu").attr("data-mcs-theme","inset-dark");'#13#10;
  s:=s+'  $("#meet-person-select-menu").mCustomScrollbar({ '#13#10;
  s:=s+'    alwaysShowScrollbar: 1 '#13#10;
  s:=s+'  })'#13#10;
  s:=s+'});'#13#10;
  s:=s+'if ( ($("#meet-person-select option").size()==1) && ($("#meet-person-select option").val()=="0")) { '#13#10;
  s:=s+'  var s2=''<p style="color: red;">�������� ��������� ������� � ��������� > ������������ ������ ��� �� ���. '+PhoneSupport+'.</p>'''#13#10;
  s:=s+'  $("#meet-person-select-button ").parent() .addClass("tooltip");'#13#10;
  s:=s+'  $("#meet-person-select-button ").parent() .tooltipster({'#13#10;
    //                  position: "left",'#13#10+
    //                  offsetX: -450,'#13#10+
  s:=s+'                    content: $(s2)'#13#10;
  s:=s+'  });'#13#10;
  s:=s+'  $("#meet-person-select-button ").parent() .tooltipster();'#13#10;
  s:=s+'}'#13#10;
  s:=s+'else{'#13#10;
  s:=s+'  $("#meet-person-select-button").removeClass("tooltip");'#13#10;
  s:=s+'}'#13#10;
  Result:=s;
end;  // getMeetPersonsList

function fnCreateNewUser(Stream:TBoBMemoryStream; var userInf:TUserInfo) :string;// ������ ���������. �������� ������������
 var
  s:String;
begin
  s:='';
  s:=s+'jqswMessage("������� ������ ��� ������ ������������ ������� �������. ����� � ������ ���������� �� e-mail ������������.");'#13#10;
  s:=s+'addOptionsPageNewUser('+fnGetFieldStrList(userInf.strPost,userInf.strGet,'ful')+','''+fnGetFieldStrList(userInf.strPost,userInf.strGet,'newlogin')+''','''+Stream.ReadStr+''');';
  Result:=s;
end;


function fnGetNodeWares_Motul(Stream:TBoBMemoryStream; var userInf:TUserInfo;ScriptName:String): string;
var
  temp:RawByteString;
  i,j,k,m,l,WareCode,GroupCode,fsize,NodeID,PLineCode: integer;
  arPrices: Array of String;
  arPricesLitr: Array of Double;
  LitrCount: double;
  jpg:TJpegImage;
  StreamImg,TMPStream: TBoBMemoryStream;
  NodeHint,PLineName,PLineComm,PLineLitr:String;
begin
  Result:='';
  Result:=Result+'$("#motul-podbor-tree").removeClass("hide");'#13#10;
  Result:=Result+'arrPodborMotul.length=0;'#13#10;
  Result:=Result+'arrPodborMotul[arrPodborMotul.length]={';
  Result:=Result+'Sys:'+IntToStr(Stream.ReadInt)+' ,ModelName:'''+GetJSSafeStringArgMonoQuote(Stream.ReadStr)+''', ';
  Result:=Result+'ModelCode:'+fnGetFieldStrList(userInf.strPost,userInf.strGet,'model')+' ,Contract:'+fnGetFieldStrList(userInf.strPost,userInf.strGet,'contract')+', ';
   Result:=Result+'CurrentNode:'+fnGetFieldStrList(userInf.strPost,userInf.strGet,'node')+', ';
  Result:=Result+'IconNames:new Array(), ';
  Result:=Result+'MainTableData:new Array()';
  Result:=Result+'};'#13#10;
  j:=Stream.ReadInt;
  for i := 1 to j do begin
    Result:=Result+'arrPodborMotul[arrPodborMotul.length-1].IconNames['+IntToStr(i-1)+']={';
    Result:=Result+' Code:'+IntToStr(Stream.ReadInt)+',';
    Result:=Result+' Hint:'''+Stream.ReadStr+'''};'#13#10;
  end;

  Result:=Result+'arrPodborMotul[arrPodborMotul.length-1].CurencyName='''+Stream.ReadStr+''';'#13#10;
  j:=Stream.ReadInt; // �������� ���� �� ������
  for i := 1 to j do begin
    NodeID:=Stream.ReadInt;
    NodeHint:=Stream.ReadStr;
    PLineCode:=Stream.ReadInt;
    PLineName:=Stream.ReadStr;
    PLineComm:=Stream.ReadStr;
    PLineLitr:=Stream.ReadStr;
    Result:=Result+'arrPodborMotul[arrPodborMotul.length-1].MainTableData['+IntToStr(i-1)+']={';
    Result:=Result+'NodeID:'+IntToStr(NodeID)+', NodeHint:'''+NodeHint+''', PLineCode:'+IntToStr(PLineCode)+', PLineName:'''+PLineName+''', PLineComm:'''+PLineComm;
    Result:=Result+''', PLineLitr:'''+PLineLitr+''', ';
    temp:=Stream.ReadStr;
    temp:=GetHTMLSafeString(temp, true);
    temp:=fnDeCodeBracketsInWeb(temp);
    Result:=Result+'PLineiHint:'''+GetJSSafeStringArg(temp)+''', ';
    Result:=Result+'ImageExt:'''+Stream.ReadStr+''', '; // ���������� ����� ��������
    fsize:=Stream.ReadInt;
    if fsize=0 then begin
      prMessageLOGS('fnGetNodeWares_Motul: EmptyImage PLineCode='+IntToStr(PLineCode));
      Result:=Result+'ImageSize:0, '; // ������ ��������
      Result:=Result+'Width:0, '; // ������ ��������
      Result:=Result+'Height:0, '; // ������ ��������
      Result:=Result+'Image:'''', '
    end
    else begin
      Result:=Result+'ImageSize:'+IntToStr(fsize)+', '; // ������ ��������
      try
        jpg:=TJpegImage.Create;
        StreamImg:=TBoBMemoryStream.Create;
        TMPStream:=TBoBMemoryStream.Create;
        StreamImg.CopyFrom(Stream, fsize);
        StreamImg.Position:=0;
        try
          jpg.LoadFromStream(StreamImg);
          Result:=Result+'Width:'+IntToStr(jpg.Width)+', '; // ������ ��������
          Result:=Result+'Height:'+IntToStr(jpg.Height)+', '; // ������ ��������
          StreamImg.Clear;
          TMPStream.Clear;
          temp:='';
          jpg.SaveToStream(StreamImg);
          StreamImg.Position:=0;
          EncodeStream(StreamImg, TMPStream);
          TMPStream.Position:=0;
          SetLength(temp, TMPStream.Size);
          TMPStream.Read(Pointer(temp)^, TMPStream.Size);
          Result:=Result+'Image:'''+StringReplace(string(temp),#13#10,'',[rfReplaceAll])+''', '
        except
          prMessageLOGS('fnGetNodeWares_Motul: Error image format PLineCode='+IntToStr(PLineCode));
          Result:=Result+'ImageSize:0, '; // ������ ��������
          Result:=Result+'Width:0, '; // ������ ��������
          Result:=Result+'Height:0, '; // ������ ��������
          Result:=Result+'Image:'''', '
        end;
       finally
        jpg.Destroy;
        StreamImg.Destroy;
        TMPStream.Destroy;
      end;
    end;
    m:=Stream.ReadInt;// ���������� ����� �������
    Result:=Result+'PLineWaresCount:'+IntToStr(m)+', WaresTableData:new Array()};'#13#10;
    for k := 1 to m do begin // ���� ����� �������
      WareCode:=Stream.ReadInt;
      GroupCode:=Stream.ReadInt;
      LitrCount:=Stream.ReadDouble;
      Result:=Result+'arrPodborMotul[arrPodborMotul.length-1].MainTableData['+IntToStr(i-1)+'].WaresTableData['+IntToStr(k-1)+']={';
      Result:=Result+'WareCode:'+IntToStr(WareCode)+',GroupCode:'+IntToStr(GroupCode)+', LitrCount:'+StringReplace(FormatFloat('# ##0.00',LitrCount),',','.',[]);
      Result:=Result+', Prices:[''';
      l:=0; SetLength(arPrices,Length(arPriceColNames)); SetLength(arPricesLitr,Length(arPriceColNames));
      while (l<Length(arPriceColNames)) do begin
        arPricesLitr[l]:=RoundTo(Stream.ReadDouble,-2);
        //arPrices[l]:=StringReplace(FloatToStr(arPricesLitr[l]),',','.',[rfReplaceAll]);
        arPrices[l]:=FormatFloat('# ##0.00',arPricesLitr[l]);
        arPrices[l]:=StringReplace(arPrices[l],',','.',[rfReplaceAll]);
        if l=Length(arPriceColNames)-1 then
          Result:=Result+arPrices[l]+'''] , '
        else
          Result:=Result+arPrices[l]+''', ''';
        Inc(l);
      end;
      Result:=Result+' PricesLitr:[''';
      l:=0;
      while (l<Length(arPriceColNames)) do begin
        if l=Length(arPriceColNames)-1 then  begin
          if LitrCount>0 then begin
            //Result:=Result+StringReplace(FloatToStr(RoundTo(arPricesLitr[l]/LitrCount, -2)),',','.',[rfReplaceAll])+'] , ';
            arPrices[l]:=FormatFloat('# ##0.00',arPricesLitr[l]/LitrCount);
            arPrices[l]:=StringReplace(arPrices[l],',','.',[rfReplaceAll]);
            Result:=Result+arPrices[l]+'''] , ';
          end
          else
            Result:=Result+'''0.00''] , '
        end
        else
          if LitrCount>0 then begin
            //Result:=Result+StringReplace(FloatToStr(RoundTo(arPricesLitr[l]/LitrCount, -2)),',','.',[])+', ';
            arPrices[l]:=FormatFloat('# ##0.00',arPricesLitr[l]/LitrCount);
            arPrices[l]:=StringReplace(arPrices[l],',','.',[rfReplaceAll]);
            Result:=Result+arPrices[l]+''' , ''';
          end
          else
            Result:=Result+'''0.00'', ''';
        Inc(l);
      end;

      Result:=Result+'QvSys:'+IntToStr(Stream.ReadInt)+', AutoSysCode:'+IntToStr(Stream.ReadInt)+', IsAuto:'+BoolToStr(Stream.ReadBool);
      Result:=Result+', MotoSysCode:'+IntToStr(Stream.ReadInt)+', IsMoto:'+BoolToStr(Stream.ReadBool);
      Result:=Result+', CVSysCode:'+IntToStr(Stream.ReadInt)+', IsCV:'+BoolToStr(Stream.ReadBool);
      Result:=Result+', AuxSysCode:'+IntToStr(Stream.ReadInt)+', IsAux:'+BoolToStr(Stream.ReadBool);
      Result:=Result+', IsSale:'+BoolToStr(Stream.ReadBool)+', IsNotReturn:'+BoolToStr(Stream.ReadBool)+', IsCutPrice:'+BoolToStr(Stream.ReadBool);
      Result:=Result+', ActionCode:'+IntToStr(Stream.ReadInt)+', ActionTitle:'''+Stream.ReadStr+''', ActionText:'''+Stream.ReadStr;
      Result:=Result+''', ActionImageExt:'''+Stream.ReadStr+''', '; // ���������� ����� �������� ������
      fsize:=Stream.ReadInt;
      Result:=Result+'ActionImageSize:'+IntToStr(fsize)+', '; // ������ ��������   ������
      if fsize=0 then begin
        Result:=Result+'ActionImage:'''', '
      end
      else begin
        try
          StreamImg:=TBoBMemoryStream.Create;
          TMPStream:=TBoBMemoryStream.Create;
          StreamImg.CopyFrom(Stream, fsize);
          StreamImg.Position:=0;
          temp:='';
          EncodeStream(StreamImg, TMPStream);
          TMPStream.Position:=0;
          SetLength(temp, TMPStream.Size);
          TMPStream.Read(Pointer(temp)^, TMPStream.Size);
          Result:=Result+'ActionImage:'''+StringReplace(string(temp),#13#10,'',[rfReplaceAll])+''', ';
       finally
         StreamImg.Destroy;
         TMPStream.Destroy;
       end;
      end;
      Result:=Result+' Divis:'+FloatToStr(Stream.ReadDouble)+', Semafor:'+IntToStr(Stream.ReadInt);
      if flSpecRestSem then  begin
        Result:=Result+', yellow_greenHint:'''+Stream.ReadStr;
        Result:=Result+'''};'#13#10;
      end
      else
        Result:=Result+'};'#13#10;
    end;
  end;
  if j>0 then  begin
    Result:=Result+'createPodborMotulTableHeader();'#13#10;
    Result:=Result+'loadPodborMotulIcon();'#13#10;
    Result:=Result+'loadPodborMotulData();'#13#10;
     Result:=Result+'if ($("#addlines", top.document).length) {'#13#10;
    Result:=Result+'  if ($("#addlines", top.document).attr("value")) {'#13#10;
    Result:=Result+'    setPodborMotulQvHint();'#13#10;
    Result:=Result+'  }'#13#10;
    Result:=Result+'}'#13#10;
    Result:=Result+'intervalID2=setInterval("resizePodborMotulHeaderTable()",500);'#13#10;
    Result:=Result+'setSemaforCheckWareFunc();'#13#10;
end;
  SetLength(arPrices,0);
  SetLength(arPricesLitr,0);
end; // fnGetNodeWares

function fnGetContractList(Stream:TBoBMemoryStream; edit:String; ContractId:integer) :string;// ���� ������ ����������
var
  s, stemp,deprtShortName,deprtName,FirmName,SelfCommentary,temp,CurrencyContractName,CurrentContractNum,PayForm,Color,BKColor: string;
  i, Count, j, CurrentContractCode,ReprieveContract,ContractStatus,BlockCount,k: integer;
  Blocked: Boolean;
  DebtContract,CreditContractSum,ContractRedSum,ContractVioletSum,ContractOrderSum,ProfDebtAll:Double;

begin
  Result:='';
  s:='var flCredProfile='+BoolToStr(flCredProfile)+';'#13#10;
  s:=s+'var cTitleLegal="��. ����";'#13#10;
  s:=s+'var edit="'+edit+'";'#13#10;
  s:=s+'TStream.length=0;'#13#10;
  if flCredProfile then begin
    BlockCount:=Stream.ReadInt;
    s:=s+'TStream.BlockCount='+IntToStr(BlockCount)+';'#13#10;
    s:=s+'TStream.ContractId='+IntToStr(ContractId)+';'#13#10;
    s:=s+'TStream.arrtable=new Array();'#13#10;
    for k := 0 to BlockCount-1 do begin
      s:=s+'TStream.arrtable['+IntToStr(k)+']={';
      Count:=Stream.ReadInt; //rowspan="2"
      s:=s+'Count: '+IntToStr(Count)+', ';
      s:=s+'RowData: new Array()};'#13#10;
      for i := 0 to Count-1 do begin
        s:=s+'TStream.arrtable['+IntToStr(k)+'].RowData['+IntToStr(i)+']={ ';
        CurrentContractCode:=Stream.ReadInt;
        s:=s+'CurrentContractCode:'+IntToStr(CurrentContractCode)+', ';
        CurrentContractNum:=Stream.ReadStr;
        s:=s+'CurrentContractNum:"'+CurrentContractNum+'", ';
        j:=Stream.ReadInt;
        PayForm:=fnPayFormByCode(j);
        s:=s+'PayForm:"'+PayForm+'", ';
        FirmName:=Stream.ReadStr;
        s:=s+'FirmName:"'+FirmName+'", ';
        j:=Stream.ReadInt;
        stemp:='�.�.';
        case j of
          0: stemp:='';
          1: stemp:='���.';
        end;
        s:=s+'stemp:"'+stemp+'", ';
        deprtShortName:=Stream.ReadStr;
        deprtName:=Stream.ReadStr;
        s:=s+'deprtShortName:"'+deprtShortName+'", deprtName:"'+deprtName+'", ';
        CreditContractSum:=Stream.ReadDouble;
        s:=s+'CreditContractSum:"'+StringReplace(FormatFloat('# ##0.##', CreditContractSum),',','.',[rfReplaceAll])+'", ';
        CurrencyContractName:=Stream.ReadStr;
        s:=s+'CurrencyContractName:"'+CurrencyContractName+'", ';
        ReprieveContract:=Stream.ReadInt;
        s:=s+'ReprieveContract:'+IntToStr(ReprieveContract)+', ';
        ProfDebtAll:=Stream.ReadDouble;
        s:=s+'ProfDebtAll:"'+StringReplace(FormatFloat('# ##0.##', ProfDebtAll),',','.',[rfReplaceAll])+'", ';
        DebtContract:=Stream.ReadDouble;
        s:=s+'DebtContract:"'+fnIfStr(DebtContract=0,'',StringReplace(FormatFloat('# ##0.##', DebtContract),',','.',[rfReplaceAll]))+'", ';
        ContractOrderSum:=Stream.ReadDouble; // ������
        s:=s+'ContractOrderSum:"'+StringReplace(FormatFloat('# ##0.##', ContractOrderSum),',','.',[rfReplaceAll])+'", ';
        ContractStatus:=Stream.ReadInt;
        s:=s+'ContractStatus:'+IntToStr(ContractStatus)+', ';
        Blocked:=Stream.ReadBool;
        s:=s+'Blocked:'+BoolToStr(Blocked)+', ';
        stemp:=Stream.ReadStr;
        s:=s+'stemp:"'+stemp+'", ';
        ContractRedSum:=Stream.ReadDouble;
        s:=s+'ContractRedSum:"'+fnIfStr(ContractRedSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractRedSum),',','.',[rfReplaceAll]))+'", ';
        ContractVioletSum:=Stream.ReadDouble;
        s:=s+'ContractVioletSum:"'+fnIfStr(ContractVioletSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractVioletSum),',','.',[rfReplaceAll]))+'", ';
        SelfCommentary:=Stream.ReadStr;
        temp:=SelfCommentary;
        if (Length(SelfCommentary)>11) then  begin
          temp:=SelfCommentary;
          Delete(temp,8,Length(temp));
          temp:=temp+'...';
        end;
        s:=s+'temp:"'+temp+'",SelfCommentary:"'+SelfCommentary+'" ,';
        j:=getBackGrColor(stemp,ContractStatus,Blocked);
        BKColor:=arDelayWarningsColorRedisign[j];
        Color:=fnIfStr(j=1,'black','white');
        s:=s+'Color:"'+Color+'", BKColor:"'+BKColor+'", ContStatusNames:"'+ContStatusNames[ContractStatus]+'"';
        if not (ContractStatus in [0,1,2]) then begin
          Result:='jqswMessageError("�� ������ ������:'+IntToStr(ContractStatus)+'");'#13#10;
          Exit;
        end;
        s:=s+'};'#13#10;
      end;
    end;
  end
  else begin
    Count:=Stream.ReadInt;
    s:=s+' TStream.arlen='+IntToStr(Count)+'; '#13#10;
    s:=s+' TStream.arrtable= new Array(); '#13#10;
    for i := 0 to Count-1 do begin
      s:=s+' TStream.arrtable['+IntToStr(i)+']={';
      CurrentContractCode:=Stream.ReadInt;
      s:=s+'CurrentContractCode:'+IntToStr(CurrentContractCode)+', ';
      CurrentContractNum:=Stream.ReadStr;
      s:=s+'CurrentContractNum:"'+CurrentContractNum+'", ';
      j:=Stream.ReadInt;
      PayForm:=fnPayFormByCode(j);
      s:=s+'PayForm:"'+PayForm+'", ';
      FirmName:=Stream.ReadStr;
      s:=s+'FirmName:"'+FirmName+'", ';
      j:=Stream.ReadInt;
      stemp:='�.�.';
      case j of
         0: stemp:='';
         1: stemp:='���.';
      end;
      s:=s+'stemp:"'+stemp+'", ';
      deprtShortName:=Stream.ReadStr;
      deprtName:=Stream.ReadStr;
      s:=s+'deprtShortName:"'+deprtShortName+'", deprtName:"'+deprtName+'", ';
      CreditContractSum:=Stream.ReadDouble;
      s:=s+'CreditContractSum:"'+StringReplace(FormatFloat('# ##0.##', CreditContractSum),',','.',[rfReplaceAll])+'", ';
      CurrencyContractName:=Stream.ReadStr;
      s:=s+'CurrencyContractName:"'+CurrencyContractName+'", ';
      ReprieveContract:=Stream.ReadInt;
      s:=s+'ReprieveContract:'+IntToStr(ReprieveContract)+', ';
      DebtContract:=Stream.ReadDouble;
      s:=s+'DebtContract:"'+fnIfStr(DebtContract=0,'',StringReplace(FormatFloat('# ##0.##', DebtContract),',','.',[rfReplaceAll]))+'", ';
      ContractOrderSum:=Stream.ReadDouble; // ������
      s:=s+'ContractOrderSum:"'+StringReplace(FormatFloat('# ##0.##', ContractOrderSum),',','.',[rfReplaceAll])+'", ';
      ContractStatus:=Stream.ReadInt;
      s:=s+'ContractStatus:'+IntToStr(ContractStatus)+', ';
      if not (ContractStatus in [0,1,2]) then begin
          Result:='jqswMessageError("�� ������ ������:'+IntToStr(ContractStatus)+'");'#13#10;
          Exit;
      end
      else begin
        Blocked:=Stream.ReadBool;
        s:=s+'Blocked:'+BoolToStr(Blocked)+', ';
        stemp:=Stream.ReadStr;
        s:=s+'stemp:"'+stemp+'", ';
        ContractRedSum:=Stream.ReadDouble;
        s:=s+'ContractRedSum:"'+fnIfStr(ContractRedSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractRedSum),',','.',[rfReplaceAll]))+'", ';
        ContractVioletSum:=Stream.ReadDouble;
        s:=s+'ContractVioletSum:"'+fnIfStr(ContractVioletSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractVioletSum),',','.',[rfReplaceAll]))+'", ';
        SelfCommentary:=Stream.ReadStr;
        temp:=SelfCommentary;
        if (Length(SelfCommentary)>11) then  begin
          temp:=SelfCommentary;
          Delete(temp,8,Length(temp));
          temp:=temp+'...';
        end;
        s:=s+'temp:"'+temp+'",SelfCommentary:"'+SelfCommentary+'" ,';
        j:=getBackGrColor(stemp,ContractStatus,Blocked);
        BKColor:=arDelayWarningsColorRedisign[j];
        Color:=fnIfStr(j=1,'black','white');
        s:=s+'Color:"'+Color+'", BKColor:"'+BKColor+'", ContStatusNames:"'+ContStatusNames[ContractStatus]+'"';
        s:=s+'};'#13#10;
      end;
    end;
  end;
  s:=s+'New_getContractListWindow();'#13#10;
  Result:=s;
end;

function fnGetDestPointParams(Stream:TBoBMemoryStream) :string;// ���� ������ �������� �����
 var
   s, Name, ShortName:String;
   Count,Code, i:integer;
begin
  s:='TStream.length=0;'#13#10;
  s:=s+'TStream.arrArea=new Array();'#13#10;
  Count:=Stream.ReadInt;
  for i := 0 to Count-1 do begin
    Code:=Stream.ReadInt;
    Name:=Stream.ReadStr;
    s:=s+'TStream.arrArea['+IntToStr(i)+']={';
    s:=s+'AreaCode:'+IntToStr(Code)+', AreaName:"'+Name+'"';
    s:=s+'};'#13#10;
  end;
  s:=s+'TStream.arrCity=new Array();'#13#10;
  Count:=Stream.ReadInt;
  for i := 0 to Count-1 do begin
    Code:=Stream.ReadInt;
    Name:=Stream.ReadStr;
    ShortName:=Stream.ReadStr;
    s:=s+'TStream.arrCity['+IntToStr(i)+']={';
    s:=s+'CityCode:'+IntToStr(Code)+', CityName:"'+Name+'"'+', CityShortName:"'+ShortName+'"';
    s:=s+'};'#13#10;
  end;
  s:=s+'TStream.arrType=new Array();'#13#10;
  Count:=Stream.ReadInt;
  for i := 0 to Count-1 do begin
    Code:=Stream.ReadInt;
    Name:=Stream.ReadStr;
    ShortName:=Stream.ReadStr;
    s:=s+'TStream.arrType['+IntToStr(i)+']={';
    s:=s+'TypeCode:'+IntToStr(Code)+', TypeName:"'+Name+'"'+', TypeShortName:"'+ShortName+'"';
    s:=s+'};'#13#10;
  end;
  s:=s+'fillSelectsTTtable();'#13#10;
 Result:=s;
end;

function fnGetObm_JMAction(Stream:TBoBMemoryStream;ScriptName:string):string;
 var s1,s2:string;
begin
 Result:='';
 s1:=IntToStr(Stream.ReadInt);
 s2:=GetJSSafeString(Stream.ReadStr);
 if s2<>'' then Result:=Result+'jqswMessage("'+s2+'");';
 Result:=Result+'location.href="'+ScriptName+'/order?order='+s1+'&contract='+IntToStr(Stream.ReadInt)+'"; '#13#10;
end;





 end.
