unit n_DataSetsManager;

interface

uses SysUtils, Classes, IniFiles, Forms, IBDataBase, IBQuery, IBSQL, ADODB, ActiveX,
     n_free_functions, n_constants, n_IBCntsPool;

type
  TDataSetsManager = class
  public
    Cnts: array of Pointer; // ������ ���������� ���������, ������� ����������� ��� Create
    arCntsLocked: Boolean;
    constructor Create;
    destructor Destroy; override;
     function AddCntsItem(p: Pointer): Integer;
    procedure ClearCntsItem(p: Pointer);
     function GetCntsItemIndex(p: Pointer): Integer;
     function GetCntsItemPointer(index: Integer): Pointer;
 end;

  TTRK = (trkTable, trkField, trkProc, trkIndex, trkParInCount);
  TAdoType = (atExcel2003, atExcel2007);
//  TAdoType = (atExcel2003, atExcel2007, atDBF);

var
  DataSetsManager: TDataSetsManager;
  cntsGRB, cntsORD, cntsLOG, cntsSUF, cntsTDT, cntsSUFORD, cntsSUFLOG: TIBCntsPool;

 function fnCreateNewIBQuery(db: TIBDatabase; QueryName: String=''; id: integer=-1; RWparam: Integer=tpRead): TIBQuery; // ������� IBQuery � �������� ���������� Transaction
// function fnNewIBQuery(Database: TIBDatabase; QueryName: String=''; id: integer=-1): TIBQuery; // ������� IBQuery
 function fnSetTransParams(Transaction: TIBTransaction; RWparam: Integer; flStart: Boolean=False): Boolean; // ������ ��������� TIBTransaction
 function fnCreateNewIBSQL(db: TIBDatabase; SQLName: String=''; id: integer=-1;
          RWparam: Integer=tpRead; StartAfterCreate: Boolean=False): TIBSQL;
procedure prFreeIBSQL(var ibs: TIBSQL; CloseTransaction: boolean = true);
procedure prFreeIBQuery(var Query: TIBQuery; CloseTransaction: boolean = true);
//------------------------------------------ ���������� ������
procedure prCreatePools(IniF: TIniFile);
procedure prSetPoolsRunParams(IniF: TIniFile); // ���������� ��������� ���������
procedure prCheckPoolsDatabasePath;            // ��������� ���� � ����� �����
procedure prSuspendPools;
procedure prResumePools;
procedure prFreePools;
 function GetMessToLogPools(vid: integer=0; flWA: boolean=False): String;
//------------------------------------------
 function TestRDB(cnts: TIBCntsPool; kind: TTRK; Name: String; Name1: String=''; parIn: Integer=0): Boolean; // ��������� ������� ���������, �������, ���� � ����

 function CreateADOConnection(DatSource: String; AdoType: TAdoType=atExcel2007): TADOConnection;
 procedure DestroyADOConnection(ADOConnection: TADOConnection);
 function CreateADOTable(ADOConn: TADOConnection; TabName: String=''): TADOTable;
 procedure DestroyADOTable(ADOTable: TADOTable);
 function CreateADOQuery(ADOConn: TADOConnection): TADOQuery;
 procedure DestroyADOQuery(ADOQuery: TADOQuery);

const
  cDefGBLogin  = 'ORDERAUTO';
  cDefGBrole   = 'ALLGBUSER';
  cDefPassword = '12345';
  cDefORDLogin = 'ORDERAUTO';
