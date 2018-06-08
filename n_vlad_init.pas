unit n_vlad_init;

interface
uses Windows, Classes, SysUtils, DateUtils, IniFiles, IdSMTP, IdMessage, DB, IBDatabase, IBSQL,
     n_free_functions, v_constants, v_DataTrans, n_CSSThreads,
     n_Functions, n_constants, n_vlad_mail, n_MailServis, n_DataCacheInMemory,
     n_LogThreads, n_DataSetsManager, n_server_common, n_vlad_common ;

type
  TLoginInfo = record // ������ ��� �������� ������ � ������
    code: Integer;    // ��� ������������
    err : Integer;    // ������� ��������� �������� �/�
    MAILPASS: string;
    BOXCREATETIME: TDateTime;
  end;

  TTestThread = class(TCSSCyclicThread) // ���������� ����� ����� ������
  private { Private declarations }
  protected
    procedure WorkProc; override; // �������� �/� � ��������� ������
  public
    CycleInterval, TestCount: integer; // �������� ������������� � ��������, ���-�� ������� �������� �/�
    TestBody: TStringList;
    mailLogins: array of TLoginInfo; // ������ ������� ��� �/�
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
    procedure CSSSuspend; override;
    procedure CSSResume; override;
  end;

const DOMAIN_LEN   = 45;
      MAILBOX_LEN  = 30;
      FULLNAME_LEN = 30;
      MAILDIR_LEN  = 90;
      PASSWORD_LEN = 20;

var TestThread: TTestThread; // ��������� ����� ��� �������� �/�

procedure prGetVladInitFile(Stream: TBoBMemoryStream; ThreadData: TThreadData);                  // ������� ���� ����������� �������
 function WriteVladInitFile(FirmCode: String; var nf: String; ThreadData: TThreadData): Boolean; // ���������� ������ � ���� ����������� �������
 function FirmUsersLoginAndPasswords(FirmCode: String;
          var FirmUsers: TStringList; ThreadData: TThreadData): Boolean;     // ������ ������� � ������� ������������������ ����������� �����
 function TestUser(login,mailpsw: String; ThreadData: TThreadData): Boolean; // �������� ������� �/� ������ - - ��������� Connect

implementation
//******************************************************************************
//                 ��������� ����� �������� � �������� �/�
//******************************************************************************
//================================================================ ������ ������
constructor TTestThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'TestThread';
  CommandAndParamsToLog(ccTestThread, ThreadData, ThreadName); // ������ � LOG ������� ������
  if ToLog(0) then prMessageLOGS('***** �������� ������ �������� �/�', LogMail, false); // ����� � log
  setLength(mailLogins, 0); // ������ ������� ��� �/�
  TestBody:= TStringList.Create;
end;
//==============================================================================
procedure TTestThread.CSSResume;
begin
  inherited;
  if ToLog(0) then prMessageLOGS('***** ������ ������ �������� �/�', LogMail, false); // ����� � log
end;
//==============================================================================
procedure TTestThread.CSSSuspend;
begin
  if ToLog(0) then prMessageLOGS('***** ��������� ������ �������� �/�', LogMail, false); // ����� � log
  inherited;
end;
//============================================================= ��������� ������
procedure TTestThread.DoTerminate;
begin
  prFree(TestBody);
  setLength(mailLogins, 0);
  if ToLog(0) then prMessageLOGS('***** ���������� ������ �������� �/�', LogMail, false); // ����� � log
  inherited;
