unit n_MailReports;
//******************************************************************************
//                   ������������ ������� ��� ��������� ����
//******************************************************************************
interface

uses Windows, Classes, Forms, SysUtils, Math, Controls, DateUtils, 
     DB, IBDatabase, IBSQL, n_free_functions, v_constants, v_DataTrans,
     n_vlad_mail, n_Functions, n_constants, n_MailServis, n_DataCacheInMemory, 
     n_LogThreads, n_DataSetsManager, n_func_ads_loc, n_vlad_common, n_server_common;

 function AddNewZaksOrd(FirmCode, FirmPrefix, UserCode: String; zak: TZakazLine;
          zakln: array of TWareLine; ThreadData: TThreadData; exevers: String=''): TStringList; // ���������� � ib_ord ����� �����
 function GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode: String; zaks: array of TZakazLine;
           ThreadData: TThreadData; exevers: String=''): TStringList;      // �������� ������� �������
 function LoadingZaksOrd(FirmCode, FirmPrefix, UserCode, BegDat: String; zaks: array of TZakazLine;
          ThreadData: TThreadData; exevers: String=''): TStringList;  // ��������� ������
 function ReportUnpayedDocOrd(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList; // �������� �����.���-��, ������.�����, ����.�������
 function GetDivisible(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;        // ��������� ��������� �������
 function ReportFirmDiscounts(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList; // �������� ������ ������ �����
 function ReportRateCur(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;       // �������� ���� �.�.
 function ReportRestAndPrice(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; exevers: String=''): TStringList; // �������� ������ �������� � ���
 function ReportDataAll(FirmCode, UserCode: String; var nfzip: string; // ������ ���������� �������
          ThreadData: TThreadData; exevers: String=''): TStringList;
 function ReportMesMan(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): TStringList; // ��������� ��������� ���������
 function ReportGetNewVers(FirmCode, UserCode, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList;  // ��������� ����� ������ ��������� ����
 function ReportReLoadVers(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): Boolean; // ����� � �������� ����� ������
 function ReportBlockOldVers(zapros, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList; // �������� ����� ��������� ��� ���������� ������ ��� ������ ������
 function ReportLoadOrgNum(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; onzipSize: Integer=0): TStringList; // �������� ������ ������������ ������� � ��������� �����
 function ReportWrongMes(FirmCode, UserCode: String; arpar: Tas; mess: TStringList; ThreadData: TThreadData): TStringList; // ������ �� ������
 function SetUserParams(aCODE, aLOGIN, aPASSW, aVERSNUM, aVERSDATA: string): string;

implementation
uses n_DataCacheObjects, n_vlad_files_func;
//==============================================================================
//                     ������ �� ������
//==============================================================================
function ReportWrongMes(FirmCode, UserCode: String; arpar: Tas; mess: TStringList; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportWrongMes'; // ��� ���������/�������
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
    if (MesType<1) then raise Exception.Create(MessText(mtkNotValidParam)+' ����');
    WareId:= StrTointDef(arpar[1], 0);
    if (WareId<1) then raise Exception.Create(MessText(mtkNotValidParam)+' ������');

    case MesType of
      constWrongAnalog: begin // =3; ������ �������� �������
          AnalogId:= StrTointDef(arpar[2], 0);
          if (AnalogId<1) then raise Exception.Create(MessText(mtkNotValidParam)+' �������');
        end;
      constWrongOrNum: begin // =5; ������ ������������ ������������� ������
          OrNumId := StrTointDef(arpar[2], 0);
          if (OrNumId<1) then raise Exception.Create(MessText(mtkNotValidParam)+' ����.������');
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
      j:= mess.IndexOf(cStrWhy); // ��� ����� ��������� �������� �� ������ cStrWhy
      for i:= j+1 to mess.Count-1 do Body.Add(mess[i]);
                                                // ���������� ��������� �� ������
      ms:= fnSendErrorMes(FirmID, UserID, MesType, WareId, AnalogId, OrNumId, -1, -1, Body.Text, '', ThreadData);

  //------------------------------------------------- ��������� ����� ������������
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
//                    ��������� ��������� ���������
//==============================================================================
function ReportMesMan(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportMesMan'; // ��� ���������/�������
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
      ma:= '��������� ��������';
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, ma);
      if ToLog(2) then prMessageLOGS(nmProc+': '+ma, LogMail, false);
      if ToLog(11) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, ms); // ��������� � LOG ���������
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
//                        ����� ������ ���������
//==============================================================================
function ReportGetNewVers(FirmCode, UserCode, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList;
var currvers, nf, nfmail, vd, vn, s, err: String;
    ar: Tas;
begin
  Result:= TStringList.Create;
  err:= '������ �������� ����� ������ ���������.';
  Result.Add('response:'+cGetNewVers);
  TestCurrentVersVlad(ThreadData); // ��������� ������� ������ ��������� ����
  currvers:= GetIniParam(nmIniFileBOB, 'mail', 'vladversion');
  setLength(ar, 0);
  ar:= fnSplitString(currvers); // ��������� ������� ������ ��������� ���� - � ������
  try
    vn:= ar[0]; // ar[0] - � ������
    If length(ar)>1 then vd:= ar[1] else vd:= ''; // ar[1] - ���� ������
    s:= '';
    if (length(ar)>0) then begin
      Result.Add(pCOMMNT+currvers); // ���������� � ����� ��������� ������� ������ ����
      if not VersFirstMoreSecond(vn, vd, exevers, exedate) then begin
        Result.Add(pINFORM+'� ��� ���������� ������ ���������.');
        nfzip:= '';
        Exit;
      end;
    end else begin
      Result.Add(pINFORM+err);
      nfzip:= '';
      Exit;
    end;

    try
      s:= 'tmp'+fnGenRandString(4); // ��� ����.�����
      If length(ar)>2 then nfzip:= ar[2] else nfzip:= nfzipvlexe; // ar[2] - ��� zip-����� ������
      nf:= Cache.VladZipPath+nfzip;
      if not FileExists(nf) then raise Exception.Create(MessText(mtkNotFoundFile)+nf);
      if not TestVladVersFromZip(DirFileErr, nf, 'vlad.exe', s, vn, vd, True) then
        raise Exception.Create('�������������� ������ � ����� '+nf+': '+s); // ��������� ������ ����� � ������
      nfmail:= DirFileErr+nfzip;
      if FileExists(nfmail) then DeleteFile(nfmail);
      CopyFile(PChar(nf), PChar(nfmail), false); // �������� zip � ����� �����
      if not FileExists(nfmail) then raise Exception.Create(MessText(mtkErrCopyFile)+nfmail);
      Result.Add(pKTOVAR+nfzip); // ���������� � ����� ��� ����� ������ ����������
      nfzip:= nfmail;            // ������ ��� ����� ������ ��� ��������
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
//============= �������� ����� ��������� ��� ���������� ������ ��� ������ ������
function ReportBlockOldVers(zapros, exevers, exedate: String; var nfzip: string; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportBlockOldVers'; // ��� ���������/�������
var currvers, nfmail, vd, vn, s, err, nfm: String;
    ar: Tas;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetRateCur); // ���������� � ����� ���������
  Result.Add(pINFORM+strDelim2_45);
  Result.Add(pINFORM+'   ��������� �������� �� ������ ������');
  Result.Add(pINFORM+'         �  �  �  �  �  �  �  �  �  �  �  �  � !');
  Result.Add(pINFORM+strDelim2_45);

  TestCurrentVersVlad(ThreadData); // ��������� ������� ������ ��������� ����
  currvers:= GetIniParam(nmIniFileBOB, 'mail', 'vladversion');
  setLength(ar, 0);
  ar:= fnSplitString(currvers); // ��������� ������� ������ ��������� ���� - � ������
  try
    vn:= ar[0]; // ar[0] - � ������
    If length(ar)>1 then vd:= ar[1] else vd:= ''; // ar[1] - ���� ������
    try
      s:= 'tmp'+fnGenRandString(4); // ��� ����.�����
      If length(ar)>2 then nfzip:= ar[2] else nfzip:= nfzipvlexe; // ar[2] - ��� zip-����� ������
      nfm:= nfzip;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, err, E.Message);
        if FileExists(nfmail) then DeleteFile(nfmail);
        nfzip:= '';
      end;
    end;
    Result.Add(pINFORM+'      �������� � ����� ����� '+nfm);
    Result.Add(pINFORM+'         ���������� � �������� �����');
    Result.Add(pINFORM+'               � ����� vlad\EXE');
    Result.Add(pINFORM+strDelim2_45);
  finally
    setLength(ar, 0);
  end;
  if ToLog(2) then prMessageLOGS(nmProc+': ���������� ��������� � ���������� ������ ������', LogMail, false);
  if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, '���������� ��������� � ���������� ������ ������'); // ��������� � LOG ���������
end;
//==============================================================================
//                             ���������� �������
//==============================================================================
//================================== ������ ���������� ������� - ��������� �����
function ReportDataAll(FirmCode, UserCode: String; var nfzip: string;
         ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'ReportDataAll'; // ��� ���������/�������
var nf, nfmail, str, dir, tmpdir, sFiles: string;
    i, contID: integer;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetDataAll);
  dir:= '';
  str:= '';
  contID:= 0;
  with Cache do try
    i:= StrToIntDef(FirmCode, 0); // ������ AUTO / MOTO
    if FirmExist(i) then str:= GetSysTypeSuffix(arFirmInfo[i].GetContract(contID).SysID);

    nf:= VladZipPath+nfzip+str+'.zip';
    if not FileExists(nf) then raise Exception.Create(MessText(mtkNotFoundFile)+nf);
//    TestVladDbf(nf, ThreadData, exevers); // �������� ���� vladdbf.zip

    if not TestBaseRestAndPrice(ThreadData) then begin // ��������� ���� � ������� � base.dbf
      dir:= '����� ���� ����������';
      if ToLog(2) then prMessageLOGS(nmProc+': '+dir, LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, dir); // ��������� � LOG ���������
    end;

    tmpdir:= 'rr'+fnGenRandString(4); // ��� ��� �����
    dir:= fnCreateTmpDir(DirFileErr, tmpdir); // �������� ��������� �����
    tmpdir:= fnTestDirEnd(dir); // ��� ��������� ����� � �������� ������
    try
      CScache.Enter;
      CopyFile(PChar(nf), PChar(tmpdir+nfzip+'.zip'), false); // �������� zip � ����.�����
    finally
      CSCache.Leave;
    end;
    nf:= tmpdir+nfzip+'.zip'; // ������ �������� � ������ ������ ����������
    if not FileExists(nf) then raise Exception.Create(MessText(mtkErrCopyFile)+nf);

    sFiles:= '';
    str:= ZipExtractFiles(nf, sFiles, dir); // ������������� ����� �� zip
    if str<>'' then raise Exception.Create(str);

    if not FirmBaseRestCols(FirmCode, baseFname, tmpdir, exevers, ThreadData) then // ������� ����� �������
      raise Exception.Create('������ ��������� ��������� �����');

    DeleteFile(nf); // ������� ������ zip
    str:= ZipAddFiles(nf, sFiles); // ������ ����� �������

    if str<>'' then raise Exception.Create(str);
    Application.ProcessMessages;

    nfmail:= DirFileErr+nfzip+'.zip';
    if FileExists(nfmail) then DeleteFile(nfmail);
    RenameFile(nf, nfmail);
    if not FileExists(nfmail) then raise Exception.Create(MessText(mtkErrCopyFile)+nfmail);
    Result.Add(pKTOVAR+nfzip+'.zip'); // ���������� � ����� ��� ����� ������ ����������
    nfzip:= nfmail;                   // ������ ��� ����� ������ ��� ��������
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      nf:= '������ ���������� ���';
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, nf, E.Message);
      Result.Add(pINFORM+nf);
      if FileExists(nfmail) then DeleteFile(nfmail);
      nfzip:= '';
    end;
  end;
  if not fnDeleteTmpDir(dir) then begin // ������ �� �����
    nf:= '������ ������� ����.�����';
    prMessageLOGS(nmProc+': '+nf+' '+dir, LogMail, False);
    fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, nf, dir);
  end;
end;
//============================= �������� ������ �������� � ��� � ��������� �����
function ReportRestAndPrice(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'ReportRestAndPrice'; // ��� ���������/�������
      errmess = '������ ������ �������� � ���';
var str, nftmpRest: string;
    i, contID: Integer;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetReAndPr);
  DeleteFile(DirFileErr+nfzip+'.zip');
  DeleteFile(DirFileErr+nfzip+'.dbf'); // �� ����.������
  contID:= 0;
  with Cache do try
    str:= '.dbf';
    i:= StrToIntDef(FirmCode, 0); // ������ AUTO / MOTO
    if FirmExist(i) then str:= GetSysTypeSuffix(arFirmInfo[i].GetContract(contID).SysID)+str;
    nftmpRest:= restFname+str;

    if not TestRestAndPrice(ThreadData) then begin // ��������� / ��������� ���� �������� � ���
      if ToLog(2) then prMessageLOGS(nmProc+': ����� ���� ��������', LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, '����� ���� ��������'); // ��������� � LOG ���������
    end; 

    try
      CScache.Enter;
      CopyFile(PChar(DirFileErr+nftmpRest), PChar(DirFileErr+nfzip+'.dbf'), false); // �������� ���� ��������
    finally
      CSCache.Leave;
    end;
    if not FileExists(DirFileErr+nfzip+'.dbf') then // ��������� �����
      raise Exception.Create('��� ����� ����� ��������');

    if not FirmRestAndPrice(FirmCode, nfzip, '', ThreadData) then // ������� ������� �������� ������� 
      raise Exception.Create('������ ��������� ��������� ����� ��������');

    if not RenameFile(DirFileErr+nfzip+'0.dbf', DirFileErr+nColRests) then
      raise Exception.Create('������ �������������� ����� �������');

    str:= ZipAddFiles(DirFileErr+nfzip+'.zip', DirFileErr+nColRests); // ������ ������� ������� �������
    if (str<>'') then raise Exception.Create(str);
    DeleteFile(DirFileErr+nColRests); // ������� ������� ������� �������
    if str<>'' then raise Exception.Create(str);

    str:= ZipAddFiles(DirFileErr+nfzip+'.zip', DirFileErr+nfzip+'.dbf'); // ������ ������� ��������
    Application.ProcessMessages;
    if str<>'' then raise Exception.Create(str);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errmess, E.Message);
      Result.Add(pINFORM+errmess);
      DeleteFile(DirFileErr+nfzip+'.zip'); // ������� ���� ������, ���� �� ��� ����
      nfzip:= '';
    end;
  end;
  if nfzip='' then Exit;
  Result.Add(pKTOVAR+nfzip+'.zip'); // ���������� � ����� ��� ����� ������ ��������
  DeleteFile(DirFileErr+nfzip+'.dbf'); // ������� ������� ��������
  nfzip:= DirFileErr+nfzip+'.zip'; // ������ ��� ����� ������ ��� ��������
end;
//======================= �������� ������ ������������ ������� � ��������� �����
function ReportLoadOrgNum(FirmCode, UserCode: String; var nfzip: string; ThreadData: TThreadData; onzipSize: Integer=0): TStringList;
const nmProc = 'ReportLoadOrgNum'; // ��� ���������/�������
var nfon, nfziptmp, errmess, s: String;
    i, contID: integer;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cLoadOrgNum);
  nfziptmp:= DirFileErr+nfzip+'.zip';
  DeleteFile(nfziptmp); // �� ����.������
  errmess:= '������ ������ ������������ �������';
  contID:= 0;
  with Cache do try
    i:= StrToIntDef(FirmCode, 0);
    s:= '';
    if FirmExist(i) then //  ������ AUTO / MOTO
      if not arFirmInfo[i].CheckSysType(constIsAUTO) then begin // ���� ��.���. ������ AUTO
        Result.Add(pERRCOD+'�� ������-����������� '+arFirmInfo[i].GetContract(contID).SysName);
        Result.Add(pERRCOD+'��� ���� ������������ �������');
        errmess:= '';
        raise Exception.Create('');
      end;

    nfon:= VladZipPath+nfziporgnum+s+'.zip';
    if not FileExists(nfon) then // ��������� ���� ������ ������������ �������
      raise Exception.Create(MessText(mtkNotFoundFile)+nfziporgnum+'.zip');

    if onzipSize>0 then begin // ��������� ������ zip ��.�. �������
      i:= GetFileSize(nfon);
      if abs(i-onzipSize)<5 then begin // ���� ������ zip �� ���������
        errmess:= '� ��� ���������� ���� ������������ �������';
        raise Exception.Create('');
      end;
    end;
    try
      CScache.Enter;
      CopyFile(PChar(nfon), PChar(nfziptmp), false); // ��������
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
      DeleteFile(nfziptmp); // ������� ���� ������, ���� �� ��� ����
      nfzip:= '';
    end;
  end;
  if nfzip<>'' then begin
    Result.Add(pKTOVAR+nfzip+'.zip'); // ���������� � ����� ��� ����� ������ ������������ �������
    nfzip:= nfziptmp; // ������ ��� ����� ������ ��� ��������
  end;
end;
//==============================================================================
//                     �������� ���� �.�. � ��������� �����
//==============================================================================
function ReportRateCur(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportRateCur'; // ��� ���������/�������
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
  if rate<>'' then Result.Add(pKTOVAR+rate) else Result.Add(pINFORM+'������ �������� ����� �.�.');
end;
//==============================================================================
//    �������� ������ ������ ����� � ��������� �����
//==============================================================================
function ReportFirmDiscounts(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportFirmDiscounts';   // ��� ���������/�������
      errLoad = '������ �������� ������';
var FirmID, i, j, contID: Integer;
    link: TQtyLink;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetFirmDis);
  FirmID:= StrToIntDef(FirmCode, 0);
  j:= 0; // �������
  contID:= 0;
  with Cache do try
    if not FirmExist(FirmID) then TestFirms(FirmID, True);
    with arFirmInfo[FirmID].GetContract(contID) do // ���� ����� � �������� �� ��������
      for i:= 0 to ContDiscLinks.Count-1 do try
        link:= ContDiscLinks[i];
        Result.Add(pKTOVAR+IntToStr(link.LinkID)+';'+fnSetDecSep(FormatFloat('# ##0.00', link.Qty)));
        inc(j);
      except
        on E: Exception do fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errLoad, E.Message);
      end;
    if j<1 then Result.Add(pINFORM+'������ �� �������');
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, errLoad, E.Message);
      Result.Add(pINFORM+errLoad);
    end;
  end;