//                   'Extended Properties="Excel 8.0;HDR=No;MAXSCANROWS=1;";';
//  ADOConStrExcel2003 = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Extended Properties="Excel 8.0;HDR=Yes;IMEX=1;";';
  ADOConStrExcel2003 = 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=%s;Extended Properties="Excel 8.0;HDR=Yes;";';
  ADOConStrExcel2007 = 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=%s;Extended Properties="Excel 12.0 Xml;HDR=YES";';
  ADOConStrDBF       = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Extended Properties=dBASE IV;User ID=Admin;Password=;';
{
http://kbyte.ru/ru/Forums/Show.aspx?id=11017
����� �� ���� Microsoft, ����� �� ������ "Microsoft.ACE.OLEDB.12.0 " ��������� ��� 64-bit:
AccessDatabaseEngine_x64.exe
������: http://www.microsoft.com/downloads/en/details.aspx?FamilyID=c06b8369-60dd-4b64-a44b-84b371ede16d&displaylang=en
��� ����, ����� �� �������� ��� Excel 2007 (������� 32-bit),
  ���� ������ ��������� ��� ���������� ����, ����� ������������� AccessDatabaseEngine_x64.exe, ����� ��������� ���� �����.
  ����� � SQL Server 2008 >> Server Objects >> Linked Servers >> Providers �������� Microsoft.ACE.OLEDB.12.0 � �� ����� ��������.

  http://www.connectionstrings.com/excel/ - Excel connection strings
}
implementation
//============================================================ ������������ � ��


uses n_server_common;//function CreateADOConnection(DatSource: String; AdoType: TAdoType; CoInit: Boolean=True): TADOConnection;
function CreateADOConnection(DatSource: String; AdoType: TAdoType=atExcel2007): TADOConnection;
begin
//  if CoInit then CoInitialize(nil);
  Result:= TADOConnection.Create(nil);
  Result.LoginPrompt:= False;
  Result.Mode:= cmReadWrite;
  case AdoType of
    atExcel2007: Result.ConnectionString:= Format(ADOConStrExcel2007, [DatSource]);  // ???
    atExcel2003: Result.ConnectionString:= Format(ADOConStrExcel2003, [DatSource]);
//    atDBF      : Result.ConnectionString:= Format(ADOConStrDBF, [DatSource]);
  end;
end;
//============================================================ ����������� �� ��
//procedure DestroyADOConnection(ADOConnection: TADOConnection; CoInit: Boolean=True);
procedure DestroyADOConnection(ADOConnection: TADOConnection);
begin
  if not Assigned(ADOConnection) then exit;
  if ADOConnection.InTransaction then ADOConnection.RollbackTrans;
  ADOConnection.Close;
  ADOConnection.ConnectionString:= '';
  prFree(ADOConnection);
//  if CoInit then CoUnInitialize;
end;
//============================================================
function CreateADOTable(ADOConn: TADOConnection; TabName: String=''): TADOTable;
begin
  Result:= TADOTable.Create(nil);
  Result.CursorLocation:= clUseServer;
  Result.Connection:= ADOConn;
  if TabName<>'' then Result.TableName:= TabName;
end;
//============================================================
procedure DestroyADOTable(ADOTable: TADOTable);
begin
  if not Assigned(ADOTable) then exit;
  if ADOTable.Active then ADOTable.Close;
  prFree(ADOTable);
end;
//============================================================
function CreateADOQuery(ADOConn: TADOConnection): TADOQuery;
begin
  Result:= TADOQuery.Create(nil);
  Result.Connection:= ADOConn;
  Result.ConnectionString:= ADOConn.ConnectionString;
end;
//============================================================
procedure DestroyADOQuery(ADOQuery: TADOQuery);
begin
  if not Assigned(ADOQuery) then exit;
  if ADOQuery.Active then ADOQuery.Close;
  prFree(ADOQuery);
