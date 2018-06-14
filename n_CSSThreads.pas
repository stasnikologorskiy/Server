unit n_CSSThreads;

interface
uses Windows, Classes, SysUtils, IniFiles, Forms, DateUtils, System.Math,
     IdTCPServer, IBDatabase, IBSQL,
     n_free_functions, v_constants, v_DataTrans,
     n_LogThreads, n_DataSetsManager, n_DataCacheInMemory, n_constants, n_server_common;

type
//------------------------------------------------------------------------------
  TTestCacheThread = class (TThread)   // ���������
  private { Private declarations }
    FExpress: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(aExpress: Boolean);
  end;

//------------------------------------------------------------------------------
  TManageCommand = record // �������, ����������� ��������
    Command: integer;
    IP: string; // IP �������, ������������ �������
  end;

  TManageThread = class (TThread)
  protected
    CycleInterval: integer; // �������� ������������� � ��������
    procedure Execute; override;
    procedure StopAll;
  public

  end;

//------------------------------------------------------------------------------
  TSingleThread = class (TThread) // ����������� �����
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
    CycleInterval: integer; // �������� ������������� � ��������
    FStopFlag: boolean;
    FSafeSuspendFlag: boolean;
    ThreadData: TThreadData;
    ThreadType: integer;
    ThreadName: string;
    procedure WorkProc; virtual; abstract;
    procedure Execute; override;
    procedure DoTerminate; override;
  public
    ExpressFlag: boolean;  // ���� �������� ���������� WorkProc
    LastTime: TDateTime;   // ����� ���������� ������� WorkProc
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
  TTestMailFilesThread = class (TCSSCyclicThread) // ����� ������� ����� �� ������
  private { Private declarations }
    FWroteToLog: boolean; // ���� ������ � ��� ��������� �� ���������� ����������
  protected
    procedure WorkProc; override;
  public  { Public declarations }
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    destructor Destroy; override;
  end;
//------------------------------------------------------------------------------

var ErrorExit: boolean;                    // ������� ��������� �������
    thTestMailFiles: TTestMailFilesThread; // ��������� ����� ��� ������� ����� �� ������
    thTTestCache: TTestCacheThread;        // ��������� ����� �������� ����
    thSingleThread: TSingleThread;
    arManageCommands: array of TManageCommand;
    IniFile: TINIFile;

   function fnServerInit: boolean; // ����������� �� �������� ������� �����, ��������� ����������� � ��������, ADS � ��.
  procedure prServerExit; // ����������� ����� �����, ����������� �� ��������, ADS � ��.
  procedure prSafeSuspendAll; // ���������������� ���
  procedure prResumeAll; // �������� ���, ��� ������ ����������

   function GetAllBasesConnected(conn: boolean=True; flSUF: boolean=False): boolean;
   function GetReadyWorkOrStop(Work: boolean=True): boolean;
   function GetMessageNotCanWorks: string;
//  procedure MemUsedToLog(comment: String); // ������ - ����� � ���
  procedure SendZeroPricesMail; // ������������ ������ ������� � �������� ������

implementation

uses v_Functions, n_CSSservice, n_DataCacheObjects, n_IBCntsPool,
     t_ImportChecking, t_WebArmProcedures, t_CSSThreads;

//******************************************************************************
//                           TManageThread
//******************************************************************************
procedure TManageThread.StopAll;
begin
  StopServiceCSS; // ��������� ������� �� ����������
end;
//==============================================================================
procedure TManageThread.Execute;
var i, j: integer;
    Command: TManageCommand;
begin
  while not (Application.Terminated or (AppStatus=stExiting)) do try

    if ServiceGoOut then begin // �����, ����� ��������� ������ �� PopupMenu, ���� �������� �� �������������
      if IsServiceCSS then Synchronize(StopAll) else Synchronize(Application.Terminate);
      Terminate;
      exit;
    end;

    if (Length(arManageCommands)>0) and not (AppStatus in [stSuspending, stResuming]) then begin
      while ManageCommandsLock do begin
        sleep(101);  // �� ����������, ���� ������ �������
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
        scSuspend: begin //---------------------------------------- ������������
            if fnInStrArray(Command.IP, StopList)=-1 then begin
              SetLength(StopList, Length(StopList)+1);
              StopList[Length(StopList)-1]:= Command.IP;
              prMessageLOG('TManageThread.Execute: ������ '+Command.IP+' �������� � StopList.', 'system');
            end;
            if AppStatus=stWork then begin
              prMessageLOG('TManageThread.Execute: �������� ��������� prSafeSuspendAll.', 'system');
              prSafeSuspendAll;
            end;
          end;
        scResume: begin //----------------------------------------------- ������
            i:= fnInStrArray(Command.IP, StopList);
            if i>-1 then begin
              for j:= i to Length(StopList)-2 do StopList[j]:= StopList[j+1];
              SetLength(StopList, Length(StopList)-1);
              prMessageLOG('TManageThread.Execute: ������ '+Command.IP+' ������ �� StopList.', 'system');
            end;
            if (AppStatus=stSuspended) and (Length(StopList)=0) then begin
              prMessageLOG('TManageThread.Execute: �������� ��������� prResumeAll.', 'system');
              prResumeAll;
            end;
          end;
        scExit: begin //-------------------------------------------------- �����
            prMessageLOG('TManageThread.Execute: �������� ������ �� ������� �� '+Command.IP, 'system');
            ServiceGoOut:= True;                // ������������� ���� - ����������
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
  ExpressFlag:= false; // ���� �������� ���������� WorkProc
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
    ExpressFlag:= False; // ���� �������� ���������� WorkProc
    i:= 0;
    while (i<CycleInterval) and not FStopFlag and not FSafeSuspendFlag and not ExpressFlag do begin
      Inc(i);
      Sleep(997); // ����� ������� (������� ����� - �� ����.������)
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
    fnWriteToLog(ThreadData, lgmsInfo, ThreadName, '������������ ������.', '', '');
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
    fnWriteToLog(ThreadData, lgmsInfo, ThreadName, '������ ������.', '', '');
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
const nmProc = 'TCheckDBConnectThread_WorkProc'; // ��� ���������/�������/������
var fOpen: boolean;
    rIniFile: TINIFile;
