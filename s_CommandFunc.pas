unit s_CommandFunc;

interface

uses Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
     DB, IBDatabase, IBSQL, IBQuery,JPEG,
     n_free_functions, v_constants, v_Functions, v_DataTrans,
     n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common,IniFiles, HTTPApp,s_Utils;

function fnShowNotification(Stream: TBoBMemoryStream; notifcode:String): string;
function fnSaveNotification(var userInf:TEmplInfo;Stream: TBoBMemoryStream; code: String;ThreadData: TThreadData): string;
function fnShowNotificationWA(Stream: TBoBMemoryStream;code:String): string;
function fnShowActionNews(var userInf:TEmplInfo; Stream: TBoBMemoryStream;id: String ): string;
function fnAEActionNews(var userInf:TEmplInfo;Stream: TBoBMemoryStream;ThreadData: TThreadData;NodeID: integer): string;
function fnDelActionNews(Stream: TBoBMemoryStream;id: String): string;
function fnEditSysOptions(Stream: TBoBMemoryStream;id: String): string;
function fnSaveSysOptions(Stream: TBoBMemoryStream;id: String): string;
function fnGetWebArmOptions(var userInf:TEmplInfo): string;
function fnAewausers(Stream: TBoBMemoryStream;NewId: integer): string;
function fnBlockWebArmUser(Stream: TBoBMemoryStream;id: string;command: string): string;
function fnSaveWebArmUser(Stream: TBoBMemoryStream;id: string): string;
function fnGetWareForProduct(Stream: TBoBMemoryStream;id: string;ignorespec: string;templ: string): string;
function fnGetOrignumAndAnalogs(var userInf:TEmplInfo; Stream: TBoBMemoryStream;tabnum: integer;ThreadData: TThreadData;id:String): string;
function fnGetmanufacturerlist(Stream: TBoBMemoryStream;selname:String;j:integer): string;
function fnWareSearch(var userInf:TEmplInfo; Stream: TBoBMemoryStream;var LogText: string;groups:String;waresearch:String;ignorspec:String;one_line_mode:String;forfirmid:String;Template: string): string;
function fnWebArmGetWaresDescrView(Stream: TBoBMemoryStream): string;
function fnRefreshTop10List(Stream: TBoBMemoryStream;Top10Cookie:String;Sys:integer): string;
function fnGetAttributeGroupList(Stream: TBoBMemoryStream;tablename:String): string;
function fnWebArmAutenticateNew(var userInf:TEmplInfo;psw:String;lgn:String;sid_:String;ip_:String;agent:String;ThreadData: TThreadData):integer;
function fnLoadFirms(Stream: TBoBMemoryStream): string;  // загрузить список контрагентов
function fnLoadPersons(Stream: TBoBMemoryStream;id:string): string; // загрузить список должностных лиц
function fnLoadOrder(Stream: TBoBMemoryStream): string;
function fnLoadManufactures(Stream: TBoBMemoryStream; sys: String): string;
function fnEditManufacturer(Stream: TBoBMemoryStream): string; // редактирует производителей авто/мото
function fnLoadModelLine(func:String;Stream: TBoBMemoryStream; rep:String; sys:String; id:String): string;
function fnDelTreeNode(Stream: TBoBMemoryStream; id:String): string;
function fnEditTreeNode(Stream: TBoBMemoryStream; id:String; mess:String; mainnode:String): string;
function fnAddTreeNode(Stream: TBoBMemoryStream;i:integer; id:String; mess:String; vis:String; newname:String): string;
function fnAddSubTreeNode(Stream: TBoBMemoryStream;i:integer; id:String; mess:String; vis:String; newname:String): string;
function fnShowPortion(Stream: TBoBMemoryStream;portion:String;mode:String;model:String;node:String;ware:String;UserID:String;ThreadData: TThreadData): string;
function fnGetCriteriaValues(Stream: TBoBMemoryStream;value:String): string;
function fnSavePortion(Stream: TBoBMemoryStream;ware:String;node:String;model:String): string;
function fnShowConditionPortions(Stream: TBoBMemoryStream;ware:String;node:String;model:String): string;
function fnMarkPortion(Stream: TBoBMemoryStream;ware:String;node:String;model:String): string;
function fnGetSatellites(var userInf:TEmplInfo; Stream: TBoBMemoryStream;id: String): string;
function fnGetAnalogs(var userInf:TEmplInfo; Stream: TBoBMemoryStream;id: String; is_on:String): string;
function fnLoadInvoice(Stream: TBoBMemoryStream;id:String): string;
function fnCheckContracts(Stream: TBoBMemoryStream): string;
function fnSaveAccHeaderPart(Stream: TBoBMemoryStream;partid: String;val: String; accid: String; annul:String): string;
function fnSelectContract(Stream: TBoBMemoryStream;ContractId:integer;invoiceid:String): string;
function fnShowWareCompare(Stream: TBoBMemoryStream;FirmID:String; ScriptName:String; ContractId:integer): string;
function fnLoadAccountList(Stream: TBoBMemoryStream; filterselectedfirm:String): string;
function fnWebArmGetTransInvoicesList(Stream: TBoBMemoryStream): string;
function fnCreateSubAcc(Stream: TBoBMemoryStream;id:String): string;
function fnDelLineFromInvoice(Stream: TBoBMemoryStream;wareid: String;linecode:String): string;
function fngetTimeListSelfDelivery(Stream: TBoBMemoryStream;OldTime: String): string;  //Получение список времен по дате для самовывоза
function fngetContractDestPointsList(Stream: TBoBMemoryStream;id: String;value: String;isEmpty: String): string;  //Получение список торговых точек
function fnfillParametrsAllWebArm(Stream: TBoBMemoryStream): string;   //вызывается для заполнения всех данных окна заказа при его открытии
function fnsaveParametrsFromWebArm(Stream: TBoBMemoryStream;v:integer; deliverydatetext:String; deliverydate: String): string;   //вызывается для сохранения данных окна заказа
function fnFillDeliverySheduler(Stream: TBoBMemoryStream;_tt:String;_deliverydate:String): string;   //вызывается для заполнения окна расписаний
function fngetDateListSelfDelivery(Stream: TBoBMemoryStream;flag:boolean;Olddate:String) : String;  //Получение список дат для окна доставки
function fnGetAttrListSelected(Stream: TBoBMemoryStream;selectname:String): String; // получить список  по выбранным атрибутам
function fnFillAttrListSelected(Stream: TBoBMemoryStream;selectname:String): String; // получить все списки и заполнить их заново
function fnGetAttrList(Stream: TBoBMemoryStream;id:String): string;
function fnGetWaresByAttr(var userInf:TEmplInfo;Stream: TBoBMemoryStream): string;
function fnGetNodeWares(Stream:TBoBMemoryStream; var userInf:TEmplInfo;ScriptName:String): string;
function fnShowFilter(Stream: TBoBMemoryStream; var userInf:TEmplInfo): string;
function fnLoadModelTree(Stream: TBoBMemoryStream; var userInf:TEmplInfo;pref:String): string;
function fnShareWareinfoAction(Stream: TBoBMemoryStream; var userInf:TEmplInfo;DescrImageUrl:String; ScriptName:String) :String;     //процедура общая для двух цги с целью открытия инфы об найденной товаре
function fnAddBrandLink(Stream: TBoBMemoryStream ): string;
function fnWebArmGetFirmList(Stream: TBoBMemoryStream;inputid:string;templ:string): string;
function fnGetRestsOfWares(Stream: TBoBMemoryStream): string;
function fnGetMPPRegOrds(Stream: TBoBMemoryStream): string;     // получить перечень заявок на регистрацию
function fnGetWareForSearch(Stream: TBoBMemoryStream; ErrMessKind: integer; tblname: string; var WareCode: string; var AnalogCount: integer; var Wares: string; isWebArm: boolean;ispodtowari:boolean=false): string;
function fnGetAnalogForSearch(Stream: TBoBMemoryStream; isWebArm: boolean; var Wares: string; WareCode: String; TypeCode:integer=0): string;
function fnLoadModelList(Stream: TBoBMemoryStream;tablename:String;sys:integer): string;
function fnLoadModellineList(Stream: TBoBMemoryStream;select:String): string;
function fnGetMPPAccountList(Stream: TBoBMemoryStream; var userInf:TEmplInfo): string;
function fnGetMotulSiteManageResult(Stream: TBoBMemoryStream; var userInf:TEmplInfo) :string;
function fnSaveBrandDetails(Stream: TBoBMemoryStream; var userInf:TEmplInfo; code: String; hideinprice:boolean; NotPictShow:boolean=false): string;

implementation
 uses s_WebArmProcedures, n_CSSThreads,n_WebArmProcedures,t_function;

//========================================== запись в строку сообщения об ошибке
procedure prSaveCommonErrorStr(var errStr:String; ThreadData: TThreadData;
          nmProc, Emess, MyText: String; flEBOB: Boolean; flPRS: Boolean=False);
var s: String;
begin
  if flEBOB then begin
    errStr:=fnReplaceQuotedForWeb(Emess);
    fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', Emess, MyText);
  end else begin
    s:= '';
    if flPRS then s:= CutPRSmess(Emess);
    if s='' then s:= MessText(mtkErrProcess);
    errStr:=s;
    fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', Emess, MyText);
  end;
end;


//==============================================================================
function  fnWebArmAutenticateNew(var userInf:TEmplInfo;psw:String;lgn:String;sid_:String;ip_:String;agent:String;ThreadData: TThreadData):integer;
const nmProc = 'prWebArmAutenticateNew'; // имя процедуры/функции
var sid, UserLogin, UserPsw, sParam, IP, Ident, ErrorPos, s,ss: string;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, i: integer;
    TimeNow: TDateTime;
    empl: TEmplInfoItem;
    flEnable: Boolean;
begin
  //Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBS:=  nil;
  empl:= nil;
  UserId:= -1;
  s:= '';
  try
    UserLogin:= trim(psw);
    UserPsw:= trim(lgn);
    sid:= trim(sid_);
    IP:= trim(ip_);
    Ident:= trim(agent);

    sParam:= 'Login='+UserLogin+#13#10'Password='+UserPsw+#13#10'sid='+sid+
             #13#10'IP='+IP+#13#10'Browser='+Ident;
    try
      if ((UserLogin+UserPsw+sid)='') then
        raise EBOBError.Create('Не заданы реквизиты аутентикации.');

      if (UserLogin<>'') then begin
        // сначала проверяем, есть ли такой логин в системе
        UserId:= Cache.GetEmplIDbyLogin(UserLogin);
        if (UserId=-1) then raise EBOBError.Create('Не найден логин '+UserLogin);
        //если задан параметр логин, то предполагаем наличие и пароля
        if (UserPsw='') then raise EBOBError.Create('Пустой пароль');

        empl:= Cache.arEmplInfo[UserId];
        if (empl.USERPASSFORSERVER<>UserPsw) then raise EBOBError.Create('Неверный пароль');
        if (empl.RESETPASSWORD) then raise EBoBAutenticationError.Create(IntToStr(aeResetPassword));
ErrorPos:='0-2';
        sid:= IntToStr(UserID)+'|'+fnGetSessionID;
        s:= ', EMPLSESSIONID="'+sid+'"';
ErrorPos:='1-0';

      end else begin // if (UserLogin<>'')
        if (sid='') then
          raise EBOBError.Create('Ошибка авторизации. Пустой идентификатор сесcии.');

        UserId:= Cache.GetEmplIDBySession(sid);
        if (UserId=-1) then
          raise EBOBError.Create('Ошибка авторизации. Идентификатор сесcии устарел или испорчен.');
        if (Copy(sid, 1, Pos('|', sid)-1)<>IntToStr(UserId)) then
          raise EBOBError.Create('Ошибка авторизации. Некорректный идентификатор сесcии.');

        empl:= Cache.arEmplInfo[UserId];
        if ((now-empl.LastActionTime)>Cache.GetConstItem(pcClientTimeOutWebArm).IntValue/24/60) then
          raise EBOBError.Create('Время действительности Вашей сессии истекло.'+
            ' Пройдите заново процедуру авторизации используя Ваши логин и пароль.');
ErrorPos:='1-5';
      end; //if (UserLogin<>'') else

      if (empl.Arhived) then
        raise EBOBError.Create('Ваша учетная запись заблокирована администратором GrossBee.');
      if (empl.Blocked) then
        raise EBOBError.Create('Ваша учетная запись заблокирована администратором werbarm.');

//-------------------------------------- nk
if flDisableOut then begin
      flEnable:= not empl.DisableOut;
      if not flEnable then begin // список шаблонов внутренних IP через запятую (192.168.,172.20.)
        ss:= trim(Cache.GetConstItem(pcInnerIPshablons).StrValue);
        flEnable:= (ss=''); // шаблоны не заданы
      end; // if not flEnable
      if not flEnable then with fnSplit(',', ss) do try // TStringList
        for i:= 0 to Count-1 do begin
          ss:= trim(Strings[i]);
          flEnable:= (copy(trim(IP), 1, length(ss))=ss);
          if flEnable then break;
        end;
      finally
        Free;
      end; // with fnSplit
      if not flEnable then
        raise EBOBError.Create('Запрещен доступ к Webarm не из сети Компании.'+
          cSpecDelim+'Запрос на предоставление доступа отправляйте на '+
          Cache.GetConstItem(pcUIKdepartmentMail).StrValue);
end;
//-------------------------------------- nk
      TimeNow:= Now();
      try
        ordIBD:= CntsOrd.GetFreeCnt;
        OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
ErrorPos:='1-10';
        OrdIBS.SQL.Text:= 'UPDATE EMPLOYEES SET EMPLLASTACTION=:TimeNow'+s+
                          ' WHERE EMPLCODE='+IntToStr(UserId);
        OrdIBS.ParamByName('TimeNow').AsDateTime:= TimeNow;
        s:= RepeatExecuteIBSQL(OrdIBS);
        if (s<>'') then raise Exception.Create(s);
      finally
        prFreeIBSQL(OrdIBS);
        cntsORD.SetFreeCnt(ordIBD);
      end;
ErrorPos:='1-15';
      if (UserLogin<>'') then Empl.Session:= sid;
      Empl.LastActionTime:= TimeNow;
ErrorPos:='2-0';
    finally
       prSetThLogParams(ThreadData, csWebArmAutentication, UserId, 0, sParam);
    end;
    Result:=aeSuccess;
    userInf.UserID:=IntToStr(UserID);
    userInf.SessionID:=sid;
    userInf.ServerTime:=Now();

    userInf.Roles:=Empl.UserRoles;
    userInf.ShowImportPage:=Cache.GetEmplAllowRepImp(UserID);
    userInf.Links23Loaded:=Cache.WareCacheUnLocked;
    userInf.SysOptions:=Cache.GetEmplConstantsCount(UserID)>0;

    userInf.UserName:=Empl.EmplShortName;
    userInf.ShowNewAttr:=Cache.GBAttributes.HasNewGroups;



    //Stream.WriteInt(UserID);
    //Stream.WriteStr(sid);
    //Stream.WriteDouble(Now());
ErrorPos:='2-5';
    //Stream.WriteIntArray(Empl.UserRoles);
ErrorPos:='2-6';
//    Stream.WriteBool(Cache.GetEmplAllowRepImp(UserID)); // признак наличия разрешенных отчетов/импортов у сотрудника
ErrorPos:='2-7';
    //Stream.WriteBool(Cache.WareCacheUnLocked);
ErrorPos:='2-8';
    //Stream.WriteBool(Cache.GetEmplConstantsCount(UserID)>0);
ErrorPos:='2-9';
    //Stream.WriteStr(Empl.EmplShortName);
ErrorPos:='2-10';
  except
    on E: EBoBAutenticationError do begin
      i:= StrToIntDef(E.Message, -1);
      //Stream.Clear;
      if (i=aeResetPassword) then begin
          Result:=aeResetPassword;
          userInf.UserID:=IntToStr(UserID);
          //Stream.WriteInt(i);
          //Stream.WriteInt(UserID);
      end else begin
        s:= 'Неизвестный код ошибки авторизации';
        Result:=aeCommonError;
        userInf.Error:=(s+' - '+E.Message);
        fnWriteToLog(ThreadData, lgmsUserError, nmProc, s, E.Message, '');
      end;
    end;
    on E: EBOBError do begin
                         Result:=aeCommonError;
                         prSaveCommonErrorStr(userInf.Error, ThreadData, nmProc, E.Message, '', True);
                        end;
    on E: Exception do begin
                         Result:=aeCommonError;
                         prSaveCommonErrorStr(userInf.Error, ThreadData, nmProc, E.Message, '', False);
                       end;
  end;
  //Stream.Position:= 0;
end;


function fnGetWareForSearch(Stream: TBoBMemoryStream; ErrMessKind: integer; tblname: string; var WareCode: string; var AnalogCount: integer; var Wares: string; isWebArm: boolean;ispodtowari:boolean=false): string;
var
  Brand, BrandWWW, BrandAdrWWW, AttrGroupCode, HasSatellite, Price, PriceO, CutPriceReason, MarginPrice, BonusPrice: string;
  Sale, NonReturn, CutPrice,flag,IsMoto,IsAuto: boolean;
  List: TStringList;
  k,ActionCode,RestSem,SysCount,iCode,i:integer;
  DirectName,ActionTitle,ActionText,WareName,UnitName,Description:string;
  arPrices: Array of String;
begin
  Result:='';
  CutPriceReason:='';
  WareCode:=IntToStr(Stream.ReadInt);
  Wares:=Wares+','+WareCode;
  AttrGroupCode:=IntToStr(Stream.ReadInt);
  AnalogCount:=Stream.ReadInt;
  HasSatellite:=fnIfStr(Stream.ReadInt>0,'true','false');
  Brand:=Stream.ReadStr;                                           // название бренда
  BrandWWW:=Stream.ReadStr;                                           // название бренда для лого
  BrandAdrWWW:=Stream.ReadStr;
  WareName:=GetJSSafeString(Stream.ReadStr);                                // адрес перехода на сайт поставщика
  Result:=Result+'awstl(document.getElementById('''+tblname+'''), '+WareCode+', '+AttrGroupCode+', '
                +'"'+Brand+'", "'+BrandWWW+'", "'+BrandAdrWWW+'", '
                +IntToStr(AnalogCount)+', '                                  //AnalogCount
                +HasSatellite+', '
                +'"'+WareName+'", ';                 // Warename
  Sale:=Stream.ReadBool;
  NonReturn:=Stream.ReadBool;
  CutPrice:=Stream.ReadBool;
  DirectName:=LowerCase(Stream.ReadStr);    //название направления для скидок
  UnitName:=GetJSSafeString(Stream.ReadStr);                                 // Unit
  Result:=Result+'"'+UnitName+'", ';                 // Unit
  ActionCode:=Stream.ReadInt;         // код акции
  ActionTitle:=Stream.ReadStr+' <br> ';      // заголовок
  ActionText:=Stream.ReadStr;       // текст
  ActionText:=StringReplace(ActionText,'\n','<br>',[rfReplaceAll]);
  ActionText:=GetJSSafeStringArg(ActionText);
  RestSem:=Stream.ReadInt; // семафор остатков: 0- красный, 2- зеленый, другое - нет
  if ispodtowari then
    SysCount:=2 // кол-во систем учета
  else
    SysCount:=Stream.ReadInt; // кол-во систем учета

  for i:= 0 to SysCount-1 do begin
    iCode:=Stream.ReadInt; // код системы учета
    flag:=Stream.ReadBool; // признак наличия моделей
    if iCode=constIsAuto then
      IsAuto:=flag;
    if iCode=constIsMoto then
      IsMoto:=flag;
  end;


  k:=0; SetLength(arPrices,Length(arPriceColNames));
  while (k<Length(arPriceColNames)) do begin
    arPrices[k]:=Stream.ReadStr;
    Inc(k);
  end;
  //Price:=Stream.ReadStr;   //если нужно вернуть колонки обратно
  //PriceO:=Stream.ReadStr;
  MarginPrice:=Stream.ReadStr;
  BonusPrice:=Stream.ReadStr;

  if (CutPrice and FileExists(DescrDir+'\waredescr\'+WareCode+'.html')) then begin
    List:=TStringList.Create;
    try
      List.LoadFromFile(DescrDir+'\waredescr\'+WareCode+'.html');
      CutPriceReason:=GetHTMLSafeString(StripHTMLTags(List.Text));
    finally
      prFree(List);
    end;
  end;

  Result:=Result+BoBBoolToStr(Sale)+', ';                              //Sale
  Result:=Result+BoBBoolToStr(NonReturn)+', ';                              //
  Result:=Result+BoBBoolToStr(CutPrice)+', ';                              //
  Result:=Result+'"'+DirectName+'", ';
  Result:=Result+'"'+IntToStr(ActionCode)+'", ';
  Result:=Result+'"'+ActionTitle+'", ';
  Result:=Result+'"'+ActionText+'", ';
  Result:=Result+'"'+IntToStr(RestSem)+'", ';
  Result:=Result+BoBBoolToStr(IsAuto)+', ';                              //
  Result:=Result+BoBBoolToStr(IsMoto)+', ';
  Result:=Result+''''+CutPriceReason+''', ';                              //
  k:=0;Result:=Result+'[';
  while (k<Length(arPriceColNames)) do begin
    if k<>Length(arPriceColNames)-1 then
      Result:=Result+'"'+arPrices[k]+'",'
    else
      Result:=Result+'"'+arPrices[k]+'"';
    Inc(k);
    end;
  Result:=Result+']," ",';
  //Result:=Result+'"'+Price+'", "'+PriceO+'", ';                  //  PriceR, PriceO
  Result:=Result+'"'+MarginPrice+'", "'+BonusPrice+'", ';                  //
  Description:=GetJSSafeStringArg(Stream.ReadStr);
  Result:=Result+'"'+Description;                        //Description
 if ispodtowari then
  Result:=Result+'", '+IntToStr(ErrMessKind)+',true);'#13#10  // не показывать в одну линию в поддтоварах
 else
   Result:=Result+'", '+IntToStr(ErrMessKind)+');'#13#10;



 if RestSem=2 then
   Result:=Result+' arrFindResGreen[arrFindResGreen.length]';
 if RestSem=0 then
   Result:=Result+' arrFindResRed[arrFindResRed.length]';
 if (RestSem<>0) and (RestSem<>2)  then
   Result:=Result+' arrFindResNone[arrFindResNone.length]';
 Result:=Result+'={ tblname: document.getElementById('''+tblname+'''),WareCode: '+WareCode+',AttrGroupCode: '+AttrGroupCode+', '
                +'Brand: "'+Brand+'",BrandWWW: "'+BrandWWW+'",BrandAdrWWW: "'+BrandAdrWWW+'",AnalogCount: '
                +IntToStr(AnalogCount)+',HasSatellite: '                                  //AnalogCount
                +HasSatellite+', '
                +'WareName: "'+WareName+'", '+'UnitName: "'+UnitName+'",Sale: ';
 Result:=Result+BoBBoolToStr(Sale)+',NonReturn: ';                              //Sale
 Result:=Result+BoBBoolToStr(NonReturn)+',CutPrice: ';                              //
 Result:=Result+BoBBoolToStr(CutPrice)+', ';                              //
 Result:=Result+'DirectName: "'+DirectName+'", ';
 Result:=Result+'ActionCode: "'+IntToStr(ActionCode)+'", ';
 Result:=Result+'ActionTitle: "'+ActionTitle+'", ';
 Result:=Result+'ActionText: "'+ActionText+'", ';
 Result:=Result+'RestSem: "'+IntToStr(RestSem)+'",IsAuto: ';
 Result:=Result+BoBBoolToStr(IsAuto)+',IsMoto:  ';                              //
 Result:=Result+BoBBoolToStr(IsMoto)+', ';
 Result:=Result+'CutPriceReason: '''+CutPriceReason+''', ';                              //
 k:=0; Result:=Result+'Prices: [';
 while (k<Length(arPriceColNames)) do begin
   if k<>Length(arPriceColNames)-1 then
     Result:=Result+'"'+arPrices[k]+'",'
   else
     Result:=Result+'"'+arPrices[k]+'"';
   Inc(k);
 end;
 Result:=Result+'],NoneStr: " ",';
   //Result:=Result+'"'+Price+'", "'+PriceO+'", ';                  //  PriceR, PriceO
 Result:=Result+'MarginPrice: "'+MarginPrice+'",BonusPrice: "'+BonusPrice+'", ';                  //
 Result:=Result+'Description: "'+Description;                        //Description
 if ispodtowari then
  Result:=Result+'",ErrMessKind: '+IntToStr(ErrMessKind)+',Online: true};'#13#10  // не показывать в одну линию в поддтоварах
 else
   Result:=Result+'",ErrMessKind: '+IntToStr(ErrMessKind)+'};'#13#10;
 SetLength(arPrices,0);
end;







// принимает пакет данных о применимости товаров в моделях
function fnGetModelApplicability(var userInf:TEmplInfo;Stream: TBoBMemoryStream; Wares: string; isWebArm, NeedDopWareDescr: boolean): string;
var
  i, WareCount: integer;
  NeedRests: boolean;
  Count:integer;
  WareCode,WareQv:String;
begin
  Result:='';
  NeedRests:=Stream.ReadBool;
// проставляем наличие моделей ++
  if (Stream.Size>=(Stream.Position+1)) then begin
    WareCount:=Stream.ReadInt;
    for i:=0 to WareCount-1 do begin
      Result:=Result+'$(''.smwu_'+IntToStr(constIsAuto)+'_'+IntToStr(Stream.ReadInt)+''').css(''display'', ''block'');'#13#10;
    end;
    WareCount:=Stream.ReadInt;
    for i:=0 to WareCount-1 do begin
      Result:=Result+'$(''.smwu_'+IntToStr(constIsMoto)+'_'+IntToStr(Stream.ReadInt)+''').css(''display'', ''block'');'#13#10;
    end;
  end;
// проставляем наличие моделей --
  //prMessageLOG('NeedRests='+BoolToStr(NeedRests));
  Count:=Stream.ReadInt;
  for i:=0 to Count-1 do begin
    WareCode:=IntToStr(Stream.ReadInt);
    WareQv:=IntToStr(Stream.ReadInt);
    if NeedRests then begin
      Result:=Result+'$(''.rm'+WareCode+''').css(''background-image'', ''url('+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/restmark'+WareQv+'.png)'');'#13#10;
      Result:=Result+'$(''.rm'+WareCode+'[title=""]'').attr(''title'', '''+fnIfStr(WareQv='0', 'Нет в наличии', 'Есть в наличии')+''');'#13#10;
    end;
  end;
  if NeedRests then begin
    if flNewModeCGI then
      if NeedDopWareDescr then Result:=Result+'ec("getaresdescrview", "warecodes='+Wares+fnifStr(isWebArm, '&forfirmid="+$("#forfirmid").val()+"&contract='+IntToStr(userInf.ContractID)+'"', '"')+', "newbj");'#13#10
    else
      if NeedDopWareDescr then Result:=Result+'ec("getaresdescrview", "warecodes='+Wares+fnifStr(isWebArm, '&forfirmid="+$("#forfirmid").val()+"&contract='+IntToStr(userInf.ContractID)+'"', '"')+', "abj");'#13#10;
    end;
  {else begin
    if NeedRests then begin
      Result:=Result+'ec("getrestsofwares", "warecodes='+Wares+fnifStr(isWebArm, '&forfirmid="+$("#forfirmid").val()+"', '')+'&contract='+IntToStr(ContractID)+'", "abj");'#13#10;
      if NeedDopWareDescr then Result:=Result+'ec("getaresdescrview", "warecodes='+Wares+fnifStr(isWebArm, '&forfirmid="+$("#forfirmid").val()+"&contract='+IntToStr(ContractID)+'"', '"')+', "abj");'#13#10;
    end;
  end; }
end;




function fnShowNotification(Stream: TBoBMemoryStream; notifcode:String): string;
var
  s: string;
begin
 s:='';
 try
   s:=s+'notifwindow("'+GetJSSafeStringArg(Stream.ReadStr)+'", '+notifcode+');'#13#10
 finally
   Result:=s;
 end;
end;  // fnShowNotification

function fnSaveNotification(var userInf:TEmplInfo; Stream: TBoBMemoryStream; code: String;ThreadData: TThreadData): string;
var
  s, nmProc,Error : string;
  i, j: integer;
begin
  s:='';
  try
    if StrToIntDef(code, 0)<0 then begin
      s:=s+'delrowbycode("tablecontent", '+Copy(trim(code), 2, 10000)+', true);'#13#10;
    end else begin
      i:=Stream.ReadInt;
      Stream.Clear;
      Stream.WriteInt(StrToInt(userInf.UserID));
      Stream.WriteInt(i);
      nmProc := 'prWebArmGetNotificationsParams'; // имя процедуры/функции
      prWebArmGetNotificationsParams(Stream,ThreadData);
      if Stream.ReadInt=aeSuccess then begin
        j:=Stream.ReadInt;
        for i:=1 to j do begin
          s:=s+'aenotifyrow(';
          s:=s+IntToStr(Stream.ReadInt); //code
          s:=s+', "'+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+'"'; //from
          s:=s+', "'+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+'"'; //to
          s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; //text
          s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // Редакт
          s:=s+', "'+FormatDateTime('dd.mm.yy hh:nn', Stream.ReadDouble)+'"'; // Дата ред.
          s:=s+', '+IntToStr(Stream.ReadInt); // Всего к/а
          s:=s+', '+IntToStr(Stream.ReadInt); // Ознакомленных к/а
          s:=s+', '+IntToStr(Stream.ReadInt); // Ознакомленных пользователей
          s:=s+');'#13#10;
        end;
        s:=s+'$(''#aenotificationdiv'').dialog(''close'');'#13#10;
        s:=s+'zebratable($("#tablecontent")[0]);'#13#10;
      end
      else begin
       Error:=Stream.ReadStr;
       prMessageLog(Error);
       s:='jqswMessageError(''Ошибка выполнения: '+GetHTMLSafeString(Error)+''')';
      end;
    end;

  finally
    Result:=s;
  end;
end; //fnSaveNotification

function fnShowNotificationWA(Stream: TBoBMemoryStream;code:String): string;
var
  s, temp : string;
  Count, i, j: integer;
begin
  s:='';
  try
    s:=s+'$(''#fromdate'').val("'+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+'");'#13#10;
    s:=s+'$(''#todate'').val("'+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+'");'#13#10;
    s:=s+'$(''#notiftext'').val("'+GetJSSafeStringArg(Stream.ReadStr)+'");'#13#10;
    s:=s+'$(''#clienttype'').val(["'+StringReplace(Stream.ReadStr, ',', '","', [rfReplaceAll])+'"]);'#13#10;
    s:=s+'$(''#clientcategory'').val(["'+StringReplace(Stream.ReadStr, ',', '","', [rfReplaceAll])+'"]);'#13#10;
    s:=s+'$(''#clientfilial'').val(["'+StringReplace(Stream.ReadStr, ',', '","', [rfReplaceAll])+'"]);'#13#10;
    s:=s+'$(''#individualclientsmethod'').val("'+fnIfStr(Stream.ReadBool, '0', '1')+'");'#13#10;
    s:=s+'$(''#clientauto'')[0].checked='+BoBBoolToStr(Stream.ReadBool)+';'#13#10;
    s:=s+'$(''#clientmoto'')[0].checked='+BoBBoolToStr(Stream.ReadBool)+';'#13#10;
    Count:=Stream.ReadInt;
    for i := 1 to Count do begin
      j:=Stream.ReadInt;
      temp:=Stream.ReadStr;
      s:=s+'$(''#notiffirms'').attr("code", "'+IntToStr(j)+'").attr("firmname", "'+temp+'");'#13#10'addnotifyfirtotbl(); '#13#10;
    end;
    s:=s+'$(''#aenotificationdiv'').attr(''code'', '''+code+''').dialog(''open'');'#13#10;
  finally
    Result:=s;
  end;
end; //fnShowNotification

function fnShowActionNews(var userInf:TEmplInfo; Stream: TBoBMemoryStream;id: String ): string;
var
  s: string;
begin

  try
   s:='';
   s:=s+'shownewsaedialog(true);'#13#10;
   s:=s+'$(''#divtitle'').html(''Редактирование новости'');'#13#10;
   s:=s+'$(''#newssubmit'').attr(''value'', ''Сохранить изменения'');'#13#10;
   s:=s+'$(''#imguserid'').attr(''value'', '''+(userInf.UserID)+''');'#13#10;
   s:=s+'$(''.imgloaddiv'').css(''display'', ''block'');'#13#10;
   s:=s+'$(''#scrname'').attr(''value'', '''+ScriptName+'/difdict'');'#13#10;
   s:=s+'$(''#imgnewsid'').attr(''value'', '''+id+''');'#13#10;
   s:=s+'$(''#newsid'').attr(''value'', '''+IntToStr(Stream.ReadInt)+''');'#13#10;
   s:=s+'$(''#forauto'')[0].checked='+fnIfStr(Stream.ReadBool, 'true', 'false')+';'#13#10;
   s:=s+'$(''#formoto'')[0].checked='+fnIfStr(Stream.ReadBool, 'true', 'false')+';'#13#10;
   s:=s+'$(''#inframe'')[0].checked='+fnIfStr(Stream.ReadBool, 'true', 'false')+';'#13#10;
   s:=s+'$(''#fromdate'').attr(''value'', '''+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+''');'#13#10;
   s:=s+'$(''#todate'').attr(''value'', '''+FormatDateTime('dd.mm.yy', Stream.ReadDouble)+''');'#13#10;
   s:=s+'$(''#priority'').attr(''value'', '''+IntToStr(Stream.ReadInt)+''');'#13#10;
   s:=s+'$(''#caption'').attr(''value'', '''+GetHTMLSafeString(Stream.ReadStr)+''');'#13#10;
   s:=s+'$(''#link'').attr(''value'', '''+Stream.ReadStr+''');'#13#10;
   s:=s+'$(''#newsimg'').attr(''src'', '''+fnGetThumb(fnTestDirEnd(BaseDir, true)+'/images/actions/'+Stream.ReadStr, 160, 300,'server.ini')+''');'#13#10;    //vv
   s:=s+'$(''#newsimg'').css(''display'', ''block'');'#13#10;
  finally
    Result:=s;
  end;
end; // fnShowActionNews

function fnAEActionNews(var userInf:TEmplInfo; Stream: TBoBMemoryStream;ThreadData: TThreadData;NodeID: integer): string;
var
  s: string;
  id:integer;
begin
  try
   s:='';
   id:=Stream.ReadInt;
   if (NodeID=-1) then begin
     Stream.Clear;
     Stream.WriteInt(StrToInt(userInf.UserID));
     Stream.WriteInt(id);
     prShowActionNews(Stream, ThreadData);
     if Stream.ReadInt=aeSuccess then begin
        s:=fnShowActionNews(userInf,Stream,IntToStr(id));
      end else begin
        s:='jqswMessageError('''+Stream.ReadStr+''')';
      end;
    end else begin
      s:=s+'alert("Изменения внесены успешно");'#13#10;
      s:=s+'reloadpage();'#13#10;
    end;
  finally
    Result:=s;
  end;
end; // fnAEActionNews

function fnDelActionNews(Stream: TBoBMemoryStream;id: String): string;
var
  s: string;
begin
  s:='';
  try
    s:=s+'var newstbl_=$("#newsln'+id+'")[0].parentNode;'#13#10;
    s:=s+'newstbl_.deleteRow($("#newsln'+id+'")[0].rowIndex);'#13#10;
  finally
    Result:=s;
  end;
end; //fnDelActionNews


function fnEditSysOptions(Stream: TBoBMemoryStream;id: String): string;
var
  s, ss: string;
  Count, i, Code, CurCode: integer;
begin
  s:='';
  ss:='';
  try
    case StrToInt(id) of
      pcEmplID_list_Rep30, pcTestingSending1, pcTestingSending2, pcTestingSending3, pcEmpl_list_UnBlock, pcEmpl_list_TmpBlock, pcEmpl_list_FinalBlock, pcVINmailEmpl_list,
      pcVINmailFilial_list, pcVINmailFirmClass_list, pcVINmailFirmTypes_list, pcPriceLoadFirmClasses
      : begin
         ss:=ss+'Для выбора нескольких значений или их удаления нажмите и удерживайте Ctrl<br /><SELECT multiple size=18 id=sysoptionnewvalue>';
         Count:=Stream.ReadInt;
         for i:=0 to Count-1 do begin
           ss:=ss+'<OPTION value='+IntToStr(Stream.ReadInt)+fnIfStr(Stream.ReadBool, ' selected', '')+'>'+GetHTMLSafeString(Stream.ReadStr);
         end;
         ss:=ss+'</SELECT>';
         ss:=ss+'<br/><input type=button value=\"Сохранить\" onclick=\"var val=$(''#sysoptionnewvalue'').val(); ec(''savesysoption'', ''id='+id+'&value=''+((val==null)?'''':val), ''difdict'');\"></center>';
         s:=s+'sw("'+ss+'");';
       end;
       pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto: begin
         ss:=ss+'<SELECT id=sysoptionnewvalue>';
         Code:=Stream.ReadInt;
         Count:=Stream.ReadInt;
         for i:=0 to Count do begin
           CurCode:=Stream.ReadInt;
           ss:=ss+'<OPTION value='+IntToStr(CurCode)+fnIfStr(CurCode=Code, ' selected', '')+'>'+GetHTMLSafeString(Stream.ReadStr);
         end;
         ss:=ss+'</SELECT>';

         ss:=ss+'<br/><input type=button value=\"Сохранить\" onclick=\"var val=$(''#sysoptionnewvalue'').val(); ec(''savesysoption'', ''id='+id+'&value=''+((val==null)?'''':val),'+fnIfStr(flNewModeCGI,'''newbj''', '''difdict''')+ ');\"></center>';

         s:=s+'sw("'+ss+'");';
       end;
       else
          s:=s+'jqswMessageError(''Неопознанный код константы.'')';
        end;



  finally
    Result:=s;
  end;
end; // fnEditSysOptions


function fnSaveSysOptions(Stream: TBoBMemoryStream;id: String): string;
var
  s: string;
  LastTime: double;
  Adapred,FIO:String;
begin
  s:='';
  try
    Adapred:=Stream.ReadStr;
    FIO:=Stream.ReadStr;
    LastTime:=Stream.ReadDouble;
    s:=s+'$.fancybox.close();'#13#10;
    s:=s+'$("#so_td'+id+'").html("'+GetJSSafeStringArg(Adapred)+'");'#13#10;
    s:=s+'$("#so_ln'+id+'")[0].cells[5].innerHTML="'+GetJSSafeStringArg(FIO)+'";'#13#10;
    s:=s+'$("#so_ln'+id+'")[0].cells[6].innerHTML="'+FormatDateTime(cDateTimeFormatY4N, LastTime)+'";'#13#10;
  finally
    Result:=s;
  end;
end; // fnSaveSysOptions

function fnGetWebArmOptions(var userInf:TEmplInfo): string;
var
  s: string;
begin
 try
   s:=s+'<fieldset style="width: auto;"><legend>Опции поиска</legend>';
   s:=s+'<input style=''position: relative; top: 2px; left: -4px;'' type=checkbox title="В назв. товаров не будут учитываться все символы # ! (пробел) , ; : - . [ ] / + № (  ) \ '' "'+
   ' id=ignorspec name=ignorspec '+fnIfStr((userInf.strCookie.Values['ignorspec']='true'), 'checked', '')+' onClick="svtc(this.name, this.checked);">Игнорировать&nbsp;спецсимволы';
   s:=s+'</br><input style=''position: relative; top: 2px; left: -4px;'' type=checkbox id=one_line_mode name=one_line_mode '+fnIfStr((userInf.strCookie.Values['one_line_mode']='true'), 'checked', '')
   +' onClick="svtc(this.name, this.checked);csrw(0);one_line=this.checked;">Выводить описания товаров в правой колонке';
   s:=s+'</br><input style=''position: relative; top: 2px; left: -4px;'' type=checkbox id=show_in_uah name=show_in_uah '+fnIfStr((userInf.strCookie.Values['show_in_uah']='true'), 'checked', '')+' onClick="svtc(this.name, this.checked);csrw(0);">Показывать цены в гривне';
   s:=s+'</fieldset>';
   if flNewModeCGI then begin
     s:=s+'<form method=post onSubmit="return sfbaNew(this);">';
     s:=s+'<fieldset style="width: auto;margin-top: 10px;"><legend>Сменить пароль</legend>';
     s:=s+'<input type=hidden name=act value=changepass>';
     s:=s+'<table style="font-size: 11px;">';
     s:=s+'<tr><td align=right>Старый пароль:</td><td><input type=password class=input1 name=opass></td></tr>';
     s:=s+'<tr><td align=right>Новый пароль:</td><td><input type=password class=input1 name=npass1></td></tr>';
     s:=s+'<tr><td align=right>Новый пароль (повторно):</td><td><input type=password class=input1 name=npass2></td></tr>';
     s:=s+'<tr><td align=right><input type=submit value="Изменить пароль"></td><td><input type=reset value="Сброс"></td></tr>';
     s:=s+'</table>';
     s:=s+'</fieldset>';
     s:=s+'</form>';
   end;
  s:=fnWriteSimpleText(s);
 finally
   Result:=s;
 end;
end; // fnSaveSysOptions

function fnAewausers(Stream: TBoBMemoryStream;NewId: integer): string;
var
  s,s2: string;
  iMaxBrand,i:integer;
begin
try
  OnReadyScript:='';
  s:='';
  iMaxBrand:=Stream.ReadInt;
  s:=s+' TStream.arlen='+IntToStr(iMaxBrand)+'; '#13#10;
  s:=s+' TStream.artable= new Array(); '#13#10;
  for i:=0 to iMaxBrand do begin
    s:=s+' TStream.artable['+IntToStr(i)+']=new Array('+IntToStr(Stream.ReadInt)+','''+Stream.ReadStr+''');';
  end;
  iMaxBrand:=Stream.ReadInt;
  s:=s+' TStream_.arlen='+IntToStr(iMaxBrand)+'; '#13#10;
  s:=s+' TStream_.artable= new Array(); '#13#10;
  for i:=0 to iMaxBrand -1 do begin
    s:=s+' TStream_.artable['+IntToStr(i)+']=new Array('''+Stream.ReadStr+''');';
  end;
  s:=s+#13#10;
  //s:=s+' getWATableEditUsers(TStream,TStream_,'''+ScriptName+''','+IntToStr(NewId)+'); '#13#10;


  (*
  s:=s+'<form action="'+ScriptName+'/abj" onSubmit="return sfba(this);"><input type=hidden name=act value=savewausers><input type=hidden name=id value="'+IntToStr(NewId)+'"><div>';
  s:=s+'<h1 style="margin-top:0;">'+fnIfStr(NewId=-1, 'Добавить пользователя', 'Изменить данные пользователя')+'</h1>';

  s:=s+'<table style="font-size: 12px;">';
  s:=s+'<tr><td class="b r">Логин: </td><td><input type=text id=login name=login maxlength=20 size=20></td></tr>';
  s:=s+'<tr><td class="b r">Пароль: </td><td><input type=text id=pass name=pass maxlength=20 size=20></td></tr>';
  s:=s+'<tr><td class="b r">Сотрудник: </td><td><select id=code name=code>';

  iMaxBrand:=Stream.ReadInt;
  for i:=0 to iMaxBrand do begin
    s:=s+'<option value='+IntToStr(Stream.ReadInt)+'>'+Stream.ReadStr+'</option>';
  end;
  s:=s+'</select></td></tr>';

  s1:='<option value=""></option>';
  iMaxBrand:=Stream.ReadInt;
   for i:=0 to iMaxBrand do begin
     s2:=Stream.ReadStr;
     s1:=s1+'<option value='+s2+'>'+s2+'</option>';
   end;

   s:=s+'<tr><td class="b r">Подразделение: </td><td><select id=dprt name=dprt>';
   s:=s+'</select></td></tr>';

   s:=s+'<tr><td class="b r">Логин&nbsp;GrossBee&nbsp;осн.: </td><td><select id=gbuser name=gbuser>'+s1;
   s:=s+'</select></td></tr>';

   s:=s+'<tr><td class="b r">Логин&nbsp;GrossBee&nbsp;отч.: </td><td><select id=gbuserreport name=gbuserreport>'+s1;
   s:=s+'</select></td></tr>';

   s:=s+'<tr><td colspan=2 class="b">';
   s:=s+'Права пользователя:';
   s:=s+'</td></tr>';

   s:=s+'<tr><td id=tdroles colspan=2 style="height: 200px;">';
   s:=s+'<tr><td colspan=2 align=center>';
   s:=s+'<input type=submit value="Сохранить">&nbsp;<input type=button value="Выйти" onclick="$.fancybox.close();">';
   s:=s+'</td></tr>';
   s:=s+'</table>';


   s:=s+'</div></form>';*)

   s:=s+'sw(getWATableEditUsers(TStream,TStream_,'''+ScriptName+''','+IntToStr(NewId)+'), true);'#13#10;

   s:=s+'var s="";'#13#10;
   s:=s+'for (var i = 0, length = roles.length; i<length; i++) {'#13#10;
   s:=s+'  if (i in roles) {'#13#10;
   s:=s+'       s+="<input type=checkbox name=r_"+i+" id=r_"+i+">"+roles[i]+"<br />";'#13#10;
   s:=s+'  }'#13#10;
   s:=s+'}'#13#10;
   s:=s+'$("#tdroles").html(s)'#13#10;

   s:=s+'$("#dprt").html(dprtstr)'#13#10;

   if (NewID>-1) then begin
     s:=s+'$("#login").attr("value", "'+Stream.ReadStr+'")'#13#10;
     s:=s+'$("#login").attr("disabled", "true")'#13#10;
     s:=s+'$("#code").attr("disabled", "true")'#13#10;
     s:=s+'$("#pass").attr("value", "'+Stream.ReadStr+'")'#13#10;
     s:=s+'$("#dprt").attr("value", "'+Stream.ReadStr+'")'#13#10;
     s:=s+'$("#gbuser").attr("value", "'+Stream.ReadStr+'")'#13#10;
     s:=s+'$("#gbuserreport").attr("value", "'+Stream.ReadStr+'")'#13#10;
     if Stream.ReadBool then
       s:=s+'$("#disableoutipcheck").attr("checked", "true");'#13#10;
     iMaxBrand:=Stream.ReadInt;
     for i:=0 to iMaxBrand do begin
       s2:=IntToStr(Stream.ReadInt);
       s:=s+'$("#r_'+s2+'").attr("checked", "true")'#13#10;
     end;
   end;

   s:=s+''#13#10;

finally
  Result:=s;
end;
end; // fnSaveSysOptions

function fnBlockWebArmUser(Stream: TBoBMemoryStream;id: string;command: string): string;
var
  s: string;
begin
  try
   s:=s+'var blockbtn=$(''#tr'+id+' .blockbtn'');'#13#10;
   s:=s+'blockbtn.attr("command", "'+fnIfStr(command='block', 'unblock', 'block')+'");'#13#10;
   s:=s+'blockbtn.val("'+fnIfStr(command='block', 'Разблокировать', 'Блокировать')+'");'#13#10;
  finally
    Result:=s;
  end;
end; // prBlockWebArmUser

function fnSaveWebArmUser(Stream: TBoBMemoryStream;id: string): string;
var
  s: string;
  NewId:integer;
begin
  try
   NewId:=Stream.ReadInt;
   if id=IntToStr(NewId) then begin
     s:='jqswMessage("Изменения внесены успешно");';
     s:=s+'$("#tr'+IntToStr(NewId)+'")[0].cells[1].innerHTML=$("#login").attr("value");'#13#10;
     s:=s+'$("#tr'+IntToStr(NewId)+'")[0].cells[3].innerHTML=dprt[$("#dprt").attr("value")];'#13#10;
     s:=s+'$("#tr'+IntToStr(NewId)+'")[0].cells[4].innerHTML=$("#gbuser").attr("value");'#13#10;

     end else begin
       s:=s+'var j=-1;'#13#10; //
       s:=s+'for (i=0; (i<$("#tablecontent")[0].rows.length) && (j==-1); i++) {'#13#10; //
       s:=s+'  if ('+IntToStr(NewId)+'<parseInt($("#tablecontent")[0].rows[i].id.substr(2))) j=i;'#13#10; //
       s:=s+'}'#13#10; //

       s:=s+'jqswMessage("Пользователь добавлен успешно");'#13#10;

       s:=s+'waul(j, '+IntToStr(NewId)+', '; // Код
       s:=s+'$("#login").attr("value"), '; // Логин
       s:=s+'$("#code").attr("value"), '; // ФИО
       s:=s+'$("#dprt").attr("value"), '; // Код Подразделения
       s:=s+'$("#gbuser").attr("value")'; // Логин GrossBee
       s:=s+');'#13#10; //
       s:=s+'zebratable($("#tablecontent")[0]);'#13#10;
     end;

     s:=s+'$.fancybox.close();'#13#10; //
  finally
    Result:=s;
  end;
end; // prBlockWebArmUser

// выдать товары заданного продукт-менеджера
function fnGetWareForProduct(Stream: TBoBMemoryStream;id: string;ignorespec: string;templ: string): string;
var
  s, WareCode: string;
  i,iMaxWare: integer;
  Path: string;
  Attr: Integer;
  F: TSearchRec;
  flag:boolean;//для иконок, найдена картингка или нет
begin
  s:='';
  try
    s:=s+'var tbl_=document.getElementById(''searchrestable'');'#13#10;
    s:=s+'while (tbl_.rows.length) tbl_.deleteRow(0);'#13#10;
    s:=s+'var altrow=false;'#13#10;
    Attr := faAnyFile;
    {Если хотя бы один файл найден, то продолжить поиск}

    iMaxWare := Stream.ReadInt;
    for i := 1 to iMaxWare do begin
      WareCode:=IntToStr(Stream.ReadInt);
      Path := DescrDir+'\wareimages\'+WareCode+'*';
      flag:=false;
      if FindFirst(Path, Attr, F)=0 then   begin
        flag:=true;
      end;
      SysUtils.FindClose(F);
      s:=s+'addwaretosearchlist(' + WareCode+ {код товара}
      ', ' + IntToStr(Stream.ReadInt)+ {код бренда}
      ', ' + IntToStr(Stream.ReadInt)+ {код группы}
      ', "' +StringReplace(AnsiToUtf8(Stream.ReadStr), '"', '`',[rfReplaceAll, rfIgnoreCase]) +'"'+
      ', '+fnIfStr(flag, '1', '0')+
      ', '+fnIfStr(FileExists(DescrDir+'\waredescr\'+WareCode+'.html') and (n_free_functions.GetFileSize(DescrDir+'\waredescr\'+WareCode+'.html')>12), '1', '0')+
      ', '+fnIfStr(flag and (n_free_functions.GetFileSize(DescrDir+'\wareimages\'+WareCode+'.jpg')>128*1024), 'true', 'false')+
      ');'#13#10; {наименование товара}
    end;

    s:=s+'$(''a[id^="srware_"]'').bind(''click'', function(event) {'#13#10;
    s:=s+'  $("#workareaWrap").removeClass("noactive");'#13#10;
    if flNewModeCGI then
      s:=s+'  ec("getorignumandanalogs", "id="+this.id.substr(7)+"&newware=1&tab="+tabnum, "newbj") ;'#13#10
    else
      s:=s+'  ec("getorignumandanalogs", "id="+this.id.substr(7)+"&newware=1&tab="+tabnum, "pabj") ;'#13#10;
    s:=s+'  this.title="Получить дополнительные данные по товару";'#13#10;
    s:=s+'});'#13#10;

    if (trim(id)<>'') then begin
      s:=s+'$(''#searchresWrap h1'').html(''Группа "''+$("#ali_'+trim(id)+'").html()+''" '');'#13#10;
    end else begin
        s:=s+'$(''#searchresWrap h1'').html(''Строка "'+trim(templ)+'" игнор.'+fnIfStr(UpperCase(trim(ignorespec))='ON','вкл','выкл')+''');'#13#10;
    end;
    s:=s+'$(''#searchres'').scrollTop(0);'#13#10;
 finally
    Result:=s;
  end;
