unit n_CSSThreads;

interface
uses Windows, Classes, SysUtils, IniFiles, Forms, DateUtils, System.Math,
     IdTCPServer, IBDatabase, IBSQL,
     n_free_functions, v_constants, v_DataTrans,
     n_LogThreads, n_DataSetsManager, n_DataCacheInMemory, n_constants, n_server_common;

type
//------------------------------------------------------------------------------
  TTestCacheThread = class (TThread)   // заготовка
  private { Private declarations }
    FExpress: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(aExpress: Boolean);
  end;

//------------------------------------------------------------------------------
  TManageCommand = record // команды, управляющие сервером
    Command: integer;
    IP: string; // IP сервера, отправившего команду
  end;

  TManageThread = class (TThread)
  protected
    CycleInterval: integer; // Интервал повторяемости в секундах
    procedure Execute; override;
    procedure StopAll;
  public

  end;

//------------------------------------------------------------------------------
  TSingleThread = class (TThread) // одноразовый поток
  private { Private declarations }
    FKind: Byte;
  protected
    procedure Execute; override;
    procedure DoTerminate; override;
  public
    constructor Create(aKind: Byte=0; aSuspended: Boolean=False);
  end;

//------------------------------------------------------------------------------
  TCSSCyclicThread = class(TThread)
  private { Private declarations }
    function GetStatus: integer;
  protected
    CycleInterval: integer; // Интервал повторяемости в секундах
    FStopFlag: boolean;
    FSafeSuspendFlag: boolean;
    ThreadData: TThreadData;
    ThreadType: integer;
    ThreadName: string;
    procedure WorkProc; virtual; abstract;
    procedure Execute; override;
    procedure DoTerminate; override;
  public
    ExpressFlag: boolean;  // флаг срочного выполнения WorkProc
    LastTime: TDateTime;   // время последнего запуска WorkProc
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure Stop;
    procedure SafeSuspend;
    procedure CSSSuspend; virtual;
    procedure CSSResume; virtual;
//  published
    property Terminated;
    property Status: integer read GetStatus;
  end;

//------------------------------------------------------------------------------
  TCheckDBConnectThread = class(TCSSCyclicThread)
  protected
    procedure WorkProc; override;
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
  end;

//------------------------------------------------------------------------------
  TCheckStoppedOrders = class(TCSSCyclicThread)
  private { Private declarations }
    Stream: TBOBMemoryStream;
  protected
    procedure WorkProc; override;
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
  end;

//------------------------------------------------------------------------------
  TTestMailFilesThread = class (TCSSCyclicThread) // поток отсылки писем из файлов
  private { Private declarations }
    FWroteToLog: boolean; // флаг вывода в лог сообщения об отсутствии соединения
  protected
    procedure WorkProc; override;
  public  { Public declarations }
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    destructor Destroy; override;
  end;
//------------------------------------------------------------------------------

var ErrorExit: boolean;                    // признак зависания потоков
    thTestMailFiles: TTestMailFilesThread; // отдельный поток для отсылки писем из файлов
    thTTestCache: TTestCacheThread;        // отдельный поток проверки кеша
    thSingleThread: TSingleThread;
    arManageCommands: array of TManageCommand;
    IniFile: TINIFile;

   function fnServerInit: boolean; // вызыывается до создания главной формы, выполняет подключения к ГроссБии, ADS и пр.
  procedure prServerExit; // вызыывается после всего, отключается от ГроссБии, ADS и пр.
  procedure prSafeSuspendAll; // приостанавливает все
  procedure prResumeAll; // стартует все, что должно стартовать

   function GetAllBasesConnected(conn: boolean=True; flSUF: boolean=False): boolean;
   function GetReadyWorkOrStop(Work: boolean=True): boolean;
   function GetMessageNotCanWorks: string;
//  procedure MemUsedToLog(comment: String); // память - вывод в лог
  procedure SendZeroPricesMail; // формирование списка товаров с нулевыми ценами

implementation

uses v_Functions, n_CSSservice, n_DataCacheObjects, n_IBCntsPool,
     t_ImportChecking, t_WebArmProcedures, t_CSSThreads;

//******************************************************************************
//                           TManageThread
//******************************************************************************
procedure TManageThread.StopAll;
begin
  StopServiceCSS; // остановка сервиса по требованию
end;
//==============================================================================
procedure TManageThread.Execute;
var i, j: integer;
    Command: TManageCommand;
begin
  while not (Application.Terminated or (AppStatus=stExiting)) do try

    if ServiceGoOut then begin // нужно, чтобы завершить сервис из PopupMenu, если застряли на инициализации
      if IsServiceCSS then Synchronize(StopAll) else Synchronize(Application.Terminate);
      Terminate;
      exit;
    end;

    if (Length(arManageCommands)>0) and not (AppStatus in [stSuspending, stResuming]) then begin
      while ManageCommandsLock do begin
        sleep(101);  // не продолжаем, пока список залочен
        Application.ProcessMessages;
      end;
      try
        ManageCommandsLock:= true;
        Command:= arManageCommands[0];
        for i:= Low(arManageCommands) to High(arManageCommands)-1 do
          arManageCommands[i]:= arManageCommands[i+1];
        SetLength(arManageCommands, Length(arManageCommands)-1);
      finally
        ManageCommandsLock:= false;
      end;

      case Command.Command of
        scSuspend: begin //---------------------------------------- приостановка
            if fnInStrArray(Command.IP, StopList)=-1 then begin
              SetLength(StopList, Length(StopList)+1);
              StopList[Length(StopList)-1]:= Command.IP;
              prMessageLOG('TManageThread.Execute: Сервер '+Command.IP+' добавлен в StopList.', 'system');
            end;
            if AppStatus=stWork then begin
              prMessageLOG('TManageThread.Execute: запускаю процедуру prSafeSuspendAll.', 'system');
              prSafeSuspendAll;
            end;
          end;
        scResume: begin //----------------------------------------------- запуск
            i:= fnInStrArray(Command.IP, StopList);
            if i>-1 then begin
              for j:= i to Length(StopList)-2 do StopList[j]:= StopList[j+1];
              SetLength(StopList, Length(StopList)-1);
              prMessageLOG('TManageThread.Execute: Сервер '+Command.IP+' удален из StopList.', 'system');
            end;
            if (AppStatus=stSuspended) and (Length(StopList)=0) then begin
              prMessageLOG('TManageThread.Execute: запускаю процедуру prResumeAll.', 'system');
              prResumeAll;
            end;
          end;
        scExit: begin //-------------------------------------------------- выход
            prMessageLOG('TManageThread.Execute: Завершаю работу по команде от '+Command.IP, 'system');
            ServiceGoOut:= True;                // устанавливаем флаг - Остановить
            if IsServiceCSS then Synchronize(StopAll) else Synchronize(Application.Terminate);
            Terminate;
            exit;
          end;
      end;
    end;
    sleep(997);
    Application.ProcessMessages;
  except
    on E:Exception do prMessageLOG('TManageThread.Execute '+E.Message);
  end;
end;

//******************************************************************************
//                           TCSSCyclicThread
//******************************************************************************
constructor TCSSCyclicThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended);
  ThreadType:= AThreadType;
  if not (ThreadType  in [thtpCheckDBConnect]) then
    ThreadData:= fnCreateThread(ThreadType);
  FStopFlag:= false;
  FSafeSuspendFlag:= false;
  ExpressFlag:= false; // флаг срочного выполнения WorkProc
  CycleInterval:= 30;
  LastTime:= 0;
end;
//==============================================================================
procedure TCSSCyclicThread.Stop;
begin
  FStopFlag:= true;
  if Suspended then Suspended:= False;
end;
//==============================================================================
procedure TCSSCyclicThread.SafeSuspend;
begin
  FSafeSuspendFlag:= true;
end;
//==============================================================================
procedure TCSSCyclicThread.Execute;
var i: integer;
begin
  While not FStopFlag do begin
    LastTime:= Now;
    WorkProc;
    ExpressFlag:= False; // флаг срочного выполнения WorkProc
    i:= 0;
    while (i<CycleInterval) and not FStopFlag and not FSafeSuspendFlag and not ExpressFlag do begin
      Inc(i);
      Sleep(997); // почти секунда (простое число - на всяк.случай)
      Application.ProcessMessages;
    end; // while (i<CycleInterval) and not FStopFlag
    if FSafeSuspendFlag then CSSSuspend;
  end; //While not FStopFlag do begin
  Terminate;