begin
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  try try
    CycleInterval:= rIniFile.ReadInteger('intervals', 'CheckDBConnectInterval', 30);

    prSetPoolsRunParams(rIniFile); // ��������� ���������� ��������� ���������
    fOpen:= AppStatus in [stStarting, stWork, stResuming];
//------------------------------------------------- �������� ���������� � ������
    cntsORD.CheckBaseConnection(CycleInterval, fOpen);
    cntsLOG.CheckBaseConnection(CycleInterval, fOpen);
    cntsGRB.CheckBaseConnection(CycleInterval, fOpen);
    if Cache.AllowWebArm then begin
      cntsTDT.CheckBaseConnection(CycleInterval, fOpen);
      cntsSUF.CheckBaseConnection(CycleInterval, fOpen);
      cntsSUFORD.CheckBaseConnection(CycleInterval, fOpen);
      cntsSUFLOG.CheckBaseConnection(CycleInterval, fOpen);
    end;

    RepeatSaveInterval:= rIniFile.ReadInteger('intervals', 'RepeatSaveInterval', 100); // �������� �������� ������� ������ � ����
    RepeatStopInterval:= rIniFile.ReadInteger('intervals', 'RepeatStopInterval', 5);   // �������� �������� �������� ��������� � ���
    accRepeatCount    := rIniFile.ReadInteger('intervals', 'accRepeatCount', 6);       // ���-�� ������� ������� �����
//    FlagCachePath:= fnTestDirEnd(rIniFile.ReadString('service', 'FlagCachePath', '..\'));

    with Cache do begin
//      TestCacheAlterInterval:= rIniFile.ReadInteger('intervals', 'TestCacheAlterInterval', 5); // �������� �������� ���� �� alter-�������� � ��� (����� ���� � ��������)
//      if (Now>IncMinute(LastTimeMemUsed, TestCacheInterval)) then MemUsedToLog('check mem');
//      flAccTimeToLog    := rIniFile.ReadInteger('Logs', 'AccTimeToLog', 0)=1;
      TestCacheInterval   := rIniFile.ReadInteger('intervals', 'TestCacheInterval', 30);   // �������� ������ �������� ���� � ��� (����� ���� � ��������)
      TestCacheNightInt   := rIniFile.ReadInteger('intervals', 'TestCacheNightInt', TestCacheInterval*3); // ������ ��������
      if (TestCacheNightInt<TestCacheInterval) then TestCacheNightInt:= TestCacheInterval; // ������ �������� �� ����� ���� ������ ��������
      FirmActualInterval  := rIniFile.ReadInteger('intervals', 'FirmActualInterval', 5);   // �������� ������������ ���� 1 ����� � ��� (����� ������)
      ClientActualInterval:= rIniFile.ReadInteger('intervals', 'ClientActualInterval', 5); // �������� ������������ ���� 1 ������� � ���
      flSendZeroPrices    := rIniFile.ReadInteger('threads', 'SendZeroPricesMail', 0)=1;
      flCheckDocSum       := rIniFile.ReadInteger('threads', 'CheckDocSum', 0)=1;          // �������� ���� ���-���
      flCheckCliEmails    := rIniFile.ReadInteger('threads', 'CheckCliEmails', 0)=1;       // �������� Email
      WebAutoLinks        := rIniFile.ReadInteger('threads', 'WebAutoLinks', 0)=1;
      HideOnlySameName    := rIniFile.ReadInteger('threads', 'HideOnlySameName', 0)=1;
      HideOnlyOneLevel    := rIniFile.ReadInteger('threads', 'HideOnlyOneLevel', 0)=1;
      flCheckClosingDocs  := rIniFile.ReadInteger('threads', 'CheckClosingDocs', 0)=1;
    end; // with Cache
{
    FormingOrdersLimit:= rIniFile.ReadInteger('threads', 'FormingOrdersLimit', 10); // ����� ����� � ������ ���������� ������� (5-50)
    if (FormingOrdersLimit<5) then FormingOrdersLimit:= 5;
    OrderListLimit:= rIniFile.ReadInteger('threads', 'OrderListLimit', 0); // ����� ����� � ������ �������, 0- �� ��������� ��� >= 20
    if (OrderListLimit>0) and (OrderListLimit<20) then OrderListLimit:= 20;
}
    PhoneSupport:= rIniFile.ReadString('Options', 'PhoneSupport', '0-800-30-20-02'); // ������� ������ ���������
//---------------------- ���������
    flTest:= rIniFile.ReadInteger('Options', 'flTest', 0)=1;
    flTestDocs:= rIniFile.ReadInteger('Options', 'flTestDocs', 0)=1;
    flDebug:= rIniFile.ReadInteger('Options', 'flDebug', 0)=1; // ���� �������
    flmyDebug:= rIniFile.ReadInteger('Options', 'flmyDebug', 0)=1;                 // ��� ���� ������� (���������)
    flSkipTestWares:= rIniFile.ReadInteger('Options', 'flSkipTestWares', 0)=1;     // ���� �������� �������� ������� ��� ��������� �������
    flLogTestWares:= rIniFile.ReadInteger('Options', 'flLogTestWares', 0)=1;       // ���� ������ � ��� ������ �������� ���� �������
    flLogTestClients:= rIniFile.ReadInteger('Options', 'flLogTestClients', 0)=1;   // ���� ������ � ��� ������ �������� ���� ��������
    flTmpRecodeCSS:= rIniFile.ReadInteger('Options', 'flTmpRecodeCSS', 0)=1;       // ���� ������� ������������� ���� �����������
    flTmpRecodeORD:= rIniFile.ReadInteger('Options', 'flTmpRecodeORD', 0)=1;       // ���� ������� ������������� ���� ORD
    flTmpRecodeGRB:= rIniFile.ReadInteger('Options', 'flTmpRecodeGRB', 0)=1;       // ���� ������� ������������� ���� Grossbee