end;// fnGetWareForProduct

function fnGetOrignumAndAnalogs(var userInf:TEmplInfo; Stream: TBoBMemoryStream;tabnum: integer;ThreadData: TThreadData;id:String): string;
 var
  StreamNew:TBoBMemoryStream;
  i,iMaxBrand,iMaxWare, Count:integer;
  mancode,manname: String;
  Ret:boolean;
  s3, WaresS: string;
  Wares: Tai;
begin
 Result:='';
 iMaxWare:=0;
 WaresS:='-1';

 case tabnum of
   1: begin
     Stream.WriteInt(StrToInt(id));
     Stream.WriteByte(0); // признак передачи правильных оригинальных номеров
     prProductGetOrigNumsAndWares(Stream,ThreadData);
     if Stream.ReadInt=aeSuccess then begin
       Result:=Result+'$(''#addornumbyhand'').css(''display'', ''block'');'#13#10;
       StreamNew:=TBoBMemoryStream.Create;
       StreamNew.Clear;
       StreamNew.WriteInt(isWe);
       StreamNew.WriteInt(StrToInt(userInf.UserID));
       StreamNew.WriteInt(1); // 0 - все производители
       StreamNew.WriteBool(false);    // в остальных случаях - не показывать невидимые
       prGetManufacturerList(StreamNew,ThreadData);
       if StreamNew.ReadInt=aeSuccess then begin
         iMaxBrand := StreamNew.ReadInt;
         for i := 1 to iMaxBrand do begin
           mancode:=IntToStr(StreamNew.ReadInt);
           manname:=StreamNew.ReadStr;
           Result:= Result + 'manufactureselect+=''<option value="'+mancode+'">'+GetJSSafeString(manname)+'</option>'';'#13#10;
           StreamNew.ReadBool;
           Ret:=StreamNew.ReadBool;
           Ret:=(StreamNew.ReadBool and Ret);
           StreamNew.ReadBool; // признак видимости
         end;
       end
       else begin
         Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
       end;
       StreamNew.Free;

       Result:=Result+'var altrow=false;'#13#10;
       Result:=Result+'var tbl_=document.getElementById(''orignumstable'');'#13#10;
       iMaxWare := Stream.ReadInt;
       if (iMaxWare=0) then begin
         Result:=Result+'addorignum(0, 0, 0, "", "");'#13#10; {код ориг.номера}
       end
       else
         for i := 1 to iMaxWare do begin
           Result:=Result+'addorignum(' + IntToStr(Stream.ReadInt)+ {код ориг.номера}
           ', ' + IntToStr(Stream.ReadInt)+ {код производ.авто}
           ', ' + IntToStr(Stream.ReadByte)+ {код источника}
           ', "' + Stream.ReadStr +'", "' + GetJSSafeString(Stream.ReadStr) +'");'#13#10; {наименование оригинального номера и производителя авто}
         end;
       Result:=Result+'$(''#waredetdiv1 h1:first'').html(''Оригинальные номера товара "''+$("#srware_'+trim(id)+'").html()+''" '');'#13#10;
//     Result:=Result+'$(''#waredetdiv4 h1'').html(''Неправильные оригинальные номера товара "''+$("#srware_'+trim(Request.ContentFields.Values['id'])+'").html()+''"'');'#13#10;

     end else begin
                Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
              end;

     Stream.Clear;
     Stream.WriteInt(StrToInt(userInf.UserID));
     Stream.WriteInt(StrToInt(id));
     Stream.WriteByte(1); // признак передачи неправильных оригинальных номеров
     prProductGetOrigNumsAndWares(Stream,ThreadData);
     if Stream.ReadInt=aeSuccess then begin
       Result:=Result+'var altrow=false;'#13#10;
       Result:=Result+'var tbl_=document.getElementById(''wrongoetable'');'#13#10;
       iMaxWare := Stream.ReadInt;
       if (iMaxWare=0) then begin
         Result:=Result+'addorignum(0, 0, 0, "");'#13#10; {код ориг.номера}
       end else
         for i := 1 to iMaxWare do begin
           Result:=Result+'addorignum(' + IntToStr(Stream.ReadInt)+ {код ориг.номера}
           ', ' + IntToStr(Stream.ReadInt)+ {код производ.авто}
           ', ' + IntToStr(Stream.ReadByte)+ {код источника}
           ', "' + Stream.ReadStr +'", "' + GetJSSafeString(Stream.ReadStr) +'", "' + GetJSSafeString(Stream.ReadStr) +'");'#13#10; {наименование товара}
         end;
         Result:=Result+'tabvis(tabnum);'#13#10;
     end else begin
       Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
     end;


   end; // case 1 *)
  2: begin
       Stream.WriteInt(isWe);
       Stream.WriteInt(gwlAnalogsGB);
       Stream.WriteStr(id);
       prGetWareList(Stream,ThreadData);
       if Stream.ReadInt=aeSuccess then begin
         Result:=Result+'var tbl_=document.getElementById(''gbanalogtable'');'#13#10;
         Result:=Result+'var altrow=false;'#13#10;
         iMaxWare := Stream.ReadInt;
         if (iMaxWare=0) then begin
           Result:=Result+'var row=tbl_.insertRow(-1);'#13#10;
           Result:=Result+'var newcell=row.insertCell(-1);'#13#10;
           Result:=Result+'newcell.innerHTML=''У этого товара нет аналогов в GrossBee'';'#13#10;
         end
         else
           for i := 1 to iMaxWare do begin
             Result:=Result+fnGetWareForSearch(Stream, -100, 'gbanalogtable', s3, Count, WaresS, true,true);
           end;
         Result:=Result+'$(''#waredetdiv2 h1'').html(''Аналоги товара "''+$("#srware_'+trim(id)+'").html()+''" из базы GrossBee'');'#13#10;
         Result:=Result+fnGetModelApplicability(userInf,Stream, WaresS, true, false);
       end else begin
             Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
           end;
     end; // case 2

  3: begin
       Stream.WriteInt(isWe);
       Stream.WriteInt(gwlAnalogsON);
       Stream.WriteStr(id);
       prGetWareList(Stream,ThreadData);
       if Stream.ReadInt=aeSuccess then begin
         Result:=Result+'var tbl_=document.getElementById(''onanalogtable'');'#13#10;
         Result:=Result+'var altrow=false;'#13#10;
         iMaxWare := Stream.ReadInt;
         SetLength(Wares, iMaxWare);
         if (iMaxWare=0) then begin
           Result:=Result+'var row=tbl_.insertRow(-1);'#13#10;
           Result:=Result+'var newcell=row.insertCell(-1);'#13#10;
           Result:=Result+'newcell.innerHTML=''У этого товара нет аналогов, найденных через совпадение оригинальных номеров'';'#13#10;
         end
         else
           for i := 1 to iMaxWare do begin
             Wares[i-1]:=Stream.ReadInt;
             Stream.Position:=Stream.Position-4;
             Result:=Result+fnGetWareForSearch(Stream, -100, 'onanalogtable', s3, Count, WaresS, true,true);
           end;
         Result:=Result+fnGetModelApplicability(userInf,Stream, WaresS, true, false);

         // дорисовываем ссылочку на список ОЕ, по которым этот товар пересекается с главным
         Result:=Result+'var new_a;'#13#10;
         for i := 0 to iMaxWare-1 do begin
           Result:=Result+'new_a = document.createElement(''a'');'#13#10;
           Result:=Result+'new_a.className=''abANew'';'#13#10;
           Result:=Result+'new_a.style.backgroundImage=''url("/images/cross_16.png")'';'#13#10;
           Result:=Result+'new_a.style.display=''block'';'#13#10;
           Result:=Result+'new_a.style.right=''32px'';'#13#10;
           Result:=Result+'new_a.title=''Показать общие оригинальные номера'';'#13#10;
           Result:=Result+'$(new_a).bind(''click'', function(event) {'#13#10;
           Result:=Result+'  ec("showcrossoe", "waremain='+id+'&warecross='+IntToStr(Wares[i])+'", "newbj");'#13#10;
           Result:=Result+'});'#13#10;
    //     Result:=Result+'new_a.onclick=''ec("showcrossoe", "waremain='+Request.ContentFields.Values['id']+'&warecross='+IntToStr(Wares[i])+'", "difdict");'';'#13#10;
           Result:=Result+'$(''#onanalogtable #tr'+IntToStr(Wares[i])+' div'')[0].appendChild(new_a);'#13#10;
         end;

         Result:=Result+'$(''#waredetdiv3 h1'').html(''Аналоги товара "''+$("#srware_'+id+'").html()+''", найденные через оригинальные номера'');'#13#10;
         end else begin
           Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
         end;
     end; // case 3

  4: begin
      Stream.WriteInt(isWe);
      Stream.WriteInt(gwlAnalogsOneDirect);
      Stream.WriteStr(id);
      prGetWareList(Stream,ThreadData);
      if Stream.ReadInt=aeSuccess then begin
        Result:=Result+'var tbl_=document.getElementById(''onediractanalogstable'');'#13#10;
        Result:=Result+'var altrow=false;'#13#10;
        iMaxWare := Stream.ReadInt;
        if (iMaxWare=0) then begin
          Result:=Result+'var row=tbl_.insertRow(-1);'#13#10;
          Result:=Result+'var newcell=row.insertCell(-1);'#13#10;
          Result:=Result+'var img;'#13#10;
          Result:=Result+'newcell.innerHTML=''У этого товара нет "одностороних" аналогов'';'#13#10;
        end
        else
          for i := 1 to iMaxWare do begin
            Result:=Result+fnGetWareForSearch(Stream, -100, 'onediractanalogstable', s3, Count, WaresS, true,true);
            Result:=Result+'addsource(''#waredetdiv4 #tr'+s3+' div:first'', '+IntToStr(Count)+');'#13#10;
            Result:=Result+'addhandleODA(''#waredetdiv4 #tr'+s3+' div:first'', '+s3+', '+IntToStr(Count)+', true);'#13#10;
          end;
        Result:=Result+fnGetModelApplicability(userInf,Stream, WaresS, true, false);
        end else begin
           Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
        end;

        Stream.Clear;
        Stream.WriteInt(StrToInt(userInf.UserID));
        Stream.WriteInt(isWe);
        Stream.WriteInt(gwlAnalogsOneDirectWrong);
        Stream.WriteStr(id);
        prGetWareList(Stream,ThreadData);
        if Stream.ReadInt=aeSuccess then begin
          Result:=Result+'var tbl_=document.getElementById(''wrongonediractanalogstable'');'#13#10;
          Result:=Result+'var altrow=false;'#13#10;
          iMaxWare := Stream.ReadInt;
          if (iMaxWare=0) then begin
            Result:=Result+'var row=tbl_.insertRow(-1);'#13#10;
            Result:=Result+'var newcell=row.insertCell(-1);'#13#10;
            Result:=Result+'var img;'#13#10;
            Result:=Result+'newcell.innerHTML=''У этого товара нет неправильных "одностороних" аналогов'';'#13#10;
          end
          else
            for i := 1 to iMaxWare do begin
              Result:=Result+fnGetWareForSearch(Stream ,-100, 'wrongonediractanalogstable', s3, Count, WaresS, true,true);
              Result:=Result+'addsource(''#waredetdiv4 #tr'+s3+' div:first'', '+IntToStr(Count)+');'#13#10;
              Result:=Result+'addhandleODA(''#waredetdiv4 #tr'+s3+' div:first'', '+s3+', '+IntToStr(Count)+', false);'#13#10;
            end;
          Result:=Result+fnGetModelApplicability(userInf,Stream, WaresS, true, false);
          end else begin
            Result:=Result+'jqswMessageError("'+Stream.ReadStr+'");';
          end;

          Result:=Result+'$(''#waredetdiv4 > h1'').html(''Товары, к которым "''+$("#srware_'+trim(id)+'").html()+''" привязан, как односторонний аналог'');'#13#10;
          Result:=Result+'$(''#waredetdiv4 input[id^="attrgr"]'').css(''visibility'', ''hidden'');'#13#10;
          Result:=Result+'$(''#waredetdiv4 a[id^="analog_"]'').css(''display'', ''none'');'#13#10;
          Result:=Result+'$(''#waredetdiv4 a.smwu_2'').css(''right'', ''16px'');'#13#10;
          Result:=Result+'$(''#waredetdiv4 a.smwu_1'').css(''right'', ''32px'');'#13#10;
          Result:=Result+'$(''#waredetdiv4 span.brandspan'').css(''right'', ''48px'');'#13#10;
        end; // case 4



 else
   Result:=Result+'jqswMessageError("Нeизвестный код закладки - '+IntToStr(tabnum)+'");';
 end;  // case TabNum of

 Result:=Result+'tabvis('+IntToStr(tabnum)+');'#13#10;
 Result:=Result+'  $("#workareaWrap").removeClass("noactive");'#13#10;
end;

function fnGetmanufacturerlist(Stream: TBoBMemoryStream;selname:String;j:integer): string;
 var
  i,iMaxBrand:integer;
  s,mancode,manname:String;
  Ret:Boolean;
begin
  s:='';
  iMaxBrand := Stream.ReadInt;
  if (j=21) then begin
    s:=s+'manufacturerauto=[];'#13#10;
  end else begin
    s:=s+'var selbody='''';'#13#10;
  end;
  for i := 1 to iMaxBrand do begin
    mancode:=IntToStr(Stream.ReadInt);
    manname:=Stream.ReadStr;
    if (j=31) then begin
      s := s + 'selbody+=''<option value='+mancode+'>'+GetJSSafeString(manname)+'</option>'';'#13#10;
    end else
          if (j=21) then begin
              s := s + 'manufacturerauto[' + mancode + ']="' + GetJSSafeString(manname) + '";'#13#10;
              s := s + 'manufactureselect+=''<option value='+mancode+'>'+GetJSSafeString(manname)+'</option>'';'#13#10;
          end else begin
                Stream.ReadBool;
                Ret:=Stream.ReadBool;
                Ret:=(Stream.ReadBool and Ret);
                Stream.ReadBool; // признак видимости
                if Ret then begin
                  s := s + 'selbody+=''<option value='+mancode+'>'+GetJSSafeString(manname)+'</option>'';'#13#10;
                end;
              end;
  end;
  if (j=21) then begin
    s:=s+'$("#'+selname+'").html("<option value=-1> </option>"+manufactureselect);'#13#10;
  end else begin
    s:=s+'$("#'+selname+'").html("<option value=-1> </option>"+selbody);'#13#10;
    s:=s+'$("#'+selname+'").change();'#13#10;
  end;
  s:=s+'podborwinresize();';
  Result:=s;
end; //getmanufacturerlist


{
function fnGetAnalogForSearch(Stream: TBoBMemoryStream; isWebArm: boolean; var Wares: string; TypeCode:integer=0): string;
var
  Brand, BrandWWW, BrandAdrWWW, CurWareCode, PriceR, PriceO, MarginPrice, BonusPrice, Descr, CutPriceReason: string;
  Sale, NonReturn, CutPrice: boolean;
  List: TStringList;
  k:integer;
  arPrices: Array of String;
  DirectName:string;
begin

  Result:='';
  CurWareCode:=InttoStr(Stream.ReadInt);
  Wares:=Wares+','+CurWareCode;
  Result:=Result+'aal('+CurWareCode+', '    //  CurWareCode
                +InttoStr(Stream.ReadInt)+', ';          //  AttrGr
  Stream.ReadInt;                                        //  кол-во аналогов, пропускаем, так как не может быть аналогов у аналогов
  Stream.ReadInt;                                        //  и сателлитов пропускаем - нафиг нужно?
  Brand:=Stream.ReadStr;                                           // название бренда для лого
  BrandWWW:=Stream.ReadStr;                                           // название бренда для лого
  BrandAdrWWW:=Stream.ReadStr;                                           // адрес перехода на сайт поставщика
  Result:=Result+'"'+Brand+'", '              //  Brand
                +'"'+BrandWWW+'", '              //  BrandWWW
                +'"'+BrandAdrWWW+'", '              //  BrandAdrWWW
                +'"'+Stream.ReadStr+'", ';              //  WareName
  Sale:=Stream.ReadBool;
  NonReturn:=Stream.ReadBool;
  CutPrice:=Stream.ReadBool;
  DirectName:=LowerCase(Stream.ReadStr);    //название направления для скидок
  Result:=Result+'"'+GetJSSafeString(Stream.ReadStr)+'", ';                 // Unit
  k:=0; SetLength(arPrices,Length(arPriceColNames));
  while (k<Length(arPriceColNames)) do begin
    arPrices[k]:=Stream.ReadStr;
    Inc(k);
    end;
  //PriceR:=Stream.ReadStr;   //если нужно вернуть колонки обратно
  //PriceO:=Stream.ReadStr;
  MarginPrice:=Stream.ReadStr;
  BonusPrice:=Stream.ReadStr;

  if (CutPrice and FileExists(DescrDir+'\waredescr\'+CurWareCode+'.html')) then begin
    List:=TStringList.Create;
    try
      List.LoadFromFile(DescrDir+'\waredescr\'+CurWareCode+'.html');
      CutPriceReason:=StripHTMLTags(GetJSSafeStringArg(List.Text));
      if Length(CutPriceReason)<4 then CutPriceReason:='';
    finally
      prFree(List);
    end;
  end;

  Result:=Result+BoBBoolToStr(Sale)+', ';                              //Sale
  Result:=Result+BoBBoolToStr(NonReturn)+', ';                              //
  Result:=Result+BoBBoolToStr(CutPrice)+', ';
  Result:=Result+'"'+DirectName+'", ';                            //
  Result:=Result+''''+CutPriceReason+''', ';                              //
//  Result:=Result+'"'+Stream.ReadStr+'", ';              //  Unit
  k:=0;Result:=Result+'[';
  while (k<Length(arPriceColNames)) do begin
    if k<>Length(arPriceColNames)-1 then
      Result:=Result+'"'+arPrices[k]+'",'
    else
      Result:=Result+'"'+arPrices[k]+'"';
    Inc(k);
    end;
  Result:=Result+']," ",';
 // Result:=Result+'"'+PriceR+'", '              //
  //            +'"'+PriceO+'", ';              //                //  PriceR, PriceO

  Result:=Result+'"'+MarginPrice+'", "'+BonusPrice+'", ';                  //
  Descr:=Stream.ReadStr;
  Descr:=GetJSSafeStringArg(Descr);
  Result:=Result+'"'+Descr+'", '              //  описание товара
                +'"'+arAnalogColors[3]+'", ' //  Код цвета
                +'"'+IntToStr(TypeCode)+'"' //  0-аналоги 1- сопутствующие
                +');'#13#10;
  SetLength(arPrices,0);
end; }


