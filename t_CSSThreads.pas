unit t_CSSThreads;

interface
uses Classes, SysUtils, IniFiles, Forms, DateUtils, System.Math, Variants,
     IdTCPServer, IBDatabase, IBSQL, IdHTTP, IdUri,
     n_CSSThreads, n_free_functions, n_server_common, v_constants, n_LogThreads, n_DataSetsManager, n_constants,
     n_DataCacheInMemory,
     t_function;

type
  TCheckSMSThread = class(TCSSCyclicThread)
  protected
    procedure WorkProc; override;
  public
    DateMail: double;  
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
  end;

  TControlPayThread = class(TCSSCyclicThread)
  protected
    lastControlTime: TDateTime;
    procedure WorkProc; override;
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
  end;

  TControlSMSThread = class(TCSSCyclicThread)
  protected
    lastControlTime: TDateTime;
    procedure WorkProc; override;
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
  end;

procedure prSendSMS(ThreadData: TThreadData);  
procedure prTestSMS(ThreadData: TThreadData);
function fnTestBalance: real;
function datCompToDateTime(s: string; descD: string='-'): TDateTime;
function TimeSendMess(BeginHour,EndHour: INTEGER): Boolean;

implementation

function TimeSendMess(BeginHour,EndHour: INTEGER): Boolean;
var Hour,Min,Sec,MSec: Word;
begin
  Result:= True;
  if BeginHour<0 then BeginHour:= 0;
  if BeginHour>24 then BeginHour:= 24;
  if EndHour<0 then EndHour:= 0;
  if EndHour>24 then EndHour:= 24;
  if (BeginHour=EndHour) or ((BeginHour=0) and (EndHour=24)) or ((EndHour=0) and (BeginHour=24)) then Exit;
  DecodeTime(Time,Hour,Min,Sec,MSec);
  if BeginHour<EndHour then Result:= (Hour>(BeginHour-1)) and (Hour<(EndHour+1))
  else Result:= (Hour>(BeginHour-1)) or (Hour<(EndHour+1));
end;
//==============================================================================
function datCompToDateTime(s: string; descD: string='-'): TDateTime;
var ss,sdd: string;
begin
result:= StrToDateTime(copy(s,pos(' ',s)+1,length(s)));
s:= StringReplace(s,descD,'.',[rfReplaceAll]); 
ss:= trim(copy(s,1,pos(' ',s)));
while True do begin
  if pos('.',ss)=0 then break;
  sdd:= fnIfStr(pos('.',sdd)=0,'.','')+copy(ss,1,pos('.',ss)-1)+sdd;
  ss:= copy(ss,pos('.',ss)+1,length(ss)) ;
end;
if (ss<>'') and (sdd<>'') then
  sdd:= ss+'.'+sdd+' '+copy(s,pos(' ',s)+1,length(s))
else 
  sdd:= copy(s,pos(' ',s)+1,length(s));
result:= StrToDateTime(sdd);
end;
//==============================================================================
//******************************************************************************
//                            TControlPayThread
//******************************************************************************
procedure TControlPayThread.WorkProc;
const nmProc = 'TControlPayThread_WorkProc'; // имя процедуры/функции/потока
var fOpen: boolean;
    rIniFile: TINIFile;
    BeginHour,EndHour, countR, Interval: integer;
    IBSQL: TIBSQL;
    IBLog: TIBDatabase;
    SLBody: TStringList;
    Addrs, ss: string; 
    DT: TDateTime;
begin
//DT:= StrToDateTime('20.09.2016')+time;
  BeginHour:= 0;
  EndHour:= 0;
try   
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  if rIniFile.ReadInteger('threads', 'ControlPay', 0)=0 then exit;
  DT:= LastControlTime;
  LastControlTime:= now;
  try
    if (DayOfWeek(date)=1) or (DayOfWeek(date)=7) then begin
      Interval:= rIniFile.ReadInteger('intervals', 'CheckPayS', 30);
      BeginHour  := rIniFile.ReadInteger('intervals','BeginHourPayS',0);  // начало 
      EndHour    := rIniFile.ReadInteger('intervals','EndHourPayS',0);    // окончание 
    end;
    if (DayOfWeek(date)<>1) and (DayOfWeek(date)<>7) then begin
      interval:= rIniFile.ReadInteger('intervals', 'CheckPay', 10);
      BeginHour  := rIniFile.ReadInteger('intervals','BeginHourPay',0);  // начало 
      EndHour    := rIniFile.ReadInteger('intervals','EndHourPay',0);    // окончание 
    end;
    CycleInterval:= interval*60;
    fOpen:= (appStatus in [stWork]) and (cntsLOG.BaseConnected);
    if fOpen and TimeSendMess(BeginHour,EndHour) then begin
      try
        IBLog:= CntsLog.GetFreeCnt;
        IBSQL:= fnCreateNewIBSQL(IBLog,'LOGIBSQL_'+nmProc, -1, tpRead, true);
//        IBSQL.SQL.Text:= 'SELECT count(THLGCODE) CountR  FROM LOGTHREADS where THLGTYPE=22 and THLGBEGINTIME>= :pBEGINTIME ';
        IBSQL.SQL.Text:= 'SELECT first 1 THLGCODE  FROM LOGTHREADS where THLGTYPE=22 and THLGBEGINTIME>= :pBEGINTIME ';
        IBSQL.ParamByName('pBEGINTIME').AsDateTime:= DT;//IncMinute(now{DT},-Interval);
        IBSQL.Prepare; 
        IBSQL.ExecQuery;
        countR:= 0;
        while not IBSQL.EOF do begin
          countR:= IBSQL.FieldByName('THLGCODE').AsInteger;
          IBSQL.Next;
        end;
        if countR=0 then begin
          SLBody:= TStringList.Create;
          SLBody.Add('Внимание! В течении последних '+IntToStr(Interval)+' мин. система платежей не работала!');
          Addrs:= rIniFile.ReadString('mail', 'SysAdresPay','');
          ss:= n_SysMailSend(Addrs, 'PAY Error', SLBody, nil, cNoReplayEmail, '', true);
          if ss<>'' then prMessageLOGS(nmProc+' Ошибка при отправке email: '+ss,'Error' , true);
        end;
      finally
        prFreeIBSQL(IBSQL);
        CntsLog.SetFreeCnt(IBLog, True);
        prFree(SLBody);
      end;
    end;
  except
    on E:Exception do begin
      prMessageLOGS(nmProc+' Ошибка при проверке работы системы платежей ','Error' , true);
    end;
  end;
finally
  prFree(rIniFile);
end;
end;
//==============================================================================
constructor TControlPayThread.Create(CreateSuspended: Boolean; AThreadType: integer);
const nmProc = 'TControlPayThread_Create'; // имя процедуры/функции/потока
var rIniFile: TINIFile;
    Interval: integer;