//---------------------- �� ������������ ����
    flMargins:= rIniFile.ReadInteger('Options', 'flMargins', 0)=1;                 // ���� �������
    flShowAttrImage:= rIniFile.ReadInteger('Options', 'flShowAttrImage', 0)=1;     // ���� ������ ������ � ������� ���������
    flBonusAttr:= rIniFile.ReadInteger('Options', 'flBonusAttr', 0)=1;             // ���� ��������� ��������
    flMeetPerson:= rIniFile.ReadInteger('Options', 'flMeetPerson', 0)=1;           // ���� ����� ���� ����� "�����������"
    flNewModeCGI:= rIniFile.ReadInteger('Options', 'flNewModeCGI', 0)=1;           // ���� �������   //sn
    flContCurrPrice:= rIniFile.ReadInteger('Options', 'flContCurrPrice', 0)=1;     // ���� ������ ������ � ������ ���������
    flCheckLimits:= rIniFile.ReadInteger('Options', 'flCheckLimits', 0)=1;         // ���� �������� ������� �� ���-�� � ����
//---------------------- �����������
    flNewDocNames:= rIniFile.ReadInteger('Options', 'flNewDocNames', 1)=1;         // ���� ������ �������� ���-���
    flDisableOut := rIniFile.ReadInteger('Options', 'flDisableOut', 1)=1;          // ���� ������� �� ������ � webarm � ������� IP
    flNewSaveAcc := rIniFile.ReadInteger('Options', 'flNewSaveAcc', 1)=1;          // ���� ������ ����� � ������������
    flSpecRestSem:= rIniFile.ReadInteger('Options', 'flSpecRestSem', 0)=1;         // ���� ����� �������� �� �������
    flMotulTree:= rIniFile.ReadInteger('Options', 'flMotulTree', 0)=1;             // ���� ������� Motul (��� ���������� webarm)
    flNotReserve:= rIniFile.ReadInteger('Options', 'flNotReserve', 0)=1;           // ���� ������� ��������������
//    TodayFillDprts:= rIniFile.ReadString('Options', 'TodayFillDprts', '');         // ������ �������� �� ������� (����� - ���)
    flNewBonusFilter:= rIniFile.ReadInteger('Options', 'flNewBonusFilter', 0)=1;   // ���� ������� �������� MOTUL
    flCredProfile:= rIniFile.ReadInteger('Options', 'flCredProfile', 0)=1;         // ���� ������ ����.������� �� ��������
    flOrderImport:= rIniFile.ReadInteger('Options', 'flOrderImport', 0)=1;         // ���� �������� �������
    flNewRestCols:= rIniFile.ReadInteger('Options', 'flNewRestCols', 0)=1;         // ���� ������ ������ �������� �� ��������
    flShowWareByState:= rIniFile.ReadInteger('Options', 'flShowWareByState', 0)=1; // ���� ������ ������� �� �������
    flTradePoint:= rIniFile.ReadInteger('Options', 'flTradePoint', 0)=1;           // ���� ���������� ����.�������
//---------------------- �����
    flPictNotShow:= rIniFile.ReadInteger('Options', 'flPictNotShow', 0)=1;         // ���� ���������� ��������� "�� ���������� ��������"
    flWareForSearch:= rIniFile.ReadInteger('Options', 'flWareForSearch', 0)=1;     // ���� �������� ������ ������� � ������ (Web)
    flNewOrdersMode:= rIniFile.ReadInteger('Options', 'flNewOrdersMode', 0)=1;         // ���� ������ �������� ������ �� ����� �����
    flNewOrderMode:= rIniFile.ReadInteger('Options', 'flNewOrderMode', 0)=1;         // ���� ������ �������� ������ �� ����� �����
    flGetExcelWareList:= rIniFile.ReadInteger('Options', 'flGetExcelWareList', 0)=1;         // ���� ������ �������� ������ �� ����� �����

    if not IsServiceCSS and fIconExist and (iAppStatus<0) and Application.MainForm.Visible then begin // ����������� �����
      Synchronize(Application.MainForm.Hide); //
      Application.ProcessMessages;
      iAppStatus:= 0;
    end;

//-------------------------------------------- ���������� / �������� ���� � �.�.
    with Cache do if GetAllBasesConnected then begin
//      if flCheckDocSum and (GetConstItem(pcCheckDocSumDelta).DoubValue<0.001) then  // ���� ������ !!!
//        SaveNewConstValue(pcCheckDocSumDelta, GetConstItem(pcEmplORDERAUTO).IntValue, '0.00999');
      if fOpen then begin
        TestConnections(); // ����� � ��� ���.� ���������
        if not WareCacheTested then // ���������� / �������� ���� (ExpressFlag=True - ������ � ���)
          TestDataCache(not ExpressFlag);
  //        thTTestCache:= TTestCacheThread.Create(ExpressFlag); // ���������� / �������� ���� (ExpressFlag=True - ������ � ���)
      end;

      if flCheckDocSum      then CheckDocSum;         // �������� ���� ���-���
      if flCheckClosingDocs then CheckClosingDocsAll; // �������� �������� ����������� ���-��� �������
      if flSendZeroPrices   then SendZeroPricesMail;  // ����� � ������� � �������� ������
      if flCheckCliEmails   then CheckClientsEmails;  // �������� Email-��

      if flTmpRecodeCSS then TmpRecodeCSS; // ������� ������������� � ���� �����������
      if flTmpRecodeORD then TmpRecodeORD; // ������� ������������� � ���� ORD
      if flTmpRecodeGRB then TmpRecodeGRB; // ������� �������������/������ ������ � ���� Grossbee