function fnGetAnalogForSearch(Stream: TBoBMemoryStream; isWebArm: boolean; var Wares: string; WareCode: String; TypeCode:integer=0): string;
var
  Brand, BrandWWW, BrandAdrWWW, CurWareCode, MarginPrice, BonusPrice, Descr, CutPriceReason: string;
  Sale, NonReturn, CutPrice,flag,IsMoto,IsAuto: boolean;
  List: TStringList;
  k,ActionCode,RestSem,SysCount,iCode,i:integer;
  DirectName,ActionTitle,ActionText,WareName,UnitName,AttrGr,QvAnalog,QvSatelit:string;
  arPrices: Array of String;
begin

  Result:='';
  CurWareCode:=InttoStr(Stream.ReadInt);
  AttrGr:=InttoStr(Stream.ReadInt);
  QvAnalog:=InttoStr(Stream.ReadInt);  //  кол-во аналогов, пропускаем, так как не может быть аналогов у аналогов
  QvSatelit:=InttoStr(Stream.ReadInt); //  и сателлитов пропускаем - нафиг нужно?
  Wares:=Wares+','+CurWareCode;
  Result:=Result+'aal('+CurWareCode+', '    //  CurWareCode
                +AttrGr+', ';          //  AttrGr
  Brand:=Stream.ReadStr;                                           // название бренда для лого
  BrandWWW:=Stream.ReadStr;                                           // название бренда для лого
  BrandAdrWWW:=Stream.ReadStr;                                     // адрес перехода на сайт поставщика
  WareName:=Stream.ReadStr;
  Result:=Result+'"'+Brand+'", '              //  Brand
                +'"'+BrandWWW+'", '              //  BrandWWW
                +'"'+BrandAdrWWW+'", '              //  BrandAdrWWW
                +'"'+WareName+'", ';              //  WareName
  Sale:=Stream.ReadBool;
  NonReturn:=Stream.ReadBool;
  CutPrice:=Stream.ReadBool;
  DirectName:=LowerCase(Stream.ReadStr);    //название направления для скидок
  UnitName:=GetJSSafeString(Stream.ReadStr);                                 // Unit

  Result:=Result+'"'+UnitName+'", ';

  ActionCode:=Stream.ReadInt;         // код акции
  ActionTitle:=Stream.ReadStr+' <br> ';      // заголовок
  ActionText:=Stream.ReadStr;       // текст
  ActionText:=StringReplace(ActionText,'\n','<br>',[rfReplaceAll]);
  RestSem:=Stream.ReadInt; // семафор остатков: 0- красный, 2- зеленый, другое - нет
  SysCount:=Stream.ReadInt; // кол-во систем учета
  for i:= 0 to SysCount-1 do begin
    iCode:=Stream.ReadInt; // код системы учета
    flag:=Stream.ReadBool; // признак наличия моделей
    if iCode=constIsAuto then
      IsAuto:=flag;
    if iCode=constIsMoto then
      IsMoto:=flag;
  end;
                // Unit
  k:=0; SetLength(arPrices,Length(arPriceColNames));
  while (k<Length(arPriceColNames)) do begin
    arPrices[k]:=Stream.ReadStr;
    Inc(k);
    end;
  //PriceR:=Stream.ReadStr;   //если нужно вернуть колонки обратно
  //PriceO:=Stream.ReadStr;
  MarginPrice:=Stream.ReadStr;
  BonusPrice:=Stream.ReadStr;

  if (CutPrice and FileExists(DescrDir+'\waredescr\'+CurWareCode+'.html')) then begin
    List:=TStringList.Create;
    try
      List.LoadFromFile(DescrDir+'\waredescr\'+CurWareCode+'.html');
      CutPriceReason:=StripHTMLTags(GetJSSafeStringArg(List.Text));
      if Length(CutPriceReason)<4 then CutPriceReason:='';
    finally
      prFree(List);
    end;
  end;

  Result:=Result+BoBBoolToStr(Sale)+', ';                              //Sale
  Result:=Result+BoBBoolToStr(NonReturn)+', ';                              //
  Result:=Result+BoBBoolToStr(CutPrice)+', ';
  Result:=Result+'"'+DirectName+'", ';                            //
  Result:=Result+'"'+IntToStr(ActionCode)+'", ';
  Result:=Result+'"'+ActionTitle+'", ';
  Result:=Result+'"'+ActionText+'", ';
  Result:=Result+'"'+IntToStr(RestSem)+'", ';
  Result:=Result+BoBBoolToStr(IsAuto)+', ';                              //
  Result:=Result+BoBBoolToStr(IsMoto)+', ';
  Result:=Result+''''+CutPriceReason+''', ';                              //
//  Result:=Result+'"'+Stream.ReadStr+'", ';              //  Unit
  k:=0;Result:=Result+'[';
  while (k<Length(arPriceColNames)) do begin
    if k<>Length(arPriceColNames)-1 then
      Result:=Result+'"'+arPrices[k]+'",'
    else
      Result:=Result+'"'+arPrices[k]+'"';
    Inc(k);
    end;
  Result:=Result+']," ",';
 // Result:=Result+'"'+PriceR+'", '              //
  //            +'"'+PriceO+'", ';              //                //  PriceR, PriceO

  Result:=Result+'"'+MarginPrice+'", "'+BonusPrice+'", ';                  //
  Descr:=GetJSSafeStringArg(Stream.ReadStr);
  Result:=Result+'"'+Descr+'", '              //  описание товара
                +'"'+arAnalogColors[3]+'", ' //  Код цвета
                +'"'+IntToStr(TypeCode)+'"' //  0-аналоги 1- сопутствующие
                +');'#13#10;


   if TypeCode=0 then begin //аналоги
     Result:=Result+'if (arrAnalogCodeGener.length==0){arrAnalogCodeGener[0]='''+WareCode+''';} '#13#10              //  Brand
              +'  else{ if ('+WareCode+' !=arrAnalogCodeGener[arrAnalogCodeGener.length-1]){ '#13#10
                +'          arrAnalogCodeGener[arrAnalogCodeGener.length]='''+WareCode+'''; }}'#13#10 ;             //  BrandWWW              .
     if RestSem=2 then
       Result:=Result+' arrFindAnalogGreen[arrFindAnalogGreen.length]';
     if RestSem=0 then
       Result:=Result+' arrFindAnalogRed[arrFindAnalogRed.length]';
     if (RestSem<>0) and (RestSem<>2)  then
       Result:=Result+' arrFindAnalogNone[arrFindAnalogNone.length]';
   end;
   if TypeCode=1 then begin //сателиты
     Result:=Result+'if (arrSateliteCodeGener.length==0){arrSateliteCodeGener[0]='''+WareCode+''';} '#13#10              //  Brand
         +'  else{ if ('+WareCode+' !=arrSateliteCodeGener[arrSateliteCodeGener.length-1]){ '#13#10
         +'          arrSateliteCodeGener[arrSateliteCodeGener.length]='''+WareCode+'''; }}'#13#10 ;             //  BrandWWW              .
     if RestSem=2 then
       Result:=Result+' arrFindSateliteGreen[arrFindSateliteGreen.length]';
     if RestSem=0 then
       Result:=Result+' arrFindSateliteRed[arrFindSateliteRed.length]';
     if (RestSem<>0) and (RestSem<>2)  then
       Result:=Result+' arrFindSateliteNone[arrFindSateliteNone.length]';
   end;
   Result:=Result+'= {CurWareCode: '+CurWareCode+', AttrGr:'    //  CurWareCode
                +AttrGr+', ';          //  AttrGr
   Result:=Result+'Brand: "'+Brand+'", '              //  Brand
                +'BrandWWW: "'+BrandWWW+'", '              //  BrandWWW
                +'BrandAdrWWW: "'+BrandAdrWWW+'", '              //  BrandAdrWWW
                +'WareName: "'+WareName+'", ';              //  WareName
   Result:=Result+'UnitName: "'+UnitName+'", ';


   Result:=Result+'Sale: '+BoBBoolToStr(Sale)+', ';                              //Sale
   Result:=Result+'NonReturn: '+BoBBoolToStr(NonReturn)+', ';                              //
   Result:=Result+'CutPrice: '+BoBBoolToStr(CutPrice)+', ';
   Result:=Result+'DirectName: '+'"'+DirectName+'", ';                            //
   Result:=Result+'ActionCode: "'+IntToStr(ActionCode)+'", ';
   Result:=Result+'ActionTitle: "'+ActionTitle+'", ';
   Result:=Result+'ActionText: "'+ActionText+'", ';
   Result:=Result+'RestSem: "'+IntToStr(RestSem)+'", ';
   Result:=Result+'IsAuto: '+BoBBoolToStr(IsAuto)+', ';                              //
   Result:=Result+'IsMoto: '+BoBBoolToStr(IsMoto)+', ';
   Result:=Result+'CutPriceReason: '''+CutPriceReason+''', ';                              //
   k:=0; Result:=Result+'Prices: [';
   while (k<Length(arPriceColNames)) do begin
     if k<>Length(arPriceColNames)-1 then
       Result:=Result+'"'+arPrices[k]+'",'
     else
       Result:=Result+'"'+arPrices[k]+'"';
     Inc(k);
   end;
   Result:=Result+'],NoneStr: " ",';
   //Result:=Result+'"'+Price+'", "'+PriceO+'", ';                  //  PriceR, PriceO
   Result:=Result+'MarginPrice: "'+MarginPrice+'",BonusPrice: "'+BonusPrice+'", ';                  //
   Result:=Result+'Descr: "'+Descr+'", '              //  описание товара
                +'arAnalogColors: "'+arAnalogColors[3]+'", ' //  Код цвета
                +'TypeCode: "'+IntToStr(TypeCode)+'", WareCode: ' //  0-аналоги 1- сопутствующие
                +WareCode+' };'#13#10;
  SetLength(arPrices,0);
end;







function fnWareSearch(var userInf:TEmplInfo; Stream: TBoBMemoryStream;var LogText: string;groups:String;waresearch:String;ignorspec:String;one_line_mode:String;forfirmid:String;Template: string): string;
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
    if not NeedTypes then begin // если товаров меньше определенного значения, то приходит положительное число и мы показываем товары
      Currency:=Stream.ReadStr;
      ShowAnalogs:=Stream.ReadBool;
      WareCount:=Stream.ReadInt;
      if (IgnoreSpec=coLampBaseIgnoreSpec) then begin
         s:=s+'$("#WSRwrapper h1").html("Результаты подбора ламп <span>'''+GetHTMLSafeString(Template)+'''</span>");'#13#10;
      end else begin
         s:=s+'$("#WSRwrapper h1").html("Результаты поиска по строке <span>'''+GetHTMLSafeString(Template)+'''</span>");'#13#10;
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
      // принимаем товары
      for i:=0 to WareCount-1 do begin
        s:=s+fnGetWareForSearch(Stream, -100, 'WSRtablecontent', WareCode, AnalogCount, Wares, userInf.FirmId=IntToStr(isWe));
        if ShowAnalogs then begin  //если нужно показывать аналоги сразу и они есть, то показываем
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

      // принимаем оригинальные номера
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

        if ShowAnalogs then begin  //если нужно показывать аналоги сразу и они есть, то показываем
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

      LogText:=('Шабл="'+Template+'" игнор='+fnIfStr(ignorspec='unchecked', 'выкл', 'вкл')+' кол-во_рез='+IntToStr(wareCount+OrNumCount)+' групп="'+groups+'"');
    end else begin  //  передаются не товары, а группы для уточнения
      WareCount:=Stream.ReadInt;
      s1:='';
      s1:=s1+'<div style=''font-size: 12px;''>Найдено позиций - '+IntToStr(WareCount)+'. Для уточнения запроса выберите тип товара.<hr /></div>';
      s1:=s1+'<div id=waregrouplistdiv>';
      WareCount:=Stream.ReadInt;
      for i:=0 to WareCount-1 do begin
        if (I>0) then s1:=s1+'<br />';
          s1:=s1+'<input type=checkbox value='+IntToStr(Stream.ReadInt)+'> '+GetJSSafeString(Stream.ReadStr);
        end;
        s1:=s1+'</div>'; // s1:=s1+'<div id=waregrouplistdiv>';
        s1:=s1+'<div class=bottombuttonsdiv><input type=button value=''Показать'' onclick=searchwaresbygroup();> <input type=button value=''Закрыть''onclick=''$.fancybox.close();''></div>';
        s:=s+'sw("'+s1+'");'#13#10;
        s:=s+'var h=window.innerHeight-130;'#13#10;
        s:=s+'if (h<38) {'#13#10;
        s:=s+'  h=38;'#13#10;
        s:=s+'} else {'#13#10;
        s:=s+'  if (h>'+IntToStr(WareCount*19)+') {'#13#10; // 19 пикселей - высота строки
        s:=s+'    h='+IntToStr(WareCount*19)+';'#13#10;
        s:=s+'  }'#13#10;
        s:=s+'}'#13#10;
        s:=s+'$(''#waregrouplistdiv'').height(h);'#13#10;
        LogText:='к-во типов товаров - '+IntToStr(WareCount);
      end;
        s:=s+'$("#podbortabs").dialog("close");'#13#10;
        s:=s+'checkListWaresForFind ();'#13#10;
        s:=s+' setActionTooltip();'#13#10;
        s:=s+'setFindFilter();'#13#10;
  finally
    Result:=s;
  end;
end; // fnWareSearch

function fnGetAnalogs(var userInf:TEmplInfo; Stream: TBoBMemoryStream;id: String; is_on:String): string;
var
  s, WareCode, Wares: string;
  WareCount, i: integer;
begin
  s:='';
  Wares:='-1';
  WareCode:=trim(id);
  WareCount:=Stream.ReadInt;
  if wareCount=0 then begin
    s:='jqswMessage(''По заданному товару аналогов не найдено.'');';
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
    s:=s+'aaa.css("backgroundImage", "url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/wac.png'')");'#13#10;
    s:=s+'aaa.attr("title", "Скрыть аналоги");'#13#10;
    s:=s+'checkListWaresForFind ();'#13#10;
    s:=s+' setActionTooltip();'#13#10;
    s:=s+' setActionTooltip();'#13#10;
    s:=s+'setFindFilter(1);'#13#10;
  end;
  Result:=s;
end; //fnGetAnalogs

function fnGetSatellites(var userInf:TEmplInfo; Stream: TBoBMemoryStream;id: String): string;
var
  s, WareCode, Wares: string;
  WareCount, i: integer;
begin
  s:='';
  Wares:='-1';
  WareCode:=trim(id);
  WareCount:=Stream.ReadInt;
  if wareCount=0 then begin
    s:='jqswMessage(''К заданному товару не найдены сопутствующие товары.'');';
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
    s:=s+'aaa.css("backgroundImage", "url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/wsc.png'')");'#13#10;
    s:=s+'aaa.attr("title", "Скрыть сопутствующие товары");'#13#10;
    s:=s+'setcomparebtnvis();'#13#10;
    s:=s+'checkListWaresForFind ();'#13#10;
    s:=s+' setActionTooltip();'#13#10;
  end;
  Result:=s;
end; //fnGetSatellites

function fnWizard(var userInf:TEmplInfo; cat: string;var WizardId, ValueId: string): string;
var Stream  : TBoBMemoryStream;
    s, ss, sss, s1, command: string;
    icon, name, value, conditionid, ssd, res, vinexample, frameexample: string;
    i, pcond, p: integer;
begin
//prTestLog('fnWizard');
result:= '';
s:='';
p:=0;
try
    Stream:=TBoBMemoryStream.Create;
    Stream.WriteInt(StrToInt(userInf.UserID));
    Stream.WriteInt(StrToInt(userInf.FirmID));
//    Stream.WriteInt(StrToIntDef(fnGetField(Request, 'forfirmid'), -1));     !!!!!!!!!!!!
    Stream.WriteStr(cat);
    Stream.WriteStr(WizardId);
    Stream.WriteStr(ValueId);
    if fnSendReceiveData(oecGetWizard, Stream, csServerManage) then begin
      if Stream.ReadInt=aeSuccess then begin
(*        try *)
          cat:= Stream.ReadStr;
          WizardId:= Stream.ReadStr;
          ValueId:= Stream.ReadStr;
          command:= Stream.ReadStr;
          icon:= Stream.ReadStr;
          s:= Stream.ReadLongStr;
          ss:= fnCutFromTo(s, '<response>', '</response>',true);
          vinexample:= fnCutFromTo(ss, 'vinexample="', '"',false);
          frameexample:= fnCutFromTo(ss, 'frameexample="', '"',false);
          if vinexample<>'' then
            res:=res+'<hr><form  onsubmit=\''return vs(this,"'+icon+'","'+cat+'");\'' ><h3>Поиск по VIN-коду</h3>Укажите  VIN-код(17 символов), например: '+vinexample+
                ' <br><input name="'+cat+'" type=text maxlength=17 id=vinno size=20><input type=submit value="Искать" style="display: none;" >'+
                '<a class="abgslide" style="position: relative; display: inline-block; margin-left: 3px; width: 23px; height: 22px; top: 6px; background-image: url(\'''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/lupa.png\'');" '
                +'href="#" title="Поиск по VIN" onclick="$(\''#origprogs .currentdiv form\'').submit(); "></a>'
                +'</form>';
          if frameexample<>'' then begin
            //if flNewModeCGI  then
            //  res:=res+'<hr><h3 >Поиск по FRAME</h3>Укажите FRAME, например: '+frameexample+' <input style="margin-left: 10px;" type=text id=frame size=20> - <input type=text id=frameno size=20><input type=button value="Искать" onclick=\''ec("FindByVIN", "icon='+icon+'&frame="+$("#frame").val()+"&frameno="+$("#frameno").val()+"&cat='+cat+'&vin=", "newbj");\''>'
            //else
            res:=res+'<hr><h3 >Поиск по FRAME</h3>Укажите FRAME, например: '+frameexample+' <input style="margin-left: 10px;" type=text id=frame size=20> - <input type=text id=frameno size=20><input type=button value="Искать" onclick=\''ec("FindByVIN", "icon='+icon+'&frame="+$("#frame").val()+"&frameno="+$("#frameno").val()+"&cat='+cat+'&vin=", "abj");\''>';
          end;
          res:=res+'<hr><h3 >Поиск по параметрам</h3>';
          res:= res+'<table>';
          while True do begin
            ssd:='';
            ss:=  fnCutFromTo(s, '<row', '><',true);
            if ss='' then break;
            s:= '<'+s;
            name:= StringReplace(fnCutFromTo(ss, 'name="', '"',false), '''', '\'#39, [rfReplaceAll]);//   StringReplace(ss, #39, '\'#39, [rfReplaceAll]);
            value:= StringReplace(fnCutFromTo(ss, 'value="', '"',false), '''', '\'#39, [rfReplaceAll]);
            conditionid:= StringReplace(fnCutFromTo(ss, 'conditionid="', '"',false), '''', '\'#39, [rfReplaceAll]);
            WizardId:= StringReplace(fnCutFromTo(ss, 'wizardid="', '"',false), #39, '\'#39, [rfReplaceAll]);;
            res:=res+'<tr><td style="text-align:left;">'+name+':</td>';
            //if flNewModeCGI  then
            //   res:=res+'<td ><select style="width:150px;" onchange=\''ec("getwizard", "icon='+icon+'&cat='+cat+'&WizardId='+WizardId+'&ValueId="+this.value, "newbj");\''>'+value
            //else
            res:=res+'<td ><select style="width:150px;" onchange=\''ec("getwizard", "icon='+icon+'&cat='+cat+'&WizardId='+WizardId+'&ValueId="+this.value, "abj");\''>'+value;
            sss:= fnCutFromTo(s, '<', '/>',false);
            if sss='options' then begin
              res:= res+ '<option value="'+name+'">'+StringReplace(value, #39, '\'#39, [rfReplaceAll])+'</option>';
              ssd:= fnCutFromTo(ss, 'ssd="', '"',false);
              if ssd='' then ssd:=' ';
              if command='GetWizard2' then inc(p);
            end
            else begin
              sss:= fnCutFromTo(s, '<options>', '</options></row>',true);
              i:= 0;

              while True do  begin
                ss:= fnCutFromTo(sss, '<row', '/>',true);
                if ss='' then break;
                if i=0 then res:= res+ '<option value="null"> </option>';
                value:= fnCutFromTo(ss, 'key="', '"',false);
                name:= fnCutFromTo(ss, 'value="', '"',false);
                res:= res+ '<option value="'+StringReplace(value, '''', '\'#39, [rfReplaceAll])+'">'+StringReplace(name, '''', '\'#39, [rfReplaceAll])+' </option>';
                inc(i);
              end;
            end;
            res:=res+'</select></td>';
            if flNewModeCGI  then
              if command='GetWizard2' then res:=res+'<td onclick=\''ec("getwizard", "icon='+icon+'&cat='+cat+'&WizardId='+WizardId+'&ValueId='+ssd+'", "newbj");\''><img src="'+DescrImageUrl+'/images/remove.png" style="display: '+fnIfStr(ssd='','none','block')+';"></td>'
            else
              if command='GetWizard2' then res:=res+'<td onclick=\''ec("getwizard", "icon='+icon+'&cat='+cat+'&WizardId='+WizardId+'&ValueId='+ssd+'", "abj");\''><img src="'+DescrImageUrl+'/images/remove.png" style="display: '+fnIfStr(ssd='','none','block')+';"></td>';
            res:=res+'</tr>';
          end;
          result:= res+'</table>';
          if (command='GetWizard2') and (p=0) then result:='buttonnot,'+result;
(*
        except
          on E: EBOBError do begin
            Result:='alert("'+GetJSSafeString(StripHTMLTags(E.Message))+'");';
            prMessageLog(E.Message, 'System');
          end;
          on E:Exception do begin
            prMessageLog('fnFindByFrame Error:'#13#10+E.Message);
            raise;
          end;
        end; *)
      end else begin
        s1:=Stream.ReadStr;
        s1:=fnIfStr(pos('URL',s1)>0,copy(s1,1,pos('URL',s1)),s1);
        result:=result+'alert("'+GetJSSafeString(s1)+'");';
      end;
(*    end else begin
      Result:=Result+'alert("Ошибка выполнения: '+GetJSSafeString(Stream.ReadStr)+'");';   *)
    end;

  finally
    FreeAndNil(Stream);
  end;

end;



function fnFindByVIN(var userInf:TEmplInfo; Stream: TBoBMemoryStream;Icons:String;WizardId:String;frame:String;frameNo:String;inputid:String): string;
const
  vinrow='model;description;engineNo;engine;grade;gearbox;transmission;date;region;destinationregion;trimcolor;framecolor;interiercolor;manufactured;options';
var
  s, ss, sss, s1, s11, dop : string;
  Count, i: integer;
  brand, cat, name, vehicleid, desc, row, tit, manuf, vin, ValueId, ssd, categoryid, unitid,quickgroupid: string;
  icon, vinexample, frameexample, supportparameteridentification, command: string;
  arvinrow, artit, arrow: tas;
  ss1,s1s,example: string;
  wizardsearch: boolean;
  c:  Char;
begin
 i:= 0;
 command:= '';
 Result:='';
 dop:='';
 try
   manuf:= Stream.ReadStr;
   vin:= Stream.ReadStr;
   cat:= Stream.ReadStr;
   ssd:= Stream.ReadStr;
   s11:= Stream.ReadLongStr;
   sss:=fnCutFromTo(s11, '<response>', '</response>',true);
   icon:=Icons;
   if icon='' then
     icon:='#icon#';
   if pos('<row',sss)=0{length(sss)<50} then
     Result:='jqswMessageError("По введенным данным результаты не найдены.");'
   else begin
     Result:= Result+'<div style="margin-left: 10px;">';
     Result:=icon;
     if (WizardId<>'') or (ssd<>'') then ss:= ' по параметрам';
     if vin <> '' then begin
       ss:= ' по VIN  '+vin;
       dop:= dop+ '$("#origprogs").attr(''vin'','''+vin+''');'#13#10;
     end
     else dop:= dop+ '$("#origprogs").attr(''vin'','''');'#13#10;
     if (frame<>'') or (frameno<>'') then begin
       ss:= ' по FRAME '+ frame+' - '+frameno;
       dop:= dop+ '$("#origprogs").attr(''frame'','''+frame+' - '+frameno+''');'#13#10;
     end
     else dop:= dop+ '$("#origprogs").attr(''frame'','''');'#13#10;;

     Result:= Result+'<h2>Результат поиска'+ss+':</h3>';
     Result:= Result+'<table class="vinrows"><tr><th>Наименование</th>#####'+'</tr>';
     while True do begin
       ss:=fnCutFromTo(sss, '<row', '</row>',true);
       if ss='' then break;
       inc(Count);
       brand:= fnCutFromTo(ss, 'brand="', '"',false);
       if pos('FIAT', UpperCase(brand))>0 then brand:='Fiat';
       if pos('VOLKSWAGEN', UpperCase(brand))>0 then brand:='VW';
       dop:= dop+'brandoe = "'+brand+'";';
       dop:= dop+ '$("#origprogs").attr(''brandoe'','''+brand+''');'#13#10;
       desc:= desc+'<br>Производитель: '+brand;
       cat:= fnCutFromTo(ss, 'catalog="', '"',false);
       vehicleid:= fnCutFromTo(ss, 'vehicleid="', '"',false);
       name:= StringReplace(fnCutFromTo(ss, 'name="', '"',false), #39, '\'#39, [rfReplaceAll]);
       ssd:= fnCutFromTo(ss, 'ssd="', '"',false);
       desc:= desc+'<br>Name: '+name;
       Result:= Result+'<tr class="tooltip" style="cursor: pointer;" title=# onclick=\''ec("ListUnits", "icon='+icon+'&vin='+vin+'&frame='+frame+'&frameno='+frameno+'&cat='+cat+'&vehicleid='+vehicleid+'&categoryid='+categoryid+'&unitid='+unitid+'&quickgroupid='+quickgroupid+'&ssd='+ssd+'", "abj");\''>'+'<td>'+name+'</td>';
       if count>1 then begin
         SetLength(artit,0);
         artit:=fnSplitString(StringReplace(copy(tit,5,length(tit)-9), '</th><th>', '<', [rfReplaceAll]),'<');
         SetLength(arrow,length(artit));
       end;
       while True do begin
         s:= fnCutFromTo(ss, '<attribute', '/>');
         if s='' then break;
         s1:= fnCutFromTo(s, fnIfStr(count=1,'key="','name="'), '"',false);
         if count=1 then begin
            if fnInStrArray(s1,arvinrow,false)>-1 then begin
              tit:= tit+'<th>'+ StringReplace(fnCutFromTo(s, 'name="', '"',false), #39, '\'#39, [rfReplaceAll])+'</th>';
               row:= row+'<td>'+StringReplace(StringReplace(fnCutFromTo(s, 'value="', '"',false), #39, '\'#39, [rfReplaceAll]), '&#xa;', '<br>', [rfReplaceAll])+'</td>';
//             row:= row+'<td>'+StringReplace(fnCutFromTo(s, 'value="', '"',false), #39, '\'#39, [rfReplaceAll])+'</td>';      //if pos(#39,ss)>0 then ss:= StringReplace(ss, #39, '\'#39, [rfReplaceAll]);
            end;
         end
         else begin
           i:= fnInStrArray(s1,artit,false);
           if i>-1 then begin
             arrow[i]:= StringReplace(fnCutFromTo(s, 'value="', '"',false), #39, '\'#39, [rfReplaceAll]);
           end;
         end;
         desc:= desc+'<br>'+fnCutFromTo(s, 'name="', '"',false)+': '+{StringReplace(fnCutFromTo(s, 'value="', '"',false), #39, '\'#39, [rfReplaceAll])}
         StringReplace(StringReplace(fnCutFromTo(s, 'value="', '"',false), #39, '\'#39, [rfReplaceAll]), '&#xa;', '<br>', [rfReplaceAll]);
       end;
       if count=1 then Result:= Result+row
       else Result:= Result+'<td>'+ fnArrOfStrToString(arrow,'</td><td>')+'</td>';
       SetLength(arrow,0);
       Result:=StringReplace(Result, '<td></td>', '', [rfReplaceAll]);
       Result:=StringReplace(Result, 'title=#', 'title="'+GetHTMLSafeString(desc)+'"', [rfReplaceAll]);
       Result:= Result+  '<td onclick=\''jqswtext("info", "'+GetHTMLSafeString(desc)+'");event.stopPropagation();\''><img src="/images/attention.png" ></td>';  //info onclick="jqswtext('Заголовок' , this.parentNode.parentNode.title)"
       Result:= Result+'</tr>';
       Result:=StringReplace(Result, '#####', tit, [rfReplaceAll]);
       desc:= '';
     end;
     Result:= Result+'</table>';
     Result:=StringReplace(Result, '&#xa;', '', [rfReplaceAll]);
     sss:=fnCutFromTo(s11, '<response>', '</response>',true);
     cat:= fnCutFromTo(sss, 'code="', '"',false);
     icon:= fnCutFromTo(sss, 'icon="', '"',false);
     s1:= fnCutFromTo(sss, '<features>', '</features>',false);
     if pos('wizardsearch2',s1)>0 then wizardsearch:= True;
     while True do begin
       s1s:= fnCutFromTo(s1, '<feature', '/>',true);
       if s1s='' then break;
       name:= fnCutFromTo(s1s, 'name="', '"',false);
       example:= fnCutFromTo(s1s, 'example="', '"',false);
       if not wizardsearch and (name='vinsearch') then
         Result:=Result+'<hr><form  onsubmit=\''return vs(this,"'+icon+'","'+cat+'");\'' ><h3>Поиск по VIN-коду</h3>Укажите  VIN-код(17 символов), например: '+example+
                        ' <br><input name="'+cat+'" type=text maxlength=17 id=vinno size=20><input type=submit value="Искать" style="display: none;" >'+
                        '<a class="abgslide" style="position: relative; display: inline-block; margin-left: 3px; width: 23px; height: 22px; top: 6px; background-image: url(\'''+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/lupa.png\'');" '
                       +'href="#" title="Поиск по VIN" onclick="$(\''#origprogs .currentdiv form\'').submit(); "></a>'
                       +'</form>';
       if not wizardsearch and (name='framesearch') then begin
        // if flNewModeCGI then
        //   Result:=Result+'<hr >Поиск по FRAME, например: '+example+'<input type=text id=frame size=20> - <input type=text id=frameno size=20><input type=button value="Искать" onclick=\''ec("FindByVIN", "icon='+icon+'&frame="+$("#origprogs .currentdiv #frame").val()+"&frameno="+$("#origprogs .currentdiv #frameno").val()+"&cat='+cat+'&vin=", "newbj");\''>'
        // else
         Result:=Result+'<hr >Поиск по FRAME, например: '+example+'<input type=text id=frame size=20> - <input type=text id=frameno size=20><input type=button value="Искать" onclick=\''ec("FindByVIN", "icon='+icon+'&frame="+$("#origprogs .currentdiv #frame").val()+"&frameno="+$("#origprogs .currentdiv #frameno").val()+"&cat='+cat+'&vin=", "abj");\''>';
       end;
       if name='wizardsearch2' then begin
         s:=  fnWizard(userInf,cat,WizardId,ValueId);
         if pos('buttonnot,',s)>0 then
           s:= copy(s,11,length(s));
         Result:=Result+'<div style="position: relative">'+s+'</div>';
       end;
     end;
     ss1:= fnCutFromTo(sss, '<extensions>', '</extensions>',false);
     while True do begin
       s1:= fnCutFromTo(ss1, '<operations>', '</operations>',true);
       //prTestLog('ss1='+ss1);
       if s1='' then break;
       while True do begin
         s1s:= fnCutFromTo(s1, '<', '>',true);
         if s1s='' then break;
         if (pos('operation',s1s)>0) and (pos('/operation',s1s)=0) then begin
           Result:=Result+'<hr><h3 style="margin-left: 10px;">Поиск по '+fnCutFromTo(s1s, 'description="', '"',false)+'</h3>';
           command:= 'operation='+fnCutFromTo(s1s, 'name="', '"',false);
         end;
          //      s1ss:= s1ss+'operation='+ fnCutFromTo(s1s, 'description="', '"',false)+','+ fnCutFromTo(s1s, 'name="', '"',false)+';';   //description
         if pos('field',s1s)>0 then begin
           Result:=Result+'<span style="margin-left: 10px;"> '+fnCutFromTo(s1s, 'description="', '"',false)+': </span>'+' <input style="margin-left: 10px;" type=text id='+fnCutFromTo(s1s, 'name="', '"',false)+' size=20>';
           command:= command+fnIfStr(command='','','|')+fnCutFromTo(s1s, 'name="', '"',false)+'="+$(".currentdiv #'+fnCutFromTo(s1s, 'name="', '"',false)+'").val()';
         end;
       end;
     end;
     if command<>'' then begin
       //if flNewModeCGI then
       //  Result:=Result+'<br><input type=button value="Искать" onclick=\''ec("FindByVIN", "icon='+icon+'&command='+command+'+"&cat='+cat+'&vin=", "newbj");\''>'
       //else
       Result:=Result+'<br><input type=button value="Искать" onclick=\''ec("FindByVIN", "icon='+icon+'&command='+command+'+"&cat='+cat+'&vin=", "abj");\''>';
     end;
     Result:= Result+'</div>';
     Result:= stringreplace(Result,'#icon#', icon, [rfReplaceAll]);
     dop:= dop+'$(".tooltip").easyTooltip();'#13#10;
     dop:= dop + '$(''#podbortabs'').dialog(''open'');'#13#10;
     Result:=fnRemoveBreaks(Result);
     if inputid='vinsearch' then Result:=Result
         +'$("#origprogs .selectpartsdiv.currentdiv").removeClass("currentdiv");'#13#10
         +'$("#origprogs .selectpartsdiv[number=1]").addClass("currentdiv");'#13#10
         +'$("#podbortabs").tabs("option", "selected", parseInt($("#origprogs").attr("tabnumber")));'#13#10
         +'$("#podbortabs").dialog("open");'#13#10
         +'setpodborsubdiv(1, 1,'''+Result+''');'#13#10 {Result:=Result+'setpodborsubdiv(1, 1).html('''+Result+''');'#13#10}
     else Result:=Result+'setpodborsubdiv(-1, 1,'''+Result+''');'#13#10; { Result:=Result+'setpodborsubdiv(-1, 1).html('''+Result+''');'#13#10;}
     Result:=Result+'$("#origheaderlogo").css(''background-image'', ''url('+DescrImageUrl+'/images/manufacturers/'+icon+')'');'#13#10;
     dop:= dop+ '$(''#'+inputid+''').val('''');'#10#13;
     Result:=Result+dop;
   end;
 finally
   SetLength(arvinrow,0);
   SetLength(artit,0);
   SetLength(arrow,0);
 end;
end; //fnFindByVIN

function fnWebArmGetWaresDescrView(Stream: TBoBMemoryStream): string;
var
  s, s1, s2, s3, WareCode : string;
  Count, i: integer;
begin
  s:='';
  Count:=Stream.ReadInt;
  for i:=0 to Count-1 do begin
    s2:='';
    WareCode:=IntToStr(Stream.ReadInt);
    s1:=GetJSSafeString(StringReplace(Stream.ReadStr, #13#10, '<br>', [rfReplaceAll]));
    if s1<>'' then begin
      s2:=s2+'<hr><b>Атрибуты: </b>'+s1;
    end;
    s1:=GetJSSafeString(StringReplace(Stream.ReadStr, #13#10, '<br>', [rfReplaceAll]));
    s3:=GetJSSafeString(StringReplace(Stream.ReadStr, #13#10, '<br>', [rfReplaceAll]));
    if (s1+s3)<>'' then begin
      s2:=s2+'<hr><b>TecDoc: </b>';
    end;
    if s1<>'' then begin
      s2:=s2+s1;
    end;
    if (s1<>'') and (s3<>'') then begin
      s2:=s2+'<br>';
    end;
    if s3<>'' then begin
      s2:=s2+s3;
    end;
    s:=s+'$(".tddata'+WareCode+'").html("'+s2+'");'#13#10;
  end;
  Result:=s;
end; //prWebArmGetWaresDescrView

// "освежает" набор Top10 последних выбираемых моделей и возвращает данные для отображения строк
function fnRefreshTop10List(Stream: TBoBMemoryStream;Top10Cookie:String;Sys:integer): string;
var
 i, Count, ModelCode, CodeForSite, ModelLine, Manufacturer, bmonth, byear, eyear, emonth, Power, i_en: integer;
 s,  Top10CookieValue, Engines, Engine, ss: string;
 EnginesList: TStringList;
 altrow: boolean;
begin
  s:='';
  s:=s+'var tbl=$("#'+Top10Cookie+'");'#13#10;
  s:=s+'tbl.empty();'#13#10;
  s:=s+'var newrow=null;'#13#10;
  s:=s+'var td=null;'#13#10;

  if (Sys=(30+constIsAuto)) then begin
    s:=s+'var altrow=true;'#13#10;
    s:=s+'var _objdiv="selbymodeltreedivautoengine";'#13#10;
    s:=s+'var _treediv="selbymodelauenobj";'#13#10;
    s:=s+'var _pref="sel_auen";'#13#10;
    s:=s+'drawenginestop10header();'#13#10;
  end;
  Count:=Stream.ReadInt;
  altrow:=true;
  Top10CookieValue:='';
  for i:=0 to Count do begin
    ModelCode:=Stream.ReadInt;
    Top10CookieValue:=Top10CookieValue+','+IntToStr(ModelCode);
    if ((Sys in constAllSys)) then begin
      CodeForSite:=Stream.ReadInt;
      ModelLine:=Stream.ReadInt;
      Manufacturer:=Stream.ReadInt;
      s:=s+'newrow=tbl[0].insertRow(-1);'#13#10;
      s:=s+'newrow.onclick=function(){showmodelfromwarelist(this, '+IntToStr(Manufacturer)+', '+IntToStr(ModelLine)+', '+IntToStr(ModelCode)+', '+IntToStr(Sys)+');}'#13#10;
      s:=s+'newrow.style.fontSize="11px";'#13#10;
      if altrow then begin
        s:=s+'newrow.className="lblchoice";'#13#10;
      end
      else
        s:=s+'newrow.className="lblchoice altrow";'#13#10;
        altrow:= not altrow;
        s:=s+'newcell=newrow.insertCell(-1);'#13#10;

      if (Sys=constIsAuto) then begin
        s:=s+'newcell.innerHTML="<img src=\"/images/more.png\" style=\"cursor: pointer;\" onclick=\"ec(''loadmodeldatatext'', ''model='+IntToStr(ModelCode)+''', ''abj'');\" >"'#13#10;
      end else begin
         if (CodeForSite>0) then begin
           s:=s+'newcell.innerHTML="<a href=\"http://ride.ua/models/model/id/'+IntToStr(CodeForSite)+'\" target=\"_blank\" title=\"Эта модель на сайте ride.ua\" style=\"top: 2px; position: relative;\"><img src=\"/images/rideico.png\"></a>";'#13#10;
         end else begin
           s:=s+'newcell.innerHTML="&nbsp;";'#13#10;
         end;
      end;

      s:=s+'newcell=newrow.insertCell(-1);'#13#10;
      s:=s+'newcell.innerHTML="'+GetJSSafeStringArg(Stream.ReadStr)+'";'#13#10;
      s:=s+'newcell=newrow.insertCell(-1);'#13#10;
      s:=s+'newcell.innerHTML="'+GetJSSafeStringArg(Stream.ReadStr)+'";'#13#10;
      s:=s+'newcell=newrow.insertCell(-1);'#13#10;
      s:=s+'newcell.innerHTML="<a href=# onclick=\"showmodelfromwarelist(this, '+IntToStr(Manufacturer)+', '+IntToStr(ModelLine)+', '+IntToStr(ModelCode)+', '+IntToStr(Sys)+');\">'+Stream.ReadStr+'";'#13#10;
      byear:=Stream.ReadInt;
      bmonth:=Stream.ReadInt;
      eyear:=Stream.ReadInt;
      emonth:=Stream.ReadInt;
      Power:=Stream.ReadInt;
      if (Sys=constIsAuto) then begin
        s:=s+'newcell=newrow.insertCell(-1);'#13#10;
        ss:=fnGetYMBE(byear, bmonth, eyear, emonth);
        ss:=StringReplace(ss, '(', '', []);
        ss:=StringReplace(ss, ')', '', []);
        s:=s+'newcell.innerHTML="'+ss+'";'#13#10;
        s:=s+'newcell=newrow.insertCell(-1);'#13#10;
        s:=s+'newcell.innerHTML="'+fnIfStr(Power>0, IntToStr(Power)+'&nbsp;лс', '')+'";'#13#10;
        s:=s+'newcell=newrow.insertCell(-1);'#13#10;

        Engines:=Stream.ReadStr;
        if (Engines='') then Engines:='&nbsp;' else begin
          EnginesList:=fnSplit(',', Engines);
          Engines:='';
          for i_en:=0  to EnginesList.Count-1 do begin
             Engine:=trim(EnginesList[i_en]);
             Engines:=Engines+'<a href=# onclick=\"ec(''showengineoptions'', ''model='+IntToStr(ModelCode)+'&engine='+Engine+''', ''abj''); return false; \">'+Engine+'</a>, ';
          end;
          Engines:=Copy(Engines, 1, Length(Engines)-2);
        end;

            s:=s+'newcell.innerHTML="'+Engines+'";'#13#10;
      end else begin
        Stream.ReadStr;
      end;
    end else begin// двигатели
      s:=s+'drawenginestop10row('+IntToStr(ModelCode)+', "'+GetJSSafeString(Stream.ReadStr)+'", "'+GetJSSafeString(Stream.ReadStr)+'", "'+GetJSSafeString(Stream.ReadStr)+'", "'+GetJSSafeString(Stream.ReadStr)+'", "'+GetJSSafeString(Stream.ReadStr)+'", "'+GetJSSafeString(Stream.ReadStr)+'");'#13#10;
    end;


  end;
  s:=s+'podborwinresize();'#13#10;
  s:=s+'setCookie_("Top10Cookie", "'+Copy(Top10CookieValue, 2, Length(Top10CookieValue))+'", getExpDate_(365,0,0),"/",0,0);'#13#10;
  Result:=s;
end;//fnRefreshTop10List

function fnGetAttributeGroupList(Stream: TBoBMemoryStream;tablename:String): string;
var
  s, s1, s2: string;
  i, Count1: integer;
  isNew:Boolean;
begin
  s:='';
  if tablename<>'' then begin
    s:=s+'tbl=$("#'+tablename+'");'#13#10;
    s:=s+'tbl.empty();'#13#10;
    s:=s+'tbl=tbl[0];'#13#10;
  end;

  Count1:=Stream.ReadInt;
  for i:=0 to Count1-1 do begin
    s1:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    isNew:=Stream.ReadBool;
    if tablename<>'' then begin
      s:=s+'var row=tbl.insertRow(-1);'#13#10;
      s:=s+'var newcell=row.insertCell(-1);'#13#10;
      if isNew then
        s:=s+'newcell.innerHTML=''<a class=tablabel id=grattrlink'+s1+' href="#" onclick=\''curmotoattrgroupname=this.innerHTML; ec("getattrlist", "id='+s1+'&name='+s2+'",'+fnIfStr(flNewModeCGI,'"newbj"','"abj"')+');\''>'+s2+'</a><span id="attrnewspan">New</span>'';'#13#10
      else
        s:=s+'newcell.innerHTML=''<a class=tablabel id=grattrlink'+s1+' href="#" onclick=\''curmotoattrgroupname=this.innerHTML; ec("getattrlist", "id='+s1+'&name='+s2+'",'+fnIfStr(flNewModeCGI,'"newbj"','"abj"')+');\''>'+s2+'</a>'';'#13#10;
    end;
  end;
  s:=s+'zebratable("#'+tablename+'");'#13#10;
  s:=s+'$(''#motoattrlisttable'').css(''border-spacing'','' 3px 6px'');';
  Result:=s;
end; //fnGetAttributeGroupList


function fnLoadFirms(Stream: TBoBMemoryStream): string;  // загрузить список контрагентов
var
  s: string;
  i, j: integer;
begin
 s:='var tbl=$("#firmstable")[0];'#13#10;
 s:=s+'while (tbl.rows.length) tbl.deleteRow(0);'#13#10;
 s:=s+'var altrow=false;'#13#10;
 j := Stream.ReadInt;
 for i := 1 to j do begin
   s:=s+'addfirmrowNew(' + IntToStr(Stream.ReadInt) + ', "' + GetJSSafeString(Stream.ReadStr) + '", "' + GetJSSafeString(Stream.ReadStr) + '", "' + GetJSSafeString(Stream.ReadStr) + '");'#13#10;
 end;
 Result:=s;
end;


function fnLoadPersons(Stream: TBoBMemoryStream;id:string): string; // загрузить список должностных лиц
var
  s: string;
  b: byte;
  i, j: integer;
  code, name, post, phone, email, login: string;
begin
  s:='';
  s:=s+'$("#personsdivWrap h1").html("ДОЛЖНОСТНЫЕ ЛИЦА("+$("#firmtr'+id+'")[0].cells[1].firstChild.innerHTML+")");'#13#10;
  s:=s+'var tbl=$("#personstable")[0];'#13#10;
  s:=s+'while (tbl.rows.length) tbl.deleteRow(0);'#13#10;
  s:=s+'var altrow=false;'#13#10;
  j := Stream.ReadInt;
  for i := 1 to j do begin
   code:=IntToStr(Stream.ReadInt);
   name:=GetJSSafeString(Stream.ReadStr);
   post:=GetJSSafeString(Stream.ReadStr);
   phone:=GetJSSafeString(Stream.ReadStr);
   email:=GetJSSafeString(Stream.ReadStr);
   login:=GetJSSafeString(Stream.ReadStr);
   b:=Stream.ReadByte;
   s:=s+'addpersonrowNew('+code+ ', '+id+ ', '+fnIfStr(fnBit(4, b), '1', '0')+', "'+name+'", "'+post+'", "'+phone+'", "'+email+'", "'+login+'", ';
   s:=s+fnIfStr(fnBit(1, b), '1', '0') + ', '+fnIfStr(fnBit(2, b), '1', '0')+');'#13#10;
  end;
  Result:=s;
end;

function fnLoadOrder(Stream: TBoBMemoryStream): string;
var
  s: string;
  OrderNum, Data, Status, FirmName, CreatorName, PayForm, Delivery, Comment, Currency, ContractName: string;
  ContractSys: integer;
  Count, i: integer;
  AccNum,AccDate,Creator,Sender: string;
  WareName, WareUnit: string;
  RowQty, RowPrice, RowSumm, Summ: double;

begin
  s:='';
  Stream:=TBoBMemoryStream.Create;
  OrderNum:=Stream.ReadStr;
  Data:=Stream.ReadStr;
  Status:=Stream.ReadStr;
  AccNum:=Stream.ReadStr;
  AccDate:=Stream.ReadStr;
  Creator:=Stream.ReadStr;
  Sender:=Stream.ReadStr;
  FirmName:=GetJSSafeStringArg(Stream.ReadStr);
  PayForm:=Stream.ReadStr;
  Delivery:=Stream.ReadStr;
  Comment:=Stream.ReadStr;
  Currency:=Stream.ReadStr;
  ContractName:=Stream.ReadStr;
  s:=s+'$("#orderdata1").html("Заказ № <b>'+OrderNum+'</b> от <b>'+Data+'</b>. Создал <b>'+GetHTMLSafeString(Creator)+'</b>.");'#13#10;
  s:=s+'$("#orderdata2").html("Статус <b>'+Status+'</b> Счет <b>'+AccNum+'</b> Сформирован <b>'+AccDate+'</b> Отправил <b>'+GetHTMLSafeString(Sender)+'</b>");'#13#10;
  s:=s+'$("#orderdata3").html("Контракт <b>'+ContractName+'</b> Контрагент <b>'+GetHTMLSafeString(FirmName)+'</b>.");'#13#10;
  s:=s+'$("#orderdata6").html("</b>Доставка <b>'+GetHTMLSafeString(Delivery)+'");'#13#10;
  s:=s+'$("#orderdata5").html("Комментарий клиента:<i>'+Comment+'</i>.");'#13#10;

  s:=s+'var tbl=$("#tableheader")[0];'#13#10;
  s:=s+'tbl.rows[0].cells[3].innerHTML="Цена, '+Currency+'";'#13#10;

  Count:=Stream.ReadInt-1;

  s:=s+'var tbl=$("#tablecontent")[0]; var row, cell;'#13#10;
  s:=s+'for (;tbl.rows.length; tbl.deleteRow(0));'#13#10;
  Summ:=0.;
  for I := 0 to Count do begin
     WareName:=GetJSSafeStringArg(Stream.ReadStr);
     WareUnit:=GetJSSafeStringArg(Stream.ReadStr);
     RowQty:=Stream.ReadDouble;
     RowPrice:=Stream.ReadDouble;
     RowSumm:=RowQty*RowPrice;
     Summ:=Summ+RowSumm;
     s:=s+'row=tbl.insertRow(-1);'#13#10;
     s:=s+'cell=row.insertCell(-1);'#13#10;
     s:=s+'cell.innerHTML="'+WareName+'";'#13#10;
     s:=s+'cell=row.insertCell(-1);'#13#10;
     s:=s+'cell.innerHTML="'+FormatFloat('# ##0', RowQty)+'";'#13#10;
     s:=s+'cell=row.insertCell(-1);'#13#10;
     s:=s+'cell.innerHTML="'+WareUnit+'";'#13#10;
     s:=s+'cell=row.insertCell(-1);'#13#10;
     s:=s+'cell.innerHTML="'+FormatFloat('# ##0.00', RowPrice)+'";'#13#10;
     s:=s+'cell=row.insertCell(-1);'#13#10;
     s:=s+'cell.innerHTML="'+FormatFloat('# ##0.00', RowSumm)+'";'#13#10;
  end;
  s:=s+'$("#tableheader")[0].rows[0].cells[4].innerHTML="&#8721; '+FormatFloat('# ##0.00', Summ)+', '+Currency+'";'#13#10;
  s:=s+'set_sizes();'#13#10;
  s:=s+'zebratable(tbl);'#13#10;
  Result:=s;
end; // fnLoadOrder

function fnLoadManufactures(Stream: TBoBMemoryStream; sys: String): string;
var
  s: string;
  i, j: integer;
begin
  s:='var tbl=$("#manuftable")[0];'#13#10;
  s:=s+'var altrow=false;'#13#10;
  j := Stream.ReadInt;
  for i := 1 to j do begin
    s:=s+'addmanufrow(' + IntToStr(Stream.ReadInt) + ', "' + GetJSSafeString(Stream.ReadStr) + '", '+fnIfStr(Stream.ReadBool, '1', '0')+', '+fnIfStr(Stream.ReadBool, '1', '0')+', '+sys;
    Stream.ReadBool;
    s:=s+', '+fnIfStr(Stream.ReadBool, '1', '0')+');'#13#10;
  end;
  Result:=s;
end;

function fnEditManufacturer(Stream: TBoBMemoryStream): string; // редактирует производителей авто/мото
var
  s: string;
begin
  s:='';
  s:=s+'reloadpage();'#13#10;
  Result:=s;
end;

function fnDelTreeNode(Stream: TBoBMemoryStream; id:String): string;
var
  s: string;
begin
 s:=s+'var ul=$(''#tv_li_'+trim(id)+''')[0].parentNode.id.substr('+IntToStr(Length('tv_ul_'))+');'#13#10;
 s:=s+'$(''#tv_li_'+trim(id)+''').remove();'#13#10;
 s:=s+'if (!$(''#tv_ul_''+ul).children().length) {'#13#10;
 s:=s+'  $(''#tv_a1_''+ul).html('''');'#13#10;
 s:=s+'  $(this).unbind(''click'');'#13#10;
 s:=s+'};'#13#10;
 s:=s+'$("#curnodetd").html(''нет'');'#13#10;
 s:=s+'$("#outername").val('''');'#13#10;
 s:=s+'$("#innername").val('''');'#13#10;
 s:=s+'$("#nodevisibility")[0].checked=true;'#13#10;
 s:=s+'$("#mainnodecode").val('''');'#13#10;
 s:=s+'$("#mainnodename").html('''');'#13#10;
 s:=s+'curnode=null;'#13#10;
 Result:=s;
end;

function fnEditTreeNode(Stream: TBoBMemoryStream; id:String; mess:String; mainnode:String): string;
var
  s: string;
begin
 s:=s+'$("#innername").val('''+mess+''');'#13#10;
 s:=s+'$(''#tv_a2_'+trim(id)+''').html($(''#outername'').val());'#13#10;
 s:=s+'$(''#tv_a2_'+trim(id)+''').attr(''title'', '''+GetJSSafeString(mess)+''');'#13#10;
 s:=s+'$(''#tv_a2_'+trim(id)+''').attr(''mainnode'', '''+GetJSSafeString(mess)+''');'#13#10;
 s:=s+'$(''#tv_cb_'+trim(id)+''')[0].checked=$("#nodevisibility")[0].checked;'#13#10;
 // а теперь - ГЛАВНАЯ НОДА!!!!!!
 s:=s+'$(''#tv_a2_'+id+''').attr(''mainnode'', '''+mainnode+''');'#13#10;
 s:=s+'$(''#smnp_'+trim(id)+''').css(''visibility'', '''+fnIfStr(mainnode=id, 'visible', 'hidden')+''');'#13#10;
 Result:=s;
end;

function fnAddTreeNode(Stream: TBoBMemoryStream;i:integer; id:String; mess:String; vis:String; newname:String): string;
var
  s: string;
begin
  s:=s+'addbranch('+IntToStr(i)+', '+trim(id)+', "'+UTF8ToAnsi(trim(newname))+'", "'+mess+'", '+vis+', '+intToStr(i)+', true);'#13#10;
// назначаю функции сворачивания/разворачивания узлов
  s:=s+fnBindFuncToNewNodes(IntToStr(i));
  s:=s+fnBindFuncToNewNodes(id);
//           Раскрываю текущий пункт если нужно
  s:=s+'    if ($(''#tv_a1_'+trim(id)+''')[0].innerHTML.charCodeAt(0) == 9658 ) {'#13#10;
  s:=s+'      $(''#tv_a1_'+trim(id)+''').trigger(''click'');'#13#10;
  s:=s+'    }'#13#10;
//
  s:=s+'    $(''#tv_a2_'+id+''').attr("isend", "false");'#13#10;
  s:=s+'    $(''#smnp_'+id+''').css("visibility", "hidden");'#13#10;
  s:=s+'$(''#tv_a2_'+IntToStr(i)+''').trigger(''click'');'#13#10;
 Result:=s;
end;

function fnAddSubTreeNode(Stream: TBoBMemoryStream;i:integer; id:String; mess:String; vis:String; newname:String): string;
var
  s: string;
begin
 s:=s+'addbranch('+IntToStr(i)+', '+trim(id)+', "'+UTF8ToAnsi(trim(newname))+'", "'+mess+'", '+vis+', '+intToStr(i)+', true);'#13#10;
// назначаю функции сворачивания/разворачивания узлов
 s:=s+fnBindFuncToNewNodes(IntToStr(i));
 s:=s+fnBindFuncToNewNodes(id);

//           Раскрываю текущий пункт если нужно
 s:=s+'    if ($(''#tv_a1_'+trim(id)+''')[0].innerHTML.charCodeAt(0) == 9658 ) {'#13#10;
 s:=s+'      $(''#tv_a1_'+trim(id)+''').trigger(''click'');'#13#10;
 s:=s+'    }'#13#10;
//
 s:=s+'    $(''#tv_a2_'+id+''').attr("isend", "false");'#13#10;
 s:=s+'    $(''#smnp_'+id+''').css("visibility", "hidden");'#13#10;

 s:=s+'$(''#tv_a2_'+IntToStr(i)+''').trigger(''click'');'#13#10;
 Result:=s;
end;



function fnLoadModelLine(func:String;Stream: TBoBMemoryStream; rep:String; sys:String; id:String): string;
var
  s, s2: string;
  i, j, byear, bmonth, eyear, emonth: integer;
begin
  s:='$("#modellinetable").empty();'#13#10;
  s:=s+'var tbl=$("#modellinetable")[0];'#13#10;
  s:=s+'var altrow=false;'#13#10;
  s:=s+'modelline=new Array();'#13#10;
  j := Stream.ReadInt;
  for i := 1 to j do begin
    s:=s+func+'(' + IntToStr(Stream.ReadInt) + ', "' + GetJSSafeString(Stream.ReadStr) + '", '
        +fnIfStr(rep='rep',fnIfStr((i-1)<j/2,'1','0'),fnIfStr(Stream.ReadBool, '1', '0'))
        +', '+fnIfStr(Stream.ReadBool, '1', '0')+', '//
        +trim(sys)+', "';
    byear:=Stream.ReadInt;
    bmonth:=Stream.ReadInt;
    eyear:=Stream.ReadInt;
    emonth:=Stream.ReadInt;
    s2:=fnGetYMBE(byear, bmonth, eyear, emonth);
    s:=s+s2+'", '+IntToStr(byear)+', '+IntToStr(bmonth)+', '+IntToStr(eyear)+', '+IntToStr(emonth)+', '+IntToStr(Stream.ReadInt)
    +', '+id+');'#13#10;
  end;
  s:=s+'$("#addmodelline").attr("name", '+trim(id)+');'#13#10;
  s:=s+'$("#addmodelline").css("display", "block");'#13#10;
  s:=s+'$("#modellinedivWrap h1").html("МОДЕЛЬНЫЕ РЯДЫ("+$("#manuftr'+trim(id)+' td div span a").html()+")");'#13#10;
  Result:=s;
end;

function fnGetCriteriaValues(Stream: TBoBMemoryStream;value:String): string;
var
  s, s1 : string;
  Count, i: integer;
begin
  s:='';
  s1:='';
  try
    s:=s+'$("#critsearchbtn").css("display", "none");';
    s:=s+'$("ul.ui-autocomplete").css("display", "none");'#13#10;

    Count:=Stream.ReadInt-1;
    if Count>-1 then begin
      for i:=0 to Count do begin
        if i>0 then s1:=s1+', ';
          s1:=s1+'{label: "'+GetJSSafeString(Stream.ReadStr)+'", category:"Последние"}';
      end;
    end;

    Count:=Stream.ReadInt-1;

    for i:=0 to Count do begin
      if s1<>'' then s1:=s1+', ';
        s1:=s1+'{label: "'+GetJSSafeString(Stream.ReadStr)+'", category:"Все"}';
    end;

    if s1<>'' then begin
      s:=s+'$("#critsearchbtn").css("display", "block");';
      s:=s+'$.widget("custom.catcomplete", $.ui.autocomplete, {'#13#10;
      s:=s+'  _renderMenu: function(ul, items){'#13#10;
      s:=s+'    var self = this,'#13#10;
      s:=s+'    currentCategory = "";'#13#10;
      s:=s+'    $.each( items, function(index, item){'#13#10;
      s:=s+'      if(item.category != currentCategory){'#13#10;
      s:=s+'        ul.append( "<li class=''ui-autocomplete-category''>" + item.category + "</li>" );'#13#10;
      s:=s+'        currentCategory = item.category;'#13#10;
      s:=s+'      }'#13#10;
      s:=s+'      self._renderItem( ul, item );'#13#10;
      s:=s+'    });'#13#10;
      s:=s+'  }'#13#10;
      s:=s+'});'#13#10;
      s:=s+'$("#critvalue").catcomplete({minLength: 0, source: ['+s1+']});'#13#10;

      s:=s+'$(''#critsearchbtn'').unbind(''click'');';
      s:=s+'$(''#critsearchbtn'').bind(''click'', function(event) {'#13#10;
      s:=s+'  if ($("ul.ui-autocomplete").css("display")=="none") {'#13#10;
      s:=s+'    $(''#critvalue'').catcomplete(''search'' , $(''#critvalue'').val());'#13#10;
      s:=s+'  } else { '#13#10;
      s:=s+'    $("ul.ui-autocomplete").css("display", "none");'#13#10;
      s:=s+'  }'#13#10;
      s:=s+'});'#13#10;
    end;
    s:=s+'$("#critvalue").val("'+value+'");'#13#10;
    s:=s+'$("#addcoudiv").dialog("open");'#13#10;
  finally
   Result:=s;
  end;
end; //fnGetCriteriaValues

function fnShowPortion(Stream: TBoBMemoryStream;portion:String;mode:String;model:String;node:String;ware:String;UserID:String;ThreadData: TThreadData): string;
var
  s, s1 : string;
  Count, i: integer;
begin
  s:='';
  s1:='';
  try
    if portion='-1' then begin
      s1:=s1+'<table id="criteriatbl">';
      s1:=s1+'</table>';
      s:=s+'$("#jqueryuidiv").html('''+fnGetPortionWindow(s1)+''');'#13#10;
      s:=s+'$("button").button();'#13#10;
      s:=s+'$("#uiSavePortion").button( "option", "disabled", true );'#13#10;
      s:=s+'$("#jqueryuidiv").dialog({ modal: true, zIndex: 950, width: "auto", title: "Новый блок условий применимости" });'#13#10;
      s:=s+'$("#blocknum").val(-1);'#13#10;
     end else begin
        Stream:=TBoBMemoryStream.Create;
        Stream.WriteInt(StrToInt(UserID));
        Stream.WriteInt(StrToInt(model));
        Stream.WriteInt(StrToInt(node));
        Stream.WriteInt(StrToInt(ware));
        Stream.WriteInt(StrToInt(portion));
        prShowPortion(Stream,ThreadData);
        if Stream.ReadInt=aeSuccess then begin
          s1:=s1+'<table id="criteriatbl">';
          Count:=Stream.ReadInt-1;
          for i:=0 to Count do begin
            s1:=s1+'<tr id=trport_'+IntToStr(i)+'><td style="text-align:right;">'+GetHTMLSafeString(Stream.ReadStr)+':&nbsp;</td><td>'+GetHTMLSafeString(Stream.ReadStr)+'</td><td><div style="width: 32px; height: 16px;position: relative;"> '
                  +'<a class=abANew href=# onClick="editcondition('+IntToStr(i)+');" style="background-image: url('+DescrImageUrl+'/images/wedit.png); display: block; padding: 0; "></a>'
                  +'<a class=abANew href=# onClick="delcondition('+IntToStr(i)+');" style="background-image: url('+DescrImageUrl+'/images/wdell.png); display: block; padding: 0; position: absolute; right: 0;"></a>'
                  +'</div></td></tr>';
          end;
          s1:=s1+'</table>';

          s:=s+'$("#jqueryuidiv").html('''+fnGetPortionWindow(s1)+''');'#13#10;
          s:=s+'$("button").button();'#13#10;
          s:=s+'$("#uiSavePortion").button( "option", "disabled", true );'#13#10;
          s:=s+'$("#jqueryuidiv").dialog({ modal: true, zIndex: 950, width: "auto", title: "'+fnIfStr(mode='edit', 'Редактирование', 'Копия')+' блока №'+portion+'" });'#13#10;
          s:=s+'$("#blocknum").val('+fnIfStr(mode='edit', portion, '-1')+');'#13#10;
        end else begin
          s1:=Stream.ReadStr;
          s:=s+'qswMessageError("'+GetJSSafeString(s1)+'");';
        end;
      end;
  finally
    Result:=s;
  end;
end; //fnShowPortion

function fnSavePortion(Stream: TBoBMemoryStream;ware:String;node:String;model:String): string;
var
  s, s1 : string;
  Count, i: integer;
  Position: integer;
begin
  s:='';
  s1:='';
  try
    s:=s+'ec("showconditionportions", "ware='+ware+'&node='+node+'&model='+model+'", "newbj");'#13#10;
    s:=s+'$(''#jqueryuidiv'').dialog(''destroy'');'#13#10;
  finally
    Result:=s;
  end;
end; //fnSavePortion

function fnShowConditionPortions(Stream: TBoBMemoryStream;ware:String;node:String;model:String): string;
var
  s, ss, BlockCode, BlockType: string;
  BlockWrong: boolean;
  Count, i, BlockTypeI: integer;
begin
  s:='';
  ss:='';
  try
    s:=s+'$("#inp_modelid").val('+model+');'#13#10;
    s:=s+'$("#inp_nodeid").val('+node+');'#13#10;
    s:=s+'$("#inp_wareid").val('+ware+');'#13#10;
    s:=s+'$("#btn_addportion").css("display", "inline");'#13#10;

    s:=s+'$("#tablecontentdiv h1").html(''Условия применимости товара <span>'+GetJSSafeString(Stream.ReadStr+'</span> к узлу <span>'+Stream.ReadStr+'</span> модели <span>'+GetJSSafeStringArgMonoQuote(Stream.ReadStr))+'</span>'');'#13#10;
    Count:=Stream.ReadInt;
    ss:=ss+'<table>';
    for i:=0 to Count-1 do begin
      BlockTypeI:=Stream.ReadInt;
      BlockCode:=IntToStr(Stream.ReadInt);
      BlockWrong:=(BlockTypeI>cWrongPart);
      if BlockWrong then BlockTypeI:=BlockTypeI-cWrongPart;
        BlockType:=IntToStr(BlockTypeI);

      ss:=ss+'<tr><td><fieldset style="width: 100%;'+fnIfStr(BlockWrong, 'background-color: cyan;', '')+'">';
      ss:=ss+'<legend><img src="/images/src_'+BlockType+'.gif"> Блок #'+BlockCode+'</legend>';
      ss:=ss+GetHTMLSafeString(Stream.ReadStr);
      ss:=ss+'</fieldset></td>';
      ss:=ss+'<td style="padding-left: 25px;">';
      if BlockWrong then begin
        ss:=ss+'<input type=button value="Пометить, как правильный" onclick="ec(\''markportion\'', \''model='+model+'&node='+node+'&ware='+ware+'&portion='+BlockCode+'&mark=right\'', \''newbj\'');">';
      end else if BlockTypeI in [soTDparts, soTecDocBatch] then begin
        ss:=ss+'<input type=button value="Пометить, как неправильный" onclick="ec(\''markportion\'', \''model='+model+'&node='+node+'&ware='+ware+'&portion='+BlockCode+'&mark=wrong\'', \''newbj\'');">';
          end else begin
            ss:=ss+'<br><input type=button value="Редактировать" onclick="ec(\''showportion\'', \''model='+model+'&node='+node+'&ware='+ware+'&portion='+BlockCode+'&mode=edit\'', \''newbj\'');">';
            ss:=ss+'<input type=button value="Удалить" onclick="if (confirm(\''Вы действительно хотите удалить блок условий?\'')) {ec(\''markportion\'', \''model='+model+'&node='+node+'&ware='+ware+'&portion='+BlockCode+'&mark=del\'', \''newbj\'');}">';
          end;
        ss:=ss+'<br><input type=button value="Добавить копию" onclick="ec(\''showportion\'', \''model='+model+'&node='+node+'&ware='+ware+'&portion='+BlockCode+'\'', \''newbj\'');">';
        ss:=ss+'</td></tr>';
      end;
      ss:=ss+'</table>';
      s:=s+'$("#portions").html('''+ss+''');'#13#10;
  finally
    Result:=s;
  end;
end; //fnShowConditionPortions

function fnMarkPortion(Stream: TBoBMemoryStream;ware:String;node:String;model:String): string;
var
  s, s1 : string;
begin
  s:='';
  try
    s:=s+'ec("showconditionportions", "ware='+ware+'&node='+node+'&model='+model+'", "newbj");'#13#10;
  finally
    Result:=s;
  end;
end; //fnMarkPortion


function fnLoadInvoice(Stream: TBoBMemoryStream;id:String): string;
var
  s, s1, s2, s3, dop, WareCode, LineCode, Wares, ForFirmCode, PInvCode, labelcode, ContractName: string;
  InvBlocked: boolean;
  i,Count, ContractID, ContractCount: integer;
  data: TDateTime;
  warename, zakaz, fact, _unit, price, summ, descr: string;
  Locked, Annulated, Closed: boolean;
begin
  s:='';
  dop:='';
  Wares:='';
  Locked:=Stream.ReadBool;
  Annulated:=Stream.ReadBool;
  Closed:=Stream.ReadBool;
  s:=s+'$("#invoicestatus").html("'+fnIfStr(Closed, 'Закрыт', fnIfStr(Annulated, 'Аннулирован', fnIfStr(Locked, 'Заблокирован', 'Открыт')))+'");'#13#10;
  Locked:=Closed or Annulated or Locked;
  s:=s+'$("#invoicestatus").css("color", "'+fnIfStr(Locked, 'red', 'green')+'");'#13#10;

  s:=s+'$("#deliverieslistbtn").css("display", "inline");'#13#10;
  s:=s+'$("#forfirmid").val("'+IntToStr(Stream.ReadInt)+'");'#13#10;
  s1:=GetJSSafeString(Stream.ReadStr)+'||'+GetJSSafeString(Stream.ReadStr);
  s:=s+'$("#invoicefirm").attr("oldval", "'+s1+'");'#13#10;
  s:=s+'$("#invoicefirm").val("'+s1+'");'#13#10;
  s:=s+'$("#invoicefirm").css("background-color", inputbgcolor);'#13#10;
  s:=s+'$("#invoicefirm").attr("disabled", '+BoBBoolToStr(Locked)+');'#13#10;

  s:=s+'$("#contract").val('+IntToStr(Stream.ReadInt)+');'#13#10;
  s:=s+'$("#invoicecontract").html("'+Stream.ReadStr+'");'#13#10;
  s:=s+'$("#changeinvoicecontract").css("display", "'+fnIfStr(Stream.ReadInt>1, 'inline-block', 'none')+'");'#13#10;
  //s:=s+'$("#contractbusinesstypeimg").css("background-image", "url('+DescrImageUrl+'/images/'+fnIfStr(Stream.ReadBool, 'auto16', 'bike16')+'.png");'#13#10;
  Stream.ReadBool; //После удаления направлений контрактов

  s1:=IntToStr(Stream.ReadInt);
  s:=s+'$("#invoicestorage").attr("oldval", "'+s1+'");'#13#10;
  s:=s+'$("#invoicestorage").val("'+s1+'");'#13#10;
  if not Locked then s:=s+'$("#invoicestorage").attr("disabled", false);'#13#10;
{
        s1:=IntToStr(Stream.ReadInt);
        s:=s+'$("#invoicecurr").attr("oldval", "'+s1+'");'#13#10;
        s:=s+'$("#invoicecurr").val("'+s1+'");'#13#10;
        if not Locked then s:=s+'$("#invoicecurr").attr("disabled", false);'#13#10;
}
  s1:=Stream.ReadStr;
  s:=s+'$("#invoicecurr").html("'+s1+'");'#13#10;

  s:=s+'$("#invoicecode").val("'+IntToStr(Stream.ReadInt)+'");'#13#10;
  s:=s+'$("#invoicenum").html("'+Stream.ReadStr+'");'#13#10;
  s:=s+'$("#invoicenum").attr("disabled", '+BoBBoolToStr(Locked)+');'#13#10;
  data:=Stream.ReadDouble;
  s1:=FormatdateTime(cDateFormatY2, data);
  s:=s+'$("#invoicedate").val("'+s1+'");'#13#10;
  if not Locked then s:=s+'$("#invoicedate").attr("disabled", false);'#13#10;
  s:=s+'$("#invoicedate").attr("oldval", "'+s1+'");'#13#10;
  s:=s+'$("#invoiceprocessed")[0].checked='+fnIfStr(Stream.ReadBool, 'true', 'false')+';'#13#10;
  if not Locked then s:=s+'$("#invoiceprocessed").attr("disabled", false);'#13#10;
  s:=s+'$("#invoicesumm").html("'+Stream.ReadStr+'");'#13#10;
  s1:=GetJSSafeString(Stream.ReadStr);
  s:=s+'$("#invoicemaincomment").attr("oldval", "'+s1+'");'#13#10;
  s:=s+'$("#invoicemaincomment").val("'+s1+'");'#13#10;
  if not Locked then s:=s+'$("#invoicemaincomment").attr("disabled", false);'#13#10;
  s:=s+'$("#invoicewebcomment").html("'+GetJSSafeString(Stream.ReadStr)+'");'#13#10;
  s1:=GetJSSafeString(Stream.ReadStr);
  s:=s+'$("#invoiceclientcomment").attr("oldval", "'+s1+'");'#13#10;
  s:=s+'$("#invoiceclientcomment").val("'+s1+'");'#13#10;
  if not Locked then s:=s+'$("#invoiceclientcomment").attr("disabled", false);'#13#10;
  s:=s+'$("#invoiceparent").html("<a href=# class=''tablabel2'' onclick=''loadpayinvoice(-1, '+intToStr(Stream.ReadInt)+');''>'+GetJSSafeString(Stream.ReadStr)+'");'#13#10;

  Stream.ReadStr;            // создатель счета
  Count:=Stream.ReadInt;
  //s:=s+'_select=$(''#invoicedeliverytype'')[0];'#13#10;
  //s:=s+'_select.options[0]= new Option('''', 0, false, false);'#13#10;
  for i:=0 to Count-1 do begin
    s1:=IntToStr(Stream.ReadInt);
    Stream.ReadStr;
    //s:=s+'_select.options[_select.options.length]= new Option("'+GetJSSafeString(Stream.ReadStr)+'", "'+s1+'", false, false);'#13#10;
  end;
  s1:=IntToStr(Stream.ReadInt);
  // s:=s+'$("#invoicedeliverytype").attr("oldval", "'+s1+'");'#13#10;
  //s:=s+'$("#invoicedeliverytype").val("'+s1+'");'#13#10;
  //if not Locked then s:=s+'$("#invoicedeliverytype").attr("disabled", false);'#13#10;

  i:=Stream.ReadInt;
  if i>-1 then begin
    s:=s+'$("#invoicedeliverytime").attr("oldval", "'+IntToStr(i)+'");'#13#10;
    s:=s+'$("#invoicedeliverytime").val("'+IntToStr(i)+'");'#13#10;
    if not Locked then s:=s+'$("#invoicedeliverytime").attr("disabled", deliverytimekey['+IntToStr(i)+']);'#13#10;
  end;

  data:=Stream.ReadDouble;
  if data=0 then begin
    s1:='';
  end else begin
       s1:=FormatdateTime(cDateFormatY2, data);
      end;

  s:=s+'$("#invoicedeliverydate").attr("oldval", "'+s1+'");'#13#10;
  s:=s+'$("#invoicedeliverydate").val("'+s1+'");'#13#10;
  if not Locked then s:=s+'$("#invoicedeliverydate").attr("disabled", false);'#13#10;
  s:=s+'tbl=$("#tablecontent")[0];'#13#10;
  i:=Stream.ReadInt;

  if not Locked then begin
    if i>-1 then begin
            //s:=s+'$("#invoicedeliverylabeltext").attr("disabled", false);'#13#10;
            //s:=s+'$("#invoicedeliverylabelbtn").attr("disabled", false);'#13#10;
    end else begin
          i:=0;
            //s:=s+'$("#invoicedeliverylabelbtn").attr("disabled", true);'#13#10;
        end;
  end;
  labelcode:=IntToStr(i);

  s:=s+'$(".accworkbtn").attr("disabled", '+BoBBoolToStr(Locked)+');'#13#10; // запрещаем/разрешаем кнопки

  // настраиваю кнопку аннуляции
  s:=s+'var btn=$("#accannulbtn");'#13#10;
  s:=s+'btn.attr("act","'+fnIfStr(Annulated, 'deannul', 'annul')+'");'#13#10;
  s:=s+'btn.find("img").css("background-image", "url(/images/'+fnIfStr(Annulated, 'un', '')+'annulbtn.png)");'#13#10;
  s:=s+'btn.find("img").css("right", "16px");'#13#10;
  s:=s+'btn.attr("title","'+fnIfStr(Annulated, 'Деаннулировать', 'Аннулировать')+'");'#13#10;
  s:=s+'btn[0].onclick=function() {setannul(btn[0], '+id+');}'#13#10;



