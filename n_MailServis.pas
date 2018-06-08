unit n_MailServis;
//******************************************************************************
//             обмен почтой с программой Vlad в отдельном потоке
//******************************************************************************
interface

uses Windows, ExtCtrls, Classes, IniFiles, Forms, SysUtils, Math, Controls,
     Variants, DateUtils, IdTCPServer, IdHTTP, DB, IBDatabase, IBSQL, System.IOUtils,
     n_free_functions, v_constants, n_CSSThreads,
     n_server_common, n_Functions, n_constants, n_vlad_mail, n_LogThreads, 
     n_DataSetsManager, n_DataCacheInMemory;

type
  TMailThread = class(TCSSCyclicThread) // определяем поток команд для приема почты
  private { Private declarations }
    TestMailKind: Integer;        // вид проверки почты
    IntervalTestOldResp: Integer; // интервал проверки незабранных ответов
    MessOldResp: Integer;         // вид вывода в лог проверки незабранных ответов
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

  TRespThread = class(TCSSCyclicThread) // определяем поток команд для обработки запросов
  private { Private declarations }
    shablon, shablon_ord, dirPutOff: string;
    SearchRec: TSearchRec;
  protected
    procedure WorkProc; override;
    procedure FileProcessing(FileName: string); // обработка файла
  public
    constructor Create(CreateSuspended: Boolean; AThreadType: integer);
    procedure DoTerminate; override;
    procedure CSSSuspend; override;
    procedure CSSResume; override;
  end;

var
  RespThread: TRespThread;   // поток обработки запросов
  MailThread: TMailThread; // поток приема почты
  MSParams: record // запись для хранения настроек почтового сервиса
    flagTestOldFile: Boolean; // флаг проверки даты файла vladdbf.zip
    flagMessOldFile: Boolean; // флаг отправки сообщения о старом файле vladdbf.zip
    TimeTestOldFile: TDateTime; // время последней проверки даты файла vladdbf_new.zip
    DirFileRep     : String;  // папка д/файлов отчетов
    MailWorked     : Boolean; // флаг работы потока приема почты и потока обработки запросов
    TestWorked     : Boolean; // флаг работы потока создания и проверки п/я
    FileDateIni    : Integer; // дата и время последнего считывания ini-файла
  end;
  PathRests: String; // папка д/остатков
  LastRestTime     : TDateTime; // время последнего обновления файлов остатков
  LastRestPriceTime: TDateTime; // время последнего обновления цен в файлах остатков
  LastBaseTime     : TDateTime; // время последнего обновления / последней проверки изменений номенклатуры файлов baseXX.dbf
  LastBaseRestTime : TDateTime; // время последнего обновления остатков в файлах baseXX.dbf
  LastBasePriceTime: TDateTime; // время последнего обновления цен в файлах baseXX.dbf

procedure StartMailServis(ThreadData: TThreadData; start: boolean=True); // запуск почтового сервиса
procedure SuspendMailServis; // приостановка почтового сервиса
procedure StopMailServis(finish: boolean=True);                      // завершение почтового сервиса
 function MailServisIsSuspended: boolean;
 function MailServisIsStopped: boolean;
procedure GetMailParams(ThreadData: TThreadData; start: boolean=True); // загрузка параметров почтового сервиса

 function NomZakVlad(NomZak: String): String;      // определяем номер заказа клиента
 function WorkWithData(list: TStringList; ThreadData: TThreadData): TFileProcRes; // разбираем набор строк из файла по командам

 function AutorizeUser(UserLog, UserPW: String; var FirmCode, FirmPrefix, UserCode: String; ThreadData: TThreadData): Boolean; // проверить пользователя
 function ResponseToClient(com: String; response: TStringList; ThreadData: TThreadData; nfzip: string=''): Boolean; // отправка ответа

procedure SetAccInvWaresToList(Account, Invoice: array of TDocRec; list: TStringList; ThreadData: TThreadData; exevers: String=''); // формируем набор строк для передачи данных и товаров закрывающих документов
 function TestVladTitles(FirmCode, UserCode, cities: string; ThreadData: TThreadData): Boolean;         // проверяем структуру колонок по заголовкам
procedure TestVladDbf(var nf: String; ThreadData: TThreadData; exevers: String=''); // проверка даты vladdbf.zip
procedure TestCurrentVersVlad(ThreadData: TThreadData);                             // проверяем текущую версию программы Влад
procedure AddInfoNewVersion(FirmCode, UserCode, exevers, exedate: String; list: TStringList; ThreadData: TThreadData); // сообщение о новой версии
procedure AddBOBMessage(FirmCode, UserCode: String; list: TStringList; ThreadData: TThreadData); // инструкции и сообщения сервера клиентам
 function TestSubjComm(Subject: string; vid: integer): Boolean;

 function GetOldDocmType(docType: Integer; dutyType: Integer=0): Integer; // получить старый код вида док-та

implementation
uses n_MailReports, n_vlad_init, n_func_ads_loc, n_vlad_common, n_vlad_files_func;
//==============================================================================
constructor TMailThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'MailThread';
  CommandAndParamsToLog(ccMailThread, ThreadData, ThreadName); // запись в LOG команды потока
  if ToLog(0) then prMessageLOGS('***** создание потока приема почты', LogMail, false); // пишем в log
  TestMsgTime:= DateNull;
end;
//==============================================================================
procedure TMailThread.CSSResume;
begin
  inherited;
  if ToLog(0) then prMessageLOGS('***** запуск потока приема почты', LogMail, false); // пишем в log
end;
//==============================================================================
procedure TMailThread.CSSSuspend;
begin
  if ToLog(0) then prMessageLOGS('***** остановка потока приема почты', LogMail, false); // пишем в log
  inherited;
end;
//==============================================================================
procedure TMailThread.DoTerminate;
begin
  FindClose(SearchRec);
  if ToLog(0) then prMessageLOGS('***** завершение потока приема почты', LogMail, false); // пишем в log
  inherited;
end;
//==============================================================================
constructor TRespThread.Create(CreateSuspended: Boolean; AThreadType: integer);
begin
  inherited Create(CreateSuspended, AThreadType);
  ThreadName:= 'RespThread';
  CommandAndParamsToLog(ccRespThread, ThreadData, ThreadName); // запись в LOG команды потока
  if ToLog(0) then prMessageLOGS('***** создание потока обработки запросов', LogMail, false); // пишем в log
  Priority:= tpHighest; //  tpHigher;
end;
//==============================================================================
procedure TRespThread.CSSResume;
begin
  inherited;
  if ToLog(0) then prMessageLOGS('***** запуск потока обработки запросов', LogMail, false); // пишем в log
end;
//==============================================================================
procedure TRespThread.CSSSuspend;
begin
  if ToLog(0) then prMessageLOGS('***** остановка потока обработки запросов', LogMail, false); // пишем в log
  inherited;
end;
//==============================================================================
procedure TRespThread.DoTerminate;
begin
  FindClose(SearchRec);
  if ToLog(0) then prMessageLOGS('***** завершение потока обработки запросов', LogMail, false); // пишем в log
  inherited;
end;

//======================================== загрузка параметров почтового сервиса
procedure GetMailParams(ThreadData: TThreadData; start: boolean=True); // start=True - все параметры
var str, s: String;
    pIniFile: TIniFile;
    ar: Tas;
    FileDateTime: TDateTime;
begin
  setLength(ar, 0);
  if FileAge(nmIniFileBOB, FileDateTime) then // запоминаем дату и время ini-файла
    MSParams.FileDateIni:= DateTimeToFileDate(FileDateTime);
