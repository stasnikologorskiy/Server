unit n_IBCntsPool;

interface

uses Windows, SysUtils, Classes, DateUtils, Db, IBDatabase, IBHeader, SyncObjs,
     Math, n_free_functions, v_constants;

const
//  cDefConTimeout = 10; // сек
  cDefLockLimit  = 500;
  cDefMaxOpen    = 50;
  cDefIntFreeCnt = 20;
  cDefStartCnt   = 0;
  cLenCntsName   = 10;
  cPoolLog       = 'TestConns';

type // статусы коннекта:
// csFree - свободный, csLock - используется, csBad - сбойный, csConn - в процессе соединения с базой
  TCntStatus = (csFree, csLock, csBad, csConn);

  TIBPooledCnt = class (TComponent) // свойства рабочего коннекта
  private
    FConnStatus  : TCntStatus;  // статус коннекта
    FIgnoreTimer : Boolean;     // не закрывать коннект по времени
    FLockCount   : Integer;     // счетчик использования открытого коннекта
    FUserIndex   : Integer;     // индекс логина в списке логинов
    FConnLockTime: TDateTime;   // индикатор последнего времени использования коннекта
    FDatabase    : TIBDatabase;
  public
    CScnt: TCriticalSection;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Database: TIBDatabase read FDatabase;
//  published
//    property ConnStatus  : ShortInt  read FConnStatus   write FConnStatus;
//    property IgnoreTimer : Boolean   read FIgnoreTimer  write FIgnoreTimer;
//    property LockCount   : Word      read FLockCount    write FLockCount;
//    property UserIndex   : Word      read FUserIndex    write FUserIndex;
//    property ConnLockTime: TDateTime read FConnLockTime write FConnLockTime;
  end;

  TIBCntsPool = class (TComponent) // пул рабочих коннектов к базе
  private
    FCurrConnections : Integer;               // текущее кол-во коннектов в пуле
    FOpenConnections : Integer;               // текущее кол-во открытых коннектов в пуле
    FLockConnections : Integer;               // текущее кол-во используемых коннектов в пуле
    FConnConnections : Integer;               // текущее кол-во коннектов в процессе соединения с базой в пуле
    FLockLimit       : Integer;               // лимит использования открытого коннекта
    FIntClose        : Integer;               // интервал в мин закрытия неиспользуемых коннектов (def 20)
    FStartConnections: Integer;               // стартовое кол-во коннектов
    FMaxOpenConnects : Integer;               // максимальное кол-во открытых коннектов в пуле
//    FConnectTimeout  : Integer;               // в сек
    FBaseConnected   : boolean;               // флаг наличия соединения с базой
    FSuspend         : boolean;               // флаг остановки работы
    FCntsName        : string;                // имя пула
    FDatabaseName    : string;                // путь подключения к базе
    FCntsComment     : string;                // комментарий пула
    FLogins          : Tas;                   // список логинов юзеров (0- логин по умолчанию)
    FDBParams        : TStrings;              // параметры подключения к базе по умолчанию
    FPoolConns       : array of TIBPooledCnt; // список коннектов к данной базе
    procedure IBDBFree(Database: TIBDatabase);
    procedure CreatePoolItem(i: integer);         // создать новый коннект
     function OpenPoolItem(i: integer): boolean;  // открыть коннект
     function ClosePoolItem(i: integer; InCS: Boolean=False): boolean; // закрыть коннект
     function ClosePoolItem_new(i: integer; InCS: Boolean=False): boolean; // закрыть коннект
     function PoolNotAvailable: boolean;
     function AddNewCnt(UserInd: Integer; aPass,aRole: string; var i: Integer): boolean; // добавить в пул новый элемент
    procedure StartFillPool;           // начальное заполнение пула
  public
    CSpool: TCriticalSection;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CSSSuspend(StopInt: Integer=10);
    procedure CSSResume;
     function GetMessToLog(kind: integer=0): String;
    procedure SetPoolParams(cName, Path, User, Pass: string; Role: string='';     // стартовые параметры пула
              StartCnt: Integer=cDefStartCnt; Comment: string='');
    procedure CheckDatabasePath(Path: string);                                    // проверить путь к базе пула
    procedure SetPoolRunParams(pIntClose, pLockLimit, pMaxOpen: Integer; pConTimeout: Integer=10); // изменяемые параметры пула
    procedure CheckBaseConnection(Interval: integer; fOpen: Boolean=False); // проверить соединение с базой
     function BaseConnected: boolean;
     function PoolNotInit: boolean;
     function NotManyLockConnects: boolean;
     function GetFreeCnt(aUser: string=''; aPass: string=''; aRole: string=''; IgnoreTimer: Boolean=False): TIBDatabase; // получить свободный коннект и пометить "занят"
     function GetFreeCnt_new(aUser: string=''; aPass: string=''; aRole: string=''; IgnoreTimer: Boolean=False): TIBDatabase; // получить свободный коннект и пометить "занят"
    procedure SetFreeCnt(pdb: TIBDatabase; fclose: boolean=False); // освободить коннект
    procedure SetFreeCnt_new(pdb: TIBDatabase; fclose: boolean=False); // освободить коннект
    procedure TestCntsState(var ss: string; k: Integer; var Body: TStringList);
    procedure TestSuspendException;
     function PoolItemExists(index: Integer): boolean;
     property CntsName   : String read FCntsName;
     property CntsComment: String read FCntsComment;
     property dbPath     : string read FDatabaseName;
     property OpenConnections: Integer read FOpenConnections; // текущее кол-во открытых коннектов
     property LockConnections: Integer read FLockConnections; // текущее кол-во используемых коннектов
     property ConnConnections: Integer read FConnConnections; // текущее кол-во открываемых коннектов
  published
    property Suspend: boolean read FSuspend write FSuspend;
  end;