begin
  inherited Create(CreateSuspended, AThreadType);
try try 
  ThreadName:= 'TControlPayThread';
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  if (DayOfWeek(date)=1) or (DayOfWeek(date)=7) then 
      Interval:= rIniFile.ReadInteger('intervals', 'CheckPayS', 10);
  if (DayOfWeek(date)<>1) and (DayOfWeek(date)<>7) then 
      Interval:= rIniFile.ReadInteger('intervals', 'CheckPay', 10);   
  CycleInterval:= Interval*60;     
  LastControlTime:= IncMinute(now,-Interval);
  prMessageLOG(ThreadName+': Запуск потока проверки зависания системы приема платежей');
except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message+
     #10'Error.'#10+'nmIniFileBOB='+nmIniFileBOB);
end;
finally
  prFree(rIniFile);
end;
end;
//==============================================================================
procedure TControlPayThread.DoTerminate;
begin
  inherited;
  prMessageLOG(ThreadName+': Завершение потока проверки зависания системы приема платежей');
end;

//******************************************************************************
//******************************************************************************
//                            TControlSMSThread
//******************************************************************************
procedure TControlSMSThread.WorkProc;
const nmProc = 'TControlSMSThread_WorkProc'; // имя процедуры/функции/потока           //CheckSMSInterval
var fOpen: boolean;
    rIniFile: TINIFile;
    BeginHour,EndHour, countR, Interval: integer;
    IBSQL: TIBSQL;
    IBGB: TIBDatabase;
    SLBody: TStringList;
    Addrs, ss: string; 
    DT: TDateTime;
begin
  BeginHour:= 0;
  EndHour:= 0;
try   
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  if rIniFile.ReadInteger('threads', 'CheckSMS', 0)=0 then exit;
  if rIniFile.ReadInteger('threads', 'ControlSMS', 0)=0 then exit;
  DT:= LastControlTime;
  try
//    CycleInterval:= rIniFile.ReadInteger('intervals', 'CheckSMS', 30);
    if (DayOfWeek(date)=1) or (DayOfWeek(date)=7) then begin
      Interval:= rIniFile.ReadInteger('intervals', 'CheckSMSS', 30);
      BeginHour  := rIniFile.ReadInteger('intervals','BeginHourSMSS',0);  // начало 
      EndHour    := rIniFile.ReadInteger('intervals','EndHourSMSS',0);    // окончание 
    end;
    if (DayOfWeek(date)<>1) and (DayOfWeek(date)<>7) then begin
      Interval:= rIniFile.ReadInteger('intervals', 'CheckSMS', 10);
      BeginHour  := rIniFile.ReadInteger('intervals','BeginHourSMS',0);  // начало 
      EndHour    := rIniFile.ReadInteger('intervals','EndHourSMS',0);    // окончание 
    end;
    CycleInterval:= Interval*60;
    fOpen:= (appStatus in [stWork]) and (cntsGRB.BaseConnected);
    if fOpen and TimeSendMess(BeginHour,EndHour) then begin
      try
        IBGB:= CntsGRB.GetFreeCnt();//(cDefGBLogin, cDefPassword, cDefGBrole,True);
        IBSQL:= fnCreateNewIBSQL(IBGB,'IBSQL_'+nmProc, -1, tpRead, true);
//        IBSQL.SQL.Text:= 'SELECT count(SBCODE) countR FROM SMSBOX where SBURGENCY in (1,2) and  (SBCAMPID is null or SBCAMPID=0) and (SBERROR is null or SBERROR="") and '#10
//                       + 'SBCREATEDATE>= :pBEGINTIME and  SBCREATEDATE< :pEndTIME ';
        IBSQL.SQL.Text:= 'SELECT first 1 SBCODE  FROM SMSBOX where SBURGENCY in (1,2) and  (SBCAMPID is null or SBCAMPID=0) and (SBERROR is null or SBERROR="") and '#10
                       + 'SBCREATEDATE>= :pBEGINTIME and SBCREATEDATE< :pEndTIME';               
        IBSQL.ParamByName('pBEGINTIME').AsDateTime:= DT;//IncMinute({now}DT,-(Interval+2*rIniFile.ReadInteger('intervals','CheckSMSInterval',0)));
        IBSQL.ParamByName('pEndTIME').AsDateTime:= IncMinute(now,-(2*rIniFile.ReadInteger('intervals','CheckSMSInterval',0)));//IncMinute({now}DT,-(rIniFile.ReadInteger('intervals','CheckSMSInterval',0)));
        LastControlTime:= IncMinute(now,-(2*rIniFile.ReadInteger('intervals','CheckSMSInterval',0)));
        IBSQL.Prepare; 
        IBSQL.ExecQuery;
        countR:= 0;
        while not IBSQL.EOF do begin
          countR:= IBSQL.FieldByName('SBCODE').AsInteger;
          IBSQL.Next;
        end;   
        if countR>0 then begin
          SLBody:= TStringList.Create;
          SLBody.Add('Внимание! В течении последних '+IntToStr(Interval)+' мин. система отправки СМС не работала!');
          Addrs:= rIniFile.ReadString('mail', 'SysAdresPay','');
          ss:= n_SysMailSend(Addrs, 'SMS Error', SLBody, nil, cNoReplayEmail, '', true);
          if ss<>'' then prMessageLOGS(nmProc+' Ошибка при отправке email: '+ss,'Error' , true);
        end;
      finally
        prFreeIBSQL(IBSQL);
        CntsGRB.SetFreeCnt(IBGB, True);
        prFree(SLBody);
      end;
    end;
  except
    on E:Exception do begin
      prMessageLOGS(nmProc+' Ошибка при проверке работы системы отправки СМС ','Error' , true);
    end;
  end;
finally
  prFree(rIniFile);
end;
end;
//==============================================================================
constructor TControlSMSThread.Create(CreateSuspended: Boolean; AThreadType: integer);
const nmProc = 'TControlSMSThread_Create'; // имя процедуры/функции/потока
var rIniFile: TINIFile;
    Interval: integer;
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'TControlSMSThread';
try  
  rIniFile:= TINIFile.Create(nmIniFileBOB);
    if (DayOfWeek(date)=1) or (DayOfWeek(date)=7) then 
      Interval:= rIniFile.ReadInteger('intervals', 'CheckSMSS', 30);

    if (DayOfWeek(date)<>1) and (DayOfWeek(date)<>7) then
      Interval:= rIniFile.ReadInteger('intervals', 'CheckSMS', 10);
    CycleInterval:= Interval*60;
    LastControlTime:= IncMinute(now,-(Interval+(2*rIniFile.ReadInteger('intervals','CheckSMSInterval',0))));;
  prMessageLOG(ThreadName+': Запуск потока проверки зависания системы отправки СМС');
finally
  prFree(rIniFile);