//  MSParams.FileDateIni:= FileAge(nmIniFileBOB); // запоминаем дату и время считывания ini-файла
  pIniFile:= TINIFile.Create(nmIniFileBOB);
  try
    if start then begin // параметры, которые можно изменить только при перезагрузке
      MSParams.MailWorked:= (pIniFile.ReadInteger('threads', 'mailget', 0)=1); // признак работы потока приема почты и потока обработки запросов
      MSParams.TestWorked:= (pIniFile.ReadInteger('threads', 'mailbox', 0)=1); // признак работы потока создания и проверки п/я
    end;
    GetLogKinds; // виды логирования - если запущены почтовые потоки, можно изменить "на лету", 
                 // иначе только при запуске или Resume 

    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;

    if start then begin // параметры, которые можно изменить только при загрузке программы
      if ToLog(0) then prMessageLOGS(' ', LogMail, false); // пишем в log разделитель
      MSParams.flagTestOldFile:= True; // взводим флаг проверки даты файла vladdbf.zip
      MSParams.flagMessOldFile:= False;
      MSParams.TimeTestOldFile:= 0;
      if MSParams.MailWorked then begin // запускаем почтовые потоки
        MailThread:= TMailThread.Create(True, thtpMail); // создаем поток приема почты
        RespThread:= TRespThread.Create(True, thtpMail); // создаем поток обработки запросов
      end;
      if MSParams.TestWorked then begin // запускаем поток проверки п/я
        TestThread:= TTestThread.Create(True, thtpMailBox); // создаем поток проверки п/я
      end;
    end;

    // параметры, которые можно изменить "на лету", если запущены почтовые потоки
    AttachPath:= pIniFile.ReadString('mail', 'AttachPath', 'mailtmp'); // папка для принятых файлов (vlad_mail)
    str:= GetAppExePath+fnTestDirEnd(AttachPath, false);
    if not DirectoryExists(str) and not CreateDir(str) then begin  // если папки нет - создавать
      s:= 'Не могу создать папку '+str;
      prMessageLOGS('GetMailParams: '+s, LogMail, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'GetMailParams', 'Ошибка', s);
      str:= GetAppExePath;
    end;
    AttachPath:= str;
    MailParam.PortTo   := pIniFile.ReadString('mail', 'PortTo', '');   // PortTo = 25
    MailParam.PortFrom := pIniFile.ReadString('mail', 'PortFrom', ''); // PortFrom = 110
    MailParam.Host     := pIniFile.ReadString('mail', 'Host', '');     // Host = 'gatenet'
    MailParam.UserID   := pIniFile.ReadString('mail', 'ServerID', ''); // логин БОБ-а
    MailParam.Password := pIniFile.ReadString('mail', 'serverPW', ''); // пароль БОБ-а
//    MailParam.ToAdres  := '';                                       // адрес "кому" - формируется программно
    MailParam.FromAdres:= pIniFile.ReadString('mail', 'AdresAll', ''); // общий п/я

    str:= GetAppExePath+pIniFile.ReadString('mail', DirRepFiles, DirRepFilesDef); // папка д/файлов отчетов
    if not DirectoryExists(str) and not CreateDir(str) then begin // если папки нет - создавать
      s:= 'Не могу создать папку '+str;
      prMessageLOGS('GetMailParams: '+s, LogMail, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'GetMailParams', 'Ошибка', s);
      str:= GetAppExePath;
    end;
    MSParams.DirFileRep:= fnTestDirEnd(str);

    if MSParams.MailWorked then begin
      MailThread.CycleInterval:= pIniFile.ReadInteger('intervals', 'intervalmail', 10); // интервал задержки приема почты в сек.
      MailThread.IntervalTestOldResp:= pIniFile.ReadInteger('intervals', 'IntervalTestOldResp', 10); // интервал проверки незабранных ответов в мин.
      MailThread.MessOldResp:= pIniFile.ReadInteger('Logs', 'MessOldResp', 1); // вид вывода в лог незабранных ответов
      MailThread.PathBox:= fnTestDirEnd(pIniFile.ReadString('mail', 'MDaemonPathBox', ''))+ // папка для писем
        copy(MailParam.FromAdres, pos('@', MailParam.FromAdres)+1, length(MailParam.FromAdres)); // домен
      MailThread.shablon:= MailThread.PathBox+PathDelim+MailParam.UserID+PathDelim+'*.msg';
      MailThread.TestMailKind:= pIniFile.ReadInteger('mail', 'TestKind', 0); // 0- проверять п/я, 1- проверять файлы писем
      RespThread.CycleInterval:= pIniFile.ReadInteger('intervals', 'intervalresp', 5);  // интервал задержки обработки запросов в сек.
      RespThread.shablon:= fnTestDirEnd(AttachPath)+'*.'+FileInd+'*'; // шаблон поиска файлов запросов с заданным расширением FileInd
      RespThread.shablon_ord:= fnTestDirEnd(AttachPath)+'*AddNewZaks*.'+FileInd+'*'; // шаблон поиска файлов заказов
      RespThread.dirPutOff:= fnTestDirEnd(AttachPath)+'PutOff'; // папка для отложенных файлов
    end;
    if MSParams.TestWorked then begin
      TestThread.CycleInterval:= pIniFile.ReadInteger('intervals', 'MailBoxTestInterval', 30); // через сколько сек проверять
      TestThread.TestCount:= pIniFile.ReadInteger('intervals', 'MailBoxTestCount', 6); // сколько раз повторять при неудаче
    end;
  finally
    prFree(pIniFile);
    setLength(ar, 0);
  end;
end;
//========================================== запуск/перезапуск почтового сервиса
procedure StartMailServis(ThreadData: TThreadData; start: boolean=True); // start=True - начальная загрузка
var FileDateTime: TDateTime;
begin
  try
    if FileAge(nmIniFileBOB, FileDateTime) and (DateTimeToFileDate(FileDateTime)>MSParams.FileDateIni) then
      GetMailParams(ThreadData, start); // загрузка параметров почтового сервиса

    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;
    if start and FileExists(Cache.FormVladBlockFile) then DeleteFile(Cache.FormVladBlockFile);

    if MSParams.MailWorked then begin
      if Assigned(MailThread) and MailThread.Suspended then MailThread.CSSResume;
      if Assigned(RespThread) and RespThread.Suspended then RespThread.CSSResume;
    end;

    if MSParams.TestWorked and Assigned(TestThread) and TestThread.Suspended then TestThread.CSSResume;
  except
    on E: Exception do prMessageLOGS('Ошибка StartMailServis: '+E.Message);
  end;
end;
//=============================================== приостановка почтового сервиса
procedure SuspendMailServis;
begin
  try
    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;
    if ToLog(0) then prMessageLOGS('===== начинаю приостановку почтовых потоков =====', LogMail, false); // пишем в log
//    if Assigned(MailThread) then MailThread.SafeSuspend;
//    if Assigned(RespThread) then RespThread.SafeSuspend;
    if Assigned(TestThread) then TestThread.SafeSuspend;
    if ToLog(0) then prMessageLOGS('===== почтовые потоки приостановлены =====', LogMail, false);
    Application.ProcessMessages;
  except
    on E: Exception do prMessageLOGS('Ошибка SuspendMailServis: '+E.Message);
  end;
end;
//================================================= завершение почтового сервиса
procedure StopMailServis(finish: boolean=True); // finish=False - только команда на остановку
const nmProc = 'StopMailServis'; // имя процедуры/функции
var i: Integer;
    LocalStart: TDateTime;
begin
  try
    if not (MSParams.MailWorked or MSParams.TestWorked) then Exit;

    LocalStart:= now();
    if not finish then begin
      if ToLog(0) then prMessageLOGS('===== начинаю остановку почтовых потоков =====', LogMail, false); // пишем в log
      if Assigned(MailThread) then MailThread.Stop;
      if Assigned(RespThread) then RespThread.Stop;
      if Assigned(TestThread) then TestThread.Stop;
      if ToLog(0) then prMessageLOGS('===== почтовые потоки остановлены =====', LogMail, false);
      if flTest then prMessageLOGS(nmProc+'_Stop: - '+
        GetLogTimeStr(LocalStart), fLogDebug, false);

    end else begin
      if ToLog(0) then prMessageLOGS('===== проверяю завершение почтовых потоков =====', LogMail, false); // пишем в log
      i:= 0;
      while Assigned(MailThread) and not MailThread.Terminated and (i<100) do begin
        sleep(31); // завершение потока приема почты
        inc(i);
      end;
      i:= 0;
      while Assigned(RespThread) and not RespThread.Terminated and (i<100) do begin
        sleep(31); // завершение потока обработки запросов
        inc(i);
      end;
      i:= 0;
      while Assigned(TestThread) and not TestThread.Terminated and (i<100) do begin
        sleep(31); // завершение потока создания и проверки п/я
        inc(i);
      end;
      if ToLog(0) then prMessageLOGS('===== почтовые потоки завершены =====', LogMail, false);
      if flTest then prMessageLOGS(nmProc+'_Exit: - '+
        GetLogTimeStr(LocalStart), fLogDebug, false);
    end;
    Application.ProcessMessages;
  except
    on E: Exception do prMessageLOGS('Ошибка StopMailServis: '+E.Message);
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
//=========================================================== поток приема почты
procedure TMailThread.WorkProc;
var FileDateTime: TDateTime;
//    arNames: Tas;
//    i: integer;
    lst: TStringList;
begin
  lst:= nil;
//  setLength(arNames, 0);
  try try   // перезагрузка некоторых параметров почтового сервиса при изменении ini-файла
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

      GetMailid; // получить письма (от vlad)
      if (length(MessageTxt)>0) and (MessageTxt<>'Нет сообщений!') then begin
        if ToLog(6) then prMessageLOGS(' ', LogMail, false); // пишем в log
        if ToLog(6) then prMessageLOGS(MessageTxt, LogMail, false); // пишем в log
        if ToLog(16) then fnWriteToLogPlus(ThreadData, lgmsInfo, ThreadName+'.WorkProc', MessageTxt);
      end;