implementation
//****************************** TIBPooledCnt ***********************************
constructor TIBPooledCnt.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase:= TIBDatabase.Create(self);
  FDatabase.DefaultTransaction:= TIBTransaction.Create(self);
  with FDatabase.DefaultTransaction.Params do begin
    Add(tpReadWrite[tpRead]); // на чтение
    Add('read_committed');
    Add('rec_version');
    Add('nowait');
  end;
  FDatabase.LoginPrompt:= false;
  FDatabase.DefaultTransaction.DefaultDatabase:= FDatabase;
  FDatabase.Tag:= -1;
  FLockCount:= 0;
  CScnt:= TCriticalSection.Create;
end;
//==================================================
destructor TIBPooledCnt.Destroy;
begin
  prFree(CScnt);
  inherited;
end;

//****************************** TIBCntsPool ***********************************
constructor TIBCntsPool.Create(AOwner: TComponent);
begin
  inherited;
  FBaseConnected:= False;
  FCurrConnections:= 0;
  FStartConnections:= 0;
  FOpenConnections:= 0;
  FLockConnections:= 0;
  FConnConnections:= 0;
  FLockLimit:= cDefLockLimit;
  FMaxOpenConnects:= cDefMaxOpen;
  setLength(FLogins, 0);
  setLength(FPoolConns, 0);
  FDBParams:= TStringList.Create;
  CSpool:= TCriticalSection.Create;
end;
//==================================================
destructor TIBCntsPool.Destroy;
var i: Integer;
begin
  if not Assigned(self) then exit;
  setLength(FLogins, 0);
  for i:= 0 to High(FPoolConns) do begin
    IBDBFree(FPoolConns[i].FDatabase);
    prFree(FPoolConns[i]);
  end;
  setLength(FPoolConns, 0);
  FPoolConns:= nil;
  prFree(FDBParams);
  prFree(CSpool);
  inherited Destroy;
end;
//==============================================================================
procedure TIBCntsPool.TestSuspendException;
begin
  if not Assigned(self) then exit;
  if Suspend then raise Exception.Create('прерываю процесс по команде Suspend');
end;
//=================================================
function TIBCntsPool.PoolNotInit: boolean;
begin
  Result:= not Assigned(self) or (FDatabaseName='');
end;
//=================================================
function TIBCntsPool.NotManyLockConnects: boolean;
begin
  Result:= Assigned(self) and ((FLockConnections+FConnConnections)<FMaxOpenConnects);
end;
//=================================================
function TIBCntsPool.PoolItemExists(index: Integer): boolean;
begin
  Result:= Assigned(self) and not PoolNotInit and (index>-1)
           and (index<FCurrConnections) and Assigned(FPoolConns[index]);
end;
//=================================================
function TIBCntsPool.PoolNotAvailable: boolean;
begin
  Result:= Assigned(self) and PoolNotInit or Suspend or not FBaseConnected;
end;
//=================================================
function TIBCntsPool.BaseConnected: boolean;
begin
  Result:= Assigned(self) and not PoolNotInit and FBaseConnected;