// пошли строки счета
  Count:=Stream.ReadInt;
  s1:='<table id=labelstbl class=st>';
    s1:=s1+'<tr class=\"grayline\">';
       s1:=s1+'<td>Наименование</td>';
       s1:=s1+'<td>Встречающие</td>';
       s1:=s1+'<td>Телефон</td>';
       s1:=s1+'<td>Перевозчик</td>';
       s1:=s1+'<td>Время отпр</td>';
       s1:=s1+'<td>Примечание</td>';
    s1:=s1+'</tr>';
    s2:='0';
    s1:=s1+'<tr id=\"labelrow_'+s2+'\" class=\"lblchoice'+fnIfStr(s2=labelcode, ' selected', '')+'\" code=\"'+s2+'\" onclick=\"selectdeliverylabel('+s2+');\">';
       s1:=s1+'<td> </td>';
       s1:=s1+'<td> </td>';
       s1:=s1+'<td> </td>';
       s1:=s1+'<td> </td>';
       s1:=s1+'<td> </td>';
       s1:=s1+'<td> </td>';
       s1:=s1+'</tr>';
   for i:=0 to Count-1 do begin
     s2:=IntToStr(Stream.ReadInt);
     s1:=s1+'<tr id=\"labelrow_'+s2+'\" class=\"lblchoice'+fnIfStr(s2=labelcode, ' selected', '')+'\" code=\"'+s2+'\" onclick=\"selectdeliverylabel('+s2+');\">';
     s1:=s1+'<td>'+GetJSSafeStringArg(Stream.ReadStr)+'</td>';
     s1:=s1+'<td>'+GetJSSafeStringArg(Stream.ReadStr)+'</td>';
     s1:=s1+'<td>'+GetJSSafeStringArg(Stream.ReadStr)+'</td>';
     s1:=s1+'<td>'+GetJSSafeStringArg(Stream.ReadStr)+'</td>';
     s1:=s1+'<td>'+GetJSSafeStringArg(Stream.ReadStr)+'</td>';
     s1:=s1+'<td>'+GetJSSafeStringArg(Stream.ReadStr)+'</td>';
     s1:=s1+'</tr>';
   end;
   s1:=s1+'</table>';
   //s:=s+'$("#invoicedeliverylabelcode").val("'+labelcode+'");'#13#10;
   s:=s+'$("#labelsdiv").html("'+s1+'");'#13#10;
   if (labelcode='0') then begin
     //s:=s+'$("#invoicedeliverylabeltext").val("");'#13#10;
     // s:=s+'$("#invoicedeliverylabeltext").attr("oldval", "");'#13#10;
   end else begin
     //s:=s+'$("#invoicedeliverylabeltext").val($(''#labelstbl tr.selected td'').html());'#13#10;
     //s:=s+'$("#invoicedeliverylabeltext").attr("oldval", $(''#labelstbl tr.selected td'').html());'#13#10;
   end;
   s:=s+'zebratable($("#labelstbl")[0]);'#13#10;


   Count:=Stream.ReadInt;
   for i:=0 to Count-1 do begin
     LineCode:=IntToStr(Stream.ReadInt);
     WareCode:=IntToStr(Stream.ReadInt);
     Wares:=Wares+','+WareCode;
     warename:=GetJSSafeString(Stream.ReadStr);
     zakaz:=GetJSSafeString(Stream.ReadStr);
     fact:=GetJSSafeString(Stream.ReadStr);
     _unit:=GetJSSafeString(Stream.ReadStr);
     price:=GetJSSafeString(Stream.ReadStr);
     summ:=GetJSSafeString(Stream.ReadStr);
     descr:=GetJSSafeString(Stream.ReadStr);
     s:=s+'addaccline('+BoBBoolToStr(Locked)+', '+LineCode+', '+WareCode+', "'+warename+'", "'+zakaz+'", "'+fact+'", "'+_unit+'", "'+price+'", "'+summ+'", "'+descr+'");'#13#10;
   end;
   s:=s+'set_sizes();'#13#10;
   s:=s+'zebratable(tbl);'#13#10;
   s:=s+'payinvoiceheaderbinding();'#13#10;
   s:=s+'ec("getrestsofwares", "warecodes='+Wares+'&forfirmid="+$(''#forfirmid'').val(), "newbj");'#13#10;
   s:=s+'ec("checkcontracts", "contractid="+$("#contract").val()+"&infoonly=true&&firmid="+$(''#forfirmid'').val(), "newbj");'#13#10;

   Result:=s+dop;