//      if FStopFlag or FSafeSuspendFlag then Exit;
      if FStopFlag then Exit;

      prDeleteAllFiles('*.mme', AttachPath);  // удаление лишних файлов
      prDeleteAllFiles('*.eml', AttachPath);
      prDeleteAllFiles('*.tmp', AttachPath);
      Application.ProcessMessages;
    end;

//    if FStopFlag or FSafeSuspendFlag then Exit;
    if FStopFlag then Exit;
    if (AppStatus=stWork) and (IntervalTestOldResp>0)
      and (Now>IncMinute(TestMsgTime, IntervalTestOldResp)) then begin
      TestOldResponses; // проверка незабранных ответов
//      prMessageLOGS(FormatFloat('Memory used: , .# K', fnGetCurrentMemoryUsage/1024), 'MemUsed', false);   // для отладки
    end;

  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS(ThreadName+'.WorkProc: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, ThreadName+'.WorkProc', 'Ошибка потока', E.Message);
    end;
  end;
  finally
  //  FindClose(SearchRec);
//    setLength(arNames, 0);
    prFree(lst);
  end;
end;
//================================================= проверка незабранных ответов
procedure TMailThread.TestOldResponses;
var s, nf, path, mess8, sf: string;
    i, vid: integer;
    lst: TStringList;
    ftime, LocalThreadStart: TDateTime;
    oldfile: textfile; // идентификатор файла
    fdel: Boolean;
    ThreadData: TThreadData; // параметры потока записи в LOG
begin
  if (FindFirst(PathBox+'\*', faDirectory, SearchRec)<>0) then Exit;
  ThreadData:= fnCreateThread(thtpMail); // создаем LOG-поток проверки
  CommandAndParamsToLog(ccTestOldRes, ThreadData, 'TestOldResponses'); // запись параметров LOG-потока
  lst:= TStringList.Create; // список пользовательских папок (логинов)
  mess8:= '';
  LocalThreadStart:= now();
  try
    repeat                           // составляем список пользовательских папок
      if fnNotLockingLogin(SearchRec.Name) then lst.Add(SearchRec.Name);
    until FindNext(SearchRec)<>0;
{$I-}
    for i:= 0 to lst.Count-1 do begin // проверяем пользовательские папки
      path:= PathBox+PathDelim+lst.Strings[i]+PathDelim;
      if (FindFirst(path+'*.msg', faAnyFile, SearchRec)=0) then // ищем почтовые файлы *.msg - ответы сервера
        repeat
          ftime:= SearchRec.TimeStamp; // дата и время файла
          if (ftime<IncHour(Now, -2)) then vid:= 2 // если файл пролежал 2 часа
          else if (ftime<IncHour(Now, -1)) then vid:= 1 // если файл пролежал 1 час
          else vid:= 0;
//          vid:= 2; // для отладки
          if vid>0 then begin // если надо проверять файл
            sf:= lst.Strings[i]+PathDelim+SearchRec.Name+' ('+FormatDateTime(cDateTimeFormatY2S, ftime);
            nf:= path+ChangeFileExt(SearchRec.Name, '.old');
            if FileExists(nf) then DeleteFile(nf);
            Application.ProcessMessages;
            if RenameFile(path+SearchRec.Name, nf) then begin // переименовываем файл
              Application.ProcessMessages;
              AssignFile(oldfile, nf);
              Application.ProcessMessages;
              try
                Reset(oldfile);
                Application.ProcessMessages;
                fdel:= False;
                while not Eof(oldfile) do begin
                  ReadLn(oldfile, s);
                  if (pos('Subject:', s)>0) then begin // проверяем тему
                    fdel:= TestSubjComm(s, 3); // приветствия
                    if fdel then break;
                    case vid of
                    1: fdel:= TestSubjComm(s, 1); // если не забрали ответ 1 час
                    2: fdel:= TestSubjComm(s, 2) or TestSubjComm(s, 1); // если не забрали ответ 2 часа
                    end; // case
                    break;
                  end;
                end;
                Application.ProcessMessages;
              finally
                CloseFile(oldfile);
              end;
              Application.ProcessMessages;
              if fdel then fdel:= DeleteFile(nf); // удаляем файл
              Application.ProcessMessages;
              if not fdel then RenameFile(nf, path+SearchRec.Name); // если не удалили - переименовываем обратно
              Application.ProcessMessages;
              if fdel then // если удалили файл
                mess8:= mess8+fnIfStr(mess8='', '', #10)+sf+', '+ExtractParametr(s, ':')+') удален'
              else if (MessOldResp>0) then // если не удалили файл
                mess8:= mess8+fnIfStr(mess8='', '', #10)+sf+', '+ExtractParametr(s, ':')+') оставлен';
            end else  // не смогли переименовать файл
              mess8:= mess8+fnIfStr(mess8='', '', #10)+sf+') - ошибка: не могу переименовать';
          end; // if vid>0
          Application.ProcessMessages;
        until FindNext(SearchRec)<>0;
    end;
{$I+}
    Application.ProcessMessages;
    if mess8<>'' then begin
      mess8:= #10'TestOldResponses: проверка старых ответов'+fnIfStr(mess8='', '', #10)+mess8+#10;
      if (MessOldResp>1) then mess8:= mess8+
        'TestOldResponses: проверяли '+GetLogTimeStr(LocalThreadStart)+#10;
      if ToLog(8) then prMessageLOGS(mess8, LogMail, false);
      if ToLog(18) then fnWriteToLogPlus(ThreadData, lgmsInfo, 'TestOldResponses', 'проверка старых ответов', mess8);
    end;
    Application.ProcessMessages;
  except
    on E: Exception do
      if (E.Message<>'') then begin
        prMessageLOGS('TestOldResponses: '+E.Message, LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestOldResponses', 'Ошибка проверки старых ответов', E.Message);
      end;
  end;
  prFree(lst);
  TestMsgTime:= Now; // время последней проверки незабранных ответов
  prDestroyThreadData(ThreadData, 'TestOldResponses'); // очищаем LOG-поток
end;
//=============================================== проверка условия в теме письма
function TestSubjComm(Subject: string; vid: integer): Boolean;
begin
  Result:= False;
  case vid of
  0:  if (pos(cAddNewZaks, Subject)>0) or (pos(cSendMesMan, Subject)>0) // новый заказ, письмо менеджеру
        or (pos(cBOBMessage, Subject)>0)                               // сообщения сервера клиентам
        then Result:= True;  // ответы не удалять
  1:  if (pos(cGetDataAll, Subject)>0) or (pos(cGetReAndPr, Subject)>0)   // полное обновление, обновление остатков
        or (pos(cGetRateCur, Subject)>0) or (pos(cGetFirmDis, Subject)>0) // курс у.е., скидки
        or (pos(cLoadLogins, Subject)>0) or (pos('Welcome to the email system', Subject)>0) // список пользователей, приветствия
        or (pos('Welcome to MDaemon', Subject)>0)
        then Result:= True; // если не забрали ответ в теч.1 час - удалять
  2:  if (pos(cStatusZaks, Subject)>0) or (pos(cLoadingZak, Subject)>0)   // статусы заказов, загрузка заказов
        or (pos(cRepAccList, Subject)>0) or (pos(cUnpayedDoc, Subject)>0) // незакрытые счета, неоплаченные док-ты
        or (pos(cFactSumZak, Subject)>0) or (pos(cLoadDelivr, Subject)>0) // сверка заказов, таблица доставок (пока не исп.)
        or (pos(cReportDebt, Subject)>0) or (pos(cGetCheckDt, Subject)>0) // кредитные условия, сверка
        or (pos(cGetDivisib, Subject)>0) or (pos(cGetNewVers, Subject)>0) // кратность товаров, новая версия
        then Result:= True;  // если не забрали ответ в теч.2 час - удалять
  end; // case
end;
//===================================================== поток обработки запросов
procedure TRespThread.WorkProc;
var flag: Boolean;
begin
  try
    if (AppStatus in [stStarting, stResuming]) then Exit; // если запускаемся - пропускаем этот цикл

    if (AppStatus in [stWork]) and DirectoryExists(dirPutOff) then begin
      flag:= (FindFirst(fnTestDirEnd(dirPutOff)+'*.'+FileInd+'*', faAnyFile, SearchRec)=0); // ищем отложенные файлы
      while flag and not (FStopFlag or FSafeSuspendFlag) do begin // возвращаем отложенные файлы в обработку
        RenameErrFile(SearchRec.Name, dirPutOff, AttachPath, True);
        flag:= (FindNext(SearchRec)=0); // ищем следующий
      end;
      if not flag then fnDeleteTmpDir(dirPutOff);
    end;

    if (FindFirst(shablon, faAnyFile, SearchRec)<>0) or FStopFlag then Exit; // если нет файлов для обработки
    repeat
      flag:= (FindFirst(shablon_ord, faAnyFile, SearchRec)=0); // ищем файлы заказов
      while flag and not FStopFlag do begin // обрабатываем файлы заказов
        FileProcessing(SearchRec.Name);
        flag:= (FindNext(SearchRec)=0); // ищем следующий
      end; // while flag...
      flag:= (FindFirst(shablon, faAnyFile, SearchRec)=0) and not FStopFlag;
      if flag then FileProcessing(SearchRec.Name); // обрабатываем 1 другой запрос
    until not flag or FStopFlag;

  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS('TRespThread.WorkProc: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'TRespThread.WorkProc', 'Ошибка потока', E.Message);
    end;
  end;
  FindClose(SearchRec);
end;
//============================================================== обработка файла
procedure TRespThread.FileProcessing(FileName: string);
const nmProc = 'FileProcessing'; // имя процедуры/функции
var list: TStringList;
    i: integer;
    res: TFileProcRes;
    ThreadData: TThreadData; // параметры потока записи в LOG обработки запроса
    s: string;
begin
  ThreadData:= nil;
  list:= nil;
  try
    ThreadData:= fnCreateThread(thtpMail); // создаем LOG-поток обработки запроса
    CommandAndParamsToLog(0, ThreadData, copy(FileName, 1, pos('.', FileName)-1)); // запись параметров LOG-потока обработки запроса
    if ToLog(2) then prMessageLOGS('FileProcessing: Обработка файла '+FileName, LogMail, false);

    list:= ExtractDataFromFile(fnTestDirEnd(AttachPath)+FileName); // извлекаем набор строк из файла (vlad_mail)

    if not Assigned(list) or (list.Count<1) then begin
      res:= fprEmpty;
      s:= 'пустой файл '+FileName;
      prMessageLOGS(nmProc+': '+s, LogMail, false); // пишем в log
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s);

    end else if (length(list.Strings[0])<7) or (copy(list.Strings[0], 1, 7)<>pUSERID) then begin
      res:= fprError;
      s:= 'некорректный файл '+FileName;
      prMessageLOGS(nmProc+': '+s, LogMail, false); // пишем в log
      for i:= 0 to list.Count-1 do prMessageLOGS(': '+list[i], LogMail, false); // пишем в log
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s);
//      raise Exception.Create('Empty file');

    end else for i:= 1 to RepeatCount do begin // RepeatCount раз
      res:= WorkWithData(list, ThreadData);
      if res in [fprSuccess, fprPutOff] then break; // если файл обработан или нужно отложить - выходим

      if res in [fprEmptLog] then s:= '' else s:= IntToStr(i)+'-й попытки ';
      s:= 'ошибка '+s+'обработки файла '+FileName;
      prMessageLOGS(nmProc+': '+s, LogMail, false); // пишем в log
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s);
      if res in [fprEmptLog] then break; // если пустой логин

      if FStopFlag or (i=RepeatCount) then break else sleep(RepeatSaveInterval);
    end; // for

    s:= '';
    case res of
      fprSuccess, fprEmpty, fprEmptLog: // удаляем обработанный или пустой файл
        DeleteFile(fnTestDirEnd(AttachPath)+FileName);
      fprError:  // если был сбой - перемещаем файл в папку д/сбойных файлов
        s:= RenameErrFile(FileName, AttachPath, DirFileErr);
      fprPutOff:           // отложить обработку файла (до Resume)
        s:= RenameErrFile(FileName, AttachPath, dirPutOff, True);
    end; // case
    if (s<>'') then raise Exception.Create(s);

    Application.ProcessMessages;
  except
    on E: Exception do if (E.Message<>'') then begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка', E.Message);
    end;
  end;
  prFree(list);
  prDestroyThreadData(ThreadData, nmProc); // очищаем LOG-поток обработки запроса
end;

//******************************************************************************
//                    разбираем набор строк из файла по командам
//******************************************************************************
function WorkWithData(list: TStringList; ThreadData: TThreadData): TFileProcRes;
const nmProc = 'WorkWithData'; // имя процедуры/функции
// возвращает True, если все отработало нормально - значит, можно удалять файл
var i, j, j1, j2, onzipSize: Integer;
    str, FirmCode, FirmPrefix, UserCode, UserLog, UserPW, BegDat, 
      exevers, exedate, exeinf, mess1, dataDate, baseDate: String;
    response, wlst: TStringList; // ответ сервера на запрос, рабочий список
    Wlines: array of TWareLine;
    arZaks: array of TZakazLine; // д/сохр.параметров запросов
    ar: Tas;
    flResult: boolean;
//----------------------------------------------
procedure AddOtherResp(res: TStringList);
var lst: TStringList;
    j: integer;
begin
  lst:= nil;
  try
    lst:= ReportFirmDiscounts(FirmCode, UserCode, ThreadData); // добавляем список скидок фирмы
    if Lst.Count>0 then for j:= 0 to Lst.Count-1 do res.Add(lst.Strings[j]);
  finally prFree(lst); end;
  try
    lst:= ReportRateCur(FirmCode, UserCode, ThreadData); // добавляем курс у.е.
    if Lst.Count>0 then for j:= 0 to Lst.Count-1 do res.Add(lst.Strings[j]);
  finally prFree(lst); end;
  try
    lst:= GetDivisible(FirmCode, UserCode, ThreadData); // добавляем кратность товаров
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
        mess1:= mess1+fnIfStr(mess1='', '', #13#10)+list.Strings[j]; // для отладки
        if list.Strings[j]=cLoadingZak then j1:= j+5;
        if (j1>0) and (j>j1) then break;
      end;
    if ToLog(7) then prMessageLOGS(nmProc+': запрос'#13#10+mess1, LogMail, false);
    if ToLog(17) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, 'запрос', mess1);

    ar:= fnSplitString(ExtractParametr(list.Strings[0])); // UserLog;UserPW;exevers;exedate;...UserParams
    UserLog:= ar[0];
    if trim(UserLog)='' then begin
      Result:= fprEmptLog;
      raise Exception.Create('Empty UserLog');
    end;

    UserPW:= ar[1];
    if (length(ar)>2) then exevers:= ar[2] else exevers:= ''; // версия программы клиента
    if (length(ar)>3) then exedate:= ar[3] else exedate:= ''; // дата программы клиента
                          // формируем адрес "кому" по логину для отправки ответа
    MailParam.ToAdres:= UserLog+copy(MailParam.FromAdres, pos('@', MailParam.FromAdres), length(MailParam.FromAdres));

    str:= GetMessageNotCanWorks;
    if str<>'' then begin //------------------ если не готов ответить на запрос
      UserCode:= list.Strings[1];
      response.Add('response:'+cBOBMessage); // сообщение клиенту
      response.Add(pINFORM+str); // записываем в ответ сообщение
      if (UserCode=cAddNewZaks) then begin // заказ
        response.Add(pINFORM+'Ваш заказ поставлен в очередь на обработку.');
        Result:= fprPutOff;
      end else if (UserCode=cSendMesMan) then begin // письмо менеджеру
        response.Add(pINFORM+'Ваше сообщение менеджеру поставлено в очередь на отправку.');
        Result:= fprPutOff;
      end; // else response.Add(pINFORM+'Повторите Ваш запрос позже.');
      ResponseToClient(cBOBMessage, response, ThreadData); // отправляем ответ - response
      UserCode:= '';
      raise Exception.Create('');

    end else if AutorizeUser(UserLog, UserPW, FirmCode, FirmPrefix, UserCode, ThreadData) then // проверить пользователя
      prSetThLogParams(ThreadData, 0, StrToIntDef(UserCode, 0), StrToIntDef(FirmCode, 0), '') // логирование в ib_css

    else begin
      response.Add('response:'+cLoadLogins); // ошибка авторизации
      if UserCode='' then UserCode:= 'Ошибка авторизации';
      wlst.Text:= UserCode;
      for j:= 0 to wLst.Count-1 do response.Add(pINFORM+wlst.Strings[j]); // записываем в ответ сообщение
//      response.Add(pINFORM+UserCode);
      case StrToIntDef(FirmPrefix, 0) of
        -1: begin
              prFillRegistrationInfo(); // заполняем описания полей для регистрации
              FirmUsersLoginAndPasswords(FirmCode, response, ThreadData); // неверный входной пароль - передаем список логинов и паролей
              prClearRegistrationInfo(); // очищаем описания полей для регистрации
            end;
        -2: begin
              str:= GetIniParam(nmIniFileBOB, 'mail', 'UrlChangePW'); // ссылка для смены временного пароля
              if str<>'' then response.Add(pCOMMNT+str); // Временный пароль - передаем ссылку для смены пароля
            end;
      end;
      flResult:= ResponseToClient(cLoadLogins, response, ThreadData); // отправляем ответ - response
      if ToLog(1) or ToLog(11) then begin
        mess1:= '';
        for j:= 0 to response.Count-1 do mess1:= mess1+fnIfStr(mess1='', '', #13#10)+response.Strings[j]; // для отладки
//        if ToLog(1) then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, 'запрос', mess1);
      end;
      UserCode:= '';
      FirmCode:= '';
      raise Exception.Create('');
    end;
//-------------------------------------------------- доп.данные клиента
    if (length(ar)>4) then NetConnectionType:= StrToIntDef(ar[4], 0) else NetConnectionType:= -1; // тип соединения с Интернетом
    if (length(ar)>5) then MailParam.SocketHost:= ar[5] else MailParam.SocketHost:= '';                      // альтерн.Host
    if (length(ar)>6) then MailParam.SocketPortTo:= StrToIntDef(ar[6], 0) else MailParam.SocketPortTo:= 0;    // альтерн.PortTo
    if (length(ar)>7) then MailParam.SocketPortFrom:= StrToIntDef(ar[7], 0) else MailParam.SocketPortFrom:= 0;// альтерн.PortFrom

    if (length(ar)>8) then onzipSize:= StrToIntDef(ar[8], 0) else onzipSize:= 0; // размер zip ор.н. клиента
    if (length(ar)>9) then dataDate:= ar[9] else dataDate:= '';   // дата данных клиента
    if (length(ar)>10) then baseDate:= ar[10] else baseDate:= ''; // дата base.dbf клиента

    str:= SetUserParams(UserCode, UserLog, UserPW, exevers, exedate); // запись параметров клиента Влад
    if str<>'' then begin
      prMessageLOGS(nmProc+': '+str, LogMail, false);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', str);
    end;
//--------------------------------------------------
    if not ((exevers<>'') and VersFirstMoreSecond(exevers, '', VladVersion509, ''))
      and (list.Strings[1]<>cGetNewVers) then begin // блокируем старые версии до 5.1.0 (кроме запроса новой версии)
      str:= '';
      response:= ReportBlockOldVers(list.Strings[1], exevers, exedate, str, ThreadData);
      flResult:= ResponseToClient(list.Strings[1], response, ThreadData, str); // отправляем ответ - response
      if ToLog(1) or ToLog(11) then begin
        mess1:= '';
        for j:= 0 to response.Count-1 do mess1:= mess1+fnIfStr(mess1='', '', #13#10)+response.Strings[j]; // для отладки
//        if ToLog(1) then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, 'запрос', mess1);
      end;
      UserCode:= '';
      FirmCode:= '';
      raise Exception.Create('');
    end;

    i:= 1;
    while i<list.Count do begin
      response.Clear;  // очищаем "бланк" ответа для очередной команды
      Application.ProcessMessages;
      if list.Strings[i]=cAddNewZaks then begin //==================== новый заказ
        Inc(i);
        setLength(arZaks, 1);
        setLength(Wlines, 0); // активизируем массив для товаров заказа
        while i<list.Count do begin //
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then begin
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // параметры заказа - в массив
            arZaks[0].NomZak:= ar[0]; // № заказа
//            arZaks[0].DatZak:= fnTestDateYear4(ar[1]);
            arZaks[0].DatZak:= ar[1];
            arZaks[0].OplZak:= ar[2];
            arZaks[0].ValZak:= ar[3];
            arZaks[0].DeliTp:= ar[4]; // тип доставки
            if arZaks[0].DeliTp='1' then arZaks[0].DeliTp:= '0' else arZaks[0].DeliTp:= '1'; // приводим в соответствие со счетами
            arZaks[0].SumZak:= fnTestDecSep(ar[5]); // SUMZAK
            if (length(ar)>6) then arZaks[0].storage:= ar[6];
          end else if copy(list.Strings[i], 1, 7)=pWARRNT then begin  // реквизиты доверенности
            arZaks[0].Warrnt:= ExtractParametr(list.Strings[i]);
          end else if copy(list.Strings[i], 1, 7)=pCOMMNT then begin  // примечание
            arZaks[0].Commnt:= ExtractParametr(list.Strings[i]);
          end else if copy(list.Strings[i], 1, 7)=pKTOVAR then begin // KTOVAR= строки товаров
            j2:= Length(Wlines);
            setLength(Wlines, j2+1);
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // параметры товара - в массив
            Wlines[j2].WCode:= ar[0];                             // код товара
            Wlines[j2].WKolv:= ar[1];                             // количество
            Wlines[j2].WCena:= fnTestDecSep(ar[2]);               // цена
          end else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        response:= AddNewZaksOrd(FirmCode, FirmPrefix, UserCode, arZaks[0], Wlines, ThreadData, exevers); // записываем в БД новый заказ
        flResult:= ResponseToClient(cAddNewZaks, response, ThreadData); // отправляем ответ - response

      end else if list.Strings[i]=cStatusZaks then begin //======= статусы заказов
        Inc(i);
        setLength(arZaks, 0);
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then begin // № заказа
            j1:= Length(arZaks);
            setLength(arZaks, j1+1);
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // параметры заказа - в массив
            arZaks[j1].nomstr:= ar[0]; // № заказа символьный
            arZaks[j1].NomZak:= ar[1]; // № заказа
  //          arZaks[j1].Status:= ar[2]; // пока не используется
  //          arZaks[j1].DatZak:= fnTestDateYear4(ar[3]); // пока не используется
          end else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        response:= GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode, arZaks, ThreadData, exevers); // получить статусы заказов
        flResult:= ResponseToClient(cStatusZaks, response, ThreadData); // отправляем ответ - response

      end else if list.Strings[i]=cLoadingZak then begin //====== загрузка заказов
        Inc(i);
        setLength(arZaks, 0);
        BegDat:= '';
        while i<list.Count do begin //
          str:= list.Strings[i];
          if copy(str, 1, 7)=pBEGDAT then begin
            BegDat:= ExtractParametr(list.Strings[i]); // BegDat:= fnTestDateYear4(ExtractParametr(list.Strings[i]));
          end else if copy(str, 1, 7)=pNOMSTR then begin // № заказа клиента (для заказа с сервера: № заказа на сервере)
            j1:= Length(arZaks);
            setLength(arZaks, j1+1);
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // параметры заказа - в массив
            arZaks[j1].nomstr:= ar[0]; // № заказа символьный
            arZaks[j1].NomZak:= ar[1]; // № заказа
            if Length(ar)>2 then arZaks[j1].DatZak:= ar[2]; // пока не используется
          end else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        response:= LoadingZaksOrd(FirmCode, FirmPrefix, UserCode, BegDat, arZaks, ThreadData, exevers); // загрузить заказы
        flResult:= ResponseToClient(cLoadingZak, response, ThreadData); // отправляем ответ

{      end else if list.Strings[i]=cLoadDelivr then begin //===== загрузка доставок
        Inc(i);
        response:= LoadDeliver(FirmCode, UserCode);
        flResult:= ResponseToClient(cLoadDelivr, response, '', ThrID); // отправляем ответ}

      end else if list.Strings[i]=cGetDivisib then begin //===== загрузка кратности товаров
        Inc(i);
        response:= GetDivisible(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cGetDivisib, response, ThreadData); // отправляем ответ

      end else if list.Strings[i]=cUnpayedDoc then begin //===== список неоплаченных документов
        Inc(i);                               // + список незакрытых счетов + кредитные условия
        response:= ReportUnpayedDocOrd(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cUnpayedDoc, response, ThreadData); // отправляем ответ

      end else if list.Strings[i]=cGetFirmDis then begin // список скидок фирмы
        Inc(i);
        response:= ReportFirmDiscounts(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cGetFirmDis, response, ThreadData); // отправляем ответ

      end else if list.Strings[i]=cGetRateCur then begin //============= курс у.е.
        Inc(i);
        response:= ReportRateCur(FirmCode, UserCode, ThreadData);
        flResult:= ResponseToClient(cGetRateCur, response, ThreadData); // отправляем ответ

      end else if list.Strings[i]=cLoadLogins then begin //== список пользователей
        Inc(i);
        response.Add('response:'+cLoadLogins);
        prFillRegistrationInfo(); // заполняем описания полей для регистрации
        FirmUsersLoginAndPasswords(FirmCode, response, ThreadData);
        prClearRegistrationInfo(); // очищаем описания полей для регистрации
        flResult:= ResponseToClient(cLoadLogins, response, ThreadData); // отправляем ответ - response

      end else if list.Strings[i]=cGetDataAll then begin // полное обновление товаров
        Inc(i);
        str:= nfzipvlad; // имя архива обновления
        response:= ReportDataAll(FirmCode, UserCode, str, ThreadData, exevers);
        AddInfoNewVersion(FirmCode, UserCode, exevers, exedate, response, ThreadData); // сообщение о новой версии
        AddOtherResp(response); // отправляем дополнительные ответы
        flResult:= ResponseToClient(cGetDataAll, response, ThreadData, str); // отправляем ответ

      end else if list.Strings[i]=cGetReAndPr then begin // обновление остатков и цен
        Inc(i);
        BegDat:= '';
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then // список складов из Влада
            BegDat:= ExtractParametr(list.Strings[i])
          else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        if //VersFirstMoreSecond(exevers, '', VladVersion513, '') and // до 5.2.0 не работает
          TestVladTitles(FirmCode, UserCode, BegDat, ThreadData) then begin // совпадает структура колонок
          str:= 're'+fnGenRandString(4); // имя файла с остатками без расширения
          response:= ReportRestAndPrice(FirmCode, UserCode, str, ThreadData, exevers);
          flResult:= ResponseToClient(cGetReAndPr, response, ThreadData, str); // отправляем ответ
        end else begin
          str:= nfzipvlad; // имя архива полного обновления
          response:= ReportDataAll(FirmCode, UserCode, str, ThreadData, exevers);
          AddInfoNewVersion(FirmCode, UserCode, exevers, exedate, response, ThreadData); // сообщение о новой версии
          AddOtherResp(response); // отправляем дополнительные ответы
          flResult:= ResponseToClient(cGetDataAll, response, ThreadData, str); // отправляем полное обновление
        end;

      end else if list.Strings[i]=cLoadOrgNum then begin // загрузить оригинальные номера
        Inc(i);
        str:= 'on'+fnGenRandString(4); // имя файла архива оригинальных номеров без расширения
        response:= ReportLoadOrgNum(FirmCode, UserCode, str, ThreadData, onzipSize);
        flResult:= ResponseToClient(cLoadOrgNum, response, ThreadData, str); // отправляем ответ

      end else if list.Strings[i]=cGetCheckDt then begin //===== сверка по датам
        Inc(i);
        BegDat:= '';
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pBEGDAT then // диапазон дат
            BegDat:= ExtractParametr(list.Strings[i])
          else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        if (BegDat<>'') then begin
          str:= ''; // имя архива
          response:= ReportCheck(FirmCode, UserCode, BegDat, str, ThreadData);
          flResult:= ResponseToClient(cGetCheckDt, response, ThreadData, str); // отправляем ответ - response
        end;

      end else if list.Strings[i]=cSendMesMan then begin // отправить менеджеру письмо
        Inc(i);
        response.Clear;
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pINFORM then // строка письма
            response.Add(ExtractParametr(list.Strings[i]))
          else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        response:= ReportMesMan(FirmCode, UserCode, response, ThreadData);
        flResult:= ResponseToClient(cSendMesMan, response, ThreadData); // отправляем ответ - response

      end else if list.Strings[i]=cGetNewVers then begin //===== загрузить новую версию
        Inc(i);
        str:= '';
        response:= ReportGetNewVers(FirmCode, UserCode, exevers, exedate, str, ThreadData);
        flResult:= ResponseToClient(cGetNewVers, response, ThreadData, str); // отправляем ответ - response

      end else if list.Strings[i]=cReLoadVers then begin // отчет о загрузке новой версии
        Inc(i);
        response.Clear;
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pINFORM then // строка отчета
            response.Add(ExtractParametr(list.Strings[i]))
          else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        flResult:= ReportReLoadVers(FirmCode, UserCode, response, ThreadData);

      end else if list.Strings[i]=cSendWrongM then begin // отчет о письме об ошибке
        Inc(i);
        response.Clear;
        while i<list.Count do begin
          str:= list.Strings[i];
          if copy(str, 1, 7)=pNOMSTR then begin // вид
            ar:= fnSplitString(ExtractParametr(list.Strings[i])); // параметры ошибки - в массив
          end else if copy(str, 1, 7)=pINFORM then // строка письма
            response.Add(ExtractParametr(list.Strings[i]))
          else Break;
          Inc(i); // переходим на след.("чужую")строку
        end; // while...
        response:= ReportWrongMes(FirmCode, UserCode, ar, response, ThreadData);
        flResult:= ResponseToClient(cSendWrongM, response, ThreadData); // отправляем ответ - response

      end else begin // другие команды
        flResult:= False;
        Inc(i);
        prMessageLOGS(nmProc+': Неизвестная команда: '+list.Strings[i], LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Неизвестная команда', list.Strings[i]);
      end; // другие команды

      if ToLog(1) or ToLog(11) and Assigned(response) and (response.Count>0) then begin
        mess1:= '';
        for j:= 0 to response.Count-1 do mess1:= mess1+fnIfStr(mess1='', '', #13#10)+response.Strings[j]; // для отладки
//        if ToLog(1) then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
        if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, 'запрос', mess1);
      end;
    end; // while

  except
    on E: Exception do if (E.Message<>'') then begin
      flResult:= False;
      prMessageLOGS(nmProc+': Ошибка обработки запроса: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка обработки запроса', E.Message);
    end;
  end;
  if (Result=fprSuccess) and not flResult then Result:= fprError;
  if (exevers<>'') then
    prSetThLogParams(ThreadData, 0, 0, 0, 'версия клиента: '+exevers+' '+exedate); // добавляем в LOG версию клиента
  setLength(ar, 0);
  setLength(arZaks, 0);
  setLength(Wlines, 0);
  prFree(response);
  prFree(wlst);
end;
//============================================================== отправка ответа
function ResponseToClient(com: String; response: TStringList; ThreadData: TThreadData; nfzip: string=''): Boolean;
var file_name, s, mess: String;
    i: Integer;
    Body: TStringList;
begin
  Result:= (MailParam.ToAdres<>'');
  Body:= nil;
  try
    if not Result then raise Exception.Create(MessText(mtkNotValidParam)+' для отправки');
    file_name:= DirFileErr+'re'+IntToStr(DateTimeToFileDate(Now))+com+'.'+FileInd; // формируем имя файла для отправки ответа
    Result:= fnSaveEncoded(file_name, response); // кодируем ответ в файл
    if not Result then raise Exception.Create('Ответ не удалось записать в файл для отправки');
    if nfzip='' then s:= file_name else s:= file_name+';'+nfzip; // если есть доп.файл (zip)
    for i:= 1 to RepeatCount do begin // RepeatCount попыток
      try
        Result:= MailSendid(s, com);  // отправка ответа по эл/почте
        if not Result then begin
          mess:= 'Ошибка MailSendid: '+MessageTxt;
          prMessageLOGS('ResponseToClient: '+mess, LogMail, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', '', mess);
        end;
      except
        on E: Exception do begin
          Result:= False;
          prMessageLOGS('ResponseToClient: Ошибка '+IntToStr(i)+'-й попытки отправки ответа: '+E.Message, LogMail, False);
          fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', 'Ошибка '+IntToStr(i)+'-й попытки отправки ответа', E.Message);
        end;
      end;
      Application.ProcessMessages;
      if (length(MessageTxt)>0) and (MessageTxt<>'Сообщение отправлено!') then begin
        if ToLog(6) then prMessageLOGS('ResponseToClient: '+MessageTxt, LogMail, false);
        if ToLog(16) then fnWriteToLogPlus(ThreadData, lgmsInfo, 'ResponseToClient', 'Отправляем ответ', MessageTxt);
      end;
      if Result then Break else if (i<RepeatCount) then sleep(RepeatSaveInterval); // если отправили - выходим, если сбой - пробуем повторить
    end; // for
    if Result then begin
      if ToLog(2) then prMessageLOGS('ResponseToClient: Отправлен ответ на запрос: '+com, LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, 'Отправлен ответ'); // добавляем в LOG сообщение
    end else begin
      Body:= TStringList.Create;
      Body.Add(GetMessageFromSelf);
      Body.Add('Error send response '+com+' file '+file_name); // отправить сообщение админу пр-мы Vlad
      s:= fnGetSysAdresVlad(caeOnlyDayLess);
      s:= n_SysMailSend(s, 'Error send response', Body, nil, '', '', true);
      if (s<>'') then begin
        prMessageLOGS('ResponseToClient: Ошибка отправки письма об Ошибке отправки ответа: '+s, LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', 'Ошибка отправки письма об Ошибке отправки ответа', s);
      end;
    end;
  except
    on E: Exception do begin
      prMessageLOGS('ResponseToClient: Ошибка отправки ответа: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'ResponseToClient', 'Ошибка отправки ответа', E.Message);
    end;
  end;
  prFree(Body);
  if FileExists(file_name) then DeleteFile(file_name);
  if FileExists(nfzip) then DeleteFile(nfzip);
  Application.ProcessMessages;
  sleep(RepeatSaveInterval); // ждем немного, чтобы другой поток мог перехватить отправку
end;
//======================================================= проверить пользователя
function AutorizeUser(UserLog, UserPW: String; var FirmCode, FirmPrefix, UserCode: String; ThreadData: TThreadData): Boolean;
// возвращает True, если нашли пользователя, если нет - в UserCode сообщение, 
// FirmPrefix='-1' - передать список  users, '-2' - передать ссылку для смены пароля
const nmProc = 'AutorizeUser'; // имя процедуры/функции
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
  err:= 'Ошибка SQL';
  ibs:= nil;
//  ibd:= nil;
//  iBlock:= 0;
//  LastAct:= Now;
  with Cache do try
    ibd:= cntsORD.GetFreeCnt;              // ищем пользователя
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
      ibS.SQL.Text:= 'Select * from AutenticateUserCSS(:LOGIN, :PASSW, :Ses, 0, '+IntToStr(cosByVlad)+')';
      ibS.ParamByName('LOGIN').AsString:= UserLog;
      ibS.ParamByName('PASSW').AsString:= UserPW;
      ibS.ParamByName('Ses').AsString:= '';
      ibS.ExecQuery;
      if (ibs.Bof and ibs.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      if ibS.FieldByName('rErrText').AsString<>'' then begin
        err:= ibS.FieldByName('rErrText').AsString; // сообщение для клиента
        raise Exception.Create(err+' в  WEBORDERCLIENTS'); // сообщение в лог
      end;
      UserID      := ibS.FieldByName('rWOCLCODE').AsInteger;
      UserCode    := ibs.fieldByName('rWOCLCODE').AsString; // Создатель: код пользователя
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
      raise Exception.Create(err+' в кэше WOCLCODE='+UserCode);

    end else with arClientInfo[UserID] do begin
      if Arhived then begin // клиент заблокирован в Grossbee
        err:= MessText(mtkNotLoginProcess, UserLog);
        FirmPrefix:= '-10'; //
        raise Exception.Create(err);
      end;
      LastAct:= Now;
      err:= CheckBlocked(True, True, cosByVlad); // проверка блокировки
      if Blocked then begin
        FirmPrefix:= '-10'; //
        raise Exception.Create(err);
      end;
    end;

    FirmID:= arClientInfo[UserID].FirmID;      // код фирмы
    FirmCode:= IntToStr(FirmID);
    if not FirmExist(FirmID) then begin
      err:= 'Не найдена фирма пользователя '+UserLog;
      raise Exception.Create(err+' в кэше WOFRCODE='+FirmCode);
    end else with arFirmInfo[FirmID] do if Arhived or Blocked then begin // фирма заблокирована
      err:= MessText(mtkNotFirmProcess, Name);
      FirmPrefix:= '-10'; //
      raise Exception.Create(err);
    end else if UserPW<>Password then begin // проверка пароля
      err:= 'Неверный пароль пользователя '+UserLog;
      FirmPrefix:= '-1'; // передать список  users
      raise Exception.Create(err+' UserPW='+UserPW);
    end else if RESETPASWORD then begin // временный пароль
      err:= 'Временный пароль пользователя '+UserLog;
      FirmPrefix:= '-2'; // передать ссылку для смены пароля
      raise Exception.Create(err);
    end else FirmPrefix:= arFirmInfo[FirmID].NUMPREFIX; // префикс фирмы клиента
    Result:= True;
  except
    on E: Exception do begin
      UserCode:= err;
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка авторизации', E.Message);
    end;
  end;
end;
//========================================= определяем номер заказа клиента Vlad
function NomZakVlad(NomZak: String): String;
var i: Integer;
begin
  Result:= NomZak;
  i:= pos('V', NomZak);
  if i>0 then Result:= copy(NomZak, i+2, length(NomZak)); // номер заказа клиента Vlad
end;
//==================================================== проверка даты vladdbf.zip
procedure TestVladDbf(var nf: String; ThreadData: TThreadData; exevers: String='');
const nmProc = 'TestVladDbf'; // имя процедуры/функции
var str, ss: string;
    Body: TStringList;
    FileDateTime: TDateTime;
begin
  if not fnGetActionTimeEnable(caeOnlyDay) or (IncHour(MSParams.TimeTestOldFile, 3)>Now) then Exit; // проверяем через 3 часа днем
  Body:= nil;
  MSParams.TimeTestOldFile:= Now;
  try
    str:= '';
    if not FileExists(nf) then begin
      str:= 'file '+nf+' not exist'; // если файла нет
      ss:= 'Файл не найден: '+nf;
    end else if not TestFileActual(nf, -10800, False) // если файл "старше" 3 час.
      and FileAge(nf, FileDateTime) then begin
      str:= 'file '+nf+' - '+FormatDateTime(cDateTimeFormatY4S, FileDateTime);
//      str:= 'file '+nf+' - '+FormatDateTime(cDateTimeFormatY4S, FileDateToDateTime(FileAge(nf)));
      ss:= 'Файл устарел: '+nf;
    end;
    if str<>'' then begin
      if ToLog(2) then begin
        prMessageLOGS(strDelim2_45, LogMail, false);
        prMessageLOGS(nmProc+': '+str, LogMail, false);
        prMessageLOGS(strDelim2_45, LogMail, false);
      end;
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, ss); // добавляем в LOG сообщение
      Body:= TStringList.Create; // отправить сообщение админу пр-мы Vlad
      Body.Add(GetMessageFromSelf);
      Body.Add(str);
      str:= fnGetSysAdresVlad(caeOnlyDayLess);
      str:= n_SysMailSend(str, 'old '+ExtractFileName(nf), Body, nil, '', '', true);
      if (str<>'') then begin
        prMessageLOGS(nmProc+': Ошибка отправки письма: '+ss+#13#10+str, LogMail, false);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка отправки письма', str);
      end;
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка', E.Message);
    end;
  end;
  prFree(Body);
end;
//====================================== проверяет текущую версию программы Влад
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
  lastvers:= ''; // параметры самой новой версии
  lastdate:= '';
  nfzip:= '';
  try
    path:= Cache.VladZipPath; // путь к файлам обновления версии
    if FindFirst(fnTestDirEnd(path)+vlexezipshablon, faAnyFile, sr)=0 then try
      repeat                                      // ищем файлы архивов версий
        v:= '';
        d:= '';
        tmp:= '';
        if TestVladVersFromZip(path, fnTestDirEnd(path)+sr.Name, 'vlad.exe', tmp, v, d, true) and
          VersFirstMoreSecond(v, d, lastvers, lastdate) then begin
          lastvers:= v;               // ищем самую новую версию
          lastdate:= d;
          nfzip:= sr.Name;
        end;
      until SysUtils.FindNext(sr)<>0;
    finally
      SysUtils.FindClose(sr);
    end;
    if (lastvers<>'') then begin // если нашли файл обновления - сверяем с текущей версией
      s:= pIniFile.ReadString('mail', 'vladversion', ''); // параметры текущей версии программы Влад
      if s<>'' then ar:= fnSplitString(s); // параметры текущей версии - в массив
      if length(ar)<3 then setLength(ar, 3);
      if VersFirstMoreSecond(lastvers, lastdate, ar[0], ar[1]) then begin // если найденная версия больше текущей
        s:= lastvers+fnIfStr(lastdate<>'', ';'+lastdate, '')+fnIfStr(nfzip<>'', ';'+nfzip, '');
        pIniFile.WriteString('mail', 'vladversion', s);
        if ToLog(2) then prMessageLOGS('TestCurrentVersVlad: Изменилась текущая версия Влад: '+s, LogMail, false);
        if ToLog(12) then fnWriteToLogPlus(ThreadData, lgmsInfo, 'TestCurrentVersVlad', 'Изменилась текущая версия Влад', s);
        Body.Add('Change Current VersVlad: '+s);
        s:= fnGetSysAdresVlad(caeOnlyWorkDay);
        Body.Insert(0, GetMessageFromSelf);
        s:= n_SysMailSend(s, 'Change VersVlad', Body, nil, '', '', true);
        if s<>'' then begin
          prMessageLOGS('TestCurrentVersVlad: Ошибка отправки письма об изменении текущей версии Влад: '#13#10+s, LogMail, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestCurrentVersVlad', 'Ошибка отправки письма об изменении текущей версии Влад', s);
        end;
      end;
    end;
  except
    on E: Exception do begin
      prMessageLOGS('TestCurrentVersVlad: '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, 'TestCurrentVersVlad', 'Ошибка', E.Message);
    end;
  end;
  prFree(Body);
  prFree(pIniFile);
  setLength(ar, 0);
end;
//===================================================== сообщение о новой версии
procedure AddInfoNewVersion(FirmCode, UserCode, exevers, exedate: String; list: TStringList; ThreadData: TThreadData);
// exevers - версия программы клиента, exedate - дата программы клиента
var s, str: string;
    ar: Tas;
begin
  setLength(ar, 0);
  try
    TestCurrentVersVlad(ThreadData);                         // проверяем текущую версию программы Влад
    str:= GetIniParam(nmIniFileBOB, 'mail', 'vladversion'); // параметры текущей версии программы Влад
    if str=''       then Exit else ar:= fnSplitString(str); // параметры текущей версии - в массив
    if length(ar)<1 then Exit else list.Add(pCOMMNT+str); // с версии 5.0.9 записываем в ответ параметры текущей версии Влад
    If length(ar)>1 then s:= ar[1] else s:= '';

    if not VersFirstMoreSecond(ar[0], s, exevers, exedate) then Exit; // версия клиента актуальна

    list.Add(pINFORM+strDelim2_45);
    list.Add(pINFORM+' на сайте версия программы  '+ar[0]+' от '+s);
//      list.Add(pINFORM+' новые функции - ссылка "Что нового?"');
    if not ((exevers<>'') and VersFirstMoreSecond(exevers, '', VladVersion513, ''))
      and VersFirstMoreSecond(ar[0], '', VladVersion513, '') then begin // когда запустим 5.2.0
      list.Add(pINFORM+strDelim1_45);
      list.Add(pINFORM+'   НОВЫЕ ФУНКЦИИ: поиск товаров и вывод');
      list.Add(pINFORM+'     аналогов по оригинальным номерам');
      list.Add(pINFORM+'   (после обновления баз из новой версии)');
    end;
    list.Add(pINFORM+strDelim1_45);

    If(length(ar)>2) then str:= ar[2] else str:= 'vl'+fnDelSpcAndSumb(ar[0])+'exe.zip';
    list.Add(pINFORM+'    если версия не обновилась по запросу:'); // с версии 5.0.9 работает
    list.Add(pINFORM+' в папке Vlad\IN должен быть архив '+str);   // обновление программы по запросу
    list.Add(pINFORM+'           (если нет - скачайте с сайта)');
    list.Add(pINFORM+'         распакуйте архив '+str);
    list.Add(pINFORM+'     и замените файлы в папке Vlad\EXE');
    list.Add(pINFORM+strDelim2_45);

    if ToLog(2) then prMessageLOGS('AddInfoNewVersion: отправляем сообщение о версии '+ar[0], LogMail, false);
    if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, 'Отправлено сообщение о версии '+ar[0]); // добавляем в LOG сообщение
  finally
    setLength(ar, 0);
  end;
end;
//==================================== проверяем структуру колонок по заголовкам
function TestVladTitles(FirmCode, UserCode, cities: string; ThreadData: TThreadData): Boolean; // True - совпадение структуры
const nmProc = 'TestVladTitles'; // имя процедуры/функции
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
    ColNames:= fnSplit(',', cities); // список заголовков складов от клиента
    with arFirmInfo[FirmID].GetContract(contID) do for i:= Low(ContStorages) to High(ContStorages) do begin
      if ColNames.Count<1 then Exit; // если добавился видимый склад
      j:= ContStorages[i].DprtID;
      s:= GetDprtColName(j);
      j:= ColNames.IndexOf(s);
      if j<0 then Exit; // если добавился видимый склад
      ColNames.Delete(j); // проверенный заголовок удаляем
    end;
    Result:= ColNames.Count<1; // False, если убрали видимый склад
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка', E.Message);
    end;
  end;
  prFree(ColNames);
end;

//====== формируем набор строк для передачи данных и товаров закрывающих док-тов
procedure SetAccInvWaresToList(Account, Invoice: array of TDocRec; list: TStringList;
          ThreadData: TThreadData; exevers: String='');
const nmProc = 'SetAccInvWaresToList'; // имя процедуры/функции
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
      str:= ''; // строка данных закрывающих документов
      if Account[ii].Number<>'' then
        try
          str:= Account[ii].Number+';'+                  // № счета в Grossbee
            IntToStr(Account[ii].ID)+';'+                // код счета
            fnDateGetText(Account[ii].Data)+';'+         // дата счета
            fnSetDecSep(FormatFloat('# ##0.00', Account[ii].Summa))+';'+ // сумма счета
            Account[ii].CurrencyName+';'+                // валюта счета
            fnIfStr(Account[ii].Processed, '1', '0')+';';  // признак обработки счета
          if Invoice[ii].Number<>'' then begin
            str:= str+Invoice[ii].Number+';'+            // № накладной в Grossbee
              IntToStr(Invoice[ii].ID)+';'+              // код накладной
              fnDateGetText(Invoice[ii].Data)+';'+       // дата накладной
              fnSetDecSep(FormatFloat('# ##0.00', Invoice[ii].Summa))+';'+ // сумма накладной
              Invoice[ii].CurrencyName+';';              // валюта накладной
          end;
          if Account[ii].Commentary<>'' then begin            // комментарий для клиента
            s:= StringReplace(Account[ii].Commentary, #13, ' ', [rfReplaceAll]);
            s:= StringReplace(s, #10, ' ', [rfReplaceAll]);
            s:= StringReplace(s, ';', ',', [rfReplaceAll]);
            str:= str+copy(s, 1, cCommentLength)+';';
          end else str:= str+';';
          str:= str+IntToStr(Account[ii].DprtID)+';'+     // склады
                fnIfStr(Invoice[ii].Number<>'', IntToStr(Invoice[ii].DprtID), '0')+';';
        except
          on E: Exception do begin
            err:= err+fnIfStr(err='', '', #13#10)+E.Message;
            str:='';
          end;
        end;
      if str='' then Continue else list.Add(pGBACCN+str);

      if Account[ii].ID>0 then begin
        ibsWa.ParamByName('id').AsInteger:= Account[ii].ID;   // содержимое док-тов
        ibsWa.ExecQuery;
        if (ibsWa.Bof and ibsWa.Eof) then list.Add(pINFORM+'Товары по счету N '+Account[ii].Number+' не найдены')
        else
          while not ibsWa.EOF do begin
            list.Add(pACCWAR+IntToStr(Account[ii].ID)+';'+    // код счета
              ibsWa.fieldByName('PINVLNWARECODE').AsString+';'+ // код товара
                 ibsWa.fieldByName('PINVLNORDER').AsString+';'+ // кол-во в заказе
                 ibsWa.fieldByName('PINVLNCOUNT').AsString+';'+ // кол-во факт.
              fnSetDecSep(FormatFloat('# ##0.00', ibsWa.fieldByName('PINVLNPRICE').AsFloat))); // цена
            ibsWa.Next;
          end;
        ibsWa.Close;
      end; // if Account.ID>0
      if Invoice[ii].ID>0 then begin
        ibsWi.ParamByName('id').AsInteger:= Invoice[ii].ID;
        ibsWi.ExecQuery;
        if (ibsWi.Bof and ibsWi.Eof) then list.Add(pINFORM+'Товары по накл.N '+Invoice[ii].Number+' не найдены')
        else
          while not ibsWi.EOF do begin
            list.Add(pINVWAR+IntToStr(Invoice[ii].ID)+';'+    // код накладной
              ibsWi.fieldByName('INVCLNWARECODE').AsString+';'+   // код товара
                 ibsWi.fieldByName('INVCLNCOUNT').AsString+';'+   // факт.кол-во
             fnSetDecSep(FormatFloat('# ##0.00', ibsWi.fieldByName('INVCLNPRICE').AsFloat))); // цена
            ibsWi.Next;
          end;
        ibsWi.Close;
      end; // if Invoice.ID>0
    end;
  except
    on E: Exception do err:= err+fnIfStr(err='', '', #13#10)+E.Message;
  end;
  if (err<>'') then prMessageLOGS(nmProc+': '+err, LogMail, False);
  if (err<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка', err);
  prFreeIBSQL(ibsWi);
  prFreeIBSQL(ibsWa);
  cntsGRB.SetFreeCnt(ibd);
end;
//====================================== инструкции и сообщения сервера клиентам
procedure AddBOBMessage(FirmCode, UserCode: String; list: TStringList; ThreadData: TThreadData);
begin                                                    ////// заготовка
  list.Add(pINFORM+''); // сообщения
  list.Add(pKTOVAR+''); // имя файла (vlupdzipshablon) архива инструкций сервера для программы Влад
  // если в архиве есть файл инструкции (vlupdexeshablon) - Влад его сразу запустит в папке vlad\in
  if ToLog(2) then prMessageLOGS('AddBOBMessage: отправляем инструкции и сообщения', LogMail, false);
  if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, 'Отправлены инструкции и сообщения'); // добавляем в LOG сообщение
end;
//============================================== получить старый код вида док-та
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

//function fnGetDeliverType(FirmCode, DprtCode, DatabaseName: string): Integer; // проверка - город или меж/город
//=============================================== проверка - город или меж/город ???
{function fnGetDeliverType(FirmCode, DprtCode, DatabaseName: string): Integer;
// возвращает 1, если город фирмы совпадает с городом филиала, 2- не совпадает, 0 - не нашла
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
//======================================= возвращает FIRMSHORTNAME по коду фирмы
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
//========================= проверяет соответствие FIRMSHORTNAME шаблону 99-9999
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

