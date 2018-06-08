unit n_MailReports;
//******************************************************************************
//                   формирование отчетов для программы Влад
//******************************************************************************
interface

uses Windows, Classes, Forms, SysUtils, Math, Controls, DateUtils, 
     DB, IBDatabase, IBSQL, n_free_functions, v_constants, v_DataTrans,
     n_vlad_mail, n_Functions, n_constants, n_MailServis, n_DataCacheInMemory, 
     n_LogThreads, n_DataSetsManager, n_func_ads_loc, n_vlad_common, n_server_common;

 function AddNewZaksOrd(FirmCode, FirmPrefix, UserCode: String; zak: TZakazLine;
          zakln: array of TWareLine; ThreadData: TThreadData; exevers: String=''): TStringList; // записываем в ib_ord новый заказ
 function GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode: String; zaks: array of TZakazLine;
           ThreadData: TThreadData; exevers: String=''): TStringList;      // получаем статусы заказов
 function LoadingZaksOrd(FirmCode, FirmPrefix, UserCode, BegDat: String; zaks: array of TZakazLine;
          ThreadData: TThreadData; exevers: String=''): TStringList;  // загружаем заказы
 function ReportUnpayedDocOrd(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList; // получаем неопл.док-ты, незакр.счета, кред.условия
 function GetDivisible(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;        // загружаем кратность товаров
 function ReportFirmDiscounts(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList; // получаем список скидок фирмы
 function ReportRateCur(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;       // получаем курс у.е.
 function ReportRestAndPrice(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; exevers: String=''): TStringList; // получаем список остатков и цен
 function ReportDataAll(FirmCode, UserCode: String; var nfzip: string; // полное обновление товаров
          ThreadData: TThreadData; exevers: String=''): TStringList;
 function ReportMesMan(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): TStringList; // отправить сообщение менеджеру
 function ReportGetNewVers(FirmCode, UserCode, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList;  // отправить новую версию программы Влад
 function ReportReLoadVers(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): Boolean; // отчет о загрузке новой версии
 function ReportBlockOldVers(zapros, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList; // отправка новой программы при блокировке ответа для старых версий
 function ReportLoadOrgNum(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; onzipSize: Integer=0): TStringList; // получаем список оригинальных номеров и формируем ответ
 function ReportWrongMes(FirmCode, UserCode: String; arpar: Tas; mess: TStringList; ThreadData: TThreadData): TStringList; // письмо об ошибке
 function SetUserParams(aCODE, aLOGIN, aPASSW, aVERSNUM, aVERSDATA: string): string;

implementation
uses n_DataCacheObjects, n_vlad_files_func;
//==============================================================================
//                     письмо об ошибке
//==============================================================================
function ReportWrongMes(FirmCode, UserCode: String; arpar: Tas; mess: TStringList; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportWrongMes'; // имя процедуры/функции
var ms: string;
    UserID, FirmID, MesType, WareId, AnalogId, OrNumId, i, j: Integer;
    Body: TStringList;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cSendWrongM);
//  Body:= nil;
  AnalogId:= -1;
  OrNumId := -1;
  with Cache do try
    if (Length(arpar)<3) then raise Exception.Create(MessText(mtkNotValidParam));
    MesType:= StrTointDef(arpar[0], 0);
    if (MesType<1) then raise Exception.Create(MessText(mtkNotValidParam)+' типа');
    WareId:= StrTointDef(arpar[1], 0);
    if (WareId<1) then raise Exception.Create(MessText(mtkNotValidParam)+' товара');

    case MesType of
      constWrongAnalog: begin // =3; Ошибка указания аналога
          AnalogId:= StrTointDef(arpar[2], 0);
          if (AnalogId<1) then raise Exception.Create(MessText(mtkNotValidParam)+' аналога');
        end;
      constWrongOrNum: begin // =5; Ошибка соответствия оригинального номера
          OrNumId := StrTointDef(arpar[2], 0);
          if (OrNumId<1) then raise Exception.Create(MessText(mtkNotValidParam)+' ориг.номера');
        end;
    end;

    UserID:= StrToIntDef(UserCode, 0);
    if (UserID<1) or not ClientExist(UserId) then
      raise Exception.Create(MessText(mtkNotClientExist, UserCode));

    FirmID:= arClientInfo[UserID].FirmID;
    if not FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists, IntToStr(FirmID)));

    Body:= TStringList.Create;
    try
      j:= mess.IndexOf(cStrWhy); // для новой процедуры отрезаем по строку cStrWhy
      for i:= j+1 to mess.Count-1 do Body.Add(mess[i]);
                                                // отправляем сообщение об ошибке
      ms:= fnSendErrorMes(FirmID, UserID, MesType, WareId, AnalogId, OrNumId, -1, -1, Body.Text, '', ThreadData);

  //------------------------------------------------- формируем ответ пользователю
      Body.Clear;
      Body.Text:= ms;
      Result.Add(pINFORM+strDelim2_45);
      for i:= 0 to Body.Count-1 do Result.Add(pINFORM+Body[i]);
      Result.Add(pINFORM+strDelim2_45);
    finally
      prFree(Body);
    end;
  except
    on E: Exception do begin
      if ms='' then begin
        ms:= MessText(mtkErrSendMess);
        Result.Add(pINFORM+ms);
      end;
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, ms, E.Message, mess.Text);
    end;
  end;
end;
//==============================================================================
//                    отправить сообщение менеджеру
//==============================================================================
function ReportMesMan(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportMesMan'; // имя процедуры/функции
var ma, ms: string;
    UserID, FirmID, i: Integer;
    Strings: TStringList;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cSendMesMan);
//  Strings:= nil;
  try
    UserID:= StrToIntDef(UserCode, 0);
    if (UserID<1) then raise Exception.Create('UserCode='+UserCode);

    FirmID:= StrToIntDef(FirmCode, 0);

    if fnSendClientMes(FirmID, UserID, cosByVlad, Mess.Text, ThreadData, ms) then begin
      ma:= 'Сообщение передано';
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, ma);
      if ToLog(2) then prMessageLOGS(nmProc+': '+ma, LogMail, false);
      if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, ms); // добавляем в LOG сообщение
      if ToLog(1) then prMessageLOGS(nmProc+': '+ms, LogMail, false);
    end else begin
      if ms='' then raise Exception.Create('');
      prMessageLOGS(nmProc+': '+ms, LogMail, false);
    end;

    Strings:= TStringList.Create;
    try
      Strings.Text:= ms;
      if Strings.Count>0 then begin
        Result.Add(pINFORM+strDelim2_45);
        for i:= 0 to Strings.Count-1 do Result.Add(pINFORM+Strings[i]);
        Result.Add(pINFORM+strDelim2_45);
      end;
    finally
      prFree(Strings);
    end;
  except
    on E: Exception do begin
      if ms='' then Result.Add(pINFORM+MessText(mtkErrSendMess));
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
    end;
  end;
end;
//==============================================================================
//                        новая версия программы
//==============================================================================
function ReportGetNewVers(FirmCode, UserCode, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList;
var currvers, nf, nfmail, vd, vn, s, err: String;
    ar: Tas;
begin
  Result:= TStringList.Create;
  err:= 'Ошибка передачи новой версии программы.';
  Result.Add('response:'+cGetNewVers);
  TestCurrentVersVlad(ThreadData); // проверяем текущую версию программы Влад
  currvers:= GetIniParam(nmIniFileBOB, 'mail', 'vladversion');
  setLength(ar, 0);
  ar:= fnSplitString(currvers); // параметры текущей версии программы Влад - в массив
  try
    vn:= ar[0]; // ar[0] - № версии
    If length(ar)>1 then vd:= ar[1] else vd:= ''; // ar[1] - дата версии
    s:= '';
    if (length(ar)>0) then begin
      Result.Add(pCOMMNT+currvers); // записываем в ответ параметры текущей версии Влад
      if not VersFirstMoreSecond(vn, vd, exevers, exedate) then begin
        Result.Add(pINFORM+'У Вас актуальная версия программы.');
        nfzip:= '';
        Exit;
      end;
    end else begin
      Result.Add(pINFORM+err);
      nfzip:= '';
      Exit;
    end;

    try
      s:= 'tmp'+fnGenRandString(4); // имя врем.папки
      If length(ar)>2 then nfzip:= ar[2] else nfzip:= nfzipvlexe; // ar[2] - имя zip-файла версии
      nf:= Cache.VladZipPath+nfzip;
      if not FileExists(nf) then raise Exception.Create(MessText(mtkNotFoundFile)+nf);
      if not TestVladVersFromZip(DirFileErr, nf, 'vlad.exe', s, vn, vd, True) then
        raise Exception.Create('Несоответствие версии в файле '+nf+': '+s); // проверяем версию файла в архиве
      nfmail:= DirFileErr+nfzip;
      if FileExists(nfmail) then DeleteFile(nfmail);
      CopyFile(PChar(nf), PChar(nfmail), false); // копируем zip в папку почты
      if not FileExists(nfmail) then raise Exception.Create(MessText(mtkErrCopyFile)+nfmail);
      Result.Add(pKTOVAR+nfzip); // записываем в ответ имя файла архива обновления
      nfzip:= nfmail;            // полное имя файла архива для отправки
    except
      on E: Exception do begin
        prMessageLOGS('ReportGetNewVers: '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, 'ReportGetNewVers', err, E.Message);
        Result.Add(pINFORM+err);
        if FileExists(nfmail) then DeleteFile(nfmail);
        nfzip:= '';
      end;
    end;
  finally
    setLength(ar, 0);
  end;
end;
//============= отправка новой программы при блокировке ответа для старых версий
function ReportBlockOldVers(zapros, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportBlockOldVers'; // имя процедуры/функции
var currvers, nfmail, vd, vn, s, err, nfm: String;
    ar: Tas;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetRateCur); // записываем в ответ сообщение
  Result.Add(pINFORM+strDelim2_45);
  Result.Add(pINFORM+'   ОБРАБОТКА ЗАПРОСОВ ОТ СТАРЫХ ВЕРСИЙ');
  Result.Add(pINFORM+'         З  А  Б  Л  О  К  И  Р  О  В  А  Н  А !');
  Result.Add(pINFORM+strDelim2_45);

  TestCurrentVersVlad(ThreadData); // проверяем текущую версию программы Влад
  currvers:= GetIniParam(nmIniFileBOB, 'mail', 'vladversion');
  setLength(ar, 0);
  ar:= fnSplitString(currvers); // параметры текущей версии программы Влад - в массив
  try
    vn:= ar[0]; // ar[0] - № версии
    If length(ar)>1 then vd:= ar[1] else vd:= ''; // ar[1] - дата версии
    try
      s:= 'tmp'+fnGenRandString(4); // имя врем.папки
      If length(ar)>2 then nfzip:= ar[2] else nfzip:= nfzipvlexe; // ar[2] - имя zip-файла версии
      nfm:= nfzip;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, err, E.Message);
        if FileExists(nfmail) then DeleteFile(nfmail);
        nfzip:= '';
      end;
    end;
    Result.Add(pINFORM+'      скачайте с сайта архив '+nfm);
    Result.Add(pINFORM+'         распакуйте и замените файлы');
    Result.Add(pINFORM+'               в папке vlad\EXE');
    Result.Add(pINFORM+strDelim2_45);
  finally
    setLength(ar, 0);
  end;
  if ToLog(2) then prMessageLOGS(nmProc+': отправляем сообщение о блокировке старых версий', LogMail, false);
  if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, 'Отправлено сообщение о блокировке старых версий'); // добавляем в LOG сообщение