end;
end;
//==============================================================================
procedure TControlSMSThread.DoTerminate;
begin
  inherited;
  prMessageLOG(ThreadName+': Завершение потока проверки зависания системы отправки СМС');
end;

//******************************************************************************
//==============================================================================
function fnTestBalance: real;
var jsonToBal, SLBody: TStringList;
    pIniFile: TINIFile;
    HTTP: TIDHTTP;
    Stream: TStringStream;
    ss: string;
//    balance: real;
begin
  result:= 0;
  Stream:= nil;
  jsonToBal := TStringList.create;
  jsonToBal.Add('<?xml version="1.0" encoding="utf-8"?>');
  jsonToBal.Add('<request>');
  jsonToBal.Add('<operation>GETBALANCE</operation>');
  jsonToBal.Add('</request>');
  SLBody:= TStringList.Create;
  try
    HTTP:= TIDHTTP.Create(nil);
    HTTP.HandleRedirects := true;
    HTTP.ReadTimeout := 5000;
    HTTP.Request.BasicAuthentication:= true; 
    pIniFile:= TINIFile.Create(nmIniFileBOB);  
    if (pIniFile.ReadString('Proxy', 'Server', '')<>'') and (pIniFile.ReadString('svitSMS', 'login', '')<>'') then begin
      HTTP.ProxyParams.ProxyServer:=pIniFile.ReadString('Proxy', 'Server', '');
      HTTP.ProxyParams.ProxyPort:=pIniFile.ReadInteger('Proxy', 'Port', 8080);
      HTTP.ProxyParams.ProxyUsername:=pIniFile.ReadString('Proxy', 'login', '');
      HTTP.ProxyParams.ProxyPassword:=pIniFile.ReadString('Proxy', 'Password', '');
      HTTP.Request.Username:=pIniFile.ReadString('svitSMS', 'login', '380952306161');//'380952306161';
      HTTP.Request.Password:=pIniFile.ReadString('svitSMS', 'Password', 'RkbtynGhfd531');//'RkbtynGhfd531';
    end
    else exit;
    Stream:=TStringStream.Create(jsonToBal.Text, TEncoding.UTF8);
    ss:= http.Post(TIdUri.UrlEncode('http://svitsms.com/api/api.php'), Stream);
    Stream.Clear;
    ss:= fnCutFromTo(ss, '<balance>', '</balance>',false);
    ss:=StringReplace(ss,'.',DecimalSeparator,[rfReplaceAll]);
    result:= StrToFloatDef(ss,0);
  finally
    if assigned(SLBody) then prFree(SLBody);
    if assigned(jsonToBal) then prFree(jsonToBal);
    if assigned(HTTP) then prFree(HTTP);
    if assigned(pIniFile) then prFree(pIniFile);
    if assigned(Stream) then prFree(Stream);
  end;
end;
//==============================================================================
procedure prSendSMS(ThreadData: TThreadData); 
const nmProc='prSendSMS';
      arState: array [0..10] of string  = (
      'ACCEPT',        // – сообщение принято системой и поставлено в очередь на формирование рассылки.
      'XMLERROR',      // – Некорректный XML .
      'ERRPHONES',     //– Неверно задан номер получателя.
      'ERRSTARTTIME',  //– не корректное время начала отправки.
      'ERRENDTIME',    //– не корректное время окончания рассылки.
      'ERRLIFETIME',   //– не корректное время жизни сообщения.
      'ERRSPEED',      //– не корректная скорость отправки сообщений.
      'ERRALFANAME',   //– данное альфанумерическое имя использовать запрещено, либо ошибка .
      'ERRTEXT',
      'ERRMobilePHONES',
      'TEST');
      arStateR: array [0..10] of string  = (
      ' сообщение принято системой и поставлено в очередь на формирование рассылки ',
      ' Некорректный XML ',
      ' Неверно задан номер получателя ',
      ' не корректное время начала отправки ',
      ' не корректное время окончания рассылки ',
      ' не корректное время жизни сообщения ',
      ' не корректная скорость отправки сообщений ',
      ' данное альфанумерическое имя использовать запрещено, либо ошибка ',
      ' некорректный текст сообщения ',
      ' Номер не мобильный',
      ' Проверка работы.');
var GBIBSQL, GBIBSQLUp: TIBSQL;
    IBGRB, IBGRBUp: TIBDatabase;
    HTTP: TIDHTTP;
    Stream: TStringStream;
    SBCODE, SBURGENCY,  i, iState: integer; 
    SBMESSAGE, SBPHONE, SendSS, ss, SBALPHANAME, sError, Err: string;
    flSend, TestMob: boolean;
    jsonToSend, jsonToBal, SLBody, SLBodyBal: TStringList;
    pIniFile: TINIFile;
    sstat, campaignID, datComp, code, sRec, rec, Addrs: string;
    balance, tarif: real;
    SENDTIMECSS, SBCREATEDATE: TDateTime;
    DS: char;
    TimeSend: double;
    countSend: integer;
begin
  GBIBSQL:= nil;
  GBIBSQLUp:= nil;
  IBGRB:= nil;
  IBGRBUp:= nil;
  Stream:= nil;
  flSend:= false;
  SendSS:= '';
  SBURGENCY:= 0;
  SBCODE:= 0;
  SBPHONE:= '';
  SBMESSAGE:= '';
  countSend:= 0;
  jsonToSend := TStringList.create;
  jsonToBal := TStringList.create;
  jsonToBal.Add('<?xml version="1.0" encoding="utf-8"?>');
  jsonToBal.Add('<request>');
  jsonToBal.Add('<operation>GETBALANCE</operation>');
  jsonToBal.Add('</request>');
  SLBody:= TStringList.Create;
  SLBodyBal:= TStringList.Create;