end;
//============================================================  ???
{����� ���������� buf ������������� ���������� �������� 101,
  ��� ������������� 16-������� 65 ��� 29-�� �����. ��� �������� ������������� ��������� DOS.
  ������ ��� ���������� �� ����������������� �������� 29-�� ����� ��� ��������� ������� �������, �� ��������.
��� ��������� win1251 ������������������� �������� 29 ����� �9, ��� ������������� ����������� 201.
� ������������ ������� �������� ���� ���: 29 1 n ����� �������� �����
0x01(1) ������� �������� 437 DOS USA,       0x02(2) ������� �������� 850 DOS Multilang
0x26(38) ������� �������� 866 DOS Russian,  0x57(87) ������� �������� 1251 Windows ANSI
0xC8(200) ������� �������� 1250 Windows EE, 0x00(0) ������������
procedure control29byte(dbfName: string);
var f: file;
    buf: byte;
begin
  AssignFile(f, dbfName);
  try
    Reset(f, 1);
    Seek(f, 29);
    BlockRead(f, buf, 1);
    if buf=0 then begin
      buf:= 101;
      Seek(f, 29);
      BlockWrite(f, buf, 1);
    end;
  finally
    CloseFile(f);
  end;  
end;  }
//=================== ��������� ������� ���������, �������, ����, ������� � ����
function TestRDB(cnts: TIBCntsPool; kind: TTRK; Name: String; Name1: String=''; parIn: Integer=0): Boolean;
//  TTRK = (trkTable, trkField, trkProc, trkIndex, trkParInCount);
var IBD: TIBDatabase;
    ibs: TIBSQL;
begin
  Result:= False;
  try
    IBD:= cnts.GetFreeCnt();
  except
    Exit;
  end;
  try
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_TestRDB', -1, tpRead, True);
    case kind of
      trkTable: begin
          ibs.SQL.Text:= 'select RDB$RELATION_NAME from RDB$RELATIONS'+
            ' where RDB$SYSTEM_FLAG=0 and RDB$VIEW_SOURCE is null and RDB$RELATION_NAME=:name';
          ibs.ParamByName('name').AsString:= AnsiUpperCase(Name);
          ibs.ExecQuery;
          Result:= not (ibs.Bof and ibs.Eof)
                   and (ibs.FieldByName('RDB$RELATION_NAME').AsString<>'');
        end;
      trkField: begin
          ibs.SQL.Text:= 'select RDB$FIELD_NAME from RDB$RELATION_FIELDS'+
            ' where RDB$RELATION_NAME=:nTable and RDB$FIELD_NAME=:nField';
          ibs.ParamByName('nTable').AsString:= AnsiUpperCase(Name);
          ibs.ParamByName('nField').AsString:= AnsiUpperCase(Name1);
          ibs.ExecQuery;
          Result:= not (ibs.Bof and ibs.Eof)
                   and (ibs.FieldByName('RDB$FIELD_NAME').AsString<>'');
        end;
      trkProc : begin
          ibs.SQL.Text:= 'select RDB$PROCEDURE_ID from RDB$PROCEDURES'+
            ' where RDB$PROCEDURE_NAME=:procname';
          ibs.ParamByName('procname').AsString:= AnsiUpperCase(Name);
          ibs.ExecQuery;
          Result:= not (ibs.Bof and ibs.Eof)
                   and (ibs.FieldByName('RDB$PROCEDURE_ID').AsInteger>0);
        end;
      trkIndex: begin
          ibs.SQL.Text:= 'select RDB$INDEX_ID from RDB$INDICES'+
            ' where RDB$RELATION_NAME=:nTable and RDB$INDEX_NAME=:nIndex';
          ibs.ParamByName('nTable').AsString:= AnsiUpperCase(Name);
          ibs.ParamByName('nIndex').AsString:= AnsiUpperCase(Name1);
          ibs.ExecQuery;
          Result:= not (ibs.Bof and ibs.Eof)
                   and (ibs.FieldByName('RDB$INDEX_ID').AsInteger>0);
        end;
      trkParInCount: begin // ���-�� ����.�����-�� ���������
          ibs.SQL.Text:= 'select RDB$PROCEDURE_INPUTS from RDB$PROCEDURES'+
            ' where RDB$PROCEDURE_NAME=:procname';
          ibs.ParamByName('procname').AsString:= AnsiUpperCase(Name);
          ibs.ExecQuery;
          Result:= not (ibs.Bof and ibs.Eof)
                   and (ibs.FieldByName('RDB$PROCEDURE_INPUTS').AsInteger=parIn);
        end;
    end;
  except end;
  prFreeIBSQL(ibs);
  cnts.SetFreeCnt(IBD);