end;
//==================================================== изменяемые параметры пула
procedure TIBCntsPool.SetPoolRunParams(pIntClose, pLockLimit, pMaxOpen: Integer; pConTimeout: Integer=10);
begin
  if not Assigned(self) or PoolNotInit then Exit;
  if (FIntClose<>pIntClose) then FIntClose:= pIntClose; // интервал закрытия неисп.коннектов в мин., 0 - не закрывать
  if (FLockLimit<>pLockLimit) then FLockLimit:= pLockLimit;
  if (FMaxOpenConnects<>pMaxOpen) then FMaxOpenConnects:= pMaxOpen;
//  if (FConnectTimeout<>pConTimeout) then FConnectTimeout:= pConTimeout;
end;
//========================================================= закрыть все коннекты
procedure TIBCntsPool.CSSSuspend(StopInt: Integer=10);
var i, j: Integer;
begin
  if not Assigned(self) or PoolNotInit then Exit;
  Suspend:= True; // блокируем пул (своб.коннекты не выдаются)
  sleep(101); // ждем немного
  CSpool.Enter;
  try
    for i:= 0 to High(FPoolConns) do with FPoolConns[i] do try // закрываем все
      if not Database.Connected then Continue;
      j:= 0;
      if (FConnStatus=csLock) then // если работает - ждем StopInt сек
        while Database.DefaultTransaction.InTransaction and (j<StopInt) do begin
          sleep(999);
          inc(j);
        end;
      ClosePoolItem(i);
    except
      on E: Exception do begin
        FConnStatus:= csBad;
        prMessageLOGS(CntsName+'.CSSSuspend: error Close '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
      end;
    end;
  finally
    CSpool.Leave;
  end;
  FOpenConnections:= 0;
  FLockConnections:= 0;
  FConnConnections:= 0;
  FBaseConnected:= False;
end;
//==================================================
procedure TIBCntsPool.CSSResume;
begin
  if not Assigned(self) or PoolNotInit then Exit;
  Suspend:= False; // разблокировать пул
  CheckBaseConnection(1);
end;
//=================================================== проверить путь к базе пула
procedure TIBCntsPool.CheckDatabasePath(Path: string);
const nmProc = 'CheckDatabasePath'; // имя процедуры/функции/потока
var i, j: Integer;
begin
  if not Assigned(self) then Exit;
  if (FDatabaseName=Path) then Exit;

  CSpool.Enter;
  FDatabaseName:= Path;
  try
    for i:= 0 to High(FPoolConns) do with FPoolConns[i] do try // закрываем все
      if Database.Connected then begin
        j:= 0;
        if (FConnStatus=csLock) then // если работает - ждем до 3 сек      ??????
          while Database.DefaultTransaction.InTransaction and (j<28) do begin
            sleep(101);
            inc(j);
          end;
        ClosePoolItem(i);
      end;
      Database.DatabaseName:= FDatabaseName;
      prMessageLOGS(CntsName+'.'+nmProc+': set DatabaseName '+IntToStr(i)+
                    ' - '+FDatabaseName, cPoolLog, false);
    except
      on E: Exception do begin
        FConnStatus:= csBad;
        prMessageLOGS(CntsName+'.'+nmProc+': error '+IntToStr(i)+
                      ' - '+E.Message, cPoolLog, false);
      end;
    end;
  finally
    CSpool.Leave;
  end;

end;
//===================================================== стартовые параметры пула
procedure TIBCntsPool.SetPoolParams(cName, Path, User, Pass: string; Role: string='';
          StartCnt: Integer=cDefStartCnt; Comment: string='');
begin
  if not Assigned(self) then Exit;
  FCntsName:= cName;        // имя пула
  FDatabaseName:= Path;     // путь подключения к базе
  FCntsComment:= Comment;   // комментарий пула
  with FDBParams do begin   // параметры подключения к базе по умолчанию
//    Add('USER_NAME='+User);
//    Add('PASSWORD='+Pass);
//    if (Role<>'') then Add('sql_role_name='+Role);
    Values['user_name']:= User;
    Values['password']:= Pass;
    if (Role<>'') then Values['sql_role_name']:= Role;
//    if (FConnectTimeout>0) then Values['connect_timeout']:= IntToStr(FConnectTimeout);
  end;
  setLength(FLogins,1);
  FLogins[0]:= User;
  FStartConnections:= StartCnt;
  if FDatabaseName='' then exit;
  StartFillPool;
end;
//=================================================== очищаем TIBDatabase в пуле
procedure TIBCntsPool.IBDBFree(Database: TIBDatabase);
const nmProc = 'IBDBFree'; // имя процедуры/функции/потока
var DbName: string;
    tr: TIBTransaction;
begin
  if not Assigned(self) or PoolNotInit or not Assigned(Database) then Exit;
  try
    DbName:= Database.Name;
    with Database do if Assigned(DefaultTransaction) then begin
      if DefaultTransaction.InTransaction then DefaultTransaction.RollBack;
      tr:= DefaultTransaction;
      prFree(tr);
    end;
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+': '+DbName+' error 1: '+E.Message, cPoolLog, false);
  end;
  try
    Database.ForceClose;
    Database.FlushSchema;
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+': '+DbName+' error 2: '+E.Message, cPoolLog, false);
  end;
  try
    if Database.Connected then prMessageLOGS(CntsName+'.'+nmProc+': '+DbName+' not closed', cPoolLog, false);
    prFree(Database);
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+': error '+DbName+'.Free: '+E.Message, cPoolLog, false);
  end;