end;
//==============================================================================
//    �������� �����.���-��, ������.�����, ����.������� � ��������� �����
//==============================================================================
function ReportUnpayedDocOrd(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'ReportUnpayedDocOrd'; // ��� ���������/�������
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
  Result.Add('response:'+cUnpayedDoc); // �������� ������ ������������ ���������� � ��������� �����
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
      if (ibs.Bof and ibs.Eof) then Result.Add(pINFORM+'������������ ��������� �� �������')
      else while not ibs.EOF do begin
        dd:= ibs.FieldByName('RDOCMDATE').AsDateTime+ibs.FieldByName('DELAYCALC').AsInteger+1;
        str:= ibs.FieldByName('LNNUMBER').AsString+';'+  // � ���������
              ibs.FieldByName('RDOCMCODE').AsString+';'+   // ��� ���������
              IntToStr(GetOldDocmType(ibs.FieldByName('RDOCMTYPE').AsInteger, // ���� �������� ������ ���� ����� ���-��� !!!
              5))+';'+   // ��� ���� ���������
//              ibs.FieldByName('DUTYTYPE').AsInteger))+';'+   // ��� ���� ���������
              fnDateGetText(ibs.FieldByName('RDOCMDATE').AsDateTime)+';'+ // ���� ���������
              fnDateGetText(dd)+';';                         // ���� ������
        sum:= RoundToHalfDown(ibs.FieldByName('LNSUMM').AsFloat);
//        if fnNotZero(sum) and (ibs.FieldByName('DUTYTYPE').AsString<>'5') then sum:= -sum; // 5 - ����, 0 - ������
        str:= str+fnSetDecSep(FloatToStr(sum))+';'; // ����� ��������� (���������� ����� - �������������)
        sum:= RoundToHalfDown(ibs.FieldByName('RDutySumm').AsFloat);
//        if fnNotZero(sum) and (ibs.FieldByName('DUTYTYPE').AsString<>'5') then sum:= -sum;
        str:= str+fnSetDecSep(FloatToStr(sum))+';'+ // ������������ ����� (���������� ����� - �������������)
              GetCurrName(ibs.FieldByName('RCRNCCODE').AsInteger, True)+';'+ // ������ ���������
              ibs.FieldByName('DPRTCODE').AsString+';';  // ��� ������
        Result.Add(pNOMSTR+str); // ��������� ���������
        ibsW.ParamByName('DOCMCODE').AsInteger:= ibs.FieldByName('RDOCMCODE').AsInteger;
        ibsW.ExecQuery;                           // ������ ���-��
        while not ibsW.EOF do begin
          if fnNotZero(ibsW.fieldByName('LNPRICE').AsFloat) then
            Result.Add(pKTOVAR+ibsW.fieldByName('LNWARECODE').AsString+';'+ // ��� ������
              ibsW.fieldByName('LNCOUNT').AsString+';'+ // ���-��
              fnSetDecSep(FormatFloat('# ##0.00', ibsW.fieldByName('LNPRICE').AsFloat))); // ����
          ibsW.Next;
        end;
        ibsW.Close;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
    except
      on E: Exception do begin
        s:= '������ �������� ������������ ����������';
        Result.Add(pINFORM+s);
        prMessageLOGS(nmProc+': '+s+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
      end;
    end;

    with Contract do Result.Add(pDEBETS+ // ��������� � ����� ��������� �������
      FloatToStr(CredLimit)+';'+                          // ������ �������
      fnSetDecSep(FloatToStr(DebtSum))+';'+               // ������������� �� ������� ������
      fnSetDecSep(FloatToStr(OrderSum))+';'+              // ����� ����� ������������������ ������ � ������ �������
      GetCurrName(CredCurrency, True)+';'+                // ������� ������������ ������ �������
      BoolToStr(SaleBlocked)+';'+IntToStr(CredDelay)+';'+ // ������� ����������, ��������
      WarnMessage+';');                                // ����� ��������� � ��������� ��������� �������
    ibsW.Close;
    ibs.Close;

    cntsGRB.TestSuspendException;
    Result.Add('response:'+cRepAccList); // �������� ������ ���������� ������ � ��������� �����
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
      if (ibs.Bof and ibs.Eof) then Result.Add(pINFORM+'���������� ����� �� �������')
      else while not ibs.EOF do begin    // ��������� �����
        str:= StringReplace(ibs.fieldByName('acCLIENTCOMMENT').AsString, #10, ' ', [rfReplaceAll]);
        str:= StringReplace(str, #13, ' ', [rfReplaceAll]);
        str:= StringReplace(str, ';', ',', [rfReplaceAll]);
        if length(str)>cCommentLength then str:= copy(str, 1, cCommentLength);
        s:= fnIfStr(CurrExists(ibs.FieldByName('acCRNCCODE').AsInteger),
          GetCurrName(ibs.FieldByName('acCRNCCODE').AsInteger, True), '');
        Result.Add(pGBACCN+ibs.FieldByName('acNUMBER').AsString+';'+ // � �����
          ibs.FieldByName('acCODE').AsString+';'+                    // ��� �����
          fnDateGetText(ibs.FieldByName('acDATE').AsDateTime)+';'+   // ���� �����
          fnSetDecSep(FormatFloat('# ##0.00', ibs.FieldByName('acSUMM').AsFloat))+';'+s+';'+ // �����, ������ �����
          fnIfStr(GetBoolGB(ibs, 'acPROCESSED'), '1', '0')+';'+ // ������� ��������� �����
          str+';'+ibs.FieldByName('acDPRTCODE').AsString+';'); // ����������� ��� �������, ��� ������

        ibsORD.ParamByName('ORDRGBACCCODE').AsInteger:= ibs.FieldByName('acCODE').AsInteger;
        ibsORD.ExecQuery;               // ���� ���� �� ������
        if not (ibsORD.Bof and ibsORD.Eof) then // ���;�;���� ������
          Result.Add(pNOMSTR+ibsORD.FieldByName('ORDRCODE').AsString+';'+
            fnIfStr(ibsORD.fieldByName('ORDRSOURCE').AsInteger=cosByVlad,    // ���� ����� �� Vlad
            NomZakVlad(ibsORD.fieldByName('ORDRNUM').AsString), // ��������� ����� ������ ������� (Vlad)
            ibsORD.FieldByname('ORDRNUM').AsString)+';'+ibsORD.FieldByname('ORDRDATE').AsString);
        ibsORD.Close;

        ibsW.ParamByName('acCODE').AsInteger:= ibs.FieldByName('acCODE').AsInteger;
        ibsW.ExecQuery;                  // ������ �����
        while not ibsW.EOF do begin // ��� ������;���-�� ����.;���-�� � ������;����
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
        s:= '������ �������� ���������� ������';
        Result.Add(pINFORM+s);
        prMessageLOGS(nmProc+': '+s+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
      end;
    end;
  except
    on E: Exception do begin
      s:= '������ �������� ��������� ������� � ����������';
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
//               ��������� ��������� ������� � ��������� �����
//==============================================================================
function GetDivisible(FirmCode, UserCode: String; ThreadData: TThreadData): TStringList;
const nmProc = 'GetDivisible'; // ��� ���������/�������
var i, j, FirmID: Integer;
    s: String;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetDivisib); // ��������� �����
  FirmID:= StrToIntDef(FirmCode, 0);
  j:= 0; // �������
  with Cache do try
    if not FirmExist(FirmID) then TestFirms(FirmID, True);
    for i:= 1 to High(arWareInfo) do
      if WareExist(i) then with GetWare(i) do if not IsArchive and (divis>1) then begin
        if (FirmID>0) and not CheckWareAndFirmEqualSys(i, FirmID) then Continue;
        inc(j);
        Result.Add(pKTOVAR+IntToStr(i)+';'+
          fnSetDecSep(FormatFloat('# ##0.00', divis))+';'+MeasName);
      end;
    if j<1 then begin // ���� �� �����
      s:= '������ � ��������� ������� �� �������';
      Result.Add(pINFORM+s);
      if ToLog(2) then prMessageLOGS(nmProc+': '+s, LogMail, false);
      if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, s); // ��������� � LOG ���������
    end;
  except
    on E: Exception do begin
      s:= '������ �������� ��������� �������';
      Result.Add(pINFORM+s); // ������ ��������� �� ������
      prMessageLOGS(nmProc+': '+s+', '+E.Message, LogMail, False); // ���� ����
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s, E.Message);
    end;
  end;
end;
//==============================================================================
//                         ��������� ������ � ��������� �����
//==============================================================================
function LoadingZaksOrd(FirmCode, FirmPrefix, UserCode, BegDat: String;
         zaks: array of TZakazLine; ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'LoadingZaksOrd'; // ��� ���������/�������
var i, kz, st: Integer;
    strw, snom, mess1, mess2, mess3, s: String;
    zak: array of TZakazLine;
    Accounts, Invoices: array of TDocRecArr;
    ibs: TIBSQL;
    ibd: TIBDatabase;
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cLoadingZak); // ��������� �����
  ibs:= nil;
  ibd:= nil;
  setLength(zak, 0);
  strw:= ' where (ORDRFIRM='+FirmCode+')'; // ������� ��� SQL �� ���� �����
  if (Length(BegDat)>0) then strw:= strw+' and (ORDRDATE>=:d)'; // ������� �� ��������� ����
  try
    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select ORDRCODE, ORDRNUM, ORDRSOURCE, ORDRDATE, ORDRTOPROCESSDATE, '+
      'ORDRSTATUS, ORDRSUMORDER, ORDRACCOUNTINGTYPE, ORDRCURRENCY, ORDRDELIVERYTYPE, '+
      'ORDRSTORAGECOMMENT, ORDRSTORAGE from ORDERSREESTR'+strw+' order by ORDRCODE';
    if pos(':d', ibs.SQL.Text)>0 then ibs.ParamByName('d').AsDateTime:= fnStrToDateDef(BegDat);
    ibs.ExecQuery;  // �������� � �������
    if (ibs.Bof and ibs.Eof) then begin // ���� �� �����
      Result.Add(pINFORM+'������ ��� �������� �� �������');
      mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'������ ��� �������� �� �������';
      raise Exception.Create('');
    end;
    kz:= 0;   // ���-�� ������� ��� ������
    while not ibs.Eof do begin
      snom:= ibs.fieldByName('ORDRNUM').AsString; // ������ � ������
      if ibs.fieldByName('ORDRSOURCE').AsInteger=cosByVlad then    // ���� ����� �� Vlad
        snom:= NomZakVlad(ibs.fieldByName('ORDRNUM').AsString); // ��������� ����� ������ ������� (Vlad)
      i:= FindInMassZak(zaks, snom); // ��������� � ������� ���������� � �������
      if i>-1 then snom:= ''; // ���� ����� - �� ���������
      if (length(snom)>0) and (ibs.fieldByName('ORDRCODE').AsInteger>0) then begin
        i:= length(zak);
        setLength(zak, i+1);
        if ibs.fieldByName('ORDRSOURCE').AsInteger=cosByVlad then zak[i].NomZak:= snom // ��� ������ �� Vlad - � ������ �������
        else zak[i].NomZak:= '-'+ibs.fieldByName('ORDRSOURCE').AsString; // ��� ������ � �������: -��������
        zak[i].nomstr:= ibs.fieldByName('ORDRNUM').AsString; // ���������� � ������
        zak[i].KodZak:= ibs.fieldByName('ORDRCODE').AsString; // ���������� ��� ������, ������ �������� � �����
        zak[i].izak:= ibs.fieldByName('ORDRCODE').AsInteger;
        zak[i].storage:= ibs.fieldByName('ORDRSTORAGE').AsString; // �����
        setLength(Accounts, Length(zak));
        setLength(Invoices, Length(zak));
        zak[i].Status:= ibs.fieldByName('ORDRSTATUS').AsString; // ������ ������
        try
          st:= 0;        // �������� ������ � �������� ������ ����������� ����������
          s:= fnGetClosingDocsOrd(zak[i].KodZak, Accounts[i], Invoices[i], st, ThreadData.ID);
          if s<>'' then raise Exception.Create('������ fnGetClosingDocsOrd: '+s);
          if st>0 then zak[i].Status:= IntToStr(st);
          zak[i].Checked:= True;
        except
          on E: Exception do begin
            if StrToIntDef(zak[i].NomZak, 0)>0 then snom:= zak[i].NomZak // ���� ����� �� Vlad
            else snom:= zak[i].nomstr;
            Result.Add(pINFORM+'������ ������ ���������� �� ������ N '+snom);
            mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'������ ������ ���������� �� ������ '+zak[i].nomstr+': '+E.Message;
            zak[i].Checked:= False;
          end;
        end;
        zak[i].Checked:= zak[i].Checked and (StrToIntDef(zak[i].Status, -1) in [orstProcessing..orstClosed]); // ������� ��� ��������
        if zak[i].Checked then begin     // �������, ��� ����� ����� ���������
          zak[i].OplZak:= ibs.fieldByName('ORDRACCOUNTINGTYPE').AsString; // ����� ������ ������
          zak[i].ValZak:= ibs.fieldByName('ORDRCURRENCY').AsString;       // ������ ������
          zak[i].DatZak:= fnDateGetText(ibs.fieldByName('ORDRDATE').AsDateTime); // ���� ������
          zak[i].DZakIn:= FormatDateTime(cDateTimeFormatY2N, ibs.fieldByName('ORDRTOPROCESSDATE').AsDateTime); // ���� ������ ������
          zak[i].DeliTp:= ibs.fieldByName('ORDRDELIVERYTYPE').AsString;   // ��� ��������
          zak[i].SumZak:= fnSetDecSep(FormatFloat('# ##0.00', ibs.fieldByName('ORDRSUMORDER').AsFloat)); // ����� ������ ��� ��������
          s:= StringReplace(ibs.fieldByName('ORDRSTORAGECOMMENT').AsString, #13, ' ', [rfReplaceAll]);
          s:= StringReplace(s, #10, ' ', [rfReplaceAll]);
          s:= StringReplace(s, ';', ',', [rfReplaceAll]);
          zak[i].Commnt:= copy(s, 1, 150);   // ����������
          Inc(kz);
        end;
      end;
      ibs.Next;
      cntsORD.TestSuspendException;
    end;
    ibs.Close;

    if (Length(zak)<1) or (kz<1) then begin // ���� ��� ������� ��� ��������
      Result.Add(pINFORM+'������ ��� �������� �� �������');
      mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'������ ��� �������� �� �������';
      raise Exception.Create('');
    end;
    ibs.SQL.Text:= 'select ORDRLNWARE, ORDRLNCLIENTQTY, ORDRLNPRICE'+
      ' from ORDERSLINES where ORDRLNORDER=:kod';
    ibs.Prepare;
    for i:= Low(zak) to High(zak) do
      if not zak[i].Checked then Continue else try // ���� ����� �� ����� ��������� - ����������
        ibs.ParamByName('kod').AsInteger:= zak[i].izak;
        ibs.ExecQuery;  // �������� ������ ������
        if StrToIntDef(zak[i].NomZak, 0)>0 then snom:= zak[i].NomZak // ���� ����� �� Vlad
        else snom:= zak[i].nomstr;
        if (ibs.Bof and ibs.Eof) then raise Exception.Create('��� �����'); // ���� �� ����� ������ ������
        if zak[i].DeliTp='0' then zak[i].DeliTp:= '1' else zak[i].DeliTp:= '0'; // �������� � ������������ �� �������
        s:= snom+';'+ //  � ������ ������� (��� ������ � �������: � ������ �� �������)
          zak[i].NomZak+';'+ //  � ������ ������� (��� ������ � �������: -��������)
          zak[i].SumZak+';'+zak[i].OplZak+';'+zak[i].ValZak+';'+ // �����, ����� ������, ������ ������
          zak[i].DeliTp+';'+zak[i].DatZak+';'+zak[i].Status+';'+ // ��� ��������, ����, ������
          zak[i].DZakIn+';'+zak[i].Commnt+';'+zak[i].storage+';'; // ���� ������ ������, ����������, �����
        Result.Add(pNOMSTR+s);
        while not ibs.Eof do begin  // ������ ������� ������
          Result.Add(pKTOVAR+ibs.fieldByName('ORDRLNWARE').AsString+';'+       // ��� ������
                             ibs.fieldByName('ORDRLNCLIENTQTY').AsString+';'+  // ���.���-��
                             ibs.fieldByName('ORDRLNCLIENTQTY').AsString+';'+ // ����.���-��
               fnSetDecSep(FormatFloat('# ##0.00', ibs.fieldByName('ORDRLNPRICE').AsFloat))); // ����
          ibs.Next;
        end;
        if Length(Accounts[i])>0 then begin // ������ ����������� ����������
          SetAccInvWaresToList(Accounts[i], Invoices[i], Result, ThreadData, exevers); // ������ ������ � ������� ����������� ����������
          Result.Add(pINFORM+'�������� ��������� � ������ N '+snom);
        end;
        Result.Add(pINFORM+'������� ����� N '+snom);
        mess1:= mess1+fnIfStr(mess1='', '', #13#10)+'������� ����� N '+zak[i].nomstr+'; ����� '+zak[i].SumZak;
        ibs.Close;
        cntsORD.TestSuspendException;
      except
        on E: Exception do begin
          Result.Add(pINFORM+'������ �������� ������ N: '+snom);
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'������ �������� ������: FirmCode: '+FirmCode+
            ', ����� N '+zak[i].nomstr+': '+E.Message;
        end;
      end;
  except
    on E: Exception do
      if (E.Message<>'') then begin
        mess3:= mess3+fnIfStr(mess3='', '', #13#10)+E.Message;
        Result.Add(pINFORM+'������ �������� �������');
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
  if ToLog(12) and (mess2<>'') then prSetThLogParams(ThreadData, 0, 0, 0, mess2); // ��������� � LOG ���������
  if (mess3<>'')  then prMessageLOGS(nmProc+': '+mess3, LogMail, False);
  if (mess3<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', mess3);
end;
//==============================================================================
//                    �������� ������� ������� � ��������� �����
//==============================================================================
function GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode: String; zaks: array of TZakazLine;
         ThreadData: TThreadData; exevers: String=''): TStringList;
const nmProc = 'GetStatusZaksOrd'; // ��� ���������/�������
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
  Result.Add('response:'+cStatusZaks); // ��������� �����
  ibs:= nil;
  ibd:= nil;
  try
    s:= '������ ������� �������� �������: FirmCode: '+FirmCode;
    j:= Length(zaks); // ���-�� �������
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
    kz:= 0; // ���-�� ������� ��� ������ ����������
    for i:= 0 to j-1 do try  // ��������� ������ �������
      cntsORD.TestSuspendException;

      zak[i].NomZak:= zaks[i].NomZak; // � ������ ������� (��� ������ � �������: <1)
      if StrToIntDef(zaks[i].NomZak, 0)>0 then // ���� ����� �� Vlad, ��������� � ������ �� �������
        zak[i].nomstr:= fnGetNumOrder(FirmPrefix, zaks[i].NomZak)
      else zak[i].nomstr:= zaks[i].nomstr;

      with ibs.Transaction do if not InTransaction then StartTransaction;
      ibs.ParamByName('p0').AsString:= zak[i].nomstr;
      ibs.ExecQuery;
      if (ibs.Bof and ibs.Eof) then begin // ���� �� �����
        zak[i].KodZak:= '0';
        zak[i].izak:= 0;
        mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'FirmCode: '+FirmCode+', '+
          MessText(mtkNotFoundOrder)+' N '+zak[i].nomstr; // � ������ �� �������
        Result.Add(pINFORM+MessText(mtkNotFoundOrder)+' N '+zaks[i].nomstr); // � ������ �� �������
        Result.Add(pNOMSTR+zaks[i].nomstr+';'+IntToStr(orstNoDefinition));

      end else begin
        zak[i].KodZak:= ibs.fieldByName('ORDRCODE').AsString; // ���� ��� ������������� � Grossbee
        zak[i].izak:= ibs.fieldByName('ORDRCODE').AsInteger;  // � ��� ������ ����� �������
        zak[i].Status:= ibs.fieldByName('ORDRSTATUS').AsString;         // ������ ������
        zak[i].DZakIn:= FormatDateTime(cDateTimeFormatY2N, ibs.fieldByName('ORDRTOPROCESSDATE').AsDateTime); // ���� ������ ������
        zak[i].storage:= ibs.fieldByName('ORDRSTORAGE').AsString;
        if ibs.fieldByName('ORDRSTATUS').AsInteger=orstAnnulated then
          zak[i].Commnt:= ibs.fieldByName('ORDRANNULATEREASON').AsString; // ������� ���������
        try
          st:= 0;        // �������� ������ � �������� ������ ����������� ����������
          s:= fnGetClosingDocsOrd(zak[i].KodZak, Accounts[i], Invoices[i], st, ThreadData.ID);
          if s<>'' then raise Exception.Create('������ fnGetClosingDocsOrd: '+s);
          if st>0 then zak[i].Status:= IntToStr(st);
        except
          on E: Exception do begin
            Result.Add(pINFORM+'������ ������ ���������� �� ������ N '+zaks[i].nomstr);
            mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'������ ������ ���������� �� ������ '+zak[i].nomstr+': '+E.Message;
          end;
        end;
        mess1:= mess1+fnIfStr(mess1='', '', #13#10)+'FirmCode: '+FirmCode+', ������� ������ ������ N: '+zak[i].nomstr;
        Result.Add(pINFORM+'������� ������ ������ N '+zaks[i].nomstr);
        Result.Add(pNOMSTR+zaks[i].nomstr+';'+zak[i].Status+';'+ // � ������ �� �������;������ ������;
                           zak[i].DZakIn+';'+zak[i].Commnt+';'+zak[i].storage+';'); // ���� ������ ������, ������� ���������, �����
        zak[i].Checked:= True; // �������, ��� �� ������ ����� ������� ���-��
        Inc(kz);
      end;
    finally
      ibs.Close;
    end;

    if kz>0 then begin // ������� ����������
      Result.Add('response:'+cFactSumZak);
      for i:= 0 to j-1 do
        if not zak[i].Checked then Continue // ���� �� ������ �� ����� ������� ���-�� - ����������
        else if Length(Accounts[i])>0 then try // ������ ����������� ����������
          Result.Add(pNOMSTR+zaks[i].nomstr+';'+zak[i].NomZak); // � ������ �� �������;� ������ �� ������� - ��� ������������� � ��������� �������
          SetAccInvWaresToList(Accounts[i], Invoices[i], Result, ThreadData, exevers); // ������ ������ � ������� ����������� ����������
          Result.Add(pINFORM+'�������� ��������� � ������ N '+zaks[i].nomstr);
        except
          on E: Exception do mess3:= mess3+fnIfStr(mess3='', '', #13#10)+
            'FirmCode: '+FirmCode+', ������ ������ ������ N: '+zak[i].nomstr; // � ������ �� �������
        end;
    end; // if kz>0
  except
    on E: Exception do begin
      Result.Add(pINFORM+'������ ������� �������� �������');
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
//                 ���������� � �� ����� ����� � ��������� �����
//==============================================================================
function AddNewZaksOrd(FirmCode, FirmPrefix, UserCode: String; zak: TZakazLine;
         zakln: array of TWareLine; ThreadData: TThreadData; exevers: String=''): TStringList;
// ���������� True, ���� ��� ���������� ���������
const nmProc = 'AddNewZaksOrd'; // ��� ���������/�������
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
procedure FreeZakaz(skod: String); // ������� ��������� ������
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
      mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'����� SQL: '+_ibs.SQL.Text+' - '+E.Message;
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
  messzak:= '������ ������ ������ N '+zak.NomZak;
  setLength(ar, 0);
  setLength(wkodes, 0);
  Result:= TStringList.Create;
  Body:= TStringList.Create;
  ibs:= nil;
  ibd:= nil;
  Stream:= nil;
  contID:= 0;
  with Cache do try
    Result.Add('response:'+cAddNewZaks); // ��������� �����
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
      zak.nomstr:= fnGetNumOrder(FirmPrefix, zak.NomZak); // ��������� ����� ������ �� �������
      if zak.nomstr='' then raise Exception.Create(MessText(mtkNotValidParam)+' - N ������');

      ibd:= cntsORD.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpWrite, true);
      ibs.SQL.Text:= 'select rORDRDATE as ORDRDATE, rMaxOrderNum'+
        ' from TestVladOrderNum('+FirmCode+', :Nzak)'; // ��������� ������������ � ������
      ibs.ParamByName('Nzak').AsString:= zak.nomstr;
      ibs.ExecQuery;
      if not (ibs.Bof and ibs.Eof) and (ibs.FieldByName('rMaxOrderNum').AsInteger>0) then begin
        Result.Add(pINFORM+'�������� ������ N '+zak.nomstr); // ������ � �����
        Result.Add(pINFORM+'�� ������� ���� ��� ����� N '+zak.nomstr+' �� '+
          fnDateGetText(ibs.FieldByName('ORDRDATE').AsDateTime)); // ������ � �����
        if (TDate(ibs.FieldByName('ORDRDATE').AsDateTime)<>TDate(fnStrToDateDef(zak.DatZak))) then begin
          Result.Add(pINFORM+'��� ��������� N ������ �� ������� - '+
            ibs.FieldByName('rMaxOrderNum').AsString); // ������ � �����
          Result.Add(pINFORM+'�������� ����� � �������������� ������'); // ������ � �����
        end;
        mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'�������� ������ N '+zak.nomstr;
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

      if zak.DeliTp='' then zak.DeliTp:= '1'; // ��� �������� �� ��������� (�������������)
      dat:= fnStrToDateDef(zak.DatZak, Date);
      datw:= DateNull;
      s1:= '';
      s2:= '';
      if (zak.OplZak='1') and (zak.Warrnt<>'') then begin   // (ORDRACCOUNTINGTYPE=1)
        ar:= fnSplitString(ExtractParametr(zak.Warrnt));   // ��������� ������������ - � ������
        if length(ar)>0 then s1:= ar[0];
        if length(ar)>1 then datw:= fnStrToDateDef(ar[1]);
        if length(ar)>2 then s2:= ar[2];
      end;
      if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
      ibs.SQL.Text:= 'select rNewOrderCode, rDate from CreateNewOrderHeader(:ORDRNUM, '+
        // ��� �����(0-���, 1-�/���), ������, ��� ������, ��������, ��� �����, ��� ��������
        zak.OplZak+', '+sdprt+', '+zak.storage+', '+IntToStr(cosByVlad)+', '+FirmCode+', '+zak.DeliTp+', '+
        zak.ValZak+', :ORDRWARRANT, :ORDRWARRANTDATE, :ORDRWARRANTPERSON, '+  // ��� ������, ...
        IntToStr(orstProcessing)+', :ORDRSTORAGECOMMENT, :ORDRDATE, '+UserCode+')';        // ..., ��������� ������
      ibs.ParamByName('ORDRNUM').AsString           := zak.nomstr;      // � ������
      ibs.ParamByName('ORDRWARRANT').AsString       := s1;              // ������������
      ibs.ParamByName('ORDRWARRANTDATE').AsDateTime := datw;            // ���� ������������
      ibs.ParamByName('ORDRWARRANTPERSON').AsString := s2;              // ���� ������ ������������
      ibs.ParamByName('ORDRSTORAGECOMMENT').AsString:= zak.Commnt;      // ����������
      ibs.ParamByName('ORDRDATE').AsDateTime        := dat;             // ���� ������
      for i:= 1 to RepeatCount do // ���������� ��������� ������ (������� RepeatCount ���)
        try
          if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
          ibs.ExecQuery;
          if (ibs.Bof and ibs.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
          zak.KodZak:= ibs.fieldByName('rNewOrderCode').AsString;  // ��� ������
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
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'������ ������ ��������� ������, ������� '+IntToStr(i);
              sleep(RepeatSaveInterval);
            end else begin
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+E.Message;
              raise Exception.Create(messzak);
            end;
          end;
        end;

      mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'���������� ��������� ������ '+
        GetLogTimeStr(LocalThreadStart);
      LocalThreadStart:= now();

      ferr:= True; // ���� ������ ������ ������                // ������ �������
      kt:= 0;       // ������� ����� �������
      if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
      ibs.SQL.Text:= 'select rNewOrderLnCode from AddOrderLineQty('+zak.KodZak+', '+   // ..., ��� ������
        ':ORDRLNWARE, :ORDRLNCLIENTQTY, :ORDRLNMEASURE, :ORDRLNPRICE, '+zak.storage+', 0)';  // ..., ��� ������
      ibs.Prepare;
      for i:= Low(zakln) to High(zakln) do begin // ���������� ������ ������� ������
        Ware:= GetWare(StrToIntDef(zakln[i].WCode, 0), True);
        s:= '';
        if Ware=NoWare then
          s:= '������ ������ � ����� ������ - �� ������ ��� '+zakln[i].WCode
        else if not fnNotZero(Ware.RetailPrice) then  // ������� �� ������������ ������� �������
          s:= '������ ������ � ����� ������ '+StringReplace(Ware.Name, '  ', ' ', [rfReplaceAll])+' - ��� ����';
        if s<>'' then begin
          Result.Add(pINFORM+s); // ������ � �����
          Result.Add(pERRCOD+zakln[i].WCode+';'+zak.NomZak); // ������ � ����� � ����� ������
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+s;
          ferr:= False;
          Body.Add(s);
          Continue;
        end;
        
        ibs.ParamByName('ORDRLNWARE').AsString    := zakln[i].WCode;  // ��� ������
        ibs.ParamByName('ORDRLNMEASURE').AsString := zakln[i].Wdocm;  // ��� ��.���.
        ibs.ParamByName('ORDRLNCLIENTQTY').AsFloat:= StrToFloatDef(zakln[i].WKolv, 0); // ���-��
        ibs.ParamByName('ORDRLNPRICE').AsFloat    := StrToFloatDef(zakln[i].WCena, 0); // ����
        for j:= 1 to RepeatCount do try //  ������� �������� ����� RepeatCount ���
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
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'������ ������ ������ ������: ��� '+zakln[i].WCode+', ������� '+IntToStr(j);
              sleep(RepeatSaveInterval);
            end else begin
              s:= StringReplace(Ware.Name, '  ', ' ', [rfReplaceAll]); // ������� �� ������������ ������� �������
              Result.Add(pINFORM+'������ ������ ������ '+s); // ������ � �����
              Result.Add(pERRCOD+zakln[i].WCode+';'+zak.NomZak); // ������ � ����� � ����� ������
              mess3:= mess3+fnIfStr(mess3='', '', #13#10)+
                '������ ������ ������ ������: ��� '+zakln[i].WCode+', '+s+#13#10+E.Message;
              ferr:= False;
              Body.Add('������ ������ ������ ������: ��� '+zakln[i].WCode+', '+s);
            end;
          end; // on E: Exception
        end; // for j:= 1 to RepeatCount
      end; // for i:=

      mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'���������� ������ ������� ������ '+
        GetLogTimeStr(LocalThreadStart);
      LocalThreadStart:= now();

      if (Body.Count>0) then begin
        Body.Add('Error save order: FirmCode: '+FirmCode+', order N '+zak.NomZak);
        s:= fnGetSysAdresVlad(caeOnlyDayLess);
        Body.Insert(0, GetMessageFromSelf);
        s:= n_SysMailSend(s, 'Error save order', Body, nil, '', '', true); // ��������� ��������� ������ ��-�� Vlad
        if s<>'' then begin
          prMessageLOGS(nmProc+': ������ �������� ������ �� ������ ������ ������: '#13#10+s, LogMail, false);
          fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ �������� ������ �� ������ ������ ������', s);
        end;
      end;
      if not ferr then  // ���� ���� ������
        if kt>0 then begin // ���� ���� ������, �� � ������ ���� ������
          Result.Add(pINFORM+'����� N '+Zak.NomZak+': ������� '+IntToStr(kt)+' �����');
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'����� N '+Zak.NomZak+': ������� '+IntToStr(kt)+' �����';
        end else begin // ���� ���� ������ � � ������ ��� �����
          FreeZakaz(zak.nomstr);
          Result.Add(pINFORM+'����� N '+Zak.NomZak+' � ��������� �� ������');
          Result.Add(pNOMSTR+Zak.NomZak+';'+IntToStr(orstNoDefinition));
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'����� N '+Zak.NomZak+' � ��������� �� ������';
          Exit;
        end;

      ferr:= True;              // ���������, ���� �� ����� ����������� ����
      zak.Checked:= FirmExist(FirmID) and arFirmInfo[FirmID].SKIPPROCESSING;
  //    zak.Checked:= False;  // ��� ������� TCheckStoppedOrders
      if zak.Checked then try // ���� ���� ����������� ����
        Stream:= TBOBMemoryStream.Create;
        Stream.WriteInt(zak.izak);
        Stream.WriteBool(False); // �� ��������� ��������� ��������

        prOrderToGBn_Ord(Stream, ThreadData, True); // ��������� ����

        mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'���������� ���� '+
          GetLogTimeStr(LocalThreadStart);
        LocalThreadStart:= now();
        Application.ProcessMessages;

        Stream.Position:= 0;
        jj:= Stream.ReadInt;
        if (jj in [aeSuccess, erWareToAccount]) then begin
          if jj=erWareToAccount then begin // ���� ���� �������, �� ���� ������ ��� ������ �������
            Body.Clear;
            s:= Stream.ReadStr;
            Body.Text:= s;
            if Body.Count>0 then for i:= 0 to Body.Count-1 do
              Result.Add(pINFORM+Body.Strings[i]); // �������� �������� ������
          end;

          setLength(zaks, 1);
          zaks[0].NomZak:= zak.NomZak;
          zaks[0].nomstr:= zak.NomZak;
          Body.Clear;
          Body:= GetStatusZaksOrd(FirmCode, FirmPrefix, UserCode, zaks, ThreadData, exevers);
          if Body.Count>0 then for i:= 0 to Body.Count-1 do Result.Add(Body.Strings[i]);
          ferr:= False;
          mess5:= mess5+fnIfStr(mess5='', '', #13#10)+'�������� ��������� � ������ '+
            GetLogTimeStr(LocalThreadStart);
        end else begin
          s:= Stream.ReadStr;
          raise Exception.Create(s);
        end;
      except
        on E: Exception do begin
          mess3:= mess3+fnIfStr(mess3='', '', #13#10)+'������ ������������ ����� �� ������ N '+zak.NomZak+' - '#13#10+E.Message;
          Body.Clear; // ��������� ��������� ������ ��-�� Vlad
          Body.Add(GetMessageFromSelf);
          Body.Add('Error save account: FirmCode: '+FirmCode+', order N '+zak.NomZak);
          s:= fnGetSysAdresVlad(caeOnlyDayLess);
          s:= n_SysMailSend(s, 'Error save account', Body, nil, '', '', true);
          if (s<>'') then begin
            s1:= '������ �������� ������ �� ������ ������������ �����';
            prMessageLOGS(nmProc+': '+s1+': '#13#10+s, LogMail, false);
            fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, s1, s);
          end;
        end;
      end;

      if ferr then begin
        Result.Add(pINFORM+'����� N '+zak.NomZak+' �� ���������');
        Result.Add(pINFORM+'����� ��������� ������ ������ N '+zak.NomZak);
        Result.Add(pNOMSTR+zak.NomZak+';'+IntToStr(orstProcessing)+';'+zak.DZakIn);
        mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'����� N '+zak.NomZak+
          ' �� ��������� ('+IntToStr(Length(zakln))+' �����)';
      end else begin
        Result.Add(pINFORM+'����� N '+zak.NomZak+' ������');
        mess2:= mess2+fnIfStr(mess2='', '', #13#10)+'����� N '+zak.NomZak+
          ' ������ ('+IntToStr(kt)+' �����)';
      end;
    except
      on E: Exception do if E.Message<>'' then begin
        Result.Add(pINFORM+messzak); // ������ � �����
        mess3:= mess3+fnIfStr(mess3='', '', #13#10)+messzak+': '+E.Message;
      end;
    end;
    mess5:= '������������ ����� ('+IntToStr(Length(zakln))+' �����) '+
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
    if ToLog(12) and (mess2<>'') then prSetThLogParams(ThreadData, 0, 0, 0, mess2); // ��������� � LOG ���������
    if ToLog(5) and (mess5<>'') then prMessageLOGS(nmProc+': '+mess5, LogMail, false);
    if ToLog(15) and (mess5<>'') then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, mess5);
    if (mess3<>'') then prMessageLOGS(nmProc+': '+mess3, LogMail, false);
    if (mess3<>'') then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '', mess3);
  end;
end;

//================================================ ����� � �������� ����� ������
function ReportReLoadVers(FirmCode, UserCode: String; mess: TStringList; ThreadData: TThreadData): Boolean;
const nmProc = 'ReportReLoadVers'; // ��� ���������/�������
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
    fnStringsLogToFile(mess, nf); // ���������� ����� � ����
    Result:= true;
  except end;
end;
//=============================================== ������ ���������� ������� ����
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
