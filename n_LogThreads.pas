unit n_LogThreads;

interface
uses SysUtils, Classes, Forms, DateUtils, IBDataBase, IBQuery, IBSQL,
     SyncObjs, IdTCPServer, n_free_functions, v_constants, n_constants;

type
  TlmText = record // для хранения последнего набора сообщений каждого типа
    lmCODE      : integer; // код последней записи в LOGMESSAGES
    MyText      : String;
    EMessageText: String;
    CommentText : String;
  end;

  TThreadData = class
  public
    thCommand: integer;
    ID       : integer;
    IDuser   : integer;
    pProcess : Pointer;
    thParams : String; // текст параметра потока
    lmTexts  : array [lgmsInfo..lgmsSysMess] of TlmText; // сообщения по типам
    constructor Create;
    destructor Destroy; override;
  end;

var
  ServerID: integer;           // код данного экземпляра сервера из таблицы LOGSERVERLIST
  MainThreadData: TThreadData; // Данные для логирования главного потока программы
  manycntsTime: TDateTime;     // время последнего сообщения "many connections"
  CSlog: TCriticalSection;     // защита от одновременного срабатывания fnCreateThread
  WorkThreadDataIDs: TIntegerList;
  strDelim1_45, strDelim2_45: String;

//---------------------- новые функции
 function fnGetServerID: integer;
procedure prSetThLogParams(ThreadData: TThreadData; COMMAND: integer=0;   // записывает/добавляет параметры потока
          pUSERID: integer=0; FIRMID: integer=0; PARAMS: string=''; plus: Boolean=True);
 function fnWriteMessageToLog(ThreadData: TThreadData; MessType: integer; // записывает/добавляет сообщение
          ProcName, MyText, EMessageText, CommentText: string; plus: Boolean=false): boolean;
//---------------------- доработанные функции ВЧ
 function fnCreateThread(ThreadType: integer; Command: Integer=0): TThreadData; // Создает поток и возвращает его ID и открытое Query
procedure prDestroyThreadData(ThreadData: TThreadData; ProcName: string); // записывает в лог время завершения потока и освобождает память ThreadData
 function fnSignatureToThreadType(Signature: integer): integer; // Переводит сигнатуру в тип потока
procedure fnWriteToLog(ThreadData: TThreadData; MessType: integer; ProcName, MyText, EMessageText, CommentText: string); // запись в лог
//---------------------- доработанные функции НК
procedure fnWriteToLogPlus(ThreadData: TThreadData; MessType: integer; ProcName: string; MyText: string='';
          EMess: string=''; CommText: string=''; plus: Boolean=True; logf: string='error');

 procedure TestConnections(flZero: boolean=False; flDSlist: boolean=False; NameLog: String='');  // проверка соединений с БД

implementation
uses n_server_common, n_DataSetsManager, n_DataCacheInMemory;
//======================================================
function fnGetServerID: integer;    // логирование в ib_css
const nmProc = 'fnGetServerID'; // имя процедуры/функции
var ibs: TIBSQL;
    ibd: TIBDatabase;
begin
  Result:= 0;
  if not cntsLog.BaseConnected then Exit;
  ibd:= nil;
  ibs:= nil;
  try try
    ibd:= cntsLog.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, true);
    ibs.SQL.Text:= 'select NewSELLCODE from GetLogServerID(:pSELLSERVER, :pSELLPATH)';
    ibs.ParamByName('pSELLSERVER').AsString:= fnGetComputerName;
    ibs.ParamByName('pSELLPATH').AsString:= AnsiUpperCase(ParamStr(0));
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then begin
      Result:= ibs.FieldByName('NewSELLCODE').AsInteger;
      if ibs.Transaction.InTransaction then ibs.Transaction.Commit;
    end;
  except
    on E:Exception do begin
      prMessageLOGS(nmProc+': '+E.Message);
      Result:= 0;
    end;
  end;
  finally
    prFreeIBSQL(ibs);
    cntsLog.SetFreeCnt(ibd);
  end;