prMessageLOGS(nmProc+' начало ','testSMS' , false);  
  try

    HTTP:= TIDHTTP.Create(nil);
    HTTP.HandleRedirects := true;
    HTTP.ReadTimeout := 5000;
    HTTP.Request.BasicAuthentication:= true; 
    pIniFile:= TINIFile.Create(nmIniFileBOB);  
    if (pIniFile.ReadString('Proxy', 'Server', '')<>'') and (pIniFile.ReadString('svitSMS', 'login', '')<>'') then begin
      HTTP.ProxyParams.ProxyServer:=pIniFile.ReadString('Proxy', 'Server', '');
      HTTP.ProxyParams.ProxyPort:=pIniFile.ReadInteger('Proxy', 'Port', 8080);
      HTTP.ProxyParams.ProxyUsername:=pIniFile.ReadString('Proxy', 'login', '');
      HTTP.ProxyParams.ProxyPassword:=pIniFile.ReadString('Proxy', 'Password', '');
      HTTP.Request.Username:=pIniFile.ReadString('svitSMS', 'login', '380952306161');//'380952306161';
      HTTP.Request.Password:=pIniFile.ReadString('svitSMS', 'Password', 'RkbtynGhfd531');//'RkbtynGhfd531';
    end
    else exit;
    tarif:= pIniFile.ReadFloat('svitSMS', 'tarif', 0.245);
    IBGRB:= CntsGRB.GetFreeCnt();//(cDefGBLogin, cDefPassword, cDefGBrole,True);;
    IBGRBUp:=CntsGRB.GetFreeCnt();//(cDefGBLogin, cDefPassword, cDefGBrole);
    GBIBSQL:= fnCreateNewIBSQL(IBGRB, 'Query_'+nmProc, -1, tpRead, true);
    GBIBSQLUp:= fnCreateNewIBSQL(IBGRBUp, 'Query_'+nmProc, -1, tpWrite, true);
    GBIBSQLUp.SQL.Text:='Update SMSBOX set SBSTATE=:pSBSTATE, SBCAMPID=:pSBSENDCode, SBSENDDATE=:pSBSENDDATE, SBERROR=:pSBERROR '
                       +',SBSENDTIMECSS=:pSBSENDTIMECSS '
                       +'where SBCODE=:pSBCODE';
    GBIBSQL.SQL.Text:= 'SELECT SBCODE, SBPHONE, SBMESSAGE, SBURGENCY, SBSTATE, SBERROR, SBALPHANAME, SBCREATEDATE, RResult TestMob '#10
                     + 'FROM SMSBOX left join TestMobilePhone(SBPHONE) on 0=0 '#10
                     + 'where (SBCAMPID is null or SBCAMPID=0) and (SBERROR is null or SBERROR="") order by SBCREATEDATE';
    GBIBSQL.Prepare; 
    GBIBSQL.ExecQuery;
//prMessageLOGS(nmProc+' GBIBSQL.ExecQuery ','error' , false);
    try
      TimeSend:= now;
      while not GBIBSQL.EOF do begin  
        try
          SBURGENCY:= GBIBSQL.FieldByName('SBURGENCY').AsInteger;
          SBCODE:= GBIBSQL.FieldByName('SBCODE').AsInteger;
          SBCREATEDATE:= GBIBSQL.FieldByName('SBCREATEDATE').AsDateTime;      
          SBPHONE:= GBIBSQL.FieldByName('SBPHONE').AsString;   
          TestMob:= StrToBool(fnIfStr(GBIBSQL.FieldByName('TestMob').AsString='T', 'TRUE', 'FALSE')); 
//1- сообщение должно быть отправлено немедленно, 2 - отправка в будні - 8:00-20:00, у вихідні - 11:00-17:00; 0 - проверка работы  
          if (SBURGENCY=1) or (SBURGENCY=0) then flSend:= true;
          if (SBURGENCY=2) and (
            ((DayOfWeek(Now)<>1) and (DayOfWeek(Now)<>7) and (HourOf(now)>=8) and (HourOf(Now)<20)) 
            or (((DayOfWeek(Now)=1) or (DayOfWeek(Now)=7)) and (HourOf(now)>=11) and (HourOf(Now)<17))) then flSend:= true;
          if pos('0999999999', SBPHONE)>0 then flSend:= false;
          if not TestMob then flSend:= false;
          
          if flSend then begin
            ss:='';
//            SBCODE:= GBIBSQL.FieldByName('SBCODE').AsInteger;
            
            SBMESSAGE:= GBIBSQL.FieldByName('SBMESSAGE').AsString;
            SBALPHANAME:= GBIBSQL.FieldByName('SBALPHANAME').AsString;

///////////////////////////////////////////////////////////////////////////////          +380730203913
            TestCssStopException; 
////            Stream:=TStringStream.Create(jsonToBal.Text, TEncoding.UTF8);
////            ss:= http.Post(TIdUri.UrlEncode('http://svitsms.com/api/api.php'), Stream);
////            Stream.Clear;
////            ss:= fnCutFromTo(ss, '<balance>', '</balance>',false);
////            ss:=StringReplace(ss,'.',DecimalSeparator,[rfReplaceAll]);
////            balance:= StrToFloatDef(ss,0);
            balance:= fnTestBalance;
            if (balance<tarif) then begin
              prMessageLOGS(nmProc+ ' Нет средств для отправки СМС. '+'Баланс: '+ FloatToStr(balance), 'testSMS', true) ;
              //отправка письма на элпочту 1 раз в час
              if (TCheckSMSThread(thCheckSMSThread).DateMail=0) or (IncHour(TCheckSMSThread(thCheckSMSThread).DateMail)<now) then begin
                TCheckSMSThread(thCheckSMSThread).DateMail:= now;
                SLBodyBal.Clear;
                SLBodyBal.Add(' Нет средств для отправки СМС. '+'Баланс: '+ FloatToStr(balance));
//                Addrs:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue;  >> 21.09.2016 12:34:30  Чичков Валерий wrote: >> Поменяйте, плз на payment@vladislav.ua
                Addrs:= IniFile.ReadString('mails', 'svitSMS', '');
                ss:= n_SysMailSend(Addrs, 'SMS Error', SLBody, nil, cNoReplayEmail, '', true);
                if ss<>'' then prMessageLOGS(nmProc+' Ошибка при отправке email: '+ss,'TestSMS' , true);
                Addrs:= '';
                ss:= '';
                SLBodyBal.Clear;
              end;
              break;//////// balance<tarif
            end;
            if (balance>=tarif) then begin
              if TCheckSMSThread(thCheckSMSThread).DateMail>0 then TCheckSMSThread(thCheckSMSThread).DateMail:= 0;
              ss:='';
              jsonToSend.Clear;
              jsonToSend.Add('<?xml version="1.0" encoding="utf-8"?>');
              jsonToSend.Add('<request>');
              jsonToSend.Add('<operation>SENDSMS</operation>');
              jsonToSend.Add('<message start_time="AUTO" end_time="AUTO" lifetime="24" rate="120" desc="My campaign " source="'+SBALPHANAME+'">');
              jsonToSend.Add('<body>'+SBMESSAGE+'</body>');
              jsonToSend.Add('<recipient>'+SBPHONE+'</recipient>');
              jsonToSend.Add('</message>');
              jsonToSend.Add('</request>');
              prMessageLOGS(nmProc+' отпр: '+jsonToSend.Text,'testSMS' , false);            
              Stream:=TStringStream.Create(jsonToSend.Text, TEncoding.UTF8);
              if SBURGENCY<>0 then
                ss:= http.Post(TIdUri.UrlEncode('http://svitsms.com/api/api.php'), Stream);     //sms
              Application.ProcessMessages;
              inc(countSend);
              Stream.Clear;
            SENDTIMECSS:=now;