end;
//==============================================================================
//                             обновление товаров
//==============================================================================
//================================== полное обновление товаров - формируем ответ
function ReportDataAll(FirmCode, UserCode: String; var nfzip: string;
         ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'ReportDataAll'; // имя процедуры/функции
var nf, nfmail, str, dir, tmpdir, sFiles: string;
    i, contID: integer;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetDataAll);
  dir:= '';
  str:= '';
  contID:= 0;
  with Cache do try
    i:= StrToIntDef(FirmCode, 0); // фасуем AUTO / MOTO
    if FirmExist(i) then str:= GetSysTypeSuffix(arFirmInfo[i].GetContract(contID).SysID);

    nf:= VladZipPath+nfzip+str+'.zip';
    if not FileExists(nf) then raise Exception.Create(MessText(mtkNotFoundFile)+nf);
//    TestVladDbf(nf, ThreadData, exevers); // проверка даты vladdbf.zip

    if not TestBaseRestAndPrice(ThreadData) then begin // обновляем цены и остатки в base.dbf
      dir:= 'взяли файл обновления';
      if ToLog(2) then prMessageLOGS(nmProc+': '+dir, LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, dir); // добавляем в LOG сообщение
    end;

    tmpdir:= 'rr'+fnGenRandString(4); // имя для папки
    dir:= fnCreateTmpDir(DirFileErr, tmpdir); // создание временной папки
    tmpdir:= fnTestDirEnd(dir); // имя временной папки с конечным слэшем
    try
      CScache.Enter;
      CopyFile(PChar(nf), PChar(tmpdir+nfzip+'.zip'), false); // копируем zip в врем.папку
    finally
      CSCache.Leave;
    end;
    nf:= tmpdir+nfzip+'.zip'; // теперь работаем с копией архива обновления
    if not FileExists(nf) then raise Exception.Create(MessText(mtkErrCopyFile)+nf);

    sFiles:= '';
    str:= ZipExtractFiles(nf, sFiles, dir); // распаковываем файлы из zip
    if str<>'' then raise Exception.Create(str);

    if not FirmBaseRestCols(FirmCode, baseFname, tmpdir, exevers, ThreadData) then // готовим файлы клиента
      raise Exception.Create('Ошибка изменения структуры файла');

    DeleteFile(nf); // удаляем старый zip
    str:= ZipAddFiles(nf, sFiles); // пакуем файлы клиента

    if str<>'' then raise Exception.Create(str);
    Application.ProcessMessages;

    nfmail:= DirFileErr+nfzip+'.zip';
    if FileExists(nfmail) then DeleteFile(nfmail);
    RenameFile(nf, nfmail);
    if not FileExists(nfmail) then raise Exception.Create(MessText(mtkErrCopyFile)+nfmail);
    Result.Add(pKTOVAR+nfzip+'.zip'); // записываем в ответ имя файла архива обновления
    nfzip:= nfmail;                   // полное имя файла архива для отправки
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      nf:= 'Ошибка обновления баз';
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, nf, E.Message);
      Result.Add(pINFORM+nf);
      if FileExists(nfmail) then DeleteFile(nfmail);
      nfzip:= '';
    end;
  end;
  if not fnDeleteTmpDir(dir) then begin // чистим за собой
    nf:= 'Ошибка очистки врем.папки';
    prMessageLOGS(nmProc+': '+nf+' '+dir, LogMail, False);
    fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, nf, dir);
  end;
end;
//============================= получаем список остатков и цен и формируем ответ
function ReportRestAndPrice(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'ReportRestAndPrice'; // имя процедуры/функции
      errmess = 'Ошибка записи остатков и цен';
var str, nftmpRest: string;
    i, contID: Integer;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetReAndPr);
  DeleteFile(DirFileErr+nfzip+'.zip');
  DeleteFile(DirFileErr+nfzip+'.dbf'); // на всяк.случай
  contID:= 0;
  with Cache do try
    str:= '.dbf';
    i:= StrToIntDef(FirmCode, 0); // фасуем AUTO / MOTO
    if FirmExist(i) then str:= GetSysTypeSuffix(arFirmInfo[i].GetContract(contID).SysID)+str;
    nftmpRest:= restFname+str;

    if not TestRestAndPrice(ThreadData) then begin // обновляем / формируем файл остатков и цен
      if ToLog(2) then prMessageLOGS(nmProc+': взяли файл остатков', LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, 'взяли файл остатков'); // добавляем в LOG сообщение
    end; 

    try
      CScache.Enter;
      CopyFile(PChar(DirFileErr+nftmpRest), PChar(DirFileErr+nfzip+'.dbf'), false); // копируем файл остатков
    finally
      CSCache.Leave;
    end;
    if not FileExists(DirFileErr+nfzip+'.dbf') then // проверяем копию
      raise Exception.Create('Нет копии файла остатков');

    if not FirmRestAndPrice(FirmCode, nfzip, '', ThreadData) then // готовим таблицу остатков клиента 
      raise Exception.Create('Ошибка изменения структуры файла остатков');

    if not RenameFile(DirFileErr+nfzip+'0.dbf', DirFileErr+nColRests) then
      raise Exception.Create('Ошибка переименования файла колонок');

    str:= ZipAddFiles(DirFileErr+nfzip+'.zip', DirFileErr+nColRests); // пакуем таблицу колонок клиента
    if (str<>'') then raise Exception.Create(str);
    DeleteFile(DirFileErr+nColRests); // удаляем таблицу колонок клиента
    if str<>'' then raise Exception.Create(str);

    str:= ZipAddFiles(DirFileErr+nfzip+'.zip', DirFileErr+nfzip+'.dbf'); // пакуем таблицу остатков
    Application.ProcessMessages;
    if str<>'' then raise Exception.Create(str);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errmess, E.Message);
      Result.Add(pINFORM+errmess);
      DeleteFile(DirFileErr+nfzip+'.zip'); // удаляем файл архива, если он уже есть
      nfzip:= '';
    end;
  end;
  if nfzip='' then Exit;
  Result.Add(pKTOVAR+nfzip+'.zip'); // записываем в ответ имя файла архива остатков
  DeleteFile(DirFileErr+nfzip+'.dbf'); // удаляем таблицу остатков
  nfzip:= DirFileErr+nfzip+'.zip'; // полное имя файла архива для отправки
