unit n_vlad_files_func;
//******************************************************************************
//        ������ ��� ��������� ���� � ������� � ������������� ������
//******************************************************************************
interface
uses Windows, Classes, SysUtils, Math, Variants, DateUtils, Forms, IniFiles,
    IBDataBase, IBSQL, adstable, adscnnct, adsset, ADODB, ActiveX,// ��� ��������� ������
    n_free_functions, n_constants, n_Functions, n_server_common,
    n_func_ads_loc, n_DataCacheObjects, n_DataCacheInMemory,
    n_DataSetsManager, n_LogThreads, n_MailServis, v_constants;

var
  AdsSettings: TAdsSettings;
  arVladStores: array of TColumnInfo; // ������ ���� ������� ������� ��� ������������ ������ Vlad

  procedure CreateAdsSettings;
  procedure FreeAdsSettings;
  procedure FormVladONFiles;  // ������������ ������ ������������ ������� Vlad
  procedure FormVladTables; // ������������ ������ Vlad (base.dbf � ���������)
  function GetNeedFormVladBase: Boolean; // ������� ������������� ��������������� ������� Vlad
  function TestChangeRestCols: Boolean; // ��������� / ��������� ���� �������
  function TestRestAndPrice(ThreadData: TThreadData=nil): Boolean; // ��������� / ��������� ���� �������� � ��� �� ���� �������
  function TestBaseRestAndPrice(ThreadData: TThreadData): Boolean; // ��������� ���� � ������� � base.dbf
  function FirmRestAndPrice(FirmCode, nfrest, cits: string; ThreadData: TThreadData): Boolean; // ��������� ���� - ������ �������� � ��� �������
  function FirmBaseRestCols(FirmCode, nf, tmpdir, exevers: string; ThreadData: TThreadData): Boolean; // ��������� base.dbf � ��������� �������
  function ReportCheck(FirmCode, UserCode, BegDat: String; var nfzip: string; ThreadData: TThreadData): TStringList; // ������ �� �����
//  function GetWaresPgrFilterStr: string;
//  function GetWaresNotInfoFilterStr: string;

implementation

uses n_vlad_common;
//==============================================================================
procedure CreateAdsSettings;
begin
  AdsSettings:= TAdsSettings.Create(nil);
  AdsSettings.ShowDeleted:= True;  // ����� ��� �������� � dbf �� ���������� �� ����.������
end;
//==============================================================================
procedure FreeAdsSettings;
begin
  if Assigned(AdsSettings) then prFree(AdsSettings);
end;
//==============================================================================
function GetWaresPgrFilterStr: string;
begin
  Result:= ' inner join VLADPGR pg on pg.KODPGR=w.waremastercode'+
           ' and w.warearchive="F" and w.WARECHILDCOUNT=0';
end;
//==============================================================================
function GetWaresNotInfoFilterStr: string;
begin
  Result:= ' inner join VLADGR g on g.KODGR=pg.KODGR and g.KODTG='+IntToStr(codeTovar);
end;
//=========================== ������� ������������� ��������������� ������� Vlad
function GetNeedFormVladBase: Boolean;
const nmProc = 'GetNeedFormVladBase'; // ��� ���������/�������/������
var ibdGb: TIBDatabase;
    ibsGB: TIBSQL;
    s: string;
    vfIniFile: TINIFile;
    FileDateTime: TDateTime;
begin
  Result:= False;
  ibsGB:= nil;
  with Cache do try
    if not AllowVladMail or (FormBaseInterval<1) then exit;
    vfIniFile:= TINIFile.Create(nmIniFileBOB);
    try
      if LastBaseTime=DateNull then begin// ��� �������� ����� ����� �� ini-�����
        LastBaseTime:= vfIniFile.ReadDateTime('VladTables', 'LastBaseTime', DateNull);
        if LastBaseTime=DateNull then begin // ���� �� ���������� - ����� �����
          s:= FormVladPath+nAnalogs;        // ����.������������ �� ����� ��������
          if FileAge(s, FileDateTime) then LastBaseTime:= FileDateTime;
          vfIniFile.WriteDateTime('VladTables', 'LastBaseTime', LastBaseTime);
        end;
      end;

      if (Now<IncMinute(LastBaseTime, FormBaseInterval)) then exit; // ��� ���� ���������

      if TestChangeRestCols and // ��������� ���� �������
        FileAge(fnTestDirEnd(PathRests)+colsFname+'.dbf', FileDateTime) then
          Result:= (FileDateTime>LastBaseTime);

      if not Result then begin
        ibdGb:= cntsGRB.GetFreeCnt;
        ibsGB:= fnCreateNewIBSQL(ibdGb, 'ibsGBr_'+nmProc, -1, tpRead, True);
        try                          // ��������� ��������� � ������������
          ibsGB.SQL.Text:= 'select count(*) from'+
            ' (select WAREALTERWARECODE kod from WAREALTER'+
            ' inner join wares w on w.WARECODE=WAREALTERWARECODE'+
            GetWaresPgrFilterStr+' where warealtertime>:Time1'+
            ' union select VGALTERKODGR kod from VLADGRALTER where VGALTERDATE>:Time2)';
          ibsGB.ParamByName('Time1').AsDateTime:= IncMinute(LastBaseTime, -5); // ��� ���������
          ibsGB.ParamByName('Time2').AsDateTime:= ibsGB.ParamByName('Time1').AsDateTime;
          ibsGB.ExecQuery;     // ��������� ������ ����� ���������� �������� ��� �������
          Result:= not (ibsGB.Eof and ibsGB.Bof) and (ibsGB.Fields[0].AsInteger>0);
        finally
          prFreeIBSQL(ibsGB);
          cntsGRB.SetFreeCnt(ibdGb);
        end;
      end;
      if not Result then begin // ����������������� �� ���� - ��������� ����� ��������
        LastBaseTime:= Now;
        vfIniFile.WriteDateTime('VladTables', 'LastBaseTime', LastBaseTime);
      end;
    finally
      prFree(vfIniFile);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache, False);
  end;
end;
//================================ ������������ ������ ������������ ������� Vlad
procedure FormVladONFiles;
const nmProc = 'FormVladONFiles'; // ��� ���������/�������/������
var grName, pgrName, wName, s: string;
    i, itg, igr, ipgr, k, BrONCode, j, jj, ion: LongInt;
    ip: Integer;
    LocalStart: TDateTime;
    arMfau, ar: Tai;
    AConnLoc: TAdsConnection;
    aqloc: TAdsQuery;
    atG: TAdsTable;
    lstW: TStringList;
    fs: TFileStream;
begin
  if not Assigned(Cache) then Exit;
  LocalStart:= now();
  AConnLoc:= nil;
  aqloc:= nil;
  atG:= nil;
  SetLength(ar, 0);
  SetLength(arMfau, 0);
  lstW:= nil;
  with Cache do try
    try                                            // ������� ������ �����
      DeleteFile(FormVladPath+nfOrgNumsTab); // ���� ������������ ������� Vlad
      DeleteFile(FormVladPath+nfOrgNums);    // ���� ������ ������������ ������� Vlad
      fs:= TFileStream.Create(FormVladPath+nfOrgNums, fmCreate); // ���� ������ ������������ �������
      try
        itg:= 0; // ������������ MFAUCODE
        lstW:= FDCA.Manufacturers.GetOEManufList; // ������������� ������ �������������� � ��
        with lstW do for i:= 0 to Count-1 do begin
          ip:= Integer(Objects[i]);
          if itg<ip then itg:= ip;
          TestCssStopException;
        end;
        SetLength(arMfau, itg+1);
        BrONCode:= length(arWareInfo)+100000; // ��������� ������ ��� ��� �������������

        fs.Position:= 0;
        fs.Write(LongInt(BrONCode), sizeof(LongInt)); // ���������� ��� ������ ������������ �������
        i:= 0; // ������� MFAUCODE
        itg:= fs.Position;
        fs.Write(LongInt(i), sizeof(LongInt)); //  ����� ��� ���-�� �������������� ����
        for k:= 0 to lstW.Count-1 do begin
          ipgr:= LongInt(lstW.Objects[k]);
          inc(i);
          arMfau[ipgr]:= BrONCode+i; // ��� ��� �������������
          fs.Write(LongInt(arMfau[ipgr]), sizeof(LongInt)); // ���������� ��� ������������� ������������� ����
          grName:= fnCodeString(Byte('S'), lstW.Strings[k]); // ��������
          fnStreamWriteAnsiString(fs, grName); // ���������� ����. ������������� ����
//          fnStreamWriteString(fs, grName); // ���������� ����. ������������� ����
          TestCssStopException;
        end;
        if i>0 then begin
          k:= fs.Position;
          fs.Position:= itg;
          fs.Write(LongInt(i), sizeof(LongInt)); // ���������� ���-�� �������������� ����
          fs.Position:= k;
        end;
        lstW.Clear;
        wName:= IntToStr(i)+'�.��.,';

        BrONCode:= BrONCode+i+10; // ��������� ������ ��� ��� �������������
        with FDCA do for k:= 0 to High(arOriginalNumInfo) do begin
          if OrigNumExist(k) then with GetOriginalNum(k) do
            if (trim(OriginalNum)<>'') and (Links.LinkCount>0) then // ���� ���� ������ �� ����� ����.������
              lstW.AddObject(OriginalNum, Pointer(ID));
          TestCssStopException;
        end;
        lstW.Sort; // ��������� �� ������.������

        try
          AConnLoc:= CreateLocalAdsConnection(FormVladPath); // ������� ��������� AdsConnection
          AConnLoc.Connect;
          aqloc:= NewLocalADSQuery(AConnLoc);
          aqloc.SQL.Text:= 'create table "'+nfOrgNumsTab+
            '" (KOD integer, KODPGR integer, NAME char(50), INDAT date)'; // ���� ������������ �������
          aqloc.ExecSQL;
          aqloc.AdsCloseSQLStatement;

          atG:= NewLocalAdsTable(nfOrgNumsTab, AConnLoc);
          atG.Exclusive:= True;
          atG.Open;
          i:= 0; // ������� ����.�������
          j:= 0; // ������� ������
          itg:= fs.Position;
          fs.Write(LongInt(j), sizeof(LongInt)); //  ����� ��� ���-�� ������
          for k:= 0 to lstW.Count-1 do begin
            ipgr:= Integer(lstW.Objects[k]);          // ��� ����.������
            igr:= FDCA.GetOriginalNum(ipgr).MfAutoID; // ��� �������������
            if (Length(arMfau)>igr) and (arMfau[igr]>0) then begin
              inc(i);  // ������� ����.�������
              ion:= BrONCode+i; // ��� ��� �������������
              atG.AppendRecord([ion, arMfau[igr], lstW.Strings[k], Null]);
      // ion - ��� �������-�� ����.������, arMfau[igr] - ��� �������-�� ������.����, lstW.Strings[k] - ����.�����
              ar:= FDCA.GetOriginalNum(ipgr).Links.GetLinkCodes;
              for jj:= Low(ar) to High(ar) do begin
                igr:= ar[jj];  // ��� ������
                if WareExist(igr) and not GetWare(igr).IsArchive then begin
                  fs.Write(LongInt(ion), sizeof(LongInt)); // ���������� ��� ������������� ������.������
                  fs.Write(LongInt(igr), sizeof(LongInt)); // ���������� ��� ������
                  inc(j); // ������� ������
                end;
              end;
            end;
            TestCssStopException;
          end;
          atG.Close;
          atG.Exclusive:= False;
        finally
          AConnLoc.Disconnect;
          prFreeADSQuery(aqloc);
          prFree(atG);
          prFree(AConnLoc);
        end;

        if j>0 then begin
          fs.Position:= itg;
          fs.Write(LongInt(j), sizeof(LongInt)); // ���������� ���-�� ������
        end;
        lstW.Clear;
      finally
        fs.Position:= 0;
        prFree(fs);
      end;

//------------------------------------------------------ ������� � ������ ������
      grName:= FormVladPath+nfziporgnum+'.zip'; // ��� ������
      pgrName:= FormVladPath+nfOrgNums+','+FormVladPath+nfOrgNumsTab; // ����� ������
      s:= ZipAddFiles(grName, pgrName);
      if (s<>'') then raise Exception.Create(s);
      CScache.Enter;
      try
        CopyFile(PChar(grName), PChar(VladZipPath+nfziporgnum+'.zip'), False);
      finally
        CSCache.Leave;
      end;
    except
      on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
    if ToLog(3) then prMessageLOGS(nmProc+': '+IntToStr(i)+'�.�.,'+IntToStr(j)+
      '��. - '+GetLogTimeStr(LocalStart), fLogCache, False);
  finally
    SetLength(arMfau, 0);
    SetLength(ar, 0);
    prFree(lstW);
  end;
  TestCssStopException;
