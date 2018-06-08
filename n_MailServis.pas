unit n_MailServis;
//******************************************************************************
//             ����� ������ � ���������� Vlad � ��������� ������
//******************************************************************************
interface

uses Windows, ExtCtrls, Classes, IniFiles, Forms, SysUtils, Math, Controls,
     Variants, DateUtils, IdTCPServer, IdHTTP, DB, IBDatabase, IBSQL, System.IOUtils,
     n_free_functions, v_constants, n_CSSThreads,
     n_server_common, n_Functions, n_constants, n_vlad_mail, n_LogThreads, 
     n_DataSetsManager, n_DataCacheInMemory;

type
  TMailThread = class(TCSSCyclicThread) // ���������� ����� ������ ��� ������ �����
  private { Private declarations }
    TestMailKind: Integer;        // ��� �������� �����
    IntervalTestOldResp: Integer; // �������� �������� ����������� �������
    MessOldResp: Integer;         // ��� ������ � ��� �������� ����������� �������
    PathBox, shablon: string;
    TestMsgTime: TDateTime;
    SearchRec: TSearchRec;
  protected
    procedure WorkProc; override;
    procedure TestOldResponses;
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
    procedure CSSSuspend; override;
    procedure CSSResume; override;
  end;

  TRespThread = class(TCSSCyclicThread) // ���������� ����� ������ ��� ��������� ��������
  private { Private declarations }
    shablon, shablon_ord, dirPutOff: string;
    SearchRec: TSearchRec;
  protected
    procedure WorkProc; override;
    procedure FileProcessing(FileName: string); // ��������� �����
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
    procedure CSSSuspend; override;
    procedure CSSResume; override;
  end;

var
  RespThread: TRespThread;   // ����� ��������� ��������
  MailThread: TMailThread; // ����� ������ �����
  MSParams: record // ������ ��� �������� �������� ��������� �������
    flagTestOldFile: Boolean; // ���� �������� ���� ����� vladdbf.zip
    flagMessOldFile: Boolean; // ���� �������� ��������� � ������ ����� vladdbf.zip
    TimeTestOldFile: TDateTime; // ����� ��������� �������� ���� ����� vladdbf_new.zip
    DirFileRep     : String;  // ����� �/������ �������
    MailWorked     : Boolean; // ���� ������ ������ ������ ����� � ������ ��������� ��������
    TestWorked     : Boolean; // ���� ������ ������ �������� � �������� �/�
    FileDateIni    : Integer; // ���� � ����� ���������� ���������� ini-�����
  end;
  PathRests: String; // ����� �/��������
  LastRestTime     : TDateTime; // ����� ���������� ���������� ������ ��������
  LastRestPriceTime: TDateTime; // ����� ���������� ���������� ��� � ������ ��������
  LastBaseTime     : TDateTime; // ����� ���������� ���������� / ��������� �������� ��������� ������������ ������ baseXX.dbf
  LastBaseRestTime : TDateTime; // ����� ���������� ���������� �������� � ������ baseXX.dbf
  LastBasePriceTime: TDateTime; // ����� ���������� ���������� ��� � ������ baseXX.dbf

procedure StartMailServis(ThreadData: TThreadData; start: boolean=True); // ������ ��������� �������
procedure SuspendMailServis; // ������������ ��������� �������
procedure StopMailServis(finish: boolean=True);                      // ���������� ��������� �������
 function MailServisIsSuspended: boolean;
 function MailServisIsStopped: boolean;
procedure GetMailParams(ThreadData: TThreadData; start: boolean=True); // �������� ���������� ��������� �������

 function NomZakVlad(NomZak: String): String;      // ���������� ����� ������ �������
 function WorkWithData(list: TStringList; ThreadData: TThreadData): TFileProcRes; // ��������� ����� ����� �� ����� �� ��������

 function AutorizeUser(UserLog, UserPW: String; var FirmCode, FirmPrefix, UserCode: String; ThreadData: TThreadData): Boolean; // ��������� ������������
 function ResponseToClient(com: String; response: TStringList; ThreadData: TThreadData; nfzip: string=''): Boolean; // �������� ������

procedure SetAccInvWaresToList(Account, Invoice: array of TDocRec; list: TStringList; ThreadData: TThreadData; exevers: String=''); // ��������� ����� ����� ��� �������� ������ � ������� ����������� ����������
 function TestVladTitles(FirmCode, UserCode, cities: string; ThreadData: TThreadData): Boolean;         // ��������� ��������� ������� �� ����������
procedure TestVladDbf(var nf: String; ThreadData: TThreadData; exevers: String=''); // �������� ���� vladdbf.zip
procedure TestCurrentVersVlad(ThreadData: TThreadData);                             // ��������� ������� ������ ��������� ����
procedure AddInfoNewVersion(FirmCode, UserCode, exevers, exedate: String; list: TStringList; ThreadData: TThreadData); // ��������� � ����� ������
procedure AddBOBMessage(FirmCode, UserCode: String; list: TStringList; ThreadData: TThreadData); // ���������� � ��������� ������� ��������
 function TestSubjComm(Subject: string; vid: integer): Boolean;

 function GetOldDocmType(docType: Integer; dutyType: Integer=0): Integer; // �������� ������ ��� ���� ���-��

implementation
uses n_MailReports, n_vlad_init, n_func_ads_loc, n_vlad_common, n_vlad_files_func;
//==============================================================================
constructor TMailThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'MailThread';
  CommandAndParamsToLog(ccMailThread, ThreadData, ThreadName); // ������ � LOG ������� ������
  if ToLog(0) then prMessageLOGS('***** �������� ������ ������ �����', LogMail, false); // ����� � log
  TestMsgTime:= DateNull;
end;
//==============================================================================
procedure TMailThread.CSSResume;
begin
  inherited;
  if ToLog(0) then prMessageLOGS('***** ������ ������ ������ �����', LogMail, false); // ����� � log
end;
//==============================================================================
procedure TMailThread.CSSSuspend;
begin
  if ToLog(0) then prMessageLOGS('***** ��������� ������ ������ �����', LogMail, false); // ����� � log
  inherited;
end;
//==============================================================================
procedure TMailThread.DoTerminate;
begin
  FindClose(SearchRec);
  if ToLog(0) then prMessageLOGS('***** ���������� ������ ������ �����', LogMail, false); // ����� � log
  inherited;
end;
//==============================================================================
constructor TRespThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'RespThread';
  CommandAndParamsToLog(ccRespThread, ThreadData, ThreadName); // ������ � LOG ������� ������
  if ToLog(0) then prMessageLOGS('***** �������� ������ ��������� ��������', LogMail, false); // ����� � log
  Priority:= tpHighest; //  tpHigher;
end;
//==============================================================================
procedure TRespThread.CSSResume;
begin
  inherited;
  if ToLog(0) then prMessageLOGS('***** ������ ������ ��������� ��������', LogMail, false); // ����� � log
end;
//==============================================================================
procedure TRespThread.CSSSuspend;
begin
  if ToLog(0) then prMessageLOGS('***** ��������� ������ ��������� ��������', LogMail, false); // ����� � log
  inherited;
end;
//==============================================================================
procedure TRespThread.DoTerminate;
begin
  FindClose(SearchRec);
  if ToLog(0) then prMessageLOGS('***** ���������� ������ ��������� ��������', LogMail, false); // ����� � log
  inherited;
end;

//======================================== �������� ���������� ��������� �������
procedure GetMailParams(ThreadData: TThreadData; start: boolean=True); // start=True - ��� ���������
var str, s: String;
    pIniFile: TIniFile;
    ar: Tas;
    FileDateTime: TDateTime;
begin
  setLength(ar, 0);
  if FileAge(nmIniFileBOB, FileDateTime) then // ���������� ���� � ����� ini-�����
    MSParams.FileDateIni:= DateTimeToFileDate(FileDateTime);
//  MSParams.FileDateIni:= FileAge(nmIniFileBOB); // ���������� ���� � ����� ���������� ini-�����
  pIniFile:= TINIFile.Create(nmIniFileBOB);
  try
    if start then begin // ���������, ������� ����� �������� ������ ��� ������������
      MSParams.MailWorked:= (pIniFile.ReadInteger('threads', 'mailget', 0)=1); // ������� ������ ������ ������ ����� � ������ ��������� ��������
      MSParams.TestWorked:= (pIniFile.ReadInteger('threads', 'mailbox', 0)=1); // ������� ������ ������ �������� � �������� �/�
    end;
    GetLogKinds; // ���� ����������� - ���� �������� �������� ������, ����� �������� "�� ����", 
                 // ����� ������ ��� ������� ��� Resume 

    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;

    if start then begin // ���������, ������� ����� �������� ������ ��� �������� ���������
      if ToLog(0) then prMessageLOGS(' ', LogMail, false); // ����� � log �����������
      MSParams.flagTestOldFile:= True; // ������� ���� �������� ���� ����� vladdbf.zip
      MSParams.flagMessOldFile:= False;
      MSParams.TimeTestOldFile:= 0;
      if MSParams.MailWorked then begin // ��������� �������� ������
        MailThread:= TMailThread.Create(True, thtpMail); // ������� ����� ������ �����
        RespThread:= TRespThread.Create(True, thtpMail); // ������� ����� ��������� ��������
      end;
      if MSParams.TestWorked then begin // ��������� ����� �������� �/�
        TestThread:= TTestThread.Create(True, thtpMailBox); // ������� ����� �������� �/�
      end;
    end;

    // ���������, ������� ����� �������� "�� ����", ���� �������� �������� ������
    AttachPath:= pIniFile.ReadString('mail', 'AttachPath', 'mailtmp'); // ����� ��� �������� ������ (vlad_mail)
    str:= GetAppExePath+fnTestDirEnd(AttachPath, false);
    if not DirectoryExists(str) and not CreateDir(str) then begin  // ���� ����� ��� - ���������
      s:= '�� ���� ������� ����� '+str;
      prMessageLOGS('GetMailParams: '+s, LogMail, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'GetMailParams', '������', s);
      str:= GetAppExePath;
    end;
    AttachPath:= str;
    MailParam.PortTo   := pIniFile.ReadString('mail', 'PortTo', '');   // PortTo = 25
    MailParam.PortFrom := pIniFile.ReadString('mail', 'PortFrom', ''); // PortFrom = 110
    MailParam.Host     := pIniFile.ReadString('mail', 'Host', '');     // Host = 'gatenet'
    MailParam.UserID   := pIniFile.ReadString('mail', 'ServerID', ''); // ����� ���-�
    MailParam.Password := pIniFile.ReadString('mail', 'serverPW', ''); // ������ ���-�
//    MailParam.ToAdres  := '';                                       // ����� "����" - ����������� ����������
    MailParam.FromAdres:= pIniFile.ReadString('mail', 'AdresAll', ''); // ����� �/�

    str:= GetAppExePath+pIniFile.ReadString('mail', DirRepFiles, DirRepFilesDef); // ����� �/������ �������
    if not DirectoryExists(str) and not CreateDir(str) then begin // ���� ����� ��� - ���������
      s:= '�� ���� ������� ����� '+str;
      prMessageLOGS('GetMailParams: '+s, LogMail, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'GetMailParams', '������', s);
      str:= GetAppExePath;
    end;
    MSParams.DirFileRep:= fnTestDirEnd(str);

    if MSParams.MailWorked then begin
      MailThread.CycleInterval:= pIniFile.ReadInteger('intervals', 'intervalmail', 10); // �������� �������� ������ ����� � ���.
      MailThread.IntervalTestOldResp:= pIniFile.ReadInteger('intervals', 'IntervalTestOldResp', 10); // �������� �������� ����������� ������� � ���.
      MailThread.MessOldResp:= pIniFile.ReadInteger('Logs', 'MessOldResp', 1); // ��� ������ � ��� ����������� �������
      MailThread.PathBox:= fnTestDirEnd(pIniFile.ReadString('mail', 'MDaemonPathBox', ''))+ // ����� ��� �����
        copy(MailParam.FromAdres, pos('@', MailParam.FromAdres)+1, length(MailParam.FromAdres)); // �����
      MailThread.shablon:= MailThread.PathBox+PathDelim+MailParam.UserID+PathDelim+'*.msg';
      MailThread.TestMailKind:= pIniFile.ReadInteger('mail', 'TestKind', 0); // 0- ��������� �/�, 1- ��������� ����� �����
      RespThread.CycleInterval:= pIniFile.ReadInteger('intervals', 'intervalresp', 5);  // �������� �������� ��������� �������� � ���.
      RespThread.shablon:= fnTestDirEnd(AttachPath)+'*.'+FileInd+'*'; // ������ ������ ������ �������� � �������� ����������� FileInd
      RespThread.shablon_ord:= fnTestDirEnd(AttachPath)+'*AddNewZaks*.'+FileInd+'*'; // ������ ������ ������ �������
      RespThread.dirPutOff:= fnTestDirEnd(AttachPath)+'PutOff'; // ����� ��� ���������� ������
    end;
    if MSParams.TestWorked then begin
      TestThread.CycleInterval:= pIniFile.ReadInteger('intervals', 'MailBoxTestInterval', 30); // ����� ������� ��� ���������
      TestThread.TestCount:= pIniFile.ReadInteger('intervals', 'MailBoxTestCount', 6); // ������� ��� ��������� ��� �������
    end;
  finally
    prFree(pIniFile);
    setLength(ar, 0);
  end;
end;
//========================================== ������/���������� ��������� �������
procedure StartMailServis(ThreadData: TThreadData; start: boolean=True); // start=True - ��������� ��������
var FileDateTime: TDateTime;
begin
  try
    if FileAge(nmIniFileBOB, FileDateTime) and (DateTimeToFileDate(FileDateTime)>MSParams.FileDateIni) then
      GetMailParams(ThreadData, start); // �������� ���������� ��������� �������

    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;
    if start and FileExists(Cache.FormVladBlockFile) then DeleteFile(Cache.FormVladBlockFile);

    if MSParams.MailWorked then begin
      if Assigned(MailThread) and MailThread.Suspended then MailThread.CSSResume;
      if Assigned(RespThread) and RespThread.Suspended then RespThread.CSSResume;
    end;

    if MSParams.TestWorked and Assigned(TestThread) and TestThread.Suspended then TestThread.CSSResume;
  except
    on E: Exception do prMessageLOGS('������ StartMailServis: '+E.Message);
  end;
end;
//=============================================== ������������ ��������� �������
procedure SuspendMailServis;
begin
  try
    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;
    if ToLog(0) then prMessageLOGS('===== ������� ������������ �������� ������� =====', LogMail, false); // ����� � log
//    if Assigned(MailThread) then MailThread.SafeSuspend;
//    if Assigned(RespThread) then RespThread.SafeSuspend;
    if Assigned(TestThread) then TestThread.SafeSuspend;
    if ToLog(0) then prMessageLOGS('===== �������� ������ �������������� =====', LogMail, false);
    Application.ProcessMessages;
  except
    on E: Exception do prMessageLOGS('������ SuspendMailServis: '+E.Message);
  end;
end;
//================================================= ���������� ��������� �������
procedure StopMailServis(finish: boolean=True); // finish=False - ������ ������� �� ���������
const nmProc = 'StopMailServis'; // ��� ���������/�������
var i: Integer;
    LocalStart: TDateTime;
begin
  try
    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;

    LocalStart:= now();
    if not finish then begin
      if ToLog(0) then prMessageLOGS('===== ������� ��������� �������� ������� =====', LogMail, false); // ����� � log
      if Assigned(MailThread) then MailThread.Stop;
      if Assigned(RespThread) then RespThread.Stop;
      if Assigned(TestThread) then TestThread.Stop;
      if ToLog(0) then prMessageLOGS('===== �������� ������ ����������� =====', LogMail, false);
      if flTest then prMessageLOGS(nmProc+'_Stop: - '+
        GetLogTimeStr(LocalStart), fLogDebug, false);

    end else begin
      if ToLog(0) then prMessageLOGS('===== �������� ���������� �������� ������� =====', LogMail, false); // ����� � log
      i:= 0;
      while Assigned(MailThread) and not MailThread.Terminated and (i<100) do begin
        sleep(31); // ���������� ������ ������ �����
        inc(i);
      end;
      i:= 0;
      while Assigned(RespThread) and not RespThread.Terminated and (i<100) do begin
        sleep(31); // ���������� ������ ��������� ��������
        inc(i);
      end;
      i:= 0;
      while Assigned(TestThread) and not TestThread.Terminated and (i<100) do begin
        sleep(31); // ���������� ������ �������� � �������� �/�
        inc(i);
      end;
      if ToLog(0) then prMessageLOGS('===== �������� ������ ��������� =====', LogMail, false);
      if flTest then prMessageLOGS(nmProc+'_Exit: - '+
        GetLogTimeStr(LocalStart), fLogDebug, false);
    end;
    Application.ProcessMessages;
  except
    on E: Exception do prMessageLOGS('������ StopMailServis: '+E.Message);
  end;
end;
//===========================================================
function MailServisIsSuspended: boolean;
begin
  Result:= (not Assigned(TestThread) or TCSSCyclicThread(TestThread).Suspended);
//       and (not Assigned(MailThread) or TCSSCyclicThread(MailThread).Suspended)
//       and (not Assigned(RespThread) or TCSSCyclicThread(RespThread).Suspended);
end;
//===========================================================
function MailServisIsStopped: boolean;
begin
  Result:= (not Assigned(RespThread) or TCSSCyclicThread(RespThread).Terminated)
       and (not Assigned(MailThread) or TCSSCyclicThread(MailThread).Terminated)
       and (not Assigned(TestThread) or TCSSCyclicThread(TestThread).Terminated);
end;
//=========================================================== ����� ������ �����
procedure TMailThread.WorkProc;
var FileDateTime: TDateTime;
//    arNames: Tas;
//    i: integer;
    lst: TStringList;
begin
  lst:= nil;
//  setLength(arNames, 0);
  try try   // ������������ ��������� ���������� ��������� ������� ��� ��������� ini-�����
    if FileAge(nmIniFileBOB, FileDateTime) and (DateTimeToFileDate(FileDateTime)>MSParams.FileDateIni) then
//    if (FileAge(nmIniFileBOB)>MSParams.FileDateIni) then
      GetMailParams(ThreadData, false);
//    if FStopFlag or FSafeSuspendFlag then Exit;
    if FStopFlag then Exit;
{
    arNames:= TDirectory.GetFiles('\\zzz0255\InOut', '*');
    for i:= 0 to High(arNames) do prMessageLOGS('File: '+arNames[i], fLogDebug, False);
    setLength(arNames, 0);
    arNames:= TDirectory.GetDirectories('\\zzz0255\InOut', '*'); // TDirectory.GetCurrentDirectory
    for i:= 0 to High(arNames) do prMessageLOGS('SubDir: '+arNames[i], fLogDebug, False);

    lst:= fnListAllFiles('*.rar', '\\zzz0255\InOut');
    for i:= 0 to lst.Count-1 do prMessageLOGS('2 File: '+lst[i], fLogDebug, False);
}
//    arNames:= TDirectory.GetFiles(MailThread.PathBox+PathDelim+MailParam.UserID, '*.msg');
    lst:= fnListAllFiles('*.msg', MailThread.PathBox+PathDelim+MailParam.UserID);