//      prCheckSelfRestart; // ��������� ����������

      if not SingleThreadExists and Assigned(thSingleThread) then try  // ???
        prFree(thSingleThread);
      except end;

      TestCssStopException;
      if AllowWebArm  // ���������� �������� �������� ������ �� TDT
        and (AppStatus=stWork)                                           // ������� �����
        and (GetConstItem(pcSelfStartAddLoadWare).IntValue=1)            // ���������� �������
        and (GetConstItem(pcLastAddLoadWare).IntValue>0)                 // ���������� ���������
        and (fnGetActionTimeEnable(caeSmallWork) or flmyDebug)           // ��������� �����
        and (Cache.LongProcessFlag=cdlpNotLongPr)                        // �� ������� ������� �������
        and (ImpCheck.CheckList.Count<1)                                 // �� ������� �����/������
        and not SingleThreadExists                                       // ����.����� �� �������
        then thSingleThread:= TSingleThread.Create(csthLoadData, False); // ��������� � ��������� ������
    end; // with Cache
  except
    on E:Exception do begin
      prMessageLOG(nmProc+' - ���������� ������������ try '+E.Message);
      try
        prMessageLOG('FSafeSuspendFlag='+BOBBoolToStr(FSafeSuspendFlag));
        prMessageLOG('FStopFlag='+BOBBoolToStr(FStopFlag));
      except
       on E:Exception do prMessageLOG(nmProc+' - ������ ������ ������������ ������ '+E.Message);
      end;
    end;
  end;
  finally
    prFree(rIniFile);
  end;
end; // WorkProc
//==============================================================================
constructor TCheckDBConnectThread.Create(CreateSuspended: Boolean; AThreadType: integer);
const nmProc = 'TCheckDBConnectThread'; // ��� ���������/�������/������
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'thCheckDBConnectThread';
  prMessageLOG(nmProc+': ������ ������ �������� ���������� � ��');
end;
//==============================================================================
procedure TCheckDBConnectThread.DoTerminate;
begin
  inherited;
  prMessageLOG(ThreadName+': ���������� ������ �������� ����������');
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
        ' and DATEDIFF(SECOND, ORDRTOPROCESSDATE, cast("NOW" as timestamp))>:interval'; // "��������" ������
      OrdIBS.ParamByName('interval').AsInteger:= CycleInterval;
      OrdIBS.ExecQuery;
      while not (OrdIBS.Eof or FSafeSuspendFlag or FStopFlag) do begin
        i:= OrdIBS.FieldByName('ORDRFIRM').AsInteger;
        s:= '�� ������ '+OrdIBS.FieldByName('ORDRNUM').AsString+
            ', ��� '+OrdIBS.FieldByName('ORDRCODE').AsString;
        Cache.TestFirms(i, true, true);  // ������ ��������
        if not Cache.FirmExist(i) then
          fnWriteToLog(ThreadData, lgmsSysError, ThreadName, '�� ������� �����'+
            ' ��� '+IntToStr(i)+' ��� ������������ ����� '+s, '', '')
        else if Cache.arFirmInfo[i].SKIPPROCESSING then begin
          OrderID:= OrdIBS.FieldByName('ORDRCODE').AsInteger;
          Stream.Clear;
          try
//            if flNewSaveAcc then begin
              // �������� ������ � ���� Grossbee � ������������ ������
              jj:= fnOrderToGB(OrderID, True, True, ss, ThreadData);

{            end else begin
              Stream.WriteInt(OrderID);
              Stream.WriteBool(True); // ��������� ��������� ��������
              prOrderToGBn_Ord(Stream, ThreadData, True); // ������
              Stream.Position:= 0;
              jj:= Stream.ReadInt;
            end; }

            if (jj in [aeSuccess, erWareToAccount]) then begin
              s:= '����������� ���� '+s;
              fnWriteToLog(ThreadData, lgmsInfo, ThreadName, s, '', '');
              prMessageLOGS(ThreadName+': '+s, 'system');
            end;
          except
            on E:Exception do fnWriteToLog(ThreadData, lgmsSysError, 
              ThreadName, '������ ������������ ����� '+s, E.Message, '');
          end;
        end;
        TestCssStopException;
        OrdIBS.Next;
      end;
    finally
      prFreeIBSQL(OrdIBS);
      cntsOrd.SetFreeCnt(OrdIBD);
    end;
    CheckClonedOrBlockedClients; // �������� ������/������ ��������
  except
    on E:Exception do fnWriteToLog(ThreadData, lgmsSysError, ThreadName, '������ WorkProc', E.Message, '');
  end;
end;
//==============================================================================
constructor TCheckStoppedOrders.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'thCheckStoppedOrders';
  prSetThLogParams(ThreadData, 0, 0, 0, ThreadName); // ����������� � ib_css
  Stream:= TBOBMemoryStream.Create;
end;
//==============================================================================
procedure TCheckStoppedOrders.DoTerminate;
begin
  prFree(Stream);
  inherited;
end;

//******************************************************************************
//                           ���������� ��������
//******************************************************************************
function fnServerInit: boolean;   // ��������� ����������� � �������� � ��.
const nmProc = 'fnServerInit'; // ��� ���������/�������
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
    prCreatePools(IniFile);   // ������� ����
    MyClass:= TMyClass.Create;
    FullLog:= IniFile.ReadBool('Logs', 'FullLog', true);
    SetAppCaption; // ��������� �����
    Application.ProcessMessages;

    Cache:= TDataCache.Create; // ������� ���

    with Cache do begin // ��������, ����� ������ ���������. �������� �� ����������� ����
      AllowWeb          := IniFile.ReadInteger('Threads', 'Web', 0)=1;
      AllowWebArm       := IniFile.ReadInteger('Threads', 'WebArm', 0)=1;
      AllowCheckStopOrds:= IniFile.ReadInteger('Threads', 'CheckStoppedOrders', 0)=1;
    end;

    prMessageLOG(GetMessToLogPools(0, Cache.AllowWebArm), 'system'); // ��������� � ����� � ��������� ��� ��� ��������

    DirFileErr:= GetAppExePath+IniFile.ReadString('mail', 'ErrFilesPath', 'mailerrfiles'); // ����� �/������� � ����. ������
    if not DirectoryExists(DirFileErr) and // ���� ����� ��� - ���������
      not CreateDir(DirFileErr) then begin
      prMessageLOGS(nmProc+': �� ���� ������� ����� '+DirFileErr);
      DirFileErr:= GetAppExePath;
    end;
    DirFileErr:= fnTestDirEnd(DirFileErr);

    // � ��������� ������ ��������� �������� ���������� � ������ ������
    thCheckDBConnectThread:= TCheckDBConnectThread.Create(true, thtpCheckDBConnect);
    TCSSCyclicThread(thCheckDBConnectThread).CSSResume;
    Application.ProcessMessages;

    // � ��������� ������ ��������� ��������� ����� ����������� ������
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
        prMessageLOGS(nmProc+': ������ ������������� ��������� ����������� �������� �� ����� '+
          IntToStr(ServerManage.DefaultPort)+': '+E.Message+'. �������� ������.');
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
        prMessageLOGS(nmProc+': ������ ������������� ��������� �������� Web �� ����� '+
          IntToStr(ServerWeb.DefaultPort)+': '+E.Message+'. �������� ������.');
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
        prMessageLOGS(nmProc+': ������ ������������� ��������� �������� WebArm �� ����� '+
          IntToStr(ServerWebArm.DefaultPort)+': '+E.Message+'. �������� ������.');
        exit;
      end;
    end;