end;
//========================================================== ���������� DataSets
constructor TDataSetsManager.Create;
begin
  inherited Create;
  setLength(Cnts, 0);
  arCntsLocked:= False;
  prMessageLOGS('start '+StringOfChar('*', 34), cPoolLog, false);
end;
//==============================================================================
destructor TDataSetsManager.Destroy;
begin
  setLength(Cnts, 0);
  inherited Destroy;
end;
//=========================================== �������� ������ �������� � �������
function TDataSetsManager.GetCntsItemIndex(p: Pointer): Integer;
var i: integer;
begin
  Result:= -1;
  try
    if not Assigned(p) then Exit;
    for i:= Low(Cnts) to High(Cnts) do
      if Cnts[i]=p then begin
        Result:= i;
        break;
      end;
  except
    on E: Exception do prMessageLOGS('GetCntsItemIndex: '+E.Message, cPoolLog, false);
  end;
end;
//========================================= �������� Pointer �������� �� �������
function TDataSetsManager.GetCntsItemPointer(index: Integer): Pointer;
begin
  Result:= nil;
  try
    if Length(Cnts)>index then Result:= Cnts[index];
  except
    on E: Exception do prMessageLOGS('GetCntsItemPointer: '+E.Message, cPoolLog, false);
  end;
end;
//============================================ ����� ������� � ������� ���������
function TDataSetsManager.AddCntsItem(p: Pointer): Integer;
begin
  Result:= -1;
  while arCntsLocked do sleep(101);
  arCntsLocked:= True;
  try try
    Result:= Length(Cnts);
    setLength(Cnts, Result+1);
    Cnts[Result]:= p;
  except
    on E: Exception do prMessageLOGS('AddCntsItem: '+E.Message, cPoolLog, false);
  end;
  finally
    arCntsLocked:= False;
  end;
end;
//=========================================== �������� ������� ������� ���������
procedure TDataSetsManager.ClearCntsItem(p: Pointer);
var icnt: integer;
begin
  try
    if not Assigned(p) then Exit;
    icnt:= GetCntsItemIndex(p);
    if icnt<0 then Exit;
    Cnts[icnt]:= nil;
  except
    on E: Exception do prMessageLOGS('ClearCntsItem: '+E.Message, cPoolLog, false);
  end;
end;
//============================================== ������ ��������� TIBTransaction
function fnSetTransParams(Transaction: TIBTransaction; RWparam: Integer; flStart: Boolean=False): Boolean;
var i: integer;
begin
  Result:= False;
  try
    if not Assigned(Transaction) then Exit else with Transaction do begin
      if Active then Rollback;
      i:= Params.Count;
      if i<1 then begin          //-------------------------- ��������� ����������
        Params.Add(tpReadWrite[RWparam]);
        Params.Add('nowait');
        Params.Add('read_committed');
        Params.Add('rec_version');
      end else begin // �������� � ������ ��� �������������
        case RWparam of // ������ �������� ��������
          tpRead:  i:= tpWrite;
          tpWrite: i:= tpRead;
        end;
        i:= Params.IndexOf(tpReadWrite[i]);                    // ���� �������� ��������
        if i>-1 then Params.Strings[i]:= tpReadWrite[RWparam]; // ���� ����� - ������ �� ������
        i:= Params.IndexOf(tpReadWrite[RWparam]);     // ��������� ������ ��������
        if i<0 then Params.Add(tpReadWrite[RWparam]); // ���� �� ����� - ���������
      end;
      if Tag<>RWparam then Tag:= RWparam;
      Result:= True;
      if flStart then StartTransaction;
    end;
  except
    on E:Exception do begin
      prMessageLOGS('������ ������� ���������� TIBTransaction: '+E.Message);
      Result:= False;
    end;
  end;