end;
//==================================================
constructor TThreadData.Create;
var i: Integer;
    tmt: TlmText;
begin
  inherited Create;
  ID:= 0;
  IDuser:= 0;
  pProcess:= nil;
  thCommand:= 0;
  thParams:= ''; // текст параметра потока
  for i:= Low(lmTexts) to High(lmTexts) do begin // сообщения по типам
    tmt:= lmTexts[i];
    tmt.lmCODE:= 0;
    tmt.MyText:= '';
    tmt.EMessageText:= '';
    tmt.CommentText:= '';
  end;
end;
//==================================================
destructor TThreadData.Destroy;
begin
  inherited Destroy;
end;

//************************* логирование в ib_css *******************************
//======================================= Создает и возвращает поток логирования
function fnCreateThread(ThreadType: integer; Command: Integer=0): TThreadData;
const nmProc = 'fnCreateThread'; // имя процедуры/функции
var i, newID: integer;
    ibd: TIBDatabase;
    ibs: TIBSQL;
begin
//  ibd:= nil;
  ibs:= nil;
  newID:= 0;
  Result:= TThreadData.Create;
  if not cntsLog.BaseConnected or (ServerID<1) then Exit;
  try
    ibd:= cntsLog.GetFreeCnt;             // логирование в ib_css
    try
      ibs:= fnCreateNewIBSQL(ibd, 'TD_ibs', -1, tpWrite, True);
      ibs.SQL.Text:= 'select NewTHLGCODE from CreateThreadLog('+IntToStr(ThreadType)+
                     ', '+IntToStr(Command)+', :pTIME, '+IntToStr(ServerID)+')';
      ibs.ParamByName('pTIME').AsDateTime:= Now;
      for i:= 1 to RepeatCount do try
        ibs.Close;
        if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
        ibs.ExecQuery;
        if (ibs.Bof and ibs.Eof) or (ibs.Fields[0].AsInteger<1) then
          raise Exception.Create('Empty NewTHLGCODE');
        newID:= ibs.FieldByName('NewTHLGCODE').AsInteger;
        if (newID>0) and (WorkThreadDataIDs.IndexOf(newID)>-1) then
          raise Exception.Create('Duplicate NewTHLGCODE');
        if ibs.Transaction.InTransaction then ibs.Transaction.Commit;
        break;
      except
        on E:Exception do begin
          if ibs.Transaction.InTransaction then ibs.Transaction.RollbackRetaining;
          prMessageLOGS(nmProc+': CreateThreadLog error, try '+IntToStr(i)+#13#10+E.Message);
          if (i<RepeatCount) then sleep(101) else newID:= -1;
        end;
      end;
    finally
      prFreeIBSQL(ibs);
      cntsLog.SetFreeCnt(ibd);
    end;

    CSlog.Enter;
    try
      if (newID>0) and (WorkThreadDataIDs.IndexOf(newID)<0) then
        WorkThreadDataIDs.Add(newID)
      else newID:= -1;
      Result.ID:= newID;
      if (Command<>0) then Result.thCommand:= COMMAND;
    finally
      CSlog.Leave;
    end;
  except
    on E:Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
end;
//==============================================================================
// записывает в лог время завершения потока и освобождает память ThreadData
procedure prDestroyThreadData(ThreadData: TThreadData; ProcName: string);
const nmProc = 'prDestroyThreadData'; // имя процедуры/функции
var nq: string;
    i, tdID: integer;
    ibd: TIBDatabase;
    ibs: TIBSQL;
begin
  if not Assigned(ThreadData) then Exit;
//  ibd:= nil;
  ibs:= nil;
  try
    tdID:= ThreadData.ID;
    CSlog.Enter;
    try
      if (tdID>0) then WorkThreadDataIDs.Remove(tdID);
      prFree(ThreadData);
    finally
      CSlog.Leave;
    end;
    if not cntsLog.BaseConnected or (tdID<1) then Exit;

    ibd:= cntsLog.GetFreeCnt;
    try
      ibs:= fnCreateNewIBSQL(ibd, 'TD_ibs', -1, tpWrite);
      if Assigned(ibs) then begin
        ibs.Transaction.StartTransaction;
        ibs.SQL.Text:= 'execute procedure SetThreadLogEnd(:THLGCODE, :THLGENDTIME)';
        ibs.ParamByName('THLGCODE').asInteger:= tdID;
        ibs.ParamByName('THLGENDTIME').AsDateTime:= Now();
        nq:= ibs.Name;
        for i:= 1 to RepeatCount do try // RepeatCount попыток
          if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
          ibs.ExecQuery;
          ibs.Transaction.Commit;
          break;
        except
          on E:Exception do begin
            if ibs.Transaction.InTransaction then ibs.Transaction.RollbackRetaining;
            prMessageLOGS(nmProc+': '+ProcName+': error save THLGENDTIME, '+nq+', try '+IntToStr(i));
            if i<RepeatCount then sleep(101); // если сбой - пробуем повторить
          end;
        end;
      end;
    finally
      prFreeIBSQL(ibs);
      cntsLog.SetFreeCnt(ibd);
    end;
  except
    on E:Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
end;
//=============================== записывает/добавляет параметры потока в ib_css
procedure prSetThLogParams(ThreadData: TThreadData; COMMAND: integer=0;
  pUSERID: integer=0; FIRMID: integer=0; PARAMS: string=''; plus: Boolean=True);
const nmProc = 'prSetThLogParams'; // имя процедуры/функции
var i: Integer;
    s, sID, sCommand, sFirm, sUser: String;
    ibd: TIBDatabase;
    ibQuery: TIBQuery; // для AsMemo
begin
  ibQuery:= nil;
  ibd:= nil;
  if (FIRMID=isWe) then FIRMID:= 0;

  if not cntsLog.BaseConnected or not Assigned(ThreadData) or (ThreadData.ID<1) or
    ((COMMAND=0) and (pUSERID=0) and (FIRMID=0) and (PARAMS='')) then Exit;

  try //----------------------------------------------------------- пишем в базу
    sID:= IntToStr(ThreadData.ID);
    sCommand:= IntToStr(COMMAND);
    sFirm:= IntToStr(FIRMID);
    sUser:= IntToStr(pUSERID);
    if (COMMAND<>0) then ThreadData.thCommand:= COMMAND;
    try
      try
        ibd:= cntsLog.GetFreeCnt;
      except
        Exit;
      end;
      ibQuery:= fnCreateNewIBQuery(ibd, 'TD_ibQuery', -1, tpWrite);
      s:= '';
      if (PARAMS<>'') then begin
        if plus then s:= ThreadData.thParams; // если дописывать
        s:= s+fnIfStr(s<>'', #13#10, '')+PARAMS;
      end;
      if ibQuery.Active then ibQuery.Close;
      if (ibQuery.ParamCount>0) then ibQuery.Params.Clear;
      ibQuery.SQL.Text:= 'select rTHLGPARAMS from SetThreadLogParamsR('+sID+', '+
        fnIfStr(s<>'', ':PARAMS,', 'null,')+' '+sCommand+', '+sUser+', '+sFirm+')';
      if (s<>'') then ibQuery.ParamByName('PARAMS').AsMemo:= s;
      for i:= 1 to RepeatCount do try
        ibQuery.Open;
        s:= ibQuery.FieldByName('rTHLGPARAMS').AsString;
        if ibQuery.Transaction.InTransaction then ibQuery.Transaction.Commit;
        ThreadData.thParams:= s;
        break;
      except
        on E:Exception do begin
          if ibQuery.Transaction.InTransaction then ibQuery.Transaction.RollbackRetaining;
          if (i<RepeatCount) then sleep(101)
          else begin
            prMessageLOGS(nmProc+': ExecSQL Error: '+E.Message);
            prMessageLOGS(nmProc+': COMMAND='+sCommand+', FIRMID='+sFirm+
              ', USERID='+sUser+fnIfStr(s<>'', ': Params='+s, ''));
          end;
        end; // on E:Exception
      end; // except (for)
      if ibQuery.Active then ibQuery.Close;
    finally
      prFreeIBQuery(ibQuery);
      cntsLog.SetFreeCnt(ibd);
    end;
//------------------------------------------------------------ счетчик коннектов
    if (ThreadData.IDuser>0) or (pUSERID<1) or not Cache.ClientExist(pUSERID) then Exit;
    if (FIRMID<1) or (FIRMID=isWe) then Exit;
    if (ThreadData.thCommand<1) or (ThreadData.thCommand=csWebAutentication)
      or (ThreadData.thCommand=csBackJobAutentication) then Exit;

    ThreadData.IDuser:= pUSERID;
    Cache.arClientInfo[pUSERID].CheckConnectCount;
  except
    on E:Exception do prMessageLOGS(nmProc+': Alert! - '+E.Message);
  end;
end;
//====================================== записывает/добавляет сообщение в ib_css
function fnWriteMessageToLog(ThreadData: TThreadData; MessType: integer;
         ProcName, MyText, EMessageText, CommentText: string; plus: Boolean=false): boolean;
const nmProc = 'fnWriteMessageToLog'; // имя процедуры/функции
var i, SCODE: Integer;
    s1, s2, s3, ss: String;
    fl1, fl2, fl3: Boolean;
    tmt: TlmText;
    ibd: TIBDatabase;
    ibQuery: TIBQuery; // для AsMemo
begin
  Result:= false;
  if not cntsLog.BaseConnected or not Assigned(ThreadData) or (ThreadData.ID<1) then Exit;
  SCODE:= 0;
  fl1:= MyText<>'';
  fl2:= EMessageText<>'';
  fl3:= CommentText<>'';
  if not (fl1 or fl2 or fl3) then Exit; // если нечего писать - выходим
  ibQuery:= nil;
  ibd:= nil;
  with ThreadData do try try
    try
      ibd:= cntsLog.GetFreeCnt;
    except
      Exit;
    end;
    s1:= '';
    s2:= '';
    s3:= '';
    tmt:= lmTexts[MessType];
    if plus then begin // если дописывать
      SCODE:= tmt.lmCODE;
      if fl1 then s1:= tmt.MyText;
      if fl2 then s2:= tmt.EMessageText;
      if fl3 then s3:= tmt.CommentText;
    end;
    if fl1 then s1:= s1+fnIfStr(s1<>'', #13#10, '')+MyText;
    if fl2 then s2:= s2+fnIfStr(s2<>'', #13#10, '')+EMessageText;
    if fl3 then s3:= s3+fnIfStr(s3<>'', #13#10, '')+CommentText;
    ibQuery:= fnCreateNewIBQuery(ibd, 'TD_ibQuery', ID, tpWrite);
    if not Assigned(ibQuery) then Exit;
    ss:= 'select NewLGMSCODE from SaveMessageToLog(:id, :idth, :TIME, :PROC,'+
      fnIfStr(fl1, ' :MYMES,', ' null,')+fnIfStr(fl2, ' :EMESS,', ' null,')+
      fnIfStr(fl3, ' :COMM,', ' null,')+' :TYPE)';
    ibQuery.SQL.Text:= ss;
    ibQuery.ParamByName('id').AsInteger:= SCODE;               // код строки (если 0 - создается новая запись)
    ibQuery.ParamByName('idth').AsInteger:= ID;                // код потока
    ibQuery.ParamByName('TIME').AsDateTime:= Now;              // дата и время сообщения
    ibQuery.ParamByName('PROC').asString:= ProcName;           // Имя процедуры
    if fl1 then ibQuery.ParamByName('MYMES').AsMemo:= s1;      // Наш текст
    if fl2 then ibQuery.ParamByName('EMESS').AsMemo:= s2;      // Текст ошибки из E.Message
    if fl3 then ibQuery.ParamByName('COMM').AsMemo:= s3;       // Примечание (например, текст SQL)
    ibQuery.ParamByName('TYPE').AsInteger:= MessType;          // Код типа сообщения
    for i:= 1 to RepeatCount do try
      if ibQuery.Active then ibQuery.Close;
      ibQuery.Open;
      if not (ibQuery.Bof and ibQuery.Eof) and
        (SCODE<>ibQuery.FieldByName('NewLGMSCODE').AsInteger) then
        SCODE:= ibQuery.FieldByName('NewLGMSCODE').AsInteger;
      if ibQuery.Transaction.InTransaction then ibQuery.Transaction.Commit;
      Result:= true;
      if (lmTexts[MessType].lmCODE<>SCODE) then lmTexts[MessType].lmCODE:= SCODE;
      if fl1 then tmt.MyText      := s1;
      if fl2 then tmt.EMessageText:= s2;
      if fl3 then tmt.CommentText := s3;
      break;
    except
      on E:Exception do begin
        if ibQuery.Transaction.InTransaction then ibQuery.Transaction.RollbackRetaining;
        prMessageLOGS(nmProc+': error save message, try '+IntToStr(i)+': '+E.Message);
        if (i<RepeatCount) then sleep(101);
      end;
    end;
  finally
    prFreeIBQuery(ibQuery);
    cntsLog.SetFreeCnt(ibd);
  end;
  except
    on E:Exception do prMessageLOGS(nmProc+': Alert! - '+E.Message);
  end;
end;
//******************************************************************************

//================================================================= запись в лог
procedure fnWriteToLog(ThreadData: TThreadData; MessType: integer; ProcName, MyText, EMessageText, CommentText: string);
const nmProc = 'fnWriteToLog'; // имя процедуры/функции
var s, mess: String;
    ch: Char;
begin
  if fnWriteMessageToLog(ThreadData, MessType, ProcName, MyText, EMessageText, CommentText) // логирование в ib_css
    and not (MessType in [lgmsSysError, lgmsSysMess, lgmsCryticalSysError]) then Exit;

  if ((AppStatus in [stSuspending, stSuspended]) // если остановлены и сообщение из Server*Connect - не пишем в текст.лог
    and ((pos('Server', ProcName)>0) and (pos('Connect', ProcName)>0))) or // если Сервер перегружен - не пишем в текст.лог
    ((AppStatus=stWork) and (pos('Сервер перегружен', EMessageText)>0)) then Exit;

  try
    mess:= fnIfStr(MyText='', '', 'MyText: '+MyText);
    if EMessageText<>'' then begin
      ch:= EMessageText[1];   //  length(EMessageText)
      if not SysUtils.CharInSet(ch, [#13, #10]) then s:= #13#10 else s:= '';
      mess:= mess+fnIfStr(mess='', '', s)+'error: '+EMessageText;
    end;
    if CommentText<>'' then
      mess:= mess+fnIfStr(mess='', '', #13#10)+'Comment: '+CommentText;
    prMessageLOGS(ProcName+': '+mess);
  except end;
end;
//==============================================================================
function fnSignatureToThreadType(Signature: integer): integer;
begin
  case Signature of
    csOldAutorizeSignature: Result:= thtpOldAutorize;
    csAutorizeSignature   : Result:= thtpAutorize;
    csPingSignature       : Result:= thtpPing;
    csCommonSignature     : Result:= thtpArm;
    csOnlineOrder         : Result:= thtpWeb;
    csWebArm              : Result:= thtpWebArm;
    else                    Result:= thtpUnknown;
  end;
end;
//============================= добавляет тексты к последней записи LOG-а потока
procedure fnWriteToLogPlus(ThreadData: TThreadData; MessType: integer; ProcName: string; MyText: string='';
          EMess: string=''; CommText: string=''; plus: Boolean=True; logf: string='error');
var err: boolean;
begin
  err:= not fnWriteMessageToLog(ThreadData, MessType, ProcName, MyText, EMess, CommText, plus); // логирование в ib_css
  if not (err or (MessType in [lgmsSysError, lgmsSysMess, lgmsCryticalSysError])) then Exit;
  prMessageLOGS(fnIfStr(ProcName='', '', ProcName+': ')+MyText+
    fnIfStr(EMess='', '', #10+EMess)+fnIfStr(CommText='', '', #10+CommText), logf);
end;

//==============================================================================
procedure TestConnections(flZero: boolean=False; flDSlist: boolean=False; NameLog: String='');  // проверка соединений с БД
// flZero=True - выводить DataSetCount=0, flDSlist=True - выводить список DataSets
var i, j, ii: integer;
    s, cm, ss: string;
    p: Pointer;
    Body: TStringList;
begin
  s:= '';
  Body:= nil;
  ii:= 100; // число коннектов, после которого отсылать сообщение админу
  if NameLog='' then NameLog:= 'TestConns';
  try
    with DataSetsManager do for j:= Low(Cnts) to High(Cnts) do try
      p:= GetCntsItemPointer(j);
      if not Assigned(p) then Continue;
      cm:= TComponent(p).Name;
      if (TComponent(p) is TIDTCPServer) and not flDSlist then begin // TIDTCPServer
        i:= fnGetThreadsCount(TIDTCPServer(p));
        if cm='' then cm:= 'TIDTCPServer';
        if i>ii then begin
          if not Assigned(Body) then Body:= TStringList.Create;
          Body.Add('many Contexts: '+cm+'.Contexts.Count = '+IntToStr(i));
        end;
        if flZero or (i>0) then
          s:= s+fnIfStr(s='', ' ', #13#10+StringOfChar(' ', 18))+cm+'.Contexts.Count = '+IntToStr(i);
      end;
    except
      on E: Exception do prMessageLOGS('TestConnections: '+cm+' '+E.Message, NameLog);
    end;

    cntsGRB.TestCntsState(s, ii, Body);    // формируем строку по cntsGRB
    cntsORD.TestCntsState(s, ii, Body);    // формируем строку по cntsORD
    cntsLOG.TestCntsState(s, ii, Body);    // формируем строку по cntsLOG
    cntsTDT.TestCntsState(s, ii, Body);    // формируем строку по cntsTDT
    cntsSUF.TestCntsState(s, ii, Body);    // формируем строку по cntsSUF
    cntsSUFORD.TestCntsState(s, ii, Body); // формируем строку по cntsSUFORD
    cntsSUFLOG.TestCntsState(s, ii, Body); // формируем строку по cntsSUFLOG

    if Assigned(Body) and (Body.Count>0) and ((manycntsTime=DateNull) or (Now>IncMinute(manycntsTime, 5))) then begin
      manycntsTime:= Now;                          // отправить сообщение админу
      prMessageLOGS('many connections:'#13#10+ss, NameLog);
      Body.Insert(0, FormatDateTime(' '+cDateTimeFormatY2S+' ', manycntsTime)+
       ' - many connections ('+fnGetComputerName+', '+Application.Name+')');
      ss:= Cache.GetConstEmails(pcEmplORDERAUTO);
      if ss='' then ss:= fnGetSysAdresVlad(caeOnlyDayLess);
      Body.Insert(0, GetMessageFromSelf);
      ss:= n_SysMailSend(ss, 'many connections', Body, nil, '', '', true);
      if (ss<>'') then prMessageLOGS('Ошибка отправки письма о коннектах: '#13#10+ss, NameLog)
      else prMessageLOGS('send mail to admin', NameLog);
    end;
  finally
    prFree(Body);
  end;
  if s<>'' then begin  // выводим в лог
    prMessageLOGS(strDelim1_45, NameLog, false);
    prMessageLOGS(s, NameLog, false);
    prMessageLOGS(strDelim1_45, NameLog, false);
  end;
end;

//******************************************************************************
initialization
begin
  manycntsTime:= DateNull;
  CSlog:= TCriticalSection.Create;
  WorkThreadDataIDs:= TIntegerList.Create;
  strDelim1_45:= StringOfChar('-', 45);
  strDelim2_45:= StringOfChar('=', 45);
end;
finalization
begin
  prFree(CSlog);
  prFree(WorkThreadDataIDs);
end;
//******************************************************************************

end.
