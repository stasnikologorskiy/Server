unit n_TD_functions;

interface
uses Windows, Classes, Types, SysUtils, IniFiles, DateUtils, Math, DB, ADODB,
     ActiveX, Forms, Contnrs, IBDatabase, IBSQL, OleServer, Excel_TLB, Variants,
     n_free_functions, v_constants, v_DataTrans, n_constants, n_LogThreads,
     n_DataCacheInMemory, n_DataCacheAddition, n_DataCacheObjects, n_DataSetsManager;

type TarMps = array [0..17] of Integer; // массив для параметров модели

  TKeyTab = record // для инфо-списков
    KtCodeTDT   : Integer; // код KeyTable TDT
    TypeCodeORD : Integer; // код типа списка ORD
    FieldNameTDT: String;  // имя поля TDT
    KtNameTDT   : String;  // название KeyTable TDT
    InfoCodesORD: Tai;     // индекс - код Key TDT, значение - код DIRINFOTYPEMODEL (ORD)
    KeNamesTDT  : Tas;     // индекс - код Key TDT, значение - наименование TDT
  end;
  TarKeyTabs = array of TKeyTab; // массив для кодов элементов списков

  TLinkInfo = record
    nodeORD, nodTD, modORD, modelTD, Src, ldmw, sys: Integer;
    PartLagts: Tai;  // коды связок TD
    PartNums: Tai;   // номера порций условий и текстов
    UsesLists: TASL; // списки порций условий
    TextLists: TASL; // списки порций текстов
  end;
  TArLinkInfo = array of TLinkInfo; // для передачи через параметр функции

  TEngLinkInfo = record
    nodeORD, engORD, xLenw: Integer;
    PartLages: Tai;  // коды связок TD
    PartNums: Tai;   // номера порций условий
    ArUseParts: array of array of TCriInfo; // порции условий
  end;

const cDelim = '-------------;';
      cTabDelim = '-------------'#9;
      cTab = #9;
  arMpsTitles: array [0..17] of String = ('От/м', 'От/г', 'До/м', 'До/г',
    'кВт', 'ЛС', 'Т/об', 'Цил', 'Клап', 'Кузов', 'Привод', 'Двиг', 'Топл',
    'Впрыск', 'Тип/ТС', 'ТС', 'Катал', 'К/пер');
  ModelSheetName = 'Модели';
  sActionAdd = 'добавить';
  sActionUpd = 'изменить';
  sActionDel = 'удалить';

//                 отчеты и импорт данных из fb_tdt.fdb в ib_ord.gdb

 function AddLoadWaresInfoFromTDT(UserID: Integer;       // 24-stamp - must Free - пакетная доп.загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
          ThreadData: TThreadData=nil; filter_data: String=''): TStringList;
procedure prDeleteAutoModels(UserID: integer;            // 24-imp - удаление моделей авто из базы по файлу Excel (xls)
          FileName: string; ThreadData: TThreadData=nil);
function SetClientContractsToORD(UserID: Integer; ThreadData: TThreadData=nil): TStringList; // 24(3)-stamp must Free - простановка контрактов в db_ORD
procedure CheckGeneralPersonsForGB(UserID: Integer; pFileName: String; // 24(4/5)-stamp - проверка глав.пользователей в Grossbee
          ThreadData: TThreadData=nil; CheckNotArhLogins: Boolean=False);

 function fnGetNewAutoMfMlModFromTDT(pUserID: Integer;   // 25-stamp - must Free - поиск новых производителей, м.р., моделей авто из TDT
          ThreadData: TThreadData=nil): TStringList;
procedure prSetNewAutoMfMlModFromTDT(UserID: integer;    // 25-imp - загрузка моделей авто из TDT по файлу Excel
          FileName: string; var BodyMail: TStringList; ThreadData: TThreadData=nil);

 function fnGetNewCVMfMlModFromTDT(pUserID: Integer;     // 67-stamp - must Free - поиск новых производителей, м.р., моделей грузовиков из TDT
           ThreadData: TThreadData=nil): TStringList;
procedure prSetNewCVMfMlModFromTDT(UserID: integer;      // 67-imp - загрузка моделей грузовиков из TDT из файла Excel
          FileName: string; var BodyMail: TStringList; ThreadData: TThreadData=nil);

 function fnGetNewAxMfMlModFromTDT(pUserID: Integer;     // 68-stamp - must Free Result - поиск новых производителей, м.р., моделей осей из TDT
          ThreadData: TThreadData=nil): TStringList;
procedure prSetNewAxMfMlModFromTDT(UserID: integer;      // 68-imp - загрузка моделей осей из TDT из файла Excel
          FileName: string; var BodyMail: TStringList; ThreadData: TThreadData=nil);

 function prAddNewAxleFromTDT(var mORD: integer; UserID, mTD, mlORD: integer; // загрузка 1 модели оси из TDT
          var TdtIBS: TIBSQL; var KeyTabs: TarKeyTabs; fVis, fTop: Boolean; mName: string=''): string;
 function GetCVaxlesFromTDT(mCVord, mCVTD, UserID: integer; // связи грузовика с осями
          var KeyTabs: TarKeyTabs; var TdtIBSl, TdtIBSa, ordIBS: TIBSQL): string;

// function fnGetNewTreeNodesFromTDT(pUserID: Integer;     // 34-stamp - must Free - поиск новых узлов авто из TDT
//          ThreadData: TThreadData=nil): TStringList;
//procedure prSetNewTreeNodesFromTDT(UserID: Integer;      // 34-imp - загрузка / корректировка узлов авто из файла Excel
//          FileName: string; var BodyMail: TStringList; ThreadData: TThreadData=nil);

 function fnGetNewTreeNodesFromTDT(pUserID: Integer;     // 34-stamp - must Free - поиск новых узлов авто (+грузовики+оси) из TDT
          ThreadData: TThreadData=nil): TStringList;
procedure prSetNewTreeNodesFromTDT(UserID: Integer;      // 34-imp - загрузка / корректировка узлов авто (+грузовики+оси) из файла Excel
          FileName: string; var BodyMail: TStringList; ThreadData: TThreadData=nil);

procedure prGetArticlesINFOgrFromTDT(pUserID: Integer;   // 36-stamp - поиск артикулов TDT для инфо-групп Гроссби
          pFileName: String; ThreadData: TThreadData=nil);

 function fnGetInfoTextsForTranslate(pUserID: Integer;   // 39-stamp - must Free - перечень инфо-текстов TecDoc для перевода
          ThreadData: TThreadData=nil): TStringList;
procedure prSetAlternativeInfoTexts(UserID: integer;     // 39-imp - загрузка альтернативных значений инфо-текстов TecDoc из файла Excel
          FileName: string; ThreadData: TThreadData=nil);

 function fnGetCheckWareTDTArticles(pUserID: Integer;    // 40-stamp - must Free, Отчет о проверке привязок товаров к артикулам
          ThreadData: TThreadData=nil): TStringList;

//             функции загрузок из TDT
 function LoadWareLinksUsesCrisTextsFromTDT(WareID, UserID: Integer;
          var addLink3, addLinkON: Integer; var LO: RLoadOpts; ThreadData: TThreadData=nil): String; overload;
 function LoadWareLinksUsesCrisTextsFromTDT(WareID, UserID: Integer; // ... для t_webarmprocedures
          var addLink3, addLinkON: Integer): String; overload;

 function LoadWareEngLinksUsesFromTDT( WareID, UserID: Integer;                       // загрузка связок товара с двигателями из TecDoc (версия 2.4)
          var addLinkEng: Integer; ThreadData: TThreadData=nil; CheckArt: Boolean=True): String;

procedure LoadModelNodeWareUseAndTextListsFromTDT(TdtIBS, TdtIBSt, ordIBS, ordIBSr: TIBSQL; // загрузка порций условий и текстов из TecDoc (версия 2.4)
          WareID, pSupMFTD, UserID: Integer; var arInfo: TArLinkInfo;
          ThreadData: TThreadData=nil; CheckTexts: Boolean=False);

procedure LoadLinkListsFromTDT(TdtIBS: TIBSQL; WareID, UserID, pSrc, sysID: Integer; // загрузка связок товара из TDT по 1-му источнику
          var arInfo: TArLinkInfo; var ii, addLink3: Integer; ThreadData: TThreadData=nil);
procedure LoadWareNodeInfoTextFromTDT(WareID, pSupMFTD, nodeID, UserID, pSrc, sysID: Integer; // доп.инф. по товару и ноде из TDT
          pArticleTD: String; TdtIBS, ordIBS, ordIBSr: TIBSQL; ThreadData: TThreadData=nil);
 function LoadWareGraFileNamesFromTDT(WareID, UserID: Integer): String;                // имена файлов рисунков товара из TDT
 function fnGetWareONumsFromTDT(pWareID: Integer; pArtSupTD: Integer=0;                // поиск оригинальных номеров товара в TDT
                                pArticleTD: String=''): TarWareOnumOpts;
 function CheckEnginesFromTDT(var engCodes: Tai; pUserID: integer; sys: Integer=0): String; overload;  // загрузка/проверка параметров нескольких двигателей из TDT
 function CheckEnginesFromTDT(pUserID: integer): String; overload;                     // пакетная загрузка/проверка параметров двигателей из TDT
procedure LoadWareCrossesFromTDT(TdtIBS, ordIBS, ordIBSr: TIBSQL;
          WareID, pSupMFTD, UserID: Integer; pArticleTD: String; ThreadData: TThreadData=nil); // загрузка аналогов товара (+ по заменам) из TecDoc
procedure LoadWareEANandPackFromTDT(TdtIBS, ordIBS, ordIBSr: TIBSQL;                   // загрузка номеров EAN и параметров упаковки товара из TecDoc
          WareID, pSupMFTD, UserID: Integer; pArticleTD: String; ThreadData: TThreadData=nil);

//                    функции администрирования
function TestUpperWareArticleFromTDT: TStringList;                    // проверка артиклей на Upper в WAREARTICLETD
function TestNotLoadArticleLinksFromTDT(supliers: String=''): String; // проверка связок артиклей

implementation
uses n_server_common, t_ExcelXmlUse, n_xml_functions, t_ImportChecking, t_WebArmProcedures;

const icKodMF    = 1;   icKodML    = 2;      icNameTDML = 8;    icKodTDMod = 5;
      icNameMF   = 2;   icNameML   = 3;      icFromTDML = 9;    icNameTDMod= 6;
      icVisMF    = 3;   icFromML   = 4;      icToTDML   = 10;   icModMps   = 8;
      icKodTDMF  = 4;   icToML     = 5;      icCommML   = 11;   icModMpsV  = 8;
      icNameTDMF = 5;   icVisML    = 6;      icKodMod   = 3;    icCommMod  = 26;
      icCommMF   = 6;   icKodTDML  = 7;      icVisMod   = 4;    icResMod   = 27;
//******************************************************************************
//                        вспомагательные функции
//******************************************************************************
//------------------------------- разделить год и месяц начала/окончания выпуска
procedure GetYMfromTDfromto(tdFrom, tdTo: Integer; var yFrom, mFrom, yTo, mTo: Integer);
begin
  if (tdFrom>0) then yFrom:= tdFrom div 100 else yFrom:= 0; // Год начала выпуска
  if (yFrom>0)  then mFrom:= tdFrom mod 100 else mFrom:= 0; // Месяц начала выпуска
  if (tdTo>0)   then yTo  := tdTo   div 100 else yTo:= 0;   // Год конца выпуска
  if (yTo>0)    then mTo  := tdTo   mod 100 else mTo:= 0;   // Месяц конца выпуска
end;
//------------------------------------------------ параметры модели - из массива
procedure MakeMpsFromArray(arMps: TarMps; var Result: TModelParams);
begin
  if not Assigned(Result) then Result:= TModelParams.Create;
  with Result do begin
    pMStart    := arMps[0];
    pYStart    := arMps[1];
    pMEnd      := arMps[2];
    pYEnd      := arMps[3];
    pKW        := arMps[4];
    pHP        := arMps[5];
    pCCM       := arMps[6];
    pCylinders := arMps[7];
    pValves    := arMps[8];
    pBodyID    := arMps[9];
    pDriveID   := arMps[10];
    pEngTypeID := arMps[11];
    pFuelID    := arMps[12];
    pFuelSupID := arMps[13];
    pBrakeID   := arMps[14];
    pBrakeSysID:= arMps[15];
    pCatalID   := arMps[16];
    pTransID   := arMps[17];
  end;
end;
//-------------------------------------------------- параметры модели - в массив
function MakeArrayFromMps(mps: TModelParams): TarMps;
begin
  with mps do begin
    Result[0] := pMStart;
    Result[1] := pYStart;
    Result[2] := pMEnd;
    Result[3] := pYEnd;
    Result[4] := pKW;
    Result[5] := pHP;
    Result[6] := pCCM;
    Result[7] := pCylinders;
    Result[8] := pValves;
    Result[9] := pBodyID;
    Result[10]:= pDriveID;
    Result[11]:= pEngTypeID;
    Result[12]:= pFuelID;
    Result[13]:= pFuelSupID;
    Result[14]:= pBrakeID;
    Result[15]:= pBrakeSysID;
    Result[16]:= pCatalID;
    Result[17]:= pTransID;
  end;
end;
//----------------------------------- заполняем имя поля для поиска соответствий
procedure FillKeTabRecNf(index: Integer; nmf: String; var KeyTabs: TarKeyTabs);
begin
  if (index<Low(KeyTabs)) or (index>High(KeyTabs)) then exit;
  KeyTabs[index].FieldNameTDT := nmf;          // код KeyTable TDT
  KeyTabs[index].KtCodeTDT    := 0;            // код типа списка ORD
  KeyTabs[index].KtNameTDT    := '';           // имя поля TDT
  KeyTabs[index].TypeCodeORD  := 0;            // название KeyTable TDT
// инициализируем массивы
  SetLength(KeyTabs[index].InfoCodesORD, 0);   // индекс - код Key TDT, значение - код DIRINFOTYPEMODEL (ORD)
  SetLength(KeyTabs[index].KeNamesTDT, 0);     // индекс - код Key TDT, значение - наименование TDT
end;
//-------------------------- заполняем массив соответствий нужных списков по TDT
procedure FillarKeyTabsFromTDT(var KeyTabs: TarKeyTabs; FILEID: Integer; TdtIBS: TIBSQL);
var ss, mName: string;
    pkt, pke, i, ii: integer;
begin
  try
    TdtIBS.Close;
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
                                 // вынимаем в память виды списков TDT
    TdtIBS.SQL.Text:= 'select upper(IFFIELDNAME) fn, kt_id, kt_descr'+
      ' from IMPORT_FIELDS left join KEY_TABLES on kt_id=IFBYKT'+
      ' where IFFILEID='+IntToStr(FILEID)+' and IFBYKT>0';
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin // заполняем коды TDT видов списков
      ss:= TdtIBS.FieldByName('fn').AsString;
      pkt:= TdtIBS.FieldByName('kt_id').AsInteger;
      mName:= TdtIBS.FieldByName('kt_descr').AsString;
      for i:= Low(KeyTabs) to high(KeyTabs) do
        with KeyTabs[i] do if FieldNameTDT=ss then begin  // имя поля TDT
          KtCodeTDT:= pkt;            // код KEY_TABLES TDT
          KtNameTDT:= mName;          // название KEY_TABLES TDT
          SetLength(InfoCodesORD, 0); // индекс - код Key TDT, значение - код DIRINFOTYPEMODEL (ORD)
          SetLength(KeNamesTDT, 0);   // индекс - код Key TDT, значение - наименование KEY_ENTRIES TDT
          break;
        end;
      TestCssStopException;
      TdtIBS.Next;
    end;
    TdtIBS.Close;              // вынимаем в память списки TDT
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    TdtIBS.SQL.Text:= 'select kt_id, cast(ke_key as integer) ke,'+
      ' iif(icn_NewDescr is null, ke_descr, icn_NewDescr) ke_descr'+
      ' from IMPORT_FIELDS left join KEY_TABLES on kt_id=IFBYKT'+
      ' left join KEY_ENTRIES on ke_kt_id=kt_id'+
      ' left join import_change_names on icn_kt_ID=kt_id'+
      ' and icn_ke_key=cast(ke_key as integer)'+
      ' where IFFILEID='+IntToStr(FILEID)+' and IFBYKT>0 order by kt_id';
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin // заполняем наименования KEY_ENTRIES TDT
      pkt:= TdtIBS.FieldByName('kt_id').AsInteger;
      ii:= -1;
      for i:= Low(KeyTabs) to high(KeyTabs) do with KeyTabs[i] do
        if KtCodeTDT=pkt then begin // ищем индекс нужного элемента KeyTabs
          ii:= i;
          break;
        end;
      while not TdtIBS.Eof and (pkt=TdtIBS.FieldByName('kt_id').AsInteger) do begin
        if ii>-1 then with KeyTabs[ii] do begin
          pke:= TdtIBS.FieldByName('ke').AsInteger;
          if High(KeNamesTDT)<pke then begin
            SetLength(KeNamesTDT, pke+10);   // заполняем наименование
            SetLength(InfoCodesORD, pke+10); // готовим место для кода соответствия с ORD
          end;
          KeNamesTDT[pke]:= TdtIBS.FieldByName('ke_descr').AsString;
        end;
        TestCssStopException;
        TdtIBS.Next;
      end;
    end;
  finally
    TdtIBS.Close;
    TdtIBS.SQL.Clear;
  end;
end;
//------------------------------------------------------------ чистка TarKeyTabs
procedure ClearArKeyTabs(var KeyTabs: TarKeyTabs);
var i: integer;
begin
  for i:= Low(KeyTabs) to high(KeyTabs) do with KeyTabs[i] do begin
    if Assigned(InfoCodesORD) then SetLength(InfoCodesORD, 0);
    if Assigned(KeNamesTDT) then SetLength(KeNamesTDT, 0);
  end;
  SetLength(KeyTabs, 0);
end;
//---------------------------------- найти код элемента инфо-списка по кодам TDT
function GetInfoCode(ke, UserID: Integer; var KeyTab: TKeyTab): Integer;  // код KEY_ENTRIES
var kt, pType: integer;
    kName, ss: string;
begin
  Result:= 0;
  if (ke<1) then exit;
  with KeyTab do begin // проверяем наличие соответствия
    if (high(InfoCodesORD)<ke) then
      raise Exception.Create(FieldNameTDT+' некорректное значение');
    if (InfoCodesORD[ke]>0) then begin
      Result:= InfoCodesORD[ke];
      exit; // если нашли - выходим
    end;
    kName:= '';
    kt:= KtCodeTDT;
    if TypeCodeORD>0 then pType:= TypeCodeORD else pType:= 0;
    with Cache.FDCA do begin               // ищем в кеше по кодам TDT
      if TypesInfoModel.FindInfoItemByTDcodes(Result, pType, ke, kt) then begin
        InfoCodesORD[ke]:= Result; // если нашли - запоминаем коды и выходим
        if TypeCodeORD<1 then TypeCodeORD:= pType;
        exit;
      end;
      kName:= KeNamesTDT[ke]; // ищем наименование нового элемента
      if (kName='') then
        raise Exception.Create(FieldNameTDT+' не найдено значение');
      // добавляем новый элемент в кеш и в базу (pType - из FindInfoItemByTDcodes)
      ss:= TypesInfoModel.AddInfoModelItem(Result, pType, ke, kt, kName, UserID);
    end; // with Cache.FDCA
    if (ss<>'') then raise Exception.Create(FieldNameTDT+' '+ss)
    else if (Result<1) then raise Exception.Create(FieldNameTDT+' ID<1');
    InfoCodesORD[ke]:= Result; // запоминаем коды
    if (TypeCodeORD<1) then TypeCodeORD:= pType;
  end; // with KeyTabs[index]
end;
//--------------------------------- маркировки двигателей модели - в TStringList
procedure GetEngMarks(mt, sys, pUserID: Integer; var lst: TStringList; var TdtIBS: TIBSQL);
var engCodes: Tai;
    i: Integer;
begin
  prClearStrListWithObj(lst);
  with TdtIBS do try
    with Transaction do if not InTransaction then StartTransaction;
    if SQL.Text='' then
      case sys of
        constIsAuto: SQL.Text:= 'select eng_ID, eng_mark from link_eng_model_types'+
              ' left join engines on eng_ID=lemt_eng_ID where lemt_mt_ID=:mt order by eng_mark';
        constIsCV: SQL.Text:= 'select eng_ID, eng_mark from (select LECT_ENG_ID'+
              ' from LINK_ENG_CV_TYPES where LECT_CPT_ID=:mt group by LECT_ENG_ID) g'+
              ' left join engines on eng_ID=g.LECT_ENG_ID order by eng_mark';
        else Exit;
      end; // case
    ParamByName('mt').AsInteger:= mt;
    ExecQuery;
    while not Eof do begin
      lst.AddObject(FieldByName('eng_mark').AsString,
        TTwoCodes.Create(FieldByName('eng_ID').AsInteger, 0));
      Next;
    end;
  finally
    Close;
  end;
  if lst.Count<1 then Exit;
  try
    SetLength(engCodes, lst.Count);
    for i:= Low(engCodes) to High(engCodes) do engCodes[i]:= TTwoCodes(lst.Objects[i]).ID1;
    CheckEnginesFromTDT(engCodes, pUserID, sys); // загрузка/проверка параметров двигателей из TDT
    for i:= Low(engCodes) to High(engCodes) do TTwoCodes(lst.Objects[i]).ID2:= engCodes[i];
  finally
    SetLength(engCodes, 0);
  end;
end;
//----------------------------------------------- запись значения в ячейку index
procedure SaveValueADO(index: Word; S: String; var ADOTable: TADOTable);
begin
  ADOTable.Edit;
  ADOTable.Fields[index].Value:= S;
  ADOTable.Post;
end;
//------------------------------------ добавление строки и запись в ячейку index
procedure AddRecordADO(S: String; var ADOTable: TADOTable; index: Word=0);
begin
  ADOTable.Append;
  ADOTable.Fields[index].Value:= S;
  ADOTable.Post;
end;

//******************************************************************************
//                        поиск данных в fb_tdt.fdb
//******************************************************************************
//====================================== поиск оригинальных номеров товара в TDT
function fnGetWareONumsFromTDT(pWareID: Integer; pArtSupTD: Integer=0; pArticleTD: String=''): TarWareOnumOpts;
// возвращает массив - OE + если произв.найден - MFAUCODE и MFAUNAME,
// если нет - код=0 и наименование TecDoc
// Exception передает вызывающей процедуре
const nmProc = 'fnGetWareONumsFromTDT'; // имя процедуры/функции
var TdtIBD, ordIBD: TIBDatabase;
    TdtIBS, ordIBS: TIBSQL;
    mfTD, j, i: integer;
    mfName: string;
    fl: Boolean;
    arMFORD: Tai;
begin
  setLength(Result, 10);
  setLength(arMFORD, 0);
  TdtIBS:= nil;
  TdtIBD:= nil;
  ordIBS:= nil;
  ordIBD:= nil;
  with Cache.FDCA do try try
    if (pArtSupTD=0) or (pArticleTD='') then with Cache.GetWare(pWareID) do
      if (ArticleTD='') or (ArtSupTD<1) then
        raise EBOBError.Create(MessText(mtkNotEnoughParams))
      else begin
        pArtSupTD:= ArtSupTD;
        pArticleTD:= ArticleTD;
      end;

    ordIBD:= cntsORD.GetFreeCnt;
    TdtIBD:= cntsTDT.GetFreeCnt;

    ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
    ordIBS.SQL.Text:= 'select MtaMfau from MfTDaggregative where MtaMfTD=:mftd';

    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
    TdtIBS.SQL.Text:= 'select RN_MF_ID mfID, RN_REF_NR Onum,'+
      ' iif(ICN_NEWDESCR is null, mf_descr, ICN_NEWDESCR) mfName'+
      ' from REF_NUMBERS left join data_suppliers on RN_SUP_ID=DS_ID'+
      ' left join manufacturers on mf_id=RN_MF_ID'+
      ' left join IMPORT_CHANGE_NAMES on ICN_TAB_ID=100 and ICN_KE_KEY=mf_id'+
      ' where RN_ART_NR="'+pArticleTD+'" and ds_mf_id='+IntToStr(pArtSupTD)+
      ' and (mf_pc=1 or mf_cv=1 or mf_eng=1 or mf_axle=1)'+
      ' and mf_del=0 order by mfName, mfID, Onum'; // только произв.
    TdtIBS.ExecQuery;
    j:= 0; // счетчик
    while not TdtIBS.Eof do begin
      mfTD  := TdtIBS.fieldByName('mfID').AsInteger;   // код произв.TecDoc
      mfName:= TdtIBS.fieldByName('mfName').AsString;  // наимен. произв.TecDoc
      i:= Manufacturers.GetManufIDByTDcode(mfTD);      // ищем ID произв. по коду TecDoc
      if (i>0) then begin
        setLength(arMFORD, 1); // задаем длину
        arMFORD[0]:= i;
      end else try
        setLength(arMFORD, 0);
        ordIBS.ParamByName('mftd').AsInteger:= mfTD;
        ordIBS.ExecQuery;
        while not ordIBS.Eof do begin
          prAddItemToIntArray(ordIBS.fieldByName('MtaMfau').AsInteger, arMFORD);
          TestCssStopException;
          ordIBS.Next;
        end;
      finally
        ordIBS.Close;
      end;

      while not TdtIBS.Eof and (TdtIBS.fieldByName('mfID').AsInteger=mfTD) do begin
        for i:= 0 to High(arMFORD) do begin
          fl:= (arMFORD[i]>0) and Manufacturers.ManufExists(arMFORD[i]);
          if (High(Result)<j) then setLength(Result, j+10);
          Result[j].ONum:= TdtIBS.fieldByName('Onum').AsString;
          if fl then begin
            Result[j].mfau  := arMFORD[i];
            Result[j].mfName:= Manufacturers[arMFORD[i]].Name;
          end else begin
            Result[j].mfau  := 0;
            Result[j].mfName:= mfName;
          end;
          inc(j);
        end; // for
        TestCssStopException;
        TdtIBS.Next;
      end; // цикл по произв. mfTD
    end;
    if Length(Result)>j then setLength(Result, j);
  except
    on E: Exception do begin
      setLength(Result, 0);
      raise Exception.Create(nmProc+' (WareID='+IntToStr(pWareID)+'): '+E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    cntsTdt.SetFreeCnt(TdtIBD);
    prFreeIBSQL(ordIBS);
    cntsORD.SetFreeCnt(ordIBD);
    setLength(arMFORD, 0);
  end;
end;
//=============================================== сортировка TList бренд + товар
function WareListSortCompare(Item1, Item2: Pointer): Integer;
var w1, w2: TWareInfo;
    s1, s2: String;
begin
  try
    w1:= TWareInfo(Item1);
    w2:= TWareInfo(Item2);
    if w1.WareBrandID<>w2.WareBrandID then begin
      if w1.WareBrandName='' then s1:= 'Не определен' else s1:= w1.WareBrandName;
      if w2.WareBrandName='' then s2:= 'Не определен' else s2:= w2.WareBrandName;
      if s1<>s2 then Result:= AnsiCompareText(s1, s2)
      else if w1.ArtSupTD>w2.ArtSupTD then Result:= 1
      else if w1.ArtSupTD<w2.ArtSupTD then Result:= -1 else Result:= 0;
    end else Result:= AnsiCompareText(w1.Name, w2.Name)
  except
    Result:= 0;
  end;
end;
//===================== 40-stamp - Отчет о проверке привязок товаров к артикулам
function fnGetCheckWareTDTArticles(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
const nmProc = 'fnGetCheckWareTDTArticles'; // имя процедуры/функции
      xChars = 'ABCDEFGHIJKLMNOPQRSTUVWYYZ';
// возвращает список для выгрузки в файл XML
type Rflags = record
    flONs, flAnals, flLinks, flCris: Integer;
  end;
var IBD: TIBDatabase;
    IBS: TIBSQL;
    Widths: Tai;
    Ncolumns, iposWW, iRows, i, WareID, supMF, j, PercentStep, k, ii: integer;
    Percent: real;
    lst1, lst2, lst3, lst4: TStringList;
    lstWares: TList;
    str, sm, sbt, sbg, stw, Art, sEnd1, sEnd2, sTitle, s, ss, sEmpty, wSearch, sGa: String;
    ware: TWareInfo;
    arWareFlags: array of Rflags;
    arTDBrands: Tas;
    flSleep: Boolean;
    tt: TDateTime;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    AddXmlLine(Result, s, 100);
  end;
  //----------------------------------------------
  procedure AddStrWW(s: string);
  begin
    AddXmlLineWW(Result, s, 100);
  end;
  //----------------------------------------------
  procedure CheckStep;
  begin
    CheckStopExecute(pUserID, ThreadData);
    if j>PercentStep then begin
      SetExecutePercent(pUserID, ThreadData, Percent);
      j:= 0;
    end;
  end;
  //----------------------------------------------
begin
  Result:= fnCreateStringList(False, 100);
//  IBD:= nil;
  IBS:= nil;
  lst1:= fnCreateStringList(False, 100);
  lst2:= fnCreateStringList(False, 100);
  lst3:= fnCreateStringList(False, 100);
  lst4:= fnCreateStringList(False, 100);
  lstWares:= TList.Create;
  lstWares.Capacity:= 100000;
  Setlength(arTDBrands, 0);
  SetLength(arWareFlags, 0);
  Ncolumns:= 13;        // кол-во столбцов
  SetLength(Widths, Ncolumns); // задаем ширину столбцов, 0 - AutoFitWidth
  Widths[0]:= 150;  // Товар GrossBee
  Widths[1]:= 90;   // Бренд ТесDoc
  Widths[2]:= 100;  // Артикул TecDoc
  Widths[3]:= 42;   // Статус привязки
  Widths[4]:= 90;   // Менеджер
  Widths[5]:= 40;   // ОН TecDoc
  Widths[6]:= 40;   // Анал.TecDoc
  Widths[7]:= 40;   // Связ.TecDoc
  Widths[8]:= 40;   // Парам.TecDoc
  Widths[9]:= 90;   // Бренд GrossBee
  Widths[10]:= 0;   // Код товара
  Widths[11]:= 180; // Комментарий
  Widths[12]:= 0;   // SupMF TecDoc
  CheckStyle(skHeadBlue);     // задаем нужные стили
  CheckStyle(skBold);
  CheckStyle(skTxt);
  CheckStyle(skTxtWW);
  CheckStyle(skTxtGreenWW);
  CheckStyle(skTxtYellowWW);
  CheckStyle(skTxtRoseWW);
  CheckStyle(skTxtBlueWW);
  Percent:= 0.5;
  PercentStep:= 100;
  flSleep:= not flDebug and not fnGetActionTimeEnable(caeSmallWork);
  with Cache do try try
    SetLength(arWareFlags, Length(arWareInfo)); // составляем список привязанных товаров
    for WareID:= 1 to High(arWareInfo) do if WareExist(WareID) then begin
      ware:= GetWare(WareID);
      if (ware.ArticleTD='') or (ware.ArtSupTD<1) then Continue;
      lstWares.Add(Ware);
      with arWareFlags[WareID] do begin
        flONs  := 0;
        flAnals:= 0;
        flLinks:= 0;
        flCris := 0;
      end;
      CheckStopExecute(pUserID, ThreadData);
    end;
    lstWares.Sort(WareListSortCompare); // сортируем - бренд + товар

    for i:= 0 to BrandTDList.Count-1 do begin // наименования брендов TD
      k:= Integer(BrandTDList.Objects[i]);
      if High(arTDBrands)<k then begin
        j:= length(arTDBrands);
        Setlength(arTDBrands, k+100);
        for WareID:= j to High(arTDBrands) do arTDBrands[WareID]:= '';
      end;
      arTDBrands[k]:= BrandTDList[i];
      CheckStopExecute(pUserID, ThreadData);
    end;
    SetExecutePercent(pUserID, ThreadData, Percent);

    Percent:= 1.5;
    IBD:= cntsORD.GetFreeCnt;       // флаги наличия связок TecDoc товаров в ORD
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, True);
      IBS.SQL.Text:= 'select rWare, flONs, flAnals, flLinks, flCris from GetWaresHasTDinfo';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        WareID:= IBS.FieldByName('rWare').AsInteger;
        if WareExist(WareID) and (WareID<Length(arWareFlags)) then with arWareFlags[WareID] do begin
          flONs  := IBS.FieldByName('flONs').AsInteger;
          flLinks:= IBS.FieldByName('flLinks').AsInteger;
          flCris := IBS.FieldByName('flCris').AsInteger;
        end;
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
      end;
      IBS.Close;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD, True);
    end;
    SetExecutePercent(pUserID, ThreadData, Percent);

    IBD:= cntsGRB.GetFreeCnt; // флаги наличия аналогов TecDoc товаров в Grossbee
    try
      s:= 'AnDtSyncCode-'+Cache.GetConstItem(pcCrossAnalogsDeltaSync).StrValue+
        ') in ('+IntToStr(soTecDocBatch)+', '+IntToStr(soTDparts)+', '+
        IntToStr(soTDsupersed)+'))';
//        IntToStr(soTDsupersed)+', '+IntToStr(soTDold)+'))';

      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, True);
      IBS.SQL.Text:= 'select WareCode from wares w'+
        ' where (exists(select * from pmwareanalogs a1'+ // w.warearchive="F" and
        '  left join AnalitDict d1 on d1.andtcode = a1.pmwasourcecode'+
        ' where a1.pmwawarecode=w.WareCode and (d1.'+s+
        ' or exists(select * from pmwareanalogs a2'+
        '  left join AnalitDict d2 on d2.andtcode = a2.pmwasourcecode'+
        ' where a2.pmwawareanalogcode=w.WareCode and (d2.'+s+') order by WareCode';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        WareID:= IBS.FieldByName('WareCode').AsInteger;
        if (WareID>0) and WareExist(WareID) and (WareID<Length(arWareFlags)) then
          arWareFlags[WareID].flAnals:= 1;
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
      end;
      IBS.Close;
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD, True);
    end;
    SetExecutePercent(pUserID, ThreadData, Percent);

    IBD:= cntsTDT.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, True);
      IBS.SQL.Text:= 'select flag, SupMF_find, art_find, trade_find, GaName'+
                        ' from SearchWareArticles(:Sup, :Art, :Wname)';
      IBS.Prepare;
      sEmpty:= sTxtWWCell('');
      sEnd2:= sEmpty+sEmpty+sEmpty+sEmpty+sEmpty+sEmpty+sEmpty+sEmpty; // для строк без товара
      if lstWares.Count>0 then Percent:= 90*PercentStep/lstWares.Count else Percent:= 1;
      j:= 0; // счетчик для процентов
      tt:= Now;
      for k:= 0 to lstWares.Count-1 do begin
        ware:= lstWares[k];
        WareID:= Ware.ID;
        inc(j);
        i:= Ware.ManagerID;
        if (i<1) or not EmplExist(i) or CheckEmplIsFictive(i) then // Менеджер
          sm:= 'Не определен'
        else sm:= arEmplInfo[i].EmplShortName;
        sbg:= ware.WareBrandName;                          // Бренд GrossBee
        if sbg='' then sbg:= 'Не определен';
        i:= ware.ArtSupTD;
        ss:= IntToStr(i);
        if (i>High(arTDBrands)) or (arTDBrands[i]='') then // Бренд ТесDoc
          sbt:= 'Не определен'
        else sbt:= arTDBrands[i];
        with arWareFlags[WareID] do begin // Наличие связок TecDoc
          if flONs=1 then str:= sTxtGreenCellWW('1') else str:= sEmpty;
          if flAnals=1 then str:= str+sTxtGreenCellWW('1') else str:= str+sEmpty;
          if flLinks=1 then str:= str+sTxtGreenCellWW('1') else str:= str+sEmpty;
          if flCris=1 then str:= str+sTxtGreenCellWW('1') else str:= str+sEmpty;
        end;
        stw:= ware.TypeName;
        if stw<>'' then stw:= sTxtGreenCellWW('GR-тип: '+stw) else stw:= sEmpty;
        sEnd1:= sTxtWWCell(sm)+str+sTxtWWCell(sbg)+sTxtWWCell(IntToStr(WareID))+stw+sTxtWWCell(ss);

        if (sbt='Не определен') then begin // Бренд ТесDoc
          str:= sTxtGreenCellWW(ware.Name)+sTxtYellowCellWW(sbt)+       //  Товар GrossBee, Бренд ТесDoc
                sTxtYellowCellWW(ware.ArticleTD)+sTxtYellowCellWW('1')+sEnd1; // Артикул TecDoc, Статус привязки
          lst4.Add(str); // 4-й лист - артикул не нашли - не определен (старый) Бренд ТесDoc
          CheckStep;
          CheckSleepProc(tt, flSleep);
          Continue;
        end;

        wSearch:= trim(ware.Name);
        if (pos(wSearch[1], xChars)>0) then begin // если 1-й символ-буква
          i:= pos(' ', wSearch); // обрезаем приставку до 1-го пробела
          if (i>0) then wSearch:= copy(wSearch, i+1);
        end;
        i:= pos('     ', wSearch); // обрезаем наименование справа от 5-ти пробелов
        if (i>0) then wSearch:= copy(wSearch, 1, i-1);

        try
          IBS.ParamByName('Sup').AsInteger:= ware.ArtSupTD;
          IBS.ParamByName('Art').AsString:= ware.ArticleTD;
          IBS.ParamByName('Wname').AsString:= wSearch;
          IBS.ExecQuery;
          while not IBS.Eof do begin
            i:= IBS.FieldByName('flag').AsInteger;
            Art:= IBS.FieldByName('art_find').AsString;
            SupMF:= IBS.FieldByName('SupMF_find').AsInteger;
            ss:= IBS.FieldByName('trade_find').AsString;
            sGa:= IBS.FieldByName('GaName').AsString;
// за 1 проход фасуем в списки по листам
            if (i=999) then begin // 1-й лист
              str:= sTxtGreenCellWW(ware.Name)+sTxtYellowCellWW(sbt)+       //  Товар GrossBee, Бренд ТесDoc
                    sTxtYellowCellWW(ware.ArticleTD)+sTxtYellowCellWW('1')+sEnd1; // Артикул TecDoc, Статус привязки
              lst1.Add(str); // 1-й лист - артикул не нашли, искали варианты

            end else if (i=1) or (i=-1) then begin   // 2-й или 3-й лист
              s:= AnsiUpperCase(fnDelSpcAndSumb(ware.ArticleTD));
              with Ware do if (pos(s, NameBS)>0) then
                str:= sTxtGreenCellWW(Name)+sTxtGreenCellWW(sbt)+
                      sTxtGreenCellWW(ArticleTD)+sTxtGreenCellWW('1')+sEnd1
              else str:= sTxtRoseCellWW(Name)+sTxtRoseCellWW(sbt)+
                         sTxtRoseCellWW(ArticleTD)+sTxtRoseCellWW('1')+sEnd1;
              if (i=-1) then lst3.Add(str) // 3-й лист - нашли артикул, варианты не искали
              else lst2.Add(str);          // 2-й лист - нашли артикул и варианты

            end else if (i>1) then begin                 // найденные варианты
              if (SupMF=ware.ArtSupTD) then s:= sbt
              else begin // если другой бренд - проверяем соответствие
                ii:= ware.WareBrandID;
                if (ii>1) and Cache.WareBrands.ItemExists(ii) and // бренд TD не соответствует Grossbee
                  (fnInIntArray(SupMF, TBrandItem(Cache.WareBrands[ii]).TDMFcodes)<0) then s:= ''
                else if (SupMF>High(arTDBrands)) then s:= '' // бренд TD не найден
                else s:= arTDBrands[SupMF];
              end;
              if s<>'' then begin
                str:= sEmpty+sTxtBlueCellWW(s)+sTxtBlueCellWW(Art)+sEnd2;
                if sGa<>'' then sGa:= 'TD-группа: '+sGa;
                if ss='' then ss:= sGa
                else ss:= 'TD-номер польз.: '+ss+fnIfStr(sGa='', '', '                 ')+sGa;
                if (ss<>'') then ss:= sTxtBlueCellWW(ss) else ss:= sEmpty;
                str:= str+ss+sEmpty;
                if (i>999) then lst1.Add(str) // 1-й лист - варианты (не нашли артикул)
                else lst2.Add(str);           // 2-й лист - варианты (нашли артикул)
              end;
            end;
            CheckStopExecute(pUserID, ThreadData);
            IBS.Next;
          end;
        finally
          IBS.Close;
        end;
        CheckStep;
        CheckSleepProc(tt, flSleep);
      end; // for WareID:= 1 to High(arWareInfo)
    finally
      prFreeIBSQL(IBS);
      cntsTDT.SetFreeCnt(IBD, True);
    end;

    CheckStopExecute(pUserID, ThreadData);
    AddXmlBookBegin(Result);
//------------------------------------------------------------- лист с описанием
    AddXmlSheetBegin(Result, 'описание', 1);
    AddStr(sBoldCell('          Отчет о проверке привязки товаров Grossbee к артикулам TecDoc'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('на всех листах:'));
    AddStr(sTxtCell('  первые 4 столбца соответствуют структуре 18/22 отчетов, можно'+
                     ' копировать их ячейки из нужных строк в файл для 18/22 импорта'));
    AddStr(sTxtCell('  в столбцах с заголовками "ОН/аналоги/связки/парам. TecDoc" проставлено'+
                     ' наличие в нашей базе загруженных ориг.N/аналогов/связок/критериев товара'));
    AddStr(sTxtCell('  в столбце "Комментарий" выводится тип товара Grossbee (зеленая заливка)'+
                     ' или группа товара TecDoc/номер польз.TecDoc (голубая заливка)'));
    AddStr(sTxtCell('  голубой заливкой в столбцах В и С выделены найденные артикулы, предлагаемые для связывания'));
    AddStr(sTxtCell('  для того, чтобы перепривязать артикул, нужно в строке с товаром проставить статус'+
                     ' отвязки (-1), а в следующей строке с правильным артикулом проставить статус привязки (1)'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('лист "не найдены":'));
    AddStr(sTxtCell('   желтой заливкой выделены артикулы, которые не найдены в текущей поставке данных TecDoc'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('лист "найдены варианты":'));
    AddStr(sTxtCell('   розовой заливкой выделены строки, в которых артикул найден, но не соответствует'+
                      ' наименованию товара, т.е. есть подозрение о неверной связке'));
    AddStr(sTxtCell('   зеленой заливкой выделены строки, в которых артикул найден, и есть соответствие'+
                      ' с товаром, но найден другой артикул, предположительно более соответствующий товару'));
    AddXmlSheetEnd(Result, 0, 0);

    Percent:= 5;
    sTitle:= sHeadBlueCell('Товар GrossBee')+sHeadBlueCell('Бренд ТесDoc')+ // 1, 2 - индекс ячейки
      sHeadBlueCell('Артикул TecDoc')+sHeadBlueCell('Статус привяз.')+      // 3, 4 - индекс ячейки
      sHeadBlueCell('Менеджер')+sHeadBlueCell('ОН TecDoc')+                 // 5, 6 - индекс ячейки
      sHeadBlueCell('аналоги TecDoc')+sHeadBlueCell('связки TecDoc')+         // 7, 8 - индекс ячейки
      sHeadBlueCell('парам. TecDoc')+sHeadBlueCell('Бренд GrossBee')+       // 9, 10 - индекс ячейки
      sHeadBlueCell('Код товара')+sHeadBlueCell('Комментарий')+sHeadBlueCell('SupMF TecDoc'); // 11, 12, 13 - индекс ячейки
// 1-й лист
    j:= 0; // счетчик для процентов
    if lst1.Count>0 then Percent:= 4*PercentStep/lst1.Count else Percent:= 1;
    iposWW:= AddXmlSheetBegin(Result, 'не найдены', Ncolumns, Widths); // индекс строки с <Table...>
    iRows:= 1; // счетчик строк листа
    AddStrWW(sTitle);
    for i:= 0 to lst1.Count-1 do begin
      AddStrWW(lst1[i]);
      inc(iRows);
      CheckStep;
    end;
    SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
    AddXmlSheetEnd(Result, 1, 1);
    SetExecutePercent(pUserID, ThreadData, Percent);
// 2-й лист
    j:= 0; // счетчик для процентов
    if lst2.Count>0 then Percent:= 4*PercentStep/lst2.Count else Percent:= 1;
    iposWW:= AddXmlSheetBegin(Result, 'найдены варианты', Ncolumns, Widths); // индекс строки с <Table...>
    iRows:= 1; // счетчик строк листа
    AddStrWW(sTitle);
    for i:= 0 to lst2.Count-1 do begin
      AddStrWW(lst2[i]);
      inc(iRows);
      CheckStep;
    end;
    SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
    AddXmlSheetEnd(Result, 1, 1);
    SetExecutePercent(pUserID, ThreadData, Percent);
// 3-й лист
    j:= 0; // счетчик для процентов
    if lst3.Count>0 then Percent:= 4*PercentStep/lst3.Count else Percent:= 1;
    iposWW:= AddXmlSheetBegin(Result, 'найдены (проверить)', Ncolumns, Widths); // индекс строки с <Table...>
    iRows:= 1; // счетчик строк листа
    AddStrWW(sTitle);
    for i:= 0 to lst3.Count-1 do begin
      AddStrWW(lst3[i]);
      inc(iRows);
      CheckStep;
    end;
    SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
    AddXmlSheetEnd(Result, 1, 1);
    SetExecutePercent(pUserID, ThreadData, Percent);
// 4-й лист
    j:= 0; // счетчик для процентов
    if lst4.Count>0 then Percent:= 4*PercentStep/lst4.Count else Percent:= 1;
    iposWW:= AddXmlSheetBegin(Result, 'не найден бренд TD', Ncolumns, Widths); // индекс строки с <Table...>
    iRows:= 1; // счетчик строк листа
    AddStrWW(sTitle);
    for i:= 0 to lst4.Count-1 do begin
      AddStrWW(lst4[i]);
      inc(iRows);
      CheckStep;
    end;
    SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
    AddXmlSheetEnd(Result, 1, 1);
    SetExecutePercent(pUserID, ThreadData, Percent);

  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache
  finally
    AddXmlBookEnd(Result);
    Setlength(arTDBrands, 0);
    SetLength(arWareFlags, 0);
    Setlength(Widths, 0);
    prFree(lst1);
    prFree(lst2);
    prFree(lst3);
    prFree(lst4);
    prFree(lstWares);
  end;
end;
//==================================== перечень инфо-текстов TecDoc для перевода
function fnGetInfoTextsForTranslate(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
// возвращает список для выгрузки в файл XML                             // переделать !!!
const nmProc = 'fnGetInfoTextsForTranslate'; // имя процедуры/функции
var IBD: TIBDatabase;
    IBS: TIBSQL;
    Widths: Tai;
    Ncolumns, iposWW, iRows, i, j, iSup: integer;
    Percent: real;
    lstProblems: TStringList;
    str, sTitle, sArt, sSup: String;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    AddXmlLine(Result, s, 100);
  end;
  //----------------------------------------------
  procedure AddStrWW(s: string);
  begin
    AddXmlLineWW(Result, s, 100);
  end;
  //----------------------------------------------
begin
  Result:= fnCreateStringList(False, 100);
  IBS:= nil;
  lstProblems:= fnCreateStringList(False, 100);
  Ncolumns:= 7;        // кол-во столбцов
  Setlength(Widths, Ncolumns);
  Widths[0]:= 0;       // задаем ширину столбцов, 0 - AutoFitWidth
  Widths[1]:= 250;
  Widths[2]:= 250;
  Widths[3]:= 0;
  Widths[4]:= 150;
  Widths[5]:= 150;
  Widths[6]:= 0;
  CheckStyle(skHeadBlue);     // задаем нужные стили
  CheckStyle(skTxtWW);
  CheckStyle(skTxtGreenWW);
  CheckStyle(skTxtYellowWW);
  CheckStyle(skTxt);
  CheckStyle(skBold);
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  with Cache do try try
    IBD:= cntsORD.GetFreeCnt('', '', '', True);
    try
      AddXmlBookBegin(Result);
  //------------------------------------------------------------- лист с описанием
      AddXmlSheetBegin(Result, 'описание', 1);
      AddStr(sBoldCell('          замены текстов TecDoc для отображения в системе заказов'));
      AddStr(sTxtCell(''));
      AddStr(sBoldCell('на листе "ЗАМЕНЫ" - тексты TecDoc, не имеющие перевода,'));
      AddStr(sTxtCell('    в строках, где перевод не нужен (аббревиатуры, правильный русский текст и т.п.),'+
                           ' должна стоять опция "/-1", в дальнейшем такие тексты обрабатываться не будут,'));
      AddStr(sTxtCell('    в строках с новыми переводами должна стоять опция "/1",'+
                           ' НЕЛЬЗЯ переименовывать лист и менять на нем порядок столбцов,'));
      AddStr(sTxtCell('    изменять МОЖНО ТОЛЬКО ячейки в столбцах "перевод" и "опция" (выделены цветом),'+
                           ' МОЖНО удалить строки, в которых не задана опция'));
{      AddStr(sBoldCell('на листе "вопросы" - тексты TecDoc с переводами из базы, требующие проверки,'));
      AddStr(sTxtCell('    лист информационный, не обрабатывается,'));
      AddStr(sTxtCell('    если перевод в строке заменяется, эту строку необходимо'+
                           ' скопировать/переместить на лист "ЗАМЕНЫ" с опцией "/3",'));
      AddStr(sTxtCell('    изменять МОЖНО ТОЛЬКО ячейки в столбцах "перевод" и "опция" (выделены цветом),'+
                           ' НЕЛЬЗЯ менять порядок столбцов на листе'));  }
      AddStr(sBoldCell('на листе "проблемы" - тексты TecDoc, не представляющие возможность перевода,'));
      AddStr(sTxtCell('    лист информационный, не обрабатывается,'));
      AddStr(sTxtCell('    под строками с текстами могут быть указаны артикулы TecDoc,'+
                           ' по которым встречаются такие тексты'));
      AddStr(sTxtCell('       (и модели, если текст можно увидеть только при выборе модели),'+
                              ' для поиска оригинальных текстов в англоязычной версии TecDoc,'));
      AddStr(sTxtCell('    если перевод найден, строку необходимо скопировать/переместить'+
                           ' на лист "ЗАМЕНЫ" с опцией "/1",'));
      AddStr(sTxtCell('    изменять МОЖНО ТОЛЬКО ячейки в столбцах "перевод" и "опция" (выделены цветом),'+
                           ' НЕЛЬЗЯ менять порядок столбцов на листе'));
      AddStr(sBoldCell('на листе "переводы" - тексты TecDoc с переводами из базы для сравнения,'));
      AddStr(sTxtCell('    лист информационный, не обрабатывается,'));
      AddStr(sTxtCell('    если требуется замена перевода, строку с изменениями'+
                           ' необходимо скопировать/переместить на лист "ЗАМЕНЫ" с опцией "/3",'));
      AddStr(sTxtCell('    изменять МОЖНО ТОЛЬКО ячейки в столбцах "перевод" и "опция" (выделены цветом),'+
                           ' НЕЛЬЗЯ менять порядок столбцов на листе'));
      AddStr(sBoldCell('на листе "без перевода" - тексты TecDoc, отмеченные как не требующие перевода,'));
      AddStr(sTxtCell('    лист информационный, не обрабатывается,'));
      AddStr(sTxtCell('    если требуется перевод, строку необходимо скопировать/переместить на лист "ЗАМЕНЫ" с опцией "/1",'));
      AddStr(sTxtCell(''));
      AddStr(sBoldCell(' При импорте:'));
      AddStr(sTxtCell(' - в файле импорта не должно быть скрытых строк или столбцов, фильтра и т.п.,'));
      AddStr(sTxtCell(' - форматы файла импорта - ".xml", ".xls"(Excel2003),'));
      AddStr(sTxtCell(' - обрабатывается только лист "ЗАМЕНЫ" и строки с опциями "/1", "/-1", "/3",'));
      AddStr(sTxtCell(' - результат обработки строки записывается в столбец "Результат",'));
      AddStr(sTxtCell(' - при успешной обработке строки ячейка "опция" заменяется на "/0".'));
      AddXmlSheetEnd(Result, 0, 0);

      IBS:= fnCreateNewIBSQL(IBD, 'IBS_ORD_'+nmProc, -1, tpWrite, True);
                                    // чистим неиспользуемые тексты без перевода
      IBS.SQL.Text:= 'delete from infotexts where (italtern<1)'+
        ' and not exists(select * from wareinfotexts where wittextcode=itcode)';
      IBS.ExecQuery;
      IBS.Transaction.Commit;
      IBS.Close;

      fnSetTransParams(IBS.Transaction, tpRead, True);
      IBS.SQL.Text:= 'select count(*) from wareinfotexts';
      IBS.ExecQuery;
      if not (IBS.Eof and IBS.Bof) and (IBS.fields[0].AsInteger>1) then
        Percent:= 90/IBS.fields[0].AsInteger;
      IBS.Close;
      sTitle:= sHeadBlueCell('ITCODE')+sHeadBlueCell('текст TecDoc')+
        sHeadBlueCell('перевод')+ sHeadBlueCell('опция')+
        sHeadBlueCell('Результат')+sHeadBlueCell('ittext3')+sHeadBlueCell('исп.');

  //----------------------------------------------- лист с текстами для перевода
      iposWW:= AddXmlSheetBegin(Result, 'ЗАМЕНЫ', Ncolumns, Widths); // индекс строки с <Table...>
      iRows:= 1; // счетчик строк листа
      AddStr(sTitle);
      IBS.SQL.Text:= 'select ITCODE, ITTEXT,'+
        ' iif(exists(select * from wareinfotexts where wittextcode=itcode), 1, 0) as TextUse'+
        ' from infotexts where italtern=0 order by ITTEXT';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        if (IBS.fieldByName('TextUse').AsInteger>0) then sSup:= '/1' else sSup:= '';
        str:= sTxtWWCell(IBS.fieldByName('ITCODE').AsString)+
              sTxtYellowCellWW(IBS.fieldByName('ITTEXT').AsString)+
              sTxtGreenCellWW('')+sTxtGreenCellWW(sSup)+sTxtWWCell('')+sTxtWWCell('')+
              sTxtWWCell(IBS.fieldByName('TextUse').AsString);
        sArt:= IBS.fieldByName('ITTEXT').AsString;
        if (pos('???', sArt)>0) or (pos('їїї', sArt)>0) or (pos('ЇЇЇ', sArt)>0) then begin
          i:= IBS.fieldByName('ITCODE').AsInteger;
          lstProblems.AddObject(str, Pointer(i)); // собираем проблемы
        end else begin
          AddStrWW(str);
          inc(iRows);
        end;
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
        SetExecutePercent(pUserID, ThreadData, Percent);
      end; // while not IBS.Eof and (id1=
      IBS.Close;
      SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
      AddXmlSheetEnd(Result, 1, 1);
(*
  //--- лист с вопросами (тексты с переводами, измененные при последней заливке)
      iposWW:= AddXmlSheetBegin(Result, 'вопросы', Ncolumns, Widths);
      AddStr(sTitle);
      iRows:= 1; // счетчик строк листа
      with IBS.Transaction do if not InTransaction then StartTransaction;
      IBS.SQL.Text:= 'select WITCODE, WITSUPTD, "#"||WITTMTD WITTMTD, WITTEXT, vittext'+
        ' from wareinfotexts left join linkinfotextvalues'+
        '   on litvsuptd=witsuptd and litvtmtd=wittmtd and LITVWRONG="F"'+
        ' left join valuesinfotexts on vitcode=litvvit'+
        ' where witaltern=1 and '+sPeriod+' order by WITTEXT';
      IBS.ParamByName('TestTime1').AsDateTime:= TestTime1;
      IBS.ParamByName('TestTime2').AsDateTime:= TestTime2;
      IBS.ExecQuery;
      while not IBS.Eof do begin
        AddStrWW(sTxtWWCell(IBS.fieldByName('WITCODE').AsString)+
                 sTxtWWCell(IBS.fieldByName('WITSUPTD').AsString)+
                 sTxtWWCell(IBS.fieldByName('WITTMTD').AsString)+
                 sTxtWWCell(IBS.fieldByName('WITTEXT').AsString)+
                 sTxtGreenCellWW(IBS.fieldByName('vittext').AsString)+
                 sTxtGreenCellWW('/3')+sTxtWWCell('')+sTxtWWCell(''));
        inc(iRows);
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
        SetExecutePercent(pUserID, ThreadData, Percent);
      end; // while not IBS.Eof and (id1=
      IBS.Close;
      SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
      AddXmlSheetEnd(Result, 1, 1);
*)
  //---------------------------------------------------------- лист с проблемами
      iposWW:= AddXmlSheetBegin(Result, 'проблемы', Ncolumns, Widths);
      AddStr(sTitle);
      iRows:= 1; // счетчик строк листа
      with IBS.Transaction do if not InTransaction then StartTransaction;
      IBS.SQL.Text:= 'select rWare, rMod, rNod from GetWaresForBadTexts('+
        '(select first 1 witcode from wareinfotexts where wittextcode=:it))';
      for i:= 0 to lstProblems.Count-1 do begin
        AddStrWW(lstProblems[i]);
        inc(iRows);
        j:= Integer(lstProblems.Objects[i]);
        IBS.ParamByName('it').AsInteger:= j;
        IBS.ExecQuery;
        while not IBS.Eof do begin // артикулы для проблемных текстов
          j:= IBS.fieldByName('rWare').AsInteger;
          sArt:= '';
          sSup:= '';
          iSup:= 0;
          if (j>0) and WareExist(j) then with GetWare(j) do begin
            iSup:= ArtSupTD;
            sArt:= ArticleTD;
          end;
          if iSup>0 then for j:= 0 to BrandTDList.Count-1 do  // наименования бренда TD
            if Integer(BrandTDList.Objects[j])=iSup then begin
              sSup:= BrandTDList[j];
              break;
            end;
          if (sArt<>'') and (sSup<>'') then begin
            sArt:= sTxtWWCell('')+sTxtWWCell(sSup+', '+sArt+', '+IBS.fieldByName('rMod').AsString);
            str:= IBS.fieldByName('rNod').AsString;
            j:= pos(' (TD', str);
            if (j>0) then str:= copy(str, 1, j-1);
            AddStrWW(sArt+sTxtWWCell(str)+sTxtWWCell('')+sTxtWWCell('')+sTxtWWCell(''));
            inc(iRows);
          end;
          CheckStopExecute(pUserID, ThreadData);
          IBS.Next;
        end; // while not IBS.Eof
        IBS.Close;
      end;
      SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
      AddXmlSheetEnd(Result, 1, 1);

  //------------------------------------ лист с переводами из базы для сравнения
      iposWW:= AddXmlSheetBegin(Result, 'переводы', Ncolumns, Widths);
      AddStr(sTitle);
      iRows:= 1; // счетчик строк листа
      with IBS.Transaction do if not InTransaction then StartTransaction;
      IBS.SQL.Text:= 'select ITCODE, ITTEXT, itatext,'+
        ' iif(exists(select * from wareinfotexts where wittextcode=itcode), 1, 0) as TextUse'+
        ' from infotexts left join infotextsaltern on itacode=italtern'+
        ' where italtern>0 order by ITTEXT';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        AddStrWW(sTxtWWCell(IBS.fieldByName('ITCODE').AsString)+
                 sTxtWWCell(IBS.fieldByName('ITTEXT').AsString)+
                 sTxtGreenCellWW(IBS.fieldByName('itatext').AsString)+
                 sTxtGreenCellWW('')+sTxtWWCell('')+sTxtWWCell('')+
                 sTxtWWCell(IBS.fieldByName('TextUse').AsString));
        inc(iRows);
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
        SetExecutePercent(pUserID, ThreadData, Percent);
      end; // while not IBS.Eof and (id1=
      IBS.Close;
      SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
      AddXmlSheetEnd(Result, 1, 1);

  //--------------------------------------- лист с текстами без перевода из базы
      iposWW:= AddXmlSheetBegin(Result, 'без перевода', Ncolumns, Widths);
      iRows:= 1; // счетчик строк листа
      AddStr(sTitle);

      with IBS.Transaction do if not InTransaction then StartTransaction;
      IBS.SQL.Text:= 'select ITCODE, ITTEXT,'+
        ' iif(exists(select * from wareinfotexts where wittextcode=itcode), 1, 0) as TextUse'+
        ' from infotexts where italtern=-1 order by ITTEXT';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        AddStrWW(sTxtWWCell(IBS.fieldByName('ITCODE').AsString)+
                 sTxtWWCell(IBS.fieldByName('ITTEXT').AsString)+
                 sTxtGreenCellWW('')+sTxtGreenCellWW('')+sTxtWWCell('')+sTxtWWCell('')+
                 sTxtWWCell(IBS.fieldByName('TextUse').AsString));
        inc(iRows);
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
        SetExecutePercent(pUserID, ThreadData, Percent);
      end; // while not IBS.Eof and (id1=
      IBS.Close;
      SetXmlSheetWWoptions(Result, iposWW, Ncolumns, iRows); // устанавливаем опции worksheet для WordWrap
      AddXmlSheetEnd(Result, 1, 1);
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD, True);
      AddXmlBookEnd(Result);
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache
  finally
    Setlength(Widths, 0);
    prFree(lstProblems);
  end;
end;
(*//===================================== 34-stamp - поиск новых узлов авто из TDT
function fnGetNewTreeNodesFromTDT(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
// возвращает список для выгрузки в файл XML
const nmProc = 'fnGetNewTreeNodesFromTDT'; // имя процедуры/функции
var IBD: TIBDatabase;
    IBS: TIBSQL;
    nodeGA, ParGA, nodeORD, Ncolumns, id1, id2, id3, id4: integer;
    nameGA, nameSys, name1, name2, name3, name4, Sname1, Sname2, Sname3, Sname4: string;
    Widths: Tai;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    Percent: real;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    if Result.Capacity=Result.Count then Result.Capacity:= Result.Capacity+1000;
    AddXmlLine(Result, s);
  end;
  //----------------------------------------------
begin

    Result:= fnGetNewTreeNodesFromTDT_new(pUserID, ThreadData);
    Exit;

  Result:= fnCreateStringList(False, 1000);
  IBS:= nil;
//  IBD:= nil;
  Ncolumns:= 13;
  Setlength(Widths, Ncolumns);
  Widths[1]:= 150;
  Widths[2]:= 150;
  Widths[3]:= 150;
  Widths[4]:= 150;
  Widths[8]:= 150;
  Widths[9]:= 150;
  Widths[12]:= 100; // Результат
  CheckStyle(skTxt);
  CheckStyle(skHead);
  CheckStyle(skBold);
  CheckStyle(skTxtGreen);
  CheckStyle(skBoldGreen);
  CheckStyle(skTxtYellow);
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  with Cache.FDCA do try try
    nodes:= AutoTreeNodesSys[constIsAuto];
    Percent:= 90/nodes.NodesList.Count/2;
    AddXmlBookBegin(Result);
//------------------------------------------------------------- лист с описанием
    AddXmlSheetBegin(Result, 'описание', 1);
    AddStr(sBoldCell('   Узлы легковых авто'));
    AddStr(sTxtCell(' На листе "узлы авто" содержится перечень конечных узлов с 4 уровнями родительских узлов.'));
    AddStr(sTxtCell('   (Узлы ветви "Мотоцикл" исключены).'));
    AddStr(sTxtCell(' Если в TecDoc найдены новые узлы, строки с новыми конечными и родительскими узлами расположены'));
    AddStr(sTxtCell('   в начале листа с опцией "добавить", параметры новых узлов выделены зеленой заливкой ячеек.'));
    AddStr(sTxtCell(' Перечень узлов в нашей базе: видимость=1 - без заливки, видимость=0 - выделены желтой заливкой.'));
    AddStr(sBoldCell(' В строках с новыми узлами:'));
    AddStr(sTxtCell(' - желательно проверить наименования в ячейках с жирным шрифтом, т.к. в TecDoc часто встречаются ошибки,'));
    AddStr(sTxtCell(' - наименования родительских узлов - в столбце соответствующего уровня, конечных узлов - в столбце "Конечный узел",'));
    AddStr(sTxtCell(' - жирным шрифтом выделены изменяемые ячейки, значения которых при импорте будут записываться в базу из файла:'));
    AddStr(sTxtCell('   наименование и видимость, в строках конечных узлов - глав.код узла (из перечня узлов в нашей базе).'));
    AddStr(sBoldCell(' В строках существующих узлов:'));
    AddStr(sTxtCell(' - можно изменить значения в столбцах "Конечный узел"(наименование), "Видим."(видимость)'));
    AddStr(sTxtCell('   и "Главн."(глав.код конечного узла), значения в столбце "Код" изменять нельзя,'));
    AddStr(sTxtCell(' - изменение глав.кода возможно 2-х видов - сделать главный узел дублирующим или сделать дублирующий узел главным,'));
    AddStr(sTxtCell('   переподчинение (замена глав.кода у дублирующего узла) не предусмотрено, при необходимости это можно сделать в 2 этапа:'));
    AddStr(sTxtCell('   сделать дублирующий узел главным, а затем сделать его дублирующим с другим глав.кодом,'));
    AddStr(sTxtCell(' - для обработки изменения параметров узла нужно в столбец "опция" записать значение "изменить".'));
    AddStr(sBoldCell(' При подготовке импорта:'));
    AddStr(sTxtCell(' - строки с новыми конечными узлами можно переставить на нужное место в перечне узлов, строки с новыми родительскими узлами'));
    AddStr(sTxtCell('   желательно оставить в начале листа, т.к. строки с родительскими узлами должны быть выше строк с конечными узлами,'));
    AddStr(sTxtCell(' - при перестановке нужно переносить всю строку, чтобы сохранить соответствие с кодами TD,'));
    AddStr(sTxtCell(' - в случае сортировки данных необходимо выделять все столбцы до столбца "Результат", перед импортом желательно отменить сортировку,'));
    AddStr(sTxtCell(' - значения в строках с опцией "добавить", кроме перечисленных выше, изменять нельзя,'));
    AddStr(sTxtCell(' - на листе "узлы авто" нельзя менять порядок столбцов, изменение цвета ячеек допускается.'));
    AddStr(sBoldCell(' При импорте:'));
    AddStr(sTxtCell(' - в файле импорта не должно быть скрытых строк или столбцов, фильтра и т.п.,'));
    AddStr(sTxtCell(' - формат файла импорта - ".xml", или для Excel2003 ".xls", или для Excel2007 и выше ".xlsx",'));
    AddStr(sTxtCell(' - обрабатываются только листы, в наименовании которых есть слово "узлы", и строки с опциями "добавить" или "изменить",'));
    AddStr(sTxtCell(' - все значения в строках с опцией "изменить", кроме перечисленных выше, игнорируются,'));
    AddStr(sTxtCell(' - результат обработки строки записывается в столбец "Результат", при успешной обработке строки ячейка "опция" очищается.'));
    AddXmlSheetEnd(Result, 0, 0);
//---------------------------------------------------------------- лист с узлами
    AddXmlSheetBegin(Result, 'узлы авто', Ncolumns, Widths);
//                       0                 1                  2                  3          индекс поля ADOTable
    AddStr(sHeadCell('опция')+sHeadCell('уровень 1')+sHeadCell('уровень 2')+sHeadCell('уровень 3')+
//                 4                 5                6                 7               8   индекс поля ADOTable
      sHeadCell('уровень 4')+sHeadCell('Код')+sHeadCell('Главн.')+sHeadCell('Видим.')+sHeadCell('Конечный узел')+
//                 9                 10                 11                 12               индекс поля ADOTable
      sHeadCell('Сист.наимен.')+sTxtCell('kodTD')+sTxtCell('ParTD')+sHeadCell('Результат'));
//------------------------------------------- недостающие узлы
    IBD:= cntsTDT.GetFreeCnt('', '', '', True);
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_TDT_'+nmProc, -1, tpRead, true);
      IBS.SQL.Text:= 'select name4, name3, name2, name1, ga_id, ga_name,'+
                     ' id1, id2, id3, id4 from GetTreeNodesFor34rep(1, 0)';
      with IBS.Transaction do if not InTransaction then StartTransaction;
      IBS.ExecQuery;
      while not IBS.Eof do begin
        id4    := IBS.fieldByName('id4').AsInteger; //------- узел TD 1-го уровня
        nodeORD:= Nodes.GetNodeIDByTDcodes(id4, 0, False);
        if nodeORD<1 then begin // если узла в ORD нет
          name4  := trim(IBS.fieldByName('name4').AsString);
          Sname4 := sTxtGreenCell(name4);
          nameSys:= AnsiUpperCase(name4)+' (TD '+IntToStr(id4)+')';
          AddStr(sTxtGreenCell(sActionAdd)+sBoldGreenCell(name4)+sTxtCell('')+sTxtCell('')+
            sTxtCell('')+sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
            sTxtGreenCell(nameSys)+sIntGreenCell(id4)+sIntGreenCell(0)+sTxtGreenCell(''));
        end else begin
          node:= Nodes[nodeORD];
          name4:= Node.Name;
          if node.IsVisible then Sname4:= sTxtCell(name4)
          else Sname4:= sTxtYellowCell(name4);
        end;
        ParGA:= id4;

        while not IBS.Eof and (id4=IBS.fieldByName('id4').AsInteger) do begin
          id3  := IBS.fieldByName('id3').AsInteger;
          name3:= trim(IBS.fieldByName('name3').AsString);
          if id3>0 then begin //------------------ если есть узел TD 2-го уровня
            nodeORD:= Nodes.GetNodeIDByTDcodes(id3, id4, False);
            if nodeORD<1 then begin // если узла в ORD нет
              nameSys:= AnsiUpperCase(name3)+' (TD '+IntToStr(id3)+')';
              Sname3 := sTxtGreenCell(name3);
              AddStr(sTxtGreenCell(sActionAdd)+Sname4+sBoldGreenCell(name3)+sTxtCell('')+
                sTxtCell('')+sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
                sTxtGreenCell(nameSys)+sIntGreenCell(id3)+sIntGreenCell(id4)+sTxtGreenCell(''));
            end else begin
              node:= Nodes[nodeORD];
              name3:= Node.Name;
              if node.IsVisible then Sname3:= sTxtCell(name3)
              else Sname3:= sTxtYellowCell(name3);
            end;
            ParGA:= id3;
          end else Sname3:= sTxtCell(name3);

          while not IBS.Eof and (id4=IBS.fieldByName('id4').AsInteger)
            and (id3=IBS.fieldByName('id3').AsInteger) do begin
            id2  := IBS.fieldByName('id2').AsInteger;
            name2:= trim(IBS.fieldByName('name2').AsString);
            if id2>0 then begin //---------------- если есть узел TD 3-го уровня
              nodeORD:= Nodes.GetNodeIDByTDcodes(id2, id3, False);
              if nodeORD<1 then begin // если узла в ORD нет
                nameSys:= AnsiUpperCase(name2)+' (TD '+IntToStr(id2)+')';
                Sname2 := sTxtGreenCell(name2);
                AddStr(sTxtGreenCell(sActionAdd)+Sname4+Sname3+sBoldGreenCell(name2)+
                  sTxtCell('')+sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
                  sTxtGreenCell(nameSys)+sIntGreenCell(id2)+sIntGreenCell(id3)+sTxtGreenCell(''));
              end else begin
                node:= Nodes[nodeORD];
                name2:= Node.Name;
                if node.IsVisible then Sname2:= sTxtCell(name2)
                else Sname2:= sTxtYellowCell(name2);
              end;
              ParGA:= id2;
            end else Sname2:= sTxtCell(name2);

            while not IBS.Eof and (id4=IBS.fieldByName('id4').AsInteger)
              and (id3=IBS.fieldByName('id3').AsInteger)
              and (id2=IBS.fieldByName('id2').AsInteger) do begin
              id1  := IBS.fieldByName('id1').AsInteger;
              name1:= trim(IBS.fieldByName('name1').AsString);
              if id1>0 then begin //-------------- если есть узел TD 4-го уровня
                nodeORD:= Nodes.GetNodeIDByTDcodes(id1, id2, False);
                if nodeORD<1 then begin // если узла в ORD нет
                  nameSys:= AnsiUpperCase(name1)+' (TD '+IntToStr(id1)+')';
                  Sname1 := sTxtGreenCell(name1);
                  AddStr(sTxtGreenCell(sActionAdd)+Sname4+Sname3+Sname2+sBoldGreenCell(name1)+
                    sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
                    sTxtGreenCell(nameSys)+sIntGreenCell(id1)+sIntGreenCell(id2)+sTxtGreenCell(''));
                end else begin
                  node:= Nodes[nodeORD];
                  name1:= Node.Name;
                  if node.IsVisible then Sname1:= sTxtCell(name1)
                  else Sname1:= sTxtYellowCell(name1);
                end;
                ParGA:= id1;
              end else Sname1:= sTxtCell(name1);

              while not IBS.Eof and (id4=IBS.fieldByName('id4').AsInteger)
                and (id3=IBS.fieldByName('id3').AsInteger)
                and (id2=IBS.fieldByName('id2').AsInteger)
                and (id1=IBS.fieldByName('id1').AsInteger) do begin
                nodeGA := IBS.fieldByName('ga_id').AsInteger; //---- группа TD
                nodeORD:= Nodes.GetNodeIDByTDcodes(nodeGA, ParGA, True);
                if nodeORD<1 then begin // если конечного узла в ORD нет
                  nameGA := trim(IBS.fieldByName('ga_name').AsString);
                  nameSys:= AnsiUpperCase(nameGA)+' (TD '+IntToStr(ParGA)+' GA '+IntToStr(nodeGA)+')';
                  AddStr(sTxtGreenCell(sActionAdd)+Sname4+Sname3+Sname2+Sname1+
                    sIntCell(0)+sIntBoldGreenCell(0)+sIntBoldGreenCell(1)+sBoldGreenCell(nameGA)+
                    sTxtGreenCell(nameSys)+sIntGreenCell(nodeGA)+sIntGreenCell(ParGA)+sTxtGreenCell(''));
                end;
                CheckStopExecute(pUserID, ThreadData);
                IBS.Next;
                SetExecutePercent(pUserID, ThreadData, Percent);
              end; // while not IBS.Eof and (id1=
            end; // while not IBS.Eof and (id2=
          end; // while not IBS.Eof and (id3=
        end; // while not IBS.Eof and (id4=
      end; // while not IBS.Eof
    finally
      prFreeIBSQL(IBS);
      cntsTDT.SetFreeCnt(IBD, True);
    end;
//------------------------------------------- узлы в нашей базе
    AddStr(sTxtCell(''));

    IBD:= cntsORD.GetFreeCnt('', '', '', True);
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_ORD_'+nmProc, -1, tpRead, true);
      IBS.ParamCheck:= False;
      IBS.SQL.Add('execute block returns (nm4 varchar(100), nm3 varchar(100), nm2 varchar(100),');
      IBS.SQL.Add('  nm1 varchar(100), node integer, Main integer, nvis varchar(1), name varchar(100),');
      IBS.SQL.Add('  nmSys varchar(100), parent integer, kodTD integer,');
      IBS.SQL.Add('  node1 integer, node2 integer, node3 integer, node4 integer)');
      IBS.SQL.Add('as  declare variable Sys integer=1; begin nmSys=""; parent=0; kodTD=0;');
      IBS.SQL.Add('  parent=0; node=0; Main=0; nm1=""; nm2=""; nm3=""; nm4=""; name="";');
      IBS.SQL.Add('  node1=0; node2=0; node3=0; node4=0;');

      IBS.SQL.Add('  for select t4.trnacode, t4.trnaname from TREENODESAUTO t4');
      IBS.SQL.Add('    where t4.trnadtsycode=:Sys and (t4.trnacodeparent is null');
      IBS.SQL.Add('      or t4.trnacodeparent=0) order by t4.trnaname');
      IBS.SQL.Add('  into :node4, :nm4 do begin nm1=""; nm2=""; nm3=""; name=""; node1=0; node2=0; node3=0;');
      IBS.SQL.Add('    if (not exists(select * from TREENODESAUTO t3 where t3.trnadtsycode=:Sys');
      IBS.SQL.Add('      and t3.trnacodeparent=:node4 and t3.trnatdga="F")) then begin');
      IBS.SQL.Add('      if (exists(select * from TREENODESAUTO t3 where t3.trnadtsycode=:Sys');
      IBS.SQL.Add('        and t3.trnacodeparent=:node4 and t3.trnatdga="T" )) then begin parent=node4;');
      IBS.SQL.Add('        for select t3.trnacode, t3.trnatdcode, t3.trnamaincode, IIF (t3.trnavisible="T", 1, 0),');
      IBS.SQL.Add('          t3.trnaname, t3.trnanamesys from TREENODESAUTO t3 where t3.trnadtsycode=:Sys');
      IBS.SQL.Add('          and t3.trnacodeparent=:node4 and t3.trnatdga="T" order by t3.trnaname');
      IBS.SQL.Add('        into :node, :kodTD, :Main, :nvis, :name, :nmSys do suspend; end');

      IBS.SQL.Add('    end else begin for select t3.trnacode, t3.trnaname from TREENODESAUTO t3');
      IBS.SQL.Add('      where t3.trnadtsycode=:Sys and t3.trnacodeparent=:node4 and t3.trnatdga="F"');
      IBS.SQL.Add('      order by t3.trnaname into :node3, :nm3 do begin nm1=""; nm2=""; node1=0; node2=0;');
      IBS.SQL.Add('      if (not exists(select * from TREENODESAUTO t2 where t2.trnadtsycode=:Sys');
      IBS.SQL.Add('        and t2.trnacodeparent=:node3 and t2.trnatdga="F")) then begin');
      IBS.SQL.Add('        if (exists(select * from TREENODESAUTO t2 where t2.trnadtsycode=:Sys');
      IBS.SQL.Add('          and t2.trnacodeparent=:node3 and t2.trnatdga="T" )) then begin parent=node3;');
      IBS.SQL.Add('          for select t2.trnacode, t2.trnatdcode, t2.trnamaincode, IIF (t2.trnavisible="T", 1, 0),');
      IBS.SQL.Add('            t2.trnaname, t2.trnanamesys from TREENODESAUTO t2 where t2.trnadtsycode=:Sys');
      IBS.SQL.Add('            and t2.trnacodeparent=:node3 and t2.trnatdga="T" order by t2.trnaname');
      IBS.SQL.Add('          into :node, :kodTD, :Main, :nvis, :name, :nmSys do suspend; end');

      IBS.SQL.Add('      end else begin for select t2.trnacode, t2.trnaname from TREENODESAUTO t2');
      IBS.SQL.Add('        where t2.trnadtsycode=:Sys and t2.trnacodeparent=:node3 and t2.trnatdga="F"');
      IBS.SQL.Add('        order by t2.trnaname into :node2, :nm2 do begin nm1=""; node1=0;');
      IBS.SQL.Add('        if (not exists(select * from TREENODESAUTO t1 where t1.trnadtsycode=:Sys');
      IBS.SQL.Add('          and t1.trnacodeparent=:node2 and t1.trnatdga="F")) then begin');
      IBS.SQL.Add('          if (exists(select * from TREENODESAUTO t1 where t1.trnadtsycode=:Sys');
      IBS.SQL.Add('            and t1.trnacodeparent=:node2 and t1.trnatdga="T" )) then begin parent=node2;');
      IBS.SQL.Add('            for select t1.trnacode, t1.trnatdcode, t1.trnamaincode, IIF (t1.trnavisible="T", 1, 0),');
      IBS.SQL.Add('              t1.trnaname, t1.trnanamesys from TREENODESAUTO t1 where t1.trnadtsycode=:Sys');
      IBS.SQL.Add('              and t1.trnacodeparent=:node2 and t1.trnatdga="T" order by t1.trnaname');
      IBS.SQL.Add('            into :node, :kodTD, :Main, :nvis, :name, :nmSys do suspend; end');

      IBS.SQL.Add('        end else begin for select t1.trnacode, t1.trnaname from TREENODESAUTO t1');
      IBS.SQL.Add('          where t1.trnadtsycode=:Sys and t1.trnacodeparent=:node2 and t1.trnatdga="F"');
      IBS.SQL.Add('          order by t1.trnaname into :node1, :nm1 do begin');
      IBS.SQL.Add('          if (exists(select * from TREENODESAUTO t0 where t0.trnadtsycode=:Sys');
      IBS.SQL.Add('            and t0.trnacodeparent=:node1 and t0.trnatdga="T" )) then begin parent=node1;');
      IBS.SQL.Add('            for select t0.trnacode, t0.trnatdcode, t0.trnamaincode, IIF (t0.trnavisible="T", 1, 0),');
      IBS.SQL.Add('              t0.trnaname, t0.trnanamesys from TREENODESAUTO t0 where t0.trnadtsycode=:Sys');
      IBS.SQL.Add('              and t0.trnacodeparent=:node1 and t0.trnatdga="T" order by t0.trnaname');
      IBS.SQL.Add('            into :node, :kodTD, :Main, :nvis, :name, :nmSys');
      IBS.SQL.Add('            do suspend; end end end end end end end end end');
      with IBS.Transaction do if not InTransaction then StartTransaction;
      IBS.ExecQuery;
      while not IBS.Eof do begin
        id1    := IBS.fieldByName('node1').AsInteger;
        id2    := IBS.fieldByName('node2').AsInteger;
        id3    := IBS.fieldByName('node3').AsInteger;
        id4    := IBS.fieldByName('node4').AsInteger;
        name4  := IBS.fieldByName('nm4').AsString;
        name3  := IBS.fieldByName('nm3').AsString;
        name2  := IBS.fieldByName('nm2').AsString;
        name1  := IBS.fieldByName('nm1').AsString;
        nameGA := IBS.fieldByName('name').AsString;
        nameSys:= IBS.fieldByName('nmSys').AsString;
        nodeORD:= IBS.fieldByName('node').AsInteger;
        nodeGA := IBS.fieldByName('Main').AsInteger;
        ParGA  := IBS.fieldByName('nvis').AsInteger;
        if (id1>0) and not Nodes[id1].IsVisible then
          name1:= sTxtYellowCell(name1)
        else name1:= sTxtCell(name1);
        if (id2>0) and not Nodes[id2].IsVisible then
          name2:= sTxtYellowCell(name2)
        else name2:= sTxtCell(name2);
        if (id3>0) and not Nodes[id3].IsVisible then
          name3:= sTxtYellowCell(name3)
        else name3:= sTxtCell(name3);
        if (id4>0) and not Nodes[id4].IsVisible then
          name4:= sTxtYellowCell(name4)
        else name4:= sTxtCell(name4);
        if (ParGA>0) then nameGA:= sTxtCell(nameGA)
        else nameGA:= sTxtYellowCell(nameGA);
        AddStr(sTxtCell('')+name4+name3+name2+name1+sIntCell(nodeORD)+sIntCell(nodeGA)+
          sIntCell(ParGA)+nameGA+sTxtCell(nameSys)+sIntCell(0)+sIntCell(0)+sTxtCell(''));
        CheckStopExecute(pUserID, ThreadData);
        IBS.Next;
        SetExecutePercent(pUserID, ThreadData, Percent);
      end; // while not IBS.Eof
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD, True);
    end;
//-------------------------------------------
    AddXmlSheetEnd(Result, 1, 1);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    AddXmlBookEnd(Result);
    Setlength(Widths, 0);
  end;
end;  *)
//===================================== 34-stamp - поиск новых узлов авто из TDT
function fnGetNewTreeNodesFromTDT(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
// возвращает список для выгрузки в файл XML
const nmProc = 'fnGetNewTreeNodesFromTDT'; // имя процедуры/функции
var ordIBD, tdtIBD: TIBDatabase;
    ordIBS, tdtIBS: TIBSQL;
    nodeGA, ParGA, nodeORD, Ncolumns, id1, id2, id3, id4, iList, sysID, kodTD, ind, LastInd: integer;
    nameGA, nameSys, name1, name2, name3, name4, Sname1, Sname2, Sname3, Sname4,
      ListSys, ListType, ListName, sCodeOrd, sCodeMain, sCodeTD: string;
    Widths: Tai;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    Percent: real;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    if Result.Capacity=Result.Count then Result.Capacity:= Result.Capacity+1000;
    AddXmlLine(Result, s);
  end;
  //----------------------------------------------
begin
  Result:= fnCreateStringList(False, 1000);
  ordIBS:= nil;
  tdtIBS:= nil;
  ordIBD:= nil;
  tdtIBD:= nil;
  Ncolumns:= 13;
  Setlength(Widths, Ncolumns);
  Widths[1]:= 150;
  Widths[2]:= 150;
  Widths[3]:= 150;
  Widths[4]:= 150;
  Widths[8]:= 150;
  Widths[9]:= 150;
  Widths[12]:= 100; // Результат
  CheckStyle(skTxt);
  CheckStyle(skHead);
  CheckStyle(skBold);
  CheckStyle(skTxtGreen);
  CheckStyle(skBoldGreen);
  CheckStyle(skTxtYellow);
  CheckStyle(skTxtGreen);
  CheckStyle(skBoldGreen);
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  sysID:= 0;
  with Cache.FDCA do try try
    nodes:= AutoTreeNodesSys[constIsAuto];
    Percent:= 30/nodes.NodesList.Count;

    ordIBD:= cntsORD.GetFreeCnt('', '', '', True);
    ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
    ordIBS.ParamCheck:= False;
    tdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    tdtIBS:= fnCreateNewIBSQL(tdtIBD, 'tdtIBS_'+nmProc, -1, tpRead, true);

    AddXmlBookBegin(Result);
//------------------------------------------------------------- лист с описанием
    AddXmlSheetBegin(Result, 'описание', 1);
    AddStr(sBoldCell('   Узлы легковых авто, грузовиков и осей'));
    AddStr(sTxtCell(' На листах "узлы ..." содержится перечень конечных узлов с 4 уровнями родительских узлов.'));
    AddStr(sTxtCell('   (на листе "узлы авто" узлы ветви "Мотоцикл" исключены).'));
    AddStr(sTxtCell(' Если в TecDoc найдены новые узлы, строки с новыми конечными и родительскими узлами расположены'));
    AddStr(sTxtCell('   в начале листа с опцией "добавить", параметры новых узлов выделены зеленой заливкой ячеек.'));
    AddStr(sTxtCell(' Перечень узлов в нашей базе: видимость=1 - без заливки, видимость=0 - выделены желтой заливкой,'));
    AddStr(sTxtCell('   дубликаты узлов с разными главными кодами - коды выделены зеленой заливкой.'));
    AddStr(sBoldCell(' В строках с новыми узлами:'));
    AddStr(sTxtCell(' - желательно проверить наименования в ячейках с жирным шрифтом, т.к. в TecDoc часто встречаются ошибки,'));
    AddStr(sTxtCell(' - наименования родительских узлов - в столбце соответствующего уровня, конечных узлов - в столбце "Конечный узел",'));
    AddStr(sTxtCell(' - жирным шрифтом выделены изменяемые ячейки, значения которых при импорте будут записываться в базу из файла:'));
    AddStr(sTxtCell('   наименование и видимость, в строках конечных узлов - глав.код узла (из перечня узлов в нашей базе).'));
    AddStr(sBoldCell(' В строках существующих узлов:'));
    AddStr(sTxtCell(' - можно изменить значения в столбцах "Конечный узел"(наименование), "Видим."(видимость)'));
    AddStr(sTxtCell('   и "Главн."(глав.код конечного узла), значения в столбце "Код" изменять нельзя,'));
    AddStr(sTxtCell(' - строки, где коды выделены зеленой заливкой, следует отсортировать по столбцу "kodTD",'));
    AddStr(sTxtCell('   в группе строк с одним значением kodTD должен быть один глав.код,'));
    AddStr(sTxtCell(' - изменение глав.кода возможно 2-х видов - сделать главный узел дублирующим или сделать дублирующий узел главным,'));
    AddStr(sTxtCell('   переподчинение (замена глав.кода у дублирующего узла) не предусмотрено, при необходимости это можно сделать в 2 этапа:'));
    AddStr(sTxtCell('   сделать дублирующий узел главным, а затем сделать его дублирующим с другим глав.кодом,'));
    AddStr(sTxtCell(' - для обработки изменения параметров узла нужно в столбец "опция" записать значение "изменить".'));
    AddStr(sBoldCell(' При подготовке импорта:'));
    AddStr(sTxtCell(' - строки с новыми конечными узлами можно переставить на нужное место в перечне узлов, строки с новыми родительскими узлами'));
    AddStr(sTxtCell('   желательно оставить в начале листа, т.к. строки с родительскими узлами должны быть выше строк с конечными узлами,'));
    AddStr(sTxtCell(' - при перестановке нужно переносить всю строку, чтобы сохранить соответствие с кодами TD,'));
    AddStr(sTxtCell(' - в случае сортировки данных необходимо выделять все столбцы до столбца "Результат", перед импортом желательно отменить сортировку,'));
    AddStr(sTxtCell(' - значения в строках с опцией "добавить", кроме перечисленных выше, изменять нельзя,'));
    AddStr(sTxtCell(' - на листах "узлы ..." нельзя менять порядок столбцов, изменение цвета ячеек допускается.'));
    AddStr(sBoldCell(' При импорте:'));
    AddStr(sTxtCell(' - в файле импорта не должно быть скрытых строк или столбцов, фильтра и т.п.,'));
    AddStr(sTxtCell(' - формат файла импорта - ".xml", или для Excel2003 ".xls", или для Excel2007 и выше ".xlsx",'));
    AddStr(sTxtCell(' - обрабатываются только листы, в наименовании которых есть слово "узлы", и строки с опциями "добавить" или "изменить",'));
    AddStr(sTxtCell(' - все значения в строках с опцией "изменить", кроме перечисленных выше, игнорируются,'));
    AddStr(sTxtCell(' - результат обработки строки записывается в столбец "Результат", при успешной обработке строки ячейка "опция" очищается.'));
    AddXmlSheetEnd(Result, 0, 0);

//--------------------------------------------------------------- листы с узлами
    for iList:= 0 to 2 do begin
      case iList of
      0: begin
          sysID:= constIsAuto;
          ListType:= '1';
          ListName:= 'узлы авто';
        end;
      1: begin
          sysID:= constIsCV;
          ListType:= '2';
          ListName:= 'узлы груз.';
        end;
      2: begin
          sysID:= constIsAx;
          ListType:= '4';
          ListName:= 'узлы осей';
        end;
      end; //  case
      ListSys:= IntToStr(sysID);
      nodes:= AutoTreeNodesSys[sysID];
//------------------------------------------------------- начало 1 листа
      AddXmlSheetBegin(Result, ListName, Ncolumns, Widths);
      AddStr(sHeadCell('опция')+sHeadCell('уровень 1')+sHeadCell('уровень 2')+sHeadCell('уровень 3')+
        sHeadCell('уровень 4')+sHeadCell('Код')+sHeadCell('Главн.')+sHeadCell('Видим.')+sHeadCell('Конечный узел')+
        sHeadCell('Сист.наимен.')+sTxtCell('kodTD')+sTxtCell('ParTD')+sHeadCell('Результат'));
  //------------------------------------------- недостающие узлы
      try
        tdtIBS.SQL.Text:= 'select name4, name3, name2, name1, ga_id, ga_name,'+
                       ' id1, id2, id3, id4 from GetTreeNodesFor34rep('+ListType+', 0)';
        with tdtIBS.Transaction do if not InTransaction then StartTransaction;
        tdtIBS.ExecQuery;
        while not tdtIBS.Eof do begin
          id4    := tdtIBS.fieldByName('id4').AsInteger; //------- узел TD 1-го уровня
          nodeORD:= Nodes.GetNodeIDByTDcodes(id4, 0, False);
          if (nodeORD<1) then begin // если узла в ORD нет
            name4  := trim(tdtIBS.fieldByName('name4').AsString);
            Sname4 := sTxtGreenCell(name4);
            nameSys:= AnsiUpperCase(name4)+' (TD '+IntToStr(id4)+')';
            AddStr(sTxtGreenCell(sActionAdd)+sBoldGreenCell(name4)+sTxtCell('')+sTxtCell('')+
              sTxtCell('')+sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
              sTxtGreenCell(nameSys)+sIntGreenCell(id4)+sIntGreenCell(0)+sTxtGreenCell(''));
          end else begin
            node:= Nodes[nodeORD];
            name4:= Node.Name;
            if node.IsVisible then Sname4:= sTxtCell(name4)
            else Sname4:= sTxtYellowCell(name4);
          end;
          ParGA:= id4;

          while not tdtIBS.Eof and (id4=tdtIBS.fieldByName('id4').AsInteger) do begin
            id3  := tdtIBS.fieldByName('id3').AsInteger;
            name3:= trim(tdtIBS.fieldByName('name3').AsString);
            if id3>0 then begin //------------------ если есть узел TD 2-го уровня
              nodeORD:= Nodes.GetNodeIDByTDcodes(id3, id4, False);
              if (nodeORD<1) then begin // если узла в ORD нет
                nameSys:= AnsiUpperCase(name3)+' (TD '+IntToStr(id3)+')';
                Sname3 := sTxtGreenCell(name3);
                AddStr(sTxtGreenCell(sActionAdd)+Sname4+sBoldGreenCell(name3)+sTxtCell('')+
                  sTxtCell('')+sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
                  sTxtGreenCell(nameSys)+sIntGreenCell(id3)+sIntGreenCell(id4)+sTxtGreenCell(''));
              end else begin
                node:= Nodes[nodeORD];
                name3:= Node.Name;
                if node.IsVisible then Sname3:= sTxtCell(name3)
                else Sname3:= sTxtYellowCell(name3);
              end;
              ParGA:= id3;
            end else Sname3:= sTxtCell(name3);

            while not tdtIBS.Eof and (id4=tdtIBS.fieldByName('id4').AsInteger)
              and (id3=tdtIBS.fieldByName('id3').AsInteger) do begin
              id2  := tdtIBS.fieldByName('id2').AsInteger;
              name2:= trim(tdtIBS.fieldByName('name2').AsString);
              if (id2>0) then begin //---------------- если есть узел TD 3-го уровня
                nodeORD:= Nodes.GetNodeIDByTDcodes(id2, id3, False);
                if (nodeORD<1) then begin // если узла в ORD нет
                  nameSys:= AnsiUpperCase(name2)+' (TD '+IntToStr(id2)+')';
                  Sname2 := sTxtGreenCell(name2);
                  AddStr(sTxtGreenCell(sActionAdd)+Sname4+Sname3+sBoldGreenCell(name2)+
                    sTxtCell('')+sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
                    sTxtGreenCell(nameSys)+sIntGreenCell(id2)+sIntGreenCell(id3)+sTxtGreenCell(''));
                end else begin
                  node:= Nodes[nodeORD];
                  name2:= Node.Name;
                  if node.IsVisible then Sname2:= sTxtCell(name2)
                  else Sname2:= sTxtYellowCell(name2);
                end;
                ParGA:= id2;
              end else Sname2:= sTxtCell(name2);

              while not tdtIBS.Eof and (id4=tdtIBS.fieldByName('id4').AsInteger)
                and (id3=tdtIBS.fieldByName('id3').AsInteger)
                and (id2=tdtIBS.fieldByName('id2').AsInteger) do begin
                id1  := tdtIBS.fieldByName('id1').AsInteger;
                name1:= trim(tdtIBS.fieldByName('name1').AsString);
                if (id1>0) then begin //-------------- если есть узел TD 4-го уровня
                  nodeORD:= Nodes.GetNodeIDByTDcodes(id1, id2, False);
                  if (nodeORD<1) then begin // если узла в ORD нет
                    nameSys:= AnsiUpperCase(name1)+' (TD '+IntToStr(id1)+')';
                    Sname1 := sTxtGreenCell(name1);
                    AddStr(sTxtGreenCell(sActionAdd)+Sname4+Sname3+Sname2+sBoldGreenCell(name1)+
                      sIntCell(0)+sIntCell(0)+sIntBoldGreenCell(1)+sTxtCell('')+
                      sTxtGreenCell(nameSys)+sIntGreenCell(id1)+sIntGreenCell(id2)+sTxtGreenCell(''));
                  end else begin
                    node:= Nodes[nodeORD];
                    name1:= Node.Name;
                    if node.IsVisible then Sname1:= sTxtCell(name1)
                    else Sname1:= sTxtYellowCell(name1);
                  end;
                  ParGA:= id1;
                end else Sname1:= sTxtCell(name1);

                while not tdtIBS.Eof and (id4=tdtIBS.fieldByName('id4').AsInteger)
                  and (id3=tdtIBS.fieldByName('id3').AsInteger)
                  and (id2=tdtIBS.fieldByName('id2').AsInteger)
                  and (id1=tdtIBS.fieldByName('id1').AsInteger) do begin
                  nodeGA := tdtIBS.fieldByName('ga_id').AsInteger; //---- группа TD
                  nodeORD:= Nodes.GetNodeIDByTDcodes(nodeGA, ParGA, True);
                  if (nodeORD<1) then begin // если конечного узла в ORD нет
                    nameGA := trim(tdtIBS.fieldByName('ga_name').AsString);
                    nameSys:= AnsiUpperCase(nameGA)+' (TD '+IntToStr(ParGA)+' GA '+IntToStr(nodeGA)+')';
                    AddStr(sTxtGreenCell(sActionAdd)+Sname4+Sname3+Sname2+Sname1+
                      sIntCell(0)+sIntBoldGreenCell(0)+sIntBoldGreenCell(1)+sBoldGreenCell(nameGA)+
                      sTxtGreenCell(nameSys)+sIntGreenCell(nodeGA)+sIntGreenCell(ParGA)+sTxtGreenCell(''));
                  end;
                  CheckStopExecute(pUserID, ThreadData);
                  tdtIBS.Next;
                  SetExecutePercent(pUserID, ThreadData, Percent);
                end; // while not tdtIBS.Eof and (id1=
              end; // while not tdtIBS.Eof and (id2=
            end; // while not tdtIBS.Eof and (id3=
          end; // while not tdtIBS.Eof and (id4=
        end; // while not tdtIBS.Eof
      finally
        tdtIBS.Close;
      end;
  //------------------------------------------- узлы в нашей базе
      AddStr(sTxtCell(''));
      LastInd:= -1;
      try
        ordIBS.SQL.Clear;
        ordIBS.SQL.Add('execute block returns (nm4 varchar(100), nm3 varchar(100), nm2 varchar(100),');
        ordIBS.SQL.Add('  nm1 varchar(100), node integer, Main integer, nvis varchar(1), name varchar(100),');
        ordIBS.SQL.Add('  nmSys varchar(100), parent integer, kodTD integer, Other integer,');
        ordIBS.SQL.Add('  node1 integer, node2 integer, node3 integer, node4 integer)');
        ordIBS.SQL.Add('as  declare variable Sys integer='+ListSys+'; begin nmSys=""; parent=0; kodTD=0;');
        ordIBS.SQL.Add('  parent=0; node=0; Main=0; nm1=""; nm2=""; nm3=""; nm4=""; name="";');
        ordIBS.SQL.Add('  node1=0; node2=0; node3=0; node4=0;');

        ordIBS.SQL.Add('  for select t4.trnacode, t4.trnaname from TREENODESAUTO t4');
        ordIBS.SQL.Add('    where t4.trnadtsycode=:Sys and (t4.trnacodeparent is null');
        ordIBS.SQL.Add('      or t4.trnacodeparent=0) order by t4.trnaname');
        ordIBS.SQL.Add('  into :node4, :nm4 do begin nm1=""; nm2=""; nm3=""; name=""; node1=0; node2=0; node3=0;');
        ordIBS.SQL.Add('    if (not exists(select * from TREENODESAUTO t3 where t3.trnadtsycode=:Sys');
        ordIBS.SQL.Add('      and t3.trnacodeparent=:node4 and t3.trnatdga="F")) then begin');
        ordIBS.SQL.Add('      if (exists(select * from TREENODESAUTO t3 where t3.trnadtsycode=:Sys');
        ordIBS.SQL.Add('        and t3.trnacodeparent=:node4 and t3.trnatdga="T" )) then begin parent=node4;');
        ordIBS.SQL.Add('        for select t3.trnacode, t3.trnatdcode, t3.trnamaincode, IIF (t3.trnavisible="T", 1, 0),');
        ordIBS.SQL.Add('          iif(exists(select * from TREENODESAUTO tt where tt.trnatdcode=t3.trnatdcode');
        ordIBS.SQL.Add('            and tt.trnatdga="T" and tt.trnadtsycode=:Sys and tt.trnamaincode<>t3.trnamaincode), 1, 0),');
        ordIBS.SQL.Add('          t3.trnaname, t3.trnanamesys from TREENODESAUTO t3 where t3.trnadtsycode=:Sys');
        ordIBS.SQL.Add('          and t3.trnacodeparent=:node4 and t3.trnatdga="T" order by t3.trnaname');
        ordIBS.SQL.Add('        into :node, :kodTD, :Main, :nvis, :Other, :name, :nmSys do suspend; end');

        ordIBS.SQL.Add('    end else begin for select t3.trnacode, t3.trnaname from TREENODESAUTO t3');
        ordIBS.SQL.Add('      where t3.trnadtsycode=:Sys and t3.trnacodeparent=:node4 and t3.trnatdga="F"');
        ordIBS.SQL.Add('      order by t3.trnaname into :node3, :nm3 do begin nm1=""; nm2=""; node1=0; node2=0;');
        ordIBS.SQL.Add('      if (not exists(select * from TREENODESAUTO t2 where t2.trnadtsycode=:Sys');
        ordIBS.SQL.Add('        and t2.trnacodeparent=:node3 and t2.trnatdga="F")) then begin');
        ordIBS.SQL.Add('        if (exists(select * from TREENODESAUTO t2 where t2.trnadtsycode=:Sys');
        ordIBS.SQL.Add('          and t2.trnacodeparent=:node3 and t2.trnatdga="T" )) then begin parent=node3;');
        ordIBS.SQL.Add('          for select t2.trnacode, t2.trnatdcode, t2.trnamaincode, IIF (t2.trnavisible="T", 1, 0),');
        ordIBS.SQL.Add('            iif(exists(select * from TREENODESAUTO tt where tt.trnatdcode=t2.trnatdcode');
        ordIBS.SQL.Add('              and tt.trnatdga="T" and tt.trnadtsycode=:Sys and tt.trnamaincode<>t2.trnamaincode), 1, 0),');
        ordIBS.SQL.Add('            t2.trnaname, t2.trnanamesys from TREENODESAUTO t2 where t2.trnadtsycode=:Sys');
        ordIBS.SQL.Add('            and t2.trnacodeparent=:node3 and t2.trnatdga="T" order by t2.trnaname');
        ordIBS.SQL.Add('          into :node, :kodTD, :Main, :nvis, :Other, :name, :nmSys do suspend; end');

        ordIBS.SQL.Add('      end else begin for select t2.trnacode, t2.trnaname from TREENODESAUTO t2');
        ordIBS.SQL.Add('        where t2.trnadtsycode=:Sys and t2.trnacodeparent=:node3 and t2.trnatdga="F"');
        ordIBS.SQL.Add('        order by t2.trnaname into :node2, :nm2 do begin nm1=""; node1=0;');
        ordIBS.SQL.Add('        if (not exists(select * from TREENODESAUTO t1 where t1.trnadtsycode=:Sys');
        ordIBS.SQL.Add('          and t1.trnacodeparent=:node2 and t1.trnatdga="F")) then begin');
        ordIBS.SQL.Add('          if (exists(select * from TREENODESAUTO t1 where t1.trnadtsycode=:Sys');
        ordIBS.SQL.Add('            and t1.trnacodeparent=:node2 and t1.trnatdga="T" )) then begin parent=node2;');
        ordIBS.SQL.Add('            for select t1.trnacode, t1.trnatdcode, t1.trnamaincode, IIF (t1.trnavisible="T", 1, 0),');
        ordIBS.SQL.Add('              iif(exists(select * from TREENODESAUTO tt where tt.trnatdcode=t1.trnatdcode');
        ordIBS.SQL.Add('                and tt.trnatdga="T" and tt.trnadtsycode=:Sys and tt.trnamaincode<>t1.trnamaincode), 1, 0),');
        ordIBS.SQL.Add('              t1.trnaname, t1.trnanamesys from TREENODESAUTO t1 where t1.trnadtsycode=:Sys');
        ordIBS.SQL.Add('              and t1.trnacodeparent=:node2 and t1.trnatdga="T" order by t1.trnaname');
        ordIBS.SQL.Add('            into :node, :kodTD, :Main, :nvis, :Other, :name, :nmSys do suspend; end');

        ordIBS.SQL.Add('        end else begin for select t1.trnacode, t1.trnaname from TREENODESAUTO t1');
        ordIBS.SQL.Add('          where t1.trnadtsycode=:Sys and t1.trnacodeparent=:node2 and t1.trnatdga="F"');
        ordIBS.SQL.Add('          order by t1.trnaname into :node1, :nm1 do begin');
        ordIBS.SQL.Add('          if (exists(select * from TREENODESAUTO t0 where t0.trnadtsycode=:Sys');
        ordIBS.SQL.Add('            and t0.trnacodeparent=:node1 and t0.trnatdga="T" )) then begin parent=node1;');
        ordIBS.SQL.Add('            for select t0.trnacode, t0.trnatdcode, t0.trnamaincode, IIF (t0.trnavisible="T", 1, 0),');
        ordIBS.SQL.Add('              iif(exists(select * from TREENODESAUTO tt where tt.trnatdcode=t0.trnatdcode');
        ordIBS.SQL.Add('                and tt.trnatdga="T" and tt.trnadtsycode=:Sys and tt.trnamaincode<>t0.trnamaincode), 1, 0),');
        ordIBS.SQL.Add('              t0.trnaname, t0.trnanamesys from TREENODESAUTO t0 where t0.trnadtsycode=:Sys');
        ordIBS.SQL.Add('              and t0.trnacodeparent=:node1 and t0.trnatdga="T" order by t0.trnaname');
        ordIBS.SQL.Add('            into :node, :kodTD, :Main, :nvis, :Other, :name, :nmSys');
        ordIBS.SQL.Add('            do suspend; end end end end end end end end end');
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.ExecQuery;
        while not ordIBS.Eof do begin
          id1    := ordIBS.fieldByName('node1').AsInteger;
          id2    := ordIBS.fieldByName('node2').AsInteger;
          id3    := ordIBS.fieldByName('node3').AsInteger;
          id4    := ordIBS.fieldByName('node4').AsInteger;
          name4  := ordIBS.fieldByName('nm4').AsString;
          name3  := ordIBS.fieldByName('nm3').AsString;
          name2  := ordIBS.fieldByName('nm2').AsString;
          name1  := ordIBS.fieldByName('nm1').AsString;
          nameGA := ordIBS.fieldByName('name').AsString;
          nameSys:= ordIBS.fieldByName('nmSys').AsString;
          nodeORD:= ordIBS.fieldByName('node').AsInteger;
          nodeGA := ordIBS.fieldByName('Main').AsInteger;
          ParGA  := ordIBS.fieldByName('nvis').AsInteger;
          kodTD  := ordIBS.fieldByName('kodTD').AsInteger;
                                // признак наличия разных главных нод у одной GA
          ind    := ordIBS.fieldByName('Other').AsInteger;
          if (id1>0) and not Nodes[id1].IsVisible then
            name1:= sTxtYellowCell(name1)
          else name1:= sTxtCell(name1);
          if (id2>0) and not Nodes[id2].IsVisible then
            name2:= sTxtYellowCell(name2)
          else name2:= sTxtCell(name2);
          if (id3>0) and not Nodes[id3].IsVisible then
            name3:= sTxtYellowCell(name3)
          else name3:= sTxtCell(name3);
          if (id4>0) and not Nodes[id4].IsVisible then
            name4:= sTxtYellowCell(name4)
          else name4:= sTxtCell(name4);
          if (ParGA>0) then nameGA:= sTxtCell(nameGA)
          else nameGA:= sTxtYellowCell(nameGA);
          if (ind<1) then begin
            sCodeOrd := sIntCell(nodeORD);
            sCodeMain:= sIntCell(nodeGA);
            sCodeTD  := sIntCell(kodTD);
          end else begin
            sCodeOrd := sIntGreenCell(nodeORD);
            sCodeMain:= sIntBoldGreenCell(nodeGA);
            sCodeTD  := sIntGreenCell(kodTD);
          end;
          AddStr(sTxtCell('')+name4+name3+name2+name1+sCodeOrd+sCodeMain+
            sIntCell(ParGA)+nameGA+sTxtCell(nameSys)+sCodeTD+sIntCell(0)+sTxtCell(''));
          CheckStopExecute(pUserID, ThreadData);
          ordIBS.Next;
          SetExecutePercent(pUserID, ThreadData, Percent);
        end; // while not ordIBS.Eof
      finally
        ordIBS.Close;
      end;
  //-------------------------------------------
      AddXmlSheetEnd(Result, 1, 1);
//------------------------------------------------------- окончание 1 листа
    end; // for iList:= 0 to

  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(tdtIBS);
    cntsTDT.SetFreeCnt(tdtIBD, True);
    prFreeIBSQL(ordIBS);
    cntsORD.SetFreeCnt(ordIBD, True);
    AddXmlBookEnd(Result);
    Setlength(Widths, 0);
  end;
end;
//============= 25-stamp - поиск новых производителей, м.р., моделей авто из TDT
function fnGetNewAutoMfMlModFromTDT(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
// возвращает список для выгрузки в файл XML
const nmProc = 'fnGetNewAutoMfMlModFromTDT'; // имя процедуры/функции
var TdtIBD: TIBDatabase;
    TdtIBS: TIBSQL;
    manufTD, manufORD, mlTD, mlORD, modTD, modORD, tdFrom, tdTo, tdHP, tdKW,
      tdCC, tdCYL, tdVLV, Ncolumns: integer;
    nameTD, s, marksTD, sYearFrom: string;
    flMF, flMFex, flML, flMod: Boolean;
    Widths: Tai;
    mdl: TModelAuto;
    mps: TModelParams;
    tim: TTypesInfoModel;
    Percent: real;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    if (Result.Capacity=Result.Count) then Result.Capacity:= Result.Capacity+1000;
    AddXmlLine(Result, s);
  end;
  //----------------------------------------------
  function EmptyStrCell(n: integer=1): string;
  var i: integer;
  begin
    Result:= '';
    if (n<1) then Exit;
    for i:= 1 to n do Result:= Result+sTxtCell('');
  end;
  //----------------------------------------------
  function EmptyIntCell(n: integer=1): string;
  var i: integer;
  begin
    Result:= '';
    if (n<1) then Exit;
    for i:= 1 to n do Result:= Result+sIntCell(0);
  end;
  //----------------------------------------------
begin
  Result:= TStringList.Create;
  Result.Capacity:= 1000;
  TdtIBS:= nil;
  TdtIBD:= nil;
  Ncolumns:= 28;
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  Setlength(Widths, Ncolumns);
  Widths[2] := 150; // М/ряд
  Widths[3] := 200; // Модель
  Widths[7] := 200; // Марк/двиг
  Widths[14]:= 100; // Результат
  Widths[19]:= 100; // Тип кузова
  Widths[20]:= 150; // Тип привода
  Widths[21]:= 150; // Тип двигателя
  Widths[22]:= 100; // Тип топлива
  Widths[23]:= 270; // Система впрыска
  Widths[24]:= 120; // Тип торм.системы
  Widths[25]:= 120; // Торм.система
  Widths[26]:= 250; // Тип катализат.
  Widths[27]:= 250; // Вид кор.передач
  CheckStyle(skTxt);
  CheckStyle(skHead);
  CheckStyle(skBold);
  CheckStyle(skCBold);
  sYearFrom:= '';
  s:= '';
  with Cache.FDCA do try try
    sYearFrom:= GetYearFromLoadModels;
    if (sYearFrom<>'') then begin
      s:=' с годом выпуска от '+sYearFrom;
      sYearFrom:= ' and MT_FROM>'+sYearFrom+'00';
    end;
    AddXmlBookBegin(Result);
    AddXmlSheetBegin(Result, 'описание', 1);
    AddStr(sBoldCell('Модели легковых авто из TecDoc'+s));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' В файле содержится перечень моделей с разбивкой по листам производителей,'));
    AddStr(sTxtCell('   (Производители, в наименованиях которых есть "MOTORCYCLES", исключены),'));
    AddStr(sTxtCell('   наименование производителя указано в имени листа,'));
    AddStr(sTxtCell('   строка производителя расположена в 1-й строке таблицы листа,'));
    AddStr(sTxtCell('   в 1-м столбце находится опция обработки строки.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell('   Если в настройках СВК задан минимальный год выпуска моделей,'));
    AddStr(sTxtCell('   отображаются только модели с годом начала выпуска не менее заданного.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' На листе строки отсортированы по наименованиям модельных рядов и моделей.'));
    AddStr(sTxtCell(' Опцией "/2" и жирным шрифтом обозначены данные, видимые при авто-подборе'));
    AddStr(sTxtCell('   в СВК, в таких строках приведены наименования из СВК.'));
    AddStr(sTxtCell(' В строках с пустой опцией - приведены данные из TecDoc, которых нет'));
    AddStr(sTxtCell('   в СВК или они невидимы при авто-подборе.'));
    AddStr(sTxtCell(' Столбцы между "Марк/двиг" и "Результат"- служебные (для загрузки данных из файла).'));
    AddStr(sTxtCell(' Столбцы после столбца "Результат" - информационные (параметры моделей в СВК).'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' В строках моделей с пустой опцией, которые должны быть видимыми при авто-подборе'));
    AddStr(sTxtCell('   в СВК, нужно проставить опцию "/1". Если в строке модели проставлена опция "/1",'));
    AddStr(sTxtCell('   то в строках ее модельного ряда и ее производителя должна быть опция "/1" или "/2".'));
    AddStr(sTxtCell(' В строках моделей / модельных рядов с опцией "/1" можно изменить наименование.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' При импорте обрабатываются только строки с опцией "/1", при этом'));
    AddStr(sTxtCell('   наименование модели / модельного ряда записывается в базу из файла,'));
    AddStr(sTxtCell('   устанавливается видимость модели / модельного ряда / производителя,'));
    AddStr(sTxtCell('   все остальные параметры новых моделей / модельных рядов записываются из базы TecDoc.'));
    AddStr(sTxtCell(' Новые модельные ряды / производители записываются в базу СВК'));
    AddStr(sTxtCell('   только при наличии у них моделей с опцией "/1".'));
    AddStr(sTxtCell(' Результат обработки строки записывается в столбец "Результат",'));
    AddStr(sTxtCell('   в случае ошибки результат дублируется в тексте письма с отчетом.'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('ВНИМАНИЕ! В файле допускается только изменение пустых ячеек опций в 1-м столбце'));
    AddStr(sBoldCell('          и изменение ячеек с наименованием модельного ряда / модели с опцией "/1"!'));
    AddStr(sBoldCell('          Ячейки, области, листы нельзя удалять, сортировать, форматировать и т.п.!'));
    AddXmlSheetEnd(Result, 0, 0);

    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);

    TdtIBS.SQL.Text:= 'select count(*) from (select MS_MF_ID from MODEL_TYPES'+
      ' inner join MODEL_SERIES on MS_ID=MT_MS_ID and MS_PC=1 and MT_DEL=0'+ // кол-во производителей
      ' where not (MS_MF_DESCR containing "MOTORCYCLES")'+
      ' group by MS_MF_ID)';
    TdtIBS.ExecQuery;
    if not (TdtIBS.Bof and TdtIBS.Eof) then Percent:= 90/TdtIBS.Fields[0].AsInteger;
    TdtIBS.Close;

    TdtIBS.SQL.Text:= 'select MT_MS_ID, MT_MS_DESCR, MT_ID, MT_DESCR, MT_FROM, MT_TO, MT_HP,'+
      ' MT_KW, MT_CC_TEC, MT_CYL, MT_VLV,'+
      ' MS_MF_ID, iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR,'+
      ' (select marks from get_str_eng_marks_sys(2, MT_ID)) marks'+
      ' from MODEL_TYPES inner join MODEL_SERIES on MS_ID=MT_MS_ID and MS_PC=1 and MT_DEL=0'+ // мод.ряды легк.авто
      ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+
      ' where not (MS_MF_DESCR containing "MOTORCYCLES")'+sYearFrom+
      ' order by MS_MF_DESCR, MS_MF_ID, MT_MS_DESCR, MT_MS_ID, MT_DESCR, MT_FROM';
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin
      manufTD:= TdtIBS.fieldByName('MS_MF_ID').AsInteger;   // код произв. TecDoc
      manufORD:= Manufacturers.GetManufIDByTDcode(manufTD); // ищем ID произв. по коду TecDoc
      if manufORD<1 then manufORD:= 0;
      flMFex:= (manufORD>0) and Manufacturers.ManufExists(manufORD);
      flMF:= flMFex and Manufacturers[manufORD].CheckIsVisible(constIsAuto);
      if flMFex then s:= Manufacturers[manufORD].Name
      else s:= TdtIBS.fieldByName('MF_DESCR').AsString;

      AddXmlSheetBegin(Result, s, Ncolumns, Widths);
      AddStr(sHeadCell('Опция')+sHeadCell('Произв.')+sHeadCell('М/ряд')+sHeadCell('Модель')+
          sHeadCell('От')+sHeadCell('До')+sHeadCell('Л/с')+sHeadCell('Марк/двиг')+
          sTxtCell('mf_TD')+sTxtCell('mf_ORD')+sTxtCell('ml_TD')+sTxtCell('ml_ORD')+
          sTxtCell('mod_TD')+sTxtCell('mod_ORD')+sHeadCell('Результат')+
          sHeadCell('Тех.об.')+sHeadCell('кВт')+sHeadCell('Цил.')+sHeadCell('Клап.')+
          sHeadCell('Тип кузова')+sHeadCell('Тип привода')+sHeadCell('Тип двигателя')+
          sHeadCell('Тип топлива')+sHeadCell('Система впрыска')+sHeadCell('Тип торм.системы')+
          sHeadCell('Торм.система')+sHeadCell('Тип катализат.')+sHeadCell('Вид кор.передач'));

      AddStr(fnIfStr(flMF, sCBoldCell('/2'), EmptyStrCell)+fnIfStr(flMF, sBoldCell(s), sTxtCell(s))+
             EmptyStrCell(6)+sIntCell(manufTD)+sIntCell(manufORD)+EmptyIntCell(4));

      while not TdtIBS.Eof and (TdtIBS.fieldByName('MS_MF_ID').AsInteger=manufTD) do begin
        mlTD:= TdtIBS.fieldByName('MT_MS_ID').AsInteger;       // код мод.ряда TecDoc
        if not flMFex then mlORD:= 0
        else mlORD:= Manufacturers[manufORD].GetMfMLineIDByTDcode(mlTD); // ищем ID мод.ряда по коду TecDoc
        if mlORD<1 then mlORD:= 0;
        flML:= (mlORD>0) and ModelLines.ModelLineExists(mlORD) and ModelLines[mlORD].IsVisible;

        if (mlORD>0) and ModelLines.ModelLineExists(mlORD) then
          s:= ModelLines[mlORD].Name // наше наименование
        else s:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MT_MS_DESCR').AsString);

        AddStr(fnIfStr(flML, sCBoldCell('/2'), EmptyStrCell)+EmptyStrCell+
               fnIfStr(flML, sBoldCell(s), sTxtCell(s))+EmptyStrCell(5)+
               EmptyIntCell(2)+sIntCell(mlTD)+sIntCell(mlORD)+EmptyIntCell(2));

        while not TdtIBS.Eof and (TdtIBS.fieldByName('MT_MS_ID').AsInteger=mlTD) do begin
          modTD := TdtIBS.fieldByName('MT_ID').AsInteger;   // код модели TecDoc
          nameTD:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MT_DESCR').AsString); // наимен. модели TecDoc
          tdFrom:= TdtIBS.fieldByName('MT_FROM').AsInteger; // от
          tdTo  := TdtIBS.fieldByName('MT_TO').AsInteger;   // до

          if not flML then modORD:= 0
            else modORD:= ModelLines[mlORD].GetMLModelIDByTDcode(modTD); // ищем ID модели по коду TecDoc
          if modORD<1 then modORD:= 0;
          flMod:= (modORD>0) and Models.ModelExists(modORD);
          if flMod then s:= Models[modORD].Name else s:= nameTD; // наше наименование или TD
          flMod:= flMod and Models[modORD].IsVisible; // выделяем только видимые
          if flMod then begin
            mdl:= Models[modORD];
            mps:= mdl.Params;
            tim:= TypesInfoModel;
            if (mps.pYStart>0) then tdFrom:= mps.pYStart*100+mps.pMStart;
            if (mps.pYEnd>0) then tdTo:= mps.pYEnd*100+mps.pMEnd;
            AddStr(sCBoldCell('/2')+EmptyStrCell(2)+sBoldCell(s)+                            // наимен. модели
              fnIfStr(mps.pYStart<1, EmptyStrCell, sBoldCell(IntToStr(tdFrom)))+             // от
              fnIfStr(mps.pYEnd<1, EmptyStrCell, sBoldCell(IntToStr(tdTo)))+                 // до
              fnIfStr(mps.pHP<1, EmptyStrCell, sBoldCell(IntToStr(mps.pHP)))+                // Мощность ЛС
              fnIfStr(mdl.EngLinks.LinkCount<1, EmptyStrCell,sBoldCell(mdl.MarksCommaText))+ // Марк/двиг
              EmptyIntCell(4)+sIntCell(modTD)+sIntCell(modORD)+EmptyStrCell+
              fnIfStr(mps.pCCM       <1, EmptyStrCell, sBoldCell(IntToStr(mps.pCCM)))+       // Тех.об.куб.см.
              fnIfStr(mps.pKW        <1, EmptyStrCell, sBoldCell(IntToStr(mps.pKW)))+        // Мощность кВт
              fnIfStr(mps.pCylinders <1, EmptyStrCell, sBoldCell(IntToStr(mps.pCylinders)))+ // Количество цилиндров
              fnIfStr(mps.pValves    <1, EmptyStrCell, sBoldCell(IntToStr(mps.pValves)))+    // Количество клапанов
              fnIfStr(mps.pBodyID    <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pBodyID].Name))+     // тип кузова
              fnIfStr(mps.pDriveID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pDriveID].Name))+    // тип привода
              fnIfStr(mps.pEngTypeID <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pEngTypeID].Name))+  // тип двигателя
              fnIfStr(mps.pFuelID    <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pFuelID].Name))+     // тип топлива
              fnIfStr(mps.pFuelSupID <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pFuelSupID].Name))+  // система впрыска
              fnIfStr(mps.pBrakeID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pBrakeID].Name))+    // тип тормозной системы
              fnIfStr(mps.pBrakeSysID<1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pBrakeSysID].Name))+ // тип тормозная система
              fnIfStr(mps.pCatalID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pCatalID].Name))+    // тип катализатора
              fnIfStr(mps.pTransID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pTransID].Name)));   // тип коробки передач
          end else begin
            marksTD:= TdtIBS.fieldByName('marks').AsString;     // Марк/двиг модели TecDoc (информ.поле)
            tdHP  := TdtIBS.FieldByName('MT_HP').AsInteger;     // Мощность ЛС
            tdCC  := TdtIBS.FieldByName('MT_CC_TEC').AsInteger; // Тех. объем куб. см.
            tdKW  := TdtIBS.FieldByName('MT_KW').AsInteger;     // Мощность кВт.
            tdCYL := TdtIBS.FieldByName('MT_CYL').AsInteger;    // Кол. цилиндров
            tdVLV := TdtIBS.FieldByName('MT_VLV').AsInteger;    // Кол. клапанов на одну камеру сгорания
            AddStr(EmptyStrCell(3)+sTxtCell(s)+
              fnIfStr(tdFrom<1, EmptyStrCell, sTxtCell(IntToStr(tdFrom)))+
              fnIfStr(tdTo<1, EmptyStrCell, sTxtCell(IntToStr(tdTo)))+
              fnIfStr(tdHP<1, EmptyStrCell, sTxtCell(IntToStr(tdHP)))+
              fnIfStr(marksTD='', EmptyStrCell, sTxtCell(marksTD))+
              EmptyIntCell(4)+sIntCell(modTD)+sIntCell(modORD)+EmptyStrCell+
              fnIfStr(tdCC  <1, EmptyStrCell, sTxtCell(IntToStr(tdCC)))+   // Тех.об.куб.см.
              fnIfStr(tdKW  <1, EmptyStrCell, sTxtCell(IntToStr(tdKW)))+   // Мощность кВт
              fnIfStr(tdCYL <1, EmptyStrCell, sTxtCell(IntToStr(tdCYL)))+  // Количество цилиндров
              fnIfStr(tdVLV <1, EmptyStrCell, sTxtCell(IntToStr(tdVLV)))); // Количество клапанов
          end;
          CheckStopExecute(pUserID, ThreadData);
          TdtIBS.Next;
        end;  // цикл по мод.ряду mlTD
      end; // цикл по произв. manufTD
      AddXmlSheetEnd(Result, 1, 2);
      SetExecutePercent(pUserID, ThreadData, Percent);
    end;
    AddXmlBookEnd(Result);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    cntsTdt.SetFreeCnt(TdtIBD, True);
    Setlength(Widths, 0);
  end;
end;
//======= 67-stamp - поиск новых производителей, м.р., моделей грузовиков из TDT
function fnGetNewCVMfMlModFromTDT(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
// возвращает список для выгрузки в файл XML
const nmProc = 'fnGetNewCVMfMlModFromTDT'; // имя процедуры/функции
var TdtIBD: TIBDatabase;
    TdtIBS: TIBSQL;
    manufTD, manufORD, mlTD, mlORD, modTD, modORD, tdFrom, tdTo,
      tdCC, tdVLV, Ncolumns, tdHPfr, tdHPto, tdKWfr, tdKWto: integer;
    nameTD, s, marksTD, sHP, sKW, sAC, sBT, sEnT, sYearFrom: string;
    flMF, flMFex, flML, flMod: Boolean;
    Widths: Tai;
    mdl: TModelAuto;
    mps: TModelParams;
    tim: TTypesInfoModel;
    manuf: TManufacturer;
    mline: TModelLine;
    Percent: real;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    if Result.Capacity=Result.Count then Result.Capacity:= Result.Capacity+1000;
    AddXmlLine(Result, s);
  end;
  //----------------------------------------------
  function EmptyStrCell(n: integer=1): string;
  var i: integer;
  begin
    Result:= '';
    if n<1 then Exit;
    for i:= 1 to n do Result:= Result+sTxtCell('');
  end;
  //----------------------------------------------
  function EmptyIntCell(n: integer=1): string;
  var i: integer;
  begin
    Result:= '';
    if n<1 then Exit;
    for i:= 1 to n do Result:= Result+sIntCell(0);
  end;
  //----------------------------------------------
begin
  Result:= TStringList.Create;
  Result.Capacity:= 1000;
  TdtIBS:= nil;
  TdtIBD:= nil;
  mdl:= nil;
  mline:= nil;
  manuf:= nil;
  Ncolumns:= 21;
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  Setlength(Widths, Ncolumns);
  Widths[2] := 100; // М/ряд
  Widths[3] := 150; // Модель
  Widths[7] := 150; // Марк/двиг
  Widths[14]:= 100; // Результат
  Widths[18]:= 60;  // Конфигурация оси
  Widths[19]:= 150; // Конструкция
  Widths[20]:= 100; // Тип двигателя
  CheckStyle(skTxt);
  CheckStyle(skHead);
  CheckStyle(skBold);
  CheckStyle(skCBold);

  sYearFrom:= '';
  s:= '';
  with Cache.FDCA do try try
    sYearFrom:= GetYearFromLoadModels;
    if (sYearFrom<>'') then begin
      s:=' с годом выпуска от '+sYearFrom;
      sYearFrom:= ' where CPT_FROM>'+sYearFrom+'00';
    end;

    AddXmlBookBegin(Result);
    AddXmlSheetBegin(Result, 'описание', 1);
    AddStr(sBoldCell('Модели грузовых авто из TecDoc'+s));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' В файле содержится перечень моделей с разбивкой по листам производителей,'+
                      ' наименование производителя указано в имени листа,'));
    AddStr(sTxtCell('   строка производителя расположена в 1-й строке таблицы листа,'+
                      ' в 1-м столбце находится опция обработки строки.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell('   Если в настройках СВК задан минимальный год выпуска моделей,'));
    AddStr(sTxtCell('   отображаются только модели с годом начала выпуска не менее заданного.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' На листе строки отсортированы по наименованиям модельных рядов и моделей.'));
    AddStr(sTxtCell(' Опцией "/2" и жирным шрифтом обозначены данные, видимые при авто-подборе в СВК,'+
                      ' в таких строках приведены наименования из СВК.'));
    AddStr(sTxtCell(' В строках с пустой опцией - приведены данные из TecDoc, которых нет'+
                      ' в СВК или они невидимы при авто-подборе.'));
    AddStr(sTxtCell(' Столбцы между "Марк/двиг" и "Результат"- служебные (для загрузки данных из файла).'));
    AddStr(sTxtCell(' Столбцы после столбца "Результат" - информационные (параметры моделей в СВК).'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' В строках моделей с пустой опцией, которые должны быть видимыми при авто-подборе в СВК,'+
                      ' нужно проставить опцию "/1".'));
    AddStr(sTxtCell(' Если в строке модели проставлена опция "/1", то в строках ее'+
                      ' мод.ряда / производителя должна быть опция "/1" или "/2".'));
    AddStr(sBoldCell(' В строках моделей / модельных рядов с опцией "/1" можно изменить наименование.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' При импорте обрабатываются только строки с опцией "/1", при этом'+
                      ' наименование модели / мод.ряда записывается в базу из файла,'));
    AddStr(sTxtCell('   устанавливается видимость модели / мод.ряда / производителя,'+
                      ' остальные параметры новых моделей / мод.рядов записываются из базы TecDoc.'));
    AddStr(sTxtCell(' Новые модельные ряды / производители записываются в базу СВК'+
                      ' только при наличии у них моделей с опцией "/1".'));
    AddStr(sTxtCell(' Результат обработки строки записывается в столбец "Результат",'+
                      ' в случае ошибки результат дублируется в письме с отчетом.'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('Оси, привязанные к новой модели грузового авто, загружаются в базу автоматически.'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('ВНИМАНИЕ! В файле допускается только изменение пустых ячеек опций в 1-м столбце'));
    AddStr(sBoldCell('          и изменение ячеек с наименованием модельного ряда / модели с опцией "/1"!'));
    AddStr(sBoldCell('          Ячейки, области, листы нельзя удалять, сортировать, форматировать и т.п.!'));
    AddXmlSheetEnd(Result, 0, 0);

    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);

    TdtIBS.SQL.Text:= 'select count(*) from (select MS_MF_ID from CV_PRIMARY_TYPES'+
      ' inner join MODEL_SERIES on MS_ID=CPT_MS_ID and MS_CV=1 and CPT_DEL=0'+ // кол-во производителей
      ' group by MS_MF_ID)';
    TdtIBS.ExecQuery;
    if not (TdtIBS.Bof and TdtIBS.Eof) then Percent:= 90/TdtIBS.Fields[0].AsInteger;
    TdtIBS.Close;
    TdtIBS.SQL.Text:= 'select CPT_MS_ID, CPT_MS_DESCR, CPT_ID, CPT_DESCR,'+
      ' CPT_FROM, CPT_TO, CPT_BT, CPT_ENG, CPT_KW_FROM, CPT_KW_TO,'+
      ' CPT_HP_FROM, CPT_HP_TO, CPT_CC_TEC, CPT_TONNAGE, CPT_AC, MS_MF_ID,'+
      ' iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR,'+
      ' (select marks from get_str_eng_marks_sys(16, CPT_ID)) marks,'+
      ' ac.ke_descr acname, bt.ke_descr btname, et.ke_descr etname'+
      ' from CV_PRIMARY_TYPES inner join MODEL_SERIES on MS_ID=CPT_MS_ID and MS_CV=1 and CPT_DEL=0'+ // мод.ряды груз.авто
      ' left join KEY_ENTRIES ac on ac.ke_kt_id=65 and cast(ac.ke_key as integer)=CPT_AC'+
      ' left join KEY_ENTRIES bt on bt.ke_kt_id=67 and cast(bt.ke_key as integer)=CPT_BT'+
      ' left join KEY_ENTRIES et on et.ke_kt_id=80 and cast(et.ke_key as integer)=CPT_ENG'+
      ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+sYearFrom+
      ' order by MS_MF_DESCR, MS_MF_ID, CPT_MS_DESCR, CPT_MS_ID, CPT_DESCR, CPT_FROM';
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin
      manufTD:= TdtIBS.fieldByName('MS_MF_ID').AsInteger;   // код произв. TecDoc
      manufORD:= Manufacturers.GetManufIDByTDcode(manufTD); // ищем ID произв. по коду TecDoc
      if (manufORD<1) then manufORD:= 0;
      flMFex:= (manufORD>0) and Manufacturers.ManufExists(manufORD);
      if flMFex then begin
        manuf:= Manufacturers[manufORD];
        s:= manuf.Name;
        flMF:= flMFex and manuf.IsMfCV;
      end else begin
        manuf:= nil;
        flMF:= False;
        s:= TdtIBS.fieldByName('MF_DESCR').AsString;
      end;

      AddXmlSheetBegin(Result, s, Ncolumns, Widths);
      AddStr(sHeadCell('Опция')+sHeadCell('Произв.')+sHeadCell('М/ряд')+sHeadCell('Модель')+
          sHeadCell('От')+sHeadCell('До')+sHeadCell('Л/с')+sHeadCell('Марк/двиг')+
          sTxtCell('mf_TD')+sTxtCell('mf_ORD')+sTxtCell('ml_TD')+sTxtCell('ml_ORD')+
          sTxtCell('mod_TD')+sTxtCell('mod_ORD')+sHeadCell('Результат')+
          sHeadCell('Тех.об.')+sHeadCell('кВт')+sHeadCell('Тоннаж')+sHeadCell('Конфиг.оси')+
          sHeadCell('Конструкция')+sHeadCell('Тип двигателя'));

      AddStr(fnIfStr(flMF, sCBoldCell('/2'), EmptyStrCell)+fnIfStr(flMF, sBoldCell(s), sTxtCell(s))+
             EmptyStrCell(6)+sIntCell(manufTD)+sIntCell(manufORD)+EmptyIntCell(4));

      while not TdtIBS.Eof and (TdtIBS.fieldByName('MS_MF_ID').AsInteger=manufTD) do begin
        mlTD:= TdtIBS.fieldByName('CPT_MS_ID').AsInteger; // код мод.ряда TecDoc
        if not flMFex then mlORD:= 0
        else mlORD:= manuf.GetMfMLineIDByTDcode(mlTD, constIsCV); // ищем ID мод.ряда по коду TecDoc
        if (mlORD<1) then mlORD:= 0;
        flML:= (mlORD>0) and ModelLines.ModelLineExists(mlORD);
        if flML then begin
          mline:= ModelLines[mlORD];
          s:= mline.Name; // наше наименование
          flML:= flML and mline.IsVisible;
        end else s:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('CPT_MS_DESCR').AsString);

        AddStr(fnIfStr(flML, sCBoldCell('/2'), EmptyStrCell)+EmptyStrCell+
               fnIfStr(flML, sBoldCell(s), sTxtCell(s))+EmptyStrCell(5)+
               EmptyIntCell(2)+sIntCell(mlTD)+sIntCell(mlORD)+EmptyIntCell(2));

        while not TdtIBS.Eof and (TdtIBS.fieldByName('CPT_MS_ID').AsInteger=mlTD) do begin
          modTD := TdtIBS.fieldByName('CPT_ID').AsInteger;   // код модели TecDoc
          nameTD:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('CPT_DESCR').AsString); // наимен. модели TecDoc
          tdFrom:= TdtIBS.fieldByName('CPT_FROM').AsInteger; // от
          tdTo  := TdtIBS.fieldByName('CPT_TO').AsInteger;   // до

          if not flML then modORD:= 0
          else modORD:= mline.GetMLModelIDByTDcode(modTD); // ищем ID модели по коду TecDoc
          if (modORD<1) then modORD:= 0;
          flMod:= (modORD>0) and Models.ModelExists(modORD);
          if flMod then begin
            mdl:= Models[modORD];
            s:= mdl.Name; // наше наименование
            flMod:= flMod and mdl.IsVisible; // выделяем только видимые
          end else s:= nameTD; // наименование TD

          if flMod then begin
            mps:= mdl.Params;
            tim:= TypesInfoModel;
            if (mps.pYStart>0) then tdFrom:= mps.pYStart*100+mps.pMStart;
            if (mps.pYEnd>0) then tdTo:= mps.pYEnd*100+mps.pMEnd;
            AddStr(sCBoldCell('/2')+EmptyStrCell(2)+sBoldCell(s)+                            // наимен. модели
              fnIfStr(mps.pYStart<1, EmptyStrCell, sBoldCell(IntToStr(tdFrom)))+             // от
              fnIfStr(mps.pYEnd<1, EmptyStrCell, sBoldCell(IntToStr(tdTo)))+                 // до
              fnIfStr(mps.cvHPaxLO='', EmptyStrCell, sBoldCell(mps.cvHPaxLOout))+            // Мощность ЛС от-до
              fnIfStr(mdl.EngLinks.LinkCount<1, EmptyStrCell,sBoldCell(mdl.MarksCommaText))+ // Марк/двиг
              EmptyIntCell(4)+sIntCell(modTD)+sIntCell(modORD)+EmptyStrCell+
              fnIfStr(mps.pCCM       <1, EmptyStrCell, sBoldCell(IntToStr(mps.pCCM)))+        // Тех.об.куб.см.
              fnIfStr(mps.cvKWaxDI  ='', EmptyStrCell, sBoldCell(mps.cvKWaxDIOut))+           // Мощность кВт от-до
              fnIfStr(mps.pValves    <1, EmptyStrCell, sBoldCell(mps.cvTonnOut))+             // тоннаж
              fnIfStr(mps.pDriveID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pDriveID].Name))+    // Конфигурация оси
              fnIfStr(mps.pBodyID    <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pBodyID].Name))+     // Конструкция
              fnIfStr(mps.pEngTypeID <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pEngTypeID].Name))); // тип двигателя

          end else begin
            marksTD:= TdtIBS.fieldByName('marks').AsString;       // Марк/двиг модели TecDoc (информ.поле)
            tdHPfr:= TdtIBS.fieldByName('CPT_HP_FROM').AsInteger; // Мощность ЛС от
            tdHPto:= TdtIBS.fieldByName('CPT_HP_TO').AsInteger;   // Мощность ЛС до
            tdKWfr:= TdtIBS.fieldByName('CPT_KW_FROM').AsInteger; // Мощность кВт от
            tdKWto:= TdtIBS.fieldByName('CPT_KW_TO').AsInteger;   // Мощность кВт до
            sHP:= '';
            if (tdHPfr>0) then sHP:= IntToStr(tdHPfr);            // Мощность ЛС от-до
            if (tdHPto>0) then sHP:= sHP+fnIfStr(sHP<>'', '-', '')+IntToStr(tdHPto);
            sKW:= '';
            if (tdKWfr>0) then sKW:= IntToStr(tdKWfr);            // Мощность кВт от-до
            if (tdKWto>0) then sKW:= sKW+fnIfStr(sKW<>'', '-', '')+IntToStr(tdKWto);
            tdCC := TdtIBS.FieldByName('CPT_CC_TEC').AsInteger;   // Тех. объем куб. см.
            tdVLV:= TdtIBS.FieldByName('CPT_TONNAGE').AsInteger;  // тоннаж * 100
            sAC  := TdtIBS.FieldByName('acname').AsString;        // Конфигурация оси
            sBT  := TdtIBS.FieldByName('btname').AsString;        // Конструкция
            sEnT := TdtIBS.FieldByName('etname').AsString;        // тип двигателя

            AddStr(EmptyStrCell(3)+sTxtCell(s)+
              fnIfStr(tdFrom<1, EmptyStrCell, sTxtCell(IntToStr(tdFrom)))+
              fnIfStr(tdTo<1, EmptyStrCell, sTxtCell(IntToStr(tdTo)))+
              fnIfStr(sHP='', EmptyStrCell, sTxtCell(sHP))+
              fnIfStr(marksTD='', EmptyStrCell, sTxtCell(marksTD))+
              EmptyIntCell(4)+sIntCell(modTD)+sIntCell(modORD)+EmptyStrCell+
              fnIfStr(tdCC <1, EmptyStrCell, sTxtCell(IntToStr(tdCC)))+  // Тех.об.куб.см.
              fnIfStr(sKW ='', EmptyStrCell, sTxtCell(sKW))+             // Мощность кВт от-до
              fnIfStr(tdVLV<1, EmptyStrCell, sTxtCell(FormatFloat(cFloatFormatSumm, tdVLV/100)))+ // Тоннаж
              fnIfStr(sAC ='', EmptyStrCell, sTxtCell(sAC))+             // Конфигурация оси
              fnIfStr(sBT ='', EmptyStrCell, sTxtCell(sBT))+             // Конструкция
              fnIfStr(sEnT='', EmptyStrCell, sTxtCell(sEnT)));           // тип двигателя
          end;
          CheckStopExecute(pUserID, ThreadData);
          TdtIBS.Next;
        end;  // цикл по мод.ряду mlTD
      end; // цикл по произв. manufTD
      AddXmlSheetEnd(Result, 1, 2);
      SetExecutePercent(pUserID, ThreadData, Percent);
    end;
    AddXmlBookEnd(Result);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    cntsTdt.SetFreeCnt(TdtIBD, True);
    Setlength(Widths, 0);
  end;
end;
//============= 68-stamp - поиск новых производителей, м.р., моделей осей из TDT
function fnGetNewAxMfMlModFromTDT(pUserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
// возвращает список для выгрузки в файл XML
const nmProc = 'fnGetNewAxMfMlModFromTDT'; // имя процедуры/функции
var TdtIBD: TIBDatabase;
    TdtIBS: TIBSQL;
    manufTD, manufORD, mlTD, mlORD, modTD, modORD, tdFrom, tdTo,
      tdCC, Ncolumns, tdHPfr, tdHPto, tdKWfr, tdKWto: integer;
    nameTD, s, sHP, sKW, sAC, sBT, sEnT, sYearFrom, sBr, sWh, sHb: string;
    flMF, flMFex, flML, flMod: Boolean;
    Widths: Tai;
    mdl: TModelAuto;
    mps: TModelParams;
    tim: TTypesInfoModel;
    manuf: TManufacturer;
    mline: TModelLine;
    Percent: real;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    if Result.Capacity=Result.Count then Result.Capacity:= Result.Capacity+1000;
    AddXmlLine(Result, s);
  end;
  //----------------------------------------------
  function EmptyStrCell(n: integer=1): string;
  var i: integer;
  begin
    Result:= '';
    if n<1 then Exit;
    for i:= 1 to n do Result:= Result+sTxtCell('');
  end;
  //----------------------------------------------
  function EmptyIntCell(n: integer=1): string;
  var i: integer;
  begin
    Result:= '';
    if n<1 then Exit;
    for i:= 1 to n do Result:= Result+sIntCell(0);
  end;
  //----------------------------------------------
begin
  Result:= TStringList.Create;
  Result.Capacity:= 1000;
  TdtIBS:= nil;
  TdtIBD:= nil;
  mdl:= nil;
  mline:= nil;
  manuf:= nil;
  Ncolumns:= 22;
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  Setlength(Widths, Ncolumns);
  Widths[2] := 100; // М/ряд
  Widths[3] := 100; // Модель
  Widths[6] := 60;  // Нагрузка[кг]
  Widths[7] := 60;  // Тип оси
  Widths[14]:= 60;  // Результат
  Widths[15]:= 60;  // Балка моста
  Widths[16]:= 60;  // Исполнение оси
  Widths[17]:= 60;  // Тип тормозной системы
  Widths[18]:= 60;  // Колесное крепление
  Widths[19]:= 60;  // Ширина колеи [мм]
  Widths[20]:= 60;  // Дистанция
  Widths[21]:= 60;  // Hub system

  CheckStyle(skTxt);
  CheckStyle(skHead);
  CheckStyle(skBold);
  CheckStyle(skCBold);

  sYearFrom:= '';
  s:= '';
  with Cache.FDCA do try try
    sYearFrom:= GetYearFromLoadModels;
    if (sYearFrom<>'') then begin
      s:=' с годом выпуска от '+sYearFrom;
      sYearFrom:= ' where AX_FROM=0 or AX_FROM>'+sYearFrom+'00';  // ???
    end;

    AddXmlBookBegin(Result);
    AddXmlSheetBegin(Result, 'описание', 1);
    AddStr(sBoldCell('Модели осей из TecDoc'+s));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' В файле содержится перечень моделей с разбивкой по листам производителей,'+
                      ' наименование производителя указано в имени листа,'));
    AddStr(sTxtCell('   строка производителя расположена в 1-й строке таблицы листа,'+
                      ' в 1-м столбце находится опция обработки строки.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' Если в настройках СВК задан минимальный год выпуска моделей,'+
                      ' отображаются только модели'));
    AddStr(sTxtCell('   с годом начала выпуска не менее заданного и модели'+
                      ' с неопределенным годом начала выпуска.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' На листе строки отсортированы по наименованиям модельных рядов и моделей.'));
    AddStr(sTxtCell(' Опцией "/2" и жирным шрифтом обозначены данные, видимые при авто-подборе'+
                      ' в СВК, в таких строках приведены наименования из СВК.'));
    AddStr(sTxtCell(' В строках с пустой опцией - приведены данные из TecDoc, которых нет'+
                      ' в СВК или они невидимы при авто-подборе.'));
    AddStr(sTxtCell(' Столбцы между "Тип оси" и "Результат"- служебные (для загрузки данных из файла).'));
    AddStr(sTxtCell(' Столбцы после столбца "Результат" - информационные (параметры моделей в СВК).'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' В строках моделей с пустой опцией, которые должны быть видимыми'+
                      ' при авто-подборе в СВК, нужно проставить опцию "/1".'));
    AddStr(sTxtCell('   Если в строке модели проставлена опция "/1", то в строках'+
                      ' ее мод.ряда / производителя должна быть опция "/1" или "/2".'));
    AddStr(sBoldCell(' В строках моделей / мод.рядов с опцией "/1" можно изменить наименование.'));
    AddStr(sTxtCell(''));
    AddStr(sTxtCell(' При импорте обрабатываются только строки с опцией "/1", при этом'+
                      ' наименование модели / мод.ряда записывается в базу из файла, устанавливается'));
    AddStr(sTxtCell('   видимость модели / мод.ряда / производителя,'+
                      ' остальные параметры новых моделей / мод.рядов записываются из базы TecDoc.'));
    AddStr(sTxtCell(' Новые модельные ряды / производители записываются в базу СВК'+
                      ' только при наличии у них моделей с опцией "/1".'));
    AddStr(sTxtCell(' Результат обработки строки записывается в столбец "Результат",'+
                      ' в случае ошибки результат дублируется в письме с отчетом.'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('При загрузке моделей грузовых авто привязанные к ним оси'+
                       ' загружаются в базу автоматически.'));
    AddStr(sBoldCell('После проведения 67-го импорта рекомендуется обновлять 68-й отчет.'));
    AddStr(sTxtCell(''));
    AddStr(sBoldCell('ВНИМАНИЕ! В файле допускается только изменение пустых ячеек опций в 1-м столбце'));
    AddStr(sBoldCell('          и изменение ячеек с наименованием модельного ряда / модели с опцией "/1"!'));
    AddStr(sBoldCell('          Ячейки, области, листы нельзя удалять, сортировать, форматировать и т.п.!'));
    AddXmlSheetEnd(Result, 0, 0);

    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
    TdtIBS.SQL.Text:= 'select count(*) from (select MS_MF_ID from AXLES'+
      ' inner join MODEL_SERIES on MS_ID=AX_MS_ID and MS_AXL=1 and AX_DEL=0'+ // кол-во производителей
      ' group by MS_MF_ID)';
    TdtIBS.ExecQuery;
    if not (TdtIBS.Bof and TdtIBS.Eof) then Percent:= 90/TdtIBS.Fields[0].AsInteger;
    TdtIBS.Close;
    TdtIBS.SQL.Text:= 'select MS_ID, MS_DESCR, AX_ID, AX_DESC, AX_FROM, AX_TO, AX_HUB,'+
//      ' AX_TYPE, AX_BODY, AX_STYLE, AX_BRAKE, AX_WHEEL,'+
      ' AX_DI_FROM, AX_DI_TO, AX_LO_FROM, AX_LO_TO, AX_TR_WIDTH, ac.ke_descr nBody,'+
      ' bt.ke_descr nBrake, et.ke_descr nStyle, tt.ke_descr nType, aw.ke_descr nWheel,'+
      ' MS_MF_ID, iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR'+
      ' from AXLES inner join MODEL_SERIES on MS_ID=AX_MS_ID and MS_AXL=1 and AX_DEL=0'+ // мод.ряды осей
      ' left join KEY_ENTRIES ac on ac.ke_kt_id=214 and cast(ac.ke_key as integer)=AX_BODY'+
      ' left join KEY_ENTRIES bt on bt.ke_kt_id=83 and cast(bt.ke_key as integer)=AX_BRAKE'+
      ' left join KEY_ENTRIES et on et.ke_kt_id=95 and cast(et.ke_key as integer)=AX_STYLE'+
      ' left join KEY_ENTRIES tt on tt.ke_kt_id=68 and cast(tt.ke_key as integer)=AX_TYPE'+
      ' left join KEY_ENTRIES aw on aw.ke_kt_id=213 and cast(aw.ke_key as integer)=AX_WHEEL'+
      ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+sYearFrom+
      ' order by MS_MF_DESCR, MS_MF_ID, MS_DESCR, MS_ID, AX_DESC, AX_FROM';
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin
      manufTD:= TdtIBS.fieldByName('MS_MF_ID').AsInteger;   // код произв. TecDoc
      manufORD:= Manufacturers.GetManufIDByTDcode(manufTD); // ищем ID произв. по коду TecDoc
      if (manufORD<1) then manufORD:= 0;
      flMFex:= (manufORD>0) and Manufacturers.ManufExists(manufORD);
      if flMFex then begin
        manuf:= Manufacturers[manufORD];
        s:= manuf.Name;
        flMF:= flMFex and manuf.IsMfAx;
      end else begin
        manuf:= nil;
        flMF:= False;
        s:= TdtIBS.fieldByName('MF_DESCR').AsString;
      end;

      AddXmlSheetBegin(Result, s, Ncolumns, Widths);
      AddStr(sHeadCell('Опция')+sHeadCell('Произв.')+sHeadCell('М/ряд')+sHeadCell('Модель')+
          sHeadCell('От')+sHeadCell('До')+sHeadCell('Нагрузка[кг]')+sHeadCell('Тип оси')+
          sTxtCell('mf_TD')+sTxtCell('mf_ORD')+sTxtCell('ml_TD')+sTxtCell('ml_ORD')+
          sTxtCell('mod_TD')+sTxtCell('mod_ORD')+sHeadCell('Результат')+sHeadCell('Балка моста')+
          sHeadCell('Исполн.оси')+sHeadCell('Тип тормоза')+sHeadCell('Колесн.крепление')+
          sHeadCell('Шир.колеи[мм]')+sHeadCell('Дистанция[мм]')+sHeadCell('Hub system'));

      AddStr(fnIfStr(flMF, sCBoldCell('/2'), EmptyStrCell)+fnIfStr(flMF, sBoldCell(s), sTxtCell(s))+
             EmptyStrCell(6)+sIntCell(manufTD)+sIntCell(manufORD)+EmptyIntCell(4));

      while not TdtIBS.Eof and (TdtIBS.fieldByName('MS_MF_ID').AsInteger=manufTD) do begin
        mlTD:= TdtIBS.fieldByName('MS_ID').AsInteger; // код мод.ряда TecDoc
        if not flMFex then mlORD:= 0
        else mlORD:= manuf.GetMfMLineIDByTDcode(mlTD, constIsAx); // ищем ID мод.ряда по коду TecDoc
        if (mlORD<1) then mlORD:= 0;
        flML:= (mlORD>0) and ModelLines.ModelLineExists(mlORD);
        if flML then begin
          mline:= ModelLines[mlORD];
          s:= mline.Name; // наше наименование
          flML:= flML and mline.IsVisible;
        end else s:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MS_DESCR').AsString);

        AddStr(fnIfStr(flML, sCBoldCell('/2'), EmptyStrCell)+EmptyStrCell+
               fnIfStr(flML, sBoldCell(s), sTxtCell(s))+EmptyStrCell(5)+
               EmptyIntCell(2)+sIntCell(mlTD)+sIntCell(mlORD)+EmptyIntCell(2));

        while not TdtIBS.Eof and (TdtIBS.fieldByName('MS_ID').AsInteger=mlTD) do begin
          modTD := TdtIBS.fieldByName('AX_ID').AsInteger;   // код модели TecDoc
          nameTD:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('AX_DESC').AsString);  // наимен. модели TecDoc
          tdFrom:= TdtIBS.fieldByName('AX_FROM').AsInteger; // от
          tdTo  := TdtIBS.fieldByName('AX_TO').AsInteger;   // до

          if not flML then modORD:= 0
          else modORD:= mline.GetMLModelIDByTDcode(modTD); // ищем ID модели по коду TecDoc
          if (modORD<1) then modORD:= 0;
          flMod:= (modORD>0) and Models.ModelExists(modORD);
          if flMod then begin
            mdl:= Models[modORD];
            s:= mdl.Name;      // наше наименование
            flMod:= flMod and mdl.IsVisible; // выделяем только видимые
          end else s:= nameTD; // наименование TD

          if flMod then begin
            mps:= mdl.Params;
            tim:= TypesInfoModel;
            if (mps.pYStart>0) then tdFrom:= mps.pYStart*100+mps.pMStart;
            if (mps.pYEnd>0) then tdTo:= mps.pYEnd*100+mps.pMEnd;
            AddStr(sCBoldCell('/2')+EmptyStrCell(2)+sBoldCell(s)+                            // наимен. модели
              fnIfStr(mps.pYStart<1, EmptyStrCell, sBoldCell(IntToStr(tdFrom)))+             // от
              fnIfStr(mps.pYEnd<1, EmptyStrCell, sBoldCell(IntToStr(tdTo)))+                 // до
              fnIfStr(mps.cvHPaxLO='', EmptyStrCell, sBoldCell(mps.cvHPaxLOout))+            // Нагрузка[кг]
              fnIfStr(mps.pDriveID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pDriveID].Name))+   // Тип оси
              EmptyIntCell(4)+sIntCell(modTD)+sIntCell(modORD)+EmptyStrCell+
              fnIfStr(mps.pBodyID    <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pBodyID].Name))+    // Балка моста
              fnIfStr(mps.pEngTypeID <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pEngTypeID].Name))+ // Исполнение оси
              fnIfStr(mps.pBrakeID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pBrakeID].Name))+   // Тип тормозной системы
              fnIfStr(mps.pFuelID    <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pFuelID].Name))+    // Колесное крепление
              fnIfStr(mps.pCCM       <1, EmptyStrCell, sBoldCell(IntToStr(mps.pCCM)))+                 // Ширина колеи [мм]
              fnIfStr(mps.cvKWaxDI  ='', EmptyStrCell, sBoldCell(mps.cvKWaxDIOut))+                    // Дистанция [мм] от-до
              fnIfStr(mps.pTransID   <1, EmptyStrCell, sBoldCell(tim.InfoItems[mps.pTransID].Name)));  // Hub system

          end else begin
            tdCC  := TdtIBS.FieldByName('AX_TR_WIDTH').AsInteger; // Ширина колеи [мм]
            sAC   := TdtIBS.FieldByName('nType').AsString;        // Тип оси
            sBT   := TdtIBS.FieldByName('nBody').AsString;        // Балка моста
            sEnT  := TdtIBS.FieldByName('nStyle').AsString;       // Исполнение оси
            sBr   := TdtIBS.FieldByName('nBrake').AsString;       // Тип тормозной системы
            sWh   := TdtIBS.FieldByName('nWheel').AsString;       // Колесное крепление
            sHb   := TdtIBS.FieldByName('AX_HUB').AsString;       // Hub system
            tdHPfr:= TdtIBS.fieldByName('AX_LO_FROM').AsInteger;  // Нагрузка[кг] от
            tdHPto:= TdtIBS.fieldByName('AX_LO_TO').AsInteger;    // Нагрузка[кг] до
            tdKWfr:= TdtIBS.fieldByName('AX_DI_FROM').AsInteger;  // Дистанция [мм] от
            tdKWto:= TdtIBS.fieldByName('AX_DI_TO').AsInteger;    // Дистанция [мм] до
            sHP:= '';
            if (tdHPfr>0) then sHP:= IntToStr(tdHPfr);            // Нагрузка[кг] от-до
            if (tdHPto>0) then sHP:= sHP+fnIfStr(sHP<>'', '-', '')+IntToStr(tdHPto);
            sKW:= '';
            if (tdKWfr>0) then sKW:= IntToStr(tdKWfr);            // Дистанция [мм] от-до
            if (tdKWto>0) then sKW:= sKW+fnIfStr(sKW<>'', '-', '')+IntToStr(tdKWto);

            AddStr(EmptyStrCell(3)+sTxtCell(s)+
              fnIfStr(tdFrom<1, EmptyStrCell, sTxtCell(IntToStr(tdFrom)))+
              fnIfStr(tdTo<1, EmptyStrCell, sTxtCell(IntToStr(tdTo)))+
              fnIfStr(sHP='', EmptyStrCell, sTxtCell(sHP))+             // Нагрузка[кг] от-до
              fnIfStr(sAC='', EmptyStrCell, sTxtCell(sAC))+             // Тип оси
              EmptyIntCell(4)+sIntCell(modTD)+sIntCell(modORD)+EmptyStrCell+
              fnIfStr(sBT ='', EmptyStrCell, sTxtCell(sBT))+            // Балка моста
              fnIfStr(sEnT='', EmptyStrCell, sTxtCell(sEnT))+           // Исполнение оси
              fnIfStr(sBr ='', EmptyStrCell, sTxtCell(sBr))+            // Тип тормозной системы
              fnIfStr(sWh ='', EmptyStrCell, sTxtCell(sWh))+            // Колесное крепление
              fnIfStr(tdCC <1, EmptyStrCell, sTxtCell(IntToStr(tdCC)))+ // Ширина колеи [мм]
              fnIfStr(sKW ='', EmptyStrCell, sTxtCell(sKW))+            // Дистанция [мм] от-до
              fnIfStr(sHb ='', EmptyStrCell, sTxtCell(sHb)));           // Hub system
          end;
          CheckStopExecute(pUserID, ThreadData);
          TdtIBS.Next;
        end;  // цикл по мод.ряду mlTD
      end; // цикл по произв. manufTD
      AddXmlSheetEnd(Result, 1, 2);
      SetExecutePercent(pUserID, ThreadData, Percent);
    end;
    AddXmlBookEnd(Result);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    cntsTdt.SetFreeCnt(TdtIBD, True);
    Setlength(Widths, 0);
  end;
end;
//======================== 36-stamp - поиск артикулов TDT для инфо-групп Гроссби
procedure prGetArticlesINFOgrFromTDT(pUserID: Integer; pFileName: String; ThreadData: TThreadData=nil);
const nmProc = 'fnGetArticlesINFOgrFromTDT'; // имя процедуры/функции
      DelimChars = [' ', '=', '/', '\']; // разделители в наименовании товара
var TdtIBD: TIBDatabase;
    TdtIBS: TIBSQL;
    lstSups, lstCross, lstNotArtWares, lstSearch: TStringList;
    iSup, kodMF, i, ii, j, jj, iCount: Integer;
    Brand, Article, GAdescr, cross, SupFrom, WareName, s, ss, sbs, ssbs: String;
    tcodes: TTwoCodes;
    arMF: Tai;
    arSups: Tas;
    Percent: real;
    Ware: TWareInfo;
    wBrand: TBrandItem;
    arLstWareArticles: TASL;
    flSkipArt, fl, flSingle, flSupFrom, flSupsOnly, flSupsAll: Boolean;
    //--------------------- проверка "чистого" вхождения артикула в наименование
    function CheckArtInName(sArt, sName: String): Boolean;
    var ipos, ibefore, iafter: Integer;
    begin
      Result:= (sArt=sName);
      if Result then Exit;
      ipos:= pos(sArt, sName);    // позиция начала артикула
      if (ipos<1) then Exit;      // наименование не содержит артикула
      ibefore:= ipos-1;           // позиция перед артикулом
      if (ibefore>0) and                    // если не разделитель - не подходит
        not SysUtils.CharInSet(sName[ibefore], DelimChars) then Exit;
      iafter:= ipos+length(sArt); // 1-я позиция после артикула
      if (iafter<=length(sName)) and        // если не разделитель - не подходит
        not SysUtils.CharInSet(sName[iafter], DelimChars) then Exit;
      inc(iafter);                // 2-я позиция после артикула
      if (iafter<=length(sName)) and        // если не разделитель - не подходит
        not SysUtils.CharInSet(sName[iafter], DelimChars) then Exit;
      Result:= true;
    end;
    //------------------------------------- поиск соответствия с товаром Гроссби
    function FindWaresByArticle: String;
    var ii, br: Integer;
    begin
      Result:= ';';
      if lstSearch.Count>0 then lstSearch.Clear;
      s:= AnsiUpperCase(Article);                      // UPPER артикула
      sbs:= StringReplace(s, ' ', '', [rfReplaceAll]); // артикул без пробелов
      if (kodMF=531) and (copy(s, 1, 3)='AVX') then begin // CONTITECH
        ss:= fnGetAfter('AVX', s);
        ssbs:= fnGetAfter('AVX', sbs);
      end else ss:= '';
      for ii:= 0 to lstNotArtWares.Count-1 do begin // идем по списку непривязанных товаров
        Ware:= TWareInfo(lstNotArtWares.Objects[ii]);
        if lstCross.Find(Ware.Name, br) then Continue; // товар есть в аналогах
        br:= Ware.WareBrandID;      // проверяем соответствие брендов
        if {not Ware.IsINFOgr and} (br>1) and Cache.WareBrands.ItemExists(br) then begin  // ???
          wBrand:= Cache.WareBrands[br];
          if fnInIntArray(kodMF, wBrand.TDMFcodes)<0 then Continue; // бренд не подходит
        end;
        fl:= CheckArtInName(s, Ware.WareSupName) or // ищем артикул
             CheckArtInName(sbs, Ware.WareSupName) or
             CheckArtInName(s, Ware.Name) or CheckArtInName(sbs, Ware.Name);
        if not fl and (ss<>'') then // ищем артикул CONTITECH без префикса
          fl:= CheckArtInName(ss, Ware.WareSupName) or
               CheckArtInName(ssbs, Ware.WareSupName) or
               CheckArtInName(ss, Ware.Name) or CheckArtInName(ssbs, Ware.Name);
        if not fl then Continue;
        if flSingle and (lstSearch.Count>0) then begin
          lstSearch.Clear; // если нужно 1 соответствие и есть еще - не подходит
          Exit;
        end;
        lstSearch.Add(Ware.Name+';'+Ware.PgrName);
        CheckStopExecute(pUserID, ThreadData);
      end;
      if lstSearch.Count>0 then Result:= lstSearch[0];
    end;
    //---------------------------------------------- запись строки в файл
    procedure SaveStrToFile;
    var ii: Integer;
    begin
      WareName:= FindWaresByArticle; // ищем соответствие с артикулом
      cross:= '';
      if lstCross.Count>1 then lstCross.Sort;
      for ii:= 0 to lstCross.Count-1 do cross:= cross+lstCross[ii]+';';
      prMessageLOGn(WareName+';'+Brand+';'+Brand+' '+Article+';'+GAdescr+';'+cross, pFileName);
      if (lstSearch.Count>1) then // если > 1 соответствия
        for ii:= 1 to lstSearch.Count-1 do prMessageLOGn(lstSearch[ii]+';;;;', pFileName);
      Inc(iCount);
      lstCross.Clear;
      lstCross.Capacity:= 100;
    end;
    //----------------------------------------------
begin
  lstSups:= fnCreateStringList(False, 100); // список брендов
  lstCross:= fnCreateStringList(True, 100); // список товаров-аналогов 1 артикула, сортированный (для Find)
  lstNotArtWares:= fnCreateStringList(False, 1000); // список непривязанных товаров
  lstSearch:= fnCreateStringList(True, 10); // список товаров, найденных по артикулу
  TdtIBS:= nil;
  Percent:= 1;
  iCount:= 0;
  SetLength(arMF, 0);
  SetLength(arLstWareArticles, 0);

  SupFrom:= GetIniParam(nmIniFileBOB, 'reports', 'SupFrom'); // условия выборки брендов
  s:= GetIniParam(nmIniFileBOB, 'reports', 'SupsOnly');
  if s='' then SetLength(arSups, 0) else arSups:= fnSplitString(s, ',');
  flSingle:= GetIniParamInt(nmIniFileBOB, 'reports', 'SearchSingleWare')=1;
  flSupFrom:= (SupFrom<>'');
  flSupsOnly:= (length(arSups)>0);
  flSupsAll:= (not flSupFrom and not flSupsOnly);

  try
    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);

    s:= 'Проверить товар Gr;Группа товара Gr;Бренд TD;Бренд TD + артикул TD;Предметная группа TD;Аналоги-товары Gr (по TD);';
    prMessageLOGn(s, pFileName);
    SetExecutePercent(pUserID, ThreadData, Percent);
    try                                         // выбираем бренды для обработки
      TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
      TdtIBS.SQL.Text:= 'select d.ds_mf_id, d.DS_ID,'+
        ' iif(ICN_NEWDESCR is null, d.DS_BRA, ICN_NEWDESCR) bra from data_suppliers d'+
        ' left join IMPORT_CHANGE_NAMES on ICN_TAB_ID=100 and ICN_KE_KEY=d.DS_MF_ID';
      TdtIBS.ExecQuery;
      while not TdtIBS.Eof do begin
        s:= TdtIBS.FieldByName('bra').AsString;
        if flSupsAll or (flSupFrom and (s>=SupFrom))
          or (flSupsOnly and (fnInStrArray(s, arSups, False)>-1)) then
          lstSups.AddObject(s, TTwoCodes.Create(TdtIBS.FieldByName('DS_ID').AsInteger,      // ID1
                                                TdtIBS.FieldByName('ds_mf_id').AsInteger)); // ID2
        CheckStopExecute(pUserID, ThreadData); // проверка остановки процесса или системы
        TdtIBS.Next;
      end;
      TdtIBS.Close;

      Percent:= 3;
      SetExecutePercent(pUserID, ThreadData, Percent);
      if lstSups.Count>1 then begin
        lstSups.Sort;
        Percent:= 90/lstSups.Count; // процент на 1-го произв.
      end;
      //------------------ готовим инструменты для поиска артикулов
      SetLength(arMF, lstSups.Count);              // массив кодов MF брендов TD
      SetLength(arLstWareArticles, lstSups.Count); // массив списков артикулов с товарами Grossbee, по брендам
      for i:= 0 to lstSups.Count-1 do begin
        arLstWareArticles[i]:= fnCreateStringList(False, dupAccept, 1000); // инициируем
        arMF[i]:= TTwoCodes(lstSups.Objects[i]).ID2;                       // заполняем массив (ds_mf_id)
        CheckStopExecute(pUserID, ThreadData);
      end;
      //-------------------- заполняем списки для поиска
      for i:= 1 to High(Cache.arWareInfo) do if Cache.WareExist(i) then begin
        Ware:= Cache.GetWare(i);
        if Ware.IsArchive or (Ware.PgrID<1) then Continue; // архивный товар пропускаем
        if (Ware.ArtSupTD>0) and (Ware.ArticleTD<>'') then begin
          j:= fnInIntArray(Ware.ArtSupTD, arMF);    // артикул с привязанным товаром - в список бренда
          if j>-1 then arLstWareArticles[j].AddObject(Ware.ArticleTD, Ware);
        end else if Ware.IsAUTOWare then             // только авто-товары                             ???
          lstNotArtWares.AddObject(Ware.Name, Ware); // непривязанный товар - в отдельный список
        CheckStopExecute(pUserID, ThreadData);
      end;
      for i:= 0 to lstSups.Count-1 do begin // сортируем списки артикулов
        if arLstWareArticles[i].Count>1 then arLstWareArticles[i].Sort;
        arLstWareArticles[i].Sorted:= True; // устанавливаем сортировку (для Find)
        CheckStopExecute(pUserID, ThreadData);
      end;

      TdtIBS.SQL.Text:= 'select RcrossMF, RcrossNR, Rdescr from get_SupArticlesINFOgr(:xDs)';
      // процедура возвращает порции: строку с артикулом и группой, затем строки с кроссами этого артикула

      for iSup:= 0 to lstSups.Count-1 do try // идем по брендам
        tcodes:= TTwoCodes(lstSups.Objects[iSup]);
        kodMF:= tcodes.ID2; // код MF бренда
        Brand:= lstSups[iSup];
        prMessageLOGS(nmProc+': загрузка артикулов '+Brand, 'import_test', False); // debug
        lstCross.Clear;
        lstCross.Capacity:= 100;
        flSkipArt:= False;
        try
          with TdtIBS.Transaction do if not InTransaction then StartTransaction;
          TdtIBS.ParamByName('xDs').AsInteger:= tcodes.ID1;
          TdtIBS.ExecQuery; // вынимаем артикулы бренда без товаров и кроссы из TD
          while not TdtIBS.Eof do begin
            if (TdtIBS.FieldByName('RcrossMF').AsInteger=0) then begin // строка с артикулом и группой

              if lstCross.Count>0 then SaveStrToFile; // если есть товары-аналоги предыдущего артикула

              Article:= TdtIBS.FieldByName('RcrossNR').AsString; // следующий артикул
              WareName:= '';                 // проверяем артикул на привязанный товар (по Grossbee, на всяк.случай)
              flSkipArt:= arLstWareArticles[iSup].Find(Article, ii); // если нашли - артикул пропускаем
              if not flSkipArt then GAdescr:= TdtIBS.FieldByName('Rdescr').AsString;

            end else if (TdtIBS.FieldByName('Rdescr').AsString='') // строка с кроссом TD
              and not flSkipArt then begin // признак непривязанного артикула

              cross:= TdtIBS.FieldByName('RcrossNR').AsString;  // артикул кросса
              jj:= fnInIntArray(TdtIBS.FieldByName('RcrossMF').AsInteger, arMF); // определяем индекс бренда кросса
              if (jj>-1) and arLstWareArticles[jj].Find(cross, ii) then // если нашли артикул - перебираем его товары
                while (ii<arLstWareArticles[jj].Count) and (arLstWareArticles[jj][ii]=cross) do begin
                  Ware:= TWareInfo(arLstWareArticles[jj].Objects[ii]);
                  if not Ware.IsINFOgr then  // здесь инфо-товары пропускаем
                    if not lstCross.Find(Ware.Name, j) then // проверяем на дубляж
                      lstCross.AddObject(Ware.Name, Pointer(Ware.ID));
                  inc(ii);
                end; // while (ii<...Count) and (...=cross)
            end;
            CheckStopExecute(pUserID, ThreadData); // проверка остановки процесса или системы
            TdtIBS.Next;
          end;
        finally
          TdtIBS.Close;
        end;
        if lstCross.Count>0 then SaveStrToFile; // если есть товары-аналоги последнего артикула
        SetExecutePercent(pUserID, ThreadData, Percent);
      except
        on E: EBOBError do begin
          cross:= 'загрузка остановлена - ';
          prMessageLOGS(nmProc+': '+cross+'('+Brand+') '+E.Message, 'import');
          prMessageLOGn(cross+'ошибка при загрузке артикулов бренда '+Brand, pFileName);
          break;
        end;
        on E: Exception do begin
          prMessageLOGS(nmProc+': ('+Brand+') '+E.Message, 'import');
          prMessageLOGn('ошибка при загрузке артикулов бренда '+Brand, pFileName);
        end;
      end; // for iSup
      if iCount<1 then raise Exception.Create(MessText(mtkNotFoundData));
    finally
      prFreeIBSQL(TdtIBS);
      cntsTdt.SetFreeCnt(TdtIBD, True);
      prFree(lstSups);
      prFree(lstCross);
      prFree(lstNotArtWares);
      prFree(lstSearch);
      for i:= 0 to Length(arLstWareArticles) do prFree(arLstWareArticles[i]);
      SetLength(arLstWareArticles, 0);
      SetLength(arMF, 0);
      SetLength(arSups, 0);
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end;
end;
//============================================== простановка контрактов в db_ORD
function SetClientContractsToORD(UserID: Integer; ThreadData: TThreadData=nil): TStringList; // must Free Result
const nmProc = 'SetClientContractsToORD'; // имя процедуры/функции
var ibsGB, ibsOrd: TIBSQL;
    ibdGB, ibdOrd: TIBDatabase;
    sFirm, s: String;
    RecCount, j, firmID, contID, i: Integer;
    Percent: Single;
    ilst: TIntegerList;
    flSleep: Boolean;
    TimeProc, LocalTime: TDateTime;
begin
  Result:= TStringList.Create; // отчет для администратора
  ibdOrd:= nil;
  ibdGB:= nil;
  ibsOrd:= nil;
  ibsGB:= nil;
  ilst:= TIntegerList.Create;
  flSleep:= not flDebug and fnGetActionTimeEnable(caeOnlyWorkTime);
  TimeProc:= Now;
  RecCount:= 0;
  try try
    ibdOrd:= cntsORD.GetFreeCnt;
    ibdGB:= cntsGRB.GetFreeCnt;

    Result.Add('простановка контрактов в db_ORD:');
    SetExecutePercent(UserID, ThreadData, 1);

    ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibsOrd_'+nmProc, -1, tpRead, True);
    ibsOrd.SQL.Text:= 'select xFirm from GetFirmWithoutOrderContract';
    ibsOrd.ExecQuery;
    SetExecutePercent(UserID, ThreadData, 1);
    while not ibsOrd.Eof do begin
      ilst.Add(ibsOrd.fieldByName('xFirm').AsInteger);
      TestCssStopException;
      ibsOrd.Next;
    end;
    ibsOrd.Close;
    if (ilst.Count<1) then begin
      Result.Add('не найдены к/а для обработки');
      Exit;
    end;
    Percent:= 90*100/ilst.Count;

    ibsOrd.SQL.Clear;
    fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
    ibsOrd.SQL.Text:= 'execute procedure SetOrderContract(:xFirm, :xContr)';
    ibsOrd.Prepare;

    ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc, -1, tpRead, True);
    ibsGB.SQL.Text:= 'select CONTCODE from Contract'+
      ' where CONTSECONDPARTY=:firm and CONTUSEBYDEFAULT="T"'+
      '  and contfirstparty=(select userfirmcode from userpsevdonimreestr where usercode=1)';
    j:= 0;
    LocalTime:= Now;
    for i:= 0 to ilst.Count-1 do begin
      firmID:= ilst[i];
      contID:= 0;
      if Cache.FirmExist(firmID) then
        contID:= Cache.arFirmInfo[firmID].GetDefContractID;
      if (contID<1) then begin
        ibsGB.ParamByName('firm').AsInteger:= firmID;
        ibsGB.ExecQuery;
        if not (ibsGB.Eof and ibsGB.Bof) then
          contID:= ibsGB.fieldByName('CONTCODE').AsInteger;
        ibsGB.Close;
      end;
      if (contID<1) then Continue;

      sFirm:= IntToStr(firmID);
      try
        with ibsOrd.Transaction do if not InTransaction then StartTransaction;
        ibsOrd.ParamByName('xFirm').AsInteger:= firmID;
        ibsOrd.ParamByName('xContr').AsInteger:= contID;
        ibsOrd.ExecQuery;
        ibsOrd.Transaction.Commit;
      except
        on E: Exception do begin
          ibsOrd.Transaction.Rollback;
          s:= 'ошибка обработки FIRMCODE='+sFirm+': '+E.Message;
          Result.Add(s);
          prMessageLOGS(nmProc+': '+s, 'import');
        end;
      end;
      ibsOrd.Close;
      inc(j);
      inc(RecCount);
      if j>=100 then begin               // отображение процентов
        SetExecutePercent(UserID, ThreadData, Percent);
        j:= 0;
      end else inc(j);

      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
    end;
  except
    on E: Exception do begin
      Result.Add(E.Message);
      prMessageLOGS(nmProc+': '+E.Message, 'import');
    end;
  end;
  finally
    Result.Add('обработано '+IntToStr(RecCount)+' к/а, время - '+GetLogTimeStr(TimeProc));
    prFreeIBSQL(ibsGB);     // отпускаем коннект Grossbee
    cntsGRB.SetFreeCnt(ibdGB);
    prFreeIBSQL(ibsOrd);     // отпускаем коннект ib_ord
    cntsORD.SetFreeCnt(ibdOrd);
    prFree(ilst);
  end;
end;
//======================= 24(4/5)-stamp - проверка глав.пользователей в Grossbee
procedure CheckGeneralPersonsForGB(UserID: Integer; pFileName: String;
          ThreadData: TThreadData=nil; CheckNotArhLogins: Boolean=False);
const nmProc = 'CheckGeneralPersonsForGB'; // имя процедуры/функции
// 4- обычный режим, 5- + проверка неархивных логинов у архивных клиентов
var ibsGB, ibsGBw, ibsOrd: TIBSQL;
    ibdGB, ibdGBw, ibdOrd: TIBDatabase;
    s, login, ss, loginWeb, str: String;
    RecCount, SetCount, ChangeCount, firmID, personID, superID, i: Integer;
    Olist: TObjectList;
    lstSQL: TStringList;
    qq: TCodeAndQty;
    flArhFirm, flArhPers: Boolean;
begin
  ibdOrd:= nil;
  ibsOrd:= nil;
  ibdGB:= nil;
  ibsGB:= nil;
  ibdGBw:= nil;
  ibsGBw:= nil;
  Olist:= TObjectList.Create;
  lstSQL:= TStringList.Create; //
  RecCount:= 0;
  SetCount:= 0;
  ChangeCount:= 0;
  try try
    ibdOrd:= cntsORD.GetFreeCnt;
    ibdGB:= cntsGRB.GetFreeCnt;
    ibdGBw:= cntsGRB.GetFreeCnt;
    ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibsOrd_'+nmProc, -1, tpRead, True);
    ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc, -1, tpRead, True);
    ibsGBw:= fnCreateNewIBSQL(ibdGBw, 'ibsGBw_'+nmProc, -1, tpWrite, True);
    ibsGB.SQL.Text:= 'select FIRMMAINNAME, FIRMSHORTNAME, FIRMARCHIVEDKEY,'+
      ' FIRMSERVICEFIRM, PRSNCODE, PRSNARCHIVEDKEY, PRSNLOGIN, PRSNPOST, PRSNNAME,'+
      ' (select first 1 GnPrPersonCode from GeneralPerson where GnPrFirmCode=FIRMCODE'+
      '   order by GnPrDate desc) as mainuser from FIRMS'+
      ' left join PERSONS on PRSNFIRMCODE=FIRMCODE where FIRMCODE=:firm';

    str:= 'проверка глав.пользователей в Grossbee:';
    prMessageLOGn(str, pFileName);
    str:= 'код к/а;Шифр;Наименование к/а;арх.к/а;код сотр.;арх.сотр.;должн.;имя;логин Грос;логин Web;примечание';
    prMessageLOGn(str, pFileName);
    SetExecutePercent(UserID, ThreadData, 1);

    ibsOrd.SQL.Text:= 'select WOFRCODE, WOFRSUPERVISOR, WOCLCODE, WOCLLOGIN'+
      ' from WEBORDERFIRMS left join WEBORDERCLIENTS on WOCLFIRMCODE=WOFRCODE order by WOFRCODE';
    ibsOrd.ExecQuery;
    SetExecutePercent(UserID, ThreadData, 1);
    while not ibsOrd.Eof do begin
      firmID:= ibsOrd.fieldByName('WOFRCODE').AsInteger;        // код к/а
      superID:= ibsOrd.fieldByName('WOFRSUPERVISOR').AsInteger; // код глав.польз.
      Olist.Clear;
      while not ibsOrd.Eof and (firmID=ibsOrd.fieldByName('WOFRCODE').AsInteger) do begin
        qq:= TCodeAndQty.Create(ibsOrd.fieldByName('WOCLCODE').AsInteger, 0, ibsOrd.fieldByName('WOCLLOGIN').AsString);
        Olist.Add(qq); // коды сотрудников с логинами
        TestCssStopException;
        ibsOrd.Next;
      end;
      try
        ibsGB.ParamByName('firm').AsInteger:= firmID;
        ibsGB.ExecQuery;
        while not ibsGB.Eof do begin
          personID:= ibsGB.fieldByName('PRSNCODE').AsInteger;
          login:= ibsGB.fieldByName('PRSNLOGIN').AsString;
          flArhFirm:= GetBoolGB(ibsGB, 'FIRMARCHIVEDKEY');
          flArhPers:= GetBoolGB(ibsGB, 'PRSNARCHIVEDKEY');
          s:= '';
          qq:= nil;
          for i:= 0 to Olist.Count-1 do begin // ищем такой код сотрудника из ORD
            qq:= TCodeAndQty(Olist[i]);
            if (qq.ID=personID) then break else qq:= nil;
          end;
          loginWeb:= '';
          if Assigned(qq) then begin // если нашли - проверяем
            loginWeb:= qq.Name;
            if (login<>qq.Name) then begin
              lstSQL.Add('update persons set prsnlogin="'+qq.Name+'" where prsncode='+IntToStr(personID)+';');
//              s:= s+fnIfStr(s='', '', ', ')+'несоотв.логинов';
            end;
            if (personID=superID) then  // главный
              if (flArhPers and not flArhFirm) then
                s:= s+fnIfStr(s='', '', ', ')+'арх.главный'
              else if (not flArhPers and not flArhFirm and (s='')) then begin
                if (ibsGB.fieldByName('mainuser').AsInteger<>superID) then begin
                  ss:= SetMainUserToGB(FirmID, superID, Date(), ibsGBw);
                  if (ss='') then inc (SetCount) else s:= s+fnIfStr(s='', '', ', ')+ss;
                end;
              end;
            //------------------ проверка неархивных логинов у архивных клиентов
            if CheckNotArhLogins and (flArhPers or flArhFirm) and (copy(login, 1, 1)<>'_') then
              s:= s+fnIfStr(s='', '', ', ')+'неарх.логин у арх.клиента';
          end else if (login<>'') then s:= s+fnIfStr(s='', '', ', ')+'несоотв.Web';

          if (s<>'') then begin
            str:= IntToStr(firmID)+';'+ ibsGB.fieldByName('FIRMSHORTNAME').AsString+';'+
              ibsGB.fieldByName('FIRMMAINNAME').AsString+';'+
              ibsGB.fieldByName('FIRMARCHIVEDKEY').AsString+';'+
              ibsGB.fieldByName('PRSNCODE').AsString+';'+
              ibsGB.fieldByName('PRSNARCHIVEDKEY').AsString+';'+
              ibsGB.fieldByName('PRSNPOST').AsString+';'+
              ibsGB.fieldByName('PRSNNAME').AsString+';'+login+';'+loginWeb+';'+s;
            prMessageLOGn(str, pFileName);
          end;
          TestCssStopException;
          ibsGB.Next;
        end;
      finally
        ibsGB.Close;
      end;
      inc (RecCount);
    end;

    if (lstSQL.Count>0) then begin
      lstSQL.Insert(0, 'execute block as begin ');
      lstSQL.Add(' end');
      ibsGBw.Close;
      ibsGBw.SQL.Clear;
      ibsGBw.SQL.AddStrings(lstSQL);
      with ibsGBw.Transaction do if not InTransaction then StartTransaction;
      ibsGBw.ExecQuery;
      ibsGBw.Transaction.Commit;
      ChangeCount:= lstSQL.Count;
    end;
  except
    on E: Exception do begin
      prMessageLOGn(E.Message, pFileName);
      prMessageLOGS(nmProc+': '+E.Message, 'import');
    end;
  end;
  finally
    str:= 'проверено к/а - '+IntToStr(RecCount)+', записано гл.польз. - '+
          IntToStr(SetCount)+', изменено логинов - '+IntToStr(ChangeCount);
    prMessageLOGn(str, pFileName);
    prFreeIBSQL(ibsGB);     // отпускаем коннект Grossbee
    cntsGRB.SetFreeCnt(ibdGB);
    prFreeIBSQL(ibsGBw);     // отпускаем коннект Grossbee
    cntsGRB.SetFreeCnt(ibdGBw);
    prFreeIBSQL(ibsOrd);     // отпускаем коннект ib_ord
    cntsORD.SetFreeCnt(ibdOrd);
    prFree(Olist);
    prFree(lstSQL);
  end;
end;

//******************************************************************************
//                   импорт данных из fb_tdt.fdb в ib_ord.gdb
//******************************************************************************
//========================= 25-imp - загрузка моделей авто из TDT из файла Excel
procedure prSetNewAutoMfMlModFromTDT(UserID: integer; FileName: string;
          var BodyMail: TStringList; ThreadData: TThreadData=nil);
const nmProc = 'prSetNewAutoMfMlModFromTDT'; // имя процедуры/функции
var mlORD, mlTD, mORD, mTD, mfORD, mfTD, iAdd, iErr, iUpd, ii, iMail,
      tdFrom, tdTo, mFrom, yFrom, mTo, yTo, iLine, SheetCount, SheetID, rows: integer;
    fVis, fTop, fAddMf, fAddMl, fUpdMf, fUpdMl, fAddMod, fUpdMod: Boolean;
    mName, mlName, mfName, ss, s, SheetName, MailStr: string;
    arMpsORD: TarMps;
    TdtIBD: TIBDatabase;
    TdtIBS, TdtIBSm: TIBSQL;
    KeyTabs: TarKeyTabs; // Tai: индекс - код TDT, значение - код ORD
    mps: TModelParams;
    marks: TStringList;
    Percent, ListPercent: real;
    XL: TExcelApplication;
    WorkBook: Excel_TLB._Workbook;
    WorkSheet: Excel_TLB._Worksheet;
    manuf: TManufacturer;
    mline: TModelLine;
    model: TModelAuto;
    //--------------------------------------------
    procedure SaveStrToMail(str: String);
    begin
      if not Assigned(BodyMail) then BodyMail:= TStringList.Create;
      if (iMail<1) then BodyMail.Add(' ');
      BodyMail.Add(str);
      inc(iMail);
    end;
    //--------------------------------------------
begin
  TdtIBS:= nil;
  TdtIBSm:= nil;
  TdtIBD:= nil;
  mps:= nil;
  manuf:= nil;
  mline:= nil;
  model:= nil;
  XL:= nil;
  WorkBook:= nil;
  marks:= TStringList.Create;
  SetLength(KeyTabs, 0);
  SetExecutePercent(UserID, ThreadData, 1);
  iMail:= 0;
  with Cache.FDCA do try try // заполняем имена полей для поиска соответствий
    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    TdtIBSm:= fnCreateNewIBSQL(TdtIBD, 'TdtIBSm_'+nmProc, -1, tpRead); // для маркировок (GetEngMarks)
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);

    SetLength(KeyTabs, 9);
    FillKeTabRecNf(0, 'MT_BT' , KeyTabs);  // Тип кузова
    FillKeTabRecNf(1, 'MT_DR' , KeyTabs);  // Тип привода
    FillKeTabRecNf(2, 'MT_ENG', KeyTabs);  // Тип двигателя
    FillKeTabRecNf(3, 'MT_FT' , KeyTabs);  // Тип топлива
    FillKeTabRecNf(4, 'MT_FF' , KeyTabs);  // Система впрыска
    FillKeTabRecNf(5, 'MT_BRT', KeyTabs);  // Тип тормозной системы
    FillKeTabRecNf(6, 'MT_BRS', KeyTabs);  // Тормозная система
    FillKeTabRecNf(7, 'MT_CT' , KeyTabs);  // Тип катализатора
    FillKeTabRecNf(8, 'MT_TT' , KeyTabs);  // Вид коробки передач
    FillarKeyTabsFromTDT(KeyTabs, 120, TdtIBS); // вынимаем в KeyTabs нужные списки TDT
    try
      OpenWorkBookNotVisible(FileName, XL, WorkBook); // открыть файл Excel для импорта
      SheetCount:= WorkBook.Worksheets.Count; //количество листов excel
      ListPercent:= 90/SheetCount;
  //      for i:= 1 to SheetCount do prMessageLOGS(nmProc+': '+(WorkBook.Sheets.Item[i] as Excel_TLB._Worksheet).Name, 'import', False);
      for SheetID:= 1 to SheetCount do try
        WorkSheet:= WorkBook.Sheets.Item[SheetID] as Excel_TLB._Worksheet;
        SheetName:= AnsiUpperCase(WorkSheet.Name);
        if pos('ОПИСАНИЕ', SheetName)>0 then Continue; // пропускаем лист "Описание"
        if pos('ЛИСТ', SheetName)>0 then Continue;     // пропускаем стандартные листы

        GetWorkSheetCounts(WorkSheet, rows, ii); // получить кол-во строк и столбцов на листе
        if rows<2 then Continue;                // переходим к следующему листу
        if ii<15 then // проверяем кол-во столбцов
          raise Exception.Create(MessText(mtkNotEnoughParams)+' - мало столбцов');
        CheckStopExecute(UserID, ThreadData);

        Percent:= ListPercent/rows;
        fAddMl:= False;
        fUpdMl:= False;
        fAddMf:= False;
        fUpdMf:= False;
        mfTD:= 0;
        mfORD:= 0;
        mlTD:= 0;
        mlORD:= 0;
        mORD:= 0;
        iAdd:= 0;
        iErr:= 0;
        iUpd:= 0;
  //     1          2          3         4         5      6      7          8      индекс ячейки
  // ('Опция')+('Произв.')+('М/ряд')+('Модель')+('От')+('До')+('Л/с')+('Марк/двиг')+
  //     9         10        11         12         13         14         15        индекс ячейки
  // ('mf_TD')+('mf_ORD')+('ml_TD')+('ml_ORD')+('mod_TD')+('mod_ORD')+('result')

        for iLine:= 2 to rows do try // считываем строки файла (1-я строка - заголовок)
          CheckStopExecute(UserID, ThreadData);
          SetExecutePercent(UserID, ThreadData, Percent);
  //--------------------------------------------------------- строка производителя
          s:= GetCellStrValue(WorkSheet, CellSigns[2], iLine);
          if (s<>'') then begin
            mfTD:= GetCellIntValue(WorkSheet, CellSigns[9], iLine);  // код TecDoc произв.
            mfORD:= GetCellIntValue(WorkSheet, CellSigns[10], iLine); // ID произв.
            mfName:= s;
            fAddMf:= True;
            fUpdMf:= True;  // оба флага = True - сигнал проверки
            Continue;
          end;
  //-------------------------------------------------------------- строка мод.ряда
          s:= GetCellStrValue(WorkSheet, CellSigns[3], iLine);
          if (s<>'') then begin
            mlTD := GetCellIntValue(WorkSheet, CellSigns[11], iLine); // код TecDoc мод.ряда
            mlORD:= GetCellIntValue(WorkSheet, CellSigns[12], iLine); // ID мод.ряда
            mlName:= fnReplaceQuotedForWeb(s);
            fAddMl:= True;
            fUpdMl:= True;  // оба флага = True - сигнал проверки
            Continue;
          end;
  //---------------------------------------------------------------- строка модели
          s:= GetCellStrValue(WorkSheet, CellSigns[4], iLine);
          if (s='') then Continue;  // если не строка модели - пропускаем

          ss:= GetCellStrValue(WorkSheet, CellSigns[1], iLine);
          if (ss<>'/1') then Continue; // если опция <> "/1" - пропускаем

  //------------------------------------------------------ обработка строки модели
          mTD := GetCellIntValue(WorkSheet, CellSigns[13], iLine); // код TecDoc модели
          mORD:= GetCellIntValue(WorkSheet, CellSigns[14], iLine); // ID модели
          mName:= fnReplaceQuotedForWeb(s);

          if ((mORD<1) and (mTD<1)) then   // не определена модель
            raise Exception.Create(MessText(mtkNotValidParam)+' - модель');
          if ((mlORD<1) and (mlTD<1)) then // не определен мод.ряд
            raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
          if ((mfORD<1) and (mfTD<1)) then // не определен произв.
            raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');

          if fAddMf and fUpdMf then begin // 2 флага = True - сигнал проверки произв.
            if (mfORD<1) then mfORD:= Manufacturers.GetManufIDByTDcode(mfTD);
            fAddMf:= not Manufacturers.ManufExists(mfORD);     // надо добавлять
            if not fAddMf then begin
              manuf:= Manufacturers[mfORD];
              fUpdMf:= (not manuf.CheckIsTypeSys(constIsAuto) or
                        not manuf.CheckIsVisible(constIsAuto)); // надо открыть видимость
            end else fUpdMf:= False;
          end;

          if fAddMl and fUpdMl then begin // 2 флага = True - сигнал проверки мод.ряда
            if not fAddMf and (mlORD<1) then
              mlORD:= manuf.GetMfMLineIDByTDcode(mlTD);
            fAddMl:= not ModelLines.ModelLineExists(mlORD);          // надо добавлять
            if not fAddMl then begin
              mline:= ModelLines[mlORD];                             // надо редактировать
              fUpdMl:= not fAddMl and (not mline.IsVisible or (mline.Name<>mlName));
            end else fUpdMl:= False;
          end;

          if not fAddMl and (mORD<1) then                    // проверяем модель
            mORD:= mline.GetMLModelIDByTDcode(mTD);
          fAddMod:= (mORD<1) or not Models.ModelExists(mORD);   // надо добавлять
          if not fAddMod then begin
            model:= Models[mORD];                               // надо редактировать
            fUpdMod:= not fAddMod and (not model.IsVisible or (model.Name<>mName));
          end else fUpdMod:= False;

          if not fAddMod and not fUpdMod then begin
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '/2');
            SetCellStrValue(WorkSheet, CellSigns[15], iLine, ''); // вписываем результат
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - модель уже есть';
            SaveStrToMail(MailStr);
            Continue;
          end;

  //-------------------------------------------------- отрабатываем редактирование
          fVis:= True;
          ss:= '';
          if fUpdMf then begin //--------------- если надо - редактируем произв.
            fTop:= manuf.CheckIsTop(constIsAuto);
            mfName:= manuf.Name;
            s:= Manufacturers.ManufEdit(mfORD, constIsAuto, UserID, fTop, fVis, mfName, mfTD);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then s:= 'уст.видим.произв.'
            else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
            fUpdMf:= False;
          end; // отредактировали произв.

          if fUpdMl then begin //--------------- если надо - редактируем мод.ряд
            with mline do begin
              if mlName='' then mlName:= Name;
              yFrom:= YStart;
              mFrom:= MStart;
              yTo:= YEnd;
              mTo:= MEnd;
              fTop:= IsTop;
            end;
            s:= manuf.ModelLineEdit(mlORD, yFrom, mFrom,
              yTo, mTo, UserID, fTop, fVis, mlName, mlTD);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then s:= 'уст.видим.мод.ряда'
            else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
            fUpdMl:= False;
          end; // отредактировали мод.ряд

          if fUpdMod then with model do begin //------ редактируем модель
            if (Name<>mName) then
              s:= ModelEdit(mName, fVis, IsTop, UserID, Params)
            else s:= SetModelVisible(fVis);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then begin
              s:= 'устан.видим.модели';
              inc(iUpd);
            end else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;

  //------------------------------------------------------ отрабатываем добавление
          end else if fAddMod then try
            with TdtIBS.Transaction do if not InTransaction then StartTransaction;
            if TdtIBS.SQL.Text='' then
              TdtIBS.SQL.Text:= 'select MT_MS_ID, MT_MS_DESCR, MT_ID, MT_DESCR, MS_MF_ID,'+
                ' iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR,'+
                ' MS_FROM, MS_TO, MT_FROM, MT_TO, MT_KW, MT_HP, MT_CC_TEC, MT_CYL, MT_VLV,'+
                ' (select key_to from get_key_code (120, MT_BT, "MT_BT")) MT_BT,'+    // Тип кузова
                ' (select key_to from get_key_code (120, MT_DR, "MT_DR")) MT_DR,'+    // Тип привода
                ' (select key_to from get_key_code (120, MT_ENG, "MT_ENG")) MT_ENG,'+ // Тип двигателя
                ' (select key_to from get_key_code (120, MT_FT, "MT_FT")) MT_FT,'+    // Тип топлива
                ' (select key_to from get_key_code (120, MT_FF, "MT_FF")) MT_FF,'+    // Система впрыска
                ' (select key_to from get_key_code (120, MT_BRT, "MT_BRT")) MT_BRT,'+ // Тип тормозной системы
                ' (select key_to from get_key_code (120, MT_BRS, "MT_BRS")) MT_BRS,'+ // Тормозная система
                ' (select key_to from get_key_code (120, MT_CT, "MT_CT")) MT_CT,'+    // Тип катализатора
                ' (select key_to from get_key_code (120, MT_TT, "MT_TT")) MT_TT'+     // Вид коробки передач
                ' from MODEL_TYPES left join MODEL_SERIES on MS_ID=MT_MS_ID'+
                ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+
                ' where MT_ID=:mt';
            TdtIBS.ParamByName('mt').AsInteger:= mTD;
            TdtIBS.ExecQuery;
            if (TdtIBS.Bof and TdtIBS.Eof) then
              raise Exception.Create(MessText(mtkNotValidParam)+' - модель TD');
            if mfTD<>TdtIBS.fieldByName('MS_MF_ID').AsInteger then
              raise Exception.Create(MessText(mtkNotValidParam)+' - произв. TD');
            if mlTD<>TdtIBS.fieldByName('MT_MS_ID').AsInteger then
              raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд TD');

            if fAddMf then begin //--------------- если надо - добавляем произв.
  //              if mfName='' then
                mfName:= TdtIBS.fieldByName('MF_DESCR').AsString;  // наимен. произв.
              fTop:= False;
              s:= Manufacturers.ManufAdd(mfORD, mfName, constIsAuto, UserID, fTop, fVis, mfTD);
              if (s=MessText(mtkNotParams)) then s:= ''
              else if (s='') then s:= 'доб.произв.'
              else raise Exception.Create(s);
              if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
              fAddMf:= False;
              if (mfORD<1) then // не определен ID произв.
                raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');
              manuf:= Manufacturers[mfORD];
            end; // добавили произв.

            if fAddMl then begin //--------------- если надо - добавляем мод.ряд
              if mlName='' then
                mlName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MT_MS_DESCR').AsString);    // наимен. мод.ряда
              tdFrom := TdtIBS.fieldByName('MS_FROM').AsInteger;      // от
              tdTo:= TdtIBS.fieldByName('MS_TO').AsInteger;           // до

              if tdFrom>0 then yFrom:= tdFrom div 100 else yFrom:= 0; // Год начала выпуска
              if yFrom>0 then mFrom:= tdFrom mod 100 else mFrom:= 0;  // Месяц начала выпуска
              if tdTo>0 then yTo:= tdTo div 100 else yTo:= 0;         // Год конца выпуска
              if yTo>0 then mTo:= tdTo mod 100 else mTo:= 0;          // Месяц конца выпуска
              fTop:= False;
              s:= manuf.ModelLineAdd(mlORD, mlName, constIsAuto,
                mFrom, yFrom, mTo, yTo, UserID, fTop, fVis, mlTD);
              if (s=MessText(mtkNotParams)) then s:= ''
              else if (s='') then s:= 'доб.мод.ряд'
              else raise Exception.Create(s);
              if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
              fAddMl:= False;
              if (mlORD<1) then // не определен ID мод.ряда
                raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
            end; // добавили мод.ряд

            if (mName='') then   //------------------------ добавляем новую модель
              mName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MT_DESCR').AsString);  // наимен. модели TecDoc
            tdFrom:= TdtIBS.fieldByName('MT_FROM').AsInteger;   // от
            tdTo  := TdtIBS.fieldByName('MT_TO').AsInteger;     // до
            if (tdFrom>0)      then arMpsORD[1]:= tdFrom div 100 else arMpsORD[1]:= 0; // Год начала выпуска
            if (arMpsORD[1]>0) then arMpsORD[0]:= tdFrom mod 100 else arMpsORD[0]:= 0; // Месяц начала выпуска
            if (tdTo>0)        then arMpsORD[3]:= tdTo   div 100 else arMpsORD[3]:= 0; // Год конца выпуска
            if (arMpsORD[3]>0) then arMpsORD[2]:= tdTo   mod 100 else arMpsORD[2]:= 0; // Месяц конца выпуска
            arMpsORD[4]:= TdtIBS.FieldByName('MT_KW').AsInteger;     // Мошность кВт.
            arMpsORD[5]:= TdtIBS.FieldByName('MT_HP').AsInteger;     // Мощность ЛС
            arMpsORD[6]:= TdtIBS.FieldByName('MT_CC_TEC').AsInteger; // Тех. объем куб. см.
            arMpsORD[7]:= TdtIBS.FieldByName('MT_CYL').AsInteger;    // Кол. цилиндров
            arMpsORD[8]:= TdtIBS.FieldByName('MT_VLV').AsInteger;    // Кол. клапанов на одну камеру сгорания
            for ii:= Low(KeyTabs) to High(KeyTabs) do arMpsORD[ii+9]:=  // Тип кузова .. Вид коробки передач
              GetInfoCode(TdtIBS.FieldByName(KeyTabs[ii].FieldNameTDT).AsInteger, UserID, KeyTabs[ii]);
            fTop:= False;
            MakeMpsFromArray(arMpsORD, mps);
            GetEngMarks(mTD, constIsAuto, UserID, marks, TdtIBSm); // маркировки двигателей
            s:= Models.ModelAdd(mORD, mName, fVis, fTop, UserID, mlORD, mps, -1, mTD, marks);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then begin
              s:= 'доб.модель';
              inc(iAdd);
            end else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
          finally
            TdtIBS.Close;
          end; // if fAddMod

          if (GetCellStrValue(WorkSheet, CellSigns[1], iLine)='/1') then  // если опция = "/1" - заменяем на '/2'
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '/2');
          if (GetCellIntValue(WorkSheet, CellSigns[14], iLine)=0) and (mORD>0) then // если добавили модель
            SetCellIntValue(WorkSheet, CellSigns[14], iLine, mORD);              // вписываем код модели
          if (ss<>'') then SetCellStrValue(WorkSheet, CellSigns[15], iLine, ss); // вписываем результат
        except
          on E: EBOBError do begin
            if (E.Message<>'') or (ss<>'') then
              SetCellStrValue(WorkSheet, CellSigns[15], iLine, fnIfStr(ss='', '', ss+', ')+E.Message); // вписываем сообщение
            raise EBOBError.Create('строка '+IntToStr(iLine)+' - '+E.Message);
          end;
          on E: Exception do begin
            inc(iErr);
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - '+E.Message;
            SaveStrToMail(MailStr);
            prMessageLOGS(nmProc+': '+MailStr, 'import', False);
            if (E.Message<>'') or (ss<>'') then
              SetCellStrValue(WorkSheet, CellSigns[15], iLine, fnIfStr(ss='', '', ss+', ')+E.Message); // вписываем сообщение
          end;
        end; // for iLine:= 2 to rows

        try                           //--------------------------- итоги по листу
          iLine:= rows+1;
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, '----------------------');
          inc(iLine);
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'обработано:   '+IntToStr(iLine)+' строк');
          inc(iLine);
          if iAdd>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'добавлено :   '+IntToStr(iAdd)+' моделей');
            inc(iLine);
          end;
          if iUpd>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'уст.видим.:   '+IntToStr(iUpd)+' моделей');
            inc(iLine);
          end;
          if iErr>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'ошибки    :   '+IntToStr(iErr)+' строк');
            SaveStrToMail('лист ['+WorkSheet.Name+'] - '+IntToStr(iErr)+' ошибок');
            inc(iLine);
          end;
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, '----------------------');
        except
          on E: Exception do
            prMessageLOGS(nmProc+': ошибка в итогах на листе ['+WorkSheet.Name+'] '+E.Message, 'import', False);
        end;
       CheckStopExecute(UserID, ThreadData);
       SetExecutePercent(UserID, ThreadData, Percent);
      except
        on E: EBOBError do raise Exception.Create('лист ['+WorkSheet.Name+']: '+E.Message);
        on E: Exception do begin
          MailStr:= 'лист ['+WorkSheet.Name+'] - '+E.Message;
          SaveStrToMail(MailStr);
          prMessageLOGS(nmProc+': '+MailStr, 'import', False);
        end;
      end; // for SheetID:= 1 to SheetCount
    finally
      SaveAndCloseWorkBook(XL, WorkBook);
    end;
  except
    on E: Exception do begin
      SaveStrToMail(E.Message);
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import', False);
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    prFreeIBSQL(TdtIBSm);
    cntsTDT.SetFreeCnt(TdtIBD, True);
    ClearArKeyTabs(KeyTabs);
    prFreeAndNilStrListWithObj(marks);
    prFree(mps);
    if (iMail>0) then BodyMail.Add(' ');
  end;
end;
//=================== 67-imp - загрузка моделей грузовиков из TDT из файла Excel
procedure prSetNewCVMfMlModFromTDT(UserID: integer; FileName: string;
          var BodyMail: TStringList; ThreadData: TThreadData=nil);
const nmProc = 'prSetNewCVMfMlModFromTDT'; // имя процедуры/функции
var mlORD, mlTD, mORD, mTD, mfORD, mfTD, iAdd, iErr, iUpd, ii, iMail,
      tdFrom, tdTo, mFrom, yFrom, mTo, yTo, iLine, SheetCount, SheetID, rows: integer;
    fVis, fTop, fAddMf, fAddMl, fUpdMf, fUpdMl, fAddMod, fUpdMod: Boolean;
    mName, mlName, mfName, ss, s, SheetName, MailStr: string;
    arMpsORD: TarMps;
    TdtIBD, ordIBD: TIBDatabase;
    TdtIBS, TdtIBSm, TdtIBSa, TdtIBSl, ordIBS: TIBSQL;
    KeyTabs, KeyTabsA: TarKeyTabs; // Tai: индекс - код TDT, значение - код ORD
    mps: TModelParams;
    marks: TStringList;
    Percent, ListPercent: real;
    XL: TExcelApplication;
    WorkBook: Excel_TLB._Workbook;
    WorkSheet: Excel_TLB._Worksheet;
    manuf: TManufacturer;
    mline: TModelLine;
    model: TModelAuto;
    //--------------------------------------------
    procedure SaveStrToMail(str: String);
    begin
      if not Assigned(BodyMail) then BodyMail:= TStringList.Create;
      if (iMail<1) then BodyMail.Add(' ');
      BodyMail.Add(str);
      inc(iMail);
    end;
    //--------------------------------------------
begin
  TdtIBD:= nil;
  TdtIBS:= nil;
  TdtIBSm:= nil;
  TdtIBSl:= nil;
  TdtIBSa:= nil;
  ordIBD:= nil;
  ordIBS:= nil;
  mps:= nil;
  XL:= nil;
  WorkBook:= nil;
  manuf:= nil;
  mline:= nil;
  model:= nil;
  marks:= TStringList.Create;
  SetLength(KeyTabs, 0);
  SetLength(KeyTabsA, 0);
  SetExecutePercent(UserID, ThreadData, 1);
  iMail:= 0;
  with Cache.FDCA do try try // заполняем имена полей для поиска соответствий
    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    TdtIBSm:= fnCreateNewIBSQL(TdtIBD, 'TdtIBSm_'+nmProc, -1, tpRead); // для маркировок (GetEngMarks)
    TdtIBSl:= fnCreateNewIBSQL(TdtIBD, 'TdtIBSl_'+nmProc, -1, tpRead); // для связей с осями (GetCVaxlesFromTDT)
    TdtIBSa:= fnCreateNewIBSQL(TdtIBD, 'TdtIBSa_'+nmProc, -1, tpRead); // для осей (GetCVaxlesFromTDT)
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
    ordIBD:= cntsORD.GetFreeCnt('', '', '', True);
    ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite);  // для записи связей с осями (GetCVaxlesFromTDT)

    SetLength(KeyTabs, 3);
    FillKeTabRecNf(0, 'CPT_BT', KeyTabs);  // Конструкция
    FillKeTabRecNf(1, 'CPT_AC', KeyTabs);  // Конфигурация оси
    FillKeTabRecNf(2, 'CPT_ENG', KeyTabs); // Тип двигателя
    FillarKeyTabsFromTDT(KeyTabs, 532, TdtIBS); // вынимаем в KeyTabs нужные списки TDT

    SetLength(KeyTabsA, 5); // заполняем KeyTabsA для осей
    FillKeTabRecNf(0, 'AX_BODY', KeyTabsA);   // Балка моста
    FillKeTabRecNf(1, 'AX_TYPE', KeyTabsA);   // Тип оси
    FillKeTabRecNf(2, 'AX_STYLE', KeyTabsA);  // Исполнение оси
    FillKeTabRecNf(3, 'AX_WHEEL', KeyTabsA);  // Колесное крепление
    FillKeTabRecNf(4, 'AX_BRAKE', KeyTabsA);  // Тип тормозной системы
    FillarKeyTabsFromTDT(KeyTabsA, 160, TdtIBS); // вынимаем в KeyTabsA нужные списки TDT
    try
      OpenWorkBookNotVisible(FileName, XL, WorkBook); // открыть файл Excel для импорта
      SheetCount:= WorkBook.Worksheets.Count; //количество листов excel
      ListPercent:= 90/SheetCount;
  //      for i:= 1 to SheetCount do prMessageLOGS(nmProc+': '+(WorkBook.Sheets.Item[i] as Excel_TLB._Worksheet).Name, 'import', False);
      for SheetID:= 1 to SheetCount do try
        WorkSheet:= WorkBook.Sheets.Item[SheetID] as Excel_TLB._Worksheet;
        SheetName:= AnsiUpperCase(WorkSheet.Name);
        if pos('ОПИСАНИЕ', SheetName)>0 then Continue; // пропускаем лист "Описание"
        if pos('ЛИСТ', SheetName)>0 then Continue;     // пропускаем стандартные листы

        GetWorkSheetCounts(WorkSheet, rows, ii); // получить кол-во строк и столбцов на листе
        if rows<2 then Continue;                // переходим к следующему листу
        if ii<15 then // проверяем кол-во столбцов
          raise Exception.Create(MessText(mtkNotEnoughParams)+' - мало столбцов');
        CheckStopExecute(UserID, ThreadData);

        Percent:= ListPercent/rows;
        fAddMl:= False;
        fUpdMl:= False;
        fAddMf:= False;
        fUpdMf:= False;
        mfTD:= 0;
        mfORD:= 0;
        mlTD:= 0;
        mlORD:= 0;
        mORD:= 0;
        iAdd:= 0;
        iErr:= 0;
        iUpd:= 0;
  //     1          2          3         4         5      6      7          8      индекс ячейки
  // ('Опция')+('Произв.')+('М/ряд')+('Модель')+('От')+('До')+('Л/с')+('Марк/двиг')+
  //     9         10        11         12         13         14         15        индекс ячейки
  // ('mf_TD')+('mf_ORD')+('ml_TD')+('ml_ORD')+('mod_TD')+('mod_ORD')+('result')

        for iLine:= 2 to rows do try // считываем строки файла (1-я строка - заголовок)
          CheckStopExecute(UserID, ThreadData);
          SetExecutePercent(UserID, ThreadData, Percent);
  //--------------------------------------------------------- строка производителя
          s:= GetCellStrValue(WorkSheet, CellSigns[2], iLine);
          if (s<>'') then begin
            mfTD:= GetCellIntValue(WorkSheet, CellSigns[9], iLine);  // код TecDoc произв.
            mfORD:= GetCellIntValue(WorkSheet, CellSigns[10], iLine); // ID произв.
            mfName:= s;
            fAddMf:= True;
            fUpdMf:= True;  // оба флага = True - сигнал проверки
            Continue;
          end;
  //-------------------------------------------------------------- строка мод.ряда
          s:= GetCellStrValue(WorkSheet, CellSigns[3], iLine);
          if (s<>'') then begin
            mlTD := GetCellIntValue(WorkSheet, CellSigns[11], iLine); // код TecDoc мод.ряда
            mlORD:= GetCellIntValue(WorkSheet, CellSigns[12], iLine); // ID мод.ряда
            mlName:= fnReplaceQuotedForWeb(s);
            fAddMl:= True;
            fUpdMl:= True;  // оба флага = True - сигнал проверки
            Continue;
          end;
  //---------------------------------------------------------------- строка модели
          s:= GetCellStrValue(WorkSheet, CellSigns[4], iLine);
          if (s='') then Continue;  // если не строка модели - пропускаем

          ss:= GetCellStrValue(WorkSheet, CellSigns[1], iLine);
          if (ss<>'/1') then Continue; // если опция <> "/1" - пропускаем

  //------------------------------------------------------ обработка строки модели
          mTD := GetCellIntValue(WorkSheet, CellSigns[13], iLine); // код TecDoc модели
          mORD:= GetCellIntValue(WorkSheet, CellSigns[14], iLine); // ID модели

          if ((mORD<1) and (mTD<1)) then   // не определена модель
            raise Exception.Create(MessText(mtkNotValidParam)+' - модель');
          if ((mlORD<1) and (mlTD<1)) then // не определен мод.ряд
            raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
          if ((mfORD<1) and (mfTD<1)) then // не определен произв.
            raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');

          mName:= fnReplaceQuotedForWeb(s);
          if fAddMf and fUpdMf then begin // 2 флага = True - сигнал проверки произв.
            if (mfORD<1) then mfORD:= Manufacturers.GetManufIDByTDcode(mfTD);
            fAddMf:= not Manufacturers.ManufExists(mfORD);     // надо добавлять
            if not fAddMf then begin
              manuf:= Manufacturers[mfORD];
              fUpdMf:= not manuf.CheckIsTypeSys(constIsCV); // надо установить признак системы
            end else fUpdMf:= False;
          end;

          if fAddMl and fUpdMl then begin // 2 флага = True - сигнал проверки мод.ряда
            if not fAddMf and (mlORD<1) then
              mlORD:= manuf.GetMfMLineIDByTDcode(mlTD, constIsCV);
            fAddMl:= not ModelLines.ModelLineExists(mlORD);          // надо добавлять
            if not fAddMl then begin
              mline:= ModelLines[mlORD];
              if (mline.TypeSys<>constIsCV) then
                raise Exception.Create('мод.ряд есть в другой системе');
              fUpdMl:= (not mline.IsVisible or (mline.Name<>mlName)); // надо редактировать
            end else fUpdMl:= False;
          end;

          if not fAddMl and (mORD<1) then                    // проверяем модель
            mORD:= mline.GetMLModelIDByTDcode(mTD);
          fAddMod:= (mORD<1) or not Models.ModelExists(mORD);   // надо добавлять
          if not fAddMod then begin
            model:= Models[mORD];
            fUpdMod:= (not model.IsVisible or (model.Name<>mName)); // надо редактировать
          end else fUpdMod:= False;

          if not fAddMod and not fUpdMod then begin
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '/2');
            SetCellStrValue(WorkSheet, CellSigns[15], iLine, ''); // вписываем результат
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - модель уже есть';
            SaveStrToMail(MailStr);
            Continue;
          end;

  //-------------------------------------------------- отрабатываем редактирование
          fVis:= True;
          ss:= '';
          if fUpdMf then begin //--------------- если надо - редактируем произв.
//            fTop:= manuf.CheckIsTop(constIsCV);
            fTop:= False;
            mfName:= manuf.Name;
            s:= Manufacturers.ManufEdit(mfORD, constIsCV, UserID, fTop, fVis, mfName, mfTD);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then s:= 'уст.видим.произв.'
            else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
            fUpdMf:= False;
          end; // отредактировали произв.

          if fUpdMl then begin //--------------- если надо - редактируем мод.ряд
            with mline do begin
              if (mlName='') then mlName:= Name;
              yFrom:= YStart;
              mFrom:= MStart;
              yTo:= YEnd;
              mTo:= MEnd;
              fTop:= IsTop;
            end;
            s:= manuf.ModelLineEdit(mlORD, yFrom, mFrom,
              yTo, mTo, UserID, fTop, fVis, mlName, mlTD);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then s:= 'уст.видим.мод.ряда'
            else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
            fUpdMl:= False;
          end; // отредактировали мод.ряд

          if fUpdMod then with model do begin //------ редактируем модель
            if (Name<>mName) then
              s:= ModelEdit(mName, fVis, IsTop, UserID, Params)
            else s:= SetModelVisible(fVis);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then begin
              s:= 'устан.видим.модели';
              inc(iUpd);
            end else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;

  //------------------------------------------------------ отрабатываем добавление
          end else if fAddMod then try
            with TdtIBS.Transaction do if not InTransaction then StartTransaction;
            if TdtIBS.SQL.Text='' then
              TdtIBS.SQL.Text:= 'select CPT_MS_ID, CPT_MS_DESCR, CPT_DESCR, MS_MF_ID,'+
                ' iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR,'+
                ' MS_FROM, MS_TO, CPT_FROM, CPT_TO, CPT_KW_FROM, CPT_KW_TO,'+
                ' CPT_HP_FROM, CPT_HP_TO, CPT_CC_TEC, CPT_TONNAGE,'+
                ' (select list(CCT_DESC) from (select distinct CCT_DESC from CV_SECONDARY_TYPES'+
                '   where CCT_CPT_ID=CPT_ID order by CCT_SUBNR)) sect,'+       // Второстепенные типы
                ' (select list(w) from (select (ke_descr||"/"||LWCT_WBASE) w'+
                '  from (select distinct ke_descr,LWCT_WBASE from link_Wheel_CV_types'+
                '  left join KEY_ENTRIES on ke_kt_id=64 and cast(ke_key as integer)=LWCT_APOS'+
                '   where LWCT_CPT_ID=CPT_ID order by LWCT_LFD_NR))) wheel,'+  // Колесная база
                ' (select list(cpi_num) from (select distinct cpi_num'+
                '   from link_IDs_CV_types left join CV_Producer_IDs'+
                '   on cpi_id=lict_prod_id where lict_cpt_id=CPT_ID)) ids,'+   // ID производителя
                ' (select list(cdc_descr) from (select distinct cdc_descr'+
                '   from link_Cabs_CV_types left join CV_Driver_Cabs'+
                '   on cdc_id=ldcct_cdc_id where ldcct_cpt_id=CPT_ID)) cabs,'+ // Кабина
                ' (select list(ac.ke_descr||"/"||ss.ke_descr) from (select distinct'+ // Подвеска/амортизация
                '  lsct_apos,lsct_susp from link_Susp_CV_types ls where ls.lsct_cpt_id=CPT_ID)'+
                '  left join KEY_ENTRIES ac on ac.ke_kt_id=64 and cast(ac.ke_key as integer)=lsct_apos'+
                '  left join KEY_ENTRIES ss on ss.ke_kt_id=66 and cast(ss.ke_key as integer)=lsct_susp) susps,'+
                ' (select key_to from get_key_code (532, CPT_BT, "CPT_BT")) CPT_BT,'+    // Конструкция
                ' (select key_to from get_key_code (532, CPT_AC, "CPT_AC")) CPT_AC,'+    // Конфигурация оси
                ' (select key_to from get_key_code (532, CPT_ENG, "CPT_ENG")) CPT_ENG'+  // Тип двигателя
                ' from CV_PRIMARY_TYPES left join MODEL_SERIES on MS_ID=CPT_MS_ID'+
                ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+
                ' where CPT_ID=:mt';
            TdtIBS.ParamByName('mt').AsInteger:= mTD;
            TdtIBS.ExecQuery;
            if (TdtIBS.Bof and TdtIBS.Eof) then
              raise Exception.Create(MessText(mtkNotValidParam)+' - модель TD');
            if (mfTD<>TdtIBS.fieldByName('MS_MF_ID').AsInteger) then
              raise Exception.Create(MessText(mtkNotValidParam)+' - произв. TD');
            if (mlTD<>TdtIBS.fieldByName('CPT_MS_ID').AsInteger) then
              raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд TD');

            if fAddMf then begin //--------------- если надо - добавляем произв.
              mfName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MF_DESCR').AsString);  // наимен. произв.
              fTop:= False;
              s:= Manufacturers.ManufAdd(mfORD, mfName, constIsCV, UserID, fTop, fVis, mfTD);
              if (s=MessText(mtkNotParams)) then s:= ''
              else if (s='') then s:= 'доб.произв.'
              else raise Exception.Create(s);
              if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
              fAddMf:= False;
              if (mfORD<1) then // не определен ID произв.
                raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');
              manuf:= Manufacturers[mfORD];
            end; // добавили произв.

            if fAddMl then begin //--------------- если надо - добавляем мод.ряд
              if mlName='' then                             // наимен. мод.ряда
                mlName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('CPT_MS_DESCR').AsString);
              tdFrom := TdtIBS.fieldByName('MS_FROM').AsInteger;        // от
              tdTo:= TdtIBS.fieldByName('MS_TO').AsInteger;             // до
                               // разделить год и месяц начала/окончания выпуска
              GetYMfromTDfromto(tdFrom, tdTo, yFrom, mFrom, yTo, mTo);
//              if (tdFrom>0) then yFrom:= tdFrom div 100 else yFrom:= 0; // Год начала выпуска
//              if (yFrom>0)  then mFrom:= tdFrom mod 100 else mFrom:= 0; // Месяц начала выпуска
//              if (tdTo>0)   then yTo  := tdTo   div 100 else yTo:= 0;   // Год конца выпуска
//              if (yTo>0)    then mTo  := tdTo   mod 100 else mTo:= 0;   // Месяц конца выпуска
              fTop:= False;
              s:= manuf.ModelLineAdd(mlORD, mlName, constIsCV,
                mFrom, yFrom, mTo, yTo, UserID, fTop, fVis, mlTD);
              if (s=MessText(mtkNotParams)) then s:= ''
              else if (s='') then s:= 'доб.мод.ряд'
              else raise Exception.Create(s);
              if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
              fAddMl:= False;
              if (mlORD<1) then // не определен ID мод.ряда
                raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
//              mline:= ModelLines[mlORD];
            end; // добавили мод.ряд

            if (mName='') then   //---------------------- добавляем новую модель
              mName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('CPT_DESCR').AsString); // наимен. модели TecDoc
            tdFrom := TdtIBS.fieldByName('CPT_FROM').AsInteger; // от
            tdTo:= TdtIBS.fieldByName('CPT_TO').AsInteger;      // до
                             // разделить год и месяц начала/окончания выпуска
            GetYMfromTDfromto(tdFrom, tdTo, arMpsORD[1], arMpsORD[0], arMpsORD[3], arMpsORD[2]);
//            if (tdFrom>0)      then arMpsORD[1]:= tdFrom div 100 else arMpsORD[1]:= 0; // Год начала выпуска
//            if (arMpsORD[1]>0) then arMpsORD[0]:= tdFrom mod 100 else arMpsORD[0]:= 0; // Месяц начала выпуска
//            if (tdTo>0)        then arMpsORD[3]:= tdTo   div 100 else arMpsORD[3]:= 0; // Год конца выпуска
//            if (arMpsORD[3]>0) then arMpsORD[2]:= tdTo   mod 100 else arMpsORD[2]:= 0; // Месяц конца выпуска

            for ii:= 4 to 5 do arMpsORD[ii]:= 0;
            arMpsORD[6]:= TdtIBS.FieldByName('CPT_CC_TEC').AsInteger; // Тех. объем куб. см.
            arMpsORD[7]:= 0;
            arMpsORD[8]:= TdtIBS.FieldByName('CPT_TONNAGE').AsInteger; // Тоннаж * 100
            for ii:= Low(KeyTabs) to High(KeyTabs) do arMpsORD[ii+9]:=  // Конструкция .. Тип двигателя
              GetInfoCode(TdtIBS.FieldByName(KeyTabs[ii].FieldNameTDT).AsInteger, UserID, KeyTabs[ii]);
            for ii:= (Length(KeyTabs)+9) to High(arMpsORD) do arMpsORD[ii]:= 0;

            MakeMpsFromArray(arMpsORD, mps);
            fTop:= False;                                // Мощность ЛС от-до
            tdFrom:= TdtIBS.fieldByName('CPT_HP_FROM').AsInteger; // Мощность ЛС от
            tdTo:= TdtIBS.fieldByName('CPT_HP_TO').AsInteger;     // Мощность ЛС до
            mps.cvHPaxLO:= '';
            if (tdFrom>0) then mps.cvHPaxLO:= IntToStr(tdFrom);
            if (tdTo>0) then
              mps.cvHPaxLO:= mps.cvHPaxLO+fnIfStr(mps.cvHPaxLO<>'', '-', '')+IntToStr(tdTo);
                                                        // Мощность кВт от-до
            tdFrom:= TdtIBS.fieldByName('CPT_KW_FROM').AsInteger; // Мощность кВт от
            tdTo:= TdtIBS.fieldByName('CPT_KW_TO').AsInteger;     // Мощность кВт до
            mps.cvKWaxDI:= '';
            if (tdFrom>0) then mps.cvKWaxDI:= IntToStr(tdFrom);
            if (tdTo>0) then
              mps.cvKWaxDI:= mps.cvKWaxDI+fnIfStr(mps.cvKWaxDI<>'', '-', '')+IntToStr(tdTo);
                                                        // Второстепенные типы
            mps.cvSecTypes:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('sect').AsString);
            mps.cvWheels:= TdtIBS.fieldByName('wheel').AsString; // Колесная база [поз.осей]/[мм]
            mps.cvIDaxBT:= TdtIBS.fieldByName('ids').AsString;   // ID производителя
            mps.cvCabs:= TdtIBS.fieldByName('cabs').AsString;    // Кабина

            mps.cvSUAxBR:= '';   // Подвеска/амортизация (список кодов TYPEDIR=ctCVSusp)
            s:= TdtIBS.fieldByName('susps').AsString;
            if (s<>'') then with fnSplit(',', s) do try
              for yTo:= 0 to Count-1 do begin
                s:= Strings[yTo];
                tdTo:= pos('/', s);
                if (tdTo>0) then
                  s:= copy(s, 1, tdTo)+LowerCase(copy(s, tdTo+1, 1))+copy(s, tdTo+2, length(s));
                tdTo:= 0; // здесь используется как код значения
                with Cache.FDCA.TypesInfoModel do // ищем код элемента в кеше по значению
                  if not FindInfoItemByValue(tdTo, cvtSusp, s) then begin
                    tdFrom:= cvtSusp; // здесь нужно из-за типов параметров функции
                    // добавляем новoe значение в кеш и в базу
                    s:= AddInfoModelItem(tdTo, tdFrom, 0, 0, s, UserID);
                    if (s<>'') then raise Exception.Create('AddInfoModelItem error: '+s);
                  end;
                if (tdTo>0) then
                  mps.cvSUAxBR:= mps.cvSUAxBR+fnIfStr(mps.cvSUAxBR='', '', ',')+IntToStr(tdTo);
              end; // for yTo:= 0 to Count-1
            finally Free; end;

            GetEngMarks(mTD, constIsCV, UserID, marks, TdtIBSm); // маркировки двигателей

            s:= Models.ModelAdd(mORD, mName, fVis, fTop, UserID, mlORD, mps, -1, mTD, marks);

            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then begin
              s:= 'доб.модель';
              inc(iAdd);
              sleep(10);
            end else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
                                                     // связи грузовика с осями
            mps.cvAxles:= GetCVaxlesFromTDT(mORD, mTD, UserID, KeyTabsA, TdtIBSl, TdtIBSa, ordIBS);

          finally
            TdtIBS.Close;
          end; // if fAddMod

          if (GetCellStrValue(WorkSheet, CellSigns[1], iLine)='/1') then  // если опция = "/1" - заменяем на '/2'
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '/2');
          if (GetCellIntValue(WorkSheet, CellSigns[14], iLine)=0) and (mORD>0) then // если добавили модель
            SetCellIntValue(WorkSheet, CellSigns[14], iLine, mORD);            // вписываем код модели
          if ss<>'' then SetCellStrValue(WorkSheet, CellSigns[15], iLine, ss); // вписываем результат
        except
          on E: EBOBError do begin
            if (E.Message<>'') or (ss<>'') then
              SetCellStrValue(WorkSheet, CellSigns[15], iLine, fnIfStr(ss='', '', ss+', ')+E.Message); // вписываем сообщение
            raise EBOBError.Create('строка '+IntToStr(iLine)+' - '+E.Message);
          end;
          on E: Exception do begin
            inc(iErr);
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - '+E.Message;
            SaveStrToMail(MailStr);
            prMessageLOGS(nmProc+': '+MailStr, 'import', False);
            if (E.Message<>'') or (ss<>'') then
              SetCellStrValue(WorkSheet, CellSigns[15], iLine, fnIfStr(ss='', '', ss+', ')+E.Message); // вписываем сообщение
          end;
        end; // for iLine:= 2 to rows

        try                           //--------------------------- итоги по листу
          iLine:= rows+1;
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, '----------------------');
          inc(iLine);
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'обработано:   '+IntToStr(iLine)+' строк');
          inc(iLine);
          if iAdd>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'добавлено :   '+IntToStr(iAdd)+' моделей');
            inc(iLine);
          end;
          if iUpd>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'уст.видим.:   '+IntToStr(iUpd)+' моделей');
            inc(iLine);
          end;
          if iErr>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'ошибки    :   '+IntToStr(iErr)+' строк');
            SaveStrToMail('лист ['+WorkSheet.Name+'] - '+IntToStr(iErr)+' ошибок');
            inc(iLine);
          end;
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, '----------------------');
        except
          on E: Exception do
            prMessageLOGS(nmProc+': ошибка в итогах на листе ['+WorkSheet.Name+'] '+E.Message, 'import', False);
        end;
       CheckStopExecute(UserID, ThreadData);
       SetExecutePercent(UserID, ThreadData, Percent);
      except
        on E: EBOBError do raise Exception.Create('лист ['+WorkSheet.Name+']: '+E.Message);
        on E: Exception do begin
          MailStr:= 'лист ['+WorkSheet.Name+'] - '+E.Message;
          SaveStrToMail(MailStr);
          prMessageLOGS(nmProc+': '+MailStr, 'import', False);
        end;
      end; // for SheetID:= 1 to SheetCount
    finally
      SaveAndCloseWorkBook(XL, WorkBook);
    end;
  except
    on E: Exception do begin
      SaveStrToMail(E.Message);
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import', False);
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    prFreeIBSQL(TdtIBSm);
    prFreeIBSQL(TdtIBSa);
    prFreeIBSQL(TdtIBSl);
    cntsTDT.SetFreeCnt(TdtIBD, True);
    prFreeIBSQL(ordIBS);
    cntsORD.SetFreeCnt(ordIBD, True);
    ClearArKeyTabs(KeyTabs);
    ClearArKeyTabs(KeyTabsA);
    prFreeAndNilStrListWithObj(marks);
    prFree(mps);
    if (iMail>0) then BodyMail.Add(' ');
  end;
end;
//================================================= загрузка 1 модели оси из TDT
function prAddNewAxleFromTDT(var mORD: integer; UserID, mTD, mlORD: integer;
         var TdtIBS: TIBSQL; var KeyTabs: TarKeyTabs; fVis, fTop: Boolean; mName: string=''): string;
const nmProc = 'prAddNewAxleFromTDT'; // имя процедуры/функции
var ii, tdFrom, tdTo, k: integer;
    s, s1, s2: string;
    arMpsORD: TarMps;
    mps: TModelParams;
begin
  Result:= '';
  mps:= nil;
  with Cache.FDCA do try try
    if (mTD<1) then               // не определена модель
      raise Exception.Create(MessText(mtkNotValidParam)+' - модель');
    if (mlORD<1) then             // не определен мод.ряд
      raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');

    TdtIBS.Close;
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    if (TdtIBS.SQL.Text='') then
      TdtIBS.SQL.Text:= 'select AX_DESC, AX_FROM, AX_TO, AX_LO_FROM, AX_LO_TO,'+
        ' AX_DI_FROM, AX_DI_TO, AX_TR_WIDTH, AX_HUB,'+
        ' (select list(LABT_DESC) from (select distinct LABT_DESC'+
        '  from LINK_AXLES_BOTYPES where LABT_AX_ID=AX_ID)) bots,'+  // Тип модели
        ' (select list(trim(ac.ke_descr||"~"||LABS_DESC),"@") from'+
        '  (select distinct LABS_BSIZE,LABS_DESC from LINK_AXLES_BRSIZES'+
        '   where LABS_AX_ID=AX_ID) left join KEY_ENTRIES ac on ac.ke_kt_id=216'+
        '   and cast(ac.ke_key as integer)=LABS_BSIZE) brsize,'+     // Размеры тормоза
        ' (select key_to from get_key_code (160, AX_TYPE, "AX_TYPE")) AX_TYPE,'+    // Тип оси
        ' (select key_to from get_key_code (160, AX_BODY, "AX_BODY")) AX_BODY,'+    // Балка моста
        ' (select key_to from get_key_code (160, AX_STYLE, "AX_STYLE")) AX_STYLE,'+ // Исполнение оси
        ' (select key_to from get_key_code (160, AX_BRAKE, "AX_BRAKE")) AX_BRAKE,'+ // Тип тормозной системы
        ' (select key_to from get_key_code (160, AX_WHEEL, "AX_WHEEL")) AX_WHEEL'+  // Колесное крепление
        ' from AXLES where AX_ID=:mt';
    TdtIBS.ParamByName('mt').AsInteger:= mTD;
    TdtIBS.ExecQuery;
    if (TdtIBS.Bof and TdtIBS.Eof) then
      raise Exception.Create(MessText(mtkNotValidParam)+' - модель TD');

    if (mName='') then   //---------------------- добавляем новую модель
      mName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('AX_DESC').AsString);  // наимен. модели TecDoc
    tdFrom := TdtIBS.fieldByName('AX_FROM').AsInteger; // от
    tdTo:= TdtIBS.fieldByName('AX_TO').AsInteger;      // до
                             // разделить год и месяц начала/окончания выпуска
    GetYMfromTDfromto(tdFrom, tdTo, arMpsORD[1], arMpsORD[0], arMpsORD[3], arMpsORD[2]);
    for ii:= 4 to 5 do arMpsORD[ii]:= 0;
    arMpsORD[6]:= TdtIBS.FieldByName('AX_TR_WIDTH').AsInteger; // Ширина колеи [мм]  pCCM
    for ii:= 7 to 8 do arMpsORD[ii]:= 0;
    for ii:= 0 to 3 do arMpsORD[ii+9]:=  // Балка моста .. Колесное крепление  pBodyID...pFuelID
      GetInfoCode(TdtIBS.FieldByName(KeyTabs[ii].FieldNameTDT).AsInteger, UserID, KeyTabs[ii]);
    arMpsORD[13]:= 0;
    try                          // Тип тормозной системы  pBrakeID
      tdTo:= TdtIBS.FieldByName(KeyTabs[4].FieldNameTDT).AsInteger;
      arMpsORD[14]:= GetInfoCode(tdTo, UserID, KeyTabs[4]);
    except
      on E: Exception do begin
        arMpsORD[14]:= 0;
        prMessageLOGS(nmProc+': mTD='+IntToStr(mTD)+', AX_BRAKE='+IntToStr(tdTo)+': '+E.Message, 'import', False);
      end;
    end;
    for ii:= 15 to 16 do arMpsORD[ii]:= 0;

    s:= TdtIBS.fieldByName('AX_HUB').AsString;  // Hub system pTransID
    tdTo:= 0; // здесь используется как код значения
    if (s<>'') then with Cache.FDCA.TypesInfoModel do // ищем код элемента в кеше по значению
      if not FindInfoItemByValue(tdTo, axtHub, s) then begin
        tdFrom:= axtHub; // здесь нужно из-за типов параметров функции
        // добавляем новoe значение в кеш и в базу
        s:= AddInfoModelItem(tdTo, tdFrom, 0, 0, s, UserID);
        if (s<>'') then raise Exception.Create('AddInfoModelItem error: '+s);
      end;
    arMpsORD[17]:= tdTo;

    MakeMpsFromArray(arMpsORD, mps);
    tdFrom:= TdtIBS.fieldByName('AX_LO_FROM').AsInteger; // Нагрузка[кг] от
    tdTo:= TdtIBS.fieldByName('AX_LO_TO').AsInteger;     // Нагрузка[кг] до
    mps.cvHPaxLO:= '';
    if (tdFrom>0) then mps.cvHPaxLO:= IntToStr(tdFrom);
    if (tdTo>0) then                            // Нагрузка[кг] от-до
      mps.cvHPaxLO:= mps.cvHPaxLO+fnIfStr(mps.cvHPaxLO<>'', '-', '')+IntToStr(tdTo);
    tdFrom:= TdtIBS.fieldByName('AX_DI_FROM').AsInteger; // Дистанция[мм] от
    tdTo:= TdtIBS.fieldByName('AX_DI_TO').AsInteger;     // Дистанция[мм] до
    mps.cvKWaxDI:= '';
    if (tdFrom>0) then mps.cvKWaxDI:= IntToStr(tdFrom);
    if (tdTo>0) then                            // Дистанция[мм] от-до
      mps.cvKWaxDI:= mps.cvKWaxDI+fnIfStr(mps.cvKWaxDI<>'', '-', '')+IntToStr(tdTo);
    mps.cvIDaxBT:= TdtIBS.fieldByName('bots').AsString; // Тип модели
    mps.cvSUAxBR:= '';                                  // Размеры тормоза
    s:= TdtIBS.fieldByName('brsize').AsString;
    if (s<>'') then with fnSplit('@', s) do try
      for k:= 0 to Count-1 do begin
        s:= Strings[k];
        tdTo:= pos('~', s);
        if (tdTo>0) then begin
          s1:= trim(copy(s, 1, tdTo-1));
          s2:= trim(copy(s, tdTo+1, length(s)));
        end else begin
          s1:= trim(s);
          s2:= '';
        end;
        if (s1='0') then s1:= ''
        else if (s1<>'') then begin
          s1:= StringReplace(s1, '"', '``', [rfReplaceAll]);
          s1:= StringReplace(s1, '''''', '``', [rfReplaceAll]);
//          s1:= StringReplace(s1, '"', 'дюйм', [rfReplaceAll]);
//          s1:= StringReplace(s1, '''''', 'дюйм', [rfReplaceAll]);
        end;
        s:= s1+fnIfStr((s1<>'') and (s2<>''), ' ', '')+s2;
        if (s<>'') then begin
          tdTo:= 0; // здесь используется как код значения
          with Cache.FDCA.TypesInfoModel do // ищем код элемента в кеше по значению
            if not FindInfoItemByValue(tdTo, axtBrSize, s) then begin
              tdFrom:= axtBrSize; // здесь нужно из-за типов параметров функции
              // добавляем новoe значение в кеш и в базу
              s:= AddInfoModelItem(tdTo, tdFrom, 0, 0, s, UserID);
              if (s<>'') then raise Exception.Create('AddInfoModelItem error: '+s);
            end;
          if (tdTo>0) then
            mps.cvSUAxBR:= mps.cvSUAxBR+fnIfStr(mps.cvSUAxBR='', '', ',')+IntToStr(tdTo);
        end;
      end; // for yTo:= 0 to Count-1
    finally Free; end;

    Result:= Models.ModelAdd(mORD, mName, fVis, fTop, UserID, mlORD, mps, -1, mTD);
  except
    on E: Exception do Result:= E.Message;
  end; // with Cache.FDCA
  finally
    TdtIBS.Close;
    prFree(mps);
  end;
end;
//====================================================== связи грузовика с осями
function GetCVaxlesFromTDT(mCVord, mCVTD, UserID: integer; var KeyTabs: TarKeyTabs;
                           var TdtIBSl, TdtIBSa, ordIBS: TIBSQL): string;
const nmProc = 'GetCVaxlesFromTDT'; // имя процедуры/функции
var mlORD, mlTD, mORD, mTD, mfORD, mfTD, tdFrom, tdTo, mFrom, yFrom, mTo, yTo: integer;
    fVis, fTop, fAddMf, fAddMl, fUpdMf, fUpdMl, fAddMod, fUpdMod: Boolean;
    mName, mlName, mfName, s: string;
    manuf: TManufacturer;
    mline: TModelLine;
    model: TModelAuto;
begin
  Result:= '';
  fAddMl:= False;
  fUpdMl:= False;
  fAddMf:= False;
  fUpdMf:= False;
  fAddMod:= False;
  fUpdMod:= False;
  mfORD:= 0;
  mlORD:= 0;
  mORD:= 0;
  fTop:= False;
  fVis:= True;
  manuf:= nil;
  mline:= nil;
  with Cache.FDCA do try try
    TdtIBSl.Close;
    with TdtIBSl.Transaction do if not InTransaction then StartTransaction;
    if (TdtIBSl.SQL.Text='') then
      TdtIBSl.SQL.Text:= 'select AX_ID, LACT_APOS, ac.ke_descr,'+
        ' MS_ID, MS_DESCR, MS_FROM, MS_TO, MS_MF_ID,'+
        ' iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR'+
        ' from LINK_AXLES_CV_TYPES left join AXLES on AX_ID=LACT_AX_ID and AX_DEL=0'+
        ' left join MODEL_SERIES on MS_ID=AX_MS_ID and MS_AXL=1'+
        ' left join KEY_ENTRIES ac on ac.ke_kt_id=64 and cast(ac.ke_key as integer)=LACT_APOS'+
        ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+
        ' where LACT_CPT_ID=:mt and MS_ID is not null order by MS_MF_ID, MS_ID';
    TdtIBSl.ParamByName('mt').AsInteger:= mCVTD;
    TdtIBSl.ExecQuery;
    if (TdtIBSl.Bof and TdtIBSl.Eof) then Exit;  // нет осей
//      raise Exception.Create(MessText(mtkNotValidParam)+' - модель mCVTD');
    while not TdtIBSl.Eof do begin
      mfTD:= TdtIBSl.fieldByName('MS_MF_ID').AsInteger;
      mfName:= TdtIBSl.fieldByName('MF_DESCR').AsString;  // наимен. произв.
      mfORD:= Manufacturers.GetManufIDByTDcode(mfTD);
      try
      //------------------------------------------------- проверка производителя
        if (mfORD<1) or not Manufacturers.ManufExists(mfORD) then begin // надо добавлять
          s:= Manufacturers.ManufAdd(mfORD, mfName, constIsAx, UserID, fTop, fVis, mfTD);
          if (s<>'') and (s<>MessText(mtkNotParams)) then raise Exception.Create(s);
          if (mfORD<1) then // не определен ID произв.
            raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');
          manuf:= Manufacturers[mfORD];
        end else begin
          manuf:= Manufacturers[mfORD];
          if not manuf.CheckIsTypeSys(constIsAx) then begin // надо установить признак системы
            mfName:= manuf.Name;
            s:= Manufacturers.ManufEdit(mfORD, constIsAx, UserID, fTop, fVis, mfName, mfTD);
            if (s<>'') and (s<>MessText(mtkNotParams)) then raise Exception.Create(s);
          end;
        end;
      except
        on E: Exception do begin
          prMessageLOGS(nmProc+': mfTD='+IntToStr(mfTD)+': '+E.Message, 'import', False);
          TestCssStopException;
          while not TdtIBSl.Eof and (mfTD=TdtIBSl.fieldByName('MS_MF_ID').AsInteger) do TdtIBSl.Next;
          Continue;
        end;
      end;

      while not TdtIBSl.Eof and (mfTD=TdtIBSl.fieldByName('MS_MF_ID').AsInteger) do begin
        mlTD:= TdtIBSl.fieldByName('MS_ID').AsInteger;
        mlName:= fnReplaceQuotedForWeb(TdtIBSl.fieldByName('MS_DESCR').AsString);   // наимен. мод.ряда
        tdFrom:= TdtIBSl.fieldByName('MS_FROM').AsInteger;     // от
        tdTo  := TdtIBSl.fieldByName('MS_TO').AsInteger;       // до
        try
        //---------------------------------------------------- проверка мод.ряда
          mlORD:= manuf.GetMfMLineIDByTDcode(mlTD, constIsAx);
          if (mlORD<1) or not ModelLines.ModelLineExists(mlORD) then begin // надо добавлять
                             // разделить год и месяц начала/окончания выпуска
            GetYMfromTDfromto(tdFrom, tdTo, yFrom, mFrom, yTo, mTo);
            s:= manuf.ModelLineAdd(mlORD, mlName, constIsAx,
              mFrom, yFrom, mTo, yTo, UserID, fTop, fVis, mlTD);
            if (s<>'') and (s<>MessText(mtkNotParams)) then raise Exception.Create(s);
            if (mlORD<1) then // не определен ID мод.ряда
              raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
            mline:= ModelLines[mlORD];
          end else begin
            mline:= ModelLines[mlORD];
            if (mline.TypeSys<>constIsAx) then
              raise Exception.Create('мод.ряд есть в другой системе');
            if not mline.IsVisible then begin // надо редактировать
              with mline do begin
                mlName:= Name;
                yFrom:= YStart;
                mFrom:= MStart;
                yTo:= YEnd;
                mTo:= MEnd;
                fTop:= IsTop;
              end;
              s:= manuf.ModelLineEdit(mlORD, yFrom, mFrom, yTo, mTo, UserID, fTop, fVis, mlName, mlTD);
              if (s<>'') and (s<>MessText(mtkNotParams)) then raise Exception.Create(s);
            end;
          end;
        except
          on E: Exception do begin
            prMessageLOGS(nmProc+': mlTD='+IntToStr(mlTD)+': '+E.Message, 'import', False);
            TestCssStopException;
            while not TdtIBSl.Eof and (mlTD=TdtIBSl.fieldByName('MS_ID').AsInteger) do TdtIBSl.Next;
            Continue;
          end;
        end;

        while not TdtIBSl.Eof and (mlTD=TdtIBSl.fieldByName('MS_ID').AsInteger) do begin
          mTD:= TdtIBSl.fieldByName('AX_ID').AsInteger;
          try
          //---------------------------------------------------- проверка модели
            mORD:= mline.GetMLModelIDByTDcode(mTD);
            if (mORD<1) or not Models.ModelExists(mORD) then begin // надо добавлять
              mName:= '';
              s:= prAddNewAxleFromTDT(mORD, UserID, mTD, mlORD, TdtIBSa, KeyTabs, fVis, fTop, mName);
              if (s<>'') and (s<>MessText(mtkNotParams)) then raise Exception.Create(s);
//              model:= Models[mORD];
            end else begin
              model:= Models[mORD];
              if not model.IsVisible then begin // надо редактировать
                s:= model.SetModelVisible(fVis);
                if (s<>'') and (s<>MessText(mtkNotParams)) then raise Exception.Create(s);
              end;
            end;
//--------------------------------------------------------- позиция оси
            mTo:= TdtIBSl.fieldByName('LACT_APOS').AsInteger; // ke_key
            yTo:= 64;   // ke_kt_id
            mFrom:= 0;  // pType
            yFrom:= 0;  // искомый код
            with Cache.FDCA do                // ищем в кеше по кодам TDT
              if not TypesInfoModel.FindInfoItemByTDcodes(yFrom, mFrom, mTo, yTo) then begin
                s:= TdtIBSl.fieldByName('ke_descr').AsString; // наименование нового элемента
                if (s='') then raise Exception.Create('ke_descr - не найдено значение');
                // добавляем новый элемент в кеш и в базу (pType - из FindInfoItemByTDcodes)
                s:= TypesInfoModel.AddInfoModelItem(yFrom, mFrom, mTo, yTo, s, UserID);
                if (s<>'') then raise Exception.Create('ошибка добавления позиции оси');
              end;
            if (yFrom<1) then raise Exception.Create('ошибка добавления позиции оси');
//--------------------------------------------------------- связка
            ordIBS.Close;
            with ordIBS.Transaction do if not InTransaction then StartTransaction;
            if (ordIBS.SQL.Text='') then ordIBS.SQL.Text:= 'insert into LINKCVAxles'+
              ' (lcaDmosCV, lcaDmosAx, lcaAxPos, lcaSRC, lcaUSERID) values ('+
              ' :DmosCV, :DmosAx, :AxPos, '+IntToStr(soTecDocBatch)+', '+IntToStr(UserID)+')';
            ordIBS.ParamByName('DmosCV').AsInteger:= mCVord;
            ordIBS.ParamByName('DmosAx').AsInteger:= mORD;
            ordIBS.ParamByName('AxPos').AsInteger:= yFrom;
            ordIBS.ExecQuery;
            ordIBS.Transaction.Commit;

            Result:= Result+fnIfStr(Result='', '', ',')+IntToStr(yFrom)+'/'+IntToStr(mORD); // строка - список
//---------------------------------------------------------
          except
            on E: Exception do
              prMessageLOGS(nmProc+': mTD='+IntToStr(mTD)+': '+E.Message, 'import', False);
          end;
          TestCssStopException;
          TdtIBSl.Next;
        end; // while not TdtIBS.Eof  and (mlTD=
      end; // while not TdtIBS.Eof and (mfTD=
    end; // while not TdtIBS.Eof
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, 'import', False);
  end; // with Cache.FDCA
  finally
    TdtIBSl.Close;
    TdtIBSa.Close;
    ordIBS.Close;
  end;
end;
//========================= 68-imp - загрузка моделей осей из TDT из файла Excel
procedure prSetNewAxMfMlModFromTDT(UserID: integer; FileName: string;
          var BodyMail: TStringList; ThreadData: TThreadData=nil);
const nmProc = 'prSetNewAxMfMlModFromTDT'; // имя процедуры/функции
var mlORD, mlTD, mORD, mTD, mfORD, mfTD, iAdd, iErr, iUpd, ii, iMail,
      tdFrom, tdTo, mFrom, yFrom, mTo, yTo, iLine, SheetCount, SheetID, rows: integer;
    fVis, fTop, fAddMf, fAddMl, fUpdMf, fUpdMl, fAddMod, fUpdMod: Boolean;
    mName, mlName, mfName, ss, s, SheetName, MailStr: string;
    TdtIBD: TIBDatabase;
    TdtIBS, TdtIBSm: TIBSQL;
    KeyTabs: TarKeyTabs; // Tai: индекс - код TDT, значение - код ORD
    Percent, ListPercent: real;
    XL: TExcelApplication;
    WorkBook: Excel_TLB._Workbook;
    WorkSheet: Excel_TLB._Worksheet;
    manuf: TManufacturer;
    mline: TModelLine;
    model: TModelAuto;
    //--------------------------------------------
    procedure SaveStrToMail(str: String);
    begin
      if not Assigned(BodyMail) then BodyMail:= TStringList.Create;
      if (iMail<1) then BodyMail.Add(' ');
      BodyMail.Add(str);
      inc(iMail);
    end;
    //--------------------------------------------
begin
  TdtIBS:= nil;
  TdtIBSm:= nil;
  TdtIBD:= nil;
  XL:= nil;
  WorkBook:= nil;
  manuf:= nil;
  mline:= nil;
  model:= nil;
  SetLength(KeyTabs, 0);
  SetExecutePercent(UserID, ThreadData, 1);
  iMail:= 0;
  with Cache.FDCA do try try
    TdtIBD:= cntsTDT.GetFreeCnt('', '', '', True);
    TdtIBSm:= fnCreateNewIBSQL(TdtIBD, 'TdtIBSm_'+nmProc, -1, tpRead); // для моделей
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead);

    SetLength(KeyTabs, 5);
    FillKeTabRecNf(0, 'AX_BODY', KeyTabs);   // Балка моста
    FillKeTabRecNf(1, 'AX_TYPE', KeyTabs);   // Тип оси
    FillKeTabRecNf(2, 'AX_STYLE', KeyTabs);  // Исполнение оси
    FillKeTabRecNf(3, 'AX_WHEEL', KeyTabs);  // Колесное крепление
    FillKeTabRecNf(4, 'AX_BRAKE', KeyTabs);  // Тип тормозной системы
    FillarKeyTabsFromTDT(KeyTabs, 160, TdtIBS); // вынимаем в KeyTabs нужные списки TDT
    try
      OpenWorkBookNotVisible(FileName, XL, WorkBook); // открыть файл Excel для импорта
      SheetCount:= WorkBook.Worksheets.Count; //количество листов excel
      ListPercent:= 90/SheetCount;
  //      for i:= 1 to SheetCount do prMessageLOGS(nmProc+': '+(WorkBook.Sheets.Item[i] as Excel_TLB._Worksheet).Name, 'import', False);
      for SheetID:= 1 to SheetCount do try
        WorkSheet:= WorkBook.Sheets.Item[SheetID] as Excel_TLB._Worksheet;
        SheetName:= AnsiUpperCase(WorkSheet.Name);
        if pos('ОПИСАНИЕ', SheetName)>0 then Continue; // пропускаем лист "Описание"
        if pos('ЛИСТ', SheetName)>0 then Continue;     // пропускаем стандартные листы

        GetWorkSheetCounts(WorkSheet, rows, ii); // получить кол-во строк и столбцов на листе
        if (rows<2) then Continue;                // переходим к следующему листу
        if (ii<15) then // проверяем кол-во столбцов
          raise Exception.Create(MessText(mtkNotEnoughParams)+' - мало столбцов');
        CheckStopExecute(UserID, ThreadData);

        Percent:= ListPercent/rows;
        fAddMl:= False;
        fUpdMl:= False;
        fAddMf:= False;
        fUpdMf:= False;
        mfTD:= 0;
        mfORD:= 0;
        mlTD:= 0;
        mlORD:= 0;
        mORD:= 0;
        iAdd:= 0;
        iErr:= 0;
        iUpd:= 0;
  //     1          2          3         4         5      6           7            8      индекс ячейки
  // ('Опция')+('Произв.')+('М/ряд')+('Модель')+('От')+('До')+('Нагрузка[кг]')+('Тип оси')+
  //     9         10        11         12         13         14         15        индекс ячейки
  // ('mf_TD')+('mf_ORD')+('ml_TD')+('ml_ORD')+('mod_TD')+('mod_ORD')+('result')

        for iLine:= 2 to rows do try // считываем строки файла (1-я строка - заголовок)
          CheckStopExecute(UserID, ThreadData);
          SetExecutePercent(UserID, ThreadData, Percent);
//--------------------------------------------------------- строка производителя
          s:= GetCellStrValue(WorkSheet, CellSigns[2], iLine);
          if (s<>'') then begin
            mfTD:= GetCellIntValue(WorkSheet, CellSigns[9], iLine);  // код TecDoc произв.
            mfORD:= GetCellIntValue(WorkSheet, CellSigns[10], iLine); // ID произв.
            mfName:= s;
            fAddMf:= True;
            fUpdMf:= True;  // оба флага = True - сигнал проверки
            Continue;
          end;
//-------------------------------------------------------------- строка мод.ряда
          s:= GetCellStrValue(WorkSheet, CellSigns[3], iLine);
          if (s<>'') then begin
            mlTD := GetCellIntValue(WorkSheet, CellSigns[11], iLine); // код TecDoc мод.ряда
            mlORD:= GetCellIntValue(WorkSheet, CellSigns[12], iLine); // ID мод.ряда
            mlName:= fnReplaceQuotedForWeb(s);
            fAddMl:= True;
            fUpdMl:= True;  // оба флага = True - сигнал проверки
            Continue;
          end;
//---------------------------------------------------------------- строка модели
          s:= GetCellStrValue(WorkSheet, CellSigns[4], iLine);
          if (s='') then Continue;  // если не строка модели - пропускаем

          ss:= GetCellStrValue(WorkSheet, CellSigns[1], iLine);
          if (ss<>'/1') then Continue; // если опция <> "/1" - пропускаем

//------------------------------------------------------ обработка строки модели
          mTD := GetCellIntValue(WorkSheet, CellSigns[13], iLine); // код TecDoc модели
          mORD:= GetCellIntValue(WorkSheet, CellSigns[14], iLine); // ID модели

          if ((mORD<1) and (mTD<1)) then   // не определена модель
            raise Exception.Create(MessText(mtkNotValidParam)+' - модель');
          if ((mlORD<1) and (mlTD<1)) then // не определен мод.ряд
            raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
          if ((mfORD<1) and (mfTD<1)) then // не определен произв.
            raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');

          mName:= fnReplaceQuotedForWeb(s);
          if fAddMf and fUpdMf then begin // 2 флага = True - сигнал проверки произв.
            if (mfORD<1) then mfORD:= Manufacturers.GetManufIDByTDcode(mfTD);
            fAddMf:= not Manufacturers.ManufExists(mfORD);     // надо добавлять
            if not fAddMf then begin
              manuf:= Manufacturers[mfORD];
              fUpdMf:= not manuf.CheckIsTypeSys(constIsAx); // надо установить признак системы
            end else fUpdMf:= False;
          end;

          if fAddMl and fUpdMl then begin // 2 флага = True - сигнал проверки мод.ряда
            if not fAddMf and (mlORD<1) then
              mlORD:= manuf.GetMfMLineIDByTDcode(mlTD, constIsAx);
            fAddMl:= not ModelLines.ModelLineExists(mlORD);          // надо добавлять
            if not fAddMl then begin
              mline:= ModelLines[mlORD];
              if (mline.TypeSys<>constIsAx) then
                raise Exception.Create('мод.ряд есть в другой системе');
              fUpdMl:= (not mline.IsVisible or (mline.Name<>mlName)); // надо редактировать
            end else fUpdMl:= False;
          end;

          if not fAddMl and (mORD<1) then                    // проверяем модель
            mORD:= mline.GetMLModelIDByTDcode(mTD);
          fAddMod:= (mORD<1) or not Models.ModelExists(mORD);   // надо добавлять
          if not fAddMod then begin
            model:= Models[mORD];
            fUpdMod:= (not model.IsVisible or (model.Name<>mName)); // надо редактировать
          end else fUpdMod:= False;

          if not fAddMod and not fUpdMod then begin
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '/2');
            SetCellStrValue(WorkSheet, CellSigns[15], iLine, ''); // вписываем результат
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - модель уже есть';
            SaveStrToMail(MailStr);
            Continue;
          end;

//-------------------------------------------------- отрабатываем редактирование
          fVis:= True;
          ss:= '';
          if fUpdMf then begin //--------------- если надо - редактируем произв.
            mfName:= manuf.Name;
            fTop:= False;
            s:= Manufacturers.ManufEdit(mfORD, constIsAx, UserID, fTop, fVis, mfName, mfTD);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then s:= 'уст.видим.произв.'
            else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
            fUpdMf:= False;
          end; // отредактировали произв.

          if fUpdMl then begin //--------------- если надо - редактируем мод.ряд
            with mline do begin
              if (mlName='') then mlName:= Name;
              yFrom:= YStart;
              mFrom:= MStart;
              yTo:= YEnd;
              mTo:= MEnd;
              fTop:= IsTop;
            end;
            s:= manuf.ModelLineEdit(mlORD, yFrom, mFrom,
              yTo, mTo, UserID, fTop, fVis, mlName, mlTD);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then s:= 'уст.видим.мод.ряда'
            else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
            fUpdMl:= False;
          end; // отредактировали мод.ряд

          if fUpdMod then with model do begin //------ редактируем модель
            if (Name<>mName) then
              s:= ModelEdit(mName, fVis, IsTop, UserID, Params)
            else s:= SetModelVisible(fVis);
            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then begin
              s:= 'устан.видим.модели';
              inc(iUpd);
            end else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;

//------------------------------------------------------ отрабатываем добавление
          end else if fAddMod then begin
            tdFrom:= 0;
            tdTo:= 0;
            if (fAddMf or fAddMl) then try
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              if TdtIBS.SQL.Text='' then
                TdtIBS.SQL.Text:= 'select MS_ID, MS_DESCR, MS_MF_ID, MS_FROM, MS_TO,'+
                  ' iif(icn_NewDescr is null, MS_MF_DESCR, icn_NewDescr) MF_DESCR'+
                  ' from AXLES left join MODEL_SERIES on MS_ID=AX_MS_ID'+
                  ' left join import_change_names on ICN_TAB_ID=100 and ICN_KE_KEY=MS_MF_ID'+
                  ' where AX_ID=:mt';
              TdtIBS.ParamByName('mt').AsInteger:= mTD;
              TdtIBS.ExecQuery;
              if (TdtIBS.Bof and TdtIBS.Eof) then
                raise Exception.Create(MessText(mtkNotValidParam)+' - модель TD');
              if (mfTD<>TdtIBS.fieldByName('MS_MF_ID').AsInteger) then
                raise Exception.Create(MessText(mtkNotValidParam)+' - произв. TD');
              if (mlTD<>TdtIBS.fieldByName('MS_ID').AsInteger) then
                raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд TD');

              mfName:= TdtIBS.fieldByName('MF_DESCR').AsString;  // наимен. произв.
              if (mlName='') then
                mlName:= fnReplaceQuotedForWeb(TdtIBS.fieldByName('MS_DESCR').AsString);   // наимен. мод.ряда
              tdFrom:= TdtIBS.fieldByName('MS_FROM').AsInteger;     // от
              tdTo  := TdtIBS.fieldByName('MS_TO').AsInteger;       // до
            finally
              TdtIBS.Close;
            end; // if (fAddMf or fAddMl)

            if fAddMf then begin //--------------- если надо - добавляем произв.
              fTop:= False;
              s:= Manufacturers.ManufAdd(mfORD, mfName, constIsAx, UserID, fTop, fVis, mfTD);
              if (s=MessText(mtkNotParams)) then s:= ''
              else if (s='') then s:= 'доб.произв.'
              else raise Exception.Create(s);
              if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
              fAddMf:= False;
              if (mfORD<1) then // не определен ID произв.
                raise Exception.Create(MessText(mtkNotValidParam)+' - произв.');
              manuf:= Manufacturers[mfORD];
            end; // добавили произв.

            if fAddMl then begin //--------------- если надо - добавляем мод.ряд
                               // разделить год и месяц начала/окончания выпуска
              GetYMfromTDfromto(tdFrom, tdTo, yFrom, mFrom, yTo, mTo);
              fTop:= False;
              s:= manuf.ModelLineAdd(mlORD, mlName, constIsAx,
                mFrom, yFrom, mTo, yTo, UserID, fTop, fVis, mlTD);
              if (s=MessText(mtkNotParams)) then s:= ''
              else if (s='') then s:= 'доб.мод.ряд'
              else raise Exception.Create(s);
              if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
              fAddMl:= False;
              if (mlORD<1) then // не определен ID мод.ряда
                raise Exception.Create(MessText(mtkNotValidParam)+' - мод.ряд');
            end; // if fAddMl - добавили мод.ряд

            fTop:= False;
                                 //---------------------- добавляем новую модель
            s:= prAddNewAxleFromTDT(mORD, UserID, mTD, mlORD, TdtIBSm, KeyTabs, fVis, fTop, mName);

            if (s=MessText(mtkNotParams)) then s:= ''
            else if (s='') then begin
              s:= 'доб.модель';
              inc(iAdd);
              sleep(10);
            end else raise Exception.Create(s);
            if (s<>'') then ss:= ss+fnIfStr(ss='', '', ', ')+s;
          end; // if fAddMod

          if (GetCellStrValue(WorkSheet, CellSigns[1], iLine)='/1') then  // если опция = "/1" - заменяем на '/2'
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '/2');
          if (GetCellIntValue(WorkSheet, CellSigns[14], iLine)=0) and (mORD>0) then // если добавили модель
            SetCellIntValue(WorkSheet, CellSigns[14], iLine, mORD);            // вписываем код модели
          if ss<>'' then SetCellStrValue(WorkSheet, CellSigns[15], iLine, ss); // вписываем результат
        except
          on E: EBOBError do begin
            if (E.Message<>'') or (ss<>'') then
              SetCellStrValue(WorkSheet, CellSigns[15], iLine, fnIfStr(ss='', '', ss+', ')+E.Message); // вписываем сообщение
            raise EBOBError.Create('строка '+IntToStr(iLine)+' - '+E.Message);
          end;
          on E: Exception do begin
            inc(iErr);
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - '+E.Message;
            SaveStrToMail(MailStr);
            prMessageLOGS(nmProc+': '+MailStr, 'import', False);
            if (E.Message<>'') or (ss<>'') then
              SetCellStrValue(WorkSheet, CellSigns[15], iLine, fnIfStr(ss='', '', ss+', ')+E.Message); // вписываем сообщение
          end;
        end; // for iLine:= 2 to rows

        try                           //--------------------------- итоги по листу
          iLine:= rows+1;
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, '----------------------');
          inc(iLine);
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'обработано:   '+IntToStr(iLine)+' строк');
          inc(iLine);
          if iAdd>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'добавлено :   '+IntToStr(iAdd)+' моделей');
            inc(iLine);
          end;
          if iUpd>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'уст.видим.:   '+IntToStr(iUpd)+' моделей');
            inc(iLine);
          end;
          if iErr>0 then begin
            SetCellStrValue(WorkSheet, CellSigns[2], iLine, 'ошибки    :   '+IntToStr(iErr)+' строк');
            SaveStrToMail('лист ['+WorkSheet.Name+'] - '+IntToStr(iErr)+' ошибок');
            inc(iLine);
          end;
          SetCellStrValue(WorkSheet, CellSigns[2], iLine, '----------------------');
        except
          on E: Exception do
            prMessageLOGS(nmProc+': ошибка в итогах на листе ['+WorkSheet.Name+'] '+E.Message, 'import', False);
        end;
       CheckStopExecute(UserID, ThreadData);
       SetExecutePercent(UserID, ThreadData, Percent);
      except
        on E: EBOBError do raise Exception.Create('лист ['+WorkSheet.Name+']: '+E.Message);
        on E: Exception do begin
          MailStr:= 'лист ['+WorkSheet.Name+'] - '+E.Message;
          SaveStrToMail(MailStr);
          prMessageLOGS(nmProc+': '+MailStr, 'import', False);
        end;
      end; // for SheetID:= 1 to SheetCount
    finally
      SaveAndCloseWorkBook(XL, WorkBook);
    end;
  except
    on E: Exception do begin
      SaveStrToMail(E.Message);
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import', False);
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    prFreeIBSQL(TdtIBS);
    prFreeIBSQL(TdtIBSm);
    cntsTDT.SetFreeCnt(TdtIBD, True);
    ClearArKeyTabs(KeyTabs);
    if (iMail>0) then BodyMail.Add(' ');
  end;
end;
//================== 34-imp - загрузка / корректировка узлов авто из файла Excel
procedure prSetNewTreeNodesFromTDT(UserID: Integer; FileName: string;
          var BodyMail: TStringList; ThreadData: TThreadData=nil);
const nmProc = 'prSetNewTreeNodesFromTDT'; // имя процедуры/функции
var nodeTD, ParTD, nodeORD, mainORD, ParORD, iAdd, SheetID, iErr, iUpd,
      iLine, iVis, SheetCount, rows, ii, iWork, iSys, iMail: integer;
    NodeName, nameSys, name1, name2, name3, name4, s, SheetName, MailStr: string;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    flVis, flGA, flAdd, flUpd: Boolean;
    Percent, ListPercent: Single;
    XL: Excel_TLB.TExcelApplication;
    WorkBook: Excel_TLB._Workbook;
    WorkSheet: Excel_TLB._Worksheet;
    //--------------------------------------------
    procedure SaveStrToMail(str: String);
    begin
      if not Assigned(BodyMail) then BodyMail:= TStringList.Create;
      if (iMail<1) then BodyMail.Add(' ');
      BodyMail.Add(str);
      inc(iMail);
    end;
    //--------------------------------------------
begin
  iSys:= 0;
  iMail:= 0;
  XL:= nil;
  WorkBook:= nil;
  with Cache.FDCA do try
    SetExecutePercent(UserID, ThreadData, 1);
    try
      OpenWorkBookNotVisible(FileName, XL, WorkBook); // открыть файл Excel для импорта
      SheetCount:= WorkBook.Worksheets.Count; //количество листов excel
      ListPercent:= 90/SheetCount;
      for SheetID:= 1 to SheetCount do try
        WorkSheet:= WorkBook.Sheets.Item[SheetID] as Excel_TLB._Worksheet;
        SheetName:= AnsiUpperCase(WorkSheet.Name);
        if (pos('УЗЛЫ', SheetName)<1) then Continue;    // пропускаем ненужные листы

        if (pos('АВТО', SheetName)>0) then iSys:= constIsAuto
        else if (pos('ГРУЗ', SheetName)>0) then iSys:= constIsCV
        else if (pos('ОСЕЙ', SheetName)>0) then iSys:= constIsAx;
        if (iSys<1) then Continue;                     // пропускаем неопознанные листы

        nodes:= AutoTreeNodesSys[iSys];

        GetWorkSheetCounts(WorkSheet, rows, ii); // получить кол-во строк и столбцов на листе
        if rows<2 then Continue;                // переходим к следующему листу
        if ii<13 then // проверяем кол-во столбцов
          raise Exception.Create(MessText(mtkNotEnoughParams)+' - мало столбцов');
        CheckStopExecute(UserID, ThreadData);
//      1         2             3             4              5          6        7     индекс ячейки
// ('опция')+('уровень 1')+('уровень 2')+('уровень 3')+('уровень 4')+('Код')+('Главн.')+
//      8           9                 10             11        12         13           индекс ячейки
// ('Видим.')+('Конечный узел')+('Сист.наимен.')+('kodTD')+('ParTD')+('Результат')

        Percent:= ListPercent/rows;
        iAdd:= 0;
        iErr:= 0;
        iUpd:= 0;
        iWork:= 0;
        for iLine:= 2 to rows do try // считываем строки листа (1-я строка - заголовок)
          CheckStopExecute(UserID, ThreadData);
          SetExecutePercent(UserID, ThreadData, Percent);
//------------------------------------------------------ определяем опцию
          s:= GetCellStrValue(WorkSheet, CellSigns[1], iLine);
          if (s='') then begin
            flAdd:= False;
            flUpd:= False;
          end else begin
            flAdd:= (s=sActionAdd);
            flUpd:= not flAdd and (s=sActionUpd);
          end;            // если опция отсутствует или недопустима - пропускаем
          if not flAdd and not flUpd then Continue;
          inc(iWork);
//------------------------------------------------------ обработка строки
          name1   := GetCellStrValue(WorkSheet, CellSigns[2], iLine);
          name2   := GetCellStrValue(WorkSheet, CellSigns[3], iLine);
          name3   := GetCellStrValue(WorkSheet, CellSigns[4], iLine);
          name4   := GetCellStrValue(WorkSheet, CellSigns[5], iLine);
          nodeORD := GetCellIntValue(WorkSheet, CellSigns[6], iLine); // код узла
          mainORD := GetCellIntValue(WorkSheet, CellSigns[7], iLine); // код главн.узла
          iVis    := GetCellIntValue(WorkSheet, CellSigns[8], iLine);
          flVis   := iVis=1;
          NodeName:= GetCellStrValue(WorkSheet, CellSigns[9], iLine);
          nameSys := GetCellStrValue(WorkSheet, CellSigns[10], iLine);
          nodeTD  := GetCellIntValue(WorkSheet, CellSigns[11], iLine); // код TecDoc узла
          ParTD   := GetCellIntValue(WorkSheet, CellSigns[12], iLine); // код TecDoc род.узла
          flGA    := (NodeName<>'');
          if not flGA then begin // ищем наимен. неконечной ноды
            if (name4<>'') then NodeName:= name4
            else if (name3<>'') then NodeName:= name3
            else if (name2<>'') then NodeName:= name2
            else if (name1<>'') then NodeName:= name1;
          end;

          if flAdd then begin  // новая нода
            if (nodeORD>0) then raise Exception.Create(MessText(mtkNotValidParam)+' - Код');
            if (nodeTD<1) then raise Exception.Create(MessText(mtkNotValidParam)+' - kodTD');
            if (ParTD<0)  then raise Exception.Create(MessText(mtkNotValidParam)+' - ParTD');

            nodeORD:= Nodes.GetNodeIDByTDcodes(nodeTD, ParTD, flGA);
            if (nodeORD>0) and Nodes.NodeExists(nodeORD) then
              raise Exception.Create('такой узел уже есть');

            if ParTD<1 then ParORD:= 0                       // код ORD род.ноды
            else ParORD:= Nodes.GetNodeIDByTDcodes(ParTD, 0, False);
            nodeORD:= 0;

            if flVis and (ParORD>0) then begin
              node:= Nodes[ParORD];
              if not node.IsVisible then raise Exception.Create(
                'нельзя добавить видимый узел в ветку к невидимому родительскому узлу');
            end;

            s:= TreeNodeAdd(iSys, ParORD, mainORD, NodeName, nameSys, UserID,
                 nodeORD, flVis, 0, nodeTD, flGA);       // Добавление узла
            if (s<>'') then raise Exception.Create(s);

            node:= Nodes[nodeORD];
            SetCellIntValue(WorkSheet, CellSigns[6], iLine, nodeORD);         // вписываем Код
            if (node.MainCode<>mainORD) then
              SetCellIntValue(WorkSheet, CellSigns[7], iLine, node.MainCode); // вписываем Главн.
            inc(iAdd);
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '');              // убираем опцию
            SetCellStrValue(WorkSheet, CellSigns[13], iLine, 'добавлен');     // вписываем результат

          end else if flUpd then begin  // корректировка
            if (nodeORD<1) or not Nodes.NodeExists(nodeORD) then
              raise Exception.Create(MessText(mtkNotValidParam)+' - Код = '+IntToStr(nodeORD));
            if not flGA then raise Exception.Create(MessText(mtkNotValidParam)+' - Конечный узел');

            s:= Nodes.NodeEdit(nodeORD, mainORD, iVis, UserID, NodeName, ''); // NameSys не меняем !!!
            if (s<>'') then raise Exception.Create(s);
            inc(iUpd);
            SetCellStrValue(WorkSheet, CellSigns[1], iLine, '');             // убираем опцию
            SetCellStrValue(WorkSheet, CellSigns[13], iLine, 'изменен');      // вписываем результат
          end;
          CheckStopExecute(UserID, ThreadData);
        except
          on E: EBOBError do begin
            if (E.Message<>'') then begin
              MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - !!! '+E.Message;
              SaveStrToMail(MailStr);
              SetCellStrValue(WorkSheet, CellSigns[13], iLine, '!!! '+E.Message); // вписываем сообщение
            end;
            raise EBOBError.Create('строка '+IntToStr(iLine)+': '+E.Message);
          end;
          on E: Exception do begin
            inc(iErr);
            MailStr:= 'строка '+IntToStr(iLine)+' листа ['+WorkSheet.Name+'] - !!! '+E.Message;
            prMessageLOGS(nmProc+': '+MailStr, 'import', False);
            if (E.Message<>'') then begin
              SaveStrToMail(MailStr);
              SetCellStrValue(WorkSheet, CellSigns[13], iLine, '!!! '+E.Message); // вписываем сообщение
            end;
          end;
        end; // for iLine:= 2 to rows

        try                         //--------------------------- итоги по листу
          iLine:= rows+1;
          s:= CellSigns[1];
          SetCellStrValue(WorkSheet, s, iLine, '---------------------- '+FormatDateTime(cDateTimeFormatY4N, Now));
          inc(iLine);
          SetCellStrValue(WorkSheet, s, iLine, 'обработано:   '+IntToStr(iWork)+' строк');
          inc(iLine);
          if iAdd>0 then begin
            SetCellStrValue(WorkSheet, s, iLine, 'добавлено:   '+IntToStr(iAdd)+' узлов');
            inc(iLine);
          end;
          if iUpd>0 then begin
            SetCellStrValue(WorkSheet, s, iLine, 'изменено :   '+IntToStr(iUpd)+' узлов');
            inc(iLine);
          end;
          if iErr>0 then begin
            SetCellStrValue(WorkSheet, s, iLine, 'ошибки   :   '+IntToStr(iErr)+' узлов');
            inc(iLine);
          end;
          SetCellStrValue(WorkSheet, s, iLine, '----------------------');
        except
          on E: Exception do begin
            MailStr:= 'ошибка в итогах на листе ['+WorkSheet.Name+'] - '+E.Message;
            SaveStrToMail(MailStr);
            prMessageLOGS(nmProc+': '+MailStr, 'import', False);
          end;
        end;
        CheckStopExecute(UserID, ThreadData);
        SetExecutePercent(UserID, ThreadData, Percent);
      except
        on E: EBOBError do raise Exception.Create('лист ['+WorkSheet.Name+']: '+E.Message);
        on E: Exception do
          prMessageLOGS(nmProc+': лист ['+WorkSheet.Name+'] '+E.Message, 'import', False);
      end; // for SheetID:= 1 to SheetCount
      CheckStopExecute(UserID, ThreadData);
    finally
      SaveAndCloseWorkBook(XL, WorkBook);
    end;
  except
    on E: Exception do begin
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import', False);
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
end;
//========== загрузка альтернативных значений инфо-текстов TecDoc из файла Excel
procedure prSetAlternativeInfoTexts(UserID: integer; FileName: string; ThreadData: TThreadData=nil);
const nmProc  = 'prSetAlternativeInfoTexts'; // имя процедуры/функции
      LogTest = 'import_test';
// обрабатываются только строки с опциями 1 и 2
// в обработанных строках в файл FileName в колонку опции записывается результат:
// 0= обработано, 1= уже есть, 21= не найден tmTD, 22= не совп. с текстом в базе (опция 1),
// 24= совпадение текстов в файле, 25= ошибка
var ORD_IBS, ibsN: TIBSQL;
    ORD_IBD: TIBDatabase;
    opt, txt, txtAlt, SheetName, s, mess: String;
    i, iLine, iErr, iAdd, iNot, iEx, iWork, SheetCount, rows, ii: Integer;
    XL: Excel_TLB.TExcelApplication;
    WorkBook: Excel_TLB._Workbook;
    WorkSheet: Excel_TLB._Worksheet;
  //---------------------------------
  procedure SaveToTestLog(iLine: Integer; txt, txtAlt, errtxt: String);
  begin
    prMessageLOGS(nmProc+': строка '+IntToStr(iLine), LogTest, False);
    prMessageLOGS(' errtxt= '+errtxt, LogTest, False);
    prMessageLOGS('    txt= '+txt, LogTest, False);
    prMessageLOGS(' txtAlt= '+txtAlt, LogTest, False);
  end;
  //---------------------------------
begin
  ORD_IBS:= nil;
  ibsN:= nil;
  XL:= nil;
  WorkBook:= nil;
  iAdd := 0;
  iErr := 0;
  iWork:= 0;
  iNot := 0;
  iEx  := 0;
  opt:= '';
  SheetName:= '';
  try try
    OpenWorkBookNotVisible(FileName, XL, WorkBook); // открыть файл Excel для импорта
    SheetCount:= WorkBook.Worksheets.Count;         // количество листов excel
    for i:= 1 to SheetCount do begin
      WorkSheet:= WorkBook.Sheets.Item[i] as Excel_TLB._Worksheet;
      SheetName:= AnsiUpperCase(WorkSheet.Name);
      if pos('ЗАМЕНЫ', SheetName)>0 then break else SheetName:= '';
    end;
    if SheetName='' then raise EBOBError.Create('в файле '+FileName+' нет листа "ЗАМЕНЫ"');

    GetWorkSheetCounts(WorkSheet, rows, ii); // получить кол-во строк и столбцов на листе
    if rows<2 then raise EBOBError.Create(MessText(mtkNotEnoughParams)+' - мало строк');
    if ii<6 then // проверяем кол-во столбцов
      raise EBOBError.Create(MessText(mtkNotEnoughParams)+' - мало столбцов');

    CheckStopExecute(UserID, ThreadData);
    ORD_IBD:= cntsOrd.GetFreeCnt('', '', '', True);
    try
      ibsN:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite);
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
                                 // для простановки признака ненужности перевода
      ibsN.SQL.Text:= 'select Result from SetTextNotAlternative(:txt, '+intToStr(UserID)+')';
                                                      // для добавления перевода
      ORD_IBS.SQL.Text:= 'select Result, rText, ErrText'+
        ' from AddAlternativeText_new(:opt, :txt, :txtAlt, '+intToStr(UserID)+')';

      for iLine:= 2 to rows do try // считываем строки файла (1-я строка - заголовок)
        opt:= GetCellStrValue(WorkSheet, CellSigns[4], iLine); // опция
        // opt= '/1' - обр-ть, если pText=текст в базе, '/-1' - отметить текст, не треб.перевода,
        // opt= '/2' - обр-ть без проверки, '/3' - заменить альт.текст
        if (opt<>'/-1') and (opt<>'/1') and (opt<>'/2') and (opt<>'/3') then Continue;
        inc(iWork);
        txt:= GetCellStrValue(WorkSheet, CellSigns[2], iLine); // исх.текст

        if (opt='/-1') then begin // отмечаем текст, не требующий перевода
          if ibsN.Open then ibsN.Close;
          with ibsN.Transaction do if not InTransaction then StartTransaction;
          ibsN.ParamByName('txt').AsString:= txt;
          ibsN.ExecQuery;
          if (ibsN.Bof and ibsN.Eof) then raise Exception.Create('empty ibsN');
          opt:= ibsN.FieldByName('Result').AsString;
          with ibsN.Transaction do if InTransaction then
            if opt='0' then Commit else Rollback;
          ibsN.Close;

          if opt='0' then begin // обработано
            inc(iNot);
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/0'); // вписываем результат: 0=обраб.
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, 'проставлен признак "-1" в базе'); // пишем комментарий
          end else if opt='-1' then begin // не найден текст
            inc(iErr);
            mess:= 'не найден текст';
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/-21'); // вписываем результат: -21=не найден
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем комментарий
            SaveToTestLog(iLine, txt, txtAlt, mess);
          end;

        end else begin            // добавляем перевод
          txtAlt:= GetCellStrValue(WorkSheet, CellSigns[3], iLine); // альтерн.текст - перевод
          if (txtAlt='') then begin
            inc(iErr);
            mess:= 'альтерн.текст пустой';
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/25'); // вписываем результат ошибки
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем текст ошибки
            SaveToTestLog(iLine, txt, txtAlt, mess);
            Continue;
          end;
          if (txt=txtAlt) then begin
            inc(iErr);
            mess:= 'альтерн.текст = текст';
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/24'); // вписываем результат совпадения текстов
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем результат
            SaveToTestLog(iLine, txt, txtAlt, mess);
            Continue;
          end;

          txtAlt:= StringReplace(txtAlt,   #9, ' ', [rfReplaceAll]); // убираем символы табуляции
          txtAlt:= StringReplace(txtAlt,  #10, ' ', [rfReplaceAll]); // убираем символы конца строки
          txtAlt:= StringReplace(txtAlt,  #13, ' ', [rfReplaceAll]); // убираем символы новой строки
          txtAlt:= StringReplace(txtAlt, '  ', ' ', [rfReplaceAll]); // убираем двойные пробелы

          if ORD_IBS.Open then ORD_IBS.Close;
          with ORD_IBS.Transaction do if not InTransaction then StartTransaction;
          ORD_IBS.ParamByName('opt').AsString:= copy(opt, 2, length(opt)-1);
          ORD_IBS.ParamByName('txt').AsString:= txt;
          ORD_IBS.ParamByName('txtAlt').AsString:= txtAlt;
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Bof and ORD_IBS.Eof) then raise Exception.Create('empty ORD_IBS');
          opt := ORD_IBS.FieldByName('Result').AsString;
          txt := ORD_IBS.FieldByName('rText').AsString;
          mess:= ORD_IBS.FieldByName('ErrText').AsString;
          with ORD_IBS.Transaction do if InTransaction then
            if opt='0' then Commit else Rollback;
          ORD_IBS.Close;

          if opt='0' then begin // обработано
            inc(iAdd);
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/0'); // вписываем результат: 0=обраб.
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, 'альтерн.текст записан в базу'); // пишем комментарий
          end else if opt='1' then begin // уже есть
            inc(iEx);
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/-0'); // вписываем результат: -0= (уже есть)
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем комментарий
          end else if opt='-1' then begin // не найден tmTD
            inc(iErr);
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/21'); // вписываем результат: 21=не найден
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем комментарий
            SaveToTestLog(iLine, txt, txtAlt, mess);
          end else if opt='-2' then begin // не совп. с текстом в базе (опция 1)
            inc(iErr);
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/22'); // вписываем результат: 22=не совп.
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем комментарий
            SetCellStrValue(WorkSheet, CellSigns[6], iLine, txt);   // пишем текст из базы для анализа
            SaveToTestLog(iLine, txt, txtAlt, mess);
          end else if opt='-3' then begin // есть связка с др.текстом (опция 1,2)
            inc(iErr);
            SetCellStrValue(WorkSheet, CellSigns[4], iLine, '/23'); // вписываем результат: 23=есть др.связка
            SetCellStrValue(WorkSheet, CellSigns[5], iLine, mess);  // пишем комментарий
            SetCellStrValue(WorkSheet, CellSigns[6], iLine, txt);   // пишем текст из базы для анализа
            SaveToTestLog(iLine, txt, txtAlt, mess);
          end;
        end;
        CheckStopExecute(UserID, ThreadData);
      except
        on E: Exception do begin
          with ORD_IBS.Transaction do if InTransaction then Rollback;
          with ibsN.Transaction do if InTransaction then Rollback;
          prMessageLOGS(nmProc+': строка '+IntToStr(iLine)+' - '+E.Message, 'import', False);
          inc(iErr);
          if (opt='/-1') then s:= '/-25' else s:= '/25';
          SetCellStrValue(WorkSheet, CellSigns[4], iLine, s); // вписываем результат ошибки
          SetCellStrValue(WorkSheet, CellSigns[5], iLine, E.Message); // пишем текст ошибки
          SaveToTestLog(iLine, txt, txtAlt, E.Message);
        end;
      end; // for iLine:= 2 to rows
      ORD_IBS.Close;

      ORD_IBS.SQL.Text:= 'delete from infotextsaltern'+  // чистим лишние переводы
        ' where not exists(select * from infotexts where italtern=itacode)';
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      prFreeIBSQL(ibsN);
      cntsOrd.SetFreeCnt(ORD_IBD, True);
    end;
  finally
    SaveAndCloseWorkBook(XL, WorkBook);
    if (iWork>0) then prMessageLOGS(nmProc+': обраб- '+IntToStr(iWork)+
      fnIfStr(iAdd>0, ', доб- '+IntToStr(iAdd), '')+
      fnIfStr(iNot>0, ', пр."-1"- '+IntToStr(iNot), '')+
      fnIfStr(iEx>0, ', дубл.- '+IntToStr(iEx), '')+
      fnIfStr(iErr>0, ', ош- '+IntToStr(iErr), ''), 'import', False);
  end;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, 'import', False);
  end;
end;
(*
//==================================== 53-import - отмена переброски к/а Гроссби
procedure prSetFirmReClones(pUserID: Integer; pFileName: String; ThreadData: TThreadData=nil);
const nmProc = 'prSetFirmReClones'; // имя процедуры/функции
var ordIBD, gbIBD, gbIBDw: TIBDatabase;
    ordIBS, gbIBS, gbIBSw: TIBSQL;
    lstSQL, lst: TStringList;
    i, SheetCount, rows, ii, iLine, iChange: Integer;
    s, ss, sf1, sFirm, SheetName, NumContOld, NumContFrom, NumContMain, fNameFrom, fNameTo: String;
    Percent: real;
    XL: Excel_TLB.TExcelApplication;
    WorkBook: Excel_TLB._Workbook;
    WorkSheet: Excel_TLB._Worksheet;
begin
  ordIBS:= nil;
  gbIBS:= nil;
  gbIBSw:= nil;
  XL:= nil;
  WorkBook:= nil;
//  gbIBDw:= nil;
//  ordIBD:= nil;
  lstSQL:= fnCreateStringList(False, 10); // список строк SQL для изменения логинов
  lst:= fnCreateStringList(False, 10); // список строк для отправки в архив логинов
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  SheetName:= ''; //
  try try

    OpenWorkBookNotVisible(pFileName, XL, WorkBook); // открыть файл Excel для импорта
    SheetCount:= WorkBook.Worksheets.Count;         // количество листов excel
    for i:= 1 to SheetCount do begin
      WorkSheet:= WorkBook.Sheets.Item[i] as Excel_TLB._Worksheet;
      SheetName:= AnsiUpperCase(WorkSheet.Name);
      if pos('РАЗЪЕДИНЕНИЕ', SheetName)>0 then break else SheetName:= '';
    end;
    if SheetName='' then raise EBOBError.Create('в файле '+pFileName+' нет листа "РАЗЪЕДИНЕНИЕ"');

    GetWorkSheetCounts(WorkSheet, rows, ii); // получить кол-во строк и столбцов на листе
    if rows<2 then raise EBOBError.Create(MessText(mtkNotEnoughParams)+' - мало строк');
    if ii<5 then raise EBOBError.Create(MessText(mtkNotEnoughParams)+' - мало столбцов');
    CheckStopExecute(pUserID, ThreadData);

    gbIBD:= cntsGRB.GetFreeCnt('', '', '', True);
    gbIBDw:= cntsGRB.GetFreeCnt('', '', '', True);
    ordIBD:= cntsORD.GetFreeCnt('', '', '', True);
    try
      gbIBS:= fnCreateNewIBSQL(gbIBD, 'gbIBS_'+nmProc, -1, tpRead, true);
      gbIBS.ParamCheck:= False;
      gbIBS.SQL.Add('execute block returns (firmFrom integer, contFrom integer,');
      gbIBS.SQL.Add('  firmTo integer, contTo integer, filTo integer, dprtTo integer,');
      gbIBS.SQL.Add('  ContToN varchar(16), fnameFrom varchar(100), fnameTo varchar(100)) as');
      gbIBS.SQL.Add(' declare variable xKind integer; declare variable xContOldN varchar(16);');
      gbIBS.SQL.Add(' declare variable xBegDate Date; declare variable xContFromN varchar(16);');
      gbIBS.SQL.Add(' declare variable xMainNum varchar(16);');
      iChange:= gbIBS.SQL.Add(' begin xContOldN = ""; xContFromN = ""; xMainNum = "";'); // gbIBS.SQL[iChange]
      gbIBS.SQL.Add('  select contsecondparty, f.firmmainname from contract');
      gbIBS.SQL.Add('    left join firms f on f.firmcode = contsecondparty');
      gbIBS.SQL.Add('    where trim(iif(contnkeyyear>2016 and contpaytype=0, contnumber||"-55",');
      gbIBS.SQL.Add('      contnumber))||"-"||RIGHT(contnkeyyear, 2) = :xContOldN');
//      gbIBS.SQL.Add('    where trim(contnumber) || "-" || right(cast(extract(year');
//      gbIBS.SQL.Add('      from contbeginingdate) as varchar(4)), 2) = :xContOldN');
      gbIBS.SQL.Add('  into :firmTo, :fnameTo;');
      gbIBS.SQL.Add('  if(firmTo < 1) then Exception NonFound "не найден контракт "||xContOldN;');
      gbIBS.SQL.Add('  select contsecondparty, f.firmmainname from contract');
      gbIBS.SQL.Add('    left join firms f on f.firmcode = contsecondparty');
      gbIBS.SQL.Add('    where trim(iif(contnkeyyear>2016 and contpaytype=0, contnumber||"-55",');
      gbIBS.SQL.Add('      contnumber))||"-"||RIGHT(contnkeyyear, 2) = :xMainNum');
//      gbIBS.SQL.Add('    where trim(contnumber) || "-" || right(cast(extract(year');
//      gbIBS.SQL.Add('      from contbeginingdate) as varchar(4)), 2) = :xMainNum');
      gbIBS.SQL.Add('  into :firmFrom, :fnameFrom;');
      gbIBS.SQL.Add('  if(firmFrom < 1) then Exception NonFound "не найден контракт "||xMainNum;');
      gbIBS.SQL.Add('  select contcode, contbeginingdate from contract');
      gbIBS.SQL.Add('    where trim(iif(contnkeyyear>2016 and contpaytype=0, contnumber||"-55",');
      gbIBS.SQL.Add('      contnumber))||"-"||RIGHT(contnkeyyear, 2) = :xContFromN');
//      gbIBS.SQL.Add('    where trim(contnumber) || "-" || right(cast(extract(year');
//      gbIBS.SQL.Add('      from contbeginingdate) as varchar(4)), 2) = :xContFromN');
      gbIBS.SQL.Add('  into :contFrom, :xBegDate;');
      gbIBS.SQL.Add('  if(contFrom < 1) then Exception NonFound "не найден контракт "||xContFromN;');
      gbIBS.SQL.Add('  contTo = null; ContToN = null; dprtTo = null; filTo = null;');

      gbIBS.SQL.Add('  select c2.contcode,'+
                    '  iif(c2.contnkeyyear>2016 and c2.contpaytype=0,'+
                    '    c2.contnumber||"-55", c2.contnumber) contnumber'+
                    '  from contract c2');
//      If not flFCNProc then
//      gbIBS.SQL.Add('  left join Vlad_CSS_GetFullContNum(c2.contnumber, c2.contnkeyyear, c2.contpaytype) gn on 1=1');

      gbIBS.SQL.Add('    where c2.contsecondparty = :firmTo and c2.contbeginingdate >= :xBegDate');
      gbIBS.SQL.Add('  into :contTo, :ContToN;');
      gbIBS.SQL.Add('  if(contTo < 1) then Exception NonFound "не найден контракт для возврата";');
      gbIBS.SQL.Add('  select h.ctshlkdprtcode from contractstorehouselink h');
      gbIBS.SQL.Add('    where h.ctshlkcontcode = :contTo and h.ctshlkdefault = "T"');
      gbIBS.SQL.Add('  into :dprtTo; filTo = dprtTo; xKind = -1;');
      gbIBS.SQL.Add('  while (xKind < 0) do begin');
      gbIBS.SQL.Add('    select d.dprtmastercode from department d');
      gbIBS.SQL.Add('      where d.dprtcode = :filTo into :filTo;');
      gbIBS.SQL.Add('    select d.dprtkind from department d');
      gbIBS.SQL.Add('      where d.dprtcode = :filTo into :xKind;');
      gbIBS.SQL.Add('    if (xKind <> 1) then xKind = -1; end suspend; end');

      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite, true);
      ordIBS.SQL.Text:= 'select rClientOld, rArhLogin from reCloneFirm(:FirmFrom,'+
        ' :ContFrom, :FirmTo, :ContTo, :FilialTo, :DprtTo, '+IntToStr(pUserID)+')';


      for iLine:= 2 to rows do try // считываем строки файла (1-я строка - заголовок)
        NumContOld := GetCellStrValue(WorkSheet, CellSigns[1], iLine); // старый контракт
        if (NumContOld='') then Continue;
        NumContFrom:= GetCellStrValue(WorkSheet, CellSigns[2], iLine); // был перенос на контракт
        NumContMain:= GetCellStrValue(WorkSheet, CellSigns[3], iLine); // основной контракт нового к/а
        fNameTo    := GetCellStrValue(WorkSheet, CellSigns[4], iLine);
        fNameFrom  := GetCellStrValue(WorkSheet, CellSigns[5], iLine);
        if (NumContFrom='') or (NumContMain='') then
          raise Exception.Create('не задан один из контрактов');
        gbIBS.Close;
        gbIBS.SQL[iChange]:= ' begin xContOldN = "'+NumContOld+'"; xContFromN = "'+
                             NumContFrom+'"; xMainNum = "'+NumContMain+'";'; //
        gbIBS.ExecQuery; // считываем данные для возврата из Grossbee
        if (gbIBS.FieldByName('fnameTo').AsString<>fNameTo) then
          raise Exception.Create('несоответствие к/а '+fNameTo);
        if (gbIBS.FieldByName('fNameFrom').AsString<>fNameFrom) then
          raise Exception.Create('несоответствие к/а '+fNameFrom);

        ss:= 'перенос данных к/а '+fNameTo+' на контракт '+gbIBS.FieldByName('ContToN').AsString;
        ordIBS.Close;
        lstSQL.Clear;
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.ParamByName('FirmFrom').AsInteger:= gbIBS.FieldByName('FirmFrom').AsInteger;
        ordIBS.ParamByName('ContFrom').AsInteger:= gbIBS.FieldByName('ContFrom').AsInteger;
        ordIBS.ParamByName('FirmTo').AsInteger  := gbIBS.FieldByName('FirmTo').AsInteger;
        ordIBS.ParamByName('ContTo').AsInteger  := gbIBS.FieldByName('ContTo').AsInteger;
        ordIBS.ParamByName('filTo').AsInteger   := gbIBS.FieldByName('filTo').AsInteger;
        ordIBS.ParamByName('DprtTo').AsInteger  := gbIBS.FieldByName('DprtTo').AsInteger;
        gbIBS.Close;
        try
          ordIBS.ExecQuery; //-------------------------  в db_ORD
          s:= '';
          i:= 0;
          while not ordIBS.Eof do begin
            if (ordIBS.FieldByName('rClientOld').AsInteger<0) then // аннулировано/перенесено заказов - в лог
              ss:= ss+' '+ordIBS.FieldByName('rArhLogin').AsString
            else if (ordIBS.FieldByName('rClientOld').AsInteger>0) then begin
              sf1:= ordIBS.FieldByName('rArhLogin').AsString;
              lstSQL.Add('update persons set prsnlogin="'+sf1+'" where prsncode='+
                         ordIBS.FieldByName('rClientOld').AsString+';');
              if (copy(sf1, 1, 1)='_') then begin
                s:= s+fnIfStr(s='', '', ' ')+sf1;
                inc(i);
              end;
            end;
            TestCssStopException;
            ordIBS.Next;
          end;
          ordIBS.Transaction.Commit;
          ordIBS.Close;
        except
          on E: Exception do begin
            with ordIBS.Transaction do if InTransaction then Rollback;
            ordIBS.Close;
// при ошибке вывести в лог коды фирм, клиентов и логины !!!
            raise Exception.Create(E.Message);
          end;
        end;

        if (lstSQL.Count>0) then begin
          lstSQL.Insert(0, 'execute block as begin');
          lstSQL.Add('end');
          with gbIBSw.Transaction do if not InTransaction then StartTransaction;
          gbIBSw.SQL.Clear;
          gbIBSw.SQL.AddStrings(lstSQL);
          try
            gbIBSw.ExecQuery;
            gbIBSw.Transaction.Commit;
//            ss:= sf1+';;;отключен признак клонирования в Grossbee';
          except
            on E: Exception do begin
              with gbIBSw.Transaction do if InTransaction then Rollback;
//              ss:= sf1+';;;!!! ошибка отключения признака клонирования в Grossbee';
//              prMessageLOGS(nmProc+': '+ss+#13#10+CutEMess(E.Message), 'import');
           end;
          end;
          gbIBSw.Close;
        end; // if (lstSQL.Count>0)

        if (i>0) then begin // собираем строки для сообщения об архивировании сотрудников
          sFirm:= 'в архив: '+fNameFrom+' - ';
          if (i=1) then s:= 'сотрудника с логином '+s else s:= 'сотрудников с логинами '+s;
          lst.Add(sFirm+s);
        end;

        SetCellStrValue(WorkSheet, CellSigns[7], iLine, ss); // пишем результат по строке
        prMessageLOGS(nmProc+': '+ss, 'import_test', False); // логирование переноса заказов

        CheckStopExecute(pUserID, ThreadData);
        SetExecutePercent(pUserID, ThreadData, Percent);
      except
        on E: EBOBError do raise EBOBError.Create(E.Message);
        on E: Exception do begin
          prMessageLOGS(nmProc+': строка '+IntToStr(iLine)+' - '+E.Message, 'import', False);
          SetCellStrValue(WorkSheet, CellSigns[7], iLine, E.Message); // пишем текст ошибки
        end;
      end; // for  2 to rows

      rows:= rows+2;
      for iLine:= 0 to lst.Count-1 do // пишем сообщения об архивировании сотрудников
        SetCellStrValue(WorkSheet, CellSigns[1], rows+iLine, lst[iLine]);


    finally
      prFreeIBSQL(ordIBS);
      cntsORD.SetFreeCnt(ordIBD, True);
      prFreeIBSQL(gbIBS);
      cntsGRB.SetFreeCnt(gbIBD, True);
      prFreeIBSQL(gbIBSw);
      cntsGRB.SetFreeCnt(gbIBDw, True);
      prFree(lstSQL);
      prFree(lst);
    end;
  finally
    SaveAndCloseWorkBook(XL, WorkBook);
  end;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do begin
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import');
      raise Exception.Create(E.Message);
    end;
  end;
end;
*)
//==================== загрузка/проверка параметров нескольких двигателей из TDT
function CheckEnginesFromTDT(var engCodes: Tai; pUserID: integer; sys: Integer=0): string;
// предназначена для добавления/редактирования двигателей модели
// на входе в engCodes коды двигателей TecDoc, на выходе - коды ORD
const nmProc = 'CheckEnginesFromTDT'; // имя процедуры/функции
var i, ii, iErr, iAdd, iUpd, engORD, engTD, mfTD, mfORD, kodORD: integer;
    TdtIBD: TIBDatabase;
    TdtIBS: TIBSQL;
    KeyTabs: TarKeyTabs; // array of TKeyTab
    s, nf, pMark: string;
    eps: TEngParams;
    eng: TEngine;
begin
  TdtIBD:= nil;
  eps:= nil;
  iErr:= 0;
  iAdd:= 0;
  iUpd:= 0;
  if (Length(engCodes)<1) then Exit;
  SetLength(KeyTabs, 0);
  try
    if (pUserID<1) then raise Exception.Create(MessText(mtkNotParams));
    engTD:= 155; // ENGINES
    s:= IntToStr(engTD);
    eps:= TEngParams.Create;
    with Cache.FDCA do try // заполняем имена полей для поиска соответствий
      TdtIBD:= cntsTDT.GetFreeCnt;
      TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);

      SetLength(KeyTabs, 10);
      FillKeTabRecNf(0, 'ENG_DESIGN'    , KeyTabs);  // Исполнение двигателя (KT 96)       (TYPEDIR=13)
      FillKeTabRecNf(1, 'ENG_FUEL_TYPE' , KeyTabs);  // Вид топлива (KT 88)                (TYPEDIR=12)
      FillKeTabRecNf(2, 'ENG_FUEL_MIXT' , KeyTabs);  // Подготовка топливной смеси (KT 97) (TYPEDIR=5)
      FillKeTabRecNf(3, 'ENG_ASPIR'     , KeyTabs);  // Подача воздуха (KT 99)             (TYPEDIR=14)
      FillKeTabRecNf(4, 'ENG_TYPE'      , KeyTabs);  // Вид двигателя (KT 80)              (TYPEDIR=3)
      FillKeTabRecNf(5, 'ENG_NORM'      , KeyTabs);  // Норма выхлопных газов (KT 63)      (TYPEDIR=15)
      FillKeTabRecNf(6, 'ENG_CYL_DESIGN', KeyTabs);  // Форма головки цилиндра (KT 79)     (TYPEDIR=16)
      FillKeTabRecNf(7, 'ENG_MANAG'     , KeyTabs);  // Управление двигателем (KT 77)      (TYPEDIR=17)
      FillKeTabRecNf(8, 'ENG_VAL_CNT'   , KeyTabs);  // Привод клапана (KT 78)             (TYPEDIR=18)
      FillKeTabRecNf(9, 'ENG_COOL_TYPE' , KeyTabs);  // Тип системы охлаждения (KT 76)     (TYPEDIR=19)
      FillarKeyTabsFromTDT(KeyTabs, engTD, TdtIBS); // вынимаем в KeyTabs нужные списки TDT

      TdtIBS.SQL.Clear;
      TdtIBS.SQL.Add('select ENG_MF_ID, ENG_MARK, ENG_MOD_FR, ENG_MOD_TO,');
      TdtIBS.SQL.Add(' ENG_KW_FR, ENG_KW_TO, ENG_HP_FR, ENG_HP_TO, ENG_VAL, ENG_CYL,');
      TdtIBS.SQL.Add(' ENG_COMP_FR, ENG_COMP_TO, ENG_CC_TEC_FR, ENG_CC_TEC_TO,');
      TdtIBS.SQL.Add(' ENG_RPM_KW_FR, ENG_RPM_KW_TO, ENG_RPM_TORQ_FR, ENG_RPM_TORQ_TO,');
      for i:= Low(KeyTabs) to High(KeyTabs) do begin
        nf:= KeyTabs[i].FieldNameTDT;
        TdtIBS.SQL.Add(' (select key_to from get_key_code ('+s+', '+nf+', "'+nf+'")) '+nf+',');
      end;
      TdtIBS.SQL.Add(' ENG_CRANK, ENG_BORE, ENG_STROKE, ENG_SALES_DESC from ENGINES');
      TdtIBS.SQL.Add(' where ENG_ID=:eng');

      for i:= Low(engCodes) to High(engCodes) do try
        engTD:= engCodes[i];
        engORD:= 0;
        with TdtIBS.Transaction do if not InTransaction then StartTransaction;
        TdtIBS.ParamByName('eng').AsInteger:= engTD;
        try
          TdtIBS.ExecQuery;
          if (TdtIBS.Bof and TdtIBS.Eof) then raise Exception.Create('не найден двигатель в TDT');
          mfTD:= TdtIBS.FieldByName('ENG_MF_ID').AsInteger;
          mfORD:= Manufacturers.GetManufIDByTDcode(mfTD); // ищем произв.
          if (mfORD<1) then Exception.Create('не найден производитель в ORD, mfTD='+IntToStr(mfTD));
          pMark:= TdtIBS.FieldByName('ENG_MARK').AsString;
          with eps do begin
            Clear;
            pYearFrom   := TdtIBS.FieldByName('ENG_MOD_FR').AsInteger div 100; // Год выпуска от
            pMonFrom    := TdtIBS.FieldByName('ENG_MOD_FR').AsInteger mod 100; // Месяц выпуска от
            pYearTo     := TdtIBS.FieldByName('ENG_MOD_TO').AsInteger div 100; // Год выпуска до
            pMonTo      := TdtIBS.FieldByName('ENG_MOD_TO').AsInteger mod 100; // Месяц выпуска до
            pCompFrom   := TdtIBS.FieldByName('ENG_COMP_FR').AsInteger;        // Компрессор * 100 от
            pCompTo     := TdtIBS.FieldByName('ENG_COMP_TO').AsInteger;        // Компрессор * 100 до
            pRPMtorqFrom:= TdtIBS.FieldByName('ENG_RPM_TORQ_FR').AsInteger;    // Момент вращения (Nm) при [об/мин] от
            pRPMtorqTo  := TdtIBS.FieldByName('ENG_RPM_TORQ_TO').AsInteger;    // Момент вращения (Nm) при [об/мин] до
            pBore       := TdtIBS.FieldByName('ENG_BORE').AsInteger;           // Расточка * 1000
            pStroke     := TdtIBS.FieldByName('ENG_STROKE').AsInteger;         // Ход поршня * 1000
            pKWfrom     := TdtIBS.FieldByName('ENG_KW_FR').AsInteger;          // Мощность кВт от
            pRPMKWfrom  := TdtIBS.FieldByName('ENG_RPM_KW_FR').AsInteger;      // при [об/мин] от
            pKWto       := TdtIBS.FieldByName('ENG_KW_TO').AsInteger;          // Мощность кВт до
            pRPMKWto    := TdtIBS.FieldByName('ENG_RPM_KW_TO').AsInteger;      // при [об/мин] до
            pHPfrom     := TdtIBS.FieldByName('ENG_HP_FR').AsInteger;          // Мощность ЛС от
            pHPto       := TdtIBS.FieldByName('ENG_HP_TO').AsInteger;          // Мощность ЛС до
            pCCtecFrom  := TdtIBS.FieldByName('ENG_CC_TEC_FR').AsInteger;      // Тех.обьем в куб.см. от
            pCCtecTo    := TdtIBS.FieldByName('ENG_CC_TEC_TO').AsInteger;      // Тех.обьем в куб.см. до
            pVal        := TdtIBS.FieldByName('ENG_VAL').AsInteger;            // Количество клапанов
            pCyl        := TdtIBS.FieldByName('ENG_CYL').AsInteger;            // Количество цилиндров
            pCrank      := TdtIBS.FieldByName('ENG_CRANK').AsInteger;          // Кол-во подшипников коленвала
            pSalesDesc  := TdtIBS.FieldByName('ENG_SALES_DESC').AsString;      // Обозначение продажи
            for ii:= Low(KeyTabs) to High(KeyTabs) do begin // Исполнение двигателя .. Тип системы охлаждения
              kodORD:= GetInfoCode(TdtIBS.FieldByName(KeyTabs[ii].FieldNameTDT).AsInteger, pUserID, KeyTabs[ii]);
              if kodORD<1 then Continue;
              case ii of
                0: pDesign     := kodORD;     // Код, Исполнение двигателя (KT 96)       (TYPEDIR=13)
                1: pFuelType   := kodORD;     // Код, Вид топлива (KT 88)                (TYPEDIR=12)
                2: pFuelMixt   := kodORD;     // Код, Подготовка топливной смеси (KT 97) (TYPEDIR=5)
                3: pAspir      := kodORD;     // Код, Подача воздуха (KT 99)             (TYPEDIR=14)
                4: pType       := kodORD;     // Код, Вид двигателя (KT 80)              (TYPEDIR=3)
                5: pNorm       := kodORD;     // Код, Норма выхлопных газов (KT 63)      (TYPEDIR=15)
                6: pCylDesign  := kodORD;     // Код, Форма головки цилиндра (KT 79)     (TYPEDIR=16)
                7: pManag      := kodORD;     // Код, Управление двигателем (KT 77)      (TYPEDIR=17)
                8: pValCnt     := kodORD;     // Код, Привод клапана (KT 78)             (TYPEDIR=18)
                9: pCoolType   := kodORD;     // Код, Тип системы охлаждения (KT 76)     (TYPEDIR=19)
              end; // case
            end; // for ii
          end; // with eps
          s:= '';

          if Engines.FindEngineByTDcode(engTD, eng) then engORD:= eng.ID;
          if (engORD<1) then begin
            s:= Engines.AddEngine(engORD, sys, engTD, mfORD, pUserID, pMark, eps);
            if (s='') then Inc(iAdd) else raise Exception.Create(s);
          end else begin
            s:= Engines.EditEngine(engORD, engTD, mfORD, sys, pUserID, pMark, eps);
            if (s='') then Inc(iUpd) else raise Exception.Create(s);
          end;

        finally
          TdtIBS.Close;
          engCodes[i]:= engORD;
        end;
        TestCssStopException;
      except
        on E: Exception do begin
          inc(iErr);
          with TdtIBS.Transaction do if InTransaction then Rollback;
          prMessageLOGS(nmProc+': код='+IntToStr(engTD)+' - '+E.Message, 'import', False);
        end;
      end; // for
    except
      on E: Exception do begin
        E.Message:= nmProc+': '+E.Message;
        prMessageLOGS(E.Message, 'import', False);
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    prFreeIBSQL(TdtIBS);
    cntsTDT.SetFreeCnt(TdtIBD);
    ClearArKeyTabs(KeyTabs);
    prFree(eps);
  end; // with Cache.FDCA
  s:= '';
  if (iAdd>0) then s:= s+' добавлено: '+IntToStr(iAdd);
  if (iUpd>0) then s:= s+' проверено: '+IntToStr(iUpd);
  if (iErr>0) then s:= s+' ошибок: '+IntToStr(iErr);
  if (s<>'') then prMessageLOGS(nmProc+': '+s, 'import', False);
end;
//====================== пакетная загрузка/проверка параметров двигателей из TDT
function CheckEnginesFromTDT(pUserID: integer): string;
const nmProc = 'CheckEnginesFromTDT'; // имя процедуры/функции
var i: integer;
    engCodes: Tai;
begin
  with Cache.FDCA.Engines do try try
    SetLength(engCodes, ItemsList.Count);
    for i:= 0 to High(engCodes) do engCodes[i]:= TEngine(ItemsList[i]).TDCode;
    CheckEnginesFromTDT(engCodes, pUserID);
  except
    on E: Exception do begin
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import', False);
      raise Exception.Create(E.Message);
    end;
  end;
  finally
    SetLength(engCodes, 0);
  end;
end;

//******************************************************************************
//                 загрузка информации по товару
//******************************************************************************
//========================================== имена файлов рисунков товара из TDT
function LoadWareGraFileNamesFromTDT(WareID, UserID: Integer): String;
const nmProc = 'LoadWareGraFileNamesFromTDT'; // имя процедуры/функции
var TdtIBD: TIBDatabase;
    TdtIBS: TIBSQL;
    headID, pSupID, pType, kt, ke, fID, fCount, res: integer;
    s: string;
    Ware: TWareInfo;
    arTDfiles: TarWareFileOpts;
begin
  Result:= '';
//  TdtIBD:= nil;
  TdtIBS:= nil;
  kt:= 141;
  pType:= 0;
  fCount:= 0;
  SetLength(arTDfiles, 10);
  with Cache do try
    Ware:= GetWare(WareID);
    with Ware do if (ArticleTD='') or (ArtSupTD<1) then
      raise EBOBError.Create(MessText(mtkNotEnoughParams))
    else begin
      s:= ArticleTD;
      pSupID:= ArtSupTD; // SupID TecDoc (DS_MF_ID !!!)
    end;

    TdtIBD:= cntsTDT.GetFreeCnt;
    try
      TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
      TdtIBS.SQL.Text:= 'select rHeadID, rHeadName, rFileName, rSupID'+
        ' from GetArtGraFileNames(:aArticle, '+IntToStr(pSupID)+')';
      TdtIBS.ParamByName('aArticle').AsString:= s;
      TdtIBS.ExecQuery;
      while not TdtIBS.Eof do begin
        ke:= TdtIBS.FieldByName('rHeadID').AsInteger;
        s:= TdtIBS.FieldByName('rHeadName').AsString;
        with FDCA.TypesInfoModel do // ищем заголовок в кеше по кодам TDT
          if not FindInfoItemByTDcodes(headID, pType, ke, kt) then begin
            // добавляем новый заголовок в кеш и в базу (pType - из FindInfoItemByTDcodes)
            s:= AddInfoModelItem(headID, pType, ke, kt, s, UserID);
            if (s<>'') then raise Exception.Create('AddInfoModelItem error: '+s);
          end;

        s:= TdtIBS.FieldByName('rFileName').AsString;    // имя файла с расширением
        pSupID:= TdtIBS.FieldByName('rSupID').AsInteger; // SupID TecDoc (DS_ID !!!)
        fID:= SearchWareFileBySupAndName(pSupID, s); // ищем код файла
        if fID<1 then begin // не нашли - добавляем
          s:= AddWareFile(fID, s, pSupID, headID, UserID, soTecDocBatch);
          if (s<>'') then raise Exception.Create('AddWareFile error: '+s);
        end;

        if fCount>High(arTDfiles) then setLength(arTDfiles, fCount+10);
        arTDfiles[fCount].SupID   := fID; // здесь - код файла
        arTDfiles[fCount].FileName:= TdtIBS.FieldByName('rFileName').AsString;
        inc(fCount);

        if (fID>0) then begin
          res:= resAdded; // добавляем в кеш линк товара с файлом
          s:= CheckWareFileLink(res, fID, WareID, soTecDocBatch, UserID);
          if (res=resError) then prMessageLOGS(nmProc+': add WareFileLink error('+
                                 IntToStr(WareID)+'): '+s, 'import', False);
        end;
        TestCssStopException;
        TdtIBS.Next;
      end;
    finally
      prFreeIBSQL(TdtIBS);
      cntsTDT.SetFreeCnt(TdtIBD);
    end;

    for kt:= Ware.FileLinks.ListLinks.Count-1 downto 0 do begin
      fID:= GetLinkID(Ware.FileLinks.ListLinks[kt]);   // ID файла
      pType:= 0; // здесь - признак наличия
      for ke:= 0 to fCount-1 do if arTDfiles[ke].SupID=fID then begin
        pType:= 1;
        break;
      end; // for ke:= 0 to fCount-1
      if pType=1 then Continue; // если нашли
      if GetLinkSrc(Ware.FileLinks.ListLinks[kt])<>soTecDocBatch then Continue; // если не TD

      res:= resDeleted; // удаляем из кеша линк товара с файлом
      s:= CheckWareFileLink(res, fID, WareID, soTecDocBatch);
      if (res=resError) then prMessageLOGS(nmProc+': del WareFileLink error('+IntToStr(WareID)+'): '+s, 'import', False);
    end; // for kt:= 0 to Ware.FileLinks.ListLinks.Count-1

if (GetIniParamInt(nmIniFileBOB, 'reports', 'SkipFotoToGB', 0)=0) then
    prGFtoGB(WareID);
  except
    on E: EBOBError do Result:= nmProc+': '+E.Message;
    on E: Exception do begin
      Result:= nmProc+': load error';
      prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): '+E.Message, 'import', False);
    end;
  end;
  SetLength(arTDfiles, 0);
end;
//============================================= доп.инф. по товару и ноде из TDT
procedure LoadWareNodeInfoTextFromTDT(WareID, pSupMFTD, nodeID, UserID, pSrc, sysID: Integer;
         pArticleTD: String; TdtIBS, ordIBS, ordIBSr: TIBSQL; ThreadData: TThreadData=nil);
const nmProc = 'LoadWareNodeInfoTextFromTDT'; // имя процедуры/функции
var j, gaID, pType, kt, ke, txtCount: integer;
    s, tm, ss, skod: string;
    arTXT: TarTextInfo;
begin
  kt:= 72;
  pType:= 0;
  gaID:= 0;
  txtCount:= 0;
  setLength(arTXT, 10);
  try try

    with Cache.FDCA.AutoTreeNodesSys[sysID][nodeID] do if IsGATD then gaID:= SubCode;
    if (gaID<1) then Exit;

    with ordIBS.Transaction do if not InTransaction then StartTransaction;
    if ordIBS.SQL.Text='' then
      ordIBS.SQL.Text:= 'select linkID, errLink from AddNodeWareTextLink_new('+
        ':NodeID, :WareID, :typeID, :pSupMFTD, :tmTD, :pText, :UserID, :pSrc)';
    ordIBS.ParamByName('NodeID').AsInteger:= NodeID;
    ordIBS.ParamByName('WareID').AsInteger:= WareID;
    ordIBS.ParamByName('pSupMFTD').AsInteger:= pSupMFTD;
    ordIBS.ParamByName('UserID').AsInteger:= UserID;
    ordIBS.ParamByName('pSrc').AsInteger:= pSrc;

    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    if (TdtIBS.SQL.Text='') then
      TdtIBS.SQL.Text:= 'select rINFTYPE, rTM, rTXT, rTYPEname'+
        ' from GetArtTexts(:xart, :pSupMFTD)';
    TdtIBS.ParamByName('xart').AsString:= pArticleTD;
    TdtIBS.ParamByName('pSupMFTD').AsInteger:= pSupMFTD;
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin
      ke:= TdtIBS.FieldByName('rINFTYPE').AsInteger;
      s:= TdtIBS.FieldByName('rTYPEname').AsString;
      with Cache.FDCA do begin       // ищем вид информации в кеше по кодам TDT
        pType:= 11;
        if not TypesInfoModel.FindInfoItemByTDcodes(j, pType, ke, kt) then begin
          // добавляем новый вид информации в кеш и в базу (pType - из FindInfoItemByTDcodes)
          ss:= TypesInfoModel.AddInfoModelItem(j, pType, ke, kt, s, UserID);
          if (ss<>'') then raise Exception.Create('add error: '+ss);
        end;
      end;
      pType:= j;

      while not TdtIBS.Eof and (ke=TdtIBS.FieldByName('rINFTYPE').AsInteger) do begin
        tm:= TdtIBS.FieldByName('rTM').AsString;
        s:= '';                // собираем строку текстового модуля
        while not TdtIBS.Eof and (ke=TdtIBS.FieldByName('rINFTYPE').AsInteger)
          and (tm=TdtIBS.FieldByName('rTM').AsString) do begin
          s:= s+' '+TdtIBS.FieldByName('rTXT').AsString;
          CheckStopExecute(UserID, ThreadData);
          TdtIBS.Next;
        end;
        s:= trim(s);
//        s:= CheckTextFirstUpAndSpaces(s); // проверка заглавной буквы и пробелов текста
        if (txtCount>High(arTXT)) then setLength(arTXT, txtCount+10);
        arTXT[txtCount].ldmw    := 0; // эдесь - код линка текста
        arTXT[txtCount].supTD   := 0; // эдесь - признак наличия в нашей базе
        arTXT[txtCount].infotype:= pType;
        arTXT[txtCount].tmTD    := tm;
        arTXT[txtCount].text    := s;
        arTXT[txtCount].search  := AnsiUpperCase(StringReplace(s, ' ', '', [rfReplaceAll]));
        try                           // добавляем в базу
          with ordIBS.Transaction do if not InTransaction then StartTransaction;
          ordIBS.ParamByName('typeID').AsInteger:= pType;
          ordIBS.ParamByName('tmTD').AsString:= tm;
          ordIBS.ParamByName('pText').AsString:= s;
          ordIBS.ExecQuery;
          if (ordIBS.Eof and ordIBS.Bof) or (ordIBS.Fields[0].AsInteger<1) then
            raise Exception.Create('error add text link  Node='+IntToStr(NodeID)+' tmTD='+tm+' txt='+s);

          arTXT[txtCount].ldmw:= ordIBS.Fields[0].AsInteger; // код линка текста
          with ordIBS.Transaction do if (ordIBS.Fields[1].AsInteger=0) then Commit
          else Rollback; // если линк уже был в базе
        except
          on E: Exception do begin
            ordIBS.Transaction.Rollback;
            prMessageLOGS(nmProc+'('+IntToStr(WareID)+'): '+E.Message, 'import', False);
          end;
        end;
        inc(txtCount);
        ordIBS.Close;
      end; // while ... and (ke=
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
    end;

    ss:= '';         // доп.инф. по товару и ноде из ORD (источник - TecDoc)
    with ordIBSr.Transaction do if not InTransaction then StartTransaction;
    if ordIBSr.SQL.Text='' then
      ordIBSr.SQL.Text:= 'select LWNTCODE, LWNTinfotype, WITTMTD, ITSEARCH'+
        ' from LinkWareNodeText left join WareInfoTexts on WITCODE=LWNTWIT'+
        ' left join INFOTEXTS on ITCODE=WITTEXTCODE'+
        ' where LWNTnodeID=:NodeID and LWNTwareID=:WareID and WITSUPTD=:SUPTD'+
        ' and LWNTSRCLECODE in ('+IntToStr(soTecDocBatch)+', '+
        IntToStr(soTDparts)+', '+IntToStr(soTDsupersed)+')';
    ordIBSr.ParamByName('NodeID').AsInteger:= NodeID;
    ordIBSr.ParamByName('WareID').AsInteger:= WareID;
    ordIBSr.ParamByName('SUPTD').AsInteger:= pSupMFTD;
    ordIBSr.ExecQuery;
    while not ordIBSr.Eof do begin  // ищем связки, кот.ушли из TD
      kt   := ordIBSr.FieldByName('LWNTCODE').AsInteger;
      pType:= ordIBSr.FieldByName('LWNTinfotype').AsInteger;
      tm   := ordIBSr.FieldByName('WITTMTD').AsString;
      s    := ordIBSr.FieldByName('ITSEARCH').AsString;
      skod := ordIBSr.FieldByName('LWNTCODE').AsString;
      for j:= 0 to txtCount-1 do if (arTXT[j].ldmw=kt) or
        ((arTXT[j].infotype=pType) and (arTXT[j].tmTD=tm) and (arTXT[j].search=s)) then begin
          skod:= '';           // если есть такой текст в TD - очищаем skod
          break;
        end;
      if (skod<>'') then ss:= ss+fnIfStr(ss='', '', ',')+skod; // собираем строку кодов ненайденных связок
      CheckStopExecute(UserID, ThreadData);
      ordIBSr.Next;
    end;
    ordIBSr.Close;

    if (ss<>'') then try  // если нашли связки, кот.ушли из TD - удаляем
//      fnSetTransParams(ordIBSr.Transaction, tpWrite, True);
      try
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.SQL.Text:= 'delete from LinkWareNodeText where LWNTCODE in ('+ss+')';
        ordIBS.ExecQuery;
        ordIBS.Transaction.Commit;
      except
        on E: Exception do begin
          ordIBS.Transaction.Rollback;
          prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+')(del): '+E.Message, 'import', False);
        end;
      end;
    finally
      ordIBS.Close;
      ordIBS.SQL.Text:= '';
//      fnSetTransParams(ordIBSr.Transaction, tpRead, True);
    end;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error WareNode texts: '+E.Message, 'import', False);
  end;
  finally
    with ordIBS.Transaction do if InTransaction then Rollback;
    ordIBS.Close;
    TdtIBS.Close;
    ordIBSr.Close;
    setLength(arTXT, 0);
  end;
end;
//================== загрузка номеров EAN и параметров упаковки товара из TecDoc
procedure LoadWareEANandPackFromTDT(TdtIBS, ordIBS, ordIBSr: TIBSQL;
          WareID, pSupMFTD, UserID: Integer; pArticleTD: String; ThreadData: TThreadData=nil);
const nmProc = 'LoadWareEANandPackFromTDT'; // имя процедуры/функции
var i, j, UnitOrd, CountOrd, UnitTdt, CountTdt: Integer;
    s: String;
    lstEANord, lstEANtdt: TStringList;
begin
  UnitOrd:= 0;
  CountOrd:= 0;
  UnitTdt:= 0;
  CountTdt:= 0;
  lstEANord:= TStringList.Create;
  lstEANtdt:= TStringList.Create;
  try
    ordIBSr.Close;
    with ordIBSr.Transaction do if not InTransaction then StartTransaction;
    ordIBSr.SQL.Text:= 'select weanNumber ean, iif(lweanWRONG="T", 1, 0) par1, 0 par2'+
      ' from LinkWareEAN left join WareEANnumbers on weanCODE=lweanEAN'+
      ' where lweanWare='+IntToStr(WareID)+' and lweanSRCCODE in ('+
      IntToStr(soTecDocBatch)+', '+IntToStr(soTDparts)+', '+IntToStr(soTDsupersed)+')'+
      ' union select "" ean, woPackUnit par1, woPackCount par2'+
      ' from WAREOPTIONS where WOWARECODE='+IntToStr(WareID);
    ordIBSr.ExecQuery;                  // параметры товара из ORD
    while not ordIBSr.Eof do begin
      s:= ordIBSr.FieldByName('ean').AsString;
      if (s='') then begin
        UnitOrd:= ordIBSr.FieldByName('par1').AsInteger;  // Упаковочная единица
        CountOrd:= ordIBSr.FieldByName('par2').AsInteger; // Количество в упаковке
      end else begin
        j:= ordIBSr.FieldByName('par1').AsInteger;
        lstEANord.AddObject(s, Pointer(j));               // номер EAN, Wrong
      end;

      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      ordIBSr.Next;
    end;
    ordIBSr.Close;

    TdtIBS.Close;
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    TdtIBS.SQL.Text:= 'select AS_PACK, AS_PART, ae_ean_nr'+
      ' from ARTICLES left join data_suppliers on ds_id=art_sup_id'+
      ' left join ARTICLE_SPECIFIC on AS_ART_ID=ART_ID'+
      ' left join article_EAN on ae_art_ID=art_ID'+
      ' where ART_NR=:art_nr and ds_mf_id='+IntToStr(pSupMFTD);
    TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
    TdtIBS.ExecQuery;              // параметры товара из TDT
    while not TdtIBS.Eof do begin
      if (lstEANtdt.Count=0) then begin // 1-я строка
        UnitTdt:= TdtIBS.FieldByName('AS_PACK').AsInteger;  // Упаковочная единица
        CountTdt:= TdtIBS.FieldByName('AS_PART').AsInteger; // Количество в упаковке
      end;
      s:= TdtIBS.FieldByName('ae_ean_nr').AsString;         // номер EAN
      if (s<>'') then lstEANtdt.Add(s);

      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      TdtIBS.Next;
    end;
    TdtIBS.Close;

    for i:= lstEANtdt.Count-1 downto 0 do begin // идем по номерам TDT
      j:= lstEANord.IndexOf(lstEANtdt[i]); // ищем в ORD
      if (j<0) then Continue; // не нашли - оставляем
      lstEANtdt.Delete(i);
      lstEANord.Delete(j);
    end; // остались строки для добавления

    for j:= lstEANord.Count-1 downto 0 do begin // идем по оставшимся номерам ORD
      i:= Integer(lstEANord.Objects[j]); // Wrong
      if (i=1) then lstEANord.Delete(j); // уже помечена, как неправильная
    end; // остались строки для пометки, как неправильных

//--------------------------------------------------- меняем параметров упаковки
    if (UnitOrd<>UnitTdt) or (CountOrd<>CountTdt) then try
      ordIBS.Close;
      with ordIBS.Transaction do if not InTransaction then StartTransaction;
      ordIBS.SQL.Text:= 'update WAREOPTIONS set woPackUnit='+IntToStr(UnitTdt)+
        ', woPackCount='+IntToStr(CountTdt)+' where WOWARECODE='+IntToStr(WareID);
      ordIBS.ExecQuery;
      ordIBS.Transaction.Commit;
    except
      on E: Exception do begin
        ordIBS.Transaction.Rollback;
        prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error set Pack='+
          IntToStr(UnitTdt)+', kolvo='+IntToStr(CountTdt)+': '+E.Message, 'import', False);
      end;
    end;

    if (lstEANord.Count<1) and (lstEANtdt.Count<1) then Exit; // нет изменений EAN

//--------------------------------------------------- отрабатываем изменения EAN
    ordIBS.Close;
    with ordIBS.Transaction do if not InTransaction then StartTransaction;
    ordIBS.SQL.Text:= 'select * from CheckWareEANlink (:res, '+IntToStr(WareID)+
                      ', :EAN, '+IntToStr(soTecDocBatch)+', '+IntToStr(UserID)+')';
    if (lstEANord.Count>0) then begin // строки для пометки, как неправильных
      ordIBS.ParamByName('res').AsInteger:= resWrong;
      for j:= 0 to lstEANord.Count-1 do try
        ordIBS.Close;
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.ParamByName('EAN').AsString:= lstEANord[j];
        ordIBS.ExecQuery;
        if (ordIBS.FieldByName('ResCode').AsInteger=resWrong) then s:= ''
        else s:= ordIBS.FieldByName('ResMess').AsString;
        ordIBS.Transaction.Commit;
        if (s<>'') then prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
                        '): set Wrong EAN '+lstEANord[j]+': '+s, 'import', False);
      except
        on E: Exception do begin
          ordIBS.Transaction.Rollback;
          prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
            '): error Wrong EAN '+lstEANord[j]+': '+E.Message, 'import', False);
        end;
      end; // for
    end; // if (lstEANord.Count>0)
    ordIBS.Close;
    if (lstEANtdt.Count>0) then begin // строки для добавления
      ordIBS.ParamByName('res').AsInteger:= resAdded;
      for j:= 0 to lstEANtdt.Count-1 do try  // строки для пометки, как неправильных
        ordIBS.Close;
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.ParamByName('EAN').AsString:= lstEANtdt[j];
        ordIBS.ExecQuery;
        if (ordIBS.FieldByName('ResCode').AsInteger=resAdded) then s:= ''
        else s:= ordIBS.FieldByName('ResMess').AsString;
        ordIBS.Transaction.Commit;
        if (s<>'') then prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
                        '): Add EAN '+lstEANtdt[j]+': '+s, 'import', False);
      except
        on E: Exception do begin
          ordIBS.Transaction.Rollback;
          prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
            '): error Add EAN '+lstEANtdt[j]+': '+E.Message, 'import', False);
        end;
      end; // for
    end; // if (lstEANtdt.Count>0)
  finally
    TdtIBS.Close;
    ordIBS.Close;
    ordIBSr.Close;
    prFree(lstEANord);
    prFree(lstEANtdt);
  end;
end;
//========================================== загрузка критериев товара из TecDoc
procedure LoadWareCrisFromTDT(WareID, pSupMFTD, UserID: Integer; pArticleTD: String; ThreadData: TThreadData=nil);
const nmProc = 'LoadWareCrisFromTDT'; // имя процедуры/функции
// TdtIBS, ordIBS, ordIBSr передаются для увеличения скорости обработки
var j, pCriTD: Integer;
    s, criName, criValue, criValueUp: String;
    flNotEx: Boolean;
    ArCris: TarCriInfo;
    TdtIBD, ordIBD: TIBDatabase;
    TdtIBS, ordIBS: TIBSQL;
begin
  SetLength(ArCris, 100);
  j:= 0;
  TdtIBD:= nil;
  ordIBD:= nil;
  TdtIBS:= nil;
  ordIBS:= nil;
  try try
    TdtIBD:= cntsTDT.GetFreeCnt;
    ordIBD:= cntsORD.GetFreeCnt;

    ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, True);
    ordIBS.SQL.Text:= 'select LWCVCODE, WCRITDCODE, WCVSVALUE from LINKWARECRIVALUES'+
      ' left join WARECRIVALUES on WCVSCODE=LWCVWCVSCODE'+
      ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE'+
      ' where LWCVWARECODE='+IntToStr(WareID)+' and LWCVWRONG="F"'+
      ' and LWCVSRCLECODE in ('+IntToStr(soTecDocBatch)+', '+
      IntToStr(soTDparts)+', '+IntToStr(soTDsupersed)+')';
    ordIBS.ExecQuery;
    while not ordIBS.Eof do begin // критерии товара из ORD
      if Length(ArCris)<(j+1) then SetLength(ArCris, j+100);
      ArCris[j].ldmw:=  ordIBS.FieldByName('LWCVCODE').AsInteger; // здесь - код связки
      ArCris[j].CRITD:= ordIBS.FieldByName('WCRITDCODE').AsInteger;
      ArCris[j].ValueUp:= AnsiUpperCase(ordIBS.FieldByName('WCVSVALUE').AsString);
      inc(j);
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      ordIBS.Next;
    end;
    ordIBS.Close;
    if Length(ArCris)>j then SetLength(ArCris, j);

    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, True);
    TdtIBS.SQL.Text:= 'select distinct xCri_ID, xCri_desc, xCri_val'+
      ' from GETARTICLECriteries(:art_nr, '+IntToStr(pSupMFTD)+')';
    TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin
      pCriTD:= TdtIBS.FieldByName('xCri_ID').AsInteger;
      criName:= TdtIBS.FieldByName('xCri_desc').AsString;
      criValue:= TdtIBS.FieldByName('xCri_val').AsString; // значение критерия
      criValueUp:= AnsiUpperCase(criValue);
      flNotEx:= True;
      for j:= Low(ArCris) to High(ArCris) do
        if (ArCris[j].CRITD=pCriTD) and (ArCris[j].ValueUp=criValueUp) then begin
          flNotEx:= False;
          ArCris[j].ldmw:= 0; // обнуляем код связки
          break;
        end;

      if flNotEx then begin
        s:= Cache.CheckWareCriValueLink(WareID, pCriTD, UserID, soTecDocBatch, CriName, criValue);
        if (s<>'') and (s<>'exists') then
          prMessageLOGS(nmProc+': error add Cri link(ware='+IntToStr(wareID)+'): '+s, 'import', False);
      end;
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      TdtIBS.Next;
    end;

    s:= ''; // собираем коды линков, кот.ушли из TD
    for j:= Low(ArCris) to High(ArCris) do
      if (ArCris[j].ldmw>0) then s:= s+fnIfStr(s='', '', ',')+IntToStr(ArCris[j].ldmw);

    if (s<>'') then try
      fnSetTransParams(ordIBS.Transaction, tpWrite, True);
      ordIBS.SQL.Text:= 'delete from LINKWARECRIVALUES where LWCVCODE in ('+s+')';
      ordIBS.ExecQuery;
      ordIBS.Transaction.Commit;
    except
      on E: Exception do begin
        ordIBS.Transaction.Rollback;
        prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error del old criteries: '+E.Message, 'import', False);
      end;
    end;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error add criteries: '+E.Message, 'import', False);
  end;
  finally
    prFreeIBSQL(ordIBS);
    cntsORD.SetFreeCnt(ordIBD);
    prFreeIBSQL(TdtIBS);
    cntsTDT.SetFreeCnt(TdtIBD);
    SetLength(ArCris, 0);
  end;
end;
//============================== загрузка связок товара из TDT по 1-му источнику
procedure LoadLinkListsFromTDT(TdtIBS: TIBSQL; WareID, UserID, pSrc, sysID: Integer;
          var arInfo: TArLinkInfo; var ii, addLink3: Integer; ThreadData: TThreadData=nil);
const nmProc = 'LoadLinkListsFromTDT'; // имя процедуры/функции
var nodeTD, pNodeORD, modTD, pModORD, mlTD, pMlORD, mfTD, pMfORD, res, i, j, iLinkORD, iLagt: Integer;
    s: String;
    pNodLinks: TNodeLinks; // для удобства
    DupNodeCodes: Tai;
    LocalTime: TDateTime;
    flSleep: Boolean;
begin
  LocalTime:= Now;
  flSleep:= not flDebug and fnGetActionTimeEnable(caeOnlyWorkTime);
  with TdtIBS.Transaction do if not InTransaction then StartTransaction;
  TdtIBS.ExecQuery;
  with Cache.FDCA do try
    while not TdtIBS.Eof do begin
      nodeTD:= TdtIBS.FieldByName('xGA').AsInteger;  // код TD ноды GA
      pNodeORD:= AutoTreeNodesSys[sysID].GetMainNodeIDByTDcode(nodeTD); // все связки 3 - на главную ноду
  //      if (pNodeORD<1) or not AutoTreeNodesSys[sysID][pNodeORD].Visible then begin
      if (pNodeORD<1) then begin // видимость нод не учитываем !!! если не нашли - прокручиваем
        prMessageLOGS(nmProc+': not found nodeTD= '+IntToStr(nodeTD), 'import', False);
        TestCssStopException;
        while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger) do TdtIBS.Next;
        Continue;
      end;
      setlength(DupNodeCodes, 0); // список кодов видимых дублирующих нод
      DupNodeCodes:= AutoTreeNodesSys[sysID].GetDuplicateNodeCodes(pNodeORD, True);

      while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger) do begin // 1 нода
        mfTD  := TdtIBS.FieldByName('xMf').AsInteger; // код TD произв.авто
        pMfORD:= Manufacturers.GetManufIDByTDcode(mfTD);
                                            // произв.нет или невидим - прокручиваем
        if (pMfORD<1) or not Manufacturers[pMfORD].CheckIsVisible(sysID) then begin
          TestCssStopException;
          while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger)
            and (mfTD=TdtIBS.FieldByName('xMf').AsInteger) do TdtIBS.Next;
          Continue;
        end;

        while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger) // 1 производитель
          and (mfTD=TdtIBS.FieldByName('xMf').AsInteger) do begin
          mlTD  := TdtIBS.FieldByName('xMs').AsInteger; // код TD модельного ряда
          pMlORD:= Manufacturers[pMfORD].GetMfMLineIDByTDcode(mlTD, sysID);
                                              // м.р. нет или невидим - прокручиваем
          if (pMlORD<1) or not ModelLines[pMlORD].IsVisible then begin
            TestCssStopException;
            while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger)
              and (mfTD=TdtIBS.FieldByName('xMf').AsInteger)
              and (mlTD=TdtIBS.FieldByName('xMs').AsInteger) do TdtIBS.Next;
            Continue;
          end;

          while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger) // 1 мод.ряд
            and (mfTD=TdtIBS.FieldByName('xMf').AsInteger)
            and (mlTD=TdtIBS.FieldByName('xMs').AsInteger) do begin
            modTD := TdtIBS.FieldByName('xMT').AsInteger; // код TD модели
            pModORD:= ModelLines[pMlORD].GetMLModelIDByTDcode(modTD);
                                              // модели нет или невидима - прокручиваем
            if (pModORD<1) or not Models[pModORD].IsVisible then begin
              TestCssStopException;
              while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger)
                and (mfTD=TdtIBS.FieldByName('xMf').AsInteger)
                and (mlTD=TdtIBS.FieldByName('xMs').AsInteger)
                and (modTD=TdtIBS.FieldByName('xMT').AsInteger) do TdtIBS.Next;
              Continue;
            end;

            iLinkORD:= -1; // ищем связку ORD в массиве arInfo
            for i:= 0 to High(arInfo) do
              if (arInfo[i].nodeORD=pNodeORD) and (arInfo[i].modORD=pModORD) then begin
                iLinkORD:= i;
                break;
              end;

            if (iLinkORD<0) then begin //-------- если не нашли - добавляем связки
              iLinkORD:= ii;               // проверяем связку 2 с нодой nodeORD
              pNodLinks:= Models[pModORD].NodeLinks; // связки 2 модели modORD
              if not pNodLinks.LinkExists(pNodeORD) then begin
                s:= CheckModelNodeLinkDup(pModORD, pNodeORD, '0', Res, pSrc, userID);
                if res=resError then begin         // если ошибка - прокручиваем
                  prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): '+s+' (Model='+
                    IntToStr(pModORD)+', Node='+IntToStr(pNodeORD)+')', 'import', False);
                  TestCssStopException;
                  while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger)
                    and (mfTD=TdtIBS.FieldByName('xMf').AsInteger)
                    and (mlTD=TdtIBS.FieldByName('xMs').AsInteger)
                    and (modTD=TdtIBS.FieldByName('xMT').AsInteger) do TdtIBS.Next;
                  Continue;
                end;
              end;
                      // проверяем связку 2 на дублирующие ноды (на всяк.случай)
              for i:= Low(DupNodeCodes) to High(DupNodeCodes) do
                if not pNodLinks.LinkExists(DupNodeCodes[i]) then begin
                  s:= CheckModelNodeLinkDup(pModORD, DupNodeCodes[i], '0', Res, pSrc, userID);
                  if res=resError then
                    prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): '+s+' (Model='+
                      IntToStr(pModORD)+', DupNode='+IntToStr(DupNodeCodes[i])+')', 'import', False);
                end;
              // проверяем связку 3 модели modORD и ноды nodeORD с товаром WareID
              if not pNodLinks.DoubleLinkExists(pNodeORD, WareID) then begin
                res:= resAdded;
                s:= CheckWareModelNodeLink(WareID, pModORD, pNodeORD, res, pSrc, userID);
                if res=resError then begin         // если ошибка - прокручиваем
                  prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): '+s+' (Model='+
                    IntToStr(pModORD)+', Node='+IntToStr(pNodeORD)+')', 'import', False);
                  TestCssStopException;
                  while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger)
                    and (mfTD=TdtIBS.FieldByName('xMf').AsInteger)
                    and (mlTD=TdtIBS.FieldByName('xMs').AsInteger)
                    and (modTD=TdtIBS.FieldByName('xMT').AsInteger) do TdtIBS.Next;
                  Continue;
                end else if res=resAdded then inc(addLink3);
              end;
                                                // новую связку ORD - в массив
              if High(arInfo)<iLinkORD then setlength(arInfo, iLinkORD+100);
              with arInfo[iLinkORD] do begin
                nodeORD:= pNodeORD;
                nodTD  := nodeTD;
                modORD := pModORD;
                modelTD:= modTD;
                Src    := pSrc;
                ldmw   := 0;
                sys    := sysID;
                SetLength(PartNums, 0);
                SetLength(PartLagts, 0);
                SetLength(UsesLists, 0);
                SetLength(TextLists, 0);
              end;
              inc(ii);
            end; // if iLinkORD<0
                                        // собираем коды связок TD на связку ORD
            j:= Length(arInfo[iLinkORD].PartLagts);
            // может быть несколько одинаковых связок с разными порциями условий
            while not TdtIBS.Eof and (nodeTD=TdtIBS.FieldByName('xGA').AsInteger) // 1 модель
              and (mfTD=TdtIBS.FieldByName('xMf').AsInteger)
              and (mlTD=TdtIBS.FieldByName('xMs').AsInteger)
              and (modTD=TdtIBS.FieldByName('xMT').AsInteger) do begin
              iLagt:= TdtIBS.FieldByName('xlagt').AsInteger;
              with arInfo[iLinkORD] do   // запоминаем порции условий
                if fnInIntArray(iLagt, PartLagts)<0 then begin
                  setlength(PartNums, j+1);
                  PartNums[j]:= 0;
                  setlength(PartLagts, j+1);
                  PartLagts[j]:= iLagt;
                  setlength(UsesLists, j+1);
                  UsesLists[j]:= TStringList.Create;
                  setlength(TextLists, j+1);
                  TextLists[j]:= TStringList.Create;
                  inc(j);
                end; // with arInfo[iLinkORD]

              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
              TdtIBS.Next;
            end; // while ... and (modTD=
            CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
          end; // while ... and (mlTD=
        end; // while ... and (mfTD=
      end; // while ... and (nodeTD=
    end;
  finally
    TdtIBS.Close;
    setlength(DupNodeCodes, 0); 
  end;
end;
//=============================== загрузка связок товара с двигателями из TecDoc
function LoadWareEngLinksUsesFromTDT( WareID, UserID: Integer;
         var addLinkEng: Integer; ThreadData: TThreadData=nil; CheckArt: Boolean=True): String;
const nmProc = 'LoadWareEngLinksUsesFromTDT'; // имя процедуры/функции
var i, j, jj, ii, ij, ji, aCount, uCount, pEngTD, pGA, pLage, pCriTD, pEngORD,
      pNodeORD, DelUses, AddUses, iUse, pSupMFTD, DelCount, iPart: Integer;
    criValue, pArticleTD: String;
    flNotEx, flag, fl, flSleep: Boolean;
    ArCris: array of TCriInfo;
    arEngLinks: array of TEngLinkInfo;
    Nodes: TAutoTreeNodes;
    Engns: TEngines;
    TdtIBD, ordIBD, ordIBDr: TIBDatabase;
    TdtIBS, ordIBS, ordIBSr: TIBSQL;
    ErrUseNums: Tai; // номера порций условий для удаления
    LocalTime: TDateTime;
begin
  Result:= '';
  SetLength(arEngLinks, 0);
  SetLength(ArCris, 0);
  SetLength(ErrUseNums, 0); // номера порций условий для удаления
  addLinkEng:= 0;
  AddUses:= 0;
  DelUses:= 0;
  DelCount:= 0;
  tdtIBD:= nil;
  tdtIBS:= nil;
  ordIBD:= nil;
  ordIBDr:= nil;
  ordIBS:= nil;
  ordIBSr:= nil;
  LocalTime:= Now;
  flSleep:= not flDebug and fnGetActionTimeEnable(caeOnlyWorkTime);
  try try
    with Cache.GetWare(WareID) do begin
      if (ArticleTD='') or (ArtSupTD<1) then
        raise EBOBError.Create(MessText(mtkNotEnoughParams));
      pArticleTD:= ArticleTD;
      pSupMFTD:= ArtSupTD; // SupID TecDoc (DS_MF_ID !!!)
    end;

//    prMessageLOGS('      load engine links', 'import_test', False);
//----------------------------------------------------------------------- связки
    TdtIBD:= cntsTDT.GetFreeCnt;
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);

    if CheckArt then begin
      TdtIBS.SQL.Text:= 'select art_id from articles'+
        ' left join data_suppliers on ds_id=art_sup_id'+
        ' where art_nr=:art_nr and ds_mf_id='+IntToStr(pSupMFTD);
      TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
      TdtIBS.ExecQuery;
      if (TdtIBS.Bof and TdtIBS.Eof) or (TdtIBS.Fields[0].AsInteger<1) then // если артикула в TD нет
        raise Exception.Create('не найден артикул '+pArticleTD);
      TdtIBS.Close;
    end;

    TdtIBS.SQL.Text:= 'select rGA, rEng, rlage from GETARTICLEGAENGINES'+
      '(:art_nr, '+IntToStr(pSupMFTD)+') order by rGA, rEng';
    TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
    TdtIBS.ExecQuery;
    if TdtIBS.Bof and TdtIBS.Eof then Exit; // если связок нет - выходим

    ordIBD:= cntsORD.GetFreeCnt;
    ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite, true);
    ordIBS.SQL.Text:= 'select * from AddEngNodeWareLink(:xEng, :xNode, '+
      IntToStr(WareID)+', '+IntToStr(UserID)+', '+IntToStr(soTecDocBatch)+')';

    ordIBDr:= cntsORD.GetFreeCnt; // только для чтения
    ordIBSr:= fnCreateNewIBSQL(ordIBDr, 'ordIBSr_'+nmProc, -1, tpRead, true);
    //--------------------------------------------------- выбираем связки из ORD
    ordIBSr.SQL.Text:= 'select LENTRNACODE, LENDENGCODE, LENWCODE, TRNAMAINCODE'+
      ' from LINKENGINENODE left join LINKENGNODEWARE on LENWLENCODE=LENCODE'+
      ' left join TREENODESAUTO on TRNACODE=LENTRNACODE'+
      ' where LENWWARECODE='+IntToStr(WareID);
    ordIBSr.ExecQuery;
    j:= 0;
    while not ordIBSr.Eof do begin // связи товара из ORD
      if Length(arEngLinks)<(j+1) then SetLength(arEngLinks, j+100);
      with arEngLinks[j] do begin
        nodeORD:= ordIBSr.FieldByName('TRNAMAINCODE').AsInteger;
        engORD := ordIBSr.FieldByName('LENDENGCODE').AsInteger;
        xLenw  := ordIBSr.FieldByName('LENWCODE').AsInteger;
        SetLength(PartLages, 0);
        SetLength(PartNums, 0);   // номера порций условий
        SetLength(ArUseParts, 0); // порции условий
      end;
      inc(j);
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      ordIBSr.Next;
    end;
    ordIBSr.Close;
    aCount:= j;

    Nodes:= Cache.FDCA.AutoTreeNodesSys[constIsAuto];
    Engns:= Cache.FDCA.Engines;

    while not TdtIBS.Eof do begin
      pGA   := TdtIBS.FieldByName('rGA').AsInteger;
      pNodeORD:= Nodes.GetMainNodeIDByTDcode(pGA); // ищем ноду
      if (pNodeORD<1) then begin // если не нашли - прокручиваем
        prMessageLOGS(nmProc+': not found nodeTD= '+IntToStr(pGA), 'import', False);
        TestCssStopException;
        while not TdtIBS.Eof and (pGA=TdtIBS.FieldByName('rGA').AsInteger) do TdtIBS.Next;
        Continue;
      end;

      pEngTD:= TdtIBS.FieldByName('rEng').AsInteger;
      pEngORD:= Engns.GetIDBySubCode(pEngTD); // ищем двигатель
      if (pEngORD<1) then begin // если у нас такого нет - прокручиваем
        TestCssStopException;
        while not TdtIBS.Eof and (pGA=TdtIBS.FieldByName('rGA').AsInteger)
          and (pEngTD=TdtIBS.FieldByName('rEng').AsInteger) do TdtIBS.Next;
        Continue;
      end;

      while not TdtIBS.Eof and (pGA=TdtIBS.FieldByName('rGA').AsInteger)
        and (pEngTD=TdtIBS.FieldByName('rEng').AsInteger) do begin
        pLage := TdtIBS.FieldByName('rlage').AsInteger;
        flNotEx:= True;
        for j:= 0 to aCount-1 do with arEngLinks[j] do // ищем связку
          if (nodeORD=pNodeORD) and (engORD=pEngORD) then begin
            prAddItemToIntArray(pLage, PartLages); // собираем коды для условий
            flNotEx:= False;
            break;
          end;
        if flNotEx then try // если не нашли - добавляем
          with ordIBS.Transaction do if not InTransaction then StartTransaction;
          ordIBS.ParamByName('xEng').AsInteger:= pEngORD;
          ordIBS.ParamByName('xNode').AsInteger:= pNodeORD;
          ordIBS.ExecQuery;
          if (ordIBS.Eof and ordIBS.Bof) then i:= 0 else i:= ordIBS.Fields[0].AsInteger;
          if (i<1) then raise Exception.Create('empty link code');
          with ordIBS.Transaction do if InTransaction then Commit;
          j:= aCount;
          if Length(arEngLinks)<(j+1) then SetLength(arEngLinks, j+100);
          with arEngLinks[j] do begin
            nodeORD:= pNodeORD;     // запоминаем новую связку
            engORD := pEngORD;
            xLenw  := i;
            SetLength(PartLages, 1);
            PartLages[0]:= pLage;
            SetLength(PartNums, 0);   // номера порций условий     ???
            SetLength(ArUseParts, 0); // порции условий            ???
          end;
          inc(aCount);
          inc(addLinkEng);
          j:= Engns.GetEngine(pEngORD).EngMFau;
          if Cache.FDCA.Manufacturers.ManufExists(j) then
            with Cache.FDCA.Manufacturers[j] do begin
              if not MfHasEngWares then MfHasEngWares:= true;
              if not IsMfEng then IsMfEng:= true;
            end;
          CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
        except
          on E: Exception do begin
            with ordIBS.Transaction do if InTransaction then Rollback;
            prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error add node/eng link Node='+
              IntToStr(pNodeORD)+', Eng='+IntToStr(pEngORD)+': '+E.Message, 'import', False);
          end;
        end;
        ordIBS.Close;
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        TdtIBS.Next;
      end;
    end;
    TdtIBS.Close;
    ordIBS.SQL.Clear;

    for j:= 0 to aCount-1 do with arEngLinks[j] do begin  // заготовки массивов
      i:= Length(PartLages);
      SetLength(PartNums, i);   // номера порций условий
      SetLength(ArUseParts, i); // порции условий
      for i:= 0 to High(PartNums) do PartNums[i]:= 0;
      for i:= 0 to High(ArUseParts) do SetLength(ArUseParts[i], 0); // 1 порция условий
    end;
    flSleep:= flSleep or (aCount>1000);

//--------------------------------------------------------------- условия из TDT
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    TdtIBS.SQL.Text:= 'select rCri_ID, rCri_desc, rCri_val'+
      ' from GETARTICLEGAENGUSES(:lage)';
    for j:= 0 to aCount-1 do with arEngLinks[j] do begin
      iPart:= -1;
      uCount:= 0;
      for i:= 0 to High(PartLages) do begin
        TdtIBS.ParamByName('lage').AsInteger:= PartLages[i];
        TdtIBS.ExecQuery;
        while not TdtIBS.Eof do begin // условия из TDT
          pCriTD:= TdtIBS.FieldByName('rCri_ID').AsInteger;

          if (iPart<0) or (pCriTD=8) then begin // начало или разделитель блоков
            if (iPart>-1) then begin
              if (Length(ArUseParts[iPart])>uCount) then // конец порции
                SetLength(ArUseParts[iPart], uCount);
            end;
            Inc(iPart); // новая порция
            uCount:= 0;
            if (High(PartNums)<iPart) then begin
              SetLength(PartNums, iPart+1);   // номера порций условий
              SetLength(ArUseParts, iPart+1); // порции условий
              PartNums[iPart]:= 0;
              SetLength(ArUseParts[iPart], 0); // 1 порция условий
            end; // if (High(PartNums)<iPart)
          end; // if (iPart<0) or (pCriTD=8)

          if (pCriTD<>8) then begin
            if (High(ArUseParts[iPart])<uCount) then
              SetLength(ArUseParts[iPart], uCount+100);
            with ArUseParts[iPart][uCount] do begin
              CRITD:= pCriTD;    // код TD критерия
              CriName:= TdtIBS.FieldByName('rCri_desc').AsString; // нужно для записи в базу
  //              CriNameUp:= AnsiUpperCase(CriName);
              Value:= TdtIBS.FieldByName('rCri_val').AsString;    // значение критерия
              if Value='' then ValueUp:= '' else ValueUp:= AnsiUpperCase(Value);
            end;
            inc(uCount);
          end; // if (pCriTD<>8)

          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
          TdtIBS.Next;
        end;
        TdtIBS.Close;
        if (iPart>-1) and (Length(ArUseParts[iPart])>uCount) then // конец последней порции
          SetLength(ArUseParts[iPart], uCount);
      end; // for i:= 0 to High(PartLages)

//---------------------------------------- проверяем дубликаты порций условий TD
      if length(PartNums)>1 then begin
        for jj:= 0 to High(PartNums) do begin
          if (Length(ArUseParts[jj])<1) then Continue;

          for ji:= jj+1 to High(PartNums) do begin
            if (Length(ArUseParts[jj])<>Length(ArUseParts[ji])) then Continue;

            flag:= False; // признак несовпадения массивов
            for i:= Low(ArUseParts[jj]) to High(ArUseParts[jj]) do begin // сверяем ArUseParts
              fl:= False; // признак - нашли элемент
              for ii:= Low(ArUseParts[ji]) to High(ArUseParts[ji]) do begin // ищем элемент jj-го массива в ji-том массиве
                fl:= (ArUseParts[jj][i].CRITD=ArUseParts[ji][ii].CRITD) and
                     (ArUseParts[jj][i].ValueUp=ArUseParts[ji][ii].ValueUp);
                if fl then Break;
              end; // for ii:= 0 to
              if fl then Continue; // нашли - продолжаем сверку элементов

              flag:= True; // что-то не нашли - прекращаем сверку элементов
              Break;
            end; // for i:= 0 to
            if flag then Continue; // что-то не нашли

            //--------------------- ArUseParts[jj] = ArUseParts[ji]
            SetLength(ArUseParts[ji], 0);  // чистим дубликат
            PartNums[ji]:= -1;
          end; // for ji:= jj+1 to ...
        end; // for jj:= 0 to
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      end; // if length(PartNums)>1
      CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
    end; //  for j:= 0 to aCount-1

    CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

//--------------------------------------------------------------- условия из ORD
    with ordIBSr.Transaction do if not InTransaction then StartTransaction;
    ordIBSr.SQL.Text:= 'select WCRITDCODE, WCVSVALUE, LENWUPART'+
      ' from LINKENGNODEWAREUSAGE'+
      ' left join WARECRIVALUES on WCVSCODE=LENWUWCVSCODE'+
      ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE'+
      ' where LENWULENWCODE=:lenw order by LENWUPART';

    with ordIBS.Transaction do if not InTransaction then StartTransaction;
    ordIBS.SQL.Text:= 'delete from LINKENGNODEWAREUSAGE'+ // для удаления ненайденных порций
      ' where LENWULENWCODE=:lenw and LENWUPART=:part';

    for j:= 0 to aCount-1 do with arEngLinks[j] do begin
      ordIBSr.ParamByName('lenw').AsInteger:= xLenw; // 1 связка 3
      ordIBSr.ExecQuery;
      while not ordIBSr.Eof do begin // условия из ORD
        iUse:= ordIBSr.FieldByName('LENWUPART').AsInteger;
        uCount:= 0;                     // 1 порция из ORD - в ArCris
        DelCount:= 0;          // чистим массив номеров порций условий ORD для удаления
        while not ordIBSr.Eof and (iUse=ordIBSr.FieldByName('LENWUPART').AsInteger) do begin
          if (High(ArCris)<uCount) then SetLength(ArCris, uCount+100);
          with ArCris[uCount] do begin
            CRITD:= ordIBSr.FieldByName('WCRITDCODE').AsInteger;
            Value:= ordIBSr.FieldByName('WCVSVALUE').AsString;
            if Value='' then ValueUp:= '' else ValueUp:= AnsiUpperCase(Value);
          end;
          inc(uCount);
          CheckStopExecute(UserID, ThreadData);
          ordIBSr.Next;
        end; // while ... and (iUse=
//------------------------------------------------------- проверяем 1 порцию ORD
        for jj:= 0 to High(ErrUseNums) do ErrUseNums[jj]:= 0;

        pLage:= -1;         // ищем такую же порцию в arEngLinks[j].ArUseParts
        for jj:= 0 to High(ArUseParts) do begin
          if (PartNums[jj]>0) or (Length(ArUseParts[jj])<1) then Continue; // порция уже найдена
                                      // кол-во условий в порциях не совпадает
          if (Length(ArUseParts[jj])<>uCount) then Continue;

          pLage:= -1;                              // проверяем 1 порцию TDT
          for ii:= 0 to High(ArUseParts[jj]) do with ArUseParts[jj][ii] do begin
            pCriTD:= CRITD;     // берем 1 условие из порции TDT
            criValue:= ValueUp;
            pLage:= -1;
            for ij:= 0 to uCount-1 do // ищем такое же условие в ArCris
              if (ArCris[ij].CRITD=pCriTD) and (ArCris[ij].ValueUp=criValue) then begin
                pLage:= ij; // нашли соответствие
                break;
              end;
            if (pLage<0) then break; // какое-то условие не нашли - проверку прекращаем
          end; // for ii:= 0 to High(arEngLinks[j].ArUseParts[jj])

          if (pLage>-1) then begin  // если все условия нашли
            if (fnInIntArray(iUse, PartNums)<0) then PartNums[jj]:= iUse;
            SetLength(ArUseParts[jj], 0);          // чистим
            break;
          end;
          CheckStopExecute(UserID, ThreadData);
        end; // for jj:= 0 to High(arEngLinks[j].ArUseParts)

        if (pLage<0) and (fnInIntArray(iUse, ErrUseNums)<0) then begin // порцию ORD в TDT не нашли
          if High(ErrUseNums)<DelCount then SetLength(ErrUseNums, DelCount+10); // номера порций условий ORD для удаления
          ErrUseNums[DelCount]:= iUse;
          inc(DelCount);
        end;
//------------------------------------------------------- проверили 1 порцию ORD
      end; // while not ordIBSr.Eof
      ordIBSr.Close;

//-------------------------------------- если надо удалять порции условий из ORD
      if (DelCount>0) then begin
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.ParamByName('lenw').AsInteger:= xLenw;
        for jj:= 0 to DelCount-1 do if (ErrUseNums[jj]>0) then try
          with ordIBS.Transaction do if not InTransaction then StartTransaction;
          ordIBS.ParamByName('part').AsInteger:= ErrUseNums[jj];
          ordIBS.ExecQuery;
          with ordIBS.Transaction do if InTransaction then Commit;
          inc(DelUses);
          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        except
          on E: EBOBError do raise EBOBError.Create(E.Message);
          on E: Exception do begin
            with ordIBS.Transaction do if InTransaction then Rollback;
            prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error del eng use part '+
              IntToStr(ErrUseNums[jj])+': '+E.Message, 'import', False);
          end;
        end;
      end; // if DelCount>0
      CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
    end; // for j:= 0 to aCount-1 do with arEngLinks[j] do

    CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

//--------------------------------------------- пишем новые порции условий в ORD
    with ordIBS.Transaction do if not InTransaction then StartTransaction;
    ordIBS.SQL.Text:= 'select * from ADDENGNODEWAREPARTUSAGELINK(:xEng, :xNode, '+
      IntToStr(WareID)+', :part, :criTD, :CriName, :CriValue, '+
      IntToStr(UserID)+', '+IntToStr(soTecDocBatch)+')';

    for j:= 0 to aCount-1 do with arEngLinks[j] do begin
      if Length(ArUseParts)<1 then Continue;

      for jj:= 0 to High(ArUseParts) do begin
        if (PartNums[jj]>0) or (Length(ArUseParts[jj])<1) then Continue;

        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.ParamByName('xEng').AsInteger := EngORD;
        ordIBS.ParamByName('xNode').AsInteger:= NodeORD;

        for ij:= 0 to High(ArUseParts[jj]) do with ArUseParts[jj][ij] do begin
          try
            with ordIBS.Transaction do if not InTransaction then StartTransaction;
            ordIBS.ParamByName('criTD').AsInteger  := CRITD;
            ordIBS.ParamByName('CriName').AsString := CriName;
            ordIBS.ParamByName('CriValue').AsString:= Value; // значение критерия
            ordIBS.ParamByName('part').AsInteger   := PartNums[jj];
            ordIBS.ExecQuery;
            if (ordIBS.Bof and ordIBS.Eof) then raise Exception.Create('empty ordIBS');
            if ordIBS.FieldByName('ERRLINK').AsInteger<0 then raise Exception.Create('exists');
            if ordIBS.FieldByName('ERRLINK').AsInteger>0 then raise Exception.Create('wrong');
            if ordIBS.FieldByName('PARTID').AsInteger<1 then raise Exception.Create('empty PartID');

            if (PartNums[jj]<1) then PartNums[jj]:= ordIBS.FieldByName('PARTID').AsInteger; // номер новой порции
            with ordIBS.Transaction do if InTransaction then Commit;
            inc(AddUses);
          except
            on E: Exception do begin
              with ordIBS.Transaction do if InTransaction then Rollback;
              if E.Message<>'exists' then
                prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
                  '): error add Lenw/criTD/CriValue '+IntToStr(xLenw)+'/'+
                  IntToStr(CRITD)+'/'+Value+': '+E.Message, 'import', False);
            end;
          end;
          ordIBS.Close;
          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        end; // for ij:= 0 to High(ArUseParts[jj])
      end; // for i:= 0 to High(ArUseParts)
      CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
    end; //  for j:= 0 to aCount-1
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do begin
      Result:= nmProc+' (ware='+IntToStr(WareID)+'): '+E.Message;
//      prMessageLOGS(Result, 'import', False);
//      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'error', E.Message, '', false, 'import');
    end;
  end;
  finally
    prFreeIBSQL(TdtIBS);
    cntsTDT.SetFreeCnt(TdtIBD);
    prFreeIBSQL(ordIBS);
    cntsORD.SetFreeCnt(ordIBD);
    prFreeIBSQL(ordIBSr);
    cntsORD.SetFreeCnt(ordIBDr);
    SetLength(ArCris, 0);
    for i:= 0 to High(arEngLinks) do begin
      SetLength(arEngLinks[i].PartLages, 0);
      SetLength(arEngLinks[i].PartNums, 0);
      for j:= 0 to High(arEngLinks[i].ArUseParts) do
        SetLength(arEngLinks[i].ArUseParts[j], 0);
      SetLength(arEngLinks[i].ArUseParts, 0);
    end;
    SetLength(arEngLinks, 0);
    SetLength(ErrUseNums, 0); // номера порций условий для удаления
  end;
//  if (addLinkEng>0) or (AddUses>0) or (DelUses>0) then
//    prMessageLOGS(nmProc+':'+fnIfStr(addLinkEng>0, ' add '+IntToStr(addLinkEng)+' eng links', '')+
//      fnIfStr(AddUses>0, ' add '+IntToStr(AddUses)+' eng uses', '')+
//      fnIfStr(DelUses>0, ' del '+IntToStr(DelUses)+' eng use parts', ''), 'import', False);
end;
//===================== загрузка порций условий и текстов из TecDoc (версия 2.4)
procedure LoadModelNodeWareUseAndTextListsFromTDT(TdtIBS, TdtIBSt, ordIBS, ordIBSr: TIBSQL;
          WareID, pSupMFTD, UserID: Integer; var arInfo: TArLinkInfo;
          ThreadData: TThreadData=nil; CheckTexts: Boolean=False);
const nmProc = 'LoadModelNodeWareUseAndTextListsFromTDT'; // имя процедуры/функции
// TdtIBS, ordIBS, ordIBSr передаются для увеличения скорости обработки
var ii, criTD, jj, ke, kt, pType, j, i, ResCode, iLagt, iPart, iPartTxt: Integer;
    s, ss, criName, usValue, tm: String;
    ErrUseNums, ErrTxtNums: Tai;
    flag, flSleep: Boolean;
    LocalTime: TDateTime;
  //----------------------------------------------- новая порция
  procedure AddPart(ii, ind: Integer);
  begin
    with arInfo[ii] do begin
      if (High(UsesLists)<ind) then begin
        setlength(PartNums, ind+1);
        setlength(UsesLists, ind+1);
        setlength(TextLists, ind+1);
        UsesLists[ind]:= TStringList.Create;
        TextLists[ind]:= TStringList.Create;
      end;
      PartNums[ind]:= 0;
      if (UsesLists[ind].Count>0) then UsesLists[ind].Clear;
      if (TextLists[ind].Count>0) then TextLists[ind].Clear;
    end; // with arInfo[ii]
  end;
  //-----------------------------------------------
begin
  kt:= 72;
  pType:= 0;
  SetLength(ErrUseNums, 0);  // массив номеров порций условий, кот.надо удалять
  SetLength(ErrTxtNums, 0);  // массив номеров порций текстов, кот.надо удалять
  LocalTime:= Now;
  flSleep:= not flDebug and (fnGetActionTimeEnable(caeOnlyWorkTime) or (High(arInfo)>1000));
  try
    ordIBSr.Close;
    ordIBSr.SQL.Clear;
    ordIBS.Close;
    ordIBS.SQL.Clear;
    TdtIBS.Close;
  //------------------------------------------- из TDT порция условий к связке 3
  //------------------------------------------- может содержать несколько блоков
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    TdtIBS.SQL.Text:= 'select xCri_ID, xCri_desc, xCri_val'+
      ' from GetArticleGATypeUsesNew(:xlagt)';
    TdtIBS.Prepare;
  //------------------------------------------- из TDT порция текстов к связке 3
    with TdtIBSt.Transaction do if not InTransaction then StartTransaction;
    TdtIBSt.SQL.Text:= 'select rINFTYPE, rTM, rTXT, rTYPEname'+
                      ' from GetArtGAMtTextPart(:xlagt)';
    TdtIBSt.Prepare;

    for ii:= 0 to High(arInfo) do with arInfo[ii] do begin
      if (ldmw<1) or (length(PartLagts)<1) then Continue;
//------------------------------------------------------------------------------
      iPart:= -1;
      iLagt:= -1;
      iPartTxt:= 0;
      for jj:= 0 to High(PartLagts) do try // перебираем связки TDT
//==============================================
//        if flDebug and ((PartLagts[jj]=555400){ or (PartLagts[jj]=555401)}) then begin
//          iDebug:= ii;
//        end else iDebug:= -1;
        //------------------------------------------ начало или смена связки TDT
        if (iLagt<>jj) then begin
          Inc(iPart);        // новая порция
          AddPart(ii, iPart);
          iPartTxt:= iPart; // индекс 1-й порции текстов связки TDT (для копирования в блоки)
          iLagt:= jj;       // индекс текущей связки TDT (для проверки смены связки TDT)

          try //----------------- тексты вынимаем 1 раз по связке TDT
            with TdtIBSt.Transaction do if not InTransaction then StartTransaction;
            TdtIBSt.ParamByName('xLAGT').AsInteger:= PartLagts[jj];
            TdtIBSt.ExecQuery;
            while not TdtIBSt.Eof do begin
              ke:= TdtIBSt.FieldByName('rINFTYPE').AsInteger;
              s:= TdtIBSt.FieldByName('rTYPEname').AsString;
              with Cache.FDCA do begin  // ищем вид информации в кеше по кодам TDT
                pType:= 11;
                j:= 0;
                if not TypesInfoModel.FindInfoItemByTDcodes(j, pType, ke, kt) then begin
                  // добавляем новый вид информации в кеш и в базу (pType - из FindInfoItemByTDcodes)
                  ss:= TypesInfoModel.AddInfoModelItem(j, pType, ke, kt, s, UserID);
                  if (ss<>'') then raise Exception.Create('add error: '+ss);
                end;
              end;
              pType:= j;
              while not TdtIBSt.Eof and (ke=TdtIBSt.FieldByName('rINFTYPE').AsInteger) do begin
                tm:= TdtIBSt.FieldByName('rTM').AsString;
                s:= '';                        // собираем текстовый модуль в строку
                while not TdtIBSt.Eof and (ke=TdtIBSt.FieldByName('rINFTYPE').AsInteger)
                  and (tm=TdtIBSt.FieldByName('rTM').AsString) do begin
                  s:= s+' '+TdtIBSt.FieldByName('rTXT').AsString;
                  CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
                  TdtIBSt.Next;
                end;
  //              s:= CheckTextFirstUpAndSpaces(s); // проверка заглавной буквы и пробелов текста
                s:= trim(s); // <IntToStr(код типа текста)>=<идентификатор TecDoc>+cSpecDelim+<текст>
                s:= IntToStr(pType)+cStrValueDelim+tm+cSpecDelim+s;
                TextLists[iPart].AddObject(s, Pointer(pSupMFTD)); // формируем список
              end; // while not TdtIBSt.Eof and (ke=
            end; // while not TdtIBSt.Eof
          except
            on E: EBOBError do raise EBOBError.Create(E.Message);
            on E: Exception do prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
              '): mod='+IntToStr(modORD)+', node='+IntToStr(nodeORD)+
              ': '+E.Message, 'import', False);
          end;
          TdtIBSt.Close;
          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        end; // if (iLagt<>jj)

        try //--------------------------------------------- условия к связке TDT
          with TdtIBS.Transaction do if not InTransaction then StartTransaction;
          TdtIBS.ParamByName('xlagt').AsInteger:= PartLagts[jj];
          TdtIBS.ExecQuery;
          while not TdtIBS.Eof do begin
            criTD:= TdtIBS.FieldByName('xCri_ID').AsInteger;

            if (criTD=8) then begin // критерий "Отсоединение блока" (разделитель)
              Inc(iPart);
              AddPart(ii, iPart); // новая порция в одном iLagt
              // копируем тексты в блок
              if (iPart>iPartTxt) and (TextLists[iPartTxt].Count>0) then
                TextLists[iPart].AddStrings(TextLists[iPartTxt]);
            end else begin
              criName:= TdtIBS.FieldByName('xCri_desc').AsString;
              usValue:= TdtIBS.FieldByName('xCri_val').AsString;  // значение условия
              UsesLists[iPart].AddObject(criName+cStrValueDelim+usValue, Pointer(criTD)); // формируем списки условий
            end;

            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            TdtIBS.Next;
          end;
        except
          on E: EBOBError do raise EBOBError.Create(E.Message);
          on E: Exception do prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): mod='+
            IntToStr(modORD)+', node='+IntToStr(nodeORD)+': '+E.Message, 'import', False);
        end;
        TdtIBS.Close;
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
//==============================================
      finally
        TdtIBSt.Close;
        TdtIBS.Close;
      end; // for jj:= 0 to High(link.PartLagts)
//------------------------------------------------------------------------------
      CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
    end; // for ii:= 0 to High(arInfo)
    CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

    for ii:= 0 to High(arInfo) do with arInfo[ii] do begin
      if (ldmw<1) or (length(PartLagts)<1) then Continue;
{
      if flDebug and (ii=iDebug) then begin
        prMessageLOGS('-------------------------------- 1', fLogDebug, False);
        prMessageLOGS(' 555400: length(PartNums)= '+IntToStr(length(PartNums))+
              ' length(UsesLists)= '+IntToStr(length(UsesLists)), fLogDebug, False);
        for i:= 0 to High(UsesLists) do
          for j:= 0 to UsesLists[i].Count-1 do
            prMessageLOGS(' '+IntToStr(i)+': UsesLists'+IntToStr(j)+'= '+UsesLists[i][j], fLogDebug, False);
      end;
}
      //--------------------------------------- проверяем дубликаты порций
      if (length(PartNums)>1) then begin

        for jj:= 0 to High(PartNums) do begin
          if (UsesLists[jj].Count>1) then UsesLists[jj].Sort;
          if (TextLists[jj].Count>1) then TextLists[jj].Sort;
          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        end;

        for jj:= 0 to High(PartNums) do begin
          if (UsesLists[jj].Count<1) and (TextLists[jj].Count<1) then Continue;

          for j:= jj+1 to High(PartNums) do begin
            if (UsesLists[jj].Count<>UsesLists[j].Count) or
              (TextLists[jj].Count<>TextLists[j].Count) then Continue;

            flag:= False;
            if (UsesLists[jj].Count>0) then
              for i:= 0 to UsesLists[jj].Count-1 do begin // сверяем PartLists
                flag:= (UsesLists[jj][i]<>UsesLists[j][i]) or
                       (Integer(UsesLists[jj].Objects[i])<>Integer(UsesLists[j].Objects[i]));
                if flag then Break;
              end; // for i:= 0 to
            if flag then Continue;

            if (TextLists[jj].Count>0) then
              for i:= 0 to TextLists[jj].Count-1 do begin // сверяем TextLists
                flag:= ((TextLists[jj][i]<>TextLists[j][i]) or
                       (Integer(TextLists[jj].Objects[i])<>Integer(TextLists[j].Objects[i])));
                if flag then Break;
              end; // for i:= 0 to
            if flag then Continue;

            // link.PartLists[jj] = link.PartLists[j] and link.TextLists[jj] = link.TextLists[j]
            UsesLists[j].Clear;  // чистим дубликат
            UsesLists[j].Delimiter:= LCharGood;
            TextLists[j].Clear;
            TextLists[j].Delimiter:= LCharGood;
            PartNums[j]:= -1;
          end; // for j:= jj+1 to ...
          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        end; // for jj:= 0 to
      end; // if length(link.PartNums)>1
{
      if flDebug and (ii=iDebug) then begin
        prMessageLOGS('-------------------------------- 2', fLogDebug, False);
        for i:= 0 to High(UsesLists) do begin
          prMessageLOGS(' '+IntToStr(i)+': UsesLists.Delimiter= '+UsesLists[i].Delimiter, fLogDebug, False);
          for j:= 0 to UsesLists[i].Count-1 do
            prMessageLOGS(' '+IntToStr(i)+': UsesLists'+IntToStr(j)+'= '+UsesLists[i][j], fLogDebug, False);
        end;
      end;
}
      //---------------------------------------- ищем номера порций в нашей базе
      s:= Cache.FindModelNodeWareUseAndTextListNumbers(modORD, nodeORD, WareID,
          UsesLists, TextLists, PartNums, ErrUseNums, ErrTxtNums, True, CheckTexts);
      if s<>'' then raise Exception.Create(s);
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

      //------------------------ удаляем ненайденные порции условий в нашей базе
      for jj:= 0 to High(ErrUseNums) do if (ErrUseNums[jj]>0) then begin
        s:= Cache.DelModelNodeWareUseListLinks(modORD, nodeORD, WareID, ErrUseNums[jj]);
        if s<>'' then prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+') error del use link: '+s, 'import', False);
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      end;

      //------------------------ удаляем ненайденные порции текстов в нашей базе
      for jj:= 0 to High(ErrTxtNums) do if (ErrTxtNums[jj]>0) then begin
        ResCode:= resDeleted;
        s:= Cache.CheckModelNodeWareTextListLinks(ResCode, modORD, nodeORD,
                            WareID, nil, UserID, Src, ErrTxtNums[jj]);
        if ResCode=resError then
          prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+') error del txt link: '+s, 'import', False);
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      end;

      for jj:= 0 to High(PartNums) do begin // чистим все, что не надо заливать
        with UsesLists[jj] do if (Delimiter=LCharGood) and (Count>0) then Clear;
        with TextLists[jj] do if (Delimiter=LCharGood) and (Count>0) then Clear;
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
     end; // for jj:= 0 to High(link.PartNums)
{
      if flDebug and (ii=iDebug) then begin
        prMessageLOGS('-------------------------------- 3', fLogDebug, False);
        prMessageLOGS(' 555400: length(PartNums)= '+IntToStr(length(PartNums))+
              ' PartNums= '+fnArrOfIntToString(PartNums), fLogDebug, False);
        for i:= 0 to High(UsesLists) do begin
          prMessageLOGS(' '+IntToStr(i)+': UsesLists.Delimiter= '+UsesLists[i].Delimiter, fLogDebug, False);
          for j:= 0 to UsesLists[i].Count-1 do
            prMessageLOGS(' '+IntToStr(i)+': UsesLists'+IntToStr(j)+'= '+UsesLists[i][j], fLogDebug, False);
        end;
      end;
}
      for jj:= 0 to High(PartNums) do begin
        j:= 0;
        //------------------------------------ добавляем новую порцию условий
        if (UsesLists[jj].Count>0) then begin
          s:= Cache.AddModelNodeWareUseListLinks(modORD, nodeORD, WareID, UserID, Src, UsesLists[jj], j);
          if (s='') or (s='exists') then
            PartNums[jj]:= StrToIntDef(UsesLists[jj].Strings[0], 0) // номер новой порции
          else //raise Exception.Create(s);
           prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error add use link: '+s, 'import', False);
          CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        end;
        //------------------------------------ добавляем новую порцию текстов
        if (TextLists[jj].Count>0) then begin
          ResCode:= resAdded;
          s:= Cache.CheckModelNodeWareTextListLinks(ResCode, modORD, nodeORD,
                              WareID, TextLists[jj], UserID, Src, PartNums[jj]);
          if ResCode=resError then
            prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): error add txt link: '+s, 'import', False);
        end;
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      end; // for jj:= 0 to High(link.PartNums)

      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
    end; // for ii:= 0 to High(arInfo)
  finally
    with ordIBS.Transaction do if InTransaction then Rollback;
    ordIBS.Close;
    ordIBSr.Close;
    TdtIBS.Close;
    TdtIBSt.Close;
    SetLength(ErrUseNums, 0);
    SetLength(ErrTxtNums, 0);
  end;
end;
//============================ загрузка аналогов товара (+ по заменам) из TecDoc
procedure LoadWareCrossesFromTDT(TdtIBS, ordIBS, ordIBSr: TIBSQL;
          WareID, pSupMFTD, UserID: Integer; pArticleTD: String; ThreadData: TThreadData=nil);
const nmProc = 'LoadWareCrossesFromTDT'; // имя процедуры/функции
      StrLimit = 240;
// TdtIBS, ordIBS, ordIBSr передаются для увеличения скорости обработки
var j, i, k, src: Integer;
    sWare, sUser, s: String;
    ArArtCross: array of TCrossArtInfo;
    flag: Boolean;
    IBS: TIBSQL;
    ibd: TIBDatabase;
    CrossList1, CrossList2, CrossDel1, CrossDel2: TIntegerList;
    ware, analog: TWareInfo;
    arListsSql: TASL;
    //---------------------------------------------
    procedure NewListSQL(var jj: Integer; kind: Integer=1);
    begin
      if (jj>-1) then arListsSql[jj].Add('end');
      inc(jj);
      SetLength(arListsSql, jj+1);
      arListsSql[jj]:= TStringList.Create;
      if kind=0 then begin
        arListsSql[jj].Add('execute block returns (rWare integer, rSrc integer) as begin');
      end else begin
        arListsSql[jj].Add('execute block returns (rWare integer, rSrc integer, rAdd integer)');
        arListsSql[jj].Add('as declare variable err integer; begin');
      end;
    end;
    //---------------------------------------------
begin
  SetLength(ArArtCross, 0);
  ordIBSr.Close;
  SetLength(arListsSql, 0);
  j:= 0;
  sWare:= IntToStr(WareID);
  sUser:= IntToStr(UserID);
  if not Cache.WareExist(WareID) then Exit;
  ware:= Cache.GetWare(WareID, True);
  IBS:= nil;
  CrossList1:= TIntegerList.Create; // коды кроссов с источником soTecDocBatch
  CrossList2:= TIntegerList.Create; // коды кроссов с источником soTDsupersed
  CrossDel1 := TIntegerList.Create; // коды кроссов для удаления с источником soTecDocBatch
  CrossDel2 := TIntegerList.Create; // коды кроссов для удаления с источником soTDsupersed
  try try
    TdtIBS.Close; //--------------------------- кроссы-артикулы (+ замены) из TD
    with TdtIBS.Transaction do if not InTransaction then StartTransaction;
    TdtIBS.SQL.Text:= 'select distinct crossMF, crossNR, BySupersed'+
      ' from get_art_crosses_new('+IntToStr(pSupMFTD)+', :art_nr)'+
      ' order by crossMF, crossNR, BySupersed';
    TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
    TdtIBS.ExecQuery;
    while not TdtIBS.Eof do begin
      k:= TdtIBS.FieldByName('crossMF').AsInteger;
      s:= TdtIBS.FieldByName('crossNR').AsString;
      flag:= (k=pSupMFTD) and (s=pArticleTD);
      if not flag then for i:= 0 to High(ArArtCross) do begin    // проверяем дубликаты
        flag:= (ArArtCross[i].supMF=k) and (ArArtCross[i].article=s);
        if flag then break;
      end;
      if not flag then begin
        if Length(ArArtCross)<(j+1) then SetLength(ArArtCross, j+100);
        ArArtCross[j].supMF  := k; // код supMF
        ArArtCross[j].article:= s; // артикул TD
        if (TdtIBS.FieldByName('BySupersed').AsInteger=1) then
          ArArtCross[j].src:= soTDsupersed
        else ArArtCross[j].src:= soTecDocBatch;
        inc(j);
      end;
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      TdtIBS.Next;
    end;
    TdtIBS.Close;
    TdtIBS.SQL.Clear;
    if Length(ArArtCross)>j then SetLength(ArArtCross, j);

//------------------------------------- коды товаров-кроссов по артикулам из ORD
    j:= -1;
    NewListSQL(j, 0);
    for i:= 0 to High(ArArtCross) do begin
      if (arListsSql[j].Count>StrLimit) then NewListSQL(j, 0);
      arListsSql[j].Add(' rSrc='+IntToStr(ArArtCross[i].src)+';');
      arListsSql[j].Add(' for select WATDWARECODE from WAREARTICLETD'+
                        ' left join WareOptions on wowarecode=WATDWARECODE');
      arListsSql[j].Add('  where WATDARTICLE="'+ArArtCross[i].article+'"'+
                        '   and WATDARTSUP='+IntToStr(ArArtCross[i].supMF)+' and WOARHIVED="F"');
      arListsSql[j].Add(' into :rWare do if (rWare is not null and rWare>0) then suspend;');
      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
    end;
    arListsSql[j].Add('end');

    with ordIBSr.Transaction do if not InTransaction then StartTransaction;
    ordIBSr.Close;
    ordIBSr.ParamCheck:= False;
    for j:= 0 to High(arListsSql) do begin
      ordIBSr.SQL.Clear;
      ordIBSr.SQL.AddStrings(arListsSql[j]);
      ordIBSr.ExecQuery;
      while not ordIBSr.Eof do begin
        k:= ordIBSr.Fields[0].AsInteger;  // берем только неархивные и не ИНФО
        if (k<>WareID) and Cache.WareExist(k) then with Cache.GetWare(k) do
          if not IsArchive and not IsINFOgr then
            if (ordIBSr.Fields[1].AsInteger=soTDsupersed) then
              CrossList2.Add(k)     // коды кроссов с источником soTDsupersed
            else CrossList1.Add(k); // коды кроссов с источником soTecDocBatch
        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        ordIBSr.Next;
      end;
      ordIBSr.Close;
    end;
    ordIBSr.SQL.Clear;
    ordIBSr.ParamCheck:= True;
    for i:= 0 to High(arListsSql) do prFree(arListsSql[i]);
    SetLength(arListsSql, 0);

//----------------------------- проверяем существующие товары-кроссы из Grossbee
    ibd:= cntsGRB.GetFreeCnt;
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, true);
      IBS.SQL.Text:= 'select PMWAWAREANALOGCODE, PMWAISWRONG, (AnDtSyncCode-'+
        Cache.GetConstItem(pcCrossAnalogsDeltaSync).StrValue+') as Src'+
        ' from PMWAREANALOGS left join AnalitDict on ANDTCODE=PMWASOURCECODE'+
        ' where PMWAWARECODE='+sWare;
      IBS.ExecQuery;
      while not IBS.Eof do begin // коды кроссов товара из Grossbee
        k:= IBS.FieldByName('PMWAWAREANALOGCODE').AsInteger; // код товара-кросса
        src:= ibs.FieldByName('Src').AsInteger;              // источник из GrossBee
        flag:= ibs.FieldByName('PMWAISWRONG').AsString='F';

        i:= CrossList1.IndexOf(k); // ищем в 1-м списке
        if (i>-1) then CrossList1.Delete(i) // если нашли - не добавляем
        else begin
          i:= CrossList2.IndexOf(k); // ищем в 2-м списке
          if (i>-1) then CrossList2.Delete(i); // если нашли - не добавляем
        end;
        if (i>-1) then begin  // такой кросс в GrossBee есть (источник неважен)
          if flag then Ware.CheckAnalogLink(k, src); // добавить в кеш, если его там нет
          TestCssStopException;
          IBS.Next;
          Continue;
        end;

        if not flag or not (src in [soTecDocBatch, soTDsupersed]) then begin
          TestCssStopException;
          IBS.Next;    // проверяем, надо ли удалять, только правильные TD-связи
          Continue;
        end;

        analog:= nil;
        flag:= (k<>WareId); // аналог <> товар
        if flag then begin
          analog:= Cache.GetWare(k);                        // не архив или инфо
          flag:= Assigned(analog) and not ((analog=NoWare) or analog.IsArchive or analog.IsINFOgr);
        end;

        if not flag or not Assigned(analog) then begin // аналог = товар, архив и инфо - удалять
          if (src=soTDsupersed) then CrossDel2.Add(k) else CrossDel1.Add(k);
          TestCssStopException;
          IBS.Next;
          Continue;
        end;

        if (analog.ArtSupTD<1) or (analog.ArticleTD='') then begin
          TestCssStopException;
          IBS.Next;    // товар не связан с TD (старый артикул) - не проверяем
          Continue;
        end;
                                         // проверяем существование артикула TD
        if TdtIBS.SQL.Text='' then TdtIBS.SQL.Text:= 'select art_id from articles'+
          ' left join data_suppliers on DS_ID=ART_SUP_ID where art_nr=:art and ds_mf_id=:mf';
        TdtIBS.ParamByName('art').AsString:= Ware.ArticleTD;
        TdtIBS.ParamByName('mf').AsInteger:= Ware.ArtSupTD;
        TdtIBS.ExecQuery;
        flag:= not (TdtIBS.Eof and TdtIBS.Bof) and (TdtIBS.Fields[0].AsInteger>0);
        TdtIBS.Close;

        if flag then  // удаляем, если артикул в TD есть, а связь ушла
          if (src=soTDsupersed) then CrossDel2.Add(k) else CrossDel1.Add(k);

        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        IBS.Next;
      end;
      IBS.Close;

      flag:= (CrossList1.Count>0) or // признак необходимости изменений
        (CrossList2.Count>0) or (CrossDel1.Count>0) or (CrossDel2.Count>0);

      if flag then begin
        //------------------------- готовим порции текстов SQL для записи в базу
        j:= -1;
        NewListSQL(j);
        //----------------------------------------------------------- добавление
        if (CrossList1.Count>0) then begin // источник soTecDocBatch
          s:= ' rAdd=1; rSrc='+IntToStr(Cache.FDCA.GetSourceGBcode(soTecDocBatch))+';';
          for i:= 0 to CrossList1.Count-1 do begin
            if (arListsSql[j].Count>StrLimit) then NewListSQL(j);
            if (i=0) or (arListsSql[j].Count=2) then arListsSql[j].Add(s);
            arListsSql[j].Add(' select rCrossID, errLink from Vlad_CSS_AddWareCross(');
            arListsSql[j].Add(sWare+', '+IntToStr(CrossList1[i])+', '+sUser+', :rSrc)');
            arListsSql[j].Add(' into :rWare, :err; if (err=0 and rWare>0) then suspend;');
            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
          end;
          CrossList1.Clear;
        end;
        if (CrossList2.Count>0) then begin // источник soTDsupersed
          s:= ' rAdd=1; rSrc='+IntToStr(Cache.FDCA.GetSourceGBcode(soTDsupersed))+';';
          for i:= 0 to CrossList2.Count-1 do begin
            if (arListsSql[j].Count>StrLimit) then NewListSQL(j);
            if (i=0) or (arListsSql[j].Count=2) then arListsSql[j].Add(s);
            arListsSql[j].Add(' select rCrossID, errLink from Vlad_CSS_AddWareCross(');
            arListsSql[j].Add(sWare+', '+IntToStr(CrossList2[i])+', '+sUser+', :rSrc)');
            arListsSql[j].Add(' into :rWare, :err; if (err=0 and rWare>0) then suspend;');
            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
          end;
          CrossList2.Clear;
        end;
        //------------------------------------------------------------- удаление
        if (CrossDel1.Count>0) then begin  // источник soTecDocBatch
          s:= ' rAdd=0; rSrc='+IntToStr(Cache.FDCA.GetSourceGBcode(soTecDocBatch))+';';
          for i:= 0 to CrossDel1.Count-1 do begin
            if (arListsSql[j].Count>StrLimit) then NewListSQL(j);
            if (i=0) or (arListsSql[j].Count=2) then arListsSql[j].Add(s);
            arListsSql[j].Add(' select rCrossID from Vlad_CSS_DelWareCross(');
            arListsSql[j].Add(sWare+', '+IntToStr(CrossDel1[i])+', :rSrc)');
            arListsSql[j].Add(' into :rWare; if (rWare>0) then suspend;');
            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
          end;
          CrossDel1.Clear;
        end;
        if (CrossDel2.Count>0) then begin  // источник soTDsupersed
          s:= ' rAdd=0; rSrc='+IntToStr(Cache.FDCA.GetSourceGBcode(soTDsupersed))+';';
          for i:= 0 to CrossDel2.Count-1 do begin
            if (arListsSql[j].Count>StrLimit) then NewListSQL(j);
            if (i=0) or (arListsSql[j].Count=2) then arListsSql[j].Add(s);
            arListsSql[j].Add(' select rCrossID from Vlad_CSS_DelWareCross(');
            arListsSql[j].Add(sWare+', '+IntToStr(CrossDel2[i])+', :rSrc)');
            arListsSql[j].Add(' into :rWare; if (rWare>0) then suspend;');
            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
          end;
          CrossDel2.Clear;
        end;
        arListsSql[j].Add('end');

        //-------------------- запись в базу добавлений/удалений товаров-кроссов
        fnSetTransParams(ibs.Transaction, tpWrite, True);
        IBS.ParamCheck:= False;
        for j:= 0 to High(arListsSql) do begin
          IBS.SQL.Clear;
          IBS.SQL.AddStrings(arListsSql[j]);
          IBS.ExecQuery;
          while not IBS.Eof do begin
            if (IBS.FieldByName('rAdd').AsInteger=1) then begin // факт. добавление
              Src:= Cache.FDCA.GetSourceByGBcode(IBS.FieldByName('rSrc').AsInteger);
              if (Src=soTDsupersed) then
                CrossList2.Add(IBS.FieldByName('rWare').AsInteger)
              else CrossList1.Add(IBS.FieldByName('rWare').AsInteger);
            end else
              CrossDel1.Add(IBS.FieldByName('rWare').AsInteger); // факт. удаление

            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            IBS.Next;
          end;
          IBS.Close;
        end; // for j:= 0 to High(arListsSql)
        IBS.Transaction.Commit;   // запись в базу
      end;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(ibd);
    end;

    if flag then begin //-------------------------------- отрабатываем кеш
      for i:= 0 to CrossList1.Count-1 do       // добавляем источник soTecDocBatch
        Ware.CheckAnalogLink(CrossList1[i], soTecDocBatch);
      for i:= 0 to CrossList2.Count-1 do       // добавляем источник soTDsupersed
        Ware.CheckAnalogLink(CrossList2[i], soTDsupersed);
      for i:= 0 to CrossDel1.Count-1 do Ware.DelAnalogLink(CrossDel1[i], True); // удаляем
      if (CrossList1.Count>0) or (CrossList2.Count>0) then Ware.SortAnalogsByName;
    end;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do prMessageLOGS(nmProc+' (ware='+sWare+
      '): error load crosses: '+E.Message, 'import', False);
  end;
  finally
    TdtIBS.Close;
    ordIBS.Close;
    ordIBSr.Close;
    SetLength(ArArtCross, 0);
    for i:= 0 to High(arListsSql) do prFree(arListsSql[i]);
    SetLength(arListsSql, 0);
    prFree(CrossList1);
    prFree(CrossList2);
    prFree(CrossDel1);
    prFree(CrossDel2);
  end;
end;
//======= загрузка связок, порций критериев и текстов, файлов и ОН товара из TDT
function LoadWareLinksUsesCrisTextsFromTDT(WareID, UserID: Integer;
         var addLink3, addLinkON: Integer): String;  // ... для t_webarmprocedures
// addLink3 - кол-во новых связок 3, addLinkON - кол-во новых связок с ориг.№
const nmProc = 'LoadWareLinksUsesCrisTextsFromTDT'; // имя процедуры/функции
var LO: RLoadOpts;
begin
  LO.All:= True;
  LO.OnlyON:= False;
  LO.OnlyEng:= False;
  LO.OnlyCross:= False;
  LO.OnlyCris:= False;
  LO.OnlyGrafic:= False;
  LO.OnlyEAN:= False;
  LO.OnlyLinksPC:= False;
  LO.OnlyLinksCV:= False;
  LO.OnlyLinksAx:= False;
  LO.CheckTexts:= False;
  LO.CheckArt:= False;
  LO.WithEng:= True;
  Result:= LoadWareLinksUsesCrisTextsFromTDT(WareID, UserID, addLink3, addLinkON, LO, nil);
end;
//======= загрузка связок, порций критериев и текстов, файлов и ОН товара из TDT
function LoadWareLinksUsesCrisTextsFromTDT(WareID, UserID: Integer;
         var addLink3, addLinkON: Integer; var LO: RLoadOpts; ThreadData: TThreadData=nil): String;
// addLink3 - кол-во новых связок 3, addLinkON - кол-во новых связок с ориг.№
const nmProc = 'LoadWareLinksUsesCrisTextsFromTDT'; // имя процедуры/функции
var res, criTD, ii, linCount, i, pSupMFTD, NodeID, ModID, iLdmw: Integer;
    TimeProc, LocalTime: TDateTime;
    TdtIBD, ordIBD, ordIBDr: TIBDatabase;
    TdtIBS, TdtIBSt, ordIBS, ordIBSr: TIBSQL;
    s, pArticleTD, ss: String;
    fl, flINFO, flSleep: Boolean;
    arInfo: TArLinkInfo;
    NodeCodes: Tai;
    arWareONums: TarWareOnumOpts;
    ware: TWareInfo;
begin
  TimeProc:= Now;
  LocalTime:= TimeProc;
  Result:= '';
  flSleep:= not flDebug and fnGetActionTimeEnable(caeOnlyWorkTime);
//  TdtIBD:= nil;
//  ordIBD:= nil;
//  ordIBDr:= nil;
  TdtIBS:= nil;
  ordIBS:= nil;
  ordIBSr:= nil;
  setlength(arWareONums, 0);
  addLink3:= 0;
  addLinkON:= 0;
  try
    ware:= Cache.GetWare(WareID);
    s:= Cache.GetConstItem(pcBrandsNotLoadFromTD).StrValue; // проверяем исключения (MOTUL)
    if (s<>'') then begin
      s:= ','+s+',';
      ss:= ','+IntToStr(ware.WareBrandID)+',';
      if (pos(ss, s)>0) then
        raise Exception.Create('запрет загрузки бренда'); // or Exit  ???
    end;
    if (ware.ArticleTD='') or (ware.ArtSupTD<1) then
      raise Exception.Create('нет привязки к артикулу Текдок'); // or Exit  ???

    pArticleTD:= ware.ArticleTD;
    pSupMFTD:= ware.ArtSupTD; // SupID TecDoc (DS_MF_ID !!!)
    flINFO:= ware.IsINFOgr;

    TdtIBD:= cntsTDT.GetFreeCnt;
    try
      TdtIBSt:= fnCreateNewIBSQL(TdtIBD, 'TdtIBSt_'+nmProc, -1, tpRead);
      TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> проверка артикула
      if LO.CheckArt then begin
        with TdtIBS.Transaction do if not InTransaction then StartTransaction;
        TdtIBS.SQL.Text:= 'select art_id, DS_BRA from articles'+
          ' left join data_suppliers on ds_id=art_sup_id'+
          ' where art_nr=:art_nr and ds_mf_id='+IntToStr(pSupMFTD);
        TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
        TdtIBS.ExecQuery;
        if (TdtIBS.Bof and TdtIBS.Eof) or (TdtIBS.Fields[0].AsInteger<1) then begin
          TdtIBS.Close;
          TdtIBS.SQL.Text:= 'select DS_BRA from data_suppliers'+
            ' where ds_mf_id='+IntToStr(pSupMFTD);
          TdtIBS.ExecQuery;
          raise Exception.Create('не найден артикул TD;'+pArticleTD+';'+TdtIBS.Fields[0].AsString); // если артикула в TD нет
        end;
        TdtIBS.Close;
      end;
//      prMessageLOGS('begin load supID='+IntToStr(pSupMFTD)+' article '+pArticleTD, 'import_test', False);
      prMessageLOGS('begin load wareID='+IntToStr(WareID)+' warename '+ware.Name, 'import_test', False);
      prMessageLOGS('           supID='+IntToStr(pSupMFTD)+' article '+pArticleTD, 'import_test', False);

      CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
      ordIBD:= cntsORD.GetFreeCnt;
      try
        ordIBDr:= cntsORD.GetFreeCnt; // только для чтения
        try
          ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite);
          ordIBSr:= fnCreateNewIBSQL(ordIBDr, 'ordIBSr_'+nmProc);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> связки с моделями (не ИНФО-товары)
          if (LO.All or LO.OnlyLinksPC or LO.OnlyLinksCV or LO.OnlyLinksAx) and not flINFO then try
            ii:= 0;
            setlength(arInfo, 100);
            setlength(NodeCodes, 0);
//--------------------------------------------------------------------- легковые
            if (LO.All or LO.OnlyLinksPC) then begin
              //---------------------------------- нужные связки 2 и 3 из TecDoc
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              TdtIBS.SQL.Text:= 'select xGA, xMf, xMs, xMT, xlagt'+
                ' from GETARTICLEGAmodels(:art_nr, '+IntToStr(pSupMFTD)+', 2)'+
                ' order by xGA, xMf, xMs, xMT';
              TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
              LoadLinkListsFromTDT(TdtIBS, WareID, UserID, soTecDocBatch,
                                   constIsAuto, arInfo, ii, addLink3, ThreadData);
              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
              //----------------- нужные связки 2 и 3 из TecDoc по спецификациям
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              TdtIBS.SQL.Text:= 'select xGA, xMf, xMs, xMT, xlagt'+
                ' from GETpartGAModels(:art_nr, '+IntToStr(pSupMFTD)+', 2)'+
                ' order by xGA, xMf, xMs, xMT';
              TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
              LoadLinkListsFromTDT(TdtIBS, WareID, UserID, soTDparts,
                                   constIsAuto, arInfo, ii, addLink3, ThreadData);
              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            end; // if (LO.All or LO.OnlyLinksPC)

//-------------------------------------------------------------------- грузовики
            if (LO.All or LO.OnlyLinksCV) then begin
              //---------------------------------- нужные связки 2 и 3 из TecDoc
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              TdtIBS.SQL.Text:= 'select xGA, xMf, xMs, xMT, xlagt'+
                ' from GETARTICLEGAmodels(:art_nr, '+IntToStr(pSupMFTD)+', 16)'+
                ' order by xGA, xMf, xMs, xMT';
              TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
              LoadLinkListsFromTDT(TdtIBS, WareID, UserID, soTecDocBatch,
                                   constIsCV, arInfo, ii, addLink3, ThreadData);
              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
              //----------------- нужные связки 2 и 3 из TecDoc по спецификациям
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              TdtIBS.SQL.Text:= 'select xGA, xMf, xMs, xMT, xlagt'+
                ' from GETpartGAModels(:art_nr, '+IntToStr(pSupMFTD)+', 16)'+
                ' order by xGA, xMf, xMs, xMT';
              TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
              LoadLinkListsFromTDT(TdtIBS, WareID, UserID, soTDparts,
                                   constIsCV, arInfo, ii, addLink3, ThreadData);
              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            end; // if (LO.All or LO.OnlyLinksCV)

//-------------------------------------------------------------------------- оси
            if (LO.All or LO.OnlyLinksAx) then begin
            //------------------------------------ нужные связки 2 и 3 из TecDoc
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              TdtIBS.SQL.Text:= 'select xGA, xMf, xMs, xMT, xlagt'+
                ' from GETARTICLEGAmodels(:art_nr, '+IntToStr(pSupMFTD)+', 19)'+
                ' order by xGA, xMf, xMs, xMT';
              TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
              LoadLinkListsFromTDT(TdtIBS, WareID, UserID, soTecDocBatch,
                                   constIsAx, arInfo, ii, addLink3, ThreadData);
              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
              //----------------- нужные связки 2 и 3 из TecDoc по спецификациям
              with TdtIBS.Transaction do if not InTransaction then StartTransaction;
              TdtIBS.SQL.Text:= 'select xGA, xMf, xMs, xMT, xlagt'+
                ' from GETpartGAModels(:art_nr, '+IntToStr(pSupMFTD)+', 19)'+
                ' order by xGA, xMf, xMs, xMT';
              TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
              LoadLinkListsFromTDT(TdtIBS, WareID, UserID, soTDparts,
                                   constIsAx, arInfo, ii, addLink3, ThreadData);
              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            end; // if (LO.All or LO.OnlyLinksAx)

            linCount:= ii;
            if (Length(arInfo)<>ii) then SetLength(arInfo, linCount);
//-------------------------------------------------------------- инфо по связкам
            if linCount>0 then begin
              with ordIBSr.Transaction do if not InTransaction then StartTransaction;
              ordIBSr.SQL.Text:= 'select ldmwcode, LDEMDMOSCODE, LDEMTRNACODE'+
                ' from LINKDETAILMODEL inner join LINKDETMODWARE on ldmwldemcode=ldemcode'+
                ' and LDMWWARECODE=:WareID where LDMWWRONG="F" and LDEMWRONG="F"';
              ordIBSr.ParamByName('WareID').AsInteger:= WareID;
              ordIBSr.ExecQuery;
              while not ordIBSr.Eof do begin // проставляем коды связок 3
                NodeID:= ordIBSr.FieldByName('LDEMTRNACODE').AsInteger;
                ModID := ordIBSr.FieldByName('LDEMDMOSCODE').AsInteger;
                iLdmw := ordIBSr.FieldByName('ldmwcode').AsInteger;
                for ii:= 0 to linCount-1 do with arInfo[ii] do
                  if (ldmw<1) and (nodeORD=NodeID) and (modORD=ModID) then ldmw:= iLdmw;
                TestCssStopException;
                ordIBSr.Next;
              end;
              ordIBSr.Close;

              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

            //------------------------------- порции условий и текстов из TecDoc
              LoadModelNodeWareUseAndTextListsFromTDT(TdtIBS, TdtIBSt, ordIBS, ordIBSr,
                WareID, pSupMFTD, UserID, arInfo, ThreadData, LO.CheckTexts);

              CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

              ordIBS.SQL.Clear;
              ordIBSr.SQL.Clear; // здесь используется в цикле
              TdtIBS.SQL.Clear;
              setlength(NodeCodes, linCount);
              for ii:= 0 to linCount-1 do with arInfo[ii] do //  для отсева повторений нод
                NodeCodes[ii]:= fnIfInt(fnInIntArray(nodeORD, NodeCodes)<0, nodeORD, 0);
              for ii:= 0 to linCount-1 do with arInfo[ii] do if (NodeCodes[ii]>0) then begin
                LoadWareNodeInfoTextFromTDT(WareID, pSupMFTD, nodeORD, UserID,
                  Src, sys, pArticleTD, TdtIBS, ordIBS, ordIBSr, ThreadData);
                CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
              end;
            end; // if linCount>0
            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
          finally
            for i:= 0 to High(arInfo) do begin
              setLength(arInfo[i].PartNums, 0);
              setLength(arInfo[i].PartLagts, 0);
              for ii:= 0 to High(arInfo[i].UsesLists) do
                if Assigned(arInfo[i].UsesLists[ii]) then prFree(arInfo[i].UsesLists[ii]);
              setLength(arInfo[i].UsesLists, 0);
              for ii:= 0 to High(arInfo[i].TextLists) do
                if Assigned(arInfo[i].TextLists[ii]) then prFree(arInfo[i].TextLists[ii]);
              setLength(arInfo[i].TextLists, 0);
            end;
            setlength(arInfo, 0);
            setlength(NodeCodes, 0);
          end; // if LO.All and not flINFO

//>>>>>>>>>>>>>>>>>>>>>>>> связи товара с двигателями из TecDoc (не ИНФО-товары)
          if (LO.All or LO.OnlyEng) and not flINFO then begin
            ss:= LoadWareEngLinksUsesFromTDT(WareID, UserID, LO.addLinkEng, ThreadData, False);
            if ss<>'' then prMessageLOGS(nmProc+': error eng links '+ss, 'import', False);

// что делать с грузовиками ???

            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
          end;

//>>>>>>>>>>>>>>>>>>>>>>>>> файлы рисунков/документов по товару (не ИНФО-товары)
          if (LO.All or LO.OnlyGrafic) and not flINFO and not ware.PictShowEx then begin
            s:= LoadWareGraFileNamesFromTDT(WareID, UserID);
            if s<>'' then prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+
              '): error Ware FileNames: '+s, 'import', False);
            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
          end; //  if (LO.All or LO.OnlyGrafic) and not flINFO

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> критерии товара из TecDoc  (не ИНФО-товары)
          if (LO.All or LO.OnlyCris) and not flINFO then begin
            LoadWareCrisFromTDT(WareID, pSupMFTD, UserID, pArticleTD, ThreadData);

            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
          end; // if (LO.All or LO.OnlyCris) and not flINFO

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> кроссы товара из TecDoc (и ИНФО-товары)
          if (LO.All or LO.OnlyCross) then begin
            LoadWareCrossesFromTDT(TdtIBS, ordIBS, ordIBSr, WareID, pSupMFTD, UserID, pArticleTD, ThreadData);

            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
          end; // if not OnlyON and not OnlyCris

//>>>>>>>>>>>> номера EAN и параметры упаковки товара из TecDoc (не ИНФО-товары)
          if (LO.All or LO.OnlyEAN) and not flINFO then begin
            LoadWareEANandPackFromTDT(TdtIBS, ordIBS, ordIBSr, WareID, pSupMFTD, UserID, pArticleTD, ThreadData);

            CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
            CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
          end; // if not OnlyON and not OnlyCris

        finally
          prFreeIBSQL(ordIBSr);
          cntsORD.SetFreeCnt(ordIBDr);
        end;
      finally
        prFreeIBSQL(ordIBS);
        cntsORD.SetFreeCnt(ordIBD);
      end;
    finally
      prFreeIBSQL(TdtIBS);
      prFreeIBSQL(TdtIBSt);
      cntsTDT.SetFreeCnt(TdtIBD);
    end;

//>>>>>>>>>>>>>>>>>>>>> поиск оригинальных номеров товара в TDT (и ИНФО-товары)
    if (LO.All or LO.OnlyON) then try  //  and not flINFO  // 18.05.2018
      arWareONums:= fnGetWareONumsFromTDT(WareID, pSupMFTD, pArticleTD);
      ss:= '';
      with Cache.FDCA do for i:= Low(arWareONums) to high(arWareONums) do begin
        with arWareONums[i] do if mfau>0 then begin
          res:= resAdded;
          criTD:= 0;
          s:= CheckOrigNumLink(res, WareID, mfau, criTD, ONum, soTecDocBatch, userID);
          fl:= res<>resError;
          if not fl then
            prMessageLOGS(nmProc+' (ware='+IntToStr(WareID)+'): '+s, 'import', False);
          if res=resAdded then inc(addLinkON);

        end else if (pos(mfName, ss)<1) then
          ss:= ss+fnIfStr(ss='', '', ',')+mfName; // не найденные произв.ОН

        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
        CheckSleepProc(LocalTime, flSleep); // в рабочее время - задержка пропорционально длительности процесса
      end;

      if ss<>'' then begin // не найденные произв.ОН
        prMessageLOGS(fnMakeAddCharStr(IntToStr(WareID), 10, True)+'- '+ss, 'import_notmfon', False);
        raise Exception.Create('нет произв.ОН: '+ss);
      end;
    finally
      setlength(arWareONums, 0);
    end; // if (LO.All or LO.OnlyON)

    prMessageLOGS('  end load wareID='+IntToStr(WareID), 'import_test', False);
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do begin
      Result:= nmProc+' (ware='+IntToStr(WareID)+'): '+E.Message;
      if (pos('не найден артикул TD', Result)<1)
        and ((pos('запрет загрузки бренда', Result)<1))
        and ((pos('отмечена, как неверная', Result)<1)) then
        prMessageLOGS(Result, 'import', False);
    end;
  end;

  CheckSleepProc(TimeProc, flSleep); // в рабочее время - задержка пропорционально длительности процесса
end;
//============== вычисляет процент выполнения пакетной загрузки для вывода в лог
function GetOrdLoadProc: string;
const nmProc = 'GetOrdLoadProc'; // имя процедуры/функции
var ibsOrd: TIBSQL;
    ibOrd: TIBDatabase;
    proc: Single;
    countNow, countAll: Integer;
begin
  Result:= '';
  ibsOrd:= nil;
  ibOrd:= nil;
  proc:= 0;
  try
    ibOrd:= cntsORD.GetFreeCnt;
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_', -1, tpRead, True);
    ibsOrd.SQL.Text:= 'select countNow, countAll, countNow/countAll*100 as proc from'+
      ' (select (select count(*) from WAREARTICLETD wa'+
      '  inner join wareoptions wo on wo.wowarecode=wa.watdwarecode and wo.woarhived="F"'+
      '  where wa.watdwarecode<=(select cast(spcvalue as integer) from'+
      '    SERVERPARAMCONSTANTS where spccode=31) and wa.watdwrong="F") as countNow,'+
      '  count(*) as countAll from WAREARTICLETD wa1'+
      '  inner join wareoptions wo1 on wo1.wowarecode=wa1.watdwarecode and wo1.woarhived="F"'+
      '  where wa1.watdwrong="F")';
    ibsOrd.ExecQuery;
    if not (ibsOrd.Eof and ibsOrd.Bof) then begin
      countNow:= ibsOrd.FieldByName('countNow').AsInteger;
      countAll:= ibsOrd.FieldByName('countAll').AsInteger;
      if (countAll>0) and (countNow>0) then proc:= countNow*100/countAll;
      if fnNotZero(proc) then Result:= #10'Связанных товаров: всего '+
        IntToStr(countAll)+', обработано '+IntToStr(countNow)+
        ' ('+FormatFloat(cFloatFormatSumm, proc)+' %)';
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      Result:= '';
    end;
  end;
  prFreeIBSQL(ibsOrd);
  cntsOrd.SetFreeCnt(ibOrd);
end;
//===== пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
function AddLoadWaresInfoFromTDT(UserID: Integer; ThreadData: TThreadData=nil; filter_data: String=''): TStringList; // must Free Result
const nmProc = 'AddLoadWaresInfoFromTDT'; // имя процедуры/функции
      RepAddLoads = 'rep_add_loads_'; // шаблон файлов отчетов
      StopMess = 'пакетная загрузка остановлена: ';
//      sZero:= ' -     0 связ.,     0 ориг.н.';
// в ini-файле в секции [reports] параметры:
// LastAddLoadWare: =0 - пред.загрузка закончена,
//   >0 - код последнего обработанного товара, загрузка прервана,
//   =-1 - загрузка закончена, но отчеты не отправлены
// addWares - список кодов товаров через запятую, если не задан - все товары
var i, j, MgID, addLink3, addLinkON, istart, iPercent,
      addLink3a, addLinkONa, addLinkEnga, userAdm: Integer;
    s, nFile, nFile1, repPath, str, From, ss: string;
    BadTextSups: Tai; // массив кодов произв. для замены инфо-текстов
    OnlySups: Tai; // массив кодов произв. для выборочной загрузки
    Ware: TWareInfo;
    pIniFile: TIniFile;
    flag, SendRep, flSelfStart, flAllSups, flLoad, flFullLoad: Boolean;
    ListFiles, Body: TStringList;
    TimeProc: TDateTime;
    Percent: Single;
    LO: RLoadOpts;
  //------------------------------------------------------- загрузка по 1 товару
  procedure AddLoadWare(WareID: integer);
  var rep_file: textfile;
  begin
    try
      LO.CheckTexts:= (Length(BadTextSups)>0) and (fnInIntArray(Ware.ArtSupTD, BadTextSups)>-1); // произв. для замены инфо-текстов
      addLink3:= 0;
      addLinkON:= 0;
      LO.addLinkEng:= 0; //----------------- загрузка всех параметров товара из TDT

      s:= LoadWareLinksUsesCrisTextsFromTDT(WareID, UserID, addLink3, addLinkON, LO, ThreadData);

      if (addLink3>0) or (addLinkON>0) or (LO.addLinkEng>0) or (s<>'') then begin // пишем в отчет, если добавилось что-то или были ошибки
        addLink3a:= addLink3a+addLink3;
        addLinkONa:= addLinkONa+addLinkON;
        addLinkEnga:= addLinkEnga+LO.addLinkEng;
        str:= fnMakeAddCharStr(Ware.Name, 60, True)+' - '+
              fnMakeAddCharStr(IntToStr(addLink3), 5)+' связ. '+
              fnMakeAddCharStr(IntToStr(addLinkON), 5)+' ориг.н. '+
              fnMakeAddCharStr(IntToStr(LO.addLinkEng), 5)+' связ.двиг.';
        if (s<>'') then begin
          if (pos('не найден артикул TD', s)>0) then begin
//            s:= StringReplace(StringReplace(s, #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);
            prMessageLOGS(';'+IntToStr(WareID)+';'+s, 'import_no_art', False); // собираем коды товаров с ненайденными артикулами
          end else if (pos('запрет загрузки бренда', s)>0) then begin
            prMessageLOGS(';'+IntToStr(WareID)+';'+s, 'import_no_load', False); // собираем коды товаров с запретом загрузки
          end else if (pos('отмечена, как неверная', s)>0) then begin
            prMessageLOGS(';'+IntToStr(WareID)+';'+s, 'import_wrong', False); // собираем коды товаров с запретом загрузки
          end else begin
            prMessageLOGS(nmProc+': ошибки загрузки (ware='+IntToStr(WareID)+'): '+str+#10, 'import', False);
            s:= StringReplace(StringReplace(s, #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);
            prMessageLOGS(';'+IntToStr(WareID)+';'+s, 'import_err_wares', False); // собираем коды сбойных товаров
          end;
        end else try
          MgID:= Ware.ManagerID;
          nFile:= repPath+RepAddLoads+IntToStr(MgID); // файл отчета о пакетной загрузке прод.менеджера MgID
          flag:= not FileExists(nFile);
          try
            AssignFile(rep_file, nFile); // назначаем файл отчета
            if flag then ReWrite(rep_file) else Append(rep_file);
            writeln(rep_file, str); // записываем строку по товару в файл
            Flush(rep_file);
          finally
            closefile(rep_file); // закрываем файл отчета
          end;
        except
          on E: Exception do fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc,
            'error save to repfile: wareID='+IntToStr(WareID), E.Message, '', false, 'import')
        end;
      end;
      Cache.SaveNewConstValue(pcLastAddLoadWare, userAdm, IntToStr(WareID)); // записываем код обработанного товара
    except
      on E: EBOBError do raise EBOBError.Create(E.Message);
      on E: Exception do raise Exception.Create(StopMess+'error wareID='+IntToStr(WareID)+' - '+E.Message);
    end;

    if flSelfStart then begin // проверки в режиме автозапуска
      if (Cache.GetConstItem(pcSelfStartAddLoadWare).IntValue<>1) then // режим
        raise Exception.Create(StopMess+'last wareID='+IntToStr(WareID)+' - выключен режим автозапуска');
      if not fnGetActionTimeEnable(caeSmallWork) then                  // доступное время
        raise Exception.Create(StopMess+'last wareID='+IntToStr(WareID)+' - запретный период времени');
    end;

    CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы
  end;
  //-----------------------------------------------------
begin
  Result:= TStringList.Create; // отчет для администратора
  pIniFile:= TINIFile.Create(nmIniFileBOB);
  From:= pIniFile.ReadString('mail', 'SysAdresFrom', '');
  Body:= TStringList.Create;
  setlength(BadTextSups, 0);
  setlength(OnlySups, 0);
  ListFiles:= nil;
  addLink3a:= 0;
  addLinkONa:= 0;
  addLinkEnga:= 0;
  userAdm:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
  flSelfStart:= (filter_data=cSelfStart);
  TimeProc:= Now;
  flFullLoad:= False;
  try try                       // массив кодов произв. для замены инфо-текстов
    with fnSplit(',', pIniFile.ReadString('reports', 'BadTextSups', '')) do try
      if Count>0 then begin
        setlength(BadTextSups, Count);
        for j:= 0 to Count-1 do BadTextSups[j]:= StrToIntDef(Strings[j], 0);
      end;
    finally Free; end;        // массив кодов произв. для выборочной загрузки
    with fnSplit(',', pIniFile.ReadString('reports', 'OnlySups', '')) do try
      if Count>0 then begin
        setlength(OnlySups, Count);
        for j:= 0 to Count-1 do OnlySups[j]:= StrToIntDef(Strings[j], 0);
      end;
    finally Free; end;
    flAllSups:= (length(OnlySups)<1);

    repPath:= fnTestDirEnd(pIniFile.ReadString('mail', DirRepFiles, DirRepFilesDef), False); // путь к папке д/файлов отчетов
    if not DirectoryExists(repPath) then CreateDir(repPath);
    repPath:= fnTestDirEnd(repPath);

    istart:= Cache.GetConstItem(pcLastAddLoadWare).IntValue;
    SendRep:= (pIniFile.ReadInteger('reports', 'SendRep', 0)=1);  // True - отправлять отчеты

    if (istart>-1) then begin //--------------------------------------- загрузка
      SetExecutePercent(UserID, ThreadData, 1);

      LO.CheckArt   := True;
      LO.OnlyON     := pIniFile.ReadInteger('reports', 'OnlyON', 0)=1;
      LO.OnlyEng    := pIniFile.ReadInteger('reports', 'OnlyEng', 0)=1;
      LO.OnlyCross  := pIniFile.ReadInteger('reports', 'OnlyCross', 0)=1;
      LO.OnlyCris   := pIniFile.ReadInteger('reports', 'OnlyCris', 0)=1;
      LO.OnlyGrafic := pIniFile.ReadInteger('reports', 'OnlyGrafic', 0)=1;
      LO.OnlyEAN    := pIniFile.ReadInteger('reports', 'OnlyEAN', 0)=1;
      LO.OnlyLinksPC:= pIniFile.ReadInteger('reports', 'OnlyLinksPC', 0)=1;
      LO.OnlyLinksCV:= pIniFile.ReadInteger('reports', 'OnlyLinksCV', 0)=1;
      LO.OnlyLinksAx:= pIniFile.ReadInteger('reports', 'OnlyLinksAx', 0)=1;

      LO.All:= not LO.OnlyON and not LO.OnlyCross and not LO.OnlyCris
               and not LO.OnlyGrafic and not LO.OnlyEAN and not LO.OnlyLinksPC
               and not LO.OnlyLinksCV and not LO.OnlyLinksAx;
      LO.WithEng   := LO.All;

      s:= pIniFile.ReadString('reports', 'addWares', ''); // список кодов товаров
      flFullLoad:= (s='');
      if not flFullLoad then begin // если задан список кодов товаров
        ListFiles:= fnSplit(',', s);
        if (ListFiles.Count>0) then begin // определяем, с какого кода начинать
          j:= ListFiles.IndexOf(IntToStr(istart));
          if j>-1 then istart:= j+1 else istart:= 0;
        end else istart:= 0;

      end else if (istart=0) then istart:= 1 // новая полная загрузка
      else istart:= istart+1; // полная загрузка прерывалась, начинаем со следующего кода

      if flSelfStart then
        prMessageLOGS(nmProc+': .......... автозапуск загрузки данных из TecDoc', 'import', False);
      ss:= '';
      if flFullLoad then begin //------------------------------- полная загрузка
        prMessageLOGS(nmProc+': .......... начинаю пакетную загрузку данных из TecDoc', 'import', False);
        iPercent:= 0;
        Percent:= 90*1000/(High(Cache.arWareInfo)-istart);
        for i:= istart to High(Cache.arWareInfo) do begin
          if Cache.WareExist(i) then begin
            Ware:= Cache.GetWare(i, True);
            flLoad:= (Ware<>NoWare) and not Ware.IsArchive
                     and (Ware.ArtSupTD>0) and (Ware.ArticleTD<>'')
                     and (flAllSups or (fnInIntArray(Ware.ArtSupTD, OnlySups)>-1));

            if flLoad then begin // проверяем исключения (MOTUL)
              s:= Cache.GetConstItem(pcBrandsNotLoadFromTD).StrValue;
              if (s<>'') then begin
                s:= ','+s+',';
                ss:= ','+IntToStr(Ware.WareBrandID)+',';
                flLoad:= (pos(ss, s)<1);
                ss:= '';
              end;
            end;

            if flLoad then AddLoadWare(i); // загрузка по 1 товару
          end;
          if iPercent>=1000 then begin               // отображение процентов
            SetExecutePercent(UserID, ThreadData, Percent);
            iPercent:= 0;
          end else inc(iPercent);
        end; // for

      end else try  //--------------------------------------- загрузка по списку
        prMessageLOGS(nmProc+': .......... начинаю загрузку данных из TecDoc по списку кодов', 'import', False);
        Percent:= 90/(ListFiles.Count-istart);
        for i:= istart to ListFiles.Count-1 do begin // здесь в ListFiles список кодов товаров
          j:= StrToIntDef(ListFiles[i], 0);
          if Cache.WareExist(j) then Ware:= Cache.GetWare(j, True) else Ware:= NoWare;

          if (Ware=NoWare) or Ware.IsArchive or (Ware.ArtSupTD<1) or (Ware.ArticleTD='') then begin
            if (Ware=NoWare) then ss:= ss+#10'not found ware id='+IntToStr(j)
            else if Ware.IsArchive then ss:= ss+#10'archived ware id='+IntToStr(j)+' - '+Ware.Name
            else if (Ware.ArtSupTD<1) or (Ware.ArticleTD='') then
              ss:= ss+#10'not found TD link ware id='+IntToStr(j)+' - '+Ware.Name;
          end else begin
            ss:= '';
            s:= Cache.GetConstItem(pcBrandsNotLoadFromTD).StrValue;
            if (s<>'') then            // проверяем исключения (MOTUL)
              if (pos(','+IntToStr(Ware.WareBrandID)+',', ','+s+',')>0) then
                ss:= ss+#10'Not Load Brand='+IntToStr(Ware.WareBrandID)+
                           ' ware id='+IntToStr(j)+' - '+Ware.Name;

            if (ss='') then AddLoadWare(j); // загрузка по 1 товару
          end;
          SetExecutePercent(UserID, ThreadData, Percent); // отображение процентов
        end; // for
      finally
        if (ss<>'') then prMessageLOGS(nmProc+'(load ListWares): '+ss, 'import', False);
      end;

      if SendRep then istart:= -1 else istart:= 0; // признак - 0 - окончание загрузки, -1 - отчеты не отправлены
      Cache.SaveNewConstValue(pcLastAddLoadWare, userAdm, IntToStr(istart)); // записываем признак
      prMessageLOGS(nmProc+': ...... окончание загрузки данных из TecDoc', 'import', False);
      if flSelfStart then // если автозапуск
        Cache.SaveNewConstValue(pcSelfStartAddLoadWare, userAdm, '0'); // сбрасываем признак автозапуска


      j:= 0;
      s:= Cache.CheckWareFiles(j); // удаление неиспользуемых файлов рисунков
      if s<>'' then prMessageLOGS(nmProc+': '+s, 'import', False);
      if j>0 then prMessageLOGS(nmProc+': удалено строк неиспользуемых файлов - '+IntToStr(j), 'import', False);

      if (addLink3a>0) or (addLinkONa>0) or (addLinkEnga>0) then
        Result.Add(nmProc+': load - '+
          fnMakeAddCharStr(IntToStr(addLink3a), 5)+' links, '+
          fnMakeAddCharStr(IntToStr(addLinkONa), 5)+' ON,'+
          fnMakeAddCharStr(IntToStr(addLinkEnga), 5)+' eng links');
      Result.Add(nmProc+': time = '+FloatToStr(RoundTo((Now-TimeProc)*60*60*24,-5))+' sec');
    end; // загрузка

    if (istart<0) and SendRep then begin //------------------ рассылка отчетов
      flag:= True; // признак нормального окончания рассылки
      ListFiles:= fnListAllFiles(RepAddLoads+'*', repPath); // список файлов отчетов
      for i:= 0 to ListFiles.Count-1 do begin // идем по списку файлов отчетов

        CheckStopExecute(UserID, ThreadData); // проверка остановки процесса или системы

        nFile:= ListFiles[i];
        nFile1:= repPath+'err_'+RepAddLoads+IntToStr(MgID);
        istart:= length(repPath)+length(RepAddLoads)+1;
        s:= copy(nFile, istart, length(nFile));
        MgID:= StrToIntDef(s, 0);
        if (MgID<1) or not Cache.EmplExist(MgID) then begin
          ss:= 'не найден менеджер, id='+IntToStr(MgID);
          fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, ss, '', '', false, 'import');
          DeleteFile(nFile1);
          RenameFile(nFile, nFile1);
          flag:= False;
          Continue;
        end;

        str:= Cache.arEmplInfo[MgID].Mail;
        if (str='') then begin
          ss:= 'В базе нет E-mail менеджера, id='+IntToStr(MgID);
          fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, ss, '', '', false, 'import');
          DeleteFile(nFile1);
          RenameFile(nFile, nFile1);
          flag:= False;
          Continue;
        end;

        Body.Clear;
        Body.AddStrings(fnStringsLogFromFile(nFile));
        if Body.Count>0 then begin
          if Body.Count>1 then Body.Sort; // сортируем

          Result.Add(' ');                // в отчет для администратора
          Result.Add(' '+Cache.arEmplInfo[MgID].EmplLongName);
          Result.Add(' ');
          Result.Capacity:= Result.Capacity+Body.Count;
          for j:= 0 to Body.Count-1 do Result.Add(Body[j]);

          ss:= n_SysMailSend(str, 'отчет о загрузке данных из TecDoc', Body, nil, From, '', True);
          if ss='' then begin
            ss:= 'отправлен отчет для менеджера, id='+IntToStr(MgID);
            fnWriteToLogPlus(ThreadData, lgmsInfo, nmProc, ss, '', '', false, 'import');
//            DeleteFile(nFile);
            nFile1:= repPath+'send_'+RepAddLoads+IntToStr(MgID); // для отладки
            DeleteFile(nFile1);                                  // для отладки
            RenameFile(nFile, nFile1);                           // для отладки
          end else begin
            ss:= 'ошибка отправки отчета для менеджера, id='+IntToStr(MgID)+': '+ss;
            fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, ss, '', '', false, 'import');
            DeleteFile(nFile1);
            RenameFile(nFile, nFile1);
            flag:= False;
          end;
        end; // if Body.Count>0
      end; // for

      Cache.SaveNewConstValue(pcLastAddLoadWare, userAdm, '0'); // записываем признак окончания загрузки
    end;

  except
    on E: EBOBError do begin
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'error', E.Message, '', false, 'import');
      Result.Add(' '+E.Message);
      raise EBOBError.Create(E.Message);
    end;
    on E: Exception do begin
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, 'error', E.Message, '', false, 'import');
      Result.Add(' '+E.Message);
      Result.Insert(0, GetMessageFromSelf);
//      ss:= n_SysMailSend(fnGetSysAdresVlad(caeOnlyDayLess), 'Error load', Result, nil, From, '', True);
//      Result.Clear;
    end;
  end;
  finally
    if flFullLoad then begin // если пакетная загрузка
      ss:= GetOrdLoadProc; // процент выполнения пакетной загрузки
//      if (ss<>'') then Result.Add(#10'% загрузки ~ '+ss);
      if (ss<>'') then Result.Add(ss);
    end;
    prFree(ListFiles);
    prFree(Body);
    prFree(pIniFile);
    setlength(BadTextSups, 0);
    setlength(OnlySups, 0);
  end;
end;

//******************************************************************************
//                 вспомагательные и проверочные функции
//******************************************************************************
//----------------------------------- проверка артиклей на Upper в WAREARTICLETD
function TestUpperWareArticleFromTDT: TStringList; // must Free Result
const nmProc = 'TestUpperWareArticleFromTDT'; // имя процедуры/функции
var TdtIBD, ordIBD: TIBDatabase;
    TdtIBS, ordIBS: TIBSQL;
    i: integer;
    s: string;
begin
  Result:= TStringList.Create;
  TdtIBD:= nil;
  ordIBD:= nil;
  TdtIBS:= nil;
  ordIBS:= nil;
  try try
    TdtIBD:= cntsTDT.GetFreeCnt;
    TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
    TdtIBS.SQL.Text:= 'select art_nr from articles'+
      ' where art_sup_id = (select DS_ID from DATA_SUPPLIERS where DS_MF_ID = :mf)'+
      ' and ( art_nr = :art1 or upper(art_nr) = :art2 or lower(art_nr) = :art3 )';
    TdtIBS.Prepare;

    ordIBD:= cntsORD.GetFreeCnt;
    ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite, true);
    ordIBS.SQL.Text:= 'update WAREARTICLETD set WATDARTICLE=:ARTnew'+
      ' where WATDARTICLE=:ARTold and WATDARTSUP=:ARTsup';
    ordIBS.Prepare;

    for i:= Low(cache.arWareInfo) to High(cache.arWareInfo) do
      if Cache.WareExist(i) then with Cache.GetWare(i) do try
        if IsArchive then continue;
        if (ArticleTD='') or (ArtSupTD<1) then continue;
        if (ArticleTD=LowerCase(ArticleTD)) and (ArticleTD=UpperCase(ArticleTD)) then continue;
//        if (ArticleTD=LowerCase(ArticleTD)) then continue;

        TdtIBS.ParamByName('mf').AsInteger:= ArtSupTD; // SupID TecDoc (DS_MF_ID !!!)
        TdtIBS.ParamByName('art1').AsString:= ArticleTD;
        TdtIBS.ParamByName('art2').AsString:= ArticleTD;
        TdtIBS.ParamByName('art3').AsString:= ArticleTD;
        TdtIBS.ExecQuery;
        if not (TdtIBS.Bof and TdtIBS.Eof) and (TdtIBS.Fields[0].AsString <> ArticleTD) then
          with ordIBS.Transaction do begin
            if not InTransaction then StartTransaction;
            ordIBS.Close;
            ordIBS.ParamByName('ARTsup').AsInteger:= ArtSupTD;
            ordIBS.ParamByName('ARTold').AsString:= ArticleTD;
            ordIBS.ParamByName('ARTnew').AsString:= TdtIBS.Fields[0].AsString;
            ordIBS.ExecQuery;                      // заменяем в базе
            Commit;
            s:= 'SupMF='+fnMakeAddCharStr(IntToStr(ArtSupTD), 5, True)+
              ' rewrite article '+fnMakeAddCharStr(ArticleTD, 25, True)+
              ' -> '+TdtIBS.Fields[0].AsString;
            ArticleTD:= TdtIBS.Fields[0].AsString; // заменяем в кеше
            Result.Add(s);
            prMessageLOGn(s, 'art_rewrite.txt');
          end;
        TdtIBS.Close;
      except
        on E: Exception do Result.Add('error article '+ArticleTD+': '+E.Message);
      end;
  except
    on E: Exception do Result.Add( nmProc+': '+E.Message);
  end;
  finally
    prFreeIBSQL(ordIBS);
    cntsORD.SetFreeCnt(ordIBD);
    prFreeIBSQL(TdtIBS);
    cntsTDT.SetFreeCnt(TdtIBD);
  end;
end;
//----------------------------------------------------- проверка связок артиклей
function TestNotLoadArticleLinksFromTDT(supliers: String=''): String;
const nmProc = 'TestNotLoadArticleLinksFromTDT'; // имя процедуры/функции
var TdtIBD, ordIBD: TIBDatabase;
    TdtIBS, ordIBS, ordIBSa: TIBSQL;
    i, pSupMFTD, pWareID, pModID, pMLid, pMFid: integer;
    s, pArticleTD, sName, sWare, sf, nf, nf1, sVis: string;
    Ware: TWareInfo;
begin
  Result:= '';
  TdtIBD:= nil;
  ordIBD:= nil;
  TdtIBS:= nil;
  ordIBS:= nil;
  ordIBSa:= nil;
  try
    try
      ordIBD:= cntsORD.GetFreeCnt;
      ordIBSa:= fnCreateNewIBSQL(ordIBD, 'ordIBSa_'+nmProc);
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
      ordIBSa.SQL.Text:= 'select WATDARTSUP, WATDARTICLE, WATDWARECODE'+
        ' from WAREARTICLETD'+
        fnIfStr(supliers='', '', ' where WATDARTSUP in ('+supliers+')')+
        ' order by WATDARTSUP, WATDARTICLE';

      ordIBS.SQL.Text:= 'select count(ldemtrnacode)'+
        ' from LINKDETAILMODEL, LINKDETMODWARE, DIRMODELS'+
        ' where LDMWLDEMCODE=LDEMCODE and DMOSCODE=LDEMDMOSCODE'+
        ' and LDMWWARECODE=:WareID and DMOSTDCODE=:mt';
      ordIBS.Prepare;

      TdtIBD:= cntsTDT.GetFreeCnt;
      TdtIBS:= fnCreateNewIBSQL(TdtIBD, 'TdtIBS_'+nmProc, -1, tpRead, true);
      TdtIBS.SQL.Text:= 'select c, xMT, ms_mf_id, ms_mf_descr, ms_id, ms_descr,'+
        ' mt_descr, mt_from, mt_to, ms_from'+
        ' from ( select count(xGA) c, xMT from GETARTICLEGATYPESNew(:art_nr, :SupMF) group by xMT )'+
        ' left join model_types on mt_id = xMT'+
        ' left join model_series on ms_id = mt_ms_id'+
        ' order by ms_mf_descr, ms_descr, mt_descr';
      TdtIBS.Prepare;

      sf:= FormatDateTime('_mm_dd_hhmm', Now)+'.txt';
      ordIBSa.ExecQuery;
      while not ordIBSa.Eof do begin
        pWareID:= ordIBSa.FieldByName('WATDWARECODE').AsInteger;
        Ware:= Cache.GetWare(pWareID);
        if Ware.IsSale then begin
          TestCssStopException;
          ordIBSa.Next;
          Continue;
        end;
        pSupMFTD:= ordIBSa.FieldByName('WATDARTSUP').AsInteger;
        pArticleTD:= ordIBSa.FieldByName('WATDARTICLE').AsString;
        sWare:= ordIBSa.FieldByName('WATDWARECODE').AsString;
        sName:= Copy(Ware.Name, 1, 40);

        nf:= 'loads\NotLoad_'+Ware.GrpName+sf;
        nf1:= 'loads\Load_'+Ware.GrpName+sf;
        if not FileExists(nf) then begin
          s:= fnMakeAddCharStr(' код.т.GR', 10)+'  '+fnMakeAddCharStr('  товар', 42, True)+
            fnMakeAddCharStr('  произв.', 17, True)+fnMakeAddCharStr('  мод.ряд', 42, True)+
            fnMakeAddCharStr('  модель', 42, True)+fnMakeAddCharStr('  от', 10, True)+
            fnMakeAddCharStr('  до', 10, True)+fnMakeAddCharStr('код.м.TD ', 10)+'вид.пр.мр.м.';
          prMessageLOGn(s, nf);
        end;
        if not FileExists(nf1) then begin
          s:= fnMakeAddCharStr(' код.т.GR', 10)+'  '+fnMakeAddCharStr('  товар', 42, True)+
            fnMakeAddCharStr('  произв.', 17, True)+fnMakeAddCharStr('  мод.ряд', 42, True)+
            fnMakeAddCharStr('  модель', 42, True)+fnMakeAddCharStr('  от', 10, True)+
            fnMakeAddCharStr('  до', 10, True)+fnMakeAddCharStr('загружено', 10);
          prMessageLOGn(s, nf1);
          prMessageLOGn(' ', nf1);
        end;

        prMessageLOGn(' ', nf);
        TdtIBS.ParamByName('art_nr').AsString:= pArticleTD;
        TdtIBS.ParamByName('SupMF').AsInteger:= pSupMFTD;
        TdtIBS.ExecQuery;
        if (TdtIBS.Bof and TdtIBS.Eof) then begin
          s:= fnMakeAddCharStr(sWare, 10)+'  '+fnMakeAddCharStr(sName, 42, True)+'Not links in TecDoc';
          prMessageLOGn(s, nf);
          TdtIBS.Close;
          TestCssStopException;
          ordIBSa.Next;
          Continue;
        end;

        while not TdtIBS.Eof do begin
          if TdtIBS.FieldByName('ms_from').AsInteger<198001 then begin
            TestCssStopException;
            TdtIBS.Next;
            Continue;
          end;
          ordIBS.ParamByName('WareID').AsInteger:= pWareID;
          ordIBS.ParamByName('mt').AsInteger:= TdtIBS.FieldByName('xMT').AsInteger;
          ordIBS.ExecQuery;
          if (ordIBS.Bof and TdtIBS.Eof) then i:= 0 else i:= ordIBS.Fields[0].AsInteger;
          ordIBS.Close;
          if (i<1) then begin
            pMFid:= Cache.FDCA.Manufacturers.GetManufIDByTDcode(TdtIBS.FieldByName('ms_mf_id').AsInteger);
            if pMFid<1 then sVis:= '- - -'
            else begin
              sVis:= fnIfStr(Cache.FDCA.Manufacturers[pMFid].CheckIsVisible(1), '1', '0');
              pMLid:= Cache.FDCA.Manufacturers[pMFid].GetMfMLineIDByTDcode(TdtIBS.FieldByName('ms_id').AsInteger);
              if pMLid<1 then sVis:= sVis+' - -'
              else begin
                sVis:= sVis+' '+fnIfStr(Cache.FDCA.ModelLines[pMLid].IsVisible, '1', '0');
                pModID:= Cache.FDCA.ModelLines[pMLid].GetMLModelIDByTDcode(TdtIBS.FieldByName('xMT').AsInteger);
                if pModID<1 then sVis:= sVis+' -'
                else sVis:= sVis+' '+fnIfStr(Cache.FDCA.Models[pModID].IsVisible, '1', '0');
              end;
            end;

            s:= fnMakeAddCharStr(sWare, 10)+'  '+fnMakeAddCharStr(sName, 42, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('ms_mf_descr').AsString, 1, 15), 17, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('ms_descr').AsString, 1, 40), 42, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('mt_descr').AsString, 1, 40), 42, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('mt_from').AsString, 1, 8), 10, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('mt_to').AsString, 1, 8), 10, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('xMT').AsString, 1, 9), 10)+
              fnMakeAddCharStr(sVis, 12);
            prMessageLOGn(s, nf);
          end else begin
            s:= fnMakeAddCharStr(sWare, 10)+'  '+fnMakeAddCharStr(sName, 42, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('ms_mf_descr').AsString, 1, 15), 17, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('ms_descr').AsString, 1, 40), 42, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('mt_descr').AsString, 1, 40), 42, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('mt_from').AsString, 1, 8), 10, True)+
              fnMakeAddCharStr(Copy(TdtIBS.FieldByName('mt_to').AsString, 1, 8), 10, True)+
              fnMakeAddCharStr(IntToStr(i)+' links', 10);
            prMessageLOGn(s, nf1);
          end;
          TestCssStopException;
          TdtIBS.Next;
        end;
        TdtIBS.Close;
  //      Application.ProcessMessages;
        TestCssStopException;
        ordIBSa.Next;
      end;
      Result:= 'обработано '+supliers;
    finally
      prFreeIBSQL(ordIBS);
      prFreeIBSQL(ordIBSa);
      cntsORD.SetFreeCnt(ordIBD);
      prFreeIBSQL(TdtIBS);
      cntsTDT.SetFreeCnt(TdtIBD);
    end;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
end;

//******************************************************************************
//                         импорт - администрирование баз
//******************************************************************************
//======================= удаление моделей авто из базы ORD по файлу Excel (xls)
procedure prDeleteAutoModels(UserID: integer; FileName: string; ThreadData: TThreadData=nil);
// структура файла: имя листа - 'удалить модели'(нельзя менять),
// столбцы - произв.;мод.ряд;м.р.вид.;м.р.от;м.р.до;модель;м.вид.;м.от;м.до;код м.р.;код.мод.;результат (можно менять)
// обрабатывается 11-й столбец, результат записывается в 12-й столбец
const nmProc = 'prDeleteAutoModels'; // имя процедуры/функции
      iDelModID = 10; iResDelMod = 11;
var mORD, iDel, iErr, i, iLine, Del2, Del3, Delut, Delen, delTxt, delCriV, delEng: integer;
    ss: string;
    TimeProc: TDateTime;
    ordIBD: TIBDatabase;
    ordIBS: TIBSQL;
    ADOConnection: TADOConnection;
    ADOTable: TADOTable;
  //--------------------------------------------- запись значения в ячейку index
  procedure SaveValueADO(index: Word; txt: String);
  begin
    ADOTable.Edit;
    ADOTable.Fields[index].Value:= txt;
    ADOTable.Post;
  end;
  //------------------------------------ добавление строки и запись в 0-ю ячейку
  procedure AddRecordADO(S: String);
  begin
    ADOTable.Append;
    ADOTable.Fields[0].Value:= S;
    ADOTable.Post;
  end;
  //---------------------------------------------
begin
  TimeProc:= Now;
  iDel:= 0;
  iErr:= 0;
  Del2:= 0;
  Del3:= 0;
  Delut:= 0;
  Delen:= 0;
  delTxt:= 0;
  delCriV:= 0;
  delEng:= 0;
  ordIBS:= nil;
//  ordIBD:= nil;
  ADOConnection:= nil;
  ADOTable:= nil;
  with Cache.FDCA do try try
    ordIBD:= cntsORD.GetFreeCnt;
    try
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite, True);
      ordIBS.ParamCheck:= False; // запоминаем кол-во записей в таблицах
      ordIBS.SQL.Add('execute block returns (Del2 integer, Del3 integer, Delut integer,');
      ordIBS.SQL.Add('  Delen integer, delTxt integer, delCriV integer, delEng integer)');
      ordIBS.SQL.Add('as declare variable xcount integer = 0; begin');
      ordIBS.SQL.Add('  del2 = 0; del3 = 0; delut = 0; delen = 0;');
      ordIBS.SQL.Add('  delTxt = 0; delCriV = 0; delEng = 0;');
      ordIBS.SQL.Add('  select count(*) from linkdetailmodel into :del2;');
      ordIBS.SQL.Add('  select count(*) from linkdetmodware into :del3;');
      ordIBS.SQL.Add('  select count(*) from linkwaremodelnodeusage into :delut;');
      ordIBS.SQL.Add('  select count(*) from linkwarenodemodeltext into :xcount;');
      ordIBS.SQL.Add('  if (xcount>0) then delut=delut+xcount;');
      ordIBS.SQL.Add('  select count(*) from linkmodelsengines into :delen;');
      ordIBS.SQL.Add('  select count(*) from wareinfotexts into :delTxt;');
      ordIBS.SQL.Add('  select count(*) from warecrivalues into :delCriV;');
      ordIBS.SQL.Add('  select count(*) from direngines into :delEng;');
      ordIBS.SQL.Add('  suspend; end');
      ordIBS.ExecQuery;
      if not (ordIBS.Bof and ordIBS.Eof) then begin
        Del2    := ordIBS.Fields[0].AsInteger;
        Del3    := ordIBS.Fields[1].AsInteger;
        Delut   := ordIBS.Fields[2].AsInteger;
        Delen   := ordIBS.Fields[3].AsInteger;
        delTxt  := ordIBS.Fields[4].AsInteger;
        delCriV := ordIBS.Fields[5].AsInteger;
        delEng  := ordIBS.Fields[6].AsInteger;
      end;
      ordIBS.Close;

      ordIBS.SQL.Clear; // готовим текст для удаления 1-й модели
      ordIBS.SQL.Add('execute block returns (DelModel integer) as declare variable MLine integer = 0;');
      ordIBS.SQL.Add('  declare variable ldem integer = 0; declare variable ldmw integer = 0; begin');
      ordIBS.SQL.Add('  DelModel = 0;'); // в цикле меняем
      ordIBS.SQL.Add('  if (exists(select * from dirmodels m where m.dmoscode=:DelModel)) then begin');
      ordIBS.SQL.Add('    select m.dmosdrmlcode from dirmodels m where m.dmoscode=:DelModel into:MLine;');
      ordIBS.SQL.Add('    if (exists(select * from linkdetailmodel where ldemdmoscode=:DelModel)) then begin');
      ordIBS.SQL.Add('      for select l.ldemcode from linkdetailmodel l where l.ldemdmoscode=:DelModel into :ldem do begin');
      ordIBS.SQL.Add('        if (exists(select * from linkdetmodware lw where lw.ldmwldemcode=:ldem)) then begin');
      ordIBS.SQL.Add('          for select lw.ldmwcode from linkdetmodware lw where lw.ldmwldemcode=:ldem into :ldmw do begin');
      ordIBS.SQL.Add('            if (exists(select * from linkwaremodelnodeusage u where u.lwmnuldmwcode=:ldmw)) then');
      ordIBS.SQL.Add('              delete from linkwaremodelnodeusage u where u.lwmnuldmwcode=:ldmw;');
      ordIBS.SQL.Add('            if (exists(select * from linkwarenodemodeltext u where u.lwnmtldmw=:ldmw)) then');
      ordIBS.SQL.Add('              delete from linkwarenodemodeltext u where u.lwnmtldmw=:ldmw; end');
      ordIBS.SQL.Add('          delete from linkdetmodware lw where lw.ldmwldemcode=:ldem; end end');
      ordIBS.SQL.Add('      delete from linkdetailmodel l where l.ldemdmoscode=:DelModel; end');
      ordIBS.SQL.Add('    if (exists(select * from linkmodelsengines u where u.lmendmoscode=:DelModel)) then');
      ordIBS.SQL.Add('      delete from linkmodelsengines u where u.lmendmoscode=:DelModel;');
      ordIBS.SQL.Add('    delete from dirmodels m where m.dmoscode=:DelModel; ');
      ordIBS.SQL.Add('    if (not(exists(select * from dirmodels m where m.dmosdrmlcode=:MLine))) then begin');
      ordIBS.SQL.Add('      update dirmodellines ml set ml.drmlisvisible="F" where ml.drmlcode=:MLine; end end');
      ordIBS.SQL.Add('  suspend; end');
      try
        CoInitialize(nil);
        ADOConnection:= CreateADOConnection(ExpandFileName(FileName), atExcel2003); // подключаемся к файлу Excel как к БД
        ADOConnection.Open;
        ADOConnection.BeginTrans;

        ADOTable:= CreateADOTable(ADOConnection, '[удалить модели$]'); // лист книги как таблица
        ADOTable.Open;
        if ADOTable.FieldCount<(iResDelMod+1) then // проверяем кол-во столбцов
          raise Exception.Create(MessText(mtkNotEnoughParams)+' файла');

        for i:= 0 to ADOTable.FieldCount-1 do // символьные поля
          if (i in [0, 1, 5, iResDelMod]) then ADOTable.Fields[i].SetFieldType(ftString);
      except
        on E: Exception do begin
          prMessageLOGS(nmProc+': ошибка ADOConnection '+E.Message, 'import', False);
          raise Exception.Create(E.Message);
        end;
      end;

      iLine:= 0;
      while not ADOTable.Eof do begin
        try                              // считываем параметры 1-й строки файла
          if copy(ADOTable.Fields[0].AsString, 1, 6)='время:' then begin // старое время убираем
            SaveValueADO(0, '');
            TestCssStopException;
            ADOTable.Next;
            Continue;
          end;

          mORD:= fnStrToIntDef(ADOTable.Fields[iDelModID].AsString, 0);   // ID модели
          if (mORD<1) then raise Exception.Create(MessText(mtkNotEnoughParams));  // если не хватает параметров
          if not Models.ModelExists(mORD) then
            raise Exception.Create('не найдена'); // если не нашли для удаления

          ss:= '';
          with ordIBS.Transaction do if not InTransaction then StartTransaction;
          ordIBS.SQL[2]:= '  DelModel = '+IntToStr(mORD)+';';
          ordIBS.ExecQuery;                                  // удаляем
          if (ordIBS.Bof and ordIBS.Eof) or (ordIBS.Fields[0].AsInteger<>mORD) then
            raise Exception.Create('error execute block');
          SaveValueADO(iResDelMod, 'удалена'); // вписываем результат
          with ordIBS.Transaction do if InTransaction then Commit;
          inc(iDel);
        except
          on E: Exception do begin
            with ordIBS.Transaction do if InTransaction then Rollback;
            inc(iErr);
            prMessageLOGS(nmProc+': ошибка в строке '+IntToStr(iLine)+' '+E.Message, 'import', False);
            if E.Message<>'' then SaveValueADO(iResDelMod, E.Message); // вписываем сообщение
          end;
        end;
        ordIBS.Close;
        CheckStopExecute(UserID, ThreadData);
        ADOTable.Next;
        inc(iLine);
      end;

      with ordIBS.Transaction do if not InTransaction then StartTransaction;
      ordIBS.SQL.Clear; // вычисляем, сколько записей удалили, и чистим справочники
      ordIBS.SQL.Add('execute block returns (Del2 integer, Del3 integer, Delut integer,');
      ordIBS.SQL.Add('  Delen integer, delTxt integer, delCriV integer, delEng integer)');
      ordIBS.SQL.Add('as declare variable xcount integer = 0; begin');
      ordIBS.SQL.Add('  del2 = 0; del3 = 0; delut = 0; delen = 0;');
      ordIBS.SQL.Add('  delTxt = 0; delCriV = 0; delEng = 0;');
      ordIBS.SQL.Add('  select count(*) from linkdetailmodel into :del2;');
      ordIBS.SQL.Add('  select count(*) from linkdetmodware into :del3;');
      ordIBS.SQL.Add('  select count(*) from linkwaremodelnodeusage into :delut;');
      ordIBS.SQL.Add('  select count(*) from linkwarenodemodeltext into :xcount;');
      ordIBS.SQL.Add('  if (xcount>0) then delut=delut+xcount;');
      ordIBS.SQL.Add('  select count(*) from linkmodelsengines into :delen;');
      ordIBS.SQL.Add('  for select e.dengcode from direngines e into :xcount do');
      ordIBS.SQL.Add('    if (not(exists(select * from linkmodelsengines u where u.lmendengcode=:xcount))) then');
      ordIBS.SQL.Add('      delete from direngines u where u.dengcode=:xcount;');
      ordIBS.SQL.Add('  for select t.witcode from wareinfotexts t into :xcount do');
      ordIBS.SQL.Add('    if ((not(exists(select * from linkwarenodemodeltext u where u.lwnmtwit=:xcount))) and');
      ordIBS.SQL.Add('      (not(exists(select * from linkwarenodetext u1 where u1.lwntwit=:xcount)))) then');
      ordIBS.SQL.Add('      delete from wareinfotexts u where u.witcode=:xcount;');
      ordIBS.SQL.Add('  for select t.wcvscode from warecrivalues t into :xcount do');
      ordIBS.SQL.Add('    if ((not(exists(select * from linkwarecrivalues u where u.lwcvwcvscode=:xcount))) and');
      ordIBS.SQL.Add('      (not(exists(select * from linkwaremodelnodeusage u1 where u1.lwmnuwcvscode=:xcount)))) then');
      ordIBS.SQL.Add('      delete from warecrivalues u where u.wcvscode=:xcount;');
      ordIBS.SQL.Add('  select count(*) from wareinfotexts into :delTxt;');
      ordIBS.SQL.Add('  select count(*) from warecrivalues into :delCriV;');
      ordIBS.SQL.Add('  select count(*) from direngines into :delEng;');
      ordIBS.SQL.Add('  suspend; end');
      ordIBS.ExecQuery;
      if not (ordIBS.Bof and ordIBS.Eof) then begin
        Del2    := Del2    -ordIBS.Fields[0].AsInteger;
        Del3    := Del3    -ordIBS.Fields[1].AsInteger;
        Delut   := Delut   -ordIBS.Fields[2].AsInteger;
        Delen   := Delen   -ordIBS.Fields[3].AsInteger;
        delTxt  := delTxt  -ordIBS.Fields[4].AsInteger;
        delCriV := delCriV -ordIBS.Fields[5].AsInteger;
        delEng  := delEng  -ordIBS.Fields[6].AsInteger;
      end;
    finally
      prFreeIBSQL(ordIBS);
      cntsORD.SetFreeCnt(ordIBD);
    end;

    try
      AddRecordADO('-----------');                                    // итоги
      AddRecordADO('обработано:   '+IntToStr(iDel+iErr)+' строк');
      AddRecordADO('ошибки    :   '+IntToStr(iErr)+' строк');
      if iDel>0     then AddRecordADO('удалено   :   '+IntToStr(iDel)+' моделей');
      if Del2>0     then AddRecordADO('удалено   :   '+IntToStr(Del2)+' связок 2');
      if Del3>0     then AddRecordADO('удалено   :   '+IntToStr(Del3)+' связок 3');
      if Delut>0    then AddRecordADO('удалено   :   '+IntToStr(Delut)+' условий');
      if Delen>0    then AddRecordADO('удалено   :   '+IntToStr(Delen)+' марк.');
      if delTxt>0    then AddRecordADO('удалено   :   '+IntToStr(delTxt)+' текстов');
      if delCriV>0   then AddRecordADO('удалено   :   '+IntToStr(delCriV)+' зн.крит.');
      if delEng>0    then AddRecordADO('удалено   :   '+IntToStr(delEng)+' двиг.');
      AddRecordADO('-----------');
      AddRecordADO('время     : '+GetLogTimeStr(TimeProc));
    except
      on E: Exception do prMessageLOGS(nmProc+': ошибка в итогах '+E.Message, 'import', False);
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
      E.Message:= nmProc+': '+E.Message;
      raise Exception.Create(E.Message);
    end;
  end; // with Cache.FDCA
  finally
    if assigned(ADOConnection) then begin
      ADOConnection.CommitTrans;
      DestroyADOConnection(ADOConnection);
    end;
    DestroyADOTable(ADOTable);
    CoUnInitialize;
    if iDel>0 then begin
      FillDirEngines(False);
      FillDirModels(False);
      FillDirModelLines(False);
    end;
  end;
end;

//******************************************************************************
initialization
begin
end;
finalization
begin
end;
//******************************************************************************
{ синхронизация -  Группа 3.
+ - Связь товара с информационным файлом (рисунки, pdf-файлы).
+ - Связки товара с критериями.
+ - Привязка инфотекстов к связкам  товар-узел.
1 - Привязки критериев к связкам-3 по моделям.
1 - Привязки инфотекстов к связкам-3 по моделям.
1 - Привязки критериев к связкам-3 по двигателям.}
end.