end;
//======================= получаем список оригинальных номеров и формируем ответ
function ReportLoadOrgNum(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; onzipSize: Integer=0): TStringList;
const nmProc = 'ReportLoadOrgNum'; // имя процедуры/функции
var nfon, nfziptmp, errmess, s: String;
    i, contID: integer;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cLoadOrgNum);
  nfziptmp:= DirFileErr+nfzip+'.zip';
  DeleteFile(nfziptmp); // на всяк.случай
  errmess:= 'Ошибка записи оригинальных номеров';
  contID:= 0;
  with Cache do try
    i:= StrToIntDef(FirmCode, 0);
    s:= '';
    if FirmExist(i) then //  фасуем AUTO / MOTO
      if not arFirmInfo[i].CheckSysType(constIsAUTO) then begin // пока ор.ном. только AUTO
        Result.Add(pERRCOD+'По бизнес-направлению '+arFirmInfo[i].GetContract(contID).SysName);
        Result.Add(pERRCOD+'нет базы оригинальных номеров');
        errmess:= '';
        raise Exception.Create('');
      end;

    nfon:= VladZipPath+nfziporgnum+s+'.zip';
    if not FileExists(nfon) then // проверяем файл архива оригинальных номеров
      raise Exception.Create(MessText(mtkNotFoundFile)+nfziporgnum+'.zip');

    if onzipSize>0 then begin // проверяем размер zip ор.н. клиента
      i:= GetFileSize(nfon);
      if abs(i-onzipSize)<5 then begin // если размер zip не изменился
        errmess:= 'У Вас актуальная база оригинальных номеров';
        raise Exception.Create('');
      end;
    end;
    try
      CScache.Enter;
      CopyFile(PChar(nfon), PChar(nfziptmp), false); // копируем
    finally
      CSCache.Leave;
    end;
    Application.ProcessMessages;
  except
    on E: Exception do begin
      if E.Message<>'' then begin
        prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errmess, E.Message);
      end;
      if errmess<>'' then Result.Add(pINFORM+errmess);
      DeleteFile(nfziptmp); // удаляем файл архива, если он уже есть
      nfzip:= '';
    end;
  end;
  if nfzip<>'' then begin
    Result.Add(pKTOVAR+nfzip+'.zip'); // записываем в ответ имя файла архива оригинальных номеров
    nfzip:= nfziptmp; // полное имя файла архива для отправки
  end;
end;
//==============================================================================
//                     получаем курс у.е. и формируем ответ
//==============================================================================
function ReportRateCur(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportRateCur'; // имя процедуры/функции
var rate: String;
    r: Double;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetRateCur);
  rate:= '';
  with Cache do begin
    if DefCurrRate<1 then DefCurrRate:= GetRateCurr;
    r:= DefCurrRate;
  end;
  if r>0 then rate:= fnSetDecSep(FloatToStr(r));
  if rate<>'' then Result.Add(pKTOVAR+rate) else Result.Add(pINFORM+'Ошибка загрузки курса у.е.');
end;
//==============================================================================
//    получаем список скидок фирмы и формируем ответ
//==============================================================================
function ReportFirmDiscounts(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportFirmDiscounts';   // имя процедуры/функции
      errLoad = 'Ошибка загрузки скидок';
var FirmID, i, j, contID: Integer;
    link: TQtyLink;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetFirmDis);
  FirmID:= StrToIntDef(FirmCode, 0);
  j:= 0; // счетчик
  contID:= 0;
  with Cache do try
    if not FirmExist(FirmID) then TestFirms(FirmID, True);
    with arFirmInfo[FirmID].GetContract(contID) do // коды групп и подгрупп со скидками
      for i:= 0 to ContDiscLinks.Count-1 do try
        link:= ContDiscLinks[i];
        Result.Add(pKTOVAR+IntToStr(link.LinkID)+';'+fnSetDecSep(FormatFloat('# ##0.00', link.Qty)));
        inc(j);
      except
        on E: Exception do fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errLoad, E.Message);
      end;
    if j<1 then Result.Add(pINFORM+'Скидки не найдены');
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errLoad, E.Message);
      Result.Add(pINFORM+errLoad);
    end;
  end;
end;
//==============================================================================
//    получаем неопл.док-ты, незакр.счета, кред.условия и формируем ответ
//==============================================================================
function ReportUnpayedDocOrd(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportUnpayedDocOrd'; // имя процедуры/функции
var ibsORD, ibs, ibsW: TIBSQL;
    ibd, ibdOrd: TIBDatabase;
    str, s: String;
    sum: double;
    FirmID, contID: integer;
    dd: TDateTime;
    firma: TFirmInfo;
    Contract: TContract;
begin
  Result:= TStringList.Create;
  ibdOrd:= nil;
  ibsORD:= nil;
  ibd:= nil;
  ibs:= nil;
  ibsW:= nil;
  contID:= 0;
  FirmID:= StrToIntDef(FirmCode, 0);
  Result.Add('response:'+cUnpayedDoc); // получаем список неоплаченных документов и формируем ответ
  with Cache do try
    if FirmID>0 then TestFirms(FirmID, true);
    if (FirmID<1) or not FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists));
    firma:= arFirmInfo[FirmID];
    Contract:= firma.GetContract(contID);

    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID);
    ibsW:= fnCreateNewIBSQL(ibd, 'ibsW_'+nmProc, ThreadData.ID);
    ibd.DefaultTransaction.StartTransaction;
    try
      ibsW.SQL.Text:= 'select INVCLNWARECODE LNWARECODE, '+
        ' INVCLNPRICE LNPRICE, INVCLNCOUNT LNCOUNT'+
        ' from INVOICELINES where INVCLNDOCMCODE=:DOCMCODE';

      ibs.SQL.Text:= 'select rDocmTYPE, rDocmCODE, rDocmDate, rDocmCrnc RCrncCode,'+
        ' rDocmDuty RDutySumm, rDocmDPRT DPRTCODE, rDocmDELAY DELAYCALC,'+
        ' rDocmSUMM LNSUMM, rDocmNUMBER LNNUMBER'+
        ' from Vlad_CSS_GetContractDutyDocms('+FirmCode+ ', '+IntToStr(contID)+
        ', '+Cache.GetConstItem(pcDutyDocsWithPlan).StrValue+')';

      ibsW.Prepare;
      ibs.ExecQuery;
      if (ibs.Bof and ibs.Eof) then Result.Add(pINFORM+'Неоплаченные документы не найдены')
      else while not ibs.EOF do begin
        dd:= ibs.FieldByName('RDOCMDATE').AsDateTime+ibs.FieldByName('DELAYCALC').AsInteger+1;
        str:= ibs.FieldByName('LNNUMBER').AsString+';'+  // № документа
              ibs.FieldByName('RDOCMCODE').AsString+';'+   // код документа
              IntToStr(GetOldDocmType(ibs.FieldByName('RDOCMTYPE').AsInteger, // пока передаем старые коды типов док-тов !!!
              5))+';'+   // код типа документа
//              ibs.FieldByName('DUTYTYPE').AsInteger))+';'+   // код типа документа
              fnDateGetText(ibs.FieldByName('RDOCMDATE').AsDateTime)+';'+ // дата документа
              fnDateGetText(dd)+';';                         // дата оплаты
        sum:= RoundToHalfDown(ibs.FieldByName('LNSUMM').AsFloat);
//        if fnNotZero(sum) and (ibs.FieldByName('DUTYTYPE').AsString<>'5') then sum:= -sum; // 5 - долг, 0 - оплата
        str:= str+fnSetDecSep(FloatToStr(sum))+';'; // сумма документа (кредитовые суммы - отрицательные)
        sum:= RoundToHalfDown(ibs.FieldByName('RDutySumm').AsFloat);