end;
//================================================= проверить соединение с базой
procedure TIBCntsPool.CheckBaseConnection(Interval: integer; fOpen: Boolean=False);
// Interval - в сек., fmess - выводить в лог
var TestTime: TDateTime;
    Connted, fbegin, Check: boolean;
    DB: TIBDatabase;
    i: integer;
//------------------------------------
  function WorkAfterTime(TestTime: TDateTime): boolean;
  var j: integer;
  begin
    Result:= False;
    for j:= 0 to High(FPoolConns) do
      if FPoolConns[j].FConnLockTime>TestTime then begin
        Result:= True;
        exit;
      end;
  end;
//------------------------------------
begin
  if not Assigned(self) or PoolNotInit or Suspend then Exit;
  fbegin:= not FBaseConnected;
  Check:= false;
  DB:= nil;
  if fbegin or (Interval<0) then Connted:= false
  else begin
    TestTime:= IncSecond(Now, -Interval);
    Connted:= WorkAfterTime(TestTime);
  end;
  try
    Check:= not Connted; // если пул недавно работал - считаем, что с базой есть соединение
    if not Check then Exit;
    try
      DB:= TIBDatabase.Create(self);
      DB.DatabaseName:= FDatabaseName;
      DB.LoginPrompt:= false;
      DB.Params:= FDBParams;
      DB.Open;
      Connted:= DB.TestConnected; // false - если нет соединения с базой
    except
      on e: Exception do begin
        prMessageLOGS('error '+fnMakeAddCharStr(CntsName, cLenCntsName, True)+':  '+E.Message, 'CheckConnect', false);
        Connted:= false;
      end;
    end;
  finally
    IBDBFree(DB);
    FBaseConnected:= Connted;
    if Check then  // если проверяли
      prMessageLOGS('check '+fnMakeAddCharStr(CntsName, cLenCntsName, True)+':  '+
        fnIfStr(FBaseConnected, '', 'not ')+'BaseConnected', 'CheckConnect', false);

    if fbegin and FBaseConnected then begin
      prMessageLOGS(GetMessToLog(1), cPoolLog, true); // сообщение в лог при подключении пула
      if fOpen and (FStartConnections>0) then         // начальное открытие коннектов пула
        for i:= 0 to FStartConnections-1 do OpenPoolItem(i);
    end;
  end;