end;
//=========================================== ��������� / ��������� ���� �������
function TestChangeRestCols: Boolean;
const nmProc = 'TestChangeRestCols'; // ��� ���������/�������
var locAQuery: TAdsQuery;
    atloc: TAdsTable;
    locAdsConnection: TAdsConnection;
    arr: array of TColumnInfo;
    i, j: Integer;
    s, nfCols, nftmpCols, dir, dirtmp: string;
    arData: TVarRecArray;
    flagForm: Boolean;
begin
  Result:= False;
  locAdsConnection:= nil;
  locAQuery:= nil;
  atloc:= nil;
  setlength(arr, 0);
  setlength(arData, 0);
  dir:= PathRests;
  dirtmp:= fnTestDirEnd(fnCreateTmpDir(dir));
  nfCols:= colsFname+'.dbf';
  nftmpCols:= '_tmpcols.dbf';
  with Cache do try
    locAdsConnection:= CreateLocalAdsConnection(dirtmp); // ������� ��������� AdsConnection ��� ��������� dbf
    locAQuery:= NewLocalADSQuery(locAdsConnection);
    atloc:= NewLocalAdsTable(nftmpCols, locAdsConnection);
    flagForm:= not FileExists(dir+nfCols); // ���� - �����������
       // ��� �������� ��������� ������ ���� ������� ������� �� ������� �������
    if not flagForm and (length(arVladStores)<1) then begin
      CopyFile(PChar(dir+nfCols), PChar(dirtmp+nftmpCols), False); // �������� ������� �������
      Setlength(arVladStores, 10);
      locAdsConnection.Connect;
      atloc.Open;
      j:= 0;
      while not atloc.Eof do begin
        if High(arVladStores)<j then SetLength(arVladStores, j+10);
        with arVladStores[j] do begin
          Kod:= atloc.FieldByName('KOD').AsInteger;
          codes:= atloc.FieldByName('KOD').AsString;
          Field:= atloc.FieldByName('FIELD').AsString;
          short:= atloc.FieldByName('SHORT').AsString;
          sHint:= atloc.FieldByName('HINT').AsString;
          size:= atloc.FieldByName('SIZE').AsInteger;
        end;
        inc(j);
        TestCssStopException;
        atloc.Next;
      end;
      atloc.Close;
      locAdsConnection.Disconnect;
      if Length(arVladStores)>j then SetLength(arVladStores, j);
    end; // with RespThread

    j:= 0;
    for i:= 1 to length(arDprtInfo)-1 do // ���.������ ������� �� ����
      if DprtExist(i) and arDprtInfo[i].IsStoreHouse then begin
        if High(arr)<j then SetLength(arr, j+10);
        arr[j].Kod:= i;
        s:= IntToStr(i);
        arr[j].codes:= s;
        arr[j].Field:= 'r'+s;
        arr[j].short:= GetDprtColName(i);
        arr[j].sHint:= GetDprtMainName(i);
        arr[j].size:= 1;
        inc(j);
      end;
    if Length(arr)>j then SetLength(arr, j);
    TestCssStopException;

    with RespThread do begin // ��������� ������ ������� ������ �� ���.�������
      if not flagForm then flagForm:= (Length(arr)<>Length(arVladStores));
      if flagForm then setlength(arVladStores, Length(arr)); // ���� - �����������
      for i:= 0 to High(arr) do begin          
        if (arVladStores[i].Kod<>arr[i].Kod)
          or (arVladStores[i].Field<>arr[i].Field)
          or (arVladStores[i].short<>arr[i].short)
          or (arVladStores[i].sHint<>arr[i].sHint)
          or (arVladStores[i].size<>arr[i].size) then begin
          arVladStores[i].Kod:= arr[i].Kod;
          arVladStores[i].codes:= arr[i].codes;
          arVladStores[i].Field:= arr[i].Field;
          arVladStores[i].short:= arr[i].short;
          arVladStores[i].sHint:= arr[i].sHint;
          arVladStores[i].size:= arr[i].size;
          if not flagForm then flagForm:= True;
        end;
      end;
    end; // with RespThread
    TestCssStopException;

    if flagForm then begin  // ���� �����������
      DeleteFile(dirtmp+nftmpCols); // ������� ��������� ������� �������
      locAdsConnection.Connect;
      locAQuery.SQL.Text:= 'create table "'+nftmpCols+'" '+ // ������ tmpcols51.dbf
        '(KOD integer, FIELD CHAR(8), TITLE CHAR(15), SHORT CHAR(6), HINT CHAR(30),'+
        'DEF CHAR(1), RES CHAR(1), CLIENT CHAR(1), SIZE INTEGER)';
      locAQuery.ExecSQL;
      locAQuery.AdsCloseSQLStatement;
      atloc.TableName:= nftmpCols;
      atloc.Exclusive:= True; // ������� ��������� ������� �������
      atloc.Open;
      SetLength(arData, 9);
      try
        arData[0].VType:= vtInteger;
        arData[8].VType:= vtInteger;
        for i:= 1 to 7 do begin
          arData[i].VType:= vtAnsiString;
          arData[i].VAnsiString:= nil;
          AnsiString(arData[i].VAnsiString):= AnsiString('');
        end;
        for i:= 0 to High(arr) do begin
          arData[0].VInteger:= arr[i].Kod;
          AnsiString(arData[1].VAnsiString):= AnsiString(arr[i].Field);
          AnsiString(arData[3].VAnsiString):= AnsiString(arr[i].short);
          AnsiString(arData[4].VAnsiString):= AnsiString(arr[i].sHint);
          arData[8].VInteger:= arr[i].size;
          atloc.AppendRecord(arData);
        end;
      finally
        arData[0].VInteger:= 0;
        for i:= 1 to 7 do arData[i].VAnsiString:= nil;
        arData[8].VInteger:= 0;
        SetLength(arData, 0);
      end;
      atloc.AdsFlushFileBuffers;
      atloc.Close;
      locAdsConnection.Disconnect;
      CScache.Enter;
      try
        DeleteFile(dir+nfCols); // ������� ������ ������� �������
        RenameFile(dirtmp+nftmpCols, dir+nfCols);
      finally
        CSCache.Leave;
      end;
    end;
    Result:= True;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
  end;
  setlength(arr, 0);
  prFreeADSQuery(locAQuery);
  prFreeAdsTable(atloc);
  if assigned(locAdsConnection) then locAdsConnection.Disconnect;
  prFree(locAdsConnection);
  DeleteFile(dirtmp+nftmpCols); // ������� ��������� ������� �������
  fnDeleteTmpDir(dirtmp);
end;
//================= ��������� / ��������� ���� �������� � ��� �� ������� �������
function TestRestAndPrice(ThreadData: TThreadData=nil): Boolean;
// ���������� ������� ��������� ������ ��������
const nmProc = 'TestRestAndPrice'; // ��� ���������/�������
type
  SysRestData = record
    SysID: integer;
    SysRests: string;
    tmpSysRests: string;
    atlocSys: TAdsTable;
  end;
var locAQuery: TAdsQuery;
    atloc: TAdsTable;
    locAdsConnection: TAdsConnection;
    ibdGb: TIBDatabase;
    ibsGB: TIBSQL; // ������� �� ������� ������� (������ ���� 5.1.x � ������)
    i, j, k, kod, iPr, RestCount, Interval: Integer;
    s, dir, dirtmp, sRestFields, sRestJoins: string;
    flagForm, flagTestPrice: Boolean;
    LocalThreadStart, TestTime, FileDateTime: TDateTime;
    Ware: TWareInfo;
    arSys: array of SysRestData;
    arData: TVarRecArray;
    vfIniFile: TINIFile;
    price: Double;
  //------------ ������� ������ ��� ������� ��������
  function NewRestRecArray: TVarRecArray;
  var jj: Integer;
  begin
    SetLength(Result, RestCount+3);
    Result[0].VType:= vtInteger;
    Result[1].VType:= vtExtended;
    for jj:= 2 to RestCount+2 do begin
      Result[jj].VType:= vtAnsiString;
      Result[jj].VAnsiString:= nil;
    end;
  end;
  //-------------------------------------------