end;// fnLoadInvoice

function fnCheckContracts(Stream: TBoBMemoryStream): string;
var
  s, s1: string;
  i, ContractId, ContractsCount: integer;
  stemp: string;
  CredLimit, Debt, OrderSum, PlanOutSum,ContractRedSum,ContractVioletSum: double;
  CredCurrencyCode: integer;
  CredCurrency, FirmCode, WarningMessage, ContractName, ContractCurrency: string;
  SaleBlock: boolean;
  CredDelay, PaymentForm,ContractStatus: integer;
  InfoOnly: boolean;
  WhenBlocked: integer; // срок, через который наступит блокировка по причине просрочки оплаты
  LegalFirmName:string;
begin
  s:='';
  s1:='';
  ContractId:=Stream.ReadInt;
  ContractsCount:=Stream.ReadInt;
  if ContractId=0 then begin
    s:=s+'$("#contractname").html("Все");'#13#10;
    s1:=s1+'Чтобы увидеть оперативную информацию <a href=# onclick=\"ec(''selectcontract'', ''contractid=''+$(''#filtercontract'').val()+''&firmid=''+$(''#filterselectedfirm'').val(), ''newbj'');\">'
          +'выберите конкретный контракт</a>.';
  end else begin
       ContractName:=Stream.ReadStr; //ContractName
       CredLimit:=Stream.ReadDouble;
       Debt:=Stream.ReadDouble;
       OrderSum:=Stream.ReadDouble;
       PlanOutSum:=Stream.ReadDouble;

       CredCurrencyCode:=Stream.ReadInt;
       CredCurrency:=Stream.ReadStr;
       ContractCurrency:=Stream.ReadStr;
       PaymentForm:=Stream.ReadInt;
       LegalFirmName:=Stream.ReadStr;
       ContractStatus:=Stream.ReadInt;
       if not (ContractStatus in [0,1,2]) then begin
          s:='jqswMessageError(''Не найден Статус:'+IntToStr(ContractStatus)+''');';
          Exit;
       end;
       WarningMessage:=GetHTMLSafeString(Stream.ReadStr);
       SaleBlock:=Stream.ReadBool;
       ContractRedSum:=Stream.ReadDouble;
       ContractVioletSum:=Stream.ReadDouble;
       CredDelay:=Stream.ReadInt;
       if not SaleBlock then begin
         WhenBlocked:=Stream.ReadInt;
       end;

       s1:=s1+'<p>Контракт №'+ContractName//+' <img src=\"/images/tr.gif\" style=\"width: 16px; height: 16px; position: relative; top: 3px; background-image: url('+DescrImageUrl+'/images/'+fnIfStr(not IsMotoClient, 'auto16', 'bike16')+'.png);\">'
//                        +fnIfStr((ContractsCount>1), '<a id=contractmarkleft href=# class=abgslide onclick=''ec(\"contractlist\",\"position=left&contract='+IntToStr(ContractId)+'\");'' style=\"background-image: url('+DescrImageUrl+'/images/right_white.gif); float: right; position: static; width: 24px;\" title=\"Сменить текущий контракт\"></a>', '')+'</p>'
       ;
       s1:=s1+'<p>Форма оплаты: '+fnPayFormByCode(PaymentForm)+'</p>';
       s1:=s1+'<p>Валюта: '+ContractCurrency+'</p>';
       s1:=s1+'<p>Кр. условия: '+FormatFloat('# ##0.##', CredLimit)+' '+CredCurrency+'/'+IntToStr(CredDelay)+'дн.</p>';
       s1:=s1+'<p>'+fnIfStr(Debt>0, 'Долг', 'Переплата')+': '+FormatFloat('# ##0.00', Abs(Debt))+' '+CredCurrency+'</p>';

       s1:=s1+'<p '+fnIfStr((CredLimit-Debt-PlanOutSum)<0, 'style=''color: orange; font-weight: bold;''', '')+'>'+fnIfStr((CredLimit-Debt-PlanOutSum)<0, 'Превыш. кредита', 'Своб. кредит')+': '+FormatFloat('# ##0.00', Abs(CredLimit-Debt-PlanOutSum))+' '+CredCurrency+'</p>';
       s1:=s1+'<p>Резерв:'+FormatFloat('# ##0.00', OrderSum)+' '+CredCurrency+'</p>';
       i:=getBackGrColor(WarningMessage,ContractStatus,SaleBlock);
       s1:=s1+'<p '
              +'style=''font-weight: bold; color: '+fnIfStr(i=1,'black','white')+'; line-height: 20px; background-color: '
              +arDelayWarningsColor[i]+';'' title=\"'+WarningMessage+'\">Статус: '
              +ContStatusNames[ContractStatus]+'</p>';
       s1:=s1+'<p style='' line-height: 20px; ''>Просрочено: <span style='' color: red;font-weight: bold;''>'
                        +fnIfStr(ContractRedSum=0,'',FormatFloat('# ##0.00',ContractRedSum))+'</span></p>';
       s1:=s1+'<p style=''line-height: 20px; ''>Истекает срок: <span style='' color: #f0f;font-weight: bold;''>'
             +fnIfStr(ContractVioletSum=0,'',FormatFloat('# ##0.00',ContractVioletSum))+'</span></p>';

       if (not InfoOnly) then begin
         s:=s+'$("#contractname").html("'+ContractName+'");'#13#10;
       end;
    end;

    if (not InfoOnly) then begin
      s:=s+'$("#setcontractfilter").css("display", "'+fnIfStr(ContractsCount>1, 'inline-block', 'none')+'");'#13#10;
      s:=s+'$("#clearcontractfilter").css("display", "'+fnIfStr((ContractsCount>1) and (ContractId<>0), 'inline-block', 'none')+'");'#13#10;
      s:=s+'$("#filtercontract").val("'+IntToStr(ContractId)+'");'#13#10;
      s:=s+'$("#contractlistdiv").dialog("close");'#13#10;
    end;
    s:=s+'$("#contractdatadiv").html("'+s1+'").dialog("open");'#13#10;

    Result:=s;
end; // fnCheckContracts

function fnSaveAccHeaderPart(Stream: TBoBMemoryStream;partid: String;val: String; accid: String; annul:String): string;
var
  s, s1: string;
  i, OperationCode: integer;
begin
  s:='';
  case i of
     ceahChangeRecipient, ceahRecalcPrices, ceahRecalcCounts, ceahMakeInvoice, ceahChangeContract: begin
       s:=s+'loadpayinvoice(-1, '+accid+');'#13#10;
     end;
     ceahChangeEmplComm, ceahChangeClientComm, ceahChangeDocmDate, ceahChangeShipDate: begin
       s:=s+'$("#'+partid+'").attr("oldval", $("#'+partid+'").val());'#13#10;
       s:=s+'$("#'+partid+'").css("background-color", inputbgcolor);'#13#10;
     end;
     ceahChangeCurrency, ceahChangeShipMethod, ceahChangeShipTime: begin
       s:=s+'$("#'+partid+'").attr("oldval", $("#'+partid+'").val());'#13#10;
     end;
     ceahChangeStorage: begin
       s:=s+'$("#'+partid+'").attr("oldval", $("#'+partid+'").val());'#13#10;
       s:=s+'ec(''loadshipmethodsforstore'', ''id='+val+''', ''abj'');'#13#10;
     end;
     ceahChangeLabel: begin
       s:=s+'var code='+val+';'#13#10;
       s:=s+'$(''#labelstbl .selected'').removeClass("selected");'#13#10;
       s:=s+'$(''#labelrow_''+code).addClass("selected");'#13#10;
       s:=s+'$(''#invoicedeliverylabelcode'').val(code);'#13#10;
       s:=s+'$(''#invoicedeliverylabeltext'').val($(''#labelrow_''+code+'' td'').html());'#13#10;
       s:=s+'$.fancybox.close();'#13#10;
     end;
   end;
   if (i=ceahChangeShipMethod) then begin
     s:=s+'$("#invoicedeliverytime").attr("disabled", deliverytimekey['+val+']);'#13#10;
     s:=s+'if (deliverytimekey['+val+']) {'#13#10;
     s:=s+'  $(''#invoicedeliverytime'').attr(''oldval'', ''0'');'#13#10;
     s:=s+'  $(''#invoicedeliverytime'').val(''0'');'#13#10;
     s:=s+'}'#13#10;
     s:=s+'$("#invoicedeliverylabeltext").attr("disabled", deliverylabelkey['+val+']);'#13#10;
     s:=s+'$("#invoicedeliverylabelbtn").attr("disabled", deliverylabelkey['+val+']);'#13#10;
     s:=s+'if (deliverylabelkey['+val+']) {'#13#10;
     s:=s+'  $(''#invoicedeliverylabeltext'').val('''');'#13#10;
     s:=s+'  $(''#invoicedeliverylabelcode'').val(''0'');'#13#10;
     s:=s+'  $(''#labelstbl .selected'').removeClass("selected");'#13#10;
     s:=s+'  $(''#labelrow_0'').addClass("selected");'#13#10;
     s:=s+'}'#13#10;
   end;
   if (i=ceahMakeInvoice) then begin
     Stream.ReadInt; // пропускаем код накладной
     s:=s+'alert("Создана накладная №'+GetJSSafeString(Stream.ReadStr)+'");';
   end;
   if (i=ceahAnnulateInvoice) then begin
     s:=s+'if ($("#invoicesfilterdiv").css("display")=="block") {'#13#10;
     s:=s+'  var row=$("#accrow_'+accid+'")[0];'#13#10;
     s:=s+'  $(row).attr("annulated", "'+annul+'");'#13#10;
     s:=s+'  setaccrowcolor(row);'#13#10;
     s:=s+'  fillaccrowfirstcell(row, row.cells[0]);'#13#10;
     s:=s+'  fillaccrowlastcell(row, row.cells[row.cells.length-1]);'#13#10;
     s:=s+'  $("#jqdialog").dialog("close");'#13#10;
     s:=s+'} else {'#13#10;
     s:=s+'  loadpayinvoice(-1, '+accid+');'#13#10;
     s:=s+'}'#13#10;
     s:=s+'$("#jqdialog").dialog("close");'#13#10;

   end;
   if (i=ceahChangeContract) then begin
     s:=s+'$("#contractlistdiv").dialog("close");';
   end;
  Result:=s;

end;// fnSaveAccHeaderPart

function fnSelectContract(Stream: TBoBMemoryStream;ContractId:integer;invoiceid:String): string;
var
  s, stemp,deprtShortName,deprtName,FirmName,SelfCommentary,temp: string;
  Count, CurrentContractCode, i, j,ContractStatus: integer;
  Blocked: boolean;
  ContractRedSum,ContractVioletSum,ContractOrderSum:double;
begin
  s:='';
  Count:=Stream.ReadInt;
  s:=s+'<table class=st style="white-space: nowrap; font-size: 11px;">';
  s:=s+'<tr style="font-size: 14px;" class="grayline">';
  s:=s+'<td>№</td>';
  s:=s+'<td>Форма оплаты</td>';
  //s:=s+'<td>Напр.</td>';
  s:=s+'<td>Склад</td>';
  //s:=s+'<td>Контракт</td>';
  s:=s+'<td colspan=2>Сумма кредита</td>';
  s:=s+'<td>Отсрочка</td>';
  s:=s+'<td>Долг/перепл.</td>';
  s:=s+'<td>Резерв</td>';
  s:=s+'<td>Статус</td>';
  s:=s+'<td>Просрочено</td>';
  s:=s+'<td>Истекает срок</td>';
  s:=s+'<td>'+cTitleLegal+'</td>';
  s:=s+'<td>Комментарий</td>';
  s:=s+'</tr>';
  for i := 0 to Count-1 do begin
    CurrentContractCode:=Stream.ReadInt;
    s:=s+'<tr code='+IntToStr(CurrentContractCode)+fnIfStr(ContractId=CurrentContractCode, '', ' class="lblchoice"')+'>';
    s:=s+'<td>'+Stream.ReadStr+'</td>';
    s:=s+'<td>'+fnPayFormByCode(Stream.ReadInt)+'</td>';
   //s:=s+'<td>'+Stream.ReadStr+'</td>';
    FirmName:=Stream.ReadStr;
    stemp:=Stream.ReadStr;
    deprtShortName:=Stream.ReadStr;
    deprtName:=Stream.ReadStr;
    s:=s+'<td title="'+deprtName+'">'+deprtShortName+'</td>';
    //s:=s+'<td>'+stemp+'</td>';
    s:=s+'<td align=right>'+FormatFloat('# ##0.##', Stream.ReadDouble)+'</td>';
    s:=s+'<td>'+Stream.ReadStr+'</td>';
    s:=s+'<td>'+IntToStr(Stream.ReadInt)+'</td>';
    s:=s+'<td>'+FormatFloat('# ##0.##', Stream.ReadDouble)+'</td>';
    ContractOrderSum:=Stream.ReadDouble; // резерв
    ContractStatus:=Stream.ReadInt;
    if not (ContractStatus in [0,1,2]) then begin
      s:='jqswMessageError(''Не найден Статус:'+IntToStr(ContractStatus)+''');';
      Exit;
    end;
    Blocked:=Stream.ReadBool;
    stemp:=Stream.ReadStr;
    ContractRedSum:=Stream.ReadDouble;
    ContractVioletSum:=Stream.ReadDouble;
    SelfCommentary:=Stream.ReadStr;
    temp:=SelfCommentary;
    if (Length(SelfCommentary)>11) then  begin
      temp:=SelfCommentary;
      Delete(temp,8,Length(temp));
      temp:=temp+'...';
    end;
    s:=s+'<td>'+FormatFloat('# ##0.##', ContractOrderSum)+'</td>';   //резерв
    j:=getBackGrColor(stemp,ContractStatus,Blocked);
    s:=s+'<td style="padding: 0 10px 0 10px; background-color: '+arDelayWarningsColor[j]+'; color: '+fnIfStr(j=1,'black','white')+'; text-align: center; font-weight: bold;" title="'+stemp+'">'+ContStatusNames[ContractStatus]+'</td>';
    s:=s+'<td style="color: red; font-weight: bold;">'+fnIfStr(ContractRedSum=0,'',FormatFloat('# ##0.##', ContractRedSum))+'</td>';
    s:=s+'<td style="color: #f0f; font-weight: bold;">'+fnIfStr(ContractVioletSum=0,'',FormatFloat('# ##0.##', ContractVioletSum))+'</td>';

    s:=s+'<td>'+FirmName+'</td>';
    s:=s+'<td><span class="contractcommentspan" title="'+SelfCommentary+'">'+temp+'</span></td>';
    s:=s+'</tr>';
  end;
  s:=s+'</table>';
  stemp:='';

  s:='$("#contractlistdiv").html('''+s+''').dialog({modal:true,width:''auto'',resizable:true,title: "Выберите контракт", '
     +'open: function(event, ui) {$("#contractlistdiv .lblchoice").bind("click", function(event) {';

  i:=StrToIntDef(invoiceid, 0);
  if i=0 then begin
     s:=s+'  ec("checkcontracts", "contractid="+$(this).attr("code")+"&firmid="+$(''#filterselectedfirm'').val(), "newbj");'
  end else begin
     s:=s+'  ec("saveaccheaderpart", "val="+$(this).attr("code")+"&partid=invoicecontract&accid='+IntToStr(i)+'", "newbj");'
  end;
  s:=s+'})},'
      +'buttons: {}});';
  Result:=s;

end; // fnSelectContracts

function fnShowWareCompare(Stream: TBoBMemoryStream;FirmID:String; ScriptName:String; ContractId:integer): string;
type
TWareInfo = record
  Code,ActionCode: integer;
  Name: string;         // наименование
  IsSale,NonReturn,CutPrice: boolean;      // признак распродажи
  BrandNameWWW: string; // бренд для сайта
  BrandName: string;    // бренд
  BrandWWWAdr: string;    // адрес сайта производителя
  divis: double;        // кратность
  MeasName: string;     // ед.изм.
  Comment: string;      // описание
  Price: double;        // цена
  PriceC: double;       // цена клиента
  wattrs:  TAS;
  arPrices: Array of double;
  DirectName,ActionTitle,ActionText:string;
end;

var
  s, CurrName, ss, sss, Waress: string;
  i, ii, j, acount: integer;
  a: tai;
  attrs: TAS;
  Wares: array of TWareInfo;
  List: TStringList;
  k,Count,  Qty, Code:integer;
begin
  s:='';
  Waress:='0';
  CurrName:=Stream.ReadStr;
  acount:=Stream.ReadInt;
  SetLength(attrs, acount);
  for i:=0 to acount-1 do begin
    attrs[i]:=Stream.ReadStr;
  end;
  j:=Stream.ReadInt;
  SetLength(Wares, j);
  for i:=0 to j-1 do begin
    with Wares[i] do begin
      Code:=Stream.ReadInt;
      Waress:=Waress+','+IntToStr(Code);
      Name:=Stream.ReadStr;         // наименование
      IsSale:=Stream.ReadBool;      // признак распродажи
      NonReturn:=Stream.ReadBool;      // признак невозврата
      CutPrice:=Stream.ReadBool;      // признак уценки
      DirectName:=LowerCase(Stream.ReadStr);    //название направления для скидок
      BrandNameWWW:=Stream.ReadStr; // бренд для сайта
      BrandWWWAdr:=Stream.ReadStr;    // адрес сайта
      BrandName:=Stream.ReadStr;    // бренд
      divis:=Stream.ReadDouble;     // кратность
      MeasName:=Stream.ReadStr;     // ед.изм.
      Comment:=Stream.ReadStr;      // описание
      ActionCode:=Stream.ReadInt;         // код акции
      ActionTitle:=Stream.ReadStr +' <br> ';      // заголовок
      ActionText:=Stream.ReadStr;       // текст
      ActionText:=StringReplace(ActionText,'\n','<br>',[rfReplaceAll]);
      SetLength(wattrs, acount);
      if (StrToInt(FirmID)=isWe) then begin
         Price:=Stream.ReadDouble;     // ц-на
      end
      else begin
        k:=0; SetLength(Wares[i].arPrices,Length(arPriceColNames));
        while (k<Length(arPriceColNames)) do begin
          Wares[i].arPrices[k]:=Stream.ReadDouble;
          Inc(k);
        end;
      end;
      for ii:=0 to acount-1 do begin
        wattrs[ii]:=Stream.ReadStr;
      end;
    end;
  end;
  ss:=ss+'<div><table id=comparetable class="st" style="font-size: 12px; table-layout: fixed; width: '+IntToStr(j*350+140)+'px;">';
  ss:=ss+'<tr class=headerrow>';
  ss:=ss+'<td style="width: 150px;">&nbsp;</td>';
  for i:=0 to j-1 do begin
    ss:=ss+'<td><b>'+Wares[i].Name+'</b>';
    if Wares[i].DirectName='auto' then
      ss:=ss+'&nbsp;<img title="Товар автонаправления" align=top src="'+DescrImageUrl+'/images/'+Wares[i].DirectName+'G-32x16.png">';
    if Wares[i].DirectName='moto' then
      ss:=ss+'&nbsp;<img title="Товар мотонаправления" align=top src="'+DescrImageUrl+'/images/'+Wares[i].DirectName+'G-32x16.png">';
    if Wares[i].DirectName='motul' then
      ss:=ss+'&nbsp;<img title="Товар направления Motul" align=top src="'+DescrImageUrl+'/images/'+Wares[i].DirectName+'G-32x16.png">';
    if Wares[i].IsSale then
      ss:=ss+'&nbsp;<img title="" align=top src="'+DescrImageUrl+'/images/sal.png">';
    if Wares[i].CutPrice then
      ss:=ss+'&nbsp;<img title="Уцененный товар" align=top src="'+DescrImageUrl+'/images/catprice.png">';
    if Wares[i].NonReturn then
      ss:=ss+'&nbsp;<img title="Возврату не подлежит" align=top src="'+DescrImageUrl+'/images/denyback.png">';
    if (FirmId<>IntToStr(isWe)) then begin
      if Wares[i].ActionCode>0 then
        ss:=ss+'&nbsp;<a target="_blank" class="abANewAction" title="'+Wares[i].ActionTitle+'\n'+Wares[i].ActionText+'" style="background-image: url('+DescrImageUrl+'/images/action16.png);" href="'+ScriptName+'/info?actioncode='+IntToStr(Wares[i].ActionCode)+'"></a>';
    end;
    ss:=ss+'</td>';
  end;
  ss:=ss+'</tr>';

  ss:=ss+'<tr>';
  ss:=ss+'<td style="width: 150px;">&nbsp;</td>';
  for i:=0 to j-1 do begin
    ss:=ss+'<td style="position: relative; vertical-align: top;"><div style="position: relative;">';
    if FileExists(DescrDir+'\wareimages\'+IntToStr(Wares[i].Code)+'.jpg') then begin
            //prMessageLOG(DescrImageUrl+'/wareimages/'+IntToStr(Wares[i].Code)+'.jpg'+'!!!!!!!!!!!!!!!!!!!');
            //ss:=ss+'<a target=_blank href="'+DescrUrl+'/wareinfo?id='+IntToStr(Wares[i].Code)+'"><img src="'+fnGetThumb(DescrDir+'\wareimages\'+IntToStr(Wares[i].Code)+'.jpg', 100, 100)+'"></a>';
          //ss:=ss+'<a target=_blank href="'+Request.ScriptName+'/wareinfo?id='+IntToStr(Wares[i].Code)+'"><img src="'+fnGetThumb(DescrImageUrl+'/wareimages/'+IntToStr(Wares[i].Code)+'.jpg', 100, 100)+'"></a>';
      ss:=ss+'<a target=_blank href="'+ScriptName+'/wareinfo?id='+IntToStr(Wares[i].Code)+'"><img src="'+DescrImageUrl+'/wareimages/'+IntToStr(Wares[i].Code)+'.jpg'+'" style=" max-height: 100px;max-width: 100px;"></a>';
    end else begin
          ss:=ss+'&nbsp';
        end;
    ss:=ss+'<a class="abANew rm'+IntToStr(Wares[i].Code)+'" href="#" style="background-image: url(/images/tr.gif); top: 0px; right: 0px; cursor: default;" title=""></a>';
    ss:=ss+'<a class="abANew toorder" href="#" style="width: 70px; background-position: 0px 0px; background-image: url(/images/tr.gif); top: 0px; right: 16px;" onmouseover="$(this).css(\''background-position\'',\''-100% 0\'');"'+
          ' onmouseup="$(this).css(\''background-position\'',\''0 0\''); "'+
          ' onmousedown="$(this).css(\''background-position\'',\''-200% 0\'');" ';
          //ss:=ss+'onmouseout="$(this).css(\''background-position\'',\''0 0\'');" onclick=\'' ec("linefromsearchtoorder", "ordr="+$("#addlines", top.document).attr("value")+"&warecode='+IntToStr(Wares[i].Code)+'&wareqty='+FloatToStr(Wares[i].divis)+'&inline=false&contract='+IntToStr(ContractId)+'");\''></a>';
    ss:=ss+'onmouseout="$(this).css(\''background-position\'',\''0 0\'');" onclick=\'' call_linefromsearchtoorder('+IntToStr(Wares[i].Code)+','+FloatToStr(Wares[i].divis)+','+IntToStr(ContractId)+'); \''></a>';
    ss:=ss+'</div></td>';
  end;
  ss:=ss+'</tr>';

  ss:=ss+'<tr>';
  ss:=ss+'<td style="width: 150px;">Производитель: </td>';
  for i:=0 to j-1 do begin
    if (Wares[i].BrandNameWWW='-') then begin
       ss:=ss+'<td>'+Wares[i].BrandName+'</td>';
    end else begin
       ss:=ss+'<td><a target=_blank href="http://www.vladislav.ua/assortiment.php?brand='+Wares[i].BrandNameWWW+'">'+Wares[i].BrandName+'</a></td>';
    end;

  end;
  ss:=ss+'</tr>';
  if (StrToInt(FirmID)=isWe) then begin
    ss:=ss+'<tr>';
    ss:=ss+'<td>'+arPriceColNames[0].ColName+', '+CurrName+': </td>';
    for i:=0 to j-1 do begin
      ss:=ss+'<td>'+FormatFloat('# ##0.00', Wares[i].Price) +'</td>';
    end;
    ss:=ss+'</tr>';
  end
  else begin
    k:=0;
    while (k<Length(arPriceColNames)) do begin
       ss:=ss+'<tr>';
       ss:=ss+'<td style="width: 150px;">'+arPriceColNames[k].ColName+', '+CurrName+': </td>';
       for i:=0 to j-1 do begin
         ss:=ss+'<td>'+FormatFloat('# ##0.00', Wares[i].arPrices[k]) +'</td>';
       end;
       ss:=ss+'</tr>';
       Inc(k);
    end;
  end;
        {              колонки, если сменное к-во не заработает - вернуть
          ss:=ss+'<tr>';
          ss:=ss+'<td>Цена(розн.), '+CurrName+': </td>';
          for i:=0 to j-1 do begin
            ss:=ss+'<td>'+FormatFloat('# ##0.00', Wares[i].Price) +'</td>';
          end;
          ss:=ss+'</tr>';

          if (StrToInt(FirmID)<>isWe) then begin
            ss:=ss+'<td>Цена(вход.), '+CurrName+': </td>';
            for i:=0 to j-1 do begin
              ss:=ss+'<td>'+FormatFloat('# ##0.00', Wares[i].PriceC) +'</td>';
            end;
            ss:=ss+'</tr>';
          end; }

  for ii:=0 to acount-1 do begin
    ss:=ss+'<tr>';
    ss:=ss+'<td style="width: `150px;">'+attrs[ii]+': </td>';
    for i:=0 to j-1 do begin
      ss:=ss+'<td>'+Wares[i].wattrs[ii]+'</td>';
    end;
    ss:=ss+'</tr>';
  end;

  ss:=ss+'<tr>';
  ss:=ss+'<td style="vertical-align: top;width: 200px;">Описание : </td>';
  for i:=0 to j-1 do begin
    ss:=ss+'<td style="vertical-align: top; text-align: left; white-space: normal;">';

    if FileExists(DescrDir+'\waredescr\'+IntToStr(Wares[i].Code)+'.html') then begin
      List:=TStringList.Create;
      List.LoadFromFile(DescrDir+'\waredescr\'+IntToStr(Wares[i].Code)+'.html');
      sss:=StringReplace(List.Text, #13, ' ', [rfReplaceAll]);
      FreeAndNil(List);
      sss:=fnCodeBracketsForWeb(sss);
      ss:=ss+GetHTMLSafeString(StringReplace(sss, #10, ' ', [rfReplaceAll]));
      ss:=fnDeCodeBracketsInWeb(ss);

    end else begin
          ss:=ss+Wares[i].Comment;
        end;

    ss:=ss+'</td>';
  end;
  ss:=ss+'</tr>';
  ss:=ss+'</table></div>';

  //s:=s+'sw('''+ss+''', false);'#13#10;
  s:=s+'jqswInfo('''','''+ss+''',''top'');'#13#10;
  if Copy(Waress, 1, 1)=',' then Waress:=Copy(Waress, 2, length(Waress));
  Count:=Stream.ReadInt;
  for i:=0 to Count-1 do begin
    Code:=Stream.ReadInt;
    Qty:=Stream.ReadInt;
    s:=s+'$(''.rm'+IntToStr(Code)+''').css(''background-image'', ''url('+fnIfStr(FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/restmark'+IntToStr(Qty)+'.png)'');'#13#10;
    s:=s+'$(''.rm'+IntToStr(Code)+'[title=""]'').attr(''title'', '''+fnIfStr(Qty=0, 'Нет в наличии', 'Есть в наличии')+''');'#13#10;
  end;
  //else
  //  s:=s+'ec(''getrestsofwares'', ''warecodes='+Waress+'&contract='+IntToStr(ContractId)+''');'#13#10;

  s:=s+'if ($(''#addlines'', top.document).length) {'#13#10;
  s:=s+'  if ($(''#addlines'', top.document).attr(''value'')) {'#13#10;
  s:=s+'    $(''.toorder'').css(''background-image'', ''url(/images/orderbtn.png)'');'#13#10;
  //s:=s+'    $(''.toorder'').css(''background-image'', ''url(/images/wdown.png)'');'#13#10;
  //s:=s+'    $(''.toorder'').attr(''title'', ''Добавить в текущий заказ'');'#13#10;
  s:=s+'  } else {'#13#10;
  s:=s+'    $(''.toorder'').css(''background-image'', ''url(/images/orderbtn.png)'');'#13#10;
  //s:=s+'    $(''.toorder'').attr(''title'', ''Добавить в новый заказ'');'#13#10;
  s:=s+'  }'#13#10;
  s:=s+'} else $(''.toorder'').css(''display'', ''none'');'#13#10;

  s:=s+'zebratable("#comparetable");'#13#10;
  s:=s+' setActionTooltip();'#13#10;

  Result:=s;
end; //fnShowWareCompare

function fnLoadAccountList(Stream: TBoBMemoryStream; filterselectedfirm:String): string;
var
  s, s1, temp: string;
  InvBlocked, InvProcessed, InvAnnulated, InvExecuted: boolean;
  i,Count: integer;
  Date, DateBegin, DateEnd: TDateTime;
  ShortFilter: boolean;
begin
  s:='';
  s:=s+'$("#contract").val(0);'#13#10;
  s:=s+'tbl=$("#tablecontent")[0];'#13#10;
  s:=s+'while (tbl.rows.length) tbl.deleteRow(0);'#13#10;
  s:=s+'$("#tablecontent").css("table-layout", "auto");'#13#10;
  Count:=Stream.ReadInt;
  for i:=0 to Count-1 do begin
(*
        Stream.WriteInt(fid);                                        // код к/а
        Stream.WriteStr(Cache.arFirmInfo[fid].Name);                 // наименование к/а
        Stream.WriteDouble(GBIBS.FieldByName('PInvSumm').AsFloat);
        Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('PInvCrncCode').AsInteger));
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger); // метод отгрузки
        Stream.WriteDouble(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDate);       // дата отгрузки
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger);   // время отгрузки
        Stream.WriteStr(GBIBS.FieldByName('uslsusername').AsString);            // создатель счета
        Stream.WriteStr(GBIBS.FieldByname('PINVCLIENTCOMMENT').AsString);