//ss:='<?xml version="1.0" encoding="utf-8"?><message>	<state code="ERRTEXT" date="2016-10-17 09:17:10">STOPWORDS  струк </state></message>';
              prMessageLOGS(nmProc+' ответ: '+ss,'testSMS' , false);
              if ss<>'' then begin
                sstat:= fnCutFromTo(ss, '<state', '</state>',false);
                //code="ERRSTARTTIME"
                code:= fnCutFromTo(sstat, 'code="', '"',false);
                datComp:= fnCutFromTo(sstat, 'date="', '"',false);
                campaignID:= fnCutFromTo(sstat, 'campaignID="', '"',false);            
              end
              else begin
                datComp:= '';
              end;
              iState:= fnInStrArray(code,arState);
              if SBURGENCY=0 then iState:= 10;
              
              if iState=0 then begin
                while True do begin
                  sRec:= fnCutFromTo(ss, '<to', '/>',true);
                  if sRec='' then break;
                  rec:= fnCutFromTo(sRec, 'recipient="', '"',false);
                  sstat:= fnCutFromTo(sRec, 'status="', '"',false);
                  try
                    with GBIBSQLUp.Transaction do if not InTransaction then StartTransaction;                             
                    GBIBSQLUp.ParamByName('pSBERROR').AsString:= '';
                    GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= datCompToDateTime(datComp);//StrToDateTime(datComp);
                    GBIBSQLUp.ParamByName('pSBSENDTIMECSS').AsDateTime:= SENDTIMECSS;
                    GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= -1;
                    GBIBSQLUp.ParamByName('pSBSENDCode').AsString:= campaignID;/////////////////////////////
                    GBIBSQLUp.ParamByName('pSBCODE').AsInteger:= SBCODE;     
                    GBIBSQLUp.ExecQuery;
                    GBIBSQLUp.Transaction.Commit;
                    GBIBSQLUp.Close;
                  except
                    on E: Exception do begin
                      GBIBSQLUp.Transaction.Rollback;
                      prMessageLOGS('Ошибка обновления базы '+nmProc+' '+ E.Message, 'TestSMS', true) ;
                      prMessageLOGS('Phone='+SBPHONE+'; campaignID='+campaignID+'date='+datComp, 'TestSMS', true) ;
                    end;
                  end;
                end;
              end
              else begin   //error
                try
                  Err:='';
                  if length(sstat)<>0 then Err:= copy(sstat,pos('>',sstat)+1, length(sstat));
                  with GBIBSQLUp.Transaction do if not InTransaction then StartTransaction;                           
                  SLBody.Add('Ошибка отправки СМС: '+SBPHONE);
                  GBIBSQLUp.ParamByName('pSBERROR').AsString:= arStateR[iState]+fnIfStr(length(Err)>0,'('+Err+')','');
                  if datComp= '' then  GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= SENDTIMECSS
                    else
                  GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= datCompToDateTime(datComp);//StrToDateTime(datComp);
  //              if flDebug then
                  GBIBSQLUp.ParamByName('pSBSENDTIMECSS').AsDateTime:= SENDTIMECSS;
                  GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= -1;
                  GBIBSQLUp.ParamByName('pSBSENDCode').AsInteger:= 0;/////////////////////////////
                  GBIBSQLUp.ParamByName('pSBCODE').AsInteger:= SBCODE;     
                  GBIBSQLUp.ExecQuery;
                  GBIBSQLUp.Transaction.Commit;
                  GBIBSQLUp.Close;
                except
                    on E: Exception do begin
                      GBIBSQLUp.Transaction.Rollback;
                      prMessageLOGS('Ошибка обновления базы '+nmProc+' '+ E.Message, 'TestSMS', true) ;
                      prMessageLOGS('Phone='+SBPHONE+'; campaignID='+campaignID+'date='+datComp, 'TestSMS', true) ;
                    end;
                end;
                SLBody.Add('Ошибка при отправке СМС на '+SBPHONE +': '+arStateR[iState]+fnIfStr(length(Err)>0,'('+Err+')',''));
              end;
              if (countSend>=8) then begin 
                countSend:= 0;
                if (now<IncSecond(TimeSend)) then sleep(100);
                TimeSend:= now;//IncSecond 
              end;              
            end;
//            else prMessageLOGS('Номер не мобильный: Phone='+SBPHONE, 'TestSMS', true) ;
          end
          else if (SBCREATEDATE+1>=now) then  begin
            sError:= '';
            if (SBURGENCY<1) or (SBURGENCY>2) then 
              sError:= 'Неизвестное значение "Код срочности": '+IntToStr(SBURGENCY);
            if pos('0999999999', SBPHONE)>0 then
              sError:= 'Запрет отправки: '+SBPHONE;
            if not TestMob then
              sError:= 'Номер не мобильный: '+SBPHONE;
            if sError<>'' then begin
              prMessageLOGS(sError, 'TestSMS', false) ;
              SENDTIMECSS:=now;
              try
                with GBIBSQLUp.Transaction do if not InTransaction then StartTransaction;                           
  //              SLBody.Add('Ошибка отправки СМС: '+SBPHONE);
                GBIBSQLUp.ParamByName('pSBERROR').AsString:= sError;
                if datComp= '' then  GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= SENDTIMECSS
                  else
                GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= datCompToDateTime(datComp);//StrToDateTime(datComp);
                GBIBSQLUp.ParamByName('pSBSENDTIMECSS').AsDateTime:= SENDTIMECSS;
                GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= -1;
                GBIBSQLUp.ParamByName('pSBSENDCode').AsInteger:= 0;/////////////////////////////
                GBIBSQLUp.ParamByName('pSBCODE').AsInteger:= SBCODE;     
                GBIBSQLUp.ExecQuery;
                GBIBSQLUp.Transaction.Commit;
                GBIBSQLUp.Close;
              except
                on E: Exception do begin
                  GBIBSQLUp.Transaction.Rollback;
                  prMessageLOGS('Ошибка обновления базы '+nmProc+' '+ E.Message, 'TestSMS', true) ;
                  prMessageLOGS('SBCODE='+IntToStr(SBCODE)+'date='+datComp, 'TestSMS', true) ;
                end;
              end;
            end;
          end;
        except
          on e: exception do  begin
            prMessageLOGS('Ошибка: '+e.Message,'TestSMS' , false);
            prMessageLOGS('SBCODE= '+IntToStr(SBCODE)+' SBPHONE='+SBPHONE+' SBMESSAGE='+SBMESSAGE,'TestSMS' , false);
          end;
        end;  
        
        SBURGENCY:= 0;
        SBCODE:= 0;
        SBPHONE:= '';
        SBMESSAGE:= '';
        flSend:= false;   
        TestCssStopException;        
        GBIBSQL.Next;
      end;
      
      
    except
      on e: exception do  begin
        prMessageLOGS('Ошибка при обработке результатов запроса: '+e.Message,'TestSMS' , false);
      end;
    end;
  finally
//prMessageLOGS(nmProc+' finally ','error' , false);
    if SLBody.Count>0 then begin