begin
  Result:= False;
  if FileExists(Cache.FormVladBlockFile) then Exit; // ���� ���� ���������� - �������
  locAdsConnection:= nil;
  locAQuery:= nil;
  atloc:= nil;
  ibsGB:= nil;
  ibdGb:= nil;
  FileDateTime:= DateNull;
  TestTime:= 0;
  j:= 0;   // ������� ����� ��������
  iPr:= 0; // ������� ����� ���
  flagForm:= False; // ������� ������������ ����� ������
  flagTestPrice:= False;
  vfIniFile:= TINIFile.Create(nmIniFileBOB);
  SetLength(arData, 0);
  with Cache do try
    if fnTestFileCreate(FormVladBlockFile)<0 then exit; // ������� ���� ����������
    LocalThreadStart:= now();
    if not TestChangeRestCols then Exit; // ��������� ���� �������
    dir:= PathRests;
    dirtmp:= fnTestDirEnd(fnCreateTmpDir(dir));
    RestCount:= Length(arVladStores);
    s:= dir+colsFname+'.dbf'; // ��� ����� �������
    if not FileAge(s, FileDateTime) then FileDateTime:= DateNull;
    SetLength(arSys, SysTypes.Count);            // ������� ������� �� ��������
    for i:= 0 to High(arSys) do with arSys[i] do begin
      atlocSys:= nil;
      with SysTypes do begin
        SysID:= TSysItem(ItemsList[i]).ID;
        SysRests:= restFname+TSysItem(ItemsList[i]).SysSuffix+'.dbf';
      end;
      tmpSysRests:= '_'+SysRests;
      DeleteFile(dirtmp+tmpSysRests); // ������� ��������� ������� �������� SysID
                       // ��������� �� ����� ������� - ����������� ��� ���������
      if not FileAge(dir+SysRests, TestTime) then TestTime:= 0;
      flagForm:= flagForm or (FileDateTime>TestTime);
    end;

    if not flagForm then begin // ���� ���������
      for i:= 0 to High(arSys) do with arSys[i] do begin
        if not FileAge(dir+SysRests, TestTime) then TestTime:= DateNull;
        if LastRestTime=DateNull then LastRestTime:= TestTime;
        if LastRestPriceTime=DateNull then begin             // � ������ �� ���� �������� ��������
          Interval:= fnIfInt(fnGetActionTimeEnable(caeOnlyDay), TestCacheInterval, TestCacheNightInt);
          LastRestPriceTime:= IncMinute(LastRestTime, -Interval);
        end;
      end;
                                        // ��������� ������������ ��������
      if (Now<IncMinute(LastRestTime, ActualFileRests)) then Exit;

      for i:= 0 to High(arSys) do with arSys[i] do // �������� ����� �������� �� ��������
        CopyFile(PChar(dir+SysRests), PChar(dirtmp+tmpSysRests), False);
    end;
    TestCssStopException;
    TestTime:= LastTimeCache; // ��������� ����� ���������� ���������� ���� ��� ���

    try
      sRestFields:= '';
      sRestJoins:= '';
      for i:= 0 to RestCount-1 do begin // ������ ���� �������
        s:= IntToStr(arVladStores[i].Kod);
        sRestFields:= sRestFields+', rm'+s+'.Rmarket as r'+s;
        sRestJoins:= sRestJoins+' left join GetWareRestsCSS_Vlad(w.warecode, '+s+') rm'+s+' on 1=1';
      end;

      try                     // ������� ��������� AdsConnection ��� ��������� dbf
        locAdsConnection:= CreateLocalAdsConnection(dirtmp);
        locAdsConnection.Connect;
        locAQuery:= NewLocalADSQuery(locAdsConnection);
        if flagForm then with RespThread do begin  // ���� �����������
          s:= ''; // ������ ���� ����� �������� ��� �������� ������
          for i:= 0 to RestCount-1 do
            s:= s+', '+arVladStores[i].Field+' char('+IntToStr(arVladStores[i].size)+')';
                                 // ������� ��������� ������� �������� �� ��������
          for i:= 0 to High(arSys) do with arSys[i] do begin
            locAQuery.SQL.Text:= 'create table "'+tmpSysRests+
              '" (kod1 integer, cena numeric(11,2)'+s+', SALE CHAR(1))';
            locAQuery.ExecSQL;
            locAQuery.AdsCloseSQLStatement;
          end;
        end;

        for i:= 0 to High(arSys) do with arSys[i] do begin
          atlocSys:= NewLocalAdsTable(tmpSysRests, locAdsConnection, True);
          atlocSys.Open;
          if not flagForm then begin // ���� ��������� - ������� ������� (�������� dbf)
            atlocSys.AddIndex( 'ikod1', 'kod1', [] );
            atlocSys.IndexName:= 'ikod1';
          end;
        end;

        ibdGb:= cntsGRB.GetFreeCnt;
        ibsGB:= fnCreateNewIBSQL(ibdGb, 'ibsGBr_'+nmProc, -1, tpRead, True);
        arData:= NewRestRecArray;

  /////////////////////////////////////////////////////////////// ���� �����������
        if flagForm then begin
          ibsGB.SQL.Text:= 'Select w.warecode'+sRestFields+
            ' from wares w'+GetWaresPgrFilterStr+GetWaresNotInfoFilterStr+
            sRestJoins+' order by warecode';
          ibsGB.ExecQuery;       // ��������� ������ �������� �� Grossbee
          if (ibsGB.Bof and ibsGB.Eof) then raise Exception.Create('��� ��������');
          while not ibsGB.Eof do begin
            kod:= ibsGB.FieldByName('WARECODE').AsInteger;
            if WareExist(kod) then begin
              Ware:= GetWare(kod);
              price:= Ware.RetailPrice;
              if not Ware.IsArchive and fnNotZero(price) then begin // �������� ������� ����
                arData[0].VInteger:= Ware.ID; // ��������� ������ ��� ������� �������� SysID
                prAddVarRecs(arData, 1, 1, [price]);
                for i:= 0 to RestCount-1 do begin
                  k:= ibsGB.fieldByName(arVladStores[i].Field).AsInteger;
                  if k<1      then AnsiString(arData[i+2].VAnsiString):= AnsiString('')
                  else if k>8 then AnsiString(arData[i+2].VAnsiString):= AnsiString('*') // ������� ���������� �� 8
                  else             AnsiString(arData[i+2].VAnsiString):= AnsiString(IntToStr(k));
                end;
                AnsiString(arData[RestCount+2].VAnsiString):= AnsiString(fnIfStr(Ware.IsSale, 'T', 'F'));
                for i:= 0 to High(arSys) do with arSys[i] do // ��������� ������ � ������� �������� SysID
                  if Ware.CheckWareTypeSys(SysID) then atlocSys.AppendRecord(arData);
                inc(j);
              end; // if fnNotZero(price)
            end; // if WareExist(kod)
            cntsGRB.TestSuspendException;
            ibsGB.Next;
          end;
          ibsGB.Close;

  ///////////////////////////////////////////////////////////////// ���� ���������
        end else begin
          ibsGB.SQL.Text:= 'Select w.warecode'+sRestFields+
            ' from WARECACHE_VLAD inner join wares w on w.warecode=WACACODE'+
            GetWaresPgrFilterStr+GetWaresNotInfoFilterStr+sRestJoins+
            ' where WACARESTUPDATETIME>:LastTime order by WACACODE';
          ibsGB.ParamByName('LastTime').AsDateTime:= IncMinute(LastRestTime, -1); // ������ ������ ��� ���������
          ibsGB.ExecQuery;       // ��������� ������ �������� �� Grossbee - ��, ��� ��������
          while not ibsGB.Eof do begin
            kod:= ibsGB.FieldByName('warecode').AsInteger;
            if WareExist(kod) then begin
              Ware:= GetWare(kod);
              price:= Ware.RetailPrice;
              if not Ware.IsArchive and fnNotZero(price) then begin // �������� ������� ����

                arData[0].VInteger:= Ware.ID; // ��������� ������ ��� ������� �������� SysID
                prAddVarRecs(arData, 1, 1, [price]);
                for i:= 0 to RestCount-1 do begin
                  k:= ibsGB.fieldByName(arVladStores[i].Field).AsInteger;
                  if k<1      then AnsiString(arData[i+2].VAnsiString):= AnsiString('')
                  else if k>8 then AnsiString(arData[i+2].VAnsiString):= AnsiString('*') // ������� ���������� �� 8
                  else             AnsiString(arData[i+2].VAnsiString):= AnsiString(IntToStr(k));
                end;
                AnsiString(arData[RestCount+2].VAnsiString):= AnsiString(fnIfStr(Ware.IsSale, 'T', 'F'));

                for i:= 0 to High(arSys) do with arSys[i] do
                  if Ware.CheckWareTypeSys(SysID) then
                    if atlocSys.FindKey([kod]) then begin // ��������� ������� �������� SysID
                      atlocSys.Edit;
                      atlocSys.SetFields(arData);
                      atlocSys.Post;
                    end else atlocSys.AppendRecord(arData);
                inc(j);
              end else for i:= 0 to High(arSys) do with arSys[i] do
                if Ware.CheckWareTypeSys(SysID) and atlocSys.FindKey([kod]) then atlocSys.Delete;

            end else for i:= 0 to High(arSys) do with arSys[i] do
              if atlocSys.FindKey([kod]) then atlocSys.Delete;
            cntsGRB.TestSuspendException;
            ibsGB.Next;
          end;
          ibsGB.Close;

          flagTestPrice:= LastRestPriceTime<TestTime;
          if flagTestPrice then begin // ���� ��������� ����� ���������� ����
            ibsGB.SQL.Text:= // ���� �������� ������, ���. �������� �� ����.���������� ����
              ' select p.pricewarecode from PRICELISTALTER'+
              ' inner join pricelist p on p.pricecode=PRICEALTERCODE'+
              ' and p.PRICESUBFIRMCODE=1 and p.PRICETYPECODE='+IntToStr(PriceTypes[0])+
              ' inner join wares w on w.warecode=p.pricewarecode'+
              GetWaresPgrFilterStr+GetWaresNotInfoFilterStr+
              ' where PRICEALTERTIME between :Time1 and :Time2'+
              ' group by p.pricewarecode order by p.pricewarecode';
            ibsGB.ParamByName('Time1').AsDateTime:= IncMinute(LastRestPriceTime, -1); // ��� ���������
            ibsGB.ParamByName('Time2').AsDateTime:= IncSecond(TestTime, -1); // �.�.���� ����� �� ����
            ibsGB.ExecQuery;
            while not ibsGB.Eof do begin
              kod:= ibsGB.FieldByName('pricewarecode').AsInteger;
              if WareExist(kod) then begin
                Ware:= GetWare(kod);
                price:= Ware.RetailPrice;
                if not Ware.IsArchive then begin
                  inc(iPr);
                  for i:= 0 to High(arSys) do with arSys[i] do if Ware.CheckWareTypeSys(SysID) then
                    if atlocSys.FindKey([kod]) then begin // ���� ������ �� ������ ����
                      if not fnNotZero(price) then atlocSys.Delete
                      else if fnNotZero(atlocSys.FieldByName('cena').AsFloat-price) then begin
                        atlocSys.Edit;
                        atlocSys.FieldByName('cena').AsFloat:= price;
                        atlocSys.Post;
                      end;
                    end else begin // ���� ������ �� ������ ��� - ��������� � �������� ���������
                      arData[0].VInteger:= kod;      // ��������� ������ ��� ������� �������� SysID
                      prAddVarRecs(arData, 1, 1, [price]);       // �������� ������ ��������
                      for k:= 2 to RestCount+1 do AnsiString(arData[k].VAnsiString):= AnsiString('');
                      AnsiString(arData[RestCount+2].VAnsiString):= AnsiString(fnIfStr(Ware.IsSale, 'T', 'F'));
                      atlocSys.AppendRecord(arData);
                    end;
                end;
              end;
              cntsGRB.TestSuspendException;
              ibsGB.Next;
            end;
            ibsGB.Close;
          end; // if flagTestPrice
        end;
      finally
        prFreeIBSQL(ibsGB);
        cntsGRB.SetFreeCnt(ibdGb);
        prFreeADSQuery(locAQuery);
        for i:= 0 to High(arSys) do with arSys[i] do try
          if not flagForm and Assigned(atlocSys) and atlocSys.Active then begin
            atlocSys.IndexName:= '';    // ���� ��������� - ������� �������
            atlocSys.DeleteIndex('ikod1');
          end;
          prFreeAdsTable(atlocSys);
        except end;
        if assigned(locAdsConnection) then locAdsConnection.Disconnect;
        prFree(locAdsConnection);
      end;
  ///////////////////////////////////////////////////////// �������� ������� �����
      try
        CScache.Enter;
        for i:= Low(arSys) to High(arSys) do with arSys[i] do begin
          DeleteFile(dir+SysRests); // ������� ������ ������� �������� SysID
          RenameFile(dirtmp+tmpSysRests, dir+SysRests);
        end;
      finally
        CSCache.Leave;
      end;
  ////////////////////////////////////////////////////////////////////////////////
      s:= fnIfStr(flagForm, '����������� '+IntToStr(j)+' ����� - ', '��������� '+
        IntToStr(j)+' ���./ '+IntToStr(iPr)+' ��� - ')+GetLogTimeStr(LocalThreadStart);
      if ToLog(4) then prMessageLOGS(nmProc+': '+s, LogMail, false);
      if assigned(ThreadData) and ToLog(14) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, s);
      LastRestTime:= Now;
      vfIniFile.WriteDateTime('VladTables', 'LastRestTime', LastRestTime);
      if flagForm or flagTestPrice then begin
        LastRestPriceTime:= TestTime;
        vfIniFile.WriteDateTime('VladTables', 'LastRestPriceTime', LastRestPriceTime);
      end;
      Result:= True;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
        if assigned(ThreadData) then fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message);
      end;
    end;
  finally
    SetLength(arData, 0);
    SetLength(arSys, 0);
    fnDeleteTmpDir(dirtmp);
    DeleteFile(Cache.FormVladBlockFile);
    prFree(vfIniFile);
  end;
end;
//========================================== ��������� ���� � ������� � base.dbf
function TestBaseRestAndPrice(ThreadData: TThreadData): Boolean;
// ���������� ������� ��������� ������ base.dbf
const nmProc = 'TestBaseRestAndPrice'; // ��� ���������/�������
type
  SysRestData = record
    SysID: integer;
    SysZip, SysBasePath, SysBase: string;
    SysConn: TAdsConnection;
    atlocSys: TAdsTable;
  end;
  WareRestData = record
    flChangePrice: Boolean;
    wprice: Single;
    wrests: Tas;
  end;
var locAQuery: TAdsQuery;
    locAdsConnection: TAdsConnection;
    ibdbGb: TIBDatabase;
    ibsGBr: TIBSQL;
    i, j, k, ii, jj, kod, iPr, RestCount, Interval: Integer;
    flagTestPrice, flRests, flDat: Boolean;
    s, s1, dirtmp, sRestFields, sRestJoins, pathAll: string;
    LocalThreadStart, TestTime: TDateTime;
    arSys: array of SysRestData;
    arWareRest: array of WareRestData;
    arrf: Tas;
    vfIniFile: TINIFile;
  //-------------------------------------------
begin
  Result:= False;
  if FileExists(Cache.FormVladBlockFile) then Exit; // ���� ���� ������������ - �������
  SetLength(arWareRest, 0);
  locAQuery:= nil;
  ibsGBr:= nil;
  ibdbGb:= nil;
  j:= 0;   // ������� ����� ��������
  iPr:= 0; // ������� ����� ���
  SetLength(arrf, 10);
  LocalThreadStart:= now();
  vfIniFile:= TINIFile.Create(nmIniFileBOB);
  with Cache do try
    pathAll:= FormVladPath+'all';
    if fnTestFileCreate(FormVladBlockFile)<0 then exit; // ������� ���� ����������
    SetLength(arSys, SysTypes.Count);    // ������� ������� �� ��������
    for i:= 0 to High(arSys) do with arSys[i] do begin
      atlocSys:= nil;
      with SysTypes do begin
        s:= TSysItem(ItemsList[i]).SysSuffix;
        SysID:= TSysItem(ItemsList[i]).ID;
      end;
      SysBasePath:= fnTestDirEnd(FormVladPath+s);
      SysBase:= SysBasePath+baseFname;
      SysZip:= VladZipPath+nfzipvlad+s+'.zip';