end;
//==============================================================================
//                           �������� �/�
//==============================================================================
procedure TTestThread.WorkProc;
var i, j: Integer;
    strlog, S: String;
    ThrData: TThreadData;
    ibsOrd: TIBSQL;
    ibdOrd: TIBDatabase;
    newTime, FileDateTime: TDateTime;
  //--------------------------- ������� ��������� ������� ������ � �������
  function fnFindInMassLog(Code: integer): integer;
  var i: integer;  // ���������� ������, ���� �����, ��� -1
  begin
    Result:= -1;
    if length(mailLogins)<1 then Exit;
    for i:= Low(mailLogins) to High(mailLogins) do
      if (mailLogins[i].code=Code) then begin
        Result:= i;
        Exit;
      end;
  end;
  //----------------------- ������� i-� ������� �� ������� �������
  procedure fnDeleteFromMassLog(i: integer);
  var ii: integer;
  begin
    if i<High(mailLogins) then
      for ii:= i to High(mailLogins)-1 do begin
        mailLogins[i].code:= mailLogins[i+1].code;
        mailLogins[i].err:= mailLogins[i+1].err;
        mailLogins[i].MAILPASS:= mailLogins[i+1].MAILPASS;
        mailLogins[i].BOXCREATETIME:= mailLogins[i+1].BOXCREATETIME;
      end;
    setLength(mailLogins, High(mailLogins));
  end;
  //---------------------- ������������ ����� SEM ��� �������� �/�
  procedure SemCreateUserMailBox(list: TStringList; ThreadData: TThreadData);
  const nmProc = 'SemCreateUserMailBox'; // ��� ���������/�������
  var md, file_name, file_block: String;
      file_out: textfile;
      FileHandle, i: Integer;
  begin
    md:= fnTestDirEnd(GetIniParam(nmIniFileBOB, 'mail', 'MDaemonPathAPP')); // ���� � MDaemon APP
    if md='' then begin
      prMessageLOGS(nmProc+': ��� ��������� MDaemonPathAPP', LogReg, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '��� ��������� MDaemonPathAPP', '', '', false);
      Exit;
    end;
    file_name:= md+'ADDUSER.SEM';  // ���� �������� �������� �/�
    file_block:= md+'ADDUSER.LCK'; // ���� ���������� ��������� ��������
    try
      FileHandle:= fnTestFileCreate(file_block); // ������� ���� ����������
      if (FileHandle<0) then begin
        prMessageLOGS(nmProc+': ������ �������� ����� '+file_block, LogReg, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ �������� ����� '+file_block, '', '', false);
      end;
      AssignFile(file_out, file_name); // ��������� ���� ��������
      try
        if FileExists(file_name) then Append(file_out) else Rewrite(file_out);
        for i:= 0 to list.Count-1 do begin
          Writeln(file_out, AnsiString(list.Strings[i])); // ���������� ������
          if ToLog(1) then prMessageLOGS(nmProc+': � ���� '+file_name+' ������ '+IntToStr(i+1), LogReg, false);
        end;
        Flush(file_out);
      finally
        closefile(file_out);            // ��������� ���� ��������
      end;
      if FileExists(file_name) then begin
        if ToLog(1) then prMessageLOGS(nmProc+': ����������� ���� '+file_name, LogReg, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '����������� ���� '+file_name, '', '');
      end;  
      if (FileHandle>-1) and not DeleteFile(file_block) then begin // ������� ���� ����������
        prMessageLOGS(nmProc+': ������ �������� ����� '+file_block, LogReg, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ �������� ����� '+file_block, '', '', false);
      end;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': ������ ��� ������ � ���� '+file_name, LogReg, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc,'������ ��� ������ � ���� '+file_name, '', '', false);
      end;
    end;
  end;
  //-------------------------- ��������� ������� ������
  function TestUserMailBox(login: String; ThreadData: TThreadData): Boolean;
  // login - ����� ������������
  const nmProc = 'TestUserMailBox'; // ��� ���������/�������
  var md, user, dom, str, file_name, file_tmp: String;
      file_out: textfile;
  begin
    Result:= False;
    md:= fnTestDirEnd(GetIniParam(nmIniFileBOB, 'mail', 'MDaemonPathAPP')); // ���� � MDaemon/APP
    dom:= copy(MailParam.FromAdres, pos('@', MailParam.FromAdres)+1, length(MailParam.FromAdres)); // �����
    user:= fnTestDirEnd(GetIniParam(nmIniFileBOB, 'mail', 'MDaemonPathBox'))+dom+PathDelim+login; // ����� ��� �����
    file_name:= md+'USERLIST.DAT';
    file_tmp:= md+'USERLIST.TMP';
    str:= '';
    if FileExists(file_name) then try
      DeleteFile(file_tmp);
      CopyFile(PChar(file_name), PChar(file_tmp), false);
      AssignFile(file_out, file_tmp); // ��������� ����
      try
        Reset(file_out);
        While not Eof(file_out) do begin
          ReadLn(file_out, str);
          if pos(login,str)>0 then begin
            if ToLog(1) then prMessageLOGS(nmProc+': ������� ������� ������ ������������ '+login, LogReg, false);
            if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '������� ������� ������ ������������ '+login, '', '');
            Result:= True;
            Break;
          end;
        end;
      finally
        closefile(file_out);            // ��������� ����
      end;
    finally
      DeleteFile(file_tmp);
    end;
    if Result then Result:= Result and DirectoryExists(user);
    if Result then begin
      if ToLog(1) then prMessageLOGS(nmProc+': ������� ����� ������������ '+login, LogReg, false);
      if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, '������� ����� ������������ '+login, '', '');
    end;
  end;
  //------------------------------- ������������ �/�
  procedure FormUserMailBoxList(ThreadData: TThreadData);
  const nmProc = 'FormUserMailBoxList'; // ��� ���������/�������
  var str, login, pasw, userdir, dom: String;
      list: TStringList;
      i, j, UserID: Integer;
      codes: Tai;
      Client: TClientInfo;
  begin
    setLength(codes, 0);
    list:= nil;
    try
      for i:= Low(mailLogins) to High(mailLogins) do begin
        str:= Cache.arClientInfo[mailLogins[i].code].Login;
        if ToLog(1) then prMessageLOGS('FormUserMailBoxList: ��������� ����� '+str, LogReg, false);
        if not TestUserMailBox(str, ThreadData) then begin // ��������� ������� ������
          j:= Length(codes);
          setLength(codes, j+1); // ���������� ���� ���, ���� ���� �������� � ���� SEM
          codes[j]:= mailLogins[i].code;
        end;
      end;
      if Length(codes)<1 then Exit;
      list:= TStringList.Create;
      for j:= Low(codes) to High(codes) do begin
        i:= fnFindInMassLog(codes[j]);
        if (i>-1) then try
          UserID:= codes[j];
          Client:= Cache.arClientInfo[UserID];
          str:= copy(IntToStr(Client.FirmID)+' '+ // ��������� ������ ��� ����� SEM
            fnIfStr(Client.Name='', '?', Client.Name), 1, FULLNAME_LEN); // ���
          str:= StringReplace(str, '@', '-', [rfReplaceAll]);
          login:= Client.Login;
          pasw:= mailLogins[i].MAILPASS;
          dom:= copy(MailParam.FromAdres, pos('@',MailParam.FromAdres)+1, length(MailParam.FromAdres)); // �����
//          userdir:= fnTestDirEnd(GetIniParam(nmIniFileBOB, 'mail', 'MDaemonPathBox'))+dom+PathDelim+login+PathDelim; // ����� ��� �����
          userdir:= fnTestDirEnd(GetIniParam(nmIniFileBOB, 'mail', 'MDaemonUsers'))+dom+PathDelim+login+PathDelim; // ����� ��� �����
          str:= fnMakeAddCharStr(dom,     DOMAIN_LEN,     True)+
                fnMakeAddCharStr(login,   MAILBOX_LEN,    True)+
                fnMakeAddCharStr(str,     FULLNAME_LEN,   True)+
                fnMakeAddCharStr(userdir, MAILDIR_LEN,    True)+
                fnMakeAddCharStr(pasw,    PASSWORD_LEN-2, True)+' YNYYYYNNNNN0000000000';
          list.Add(str);
          if ToLog(1) then prMessageLOGS('FormUserMailBoxList: str= '+str, LogReg, false);
        except
          on E: Exception do if (E.Message<>'') then begin
            prMessageLOGS(nmProc+': '+E.Message, LogReg, false);
            fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message, '', false);
          end;
        end;
      end;
      if list.Count>0 then SemCreateUserMailBox(list, ThreadData); // ��������� ���� SEM ��� �������� �/�
    except
      on E: Exception do if (E.Message<>'') then begin
        prMessageLOGS(nmProc+': '+E.Message, LogReg, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message, '', false);
      end;
    end;
    setLength(codes, 0);
    prFree(list);
  end;
//======================================= begin TTestThread.WorkProc ===========
begin
//  ibdOrd:= nil;
  ibsOrd:= nil;
  ThrData:= nil;
  // ������������ ��������� ���������� ��������� ������� ��� ��������� ini-����� (�� ������, ���� �� ������� �������� �����)
  if not MSParams.MailWorked and
    FileAge(nmIniFileBOB, FileDateTime) and (DateTimeToFileDate(FileDateTime)>MSParams.FileDateIni) then
//   (FileAge(nmIniFileBOB)>MSParams.FileDateIni) then
    GetMailParams(ThreadData, false);
 
  if FStopFlag or FSafeSuspendFlag then Exit;
  try
    try
      ibdOrd:= cntsORD.GetFreeCnt;
    except
      Exit;
    end;
    try
      ibsOrd:= fnCreateNewIBSQL(ibdOrd,'ibsOrd_'+ThreadName, ThreadData.ID);
      if not Assigned(ibsOrd) then Exit;
      ibsOrd.Transaction.StartTransaction;
      ibsOrd.SQL.Text:= 'select WOCLCODE, WOCLLOGIN, WOCLMAILPASS, WOCLEBOXCREATETIME'+
        ' from WEBORDERCLIENTS where not WOCLLOGIN is null and not WOCLMAILPASS is null'+
        ' and not WOCLEBOXCREATETIME is null and WOCLEBOXCREATETIME<:dat';
      ibsOrd.ParamByName('dat').AsDateTime:= Now;
      ibsOrd.ExecQuery;
      while not ibsOrd.Eof do begin // ���� ����� ������ � �������� ������� � �������� ����� ������
        j:= ibsOrd.fieldByName('WOCLCODE').AsInteger;
        i:= fnFindInMassLog(j);
        if i<0 then begin
          Cache.TestClients(j, True, False, True); // ��������� ��������
          if Cache.ClientExist(j) then begin
            i:= Length(mailLogins);    // ���������� ����� ��� ��������
            setLength(mailLogins, i+1);
            with mailLogins[i] do begin
              code:= j;
              MAILPASS:= ibsOrd.fieldByName('WOCLMAILPASS').AsString;
              BOXCREATETIME:= ibsOrd.fieldByName('WOCLEBOXCREATETIME').AsDateTime;
            end;
            if ToLog(1) then prMessageLOGS(ThreadName+'.WorkProc: ������� ������ �� �/�, ����� '+
              ibsOrd.fieldByName('WOCLLOGIN').AsString+' MAILPASS '+mailLogins[i].MAILPASS, LogReg, false);
          end;
        end;
        if FStopFlag or FSafeSuspendFlag then Exit;
        ibsOrd.Next;
      end; //  while not ibsOrd.Eof