end;
//============================ ������� IBQuery � �������� ���������� Transaction
function fnCreateNewIBQuery(db: TIBDatabase; QueryName: String=''; id: integer=-1; RWparam: Integer=tpRead): TIBQuery;
const nmProc = 'fnCreateNewIBQuery'; // ��� ���������/�������/������
begin
  if not Assigned(db) then raise Exception.Create(MessText(mtkErrConnectToDB));
//  if not Assigned(db) then Exit;
  try
    if not db.Connected then db.Open;
    Result:= TIBQuery.Create(nil);
    Result.UniDirectional:= True;
    Result.Database:= db;
    Result.Transaction:= Result.Database.DefaultTransaction;
    fnSetTransParams(Result.Transaction, RWparam);
  except
    on E:Exception do begin
      prMessageLOGS(nmProc+': error 1: '+E.Message);
      Result:= nil;
    end;
  end;
  if Assigned(Result) then try
//    if QueryName<>'' then Result.Name:= QueryName else Result.Name:= 'ibQuery';
    if QueryName<>'' then Result.Name:= StringReplace(QueryName, '.', '_', [rfReplaceAll]) else Result.Name:= 'ibQuery';
    if id>-1 then Result.Name:= Result.Name+'_'+IntToStr(id);
  except
    on E:Exception do prMessageLOGS(nmProc+': error 2: '+QueryName+': '+E.Message);
  end;
end;
//============================== ������� IBSQL � �������� ���������� Transaction
function fnCreateNewIBSQL(db: TIBDatabase; SQLName: String=''; id: integer=-1;
         RWparam: Integer=tpRead; StartAfterCreate: Boolean=False): TIBSQL;
const nmProc = 'fnCreateNewIBSQL'; // ��� ���������/�������/������
var errmess: String;
begin
  Result:= nil;
  try try
   if not Assigned(db) then Exit;
    errmess:= 'error 1:';
    if not db.Connected then db.Open;
    Result:= TIBSQL.Create(nil);
    Result.Database:= db;
    Result.GoToFirstRecordOnExecute:= True;
    Result.Transaction:= Result.Database.DefaultTransaction;
    fnSetTransParams(Result.Transaction, RWparam);
    errmess:= 'error 2:';
    if (SQLName<>'') then Result.Name:= SQLName else Result.Name:= 'ibSQL';
    if (id>-1) then Result.Name:= Result.Name+'_'+IntToStr(id);
    if StartAfterCreate then Result.Transaction.StartTransaction;
  except
    on E:Exception do begin
      prMessageLOGS(nmProc+': '+errmess+' '+SQLName+': '+E.Message);
      Result:= nil;
    end;
  end;
  finally
    if not Assigned(Result) then raise Exception.Create(MessText(mtkErrConnectToDB));
  end;
end;
//=============================================================== ������� TIBSQL
procedure prFreeIBSQL(var ibs: TIBSQL; CloseTransaction: boolean = true);
const nmProc = 'prFreeIBSQL'; // ��� ���������/�������/������
var nm, ss: string;
begin
  ss:= '';
  if not Assigned(ibs) then Exit;
  if CloseTransaction and Assigned(ibs.Transaction) and ibs.Transaction.InTransaction then
    ibs.Transaction.RollBack;
  nm:= 'TIBSQL';
  try
    If ibs.Name<>'' then nm:= ibs.Name;
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error TIBSQL.Name: '+E.Message;
  end;
  try
    if ibs.Open then ibs.Close;
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error '+nm+'.Close: '+E.Message;
  end;
  try
    prFree(ibs);
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error '+nm+'.Free: '+E.Message;
  end;
  if ss<>'' then try
    prMessageLOGS(ss);
  except end;