//      Addrs:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue;      >> 21.09.2016 12:34:30  Чичков Валерий wrote: >> Поменяйте, плз на payment@vladislav.ua
      Addrs:= pIniFile.ReadString('svitSMS', 'Mails', '');
      ss:= n_SysMailSend(Addrs, 'SMS Error', SLBody, nil, cNoReplayEmail, '', true);
      if ss<>'' then prMessageLOGS(nmProc+' Ошибка при отправке email: '+ss,'TestSMS' , true);
    end;
    prFreeIBSQL(GBIBSQL);
    prFreeIBSQL(GBIBSQLUp);
    if assigned(IBGRB) then cntsGRB.SetFreeCnt(IBGRB, True);
    if assigned(IBGRBUp) then cntsGRB.SetFreeCnt(IBGRBUp, True);
    if assigned(SLBody) then prFree(SLBody);
    if assigned(SLBodyBal) then prFree(SLBodyBal);
    if assigned(jsonToBal) then prFree(jsonToBal);
    if assigned(jsonToSend) then prFree(jsonToSend);
    if assigned(HTTP) then prFree(HTTP);
    if assigned(pIniFile) then prFree(pIniFile);
    if assigned(Stream) then prFree(Stream);
prMessageLOGS(nmProc+' finally end','testSMS' , false);    
  end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure prTestSMS(ThreadData: TThreadData); 
const nmProc='prTestSMS';
      arState: array [0..10] of string  = (
      'PENDING',// - запланировано;
      'SENT',// - передано мобильному оператору;
      'DELIVERED',// - доставлено;
      'EXPIRED',// - истек срок доставки;
      'UNDELIV',// - не доставлено;
      'STOPED',// - остановлено системой (недостаточно средств);
      'ERROR',// - ошибка при отправке;
      'USERSTOPED',// - остановлено пользователем;
      'ALFANAMELIMITED',// - ограничено альфаименем;
      'STOPFLAG',
      'NEW'// – временные статусы;
      );
      arStateR: array [0..10] of string  = (
      'запланировано',
      'передано мобильному оператору',
      'доставлено',
      'истек срок доставки',
      'не доставлено',
      'остановлено системой (недостаточно средств)',
      'ошибка при отправке',
      'остановлено пользователем',
      'ограничено альфаименем',
      'временные статус',
      'временные статус');
var GBIBSQL, GBIBSQLUp: TIBSQL;
    IBGRB, IBGRBUp: TIBDatabase;
    HTTP: TIDHTTP;
    Stream: TStringStream;
    SBCODE, SBCAMPID, i: integer; 
    SBPHONE, SendSS, ss: string;
    jsonToSend, SLGroup, SLBody: TStringList;
    pIniFile: TINIFile;
    sstat, campaignID, datComp, status, rec, Addrs: string;
    SBSENDDATE: TDateTime;
begin
  GBIBSQL:= nil;
  GBIBSQLUp:= nil;
  IBGRB:= nil;
  IBGRBUp:= nil;
  Stream:= nil;
  SendSS:= '';
  SBCAMPID:= 0;
  SBSENDDATE:= 0;
  jsonToSend := TStringList.create;
  SLGroup:= TStringList.create;
  SLBody:= TStringList.create;
prMessageLOGS(nmProc+' начало ','testSMS' , false);  
  try
    HTTP:= TIDHTTP.Create(nil);
    HTTP.HandleRedirects := true;
    HTTP.ReadTimeout := 5000;
    HTTP.Request.BasicAuthentication:= true; 
    pIniFile:= TINIFile.Create(nmIniFileBOB);  
    if (pIniFile.ReadString('Proxy', 'Server', '')<>'') and (pIniFile.ReadString('svitSMS', 'login', '')<>'') then begin
      HTTP.ProxyParams.ProxyServer:=pIniFile.ReadString('Proxy', 'Server', '');
      HTTP.ProxyParams.ProxyPort:=pIniFile.ReadInteger('Proxy', 'Port', 8080);
      HTTP.ProxyParams.ProxyUsername:=pIniFile.ReadString('Proxy', 'login', '');
      HTTP.ProxyParams.ProxyPassword:=pIniFile.ReadString('Proxy', 'Password', '');
      HTTP.Request.Username:=pIniFile.ReadString('svitSMS', 'login', '380952306161');//'380952306161';
      HTTP.Request.Password:=pIniFile.ReadString('svitSMS', 'Password', 'RkbtynGhfd531');//'RkbtynGhfd531';
    end
    else exit;
//prMessageLOGS(nmProc+' HTTP ','error' , false);
    IBGRB:= CntsGRB.GetFreeCnt();//(cDefGBLogin, cDefPassword, cDefGBrole,True);;
    IBGRBUp:=CntsGRB.GetFreeCnt();//(cDefGBLogin, cDefPassword, cDefGBrole);
    GBIBSQL:= fnCreateNewIBSQL(IBGRB, 'Query_'+nmProc, -1, tpRead, true);
    GBIBSQLUp:= fnCreateNewIBSQL(IBGRBUp, 'Query_'+nmProc, -1, tpWrite, true);
    GBIBSQLUp.SQL.Text:='Update SMSBOX set SBSTATE=:pSBSTATE, SBSENDDATE=:pSBSENDDATE, SBERROR=:pSBERROR where SBCODE=:pSBCODE';
    GBIBSQL.SQL.Text:='SELECT SBCODE, SBCAMPID, SBPHONE, SBSTATE, SBERROR, SBSENDDATE '#10
                     + 'FROM SMSBOX '#10
                     + 'where SBCAMPID>0 and (SBERROR is null or SBERROR="")  order by SBCAMPID';
    GBIBSQL.Prepare; 
    GBIBSQL.ExecQuery;
//prMessageLOGS(nmProc+' GBIBSQL.ExecQuery ','error' , false);    
    try
      while not GBIBSQL.EOF do begin    
        if (SBCAMPID<>GBIBSQL.FieldByName('SBCAMPID').AsInteger) and (SLGroup.Count>0) then begin
          if SLGroup.Count>1 then begin
            jsonToSend.Add('<?xml version="1.0" encoding="utf-8"?>');
            jsonToSend.Add('<request>');
            jsonToSend.Add('<operation>GETCAMPAIGNDETAIL</operation>');
            jsonToSend.Add('<message campaignID="'+IntToStr(SBCAMPID)+'" />');
            jsonToSend.Add('</request>');
          end;
          if SLGroup.Count=1 then begin
            jsonToSend.Add('<?xml version="1.0" encoding="utf-8"?>');
            jsonToSend.Add('<request>');
            jsonToSend.Add('<operation>GETMESSAGESTATUS</operation>');
            jsonToSend.Add('<message campaignID="'+IntToStr(SBCAMPID)+'" recipient="'+SBPHONE+'" />');
            jsonToSend.Add('</request>');
          end;