//      ibsOrd.Transaction.Rollback;
      ibsOrd.Close;

      if (length(mailLogins)<1) or FStopFlag or FSafeSuspendFlag then Exit; // ���� ��� ������� ��� ��������

      ThrData:= fnCreateThread(thtpMailBox);
      FormUserMailBoxList(ThrData); // ������������ �/�
      sleep(997); // ���� �������, ���� ���������� �����

      try
        fnSetTransParams(ibsOrd.Transaction, tpWrite);
        j:= Length(mailLogins)-1;
        for i:= j downto 0 do try
          if FStopFlag or FSafeSuspendFlag then break;
          strlog:= Cache.arClientInfo[mailLogins[i].code].Login;
          if ToLog(1) then prMessageLOGS(ThreadName+'.WorkProc: ��������� ����� '+
            strlog+' MAILPASS '+mailLogins[i].MAILPASS, LogReg, false);
          if TestUserMailBox(strlog, ThrData) and // ��������� ������� ������
            TestUser(strlog, mailLogins[i].MAILPASS, ThrData) then begin // ���� �/� ���� - ��������� Connect
            if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
            ibsOrd.SQL.Text:= 'update WEBORDERCLIENTS set WOCLEBOXCREATETIME=NULLIF(0, 0)'+
              ' where WOCLCODE='+IntToStr(mailLogins[i].code); // ���� - � Null
            ibsOrd.ExecQuery;
            ibsOrd.Transaction.Commit;
            ibsOrd.Close;
            fnDeleteFromMassLog(i); // ������� �� ������� �������
            if ToLog(2) then prMessageLOGS(ThreadName+'.WorkProc: ������ �/�, ����� '+strlog, LogReg, false);
            if ToLog(12) then prSetThLogParams(ThrData, 0, 0, 0, '������ �/�, ����� '+strlog); // ��������� � LOG ���������
          end else begin
            inc(mailLogins[i].err); // ������� ������� �������� ������
            if mailLogins[i].err>TestCount then begin // ��������� �������� ���-�� �������
              TestBody.Add('Not found mailbox, login - '+strlog);
              newTime:= mailLogins[i].BOXCREATETIME;
              TestBody.Add(' test time '+FormatDateTime(cDateTimeFormatTnD, newTime));
              TestBody.Add(' search time '+FormatDateTime(cDateTimeFormatTnD, Now));
              newTime:= IncHour(newTime, 1);     // �������� �������� �� ���
              TestBody.Add(' new test time '+FormatDateTime(cDateTimeFormatTnD, newTime));
              if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
              ibsOrd.SQL.Text:= 'update WEBORDERCLIENTS set WOCLEBOXCREATETIME=:dat'+
                ' where WOCLCODE='+IntToStr(mailLogins[i].code);
              ibsOrd.ParamByName('dat').AsDateTime:= newTime;
              ibsOrd.ExecQuery;
              ibsOrd.Transaction.Commit;
              ibsOrd.Close;
              fnDeleteFromMassLog(i); // ������� �� ������� �������
              s:= '�� ������ �/� ������ '+strlog;
              prMessageLOGS(ThreadName+'.WorkProc: '+s, LogReg, false); // ����� � log
              fnWriteToLogPlus(ThrData, lgmsSysError, ThreadName+'.WorkProc', s, '', '', false);
            end;
          end;
        except
          on E: Exception do begin
            if ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.Rollback;
            s:= '������ ������ �������� �/� '+strlog;
            prMessageLOGS(ThreadName+'.WorkProc: '+s+#13#10+E.Message, LogReg, false);
            fnWriteToLogPlus(ThrData, lgmsSysError, ThreadName+'.WorkProc', s, E.Message, '', false);
          end;
        end;
        if FStopFlag or FSafeSuspendFlag then Exit;

        if (TestBody.Count>0) then begin // ��������� ��������� ������ ��-�� Vlad
          s:= fnGetSysAdresVlad(caeOnlyDayLess);
          TestBody.Insert(0, GetMessageFromSelf);
          s:= n_SysMailSend(s, 'Mailbox-search error', TestBody, nil, '', '', true);
          if (s<>'') then begin
            strlog:=  '������ �������� ������ �� ������ ������ �/�';
            prMessageLOGS(ThreadName+'.WorkProc: '+strlog+#13#10+s, LogReg, false);
            fnWriteToLogPlus(ThrData, lgmsSysError, ThreadName+'.WorkProc', strlog, s, 'n_SysMailSend', false);
          end;
          TestBody.Clear;
        end;
      except
        on E: Exception do if (E.Message<>'') then begin
          prMessageLOGS(ThreadName+
            '.WorkProc: ������ ������ �������� �/�: '#13#10+E.Message, LogReg, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError,
            ThreadName+'.WorkProc', '������ ������ �������� �/�', E.Message, '', false);
        end;
      end;
    finally
      prFreeIBSQL(ibsOrd);
      cntsORD.SetFreeCnt(ibdOrd);
      if assigned(ThrData) then prDestroyThreadData(ThrData, ThreadName+'.WorkProc');
    end;
  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS(ThreadName+
        '.WorkProc: ������ ������ �������� �/�: '#13#10+E.Message, LogReg, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError,
        ThreadName+'.WorkProc', '������ ������ �������� �/�', E.Message, '', false);
    end;
  end;
end;
//================================================== �������� ������� �/� ������
function TestUser(login, mailpsw: String; ThreadData: TThreadData): Boolean; // - ��������� Connect
// login,mailpsw - ����� � �������� ������ ������������
var IdSMTP0: TIdSMTP;
    MsgRecive0: TIdMessage;
    pIniFile: TIniFile;
    i: Integer;
begin
  Result:= False;
  MsgRecive0:= nil;
  pIniFile:= nil;
  while flMailSendProc do sleep(101); // ����, ���� ���� �������� ��� �����
  flMailSendProc:= True;
  try
    IdSMTP0:= TIdSMTP.Create(nil);
    try
      MsgRecive0:= TIdMessage.Create(nil);
      pIniFile:= TINIFile.Create(nmIniFileBOB);
      i:= pIniFile.ReadInteger('mail', 'PortTo', 0); // PortTo BOB�
//      i:= pIniFile.ReadInteger('mail', 'PortFrom', 0); // PortFrom BOB�
      if i<1 then raise Exception.Create('������������ �������� SysPortTo='+IntToStr(i));
      IdSMTP0.AuthType:= satNone;       // ��������� �����������
      IdSMTP0.Port:= i;
      IdSMTP0.Host:= pIniFile.ReadString('mail', 'Host', '');  // Host BOB�
      IdSMTP0.Username:= login;   // ����� ������������
      IdSMTP0.Password:= mailpsw; // �������� ������ ������������
      MsgRecive0.Clear;
      try
        IdSMTP0.Connect; // ������������ � ��������� �������
      except
        on e: Exception do
          raise Exception.Create('������ �������� �/�, ����� '+login+' - not IdSMTP0.Connect'+#10+E.Message);
      end;
      Result:= IdSMTP0.Connected;
      if not Result then  // �� ������������
        raise Exception.Create('������ �������� �/�, ����� '+login+' - not IdSMTP0.Connected');
    finally
      if IdSMTP0.Connected then IdSMTP0.Disconnect;
      prFree(IdSMTP0);
      prFree(MsgRecive0);
      prFree(pIniFile);
    end;
  except
    on E: Exception do begin
      prMessageLOGS('TestUser: '+E.Message, LogReg, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestUser', '������ �������� �/�, ����� '+login, E.Message, '', false);
    end;
  end;
  flMailSendProc:= False;
end;
//******************************************************************************
//                ���������, �� ��������� �� �������� �������
//******************************************************************************
//============================================= ������� ���� ����������� �������
procedure prGetVladInitFile(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetVladInitFile'; // ��� ���������/�������
var nf, nfs, FirmCode: string;
    i, j, UserID, FirmID: integer;
    fs: TFileStream;
    SearchRec: TSearchRec;
begin
//  fs:= nil;
  Stream.Position:= 0;
  try
    FirmCode:= Stream.ReadStr;
    UserID:= Stream.ReadInt;
    FirmID:= StrToIntDef(FirmCode, 0);
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'FirmID='+FirmCode+' UserID='+IntToStr(UserID)); // �����������

    if not Cache.FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists, FirmCode));
    if not Cache.ClientExist(UserID) then
      raise Exception.Create(MessText(mtkNotClientExist, IntToStr(UserID)));

    Randomize;
    nf:= IntToStr(Random(High(LongInt)-1)+1);
    try
      i:= FindFirst(nf+'*', faAnyFile, SearchRec); // ���� ����� � �������� ������
      while i=0 do begin
        nf:= IntToStr(Random(High(LongInt)-1)+1);
        i:= FindNext(SearchRec);            // ���� ���������
      end;
    finally
      FindClose(SearchRec);
    end;
    i:= length(nf);
    nfs:= nf; // ������ ����� ���������� �����
    try
      if not WriteVladInitFile(FirmCode, nfs, ThreadData) then  // ��������� � ��� ����� ������ ����������
        raise Exception.Create('������ �������� ����� �����������: FirmCode='+FirmCode);

      fs:= TFileStream.Create(nfs, fmOpenRead);
      try
        j:= fs.Size;
        nf:= copy(nfs, i+1, length(nfs)-i+1); // ��������� ����� ����� � ������ �����������
        Stream.Clear;
        Stream.WriteInt(aeSuccess); // ������� ���� ����, ��� ������ ��������� ���������
        Stream.WriteStr(nf);        // �������� ��������� ����� �����
        Stream.WriteInt(j);         // ������ ����� ������
        Stream.CopyFrom(fs, j);
      finally
        prFree(fs);
      end;
    finally
      DeleteFile(nfs); // ������� ��������� ����
    end;
  except
    on E: Exception do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr('��������� '+nmProc+' ��������: '#13#10+E.Message);
      prMessageLOGS(nmProc+': '+E.Message, LogReg, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc,'������', E.Message, '', false);
      if Assigned(TestThread) then
        fnWriteToLogPlus(TestThread.ThreadData, lgmsSysError, nmProc,'������', E.Message, '', false);
    end;
  end;
  Stream.Position:= 0;
end;
//================================= ���������� ������ � ���� ����������� �������
function WriteVladInitFile(FirmCode: String; var nf: String; ThreadData: TThreadData): Boolean;
// FirmCode - ��� �����, nf - ��� ����� ����������� (� �������� �������� ���������� FileSet)
const nmProc = 'WriteVladInitFile'; // ��� ���������/�������
var pIniFile: TINIFile;
    RegList, FirmUsers: TStringList; // ����� ����� ����� �����������, ������ ������� � �������
    i, FirmID: integer;
    str, FirmName, mess1, mess2, mess3, s: String;
begin
  Result:= False;
  mess1:= '';
  mess2:= '';
  mess3:= '';
  FirmName:= '';
  FirmID:= StrToIntDef(FirmCode, 0);
  if FirmID<1 then Exit;

  Cache.TestFirms(FirmID, True, False, True); // ��������� ��������
  if not Cache.FirmExist(FirmID) then Exit;

  FirmName:= 'FIRMNM='+Cache.arFirmInfo[FirmID].Name;
  RegList:= TStringList.Create;
  FirmUsers:= TStringList.Create;
  pIniFile:= TINIFile.Create(nmIniFileBOB); // ��������� ��������� Connection � �����
  try try
    prFillRegistrationInfo();        // ��������� �������� ����� ��� �����������
    nf:= nf+'.'+FileSet;             // ��������� ��� ����� � ������ �����������
    DateTimeToString(str, cDateTimeFormatY4S, Now);
    RegList.Add(str); // ���� � ����� �������� �����
    if ToLog(1) then begin
      prMessageLOGS(' ', LogReg, false); // ��� �������
      prMessageLOGS(nmProc+': '+str, LogReg, false);
    end;
    mess1:= str;

    for i:= Low(afmail) to High(afmail) do begin // �������� �������� �����
      str:= afmail[i].fName+'='+pIniFile.ReadString('mail', afmail[i].fNameS, '');
      RegList.Add(str);
      mess1:= mess1+#13#10+str;
      if ToLog(1) then prMessageLOGS(nmProc+': '+str, LogReg, false); // ��� �������
    end;

    RegList.Add(FirmName); // �������� �����
    if ToLog(2) then prMessageLOGS(nmProc+': '+FirmName, LogReg, false); // ��� �������
    mess2:= FirmName;
    if not FirmUsersLoginAndPasswords(FirmCode, FirmUsers, ThreadData) then
       raise Exception.Create('������ ������������ ������ �����������: FIRMCODE='+FirmCode);

    RegList.AddStrings(FirmUsers); // ������ ������� � ������� ������������������ �����������
    if ToLog(2) or ToLog(12) then    // ��� �������
      for i:= 0 to FirmUsers.Count-1 do begin
        if ToLog(2) then prMessageLOGS(nmProc+': '+FirmUsers.Strings[i], LogReg, false);
        mess2:= mess2+#13#10+FirmUsers.Strings[i];
      end;

    Result:= fnSaveEncoded(nf, RegList); // �������� ��������� � ����
    if not Result then begin
      s:= '�� ������� �������� ��������� � ���� '+nf;
      prMessageLOGS(nmProc+': '+s, LogReg, false);
      mess3:= mess3+fnIfStr(mess3='','',#13#10)+s;
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, '', '', false);
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogReg, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message, '', false);
      mess3:= mess3+fnIfStr(mess3='','',#13#10)+'������: '+E.Message;
    end;
  end;
  finally
    prFree(pIniFile);
    prClearRegistrationInfo(); // ������� �������� ����� ��� �����������
    prFree(FirmUsers);
    prFree(RegList);
    if Assigned(TestThread) then begin
      if ToLog(11) and (mess1<>'') then fnWriteToLogPlus(TestThread.ThreadData, lgmsInfo, nmProc, mess1, '', '', false);
      if ToLog(12) and (mess2<>'') then fnWriteToLogPlus(TestThread.ThreadData, lgmsInfo, nmProc, mess2, '', '', false);
      if (mess3<>'') then fnWriteToLogPlus(TestThread.ThreadData, lgmsSysError, nmProc, mess3, '', '', false);
    end;
  end;
end;
//================ ������ ������� � ������� ������������������ ����������� �����
function FirmUsersLoginAndPasswords(FirmCode: String;
         var FirmUsers: TStringList; ThreadData: TThreadData): Boolean;
// FirmCode - ��� �����, FirmUsers - ������
const nmProc = 'FirmUsersLoginAndPasswords'; // ��� ���������/�������
var str, login, pasw, user, s1, s2: String;
    ibsOrd, ibsOrdUpd, ibsOrdPw: TIBSQL;
    ibdOrd, ibdOrdUpd: TIBDatabase;
    i, k, err, code, FirmID, userID: Integer;
    list: TStringList;
    firma: TFirmInfo;
begin
  Result:= True;
  k:= 0;     // ���-�� ����� �����������
  user:= ''; // ��� ��.������������ ����������
  list:= TStringList.Create;
  ibdOrd:= nil;
  ibdOrdUpd:= nil;
  ibsOrd:= nil;
  ibsOrdUpd:= nil;
  ibsOrdPw:= nil;
  try
    FirmID:= StrToIntDef(FirmCode, 0);
    if not Cache.FirmExist(FirmID) then Cache.TestFirms(FirmID, True, True, True);
    if not Cache.FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists, FirmCode));

    firma:= Cache.arFirmInfo[FirmID];
    userID:= firma.SUPERVISOR;
    if (userID<1) then raise Exception.Create('�� ������ ������� ������������ FIRMCODE='+FirmCode);

    if not Cache.ClientExist(userID) then Cache.TestClients(userID, True, True, True);
    if not Cache.ClientExist(userID) or (Length(firma.FirmClients)<1) then
      raise Exception.Create('�� ������� ����������: FIRMCODE='+FirmCode);

    user:= IntToStr(userID);

    try
      ibdOrdUpd:= cntsORD.GetFreeCnt;
      ibdOrd:= cntsORD.GetFreeCnt;
      ibsOrdUpd:= fnCreateNewIBSQL(ibdOrdUpd, 'ibsOrdUpd_'+nmProc, ThreadData.ID, tpWrite);
      ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibSql_'+nmProc, ThreadData.ID);
      ibsOrdPw:= fnCreateNewIBSQL(ibdOrd, 'ibsOrdPw_'+nmProc, ThreadData.ID);
      ibdOrd.DefaultTransaction.StartTransaction;
      err:= 0;
      code:= 0;
      login:= '';      // ���� ������������������ ����������� ��� ��������� ������
      ibsOrdPw.SQL.Text:= 'select WOCLCODE from WEBORDERCLIENTS where WOCLMAILPASS=:pasw';
      ibsOrdPw.Prepare;
      ibsOrd.SQL.Text:= 'select * from WEBORDERCLIENTS where WOCLFIRMCODE='+FirmCode+
        ' and not WOCLLOGIN is null and WOCLMAILPASS is null';
      ibsOrd.ExecQuery;

      if not (ibsOrd.Bof and ibsOrd.Eof) then begin
        ibsOrdUpd.Transaction.StartTransaction;
        ibsOrdUpd.SQL.Text:= 'update WEBORDERCLIENTS set WOCLMAILPASS=:WOCLMAILPASS,'+
                             'WOCLEBOXCREATETIME=:CREATETIME where WOCLCODE=:code';
        ibsOrdUpd.Prepare;
      end;

      while not (ibsOrd.Bof and ibsOrd.Eof) and (err<3) do begin
        try
          if code=ibsOrd.fieldByName('WOCLCODE').AsInteger then begin
            inc(err); // ������� ��������� ������� �������� ��������� ������
            s1:= '������ �������� ��������� ������';
            s2:= 'WOCLCODE='+IntToStr(code)+', WOCLLOGIN='+ibsOrd.fieldByName('WOCLLOGIN').AsString+
              ', WOCLPASSWORD='+ibsOrd.fieldByName('WOCLPASSWORD').AsString;
            prMessageLOGS(nmProc+': '+s1+': '+s2, LogReg, false);
            fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s1, s2, '', false);
            if Assigned(TestThread) then
              fnWriteToLogPlus(TestThread.ThreadData, lgmsSysError, nmProc, s1, s2, '', false);
          end else code:= ibsOrd.fieldByName('WOCLCODE').AsInteger;
          ibsOrd.Close;
          repeat
            pasw:= fnGenRandString(5, True, 4); // ���������� �������� ������
            ibsOrdPw.ParamByName('pasw').AsString:= pasw;
            ibsOrdPw.ExecQuery;  // ��������� �������� ������ �� ������������
            if not (ibsOrdPw.Bof and ibsOrdPw.Eof) then pasw:= '';
            ibsOrdPw.Close;
          until pasw<>'';
          if not ibsOrdUpd.Transaction.InTransaction then ibsOrdUpd.Transaction.StartTransaction;
          ibsOrdUpd.ParamByName('code').AsInteger:= code;
          ibsOrdUpd.ParamByName('WOCLMAILPASS').AsString:= pasw;
          ibsOrdUpd.ParamByName('CREATETIME').AsDateTime:= Now; // ���� � ����� ������ �� �������� �/�
          ibsOrdUpd.ExecQuery;              // ����� �������� � �������� �/� ��� ���� ���������� (Clear)
          ibsOrdUpd.Transaction.Commit;
          ibsOrdUpd.Close;
        except
          on E: Exception do begin
            prMessageLOGS(nmProc+': '+E.Message+
              #13#10'ibSql: '+ibsOrd.SQL.Text+#13#10'ibsOrdUpd: '+ibsOrdUpd.SQL.Text, LogReg, false);
            fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', E.Message, '', false);
            if Assigned(TestThread) then fnWriteToLogPlus(TestThread.ThreadData, lgmsSysError, nmProc,
              '', E.Message, 'ibSql: '+ibsOrd.SQL.Text+#13#10'ibsOrdUpd: '+ibsOrdUpd.SQL.Text, false);
          end;
        end;
        ibsOrd.ExecQuery; // ���� ��� ������������������ ����������� ��� ��������� ������
      end; // while
      ibsOrd.Close;
    finally
      prFreeIBSQL(ibsOrdUpd);
      cntsORD.SetFreeCnt(ibdOrdUpd);
    end;

    ibsOrd.SQL.Text:= 'select * from WEBORDERCLIENTS where WOCLFIRMCODE='+FirmCode+
        ' and not WOCLLOGIN is null and not WOCLMAILPASS is null';
    ibsOrd.ExecQuery;   // �������� ������������������ ����������� � �������� �������
    if (ibsOrd.Bof and ibsOrd.Eof) then
      raise Exception.Create('�� ������� ������������������ ����������: FIRMCODE='+FirmCode);

    while not ibsOrd.Eof do begin // ������ �����������
      try
        str:= '';  // ������ � ����������� ���������� �������������� ������� afusers
        for i:= 0 to 2 do // WOCLLOGIN, WOCLPASSWORD, WOCLMAILPASS
          if ibsOrd.fieldByName(afusers[i].fNameS).IsNull or (ibsOrd.fieldByName(afusers[i].fNameS).AsString='') then
            raise Exception.Create('�� ������ '+afusers[i].fNameS+': WOCLCODE='+ibsOrd.fieldByName('WOCLCODE').AsString)
          else str:= str+ibsOrd.fieldByName(afusers[i].fNameS).AsString+';';

        if not Cache.ClientExist(ibsOrd.fieldByName('WOCLCODE').AsInteger) then
          raise Exception.Create('Cache - �� ������ WOCLCODE='+ibsOrd.fieldByName('WOCLCODE').AsString);

        s1:= Cache.arClientInfo[ibsOrd.fieldByName('WOCLCODE').AsInteger].Name;
        if s1='' then str:= str+'-' else str:= str+StringReplace(s1,';',',',[rfReplaceAll]); // PRSNNAME

        str:= str+fnIfStr(ibsOrd.fieldByName('WOCLCODE').AsString=user,';1',';0'); // ������� ��.������������
        for i:= 5 to length(afusers)-1 do begin // ������� ����.������, �������� ����� � ������� �������
          if ibsOrd.FieldIndex[afusers[i].fNameS]>-1 then
            str:= str+fnIfStr(GetBoolGB(ibsOrd, afusers[i].fNameS),';1',';0')
          else str:= str+';0';
        end;
        FirmUsers.Add(pUSERID+str); // ��������� ������ � ����������� ����������
        Inc(k); 
      except
        on E: Exception do begin
          prMessageLOGS(nmProc+': '+E.Message+#13#10'ibSql: '+ibsOrd.SQL.Text, LogReg, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', E.Message, '', false);
          if Assigned(TestThread) then
            fnWriteToLogPlus(TestThread.ThreadData, lgmsSysError, nmProc, '', E.Message, 'ibSql: '+ibsOrd.SQL.Text, false);
        end;
      end;
      TestCssStopException;
      ibsOrd.Next;
    end; // ������ �����������
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message+#13#10'ibSql: '+ibsOrd.SQL.Text, LogReg, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', E.Message, '', false);
      if Assigned(TestThread) then
        fnWriteToLogPlus(TestThread.ThreadData, lgmsSysError, nmProc, '', E.Message, 'ibSql: '+ibsOrd.SQL.Text, false);
      Result:= False;
    end;
  end;
  prFreeIBSQL(ibsOrdPw);
  prFreeIBSQL(ibsOrd);
  cntsORD.SetFreeCnt(ibdOrd);
  prFree(list);
  Result:= Result and (k>0); // ���� � ������ ��� ����������� ?
end;

end.