end;
//============================================================= ������� TIBQuery
procedure prFreeIBQuery(var Query: TIBQuery; CloseTransaction: boolean = true);
const nmProc = 'prFreeIBQuery'; // ��� ���������/�������/������
var nm, ss: string;
begin
  ss:= '';
  if not Assigned(Query) then Exit;
  if CloseTransaction and Assigned(Query.Transaction) and Query.Transaction.InTransaction then
    Query.Transaction.RollBack;
  nm:= 'TIBQuery';
  try
    If Query.Name<>'' then nm:= Query.Name;
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error TIBQuery.Name: '+E.Message;
  end;
  try
    if Query.Active then Query.Close;
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error '+nm+'.Close: '+E.Message;
  end;
  try
    if Query.Prepared then Query.UnPrepare;
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error '+nm+'.UnPrepare: '+E.Message;
  end;
  try
    prFree(Query);
  except
    on E:Exception do ss:= ss+fnIfStr(ss='', '', #13#10)+'error '+nm+'.Free: '+E.Message;
  end;
  if ss<>'' then try
    prMessageLOGS(ss);
  except end;
end;

//******************************************************************************
//                              ���������� ������
//******************************************************************************
//============================================================== ���������� ����
procedure prSuspendPools;
begin
  cntsSUF.CSSSuspend(RepeatStopInterval);
  cntsTDT.CSSSuspend(RepeatStopInterval);
  cntsORD.CSSSuspend(RepeatStopInterval);
  cntsGRB.CSSSuspend(RepeatStopInterval);
  cntsLOG.CSSSuspend(RepeatStopInterval);
  cntsSUFORD.CSSSuspend(RepeatStopInterval);
  cntsSUFLOG.CSSSuspend(RepeatStopInterval);
end;
//========================================================== �������������� ����
procedure prResumePools;
begin
  prCheckPoolsDatabasePath; // ��������� ���� � ����� �����
  cntsLOG.CSSResume;
  cntsGRB.CSSResume;
  cntsORD.CSSResume;
  cntsTDT.CSSResume;
  cntsSUF.CSSResume;
  cntsSUFORD.CSSResume;
  cntsSUFLOG.CSSResume;
end;
//=============================================================== ��������� ����
procedure prFreePools;
begin
  prFree(cntsLOG);
  prFree(cntsGRB);
  prFree(cntsORD);
  prFree(cntsTDT);
  prFree(cntsSUF);
  prFree(cntsSUFORD);
  prFree(cntsSUFLOG);
end;
//============================================================== ��������� � ���
function GetMessToLogPools(vid: integer=0; flWA: boolean=False): String;
const delta = 19;
var s, sdelim: string;
begin
  Result:= '';
  if vid=0 then sdelim:= StringOfChar(' ', delta) // ��������� � ����� � ��������� ��� ��� ��������
  else sdelim:= '';                               // ��������� � ����� � ���-���� ��� ��������
  Result:= cntsGRB.GetMessToLog+
    #13#10+sdelim+cntsORD.GetMessToLog+
    #13#10+sdelim+cntsLOG.GetMessToLog;
  if flWA then begin
    s:= cntsTDT.GetMessToLog;
    if s<>'' then Result:= Result+#13#10+sdelim+s;
    s:= cntsSUF.GetMessToLog;
    if s<>'' then Result:= Result+#13#10+sdelim+s;
    s:= cntsSUFORD.GetMessToLog;
    if s<>'' then Result:= Result+#13#10+sdelim+s;
    s:= cntsSUFLOG.GetMessToLog;
    if s<>'' then Result:= Result+#13#10+sdelim+s;
  end;
end;
//================================================================= ������� ����
procedure prCreatePools(IniF: TIniFile);
var dbPath, dbUser, dbPass, dbRole: String;
    StartCnt: integer;
    ErrorPos: string;
begin
  try
ErrorPos:='1';
// ������� ��� ��������� � ib_css.gdb
    dbPath:= IniF.ReadString('Logs', 'LogPath', '');
    dbUser:= IniF.ReadString('Logs', 'LogUser', cDefORDLogin);
    dbPass:= IniF.ReadString('Logs', 'LogPass', cDefPassword);
    dbRole:= IniF.ReadString('Logs', 'LogRole', '');
    StartCnt:= IniF.ReadInteger('Logs', 'LogStartCnt', cDefStartCnt);
    cntsLOG:= TIBCntsPool.Create(nil);
    cntsLOG.SetPoolParams('cntsLOG', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� �����');
// ������� ��� ��������� � SufLOG
    dbPath:= IniF.ReadString('Logs', 'SufLogPath', cntsLOG.dbPath); // dbUser, dbPass, dbRole - �� cntsORD
    StartCnt:= IniF.ReadInteger('Logs', 'SufLogStartCnt', cDefStartCnt);
    cntsSUFLOG:= TIBCntsPool.Create(nil);
    cntsSUFLOG.SetPoolParams('cntsSUFLOG', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� SufLOG');
ErrorPos:='2';
// ������� ��� ��������� � Grossbee
    dbPath:= IniF.ReadString('GrossBee', 'GBpath', '');
    dbUser:= IniF.ReadString('GrossBee', 'USERNAME', cDefGBLogin);
    dbPass:= IniF.ReadString('GrossBee', 'GBpass', cDefPassword);
    dbRole:= IniF.ReadString('GrossBee', 'GBrole', cDefGBrole);
    StartCnt:= IniF.ReadInteger('GrossBee', 'GBStartCnt', cDefStartCnt);
    cntsGRB:= TIBCntsPool.Create(nil);
    cntsGRB.SetPoolParams('cntsGRB', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� Grossbee');
ErrorPos:='3';
// ������� ��� ��������� � Suffler - dbUser, dbPass, dbRole - �� cntsGRB
    dbPath:= IniF.ReadString('GrossBee', 'SufPath', '');
    StartCnt:= IniF.ReadInteger('GrossBee', 'SufStartCnt', cDefStartCnt);
    cntsSUF:= TIBCntsPool.Create(nil);
    cntsSUF.SetPoolParams('cntsSUF', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� Suffler');
ErrorPos:='4';
// ������� ��� ��������� � ib_ord.gdb
    dbPath:= IniF.ReadString('DBOrder', 'DBOrderPath', '');
    dbUser:= IniF.ReadString('DBOrder', 'DBOrderUser', cDefORDLogin);
    dbPass:= IniF.ReadString('DBOrder', 'DBOrderPass', cDefPassword);
    dbRole:= IniF.ReadString('DBOrder', 'DBOrderRole', '');
    StartCnt:= IniF.ReadInteger('DBOrder', 'OrdStartCnt', cDefStartCnt);
    cntsORD:= TIBCntsPool.Create(nil);
    cntsORD.SetPoolParams('cntsORD', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� Order');
// ������� ��� ��������� � SufORD - dbUser, dbPass, dbRole - �� cntsORD
    dbPath:= IniF.ReadString('DBOrder', 'SufOrdPath', cntsORD.dbPath);
    StartCnt:= IniF.ReadInteger('DBOrder', 'SufOrdStartCnt', cDefStartCnt);
    cntsSUFORD:= TIBCntsPool.Create(nil);
    cntsSUFORD.SetPoolParams('cntsSUFORD', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� SufORD');
ErrorPos:='5';
// ������� ��� ��������� � fb_tdt.fdb
    dbPath:= IniF.ReadString('TDT', 'TDTPath', '');
    dbUser:= IniF.ReadString('TDT', 'TDTUser', cDefORDLogin);
    dbPass:= IniF.ReadString('TDT', 'TDTPass', cDefPassword);
    dbRole:= IniF.ReadString('TDT', 'TDTRole', '');
    StartCnt:= IniF.ReadInteger('TDT', 'TDTStartCnt', cDefStartCnt);
    cntsTDT:= TIBCntsPool.Create(nil);
    cntsTDT.SetPoolParams('cntsTDT', dbPath, dbUser, dbPass, dbRole, StartCnt, '���� TecDoc');

//    prSetPoolsRunParams(IniF);
  except
    on E: Exception do begin
      prMessageLOGS('prCreatePools: '+E.Message+#10'ErrorPos='+ErrorPos);
      raise;
    end;
  end;
end;
//=============================================== ���������� ��������� ���������
procedure prSetPoolsRunParams(IniF: TIniFile);
var pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout: integer;
begin
  pConTimeout:= 0;
  pIntFreeCnt:= IniF.ReadInteger('intervals', 'GbIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('GrossBee',  'GBLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('GrossBee',  'GBMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('GrossBee',  'GBConnectTimeout', cDefConTimeout);
  cntsGRB.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);

  pIntFreeCnt:= IniF.ReadInteger('intervals', 'SufIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('GrossBee',  'SufLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('GrossBee',  'SufMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('GrossBee',  'SufConnectTimeout', cDefConTimeout);
  cntsSUF.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);

  pIntFreeCnt:= IniF.ReadInteger('intervals', 'OrdIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('DBOrder',   'OrdLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('DBOrder',   'OrdMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('DBOrder',   'OrdConnectTimeout', cDefConTimeout);
  cntsOrd.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);

  pIntFreeCnt:= IniF.ReadInteger('intervals', 'SufOrdIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('DBOrder',   'SufOrdLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('DBOrder',   'SufOrdMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('DBOrder',   'SufOrdConnectTimeout', cDefConTimeout);
  cntsSUFORD.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);

  pIntFreeCnt:= IniF.ReadInteger('intervals', 'LogIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('Logs',      'LogLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('Logs',      'LogMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('Logs',      'LogConnectTimeout', cDefConTimeout);
  cntsLog.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);

  pIntFreeCnt:= IniF.ReadInteger('intervals', 'SufLogIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('Logs',      'SufLogLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('Logs',      'SufLogMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('Logs',      'SufLogConnectTimeout', cDefConTimeout);
  cntsSUFLOG.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);

  pIntFreeCnt:= IniF.ReadInteger('intervals', 'TdTIntFreeCnt', cDefIntFreeCnt);
  pLockLimit := IniF.ReadInteger('TDT',       'TDTLockLimit', cDefLockLimit);
  pMaxOpen   := IniF.ReadInteger('TDT',       'TDTOrdMaxOpenConnects', cDefMaxOpen);
//  pConTimeout:= IniF.ReadInteger('TDT',       'TDTConnectTimeout', cDefConTimeout);
  cntsTDT.SetPoolRunParams(pIntFreeCnt, pLockLimit, pMaxOpen, pConTimeout);
end;

//================================================= ��������� ���� � ����� �����
procedure prCheckPoolsDatabasePath;
var dbPath: String;
    IniF: TINIFile;
begin
  IniF:= TINIFile.Create(nmIniFileBOB);
  try
    dbPath:= IniF.ReadString('Logs', 'LogPath', '');
    if (dbPath<>'') then cntsLOG.CheckDatabasePath(dbPath);

    dbPath:= IniF.ReadString('Logs', 'SufLogPath', cntsLOG.dbPath);
    if (dbPath<>'') then cntsSUFLOG.CheckDatabasePath(dbPath);

    dbPath:= IniF.ReadString('GrossBee', 'GBpath', '');
    if (dbPath<>'') then cntsGRB.CheckDatabasePath(dbPath);

    dbPath:= IniF.ReadString('GrossBee', 'SufPath', '');
    if (dbPath<>'') then cntsSUF.CheckDatabasePath(dbPath);

    dbPath:= IniF.ReadString('DBOrder', 'DBOrderPath', '');
    if (dbPath<>'') then cntsORD.CheckDatabasePath(dbPath);

    dbPath:= IniF.ReadString('DBOrder', 'SufOrdPath', cntsORD.dbPath);
    if (dbPath<>'') then cntsSUFORD.CheckDatabasePath(dbPath);

    dbPath:= IniF.ReadString('TDT', 'TDTPath', '');
    if (dbPath<>'') then cntsTDT.CheckDatabasePath(dbPath);
  finally
    prFree(IniF);
  end;
end;

//******************************************************************************
initialization
begin
  DataSetsManager:= TDataSetsManager.Create;
end;
finalization
begin
  DataSetsManager.Destroy;
end;
//******************************************************************************
end.