prMessageLOGS(nmProc+' отпр: '+jsonToSend.Text,'testSMS' , false);            
          Stream:=TStringStream.Create(jsonToSend.Text, TEncoding.UTF8);
          ss:= http.Post(TIdUri.UrlEncode('http://svitsms.com/api/api.php'), Stream);
          Application.ProcessMessages;
prMessageLOGS(nmProc+' ответ: '+ss,'testSMS' , false);
          Stream.Clear;
          while True do begin
            sstat:= fnCutFromTo(ss, '<message', '</message>',true);
            if sstat='' then break;
            if pos('recipient="',sstat)>0 then
              SBPHONE:= fnCutFromTo(sstat, 'recipient="', '"',false)
            else
              SBPHONE:= fnCutFromTo(sstat, 'phone="', '"',false);
            status:= fnCutFromTo(sstat, 'status="', '"',false);
            if pos('date="',sstat)>0 then
              datComp:= fnCutFromTo(sstat, 'date="', '"',false)
            else
              datComp:= fnCutFromTo(sstat, 'modifyDateTime="', '"',false);
            if datComp='' then
              datComp:= fnCutFromTo(sstat, 'startDateTime="', '"',false);

            i:= SLGroup.IndexOf(SBPHONE);
            if i=-1 then i:= SLGroup.IndexOf(copy(SBPHONE,3,length(SBPHONE)));
            if i=-1 then i:= SLGroup.IndexOf('+'+SBPHONE);
            if i>-1 then
            try
              SBCODE:= integer(SLGroup.Objects[i]);
              with GBIBSQLUp.Transaction do if not InTransaction then StartTransaction; 
              if datComp='' then
                GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= SBSENDDATE
              else 
                GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= datCompToDateTime(datComp);
              i:= fnInStrArray(status,arState);
              if i<9{status='DELIVERED'} then begin
                GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= i;
                if (i>=2) or ((datComp<>'') and (Date()-datCompToDateTime(datComp)>2)) then begin 
                  if ((datComp<>'') and (Date()-datCompToDateTime(datComp)>2)) then begin
                    GBIBSQLUp.ParamByName('pSBERROR').AsString:= 'VLAD: '+'Сообщение не доставлено.';
                    SLBody.Add('Vlad. Error of SMS! Phone '+SBPHONE+': '+'Сообщение не доставлено.');
                  end
                  else
                    GBIBSQLUp.ParamByName('pSBERROR').AsString:= arStateR[i];
                  if i>2 then SLBody.Add('Error of SMS! Phone '+SBPHONE+': '+arStateR[i]);                  
                end
                else GBIBSQLUp.ParamByName('pSBERROR').AsString:='';
              end
              else if i>8 then begin
                GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= -1;
                GBIBSQLUp.ParamByName('pSBERROR').AsString:= '';//arStateR[i];
              end;
              GBIBSQLUp.ParamByName('pSBCODE').AsInteger:= SBCODE;  
              GBIBSQLUp.ExecQuery;
              GBIBSQLUp.Transaction.Commit;
              GBIBSQLUp.Close;
            except
              on E: Exception do begin
                GBIBSQLUp.Transaction.Rollback;
                prMessageLOGS('Ошибка обновления базы '+nmProc+' '+ E.Message, 'error', true) ;
                prMessageLOGS('Phone='+SBPHONE+'; campaignID='+IntToStr(SBCAMPID)+'date='+datComp, 'error', true) ;
              end;
            end;
            if i>2 then  SLBody.Add('Error of SMS! Phone '+SBPHONE+': '+arStateR[i]);
          end;
          SLGroup.Clear;
          jsonToSend.Clear;
        end;
        SBCAMPID:= GBIBSQL.FieldByName('SBCAMPID').AsInteger;
        SBCODE:= GBIBSQL.FieldByName('SBCODE').AsInteger;
        SBPHONE:= GBIBSQL.FieldByName('SBPHONE').AsString;
        SBSENDDATE:= GBIBSQL.FieldByName('SBSENDDATE').AsDateTime;
        SLGroup.AddObject(SBPHONE,Pointer(SBCODE));
        TestCssStopException; 
        GBIBSQL.Next;
      end;
//prMessageLOGS(nmProc+' GBIBSQL.ExecQuery 1','error' , false);        
      if (SLGroup.Count>0) then begin
        if SLGroup.Count>1 then begin
          jsonToSend.Add('<?xml version="1.0" encoding="utf-8"?>');
          jsonToSend.Add('<request>');
          jsonToSend.Add('<operation>GETCAMPAIGNDETAIL</operation>');
          jsonToSend.Add('<message campaignID="'+IntToStr(SBCAMPID)+'" />');
          jsonToSend.Add('</request>');
        end;
        if SLGroup.Count=1 then begin
          jsonToSend.Add('<?xml version="1.0" encoding="utf-8"?>');
          jsonToSend.Add('<request>');
          jsonToSend.Add('<operation>GETMESSAGESTATUS</operation>');
          jsonToSend.Add('<message campaignID="'+IntToStr(SBCAMPID)+'" recipient="'+SBPHONE+'" />');
          jsonToSend.Add('</request>');
        end;
prMessageLOGS(nmProc+' отпр: '+jsonToSend.Text,'testSMS' , false);            
          Stream:=TStringStream.Create(jsonToSend.Text, TEncoding.UTF8);
          ss:= http.Post(TIdUri.UrlEncode('http://svitsms.com/api/api.php'), Stream);
          Application.ProcessMessages;