*)

    InvBlocked:=Stream.ReadBool;
    s1:=IntToStr(Stream.ReadInt); // код счета
    InvProcessed:=Stream.ReadBool;
    InvAnnulated:=Stream.ReadBool;
    InvExecuted:=Stream.ReadBool;

    s:=s+'addpayinvoicerow('+s1+', '+BOBBoolToStr(InvBlocked)+', '+BOBBoolToStr(InvProcessed)+', '+BOBBoolToStr(InvAnnulated)+', '+BOBBoolToStr(InvExecuted)+', '+BOBBoolToStr(not Stream.ReadBool);
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // номер счета
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // дата счета
    s:=s+', '+IntToStr(Stream.ReadInt); // код фирмы
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // название фирмы
    s:=s+', '+IntToStr(Stream.ReadInt); // код контракта
    s:=s+', '+BoBBoolToStr(Stream.ReadBool); // is moto
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // номер контракта
    s:=s+', '+IntToStr(Stream.ReadInt); // код склада
    s:=s+', "'+FormatFloat('# ##0.00', Stream.ReadDouble)+'"'; // сумма
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // валюта
    s:=s+', '+IntToStr(Stream.ReadInt); // _deliverytype
    Date:=Stream.ReadDouble;
    s:=s+', "'+fnIfStr(fnNotZero(Date), FormatDateTime('dd.mm.yy', Date), '')+'"'; // _deliverydate
    s:=s+', '+IntToStr(Stream.ReadInt); // _deliverytime
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // _operator
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // _comment
    s:=s+', "'+GetJSSafeStringArg(Stream.ReadStr)+'"'; // _commentclient
    s:=s+');'#13#10;
  end;
  if (ShortFilter) then begin
    s:=s+'var s="";'#13#10; //
    s:=s+'for (i=0; (i<firms.length) && !s; i++) { if (firms[i].value=='+filterselectedfirm+') s=firms[i].label;}'#13#10; //
    s:=s+'if (s) {'#13#10; //
    s:=s+'  $("#filterselectedfirm").val("'+filterselectedfirm+'");'#13#10; //
    s:=s+'  $("#filterfirm").attr("oldval", s);'#13#10; //
    s:=s+'  $("#filterfirm").val(s);'#13#10; //
    s:=s+'};'#13#10; //
  end;
  s:=s+'$("#createaccountbtn").attr("disabled", '+BoBBoolToStr(StrToIntDef(filterselectedfirm, -1)=-1)+');'#13#10; //
  s:=s+'zebratable(tbl);'#13#10;
  s:=s+'$("#showinvoicelistbtn").val("Обновить информацию");'#13#10;
  s:=s+'$("#mainheaderwrap").css("height", "'+IntToStr(constPayInvoiceFilterHeader)+'px");'#13#10;
  s:=s+'$("#invoiceheaderdiv").css("display", "none");'#13#10;
  s:=s+'set_sizes(3);'#13#10;
  s:=s+'synqcols1();'#13#10;

   Result:=s;
end;// fnLoadAccountList

function fnWebArmGetTransInvoicesList(Stream: TBoBMemoryStream): string;
var
  s, s1: string;
  invcode, invnum, invdate, invfrom, invto, invshipmethod, invshipdate, invshiptime, invcomment, invstatus: string;
  i, Count: integer;
begin
  s:='';
  s1:='';
  s:=s+'$("#transferinvforacc").empty();'#13#10;
  Stream.ReadDouble; // пока пропускаю дату, решил ее не обрабатывать
  Count:=Stream.ReadInt;
  for I:=0 to Count-1 do begin
    invcode:=IntToStr(Stream.ReadInt);
    invnum:=Stream.ReadStr;
    invdate:=FormatDateTime(cDateFormatY4, Stream.ReadDouble);
    invfrom:=IntToStr(Stream.ReadInt);
    invto:=IntToStr(Stream.ReadInt);
    invshipmethod:=IntToStr(Stream.ReadInt);
    invshipdate:=BoBFormatDateTime(cDateFormatY4, Stream.ReadDouble);
    invshiptime:=IntToStr(Stream.ReadInt);
    invcomment:=GetHTMLSafeString(Stream.ReadStr);
    invstatus:=GetHTMLSafeString(Stream.ReadStr);
    s:=s+'addtransferinvforacc('
        +invcode+', ' // код накладной
        +'"'+invnum+'", ' //номер накладной
        +'"'+invdate+'", ' //дата
        +''+invfrom+', ' // код склада Out
        +''+invto+', ' // код склада In
        +''+invshipmethod+', ' // код способа отгрузки
        +'"'+invshipdate+'", ' // дата отгрузки
        +''+invshiptime+', ' //  код времени отгрузки
        +'"'+invcomment+'", ' // комментарий
        +'"'+invstatus+'" ' // статус
        +');'#13#10;
  end;

  s:=s+'if ($("#transferinvforaccdiv").dialog("isOpen")) {tinvsizetune(null, null)} else {$("#transferinvforaccdiv").dialog("open")};'#13#10;

  Result:=s;
end; // prWebArmGetTransInvoicesList

function fnCreateSubAcc(Stream: TBoBMemoryStream;id:String): string;
var
  s: string;
  i: integer;
begin
  i:=Stream.ReadInt;
  s:=s+'if (confirm("Создан счет №'+Stream.ReadStr+'. Перейти к этому счету?")) {'#13#10;
  s:=s+'  loadpayinvoice(-1, '+IntToStr(i)+');'#13#10;
  s:=s+'} else {'#13#10;
  s:=s+'  loadpayinvoice(-1, '+id+');'#13#10;
  s:=s+'}'#13#10;
  Result:=s;
end; // fnCreateSubAcc

function fnDelLineFromInvoice(Stream: TBoBMemoryStream;wareid: String;linecode:String): string;
var
  s: string;
begin
  s:='';
  s:=s+'var tbl=$("#tablecontent")[0];'#13#10;
  s:=s+'$("#invoiceprocessed")[0].checked='+fnIfStr(Stream.ReadBool, 'true', 'false')+';'#13#10;
  s:=s+'$("#invoicesumm").html("'+Stream.ReadStr+'");'#13#10;
  s:=s+'var row=$("#invrow_'+linecode+'")[0];'#13#10;
  s:=s+'tbl.deleteRow(row.rowIndex);'#13#10;

  s:=s+'zebratable(tbl);'#13#10;
  s:=s+'set_sizes();'#13#10;
  s:=s+'if ($("#warecodeforinvoice").val()=='+wareid+') checkwareqty('+wareid+', this.parentNode);'#13#10;
  Result:=s;

end;// fnDelLineFromInvoice

function fnSendWareList(var userInf:TEmplInfo; Stream: TBoBMemoryStream; var Wares: string; ErrMessKind: integer; suffix: string=''): string;
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
  // принимаем товары
  ShowAnalogs:=Stream.ReadBool;
  j:=Stream.ReadInt;
  for i:=0 to j-1 do begin
    s:=s+fnGetWareForSearch(Stream, -100, 'WSRtablecontent', WareCode, AnalogCount, Wares, userInf.FirmId=IntToStr(isWe));
    if ShowAnalogs then begin  //если нужно показывать аналоги сразу и они есть, то показываем
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

function fngetTimeListSelfDelivery(Stream: TBoBMemoryStream;OldTime: String): string;  //Получение список времен по дате для самовывоза
var
  s, stemp, name,bkcolor: string;
  i, j, code: integer;
begin
  s:='';
  s:=s+'var list=$("#pickuptimespan select[name^=''pickuptime'']")[0];'#13#10;  //переменная списка
  s:=s+'list.options.length=0;'#13#10;
  s:=s+'var j=0;'#13#10;//взяли элементы списка
  j := Stream.ReadInt; //количесво элементов списка времен
  //s:=s+'list.options[j++]= new Option('''', -1, false, false);'#13#10;
  bkcolor:='#FFFFFF';     //опрелделяем цвет фона для списка времени
  for i := 1 to j do begin
    code:=Stream.ReadInt;
//prTestLog(IntToStr(code));
    name:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
    s:=s+'list.options[j++]= new Option('''+name+''', '+IntToStr(ABS(code))+', false, false);'#13#10;
    if code<0 then begin
       bkcolor:='#FF0000';
       s:=s+'list.options[j-1].style.backgroundColor="#FF0000";'#13#10;
    end
  end;
  s:=s+'list.value='+OldTime+';'#13#10;
  s:=s+'list.style.backgroundColor="'+bkcolor+'";'#13#10;
  Result:=s;
end;  // getTimeListSelfDelivery

function fngetContractDestPointsList(Stream: TBoBMemoryStream;id: String;value: String;isEmpty: String): string;  //Получение список торговых точек
var
  s, stemp, DestName,DestAdr,id_select: string;
  i, j, DestID: integer;
begin
  s:='';
  s:=s+'var list=$("#'+id+'")[0];'#13#10;  //обнуление списка
  s:=s+'list.options.length=0;'#13#10;
  s:=s+'var j=0;'#13#10;
  j := Stream.ReadInt; //количесво элементов списка тт
  if (value='0') and (isEmpty='1') then
    s:=s+'list.options[j++]= new Option('''',0, false, false);'#13#10;
    for i := 1 to j do begin
      DestID:=Stream.ReadInt;
      //Ini.WriteString('log','str',IntToStr(DestID));
      DestName:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
      DestAdr:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
      s:=s+'list.options[j++]= new Option('''+DestName+' - '+DestAdr+''','+IntToStr(DestID)+', false, false);'#13#10;
    end;
   //Ini.Free;
   //if fnGetField(Request, 'value')='0' then
    s:=s+'list.value='+value+';'#13#10;
  Result:=s;
end;  // getContractDestPointsList

function fnfillParametrsAllWebArm(Stream: TBoBMemoryStream): string;   //вызывается для заполнения всех данных окна заказа при его открытии
var
  s,DestName,DestAdr,name,deliverydate,SelfCommentary: string;
  v,DestID,code,paymenttype,code_date: integer;
  d_date,w_date:double;
//  Ini: Tinifile;
begin
  s:='';
  s:=s+'$("#sendordermark").val(''1''); '#13#10;
  v:=Stream.ReadInt;
  s:=s+' $("#getting'+IntToStr(v)+'").prop(''checked'', true);  '#13#10;
  s:=s+' $("#getting'+IntToStr(v)+'").trigger(''change''); '#13#10;
  s:=s+'var list=$("#fillheaderbeforeprocessingdiv select[name^=''tt'']")[0];'#13#10;  //обнуление списка
  s:=s+'list.options.length=0;'#13#10;
  DestID:=Stream.ReadInt;
  s:=s+'ec(''getcontractdestpointslist'',''value='+IntToStr(DestID)+'&forfirmid=''+$("#forfirmid").val()+''&contractid=''+$("#contract").val()+''&id=_ttorderselect&isEmpty=0'', ''abj'');'#13#10;
  DestName:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
  DestAdr:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
//s:=s+'list.options[0]= new Option('''+DestName+','+DestAdr+''','+IntToStr(DestID)+', false, false);'#13#10;
  d_date:=Stream.ReadDouble ;
  if fnNotZero(d_date) then begin
     code_date:=Trunc(d_date);
     s:=s+' $("#deliverydatetext").val('''+FormatDateTime('dd.mm.yy',d_date)+''');'#13#10;
     s:=s+'list=$("#fillheaderbeforeprocessingdiv select[name^=''deliverydate'']")[0];'#13#10;  //переменная списка
     s:=s+'list.options.length=0;'#13#10;
     s:=s+'list.options[0]= new Option('''+FormatDateTime('dd.mm.yy', d_date)+''', '+IntToStr(ABS(code_date))+', false, false);'#13#10;
     s:=s+'ec("getDateListSelfDelivery","Olddate='+IntToStr(code_date)+'&contractid="+$("#contract").val()+"&forfirmid="+$("#forfirmid").val(),"abj"); '#13#10;
  end
  else begin
    s:=s+'ec("getDateListSelfDelivery","Olddate=0&contractid="+$("#contract").val()+"&forfirmid="+$("#forfirmid").val(),"abj"); '#13#10;
  end;        s:=s+' $("#shedulercode").val('''+IntToStr(Stream.ReadInt)+''');'#13#10;
  if v=0 then
    s:=s+' $("#deliverykind").text('''+Stream.ReadStr+''');'#13#10
  else
    Stream.ReadStr;
  s:=s+'list=$("#pickuptimespan select[name^=''pickuptime'']")[0];'#13#10;  //переменная списка
  s:=s+'list.options.length=0;'#13#10;
  code:=Stream.ReadInt;
  name:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
  s:=s+'list.options[0]= new Option('''+name+''', '+IntToStr(ABS(code))+', false, false);'#13#10;
  if v=0 then begin
    s:=s+' $("#deliverytimeout").text('''+name+''');'#13#10;
    s:=s+' $("#deliverytimein").text('''+Stream.ReadStr+''');'#13#10;
  end
  else
    Stream.ReadStr;
    //s:=s+' var btn = document.getElementById(''showdeliveriesbtn'');'#13#10;
    //s:=s+' var tt = $("#fillheaderbeforeprocessingdiv [name^=''tt'']").val();'#13#10;
    //s:=s+' var dd = $("#fillheaderbeforeprocessingdiv select[name^=''deliverydate''] ").text();'#13#10;
    //s:=s+' if(tt!=0 && dd!=''''){if (btn.disabled){btn.disabled = false;}}    '#13#10;
    s:=s+''#13#10;
    Result:=s;
end;  // fnfillParametrsFromOrder

function fnsaveParametrsFromWebArm(Stream: TBoBMemoryStream;v:integer; deliverydatetext:String; deliverydate: String): string;   //вызывается для сохранения данных окна заказа
var
  s: string;
begin
  s:='';
  case v of
    0:begin
       s:=s+'var deliverytimeout=$("#deliverytimeout").text();'#13#10;
       s:=s+'var deliverytimein=$("#deliverytimein").text();'#13#10;
       s:=s+'var deliverykind=$("#deliverykind").text();'#13#10;
       s:=s+'var str1=''Отгрузка: '+deliverydatetext+''';       '#13#10;
       s:=s+'var tt=$("#_ttorderselect :selected").text(); '#13#10;
       s:=s+'if ((deliverytimeout!='''') && (str1 !=''Отгрузка: '')) {str1+='' , '';} '#13#10;
       s:=s+'if ( (deliverykind !='''') && ((deliverytimeout!='''') || (str1 !=''Отгрузка: '')) ) {deliverytimeout+='' , '';} '#13#10;
       s:=s+'if ( (tt !='''') && ((deliverytimeout!='''') || (str1 !=''Отгрузка: '') || (deliverykind !='''')) ) {deliverykind+='' , '';}                                   '#13#10;
       s:=s+'if ((deliverytimein !='''') && ((deliverytimeout!='''') || (str1 !=''Отгрузка: '') || (deliverykind !='''') || (tt !='''')) )  {deliverytimein='', План. приб. ''+deliverytimein;} '#13#10;
       s:=s+' else{ if (deliverytimein !='''')  {deliverytimein=''План. приб. ''+deliverytimein;} }'#13#10;

       s:=s+'$(''#orderdeliverydata'').text(str1+deliverytimeout+deliverykind+tt+deliverytimein);'#13#10;
      end;
    1:begin
       s:=s+'$(''#orderdeliverydata'').text(''Резервирование'');'#13#10;
      end;
    2:begin
       s:=s+'var deliverytime=$("#pickuptimespan select[name^=''pickuptime''] :selected").text();        ;'#13#10;
       s:=s+'var str1=''Отгрузка: '+deliverydatetext+''';       '#13#10;
       s:=s+'var str2=''Самовывоз''      '#13#10;
       s:=s+'if ((deliverytime !='''') && (str1 !=''Отгрузка: '')) {str1+='' , '';deliverytime+='' , '';} '#13#10;
       s:=s+'if ($("#btim_toprocessingbonus").length){ '#13#10;
       s:=s+'$("#orderdeliverydataBonus").text(str1+deliverytime+str2); '#13#10;
       s:=s+'}'#13#10;
       s:=s+'else {'#13#10;
       s:=s+'$(''#orderdeliverydata'').text(str1+deliverytime+str2);'#13#10;
       s:=s+' }'#13#10;
      end;
   end;
   s:=s+'$("#invoicedeliverydate").attr("oldval", "'+FormatDateTime('dd.mm.yy',StrToFloatDef(deliverydate,0))+'");'#13#10;
   s:=s+'$("#invoicedeliverydate").val("'+FormatDateTime('dd.mm.yy',StrToFloatDef(deliverydate,0))+'");'#13#10;
   s:=s+' $(''#fillheaderbeforeprocessingdiv'').dialog(''close'');'#13#10;
   s:=s+''#13#10;
   Result:=s;

end;  // fnsaveParametrsFromOrder

function fnFillDeliverySheduler(Stream: TBoBMemoryStream;_tt:String;_deliverydate:String): string;   //вызывается для заполнения окна расписаний
var
  s,kindDelivery,timeOut,shedulercode,oldShedulercode,deliveryTime: string;
  i,j: integer;
  IsHide,choicedRow: Boolean; //прятать ли колонки
begin
  s:='';
  j := Stream.ReadInt; //количесво элементов списка
  IsHide:=Stream.ReadBool;
  if j<>0 then begin
    s:=s+' $(''#datetimediv'').attr(''tt'', "'+_tt+'");'#13#10;
    s:=s+' $(''#deliveryshedulerdiv'').attr(''deliverydate'', "'+_deliverydate+'");'#13#10;
    s:=s+'var tbl=$("#deliveryshedulerdiv_table");'#13#10;
    s:=s+'tbl.empty();'#13#10;
    s:=s+'tbl=tbl[0];'#13#10;
    s:=s+'var row;'#13#10;
    s:=s+'var newcell;'#13#10;
    //доставка отгузхка прибытие
    s:=s+'row=tbl.insertRow(0);'#13#10;
    s:=s+'row.className="grayline";'#13#10;
    s:=s+'newcell=row.insertCell(0);'#13#10;
    s:=s+'newcell.style.textAlign="center";'#13#10;
    s:=s+'newcell.style.visibility=''hidden'';'#13#10;
    s:=s+'newcell.innerHTML="'+'Код'+'";'#13#10;
    s:=s+'newcell=row.insertCell(1);'#13#10;
    s:=s+'newcell.style.textAlign="center";'#13#10;
    s:=s+'newcell.innerHTML="'+'Время отгрузки со склада'+'";'#13#10;
    s:=s+'newcell=row.insertCell(2);'#13#10;
    s:=s+'newcell.style.textAlign="center";'#13#10;
    s:=s+'newcell.innerHTML="'+'Способ доставки'+'";'#13#10;
    s:=s+'newcell=row.insertCell(3);'#13#10;
    s:=s+'newcell.style.textAlign="center";'#13#10;
    s:=s+'newcell.innerHTML="'+'Планируемое прибытие'+'";'#13#10;
    for i := 1 to j do begin
      shedulercode:=IntToStr(Stream.ReadInt);
      kindDelivery:=GetJSSafeString(Stream.ReadStr);
      timeOut:=Stream.ReadStr;
      deliveryTime:=Stream.ReadStr;
      choicedRow:=Stream.ReadBool;
      s:=s+'row=tbl.insertRow('+IntToStr(i)+');'#13#10;
      if IsHide then  begin
        s:=s+'$("#deliveryshedulerdiv_caption").css(''display'', ''block'');'#13#10;
        s:=s+'$("#deliverysheduler_viewall").css(''display'', ''block'');'#13#10;
        if not choicedRow then
          s:=s+'row.style.display=''none'';'#13#10;
        end
      else begin
        s:=s+'$("#deliveryshedulerdiv_caption").css(''display'', ''none'');'#13#10;
        s:=s+'$("#deliverysheduler_viewall").css(''display'', ''none'');'#13#10;
      end;
      if (i mod 2)=0 then
        s:=s+'row.className="lblchoice";'#13#10
      else
        s:=s+'row.className="lblchoice altrow";'#13#10;
      s:=s+'row.onclick=fillDelivetyField;'#13#10;
      //s:=s+'row.style.visibility=''hidden'';'#13#10;
      s:=s+'newcell=row.insertCell(0);'#13#10;
      s:=s+'newcell.style.textAlign="center";'#13#10;
      s:=s+'newcell.style.visibility=''hidden'';'#13#10;
      s:=s+'newcell.innerHTML="'+shedulercode+'";'#13#10;
      s:=s+'newcell=row.insertCell(1);'#13#10;
      if oldShedulercode=shedulercode then
        s:=s+'newcell.style.cssText="font-weight:bold";'#13#10;
      s:=s+'newcell.style.textAlign="center";'#13#10;
      s:=s+'newcell.innerHTML="'+timeOut+'";'#13#10;
      s:=s+'newcell=row.insertCell(2);'#13#10;
      if oldShedulercode=shedulercode then
        s:=s+'newcell.style.cssText="font-weight:bold";'#13#10;
      s:=s+'newcell.style.textAlign="center";'#13#10;
      s:=s+'newcell.innerHTML="'+kindDelivery+'";'#13#10;
      s:=s+'newcell=row.insertCell(3);'#13#10;
      if oldShedulercode=shedulercode then
        s:=s+'newcell.style.cssText="font-weight:bold";'#13#10;
      s:=s+'newcell.style.textAlign="center";'#13#10;
      s:=s+'newcell.innerHTML="'+deliveryTime+'";'#13#10;
    end;

    s:=s+'$(''#deliveryshedulerdiv'').dialog(''open'');'#13#10;
    s:=s+''#13#10;
    s:=s+''#13#10;
  end
  else begin
    s:=s+'jqswMessageError(''На выбранную дату доступных расписаний нет.'');'#13#10;
  end;

  Result:=s;
end;  // fnFillDeliverySheduler


function fngetDateListSelfDelivery(Stream: TBoBMemoryStream;flag:boolean;Olddate:String) : String;  //Получение список дат для окна доставки
var
  s, stemp, name,bkcolor: string;
  i, j, code,d: integer;
begin
  s:='';
  s:=s+'var list=$("#fillheaderbeforeprocessingdiv select[name^=''deliverydate'']")[0];'#13#10;  //переменная списка
  s:=s+'list.options.length=0;'#13#10;
  s:=s+'var j=0;'#13#10;//взяли элементы списка
  j := Stream.ReadInt; //количесво элементов списка времен
  //s:=s+'list.options[j++]= new Option('''', -1, false, false);'#13#10;
  bkcolor:='#FFFFFF';     //опрелделяем цвет фона для списка времени
  for i := 1 to j do begin
    code:=Stream.ReadInt;
    if d=code then
      flag:=false;
    name:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
    s:=s+'list.options[j++]= new Option('''+name+''', '+IntToStr(ABS(code))+', false, false);'#13#10;
    if code<0 then begin
      bkcolor:='#FF0000';
      s:=s+'list.options[j-1].style.backgroundColor="#FF0000";'#13#10;
    end
  end;
  s:=s+'list.value='+Olddate+';'#13#10;
  s:=s+'list.style.backgroundColor="'+bkcolor+'";'#13#10;
  if flag then begin
    s:=s+' $(''#deliverykind'').empty(); $(''#deliverytimeout'').empty(); $(''#deliverytimein'').empty();$(''#shedulercode'').val(''0'');  ';
  end;
  s:=s+'fillHelpDesk();'#13#10;
  //s:=s+'var v=$("#fillheaderbeforeprocessingdiv input[name^=''typeofgetting'']:checked").val(); '#13#10;
  //s:=s+' if (v==1) {ec("checkorderwarerests", "shipdate=0&ordr="+document.getElementById("addlines").value+"&deliverykind="+v) } '#13#10;
  //s:=s+' else {ec("checkorderwarerests", "shipdate="+tt.substring(0,10)+"&ordr="+document.getElementById(''addlines'').value+"&deliverykind="+v); }'#13#10;
  s:=s+'checkWareOnStorage(); '#13#10;
  s:=s+' var deliverydate=$("#fillheaderbeforeprocessingdiv select[name^=''deliverydate''] option:selected").text(); '#13#10;
  s:=s+' if (deliverydate!=''''){ ec("gettimelistselfdelivery","date="+deliverydate.substring(0,10)+"&OldTime="+$("#pickuptimespan select[name^=''pickuptime'']").val()+"&contract="+$("#contract").val()+"&forfirmid="+$("#forfirmid").val(),"abj");} '#13#10;
  Result:=s;
end;  // getTimeListSelfDelivery

function fnGetAttrListSelected(Stream: TBoBMemoryStream;selectname:String): String; // получить список  по выбранным атрибутам
var
  s,  s2,s1,s3: string;
  i, j, Count, Count1, atttype: integer;
begin
  s:='';
  Count:=Stream.ReadInt;
  if Count>0 then begin
    s:=s+'var sel;';
    for i:=0 to Count-1 do begin
      s3:=IntToStr(Stream.ReadInt);
      Count1:=Stream.ReadInt;
      s:=s+'sel=$("select[name=''attr'+s3+''']");'#13#10;
      if (selectname<>('attr'+s3)) then begin
        s:=s+'sel.empty();'#13#10;
       //if StrToInt(s3)<=cGBattDelta then
        //s:=s+' sel.change(function(){LoadAtrrBySelect(this,'+fnGetField(Request, 'groupid')+'); });'#13#10
       //else
       //s:=s+' sel.change(function(){LoadAtrrBySelect(this,'+fnGetField(Request, 'groupid')+'); });'#13#10;
        s:=s+'sel.append($(''<option value=0>Все</option>''));'#13#10;
      end;
      if Count1>0 then begin
        for j:=0 to Count1-1 do begin
          s1:=IntToStr(Stream.ReadInt);
          s2:=GetJSSafeString(Stream.ReadStr);
          if (selectname<>('attr'+s3)) then begin
            if FileExists(DescrDir+'/images/lampbases/'+s2+'.png') then
              s:=s+'sel.append($(''<option imgval_=1 value='+s1+'>'+s2+'</option>''));'#13#10
            else
              s:=s+'sel.append($(''<option imgval_=0 value='+s1+'>'+s2+'</option>''));'#13#10;
          end;
        end ;
        s:=s+'if (sel.attr(''selectval_'') != '''') { $("select[name=''attr'+s3+'''] [value="+sel.attr(''selectval_'')+"]").attr("selected", "selected"); }'#13#10;
      end
      else
        s:=s+'sel.attr(''selectval_'','''');'#13#10;
    end;
  end;
  Result:=s;
end;  //fnGetAttrListSelected

function fnFillAttrListSelected(Stream: TBoBMemoryStream;selectname:String): String; // получить все списки и заполнить их заново
var
  s,  s2,s1,s3: string;
  i, j, Count, Count1, atttype: integer;
begin
  s:='';
  Count:=Stream.ReadInt;
  if Count>0 then begin
    s:=s+'var sel;';
    for i:=0 to Count-1 do begin
      s3:=IntToStr(Stream.ReadInt);
      Count1:=Stream.ReadInt;
      s:=s+'sel=$("select[name=''attr'+s3+''']");'#13#10;
      s:=s+'sel.empty();'#13#10;
      s:=s+'sel.append($(''<option value=0>Все</option>''));'#13#10;
      if Count1>0 then begin
        for j:=0 to Count1-1 do begin
          s1:=IntToStr(Stream.ReadInt);
          s2:=GetJSSafeString(Stream.ReadStr);
          if (selectname<>('attr'+s3)) then begin
            if FileExists(DescrDir+'/images/lampbases/'+s2+'.png') then
              s:=s+'sel.append($(''<option imgval_=1 value='+s1+'>'+s2+'</option>''));'#13#10
            else
              s:=s+'sel.append($(''<option imgval_=0 value='+s1+'>'+s2+'</option>''));'#13#10;
          end;
        end ;
      end;
      s:=s+'sel.attr(''selectval_'','''');'#13#10;
    end;
  end;
  Result:=s;
end;  //fnFillAttrListSelected

function fnGetAttrList(Stream: TBoBMemoryStream;id:String): string;
var
  s, s1, s2,curAttrCode: string;
  i, j, Count, Count1, atttype: integer;
begin
  s:='';
  s:=s+'tbl=$("#motoattrtable");'#13#10;
  s:=s+'tbl.empty();'#13#10;
  s:=s+'tbl=tbl[0];'#13#10;
  s:=s+'var row;'#13#10;
  s:=s+'var newcell;'#13#10;
  //csGetFilteredGBGroupAttValues
  Count:=Stream.ReadInt;
  for i:=0 to Count-1 do begin
    curAttrCode:=IntToStr(Stream.ReadInt);
    s2:=GetJSSafeString(Stream.ReadStr);
    atttype:=Stream.ReadByte;
    Count1:=Stream.ReadInt;
    s:=s+'row=tbl.insertRow(-1);'#13#10;
    s:=s+'newcell=row.insertCell(-1);'#13#10;
    s:=s+'newcell.style.textAlign="right";'#13#10;
    s:=s+'newcell.innerHTML="'+s2+'";'#13#10;

    s:=s+'newcell=row.insertCell(-1);'#13#10;
    if StrToInt(curAttrCode)<=cGBattDelta then  // не забыть убрать
      s:=s+'newcell.innerHTML="<select  name=attr'+curAttrCode+' selectval_='''' id=''attr'+curAttrCode+''' style=''text-align: '+
         fnIfStr(atttype in [constInteger,constDouble], 'right', 'left')+';''><option value=0>Все</option>'
    else
      s:=s+'newcell.innerHTML="<select onchange=''LoadAtrrBySelect(this,'+id+');'' name=attr'+curAttrCode+' id=''attr'+curAttrCode+''' selectval_='''' style=''text-align: '+
         fnIfStr(atttype in [constInteger,constDouble], 'right', 'left')+';''><option  value=0> Все</option>';
      for j:=0 to Count1-1 do begin
        s1:=IntToStr(Stream.ReadInt);
        s2:=GetJSSafeString(Stream.ReadStr);
        if FileExists(DescrDir+'/images/lampbases/'+StringReplace(s2, '/', '_', [rfReplaceAll])+'.png') then
          //s:=s+'<option class=''tooltip''  imgval_=1 value='+s1+'>'+s2+'</option>'
          s:=s+'<option imgval_=1 value='+s1+'>'+StringReplace(s2, '/', '_',[rfReplaceAll])+'</option>'
        else
          s:=s+'<option imgval_=0 value='+s1+'>'+s2+'</option>';
         //s:=s+'<option value='+s1+'><img style=''width: 16px;'' src=''http://order15.vladislav.ua/images/lampbases/HB4.png''>'+s2+'</option>';
         //s:=s+'list.options[j++]= new Option('''+s2+''', '+s1+', false, false);'#13#10;
         //s:=s+'list.append( $(''<option value='+s1+'><img src=''http://order.vladislav.ua/images/lampbases/HB4.png'' style=''height: 16px;''>'+s2+'</option>''));'#13#10;
      end;
      s:=s+'</select>";'#13#10;
      //if curAttrCode='10002' then   begin
      //  if flShowAttrImage then
      //    s:=s+'setImageInAttrSelect('+curAttrCode+');'#13#10;
     // end;

  end;
  s:=s+'row=tbl.insertRow(-1);'#13#10;
  s:=s+'newcell=row.insertCell(-1);'#13#10;
  s:=s+'newcell.colSpan=2;'#13#10;
  s:=s+'newcell.style.textAlign="left";'#13#10;

  s1:='<button onClick=''selbyattr();'' class=\"ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only\" '+
  'onMouseOver=\"$(this).attr(''class'', ''ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-hover'');\"'+
  'onMouseOut=\"$(this).attr(''class'', ''ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'');\"'+
  'type=''button'' role=''button'' aria-disabled=''false'' id=''podborbtn''>'+
  '<span class=''ui-button-text'' style=''padding: 0.2em 1em;''>Подобрать</span></button>';
  s:=s+'newcell.innerHTML="'+s1+'"'#13#10;

  s:=s+'row=tbl.insertRow(-1);'#13#10;
  s:=s+'newcell=row.insertCell(-1);'#13#10;
  s:=s+'newcell.colSpan=2;'#13#10;
  s:=s+'newcell.style.textAlign="left";'#13#10;

  if StrToInt(curAttrCode)>cGBattDelta  then  begin
    s1:='<button onClick=''LoadAtrrAll('+id+');'' class=\"ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only\" '+
        'onMouseOver=\"$(this).attr(''class'', ''ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-hover'');\"'+
        'onMouseOut=\"$(this).attr(''class'', ''ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'');\"'+
        ' type=''button'' role=''button'' aria-disabled=''false'' id=''clearallbtn''>'+
        '<span class=''ui-button-text'' style=''padding: 0.2em 1em;''>Сброс</span></button>';
    s:=s+'newcell.innerHTML="'+s1+'"'#13#10;
  end;

   //     s:=s+'newcell.innerHTML="<input id=''podborbtn'' type=button value=''Подобрать'' onclick=selbyattr();>";'#13#10;