end;
//==============================================================================
procedure TCSSCyclicThread.DoTerminate;
begin
  if not (ThreadType  in [thtpCheckDBConnect]) then
    prDestroyThreadData(ThreadData, ThreadName);
//  inherited;
end;
//==============================================================================
procedure TCSSCyclicThread.CSSSuspend;
begin
  if not (ThreadType in [thtpCheckDBConnect]) and cntsLOG.BaseConnected then
    fnWriteToLog(ThreadData, lgmsInfo, ThreadName, 'Приостановка потока.', '', '');
  if not FStopFlag then begin
    FSafeSuspendFlag:= false;
    Suspended:= True;
  end;
end;
//==============================================================================
procedure TCSSCyclicThread.CSSResume;
begin
  Suspended:= False;
  if not (ThreadType in [thtpCheckDBConnect]) and cntsLOG.BaseConnected then
    fnWriteToLog(ThreadData, lgmsInfo, ThreadName, 'Запуск потока.', '', '');
end;
//==============================================================================
function TCSSCyclicThread.GetStatus: integer;
begin
  if Terminated then Result:= stthrdTerminated
  else if Suspended then Result:= stthrdSuspended
  else if FStopFlag then Result:= stthrdTerminating
  else if FSafeSuspendFlag then Result:= stthrdSuspending
  else Result:= stthrdWork;
end;

//******************************************************************************
//                           TCheckDBConnectThread
//******************************************************************************
procedure TCheckDBConnectThread.WorkProc;
const nmProc = 'TCheckDBConnectThread_WorkProc'; // имя процедуры/функции/потока
var fOpen: boolean;
    rIniFile: TINIFile;
begin
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  try try
    CycleInterval:= rIniFile.ReadInteger('intervals', 'CheckDBConnectInterval', 30);

    prSetPoolsRunParams(rIniFile); // считываем изменяемые параметры коннектов
    fOpen:= AppStatus in [stStarting, stWork, stResuming];
//------------------------------------------------- проверка соединения с базами
    cntsORD.CheckBaseConnection(CycleInterval, fOpen);
    cntsLOG.CheckBaseConnection(CycleInterval, fOpen);
    cntsGRB.CheckBaseConnection(CycleInterval, fOpen);
    if Cache.AllowWebArm then begin
      cntsTDT.CheckBaseConnection(CycleInterval, fOpen);
      cntsSUF.CheckBaseConnection(CycleInterval, fOpen);
      cntsSUFORD.CheckBaseConnection(CycleInterval, fOpen);
      cntsSUFLOG.CheckBaseConnection(CycleInterval, fOpen);
    end;

    RepeatSaveInterval:= rIniFile.ReadInteger('intervals', 'RepeatSaveInterval', 100); // интервал задержки попыток записи в мсек
    RepeatStopInterval:= rIniFile.ReadInteger('intervals', 'RepeatStopInterval', 5);   // интервал задержки ожидания остановки в сек
    accRepeatCount    := rIniFile.ReadInteger('intervals', 'accRepeatCount', 6);       // кол-во попыток посадки счета
//    FlagCachePath:= fnTestDirEnd(rIniFile.ReadString('service', 'FlagCachePath', '..\'));

    with Cache do begin
//      TestCacheAlterInterval:= rIniFile.ReadInteger('intervals', 'TestCacheAlterInterval', 5); // интервал проверки кэша по alter-таблицам в мин (кроме фирм и клиентов)
//      if (Now>IncMinute(LastTimeMemUsed, TestCacheInterval)) then MemUsedToLog('check mem');
//      flAccTimeToLog    := rIniFile.ReadInteger('Logs', 'AccTimeToLog', 0)=1;
      TestCacheInterval   := rIniFile.ReadInteger('intervals', 'TestCacheInterval', 30);   // интервал полной проверки кэша в мин (кроме фирм и клиентов)
      TestCacheNightInt   := rIniFile.ReadInteger('intervals', 'TestCacheNightInt', TestCacheInterval*3); // ночной интервал
      if (TestCacheNightInt<TestCacheInterval) then TestCacheNightInt:= TestCacheInterval; // ночной интервал не может быть меньше дневного
      FirmActualInterval  := rIniFile.ReadInteger('intervals', 'FirmActualInterval', 5);   // интервал актуальности кэша 1 фирмы в мин (кроме долгов)
      ClientActualInterval:= rIniFile.ReadInteger('intervals', 'ClientActualInterval', 5); // интервал актуальности кэша 1 клиента в мин
      flSendZeroPrices    := rIniFile.ReadInteger('threads', 'SendZeroPricesMail', 0)=1;
      flCheckDocSum       := rIniFile.ReadInteger('threads', 'CheckDocSum', 0)=1;          // проверка сумм док-тов
      flCheckCliEmails    := rIniFile.ReadInteger('threads', 'CheckCliEmails', 0)=1;       // проверка Email
      WebAutoLinks        := rIniFile.ReadInteger('threads', 'WebAutoLinks', 0)=1;
      HideOnlySameName    := rIniFile.ReadInteger('threads', 'HideOnlySameName', 0)=1;
      HideOnlyOneLevel    := rIniFile.ReadInteger('threads', 'HideOnlyOneLevel', 0)=1;
      flCheckClosingDocs  := rIniFile.ReadInteger('threads', 'CheckClosingDocs', 0)=1;
    end; // with Cache
{
    FormingOrdersLimit:= rIniFile.ReadInteger('threads', 'FormingOrdersLimit', 10); // лимит строк в списке незакрытых заказов (5-50)
    if (FormingOrdersLimit<5) then FormingOrdersLimit:= 5;
    OrderListLimit:= rIniFile.ReadInteger('threads', 'OrderListLimit', 0); // лимит строк в списке заказов, 0- не проверять или >= 20
    if (OrderListLimit>0) and (OrderListLimit<20) then OrderListLimit:= 20;
}
    PhoneSupport:= rIniFile.ReadString('Options', 'PhoneSupport', '0-800-30-20-02'); // телефон службы поддержки
//---------------------- служебные
    flTest:= rIniFile.ReadInteger('Options', 'flTest', 0)=1;
    flTestDocs:= rIniFile.ReadInteger('Options', 'flTestDocs', 0)=1;
    flDebug:= rIniFile.ReadInteger('Options', 'flDebug', 0)=1; // флаг отладки
    flmyDebug:= rIniFile.ReadInteger('Options', 'flmyDebug', 0)=1;                 // мой флаг отладки (временный)
    flSkipTestWares:= rIniFile.ReadInteger('Options', 'flSkipTestWares', 0)=1;     // флаг пропуска проверки товаров для запасного сервера
    flLogTestWares:= rIniFile.ReadInteger('Options', 'flLogTestWares', 0)=1;       // флаг вывода в лог этапов проверки кеша товаров
    flLogTestClients:= rIniFile.ReadInteger('Options', 'flLogTestClients', 0)=1;   // флаг вывода в лог этапов проверки кеша клиентов
    flTmpRecodeCSS:= rIniFile.ReadInteger('Options', 'flTmpRecodeCSS', 0)=1;       // флаг фоновой перекодировки базы логирования
    flTmpRecodeORD:= rIniFile.ReadInteger('Options', 'flTmpRecodeORD', 0)=1;       // флаг фоновой перекодировки базы ORD
    flTmpRecodeGRB:= rIniFile.ReadInteger('Options', 'flTmpRecodeGRB', 0)=1;       // флаг фоновой перекодировки базы Grossbee