//    if (TestMailKind<>1) or (FindFirst(shablon, faAnyFile, SearchRec)=0) then begin
//    if (TestMailKind<>1) or (Length(arNames)>0) then begin
    if (TestMailKind<>1) or (lst.Count>0) then begin

      GetMailid; // �������� ������ (�� vlad)
      if (length(MessageTxt)>0) and (MessageTxt<>'��� ���������!') then begin
        if ToLog(6) then prMessageLOGS(' ', LogMail, false); // ����� � log
        if ToLog(6) then prMessageLOGS(MessageTxt, LogMail, false); // ����� � log
        if ToLog(16) then fnWriteToLogPlus(ThreadData, lgmsInfo, ThreadName+'.WorkProc', MessageTxt);
      end;

//      if FStopFlag or FSafeSuspendFlag then Exit;
      if FStopFlag then Exit;

      prDeleteAllFiles('*.mme', AttachPath);  // �������� ������ ������
      prDeleteAllFiles('*.eml', AttachPath);
      prDeleteAllFiles('*.tmp', AttachPath);
      Application.ProcessMessages;
    end;

//    if FStopFlag or FSafeSuspendFlag then Exit;
    if FStopFlag then Exit;
    if (AppStatus=stWork) and (IntervalTestOldResp>0)
      and (Now>IncMinute(TestMsgTime, IntervalTestOldResp)) then begin
      TestOldResponses; // �������� ����������� �������
//      prMessageLOGS(FormatFloat('Memory used: , .# K', fnGetCurrentMemoryUsage/1024), 'MemUsed', false);   // ��� �������
    end;

  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS(ThreadName+'.WorkProc: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, ThreadName+'.WorkProc', '������ ������', E.Message);
    end;
  end;
  finally
  //  FindClose(SearchRec);
//    setLength(arNames, 0);
    prFree(lst);
  end;
end;
//================================================= �������� ����������� �������
procedure TMailThread.TestOldResponses;
var s, nf, path, mess8, sf: string;
    i, vid: integer;
    lst: TStringList;
    ftime, LocalThreadStart: TDateTime;
    oldfile: textfile; // ������������� �����
    fdel: Boolean;
    ThreadData: TThreadData; // ��������� ������ ������ � LOG
begin
  if (FindFirst(PathBox+'\*', faDirectory, SearchRec)<>0) then Exit;
  ThreadData:= fnCreateThread(thtpMail); // ������� LOG-����� ��������
  CommandAndParamsToLog(ccTestOldRes, ThreadData, 'TestOldResponses'); // ������ ���������� LOG-������
  lst:= TStringList.Create; // ������ ���������������� ����� (�������)
  mess8:= '';
  LocalThreadStart:= now();
  try
    repeat                           // ���������� ������ ���������������� �����
      if fnNotLockingLogin(SearchRec.Name) then lst.Add(SearchRec.Name);
    until FindNext(SearchRec)<>0;
{$I-}
    for i:= 0 to lst.Count-1 do begin // ��������� ���������������� �����
      path:= PathBox+PathDelim+lst.Strings[i]+PathDelim;
      if (FindFirst(path+'*.msg', faAnyFile, SearchRec)=0) then // ���� �������� ����� *.msg - ������ �������
        repeat
          ftime:= SearchRec.TimeStamp; // ���� � ����� �����
          if (ftime<IncHour(Now, -2)) then vid:= 2 // ���� ���� �������� 2 ����
          else if (ftime<IncHour(Now, -1)) then vid:= 1 // ���� ���� �������� 1 ���
          else vid:= 0;
//          vid:= 2; // ��� �������
          if vid>0 then begin // ���� ���� ��������� ����
            sf:= lst.Strings[i]+PathDelim+SearchRec.Name+' ('+FormatDateTime(cDateTimeFormatY2S, ftime);
            nf:= path+ChangeFileExt(SearchRec.Name, '.old');
            if FileExists(nf) then DeleteFile(nf);
            Application.ProcessMessages;
            if RenameFile(path+SearchRec.Name, nf) then begin // ��������������� ����
              Application.ProcessMessages;
              AssignFile(oldfile, nf);
              Application.ProcessMessages;
              try
                Reset(oldfile);
                Application.ProcessMessages;
                fdel:= False;
                while not Eof(oldfile) do begin
                  ReadLn(oldfile, s);
                  if (pos('Subject:', s)>0) then begin // ��������� ����
                    fdel:= TestSubjComm(s, 3); // �����������
                    if fdel then break;
                    case vid of
                    1: fdel:= TestSubjComm(s, 1); // ���� �� ������� ����� 1 ���
                    2: fdel:= TestSubjComm(s, 2) or TestSubjComm(s, 1); // ���� �� ������� ����� 2 ����
                    end; // case
                    break;
                  end;
                end;
                Application.ProcessMessages;
              finally
                CloseFile(oldfile);
              end;
              Application.ProcessMessages;
              if fdel then fdel:= DeleteFile(nf); // ������� ����
              Application.ProcessMessages;
              if not fdel then RenameFile(nf, path+SearchRec.Name); // ���� �� ������� - ��������������� �������
              Application.ProcessMessages;
              if fdel then // ���� ������� ����
                mess8:= mess8+fnIfStr(mess8='', '', #10)+sf+', '+ExtractParametr(s, ':')+') ������'
              else if (MessOldResp>0) then // ���� �� ������� ����
                mess8:= mess8+fnIfStr(mess8='', '', #10)+sf+', '+ExtractParametr(s, ':')+') ��������';
            end else  // �� ������ ������������� ����
              mess8:= mess8+fnIfStr(mess8='', '', #10)+sf+') - ������: �� ���� �������������';
          end; // if vid>0
          Application.ProcessMessages;
        until FindNext(SearchRec)<>0;
    end;
{$I+}
    Application.ProcessMessages;
    if mess8<>'' then begin
      mess8:= #10'TestOldResponses: �������� ������ �������'+fnIfStr(mess8='', '', #10)+mess8+#10;
      if (MessOldResp>1) then mess8:= mess8+
        'TestOldResponses: ��������� '+GetLogTimeStr(LocalThreadStart)+#10;
      if ToLog(8) then prMessageLOGS(mess8, LogMail, false);
      if ToLog(18) then fnWriteToLogPlus(ThreadData, lgmsInfo, 'TestOldResponses', '�������� ������ �������', mess8);
    end;
    Application.ProcessMessages;
  except
    on E: Exception do
      if (E.Message<>'') then begin
        prMessageLOGS('TestOldResponses: '+E.Message, LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestOldResponses', '������ �������� ������ �������', E.Message);
      end;
  end;
  prFree(lst);
  TestMsgTime:= Now; // ����� ��������� �������� ����������� �������
  prDestroyThreadData(ThreadData, 'TestOldResponses'); // ������� LOG-�����
end;
//=============================================== �������� ������� � ���� ������
function TestSubjComm(Subject: string; vid: integer): Boolean;
begin
  Result:= False;
  case vid of
  0:  if (pos(cAddNewZaks, Subject)>0) or (pos(cSendMesMan, Subject)>0) // ����� �����, ������ ���������
        or (pos(cBOBMessage, Subject)>0)                               // ��������� ������� ��������
        then Result:= True;  // ������ �� �������
  1:  if (pos(cGetDataAll, Subject)>0) or (pos(cGetReAndPr, Subject)>0)   // ������ ����������, ���������� ��������
        or (pos(cGetRateCur, Subject)>0) or (pos(cGetFirmDis, Subject)>0) // ���� �.�., ������
        or (pos(cLoadLogins, Subject)>0) or (pos('Welcome to the email system', Subject)>0) // ������ �������������, �����������
        or (pos('Welcome to MDaemon', Subject)>0)
        then Result:= True; // ���� �� ������� ����� � ���.1 ��� - �������
  2:  if (pos(cStatusZaks, Subject)>0) or (pos(cLoadingZak, Subject)>0)   // ������� �������, �������� �������
        or (pos(cRepAccList, Subject)>0) or (pos(cUnpayedDoc, Subject)>0) // ���������� �����, ������������ ���-��
        or (pos(cFactSumZak, Subject)>0) or (pos(cLoadDelivr, Subject)>0) // ������ �������, ������� �������� (���� �� ���.)
        or (pos(cReportDebt, Subject)>0) or (pos(cGetCheckDt, Subject)>0) // ��������� �������, ������
        or (pos(cGetDivisib, Subject)>0) or (pos(cGetNewVers, Subject)>0) // ��������� �������, ����� ������
        then Result:= True;  // ���� �� ������� ����� � ���.2 ��� - �������
  end; // case
end;
//===================================================== ����� ��������� ��������
procedure TRespThread.WorkProc;
var flag: Boolean;
begin
  try
    if (AppStatus in [stStarting, stResuming]) then Exit; // ���� ����������� - ���������� ���� ����

    if (AppStatus in [stWork]) and DirectoryExists(dirPutOff) then begin
      flag:= (FindFirst(fnTestDirEnd(dirPutOff)+'*.'+FileInd+'*', faAnyFile, SearchRec)=0); // ���� ���������� �����
      while flag and not (FStopFlag or FSafeSuspendFlag) do begin // ���������� ���������� ����� � ���������
        RenameErrFile(SearchRec.Name, dirPutOff, AttachPath, True);
        flag:= (FindNext(SearchRec)=0); // ���� ���������
      end;
      if not flag then fnDeleteTmpDir(dirPutOff);
    end;

    if (FindFirst(shablon, faAnyFile, SearchRec)<>0) or FStopFlag then Exit; // ���� ��� ������ ��� ���������
    repeat
      flag:= (FindFirst(shablon_ord, faAnyFile, SearchRec)=0); // ���� ����� �������
      while flag and not FStopFlag do begin // ������������ ����� �������
        FileProcessing(SearchRec.Name);
        flag:= (FindNext(SearchRec)=0); // ���� ���������
      end; // while flag...
      flag:= (FindFirst(shablon, faAnyFile, SearchRec)=0) and not FStopFlag;
      if flag then FileProcessing(SearchRec.Name); // ������������ 1 ������ ������
    until not flag or FStopFlag;

  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS('TRespThread.WorkProc: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'TRespThread.WorkProc', '������ ������', E.Message);
    end;
  end;
  FindClose(SearchRec);
end;
//============================================================== ��������� �����
procedure TRespThread.FileProcessing(FileName: string);
const nmProc = 'FileProcessing'; // ��� ���������/�������
var list: TStringList;
    i: integer;
    res: TFileProcRes;
    ThreadData: TThreadData; // ��������� ������ ������ � LOG ��������� �������
    s: string;
begin
  ThreadData:= nil;
  list:= nil;
  try
    ThreadData:= fnCreateThread(thtpMail); // ������� LOG-����� ��������� �������
    CommandAndParamsToLog(0, ThreadData, copy(FileName, 1, pos('.', FileName)-1)); // ������ ���������� LOG-������ ��������� �������
    if ToLog(2) then prMessageLOGS('FileProcessing: ��������� ����� '+FileName, LogMail, false);

    list:= ExtractDataFromFile(fnTestDirEnd(AttachPath)+FileName); // ��������� ����� ����� �� ����� (vlad_mail)

    if not Assigned(list) or (list.Count<1) then begin
      res:= fprEmpty;
      s:= '������ ���� '+FileName;
      prMessageLOGS(nmProc+': '+s, LogMail, false); // ����� � log
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s);

    end else if (length(list.Strings[0])<7) or (copy(list.Strings[0], 1, 7)<>pUSERID) then begin
      res:= fprError;
      s:= '������������ ���� '+FileName;
      prMessageLOGS(nmProc+': '+s, LogMail, false); // ����� � log
      for i:= 0 to list.Count-1 do prMessageLOGS(': '+list[i], LogMail, false); // ����� � log
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s);
//      raise Exception.Create('Empty file');

    end else for i:= 1 to RepeatCount do begin // RepeatCount ���
      res:= WorkWithData(list, ThreadData);
      if res in [fprSuccess, fprPutOff] then break; // ���� ���� ��������� ��� ����� �������� - �������

      if res in [fprEmptLog] then s:= '' else s:= IntToStr(i)+'-� ������� ';
      s:= '������ '+s+'��������� ����� '+FileName;
      prMessageLOGS(nmProc+': '+s, LogMail, false); // ����� � log
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s);
      if res in [fprEmptLog] then break; // ���� ������ �����

      if FStopFlag or (i=RepeatCount) then break else sleep(RepeatSaveInterval);
    end; // for

    s:= '';
    case res of
      fprSuccess, fprEmpty, fprEmptLog: // ������� ������������ ��� ������ ����
        DeleteFile(fnTestDirEnd(AttachPath)+FileName);
      fprError:  // ���� ��� ���� - ���������� ���� � ����� �/������� ������
        s:= RenameErrFile(FileName, AttachPath, DirFileErr);
      fprPutOff:           // �������� ��������� ����� (�� Resume)
        s:= RenameErrFile(FileName, AttachPath, dirPutOff, True);
    end; // case
    if (s<>'') then raise Exception.Create(s);

    Application.ProcessMessages;
  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message);
    end;
  end;
  prFree(list);
  prDestroyThreadData(ThreadData, nmProc); // ������� LOG-����� ��������� �������
end;

//******************************************************************************
//                    ��������� ����� ����� �� ����� �� ��������
//******************************************************************************
function WorkWithData(list: TStringList; ThreadData: TThreadData): TFileProcRes;
const nmProc = 'WorkWithData'; // ��� ���������/�������
// ���������� True, ���� ��� ���������� ��������� - ������, ����� ������� ����
var i, j, j1, j2, onzipSize: Integer;
    str, FirmCode, FirmPrefix, UserCode, UserLog, UserPW, BegDat, 
      exevers, exedate, exeinf, mess1, dataDate, baseDate: String;
    response, wlst: TStringList; // ����� ������� �� ������, ������� ������
    Wlines: array of TWareLine;
    arZaks: array of TZakazLine; // �/����.���������� ��������
    ar: Tas;
    flResult: boolean;
//----------------------------------------------
procedure AddOtherResp(res: TStringList);
var lst: TStringList;
    j: integer;
begin
  lst:= nil;
  try
    lst:= ReportFirmDiscounts(FirmCode, UserCode, ThreadData); // ��������� ������ ������ �����
    if Lst.Count>0 then for j:= 0 to Lst.Count-1 do res.Add(lst.Strings[j]);
  finally prFree(lst); end;
  try
    lst:= ReportRateCur(FirmCode, UserCode, ThreadData); // ��������� ���� �.�.
    if Lst.Count>0 then for j:= 0 to Lst.Count-1 do res.Add(lst.Strings[j]);
  finally prFree(lst); end;
  try
    lst:= GetDivisible(FirmCode, UserCode, ThreadData); // ��������� ��������� �������
    if Lst.Count>0 then for j:= 0 to Lst.Count-1 do res.Add(lst.Strings[j]);
  finally prFree(lst); end;
end;
//----------------------------------------------
begin
  Result:= fprSuccess;
  flResult:= True;
  response:= TStringList.Create;
  wlst:= TStringList.Create;
  mess1:= '';
  FirmCode:= '';
  UserCode:= '';
  FirmPrefix:= '';
  exeinf:= '';
  setLength(ar, 0);
  try
    if (copy(list.Strings[0], 1, 7)<>pUSERID) then raise Exception.Create('Empty file');
    j1:= 0;
    if ToLog(7) or ToLog(17) then
      for j:= 0 to list.Count-1 do begin
        mess1:= mess1+fnIfStr(mess1='', '', #13#10)+list.Strings[j]; // ��� �������
        if list.Strings[j]=cLoadingZak then j1:= j+5;
        if (j1>0) and (j>j1) then break;
      end;
    if ToLog(7) then prMessageLOGS(nmProc+': ������'#13#10+mess1, LogMail, false);
    if ToLog(17) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '������', mess1);

    ar:= fnSplitString(ExtractParametr(list.Strings[0])); // UserLog;UserPW;exevers;exedate;...UserParams
    UserLog:= ar[0];
    if trim(UserLog)='' then begin
      Result:= fprEmptLog;
      raise Exception.Create('Empty UserLog');
    end;

    UserPW:= ar[1];
    if (length(ar)>2) then exevers:= ar[2] else exevers:= ''; // ������ ��������� �������
    if (length(ar)>3) then exedate:= ar[3] else exedate:= ''; // ���� ��������� �������
                          // ��������� ����� "����" �� ������ ��� �������� ������
    MailParam.ToAdres:= UserLog+copy(MailParam.FromAdres, pos('@', MailParam.FromAdres), length(MailParam.FromAdres));

    str:= GetMessageNotCanWorks;
    if str<>'' then begin //------------------ ���� �� ����� �������� �� ������
      UserCode:= list.Strings[1];
      response.Add('response:'+cBOBMessage); // ��������� �������
      response.Add(pINFORM+str); // ���������� � ����� ���������
      if (UserCode=cAddNewZaks) then begin // �����
        response.Add(pINFORM+'��� ����� ��������� � ������� �� ���������.');
        Result:= fprPutOff;
      end else if (UserCode=cSendMesMan) then begin // ������ ���������
        response.Add(pINFORM+'���� ��������� ��������� ���������� � ������� �� ��������.');
        Result:= fprPutOff;
      end; // else response.Add(pINFORM+'��������� ��� ������ �����.');
      ResponseToClient(cBOBMessage, response, ThreadData); // ���������� ����� - response
      UserCode:= '';
      raise Exception.Create('');

    end else if AutorizeUser(UserLog, UserPW, FirmCode, FirmPrefix, UserCode, ThreadData) then // ��������� ������������
      prSetThLogParams(ThreadData, 0, StrToIntDef(UserCode, 0), StrToIntDef(FirmCode, 0), '') // ����������� � ib_css

    else begin
      response.Add('response:'+cLoadLogins); // ������ �����������
      if UserCode='' then UserCode:= '������ �����������';
      wlst.Text:= UserCode;
      for j:= 0 to wLst.Count-1 do response.Add(pINFORM+wlst.Strings[j]); // ���������� � ����� ���������
//      response.Add(pINFORM+UserCode);
      case StrToIntDef(FirmPrefix, 0) of
        -1: begin
              prFillRegistrationInfo(); // ��������� �������� ����� ��� �����������
              FirmUsersLoginAndPasswords(FirmCode, response, ThreadData); // �������� ������� ������ - �������� ������ ������� � �������
              prClearRegistrationInfo(); // ������� �������� ����� ��� �����������
            end;
        -2: begin
              str:= GetIniParam(nmIniFileBOB, 'mail', 'UrlChangePW'); // ������ ��� ����� ���������� ������
              if str<>'' then response.Add(pCOMMNT+str); // ��������� ������ - �������� ������ ��� ����� ������
            end;
      end;
      flResult:= ResponseToClient(cLoadLogins, response, ThreadData); // ���������� ����� - response
      if ToLog(1) or ToLog(11) then begin
        mess1:= '';
        for j:= 0 to response.Count-1 do mess1:= mess1+fnIfStr(mess1='', '', #13#10)+response.Strings[j]; // ��� �������
//        if ToLog(1) then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '������', mess1);
      end;
      UserCode:= '';
      FirmCode:= '';
      raise Exception.Create('');
    end;
//-------------------------------------------------- ���.������ �������
    if (length(ar)>4) then NetConnectionType:= StrToIntDef(ar[4], 0) else NetConnectionType:= -1; // ��� ���������� � ����������
    if (length(ar)>5) then MailParam.SocketHost:= ar[5] else MailParam.SocketHost:= '';                      // �������.Host
    if (length(ar)>6) then MailParam.SocketPortTo:= StrToIntDef(ar[6], 0) else MailParam.SocketPortTo:= 0;    // �������.PortTo
    if (length(ar)>7) then MailParam.SocketPortFrom:= StrToIntDef(ar[7], 0) else MailParam.SocketPortFrom:= 0;// �������.PortFrom

    if (length(ar)>8) then onzipSize:= StrToIntDef(ar[8], 0) else onzipSize:= 0; // ������ zip ��.�. �������
    if (length(ar)>9) then dataDate:= ar[9] else dataDate:= '';   // ���� ������ �������
    if (length(ar)>10) then baseDate:= ar[10] else baseDate:= ''; // ���� base.dbf �������

    str:= SetUserParams(UserCode, UserLog, UserPW, exevers, exedate); // ������ ���������� ������� ����
    if str<>'' then begin
      prMessageLOGS(nmProc+': '+str, LogMail, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', str);
    end;
//--------------------------------------------------
    if not ((exevers<>'') and VersFirstMoreSecond(exevers, '', VladVersion509, ''))
      and (list.Strings[1]<>cGetNewVers) then begin // ��������� ������ ������ �� 5.1.0 (����� ������� ����� ������)
      str:= '';
      response:= ReportBlockOldVers(list.Strings[1], exevers, exedate, str, ThreadData);
      flResult:= ResponseToClient(list.Strings[1], response, ThreadData, str); // ���������� ����� - response
      if ToLog(1) or ToLog(11) then begin
        mess1:= '';
        for j:= 0 to response.Count-1 do mess1:= mess1+fnIfStr(mess1='', '', #13#10)+response.Strings[j]; // ��� �������
//        if ToLog(1) then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '������', mess1);
      end;
      UserCode:= '';
      FirmCode:= '';
      raise Exception.Create('');
    end;

    i:= 1;
    while i<list.Count do begin
      response.Clear;  // ������� "�����" ������ ��� ��������� �������
      Application.ProcessMessages;
      if list.Strings[i]=cAddNewZaks then begin //==================== ����� �����
        Inc(i);
        setLength(arZaks, 1);
        setLength(Wlines, 0); // ������������ ������ ��� ������� ������
        while i<list.Count do begin //
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then begin
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // ��������� ������ - � ������
            arZaks[0].NomZak:= ar[0]; // � ������
//            arZaks[0].DatZak:= fnTestDateYear4(ar[1]);
            arZaks[0].DatZak:= ar[1];
            arZaks[0].OplZak:= ar[2];
            arZaks[0].ValZak:= ar[3];
            arZaks[0].DeliTp:= ar[4]; // ��� ��������
            if arZaks[0].DeliTp='1' then arZaks[0].DeliTp:= '0' else arZaks[0].DeliTp:= '1'; // �������� � ������������ �� �������
            arZaks[0].SumZak:= fnTestDecSep(ar[5]); // SUMZAK
            if (length(ar)>6) then arZaks[0].storage:= ar[6];
          end else if copy(list.Strings[i], 1, 7)=pWARRNT then begin  // ��������� ������������
            arZaks[0].Warrnt:= ExtractParametr(list.Strings[i]);
          end else if copy(list.Strings[i], 1, 7)=pCOMMNT then begin  // ����������
            arZaks[0].Commnt:= ExtractParametr(list.Strings[i]);
          end else if copy(list.Strings[i], 1, 7)=pKTOVAR then begin // KTOVAR= ������ �������
            j2:= Length(Wlines);
            setLength(Wlines, j2+1);
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // ��������� ������ - � ������
            Wlines[j2].WCode:= ar[0];                             // ��� ������
            Wlines[j2].WKolv:= ar[1];                             // ����������
            Wlines[j2].WCena:= fnTestDecSep(ar[2]);               // ����
          end else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        response:= AddNewZaksOrd(FirmCode, FirmPrefix, UserCode, arZaks[0], Wlines, ThreadData, exevers); // ���������� � �� ����� �����
        flResult:= ResponseToClient(cAddNewZaks, response, ThreadData); // ���������� ����� - response

      end else if list.Strings[i]=cStatusZaks then begin //======= ������� �������
        Inc(i);
        setLength(arZaks, 0);
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then begin // � ������
            j1:= Length(arZaks);
            setLength(arZaks, j1+1);
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // ��������� ������ - � ������
            arZaks[j1].nomstr:= ar[0]; // � ������ ����������
            arZaks[j1].NomZak:= ar[1]; // � ������
  //          arZaks[j1].Status:= ar[2]; // ���� �� ������������
  //          arZaks[j1].DatZak:= fnTestDateYear4(ar[3]); // ���� �� ������������
          end else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        response:= GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode, arZaks, ThreadData, exevers); // �������� ������� �������
        flResult:= ResponseToClient(cStatusZaks, response, ThreadData); // ���������� ����� - response

      end else if list.Strings[i]=cLoadingZak then begin //====== �������� �������
        Inc(i);
        setLength(arZaks, 0);
        BegDat:= '';
        while i<list.Count do begin //
          str:= list.Strings[i];
          if copy(str, 1, 7)=pBEGDAT then begin
            BegDat:= ExtractParametr(list.Strings[i]); // BegDat:= fnTestDateYear4(ExtractParametr(list.Strings[i]));
          end else if copy(str, 1, 7)=pNOMSTR then begin // � ������ ������� (��� ������ � �������: � ������ �� �������)
            j1:= Length(arZaks);
            setLength(arZaks, j1+1);
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // ��������� ������ - � ������
            arZaks[j1].nomstr:= ar[0]; // � ������ ����������
            arZaks[j1].NomZak:= ar[1]; // � ������
            if Length(ar)>2 then arZaks[j1].DatZak:= ar[2]; // ���� �� ������������
          end else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        response:= LoadingZaksOrd(FirmCode, FirmPrefix, UserCode, BegDat, arZaks, ThreadData, exevers); // ��������� ������
        flResult:= ResponseToClient(cLoadingZak, response, ThreadData); // ���������� �����

{      end else if list.Strings[i]=cLoadDelivr then begin //===== �������� ��������
        Inc(i);
        response:= LoadDeliver(FirmCode, UserCode);
        flResult:= ResponseToClient(cLoadDelivr, response, '', ThrID); // ���������� �����}

      end else if list.Strings[i]=cGetDivisib then begin //===== �������� ��������� �������
        Inc(i);
        response:= GetDivisible(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cGetDivisib, response, ThreadData); // ���������� �����

      end else if list.Strings[i]=cUnpayedDoc then begin //===== ������ ������������ ����������
        Inc(i);                               // + ������ ���������� ������ + ��������� �������
        response:= ReportUnpayedDocOrd(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cUnpayedDoc, response, ThreadData); // ���������� �����

      end else if list.Strings[i]=cGetFirmDis then begin // ������ ������ �����
        Inc(i);
        response:= ReportFirmDiscounts(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cGetFirmDis, response, ThreadData); // ���������� �����

      end else if list.Strings[i]=cGetRateCur then begin //============= ���� �.�.
        Inc(i);
        response:= ReportRateCur(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cGetRateCur, response, ThreadData); // ���������� �����

      end else if list.Strings[i]=cLoadLogins then begin //== ������ �������������
        Inc(i);
        response.Add('response:'+cLoadLogins);
        prFillRegistrationInfo(); // ��������� �������� ����� ��� �����������
        FirmUsersLoginAndPasswords(FirmCode, response, ThreadData);
        prClearRegistrationInfo(); // ������� �������� ����� ��� �����������
        flResult:= ResponseToClient(cLoadLogins, response, ThreadData); // ���������� ����� - response

      end else if list.Strings[i]=cGetDataAll then begin // ������ ���������� �������
        Inc(i);
        str:= nfzipvlad; // ��� ������ ����������
        response:= ReportDataAll(FirmCode, UserCode, str, ThreadData, exevers);
        AddInfoNewVersion(FirmCode, UserCode, exevers, exedate, response, ThreadData); // ��������� � ����� ������
        AddOtherResp(response); // ���������� �������������� ������
        flResult:= ResponseToClient(cGetDataAll, response, ThreadData, str); // ���������� �����

      end else if list.Strings[i]=cGetReAndPr then begin // ���������� �������� � ���
        Inc(i);
        BegDat:= '';
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then // ������ ������� �� �����
            BegDat:= ExtractParametr(list.Strings[i])
          else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        if //VersFirstMoreSecond(exevers, '', VladVersion513, '') and // �� 5.2.0 �� ��������
          TestVladTitles(FirmCode, UserCode, BegDat, ThreadData) then begin // ��������� ��������� �������
          str:= 're'+fnGenRandString(4); // ��� ����� � ��������� ��� ����������
          response:= ReportRestAndPrice(FirmCode, UserCode, str, ThreadData, exevers);
          flResult:= ResponseToClient(cGetReAndPr, response, ThreadData, str); // ���������� �����
        end else begin
          str:= nfzipvlad; // ��� ������ ������� ����������
          response:= ReportDataAll(FirmCode, UserCode, str, ThreadData, exevers);
          AddInfoNewVersion(FirmCode, UserCode, exevers, exedate, response, ThreadData); // ��������� � ����� ������
          AddOtherResp(response); // ���������� �������������� ������
          flResult:= ResponseToClient(cGetDataAll, response, ThreadData, str); // ���������� ������ ����������
        end;

      end else if list.Strings[i]=cLoadOrgNum then begin // ��������� ������������ ������
        Inc(i);
        str:= 'on'+fnGenRandString(4); // ��� ����� ������ ������������ ������� ��� ����������
        response:= ReportLoadOrgNum(FirmCode, UserCode, str, ThreadData, onzipSize);
        flResult:= ResponseToClient(cLoadOrgNum, response, ThreadData, str); // ���������� �����

      end else if list.Strings[i]=cGetCheckDt then begin //===== ������ �� �����
        Inc(i);
        BegDat:= '';
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pBEGDAT then // �������� ���
            BegDat:= ExtractParametr(list.Strings[i])
          else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        if (BegDat<>'') then begin
          str:= ''; // ��� ������
          response:= ReportCheck(FirmCode, UserCode, BegDat, str, ThreadData);
          flResult:= ResponseToClient(cGetCheckDt, response, ThreadData, str); // ���������� ����� - response
        end;

      end else if list.Strings[i]=cSendMesMan then begin // ��������� ��������� ������
        Inc(i);
        response.Clear;
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pINFORM then // ������ ������
            response.Add(ExtractParametr(list.Strings[i]))
          else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        response:= ReportMesMan(FirmCode, UserCode, response, ThreadData);
        flResult:= ResponseToClient(cSendMesMan, response, ThreadData); // ���������� ����� - response

      end else if list.Strings[i]=cGetNewVers then begin //===== ��������� ����� ������
        Inc(i);
        str:= '';
        response:= ReportGetNewVers(FirmCode, UserCode, exevers, exedate, str, ThreadData);
        flResult:= ResponseToClient(cGetNewVers, response, ThreadData, str); // ���������� ����� - response

      end else if list.Strings[i]=cReLoadVers then begin // ����� � �������� ����� ������
        Inc(i);
        response.Clear;
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pINFORM then // ������ ������
            response.Add(ExtractParametr(list.Strings[i]))
          else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        flResult:= ReportReLoadVers(FirmCode, UserCode, response, ThreadData);

      end else if list.Strings[i]=cSendWrongM then begin // ����� � ������ �� ������
        Inc(i);
        response.Clear;
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then begin // ���
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // ��������� ������ - � ������
          end else if copy(str, 1, 7)=pINFORM then // ������ ������
            response.Add(ExtractParametr(list.Strings[i]))
          else Break;
          Inc(i); // ��������� �� ����.("�����")������
        end; // while...
        response:= ReportWrongMes(FirmCode, UserCode, ar, response, ThreadData);
        flResult:= ResponseToClient(cSendWrongM, response, ThreadData); // ���������� ����� - response

      end else begin // ������ �������
        flResult:= False;
        Inc(i);
        prMessageLOGS(nmProc+': ����������� �������: '+list.Strings[i], LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '����������� �������', list.Strings[i]);
      end; // ������ �������

      if ToLog(1) or ToLog(11) and Assigned(response) and (response.Count>0) then begin
        mess1:= '';
        for j:= 0 to response.Count-1 do mess1:= mess1+fnIfStr(mess1='', '', #13#10)+response.Strings[j]; // ��� �������
//        if ToLog(1) then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '������', mess1);
      end;
    end; // while

  except
    on E: Exception do if (E.Message<>'') then begin
      flResult:= False;
      prMessageLOGS(nmProc+': ������ ��������� �������: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ ��������� �������', E.Message);
    end;
  end;
  if (Result=fprSuccess) and not flResult then Result:= fprError;
  if (exevers<>'') then
    prSetThLogParams(ThreadData, 0, 0, 0, '������ �������: '+exevers+' '+exedate); // ��������� � LOG ������ �������
  setLength(ar, 0);
  setLength(arZaks, 0);
  setLength(Wlines, 0);
  prFree(response);
  prFree(wlst);
end;
//============================================================== �������� ������
function ResponseToClient(com: String; response: TStringList; ThreadData: TThreadData; nfzip: string=''): Boolean;
var file_name, s, mess: String;
    i: Integer;
    Body: TStringList;
begin
  Result:= (MailParam.ToAdres<>'');
  Body:= nil;
  try
    if not Result then raise Exception.Create(MessText(mtkNotValidParam)+' ��� ��������');
    file_name:= DirFileErr+'re'+IntToStr(DateTimeToFileDate(Now))+com+'.'+FileInd; // ��������� ��� ����� ��� �������� ������
    Result:= fnSaveEncoded(file_name, response); // �������� ����� � ����
    if not Result then raise Exception.Create('����� �� ������� �������� � ���� ��� ��������');
    if nfzip='' then s:= file_name else s:= file_name+';'+nfzip; // ���� ���� ���.���� (zip)
    for i:= 1 to RepeatCount do begin // RepeatCount �������
      try
        Result:= MailSendid(s, com);  // �������� ������ �� ��/�����
        if not Result then begin
          mess:= '������ MailSendid: '+MessageTxt;
          prMessageLOGS('ResponseToClient: '+mess, LogMail, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', '', mess);
        end;
      except
        on E: Exception do begin
          Result:= False;
          prMessageLOGS('ResponseToClient: ������ '+IntToStr(i)+'-� ������� �������� ������: '+E.Message, LogMail, False);
          fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', '������ '+IntToStr(i)+'-� ������� �������� ������', E.Message);
        end;
      end;
      Application.ProcessMessages;
      if (length(MessageTxt)>0) and (MessageTxt<>'��������� ����������!') then begin
        if ToLog(6) then prMessageLOGS('ResponseToClient: '+MessageTxt, LogMail, false);
        if ToLog(16) then fnWriteToLogPlus(ThreadData, lgmsInfo, 'ResponseToClient', '���������� �����', MessageTxt);
      end;
      if Result then Break else if (i<RepeatCount) then sleep(RepeatSaveInterval); // ���� ��������� - �������, ���� ���� - ������� ���������
    end; // for
    if Result then begin
      if ToLog(2) then prMessageLOGS('ResponseToClient: ��������� ����� �� ������: '+com, LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, '��������� �����'); // ��������� � LOG ���������
    end else begin
      Body:= TStringList.Create;
      Body.Add(GetMessageFromSelf);
      Body.Add('Error send response '+com+' file '+file_name); // ��������� ��������� ������ ��-�� Vlad
      s:= fnGetSysAdresVlad(caeOnlyDayLess);
      s:= n_SysMailSend(s, 'Error send response', Body, nil, '', '', true);
      if (s<>'') then begin
        prMessageLOGS('ResponseToClient: ������ �������� ������ �� ������ �������� ������: '+s, LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', '������ �������� ������ �� ������ �������� ������', s);
      end;
    end;
  except
    on E: Exception do begin
      prMessageLOGS('ResponseToClient: ������ �������� ������: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', '������ �������� ������', E.Message);
    end;
  end;
  prFree(Body);
  if FileExists(file_name) then DeleteFile(file_name);
  if FileExists(nfzip) then DeleteFile(nfzip);
  Application.ProcessMessages;
  sleep(RepeatSaveInterval); // ���� �������, ����� ������ ����� ��� ����������� ��������
end;
//======================================================= ��������� ������������
function AutorizeUser(UserLog, UserPW: String; var FirmCode, FirmPrefix, UserCode: String; ThreadData: TThreadData): Boolean;
// ���������� True, ���� ����� ������������, ���� ��� - � UserCode ���������, 
// FirmPrefix='-1' - �������� ������  users, '-2' - �������� ������ ��� ����� ������
const nmProc = 'AutorizeUser'; // ��� ���������/�������
var err, Password: string;
    UserID, FirmID{, iBlock}: integer;
    RESETPASWORD: Boolean;
//    LastAct: TDateTime;
    ibs: TIBSQL;
    ibd: TIBDatabase;
begin
  Result:= False;
  FirmCode:= '';
  FirmPrefix:= '';
  UserID:= 0;
  UserCode:= '';
  RESETPASWORD:= false;
  err:= '������ SQL';
  ibs:= nil;
//  ibd:= nil;
//  iBlock:= 0;
//  LastAct:= Now;
  with Cache do try
    ibd:= cntsORD.GetFreeCnt;              // ���� ������������
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
      ibS.SQL.Text:= 'Select * from AutenticateUserCSS(:LOGIN, :PASSW, :Ses, 0, '+IntToStr(cosByVlad)+')';
      ibS.ParamByName('LOGIN').AsString:= UserLog;
      ibS.ParamByName('PASSW').AsString:= UserPW;
      ibS.ParamByName('Ses').AsString:= '';
      ibS.ExecQuery;
      if (ibs.Bof and ibs.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      if ibS.FieldByName('rErrText').AsString<>'' then begin
        err:= ibS.FieldByName('rErrText').AsString; // ��������� ��� �������
        raise Exception.Create(err+' �  WEBORDERCLIENTS'); // ��������� � ���
      end;
      UserID      := ibS.FieldByName('rWOCLCODE').AsInteger;
      UserCode    := ibs.fieldByName('rWOCLCODE').AsString; // ���������: ��� ������������
      Password    := ibs.fieldByName('rWOCLPASSWORD').AsString;
      RESETPASWORD:= GetBoolGB(ibs, 'rWOCLRESETPASWORD');
//      iBlock      := ibS.FieldByName('rBlock').AsInteger;
//      LastAct     := ibS.FieldByName('rLastAct').AsDateTime;
    finally
      ibs.Transaction.Rollback;
      ibs.Close;
      prFreeIBSQL(ibs);
      cntsORD.SetFreeCnt(ibd);
    end;

    TestClients(UserID, True);
    if not ClientExist(UserID) then begin
      err:= MessText(mtkNotClientExist)+' '+UserLog;
      raise Exception.Create(err+' � ���� WOCLCODE='+UserCode);

    end else with arClientInfo[UserID] do begin
      if Arhived then begin // ������ ������������ � Grossbee
        err:= MessText(mtkNotLoginProcess, UserLog);
        FirmPrefix:= '-10'; //
        raise Exception.Create(err);
      end;
      LastAct:= Now;
      err:= CheckBlocked(True, True, cosByVlad); // �������� ����������
      if Blocked then begin
        FirmPrefix:= '-10'; //
        raise Exception.Create(err);
      end;
    end;

    FirmID:= arClientInfo[UserID].FirmID;      // ��� �����
    FirmCode:= IntToStr(FirmID);
    if not FirmExist(FirmID) then begin
      err:= '�� ������� ����� ������������ '+UserLog;
      raise Exception.Create(err+' � ���� WOFRCODE='+FirmCode);
    end else with arFirmInfo[FirmID] do if Arhived or Blocked then begin // ����� �������������
      err:= MessText(mtkNotFirmProcess, Name);
      FirmPrefix:= '-10'; //
      raise Exception.Create(err);
    end else if UserPW<>Password then begin // �������� ������
      err:= '�������� ������ ������������ '+UserLog;
      FirmPrefix:= '-1'; // �������� ������  users
      raise Exception.Create(err+' UserPW='+UserPW);
    end else if RESETPASWORD then begin // ��������� ������
      err:= '��������� ������ ������������ '+UserLog;
      FirmPrefix:= '-2'; // �������� ������ ��� ����� ������
      raise Exception.Create(err);
    end else FirmPrefix:= arFirmInfo[FirmID].NUMPREFIX; // ������� ����� �������
    Result:= True;
  except
    on E: Exception do begin
      UserCode:= err;
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ �����������', E.Message);
    end;
  end;
end;
//========================================= ���������� ����� ������ ������� Vlad
function NomZakVlad(NomZak: String): String;
var i: Integer;
begin
  Result:= NomZak;
  i:= pos('V', NomZak);
  if i>0 then Result:= copy(NomZak, i+2, length(NomZak)); // ����� ������ ������� Vlad
end;
//==================================================== �������� ���� vladdbf.zip
procedure TestVladDbf(var nf: String; ThreadData: TThreadData; exevers: String='');
const nmProc = 'TestVladDbf'; // ��� ���������/�������
var str, ss: string;
    Body: TStringList;
    FileDateTime: TDateTime;
begin
  if not fnGetActionTimeEnable(caeOnlyDay) or (IncHour(MSParams.TimeTestOldFile, 3)>Now) then Exit; // ��������� ����� 3 ���� ����
  Body:= nil;
  MSParams.TimeTestOldFile:= Now;
  try
    str:= '';
    if not FileExists(nf) then begin
      str:= 'file '+nf+' not exist'; // ���� ����� ���
      ss:= '���� �� ������: '+nf;
    end else if not TestFileActual(nf, -10800, False) // ���� ���� "������" 3 ���.
      and FileAge(nf, FileDateTime) then begin
      str:= 'file '+nf+' - '+FormatDateTime(cDateTimeFormatY4S, FileDateTime);
//      str:= 'file '+nf+' - '+FormatDateTime(cDateTimeFormatY4S, FileDateToDateTime(FileAge(nf)));
      ss:= '���� �������: '+nf;
    end;
    if str<>'' then begin
      if ToLog(2) then begin
        prMessageLOGS(strDelim2_45, LogMail, false);
        prMessageLOGS(nmProc+': '+str, LogMail, false);
        prMessageLOGS(strDelim2_45, LogMail, false);
      end;
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, ss); // ��������� � LOG ���������
      Body:= TStringList.Create; // ��������� ��������� ������ ��-�� Vlad
      Body.Add(GetMessageFromSelf);
      Body.Add(str);
      str:= fnGetSysAdresVlad(caeOnlyDayLess);
      str:= n_SysMailSend(str, 'old '+ExtractFileName(nf), Body, nil, '', '', true);
      if (str<>'') then begin
        prMessageLOGS(nmProc+': ������ �������� ������: '+ss+#13#10+str, LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ �������� ������', str);
      end;
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message);
    end;
  end;
  prFree(Body);
end;
//====================================== ��������� ������� ������ ��������� ����
procedure TestCurrentVersVlad(ThreadData: TThreadData);
var s, path, lastvers, lastdate, v, d, tmp, nfzip: String;
    sr: TSearchRec;
    ar: Tas;
    Body: TStringList;
    pIniFile: TIniFile;
begin
  Body:= TStringList.Create;
  setLength(ar, 0);
  pIniFile:= TINIFile.Create(nmIniFileBOB);
  lastvers:= ''; // ��������� ����� ����� ������
  lastdate:= '';
  nfzip:= '';
  try
    path:= Cache.VladZipPath; // ���� � ������ ���������� ������
    if FindFirst(fnTestDirEnd(path)+vlexezipshablon, faAnyFile, sr)=0 then try
      repeat                                      // ���� ����� ������� ������
        v:= '';
        d:= '';
        tmp:= '';
        if TestVladVersFromZip(path, fnTestDirEnd(path)+sr.Name, 'vlad.exe', tmp, v, d, true) and
          VersFirstMoreSecond(v, d, lastvers, lastdate) then begin
          lastvers:= v;               // ���� ����� ����� ������
          lastdate:= d;
          nfzip:= sr.Name;
        end;
      until SysUtils.FindNext(sr)<>0;
    finally
      SysUtils.FindClose(sr);
    end;
    if (lastvers<>'') then begin // ���� ����� ���� ���������� - ������� � ������� �������
      s:= pIniFile.ReadString('mail', 'vladversion', ''); // ��������� ������� ������ ��������� ����
      if s<>'' then ar:= fnSplitString(s); // ��������� ������� ������ - � ������
      if length(ar)<3 then setLength(ar, 3);
      if VersFirstMoreSecond(lastvers, lastdate, ar[0], ar[1]) then begin // ���� ��������� ������ ������ �������
        s:= lastvers+fnIfStr(lastdate<>'', ';'+lastdate, '')+fnIfStr(nfzip<>'', ';'+nfzip, '');
        pIniFile.WriteString('mail', 'vladversion', s);
        if ToLog(2) then prMessageLOGS('TestCurrentVersVlad: ���������� ������� ������ ����: '+s, LogMail, false);
        if ToLog(12) then fnWriteToLogPlus(ThreadData, lgmsInfo, 'TestCurrentVersVlad', '���������� ������� ������ ����', s);
        Body.Add('Change Current VersVlad: '+s);
        s:= fnGetSysAdresVlad(caeOnlyWorkDay);
        Body.Insert(0, GetMessageFromSelf);
        s:= n_SysMailSend(s, 'Change VersVlad', Body, nil, '', '', true);
        if s<>'' then begin
          prMessageLOGS('TestCurrentVersVlad: ������ �������� ������ �� ��������� ������� ������ ����: '#13#10+s, LogMail, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestCurrentVersVlad', '������ �������� ������ �� ��������� ������� ������ ����', s);
        end;
      end;
    end;
  except
    on E: Exception do begin
      prMessageLOGS('TestCurrentVersVlad: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestCurrentVersVlad', '������', E.Message);
    end;
  end;
  prFree(Body);
  prFree(pIniFile);
  setLength(ar, 0);
end;
//===================================================== ��������� � ����� ������
procedure AddInfoNewVersion(FirmCode, UserCode, exevers, exedate: String; list: TStringList; ThreadData: TThreadData);
// exevers - ������ ��������� �������, exedate - ���� ��������� �������
var s, str: string;
    ar: Tas;
begin
  setLength(ar, 0);
  try
    TestCurrentVersVlad(ThreadData);                         // ��������� ������� ������ ��������� ����
    str:= GetIniParam(nmIniFileBOB, 'mail', 'vladversion'); // ��������� ������� ������ ��������� ����
    if str=''       then Exit else ar:= fnSplitString(str); // ��������� ������� ������ - � ������
    if length(ar)<1 then Exit else list.Add(pCOMMNT+str); // � ������ 5.0.9 ���������� � ����� ��������� ������� ������ ����
    If length(ar)>1 then s:= ar[1] else s:= '';

    if not VersFirstMoreSecond(ar[0], s, exevers, exedate) then Exit; // ������ ������� ���������

    list.Add(pINFORM+strDelim2_45);
    list.Add(pINFORM+' �� ����� ������ ���������  '+ar[0]+' �� '+s);
//      list.Add(pINFORM+' ����� ������� - ������ "��� ������?"');
    if not ((exevers<>'') and VersFirstMoreSecond(exevers, '', VladVersion513, ''))
      and VersFirstMoreSecond(ar[0], '', VladVersion513, '') then begin // ����� �������� 5.2.0
      list.Add(pINFORM+strDelim1_45);
      list.Add(pINFORM+'   ����� �������: ����� ������� � �����');
      list.Add(pINFORM+'     �������� �� ������������ �������');
      list.Add(pINFORM+'   (����� ���������� ��� �� ����� ������)');
    end;
    list.Add(pINFORM+strDelim1_45);

    If(length(ar)>2) then str:= ar[2] else str:= 'vl'+fnDelSpcAndSumb(ar[0])+'exe.zip';
    list.Add(pINFORM+'    ���� ������ �� ���������� �� �������:'); // � ������ 5.0.9 ��������
    list.Add(pINFORM+' � ����� Vlad\IN ������ ���� ����� '+str);   // ���������� ��������� �� �������
    list.Add(pINFORM+'           (���� ��� - �������� � �����)');
    list.Add(pINFORM+'         ���������� ����� '+str);
    list.Add(pINFORM+'     � �������� ����� � ����� Vlad\EXE');
    list.Add(pINFORM+strDelim2_45);

    if ToLog(2) then prMessageLOGS('AddInfoNewVersion: ���������� ��������� � ������ '+ar[0], LogMail, false);
    if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, '���������� ��������� � ������ '+ar[0]); // ��������� � LOG ���������
  finally
    setLength(ar, 0);
  end;
end;
//==================================== ��������� ��������� ������� �� ����������
function TestVladTitles(FirmCode, UserCode, cities: string; ThreadData: TThreadData): Boolean; // True - ���������� ���������
const nmProc = 'TestVladTitles'; // ��� ���������/�������
var s: string;
    FirmID, i, j, contID: Integer;
    ColNames: TStringList;
begin
  Result:= False;
  FirmID:= StrToIntDef(FirmCode, 0);
  if (cities='') or (FirmID<1) then Exit;
  ColNames:= nil;
  contID:= 0;
  with Cache do try
    ColNames:= fnSplit(',', cities); // ������ ���������� ������� �� �������
    with arFirmInfo[FirmID].GetContract(contID) do for i:= Low(ContStorages) to High(ContStorages) do begin
      if ColNames.Count<1 then Exit; // ���� ��������� ������� �����
      j:= ContStorages[i].DprtID;
      s:= GetDprtColName(j);
      j:= ColNames.IndexOf(s);
      if j<0 then Exit; // ���� ��������� ������� �����
      ColNames.Delete(j); // ����������� ��������� �������
    end;
    Result:= ColNames.Count<1; // False, ���� ������ ������� �����
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message);
    end;
  end;
  prFree(ColNames);
end;

//====== ��������� ����� ����� ��� �������� ������ � ������� ����������� ���-���
procedure SetAccInvWaresToList(Account, Invoice: array of TDocRec; list: TStringList;
          ThreadData: TThreadData; exevers: String='');
const nmProc = 'SetAccInvWaresToList'; // ��� ���������/�������
var ibsWa, ibsWi: TIBSQL;
    ibd: TIBDatabase;
    ii: Integer;
    str, err, s: String;
begin
  err:= '';
//  ibd:= nil;
  ibsWa:= nil;
  ibsWi:= nil;
  try
    ibd:= cntsGRB.GetFreeCnt;
  except
    Exit;
  end;
  try
    ibsWa:= fnCreateNewIBSQL(ibd, 'ibsWa_'+nmProc, ThreadData.ID);
    ibsWi:= fnCreateNewIBSQL(ibd, 'ibsWi_'+nmProc, ThreadData.ID);
    ibd.DefaultTransaction.StartTransaction;
    ibsWa.SQL.Text:= 'select PINVLNWARECODE, PINVLNPRICE, PINVLNCOUNT, PINVLNORDER '+
                     'from PAYINVOICELINES where PINVLNDOCMCODE=:id';
    ibsWa.Prepare;
    ibsWi.SQL.Text:= 'select INVCLNWARECODE, INVCLNPRICE, INVCLNCOUNT '+
                     'from INVOICELINES where INVCLNDOCMCODE=:id';
    ibsWi.Prepare;
    for ii:= Low(Account) to High(Account) do begin
      str:= ''; // ������ ������ ����������� ����������
      if Account[ii].Number<>'' then
        try
          str:= Account[ii].Number+';'+                  // � ����� � Grossbee
            IntToStr(Account[ii].ID)+';'+                // ��� �����
            fnDateGetText(Account[ii].Data)+';'+         // ���� �����
            fnSetDecSep(FormatFloat('# ##0.00', Account[ii].Summa))+';'+ // ����� �����
            Account[ii].CurrencyName+';'+                // ������ �����
            fnIfStr(Account[ii].Processed, '1', '0')+';';  // ������� ��������� �����
          if Invoice[ii].Number<>'' then begin
            str:= str+Invoice[ii].Number+';'+            // � ��������� � Grossbee
              IntToStr(Invoice[ii].ID)+';'+              // ��� ���������
              fnDateGetText(Invoice[ii].Data)+';'+       // ���� ���������
              fnSetDecSep(FormatFloat('# ##0.00', Invoice[ii].Summa))+';'+ // ����� ���������
              Invoice[ii].CurrencyName+';';              // ������ ���������
          end;
          if Account[ii].Commentary<>'' then begin            // ����������� ��� �������
            s:= StringReplace(Account[ii].Commentary, #13, ' ', [rfReplaceAll]);
            s:= StringReplace(s, #10, ' ', [rfReplaceAll]);
            s:= StringReplace(s, ';', ',', [rfReplaceAll]);
            str:= str+copy(s, 1, cCommentLength)+';';
          end else str:= str+';';
          str:= str+IntToStr(Account[ii].DprtID)+';'+     // ������
                fnIfStr(Invoice[ii].Number<>'', IntToStr(Invoice[ii].DprtID), '0')+';';
        except
          on E: Exception do begin
            err:= err+fnIfStr(err='', '', #13#10)+E.Message;
            str:='';
          end;
        end;
      if str='' then Continue else list.Add(pGBACCN+str);

      if Account[ii].ID>0 then begin
        ibsWa.ParamByName('id').AsInteger:= Account[ii].ID;   // ���������� ���-���
        ibsWa.ExecQuery;
        if (ibsWa.Bof and ibsWa.Eof) then list.Add(pINFORM+'������ �� ����� N '+Account[ii].Number+' �� �������')
        else
          while not ibsWa.EOF do begin
            list.Add(pACCWAR+IntToStr(Account[ii].ID)+';'+    // ��� �����
              ibsWa.fieldByName('PINVLNWARECODE').AsString+';'+ // ��� ������
                 ibsWa.fieldByName('PINVLNORDER').AsString+';'+ // ���-�� � ������
                 ibsWa.fieldByName('PINVLNCOUNT').AsString+';'+ // ���-�� ����.
              fnSetDecSep(FormatFloat('# ##0.00', ibsWa.fieldByName('PINVLNPRICE').AsFloat))); // ����
            ibsWa.Next;
          end;
        ibsWa.Close;
      end; // if Account.ID>0
      if Invoice[ii].ID>0 then begin
        ibsWi.ParamByName('id').AsInteger:= Invoice[ii].ID;
        ibsWi.ExecQuery;
        if (ibsWi.Bof and ibsWi.Eof) then list.Add(pINFORM+'������ �� ����.N '+Invoice[ii].Number+' �� �������')
        else
          while not ibsWi.EOF do begin
            list.Add(pINVWAR+IntToStr(Invoice[ii].ID)+';'+    // ��� ���������
              ibsWi.fieldByName('INVCLNWARECODE').AsString+';'+   // ��� ������
                 ibsWi.fieldByName('INVCLNCOUNT').AsString+';'+   // ����.���-��
             fnSetDecSep(FormatFloat('# ##0.00', ibsWi.fieldByName('INVCLNPRICE').AsFloat))); // ����
            ibsWi.Next;
          end;
        ibsWi.Close;
      end; // if Invoice.ID>0
    end;
  except
    on E: Exception do err:= err+fnIfStr(err='', '', #13#10)+E.Message;
  end;
  if (err<>'') then prMessageLOGS(nmProc+': '+err, LogMail, False);
  if (err<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', err);
  prFreeIBSQL(ibsWi);
  prFreeIBSQL(ibsWa);
  cntsGRB.SetFreeCnt(ibd);
end;
//====================================== ���������� � ��������� ������� ��������
procedure AddBOBMessage(FirmCode, UserCode: String; list: TStringList; ThreadData: TThreadData);
begin                                                    ////// ���������
  list.Add(pINFORM+''); // ���������
  list.Add(pKTOVAR+''); // ��� ����� (vlupdzipshablon) ������ ���������� ������� ��� ��������� ����
  // ���� � ������ ���� ���� ���������� (vlupdexeshablon) - ���� ��� ����� �������� � ����� vlad\in
  if ToLog(2) then prMessageLOGS('AddBOBMessage: ���������� ���������� � ���������', LogMail, false);
  if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, '���������� ���������� � ���������'); // ��������� � LOG ���������
end;
//============================================== �������� ������ ��� ���� ���-��
function GetOldDocmType(docType: Integer; dutyType: Integer=0): Integer;
begin
  case docType of
     89: if dutyType= 0 then Result:= 50 else Result:= 51;
     99: Result:= 55;
    101: if dutyType= 0 then Result:= 56 else Result:= 57;
    102: if dutyType= 0 then Result:= 52 else Result:= 53;
    103: Result:= 64;
    107: Result:= 73;
    112: Result:= 72;
    else Result:= docType;
  end;
end;


//******************************************************************************
initialization
begin
  MSParams.FileDateIni:= 0;
end;
//******************************************************************************
//finalization
//begin
//
//end;
//******************************************************************************

//function fnGetDeliverType(FirmCode, DprtCode, DatabaseName: string): Integer; // �������� - ����� ��� ���/�����
//=============================================== �������� - ����� ��� ���/����� ???
{function fnGetDeliverType(FirmCode, DprtCode, DatabaseName: string): Integer;
// ���������� 1, ���� ����� ����� ��������� � ������� �������, 2- �� ���������, 0 - �� �����
var
  qrGB1: TQuery;
  cFirm, cDprt: Integer;
begin
  Result:= -1;
  cFirm:= 0;
  cDprt:= 0;
  qrGB1:= QueryGrossBeeCreate;
  qrGB1.SQL.Text:='Select firmcitycode from firms where firmcode='+FirmCode;
  qrGB1.Open;
  if not qrGB1.IsEmpty and not qrGB1.Fields[0].IsNull then cFirm:= qrGB1.Fields[0].AsInteger;
  qrGB1.Close;
  qrGB1.SQL.Text:='Select firmcitycode from firms where firmcode='+DprtCode;
  qrGB1.Open;
  if not qrGB1.IsEmpty and not qrGB1.Fields[0].IsNull then cDprt:= qrGB1.Fields[0].AsInteger;
  qrGB1.Close;
  prFree(qrGB1);
  if (cFirm>0) and (cDprt>0) then
    if cFirm=cDprt then Result:= 0 else Result:= 1;
end;
//======================================= ���������� FIRMSHORTNAME �� ���� �����
function fnGetFIRMSHORTNAME(Code, DatabaseName: string): string;
var qrGB1: TQuery;
begin
  Result:= '';
  qrGB1:= fnNewQueryGrossBee(DatabaseName);
  qrGB1.SQL.Text:='Select FIRMSHORTNAME from firms where firmcode='+Code;
  qrGB1.Open;
  if not qrGB1.IsEmpty and not qrGB1.fieldByName('FIRMSHORTNAME').IsNull then
    Result:= trim(qrGB1.fieldByName('FIRMSHORTNAME').AsString);
  qrGB1.Close;
  prFree(qrGB1);
end;
//========================= ��������� ������������ FIRMSHORTNAME ������� 99-9999
function fnTestFIRMSHORTNAME(ShortName: string): Boolean;
var i: Integer;
begin
  Result:= False;
  if length(ShortName)>7 then Exit;
  for i:= 0 to length(ShortName)-1 do
    if not (ShortName[i] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '_']) then Exit;
  Result:= True;
end;
//=================================================}

end.

