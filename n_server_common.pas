unit n_server_common; // ����� �������

interface
uses Windows, Classes, SysUtils, IniFiles, System.DateUtils, Math, DB, Forms, Contnrs,
     IBDatabase, IBSQL, IdSMTP, IdMessage, IdAttachmentFile, IdCharsets, IdText,
     Controls, IdGlobal, IdContext, IdTCPServer, ShellAPI, Types,
     n_free_functions, v_constants, v_DataTrans, v_Functions, n_DataCacheObjects,
     n_constants, n_functions, n_DataSetsManager, n_LogThreads, n_DataCacheAddition;

type
//------------------------------------------------------------ vc
  TMyClass = class
    procedure ServerExecute(AContext: TIdContext);
    procedure ServerWEBConnect(AContext: TIdContext);
    procedure ServerWEBArmConnect(AContext: TIdContext);
    procedure ServerManageConnect(AContext: TIdContext);
  public
  end;
//------------------------------------------------------------ vc

  TVSMail = class // Vladislav Software Mail
  public
    Xstring: String;
    constructor Create;
    procedure CheckXstring(section: String=''; value: String='');
    procedure OnInitISO(var VHeaderEncoding: Char; var VCharSet: String);
  end;

  //----------------------------------------------------------
  TSearchWareOrOnum = class // ���-� ������: ��� ������/��, �������, �����.������
  public
    ID, RestSem, SatCount: Integer; // ��� ������/��, ������� �������, ���-�� �����.�������
    IsWare: Boolean;      // ������� ������
    AddComment, SemTitle : String; //������� ������������, ��������� � �������� (���� ������ � 3)
    OLAnalogs: TObjectList; // (TTwoCodes - ID, sem) �������, �����.������
    constructor Create(pID, pSatCount: Integer; pIsWare, pIsMarket: Boolean; parAnalogs: Tai=nil);
    destructor Destroy; override;
  end;

  //----------------------------------------------------------
  TForFirmParams = class
  public
    FirmID, UserID, ForFirmID, currID, contID, StoreMain: integer;
    rate: double;
    arSys, StoreCodes: Tai; // ���� ������ �����, ���� ��������� ������� ���������
    ForClient, HideZeroRests: Boolean;
    constructor Create(pFirmID, pUserID: Integer; pForFirmID: Integer=0;
                       pCurrID: Integer=0; pContID: Integer=0);
    destructor Destroy; override;
    procedure FillStores;
    function NeedSemafores: Boolean;
  end;

  //----------------------------------------------------------
  TFirmPhoneParams = class
  public
    Names: String;
    arSMSind: Tai; //
    constructor Create(pNames: String; pSMScount: Integer);
    destructor Destroy; override;
  end;

//--------------------- ��� ������ �������� �� �������� ����������
  TWareRestsByArrive = Class
  public
    arWares: Tai;             // 0- ��� ������, 1... - ���� ��������
    Storages: TaSD;           // ����� ������� (�������)
//    WareTotals: TDoubleDynArray; //
    WareTotal: Double; // ���-�� ������ �� ���� �������
    arRestLists: TASL; // ��������� ������� �� �����������
    constructor Create;
    destructor Destroy; override;
  end;

var
  VSMail: TVSMail;
  nmIniFileBOB, cNoReplayEmail, cFictiveEmail: string;  // , TodayFillDprts
  RepeatSaveInterval: Integer; // �������� �������� ������� ������ � ����
  RepeatStopInterval: Integer; // �������� �������� �������� ��������� � ���
  accRepeatCount    : Integer; // ���-�� ������� ������� �����
  SleepFillLinksInt : Integer; // �������� �������� ���������� ������
  FormingOrdersLimit: Integer; // ����� ����� � ������ ���������� �������
  OrderListLimit: Integer;     // ����� ����� � ������ �������
  LimitShowAnalogs: Integer;   // ����� ������� �� �������� ��� ������ �������� (5)
  SaveToLog: set of Byte;      // ����� ����� ������ � LOG
  flCSSnew, flDebug, flTest, flTestDocs, flMargins, flmyDebug, flSkipTestWares,
    flTmpRecodeCSS, flTmpRecodeORD, flTmpRecodeGRB, flWareForSearch, // flNewComplMode,
    flLogTestWares, flLogTestClients, flShowWareByState, flCheckLimits, flTradePoint,
    flContCurrPrice, flBonusAttr, flShowAttrImage, flNewModeCGI, flMeetPerson,
    flNewSaveAcc, flDisableOut, flNotReserve, flCredProfile, flNewBonusFilter,
    flSpecRestSem, flMotulTree, flOrderImport, flNewRestCols, flPictNotShow,flNewOrderMode,flNewOrdersMode,flGetExcelWareList: boolean;

  PhoneSupport: String; // ������� ������ ���������
  CheckDocsList: TStringList;
  dLastCheckDocTime, dLastCheckCliEmails: TDateTime;
  brcWebDelim, brcWebBoldBlackBegin, brcWebBoldEnd,
    brcWebColorRedBegin, brcWebColorBlueBegin, brcWebColorEnd: string;
//  brcWebItalBegin, brcWebItalEnd: string;
//------------------------------------------------------------ vc
  AppStatus: integer; //������ ����������
  StopList: Tas;
  ManageCommandsLock: boolean = false;
  GBWork: boolean; // �������� ����������������� GB
  thCheckStoppedOrders: TThread;
  thCheckDBConnectThread: TThread;
  thManageThread: TThread;

  thCheckSMSThread: TThread;
  thControlPayThread: TThread;
  thControlSMSThread: TThread;

  ServerWeb, ServerWebArm, ServerManage: TIDTCPServer;
  MyClass: TMyClass;
  ImageList: TImageList;
  DescrDir: string; // �����, ������������ ��� �������� � ��������
  DirFileErr: String; // ����� �/������� � ����. ������

 function fnGetNumOrder(Prefix, NumOrd: String; Source: Integer=5): String; // ��������� ����� ������ ��� �������
 function fnCheckOrderWebLogin(S: string): boolean;
 function fnCheckOrderWebPassword(S: string): boolean;
 function fnGenWebPass: string;  // ���������� ������
 function fnGetThreadsCount(Server: TIdTCPServer): integer;
procedure SetAppCaption;                 // ��������� �����
 function GetAppImageList: TImageList;   // ������
procedure SetAppStatus(Status: integer); // ������������� ���������� �������� ����������
 function fnWareCompareByBrand(List: TStringList; Index1, Index2: Integer): Integer; // ���������� ������� � StringList � ������ ������
 function fnGetWareListByBrand(Brand: integer; Sys: byte = 255; Sort: boolean = false): TStringList; // �������� ������ �� ��������� ������
 function fnGetAdaptedConstValue(ConstID: integer): string; // ������ �������� ��������� ���������, �������������� ��� ����� ������������
 function CheckShipmentDateTime(Data: TDate; TimeCode: integer): boolean; // ���������, ���������� �� ����� ��������
 function TypeNamesSortCompare(List: TStringList; Index1, Index2: Integer): Integer; // ���������� ������ ����� ������� � ����������� ������
 function SortCompareManufNamesForTwoCodes(Item1, Item2: Pointer): Integer; // ���������� �������� ���� TTwoCodes � TObjectList ��� ������ ������ �������������� ����/����
 function SortCompareConditionPortions(Item1, Item2: Pointer): Integer; // ���������� StringList � TObjectList ��� ������ ������ ������� ������������
//------------------------------------------------------------ vc
//----------------------------------------- v_CSSServerManageProcs
procedure prGetFullStatus(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prExecuteServerCommand(Stream: TBoBMemoryStream; ThreadData: TThreadData; ACommand: integer; AIP: string);
procedure prUpdateCacheSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetActionsSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetActionIconsSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������������ ������ �����
procedure prGetMediaBloksSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // ������������ ����� �����-������
//----------------------------------------- v_CSSServerManageProcs

//                    ������� �� ������ � �������� � �.�.
 function fnGetClosingDocsOrd(ORDRCODE: string; var Accounts, Invoices: TDocRecArr;
          var Status: integer; id: Integer=-1): string; // �������� ������ ������ � ���������� ������ �� ����������� ���������� (Grossbee/Order)
 function fnGetClosingDocsFromOrd(ORDRCODE: string; var Accounts, Invoices: TDocRecArr;
          var Status: integer; id: Integer=-1): string; // �������� ������ ������ � ���������� ������ �� ����������� ���������� �� Order
//procedure prOrderToGBn_Ord(Stream: TBoBMemoryStream; ThreadData: TThreadData; CreateMail: boolean=false); // ������������ ����� � Grossbee
 function fnOrderToGB(OrderID: Integer; flCheckShipParams, CreateMail: Boolean; // �������� ������ � ���� Grossbee � ������������ ������
          var WaresErrMess: String; ThreadData: TThreadData): Integer;
 function GetRateCurr(crnc: Integer=cDefCurrency; crncTo: Integer=1): Double; // �������� ������� ���� ������ (def - EUR->UAH)
 function fnNotLockingLogin(Login: String): Boolean;                          // ���������, �� ��������� �� ����� � �����������

procedure prSaveShortWareInfoToStream(Stream: TBoBMemoryStream;               // ������ � Stream ���� � ������
          WareID, FirmID, UserID: integer; AnalogsCount: integer=0;
          currID: Integer=0; ForFirmID: integer=0; SatellsCount: integer=0;
          contID: integer=0; RestSem: integer=-1; RestTitle: String=''; ModelsEx: Boolean=True); overload;
procedure prSaveShortWareInfoToStream(Stream: TBoBMemoryStream;              // ������ � Stream ���� � ������
          ffp: TForFirmParams; WareID: integer; AnalogsCount: integer=0;
          SatellsCount: integer=0; RestSem: integer=-1; RestTitle: String=''; ModelsEx: Boolean=True); overload;
procedure prSaveWareRestsExists(Stream: TBoBMemoryStream; ffp: TForFirmParams; wCodes: Tai); // ������ � Stream ����� ��������� ������� ������� (����� ������ � Web)
 function fnGetContMainStoreAndStoreCodes(FirmID, ContID: Integer; var StorageCodes: Tai): Integer; // �������� ���� ������� ��������� � ��� �������� ������
procedure prCheckWareRestsExists(ffp: TForFirmParams; var OLmarkets: TObjectList; var RestCount: Integer);

 function GetContWareRestsByCols(wareID, ContID, StorageCount: Integer): TDoubleDynArray; // ������� ������ ��� ��������� �� �������� (�������, ������, >1 ���)
 function GetContWareRestsSem(wareID: Integer; ffp: TForFirmParams; var sArrive: String): Integer;

procedure prSaveEmplFirmsChoiceList(Stream: TBoBMemoryStream; EmplID: Integer);             // ������ � Stream ������ ������� ���������� �/� ��� ������ (WebArm)
procedure prSaveEmplStoresChoiceList(Stream: TBoBMemoryStream; EmplID: Integer; flWithRoad: Boolean=False); // ������ � Stream ������ ������� ���������� �������(+�����) ��� ������ (WebArm)

procedure CheckDocSum;                                                        // �������� ���� ���-���
procedure CheckClientsEmails;                                                 // �������� �������

procedure prHideTreeNodes(var ListNodes, listParCodes: TList; flOnlySameName, flOnlyOneLevel: boolean); // �������� ���� ������ ����� � 1 ��������, � TreeList[i] - Pointer(TSecondLink)
 function fnRepClientRequests(UserID: integer; StartTime, EndTime: TDateTime; var FName: string): string; // ������������ ������ �� �������� ������� �� ������
 function SaveClientBlockType(BlockType, UserID: Integer;                     // ����������/������������� ������� � ����
          var BlockTime: TDateTime; EmplID: Integer=0): Boolean;
// function SetSemMarkForClients(pSysID: Integer; SemMark: String='T'): String; // ����������� �������� WareSemafor ���� �������� �������

 function GetModelNodeWareUsesAndTextsPartsView(ModelID, NodeID, WareID: Integer): TObjectList; // must Free, ������ ������ ������� � ������� � ������ 3 ��� ���������
 function SetUsageTextPartWrongMark(pModelID, pNodeID, pWareID, pPart, // ����������/������ ������� WRONG ������ ������� � �������
          pUserID: Integer; flWrong: Boolean): String;
//function CheckTextFirstUpAndSpaces(txt: String): String; // �������� ��������� ����� � �������� ������

//                       ������� ���������
 function fnGetManagerMail(code: Integer; Mailelse: String): String; // Email �������
 function fnGetSysAdresVlad(kind: integer=caeOnlyDay): string;       // ������ ��� ����.���������
 function GetMessageFromSelf: String;                                // ������ "��������� ��" CSS-�������
 function n_SysMailSend(ToAdres, Subj: String; Body: TStrings=nil; Attachments: TStrings=nil;
          From: string =''; nmIniFile: string =''; flSaveToFile: boolean=False): string; // ��������� ��������� ���������
procedure TestOldErrMailFiles;                                                           // �������� ����������� ������ �������
 function MessText(kind: TMessTextKind; str: string=''): String;                         // ����� ��������� ������������
 function CutEMess(Emess: String): String;  overload;                                    // ������� ��������� �� exception ORD
 function CutEMess(Emess: String; var ResCode: Integer): String;  overload;              // ������� ��������� �� exception ORD + resDoNothing
 function CutLockMess(mess: String): String;                                             // ������� ��������� deadlock � �.�.
 function CutPRSmess(mess: String): String;                                              // �������� ��������� PRS.
 function fnFormRepFileName(pSubName, pNameOrExt: string; pOpKind: integer): string;     // ��������� ��� ����� ������
 function fnSendErrorMes(FirmID, UserID, MesType, WareId, AnalogId, OrNumId, ModelId, NodeId: Integer;
          SenderMess, AttrMess: String; ThreadData: TThreadData): String;      // ���������� ��������� ������������ �� ������, Exception �������� ������, ���������� ��������� ��� ������������
// function fnSendClientMes(FirmID, UserID, Source: Integer; SenderMess: String; // ���������� ��������� ������������ ���������
//          ThreadData: TThreadData; var Response: String; ContID: Integer=0): Boolean;
 function prSendMailWithClientPassw(Kind: TKindCliMail; Login, Password, Mail: String; // ��������� ������ � ������� �������
          ThreadData: TThreadData; FirmName: String=''; lst: TStringList=nil): string;
//              ������� �������� ��������� �� ������
 function fnSaveMailStringsToFile(ToAdres, Subj, From: String;
          Body, Attachments: TStrings; var FileName: String): Boolean; // ������ ������ ����� ������ � ����
 function fnGetMailFilesPath: String;                                  // ���� � ������ �����
 function fnGetErrMailFilesDir: String;                                // ����� � ��������������� �������
 function fnGetLockFileName(FileName: String): String;                 // ��� ����� ����������
 function ExtractFictiveEmail(emails: String): String; overload;           // ���������� ���������� ������ �� ������
 function ExtractFictiveEmail(emails: TStringList): TStringList; overload; // must Free, ���������� ���������� ������ �� ������

//              ������� ��������
 function CheckNotValidUser(pUserID, pFirmID: Integer; var errmess: string): boolean;     // ��������� ���������� ������������
// function CheckNotValidFirmSys(FirmID, SysID: Integer; var errmess: string): boolean;     // ��������� ������� �����
 function CheckNotValidModelManage(UserID, SysID: Integer; var errmess: string): boolean; // ��������� ����� ���������� �� ������ � �������� �������
 function CheckNotValidTNAManage(UserID, SysID: Integer; var errmess: string): boolean;   // ��������� ����� ���������� �� ������ � ������� ����� �������
 function CheckNotValidManuf(ManufID: Integer; SysID: Integer;             // �������� ������������� � ��������� �����������
          var Manuf: TManufacturer; var errmess: string): boolean;
 function CheckNotValidModelLine(ModelLineID: Integer; var SysID: Integer; // �������� ��������� ���, ������� � ��������� �����������
          var ModelLine: TModelLine; var errmess: string): boolean;
 function CheckNotValidModel(ModelID: Integer; var SysID: Integer;          // �������� ������, ������� � ��������� �����������
          var Model: TModelAuto; var errmess: string): boolean;
procedure TestCssStopException;         // �������� ��� ��������� ����.�������� ��� ��������� �������
 function SetLongProcessFlag(cdlpKind: Integer; NotCheck: Boolean=False): Boolean; // ���������� ���� ����������� �������� (������������ ���� � �.�)
 function SetNotLongProcessFlag(cdlpKind: Integer): Boolean; // ����� ���� ����������� �������� (������������ ���� � �.�)  !!! ���������
//procedure prCheckUserForFirmAndGetSysCurr(UserID, FirmID: Integer; // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
//          var ForFirmID, Sys, CurrID: Integer; PriceInUah: Boolean=False; contID: Integer=0);
procedure prCheckUserForFirmAndGetCurr(UserID, FirmID: Integer; // ��������� UserID, FirmID, ForFirmID � �������� ������
          var ForFirmID, CurrID: Integer; PriceInUah: Boolean=False; contID: Integer=0);
 function CheckMobileNumber(num: String): Boolean;   // �������� ������ ���������� ��������
 function CheckClientFIO(CliName: String): String;   // �������� ������������ ��� ������������ �������
 function CheckFirmFilterConditions(FirmID: Integer; // �������� ������������ �/� �������� ���������� (Web & WebArm)
          flFirmsAdd, flAuto, flMoto: Boolean; Filials, Classes, Types, Firms: TIntegerList): Boolean;

//              ������� ��� ����.���������
procedure CheckGAMainNodesLinks(LogFile: String='');                            // ������ TD->GA � TreeNodesAuto->MainNode
procedure CheckArticleWareMarks(LogFile: String=''; maxStrLen: Integer = 3000); // ��������� ������� ������� � ��������� � TDT
procedure TestLastFirms(DecHour: Integer=1);                                    // �������� ����, �������� ��������� DecHour �����
procedure TestLogFirmNames;                                                     // �������� ������������ ���� � ���� �����������
procedure CheckClosingDocsAll(CompareTime: boolean=True);                       // �������� �������� ����������� ���-��� �������
//procedure CheckClosingDocsByPeriod(tbegin, tend: TDateTime;                     // �������� ����������� ���-��� ������� �� ������ ���������
//          flSaveTime: boolean=True; flalter: boolean=True);
procedure CheckClosingDocsByPeriod_new(tbegin, tend: TDateTime; flSaveTime: boolean=True); // �������� ����������� ���-��� ������� �� ������ ���������
procedure CheckWorkLogins(userID: Integer; Login: String);                      // �������� ������ � ������ ������ �������
procedure CheckClonedOrBlockedClients(LogFile: String='');                      // �������� ������/������ ��������
//procedure FillOrdersClosingDocs(FirstRecs: Integer=0); // ��������� ������� ����.���-��� � ���������� ���� ������� ����.���-���
//procedure TestFile;
procedure TmpRecodeCSS;   // ������� ������������ � ���� �����������
procedure TmpCheckRecode; // ���������� �������� � ���� �����������, ����������� ��� ������ � Webarm
procedure TmpRecodeORD;   // ������� ������������� � ���� ORD
procedure TmpRecodeGRB;   // ������� �������������/������ ������ � ���� Grossbee

//             ������ �������
 function ToLog(vid: Integer): Boolean; // ������� ������ � LOG � ���-�� �� ����
procedure GetLogKinds;                  // ���� �����������
 function RepeatExecuteIBSQL(IBS: TIBSQL; repeats: Integer=RepeatCount): string; overload;
 function RepeatExecuteIBSQL(IBS: TIBSQL; Fname: string; var StrValue: string; repeats: Integer=RepeatCount): string; overload;
 function RepeatExecuteIBSQL(IBS: TIBSQL; Fname: string; var IntValue: Integer; repeats: Integer=RepeatCount): string; overload;
 function RepeatExecuteIBSQL(IBS: TIBSQL; var FnamesValues: Tas; repeats: Integer=RepeatCount): string;  overload;
 function GetEmplTmpFilePath(EmplID: Integer; var pFilePath, errmess: string): boolean;  // ���� � ������� ������ ����������
 function GetBoolGB(ibsql: TIBSQL; Fname: string): boolean;                              // ��������� �������� ���� Fname ibsql � boolean
 function GetLstPrefixAddon(pBrandID: Integer; UseOnlyBrand: Boolean=True): TStringList; // ������������ ������ ��������� ��� ��������� � �������� ��� ������
 function GetLstSufixAddon(pBrandID: Integer; UseOnlyBrand: Boolean=True): TStringList;  // ������������ ������ ��������� ��� ��������� � �������� ��� ������, not Object
 function ObjWareNameSortCompare(List: TStringList; Index1, Index2: Integer): Integer; // ���������� TStringList �� ������������ ������, ���� ID � Objects
 function fnGetActionTimeEnable(kind: integer=caeOnlyDay): Boolean;           // ���������� ����� ��� ��������
procedure prSaveCommonError(Stream: TBoBMemoryStream; ThreadData: TThreadData; // ������ � Stream ��������� �� ������
          nmProc, Emess, MyText: String; flEBOB: Boolean; flPRS: Boolean=False);
procedure prSaveCommonErrorStr(var errStr:String; ThreadData: TThreadData;
          nmProc, Emess, MyText: String; flEBOB: Boolean; flPRS: Boolean=False);  //������ � ������ ��������� �� ������
 function RenameErrFile(nf, dirold, dirnew: string; flPutOff: Boolean=False): string; // ���������� ���� nf �� dirold � dirnew
procedure CheckStopExecute(pUserID: Integer; ThreadData: TThreadData); // �������� ��������� �������� ��� �������
procedure SetExecutePercent(pUserID: Integer; ThreadData: TThreadData; Percent: Double); // ����������� ��������� ����������
 function GetMobileNumber10(num: String): String;  // ����� ���������� �������� ��� +38
 function GetYearFromLoadModels: String;
 function SetMainUserToGB(FirmID, UserID: Integer; pDate: TDateTime; ibsGBw: TIBSQL=nil): String; // ������ ����.������������ � Grossbee

//             ������� ������
 function SearchWareNames(Template: string; IgnoreSpec: Integer=0; // must Free, ����� ������� �� ������������ (��������) � ����
          ManagID: Integer=-1; ByComments: boolean=False): Tai;
 function fnGetAllAnalogs(WareID: integer; ManufID: integer=-1): Tai; // must Free, ���������� ������ ����� ���� �������� ������ WareID
 function SearchWaresTypesAnalogs(Template: string; var TypeCodes: Tai; IgnoreSpec: Integer=0; // must Free, ����� ������� (� ������ � ���������) �� ������������ � ����
          ManagID: Integer=-1; ByComments: boolean=False; OnlyWithPriceOrAnalogs: boolean=False;
          flSale: boolean=False; flCutPrice: boolean=False; flLamp: boolean=False): TObjectList;

 function SearchWaresTypesAnalogs_new(Template: string; var TypeCodes: Tai; IgnoreSpec: Integer; // must Free, ����� ������� (� ������ � ���������) �� ������������ � ����
          ByComments, flSale, flCutPrice, flSemafores: boolean; ffp: TForFirmParams): TObjectList;
 function SearchWareOrigNums_new(Template: String; IgnoreSpec: Integer; // must Free, ����� ������������� ������ �� ���������
          var TypeCodes: Tai; flSemafores: boolean; ffp: TForFirmParams): TObjectList;

//              ������� ��� ��������
 function GetAvailableSelfGetTimesList(DprtID: Integer; pDate: TDateTime;                     // ������ ��������� ������ ���������� �� ������, ����
          var stID: Integer; var SL: TStringList; flWithSVKDelay: Boolean=False): String;
 function GetAvailableShipDatesList(DprtID, iDate: Integer; var SL: TStringList): String;     // ������ ��������� ��� �������� �� ������
// function GetAvailableShipDatesList(DprtID, iDate: Integer;                                   // ������ ��������� ��� �������� �� ������
//         var SL: TStringList; flWithSVKDelay: Boolean=False): String;
 function CheckAccountShipParams(delivType, ContID, DprtID: Integer; var pShipDate: TDateTime; // �������� ���������� �������� ��� �����
          var DestID, ttID, smID, stID: Integer; WithSVKDelay: Boolean): String;
 function fnGetShipParamsView(contID, DprtID, DestID, ShipTableID: Integer; ShipDate: double; // ��������� �������� ��� ���������
          var DelivType, ShipMetID, ShipTimeID: Integer; var sDestName, sDestAdr, sArrive: String;
          var sShipMet, sShipTime, sView: String; GBdirection: Boolean=False): String;
//==================================== ��������� ����������� �������� �� �������
//===== ���� - ���������� ����� ��� ��������� ������� ����������� (����.�������)
 function CheckDprtTodayFill(dprtID: Integer; RestList: TObjectList): String;
 function GetDprtWareRestsByArrive(dprtID: Integer; WareQty: Double; // ������� �������� �� ��������
                                   var wrba: TWareRestsByArrive): String;

//******************************************************************************
implementation
uses n_IBCntsPool, n_DataCacheInMemory,
     t_ImportChecking, t_WebArmProcedures, n_WebArmProcedures,
     n_server_main, n_CSSservice, n_OnlinePocedures, n_CSSThreads,
     s_OnlineProcedures, s_WebArmProcedures;

//----------------------------------------- vc
//============================================================
function fnGetThreadsCount(Server: TIdTCPServer): integer;
var aList: TList;
begin
  aList:= Server.Contexts.LockList;
  try
    Result:= aList.Count;
  except
    Result:= 0;
  end;
  Server.Contexts.UnlockList;
end;
//=========================================== ��������� ����� ������ ��� �������
function fnGetNumOrder(Prefix, NumOrd: String; Source: Integer=5): String;
// FirmCod - ��� �����, NumOrd - � ������ �������, Source - �������� (�� ���������: 5-Vlad)
var s: String;
begin
  if pos('_',NumOrd)>0 then begin
    Result:= NumOrd;
    Exit;
  end;
  case Source of
    5: s:= '_V_'; // ����������� ��� �������.������ ����� ��������� "vlad"
    6: s:= '_W_'; // ����������� ��� �������.������ ����� ��������
  else s:= '_';   // ����������� ��� ������ ����������
  end; // case
  Result:= Prefix+s+NumOrd; // ����� ������: FirmShortName(FirmCod)_V(Source)_NumOrd
end;
//================= ��������� ���������� ������ Web-������������ ������� �������
function fnCheckOrderWebLogin(S: string): boolean;
var i, j: integer;
    c:  Char;
begin
  Result:= false;
  j:= Length(s);
  if (j<5) or (j>Cache.CliLoginLength) then exit;
  for i:= 1 to j do begin
    c:= s[i];
    if not (SysUtils.CharInSet(c, ['a'..'z', 'A'..'Z', '0'..'9', '_'])) then exit;
  end;
  Result:= true;
end;
//================= ��������� ���������� ������ Web-������������ ������� �������
function fnCheckOrderWebPassword(S: string): boolean;
var i, j: integer;
    c:  Char;
begin
  Result:= false;
  j:= Length(s);
  if (j<5) or (j>Cache.CliPasswLength) then exit;
  for i:= 1 to j do begin
    c:= s[i];
    if not (SysUtils.CharInSet(c, ['a'..'z', 'A'..'Z', '0'..'9', '_'])) then exit;
  end;
  Result:= true;
end;
//============================================================ ���������� ������
function fnGenWebPass: string;
var len: integer;
    c: char;
begin
  Result:= '';
  Randomize;
  len:= 5+Random(4);
  while Length(Result)<(len+1) do begin
    c:= char(48+Random(123-48));
    if (SysUtils.CharInSet(c, ['a'..'z', '0'..'9'])) then Result:= Result+c;
  end;
end;
//========================================================= ���������� ImageList
function GetAppImageList: TImageList;
var i: integer;
    nImageList: string;
begin
  Result:= Form1.ilDefault;                 // ������ ��� ImageList �� ini-�����
  nImageList:= GetIniParam(nmIniFileBOB,'service','ImageList','');
  if nImageList='' then Exit;
  for i:= 0 to Form1.ComponentCount-1 do
    if (Form1.Components[i] is TImageList) and
      (Form1.Components[i].Name=nImageList) then begin
      Result:= (Form1.Components[i] as TImageList);
      Exit;
    end;
end;
//============================================================== ��������� �����
procedure SetAppCaption;
begin
  Form1.lbAliases.Caption:= 'CSS-server,  GrossBee: '+cntsGRB.dbPath;
end;
//================================= ������������� ���������� �������� ����������
procedure SetAppStatus(Status: integer);
begin
  AppStatus:= Status;
  Form1.Caption:= Application.Title+': '+
    fnIfStr(IsServiceCSS, '������ ', '���������� ')+arCSSServerStatusNames[Status];
  if not IsServiceCSS and (Form1.Caption[length(Form1.Caption)]='�') then
    Form1.Caption:= Copy(Form1.Caption, 1, length(Form1.Caption)-1)+'�';
  ImageList.GetIcon(AppStatus,Application.Icon); // ������ Application.Icon
  Form1.btSuspend.Enabled:= (AppStatus=stWork);
  Form1.btResume.Enabled:= (AppStatus=stSuspended);
  Form1.bbFillarWares.Enabled:= (AppStatus=stWork);
  if not IsServiceCSS and fIconExist then begin
    SetTrayIconData;
    Shell_NotifyIcon(NIM_MODIFY, @TrayIconData);
    Application.ProcessMessages;
  end;
end;
//==========================================================  TMyClass
procedure TMyClass.ServerExecute(AContext: TIdContext);
begin
;
end;
//==============================================================================
procedure TMyClass.ServerWebConnect(AContext: TIdContext);
var Stream: TBOBMemoryStream;
    i: integer;
    AThread: TIdContext;
    Command: word;
    ThreadData: TThreadData;
    ErrorPos: string;
begin
  ErrorPos:= '0';
  AThread:= AContext;
  ThreadData:= nil;
  Stream:= nil;
  try
{
ErrorPos:= '8-7';
ErrorPos:= '1';
    i:= AThread.Connection.IOHandler.ReadLongInt;
ErrorPos:= '3';
    if (i=csOnlineOrder) then begin // ���� ��� ������ �� Web-������������ ������� ������-�������
ErrorPos:= '8';
      try
        Stream:= TBOBMemoryStream.Create;
        if not (GetAllBasesConnected and (AppStatus=stWork))
          then raise EBOBError.Create(GetMessageNotCanWorks);
        if (fnGetThreadsCount(ServerWeb)>Cache.GetConstItem(pcMaxServerWebConnect).IntValue)
          then raise EBOBError.Create('������ ����������, ��������� ������ ����� ��������� ������');

  ErrorPos:= '8-8-1';
        AThread.Connection.IOHandler.ReadLongInt;                // ��������� SessionID, ������� � ������ ������ �� �����
  ErrorPos:= '8-2';
        Command:= word(AThread.Connection.IOHandler.ReadSmallInt);   // ��������� �������
  ErrorPos:= '8-3';
        i:= AThread.Connection.IOHandler.ReadLongInt;                // ��������� ������ ���� �������
  ErrorPos:= '8-6';
        AThread.Connection.IOHandler.ReadStream(Stream, i);         // ��������� ���� �������
ErrorPos:= '8-8-2';

        ThreadData:= fnCreateThread(fnSignatureToThreadType(csOnlineOrder), Integer(Command));  // ����������� � ib_css
  ErrorPos:= '8-8';
}
ErrorPos:= '1';
    i:= AThread.Connection.IOHandler.ReadLongInt;
ErrorPos:= '3';
    if (i=csOnlineOrder) then begin // ���� ��� ������ �� Web-������������ ������� ������-�������
ErrorPos:= '8';
      AThread.Connection.IOHandler.ReadLongInt;                // ��������� SessionID, ������� � ������ ������ �� �����
ErrorPos:= '8-2';
      Command:= word(AThread.Connection.IOHandler.ReadSmallInt);   // ��������� �������
      ThreadData:= fnCreateThread(fnSignatureToThreadType(i), Integer(Command));  // ����������� � ib_css
ErrorPos:= '8-3';
      i:= AThread.Connection.IOHandler.ReadLongInt;                // ��������� ������ ���� �������
ErrorPos:= '8-6';
      Stream:= TBOBMemoryStream.Create;
ErrorPos:= '8-7';
      AThread.Connection.IOHandler.ReadStream(Stream, i);         // ��������� ���� �������
ErrorPos:= '8-8';
      try
        if not (GetAllBasesConnected and (AppStatus=stWork))
          then raise EBOBError.Create(GetMessageNotCanWorks);
ErrorPos:= '8-8-1';
        if (fnGetThreadsCount(ServerWeb)>Cache.GetConstItem(pcMaxServerWebConnect).IntValue)
          then raise EBOBError.Create('������ ����������, ��������� ������ ����� ��������� ������');
ErrorPos:= '8-8-2';
        case Command of
          csWebAutentication            : prAutenticateOrd(Stream, ThreadData);
          csGetAllUsersInfo             : prGetAllUsersInfo(Stream, ThreadData);
          csSearchWithOrNums            : prCommonWareSearch_new(Stream, ThreadData);
          csWebArmGetAnalogs            : prGetWareAnalogs_new(Stream, ThreadData);
          csCreateNewOrder              : prCreateNewOrderOrd(Stream, ThreadData);
          csGetOrderList                : prGetOrderListOrd(Stream, ThreadData);
          csShowOrder                   : prShowOrderOrd(Stream, ThreadData);
          csShowACOrder                 : prShowACOrderOrd(Stream, ThreadData);
          csDelLineFromOrder            : prDelLineFromOrderOrd(Stream, ThreadData);
          csChangeQtyInOrderLine        : prChangeQtyInOrderLineOrd(Stream, ThreadData);
          csRefreshPrices               : prRefreshPricesOrd(Stream, ThreadData);
          csCreateOrderByMarked         : prCreateOrderByMarkedOrd(Stream, ThreadData);
          csJoinMarkedOrders            : prJoinMarkedOrdersOrd(Stream, ThreadData);
          csGetAccountList              : prGetAccountListOrd(Stream, ThreadData);
          csGetWaresFromAccountList     : prGetWaresFromAccountList(Stream, ThreadData);
          csShowGBAccount               : prShowGBAccountOrd(Stream, ThreadData);         // �������� �����
          csShowGBOutInvoice            : prShowGBOutInvoice(Stream, ThreadData);         // �������� ���������
          csGetUnpayedDocs              : prGetUnpayedDocs(Stream, ThreadData);
          csDeleteOrderByMark           : prDeleteOrderByMarkOrd(Stream, ThreadData);
          csRefreshPricesInFormingOrders: prRefreshPricesInFormingOrdersOrd(Stream, ThreadData);
          csSetReservValue              : prSetReservValueOrd(Stream, ThreadData);
//          csSetOrderPayType             : prSetOrderPayTypeOrd(Stream, ThreadData);
          csGetOptions                  : prGetOptionsOrd(Stream, ThreadData);
          csSetOrderDefault             : prSetOrderDefaultOrd(Stream, ThreadData);
          csChangePassword              : prChangePasswordOrd(Stream, ThreadData);    // ???
          csWebSetMainUser              : prWebSetMainUserOrd(Stream, ThreadData);
          csWebResetPassword            : prWebResetPasswordOrd(Stream, ThreadData);
          csWebCreateUser               : prWebCreateUserOrd(Stream, ThreadData);
          csChangePass                  : prChangePasswordOrd(Stream, ThreadData);    // ???
          csGetRegisterTable            : prGetRegisterTableOrd(Stream, ThreadData);  // ������ �������� ��� ����� ����������� �����
          csSaveRegOrder                : prSaveRegOrderOrd(Stream, ThreadData);      // ������ ������ �� ����������� ����� � ������� ���
          csGetRegisterUberTowns        : prGetRegisterUberTowns(Stream, ThreadData); // ������ ������� ��� ����� ����������� UBER
          csSaveRegOrderUber            : prSaveRegOrderUber(Stream, ThreadData);     // ������ ������ �� ����������� UBER � ������� ���
          csCheckLogin                  : prCheckLoginOrd(Stream, ThreadData);
          csGetCheck                    : prGetCheck(Stream, ThreadData);             // ������
          csShowGBBack                  : prShowGBBack(Stream, ThreadData);
          csSendMessage2Manager         : prSendMessage2Manager(Stream, ThreadData);
          csAddLinesToOrder             : prAddLinesToOrderOrd(Stream, ThreadData);
          csAddLineFromSearchResToOrder : prAddLineFromSearchResToOrderOrd(Stream, ThreadData);
          csChangeVisibilityOfStorage   : prChangeVisibilityOfStorage(Stream, ThreadData);
          csClientsStoreMove            : prClientsStoreMove(Stream, ThreadData);
          csGetManufacturerList         : prGetManufacturerList(Stream, ThreadData);

          csOrdGetListAttrGroupNames    : prGetListAttrGroupNames(Stream, ThreadData);
          csOrdGetListGroupAttrs        : prGetListGroupAttrs(Stream, ThreadData);
          csSearchWaresByAttrValues     : prCommonSearchWaresByAttr_new(Stream, ThreadData);
          csGetCompareWaresInfo         : prGetCompareWaresInfo(Stream, ThreadData);
          csOrdGetWareInfo              : prGetWareInfoView(Stream, ThreadData);
          csGetFilteredGBGroupAttValues : prGetFilteredGBGroupAttValues(Stream, ThreadData); // ������������� ������ �������� ��������� Grossbee �� ������

          csOrdGetModelLineList         : prGetModelLineList(Stream, ThreadData);
          csGetModelLineModels          : prGetModelLineModels(Stream, ThreadData);
          csGetModelTree                : prGetModelTree(Stream, ThreadData);
          csGetNodeWares                : prCommonGetNodeWares_new(Stream, ThreadData);
          csOrdSendWareDescrErrorMes    : prSendWareDescrErrorMes(Stream, ThreadData);
          csShowModelsWhereUsed         : prShowModelsWhereUsed(Stream, ThreadData);
          csGetRestsOfWares             : prCommonGetRestsOfWares(Stream, ThreadData);
          csGetActions                  : prGetActions(Stream, ThreadData);
          csGetTop10Model               : prGetTop10Model(Stream, ThreadData);
          csClickOnNewsCounting         : prClickOnNewsCounting(Stream, ThreadData);
          csLoadEngines                 : prLoadEngines(Stream, ThreadData);
          csGetEngineTree               : prGetEngineTree(Stream, ThreadData);
          csShowEngineOptions           : prShowEngineOptions(Stream, ThreadData);
          csLoadModelDataText           : prLoadModelDataText(Stream, ThreadData);
          csTestLinksLoading            : prTestLinksLoading(Stream, ThreadData);
          csGetFilterValues             : prGetFilterValues(Stream, ThreadData);
          csBackJobAutentication        : prAutenticateOrd(Stream, ThreadData);
          csSaveOption                  : prSaveOption(Stream, ThreadData);
          csGetSatellites               : prGetWareSatellites(Stream, ThreadData);
          csSendVINOrder                : prSendVINOrder(Stream, ThreadData);
          csGetWaresByOE                : prCommonGetWaresByOE(Stream, ThreadData);
          csHideEmptyOE                 : prHideEmptyOE(Stream, ThreadData);
          csDownloadPrice               : prDownloadPrice(Stream, ThreadData);
          csShowNotification            : prShowNotificationOrd(Stream, ThreadData);
          csConfirmNotification         : prConfirmNotification(Stream, ThreadData);
          csWaresByOE                   : prSearchWaresByOE_new(Stream, ThreadData);
          csContractList                : prContractList(Stream, ThreadData);
          csChangeContract              : prChangeClientLastContract(Stream, ThreadData);
          csChangeContractAccess        : prChangeContractAccess(Stream, ThreadData);
          csSendOrderForChangePersonData: prSendOrderForChangeData(resEdited, Stream, ThreadData);  // ��������� ������ �� ��������� ������������ ������
          csSendOrderForAddContactPerson: prSendOrderForChangeData(resAdded, Stream, ThreadData);   // ��������� ������ �� ���������� ����������� ����
          csSendOrderForDelContactPerson: prSendOrderForChangeData(resDeleted, Stream, ThreadData); // ��������� ������ �� �������� ����������� ����
//          csSetCliContMargins           : prSetCliContMargins(Stream, ThreadData);
          csRemindPass                  : prRemindPass(Stream, ThreadData);
          csGetContracts                : prGetContracts(Stream, ThreadData);
          csGetBonusWares               : prGetBonusWares(Stream, ThreadData);
          csGetTimeListSelfDelivery     : prGetTimeListSelfDelivery(Stream, ThreadData);    // ������ ��������� ������ ����������
          csGetContractDestPointsList   : prGetContractDestPointsList(Stream, ThreadData);  // ������ �������� ����� ���������
          csGetAvailableTimeTablesList  : prGetAvailableTimeTablesList(Stream, ThreadData); // ������ ��������� ���������� �� ���������
          csGetOrderHeaderParams        : prGetOrderHeaderParams(Stream, ThreadData);       // �������� ���������� ��������� ������
          csEditOrderHeaderParams       : prEditOrderHeaderParams(Stream, ThreadData);      // �������������� ���������� ��������� ������
          csShowBonusFormingOrder       : prShowBonusFormingOrder(Stream, ThreadData);      // �������� ��������� ��������������� ������
          csGetQtyByAnalogsAndStorages  : prGetQtyByAnalogsAndStoragesOrd(Stream, ThreadData);
          csEditOrderSelfComment        : prEditOrderSelfComment(Stream, ThreadData);       // �������������� ����������� "��� ����"
          csCheckOrderWareRests         : prCheckOrderWareRests(Stream, ThreadData);        // �������� ������� �������� ������� �� ������
          csGetDprtAvailableShipDates   : prGetDprtAvailableShipDates(Stream, ThreadData);  // ������ ��������� ��� �������� �� ������
          csGetMainStoreLocation        : prGetMainStoreLocation(Stream, ThreadData);       // ����� � ���������� �������� ������
          csGetCheckBonus               : prGetCheckBonus(Stream, ThreadData);              // unit-��������
          csShowGBManual                : prShowGBManual(Stream, ThreadData);               // �������� �������������
          csGeneralNewSystemProcOrder   : prGeneralNewSystemProcOrder(Stream, ThreadData);  // ����� ��������� �� ����� ����� ������ �����
          csGetOutInvoiceXml            : prGetOutInvoiceXml(Stream, ThreadData);           // �������� ��������� � ���� xml-�����
          csGetFormingOrdersList        : prGetFormingOrdersList(Stream, ThreadData);       // �������� ������ �������������� �������
          csGetWareActions              : prGetWareActions(Stream, ThreadData);             // �������� ������ ����� ��� "����������"

          csGetBankAccountsList         : prGetBankAccountsList(Stream, ThreadData);        // �������� ������ ������ �� ������
          csNewBankAccount              : prNewBankAccount(Stream, ThreadData);             // ������������ ����� ���� �� ������
          csSaveBankAccount             : prSaveBankAccount(Stream, ThreadData);            // �������� ���� �� ������
          csGetBankAccountFile          : prGetBankAccountFile(Stream, ThreadData);         // �������� ���� ����� �� ������
          csSendSMSfromBankAccount      : prSendSMSfromBankAccount(Stream, ThreadData);     // ��������� SMS �� ����� �� ������
          csGetReclamationList          : prGetReclamationList(Stream, ThreadData);         // �������� ������ ����������
          csGetMeetPersonsList          : prGetMeetPersonsList(Stream, ThreadData);         // �������� ������ ����������� �/�
          csGetNodeWaresMotul           : prCommonGetNodeWares_Motul(Stream, ThreadData);   // �������� ������ ������� Motul �� ����� ������
          csOrderImport                 : prOrderImport(Stream, ThreadData);                // ������ ������� � �����
          csGetDestPointParams          : prGetDestPointParams(Stream, ThreadData);         // ������ ���������� ��� ���������� ��������� �������

          else raise EBOBError.Create('�� �������� Web-������� - '+IntToStr(Command));
        end; // case Command of
      except
        on E: Exception do begin
          Stream.Clear;
          Stream.WriteInt(aeCommonError);
          if (Command<>csTestLinksLoading) and (AppStatus=stWork) then
            fnWriteToLog(ThreadData, lgmsSysError, 'TMyClass.ServerWebConnect', 'Command='+IntToStr(Command), E.Message, 'ErrorPos='+ErrorPos);
          Stream.WriteStr('������ �������� �� ������: '#13#10+E.Message);
        end;
      end;
ErrorPos:= '8-9';
      If Stream.Size>0 then begin
        i:= Stream.Size;
ErrorPos:= '8-10: Stream.Size='+IntToStr(i);
        AThread.Connection.IOHandler.Write(i);              //
ErrorPos:= '8-11: Stream.Size='+IntToStr(i);
        AThread.Connection.IOHandler.Write(Stream);         // ���������� ����� �� ������
ErrorPos:= '8-12';
      end;
      AThread.Connection.Disconnect;
      prFree(Stream);

    end else begin // ���� ����������� ���������
ErrorPos:= '9';
      AThread.Connection.Disconnect;
    end;
  except
    on E: Exception do begin
      fnWriteToLog(ThreadData, lgmsSysError, 'TMyClass.ServerWebConnect', '������ ������ ����� ', E.Message, 'ErrorPos='+ErrorPos);
      fnWriteToLog(ThreadData, lgmsInfo, 'TMyClass.ServerWebConnect', '�������� �������� ����� ', E.Message, 'ErrorPos='+ErrorPos);
    end;
  end;
  prDestroyThreadData(ThreadData, 'TMyClass.ServerWebConnect');
  if Assigned(AThread) and AThread.Connection.Connected then AThread.Connection.Disconnect;
  prFree(Stream);
end; //ServerWebConnect
//==============================================================================
procedure TMyClass.ServerWebArmConnect(AContext: TIdContext);
var Stream : TBOBMemoryStream;
    i : integer;
    AThread: TIdContext;
    Command: word;
    ThreadData: TThreadData;
    ErrorPos: string;
begin
  ErrorPos:= '0';
  AThread:= AContext;
  ThreadData:= nil;
  Stream:= nil;
  try
ErrorPos:= '1';
ErrorPos:= '2';
    i:= AThread.Connection.IOHandler.ReadLongInt;
ErrorPos:= '3';
    if (i=csWebArm) then begin // ���� ��� ������ �� WebArm-������������
ErrorPos:= '8';

      AThread.Connection.IOHandler.ReadLongInt;                // ��������� SessionID, ������� � ������ ������ �� �����
      Command:= word(AThread.Connection.IOHandler.ReadSmallInt);   // ��������� �������
      ThreadData:= fnCreateThread(fnSignatureToThreadType(i), Integer(Command));
      i:= AThread.Connection.IOHandler.ReadLongInt;                // ��������� ������ ���� �������
      Stream:= TBOBMemoryStream.Create;
      AThread.Connection.IOHandler.ReadStream(Stream, i);         // ��������� ���� �������
      try
        if not (GetAllBasesConnected and (AppStatus=stWork))
          then raise EBOBError.Create(GetMessageNotCanWorks);
        case Command of
          csWebArmAutentication            : prWebArmAutenticate(Stream, ThreadData);
          csShowWebArmUsers                : prShowWebArmUsers(Stream, ThreadData);
          csAEWebArmUser                   : prAEWebArmUser(Stream, ThreadData);
          csProductPage                    : prProductPage(Stream, ThreadData);
          csProductWareSearch              : prProductWareSearch(Stream, ThreadData);
          csProductGetOrigNumsAndWares     : prProductGetOrigNumsAndWares(Stream, ThreadData);
          csProductAddOrigNum              : prProductAddOrigNum(Stream, ThreadData);
          csProductDelOrigNum              : prProductDelOrigNum(Stream, ThreadData);
          csAccountsReestrPage             : prAccountsReestrPage(Stream, ThreadData);
          csAccountsGetFirmList            : prAccountsGetFirmList(Stream, ThreadData);
          csSearchWithOrNums               : prCommonWareSearch(Stream, ThreadData);
          csGetManufacturerList            : prGetManufacturerList(Stream, ThreadData);
          csWebArmGetAnalogs               : prGetWareAnalogs(Stream, ThreadData);
          csSaveWebArmUsers                : prSaveWebArmUsers(Stream, ThreadData);
          csManageBrands                   : prManageBrands(Stream, ThreadData);
          csGetBrandsGB                    : prGetBrandsGB(Stream, ThreadData);
          csGetBrandsTD                    : prGetBrandsTD(Stream, ThreadData);
          csGetLinkBrandsGBTD              : prGetLinkBrandsGBTD(Stream, ThreadData);
          csAddLinkBrandsGBTD              : prAddLinkBrandsGBTD(Stream, ThreadData);
          csDelLinkBrandsGBTD              : prDelLinkBrandsGBTD(Stream, ThreadData);
          csUiKPage                        : prUiKPage(Stream, ThreadData);
          csTNAGet                         : prTNAGet(Stream, ThreadData);
          csTNANodeAdd                     : prTNANodeAdd(Stream, ThreadData);
          csTNANodeDel                     : prTNANodeDel(Stream, ThreadData);
          csTNANodeEdit                    : prTNANodeEdit(Stream, ThreadData);
          csTNAManagePage                  : prTNAManagePage(Stream, ThreadData);
          csManufacturerAdd                : prManufacturerAdd(Stream, ThreadData);
          csManufacturerEdit               : prManufacturerEdit(Stream, ThreadData);
          csManufacturerDel                : prManufacturerDel(Stream, ThreadData);
          csGetModelLineList               : prGetModelLineList(Stream, ThreadData);
          csModelLineAdd                   : prModelLineAdd(Stream, ThreadData);
          csModelLineEdit                  : prModelLineEdit(Stream, ThreadData);
          csModelLineDel                   : prModelLineDel(Stream, ThreadData);
          csWebArmGetRegionalFirms         : prWebArmGetRegionalFirms(Stream, ThreadData);
          csWebArmGetFirmUsers             : prWebArmGetFirmUsers(Stream, ThreadData);
          csWebArmResetUserPassword        : prWebArmResetUserPassword(Stream, ThreadData);
          csWebArmSetFirmMainUser          : prWebArmSetFirmMainUser(Stream, ThreadData);
          csWebArmGetOrdersToRegister      : prWebArmGetOrdersToRegister(Stream, ThreadData);
          csWebArmAnnulateOrderToRegister  : prWebArmAnnulateOrderToRegister(Stream, ThreadData);
          csWebArmRegisterOrderToRegister  : prWebArmRegisterOrderToRegister(Stream, ThreadData);
          csGetFilialList                  : prGetFilialList(Stream, ThreadData);
          csWebArmGetRegionalZones         : prWebArmGetRegionalZones(Stream, ThreadData);
          csWebArmInsertRegionalZone       : prWebArmInsertRegionalZone(Stream, ThreadData);
          csWebArmDeleteRegionalZone       : prWebArmDeleteRegionalZone(Stream, ThreadData);
          csWebArmUpdateRegionalZone       : prWebArmUpdateRegionalZone(Stream, ThreadData);
          csGetModelLineModels             : prGetModelLineModels(Stream, ThreadData);
          csGetModelTree                   : prGetModelTree(Stream, ThreadData);
          csGetNodeWares                   : prCommonGetNodeWares(Stream, ThreadData);
          csModelAddToModelLine            : prModelAddToModelLine(Stream, ThreadData);
          csModelEdit                      : prModelEdit(Stream, ThreadData);
          csModelDel                       : prModelDel(Stream, ThreadData);
          csModelSetVisible                : prModelSetVisible(Stream, ThreadData);
          csAutoModelInfoLists             : prAutoModelInfoLists(Stream, ThreadData);
          csLoadModelData                  : prLoadModelData(Stream, ThreadData);

          csGetListAttrGroupNames          : prGetListAttrGroupNames(Stream, ThreadData);
          csGetListGroupAttrs              : prGetListGroupAttrs(Stream, ThreadData);
          csSearchWaresByAttrValues        : prCommonSearchWaresByAttr(Stream, ThreadData);
          csGetCompareWaresInfo            : prGetCompareWaresInfo(Stream, ThreadData);
          csGetWareInfoView                : prGetWareInfoView(Stream, ThreadData);
          csGetFilteredGBGroupAttValues    : prGetFilteredGBGroupAttValues(Stream, ThreadData); // ������������� ������ �������� ��������� Grossbee �� ������

          csSendWareDescrErrorMes          : prSendWareDescrErrorMes(Stream, ThreadData);
          csImportPage                     : prImportPage(Stream, ThreadData);
          csGetBaseStamp                   : prGetBaseStamp(Stream, ThreadData);
          csCommonImport                   : prCommonImport(Stream, ThreadData);
          csCheckWareManager               : prCheckWareManager(Stream, ThreadData);
          csModifyLink3                    : prModifyLink3(Stream, ThreadData);
          csGetWareList                    : prGetWareList(Stream, ThreadData);
          csLoadModelDataText              : prLoadModelDataText(Stream, ThreadData);
          csShowModelsWhereUsed            : prShowModelsWhereUsed(Stream, ThreadData);
          csMarkOrNum                      : prMarkOrNum(Stream, ThreadData);
          csShowCrossOE                    : prShowCrossOE(Stream, ThreadData);
          csShowCurrentOperations          : prShowCurrentOperations(Stream, ThreadData);
          csStopIEOperation                : prStopIEOperation(Stream, ThreadData);
          csShowEngineOptions              : prShowEngineOptions(Stream, ThreadData);
          csGetTop10Model                  : prGetTop10Model(Stream, ThreadData);
          csLoadEngines                    : prLoadEngines(Stream, ThreadData);
          csGetEngineTree                  : prGetEngineTree(Stream, ThreadData);
          csNewsPage                       : prNewsPage(Stream, ThreadData);
          csTestLinksLoading               : prTestLinksLoading(Stream, ThreadData);
          csGetFilterValues                : prGetFilterValues(Stream, ThreadData);
          csShowActionNews                 : prShowActionNews(Stream, ThreadData);
          csAEActionNews                   : prAEActionNews(Stream, ThreadData);
          csSaveImgForAction               : prSaveImgForAction(Stream, ThreadData);
          csUnblockWebUser                 : prUnblockWebUser(Stream, ThreadData);
          csDelActionNews                  : prDelActionNews(Stream, ThreadData);
          csShowSysOptionsPage             : prShowSysOptionsPage(Stream, ThreadData);
          csEditSysOption                  : prEditSysOption(Stream, ThreadData);
          csSaveSysOption                  : prSaveSysOption(Stream, ThreadData);
          csShowConstRoles                 : prShowConstRoles(Stream, ThreadData);
          csEditConstRoles                 : prEditConstRoles(Stream, ThreadData);
          csMarkOneDirectAnalog            : prMarkOneDirectAnalog(Stream, ThreadData);
          csAddOneDirectAnalog             : prAddOneDirectAnalog(Stream, ThreadData);
          csShowConditionPortions          : prShowConditionPortions(Stream, ThreadData);
          csGetWaresByOE                   : prCommonGetWaresByOE(Stream, ThreadData);
          csHideEmptyOE                    : prHideEmptyOE(Stream, ThreadData);
          csMarkPortions                   : prMarkPortions(Stream, ThreadData);
          csShowPortion                    : prShowPortion(Stream, ThreadData);
          csCOUPage                        : prCOUPage(Stream, ThreadData);
          csGetCateroryValues              : prGetCateroryValues(Stream, ThreadData);
          csSavePortion                    : prSavePortion(Stream, ThreadData);
          csGetSatellites                  : prGetWareSatellites(Stream, ThreadData);
//          csGetClientData                  : prWebArmGetFirmInfo(Stream, ThreadData);
          csGetRestsOfWares                : prCommonGetRestsOfWares(Stream, ThreadData);
          csLoadAccountList                : prWebArmGetFilteredAccountList(Stream, ThreadData);
          csWebArmShowAccount              : prWebArmShowAccount(Stream, ThreadData);
          csWebArmShowFirmWareRests        : prWebArmShowFirmWareRests(Stream, ThreadData);
          csWebArmEditAccountHeader        : prWebArmEditAccountHeader(Stream, ThreadData);
          csWebArmEditAccountLine          : prWebArmEditAccountLine(Stream, ThreadData);
          csWebArmGetWaresDescrView        : prWebArmGetWaresDescrView(Stream, ThreadData);
          csWebArmGetDeliviriesList        : prWebarmGetDeliveries(Stream, ThreadData);
          csCreateSubAcc                   : prWebArmMakeSecondAccount(Stream, ThreadData);
          csGetDeliveriesList              : prGetDeliveriesList(Stream, ThreadData);
          csRestorePassword                : prRestorePassword(Stream, ThreadData);
          csBlockWebArmUser                : prBlockWebArmUser(Stream, ThreadData);
          csWebArmMakeInvoiceFromAccount   : prWebArmMakeInvoiceFromAccount(Stream, ThreadData);
          csShowTransferInvoices           : prWebArmGetTransInvoicesList(Stream, ThreadData);
          csShowTransferInvoice            : prWebArmGetTransInvoice(Stream, ThreadData);
          csWebArmAddWaresFromAccToTransInv: prWebArmAddWaresFromAccToTransInv(Stream, ThreadData);
          csCheckRestsInStorageForAcc      : prCheckRestsInStorageForAcc(Stream, ThreadData);
          csAEDNotification                : prAEDNotification(Stream, ThreadData);
          csNotificationPage               : prNotificationPage(Stream, ThreadData);
          csWebArmGetNotificationsParams   : prWebArmGetNotificationsParams(Stream, ThreadData);
          csShowNotification               : prShowNotificationOrd(Stream, ThreadData);
          csShowNotificationWA             : prShowNotification(Stream, ThreadData);
          csWaresByOE                      : prSearchWaresByOE(Stream, ThreadData);
          csCheckContracts                 : prCheckContracts(Stream, ThreadData);
          csWebarmContractList             : prWebArmContractList(Stream, ThreadData);
          csManageLogotypesPage            : prManageLogotypesPage(Stream, ThreadData);
          csLogotypeEdit                   : prLogotypeEdit(Stream, ThreadData);
          csLoadOrder                      : prLoadOrder(Stream, ThreadData);
          csLampSelect                     : prGetActionsSrvMng(Stream, ThreadData);        // ???
          csGetTimeListSelfDelivery        : prGetTimeListSelfDelivery(Stream, ThreadData);    // ������ ��������� ������ ����������
          csGetContractDestPointsList      : prGetContractDestPointsList(Stream, ThreadData);  // ������ �������� ����� ���������
          csGetAvailableTimeTablesList     : prGetAvailableTimeTablesList(Stream, ThreadData); // ������ ��������� ���������� �� ���������
          csGetAccountShipParams           : prGetAccountShipParams(Stream, ThreadData);       // �������� ���������� �������� �����
          csSetAccountShipParams           : prSetAccountShipParams(Stream, ThreadData);       // �������������� ���������� �������� �����
          csGetDprtAvailableShipDates      : prGetDprtAvailableShipDates(Stream, ThreadData);  // ������ ��������� ��� �������� �� ������
          csWebArmResetPassword            : prWebArmResetPassword(Stream, ThreadData);
          csMPBIReportsPage                : prMPBIRep(Stream, ThreadData);
          csMPBIReportsFiles               : prMPBIFiles(Stream, ThreadData);
          csLoadFirmAccountList            : prWebArmGetFirmAccountList(Stream, ThreadData);   // ������ ������ �/� ��� ��
          csShowGBAccount                  : prShowGBAccountOrd(Stream, ThreadData);           // �������� ����� ��� ��
          csShowGBOutInvoice               : prShowGBOutInvoice(Stream, ThreadData);           // �������� ��������� ��� ��

          csGeneralNewSystemProcWebArm     : prGeneralNewSystemProcWebArm(Stream, ThreadData);  // ����� ��������� �� ����� ����� ������

          csMotulSitePage                  : prMotulSitePage(Stream, ThreadData);   // C����� ��� �������� "motul.vladislav.ua"
          csMotulSiteManage                : prMotulSiteManage(Stream, ThreadData); // �������� �� �������� "motul.vladislav.ua"

          else raise EBOBError.Create('�� �������� WebArm-������� - '+IntToStr(Command));
        end; //  case Command of
      except
        on E: Exception do begin
          Stream.Clear;
          Stream.WriteInt(aeCommonError);
          if (Command<>csTestLinksLoading) and (AppStatus=stWork) then
            fnWriteToLog(ThreadData, lgmsSysError, 'TMyClass.ServerWebArmConnect',
              'Command='+IntToStr(Command), E.Message, 'ErrorPos='+ErrorPos);
          Stream.WriteStr('������ �������� �� ������: '#13#10+E.Message);
        end;
      end;
      if Stream.Size>0 then begin
        i:= Stream.Size;
        AThread.Connection.IOHandler.Write(i);              //
        AThread.Connection.IOHandler.Write(Stream);         // ���������� ����� �� ������
      end;
      AThread.Connection.Disconnect;
      prFree(Stream);
    end else begin // ���� ����������� ���������
  ErrorPos:= '9';
      AThread.Connection.Disconnect;
    end; // if i=csWebArm
  except
    on E: Exception do begin
      fnWriteToLog(ThreadData, lgmsSysError, 'TMyClass.ServerWebArmConnect', '������ ������ �����', E.Message, 'ErrorPos='+ErrorPos);
      fnWriteToLog(ThreadData, lgmsInfo, 'TMyClass.ServerWebArmConnect', '�������� �������� �����', E.Message, 'ErrorPos='+ErrorPos);
    end;
  end;
  prDestroyThreadData(ThreadData, 'TMyClass.ServerWebConnect');
  prFree(Stream);
  if Assigned(AThread) and AThread.Connection.Connected then AThread.Connection.Disconnect;
end; //ServerWebArmConnect
//==============================================================================
procedure TMyClass.ServerManageConnect(AContext: TIdContext);
var i: integer;
    ThreadData: TThreadData;
    Command: word;
    ErrorPos: string;
    AThread: TIdContext;
    Stream: TBOBMemoryStream;
begin
ErrorPos:= '0';
  AThread:= AContext;
  ThreadData:= nil;
  Stream:= nil;
  Command:= 0;
  try
    AThread.Connection.IOHandler.ReadTimeout:=5000;
ErrorPos:= '1';
    i:= AThread.Connection.IOHandler.ReadLongInt;    // ��������� ���������
    AThread.Connection.IOHandler.ReadLongInt;   // ���������� ������������� ������
ErrorPos:= '3';
    if (i=csServerManage) then begin // ���� ��� ������ ���������� ��������
ErrorPos:= '8';
      Command:= word(AThread.Connection.IOHandler.ReadSmallInt);   // ��������� �������
      ThreadData:= fnCreateThread(fnSignatureToThreadType(i), Integer(Command));
ErrorPos:= '8-3';
      i:= AThread.Connection.IOHandler.ReadLongInt;                // ��������� ������ ���� �������
ErrorPos:= '8-6';
      Stream:= TBOBMemoryStream.Create;
ErrorPos:= '8-7';
      AThread.Connection.IOHandler.ReadStream(Stream, i);         // ��������� ���� �������
ErrorPos:= '8-8';
      try
        case Command of
          scGetStatus     : prGetFullStatus(Stream, ThreadData);       // ������� ������ ����������
          scUpdateCache   : prUpdateCacheSrvMng(Stream, ThreadData);   // �������� ���
          scGetActions    : prGetActionsSrvMng(Stream, ThreadData);    // �������� �����
          scSuspend, scResume, scExit:                                 // "�������", "���������", ��������� ����������
            prExecuteServerCommand(Stream, ThreadData, Command, AThread.Connection.Socket.Binding.PeerIP);
          scGetKAPhones   : prGetKAPhones(Stream, ThreadData);         // �������� �������� ����. ��� ��� ��������
          scGetMediaBlocks: prGetMediaBloksSrvMng(Stream, ThreadData); // �������� �����-�����
          scGetActionIcons: prGetActionIconsSrvMng(Stream, ThreadData); // �������� ������ �����
          else raise EBOBError.Create('�� �������� ����������� ������� - '+IntToStr(Command));
        end;
      except
        on E: Exception do begin
          Stream.Clear;
          Stream.WriteInt(aeCommonError);
          fnWriteToLog(ThreadData, lgmsSysError, 'TMyClass.ServerManageConnect', '', E.Message, '');
          Stream.WriteStr('������ �������� �� ������: '#13#10+E.Message);
        end;
      end;
ErrorPos:= '8-9';
      If Stream.Size>0 then begin
        i:= Stream.Size;
ErrorPos:= '8-10: Stream.Size='+IntToStr(i);
        AThread.Connection.IOHandler.Write(i);              //
ErrorPos:= '8-11: Stream.Size='+IntToStr(i);
        AThread.Connection.IOHandler.Write(Stream);         // ���������� ����� �� ������
ErrorPos:= '8-12';
      end;
      AThread.Connection.Disconnect;
      prFree(Stream);

    end else begin // ���� ����������� ���������
ErrorPos:= '9';
      AThread.Connection.Disconnect;
    end;
  except
    on E: Exception do begin
      fnWriteToLog(ThreadData, lgmsSysError, 'TMyClass.ServerManageConnect', '������ ������ �����, Command='+IntToStr(Command), E.Message, 'ErrorPos='+ErrorPos);
      fnWriteToLog(ThreadData, lgmsInfo, 'TMyClass.ServerManageConnect', '�������� �������� �����', E.Message, 'ErrorPos='+ErrorPos);
    end;
  end;
  prFree(Stream);
  if (AThread<>nil) and AThread.Connection.Connected then AThread.Connection.Disconnect;
  prDestroyThreadData(ThreadData, 'TMyClass.ServerManageConnect');
end; //ServerManageConnect
//==========================================================  TMyClass

//= ������� ��� ���������������� ���������� ������� � StringList � ������ ������
function fnWareCompareByBrand(List: TStringList; Index1, Index2: Integer): Integer;
var Ware1, Ware2: TWareInfo;
begin
  Ware1:= TWareInfo(Cache.arWareInfo[integer(List.Objects[Index1])]);
  Ware2:= TWareInfo(Cache.arWareInfo[integer(List.Objects[Index2])]);
  if (Ware1.WareBrandName<Ware2.WareBrandName) then Result:= -1
  else if (Ware1.WareBrandName>Ware2.WareBrandName) then Result:= 1
  else if (Ware1.Name<Ware2.Name) then Result:= -1
  else if (Ware1.Name>Ware2.Name) then Result:= 1
  else Result:= 0;
end;
//================================ ������� ��������� ������� �� ��������� ������
function fnGetWareListByBrand(Brand: integer; Sys: byte = 255; Sort: boolean = false): TStringList;
var i, recs: integer;
    ware: TWareInfo;
begin
  Result:= TStringList.Create;
  try
    if (not Cache.WareBrands.ItemExists(Brand)) then
      raise EBOBError.Create('�� ������ ����� � ����� '+IntToStr(Brand));
    recs:= Length(Cache.arWareInfo)-1;
    for i:= 0 to recs do if Cache.WareExist(i) then begin
      ware:= Cache.arWareInfo[i];
      if not (ware.WareBrandID=Brand) then Continue;
//      if not ware.CheckWareTypeSys(Sys) then Continue;
      Result.AddObject(ware.Name, pointer(ware.ID));
    end;
    if Sort then Result.Sort;
  except
    on E:Exception do raise Exception.Create('fnGetWareListByBrand: '+E.Message);
  end;
end;
//==============================================================================
function fnGetAdaptedConstValue(ConstID: integer): string;
const nmProc = 'fnGetAdaptedConstValue'; // ��� ���������/�������
var aos: Tas;
    s, ss: string;
    j, EmplCode, Code: integer;
    Item: TConstItem;
begin
  Result:= '';
  try
    if not Cache.ConstExists(ConstID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ���='+IntToStr(ConstID));

    Item:= Cache.GetConstItem(ConstID);
    s:= '';
    case ConstID of
      pcEmplID_list_Rep30, pcTestingSending1, pcTestingSending2, pcTestingSending3,
        pcEmpl_list_UnBlock, pcEmpl_list_TmpBlock, pcEmpl_list_FinalBlock, pcVINmailEmpl_list: begin
        aos:= fnSplitString(Item.StrValue, ',');
        for j:= 0 to High(aos) do begin
          EmplCode:= StrToIntDef(aos[j], 0);
          ss:= '';
          if (EmplCode<0) then begin
            if (EmplCode>=Low(ceNames)) and (EmplCode<=High(ceNames)) then
              ss:= ceNames[EmplCode];
          end else if Cache.EmplExist(EmplCode) then
            ss:= Cache.arEmplInfo[EmplCode].EmplShortName;
          if ss<>'' then s:= s+fnIfStr(s<>'', ', ', '')+ss;
        end;
        Result:= s;
      end; // pcEmplID_list_Rep30 ...

      pcVINmailFilial_list: begin
        aos:= fnSplitString(Item.StrValue, ',');
        for j:= 0 to High(aos) do begin
          Code:= StrToIntDef(aos[j], 0);
          if Cache.DprtExist(Code) and Cache.arDprtInfo[Code].IsFilial then
            if s<>'' then s:=s+fnIfStr(s<>'', ', ', '')+Cache.arDprtInfo[Code].Name;
        end;
        Result:= s;
      end; // pcVINmailFilial_list

      pcVINmailFirmClass_list, pcPriceLoadFirmClasses: begin
        aos:= fnSplitString(Item.StrValue, ',');
        for j:=0 to High(aos) do begin
          Code:= StrToIntDef(aos[j], 0);
          ss:= Cache.GetFirmClassName(Code);
          if ss<>'' then begin
            if s<>'' then s:= s+', ';
            s:= s+ss;
          end;
        end;
        Result:= s;
      end; // pcVINmailFirmClass_list, pcPriceLoadFirmClasses

      pcVINmailFirmTypes_list: begin
        aos:= fnSplitString(Item.StrValue, ',');
        for j:=0 to High(aos) do begin
          Code:= StrToIntDef(aos[j], -1);
          ss:= Cache.GetFirmTypeName(Code);
          if ss<>'' then begin
            if s<>'' then s:=s+', ';
            s:= s+ss;
          end;
        end;
        Result:= s;
      end; // pcVINmailFirmTypes_list

      pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto: begin
        Code:= StrToIntDef(Item.StrValue, 0);
        if Cache.EmplExist(Code) then
          Result:= Cache.arEmplInfo[Code].EmplShortName
        else Result:= '�����������';
      end; // pcEmplSaleDirectorAuto, pcEmplSaleDirectorAuto

    else Result:= Item.StrValue;
    end; // case
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'for constID='+IntToStr(ConstID)+': '+E.Message);
    on E: Exception do raise Exception.Create(nmProc+'for constID='+IntToStr(ConstID)+': '+E.Message);
  end;
  SetLength(aos, 0);
end;  // fnGetAdaptedConstValue
//======== ������������ ��� ���������� ������ ����� ������� � ����������� ������
function TypeNamesSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var i1, i2: Integer;
begin
  try
    i1:= Integer(List.Objects[Index1]);
    i2:= Integer(List.Objects[Index2]);
    if (i1=i2) then Result:= 0
    else if (i1=0) then Result:= 1
    else if (i2=0) then Result:= -1
    else Result:= AnsiCompareText(List[Index1], List[Index2]);
  except
    Result:= 0;
  end;
end;
//============ ������������ ��� ���������� �������� ���� TTwoCodes � TObjectList
//====================================��� ������ ������ �������������� ����/����
function SortCompareManufNamesForTwoCodes(Item1, Item2: Pointer): Integer;
begin
  Result:= CompareText(Cache.FDCA.Manufacturers[TTwoCodes(Item1).ID1].Name,
    Cache.FDCA.Manufacturers[TTwoCodes(Item2).ID1].Name);
end;
//========================= ������������ ��� ���������� StringList � TObjectList
//======================================= ��� ������ ������ ������� ������������
function SortCompareConditionPortions(Item1, Item2: Pointer): Integer;
begin
  Result:= CompareText(TStringList(Item1).QuoteChar, TStringList(Item2).QuoteChar);
end;
//================= ���������, ���������� �� ����� ��������, true - �� ���������
function CheckShipmentDateTime(Data: TDate; TimeCode: integer): boolean;
var Hour, Minute: double;
    st: TShipTimeItem;
begin
  Result:= not fnNotZero(Data);
  if Result then Exit;
  if TimeCode=0 then begin
    Hour:= 23;
    Minute:= 59.9999999;
  end else begin
    st:= Cache.ShipTimes[TimeCode];
    Hour:= st.Hour;
    Minute:= st.Minute;
  end;
  Result:=(Data+Hour/24+Minute/60/24)>Now();
end; // CheckShipmentDateTime
//----------------------------------------- vc

//----------------------------------------- v_CSSServerManageProcs
procedure CheckManagePassw(passw: String);
const ManageDefPassw = 'sdihhhsdohsdohsovhovhsodvhsdohsdohSDObhSDObhsdohsdohbhSbuo';
begin
  if (passw<>GetIniParam(nmIniFileBOB, 'Manage', 'ManagePass', ManageDefPassw)) then
    raise Exception.Create('������������ ������');
end;
//==============================================================================
procedure prGetFullStatus(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFullStatus'; // ��� ���������/�������
var i, Count, iState: integer;
    s, s1: string;
//    Pools: array of TIBCntsPool;
    pool: TIBCntsPool;
begin
  pool:= nil;
  try
    Stream.Position:= 0;
    s1:= Stream.ReadStr;
    CheckManagePassw(s1);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(AppStatus);
    if AppStatus in [stSuspending, stSuspended] then begin  // ���� ���������� ����, �� ���������� ������ ��������� ��� ��������
      s:= '';
      for i:= 0 to High(StopList) do s:= StopList[i]+', ';
      Stream.WriteStr(Copy(s, 1, length(s)-2));
    end;

    Stream.WriteByte(1);
    Stream.WriteByte(1);

    if (ServerWeb=nil) then iState:= sttcpsrvNone
    else if ServerWeb.Active then iState:= sttcpsrvActive
    else iState:= sttcpsrvSuspended;
    Stream.WriteInt(iState);

    if (ServerWebArm=nil) then iState:= sttcpsrvNone
    else if ServerWebArm.Active then iState:= sttcpsrvActive
    else iState:= sttcpsrvSuspended;
    Stream.WriteInt(iState);

    Stream.WriteInt(stthrdNone); // RespThread
    Stream.WriteInt(stthrdNone); // MailThread
    Stream.WriteInt(stthrdNone); // TestThread

    if (thCheckStoppedOrders=nil) then Stream.WriteInt(stthrdNone)
    else begin
      Stream.WriteInt(TCSSCyclicThread(thCheckStoppedOrders).Status);
      Stream.WriteDouble(TCSSCyclicThread(thCheckStoppedOrders).LastTime);
    end;

    if (thCheckDBConnectThread=nil) then Stream.WriteInt(stthrdNone)
    else begin
      Stream.WriteInt(TCSSCyclicThread(thCheckDBConnectThread).Status);
      Stream.WriteDouble(TCSSCyclicThread(thCheckDBConnectThread).LastTime);
    end;
    Stream.WriteInt(Cache.GetTestCacheIndication);
    Stream.WriteDouble(Cache.GetLastTimeCache);

    Count:= 4;
{    SetLength(Pools, Count+1);
    Pools[0]:= cntsGRB;
    Pools[1]:= cntsORD;
    Pools[2]:= cntsLOG;
    Pools[3]:= cntsSUF;
    Pools[4]:= cntsTDT;  }
    Stream.WriteInt(Count+1);
    for i:= 0 to Count do begin
      case i of
        0: Pool:= cntsGRB;
        1: Pool:= cntsORD;
        2: Pool:= cntsLOG;
        3: Pool:= cntsSUF;
        4: Pool:= cntsTDT;
      end;
      Stream.WriteStr(Pool.CntsComment);
      Stream.WriteStr(Pool.dbPath);
      Stream.WriteBool(Pool.BaseConnected);

{      Stream.WriteStr(Pools[i].CntsComment);
      Stream.WriteStr(Pools[i].dbPath);
      Stream.WriteBool(Pools[i].BaseConnected); }
    end;
  except
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
//  SetLength(Pools, 0);
  Stream.Position:= 0;
end; // prGetFullStatus
//==============================================================================
procedure prExecuteServerCommand(Stream: TBoBMemoryStream; ThreadData: TThreadData; ACommand: integer; AIP: string);
const nmProc = 'prExecuteServerCommand'; // ��� ���������/�������
var s: string;
begin
  try
    Stream.Position:= 0;
    s:= Stream.ReadStr;
    CheckManagePassw(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    while ManageCommandsLock do sleep(50);
    try
      ManageCommandsLock:= true;
      if ACommand=scExit then SetLength(arManageCommands, 1)
      else SetLength(arManageCommands, Length(arManageCommands)+1);
      arManageCommands[Length(arManageCommands)-1].Command:= ACommand;
      arManageCommands[Length(arManageCommands)-1].IP:= AIP;
    finally
      ManageCommandsLock:= false;
    end;
  except
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end; // prExecuteServerCommand
//==============================================================================
procedure prUpdateCacheSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prUpdateCacheSrvMng'; // ��� ���������/�������
var s: string;
begin
  try
    Stream.Position:= 0;
    s:= Stream.ReadStr;
    CheckManagePassw(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    with TCSSCyclicThread(thCheckDBConnectThread) do
    if ExpressFlag or Cache.WareCacheTested then
      raise EBoBError.Create('����������� '+fnIfStr(ExpressFlag, '�������', '�������')+' �������� ����')
    else ExpressFlag:= True;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end; // prExecuteServerCommandprUpdateCacheSrvMng
//==============================================================================
procedure prGetActionsSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetActionsSrvMng'; // ��� ���������/�������
var Count, Pos: integer;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
begin
  ordIBD:= nil;
  OrdIBS:= nil;
  try
    Stream.Position:= 0;
    ordIBD:= CntsOrd.GetFreeCnt();
    OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);
    OrdIBS.SQL.Text:= 'Select * from infoboxviews'+
      ' where "TODAY" between IBVDATEFROM and IBVDATETO and (IBVVISAUTO="T" or IBVVISMOTO="T")'+
      ' order by IBVPRIORITY desc, IBVDATEFROM desc';
    OrdIBS.ExecQuery;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Pos:= Stream.Position;
    Stream.WriteInt(0); // �������� ��� ���-��
    Count:= 0;
    while not OrdIBS.EOF do begin
      Stream.WriteInt(OrdIBS.FieldByName('IBVCODE').Asinteger);
      Stream.WriteBool(GetBoolGB(OrdIBS, 'IBVVISAUTO'));
      Stream.WriteBool(GetBoolGB(OrdIBS, 'IBVVISMOTO'));
      Stream.WriteBool(GetBoolGB(OrdIBS, 'IBVVISIBLE'));
      Stream.WriteInt(OrdIBS.FieldByName('IBVPRIORITY').Asinteger);
      Stream.WriteStr(OrdIBS.FieldByName('IBVTITLE').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('IBVLINKTOSITE').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('IBVLINKTOPICT').AsString);
      inc(Count);
      TestCssStopException;
      OrdIBS.Next;
    end;
    if (Count>0) then begin
      Stream.Position:= Pos;
      Stream.WriteInt(Count);
    end;
    Stream.SaveToFile('actions.raw');
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(ordIBD);
end;
//======================================================== �������� ������ �����
procedure prGetActionIconsSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetActionIconsSrvMng'; // ��� ���������/�������
var Count, Pos, fsize, i: integer;
    s, ImageFname, mbPath: String;
    IBD: TIBDatabase;
    IBS: TIBSQL;
    msp: TMemoryStream;
begin
  IBD:= nil;
  IBS:= nil;
  msp:= nil;
  Count:= 0;
  try try
    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Pos:= Stream.Position;
    Stream.WriteInt(0); // �������� ��� ���-��

    if not TestRDB(CntsGRB, trkField, 'WareActionReestr', 'WrAcPhoto') then Exit; // ���� ������� ���� ������

    try
      msp:= TMemoryStream.Create;
      IBD:= CntsGRB.GetFreeCnt();
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, true);
      ibs.SQL.Text:= 'SELECT WrAcCode, WrAcExtn, WrAcPhoto from WareActionReestr'+
        ' where WrAcSubFirmCode=1 and WrAcDocmState=1'+
        '   and WrAcStartDate<="today" and WrAcStopDate>("today"-'+
        Cache.GetConstItem(pcClosedActionShowDays).StrValue+')';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        s:= IBS.FieldByName('WrAcExtn').AsString;
        if (s<>'') then begin
          msp.Clear;
          IBS.FieldByName('WrAcPhoto').SaveToStream(msp);
          fsize:= msp.Size;
          if (fsize>0) then begin
            ImageFname:= ibs.fieldByName('WrAcCode').AsString+'.'+s;
            Stream.WriteStr(ImageFname); // ��� ����� �������� � ����� actionicons
            Stream.WriteInt(fsize);     // ������ ������
            msp.Position:= 0;
            Stream.CopyFrom(msp, fsize); // ������
            inc(Count);
          end;
        end;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
      if (Count>0) then begin
        Stream.Position:= Pos;
        Stream.WriteInt(Count);
      end;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
      prFree(msp);
    end;
    mbPath:= fnTestDirEnd(fnCreateTmpDir('', 'actionicons'));

//---------------------------------- ��������� �������� ����� (��� Csscommander)
    prDeleteAllFiles('*.*', mbPath); // �������� ���� ������ � ����� mbPath = ...\order\app\actionicons\
//    Stream.Position:= 0;
//    Stream.SaveToFile(mbPath+'actionicons.raw');
    try
      msp:= TMemoryStream.Create;
      Stream.Position:= 0;
      Stream.ReadInt;     // aeSuccess

      Count:= Stream.ReadInt; // ���-��
      for i:= 1 to Count do begin
        ImageFname:= Stream.ReadStr; // ��� ����� ������
        fsize:= Stream.ReadInt;  // ������ ������
        if (fsize>0) then begin
          msp.Clear;
          msp.CopyFrom(Stream, fsize); // ������
          msp.Position:= 0;
          msp.SaveToFile(mbPath+ImageFname); // ����� ������ � ����
        end;
      end;  // for i:= 1
    finally
      prFree(msp);
    end;
//---------------------------------------------------- ��� Csscommander
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  finally
    Stream.Position:= 0;
  end;
end;
//============================================================ ���� �����-������
procedure prGetMediaBloksSrvMng(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetMediaBloksSrvMng'; // ��� ���������/�������
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    iType, mbLast, fsize, i, j, ShowInt: integer;
    s, mbPath, mbFile, sHint, sWEBLink, MBnum, ss: String;
    arMBnums: Tas;
    arMedia: array of array of Rmedia;
    mBibb: Rmedia;
    ware: TWareInfo;
    pIniFile: TIniFile;
    msp: TMemoryStream;
    Strings: TStrings;
//    LocalStart: TDateTime;
begin
//  LocalStart:= now();
  GBIBS:= nil;
  GBIBD:= nil;
  SetLength(arMBnums, 0);
  SetLength(arMedia, 0, 0);
  Stream.Position:= 0;
  try
    mbLast:= -1;
    with mBibb do begin // ������� ��������
      InfoType:= cmbBibb;
      WareCode:= 0;
      WareName:= '';
      ShowInterval:= 0;
      actID:= 0;
      actName:= '';
      ms:= TMemoryStream.Create;
    end; // with mBibb

    GBIBD:= CntsGRB.GetFreeCnt();
    GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:=
      'select * from (select num.andtname BlockNum, mr1.MdBlInformationType InfoType,'+
      '    mr1.MdBlShowInterval ShowInterval, mr1.MdBlHint Hint, mr1.MdBlWEBLink WEBLink,'+
      '    mr1.MdBlImage Image, mr1.MdBlImageExtn ImageExt, 0 wCode, 0 WareCode, mr1.mdblcode'+
      '  from MediaBlockReestr mr1'+
      '  left join AnalitDict Num on AndtCode = mr1.MdBlBlockCode'+
      '  where mr1.MdBlDocmState = 1 and (mr1.MdBlInformationType = 2'+
      '    or (mr1.MdBlInformationType = 0'+
      '    and "today" between mr1.MdBlStartdate and mr1.MdBlStopdate))'+
      '  union select num.andtname BlockNum, mr2.MdBlInformationType InfoType,'+
      '    mr2.MdBlShowInterval ShowInterval, mr2.MdBlHint Hint, mr2.MdBlWEBLink WEBLink,'+
      '    null Image, null ImageExt, MdBlWrCode wCode, MdBlWrWareCode WareCode, mr2.mdblcode'+
      '  from MediaBlockReestr mr2'+
      '  left join AnalitDict Num on AndtCode = mr2.MdBlBlockCode'+
      '  left join MediaBlockWares on MdBlWrDocmCode = MdBlCode'+
      '  where mr2.MdBlDocmState = 1 and mr2.MdBlInformationType = 1'+
      '    and "today" between mr2.MdBlStartdate and mr2.MdBlStopdate)'+
      '  order by BlockNum, InfoType, mdblcode, wCode';
    // ���������� - ����, ���, ��� ���-��, ��� ����� ���-�� (��� �������)
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      s:= GBIBS.FieldByName('BlockNum').AsString; // ����� �����
      if (Length(arMBnums)>0) then mbLast:= High(arMBnums); // ������� ������
//------------------------------------------------------------- ����� �����-����
      if (mbLast<0) or (s<>arMBnums[mbLast]) then begin
        mbLast:= mbLast+1;
        SetLength(arMBnums, mbLast+1);
        arMBnums[mbLast]:= s;
        SetLength(arMedia, mbLast+1);
        SetLength(arMedia[mbLast], 1);
        with mBibb do begin // ������ ��������
          Hint:= '';
          WEBLink:= '';
          ImageFname:= '';
          fsize:= 0;
          ShowInterval:= 0;
          actID:= 0;
          actName:= '';
          ms.Clear;
        end; // with mBibb
      end; // ����� �����-�����
//----------------------------------------------------------------- 1 �����-����
      j:= 0;
      while not GBIBS.EOF and (arMBnums[mbLast]=GBIBS.FieldByName('BlockNum').AsString) do begin
        iType:= GBIBS.FieldByName('InfoType').AsInteger;
        // ������������ ������ ��� ����������: 0 - ��������, 1 - �����, 2 - ��������
        if not (iType in [cmbPict, cmbWare, cmbBibb]) then begin
          GBIBS.Next;
          Continue;
        end;
        sHint:= GBIBS.FieldByName('Hint').AsString;       // ����������� ���������
        sHint:= fnChangeEndOfStrBySpace(sHint);
        sWEBLink:= GBIBS.FieldByName('WEBLink').AsString; // ������ �� ������
        sWEBLink:= fnChangeEndOfStrBySpace(sWEBLink);
        ShowInt:= GBIBS.FieldByName('ShowInterval').AsInteger;

        if (iType<>cmbWare) then   // �� ����� - ��������� ��� ����� ��������
          mbFile:= 'm_pic_'+arMBnums[mbLast]+'_'+IntToStr(j+1)+GBIBS.FieldByName('ImageExt').AsString;

        if (iType<>cmbBibb) then begin // ��������, ����� (�� ��������)
          if (j>High(arMedia[mbLast])) then SetLength(arMedia[mbLast], j+10);
          with arMedia[mbLast][j] do begin
            InfoType:= iType;
            Hint:= sHint;
            WEBLink:= sWEBLink;
            ShowInterval:= ShowInt;   // ???
            ms:= TMemoryStream.Create;
            if (iType=cmbWare) then begin // �����
              WareCode:= GBIBS.FieldByName('WareCode').AsInteger;
              ware:= Cache.GetWare(WareCode);
              WareName:= ware.Name;
              if ware.IsPrize then begin
                InfoType:= cmbPriz;       // ��� ����������: 3 - �����-�������
                if ware.IsNews then actID:= -1 else
                if ware.IsCatchMom then actID:= -2 else actID:= 0;
                actName:= '';
              end else actID:= ware.GetActionParams(actName, ss);

              if (Hint='') then Hint:= Ware.Name+' '+Ware.Comment;
              ImageFname:= '';
              fsize:= 0;
                                        // ��� ������ - ���� 1-� �������� TD
              if (iType=cmbWare) then ImageFname:= Ware.GetFirstTDPictName;

            end else begin
              WareCode:= 0;
              WareName:= '';
              actID:= 0;
              actName:= '';
              ImageFname:= mbFile;
              GBIBS.FieldByName('Image').SaveToStream(ms);
              fsize:= ms.Size;
            end;
          end; // with arMedia[mbLast][iCount]
          inc(j);

        end else with mBibb do begin  // �������� - ����� ���������
          Hint:= sHint;
          WEBLink:= sWEBLink;
          ShowInterval:= ShowInt;   // ???
          ImageFname:= mbFile;
          ms.Clear; // ���� ��������� ��������, ������������
          GBIBS.FieldByName('Image').SaveToStream(ms);
          fsize:= ms.Size;
        end; // with mBibb

        TestCssStopException;
        GBIBS.Next;
      end; // while not GBIBS.EOF and (s=GBIBS.FieldByName('BlockNum').AsString)

      if (Length(arMedia[mbLast])>j) then SetLength(arMedia[mbLast], j);
                                          // ���� ������ ������ � ���� ��������
      if (Length(arMedia[mbLast])<1) and (mBibb.ImageFname<>'') then begin
        SetLength(arMedia[mbLast], 1);
        with arMedia[mbLast][0] do begin
          InfoType:= mBibb.InfoType;
          Hint:= mBibb.Hint;
          WEBLink:= mBibb.WEBLink;
          ShowInterval:= mBibb.ShowInterval;   // ???
          WareCode:= 0;
          WareName:= '';
          actID:= 0;
          actName:= '';
          ImageFname:= mBibb.ImageFname;
          ms:= TMemoryStream.Create;
          fsize:= mBibb.ms.Size;
          mBibb.ms.Position:= 0;
          ms.CopyFrom(mBibb.ms, fsize); // ��������
        end;
      end; // ���� ������ ������ � ���� ��������

    end; // while not GBIBS.EOF
    GBIBS.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);         // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(Length(arMBnums));  // ���-�� ������
    for i:= 0 to High(arMBnums) do begin
      Stream.WriteStr(arMBnums[i]);        // ������������ ����� (1, 2, 3)
      Stream.WriteInt(Length(arMedia[i])); // ���-�� ��������� �����
      for j:= 0 to High(arMedia[i]) do with arMedia[i][j] do begin
        s:= IntToStr(InfoType)+'|'+ // ���: 0 - ��������, 1 - ������� �����, 2 - ��������, 3 - �������
            IntToStr(ShowInterval)+'|'+ // �������� �����������
            WEBLink+'|'+            // ������, ���� ���� �� ������ �� ��������, ���� ����� - ��� InfoType in [1,3] ��������� ���� ��������� ������
            Hint+'|'+               // ����� ����������� ���������
            IntToStr(WareCode)+'|'+ // ��� ������ (InfoType in [1,3]), ������� ������������� �� ������� ����� � ����������� � ���� �����
            WareName+'|'+           // ������������ ������ (InfoType in [1,3]) - �������� � ��������� ������� �����
            IntToStr(actID)+'|'+    // ��� ����� ������ (InfoType=1)
            actName+'|';            // ������������ ����� ������ (InfoType=1) - ��������� �� ������ �����
        Stream.WriteStr(s);
        Stream.WriteStr(ImageFname); // ��� ����� �������� � ����� media ��� InfoType in [0,2] ��� ��� ����� ��� ������ � tdfiles ��� InfoType=1
        Stream.WriteInt(fsize);     // ������ ��������
        if (fsize>0) then begin
          ms.Position:= 0;
          Stream.CopyFrom(ms, fsize); // ��������
        end;
      end; // for j:= 0 to
    end; // for i:= 0 to

//if flDebug then begin
    mbPath:= fnTestDirEnd(fnCreateTmpDir('', 'media'));  // ???

//---------------------------------- ��������� �������� ����� (��� Csscommander)
    prDeleteAllFiles('*.*', mbPath); // �������� ���� ������ � ����� mbPath = ...\order\app\media\
  //  Stream.SaveToFile(mbPath+'media.raw');
    s:= mbPath+'media.ini';          // ini-���� � ����� mbPath = ...\order\app\media\
    fnTestFileCreate(s);             // ��������� ������������� Ini-�����, ���� ��� - �������
    pIniFile:= TINIFile.Create(s);
    msp:= TMemoryStream.Create;
    try
      Stream.Position:= 0;
      Stream.ReadInt;     // aeSuccess

      iType:= Stream.ReadInt; // ���-�� ������
      for i:= 1 to iType do begin
        MBnum:= Stream.ReadStr;  // ������������ ����� (1, 2, 3) - ������ ��� ini-�����
        mbLast:= Stream.ReadInt; // ���-�� ��������� �����
        for j:= 1 to mbLast do begin
          s:= Stream.ReadStr;      // ������ ��� ini-����� ��� ����� ����� ��������
          mbFile:= Stream.ReadStr; // ��� ����� ��������
          fsize:= Stream.ReadInt;  // ������ ��������
          if (fsize>0) then begin
            msp.Clear;
            msp.CopyFrom(Stream, fsize); // ��������
            msp.Position:= 0;
            msp.SaveToFile(mbPath+mbFile); // ����� �������� � ����
          end;
          pIniFile.WriteString(MBnum, 'm'+IntToStr(j), s+mbFile); // ������ � ini-����
        end; // for j:= 1
      end;  // for i:= 1
    finally
      prFree(msp);
      prFree(pIniFile);
    end;
//---------------------------------------------------- ��� Csscommander

//----------------------------------------- ���� �� ������� ������ - ������ � ��
    if (Length(arMBnums)<3) and fnGetActionTimeEnable(caeOnlyWorkTime) then try
      Strings:= TStringList.Create;
      s:= '';
      for i:= 0 to High(arMBnums) do s:= s+fnIfStr(s='', '', ', ')+arMBnums[i];
      Strings.Add('��������!');
      Strings.Add(' ');
      if (s='') then
        Strings.Add('��� ������ ��� �����-������ ��� �� ������� ����')
      else begin
        Strings.Add('� ��� ��������� �����-�����: '+s+',');
        Strings.Add(' ');
        Strings.Add('�� ������ ��� ������ �� ������� ����');
      end;
      sHint:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ���������� � ���
      s:= n_SysMailSend(sHint, '��� ������ �� �����-������', Strings, nil, cNoReplayEmail, '', true);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then // ���� �� �������� � ���� ��� ��������
        fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', s, '');
    finally
      prFree(Strings);
    end;

//  prMessageLOGS(nmProc+': - '+GetLogTimeStr(LocalStart), fLogDebug, false);
//end; // if flDebug
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(GBIBD);
  for i:= 0 to High(arMedia) do for j:= 0 to High(arMedia[i]) do prFree(arMedia[i][j].ms);
  SetLength(arMedia, 0, 0);
  SetLength(arMBnums, 0);
end;

//----------------------------------------- v_CSSServerManageProcs

//******************************************************************************
//                     TVSMail - Vladislav Software Mail
//******************************************************************************
constructor TVSMail.Create;
begin
  inherited Create;
  CheckXstring; // def ������ ��� ������� � ��������� ������ (SysMailSend)
end;
//========================== ������ ��� ������� � ��������� ������ (SysMailSend)
procedure TVSMail.CheckXstring(section: String=''; value: String='');
var s: String;
begin
  if section<>'' then s:= section+': ' else s:= 'X-From-Prg: ';
  if value<>'' then s:= s+value else s:= s+'Vladislav Software';
  s:= s+' ('+GetAppExeName+', '+fnGetComputerName+')';
  if Xstring<>s then Xstring:= s;
end;
//===========================================
procedure TVSMail.OnInitISO(var VHeaderEncoding: Char; var VCharSet: String);
begin
  VCharSet:= IdCharsetNames[FindCharset(cCharSetWin)];
//  VHeaderEncoding:= 'B';     { base64 / quoted-printable }
end;

//******************************************************************************
//                          TSearchWareOrOnum
//******************************************************************************
constructor TSearchWareOrOnum.Create(pID, pSatCount: Integer; pIsWare, pIsMarket: Boolean; parAnalogs: Tai=nil);
var i: Integer;
begin
  ID:= pID;
  if pIsMarket then RestSem:= 0 else RestSem:= -1;
  IsWare:= pIsWare;
  SatCount:= pSatCount;
  OLAnalogs:= TObjectList.Create; // (TTwoCodes - ID, sem)
  if Assigned(parAnalogs) and (Length(parAnalogs)>0) then
    for i:= 0 to High(parAnalogs) do OLAnalogs.Add(TTwoCodes.Create(parAnalogs[i], -1));
  AddComment:= '';
  SemTitle:= '';
end;
//==============================================================================
destructor TSearchWareOrOnum.Destroy;
begin
  prFree(OLAnalogs);
  inherited;
end;

//******************************************************************************
//=================================================== �������� ��������� �������
procedure TestCssStopException;
begin
  if AppStatus in [stSuspending, stSuspended, stExiting] then
    raise EBOBError.Create('������� ������� ��-�� ��������� �������');
end;
//================================ ��������� �������� ���� Fname ibsql � boolean
function GetBoolGB(ibsql: TIBSQL; Fname: string): boolean;
begin
  Result:= False;
  if not Assigned(ibsql) or (Fname='') or (ibsql.FieldIndex[Fname]<0) then Exit;
  Result:= ibsql.fieldByName(Fname).AsString='T';
end;
//==============================================================================
function RepeatExecuteIBSQL(IBS: TIBSQL; repeats: Integer=RepeatCount): string;
// ��������� IBSQL RepeatCount �������
var i: integer;
begin
  Result:= '';
  if not Assigned(IBS) then Exit;
  for i:= 1 to repeats do with IBS.Transaction do try
    Application.ProcessMessages;
    IBS.Close;
    if not InTransaction then StartTransaction;
    IBS.ExecQuery;
    Commit;
    break;
  except
    on E: Exception do begin
      RollbackRetaining;
      if (Pos('lock', E.Message)>0) and (i<repeats) then
        Sleep(RepeatSaveInterval) // ���� �������
      else begin
        Result:= E.Message;
        break;
      end;
    end;
  end;
  IBS.Close;
end;
//==============================================================================
function RepeatExecuteIBSQL(IBS: TIBSQL; Fname: string; var StrValue: string; repeats: Integer=RepeatCount): string;
// ��������� IBSQL RepeatCount �������, ���������� ���������� �������� ��������� ����
var i: integer;
begin
  Result:= '';
  if not Assigned(IBS) then Exit;
  for i:= 1 to repeats do with IBS.Transaction do try
    Application.ProcessMessages;
    IBS.Close;
    if not InTransaction then StartTransaction;
    IBS.ExecQuery;
    if (Fname<>'') and not (IBS.Bof and IBS.Eof) then
      StrValue:= IBS.FieldByName(Fname).AsString;
    Commit;
    break;
  except
    on E: Exception do begin
      RollbackRetaining;
      if (Pos('lock', E.Message)>0) and (i<repeats) then
        Sleep(RepeatSaveInterval) // ���� �������
      else begin
        Result:= E.Message;
        break;
      end;
    end;
  end;
  IBS.Close;
end;
//==============================================================================
function RepeatExecuteIBSQL(IBS: TIBSQL; var FnamesValues: Tas; repeats: Integer=RepeatCount): string;
// FnamesValues �� ����� - ����� �����,
// FnamesValues �� ������ - ���������� �������z ��������������� �����
// ��������� IBSQL RepeatCount �������
var i, j: integer;
    s: string;
begin
  Result:= '';
  if not Assigned(IBS) then Exit;
  for i:= 1 to repeats do with IBS.Transaction do try
    Application.ProcessMessages;
    IBS.Close;
    if not InTransaction then StartTransaction;
    IBS.ExecQuery;
    if not (IBS.Bof and IBS.Eof) and (length(FnamesValues)>0) then
      for j:= 0 to High(FnamesValues) do begin
        s:= FnamesValues[j];
        if (s='') then Continue;
        if (IBS.FieldIndex[s]<0) then s:= '' else s:= IBS.FieldByName(s).AsString;
        FnamesValues[j]:= s;
      end; // for
    Commit;
    break;
  except
    on E: Exception do begin
      RollbackRetaining;
      if (Pos('lock', E.Message)>0) and (i<repeats) then
        Sleep(RepeatSaveInterval) // ���� �������
      else begin
        Result:= E.Message;
        break;
      end;
    end;
  end;
  IBS.Close;
end;
//==============================================================================
function RepeatExecuteIBSQL(IBS: TIBSQL; Fname: string; var IntValue: Integer; repeats: Integer=RepeatCount): string;
// ��������� IBSQL RepeatCount �������, ���������� �������� �������� ��������� ����
var i: integer;
begin
  Result:= '';
  if not Assigned(IBS) then Exit;
  for i:= 1 to repeats do with IBS.Transaction do try
    Application.ProcessMessages;
    IBS.Close;
    if not InTransaction then StartTransaction;
    IBS.ExecQuery;
    if (Fname<>'') and not (IBS.Bof and IBS.Eof) then
      IntValue:= IBS.FieldByName(Fname).AsInteger;
    Commit;
    break;
  except
    on E: Exception do begin
      RollbackRetaining;
      if (Pos('lock', E.Message)>0) and (i<repeats) then
        Sleep(RepeatSaveInterval) // ���� �������
      else begin
        Result:= E.Message;
        break;
      end;
    end;
  end;
  IBS.Close;
end;
//============================================= ���� � ������� ������ ����������
function GetEmplTmpFilePath(EmplID: Integer; var pFilePath, errmess: string): boolean;
begin
  errmess:= '';
  pFilePath:= '';
  with Cache do if not EmplExist(EmplID) then errmess:= MessText(mtkNotEmplExist)
  else begin
    pFilePath:= GetAppExePath+'TMP';
    if DirectoryExists(pFilePath) or ForceDirectories(pFilePath) then begin
      pFilePath:= fnTestDirEnd(pFilePath)+arEmplInfo[EmplID].ServerLogin;
      if not DirectoryExists(pFilePath) and not ForceDirectories(pFilePath) then
        errmess:= MessText(mtkNotCreateDir, pFilePath);
    end else errmess:= MessText(mtkNotCreateDir, pFilePath);
  end;
  Result:= errmess='';
  if Result then pFilePath:= fnTestDirEnd(pFilePath);
end;
{//====================================================== ��������� ������� �����
function CheckNotValidFirmSys(FirmID, SysID: Integer; var errmess: string): boolean;
begin
  errmess:= '';
  if (FirmID<>isWe) and not Cache.arFirmInfo[FirmID].CheckSysType(SysID) then
    errmess:= MessText(mtkNotRightExists);
  Result:= errmess<>'';
end;     }
//====================== ��������� ����� ���������� �� ������ � �������� �������
function CheckNotValidModelManage(UserID, SysID: Integer; var errmess: string): boolean;
begin
  errmess:= '';
  with Cache do if not CheckTypeSys(SysID) then
    errmess:= MessText(mtkNotFoundTypeSys, IntToStr(SysID))
  else if not EmplExist(UserID) then errmess:= MessText(mtkNotEmplExist)
  else with arEmplInfo[UserId] do
    if ((SysID=constIsAuto) and not UserRoleExists(rolModelManageAuto)) or
      ((SysID=constIsMoto) and not UserRoleExists(rolModelManageMoto)) then
      errmess:= MessText(mtkNotRightExists);
  Result:= errmess<>'';
end;
//================= ��������� ����� ���������� �� ������ � ������� ����� �������
function CheckNotValidTNAManage(UserID, SysID: Integer; var errmess: string): boolean;
begin
  errmess:= '';
  with Cache do if not CheckTypeSys(SysID) then
    errmess:= MessText(mtkNotFoundTypeSys, IntToStr(SysID))
  else if not EmplExist(UserID) then errmess:= MessText(mtkNotEmplExist)
  else with arEmplInfo[UserId] do
    if ((SysID=constIsAuto) and not UserRoleExists(rolTNAManageAuto))
      or ((SysID=constIsMoto) and not UserRoleExists(rolTNAManageMoto))
      or ((SysID=constIsCV) and not UserRoleExists(rolTNAManageCV)) then
      errmess:= MessText(mtkNotRightExists);
  Result:= errmess<>'';
end;
//=============================== �������� ������������� � ��������� �����������
function CheckNotValidManuf(ManufID: Integer; SysID: Integer;
         var Manuf: TManufacturer; var errmess: string): boolean;
begin
  errmess:= '';
  if not CheckTypeSys(SysID) then
    errmess:= MessText(mtkNotFoundTypeSys, IntToStr(SysID))
  else with Cache.FDCA do
    if not Manufacturers.ManufExists(ManufID) then
      errmess:= MessText(mtkNotFoundManuf, IntToStr(ManufID))
    else begin
      Manuf:= Manufacturers[ManufID];
      if not Manuf.CheckIsTypeSys(SysID) then
        errmess:= MessText(mtkNotSysManuf, IntToStr(SysID));
    end;
  Result:= errmess<>'';
end;
//====================== �������� ��������� ���, ������� � ��������� �����������
function CheckNotValidModelLine(ModelLineID: Integer; var SysID: Integer;
         var ModelLine: TModelLine; var errmess: string): boolean;
begin
  errmess:= '';
  if not Cache.FDCA.ModelLines.ModelLineExists(ModelLineID) then
    errmess:= MessText(mtkNotFoundModLine, IntToStr(ModelLineID))
  else begin
    ModelLine:= Cache.FDCA.ModelLines[ModelLineID];
    SysID:= ModelLine.TypeSys;
    if not CheckTypeSys(SysID) then
      errmess:= MessText(mtkNotFoundTypeSys, IntToStr(SysID));
  end;
  Result:= errmess<>'';
end;
//============================= �������� ������, ������� � ��������� �����������
function CheckNotValidModel(ModelID: Integer; var SysID: Integer;
         var Model: TModelAuto; var errmess: string): boolean;
begin
  errmess:= '';
  if not Cache.FDCA.Models.ModelExists(ModelID) then
    errmess:= MessText(mtkNotFoundModel, IntToStr(ModelID))
  else begin
    Model:= Cache.FDCA.Models.GetModel(ModelID);
    SysID:= Model.TypeSys;
    if not CheckTypeSys(SysID) then
      errmess:= MessText(mtkNotFoundTypeSys, IntToStr(SysID));
  end;
  Result:= errmess<>'';
end;

//******************************************************************************
//                    ������� �� ������ � �������� � �.�.
//******************************************************************************
//==========�������� ������ ������ � ���������� ������ �� ����������� ����������
function fnGetClosingDocsOrd(ORDRCODE: string; var Accounts, Invoices: TDocRecArr;
         var Status: integer; id: Integer=-1): string;
const nmProc = 'fnGetClosingDocsOrd'; // ��� ���������/�������
var ibsGB, ibsOrd: TIBSQL;
    ibGB, ibOrd: TIBDatabase;
    Closed, Annulated: boolean;
    i, accCode: integer;
    sid: string;
begin
  if (Cache.GetConstItem(pcClosingDocsFromOrd).IntValue=1) then begin // ���-�� �� Order
    Result:= fnGetClosingDocsFromOrd(ORDRCODE, Accounts, Invoices, Status, id);
    Exit;
  end;

  Result:= '';                                              // �� Grossbee
  sid:= '_GCD'+fnIfStr(id<0, '', '_'+IntToStr(id))+'_'+ORDRCODE;
  ibsOrd:= nil;
  ibOrd:= nil;
  ibsGB:= nil;
  ibsGB:= nil;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  Closed:= true;
  try try
    ibOrd:= cntsORD.GetFreeCnt;
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+sid, -1, tpRead, True);
    ibsOrd.SQL.Text:= 'SELECT ORDRSTATUS, ORDRGBACCCODE'+
                      ' FROM ORDERSREESTR WHERE ORDRCODE='+ORDRCODE;
    ibsOrd.ExecQuery;
    if (ibsOrd.Bof and ibsOrd.Eof) then Exit;

    Status:= ibsOrd.FieldByName('ORDRSTATUS').AsInteger;
    accCode:= ibsOrd.FieldByName('ORDRGBACCCODE').AsInteger;
    ibsOrd.Transaction.Rollback;
    ibsOrd.Close;
    if not (Status in [orstAccepted..orstClosed]) or (accCode<1) then Exit;

    ibGB:= cntsGRB.GetFreeCnt;
    try
      ibsGB:= fnCreateNewIBSQL(ibGB, 'ibsGB_'+sid, -1, tpRead, True);
      ibsGB.SQL.Text:= 'Select d.* from Vlad_CSS_GetAllClosingDocs('+IntToStr(accCode)+
                       ') d where d.PINVANNULKEY="F" and d.PInvDprt>0'; // �������������� ����� ����������
      ibsGB.ExecQuery;
      i:= 0;
      while not ibsGB.Eof do begin
        SetLength(Accounts, i+1);
        SetLength(Invoices, i+1);
        with Accounts[i] do begin // ������� ������ ����� � ���������
          ID          := ibsGB.FieldByName('PInvCode').AsInteger;
          Number      := ibsGB.FieldByName('PInvNumber').AsString;
          Data        := ibsGB.FieldByName('PInvDate').AsDateTime;
          Summa       := ibsGB.FieldByName('PInvSumm').AsFloat;
          CurrencyCode:= ibsGB.FieldByName('PInvCrnc').AsInteger;
          CurrencyName:= Cache.GetCurrName(CurrencyCode, True);
          Processed   := GetBoolGB(ibsGB, 'PINVPROCESSED');
          Commentary  := ibsGB.FieldByName('PINVCOMMENT').AsString;
          DprtID      := ibsGB.FieldByName('PInvDprt').AsInteger;
        end;
        with Invoices[i] do begin // ������� ������ ��������� � ���������
          ID:= ibsGB.FieldByName('INVCODE').AsInteger;
          if ID>0 then begin        // ���������, ������ �� ����
            Number      := ibsGB.FieldByName('INVNUMBER').AsString;
            Data        := ibsGB.FieldByName('INVDATE').AsDateTime;
            Summa       := ibsGB.FieldByName('INVSUMM').AsFloat;
            CurrencyCode:= ibsGB.FieldByName('INVCRNC').AsInteger;
            CurrencyName:= Cache.GetCurrName(CurrencyCode, True);
            DprtID      := ibsGB.FieldByName('INVDPRT').AsInteger;
          end else Number:= '';
          Closed:= Closed and (ID>0);
        end;
        inc(i);
        cntsGRB.TestSuspendException;
        ibsGB.Next;
      end;
    finally
      prFreeIBSQL(ibsGB);
      cntsGRB.SetFreeCnt(ibGB);
    end;

    Annulated:= i<1; // ���� �� ������� ����� - ���������� �����
    if Annulated then Closed:= False;
    i:= 0;
    if (Annulated and (Status<>orstAnnulated)) then i:= orstAnnulated   // ���� ��� ����� ������������, ���������� �����
    else if (Closed and (Status<>orstClosed)) then i:= orstClosed       // ���� ��� ����� �������, ��������� �����
    else if (not Closed and (Status=orstClosed)) then i:= orstAccepted; // ���� �� ��� ����� �������, ��������� �����

    if i>0 then begin
      fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
      if i=orstAnnulated then begin
        ibsOrd.SQL.Text:= 'update ORDERSREESTR set ORDRSTATUS='+IntToStr(i)+','+
          ' ORDRANNULATEREASON=:ORDRANNULATEREASON, ORDRANNULATEDATE="NOW" where ORDRCODE='+ORDRCODE;
        ibsOrd.ParamByName('ORDRANNULATEREASON').AsString:= '��� '+fnGetGBDocName(docAccount, 1, 1)+' �� ������ ������������.';
      end else
        ibsOrd.SQL.Text:= 'update ORDERSREESTR set ORDRSTATUS='+IntToStr(i)+' where ORDRCODE='+ORDRCODE;

      Result:= RepeatExecuteIBSQL(ibsOrd);
      if Result='' then Status:= i;
    end;
  finally
    prFreeIBSQL(ibsOrd);
    cntsOrd.SetFreeCnt(ibOrd);
  end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
//==========�������� ������ ������ � ���������� ������ �� ����������� ����������
function fnGetClosingDocsFromOrd(ORDRCODE: string; var Accounts, Invoices: TDocRecArr;
         var Status: integer; id: Integer=-1): string;
const nmProc = 'fnGetClosingDocsFromOrd'; // ��� ���������/�������
var ibsOrd: TIBSQL;
    ibOrd: TIBDatabase;
    Closed, Annulated: boolean;
    i: integer;
    sid: string;
begin
  Result:= '';
  sid:= '_GCD'+fnIfStr(id<0, '', '_'+IntToStr(id))+'_'+ORDRCODE;
  ibsOrd:= nil;
  ibOrd:= nil;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  Closed:= true;
  try try
    ibOrd:= cntsORD.GetFreeCnt;
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+sid, -1, tpRead, True);
//    ibsOrd.SQL.Text:= 'SELECT ORDRSTATUS FROM ORDERSREESTR WHERE ORDRCODE='+ORDRCODE;
//    ibsOrd.ExecQuery;
//    if (ibsOrd.Bof and ibsOrd.Eof) then Exit;
//    Status:= ibsOrd.FieldByName('ORDRSTATUS').AsInteger;
//    ibsOrd.Close;
    if not (Status in [orstAccepted..orstClosed]) then Exit;
    i:= 0;
    ibsOrd.SQL.Text:= 'select * from OrdersClosingDocs where OCDOrderCode='+
                      ORDRCODE+' order by OCDOrderCode, OCDACCCODE';
    ibsOrd.ExecQuery;
    while not ibsOrd.Eof do begin
      SetLength(Accounts, i+1);
      SetLength(Invoices, i+1);
      with Accounts[i] do begin // ������� ������ ����� � ���������
        ID          := ibsOrd.FieldByName('OCDAccCode').AsInteger;
        Number      := ibsOrd.FieldByName('OCDAccNumber').AsString;
        Data        := ibsOrd.FieldByName('OCDAccDate').AsDateTime;
        Summa       := ibsOrd.FieldByName('OCDAccSumm').AsFloat;
        CurrencyCode:= ibsOrd.FieldByName('OCDAccCrnc').AsInteger;
        CurrencyName:= Cache.GetCurrName(CurrencyCode, True);
        Processed   := GetBoolGB(ibsOrd, 'OCDAccPROCESSED');
        Commentary  := ibsOrd.FieldByName('OCDAccCOMMENT').AsString;
        DprtID      := ibsOrd.FieldByName('OCDAccDprt').AsInteger;
      end;
      with Invoices[i] do begin // ������� ������ ��������� � ���������
        ID:= ibsOrd.FieldByName('OCDInvCODE').AsInteger;
        if ID>0 then begin        // ���������, ������ �� ����
          Number      := ibsOrd.FieldByName('OCDInvNUMBER').AsString;
          Data        := ibsOrd.FieldByName('OCDInvDATE').AsDateTime;
          Summa       := ibsOrd.FieldByName('OCDInvSUMM').AsFloat;
          CurrencyCode:= ibsOrd.FieldByName('OCDInvCRNC').AsInteger;
          CurrencyName:= Cache.GetCurrName(CurrencyCode, True);
          DprtID      := ibsOrd.FieldByName('OCDInvDPRT').AsInteger;
        end else Number:= '';
        Closed:= Closed and (ID>0);
      end;
      inc(i);
      cntsORD.TestSuspendException;
      ibsOrd.Next;
    end;

    Annulated:= i<1; // ���� �� ������� ����� - ���������� �����
    if Annulated then Closed:= False;
    i:= 0;
    if (Annulated and (Status<>orstAnnulated)) then i:= orstAnnulated   // ���� ��� ����� ������������, ���������� �����
    else if (Closed and (Status<>orstClosed)) then i:= orstClosed       // ���� ��� ����� �������, ��������� �����
    else if (not Closed and (Status=orstClosed)) then i:= orstAccepted; // ���� �� ��� ����� �������, ��������� �����

    if i>0 then begin
      fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
      ibsOrd.SQL.Text:= 'update ORDERSREESTR set ORDRSTATUS='+IntToStr(i)+
        fnIfStr(i=orstAnnulated, ', ORDRANNULATEDATE="NOW",'+
          ' ORDRANNULATEREASON="��� '+fnGetGBDocName(docAccount, 1, 1)+' �� ������ ������������."', '')+
        ' where ORDRCODE='+ORDRCODE;
      Result:= RepeatExecuteIBSQL(ibsOrd);
      if Result='' then Status:= i;
    end;
  finally
    prFreeIBSQL(ibsOrd);
    cntsOrd.SetFreeCnt(ibOrd);
  end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
//================================ �������� �������� ����������� ���-��� �������
procedure CheckClosingDocsAll(CompareTime: boolean=True);
const nmProc = 'CheckClosingDocsAll'; // ��� ���������/�������
var tbegin, tend, tt: TDateTime;
    i: Integer;
begin
  if not Cache.flCheckClosingDocs then Exit;
//  tt:= StrToDate('01.01.2017');
  tt:= IncMonth(Date, -2);
           // ����� ��������� ������ ����������� ���������� �������
  tbegin:= Cache.GetConstItem(pcCheckClosingDocsTime).DateValue;
  if (tbegin<1) then tbegin:= IncMonth(Date, -2);
  tend:= Now;

  if CompareTime then begin // �������� ������ ����������� ���������� ������� � ���
    i:= Cache.GetConstItem(pcCheckClosDocsInterval).IntValue;
    if IncMinute(tbegin, i)>tend then Exit; // ���� ���������
  end;

  if (tbegin>tt) then tbegin:= IncMinute(tbegin, -2); // ����� 2 ���.
  CheckClosingDocsByPeriod_new(tbegin, tend);
end;
(*//===================== �������� ����������� ���-��� ������� �� ������ ���������
procedure CheckClosingDocsByPeriod(tbegin, tend: TDateTime; flSaveTime: boolean=True; flalter: boolean=True);
const nmProc = 'CheckClosingDocsByPeriod'; // ��� ���������/�������
var ibGB, ibOrd, ibOrdw: TIBDatabase;
    ibsGB, ibsOrd, ibsOrdw, ibsOrda: TIBSQL;
    LocalStart: TDateTime;
    i, OrdCount, accCount, OrdCode, accCode, invCode, accInd, j, jj, EditCount,
      Status, iOrd: Integer;
    Accounts, Invoices: TDocRecArr;
    lstBlock, lstBlockG, errmess: TStringList;
    sCode, ss, s: String;
    OrdCodes, OrdStats, OrdAccs: Tai;
begin
  ibGB:= nil;
  ibsGB:= nil;
  ibsOrd:= nil;
  ibsOrdw:= nil;
  ibsOrda:= nil;
  ibOrd:= nil;
  ibOrdw:= nil;
  LocalStart:= now();
  OrdCount:= 0;
  EditCount:= 0;
  SetLength(Accounts, 10);
  SetLength(Invoices, 10);
  SetLength(OrdCodes, 1000);
  SetLength(OrdStats, Length(OrdCodes));
  SetLength(OrdAccs, Length(OrdCodes));
  lstBlock:= TStringList.Create;
  errmess:= TStringList.Create;
  lstBlockG:= TStringList.Create;
  try try
    ibGB:= cntsGRB.GetFreeCnt;
    ibOrd:= cntsORD.GetFreeCnt;
    ibOrdw:= cntsORD.GetFreeCnt;
    ibsOrda:= fnCreateNewIBSQL(ibOrd, 'ibsOrda_'+nmProc, -1, tpRead);
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+nmProc, -1, tpRead, True);
    ibsGB:= fnCreateNewIBSQL(ibGB, 'ibsGB_'+nmProc, -1, tpRead, True);

    if ((Date-tbegin)>1) then begin // ����� ���� - ��������� "��������" �����
      ibsOrd.SQL.Text:= 'SELECT min(ORDRGBACCTIME) FROM ORDERSREESTR'+
        ' WHERE ORDRSTATUS>'+IntToStr(orstProcessing)+
        ' and ORDRSTATUS<'+IntToStr(orstAnnulated)+
        ' and ORDRGBACCCODE>0 and ORDRGBACCTIME>"01.01.2016"'+
        ' and ORDRGBACCTIME<:tbegin';
      ibsOrd.ParamByName('tbegin').AsDateTime:= tbegin;
      ibsOrd.ExecQuery;
      if not ibsOrd.Fields[0].IsNull and (ibsOrd.Fields[0].AsDateTime>0) then
        tbegin:= ibsOrd.Fields[0].AsDateTime;
      ibsOrd.Close;
    end;

    if flalter then begin //---------- ���� ������� �� ������-������� � Grossbee
      // �������� ������ ����� ������� � ����������� �� ������ �� Grossbee
      ibsGB.SQL.Text:= 'Select rOrderCode from'+
        ' Vlad_CSS_GetChangedOrderCodes(:tbegin, :tend)'; // order by rOrderCode
      ibsGB.ParamByName('tbegin').AsDateTime:= tbegin;
      ibsGB.ParamByName('tend').AsDateTime  := tend;
      ibsGB.ExecQuery;
      jj:= 0;
      while not ibsGB.Eof do begin
        if High(OrdCodes)<jj then SetLength(OrdCodes, jj+1000);
        OrdCodes[jj]:= ibsGB.FieldByName('rOrderCode').AsInteger; // ��� ������
        inc(jj);
        TestCssStopException;
        ibsGB.Next;
      end;
      ibsGB.Close;
      if Length(OrdCodes)>jj then SetLength(OrdCodes, jj);
      SetLength(OrdStats, Length(OrdCodes));
      SetLength(OrdAccs, Length(OrdCodes));

      ibsOrda.SQL.Text:= 'select ORDRGBACCCODE, ORDRSTATUS FROM ORDERSREESTR WHERE ORDRCODE=:ord';
      ibsOrda.Prepare;

    end else begin  // ���� ������� �� Order �� ������ ORDRGBACCTIME
      ibsOrd.SQL.Text:= 'SELECT ORDRCODE, ORDRGBACCCODE, ORDRSTATUS FROM ORDERSREESTR'+
        ' WHERE ORDRSTATUS>'+IntToStr(orstProcessing)+' and ORDRSTATUS<'+IntToStr(orstAnnulated)+
        ' and ORDRGBACCCODE>0 and ORDRGBACCTIME>"01.01.2016"'+
        ' and ORDRGBACCTIME between :tbegin and :tend';  //  order by ORDRCODE
      ibsOrd.ParamByName('tbegin').AsDateTime:= tbegin;
      ibsOrd.ParamByName('tend').AsDateTime  := tend;
      ibsOrd.ExecQuery;
      jj:= 0;
      while not ibsOrd.Eof do begin
        if High(OrdCodes)<jj then begin
          SetLength(OrdCodes, jj+1000);
          SetLength(OrdStats, Length(OrdCodes));
          SetLength(OrdAccs, Length(OrdCodes));
        end;
        OrdCodes[jj]:= ibsOrd.FieldByName('ORDRCODE').AsInteger; // ��� ������
        OrdStats[jj]:= ibsOrd.FieldByName('ORDRSTATUS').AsInteger; // ������ ������
        OrdAccs[jj]:= ibsOrd.FieldByName('ORDRGBACCCODE').AsInteger; // ��� �����
        inc(jj);
        TestCssStopException;
        ibsOrd.Next;
      end;
      ibsOrd.Close;
      if Length(OrdCodes)>jj then begin
        SetLength(OrdCodes, jj);
        SetLength(OrdStats, Length(OrdCodes));
        SetLength(OrdAccs, Length(OrdCodes));
      end;
    end;
    TestCssStopException;
    OrdCount:= Length(OrdCodes);

    if OrdCount>0 then begin //------------------- ���� ���� ������ ��� ��������
      ibsOrd.SQL.Text:= 'select * from OrdersClosingDocs'+
                        ' where OCDOrderCode=:ord order by OCDOrderCode, OCDACCCODE';
      ibsOrd.Prepare;
      ibsGB.SQL.Text:= 'select d.*, PIAVORDCODE from Vlad_CSS_GetAllClosingDocs(:acc) d'+
        ' left join PAYINVALTER_VLAD on PIAVACCCODE=d.PInvCode'+
        ' where d.PINVANNULKEY="F" and d.PInvDprt>0'; // �������������� ����� ����������
      ibsGB.Prepare;

      jj:= 0;
      for iOrd:= 0 to High(OrdCodes) do begin
        OrdCode:= OrdCodes[iOrd]; // ��� ������

        if flalter then begin
          TestCssStopException;
          ibsOrda.ParamByName('ord').AsInteger:= OrdCode; // ��� 1-�� ����� �� ������
          ibsOrda.ExecQuery;
          accCode:= ibsOrda.FieldByName('ORDRGBACCCODE').AsInteger;
          Status:= ibsOrda.FieldByName('ORDRSTATUS').AsInteger;
          ibsOrda.Close;
        end else begin
          accCode:= OrdAccs[iOrd];
          Status:= OrdStats[iOrd];
        end;

        TestCssStopException;
        ibsGB.ParamByName('acc').AsInteger:= accCode;
        ibsGB.ExecQuery;
        accCount:= 0; //------------------------- ���-�� �� 1 ������ �� Grossbee
        while not ibsGB.Eof do begin
          if High(Accounts)<accCount then begin
            SetLength(Accounts, accCount+10);
            SetLength(Invoices, accCount+10);
          end;
          with Accounts[accCount] do begin // ������� ������ ����� � ���������
            ID          := ibsGB.FieldByName('PInvCode').AsInteger;
            Number      := ibsGB.FieldByName('PInvNumber').AsString;
            Data        := ibsGB.FieldByName('PInvDate').AsDateTime;
            Summa       := ibsGB.FieldByName('PInvSumm').AsFloat;
            CurrencyCode:= ibsGB.FieldByName('PInvCrnc').AsInteger;
            Processed   := GetBoolGB(ibsGB, 'PINVPROCESSED');
            Commentary  := CheckSpecSumbs(ibsGB.FieldByName('PINVCOMMENT').AsString);
            DprtID      := ibsGB.FieldByName('PInvDprt').AsInteger;
          end;
          with Invoices[accCount] do begin // ������� ������ ��������� � ���������
            ID          := ibsGB.FieldByName('INVCODE').AsInteger;
            if (ID>0) then begin
              Number      := ibsGB.FieldByName('INVNUMBER').AsString;
              Data        := ibsGB.FieldByName('INVDATE').AsDateTime;
              Summa       := ibsGB.FieldByName('INVSUMM').AsFloat;
              CurrencyCode:= ibsGB.FieldByName('INVCRNC').AsInteger;
              DprtID      := ibsGB.FieldByName('INVDPRT').AsInteger;
            end;
          end;

          if (ibsGB.FieldByName('PIAVORDCODE').AsInteger<1) then // ������ ��� ������ ���� ������
            lstBlockG.Add('execute procedure Vlad_CSS_SetAlterAccount('+
              ibsGB.FieldByName('PInvCode').AsString+', 0, '+IntToStr(OrdCode)+', 2);');

          Inc(accCount);
          TestCssStopException;
          ibsGB.Next;
        end; //--------------------------- ���-�� �� 1 ������ �� Grossbee
        ibsGB.Close;

        lstBlock.Clear;  // ������ ��������� �� 1 ������ ��� execute block
        ibsOrd.Close;
        ibsOrd.ParamByName('ord').AsInteger:= OrdCode;
        ibsOrd.ExecQuery;
        while not ibsOrd.Eof do begin //---- ��������� ���-�� �� 1 ������ �� Order
          accCode:= ibsOrd.FieldByName('OCDAccCode').AsInteger;
          invCode:= ibsOrd.FieldByName('OCDInvCODE').AsInteger;
          sCode:= ' where OCDCODE='+ibsOrd.FieldByName('OCDCODE').AsString+';';
          accInd:= -1;
          if invCode>0 then for i:= 0 to accCount-1 do // ������� ���� ������ � ����� ���������
            if (Accounts[i].ID=accCode) and (Invoices[i].ID=invCode) then begin
              accInd:= i;
              break;
            end;
          if (accInd<0) then for i:= 0 to accCount-1 do // ����� ���� ������ ��� ���������
            if (Accounts[i].ID=accCode) and (Invoices[i].ID=0) then begin
              accInd:= i;
              break;
            end;

          if (accInd<0) then // ���� ����� (� ���������/��� ���������) � Grossbee ���
            lstBlock.Add('delete from OrdersClosingDocs'+sCode) // - ������� ������

          else begin    // ���� ������ ����� - ����������
            ss:= ''; // ������ ��������� �� 1 �����
            with Accounts[accInd] do begin
              if (Number<>ibsOrd.FieldByName('OCDAccNumber').AsString) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccNumber='+fnStrQuoted(Number);
              if (Data<>ibsOrd.FieldByName('OCDAccDate').AsDateTime) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccDate='+
                     fnStrQuoted(FormatDateTime(cDateTimeFormatY4S, Data));
              if fnNotZero(Summa-ibsOrd.FieldByName('OCDAccSumm').AsFloat) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccSumm='+fnSetDecSep(FloatToStr(Summa), 3);
              if (CurrencyCode<>ibsOrd.FieldByName('OCDAccCrnc').AsInteger) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccCrnc='+IntToStr(CurrencyCode);
              if (Processed<>GetBoolGB(ibsOrd, 'OCDAccPROCESSED')) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccPROCESSED='+
                     fnStrQuoted(fnIfStr(Processed, 'T', 'F'));
              if (DprtID<>ibsOrd.FieldByName('OCDAccDprt').AsInteger) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccDprt='+IntToStr(DprtID);
              if (Commentary<>CheckSpecSumbs(ibsOrd.FieldByName('OCDAccCOMMENT').AsString)) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccCOMMENT='+fnStrQuoted(Commentary);
              ID:= 0; // ���� �� Grossbee �������� - �������� ���
            end;

            with Invoices[accInd] do if (ID>0) then begin // ���� ���� ��������� - ���������
              if (ID<>invCode) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCODE='+IntToStr(ID);
              if (Number<>ibsOrd.FieldByName('OCDInvNUMBER').AsString) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvNUMBER='+fnStrQuoted(Number);
              if (Data<>ibsOrd.FieldByName('OCDInvDATE').AsDateTime) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDATE='+
                     fnStrQuoted(FormatDateTime(cDateTimeFormatY4S, Data));
              if fnNotZero(Summa-ibsOrd.FieldByName('OCDInvSUMM').AsFloat) then
                 ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvSUMM='+fnSetDecSep(FloatToStr(Summa), 3);
              if (CurrencyCode<>ibsOrd.FieldByName('OCDInvCRNC').AsInteger) then
                 ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCRNC='+IntToStr(CurrencyCode);
              if (DprtID<>ibsOrd.FieldByName('OCDInvDPRT').AsInteger) then
                 ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDPRT='+IntToStr(DprtID);

            end else if (invCode>0) then begin // ���� ��� � ���� ��������� � Order - �������
              ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCODE=0';
              if (ibsOrd.FieldByName('OCDInvNUMBER').AsString<>'') then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvNUMBER=""';
              if not ibsOrd.FieldByName('OCDInvDATE').IsNull then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDATE=null';
              if fnNotZero(ibsOrd.FieldByName('OCDInvSUMM').AsFloat) then
                 ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvSUMM=0';
              if (ibsOrd.FieldByName('OCDInvCRNC').AsInteger>0) then
                 ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCRNC=0';
              if (ibsOrd.FieldByName('OCDInvDPRT').AsInteger>0) then
                 ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDPRT=0';
            end;
            if (ss<>'') then
              lstBlock.Add(' if (exists(select * from ordersreestr where ordrcode='+
                IntToStr(OrdCode)+')) then update OrdersClosingDocs set '+ss+sCode);
          end;
          TestCssStopException;
          ibsOrd.Next;
        end; //--------------------- ���-�� �� 1 ������ �� Order
        ibsOrd.Close;
{
        if (accCount<1) and (Status<orstAnnulated) then // ���� �� ������� ����� - ���������� �����
          lstBlock.Add('update ORDERSREESTR set ORDRSTATUS='+IntToStr(orstAnnulated)+','+
            ' ORDRANNULATEREASON="��� ����� �� ������ ������������.",'+
            ' ORDRANNULATEDATE="NOW" where ORDRCODE='+IntToStr(OrdCode)+';')

         else if (accCount>0) and (Status=orstAnnulated) then // ���� ������� ����� - ��������������� �����
          lstBlock.Add('update ORDERSREESTR set ORDRSTATUS='+IntToStr(orstClosed)+','+
            ' ORDRANNULATEREASON="", ORDRANNULATEDATE=null where ORDRCODE='+IntToStr(OrdCode)+';');
}
        for i:= 0 to accCount-1 do if Accounts[i].ID>0 then begin // ���� �����, ���.�� �������
          ss:= ' insert into OrdersClosingDocs (OCDOrderCode, OCDAccCode, OCDAccNumber,'+
            ' OCDAccDate, OCDAccCrnc, OCDAccSumm, OCDAccPROCESSED, OCDAccDprt, OCDAccCOMMENT'+
            fnIfStr(Invoices[i].ID<1, '', ', OCDInvCODE, OCDInvNUMBER,'+
              ' OCDInvDPRT, OCDInvCRNC, OCDInvSUMM, OCDInvDATE')+
            ') values ('+IntToStr(OrdCode)+', ';

          with Accounts[i] do ss:= ss+IntToStr(ID)+', '+fnStrQuoted(Number)+', '+
            fnStrQuoted(FormatDateTime(cDateTimeFormatY4S, Data))+', '+
            IntToStr(CurrencyCode)+', '+fnSetDecSep(FloatToStr(Summa), 3)+', '+
            fnStrQuoted(fnIfStr(Processed, 'T', 'F'))+', '+
            IntToStr(DprtID)+', '+fnStrQuoted(Commentary);

          if (Invoices[i].ID>0) then with Invoices[i] do ss:= ss+', '+IntToStr(ID)+', '+
            fnStrQuoted(Number)+', '+IntToStr(DprtID)+', '+IntToStr(CurrencyCode)+', '+
            fnSetDecSep(FloatToStr(Summa), 3)+', '+
            fnStrQuoted(FormatDateTime(cDateTimeFormatY4S, Data));
          ss:= ss+');';
          lstBlock.Add(' if (exists(select * from ordersreestr where ordrcode='+IntToStr(OrdCode)+')) then');
          lstBlock.Add(ss);
        end;
        TestCssStopException;

        if (lstBlock.Count>0) then try  // ������ ��������� � ������� OrdersClosingDocs
          if not Assigned(ibsOrdw) then  // ������� ������ ��� �������������
            ibsOrdw:= fnCreateNewIBSQL(ibOrdw, 'ibsOrdw_'+nmProc, -1, tpWrite); // ��� ������
          lstBlock.Insert(0, 'execute block as begin ');
          lstBlock.Add(' end');
          with ibsOrdw.Transaction do if not InTransaction then StartTransaction;
          ibsOrdw.SQL.Clear;
          ibsOrdw.SQL.AddStrings(lstBlock);
          ibsOrdw.ExecQuery;
          ibsOrdw.Transaction.Commit;
          Inc(EditCount);
        except
          on E: Exception do begin
            ibsOrdw.Transaction.Rollback;
            flSaveTime:= False;
            prMessageLOGS(nmProc+': execute block '+#10+E.Message, fLogCache, false);
            if flTestDocs then for j:= 0 to lstBlock.Count-1 do errmess.Add(lstBlock[j]);
          end;
        end;
        if Assigned(ibsOrdw) then ibsOrdw.Close;

        if (jj>100) then begin // ����� �������� � ���
          jj:= 0;
          if flTestDocs then prMessageLOGS(nmProc+': '+IntToStr(iOrd+1)+
            ' ���., ��� - '+IntToStr(EditCount), fLogDebug, false);
          Application.ProcessMessages;
        end else inc(jj);

        TestCssStopException;
      end; // for iOrd

      jj:= lstBlockG.Count;
      if lstBlockG.Count>0 then fnSetTransParams(ibsGB.Transaction, tpWrite, True);
      ibsGB.SQL.Clear;
      for i:= lstBlockG.Count-1 downto 0 do begin
        ibsGB.SQL.Add(lstBlockG[i]);
        lstBlockG.Delete(i);
        if (i=0) or (ibsGB.SQL.Count>99) then begin
          try  // ������ ��������� � ������� PAYINVALTER_VLAD
            if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
            ibsGB.SQL.Insert(0, 'execute block as begin ');
            ibsGB.SQL.Add(' end');
            ibsGB.ExecQuery;
            ibsGB.Transaction.Commit;
          except
            on E: Exception do begin
              ibsGB.Transaction.Rollback;
              flSaveTime:= False;
              prMessageLOGS(nmProc+': execute block '+#10+E.Message, fLogCache, false);
              if flTestDocs then for j:= 0 to lstBlockG.Count-1 do errmess.Add(lstBlockG[j]);
            end;
          end;
          ibsGB.SQL.Clear;
        end; // if (i=0) or
        TestCssStopException;
      end; // for i:= lstBlockG.Count
      if flTestDocs then
        prMessageLOGS(nmProc+': ����� ���. � Gr - '+IntToStr(jj), fLogDebug, false);

    end else  // if OrdCount>0
    if flTestDocs then
      prMessageLOGS(nmProc+': '+MessText(mtkNotFoundOrders)+' ��� ������ ���-���', fLogDebug, false);
  except
    on E: Exception do begin
      flSaveTime:= False;
      if flTestDocs then prMessageLOGS(nmProc+': '+E.Message, fLogDebug, false);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  finally
    prFreeIBSQL(ibsOrd);
    cntsOrd.SetFreeCnt(ibOrd);
    prFreeIBSQL(ibsOrdw);
    prFreeIBSQL(ibsOrda);
    cntsOrd.SetFreeCnt(ibOrdw);
    prFreeIBSQL(ibsGB);
    cntsGRB.SetFreeCnt(ibGB);
    SetLength(Accounts, 0);
    SetLength(Invoices, 0);
    SetLength(OrdCodes, 0);
    SetLength(OrdStats, 0);
    SetLength(OrdAccs, 0);
    prFree(lstBlock);
    prFree(lstBlockG);
    if flSaveTime then begin // ����� ����� ������ ����������� ����������
      i:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
      s:= FormatDateTime(cDateTimeFormatY4S, tend);
      Cache.SaveNewConstValue(pcCheckClosingDocsTime, i, s);
    end;
    prMessageLOGS(nmProc+': '+IntToStr(OrdCount)+
      ' ���, '+IntToStr(EditCount)+' ��� - '+GetLogTimeStr(LocalStart), fLogCache, false);
    if flTestDocs then                  // ���� ���� ������ - ����� � ���
      for j:= 0 to errmess.Count-1 do prMessageLOGS(errmess[j], fLogDebug, false);
    prFree(errmess);
  end;
  TestCssStopException;
end; *)
//-----------------------------------------------------
type TCheckData = class
  OrderID: Integer;
  OrdCodes:  TIntegerList;   // ���� ������� � �����
  Account, Invoice: TDocRec; // ��������� �����, ���������
  constructor Create;
  destructor Destroy; override;
end;
constructor TCheckData.Create;
begin
  inherited Create;
  OrdCodes:= TIntegerList.Create;
end;
destructor TCheckData.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(OrdCodes);
  inherited Destroy;
end;
//===================== �������� ����������� ���-��� ������� �� ������ ���������
procedure CheckClosingDocsByPeriod_new(tbegin, tend: TDateTime; flSaveTime: boolean=True);
const nmProc = 'CheckClosingDocsByPeriod_new'; // ��� ���������/�������
var ibGB, ibOrd: TIBDatabase;
    ibsGB, ibsOrd: TIBSQL;
    LocalStart: TDateTime;
    i, AccCount, EditCount, AddCount, DelCount, invCode, accInd, j, jj, jd: Integer;
    lstBlock, errmess: TStringList;
    sCode, ss, s: String;
    olData: TObjectList;
    olTmp: TList;
    cd, cd1: TCheckData;
  //-------------------------------------------------------
  function FindAccOrdData(acc, ord: Integer): Integer;
  // ����������: -2 - �� �����, -1 - ����� � ���� �������,
  // >-1 - ������ �������� � ����������� �����
  var ii: Integer;
  begin
    result:= -2;
    for ii:= 0 to olData.Count-1 do begin
      cd:= TCheckData(olData[ii]);
      if (cd.Account.ID<>acc) then Continue;
      result:= ii;
      if (ord<1) then exit;
      if (cd.OrdCodes.IndexOf(ord)<0) then Continue;
      result:= -1;
      exit;
    end;
  end;
  //-------------------------------------------------------
begin
  ibGB:= nil;
  ibsGB:= nil;
  ibOrd:= nil;
  ibsOrd:= nil;
  LocalStart:= now();
  lstBlock:= TStringList.Create; // ������ ��������� ��� execute block
  errmess:= TStringList.Create;
  AccCount:= 0;
  EditCount:= 0;
  AddCount:= 0;
  DelCount:= 0;
  olTmp:= TList.Create;  // ���.������ ����� ������������ ������ � ������ �������
  olData:= TObjectList.Create; // ������ ������ � �������������� ������ �������
  try try
    ibGB:= cntsGRB.GetFreeCnt;
    ibOrd:= cntsORD.GetFreeCnt;
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+nmProc, -1, tpRead);
    ibsGB:= fnCreateNewIBSQL(ibGB, 'ibsGB_'+nmProc, -1, tpRead);
                                      // ����� ���� - ��������� "��������" �����  ???
    if not SameDate(Date, tbegin) {((Date-tbegin)>1)} then begin
      if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
      ibsOrd.SQL.Text:= 'SELECT min(ORDRGBACCTIME) FROM ORDERSREESTR'+
        ' WHERE ORDRSTATUS>'+IntToStr(orstProcessing)+
        ' and ORDRSTATUS<'+IntToStr(orstClosed)+' and ORDRGBACCCODE>0'+ // orstAnnulated
        ' and ORDRGBACCTIME between :dd and :tbegin';
      ibsOrd.ParamByName('dd').AsDateTime:= Date-30; // �� �����
      ibsOrd.ParamByName('tbegin').AsDateTime:= tbegin;
      ibsOrd.ExecQuery;
      if not ibsOrd.Fields[0].IsNull and (ibsOrd.Fields[0].AsDateTime>0) then
        tbegin:= ibsOrd.Fields[0].AsDateTime;
      ibsOrd.Close;
      ibsOrd.SQL.Clear;
    end;
    TestCssStopException;

    if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
    ibsGB.SQL.Text:= 'select piavAccCode PInvCode, piavOrdCode, PInvNumber, PInvDate,'+
      '  PInvCrncCode, PInvSupplyDprtCode, PInvSumm, PINVPROCESSED, PINVCLIENTCOMMENT,'+
      '  INVCCODE, INVCNUMBER, INVCDATE, INVCSUMM, INVCCRNCCODE, INVCSUPPLYDPRTCODE,'+
      '  PINVANNULKEY, pinvcombinedcode from (select piavAccCode, piavOrdCode from'+
      '  (select p1.piavAccCode, p1.piavOrdCode from payinvalter_vlad p1'+ // ����� CSS
      '    where p1.piavLastTime between :tbegin and :tend and p1.piavAccCode is not null'+
      '  union select prc.pinvcode piavAccCode, p11.piavOrdCode from payinvalter_vlad p11'+
      '    left join payinvoicereestr pr on pr.pinvcode = p11.piavAccCode'+
      '    left join payinvoicereestr prc on prc.pinvcode = pr.pinvcombinedcode'+
      '    where p11.piavLastTime between :tbegin and :tend'+ // ������������ �����
      '      and prc.pinvcode is not null and pr.pinvannulkey = "T"'+
      '  union select p2.piavAccCode, p2.piavOrdCode from invoicealter_vlad'+
      '    left join INVOICEREESTR on INVCCODE=iavInvCode'+   // ���������
      '    left join SUBCONTRACT on SbCnCode=INVCSUBCONTRACT and SbCnDocmType=99'+
      '    left join payinvalter_vlad p2 on p2.piavAccCode=SbCnDocmCode'+
      '    where iavLastTime between :tbegin and :tend and p2.piavAccCode is not null)'+
      '  group by piavAccCode, piavOrdCode order by piavAccCode, piavOrdCode) s'+
      '  left join PayInvoiceReestr r on r.PInvCode=s.piavAccCode'+
      '  left join SUBCONTRACT sb on sb.SbCnDocmCode=r.PInvCode and sb.SbCnDocmType=99'+
      '  left join INVOICEREESTR i on i.INVCSUBCONTRACT=sb.SbCnCode'+
      '  where (PInvCode>0) and ((piavOrdCode is not null and piavOrdCode>0)'+
      '    or (pinvwebcomment is not null and pinvwebcomment<>""))';
    ibsGB.ParamByName('tbegin').AsDateTime:= tbegin;
    ibsGB.ParamByName('tend').AsDateTime  := tend;
    ibsGB.ExecQuery;
    while not ibsGB.Eof do begin
      invCode:= ibsGB.FieldByName('PInvCode').AsInteger;
      jd:= ibsGB.FieldByName('pinvcombinedcode').AsInteger;
      jj:= ibsGB.FieldByName('piavOrdCode').AsInteger;
      if GetBoolGB(ibsGB, 'PINVANNULKEY') then begin  // ���� ���� �����������
        // ���� ���� ������������ ���� - ���������� � ������ ������ ���������������
        if (jd>0) then begin
          cd:= TCheckData.Create;
          cd.Account.ID:= jd;
          if (jj>0) then cd.OrdCodes.Add(jj);
          ibsOrd.Close;
          if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
          if (ibsOrd.SQL.Text='') then
            ibsOrd.SQL.Text:= 'select OCDOrderCode from OrdersClosingDocs where OCDAccCode=:acc';
          ibsOrd.ParamByName('acc').AsInteger:= invCode;
          ibsOrd.ExecQuery;
          while not ibsOrd.Eof do begin //------ ������ �� 1 ��������������� �����
            i:= ibsOrd.FieldByName('OCDOrderCode').AsInteger;
            if (i>0) then cd.OrdCodes.Add(i); // ��������� ��� ������ � �����
            TestCssStopException;
            ibsOrd.Next;
          end; //  while not ibsOrd.Eof
          olTmp.Add(cd);
        end; // if (jd>0)
        ibsOrd.Close;
                                                     // ������� ������ �� �����
        lstBlock.Add('delete from OrdersClosingDocs where OCDAccCode='+IntToStr(invCode)+';');
        while not ibsGB.Eof and (invCode=ibsGB.FieldByName('PInvCode').AsInteger) do
          ibsGB.Next;
        Inc(AccCount);
        Inc(DelCount);
        Continue;
      end;

      accInd:= FindAccOrdData(invCode, jj);
      if (accInd=-2) then begin //-------------------- �� �����
        cd:= TCheckData.Create;
        if (jj>0) then cd.OrdCodes.Add(jj); // ��������� ��� ������ � �����
        with cd.Account do begin // ������� ������ ����� � ���������
          ID          := invCode;
          Number      := ibsGB.FieldByName('PInvNumber').AsString;
          Data        := ibsGB.FieldByName('PInvDate').AsDateTime;
          Summa       := ibsGB.FieldByName('PInvSumm').AsFloat;
          CurrencyCode:= ibsGB.FieldByName('PInvCrncCode').AsInteger;
          Processed   := GetBoolGB(ibsGB, 'PINVPROCESSED');
          Commentary  := CheckSpecSumbs(fnReplaceQuotedForWeb(ibsGB.FieldByName('PINVCLIENTCOMMENT').AsString));
          DprtID      := ibsGB.FieldByName('PInvSupplyDprtCode').AsInteger;
        end;
        with cd.Invoice do begin // ������� ������ ��������� � ���������
          ID            := ibsGB.FieldByName('INVCCODE').AsInteger;
          if (ID>0) then begin
            Number      := ibsGB.FieldByName('INVCNUMBER').AsString;
            Data        := ibsGB.FieldByName('INVCDATE').AsDateTime;
            Summa       := ibsGB.FieldByName('INVCSUMM').AsFloat;
            CurrencyCode:= ibsGB.FieldByName('INVCCRNCCODE').AsInteger;
            DprtID      := ibsGB.FieldByName('INVCSUPPLYDPRTCODE').AsInteger;
          end;
        end;
        olData.Add(cd); // ��������� ����� ������� � ����������� �����

      end else if (accInd>-1) and (jj>0) then // ����� ������� � ����������� �����
        cd.OrdCodes.Add(jj); // ��������� ��� ������ � �����

      Inc(AccCount);
      TestCssStopException;
      ibsGB.Next;
    end;
    ibsGB.Close;
    ibsGB.SQL.Clear;
    //------------------------------ ������������ ���.������ ������������ ������
    s:= '';
    for i:= olTmp.Count-1 downto 0 do begin
      cd1:= TCheckData(olTmp[i]);
      jj:= FindAccOrdData(cd1.Account.ID, 0); // ���� ������������ �����

      if (jj<0) then begin // �� ����� ���� - ��������� ��������� �����
        if (ibsGB.SQL.Text='') then begin
          if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
          ibsGB.SQL.Text:= 'select PInvNumber, PInvDate, PInvCrncCode,'+
            '  PInvSupplyDprtCode, PInvSumm, PINVPROCESSED, PINVCLIENTCOMMENT,'+
            '  PINVANNULKEY, INVCCODE, INVCNUMBER, INVCDATE, INVCSUMM,'+
            '  INVCCRNCCODE, INVCSUPPLYDPRTCODE from PayInvoiceReestr'+
            '  left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
            '  left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode where PInvCode=:acc';
        end;
        ibsGB.ParamByName('acc').AsInteger:= cd1.Account.ID;
        ibsGB.ExecQuery;
        if not (ibsGB.Eof and ibsGB.Bof) then begin
          with cd1.Account do begin // ������� ������ ����� � ���������
            Number      := ibsGB.FieldByName('PInvNumber').AsString;
            Data        := ibsGB.FieldByName('PInvDate').AsDateTime;
            Summa       := ibsGB.FieldByName('PInvSumm').AsFloat;
            CurrencyCode:= ibsGB.FieldByName('PInvCrncCode').AsInteger;
            Processed   := GetBoolGB(ibsGB, 'PINVPROCESSED');
            Commentary  := CheckSpecSumbs(fnReplaceQuotedForWeb(ibsGB.FieldByName('PINVCLIENTCOMMENT').AsString));
            DprtID      := ibsGB.FieldByName('PInvSupplyDprtCode').AsInteger;
          end;
          with cd1.Invoice do begin // ������� ������ ��������� � ���������
            ID            := ibsGB.FieldByName('INVCCODE').AsInteger;
            if (ID>0) then begin
              Number      := ibsGB.FieldByName('INVCNUMBER').AsString;
              Data        := ibsGB.FieldByName('INVCDATE').AsDateTime;
              Summa       := ibsGB.FieldByName('INVCSUMM').AsFloat;
              CurrencyCode:= ibsGB.FieldByName('INVCCRNCCODE').AsInteger;
              DprtID      := ibsGB.FieldByName('INVCSUPPLYDPRTCODE').AsInteger;
            end;
          end;
          olData.Add(cd1); // ��������� ������� � ����� ������
          Inc(AccCount);
        end; // else prFree(cd);
        ibsGB.Close;

      end else                    // ����� - ��������� ���� �������
        for jj:= 0 to cd1.OrdCodes.Count-1 do cd.OrdCodes.Add(cd1.OrdCodes[jj]);

    end; // for i:= olTmp.Count-1 downto 0
//------------------------------------------------- ���� ���� ����� ��� ��������
    s:= '';
    ss:= '';
    if (olData.Count>0) then begin
      ibsOrd.Close;
      if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
      ibsOrd.SQL.Text:= 'select d.*, iif(ordrcode is null, '+IntToStr(orstNoDefinition)+
        ', ORDRSTATUS) STATUS from OrdersClosingDocs d'+
        ' left join ordersreestr on ordrcode=d.OCDOrderCode where d.OCDAccCode=:acc';
      for accInd:= 0 to olData.Count-1 do begin
        cd:= TCheckData(olData[accInd]);
        jj:= 0;
        jd:= 0;
        ibsOrd.Close;
        ibsOrd.ParamByName('acc').AsInteger:= cd.Account.ID;
        ibsOrd.ExecQuery;
        while not ibsOrd.Eof do begin //------------ ��������� ������ �� 1 �����
          i:= ibsOrd.FieldByName('STATUS').AsInteger;

          if (i=orstNoDefinition) then j:= -1
          else j:= cd.OrdCodes.IndexOf(ibsOrd.FieldByName('OCDOrderCode').AsInteger);
          if (j>-1) then cd.OrdCodes.Delete(j); // ������� ��� ������������ ������

          sCode:= ' where OCDCODE='+ibsOrd.FieldByName('OCDCODE').AsString+';';

          if (i=orstNoDefinition) or (i=orstAnnulated) then begin // ���� ������ ��� ��� �����������
            lstBlock.Add('delete from OrdersClosingDocs'+sCode); // ������� ������
            Inc(jd);

          end else begin // ��������� ���������
            invCode:= ibsOrd.FieldByName('OCDInvCODE').AsInteger;
            ss:= ''; // ������ ���������
            with cd.Account do begin
              if (Number<>ibsOrd.FieldByName('OCDAccNumber').AsString) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccNumber='+fnStrQuoted(Number);
              if (Data<>ibsOrd.FieldByName('OCDAccDate').AsDateTime) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccDate='+
                     fnStrQuoted(FormatDateTime(cDateFormatY4, Data));
              if fnNotZero(Summa-ibsOrd.FieldByName('OCDAccSumm').AsFloat) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccSumm='+fnSetDecSep(FloatToStr(Summa), 3);
              if (CurrencyCode<>ibsOrd.FieldByName('OCDAccCrnc').AsInteger) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccCrnc='+IntToStr(CurrencyCode);
              if (Processed<>GetBoolGB(ibsOrd, 'OCDAccPROCESSED')) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccPROCESSED='+
                     fnStrQuoted(fnIfStr(Processed, 'T', 'F'));
              if (DprtID<>ibsOrd.FieldByName('OCDAccDprt').AsInteger) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccDprt='+IntToStr(DprtID);
              if (Commentary<>CheckSpecSumbs(ibsOrd.FieldByName('OCDAccCOMMENT').AsString)) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDAccCOMMENT='+fnStrQuoted(Commentary);
            end; // with cd.Account
            with cd.Invoice do if (ID>0) then begin // ���� ���� ��������� - ���������
              if (ID<>invCode) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCODE='+IntToStr(ID);
              if (Number<>ibsOrd.FieldByName('OCDInvNUMBER').AsString) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvNUMBER='+fnStrQuoted(Number);
              if (Data<>ibsOrd.FieldByName('OCDInvDATE').AsDateTime) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDATE='+
                     fnStrQuoted(FormatDateTime(cDateFormatY4, Data));
              if fnNotZero(Summa-ibsOrd.FieldByName('OCDInvSUMM').AsFloat) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvSUMM='+fnSetDecSep(FloatToStr(Summa), 3);
              if (CurrencyCode<>ibsOrd.FieldByName('OCDInvCRNC').AsInteger) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCRNC='+IntToStr(CurrencyCode);
              if (DprtID<>ibsOrd.FieldByName('OCDInvDPRT').AsInteger) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDPRT='+IntToStr(DprtID);
            end else if (invCode>0) then begin // ���� ��� � ���� ��������� � Order - �������
              ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCODE=0';
              if (ibsOrd.FieldByName('OCDInvNUMBER').AsString<>'') then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvNUMBER=""';
              if not ibsOrd.FieldByName('OCDInvDATE').IsNull then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDATE=null';
              if fnNotZero(ibsOrd.FieldByName('OCDInvSUMM').AsFloat) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvSUMM=0';
              if (ibsOrd.FieldByName('OCDInvCRNC').AsInteger>0) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvCRNC=0';
              if (ibsOrd.FieldByName('OCDInvDPRT').AsInteger>0) then
                ss:= ss+fnIfStr(ss='', '', ', ')+'OCDInvDPRT=0';
            end; // with cd.Invoice
            if (ss<>'') then begin
              lstBlock.Add(' update OrdersClosingDocs set '+ss+sCode);
              Inc(jj);
            end;
          end; // ��������� ���������

          TestCssStopException;
          ibsOrd.Next;
        end; //  while not ibsOrd.Eof
        ibsOrd.Close;
        if (jj>0) then Inc(EditCount);
        if (jd>0) then Inc(DelCount);

        for j:= 0 to cd.OrdCodes.Count-1 do begin //------------ ��������� �����
          with cd.Account do begin
            s:= 'OCDOrderCode, OCDAccCode, OCDAccNumber, OCDAccDate, OCDAccCrnc,'+
                ' OCDAccDprt, OCDAccSumm, OCDAccPROCESSED, OCDAccCOMMENT';
            ss:= IntToStr(cd.OrdCodes[j])+', '+IntToStr(ID)+', "'+Number+'", "'+
                 FormatDateTime(cDateFormatY4, Data)+'", '+IntToStr(CurrencyCode)+
                 ', '+IntToStr(DprtID)+', '+fnSetDecSep(FloatToStr(Summa), 3)+', "'+
                 fnIfStr(Processed, 'T', 'F')+'", "'+Commentary+'"';
          end; // with cd.Account
          with cd.Invoice do if (ID>0) then begin
            s:= s+', OCDInvCODE, OCDInvDPRT, OCDInvNUMBER, OCDInvDATE, OCDInvSUMM, OCDInvCRNC';
            ss:= ss+', '+IntToStr(ID)+', '+IntToStr(DprtID)+', "'+Number+'", "'+
                 FormatDateTime(cDateFormatY4, Data)+'", '+
                 fnSetDecSep(FloatToStr(Summa), 3)+', '+IntToStr(CurrencyCode);
          end; //  with cd.Invoice
          lstBlock.Add(' if(exists(select * from ordersreestr'+
            ' where ordrcode='+IntToStr(cd.OrdCodes[j])+')) then'+
            '  update or insert into OrdersClosingDocs ('+s+') values ('+ss+')'+
            ' matching (OCDOrderCode, OCDAccCode);');
          Inc(AddCount);
        end; // for j:= 0 to cd.OrdCodes.Count-1
      end; // accInd:= 0 to olData.Count-1
    end;  // if (olData.Count>0)

    if (lstBlock.Count>0) then begin
      ibsOrd.SQL.Clear;
      fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
      for i:= lstBlock.Count-1 downto 0 do begin
        ibsOrd.SQL.Add(lstBlock[i]);
        lstBlock.Delete(i);
        if (i=0) or (ibsOrd.SQL.Count>49) then begin
          try  // ������ ��������� � �������
            if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
            ibsOrd.SQL.Insert(0, 'execute block as begin ');
            ibsOrd.SQL.Add(' end');
            ibsOrd.ExecQuery;
            ibsOrd.Transaction.Commit;
          except
            on E: Exception do begin
              ibsOrd.Transaction.Rollback;
              flSaveTime:= False;
              prMessageLOGS(nmProc+': execute block '#10+E.Message, fLogCache, false);
              if flTestDocs then
                for j:= 0 to ibsOrd.SQL.Count-1 do errmess.Add(ibsOrd.SQL[j]);
            end;
          end;
          ibsOrd.SQL.Clear;
        end; // if (i=0) or
        TestCssStopException;
      end; // for i:= lstBlock.Count-1 downto 0
    end; // if (lstBlock.Count>0)

  except
    on E: Exception do begin
      flSaveTime:= False;
      if flTestDocs then prMessageLOGS(nmProc+': '+E.Message, fLogDebug, false);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  finally
    prFreeIBSQL(ibsOrd);
    cntsOrd.SetFreeCnt(ibOrd);
    prFreeIBSQL(ibsGB);
    cntsGRB.SetFreeCnt(ibGB);
    prFree(lstBlock);
    prFree(olTmp);
    prFree(olData);
    if flSaveTime then begin // ����� ����� ������ ����������� ����������
      i:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
      s:= FormatDateTime(cDateTimeFormatY4S, tend);
      Cache.SaveNewConstValue(pcCheckClosingDocsTime, i, s);
    end;
    prMessageLOGS(nmProc+': '+IntToStr(AccCount)+' acc '+
      fnIfStr(AddCount>0, IntToStr(AddCount)+' add ', '')+
      fnIfStr(DelCount>0, IntToStr(DelCount)+' del ', '')+
      fnIfStr(EditCount>0, IntToStr(EditCount)+' edit ', '')+
      ' - '+GetLogTimeStr(LocalStart), fLogCache, false);
    if flTestDocs then begin
      if (AccCount>0) then s:= ': ��������� - '+IntToStr(AccCount)
      else s:= ': �� ������� ����� ��� ������ ���-���';
      prMessageLOGS(nmProc+s, fLogDebug, false);             // ���� ���� ������
      for j:= 0 to errmess.Count-1 do prMessageLOGS(errmess[j], fLogDebug, false);
    end;
    prFree(errmess);
  end;
  TestCssStopException;
end;
(*
//======== ��������� ������� ����.���-��� � ���������� ���� ������� ����.���-���
procedure FillOrdersClosingDocs(FirstRecs: Integer=0);
const nmProc = 'FillOrdersClosingDocs'; // ��� ���������/�������
var ibGB, ibOrd, ibGBr, ibOrdr: TIBDatabase;
    ibsGB, ibsOrd, ibsGBr, ibsOrdr: TIBSQL;
    iDocs, iAcc, j, iCount, iAnul: Integer;
    flInv, flAnul: Boolean;
    lstBlock: TStringList;
    LocalStart, dLast, dAnul: TDateTime;
    sInv1, sInv2: String;
begin
  ibsGB:= nil;
  ibsOrd:= nil;
  ibsGBr:= nil;
  ibsOrdr:= nil;
//  ibGB:= nil;
//  ibOrd:= nil;
  lstBlock:= TStringList.Create;
  iDocs:= 0; // ������� ����� ���-���
  iAcc:= 0; // ������� ������, � ���. ���������� ��� ������
  iAnul:= 0; // ������� �������������� �������
  LocalStart:= now();
  try
    ibOrdr:= cntsORD.GetFreeCnt;
    try
      ibsOrdr:= fnCreateNewIBSQL(ibOrdr, 'ibsOrdr_'+nmProc, -1, tpRead, True);
      ibsOrdr.SQL.Text:= 'SELECT'+fnIfStr(FirstRecs>0, ' first '+IntToStr(FirstRecs), '')+
        ' ORDRCODE, ORDRGBACCCODE, ORDRGBACCTIME FROM ORDERSREESTR'+
        ' left join OrdersClosingDocs on OCDOrderCode=ORDRCODE'+
        ' WHERE ORDRSTATUS>'+IntToStr(orstProcessing)+' and ORDRSTATUS<'+IntToStr(orstAnnulated)+
        ' and ORDRGBACCCODE>0 and ORDRGBACCTIME>"01.01.2011" and OCDOrderCode is null'+
        ' order by ORDRCODE';
      ibsOrdr.ExecQuery;
      if (ibsOrdr.Eof and ibsOrdr.Bof) then begin
        if flTest then prMessageLOGS(nmProc+': '+MessText(mtkNotFoundOrders)+' ��� ����������', fLogDebug, false);
        Exit;
      end;

      ibGBr:= cntsGRB.GetFreeCnt;
      ibGB:= cntsGRB.GetFreeCnt;
      ibOrd:= cntsORD.GetFreeCnt;
      try
        ibsGBr:= fnCreateNewIBSQL(ibGBr, 'ibsGBr_'+nmProc, -1, tpRead, True);
        ibsGB := fnCreateNewIBSQL(ibGB, 'ibsGB_'+nmProc, -1, tpWrite);   // ��� ������
        ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+nmProc, -1, tpWrite); // ��� ������
        j:= 0;
        while not ibsOrdr.Eof do begin //------------ ���� �� ������ �������
              // �������� ������ ����������� ���-��� �� 1 ������ �� Grossbee
          ibsGBr.SQL.Text:= 'select d.*, PIAVLASTTIME, PIAVORDCODE, IAVLASTTIME'+
            ' from Vlad_CSS_GetAllClosingDocs('+ibsOrdr.FieldByName('ORDRGBACCCODE').AsString+') d'+
            ' left join PAYINVALTER_VLAD on PIAVACCCODE=d.PInvCode'+
            ' left join INVOICEALTER_VLAD on IAVINVCODE=d.InvCODE'+
            ' where PINVANNULKEY="F" and d.PInvDprt>0'; // �������������� ����� ����������
          ibsGBr.ExecQuery;
          lstBlock.Clear;
          iCount:= 0; // ������� ������ �� 1 ������
          while not ibsGBr.Eof do begin
            flInv:= ibsGBr.FieldByName('InvCODE').AsInteger>0;
                                // ��������� ��������� ����� ���������
            dLast:= max(ibsGBr.FieldByName('PIAVLASTTIME').AsDateTime,
                        ibsOrdr.FieldByName('ORDRGBACCTIME').AsDateTime);
            if flInv then
              dLast:= max(dLast, ibsGBr.FieldByName('IAVLASTTIME').AsDateTime);
                                   // ������ ��� ������ ���� ������
            if ibsGBr.FieldByName('PIAVORDCODE').AsInteger<1 then
              lstBlock.Add('execute procedure Vlad_CSS_SetAlterAccount('+
                ibsGBr.FieldByName('PInvCode').AsString+', 0, '+
                ibsOrdr.FieldByName('ORDRCODE').AsString+', 2);');

            try     //---------------------- ����� ������ � ���-���� � Ord
              with ibsOrd.Transaction do if not InTransaction then StartTransaction;
              if flInv then begin
                sInv1:= ', OCDInvCODE, OCDInvNUMBER, OCDInvDPRT,'+
                        ' OCDInvCRNC, OCDInvSUMM, OCDInvDATE';
                sInv2:= ', '+ibsGBr.FieldByName('InvCODE').AsString+', :InvNUMBER, '+
                        ibsGBr.FieldByName('InvDPRT').AsString+', '+
                        ibsGBr.FieldByName('InvCRNC').AsString+', :InvSUMM, :InvDATE';
              end else begin
                sInv1:= '';
                sInv2:= '';
              end;
              ibsOrd.SQL.Text:= 'insert into OrdersClosingDocs (OCDOrderCode,'+
                ' OCDAccCode, OCDAccNumber, OCDAccDate, OCDAccCrnc, OCDAccSumm,'+
                ' OCDAccPROCESSED, OCDAccDprt, OCDAccCOMMENT, OCDTIMEADD'+sInv1+
                ') values ('+ibsOrdr.FieldByName('ORDRCODE').AsString+', '+
                ibsGBr.FieldByName('PInvCode').AsString+', :AccNumber, :AccDate, '+
                ibsGBr.FieldByName('PInvCrnc').AsString+','+' :AccSumm, :AccPROCESSED, '+
                ibsGBr.FieldByName('PInvDprt').AsString+', :AccCOMMENT, :OCDTIME'+sInv2+')';
              ibsOrd.ParamByName('AccNumber').AsString   := ibsGBr.FieldByName('PInvNumber').AsString;
              ibsOrd.ParamByName('AccDate').AsDateTime   := ibsGBr.FieldByName('PInvDate').AsDateTime;
              ibsOrd.ParamByName('AccSumm').AsFloat      := ibsGBr.FieldByName('PInvSumm').AsFloat;
              ibsOrd.ParamByName('AccPROCESSED').AsString:= ibsGBr.FieldByName('PINVPROCESSED').AsString;
              ibsOrd.ParamByName('AccCOMMENT').AsString  := ibsGBr.FieldByName('PInvCOMMENT').AsString;
              ibsOrd.ParamByName('OCDTIME').AsDateTime   := dLast;
              if flInv then begin
                ibsOrd.ParamByName('InvNUMBER').AsString := ibsGBr.FieldByName('InvNUMBER').AsString;
                ibsOrd.ParamByName('InvSUMM').AsFloat    := ibsGBr.FieldByName('InvSUMM').AsFloat;
                ibsOrd.ParamByName('InvDATE').AsDateTime := ibsGBr.FieldByName('InvDATE').AsDateTime;
              end;
              ibsOrd.ExecQuery;
              ibsOrd.Transaction.Commit;
              Inc(iCount);
              Inc(iDocs);

              if j>100 then begin // ����� �������� � ���
                j:= 0;
                if flTest then prMessageLOGS(nmProc+': '+IntToStr(iDocs)+' ���., '+
                  IntToStr(iAcc+lstBlock.Count)+' ��., '+IntToStr(iAnul)+' �����.', fLogDebug, false);
                Application.ProcessMessages;
              end else inc(j);
            except
              on E: Exception do begin
                prMessageLOGS(nmProc+': insert into OrdersClosingDocs ORDRCODE='+
                  ibsOrdr.FieldByName('ORDRCODE').AsString+#10+E.Message, fLogDebug, false);
                ibsOrd.Transaction.Rollback;
              end;
            end;
            ibsOrd.Close;

            ibsGBr.Next;
          end;
          ibsGBr.Close; // ������ ������ ����������� ���-��� �� 1 ������ �� Grossbee

          if lstBlock.Count>0 then try  // ����������� ��� ������ ������ � ������-������� Grossbee
            Inc(iAcc, lstBlock.Count);
            lstBlock.Insert(0, 'execute block as begin');
            lstBlock.Add('end');
            with ibsGB.Transaction do if not InTransaction then StartTransaction;
            ibsGB.SQL.Clear;
            ibsGB.SQL.AddStrings(lstBlock);
            ibsGB.ExecQuery;
            ibsGB.Transaction.Commit;
          except
            on E: Exception do begin
              prMessageLOGS(nmProc+': execute block '+#10+E.Message, fLogDebug, false);
              ibsGB.Transaction.Rollback;
            end;
          end;
          ibsGB.Close;

          if (iCount<1) then begin                   // ���� ������ �� �����
            dAnul:= Now;
            ibsGBr.SQL.Text:= 'select PInvAnnulDate, PInvAnnulKey from PAYINVOICEREESTR'+
                              ' where PInvCode='+ibsOrdr.FieldByName('ORDRGBACCCODE').AsString;
            ibsGBr.ExecQuery;        // ��������� ��������� ���������� �����
            flAnul:= (ibsGBr.Bof and ibsGBr.Eof);
            if not flAnul and (ibsGBr.FieldByName('PInvAnnulKey').AsString='T') then begin
              flAnul:= True;
              if not ibsGBr.FieldByName('PInvAnnulDate').IsNull then begin // ���� ���������
                dAnul:= ibsGBr.FieldByName('PInvAnnulDate').AsDateTime;
                if (YearOf(dAnul)<2000) then dAnul:= Now; // �� ����.������
              end;
            end;
            if flAnul then try                               // ���������� �����
              with ibsOrd.Transaction do if not InTransaction then StartTransaction;
              ibsOrd.SQL.Text:= 'update ORDERSREESTR set ORDRSTATUS='+IntToStr(orstAnnulated)+
                ', ORDRANNULATEREASON=:anulREASON, ORDRANNULATEDATE=:anulDate'+
                ' where ORDRCODE='+ibsOrdr.FieldByName('ORDRCODE').AsString;
              ibsOrd.ParamByName('anulREASON').AsString:= '��� ����� �� ������ ������������.';
              ibsOrd.ParamByName('anulDate').AsDateTime:= dAnul;
              ibsOrd.ExecQuery;
              ibsOrd.Transaction.Commit;
              Inc(iAnul);
            except
              on E: Exception do begin
                prMessageLOGS(nmProc+': update ORDERSREESTR '+#10+E.Message, fLogDebug, false);
                ibsOrd.Transaction.Rollback;
              end;
            end;
            ibsGBr.Close;
          end;
          cntsOrd.TestSuspendException;
          ibsOrdr.Next;
        end;
      finally
        prFreeIBSQL(ibsOrd);
        cntsOrd.SetFreeCnt(ibOrd);
        prFreeIBSQL(ibsGB);
        cntsGRB.SetFreeCnt(ibGB);
        prFreeIBSQL(ibsGBr);
        cntsGRB.SetFreeCnt(ibGBr);
      end;
    finally
      prFreeIBSQL(ibsOrdr);
      cntsOrd.SetFreeCnt(ibOrdr);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+#10+E.Message, fLogDebug, false);
  end;
  prFree(lstBlock);
  if flTest then prMessageLOGS(nmProc+': '+IntToStr(iDocs)+
    ' ���-���, '+IntToStr(iAcc)+' ��., '+IntToStr(iAnul)+' �����. - '+GetLogTimeStr(LocalStart), fLogDebug, false);
end;
*)
(*
//================================= ������������ ���� � Grossbee (������� �����)
procedure prOrderToGBn_Ord(Stream: TBoBMemoryStream; ThreadData: TThreadData; CreateMail: boolean=false);
const nmProc = 'prOrderToGBn_Ord'; // ��� ���������/�������
      nfdeadlock = 'deadlock';
//------------------------------------------ ��������� ������ (��� ������ �����)
type
  ROrderOpts = record
    ORDRCODE, DCACCODE, FirmID, ORDRSOURCE, recCloseDocs, contID, deliv, DprtID,
      DestID, ttID, smID, stID, accType, currID: Integer;
    ORDRNUM, DCACNUMBER, commDeliv, commWarrant, comment: String;
    pDate: TDateTime;
    Firma: TFirmInfo;
    Contract: TContract;
  end;
var i, TryCount, ErrCount, RecCount: integer;
    s, s1, ss2, s3, ss3, ErrorStr, ErrStr, STORAGEnew, wCode, WaresErrMess, accLine, ss1: String;
    Success, ChangeStorage, ErrTransGB, flSaveCont, flCheckShipParams: boolean;
    accLines: TStringList;
    ibGB, ibGBt, ibOrd, ibOrdW: TIBDatabase;
    ibsGB, ibsOrd, ibsOrdW, ibsGBt: TIBSQL;
    price, Qty, AccSumm: Double;
    Ware: TWareInfo;
    LocalStart, dd: TDateTime;
    Order: ROrderOpts;
{  //-------------------------------------------
  procedure SaveToLogTransInfo(emess, dop: string);
  var i: integer;
      s, ntr: string;
  begin
    i:= pos('concurrent transaction number is ', emess);
    if i<1 then exit;
    s:= '';
    ntr:= copy(emess, i+33, length(emess));
    for i:= 1 to length(ntr) do
      if SysUtils.CharInSet(ntr[i], ['0'..'9']) then s:= s+ntr[i] else break;
    if s='' then exit;
    try
      prMessageLOGS(' ', nfdeadlock, False);
      prMessageLOGS('E.Message: '+emess, nfdeadlock, False);
      prMessageLOGS('TransInfo (id='+s+') --------------- begin', nfdeadlock, False);
      if dop<>'' then prMessageLOGS('addi_info: '+dop, nfdeadlock, False);
      with ibsGBt.Transaction do if not InTransaction then StartTransaction;
      if ibsGBt.SQL.Text='' then begin
        ibsGBt.SQL.Text:= 'select T.mon$timestamp tr_begin, '+
          ' DATEDIFF(SECOND FROM T.mon$timestamp TO current_timestamp) tr_sec, '+
          ' A.mon$user tr_user, A.mon$remote_process tr_proc, '+
          ' cast( S.mon$sql_text as varchar (2400)) tr_sql from MON$TRANSACTIONS T'+
          ' left join MON$STATEMENTS S on S.mon$transaction_id = T.mon$transaction_id'+
          ' left join MON$ATTACHMENTS A on A.mon$attachment_id = T.mon$attachment_id'+
          ' where T.mon$transaction_id = :tid';
        ibsGBt.Prepare;
      end;
      ibsGBt.ParamByName('tid').AsString:= s;
      ibsGBt.ExecQuery;
      while not ibsGBt.Eof do begin
        prMessageLOGS('tr_begin='+ibsGBt.Fields[0].AsString+
          ', tr_sec='+ibsGBt.Fields[1].AsString+
          ', tr_user='+ibsGBt.Fields[2].AsString+
          ', tr_proc='+ibsGBt.Fields[3].AsString, nfdeadlock, False);
        prMessageLOGS('tr_sql='+ibsGBt.Fields[4].AsString, nfdeadlock, False);
        ibsGBt.Next;
      end;
      prMessageLOGS('TransInfo (id='+s+') --------------- end'#10#10, nfdeadlock, False);
    except
      on E: Exception do ErrorStr:= ErrorStr+#13#10'error SaveToLogTransInfo:'+E.Message;
    end;
    if ibsGBt.Transaction.InTransaction then ibsGBt.Transaction.Rollback;
    ibsGBt.Close;
  end;  }
  //-------------------------------------------
begin
  LocalStart:= now();
  ErrorStr:= '';   // ��������� � ���������� ������
  ErrStr:= '';     // ��������� �� ������� ������ �������
  ErrCount:= 0;
  RecCount:= 0;
  ErrTransGB:= False;
  ibsOrd:= nil;
  ibsOrdW:= nil;
  ibGB:= nil;
  ibOrd:= nil;
  ibsGB:= nil;
  ibsGBt:= nil;
  ibGBt:= nil;
  accLines:= TStringList.Create;
  Order.contID:= 0;
  flSaveCont:= False;
  Order.Contract:= nil;
  try try
    Stream.Position:= 0;
    Order.ORDRCODE:= Stream.ReadInt;
    flCheckShipParams:= Stream.ReadBool;

    ibOrd:= cntsORD.GetFreeCnt;                           // ��� ������ ��������
    ibOrdW:= cntsORD.GetFreeCnt;
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+nmProc, ThreadData.ID, tpWrite);
    ibsOrdW:= fnCreateNewIBSQL(ibOrdW, 'ibsOrdW_'+nmProc, ThreadData.ID, tpRead, True);

//    Order.sORDRCODE:= IntToStr(Order.ORDRCODE);

    with ibsOrdW.Transaction do if not InTransaction then StartTransaction;
    ibsOrdW.SQL.Text:= 'SELECT ORDRACCOUNTINGTYPE, ORDRNUM, ORDRCODE, ORDRFIRM,'+
      ' ORDRSOURCE, ORDRDATE, ORDRWARRANT, ORDRWARRANTPERSON, ORDRWARRANTDATE,'+
      ' ORDRSTORAGECOMMENT, ORDRDELIVERYTYPE, ORDRCONTRACT, ORDRSHIPDATE,'+
      ' ORDRDESTPOINT, ORDRTIMETIBLE, ORDRSHIPMETHOD, ORDRSHIPTIMEID, ORDRCURRENCY'+
      ' FROM ORDERSREESTR WHERE ORDRCODE='+IntToStr(Order.ORDRCODE);
    ibsOrdW.ExecQuery;
    if (ibsOrdW.Bof and ibsOrdW.Eof) then raise Exception.Create(MessText(mtkNotValidParam));

    Order.FirmID:= ibsOrdW.FieldByName('ORDRFIRM').AsInteger; // ��������� �����
    if (Order.FirmID<1) then raise Exception.Create(MessText(mtkNotFirmExists));
    Cache.TestFirms(Order.FirmID, True);
    if not Cache.FirmExist(Order.FirmID) then raise Exception.Create(MessText(mtkNotFirmExists));

//    Order.ORDRFIRM:= IntToStr(Order.FirmID);
    Order.Firma:= Cache.arFirmInfo[Order.FirmID];
    Order.contID:= ibsOrdW.FieldByName('ORDRCONTRACT').AsInteger;
    i:= Order.contID;
    Order.Contract:= Order.Firma.GetContract(Order.contID);
    if (Order.Contract.Status=cstClosed) then           // �������� �� ����������� ���������
      raise Exception.Create('�������� '+Order.Contract.Name+' ����������');

    Order.accType:= ibsOrdW.FieldByName('ORDRACCOUNTINGTYPE').AsInteger;

    flSaveCont:= (Order.contID>0) and (i<>Order.contID) and not Order.Contract.Fictive;
    Order.DprtID:= Order.Contract.MainStorage;
//    Order.STORAGE:= Order.Contract.MainStoreStr;

    Order.currID:= ibsOrdW.FieldByName('ORDRCURRENCY').AsInteger;
    if (Order.currID<>Cache.BonusCrncCode) then
      Order.currID:= Order.Contract.DutyCurrency;

    Order.ORDRNUM:= ibsOrdW.FieldByName('ORDRNUM').AsString;
    Order.ORDRSOURCE:= ibsOrdW.FieldByName('ORDRSOURCE').AsInteger;
    Order.pDate:= ibsOrdW.FieldByName('ORDRSHIPDATE').AsDateTime;
    Order.DestID:= ibsOrdW.FieldByName('ORDRDESTPOINT').AsInteger;
    Order.ttID:= ibsOrdW.FieldByName('ORDRTIMETIBLE').AsInteger;
    Order.smID:= ibsOrdW.FieldByName('ORDRSHIPMETHOD').AsInteger;
    Order.stID:= ibsOrdW.FieldByName('ORDRSHIPTIMEID').AsInteger;
    Order.deliv:= ibsOrdW.FieldByName('ORDRDELIVERYTYPE').AsInteger;

//-------------------------------------------------------- ��������� �����������
    Order.commWarrant:= '';
    if (Order.currID=cUAHCurrency) then begin
      ss2:= ibsOrdW.FieldByName('ORDRWARRANT').AsString;
      if ss2<>'' then ss2:= ' N'+ss2;
      dd:= ibsOrdW.FieldByName('ORDRWARRANTDATE').AsDateTime;
      if (YearOf(dd)<2000) then s3:= '' else s3:= ' �� '+FormatDateTime(cDateFormatY4, dd);
      ss3:= ibsOrdW.FieldByName('ORDRWARRANTPERSON').AsString;
      if ss3<>'' then ss3:= ' ������ '+ss3;
      if (ss2<>'') or (ss3<>'') or (s3<>'') then Order.commWarrant:= '������������'+ss2+s3+ss3+'. ';
    end;
    case Order.deliv of
      cDelivTimeTable: Order.commDeliv:= '��������. ';  // �������� �� ����������
      cDelivSelfGet  : Order.commDeliv:= '���������. '; // ���������
      else begin
        if (Order.deliv<>cDelivReserve) then Order.deliv:= cDelivReserve;
        Order.commDeliv:= '������. ';    // ������
      end;
    end;
    Order.comment:= ibsOrdW.FieldByName('ORDRSTORAGECOMMENT').AsString;
    ss3:= fnIfStr(Order.comment='', '', Order.comment+'. ')+Order.commDeliv+
          Order.commWarrant+'���. '+Order.ORDRNUM+' �� '+
          FormatDateTime(cDateFormatY4, ibsOrdW.FieldByName('ORDRDATE').AsDateTime)+'.';
    s1:= Copy(ss3, 1, Cache.AccWebCommLength);
    ibsOrdW.Close;
    ss3:= '';

    with ibsOrdW.Transaction do if not InTransaction then StartTransaction;
    ibsOrdW.SQL.Text:= 'SELECT ORDRLNWARE, sum(ORDRLNCLIENTQTY) as ORDRLNCLIENTQTY'+
      ' FROM ORDERSLINES where ORDRLNORDER='+IntToStr(Order.ORDRCODE)+
      ' and ORDRLNCLIENTQTY>:p0 group by ORDRLNWARE';
    ibsOrdW.Prepare;
    ibsOrdW.ParamByName('p0').AsFloat:= constDeltaZero;

    ibGBt:= cntsGRB.GetFreeCnt;
    ibGB:= cntsGRB.GetFreeCnt;
    ibsGBt:= fnCreateNewIBSQL(ibGBt, 'ibsGBt_'+nmProc, ThreadData.ID);
    ibsGB:= fnCreateNewIBSQL(ibGB, 'ibsGB_'+nmProc, ThreadData.ID, tpWrite);

    with ibsOrdW.Transaction do if not InTransaction then StartTransaction;
    ibsOrdW.ExecQuery;
    if (ibsOrdW.Bof and ibsOrdW.Eof) then // ���� ��� ����� ������� - �� �����
      raise Exception.Create(MessText(mtkNotFoundWares));

//------------------------------------------------------- ������ ��������� �����
    Order.DCACCODE:= 0;
    Success:= false;
    for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
      STORAGEnew:= IntToStr(Order.DprtID);
      Application.ProcessMessages;
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;

      ibsGB.SQL.Text:= 'Select NewAccCode, NewAccNumber, NewDprtCode'+
        ' from Vlad_CSS_AddAccountHeaderC('+IntToStr(Order.ORDRCODE)+', 0, '+
        IntToStr(Order.FirmID)+', '+IntToStr(Order.contID)+', '+
        IntToStr(Order.DprtID)+', '+IntToStr(Order.currID)+', :WEBCOMMENT)';
      ibsGB.ParamByName('WEBCOMMENT').AsString:= s1;
      ibsGB.ExecQuery; //---------------- ������ ������ ��������� � ����

      if (ibsGB.Bof and ibsGB.Eof) then raise Exception.Create('NewAccCode IsEmpty')
      else if (ibsGB.FieldByName('NewAccCode').AsInteger<1)
        or (ibsGB.FieldByName('NewAccNumber').AsString='') then
        raise Exception.Create('NewAccCode<1 or empty NewAccNumber');

      Order.DCACCODE:= ibsGB.FieldByName('NewAccCode').AsInteger;
      Order.DCACNUMBER:= trim(ibsGB.FieldByName('NewAccNumber').AsString);
      STORAGEnew:= ibsGB.FieldByName('NewDprtCode').AsString; // �������� ����� ��������������
      ChangeStorage:= (IntToStr(Order.DprtID)<>STORAGEnew); // ��������� ��������� ������

      if ChangeStorage then try // ���� ����� ������� - ��������� ��������� � �����������
        ibsGB.Close;
        ibsGB.SQL.Text:= 'execute procedure Vlad_CSS_AddCommToAcc('+
                         IntToStr(Order.DCACCODE)+', :CLIENTCOMMENT)';
        ibsGB.ParamByName('CLIENTCOMMENT').AsString:=
          '��������! ����� �������������� ������� �� ����� �� ���������.';
        ibsGB.ExecQuery;
      except
        on E: Exception do ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
                           '������ ������ ����������� ������� � ���� '+Order.DCACNUMBER;
      end;

      if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Commit;
      ibsGB.Close;
      if ChangeStorage then begin // ����� �����, ���� �������
//        Order.STORAGE:= STORAGEnew;
//        Order.DprtID:= StrToInt(Order.STORAGE);
        Order.DprtID:= StrToInt(STORAGEnew);
      end;
      Success:= true;
      break;
    except
      on E: Exception do begin
//        if (Pos('deadlock', E.Message)>0) then SaveToLogTransInfo(E.Message, '');
        if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Rollback;
        ibsGB.Close;
        if ErrorStr='' then ErrorStr:= '������ ������ ��������� ����� �� ������ '+Order.ORDRNUM;
        if (Pos('lock', E.Message)>0) then
          ErrorStr:= ErrorStr+#13#10'(������� '+IntToStr(TryCount)+'): '+CutLockMess(E.Message)
        else if (Pos('NewAcc', E.Message)>0) then
          ErrorStr:= ErrorStr+#13#10'(������� '+IntToStr(TryCount)+'): '+E.Message
        else begin
          ErrorStr:= ErrorStr+fnIfStr(E.Message='', '', #13#10+E.Message);
          break;
        end;
        if (TryCount<accRepeatCount) then Sleep(RepeatSaveInterval); // ���� deadlock, �� ���� �������
      end;
    end;
    if not Success then
      raise Exception.Create('������ ������ ��������� ����� �� ������ '+Order.ORDRNUM);

//------------------------------------------- ���������� �������� ������ � �����
    with ibsOrd.Transaction do if not InTransaction then StartTransaction;
    ibsOrd.Close;
    ibsOrd.SQL.Text:= 'UPDATE ORDERSREESTR SET ORDRSTATUS='+IntToStr(orstAccepted)+
      ', ORDRGBACCCODE='+IntToStr(Order.DCACCODE)+', ORDRGBACCNUMBER=:ACCNUMBER,'+
      fnIfStr(flSaveCont, ' ORDRCONTRACT='+IntToStr(Order.contID)+',', '')+
      ' ORDRGBACCTIME="NOW" WHERE ORDRCODE='+IntToStr(Order.ORDRCODE);
    ibsOrd.ParamByName('ACCNUMBER').AsString:= Order.DCACNUMBER;
    for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
      Application.ProcessMessages;
      with ibsOrd.Transaction do if not InTransaction then StartTransaction;
      ibsOrd.ExecQuery;
      ibsOrd.Transaction.Commit;
      break;
    except
      on E: Exception do begin
        with ibsOrd.Transaction do if InTransaction then Rollback;
        if (Pos('lock', E.Message)>0) and (TryCount<accRepeatCount) then
          Sleep(RepeatSaveInterval) // ���� deadlock, �� ���� �������
        else begin
          ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
                     '������ ������ ������� � ����� '+IntToStr(Order.ORDRCODE);
          break;
        end;
      end;
    end;
    ibsOrd.Close;

//------------------------------------------------ ���������� ��������� ��������
    ss1:= '';
    if flCheckShipParams then begin
      ss1:= CheckAccountShipParams(Order.deliv, Order.ContID, Order.DprtID,
        Order.pDate, Order.DestID, Order.ttID, Order.smID, Order.stID, True);
      if (ss1<>'') then ErrorStr:= ErrorStr+#13#10+ss1;
    end;
                          // �������� �� ���������� - ��� ������� �� ����� - ���
    if (Order.deliv=cDelivTimeTable) and (Order.ttID>0) then Order.stID:= 0;

    for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
      ibsGB.SQL.Text:= 'Select ErrMess from Vlad_CSS_SetAccountShipParams('+
        IntToStr(Order.DCACCODE)+', '+fnIfStr(Order.pDate>DateNull, ':dd', 'null')+', '+IntToStr(Order.DestID)+', '+
        IntToStr(Order.ttID)+', '+IntToStr(Order.smID)+', '+IntToStr(Order.stID)+')';
      if (Order.pDate>DateNull) then ibsGB.ParamByName('dd').AsDate:= Order.pDate;
      ibsGB.ExecQuery;
      if (ibsGB.Bof and ibsGB.Eof) then
        raise Exception.Create('Error Vlad_CSS_SetAccountShipParams');
      ss1:= ibsGB.FieldByName('ErrMess').AsString;
      if (ss1<>'') then raise Exception.Create(ss1);
      if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Commit;
      ibsGB.Close;
      break;
    except
      on E: Exception do begin
        if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Rollback;
        ibsGB.Close;
        if ErrorStr='' then ErrorStr:= '������ ������ ���������� �������� ����� �� ������ '+Order.ORDRNUM;
        if (Pos('lock', E.Message)>0) then
          ErrorStr:= ErrorStr+#13#10'(������� '+IntToStr(TryCount)+'): '+CutLockMess(E.Message)
        else begin
          ErrorStr:= ErrorStr+fnIfStr(E.Message='', '', #13#10+E.Message);
          break;
        end;
        if (TryCount<accRepeatCount) then Sleep(RepeatSaveInterval); // ���� deadlock, �� ���� �������
      end;
    end;
    ss1:= '';
//----------------------------------------- ������ ����������� ���-��� ��� �����
    Order.recCloseDocs:= 0;
    with ibsOrd.Transaction do if not InTransaction then StartTransaction;
    ibsOrd.SQL.Text:= 'insert into OrdersClosingDocs (OCDOrderCode, OCDAccCode,'+
      ' OCDAccNumber, OCDAccDate, OCDAccCrnc, OCDAccDprt) values ('+IntToStr(Order.ORDRCODE)+', '+
      IntToStr(Order.DCACCODE)+', :AccNumber, "TODAY", '+IntToStr(Order.currID)+', '+
      IntToStr(Order.DprtID)+') returning OCDCODE';
    ibsOrd.ParamByName('AccNumber').AsString:= Order.DCACNUMBER;
    for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
      Application.ProcessMessages;
      with ibsOrd.Transaction do if not InTransaction then StartTransaction;
      ibsOrd.ExecQuery;
      if not (ibsOrd.Bof and ibsOrd.Eof) then
        Order.recCloseDocs:= ibsOrd.FieldByName('OCDCODE').AsInteger;
      ibsOrd.Transaction.Commit;
      break;
    except
      on E: Exception do begin
        with ibsOrd.Transaction do if InTransaction then Rollback;
        Order.recCloseDocs:= 0;
        if (Pos('lock', E.Message)>0) and (TryCount<accRepeatCount) then
          Sleep(RepeatSaveInterval) // ���� deadlock, �� ���� �������
        else begin
          ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
                     '������ ������ ������ ���-���, ���� '+IntToStr(Order.DCACCODE);
          break;
        end;
      end;
    end;
    ibsOrd.Close;

{    if Cache.flAccTimeToLog then begin
      ss3:= '����� ������ ��������� - '+GetLogTimeStr(LocalStart);
      ErrStr:= ErrStr+fnIfStr(ErrStr='', '', #13#10)+ss3;
    end; }

    accLines.Clear;
//------------------------ �������� ��������� ����� - ����� ������ ������� �����
    if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
    ibsGB.SQL.Text:= 'select * from Vlad_CSS_AddAccLineC('+                         // SW 99903544
      IntToStr(Order.DCACCODE)+', '+IntToStr(Order.DprtID)+', :LNWARECODE, :ORDRLNCLIENTQTY)';
    ibsGB.Prepare;
    while not ibsOrdW.EOF do begin
      Success:= false;
      try                             // ��������� �����
        Ware:= Cache.GetWare(ibsOrdW.FieldByName('ORDRLNWARE').AsInteger);
        wCode:= ibsOrdW.FieldByName('ORDRLNWARE').AsString;
        Qty:= ibsOrdW.FieldByName('ORDRLNCLIENTQTY').AsFloat;
                                    // ������� �� ������������ ������� �������
        ss1:= StringReplace(Ware.Name, StringOfChar(' ', 2), StringOfChar(' ', 1), [rfReplaceAll]);

        if (Ware=NoWare) or not Ware.IsMarketWare(Order.FirmID, Order.contID) then
          raise Exception.Create('������ ������ ������ � ����: '+ // ��������� � ������
            fnIfStr(Ware=NoWare, '��� '+wCode, ss1)+', ����� - '+FormatFloat('# ##0', Qty));

        if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
        ibsGB.ParamByName('LNWARECODE').AsInteger   := Ware.ID;
        ibsGB.ParamByName('ORDRLNCLIENTQTY').AsFloat:= Qty;

        for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
          Application.ProcessMessages;
          if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
          ibsGB.ExecQuery; // ���������� ������
          if (ibsGB.Bof and ibsGB.Eof) then
            raise Exception.Create('NewLineCode IsEmpty');
          if (ibsGB.Fields[0].AsInteger<1) then
            raise Exception.Create('NewLineCode = '+ibsGB.Fields[0].AsString);

          if fnNotZero(ibsGB.FieldByName('ResQty').AsFloat-Qty) then begin // �������� ��������� ���-��
            Qty:= ibsGB.FieldByName('ResQty').AsFloat; // ����������� ���-��
            ss3:= '����� '+ss1+': ����� '+ibsOrdW.FieldByName('ORDRLNCLIENTQTY').AsString+
              ' ���������� �� ��������� �� '+ibsGB.FieldByName('ResQty').AsString;
            ErrStr:= ErrStr+fnIfStr(ErrStr='', '', #13#10)+ss3;
            WaresErrMess:= WaresErrMess+fnIfStr(WaresErrMess='', '', #13#10)+ss3;
          end;

          price:= ibsGB.FieldByName('ResPrice').AsFloat;
          if not fnNotZero(price) then // �������� 0-� ����
            ErrStr:= fnIfStr(ErrStr='', '', ErrStr+#13#10)+'����� '+ss1+' ������� � 0-� �����';

          accLine:= fnMakeAddCharStr(ss1, 40, True)+
                    fnMakeAddCharStr(ibsGB.FieldByName('ResQty').AsString, 10)+
                    fnMakeAddCharStr(FormatFloat(cFloatFormatSumm, price), 10);

          with ibsGB.Transaction do if InTransaction then Commit;
          ibsGB.Close;

          accLines.Add(accLine);
          Success:= true;
          Break;
        except
          on E: Exception do begin
//            if (Pos('deadlock', E.Message)>0) then SaveToLogTransInfo(E.Message, '');
            with ibsGB.Transaction do if InTransaction then Rollback;
            ibsGB.Close;
            if (TryCount=1) then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
              '������ ������ ������ ����� '+Order.DCACNUMBER+' �� ������ '+trim(Order.ORDRNUM)+
              ', ��� '+wCode+' ����� - '+FormatFloat('# ##0', Qty);
            ss3:= '';
            if (Pos('lock', E.Message)>0) then ss3:= CutLockMess(E.Message)
            else if (pos('Order of ware more rest', E.Message)>0)
              or (pos('NewLineCode', E.Message)>0) then ss3:= E.Message;
            if ss3='' then begin
              ErrorStr:= ErrorStr+fnIfStr(E.Message='', '', #13#10+E.Message);
              break;
            end else
              ErrorStr:= ErrorStr+#13#10'(������� '+IntToStr(TryCount)+'): '+ss3;
                                             // ���� deadlock, �� ���� �������
            if (TryCount<accRepeatCount) then Sleep(RepeatSaveInterval);
          end;
        end;

        if Success then begin
          i:= Order.DprtID; // ������� � ������� � ����
          if i>0 then Cache.CheckWareRest(Ware.RestLinks, i, Qty, True);

        end else begin
          ss3:= '������ ������ ������ � '+fnGetGBDocName(docAccount, 1, 0, 4)+': '+
            fnIfStr(Ware=NoWare, '��� '+wCode, ss1)+', ����� - '+FormatFloat('# ##0', Qty);
          if Ware<>NoWare then
            WaresErrMess:= WaresErrMess+fnIfStr(WaresErrMess='', '', #13#10)+ss3;
          raise Exception.Create(ss3); // ��������� � ������
        end;

      except
        on E: Exception do begin
          with ibsGB.Transaction do if InTransaction then Rollback;
          if E.Message<>'' then
            ErrStr:= fnIfStr(ErrStr='', '', ErrStr+#13#10)+E.Message;
          inc(ErrCount);
        end;
      end;
      ibsOrdW.Next;
      inc(RecCount);
    end; // while not ibsOrdW.EOF
    ibsOrdW.Close;
    ibsGB.Close;

//---------------------------- �������� ������ - ��������� ������ ������ �������
    Success:= true;
    if ErrCount>0 then begin
      ErrStr:= ErrStr+fnIfStr(ErrStr='', '', #13#10)+'������ ������ ������� � '+
        fnGetGBDocName(docAccount, 1, 0, 4)+' '+Order.DCACNUMBER+' - '+IntToStr(ErrCount)+' ���.';
      Success:= (ErrCount<RecCount);
    end;
    if not Success then try                        // ���� ��� �� ����������
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
      ibsGB.SQL.Text:= 'execute procedure Vlad_CSS_AddCommToAcc(:CODE, :CLIENTCOMMENT)';
      ibsGB.ParamByName('CODE').AsInteger:= Order.DCACCODE;
      ibsGB.ParamByName('CLIENTCOMMENT').AsString:= ' - ������ ������ ������� � '+fnGetGBDocName(docAccount, 1, 0, 4)+'.';
      ibsGB.ExecQuery;         // ����� � ����������� �����
      ibsGB.Transaction.Commit;
    except
      with ibsGB.Transaction do if InTransaction then Rollback;
    end;
{    if Cache.flAccTimeToLog then begin
      ss3:= '����� ������ �����     - '+GetLogTimeStr(LocalStart);
      ErrStr:= ErrStr+fnIfStr(ErrStr='', '', #13#10)+ss3;
    end; }

//---------------------------------------- �������� ���� - ��������� ����� �����
    ibsGBt.Close;
    with ibsGBt.Transaction do if not InTransaction then StartTransaction;
    ibsGBt.SQL.Text:= 'SELECT r.PInvSumm aSUMM, r.PInvDate aDATE,'+
      ' (select sum(pinvlnprice*pinvlncount) from PAYINVOICELINES'+
      '   where pinvlndocmcode=r.PInvCode) sumlines'+
      ' from PayInvoiceReestr r where r.PInvCode='+IntToStr(Order.DCACCODE);
    ibsGBt.ExecQuery;
    if (ibsGB.Bof and ibsGB.Eof) then raise Exception.Create('Not found aCODE='+IntToStr(Order.DCACCODE));
    ss1:= ibsGBt.FieldByName('aDATE').AsString;
    AccSumm:= ibsGBt.FieldByName('aSUMM').AsFloat;
    price:= ibsGBt.FieldByName('sumlines').AsFloat;
    ibsGBt.Close;
    ibsGBt.SQL.Text:= '';

//-------------------------------- ���� unit-���� - ��������� � unit-������� �/�
    if (Order.currID=Cache.BonusCrncCode) then Order.firma.BonusRes:= Order.firma.BonusRes+AccSumm;

//------------------------------------- ����� ����� � ������ ����������� ���-���
    if (Order.recCloseDocs>0) then begin
      with ibsOrd.Transaction do if not InTransaction then StartTransaction;
      ibsOrd.SQL.Text:= 'update OrdersClosingDocs set OCDAccSumm=:AccSumm'+
                        ' where OCDCODE='+IntToStr(Order.recCloseDocs);
      ibsOrd.ParamByName('AccSumm').AsFloat:= AccSumm;
      for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
        Application.ProcessMessages;
        with ibsOrd.Transaction do if not InTransaction then StartTransaction;
        ibsOrd.ExecQuery;
        ibsOrd.Transaction.Commit;
        break;
      except
        on E: Exception do begin
          with ibsOrd.Transaction do if InTransaction then Rollback;
          if (Pos('lock', E.Message)>0) and (TryCount<accRepeatCount) then
            Sleep(RepeatSaveInterval) // ���� deadlock, �� ���� �������
          else begin
            ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
                       '������ ������ ����� � ������ ���-���, ���� '+IntToStr(Order.DCACCODE);
            break;
          end;
        end;
      end; // for TryCount
      ibsOrd.Close;
    end; //  if recCloseDocs>0

//--------------------------------------------- �������� ������ � �������� �����
    if CreateMail then begin
      s:= prSendMessAboutCreateAccount(Order.ORDRCODE, Order.DCACCODE,
        Order.FirmID, Order.contID, Order.DprtID, Order.currID, ThreadData.ID,
        AccSumm, price, Order.DCACNUMBER, Order.ORDRNUM, ss1, ErrStr, accLines);
      if s<>'' then ErrorStr:= ErrorStr+fnIfStr(ErrorStr='', '', #13#10)+s;
    end; // if CreateMail

//---------------------------------------------------------------- ����� �������
    Stream.Clear;
    if WaresErrMess<>'' then begin // ���� ���� ������ ��� ������ �������
      Stream.WriteInt(erWareToAccount);
      Stream.WriteStr(WaresErrMess);
    end else Stream.WriteInt(aeSuccess); // ������� ����, ��� ������ ��������� ���������
  except
    on E: Exception do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr('������ ������ ���������.');
      ErrorStr:= ErrorStr+fnIfStr(ErrorStr='', '', #13#10)+E.Message;
    end;
  end;
  finally
    if (ErrorStr<>'') or (ErrStr<>'') then
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, ErrorStr, ErrStr, '', false, 'error');
    prFreeIBSQL(ibsGB);
    cntsGRB.SetFreeCnt(ibGB);
    prFreeIBSQL(ibsGBt);
    cntsGRB.SetFreeCnt(ibGBt);
    prFreeIBSQL(ibsOrd);
    cntsORD.SetFreeCnt(ibOrd);
    prFreeIBSQL(ibsOrdW);
    cntsORD.SetFreeCnt(ibOrdW);
    prFree(accLines);
    Stream.Position:= 0;
  end;
//  if ToLog(9) then prMessageLOGS(nmProc+': '+GetLogTimeStr(LocalStart), 'OrderToGB', false); // ����� � log
end;
*)
//======================== �������� ������ � ���� Grossbee � ������������ ������
function fnOrderToGB(OrderID: Integer; flCheckShipParams, CreateMail: Boolean;
         var WaresErrMess: String; ThreadData: TThreadData): Integer;
const nmProc = 'fnOrderToGB'; // ��� ���������/�������
      cstStarting =  0;
      cstSaved    =  1;
      cstCutSaved =  2;
      cstErrLock  = -1;
      cstErrFatal = -9;
var i, TryCount, ErrCount, RecCount, j, STORAGEnew, MeetPerson: integer;
    ErrPos, s, s1, ss2, ss3, accLine, wCutName,     SaveErrStr, // ������ ������ � ������
      sQty, sDoc2, sMeet, sResQty, sDprtID, sAccID,   ErrorStr, // ������ ������ � ���
      sDivis, sDoc1, sDoc4, sOrderID, sContID, sCurrID: String;
    Success, flSaveCont, flDontJoin, flProcessed, flMeet{, flNewAddLineJoin}: boolean;
    ibGB, ibGBt, ibOrd: TIBDatabase;
    ibsGB, ibsOrd, ibsGBt: TIBSQL;
    price, ResQty: Double;
    Ware: TWareInfo;
    LocalStart: TDateTime;
    Ord: ROrderOpts;
    tc: TTwoCodes; // ID1- ��� ������, Qty-���-��, ID2: 0- �� ���������, 1- �������, -1 - ������ ������
  //-------------------------------------------
  function BreakOnTrySaveWareException(accNum, EMessage: String): Boolean;
  begin
    Result:= False;
    if ibsGB.Transaction.InTransaction then ibsGB.Transaction.RollbackRetaining;
    ibsGB.Close;
    if (TryCount=1) then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
      '������ ������ ������ '+wCutName+', ��� '+IntToStr(tc.ID1)+' � '+sDoc4+' '+
      accNum+' �� ������ '+Ord.ORDRNUM+', ���-�� - '+sQty;
    ss3:= '';
    if (Pos('lock', EMessage)>0) then begin
      tc.ID2:= cstErrLock; // ������ �������
      ss3:= CutLockMess(EMessage);
    end else if (pos('NewLineCode', EMessage)>0) then ss3:= EMessage
    else if (pos('Order of ware more rest', EMessage)>0) then begin
      tc.ID2:= cstErrFatal; // ��������� ������
      ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+EMessage;
      Result:= True;
      exit;
    end else if (pos('������������', EMessage)>0) then begin
      tc.ID2:= cstErrFatal; // ��������� ������
      ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+'����� ������������';
      Result:= True;
      exit;
    end;
    if (ss3<>'') then
      ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+'(������� '+IntToStr(TryCount)+'): '+ss3
    else begin
      tc.ID2:= cstErrFatal; // ��������� ������
      if (EMessage<>'') then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+EMessage;
      Result:= True;
      exit;
    end;                             // ���� deadlock, �� ���� �������
    if (TryCount<accRepeatCount) then Sleep(RepeatSaveInterval);
  end;
  //-------------------------------------------
  function DoAfterTrySaveWare(accNum: String): String;
  begin
    Result:= '';
    if Success then begin
//      tc.ID2:= cstSaved;
      if (ResQty>0) and (Ord.DprtID>0) then // ������� ���� � ������� � ����
        Cache.CheckWareRest(Ware.RestLinks, Ord.DprtID, ResQty, True);
    end else begin
      Result:= '������ ������ ������ � '+sDoc4+' '+accNum+': '+wCutName+', ���-�� - '+sQty;
      if (Ware<>NoWare) then
        WaresErrMess:= WaresErrMess+fnIfStr(WaresErrMess='', '', #13#10)+Result;
    end;
  end;
  //-------------------------------------------
  function ExceptionOnCheckWare(accNum: String): String;
  begin
    Result:= '';
    Ware:= Cache.GetWare(tc.ID1);   // ������� �� ������������ ������� �������
    wCutName:= StringReplace(Ware.Name, StringOfChar(' ', 2), StringOfChar(' ', 1), [rfReplaceAll]);
    tc.Qty:= RoundTo(tc.Qty, -3);
    sQty:= StringReplace(FloatToStr(tc.Qty), ',', '.', [rfReplaceAll]);

    if (Ware=NoWare) or not Ware.IsMarketWare(Ord.Firma.ID, Ord.Contract.ID) then begin
      If (Ware=NoWare) then wCutName:=  '��� '+IntToStr(tc.ID1);
      tc.ID2:= cstErrFatal; // ��������� ������
      Result:= '������ ������ ������ � '+sDoc4+' '+accNum+': '+wCutName+', ���-�� - '+sQty;
      exit;
    end;
    sDivis:= StringReplace(FloatToStr(RoundTo(Ware.divis, -3)), ',', '.', [rfReplaceAll]);
  end;
  //-------------------------------------------
  procedure AddAccLine(lst: TStringList);
  begin
    accLine:= fnMakeAddCharStr(wCutName, 40, True)+
              fnMakeAddCharStr(sResQty, 10)+
              fnMakeAddCharStr(FormatFloat(cFloatFormatSumm, price), 10);
    lst.Add(accLine);
  end;
  //-------------------------------------------
begin
  LocalStart:= now();
  ErrorStr:= '';   // ��������� � ���������� ������
  SaveErrStr:= ''; // ��������� �� ������� ������ �������
  WaresErrMess:= '';
  sDoc1:= fnGetGBDocName(docAccount, 1, 0, 1);
  sDoc2:= fnGetGBDocName(docAccount, 1, 0, 2);
  sDoc4:= fnGetGBDocName(docAccount, 1, 0, 4);
  ErrCount:= 0;
  RecCount:= 0;
  ResQty:= 0;
  ibOrd:= nil;
  ibsOrd:= nil;
  ibGB:= nil;
  ibsGB:= nil;
  ibGBt:= nil;
  ibsGBt:= nil;
  flSaveCont:= False;
  flProcessed:= False;
  Ord.Contract:= nil;
  Result:= aeSuccess;
  Ord.olOrdWares:= TObjectList.Create;
  Ord.accSing.accLines:= TStringList.Create;
  Ord.accJoin.accLines:= TStringList.Create;
  MeetPerson:= 0;
  sMeet:= '';
  flMeet:= False;
  try try
    sOrderID:= IntToStr(OrderID);
    ibOrd:= cntsORD.GetFreeCnt; //------------------------------ ������ ��������
    ibsOrd:= fnCreateNewIBSQL(ibOrd, 'ibsOrd_'+nmProc, ThreadData.ID, tpRead, True);
    ibsOrd.SQL.Text:= 'SELECT ORDRACCOUNTINGTYPE, ORDRNUM, ORDRCODE, ORDRFIRM,'+
      ' ORDRDATE, ORDRCURRENCY, ORDRSTORAGECOMMENT, ORDRDELIVERYTYPE,'+
      ' ORDRSTATUS, ORDRCONTRACT, ORDRSHIPDATE, OrdrDontJoinAcc,'+
      ' ORDRDESTPOINT, ORDRTIMETIBLE, ORDRSHIPMETHOD, ORDRSHIPTIMEID'+
      fnIfStr(flMeetPerson, ', ordrAccMeetPerson', '')+
      ' FROM ORDERSREESTR WHERE ORDRCODE='+sOrderID;
    ibsOrd.ExecQuery;
    if (ibsOrd.Bof and ibsOrd.Eof) then
      raise Exception.Create(MessText(mtkNotValidParam));

    j:= ibsOrd.FieldByName('ORDRFIRM').AsInteger; //------------ ��������� �����
    if (j>0) then begin
      Cache.TestFirms(j, True);
      if not Cache.FirmExist(j) then j:= 0;
    end;
    if (j<1) then raise Exception.Create(MessText(mtkNotFirmExists));
    Ord.Firma:= Cache.arFirmInfo[j];

    Ord.ORDRNUM:= ibsOrd.FieldByName('ORDRNUM').AsString;
    j:= ibsOrd.FieldByName('ORDRCONTRACT').AsInteger; //----- ��������� ��������
    i:= j;
    Ord.Contract:= Ord.Firma.GetContract(j);

    if (Ord.Contract.Status=cstClosed) then begin //------- ���� �������� ������
      if (ibsOrd.FieldByName('ORDRSTATUS').AsInteger>orstForming) then begin
        ibsOrd.Close;
        fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
        ibsOrd.SQL.Text:= 'UPDATE ORDERSREESTR SET ORDRSTATUS='+IntToStr(orstForming)+
          ' WHERE ORDRCODE='+sOrderID; // ���������� ������ "�����������"
ErrPos:= '0';
        s1:= RepeatExecuteIBSQL(ibsOrd, accRepeatCount); // accRepeatCount �������
        if (s1<>'') then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
                          '������ ������ ������� � ����� '+Ord.ORDRNUM+': '+s1;
      end;
      raise Exception.Create('�������� '+Ord.Contract.Name+' ����������');
    end; // if (Ord.Contract.Status=cstClosed)

    flSaveCont:= (Ord.Contract.ID>0) and (i<>Ord.Contract.ID) and not Ord.Contract.Fictive;
    Ord.DprtID:= Ord.Contract.MainStorage;

    //---------------------------------- ���������� ������ � ������� �����������
    Ord.accType:= ibsOrd.FieldByName('ORDRACCOUNTINGTYPE').AsInteger;
    Ord.currID:= ibsOrd.FieldByName('ORDRCURRENCY').AsInteger;
    if (Ord.currID<>Cache.BonusCrncCode) then begin
      Ord.currID:= Ord.Contract.DutyCurrency;
if not flNewSaveAcc then flDontJoin:= True else
      flDontJoin:= GetBoolGB(ibsOrd, 'OrdrDontJoinAcc');
    end else flDontJoin:= True; // �������� ������ - ��������� ����� ������

    Ord.pDate:= ibsOrd.FieldByName('ORDRSHIPDATE').AsDateTime;
    Ord.DestID:= ibsOrd.FieldByName('ORDRDESTPOINT').AsInteger;
    Ord.ttID:= ibsOrd.FieldByName('ORDRTIMETIBLE').AsInteger;
    Ord.smID:= ibsOrd.FieldByName('ORDRSHIPMETHOD').AsInteger;
    Ord.stID:= ibsOrd.FieldByName('ORDRSHIPTIMEID').AsInteger;
    Ord.deliv:= ibsOrd.FieldByName('ORDRDELIVERYTYPE').AsInteger;

    sDprtID:= IntToStr(Ord.DprtID);
    sContID:= IntToStr(Ord.Contract.ID);
    sCurrID:= IntToStr(Ord.currID);

//-------------------------------------------------------- ��������� �����������
    Ord.comment:= ibsOrd.FieldByName('ORDRSTORAGECOMMENT').AsString;
    if (Ord.comment<>'') then begin
      if (copy(Ord.comment, length(Ord.comment), 1)<>'.') then
        Ord.comment:= Ord.comment+'. '
      else Ord.comment:= Ord.comment+' ';
      Ord.comment:= StringReplace(Ord.comment, '''', '`', [rfReplaceAll]);
      Ord.comment:= StringReplace(Ord.comment, '"', '`', [rfReplaceAll]);
    end;
    case Ord.deliv of
      cDelivTimeTable: Ord.commDeliv:= '��������. ';  // �������� �� ����������
      cDelivSelfGet  : Ord.commDeliv:= '���������. '; // ���������
      else if not flNotReserve then begin
        if (Ord.deliv<>cDelivReserve) then Ord.deliv:= cDelivReserve;
        Ord.commDeliv:= '������. ';    // ������
      end;
    end;
    Ord.commOrder:= '����� '+Ord.ORDRNUM+' �� '+
          FormatDateTime(cDateFormatY2, ibsOrd.FieldByName('ORDRDATE').AsDateTime)+'.';

if flMeetPerson then begin
    flMeet:= (Ord.deliv in [cDelivTimeTable, cDelivSelfGet]);
    if flMeet then begin
      MeetPerson:= ibsOrd.FieldByName('ordrAccMeetPerson').AsInteger;
      sMeet:= IntToStr(MeetPerson);
    end;
end; // flMeetPerson

    ibsOrd.Close;
    ss3:= '';

//----------------------------------------------- ��������� ������ ����� �������
    if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
    ibsOrd.SQL.Text:= 'SELECT ORDRLNWARE, sum(ORDRLNCLIENTQTY) as QTY'+
      ' FROM ORDERSLINES where (ORDRLNORDER='+sOrderID+
      ' and ORDRLNCLIENTQTY>0) group by ORDRLNWARE';
ErrPos:= '1';
    ibsOrd.ExecQuery;
    while not ibsOrd.EOF do begin
      tc:= TTwoCodes.Create(ibsOrd.FieldByName('ORDRLNWARE').AsInteger,
                            cstStarting, ibsOrd.FieldByName('QTY').AsFloat);
      Ord.olOrdWares.Add(tc);
      TestCssStopException;
      ibsOrd.Next;
    end;
    ibsOrd.Close;
    if (Ord.olOrdWares.Count<1) then // ���� ��� ����� ������� - �� �����
      raise Exception.Create(MessText(mtkNotFoundWares));

    fnSetTransParams(ibsOrd.Transaction, tpWrite); // ������� ibsOrd � ������

    ibGBt:= cntsGRB.GetFreeCnt;
    ibGB:= cntsGRB.GetFreeCnt;
    ibsGBt:= fnCreateNewIBSQL(ibGBt, 'ibsGBt_'+nmProc, ThreadData.ID);
    ibsGB:= fnCreateNewIBSQL(ibGB, 'ibsGB_'+nmProc, ThreadData.ID, tpWrite);

//------------------------------------------------- ��������� ��������� ��������
    if flCheckShipParams then begin
      j:= Ord.stID;
      s1:= CheckAccountShipParams(Ord.deliv, Ord.Contract.ID, Ord.DprtID, Ord.pDate,
        Ord.DestID, Ord.ttID, Ord.smID, Ord.stID, True);
      if (s1<>'') then begin
        s1:= '������ ������ ���������� ��������: '+s1;
        ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+s1;
        SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+s1;
      end;
    end;

    ord.accJoin.ID:= 0;
    ord.accSing.ID:= 0;
//////////////////////////////////////////////////////////// ���� ��� ����������
    if not flDontJoin then try // ���� ���� ��� ���������� (��� ������ � �������)
      if not ibsGBt.Transaction.InTransaction then ibsGBt.Transaction.StartTransaction;
      ibsGBt.SQL.Text:= ' select AddAccCode, AddAccNumber, Processed, webcomm, aDATE'+
        ' from Vlad_CSS_GetAccForJoin('+IntToStr(Ord.Firma.ID)+', '+sContID+', '+
        sDprtID+', '+IntToStr(Ord.deliv)+', '+IntToStr(Ord.DestID)+', '+
        IntToStr(Ord.ttID)+', '+IntToStr(Ord.smID)+', '+IntToStr(Ord.stID)+', '+
        fnIfStr(flMeet, sMeet, '-1')+', "'+FormatDateTime(cDateFormatY4, Ord.pDate)+'")';
ErrPos:= '2';
      ibsGBt.ExecQuery;
      if not (ibsGBt.Eof and ibsGBt.Bof) then begin
        ord.accJoin.ID     := ibsGBt.FieldByName('AddAccCode').AsInteger;
        ord.accJoin.Num    := ibsGBt.FieldByName('AddAccNumber').AsString;
        Ord.accJoin.sDate  := ibsGBt.FieldByName('aDATE').AsString;
        ord.accJoin.webcomm:= ibsGBt.FieldByName('webcomm').AsString;
        flProcessed        := GetBoolGB(ibsGBt, 'Processed');
      end;
    except
      on E: Exception do begin
        if (ErrorStr='') then ErrorStr:= '������ ������ '+sDoc2+' ��� ������ '+Ord.ORDRNUM;
        ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+e.Message;
      end;
    end; // if not flDontJoin
    ibsGBt.Close;
    ibsGBt.ParamCheck:= True;

    sAccID:= IntToStr(ord.accJoin.ID); // ����� ���� '0'
    if (ord.accJoin.ID>0) then begin
//      flNewAddLineJoin:= TestRDB(cntsGRB, trkProc, 'Vlad_CSS_AddLineToJoinAcc');
//================================================ ����� ���� - ��������� ������
      Ord.accJoin.AccSumm:= 0;
      Ord.accJoin.sumlines:= 0;
//      if flNewAddLineJoin then begin
        if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
        ibsGB.SQL.Text:= 'select NewLineCode, ResQty, ResPrice'+
                         ' from Vlad_CSS_AddLineToJoinAcc('+sAccID+', :WareID, :aOrder)';
//----------------------------------------------  ����� ������
{      end else begin
        ibsGB.ParamCheck:= False;
        if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
        ibsGB.SQL.Add('execute block returns (NewLineCode integer,'+
                      ' ResQty double precision, ResPrice double precision)');
        ibsGB.SQL.Add('as declare variable xOrder double precision;'+
                     ' declare variable xCount double precision;');
        ibsGB.SQL.Add(' declare variable xRest double precision;'+
                      ' declare variable xDivis double precision;'+
                      ' declare variable xWare integer; declare variable xMeas integer;');
        ibsGB.SQL.Add('begin NewLineCode=0; ResQty=0; ResPrice=0;');
        //----------- ������ � �������� 4 - ����� ������
        ibsGB.SQL.Add(' xWare=0; xOrder=0; xDivis=1; xMeas=1;');
        //----------------------------------------------
        ibsGB.SQL.Add(' select Rmarket from GetWareRestsCSS_Vlad(:xWare, '+sDprtID+') into :xRest;');
        ibsGB.SQL.Add(' if (xRest<=0) then begin suspend; exit; end'); // ��� ������� - ���������� 0
        ibsGB.SQL.Add(' execute procedure Vlad_CSS_GetContWarePrice(:xWare, :xMeas, '+ // ������ ���� ������
                      sContID+', '+sCurrID+') returning_values :ResPrice;');
                      //----- ���� ���� ��������� - ������������� ����� ������
        ibsGB.SQL.Add(' if (xDivis>1.0) then begin'+
                      // ��������� �� ���������� �������� ������ � �������� �� ���������
                      '  xOrder=CEILING(xOrder/xDivis)*xDivis;');
                      // ���� � ������� ������ ������ - ������� ����� �� ���������
        ibsGB.SQL.Add('  while (xOrder>xRest) do begin xOrder=xOrder-xDivis;');
                      // ��� ������� � ������ ��������� - ���������� 0
        ibsGB.SQL.Add('   if (xOrder<=0) then begin suspend; exit; end end');
                      //--- ��� ����� ��������� � ������� ������ ������ - ����� �������
        ibsGB.SQL.Add(' end else if (xOrder>xRest) then xOrder=xRest;  ResQty=xOrder;');
        ibsGB.SQL.Add(' insert into PayInvoiceLines (PInvLnWareCode, PInvLnUnitCode,'+ // ��������� ������
                      '  PInvLnDocmCode, PInvLnSupplyDprtCode, PInvLnPrice, PInvLnOrder,'+
                      '  PInvLnCount) values (:xWare, :xMeas, '+sAccID+', '+sDprtID+
                      ', :ResPrice, :xOrder, :ResQty) returning PInvLnCode, PInvLnCount,'+
                      ' PInvLnPrice into :NewLineCode, :ResQty, :ResPrice; ');
        ibsGB.SQL.Add(' suspend; end');
      end;  }
//---------------------------------------------- ����� ������

      for j:= 0 to Ord.olOrdWares.Count-1 do begin
        tc:= TTwoCodes(Ord.olOrdWares[j]);
        ResQty:= 0;
        Success:= false;
        try
          s1:= ExceptionOnCheckWare(Ord.accJoin.Num);    // ��������� �����
          if (s1<>'') then raise Exception.Create(s1);

          if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;

//          if flNewAddLineJoin then begin
            ibsGB.ParamByName('WareID').AsInteger:= tc.ID1;
            ibsGB.ParamByName('aOrder').AsFloat:= tc.Qty;

//---------------------------------------------- ����� ������
//          end else begin
  //---------------- ������ ������ (������ = 4) ibsGB.SQL
//            ibsGB.SQL[4]:= ' xWare='+IntToStr(tc.ID1)+'; xOrder='+sQty+
//                           '; xDivis='+sDivis+'; xMeas='+IntToStr(ware.measID)+';';
  //-----------------------------------------------------
//          end;
//---------------------------------------------- ����� ������

          for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
            Application.ProcessMessages;
            if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
ErrPos:= '3-'+IntToStr(j)+'-'+IntToStr(TryCount);

            ibsGB.ExecQuery;       // ���������� ������
            if (ibsGB.Bof and ibsGB.Eof) then raise Exception.Create('Empty NewLineCode');

            ResQty:= ibsGB.FieldByName('ResQty').AsFloat;  // ����������� ���-��
            price:= ibsGB.FieldByName('ResPrice').AsFloat; // ����

            if ibsGB.Transaction.InTransaction then
              if (ResQty>0) then ibsGB.Transaction.Commit else ibsGB.Transaction.Rollback;
            ibsGB.Close;

            if not (ResQty>0) then tc.ID2:= cstStarting
            else begin //--------------------------- ���� �������� ������ ������
              sResQty:= StringReplace(FloatToStr(RoundTo(ResQty, -3)), ',', '.', [rfReplaceAll]);
              //------------------------------------------------ �������� ���-��
              if (ResQty>tc.Qty) then begin // ������������� �� ���������
                tc.ID2:= cstSaved;
                ss3:= '����� '+wCutName+': ����� '+sQty+' ���������� �� ��������� �� '+sResQty;
                SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+ss3;
                WaresErrMess:= WaresErrMess+fnIfStr(WaresErrMess='', '', #13#10)+ss3;
              end else if (ResQty<tc.Qty) then begin // �� ������� ������� - �������� ��������
                tc.Qty:= tc.Qty-ResQty;             // ������� ��� ������ � ��������� ����
                tc.ID2:= cstCutSaved;
              end else tc.ID2:= cstSaved;  // ����=����� - �������� ��� ���-��
              //-------------------------------------------------- �������� ����
              if fnNotZero(price) then
                Ord.accJoin.sumlines:= Ord.accJoin.sumlines+RoundToHalfDown(ResQty*price)
              else SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+
                                        '����� '+wCutName+' ������� � 0-� �����';
              AddAccLine(Ord.accJoin.accLines);
            end;  // if (ResQty>0)
            Success:= true;
            Break;
          except
            on E: Exception do
              if BreakOnTrySaveWareException(Ord.accJoin.Num, E.Message) then break;
          end; // for TryCount:= 1 to

          s1:= DoAfterTrySaveWare(Ord.accJoin.Num);
          if (s1<>'') then raise Exception.Create(s1); // ��������� � ������ ???
        except
          on E: Exception do begin
            if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Rollback;
            if (tc.ID2>cstErrLock) then tc.ID2:= cstErrLock; // ������ ������
            // � ���� ����� ������ �� ������� � �� ����� !!!
//            if (E.Message<>'') then
//              SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+E.Message;
            // � ���� ����� ������ ������� ������ ���������
//            if (tc.ID2=cstErrFatal) then inc(ErrCount);
          end;
        end;
      end; // for j:= 0 to Ord.olOrdWares.Count-1

      RecCount:= 0; //--------------------- ��������� ������� ���������� �������
      for j:= 0 to Ord.olOrdWares.Count-1 do begin
        tc:= TTwoCodes(Ord.olOrdWares[j]);
        if (tc.ID2<cstSaved) then Continue; // ����� �� �������
//        if (tc.ID2=cstCutSaved) then tc.ID2:= cstStarting;
        inc(RecCount);
      end;
      if (RecCount<1) then ord.accJoin.ID:= 0; // ���� ������ �� �������� - �������� ���
    end; // if (ord.accJoin.ID>0)
    ibsGB.ParamCheck:= True;

    if (ord.accJoin.ID>0) then begin
      //---------------- ��������� ����������� �� ������ � WEB-����������� �����
      Ord.accJoin.webcomm:= Ord.accJoin.webcomm+fnIfStr(Ord.accJoin.webcomm='', '', ' ')+
        '�����. '+IntToStr(RecCount)+' ���. �� ���.'+Ord.ORDRNUM;
      if (Ord.comment<>'') and (pos(Ord.comment, Ord.accJoin.webcomm)<1) then
        Ord.accJoin.webcomm:= Ord.accJoin.webcomm+' ('+Ord.comment+')';
      Ord.accJoin.webcomm:= fnReplaceQuotedForWeb(Ord.accJoin.webcomm);
      Ord.accJoin.webcomm:= fnChangeEndOfStrBySpace(Ord.accJoin.webcomm);
      Ord.accJoin.webcomm:= Copy(Ord.accJoin.webcomm, 1, Cache.AccWebCommLength);

      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
      ibsGB.SQL.Clear;
      ibsGB.ParamCheck:= False;
      ibsGB.SQL.Add('execute block returns (ResSumm double precision) as'+
                    ' declare variable xOrd integer=-1; begin');
      ibsGB.SQL.Add(' select PInvSumm from PayInvoiceReestr'+
                    '  where PInvCode='+sAccID+' into ResSumm;');
      ibsGB.SQL.Add(' update PayInvoiceReestr set PINVWEBCOMMENT="'+
                    Ord.accJoin.webcomm+'" where PinvCode='+sAccID+';');
                                              // ���������/���������� ��� ������
      ibsGB.SQL.Add(' select piavOrdCode from payinvalter_vlad'+
                    '  where piavAccCode='+sAccID+' into :xOrd;');
      ibsGB.SQL.Add(' if (xOrd is null or xOrd<1) then');
      ibsGB.SQL.Add('  update or insert into payinvalter_vlad'+
                    '   (piavAccCode, piavOrdCode, piavLastTime) values ('+
                    sAccID+', '+sOrderID+', "NOW") matching (piavAccCode);');
      if flProcessed then                 // ��������������� ������� "���������"
        ibsGB.SQL.Add(' update PayInvoiceReestr set PInvProcessed="T"'+
                      '  where PinvCode='+sAccID+';');
      ibsGB.SQL.Add(' suspend; end');
ErrPos:= '4';
      s1:= RepeatExecuteIBSQL(ibsGB, 'ResSumm', ss3, accRepeatCount);
      if (s1<>'') then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
        '������ ������ ����������� � '+sDoc4+' '+Ord.accJoin.Num+' �� ������ '+Ord.ORDRNUM+': '+s1
      else Ord.accJoin.AccSumm:= StrToFloat(ss3);
      ibsGB.ParamCheck:= True;

      //-------- ���������� �������� ������ � ����� � ������ ����������� ���-���
      Ord.accJoin.recDoc:= 0;
      ibsOrd.ParamCheck:= False;
      ibsOrd.SQL.Clear;
      sQty:= StringReplace(FloatToStr(RoundTo(Ord.accJoin.AccSumm, -2)), ',', '.', [rfReplaceAll]);
      if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
      ibsOrd.SQL.Add('execute block returns (RecCode integer) as begin RecCode=0;');
      ibsOrd.SQL.Add(' update or insert into OrdersClosingDocs (OCDOrderCode,'+
                     ' OCDAccCode, OCDAccNumber, OCDAccDate, OCDAccCrnc,'+
                     ' OCDAccDprt, OCDAccSumm, OCDINVCODE) values');
      ibsOrd.SQL.Add(' ('+sOrderID+', '+sAccID+', "'+Ord.accJoin.Num+'", "'+
                     Ord.accJoin.sDate+'", '+sCurrID+', '+sDprtID+', '+sQty+', null)');
      ibsOrd.SQL.Add(' MATCHING (OCDOrderCode, OCDAccCode, OCDINVCODE)'+
                     ' returning OCDCODE into :RecCode;');
      ibsOrd.SQL.Add(' update OrdersClosingDocs set OCDAccSumm='+sQty+' where'+
                     ' OCDAccCode='+sAccID+' and OCDCODE<>:RecCode;');
      ibsOrd.SQL.Add(' UPDATE ORDERSREESTR SET ORDRGBACCCODE='+sAccID+
                     ', ORDRGBACCNUMBER="'+Ord.accJoin.Num+'",'+
                     fnIfStr(flSaveCont, ' ORDRCONTRACT='+sContID+',', '')+
                     ' ORDRGBACCTIME="NOW" WHERE ORDRCODE='+sOrderID+';');
      ibsOrd.SQL.Add(' suspend; end');
ErrPos:= '5';
      s1:= RepeatExecuteIBSQL(ibsOrd, 'RecCode', Ord.accJoin.recDoc, accRepeatCount);
      if (s1<>'') or (Ord.accJoin.recDoc<1) then
        ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
          '������ ������ �������� '+sDoc2+' '+Ord.accJoin.Num+' � ������ '+Ord.ORDRNUM+': '+s1;
      ibsOrd.ParamCheck:= True;

    end; // if (ord.accJoin.ID>0)
//////////////////////////////////////////////////////////////// �������� � ����

    i:= 0; // ��������� ������� ������� ��� ������ ���������� �����
    for j:= 0 to Ord.olOrdWares.Count-1 do begin
      tc:= TTwoCodes(Ord.olOrdWares[j]);
      if (tc.ID2=cstSaved) then Continue;    // ����� ��� �������
      inc(i);
    end;

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ������ ���������� �����
    RecCount:= 0;
    if (i>0) then begin  // �������� �� ���������� - ��� ������� �� ����� - ���
      if (Ord.deliv=cDelivTimeTable) and (Ord.ttID>0) then Ord.stID:= 0;
  //-------------------------------------------- ������ ��������� ���������� �����
      ord.accSing.webcomm:= Ord.comment+Ord.commDeliv+Ord.commOrder;
      Ord.accSing.webcomm:= fnReplaceQuotedForWeb(Ord.accSing.webcomm);
      Ord.accSing.webcomm:= fnChangeEndOfStrBySpace(Ord.accSing.webcomm);
      Ord.accSing.webcomm:= Copy(Ord.accSing.webcomm, 1, Cache.AccWebCommLength);
      Ord.accSing.ID:= 0;
      ss2:= '��������! ����� �������������� ������� �� ����� �� ���������.';
      ibsGB.ParamCheck:= False;
      ibsGB.SQL.Clear;
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
      ibsGB.SQL.Add('execute block returns (NewAccCode integer, NewAccNumber varchar(16),'+
                    ' NewDprtCode integer, ErrMess varchar(100))');
      ibsGB.SQL.Add(' as begin NewAccCode=0; NewAccNumber=""; NewDprtCode=0; ErrMess="";');
      ibsGB.SQL.Add(' Select NewAccCode, NewAccNumber, NewDprtCode'); // ������ ������ ��������� � ����
//      ibsGB.SQL.Add('   from Vlad_CSS_AddAccountHeaderC('+sOrderID+', '+sAccID+', '+
      ibsGB.SQL.Add('   from Vlad_CSS_AddAccountHeaderC('+sOrderID+', 0,'+ // ������ �� accJoin �� ����� !!! (29.12.2016 ��)
                    IntToStr(Ord.Firma.ID)+', '+sContID+', '+
                    sDprtID+', '+sCurrID+', "'+ord.accSing.webcomm+'")');
      ibsGB.SQL.Add(' into :NewAccCode, :NewAccNumber, :NewDprtCode;');
      ibsGB.SQL.Add(' update PayInvoiceReestr set PINVCLIENTCOMMENT="'+ // ����.������� - ���� � ������
                    cSpecDelim+'" where PInvCode=:NewAccCode;');
      ibsGB.SQL.Add(' if (NewDprtCode<>'+sDprtID+') then '+ // ���� ����� ������� - ��������� � �����������
                    '  execute procedure Vlad_CSS_AddCommToAcc(:NewAccCode, "'+ss2+'");');
      if flDontJoin then                                         // ������� - �� ���������� �����
        ibsGB.SQL.Add(' update PayInvoiceReestr set PInvDontJoin="T" where PInvCode=:NewAccCode;');

if flMeetPerson then
      if (MeetPerson>0) then begin
        ibsGB.SQL.Add(' if (exists(select * from personphones'+
                      '  left join persons on prsncode=PPhPersonCode'+
                      '  where pphcode='+IntToStr(MeetPerson)+
                      '   and prsnarchivedkey="F" and PPhArchivedKey="F")) then');
        ibsGB.SQL.Add('  update PayInvoiceReestr set PINVMEETPERSON='+ // �����������
                      IntToStr(MeetPerson)+' where PInvCode=:NewAccCode;');
      end; // if (MeetPerson>0)

      ibsGB.SQL.Add(' Select ErrMess from Vlad_CSS_SetAccountShipParams(:NewAccCode,'+ // ��������� ��������
                    fnIfStr(Ord.pDate>DateNull, '"'+FormatDateTime(cDateFormatY4, Ord.pDate)+
                    '"', 'null')+','+IntToStr(Ord.DestID)+','+IntToStr(Ord.ttID)+','+
                    IntToStr(Ord.smID)+','+IntToStr(Ord.stID)+') into :ErrMess; suspend; end');
      ss3:= '';
      Success:= false;
      for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
        Application.ProcessMessages;
        if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
ErrPos:= '6-'+IntToStr(TryCount);
        ibsGB.ExecQuery;
        if (ibsGB.Bof and ibsGB.Eof) then raise Exception.Create('NewAccCode IsEmpty');

        Ord.accSing.ID:= ibsGB.FieldByName('NewAccCode').AsInteger;
        Ord.accSing.Num:= trim(ibsGB.FieldByName('NewAccNumber').AsString);
        if (Ord.accSing.ID<1) then raise Exception.Create('NewAccCode<1');
        if (Ord.accSing.Num='') then raise Exception.Create('empty NewAccNumber');

        STORAGEnew:= ibsGB.FieldByName('NewDprtCode').AsInteger; // �������� ����� ��������������
        ss3:= ibsGB.FieldByName('ErrMess').AsString;

        if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Commit;
        Success:= true;
        if (Ord.DprtID<>STORAGEnew) then begin // ����� �����, ���� �������
          Ord.DprtID:= STORAGEnew;
          sDprtID:= IntToStr(Ord.DprtID);
        end;
        break;
      except
        on E: Exception do begin
          if ibsGB.Transaction.InTransaction then ibsGB.Transaction.RollbackRetaining;
          ibsGB.Close;
          if (ErrorStr='') then ErrorStr:= '������ ������ ��������� '+sDoc2+' �� ������ '+Ord.ORDRNUM;
          if (Pos('lock', E.Message)>0) then
            ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+'(������� '+IntToStr(TryCount)+'): '+CutLockMess(E.Message)
          else if (Pos('NewAcc', E.Message)>0) then
            ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+'(������� '+IntToStr(TryCount)+'): '+E.Message
          else begin
            if (E.Message<>'') then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+E.Message;
            break;
          end;
          if (TryCount<accRepeatCount) then Sleep(RepeatSaveInterval); // ���� deadlock, �� ���� �������
        end;
      end; // for TryCount
      ibsGB.Close;
      if not Success then
        raise Exception.Create('������ ������ ��������� '+sDoc2+' �� ������ '+Ord.ORDRNUM);
      if (ss3<>'') then
        if (ErrorStr<>'') then ErrorStr:= ErrorStr+#13#10+ss3
        else ErrorStr:= '������ ������ ���������� �������� � '+sDoc4+' '+Ord.accSing.Num+#13#10+ss3;

//------------------------ �������� ��������� ����� - ����� ������ ������� �����
      sAccID:= IntToStr(Ord.accSing.ID);
      ibsGB.ParamCheck:= True;
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;

{      if TestRDB(cntsGRB, trkProc, 'Vlad_CSS_AddAccLineF') then
        ibsGB.SQL.Text:= 'select NewLineCode, ResQty, ResPrice'+
                         ' from Vlad_CSS_AddAccLineF('+
                         Cache.GetConstItem(pcAccFactWithFillDprt).StrValue+', '+
                         sAccID+', '+sDprtID+', :LNWARECODE, :ORDRLNCLIENTQTY)'
      else   }
        ibsGB.SQL.Text:= 'select NewLineCode, ResQty, ResPrice'+
                         ' from Vlad_CSS_AddAccLineC('+
                         sAccID+', '+sDprtID+', :LNWARECODE, :ORDRLNCLIENTQTY)';

      ibsGB.Prepare;

      for j:= 0 to Ord.olOrdWares.Count-1 do begin
        tc:= TTwoCodes(Ord.olOrdWares[j]);
        if (tc.ID2=cstSaved) then Continue; // ����� ��� �������

        ResQty:= 0;
        Success:= false;
        try
          s1:= ExceptionOnCheckWare(Ord.accSing.Num); // ��������� �����
          if (s1<>'') then raise Exception.Create(s1);

          if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
          ibsGB.ParamByName('LNWARECODE').AsInteger   := Ware.ID;
          ibsGB.ParamByName('ORDRLNCLIENTQTY').AsFloat:= tc.Qty;

          for TryCount:= 1 to accRepeatCount do try // accRepeatCount �������
            Application.ProcessMessages;
            if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
ErrPos:= '7-'+IntToStr(j)+'-'+IntToStr(TryCount);
            ibsGB.ExecQuery;       // ���������� ������
            if (ibsGB.Bof and ibsGB.Eof) or (ibsGB.FieldByName('NewLineCode').AsInteger<1) then
              raise Exception.Create('Empty NewLineCode');

            ResQty:= ibsGB.FieldByName('ResQty').AsFloat;  // ����� (�������� ����������)
            price:= ibsGB.FieldByName('ResPrice').AsFloat;
            if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Commit;
            ibsGB.Close;

            sResQty:= StringReplace(FloatToStr(RoundTo(ResQty, -3)), ',', '.', [rfReplaceAll]);
//            if fnNotZero(ResQty-tc.Qty) then begin // �������� ��������� ���-��
            if (ResQty>tc.Qty) then begin // �������� ��������� ���-��
              ss3:= '����� '+wCutName+': ����� '+sQty+' ���������� �� ��������� �� '+sResQty;
              SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+ss3;
              WaresErrMess:= WaresErrMess+fnIfStr(WaresErrMess='', '', #13#10)+ss3;
            end;

            if not fnNotZero(price) then // �������� 0-� ����
              SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+
                           '����� '+wCutName+' ������� � 0-� �����';
            AddAccLine(Ord.accSing.accLines);
            Success:= true;
            Break;
          except
            on E: Exception do
              if BreakOnTrySaveWareException(Ord.accSing.Num, E.Message) then break;
          end;

          s1:= DoAfterTrySaveWare(Ord.accSing.Num);
          if (s1<>'') then raise Exception.Create(s1); // ��������� � ������ ???
        except
          on E: Exception do begin
            if ibsGB.Transaction.InTransaction then ibsGB.Transaction.Rollback;
            if E.Message<>'' then
              SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+E.Message;
            inc(ErrCount);
          end;
        end;
        inc(RecCount);
      end; // for i:= 0 to Ord.olOrdWares.Count-1 do
      ibsGB.Close;

//---------------------------- �������� ������ - ��������� ������ ������ �������
      Success:= true;
      if (ErrCount>0) then begin
        SaveErrStr:= SaveErrStr+fnIfStr(SaveErrStr='', '', #13#10)+
         '������ ������ ������� � '+sDoc4+' '+Ord.accSing.Num+' - '+IntToStr(ErrCount)+' ���.';
        Success:= (ErrCount<RecCount);
      end;
      ibsGB.ParamCheck:= False;
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
      ibsGB.SQL.Clear;
      ibsGB.SQL.Add('execute block as begin'); // ������� ����.������� - ���� � ������
      ibsGB.SQL.Add(' update PayInvoiceReestr set PINVCLIENTCOMMENT="" where PInvCode='+sAccID+';');
      if not Success then                        // ���� ��� �� ����������
        ibsGB.SQL.Add('execute procedure Vlad_CSS_AddCommToAcc('+sAccID+
                      ', " - ������ ������ ������� � '+sDoc4+'.");');
      ibsGB.SQL.Add(' end');

      s1:= RepeatExecuteIBSQL(ibsGB, accRepeatCount); // accRepeatCount �������
      if (s1<>'') then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
        '������ ������ ����������� � '+sDoc4+' '+sAccID+': '+s1;
      ibsGB.ParamCheck:= True;

//---------------------------------------- �������� ���� - ��������� ����� �����
      ibsGBt.Close;
      if not ibsGBt.Transaction.InTransaction then ibsGBt.Transaction.StartTransaction;
      ibsGBt.SQL.Text:= 'SELECT r.PInvSumm aSUMM, r.PInvDate aDATE,'+
        ' (select sum(pinvlnprice*pinvlncount) from PAYINVOICELINES'+
        '   where pinvlndocmcode=r.PInvCode) sumlines'+
        ' from PayInvoiceReestr r where r.PInvCode='+sAccID;
      ibsGBt.ExecQuery;
      if (ibsGB.Bof and ibsGB.Eof) then raise Exception.Create('Not found aCODE='+sAccID);
      Ord.accSing.AccSumm:= ibsGBt.FieldByName('aSUMM').AsFloat;
      Ord.accSing.sumlines:= ibsGBt.FieldByName('sumlines').AsFloat;
      Ord.accSing.sDate:= ibsGBt.FieldByName('aDATE').AsString;
      ibsGBt.Close;

  //-------------------------------- ���� unit-���� - ��������� � unit-������� �/�
      if (Ord.currID=Cache.BonusCrncCode) then
        Ord.firma.BonusRes:= Ord.firma.BonusRes+Ord.accSing.AccSumm;

//--------------------------------------------------- ������ ����������� ���-���
      Ord.accSing.recDoc:= 0;
      ibsOrd.Close;
      ibsOrd.ParamCheck:= False;
      ibsOrd.SQL.Clear;
      sQty:= StringReplace(FloatToStr(RoundTo(Ord.accSing.AccSumm, -2)), ',', '.', [rfReplaceAll]);
      if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
      ibsOrd.SQL.Add('execute block returns (RecCode integer) as begin RecCode=0;');
      ibsOrd.SQL.Add(' insert into OrdersClosingDocs (OCDOrderCode, OCDAccCode,'+
                     ' OCDAccNumber, OCDAccDate, OCDAccCrnc, OCDAccDprt, OCDAccSumm)');
      ibsOrd.SQL.Add(' values ('+sOrderID+', '+sAccID+',"'+Ord.accSing.Num+'", "'+
                     Ord.accSing.sDate+'",'+sCurrID+','+sDprtID+', '+sQty+')'+
                     ' returning OCDCODE into RecCode;');
      if (ord.accJoin.ID<1) then //---------- ���������� �������� ������ � �����
        ibsOrd.SQL.Add(' UPDATE ORDERSREESTR SET ORDRGBACCCODE='+sAccID+
                       ', ORDRGBACCNUMBER="'+Ord.accSing.Num+'",'+
                       fnIfStr(flSaveCont, ' ORDRCONTRACT='+sContID+',', '')+
                       ' ORDRGBACCTIME="NOW" WHERE ORDRCODE='+sOrderID+';');
      ibsOrd.SQL.Add(' suspend; end');
ErrPos:= '8';
      s1:= RepeatExecuteIBSQL(ibsOrd, 'RecCode', Ord.accSing.recDoc, accRepeatCount);
      if (s1<>'') or (Ord.accSing.recDoc<1) then
        ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+
          '������ ������ ������ ���-���, '+sDoc1+' '+Ord.accSing.Num+': '+s1;
      ibsOrd.ParamCheck:= True;
    end; //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ������ ���������� �����

    //------------------------------------------------------------ ������ ������
    if not ibsOrd.Transaction.InTransaction then ibsOrd.Transaction.StartTransaction;
    ibsOrd.SQL.Text:= ' UPDATE ORDERSREESTR SET ORDRSTATUS='+IntToStr(orstAccepted)+
                      ' WHERE ORDRCODE='+sOrderID;
    s1:= RepeatExecuteIBSQL(ibsOrd, accRepeatCount);
    if (s1<>'') then begin
      s:= '!!! ���� ��� ������ ������� ������ '+Ord.ORDRNUM;
      SaveErrStr:= fnIfStr(SaveErrStr='', '', SaveErrStr+#13#10)+s+
                   ', �������� ������������ ��������� �����.';
      ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+s+': '+s1;
    end;


//-------------------------------- �������� ������ � �������� / ���������� �����
    if CreateMail then begin
      s:= prSendMessAboutCreateAccount(Ord, ThreadData.ID, SaveErrStr);
      if (s<>'') then ErrorStr:= fnIfStr(ErrorStr='', '', ErrorStr+#13#10)+s;
    end; // if CreateMail

//---------------------------------------------------------------- ����� �������
    if (WaresErrMess<>'') then Result:= erWareToAccount; // ���� ���� ������ ��� ������ �������
  except
    on E: Exception do begin
      Result:= aeCommonError;
      WaresErrMess:= '������ ������ ���������.';
      ErrorStr:= ErrorStr+fnIfStr(ErrorStr='', '', #13#10)+E.Message;
    end;
  end;
  finally
    if (ErrorStr<>'') or (SaveErrStr<>'') then fnWriteToLogPlus(ThreadData,
      lgmsSysError, nmProc, ErrorStr, SaveErrStr, '����� '+Ord.ORDRNUM, false, 'error');
//      lgmsSysError, nmProc, ErrorStr, SaveErrStr, 'ErrPos= '+ErrPos, false, 'error');
    prFreeIBSQL(ibsGB);
    cntsGRB.SetFreeCnt(ibGB);
    prFreeIBSQL(ibsGBt);
    cntsGRB.SetFreeCnt(ibGBt);
    prFreeIBSQL(ibsOrd);
    cntsORD.SetFreeCnt(ibOrd);
    prFree(Ord.accSing.accLines);
    prFree(Ord.accJoin.accLines);
    prFree(Ord.olOrdWares);
  end;
  if flDebug then prMessageLOGS(nmProc+': '+GetLogTimeStr(LocalStart), fLogDebug, false); // ����� � log
end;

//================================ �������� ������� ���� ������ (def - EUR->UAH)
function GetRateCurr(crnc: Integer=cDefCurrency; crncTo: Integer=cUAHCurrency): Double;
var ibsGB: TIBSQL;
    ibGB: TIBDatabase;
begin
  Result:= 0;
  ibGB:= nil;
  ibsGB:= nil;
  try try
    ibGB:= cntsGRB.GetFreeCnt;
    ibsGB:= fnCreateNewIBSQL(ibGB, 'ibsOrd_GetRateCurr', -1, tpRead, True);
                       // ������������� 1.0 �� ����� ������ � ������
    ibsGB.SQL.Text:= 'select resultvalue from convertmoney (1.0, '+
                     IntToStr(crnc)+', '+IntToStr(crncTo)+', "TODAY")'+
                     ' where exists(select * from RateCrnc where RateCrncCode='+IntToStr(crnc)+')';
    ibsGB.Prepare;
    ibsGB.ExecQuery;
    if not (ibsGB.Bof and ibsGB.Eof) and not ibsGB.fields[0].IsNull then
      Result:= ibsGB.fields[0].AsFloat;
    ibsGB.Transaction.Rollback;
  except
    on E: Exception do prMessageLOGS('GetRateCurr: '+E.Message);
  end;
  finally
    prFreeIBSQL(ibsGB);
    cntsGRB.SetFreeCnt(ibGB);
  end;
end;
//=============================== ���������, �� ��������� �� ����� � �����������
function fnNotLockingLogin(Login: String): Boolean;
begin
  Result:= true;
  Login:= UpperCase(Login);
  if (Pos('ABUSE', Login)>0)    or (Copy(Login, 1, 3)='ADM')    or
     (Pos('EVERYONE', Login)>0) or (Pos('INPUT', Login)>0)      or
     (Pos('LIST', Login)>0)     or (Pos('MDAEMON', Login)>0)    or
     (Pos('ORDER', Login)>0)    or (Pos('POSTMASTER', Login)>0) or
     (Pos('SERVERMAIL', Login)>0) then Result:= false;
end;
//======================================== ������� ������ � LOG � ���-�� �� ����
function ToLog(vid: Integer): Boolean;
// ������ � ��������� LOG: 0- ��������� �������, 1- ���������� �������, 2- �������,
// 3- FormVladTables, 4- ����.��������, 5- ������ ������, 6- ��������� ���������,
// 7- ���������� ��������, 8- ������ ������ �������, 9- OrderToGB
// ������ � ib_ord: �������������� 10+x
begin
  Result:= vid in SaveToLog;
end;
//============================================================= ���� �����������
// ���� �������� �������� ������, ����� �������� "�� ����", ����� ������ ��� ������� ��� Resume
procedure GetLogKinds;
var pIniFile: TIniFile;
    ar: Tas;
    i, j: integer;
begin
  pIniFile:= TINIFile.Create(nmIniFileBOB);
  try
    ar:= fnSplitString(pIniFile.ReadString('Logs', 'SaveToLog', ''), ',');
    if (length(ar)>0) then for i:= Low(ar) to High(ar) do begin
      j:= StrToIntDef(ar[i], 0);
      if not (j in SaveToLog) then Include(SaveToLog, j);
    end;
  finally
    prFree(pIniFile);
    setLength(ar, 0);
  end;
end;

//******************************************************************************
//                       ������� ��������� ���������
//******************************************************************************
//============================================ ������ "��������� ��" CSS-�������
function GetMessageFromSelf: String;
begin
  Result:= FormatDateTime(cDateTimeFormatY2S, Now)+' Message from '+
           Application.Name+', '+fnGetComputerName+#10;
end;
//================================================ ��������� ��������� ���������
function n_SysMailSend(ToAdres, Subj: String; Body: TStrings=nil; Attachments: TStrings=nil;
         From: string =''; nmIniFile: string =''; flSaveToFile: boolean=False): string;
// ToAdres - ����� ����, Subj - ����, Body - ������ ���������, Attachments - ������ ������������� ������
// From - ����� �� ����, nmIniFile - ��� ini-�����
var IdSMTP0: TIdSMTP;
    MsgRecive0: TIdMessage;
    pIniFile: TIniFile;
    PlugMail, fname, dir, s: string;
    i, j: integer;
    AttErrors: TStringList;
    htmpart: TIdText;
begin
  Result:= '';
  AttErrors:= nil;
  if nmIniFile='' then nmIniFile:= nmIniFileBOB;
  while Cache.flMailSendSys do begin
    sleep(101); // ����, ���� ���� �������� ����.���������
    Application.ProcessMessages;
  end;
  try
    ToAdres:= trim(ToAdres);
    if (ToAdres='') or not fnCheckEmail(ToAdres) then
      raise Exception.Create('������������ �������� ToAdres='+ToAdres);
    pIniFile:= TINIFile.Create(nmIniFile);
    IdSMTP0:= TIdSMTP.Create(nil);
    MsgRecive0:= TIdMessage.Create(nil);
    Cache.flMailSendSys:= True;
    try
      IdSMTP0.AuthType:= satNone; // ��������� �����������
      IdSMTP0.ConnectTimeout:= 120000;
      IdSMTP0.Port:= pIniFile.ReadInteger('mail', 'SysPortTo', 0); // PortTo = 25
      if IdSMTP0.Port<1 then
        raise Exception.Create('������������ �������� SysPortTo='+pIniFile.ReadString('mail', 'SysPortTo', ''));
      IdSMTP0.Host:= pIniFile.ReadString('mail', 'SysHost', '');  // Host = 'gatenet'
      IdSMTP0.Username:= pIniFile.ReadString('mail', 'SysServerID', ''); // �����
      IdSMTP0.Password:= pIniFile.ReadString('mail', 'SysServerPW', ''); // ������
//      MsgRecive0.CharSet:= cCharSetUtf;
//      MsgRecive0.CharSet:= cCharSetKoi;  // ��������� ��� � Koi-8

      MsgRecive0.ContentType:= 'multipart/mixed';
      htmpart:= TIdText.Create(MsgRecive0.MessageParts, nil);
      htmpart.ContentType:= 'text/html; charset='+LowerCase(cCharSetWin);
      if Assigned(Body) then
        htmpart.Body.Text:= StringReplace(body.Text, #10, '<br>', [rfReplaceAll]);

      MsgRecive0.CharSet:= cCharSetWin;
      MsgRecive0.OnInitializeISO:= VSMail.OnInitISO;
      PlugMail:= pIniFile.ReadString('mail', 'PlugMail', ''); // �����-��������
      if PlugMail='' then begin
        MsgRecive0.Recipients.EMailAddresses:= ToAdres; // ������ "����"
        MsgRecive0.Subject:= Subj; // ����
      end else begin
        MsgRecive0.Recipients.EMailAddresses:= PlugMail; // ������ "����"
        MsgRecive0.Subject:= Subj+' (��� '+ToAdres+')'; // ����
      end;
      if (From='') then From:= pIniFile.ReadString('mail', 'SysAdresFrom', ''); // ����� "�� ����"
      i:= pos(',', From); //  ���� ������� � ����������� ��������� - ����� 1-�
      if i>0 then From:= copy(From, 1, i-1);
      MsgRecive0.From.Text:= From; // ����� "�� ����"

//      MsgRecive0.Date:= Now;
      MsgRecive0.UseNowForDate:= True;
      MsgRecive0.ExtraHeaders.Add(VSMail.Xstring);  // ������� ������ � ���������

      if Assigned(Attachments) and (Attachments.Count>0) then begin  // ����������� �����
        dir:= fnGetErrMailFilesDir;
        for i:= Attachments.Count-1 downto 0 do begin
          s:= Attachments[i];
          if not SysUtils.FileExists(s) then j:= -1
          else j:= GetFileSize(s) div (1024*1024);
          fname:= ExtractFileName(s);
          if (j<0) then begin                           // ���� �� ������
            s:= '�� ������ ��������� ���� '+fname;
            MsgRecive0.Body.Add(s);
            if not assigned(AttErrors) then begin
              AttErrors:= TStringList.Create;
              AttErrors.Add('��� �������� ������ �� E-mail '+ToAdres);
            end;
            AttErrors.Add(s);
            Attachments.Delete(i);
                                                        // ���� ������� �������
          end else if (j>Cache.GetConstItem(pcMaxAttFileSizeMB).IntValue) then begin
            s:= ' - �� ������� ���� '+fname+' (����� '+IntToStr(j)+' ��).';
//            MsgRecive0.Body.Add(s);
            htmpart.Body.Text:= htmpart.Body.Text+'<br>'+s;

            if RenameFile(Attachments[i], fnTestDirEnd(dir)+fname) then begin
              s:= ', ���� �������� ����� - '+IntToStr(Cache.GetConstItem(pcMailFilesStoringDays).IntValue)+' �����.';
              htmpart.Body.Text:= htmpart.Body.Text+'<br> - ���� ��������� � ����� '+fnGetComputerName+':'+dir+s;
              htmpart.Body.Text:= htmpart.Body.Text+'<br> ���� �� �� �������� ���� �� ��������, �������� ��������� ���������������';
              htmpart.Body.Text:= htmpart.Body.Text+'<br> ����� ����� � ����� �� ����� ������ � �������� � �������� ��� ����� �� ����.';
//              MsgRecive0.Body.Add(' - ���� ��������� � ����� '+fnGetComputerName+':'+dir+s);
//              MsgRecive0.Body.Add(' ���� �� �� �������� ���� �� ��������, �������� ��������� ���������������');
//              MsgRecive0.Body.Add(' ����� ����� � ����� �� ����� ������ � �������� � �������� ��� ����� �� ����.');
            end;
            Attachments.Delete(i);

          end else begin                                // ����������� ����
            TIdAttachmentFile.Create(MsgRecive0.MessageParts, Attachments[i]);
            sleep(101);
          end;
        end; // for i:= Attachments.Count-1 downto 0
      end;

      for i:= 1 to RepeatCount do // RepeatCount ������� �����������
        try
          Application.ProcessMessages;
          IdSMTP0.Connect; // ������������ � ��������� �������
          sleep(101);
          if IdSMTP0.Connected then break else raise Exception.Create(''); // ��������� �����������
        except
          on E: Exception do
            if i<RepeatCount then sleep(997)
            else raise Exception.Create('��� ����������� � '+IdSMTP0.Host+': '+E.Message);
        end;

      IdSMTP0.Send(MsgRecive0); // ���������� ������
      sleep(101);
    finally
      prFree(MsgRecive0);
      if Assigned(IdSMTP0) and IdSMTP0.Connected then IdSMTP0.Disconnect;
      prFree(IdSMTP0);
      prFree(pIniFile);
      Cache.flMailSendSys:= False;
    end;
  except
    on E: Exception do Result:= E.Message;
  end;

//------------------------------------------------------------------------------
  if (Result<>'') and flSaveToFile then try // ������ ������ ����� ������ � ����
    s:= '';
    if fnSaveMailStringsToFile(ToAdres, Subj, From, Body, Attachments, s) then
      Result:= Result+#13#10'  ������ �������� � ���� '+s
    else Result:= Result+#13#10'  '+MessText(mtkErrMailToFile)+' '+s;
  except end;
//------------------------------------------------------------------------------
  if assigned(AttErrors) then begin
    if AttErrors.Count>0 then begin
      prMessageLOGS('Error send files:');
      for i:= 0 to AttErrors.Count-1 do prMessageLOGS(AttErrors[i]);
      AttErrors.Insert(0, GetMessageFromSelf);
      s:= n_SysMailSend(fnGetSysAdresVlad(caeOnlyDayLess), 'Error send file', AttErrors, nil, '', '', flSaveToFile);
      if (s<>'') then prMessageLOGS('Error send mail to admins: '+s);  // ???
    end;
  end;
  prFree(AttErrors);
end;
//========================================== �������� ����������� ������ �������
procedure TestOldErrMailFiles;
var path: string;
    SearchRec: TSearchRec;
    cMailFilesStorDays: Integer;
begin
  try
    path:= fnGetErrMailFilesDir;
    if (FindFirst(path, faDirectory, SearchRec)<>0) then Exit;
    path:= path+PathDelim;
    cMailFilesStorDays:= Cache.GetConstItem(pcMailFilesStoringDays).IntValue;
    try                                       // ���� ����� rep*.zip - ������
      if (FindFirst(path+'rep*.zip', faAnyFile, SearchRec)=0) then repeat
        if ((Now-SearchRec.TimeStamp)>cMailFilesStorDays) then // ���� ���� �������� cMailFilesStorDays ����� - �������
          DeleteFile(path+SearchRec.Name);
        Application.ProcessMessages;
      until FindNext(SearchRec)<>0;
    except
      on E: Exception do if (E.Message<>'') then prMessageLOGS('TestOldMailFiles: '+E.Message);
    end;
  finally
    FindClose(SearchRec);
  end;
end;
//=============================================================== Email �������
function fnGetManagerMail(code: Integer; Mailelse: String): String;
begin
  if Cache.DprtExist(code) and (Cache.arDprtInfo[code].MailOrder<>'') then
    Result:= Cache.arDprtInfo[code].MailOrder
  else Result:= Mailelse;
end;
//================================================ ���������� ����� ��� ��������
function fnGetActionTimeEnable(kind: integer=caeOnlyDay): Boolean;
var h, dw: integer;
begin
  Result:= True;
  h:= HourOfTheDay(Now);  // HourOfTheDay returns a value between 0 and 23
  dw:= DayOfTheWeek(Now); // DayOfTheWeek returns a value between 1 and 7, where 1 indicates Monday and 7 indicates Sunday.
  case kind of
    caeOnlyDay: Result:= (h in [8..18]);     // ������ ���� - ����� � 8 �� 19
    caeOnlyDayLess:                          // ������ ���� � �� �������� ��������
      if (dw in [DaySaturday, DaySunday]) then Result:= (h in [9..17]) // �� �������� ����� � 9 �� 18
      else Result:= (h in [8..18]);                                     // � ���.��� ����� � 8 �� 19
    caeOnlyWorkDay:                          // ������ ���� � ������� ���
      Result:= not (dw in [DaySaturday, DaySunday]) and (h in [8..18]);
    caeOnlyWorkTime:                         // ������ � ������� ����� - ��-�� � 9 �� 18
      Result:= not (dw in [DaySaturday, DaySunday]) and (h in [9..17]);
    caeSmallWork:                            // ������ � ������� ����� �������� �������
//      if flDebug then Result:= True else                        // debug
      if (dw=DaySunday) then Result:= True                      // �� ������������
      else if (dw=DaySaturday) then Result:= not (h in [9..16]) // �� �� �������� � 9 �� 17
      else Result:= not (h in [9..17]);                         // �� � ���.��� � 9 �� 18
    caeTechWork:  // ������ ���.�����
      Result:= (h in [0..fnIfInt((dw=DaySunday), 7, 4), 23]);
  end;
end;
//==================================================== ������ ��� ����.���������
function fnGetSysAdresVlad(kind: integer=caeOnlyDay): string;
var s, s1: string;
    ar: Tas;
    i: integer;
begin
  Result:= '';
  s:= GetIniParam(nmIniFileBOB, 'mail', 'SysAdresVlad');
  ar:= fnSplitString(s, ',');
  for i:= Low(ar) to High(ar) do begin
    if (pos('@sms.', ar[i])<1) then s1:= ar[i]
    else if fnGetActionTimeEnable(kind) then s1:= ar[i] else s1:= ''; // �������� ������ ��� SMS
    if s1<>'' then Result:= Result+fnIfStr(Result='', '', ',')+s1;
  end;
  setLength(ar, 0);
end;

//******************************************************************************
//              ������� �������� ��������� ��������� �� ������
//******************************************************************************
//============================================ ������ ������ ����� ������ � ����
function fnSaveMailStringsToFile(ToAdres, Subj, From: String;
         Body, Attachments: TStrings; var FileName: String): Boolean;
var FileHandle, i: integer;
    s, file_block, ex: string;
    list: TStringList;
begin
  Result:= False;
  list:= TStringList.Create; // ��������� ����� ����� ��� ������ � ����
  try
    if Assigned(Body) then list.AddStrings(Body); // ����� ���� ������
    list.Insert(0, ToAdres);  // ��������� ������ � ������� ����
    list.Insert(1, Subj);     // ��������� ������ � �����
    if From='' then From:= 'no'; // �� ����� ������ ����� ��� ����������� ����������
    list.Insert(2, From);     // ��������� ������ � ������� �� ����

    if Assigned(Attachments) and (Attachments.Count>0) then begin // ���� ���� ����������� ����� - ���������������
      s:= fnGetMailFilesPath+'att';                // ����� ������.������ ��� ����� �� ������
      if not DirectoryExists(s) then CreateDir(s); // ���� ��� ����� - �������
      for i:= 0 to Attachments.Count-1 do begin
        file_block:= fnTestDirEnd(s)+ExtractFileName(Attachments.Strings[i]); // ����� ��� �����
        FileHandle:= 0;
        ex:= ExtractFileExt(file_block); // ���������� �����
        while FileExists(file_block) do begin // ��������� ������������ ����� ����� � �����
          inc(FileHandle);
          file_block:= copy(file_block, 1, pos(ex, file_block)-1)+'_'+IntToStr(FileHandle)+ex;
        end;
        RenameFile(Attachments.Strings[i], file_block); // ��������� ���� ??? ��� ��������
        Attachments.Strings[i]:= file_block;           // ������������ � Attachments
      end;
      s:= Attachments.CommaText;
    end else s:= 'no'; // �� ����� ������ ����� ��� ����������� ����������
    list.Insert(3, s);  // ��������� ������ � ������� ����������� ������

    FileHandle:= -1;
    if FileName='' then s:= fnGenRandString(6) else s:= FileName;
    FileName:= PrefixMailFile+s+ExtMailFile; // ��� ����� ������
    s:= fnGetMailFilesPath+FileName;         // ������ ��� �����

    for i:= 1 to RepeatCount do try
      while FileExists(s) do begin  // ��������� ������������ ����� �����
        s:= fnGenRandString(6, true);
        FileName:= PrefixMailFile+s+ExtMailFile; // ��� ����� ��� ������
        s:= fnGetMailFilesPath+FileName;         // ������ ��� �����
      end;

      file_block:= fnGetLockFileName(s); // ���� ���������� (������ �� ����� ������)
      try
        FileHandle:= fnTestFileCreate(file_block); // ������� ���� ����������
        Result:= fnStringsLogToFile(list, s); // ������ ������ ����� ������ � ����
      except end;

      if (FileHandle>-1) then DeleteFile(file_block); // ������� ���� ����������
      if Result then break;
    except end;
  finally
    prFree(list);
  end;
end;
//========================================================== ���� � ������ �����
function fnGetMailFilesPath: String;
begin
  Result:= GetAppExePath+DirMailFiles;     // ������ ��� �����
  if not DirectoryExists(Result) then CreateDir(Result); // ���� ��� - �������
  Result:= fnTestDirEnd(Result);                         // ����
end;
//============================================== ����� � ��������������� �������
function fnGetErrMailFilesDir: String;
begin
  Result:= fnGetMailFilesPath+'err';
  if not DirectoryExists(Result) then CreateDir(Result); // ���� ����� ��� - �������
end;
//========================================================= ��� ����� ����������
function fnGetLockFileName(FileName: String): String;
begin
  Result:= ChangeFileExt(FileName, '.lck'); // ������ ����������
end;
//======================================================= ��������� ������������
function MessText(kind: TMessTextKind; str: string=''): String;
begin
  case kind of
    mtkNotValidLogin   : Result:= '����� ������ ����� ����� �� 5 �� '+fnIfStr(str='', '20', str)+' �������� � �������� ������ �� ���� � ��������� ����.';
    mtkNotValidPassw   : Result:= '������ ������ ����� ����� �� 5 �� '+fnIfStr(str='', '20', str)+' �������� � �������� ������ �� ���� � ��������� ����.';
    mtkNotRightExists  : Result:= '� ��� ��� ���� �� ���������� ���� ��������.'; // not ...Empl...UserRoleExists
    mtkNotClientOfFirm : Result:= '������������ �� ��������� � ����� ����������� ��� �����������.'; // Client...FirmID<>FirmID
    mtkErrorUserID     : Result:= '������������ ��� ������������.';
    mtkNotFoundWares   : Result:= '�� ������� ������';
    mtkNotFoundWaresSem: Result:= '�� ������� ������ � ������� �� ������';
    mtkNotFoundRecord  : Result:= '�� ������� ������ ��� ��������������.';
    mtkNotFoundData    : Result:= '��� ������.';
    mtkEmptySysName    : Result:= '�� ������ ��������� ������������.';
    mtkNotParams       : Result:= '�� ������ ���������.';
    mtkNotEnoughParams : Result:= '�� ������� ����������';
    mtkNotValidParam   : Result:= '������������ ��������';
    mtkNotChanges      : Result:= '��� ���������.';
    mtkErrEditRecord   : Result:= '������ ��������� ������ � ���� ������.';
    mtkErrAddRecord    : Result:= '������ ���������� ������ � ���� ������.';
    mtkErrDelRecord    : Result:= '������ �������� ������ �� ���� ������.';
    mtkErrProcess      : Result:= '������ ����������.';
    mtkErrConnectToDB  : Result:= '������ ����������� � ���� ������.';
    mtkModelNodeLink   : Result:= '����� ������ � �����';
    mtkWareModNodeLink : Result:= '����� ������ � ������� � �����';
    mtkWareAttrValue   : Result:= '�������� �������� ������';
    mtkExitBySuspend   : Result:= '�������� ������� �� ������� Suspend';
    mtkErrCopyFile     : Result:= '������ ����������� � ���� ';
    mtkCommonErrorText : Result:= '������ �� ������� ������� ';
    mtkFuncNotAvailabl : Result:= '������� ����������';
    mtkWareModNodeUse  : Result:= '������� ���������� ������ � ������ � ����';
    mtkWareModNodeUses : Result:= '����� ������� ���������� ������ � ������ � ����';
    mtkWareArticleLink : Result:= '����� ������ � ���������';
    mtkWareOrNumLink   : Result:= '����� ������ � ������������ �������';
    mtkWareModNodeText : Result:= '����� ������ � �������, ������� � �����';
    mtkWareModNodeTexts: Result:= '����� ������ ������� � �������, ������� � �����';
    mtkRegOrdAddOrAnn  : Result:= '������ ��� ������� ��� ������������.';
    mtkRegOrdNotYourFil: Result:= '������ �� ��������� � ������ �������.';
    mtkNotFoundRegOrd  : Result:= '�� ������� ������.';
    mtkNotSetLogin     : Result:= '�� ����� �����.';
    mtkErrFormTmpPass  : Result:= '������ ������������ ���������� ������.';
    mtkNotSetRegion    : Result:= '�� ����� ������.';
    mtkNotFoundNodes   : Result:= '�� ������� ����';
    mtkErrMailToFile   : Result:= '������ ������ ������ � ����';
    mtkMailWillSend    : Result:= '!!!  ��������� �������� � ����� ���������� �����.';
    mtkLockingLogin    : Result:= '����� `'+str+'` ��� ��������������� � �������.';        // not fnNotLockingLogin
    mtkNotFoundFile    : Result:= '�� ������ ���� ';
    mtkNotFoundOrNum   : Result:= '�� ������ ������������ �����';
    mtkNotEmplExist    : Result:= '�� ������ ���������'+fnIfStr(str='', '.', ', ��� - '+str);         // not EmplExist(
    mtkNotFoundEmplMail: Result:= '�� ������ E-mail ���������� '+str;
    mtkNotClientExist  : Result:= '�� ������ ������������'+fnIfStr(str='', '.', ', ��� - '+str);      // not ClientExist(
    mtkNotFirmExists   : Result:= '�� ������ ����������'+fnIfStr(str='', '.', ', ��� - '+str);        // not FirmExist(
    mtkNotFoundFirmCont: Result:= '�� ������ �������� �����������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundFirms   : Result:= '�� ������� �����������.';
    mtkNotDprtExists   : Result:= '�� ������� �������������'+fnIfStr(str='', '.', ', ��� - '+str);    // not DprtExist(
    mtkNotFoundTypeSys : Result:= '�� ������� ������� �����'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundModel   : Result:= '�� ������� ������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundModLine : Result:= '�� ������ ��������� ���'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundManuf   : Result:= '�� ������ �������������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundNode    : Result:= '�� ������ ����'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundWare    : Result:= '�� ������ �����'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundAttGr   : Result:= '�� ������� ������ ���������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundOrder   : Result:= '�� ������ �����'+fnIfStr(str='', '', ', ��� - '+str);
    mtkNotFoundOrders  : Result:= '�� ������� ������';
    mtkNotFoundCont    : Result:= '�� ������ ��������'+fnIfStr(str='', '', ', ��� - '+str);
    mtkContNotAvailable: Result:= '�������� ����������'+fnIfStr(str='', '', ', ��� - '+str);
    mtkNotFoundAvaiCont: Result:= '�� ������ ��������� ��������';
    mtkEmptyName       : Result:= '�� ������ ������������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotEditOrder    : Result:= '����� ������ �������������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotProcOrder    : Result:= '����� ������ ��������� �� ���������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotSysManuf     : Result:= '������������� �� ��������� � �������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkDuplicateName   : Result:= '� ������� ��� ���� ������������ '+fnIfStr(str='', '', QuotedStr(str));
    mtkDuplicateSysNm  : Result:= '� ������� ��� ���� ��������� ������������ '+fnIfStr(str='', '', QuotedStr(str));
    mtkNotFirmProcess  : Result:= '��������� �������� �� ����������� '+str+' �������������.';
    mtkNotLoginProcess : Result:= '��������� �������� �� ������ '+str+' �������������.';
    mtkBlockCountLogin : Result:= '��������� �������� �� ������ '+str+' ������������� ��-�� ���������� ������ ��������.';
    mtkErrSendMess     : Result:= '������ �������� ���������'+fnIfStr(str='', '.', ' '+str);
    mtkSpecifyInquiry  : Result:= '�� ������ ������� ������� ������� ����� �������. ����������, �������� ������.';
    mtkNotFoundEngine  : Result:= '�� ������ ���������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkFuncNotEnable   : Result:= '������� �������� ����������.';
    mtkNotManagerMail  : Result:= '�� ������ ����� ��������� '+fnIfStr(str='', '.', ' '+str);
    mtkNotCreateDir    : Result:= '���������� ������� �����'+fnIfStr(str='', '', ' '+str)+'.';
    mtkNotDelPrevFile  : Result:= '���������� ������� ���������� ����.';
    mtkEndDateMoreBegin: Result:= '��������� ���� ������ ��������!';
    mtkNotEndDateMore  : Result:= '�������� ���� ������ �� ����� ���� ������ ��� '+str;
    mtkNotFoundBrand   : Result:= '�� ������ �����'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundBrandWar: Result:= '�� ������� ������ ����� ������.';
    mtkImportError     : Result:= '��� ������� ���� ���������� ������. �������� �����!';
    mtkImportSuccess   : Result:= '��� ������ ���������.';
    mtkNotFoundDataUse : Result:= '��� ������ �� ��������� ��������.';
    mtkWareAnalogLink  : Result:= '����� ������ � ��������';
    mtkWareSatelLink   : Result:= '����� ������ � ������������� �������';
    mtkOnlyFormingOrd  : Result:= '�������� �������� ������ ��� ������� �� �������� '+arOrderStatusNames[orstForming];
    mtkUnknownSysType  : Result:= '����������� ��� �������'+fnIfStr(str='', '.', ', ��� - '+str);
    mtkNotFoundDocum   : Result:= '�� ������ ��������'+fnIfStr(str='', '.', ', ��� - '+str);
  end;
end;                                     // MessText(mtkNotFoundDocum, )
//================================================ ������ � Stream ���� � ������
procedure prSaveShortWareInfoToStream(Stream: TBoBMemoryStream; ffp: TForFirmParams;
          WareID: integer; AnalogsCount: integer=0; SatellsCount: integer=0;
          RestSem: integer=-1; RestTitle: String=''; ModelsEx: Boolean=True);
const nmProc = 'prSaveShortWareInfoToStream'; // ��� ���������/�������
var ware: TWareInfo;
    sMargin, sBonus, ActTitle, ActText: string;
    bon: double;
    prices: TDoubleDynArray;
    i, iCode, aCode: Integer;
    flag: Boolean;
begin
  try
    ware:= Cache.GetWare(WareID);
    Stream.WriteInt(WareID);             // ��� ������

    iCode:= ware.AttrGroupID;
    if (iCode<1) then begin
      iCode:= ware.GBAttGroup;
      if (iCode>0) then iCode:= iCode+cGBattDelta;
    end;
    Stream.WriteInt(iCode);   // ������ ���������

    Stream.WriteInt(AnalogsCount);        // ���-�� ��������
    Stream.WriteInt(SatellsCount);        // ���-�� �����.�������
    Stream.WriteStr(ware.WareBrandName);  // �����
    Stream.WriteStr(ware.BrandNameWWW);   // ����� ��� ����� ��������
    Stream.WriteStr(ware.BrandAdrWWW);    // ����� ������ �� ���� ������
    Stream.WriteStr(ware.Name);           // ������������
    Stream.WriteBool(ware.IsSale);        // ������� ����������
    Stream.WriteBool(ware.IsNonReturn);   // ������� ����������
    Stream.WriteBool(ware.IsCutPrice);    // ������� ������
    Stream.WriteStr(Ware.PrDirectName);   // �������� ����������� �� ���������
    Stream.WriteStr(ware.MeasName);       // ��.���.
    Stream.WriteDouble(Ware.divis);       // ��������� ������� ������

    aCode:= Ware.GetActionParams(ActTitle, ActText);
    Stream.WriteInt(aCode);         // ��� �����
    Stream.WriteStr(ActTitle);      // ���������
    Stream.WriteStr(ActText);       // �����

    Stream.WriteInt(RestSem); // ������� ��������: 0- �������, 1- ������, 2- �������, 3- ����.�������, ������ - ���

if flSpecRestSem then
    Stream.WriteStr(RestTitle); // ��������� ��� ����.��������

    Stream.WriteInt(4); // ���-�� ������ �����

    Stream.WriteInt(constIsAuto); // ��� ������� ����� AUTO
    flag:= ModelsEx and ware.SysModelsExists(constIsAuto);
    Stream.WriteBool(flag); // ������� ������� ������� AUTO

    Stream.WriteInt(constIsMoto); // ��� ������� ����� MOTO
    flag:= ModelsEx and ware.SysModelsExists(constIsMoto);
    Stream.WriteBool(flag); // ������� ������� ������� MOTO

//------------------------------------ ��������� ��������� � ���
    Stream.WriteInt(constIsCV); // ��� ������� ����� ����������
    flag:= ModelsEx and ware.SysModelsExists(constIsCV);
    Stream.WriteBool(flag); // ������� ������� ������� ����������

    Stream.WriteInt(constIsAx); // ��� ������� ����� ����
    flag:= ModelsEx and ware.SysModelsExists(constIsAx);
    Stream.WriteBool(flag); // ������� ������� ������� ����

    sMargin:= '0';
    sBonus:= '0';
//----------------- ���� ������� (0- �������, 1- �� �������, 2- �� ����.�������)
    if ware.IsINFOgr then begin
      for i:= 0 to High(arPriceColNames) do
        Stream.WriteStr(trim(FormatFloat(cFloatFormatSumm, 0)));
    end else begin
      prices:= ware.CalcFirmPrices(ffp);  // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
      for i:= 0 to High(prices) do Stream.WriteStr(trim(FormatFloat(cFloatFormatSumm, prices[i])));
      if (ffp.currID>0) then begin
        if ffp.ForClient and (ffp.currID<>Cache.BonusCrncCode) then // ���� ������ � �������� (% � ���������) ��� �������
          sMargin:= trim(FormatFloat(cFloatFormatSumm, prices[0]));
//          sMargin:= trim(FormatFloat(cFloatFormatSumm, ware.MarginPrice(ffp)));

        if not fnNotZero(ffp.rate) then
          prices:= ware.CalcFirmPrices(ffp.ForFirmID, cDefCurrency, ffp.contID);
        bon:= prices[1]*Cache.GetPriceBonusCoeff(ffp.currID);
        sBonus:= trim(FormatFloat(cFloatFormatSumm, bon)); // ����� (�� unit-�����)
      end;
    end;
    Stream.WriteStr(sMargin);         // ���� � ��������
    Stream.WriteStr(sBonus);          // ������ (�� unit-�����)
    Stream.WriteStr(ware.CommentWWW); // �������� ������ ��� Web � ������ ���� ������
  except
    on E: Exception do raise Exception.Create(nmProc+': '+E.Message);
  end;
  SetLength(prices, 0);
end;
//======================= ������ � Stream ���� � ������ (����� �� prGetWareList)
procedure prSaveShortWareInfoToStream(Stream: TBoBMemoryStream; WareID, FirmID, UserID: integer;
          AnalogsCount: integer=0; currID: Integer=0; ForFirmID: integer=0; SatellsCount: integer=0;
          contID: integer=0; RestSem: integer=-1; RestTitle: String=''; ModelsEx: Boolean=True);
const nmProc = 'prSaveShortWareInfoToStream'; // ��� ���������/�������
var ware: TWareInfo;
    sMargin, sBonus, ActTitle, ActText: string;
    rate, bon: double;
    prices: TDoubleDynArray;
    i, iCode, aCode: Integer;
    arSys: Tai;
    flag: Boolean;
begin
  try
    ware:= Cache.GetWare(WareID);
    Stream.WriteInt(WareID);             // ��� ������

    iCode:= ware.AttrGroupID;
    if (iCode<1) then begin
      iCode:= ware.GBAttGroup;
      if (iCode>0) then iCode:= iCode+cGBattDelta;
    end;
    Stream.WriteInt(iCode);   // ������ ���������

    Stream.WriteInt(AnalogsCount);       // ���-�� ��������
    Stream.WriteInt(SatellsCount);       // ���-�� �����.�������
    Stream.WriteStr(ware.WareBrandName); // �����
    Stream.WriteStr(ware.BrandNameWWW);  // ����� ��� ����� ��������
    Stream.WriteStr(ware.BrandAdrWWW);   // ����� ������ �� ���� ������
    Stream.WriteStr(ware.Name);          // ������������
    Stream.WriteBool(ware.IsSale);       // ������� ����������
    Stream.WriteBool(ware.IsNonReturn);  // ������� ����������
    Stream.WriteBool(ware.IsCutPrice);   // ������� ������
    Stream.WriteStr(Ware.PrDirectName);  // �������� ����������� �� ���������
    Stream.WriteStr(ware.MeasName);      // ��.���.
    Stream.WriteDouble(Ware.divis);      // ��������� ������� ������

    aCode:= Ware.GetActionParams(ActTitle, ActText);
    Stream.WriteInt(aCode);         // ��� �����
    Stream.WriteStr(ActTitle);      // ���������
    Stream.WriteStr(ActText);       // �����

    Stream.WriteInt(RestSem); // ������� ��������: 0- �������, 1- ������, 2- �������, 3- ����.�������, ������ - ���

if flSpecRestSem then
    Stream.WriteStr(RestTitle);     // ��������� ��� ����.��������

//    Stream.WriteInt(2); // ���-�� ������ ����� (� Webarm ���������� 2 �������)  ???
    Stream.WriteInt(constIsAuto); // ��� ������� ����� AUTO
    flag:= ModelsEx and ware.SysModelsExists(constIsAuto);
    Stream.WriteBool(flag); // ������� ������� ������� AUTO

    Stream.WriteInt(constIsMoto); // ��� ������� ����� MOTO
    flag:= ModelsEx and ware.SysModelsExists(constIsMoto);
    Stream.WriteBool(flag); // ������� ������� ������� MOTO

// �������� ��������� � ��� (���� � Webarm ���������� 2 �������)  ???
{//------------------------------------ ��������� ��������� � ���
    Stream.WriteInt(constIsCV); // ��� ������� ����� ����������
    flag:= ModelsEx and ware.SysModelsExists(constIsCV);
    Stream.WriteBool(flag); // ������� ������� ������� ����������

    Stream.WriteInt(constIsAx); // ��� ������� ����� ����
    flag:= ModelsEx and ware.SysModelsExists(constIsAx);
    Stream.WriteBool(flag); // ������� ������� ������� ����  }

    if not Cache.CurrExists(currID) then // ���������� ������, ���� ��� �� ������
      if (FirmId=IsWe) then currID:= 0
      else if CheckNotValidUser(UserID, FirmID, sBonus) then currID:= 0  // ����� sBonus - ��������
      else currID:= Cache.arClientInfo[UserID].SEARCHCURRENCYID; // ����� ������ �� �������� ������������

    if (FirmId<>IsWe) or (ForFirmID<1) then ForFirmID:= FirmID; // �/� ��� ������
    sMargin:= '0';
    sBonus:= '0';
//------------------------------------------------- ���� �������
    if ware.IsINFOgr then begin
      for i:= 0 to High(arPriceColNames) do
        Stream.WriteStr(trim(FormatFloat(cFloatFormatSumm, 0)));
    end else begin
      prices:= ware.CalcFirmPrices(ForFirmID, currID, contID); // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
      for i:= 0 to High(prices) do
        Stream.WriteStr(trim(FormatFloat(cFloatFormatSumm, prices[i])));
      if (currID>0) then begin
                             // ���� ������ � �������� (% � ���������) ��� �������
        if (FirmId<>IsWe) and (currID<>Cache.BonusCrncCode) then
          sMargin:= trim(FormatFloat(cFloatFormatSumm, prices[0]));
//          sMargin:= trim(FormatFloat(cFloatFormatSumm, ware.MarginPrice(ForFirmID, UserID, currID, contID)));

        rate:= Cache.Currencies.GetCurrRate(currID);    // ???
        if not fnNotZero(rate) then prices:= ware.CalcFirmPrices(ForFirmID, cDefCurrency, contID);
        bon:= prices[1]*Cache.GetPriceBonusCoeff(currID);
        sBonus:= trim(FormatFloat(cFloatFormatSumm, bon)); // ����� (�� unit-�����)
      end;
    end;
    Stream.WriteStr(sMargin);         // ���� � ��������
    Stream.WriteStr(sBonus);          // ������ (�� unit-�����)
    Stream.WriteStr(ware.CommentWWW); // �������� ������ ��� Web � ������ ���� ������
  except
    on E: Exception do raise Exception.Create(nmProc+': '+E.Message);
  end;
  SetLength(prices, 0);
  SetLength(arSys, 0);          // ������ �������
end;
//========= ������ � Stream ����� ��������� ������� ������� (����� ������ � Web)
procedure prSaveWareRestsExists(Stream: TBoBMemoryStream; ffp: TForFirmParams; wCodes: Tai);
const nmProc = 'prSaveWareRestsExists'; // ��� ���������/�������
var iCount, i, iSem, iPos: integer;
    sArrive: String;
begin
  if not Assigned(wCodes) then SetLength(wCodes, 0);
  iCount:= 0;
  try
    iPos:= Stream.Position;
    Stream.WriteInt(iCount);

    if not ffp.ForClient then Exit; // �� ���� ���������� ��� ForFirmID<1
    if not Cache.FirmExist(ffp.ForFirmID)
      or not Assigned(wCodes) or (Length(wCodes)<1) then Exit; // ��� �������
    ffp.FillStores;

    for i:= 0 to High(wCodes) do if (wCodes[i]>0) and Cache.WareExist(wCodes[i])
      and Cache.GetWare(wCodes[i]).IsMarketWare(ffp.ForFirmID, ffp.contID) then begin
      iSem:= GetContWareRestsSem(wCodes[i], ffp, sArrive);

      Stream.Writeint(wCodes[i]);
      Stream.Writeint(iSem);

if flSpecRestSem then
      Stream.WriteStr(sArrive); // ��������� � �������� (���� ������ � 3)

      Inc(iCount);
    end;
    if (iCount>0) then begin
      Stream.Position:= iPos;
      Stream.Writeint(iCount);
      Stream.Position:= Stream.Size;
    end;
  except
    on E: Exception do raise Exception.Create(nmProc+': '+E.Message);
  end;
end;
//======================== �������� ���� ������� ��������� � ��� �������� ������
function fnGetContMainStoreAndStoreCodes(FirmID, ContID: Integer; var StorageCodes: Tai): Integer;
const nmProc = 'fnGetContMainStoreAndStoreCodes'; // ��� ���������/�������
var Contract: TContract;
begin
  Result:= 0;
  SetLength(StorageCodes, 0);
  if not Cache.FirmExist(FirmID) then Exit;
  Contract:= Cache.arFirmInfo[FirmID].GetContract(ContID);
  Result:= Contract.MainStorage;
  StorageCodes:= Contract.GetContVisStoreCodes;
end;
//============================ �������� ��������� ������� ������� (Web & WebArm)
procedure prCheckWareRestsExists(ffp: TForFirmParams; var OLmarkets: TObjectList; var RestCount: Integer);
const nmProc = 'prCheckWareRestsExists'; // ��� ���������/�������
var i: integer;
    tc: TTwoCodes;
begin
  if not Assigned(OLmarkets) then Exit;
  RestCount:= 0;
  try
    if not ffp.ForClient  // �� ���� ���������� ��� ForFirmID<1
      or not Cache.FirmExist(ffp.ForFirmID) or (OLmarkets.Count<1) then Exit; // ��� �������
    ffp.FillStores;

    for i:= 0 to OLmarkets.Count-1 do begin
      tc:= TTwoCodes(OLmarkets[i]);
      tc.ID2:= GetContWareRestsSem(tc.ID1, ffp, tc.Name);
      if (tc.ID2>0) then Inc(RestCount);
    end; // for i:= 0 to OLmarkets.Count-1
  except
    on E: Exception do raise Exception.Create(nmProc+': '+E.Message);
  end;
end;
//============ ������ � Stream ������ ������� ���������� �/� ��� ������ (WebArm)
procedure prSaveEmplFirmsChoiceList(Stream: TBoBMemoryStream; EmplID: Integer);
const nmProc = 'prSaveEmplFirmsChoiceList'; // ��� ���������/�������
var i, j, k, jj, ind0, ii: integer;
    firm: TFirmInfo;
    lst: TList;  // not Free !!! ������ ���� ��������� ����
    arLst: array of TList;
    lstf: TStringList; // ������ ��������
//    empl: TEmplInfoItem;
//    flAllFirms: Boolean;
begin
  SetLength(arLst, 0);
  lst:= nil;
  lstf:= nil;
  if not Cache.EmplExist(EmplID) then raise EBOBError.Create(MessText(mtkNotEmplExist));

//  empl:= Cache.arEmplInfo[EmplID];                      // ��� �.� - ��� + ���
//  flAllFirms:= empl.UserRoleExists(rolOPRSK) or empl.UserRoleExists(rolUiK)
//                or empl.UserRoleExists(rolWorkWithOrders); // + ������ � �������� (��)
  try
//    if flAllFirms then begin // ��� �/�
    lst:= TList.Create;
    for i:= 1 to High(Cache.arFirmInfo) do if Cache.FirmExist(i) then begin
      firm:= Cache.arFirmInfo[i];
      if firm.Arhived then Continue;
//      lst.Add(TLink.Create(0, firm));
      lst.Add(firm);
    end;
    lst.Sort(DirNameSortCompare); // ��������� �� ������������
//    lst.Sort(LinkNameSortCompare); // ��������� �� ������������
//    end else
//      lst:= Cache.GetEmplVisFirmLinkList(EmplID);  // not Free !!! ����� ����� ��� ������������� �� ������������
    if (lst.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundFirms));
    try
      lstf:= Cache.GetFilialList(False);   // False - ������ ������������
      lstf.Sort;          // ��������� ������� �� ������������

      ind0:= lstf.Count;
      SetLength(arLst, ind0+1); // ������� ����� ������� (+1 ��� ������������)
      for i:= 0 to High(arLst) do arLst[i]:= TList.Create;
      k:= 0;  // ��� �������
      j:= -1; // ������ ����� �������
      for i:= 0 to lst.Count-1 do begin // ������ ��������� ����� �� ��������
//        firm:= GetLinkPtr(lst[i]);
        firm:= lst[i];
        jj:= firm.GetDefContract.Filial;
        if (k<>jj) then begin
          k:= jj;
          j:= lstf.IndexOfObject(Pointer(k));
        end;
        if (j>-1) then arLst[j].Add(firm)  // ������� ������ �� ����� � ���� �������
        else arLst[ind0].Add(firm);        // ������� ������ �� ����� � ���� ������������
  {if flDebug then
        if (pos('��������������', firm.Name)>0) then begin
          prMessageLOGS('---------- firm.Name  : '+firm.Name, fLogCache);
          prMessageLOGS('---------- firm.ID    : '+IntToStr(firm.ID), fLogCache);
          prMessageLOGS('---------- firm.Filial: '+IntToStr(jj), fLogCache);
          prMessageLOGS('---------- index      : '+IntToStr(j), fLogCache);
        end;  }
      end;

      if (arLst[ind0].Count>0) then begin // ��������� ��������� ������
        lstf.AddObject('������ �� ���������', Pointer(0));
      end else begin
        arLst[ind0].Free;
        SetLength(arLst, ind0); // ������� ���� ��� ������������
      end;

      Stream.WriteInt(lstf.Count);    // �������� ������ ���� ��������
      for i:= 0 to lstf.Count-1 do begin
        Stream.WriteInt(Integer(lstf.Objects[i]));  // ��� �������
        Stream.WriteStr(lstf[i]);                   // ������.
      end;

      k:= Stream.Position;
      Stream.WriteInt(lst.Count); // ���-�� ����
      jj:= 0; // ������� (��� ����������)
      for i:= 0 to lstf.Count-1 do begin
        ii:= Integer(lstf.Objects[i]); // ��� �������
//  if flDebug then prMessageLOGS('---------- filial '+IntToStr(ii)+': '+lstf[i]+' '+IntToStr(arLst[i].Count)+' firms', fLogDebug, false);
        for j:= 0 to arLst[i].Count-1 do begin // �������� �����
          firm:= arLst[i][j];
          Stream.WriteInt(firm.ID);             // ��� �����
          Stream.WriteInt(ii);                  // ��� �������
          Stream.WriteStr(firm.UPPERSHORTNAME); // ������� ������.
          Stream.WriteStr(firm.Name);           // ������ ������.
  //if flDebug then prMessageLOGS('----- firm'+IntToStr(firm.ID)+': '+firm.UPPERSHORTNAME+' '+firm.Name, fLogDebug, false);
          inc(jj);
        end;
      end;
      if jj<>lst.Count then begin // ���� ������� ���-�� �� ��
        Stream.Position:= k;
        Stream.WriteInt(jj); // �������� ���-��
        Stream.Position:= Stream.Size;
      end;
    except
      on E: EBOBError do raise EBOBError.Create(E.Message);
      on E: Exception do raise Exception.Create(nmProc+': '+E.Message);
    end;
  finally
    for i:= 0 to High(arLst) do prFree(arLst[i]);
    SetLength(arLst, 0);
    prFree(lstf);
//    if flAllFirms then begin
//      for i:= 0 to lst.Count-1 do TLink(lst[i]).Free;
    prFree(lst);
//    end;
  end;
end;
//====================================== ������ � Stream ������ �������(+�����),
//======================================= ������� ���������� ��� ������ (WebArm)
procedure prSaveEmplStoresChoiceList(Stream: TBoBMemoryStream; EmplID: Integer; flWithRoad: Boolean=False);
const nmProc = 'prSaveEmplStoresChoiceList'; // ��� ���������/�������
// flWithRoad=False - ������ ������, flWithRoad=True - ������ + ����
var i, k, jj: integer;
    store: TDprtInfo;
    lst: TList;  // not Free !!! ������ ���� ������� ���������� �������
begin
  if not Cache.EmplExist(EmplID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
  lst:= TList.Create;
//  lst:= Cache.GetEmplVisStoreLinkList(EmplID);  // not Free !!!
  try
    for i:= 1 to High(Cache.arDprtInfo) do if Cache.DprtExist(i) then begin
      store:= Cache.arDprtInfo[i];
      if not (store.IsStoreHouse or (flWithRoad and store.IsStoreRoad)) then Continue;
      lst.Add(store);
    end;
    if (lst.Count<1) then raise EBOBError.Create('�� ������� ��������� ������');
    lst.Sort(DirNameSortCompare);  // ������ ��������� �� ������������

    try
      k:= Stream.Position;
      Stream.WriteInt(0); // ���-�� �������
      jj:= 0; // �������
      for i:= 0 to lst.Count-1 do begin // �������� ������
        store:= Lst[i];
  //      store:= GetLinkPtr(Lst[i]);
        Stream.WriteInt(store.ID);             // ��� ������
        Stream.WriteStr(store.MainName);       // ������ ������.
        Stream.WriteStr(store.ColumnName);     // ������. �������
        Stream.WriteBool(store.IsStoreRoad);   // ������� ����
        inc(jj);
      end;
      Stream.Position:= k;
      Stream.WriteInt(jj); // �������� ���-��
      Stream.Position:= Stream.Size;
    except
      on E: EBOBError do raise EBOBError.Create(E.Message);
      on E: Exception do raise Exception.Create(nmProc+': '+E.Message);
    end;
  finally
    prFree(lst);
  end;
end;
//========================================== ������ � Stream ��������� �� ������
procedure prSaveCommonError(Stream: TBoBMemoryStream; ThreadData: TThreadData;
          nmProc, Emess, MyText: String; flEBOB: Boolean; flPRS: Boolean=False);
var s: String;
begin
  if flEBOB then begin
    Stream.Clear;
    Stream.WriteInt(aeCommonError);
    Stream.WriteStr(fnReplaceQuotedForWeb(Emess));
    fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', Emess, MyText);
  end else begin
    Stream.Clear;
    Stream.WriteInt(aeCommonError);
    s:= '';
    if flPRS then s:= CutPRSmess(Emess);
    if s='' then s:= MessText(mtkErrProcess);
    Stream.WriteStr(s);
    fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', Emess, MyText);
  end;
  Stream.Position:= 0;
end;
//========================================== ������ � ������ ��������� �� ������
procedure prSaveCommonErrorStr(var errStr: String; ThreadData: TThreadData;
          nmProc, Emess, MyText: String; flEBOB: Boolean; flPRS: Boolean=False);
begin
  if flEBOB then begin
    errStr:= fnReplaceQuotedForWeb(Emess);
    fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', Emess, MyText);
  end else begin
    errStr:= '';
    if flPRS then errStr:= CutPRSmess(Emess);
    if errStr='' then errStr:= MessText(mtkErrProcess);
    fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', Emess, MyText);
  end;
end;
//=========================================== ������� ��������� �� exception ORD
function CutEMess(Emess: String): String;
var i, j: Integer;
begin
  Result:= Emess;
  for j:= Low(arExceptNames) to High(arExceptNames) do begin
    i:= pos(arExceptNames[j], Result);
    if i>0 then begin
      Result:= copy(Result, i, length(Result));
      i:= pos('At procedure', Result);
      if i>0 then Result:= copy(Result, 1, i-1);
      Exit;
    end;
  end;
end;
//============================ ������� ��������� �� exception ORD + resDoNothing
function CutEMess(Emess: String; var ResCode: Integer): String;
begin
  Result:= CutEMess(Emess);
  if pos(arExceptNames[0], Result)>0 then ResCode:= resDoNothing;
end;
//=========================================== �������� ��������� deadlock � �.�.
function CutLockMess(mess: String): String;
begin
  if (Pos('deadlock', mess)>0) then Result:= 'deadlock ...'
  else if (Pos('another user', mess)>0) or (Pos('lock conflict', mess)>0) then
    Result:= 'lock conflict ...'
  else Result:= mess;
end;
//====================================================== �������� ��������� PRS.
function CutPRSmess(mess: String): String;
var i: Integer;
begin
  i:= pos('PRS.', mess);
  if i>0 then begin
    Result:= copy(mess, i+4);
    i:= pos(#13#10, Result);
    if i>0 then Result:= copy(Result, 1, i-1);
  end else Result:= mess;
end;
//======================================== ��������� ������������ (Web & WebArm)
function CheckNotValidUser(pUserID, pFirmID: Integer; var errmess: string): boolean;
begin
  errmess:= '';
  if pFirmID=isWe then begin                    // �������� WebArm
    if not Cache.EmplExist(pUserID) then errmess:= MessText(mtkNotEmplExist);
  end else                                      // �������� Web
    if not Cache.FirmExist(pFirmID) then errmess:= MessText(mtkNotFirmExists)
    else if Cache.arFirmInfo[pFirmID].Blocked then errmess:= MessText(mtkNotFirmProcess)
    else if not Cache.ClientExist(pUserID) then errmess:= MessText(mtkNotClientExist)
    else with Cache.arClientInfo[pUserID] do
      if Blocked then errmess:= MessText(mtkBlockCountLogin, Login)
      else if FirmID<>pFirmID then errmess:= MessText(mtkNotClientOfFirm);
  Result:= errmess<>'';
end;
//===================================== �������� ������� � ������ (Web & WebArm)
procedure prCheckUserForFirmAndGetCurr(UserID, FirmID: Integer;
          var ForFirmID, CurrID: Integer; PriceInUah: Boolean=False; contID: Integer=0);
var errmess: String;
begin
  CurrID:= 0;
  if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
  if FirmID=isWe then begin                    //------------- WebArm
    if (ForFirmID>0) and (not Cache.FirmExist(ForFirmID)  // ���� ����� �/�
      {or not Cache.CheckEmplVisFirm(UserID, ForFirmID)}) then ForFirmID:= 0;
    currID:= fnIfInt(PriceInUah, 1, cDefCurrency);
  end else begin                                //------------- Web
    currID:= Cache.arClientInfo[UserID].SearchCurrencyID;
  end;
  if not Cache.CurrExists(currID) then currID:= cDefCurrency;
end;
(*//===================================== �������� ������� � ������ (Web & WebArm)
procedure prCheckUserForFirmAndGetSysCurr(UserID, FirmID: Integer;
          var ForFirmID, Sys, CurrID: Integer; PriceInUah: Boolean=False; contID: Integer=0);
var errmess: String;
begin
  Sys:= 0;
  CurrID:= 0;
  if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
  if FirmID=isWe then begin                    //------------- WebArm
    if (ForFirmID>0) and (not Cache.FirmExist(ForFirmID)  // ���� ����� �/�
      {or not Cache.CheckEmplVisFirm(UserID, ForFirmID)}) then ForFirmID:= 0;
    currID:= fnIfInt(PriceInUah, 1, cDefCurrency);
  end else begin                                //------------- Web
    currID:= Cache.arClientInfo[UserID].SearchCurrencyID;
  end;
  if not Cache.CurrExists(currID) then currID:= cDefCurrency;
end;  *)
//======================================================== �������� ���� ���-���
procedure CheckDocSum;
const nmProc='CheckDocSum';
var GB_IBS: TIBSQL;
    GB_IBD: TIBDatabase;
    i, j, iType, iDocm: integer;
    mess, adr: string;
    curdocs: array of TTwoCodes;
    curdoc: TTwoCodes;
    fl: boolean;
    Body: TStringList;
begin
  if not Assigned(Cache) then Exit;
  if not Cache.flCheckDocSum then exit;
  if not fnGetActionTimeEnable(caeOnlyWorkTime) then Exit; // ������ � ������� �����
  if (dLastCheckDocTime<>DateNull) and
    (Now<IncMinute(dLastCheckDocTime, Cache.GetConstItem(pcCheckDocInterval).IntValue)) then exit;
  GB_IBS:= nil;
  GB_IBD:= nil;
  Body:= TStringList.Create;
  setlength(curdocs, 0);
  try try
    GB_IBD:= cntsGRB.GetFreeCnt;
    GB_IBS:= fnCreateNewIBSQL(GB_IBD, 'GB_IBS_'+nmProc, -1, tpRead, true);
    iType:= 102; //------------------------------------------------------- �����
    GB_IBS.SQL.Text:= 'select pinvcode, pinvnumber, pinvdate, delta,'+
      ' firmcode, firmmainname, crncshortname'+
      ' from (select rr.pinvcode, rr.pinvnumber, rr.pinvdate, f.firmcode, f.firmmainname,'+
      '  rr.pinvsumm-(1-rr.disc/100)*Lsum delta, cur.crncshortname, rr.Lsum, rr.LCount'+
      '  from (select r.pinvcode, r.pinvnumber, r.pinvdate, r.pinvwarelinecount LCount,'+
      '   r.pinvsumm, r.pinvdiscount disc, r.PInvRecipientCode, r.pinvcrnccode,'+
      '   (select sum(l.pinvlnprice*l.pinvlncount) from PAYINVOICELINES l'+
      '    where l.pinvlndocmcode=r.pinvcode) Lsum from PAYINVOICEREESTR r'+
      '  inner join userpsevdonimreestr on userfirmcode=r.PInvRecipientCode and (usercode<>1)'+
      '  where r.pinvdate>:From order by r.PInvRecipientCode, r.pinvdate) rr'+
      ' left join firms f on f.firmcode = rr.PINVRECIPIENTCODE'+
      ' left join currency cur on cur.crnccode = rr.pinvcrnccode)'+
      ' where ABS(delta)>:Delta or (Lsum>0 and LCount=0)';
    GB_IBS.ParamByName('From').AsDate:= Cache.GetConstItem(pcCheckDocFromDate).DateValue;
    GB_IBS.ParamByName('Delta').AsFloat:= Cache.GetConstItem(pcCheckDocSumDelta).DoubValue;
    GB_IBS.ExecQuery;
    while not GB_IBS.Eof do begin
      iDocm:= GB_IBS.FieldByName('pinvcode').AsInteger;
      j:= length(curdocs); // ���������� ��� ���-��
      setlength(curdocs, j+1);
      curdocs[j]:= TTwoCodes.Create(iType, iDocm);
      fl:= False;
      if CheckDocsList.Count>0 then for i:= 0 to CheckDocsList.Count-1 do begin
        with TTwoCodes(CheckDocsList.objects[i]) do fl:= (ID1=iType) and (ID2=iDocm);
        if fl then break;
      end;
      if not fl then begin // ���� ������ ���-�� � ������ ��� - ����������
        mess:= '  ���� N '+GB_IBS.FieldByName('pinvnumber').AsString+' �� '+
          FormatDateTime(cDateFormatY4, GB_IBS.FieldByName('pinvdate').AsDate)+
          ' - ������� = '+FormatFloat('# ##0.000', GB_IBS.FieldByName('delta').AsFloat)+
          ' '+GB_IBS.FieldByName('crncshortname').AsString+
          '   �/� '+GB_IBS.FieldByName('firmmainname').AsString;
        CheckDocsList.AddObject(mess, TTwoCodes.Create(iType, iDocm));
      end;
      TestCssStopException;
      GB_IBS.Next;
    end;
    GB_IBS.Close;


    iType:= -1; //----------------------------------------- ��������� ��� ������
    GB_IBS.SQL.Text:= 'select f.firmmainname, c.contcode, gn.rNum contnumber'+
      ' from contract c left join firms f on f.firmcode=c.contsecondparty'+
      ' left join Vlad_CSS_GetFullContNum(c.contnumber, c.contnkeyyear, c.contpaytype) gn on 1=1'+
      ' where c.contendingdate>"today" and (c.contdutycrnccode is null or c.contdutycrnccode < 1)'+
      '  and c.contfirstparty=(select userfirmcode from userpsevdonimreestr where usercode=1)'+
      '  and f.firmarchivedkey="F" and f.firmservicefirm="F"'+
      '  and f.FirmOrganizationType=0 and (f.firmchildcount=0'+
      '  or not exists(select * from firms ff where ff.firmmastercode=f.firmcode'+
      '  and ff.FirmOrganizationType=0))';

    if flDebug then GB_IBS.SQL.Text:= GB_IBS.SQL.Text+' and c.contcode<200';
    GB_IBS.ExecQuery;
    while not GB_IBS.Eof do begin
      iDocm:= GB_IBS.FieldByName('contcode').AsInteger;
      j:= length(curdocs); // ���������� ��� ���-��
      setlength(curdocs, j+1);
      curdocs[j]:= TTwoCodes.Create(iType, iDocm);
      fl:= False;
      if CheckDocsList.Count>0 then for i:= 0 to CheckDocsList.Count-1 do begin
        with TTwoCodes(CheckDocsList.objects[i]) do fl:= (ID1=iType) and (ID2=iDocm);
        if fl then break;
      end;
      if not fl then begin // ���� ������ ���-�� � ������ ��� - ����������
        mess:= '�/� - '+fnMakeAddCharStr(GB_IBS.FieldByName('firmmainname').AsString, 40, True)+
               ' - �������� '+GB_IBS.FieldByName('contnumber').AsString;
        CheckDocsList.AddObject(mess, TTwoCodes.Create(iType, iDocm));
      end;
      TestCssStopException;
      GB_IBS.Next;
    end;

    for i:= CheckDocsList.Count-1 downto 0 do begin // ������� ��, ��� ����
      curdoc:= TTwoCodes(CheckDocsList.Objects[i]);
      fl:= False;
      for j:= 0 to High(curdocs) do begin
        fl:= (curdoc.ID1=curdocs[j].ID1) and (curdoc.ID2=curdocs[j].ID2);
        if fl then break;
      end;
      if fl then Continue;
      prFree(curdoc);
      CheckDocsList.Delete(i);
    end;

    fl:= False;
    for i:= 0 to CheckDocsList.Count-1 do begin // ������� �����
      if (CheckDocsList[i]='') then Continue;
      if (TTwoCodes(CheckDocsList.Objects[i]).ID1<0) then begin
        fl:= True;     // �������, ��� ���� ���������
        Continue;      // ��������� ����������
      end;
      Body.Add(CheckDocsList[i]);
    end;  // for

    if fl then begin // ���� ���������
      Body.Add(' ');
      Body.Add('------------------------------------------------');
      Body.Add('   �� ������ ������ ��������� / �������������');
      Body.Add('------------------------------------------------');
      for i:= 0 to CheckDocsList.Count-1 do begin
        if (CheckDocsList[i]='') then Continue;
        if (TTwoCodes(CheckDocsList.Objects[i]).ID1>0) then Continue; // ����� ����������
        Body.Add(CheckDocsList[i]);
      end;  // for
    end;

    if Body.Count>0 then begin
      adr:= Cache.GetConstItem(pcCheckDocMail).StrValue;
      if adr='' then adr:= fnGetSysAdresVlad(caeOnlyWorkDay);
      mess:= n_SysMailSend(adr, '���������� ���������', Body, nil, '', '', True);
      if (mess<>'') and (Pos(MessText(mtkErrMailToFile), mess)>0) then
        raise Exception.Create('������ �������� ������ � ���������� ���-���')
      else begin
        prMessageLOGS(nmProc+': ���������� ������ � ���������� ���-��� �� E-mail '+adr, 'system');
        for i:= 0 to CheckDocsList.Count-1 do
          if (CheckDocsList[i]<>'') then CheckDocsList[i]:= '';
      end;
    end;
    dLastCheckDocTime:= Now;
  finally
    prFreeIBSQL(GB_IBS);
    cntsGRB.SetFreeCnt(GB_IBD);
    prFree(Body);
    for i:= 0 to High(curdocs) do prFree(curdocs[i]);
    setlength(curdocs, 0);
  end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  TestCssStopException;
end;
//============================================================= �������� �������
procedure CheckClientsEmails;
const nmProc='CheckClientsEmails';
var GB_IBS: TIBSQL;
    GB_IBD: TIBDatabase;
    i, iFirm: integer;
    mess, adr, sFirm, s: string;
    fl: boolean;
    Body: TStringList;
  //------------------------------------
  procedure SaveFirm;
  begin
    Body.Add('');
    Body.Add('---------- '+sFirm);
    fl:= False;
  end;
  //------------------------------------
begin
  if not Assigned(Cache) then Exit;
  if not Cache.flCheckCliEmails then exit;
  if not fnGetActionTimeEnable(caeOnlyWorkTime) then Exit; // ������ � ������� �����
  if (dLastCheckCliEmails<>DateNull) and    // ���� �� ������ �������� ��������
    (Now<IncHour(dLastCheckCliEmails, Cache.GetConstItem(pcZeroPricesIntHour).IntValue)) then exit;
  GB_IBS:= nil;
  GB_IBD:= nil;
  Body:= TStringList.Create;
  try try
    GB_IBD:= cntsGRB.GetFreeCnt;
    GB_IBS:= fnCreateNewIBSQL(GB_IBD, 'GB_IBS_'+nmProc, -1, tpRead, true);

    GB_IBS.SQL.Text:= 'select * from (select f.firmmastercode, f.firmcode,'+
      '  f.firmmainname, f.firmemail, null contcode,  null contnumber,'+
      '  null contsecondemail, null prsncode, null prsnpost, null prsnname,'+
      '  null prsnlogin, null peemail from firms f where f.firmarchivedkey="F"'+
      '  and f.FirmOrganizationType=0 and (f.firmchildcount=0'+
      '    or not exists(select * from firms ff where ff.firmmastercode=f.firmcode'+
      '    and ff.FirmOrganizationType=0))'+
      '  and f.firmservicefirm="F" and (f.firmemail is not null)'+
      ' union select f2.firmmastercode, f2.firmcode, f2.firmmainname, null firmemail,'+
      '  c.contcode, gn.rNum contnumber, c.contsecondemail, null prsncode,'+
      '  null prsnpost, null prsnname, null prsnlogin, null peemail from firms f2'+
      '  left join contract c on c.contsecondparty=f2.firmcode where f2.firmarchivedkey="F"'+
      '  left join Vlad_CSS_GetFullContNum(c.contnumber, c.contnkeyyear, c.contpaytype) gn on 1=1'+
      '  and f2.FirmOrganizationType=0 and (f2.firmchildcount=0'+
      '    or not exists(select * from firms ff where ff.firmmastercode=f2.firmcode'+
      '    and ff.FirmOrganizationType=0))'+
      '  and f2.firmservicefirm="F" and c.contfirstparty='+
      '  (select u.userfirmcode from userpsevdonimreestr u where u.usercode=1)'+
      '  and c.contendingdate>"today" and (c.contsecondemail is not null)'+
      ' union select f1.firmmastercode, f1.firmcode, f1.firmmainname, null firmemail, null contcode,'+
      '  null contnumber, null contsecondemail, pr.prsncode, pr.prsnpost, pr.prsnname,'+
      '  pr.prsnlogin, pm.peemail from firms f1 left join persons pr on pr.prsnfirmcode=f1.firmcode'+
      '  left join personemails pm on pm.pepersoncode=pr.prsncode where f1.firmarchivedkey="F"'+
      '  and f1.FirmOrganizationType=0 and (f1.firmchildcount=0'+
      '    or not exists(select * from firms ff where ff.firmmastercode=f1.firmcode'+
      '    and ff.FirmOrganizationType=0))'+
      '  and f1.firmservicefirm="F" and pr.prsnarchivedkey="F"'+
      '  and pm.pearchivedkey="F" and (pm.peemail is not null))'+
      '  order by firmmastercode, firmcode, firmemail nulls last, contcode nulls last, prsncode nulls last';
    GB_IBS.ExecQuery;
    while not GB_IBS.Eof do begin
      iFirm:= GB_IBS.FieldByName('firmcode').AsInteger;
      fl:= True;
      sFirm:= '�/� '+GB_IBS.FieldByName('firmmainname').AsString;
      adr:= GB_IBS.FieldByName('firmemail').AsString;
      if (adr<>'') and not fnCheckEmail(adr) then begin
        if fl then SaveFirm;
        Body.Add('�/� - E-mail: '+adr);
      end;
      while not GB_IBS.Eof and (iFirm=GB_IBS.FieldByName('firmcode').AsInteger) do begin
        i:= GB_IBS.FieldByName('contcode').AsInteger;
        if (i>0) then begin
          s:= '�������� '+GB_IBS.FieldByName('contnumber').AsString;
          adr:= GB_IBS.FieldByName('contsecondemail').AsString;
          if (adr<>'') and not fnCheckEmail(adr) then begin
            if fl then SaveFirm;
            Body.Add(s+' - E-mail: '+adr);
          end;
        end;
        i:= GB_IBS.FieldByName('prsncode').AsInteger;
        if (i>0) then begin
          s:= '�����. '+GB_IBS.FieldByName('prsnpost').AsString+', '+GB_IBS.FieldByName('prsnname').AsString;
          adr:= GB_IBS.FieldByName('peemail').AsString;
          if (adr<>'') and not fnCheckEmail(adr) then begin
            if fl then SaveFirm;
            Body.Add(s+' - E-mail: '+adr);
          end;
        end;
        TestCssStopException;
        GB_IBS.Next;
      end;
      TestCssStopException;
    end;
    GB_IBS.Close;

    fl:= True;
    GB_IBS.SQL.Text:='Select EMPLCODE, EMPLMANCODE,'+
      ' MANLASTNAME, MANNAME, MANPATRONYMICNAME, MANWORKEMAIL'+
      ' FROM EMPLOYEES inner join MANS on EMPLMANCODE=MANCODE'+
      ' where EMPLARCHIVE="F" and MANARCHIVE="F"';
    GB_IBS.ExecQuery;
    while not GB_IBS.Eof do begin
      adr:= GB_IBS.FieldByName('MANWORKEMAIL').AsString;
      if (adr<>'') and not fnCheckEmail(adr) then begin
        if fl then begin
          Body.Add('');
          Body.Add('');
          Body.Add('---------- ���������� ��������');
          fl:= False;
        end;
        s:= GB_IBS.FieldByName('MANLASTNAME').AsString+' '+
            GB_IBS.FieldByName('MANNAME').AsString+' '+
            GB_IBS.FieldByName('MANPATRONYMICNAME').AsString;
        Body.Add(s+' - E-mail: '+adr);
      end;
      TestCssStopException;
      GB_IBS.Next;
    end;
    GB_IBS.Close;

    if Body.Count>0 then begin
      Body.Insert(0, '������� ��������� E-mail:');
      Body.Insert(1, '- ������ (���)@(�����)');
      Body.Insert(2, '- (���) ����� ��������� ������ ����.�����, �����, �����, ����, �������������');
      Body.Insert(3, '- (�����) ����� ��������� ������ ����.�����, �����, �����, ����');
      Body.Insert(4, '- (���) � (�����) �� ������ ���������� � ������������� ������');
      Body.Insert(5, '- (�����) ������ ��������� �� ����� 1-� �����');
      Body.Insert(6, '- (�����) ������ ��������� �� ����� 2-� �������� ����� ��������� �����');
      Body.Insert(7, '- ��������� E-mail � ������ ����������� ������ ��������.');
      Body.Insert(8, '');
      Body.Insert(9, '�������� E-mail, �� ��������������� ��������:');

      adr:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ����� Email ������ ���
      if adr='' then adr:= fnGetSysAdresVlad(caeOnlyWorkDay);
      mess:= n_SysMailSend(adr, '���������� E-mail', Body, nil, '', '', True);
      if (mess<>'') and (Pos(MessText(mtkErrMailToFile), mess)>0) then
        raise Exception.Create('������ �������� ������ � ���������� E-mail')
      else
        prMessageLOGS(nmProc+': ���������� ������ � ���������� E-mail �� E-mail '+adr, 'system');
    end;
    dLastCheckCliEmails:= Now;
  finally
    prFreeIBSQL(GB_IBS);
    cntsGRB.SetFreeCnt(GB_IBD);
    prFree(Body);
  end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  TestCssStopException;
end;
//=========== ������������ ������ ��������� ��� ���������� � �������� ��� ������
function GetLstPrefixAddon(pBrandID: Integer; UseOnlyBrand: Boolean=True): TStringList; // must Free Result
// UseOnlyBrand = True. �������� ��� ������. False - ���� �� ID ��������� ������� ������
var BID: Integer;
begin
  Result:= TStringList.Create;
  if UseOnlyBrand then BID:= Cache.GetGrpID(pBrandID) else BID:= pBrandID;
  case BID of
    85413: Result.Append('AVX');  // CONTITECH
  end;
end;
//=========== ������������ ������ ��������� ��� ���������� � �������� ��� ������
function GetLstSufixAddon(pBrandID: Integer; UseOnlyBrand: Boolean=True): TStringList; // must Free Result
// UseOnlyBrand = True. �������� ��� ������. False - ���� �� ID ��������� ������� ������
var BID: Integer;
begin
  Result:= TStringList.Create;
  if UseOnlyBrand then BID:= Cache.GetGrpID(pBrandID) else BID:= pBrandID;
  case BID of
    85413: Result.Append('LD');   // CONTITECH
  end;
end;
//============= ���������� TStringList �� ������������ ������, ���� ID � Objects
function ObjWareNameSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var s1, s2: String;
begin
  with Cache do try
    s1:= GetWare(Integer(List.Objects[Index1]), True).Name;
    s2:= GetWare(Integer(List.Objects[Index2]), True).Name;
    Result:= AnsiCompareText(s1, s2);
  except
    Result:= 0;
  end;
end;
//-- �������� ���� ������ ����� � 1 ��������, TreeList[i] - Pointer(TSecondLink)
procedure prHideTreeNodes(var ListNodes, listParCodes: TList; flOnlySameName, flOnlyOneLevel: boolean);
const nmProc = 'prHideTreeNodes'; // ��� ���������/�������
var i, j, jj, ii, NodeIndex, levelCount, iDel, iDel1: Integer;
    flHide, flNotFound: boolean;
    NodeName: String;
    link: TSecondLink;
    Node: TAutoTreeNode;
    arNodeCodes, arParCodes, arNodes1, arNodes2, arParIn: Tai;
    arNodeNames: Tas;
  //----------------------------------------------
  procedure FillNodeCodes(var arNodes: Tai; ParCode: Integer);
  var i: integer;
  begin
    setLength(arNodes, 0); // ������ ����� �������� ������� ��� � �����
    setLength(arParIn, 0);  // ������ ����� ���������� ���������� ��� � �����
    with ListNodes do for i:= 0 to Count-1 do begin
      link:= Items[i];
      Node:= link.LinkPtr;
      if (Node.ID=ParCode) then prAddItemToIntArray(ParCode, arParIn);
      if (Length(arParIn)<1) or // �� ����� �� ��������
        (fnInIntArray(Integer(listParCodes[i]), arParIn)<0) then Continue; // �� ��� ��������
      if Node.IsEnding then
        prAddItemToIntArray(Node.MainCode, arNodes) // �������� ����
      else prAddItemToIntArray(Node.ID, arParIn); // ���������� ����
    end;
  end;
  //----------------------------------------------
  procedure HideNodesWithOneChild;
  var i, jj, ChildCount: integer;
  begin
    NodeIndex:= -1;
    NodeName:= '';
    levelCount:= 0;  // ������� ������� ���������� ���
    with ListNodes do for i:= Count-1 downto 0 do begin //-- ������ �������� ���� - ���� �����
      ChildCount:= 0;
      link:= Items[i];
      Node:= link.LinkPtr;
      ii:= Integer(listParCodes[i]); // ��� �������� ������� ����
      flHide:= not Node.IsEnding and (ii>0) and (NodeIndex=(i+1)) // ���� �� �������� � �� 1-� �������
        and (Node.ID=Integer(listParCodes[NodeIndex]));           // � �������� ����� ����� ��������
      if flHide and flOnlySameName then flHide:= (Node.Name=NodeName);
      if flHide and flOnlyOneLevel then flHide:= (levelCount<1);
      if flHide then begin
        for jj:= NodeIndex+1 to listParCodes.Count-1 do
          if (Node.ID=Integer(listParCodes[jj])) then begin
            flHide:= False;
            break;
          end;                   // ���� � ������� ���� ���� ���� ������
        if not flHide then begin // ���������, ���� �� ��� ���� � ������� ����
          for jj:= 0 to listParCodes.Count-1 do begin
            if ii=Integer(listParCodes[jj]) then inc(ChildCount);
          end;
          flHide:= ChildCount<2;
        end;
      end; // if flHide
      if flHide then begin // ���� ������
        for jj:= i+1 to listParCodes.Count-1 do // ������������� �������� ���� ����� ������� ����
          if (Integer(listParCodes[jj])=Node.ID) then listParCodes[jj]:= listParCodes[i];
        Delete(i);
        listParCodes.Delete(i);
        inc(iDel);
        Dec(NodeIndex);
        inc(levelCount);
      end else begin
        NodeName:= Node.Name; // ���������� ��������� ������������ ����
        NodeIndex:= i;
        levelCount:= 0;               // ���������� ������� �������
      end;
    end; // for i:= Count-1 downto 0
  end;
  //----------------------------------------------
begin
  setLength(arNodeCodes, 0);
  setLength(arNodeNames, 0);
  setLength(arParCodes, 0);
  setLength(arNodes1, 0);
  setLength(arNodes2, 0);
  setLength(arParIn, 0);
  with ListNodes do try // ������ ��� ������
    repeat
      iDel:= 0;
//---------------------------------- ����������� ���� � 1-� ��������
      HideNodesWithOneChild;
//---------------------------------- ���� ��������� �������� ��� � 1-�� ��������
      iDel1:= 0;
      setLength(arParCodes, 0);     // ������ �����.����� �������� ���
      for i:= 0 to Count-1 do begin
        link:= Items[i];
        Node:= link.LinkPtr;
        if Node.IsEnding then prAddItemToIntArray(Integer(listParCodes[i]), arParCodes);
      end;
      for j:= High(arParCodes) downto 0 do begin
        setLength(arNodeCodes, 0);
        for i:= Count-1 downto 0 do begin // ��������� ���� 1-�� �������� - ���� �����
          link:= Items[i];
          Node:= link.LinkPtr;
          if (Node.ID=arParCodes[j]) then break; // ����� �� ��������
          if not Node.IsEnding then Continue; // �� �������� ����
          if (Integer(listParCodes[i])<>arParCodes[j]) then Continue; // �� ��� ��������
          if (fnInIntArray(Node.MainCode, arNodeCodes)>-1) then begin // ����� ��������
            Delete(i);
            listParCodes.Delete(i);
            inc(iDel);
            inc(iDel1);
          end else prAddItemToIntArray(Node.MainCode, arNodeCodes);
        end;
      end; // for j:= High(arParCodes) downto 0

//--------------------------- ���� ���� ��������� �������� ��� - ��� �����������
      if (iDel1>0) then HideNodesWithOneChild;

//----------------------------------------- ���� ��������� ����� � 1-�� ��������
      setLength(arParCodes, 0);  // ������ ����� ��������� ��������� �������� ���
      setLength(arParIn, 0);     // ������ ����� ��������� �������� ���
      for i:= Count-1 downto 0 do begin
        link:= Items[i];
        Node:= link.LinkPtr;
        jj:= Integer(listParCodes[i]);
        if Node.IsEnding then prAddItemToIntArray(jj, arParIn)
        else if (jj>0) and (fnInIntArray(Node.ID, arParIn)>-1) then
          prAddItemToIntArray(jj, arParCodes);
      end;

      for j:= 0 to High(arParCodes) do begin
        setLength(arNodeCodes, 0);     // ����� - ������ ����� �� �������� ��� (�����)
        setLength(arNodeNames, 0);     // ������ ������������ �� �������� ��� (�����)
        for i:= Count-1 downto 0 do begin // ��������� ������ ����� �����
          link:= Items[i];
          Node:= link.LinkPtr;
          if (Node.ID=arParCodes[j]) then break; // ����� �� ��������
          if Node.IsEnding then Continue; // �������� ����
          if (Integer(listParCodes[i])<>arParCodes[j]) then Continue; // �� ��� ��������
          if fnInIntArray(Node.ID, arNodeCodes)<0 then begin
            jj:= Length(arNodeCodes);
            setLength(arNodeCodes, jj+1);
            arNodeCodes[jj]:= Node.ID;
            setLength(arNodeNames, jj+1);
            arNodeNames[jj]:= Node.Name;
          end;
        end; // for i:= Count-1 downto 0

        while (Length(arNodeCodes)>1) do begin // ���� ���������, ���� �� ����� 2-� �����
          NodeName:= arNodeNames[0];  // ������������ ���.���� 1-� �����
          FillNodeCodes(arNodes1, arNodeCodes[0]); // ��������� ������ ������� ����� �������� ��� 1-� �����
   //--------------------------------------------- ������� ��������� ����� � 1-�
          if Length(arNodes1)>0 then for jj:= 1 to High(arNodeCodes) do begin
            if flOnlySameName and (arNodeNames[jj]<>NodeName) then Continue; // �� ����.������������

            FillNodeCodes(arNodes2, arNodeCodes[jj]); // ��������� ������ ������� ����� �������� ��� jj-� �����
            if (Length(arNodes2)<1) then Continue;
            if Length(arNodes2)<>Length(arNodes1) then Continue; // �� ����.���-�� ���

            flNotFound:= False;
            for ii:= 0 to High(arNodes2) do begin // ������� ������� ����� �������� ���
              flNotFound:= fnInIntArray(arNodes2[ii], arNodes1)<0;
              if flNotFound then break;
            end;
            if flNotFound then Continue; // jj-����� <> 1-� �����
   //---------------------------------------------------- ������� �������� �����
            setLength(arNodes2, 0); // ����� - ���� ��� ����� ��� ��������
            setLength(arParIn, 0); // ������ ����� ������������ ��� � �����
            levelCount:= -1;
            for i:= 0 to Count-1 do begin
              link:= Items[i];
              Node:= link.LinkPtr;
              if (Node.ID=arNodeCodes[jj]) then begin // ���� ���.���� jj-� ����� � �� ������
                levelCount:= i; // ������, �� �������� ���������� ����
                prAddItemToIntArray(Node.ID, arNodes2);
                prAddItemToIntArray(Node.ID, arParIn);
                arNodeCodes[jj]:= 0;  // ������� ��� ���.���� jj-� ����� �� �������
              end;
              if levelCount<0 then Continue; // �� ����� �� ���.���� jj-� �����
              if fnInIntArray(Integer(listParCodes[i]), arParIn)<0 then Continue; // �� ��� ��������
              if not Node.IsEnding then
                prAddItemToIntArray(Node.ID, arParIn); // ���������� ���� ����������
              prAddItemToIntArray(Node.ID, arNodes2);  // ���� ����� �����
            end;

            for i:= Count-1 downto levelCount do begin // ������� ���� �����
              link:= Items[i];
              Node:= link.LinkPtr;
              if (fnInIntArray(Node.ID, arNodes2)<0) then Continue;
              Delete(i);
              listParCodes.Delete(i);
              inc(iDel);
            end;
   //----------------------------------------------------- ������ �������� �����
          end; // for jj:= 1 to High(arNodeCodes)
          arNodeCodes[0]:= 0; // ������� ��� ���.���� ����������� ����� �� �������
          ii:= 0;
          while (Length(arNodeCodes)>ii) do
            if (arNodeCodes[ii]<1) then begin
              prDelItemFromArray(ii, arNodeCodes);
              prDelItemFromArray(ii, arNodeNames);
            end else Inc(ii);
        end; // while (Length(arNodeCodes)>1)
      end; // for j:= 0 to High(arParCodes)
    until (iDel<1);
//--------------------------- ��� ��� ����������� ��� ����������
    HideNodesWithOneChild;
  finally
    setLength(arNodeCodes, 0);
    setLength(arNodeNames, 0);
    setLength(arParCodes, 0);
    setLength(arNodes1, 0);
    setLength(arNodes2, 0);
    setLength(arParIn, 0);
  end;
end;

//=================================================== ��������� ��� ����� ������
function fnFormRepFileName(pSubName, pNameOrExt: string; pOpKind: integer): string;
// ���������� ��� ����� ��� ���� !!!
// pSubName - ������-������������� ������ ("26", "30_1", ...)
// pNameOrExt (�������) - ���������� ����� ������, ����� ��� ����� - �������
// pNameOrExt (������)  - ��� ���.����� ������� � �����������, ����� � ����� - �������
// pOpKind - ��� �������� [constOpExport, constOpImport]
var pFileExt, MidName: String;
begin
  Result:= '';
  MidName:= '';
  pFileExt:= '';
  if (pSubName='') then
    raise EBOBError.Create(MessText(mtkNotValidParam)+' - ������ ������������� �����');
  case pOpKind of
    constOpImport: begin // ������
        if (length(pNameOrExt)<5) then
          raise EBOBError.Create(MessText(mtkNotValidParam)+' - ��� ����� ������� '+pNameOrExt);

        MidName:= ExtractFileName(pNameOrExt);                // ������� ����
        pFileExt:= ExtractFileExt(MidName);                   // �������� ����������
        MidName:= copy(MidName, 1, pos(pFileExt, MidName)-1); // �������� ��� �� ����������

        MidName:= MidName+'_import_'+pSubName;                // ��������� ������������� �������
      end; // constOpImport

    constOpExport: begin // �������/�����
        if length(pNameOrExt)<3 then            // ����������
          raise EBOBError.Create(MessText(mtkNotValidParam)+' - ���������� ����� '+pNameOrExt);

        if (copy(pNameOrExt, 1, 1)='.') then pFileExt:= pNameOrExt
        else begin // ���� � ������ ���������� ��� �����
          if pos('.', pNameOrExt)>0 then // ���� ���� ����� ������
            raise EBOBError.Create(MessText(mtkNotValidParam)+' - ���������� ����� '+pNameOrExt);
          pFileExt:= '.'+pNameOrExt;      // ��������� �����
        end;

        MidName:= 'report_'+pSubName;     // ��������� ������ ����� ����� - ������������� ������
      end; // constOpExport

    else raise EBOBError.Create(MessText(mtkNotValidParam)+' �������� '+IntToStr(pOpKind));
  end; // case
  if (MidName='') or (length(pFileExt)<3) then // �� ����.������
    raise EBOBError.Create(MessText(mtkNotValidParam)+' - ��� ����� '+MidName+pFileExt);

  Result:= MidName+FormatDateTime('_yy.mm.dd_(hh.nn)', Now)+pFileExt;
end;
//================================== ���������� ��������� ������������ �� ������
function fnSendErrorMes(FirmID, UserID, MesType, WareId, AnalogId, OrNumId, ModelId, NodeId: Integer;
         SenderMess, AttrMess: String; ThreadData: TThreadData): String;
const nmProc = 'fnSendErrorMes'; // ��� ���������/�������
// Exception �������� ������, ���������� ��������� ��� ������������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    Body, SENDERCOMM, MessForSender: TStringList;
    Employee: TEmplInfoItem;
    Client: TClientInfo;
    Model: TModelAuto;
    Node: TAutoTreeNode;
    Eng: TEngine;
    Ware, Analog: TWareInfo;
    ONum: TOriginalNumInfo;
    email, emailM, s, s1, sErr, sMonitoring: string;
    SysID, ManagerID, i, EmplID: integer;
    Monitorings: Tai;
  //-------------------------------------
  procedure AddEmployeeMail(eid: Integer);
  begin
    if fnInIntArray(eid, Monitorings)>-1 then exit;
    if not Cache.EmplExist(eid) then Cache.TestEmpls(eid);
    if not Cache.EmplExist(eid) then begin
      sErr:= sErr+fnIfStr(sErr='', '', #10)+
        MessText(mtkNotEmplExist, IntToStr(eid));
      exit;
    end;
    Employee:= Cache.arEmplInfo[eid];
    if Employee.Mail='' then
      sErr:= sErr+fnIfStr(sErr='', '', #10)+
        MessText(mtkNotManagerMail, Employee.EmplShortName)
    else begin
      email:= email+fnIfStr(email='', '', ',')+Employee.Mail;
      sMonitoring:= sMonitoring+fnIfStr(sMonitoring='', '', #10)+
        Employee.Mail+' ('+Employee.EmplShortName+')';
    end;
  end;
  //-------------------------------------
begin
  Result:= '';
  OrdIBD:= nil;
  OrdIBS:= nil;
  Body:= TStringList.Create;
  SENDERCOMM:= TStringList.Create;
  MessForSender:= TStringList.Create;
  email:= '';
  emailM:= '';
  s:= '';
  s1:= '';
  sErr:= '';
  sMonitoring:= '';
  SetLength(Monitorings, 0);
  EmplID:= 0;
  try try
    if (FirmID=isWe) then begin
      if not Cache.EmplExist(UserId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
      Employee:= Cache.arEmplInfo[UserId];
      Body.Add('��������� �������� '+Employee.EmplLongName+
        #10'(E-mail: '+fnIfStr(Employee.Mail='', '�� ������', Employee.Mail)+') ��������:'#10);

    end else begin
      if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
      Client:= Cache.arClientInfo[UserId];
      Body.Add('������������� ����������� '+Client.FirmName+' - '+Client.Name+', '+Client.Post+
        #10+'(E-mail: '+fnIfStr(Client.Mail='', '�� ������', Client.Mail)+') ��������:'#10);
    end;

    Ware:= Cache.GetWare(WareId);
    if not Assigned(Ware) or (Ware=NoWare) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareId)));

    Monitorings:= Cache.GetConstEmpls(pcErrMessMonitoringEmpl);

//------------------------------------------- ��������� ������ � ������ ��������
    case MesType of // case 1
      constWrongAttribute: begin //---------------------- ��������
        if Ware.IsAUTOWare then begin
          EmplID:= GetSysTypeEmpl(constIsAuto);
          AddEmployeeMail(EmplID);
        end else if Ware.IsMOTOWare then begin
          EmplID:= GetSysTypeEmpl(constIsMoto);
          AddEmployeeMail(EmplID);
        end else email:= email+fnIfStr(email='', '', ',')+
                         Cache.GetConstItem(pcUIKdepartmentMail).StrValue;

        SENDERCOMM.Add('������ ���������� ������ '+Ware.Name+': '+AttrMess); // �������� ����� ��� ����
        Body.Add('--- ������ ���������� ������.');                           // �������� ����� ��� ������
        Body.Add('�����: '+Ware.Name);
        Body.Add(AttrMess);
      end; // constWrongAttribute

      constWrongEngineNode: begin //-------------------- ��������� - ������ ����
        SysID:= constIsAuto;
        if not Cache.FDCA.Engines.ItemExists(ModelId) then
          raise EBOBError.Create(MessText(mtkNotFoundEngine, IntToStr(ModelId)));
        Eng:= Cache.FDCA.Engines.GetEngine(ModelId);
        if not Cache.FDCA.AutoTreeNodesSys[SysID].NodeGet(NodeId, Node) then
          raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeId)));

        EmplID:= GetSysTypeEmpl(SysID);
        AddEmployeeMail(EmplID);

        SENDERCOMM.Add('����� '+Ware.Name+' �� ������������� ���� '+  // �������� ����� ��� ����
          Node.Name+' ��������� '+Eng.WebName);
        Body.Add('--- ������ ������������ ������ ��������� � ����.'); // �������� ����� ��� ������
        Body.Add('���������: '+Eng.WebName);
        Body.Add('����: '+Node.Name);
        Body.Add('�����: '+Ware.Name);
      end; // constWrongEngineNode

      constWrongModelNode: begin //---------------------- ������ - ���� ��� ����
        if not Cache.FDCA.Models.ModelExists(ModelId) then
          raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelId)));
        Model:= Cache.FDCA.Models.GetModel(ModelId);
        SysID:= Model.TypeSys;
        if not Cache.FDCA.AutoTreeNodesSys[SysID].NodeGet(NodeId, Node) then      // NodeID=-1 ???
          raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeId)));

        EmplID:= GetSysTypeEmpl(SysID);
        AddEmployeeMail(EmplID);

        SENDERCOMM.Add('����� '+Ware.Name+' �� ������������� ���� '+ // �������� ����� ��� ����
          Node.Name+' ������ '+Model.WebName);
        Body.Add('--- ������ ������������ ������ ������ � ����.');   // �������� ����� ��� ������
        Body.Add('������: '+Model.WebName);
        Body.Add('����: '+Node.Name);
        Body.Add('�����: '+Ware.Name);
      end; // constWrongModelNode

      constWrongAnalog..constWrongOrNum: begin
        EmplID:= Ware.ManagerID; // �������� ������
        AddEmployeeMail(EmplID);

        case MesType of // case 2
          constWrongAnalog: begin
            if not Cache.WareExist(AnalogId) then
              raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(AnalogId)));
            Analog:= Cache.GetWare(AnalogId);

            ManagerID:= Analog.ManagerID;  // �������� �������
            if (ManagerID<>EmplID) then   // ���� �������� ������ - ��������� ��� �����
              AddEmployeeMail(ManagerID);

            SENDERCOMM.Add('����� '+Analog.Name+       // �������� ����� ��� ����
              ' �� �������� �������� ������ '+Ware.Name);
            Body.Add('--- ������ �������� �������.');  // �������� ����� ��� ������
            Body.Add('�����: '+Ware.Name);
            Body.Add('������: '+Analog.Name);
          end; // constWrongAnalog

          constWrongDescription: begin
            SENDERCOMM.Add('������ � �������� ������ '+Ware.Name); // �������� ����� ��� ����
            Body.Add('--- ������ � �������� ������.');
            Body.Add('�����: '+Ware.Name);
          end; // constWrongDescription

          constWrongOrNum: begin
            if not Cache.FDCA.OrigNumExist(OrNumId) then
              raise EBOBError.Create('�� ������ ������������ �����');
            ONum:= Cache.FDCA.GetOriginalNum(OrNumId);

            SENDERCOMM.Add('������ '+Ware.Name+                        // �������� ����� ��� ����
              ' �� ������������� ������������ ����� '+ONum.Name+' ('+ONum.ManufName+')');
            Body.Add('--- ������ ������������ ������������� ������.'); // �������� ����� ��� ������
            Body.Add('�����: '+Ware.Name);
            Body.Add('������������ �����: '+ONum.Name+' ('+ONum.ManufName+')');
          end; // constWrongOrNum
        end; // case 2
      end; // constWrongAnalog..constWrongOrNum

      else raise EBOBError.Create('������������ ��� ������, ��� '+IntToStr(MesType));
    end; // case 1

    s:= '--- ������� (����� �����������): ';
    SENDERCOMM.Add(s);          // �������� ����� ��� ����
    SENDERCOMM.Add(SenderMess);
    Body.Add(s);                // �������� ����� ��� ������
    Body.Add(SenderMess);

//---------------------------------------------------------------- ��������� SQL
    s:= 'CEMSCEMKCODE, CEMSWARECODE';
    s1:= IntToStr(MesType)+', '+IntToStr(WareId);
    if (ModelId>0) then begin
      s := s +', CEMSMODELCODE';
      s1:= s1+', '+IntToStr(ModelId);
    end;
    if (NodeId>0) then begin
      s := s +', CEMSNODECODE';
      s1:= s1+', '+IntToStr(NodeId);
    end;
    if (AnalogId>0) then begin
      s := s +', CEMSANALOGCODE';
      s1:= s1+', '+IntToStr(AnalogId);
    end;
    if (OrNumId>0) then begin
      s := s +', CEMSONUMCODE';
      s1:= s1+', '+IntToStr(OrNumId);
    end;
    if (FirmID>0) and (FirmID<>isWe) then begin
      s := s +', CEMSFIRMCODE';
      s1:= s1+', '+IntToStr(FirmID);
    end;
    if (EmplID>0) then begin
      s := s +', CEMSWORKERCODE';
      s1:= s1+', '+IntToStr(EmplID);
    end;
    s := s +', CEMSSENDERCODE, CEMSSENDTIME, CEMSSENDERCOMM';
    s1:= s1+', '+IntToStr(UserID)+', "NOW", :CEMSSENDERCOMM';

//----------------------------------------------------------------- ����� � ����
    try
      OrdIBD:= CntsOrd.GetFreeCnt();
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBSQL_'+nmProc, ThreadData.ID, tpWrite, True);
      OrdIBS.SQL.Text:= 'INSERT INTO CLIENTERRMESSAGES ('+s+') VALUES ('+s1+')';
      OrdIBS.ParamByName('CEMSSENDERCOMM').AsString:= SENDERCOMM.Text;
      OrdIBS.ExecQuery;
      OrdIBS.Transaction.Commit;
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(OrdIBD);
    end;

//--------------------------------------------------- �������� ������ ����������
    s:= '';
    s1:= '';
    if email<>'' then begin
      s:= n_SysMailSend(email , '����������� �� ������ ������ ������', Body, nil,  '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // ���� ������ �� �������� � ����
        prMessageLOGS(nmProc+'(send mail to managers): '+s);
        if sMonitoring<>'' then sMonitoring:= '  ������ �������� ����������� �� ������ �� E-mail:'#10+sMonitoring;
      end else if sMonitoring<>'' then sMonitoring:= '  ����������� �� ������ ������� �� E-mail:'#10+sMonitoring;
      if sMonitoring<>'' then Body.Add(#10+sMonitoring);
    end;

//----------------------------------------------------- �������� ������ ��������
    if sErr<>'' then Body.Add(#10+sErr);
    emailM:= Cache.GetEmplEmails(Monitorings);
    if (emailM='') then s1:= '�� ������� E-mail ��������'
    else begin
      s1:= n_SysMailSend(emailM, '����������� �� ������ ������ ������', Body, nil,  '', '', True);
      if (s1<>'') and (Pos(MessText(mtkErrMailToFile), s1)<1) then s1:= ''; // ���� ������ �������� � ����
    end;
    if (s1<>'') then prMessageLOGS(nmProc+'(send mail to monitoring): '+s1);

//------------------------------------------------- ��������� ����� ������������
    if (s='') or (s1='') then begin // ���� ���������� ���� ����-������
      MessForSender.Add('���� ��������� �� ������ �������.');
    end else begin
      MessForSender.Add(MessText(mtkErrSendMess));
      MessForSender.Add(MessText(mtkMailWillSend));
      if (Pos(MessText(mtkErrMailToFile), s)>0) // ���� ������ �� �������� � ����, �.�. ������ � ���� ������,
        and (Pos(MessText(mtkErrMailToFile), s1)>0) then begin // � ������ ������ �� ���� - ����� � ���
        prMessageLOGS(nmProc+': ������ �������� ����������� �� E-mail: '+fnIfStr(email='', '', '('+email+')')+emailM);
        for i:= 0 to Body.Count-1 do prMessageLOGS('  '+Body[i]);
      end;
    end;
    MessForSender.Add('���������� �� ��������������.');

    Result:= MessForSender.Text;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do raise Exception.Create(nmProc+': '+E.Message+
      #10'FirmID='+IntToStr(FirmID)+', UserID='+IntToStr(UserID)+
      ', MesType='+IntToStr(MesType)+', WareId='+IntToStr(WareId)+#10+
      fnIfStr(AnalogId>-1, ' AnalogId='+IntToStr(AnalogId), '')+
      fnIfStr(OrNumId>-1, ' OrNumId='+IntToStr(OrNumId), '')+
      fnIfStr(ModelId>-1, ' ModelId='+IntToStr(ModelId), '')+
      fnIfStr(NodeId>-1, ' NodeId='+IntToStr(NodeId), '')+#10+
      fnIfStr(SenderMess<>'', ' SenderMess='+SenderMess, '')+
      fnIfStr(AttrMess<>'', ' AttrMess='+AttrMess, ''));
  end;
  finally
    prFree(MessForSender);
    prFree(Body);
    prFree(SENDERCOMM);
    SetLength(Monitorings, 0);
  end;
end;
{//================================== ���������� ��������� ������������ ���������
function fnSendClientMes(FirmID, UserID, Source: Integer; SenderMess: String;
                         ThreadData: TThreadData; var Response: String; ContID: Integer=0): Boolean;
const nmProc = 'fnSendClientMes'; // ��� ���������/�������
// � Result ���������� ������� �������� �������� ���������,
// ������ ���������� � ���, � Response ���������� ��������� ��� ������������
var Filial, EmplID, i: integer;
    s, To_, ToAdm, Delim, nm: string;
    Strings: TStringList;
    Client : TClientInfo;
    Firm   : TFirmInfo;
    ar: Tai;
begin
  Result:= False;
  Response:= '';
  nm:= '';
  Strings:= nil;
  SetLength(ar, 0);
  try
    if not (Source in [cosByVlad, cosByWeb]) then Source:= cosByWeb;
    if Source=cosByVlad then Delim:= cStrVladDelim else Delim:= ''; // ����������� ��� Vlad

    if (trim(SenderMess)='') then
      raise EBOBError.Create('������ ��������� ������ ���������');
    if not Cache.ClientExist(UserID) then
      raise Exception.Create(MessText(mtkNotClientExist, IntToStr(UserID)));

    Client:= Cache.arClientInfo[UserID];
    if not Cache.FirmExist(FirmID) then FirmID:= Client.FirmID
    else if (FirmID<>Client.FirmID) then raise Exception.Create(MessText(mtkNotClientOfFirm));

    if not Cache.FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists, IntToStr(FirmID)));

    Firm:= Cache.arFirmInfo[FirmID];
    Filial:= Firm.GetDefContract.Filial;
    if not Cache.DprtExist(Filial) then
      raise Exception.Create(MessText(mtkNotDprtExists, IntToStr(Filial)));

    if Client.Mail='' then raise EBOBError.Create(
      '������ ��������� ���������, '+Delim+'�.�. ������ E-mail ��� � ���� ������. '+Delim+
      '�������� ���� ����� � E-mail '+Delim+'��������� ������������� ��������.');
                                       // ��������� ������� � Email ������������
    nm:= Client.Name+', '+Firm.Name;
    s:= StringOfChar('-', 40);
    SenderMess:= SenderMess+#10#10+s+#10'������������: '+nm+
      #10#10'E-mail ������������: '+Client.Mail;
    if (ContID>0) then begin

      prAddItemToIntArray(Firm.GetContract(ContID).Manager, ar)
    end else for i:= 0 to Firm.FirmManagers.Count-1 do
      prAddItemToIntArray(Firm.FirmManagers[i], ar);

    if (Length(ar)<1) then
      SenderMess:= SenderMess+#10#10'�������� ����������� �� ������.'
    else for i:= 0 to High(ar) do begin            // ��������� ����������
      EmplID:= ar[i];
      if not Cache.EmplExist(EmplID) then Cache.TestEmpls(EmplID);
      if Cache.EmplExist(EmplID) then with Cache.arEmplInfo[EmplID] do
        SenderMess:= SenderMess+#10#10'�������� �����������: '+EmplShortName+
                     ' ( E-mail: '+fnIfStr(Mail<>'', Mail, '�� ������')+' )';
    end;

    Strings:= TStringList.Create;
    Strings.Text:= SenderMess;     // ��������� � ������ �����
    Strings.Insert(0, '��������! ������ ������� �������� ������� �������, '+
      'E-mail ������������ ��� ������ ������ � ������.'#10#10+
      '����� ���������:'#10+StringOfChar('-', 40)+#10);

    ToAdm:= Cache.GetConstEmails(pcEmplORDERAUTO);
    if (ToAdm='') then ToAdm:= fnGetSysAdresVlad(caeOnlyWorkDay);
    To_:= fnGetManagerMail(Filial, ToAdm);
    if (To_=ToAdm) then ToAdm:= '';
                                                    // ���������� �� CSS-�������
    s:= n_SysMailSend(To_, '��������� �� ������������ ������� ������ �������', Strings, nil, '', '', true);

    if (s<>'') then begin
      if Pos(MessText(mtkErrMailToFile), s)<1 then begin // ���� �������� � ����
        Response:= MessText(mtkErrSendMess, '�� ������������')+Delim+MessText(mtkMailWillSend);
        raise EBOBError.Create(s);

      end else begin  // ���� �� �������� � ����
        Strings.Insert(0, GetMessageFromSelf);
        if ToAdm<>'' then begin
          Strings.Add(#10'����� ������:'#10+s); // ��������� ����� ������ 1-� ��������
                                            // ���������� �� CSS-������� �������
          ToAdm:= n_SysMailSend(ToAdm, MessText(mtkErrSendMess, '�� ������������'), Strings, nil, '', '', true);
          if ToAdm<>'' then s:= s+#10+MessText(mtkErrSendMess, '�������')+#10+ToAdm+
                                #10'����� ������: '+Strings.Text;
        end;
        raise Exception.Create(s);
      end;
    end;

    Response:= '���� ��������� ���������� �� �����:'+Delim+'  '+nm+'. '+Delim+
               '����� ����� ��������� �� ��� E-mail:'+Delim+'  '+Client.Mail+'. '+Delim+
               '���� ��� ���������� �� �������� ����������, '+Delim+
               ' �������� ���� ����� � ���������� ������ '+Delim+
               ' ��������� ������������� ��������.';
    Result:= True;
  except
    on E: EBOBError do begin
      if Response='' then Response:= E.Message;
      fnWriteToLogPlus(ThreadData, lgmsUserError, nmProc, E.Message);
    end;
    on E: Exception do begin
      if Response='' then Response:= MessText(mtkErrSendMess, '�� ������������');
      fnWriteToLogPlus(ThreadData, lgmsSysError, nmProc, E.Message);
    end;
  end;
  prFree(Strings);
  SetLength(ar, 0);
end; }
//============================ ������������ ������ �� �������� ������� �� ������
function fnRepClientRequests(UserID: integer; StartTime, EndTime: TDateTime; var FName: string): string;
const nmProc = 'fnRepClientRequests'; // ��� ���������/�������  // ���������� ��� ����� ������
var Pool: TIBCntsPool;
    LogIBD: TIBDatabase;
    LogIBS: TIBSQL;
    MiddleFileName, FNameZip, Content, s: string;
    file_csv: textfile;
    iCount: integer;
    Client: TClientInfo;
begin
  FName:= '';
  iCount:= 0;
  LogIBD:= nil;
  LogIBS:= nil;
  try
    if not Cache.ClientExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotClientExist, IntToStr(UserID)));
    if (EndTime<Date) and cntsSufLOG.BaseConnected then Pool:= cntsSufLOG else Pool:= cntsLOG;
    if not Assigned(Pool) then raise EBOBError.Create(MessText(mtkErrConnectToDB));


    Client:= Cache.arClientInfo[UserID];
    MiddleFileName:= DirFileErr+'Requests_'+Client.Login+'_'+
               FormatDateTime('_dd.mm_(hh.nn.ss)', EndTime);
    FName:= MiddleFileName+'.csv';
    if FileExists(FName) and not SysUtils.DeleteFile(FName) then begin
      FName:= '';
      raise EBOBError.Create(MessText(mtkNotDelPrevFile));
    end;

    AssignFile(file_csv, FName);
    try
      filemode:= fmOpenReadWrite; //��������� ����
      if FileExists(FName) then Reset(file_csv) else ReWrite(file_csv);
      Append(file_csv);                            // ��������� �����:
      Content:= '������� ������������ � ������� <'+Client.Login+'>, ���������� '+
                Client.FirmName+' � ������� ������� � '+
                FormatDateTime(cDateTimeFormatY2S, StartTime)+
                ' �� '+FormatDateTime(cDateTimeFormatY2S, EndTime);
      WriteLn(file_csv, Content);
      Content:= '��� �������;����;�������;��������� �������';
      WriteLn(file_csv, Content);                  // ����� ���������
      try
        LogIBD:= Pool.GetFreeCnt;
        LogIBS:= fnCreateNewIBSQL(LogIBD, 'LogIBS_'+nmProc, -1, tpRead, true);
        LogIBS.SQL.Text:= 'SELECT THLGBEGINTIME, LCCOMMAND, LCCOMMDESCR,'+
          ' cast(THLGPARAMS as varchar(2400)) THLGPARAMS FROM LOGTHREADS'+
          ' left outer join LOGCOMMANDS on LCCOMMAND=THLGCOMMAND'+
          ' where THLGTYPE in ('+IntToStr(thtpWeb)+', '+IntToStr(thtpMail)+
          ') and not (THLGCOMMAND in ('+IntToStr(csWebAutentication)+', '+
          IntToStr(csBackJobAutentication)+')) and THLGUSERID='+IntToStr(UserID)+
          ' and THLGBEGINTIME between :DateStart and :DateEnd order by THLGBEGINTIME';
        LogIBS.ParamByName('DateStart').AsDateTime:= StartTime;    // ��������� �����
        LogIBS.ParamByName('DateEnd').AsDateTime  := EndTime;      // �������� �����
        LogIBS.ExecQuery;
        while not LogIBS.EOF do begin
          try
            s:= StringReplace(LogIBS.FieldByName('THLGPARAMS').AsString, #13#10,' ', [rfReplaceAll]);
            Content:= LogIBS.FieldByName('LCCOMMAND').AsString+';'+
              // ��������� ����� ����� ������, ����� Excel �� ������� ���
              FormatDateTime(' '+cDateTimeFormatY2S, LogIBS.FieldByName('THLGBEGINTIME').AsDateTime)+';'+
              LogIBS.FieldByName('LCCOMMDESCR').AsString+';'+s+';';
            WriteLn(file_csv, Content);
            inc(iCount);
          except
            on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
          end;
          TestCssStopException;
          LogIBS.Next;
        end;
      finally
        prFreeIBSQL(LogIBS);
        Pool.SetFreeCnt(LogIBD, True);
      end;
    finally
      CloseFile(file_csv);
    end;
    if iCount=0 then raise EBOBError.Create(MessText(mtkNotFoundDataUse));

    FNameZip:= MiddleFileName+'.zip';
    s:= ZipAddFiles(FNameZip, FName);
    if (s<>'') then raise Exception.Create(s);

    SysUtils.DeleteFile(FName);
    FName:= FNameZip;
  except
    on E: Exception do begin
      if FName<>'' then begin
        if FileExists(FName) then SysUtils.DeleteFile(FName);
        FName:= '';
      end;
      Result:= nmProc+': '+E.Message;
    end;
  end;
end;
//===================================== ����������/������������� ������� � ����
function SaveClientBlockType(BlockType, UserID: Integer; var BlockTime: TDateTime; EmplID: Integer=0): Boolean;
const nmProc = 'SaveClientBlockType';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    ss: String;
    command, cliType: Integer;
begin
  Result:= False;
  ORD_IBS:= nil;
//  ORD_IBD:= nil;
  try
    if (EmplID<1) then EmplID:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue
    else if not Cache.EmplExist(EmplID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist, IntToStr(EmplID)));

    case BlockType of
    cbBlockedBySearchLimit, cbBlockedTmpByConnLimit, cbBlockedByConnectLimit, cbBlockedByEmpl: begin // ����������
        command:= csBlockWebUser;
        cliType:= BlockType;
        case BlockType of
        cbBlockedBySearchLimit:  // ������������� � CSSweb ��-�� ���������� ������ ��������� �������� �� ����
            ss:= '���������� �������� ������� �� ������ ��������';
        cbBlockedTmpByConnLimit: // ������������� � CSSweb ��-�� ���������� ������ ��������� � ��.�������
            ss:= '���������� �������� ������� �� ������ �������� ��������';
        cbBlockedByConnectLimit: // ������������� � CSSweb ��-�� ���������� ������ ��������� � ��.�������
            ss:= '���������� �������� ������� �� ������ �������� ��������';
        cbBlockedByEmpl:         // ����������� � WebArm
            ss:= '���������� ����������� '+Cache.arEmplInfo[EmplID].EmplShortName;
        end;
      end; // ����������

    cbUnBlockedTmpByCSS, cbUnBlockedByEmpl: begin // �������������
        command:= csUnblockWebUser;
        cliType:= cbNotBlocked;
        case BlockType of
        cbUnBlockedTmpByCSS:     // ������������� � CSSweb
            ss:= '������������� �������� ������� ��������� ����������';
        cbUnBlockedByEmpl:       // ����������� � WebArm
            ss:= '������������� ����������� '+Cache.arEmplInfo[EmplID].EmplShortName;
        end;
      end; // �������������

    else raise EBOBError.Create('����������� �������');
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt;   // ����������/������������� �������
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'select rTIME from SetClientBlockMark('+IntToStr(command)+', '+
        IntToStr(BlockType)+', '+IntToStr(cliType)+', '+IntToStr(UserID)+', '+IntToStr(EmplID)+', :comm)';
      ORD_IBS.ParamByName('comm').AsString:= ss;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then BlockTime:= ORD_IBS.Fields[0].AsDateTime;
      ORD_IBS.Transaction.Commit;
      Result:= True;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+'('+IntToStr(UserID)+'): '+E.Message);
  end;
end;
//=============== ���������� ���� ����������� �������� (������������ ���� � �.�)  !!! ���������
function SetLongProcessFlag(cdlpKind: Integer; NotCheck: Boolean=False): Boolean;
// NotCheck=True - ��� �������� ������ ������
const nmProc = 'SetLongProcessFlag';
var //ORD_IBD: TIBDatabase;
    //ORD_IBS: TIBSQL;
    s: String;
begin
  Result:= False;
  if not (cdlpKind in [cdlpFillCache..cdlpForeignPr]) then Exit;
  s:= '';
//  ORD_IBS:= nil;
//  ORD_IBD:= nil;
  try
{
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select rOtherFlag from CheckLongProcessFlag('+IntToStr(ServerID)+', :ftxt)';
      ORD_IBS.ParamByName('ftxt').AsString:= cdlpNames[cdlpKind];
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Eof and ORD_IBS.Bof) then raise Exception.Create('Empty');
      s:= ORD_IBS.Fields[0].AsString;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    Result:= (s='');
}
    Result:= NotCheck;   // ��������
    with Cache do begin
      if not Result then begin
{        Result:= (LongProcessFlag=cdlpNotLongPr);
        if Result then
        if AllowWebArm then begin
//          Result:= (ImpCheck.CheckList.Count<1);
          if (LongProcessFlag=cdlpNotLongPr) // ����������� ����� ��� ������
            and (ImpCheck.CheckList.Count>0) then LongProcessFlag:= cdlpRepOrImp
          else if (LongProcessFlag=cdlpRepOrImp)
            and (ImpCheck.CheckList.Count<1) then LongProcessFlag:= cdlpNotLongPr;
        end; }
        Result:= (LongProcessFlag=cdlpNotLongPr);
      end;

      if Result then begin
        LongProcessFlag:= cdlpKind;
  //    end else begin
  //      LongProcessFlag:= cdlpForeignPr;
  //      cdlpNames[cdlpForeignPr]:= s;
      end;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  if flTest then prMessageLOGS(nmProc+': LongProcessFlag='+
                 cdlpNames[Cache.LongProcessFlag], fLogDebug, False);
end;
//==================== ����� ���� ����������� �������� (������������ ���� � �.�)  !!! ���������
function SetNotLongProcessFlag(cdlpKind: Integer): Boolean;
// ����� ����� ������ ����� �� ����
const nmProc = 'SetNotLongProcessFlag';
var //ORD_IBD: TIBDatabase;
    //ORD_IBS: TIBSQL;
    s: String;
begin
  Result:= False;
  if not (cdlpKind in [cdlpFillCache..cdlpForeignPr]) then Exit;
  s:= '';
//  ORD_IBS:= nil;
//  ORD_IBD:= nil;
  try
{
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select rOtherFlag from CheckLongProcessFlag('+IntToStr(ServerID)+', :ftxt)';
      ORD_IBS.ParamByName('ftxt').AsString:= cdlpNames[cdlpKind];
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Eof and ORD_IBS.Bof) then raise Exception.Create('Empty');
      s:= ORD_IBS.Fields[0].AsString;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    Result:= (s='');
}

    Result:= (Cache.LongProcessFlag=cdlpKind); // ��������

    with Cache do if Result then begin
      LongProcessFlag:= cdlpNotLongPr;
//    end else begin
//      LongProcessFlag:= cdlpForeignPr;
//      cdlpNames[cdlpForeignPr]:= s;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  if flTest then prMessageLOGS(nmProc+': LongProcessFlag='+
                 cdlpNames[Cache.LongProcessFlag], fLogDebug, False);
end;
//============================== must Free, ����� ������� �� ������������ � ����
function SearchWareNames(Template: string; IgnoreSpec: Integer=0;
         ManagID: Integer=-1; ByComments: boolean=False): Tai;
const nmProc = 'SearchWareNames';
// ���������� ������ ����� �������, ��������������� �� ������������
var list: TStringList;
    i, j: integer;
    fl: boolean;
    s, ss, mess: String;
begin
  SetLength(Result, 0);
  if not Assigned(Cache) or (Template='') then Exit;
  list:= fnCreateStringList(False, 100);
  mess:= '';
  with Cache do try
    s:= AnsiUpperCase(Template);
    ss:= fnDelSpcAndSumb(s);
    if ByComments and (IgnoreSpec=3) then ByComments:= False;
    j:= High(arWareInfo);

    for i:= 1 to j do try
      if not WareExist(i) then Continue;
      with Cache.arWareInfo[i] do begin
        if IsArchive or (PgrID<1) then Continue;                                           // ����� �� ����������
        if (PgrID=Cache.pgrDeliv) then Continue;                                           // ���������� ��������
        if (ManagID>-1) and (ManagID<>ManagerID) then Continue;                            // ����� �� ���������
        fl:= False;
        case IgnoreSpec of
          0: fl:= pos(s, Name)>0;
          1: fl:= pos(ss, NameBS)>0;
          2: fl:= (pos(s, Name)>0) or (pos(ss, NameBS)>0);
          3: if (Name=s) then begin // ������ ����������
               list.AddObject(Name, pointer(i));
               break;
             end;
        end;
        if not fl and ByComments then fl:= (pos(s, CommentUP)>0);
        if not fl then Continue;
        if list.Capacity=list.Count then list.Capacity:= list.Count+100;
        list.AddObject(Name, pointer(i));
      end; // with arWareInfo[i]
    except
      on E: Exception do
        mess:= mess+fnIfStr(mess='', '', #10)+'wareID='+IntToStr(i)+': '+E.Message;
    end; // for

    if list.Count<1 then Exit else if list.Count>1 then list.Sort;
    SetLength(Result, list.Count);
    for i:= 0 to list.Count-1 do Result[i]:= integer(list.Objects[i]);
  finally
    prFree(list);
    if mess<>'' then prMessageLOGS(nmProc+':'#10+Mess);
  end;
end;
//========== ���������� ��������������� ������ ����� ���� �������� ������ WareID
function fnGetAllAnalogs(WareID: integer; ManufID: integer=-1): Tai; // must Free
// sysID=0 - � ����, � ����
var i, Counter, ShowKind: integer;
    a1, a2, anw: Tai;
    ErrorPos: string;
    Ware: TWareInfo;
    list: TStringList;
begin
  ErrorPos:= '0';
  SetLength(Result, 0);
  list:= nil;
  try try
    if not Cache.WareExist(WareID) then
        raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    Ware:= Cache.arWareInfo[WareId];
    if Ware.IsArchive then exit;

    ShowKind:= Cache.GetConstItem(pcAnalogsShowKind).IntValue; // ����� ������ ��������
    ErrorPos:= '1';           // ������� ������������ ���-�� �������� ����� O�
    if (ShowKind in [ca_OE, ca_GR_OE, ca_Ex_OE,
      ca_TD_OE, ca_GR_Ex_OE, ca_GR_TD_OE, ca_Ex_TD_OE, ca_GR_Ex_TD_OE]) then begin
      Counter:= Cache.FDCA.fnGetListAnalogsWithManufacturer(WareID, ManufID, a1, a2);
      if (Counter<0) then Counter:= 0;
    end else Counter:= 0;

    ErrorPos:= '2';
    anw:= Ware.analogs; // ������� �� ����
    Counter:= Counter+Length(anw);
    if (Counter<1) then exit;

    list:= TStringList.Create; // ����� ������ ��� ����������
    list.Capacity:= Counter;

    for i:= 0 to High(anw) do if Cache.WareExist(anw[i]) then begin
      Ware:= Cache.arWareInfo[anw[i]];            // ������� �� ����
      if Ware.IsMarketWare then list.AddObject(Ware.Name, Pointer(Ware.ID));
    end;
    for i:= 0 to High(a1) do if Cache.WareExist(a1[i]) and (fnInIntArray(a1[i], anw)<0) then begin
      Ware:= Cache.arWareInfo[a1[i]];             // ������� ����� O� ManufID
      if Ware.IsMarketWare then list.AddObject(Ware.Name, Pointer(Ware.ID));
    end;
    for i:= 0 to High(a2) do if Cache.WareExist(a2[i]) and (fnInIntArray(a2[i], anw)<0)
                            and (fnInIntArray(a2[i], a1)<0) then begin
      Ware:= Cache.arWareInfo[a2[i]];             // ������� ����� O�
      if Ware.IsMarketWare then list.AddObject(Ware.Name, Pointer(Ware.ID));
    end;
    if list.Count>1 then list.Sort; // ���������� ������ ������

    SetLength(Result, list.Count);
    for i:= 0 to list.Count-1 do Result[i]:= Integer(list.Objects[i]);
  except
    on E: Exception do
      raise Exception.Create('fnGetAllAnalogs (ErrorPos='+ErrorPos+'): '+E.Message);
  end;
  finally
    SetLength(a1, 0);
    SetLength(a2, 0);
    SetLength(anw, 0);
    prFree(list);
  end;
end;
//========= ����� ������� (� ������ � ���������) �� ������������ � ���� (Webarm)
function SearchWaresTypesAnalogs(Template: string; var TypeCodes: Tai; IgnoreSpec: Integer=0;
         ManagID: Integer=-1; ByComments: boolean=False; OnlyWithPriceOrAnalogs: boolean=False;
         flSale: boolean=False; flCutPrice: boolean=False; flLamp: boolean=False): TObjectList; // must Free
const nmProc = 'SearchWaresTypesAnalogs';
// ���������� TObjectList, ��������������� �� ������������ ������, � Objects - TSearchWareOrOnum
// ���� TypeCodes ������ - � TypeCodes �������� ����
// ���� TypeCodes �� ������ - ����� ���-��� ������ �� �����
var iWare, j, pType: integer;
    flTypeSelection, flSelecting, flContaining, fl, flBreak, flMarket: boolean;
    s, ss, mess: String;
    ware: TWareInfo;
    arAnalogs, arTypes, ar: Tai;
begin
  Result:= TObjectList.Create;
  if not Assigned(TypeCodes) then SetLength(TypeCodes, 0);
  if not Assigned(Cache) or (Template='') then Exit;
  SetLength(arTypes, 0);

  mess:= '';
  flTypeSelection:= (Length(TypeCodes)>0); // ������� - ��������� �� TypeCodes ��� �������� ���� � TypeCodes

  flBreak:= False; // ��� ������� ����������
  with Cache do try
    s:= AnsiUpperCase(Template);

    if not (flSale or flCutPrice or flLamp) then begin
      if (IgnoreSpec in [1, 2]) then ss:= fnDelSpcAndSumb(s);
      if ByComments and (IgnoreSpec=3) then ByComments:= False;
    end;

    for iWare:= 1 to High(arWareInfo) do try
      if not WareExist(iWare) then Continue;
      ware:= Cache.GetWare(iWare, True);
      if not Assigned(ware) or (ware=NoWare) then Continue; // ����� �� �������
      if ware.IsArchive or (ware.PgrID<1) then Continue;    // ����� �� ����������
      if ware.IsPrize then Continue;                        // ����� ������
      if (ware.PgrID=Cache.pgrDeliv) then Continue;         // ����� ��������
      if (ManagID>0) and (ManagID<>ware.ManagerID) then Continue;         // ����� �� ���������

//------------------------------------------------------------- ����.���� ������
      if flSale then fl:= ware.IsSale              //------- ����� �� ����������
      else if flCutPrice then fl:= ware.IsCutPrice //----------- ����� �� ������
      else if flLamp then fl:= (pos(s, ware.CommentUP)>0) //---- ����� �� ������

      else begin //----------------------------------- ����� �� ����� ������
        fl:= False;
        case IgnoreSpec of
          0: fl:= pos(s, ware.Name)>0;
          1: fl:= pos(ss, ware.NameBS)>0;
          2: fl:= (pos(s, ware.Name)>0) or (pos(ss, ware.NameBS)>0);
          3: begin // ������ ����������
               fl:= (ware.Name=s);
               flBreak:= fl;
             end;
        end;
        if not fl and ByComments then fl:= (pos(s, ware.CommentUP)>0);
      end;
      if not fl then Continue;

      SetLength(arAnalogs, 0);
      SetLength(ar, 0);
      try
        arAnalogs:= fnGetAllAnalogs(iWare); // (Webarm)
        //---------------------- ����� �� ������� ����, �������� ��� �����.�������
        flMarket:= ware.IsMarketWare;
        if OnlyWithPriceOrAnalogs and not flMarket
          and (Length(arAnalogs)<1) and not ware.SatelliteExists() then Continue;

        //-------------------------------------------------- ����� �� ����� ������
        flSelecting:= not flTypeSelection; // True ��� ���������� ������, False ��� ������

        if not ware.IsInfoGr or ware.HasFixedType then begin // ������ � ����� - �� ������������ ����
          pType:= ware.TypeID;
          flContaining:= (fnInIntArray(pType, TypeCodes)>-1);
          if not flContaining then
            if flTypeSelection then Continue // ����� �������
            else prAddItemToIntArray(pType, TypeCodes); // ��������� ����� - �������� ����

        end else try // ����-������ ��� ���� - �� �������� (��� ������������ ������)
          arTypes:= ware.GetAnalogTypes; // ������ ����� ����� �������� (� �������)
          for j:= 0 to High(arTypes) do begin // ���������� ���� ��������
            pType:= arTypes[j];
            flContaining:= (fnInIntArray(pType, TypeCodes)>-1);
            if flTypeSelection and flContaining then begin
              flSelecting:= True;                    // ����� � ��� ���� � ������� �����
              break;
            end else if not flTypeSelection and not flContaining then
              prAddItemToIntArray(pType, TypeCodes); // ��������� ����� - �������� ����
          end;
          if not flSelecting then Continue; // ���� �� �������� �� ����� ��� ������
        finally
          SetLength(arTypes, 0);
        end;

        if (Result.Capacity=Result.Count) then Result.Capacity:= Result.Count+100;
        ar:= ware.GetSatellites;
        Result.Add(TSearchWareOrOnum.Create(iWare, Length(ar), True, flMarket, arAnalogs));
      finally
        SetLength(ar, 0);
        SetLength(arAnalogs, 0);
      end;

      if flBreak then Break; // ������ ����������
    except
      on E: Exception do
        mess:= mess+fnIfStr(mess='', '', #10)+'wareID='+IntToStr(iWare)+': '+E.Message;
    end; // for

  finally
    SetLength(arTypes, 0);
    if mess<>'' then prMessageLOGS(nmProc+':'#10+Mess);
  end;
end;
//================== ����� ������� (� ������ � ���������) �� ������������ � ����
function SearchWaresTypesAnalogs_new(Template: string; var TypeCodes: Tai; IgnoreSpec: Integer; // must Free
         ByComments, flSale, flCutPrice, flSemafores: boolean; ffp: TForFirmParams): TObjectList;
const nmProc = 'SearchWaresTypesAnalogs_new';
// ���������� TObjectList, ��������������� �� ������������ ������, � Objects - TSearchWareOrOnum
// ���� TypeCodes ������ - � TypeCodes �������� ����
// ���� TypeCodes �� ������ - ����� ���-��� ������ �� �����
// ����� ����� ��������� ��������, ���� ���� - ��������� �� �������
var iWare, j, pType: integer;
    flTypeSelection, flSelecting, flContaining, fl, flBreak, flMarket, flTypeByAnalogs: boolean;
    s, ss, mess: String;
    ware, analog: TWareInfo;
    arTypes: Tai;
    WA: TSearchWareOrOnum;
    tt: TTwoCodes;
begin
  Result:= TObjectList.Create;
  if not Assigned(TypeCodes) then SetLength(TypeCodes, 0);
  if not Assigned(Cache) or (Template='') then Exit;

  mess:= '';
  flTypeSelection:= (Length(TypeCodes)>0); // ������� - ��������� �� TypeCodes ��� �������� ���� � TypeCodes

  flBreak:= False; // ��� ������� ����������
  with Cache do try
    s:= AnsiUpperCase(Template);

    if not (flSale or flCutPrice) then begin
      if (IgnoreSpec in [1, 2]) then ss:= fnDelSpcAndSumb(s);
      if ByComments and (IgnoreSpec=3) then ByComments:= False;
    end;

    for iWare:= 1 to High(arWareInfo) do if Assigned(arWareInfo[iWare]) then try
//      if not WareExist(iWare) then Continue;
//      ware:= Cache.GetWare(iWare, True);
      ware:= arWareInfo[iWare];

if flWareForSearch then begin
      if not ware.ForSearch then Continue;
end else begin
      if not ware.IsWare or (ware=NoWare) then Continue;    // ����� �� �������
      if ware.IsArchive or (ware.PgrID<1) then Continue;    // ����� �� ����������
      if ware.IsPrize then Continue;                        // ����� ������
      if (ware.PgrID=Cache.pgrDeliv) then Continue;         // ����� ��������
      if ware.IsINFOgr and (ware.AnalogLinks.LinkCount<1) then Continue; // ����-����� ��� ��������
end; // if flWareForSearch

//------------------------------------------------------------- ����.���� ������
      if flSale then fl:= ware.IsSale              //------- ����� �� ����������
      else if flCutPrice then fl:= ware.IsCutPrice //----------- ����� �� ������
      else begin //----------------------------------- ����� �� ����� ������
        fl:= False;
        case IgnoreSpec of
          0: fl:= pos(s, ware.Name)>0;
          1: fl:= pos(ss, ware.NameBS)>0;
          2: fl:= (pos(s, ware.Name)>0) or (pos(ss, ware.NameBS)>0);
          3: begin // ������ ����������
               fl:= (ware.Name=s);
               flBreak:= fl;
             end;
        end;
        if not fl and ByComments then fl:= (pos(s, ware.CommentUP)>0);
      end;
      if not fl then Continue;

      SetLength(arTypes, 0); // ������ ����� ����� �������� (� �������)
      flTypeByAnalogs:= (ware.IsInfoGr and not ware.HasFixedType); // ����-����� ��� ����

      flMarket:= ware.IsMarketWare(ffp);
      if not flMarket and (ware.AnalogLinks.LinkCount<1) then Continue; // ����������� ����� ��� ��������

      WA:= TSearchWareOrOnum.Create(iWare, 0, True, flMarket);
      if flSemafores and flMarket then
        WA.RestSem:= GetContWareRestsSem(WA.ID, ffp, WA.SemTitle); // ��������� � ��������

      //-------------------------------------- ����� �� ������� ����, ��������
      for j:= 0 to ware.AnalogLinks.ListLinks.Count-1 do begin
        analog:= GetLinkPtr(ware.AnalogLinks.ListLinks[j]);
        if analog.IsINFOgr or not analog.IsMarketWare(ffp) then Continue; // ���� � ��� ��� ����������
        tt:= TTwoCodes.Create(analog.ID, -1);
        if flSemafores then begin // ���� ����� ��������
          tt.ID2:= GetContWareRestsSem(tt.ID1, ffp, tt.Name); // ��������� � ��������
          if ffp.HideZeroRests and (tt.ID2<1) then begin // ���� ���� - ��������� �������
            prFree(tt);
            Continue;
          end;
        end;
        if flTypeByAnalogs then prAddItemToIntArray(analog.TypeID, arTypes);
        WA.OLAnalogs.Add(tt);
      end; // for j:= 0 to
      if (WA.OLAnalogs.Count<1) and
        (not flMarket or (flSemafores and ffp.HideZeroRests and (WA.RestSem<1))) then begin
        prFree(WA);
        Continue;
      end;

      //-------------------------------------------------- ����� �� ����� ������
      flSelecting:= not flTypeSelection; // True ��� ���������� ������, False ��� ������

      if not flTypeByAnalogs then begin // ������ � ����� - �� ������������ ����
        pType:= ware.TypeID;
        flContaining:= (fnInIntArray(pType, TypeCodes)>-1);
        if not flContaining then
          if flTypeSelection then begin
            prFree(WA);
            Continue; // ����� �������
          end else prAddItemToIntArray(pType, TypeCodes); // ��������� ����� - �������� ����

      end else begin // ����-������ ��� ���� - �� �������� (��� ��)
        for j:= 0 to High(arTypes) do begin // ���������� ���� ��������
          pType:= arTypes[j];
          flContaining:= (fnInIntArray(pType, TypeCodes)>-1);
          if flTypeSelection and flContaining then begin
            flSelecting:= True;                    // ����� � ��� ���� � ������� �����
            break;
          end else if not flTypeSelection and not flContaining then
            prAddItemToIntArray(pType, TypeCodes); // ��������� ����� - �������� ����
        end; // for j:= 0 to High(arTypes)
        if not flSelecting then begin
          prFree(WA);
          Continue; // ���� �� �������� �� ����� ��� ������
        end;
      end;
      if (Result.Capacity=Result.Count) then Result.Capacity:= Result.Count+100;
      Result.Add(WA);

      if flBreak then Break; // ������ ����������
    except
      on E: Exception do
        mess:= mess+fnIfStr(mess='', '', #10)+'wareID='+IntToStr(iWare)+': '+E.Message;
    end; // for
  finally
    SetLength(arTypes, 0);
    if mess<>'' then prMessageLOGS(nmProc+':'#10+Mess);
  end;
end;
//====================================== ����� ������������� ������ �� ���������
function SearchWareOrigNums_new(Template: String; IgnoreSpec: Integer; // must Free
         var TypeCodes: Tai; flSemafores: boolean; ffp: TForFirmParams): TObjectList;
const nmProc = 'SearchWareOrigNums_new';
// ���������� ������ ����� ����.�������, ��������������� �� ������������, ������� ������
// ���� TypeCodes ������ - � TypeCodes �������� ����
// ���� TypeCodes �� ������ - ����� ���-��� ������ �� �����
// ����� ����� ��������� ��������, ���� ���� - ��������� �� �������
var i, j, pType: Integer;
    mess: String;
    flTypeSelection, flSelecting, flContaining: boolean;
    arTypes: Tai;
    WA: TSearchWareOrOnum;
    tt: TTwoCodes;
    OrigNum: TOriginalNumInfo;
    analog: TWareInfo;
begin
  Result:= TObjectList.Create;
  if not Assigned(TypeCodes) then SetLength(TypeCodes, 0);

  Template:= AnsiUpperCase(fnDelSpcAndSumb(Template));
  if Template='' then Exit;
  flTypeSelection:= (Length(TypeCodes)>0); // ������� - ��������� �� TypeCodes ��� �������� ���� � TypeCodes

  with Cache do try
    for i:= 1 to High(Cache.FDCA.arOriginalNumInfo) do try
      if not Cache.FDCA.OrigNumExist(i) then Continue;

      OrigNum:= Cache.FDCA.arOriginalNumInfo[i];
      if not Assigned(OrigNum.Links) or (OrigNum.Links.LinkCount<1) then Continue;

      if (pos(Template, OrigNum.OriginalNum)<1) then Continue;

      WA:= TSearchWareOrOnum.Create(OrigNum.ID, 0, False, False);
      SetLength(arTypes, 0); // ������ ����� ����� �������� (� �������)
      //-------------------------------------------- ����� �� ������� ��������
      for j:= 0 to OrigNum.Links.ListLinks.Count-1 do begin    // ���� �� ��������
        analog:= GetLinkPtr(OrigNum.Links.ListLinks[j]);
        if analog.IsINFOgr or not analog.IsMarketWare(ffp) then Continue; // ���� � ��� ��� ����������
        tt:= TTwoCodes.Create(analog.ID, -1);
        if flSemafores then begin // ���� ����� ��������
          tt.ID2:= GetContWareRestsSem(tt.ID1, ffp, tt.Name);
          if ffp.HideZeroRests and (tt.ID2<1) then begin // ���� ���� - ��������� �������
            prFree(tt);
            Continue;
          end;
        end;
        prAddItemToIntArray(analog.TypeID, arTypes); // �������� ����
        WA.OLAnalogs.Add(tt);
      end; // for j:= 0 to High(arAnalogs)
      if (WA.OLAnalogs.Count<1) then begin
        prFree(WA);
        Continue;
      end;

      //-------------------------------------------------- ����� �� ����� ������
      flSelecting:= not flTypeSelection; // True ��� ���������� ������, False ��� ������

      for j:= 0 to High(arTypes) do begin // ���������� ���� ��������
        pType:= arTypes[j];
        flContaining:= (fnInIntArray(pType, TypeCodes)>-1);
        if flTypeSelection and flContaining then begin
          flSelecting:= True;                    // ����� � ��� ���� � ������� �����
          break;
        end else if not flTypeSelection and not flContaining then
          prAddItemToIntArray(pType, TypeCodes); // ��������� ����� - �������� ����
      end;
      if not flSelecting then begin
        prFree(WA);
        Continue; // ���� �� �������� �� ����� ��� ������
      end;

      if (Result.Capacity=Result.Count) then Result.Capacity:= Result.Count+100;
      Result.Add(WA);
    except
      on E: Exception do
        mess:= mess+fnIfStr(mess='', '', #10)+'onID='+IntToStr(i)+': '+E.Message;
    end; // for
  finally
    SetLength(arTypes, 0);
    if mess<>'' then prMessageLOGS(nmProc+':'#10+Mess);
  end;
end;


{//======================= ����������� �������� WareSemafor ���� �������� �������
function SetSemMarkForClients(pSysID: Integer; SemMark: String='T'): String;
const nmProc='SetSemMarkForClients';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    i, j, ii: integer;
    Client: TClientInfo;
    Firma: TFirmInfo;
begin
  Result:= '';
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    ORD_IBD:= cntsORD.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'GB_IBS_'+nmProc, -1, tpWrite, True);
    ORD_IBS.SQL.Text:= 'UPDATE WEBORDERCLIENTS SET'+
      ' WOCLWARERESTSEMAFOR="'+SemMark+'" where WOCLCODE=:user';
    for i:= 1 to High(Cache.arFirmInfo) do begin
      if not Cache.FirmExist(i) then Continue;
      Firma:= Cache.arFirmInfo[i];
      if not (pSysID in [constIsAuto, constIsMoto]) then Continue;
      if not Firma.CheckSysType(pSysID) then Continue;
      for j:= 1 to High(Firma.FirmClients) do begin
        ii:= Firma.FirmClients[j];
        if not Cache.ClientExist(ii) then Continue;
        Client:= Cache.arClientInfo[ii];
        if (Client.WareSemafor=(SemMark='T')) then Continue;
        try
          with ORD_IBS.Transaction do if not InTransaction then StartTransaction;
          ORD_IBS.ParamByName('user').AsInteger:= ii;
          ORD_IBS.ExecQuery;
          with ORD_IBS.Transaction do if InTransaction then Commit;
          Client.WareSemafor:= (SemMark='T');
        except
          on E: Exception do begin
            with ORD_IBS.Transaction do if InTransaction then Rollback;
            prMessageLOGS(nmProc+': id='+IntToStr(i)+' '+E.Message, fLogCache);
          end;
        end;
        ORD_IBS.Close;
      end;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsORD.SetFreeCnt(ORD_IBD);
end;  }
//===================== ������ ������ ������� � ������� � ������ 3 ��� ���������
function GetModelNodeWareUsesAndTextsPartsView(ModelID, NodeID, WareID: Integer): TObjectList; // must Free Result
// � TObjectList[i] - TStringList, � TStringList - Delimiter=Char(iPart), QuoteChar=Char(iSrc) (���� ������������: +cWrongPart)
const nmProc = 'GetModelNodeWareUsesAndTextsPartsView';
var iType, iSrc, iPart, iWrong: integer;
    s, TypeName, str: String;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    lst: TStringList;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    Model: TModelAuto;
    flNewLst: Boolean;
begin
  Result:= TObjectList.Create;
  flNewLst:= True;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  lst:= nil;
  with Cache do begin
    with FDCA do begin
      if not Models.ModelExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));
      Model:= Models[ModelID];
      nodes:= AutoTreeNodesSys[Model.TypeSys];
    end;
    if not nodes.NodeExists(NodeID) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    if not Model.NodeLinks.LinkExists(NodeID) then
      raise EBOBError.Create('�� ������� ������ ������ � �����');
    node:= nodes[NodeID];
    if not node.IsEnding then raise EBOBError.Create('���� �� ��������');
    if NodeID<>node.MainCode then begin
      NodeID:= node.MainCode;
      if not nodes.NodeExists(NodeID) then
        raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID))+' (�������)');
      if not Model.NodeLinks.LinkExists(NodeID) then
        raise EBOBError.Create('�� ������� ������ ������ � ������� �����');
//      node:= nodes[NodeID];
    end;
    if not Model.NodeLinks.DoubleLinkExists(NodeID, WareID) then
      raise EBOBError.Create('�� ������� ������ ������ � ���� � �������');
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
      ORD_IBS.SQL.Text:= 'select * from GetModelNodeWareUsesPartsView_n('+
        IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(WareID)+')';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ����� ������
        if (iPart<1) then begin // ���������� ����������� ������ (���� ����)
          TestCssStopException;
          while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do ORD_IBS.Next;
          Continue;
        end;
        iSrc:= ORD_IBS.FieldByName('rSrc').AsInteger; // ��������
        iWrong:= ORD_IBS.FieldByName('rWrong').AsInteger; // ������� ������������
        if flNewLst then begin
          lst:= TStringList.Create;
          flNewLst:= False;
        end;
        while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // ������ �� 1 ������
          iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
          TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
          s:= '';
          while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
            and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // ������ �� 1 ���� ������
            s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
          end;
          s:= str+TypeName+fnIfStr(s='', '', ': '+s);  // ������ �� 1-�� ���� ������
          lst.Add(s);
        end; // while not ORD_IBS.Eof and (iPart=

        if lst.Count>0 then begin
          lst.Delimiter:= Char(iPart);
          if iWrong>0 then iSrc:= iSrc+cWrongPart; // ���� ������������ - +cWrongPart
          lst.QuoteChar:= Char(iSrc);
          Result.Add(lst);
          flNewLst:= True;
        end;
      end; //  while not ORD_IBS.Eof
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
      if not flNewLst then prFree(lst);
    end;
  end;
end;
//===================== ����������/������ ������� WRONG ������ ������� � �������
function SetUsageTextPartWrongMark(pModelID, pNodeID, pWareID, pPart, pUserID: Integer; flWrong: Boolean): String;
const nmProc = 'SetUsageTextPartWrongMark';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
  ORD_IBS:= nil;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pPart<1)    then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������ ������');
    if (pUserID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������������');
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'execute procedure SetUsageTextPartWrongMark('+IntToStr(pModelID)+
        ', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+IntToStr(pPart)+', '+
        IntToStr(pUserID)+', "'+fnIfStr(flWrong, 'T', 'F')+'")';
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrEditRecord);
      prMessageLOGS(nmProc+': '+E.Message);
    end;
  end;
end;
{//=========================== ������ TD->link_supplier_brand � ORD->BrandReplace
procedure CheckSuppliersBrandsLinks;
const nmProc = 'CheckSuppliersBrandsLinks'; // ��� ���������/�������
      maxStrLen = 1200;
var ordIBD, tdtIBD: TIBDatabase;
    ordIBS, tdtIBS: TIBSQL;
    pMainNode, lenS, lenGaStr, iCount, startCount, pUserID: Integer;
    s, sTime, GaStr: String;
  //---------------------------------
  procedure CheckPortion;
  begin
    tdtIBS.ParamByName('GaStr').AsString:= GaStr;
    tdtIBS.ExecQuery;
    tdtIBS.Close;
    GaStr:= '';
    lenGaStr:= 0;
  end;
  //---------------------------------
begin
  ordIBS:= nil;
//  tdtIBD:= nil;
  tdtIBS:= nil;
  with Cache do try
    ordIBD:= cntsOrd.GetFreeCnt;
    try
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
                                                  // �������� ������������� ������
      ordIBS.SQL.Text:= 'select BRRPGBCODE, BRRPTDCODE from BRANDREPLACE order by BRRPGBCODE, BRRPTDCODE';
      ordIBS.ExecQuery;
      if not (ordIBS.Bof and ordIBS.Eof) and
        (ordIBS.Fields[0].AsDateTime<=GetConstItem(pcCheckGAMainNodeTime).DateValue) then Exit;
      ordIBS.Close;

// if (exists(select * from data_suppliers where ds_mf_id = 501)) then insert into link_supplier_brand (lsbSupplier, lsbBrand) values ((select ds_id from data_suppliers where ds_mf_id = 501),35);

      sTime:= FormatDateTime(cDateTimeFormatY4S, Now);
      pUserID:= GetConstItem(pcEmplORDERAUTO).IntValue;

      tdtIBD:= cntsTDT.GetFreeCnt;
      try
        tdtIBS:= fnCreateNewIBSQL(tdtIBD, 'tdtIBS_'+nmProc, -1, tpWrite, true);
        tdtIBS.SQL.Text:= 'update link_GA_MainNode set lgm_Check=0'; // ���������� ������ ��������
        tdtIBS.ExecQuery;
        startCount:= tdtIBS.RowsAffected; // ���������� ���-�� �������
        tdtIBS.Close;
        tdtIBS.SQL.Text:= 'execute procedure check_ga_MainNode_Links(:GaStr)';
        tdtIBS.Prepare;

        ordIBS.SQL.Text:= 'select TRNAMAINCODE, TRNATDCODE from TREENODESAUTO'+
          ' where TRNATDGA="T" group by TRNAMAINCODE, TRNATDCODE order by TRNAMAINCODE';
        ordIBS.ExecQuery;
        iCount:= 0;
        GaStr:= '';
        lenGaStr:= 0;
        while not ordIBS.Eof do begin
          pMainNode:= ordIBS.fieldByName('TRNAMAINCODE').AsInteger;
          s:= '';
          while not ordIBS.Eof and (pMainNode=ordIBS.fieldByName('TRNAMAINCODE').AsInteger) do begin
            s:= s+fnIfStr(s='', '', ',')+ordIBS.fieldByName('TRNATDCODE').AsString; // �������� ������ ����� GA �� pMainNode
            inc(iCount);
            TestCssStopException;
            ordIBS.Next;
          end;
          s:= ordIBS.fieldByName('TRNAMAINCODE').AsString+'='+s; // ������ �� pMainNode
          lenS:= length(s);

          if (lenGaStr+lenS+1)>maxStrLen then CheckPortion;  // ���� ������ ��������� - ������������ � ������

          GaStr:= GaStr+fnIfStr(GaStr='', '', ';')+s;
          lenGaStr:= length(GaStr);
        end;
        ordIBS.Close;
        if GaStr<>'' then CheckPortion; // ��������� ������ - ������������

        if (iCount<startCount) then begin             // ������� �������������
          tdtIBS.SQL.Text:= 'delete from link_GA_MainNode where lgm_Check=0';
          tdtIBS.ExecQuery;
          tdtIBS.Close;
        end;
        tdtIBS.Transaction.Commit;
      finally
        prFreeIBSQL(tdtIBS);
        cntsTDT.SetFreeCnt(tdtIBD);
      end;
    finally
      prFreeIBSQL(ordIBS);
      cntsOrd.SetFreeCnt(ordIBD);
    end;

    s:= SaveNewConstValue(pcCheckGAMainNodeTime, pUserID, sTime);
    if s<>'' then prMessageLOGS(nmProc+': '+s);
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  TestCssStopException;
end;  }

//====================================== �������� ������ � ������ ������ �������
procedure CheckWorkLogins(userID: Integer; Login: String);
var i, j: Integer;
begin
  if (Login='') then exit;
  with Cache.arClientInfo.WorkLogins do begin // �������� ������ � ������ ������ �������
    i:= IndexOf(Login);
    if (i<0) then AddObject(Login, Pointer(userID))
    else begin
      j:= Integer(Objects[i]);
      if (j<>userID) then Objects[i]:= Pointer(userID);
    end;
  end;
end;
//============================================== �������� ������/������ ��������
procedure CheckClonedOrBlockedClients(LogFile: String='');
const nmProc = 'CheckClonedOrBlockedClients'; // ��� ���������/�������
var ordIBD: TIBDatabase;
    ordIBS: TIBSQL;
//    iCount,
    pUserID: Integer;
    s, sTime: String;
    tbegin, tend, tt: TDateTime;
begin
  ordIBS:= nil;
//  iCount:= 0;
  tend:= 0;
  tt:= Date;
  tbegin:= Cache.GetConstItem(pcCheckClonBlockClients).DateValue; // ����� ��������� ��������
  with Cache do try
    ordIBD:= cntsOrd.GetFreeCnt;
    try
      ordIBD.Close;  // ����� "������" ����������
      ordIBD.Open;
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
      s:= IntToStr(csWebCreateUser)+', '+IntToStr(csUnblockWebUser)+', '+IntToStr(csBlockWebUser);
      ordIBS.SQL.Text:= 'select c1.WOCLCODE user1, c1.WOCLLOGIN log1, c1.WOCLBLOCK block1,'+
        ' c2.WOCLCODE user2, c2.WOCLLOGIN log2, c2.WOCLBLOCK block2, s.PROTTIME'+
        ' from (select PROTWOCL, max(PROTTIME) PROTTIME from PROTOCOL'+
        '   where PROTCOMMAND in ('+s+') and PROTTIME>=:tbegin'+
        '     and PROTWOCL is not null group by PROTWOCL) s'+
        ' left join WEBORDERCLIENTS c1 on c1.WOCLCODE=s.PROTWOCL'+
        ' left join WEBORDERCLIENTS c2 on c2.WOCLCODE=c1.WOCLCLONEFROM order by PROTTIME';
      ordIBS.ParamByName('tbegin').AsDateTime:= max(tbegin, tt);
      ordIBS.ExecQuery;
      while not ordIBS.Eof do begin
        pUserID:= ordIBS.FieldByName('user1').AsInteger;
        s:= ordIBS.FieldByName('log1').AsString;
        if (pUserID>0) and (s<>'') then begin
          CheckWorkLogins(pUserID, s);
//          inc(iCount);
          if Cache.ClientExist(pUserID) then with Cache.arClientInfo[pUserID] do begin
            Login:= s;
            Blocked:= (ordIBS.FieldByName('block1').AsInteger<1);
          end;
        end;
        pUserID:= ordIBS.FieldByName('user2').AsInteger;
        s:= ordIBS.FieldByName('log2').AsString;
        if (pUserID>0) and (s<>'') then begin
          CheckWorkLogins(pUserID, s);
//          inc(iCount);
          if Cache.ClientExist(pUserID) then with Cache.arClientInfo[pUserID] do begin
            Login:= s;
            Blocked:= (ordIBS.FieldByName('block2').AsInteger<1);
          end;
        end;
        if (ordIBS.FieldByName('PROTTIME').AsDateTime>tend) then
          tend:= ordIBS.FieldByName('PROTTIME').AsDateTime;
        TestCssStopException;
        ordIBS.Next;
      end;
                   // ������ �� ����� � ����� ���� - ������������ ����� ��������
      if (tend=0) and (tbegin<=tt) then tend:= IncSecond(tt, 1);
    finally
      prFreeIBSQL(ordIBS);
      cntsOrd.SetFreeCnt(ordIBD);
      if (tend>0) then begin
        pUserID:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;
        sTime:= FormatDateTime(cDateTimeFormatY4S, tend);
        s:= Cache.SaveNewConstValue(pcCheckClonBlockClients, pUserID, sTime);
        if s<>'' then prMessageLOGS(nmProc+': '+s, LogFile, (LogFile<>''));
      end;
    end;
//    if flDebug then prMessageLOGS(nmProc+': '+IntToStr(iCount), fLogDebug, False);
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, LogFile, (LogFile<>''));
  end;
//  TestCssStopException;
end;

//====================================== ������ TD->GA � TreeNodesAuto->MainNode
procedure CheckGAMainNodesLinks(LogFile: String='');
const nmProc = 'CheckGAMainNodesLinks'; // ��� ���������/�������
      maxStrLen = 1200;
var ordIBD, tdtIBD: TIBDatabase;
    ordIBS, tdtIBS: TIBSQL;
    pMainNode, lenS, lenGaStr, pUserID: Integer;
    s, sTime, GaStr, sMain: String;
  //---------------------------------
  procedure CheckPortion;
  begin
    tdtIBS.ParamByName('GaStr').AsString:= GaStr;
    tdtIBS.ExecQuery;
    if tdtIBS.Fields[0].AsString<>'' then
      prMessageLOGS(nmProc+': ������ ��������: '+tdtIBS.Fields[0].AsString);
    tdtIBS.Close;
    GaStr:= '';
    lenGaStr:= 0;
  end;
  //---------------------------------
begin
  ordIBS:= nil;
//  tdtIBD:= nil;
  tdtIBS:= nil;
  with Cache do try
    ordIBD:= cntsOrd.GetFreeCnt;
    try
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
                                                  // �������� ������������� ������
      ordIBS.SQL.Text:= 'select max(TRNATIMEADD) from TREENODESAUTO'+
                        ' where TRNADTSYCODE<>'+IntToStr(constIsMoto);
      ordIBS.ExecQuery;
      if not (ordIBS.Bof and ordIBS.Eof) and
        (ordIBS.Fields[0].AsDateTime<=GetConstItem(pcCheckGAMainNodeTime).DateValue) then Exit;
      ordIBS.Close;

      sTime:= FormatDateTime(cDateTimeFormatY4S, Now);
      pUserID:= GetConstItem(pcEmplORDERAUTO).IntValue;

      tdtIBD:= cntsTDT.GetFreeCnt;
      try
        tdtIBS:= fnCreateNewIBSQL(tdtIBD, 'tdtIBS_'+nmProc, -1, tpWrite, true);
        tdtIBS.SQL.Text:= 'update link_GA_MainNode set lgm_Check=0'; // ���������� ������ ��������
        tdtIBS.ExecQuery;
        tdtIBS.Close;
        tdtIBS.SQL.Text:= 'select rErrorStr from check_ga_MainNode_Links(:GaStr)';
        tdtIBS.Prepare;

        ordIBS.SQL.Text:= 'select TRNAMAINCODE, TRNATDCODE from TREENODESAUTO'+
          ' where TRNATDGA="T" group by TRNAMAINCODE, TRNATDCODE order by TRNAMAINCODE';
        ordIBS.ExecQuery;
        GaStr:= '';
        lenGaStr:= 0;
        while not ordIBS.Eof do begin
          pMainNode:= ordIBS.fieldByName('TRNAMAINCODE').AsInteger;
          sMain:= ordIBS.fieldByName('TRNAMAINCODE').AsString;
          s:= '';
          while not ordIBS.Eof and (pMainNode=ordIBS.fieldByName('TRNAMAINCODE').AsInteger) do begin
            s:= s+fnIfStr(s='', '', ',')+ordIBS.fieldByName('TRNATDCODE').AsString; // �������� ������ ����� GA �� pMainNode
            TestCssStopException;
            ordIBS.Next;
          end;
          s:= sMain+'='+s; // ������ �� pMainNode
          lenS:= length(s);

          if (lenGaStr+lenS+1)>maxStrLen then CheckPortion;  // ���� ������ ��������� - ������������ � ������

          GaStr:= GaStr+fnIfStr(GaStr='', '', ';')+s;
          lenGaStr:= length(GaStr);
        end;
        ordIBS.Close;
        if GaStr<>'' then CheckPortion; // ��������� ������ - ������������

        tdtIBS.SQL.Text:= 'delete from link_GA_MainNode where lgm_Check=0'; // ������� �������������
        tdtIBS.ExecQuery;
        tdtIBS.Close;

        tdtIBS.Transaction.Commit;
      finally
        prFreeIBSQL(tdtIBS);
        cntsTDT.SetFreeCnt(tdtIBD);
      end;
    finally
      prFreeIBSQL(ordIBS);
      cntsOrd.SetFreeCnt(ordIBD);
    end;

    s:= SaveNewConstValue(pcCheckGAMainNodeTime, pUserID, sTime);
    if s<>'' then prMessageLOGS(nmProc+': '+s, LogFile, (LogFile<>''));
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, LogFile, (LogFile<>''));
  end;
  TestCssStopException;
end;
//===================== ��������� ������� ������� � ��������� � TDT (�� �������)
procedure CheckArticleWareMarks(LogFile: String=''; maxStrLen: Integer = 3000);
const nmProc = 'CheckArticleWareMarks'; // ��� ���������/�������
var ordIBD, tdtIBD: TIBDatabase;
    ordIBS, tdtIBS: TIBSQL;
    lenS, lenStr, pUserID, pIdent, iCount: Integer;
    s, Str: String;
    TimeProc: TDateTime;
  //---------------------------------
  procedure CheckPortion;
  begin
    tdtIBS.ParamByName('Str').AsString:= Str;
    tdtIBS.ExecQuery;
    tdtIBS.Close;
    Str:= '';
    lenStr:= 0;
  end;
  //---------------------------------
begin
  ordIBS:= nil;
//  tdtIBD:= nil;
  tdtIBS:= nil;
  iCount:= 0;
  TimeProc:= Now;
  with Cache do try
    if GetConstItem(pcNeedArticleWareMarks).IntValue<1 then Exit; // �������� �������������
    ordIBD:= cntsOrd.GetFreeCnt;
    pUserID:= GetConstItem(pcEmplORDERAUTO).IntValue;
    try
      tdtIBD:= cntsTDT.GetFreeCnt;
      try                                // ���������� ������������� ��������
        ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpRead, true);
        tdtIBS:= fnCreateNewIBSQL(tdtIBD, 'tdtIBS_'+nmProc, -1, tpRead, true);
        tdtIBS.SQL.Text:= 'select Ident from GetCheckArticleWareMarksIdent';
        tdtIBS.ExecQuery;
        if (ordIBS.Eof and ordIBS.Bof) then begin
          Randomize;
          pIdent:= Random(maxStrLen+1);
        end else pIdent:= tdtIBS.Fields[0].AsInteger;
        tdtIBS.Close;

        fnSetTransParams(tdtIBS.Transaction, tpWrite);
        tdtIBS.Transaction.StartTransaction;
        tdtIBS.SQL.Text:= 'execute procedure check_ArticleWareMarks('+IntToStr(pIdent)+', :Str)';
        tdtIBS.Prepare;

        ordIBS.SQL.Text:= 'select WATDARTICLE, WATDARTSUP, count(WATDWARECODE) wareCount'+
          ' from WAREARTICLETD where WATDWRONG="F" group by WATDARTICLE, WATDARTSUP';
        ordIBS.ExecQuery;
        Str:= '';
        lenStr:= 0;
        s:= '';
        while not ordIBS.Eof do begin
          s:= ordIBS.fieldByName('wareCount').AsString+'<'+
              ordIBS.fieldByName('WATDARTSUP').AsString+'>'+
              ordIBS.fieldByName('WATDARTICLE').AsString; // ������ �� WATDARTICLE
          lenS:= length(s);

          if (lenStr+lenS+1)>maxStrLen then CheckPortion;  // ���� ������ ��������� - ������������ � ������

          Str:= Str+fnIfStr(Str='', '', ';')+s;
          lenStr:= length(Str);
          Inc(iCount);
          TestCssStopException;
          ordIBS.Next;
        end;
        ordIBS.Close;
        if Str<>'' then CheckPortion; // ��������� ������ - ������������

                          // ���������� �������� ������� ������� � �������������
        tdtIBS.SQL.Text:= 'update articles set art_warecode=0 where ART_CheckWARE<>'+
                          IntToStr(pIdent)+' and art_warecode>0';
        tdtIBS.ExecQuery;
        tdtIBS.Close;
        tdtIBS.Transaction.Commit;
      finally
        prFreeIBSQL(tdtIBS);
        cntsTDT.SetFreeCnt(tdtIBD);
      end;
    finally
      prFreeIBSQL(ordIBS);
      cntsOrd.SetFreeCnt(ordIBD);
    end;

    prMessageLOGS(nmProc+': '+IntToStr(iCount)+' articles - '+GetLogTimeStr(TimeProc), LogFile);
                                       // ���������� ������� ��������
    s:= SaveNewConstValue(pcNeedArticleWareMarks, pUserID, '0');
    if s<>'' then prMessageLOGS(nmProc+': '+s, LogFile);
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, LogFile);
  end;
  TestCssStopException;
end;
//============================== �������� ����, �������� ��������� DecHour �����
procedure TestLastFirms(DecHour: Integer=1);
const nmProc = 'TestLastFirms'; // ��� ���������/�������
var ibd: TIBDatabase;
    ibs: TIBSQL;
    FirmID, UserID, fCount: Integer;
    LocalStart, dd: TDateTime;
begin
  if DecHour<1 then Exit;
  ibs:= nil;
  LocalStart:= now();
  fCount:= 0;
  try
    ibd:= cntsORD.GetFreeCnt('', '', '', True); // IgnoreTimer=True - �� ��������� �� �������
    try
      dd:= Now;
      if DecHour>0 then dd:= incHour(dd, -DecHour);
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);
      ibs.SQL.Text:= 'select woclfirmcode from weborderclients'+
                     ' where wocllastactiontime>:dd group by woclfirmcode';
      ibs.ParamByName('dd').AsDateTime:= dd;
      ibs.ExecQuery;
      while not ibs.Eof do begin
        FirmID:= ibs.fields[0].AsInteger;
        Cache.TestFirms(FirmID, True, True);
        if Cache.FirmExist(FirmID) then begin
          UserID:= Cache.arFirmInfo[FirmID].SUPERVISOR;
          Cache.TestClients(UserID, True, True); // ���������� �����
        end;
        TestCssStopException;
        ibs.Next;
        Inc(fCount);
      end;
    finally
      prFreeIBSQL(ibs);
      cntsORD.SetFreeCnt(ibd, True);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  prMessageLOGS(nmProc+': '+IntToStr(fCount)+' �/� - '+
    GetLogTimeStr(LocalStart), fLogCache, false);
end;
//================================ �������� ������������ ���� � ���� �����������
procedure TestLogFirmNames;
const nmProc = 'TestLogFirmNames'; // ��� ���������/�������
var ibd: TIBDatabase;
    ibs: TIBSQL;
    pFirmID, iCount, i, len: Integer;
    LocalStart: TDateTime;
    lst: TStringList;
    fName, s: String;
begin
  ibs:= nil;
  ibd:= nil;
  LocalStart:= now();
  iCount:= 0;
  len:= 40;
  try
    for i:= High(Cache.arFirmInfo) downto 1 do
      if Assigned(Cache.arFirmInfo[i]) then Cache.arFirmInfo[i].State:= False;

    lst:= TStringList.Create;
    try
      ibd:= cntsLog.GetFreeCnt('', '', '', True); // IgnoreTimer=True - �� ��������� �� �������
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);

      ibs.SQL.Text:= 'select ff.RDB$FIELD_LENGTH fsize'+
        ' from rdb$relation_fields f, rdb$fields ff'+
        ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE'+
        '   and f.RDB$RELATION_NAME=:table and f.RDB$FIELD_NAME=:fname';
        ibs.ParamByName('table').AsString:= 'LOGFIRMNAMES';
        ibs.ParamByName('fname').AsString:= 'LFNFIRMNAME';
      ibs.ExecQuery;
      if not (ibs.Eof and ibs.Bof) and (ibs.FieldByName('fsize').AsInteger>0) then
        len:= ibs.FieldByName('fsize').AsInteger;
      ibs.Close;

      ibs.SQL.Text:= 'select LFNFIRMCODE, LFNFIRMNAME from LOGFIRMNAMES';
      ibs.ExecQuery; // ��������� �� �����, ���.��� ���� � ���� �����������
      while not ibs.Eof do begin
        pFirmID:= ibs.fields[0].AsInteger;
        fName:=  ibs.fields[1].AsString;
        if Cache.FirmExist(pFirmID) then with Cache.arFirmInfo[pFirmID] do begin
          s:= copy(Name, 1, len);
          if (fName<>s) then lst.AddObject(s, Pointer(pFirmID)); // � ������ �� ��������
          State:= True;
        end;
        TestCssStopException;
        ibs.Next;
      end;
      ibs.Close;

      for i:= High(Cache.arFirmInfo) downto 1 do if Assigned(Cache.arFirmInfo[i]) then
        with Cache.arFirmInfo[i] do begin    // ���� �����, ���.�� ���������
          if State then State:= False
          else if not Arhived and (FirmContracts.count>0) then
            lst.AddObject(copy(Name, 1, len), Pointer(ID));
        end;

      iCount:= lst.Count;
      if (iCount>0) then begin
        fnSetTransParams(ibs.Transaction, tpWrite, True);
        ibS.SQL.Text:= 'execute procedure CheckLogFirmName(:aFirm, :aFName)';
        for i:= 0 to lst.Count-1 do begin
          ibS.ParamByName('aFirm').AsInteger:= Integer(lst.Objects[i]);
          ibS.ParamByName('aFName').AsString:= lst[i];
          ibs.ExecQuery;
        end;
        ibs.Transaction.Commit;
      end;
    finally
      prFreeIBSQL(ibs);
      cntsLog.SetFreeCnt(ibd, True);
      prFree(lst);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  prMessageLOGS(nmProc+': '+IntToStr(iCount)+' �/� - '+
    GetLogTimeStr(LocalStart), fLogCache, false);
end;
//================= �������� ������������ �/� �������� ���������� (Web & WebArm)
function CheckFirmFilterConditions(FirmID: Integer; flFirmsAdd, flAuto, flMoto: Boolean;
         Filials, Classes, Types, Firms: TIntegerList): Boolean;
const nmProc = 'CheckFirmFilterConditions'; // ��� ���������/�������
var j: Integer;
    flNot: Boolean;
    firm: TFirmInfo;
begin
  Result:= False;
  if not Cache.FirmExist(FirmID) then Exit;
  try
    firm:= Cache.arFirmInfo[FirmID];
    if firm.Arhived or firm.Blocked or (firm.SUPERVISOR<1) then Exit;

//    if not ((flAuto and firm.IsAUTOFirm) or (flMoto and firm.IsMOTOFirm)) then Exit;

    if (Firms.Count>0) then begin  // ��������� ����
      flNot:= (Firms.IndexOf(FirmID)<0);
      if flFirmsAdd then begin  //------------------------------ ���� ����������
        if not flNot then begin // ���� � ������ - ������ �� ���������
          Result:= True; // ����� ��������
          Exit;                            // ��� � ������ + ��� ��.������� - �� ��������
        end else if (Types.Count<1) and (Classes.Count<1) and (Filials.Count<1) then Exit;
      end else                  //------------------------------ ���� ����������
        if not flNot then Exit; // ���� � ������ - �� ��������
    end;
                                         // ��������� ���
    if (Types.Count>0) and (Types.IndexOf(firm.FirmType)<0) then Exit;
                                         // ��������� ������
    if (Filials.Count>0) and (Filials.IndexOf(firm.GetDefContract.Filial)<0) then Exit;

    if (Classes.Count>0) then begin      // ��������� ���������
      flNot:= True;
      for j:= 0 to Classes.Count-1 do begin
        flNot:= (firm.FirmClasses.IndexOf(Classes[j])<0);
        if not flNot then break;
      end;
      if flNot then Exit;
    end;

    Result:= True; // ����� ��������
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;

//-------------------------------------- �������� ��������� �������� ��� �������
procedure CheckStopExecute(pUserID: Integer; ThreadData: TThreadData);
begin
  if Assigned(ThreadData) then
    prStopProcess(pUserID, ThreadData.ID) // �������� ��������� ��������
  else TestCssStopException; // �������� ��������� �������
end;
//--------------------------------------------- ����������� ��������� ����������
procedure SetExecutePercent(pUserID: Integer; ThreadData: TThreadData; Percent: Double);
begin
  if Assigned(ThreadData) then
    ImpCheck.SetProcessPercent(pUserID, ThreadData.ID, Percent);
end;
//======================================== ���������� ���� nf �� dirold � dirnew
function RenameErrFile(nf, dirold, dirnew: string; flPutOff: Boolean=False): string;
const nmProc = 'RenameErrFile'; // ��� ���������/�������
var i: Integer;
    list: TStringList;
    nfile, s, prefix: String;
begin
  list:= TStringList.Create;
  try
    if flPutOff then prefix:= 'p' // �������� ���������� ����
    else prefix:= 'e';            // �������� ������� ����
    nfile:= fnTestDirEnd(dirnew)+prefix+'_'+nf; // ����� ��� �����
    i:= 0;
    Result:= '';
    if not DirectoryExists(dirnew) then CreateDir(dirnew); // ���� ����� ��� - �������
    while FileExists(nfile) do begin
      Inc(i);
      nfile:= fnTestDirEnd(dirnew)+prefix+IntToStr(i)+'_'+nf;
    end;
    if RenameFile(fnTestDirEnd(dirold)+nf, nfile) then
      prMessageLOGS(nmProc+': ���� '+nf+' ��������� � ����� '+dirnew) // ����� � log
    else Result:= Result+fnIfStr(Result='', '', #13#10)+'���� '+nf+' �� ������� ����������� � ����� '+dirnew;
    if not flPutOff then begin
      list.Add('Error processing file '+nf); // ��������� ��������� ������ ��-�� Vlad
      s:= fnGetSysAdresVlad(caeOnlyWorkDay);
      list.Insert(0, GetMessageFromSelf);
      s:= n_SysMailSend(s, 'Error processing file', list, nil, '', '', true);
      if (s<>'') then
        Result:= Result+fnIfStr(Result='', '', #13#10)+'������ �������� ������ �� ������ ��������� ����� '+nf;
    end;
  finally
    prFree(list);
  end;
end;
//=========================================== ��������� ������ � ������� �������
function prSendMailWithClientPassw(Kind: TKindCliMail; Login, Password, Mail: String;
         ThreadData: TThreadData; FirmName: String=''; lst: TStringList=nil): string;
//  TKindCliMail = (kcmSetMainUser, kcmRegister, kcmCreateUser, kcmRemindPass);
const nmProc = 'prSendMailWithClientPassw'; // ��� ���������/�������
var Strings: TStringList;
    errmess, subj, s1, s2: string;
    i: Integer;
    fl: Boolean;
begin
  Result:= '';
  fl:= False;
  try
    Strings:= TStringList.Create;
    Strings.Add('������������!');
    Strings.Add('');
    if (Kind=kcmRemindPass) then begin
      subj:= '�������������� ������ �� ����� ';
{      if not Assigned(lst) or (lst.Count<1) then begin
        Strings.Add('�����: '+Login);
        Strings.Add('������: '+Password);
        Strings.Add('������� ������ ����������� ����������� '+FirmName);
      end else  }
      for i:= 0 to lst.Count-1 do begin
        Strings.Add(lst[i]);
        fl:= fl or (pos('������', lst[i])>0);
      end;
      if not fl then begin  // ���� ��� ������     // ������ 02.05.2018
        Strings.Add('');
        Strings.Add('���� �� �� ����������� �������������� ������,');
        Strings.Add('����������� ��� ������� ���.'); // ������� 16.04.2018
      end;
//      Strings.Add('��������� ��� ������ � ������ ��������� '+Cache.GetConstItem(pcUIKdepartmentMail).StrValue);
    end else begin
      subj:= '������ � ����� ';
//      Strings.Add('������������ ������ � ����� http://order.vladislav.ua');
      Strings.Add('�����: '+Login);
      Strings.Add('������: '+Password);
    end;
    Strings.Add('');
    Strings.Add('� ���������,');
    Strings.Add('�������� "���������"'); // ������� 16.04.2018
//    Strings.Add('������� ���������');

//    errmess:= n_SysMailSend(Mail, subj+'order.vladislav.ua', Strings, nil, '', '', true);
    errmess:= n_SysMailSend(Mail, subj+'order.vladislav.ua', Strings, nil, cNoReplayEmail, '', true);

    if errmess<>'' then begin
      fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', errmess, '');
      s1:= '��������� ������ ��� �������� ������ � �������.';
      s2:= '������ ����� �������� ����� ������� �������������� ������';
      case Kind of
       kcmSetMainUser:
         Result:= '������� ������ ������� �������. '+s1+
                  ' �������� ������� �����, '+s2;
       kcmCreateUser:
         Result:= '������� ������ ������� �������. '+s1+
                  ' �������� ������ ���������� �����, '+s2;
       kcmRegister:
         Result:= s1+' �������� ������� �����, '+s2;
       kcmRemindPass:
         Result:= s1+' ���������� ��������� ������ ����� ��������� �����.'+
                  ' ���� ������ ���������� ���������, ��������'+
                  ' � ������ ��������� ��� e-mail - ��������'+
                  ' ����� ������ ���� ������� � ���� �����������.';
      else Result:= s1;
      end; // case Kind of
    end;
  finally
    prFree(Strings);
  end;
end;
(*//=================================== �������� ��������� ����� � �������� ������
function CheckTextFirstUpAndSpaces(txt: String): String;
var xChar, xCharU: String;
begin
  Result:= txt;
  if (Result<>'') then Result:= trim(Result);               // ������� ������� �������
  if (Result<>'') then Result:= StringReplace(Result, '  ', ' ', [rfReplaceAll]); // ������� ������� �������
  if (Result<>'') then begin
    xChar:= copy(Result, 1, 1);
    xCharU:= AnsiUpperCase(xChar);                 // ����� - � ��������� �����
    if (xChar<>xCharU) then Result:= xCharU+copy(Result, 2);
  end
end;    *)


//******************************************************************************
//                          ���������� ��������
//******************************************************************************
//=========================== ������ ��������� ������ ���������� �� ������, ����
function GetAvailableSelfGetTimesList(DprtID: Integer; pDate: TDateTime;
         var stID: Integer; var SL: TStringList; flWithSVKDelay: Boolean=False): String;
// String- ����� ��������, Object- ��� ������� ��������
// ���� stID>0 � ���������� - ������ ����
const nmProc = 'GetAvailableSelfGetTimesList'; // ��� ���������/�������
var i, TestTime, TimeMin, TimeMax, SVKDelay: Integer;
    s: String;
    st: TShipTimeItem;
    flFound: Boolean;
    lst: TList;
    dprt: TDprtInfo;
begin
  Result:= '';
  if not Assigned(SL) then SL:= TStringList.Create;
  flFound:= (stID<1);
  lst:= TList.Create;
  SVKDelay:= 0;
  try
    if not Cache.DprtExist(DprtID) then
      raise EBOBError.Create('�� ������ ����� ��������');
    dprt:= Cache.arDprtInfo[DprtID];

    s:= dprt.CheckShipAvailable(pDate, 0, 0, False, False);
    if (s<>'') then raise EBOBError.Create(s);

    if flWithSVKDelay then
      SVKDelay:= Cache.GetConstItem(pcSVKSelfDelayMinutes).IntValue;
                                              // ������� ������ �������� �� ����
    s:= dprt.GetShipTimeLimits(pDate, TimeMin, TimeMax, SVKDelay, False);
    if (s<>'') then raise EBOBError.Create(s);

    for i:= 0 to Cache.ShipTimes.ItemsList.Count-1 do begin
      st:= Cache.ShipTimes.ItemsList[i];
      TestTime:= (st.Hour*60+st.Minute)*60;
      if (TestTime<TimeMin) or (TestTime>TimeMax) then Continue; // ��������� �����
      lst.Add(st);  // ���� �������� - ��������� � ������
      flFound:= flFound or (st.ID=stID);
    end;
    if not flFound then // ������ ����� �� ������ � ������
      if Cache.ShipTimes.ItemExists(stID) then begin // ������ ����� ����
        st:= Cache.ShipTimes[stID];
        lst.Add(st);                          // ��������� � ������ ������ �����
        stID:= -stID;                         // ������ ���� � ���� -> ����������
      end else      // ������ ����� �� �������
        stID:= 0;                             // �������� ���
    if (lst.Count>1) then lst.Sort(ShipTimesSortCompare); // ���������
    for i:= 0 to lst.Count-1 do begin
      st:= lst[i];
      SL.AddObject(st.Name, Pointer(st.ID)); // ����� ��������, ���
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
  prFree(lst);
end;
//====================================== ������ ��������� ��� �������� �� ������
function GetAvailableShipDatesList(DprtID, iDate: Integer; var SL: TStringList): String;
// String- ������ ���� ��������, Object- ����� �������� ���� �������� (������ ����)
// ���� iDate>0 � ���� ���������� - ������ ����
const nmProc = 'GetAvailableShipDatesList'; // ��� ���������/�������
var i, TestTime, DateInt, DayCount: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    s: String;
    flFound: Boolean;
    dprt: TDprtInfo;
    pDate: TDateTime;
    sch: TTwoCodes;
begin
  Result:= '';
  if not Assigned(SL) then SL:= TStringList.Create;
  try
    if not Cache.DprtExist(DprtID) then
      raise EBOBError.Create('�� ������ ����� ��������');
    dprt:= Cache.arDprtInfo[DprtID];

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // ������� ��������� ������� �����
    TestTime:= iHour*60+iMinute+dprt.DelayTime;  // ������������ ������
    TestTime:= TestTime*60;
    DayCount:= Cache.GetConstItem(pcShipChoiceDays).IntValue; // ���-�� ���� ��� ������

    for i:= 0 to dprt.Schedule.Count-1 do begin
      pDate:= Date()+i;
      DateInt:= Trunc(pDate);
      flFound:= (iDate>0) and (DateInt=iDate);
      sch:= TTwoCodes(dprt.Schedule[i]);

      if ((sch.ID1<1) and (sch.ID2<1))         // ���� ����������
        or ((i=0) and (TestTime>sch.ID2)) then // ������� ��������� ������� �����
        if flFound then DateInt:= -DateInt else Continue;

      s:= FormatDateTime(cDateFormatY4, pDate);
      case DayOfTheWeek(pDate) of
        1: s:= s+' - ��';
        2: s:= s+' - ��';
        3: s:= s+' - ��';
        4: s:= s+' - ��';
        5: s:= s+' - ��';
        6: s:= s+' - ��';
        7: s:= s+' - ��';
      end;
      if (i=0) then s:= s+', �������';
      if (i=1) then s:= s+', ������';
      SL.AddObject(s, Pointer(DateInt)); // ���� �������� - ��������� � ������
      if (SL.Count>=DayCount) then break; // DayCount ���.����
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;
(*//====================================== ������ ��������� ��� �������� �� ������
function GetAvailableShipDatesList(DprtID, iDate: Integer;
         var SL: TStringList; flWithSVKDelay: Boolean=False): String;
// String- ������ ���� ��������, Object- ����� �������� ���� �������� (������ ����)
// ���� iDate>0 � ���� ���������� - ������ ����
const nmProc = 'GetAvailableShipDatesList'; // ��� ���������/�������
var i, TestTime, DateInt, DayCount: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    s: String;
    flFound: Boolean;
    dprt: TDprtInfo;
    pDate: TDateTime;
    sch: TTwoCodes;
begin
  Result:= '';
  if not Assigned(SL) then SL:= TStringList.Create;
  try
    if not Cache.DprtExist(DprtID) then
      raise EBOBError.Create('�� ������ ����� ��������');
    dprt:= Cache.arDprtInfo[DprtID];

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // ������� ��������� ������� �����
    TestTime:= iHour*60+iMinute+dprt.DelayTime;  // ������������ ������
    if flWithSVKDelay then                       // ������������ ���
      TestTime:= TestTime+Cache.GetConstItem(pcSVKShipDelayMinutes).IntValue;
    TestTime:= TestTime*60;

{    DayCount:= 1; // ��������� ���-�� ���� ��� ������
    with fnSplit(',', Cache.GetConstItem(pcAccountStorageDays).StrValue) do try  // TStringList
      for i:= 0 to Count-1 do begin
        DateInt:= StrToIntDef(Strings[i], 0);
        if (DayCount<DateInt) then DayCount:= DateInt;
      end;
    finally
      Free;
    end;  }
    DayCount:= Cache.GetConstItem(pcShipChoiceDays).IntValue; // ���-�� ���� ��� ������

    for i:= 0 to dprt.Schedule.Count-1 do begin
      pDate:= Date()+i;
      DateInt:= Trunc(pDate);
      flFound:= (iDate>0) and (DateInt=iDate);
      sch:= TTwoCodes(dprt.Schedule[i]);

      if ((sch.ID1<1) and (sch.ID2<1))         // ���� ����������
        or ((i=0) and (TestTime>sch.ID2)) then // ������� ��������� ������� �����
        if flFound then DateInt:= -DateInt else Continue;

      s:= FormatDateTime(cDateFormatY4, pDate);
      case DayOfTheWeek(pDate) of
        1: s:= s+' - ��';
        2: s:= s+' - ��';
        3: s:= s+' - ��';
        4: s:= s+' - ��';
        5: s:= s+' - ��';
        6: s:= s+' - ��';
        7: s:= s+' - ��';
      end;
      if (i=0) then s:= s+', �������';
      if (i=1) then s:= s+', ������';
      SL.AddObject(s, Pointer(DateInt)); // ���� �������� - ��������� � ������
      if (SL.Count>=DayCount) then break; // DayCount ���.����
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end; *)
//======================================= �������� ���������� �������� ��� �����
function CheckAccountShipParams(delivType, ContID, DprtID: Integer; var pShipDate: TDateTime;
         var DestID, ttID, smID, stID: Integer; WithSVKDelay: Boolean): String;
const nmProc = 'CheckAccountShipParams'; // ��� ���������/�������
var ibd: TIBDatabase;
    ibs: TIBSQL;
    s, strErr: String;
    dprt: TDprtInfo;
    SVKDelay: Integer;
begin
  ibs:= nil;
  ibd:= nil;
  Result:= '';
  s:= '';
  SVKDelay:= 0;
  try
    if not (DelivType in [cDelivTimeTable, cDelivReserve, cDelivSelfGet, cDelivClientNow]) then
      raise EBOBError.Create('����������� ��� �������� - '+IntToStr(DelivType));
    if not Cache.Contracts.ItemExists(ContID) then
      raise EBOBError.Create('�� ������ ��������, ��� - '+IntToStr(ContID));
    if not Cache.DprtExist(DprtID) then
      raise EBOBError.Create('�� ������ �����, ��� - '+IntToStr(DprtID));

    dprt:= Cache.arDprtInfo[DprtID];
    case delivType of
      cDelivReserve: begin // ������
        pShipDate:= 0;
        DestID:= 0;
        ttID:= 0;
        smID:= 0;
        stID:= 0;
      end; // cDelivReserve

      cDelivClientNow: begin // ������ �� ������ - ������ �������  ???
        strErr:= dprt.CheckShipAvailable(pShipDate, 0, 0, False, False);
        if (strErr<>'') then raise EBOBError.Create(strErr);
        DestID:= 0;
        ttID:= 0;
        smID:= Cache.GetConstItem(pcCliNowShipMethodCode).IntValue;
        stID:= 0;
      end; // cDelivClientNow

      cDelivSelfGet: begin // ���������
        DestID:= 0;
        ttID:= 0;
        smID:= Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue;
        if WithSVKDelay then
          SVKDelay:= Cache.GetConstItem(pcSVKSelfDelayMinutes).IntValue;
        try // ��������� �����
          if (stID<1) then raise EBOBError.Create('����������� ����� ��������');
          strErr:= dprt.CheckShipAvailable(pShipDate, stID, SVKDelay, True, False);
          if (strErr<>'') then raise EBOBError.Create(strErr);
        except
          on E: Exception do begin
            stID:= 0;
            raise EBOBError.Create(E.Message);
          end;
        end;
      end; // cDelivSelfGet

      cDelivTimeTable: try // ��������
        if (DestID<1) then raise EBOBError.Create('����������� �������� �����');
        if (ttID<1) then raise EBOBError.Create('����������� ����������');
        try
          ibd:= cntsGRB.GetFreeCnt;
          ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);
          ibs.SQL.Text:= 'select rSMethodID, rSTimeID'+
            ' from Vlad_CSS_GetContDestTimeTables1'+
            '('+IntToStr(contID)+', '+IntToStr(DestID)+', '+IntToStr(DprtID)+
            ', :pDate) where RttID='+IntToStr(ttID);
          IBS.ParamByName('pDate').AsDate:= pShipDate;
          IBS.ExecQuery;
          if (IBS.Bof and IBS.Eof) then begin
            DestID:= 0;
            raise EBOBError.Create('�������� �������� ����� ����������');
          end;
          smID:= IBS.FieldByName('rSMethodID').AsInteger;
          stID:= IBS.FieldByName('rSTimeID').AsInteger;
          strErr:= '�������� ���������� �������� ����������';
          if not Cache.ShipMethods.ItemExists(smID) then raise EBOBError.Create(strErr);
          if WithSVKDelay then
            SVKDelay:= Cache.GetConstItem(pcSVKShipDelayMinutes).IntValue;
          strErr:= dprt.CheckShipAvailable(pShipDate, stID, SVKDelay, False, True);
          if (strErr<>'') then raise EBOBError.Create(strErr);
        finally
          prFreeIBSQL(ibs);
          cntsGRB.SetFreeCnt(ibd);
        end;
      except
        on E: Exception do begin
          ttID:= 0;
          smID:= 0;
          stID:= 0;
          raise EBOBError.Create(E.Message);
        end;
      end; // cDelivTimeTable
    end; // case
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;
//============================================= ��������� �������� ��� ���������
function fnGetShipParamsView(contID, DprtID, DestID, ShipTableID: Integer; ShipDate: double;
         var DelivType, ShipMetID, ShipTimeID: Integer; var sDestName, sDestAdr, sArrive: String;
         var sShipMet, sShipTime, sView: String; GBdirection: Boolean=False): String;
const nmProc = 'fnGetShipParamsView'; // ��� ���������/�������
var grbIBD: TIBDatabase;
    grbIBS: TIBSQL;
    pDate: double;
    dest: TDestPoint;
    Contract: TContract;
begin
  Result:= '';
  sDestName:= '';
  sDestAdr:= '';
  sArrive:= '';
  sShipMet:= '';
  sShipTime:= '';
  sView:= '';
  grbIBD:= nil;
  grbIBS:= nil;
  try
    if not (DelivType in [cDelivTimeTable, cDelivReserve, cDelivSelfGet]) then
      DelivType:= cDelivReserve; // ������

    if not Cache.Contracts.ItemExists(contID) then Exit;
    Contract:= Cache.Contracts[contID];

    case DelivType of
      cDelivTimeTable: begin //------------------------ �������� �� ����������
        if (ShipDate<DateNull) then ShipDate:= 0;
        if (contID<1) or (DestID<1) or (ShipTableID<1) or (DprtID<1) then begin
          ShipMetID:= 0;
          ShipTimeID:= 0;
        end;
        if (ContID>0) and (DestID>0) then try
          grbIBD:= cntsGRB.GetFreeCnt;
          grbIBS:= fnCreateNewIBSQL(grbIBD, 'IBS_'+nmProc, -1, tpRead, True);
          dest:= Contract.GetContDestPoint(destID);
          if Assigned(dest) then begin
            sDestName:= dest.Name;
            sDestAdr:= dest.Adress;
          end else begin
            grbibs.SQL.Text:= 'select rDestName, rDestAdr'+
              ' from Vlad_CSS_GetContDestPoints('+IntToStr(ContID)+', '+
              fnIfStr(GBdirection, '1', '0')+') where RDestID='+IntToStr(DestID);
            grbIBS.ExecQuery;
            if not (grbIBS.Bof and grbIBS.Eof) then begin
              sDestName:= grbIBS.FieldByName('rDestName').AsString;
              sDestAdr:= grbIBS.FieldByName('rDestAdr').AsString;
            end;
            grbIBS.Close;
          end;
          if (DprtID>0) and (ShipDate>0) and (ShipTableID>0) then begin
            grbIBS.SQL.Text:= 'select rSMethodID, rSTimeID, rArrive'+
              ' from Vlad_CSS_GetContDestTimeTables1'+
              '('+IntToStr(contID)+', '+IntToStr(DestID)+', '+IntToStr(DprtID)+
              ', :pDate) where RttID='+IntToStr(ShipTableID);
            grbIBS.ParamByName('pDate').AsDate:= ShipDate;
            grbIBS.ExecQuery;
            if not (grbIBS.Bof and grbIBS.Eof) then begin
              ShipMetID:= grbIBS.FieldByName('rSMethodID').AsInteger;
              ShipTimeID:= grbIBS.FieldByName('rSTimeID').AsInteger;
              pDate:= grbIBS.FieldByName('rArrive').AsDateTime;
              if (pDate>DateNull) then sArrive:= FormatDateTime(cDateTimeFormatY2N, pDate);
            end;
          end;
        finally
          prFreeIBSQL(grbIBS);
          cntsGRB.SetFreeCnt(grbIBD);
        end;

        if Cache.ShipMethods.ItemExists(ShipMetID) then
          sShipMet:= TShipMethodItem(Cache.ShipMethods[ShipMetID]).Name;
        if Cache.ShipTimes.ItemExists(ShipTimeID) then
          sShipTime:= TShipTimeItem(Cache.ShipTimes[ShipTimeID]).Name;

        if (ShipDate>0) then sView:= sView+FormatDateTime(cDateFormatY2, ShipDate);
        if (sShipTime<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+sShipTime;
        if (sShipMet<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+sShipMet;
        if (sDestName<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+sDestName;
        if (sDestAdr<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+sDestAdr;
        if (sArrive<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+'����.����.'+sArrive;
        if (sView<>'') then sView:= '��������: '+sView else sView:= '��������';
      end; // cDelivTimeTable

      cDelivReserve: begin // ������
        ShipMetID:= 0;
        ShipTimeID:= 0;
        sView:= '�������������';
      end; // cDelivReserve

      cDelivSelfGet: begin //--------------------------------------- ���������
        if (ShipDate<DateNull) then ShipDate:= 0;
        ShipMetID:= Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue;
        if Cache.ShipMethods.ItemExists(ShipMetID) then
          sShipMet:= TShipMethodItem(Cache.ShipMethods[ShipMetID]).Name;
        if Cache.ShipTimes.ItemExists(ShipTimeID) then
          sShipTime:= TShipTimeItem(Cache.ShipTimes[ShipTimeID]).Name;

        if (ShipDate>0) then sView:= sView+FormatDateTime(cDateFormatY2, ShipDate);
        if (sShipTime<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+sShipTime;
        if (sShipMet<>'') then sView:= sView+fnIfStr(sView='', '', ', ')+sShipMet;
        if (sView<>'') then sView:= '��������: '+sView else sView:= '���������';
      end; // cDelivSelfGet
    end; // case
  except
    on E: Exception do Result:= E.Message;
  end;
end;
//========================================== ������ ����.������������ � Grossbee
function SetMainUserToGB(FirmID, UserID: Integer; pDate: TDateTime; ibsGBw: TIBSQL=nil): String;
const nmProc = 'SetMainUserToGB'; // ��� ���������/�������
var ibsGB: TIBSQL;
    ibdGB: TIBDatabase;
begin
  Result:= '';
  ibdGB:= nil;
  ibsGB:= nil;
  if (pDate<=DateNull) then pDate:= Date();
  try try
    if Assigned(ibsGBw) then begin
      ibsGB:= ibsGBw;
      ibsGB.Close;
      if not ibsGB.Transaction.InTransaction then ibsGB.Transaction.StartTransaction;
    end else begin
      ibdGB:= cntsGRB.GetFreeCnt;
      ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc, -1, tpWrite, True);
    end;
    ibsGB.SQL.Text:= 'UPDATE OR INSERT INTO GeneralPerson'+
                     ' (GnPrDate, GnPrFirmCode, GnPrPersonCode)'+
                     ' VALUES (:dd, '+IntToStr(firmID)+', '+IntToStr(UserID)+
                     ') MATCHING (GnPrFirmCode, GnPrDate)';
    ibsGB.ParamByName('dd').AsDate:= pDate;
    ibsGB.ExecQuery;
    ibsGB.Transaction.Commit;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
  finally
    if not Assigned(ibsGBw) then begin
      prFreeIBSQL(ibsGB);     // ��������� ������� Grossbee
      cntsGRB.SetFreeCnt(ibdGB);
    end;
  end;
end;
//====== ���������� �������� � ���� �����������, ����������� ��� ������ � Webarm
procedure TmpCheckRecode;
const nmProc = 'TmpCheckRecode'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    i: Integer;
    TimeProc: TDateTime;
begin
  ibd:= nil;
  ibs:= nil;
  TimeProc:= Now;
  try try
    ibd:= cntsLOG.GetFreeCnt;                                         // ib_css
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, True);
    ibs.SQL.Text:= 'select rCount from tmp_Check_Recode_err';
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise Exception.Create('Empty ibs');
    i:= ibs.FieldByName('rCount').AsInteger;
    ibs.Transaction.Commit;
    prMessageLOGS(nmProc+': ���������� '+IntToStr(i)+' �������, '+GetLogTimeStr(TimeProc), fLogCache, False);
  except
    on E: Exception do prMessageLOGS(nmProc+'_stop: '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ibs);     // ��������� �������
    cntsLOG.SetFreeCnt(ibd);
  end;
end;
//===================================== ������� ������������� � ���� �����������
procedure TmpRecodeCSS;
const nmProc = 'TmpRecodeCSS'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    i: Integer;
    flStop: Boolean;
    TimeProc: TDateTime;
begin
  ibd:= nil;
  ibs:= nil;
  if not flTmpRecodeCSS then Exit;    // ������ � ������� ����� �������� �������
  if not flDebug and not fnGetActionTimeEnable(caeSmallWork) then Exit;
  flStop:= False;
  TimeProc:= Now;
  try try
    ibd:= cntsLOG.GetFreeCnt;                                         // ib_css
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, True);
    ibs.SQL.Text:= 'select rCount from tmp_Recode';
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise Exception.Create('Empty ibs');
    i:= ibs.FieldByName('rCount').AsInteger;
    ibs.Transaction.Commit;
    flStop:= (i<1); // ��� �������������� - ���������
    if flStop then prMessageLOGS(nmProc+': ��� ������ ��� ��������� - ���������', nmProc, False)
    else prMessageLOGS(nmProc+': ���������� '+IntToStr(i)+' �������, '+GetLogTimeStr(TimeProc), nmProc, False);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+'_stop: '+E.Message, nmProc);
//      flStop:= True;
    end;
  end;
  finally
    prFreeIBSQL(ibs);     // ��������� �������
    cntsLOG.SetFreeCnt(ibd);
    if flStop then SetIniParam(nmIniFileBOB, 'Options', 'flTmpRecodeCSS', '0');
  end;
end;
//============================================= ������� ������������� � ���� ORD
procedure TmpRecodeORD;
// ��������� � ���� �������:
//  - ��������� ������ ������� ��� ������� �� ��������� "�����������", "�����������"
// 1. ������� "�����" ������ �� �������� �������
// 2. ������� ������ ������ �� �������� "������"
const nmProc = 'TmpRecodeORD'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    i: Integer;
    flStop: Boolean;
    TimeProc: TDateTime;
//    ilst: TIntegerList;
//    s: String;
begin
  ibd:= nil;
  ibs:= nil;
  if not flTmpRecodeORD then Exit;    // ������ � ������� ����� �������� �������
  if not flDebug and not fnGetActionTimeEnable(caeSmallWork) then Exit;
  flStop:= False;
  TimeProc:= Now;
//  ilst:= TIntegerList.Create;
  try try
    ibd:= cntsORD.GetFreeCnt;                                         // ib_ord
{
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);
//    ibs.SQL.Text:= 'select ordrlncode lncode, ordrlnware from ordersreestr'+        // 1
//      ' left join orderslines on ordrlnorder=ordrcode where ordrdate>"01.04.2016"'+ // 1
//      ' and ordrcurrency=22 and ordrstatus='+IntToStr(orstForming);                 // 1
    ibs.SQL.Text:= 'select first 1000 ordrcode lncode from ordersreestr'+   // 2
      ' where ordrdate<"01.01.2016" and ordrstatus='+IntToStr(orstDeleted); // 2
    ibs.ExecQuery;
    while not ibs.Eof do begin
//      i:= ibs.FieldByName('ordrlnware').AsInteger;                 // 1
//      if Cache.WareExist(i) and not Cache.GetWare(i).IsPrize then  // 1
      ilst.Add(ibs.FieldByName('lncode').AsInteger);       // 2
      TestCssStopException; // �������� ��������� �������
      ibs.Next;
    end;
    ibs.Close;
    if (ilst.Count>0) then begin
      fnSetTransParams(IBS.Transaction, tpWrite, True);
//      IBS.SQL.Text:= 'execute procedure DelOrderLine(:LineID)'; // 1
      IBS.SQL.Text:= 'delete from ordersreestr where ordrcode=:LineID'; // 2
//      s:= 'LineID=';                                            // 1
      s:= 'orderID=';                                                   // 2
      for i:= 0 to ilst.Count-1 do begin
        try
          with IBS.Transaction do if not InTransaction then StartTransaction;
          IBS.ParamByName('LineID').AsInteger:= ilst[i];
          IBS.ExecQuery;
          IBS.Transaction.Commit;
        except
          on E: Exception do prMessageLOGS(nmProc+': del error '+s+
                             IntToStr(ilst[i])+': '+E.Message, nmProc, False);
        end;
        TestCssStopException; // �������� ��������� �������
      end;
    end;
    flStop:= (ilst.Count<1); // ��� �������������� - ���������
    if flStop then prMessageLOGS(nmProc+': ��� ������ ��� ��������� - ���������', nmProc, False)
    else prMessageLOGS(nmProc+': ���������� '+IntToStr(ilst.Count)+' �������, '+
      GetLogTimeStr(TimeProc), nmProc, False);
}
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, True);
    ibs.SQL.Text:= 'select rCount from tmp_Recode';
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise Exception.Create('Empty ibs');
    i:= ibs.FieldByName('rCount').AsInteger;
    ibs.Transaction.Commit;
    flStop:= (i<1); // ��� �������������� - ���������

    if flStop then prMessageLOGS(nmProc+': ��� ������ ��� ��������� - ���������', nmProc, False)
    else prMessageLOGS(nmProc+': ���������� '+IntToStr(i)+' �������, '+GetLogTimeStr(TimeProc), nmProc, False);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+'_stop: '+E.Message, nmProc);
//      flStop:= True;
    end;
  end;
  finally
    prFreeIBSQL(ibs);     // ��������� �������
    cntsORD.SetFreeCnt(ibd, True);
    if flStop then SetIniParam(nmIniFileBOB, 'Options', 'flTmpRecodeORD', '0');
//    prFree(ilst);
  end;
end;
//========================== ������� �������������/������ ������ � ���� Grossbee
procedure TmpRecodeGRB;
const nmProc = 'TmpRecodeGRB'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    i, j: Integer;
    s, sDate, days, recs: String;
    flStop: Boolean;
    TimeProc: TDateTime;
    rIniFile: TINIFile;
begin
  ibd:= nil;
  ibs:= nil;
  if not flTmpRecodeGRB then Exit;    // ������ � ������� ����� �������� �������
  if not flDebug and not fnGetActionTimeEnable(caeSmallWork) then Exit;
  flStop:= False;
  TimeProc:= Now;
  s:= '';
  i:= 0;
  rIniFile:= TINIFile.Create(nmIniFileBOB);
  try try
    days:= rIniFile.ReadString('Options', 'RecodeGRBdays', '10');
    recs:= rIniFile.ReadString('Options', 'RecodeGRBrecs', '500');
    sDate:= rIniFile.ReadString('Options', 'RecodeGRBdateTo', '01.01.2018');

    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, True);
    ibs.ParamCheck:= False; // ������� ������ alter-������ ���-���
    ibs.SQL.Text:= ' execute block returns (rCount integer) as'+
      ' declare variable xCode integer=0; declare variable xDateTest timestamp="'+sDate+'";'+
{      ' declare variable xDateEnd timestamp; declare variable xDays integer='+days+';'+

      ' begin rCount=0; select min(piavLastTime) from payinvalter_vlad into :xDateEnd;'+
      ' if (xDateEnd<xDateTest) then begin'+
      '  xDateEnd=xDateEnd+xDays; if (xDateEnd>xDateTest) then xDateEnd=xDateTest;'+
      '  for select first '+recs+' piavAccCode from payinvalter_vlad'+
      '   where piavLastTime<:xDateEnd order by piavLastTime desc'+
      '  into :xCode do begin rCount=rCount+1;'+             // payinvalter_vlad
      '   delete from payinvalter_vlad where piavAccCode=:xCode; end end suspend;'+

      ' rCount=0; select min(iavLastTime) from invoicealter_vlad into :xDateEnd;'+
      ' if (xDateEnd<xDateTest) then begin'+
      '  xDateEnd=xDateEnd+xDays; if (xDateEnd>xDateTest) then xDateEnd=xDateTest;'+
      '  for select first '+recs+' iavInvCode from invoicealter_vlad'+
      '   where iavLastTime<:xDateEnd order by iavLastTime desc'+
      '  into :xCode do begin rCount=rCount+1;'+            // invoicealter_vlad
      '   delete from invoicealter_vlad where iavInvCode=:xCode; end end suspend;'+ }
      '   declare variable xDateEnd timestamp; declare variable xCodeEnd integer=0;'+

      ' begin rCount=0; select min(piavLastTime) from payinvalter_vlad into :xDateEnd;'+
      '   if (xDateEnd<xDateTest) then begin xDateEnd=xDateEnd+'+days+';'+
      '    if (xDateEnd>xDateTest) then xDateEnd=xDateTest;'+
      '    select Min(piavAccCode) from payinvalter_vlad'+
      '      where piavLastTime<:xDateEnd into :xCode;'+
      '    if (xCode is not null and xCode>0) then begin xCodeEnd=xCode+'+recs+';'+
      '      delete from payinvalter_vlad where'+
      '       (piavAccCode between :xCode and :xCodeEnd) and piavLastTime<:xDateEnd;'+
      '      rCount=ROW_COUNT; end end suspend;'+

      '   rCount=0; xCode=0; select min(iavLastTime) from invoicealter_vlad into :xDateEnd;'+
      '   if (xDateEnd<xDateTest) then begin xDateEnd=xDateEnd+'+days+';'+
      '    if (xDateEnd>xDateTest) then xDateEnd=xDateTest;'+
      '    select Min(iavInvCode) from invoicealter_vlad'+
      '     where iavLastTime<:xDateEnd into :xCode;'+
      '    if (xCode is not null and xCode>0) then begin xCodeEnd=xCode+'+recs+';'+
      '      delete from invoicealter_vlad where'+
      '        (iavInvCode between :xCode and :xCodeEnd) and iavLastTime<:xDateEnd;'+
      '      rCount=ROW_COUNT; end end suspend;'+

      ' end';
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise Exception.Create('Empty ibs');
    while not ibs.Eof do begin
      j:= ibs.FieldByName('rCount').AsInteger;
      i:= i+j;
      s:= s+fnIfStr(s='', '', '+')+IntToStr(j);
      TestCssStopException;
      ibs.Next;
    end;
    ibs.Transaction.Commit;
    flStop:= (i<1); // ��� �������������� - ���� ����������

    if flStop then prMessageLOGS(nmProc+': ��� ������ ��� ��������� - ���������', nmProc, False)
    else prMessageLOGS(nmProc+': ���������� '+s+' �������, '+GetLogTimeStr(TimeProc), nmProc, False);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+'_stop: '+E.Message, nmProc);
//      flStop:= True;
    end;
  end;
  finally
    prFree(rIniFile);
    prFreeIBSQL(ibs);     // ��������� �������
    cntsGRB.SetFreeCnt(ibd, True);                        // ���������
    if flStop then SetIniParam(nmIniFileBOB, 'Options', 'flTmpRecodeGRB', '0');
  end;
end;
//========================================== �������� ������ ���������� ��������
function CheckMobileNumber(num: String): Boolean;
//const opCodes: array[0..15] of String = ('039'{Golden Telecom}, '050'{MTC},
// '063'{Life}, '066'{�����}, '067'{��������/Djuice}, '068'{Beeline/WellCOM/���I},
// '073'{Life}, '091'{Utel}, '092'{PEOPLEnet}, '093'{Life}, '094'{������������},
// '095'{���/�����}, '096'{��������/Djuice}, '097'{��������/Djuice/�������},
// '098'{��������/Djuice/�������}, '099'{������(1..6)/�����});
var pref: String;
    i: Integer;
    c: Char;
begin
  Result:= False;
  if (num='') then Exit; // ������ �����
  i:= 1;
  repeat // ���� ������� ���� ���������
    c:= num[i];
    if SysUtils.CharInSet(c, ['(', '+', '3', '8', ' ']) then Inc(i)
    else c:= '~'; // ������ ������ �� �����
  until (c='~');
  pref:= copy(num, i, 10);
  if (length(pref)<10) then Exit; // ������������ ����� ������
//  pref:= copy(num, i, length(num));
//  if (length(pref)<>10) then Exit; // ������������ ����� ������

  pref:= copy(num, i, 3); // ��� ���������

  Result:= (Cache.MobilePhoneSigns.IndexOf(pref)>=0);
{
  for i:= Low(opCodes) to High(opCodes) do begin // ���� � ������� �����
    Result:= (pref=opCodes[i]);
    if Result then Exit;
  end;
  Result:= (pref='050') or (pref='066') or (pref='095') or (pref='099')  // MTC
        or (pref='067') or (pref='096') or (pref='097') or (pref='098')  // Kyivstar
        or (pref='068') or (pref='063') or (pref='093') or (pref='073')  // Beeline, Life
        or (pref='091') or (pref='092') or (pref='094') or (pref='039'); // Utel, PEOPLEnet, ������������, Golden Telecom
}
end;
//============================================ ����� ���������� �������� ��� +38
function GetMobileNumber10(num: String): String;
// ���������� ������ ������, ���� ����� ������������
var i: Integer;
    c: Char;
begin
  Result:= '';
  if (num='') then Exit; // ������ �����
  num:= fnDelSpcAndSumb(num);
  i:= 1;
  repeat // ���� ������� ���� ���������
    c:= num[i];
    if SysUtils.CharInSet(c, ['+', '3', '8', ' ']) then Inc(i)
    else c:= '~'; // ������ ������ �� �����
  until (c='~');
  if (Cache.MobilePhoneSigns.IndexOf(copy(num, i, 3))<0) then Exit; // �� ����� ��� ���������
  num:= copy(num, i, length(num));
  if (length(num)<>10) then Exit; // ������������ ����� ������
  Result:= num;
end;
//======================================= ���������� ���������� ������ �� ������
function ExtractFictiveEmail(emails: String): String;
var i: Integer;
begin
  Result:= emails;
  Result:= StringReplace(Result, ' ', '', [rfReplaceAll]);
  i:= pos(cFictiveEmail, Result);
  if (i<1) then Exit;
  Result:= StringReplace(Result, cFictiveEmail, '', [rfReplaceAll, rfIgnoreCase]);
  Result:= StringReplace(Result, ',,', ',', [rfReplaceAll]);
  if (copy(Result, 1, 1)=',') then Result:= copy(Result, 2, length(Result));
  if (copy(Result, length(Result), 1)=',') then Result:= copy(Result, 1, length(Result)-1);
end;
//======================================= ���������� ���������� ������ �� ������
function ExtractFictiveEmail(emails: TStringList): TStringList; // must Free !!!
var i: Integer;
begin
  Result:= TStringList.Create;
  for i:= 0 to eMails.Count-1 do // ���������� ��������� �����
    if (eMails[i]<>cFictiveEmail) then Result.Add(eMails[i]);
end;
//=============================== �������� ������������ ��� ������������ �������
function CheckClientFIO(CliName: String): String;
const xChars = '�����Ũ������������������������';
var s: String;
    i: Integer;
begin
  Result:= '';
  s:= trim(CliName); // ???
  try
    if (s='') then raise Exception.Create(''); // �����

    i:= pos(' ', s); // ������� �� ���� (��� �������) �������� �� �����
    if (i<3) then raise Exception.Create('');
    if not (pos(copy(s, 1, 1), xChars)>0) then raise Exception.Create(''); // 1-� ����� ������� �� ���������

    s:= copy(s, i+1, length(s)); //--- ������ ��
    if (s='') then raise Exception.Create(''); // �����
    if not (pos(copy(s, 1, 1), xChars)>0) then raise Exception.Create(''); // 1-� ����� ����� �� ���������

    i:= pos(' ', s);
    case i of
      0: begin //---------------------------- ���� 2 ����� - 2-� ������� �������
        i:= pos('.', s); // 1-� �����
        if (i<2) then raise Exception.Create(''); // ��� ����� ��� � ������ ������
        s:= copy(s, i+1, length(s)); //--- ������ ����� 1-� �����
        if (s='') then raise Exception.Create(''); // �����
        if not (pos(copy(s, 1, 1), xChars)>0) then raise Exception.Create(''); // 1-� ����� �������� �� ���������
        i:= pos('.', s); // 2-� �����
        if (i<2) then raise Exception.Create(''); // ��� ����� ��� � ������ ������
      end; // 0

      1: raise Exception.Create(''); // ������ � ������ ������ ��

      else begin //----------------------------- 2 ������� - 1-� ������� �������
        s:= copy(s, i+1, length(s)); //--- ������ �
        if not (pos(copy(s, 1, 1), xChars)>0) then raise Exception.Create(''); // 1-� ����� �������� �� ���������
        Exit;
      end; // else
    end; // case
  except
    on e: Exception do
      Result:= '��� �� ������������� ������� "������ ���� ��������" ��� "������ �.�."';
  end;
end;
//============ ������� ������ ��� ��������� �� �������� (�������, ������, >1 ���)
function GetContWareRestsByCols(wareID, ContID, StorageCount: Integer): TDoubleDynArray;
const nmProc = 'GetContWareRestsByCols';
var i, StoreMain: Integer;
    OList: TObjectList;
    flVis, flAdd: Boolean;
    Contract: TContract;
    dprt: TDprtInfo;
    pqty: Double;
begin
  if (StorageCount<1) then StorageCount:= 1;
  SetLength(Result, StorageCount); // ������ ��������: 0-�������, 1- ������, 2- >1 ���
  for i:= 0 to High(Result) do Result[i]:= 0;
  flVis:= (StorageCount>1);
  flAdd:= (StorageCount>2);
  try
    Contract:= Cache.Contracts[ContID];
    StoreMain:= Contract.MainStorage;

    OList:= Cache.GetWareRestsByStores(WareID); // ������� �� ��������
    try
      Result[0]:= fnGetQtybyIDDef(OList, StoreMain, 0);
      if flVis then begin
        dprt:= Cache.arDprtInfo[StoreMain];
        for i:= 0 to dprt.StoresFrom.Count-1 do with TTwoCodes(dprt.StoresFrom[i]) do
          if (ID2=1) or (flAdd and (ID2>1)) then begin
            pqty:= fnGetQtybyIDDef(OList, ID1, 0);
            if (ID2=1) then Result[1]:= Result[1]+pqty else Result[2]:= Result[2]+pqty;
          end;
      end; // if flVis
    finally
      prFree(OList);
    end;

  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
end;
//==================================== ��������� ����������� �������� �� �������
//===== ���� - ���������� ����� ��� ��������� ������� ����������� (����.�������)
function CheckDprtTodayFill(dprtID: Integer; RestList: TObjectList): String;
const nmProc = 'CheckDprtTodayFill';
var j, i: Integer;
    dprt: TDprtInfo;
    cqr: TCodeAndQty;
    cds: TCodeAndDates;
    rest: Double;
begin
  Result:= '';
  try
    dprt:= Cache.arDprtInfo[dprtID];
    for j:= 0 to dprt.FillTT.Count-1 do begin
      cds:= TCodeAndDates(dprt.FillTT[j]); // ��� ������, ����/����� ������, ����/����� ��������

if not flmyDebug then begin
      if (cds.Date1<Now()) then Continue;      // Date1 - ��������� ����/����� ������
      if (cds.Date2>(Date()+1)) then Continue; // Date2 - ����� �������� (����� ����� �������)
end;
      rest:= 0;
      for i:= 0 to RestList.Count-1 do begin
        cqr:= TCodeAndQty(RestList[i]);    // ��� ������, ���-��
        if (cqr.ID<>cds.ID) then Continue; // �� ��� �����
        rest:= cqr.Qty;
        break;
      end;
      if not fnNotZero(rest) then Continue; // ��� �������

      Result:= '�������� '+AnsiLowerCase(cds.Name); // ����� - ����� ��������
      Exit;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
end;
//================================================= ������� �������� �� ��������
function GetDprtWareRestsByArrive(dprtID: Integer; WareQty: Double;
                                  var wrba: TWareRestsByArrive): String;
const nmProc = 'GetDprtWareRestsByArrive';
var j, i, iw, wareID, StoreMain, restIdx: Integer;
    dprt: TDprtInfo;
    cds: TCodeAndDates;
    rest, WareRest: Double;
    RestList: TObjectList;
    TitleList: TStringList;
    s, title: String;
    restCols: TDoubleDynArray;
    ttList: TObjectList;
    tc: TTwoCodes;
    fl: Boolean;
    arFlagDel_0, arFlagDel_1: array of Boolean;
//    store: TStorageDescr;
begin
  Result:= '';
  RestList:= nil;
  TitleList:= TStringList.Create; // ������ ���������� �������
  ttList:= TObjectList.Create; // ������ ��������� ���������� �������
  try
    SetLength(wrba.arRestLists, Length(wrba.arWares)); // ������ �������� �� ��������
    for iw:= 0 to High(wrba.arRestLists) do
      wrba.arRestLists[iw]:= TStringList.Create;

    StoreMain:= dprtID;
    dprt:= Cache.arDprtInfo[StoreMain];
    //------------------------------------- ���������� ������ ���������� �������
    //------------------------- � ������ ��������� ���������� ������� ����������
//    TitleList.Add(dprt.ColumnName); // 1-� - ����� ���������
    TitleList.Add('�������, '+dprt.ColumnName); // 1-� - ����� ���������
    for j:= 0 to dprt.FillTT.Count-1 do begin  // ������ ����������
      cds:= TCodeAndDates(dprt.FillTT[j]); // ��� ������, ����/����� ������, ����/����� ��������
      if (cds.Date1<Now()) then Continue;  // Date1 - ��������� ����/����� ������

//      tc:= nil;
      fl:= False;
      for i:= 0 to ttList.Count-1 do begin
        tc:= TTwoCodes(ttList[i]);
        fl:= (tc.ID1=cds.ID);
        if fl then break;
      end;
      if fl then Continue; // ���� ����� ��� ����

      title:= cds.Name; // ��������� - ����� ��������
      restIdx:= TitleList.IndexOf(title); // ���� ������ �������
      if (restIdx<0) then restIdx:= TitleList.Add(title);

      tc:= TTwoCodes.Create(cds.ID, restIdx); // ��� ������, ������ �������
      ttList.Add(tc);
    end;
    SetLength(restCols, TitleList.Count);    // ������� �������� ������ �� ��������
    SetLength(arFlagDel_0, TitleList.Count); // ������ ������ �������� ������� c �������� ���������
    for i:= 0 to High(arFlagDel_0) do arFlagDel_0[i]:= True;
    SetLength(arFlagDel_1, TitleList.Count); // ������ ������ �������� ������ ������� "����"
    for i:= 0 to High(arFlagDel_1) do arFlagDel_1[i]:= True;

    //------------------------------------------------------ ������������ ������
    for iw:= 0 to High(wrba.arWares) do try
      wareID:= wrba.arWares[iw];
      RestList:= Cache.GetWareRestsByStores(wareID); // ������� �� �������

      for i:= 0 to High(restCols) do restCols[i]:= 0; // ������ ������ ��������
      rest:= fnGetQtybyIDDef(RestList, StoreMain, 0); // ������� �� ������� ������
      WareRest:= rest; // ������� �������� ������ �� ���� �������
      restCols[0]:= rest;
      // ----------------------------------- �������� ������� �� ��������
      for j:= 0 to ttList.Count-1 do begin
        tc:= TTwoCodes(ttList[j]); // ��� ������, ������ �������
        rest:= fnGetQtybyIDDef(RestList, tc.ID1, 0);
        if not fnNotZero(rest) then Continue; // ��� �������

        restIdx:= tc.ID2;
        restCols[restIdx]:= restCols[restIdx]+rest;
        WareRest:= WareRest+rest;
      end;

      if (iw>0) and not fnNotZero(WareRest) then begin // �������� ���� �������� ��� ��������
        wrba.arWares[iw]:= 0;
        Continue;
      end;

      // ----------------------------------- ��������� ������� �� ��������
//      fl:= False; // ���� ������� ������� "����"
      WareRest:= 0;
      for j:= 0 to High(restCols) do begin
        rest:= restCols[j];
        WareRest:= WareRest+rest;

//        if (WareRest>=WareQty) then //  "����", �.�. ������� ������ ���-��
//          s:= fnRestValuesForWeb(WareQty, WareRest)
//        else
//          s:= fnRestValuesForWeb(WareQty, rest);
        s:= fnRestValuesForWeb(WareQty, WareRest);
        wrba.arRestLists[iw].Add(s);

        fl:= not fnNotZero(rest); // ��� �������
        arFlagDel_0[j]:= arFlagDel_0[j] and fl; // ��� �������� - ������� �������
        if fl then Continue;
                              // ���-�� ���.������ �� ���� �������
        if (iw=0) then wrba.WareTotal:= wrba.WareTotal+rest;

        if (j=0) then Continue; // 0-� ������� �� ���������

        arFlagDel_1[j]:= arFlagDel_1[j] and // ��� ��������� "����" - ������� �������
          (copy(s, 1, 4)='&gt;') and (copy(wrba.arRestLists[iw][j-1], 1, 4)='&gt;');
      end;
    finally
      prFree(RestList);
    end; // for iw:= 0 to High(wrba.arWares)

    // ������� ������� ��� �������� � � ��������� "����", ����� 0-� (�����.�����)
    for j:= High(arFlagDel_0) downto 1 do if arFlagDel_0[j] or arFlagDel_1[j] then begin
      TitleList.Delete(j);
      for i:= 0 to High(wrba.arRestLists) do
        if (wrba.arRestLists[i].Count>j) then wrba.arRestLists[i].Delete(j);
    end;

    //------------------------------ ��������� ������ ������� ��� �������� � CGI
    SetLength(wrba.Storages, TitleList.Count);
    for j:= 0 to TitleList.Count-1 do begin
      fl:= (j=0);
      if fl then begin
        i:= StoreMain;
        s:= dprt.Name;
      end else begin
        i:= cAggregativeStorage+j-1;
        s:= '';
      end;
      wrba.Storages[j].Code     := IntToStr(i);
      wrba.Storages[j].FullName := s;
      wrba.Storages[j].ShortName:= TitleList[j];
      wrba.Storages[j].IsVisible:= True;
      wrba.Storages[j].IsReserve:= fl;
      wrba.Storages[j].IsSale   := fl;
    end; // for j:= 0 to TitleList.Count-1

  except
    on E: Exception do Result:= E.Message;
  end;
  prFree(TitleList);
  prFree(ttList);
  SetLength(restCols, 0);
  SetLength(arFlagDel_0, 0);
  SetLength(arFlagDel_1, 0);
end;
//======================================== ������� �������� ������ ��� ���������
function GetContWareRestsSem(wareID: Integer; ffp: TForFirmParams; var sArrive: String): Integer;
const nmProc = 'GetContWareRestsSem';
var j: Integer;
    OList: TObjectList;
begin
  Result:= 0;
  sArrive:= '';
  try
    OList:= Cache.GetWareRestsByStores(WareID);  // ������ ��������
    try
      for j:= 0 to OList.Count-1 do with TCodeAndQty(OList[j]) do begin
        if (Qty<constDeltaZero) then Continue;  // ��� �������
        if (ID=ffp.StoreMain) then begin
          Result:= 2; // ������� �� ������� (������� �����)
          break;
        end;
        if (fnInIntArray(ID, ffp.StoreCodes)<0) then Continue; // ��� � ������ �������
        Result:= 1; // ������� �� �����
      end; // for j:= 0 to OList.Count-1

if flSpecRestSem then
      //------------- ��������� ����������� �������� �� ������� (����.�������=3)
      if ffp.ForClient and (Result=1) then begin
        sArrive:= CheckDprtTodayFill(ffp.StoreMain, OList); // ��������� ��� ����.��������
        if (sArrive<>'') then Result:= 3;
{if flDebug and (sArrive<>'') then
  prMessageLOGS('ware= '+fnMakeAddCharStr(IntToStr(wareID), 5)+' dprt= '+
    fnMakeAddCharStr(IntToStr(ffp.StoreMain), 5)+' title= '+sArrive, fLogDebug, false);  }
      end; // if ffp.ForClient and (Result=1)

    finally
      prFree(OList);
    end;

    if not ffp.ForClient and (Result=1) then Result:= 2; // ��� Webarm
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
end;
//==============================================================================
function GetYearFromLoadModels: String;
var tdfrom: Integer;
begin
  Result:= '';
  tdFrom:= Cache.GetConstItem(pcTDTmodelsYearFrom).IntValue;
  if (tdFrom<1) then Exit;
  Result:= IntToStr(tdFrom);
  if (tdFrom<1900) or (tdFrom>3000) then // ������ ��������
    raise Exception.Create(MessText(mtkNotValidParam)+' ���� - '+Result);
end;


//******************************************************************************
//                           TForFirmParams
//******************************************************************************
constructor TForFirmParams.Create(pFirmID, pUserID: Integer; pForFirmID: Integer=0;
                                  pCurrID: Integer=0; pContID: Integer=0);
var s: String;
begin
  FirmId:= pFirmID;
  UserID:= pUserID;
  ForFirmID:= pForFirmID;
  currID:= pcurrID;
  contID:= pcontID;
  ForClient:= (FirmId<>IsWe);
  if not Cache.CurrExists(currID) then // ���������� ������, ���� ��� �� ������
    if not ForClient then currID:= 0
    else if CheckNotValidUser(UserID, FirmID, s) then currID:= 0
    else currID:= Cache.arClientInfo[UserID].SEARCHCURRENCYID; // ����� ������ �� �������� ������������
  if ForClient and (ForFirmID<1) then ForFirmID:= FirmID; // �/� ��� ������
  if (currID>0) then rate:= Cache.Currencies.GetCurrRate(currID) else rate:= 0;    // ???
  arSys:= SysTypes.GetDirCodes;   // ���� ������ �����
  SetLength(StoreCodes, 0);
  StoreMain:= 0;
  HideZeroRests:= ForClient and not Cache.arFirmInfo[FirmID].ShowZeroRests;
end;
//==============================================================================
destructor TForFirmParams.Destroy;
begin
  SetLength(arSys, 0); // ������ ������
  SetLength(StoreCodes, 0);
  inherited;
end;
//==============================================================================
procedure TForFirmParams.FillStores;
begin
  if not Assigned(self) then Exit;
  if (StoreMain>0) then Exit;
  StoreMain:= fnGetContMainStoreAndStoreCodes(ForFirmID, ContID, StoreCodes);
end;
//==============================================================================
function TForFirmParams.NeedSemafores: Boolean;
begin
  Result:= Assigned(self) and (ForClient or (ForFirmID>0));
end;

//******************************************************************************
//                          TFirmPhoneParams
//******************************************************************************
constructor TFirmPhoneParams.Create(pNames: String; pSMScount: Integer);
begin
  Names:= pNames;
  SetLength(arSMSind, pSMScount);
end;
//==============================================================================
destructor TFirmPhoneParams.Destroy;
begin
  SetLength(arSMSind, 0);
  inherited;
end;


{
procedure TestFile;
var Stream: TBoBMemoryStream;
    ThreadData: TThreadData;
    s: string;
begin
  prMessageLOGS('----------- Check File', fLogDebug, false);

  ThreadData:= fnCreateThread(thtpTestN);
  Stream:= TBoBMemoryStream.Create;

  Stream.WriteInt(3854562);
  Stream.WriteInt(32751);
  Stream.WriteInt(291634);

  prGetBankAccountFile(Stream, ThreadData);

  s:= IntToStr(Stream.ReadInt);
  prMessageLOGS('result - '+s, fLogDebug, false);

  prFree(Stream);
  prDestroyThreadData(ThreadData, 'Test');
end;
}

//******************************************************************************
//                              TWareRestsByArrive
//******************************************************************************
constructor TWareRestsByArrive.Create;
begin
  inherited;
  SetLength(arWares, 0);      // 0- ��� ������, 1... - ���� ��������
  SetLength(Storages, 0);     // ����� ������� (�������)
//  SetLength(WareTotals, 0);   //
  SetLength(arRestLists, 0);
  WareTotal:= 0;
end;
//==============================================================================
destructor TWareRestsByArrive.Destroy;
var i: Integer;
begin
  SetLength(arWares, 0);      // 0- ��� ������, 1... - ���� ��������
  SetLength(Storages, 0);     // ����� ������� (�������)
//  SetLength(WareTotals, 0);   //
  for i:= 0 to High(arRestLists) do prFree(arRestLists[i]);
  SetLength(arRestLists, 0);
  inherited;
end;

//******************************************************************************
initialization
begin
  SaveToLog:= [];
  CheckDocsList:= TStringList.Create;
  dLastCheckDocTime:= DateNull;
  dLastCheckCliEmails:= DateNull;
  VSMail:= TVSMail.Create;
  brcWebDelim         := fnCodeBracketsForWeb(cWebDelim);
  brcWebBoldBlackBegin:= fnCodeBracketsForWeb(cWebBoldBlackBegin);
  brcWebBoldEnd       := fnCodeBracketsForWeb(cWebBoldEnd);
  brcWebColorRedBegin := fnCodeBracketsForWeb(cWebColorRedBegin);
  brcWebColorBlueBegin:= fnCodeBracketsForWeb(cWebColorBlueBegin);
  brcWebColorEnd      := fnCodeBracketsForWeb(cWebColorEnd);
//  brcWebItalBegin     := fnCodeBracketsForWeb(cWebItalBegin);
//  brcWebItalEnd       := fnCodeBracketsForWeb(cWebItalEnd);
  flDebug:= False;
  flTest:= False;
  flTestDocs:= False;
  SleepFillLinksInt:= 10;
end;
finalization
begin
  prFree(VSMail);
  prFree(CheckDocsList);
  SaveToLog:= [];
end;
//******************************************************************************

end.