//        if fnNotZero(sum) and (ibs.FieldByName('DUTYTYPE').AsString<>'5') then sum:= -sum;
        str:= str+fnSetDecSep(FloatToStr(sum))+';'+ // неоплаченная сумма (кредитовые суммы - отрицательные)
              GetCurrName(ibs.FieldByName('RCRNCCODE').AsInteger, True)+';'+ // валюта документа
              ibs.FieldByName('DPRTCODE').AsString+';';  // код склада
        Result.Add(pNOMSTR+str); // параметры документа
        ibsW.ParamByName('DOCMCODE').AsInteger:= ibs.FieldByName('RDOCMCODE').AsInteger;
        ibsW.ExecQuery;                           // товары док-та
        while not ibsW.EOF do begin
          if fnNotZero(ibsW.fieldByName('LNPRICE').AsFloat) then
            Result.Add(pKTOVAR+ibsW.fieldByName('LNWARECODE').AsString+';'+ // код товара
              ibsW.fieldByName('LNCOUNT').AsString+';'+ // кол-во
              fnSetDecSep(FormatFloat('# ##0.00', ibsW.fieldByName('LNPRICE').AsFloat))); // цена
          ibsW.Next;
        end;
        ibsW.Close;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
    except
      on E: Exception do begin
        s:= 'ошибка загрузки неоплаченных документов';
        Result.Add(pINFORM+s);
        prMessageLOGS(nmProc+': '+s+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
      end;
    end;

    with Contract do Result.Add(pDEBETS+ // формируем в ответ кредитные условия
      FloatToStr(CredLimit)+';'+                          // Предел кредита
      fnSetDecSep(FloatToStr(DebtSum))+';'+               // задолженность на текущий момент
      fnSetDecSep(FloatToStr(OrderSum))+';'+              // общая сумма зарезервированного товара в валюте кредита
      GetCurrName(CredCurrency, True)+';'+                // краткое наименование валюты кредита
      BoolToStr(SaleBlocked)+';'+IntToStr(CredDelay)+';'+ // признак блокировки, отсрочка
      WarnMessage+';');                                // текст сообщения о нарушении кредитных условий
    ibsW.Close;
    ibs.Close;

    cntsGRB.TestSuspendException;
    Result.Add('response:'+cRepAccList); // получаем список незакрытых счетов и формируем ответ
    try
      ibdOrd:= cntsOrd.GetFreeCnt;
      ibsORD:= fnCreateNewIBSQL(ibdOrd, 'ibsORD_'+nmProc, ThreadData.ID, tpRead, True);
      ibsORD.SQL.Text:= 'select ORDRCODE, ORDRNUM, ORDRDATE, ORDRSOURCE'+
        ' from ORDERSREESTR WHERE ORDRFIRM='+FirmCode+' and ORDRGBACCCODE=:ORDRGBACCCODE';
      ibsORD.Prepare;
      ibsW.SQL.Text:= 'select PINVLNCODE LNCODE, PINVLNWARECODE LNWARECODE, '+
        ' PINVLNPRICE LNPRICE, PINVLNCOUNT LNCOUNT, PINVLNORDER LNORDER '+
        ' from PAYINVOICELINES WHERE PINVLNDOCMCODE=:acCODE';

      ibs.SQL.Text:= 'select rPInvCode acCODE, rPInvNumber acNUMBER,'+
        ' rPInvDate acDATE, rPInvSumm acSUMM, rPROCESSED acPROCESSED,'+
        ' rCLIENTCOMMENT acCLIENTCOMMENT, rPInvCrnc acCRNCCODE, rPInvDprt acDPRTCODE'+
        ' from Vlad_CSS_GetContractReserveDocs('+FirmCode+ ', '+IntToStr(contID)+')'+
        ' ORDER BY rPInvDate, rPInvNumber'; // ??

      ibsW.Prepare;
      ibs.ExecQuery;
      if (ibs.Bof and ibs.Eof) then Result.Add(pINFORM+'Незакрытые счета не найдены')
      else while not ibs.EOF do begin    // параметры счета
        str:= StringReplace(ibs.fieldByName('acCLIENTCOMMENT').AsString, #10, ' ', [rfReplaceAll]);
        str:= StringReplace(str, #13, ' ', [rfReplaceAll]);
        str:= StringReplace(str, ';', ',', [rfReplaceAll]);
        if length(str)>cCommentLength then str:= copy(str, 1, cCommentLength);
        s:= fnIfStr(CurrExists(ibs.FieldByName('acCRNCCODE').AsInteger),
          GetCurrName(ibs.FieldByName('acCRNCCODE').AsInteger, True), '');
        Result.Add(pGBACCN+ibs.FieldByName('acNUMBER').AsString+';'+ // № счета
          ibs.FieldByName('acCODE').AsString+';'+                    // код счета
          fnDateGetText(ibs.FieldByName('acDATE').AsDateTime)+';'+   // дата счета
          fnSetDecSep(FormatFloat('# ##0.00', ibs.FieldByName('acSUMM').AsFloat))+';'+s+';'+ // сумма, валюта счета
          fnIfStr(GetBoolGB(ibs, 'acPROCESSED'), '1', '0')+';'+ // признак обработки счета
          str+';'+ibs.FieldByName('acDPRTCODE').AsString+';'); // комментарий для клиента, код склада

        ibsORD.ParamByName('ORDRGBACCCODE').AsInteger:= ibs.FieldByName('acCODE').AsInteger;
        ibsORD.ExecQuery;               // если счет по заказу
        if not (ibsORD.Bof and ibsORD.Eof) then // код;№;дата заказа
          Result.Add(pNOMSTR+ibsORD.FieldByName('ORDRCODE').AsString+';'+
            fnIfStr(ibsORD.fieldByName('ORDRSOURCE').AsInteger=cosByVlad,    // если заказ из Vlad
            NomZakVlad(ibsORD.fieldByName('ORDRNUM').AsString), // вычисляем номер заказа клиента (Vlad)
            ibsORD.FieldByname('ORDRNUM').AsString)+';'+ibsORD.FieldByname('ORDRDATE').AsString);
        ibsORD.Close;

        ibsW.ParamByName('acCODE').AsInteger:= ibs.FieldByName('acCODE').AsInteger;
        ibsW.ExecQuery;                  // товары счета
        while not ibsW.EOF do begin // код товара;кол-во факт.;кол-во в заказе;цена
          Result.Add(pKTOVAR+ibsW.fieldByName('LNWARECODE').AsString+';'+
            ibsW.fieldByName('LNCOUNT').AsString+';'+ibsW.fieldByName('LNORDER').AsString+';'+
            fnSetDecSep(FormatFloat('# ##0.00', ibsW.fieldByName('LNPRICE').AsFloat)));
          ibsW.Next;
        end;
        ibsW.Close;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
      ibd.DefaultTransaction.Rollback;
    except
      on E: Exception do begin
        s:= 'ошибка загрузки незакрытых счетов';
        Result.Add(pINFORM+s);
        prMessageLOGS(nmProc+': '+s+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
      end;
    end;
  except
    on E: Exception do begin
      s:= 'ошибка загрузки кредитных условий и документов';
      Result.Add(pINFORM+s);
      prMessageLOGS(nmProc+': '+s+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
    end;
  end;
  if ibd.DefaultTransaction.InTransaction then ibd.DefaultTransaction.Rollback;
  prFreeIBSQL(ibs);
  prFreeIBSQL(ibsW);
  cntsGRB.SetFreeCnt(ibd);
  prFreeIBSQL(ibsORD);
  cntsOrd.SetFreeCnt(ibdOrd);
end;
//==============================================================================
//               загружаем кратность товаров и формируем ответ
//==============================================================================
function GetDivisible(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'GetDivisible'; // имя процедуры/функции
var i, j, FirmID: Integer;
    s: String;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetDivisib); // формируем ответ
  FirmID:= StrToIntDef(FirmCode, 0);
  j:= 0; // счетчик
  with Cache do try
    if not FirmExist(FirmID) then TestFirms(FirmID, True);
    for i:= 1 to High(arWareInfo) do
      if WareExist(i) then with GetWare(i) do if not IsArchive and (divis>1) then begin
        if (FirmID>0) and not CheckWareAndFirmEqualSys(i, FirmID) then Continue;
        inc(j);
        Result.Add(pKTOVAR+IntToStr(i)+';'+
          fnSetDecSep(FormatFloat('# ##0.00', divis))+';'+MeasName);
      end;
    if j<1 then begin // если не нашли
      s:= 'данные о кратности товаров не найдены';
      Result.Add(pINFORM+s);
      if ToLog(2) then prMessageLOGS(nmProc+': '+s, LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, s); // добавляем в LOG сообщение
    end;
  except
    on E: Exception do begin
      s:= 'Ошибка загрузки кратности товаров';
      Result.Add(pINFORM+s); // запись сообщений об ошибке
      prMessageLOGS(nmProc+': '+s+', '+E.Message, LogMail, False); // если сбой
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
    end;
  end;
end;
//==============================================================================
//                         загружаем заказы и формируем ответ
//==============================================================================
function LoadingZaksOrd(FirmCode, FirmPrefix, UserCode, BegDat: String;
         zaks: array of TZakazLine; ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'LoadingZaksOrd'; // имя процедуры/функции
var i, kz, st: Integer;
    strw, snom, mess1, mess2, mess3, s: String;
    zak: array of TZakazLine;
    Accounts, Invoices: array of TDocRecArr;
    ibs: TIBSQL;
    ibd: TIBDatabase;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cLoadingZak); // формируем ответ
  ibs:= nil;
  ibd:= nil;
  setLength(zak, 0);
  strw:= ' where (ORDRFIRM='+FirmCode+')'; // условие для SQL по коду фирмы
  if (Length(BegDat)>0) then strw:= strw+' and (ORDRDATE>=:d)'; // условие по начальной дате
  try
    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select ORDRCODE, ORDRNUM, ORDRSOURCE, ORDRDATE, ORDRTOPROCESSDATE, '+
      'ORDRSTATUS, ORDRSUMORDER, ORDRACCOUNTINGTYPE, ORDRCURRENCY, ORDRDELIVERYTYPE, '+
      'ORDRSTORAGECOMMENT, ORDRSTORAGE from ORDERSREESTR'+strw+' order by ORDRCODE';
    if pos(':d', ibs.SQL.Text)>0 then ibs.ParamByName('d').AsDateTime:= fnStrToDateDef(BegDat);
    ibs.ExecQuery;  // выбираем № заказов
    if (ibs.Bof and ibs.Eof) then begin // если не нашли
      Result.Add(pINFORM+'заказы для загрузки не найдены');
      mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'Заказы для загрузки не найдены';
      raise Exception.Create('');
    end;
    kz:= 0;   // кол-во заказов для сверки
    while not ibs.Eof do begin
      snom:= ibs.fieldByName('ORDRNUM').AsString; // полный № заказа
      if ibs.fieldByName('ORDRSOURCE').AsInteger=cosByVlad then    // если заказ из Vlad
        snom:= NomZakVlad(ibs.fieldByName('ORDRNUM').AsString); // вычисляем номер заказа клиента (Vlad)
      i:= FindInMassZak(zaks, snom); // проверяем в массиве переданных № заказов
      if i>-1 then snom:= ''; // если нашли - не загружать
      if (length(snom)>0) and (ibs.fieldByName('ORDRCODE').AsInteger>0) then begin
        i:= length(zak);
        setLength(zak, i+1);
        if ibs.fieldByName('ORDRSOURCE').AsInteger=cosByVlad then zak[i].NomZak:= snom // для заказа из Vlad - № заказа клиента
        else zak[i].NomZak:= '-'+ibs.fieldByName('ORDRSOURCE').AsString; // для заказа с сервера: -источник
        zak[i].nomstr:= ibs.fieldByName('ORDRNUM').AsString; // запоминаем № заказа
        zak[i].KodZak:= ibs.fieldByName('ORDRCODE').AsString; // запоминаем код заказа, дальше работаем с кодом
        zak[i].izak:= ibs.fieldByName('ORDRCODE').AsInteger;
        zak[i].storage:= ibs.fieldByName('ORDRSTORAGE').AsString; // склад
        setLength(Accounts, Length(zak));
        setLength(Invoices, Length(zak));
        zak[i].Status:= ibs.fieldByName('ORDRSTATUS').AsString; // статус заказа
        try
          st:= 0;        // уточняем статус и получаем данные закрывающих документов
          s:= fnGetClosingDocsOrd(zak[i].KodZak, Accounts[i], Invoices[i], st, ThreadData.ID);
          if s<>'' then raise Exception.Create('Ошибка fnGetClosingDocsOrd: '+s);
          if st>0 then zak[i].Status:= IntToStr(st);
          zak[i].Checked:= True;
        except
          on E: Exception do begin
            if StrToIntDef(zak[i].NomZak, 0)>0 then snom:= zak[i].NomZak // если заказ из Vlad
            else snom:= zak[i].nomstr;
            Result.Add(pINFORM+'Ошибка сверки документов по заказу N '+snom);
            mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'Ошибка сверки документов по заказу '+zak[i].nomstr+': '+E.Message;
            zak[i].Checked:= False;
          end;
        end;
        zak[i].Checked:= zak[i].Checked and (StrToIntDef(zak[i].Status, -1) in [orstProcessing..orstClosed]); // статусы для загрузки
        if zak[i].Checked then begin     // признак, что заказ нужно загружать
          zak[i].OplZak:= ibs.fieldByName('ORDRACCOUNTINGTYPE').AsString; // форма оплаты заказа
          zak[i].ValZak:= ibs.fieldByName('ORDRCURRENCY').AsString;       // валюта заказа
          zak[i].DatZak:= fnDateGetText(ibs.fieldByName('ORDRDATE').AsDateTime); // дата заказа
          zak[i].DZakIn:= FormatDateTime(cDateTimeFormatY2N, ibs.fieldByName('ORDRTOPROCESSDATE').AsDateTime); // дата приема заказа
          zak[i].DeliTp:= ibs.fieldByName('ORDRDELIVERYTYPE').AsString;   // тип доставки
          zak[i].SumZak:= fnSetDecSep(FormatFloat('# ##0.00', ibs.fieldByName('ORDRSUMORDER').AsFloat)); // сумма заказа для загрузки
          s:= StringReplace(ibs.fieldByName('ORDRSTORAGECOMMENT').AsString, #13, ' ', [rfReplaceAll]);
          s:= StringReplace(s, #10, ' ', [rfReplaceAll]);
          s:= StringReplace(s, ';', ',', [rfReplaceAll]);
          zak[i].Commnt:= copy(s, 1, 150);   // примечание
          Inc(kz);
        end;
      end;
      ibs.Next;
      cntsORD.TestSuspendException;
    end;
    ibs.Close;

    if (Length(zak)<1) or (kz<1) then begin // если нет заказов для загрузки
      Result.Add(pINFORM+'заказы для загрузки не найдены');
      mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'заказы для загрузки не найдены';
      raise Exception.Create('');
    end;
    ibs.SQL.Text:= 'select ORDRLNWARE, ORDRLNCLIENTQTY, ORDRLNPRICE'+
      ' from ORDERSLINES where ORDRLNORDER=:kod';
    ibs.Prepare;
    for i:= Low(zak) to High(zak) do
      if not zak[i].Checked then Continue else try // если заказ не нужно загружать - пропускаем
        ibs.ParamByName('kod').AsInteger:= zak[i].izak;
        ibs.ExecQuery;  // выбираем строки заказа
        if StrToIntDef(zak[i].NomZak, 0)>0 then snom:= zak[i].NomZak // если заказ из Vlad
        else snom:= zak[i].nomstr;
        if (ibs.Bof and ibs.Eof) then raise Exception.Create('Нет строк'); // если не нашли строки заказа
        if zak[i].DeliTp='0' then zak[i].DeliTp:= '1' else zak[i].DeliTp:= '0'; // приводим в соответствие со счетами
        s:= snom+';'+ //  № заказа клиента (для заказа с сервера: № заказа на сервере)
          zak[i].NomZak+';'+ //  № заказа клиента (для заказа с сервера: -источник)
          zak[i].SumZak+';'+zak[i].OplZak+';'+zak[i].ValZak+';'+ // сумма, форма оплаты, валюта заказа
          zak[i].DeliTp+';'+zak[i].DatZak+';'+zak[i].Status+';'+ // тип доставки, дата, статус
          zak[i].DZakIn+';'+zak[i].Commnt+';'+zak[i].storage+';'; // дата приема заказа, примечание, склад
        Result.Add(pNOMSTR+s);
        while not ibs.Eof do begin  // строки товаров заказа
          Result.Add(pKTOVAR+ibs.fieldByName('ORDRLNWARE').AsString+';'+       // код товара
                             ibs.fieldByName('ORDRLNCLIENTQTY').AsString+';'+  // зак.кол-во
                             ibs.fieldByName('ORDRLNCLIENTQTY').AsString+';'+ // факт.кол-во
               fnSetDecSep(FormatFloat('# ##0.00', ibs.fieldByName('ORDRLNPRICE').AsFloat))); // цена
          ibs.Next;
        end;
        if Length(Accounts[i])>0 then begin // данные закрывающих документов
          SetAccInvWaresToList(Accounts[i], Invoices[i], Result, ThreadData, exevers); // строки данных и товаров закрывающих документов
          Result.Add(pINFORM+'переданы документы к заказу N '+snom);
        end;
        Result.Add(pINFORM+'передан заказ N '+snom);
        mess1:= mess1+fnIfStr(mess1='', '', #13#10)+'передан заказ N '+zak[i].nomstr+'; сумма '+zak[i].SumZak;
        ibs.Close;
        cntsORD.TestSuspendException;
      except
        on E: Exception do begin
          Result.Add(pINFORM+'Ошибка загрузки заказа N: '+snom);
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'Ошибка загрузки заказа: FirmCode: '+FirmCode+
            ', заказ N '+zak[i].nomstr+': '+E.Message;
        end;
      end;
  except
    on E: Exception do
      if (E.Message<>'') then begin
        mess3:= mess3+fnIfStr(mess3='', '', #13#10)+E.Message;
        Result.Add(pINFORM+'Ошибка загрузки заказов');
      end;
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(ibd);
  setLength(zak, 0);
  setLength(Accounts, 0);
  setLength(Invoices, 0);
//  if ToLog(1) and (mess1<>'')  then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
  if ToLog(11) and (mess1<>'') then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, mess1);
  if ToLog(2) and (mess2<>'')  then prMessageLOGS(nmProc+': '+mess2, LogMail, false);
  if ToLog(12) and (mess2<>'') then prSetThLogParams(ThreadData, 0, 0, 0, mess2); // добавляем в LOG сообщение
  if (mess3<>'')  then prMessageLOGS(nmProc+': '+mess3, LogMail, False);
  if (mess3<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', mess3);
end;
//==============================================================================
//                    получаем статусы заказов и формируем ответ
//==============================================================================
function GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode: String; zaks: array of TZakazLine;
         ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'GetStatusZaksOrd'; // имя процедуры/функции
var i, j, kz, st: Integer;
    zak: array of TZakazLine;
    Accounts, Invoices: array of TDocRecArr;
    mess1, mess3, s: String;
    ibs: TIBSQL;
    ibd: TIBDatabase;
begin
  Result:= TStringList.Create;
  mess1:= '';
  mess3:= '';
  Result.Add('response:'+cStatusZaks); // формируем ответ
  ibs:= nil;
  ibd:= nil;
  try
    s:= 'Ошибка запроса статусов заказов: FirmCode: '+FirmCode;
    j:= Length(zaks); // кол-во заказов
    if j<1 then raise Exception.Create(s);
    setLength(zak, j);
    setLength(Accounts, j);
    setLength(Invoices, j);
    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select ORDRCODE, ORDRNUM, ORDRSTATUS, '+
      ' ORDRTOPROCESSDATE, ORDRANNULATEREASON, ORDRSTORAGE'+
      ' from ORDERSREESTR where (ORDRNUM=:p0)';
    ibs.Prepare;
    kz:= 0; // кол-во заказов для сверки документов
    for i:= 0 to j-1 do try  // проверяем номера заказов
      cntsORD.TestSuspendException;

      zak[i].NomZak:= zaks[i].NomZak; // № заказа клиента (для заказа с сервера: <1)
      if StrToIntDef(zaks[i].NomZak, 0)>0 then // если заказ из Vlad, формируем № заказа на сервере
        zak[i].nomstr:= fnGetNumOrder(FirmPrefix, zaks[i].NomZak)
      else zak[i].nomstr:= zaks[i].nomstr;

      with ibs.Transaction do if not InTransaction then StartTransaction;
      ibs.ParamByName('p0').AsString:= zak[i].nomstr;
      ibs.ExecQuery;
      if (ibs.Bof and ibs.Eof) then begin // если не нашли
        zak[i].KodZak:= '0';
        zak[i].izak:= 0;
        mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'FirmCode: '+FirmCode+', '+
          MessText(mtkNotFoundOrder)+' N '+zak[i].nomstr; // № заказа на сервере
        Result.Add(pINFORM+MessText(mtkNotFoundOrder)+' N '+zaks[i].nomstr); // № заказа из запроса
        Result.Add(pNOMSTR+zaks[i].nomstr+';'+IntToStr(orstNoDefinition));

      end else begin
        zak[i].KodZak:= ibs.fieldByName('ORDRCODE').AsString; // коды для синхронизации с Grossbee
        zak[i].izak:= ibs.fieldByName('ORDRCODE').AsInteger;  // и для сверки строк товаров
        zak[i].Status:= ibs.fieldByName('ORDRSTATUS').AsString;         // статус заказа
        zak[i].DZakIn:= FormatDateTime(cDateTimeFormatY2N, ibs.fieldByName('ORDRTOPROCESSDATE').AsDateTime); // дата приема заказа
        zak[i].storage:= ibs.fieldByName('ORDRSTORAGE').AsString;
        if ibs.fieldByName('ORDRSTATUS').AsInteger=orstAnnulated then
          zak[i].Commnt:= ibs.fieldByName('ORDRANNULATEREASON').AsString; // Причина аннуляции
        try
          st:= 0;        // уточняем статус и получаем данные закрывающих документов
          s:= fnGetClosingDocsOrd(zak[i].KodZak, Accounts[i], Invoices[i], st, ThreadData.ID);
          if s<>'' then raise Exception.Create('Ошибка fnGetClosingDocsOrd: '+s);
          if st>0 then zak[i].Status:= IntToStr(st);
        except
          on E: Exception do begin
            Result.Add(pINFORM+'Ошибка сверки документов по заказу N '+zaks[i].nomstr);
            mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'Ошибка сверки документов по заказу '+zak[i].nomstr+': '+E.Message;
          end;
        end;
        mess1:= mess1+fnIfStr(mess1='', '', #13#10)+'FirmCode: '+FirmCode+', передан статус заказа N: '+zak[i].nomstr;
        Result.Add(pINFORM+'передан статус заказа N '+zaks[i].nomstr);
        Result.Add(pNOMSTR+zaks[i].nomstr+';'+zak[i].Status+';'+ // № заказа из запроса;статус заказа;
                           zak[i].DZakIn+';'+zak[i].Commnt+';'+zak[i].storage+';'); // дата приема заказа, Причина аннуляции, склад
        zak[i].Checked:= True; // признак, что по заказу нужно выбрать док-ты
        Inc(kz);
      end;
    finally
      ibs.Close;
    end;

    if kz>0 then begin // выборка документов
      Result.Add('response:'+cFactSumZak);
      for i:= 0 to j-1 do
        if not zak[i].Checked then Continue // если по заказу не нужно выбрать док-ты - пропускаем
        else if Length(Accounts[i])>0 then try // данные закрывающих документов
          Result.Add(pNOMSTR+zaks[i].nomstr+';'+zak[i].NomZak); // № заказа из запроса;№ заказа из запроса - для совместимости с загрузкой заказов
          SetAccInvWaresToList(Accounts[i], Invoices[i], Result, ThreadData, exevers); // строки данных и товаров закрывающих документов
          Result.Add(pINFORM+'переданы документы к заказу N '+zaks[i].nomstr);
        except
          on E: Exception do mess3:= mess3+fnIfStr(mess3='', '', #13#10)+
            'FirmCode: '+FirmCode+', ошибка сверки заказа N: '+zak[i].nomstr; // № заказа на сервере
        end;
    end; // if kz>0
  except
    on E: Exception do begin
      Result.Add(pINFORM+'Ошибка запроса статусов заказов');
      mess3:= mess3+fnIfStr(mess3='', '', #13#10)+E.Message;
    end;
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(ibd);
  setLength(zak, 0);
  setLength(Accounts, 0);
  setLength(Invoices, 0);
//  if ToLog(1) and (mess1<>'') then prMessageLOGS(nmProc+': '+mess1, LogMail, false);
  if ToLog(11) and (mess1<>'') then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, mess1);
  if (mess3<>'') then prMessageLOGS(nmProc+': '+mess3, LogMail, false);
  if (mess3<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', mess3);
end;
//==============================================================================
//                 записываем в БД новый заказ и формируем ответ
//==============================================================================
function AddNewZaksOrd(FirmCode, FirmPrefix, UserCode: String; zak: TZakazLine;
         zakln: array of TWareLine; ThreadData: TThreadData; exevers: String=''): TStringList;
// возвращает True, если все отработало нормально
const nmProc = 'AddNewZaksOrd'; // имя процедуры/функции
var i, kt, j, jj, FirmID, contID: Integer;
    s, sdprt, mess2, mess3, mess5, messzak, s1, s2: String;
    ibs: TIBSQL;
    ibd: TIBDatabase;
    ferr: Boolean;
    ar: Tas;
    wkodes: Tai;
    Stream: TBoBMemoryStream;
    zaks: array of TZakazLine;
    Body: TStringList;
    LocalThreadStart, tdtbegin, dat, datw: TDateTime;
    Ware: TWareInfo;
//-------------------------------------
procedure FreeZakaz(skod: String); // удаляем заголовок заказа
var _ibs: TIBSQL;
    _ibd: TIBDatabase;
begin
  _ibs:= nil;
  _ibd:= nil;
  try
    _ibd:= cntsORD.GetFreeCnt;
    _ibs:= fnCreateNewIBSQL(_ibd, '_ibs_'+nmProc, ThreadData.ID, tpWrite, true);
    _ibs.SQL.Text:= 'delete from ORDERSREESTR where ORDRCODE='+skod;
    _ibs.ExecQuery;
    _ibs.Transaction.Commit;
  except
    on E: Exception do if assigned(_ibs) then begin
      _ibs.Transaction.Rollback;
      mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'текст SQL: '+_ibs.SQL.Text+' - '+E.Message;
    end else mess3:= mess3+fnIfStr(mess3='', '', #13#10)+' - '+E.Message;
  end;
  prFreeIBSQL(_ibs);
  cntsORD.SetFreeCnt(_ibd);
end;
//-------------------------------------
begin
  LocalThreadStart:= now();
  tdtbegin:= LocalThreadStart;
  mess2:= '';
  mess3:= '';
  mess5:= '';
  messzak:= 'Ошибка записи заказа N '+zak.NomZak;
  setLength(ar, 0);
  setLength(wkodes, 0);
  Result:= TStringList.Create;
  Body:= TStringList.Create;
  ibs:= nil;
  ibd:= nil;
  Stream:= nil;
  contID:= 0;
  with Cache do try
    Result.Add('response:'+cAddNewZaks); // формируем ответ
    try
      if length(zakln)<1 then raise Exception.Create(MessText(mtkNotFoundWares));
      FirmID:= StrToInt(FirmCode);
      with arFirmInfo[FirmID].GetContract(contID) do begin
        sdprt:= IntToStr(Filial);
        if (zak.storage='') or (zak.storage='0') then zak.storage:= MainStoreStr;
      end;
      if (StrToIntDef(sdprt, 0)<1) or (StrToIntDef(zak.storage, 0)<1) then
        raise Exception.Create(MessText(mtkNotDprtExists));
      if zak.NomZak='' then raise Exception.Create(MessText(mtkNotValidParam));
      zak.nomstr:= fnGetNumOrder(FirmPrefix, zak.NomZak); // формируем номер заказа на сервере
      if zak.nomstr='' then raise Exception.Create(MessText(mtkNotValidParam)+' - N заказа');

      ibd:= cntsORD.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpWrite, true);
      ibs.SQL.Text:= 'select rORDRDATE as ORDRDATE, rMaxOrderNum'+
        ' from TestVladOrderNum('+FirmCode+', :Nzak)'; // проверяем уникальность № заказа
      ibs.ParamByName('Nzak').AsString:= zak.nomstr;
      ibs.ExecQuery;
      if not (ibs.Bof and ibs.Eof) and (ibs.FieldByName('rMaxOrderNum').AsInteger>0) then begin
        Result.Add(pINFORM+'Дубликат заказа N '+zak.nomstr); // строка в ответ
        Result.Add(pINFORM+'На сервере есть Ваш заказ N '+zak.nomstr+' от '+
          fnDateGetText(ibs.FieldByName('ORDRDATE').AsDateTime)); // строка в ответ
        if (TDate(ibs.FieldByName('ORDRDATE').AsDateTime)<>TDate(fnStrToDateDef(zak.DatZak))) then begin
          Result.Add(pINFORM+'Ваш последний N заказа на сервере - '+
            ibs.FieldByName('rMaxOrderNum').AsString); // строка в ответ
          Result.Add(pINFORM+'Измените номер в неотправленном заказе'); // строка в ответ
        end;
        mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'Дубликат заказа N '+zak.nomstr;
        raise Exception.Create('');
      end;
      ibs.Close;

      for i:= Low(zakln) to High(zakln) do begin
        j:= StrToIntDef(zakln[i].WCode, 0);
        if WareExist(j) then with GetWare(j) do if not IsArchive then
          zakln[i].Wdocm:= IntToStr(measID)
        else zakln[i].Wdocm:= '1';
        if zakln[i].WKolv='' then zakln[i].WKolv:= '0';
      end;

      if zak.DeliTp='' then zak.DeliTp:= '1'; // тип доставки по умолчанию (резервировать)
      dat:= fnStrToDateDef(zak.DatZak, Date);
      datw:= DateNull;
      s1:= '';
      s2:= '';
      if (zak.OplZak='1') and (zak.Warrnt<>'') then begin   // (ORDRACCOUNTINGTYPE=1)
        ar:= fnSplitString(ExtractParametr(zak.Warrnt));   // реквизиты доверенности - в массив
        if length(ar)>0 then s1:= ar[0];
        if length(ar)>1 then datw:= fnStrToDateDef(ar[1]);
        if length(ar)>2 then s2:= ar[2];
      end;
      if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
      ibs.SQL.Text:= 'select rNewOrderCode, rDate from CreateNewOrderHeader(:ORDRNUM, '+
        // тип учета(0-нал, 1-б/нал), филиал, код склада, источник, код фирмы, тип доставки
        zak.OplZak+', '+sdprt+', '+zak.storage+', '+IntToStr(cosByVlad)+', '+FirmCode+', '+zak.DeliTp+', '+
        zak.ValZak+', :ORDRWARRANT, :ORDRWARRANTDATE, :ORDRWARRANTPERSON, '+  // код валюты, ...
        IntToStr(orstProcessing)+', :ORDRSTORAGECOMMENT, :ORDRDATE, '+UserCode+')';        // ..., Создатель заказа
      ibs.ParamByName('ORDRNUM').AsString           := zak.nomstr;      // № заказа
      ibs.ParamByName('ORDRWARRANT').AsString       := s1;              // Доверенность
      ibs.ParamByName('ORDRWARRANTDATE').AsDateTime := datw;            // Дата доверенности
      ibs.ParamByName('ORDRWARRANTPERSON').AsString := s2;              // Кому выдана доверенность
      ibs.ParamByName('ORDRSTORAGECOMMENT').AsString:= zak.Commnt;      // примечание
      ibs.ParamByName('ORDRDATE').AsDateTime        := dat;             // Дата заказа
      for i:= 1 to RepeatCount do // записываем заголовок заказа (пробуем RepeatCount раз)
        try
          if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
          ibs.ExecQuery;
          if (ibs.Bof and ibs.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
          zak.KodZak:= ibs.fieldByName('rNewOrderCode').AsString;  // код заказа
          zak.izak  := ibs.fieldByName('rNewOrderCode').AsInteger;
          zak.DZakIn:= FormatDateTime(cDateTimeFormatY2N, ibs.fieldByName('rDate').AsDateTime);
          ibs.Close;
          ibs.Transaction.Commit;
          Break;
        except
          on E: Exception do begin
            ibs.Close;
            if ibs.Transaction.InTransaction then ibs.Transaction.RollbackRetaining;
            zak.KodZak:= '';
            zak.izak  := 0;
            zak.DZakIn:= '';
            if i<RepeatCount then begin
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'ошибка записи заголовка заказа, попытка '+IntToStr(i);
              sleep(RepeatSaveInterval);
            end else begin
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+E.Message;
              raise Exception.Create(messzak);
            end;
          end;
        end;

      mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'записывали заголовок заказа '+
        GetLogTimeStr(LocalThreadStart);
      LocalThreadStart:= now();

      ferr:= True; // флаг ошибок записи товара                // список товаров
      kt:= 0;       // счетчик строк товаров
      if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
      ibs.SQL.Text:= 'select rNewOrderLnCode from AddOrderLineQty('+zak.KodZak+', '+   // ..., код заказа
        ':ORDRLNWARE, :ORDRLNCLIENTQTY, :ORDRLNMEASURE, :ORDRLNPRICE, '+zak.storage+', 0)';  // ..., код склада
      ibs.Prepare;
      for i:= Low(zakln) to High(zakln) do begin // записываем строки товаров заказа
        Ware:= GetWare(StrToIntDef(zakln[i].WCode, 0), True);
        s:= '';
        if Ware=NoWare then
          s:= 'Ошибка записи в заказ товара - не найден код '+zakln[i].WCode
        else if not fnNotZero(Ware.RetailPrice) then  // убираем из наименования длинные пробелы
          s:= 'Ошибка записи в заказ товара '+StringReplace(Ware.Name, '  ', ' ', [rfReplaceAll])+' - нет цены';
        if s<>'' then begin
          Result.Add(pINFORM+s); // строка в ответ
          Result.Add(pERRCOD+zakln[i].WCode+';'+zak.NomZak); // строка в ответ с кодом товара
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+s;
          ferr:= False;
          Body.Add(s);
          Continue;
        end;
        
        ibs.ParamByName('ORDRLNWARE').AsString    := zakln[i].WCode;  // код товара
        ibs.ParamByName('ORDRLNMEASURE').AsString := zakln[i].Wdocm;  // код ед.изм.
        ibs.ParamByName('ORDRLNCLIENTQTY').AsFloat:= StrToFloatDef(zakln[i].WKolv, 0); // кол-во
        ibs.ParamByName('ORDRLNPRICE').AsFloat    := StrToFloatDef(zakln[i].WCena, 0); // цена
        for j:= 1 to RepeatCount do try //  пробуем посадить товар RepeatCount раз
          if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
          ibs.ExecQuery;
          ibs.Transaction.Commit;
          ibs.Close;
          Inc(kt);
          break;
        except
          on E: Exception do begin
            if ibs.Transaction.InTransaction then ibs.Transaction.RollbackRetaining;
            ibs.Close;
            if j<RepeatCount then begin
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'Ошибка записи товара заказа: код '+zakln[i].WCode+', попытка '+IntToStr(j);
              sleep(RepeatSaveInterval);
            end else begin
              s:= StringReplace(Ware.Name, '  ', ' ', [rfReplaceAll]); // убираем из наименования длинные пробелы
              Result.Add(pINFORM+'Ошибка записи товара '+s); // строка в ответ
              Result.Add(pERRCOD+zakln[i].WCode+';'+zak.NomZak); // строка в ответ с кодом товара
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+
                'Ошибка записи товара заказа: код '+zakln[i].WCode+', '+s+#13#10+E.Message;
              ferr:= False;
              Body.Add('Ошибка записи товара заказа: код '+zakln[i].WCode+', '+s);
            end;
          end; // on E: Exception
        end; // for j:= 1 to RepeatCount
      end; // for i:=

      mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'записывали строки товаров заказа '+
        GetLogTimeStr(LocalThreadStart);
      LocalThreadStart:= now();

      if (Body.Count>0) then begin
        Body.Add('Error save order: FirmCode: '+FirmCode+', order N '+zak.NomZak);
        s:= fnGetSysAdresVlad(caeOnlyDayLess);
        Body.Insert(0, GetMessageFromSelf);
        s:= n_SysMailSend(s, 'Error save order', Body, nil, '', '', true); // отправить сообщение админу пр-мы Vlad
        if s<>'' then begin
          prMessageLOGS(nmProc+': Ошибка отправки письма об Ошибке приема заказа: '#13#10+s, LogMail, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'Ошибка отправки письма об Ошибке приема заказа', s);
        end;
      end;
      if not ferr then  // если были ошибки
        if kt>0 then begin // если были ошибки, но в заказе есть строки
          Result.Add(pINFORM+'заказ N '+Zak.NomZak+': принято '+IntToStr(kt)+' строк');
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'заказ N '+Zak.NomZak+': принято '+IntToStr(kt)+' строк';
        end else begin // если были ошибки и в заказе нет строк
          FreeZakaz(zak.nomstr);
          Result.Add(pINFORM+'заказ N '+Zak.NomZak+' в обработку не принят');
          Result.Add(pNOMSTR+Zak.NomZak+';'+IntToStr(orstNoDefinition));
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'заказ N '+Zak.NomZak+' в обработку не принят';
          Exit;
        end;

      ferr:= True;              // Проверяем, надо ли сразу формировать счет
      zak.Checked:= FirmExist(FirmID) and arFirmInfo[FirmID].SKIPPROCESSING;
  //    zak.Checked:= False;  // для отладки TCheckStoppedOrders
      if zak.Checked then try // если надо формировать счет
        Stream:= TBOBMemoryStream.Create;
        Stream.WriteInt(zak.izak);
        Stream.WriteBool(False); // не проверять параметры отгрузки

        prOrderToGBn_Ord(Stream, ThreadData, True); // формируем счет

        mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'записывали счет '+
          GetLogTimeStr(LocalThreadStart);
        LocalThreadStart:= now();
        Application.ProcessMessages;

        Stream.Position:= 0;
        jj:= Stream.ReadInt;
        if (jj in [aeSuccess, erWareToAccount]) then begin
          if jj=erWareToAccount then begin // если счет записан, но были ошибки при записи товаров
            Body.Clear;
            s:= Stream.ReadStr;
            Body.Text:= s;
            if Body.Count>0 then for i:= 0 to Body.Count-1 do
              Result.Add(pINFORM+Body.Strings[i]); // передаем перечень ошибок
          end;

          setLength(zaks, 1);
          zaks[0].NomZak:= zak.NomZak;
          zaks[0].nomstr:= zak.NomZak;
          Body.Clear;
          Body:= GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode, zaks, ThreadData, exevers);
          if Body.Count>0 then for i:= 0 to Body.Count-1 do Result.Add(Body.Strings[i]);
          ferr:= False;
          mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'выбирали документы к заказу '+
            GetLogTimeStr(LocalThreadStart);
        end else begin
          s:= Stream.ReadStr;
          raise Exception.Create(s);
        end;
      except
        on E: Exception do begin
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'ошибка формирования счета по заказу N '+zak.NomZak+' - '#13#10+E.Message;
          Body.Clear; // отправить сообщение админу пр-мы Vlad
          Body.Add(GetMessageFromSelf);
          Body.Add('Error save account: FirmCode: '+FirmCode+', order N '+zak.NomZak);
          s:= fnGetSysAdresVlad(caeOnlyDayLess);
          s:= n_SysMailSend(s, 'Error save account', Body, nil, '', '', true);
          if (s<>'') then begin
            s1:= 'Ошибка отправки письма об Ошибке формирования счета';
            prMessageLOGS(nmProc+': '+s1+': '#13#10+s, LogMail, false);
            fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s1, s);
          end;
        end;
      end;

      if ferr then begin
        Result.Add(pINFORM+'заказ N '+zak.NomZak+' на обработке');
        Result.Add(pINFORM+'позже проверьте статус заказа N '+zak.NomZak);
        Result.Add(pNOMSTR+zak.NomZak+';'+IntToStr(orstProcessing)+';'+zak.DZakIn);
        mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'заказ N '+zak.NomZak+
          ' на обработке ('+IntToStr(Length(zakln))+' строк)';
      end else begin
        Result.Add(pINFORM+'заказ N '+zak.NomZak+' принят');
        mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'заказ N '+zak.NomZak+
          ' принят ('+IntToStr(kt)+' строк)';
      end;
    except
      on E: Exception do if E.Message<>'' then begin
        Result.Add(pINFORM+messzak); // строка в ответ
        mess3:= mess3+fnIfStr(mess3='', '', #13#10)+messzak+': '+E.Message;
      end;
    end;
    mess5:= 'обрабатывали заказ ('+IntToStr(Length(zakln))+' строк) '+
      GetLogTimeStr(tdtbegin)+fnIfStr(mess5='', '', #13#10)+mess5;
  finally
    setLength(zaks, 0);
    setLength(ar, 0);
    setLength(wkodes, 0);
    prFree(Stream);
    prFree(Body);
    prFreeIBSQL(ibs);
    cntsORD.SetFreeCnt(ibd);
    if ToLog(2) and (mess2<>'') then prMessageLOGS(nmProc+': '+mess2, LogMail, false);
    if ToLog(12) and (mess2<>'') then prSetThLogParams(ThreadData, 0, 0, 0, mess2); // добавляем в LOG сообщение
    if ToLog(5) and (mess5<>'') then prMessageLOGS(nmProc+': '+mess5, LogMail, false);
    if ToLog(15) and (mess5<>'') then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, mess5);
    if (mess3<>'') then prMessageLOGS(nmProc+': '+mess3, LogMail, false);
    if (mess3<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', mess3);
  end;
end;

//================================================ отчет о загрузке новой версии
function ReportReLoadVers(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): Boolean;
const nmProc = 'ReportReLoadVers'; // имя процедуры/функции
var nfile, nf, s: string;
    i, UserID: Integer;
begin
  Result:= False;
  i:= 0;
  UserID:= StrToIntDef(UserCode, 0);
  nfile:= MSParams.DirFileRep+'ReLoVe_'+UserCode;
  with Cache do begin
    mess.Insert(0, 'UserCode= '+UserCode+', Login= '+arClientInfo[UserID].Login+
      ', Passw= '+arClientInfo[UserID].Password);
    mess.Insert(1, 'FirmCode= '+FirmCode+', FirmName= '+arClientInfo[UserID].FirmName);
  end;
  s:= 'NetConnectionType= '+IntToStr(NetConnectionType);
  if MailParam.SocketHost<>'' then s:= s+ ', '+MailParam.SocketHost+', '+
    IntToStr(MailParam.SocketPortTo)+', '+IntToStr(MailParam.SocketPortFrom);
  mess.Insert(2, s);
  s:= StringOfChar('-', 20);
  mess.Insert(3, s+' Vlad-s report '+s);
  nf:= nfile;
  try
    while FileExists(nf) do begin
      Inc(i);
      nf:= nfile+'_'+IntToStr(i);
    end;
    fnStringsLogToFile(mess, nf); // сбрасываем отчет в файл
    Result:= true;
  except end;
end;
//=============================================== запись параметров клиента Влад
function SetUserParams(aCODE, aLOGIN, aPASSW, aVERSNUM, aVERSDATA: string): string;
var ibs: TIBSQL;
    ibd: TIBDatabase;
begin
  Result:= '';
  ibd:= nil;
  try
    ibd:= cntsLog.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_SetUserParams_'+aLOGIN, -1, tpWrite, true);
    ibs.SQL.Text:= 'execute procedure TestVladUserParams(:aCODE, :aLOGIN, '+
      ':aPASSW, :aVERSNUM, :aVERSDATA, :aNETTYPE, :aHOST, :aPORTTO, :aPORTFROM)';
    ibs.ParamByName('aCODE').AsString:= aCODE;
    ibs.ParamByName('aLOGIN').AsString:= aLOGIN;
    ibs.ParamByName('aPASSW').AsString:= aPASSW;
    ibs.ParamByName('aVERSNUM').AsString:= aVERSNUM;
    ibs.ParamByName('aVERSDATA').AsString:= aVERSDATA;
    ibs.ParamByName('aNETTYPE').AsInteger:= NetConnectionType;
    ibs.ParamByName('aHOST').AsString:= MailParam.SocketHost;
    ibs.ParamByName('aPORTTO').AsInteger:= MailParam.SocketPortTo;
    ibs.ParamByName('aPORTFROM').AsInteger:= MailParam.SocketPortFrom;
    ibs.ExecQuery;
    if ibs.Transaction.InTransaction then ibs.Transaction.Commit;
  except
    on E: Exception do Result:= 'SetUserParams: '+E.Message;
  end;
  prFreeIBSQL(ibs);
  cntsLog.SetFreeCnt(ibd);
end;
//==============================================================================

end.