//---------------------- не используемые пока
    flMargins:= rIniFile.ReadInteger('Options', 'flMargins', 0)=1;                 // флаг наценок
    flShowAttrImage:= rIniFile.ReadInteger('Options', 'flShowAttrImage', 0)=1;     // флаг показа иконок в списках атрибутов
    flBonusAttr:= rIniFile.ReadInteger('Options', 'flBonusAttr', 0)=1;             // флаг атрибутов подарков
    flMeetPerson:= rIniFile.ReadInteger('Options', 'flMeetPerson', 0)=1;           // флаг ввода поля счета "Встречающий"
    flNewModeCGI:= rIniFile.ReadInteger('Options', 'flNewModeCGI', 0)=1;           // флаг отладки   //sn
    flContCurrPrice:= rIniFile.ReadInteger('Options', 'flContCurrPrice', 0)=1;     // флаг вывода прайса в валюте контракта
    flCheckLimits:= rIniFile.ReadInteger('Options', 'flCheckLimits', 0)=1;         // флаг проверки лимитов по кол-ву и весу
//---------------------- действующие
    flNewDocNames:= rIniFile.ReadInteger('Options', 'flNewDocNames', 1)=1;         // флаг замены названий док-тов
    flDisableOut := rIniFile.ReadInteger('Options', 'flDisableOut', 1)=1;          // флаг запрета на работу с webarm с внешних IP
    flNewSaveAcc := rIniFile.ReadInteger('Options', 'flNewSaveAcc', 1)=1;          // флаг записи счета с объединением
    flSpecRestSem:= rIniFile.ReadInteger('Options', 'flSpecRestSem', 0)=1;         // флаг учета поставки на сегодня
    flMotulTree:= rIniFile.ReadInteger('Options', 'flMotulTree', 0)=1;             // флаг подбора Motul (для интерфейса webarm)
    flNotReserve:= rIniFile.ReadInteger('Options', 'flNotReserve', 0)=1;           // флаг запрете резервирования
//    TodayFillDprts:= rIniFile.ReadString('Options', 'TodayFillDprts', '');         // склады поставки на сегодня (пусто - все)
    flNewBonusFilter:= rIniFile.ReadInteger('Options', 'flNewBonusFilter', 0)=1;   // флаг фильтра подарков MOTUL
    flCredProfile:= rIniFile.ReadInteger('Options', 'flCredProfile', 0)=1;         // флаг вывода кред.условий по профилям
    flOrderImport:= rIniFile.ReadInteger('Options', 'flOrderImport', 0)=1;         // флаг загрузки заказов
    flNewRestCols:= rIniFile.ReadInteger('Options', 'flNewRestCols', 0)=1;         // флаг нового вывода остатков по колонкам
    flShowWareByState:= rIniFile.ReadInteger('Options', 'flShowWareByState', 0)=1; // флаг показа товаров по статусу
    flTradePoint:= rIniFile.ReadInteger('Options', 'flTradePoint', 0)=1;           // флаг управления торг.точками
//---------------------- новые
    flPictNotShow:= rIniFile.ReadInteger('Options', 'flPictNotShow', 0)=1;         // флаг управления признаком "не показывать картинки"
    flWareForSearch:= rIniFile.ReadInteger('Options', 'flWareForSearch', 0)=1;     // флаг признака товара участия в поиске (Web)
    flNewOrdersMode:= rIniFile.ReadInteger('Options', 'flNewOrdersMode', 0)=1;         // флаг вывода страницы Заказы но новой схеме
    flNewOrderMode:= rIniFile.ReadInteger('Options', 'flNewOrderMode', 0)=1;         // флаг вывода страницы Заказы но новой схеме
    flGetExcelWareList:= rIniFile.ReadInteger('Options', 'flGetExcelWareList', 0)=1;         // флаг вывода страницы Заказы но новой схеме

    if not IsServiceCSS and fIconExist and (iAppStatus<0) and Application.MainForm.Visible then begin // сворачиваем форму
      Synchronize(Application.MainForm.Hide); //
      Application.ProcessMessages;
      iAppStatus:= 0;
    end;

//-------------------------------------------- заполнение / проверка кэша и т.д.
    with Cache do if GetAllBasesConnected then begin
//      if flCheckDocSum and (GetConstItem(pcCheckDocSumDelta).DoubValue<0.001) then  // дает ошибку !!!
//        SaveNewConstValue(pcCheckDocSumDelta, GetConstItem(pcEmplORDERAUTO).IntValue, '0.00999');
      if fOpen then begin
        TestConnections(); // вывод в лог инф.о коннектах
        if not WareCacheTested then // заполнение / проверка кэша (ExpressFlag=True - срочно и все)
          TestDataCache(not ExpressFlag);
  //        thTTestCache:= TTestCacheThread.Create(ExpressFlag); // заполнение / проверка кэша (ExpressFlag=True - срочно и все)
      end;

      if flCheckDocSum      then CheckDocSum;         // проверка сумм док-тов
      if flCheckClosingDocs then CheckClosingDocsAll; // пакетная проверка закрывающих док-тов заказов
      if flSendZeroPrices   then SendZeroPricesMail;  // Отчет о товарах с нулевыми ценами
      if flCheckCliEmails   then CheckClientsEmails;  // проверка Email-ов

      if flTmpRecodeCSS then TmpRecodeCSS; // фоновая перекодировка в базе логирования
      if flTmpRecodeORD then TmpRecodeORD; // фоновая перекодировка в базе ORD
      if flTmpRecodeGRB then TmpRecodeGRB; // фоновая перекодировка/чистка таблиц в базе Grossbee

//      prCheckSelfRestart; // проверяем перезапуск

      if not SingleThreadExists and Assigned(thSingleThread) then try  // ???
        prFree(thSingleThread);
      except end;

      TestCssStopException;
      if AllowWebArm  // автозапуск пакетной загрузки данных из TDT
        and (AppStatus=stWork)                                           // рабочий режим
        and (GetConstItem(pcSelfStartAddLoadWare).IntValue=1)            // автозапуск включен
        and (GetConstItem(pcLastAddLoadWare).IntValue>0)                 // автозапуск необходим
        and (fnGetActionTimeEnable(caeSmallWork) or flmyDebug)           // доступное время
        and (Cache.LongProcessFlag=cdlpNotLongPr)                        // не запущен длинный процесс
        and (ImpCheck.CheckList.Count<1)                                 // не запущен отчет/импорт
        and not SingleThreadExists                                       // спец.поток не запущен
        then thSingleThread:= TSingleThread.Create(csthLoadData, False); // запускаем в одиночном потоке
    end; // with Cache
  except
    on E:Exception do begin
      prMessageLOG(nmProc+' - внутренний охватывающий try '+E.Message);
      try
        prMessageLOG('FSafeSuspendFlag='+BOBBoolToStr(FSafeSuspendFlag));
        prMessageLOG('FStopFlag='+BOBBoolToStr(FStopFlag));
      except
       on E:Exception do prMessageLOG(nmProc+' - Ошибка записи подробностей ошибки '+E.Message);
      end;
    end;
  end;
  finally
    prFree(rIniFile);
  end;
end; // WorkProc
//==============================================================================
constructor TCheckDBConnectThread.Create(CreateSuspended: Boolean; AThreadType: integer);
const nmProc = 'TCheckDBConnectThread'; // имя процедуры/функции/потока
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'thCheckDBConnectThread';
  prMessageLOG(nmProc+': Запуск потока проверки соединения с БД');
end;
//==============================================================================
procedure TCheckDBConnectThread.DoTerminate;
begin
  inherited;
  prMessageLOG(ThreadName+': Завершение потока проверки соединения');
end;

//******************************************************************************
//                           TCheckStoppedOrders
//******************************************************************************
procedure TCheckStoppedOrders.WorkProc;
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    i, jj, OrderID: integer;
    s, ss: string;
begin
  if not Cache.WareCacheUnLocked then Exit;
  OrdIBS:= nil;
  CycleInterval:= GetIniParamInt(nmIniFileBOB, 'intervals', 'intervalCheckOrders', 5)*60;
  if GetAllBasesConnected then try
    OrdIBD:= cntsORD.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'QueryOrd_TCheckStoppedOrders', -1, tpRead, True);
      OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRNUM, ORDRFIRM'+
        ' FROM ORDERSREESTR WHERE ORDRSTATUS='+IntToStr(orstProcessing)+
        ' and DATEDIFF(SECOND, ORDRTOPROCESSDATE, cast("NOW" as timestamp))>:interval'; // "зависшие" заказы
      OrdIBS.ParamByName('interval').AsInteger:= CycleInterval;
      OrdIBS.ExecQuery;
      while not (OrdIBS.Eof or FSafeSuspendFlag or FStopFlag) do begin
        i:= OrdIBS.FieldByName('ORDRFIRM').AsInteger;
        s:= 'по заказу '+OrdIBS.FieldByName('ORDRNUM').AsString+
            ', код '+OrdIBS.FieldByName('ORDRCODE').AsString;
        Cache.TestFirms(i, true, true);  // полная проверка
        if not Cache.FirmExist(i) then
          fnWriteToLog(ThreadData, lgmsSysError, ThreadName, 'не найдена фирма'+
            ' код '+IntToStr(i)+' для формирования счета '+s, '', '')
        else if Cache.arFirmInfo[i].SKIPPROCESSING then begin
          OrderID:= OrdIBS.FieldByName('ORDRCODE').AsInteger;
          Stream.Clear;
          try