//        s:=s+'zebratable("#motoattrtable");'#13#10;
//        s:=s+'showselectdiv("selmotobyattrdiv");'#13#10;
//        s:=s+'showseldiv("selmotobyattrdiv", "selbyattrmotoobj");'#13#10;
  s:=s+'setpodborsubdiv(-1, 1);';
        //s:=s+'$("#selmotobyattridgroup").val("'+fnGetField(Request, 'id')+'");';
        //s:=s+'<script type="text/javascript"> '#13#10;
        //s:=s+'$(document).ready(function() {'#13#10+OnReadyScript+'});'#13#10;
        //s:=s+'</script>'#13#10;

//        s:=s+'podborwinresize();';
  Result:=s;

end; //fnGetAttrList


function fnGetWaresByAttr(var userInf:TEmplInfo;Stream: TBoBMemoryStream ): string;
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

function fnGetNodeWares(Stream:TBoBMemoryStream; var userInf:TEmplInfo;ScriptName:String): string;
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
  if (Stream.ReadBool) then begin//    // есть ли вообще смысл рисовать кнопки удаления
    s:=s+'var NodeWithModel="&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'";'#13#10;
  end else begin
    s:=s+'var NodeWithModel="";'#13#10;
  end;
  s:=s+'searchmodelcode="'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'";'#13#10;

  NodeName:=Stream.ReadStr;
  filter:=Stream.ReadStr;
  s:=s+'$("#WSRwrapper h1").html("Результаты подбора товара по узлу <span id=''modelnodesearch_node'' _code='''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'''>'+GetHTMLSafeString(NodeName)+'</span> '+
       fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'двигателя', 'модели')+' <a id=''modelnodesearch_engine''  _code='''+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'true', 'false')+''' '+
       'href=# onclick=''showmodtree('+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+s2+');''><span id=''modelnodesearch_model'' _code='''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'''>'+s1+'</span></a>'+
       fnIfStr(filter='', '', ' с фильтром по месту установки <a href=# onclick=''ec(\"showfilter\", \"model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&pref='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')+'\", \"newbj\");''><span id=''#modelnodesearch_filter'' _code='''+trim(fnGetFieldStrList(userInf.strPost,userinf.strGet,'filter'))+'''>'+filter+'</span></a>')+
       '")'#13#10;
  s:=s+fnSendWareList(userInf,Stream, Wares, fnIfInt(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', constWrongEngineNode, constWrongModelNode), '&model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&eng='+fnIfStr(fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')='sel_auen', 'true', 'false')+'&filter='+filter);
  // теперь получаем допданные по товарам
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
    if (userInf.FirmID=IntToStr(isWe)) and (userInf.strCookie.Values['one_line_mode']<>'true') and (fnInIntArray(rolOPRSK, userInf.Roles)>-1) and (StrToIntDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'forfirmid'),0)>0) then begin
      s:=s+'descrdiv=$(".applic'+s1+'");'#13#10;
      s:=s+'if (descrdiv.length) {'#13#10;
      s:=s+'  descrdiv.html(''<hr><b>Применимость: </b>'+StringReplace(temp, '&amp;nbsp;', ' ', [rfReplaceAll])+''');'#13#10;
      s:=s+'}'#13#10;
      s2:=s2+'isWA: 1};'#13#10;
    end
    else
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


function fnShowFilter(Stream: TBoBMemoryStream; var userInf:TEmplInfo): string;
var
  s, s1, s2, temp: string;
  Count: integer;
begin
 s:='';
 s1:='';
 s1:=s1+'<div id=warenodefilter>';
 s1:=s1+'<h1 class=grayline>'+GetHTMLSafeString(Stream.ReadStr)+'</h1>';
 Count:=Stream.ReadInt;
 while (Count>0) do begin
   s2:=IntToStr(Stream.ReadInt);
   temp:=Stream.ReadStr;
   temp:=GetHTMLSafeString(temp, false);
   temp:=fnDeCodeBracketsInWeb(temp);
   s1:=s1+'<input id=filval_'+s2+' type=checkbox value='+s2+'>'+temp+'<br />';
   Dec(Count);
 end;
 s1:=s1+'<center><input id=warenodefilterall type=button value=''Все''>&nbsp;&nbsp;&nbsp;<input id=warenodefilterok type=button value=''Ок''></center>';
 s1:=s1+'</div>';
 s:=s+'$(''#warenodefilterdialog'').html("'+s1+'"); ';
 s:=s+'$(''#warenodefilterdialog'').dialog(''open''); ';
 //s:=s+'$("#warenodefilterdialog").html("'+s1+'");';
 //s:=s+'sw("'+s1+'");'#13#10;

 s:=s+'  $(''#warenodefilterall'').bind(''click'', function(event) {'#13#10;
 s:=s+'    $(''#warenodefilter :checkbox'').attr(''checked'', ''true'');'#13#10;
 s:=s+'  });'#13#10;

 s:=s+'  $(''#warenodefilterok'').bind(''click'', function(event) {'#13#10;
 s:=s+'    if (!$(''#warenodefilter :checkbox:checked'').length) {jqswMessage(''Вы должны задать хотя бы одно значение.''); return false;}'#13#10;
 s:=s+'      var s='''';'#13#10;
 s:=s+'    $(''#warenodefilter :checkbox:checked'').each(function(index) {'#13#10;
 s:=s+'      if (s) s+='','';'#13#10;
 s:=s+'      s+=$(this)[0].id.substr('+IntToStr(Length('filval_'))+');'#13#10;
 s:=s+'    });'#13#10;
//        s:=s+'    alert(s);'#13#10;
 s:=s+'    ec(''getnodewares'', ''model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+'&node='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+'&pref='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'pref')+fnIfStr(userInf.FirmID=IntToStr(isWe), '&forfirmid=''+$(''#forfirmid'').val()+''', '')+'&contract='+IntToStr(userInf.ContractId)+'&filter=''+s, ''newbj'');'#13#10;
 s:=s+'  });'#13#10;
 Result:=s;
end; // fnShowFilter

function fnLoadModelTree(Stream: TBoBMemoryStream; var userInf:TEmplInfo;pref:String): string;
var
  s, un, modelname: string;
  i, j, Command: integer;
  HasQty, DrawFilter: boolean;
  Qty: Double;
begin
   modelname:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);

   s:=s+'var curnode=null;'#13#10;
   s:=s+'$("#'+pref+'_ul_0").empty();'#13#10;
   j:=Stream.ReadInt-1;
   for i:=0  to j do begin
     s:=s+'addbranchsel('+IntToStr(Stream.ReadInt)+', '+IntToStr(Stream.ReadInt)+', "'+Stream.ReadStr;
     HasQty:=Stream.ReadBool;
     Qty:=0;
     DrawFilter:=false;
     if HasQty then begin
       Qty:=Stream.ReadDouble;
       un:=Stream.ReadStr;
       DrawFilter:=Stream.ReadBool;
     end;
     if fnNotZero(Qty) then begin
       s:=s+'", "'+StringReplace(FormatFloat('#0.##', Qty), '-', '~', [])+' '+un+'", "'+pref+'", '+fnIfStr(DrawFilter, 'true', 'false')+');'#13#10;
     end else begin
       s:=s+'", "", "'+pref+'", '+fnIfStr(DrawFilter, 'true', 'false')+');'#13#10;
     end;
   end;

   s:=s+'curmotomodelname="'+modelname+'";'#13#10;
   s:=s+'$($("#'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'objdiv')+'")[0].parentNode).attr("modelcode", "'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'");'#13#10;
// yазначаю функции сворачивания/разворачивания узлов
   s:=s+'$(''a[id^="'+pref+'_a1_"]'').each(function(index) {'#13#10;
   s:=s+'  var num=parseInt($(this)[0].id.substr('+IntToStr(4+length(pref))+'));'#13#10;
   s:=s+'  if ($(''#'+pref+'_ul_''+num)[0]) {'#13#10;
   s:=s+'  $(this).html(''&#9658;'');'#13#10;
   s:=s+'  $(this).bind(''click'', function(event) {;'#13#10;
   s:=s+'    UnHide(this);'#13#10;
   s:=s+'  });'#13#10;
   s:=s+'  }'#13#10;
   s:=s+'});'#13#10;

   s:=s+'  $(''a[id^="'+pref+'_a2_"]'').bind(''click'', function(event) {'#13#10;
   s:=s+'    var num=parseInt($(this)[0].id.substr('+IntToStr(4+length(pref))+'));'#13#10;
   s:=s+'    $(''#'+pref+'_a1_''+num).click();'#13#10;
   s:=s+'  });'#13#10;

//           назначаю функцию для перехода к списку товаров
   s:=s+'$(''a[id^="'+pref+'_a2_"]'').each(function(index) {'#13#10;
   s:=s+'  $(this).bind(''dblclick'', function(event) {'#13#10;
   s:=s+'    curmotonodename=this.innerHTML;'#13#10;
   s:=s+'    curmotonodecode=$(this)[0].id.substr('+IntToStr(length(pref+'_a2_'))+');'#13#10;
   s:=s+'    var contractel=$("#contract");'#13#10;
   s:=s+'    ec(''getnodewares'', ''model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'&node=''+$(this)[0].id.substr('+IntToStr(4+length(pref))
       +')+''&pref='+pref+fnIfStr(userInf.FirmID=IntToStr(isWe), '&forfirmid=''+$(''#forfirmid'').val()+''', '')
       +'&contract=''+((contractel.length)?contractel.val():""), ''newbj'');'#13#10;
   s:=s+'  });'#13#10;
   s:=s+'});'#13#10;

//           назначаю функцию для перехода к списку товаров для стрелочек (для мобильных устройств)
   s:=s+'$(''img[id^="'+pref+'_selimg_"]'').each(function(index) {'#13#10;
   s:=s+'  $(this).bind(''click'', function(event) {'#13#10;
   s:=s+'    var code=$(this).attr(''code'');'#13#10;
   s:=s+'    curmotonodename=$(''a#'+pref+'_a2_''+code).html();'#13#10;
   s:=s+'    curmotonodecode=code;'#13#10;
   s:=s+'    ec(''getnodewares'', ''model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'&node=''+code+''&pref='+pref+'&contract='+IntToStr(userInf.ContractId)+''', ''abj'');'#13#10;
   s:=s+'  });'#13#10;
   s:=s+'});'#13#10;

//           назначаю функцию для вызова фильтра
   s:=s+'$(''img[id^="'+pref+'_filimg_"]'').each(function(index) {'#13#10;
   s:=s+'  $(this).bind(''click'', function(event) {;'#13#10;
   s:=s+'    var code=$(this).attr(''code'');'#13#10;
   s:=s+'    curmotonodename=$(''a#'+pref+'_a2_''+code).html();'#13#10;
   s:=s+'    curmotonodecode=code;'#13#10;
   s:=s+'    ec(''showfilter'', ''model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'&node=''+$(this)[0].id.substr('+IntToStr(length(pref+'_filimg_'))+')+''&pref='+pref+fnIfStr(userInf.FirmID=IntToStr(isWe), '&forfirmid=''+$(''#forfirmid'').val()', '''')+', ''abj'');'#13#10;
   s:=s+'  });'#13#10;
   s:=s+'});'#13#10;

   if (fnGetFieldStrList(userInf.strPost,userinf.strGet,'objdiv')='selbymodeltreediv') then begin
//          s:=s+'showseldiv(''selbymodeltreediv'', ''selbymodelmotoobj'');'#13#10;  //
     s:=s+'$("#podbortabs").tabs("select", parseInt($("#selectbymodelmotodiv").attr("tabnumber")));'#13#10;  //
     s:=s+'$(''#motmodeltreeheader'').html(''Модель - <a href=# ><b>'+modelname+'</b></a>, Двойной клик по узлу - переход к отображению товаров'');'#13#10;  //
   end else
   if (fnGetFieldStrList(userInf.strPost,userinf.strGet,'objdiv')='selbymodeltreedivauto') then begin
//          s:=s+'showseldiv(''selbymodeltreedivauto'', ''selbymodelautoobj'');'#13#10;  //
     s:=s+'$("#podbortabs").tabs("select", parseInt($("#selectbymodelautodiv").attr("tabnumber")));'#13#10;  //
     s:=s+'$(''#automodeltreeheader'').html(''Модель - <a href=# onclick="ec(\''loadmodeldatatext\'', \''model='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'\'', \''abj\'');"><b>'+modelname+'</b></a>, Двойной клик по узлу - переход к отображению товаров'');'#13#10;  //
   end else
   if (fnGetFieldStrList(userInf.strPost,userinf.strGet,'objdiv')='selbymodeltreedivautoengine') then begin
//          s:=s+'showseldiv(''selbymodeltreedivautoengine'', ''selbymodelauenobj'');'#13#10;  //
      s:=s+'$("#podbortabs").tabs("select", parseInt($("#selectbyengineautodiv").attr("tabnumber")));'#13#10;  //
      s:=s+'$(''#auenmodeltreeheader'').html(''Двигатель - <a href=# onclick="ec(\''showengineoptions\'', \''engineid='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'\'', \''abj\'');"><b>'+modelname+'</b></a>, Двойной клик по узлу - переход к отображению товаров'');'#13#10;  //
   end;

   s:=s+'$("#podbortabs").dialog("open");'#13#10;
   s:=s+'setpodborsubdiv(1, 1);'#13#10;
   s:=s+'$.fancybox.close();'#13#10;

   Result:=s;
end; // fnLoadModelTree


function fnShareWareinfoAction(Stream: TBoBMemoryStream; var userInf:TEmplInfo;DescrImageUrl:String; ScriptName:String) :String;     //процедура общая для двух цги с целью открытия инфы об найденной товаре
var
  Qv,s, s1,resStr, Comment, Error, Brand, BrandWWW, BrandAdrWWW, Folder, Divis, CondContent, imgpath, tdimgpath, sss, WareName: string;
  List: TStringList;
  i, j, Count, tdimgcount: integer;
  Sale, CutPrice, NonReturn: boolean;
  DirectName,ActionTitle,ActionText:string;
  Path: string;
  listFindFileNames: TStringList;
  Attr,curWidth,curHeight,curMargLeft,curMargTop,Code,Qty,ActionCode: Integer;
  F: TSearchRec;
  jpg:TJpegImage;
  imgWidth  : Array of Integer;   //  для расчета отступа для маленьких картинок
  imgHeight  : Array of Integer; //