//      TestTime:= FileDateToDateTime(FileAge(SysBase));
      if not FileAge(SysBase, TestTime) then TestTime:= DateNull;
      if LastBaseRestTime=DateNull then LastBaseRestTime:= TestTime;
      if LastBasePriceTime=DateNull then begin            // � ������ �� ���� �������� ��������
        Interval:= fnIfInt(fnGetActionTimeEnable(caeOnlyDay), TestCacheInterval, TestCacheNightInt);
        LastBasePriceTime:= IncMinute(LastBaseRestTime, -Interval);
      end;
    end;                                   // ��������� ������������ ��������
    if (Now<IncMinute(LastBaseRestTime, ActualFileRests)) then Exit;
    TestCssStopException;
    TestTime:= LastTimeCache; // ��������� ����� ���������� ���������� ���� ��� ���

    SetLength(arWareRest, Length(arWareInfo)+100);
    for i:= 0 to High(arWareRest) do with arWareRest[i] do begin
      SetLength(wrests, 0);
      flChangePrice:= False;
      wPrice:= 0;
    end;
    try                     // ������� ��������� AdsConnection ��� ��������� dbf
      locAdsConnection:= CreateLocalAdsConnection(pathAll);
      try
        locAdsConnection.Connect;
        locAQuery:= NewLocalADSQuery(locAdsConnection);
        locAQuery.SQL.Text:= 'select KOD, FIELD from "'+nColRests+'"';
        locAQuery.Open;
        k:= 0;
        sRestFields:= ''; // ������� ����� �� ��������������� ������� �������
        sRestJoins:= '';
        while not locAQuery.Eof do begin
          if (High(arrf)<k) then SetLength(arrf, k+10);
          arrf[k]:= locAQuery.fieldByName('FIELD').AsString;
          s:= locAQuery.fieldByName('KOD').AsString;
          sRestFields:= sRestFields+', rm'+s+'.Rmarket as '+arrf[k];
          sRestJoins:= sRestJoins+' left join GetWareRestsCSS_Vlad(w.warecode, '+s+') rm'+s+' on 1=1';
          inc(k);
          TestCssStopException;
          locAQuery.Next;
        end;
        locAQuery.Close;
        locAQuery.AdsCloseSQLStatement;
                                                      // ��������� ���� � ����
        locAQuery.SQL.Text:= 'select DATNOW, KURSNOW from "'+datFname+'"';
        locAQuery.RequestLive:= True;
        locAQuery.Open;

        flDat:= not IsToday(locAQuery.FieldByName('DATNOW').AsDateTime) or
          fnNotZero(locAQuery.FieldByName('KURSNOW').AsFloat-DefCurrRate);
        if flDat then begin
          locAQuery.Edit;
          locAQuery.FieldByName('DATNOW').AsString:= FormatDateTime(cDateFormatY2, Now);
          locAQuery.FieldByName('KURSNOW').AsFloat:= DefCurrRate;
          locAQuery.Post;
        end;
        locAQuery.Close;
        locAQuery.AdsCloseSQLStatement;

        locAdsConnection.Disconnect;
        if (Length(arrf)>k) then SetLength(arrf, k);
        RestCount:= k;

        ibdbGb:= cntsGRB.GetFreeCnt;
        ibsGBr:= fnCreateNewIBSQL(ibdbGb, 'ibsGBr_'+nmProc, ThreadData.ID, tpRead, True);

////////////////////////////////////////////////////////////// ��������� �������
        ibsGBr.SQL.Text:= 'Select w.warecode'+sRestFields+
          ' from (select WACACODE from WARECACHE_VLAD'+
          ' where WACARESTUPDATETIME>:LastTime)'+
          ' left join wares w on w.warecode=WACACODE'+
//          GetWaresPgrFilterStr+GetWaresNotInfoFilterStr+
          sRestJoins+' order by warecode';
        ibsGBr.ParamByName('LastTime').AsDateTime:= IncMinute(LastBaseRestTime, -5);
        ibsGBr.ExecQuery;       // ��������� ������ �������� �� Grossbee - ��, ��� ��������
        while not ibsGBr.Eof do begin
          kod:= ibsGBr.FieldByName('warecode').AsInteger;
          if WareExist(kod) and not GetWare(kod).IsArchive then begin
            with arWareRest[kod] do begin
              SetLength(wrests, RestCount);
              for ii:= 0 to RestCount-1 do begin
                jj:= ibsGBr.fieldByName(arrf[ii]).AsInteger;
                if jj<1      then wrests[ii]:= ''
                else if jj>8 then wrests[ii]:= '*' // ������� ���������� �� 8
                else              wrests[ii]:= IntToStr(jj);
              end;
            end;
            inc(j);
          end;
          cntsGRB.TestSuspendException;
          ibsGBr.Next;
        end;
        ibsGBr.Close;

////////////////////////////////////////////////// ��������� ����, ���. ��������
        flagTestPrice:= LastBasePriceTime<TestTime;
        if flagTestPrice then begin // ���� ��������� ����� ���������� ����
          ibsGBr.SQL.Text:= // ���� �������� ������, ���. �������� �� ����.���������� ����
            ' select p.pricewarecode from PRICELISTALTER'+
            ' inner join pricelist p on p.pricecode=PRICEALTERCODE'+
            ' and p.PRICESUBFIRMCODE=1 and p.PRICETYPECODE='+IntToStr(PriceTypes[0])+
            ' inner join wares w on w.warecode=p.pricewarecode'+
            GetWaresPgrFilterStr+GetWaresNotInfoFilterStr+
            ' where PRICEALTERTIME between :Time1 and :Time2'+
            ' group by p.pricewarecode order by p.pricewarecode';
          ibsGBr.ParamByName('Time1').AsDateTime:= IncMinute(LastBasePriceTime, -1); // ��� ���������
          ibsGBr.ParamByName('Time2').AsDateTime:= IncSecond(TestTime, -1); // �.�.���� ����� �� ����
          ibsGBr.ExecQuery;
          while not ibsGBr.Eof do begin
            kod:= ibsGBr.FieldByName('pricewarecode').AsInteger;
            if WareExist(kod) and not GetWare(kod).IsArchive then begin
              with arWareRest[kod] do begin
                flChangePrice:= True;
                wPrice:= GetWare(kod).RetailPrice;
              end;
              inc(iPr);
            end;
            cntsGRB.TestSuspendException;
            ibsGBr.Next;
          end;
          ibsGBr.Close;
        end;

        flRests:= (iPr+j)>0;

        if flRests then for i:= Low(arSys) to High(arSys) do with arSys[i] do try
          SysConn:= CreateLocalAdsConnection(SysBasePath);
          SysConn.Connect;
          atlocSys:= NewLocalAdsTable(baseFname, SysConn, True);
          atlocSys.Open;
          while not atlocSys.Eof do begin
            with arWareRest[atlocSys.FieldByName('kod').AsInteger] do
              if flChangePrice or (length(wrests)>0) then begin
                atlocSys.Edit;
                if flChangePrice then atlocSys.FieldByName('cena').AsFloat:= wPrice;
                for ii:= Low(wrests) to High(wrests) do
                  atlocSys.fieldByName(arrf[ii]).AsString:= wrests[ii];
                atlocSys.Post;
              end;
            TestCssStopException;
            atlocSys.Next;
          end;
          atlocSys.Close;
        finally
          prFreeAdsTable(atlocSys);
          SysConn.Disconnect;
          prFree(SysConn);
        end;

      finally
        prFreeIBSQL(ibsGBr);
        cntsGRB.SetFreeCnt(ibdbGb);
        locAdsConnection.Disconnect;
        prFreeADSQuery(locAQuery);
      end;
/////////////////////////////////////////////////////////// �������� ����� � zip
      if flRests or flDat then try
        CScache.Enter;
        for i:= 0 to High(arSys) do with arSys[i] do begin
          dirtmp:= SysBasePath+IntToStr(SysID);
          try
            s:= ''; // ����� ����� ������ ������ ������
            s1:= ZipExtractFiles(SysZip, s, dirtmp); // ������������� � dirtmp
            if (s1<>'') then raise Exception.Create(s1);
            dirtmp:= fnTestDirEnd(dirtmp);
            if flRests then begin                    // �������� ����� � dirtmp
              DeleteFile(dirtmp+baseFname);
              CopyFile(PChar(SysBase), PChar(dirtmp+baseFname), False);
            end;
            if flDat then begin
              DeleteFile(dirtmp+datFname);
              CopyFile(PChar(fnTestDirEnd(pathAll)+datFname), PChar(dirtmp+datFname), False);
            end;
            s1:= ZipAddFiles(dirtmp+'tmp.zip', s);     // ������ � dirtmp
            if (s1<>'') then raise Exception.Create(s1);

            DeleteFile(SysZip);                        // �������� zip
            CopyFile(PChar(dirtmp+'tmp.zip'), PChar(SysZip), False);
          finally
            fnDeleteTmpDir(dirtmp);
          end;
        end;
      finally
        CSCache.Leave;
      end;
  ////////////////////////////////////////////////////////////////////////////////
      s:= '��������� '+IntToStr(j)+' ���./ '+IntToStr(iPr)+' ��� - '+GetLogTimeStr(LocalThreadStart);
      if ToLog(4) then prMessageLOGS(nmProc+': '+s, LogMail, false);
      if ToLog(14) then fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, s);
      LastBaseRestTime:= Now;
      vfIniFile.WriteDateTime('VladTables', 'LastBaseRestTime', LastBaseRestTime);
      if flagTestPrice then begin
        LastBasePriceTime:= TestTime;
        vfIniFile.WriteDateTime('VladTables', 'LastBasePriceTime', LastBasePriceTime);
      end;
      Result:= True;
    except
      on E: Exception do begin
        prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
        fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message);
      end;
    end;
  finally
    SetLength(arSys, 0);
    SetLength(arrf, 0);
    for i:= 0 to High(arWareRest) do SetLength(arWareRest[i].wrests, 0);
    SetLength(arWareRest, 0);
    DeleteFile(Cache.FormVladBlockFile);
    prFree(vfIniFile);
  end;
end;
{//========== ���������� TList ������� - ������������ ������ + ��������� + ������
function WareModelsSortCompare(Item1, Item2: Pointer): Integer;
var i1, i2: Integer;
    Ware1, Ware2: TWareInfo;
begin
  with Cache do try
    Ware1:= GetWare(Integer(Item1));
    Ware2:= GetWare(Integer(Item2));
    if Ware1.IsINFOgr then i1:= 1 else i1:= 0;
    if Ware2.IsINFOgr then i2:= 1 else i2:= 0;
    if i1=i2 then begin
      if Ware1.GrpID<>Ware2.GrpID then
        Result:= AnsiCompareText(Ware1.GrpName, Ware2.GrpName)
      else if Ware1.PgrID<>Ware2.PgrID then
        Result:= AnsiCompareText(Ware1.PgrName, Ware2.PgrName)
      else Result:=AnsiCompareText(Ware1.Name, Ware2.Name);
    end else if i1>i2 then Result:= 1 else Result:= -1;
  except
    Result:= 0;
  end;
end;  }
//============================== ������������ ������ Vlad (base.dbf � ���������)
procedure FormVladTables;
const nmProc = 'FormVladTables'; // ��� ���������/�������/������
type TSysBaseData = record  // ����� ����������� ��� �������
  SysID: integer;
  SysSuff, SysPath: string;
  SysFS: TFileStream;
  SysAConnLoc: TAdsConnection;
  SysAtG, SysAtP, SysAtW: TAdsTable;
end;
  TWareRestData = record
    flRests: Boolean;
    wrests: Tas;
  end;
  TRestColData = record
    iKod: integer;
    sField, sKod, sSize: string;
  end;
var s, ss, grName, wName, PathAll, LogZeroPrice, pgrFNew, zipPath,
      sSort, nfTmpCols, ssField, ssKod, sRestCols, sRestPars, sRestFs: string;
    i, ii, itg, igr, ipgr, k, j, jj, jg, ion, RestCount, kk, HighWareRest: integer;
    w: word;
    cena: Double;
    LocalStart, LocStart: TDateTime;
    ibdbGb: TIBDatabase;
    ibsGBr: TIBSQL;
    AConnLoc: TAdsConnection;
    atG: TAdsTable;
    aqloc: TAdsQuery;
    lstW: TStringList;
    fs: TFileStream;
    Ware: TWareInfo;
    vfIniFile: TINIFile;
    arAnSys, arAn: Tai;
    arSys: array of TSysBaseData;
    arrCols: array of TRestColData;
    arWareRest: array of TWareRestData;
  //--------------------------------- ������� ������ �����
  procedure DelOldTables(pPath: String; pSys: Integer=0);
  begin
    DeleteFile(pPath+grFname);
    DeleteFile(pPath+pgrFname);
    DeleteFile(pPath+pgrFNew);
    DeleteFile(pPath+baseFname);
    if pSys>0 then begin
      DeleteFile(pPath+nAnalogs);
      DeleteFile(pPath+nAnalogsNew);
    end else DeleteFile(pPath+nfTmpCols);
  end;
  //--------------------------------- ������� ������ � ����� nfzipvlad
  function AddFilesToZip(pPath: String): String;
  var Fnames, s: String;
  begin
    Result:= pPath+nfzipvlad+'.zip';
    Fnames:= pPath+baseFname+','+PathAll+datFname+','+PathAll+nColRests+','+ // ����� ������
             PathAll+filesFname+','+pPath+grFname+','+pPath+pgrFNew+','+pPath+nAnalogs;
    s:= ZipAddFiles(Result, Fnames);
    if (s<>'') then raise Exception.Create(s);
  end;
  //---------------------------------