//            if flNewSaveAcc then begin
              // записать товары в счет Grossbee с объединением счетов
              jj:= fnOrderToGB(OrderID, True, True, ss, ThreadData);

{            end else begin
              Stream.WriteInt(OrderID);
              Stream.WriteBool(True); // проверять параметры отгрузки
              prOrderToGBn_Ord(Stream, ThreadData, True); // заказы
              Stream.Position:= 0;
              jj:= Stream.ReadInt;
            end; }

            if (jj in [aeSuccess, erWareToAccount]) then begin
              s:= 'сформирован счет '+s;
              fnWriteToLog(ThreadData, lgmsInfo, ThreadName, s, '', '');
              prMessageLOGS(ThreadName+': '+s, 'system');
            end;
          except
            on E:Exception do fnWriteToLog(ThreadData, lgmsSysError, 
              ThreadName, 'Ошибка формирования счета '+s, E.Message, '');
          end;
        end;
        TestCssStopException;
        OrdIBS.Next;
      end;
    finally
      prFreeIBSQL(OrdIBS);
      cntsOrd.SetFreeCnt(OrdIBD);
    end;
    CheckClonedOrBlockedClients; // проверка клонов/блоков клиентов
  except
    on E:Exception do fnWriteToLog(ThreadData, lgmsSysError, ThreadName, 'Ошибка WorkProc', E.Message, '');
  end;
end;
//==============================================================================
constructor TCheckStoppedOrders.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'thCheckStoppedOrders';
  prSetThLogParams(ThreadData, 0, 0, 0, ThreadName); // логирование в ib_css
  Stream:= TBOBMemoryStream.Create;
end;
//==============================================================================
procedure TCheckStoppedOrders.DoTerminate;
begin
  prFree(Stream);
  inherited;
end;

//******************************************************************************
//                           управление потоками
//******************************************************************************
function fnServerInit: boolean;   // выполняет подключения к ГроссБии и пр.
const nmProc = 'fnServerInit'; // имя процедуры/функции
var s: string;
    i: integer;
    IniFile: TINIFile;
begin
  Result:= false;
  thSingleThread:= nil;
  IniFile:= TINIFile.Create(nmIniFileBOB);
  try try
    SetLength(arManageCommands, 0);
    SetLength(StopList, 0);
    prCreatePools(IniFile);   // создать пулы
    MyClass:= TMyClass.Create;
    FullLog:= IniFile.ReadBool('Logs', 'FullLog', true);
    SetAppCaption; // заголовок формы
    Application.ProcessMessages;

    Cache:= TDataCache.Create; // создать кэш

    with Cache do begin // Проверка, какие потоки запускать. Почтовые НВ отслеживает сама
      AllowWeb          := IniFile.ReadInteger('Threads', 'Web', 0)=1;
      AllowWebArm       := IniFile.ReadInteger('Threads', 'WebArm', 0)=1;
      AllowCheckStopOrds:= IniFile.ReadInteger('Threads', 'CheckStoppedOrders', 0)=1;
    end;

    prMessageLOG(GetMessToLogPools(0, Cache.AllowWebArm), 'system'); // сообщение о пулах в текстовый лог при загрузке

    DirFileErr:= GetAppExePath+IniFile.ReadString('mail', 'ErrFilesPath', 'mailerrfiles'); // папка д/сбойных и врем. файлов
    if not DirectoryExists(DirFileErr) and // если папки нет - создавать
      not CreateDir(DirFileErr) then begin
      prMessageLOGS(nmProc+': Не могу создать папку '+DirFileErr);
      DirFileErr:= GetAppExePath;
    end;
    DirFileErr:= fnTestDirEnd(DirFileErr);

    // в отдельном потоке запускаем проверку соединения с базами данных
    thCheckDBConnectThread:= TCheckDBConnectThread.Create(true, thtpCheckDBConnect);
    TCSSCyclicThread(thCheckDBConnectThread).CSSResume;
    Application.ProcessMessages;

    // в отдельном потоке запускаем обработку стека управляющих команд
    thManageThread:= TManageThread.Create(False);
//---------------------------------------------------
    try
      ServerManage:= TIDTCPServer.Create(Application.MainForm);
      ServerManage.DefaultPort:= IniFile.ReadInteger('Communication', 'ManagePort', 12103);
      ServerManage.OnExecute:= MyClass.ServerExecute;
      ServerManage.OnConnect:= MyClass.ServerManageConnect;
      ServerManage.Name:= 'ServerManage';
      ServerManage.Tag:= DataSetsManager.AddCntsItem(Pointer(ServerManage));
      for i:= 1 to RepeatCount do try
        Application.ProcessMessages;
        ServerManage.Active:= true;
        break;
      except
        on E: Exception do begin
          ServerManage.Active:= false;
          if i<RepeatCount then sleep(997) else raise Exception.Create(E.Message);
        end;
      end;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': Ошибка инициализации прослушки управляющих запросов по порту '+
          IntToStr(ServerManage.DefaultPort)+': '+E.Message+'. Завершаю работу.');
        exit;
      end;
    end;

    if Cache.AllowWeb then try
      ServerWeb:= TIDTCPServer.Create(Application.MainForm);
      ServerWeb.DefaultPort:= IniFile.ReadInteger('Communication', 'WebPort', 333);
      ServerWeb.OnExecute:= MyClass.ServerExecute; // TIDServerThreadEvent
      ServerWeb.OnConnect:= MyClass.ServerWebConnect;
      ServerWeb.Name:= 'ServerWeb';
      ServerWeb.Tag:= DataSetsManager.AddCntsItem(Pointer(ServerWeb));
      for i:= 1 to RepeatCount do try
        Application.ProcessMessages;
        ServerWeb.Active:= true;
        break;
      except
        on E: Exception do begin
          ServerWeb.Active:= false;
          if i<RepeatCount then sleep(997) else raise Exception.Create(E.Message);
        end;
      end;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': Ошибка инициализации прослушки запросов Web по порту '+
          IntToStr(ServerWeb.DefaultPort)+': '+E.Message+'. Завершаю работу.');
        exit;
      end;
    end;

    if Cache.AllowWebArm then try
      ServerWebArm:= TIDTCPServer.Create(Application.MainForm);
      ServerWebArm.DefaultPort:= IniFile.ReadInteger('Communication', 'WebArmPort', 12104);
      ServerWebArm.OnExecute:= MyClass.ServerExecute; // TIDServerThreadEvent
      ServerWebArm.OnConnect:= MyClass.ServerWebArmConnect;
      ServerWebArm.Name:= 'ServerWebArm';
      ServerWebArm.Tag:= DataSetsManager.AddCntsItem(Pointer(ServerWebArm));
      for i:= 1 to RepeatCount do try
        Application.ProcessMessages;
        ServerWebArm.Active:= true;
        break;
      except
        on E: Exception do begin
          ServerWebArm.Active:= false;
          if i<RepeatCount then sleep(997) else raise Exception.Create(E.Message);
        end;
      end;
      ImpCheck:= TImpCheck.Create;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': Ошибка инициализации прослушки запросов WebArm по порту '+
          IntToStr(ServerWebArm.DefaultPort)+': '+E.Message+'. Завершаю работу.');
        exit;
      end;
    end;