begin
 DirectName:='';
 resStr:=resStr+'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/strict.dtd">'#13#10;
 resStr:=resStr+'<html>'#13#10;
 resStr:=resStr+'<head>'#13#10;
 resStr:=resStr+'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">'#13#10;
 resStr:=resStr+'<meta http-equiv="Content-Language" content="ru">'#13#10;
 resStr:=resStr+'<meta http-equiv="Cache-Control" content="no-cache">'#13#10;
 resStr:=resStr+'<meta http-equiv="Pragma" content="no-cache">'#13#10;
 if (userInf.FirmID<>IntToStr(isWe)) then
   resStr:=resStr+'<script type="text/javascript" language=JavaScript src="/fancybox/slides.js"></script>'#13#10
 else
   resStr:=resStr+'<script type="text/javascript" language=JavaScript src="/slides.js"></script>'#13#10;

        //resStr:=resStr+'<link rel="stylesheet" type="text/css" href="/fancybox/slides.css" media="screen" >'#13#10;
 if (fnGetFieldStrList(userInf.strPost,userinf.strGet,'win')='') then  begin   //использование окна как jquery диалог
   resStr:=resStr+'<script type="text/javascript" language=JavaScript src="/cookies.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
   resStr:=resStr+'<script type="text/javascript" language=JavaScript src="/fancybox/jquery-1.8.3.min.js"></script>'#13#10;
   resStr:=resStr+'<script type="text/javascript" src="/fancybox/jquery.fancybox.js?v=2.0.5"></script>'#13#10;
   resStr:=resStr+'<link rel="stylesheet" type="text/css" href="/fancybox/jquery.fancybox.css?v=2.0.5" media="screen" >'#13#10;
   if (userInf.FirmID<>IntToStr(isWe)) then  begin
     resStr:=resStr+'<link rel="stylesheet" type="text/css" href="/orders.css?v='+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
     resStr:=resStr+'<link rel="stylesheet" type="text/css" href="'+DescrImageUrl+'/common.css?v='+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
     resStr:=resStr+'<script type="text/javascript" language=JavaScript src="'+DescrImageUrl+'/common.js?v='+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
     resStr:=resStr+'<script type="text/javascript" language=JavaScript src="/orders.js?v='+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
   end;
   resStr:=resStr+'<script type="text/javascript">'#13#10;
   resStr:=resStr+'  page=''wareinfo'';'#13#10;
   resStr:=resStr+'  scriptname="'+ScriptName+'";'#13#10;
   resStr:=resStr+'</script>'#13#10;
   resStr:=resStr+'</head>'#13#10;
   resStr:=resStr+'<body class=iframebody>'#13#10;
 end;
 resStr:=resStr+'<div id=wareinfodivWrap style="position: relative; padding: 10px; font-size: 14px;">';
 resStr:=resStr+'<div id=wareinfodiv style="width: 100%;">';
 WareName:=Stream.ReadStr;
 Sale:=Stream.ReadBool;
 NonReturn:=Stream.ReadBool;
 CutPrice:=Stream.ReadBool;
 ActionCode:=Stream.ReadInt;         // код акции
 ActionTitle:=Stream.ReadStr  +' <br> ';      // заголовок
 ActionText:=Stream.ReadStr;       // текст
 ActionText:=StringReplace(ActionText,'\n','<br>',[rfReplaceAll]);
 DirectName:=LowerCase(Stream.ReadStr);    //название направления для скидок
 prOnReadyScriptAdd('$("#ui-dialog-title-viewsearchingwarediv ")[0].innerHTML=''Описание товара'';'#13#10);
 prOnReadyScriptAdd(' $(''ui-dialog-title-viewsearchingwarediv'').attr(''_oldcodeproduct'', '''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+''');'#13#10);
 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=false) then begin
   prOnReadyScriptAdd(' var inp = document.createElement(''span''); inp.innerHTML="&nbsp;'+GetJSSafeStringArg(WareName)+'&nbsp;"; ');
   prOnReadyScriptAdd(' var imgDirect = document.createElement(''img''); ');
   prOnReadyScriptAdd(' $(imgDirect).css(''position'',''relative'').css(''top'', ''3px''); ');
   if DirectName='auto' then begin
     prOnReadyScriptAdd(' imgDirect.src="'+DescrImageUrl+'/images/'+DirectName+'G-32x16.png"; ');
     prOnReadyScriptAdd(' imgDirect.title=''Товар автонаправления''; ');
   end;
   if DirectName='moto' then begin
     prOnReadyScriptAdd(' imgDirect.src="'+DescrImageUrl+'/images/'+DirectName+'G-32x16.png"; ');
     prOnReadyScriptAdd(' imgDirect.title=''Товар мотонаправления''; ');
   end;
   if DirectName='motul' then begin
     prOnReadyScriptAdd(' imgDirect.src="'+DescrImageUrl+'/images/'+DirectName+'G-32x16.png"; ');
     prOnReadyScriptAdd(' imgDirect.title=''Товар мотонаправления Motul''; ');
   end;
 end
 else begin
   prOnReadyScriptAdd(' var inp = document.createElement(''span''); inp.innerHTML="&nbsp;"; ');
 end;
 prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(inp); ');


 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=false) then
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(imgDirect); ');
 if (Sale) then begin
   prOnReadyScriptAdd(' var imgSale = document.createElement(''img''); ');
   prOnReadyScriptAdd(' imgSale.title=''Распродажа''; ');
   prOnReadyScriptAdd(' imgSale.src="'+DescrImageUrl+'/images/sal.png"; ');
   prOnReadyScriptAdd(' $(imgSale).css(''position'',''relative'').css(''top'', ''3px''); ');
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(imgSale); ');
 end;
 if (CutPrice) then begin
   prOnReadyScriptAdd(' var imgPrice = document.createElement(''img''); ');
   prOnReadyScriptAdd(' $(imgPrice).css(''position'',''relative'').css(''top'', ''3px''); ');
   prOnReadyScriptAdd(' imgPrice.src="'+DescrImageUrl+'/images/catprice.png"; ');
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(imgPrice); ');
 end;
 if (NonReturn) then begin
   prOnReadyScriptAdd(' var imgReturn = document.createElement(''img''); ');
   prOnReadyScriptAdd(' imgReturn.title=''Возврату не подлежит''; ');
   prOnReadyScriptAdd(' $(imgReturn).css(''position'',''relative'').css(''top'', ''3px''); ');
   prOnReadyScriptAdd(' imgReturn.src="'+DescrImageUrl+'/images/denyback.png"; ');
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(imgReturn); ');
 end;
 if (ActionCode>0) then begin
   prOnReadyScriptAdd(' var imgAction = document.createElement(''a''); ');
   prOnReadyScriptAdd(' imgAction.title='''+ActionTitle+'\n'+ActionText+'''; ');
   if (userInf.FirmID<>IntToStr(isWe)) then
     prOnReadyScriptAdd(' imgAction.href="'+ScriptName+'/info?actioncode='+IntToStr(ActionCode)+'"; ')
   else
     prOnReadyScriptAdd(' imgAction.href="#"; ');
   prOnReadyScriptAdd(' imgAction.target=''_blank''; ');
   prOnReadyScriptAdd(' imgAction.className="tooltip"; ');
   prOnReadyScriptAdd(' imgAction.className="abANewAction"; ');
   prOnReadyScriptAdd(' imgAction.setAttribute(''id'',''abANewAction'');  ');
   prOnReadyScriptAdd(' $(imgAction).css(''background-image'',''url(/images/action16.png)''); ');
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(imgAction); ');
 end;

 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=false) then begin
   prOnReadyScriptAdd(' var aNewPassive = document.createElement(''a''); ');
   prOnReadyScriptAdd(' aNewPassive.href=''#''; ');
   prOnReadyScriptAdd(' aNewPassive.className="abANew_passive rm'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'";  ');
   prOnReadyScriptAdd(' $(aNewPassive).css(''position'',''absolute'').css(''right'', ''48px'').css(''top'', ''8px''); ');
   prOnReadyScriptAdd(' $(aNewPassive).css(''background-image'',''url(/images/tr.gif)''); ');
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(aNewPassive); ');
   prOnReadyScriptAdd(' var aNew = document.createElement(''a''); ');
   prOnReadyScriptAdd(' aNew.href=''#''; ');
   prOnReadyScriptAdd(' aNew.className="abANew";  ');
   prOnReadyScriptAdd(' aNew.setAttribute(''id'',''toorder'');  ');
   prOnReadyScriptAdd(' $(aNew).css(''position'',''absolute'').css(''right'', ''29px'').css(''top'', ''8px'').css(''width'', ''70px''); ');
   prOnReadyScriptAdd(' $(aNew).css(''background-position'',''0px 0px'').css(''background-image'', ''29px'').css(''top'', ''8px'').css(''width'', ''70px''); ');
   prOnReadyScriptAdd(' $(aNewPassive).css(''background-image'',''url(/images/tr.gif)''); ');
   prOnReadyScriptAdd(' $("#ui-dialog-title-viewsearchingwarediv ")[0].appendChild(aNew); ');
   prOnReadyScriptAdd(' $(aNew).mousedown(function(){ $(this).css(''background-position'',''-200% 0''); }).mouseup(function(){$(this).css(''background-position'',''0 0''); });');
   prOnReadyScriptAdd(' $(aNew).mouseover(function(){ $(this).css(''background-position'',''-100% 0''); }).mouseout(function(){$(this).css(''background-position'',''0 0'');  });');
 end;
   {
        resStr:=resStr+'<h1 class="grayline" style="margin: 0px;">Описание товара "'+WareName+fnIfStr(Sale, '&nbsp;<img align=top title=''Распродажа'' src=''/images/sal.png''>', '')+'"';
        if DirectName='auto' then
          resStr:=resStr+'&nbsp;<img title=''Товар автонаправления'' align=top src="'+DescrImageUrl+'/images/'+DirectName+'G-32x16.png">';
        if DirectName='moto' then
          resStr:=resStr+'&nbsp;<img title=''Товар мотонаправления'' align=top src="'+DescrImageUrl+'/images/'+DirectName+'G-32x16.png">';
        if DirectName='motul' then
          resStr:=resStr+'&nbsp;<img title=''Товар направления Motul'' align=top src="'+DescrImageUrl+'/images/'+DirectName+'G-32x16.png">';
        if (CutPrice) then resStr:=resStr+'&nbsp;<img align=top src="/images/catprice.png">';
        if (NonReturn) then resStr:=resStr+'&nbsp;<img title="Возврату не подлежит" align=top src="/images/denyback.png">';
          resStr:=resStr+'<a class="abANew_passive rm'+fnGetField(Request, 'id')+'" href="#" style="background-image: url(/images/tr.gif);"  title=""></a>';
          resStr:=resStr+'<a class="abANew" id=toorder href="#" style="background-image: url(/images/tr.gif); position: static; float: right;"></a>';
        resStr:=resStr+'</h1>';
        }
 prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').attr(''_oldcodeproduct'', '''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+''');'#13#10);
 prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').attr(''_node'', '''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'node')+''');'#13#10);     //заполняем атрибуты для идентификации окна
 prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').attr(''_model'', '''+fnGetFieldStrList(userInf.strPost,userinf.strGet,'model')+''');'#13#10);
        //prOnReadyScriptAdd(' if ( ($(''#viewsearchingwarediv'').height()>$(window).height()) || ($(''#viewsearchingwarediv'').parent().height()>$(window).height())) {'#13#10);  //подстраиваем окно под высота экрана
        //prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').dialog(''option'', ''position'', ''top''); '#13#10);
        //prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').dialog({ height: $(window).height() }); '#13#10);
        //prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').dialog(''option'', ''position'', ''center''); '#13#10);
        //prOnReadyScriptAdd(' }'#13#10);
        //rOnReadyScriptAdd(' else{ $(''#viewsearchingwarediv'').dialog({ height: ''auto''}); '#13#10);
        //prOnReadyScriptAdd(' $(''#viewsearchingwarediv'').dialog(''option'', ''position'', ''center'');} '#13#10);
 resStr:=resStr+'<div id="container"> <div id="slides">';
 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=true) then  begin
   resStr:=resStr+'<img id=waremainimg style="" src="%imgpath%" onload="this.style.maxWidth=''500px'';this.style.maxHeight=''333px'';">';
   if FileExists(DescrDir+'\wareimages\loyality_big\'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+' (2).jpg') then begin
     imgpath:=DescrImageUrl+'/wareimages/loyality_big/'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+' (2).jpg';
    end else begin
          imgpath:='/wareimages/loyality_big/no-photo (2).jpg';
        end;
 end
 else begin
    try
      jpg:=TJpegImage.Create;
      listFindFileNames:= TStringList.Create;
      Path := DescrDir+'\wareimages\'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'.*';
      Attr := faAnyFile;
      FindFirst(Path, Attr, F);
      listFindFileNames.Clear;
      i:=0;
      {Если хотя бы один файл найден, то продолжить поиск}
      if F.Name <> '' then   begin
        if (getTypeFile(DescrDir+'\wareimages\'+F.name)='JPEG') then   begin
          listFindFileNames.Add(F.name); {Добавление в TListBox имени найденного файла}
          jpg.LoadFromFile(DescrDir+'\wareimages\'+F.name);
          scaleImages(jpg,500,333);
          curWidth:=jpg.Width; curHeight:=jpg.Height;
          SetLength(imgWidth,1);
          SetLength(imgHeight,1);
          imgWidth[0]:=jpg.Width;
          imgHeight[0]:=jpg.Height;
          i:=1;
        end;
        while FindNext(F) = 0 do  begin
          if (getTypeFile(DescrDir+'\wareimages\'+F.name)='JPEG') then   begin
            listFindFileNames.Add(F.name);
            jpg.LoadFromFile(DescrDir+'\wareimages\'+F.name);
            SetLength(imgWidth,Length(imgWidth)+1);
            SetLength(imgHeight,Length(imgHeight)+1);
            scaleImages(jpg,500,333);
            imgWidth[i]:=jpg.Width;
            imgHeight[i]:=jpg.Height;
            if curWidth<jpg.Width then
              curWidth:=jpg.Width;
            if curHeight<jpg.Height then
              curHeight:=jpg.Height;
            Inc(i);
          end;
        end;
      end;

      SysUtils.FindClose(F);
      F.Name:='';
      Path := DescrDir+'\wareimages\'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'_*';
      Attr := faAnyFile;
      FindFirst(Path, Attr, F);

      {Если хотя бы один файл найден, то продолжить поиск}
      if F.Name <> '' then   begin
        if (getTypeFile(DescrDir+'\wareimages\'+F.name)='JPEG') then   begin
          listFindFileNames.Add(F.name); {Добавление в TListBox имени найденного файла}
          jpg.LoadFromFile(DescrDir+'\wareimages\'+F.name);
          scaleImages(jpg,500,333);
          curWidth:=jpg.Width; curHeight:=jpg.Height;
          SetLength(imgWidth,Length(imgWidth)+1);
          SetLength(imgHeight,Length(imgHeight)+1);
          imgWidth[i]:=jpg.Width;
          imgHeight[i]:=jpg.Height;
          i:=i+1;
        end;
        while FindNext(F) = 0 do  begin
          if (getTypeFile(DescrDir+'\wareimages\'+F.name)='JPEG') then   begin
            listFindFileNames.Add(F.name);
            jpg.LoadFromFile(DescrDir+'\wareimages\'+F.name);
            SetLength(imgWidth,Length(imgWidth)+1);
            SetLength(imgHeight,Length(imgHeight)+1);
            scaleImages(jpg,500,333);
            imgWidth[i]:=jpg.Width;
            imgHeight[i]:=jpg.Height;
            if curWidth<jpg.Width then
              curWidth:=jpg.Width;
            if curHeight<jpg.Height then
             curHeight:=jpg.Height;
            Inc(i);
          end;
        end;
      end;
      jpg.Free;
      SysUtils.FindClose(F);
      if listFindFileNames.Count>1 then begin
        i:=0;
        while(i<listFindFileNames.Count) do begin
          curMargLeft:=0;
          if  imgWidth[i]<500 then
            curMargLeft:=Round((curWidth-imgWidth[i])/2);
          curMargTop:=0;
          if  imgHeight[i]<333 then
            curMargTop:=Round((curHeight-imgHeight[i])/2);
          resStr:=resStr+'<img style="margin-left: '+IntToStr(curMargLeft)+'px; margin-top: '+IntToStr(curMargTop)+'px;" src="'+DescrImageUrl+'/wareimages/'+listFindFileNames[i]+'" onload="this.style.maxWidth='''+IntToStr(curWidth)+'px'+''';this.style.maxHeight='''+IntToStr(curHeight)+'px'+''';">';
          Inc(i);
        end;
        resStr:=resStr+'<script type="text/javascript"> $(function initSlider(){ $("#slides").slides({width: '+IntToStr(curWidth)+',height:'+IntToStr(curHeight)+'});'+
              '$("#container").width('+IntToStr(curWidth)+'); });  </script>'#13#10;
        prOnReadyScriptAdd('if ($("#slides").slides("status").total!=undefined) {$("#slides").slides("play"); }	 '#13#10);
      end
      else if listFindFileNames.Count>0 then begin
        resStr:=resStr+'<img id=waremainimg style="" src="%imgpath%" onload="this.style.maxWidth=''500px'';this.style.maxHeight=''333px'';">';
        imgpath:=DescrImageUrl+'/wareimages/'+listFindFileNames[0];
      end else begin
            resStr:=resStr+'<img id=waremainimg style="" src="%imgpath%" onload="this.style.maxWidth=''500px'';this.style.maxHeight=''333px'';">';
            imgpath:='';
          end;
      listFindFileNames.Free;
    finally
      SetLength(imgWidth,0);
      SetLength(imgHeight,0);
    end;
 end;

 resStr:=resStr+'</div></div>';
 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=false) then
     resStr:=resStr+'</br>';
 Brand:=Stream.ReadStr;
 BrandAdrWWW:=Stream.ReadStr;                                           // адрес перехода на сайт поставщика
 BrandWWW:=Stream.ReadStr;
 Divis:=FloatToStr(Stream.ReadDouble);
 Qv:=Stream.ReadStr;                                          // название бренда для лого
 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=false) then begin
   resStr:=resStr+'<div style="float: left;">';
   if (Brand='-') then begin
      resStr:=resStr+'Производитель: '+BrandWWW+'<br>';
   end else begin
        resStr:=resStr+'Производитель: <a target="_blank" href="http://www.vladislav.ua/brand/'+Brand+'">'+BrandWWW+'</a><br>';
   end;
   resStr:=resStr+'Кратность отпуска: '+Divis+' '+Qv+'<br>';
   Comment:=Stream.ReadStr;
   j:=Stream.ReadInt;
   for i:=0  to j-1 do begin
     resStr:=resStr+'<b>'+Stream.ReadStr+'</b>: <i>'+Stream.ReadStr+'</i><br>';
   end;
   resStr:=resStr+'</div>';
 end
 else begin
   resStr:=resStr+'<div class="viewdescriptiondiv">'+WareName+'<br>';
   Comment:=Stream.ReadStr;
   j:=Stream.ReadInt;
   for i:=0  to j-1 do begin
     resStr:=resStr+'<b>'+Stream.ReadStr+'</b>: <i>'+Stream.ReadStr+'</i><br>';
   end;
   resStr:=resStr+'</div>';
   resStr:=resStr+'<div class="bonusqtdiv" style=""><span id="bonusqtspan">'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'price')+' '+fnGetFieldStrList(userInf.strPost,userinf.strGet,'ballsname')+'</span>';
   if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'btnout'),false)=false) then begin
      resStr:=resStr+'<div class="bonusinputdiv" style="cursor: text;" >'+
      '<input class="bonusinput" style="z-index: 0;"  type=text size="2" id="bonuswareinfoQv'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'" onkeyup="if(event.keyCode==13){ if ($(''#bonuswareinfoQv'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+''').val()>0){ alBonus('+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+', $(''#bonuswareinfoQv'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+''').val(),'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'ordercode')+');} else {jqswMessage(''Введите количество товара'');} return false;}" onclick="event.stopPropagation(); return false; " name="bonuswareinfoQv" value="">'+
      '<span  class="bonusinputspan"> шт.</span>'+
      '<span class="bonusbtndiv"> <a class="abANewBonus" style="background-image: url(/images/orderbtn.png);"  onclick=" if ($(''#bonuswareinfoQv'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+''').val()>0){ alBonus('+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+', $(''#bonuswareinfoQv'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'d')+''').val(),'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'ordercode')+');}'+
      ' else {jqswMessage(''Введите количество товара'');}event.stopPropagation(); return false;"'+
      ' onmousedown="$(this).css(''background-position'',''-200% 0'');"'+
      ' onmouseup="$(this).css(''background-position'',''0 0'');"'+
      ' onmouseover="$(this).css(''background-position'',''-100% 0'');"'+
      ' onmouseout="$(this).css(''background-position'',''0 0'');"'+
      'href="#" title="Добавить товар в заказ"></a>'+
      '</span></div>';
   end;

   resStr:=resStr+'</div>'+
                  '</div>';
   prOnReadyScriptAdd('$("#bonuswareinfoQv'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'").val($("#'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'_1").val()); '#13#10);

 end;


 resStr:=resStr+'<div style="clear: both;">';
 sss:='';
 if FileExists(DescrDir+'\waredescr\'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'.html') then begin
   List:=TStringList.Create;
   List.LoadFromFile(DescrDir+'\waredescr\'+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'.html');
   sss:=List.Text;
   if length(sss)<6 then sss:='';
 end;

 if ((sss='') and (not CutPrice)) then begin
   sss:=Comment;
 end;

 if (CutPrice) then begin
   resStr:=resStr+'<fieldset><legend>Описание дефекта</legend>'+sss+'</fieldset>';
 end else begin
       resStr:=resStr+sss+'<br>';
     end;
 CondContent:=Stream.ReadStr;
 //resStr:=resStr+'alert('''+CondContent+'''); ';
 if (CondContent<>'') then begin
   resStr:=resStr+'<br><fieldset><legend>Особенности применения</legend>'+GetHTMLSafeString(Copy(CondContent, 1, Length(CondContent)-2))+'</fieldset>';
 end;

 if (Stream.Position<Stream.Size) then begin
   s1:=GetHTMLSafeString(Stream.ReadStr);
   if s1<>'' then begin
     resStr:=resStr+'<br><fieldset><legend>Данные</legend>'+s1+'</fieldset>';  //  TecDoc - убрано по звонку Щербакова 14.11.2014
   end;
   Count:=Stream.ReadInt;
   if (Count>-1) then begin //and not (StrToBool(fnGetField(Request, 'bonus'))=true) then begin
     resStr:=resStr+'<br><fieldset><legend>Информационные файлы</legend>';  //  TecDoc - убрано по звонку Щербакова 14.11.2014
     for i:=0 to Count do begin
//              tdimgcount:=0;
       s1:=Stream.ReadStr;
       if AnsiUpperCase(ExtractFileExt(s1))='.BMP' then begin
         s1:='vlad_'+Copy(s1, 1, Length(s1)-4)+'.jpg';
       end;
       Folder:=IntToStr(Stream.ReadInt);
       while Length(Folder)<4 do begin
         Folder:='0'+Folder;
       end;
       if (imgpath='') and not CutPrice  then begin
         sss:=Uppercase(ExtractFileExt(s1));
         if (sss='.JPG') or (sss='.GIF') or (sss='.PNG') or (sss='.TIF') then begin
              //imgpath:=BaseUrl+'/tdfiles/'+Folder+'/'+s1;
           imgpath:=DescrImageUrl+'/tdfiles/'+Folder+'/'+s1;
//                  Inc(tdimgcount);
         end;
       end;
     //resStr:=resStr+'<a target="_blank" href="'+BaseUrl+'/tdfiles/'+Folder+'/'+s1+'">'+Stream.ReadStr+'</a><br>';
       resStr:=resStr+'<a target="_blank" href="'+DescrImageUrl+'/tdfiles/'+Folder+'/'+s1+'">'+Stream.ReadStr+'</a><br>';
     end;
     resStr:=resStr+'</fieldset>';
   end;
   if (imgpath='') then begin
     imgpath:=BaseUrl+'/images/tr.gif';
   end;
//          if ((imgpath='') and (tdimgcount=1)) then begin
//            imgpath:=BaseUrl+'/tdfiles/'+tdimgpath;
//          end;
 end;
        //

 resStr:=StringReplace(resStr, '%imgpath%', imgpath, []);
 resStr:=resStr+'</div>';

 resStr:=resStr+#13#10'<script type="text/javascript"> '#13#10;

 if userInf.FirmID<>'' then begin
   Stream.ReadInt;
   Code:=Stream.ReadInt;
   Qty:=Stream.ReadInt;
   if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=false) then begin
      prOnReadyScriptAdd('$(''.rm'+IntToStr(Code)+''').css(''background-image'', ''url('+fnIfStr(userInf.FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/restmark'+IntToStr(Qty)+'.png)'');'#13#10);
      prOnReadyScriptAdd('$(''.rm'+IntToStr(Code)+'[title=""]'').attr(''title'', '''+fnIfStr(Qty=0, 'Нет в наличии', 'Есть в наличии')+''');'#13#10);
   end;
          //resStr:=resStr+'$(''.rm'+IntToStr(Code)+''').css(''background-image'', ''url('+fnIfStr(FirmID=IntToStr(isWe), DescrImageUrl, '')+'/images/restmark'+IntToStr(Qty)+'.png)'');'#13#10;
          //resStr:=resStr+'$(''.rm'+IntToStr(Code)+'[title=""]'').attr(''title'', '''+fnIfStr(Qty=0, 'Нет в наличии', 'Есть в наличии')+''');'#13#10;
 end;
 if (StrToBoolDef(fnGetFieldStrList(userInf.strPost,userinf.strGet,'bonus'),false)=true) then begin
         //prOnReadyScriptAdd('    $(''#toorder'').css(''background-image'', ''url('+DescrImageUrl+'/images/wdown.png)'');'#13#10);
         //prOnReadyScriptAdd('   $(''#toorder'').attr(''title'', ''Добавить в текущий заказ'');'#13#10);
         //prOnReadyScriptAdd('  $(''#toorder'').bind(''click'', function(event) {'#13#10);
         //prOnReadyScriptAdd('    alBonus('+fnGetField(Request, 'id')+',1,$("#btim_toprocessingbonus").attr(''_ordr''));  '#13#10);
         //prOnReadyScriptAdd('  });'#13#10);


         //resStr:=resStr+'    $(''#toorder'').css(''background-image'', ''url('+DescrImageUrl+'/images/wdown.png)'');'#13#10;
         //resStr:=resStr+'    $(''#toorder'').attr(''title'', ''Добавить в текущий заказ'');'#13#10;
         //resStr:=resStr+'  $(''#toorder'').bind(''click'', function(event) {'#13#10;
         //resStr:=resStr+'    alBonus('+fnGetField(Request, 'id')+',1,$("#btim_toprocessingbonus").attr(''_ordr''));  '#13#10;
         //resStr:=resStr+'  });'#13#10;
 end
 else
   if (userInf.FirmID<>IntToStr(isWe)) then begin
     prOnReadyScriptAdd(' if ($(''#addlines'', top.document).length) {'#13#10);
     prOnReadyScriptAdd('  if ($(''#addlines'', top.document).attr(''value'')) {'#13#10);
     prOnReadyScriptAdd('    $(''#toorder'').css(''background-image'', ''url(/images/orderbtn.png)'');'#13#10);
     prOnReadyScriptAdd('  $(''#toorder'').bind(''click'', function(event) {'#13#10);
     prOnReadyScriptAdd('    $(''#viewsearchingwarediv'').dialog(''close'');'#13#10);
     prOnReadyScriptAdd('    ec(''linefromsearchtoorder'', ''ordr=''+$(''#addlines'', top.document).attr(''value'')+''&warecode='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'&wareqty='+Divis+'&contract='+IntToStr(userInf.ContractId)+''');'#13#10);
     prOnReadyScriptAdd('  });'#13#10);
          //prOnReadyScriptAdd('    $(''#toorder'').css(''background-image'', ''url('+DescrImageUrl+'/images/wdown.png)'');'#13#10);
          //prOnReadyScriptAdd('    $(''#toorder'').attr(''title'', ''Добавить в текущий заказ'');'#13#10);
     prOnReadyScriptAdd('  } else {'#13#10);
     prOnReadyScriptAdd('  $(''#toorder'').bind(''click'', function(event) {'#13#10);
     prOnReadyScriptAdd('    $(''#viewsearchingwarediv'').dialog(''close'');'#13#10);
     prOnReadyScriptAdd('    ec(''getlistopenorders'', ''ordr=''+$(''#addlines'', top.document).attr(''value'')+''&warecode='+fnGetFieldStrList(userInf.strPost,userinf.strGet,'id')+'&wareqty='+Divis+'&contract='+IntToStr(userInf.ContractId)+'&dialogname=viewsearchingwarediv'',''newbj'');'#13#10);
     prOnReadyScriptAdd('  });'#13#10);
          //prOnReadyScriptAdd('    $(''#toorder'').css(''background-image'', ''url('+DescrImageUrl+'/images/wnew.png)'');'#13#10);
     prOnReadyScriptAdd('    $(''#toorder'').css(''background-image'', ''url(/images/orderbtn.png)'');'#13#10);
         //prOnReadyScriptAdd('    $(''#toorder'').attr(''title'', ''Добавить в новый заказ'');'#13#10);
     prOnReadyScriptAdd('  }'#13#10);
     prOnReadyScriptAdd('} else $(''#toorder'').css(''display'', ''none'');'#13#10);
          //if not flNewBtnOrder  then begin
           // prOnReadyScriptAdd('  $(''#toorder'').bind(''click'', function(event) {'#13#10);
           // prOnReadyScriptAdd('    ec(''linefromsearchtoorder'', ''ordr=''+$(''#addlines'', top.document).attr(''value'')+''&warecode='+fnGetField(Request, 'id')+'&wareqty='+Divis+'&contract='+IntToStr(ContractId)+''');'#13#10);
           // prOnReadyScriptAdd('  });'#13#10);
          //end;
          //resStr:=resStr+' if ($(''#addlines'', top.document).length) {'#13#10;
          //resStr:=resStr+'  if ($(''#addlines'', top.document).attr(''value'')) {'#13#10;
          //resStr:=resStr+'    $(''#toorder'').css(''background-image'', ''url('+DescrImageUrl+'/images/wdown.png)'');'#13#10;
          //resStr:=resStr+'    $(''#toorder'').attr(''title'', ''Добавить в текущий заказ'');'#13#10;
          //resStr:=resStr+'  } else {'#13#10;
          //resStr:=resStr+'    $(''#toorder'').css(''background-image'', ''url('+DescrImageUrl+'/images/wnew.png)'');'#13#10;
          //resStr:=resStr+'    $(''#toorder'').attr(''title'', ''Добавить в новый заказ'');'#13#10;
          //resStr:=resStr+'  }'#13#10;
          //resStr:=resStr+'  $(''#toorder'').bind(''click'', function(event) {'#13#10;
          //resStr:=resStr+'    ec(''linefromsearchtoorder'', ''ordr=''+$(''#addlines'', top.document).attr(''value'')+''&warecode='+fnGetField(Request, 'id')+'&wareqty='+Divis+'&contract='+IntToStr(ContractId)+''');'#13#10;
          //resStr:=resStr+'  });'#13#10;
          //resStr:=resStr+'} else $(''#toorder'').css(''display'', ''none'');'#13#10;
   end;
        //prOnReadyScriptAdd('setActionTooltip();#13#10');
   resStr:=resStr+'  if ($("#viewsearchingwarediv").length) {'#13#10;
   resStr:=resStr+' $(document).ready(function() {'#13#10+OnReadyScript+'});  }'#13#10;
   //resStr:=resStr+' $(''#viewsearchingwarediv'').dialog(''option'', ''position'', ''center''); '#13#10;
   resStr:=resStr+' setActionTooltip();'#13#10;
   resStr:=resStr+'</script>'#13#10;
   Result:=resStr;
end; //prShareWareinfoAction

function fnAddBrandLink(Stream: TBoBMemoryStream ): string;
var
  s: string;
begin
  s:='';
  s:=s+'var j=-1;'#13#10; //
  // ищем, куда вставить строку
  s:=s+'for (i=0; (i<$("#tablecontent")[0].rows.length) && (j==-1); i++) {'#13#10; //
  s:=s+'  if ((GBBrands[parseInt($("#gbcode").attr("value"))]<$("#tablecontent")[0].rows[i].cells[0].innerHTML) /*&&'+
                   ' (TDBrands[parseInt($("#tdcode").attr("value"))]<$("#tablecontent")[0].rows[i].cells[0].innerHTML)*/) j=(i);'#13#10; //
  s:=s+'}'#13#10; //

  s:=s+'ablr(j, '; // номер  строки
  s:=s+'$("#gbcode").attr("value"), '; //
  s:=s+'$("#tdcode").attr("value") '; //
  s:=s+');'#13#10; //
  s:=s+'zebratable($("#tablecontent")[0]);'#13#10;

  s:=s+'$.fancybox.close();'#13#10; //
  Result:=s;
end; //fnAddBrandLink


function fnWebArmGetFirmList(Stream: TBoBMemoryStream;inputid:string;templ:string): string;
var
  s: string;
  i,j:integer;
begin
  s:='';
  s:=s+'var ul_=$("#fagd ul")[0];'#13#10;
  s:=s+'ul_.innerHTML="";'#13#10;
  j := Stream.ReadInt;
  if j>0 then begin
    for i := 1 to j do begin
      s:=s+'var li = document.createElement("LI");'#13#10;
      Stream.ReadInt;
      s:=s+'li.innerHTML = "<a href=''#''>'+StringReplace(Stream.ReadStr, '"', '&quot;', [rfReplaceAll])+'</a>";'#13#10;
      s:=s+'ul_.appendChild(li);'#13#10;
    end;
    s:=s+'$("#fagd ul li a").bind(''click'', function(event) {'#13#10;
    s:=s+'  $("#firm")[0].value=this.innerHTML;'#13#10;
    s:=s+'  $("#fagd ul")[0].innerHTML="";'#13#10;
    s:=s+'  $("#fagd").css("display","none");'#13#10;
    s:=s+'});'#13#10;
    s:=s+'$("#fagd").css("display","block");'#13#10;
    s:=s+'var input=$("#'+inputid+'")[0];'#13#10;
    s:=s+'$("#fagd").css("left", $(input).offset().left);'#13#10;
    s:=s+'$("#fagd").css("top", $(input).offset().top+$(input).height()+6);'#13#10;
    s:=s+'if ($("#fagd ul").height()>250) {'#13#10;
    s:=s+'   $("#fagd").height(250);'#13#10;
    s:=s+'   $("#fagd").width($(input).width()+16);'#13#10;
    s:=s+'   $("#fagd").css("overflow-y", "scroll");'#13#10;
    s:=s+'} else {'#13#10;
    s:=s+'   $("#fagd").height($("#fagd ul").height());'#13#10;
    s:=s+'   $("#fagd").width($(input).width());'#13#10;
    s:=s+'   $("#fagd").css("overflow-y", "hidden");'#13#10;
    s:=s+'}'#13#10;
  end else begin
        s:=s+'$("#fagd").css("display","none");'#13#10;
      end;
  s:=s+'window.status="'+UTF8ToAnsi(templ)+' "+'+IntToStr(j)+'+" ";'#13#10;
  Result:=s;
end; //fnGetWaresByAttr

function fnGetRestsOfWares(Stream: TBoBMemoryStream): string;
var
  s: string;
  Count, i, Qty, Code: integer;
begin
  s:='';
  Count:=Stream.ReadInt;
  for i:=1 to Count do begin
    Code:=Stream.ReadInt;
    Qty:=Stream.ReadInt;
    s:=s+'$(''.rm'+IntToStr(Code)+''').css(''background-image'', ''url('+DescrImageUrl+'/images/restmark'+IntToStr(Qty)+'.png)'');'#13#10;
    s:=s+'$(''.rm'+IntToStr(Code)+'[title=""]'').attr(''title'', '''+fnIfStr(Qty=0, 'Нет в наличии', 'Есть в наличии')+''');'#13#10;
  end;
  Result:=s;
end; //fnGetRestsOfWares

function fnGetMPPRegOrds(Stream: TBoBMemoryStream): string;     // получить перечень заявок на регистрацию
var
  s, s1: string;
  i, j: integer;
  OREGPROCESSINGTIME, OREGCREATETIME, DateStart, DateEnd: TDateTime;
  OREGCODE, OREGDPRTCODE, OREGUSERCODE, OREGTYPE, OREGSTATE: integer;
  OREGFIRMNAME, OREGREGION, OREGMAINUSERFIO, OREGMAINUSERPOST,OREGLOGIN,
  OREGADDRESS, OREGPHONES, OREGEMAIL, OREGCOMMENT, OREGUSERNAME: string;
  OREGCLIENT: boolean;
begin
   s:='';
   s:=s+'startLoadingAnimation();'#13#10;
   s:=s+'var tbl=$("#tablecontent")[0];'#13#10;
   s:=s+'while (tbl.rows.length) tbl.deleteRow(0);'#13#10;
   s:=s+'var altrow=false;'#13#10;
   j := Stream.ReadInt;
   for i := 1 to j do begin
     OREGCODE:=Stream.ReadInt;
     OREGFIRMNAME:=GetHTMLSafeString(Stream.ReadStr);
     OREGREGION:=GetHTMLSafeString(Stream.ReadStr);
     OREGMAINUSERFIO:=GetHTMLSafeString(Stream.ReadStr);
     OREGMAINUSERPOST:=GetHTMLSafeString(Stream.ReadStr);
     OREGLOGIN:=GetHTMLSafeString(Stream.ReadStr);
     OREGCLIENT:=Stream.ReadBool;
     OREGADDRESS:=GetHTMLSafeString(Stream.ReadStr);
     OREGPHONES:=GetHTMLSafeString(Stream.ReadStr);
     OREGEMAIL:=GetHTMLSafeString(Stream.ReadStr);
     OREGTYPE:=Stream.ReadInt;
     OREGSTATE:=Stream.ReadInt;
     OREGPROCESSINGTIME:=Stream.ReadDouble;
     OREGCOMMENT:=GetHTMLSafeString(Stream.ReadStr);
     OREGDPRTCODE:=Stream.ReadInt;
     OREGUSERCODE:=Stream.ReadInt;
     OREGUSERNAME:=GetHTMLSafeString(Stream.ReadStr);
     OREGCREATETIME:=Stream.ReadDouble;

     s:=s+'addregordrow('+
       IntToStr(OREGCODE)+', '+
       ''''+OREGFIRMNAME+''', '+
       ''''+OREGREGION+''', '+
       ''''+OREGMAINUSERFIO+''', '+
       ''''+OREGMAINUSERPOST+''', '+
       ''''+OREGLOGIN+''', '+
       fnIfStr(OREGCLIENT, '1, ', '0, ')+
       ''''+trim(OREGADDRESS)+''', '+
       ''''+trim(OREGPHONES)+''', '+
       ''''+trim(OREGEMAIL)+''', '+
       IntToStr(OREGTYPE)+', '+
       IntToStr(OREGSTATE)+', '+
       ''''+FormatDateTime('dd.mm.yy', OREGPROCESSINGTIME)+''', '+
       ''''+GetHTMLSafeString(StripHTMLTags(OREGCOMMENT))+''', '+
       IntToStr(OREGDPRTCODE)+', '+
       IntToStr(OREGUSERCODE)+', '+
       ''''+OREGUSERNAME+''', '+
       ''''+FormatDateTime('dd.mm.yy', OREGCREATETIME)+''');'#13#10;
   end;
   s:=s+'synqcols();'#13#10;
   s:=s+'$(".ahint").easyTooltip();'#13#10;
   s:=s+'stopLoadingAnimation();'#13#10;
  Result:=s;
end;


function fnLoadModelList(Stream: TBoBMemoryStream;tablename:String;sys:integer): string;
var
  s, ss, divname, Name, Power, Engines, Engine: string;
  i, j, i_en,  Code, Position, CodeForMotoSite: integer;
  byear, bmonth, eyear, emonth: integer;
  EnginesList: TStringList;
begin
  s:='';
 if tablename='modeltable' then
   s:=s+'var _objdiv=""; var _treediv=""; var _pref="";'#13#10
 else
   case sys of
     constIsAuto: begin
       tablename:='modellisttableauto';
       s:=s+'var _objdiv="selbymodeltreedivauto"; var _treediv="selbymodelautoobj"; var _pref="sel_auto";'#13#10;
     end;
     constIsMoto: begin
       tablename:='modellisttable';
       s:=s+'var _objdiv="selbymodeltreediv"; var _treediv="selbymodelmotoobj"; var _pref="sel";'#13#10;
     end;
   end;
 s:=s+'var power='''';'#13#10;
 s:=s+'var engines='''';'#13#10;
 s:=s+'var tbl=$("#'+tablename+'")[0];'#13#10;
 s:=s+'$(tbl).empty();'#13#10;
 s:=s+'var altrow=false;'#13#10;
 j := Stream.ReadInt;
 for i := 1 to j do begin  //id, name, visible, top
   Power:='';
   Engines:='';
   Code:=Stream.ReadInt;
   Name:=GetJSSafeString(Stream.ReadStr);
   Position:=Pos('||', Name);
   if Position>0 then begin
     ss:=Copy(Name, Position+2, Length(Name));
     Name:=Copy(Name, 1, Position-1);
     Position:=Pos(',', ss);
     if Position>0 then begin
       Engines:=Copy(ss, Position+1, Length(ss));
       Power:=Copy(ss, 1, Position-1);
     end else
          if Pos('(', ss)>0 then begin
            Engines:=ss;
          end else begin
             Power:=ss;
          end;
   end;
   Engines:=trim(Engines);
   if Copy(Engines,1,1)='(' then begin
     Engines:=Copy(Engines, 2, Length(Engines)-2);
   end;

   if (Engines='') then Engines:='&nbsp;' else begin
     EnginesList:=fnSplit(',', Engines);
     Engines:='';
     for i_en:=0  to EnginesList.Count-1 do begin
       Engine:=trim(EnginesList[i_en]);
       Engines:=Engines+'<a href=# onclick=\"ec(''showengineoptions'', ''model='+IntToStr(Code)+'&engine='+Engine+''', ''abj'');event.stopPropagation();\">'+Engine+'</a>, ';
     end;
     Engines:=Copy(Engines, 1, Length(Engines)-2);
   end;
   if (Power='') then Power:='&nbsp;';

   case sys of
       constIsAuto: begin
         s:=s+'power='''+Power+''';'#13#10;
//       s:=s+'alert("'+Engines+'");'#13#10;
         s:=s+'engines="'+Engines+'";'#13#10;
       end;
   end;

   s:=s+'addmodelrowforselect(' + IntToStr(Code) + ', true, "' + Name + '", '+fnIfStr(Stream.ReadBool, '1', '0')+', '+fnIfStr(Stream.ReadBool, '1', '0')+', "';
   byear:=Stream.ReadInt;
   bmonth:=Stream.ReadInt;
   eyear:=Stream.ReadInt;
   emonth:=Stream.ReadInt;
   Stream.ReadInt; //пропускаем орднум
   CodeForMotoSite:=Stream.ReadInt;
   ss:=fnGetYMBE(byear, bmonth, eyear, emonth);
   ss:=StringReplace(ss, '(', '', []);
   ss:=StringReplace(ss, ')', '', []);
   ss:=StringReplace(ss, '-', '&#8212;', []);
   s:=s+ss+'", _objdiv,_treediv ,_pref, '+IntToStr(CodeForMotoSite)+');'#13#10;
 end;
   s:=s+'zebratable($("#'+tablename+'")[0]);'#13#10;
   Result:=s;
end; // fnLoadModelList

function fnLoadModellineList(Stream: TBoBMemoryStream;select:String): string;
var
  s, s2, code, name: string;
  i, j, Qty: integer;
  vis: boolean;
  byear, bmonth, eyear, emonth: integer;
begin
  s:=s+'$("#'+select+'")[0].options.length=0;'#13#10;
  s:=s+'var j=0;'#13#10;
  s:=s+'$("#'+select+'")[0].options[j++]= new Option('' '', -1, false, false);'#13#10;
  j := Stream.ReadInt;
  for i := 1 to j do begin
    code:=IntToStr(Stream.ReadInt);
    name:=GetJSSafeStringArgMonoQuote(Stream.ReadStr);
    vis:=Stream.ReadBool;
    Stream.ReadBool;//топовость
    byear:=Stream.ReadInt;
    bmonth:=Stream.ReadInt;
    eyear:=Stream.ReadInt;
    emonth:=Stream.ReadInt;
    s2:=fnGetYMBE(byear, bmonth, eyear, emonth);
    s2:=StringReplace(s2, '&nbsp;', '', [rfReplaceAll]);
    Qty:=Stream.ReadInt; // кол-во моделей
    if (vis and (Qty>0)) then begin
      s:=s+'$("#'+select+'")[0].options[j++]= new Option('''+name+s2+''', '+code+', false, false);'#13#10;
    end;
  end;
  s:=s+'if ($("#'+select+'")[0].options.length) $("#'+select+'").change();'#13#10;
  Result:=s;
end; //fnLoadModellineList

function fnGetMPPAccountList(Stream: TBoBMemoryStream;var userInf:TEmplInfo): string;
var
  AccDate, AccNum, InvoiceNum, AccCurrency,ContractNum,AccSum2: string;
  i, j,AccCode,InvoiceCode: integer;
  AccSum :Double;
begin
  Result:='';
  j := Stream.ReadInt;
  Result:=Result+' TStream.length=0;';
  Result:=Result+' TStream.arlen='+IntToStr(j)+'; '#13#10;
  Result:=Result+' TStream.artable= new Array(); '#13#10;
  for i := 0 to j-1 do begin
    AccDate:=Stream.ReadStr;
    AccCode:=Stream.ReadInt;
    AccNum:=Stream.ReadStr;
    InvoiceCode:=Stream.ReadInt;
    InvoiceNum:=Stream.ReadStr;
    AccSum:=Stream.ReadDouble;
    AccSum2:=StringReplace(FormatFloat('# ##0.00', AccSum),',','.',[rfReplaceAll]);
    AccCurrency:=Stream.ReadStr;
    ContractNum:=Stream.ReadStr;
    Result:= Result+' TStream.artable['+IntToStr(i)+']={'+
      'AccDate:'''+AccDate+''', AccCode:'+IntToStr(AccCode)+', AccNum:'''+AccNum+''', InvoiceCode:'+IntToStr(InvoiceCode)+
      ', InvoiceNum:'''+InvoiceNum+''', AccSum:'+StringReplace(AccSum2,' ','',[rfReplaceAll])+', AccCurrency: '''+AccCurrency+''', '+
      'ContractNum:'''+ContractNum+''', Empl:'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'id')+'};'#13#10;
  end;
  Result:= Result+'fillBodyForMPPDocuments();'#13#10;
  Result:= Result+'synqcolsForMPP("#documentsdiv","documentstableheader","documentstable");'#13#10;
end;

function fnGetMotulSiteManageResult(Stream: TBoBMemoryStream; var userInf:TEmplInfo) :string;
 var
  i,NewActionCode:integer;
  KindOfOperation:integer;
  ActionCode,CurNumActionRecord,WareCode:String;
  IsAct:boolean;
  ActionEndDate: TDateTime;
begin
   KindOfOperation:=StrToInt(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'kindofoperation'));
   Result:='';
   case KindOfOperation of
     mspDelAct: begin
       ActionCode:=fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-code');
       Result:= Result+'delForActionMotulSitePage('+ActionCode+');'#13#10;
     end;
     mspDelPLine: begin
       WareCode:=fnGetFieldStrList(userInf.strPost,userInf.strGet, 'ware-code');
       Result:= Result+'delForWaresMotulSitePage('+WareCode+');'#13#10;
     end;
     mspAddAct:
       begin
         NewActionCode:=Stream.ReadInt;
         Result:=Result+'TStream.arrMotulAction[TStream.arrMotulAction.length]={';
         Result:=Result+'ActionCode:'+IntToStr(NewActionCode)+', ActionHeader:"'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-header'))+'", ';
         Result:=Result+'ActionBeginDate:"'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-fromdate')+'", ActionEndDate:"'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-todate')+'", ';
         ActionEndDate:=StrToDate(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-todate'));
         if (Trunc(ActionEndDate)>=Date) then
          IsAct:=true
         else
          IsAct:=false;
         Result:=Result+'ActionMemoText:'''+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'tinyeditorinfo'))+''', ';
         Result:=Result+'IsPlex:0, IsChex:0';
         Result:=Result+', IsAct:'+BoolToStr(IsAct);
         Result:=Result+'};'#13#10;
         Result:= Result+'addRowForMotulSiteActionTable(TStream.arrMotulAction.length-1);'#13#10;
         Result:= Result+'$("#TinyEditActionFilesDIV").css("display", "none");'#13#10;
       end;
     mspEditAct:
       begin
         ActionCode:=fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-code');
         if (StrToInt(ActionCode) in [mspResumeCode, mspInfoCode]) then   begin
           CurNumActionRecord:=fnGetFieldStrList(userInf.strPost,userInf.strGet, 'num-action-record');
           Result:=Result+'TStream.arrMotulInfo['+CurNumActionRecord+']={';
           Result:=Result+'ActionCode:'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-code')+', ActionHeader:"'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-header'))+'", ';
           Result:=Result+'ActionMemoText:'''+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'tinyeditorinfo'))+''', ';
           Result:=Result+'};'#13#10;
           Result:= Result+'editRowForMotulSiteInfoTable('+CurNumActionRecord+');'#13#10;
           Result:= Result+'$("#TinyEditActionFilesDIV").css("display", "none");'#13#10;
         end
         else begin
           CurNumActionRecord:=fnGetFieldStrList(userInf.strPost,userInf.strGet, 'num-action-record');
           ActionEndDate:=StrToDate(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-todate'));
           if (Trunc(ActionEndDate)>=Date) then
            IsAct:=true
           else
            IsAct:=false;
           Result:=Result+'TStream.arrMotulAction['+CurNumActionRecord+'].ActionCode='+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-code')+';'#13#10;
           Result:=Result+'TStream.arrMotulAction['+CurNumActionRecord+'].ActionHeader="'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-header'))+'"; '#13#10;
           Result:=Result+'TStream.arrMotulAction['+CurNumActionRecord+'].ActionBeginDate="'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-fromdate')+'"; '#13#10;
           Result:=Result+'TStream.arrMotulAction['+CurNumActionRecord+'].ActionEndDate="'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-todate')+'"; '#13#10;
           Result:=Result+'TStream.arrMotulAction['+CurNumActionRecord+'].IsAct='+BoolToStr(IsAct)+'; '#13#10;
           Result:=Result+'TStream.arrMotulAction['+CurNumActionRecord+'].ActionMemoText='''+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'tinyeditorinfo'))+'''; '#13#10;
           Result:= Result+'editRowForMotulSiteActionTable('+CurNumActionRecord+');'#13#10;
           Result:= Result+'$("#TinyEditActionFilesDIV").css("display", "none");'#13#10;
         end;
     end;
     mspAddPLine:
       begin
         NewActionCode:=Stream.ReadInt;
         Result:=Result+'TStream.arrMotulWares[TStream.arrMotulWares.length]={';
         Result:=Result+'WareCode:'+IntToStr(NewActionCode)+', WareName:"'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-header'))+'", ';
         Result:=Result+'ActionCode:0, ActionHeader:"'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'join-action-header'))+'", ';
         Result:=Result+'Image:'''', ImageSize:0};'#13#10;
         Result:= Result+'addRowForMotulSiteWaresTable(TStream.arrMotulWares.length-1);'#13#10;
         Result:= Result+'jqswMessage("Новый продукт добавлен");'#13#10;
         //Result:= Result+'$("#TinyEditActionFilesDIV").css("display", "none");'#13#10;
       end;
       mspEditPLine:
       begin
         CurNumActionRecord:=fnGetFieldStrList(userInf.strPost,userInf.strGet, 'num-action-record');
         Result:=Result+'TStream.arrMotulWares['+CurNumActionRecord+']={';
         Result:=Result+'ActionCode:'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'join-action-code')+', ActionHeader:"'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'join-action-header'))+'", ';
         Result:=Result+'WareCode:'+fnGetFieldStrList(userInf.strPost,userInf.strGet, 'ware-code')+', WareName:"'+UTF8ToAnsi(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'action-header'))+'"';
         Result:=Result+'};'#13#10;
         Result:= Result+'editRowForMotulSiteWaresTable('+CurNumActionRecord+');'#13#10;
         Result:= Result+'$("#TinyEditActionFilesDIV").css("display", "none");'#13#10;
       end
   end;

end;

function fnSaveBrandDetails(Stream: TBoBMemoryStream; var userInf:TEmplInfo; code: String; hideinprice:boolean; NotPictShow:boolean=false): string;
var
  s: string;
begin
  s:='';
  s:=s+'$("#jqdialog").dialog("close");'#13#10;
  s:=s+'var tr=$("#brandtr'+code+'")[0];'#13#10;
  s:=s+'tr.cells[1].innerHTML="'+Utf8ToAnsi(trim(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'brandshort')))+'";'#13#10;
  s:=s+'$(tr.cells[2]).attr("value", "'+Utf8ToAnsi(trim(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'brandwww')))+'");'#13#10;
  s:=s+'tr.cells[2].firstChild.src="'+fnIfStr(Utf8ToAnsi(trim(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'brandwww')))='', '/images/tr.gif', 'http://www.vladislav.ua/images/logo/'+Utf8ToAnsi(trim(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'brandwww')))+'.png')+'";'#13#10;
  s:=s+'tr.cells[3].firstChild.href="http://'+Utf8ToAnsi(trim(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'brandaddrwww')))+'";'#13#10;
  s:=s+'tr.cells[3].firstChild.innerHTML="'+Utf8ToAnsi(trim(fnGetFieldStrList(userInf.strPost,userInf.strGet, 'brandaddrwww')))+'";'#13#10;
  s:=s+'$(tr.cells[4]).attr("value", "'+BoBBoolToStr(hideinprice)+'");'#13#10;
  s:=s+'tr.cells[4].firstChild.src="'+DescrImageUrl+'/images/'+fnIfStr(hideinprice, 'checked01.png', 'tr.gif')+'";'#13#10;
  if flPictNotShow then begin
    s:=s+'$(tr.cells[5]).attr("value", "'+BoBBoolToStr(NotPictShow)+'");'#13#10;
    s:=s+'tr.cells[5].firstChild.src="'+DescrImageUrl+'/images/'+fnIfStr(NotPictShow, 'checked01.png', 'tr.gif')+'";'#13#10;
  end;
  Result:=s;
end; // fnSaveBrandDetails



end.