begin
  if not Assigned(Cache) then Exit;
  LocalStart:= now();
  LocStart:= now();
  AConnLoc:= nil;
  atG:= nil;
  SetLength(arAn, 0);
  SetLength(arAnSys, 0);
  SetLength(arrCols, 0);
  SetLength(arWareRest, 0);
  SetLength(arSys, SysTypes.Count); // ������ ������� ����������� ��� ������� �� ��������
  lstW:= fnCreateStringList(False, 150000);
  pgrFNew:= ChangeFileExt(pgrFname, '.new');
  nfTmpCols:= colsFname+'.dbf';
  vfIniFile:= TINIFile.Create(nmIniFileBOB);
  with Cache do try
    zipPath:= fnTestDirEnd(VladZipPath);
    try
      PathAll:= fnTestDirEnd(FormVladPath+'all');
      LogZeroPrice:= zipPath+fZeroPrice;
      DelOldTables(FormVladPath); // ������� ������ ����� �����

      for i:= 0 to High(arSys) do with arSys[i] do begin // ������� ������� �� ��������
        with SysTypes do begin
          SysID:= GetDirItemID(ItemsList[i]);
          SysSuff:= TSysItem(ItemsList[i]).SysSuffix;
        end;
        SysPath:= FormVladPath+SysSuff;
        if not DirectoryExists(SysPath) then CreateDir(SysPath); // ���� ��� ����� - �������
        SysPath:= fnTestDirEnd(SysPath);
      end;

      try
        CScache.Enter;
        CopyFile(PChar(PathRests+nfTmpCols), PChar(FormVladPath+nfTmpCols), False); // �������� ���� �������
        if not FileExists(FormVladPath+nfTmpCols) then
          raise Exception.Create('error CopyFile '+FormVladPath+nfTmpCols);
      finally
        CSCache.Leave;
      end;

      AConnLoc:= CreateLocalAdsConnection(FormVladPath); // ������� ��������� AdsConnection
      aqloc:= NewLocalADSQuery(AConnLoc);
      try
        AConnLoc.Connect;
        aqloc.SQL.Text:= 'select KOD, SIZE, FIELD from "'+nfTmpCols+'"';
        aqloc.Open;
        k:= 0;
        sRestCols:= '';
        sRestFs  := '';
        sRestPars:= '';
        while not aqloc.Eof do begin
          if (High(arrCols)<k) then SetLength(arrCols, k+10);
          ssField:= aqloc.fieldByName('FIELD').AsString;
          if aqloc.fieldByName('SIZE').AsInteger<1 then ssKod:= '1'
          else ssKod:= aqloc.fieldByName('SIZE').AsString;
          ssKod:= 'char('+ssKod+')';
          arrCols[k].iKod  := aqloc.fieldByName('KOD').AsInteger;
          arrCols[k].sKod  := aqloc.fieldByName('KOD').AsString;
          arrCols[k].sField:= ssField;
          arrCols[k].sSize := ssKod;
          sRestCols  := sRestCols+', '+ssField+' '+ssKod;      // ������ ����� �������� ��� <create table>
          sRestFs    := sRestFs +', '+ssField;                 // ������ ����� �������� ��� <insert into>
          sRestPars  := sRestPars+', :p'+ssField;              // ������ ���������� �������� ��� <insert into>
          inc(k);
          TestCssStopException;
          aqloc.Next;
        end;
      finally
        aqloc.Close;
        aqloc.AdsCloseSQLStatement;
        AConnLoc.Disconnect;
      end;
      if (Length(arrCols)>k) then SetLength(arrCols, k);
      RestCount:= k;

      SetLength(arWareRest, Length(arWareInfo)+100);
      HighWareRest:= High(arWareRest);
      for i:= 0 to HighWareRest do arWareRest[i].flRests:= False;

      try  //----------------------------------------------------------- �������
        ibdbGb:= cntsGRB.GetFreeCnt;
        ibsGBr:= fnCreateNewIBSQL(ibdbGb, 'ibsGBr_'+nmProc, -1, tpRead, True);
        ibsGBr.ParamCheck:= False;
        ibsGBr.SQL.Add('execute block returns (Rware integer, Rstore integer, Rest integer)');
        ibsGBr.SQL.Add('as declare variable XCoeff integer=1; declare variable Rmarket double precision;');
        ibsGBr.SQL.Add('begin for select RestWareCode, RestDprtCode, Rest, MeasCoefficient from');
        ibsGBr.SQL.Add('  (select RestWareCode, RestDprtCode,');
        ibsGBr.SQL.Add('    SUM(RestCurrent-RestOrder-RESTPLANOUTPUT-RestPlanTransfer) as Rest');
        ibsGBr.SQL.Add('    from WAREREST inner join DEPARTMENT on DPRTCODE=RestDprtCode');
        ibsGBr.SQL.Add('      where RestSubFirmCode=1 and not DprtKind is null and DprtKind=0');
        ibsGBr.SQL.Add('    group by RestWareCode, RestDprtCode order by RestWareCode)');
        ibsGBr.SQL.Add('  inner join wares w on w.warecode=RestWareCode');
        ibsGBr.SQL.Add('  inner join VLADPGR pg on pg.KODPGR=w.waremastercode');
        ibsGBr.SQL.Add('    and w.warearchive="F" and w.WARECHILDCOUNT=0');
        ibsGBr.SQL.Add('  inner join VLADGR g on g.KODGR=pg.KODGR and g.KODTG='+IntToStr(codeTovar));
        ibsGBr.SQL.Add('  inner join MEASURE on MeasCode=WareMeas');
        ibsGBr.SQL.Add('  into :Rware, :Rstore, :Rmarket, :XCoeff do if (Rmarket>0) then begin');
        ibsGBr.SQL.Add('    if (XCoeff>1) then Rmarket=ROUNDSUMMWITHSHIFT(Rmarket/XCoeff); ');
        ibsGBr.SQL.Add('    Rest=round(Rmarket,0); suspend; end end');
        ibsGBr.ExecQuery;       // ��������� ������ �������� �� Grossbee
        while not ibsGBr.Eof do begin
          i:= ibsGBr.FieldByName('Rware').AsInteger;
          if not WareExist(i) or GetWare(i).IsArchive or (i>HighWareRest) then begin
            while not ibsGBr.Eof and (i=ibsGBr.FieldByName('Rware').AsInteger) do ibsGBr.Next;
            Continue;
          end;
          with arWareRest[i] do begin
            SetLength(wrests, RestCount);
            for ii:= 0 to RestCount-1 do wrests[ii]:= ''; // ��������� �������� ������
            flRests:= True;
          end;
          while not ibsGBr.Eof and (i=ibsGBr.FieldByName('Rware').AsInteger) do begin
            jj:= ibsGBr.FieldByName('Rstore').AsInteger;
            for kk:= 0 to RestCount-1 do if (arrCols[kk].iKod=jj) then begin
              j:= ibsGBr.FieldByName('Rest').AsInteger; // ���� ����� ����� � arrCols
              with arWareRest[i] do if (j>8) then wrests[kk]:= '*'
                else if (j>0) then wrests[kk]:= IntToStr(j);
              break;
            end;
            cntsGRB.TestSuspendException;
            ibsGBr.Next;
          end;
        end;
        ibsGBr.Close;
      finally
        prFreeIBSQL(ibsGBr);
        cntsGRB.SetFreeCnt(ibdbGb);
      end;
      if ToLog(3) then prMessageLOGS(nmProc+':   fill rests - '+
        GetLogTimeStr(LocStart), fLogCache, False);
      LocStart:= Now;

      setLength(sSort, 110); //---------------------------------- ������ �������
      for i:= 1 to High(arWareInfo) do if WareExist(i) then with arWareInfo[i] do begin
        if IsArchive or not PgrExists(PgrID) or not GrpExists(GrpID) then Continue;
        if (PgrID=pgrDeliv) then Continue; // ���������� ��������
        if IsInfoGr then with GetSrcAnalogs(ca_GR) do try
          if Count<1 then Continue; // ����-������ ����� ���� ������ � ��������� Grossbee
        finally Free; end;
        sSort:= fnIfStr(arWareInfo[GrpID].PgrID=codeTovar, '1', '2')+'*'+
          fnMakeAddCharStr(copy(GrpName, 1, 16), 16, True)+'*'+
          fnMakeAddCharStr(copy(PgrName, 1, 40), 40, True)+'*'+copy(Name, 1, 50);
        lstW.AddObject(sSort, Pointer(i));
      end;

      TestCssStopException;
      lstW.Sort; // ���������

      if ToLog(3) then prMessageLOGS(nmProc+':   fill/sort wares - '+
        GetLogTimeStr(LocStart), fLogCache, False);
      LocStart:= Now;

//-------------------------------------------------- ��������� ����� �� ��������
      for i:= 0 to High(arSys) do with arSys[i] do begin
        DelOldTables(SysPath, SysID); // ������� ������ ����� SysID
    //--------------------------------------------------------------
        SysAConnLoc:= CreateLocalAdsConnection(SysPath); // ��������� AdsConnection � ����� �������
        SysAConnLoc.Connect;
        aqloc.AdsConnection:= SysAConnLoc;
    //--------------------------------------------------------------
        aqloc.SQL.Text:= 'create table "'+grFname+'" '+      // ������� �����
          '(KODTG numeric(6, 0), KODGR numeric(6, 0), NAME CHAR(16), NFPRL CHAR(8))';
        aqloc.ExecSQL;
        aqloc.AdsCloseSQLStatement;
        aqloc.SQL.Text:= 'create table "'+pgrFname+'" '+     // ������� ��������
          '(KODTG numeric(6, 0), KODGR numeric(6, 0),'+
          ' KODPGR numeric(6, 0), NAME CHAR(40), SKD CHAR(5), SKDTAG CHAR(5))';
        aqloc.ExecSQL;
        aqloc.AdsCloseSQLStatement;
        aqloc.SQL.Text:= 'create table "'+baseFname+'" '+    // ������� �������
          '(KOD numeric(6, 0), KODTG numeric(6, 0), KODGR numeric(6, 0), KODPGR numeric(6, 0),'+
          ' CENA numeric(11,2), NAME CHAR(50), COMMENT CHAR(50), SALE CHAR(1)'+sRestCols+', INDAT date)';
        aqloc.ExecSQL;
        aqloc.AdsCloseSQLStatement;
    //--------------------------------------------------------------
        SysatG:= NewLocalAdsTable(grFname, SysAConnLoc);
        SysatG.Exclusive:= True;
        SysatG.Open;
        SysatP:= NewLocalAdsTable(pgrFname, SysAConnLoc);
        SysatP.Exclusive:= True;
        SysatP.Open;
        SysatW:= NewLocalAdsTable(baseFname, SysAConnLoc);
        SysatW.Exclusive:= True;
        SysatW.Open;
        SysFS:= TFileStream.Create(SysPath+nAnalogsNew, fmCreate); // ����� ���� �������� SysID
      end;
      try
        jj:= Length(arWareRest);
        if jj<lstW.Count then begin
          SetLength(arWareRest, lstW.Count);
          HighWareRest:= High(arWareRest);
          for k:= jj to HighWareRest do arWareRest[k].flRests:= False;
        end;
        igr:= 0;
        ipgr:= 0;
        itg:= 0;
        jg:= 0; // ������� �����
        jj:= 0; // ������� ��������
        ion:= 0; // ������� �������
        for k:= 0 to lstW.Count-1 do begin
          i:= Integer(lstW.Objects[k]);
          if not WareExist(i) then Continue;

          Ware:= arWareInfo[i];
          if Ware.IsArchive then Continue;
          if (igr<>Ware.GrpID) then begin // ������� �����
            igr:= Ware.GrpID;
            itg:= arWareInfo[igr].PgrID;
            s:= copy(Ware.GrpName, 1, 16);
            for ii:= 0 to High(arSys) do with arSys[ii] do
              if arWareInfo[igr].CheckWareTypeSys(SysID) then begin
                SysatG.Append;
                SysatG.Fields[0].AsInteger:= itg;
                SysatG.Fields[1].AsInteger:= igr;
                SysatG.Fields[2].AsString:= s;
                SysatG.Post;
              end;
            inc(jg);
            TestCssStopException;
          end;

          if (ipgr<>Ware.PgrID) then begin  // ������� ��������
            ipgr:= Ware.PgrID;
            s:= copy(Ware.PgrName, 1, 40);
            for ii:= 0 to High(arSys) do with arSys[ii] do
              if arWareInfo[ipgr].CheckWareTypeSys(SysID) then begin
                SysatP.Append;
                SysatP.Fields[0].AsInteger:= itg;
                SysatP.Fields[1].AsInteger:= igr;
                SysatP.Fields[2].AsInteger:= ipgr;
                SysatP.Fields[3].AsString:= s;
                SysatP.Post;
              end;
            inc(jj);
            TestCssStopException;
          end;
          
          ssKod:= copy(Ware.Name, 1, 50);
          ss:= copy(Ware.Comment, 1, 50);
          s:= fnIfStr(Ware.IsSale, 'T', 'F');
          cena:= Ware.RetailPrice;
          arAn:= ware.Analogs;
          for ii:= High(arSys) downto 0 do with arSys[ii] do
            if Ware.CheckWareTypeSys(SysID) then begin
              SysatW.Append;
              SysatW.Fields[0].AsInteger:= i;
              SysatW.Fields[1].AsInteger:= itg;
              SysatW.Fields[2].AsInteger:= igr;
              SysatW.Fields[3].AsInteger:= ipgr;
              if fnNotZero(cena) then SysatW.Fields[4].AsFloat:= cena;
              SysatW.Fields[5].AsString:= ssKod;
              if ss<>'' then SysatW.Fields[6].AsString:= ss;
              SysatW.Fields[7].AsString:= s;        // ��������� �������
              with arWareRest[i] do if flRests then for kk:= 0 to RestCount-1 do
                if wrests[kk]<>'' then SysatW.Fields[kk+8].AsString:= wrests[kk];
              SysatW.Post;