end;
//======================================================== создать новый коннект
procedure TIBCntsPool.CreatePoolItem(i: integer);
const nmProc = 'CreatePoolItem'; // имя процедуры/функции
begin
  if not Assigned(self) or PoolNotInit or (i<0) then Exit;
  try
    FPoolConns[i]:= TIBPooledCnt.Create(self);
    with FPoolConns[i] do begin
      Database.DatabaseName:= FDatabaseName;
      FConnLockTime:= 0;
      Database.Name:= FcntsName+'_db'+IntToStr(i);  // генерируем имя
      Database.Tag:= i; // записываем индекс коннекта в пуле
      FConnStatus:= csFree;
    end;
  except
    on E: Exception do begin
      FPoolConns[i].FConnStatus:= csBad;
      prMessageLOGS(CntsName+'.'+nmProc+': '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
    end;
  end;
end;
//============================================================== открыть коннект
function TIBCntsPool.OpenPoolItem(i: integer): boolean;
const nmProc = 'OpenPoolItem'; // имя процедуры/функции
var fl: Boolean;
begin
  Result:= False;
  if not Assigned(self) or PoolNotAvailable or not PoolItemExists(i) then Exit;
  with FPoolConns[i] do try
    fl:= not Database.Connected;
    if fl then try
      FConnStatus:= csConn;
      Inc(FConnConnections);
      Database.Open;
    finally
      Dec(FConnConnections);
    end;
    Result:= Database.TestConnected;
    if Result then begin
      FConnLockTime:= Now();
      if fl then Inc(FOpenConnections);
    end;
  except
    on E: Exception do begin
      Result:= False;
      FConnStatus:= csBad;
      prMessageLOGS(CntsName+'.'+nmProc+': '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
    end;
  end;
end;
//============================================================== закрыть коннект
function TIBCntsPool.ClosePoolItem(i: integer; InCS: Boolean=False): boolean;
const nmProc = 'ClosePoolItem'; // имя процедуры/функции
var fl: Boolean;
begin
  Result:= False;
  if not Assigned(self) or PoolNotInit or not PoolItemExists(i) then Exit;
  if InCS then CSpool.Enter;
  try
    with FPoolConns[i] do try
      fl:= Database.Connected;
      if fl then begin
        Database.ForceClose;
        Database.FlushSchema;
      end;
      FLockCount:= 0;
      Result:= not Database.TestConnected;
      if not Result then raise Exception.Create('error close');
      FConnStatus:= csFree;
      if fl and (FOpenConnections>0) then Dec(FOpenConnections);
    except
      on E: Exception do begin
        Result:= False;
        FConnStatus:= csBad;
        prMessageLOGS(CntsName+'.'+nmProc+': '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
      end;
    end;
  finally
    if InCS then CSpool.Leave;
  end;
end;
//============================================================== закрыть коннект
function TIBCntsPool.ClosePoolItem_new(i: integer; InCS: Boolean=False): boolean;
const nmProc = 'ClosePoolItem_new'; // имя процедуры/функции
var fl: Boolean;
begin
  Result:= False;
  if not Assigned(self) or PoolNotInit or not PoolItemExists(i) then Exit;

  with FPoolConns[i] do try
    CScnt.Enter;
    try
      fl:= Database.Connected;
      if fl then begin
        Database.ForceClose;
        Database.FlushSchema;
      end;
      FLockCount:= 0;
      Result:= not Database.TestConnected;
      if not Result then raise Exception.Create('error close');
      FConnStatus:= csFree;
    except
      on E: Exception do begin
        Result:= False;
        FConnStatus:= csBad;
        prMessageLOGS(CntsName+'.'+nmProc+': '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
      end;
    end;
  finally
    CScnt.Leave;
  end;

  if Result and fl and (FOpenConnections>0) then try
    if InCS then CSpool.Enter;
    Dec(FOpenConnections);
  finally
    if InCS then CSpool.Leave;
  end;
end;
//==================================================== начальное заполнение пула
procedure TIBCntsPool.StartFillPool;
const nmProc = 'StartFillPool'; // имя процедуры/функции
var i: integer;
begin
  if not Assigned(self) or PoolNotInit or (FStartConnections<1) then Exit;
  FCurrConnections:= FStartConnections;
  setLength(FPoolConns, FCurrConnections);
  for i:= 0 to High(FPoolConns) do try
    CreatePoolItem(i); // создать новый коннект
    FPoolConns[i].Database.Params:= FDBParams;  // задать параметры по умолчанию
    FPoolConns[i].FUserIndex:= 0;
  except
    on E: Exception do begin
      FPoolConns[i].FConnStatus:= csBad;
      prMessageLOGS(CntsName+'.'+nmProc+': '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
    end;
  end;
end;
//================================================= добавить в пул новый элемент
function TIBCntsPool.AddNewCnt(UserInd: Integer; aPass, aRole: string; var i: Integer): boolean;
const nmProc = 'AddNewCnt'; // имя процедуры/функции
begin
  Result:= False;
  if not Assigned(self) or PoolNotAvailable then Exit;
  i:= FCurrConnections;
  try
    setLength(FPoolConns, i+1);
    Inc(FCurrConnections);
    CreatePoolItem(i); // создать новый коннект

    if (UserInd<1) or (UserInd>High(FLogins)) then
      FPoolConns[i].Database.Params:= FDBParams  // параметры по умолчанию
    else with FPoolConns[i].Database.Params do begin
//      Add('USER_NAME='+FLogins[UserInd]);  // параметры юзера
//      Add('PASSWORD='+aPass);
//      if aRole<>'' then Add('sql_role_name='+aRole);
      Values['user_name']:= FLogins[UserInd];
      Values['password']:= aPass;
      if (aRole<>'') then Values['sql_role_name']:= aRole;
//      if (FConnectTimeout>0) then Values['connect_timeout']:= IntToStr(FConnectTimeout);
    end;
    FPoolConns[i].FUserIndex:= UserInd;

    Result:= OpenPoolItem(i);
  except
    on E: Exception do begin
      Result:= False;
      FPoolConns[i].FConnStatus:= csBad;
      prMessageLOGS(CntsName+'.'+nmProc+': error AddCnt - '+E.Message, cPoolLog, false);
    end;
  end;
end;
//=================================================== получить свободный коннект
function TIBCntsPool.GetFreeCnt(aUser: string=''; aPass: string=''; aRole: string=''; IgnoreTimer: Boolean=False): TIBDatabase;
const nmProc = 'GetFreeCnt'; // имя процедуры/функции
var Loop, i, UserInd, index: integer;
    fNewUser: boolean;  // признак нового юзера (чтобы не перебирать коннекты)
    ErrMess: String;
begin
  Result:= nil;
  ErrMess:= '';
  try
    if not Assigned(self) then exit;

    if PoolNotAvailable then begin
      ErrMess:= 'остановлен или нет соединения с базой';
      exit;
    end;
    if not NotManyLockConnects then begin
      ErrMess:= 'слишком много коннектов';
      exit;
    end;

    fNewUser:= False;      // определяем юзера для подключения
    if (aUser='') then UserInd:= 0 else UserInd:= fnInStrArray(aUser, FLogins, false);
    if (UserInd<0) then try  // добавляем логин юзера в список логинов
      CSpool.Enter;
      try
        UserInd:= Length(FLogins);
        SetLength(FLogins, UserInd+1);
        FLogins[UserInd]:= aUser;
        fNewUser:= True;
      except
        on E: Exception do begin
          UserInd:= 0;
          prMessageLOGS(CntsName+'.'+nmProc+': error add Login '+aUser+' - '+E.Message, cPoolLog, false);
        end;
      end;
    finally
      CSpool.Leave;
    end;

    for loop:= 1 to RepeatCount do begin // RepeatCount попыток
      CSpool.Enter;
      try
        if (FCurrConnections>0) and not fNewUser then
          for i:= 0 to High(FPoolConns) do with FPoolConns[i] do try // ищем свободный коннект этого юзера
            if (FConnStatus=csFree) and (FUserIndex=UserInd) and OpenPoolItem(i) then begin
              FConnStatus:= csLock;
              Inc(FLockCount);            // добавляем счетчик использования
              result:= Database;
              Inc(FLockConnections);
              FIgnoreTimer:= IgnoreTimer; // признак закрытия коннекта по времени
              Exit;                       // если нашли и открыли - выходим
            end;
          except
            on E: Exception do begin
              FConnStatus:= csBad;
              prMessageLOGS(CntsName+'.'+nmProc+': error open cnt - '+E.Message, cPoolLog, false);
            end;
          end;
  // Add new connection to the pool
        if AddNewCnt(UserInd, aPass, aRole, index) then with FPoolConns[index] do begin
          FConnStatus:= csLock;
          Inc(FLockCount);            // добавляем счетчик использования
          result:= Database;
          Inc(FLockConnections);
          FIgnoreTimer:= IgnoreTimer; // признак закрытия коннекта по времени
          Exit;                       // если добавили успешно - выходим
        end;
      finally  // т.к. есть Exit
        CSpool.Leave;
      end;
      sleep(101);
    end;
  finally
    if not Assigned(result) then begin
      if (ErrMess<>'') then prMessageLOGS(CntsName+'.'+nmProc+': error '+ErrMess, cPoolLog, false);
      raise EBOBError.Create('Ошибка подключения к базе данных.');
    end;
  end;
end;
//=================================================== получить свободный коннект
function TIBCntsPool.GetFreeCnt_new(aUser: string=''; aPass: string=''; aRole: string=''; IgnoreTimer: Boolean=False): TIBDatabase;
const nmProc = 'GetFreeCnt_new'; // имя процедуры/функции
var Loop, i, UserInd, index: integer;
    fNewUser: boolean;  // признак нового юзера (чтобы не перебирать коннекты)
    ErrMess: String;
begin
  Result:= nil;
  ErrMess:= '';
  try
    if not Assigned(self) then exit;

    if PoolNotAvailable then begin
      ErrMess:= 'остановлен или нет соединения с базой';
      exit;
    end;
    if not NotManyLockConnects then begin
      ErrMess:= 'слишком много коннектов';
      exit;
    end;

    fNewUser:= False;      // определяем юзера для подключения
    if (aUser='') then UserInd:= 0 else UserInd:= fnInStrArray(aUser, FLogins, false);
    if (UserInd<0) then try  // добавляем логин юзера в список логинов
      CSpool.Enter;
      try
        UserInd:= Length(FLogins);
        SetLength(FLogins, UserInd+1);
        FLogins[UserInd]:= aUser;
        fNewUser:= True;
      except
        on E: Exception do begin
          UserInd:= 0;
          prMessageLOGS(CntsName+'.'+nmProc+': error add Login '+aUser+' - '+E.Message, cPoolLog, false);
        end;
      end;
    finally
      CSpool.Leave;
    end;

    for loop:= 1 to RepeatCount do begin // RepeatCount попыток
//      try
        if (FCurrConnections>0) and not fNewUser then
          for i:= 0 to High(FPoolConns) do with FPoolConns[i] do try // ищем свободный коннект этого юзера
            if (FConnStatus=csFree) and (FUserIndex=UserInd) and OpenPoolItem(i) then try
              CSpool.Enter;
              FConnStatus:= csLock;
              Inc(FLockCount);            // добавляем счетчик использования
              result:= Database;
              Inc(FLockConnections);
              FIgnoreTimer:= IgnoreTimer; // признак закрытия коннекта по времени
              Exit;                       // если нашли и открыли - выходим
            finally
              CSpool.Leave;
            end;
          except
            on E: Exception do begin
              FConnStatus:= csBad;
              prMessageLOGS(CntsName+'.'+nmProc+': error open cnt - '+E.Message, cPoolLog, false);
            end;
          end;
  // Add new connection to the pool
        if AddNewCnt(UserInd, aPass, aRole, index) then with FPoolConns[index] do try
          CSpool.Enter;
          FConnStatus:= csLock;
          Inc(FLockCount);            // добавляем счетчик использования
          result:= Database;
          Inc(FLockConnections);
          FIgnoreTimer:= IgnoreTimer; // признак закрытия коннекта по времени
          Exit;                       // если добавили успешно - выходим
        finally
          CSpool.Leave;
        end;
//      finally  // т.к. есть Exit
//        CSpool.Leave;
//      end;
      sleep(101);
    end;
  finally
    if not Assigned(result) then begin
      if (ErrMess<>'') then prMessageLOGS(CntsName+'.'+nmProc+': error '+ErrMess, cPoolLog, false);
      raise EBOBError.Create('Ошибка подключения к базе данных.');
    end;
  end;
end;
//=========================================================== освободить коннект
procedure TIBCntsPool.SetFreeCnt(pdb: TIBDatabase; fclose: boolean=False);
const nmProc = 'SetFreeCnt'; // имя процедуры/функции
// fclose=true - закрывать коннект
var i, j: integer;
begin
  if not Assigned(self) or PoolNotAvailable or not Assigned(pdb) then Exit;
  j:= -1;
  try                         // проверяем активность транзакции на всяк.сл.
    with pdb.DefaultTransaction do if InTransaction then Rollback;
    if PoolItemExists(pdb.Tag) and
      (FPoolConns[pdb.Tag].Database.Handle=pdb.Handle) then j:= pdb.Tag; // в Tag - индекс в пуле
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+' 1: - '+E.Message, cPoolLog, false);
  end;
  try
    if (j<0) then for i:= 0 to High(FPoolConns) do
      if (pdb.Handle=FPoolConns[i].Database.Handle) then begin
        j:= i;
        break;
      end;
    if j>-1 then with FPoolConns[j] do try
      CSpool.Enter;
      FIgnoreTimer:= False;                  // признак закрытия коннекта по времени
      if fclose or (FLockCount>FLockLimit)   // или коннект много использовался
        or (FOpenConnections>FMaxOpenConnects) then // или много открытых коннектов
        ClosePoolItem(j)                            // - закрываем
      else FConnStatus:= csFree;
      Dec(FLockConnections);
    finally
      CSpool.Leave;
    end;
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+' 2: - '+E.Message, cPoolLog, false);
  end;
end;
//=========================================================== освободить коннект
procedure TIBCntsPool.SetFreeCnt_new(pdb: TIBDatabase; fclose: boolean=False);
const nmProc = 'SetFreeCnt_new'; // имя процедуры/функции
// fclose=true - закрывать коннект
var i, j: integer;
    fl: Boolean;
begin
  if not Assigned(self) or PoolNotAvailable or not Assigned(pdb) then Exit;
  j:= -1;
  fl:= False;
  try                         // проверяем активность транзакции на всяк.сл.
    with pdb.DefaultTransaction do if InTransaction then Rollback;
    if PoolItemExists(pdb.Tag) and
      (FPoolConns[pdb.Tag].Database.Handle=pdb.Handle) then j:= pdb.Tag; // в Tag - индекс в пуле
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+' 1: - '+E.Message, cPoolLog, false);
  end;
  try
    if (j<0) then for i:= 0 to High(FPoolConns) do
      if (pdb.Handle=FPoolConns[i].Database.Handle) then begin
        j:= i;
        break;
      end;
    if (j>-1) then with FPoolConns[j] do try
      CSpool.Enter;
      FIgnoreTimer:= False;
      fl:= fclose                       // признак закрытия коннекта по времени
           or (FLockCount>FLockLimit)   // или коннект много использовался
           or (FOpenConnections>FMaxOpenConnects); // или много открытых коннектов
//      if fl then ClosePoolItem(j); // - закрываем
      if not fl then FConnStatus:= csFree;
      Dec(FLockConnections);
    finally
      CSpool.Leave;
    end;
    if fl then ClosePoolItem(j); // - закрываем

  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+' 2: - '+E.Message, cPoolLog, false);
  end;
end;
//========================== узнать состояние коннектов и закрыть неиспользуемые
procedure TIBCntsPool.TestCntsState(var ss: string; k: Integer; var Body: TStringList);
const nmProc = 'TestCntsState'; // имя процедуры/функции
// ss - строка для вывода в лог, k - число коннектов, после которого писать в Body
var i, Available, Bad: Integer; // счетчики занятых/свободных/сбойных коннектов
    TestTime: TDateTime;
    sm, s: string;
begin
  sm:= ''; // формируем строку для вывода в лог
  s:= '';
  Available:= 0;
  Bad:= 0;
  if not Assigned(self) or PoolNotAvailable then Exit;
  if FIntClose<1 then TestTime:= 0 else TestTime:= IncMinute(Now(), -FIntClose);
  for i:= 0 to High(FPoolConns) do with FPoolConns[i] do try
    if Database.Connected and not (FIgnoreTimer or (FConnLockTime>TestTime)) then
      ClosePoolItem(i, True); // пробуем закрыть неиспользуемый или сбойный
    case FConnStatus of
      csFree: inc(Available);  // свободный коннект
      csBad:  inc(Bad);        // сбойный коннект
    end;
  except
    on E: Exception do prMessageLOGS(CntsName+'.'+nmProc+' '+IntToStr(i)+' - '+E.Message, cPoolLog, false);
  end;                                       // формируем строку для вывода в лог
  if (OpenConnections>0) then sm:= 'opened= '+IntToStr(OpenConnections);  // открытые коннекты
  if (LockConnections>0) then sm:= fnMakeAddCharStr(sm, 13, True)+'locked= '+IntToStr(LockConnections);
  if (Available>0)       then sm:= fnMakeAddCharStr(sm, 25, True)+'free= '+IntToStr(Available);
  if (Bad>0)             then sm:= fnMakeAddCharStr(sm, 35, True)+'bad= '+IntToStr(Bad);
  if (ConnConnections>0) then sm:= fnMakeAddCharStr(sm, 45, True)+'TryOpen= '+IntToStr(ConnConnections);
  if ((LockConnections+ConnConnections)>k) then begin
    if (LockConnections>0) then s:= IntToStr(LockConnections)+' locked cnts';
    if (ConnConnections>0) then s:= s+fnIfStr(s='', '', ', ')+IntToStr(ConnConnections)+' try open';
    if not Assigned(Body) then Body:= TStringList.Create;
    Body.Add(CntsName+': '+s);
  end;
  if (trim(sm)<>'') then ss:= ss+fnIfStr(ss='', ' ', #13#10+StringOfChar(' ', 20))+
                            fnMakeAddCharStr(CntsName, cLenCntsName, True)+': '+sm;
end;
//=================================================
function TIBCntsPool.GetMessToLog(kind: integer=0): String;
begin
  Result:= '';
  if not Assigned(self) then exit;
  if PoolNotInit then exit;
  case kind of
    0: Result:= ' '+fnMakeAddCharStr(CntsName, cLenCntsName, True)+' - '+dbPath; // сообщение при загрузке
    1: Result:= '   Cоединение '+fnMakeAddCharStr(CntsName, cLenCntsName, True)+' установлено.'; // сообщение при подключении пула
  end;
end;

end.