//---------------------------------------------------

    while not GetReadyWorkOrStop do  // ждем готовности к работе
      for i:= 1 to 3 do begin
        Application.ProcessMessages; // без этого нельзя завершить процесс
        if (IsServiceCSS and ServiceGoOut) or
          (not IsServiceCSS and (AppStatus<>stStarting)) then exit;
        sleep(997);
      end;

    if (ServerID<1) then ServerID:= fnGetServerID;
    if (ServerID<1) then raise Exception.Create('Ошибка ServerID.');
    MainThreadData:= fnCreateThread(thtpMain); // Записываем в лог инфу о создании главного потока

    s:= GetMessToLogPools(1);  // сообщение о пулах в лог-базу при загрузке
    try
      prSetThLogParams(MainThreadData, 0, 0, 0, s); // логирование в ib_css
    except
      on E:Exception do prMessageLOG('Ошибка обновления параметров в записи потока'+
        #10'Текст ошибки: '+E.Message+#10'Данные: '+s);
    end;

    thTestMailFiles:= TTestMailFilesThread.Create(False, thtpTestMailFiles); // поток отсылки писем из файлов
    Application.ProcessMessages;

    //----------------- в отдельном потоке запускаем проверку "зависших" заказов
    if Cache.AllowCheckStopOrds then begin
      thCheckStoppedOrders:= TCheckStoppedOrders.Create(true, thtpStoppedOrders);
      TCSSCyclicThread(thCheckStoppedOrders).CSSResume;
    end;

    SetAppStatus(stWork);

    Result:= true;
    ErrorExit:= False; // признак зависания потоков
    if not IsServiceCSS and fIconExist then iAppStatus:= -1; // флаг - скрыть форму программы
//    MemUsedToLog('begin work');

    // CSSWebArm - запуск формирования шаблонов и т.п.
    // CSSWeb - заполнение фирм
if not flDebug then
    thSingleThread:= TSingleThread.Create(csthStart, False);
    Application.ProcessMessages;

    thCheckSMSThread:= nil;
    thControlPayThread:= nil;
    thControlSMSThread:= nil;
    //-------------------------------------- в Webarm запускаем отдельные потоки
    if Cache.AllowWebArm then begin
      try                    // поток отправки СМС
        thCheckSMSThread:= TCheckSMSThread.Create(true, thtpSMSThread);
        TCSSCyclicThread(thCheckSMSThread).CSSResume;
      except
        on E: Exception do prMessageLOGS(nmProc+'ошибка запуска потока: '+E.Message);
      end;
      Application.ProcessMessages;
      try                    // поток проверки зависания системы приема платежей
        thControlPayThread:= TControlPayThread.Create(true, thtpControlPayThread);
        TCSSCyclicThread(thControlPayThread).CSSResume;
      except
        on E: Exception do prMessageLOGS(nmProc+'ошибка запуска потока: '+E.Message);
      end;
      Application.ProcessMessages;
      try                    // поток проверки зависания системы отправки СМС
        thControlSMSThread:= TControlSMSThread.Create(true, thtpControlSMSThread);
        TCSSCyclicThread(thControlSMSThread).CSSResume;
      except
        on E: Exception do prMessageLOGS(nmProc+'ошибка запуска потока: '+E.Message);
      end;
      Application.ProcessMessages;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message+#10'Аварийное завершение работы.');
  end;
  finally
    prFree(IniFile);
  end;
end; // fnServerInit
//==============================================================================
procedure prServerExit; // вызывается после всего, отключается от ГроссБии, ADS и пр.
const nmProc = 'prServerExit'; // имя процедуры/функции
var CanClose, fl: boolean;
    i, j, StartWebCount, testWebCount, // для отлавливания зависших Threads
      StartWebArmCount, testWebArmCount, StartManageCount, testManageCount: integer;
    LocalStart: TDateTime;
//---------------------  начинаем остановку TIDTCPServer
  procedure ServerStartClose(var Server: TIDTCPServer; var StartCount, testCount: integer);
  begin
    StartCount:= 0;
    testCount:= 0;
    if not Assigned(Server) then Exit;
    Server.MaxConnections:= 1; // снижаем число активных соединений
    StartCount:= fnGetThreadsCount(Server); // запоминаем начальное кол-во Threads
  end;
//---------------------  попытка остановить TIDTCPServer
  procedure CloseServer(var Server: TIDTCPServer; var StartCount, testCount: integer);
  var ThreadsCount: integer;
  begin
    if not Assigned(Server) or not Server.Active then Exit;
    ThreadsCount:= fnGetThreadsCount(Server); // определяем кол-во Threads
    if ThreadsCount=StartCount then inc(testCount) // если кол-во не изменилось - увеличиваем счетчик
    else begin    // если кол-во WebThreads изменилось - сбрасываем счетчик
      StartCount:= ThreadsCount;
      testCount:= 0;
    end;
    if ThreadsCount>0 then
      prMessageLOG('Info: '+Server.Name+'.Contexts.Count = '+IntToStr(ThreadsCount));
    if (fnGetThreadsCount(Server)<2) then begin
      i:= 0;
      while (i<10) and (fnGetThreadsCount(Server)>0) do begin // пробуем отловить последний Context 1 сек
        sleep(101);
        inc(i);
        Application.ProcessMessages;
      end;
      if i>0 then prMessageLOG('Info: sleep = '+IntToStr(i));
      if fnGetThreadsCount(Server)=0 then begin
        Server.Active:= false;
        prMessageLOG('Info: '+Server.Name+'.Active:= false');
      end;
    end;
    if Server.Active and (testCount>RepeatCount) then begin // если кол-во не меняется - считаем, что зависли
      DataSetsManager.ClearCntsItem(Pointer(Server));
      Server:= nil;  // иначе зависает на любом варианте Free
      ErrorExit:= True;  // признак зависания потоков
      prMessageLOG('Info: '+Server.Name+':= nil');
    end;
  end;
//------------------------------------------   завершаем
  procedure FreeServer(var Server: TIDTCPServer);
  begin
    if not Assigned(Server) then Exit;
    if Server.Active then begin
      Server.Active:= False;
      prMessageLOG('Info: '+Server.Name+'.Active:= false');
    end;
    DataSetsManager.ClearCntsItem(Pointer(Server));
    prFree(Server);
  end;
//------------------------------------------
begin
  if AppStatus=stExiting then exit;
  prMessageLOG(nmProc+': начинаю завершение работы ');
  try
    fl:= (AppStatus=stSuspended);
    SetAppStatus(stExiting);
    if fl then prResumeAll; // если из stSuspended сразу выходить - дает Ac.Violation

    CanClose:= false;

    ServerStartClose(ServerWeb, StartWebCount, testWebCount); // начинаем остановку TIDTCPServer
    ServerStartClose(ServerWebArm, StartWebArmCount, testWebArmCount);
    ServerStartClose(ServerManage, StartManageCount, testManageCount);

//    if Assigned(thManageThread) then thManageThread.Terminate;
    if Assigned(thCheckDBConnectThread) then TCSSCyclicThread(thCheckDBConnectThread).Stop;
    if Assigned(thCheckStoppedOrders) then TCSSCyclicThread(thCheckStoppedOrders).Stop;
    if Assigned(thTestMailFiles) then thTestMailFiles.Stop; // поток отсылки писем из файлов
    if Assigned(thCheckSMSThread) then TCSSCyclicThread(thCheckSMSThread).Stop;
    if Assigned(thControlPayThread) then TCSSCyclicThread(thControlPayThread).Stop;
    if Assigned(thControlSMSThread) then TCSSCyclicThread(thControlSMSThread).Stop;

    LocalStart:= now();
    prSuspendPools;   // остановить пулы
    if flTest then prMessageLOGS(nmProc+'_prSuspendPools: - '+
      GetLogTimeStr(LocalStart), fLogDebug, false);
    Application.ProcessMessages;

    Application.ProcessMessages;

    prFree(ImpCheck);
    j:= 0;
    LocalStart:= now();
    while not CanClose and (j<RepeatStopInterval) do begin
      CloseServer(ServerWeb, StartWebCount, testWebCount); // попытка остановить TIDTCPServer
      CloseServer(ServerWebArm, StartWebArmCount, testWebArmCount);
//      CloseServer(ServerManage, StartManageCount, testManageCount);

      CanClose:= GetReadyWorkOrStop(False);
      sleep(997);
      Application.ProcessMessages;
      inc(j);
    end;
    if flTest then prMessageLOGS(nmProc+'_CanClose: - '+
      GetLogTimeStr(LocalStart), fLogDebug, false);

    ErrorExit:= (j=RepeatStopInterval);
    prDestroyThreadData(MainThreadData, nmProc);

    if Assigned(thSingleThread) then try
      LocalStart:= now();
      thSingleThread.Terminate;
      if flTest then prMessageLOGS(nmProc+'_thSingleThread: - '+
        GetLogTimeStr(LocalStart), fLogDebug, false);
      Application.ProcessMessages;
    except
    end;

    Cache.Free;
    Cache:= nil;
    Application.ProcessMessages;

    LocalStart:= now();
    prFreePools; //  (после кэша)
    if flTest then prMessageLOGS(nmProc+'_prFreePools: - '+
      GetLogTimeStr(LocalStart), fLogDebug, false);
    Application.ProcessMessages;

    LocalStart:= now();
    FreeServer(ServerWeb);
    FreeServer(ServerWebArm);
    Application.ProcessMessages;

    if Assigned(thManageThread) then thManageThread.Terminate;
    CloseServer(ServerManage, StartManageCount, testManageCount);
    FreeServer(ServerManage);

    if flTest then prMessageLOGS(nmProc+'_FreeServers: - '+
      GetLogTimeStr(LocalStart), fLogDebug, false);
    Application.ProcessMessages;
  except
    on E: Exception do begin
      prMessageLOG(nmProc+': ошибка при завершении работы '+E.Message);
      ErrorExit:= True;
    end;
  end;
  if not IsServiceCSS and Assigned(PopupMenuIcon) then prFree(PopupMenuIcon);
  SetLength(arManageCommands, 0);
  SetLength(StopList, 0);
  SetAppStatus(stClosed);
  Application.ProcessMessages;

  if ErrorExit then prErrorShutDown; // если что-то зависло - аварийное завершение
end; // prServerExit
//==============================================================================
procedure prSafeSuspendAll;
const nmProc = 'prSafeSuspendAll'; // имя процедуры/функции
var i: integer;
    LocalStart: TDateTime;
begin
  prMessageLOG(nmProc+': Перехожу в состояние Suspended');
  SetAppStatus(stSuspending);
  try
    if Assigned(thCheckDBConnectThread) then
      TCSSCyclicThread(thCheckDBConnectThread).SafeSuspend;
    if Assigned(thCheckStoppedOrders) then
      TCSSCyclicThread(thCheckStoppedOrders).SafeSuspend;
    if Assigned(thCheckSMSThread) then
      TCSSCyclicThread(thCheckSMSThread).SafeSuspend;
    if Assigned(thControlPayThread) then
      TCSSCyclicThread(thControlPayThread).SafeSuspend;
    if Assigned(thControlSMSThread) then
      TCSSCyclicThread(thControlSMSThread).SafeSuspend;

    LocalStart:= now();
    try
      sleep(499); // ждем немного, чтобы остановились потоки
      Application.ProcessMessages;
      prSuspendPools;   // остановить пулы
      if flTest then begin
        prMessageLOGS(nmProc+'_prSuspendPools: - '+
          GetLogTimeStr(LocalStart), fLogDebug, false);
        LocalStart:= now();
      end;
      Application.ProcessMessages;
      i:= 0;
      while not GetReadyWorkOrStop(False) and (i<RepeatStopInterval) do begin
        sleep(997);
        inc(i);
        Application.ProcessMessages;
      end;
      if flTest then prMessageLOGS(nmProc+'_GetReadyWorkOrStop: - '+
        GetLogTimeStr(LocalStart), fLogDebug, false);
    except
      on E: Exception do prMessageLOG(nmProc+': ошибка при остановке: '+#10+E.Message);
    end;

    if Cache.AllowWebArm and (ImpCheck.CheckList.Count>0) then begin // если процесс завис в списке (WebArm)
      for i:= 0 to ImpCheck.CheckList.Count-1 do try
        TCheckProcess(ImpCheck.CheckList.Items[i]).Free;
      except end;
      ImpCheck.CheckList.Clear;
    end;

    SetAppStatus(stSuspended);
    prMessageLOG(nmProc+': Все потоки приостановлены.');
    prMessageLOG(nmProc+': Перешел в состояние Suspended');
    if not GetAllBasesConnected(False, True) then begin
      Exit;  // ???
    end;

//    MemUsedToLog('suspended');
//    prMessageLOGS(' ', 'MemUsed', false);
//    prMessageLOGS('Пробую почистить память', 'MemUsed', false);
//    prMessageLOGS('before prTrimAppMemorySize '+FormatFloat('Memory used: , .# K', fnGetCurrentMemoryUsage/1024), 'MemUsed', false);
//    prTrimAppMemorySize;
//    prMessageLOGS('after  prTrimAppMemorySize '+FormatFloat('Memory used: , .# K', fnGetCurrentMemoryUsage/1024), 'MemUsed', false);
//    prMessageLOGS(' ', 'MemUsed', false);
  except
    on E: Exception do prMessageLOG(nmProc+': '+#10+E.Message);
  end;
end; // prSafeSuspendAll
//==============================================================================
procedure prResumeAll;
const nmProc = 'prResumeAll'; // имя процедуры/функции
begin
  try
    if AppStatus<>stExiting then begin
      prMessageLOG(nmProc+': Перехожу в состояние Worked');
      SetAppStatus(stResuming);
    end;
    prResumePools; // разблокировать пулы
//    Cache.CSSResume;
    TCheckDBConnectThread(thCheckDBConnectThread).CSSResume;

    if AppStatus<>stExiting then
      while not GetAllBasesConnected do begin // ждем готовности к работе
        sleep(499);
        Application.ProcessMessages;
      end;

    if Assigned(thCheckStoppedOrders) then TCSSCyclicThread(thCheckStoppedOrders).CSSResume;
    if Assigned(thCheckSMSThread) then TCSSCyclicThread(thCheckSMSThread).CSSResume;
    if Assigned(thControlPayThread) then TCSSCyclicThread(thControlPayThread).CSSResume;
    if Assigned(thControlSMSThread) then TCSSCyclicThread(thControlSMSThread).CSSResume;

    if AppStatus<>stExiting then begin
      if Assigned(ServerWeb) and Cache.AllowWeb and not ServerWeb.Active then ServerWeb.Active:= true;
      if Assigned(ServerWebArm) and Cache.AllowWebArm and not ServerWebArm.Active then ServerWebArm.Active:= true;
    end;

    if AppStatus<>stExiting then begin
      SetAppStatus(stWork);
      fnWriteToLog(MainThreadData, lgmsInfo, nmProc, 'Все потоки запущены.', '', '');
      prMessageLOG(nmProc+': Перешел в состояние Worked');

//      MemUsedToLog('resumed');
    end;
  except
    on E: Exception do prMessageLOG(nmProc+': '+E.Message);
  end;
end; // prResumeAll
//========================== возвращает признак соединения/отсоединения всех баз
function GetAllBasesConnected(conn: boolean=True; flSUF: boolean=False): boolean;
begin
  if conn then begin // признак соединения всех баз
    Result:= cntsGRB.BaseConnected and cntsLOG.BaseConnected and cntsORD.BaseConnected;
    if Cache.AllowWebArm then begin
      if not cntsTDT.PoolNotInit then Result:= Result and cntsTDT.BaseConnected;
      if flSUF and not cntsSUF.PoolNotInit then Result:= Result and cntsSUF.BaseConnected;
      if flSUF and not cntsSUFORD.PoolNotInit then Result:= Result and cntsSUFORD.BaseConnected;
      if flSUF and not cntsSUFLOG.PoolNotInit then Result:= Result and cntsSUFLOG.BaseConnected;
    end;
  end else begin   // признак отсоединения всех баз
    Result:= not cntsGRB.BaseConnected and not cntsLOG.BaseConnected and not cntsORD.BaseConnected;
    if Cache.AllowWebArm then begin
      if not cntsTDT.PoolNotInit then Result:= Result and not cntsTDT.BaseConnected;
      if flSUF and not cntsSUF.PoolNotInit then Result:= Result and not cntsSUF.BaseConnected;
      if flSUF and not cntsSUFORD.PoolNotInit then Result:= Result and not cntsSUFORD.BaseConnected;
      if flSUF and not cntsSUFLOG.PoolNotInit then Result:= Result and not cntsSUFLOG.BaseConnected;
    end;
  end;
end;
//=================================== признак готовности работать / остановиться
function GetReadyWorkOrStop(Work: boolean=True): boolean;
// при Work=True  - возвращает признак готовности работать
// при Work=False - возвращает признак готовности остановиться
begin
  if Work then
    Result:= GetAllBasesConnected and Cache.WareCacheUnLocked
  else case AppStatus of
    stSuspending: Result:= GetAllBasesConnected(False, True)
      and (not Assigned(thCheckStoppedOrders) or TCSSCyclicThread(thCheckStoppedOrders).Suspended)
      and (not Assigned(thCheckDBConnectThread) or TCSSCyclicThread(thCheckDBConnectThread).Suspended)
      and (not Assigned(thCheckSMSThread) or TCSSCyclicThread(thCheckSMSThread).Suspended)
      and (not Assigned(thControlPayThread) or TCSSCyclicThread(thControlPayThread).Suspended)
      and (not Assigned(thControlSMSThread) or TCSSCyclicThread(thControlSMSThread).Suspended);
    stExiting: Result:= GetAllBasesConnected(False, True)
      and (not Assigned(thCheckStoppedOrders) or TCSSCyclicThread(thCheckStoppedOrders).Terminated)
      and (not Assigned(thCheckDBConnectThread) or TCSSCyclicThread(thCheckDBConnectThread).Terminated)
      and (not Assigned(thCheckSMSThread) or TCSSCyclicThread(thCheckSMSThread).Terminated)
      and (not Assigned(thControlPayThread) or TCSSCyclicThread(thControlPayThread).Terminated)
      and (not Assigned(thControlSMSThread) or TCSSCyclicThread(thControlSMSThread).Terminated)
      and (not Assigned(thTestMailFiles) or thTestMailFiles.Terminated)
      and (not Assigned(ServerWeb) or (not ServerWeb.Active and (fnGetThreadsCount(ServerWeb)=0)))
      and (not Assigned(ServerWebArm) or (not ServerWebArm.Active and (fnGetThreadsCount(ServerWebArm)=0)));
    else Result:= False;
  end;
end;
//======================================== признак готовности ответить на запрос
function GetMessageNotCanWorks: string;
// возвращает текст сообщения, если не готов ответить на запрос
begin
  Result:= '';
  if GetAllBasesConnected and (AppStatus=stWork) then Exit;
  case AppStatus of
    stWork: Result:= 'Ошибка соединения с базой данных.';
    stStarting, stResuming:
            Result:= 'Временно отсутствует соединение с базой данных.';
    stSuspending, stSuspended, stExiting, stClosed:
            Result:= 'Сервер электронных заказов пока не доступен, ведутся '+
                     'технические работы. Приносим извинения за временные неудобства.';
  end;
//  Application.ProcessMessages;
end;
{//========================================================= память - вывод в лог
procedure MemUsedToLog(comment: String);
begin
  prMessageLOGS(FormatFloat(fnMakeAddCharStr(comment, 10, True)+
    ' : , .# K', fnGetCurrentMemoryUsage/1024), 'MemUsed', false);
  Cache.LastTimeMemUsed:= Now;
end;  }
//================================ формирование списка товаров с нулевыми ценами
procedure SendZeroPricesMail;
const nmProc = 'SendZeroPricesMail'; // имя процедуры/функции/потока
var s, ss, sSort, sAdress, sSubj: string;
    i: integer;
    lstW: TStringList;
    lasttime: TDateTime;
    ware: TWareInfo;
begin
  if not Assigned(Cache) then Exit;
  if not fnGetActionTimeEnable(caeOnlyWorkTime) then Exit; // только в рабочее время
  if not Cache.flSendZeroPrices then Exit;

  sAdress:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // общий Email отдела УИК
  if sAdress='' then Exit; // если не задан адрес

  i:= Cache.GetConstItem(pcZeroPricesIntHour).IntValue;      // интервал в часах
  lasttime:= Cache.GetConstItem(pcZeroPricesTime).DateValue; // время отправки посл.письма
  if (Now<IncHour(lasttime, i)) then Exit; // если не прошел заданный интервал

  lstW:= fnCreateStringList(False, 100);
  Cache.flSendZeroPrices:= False;  // выключаем флаг (защита от повторных писем)
  try try
    setLength(sSort, 90); // список товаров с нулевой ценой (для сортировки)
    for i:= 1 to High(Cache.arWareInfo) do begin
      if not Cache.WareExist(i) then Continue;
      ware:= Cache.GetWare(i);
      if ware.IsArchive or ware.IsINFOgr or not Cache.PgrExists(ware.PgrID) then Continue;
      if (ware.PgrID=Cache.pgrDeliv) then Continue; // пропускаем доставки
// В отчет не должны попадать товары со статусами "Подготовка, "Инфо", "Реклама" (01.11.2017, ЧВ)
      if (ware.WareState in [cWStatePrepare, cWStateInfo, cWStatePublic]) then Continue;
      if ware.IsMarketWare then Continue;
      s:= copy(ware.PgrName, 1, 40);
      ss:= copy(ware.Name, 1, 50);

      sSort:= fnMakeAddCharStr(s, 40, True)+ss;
      lstW.Add(sSort);
    end;

    if (lstW.Count<1) then lstW.Add('Товары с нулевыми ценами не найдены.')
    else begin
      lstW.Sort; // сортируем
      for i:= 0 to lstW.Count-1 do begin // имя товара с нулевой ценой (+ подгруппа) для отправки
        s:= copy(lstW[i], 41, 30); // Ware.Name
        ss:= copy(lstW[i], 1, 40); // Ware.PgrName
        lstW[i]:= 'нет цены - '+fnMakeAddCharStr(s, 40, True)+ss;
      end;
    end;

    //------------------------- Отправляем отчет о товарах с нулевыми ценами
    ss:= FormatDateTime(cDateTimeFormatY4S, Now);
    sSubj:= 'Отчет о товарах с нулевыми ценами от '+ss;
    s:= n_SysMailSend(sAdress, sSubj, lstW, nil, '', '', true);

    if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then // если не записалось в файл
      prMessageLOGS(nmProc+': Ошибка отправки письма "'+sSubj+'" на E-mail '+sAdress+': '+s, 'system')
    else begin
      prMessageLOGS(nmProc+': Отправлено письмо "'+sSubj+'" на E-mail '+sAdress, 'system');
      i:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
      Cache.SaveNewConstValue(pcZeroPricesTime, i, ss); // записываем время отправки письма
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  finally
    setLength(sSort, 0);
    prFree(lstW);
    Cache.flSendZeroPrices:= True; // включаем флаг
  end;
  TestCssStopException;
end;

//******************************************************************************
//                   поток отсылки писем из файлов
//******************************************************************************
constructor TTestMailFilesThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'TestMailFilesThread';
  prSetThLogParams(ThreadData, ccTestMailFiles, 0, 0, ThreadName); // логирование в ib_css
end;
//==============================================================================
destructor TTestMailFilesThread.Destroy;
begin
  inherited Destroy;
end;
//==============================================================================
procedure TTestMailFilesThread.WorkProc; // нужен, если основной поток не смог отослать письмо
var flag: Boolean;
    shablon, ToAdres, Subj, From, file_name, s, dir, DirErr, ss: string;
    SearchRec: TSearchRec;
    body, Attachments, errlist: TStringList;
    i: integer;
begin
  dir:= fnGetMailFilesPath;
  DirErr:= fnTestDirEnd(dir)+'err';
  shablon:= dir+PrefixMailFile+'*'+ExtMailFile;
  body:= TStringList.Create;
  Attachments:= TStringList.Create;
  errlist:= TStringList.Create;
  try try
    CycleInterval:= GetIniParamInt(nmIniFileBOB, 'intervals', 'intervalCheckOrders', 5)*60;
    flag:= (FindFirst(shablon, faAnyFile, SearchRec)=0); // ищем файлы писем
    if not flag then Exit;

    while flag and not FStopFlag do begin
      body.Clear;
      Attachments.Clear;
      file_name:= fnGetMailFilesPath+SearchRec.Name;

      if not FileExists(fnGetLockFileName(file_name)) then try // если нет блокировки

        body.AddStrings(fnStringsLogFromFile(file_name, False)); // считываем строки файла
        if body.Count<5 then begin
          s:= RenameErrFile(SearchRec.Name, dir, DirErr);
          raise Exception.Create('мало строк в файле '+SearchRec.Name+' '+s);
        end;
        ToAdres:= body.Strings[0]; // разбираем строки файла в письмо
        Subj:= body.Strings[1];
        if body.Strings[2]<>'no' then From:= body.Strings[2];
        if body.Strings[3]<>'no' then Attachments.CommaText:= body.Strings[3];
        for i:= 3 downto 0 do body.Delete(i);

        s:= n_SysMailSend(ToAdres, Subj, body, Attachments, From);
        if s<>'' then raise Exception.Create(s);
        DeleteFile(file_name); // удаляем обработанный файл
        try
          if Attachments.Count>0 then ss:= ' '+Attachments.CommaText else ss:= '';
        except
          ss:= '';
        end;                              // удаляем приложенные файлы
        for i:= 0 to Attachments.Count-1 do DeleteFile(Attachments[i]);
        fnWriteToLogPlus(ThreadData, lgmsSysMess, ThreadName+'.WorkProc',
          'отправлено письмо из файла '+SearchRec.Name, 'ToAdres='+ToAdres+
          ' Subj='+Subj+fnIfStr(From='', '', ' From='+From)+ss, '');
        if FWroteToLog then FWroteToLog:= False; // сбрасываем флаг вывода в лог
      except
        on E: Exception do
          if (Pos('Нет подключения к ', E.Message)>0) or
            (Pos('Authentication failed', E.Message)>0) then begin
            if FWroteToLog then E.Message:= '' else FWroteToLog:= True; // если уже записали в лог - пропускаем
            raise Exception.Create(E.Message);
          end else if (Pos('Некорректное значение', E.Message)>0)
            or (Pos('Invalid or missing', E.Message)>0)
            or (Pos('Mailbox syntax incorrect', E.Message)>0)
            or (Pos('mailbox not allowed', E.Message)>0) then begin
            s:= RenameErrFile(SearchRec.Name, dir, DirErr);
            if s='' then
              s:= 'в файле '+SearchRec.Name+': '+E.Message+#10'файл перемещен в папку '+DirErr
            else s:= 'в файле '+SearchRec.Name+': '+E.Message+' '+s;
            errlist.Add(s);
            raise Exception.Create(s);
          end else begin
            fnWriteToLogPlus(ThreadData, lgmsSysError, ThreadName+'.WorkProc',
              'Ошибка при отправке письма из файла '+SearchRec.Name, E.Message, '');
          end;
      end;
      flag:= (FindNext(SearchRec)=0); // ищем следующий
    end; // while flag...

    if errlist.Count>0 then begin
      errlist.Insert(0, GetMessageFromSelf);
      s:= fnGetSysAdresVlad(caeOnlyWorkDay);
      s:= n_SysMailSend(s, 'Error send mail from file', errlist, nil, '', '', true);
      if s<>'' then raise Exception.Create('Error send mail to admin'+s);
    end;
  except
    on E: Exception do if E.Message<>'' then
      fnWriteToLogPlus(ThreadData, lgmsSysError, ThreadName+'.WorkProc', 'Ошибка потока', E.Message, '');
  end;
  finally
    FindClose(SearchRec);
    prFree(body);
    prFree(Attachments);
    prFree(errlist);
  end;
end;
//==============================================================================

//******************************************************************************
//                TTestCacheThread - поток проверки кеша
//******************************************************************************
constructor TTestCacheThread.Create(aExpress: Boolean);
begin
  inherited Create(False);
  FExpress:= aExpress;
  FreeOnTerminate:= True;
  if AppStatus=stWork then Priority:= tpLower;
end;
//==============================================================================
procedure TTestCacheThread.Execute;
begin
//  inherited;
  if Application.Terminated or (AppStatus>stWork) then exit;
  Cache.TestDataCache(not FExpress);  // заполнение / проверка кэша (FExpress=True - срочно и все)
end;
//==============================================================================

//******************************************************************************
//                            TSingleThread
//******************************************************************************
constructor TSingleThread.Create(aKind: Byte=0; aSuspended: Boolean=False);
begin
  inherited Create(aSuspended);
  FKind:= aKind;
  FreeOnTerminate:= True;
  Priority:= tpLower;
  Cache.SingleThreadExists:= True;
end;
//==============================================================================
procedure TSingleThread.DoTerminate;
begin
  Cache.SingleThreadExists:= False;
end;
//==============================================================================
procedure TSingleThread.Execute;
const nmProc = 'SingleThread_Execute'; // имя процедуры/функции
var UserID, iHour: Integer;
    ThreadData: TThreadData;
    Stream: TBoBMemoryStream;
    SystemTime: TSystemTime;
  //-----------------------------------
  procedure prSleep;
  var i: Integer;
  begin
    for i:= 1 to 3 do begin
      Application.ProcessMessages; // без этого нельзя завершить процесс
      TestCssStopException;
      sleep(331);
    end;
  end;
  //-----------------------------------
begin
  Stream:= nil;
  ThreadData:= nil;
  try
    case FKind of
//----------------------- автозапуск пакетной загрузки данных из TDT - CSSWebarm
    csthLoadData: begin
        try
          UserID:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
          ThreadData:= fnCreateThread(thtpWebArm);
          Stream:= TBoBMemoryStream.Create;
          Stream.WriteInt(UserID);
          Stream.WriteInt(24);
          Stream.WriteStr(cSelfStart);
          prGetBaseStamp(Stream, ThreadData);
        finally
          prFree(Stream);
          prDestroyThreadData(ThreadData, nmProc);
        end;
      end; // csthLoadData

//------------------------------------------------------------ старт CSS-сервера
    csthStart: begin
        while not Cache.WareCacheUnLocked do prSleep; // ждем готовности основного кеша
        sleep(5000); // ждем 5 сек
        GetLocalTime(SystemTime); // системное время

    //------------------------------------------------- CSSWeb - заполнение фирм
        if Cache.AllowWeb then begin
          if fnGetActionTimeEnable(caeOnlyDay) then iHour:= 1 // днем (неплановый) - активных в теч.последнего часа
          else if (SystemTime.wHour<2) then iHour:= 1         // ночью (неплановый) - активных в теч.последнего часа
          else if (DayOfTheWeek(Date)=DayMonday) then iHour:= 24*3 // ночью пн (плановый) - активных в теч.последних 3 суток
          else iHour:= 24; // ночью вт-сб (плановый) - активных в теч.последних суток
          TestLastFirms(iHour);
        end; // if Cache.AllowWeb

    //-------------------------- CSSWebArm - запуск формирования шаблонов и т.п.
        if Cache.AllowWebArm then begin
          if (SystemTime.wHour<2) then Exit; // ночью (неплановый) - выходим
          while not Cache.WareLinksUnLocked do prSleep; // ждем готовности связок

          while not SetLongProcessFlag(cdlpFormFiles, True) do prSleep; // выставляем флаг процесса
          try             // формирование файлов-шаблонов
            apReCreateWareDetModPatternFile(constIsAuto); // 19 импорт - Auto
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            apReCreateWareDetModPatternFile(constIsMoto); // 19 импорт - Moto
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            apReCreateWareDetModPatternFile(constIsCV); // 19 импорт - CV
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            apReCreateWareDetModPatternFile(constIsAx); // 19 импорт - Axle
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);


            GetReports30;            // формирование Пакета отчетов 30
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            TestOldErrMailFiles;     // проверка незабранных файлов отчетов
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            TestLogFirmNames;        // проверка наименований фирм в базе логирования
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            TmpCheckRecode;          // регулярная проверка в базе логирования
            Application.ProcessMessages;

          finally
            SetNotLongProcessFlag(cdlpFormFiles);
          end;
        end; // if Cache.AllowWebArm

      end; // csthStart
    end; // case
  except
    on E: Exception do prMessageLOGS('TSingleThread ('+IntToStr(FKind)+'): '+E.Message);
  end;
  Terminate;
end;

end.