//------------------------------------------------------ ��������� ����� �������
              kk:= 0; // �������
              SetLength(arAnSys, Length(arAn));
              for j:= 0 to High(arAn) do  //---------------------- ������� SysID
                if WareExist(arAn[j]) then with arWareInfo[arAn[j]] do
                  if not IsInfoGr and CheckWareTypeSys(SysID) then begin
                    arAnSys[kk]:= arAn[j];
                    inc(kk);
                  end;
              if kk>1 then begin
                j:= ware.ID;
                SysFS.Write(LongInt(j), sizeof(LongInt));           // ���������� ��� ������
                SysFS.Write(word(kk), sizeof(word)); // ���������� ���-�� �������� ������
                for j:= 0 to kk-1 do SysFS.Write(LongInt(arAnSys[j]), sizeof(LongInt)); // ���������� ���� ��������
              end;
            end; // if Ware.CheckWareTypeSys(SysID)
          SetLength(arAn, 0);
          inc(ion);
          TestCssStopException;
        end;
        lstW.Clear;

        if ToLog(3) then prMessageLOGS(nmProc+':   form tables - '+
          GetLogTimeStr(LocStart), fLogCache, False);
        LocStart:= Now;

      finally
        for i:= Low(arSys) to High(arSys) do with arSys[i] do begin
          SysatG.Close;
          SysatG.Exclusive:= False;
          SysatP.Close;
          SysatP.Exclusive:= False;
          SysatW.Close;
          SysatW.Exclusive:= False;
          SysAConnLoc.Disconnect;
          SysFS.Position:= 0;
          prFree(SysFS);
          SetLength(arAnSys, 0);
        end;
      end;
      for i:= Low(arSys) to High(arSys) do with arSys[i] do
        CopyFile(PChar(SysPath+pgrFname), PChar(SysPath+pgrFNew), False);

//------------------------------------------------------------------ ���� � ����
      TestCssStopException;
      if FileExists(PathAll+datFname) then try
        AConnLoc.ConnectPath:= PathAll;
        AConnLoc.Connect;
        atG:= NewLocalAdsTable(datFname, AConnLoc);
        atG.Exclusive:= True;
        atG.Open;
        try
          atG.Edit;
          atG.FieldByName('DATNOW').AsString:= FormatDateTime(cDateFormatY2, Now);
          atG.FieldByName('KURSNOW').AsFloat:= DefCurrRate;
          atG.Post;
        except
          on E: Exception do prMessageLOGS(nmProc+': ������ ������ � '+datFname, fLogCache);
        end;
        atG.Close;
        atG.Exclusive:= False;
      finally
        AConnLoc.Disconnect;
        prFree(atG);
      end else prMessageLOGS(nmProc+': ��� ����� '+FormVladPath+datFname, fLogCache);
      TestCssStopException;

//------------------------------------------------------ ������ ������� Grossbee
      if FileExists(FormVladPath+nAnalogs) then begin
        fs:= TFileStream.Create(FormVladPath+nAnalogs, fmOpenRead); // ��������� �������
        for i:= Low(arSys) to High(arSys) do with arSys[i] do
          SysFS:= TFileStream.Create(SysPath+nAnalogs, fmCreate); // ���� �������� SysID
        try
          fs.Position:= 0;
          if fs.Size>0 then
            while fs.Position<(fs.Size-1) do begin
              fs.Read(Word(w), Sizeof(word));   // ��������� "���-��" �������� � ������
              SetLength(arAn, w);
              for i:= 0 to w-1 do begin // ��������� "������" ��������
                fs.Read(LongInt(jj), Sizeof(LongInt));
                arAn[i]:= jj;
              end;
              SetLength(arAnSys, w);

              for jj:= Low(arSys) to High(arSys) do with arSys[jj] do begin
                k:= 0; // �������
                for i:= 0 to w-1 do    //----------------------- ������� SysID
                  if arWareInfo[arAn[i]].CheckWareTypeSys(SysID) then begin
                    arAnSys[k]:= arAn[i];
                    inc(k);
                  end;
                if k>1 then begin
                  SysFS.Write(word(k), sizeof(word(k))); // ���������� ���-�� �������� � ������
                  for j:= 0 to k-1 do SysFS.Write(LongInt(arAnSys[j]), sizeof(LongInt)); // ���������� ���� ��������
                end;
              end;
            end; // while fs.Position
        finally
          fs.Position:= 0;
          prFree(fs);
          for i:= Low(arSys) to High(arSys) do with arSys[i] do begin
            SysFS.Position:= 0;
            prFree(SysFS);
          end;
        end;
      end else prMessageLOGS(nmProc+': ��� ����� '+FormVladPath+nAnalogs, fLogCache);

//------------------------------------------------------ ������� � ������ ������
      TestCssStopException;
      try
        CScache.Enter;
        DeleteFile(PathAll+nColRests);
        RenameFile(FormVladPath+nfTmpCols, PathAll+nColRests);
      finally
        CSCache.Leave;
      end;
      for i:= Low(arSys) to High(arSys) do with arSys[i] do begin
        grName:= AddFilesToZip(SysPath); // ������ ��� ������ (������� ������ � ����� nfzipvlad)
        try
          CScache.Enter;
          CopyFile(PChar(grName), PChar(zipPath+nfzipvlad+SysSuff+'.zip'), False);
        finally
          CSCache.Leave;
        end;
      end;

      if ToLog(3) then prMessageLOGS(nmProc+':   zeroP,anal,pack - '+
        GetLogTimeStr(LocStart), fLogCache, False);

      LastBaseTime:= Now;                // ����� ���������� ������������
      vfIniFile.WriteDateTime('VladTables', 'LastBaseTime', LastBaseTime);
      LastBaseRestTime:= Now;            // ����� ��������
      vfIniFile.WriteDateTime('VladTables', 'LastBaseRestTime', LastBaseRestTime);
      LastBasePriceTime:= LastTimeCache; // ����� ��� (�.�. ���� �� ����)
      vfIniFile.WriteDateTime('VladTables', 'LastBasePriceTime', LastBasePriceTime);

      wName:= IntToStr(jg+jj)+'��.,'+IntToStr(ion)+'���. - ';
      if ToLog(3) then prMessageLOGS(nmProc+': '+wName+
        GetLogTimeStr(LocalStart), fLogCache, False);

    except
      on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  finally
    for i:= Low(arSys) to High(arSys) do with arSys[i] do begin
      prFree(SysatG);
      prFree(SysatP);
      prFree(SysatW);
      prFree(SysAConnLoc);
      prDeleteAllFiles('*.cdx', SysPath); // ������ ������� (���� ����)
    end;
    prFreeADSQuery(aqloc);
    prFree(AConnLoc);
    prDeleteAllFiles('*.cdx', FormVladPath); // ������ ������� (���� ����)
    setLength(sSort, 0);
    SetLength(arSys, 0);
    SetLength(arAn, 0);
    SetLength(arAnSys, 0);
    SetLength(arrCols, 0);
    for i:= 0 to High(arWareRest) do SetLength(arWareRest[i].wrests, 0);
    SetLength(arWareRest, 0);
    prFree(lstW);
    prFree(vfIniFile);
  end;
  TestCssStopException;
end;
//=========================================== ��������� ���� � ��������� �������
function FirmBaseRestCols(FirmCode, nf, tmpdir, exevers: string; ThreadData: TThreadData): Boolean;
// nf - ���� ��� ��������� ��������� (base.dbf)
// tmpdir - ������� �����, exevers - ������ ��������� Vlad �������
const nmProc = 'FirmBaseRestCols'; // ��� ���������/�������
var locAtab, locAtab1: TAdsTable;
//    locAq: TAdsQuery;
    i, iMainPrice, FirmID, ind, contID: Integer;
    strDelete, strChange, scits, s: string;
    locAconnect: TAdsConnection;
    LocalThreadStart: TDateTime;
    flSubPrice: Boolean;
    price: Double;
begin
  Result:= False;
  locAtab:= nil;
  locAtab1:= nil;
//  locAq:= nil;
  locAconnect:= nil;
  scits:= '';
  FirmID:= StrToIntDef(FirmCode, 0);
  LocalThreadStart:= now();
  contID:= 0;
  with Cache do try
    if not FirmExist(FirmID) then raise Exception.Create(MessText(mtkNotFirmExists));
    locAconnect:= CreateLocalAdsConnection(tmpdir); // ������� ��������� AdsConnection
    locAconnect.Connect;                            // ��� ��������� dbf
//    locAq:= NewLocalADSQuery(locAconnect);
    locAtab:= NewLocalAdsTable(nColRests, locAconnect);
    locAtab1:= NewLocalAdsTable(nf, locAconnect);

    locAtab.Exclusive:= True;
    locAtab1.Exclusive:= True;
    try
      locAtab.Open;
      if not Assigned(locAtab.FindField('CLIENT')) then begin
        locAtab.Close;
  //      locAq.SQL.Text:= 'alter table "'+nColRests+'" add CLIENT char(1))';
  //      locAq.ExecSQL;             // ��������� ���� ������� � ����� �������
  //      locAq.AdsCloseSQLStatement;
        locAtab.Restructure('CLIENT,Char,1;', '', ''); // ��������� ���� ������� � ����� �������
        locAtab.Open;
      end;

      locAtab1.Open;
      with arFirmInfo[FirmID] do begin
        flSubPrice:= GetContract(contID).HasSubPrice;
        while not locAtab.Eof do begin
          s:= locAtab.fieldByName('FIELD').AsString;
          if Assigned(locAtab1.Fields.FindField(s)) then // ���� ���� � base.dbf
            with GetContract(contID) do
            for i:= Low(ContStorages) to High(ContStorages) do with ContStorages[i] do begin
              ind:= StrToIntDef(DprtCode, 0);
              if (ind<1) or (ind<>locAtab.fieldByName('KOD').AsInteger) then Continue;
              locAtab.Edit;                            // ����� ���� � �������
              locAtab.fieldByName('CLIENT').AsString:= 'T'; // ������ ������ �������
              locAtab.fieldByName('DEF').AsString:= fnIfStr(IsDefault, 'T', 'F');
              locAtab.fieldByName('RES').AsString:= fnIfStr(IsReserve, 'T', 'F');
              locAtab.Post;
              break;
            end;
          locAtab.Next;
        end; // while not locAtab.Eof
      end; // with arFirmInfo[FirmID]
      i:= 0;
      strDelete:= '';
      strChange:= '';
      TestCssStopException;
      locAtab.First;            // ������� ����� ��������� ��������� �����
      while not locAtab.Eof do begin
        if locAtab.fieldByName('CLIENT').AsString='T' then begin
          inc(i);
          strChange:= strChange+locAtab.fieldByName('FIELD').AsString+ // ������ ��� ����
            ',KOL'+IntToStr(i)+',Char,'+locAtab.fieldByName('SIZE').AsString+';';
          locAtab.Edit;
          locAtab.fieldByName('FIELD').AsString:= 'KOL'+IntToStr(i);
          locAtab.Post;
          scits:= scits+fnIfStr(scits='', '', ',')+locAtab.fieldByName('SHORT').AsString;
        end else begin
          strDelete:= strDelete+locAtab.fieldByName('FIELD').AsString+';'; // ������� ������ ������
          locAtab.Delete;
        end;
        TestCssStopException;
        locAtab.Next;
      end;
      TestCssStopException;

      locAtab.PackTable;
      locAtab.Close;
  //    locAq.SQL.Text:= 'alter table "'+nColRests+'" drop CLIENT';
  //    locAq.ExecSQL;             // ������� ���� ������� � ����� �������
  //    locAq.AdsCloseSQLStatement;
      locAtab.Restructure('', 'CLIENT', ''); // ������� ���� ������� � ����� �������
      TestCssStopException;

      if (nf=baseFname) and VersFirstMoreSecond(exevers, '', VladVersion513, '') then // c 5.2.0 � base.dbf ���� Integer
        strChange:= 'KOD,KOD,Integer;KODTG,KODTG,Integer;KODGR,KODGR,Integer;KODPGR,KODPGR,Integer;'+strChange;

      locAtab1.Close;
      if (strDelete<>'') or (strChange<>'') then
        locAtab1.Restructure('', strDelete, strChange); // ��������� ��������� �����
    finally
      locAtab.Close;
      locAtab.Exclusive:= False;
      locAtab1.Close;
      locAtab1.Exclusive:= False;
    end;
    TestCssStopException;

    if flSubPrice then begin //------------ ���� � ����� ���� ���� �� ���.������
      iMainPrice:= Low(Cache.PriceTypes); // ������ �������� ������
      locAtab1.Open;
      while not locAtab1.Eof do begin
        if locAtab1.fieldByName('KODTG').AsInteger=codeInfo then begin // ���� ����������
          while not locAtab1.Eof and (locAtab1.fieldByName('KODTG').AsInteger=codeInfo) do locAtab1.Next;
          Continue;
        end;

        i:= locAtab1.fieldByName('KODPGR').AsInteger;
        if not PgrExists(i) then ind:= iMainPrice
        else arWareInfo[i].GetFirmDiscAndPriceIndex(FirmID, ind, price); // ������ ������
        if ind=iMainPrice then begin // ���� � ��������� ������� ����� - ����������
          while not locAtab1.Eof and (locAtab1.fieldByName('KODPGR').AsInteger=i) do locAtab1.Next;
          Continue;
        end;

        i:= locAtab1.fieldByName('KOD').AsInteger;
        if WareExist(i) then begin
          price:= GetWare(i).RetailTypePrice(ind); // ������� �� ���.������
          if fnNotZero(locAtab1.fieldByName('cena').AsFloat-price) then begin
            locAtab1.Edit;
            locAtab1.fieldByName('cena').AsFloat:= price;
            locAtab1.Post;
          end;
        end;
        locAtab1.Next;
      end;
      locAtab1.Close;
    end;

    locAtab.TableName:= datFname;
    locAtab.Open;
    locAtab.Edit;
    locAtab.FieldByName('CITIES').AsString:= scits;
    locAtab.Post;
    locAtab.Close;

    Result:= True;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������', E.Message);
    end;
  end;
  prFreeAdsTable(locAtab);
  prFreeAdsTable(locAtab1);