//---------------------------------------------------

    while not GetReadyWorkOrStop do  // ���� ���������� � ������
      for i:= 1 to 3 do begin
        Application.ProcessMessages; // ��� ����� ������ ��������� �������
        if (IsServiceCSS and ServiceGoOut) or
          (not IsServiceCSS and (AppStatus<>stStarting)) then exit;
        sleep(997);
      end;

    if (ServerID<1) then ServerID:= fnGetServerID;
    if (ServerID<1) then raise Exception.Create('������ ServerID.');
    MainThreadData:= fnCreateThread(thtpMain); // ���������� � ��� ���� � �������� �������� ������

    s:= GetMessToLogPools(1);  // ��������� � ����� � ���-���� ��� ��������
    try
      prSetThLogParams(MainThreadData, 0, 0, 0, s); // ����������� � ib_css
    except
      on E:Exception do prMessageLOG('������ ���������� ���������� � ������ ������'+
        #10'����� ������: '+E.Message+#10'������: '+s);
    end;

    thTestMailFiles:= TTestMailFilesThread.Create(False, thtpTestMailFiles); // ����� ������� ����� �� ������
    Application.ProcessMessages;

    //----------------- � ��������� ������ ��������� �������� "��������" �������
    if Cache.AllowCheckStopOrds then begin
      thCheckStoppedOrders:= TCheckStoppedOrders.Create(true, thtpStoppedOrders);
      TCSSCyclicThread(thCheckStoppedOrders).CSSResume;
    end;

    SetAppStatus(stWork);

    Result:= true;
    ErrorExit:= False; // ������� ��������� �������
    if not IsServiceCSS and fIconExist then iAppStatus:= -1; // ���� - ������ ����� ���������
//    MemUsedToLog('begin work');

    // CSSWebArm - ������ ������������ �������� � �.�.
    // CSSWeb - ���������� ����
if not flDebug then
    thSingleThread:= TSingleThread.Create(csthStart, False);
    Application.ProcessMessages;

    thCheckSMSThread:= nil;
    thControlPayThread:= nil;
    thControlSMSThread:= nil;
    //-------------------------------------- � Webarm ��������� ��������� ������
    if Cache.AllowWebArm then begin
      try                    // ����� �������� ���
        thCheckSMSThread:= TCheckSMSThread.Create(true, thtpSMSThread);
        TCSSCyclicThread(thCheckSMSThread).CSSResume;
      except
        on E: Exception do prMessageLOGS(nmProc+'������ ������� ������: '+E.Message);
      end;
      Application.ProcessMessages;
      try                    // ����� �������� ��������� ������� ������ ��������
        thControlPayThread:= TControlPayThread.Create(true, thtpControlPayThread);
        TCSSCyclicThread(thControlPayThread).CSSResume;
      except
        on E: Exception do prMessageLOGS(nmProc+'������ ������� ������: '+E.Message);
      end;
      Application.ProcessMessages;
      try                    // ����� �������� ��������� ������� �������� ���
        thControlSMSThread:= TControlSMSThread.Create(true, thtpControlSMSThread);
        TCSSCyclicThread(thControlSMSThread).CSSResume;
      except
        on E: Exception do prMessageLOGS(nmProc+'������ ������� ������: '+E.Message);
      end;
      Application.ProcessMessages;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message+#10'��������� ���������� ������.');
  end;
  finally
    prFree(IniFile);
  end;
end; // fnServerInit
//==============================================================================
procedure prServerExit; // ���������� ����� �����, ����������� �� ��������, ADS � ��.
const nmProc = 'prServerExit'; // ��� ���������/�������
var CanClose, fl: boolean;
    i, j, StartWebCount, testWebCount, // ��� ������������ �������� Threads
      StartWebArmCount, testWebArmCount, StartManageCount, testManageCount: integer;
    LocalStart: TDateTime;
//---------------------  �������� ��������� TIDTCPServer
  procedure ServerStartClose(var Server: TIDTCPServer; var StartCount, testCount: integer);
  begin
    StartCount:= 0;
    testCount:= 0;
    if not Assigned(Server) then Exit;
    Server.MaxConnections:= 1; // ������� ����� �������� ����������
    StartCount:= fnGetThreadsCount(Server); // ���������� ��������� ���-�� Threads
  end;
//---------------------  ������� ���������� TIDTCPServer
  procedure CloseServer(var Server: TIDTCPServer; var StartCount, testCount: integer);
  var ThreadsCount: integer;
  begin
    if not Assigned(Server) or not Server.Active then Exit;
    ThreadsCount:= fnGetThreadsCount(Server); // ���������� ���-�� Threads
    if ThreadsCount=StartCount then inc(testCount) // ���� ���-�� �� ���������� - ����������� �������
    else begin    // ���� ���-�� WebThreads ���������� - ���������� �������
      StartCount:= ThreadsCount;
      testCount:= 0;
    end;
    if ThreadsCount>0 then
      prMessageLOG('Info: '+Server.Name+'.Contexts.Count = '+IntToStr(ThreadsCount));
    if (fnGetThreadsCount(Server)<2) then begin
      i:= 0;
      while (i<10) and (fnGetThreadsCount(Server)>0) do begin // ������� �������� ��������� Context 1 ���
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
    if Server.Active and (testCount>RepeatCount) then begin // ���� ���-�� �� �������� - �������, ��� �������
      DataSetsManager.ClearCntsItem(Pointer(Server));
      Server:= nil;  // ����� �������� �� ����� �������� Free
      ErrorExit:= True;  // ������� ��������� �������
      prMessageLOG('Info: '+Server.Name+':= nil');
    end;
  end;
//------------------------------------------   ���������
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
  prMessageLOG(nmProc+': ������� ���������� ������ ');
  try
    fl:= (AppStatus=stSuspended);
    SetAppStatus(stExiting);
    if fl then prResumeAll; // ���� �� stSuspended ����� �������� - ���� Ac.Violation

    CanClose:= false;

    ServerStartClose(ServerWeb, StartWebCount, testWebCount); // �������� ��������� TIDTCPServer
    ServerStartClose(ServerWebArm, StartWebArmCount, testWebArmCount);
    ServerStartClose(ServerManage, StartManageCount, testManageCount);

//    if Assigned(thManageThread) then thManageThread.Terminate;
    if Assigned(thCheckDBConnectThread) then TCSSCyclicThread(thCheckDBConnectThread).Stop;
    if Assigned(thCheckStoppedOrders) then TCSSCyclicThread(thCheckStoppedOrders).Stop;
    if Assigned(thTestMailFiles) then thTestMailFiles.Stop; // ����� ������� ����� �� ������
    if Assigned(thCheckSMSThread) then TCSSCyclicThread(thCheckSMSThread).Stop;
    if Assigned(thControlPayThread) then TCSSCyclicThread(thControlPayThread).Stop;
    if Assigned(thControlSMSThread) then TCSSCyclicThread(thControlSMSThread).Stop;

    LocalStart:= now();
    prSuspendPools;   // ���������� ����
    if flTest then prMessageLOGS(nmProc+'_prSuspendPools: - '+
      GetLogTimeStr(LocalStart), fLogDebug, false);
    Application.ProcessMessages;

    Application.ProcessMessages;

    prFree(ImpCheck);
    j:= 0;
    LocalStart:= now();
    while not CanClose and (j<RepeatStopInterval) do begin
      CloseServer(ServerWeb, StartWebCount, testWebCount); // ������� ���������� TIDTCPServer
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
    prFreePools; //  (����� ����)
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
      prMessageLOG(nmProc+': ������ ��� ���������� ������ '+E.Message);
      ErrorExit:= True;
    end;
  end;
  if not IsServiceCSS and Assigned(PopupMenuIcon) then prFree(PopupMenuIcon);
  SetLength(arManageCommands, 0);
  SetLength(StopList, 0);
  SetAppStatus(stClosed);
  Application.ProcessMessages;

  if ErrorExit then prErrorShutDown; // ���� ���-�� ������� - ��������� ����������
end; // prServerExit
//==============================================================================
procedure prSafeSuspendAll;
const nmProc = 'prSafeSuspendAll'; // ��� ���������/�������
var i: integer;
    LocalStart: TDateTime;
begin
  prMessageLOG(nmProc+': �������� � ��������� Suspended');
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
      sleep(499); // ���� �������, ����� ������������ ������
      Application.ProcessMessages;
      prSuspendPools;   // ���������� ����
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
      on E: Exception do prMessageLOG(nmProc+': ������ ��� ���������: '+#10+E.Message);
    end;

    if Cache.AllowWebArm and (ImpCheck.CheckList.Count>0) then begin // ���� ������� ����� � ������ (WebArm)
      for i:= 0 to ImpCheck.CheckList.Count-1 do try
        TCheckProcess(ImpCheck.CheckList.Items[i]).Free;
      except end;
      ImpCheck.CheckList.Clear;
    end;

    SetAppStatus(stSuspended);
    prMessageLOG(nmProc+': ��� ������ ��������������.');
    prMessageLOG(nmProc+': ������� � ��������� Suspended');
    if not GetAllBasesConnected(False, True) then begin
      Exit;  // ???
    end;

//    MemUsedToLog('suspended');
//    prMessageLOGS(' ', 'MemUsed', false);
//    prMessageLOGS('������ ��������� ������', 'MemUsed', false);
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
const nmProc = 'prResumeAll'; // ��� ���������/�������
begin
  try
    if AppStatus<>stExiting then begin
      prMessageLOG(nmProc+': �������� � ��������� Worked');
      SetAppStatus(stResuming);
    end;
    prResumePools; // �������������� ����
//    Cache.CSSResume;
    TCheckDBConnectThread(thCheckDBConnectThread).CSSResume;

    if AppStatus<>stExiting then
      while not GetAllBasesConnected do begin // ���� ���������� � ������
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
      fnWriteToLog(MainThreadData, lgmsInfo, nmProc, '��� ������ ��������.', '', '');
      prMessageLOG(nmProc+': ������� � ��������� Worked');

//      MemUsedToLog('resumed');
    end;
  except
    on E: Exception do prMessageLOG(nmProc+': '+E.Message);
  end;
end; // prResumeAll
//========================== ���������� ������� ����������/������������ ���� ���
function GetAllBasesConnected(conn: boolean=True; flSUF: boolean=False): boolean;
begin
  if conn then begin // ������� ���������� ���� ���
    Result:= cntsGRB.BaseConnected and cntsLOG.BaseConnected and cntsORD.BaseConnected;
    if Cache.AllowWebArm then begin
      if not cntsTDT.PoolNotInit then Result:= Result and cntsTDT.BaseConnected;
      if flSUF and not cntsSUF.PoolNotInit then Result:= Result and cntsSUF.BaseConnected;
      if flSUF and not cntsSUFORD.PoolNotInit then Result:= Result and cntsSUFORD.BaseConnected;
      if flSUF and not cntsSUFLOG.PoolNotInit then Result:= Result and cntsSUFLOG.BaseConnected;
    end;
  end else begin   // ������� ������������ ���� ���
    Result:= not cntsGRB.BaseConnected and not cntsLOG.BaseConnected and not cntsORD.BaseConnected;
    if Cache.AllowWebArm then begin
      if not cntsTDT.PoolNotInit then Result:= Result and not cntsTDT.BaseConnected;
      if flSUF and not cntsSUF.PoolNotInit then Result:= Result and not cntsSUF.BaseConnected;
      if flSUF and not cntsSUFORD.PoolNotInit then Result:= Result and not cntsSUFORD.BaseConnected;
      if flSUF and not cntsSUFLOG.PoolNotInit then Result:= Result and not cntsSUFLOG.BaseConnected;
    end;
  end;
end;
//=================================== ������� ���������� �������� / ������������
function GetReadyWorkOrStop(Work: boolean=True): boolean;
// ��� Work=True  - ���������� ������� ���������� ��������
// ��� Work=False - ���������� ������� ���������� ������������
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
//======================================== ������� ���������� �������� �� ������
function GetMessageNotCanWorks: string;
// ���������� ����� ���������, ���� �� ����� �������� �� ������
begin
  Result:= '';
  if GetAllBasesConnected and (AppStatus=stWork) then Exit;
  case AppStatus of
    stWork: Result:= '������ ���������� � ����� ������.';
    stStarting, stResuming:
            Result:= '�������� ����������� ���������� � ����� ������.';
    stSuspending, stSuspended, stExiting, stClosed:
            Result:= '������ ����������� ������� ���� �� ��������, ������� '+
                     '����������� ������. �������� ��������� �� ��������� ����������.';
  end;
//  Application.ProcessMessages;
end;
{//========================================================= ������ - ����� � ���
procedure MemUsedToLog(comment: String);
begin
  prMessageLOGS(FormatFloat(fnMakeAddCharStr(comment, 10, True)+
    ' : , .# K', fnGetCurrentMemoryUsage/1024), 'MemUsed', false);
  Cache.LastTimeMemUsed:= Now;
end;  }
//================================ ������������ ������ ������� � �������� ������
procedure SendZeroPricesMail;
const nmProc = 'SendZeroPricesMail'; // ��� ���������/�������/������
var s, ss, sSort, sAdress, sSubj: string;
    i: integer;
    lstW: TStringList;
    lasttime: TDateTime;
    ware: TWareInfo;
begin
  if not Assigned(Cache) then Exit;
  if not fnGetActionTimeEnable(caeOnlyWorkTime) then Exit; // ������ � ������� �����
  if not Cache.flSendZeroPrices then Exit;

  sAdress:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ����� Email ������ ���
  if sAdress='' then Exit; // ���� �� ����� �����

  i:= Cache.GetConstItem(pcZeroPricesIntHour).IntValue;      // �������� � �����
  lasttime:= Cache.GetConstItem(pcZeroPricesTime).DateValue; // ����� �������� ����.������
  if (Now<IncHour(lasttime, i)) then Exit; // ���� �� ������ �������� ��������

  lstW:= fnCreateStringList(False, 100);
  Cache.flSendZeroPrices:= False;  // ��������� ���� (������ �� ��������� �����)
  try try
    setLength(sSort, 90); // ������ ������� � ������� ����� (��� ����������)
    for i:= 1 to High(Cache.arWareInfo) do begin
      if not Cache.WareExist(i) then Continue;
      ware:= Cache.GetWare(i);
      if ware.IsArchive or ware.IsINFOgr or not Cache.PgrExists(ware.PgrID) then Continue;
      if (ware.PgrID=Cache.pgrDeliv) then Continue; // ���������� ��������
// � ����� �� ������ �������� ������ �� ��������� "����������, "����", "�������" (01.11.2017, ��)
      if (ware.WareState in [cWStatePrepare, cWStateInfo, cWStatePublic]) then Continue;
      if ware.IsMarketWare then Continue;
      s:= copy(ware.PgrName, 1, 40);
      ss:= copy(ware.Name, 1, 50);

      sSort:= fnMakeAddCharStr(s, 40, True)+ss;
      lstW.Add(sSort);
    end;

    if (lstW.Count<1) then lstW.Add('������ � �������� ������ �� �������.')
    else begin
      lstW.Sort; // ���������
      for i:= 0 to lstW.Count-1 do begin // ��� ������ � ������� ����� (+ ���������) ��� ��������
        s:= copy(lstW[i], 41, 30); // Ware.Name
        ss:= copy(lstW[i], 1, 40); // Ware.PgrName
        lstW[i]:= '��� ���� - '+fnMakeAddCharStr(s, 40, True)+ss;
      end;
    end;

    //------------------------- ���������� ����� � ������� � �������� ������
    ss:= FormatDateTime(cDateTimeFormatY4S, Now);
    sSubj:= '����� � ������� � �������� ������ �� '+ss;
    s:= n_SysMailSend(sAdress, sSubj, lstW, nil, '', '', true);

    if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then // ���� �� ���������� � ����
      prMessageLOGS(nmProc+': ������ �������� ������ "'+sSubj+'" �� E-mail '+sAdress+': '+s, 'system')
    else begin
      prMessageLOGS(nmProc+': ���������� ������ "'+sSubj+'" �� E-mail '+sAdress, 'system');
      i:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
      Cache.SaveNewConstValue(pcZeroPricesTime, i, ss); // ���������� ����� �������� ������
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  finally
    setLength(sSort, 0);
    prFree(lstW);
    Cache.flSendZeroPrices:= True; // �������� ����
  end;
  TestCssStopException;
end;

//******************************************************************************
//                   ����� ������� ����� �� ������
//******************************************************************************
constructor TTestMailFilesThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'TestMailFilesThread';
  prSetThLogParams(ThreadData, ccTestMailFiles, 0, 0, ThreadName); // ����������� � ib_css
end;
//==============================================================================
destructor TTestMailFilesThread.Destroy;
begin
  inherited Destroy;
end;
//==============================================================================
procedure TTestMailFilesThread.WorkProc; // �����, ���� �������� ����� �� ���� �������� ������
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
    flag:= (FindFirst(shablon, faAnyFile, SearchRec)=0); // ���� ����� �����
    if not flag then Exit;

    while flag and not FStopFlag do begin
      body.Clear;
      Attachments.Clear;
      file_name:= fnGetMailFilesPath+SearchRec.Name;

      if not FileExists(fnGetLockFileName(file_name)) then try // ���� ��� ����������

        body.AddStrings(fnStringsLogFromFile(file_name, False)); // ��������� ������ �����
        if body.Count<5 then begin
          s:= RenameErrFile(SearchRec.Name, dir, DirErr);
          raise Exception.Create('���� ����� � ����� '+SearchRec.Name+' '+s);
        end;
        ToAdres:= body.Strings[0]; // ��������� ������ ����� � ������
        Subj:= body.Strings[1];
        if body.Strings[2]<>'no' then From:= body.Strings[2];
        if body.Strings[3]<>'no' then Attachments.CommaText:= body.Strings[3];
        for i:= 3 downto 0 do body.Delete(i);

        s:= n_SysMailSend(ToAdres, Subj, body, Attachments, From);
        if s<>'' then raise Exception.Create(s);
        DeleteFile(file_name); // ������� ������������ ����
        try
          if Attachments.Count>0 then ss:= ' '+Attachments.CommaText else ss:= '';
        except
          ss:= '';
        end;                              // ������� ����������� �����
        for i:= 0 to Attachments.Count-1 do DeleteFile(Attachments[i]);
        fnWriteToLogPlus(ThreadData, lgmsSysMess, ThreadName+'.WorkProc',
          '���������� ������ �� ����� '+SearchRec.Name, 'ToAdres='+ToAdres+
          ' Subj='+Subj+fnIfStr(From='', '', ' From='+From)+ss, '');
        if FWroteToLog then FWroteToLog:= False; // ���������� ���� ������ � ���
      except
        on E: Exception do
          if (Pos('��� ����������� � ', E.Message)>0) or
            (Pos('Authentication failed', E.Message)>0) then begin
            if FWroteToLog then E.Message:= '' else FWroteToLog:= True; // ���� ��� �������� � ��� - ����������
            raise Exception.Create(E.Message);
          end else if (Pos('������������ ��������', E.Message)>0)
            or (Pos('Invalid or missing', E.Message)>0)
            or (Pos('Mailbox syntax incorrect', E.Message)>0)
            or (Pos('mailbox not allowed', E.Message)>0) then begin
            s:= RenameErrFile(SearchRec.Name, dir, DirErr);
            if s='' then
              s:= '� ����� '+SearchRec.Name+': '+E.Message+#10'���� ��������� � ����� '+DirErr
            else s:= '� ����� '+SearchRec.Name+': '+E.Message+' '+s;
            errlist.Add(s);
            raise Exception.Create(s);
          end else begin
            fnWriteToLogPlus(ThreadData, lgmsSysError, ThreadName+'.WorkProc',
              '������ ��� �������� ������ �� ����� '+SearchRec.Name, E.Message, '');
          end;
      end;
      flag:= (FindNext(SearchRec)=0); // ���� ���������
    end; // while flag...

    if errlist.Count>0 then begin
      errlist.Insert(0, GetMessageFromSelf);
      s:= fnGetSysAdresVlad(caeOnlyWorkDay);
      s:= n_SysMailSend(s, 'Error send mail from file', errlist, nil, '', '', true);
      if s<>'' then raise Exception.Create('Error send mail to admin'+s);
    end;
  except
    on E: Exception do if E.Message<>'' then
      fnWriteToLogPlus(ThreadData, lgmsSysError, ThreadName+'.WorkProc', '������ ������', E.Message, '');
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
//                TTestCacheThread - ����� �������� ����
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
  Cache.TestDataCache(not FExpress);  // ���������� / �������� ���� (FExpress=True - ������ � ���)
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
const nmProc = 'SingleThread_Execute'; // ��� ���������/�������
var UserID, iHour: Integer;
    ThreadData: TThreadData;
    Stream: TBoBMemoryStream;
    SystemTime: TSystemTime;
  //-----------------------------------
  procedure prSleep;
  var i: Integer;
  begin
    for i:= 1 to 3 do begin
      Application.ProcessMessages; // ��� ����� ������ ��������� �������
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
//----------------------- ���������� �������� �������� ������ �� TDT - CSSWebarm
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

//------------------------------------------------------------ ����� CSS-�������
    csthStart: begin
        while not Cache.WareCacheUnLocked do prSleep; // ���� ���������� ��������� ����
        sleep(5000); // ���� 5 ���
        GetLocalTime(SystemTime); // ��������� �����

    //------------------------------------------------- CSSWeb - ���������� ����
        if Cache.AllowWeb then begin
          if fnGetActionTimeEnable(caeOnlyDay) then iHour:= 1 // ���� (����������) - �������� � ���.���������� ����
          else if (SystemTime.wHour<2) then iHour:= 1         // ����� (����������) - �������� � ���.���������� ����
          else if (DayOfTheWeek(Date)=DayMonday) then iHour:= 24*3 // ����� �� (��������) - �������� � ���.��������� 3 �����
          else iHour:= 24; // ����� ��-�� (��������) - �������� � ���.��������� �����
          TestLastFirms(iHour);
        end; // if Cache.AllowWeb

    //-------------------------- CSSWebArm - ������ ������������ �������� � �.�.
        if Cache.AllowWebArm then begin
          if (SystemTime.wHour<2) then Exit; // ����� (����������) - �������
          while not Cache.WareLinksUnLocked do prSleep; // ���� ���������� ������

          while not SetLongProcessFlag(cdlpFormFiles, True) do prSleep; // ���������� ���� ��������
          try             // ������������ ������-��������
            apReCreateWareDetModPatternFile(constIsAuto); // 19 ������ - Auto
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            apReCreateWareDetModPatternFile(constIsMoto); // 19 ������ - Moto
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            apReCreateWareDetModPatternFile(constIsCV); // 19 ������ - CV
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            apReCreateWareDetModPatternFile(constIsAx); // 19 ������ - Axle
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);


            GetReports30;            // ������������ ������ ������� 30
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            TestOldErrMailFiles;     // �������� ����������� ������ �������
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            TestLogFirmNames;        // �������� ������������ ���� � ���� �����������
            Application.ProcessMessages;
            TestCssStopException;
            sleep(997);

            TmpCheckRecode;          // ���������� �������� � ���� �����������
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