prMessageLOGS(nmProc+' ответ: '+ss,'testSMS' , false);
          Stream.Clear;
          while True do begin
            sstat:= fnCutFromTo(ss, '<message', '</message>',true);
            if sstat='' then break;
            if pos('recipient="',sstat)>0 then
              SBPHONE:= fnCutFromTo(sstat, 'recipient="', '"',false)
            else
              SBPHONE:= fnCutFromTo(sstat, 'phone="', '"',false);
            status:= fnCutFromTo(sstat, 'status="', '"',false);
            if pos('date="',sstat)>0 then
              datComp:= fnCutFromTo(sstat, 'date="', '"',false)
            else
              datComp:= fnCutFromTo(sstat, 'modifyDateTime="', '"',false);
            if datComp='' then
              datComp:= fnCutFromTo(sstat, 'startDateTime="', '"',false);
            i:= SLGroup.IndexOf(SBPHONE);
            if i=-1 then i:= SLGroup.IndexOf(copy(SBPHONE,3,length(SBPHONE)));
            if i=-1 then i:= SLGroup.IndexOf('+'+SBPHONE);
            if i>-1 then
            try
              SBCODE:= integer(SLGroup.Objects[i]);
              with GBIBSQLUp.Transaction do if not InTransaction then StartTransaction; 
              if datComp='' then
                GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= SBSENDDATE
              else 
                GBIBSQLUp.ParamByName('pSBSENDDATE').AsDateTime:= datCompToDateTime(datComp);
              i:= fnInStrArray(status,arState);
              if i<9{status='DELIVERED'} then begin
                GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= i;
                if (i>=2) or ((datComp<>'') and (Date()-datCompToDateTime(datComp)>2)) then begin 
                  if ((datComp<>'') and (Date()-datCompToDateTime(datComp)>2)) then begin
                    GBIBSQLUp.ParamByName('pSBERROR').AsString:= 'VLAD: '+'Сообщение не доставлено.';
                    SLBody.Add('Vlad. Error of SMS! Phone '+SBPHONE+': '+'Сообщение не доставлено.');
                  end
                  else
                    GBIBSQLUp.ParamByName('pSBERROR').AsString:= arStateR[i];
                  if i>2 then SLBody.Add('Error of SMS! Phone '+SBPHONE+': '+arStateR[i]);                  
                end
                else GBIBSQLUp.ParamByName('pSBERROR').AsString:='';
              end
              else if i>8 then begin
                GBIBSQLUp.ParamByName('pSBSTATE').AsInteger:= -1;
                GBIBSQLUp.ParamByName('pSBERROR').AsString:= '';//arStateR[i];
              end;
              GBIBSQLUp.ParamByName('pSBCODE').AsInteger:= SBCODE;              
              GBIBSQLUp.ExecQuery;
              GBIBSQLUp.Transaction.Commit;
              GBIBSQLUp.Close;
            except
              on E: Exception do begin
                GBIBSQLUp.Transaction.Rollback;
                prMessageLOGS('Ошибка обновления базы '+nmProc+' '+ E.Message, 'error', true) ;
                prMessageLOGS('Phone='+SBPHONE+'; campaignID='+IntToStr(SBCAMPID)+'date='+datComp, 'error', true) ;
              end;
            end;
          end;
          SLGroup.Clear;
        end;
    except
      on e: exception do  begin
        prMessageLOGS(nmProc+' Ошибка при обработке результатов запроса: '+e.Message,'error' , true);
      end;
    end;
  finally
prMessageLOGS(nmProc+' finally ','testSMS' , false);    
    if SLBody.Count>0 then begin
//      Addrs:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue;      >> 21.09.2016 12:34:30  Чичков Валерий wrote: >> Поменяйте, плз на payment@vladislav.ua
      Addrs:= pIniFile.ReadString('svitSMS', 'Mails', '');
      ss:= n_SysMailSend(Addrs, 'SMS Error', SLBody, nil, cNoReplayEmail, '', true);
      if ss<>'' then
        prMessageLOGS(nmProc+' Ошибка при отправке email: '+ss,'error' , true);
    end;
    prFreeIBSQL(GBIBSQL);
    prFreeIBSQL(GBIBSQLUp);
    if assigned(IBGRB) then cntsGRB.SetFreeCnt(IBGRB, True);
    if assigned(IBGRBUp) then cntsGRB.SetFreeCnt(IBGRBUp, True);
    prFree(jsonToSend);
    prFree(SLGroup);
    prFree(SLBody);
    prFree(HTTP);
    prFree(pIniFile);
    prFree(Stream);
  end;
end;
//******************************************************************************
//                           TCheckSMSThread
//******************************************************************************
procedure TCheckSMSThread.WorkProc;
const nmProc = 'TCheckSMSThread_WorkProc'; // имя процедуры/функции/потока
var fOpen: boolean;
    rIniFile: TINIFile;
    
  procedure prSleep;
  var i: Integer;
  begin
    for i:= 1 to 3 do begin
      Application.ProcessMessages; // без этого нельзя завершить процесс
      TestCssStopException;
      sleep(331);
    end;
  end;    
begin
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  try try
    CycleInterval:= rIniFile.ReadInteger('intervals', 'CheckSMSInterval', 30)*60;     //min to sec
    if rIniFile.ReadInteger('threads', 'CheckSMS', 0)=0 then exit;

    fOpen:= (appStatus in [stWork]) and (cntsGRB.BaseConnected);
    if fOpen then  prSendSMS(ThreadData);

    Application.ProcessMessages;
    TestCssStopException;
    sleep(997);

//prMessageLOGS(nmProc+'WorkProc prTestSMS начало ','error' , false);
    if fOpen then  prTestSMS(ThreadData);    

  except
    on E:Exception do 
      prMessageLOG(nmProc+' - внутренний охватывающий try '+E.Message);
  end;
  finally
    prFree(rIniFile);
  end;
end; // WorkProc
//==============================================================================
constructor TCheckSMSThread.Create(CreateSuspended: Boolean; AThreadType: integer);
const nmProc = 'TCheckSMSThread'; // имя процедуры/функции/потока
var balance: real;
    SLBody: TStringList;
    pIniFile: TINIFile;
    Addrs,ss : string;
    UserID: integer;
begin
  inherited Create(CreateSuspended, AThreadType);
  SLBody:= nil;
  pIniFile:= nil;
  ThreadName:= 'thCheckSMSThread';
  DateMail:= 0;
  prSetThLogParams(ThreadData, 0, 0, 0, ThreadName); // логирование в ib_css
  prMessageLOG(nmProc+': Запуск потока отправки СМС');
(*  pIniFile:= TINIFile.Create(nmIniFileBOB);
  try
  if pIniFile.ReadFloat('svitSMS', 'minBalance', -1)>0 then  
    if date()> Cache.GetConstItem(pcLastDateTime_SMSerr).DateValue then begin
      SLBody:= TStringList.Create;  
      balance:= fnTestBalance;
      if balance<pIniFile.ReadFloat('svitSMS', 'minBalance', 100) then begin
        SLBody.Add('Баланс на отправку СМС ниже установленного: '+FloatToStr(balance)+ ' Срочно пополните счет!!!');
//        Addrs:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue;    >> 21.09.2016 12:34:30  Чичков Валерий wrote: >> Поменяйте, плз на payment@vladislav.ua
        Addrs:= IniFile.ReadString('mails', 'svitSMS', '');
        ss:= n_SysMailSend(Addrs, 'SMS Error Balance', SLBody, nil, cNoReplayEmail, '', true);
        if ss<>'' then prMessageLOGS(nmProc+' Ошибка при отправке email: '+ss,'TestSMS' , true);
        UserID:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
        Cache.SaveNewConstValue(pcLastDateTime_SMSerr, UserID, System.SysUtils.DateToStr(now));
      end;
    end; 
  finally
    prFree(SLBody);  
    prFree(pIniFile);
  end;   *)
end;
//==============================================================================
procedure TCheckSMSThread.DoTerminate;
begin
  inherited;
  prMessageLOG(ThreadName+': Завершение потока отправки СМС');
end;


end.