//  prFreeADSQuery(locAq);
  if Assigned(locAconnect) then begin
    if locAconnect.IsConnected then locAconnect.Disconnect;
    prFree(locAconnect);
  end;
  Application.ProcessMessages;
  if ToLog(4) then prMessageLOGS(nmProc+': �������� ����� ������� - '+
    GetLogTimeStr(LocalThreadStart), LogMail, false);
  prDeleteAllFiles('*.bak', tmpdir); // ������ �� Restructure
end;
//============================================== ��������� ���� �������� �������
function FirmRestAndPrice(FirmCode, nfrest, cits: string; ThreadData: TThreadData): Boolean;
const nmProc = 'FirmRestAndPrice'; // ��� ���������/�������
var locAtab: TAdsTable;
    locAconnect: TAdsConnection;
    i, FirmID, ind, contID: Integer;
    strDelete, strChange, scits: string;
    LocalThreadStart: TDateTime;
    arr: array of TColumnInfo;
    flSubPrice: Boolean;
    price: Double;
begin
  Result:= False;
  locAtab:= nil;
  locAconnect:= nil;
  setlength(arr, 0);
  scits:= '';
  FirmID:= StrToIntDef(FirmCode, 0);
  LocalThreadStart:= now();
  contID:= 0;
  with Cache do try
    if not FirmExist(FirmID) then raise Exception.Create(MessText(mtkNotFirmExists));
    try
      CScache.Enter;
      CopyFile(PChar(PathRests+colsFname+'.dbf'),
        PChar(PathRests+nfrest+'0.dbf'), false); // �������� ���� �������
    finally
      CSCache.Leave;
    end;
    locAconnect:= CreateLocalAdsConnection(PathRests); // ������� ��������� AdsConnection
    locAconnect.Connect;                                         // ��� ��������� dbf
    locAtab:= NewLocalAdsTable(nfrest+'0.dbf', locAconnect);
    locAtab.Exclusive:= True;
    locAtab.Open;

    with arFirmInfo[FirmID] do begin
      flSubPrice:= GetContract(contID).HasSubPrice;
      while not locAtab.Eof do begin
        with GetContract(contID) do
        for i:= Low(ContStorages) to High(ContStorages) do with ContStorages[i] do begin
          ind:= StrToIntDef(DprtCode, 0);
          if (ind<1) or (ind<>locAtab.fieldByName('KOD').AsInteger) then Continue;
          locAtab.Edit;                            // ����� ���� � �������
          locAtab.fieldByName('CLIENT').AsString:= 'T'; // ������ ������ �������
          locAtab.fieldByName('DEF').AsString:= fnIfStr(IsDefault, 'T', 'F');
          locAtab.fieldByName('RES').AsString:= fnIfStr(IsReserve, 'T', 'F');
          locAtab.Post;
          break;
        end;
        locAtab.Next;
      end; // while not locAtab.Eof
    end; // with arFirmInfo[FirmID]
    TestCssStopException;

    i:= 0;
    strDelete:= '';
    strChange:= '';
    locAtab.First;            // ������� ����� ��������� ��������� ����� ��������
    while not locAtab.Eof do begin
      if locAtab.fieldByName('CLIENT').AsString='T' then begin
        inc(i);
        strChange:= strChange+locAtab.fieldByName('FIELD').AsString+ // ������ ��� ����
          ',KOL'+IntToStr(i)+',Char,'+locAtab.fieldByName('SIZE').AsString+';';
        locAtab.Edit;
        locAtab.fieldByName('FIELD').AsString:= 'KOL'+IntToStr(i);
        locAtab.Post;
        if cits<>'' then scits:= scits+fnIfStr(scits='', '', ',')+locAtab.fieldByName('SHORT').AsString;
      end else begin
        strDelete:= strDelete+locAtab.fieldByName('FIELD').AsString+';'; // ������� ������ ������
        locAtab.Delete;
      end;
      TestCssStopException;
      locAtab.Next;
    end;
    locAtab.PackTable;
    locAtab.Close;
    locAtab.Restructure('', 'CLIENT', ''); // ������� ���� ������� � ����� �������
    locAtab.Exclusive:= False;
    TestCssStopException;

    locAtab.TableName:= nfrest+'.dbf';
    locAtab.Exclusive:= True;
    locAtab.Restructure('', strDelete, strChange); // ��������� ��������� ����� ��������
    locAtab.Exclusive:= False;
    TestCssStopException;

    if flSubPrice then begin // ���� � ����� ���� ���� �� ���.������
      locAtab.Open;
      while not locAtab.Eof do begin
        i:= locAtab.fieldByName('kod1').AsInteger;
        if WareExist(i) then begin
          price:= GetWare(i).RetailPrice(FirmID); // ������� �����
          if fnNotZero(locAtab.fieldByName('cena').AsFloat-price) then begin
            locAtab.Edit;
            locAtab.fieldByName('cena').AsFloat:= price;
            locAtab.Post;
          end;
        end;
        locAtab.Next;
      end;
      locAtab.Close;
    end;

    if cits<>'' then begin
      locAtab.TableName:= ExtractFileName(cits);
      locAtab.Exclusive:= True;
      locAtab.Open;
      locAtab.Edit;
      locAtab.FieldByName('CITIES').AsString:= scits;
      locAtab.Post;
      locAtab.Close;
      locAtab.Exclusive:= False;
    end;
    Result:= True;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData,lgmsSysError, nmProc, '������', E.Message);
    end;
  end;
  if Assigned(locAtab) then prFree(locAtab);
  if Assigned(locAconnect) then begin
    if locAconnect.IsConnected then locAconnect.Disconnect;
    prFree(locAconnect);
  end;
  Application.ProcessMessages;
  setlength(arr, 0);
  if ToLog(4) then prMessageLOGS(nmProc+': �������� ���� �������� ������� - '+
    GetLogTimeStr(LocalThreadStart), LogMail, false);
  prDeleteAllFiles('*.bak', PathRests); // ������ �� Restructure
end;
//==============================================================================
//                                ������
//==============================================================================
function ReportCheck(FirmCode, UserCode, BegDat: String; var nfzip: string;
                     ThreadData: TThreadData): TStringList; // must Free Result
const nmProc = 'ReportCheck'; // ��� ���������/�������
var ar: Tas;
    ibsGB, ibsGBw, ibsGBdebt: TIBSQL;
    ibd: TIBDatabase;
    locAq, locAqW: TAdsQuery;
    DateBegin, DateEnd, DateTemp: TDateTime;
    CodeUAH, CodeEUR, dir, nf, s: string;
    Debt, sum0uah, sum0eur, sum5uah, sum5eur: double;
    i, UAH, EUR, contID, FirmID: Integer;
    locAconnect: TAdsConnection;
  //--------------------------------------- // ��������� ������ � ������� ����������
  procedure AppendLineDoc(pDOCCODE, pDOCTYPE, pDOCVAL: Integer;
            pDOCNUM, pDUTYTYPE: string; pDOCDATE: TDateTime; pDOCSUM: double);
  begin
    locAq.Append; // ��������� ������ � ������� ����������
    locAq.FieldByName('DOCCODE').AsInteger := pDOCCODE;

// ���� �������� ������ ���� ����� ���-��� !!!
    pDOCTYPE:= GetOldDocmType(pDOCTYPE, StrToIntDef(pDUTYTYPE, 0));

    locAq.FieldByName('DOCTYPE').AsInteger := pDOCTYPE;
    locAq.FieldByName('DOCNUM').AsString   := pDOCNUM;
    if pDOCDATE>DateNull then locAq.FieldByName('DOCDATE').AsDateTime:= pDOCDATE;
    locAq.FieldByName('DUTYTYPE').AsString := pDUTYTYPE;
    locAq.FieldByName('DOCVAL').AsInteger  := pDOCVAL;
    if fnNotZero(pDOCSUM) then
      locAq.FieldByName('DOCSUM').AsString := fnCodeString(Byte('S'), fnSetDecSep(FloatToStr(pDOCSUM)));
    locAq.Post;
  end;
  //--------------------------------------- �������� ������������� �� ����
  function GetDebtOnDate(CurrCode: string; Dat: TDateTime): double;
  begin
    Result:= 0;
    ibsGBdebt.ParamByName('Dat').AsDateTime:= Dat;
    ibsGBdebt.ParamByName('CurrCode').AsString:= CurrCode;
    ibsGBdebt.ExecQuery;
    if not (ibsGBdebt.Bof and ibsGBdebt.Eof) then Result:= ibsGBdebt.Fields[0].AsFloat/100;
    ibsGBdebt.Close;
  end;
  //---------------------------------------
begin
  Result:= TStringList.Create;
  Result.Add('response:'+cGetCheckDt);
  locAq:= nil;
  locAqW:= nil;
  ibsGB:= nil;
  ibsGBw:= nil;
  ibsGBdebt:= nil;
  locAconnect:= nil;
  ibd:= nil;
  DateEnd:= DateNull;
  DateBegin:= DateNull;
  CodeUAH:= '0';
  CodeEUR:= '0';
  sum0uah:= 0; // ����� �������� �� ������ � ���.
  sum0eur:= 0; // ����� �������� �� ������ � �.�.
  sum5uah:= 0; // ����� �������� �� ������� � ���.
  sum5eur:= 0; // ����� �������� �� ������� � �.�.
  try
    FirmID:= StrToIntDef(FirmCode, 0);
    if (FirmID<1) or not Cache.FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists));

    ar:= fnSplitString(BegDat); // ��� ������, ���� ������, ���� ���������
//    if (length(ar)>1) then DateBegin:= fnStrToDateDef(fnTestDateYear4(ar[1])) else DateBegin:= DateNull; // ���� ������ ������
//    if (length(ar)>2) then DateEnd:= fnStrToDateDef(fnTestDateYear4(ar[2])) else DateEnd:= DateNull;    // ���� ��������� ������
    if (length(ar)>1) then DateBegin:= fnStrToDateDef(ar[1]); // ���� ������ ������
    if (length(ar)>2) then DateEnd  := fnStrToDateDef(ar[2]); // ���� ��������� ������
    if (length(ar)>3) then CodeUAH  := ar[3];                 // ������ � ���.
    if (length(ar)>4) then CodeEUR  := ar[4];                 // ������ � �.�.
    UAH:= StrToIntDef(CodeUAH, 0);
    EUR:= StrToIntDef(CodeEUR, 0);
    If DateEnd<DateBegin then begin // ��������� ������������ ���������
      DateTemp:= DateEnd;
      DateEnd:= DateBegin;
      DateBegin:= DateTemp;
    end;
    DateTemp:= FirstDayOfPrevMonth; // ����������� ���� ������ ������
    if (DateBegin<DateTemp) then begin  // ��������� ��������� �������� ���������
      DateBegin:= DateTemp;
      Result.Add(pINFORM+' ���� ������ ������ ���������� '+fnDateGetText(DateBegin));
    end;
    if (DateBegin>Date()) then DateBegin:= Date();
    if (DateEnd<DateTemp) then DateEnd:= DateTemp;
    if (DateEnd>Date()) then begin
      DateEnd:= Date();
      Result.Add(pINFORM+' ���� ��������� ������ ���������� '+fnDateGetText(DateEnd));
    end;
    nf:= 'rc'+fnGenRandString(4); // ��� ��� ����� � ��� ����� ������ ��� ����������
    dir:= fnCreateTmpDir(DirFileErr, nf); // ������ ��� ����.�����

    try
      ibd:= cntsGRB.GetFreeCnt;

      locAconnect:= CreateLocalAdsConnection(fnTestDirEnd(Dir)); // ������� ��������� AdsConnection ��� ��������� dbf
      locAconnect.Connect;
      if not locAconnect.IsConnected then raise Exception.Create(MessText(mtkErrConnectToDB));

      locAq:= NewLocalADSQuery(locAconnect);
      locAqW:= NewLocalADSQuery(locAconnect);

      ibsGB:= fnCreateNewIBSQL(ibd, 'ibsGB_'+nmProc, ThreadData.ID);
      ibsGBw:= fnCreateNewIBSQL(ibd, 'ibsGBw_'+nmProc, ThreadData.ID);
      ibsGBdebt:= fnCreateNewIBSQL(ibd, 'ibsGBdebt_'+nmProc, ThreadData.ID);

      contID:= Cache.arFirmInfo[FirmID].GetDefContractID;
      if (ContID<1) then raise Exception.Create(MessText(mtkNotFoundFirmCont));
      ibsGBdebt.SQL.Text:= 'select (select sum(TRNSSUMM) from TRANSACTIONS'+
        ' where TRNSFIRMCODE=f.firmcode and TRNSCRNCCODE=:CurrCode'+
        ' and TRNSCONTRACTCODE='+IntToStr(contID)+
        ' and TRNSDATE<:Dat and TRNSUSERTRANSACTIONKEY="F")'+ // ������, ��������
        '-(select sum(TRNSSUMM) from TRANSACTIONS'+
        ' where TRNSFIRMCODE=f.firmcode and TRNSCRNCCODE=:CurrCode'+
        ' and TRNSCONTRACTCODE='+IntToStr(contID)+
        ' and TRNSDATE<:Dat and TRNSUSERTRANSACTIONKEY="T")'+ // ���������
        ' from firms f where firmcode='+FirmCode;
      ibd.DefaultTransaction.StartTransaction;
      ibsGBdebt.Prepare;

      locAq.SQL.Text:= 'create table "'+nFileCheckDoc+'" (DOCCODE Integer, DOCTYPE Integer,'+
        ' DOCNUM char(16), DOCDATE date, DOCSUM char(15), DOCVAL Integer, DUTYTYPE char(1))';
      locAq.ExecSQL;             // ������� ������� ���������� ������
      locAq.AdsCloseSQLStatement;

      locAqW.SQL.Text:= 'create table "'+nFileCheckWar+'" (DOCCODE Integer, DOCTYPE Integer,'+
        ' WCODE Integer, WKOL Integer, WMEAS char(5), WPRICE char(15))';
      locAqW.ExecSQL;             // ������� ������� ���������� ������
      locAqW.AdsCloseSQLStatement;

      locAq.SQL.Text:= 'select * from "'+nFileCheckDoc+'"';
      locAq.RequestLive:= True;
      locAq.Open;

      locAqW.SQL.Text:= 'select * from "'+nFileCheckWar+'"';
      locAqW.RequestLive:= True;
      locAqW.Open;

      if UAH>0 then begin
        Debt:= GetDebtOnDate(CodeUAH, DateBegin); // ��������� ������������� � ���.
        AppendLineDoc(0, -2, UAH, '', fnIfStr(Debt>0, '5', '0'), DateNull, Abs(Debt)); // ��������� ������ � ������� ����������
      end;
      if EUR>0 then begin
        Debt:= GetDebtOnDate(CodeEUR, DateBegin); // ��������� ������������� � �.�.
        AppendLineDoc(0, -2, EUR, '', fnIfStr(Debt>0, '5', '0'), DateNull, Abs(Debt)); // ��������� ������ � ������� ����������
      end;

      ibsGB.SQL.Text:= 'select rSUMM LNSUMM, rDATE LNDATE, rDOCMTYPE LNDOCMTYPE,'+
        ' rDOCMCODE LNDOCMCODE, rCRNC LNCRNCCODE, rDUTYTYPE LNDUTYTYPE, rNUMBER LNNUMBER'+
        ' from Vlad_CSS_GetContractCheckDocs('+FirmCode+', '+IntToStr(contID)+', :DateBegin, :DateEnd)'+
        ' where rCRNC in ('+CodeUAH+','+CodeEUR+')';
      ibsGB.Prepare;
      ibsGB.ParamByName('DateBegin').AsDateTime:= DateBegin; // ����� ���������� ������
      ibsGB.ParamByName('DateEnd').AsDateTime:= DateEnd;
      ibsGB.ExecQuery;
      while not ibsGB.EOF do begin
        AppendLineDoc(ibsGB.FieldByName('LNDOCMCODE').AsInteger, // ��������� ������ � ������� ����������
          ibsGB.FieldByName('LNDOCMTYPE').AsInteger, ibsGB.FieldByName('LNCRNCCODE').AsInteger,
          ibsGB.FieldByName('LNNUMBER').AsString, ibsGB.FieldByName('LNDUTYTYPE').AsString,
          ibsGB.FieldByName('LNDATE').AsDateTime, ibsGB.FieldByName('LNSUMM').AsFloat/100);
        if (ibsGB.FieldByName('LNDUTYTYPE').AsString='0') then begin
          if (ibsGB.FieldByName('LNCRNCCODE').AsInteger=UAH) then
            sum0uah:= sum0uah+ibsGB.FieldByName('LNSUMM').AsFloat
          else if (ibsGB.FieldByName('LNCRNCCODE').AsInteger=EUR) then
            sum0eur:= sum0eur+ibsGB.FieldByName('LNSUMM').AsFloat;
        end else if (ibsGB.FieldByName('LNDUTYTYPE').AsString='5') then begin
          if (ibsGB.FieldByName('LNCRNCCODE').AsInteger=UAH) then
            sum5uah:= sum5uah+ibsGB.FieldByName('LNSUMM').AsFloat
          else if (ibsGB.FieldByName('LNCRNCCODE').AsInteger=EUR) then
            sum5eur:= sum5eur+ibsGB.FieldByName('LNSUMM').AsFloat;
        end;
        i:= ibsGB.FieldByName('LNDOCMTYPE').AsInteger;
        i:= GetOldDocmType(i, ibsGB.FieldByName('LNDUTYTYPE').AsInteger); // ���� �������� ������ ���� ����� ���-��� !!!

        if (ar[0]='1') and  // ������� ������ ������ - ��������� ������� �������
          (ibsGB.FieldByName('LNDOCMTYPE').AsInteger in [53, 102, 64, 103]) then begin

          if (ibsGB.FieldByName('LNDOCMTYPE').AsInteger in [53, 102]) then
            ibsGBw.SQL.Text:= 'select INVCLNWARECODE WARECODE, INVCLNPRICE PRICE, INVCLNCOUNT WCOUNT'+
              ' from INVOICELINES, WARES where INVCLNDOCMCODE=:DOCMCODE and WARECODE=INVCLNWARECODE'
          else if (ibsGB.FieldByName('LNDOCMTYPE').AsInteger in [64, 103]) then
            ibsGBw.SQL.Text:= 'select RTINLNWARECODE WARECODE, RTINLNPRICE PRICE, RTINLNCOUNT WCOUNT '+
              'from RETURNINVOICELINES, WARES where RTINLNDOCMCODE=:DOCMCODE and WARECODE=RTINLNWARECODE';
          ibsGBw.Prepare;
          ibsGBw.ParamByName('DOCMCODE').AsInteger:= ibsGB.FieldByName('LNDOCMCODE').AsInteger;
          ibsGBw.ExecQuery;                           // ������ ���-��
          while not ibsGBw.EOF do begin
            if fnNotZero(ibsGBw.FieldByName('PRICE').AsFloat) then begin // ���� ���� �� �������
              locAqW.Append; // ��������� ������ � ������� �������
              locAqW.FieldByName('DOCTYPE').AsInteger:= i; // ���� �������� ������ ���� ����� ���-��� !!!
              locAqW.FieldByName('DOCCODE').AsInteger:= ibsGB.FieldByName('LNDOCMCODE').AsInteger;
              locAqW.FieldByName('WCODE').AsInteger  := ibsGBw.FieldByName('WARECODE').AsInteger;
              locAqW.FieldByName('WKOL').AsInteger   := ibsGBw.FieldByName('WCOUNT').AsInteger;
              locAqW.FieldByName('WMEAS').AsString   := Cache.GetWare(ibsGBw.FieldByName('WARECODE').AsInteger).MeasName;
              locAqW.FieldByName('WPRICE').AsString  := fnCodeString(Byte('S'),
                fnSetDecSep(FormatFloat('# ##0.00',ibsGBw.FieldByName('PRICE').AsFloat))); // ����
              locAqW.Post;
            end;
            ibsGBw.Next;
          end;
          ibsGBw.Close;
        end; // if (ar[0]='1') and (i  in [53, 102, 64])
        cntsGRB.TestSuspendException;
        ibsGB.Next;
      end;
      ibsGB.Close;

      if UAH>0 then begin
        if fnNotZero(sum0uah/100) then s:= fnCodeString(Byte('S'), fnSetDecSep(FloatToStr(sum0uah/100))) else s:= '';
        AppendLineDoc(0, -3, UAH, s, '9', DateNull, sum5uah/100); // ����� �������� �� ������
        Debt:= GetDebtOnDate(CodeUAH, IncDay(DateEnd)); // �������� ������������� � ���.
        AppendLineDoc(0, -4, UAH, '', fnIfStr(Debt>0, '5', '0'), DateNull, Abs(Debt)); // ��������� ������ � ������� ����������
      end;
      if EUR>0 then begin
        if fnNotZero(sum0eur/100) then s:= fnCodeString(Byte('S'), fnSetDecSep(FloatToStr(sum0eur/100))) else s:= '';
        AppendLineDoc(0, -3, EUR, s, '9', DateNull, sum5eur/100); // ����� �������� �� ������
        Debt:= GetDebtOnDate(CodeEUR, IncDay(DateEnd)); // �������� ������������� � �.�.
        AppendLineDoc(0, -4, EUR, '', fnIfStr(Debt>0, '5', '0'), DateNull, Abs(Debt)); // ��������� ������ � ������� ����������
      end;

    finally
      prFreeIBSQL(ibsGB);
      prFreeIBSQL(ibsGBw);
      prFreeIBSQL(ibsGBdebt);
      cntsGRB.SetFreeCnt(ibd);
      if Assigned(locAqW) then begin
        locAqW.AdsFlushFileBuffers;
        prFreeADSQuery(locAqW);
      end;
      if Assigned(locAq) then begin
        locAq.AdsFlushFileBuffers;
        prFreeADSQuery(locAq);
      end;
      if Assigned(locAconnect) then begin
        if locAconnect.IsConnected then locAconnect.Disconnect;
        prFree(locAconnect);
      end;
    end;

    nfzip:= DirFileErr+nf+'.zip'; // ������ ��� ����� ������ ��� ��������
    s:= ZipAddFiles(nfzip, fnTestDirEnd(dir)+nFileCheckDoc+','+fnTestDirEnd(dir)+nFileCheckWar); // ������ �������
    if s<>'' then raise Exception.Create(s);

    if nfzip<>'' then Result.Add(pKTOVAR+nf+'.zip'); // ���������� � ����� ��� ����� ������
    Result.Add(pBEGDAT+ar[0]+';'+CodeUAH+';'+CodeEUR+';'+ // ������� ������ ������;������ � ���.;������ � �.�.
      fnDateGetText(DateBegin)+';'+fnDateGetText(DateEnd)); // ���� ������ � ��������� ������

    s:= '������� ���-�� � '+fnDateGetText(DateBegin)+' �� '+fnDateGetText(DateEnd);
    if ToLog(2) then prMessageLOGS('ReportCheck: '+s, LogMail, false);
    if ToLog(12) then prSetThLogParams(ThreadData, 0, 0, 0, s); // ��������� � LOG ���������
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, LogMail, False);
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ ������', E.Message);
      Result.Clear;
      Result.Add('response:'+cGetCheckDt);
      Result.Add(pINFORM+'������ ������.');
      if FileExists(nfzip) then DeleteFile(nfzip);
      nfzip:= '';
    end;
  end;
  setLength(ar, 0);
  if not fnDeleteTmpDir(dir) then begin // ������ �� �����
    prMessageLOGS(nmProc+': ������ ������� ����.����� '+dir, LogMail, False);
    fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, '������ ������� ����.�����', dir);
  end;
  Application.ProcessMessages;
end;

//******************************************************************************
initialization
begin
  AdsSettings:= nil;
  SetLength(arVladStores, 0);
  CreateAdsSettings;
end;
finalization
begin
  SetLength(arVladStores, 0);
  FreeAdsSettings;
end;

end.
