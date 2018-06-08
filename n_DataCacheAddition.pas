{   ������ ���������� � DataCacheInMemory ��� ������ � ������������� �������� � �� ������
{ ------------------------------------------------------------------------------------- }
unit n_DataCacheAddition;

interface

uses Classes, Types, SysUtils, IBDataBase, IBSQL, Math, Forms, SyncObjs,
     Contnrs, DateUtils, n_free_functions, v_constants, v_DataTrans,
     n_constants, n_DataSetsManager, n_LogThreads, n_DataCacheObjects;

type
//---------------------------------------------- ����� ������� �� �������� �����
  TArraySysTypeLists = Class (TArrayTypeLists)
  public
    constructor Create(fSorted: Boolean=False; fDelimiter: Boolean=False);
  end;

//--------------------------------------------------------------------- ������ 2
  TSecondLink = class (TLinkLink) // LinkPtr - ������ �� ���� ������
  protected                       // DoubleLinks - ������ 3 (������ 2 � ��������)
    FQty: Single;           // ����������
  public
    constructor Create(pSrcID: Integer; pQty: Single; pNodePtr: Pointer=nil;
                pIsLink: Boolean=False; pHasWares: Boolean=False; pHasFilters: Boolean=False; pHasMotul: Boolean=False);
    property IsLinkNode    : boolean index ik8_3 read GetLinkBool write SetLinkBool; // ������� ���� ������ 2 (�������� ����)
    property NodeHasWares  : boolean index ik8_4 read GetLinkBool write SetLinkBool; // ������� ������� ������� � ���� ��� ��� �����
    property NodeHasFilters: boolean index ik8_5 read GetLinkBool write SetLinkBool; // ������� ������� �������� � ���� ������
    property NodeHasPLs    : boolean index ik8_6 read GetLinkBool write SetLinkBool; // ������� ������� ������ � Motul � ���� ��� ��� �����
    property Qty: Single read FQty write FQty;       // ����������
    function GetWareCodes: Tai;                      // must Free, ������ ����� ������� ������ 2
  end;

//------------------------------- ������ ���������� / ��������� /��������� / ���
  TModelParams = Class  // ��������� ������
  private
    function GetStrMP(const ik: T16InfoKinds): String; // �������� ������ ��� ������ (property ...Out)
  public
    pYStart    : Word;     // ��� ������ �������
    pYEnd      : Word;     // ��� ��������� �������
    pMStart    : Byte;     // ����� ������ �������
    pMEnd      : Byte;     // ����� ��������� �������
    pCCM       : Word;     // PC,CV - ���. ����� ���.��., AX - ������ ����� [��]
    pKW        : Word;     // �������� ���
    pHP        : Word;     // �������� ��
    pCylinders : Word;     // ���������� ���������
    pValves    : Word;     // PC - ���-�� �������� �� ������ ��������, CV - ������ * 100
    pBodyID    : Word;     // PC - ���, ��� ������          (TYPEDIR=1)
                           //   CV - ���, �����������      (TYPEDIR=20)
                           //   AX - ���, ����� �����      (TYPEDIR=24)
    pDriveID   : Word;     // PC - ���, ��� �������         (TYPEDIR=2)
                           //   CV - ���, ������������ ��� (TYPEDIR=21)
                           //   AX - ���, ��� ���          (TYPEDIR=22)
    pEngTypeID : Word;     // PC,CV - ���, ��� ���������    (TYPEDIR=3)
                           //   AX - ���, ���������� ���   (TYPEDIR=23)
    pFuelID    : Word;     // PC - ���, ��� �������         (TYPEDIR=4)
                           //   AX - ���, �������� ��������� (TYPEDIR=25)
    pFuelSupID : Word;     // ���, ������� �������          (TYPEDIR=5)
    pBrakeID   : Word;     // PC,AX - ���, ��� ��������� ������� (TYPEDIR=6)
    pBrakeSysID: Word;     // ���, ��������� �������        (TYPEDIR=7)
    pCatalID   : Word;     // ���, ��� ������������         (TYPEDIR=8)
    pTransID   : Word;     // PC - ���, ��� ������� ������� (TYPEDIR=9)
                           //   AX - ���, Hub system       (TYPEDIR=30)
    cvHPaxLO   : String;   // CV - �������� [��](��-��),  AX - ��������[��](��-��)
    cvKWaxDI   : String;   // CV - �������� [���](��-��), AX - ���������[��](��-��)
    cvSecTypes : String;   // �������������� ���            (������)
    cvWheels   : String;   // �������� ���� [���.����]/[��] (������)
    cvIDaxBT   : String;   // CV - ID �������������,  AX - ��� ������ (������)
    cvCabs     : String;   // ������ (������)
    cvAxles    : String;   // ��� [���.���]/[���] (������ ��� ���.��� TYPEDIR=38/��� ������ ���)
    cvSUAxBR   : String;   // CV - ��������/����������� (������ ����� TYPEDIR=cvtSusp)
                           //    AX - ������� �������   (������ ����� TYPEDIR=axtBrSize)
    property cvTonnOut  : String  index ik16_1 read GetStrMP;  // ������ ��� ������
    property cvHPaxLOout: String  index ik16_2 read GetStrMP;  // ������ ��� ������
    property cvKWaxDIout: String  index ik16_3 read GetStrMP;  // ������ ��� ������
    property cvSecTypOut: String  index ik16_4 read GetStrMP;  // ������ ��� ������
    property cvIDaxBTout: String  index ik16_5 read GetStrMP;  // ������ ��� ������
    property cvCabsOut  : String  index ik16_6 read GetStrMP;  // ������ ��� ������
    property cvWheelsOut: String  index ik16_7 read GetStrMP;  // ������ ��� ������
    property cvSUAxBRout: String  index ik16_8 read GetStrMP;  // ������ ��� ������
    property cvAxlesOut : String  index ik16_9 read GetStrMP;  // ������ ��� ������
  end;

  TNodeLinks = Class;

  TModelAuto = Class (TSubVisDirItem)  // ������
  private // FID - ��� ������, FName - �������� ������,  FSubCode - ��� TecDoc, FOrderNum - ������.� ������,
          // IsVisible - ������� ��������� ������, FLinks - ������ � ������������ ����������, FParCode - ��� ���������� ����
    FParams       : TModelParams; // ��������� ������
    FNodeLinks    : TNodeLinks;   // ������ 2 ����� ������ � �������, Links.GetDoubleLinks(NodeID) - ������ 3 ������� �� ������� 2
    function GetIntM(const ik: T8InfoKinds): Integer;          // �������� ���
    procedure SetIntM(const ik: T8InfoKinds; Value: Integer);  // �������� ���
    function GetStrM(const ik: T8InfoKinds): String;           // �������� ������
    function GetNodesExists: Boolean;                          // ������� ������ 2
    procedure ClearLinks;
  public
    CS_mlinks: TCriticalSection; // ��� ������
    constructor Create(pModelID, pModelTDcode, pOrdNum, pModelLineID: Integer; pName: String);
    destructor Destroy; override;
    function GetModelNodesLinks: TLinks; // must Free , ������ ������ 2 ������ �� ����
    function GetModelNodesList(OnlyVisible: boolean=False; flFromBase: boolean=False): TList; // must Free, ������ ������ 2 � ������ ������ (OnlyVisible=True - ������ ������� ����)
    function GetModelNodeIsSecondLink(nodeID: Integer): Boolean;   // ������� ���� 2-� ������
    function GetModelNodeWaresList(nodeID: Integer; withChildNodes: boolean=True; flFromBase: boolean=False): TStringList; // must Free, ����.������ ������� �� ���� (Object - Pointer(ID))
    function GetModelNodeWares(nodeID: Integer; withChildNodes: boolean=True; flFromBase: boolean=False): Tai;             // must Free, ������ ����� ������� �� ����
    function GetModelParamsUpdSql(mps: TModelParams): string;
    function SetModelVisible(isVis: Boolean): String;          // �������� ��������� ������
    function CheckDiffModelMarks(marks: TStringList): Boolean; // ��������� ���������� �� marks: True - ���� ��������
    function ModelEdit(pName: String; pVisible, pIsTop: Boolean; pUserID: Integer; mps: TModelParams;
                       pOrdNum: Integer=-1; pTDcode: Integer=-1; marks: TStringList=nil): String;
    procedure SetModelParams(mps: TModelParams; flFill: Boolean=False);
    procedure SetModelMarks(marks: TStringList; pUserID: integer); // �������� ���������� �� marks
    function AddModelEngLink(pEngID, pUserID: Integer): String;  // �������� ������ ������ � ����������� ���������

    property ModelLineID   : Integer index ik8_3 read GetIntM  write SetIntM;  // ��� ���������� ����
    property ModelOrderNum : Integer index ik8_4 read GetIntM  write SetIntM;  // ������.� ������
    property TypeSys       : Integer index ik8_1 read GetIntM;  // ��� ������� 1 - ����, 2 - ���� and etc.
    property ModelMfauID   : Integer index ik8_2 read GetIntM;  // ��� �������������
    property ModelHasWares : Boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ������� ������� �� ������
    property IsTop         : Boolean index ik8_4 read GetDirBool write SetDirBool; // ��� ������
    property ModelHasPLs   : Boolean index ik8_5 read GetDirBool write SetDirBool; // ������� ������� ������ ������ � ����.���������
    property NodesExists   : Boolean read GetNodesExists;     // ������� ������ 2
    property SortName      : String  index ik8_1 read GetStrM;  // ������������ ������ ��� ����������
    property MarksCommaText: String  index ik8_2 read GetStrM;  // ������ ���������� ����������
    property ModelLineName : String  index ik8_3 read GetStrM;  // �������� ���������� ���� ������
    property ModelMfauName : String  index ik8_4 read GetStrM;  // �������� ������������� ������
    property WebName       : String  index ik8_5 read GetStrM;  // �������� ������ ��� ������ � Web
    property Params        : TModelParams read FParams;       // ��������� ������ ������ 1,2,4,5
    property NodeLinks     : TNodeLinks   read FNodeLinks;    // ������ 2 ����� ������ � �������
    property EngLinks      : TLinks       read FLinks;        // ������ � ������������ ����������
  end;

  TModelsAuto = Class   // ������ �������
  private
    FarModels: array of TModelAuto; // ������ ������� (������ - ID)
  public
    CS_Models: TCriticalSection; // ��� �������
    constructor Create;
    destructor Destroy; override;
    function GetModel(pModelID: Integer): TModelAuto;       // �������� ������ �� ������ ������
    function ModelExists(pModelID: Integer): Boolean;       // �������� ������������� ������
    function GetMLModelsList(pModelLineID: Integer): Tai;   // must Free, ���������� ������ ����� ������� ���������� ���������� ����
    function ModelAdd(var pModelID: Integer; pName: String; // �������� ������, � ���������� � ����
             pVis, pTops: Boolean; UserID, MLineID: Integer; mps: TModelParams;
             pOrdNum: Integer=-1; pTDcode: Integer=0; marks: TStringList=nil): String;
    function ModelDel(pModelID: Integer): String;           // ������� ������, � ��������� �� ����
    procedure SetStates(pState: Boolean; pModelLineID: Integer=0);     // ������������� ���� �������� ���� ������� ���������� ����
    function SaveMarkAndGetID(var pMarkID: Integer; pTDcode, pModelID, UserID: Integer; pName: String): String; // �������� ���������� � ����
    property Items[index: Integer]: TModelAuto read GetModel; default; // ���������� ��������� ������ �� ������ ������
  end;

//-------------------------------------------------------------------- ���������
  TEngParams = Class  // ��������� ���������
  public
    pCompFrom   : Integer; // ���������� * 100 ��
    pCompTo     : Integer; // ���������� * 100 ��
    pRPMtorqFrom: Integer; // ������ �������� (Nm) ��� [��/���] ��
    pRPMtorqTo  : Integer; // ������ �������� (Nm) ��� [��/���] ��
    pBore       : Integer; // �������� * 1000
    pStroke     : Integer; // ��� ������ * 1000
    pYearFrom   : Word;    // ��� ������� ��
    pYearTo     : Word;    // ��� ������� ��
    pKWfrom     : Word;    // �������� ��� ��
    pRPMKWfrom  : Word;    // ��� [��/���] ��
    pKWto       : Word;    // �������� ��� ��
    pRPMKWto    : Word;    // ��� [��/���] ��
    pHPfrom     : Word;    // �������� �� ��
    pHPto       : Word;    // �������� �� ��
    pCCtecFrom  : Word;    // ���.����� � ���.��. ��
    pCCtecTo    : Word;    // ���.����� � ���.��. ��
    pMonFrom    : Byte;    // ����� ������� ��
    pMonTo      : Byte;    // ����� ������� ��
    pVal        : Byte;    // ���������� ��������
    pCyl        : Byte;    // ���������� ���������
    pCrank      : Byte;    // ���-�� ����������� ���������
    pDesign     : Word;    // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
    pFuelType   : Word;    // ���, ��� �������            (KT 88) (TYPEDIR=12)
    pFuelMixt   : Word;    // ���, ������� �������        (KT 97) (TYPEDIR=5)
    pAspir      : Word;    // ���, ������ �������         (KT 99) (TYPEDIR=14)
    pType       : Word;    // ���, ��� ���������          (KT 80) (TYPEDIR=3)
    pNorm       : Word;    // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
    pCylDesign  : Word;    // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
    pManag      : Word;    // ���, ������ �����������     (KT 77) (TYPEDIR=17)
    pValCnt     : Word;    // ���, ������ �������         (KT 78) (TYPEDIR=18)
    pCoolType   : Word;    // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
    pIsAuto     : Boolean; // ��������� ����.����
    pIsCV       : Boolean; // ��������� ����.����
    pSalesDesc  : String;  // ����������� �������
    procedure Clear;       // �������� ���������
  end;

  TEngine = Class (TSubDirItem) // ���������
  protected // FID - ���, FName - ����������, FSubCode - ��� TecDoc
    FEngMFau: Integer;    // ��� �������������
    FParams : TEngParams; // ��������� ���������
    function GetStrEng(const ik: T8InfoKinds): String;        // �������� ������
  public
    constructor Create(pID, pSubCode, pEngMFau: Integer; pName: String; WithLinks: Boolean=False);
    destructor Destroy; override;
    procedure SetParams(eps: TEngParams; flFill: Boolean=False); // �������� / �������� ���������
    function GetViewList(Delim: String=cSpecDelim): TStringList;   // must Free, ������ ���������� ��������� ��� ���������
    function GetNodesLinks: TLinks;   // must Free, ������ ������ 2 ���������
    function GetEngNodeWareUsesView(nodeID: Integer; WareCodes: Tai; sFilters: String=''): TStringList; // must Free, ������ ������� �� ������� ���� ��������� ��� ���������

    function GetEngNodeWaresWithUsesByFilters(NodeID: Integer; // ������.������ ������� � �������� � ��������� � ������� 3, Objects - WareID
             withChildNodes: boolean=True; sFilters: String=''): TStringList;  // must Free, sFilters - ���� �������� ��������� ����� �������

    property TDCode   : Integer read FSubCode;                // ��� TecDoc
    property EngMFau  : Integer read FEngMFau write FEngMFau; // ��� �������������
    property EngParams: TEngParams read FParams;              // ��������� ���������
    property Mark     : String  index ik8_1 read GetStrEng;     // ����������
    property EngKWstr : String  index ik8_2 read GetStrEng;     // ������ - �������� �������� ���
    property EngHPstr : String  index ik8_3 read GetStrEng;     // ������ - �������� �������� ��
    property EngCCstr : String  index ik8_4 read GetStrEng;     // ������ - �������� ���.����� � ���.��.
    property EngCYLstr: String  index ik8_5 read GetStrEng;     // ������ - �������� ���������� ���������
    property WebName  : String  index ik8_6 read GetStrEng;     // WebName
    property MfauName : String  index ik8_7 read GetStrEng;     // MfauName
    property EngHasNodes: boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ������� 2-� ������
    property EngHasWares: boolean index ik8_4 read GetDirBool write SetDirBool; // ������� ������� 3-� ������
    property EngByAuto  : boolean index ik8_5 read GetDirBool write SetDirBool; // ��������� ��� �������� ����
    property EngByCV    : boolean index ik8_6 read GetDirBool write SetDirBool; // ��������� ��� ����������
  end;

  TEngines = Class (TDirItems) // ���������
  public
    function GetEngine(engID: integer): TEngine;         // �������� ��������� �� ����
    function FindEngineByTDcode(engTD: integer; var eng: TEngine): Boolean; // ����� ��������� �� ���� TecDoc
    function AddEngine(var pID: Integer; pSys, pTDcode, pMFau, pUserID: Integer; // �������� ���������
                       pMark: String; eps: TEngParams): String;
    function EditEngine(pID: Integer; pTDcode, pMFau, pSys, pUserID: Integer; // �������� ���������
                       pMark: String; eps: TEngParams): String;
    function GetMfauEngList(mfau: integer): TStringList; // must Free, ����.�� ����������� ������ ���������� ������������� (Object-TEngine)
  end;

//---------------------------------------------------------------- ��������� ���
  TModelLine = Class (TSubVisDirItem)
  private // FID, FName - ���, ������������ ���������� ����, State - ������ ��������,
          // FSubCode - ��� TecDoc, { FLinks - ������������� ������ ������ �� ������ ���������� ���� / ���������}
          // IsVisible - ������� ��������� ���������� ����, FParCode - ��� ������������� ����
    FYStart    : Word;      // ��� ������ ������������
    FYEnd      : Word;      // ��� ��������� ������������
    FMStart    : Byte;      // ����� ������ ������������
    FMEnd      : Byte;      // ����� ��������� ������������
    FTypeSys   : Byte;      // ��� ������� 1 - ����, 2 - ���� and etc.
    FMLModelsSort : TStringList; // ������������� ������ ������� ���������� ����   (Object - Pointer(ID))
    FMLModelsTopUp: TStringList; // ������ ������� ���������� ���� � ������ ������ (Object - Pointer(ID))
    function GetIntML(const ik: T8InfoKinds): Integer;              // �������� ���
    procedure SetIntML(const ik: T8InfoKinds; Value: Integer);      // �������� ���
    function GetStrML(const ik: T8InfoKinds): String;               // �������� ������
    function GetHasVisModels: Boolean;
  public
    constructor Create(pMLineID, pTDcode, pMFAID: Integer; pName: String);
    destructor Destroy; override;
    procedure ModelDelFromLine(pModelID: Integer); // ������� ������ �� ���������� ����  �� ���
    procedure CheckModelsLists;                   // ��������� ������ ������� ���������� ����
    function GetListModels(pTopsUp: Boolean=False): TStringList; // �������� ������ �������, (Object - Pointer(ID))
    function GetMLModelIDByTDcode(pModTDnr: Integer): Integer; // �������� ��� ������ ���������� ���� �� ���� TecDoc
    property MFAID       : Integer index ik8_2 read GetIntML write SetIntML; // ��� ������������� ����
    property ModelsCount : Integer index ik8_1 read GetIntML;  // ���������� ������� ���������� ����
    property YStart      : Integer index ik8_3 read GetIntML;  // ��� ������ ������������
    property YEnd        : Integer index ik8_4 read GetIntML;  // ��� ��������� ������������
    property MStart      : Integer index ik8_5 read GetIntML;  // ����� ������ ������������
    property MEnd        : Integer index ik8_6 read GetIntML;  // ����� ��������� ������������
    property TypeSys     : Integer index ik8_7 read GetIntML;  // ��� ������� 1 - ����, 2 - ���� and etc.
    property SortName    : String  index ik8_1 read GetStrML;  // ������������ ���������� ���� ��� ����������
    property MLHasWares  : Boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ������� ������� �� ���������� ����
    property IsTop       : Boolean index ik8_4 read GetDirBool write SetDirBool; // ���
    property HasVisModels: Boolean read GetHasVisModels;     // ������� ������� ������� ������� ���������� ����
  end;

  TModelLines = Class    // ������ ��������� �����
  private
    FarModelLines: array of TModelLine;    // ������ ��������� ����� (������ - ID)
  public
    CS_MLines: TCriticalSection; // ��� ���.�����
    constructor Create;
    destructor Destroy; override;
    function GetModelLine(pModelLineID: Integer): TModelLine; // �������� ������ �� ��������� ��� �� ����
    function ModelLineExists(pID: Integer): Boolean; // �������� ������������� ���������� ����
    function GetManufSysModelLinesList(pManufID, pTypeSys: Integer): TStringList; // must Free, ������ ��������� ����� ������������� �� ��������� ������� (Object - Pointer(ID))
    procedure SetStates(pState: Boolean; pTypeSys: Integer=0);   // ������������� ���� �������� ���� ���������
    property Items[Index: Integer]: TModelLine read GetModelLine; default; // ���������� ��������� ������ �� ������ ���������� ����
  end;

//-------------------------------------------------------- ������������� �������
  TManufacturer = Class (TSubDirItem)
  private // FID, FName, State - ���, ������������ �������������, ������, FSubCode - ��� TecDoc
    FManufSysMLsSort : TArraySysTypeLists; // ������������� ������ ��������� ����� �� �������� �����, (Object - Pointer(ID))
    FManufSysMLsTopUp: TArraySysTypeLists; // ������ ��������� ����� � ������ ������ �� �������� �����, (Object - Pointer(ID))
    FManufSearchONlist: TStringList;       // ������������� ������ ����.������� ������������� ��� ����/����, (Object - Pointer(ID))
    FMfauOpts: set of T16InfoKinds;
    function GetBoolMf(ik: T16InfoKinds): boolean;        // �������� �������
    procedure SetBoolMf(ik: T16InfoKinds; Value: boolean); // �������� �������
  public
    constructor Create(pID: Integer; pName: String; pTDnr: Integer=0);  // ���, ���, ��� TecDoc
    destructor Destroy; override;
    procedure TopsSet(pTypeSys: Integer; IsTop: Boolean);    // ���������� / ����� ���������
    procedure TypeSysSet(pTypeSys: Integer; IsSys: Boolean); // ���������� / ����� �������������� �������
    procedure VisibleSet(pTypeSys: Integer; IsVis: Boolean); // ���������� / ����� ���������
    function CheckIsTypeSys(pTypeSys: Integer): Boolean;     // �������� �������������� ������������� � ������� ����/ ����
    function CheckIsVisible(pTypeSys: Integer): Boolean;     // ��������� ���������
    function CheckIsTop(pTypeSys: Integer): Boolean;         // ��������� ������������� ������� ��� ������� �����
    function CheckOtherTypeSys(pTypeSys: Integer): Boolean;  // �������� �������������� � �����-������ ������� ����� pTypeSys
    function CheckHasModelLines(pTypeSys: Integer = 0): Boolean;   // �������� �������� �� � ������������� ��������� ���� ��� ������� �����
    procedure CheckModelLinesLists(pTypeSys: Integer);             // ��������� ������ ��������� ����� ������������� �� ��������� �������
    function GetModelLinesList(pTypeSys: Integer; pTopsUp: Boolean): TStringList; // ������ ��������� ����� ������������� �� ��������� �������, ������������� �� ������������  (Object - Pointer(ID))
    function GetModelsList(pTypeSys: Integer): TStringList;        // must Free, ������ ������� ������������� �� ��������� ������� (Object - Pointer(ID))
    function ModelLineAdd(var ModelLineID: Integer; pName: String; // �������� ��������� ��� � ��� � � ���� � ������������� � �������
             pTypeSys, pMS, pYS, pME, pYE, pUserID: Integer; pIsTop, pIsVis: Boolean; pMLTD: Integer=0): String;
    function ModelLineDel(pModelLineID: Integer): String;          // ������� ��������� ��� �� ���� � �� ���� � �������������
    function ModelLineEdit(pModelLineID, pYS, pMS, pYE, pME, pUserID: Integer;
             pIsTop, pIsVis: Boolean; pName: String=''; pMLTD: Integer=0): String;
    function HasVisModelLines(pTypeSys: Integer): Boolean;    // ������� ������� ������� ��������� ����� �� ��������� �������
    function HasVisMLModels(pTypeSys: Integer): Boolean;      // ������� ������� ������� ������� �� ��������� �������
    function GetMfMLineIDByTDcode(pmlTDnr: Integer; pSys: integer=constIsAuto): Integer; // �������� ��� ���������� ���� ���� �� ���� TecDoc
    property IsMF         : Boolean index ik16_1  read GetBoolMf  write SetBoolMf; // ������� ������������� � �������� (F- ������ ��)
    property IsMfAUTO     : Boolean index ik16_2  read GetBoolMf  write SetBoolMf; // ������� ������������� ����
    property IsMfMOTO     : Boolean index ik16_3  read GetBoolMf  write SetBoolMf; // ������� ������������� ����
    property IsMfTopA     : Boolean index ik16_4  read GetBoolMf  write SetBoolMf; // ������� ���-������������� ����
    property IsMfTopM     : Boolean index ik16_5  read GetBoolMf  write SetBoolMf; // ������� ���-������������� ����
    property IsMfVisA     : Boolean index ik16_6  read GetBoolMf  write SetBoolMf; // ������� ��������� ������������� ����
    property IsMfVisM     : Boolean index ik16_7  read GetBoolMf  write SetBoolMf; // ������� ��������� ������������� ����

    property IsMfCV       : Boolean index ik16_8  read GetBoolMf  write SetBoolMf; // ������� ������������� ����.����
    property IsMfAx       : Boolean index ik16_9  read GetBoolMf  write SetBoolMf; // ������� ������������� ����
//    property IsMfVisCV    : Boolean index ik16_10 read GetBoolMf  write SetBoolMf; // ������� ��������� ������������� ����.����
//    property IsMfVisAx    : Boolean index ik16_11 read GetBoolMf  write SetBoolMf; // ������� ��������� ������������� ����
//    property IsMfTopCV    : Boolean index ik16_12 read GetBoolMf  write SetBoolMf; // ������� ���-������������� ����.����
//    property IsMfTopAx    : Boolean index ik16_13 read GetBoolMf  write SetBoolMf; // ������� ���-������������� ����
    property IsMfEng      : Boolean index ik16_14 read GetBoolMf  write SetBoolMf; // ������� ������������� ����������
//    property IsMfVisEng   : Boolean index ik16_15 read GetBoolMf  write SetBoolMf; // ������� ��������� ������������� ����������
//    property IsMfTopEng   : Boolean index ik16_16 read GetBoolMf  write SetBoolMf; // ������� ���-������������� ����������

    property ManufHasWares: Boolean index ik8_3   read GetDirBool write SetDirBool; // ������� ������� ������� �� �������������
    property MfHasEngWares: Boolean index ik8_4   read GetDirBool write SetDirBool; // ������� ������� ������� ���������� �� �������������
    property ManufSearchONlist: TStringList read FManufSearchONlist;
  end;

  TManufacturers = Class  // ���������� �������������� ����
  private
    FarManufacturers  : array of TManufacturer; // ������ �������������� ���� (������ - ID)
    FSysManufListSort : TArraySysTypeLists;     // ������������� ������ �������������� �� �������� ����� (Objects-Pointer TManufacturer)
    FSysManufListTopUp: TArraySysTypeLists;     // ������ � ������ ������ �� �������� ����� (Objects-Pointer TManufacturer)
    function GetManufItem(pIndex: Integer): TManufacturer; // �������� ������� ������� (������������� �� ����)
  public
    CS_Mfaus: TCriticalSection;       // �������� ������������� ������
    constructor Create;
    destructor Destroy; override;
    function CheckManufItem(pCODE: Integer; var flNew: Boolean; pNAME: String; pTDnr: Integer=0): Boolean;
    function ManufExists(pID: Integer): Boolean;                          // �������� ������������� ������������� � �����
    function ManufExistsByName(pName: String; var pID: Integer): Boolean; // �������� ������������� ������������� �� �����
    function GetManufIDByTDcode(pTDnr: Integer): Integer;                 // �������� ��� ������������� �� ���� TecDoc
    function ManufAdd(var ManufID: Integer; pName: String; pTypeSys, pUserID: Integer;
             pIsTop, pIsVis: boolean; pTDnr: Integer=0): String;   // ������� ������������� � ��������� � ����
    function ManufEdit(var pID: Integer; pTypeSys, pUserID: Integer; // �������� ������������� � � ����
             pIsTop, pIsVis: boolean; pName: String=''; pTDnr: Integer=0): String;
    function ManufDel(var pID: Integer; pTypeSys: Integer): String;  // ������� ������������� � ��������� �� ����
    procedure CheckManufLists(pTypeSys: Integer);                    // ��������� ������ �������
    function GetSortedList(pTypeSys: Integer): TStringList;          // �������� ������������� ������ �������������� ������� (Object - Pointer TManufacturer)
    function GetSortedListWithTops(pTypeSys: Integer): TStringList;  // �������� ������ �������������� ������� � ������ ������ (Object - Pointer TManufacturer)
    procedure SetStates(pState: Boolean; pTypeSys: Integer=0); // ������������� ���� �������� ���� ���������
    function GetNotTestedList(pTypeSys: Integer=0; flTested: TBooleanDynArray=nil): TStringList; // must Free, �������� ������ ������������� �������������� ������� (Object - Pointer(ID))
    function GetEngManufList: TStringList;  // must Free, �������� ������������� ������ �������������� ���������� (Object - Pointer(ID))
    function GetOEManufList: TStringList;  // must Free, �������� ������������� ������ �������������� � �� (Object - Pointer(ID))
    property Items[Index: Integer]: TManufacturer read GetManufItem; default; // ������ ��������������
  end;

//------------------------------------------------------ ������ ����� ����������
  TAutoTreeNode = Class (TSubVisDirItem)  // ���� ������
  private // FID - ��� ����, FName - ������������, State - ������, FSubCode - ��� TecDoc,
          // FOrderNum - ������.����� ���� � ������ ����� �������
    FMainCode: Integer;         // ��� TRNACODE ������� ����
    FMeasID  : Byte;            // ��� ��.���.
    FTypeSys : Byte;            // ��� ������� 1 - ����, 2 - ���� and etc.
    FNameSys : String;          // ������������ ���������
    FChildren: TStringList;     // ������ ��������, Object - Pointer TAutoTreeNode
    function GetIsEnding: boolean;
  public
    constructor Create(pID, pParentID, pMeasID, pSysID: Integer;
                pName, pNameSys: String; pMainCode: Integer=0; pCodeTD: Integer=0;
                pIsGATD: Boolean=False; pVisible: Boolean=True);
    destructor Destroy; override;
    property Children: TStringList read FChildren; // ������ ��������, Object - Pointer TAutoTreeNode
    property NameSys : String  read FNameSys;      // ������������ ���������
    property ParentID: Integer read FParCode;      // ��� ��������
    property MainCode: Integer read FMainCode write FMainCode; // ��� TRNACODE ������� ���� �� �������������
    property OrderNum: Integer read FOrderNum write FOrderNum;  // ������.����� ���� � ������ ����� �������
    property MeasID  : Byte    read FMeasID;       // ��� ��.���.
    property TypeSys : Byte    read FTypeSys;      // ��� ������� 1 - ����, 2 - ���� and etc.
    property Visible : Boolean index ik8_2 read GetDirBool write SetDirBool; // ������� ��������� ����
    property IsGATD  : Boolean index ik8_3 read GetDirBool write SetDirBool; // ������� GA TecDoc (�������� ���� ����)
//    property HasLinks: Boolean index ik8_4 read GetDirBool write SetDirBool; // ������� ������� ������ � ��������
    property IsEnding: Boolean read GetIsEnding; // ������� �������� ����
  end;

{
  TTreeNodes = Class (TDirItems)         // ������ �����
  private // FItems - ������ ������ �� ���� ������, FItems[0] - ������ �� �������� ���� ������
    FSysNodesLists: TArraySysTypeLists;  // ������ ��� ������ �� �������� ����� ���������������� �� ���� ������ (Objects-Pointer TAutoTreeNode)
    function GetNodeByID(pID: Integer): TAutoTreeNode;

  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    property NodeItems[ID: Integer]: TAutoTreeNode read GetNodeByID; default;

    procedure CheckSysNodes(SysID: integer); // ��������� ������ ������ ������� ���������������� �� ���� ������
    function GetSysTree(SysID: integer): TStringList; // �������� ������ ������ ������� SysID ���������������� �� ���� ������
  end;
}
//  TAutoTreeNodesSys = Class;
  TAutoTreeNodes = Class          // ������ ����� �������
  private
    FTypeSys  : Byte;            // ��� ������� 1 - ����, 2 - ���� and etc.
    FNodesList: TStringList;     // ���������������� ������ ��� ������, Object - Pointer TAutoTreeNode
    FNodeItems: array of TAutoTreeNode; // ������ ����� ������ �� �����, FNodeItems[0] - �������� ���� ������
    function GetNodeByID(pID: Integer): TAutoTreeNode;
    function GetNodesList: TStringList;
  public
    CS_Nodes  : TCriticalSection; // �������� FNodesList
    constructor Create(pSysID: Integer=0);
    destructor Destroy; override;
    function NodeAdd(var pID: Integer; pParentID, pMeasID: Integer; pName, pNameSys: String; // �������� ����
             pMainCode: Integer=0; pCodeTD: Integer=0; pIsGATD: Boolean=False;
             pVisible: Boolean=True; pCheckTreeDup: Boolean=False; pReList: Boolean=False): String;
    function NodeValidCheckForAdd(pID, pParentID: Integer; pName, pNameSys: String; // ��������� ���������� ���������� ����
             var pNodeAdd, pNodeParent: TAutoTreeNode; pCheckTreeDup: Boolean=True): String; overload;
    function NodeDel(pNodeID: Integer): String;     // ������� ����
    function NodeEdit(pNodeID, pMainCode, pVisible, pUserID: Integer; pName, pNameSys: String): String; // �������� ��������� ����
    function NodeGet(pID: Integer; var pNodeGet: TAutoTreeNode): Boolean; // �������� ���� �� ����
    function NodeExists(pID: Integer): Boolean; // ��������� ������������� ����
    procedure FillNodesList;                    // ��������� ������ ������ ���������������� �� ���� ������
    function NoteGetTree: TStringList; // must Free, ���������������� ������ ��� ������, Object - Pointer TAutoTreeNode
    // must Free, ������ ���������� ���� pNodeID � �������, Object - Pointer TAutoTreeNode (ByTDid=True - �� ���� TecDoc, False - �� MainCode)
    function GetDuplicateNodes(pNodeID: Integer; ByTDid: Boolean=False): TStringList;
    function GetMainNodeIDByTDcode(pTDnr: Integer): Integer; // �������� ��� ������� ���� �� ���� TecDoc
    function GetNodeIDByTDcodes(nodeTD, parTD: Integer; IsGa: Boolean): Integer; // �������� ��� ���� �� ����� TecDoc
    function GetDuplicateNodeCodes(pMainNodeID: Integer; OnlyVisible: Boolean=False): Tai; // must Free, ���� ����������� ��� ������� ���� pMainNodeID
    property TypeSys : Byte    read FTypeSys;      // ��� ������� 1 - ����, 2 - ���� and etc.
    property Items[ID: Integer]: TAutoTreeNode read GetNodeByID; default;
    property NodesList: TStringList read GetNodesList;      // ���������������� ������ ��� ������, Object - Pointer TAutoTreeNode
  end;

  TATN = array of TAutoTreeNodes;   // ��� �������� ������ �����
  TAutoTreeNodesSys = Class
  private
    FarTreeNodes: TATN; // ������ �������� ������ �����
    function GetTreeNodes(pSys: Integer): TAutoTreeNodes; // �������� ������ �� ������ �� ���� �������
  public
    constructor Create;
    destructor Destroy; override;
    function GetTreeNode(pID: Integer): TAutoTreeNode; // �������� ������ �� ���� �� ���� ��� �������
    property arTreeNodes: TATN read FarTreeNodes;
    property Items[pSys: Integer]: TAutoTreeNodes read GetTreeNodes; default;
  end;

//----------------- ����� ������ �� ������������ ��������������� ��� TSubDirItem
  TNodeLinks = Class (TLinkLinks) // (����� ������� ����������� ������� � ������ dirNodes)
  protected
    function GetLinkItemByID(pID: Integer): Pointer; override;// �������� ������ �� ���� ���������� ��������
  public
    dirNodes: TAutoTreeNodes; // ������ �� ���������� ��������������� ��� TSubDirItem
  end;

//---------------------------------------------------- ������������ ����� ������
  TOriginalNumInfo = class (TSubDirItem) // FName - ������������ �����, FSubCode - ��� ������������� ����
  private                                // FLinks - ������ � ��������, ��������������� �� ������������
    function GetIntON(const ik: T8InfoKinds): Integer;         // �������� ���
    procedure SetIntON(const ik: T8InfoKinds; Value: Integer); // �������� ���
    function GetStrON(const ik: T8InfoKinds): String;          // �������� ������
    procedure SetStrON(const ik: T8InfoKinds; Value: String);  // �������� ������
  public
    constructor Create(pID, pMfau: Integer; pNum: String; CS: TCriticalSection=nil);
    function ArAnalogs     : Tai;                                              // must Free, ������ ����� �������
    function GetAnalogTypes(WithoutEmpty: Boolean=False): Tai;                 // must Free, ������ ����� ����� ��������
    property MfAutoID      : Integer index ik8_1 read GetIntON write SetIntON; // ��� ������������� ����
    property TypeID        : Integer index ik8_2 read GetIntON;                // ��� ���� �� ��������� �������
    property OriginalNum   : string  index ik8_1 read GetStrON write SetStrON; // ����.����� ������ UpperCase �/������������
    property ManufName     : String  index ik8_2 read GetStrON;                // ������������ ������.����
    property SortString    : String  index ik8_3 read GetStrON;                // ������ ��� ���������� �� ������.����
    property CommentWWW    : String  index ik8_4 read GetStrON;                // ����������� ��� Web � ������ ���� ������
  end;

  arTOE = array of TOriginalNumInfo;

//--------------------------------------------- TYPESINFOMODEL - ������ �� �����
  TTypeInfoModel = Class (TBaseDirItem)
  private
    FTypeDir: Word;         // ��� ������
    FTDcode : Word;         // ��� KEY_ENTRIES.KE_KEY as integer (TDT)
    FTDkt   : Word;         // ��� KEY_ENTRIES.KE_KT_ID (TDT)
  public
    constructor Create(pID, pType, pTDcode, pTDkt: Integer; pName: String);
    function SetTypeDir(pType: Word): Boolean;
    property TypeDir: Word read FTypeDir;     // ��� ������
    property TDcode : Word read FTDcode;      // ��� KEY_ENTRIES.KE_KEY as integer (TDT)
    property TDkt   : Word read FTDkt;        // ��� KEY_ENTRIES.KE_KT_ID (TDT)
  end;

  TTypesInfoModel = Class (TDirItems)  //
  private
    FTypeTDcodes: Tai;
    FTypeLists: TArrayTypeLists;                        // ����� ������� �� �����
    function GetList(pTypeDir: Word): TStringList;      // �������� ������ ��������� ��������� ���� (Object - Pointer(ID))
    function GetInfoItem(pID: Integer): TTypeInfoModel; // �������� �������������� ������� ������
  public
    constructor Create(LengthStep: Word=10);
    destructor Destroy; override;

    function GetTypeName(pType: Integer): String;   // �������� ���� ������
    function GetItemTypeName(pID: Integer): String; // �������� ���� ������ �� ID ��������
    procedure CheckInfoModelItem(pID: Integer; pType, pTDkey, pTDkt: Word; pName: String); // ��������� / �������� ������� ������ � ���
    function AddInfoModelItem(var pID, pType: Integer; pTDkey, pTDkt: Word; pName: String; pUser: Integer): String; // �������� ������� ������ � ��� � � ����
    function FindInfoItemByTDcodes(var pID, pTyp: Integer; pTDkey, pTDkt: Word): Boolean; // ����� ��� ���� ������ � ��� �������� ������ �� ����� TecDoc
    function FindInfoItemByValue(var pID: Integer; pType: Word; Value: String): Boolean; // ����� ��� �������� ������ �� ��������
    property InfoModelList[TypeDir: Word]: TStringList read GetList;     // ������ ��������� ��������� ����
    property InfoItems[index: Integer]: TTypeInfoModel read GetInfoItem; // �������� �������������� ������� ������
  end;

//----------------- ���������� � DataCache ��� ����� ������������ ������� � �.�.
  TDataCacheAdditionASON = class
  protected
    FManufacturers    : TManufacturers;    // ������������� ����/����
    FModelLines       : TModelLines;       // ��������� ����
    FModels           : TModelsAuto;       // ������
    FLinkSources      : TDirItems;         // ���������� ���������� ���������� � ������
    FarOriginalNumInfo: arTOE;             // ������ ������������ ������� ������
    FAutoTreeNodesSys : TAutoTreeNodesSys; // ������� ����� �������������� �������������
    FTypesInfoModel   : TTypesInfoModel;
//    FTreeNodes        : TTreeNodes;        // ������ �����
    CS_OrigNums       : TCriticalSection;
    FEngines          : TEngines;
  public
    constructor Create;
    destructor Destroy; override;
    procedure FillSourceLinks;   // ����������/�������� ������ ���������� ������������ ������� � ������ � ���������.
    procedure FillTreeNodesAuto; // ���������� ������ ����� ����������
    procedure FillOriginalNums(fFill: Boolean=True); // ����������/�������� ������������ ������� ������
    procedure FillWareONLinks(fFill: Boolean=True; sLog: String=''); // ����� ���������� ������ ������������ �������
    procedure FillTypesInfoModel;
    procedure FillDirManuf(fFill: Boolean=True);      // ��������/���������� ����������� �������������� �� ����
    procedure FillDirModelLines(fFill: Boolean=True); // ��������/ ���������� ������ ��������� �����
    procedure FillDirEngines(fFill: Boolean=True);    // �������� / ���������� ������ ���������� �� ���� � ���
    procedure FillDirModels(fFill: Boolean=True);     // �������� / ���������� ������ ������� �� ���� � ���
    procedure FillModelNodeLinks;                     // �������� ������ ������� � ������� ����� (������ 2)
    procedure FillWareModelNodeLinks;                 // �������� ������ ������ �� ������� 2 (������ 3)

    function GetModelTypeSys(pModelID: Integer): Integer;
    function TreeNodeAdd(pTypeSys, pParentID, pMainCode: Integer; pNodeName, pNodeNameSys: String;
             pUserID: Integer; var pNodeID: Integer; pVisible: Boolean=True; pMeasID: Integer=0;  // �������� ����
             pCodeTD: Integer=0; pIsGATD: Boolean=False): String; // ���������� �������� � ������ �����
    function SourceLinkExist(ID: Integer): Boolean;
    function OrigNumExist(ID: Integer): Boolean;
    function ManufAutoExist(ID: Integer): Boolean;
    function GetArLinkSources: Tas;                                        // must Free, ���������� ���������� � �������
    function GetSourceByGBcode(srcGB: Integer): Integer;                   // ��� ��������� �� ���� Grossbee
    function GetSourceGBcode(src: Integer): Integer;                       // ��� ��������� Grossbee

    function SearchOriginalNum(Manuf: Integer; OrigNum: String): Integer;  // ���������� ��� ������������� ������, ���� � ���� ��� - -1
    function GetOriginalNum(ID: Integer): TOriginalNumInfo;                // ���������� ������ ������������� ������ �� ����
    function AddNewOrigNumToCache(pID, pMfau: Integer; pNum: String; step: Integer=100): TOriginalNumInfo;  // ���������� ������������� ������ � ���
    function SearchWareOrigNums(Template: String; IgnoreSpec: Integer;   // must Free, ����� ������������ �������
             sortManuf: Boolean; var TypeCodes: Tai): Tai;
    function fnGetListAnalogsWithManufacturer(pWareID, pManufID: Integer; var pAr1, pAr2: Tai): Integer;   // �������� ������ �������� �� ������ ������������ ������� � ������ ������������� ����

    function CheckNotValidModelNodeLinkParams(ModelID, NodeID: Integer; // ��������� ��������� ������ 2
             var Model: TModelAuto; var Node: TAutoTreeNode; var SysID: Integer; var errmess: string): Boolean;
    function CheckModelNodeLinkDup(ModelID, NodeID: Integer; Value: String; // �������� / ���������� / �������������� ������ 2 �� ������ ���������� ���
             var ResCode: Integer; srcID: Integer=0; userID: Integer=0): string;
    function CheckWareModelNodeLink(WareID, ModelID, NodeID: Integer;   // �������� / ���������� / �������������� ������ 3
             var ResCode: Integer; srcID: Integer=0; userID: Integer=0): string;
    function CheckWareModelNodeUsage(WareID, ModelID, NodeID: Integer;  // �������� / ���������� ������� ���������� ������ 3
             UsageName, UsageValue: String; var ResCode: Integer; srcID: Integer=0; userID: Integer=0): string;
    function CheckOrigNumLink(var ResCode: Integer; WareID, pMfID: Integer; var onID: Integer; // ���������� / ����� ����� � ����.�������
             var pONum: String; srcID: Integer=0; userID: Integer=0): String;

     // must Free, ������ �������� �������� ���� ������/���������, Strings - �������� ��������, Object - Pointer(ID ��������)
    function GetModelOrEngNodeFiltersList(NodeID, pID: integer; IsEngine: Boolean=False): TStringList;

    property Manufacturers    : TManufacturers read FManufacturers; // ������������� ����/����/����������
    property ModelLines       : TModelLines read FModelLines;       // ��������� ����
    property Models           : TModelsAuto read FModels;           // ������
    property arOriginalNumInfo: arTOE read FarOriginalNumInfo write FarOriginalNumInfo;
    property AutoTreeNodesSys : TAutoTreeNodesSys read FAutoTreeNodesSys;
    property TypesInfoModel   : TTypesInfoModel read FTypesInfoModel;
//    property TreeNodes        : TTreeNodes read FTreeNodes;
    property LinkSources      : TDirItems  read FLinkSources;
    property Engines          : TEngines  read FEngines;
  end;

//                              ����������� �������
function GetNameForSort(pName: String; pY, pM: Integer): String; // ������������ ������ ��� ���������� �������
function FindNodeIndex(NodeID: Integer; lstNodes: TStringList): Integer;  // ���� ������ ���� � ����� NodeID � lstNodes

implementation
uses n_DataCacheInMemory, n_server_common, n_TD_functions, n_server_main, n_Functions;
//=================================== ���� ������ ���� � ����� NodeID � lstNodes
function FindNodeIndex(NodeID: Integer; lstNodes: TStringList): Integer;
begin
  for Result:= 0 to lstNodes.Count-1 do
    if TAutoTreeNode(lstNodes.Objects[Result]).ID=NodeID then exit;
  Result:= -1;
end;

//******************************************************************************
//  TNodeLinks - ����� ������ �� ������������ ��������������� ��� TSubDirItem
//******************************************************************************
//===================== ���������� ������ �� ������� � ����� pID, ���� ��� - nil
// ����� ������� ����������� �������
function TNodeLinks.GetLinkItemByID(pID: Integer): Pointer;
var i, SearchNum, iLow, iHigh, iNum: Integer;
begin
  Result:= nil;
  if not Assigned(self) or (pID<1) then Exit;
  if not Assigned(dirNodes) or not dirNodes.NodeExists(pID) then Exit;
  SearchNum:= GetDirItemOrdNum(dirNodes[pID]); // ���.� �������� ��-��
  iLow:= 0;                     // ������ ������
  iHigh:= FItems.Count-1;       // ������� ������
  while (iHigh-iLow)>4 do begin
    i:= (iLow+iHigh) div 2;   // ������ �������� ��-��
    if (TLink(FItems[i]).LinkID=pID) then begin
      Result:= FItems[i];
      Exit;
    end;
    iNum:= GetDirItemOrdNum(TLink(FItems[i]).LinkPtr); // ���.� �������� ��-��
    if (SearchNum<iNum) then iHigh:= i-1 else iLow:= i+1;
  end;
  for i:= iLow to iHigh do // ���� ��������� � ���������� ���������
    if TLink(FItems[i]).LinkID=pID then begin
      Result:= FItems[i];
      Exit;
    end;
end;

//******************************************************************************
//               TArraySysTypeLists - ����� ������� �� �������� �����
//******************************************************************************
constructor TArraySysTypeLists.Create(fSorted: Boolean=False; fDelimiter: Boolean=False);
var i: integer;
    item: TDirItem;
begin
  inherited Create(fSorted, fDelimiter);
  with SysTypes do for i:= 0 to Count-1 do begin // ����� ����� ������
    Item:= ItemsList[i];
    AddTypeOfList(Item.ID, Item.Name);
  end;
end;

//******************************************************************************
//                                 TSecondLink
//******************************************************************************
constructor TSecondLink.Create(pSrcID: Integer; pQty: Single; pNodePtr: Pointer=nil;
            pIsLink: Boolean=False; pHasWares: Boolean=False; pHasFilters: Boolean=False; pHasMotul: Boolean=False);
begin
  inherited Create(pSrcID, pNodePtr);
  IsLinkNode    := pIsLink;
  NodeHasWares  := pHasWares;
  NodeHasFilters:= pHasFilters;
  NodeHasPLs  := pHasMotul;
  FQty          := RoundTo(pQty, -3);
end;
//===================================== must Free, ������ ����� ������� ������ 2
function TSecondLink.GetWareCodes: Tai;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  if Assigned(DoubleLinks) then Result:= DoubleLinks.GetLinkListCodes(lkLnkNone);
end;

//******************************************************************************
//                          TTypeInfoModel
//******************************************************************************
constructor TTypeInfoModel.Create(pID, pType, pTDcode, pTDkt: Integer; pName: String);
begin
  inherited Create(pID, pName);
  FTypeDir:= pType;
  FTDcode := pTDcode;
  FTDkt   := pTDkt;
end;
//========================================================== �������� ��� ������
function TTypeInfoModel.SetTypeDir(pType: Word): Boolean;
begin
  Result:= False;
  if not Assigned(self) or (FTypeDir=pType) then Exit;
  FTypeDir:= pType;
  Result:= True;
end;

//******************************************************************************
//                          TTypesInfoModel
//******************************************************************************
//==============================================================================
constructor TTypesInfoModel.Create(LengthStep: Word=10);
begin
  inherited Create(LengthStep);
  FTypeLists:= TArrayTypeLists.Create(True);
  SetLength(FTypeTDcodes, 0);
end;
//==============================================================================
destructor TTypesInfoModel.Destroy;
begin
  if not Assigned(self) then Exit;
  if Assigned(FTypeLists) then prFree(FTypeLists);
  SetLength(FTypeTDcodes, 0);
  inherited Destroy;
end;
//============================ ���������� ������������� ������ ��������� �� ����
function TTypesInfoModel.GetList(pTypeDir: Word): TStringList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= FTypeLists[pTypeDir];
end;
//======================================= �������� �������������� ������� ������
function TTypesInfoModel.GetInfoItem(pID: Integer): TTypeInfoModel;
begin
  if ItemExists(pID) then Result:= DirItems[pID] else Result:= DirItems[0];
end;
//========================================================= �������� ���� ������
function TTypesInfoModel.GetTypeName(pType: Integer): String;
var i: Integer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  with FTypeLists.ListTypes do for i:= 0 to Count-1 do // ������ ����� �������
    if Integer(Objects[i])=pType then begin
      Result:= Strings[i];
      exit;
    end;
end;
//========================================== �������� ���� ������ �� ID ��������
function TTypesInfoModel.GetItemTypeName(pID: Integer): String;
var pType: Integer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  pType:= GetInfoItem(pID).FTypeDir;
  Result:= GetTypeName(pType);
end;
//========================================== ��������� ��� ������ � ������������
procedure TTypesInfoModel.CheckInfoModelItem(pID: Integer; pType, pTDkey, pTDkt: Word; pName: String);
var i: Integer;
    s: String;
    Item: Pointer;
begin
  if not Assigned(self) then Exit;
  if ItemExists(pID) then begin  // ��������� ��� ������, ������������
    with TTypeInfoModel(DirItems[pID]) do begin
      i:= TypeDir;
      s:= Name;
      if i<>pType then SetTypeDir(pType);
      if (pTDkey>0) and (FTDcode<>pTDkey) then FTDcode:= pTDkey;
      if (pTDkt>0) and (FTDkt<>pTDkt) then FTDkt:= pTDkt;
    end;
    if i<>pType then begin
      FTypeLists.DelTypeListItem(i, pID);
      FTypeLists.AddTypeListItem(pType, pID, pName);
    end;
    if s<>pName then begin
      SetItemName(pID, pName);
      i:= FTypeLists[pType].IndexOfObject(Pointer(pID));
      if i>-1 then fnChangeStringOfList(FTypeLists[pType], i, pName);
    end;
  end else begin
    Item:= TTypeInfoModel.Create(pID, pType, pTDkey, pTDkt, pName);
    if CheckItem(Item) then  // ��������� ������� � ������ ������
      FTypeLists.AddTypeListItem(pType, pID, pName);
  end;
end;
//======================================= �������� ������� ������ � ��� � � ����
function TTypesInfoModel.AddInfoModelItem(var pID, pType: Integer;
         pTDkey, pTDkt: Word; pName: String; pUser: Integer): String;
const nmProc = 'AddInfoModelItem';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if (pID>0) and ItemExists(pID) then Exit;
  pID:= 0;
  if (pTDkey>0) and (pTDkt>0) and FindInfoItemByTDcodes(pID, pType, pTDkey, pTDkt) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if (pType<1) then raise Exception.Create('�� ����� ��� ������');

    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);

    ORD_IBS.SQL.Text:= 'insert into DIRINFOTYPEMODEL'+
      ' (DITMTYPEDIR, DITMNAME, DITMUSERID'+fnIfStr(pTDkey>0, ', DITMTDKEYENTR', '')+
      ') values ('+IntToStr(pType)+', :DITMNAME, '+IntToStr(pUser)+
      fnIfStr(pTDkey>0, ', '+IntToStr(pTDkey), '')+
      ') returning DITMCODE';
    ORD_IBS.ParamByName('DITMNAME').AsString:= pName;
    ORD_IBS.ExecQuery;
    if not (ORD_IBS.Eof and ORD_IBS.Bof) then
      pID:= ORD_IBS.FieldByName('DITMCODE').AsInteger;
    if pID<1 then raise Exception.Create(MessText(mtkErrAddRecord));
    ORD_IBS.Transaction.Commit;
    ORD_IBS.Close;

    prMessageLOGS(nmProc+': DIRINFOTYPEMODEL add id, type, TDid, Name= '+ // ������� ����� � ���
      IntToStr(pID)+', '+IntToStr(pType)+', '+IntToStr(pTDkey)+', '+pName, 'import', false);

    CheckInfoModelItem(pID, pType, pTDkey, pTDkt, pName);  // ��������� / ��������� �������
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
end;
//================== ����� ��� ���� ������ � ��� �������� ������ �� ����� TecDoc
function TTypesInfoModel.FindInfoItemByTDcodes(var pID, pTyp: Integer; pTDkey, pTDkt: Word): Boolean;
const nmProc = 'FindInfoItemByTDcodes';
var i: Integer;
begin
  Result:= False;
  pID:= 0;
  if not Assigned(self) then Exit;
  if pTyp<1 then for i:= Low(FTypeTDcodes) to High(FTypeTDcodes) do
    if FTypeTDcodes[i]=pTDkt then begin // ���� ��� ���� ������ �� ���� TD
      pTyp:= i;
      break;
    end;
  if FTypeLists.TypeOfListExists(pTyp) then with InfoModelList[pTyp] do
    for i:= 0 to Count-1 do with TTypeInfoModel(DirItems[Integer(Objects[i])]) do begin
      Result:= (TDcode=pTDkey) and (TDkt=pTDkt);
      if Result then begin
        pID:= ID;
        Exit;
      end;
    end;
end;
//======================================== ����� ��� �������� ������ �� ��������
function TTypesInfoModel.FindInfoItemByValue(var pID: Integer; pType: Word; Value: String): Boolean;
const nmProc = 'FindInfoItemByValue';
var i: Integer;
begin
  Result:= False;
  pID:= 0;
  if not Assigned(self) then Exit;
  if (pType<1) then Exit;
  if not FTypeLists.TypeOfListExists(pType) then Exit;
  with InfoModelList[pType] do begin
    i:= IndexOf(Value);
    Result:= (i>-1);
    if Result then pID:= Integer(Objects[i]);
  end;
end;

//******************************************************************************
//                                  TAutoTreeNode
//******************************************************************************
constructor TAutoTreeNode.Create(pID, pParentID, pMeasID, pSysID: Integer;
            pName, pNameSys: String; pMainCode: Integer=0; pCodeTD: Integer=0;
            pIsGATD: Boolean=False; pVisible: Boolean=True);
begin
  inherited Create(pID, pCodeTD, 0, pName, 0, False); // TDirItem ��� ������
  State    := True;
  FParCode := pParentID;    // ��� ���� ��������
  FNameSys := pNameSys;     // ������������ ���� (���������)
  FChildren:= fnCreateStringList(True, dupIgnore); // ������ ����������� �����
  FMeasID  := pMeasID;
  FMainCode:= pMainCode;    // ��� TRNACODE ������� ����
  FTypeSys := pSysID;
  FOrderNum:= 0;            // ������.����� ���� � ������ ����� �������
  Visible  := pVisible;     // ������� ��������� ����
  IsGATD   := pIsGATD;      // ������� GA TecDoc (�������� ����)
end;
//==============================================================================
destructor TAutoTreeNode.Destroy;
begin
  if not Assigned(self) then Exit;
  if Assigned(FChildren) then prFree(FChildren);
  inherited Destroy;
end;
//======================================================== ������� �������� ����
function TAutoTreeNode.GetIsEnding: boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= not Assigned(FChildren) or (FChildren.Count<1);
end;

{
//******************************************************************************
//                               TTreeNodes
//******************************************************************************
constructor TTreeNodes.Create(LengthStep: Integer=10);
begin
  inherited Create(LengthStep);
  SetLength(FItems, 1);
  FItems[0]:= TAutoTreeNode.Create(0, -1, 0, 0, 'Root', 'Root'); // �������� ���� ������
  FSysNodesLists:= TArraySysTypeLists.Create(False, True);  // ������ ��� ������ �� �������� ����� ���������������� �� ���� ������ (Objects-Pointer TAutoTreeNode)
end;
//==============================================================================
destructor TTreeNodes.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FSysNodesLists);
  inherited Destroy;
end;
//======================================================== �������� ���� �� ����
function TTreeNodes.GetNodeByID(pID: Integer): TAutoTreeNode;
begin
  Result:= nil;
  if not Assigned(self) or not ItemExists(pID) then Exit;
  Result:= TAutoTreeNode(FItems[pID]);
end;
//============ ��������� ������ �������� ������� ���������������� �� ���� ������
procedure TTreeNodes.CheckSysNodes(SysID: integer);
var ii: Integer;
    Node: TAutoTreeNode;
  //----------------------------
  procedure GetNodes(pNode: TAutoTreeNode; syslist: TStringList);
  var i: Integer;
  begin
    if not Assigned(syslist) then exit;
    syslist.AddObject(pNode.Name, pNode);
    if Assigned(pNode.Children) then
      for i:= 0 to pNode.Children.Count-1 do
        GetNodes(TAutoTreeNode(pNode.Children.Objects[i]), syslist);
  end;
  //-----------------------------
begin
  if not Assigned(self) or not Assigned(NodeItems[0].Children) then Exit;
  if not FSysNodesLists.TypeOfListExists(sysID) then Exit;
  if (FSysNodesLists[sysID].Delimiter=LCharGood) then Exit;

  FSysNodesLists.CS_ATLists.Enter;
  try
    FSysNodesLists[sysID].Clear; // ������ ������
    with NodeItems[0].Children do for ii:= 0 to Count-1 do begin // ��������� ������
      Node:= TAutoTreeNode(Objects[ii]);
      if (sysID=Node.TypeSys) then GetNodes(Node, FSysNodesLists[sysID]);
    end;
  finally
    FSysNodesLists.CS_ATLists.Leave;
  end;
end;
//=============== �������� ������ ������ ������� ���������������� �� ���� ������
function TTreeNodes.GetSysTree(SysID: integer): TStringList;
begin
  Result:= nil;
  if not Assigned(self) or not FSysNodesLists.TypeOfListExists(sysID) then Exit;
  CheckSysNodes(SysID);
  FSysNodesLists.CS_ATLists.Enter;
  try
    Result:= FSysNodesLists[sysID];
  finally
    FSysNodesLists.CS_ATLists.Leave;
  end;
end;
}
//******************************************************************************
//                               TAutoTreeNodes
//******************************************************************************
constructor TAutoTreeNodes.Create(pSysID: Integer=0);
begin
  inherited Create;
  SetLength(FNodeItems, 1);
  FNodeItems[0]:= TAutoTreeNode.Create(0, -1, 0, 0, 'Root', 'Root');
  FTypeSys := pSysID;
  FNodesList:= TStringList.Create;
  CS_Nodes:= TCriticalSection.Create; // �������� FNodesList
end;
//==============================================================================
destructor TAutoTreeNodes.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  prFree(FNodesList);
  for i:= Low(FNodeItems) to High(FNodeItems) do
    if Assigned(FNodeItems[i]) then try prFree(FNodeItems[i]); except end;
  SetLength(FNodeItems, 0);
  prFree(CS_Nodes);
  inherited Destroy;
end;
//======================================================== �������� ���� �� ����
function TAutoTreeNodes.GetNodeByID(pID: Integer): TAutoTreeNode;
begin
  Result:= nil;
  if not Assigned(self) or not NodeExists(pID) then Exit;
  Result:= FNodeItems[pID];
end;
//=========================================================== �������� NodesList
function TAutoTreeNodes.GetNodesList: TStringList;
begin
  CS_Nodes.Enter;
  try
    Result:= FNodesList;
  finally
    CS_Nodes.Leave;
  end;
end;
//================================================================ �������� ����
function TAutoTreeNodes.NodeAdd(var pID: Integer; pParentID, pMeasID: Integer; pName, pNameSys: String;
         pMainCode: Integer=0; pCodeTD: Integer=0; pIsGATD: Boolean=False; pVisible: Boolean=True;
         pCheckTreeDup: Boolean=False; pReList: Boolean=False): String;
var pNodeAdd, pNodeParent: TAutoTreeNode;
    j, jj: Integer;
begin
  if not Assigned(self) then begin
    Result:= MessText(mtkErrProcess);
    Exit;
  end;
  pNodeAdd:= nil;
  Result:= NodeValidCheckForAdd(pID, pParentID, pName, pNameSys, pNodeAdd, pNodeParent, pCheckTreeDup);
  if (Result<>'') then Exit;
  if not Assigned(pNodeParent.Children) then
    pNodeParent.FChildren:= fnCreateStringList(True, dupIgnore);
  if High(FNodeItems)<pID then begin
    jj:= Length(FNodeItems);         // ��������� ����� �������
    SetLength(FNodeItems, pID+100);  // � ���������� ��������
    for j:= jj to High(FNodeItems) do if j<>pID then FNodeItems[j]:= nil;
  end;
  FNodeItems[pID]:= TAutoTreeNode.Create(pID, pParentID, pMeasID, TypeSys, pName, PNameSys,
             pMainCode, pCodeTD, pIsGATD, pVisible);
  pNodeParent.Children.AddObject(pName, FNodeItems[pID]);
  if pReList then FillNodesList; // ���� ���� - ������������� ������ ��������������� ����� �������
end;
//========================================= ��������� ���������� ���������� ����
function TAutoTreeNodes.NodeValidCheckForAdd(pID, pParentID: Integer; pName, pNameSys: String;
         var pNodeAdd, pNodeParent: TAutoTreeNode; pCheckTreeDup: Boolean=True): String;
const nmProc = 'NodeValidCheckForAdd';
var idx, i: Integer;
begin
  Result:= '';
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrProcess));
    if (pName='') then raise Exception.Create(MessText(mtkEmptyName));
    if (pNameSys='') then raise Exception.Create(MessText(mtkEmptySysName));

    if not NodeGet(pParentID, pNodeParent) then // ���� �������� �� ������
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pParentID)));

    if NodeGet(pID, pNodeAdd) then raise Exception.Create('�������� ���� ����');

    if (Result<>'') or not pCheckTreeDup then Exit;
// �������� �� ������� ������� � ���� �������� ???
    if Assigned(pNodeParent.Children) then
      if pNodeParent.Children.Find(pName, idx) then begin
        pNodeAdd:= TAutoTreeNode(pNodeParent.Children.Objects[idx]); // ��������
        raise Exception.Create('��� ������ ���� ����� �������� ����� ����� ��������.');
      end;

    with NodesList do for i:= 0 to Count-1 do
      if Assigned(Objects[i]) then with TAutoTreeNode(Objects[i]) do try
        idx:= ID;
        if AnsiUpperCase(NameSys)=AnsiUpperCase(pNameSys) then
          raise Exception.Create(MessText(mtkDuplicateSysNm, pNameSys));  // ������� ���� � ����� �� ��������� ������, ��������
      except
        prMessageLOGS(nmProc+': except - id='+IntToStr(idx), fLogCache, false);
      end;
  except
    on E: Exception do Result:= E.Message;
  end;
end;
//================================================================= ������� ����
function TAutoTreeNodes.NodeDel(pNodeID: Integer): String;
const nmProc = 'NodeDel';
var NodeAuto, NodeParent: TAutoTreeNode;
    idxParent: Integer;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrDelRecord));
    if not NodeGet(pNodeID, NodeAuto) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pNodeID)));

    if not NodeAuto.IsEnding then
      raise Exception.Create('���� ����� ����������� ����.');
    if not NodeGet(NodeAuto.ParentID, NodeParent) then
      raise Exception.Create('�� ������ ������������ ����.');

    ORD_IBD:= cntsORD.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True); //  �������� � ����
      ORD_IBS.SQL.Text:= 'delete from TREENODESAUTO where TRNACODE='+IntToStr(pNodeId);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    idxParent:= NodeParent.Children.IndexOfObject(NodeAuto);  // ������� ���� � ������ ��������
    CS_Nodes.Enter;
    try
      NodeParent.Children.Delete(idxParent); // ������� �� ������ �����
    finally
      CS_Nodes.Leave;
    end;

    idxParent:= NodesList.IndexOfObject(NodeAuto);  // ������� ���� � ������ �����
    if idxParent>-1 then try
      CS_Nodes.Enter;
      FNodesList.Delete(idxParent);
    finally
      CS_Nodes.Leave;
    end;
    prFree(NodeAuto);                      // ������� ���� �� ������
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//====================================================== �������� ��������� ����
function TAutoTreeNodes.NodeEdit(pNodeID, pMainCode, pVisible, pUserID: Integer; pName, pNameSys: String): String;
const nmProc = 'NodeEdit';
// pMainCode<1 - �� ������, pVisible<0 - �� ������, pName, pNameSys='' - �� ������
var Node, NodeParent: TAutoTreeNode;
    idxParent, idxParent2, ResCode: Integer;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    flUpdName, flUpdSysName, flUpdVis, flUpdMain: Boolean;
    s: String;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  idxParent:= -1;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrEditRecord));
    if not NodeGet(pNodeID, Node) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pNodeID))); // ���� � ����� pID �� ������
    pName:= Trim(pName);
    pNameSys:= Trim(pNameSys);
    if (pNameSys<>'') then pNameSys:= AnsiUpperCase(pNameSys);

    flUpdName   := (pName<>'')    and (Node.Name<>pName);
    flUpdSysName:= (pNameSys<>'') and (Node.NameSys<>pNameSys);
    flUpdMain   := (pMainCode>0)  and (Node.MainCode<>pMainCode);
    flUpdVis    := (pVisible>-1)  and (Node.Visible<>(pVisible=1));

    if not flUpdName and not flUpdSysName and not flUpdVis and not flUpdMain then
      raise Exception.Create(MessText(mtkNotChanges));

    if not NodeGet(Node.ParentID, NodeParent) then
      raise Exception.Create('�� ������ ������������ ����.');

    if flUpdName then begin
      idxParent:= NodeParent.Children.IndexOfObject(Node);
      if NodeParent.Children.Find(pName, idxParent2) and (idxParent <> idxParent2) then
        raise Exception.Create('����� ��� ���� ����� �������� ����� ����� ��������.');
    end;

    if flUpdSysName then with NodesList do for idxParent2:= 0 to Count-1 do
      if Assigned(Objects[idxParent2]) then with TAutoTreeNode(Objects[idxParent2]) do
        if (ID<>pNodeID) and (AnsiUpperCase(NameSys)=pNameSys) then // ������� ���� � ����� �� ��������� ������, ��������
          raise Exception.Create(MessText(mtkDuplicateSysNm, pNameSys));

//------------------------------------------- ��������� ������������ � ���������
    if flUpdName or flUpdSysName or flUpdVis then begin

      ORD_IBD:= cntsORD.GetFreeCnt;
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);  // � ����
        ORD_IBS.SQL.Text:= 'update TREENODESAUTO set '+
          fnIfStr(flUpdName,    'TRNANAME=:TRNANAME, ', '')+
          fnIfStr(flUpdSysName, 'TRNANAMESYS=:TRNANAMESYS, ', '')+
          fnIfStr(flUpdVis,     'TRNAVISIBLE='+fnIfStr((pVisible=1), '"T"', '"F"')+', ', '')+
          'TRNAUSERID='+IntToStr(pUserID)+' where TRNACODE='+IntToStr(pNodeID);
        if flUpdName    then ORD_IBS.ParamByName('TRNANAME').AsString:= pName;
        if flUpdSysName then ORD_IBS.ParamByName('TRNANAMESYS').AsString:= pNameSys;
        ORD_IBS.ExecQuery;
        ORD_IBS.Transaction.Commit;
      finally
        prFreeIBSQL(ORD_IBS);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;

      CS_Nodes.Enter;
      try
        if flUpdName then begin // ���� ������ ���
          Node.Name:= pName;
          fnChangeStringOfList(NodeParent.Children, idxParent, pName);
          FillNodesList; // ������������� ������ ��������������� ����� �������
        end;
        if flUpdSysName then Node.FNameSys:= pNameSys;
        if flUpdVis     then Node.Visible:= (pVisible=1);
      finally
        CS_Nodes.Leave;
      end;
    end;

    if flUpdMain then begin //---------------------- ��������� ���� ������� ����
      if (Node.ID<>Node.MainCode) then begin // ������� ����������� ����
        ResCode:= resDeleted;
        s:= Cache.CheckLinkMainAndDupNodes(pNodeID, Node.MainCode, pUserID, ResCode);
        if (ResCode=resError) then raise Exception.Create(s);
      end;
      if (pMainCode<>Node.MainCode) then begin // �������� ������� ����
        ResCode:= resAdded;
        s:= Cache.CheckLinkMainAndDupNodes(pNodeID, pMainCode, pUserID, ResCode);
        if (ResCode=resError) then raise Exception.Create(s);
      end;  
    end;
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//======================================================== �������� ���� �� ����
function TAutoTreeNodes.NodeGet(pID: Integer; var pNodeGet: TAutoTreeNode): Boolean;
begin
  Result:= False;
  pNodeGet:= nil;
  if not Assigned(self) then Exit;
  Result:= NodeExists(pID);
  if Result then pNodeGet:= FNodeItems[pID];
end;
//================================================= ��������� ������������� ����
function TAutoTreeNodes.NodeExists(pID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if (Low(FNodeItems)>pID) or (High(FNodeItems)<pID) then Exit;
  Result:= Assigned(FNodeItems[pID]);
end;
//====================== ��������� ������ ������ ���������������� �� ���� ������
procedure TAutoTreeNodes.FillNodesList;
var j: Integer;
  //----------------------------
  procedure GetNodes(pNode: TAutoTreeNode);
  var i: Integer;
  begin
    if pNode.ParentID>-1 then FNodesList.AddObject(pNode.Name, pNode);
    if Assigned(pNode.Children) then
      for i:= 0 to pNode.Children.Count-1 do
        GetNodes(TAutoTreeNode(pNode.Children.Objects[i]));
  end;
  //-----------------------------
begin
  if not Assigned(self) then Exit;
  try
    CS_Nodes.Enter;
    with FNodesList do begin
      FNodesList.Clear;        // ��������� ������ ��������������� ����� �������
      GetNodes(FNodeItems[0]); // � ����������� ���������� ����� �����
      for j:= 0 to Count-1 do TAutoTreeNode(Objects[j]).OrderNum:= j+1;
    end;
  finally
    CS_Nodes.Leave;
  end;
end;
//======================= �������� ������ ������ ���������������� �� ���� ������
function TAutoTreeNodes.NoteGetTree: TStringList; // must Free Result
var j: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  with FNodesList do begin
    if Count<1 then Exit;
    Result.Capacity:= Count;
    for j:= 0 to Count-1 do Result.AddObject(Strings[j], Objects[j]);
  end;
end;
//----- ������ ���������� ���� pNodeID � �������, Object - Pointer TAutoTreeNode
//-------------------------- (ByTDid=True - �� ���� TecDoc, False - �� MainCode)
function TAutoTreeNodes.GetDuplicateNodes(pNodeID: Integer; ByTDid: Boolean=False): TStringList; // must Free Result
var Node: TAutoTreeNode;
    i, index, DupID: Integer;
  //----------------------------
  procedure AddParents; // ��������� �����
  begin
    if Node.ParentID<1 then Exit;
    if not NodeGet(Node.ParentID, Node) then Exit;
    if Result.IndexOfObject(Node)>-1 then Exit;  // ���� ����� �������� ��� ���� - �������
    Result.InsertObject(index, Node.Name, Node); // ��������� ������������ ���� �������
    AddParents;                                  // ���� ������ �����
  end;
  //-----------------------------
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  if not NodeGet(pNodeID, Node) then Exit; // �������� ���� �� ����
  if ByTDid then DupID:= Node.SubCode else DupID:= Node.MainCode; // ��� ������ ���
  with NodesList do for i:= 0 to Count-1 do begin
    Node:= TAutoTreeNode(Objects[i]);   // ���� ������ � ����� �� ����� ������
    if (Node.ID<>pNodeID) and
      ((ByTDid and (Node.SubCode=DupID)) or (not ByTDid and (Node.MainCode=DupID))) then begin
      index:= Result.AddObject(Node.Name, Objects[i]);
      AddParents; // ��������� �����
    end;
  end;
end;
//============= must Free, ������ ����� ����������� ��� ������� ���� pMainNodeID
function TAutoTreeNodes.GetDuplicateNodeCodes(pMainNodeID: Integer; OnlyVisible: Boolean=False): Tai;
var Node: TAutoTreeNode;
    i, index: Integer;
begin
  setlength(Result, 0);
  if not Assigned(self) or not NodeGet(pMainNodeID, Node) then Exit; // �������� ���� �� ����
  if Node.ID<>Node.MainCode then Exit; // ���� �����������
  index:= 0;
  with NodesList do for i:= 0 to Count-1 do begin
    Node:= TAutoTreeNode(Objects[i]);   // ���� ������ � ����� �� ����� ������� ����
    if (Node.MainCode=pMainNodeID) and (Node.ID<>pMainNodeID)
      and (not OnlyVisible or Node.Visible) then begin
      if length(Result)<(index+1) then setlength(Result, index+10);
      Result[index]:= Node.ID;
      inc(index);
    end;
  end;
  if length(Result)>index then setlength(Result, index);
end;
//===================================== �������� ��� ������� ���� �� ���� TecDoc
function TAutoTreeNodes.GetMainNodeIDByTDcode(pTDnr: Integer): Integer;
var i: Integer;
begin
  Result:= -1;
  for i:= 1 to length(FNodeItems)-1 do if NodeExists(i) then
    with FNodeItems[i] do if IsGATD and (SubCode=pTDnr) then begin
      Result:= MainCode;
      exit;
    end;
end;
//============================================ �������� ��� ���� �� ����� TecDoc
function TAutoTreeNodes.GetNodeIDByTDcodes(nodeTD, parTD: Integer; IsGa: Boolean): Integer;
var i, par: Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  for i:= 1 to High(FNodeItems) do begin
    if not NodeExists(i) then Continue;
    if (FNodeItems[i].SubCode<>nodeTD) then Continue; // ���� TecDoc ���������� �� ���� ����
    if IsGa then begin // ������ TecDoc ���������� �� ����� ������ � ����
      par:= FNodeItems[i].ParentID;
      if not NodeExists(par) then Continue;
      if (FNodeItems[par].SubCode<>parTD) then Continue;
    end;
    Result:= FNodeItems[i].ID;
    exit;
  end;
end;

//******************************************************************************
//                          TAutoTreeNodesSys
//******************************************************************************
constructor TAutoTreeNodesSys.Create;
var i, ii, j, jj: Integer;
begin
  SetLength(FarTreeNodes, SysTypes.Count+1);
  for ii:= Low(FarTreeNodes) to High(FarTreeNodes) do FarTreeNodes[ii]:= nil;
  with SysTypes do for i:= 0 to Count-1 do begin
    j:= GetDirItemID(ItemsList[i]);
    if High(FarTreeNodes)<j then begin
      jj:= Length(FarTreeNodes);     // ��������� ����� �������
      SetLength(FarTreeNodes, j+1);  // � ���������� ��������
      for ii:= jj to High(FarTreeNodes) do FarTreeNodes[ii]:= nil;
    end;
    if not Assigned(FarTreeNodes[j]) then FarTreeNodes[j]:= TAutoTreeNodes.Create(j);
  end;
end;
//==============================================================================
destructor TAutoTreeNodesSys.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= Low(FarTreeNodes) to High(FarTreeNodes) do
    if Assigned(FarTreeNodes[i]) then try prFree(FarTreeNodes[i]); except end;
  SetLength(FarTreeNodes, 0);
  inherited Destroy;
end;
//================================== �������� ������ �� ���� �� ���� ��� �������
function TAutoTreeNodesSys.GetTreeNode(pID: Integer): TAutoTreeNode;
var i, j: Integer;
begin
  with SysTypes.ItemsList do for j:= 0 to Count-1 do begin
    i:= TSysItem(Items[j]).ID;
    if CheckTypeSys(i) then if GetTreeNodes(i).NodeGet(pID, Result) then exit;
  end;
  Result:= nil;
end;
//==================================== �������� ������ �� ������ �� ���� �������
function TAutoTreeNodesSys.GetTreeNodes(pSys: Integer): TAutoTreeNodes;
var ii, jj: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if not CheckTypeSys(pSys) then Exit;
  if (High(FarTreeNodes)<pSys) then begin
    jj:= Length(FarTreeNodes);     // ��������� ����� �������
    SetLength(FarTreeNodes, pSys+1);  // � ���������� ��������
    for ii:= jj to High(FarTreeNodes) do FarTreeNodes[ii]:= nil;
  end;
  if not Assigned(FarTreeNodes[pSys]) then
    FarTreeNodes[pSys]:= TAutoTreeNodes.Create(pSys);
  Result:= FarTreeNodes[pSys];
end;

//******************************************************************************
//                        TOriginalNumInfo
//******************************************************************************
constructor TOriginalNumInfo.Create(pID, pMfau: Integer; pNum: String; CS: TCriticalSection=nil);
begin
  pNum:= AnsiUpperCase(fnDelSpcAndSumb(pNum));
  inherited Create(pID, pMfau, 0, pNum, 0);
  FLinks:= TLinks.Create(CS);
end;
//============================================================== �������� ������
function TOriginalNumInfo.GetStrON(const ik: T8InfoKinds): String;
var i, pType: Integer;
    analog: TWareInfo;
    arTypes: Tai;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1 : Result:= FName;
    ik8_2 : if Assigned(Cache.FDCA) then // ��� ������������� ����
              Result:= Cache.FDCA.Manufacturers[FSubCode].Name;
    ik8_3 : if Assigned(Cache.FDCA) then // ������ ��� ���������� �� ������.����
              Result:= fnMakeAddCharStr(ManufName, 100, '0', True)+'*****'+FName;
    ik8_4 : if Assigned(Links) then // ����������� ��� Web � ������ ���� ������
              with Links do try // �������� � Result ������ �� �������� �����
                SetLength(arTypes, 0); // ������ ����� ����� ��� ������ �������
                for i:= 0 to LinkCount-1 do begin     // ���� �� ��������
                  analog:= GetLinkPtr(ListLinks[i]);
                  if analog.IsINFOgr then Continue;   // ���� ����������
                  pType:= analog.TypeID;
                  if (pType<1) then Continue;                         // ��� �� �����
                  if (fnInIntArray(pType, arTypes)>-1) then Continue; // ��� ��� ���
                  Result:= Result+fnIfStr(Result='', '', ' / ')+Cache.GetWareTypeName(pType);
                  prAddItemToIntArray(pType, arTypes);
                end;
                Result:= 'OE'+fnIfStr(Result='', '', ', '+Result); // ��������� 'OE'
              finally
                SetLength(arTypes, 0);
              end; // with Links ... if (LinkCount>0)
  end; // case ik of
end;
//============================================================== �������� ������
procedure TOriginalNumInfo.SetStrON(const ik: T8InfoKinds; Value: String);
var s: String;
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: begin
      s:= AnsiUpperCase(fnDelSpcAndSumb(Value));
      if (FName<>s) then FName:= s;
    end;
  end; // case ik of
end;
//================================================================= �������� ���
function TOriginalNumInfo.GetIntON(const ik: T8InfoKinds): Integer;
var i, pType: Integer;
    analog: TWareInfo;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1 : Result:= FSubCode;                  // ��� ������������� ����
    ik8_2 : if Assigned(Links) then             // ��� ���� �� ��������� �������
              with Links do if (LinkCount>0) then begin
                analog:= GetLinkPtr(ListLinks[0]);
                pType:= analog.TypeID; // ����� ��� �������
                for i:= 1 to LinkCount-1 do begin
                  analog:= GetLinkPtr(ListLinks[i]);
                  if (analog.TypeID<>pType) then Exit; // ����� ������ ��� - �������
                end;
                Result:= pType;
              end; // with Links ... if (LinkCount>0)
  end; // case ik of
end;
//============================================================== �������� ������
procedure TOriginalNumInfo.SetIntON(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if (FSubCode<1) or (FSubCode<>Value) then FSubCode:= Value;
  end; // case ik of
end;
//========================================================= ������ ����� �������
function TOriginalNumInfo.ArAnalogs: Tai;  // must Free
var i: Integer;
    analog: TWareInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  for i:= 0 to Links.LinkCount-1 do begin    // ���� �� ��������
    analog:= GetLinkPtr(Links.ListLinks[i]);
    if analog.IsINFOgr or not analog.IsMarketWare then Continue; // ���� � ��� ��� ����������
    prAddItemToIntArray(analog.ID, Result);
  end;
end;
//================================================== ������ ����� ����� ��������
function TOriginalNumInfo.GetAnalogTypes(WithoutEmpty: Boolean=False): Tai; // must Free
var i, pType: Integer;
    analog: TWareInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not Assigned(Links) or (Links.LinkCount<1) then Exit;
  for i:= 0 to Links.LinkCount-1 do begin    // ���� �� ��������
    analog:= GetLinkPtr(Links.ListLinks[i]);
    if analog.IsINFOgr or not analog.IsMarketWare then Continue; // ���� � ��� ��� ����������
    pType:= analog.TypeID;
    if WithoutEmpty and (pType<1) then Continue;       // ���� ����� ������ ��������� ����
    prAddItemToIntArray(pType, Result);
  end;
end;

//******************************************************************************
//                      TDataCacheAdditionASON
//******************************************************************************
constructor TDataCacheAdditionASON.Create;
begin
  inherited Create;
  CS_OrigNums:= TCriticalSection.Create;
  FManufacturers:= TManufacturers.Create;    // �������������
  FModelLines   := TModelLines.Create;       // ��������� ����
  FModels       := TModelsAuto.Create;       // ������
  SetLength(FarOriginalNumInfo, 0);
  FAutoTreeNodesSys:= TAutoTreeNodesSys.Create;
  FTypesInfoModel  := TTypesInfoModel.Create;
//  FTreeNodes       := TTreeNodes.Create(100);  // ������ �����
  FLinkSources     := TDirItems.Create;        // ���������� ���������� ����������
  FEngines         := TEngines.Create(100);
end;
//==============================================================================
destructor TDataCacheAdditionASON.Destroy;
const nmProc = 'FDCA_Destroy'; // ��� ���������/�������
var i: Integer;
    LocalStart: TDateTime;
begin
  if not Assigned(self) then Exit;
  LocalStart:= now();
  if Length(FarOriginalNumInfo)>0 then
    for i:= Low(FarOriginalNumInfo) to High(FarOriginalNumInfo) do
      if Assigned(arOriginalNumInfo[i]) then try prFree(arOriginalNumInfo[i]); except end;
  SetLength(FarOriginalNumInfo, 0);
  if flTest then begin
    prMessageLOGS(nmProc+'_OrigNums: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  prFree(FManufacturers);
  if flTest then begin
    prMessageLOGS(nmProc+'_Manufs: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  prFree(FModelLines);
  if flTest then begin
    prMessageLOGS(nmProc+'_MLines: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  prFree(FModels);
  if flTest then begin
    prMessageLOGS(nmProc+'_Models: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  prFree(FAutoTreeNodesSys);
  if flTest then begin
    prMessageLOGS(nmProc+'_Nodes: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  prFree(FTypesInfoModel);
//  prFree(FTreeNodes);
  prFree(FLinkSources);
  prFree(FEngines);
  if flTest then prMessageLOGS(nmProc+'_Engines: - '+
                            GetLogTimeStr(LocalStart), fLogDebug, false);
  prFree(CS_OrigNums);
  inherited Destroy;
end;
//============================================== ���������� ���������� � �������
function TDataCacheAdditionASON.GetArLinkSources: Tas; // must Free
var i, j: Integer;
begin
  SetLength(Result, 0);
  with FLinkSources do for i:= 0 to ItemsList.Count-1 do begin
    j:= GetDirItemID(ItemsList[i]);
    if High(Result)<j then SetLength(Result, j+1);
    Result[j]:= GetDirItemName(ItemsList[i]);
  end;
end;
//=============================================== ��� ��������� �� ���� Grossbee
function TDataCacheAdditionASON.GetSourceByGBcode(srcGB: Integer): Integer;
var i, j: Integer;
begin
  Result:= 0;
  with FLinkSources do for i:= 0 to ItemsList.Count-1 do begin
    j:= GetDirItemSubCode(ItemsList[i]);
    if (j=srcGB) then begin
      Result:= GetDirItemID(ItemsList[i]);
      Exit;
    end;
  end;
end;
//======================================================= ��� ��������� Grossbee
function TDataCacheAdditionASON.GetSourceGBcode(src: Integer): Integer;
begin
  Result:= 0;
  with FLinkSources do if ItemExists(src) then Result:= GetDirItemSubCode(DirItems[src]);
end;
//============================================ �������� ������������ ����� � ���
function TDataCacheAdditionASON.AddNewOrigNumToCache(pID, pMfau: Integer; pNum: String; step: Integer=100): TOriginalNumInfo;
var ii, jj: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;

  Result:= TOriginalNumInfo.Create(pID, pMfau, pNum, CS_OrigNums);
  try
    CS_OrigNums.Enter;
    if (High(FarOriginalNumInfo)<pID) then begin
      jj:= Length(FarOriginalNumInfo);        // ��������� ����� �������
      SetLength(FarOriginalNumInfo, pID+step);  // � ���������� ��������
      for ii:= jj to High(FarOriginalNumInfo) do
       if (ii<>pID) then FarOriginalNumInfo[ii]:= nil;
    end;
    FarOriginalNumInfo[pID]:= Result;
  finally
    CS_OrigNums.Leave;
  end;
end;
//=========================================================== ��� ������� ������
function TDataCacheAdditionASON.GetModelTypeSys(pModelID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  try
    Result:= ModelLines[Models[pModelID].ModelLineID].TypeSys;
  except end;
end;
//========================================== �������� / ���������� �� ���� � ���
procedure TDataCacheAdditionASON.FillTypesInfoModel;
const nmProc = 'FillTypesInfoModel';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    pTypeID, pID, pTDkey, pTDkt: Integer;
    pName: String;
begin
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  with TypesInfoModel do try
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
      ORD_IBS.SQL.Text:= 'select * from DIRTYPESINFOMODEL order by DTIMNAME';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        pTypeID:= ORD_IBS.FieldByName('DTIMCODE').AsInteger;  // ��� ������
        pName  := ORD_IBS.FieldByName('DTIMNAME').AsString;   // ������������ ����
        FTypeLists.AddTypeOfList(pTypeID, pName);             // �������� ��� ������
        prCheckLengthIntArray(FTypeTDcodes, pTypeID); // ��������� ����� �������, ���� ����, � ���������� ��������
        FTypeTDcodes[pTypeID]:= ORD_IBS.FieldByName('DTIMTDKEYTAB').AsInteger; // ��� KeyTable TDT
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
      ORD_IBS.Close;

      ORD_IBS.SQL.Text:= 'select * from DIRINFOTYPEMODEL'+
        ' left join DIRTYPESINFOMODEL on DTIMCODE=DITMTYPEDIR'+
        ' order by DITMTYPEDIR, DITMNAME';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        pTypeID:= ORD_IBS.FieldByName('DITMTYPEDIR').AsInteger;  // ��� ������
        pID    := ORD_IBS.FieldByName('DITMCODE').AsInteger;     // ���
        pName  := ORD_IBS.FieldByName('DITMNAME').AsString;      // ������������
        if ORD_IBS.FieldIndex['DITMTDKEYENTR']<0 then pTDkey := 0 else
        pTDkey := ORD_IBS.FieldByName('DITMTDKEYENTR').AsInteger; // ��� TDT
        if ORD_IBS.FieldIndex['DTIMTDKEYTAB']<0 then pTDkt := 0 else
        pTDkt := ORD_IBS.FieldByName('DTIMTDKEYTAB').AsInteger; // ��� TDT

        CheckInfoModelItem(pID, pTypeID, pTDkey, pTDkt, pName);  // ��������� / ��������� �������

        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  TestCssStopException;
end;
//============================ ����������/���������� ���� �������������� �� ����
procedure TDataCacheAdditionASON.FillDirManuf(fFill: Boolean=True);
const nmProc = 'FillDirManuf';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    i, fMFAUCODE, fMFNR, Result: Integer;
    fMFAUNAME, LaxName: String;
    flNew, fLists, fl: boolean;
    iList: TIntegerList;
begin
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  TimeProc:= Now;
  Result:= 0;
  with Manufacturers do try
    ORD_IBD:= cntsOrd.GetFreeCnt;
    fLists:= fFill;
    if not fFill then SetStates(False);
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
      ORD_IBS.SQL.Text:= 'select * from MANUFACTURERAUTO';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        fMFAUCODE:= ORD_IBS.FieldByName('MFAUCODE').AsInteger;
        fMFAUNAME:= ORD_IBS.FieldByName('MFAUNAME').AsString;
        fMFNR    := ORD_IBS.FieldByName('MFAUTDMFNR').AsInteger;
        LaxName  := ORD_IBS.FieldByName('MFAULAXIMONAME').AsString;
        CS_Mfaus.Enter;
        try
          flNew:= True;                          // �������� ������������� ����
          if CheckManufItem(fMFAUCODE, flNew, fMFAUNAME, fMFNR) then  // +100
            with FarManufacturers[fMFAUCODE] do begin
              fLists:= fLists or flNew;
              if flNew then begin
                IsMF    := GetBoolGB(ORD_IBS, 'MFAUISMFAU');      // ������� �������������
                IsMfAUTO:= GetBoolGB(ORD_IBS, 'MFAUISMFAUTO');    // ������� ������������� ����
                IsMfMOTO:= GetBoolGB(ORD_IBS, 'MFAUISMFMOTO');    // ������� ������������� ����
                IsMfTopA:= GetBoolGB(ORD_IBS, 'MFAUISTOPAUTO');   // ������� ���-������������� ����
                IsMfTopM:= GetBoolGB(ORD_IBS, 'MFAUISTOPMOTO');   // ������� ���-������������� ����
                IsMfVisA:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEAUTO'); // ������� ��������� ������������� ����
                IsMfVisM:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEMOTO'); // ������� ��������� ������������� ����
                IsMFCV  := GetBoolGB(ORD_IBS, 'MFAUISMFCV');      // ������� ������������� ����.����
                IsMFAx  := GetBoolGB(ORD_IBS, 'MFAUISMFAX');      // ������� ������������� ����
              end else begin
                if (CompareStr(Name, fMFAUNAME)<>0) then begin
                  fLists:= fLists or True;
                  Name:= fMFAUNAME;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISMFAU');      // ������� �������������
                if fl<>IsMF then begin
                  IsMF:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISMFAUTO');    // ������� ������������� ����
                if fl<>IsMfAUTO then begin
                  IsMfAUTO:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISMFMOTO');    // ������� ������������� ����
                if fl<>IsMfMOTO then begin
                  IsMfMOTO:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISTOPAUTO');   // ������� ���-������������� ����
                if fl<>IsMfTopA then begin
                  IsMfTopA:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISTOPMOTO');   // ������� ���-������������� ����
                if fl<>IsMfTopM then begin
                  IsMfTopM:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEAUTO'); // ������� ��������� ������������� ����
                if fl<>IsMfVisA then begin
                  IsMfVisA:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEMOTO'); // ������� ��������� ������������� ����
                if fl<>IsMfVisM then begin
                  IsMfVisM:= fl;
                  fLists:= fLists or True;
                end;
                if (SubCode<>fMFNR) then FSubCode:= fMFNR;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISMFCV');      // ������� ������������� ����.����
                if (fl<>IsMFCV) then begin
                  IsMFCV:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISMFAX');      // ������� ������������� ����
                if (fl<>IsMFAx) then begin
                  IsMFAx:= fl;
                  fLists:= fLists or True;
                end;
                State:= True;
              end;
{              if flNew then begin
//                IsMFVisCV := GetBoolGB(ORD_IBS, 'MFAUVISIBLECV');  // ������� ��������� ������������� ����.����
//                IsMFTopCV := GetBoolGB(ORD_IBS, 'MFAUISTOPCV');    // ������� ���-������������� ����.����
//                IsMFVisAx := GetBoolGB(ORD_IBS, 'MFAUVISIBLEAX');  // ������� ��������� ������������� ����
//                IsMFTopAx := GetBoolGB(ORD_IBS, 'MFAUISTOPAX');    // ������� ���-������������� ����
//                IsMfEng   := GetBoolGB(ORD_IBS, 'MFAUISMFeng');    // ������� ������������� ����������
//                IsMfVisEng:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEeng'); // ������� ��������� ������������� ����������
//                IsMfTopEng:= GetBoolGB(ORD_IBS, 'MFAUISTOPeng');   // ������� ���-������������� ����������
              end else begin
                fl:= GetBoolGB(ORD_IBS, 'MFAUVISIBLECV');   // ������� ��������� ������������� ����.����
                if (fl<>IsMFVisCV) then begin
                  IsMFVisCV:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISTOPCV');     // ������� ���-������������� ����.����
                if (fl<>IsMFTopCV) then begin
                  IsMFTopCV:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEAX');   // ������� ��������� ������������� ����
                if (fl<>IsMFVisAx) then begin
                  IsMFVisAx:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISTOPAX');      // ������� ���-������������� ����
                if (fl<>IsMFTopAx) then begin
                  IsMFTopAx:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISMFeng');      // ������� ������������� ����������
                if (fl<>IsMfEng) then begin
                  IsMfEng:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUVISIBLEeng');   // ������� ��������� ������������� ����������
                if (fl<>IsMfVisEng) then begin
                  IsMfVisEng:= fl;
                  fLists:= fLists or True;
                end;
                fl:= GetBoolGB(ORD_IBS, 'MFAUISTOPeng');      // ������� ���-������������� ����������
                if (fl<>IsMfTopEng) then begin
                  IsMfTopEng:= fl;
                  fLists:= fLists or True;
                end;
              end; }
            end; // with FarManufacturers[fMFAUCODE]
        finally
          CS_Mfaus.Leave;
        end;

        cntsORD.TestSuspendException;
        ORD_IBS.Next;
        Inc(Result);
      end;
      ORD_IBS.Close;
//------------------------- BrandLaximoList
      ORD_IBS.SQL.Text:= 'select LbmmLaxManuf, LbmmMfau, LmManufName'+
        ' from LaximoManufMfauLink left join LaximoManufs on LmCODE=LbmmLaxManuf'+
        ' order by LbmmLaxManuf';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        fMFNR:= ORD_IBS.FieldByName('LbmmLaxManuf').AsInteger;
        LaxName:= ORD_IBS.FieldByName('LmManufName').AsString;

        if not Cache.BrandLaximoList.Find(LaxName, i) then
          i:= Cache.BrandLaximoList.AddObject(LaxName, TIntegerList.Create);
        iList:= TIntegerList(Cache.BrandLaximoList.Objects[i]);

        while not ORD_IBS.Eof and (fMFNR=ORD_IBS.FieldByName('LbmmLaxManuf').AsInteger) do begin
          fMFAUCODE:= ORD_IBS.FieldByName('LbmmMfau').AsInteger;
          if ManufExists(fMFAUCODE) and FarManufacturers[fMFAUCODE].State then begin
            i:= iList.IndexOf(fMFAUCODE);
            if (i<0) then iList.Add(fMFAUCODE);
          end;
          TestCssStopException;
          ORD_IBS.Next;
        end;
      end;
//------------------------- BrandLaximoList
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    if not fFill then for i:= 1 to High(FarManufacturers) do
      if Assigned(FarManufacturers[i]) and not FarManufacturers[i].State then try
        CS_Mfaus.Enter;
        prFree(FarManufacturers[i]);
        fLists:= True;
      finally
        CS_Mfaus.Leave;
      end;

    fMFAUCODE:= Length(FarManufacturers);
    for i:= High(FarManufacturers) downto 1 do if Assigned(FarManufacturers[i]) then begin
      fMFAUCODE:= FarManufacturers[i].ID+1;
      break;
    end;
    if Length(FarManufacturers)>fMFAUCODE then try
      CS_Mfaus.Enter;
      SetLength(FarManufacturers, fMFAUCODE); // �������� �� ���.����
    finally
      CS_Mfaus.Leave;
    end;

    if fLists then with FSysManufListSort.ListTypes do for i:= 0 to Count-1 do begin
      fMFAUCODE:= integer(Objects[i]); // ��� �������
      FSysManufListSort.SetTypeListDelimiter(fMFAUCODE, LCharUpdate);
      FSysManufListTopUp.SetTypeListDelimiter(fMFAUCODE, LCharUpdate);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prMessageLOGS(nmProc+': '+IntToStr(Result)+' ������. - '+
    GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;
//==================================== ��������/ ���������� ������ �� ���� � ���
procedure TDataCacheAdditionASON.FillDirModelLines(fFill: Boolean=True);
const nmProc = 'FillDirModelLines';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    Code, MFAUID, pTypeSys, pMStart, pYStart, pMEnd, pYEnd, i, Result, pMLTD, ii, jj: Integer;
    pName: String;
    Tops, Visi, flNew, flLists: Boolean;
    manuf: TManufacturer;
begin
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  TimeProc:= Now;
  Result:= 0;
  with ModelLines do try
    if not fFill then SetStates(False);
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
      ORD_IBS.SQL.Text:= 'select * from DIRMODELLINES'+
        ' order by DRMLMFAUCODE, DRMLDTSYCODE';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        MFAUID:= ORD_IBS.FieldByName('DRMLMFAUCODE').AsInteger;   // ��� �������������
        if not ManufAutoExist(MFAUID) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and
            (MFAUID=ORD_IBS.FieldByName('DRMLMFAUCODE').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        pTypeSys:= ORD_IBS.FieldByName('DRMLDTSYCode').AsInteger;   // ��� �������
        if not CheckTypeSys(pTypeSys) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (MFAUID=ORD_IBS.FieldByName('DRMLMFAUCODE').AsInteger)
            and (pTypeSys=ORD_IBS.FieldByName('DRMLDTSYCode').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        manuf:= Manufacturers[MFAUID];
        flLists:= False; // ������� ���������������� �������
        while not ORD_IBS.Eof and (MFAUID=ORD_IBS.FieldByName('DRMLMFAUCODE').AsInteger)
          and (pTypeSys=ORD_IBS.FieldByName('DRMLDTSYCode').AsInteger) do begin
          Visi:= GetBoolGB(ORD_IBS, 'DRMLISVISIBLE');             // ������� ��������� ���������� ����

          if not (Cache.AllowWebArm or Visi) then begin // ����� WebArm ��������� ������ �������
            ORD_IBS.Next;
            Continue;
          end;

          Code   := ORD_IBS.FieldByName('DRMLCode').AsInteger;       // ��� ���������� ����
          pName  := ORD_IBS.FieldByName('DRMLName').AsString;        // ������������ ���������� ����
          pMStart:= ORD_IBS.FieldByName('DRMLMonthStart').AsInteger; // ����� ������ ������������
          pYStart:= ORD_IBS.FieldByName('DRMLYearStart').AsInteger;  // ��� ������ ������������
          pMEnd  := ORD_IBS.FieldByName('DRMLMonthEnd').AsInteger;   // ����� ��������� ������������
          pYEnd  := ORD_IBS.FieldByName('DRMLYearEnd').AsInteger;    // ��� ��������� ������������
          Tops   := GetBoolGB(ORD_IBS, 'DRMLISTOP');                 // ���
          pMLTD  := ORD_IBS.FieldByName('DRMLTDCODE').AsInteger;     // ��� TecDoc

          flNew:= not ModelLineExists(Code);
          CS_MLines.Enter;
          try
            if flNew then begin
              if High(FarModelLines)<Code then begin
                jj:= Length(FarModelLines);            // ��������� ����� �������
                SetLength(FarModelLines, Code+1000);   // � ���������� ��������
                for ii:= jj to High(FarModelLines) do
                 if ii<>Code then FarModelLines[ii]:= nil;
              end;
              FarModelLines[Code]:= TModelLine.Create(Code, pMLTD, MFAUID, pName);
            end;
            with FarModelLines[Code] do if flNew then begin
              FTypeSys := pTypeSys;
              FMStart  := pMStart;
              FYStart  := pYStart;
              FMEnd    := pMEnd;
              FYEnd    := pYEnd;
              IsTop    := Tops;
              IsVisible:= Visi;
              flLists  := True;
            end else begin
              flLists:= flLists or (Name<>pName) or (FMStart<>pMStart) or (FYStart<>pYStart);
              Name:= pName;
              if FMStart<>pMStart then begin
                FMStart:= pMStart;
                flLists:= True;
              end;
              if FYStart<>pYStart then begin
                FYStart:= pYStart;
                flLists:= True;
              end;
              if IsVisible<>Visi then begin
                IsVisible:= Visi;
                flLists:= True;
              end;
              if IsTop<>Tops then begin
                IsTop:= Tops;
                flLists:= True;
              end;
              if MFAID      <> MFAUID   then MFAID     := MFAUID;
              if FTypeSys   <> pTypeSys then FTypeSys  := pTypeSys;
              if FMEnd      <> pMEnd    then FMEnd     := pMEnd;
              if FYEnd      <> pYEnd    then FYEnd     := pYEnd;
              if FSubCode   <> pMLTD    then FSubCode  := pMLTD;
              State:= True; // ������������� ������ ��������
            end;
          finally
            CS_MLines.Leave;
          end;
          Inc(Result);
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
        end;

        if flLists then with manuf do begin
          FManufSysMLsSort.SetTypeListDelimiter(pTypeSys, LCharUpdate);
          FManufSysMLsTopUp.SetTypeListDelimiter(pTypeSys, LCharUpdate);
        end;
      end;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    if not fFill then for i:= 1 to High(FarModelLines) do // ������� ���������
      if Assigned(FarModelLines[i]) and not FarModelLines[i].State then try
        MFAUID:= FarModelLines[i].MFAID;
        pTypeSys:= FarModelLines[i].FTypeSys;
        Code:= FarModelLines[i].FID;
        if Cache.FDCA.ManufAutoExist(MFAUID) and CheckTypeSys(pTypeSys) then
          with Cache.FDCA.Manufacturers[MFAUID] do begin
            if FManufSysMLsSort[pTypeSys].Delimiter=LCharGood then  // ���� ������ ��� ���������
              FManufSysMLsSort.DelTypeListItem(pTypeSys, Code);
            if FManufSysMLsTopUp[pTypeSys].Delimiter=LCharGood then
              FManufSysMLsTopUp.DelTypeListItem(pTypeSys, Code);
          end;
        CS_MLines.Enter;
        try
          prFree(FarModelLines[i]);
        finally
          CS_MLines.Leave;
        end;
      except end;

    Code:= Length(FarModelLines);
    for i:= High(FarModelLines) downto 1 do if Assigned(FarModelLines[i]) then begin
      Code:= FarModelLines[i].ID+1;
      break;
    end;
    if Length(FarModelLines)>Code then try
      CS_MLines.Enter;
      SetLength(FarModelLines, Code); // �������� �� ���.����
    finally
      CS_MLines.Leave;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prMessageLOGS(nmProc+': '+IntToStr(Result)+' ���.����� - '+
    GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;
//======== ���������� TList ������ ������� - ��������� + ������.� + ������������
function ModelsLinksSortCompare(Item1, Item2: Pointer): Integer;
var i1, i2: Integer;
    Model1, Model2: TModelAuto;
begin
  try
    Model1:= GetLinkPtr(Item1);
    Model2:= GetLinkPtr(Item2);
    if (Model1.IsVisible=Model2.IsVisible) then begin
      i1:= Model1.ModelOrderNum;
      i2:= Model2.ModelOrderNum;
      if i1=i2 then Result:= AnsiCompareText(Model1.SortName, Model2.SortName)
      else if i1<i2 then Result:= -1 else Result:= 1;
    end else if Model1.IsVisible then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;
//======================== �������� / ���������� ������ ���������� �� ���� � ���
procedure TDataCacheAdditionASON.FillDirEngines(fFill: Boolean=True);
const nmProc = 'FillDirEngines';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    j, engID, mfID: Integer;
    eps: TEngParams;
    eng: TEngine;
    flMfWares, fl: Boolean;
begin
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  TimeProc:= Now;
  eps:= TEngParams.Create;
  j:= 0;
  with Engines do try
    if not fFill then SetDirStates(False); // ���������� ������ �������� ����������
    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
    ORD_IBS.SQL.Text:= 'select e.*,'+
      ' iif(exists(select * from LINKENGINENODE where LENDENGCODE=e.DENGCODE), 1, 0) hasNodes,'+
      ' iif(exists(select * from LINKENGINENODE inner join LINKENGNODEWARE on LENWLENCODE=LENCODE'+
      '   where LENDENGCODE=e.DENGCODE), 1, 0) hasWares'+
      ' from (select * from DIRENGINES order by DENGMFAU) e';
    ORD_IBS.ExecQuery;
    if not fFill then Engines.SetDirStates(False);
    while not ORD_IBS.Eof do begin
      mfID:= ORD_IBS.FieldByName('DENGMFAU').AsInteger;
      flMfWares:= False;
      if not Cache.FDCA.ManufAutoExist(mfID) then begin
        TestCssStopException;
        while not ORD_IBS.Eof and (mfID=ORD_IBS.FieldByName('DENGMFAU').AsInteger) do ORD_IBS.Next;
        Continue;
      end;

      while not ORD_IBS.Eof and (mfID=ORD_IBS.FieldByName('DENGMFAU').AsInteger) do begin
        engID:= ORD_IBS.FieldByName('DENGCODE').AsInteger;
        eng:= TEngine.Create(engID, ORD_IBS.FieldByName('DENGTDCODE').AsInteger,
          mfID, ORD_IBS.FieldByName('DENGENGINEMARK').AsString);
        if CheckItem(Pointer(eng)) then begin
          with eps do begin
            pYearFrom   := ORD_IBS.FieldByName('DENGMODFR').AsInteger div 100; // ��� ������� ��
            pMonFrom    := ORD_IBS.FieldByName('DENGMODFR').AsInteger mod 100; // ����� ������� ��
            pYearTo     := ORD_IBS.FieldByName('DENGMODTO').AsInteger div 100; // ��� ������� ��
            pMonTo      := ORD_IBS.FieldByName('DENGMODTO').AsInteger mod 100; // ����� ������� ��
            pCompFrom   := ORD_IBS.FieldByName('DENGCOMPFR').AsInteger;        // ���������� * 100 ��
            pCompTo     := ORD_IBS.FieldByName('DENGCOMPTO').AsInteger;        // ���������� * 100 ��
            pRPMtorqFrom:= ORD_IBS.FieldByName('DENGRPMTORQFR').AsInteger;     // ������ �������� (Nm) ��� [��/���] ��
            pRPMtorqTo  := ORD_IBS.FieldByName('DENGRPMTORQTO').AsInteger;     // ������ �������� (Nm) ��� [��/���] ��
            pBore       := ORD_IBS.FieldByName('DENGBORE').AsInteger;          // �������� * 1000
            pStroke     := ORD_IBS.FieldByName('DENGSTROKE').AsInteger;        // ��� ������ * 1000
            pKWfrom     := ORD_IBS.FieldByName('DENGKWFR').AsInteger;          // �������� ��� ��
            pRPMKWfrom  := ORD_IBS.FieldByName('DENGRPMKWFR').AsInteger;       // ��� [��/���] ��
            pKWto       := ORD_IBS.FieldByName('DENGKWTO').AsInteger;          // �������� ��� ��
            pRPMKWto    := ORD_IBS.FieldByName('DENGRPMKWTO').AsInteger;       // ��� [��/���] ��
            pHPfrom     := ORD_IBS.FieldByName('DENGHPFR').AsInteger;          // �������� �� ��
            pHPto       := ORD_IBS.FieldByName('DENGHPTO').AsInteger;          // �������� �� ��
            pCCtecFrom  := ORD_IBS.FieldByName('DENGCCTECFR').AsInteger;       // ���.����� � ���.��. ��
            pCCtecTo    := ORD_IBS.FieldByName('DENGCCTECTO').AsInteger;       // ���.����� � ���.��. ��
            pVal        := ORD_IBS.FieldByName('DENGVAL').AsInteger;           // ���������� ��������
            pCyl        := ORD_IBS.FieldByName('DENGCYL').AsInteger;           // ���������� ���������
            pCrank      := ORD_IBS.FieldByName('DENGCRANK').AsInteger;         // ���-�� ����������� ���������
            pDesign     := ORD_IBS.FieldByName('DENGDESIGN').AsInteger;        // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
            pFuelType   := ORD_IBS.FieldByName('DENGFUELTYPE').AsInteger;      // ���, ��� �������            (KT 88) (TYPEDIR=12)
            pFuelMixt   := ORD_IBS.FieldByName('DENGFUELMIXT').AsInteger;      // ���, ������� �������        (KT 97) (TYPEDIR=5)
            pAspir      := ORD_IBS.FieldByName('DENGASPIR').AsInteger;         // ���, ������ �������         (KT 99) (TYPEDIR=14)
            pType       := ORD_IBS.FieldByName('DENGTYPE').AsInteger;          // ���, ��� ���������          (KT 80) (TYPEDIR=3)
            pNorm       := ORD_IBS.FieldByName('DENGNORM').AsInteger;          // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
            pCylDesign  := ORD_IBS.FieldByName('DENGCYLDESIGN').AsInteger;     // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
            pManag      := ORD_IBS.FieldByName('DENGMANAG').AsInteger;         // ���, ������ �����������     (KT 77) (TYPEDIR=17)
            pValCnt     := ORD_IBS.FieldByName('DENGVALCNT').AsInteger;        // ���, ������ �������         (KT 78) (TYPEDIR=18)
            pCoolType   := ORD_IBS.FieldByName('DENGCOOLTYPE').AsInteger;      // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
            pSalesDesc  := ORD_IBS.FieldByName('DENGSALESDESC').AsString;      // ����������� �������
          end;
          eng:= DirItems[engID];
          eng.SetParams(eps, fFill);
          fl:= (ORD_IBS.FieldByName('hasNodes').AsInteger=1);
          if eng.EngHasNodes<>fl then eng.EngHasNodes:= fl;
          fl:= (ORD_IBS.FieldByName('hasWares').AsInteger=1);
          if (eng.EngHasWares<>fl) then eng.EngHasWares:= fl;
          if eng.EngHasWares and not flMfWares then flMfWares:= True;
          fl:= GetBoolGB(ORD_IBS, 'DengByAuto');
          if (eng.EngByAuto<>fl) then eng.EngByAuto:= fl;
          fl:= GetBoolGB(ORD_IBS, 'DengByCV');
          if (eng.EngByCV<>fl) then eng.EngByCV:= fl;
          inc(j);
        end;
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
      with Cache.FDCA.Manufacturers[mfID] do begin
        if (MfHasEngWares<>flMfWares) then MfHasEngWares:= flMfWares;
        if MfHasEngWares and not IsMfEng then IsMfEng:= true;
      end;
    end;
    ORD_IBS.Close;
    if not fFill then DelDirNotTested;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  prFree(eps);
  prMessageLOGS(nmProc+': '+IntToStr(j)+' ���������� - '+
    GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;
//=========================== �������� / ���������� ������ ������� �� ���� � ���
procedure TDataCacheAdditionASON.FillDirModels(fFill: Boolean=True);
const nmProc = 'FillDirModels';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    pName, sCV, sAx: String;      // ������������ ������
    Code, ModelLineID, OrdNum, Result, pModelTDcode, ii, jj: Integer;
    Vis, Top, fadd, fmlupd, flmlhas, flHasWares, flHasPLs: Boolean;
    mps: TModelParams;
    armf: TBooleanDynArray;
    model: TModelAuto;
begin
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  TimeProc:= Now;
  mps:= TModelParams.Create;
  Result:= 0;
  SetLength(armf, Length(Manufacturers.FarManufacturers));
  with Models do try
    if not fFill then SetStates(False); // ���������� ������ �������� �������
    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
    sCV:= IntToStr(constIsCV);
    sAx:= IntToStr(constIsAx);
    ORD_IBS.SQL.Text:= 'select m.*, iif(exists(select * from LINKDETAILMODEL'+
      ' inner join LINKDETMODWARE on LDMWLDEMCODE=LDEMCODE and LDMWWRONG="F"'+
      ' inner join WareOptions on wowarecode=ldmwwarecode'+
      ' where LDEMDMOSCODE=m.DMOSCODE and LDEMWRONG="F" and WOARHIVED="F"), 1, 0) hasWares,'+
      ' iif(exists(select * from LINKMODELNode_motul'+
      '  inner join LINKMODNodePL_motul on lmnpmlmnm=lmnmoCODE'+
      '  inner join PrLiOPTIONS on lploPrLine=lmnpmPrLi'+
      '  where lmnmoDMOS=m.DMOSCODE and lploARHIVED="F"), 1, 0) HasPLs,'+

fnIfStr(flmyDebug, ' "" KWfrto, "" HPfrto, "" sect, "" Wheel, "" ids, "" cabs, "" Susp, "" cvAxles', // ��� ��������� ��������

      ' (case when DRMLDTSYCODE='+sCV+' then (select first 1 a1.DMOSaText from DIRMODELS_add a1'+
      '   where a1.DMOSaDmos=m.DMOSCODE and a1.DMOSaDTIM='+IntToStr(cvtKW)+')'+
      '  when DRMLDTSYCODE='+sAx+' then (select first 1 a1.DMOSaText from DIRMODELS_add a1'+
      '   where a1.DMOSaDmos=m.DMOSCODE and a1.DMOSaDTIM='+IntToStr(axtDist)+') else "" end) KWfrto,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select first 1 a2.DMOSaText from DIRMODELS_add a2'+
      '   where a2.DMOSaDmos=m.DMOSCODE and a2.DMOSaDTIM='+IntToStr(cvtHP)+')'+
      '  when DRMLDTSYCODE='+sAx+' then (select first 1 a2.DMOSaText from DIRMODELS_add a2'+
      '   where a2.DMOSaDmos=m.DMOSCODE and a2.DMOSaDTIM='+IntToStr(axtLoad)+') else "" end) HPfrto,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select list(a3.DMOSaText) from DIRMODELS_add a3'+
      '   where a3.DMOSaDmos=m.DMOSCODE and a3.DMOSaDTIM='+IntToStr(cvtSecTyp)+') else "" end) sect,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select list(a4.DMOSaText) from DIRMODELS_add a4'+
      '   where a4.DMOSaDmos=m.DMOSCODE and a4.DMOSaDTIM='+IntToStr(cvtWheel)+') else "" end) Wheel,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select list(a4.DMOSaText) from DIRMODELS_add a4'+
      '   where a4.DMOSaDmos=m.DMOSCODE and a4.DMOSaDTIM='+IntToStr(cvtIDs)+')'+
      '  when DRMLDTSYCODE='+sAx+' then (select list(a4.DMOSaText) from DIRMODELS_add a4'+
      '   where a4.DMOSaDmos=m.DMOSCODE and a4.DMOSaDTIM='+IntToStr(axtBoType)+') else "" end) ids,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select list(a5.DMOSaText) from DIRMODELS_add a5'+
      '   where a5.DMOSaDmos=m.DMOSCODE and a5.DMOSaDTIM='+IntToStr(cvtCabs)+') else "" end) cabs,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select list(a6.DMOSaText) from DIRMODELS_add a6'+
      '   where a6.DMOSaDmos=m.DMOSCODE and a6.DMOSaDTIM='+IntToStr(cvtSusp)+')'+
      '  when DRMLDTSYCODE='+sAx+' then (select first 1 a6.DMOSaText from DIRMODELS_add a6'+
      '   where a6.DMOSaDmos=m.DMOSCODE and a6.DMOSaDTIM='+IntToStr(axtBrSize)+') else "" end) Susp,'+
      ' (case when DRMLDTSYCODE='+sCV+' then (select list(lcaAxPos||"/"||lcaDmosAx)'+
      '   from LINKCVAxles where lcaDmosCV=m.DMOSCODE and lcaWRONG="F") else "" end) cvAxles'
)
      +
      ' from DIRMODELS m left join DIRMODELLINES on DRMLCODE=DMOSDRMLCODE order by DMOSDRMLCODE';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      ModelLineID:= ORD_IBS.FieldByName('DMOSDRMLCODE').AsInteger; // ��� ���������� ����
      if not ModelLines.ModelLineExists(ModelLineID) then begin
        TestCssStopException;
        while not ORD_IBS.Eof and
          (ModelLineID=ORD_IBS.FieldByName('DMOSDRMLCODE').AsInteger) do ORD_IBS.Next;
        Continue;
      end;

      fmlupd:= False;
      flmlhas:= False;
      while not ORD_IBS.Eof and (ModelLineID=ORD_IBS.FieldByName('DMOSDRMLCODE').AsInteger) do begin
        Vis           := GetBoolGB(ORD_IBS, 'DMOSISVISIBLE');      // ��������� ������

        if not (Cache.AllowWebArm or Vis) then begin // ����� WebArm ��������� ������ �������
          ORD_IBS.Next;
          Continue;
        end;

        Code           := ORD_IBS.FieldByName('DMOSCODE').AsInteger;           // ��� ������
        pName          := ORD_IBS.FieldByName('DMOSNAME').AsString;            // ������������ ������
        Top            := GetBoolGB(ORD_IBS, 'DMOSISTOP');                     // ��� ������
        pModelTDcode   := ORD_IBS.FieldByName('DMOSTDCODE').AsInteger;         // ��� TecDoc
        mps.pMStart    := ORD_IBS.FieldByName('DMOSMONTHSTART').AsInteger;     // ����� ������ �������
        mps.pYStart    := ORD_IBS.FieldByName('DMOSYEARSTART').AsInteger;      // ��� ������ �������
        mps.pMEnd      := ORD_IBS.FieldByName('DMOSMONTHEND').AsInteger;       // ����� ����� �������
        mps.pYEnd      := ORD_IBS.FieldByName('DMOSYEAREND').AsInteger;        // ��� ����� �������
        mps.pKW        := ORD_IBS.FieldByName('DMOSKW').AsInteger;             // �������� ���.
        mps.pHP        := ORD_IBS.FieldByName('DMOSHP').AsInteger;             // �������� ��
        mps.pCCM       := ORD_IBS.FieldByName('DMOSCCM').AsInteger;            // ���. ����� ���. ��.
        mps.pCylinders := ORD_IBS.FieldByName('DMOSCYLINDERS').AsInteger;      // ���. ���������
        mps.pValves    := ORD_IBS.FieldByName('DMOSVALVES').AsInteger;         // ���. �������� �� ���� ������ ��������
        mps.pBodyID    := ORD_IBS.FieldByName('DMOSBODYCODE').AsInteger;       // ��� ������
        mps.pDriveID   := ORD_IBS.FieldByName('DMOSDRIVECODE').AsInteger;      // ��� �������
        mps.pEngTypeID := ORD_IBS.FieldByName('DMOSENGINETYPECODE').AsInteger; // ��� ���������
        mps.pFuelID    := ORD_IBS.FieldByName('DMOSFUELCODE').AsInteger;       // ��� �������
        mps.pFuelSupID := ORD_IBS.FieldByName('DMOSFUELSUPCODE').AsInteger;    // ������� �������
        mps.pBrakeID   := ORD_IBS.FieldByName('DMOSBRAKECODE').AsInteger;      // ��� ��������� �������
        mps.pBrakeSysID:= ORD_IBS.FieldByName('DMOSBRAKESYSCODE').AsInteger;   // ��������� �������
        mps.pCatalID   := ORD_IBS.FieldByName('DMOSCATALCODE').AsInteger;      // ��� ������������
        mps.pTransID   := ORD_IBS.FieldByName('DMOSTRANSCODE').AsInteger;      // ��� ������� �������
        OrdNum         := ORD_IBS.FieldByName('DMOSORDERNUM').AsInteger;       // ������.� ������
        flHasWares     := (ORD_IBS.FieldByName('hasWares').AsInteger=1);       // ������� ������� ������ � ��������
        flHasPLs       := (ORD_IBS.FieldByName('HasPLs').AsInteger=1);         // ������� ������� ������ � ����.���������
        mps.cvKWaxDI   := ORD_IBS.FieldByName('KWfrto').AsString;              // CV - �������� [���], AX - ��������� [��]
        mps.cvHPaxLO   := ORD_IBS.FieldByName('HPfrto').AsString;              // CV - �������� [��] , AX - �������� �� ��� [��]
        mps.cvSecTypes := ORD_IBS.FieldByName('sect').AsString;                // CV - �������������� ���
        mps.cvWheels   := ORD_IBS.FieldByName('Wheel').AsString;               // CV - �������� ���� [���.����]/[��]
        mps.cvIDaxBT   := ORD_IBS.FieldByName('ids').AsString;                 // CV - ID �������������,  AX - ��� ������
        mps.cvCabs     := ORD_IBS.FieldByName('cabs').AsString;                // CV - ������
        mps.cvSUAxBR   := ORD_IBS.FieldByName('Susp').AsString;                // CV - ��������/����������� (������ ����� TYPEDIR=cvtSusp)
                                                                               //   AX - ������� �������    (������ ����� TYPEDIR=axtBrSize)
        mps.cvAxles    := ORD_IBS.FieldByName('cvAxles').AsString;             // CV - ��� [���.���]/[���]  (������: ��� TYPEDIR=cvtAxPos/��� ���)

        fadd:= not ModelExists(Code);
        CS_Models.Enter;
        try
          if fadd then begin
            if High(FarModels)<Code then begin
              jj:= Length(FarModels);            // ��������� ����� �������
              SetLength(FarModels, Code+1000);   // � ���������� ��������
              for ii:= jj to High(FarModels) do
               if ii<>Code then FarModels[ii]:= nil;
            end;
            model:= TModelAuto.Create(Code, pModelTDcode, OrdNum, ModelLineID, pName);
            FarModels[Code]:= model;
          end else model:= FarModels[Code];

          if fadd then begin
            model.FNodeLinks.dirNodes:= Cache.FDCA.AutoTreeNodesSys[model.TypeSys];
            model.IsVisible:= Vis;
            model.IsTop    := Top;
            fmlupd:= True;
          end else begin
            if CompareStr(model.Name, pName)<>0 then begin
              model.Name:= pName;
              fmlupd:= True;
            end;
            if (model.ModelOrderNum<>OrdNum) then begin
              model.ModelOrderNum:= OrdNum;
              fmlupd:= True;
            end;
            if (model.IsVisible<>Vis) then begin
              model.IsVisible:= Vis;
              fmlupd:= True;
            end;
            if (model.IsTop<>Vis) then begin
              model.IsTop:= Top;
              fmlupd:= Top;
            end;
            fmlupd:= fmlupd or (model.FParams.pMStart<>mps.pMStart) or (model.FParams.pYStart<>mps.pYStart);
            if (model.FSubCode<>pModelTDcode) then model.FSubCode:= pModelTDcode; // ��� TecDoc
          end;
          model.SetModelParams(mps, fadd);
          model.ModelHasWares:= flHasWares;         // ������� ������� ������� ������
          model.ModelHasPLs:= flHasPLs;             // ������� ������� ����.������
          flmlhas:= flmlhas or model.ModelHasWares; // ������� ������� ������� ���.����
          model.State:= True;
        finally
          CS_Models.Leave;
        end;
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
        Inc(Result);
      end;

      with ModelLines[ModelLineID] do begin
        if not MLHasWares and flmlhas then MLHasWares:= flmlhas;  // ������� ������� ������� ���������� ����
        if MLHasWares then armf[MFAID]:= True;
        if fFill or fmlupd then FMLModelsSort.Delimiter:= lCharUpdate; // ����������� ������ ���������� ����
      end;
    end;
    ORD_IBS.Close;

    for Code:= 1 to High(armf) do // �������� ������� ������� �� ������.
      if Manufacturers.ManufExists(Code) and armf[Code] then
        Manufacturers[Code].ManufHasWares:= True;

    if not fFill then for Code:= 1 to High(FarModels) do  // ������� �������������
      if ModelExists(Code) and not FarModels[Code].State then begin
         with ModelLines.GetModelLine(FarModels[Code].ModelLineID) do
           if FMLModelsSort.Delimiter=lCharGood then ModelDelFromLine(Code); // ������� �� ������� ���������� ����
        CS_Models.Enter;
         try
          FarModels[Code].ClearLinks;
          prFree(FarModels[Code]);
        finally
          CS_Models.Leave;
        end;
      end;
    Code:= Length(FarModels);
    for OrdNum:= High(FarModels) downto 1 do if Assigned(FarModels[OrdNum]) then begin
      Code:= FarModels[OrdNum].ID+1;
      break;
    end;
    if Length(FarModels)>Code then try
      CS_Models.Enter;
      SetLength(FarModels, Code); // �������� �� ���.����
    finally
      CS_Models.Leave;
    end;
                                     //------------------- ���������� ����������
    ORD_IBS.SQL.Text:= 'select LMENDMOSCODE, LMENDENGCODE'+
      ' from LINKMODELSENGINES where LMENWRONG="F" order by LMENDMOSCODE';
    ORD_IBS.ExecQuery;         // ��������� / ��������� ������ ���������� ������
    while not ORD_IBS.Eof do begin
      Code:= ORD_IBS.FieldByName('LMENDMOSCODE').AsInteger; 
      if not ModelExists(Code) then begin
        TestCssStopException;
        while not ORD_IBS.Eof and (Code=ORD_IBS.FieldByName('LMENDMOSCODE').AsInteger) do ORD_IBS.Next;
        Continue;
      end;
      with FarModels[Code].EngLinks do begin
        if not fFill then SetLinkStates(False);
        while not ORD_IBS.Eof and (Code=ORD_IBS.FieldByName('LMENDMOSCODE').AsInteger) do begin
          ModelLineID:= ORD_IBS.FieldByName('LMENDENGCODE').AsInteger;   // ��� ORD
          if Engines.ItemExists(ModelLineID) then
            CheckLink(ModelLineID, 0, Engines[ModelLineID]);
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
        end;
        if not fFill then DelNotTestedLinks;
        SortByLinkName;
      end;
    end;
    ORD_IBS.Close;
//    for OrdNum:= High(FarModels) downto 1 do if Assigned(FarModels[OrdNum]) then
//      prMessageLOGS(nmProc+': ��� ������ '+IntToStr(OrdNum)+
//        ' -  ����. '+FarModels[OrdNum].MarksCommaText, fLogDebug, false);    // �������
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD, True);
  SetLength(armf, 0);
  prFree(mps);
  prMessageLOGS(nmProc+': '+IntToStr(Result)+' ������� - '+
    GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;

//======== ���������� ������� ������� ������� ������ �� ���� � ������������ ����
procedure SetHasWaresModelNodeParentLinks(Model: TModelAuto; NodeID: Integer; fHas: Boolean=True);
var link: TSecondLink;
    Node: TAutoTreeNode;
    i, j, ci, ii: Integer;
    codes: Tai;
    fbreak: Boolean;
    mlinks: TNodeLinks;
begin
  setLength(codes, 0);
  try
    i:= Model.TypeSys;
    with Cache.FDCA.AutoTreeNodesSys[i] do begin
      if not NodeGet(NodeID, Node) then Exit;
      j:= Node.MainCode; // ��� ������� ����
      codes:= GetDuplicateNodeCodes(j, True); // ���� ������� ����������� ���
      prAddItemToIntArray(j, codes);    // ��������� ��� ������� ����
    end;
    mlinks:= Model.NodeLinks;
    for ii:= High(codes) downto 0 do begin        // ���� �� ����� ���, ������� � �������
      nodeID:= codes[ii];
      link:= mlinks[nodeID];                      // ������ � ����� - ������ 2
      if not Assigned(link) then Continue;

      if (link.NodeHasWares=fHas) then Continue; // ���� ������� ���, ��� ����

      link.NodeHasWares:= fHas;                   // ������ ������ ������� ������� �������
      Node:= GetLinkPtr(link);                    // ������ �� ����
      if not Assigned(Node) then Continue;

      if fHas and not Node.Visible then fHas:= False; // �� ��������� ��������� ��� ������� True �� �����������

      repeat  // ������������ ��������� �������� ����� �� ������
        i:= Node.ParentID;
        link:= mlinks[i];                         // ������ � ����� ��������
        if not Assigned(link) then break;
        if link.NodeHasWares=fHas then break;     // ���� ������� ������� ������� ������ - ������ ����� �� ������ �� ����
        Node:= GetLinkPtr(link);                  // ������ �� ���� ��������
        if not Assigned(Node) then break;

        if not fHas and Assigned(Node.Children) then // ���� ����� �������
          with Node.Children do begin                // ��������� ����� ������������ ����
            fbreak:= False;                          // ���� ��� ������ �� 2-� ������
            for j:= 0 to Count-1 do begin
              ci:= TAutoTreeNode(Objects[j]).ID;     // ��� ������
              fbreak:= mlinks.LinkExists(ci) and     // ���� ���� ���� �� ���� � ������ ��������� - �������
                (TSecondLink(mlinks[ci]).NodeHasWares<>fHas);
              if fbreak then break;                  // ������� �� for
            end;
            if fbreak then break;                    // ������� �� repeat
          end; // with Node.Children

        link.NodeHasWares:= fHas; // ������ ������ ������� ������� ������� ����� �� ���� ��������
      until i<0;
    end; // for ii:= High(codes) downto 0
  finally
    setLength(codes, 0);
  end;
end;
//========================= �������� / ���������� ������ ������� � ������� �����
procedure TDataCacheAdditionASON.FillModelNodeLinks;
const nmProc = 'FillModelNodeLinks';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    lstLinks: TList;       // ������ ������ ��� ��������� ����������
    pTypeSys, tnID, index, j, Result, iCount, pModelID, err1, err2: Integer;
    pNode: TAutoTreeNode;
    Model: TModelAuto;
    haswares, hasFilters, flMfDebug, flSleep, hasMotul: Boolean;
    link2: TSecondLink;
    sDebugManufs: String;
  //---------------------- ��������� ��������� / ����������� ������� � ���������
  procedure AddParentLink(idp: Integer; hasw, hasM: Boolean);
  begin
    if (idp<1) then Exit; // ���� ���� ��� � ������ - �������
    index:= -1;
    if FAutoTreeNodesSys[pTypeSys].NodeGet(idp, pNode) then index:= pNode.OrderNum-1;
    if (index<0) then Exit;
    if not assigned(lstLinks[index]) then  // ���� ����� �� ���� ��� � ������ - ���������
      lstLinks[index]:= TSecondLink.Create(0, 0, pNode, False, hasw, false, hasM)
    else begin
      link2:= lstLinks[index];             // ���� �������� ��� ���� - �������
      if (hasw=link2.NodeHasWares) and (hasM=link2.NodeHasPLs) then Exit;
      if (hasw and not link2.NodeHasWares) then link2.NodeHasWares:= hasw;
      if (hasM and not link2.NodeHasPLs) then link2.NodeHasPLs:= hasM;
    end;
    AddParentLink(pNode.ParentID, hasw, hasM); // ��������� ��������� / ����������� ������� � ���������
  end;
  //----------------------------------
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  SleepFillLinksInt:= GetIniParamInt(nmIniFileBOB, 'intervals', 'SleepFillLinksInt', 10); // �������� �������� ���������� ������
  flSleep:= not flDebug and (SleepFillLinksInt>0) and fnGetActionTimeEnable(caeOnlyWorkTime);
  ORD_IBS:= nil;
  TimeProc:= Now;
  pNode:= nil;
  lstLinks:= TList.Create; // ������ ������ ��� ������
  err1:= 0;
  err2:= 0;
//  HasMotul:= False;
  if Cache.WebAutoLinks then begin
    sDebugManufs:= GetIniParam(nmIniFileBOB, 'Threads', 'DebugManufsAuto');
    flMfDebug:= (sDebugManufs<>'');
  end else flMfDebug:= False;

  try
    ORD_IBD:= cntsOrd.GetFreeCnt('', '', '', True);
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
      if flMfDebug then begin
        ORD_IBS.ParamCheck:= False;
        ORD_IBS.SQL.Add('execute block returns (DTSY integer, DMOS integer, TRNA integer, SRC integer,');
        ORD_IBS.SQL.Add('  aCOUNT double precision, hasWares integer, hasFilters integer, hasPLs integer)');
        ORD_IBS.SQL.Add('as declare variable MainNode integer=0;');
        ORD_IBS.SQL.Add('begin haswares=0; hasFilters=0; SRC=0; aCOUNT=0; TRNA=0; DMOS=0; hasPLs=0;');
        ORD_IBS.SQL.Add('  for select DRMLDTSYCODE, DMOSCODE from');
        ORD_IBS.SQL.Add('    (select DRMLDTSYCODE, DRMLCODE from DIRMODELLINES');
        ORD_IBS.SQL.Add('      where DRMLMFAUCODE in ('+sDebugManufs+') order by DRMLDTSYCODE)');
        ORD_IBS.SQL.Add('    inner join DIRMODELS on DMOSDRMLCODE=DRMLCODE');
        ORD_IBS.SQL.Add('  into :DTSY, :DMOS do begin');
        ORD_IBS.SQL.Add('    for select LDEMTRNACODE, LDEMCOUNT, LDEMSRCLECODE, iif(ldemfilters="T", 1, 0),'+
                        '      trnamaincode, iif(LDEMHASWARES="T", 1, 0), iif(LDEMHASPLS="T", 1, 0)');
        ORD_IBS.SQL.Add('      from LINKDETAILMODEL left join treenodesauto on trnacode=LDEMTRNACODE');
        ORD_IBS.SQL.Add('      where LDEMDMOSCODE=:DMOS and LDEMWRONG="F"');
        ORD_IBS.SQL.Add('    into :TRNA, :aCOUNT, :src, :hasFilters, :MainNode, :hasWares, :hasPLs');
        ORD_IBS.SQL.Add('    do begin if (MainNode<>TRNA) then');
        ORD_IBS.SQL.Add('      select iif(ld.ldemfilters="T", 1, 0), iif(ld.LDEMHASWARES="T", 1, 0),'+
                        '        iif(ld.LDEMHASPLS="T", 1, 0) from LINKDETAILMODEL ld');
        ORD_IBS.SQL.Add('        where ld.LDEMDMOSCODE=:DMOS and ld.LDEMTRNACODE=:MainNode'+
                        '      into :hasFilters, :hasWares, :hasPLs;');
        ORD_IBS.SQL.Add('      suspend; end end end');
      end else begin
        ORD_IBS.SQL.Text:= 'select * from GetModelNodeLinks_new('+
          fnIfStr(Cache.AllowWebArm, '0', '1')+', '+fnIfStr(Cache.WebAutoLinks, '0', '1')+')';
      end;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        pTypeSys:= ORD_IBS.FieldByName('DTSY').AsInteger; // �������
        with FAutoTreeNodesSys[pTypeSys].NodesList do // ������ ��������������� ����� �������
          iCount:= Count; // ���������� ��� � ������ �������

        with lstLinks do if (Count>0) then Clear; // ��������� ������ �� ���-�� ����� �������

        while not ORD_IBS.Eof and (pTypeSys=ORD_IBS.FieldByName('DTSY').AsInteger) do begin
          pModelID:= ORD_IBS.FieldByName('DMOS').AsInteger;
          if Models.ModelExists(pModelID) then Model:= Models[pModelID] else Model:= nil;
                                       // ����� WebArm ��������� ������ �������
          if not Assigned(Model) or not (Cache.AllowWebArm or Model.IsVisible) then begin
            TestCssStopException;
            while not ORD_IBS.Eof and (pTypeSys=ORD_IBS.FieldByName('DTSY').AsInteger)
              and (pModelID=ORD_IBS.FieldByName('DMOS').AsInteger) do ORD_IBS.Next;
            Inc(err1);
            Continue;
          end;

          if (lstLinks.Count<1) then with lstLinks do begin
            Capacity:= iCount;  // ��������� ��������� ������ �� ���-�� ����� �������
            for j:= 0 to iCount-1 do Add(nil);
          end;

  //----------------------------------- ������������ 1 ������
          while not ORD_IBS.Eof and (pTypeSys=ORD_IBS.FieldByName('DTSY').AsInteger)
            and (pModelID=ORD_IBS.FieldByName('DMOS').AsInteger) do begin
            tnID := ORD_IBS.FieldByName('TRNA').AsInteger;  // ��� ����
            index:= -1;
            if FAutoTreeNodesSys[pTypeSys].NodeGet(tnID, pNode) and pNode.IsEnding // ���� ���� ���� � ��������
              and ((pNode.ID=pNode.MainCode) or pNode.Visible) then // ���� ������� ��� ������� �����������
              index:= pNode.OrderNum-1;
            if (index>-1) then begin // ������� ������� ������� ����������� �����, ��� ���������� ������ 3
              haswares:= (ORD_IBS.FieldByName('hasWares').AsInteger=1); // �������� ������ (��� ������� ��������)
              hasFilters:= (ORD_IBS.FieldByName('hasFilters').AsInteger=1); // ������� ������� �������� � ���� ������
              HasMotul:= (ORD_IBS.FieldByName('hasPLs').AsInteger=1); // ������� ������� ����� � Motul
              lstLinks[index]:= TSecondLink.Create(ORD_IBS.FieldByName('SRC').AsInteger, // ������� ������ ����
                ORD_IBS.FieldByName('aCOUNT').AsFloat, pNode, True, haswares, hasFilters, HasMotul);
              Inc(Result);

              AddParentLink(pNode.ParentID, haswares, HasMotul); // ��������� ���������
//              pNode.HasLinks:= True; // ������� ������� 2-� ������
            end else begin
              prMessageLOGS(nmProc+': not node ID= '+IntToStr(tnID), fLogCache+'_test', false);
              Inc(err2);
            end; // if index>-1
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
          end; // while ... (pModelID=
          Models[pModelID].NodeLinks.AddLinkItems(lstLinks); // ������� ����� ��������������� ������ � ���
          if flSleep then sleep(SleepFillLinksInt);
  //----------------------------------- ���������� 1 ������
        end; // while ... (pTypeSys=
      end; // while not ORD_IBS.Eof
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD, True);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  lstLinks.Clear;
  prMessageLOGS(nmProc+': '+IntToStr(Result)+' ��.��-��� - '+
    GetLogTimeStr(TimeProc), fLogCache, false);
  if (err1>0) or (err2>0) then prMessageLOGS(nmProc+': no'+
    fnIfStr(err1>0, ' Models='+IntToStr(err1), '')+
    fnIfStr(err2>0, ' Nodes='+IntToStr(err2), ''), fLogCache, false);
  TestCssStopException;
end;
//========================================== �������� ������ ������ �� ������� 2
procedure TDataCacheAdditionASON.FillWareModelNodeLinks;
const nmProc = 'FillWareModelNodeLinks';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    WareID, ModelID, srcID, nodeID, i, Result, wm, wl, sysID, iSleep: Integer;
    Ware: TWareInfo;
    Model: TModelAuto;
    link2: TSecondLink;
    nlinks: TNodeLinks;
    mlinks: TLinkList;
    arml, armf: TBooleanDynArray;
    flMfDebug, flSleep: Boolean;
    sDebugManufs: String;
    ListErr1, ListErr2, ListErr3, ListErr4: TIntegerList;
begin
  if not Assigned(self) then Exit;
  SleepFillLinksInt:= GetIniParamInt(nmIniFileBOB, 'intervals', 'SleepFillLinksInt', 10); // �������� �������� ���������� ������
  flSleep:= not flDebug and (SleepFillLinksInt>0) and fnGetActionTimeEnable(caeOnlyWorkTime);
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  TimeProc:= Now;
  Result:= 0;
  iSleep:= 0;
  SetLength(arml, Length(ModelLines.FarModelLines));
  SetLength(armf, Length(Manufacturers.FarManufacturers));
  ListErr1:= TIntegerList.Create;
  ListErr2:= TIntegerList.Create;
  ListErr3:= TIntegerList.Create;
  ListErr4:= TIntegerList.Create;

  if Cache.WebAutoLinks then begin
    sDebugManufs:= GetIniParam(nmIniFileBOB, 'Threads', 'DebugManufsAuto');
    flMfDebug:= (sDebugManufs<>'');
  end else flMfDebug:= False;

  with Models do try
    try
      ORD_IBD:= cntsOrd.GetFreeCnt('', '', '', True);
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
      if flMfDebug then begin
        ORD_IBS.ParamCheck:= False;
        ORD_IBS.SQL.Add('execute block returns (DMOS integer, TRNA integer, WARE integer, SRC integer)');
        ORD_IBS.SQL.Add('as declare variable MainNode integer=0; declare variable ldem integer=0;');
        ORD_IBS.SQL.Add('  declare variable DTSY integer=0; begin DMOS=0; TRNA=0; WARE=0; SRC=0;');
        ORD_IBS.SQL.Add('  for select LDEMDMOSCODE, LDEMTRNACODE, LDMWWARECODE, LDMWSRCLECODE from');
        ORD_IBS.SQL.Add('    (select LDEMDMOSCODE, LDEMTRNACODE, ldemcode from (select DMOSCODE from DIRMODELS');
        ORD_IBS.SQL.Add('      inner join DIRMODELLINES on DRMLCODE=DMOSDRMLCODE and DRMLMFAUCODE in ('+sDebugManufs+'))');
        ORD_IBS.SQL.Add('      inner join LINKDETAILMODEL on LDEMDMOSCODE=DMOSCODE and LDEMWRONG="F")');
        ORD_IBS.SQL.Add('    inner join linkdetmodware on ldmwldemcode=ldemcode and LDMWWRONG="F"');
        ORD_IBS.SQL.Add('    inner join WareOptions on wowarecode=LDMWWARECODE and WOARHIVED="F"');
        ORD_IBS.SQL.Add('    into :DMOS, :TRNA, :WARE, :SRC do if (not WARE is null) then suspend; end');
      end else
        ORD_IBS.SQL.Text:= 'select * from GetModelNodeWareLinks('+
          fnIfStr(Cache.AllowWebArm, '0', '1')+', '+fnIfStr(Cache.WebAutoLinks, '0', '1')+')';
      ORD_IBS.ExecQuery;
      Result:= 0;
      while not ORD_IBS.Eof do begin
        ModelID:= ORD_IBS.FieldByName('DMOS').AsInteger; // ��� ������
        if ModelExists(ModelID) then Model:= FarModels[ModelID] else Model:= nil;
        if not Assigned(Model) or not Model.NodesExists
          or not (Cache.AllowWebArm or Model.IsVisible) then begin // ����� WebArm ��������� ������ �������
          TestCssStopException;
          while not ORD_IBS.Eof and (ModelID=ORD_IBS.FieldByName('DMOS').AsInteger) do ORD_IBS.Next;
          if not flMfDebug then ListErr1.Add(ModelID);
          Continue;
        end;

        wm:= 0;
        nlinks:= Model.NodeLinks;
        while not ORD_IBS.Eof and (ModelID=ORD_IBS.FieldByName('DMOS').AsInteger) do begin // 1 ������
          nodeID:= ORD_IBS.FieldByName('TRNA').AsInteger; // ��� ����

          link2:= nlinks[nodeID]; // ���� �� ����
          if not Assigned(link2) or (link2.LinkID<1) then begin
            TestCssStopException;
            while not ORD_IBS.Eof and (ModelID=ORD_IBS.FieldByName('DMOS').AsInteger)
              and (nodeID=ORD_IBS.FieldByName('TRNA').AsInteger) do ORD_IBS.Next;
            if not flMfDebug then ListErr2.Add(nodeID);
            Continue;
          end;

          wl:= 0;
          while not ORD_IBS.Eof and (ModelID=ORD_IBS.FieldByName('DMOS').AsInteger)
            and (nodeID=ORD_IBS.FieldByName('TRNA').AsInteger) do begin // 1 ���� = 1 ������ 2
            WareID:= ORD_IBS.FieldByName('WARE').AsInteger;  // ��� ������
            srcID   := ORD_IBS.FieldByName('SRC').AsInteger; // ��� ��������� �����
            Ware:= Cache.GetWare(WareID, True);
//            if (Ware=NoWare) or Ware.IsArchive then ListErr3.Add(WareID)
//            else if Ware.IsINFOgr then ListErr4.Add(WareID)
//            else begin
            if (Ware<>NoWare) and not Ware.IsArchive and not Ware.IsINFOgr then begin
              link2.CheckDoubleLinks(Model.CS_mlinks);
              link2.DoubleLinks.AddLinkListItem(TLink.Create(srcID, Ware), lkLnkNone, Model.CS_mlinks); // ������ 3
              Inc(Result); // ������� ������ � �������� �����
              Inc(wm);     // ������� ������ � �������� � ������
              Inc(wl);     // ������� ������ � �������� � ����� �� ����
            end;
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
          end; // while ... ModelID= ... and (nodeID=

          if (wl<1) and link2.NodeHasWares then begin // ����� ������� ������� �������
            sysID:= Model.TypeSys;                 // ������ �� ���� � ������������ ����
            if (cache.FDCA.AutoTreeNodesSys[sysID].GetNodeByID(NodeID).MainCode=NodeID) then
              SetHasWaresModelNodeParentLinks(Model, NodeID, False);
//  prMessageLOGS(nmProc+': not HasWares Model='+IntToStr(ModelID)+', Node='+IntToStr(NodeID), fLogCache+'_test', false);
          end;
        end; // while ... (ModelID=

        with Model do begin
          ModelHasWares:= (wm>0); // ������� ������� ������� �� ������
          if ModelHasWares then arml[ModelLineID]:= True;
        end;
        if flSleep then sleep(SleepFillLinksInt);
      end; // while not ORD_IBS.Eof
      ORD_IBS.Close;
      prMessageLOGS(nmProc+': '+IntToStr(Result)+' ��.���-��-��� - '+
        GetLogTimeStr(TimeProc), fLogCache, false);
      TimeProc:= Now;
      Result:= 0;
//---------------------------------------------------- ������ ������� � ��������
      SleepFillLinksInt:= GetIniParamInt(nmIniFileBOB, 'intervals', 'SleepFillLinksInt', 10); // �������� �������� ���������� ������
      flSleep:= not flDebug and (SleepFillLinksInt>0) and not fnGetActionTimeEnable(caeSmallWork);
      if flMfDebug then begin
        ORD_IBS.SQL.Clear;
        ORD_IBS.SQL.Add('execute block returns (LDEMDMOSCODE integer, LDMWWARECODE integer)');
        ORD_IBS.SQL.Add('as declare variable MainNode integer=0; declare variable ldem integer=0;');
        ORD_IBS.SQL.Add('  declare variable DTSY integer=0; begin LDEMDMOSCODE = 0; LDMWWARECODE = 0;');
        ORD_IBS.SQL.Add('  for select wowarecode from WareOptions where WOARHIVED="F" and ');
        ORD_IBS.SQL.Add('    exists(select * from LINKDETMODWARE ');
        ORD_IBS.SQL.Add('      inner join LINKDETAILMODEL on LDEMCODE=LDMWLDEMCODE and LDEMWRONG="F"');
        ORD_IBS.SQL.Add('      inner join DIRMODELS on DMOSCODE=LDEMDMOSCODE');
        ORD_IBS.SQL.Add('      inner join DIRMODELLINES on DRMLCODE=DMOSDRMLCODE and DRMLMFAUCODE in ('+sDebugManufs+')');
        ORD_IBS.SQL.Add('    where LDMWWARECODE = wowarecode and LDMWWRONG="F")');
        ORD_IBS.SQL.Add('  order by wowarecode into :LDMWWARECODE do begin');
        ORD_IBS.SQL.Add('    for select LDEMDMOSCODE from (select LDEMDMOSCODE from (select LDMWLDEMCODE');
        ORD_IBS.SQL.Add('      from LINKDETMODWARE where LDMWWARECODE = :LDMWWARECODE and LDMWWRONG = "F")');
        ORD_IBS.SQL.Add('      inner join LINKDETAILMODEL on LDEMCODE = LDMWLDEMCODE and LDEMWRONG = "F"');
        ORD_IBS.SQL.Add('      group by LDEMDMOSCODE)');
        ORD_IBS.SQL.Add('    inner join DIRMODELS on DMOSCODE = LDEMDMOSCODE');
        ORD_IBS.SQL.Add('    inner join DIRMODELLINES on DRMLCODE = DMOSDRMLCODE');
        ORD_IBS.SQL.Add('    inner join manufacturerauto on mfaucode = drmlmfaucode');
        ORD_IBS.SQL.Add('    where DRMLMFAUCODE in ('+sDebugManufs+')');
        ORD_IBS.SQL.Add('    order by mfauname, drmlname, dmosname into :LDEMDMOSCODE do');
        ORD_IBS.SQL.Add('    if (not LDEMDMOSCODE is null) then suspend; end end');
      end else
        ORD_IBS.SQL.Text:= 'select * from GetWareModelLinks('+
          fnIfStr(Cache.AllowWebArm, '0', '1')+', '+fnIfStr(Cache.WebAutoLinks, '0', '1')+')';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        WareID:= ORD_IBS.FieldByName('LDMWWARECODE').AsInteger;  // ��� ������
        if not Cache.WareExist(WareID) then begin
          if not flMfDebug then ListErr3.Add(WareID);
          TestCssStopException;
          while not ORD_IBS.Eof and (WareID=ORD_IBS.FieldByName('LDMWWARECODE').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        Ware:= Cache.GetWare(WareID, True);
        if (Ware=NoWare) or Ware.IsArchive then begin
          if not flMfDebug then ListErr3.Add(WareID);
          TestCssStopException;
          while not ORD_IBS.Eof and (WareID=ORD_IBS.FieldByName('LDMWWARECODE').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        if Ware.IsINFOgr then begin
          if not flMfDebug then ListErr4.Add(WareID);
          TestCssStopException;
          while not ORD_IBS.Eof and (WareID=ORD_IBS.FieldByName('LDMWWARECODE').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        mlinks:= Ware.ModelLinks;
        while not ORD_IBS.Eof and (WareID=ORD_IBS.FieldByName('LDMWWARECODE').AsInteger) do begin
          ModelID:= ORD_IBS.FieldByName('LDEMDMOSCODE').AsInteger; // ��� ������
          if ModelExists(ModelID) then Model:= FarModels[ModelID] else Model:= nil;

          if Assigned(Model) and Model.NodesExists
            and (Cache.AllowWebArm or Model.IsVisible) then begin // ����� WebArm ��������� ������ ������� ������
            mlinks.AddLinkListItem(Model, lkDirNone, Ware.CS_wlinks);
            Inc(Result); // ������� ������ � ��������
          end;

          cntsORD.TestSuspendException;
          ORD_IBS.Next;
        end;
        if flSleep then begin
          if iSleep<10 then inc(iSleep)
          else begin
            sleep(SleepFillLinksInt);
            iSleep:= 0;
          end;
        end;
      end;
//------------------------------------------------------------------------------
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD, True);
    end;

    with ModelLines do for i:= 1 to Length(arml)-1 do // �������� ������� ������� �� ���.����
      if ModelLineExists(i) and arml[i] then with ModelLines[i] do begin
        MLHasWares:= True;
        armf[MFAID]:= True;
      end;
    with Manufacturers do for i:= 1 to Length(armf)-1 do // �������� ������� ������� �� ������.
      if ManufExists(i) and armf[i] then
        Manufacturers[i].ManufHasWares:= True;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  SetLength(arml, 0);
  SetLength(armf, 0);
  prMessageLOGS(nmProc+': '+IntToStr(Result)+' ��.���-��� - '+
    GetLogTimeStr(TimeProc), fLogCache, false);
  if (ListErr1.Count>0) or (ListErr2.Count>0) or (ListErr3.Count>0) then
    prMessageLOGS(nmProc+': no'+
      fnIfStr(ListErr1.Count>0, ' Models='+fnIntegerListToStr(ListErr1), '')+
      fnIfStr(ListErr2.Count>0, ' Nodes='+fnIntegerListToStr(ListErr2), '')+
      fnIfStr(ListErr3.Count>0, ' Wares='+fnIntegerListToStr(ListErr3), '')+
      fnIfStr(ListErr4.Count>0, ' InfoWares='+fnIntegerListToStr(ListErr3), '')
      , fLogCache, false);
prFree(ListErr1);
  prFree(ListErr2);
  prFree(ListErr3);
  TestCssStopException;
end;
//=============================================== ��������� ��������� ������ 2
function TDataCacheAdditionASON.CheckNotValidModelNodeLinkParams(ModelID, NodeID: Integer;
         var Model: TModelAuto; var Node: TAutoTreeNode; var SysID: Integer; var errmess: string): Boolean;
begin
  if not Assigned(self) then errmess:= MessText(mtkErrProcess)
  else if not CheckNotValidModel(ModelID, SysID, Model, errmess) and  // ��������� ������
    not Cache.FDCA.AutoTreeNodesSys[SysID].NodeGet(NodeID, Node) then // ��������� ����
    errmess:= MessText(mtkNotFoundNode, IntToStr(NodeID));
  Result:= errmess<>'';
end;
//============================ �������� / ���������� ������� ���������� ������ 3
function TDataCacheAdditionASON.CheckWareModelNodeUsage(WareID, ModelID, NodeID: Integer;
         UsageName, UsageValue: String; var ResCode: Integer; srcID: Integer=0; userID: Integer=0): string;
const nmProc = 'CheckWareModelNodeUsage';
// ��� �������� - ResCode - �� ����� (resAdded, resDeleted, resAddOrEdit)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������, resAdded - ���������,
// resDeleted - �������, resAddOrEdit - ��������� ��� ��������
// UsageName - �������� �������� �������, UsageValue - �������� �������� �������
var OpCode, SysID: Integer;
    Model: TModelAuto;
//    errmess: string;
    fAdd: Boolean;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not (OpCode in [resAdded, resDeleted, resAddOrEdit]) then // ��������� ��� ��������
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');

    if not Models.ModelExists(ModelID) then              // ��������� ������
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)))
    else Model:= Models[ModelID];

    if not Cache.WareExist(WareID) or Cache.GetWare(wareID).IsArchive then // ��������� �����
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    SysID:= Model.TypeSys;
    if not AutoTreeNodesSys[SysID].NodeExists(NodeID) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));

    with AutoTreeNodesSys[SysID][NodeID] do begin // ������������ �� ������� ����
      fAdd:= ID<>MainCode;
      if fAdd then NodeID:= MainCode;
    end;
    if fAdd and not AutoTreeNodesSys[SysID].NodeExists(NodeID) then // ��������� ������� ����
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));

    if not Model.NodeLinks.DoubleLinkExists(nodeID, WareID) then        // ��������� ������ 3
      raise EBOBError.Create('�� ������� '+MessText(mtkWareModNodeLink));

    fAdd:= OpCode<>resDeleted;
    if fAdd and ((srcID<1) or (userID<1)) then  // ���� ���������� - ��������� srcID, userID
      raise EBOBError.Create(MessText(mtkNotParams));

    try
      ORD_IBD:= cntsOrd.GetFreeCnt; //---------------------------- ������ � ����
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select linkID, errLink from CheckModelNodeWareUsageLink('+
        IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(WareID)+
        ', 0, :CriName, :CriValue, '+IntToStr(OpCode)+', '+IntToStr(UserID)+', '+IntToStr(srcID)+')';
      ORD_IBS.ParamByName('CriName').AsString:= UsageName;
      ORD_IBS.ParamByName('CriValue').AsString:= UsageValue;
      ORD_IBS.ExecQuery;

      if fAdd then begin // ���� ����������
        if (ORD_IBS.Eof and ORD_IBS.Bof) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else if (ORD_IBS.Fields[1].AsInteger>0) then
          raise EBOBError.Create(MessText(mtkWareModNodeUse)+' � ���� ��������, ��� ��������')
        else if (ORD_IBS.Fields[1].AsInteger<0) then begin // ��� ����
          ResCode:= resDoNothing;
          Result:= '����� '+MessText(mtkWareModNodeUse)+' ����';
          if (OpCode=resAddOrEdit) and (ORD_IBS.Fields[0].AsInteger=-resAddOrEdit) then
            Result:= Result+', ������ �������� �������';
        end else if (ORD_IBS.Fields[0].AsInteger=0) then
          raise Exception.Create('error add use link Model='+IntToStr(ModelID)+
            ' Node='+IntToStr(NodeID)+' Ware='+IntToStr(WareID)+
            ' CriName='+UsageName+' CriValue='+UsageValue)
        else if (OpCode=resAddOrEdit) and (ORD_IBS.Fields[0].AsInteger=-resAddOrEdit) then begin
          ResCode:= resEdited;
          Result:= MessText(mtkWareModNodeUse)+' ��������';
        end else begin
          ResCode:= resAdded;
          Result:= MessText(mtkWareModNodeUse)+' ���������';
        end;

      end else begin  // ���� ��������
        if (ORD_IBS.Eof and ORD_IBS.Bof) then
          raise EBOBError.Create(MessText(mtkErrDelRecord))
        else if (ORD_IBS.Fields[0].AsInteger<1) then begin
          ResCode:= resDoNothing;
          Result:= '����� '+MessText(mtkWareModNodeUse)+' �� �������';
        end else begin
          ResCode:= resDeleted;
          Result:= MessText(mtkWareModNodeUse)+' �������';
        end;
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    if (ResCode=resError) then ResCode:= OpCode; // �� ����.������
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      if (ResCode<>resError) then ResCode:= resError; // �� ����.������
      Result:= CutEMess(E.Message);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//============================== �������� / ���������� / �������������� ������ 3
function TDataCacheAdditionASON.CheckWareModelNodeLink(WareID, ModelID, NodeID: Integer;
         var ResCode: Integer; srcID: Integer=0; userID: Integer=0): string;
const nmProc = 'CheckWareModelNodeLink';
// ��� �������� - ResCode - �� ����� (resAdded, resDeleted, resWrong, resNotWrong)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������, resAdded - ���������,
// resDeleted - �������, resWrong - ��������, ��� ��������, resNotWrong - �������������
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    SysID, OpCode, linkSrc: Integer;
    Ware: TWareInfo;
    Model: TModelAuto;
    Node: TAutoTreeNode;
    mess, mess1: string;
    fex: Boolean;
    link2: TSecondLink;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  mess1:= '';
  try
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then       // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');
//------------------------------------------------------ ��������� ������ � ����
    if CheckNotValidModelNodeLinkParams(ModelID, NodeID, Model, Node, SysID, mess) then
      raise Exception.Create(mess);

    if (Node.ID<>Node.MainCode) then begin // ������������ �� ������� ����
      NodeID:= Node.MainCode;
      if not AutoTreeNodesSys[SysID].NodeGet(NodeID, Node) then
        raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    end;

    if not Model.NodeLinks.LinkExists(nodeID) then         // ��������� ������ 2
      raise Exception.Create('�� ������� '+MessText(mtkModelNodeLink));

    Ware:= Cache.GetWare(WareID, True);
    if (Ware=NoWare) or Ware.IsArchive then                   // ��������� �����
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    fex:= Model.NodeLinks.DoubleLinkExists(nodeID, WareID); // ��������� ������ 3
    mess:= MessText(mtkWareModNodeLink);

    case OpCode of
      resAdded, resNotWrong:
        if fex then begin
          if (OpCode=resAdded) then mess:= '����� '+mess+' ����'
          else mess:= mess+' �� ��������, ��� ���������';
          ResCode:= resDoNothing;
          raise Exception.Create(mess);
        end else if (userID<1) then
          raise Exception.Create(MessText(mtkNotValidParam)+' �����')
        else if (OpCode=resAdded) and (srcID<1) then
          raise Exception.Create(MessText(mtkNotValidParam)+' ���������');

      resDeleted, resWrong:
        if not fex then begin
          ResCode:= resDoNothing;
          raise Exception.Create('�� ������� '+mess);
        end else if (OpCode=resWrong) then begin
          linkSrc:= GetLinkSrc(Model.NodeLinks.GetDoubleLinks(nodeID).GetLinkListItemByID(WareID, lkLnkNone));
          if not Cache.CheckLinkAllowWrong(LinkSrc) then begin
            if not Cache.CheckLinkAllowDelete(LinkSrc) then
              raise Exception.Create(MessText(mtkFuncNotAvailabl));
              if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' �����');
            srcID:= linkSrc;
            OpCode:= resDeleted; // ������ �� TecDoc �������
          end;
        end else if (OpCode=resDeleted) then begin // ��������� �������� ������
          linkSrc:= GetLinkSrc(Model.NodeLinks.GetDoubleLinks(nodeID).GetLinkListItemByID(WareID, lkLnkNone));
          if not Cache.CheckLinkAllowDelete(LinkSrc) then begin
            if not Cache.CheckLinkAllowWrong(LinkSrc) then
              raise Exception.Create(MessText(mtkFuncNotAvailabl));
            if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' �����');
            srcID:= linkSrc;
            OpCode:= resWrong; // ������ TecDoc �� �������, � �������� ���������
            mess1:= ' (TecDoc)';
          end;
        end;
    end; // case
//--------------------------------------------------- ������������ ������ � ����
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      case OpCode of
      resAdded: begin                // ���������
          ORD_IBS.SQL.Text:= 'select linkID, errLink from AddModelNodeWareLink('+
            IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(WareID)+', '+
            IntToStr(UserID)+', '+IntToStr(srcID)+')';
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Bof and ORD_IBS.Eof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ORD_IBS.Fields[1].AsInteger=1) then
            raise EBOBError.Create(MessText(mtkWareModNodeLink)+' � ���� ��������, ��� ��������')
          else if (ORD_IBS.Fields[0].AsInteger<1) then
            raise EBOBError.Create(MessText(mtkErrAddRecord));
        end; // resAdded

      resWrong, resNotWrong: begin // ������ ������� Wrong
          ORD_IBS.SQL.Text:= 'execute procedure SetModelNodeWareLinkWrongMark("'+
            fnIfStr(OpCode=resWrong, 'T', 'F')+'", '+IntToStr(ModelID)+', '+
            IntToStr(NodeID)+', '+IntToStr(WareID)+', '+IntToStr(UserID)+', '+IntToStr(srcID)+')';
          ORD_IBS.ExecQuery;
        end; // resWrong, resNotWrong

      resDeleted: begin              // �������
          ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWareLink('+
            IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(WareID)+')';
          ORD_IBS.ExecQuery;
        end; // resDeleted
      end; // case
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
//------------------------------------------------------------- ������������ ���
    case OpCode of
      resAdded, resNotWrong: begin                // ���������
        link2:= Model.NodeLinks[NodeID];
        link2.CheckDoubleLinks(Model.CS_mlinks);
        link2.DoubleLinks.AddLinkListItem(TLink.Create(srcID, Ware), lkLnkNone, Model.CS_mlinks); // ������ 3
        SetHasWaresModelNodeParentLinks(Model, NodeID); // ���������� ������� ������� ������� ������ �� ���� � ������������ ����
        if not Model.ModelHasWares then begin
          Model.ModelHasWares:= True; // �������� ������� ������� �� ������, ���.���� � ������.
          if ModelLines.ModelLineExists(Model.ModelLineID) then
            with ModelLines[Model.ModelLineID] do begin
              if not MLHasWares then MLHasWares:= True;
              if Manufacturers.ManufExists(MFAID) then with Manufacturers[MFAID] do
                if not ManufHasWares then ManufHasWares:= True;
            end;
        end;
        with Ware.ModelLinks do if not LinkListItemExists(ModelID, lkDirNone) then begin
          AddLinkListItem(Model, lkDirNone, Ware.CS_wlinks);
          if Ware.ModelsSorting then Sort(WareModelsSortCompare);
        end;
      end; // resAdded, resNotWrong

      resDeleted, resWrong: begin              // �������
        link2:= Model.NodeLinks[NodeID];
        with link2.DoubleLinks do begin
          DelLinkListItemByID(WareID, lkLnkNone, Model.CS_mlinks); // ������ 3
          if (Count<1) then begin    // ���� ��� ��� ��������� ����� - ����� ������� ������� ������� � ����� �� ����
            SetHasWaresModelNodeParentLinks(Model, NodeID, False); // � ��������� ������������ ����
          end;
        end;                          // ������������ ������ ������ � ��������
        with Model.NodeLinks do for SysID:= 0 to ListLinks.Count-1 do begin
          NodeID:= GetLinkID(ListLinks[SysID]);
          if GetDoubleLinks(NodeID).LinkListItemExists(WareID, lkLnkNone) then begin
            ModelID:= 0; // ���� � ������ ���� ��� ����� �� ���� ����� - �������� ��� ������
            break;
          end;
        end;
        if (ModelID>0) then Ware.ModelLinks.DelLinkListItemByID(ModelID, lkDirNone, Ware.CS_wlinks);
      end; // resDeleted, resWrong
    end; // case
    Ware.CheckHasModels(Model.TypeSys);

    case OpCode of
      resAdded:    Result:= mess+' ���������';
      resDeleted:  Result:= mess+' �������';
      resWrong:    Result:= mess+mess1+' ��������, ��� ��������';
      resNotWrong: Result:= mess+' �������������';
    end;
    ResCode:= OpCode;
  except
    on E: Exception do Result:= CutEMess(E.Message, ResCode);
  end;
end;
//============================= �������������� ������ 2 �� ������ ���������� ���
function TDataCacheAdditionASON.CheckModelNodeLinkDup(ModelID, NodeID: Integer; Value: String;
         var ResCode: Integer; srcID: Integer=0; userID: Integer=0): string;
const nmProc = 'CheckModelNodeLinkDup';
// ��� ��������: Value='' - ��������, Value<>'': ������ ���� - ��������������, ������ ��� - ����������
// ResCode �� ������: resError- ������, resDoNothing - �� ��������,
// resAdded - ����������, resEdited - ��������������, resDeleted - ��������
type
  TActionKind = (akAdd, akEdit, akDel, akNot, akSet, akNothing, akUnknown); // ��� ��������
  TNodeLinkData = record   // ������ ������ � ����� �� ������ ����������
    d_NodeID: Integer;     // ID ����
    d_Act: TActionKind;    // ��� �������� � ����, ����
    d_Link: TSecondLink;   // ������ �� ������ 2 � �������� �������
    d_Node: TAutoTreeNode; // ������ �� ����
  end;
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    i, ii, j, iAll, SysID, NodeMainCode, DelCount, AddCount, EditCount, ErrCount: Integer;
    Model: TModelAuto;
    Node, NodeMain: TAutoTreeNode;
    errmess: string;
    pQty: Double;
    fDel: Boolean;
    NextLink: TSecondLink;
    lstNodes: TStringList; // ������ ����� ��� ����������
    codes: Tai;
    DataNodes: array of TNodeLinkData;
    ls: TLinkList;
begin
  Result:= '';
  ResCode:= resError;
  pQty:= 0;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  lstNodes:= nil;
  SetLength(codes, 0);
  SetLength(DataNodes, 0);
  DelCount:= 0;
  AddCount:= 0;
  EditCount:= 0;
  ErrCount:= 0;
  try
    Value:= trim(Value);
    fDel:= Value=''; // ���� ��������
    if not fDel then begin //----------------- ��������� ������������ ����������
      Value:= StrWithFloatDec(Value); // ��������� DecimalSeparator
      pQty:= StrToFloatDef(Value, 99999);
      if not fnNotZero(pQty-99999) then
        raise Exception.Create(MessText(mtkNotValidParam)+' ����������');
    end;
    //------------------------------ �������� � ��������� �������, ������ � ������� ����
    if CheckNotValidModelNodeLinkParams(ModelID, NodeID, Model, Node, SysID, errmess) then
      raise Exception.Create(errmess);

    NodeMainCode:= Node.MainCode; //--------------------- ��������� ������� ����
    if NodeID=NodeMainCode then NodeMain:= Node
    else if not AutoTreeNodesSys[SysID].NodeGet(NodeMainCode, NodeMain) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeMainCode)));
            // ���� ����������� ��� (��� �������� - ����, ����� ������ �������)
    codes:= AutoTreeNodesSys[SysID].GetDuplicateNodeCodes(NodeMainCode, not fDel);

    //------------------------------ ��������� ������ ���� ��� ������ ����������
    SetLength(DataNodes, Length(codes)+1);
    with DataNodes[0] do begin  // ������� - ������� ����
      d_NodeID:= NodeMainCode;
      d_Node:= NodeMain;
      d_link:= Model.NodeLinks[NodeMainCode]; // ���� ��� - ���������� nil
    end;
    for i:= 0 to High(codes) do with DataNodes[i+1] do begin // ����������� ����
      d_NodeID:= codes[i];
      if d_NodeID=NodeID then d_Node:= Node // ���� ������� ���� ���� �����������
      else d_Node:= AutoTreeNodesSys[SysID][d_NodeID];
      d_link:= Model.NodeLinks[d_NodeID]; // ���� ��� - ���������� nil
    end;

    //------------------------------------- ��������� ��� ����: ��� ����� ������
    for i:= 0 to High(DataNodes) do with DataNodes[i] do
      if fDel then begin // ��������� ��������
        if not Assigned(d_link) or not d_link.IsLinkNode then begin // ������ 2 ���
          d_Act:= akNothing;
          Continue;
        end;
        if Assigned(d_link.DoubleLinks) and (d_link.DoubleLinks.Count>0) then  // ��������� ������ 3
          raise Exception.Create(MessText(mtkModelNodeLink)+' ����� ����� � ��������');
        d_Act:= akDel;       // ������� ������ 2
        inc(DelCount);

      end else if not Assigned(d_link) then begin // ��������� ����������
        if not Assigned(d_Node) then
          raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(d_NodeID)));
        if not d_Node.IsEnding then
          raise Exception.Create('���� '+d_Node.Name+' ����� �������� ����');
        d_Act:= akAdd;       // �������� ������ 2
        inc(AddCount);

      end else if fnNotZero(d_link.Qty-pQty) then begin // �������������� - ��������� ����������
        d_Act:= akEdit;      // �������� ����������
        inc(EditCount);
      end else d_Act:= akNothing; // for i:= 0 to High(DataNodes)

    if (DelCount=0) and (AddCount=0) and (EditCount=0) then begin
      ResCode:= resDoNothing;
      raise Exception.Create(MessText(mtkNotChanges));
    end;
    if (AddCount>0) // ���� ���� ���������� - ��������� srcID, userID
      and ((srcID<1) or (userID<1)) then raise Exception.Create(MessText(mtkNotParams));

    //------- ������������ ������ � ���� �� ������� ����, ����������� - ��������
    with DataNodes[0] do if (d_Act in [akAdd, akDel, akEdit]) then try
      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      case d_Act of
        akAdd: begin // ���������
          ORD_IBS.SQL.Text:= 'insert into LINKDETAILMODEL (LDEMDMOSCODE, LDEMTRNACODE, '+
            ' LDEMCOUNT, LDEMSRCLECODE, LDEMUSERID) values ('+IntToStr(ModelID)+', '+
            IntToStr(d_NodeID)+', :LDEMCOUNT, '+IntToStr(srcID)+', '+IntToStr(userID)+')';
          ORD_IBS.ParamByName('LDEMCOUNT').AsFloat:= pQty;
        end;

        akDel:  // �������
          ORD_IBS.SQL.Text:= 'delete from LINKDETAILMODEL where LDEMTRNACODE='+
            IntToStr(d_NodeID)+' and LDEMDMOSCODE='+IntToStr(ModelID);

        akEdit: begin // ������ ����������
          ORD_IBS.SQL.Text:= 'update LINKDETAILMODEL set LDEMCOUNT=:LDEMCOUNT, LDEMUSERID='+IntToStr(userID)+
            ' where LDEMTRNACODE='+IntToStr(d_NodeID)+' and LDEMDMOSCODE='+IntToStr(ModelID);
          ORD_IBS.ParamByName('LDEMCOUNT').AsFloat:= pQty;
        end;
      end; // case
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end; // with DataNodes[0]

    //--------------------------------------------------------- ������������ ���
    if (AddCount>0) then
      lstNodes:= AutoTreeNodesSys[SysID].NodesList; // ������ ������ ��������������� ����� ������

    for i:= Low(DataNodes) to High(DataNodes) do with DataNodes[i] do try
      case d_Act of
        akAdd: begin // ��������� ������ 2 � ����� �� ���������
          d_Link:= TSecondLink.Create(srcID, pQty, d_Node, True); // ����� ����
          repeat // ���� �� ������
            NextLink:= nil;
            iAll:= FindNodeIndex(d_NodeID, lstNodes); // ���� ������ ���� � ����� ������
            if iAll>-1 then for ii:= iAll+1 to lstNodes.Count-1 do // ���� ��������� ����, �� ������� ���� ���� � ������
              if Assigned(lstNodes.Objects[ii]) then begin
                j:= TAutoTreeNode(lstNodes.Objects[ii]).ID; // ��������� ������� ������ �� ���� ������ ������
                if Model.NodeLinks.LinkExists(j) then begin
                  NextLink:= Model.NodeLinks[j]; // ���� �� ��������� ���� ������ ������
                  break;
                end;
              end;
            Model.NodeLinks.InsertLink(d_Link, NextLink); // Insert ����� NextLink, ���� NextLink=nil - Add
            d_NodeID:= d_Node.ParentID;
            if (d_NodeID<1) or Model.NodeLinks.LinkExists(d_NodeID) then break; // ��������� ���� �� ���� ��������
            d_Node:= AutoTreeNodesSys[SysID].GetNodeByID(d_NodeID); // ���� ��������
            if not Assigned(d_Node) then break;
            d_Link:= TSecondLink.Create(0, 0, d_Node, False); // ���� �� ���� ��������
          until not Assigned(d_Node);
        end; // akAdd

        akDel: repeat // ������� ���� � ������ ����� �����
          ls:= d_link.DoubleLinks;
          prFree(ls);
          Model.NodeLinks.DeleteLinkItem(d_link); // ������� ����
          d_NodeID:= d_Node.ParentID;         // ��� ���� ��������
          if (d_NodeID<1) or not Model.NodeLinks.LinkExists(d_NodeID) then break; // ��������� ���� �� ���� ��������
          d_link:= Model.NodeLinks[d_NodeID];  // ���� �� ���� ��������
          if d_link.IsLinkNode then break; // ���� ������ 2 - ���������
          d_Node:= GetLinkPtr(d_link);     // ���� ��������
          if not Assigned(d_Node) then break;
          if Assigned(d_Node.Children) then with d_Node.Children do
            for j:= 0 to Count-1 do if Assigned(Objects[j]) and // ��������� ������� ������ �� ����� ��������
              Model.NodeLinks.LinkExists(TAutoTreeNode(Objects[j]).ID) then begin
              d_Node:= nil; // ���� �� ���� ���� ���� - ������ �� ������ �� ����
              break;
            end;
        until not Assigned(d_Node); // akDel

        akEdit: d_link.Qty:= RoundTo(pQty, -3); // ����������� - ������ ����������
      end; // case

    except
      on E: Exception do begin
        Result:= Result+fnIfStr(Result='', '', #10)+'error NodeID='+IntToStr(d_NodeID)+': '+E.Message;
        inc(ErrCount);
        case d_Act of
         akAdd: Dec(AddCount);  // ���������
         akDel: Dec(DelCount);  // �������
        akEdit: Dec(EditCount); // �������������
        end;
        d_Act:= akNot;
      end;
    end; // for i:= 0 to High(DataNodes)

    if (ErrCount<1) then
      if fDel and (DelCount>0) then ResCode:= resDeleted
      else if (AddCount>0)     then ResCode:= resAdded
      else if (EditCount>0)    then ResCode:= resEdited;
    if (DelCount>0) then
      Result:= Result+fnIfStr(Result='', '', #10)+'������� '+IntToStr(DelCount)+' ������ ������ � ������';
    if (AddCount>0) then
      Result:= Result+fnIfStr(Result='', '', #10)+'��������� '+IntToStr(AddCount)+' ������ ������ � ������';
    if (EditCount>0) then
      Result:= Result+fnIfStr(Result='', '', #10)+'�������� '+IntToStr(EditCount)+' ������ ������ � ������';
    if (ErrCount>0) then
      Result:= Result+fnIfStr(Result='', '', #10)+'������ ��������� '+IntToStr(ErrCount)+' ������ ������ � ������';
  except
    on E: Exception do Result:= Result+fnIfStr(Result='', '', #10)+CutEMess(E.Message);
  end;
  SetLength(codes, 0);
  SetLength(DataNodes, 0);
end;
//=============================== ���������� / ����� ����� ������ � ����.�������
function TDataCacheAdditionASON.CheckOrigNumLink(var ResCode: Integer; WareID, pMfID: Integer; var onID: Integer;
         var pONum: String; srcID: Integer=0; userID: Integer=0): String;
// srcID, userID ����� ������ ��� ����������, ���� ����� onID - pONum ������������ (����� resNotWrong) !!!
const nmProc = 'CheckOrigNumLink';
// ResCode �� ����� - ��� �������� (resAdded, resDeleted, resWrong, resNotWrong)
// !!! ��� resNotWrong ����� ������ pMfID, onID, pONum !!!     ???
// ResCode �� ������ - ���������: resError - ������, resDoNothing - �� ��������, 
// resAdded - ������ ���������, resDeleted - ������ �������, 
// resWrong - �������� ��������� ������ � ���� � ������� �� ����
// resNotWrong - ����� ������� ��������� ������ � ���� � ������ ��������� � ���
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    OpCode: Integer;
    s, sONid, sWid, mess1: String;
    OrigNum: TOriginalNumInfo;
    Ware: TWareInfo;
    pONumLinks: TLinkList;
    flDelON: boolean;
    fadd: boolean;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  mess1:= '';
  flDelON:= False;
  with Cache do try
//-------------------------------------------------------------------- ���������
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' �����');
    if not WareExist(WareID) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (OpCode=resAdded) and (srcID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ���������');

    Ware:= GetWare(WareID);
    if ware.IsArchive then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');

    s:= MessText(mtkNotValidParam)+' ����.������';
    if (onID<1) then begin
      if not Manufacturers.ManufExists(pMfID) then
        raise EBOBError.Create(MessText(mtkNotValidParam)+' ������.');
      pONum:= AnsiUpperCase(fnDelSpcAndSumb(pONum));
      if (pONum='') then raise EBOBError.Create(s);
      onID:= SearchOriginalNum(pMfID, pONum);

    end else if (OpCode<>resNotWrong) and not OrigNumExist(onID) then
      raise EBOBError.Create(s);

    if (OpCode<>resAdded) and (onID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' ����.������');

    pONumLinks:= Ware.ONumLinks;
    if (OpCode in [resAdded, resNotWrong]) // ��������� ����������
      and pONumLinks.LinkListItemExists(onID, lkLnkByID) then begin
      ResCode:= resDoNothing;
      s:= MessText(mtkWareOrNumLink);
      if (OpCode=resAdded) then s:= s+' ��� ����' else s:= s+' �� ��������, ��� ���������';
      raise EBOBError.Create(s);
    end;
//--------------------------------------------------- ������������ ������ � ����
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      sONid:= IntToStr(onID);
      sWid:= IntToStr(WareID);
      ORD_IBS.SQL.Text:= 'select rONid, Rmf, Ronum, Rsrc, ResCode, ResMess, RdelON'+
        ' from CheckWareOrigNumLink('+IntToStr(OpCode)+', '+sONid+', '+sWid+', '+
        IntToStr(pMfID)+', "'+pONum+'", '+IntToStr(userID)+', '+IntToStr(srcID)+')';
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Bof and ORD_IBS.Eof) then begin
        if (OpCode=resAdded) then Result:= MessText(mtkErrAddRecord)
        else if (OpCode=resDeleted) then Result:= MessText(mtkErrDelRecord)
        else Result:= MessText(mtkErrEditRecord);
        raise EBOBError.Create(Result);
      end;
      ResCode:= ORD_IBS.FieldByName('ResCode').AsInteger;
      Result := ORD_IBS.FieldByName('ResMess').AsString;
      if (ResCode=resDoNothing) then raise EBOBError.Create(Result);

      onID   := ORD_IBS.FieldByName('rONid').AsInteger;
      flDelON:= (ORD_IBS.FieldByName('RdelON').AsInteger=1);

      if (ResCode in [resAdded, resNotWrong]) then begin
        pMfID  := ORD_IBS.FieldByName('Rmf').AsInteger;
        pONum  := ORD_IBS.FieldByName('Ronum').AsString;
        srcID  := ORD_IBS.FieldByName('Rsrc').AsInteger;
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
//---------------------------------------------------------- ������������ ��� ��
    OrigNum:= GetOriginalNum(onID);
    if (ResCode in [resAdded, resNotWrong]) then begin //--------------- ���������
      if not Assigned(OrigNum) then begin // ���� ����� �� - �������
        OrigNum:= AddNewOrigNumToCache(onID, pMfID, pONum);
        if Manufacturers.ManufExists(pMfID) then try // ������������ ������ �� �������������
          Manufacturers.CS_Mfaus.Enter;
          Manufacturers[pMfID].ManufSearchONlist.AddObject(pONum, Pointer(onID));
        finally
          Manufacturers.CS_Mfaus.Leave;
        end;
      end;
      fadd:= Ware.IsMarketWare();
      if fadd then begin
        pONumLinks.AddLinkListItem(TLink.Create(srcID, OrigNum), lkLnkByID, Ware.CS_wlinks); // ���.������ � ������
        with OrigNum.Links do begin                 // ���.������ � ����.������
          CheckLink(WareID, srcID, Ware);
          if (LinkCount>1) then SortByLinkName;
        end;
      end;

    end else if (ResCode in [resDeleted, resWrong]) then begin //------- �������
      pONumLinks.DelLinkListItemByID(onID, lkLnkByID, Ware.CS_wlinks); // ����.������ � ������
      OrigNum.Links.DeleteLinkItem(WareID); // ����.������ � ����.������
      if flDelON and Manufacturers.ManufExists(pMfID) then try // ������������ ������ �� �������������
        Manufacturers.CS_Mfaus.Enter;
        with Manufacturers[pMfID].ManufSearchONlist do // ������� ��
        if Find(pONum, srcID) and (Integer(Objects[srcID])=onID) then Delete(srcID);
      finally
        Manufacturers.CS_Mfaus.Leave;
      end;
    end;

  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+' (Ware='+IntToStr(WareID)+fnIfStr(pONum='', '', ' ONum='+pONum)+
      fnIfStr(onID<1, '', ' onID='+IntToStr(onID))+'): '+CutEMess(E.Message, ResCode);
  end;
end;
//========================================= ���������� ���� ������������ �������
procedure TDataCacheAdditionASON.FillOriginalNums(fFill: Boolean=True);
const nmProc = 'FillOriginalNums'; // ��� ���������/�������
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    i, j, iCount, delCount, imfau: Integer;
    localStart: TDateTime;
    snum: String;
begin
  if not Assigned(self) then Exit;
  OrdIBS:= nil;
  localStart:= Now;
  iCount:= 0;
  delCount:= 0;
  try
    OrdIBD:= cntsOrd.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, -1, tpRead, true);
      OrdIBS.SQL.Text:= 'select ORNWCODE, ORNWMFAUCODE, ORNWORIGNUMWARE'+
        ' from ORIGINALNUMWARE where exists(select * from originallinkware'+
        '  inner join wareoptions on wowarecode=orlkcodeware and woarhived="F"'+
        '  where orlkonumcode=ORNWCODE and orlkwrong="F")'+
        ' ORDER BY ORNWMFAUCODE, ORNWORIGNUMWARE';
      OrdIBS.ExecQuery;
      if not fFill then for i:= 1 to High(FarOriginalNumInfo) do
        if Assigned(FarOriginalNumInfo[i]) then FarOriginalNumInfo[i].State:= False;

      while not OrdIBS.Eof do begin
        imfau:= OrdIBS.fieldByName('ORNWMFAUCODE').AsInteger;
        if not ManufAutoExist(imfau) then begin
          TestCssStopException;
          while not OrdIBS.Eof and (imfau=OrdIBS.fieldByName('ORNWMFAUCODE').AsInteger) do OrdIBS.Next;
          Continue;
        end;
        while not OrdIBS.Eof and (imfau=OrdIBS.fieldByName('ORNWMFAUCODE').AsInteger) do begin
          i:= OrdIBS.fieldByName('ORNWCODE').AsInteger;
          snum:= OrdIBS.fieldByName('ORNWORIGNUMWARE').AsString;
          if not OrigNumExist(i) then
            AddNewOrigNumToCache(i, imfau, snum, 1000)
          else with FarOriginalNumInfo[i] do try
            CS_OrigNums.Enter;
            MfAutoID:= imfau;
            OriginalNum:= snum;
            State:= True;
          finally
            CS_OrigNums.Leave;
          end;
          cntsORD.TestSuspendException;
          OrdIBS.Next;
          inc(iCount);
        end; // while... imfau= ...
      end; // while not OrdIBS.Eof
    finally
      prFreeIBSQL(OrdIBS);
      cntsOrd.SetFreeCnt(OrdIBD, True);
    end;

    if not fFill then for i:= 1 to High(FarOriginalNumInfo) do
      if Assigned(FarOriginalNumInfo[i]) and not FarOriginalNumInfo[i].State then begin
        with FarOriginalNumInfo[i].Links do for imfau:= LinkCount-1 downto 0 do begin
          j:= GetLinkID(ListLinks[imfau]);
          with Cache do if WareExist(j) then with GetWare(j) do
            ONumLinks.DelLinkListItemByID(i, lkLnkByID, CS_wlinks);
        end;
        CS_OrigNums.Enter;
        try
          prFree(FarOriginalNumInfo[i]);
          inc(delCount);
        finally
          CS_OrigNums.Leave;
        end;
      end;
    imfau:= Length(FarOriginalNumInfo);
    for i:= High(FarOriginalNumInfo) downto 1 do if Assigned(FarOriginalNumInfo[i]) then begin
      imfau:= FarOriginalNumInfo[i].ID+1;
      break;
    end;
    if (Length(FarOriginalNumInfo)>imfau) then try
      CS_OrigNums.Enter;  // Critical start
      SetLength(FarOriginalNumInfo, imfau); // �������� �� ���.����
    finally
      CS_OrigNums.Leave;  // Critical end
    end;

  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prMessageLOGS(nmProc+': '+IntToStr(iCount)+' ��'+
    fnIfStr(delCount=0, '', ', del '+IntToStr(delCount))+' - '+
    GetLogTimeStr(LocalStart), fLogCache , false); // ����� � log
  TestCssStopException;
end;
//================ ���������� / �������� ������ ������� � ������������� ��������
procedure TDataCacheAdditionASON.FillWareONLinks(fFill: Boolean=True; sLog: String='');
const nmProc='FillWareONLinks';
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    i, j, errCount, WareID, OrigNumID, pSrcID, jj, iLinks, mf, ii, MaxLinksWithOE: Integer;
    LocalStart: TDateTime;
    OrigNum: TOriginalNumInfo;
    Ware: TWareInfo;
    link: TLink;
    body, lst, lstM: TStringList;
    s: String;
    flMfLst, flLoad: Boolean;
    manuf: TManufacturer;
begin
  if not Assigned(self) or not Assigned(Cache) then Exit;
  LocalStart:= Now;
  ORDIBS:= nil;
  body:= nil;
  lstM:= nil;
  manuf:= nil;
  iLinks:= 0;
  lst:= TStringList.Create;
  try
    MaxLinksWithOE:= Cache.GetConstItem(pcONwareLinksLimit).IntValue;
    if not fFill then begin
      with Cache do for i:= 1 to High(arWareInfo) do if WareExist(i) then
        with GetWare(i) do if not IsArchive then ONumLinks.SetLinkStates(False, CS_wlinks);
      for i:= 1 to length(arOriginalNumInfo)-1 do
        if OrigNumExist(i) then arOriginalNumInfo[i].Links.SetLinkStates(False);
      Manufacturers.SetStates(False);
    end;
    OrdIBD:= cntsOrd.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, -1, tpRead, true);
      OrdIBS.SQL.Text:= 'select ORNWCODE, ORNWMFAUCODE, ORLKCODEWARE, ORLKSOURCECODE'+
        ' from ORIGINALNUMWARE inner join ORIGINALLINKWARE on ORLKONUMCODE=ORNWCODE'+
        ' inner join WareOptions on wowarecode=ORLKCODEWARE and WOARHIVED="F"'+
        ' where ORLKWRONG="F" ORDER BY ORNWMFAUCODE, ORNWORIGNUMWARE';
{       'select ORNWMFAUCODE, ORNWCODE, ORLKCODEWARE,'+
        ' ORLKSOURCECODE from (select ORNWMFAUCODE, ORNWCODE'+
        ' from ORIGINALNUMWARE ORDER BY ORNWMFAUCODE, ORNWORIGNUMWARE)'+
        ' inner join ORIGINALLINKWARE on ORLKONUMCODE=ORNWCODE and ORLKWRONG="F"'+
        ' inner join WareOptions on wowarecode=ORLKCODEWARE and WOARHIVED="F"';}
      OrdIBS.ExecQuery;             // select count (*) from ORIGINALLINKWARE where ORLKONUMCODE=1
      j:= 0; // �������            // update ORIGINALLINKWARE set ORLKWRONG="T" where ORLKONUMCODE=1
      errCount:= 0;
      jj:= 0;
      while not OrdIBS.EOF do begin
        mf:= OrdIBS.FieldByName('ORNWMFAUCODE').AsInteger;
        flMfLst:= ManufAutoExist(mf); // ������� ���������� ������ ��
        if flMfLst then begin
          lst.Clear; // ��������������� ������ �� �������������
          manuf:= Manufacturers[mf];
          lstM:= manuf.ManufSearchONlist;
          if fFill then lstM.Sorted:= False; // ���������� - ��������� ����������
        end;
        //---------------------------------------- ������������ 1 �������������
        while not OrdIBS.EOF and (mf=OrdIBS.FieldByName('ORNWMFAUCODE').AsInteger) do begin

          OrigNumID:= OrdIBS.FieldByName('ORNWCODE').AsInteger;
          if not OrigNumExist(OrigNumID) then begin
            while not OrdIBS.EOF and (OrigNumID=OrdIBS.FieldByName('ORNWCODE').AsInteger) do begin
              inc(errCount);
              cntsORD.TestSuspendException;
              OrdIBS.Next;
            end;
            Continue;
          end;

          OrigNum:= GetOriginalNum(OrigNumID);
          i:= 0; // ������� ������� �� 1 ����.������
          if not fFill then iLinks:= OrigNum.Links.LinkCount;
          //---------------------------------------- ������������ 1 ����.�����
          while not OrdIBS.EOF and (mf=OrdIBS.FieldByName('ORNWMFAUCODE').AsInteger)
            and (OrigNumID=OrdIBS.FieldByName('ORNWCODE').AsInteger) do begin
            WareID:= OrdIBS.FieldByName('ORLKCODEWARE').AsInteger;

            if Cache.WareExist(WareID) then begin
              Ware:= Cache.GetWare(WareID);

              flLoad:= Cache.AllowWebArm or (Cache.AllowWeb and Ware.IsMarketWare);

              if (Ware.PgrID>0) and flLoad then begin
                pSrcID:= OrdIBS.FieldByName('ORLKSOURCECODE').AsInteger;

                with Ware.ONumLinks do begin
                  if fFill or not LinkListItemExists(OrigNumID, lkLnkByID) then begin
                    link:= TLink.Create(pSrcID, OrigNum);
                    AddLinkListItem(link, lkLnkByID, Ware.CS_wlinks);
                  end else begin
                    link:= GetLinkListItemByID(OrigNumID, lkLnkByID);
                    if link.SrcID<>pSrcID then link.SrcID:= pSrcID;
                    link.State:= True;
                  end;
                end;
                                       // ���� ���-�� ������ ������ ������������
                if (OrigNum.Links.LinkCount<MaxLinksWithOE) then begin
                  if fFill then OrigNum.Links.AddLinkItem(TLink.Create(pSrcID, Ware))
                  else OrigNum.Links.CheckLink(WareID, pSrcID, Ware);
                end;
                inc(i);
                inc(j);
                if Ware.IsMOTOWare then inc(jj);
              end else inc(errCount); // if (Ware.PgrID>0) and ...
            end else inc(errCount); // if WareExist ...

            cntsORD.TestSuspendException;
            OrdIBS.Next;
          end; // while ... (OrigNumID=

          if (fFill or (iLinks<OrigNum.Links.LinkCount)) then  // ���� ���-�� ����������
            OrigNum.Links.SortByLinkName;      // ��������� ������

          // �������� ��������� � ���������� ������.���-�� ������ �� ����.�����
          if (i>MaxLinksWithOE) then try
            body:= TStringList.Create;
            body.Add('�� ����.����� '+OrigNum.OriginalNum+' (��� '+IntToStr(OrigNum.ID)+')');
            body.Add(' � ���� '+IntToStr(i)+' ������');
            body.Add(' � ��� �������� '+IntToStr(MaxLinksWithOE));
            s:= n_SysMailSend(fnGetSysAdresVlad(caeOnlyWorkDay),
              '����������� �� ������ ���������� ����', Body, nil,  '', '', True);
            if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then // ���� ������ �� �������� � ����
              prMessageLOGS(nmProc+'(send mail to admin): '+s);
          finally
            prFree(body);
          end;

          if flMfLst and (i>0) then begin // ��������� � ������, ���� ���� ������
            if fFill then body:= lstM else body:= lst;
            if (body.Capacity=body.Count) then body.Capacity:= body.Capacity+1024;
            body.AddObject(OrigNum.OriginalNum, Pointer(OrigNum.ID));
          end;
        //---------------------------------------- ���������� 1 ����.�����
        end; // while not OrdIBS.EOF and (mf=

        if flMfLst then try
          Manufacturers.CS_Mfaus.Enter;
          if fFill then begin
            lstM.Sort;
            lstM.Sorted:= True;  // ���������� - �������� ����������
          end else begin // �������� - ���������� ������ ��
            lst.Sort;             // �� lstM ������� ��, ��� ����
            lst.Sorted:= True;    // � lst ��������� ��, ��� ���� ��������
            for i:= lstM.Count-1 downto 0 do
              if lst.Find(lstM[i], ii) then lst.Delete(ii) else lstM.Delete(i);
            if lst.Count>0 then  // ����������
              for i:= 0 to lst.Count-1 do lstM.AddObject(lst[i], lst.Objects[i]);
          end;
          lstM.Capacity:= lstM.Count;
          manuf.State:= True;
        finally
          Manufacturers.CS_Mfaus.Leave;
        end;
      //---------------------------------------- ���������� 1 �������������
      end; //  while not OrdIBS.EOF
    finally
      prFreeIBSQL(OrdIBS);
      cntsOrd.SetFreeCnt(OrdIBD, True);
    end;
    sLog:= sLog+IntToStr(j)+' ����.'+
      fnIfStr(errCount=0, '', '/����� '+IntToStr(errCount))+'/m-'+IntToStr(jj);

    if not fFill then begin  // ������� ������������� �����
      with Cache do for i:= 1 to High(arWareInfo) do if WareExist(i) then
         with GetWare(i) do if not IsArchive then ONumLinks.DelNotTestedLinks(CS_wlinks);
      for i:= 1 to High(arOriginalNumInfo) do if OrigNumExist(i) then
        arOriginalNumInfo[i].Links.DelNotTestedLinks;

      lst.Clear; // ������ ������������� ������ ��
      lst:= Manufacturers.GetNotTestedList;
      for i:= 0 to lst.Count-1 do begin
        mf:= Integer(lst.Objects[i]);
        if not ManufAutoExist(mf) then Continue;
        manuf:= Manufacturers[mf];
        if manuf.State then Continue;
        with manuf.ManufSearchONlist do if (Count>0) then try
          Manufacturers.CS_Mfaus.Enter;
          Clear;
        finally
          Manufacturers.CS_Mfaus.Leave;
        end;
        TestCssStopException;
      end;
    end; // if not fFill
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFree(lst);
  prMessageLOGS(nmProc+': '+sLog+' - '+
    GetLogTimeStr(LocalStart), fLogCache, false); // ����� � log
  TestCssStopException;
end;
//============================== ���������� ������� ����������� ���������� �����
procedure TDataCacheAdditionASON.FillSourceLinks;
const nmProc = 'FillSourceLinks'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    p: Pointer;
    i, j, k: Integer;
    arANDTCODEs: Tai;
    arAnDtNames: Tas;
    s: String;
begin
  if not Assigned(self) then Exit;
//  ibd:= nil;
  ibs:= nil;
  SetLength(arANDTCODEs, 0);
  SetLength(arAnDtNames, 0);
  j:= 0;
  try try
    ibd:= cntsGRB.GetFreeCnt;
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibsGRB_'+nmProc, -1, tpRead, true);
      ibs.SQL.Text:=  'select ANDTCODE, AnDtName, (AnDtSyncCode-'+
                      Cache.GetConstItem(pcCrossAnalogsDeltaSync).StrValue+') SyncCode'+
                      ' from (select AnTpCode XDict, a1.AnDtCode XMaster from AnalitType'+
                      '  left join AnalitDict a1 on a1.AnDtAnalitTypeCode=AnTpCode'+
                      '  where AnTpLinkDictType=154 and a1.AnDtMasterCode is null)'+
                      ' left join AnalitDict on AnDtAnalitTypeCode=XDict'+
                      '  and AnDtMasterCode=XMaster order by AnDtSyncCode';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        j:= ibs.fieldByName('SyncCode').AsInteger;
        if (j>0) then begin
          if (High(arANDTCODEs)<j) then begin
            SetLength(arANDTCODEs, j+10);
            for i:= j to High(arANDTCODEs) do arANDTCODEs[j]:= 0;
            SetLength(arAnDtNames, j+10);
            for i:= j to High(arAnDtNames) do arAnDtNames[j]:= '';
          end;
          arANDTCODEs[j]:= ibs.fieldByName('ANDTCODE').AsInteger;
          arAnDtNames[j]:= ibs.fieldByName('AnDtName').AsString;
        end;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
      if High(arANDTCODEs)>j then begin
        SetLength(arANDTCODEs, j+1);
        SetLength(arAnDtNames, j+1);
      end;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(ibd);
    end;

    ibd:= cntsOrd.GetFreeCnt;
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibsOrd_'+nmProc, -1, tpRead, true);
      ibs.SQL.Text:= 'Select SRCLCODE, SRCLNAME, SRCLDELKIND FROM SOURCELINK';
// SRCLDELKIND - ����� �������� ������: 0 - ������� ������ (������ ����, Excel � �.�.), 1 - �������� ��� �������� (�� TecDoc � �.�.)
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('SRCLCODE').AsInteger;
        j:= 0;
        k:= ibs.fieldByName('SRCLDELKIND').AsInteger;
        s:= ibs.fieldByName('SRCLNAME').AsString;
        if (i<Length(arANDTCODEs)) and (arANDTCODEs[i]>0) then begin  // ����� ��������������� ��������
          j:= arANDTCODEs[i];
          arANDTCODEs[i]:= 0;
          arAnDtNames[i]:= '';
        end;
        if not FLinkSources.ItemExists(i) then begin
          p:= TSubDirItem.Create(i, j, k, s);
          FLinkSources.CheckItem(p);
        end else with TSubDirItem(FLinkSources[i]) do begin
          if Name<>s then Name:= s;
          if SubCode<>j then SubCode:= j;
          if OrderNum<>k then OrderNum:= k;
          State:= True;
        end;
        cntsORD.TestSuspendException;
        ibs.Next;
      end;

      j:= 0; // ���������, �� ��������� �� ����� ��������� � Grossbee
      for i:= 0 to High(arANDTCODEs) do
        if (arANDTCODEs[i]>0) and (arAnDtNames[i]<>'') then begin
          Inc(j);
          break;
        end;
      if (j>0) then begin // ���� ��������� - ��������� � SOURCELINK
        fnSetTransParams(ibs.Transaction, tpWrite, True);
        ibs.SQL.Text:= 'insert into SOURCELINK'+
                       '(SRCLCODE, SRCLNAME) values (:srcode, :srname)';
        for i:= 0 to High(arANDTCODEs) do
          if (arANDTCODEs[i]>0) and (arAnDtNames[i]<>'') then begin
            ibs.ParamByName('srcode').AsInteger:= i;
            ibs.ParamByName('srname').AsString:= arAnDtNames[i];
            ibs.ExecQuery;
            ibs.Close;
          end;
        ibs.Transaction.Commit;

        for i:= 0 to High(arANDTCODEs) do
          if (arANDTCODEs[i]>0) and (arAnDtNames[i]<>'') then begin
            p:= TSubDirItem.Create(i, arANDTCODEs[i], 0, arAnDtNames[i]);
            FLinkSources.CheckItem(p);
          end;
      end; // if (j>0)
      FLinkSources.DelDirNotTested;
    finally
      prFreeIBSQL(ibs);
      cntsOrd.SetFreeCnt(ibd);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  finally
    SetLength(arANDTCODEs, 0);
    SetLength(arAnDtNames, 0);
  end;
{  if flDebug then with FLinkSources do for i:= 0 to ItemsList.Count-1 do  // ��� �������
    prMessageLOGS(nmProc+': id='+IntToStr(TSubDirItem(ItemsList[i]).ID)+
      ' sub='+IntToStr(TSubDirItem(ItemsList[i]).SubCode)+
      ' nm='+TSubDirItem(ItemsList[i]).Name, fLogDebug, false);      }
  TestCssStopException;
end;
//================================= �������� ������ ������������� ������ �� ����
function TDataCacheAdditionASON.GetOriginalNum(ID: Integer): TOriginalNumInfo;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if OrigNumExist(ID) then Result:= FarOriginalNumInfo[ID];
end;
//============================== �������� ������������ ������� ��������� �������
function TDataCacheAdditionASON.ManufAutoExist(ID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= Manufacturers.ManufExists(ID);
end;
//==============================================================================
function TDataCacheAdditionASON.OrigNumExist(ID: Integer): Boolean;
begin
  Result:= Assigned(self) and (ID>0) and
    (length(FarOriginalNumInfo)>ID) and Assigned(FarOriginalNumInfo[ID]);
end;
//==============================================================================
function TDataCacheAdditionASON.SourceLinkExist(ID: Integer): Boolean;
begin
  Result:= Assigned(self) and LinkSources.ItemExists(ID);
end;
//=================================================== ����� ������������� ������
function TDataCacheAdditionASON.SearchOriginalNum(Manuf: Integer; OrigNum: String): Integer;
// Result - ��� (������), ���� � ���� ���, -1
var i: Integer;
begin
  Result:= -1;
  if not Assigned(self) or (Trim(OrigNum)='') or not ManufAutoExist(Manuf) then Exit;
  OrigNum:= AnsiUpperCase(OrigNum);
  with Manufacturers[Manuf].ManufSearchONlist do
    if (Count>0) and Find(OrigNum, i) then Result:= Integer(Objects[i]);
end;
//====================================== ����� ������������� ������ �� ���������
function TDataCacheAdditionASON.SearchWareOrigNums(Template: String; // must Free
         IgnoreSpec: Integer; sortManuf: Boolean; var TypeCodes: Tai): Tai;
// ���������� ������ ����� ����.�������, ��������������� �� ������������, ������� ������
// ���� TypeCodes ������ - � TypeCodes �������� ����
// ���� TypeCodes �� ������ - ����� ���-��� ������ �� �����
var i, j, pType: Integer;
    s: String;
    flTypeSelection, flSelecting, flContaining: boolean;
    arTypes: Tai;
begin
  SetLength(Result, 0);
  if not Assigned(TypeCodes) then SetLength(TypeCodes, 0);
  if not Assigned(self) then Exit;
  Template:= AnsiUpperCase(fnDelSpcAndSumb(Template));
  if Template='' then Exit;
  flTypeSelection:= (Length(TypeCodes)>0); // ������� - ��������� �� TypeCodes ��� �������� ���� � TypeCodes
  with fnCreateStringList(False, dupAccept, 100) do try
    for i:= 1 to length(FarOriginalNumInfo)-1 do if OrigNumExist(i) then
      with FarOriginalNumInfo[i] do if Assigned(Links) and
        (Links.LinkCount>0) and (pos(Template, OriginalNum)>0) then begin
        flSelecting:= not flTypeSelection; // True ��� ���������� ������, False ��� ������
        try
          arTypes:= GetAnalogTypes; // ������ ����� ����� �������� (� �������)
          for j:= 0 to High(arTypes) do begin // ���������� ���� ��������
            pType:= arTypes[j];
            flContaining:= (fnInIntArray(pType, TypeCodes)>-1);
            if flTypeSelection and flContaining then begin
              flSelecting:= True;                    // ����� � ��� ���� � ������� �����
              break;
            end else if not flTypeSelection and not flContaining then
              prAddItemToIntArray(pType, TypeCodes); // ��������� ����� - �������� ����
          end;
        finally
          SetLength(arTypes, 0);
        end;
        if not flSelecting then Continue; // ���� �� �������� �� ����� ��� ������

        if sortManuf then s:= SortString else s:= OriginalNum;
        AddObject(s, Pointer(i));
      end; // with FarOriginalNumInfo[i]
    if Count>1 then Sort;
    if Count>0 then begin
      SetLength(Result, Count);
      for i:= 0 to Count-1 do Result[i]:= Integer(Objects[i]);
    end;
  finally Free; end;
end;
//=========================================== �������� ������ �������� �� ������
//============================= ������������ ������� � ������ ������������� ����
function TDataCacheAdditionASON.fnGetListAnalogsWithManufacturer(
         pWareID, pManufID: Integer; var pAr1, pAr2: Tai): Integer;
const nmProc = 'fnGetListAnalogsWithManufacturer';
//{ pWareID - ��� ������, pManufID - ��� ������������� ����, ( -1 - �� ���������)
//  pAr1 - ���� ������� �������� �� ����.������ � ManufID
//  pAr2 - ���� ������� �������� �� ����.������
//  Result = 0 - ��������� �����
var i, j, idxAn, idxOE: Integer;
    lst1, lst2: TStringList;
//    TimeSection: TDateTime;
    arON, arW: Tai;
    flManuf: Boolean;
begin
//  TimeSection:= now;
  Result:= 0;
  SetLength(pAr1, 0);
  SetLength(pAr2, 0);
  if not Assigned(self) then Exit;
  lst1:= nil;
  lst2:= nil;
  try       // ������ ������������ �������, �� ������� ��������� �����
    if not Cache.WareExist(pWareID) then
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)))
    else if (pManufID>0) and not (ManufAutoExist(pManufID)) then
      raise Exception.Create('�� ������ ������., ���='+IntToStr(pManufID));
    SetLength(arON, 0);

    lst1:= fnCreateStringList(True, dupIgnore, 50);
    lst2:= fnCreateStringList(True, dupIgnore, 50);

    with Cache.GetWare(pWareID) do if IsArchive then
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)))
    else arON:= ONumLinks.GetLinkListCodes(lkLnkByID); // ���� ����.�������

    for i:= Low(arON) to High(arON) do begin
      idxOE:= arON[i];
      if not OrigNumExist(idxOE) then Continue;
      flManuf:= (pManufID>0) and (FarOriginalNumInfo[idxOE].MfAutoID=pManufID);

      SetLength(arw, 0); // ���� ������� ������� ��������� �� ������������ �����
      arW:= FarOriginalNumInfo[idxOE].Links.GetLinkCodes;
      for j:= Low(arW) to High(arW) do begin
        idxAn:= arW[j];
        if not Cache.WareExist(idxAn) or (idxAn=pWareID) then Continue;
        with Cache.GetWare(IdxAn) do if IsArchive then Continue
        else if flManuf then lst1.AddObject(Name, Pointer(IdxAn))
        else lst2.AddObject(Name, Pointer(IdxAn));
      end;
    end;

    SetLength(pAr1, lst1.Count);
    for i:= 0 to lst1.Count-1 do begin
      pAr1[i]:= Integer(lst1.Objects[i]);
      j:= lst2.IndexOfObject(lst1.Objects[i]);
      if j>-1 then lst2.Delete(j);
    end;
    SetLength(pAr2, lst2.Count);
    for i:= 0 to lst2.Count-1 do pAr2[i]:= Integer(lst2.Objects[i]);
    Result:= Length(pAr1)+Length(pAr2);
  except
    on E: Exception do begin
      Result:= 0;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  prFree(lst1);
  prFree(lst2);
  SetLength(arON, 0);
  SetLength(arW, 0);
//  prMessageLOGS(nmProc+' : '+GetLogTimeStr(TimeSection), fLogCache, false);
end;
//====================================================== ���������� ������ �����
procedure TDataCacheAdditionASON.FillTreeNodesAuto;
const nmProc = 'FillTreeNodesAuto';
var TimeProc: TDateTime;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    i, j, k, MeasCode, Code, CodeParent, sysID, pMainCode, pCodeTD: Integer;
    pName, pNameSys, s: String;
    TempList: TList;
    pIsGATD, pVisible: Boolean;
    pNode: TAutoTreeNode;
begin
  if not Assigned(self) then Exit;
  TimeProc:= Now;
  ORD_IBS:= nil;
  ORD_IBD:= nil;
  TempList:= TList.Create;
  j:= 0; // ����� �������
  try
    ORD_IBD:= cntsORD.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
    ORD_IBS.SQL.Text:= 'select * from TREENODESAUTO'+
      ' order by TRNADTSYCODE, TRNACODEPARENT, TRNACODE';
    ORD_IBS.ExecQuery;

    while not ORD_IBS.Eof do begin
      sysID:= ORD_IBS.FieldByName('TRNADTSYCODE').asInteger;
//--------------------------------------------------------- 1 ������ = 1 �������
      if TempList.Count>0 then TempList.Clear; // ������ ������� �����
      while not ORD_IBS.Eof and (sysID=ORD_IBS.FieldByName('TRNADTSYCODE').asInteger) do begin
        Code      := ORD_IBS.FieldByName('TRNACODE').asInteger;
        CodeParent:= ORD_IBS.FieldByName('TRNACODEPARENT').asInteger;
        pName     := ORD_IBS.FieldByName('TRNANAME').asString;
        pNameSys  := ORD_IBS.FieldByName('TRNANAMESYS').asString; // ������� �������� ���� � ������ � ����
        MeasCode  := ORD_IBS.FieldByName('TRNAMEASCODE').asInteger;
        pMainCode := ORD_IBS.FieldByName('TRNAMainCode').asInteger;
        pCodeTD   := ORD_IBS.FieldByName('TRNATDCODE').asInteger;
        pVisible  := GetBoolGB(ORD_IBS, 'TRNAVISIBLE');
        pIsGATD   := GetBoolGB(ORD_IBS, 'TRNATDGA');

        s:= AutoTreeNodesSys[sysID].NodeAdd(Code, CodeParent, MeasCode,
            pName, pNameSys, pMainCode, pCodeTD, pIsGATD, pVisible, False, False);
        if s<>'' then begin // ���� �� ���������� - ���������� � ������
          pNode:= TAutoTreeNode.Create(Code, CodeParent, MeasCode, sysID,
                  pName, pNameSys, pMainCode, pCodeTD, pIsGATD, pVisible);
          TempList.Add(pNode)
        end else inc(j); // ������� ���������� ����

        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end; // while ...DTSYCode=...

      k:= 0; // ������� ��������
      if TempList.Count>0 then repeat // ����� �� ������ ������� �����
        for i:= TempList.Count-1 downto 0 do

          if not Assigned(TempList[i]) then TempList.Delete(i)
          else begin
            pNode:= TempList[i];
  //            TreeNodes.CheckItem(pNode);
            Code:= pNode.ID;  // ����� ��� var ���������
            with pNode do     // ����� ������� �������� ���� � ������
              s:= AutoTreeNodesSys[sysID].NodeAdd(Code, ParentID, MeasID, Name,
                NameSys, MainCode, SubCode, IsGATD, Visible, False, False);
            if s='' then begin // ���� ����������
              inc(j);          // ������� ���������� ����
              prFree(pNode);      // ������ ������� ������
              TempList.Delete(i);
            end;
          end; // for

        inc(k);
      until (TempList.Count<1) or (k>RepeatCount); // ���� ��� �� �������, �� �� ����� RepeatCount ��������

      if (TempList.Count>0) then begin // ���� �� ��� ���� - ����� � ���
        prMessageLOGS(nmProc+': ������ ������ � ��� '+IntToStr(TempList.Count)+' �����:', fLogCache, false);
        for i:= TempList.Count-1 downto 0 do begin
          pNode:= TAutoTreeNode(TempList[i]);
          prMessageLOGS(nmProc+':    ��� ���� -'+IntToStr(pNode.ID)+', '+pNode.Name, fLogCache, false);
          prFree(pNode);
        end;
      end;

      with FAutoTreeNodesSys[sysID] do FillNodesList; // ��������� ������ ��������������� ����� �������
//--------------------------------------------------------- 1 ������ = 1 �������
    end; //  while not ORD_IBS.Eof
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  prFree(TempList);
  prMessageLOGS(nmProc+': '+IntToStr(j)+' ����� - '+GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;
//=========================================== ���������� �������� � ������ �����
function TDataCacheAdditionASON.TreeNodeAdd(pTypeSys, pParentID, pMainCode: Integer;
         pNodeName, pNodeNameSys: String; pUserID: Integer; var pNodeID: Integer;
         pVisible: Boolean=True; pMeasID: Integer=0; pCodeTD: Integer=0; pIsGATD: Boolean=False): String;
const nmProc = 'TreeNodeAdd';
var NodeAuto, NodeParent: TAutoTreeNode;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    errmess: String;
    kind: Integer;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  kind:= -1;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrAddRecord));
    if not CheckTypeSys(pTypeSys) then
      raise Exception.Create(MessText(mtkNotFoundTypeSys, IntToStr(pTypeSys)));

    pNodeNameSys:= AnsiUpperCase(pNodeNameSys);
    if (pNodeID<1) then pNodeID:= -1;
    errmess:= FAutoTreeNodesSys[pTypeSys].NodeValidCheckForAdd(
           pNodeID, pParentID, pNodeName, pNodeNameSys, NodeAuto, NodeParent);
    if (errmess<>'') then raise Exception.Create(errmess);

    ORD_IBD:= cntsORD.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True); // ���������� � ����
      ORD_IBS.SQL.Text:= 'select * from CheckTreeNode('+IntToStr(pTypeSys)+', '+
        IntToStr(pUserID)+', '+IntToStr(pCodeTD)+', '+IntToStr(pMainCode)+', '+
        IntToStr(pMeasID)+', '+IntToStr(pParentID)+', '+fnIfStr(pIsGATD, '"T", ', '"F", ')+
        fnIfStr(pVisible, '"T", ', '"F", ')+':TRNANAME, :TRNANAMESYS)';
      ORD_IBS.ParamByName('TRNANAME').AsString:= pNodeName;
      ORD_IBS.ParamByName('TRNANAMESYS').AsString:= pNodeNameSys;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
        kind:= ORD_IBS.FieldByName('rKind').asInteger; // kind= 0 - ������ �� ��������, 1 - ���� ����������
        pNodeID:= ORD_IBS.FieldByName('rNode').asInteger;
        pCodeTD:= ORD_IBS.FieldByName('rNodeTD').asInteger;
        pMainCode:= ORD_IBS.FieldByName('rNodeMain').asInteger;
        pMeasID:= ORD_IBS.FieldByName('rmeasID').asInteger;
        pParentID:= ORD_IBS.FieldByName('rParent').asInteger;
        pIsGATD:= ORD_IBS.FieldByName('rIsGa').AsString='T';
        pVisible:= ORD_IBS.FieldByName('rIsVis').AsString='T';
        pNodeName:= ORD_IBS.FieldByName('rNodeName').AsString;
        pNodeNameSys:= ORD_IBS.FieldByName('rSysName').AsString;
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if (pNodeID<1) then raise Exception.Create('pNodeID<1');
    if (pMainCode<1) then pMainCode:= pNodeID;             // ���������� � ������

    if (kind=0) and FAutoTreeNodesSys[pTypeSys].NodeExists(pNodeID) then
      with FAutoTreeNodesSys[pTypeSys][pNodeID] do begin
        if FMainCode<>pMainCode then NodeAuto.FMainCode:= pMainCode;
        if FParCode<>pParentID then FParCode:= pParentID;
        if FSubCode<>pCodeTD then FSubCode:= pCodeTD;
        if FMeasID<>pMeasID then FMeasID:= pMeasID;
        if IsGATD<>pIsGATD then IsGATD:= pIsGATD;
        if IsVisible<>pVisible then IsVisible:= pVisible;
        if Name<>pNodeName then Name:= pNodeName;
        if FNameSys<>pNodeNameSys then FNameSys:= pNodeNameSys;
      end
    else
      Result:= FAutoTreeNodesSys[pTypeSys].NodeAdd(pNodeID, pParentID, pMeasID,
        pNodeName, pNodeNameSys, pMainCode, pCodeTD, pIsGATD, pVisible, True, True);
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//================== must Free, ������ �������� �������� ���� ������ / ���������
function TDataCacheAdditionASON.GetModelOrEngNodeFiltersList(NodeID, pID: integer; IsEngine: Boolean=False): TStringList;
const nmProc='GetModelOrEngNodeFiltersList';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    iVal: Integer;
    sVal: string;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
      if IsEngine then sVal:= 'GetEngNodeFilters' else sVal:= 'GetModelNodeFilters';
      ORD_IBS.SQL.Text:= 'select * from '+sVal+'('+IntToStr(NodeID)+', '+IntToStr(pID)+')'; //
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iVal:= ORD_IBS.fieldByName('Rwcws').asInteger;
        sVal:= ORD_IBS.fieldByName('Rvalue').AsString;
        Result.AddObject(sVal, Pointer(iVal));
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
      Result.Clear;
    end;
  end;       // ���� ������� ������ �� ������� - ������������ ��� 
  if not IsEngine and (Result.Count<1) and Models.ModelExists(pID) then
    with Models[pID] do if NodeLinks.LinkExists(NodeID) then
      TSecondLink(NodeLinks[NodeID]).NodeHasFilters:= False;
end;

//******************************************************************************
//                          TModelLine - ��������� ���
//******************************************************************************
//========= ���������� TStringList ������� - ��������� + ������.� + ������������
function ModelsSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var i1, i2: integer;
    Model1, Model2: TModelAuto;
begin
  with Cache.FDCA do try
    Model1:= Models[Integer(List.Objects[Index1])];
    Model2:= Models[Integer(List.Objects[Index2])];
    if (Model1.IsVisible=Model2.IsVisible) then begin
      i1:= Model1.ModelOrderNum;
      i2:= Model2.ModelOrderNum;
      if i1=i2 then Result:= AnsiCompareText(Model1.SortName, Model2.SortName)
      else if i1<i2 then Result:= -1 else Result:= 1;
    end else if Model1.IsVisible then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;
//==============================================================================
constructor TModelLine.Create(pMLineID, pTDcode, pMFAID: Integer; pName: String);
begin
  Inherited Create(pMLineID, pTDcode, 0, pName);
  FParCode:= pMFAID;
//  FMLHasWares:= False;
  FMLModelsSort:= fnCreateStringList(False, LCharUpdate);  // ������ ������� ���������� ����
  FMLModelsTopUp:= fnCreateStringList(False, LCharUpdate); // ������ ������� ���������� ���� � ������ ������
end;
//==============================================================================
destructor TModelLine.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FMLModelsSort);
  prFree(FMLModelsTopUp);
  inherited Destroy;
end;
//================================================================= �������� ���
function TModelLine.GetIntML(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: begin                    // ���������� ������� ���������� ����
           CheckModelsLists;
           Result:= FMLModelsSort.Count;
         end;
    ik8_2: Result:= FParCode;       // ��� ������������� ����
    ik8_3: Result:= FYStart;        // ��� ������ ������������
    ik8_4: Result:= FYEnd;          // ��� ��������� ������������
    ik8_5: Result:= FMStart;        // ����� ������ ������������
    ik8_6: Result:= FMEnd;          // ����� ��������� ������������
    ik8_7: Result:= FTypeSys;       // ��� ������� 1 - ����, 2 - ���� and etc.
  end;
end;
//================================================================= �������� ���
procedure TModelLine.SetIntML(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_2: if FParCode<>Value  then FParCode:= Value;  // ��� ������������� ����
  end;
end;
//============================== ������� ������� ������� ������� ���������� ����
function TModelLine.GetHasVisModels: boolean;
var i, j: integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
   CheckModelsLists;
   with FMLModelsSort do for i:= 0 to Count-1 do begin
     j:= Integer(Objects[i]);
     if Cache.FDCA.Models[j].IsVisible then begin
       Result:= True;
       break;
     end;
   end;
end;
//============================================================== �������� ������
function TModelLine.GetStrML(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of // ������������ ���������� ���� ��� ����������
    ik8_1: Result:= GetNameForSort(Name, YStart, MStart);
  end;
end;
//===================================== ��������� ������ ������� ���������� ����
procedure TModelLine.CheckModelsLists;
var i, j, ii: Integer;
    ar: Tai;
    fLast: boolean;
    cs: TCriticalSection;
begin
  SetLength(ar, 0);
  if not Assigned(self) then Exit;
  cs:= Cache.FDCA.ModelLines.CS_MLines;

  with FMLModelsSort do if Delimiter=LCharUpdate then try
    cs.Enter;
    Clear;
    ar:= Cache.FDCA.Models.GetMLModelsList(FID);
    Capacity:= Capacity+Length(ar);
    for i:= Low(ar) to High(ar) do
      AddObject(Cache.FDCA.Models[ar[i]].SortName, Pointer(ar[i]));
    CustomSort(ModelsSortCompare);
    Delimiter:= LCharGood;
    FMLModelsTopUp.Delimiter:= LCharUpdate; // ������ �������������� ������ � ������
  finally
    cs.Leave;
    SetLength(ar, 0);
  end;

  with FMLModelsTopUp do if Delimiter=LCharUpdate then try
    cs.Enter;
    Clear;
    for i:= 0 to FMLModelsSort.Count-1 do
      AddObject(FMLModelsSort.Strings[i], FMLModelsSort.Objects[i]);
    if Count>0 then begin  // ������������ ����
      j:= Integer(Objects[0]); // ���������� 1-� �������
      i:= Count-1;
      fLast:= False;
      while not fLast do begin         // ���������� � �����
        ii:= Integer(Objects[i]);
        fLast:= (ii=j); // true - ��������� ��������
        if Cache.FDCA.Models[ii].IsTop then
          Move(i, 0)               // ��� ��������� � ������
        else Dec(i);
      end;
    end;
    Delimiter:= LCharGood; // ������ ������������ ������ � ������
  finally
    cs.Leave;
  end;
end;
//====================================== �������� ������ ������� ���������� ����
function TModelLine.GetListModels(pTopsUp: Boolean=False): TStringList;
begin
  Result:= nil;
  if not Assigned(self) then Exit else CheckModelsLists; // ��������� ������
  if pTopsUp then Result:= FMLModelsTopUp else Result:= FMLModelsSort;
end;
//=========================== �������� ��� ������ ���������� ���� �� ���� TecDoc
function TModelLine.GetMLModelIDByTDcode(pModTDnr: Integer): Integer;
var i: integer;
begin
  Result:= -1;
  if not Assigned(self) or (TypeSys=2) then Exit; // �� ���� TecDoc ���� ������ ���� !!!
  with GetListModels do for i:= 0 to Count-1 do begin
    Result:= Integer(Objects[i]);
    with Cache.FDCA do
      if Models.ModelExists(Result) and (Models[Result].SubCode=pModTDnr) then Exit;
  end;
  Result:= -1;
end;
//============================= ������� ������ �� ������ ������� ���������� ����
procedure TModelLine.ModelDelFromLine(pModelID: Integer);
const nmProc = 'ModelDelFromLine';
var i: Integer;
    p: Pointer;
  //---------------------------
  procedure DelModelItem(var lst: TStringList);
  begin
    i:= lst.IndexOfObject(p);
    if (i>-1) then lst.Delete(i);
  end;
  //---------------------------
begin
  if not Assigned(self) then Exit;
  if FMLModelsSort.Delimiter=LCharUpdate then Exit;
  try
    p:= Pointer(pModelID);
    with Cache.FDCA.ModelLines.CS_MLines do try
      Enter;
      DelModelItem(FMLModelsSort);
      DelModelItem(FMLModelsTopUp);
    finally
      Leave;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;

//******************************************************************************
//                  TModelLines - ������ ��������� �����
//******************************************************************************
//==============================================================================
constructor TModelLines.Create;
begin
  SetLength(FarModelLines, 1);
  FarModelLines[0]:= TModelLine.Create(0, 0, 0, '');
  CS_MLines:= TCriticalSection.Create;
  Inherited Create;
end;
//==============================================================================
destructor TModelLines.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= Low(FarModelLines) to High(FarModelLines) do
    if Assigned(FarModelLines[i]) then try prFree(FarModelLines[i]); except end;
  SetLength(FarModelLines, 0);
  prFree(CS_MLines);
  inherited Destroy;
end;
//======================================= �������� ������������� ���������� ���� 
function TModelLines.ModelLineExists(pID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (pID>0) and (length(FarModelLines)>pID) and Assigned(FarModelLines[pID]);
end;
//===================================== �������� ������ �� ��������� ��� �� ����
function TModelLines.GetModelLine(pModelLineID: Integer): TModelLine;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if ModelLineExists(pModelLineID) then Result:= FarModelLines[pModelLineID]
  else Result:= FarModelLines[0];
end;
//====== ���������� ������ ��������� ����� �� ���������� ������������� � �������
function TModelLines.GetManufSysModelLinesList(pManufID, pTypeSys: Integer): TStringList; // must Free Result
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  for i:= 1 to High(FarModelLines) do
    if Assigned(FarModelLines[i]) then with FarModelLines[i] do
      if (MFAID=pManufID) and (FTypeSys=pTypeSys) then
        Result.AddObject(SortName, Pointer(i));
end;
//=================================== ������������� ���� �������� ���� ���������
procedure TModelLines.SetStates(pState: Boolean; pTypeSys: Integer=0);
var i: Integer;
begin
  if not Assigned(self) or (length(FarModelLines)<2) then Exit;
  CS_MLines.Enter;
  try
    for i:= 1 to High(FarModelLines) do if Assigned(FarModelLines[i]) then
      with FarModelLines[i] do if (pTypeSys<1) or (FTypeSys=pTypeSys) then State:= pState;
  finally
    CS_MLines.Leave;
  end;
end;

//******************************************************************************
//          TManufacturer - ������������� ����/����/����������
//******************************************************************************
//============ ���������� TStringList ��������� ����� - ��������� + ������������
function ManufMLsSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var fl1, fl2: Boolean;
begin
  with Cache.FDCA do try
    fl1:= ModelLines[Integer(List.Objects[Index1])].IsVisible;
    fl2:= ModelLines[Integer(List.Objects[Index2])].IsVisible;
    if fl1=fl2 then Result:= AnsiCompareText(List.Strings[Index1], List.Strings[Index2])
    else if fl1 then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;
//==============================================================================
constructor TManufacturer.Create(pID: Integer; pName: String; pTDnr: Integer=0);  // ���, ���, ��� TecDoc
begin
  inherited Create(pID, pTDnr, 0, pName, 0);
  FManufSysMLsSort:= TArraySysTypeLists.Create(False, True);  // ������ ��������� ����� �� �������� ����� (Objects-ID)
  FManufSysMLsTopUp:= TArraySysTypeLists.Create(False, True); // ������ ��������� ����� � ������ ������ �� �������� ����� (Objects-ID)
  FMfauOpts:= [];
  FManufSearchONlist:= fnCreateStringList(True, 10);          // ������������� ������ ����.������� ������������� ��� ����/����
end;
//==============================================================================
destructor TManufacturer.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FManufSysMLsSort);
  prFree(FManufSysMLsTopUp);
  FMfauOpts:= [];
  prFree(FManufSearchONlist);
  inherited Destroy;
end;
//============================================================= �������� �������
procedure TManufacturer.SetBoolMf(ik: T16InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FMfauOpts:= FMfauOpts+[ik] else FMfauOpts:= FMfauOpts-[ik];
end;
//============================================================= �������� �������
function TManufacturer.GetBoolMf(ik: T16InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FMfauOpts);
end;
//================ �������� �������������� � �����-������ ������� ����� pTypeSys
function TManufacturer.CheckOtherTypeSys(pTypeSys: Integer): Boolean;
var i, j: integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  with SysTypes do for i:= 0 to Count-1 do begin
    j:= GetDirItemID(ItemsList[i]);
    Result:= CheckIsTypeSys(j) and (j<>pTypeSys);
    if Result then Exit;
  end;
end;
//======================== �������� �������������� ������������� � ������� �����
function TManufacturer.CheckIsTypeSys(pTypeSys: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  case pTypeSys of
    constIsAuto: Result:= IsMfAUTO;
    constIsMoto: Result:= IsMfMOTO;
//    constIsEng : Result:= self.;
    constIsCV  : Result:= IsMfCV;
    constIsAx  : Result:= IsMfAx;
    else Result:= False;
  end;
end;
//============================ ��������� ������������� ������� ��� ������� �����
function TManufacturer.CheckIsTop(pTypeSys: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  case pTypeSys of
    constIsAuto: Result:= IsMfAUTO and IsMfTopA;
    constIsMoto: Result:= IsMfMOTO and IsMfTopM;
    constIsCV  : Result:= False; // IsMfCV   and IsMfTopCV;
    constIsAx  : Result:= False; // IsMfAx   and IsMfTopAx;
    else Result:= False;
  end;
end;
//========================================================== ��������� ���������
function TManufacturer.CheckIsVisible(pTypeSys: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  case pTypeSys of
    constIsAuto: Result:= IsMfAUTO and IsMfVisA;
    constIsMoto: Result:= IsMfMOTO and IsMfVisM;
    constIsCV  : Result:= IsMfCV; //    and IsMfVisCV;
    constIsAx  : Result:= IsMfAx; //    and IsMfVisAx;
    else Result:= False;
  end;
end;
//==================================== ���������� / ����� �������������� �������
procedure TManufacturer.TypeSysSet(pTypeSys: Integer; IsSys: Boolean);
begin
  if not Assigned(self) then Exit;
  case pTypeSys of
    constIsAuto: IsMfAUTO:= IsSys;
    constIsMoto: IsMfMOTO:= IsSys;
    constIsCV  : IsMfCV  := IsSys;
    constIsAx  : IsMfAx  := IsSys;
  end;
end;
//================================================= ���������� / ����� ���������
procedure TManufacturer.TopsSet(pTypeSys: Integer; IsTop: Boolean);
begin
  if not Assigned(self) then Exit;
  case pTypeSys of
    constIsAuto: if IsMfAUTO then IsMfTopA := IsTop;
    constIsMoto: if IsMfMOTO then IsMfTopM := IsTop;
//    constIsCV  : if IsMfCV   then IsMfTopCV:= IsTop;
//    constIsAx  : if IsMfAx   then IsMfTopAx:= IsTop;
  end;
end;
//================================================= ���������� / ����� ���������
procedure TManufacturer.VisibleSet(pTypeSys: Integer; IsVis: Boolean);
begin
  if not Assigned(self) then Exit;
  case pTypeSys of
    constIsAuto: if IsMfAUTO then IsMfVisA := IsVis;
    constIsMoto: if IsMfMOTO then IsMfVisM := IsVis;
//    constIsCV  : if IsMfCV   then IsMfVisCV:= IsVis;
//    constIsAx  : if IsMfAx   then IsMfVisAx:= IsVis;
  end;
end;
//================ �������� ������� �� � ������������� ��������� ���� �� �������
function TManufacturer.CheckHasModelLines(pTypeSys: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  CheckModelLinesLists(pTypeSys);
  Result:= CheckIsTypeSys(pTypeSys) and (FManufSysMLsSort[pTypeSys].Count>0);
end;
//================= ������� ������� ������� ��������� ����� �� ��������� �������
function TManufacturer.HasVisModelLines(pTypeSys: Integer): Boolean;
var i: integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  CheckModelLinesLists(pTypeSys);
  with FManufSysMLsSort[pTypeSys] do for i:= 0 to Count-1 do
    if Cache.FDCA.ModelLines[Integer(Objects[i])].IsVisible then begin
      Result:= True;
      break;
    end;
end;
//========================= ������� ������� ������� ������� �� ��������� �������
function TManufacturer.HasVisMLModels(pTypeSys: Integer): Boolean;
var i: integer;
begin
  Result:= False;
  if not Assigned(self) then Exit else CheckModelLinesLists(pTypeSys);
  with FManufSysMLsSort[pTypeSys] do for i:= 0 to Count-1 do
    with Cache.FDCA.ModelLines[Integer(Objects[i])] do
      if IsVisible and HasVisModels then begin
        Result:= True;
        break;
      end;
end;
//==================== ������ ��������� ����� ������������� �� ��������� �������
function TManufacturer.GetModelLinesList(pTypeSys: Integer; pTopsUp: Boolean): TStringList;
begin
  if not Assigned(self) or not CheckIsTypeSys(pTypeSys) then begin
    Result:= EmptyStringList;
    Exit;
  end;
  CheckModelLinesLists(pTypeSys);
  if pTopsUp then Result:= FManufSysMLsTopUp[pTypeSys]
  else Result:= FManufSysMLsSort[pTypeSys];
end;
//============================= �������� ��� ���������� ���� ���� �� ���� TecDoc
function TManufacturer.GetMfMLineIDByTDcode(pmlTDnr: Integer; pSys: integer=constIsAuto): Integer;
var i: integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  with GetModelLinesList(pSys, False) do for i:= 0 to Count-1 do begin
    Result:= Integer(Objects[i]);
    if (Cache.FDCA.ModelLines[Result].SubCode=pmlTDnr) then Exit;
  end;
  Result:= -1;
end;

//============================ ������ ������� ������������� �� ��������� �������
function TManufacturer.GetModelsList(pTypeSys: Integer): TStringList; // must Free Result
var i, j: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  with GetModelLinesList(pTypeSys, False) do for i:= 0 to Count-1 do
    with Cache.FDCA.ModelLines[Integer(Objects[i])].GetListModels do
      for j:= 0 to Count-1 do Result.AddObject(Strings[j], Objects[j]);
end;
//========== ��������� ������ ��������� ����� ������������� �� ��������� �������
procedure TManufacturer.CheckModelLinesLists(pTypeSys: Integer);
const nmProc = 'CheckModelLinesLists';
var lst: TStringList;
    i, j: integer;
    fLast: boolean;
begin
  if not Assigned(self) then Exit;
  if not CheckIsTypeSys(pTypeSys) then Exit;
  if (FManufSysMLsSort[pTypeSys].Delimiter=LCharGood) and
    (FManufSysMLsTopUp[pTypeSys].Delimiter=LCharGood) then Exit;

  lst:= nil;
  try
    with FManufSysMLsSort do
      if Items[pTypeSys].Delimiter=LCharUpdate then try // ���� ������ ������������
        lst:= Cache.FDCA.ModelLines.GetManufSysModelLinesList(FID, pTypeSys);
        AddTypeListItems(pTypeSys, lst, True);
        Items[pTypeSys].CustomSort(ManufMLsSortCompare);
        FManufSysMLsTopUp.SetTypeListDelimiter(pTypeSys, LCharUpdate); // ������ �������������� ������ � ������
      finally
        prFree(lst);
      end;

    with FManufSysMLsTopUp do
      if Items[pTypeSys].Delimiter=LCharUpdate then begin // ���� ������ � ������ ������������
        AddTypeListItems(pTypeSys, FManufSysMLsSort[pTypeSys], True);
        CS_ATLists.Enter;
        try
          with Items[pTypeSys] do if Count>0 then begin  // ������������ ����
            j:= Integer(Objects[0]); // ���������� 1-� �������
            i:= Count-1;
            fLast:= False;
            while not fLast do begin         // ���������� � �����
              fLast:= Integer(Objects[i])=j; // true - ��������� ��������
              if Cache.FDCA.ModelLines[Integer(Objects[i])].IsTop then
                Move(i, 0)               // ��� ��������� � ������
              else inc(i, -1);
            end;
          end;
        finally
          CS_ATLists.Leave;
        end;
      end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//======================= �������� ��������� ��� � ��� � ������������� � �������
function TManufacturer.ModelLineAdd(var ModelLineID: Integer; pName: String;
         pTypeSys, pMS, pYS, pME, pYE, pUserID: Integer; pIsTop, pIsVis: Boolean; pMLTD: Integer=0): String;
const nmProc='ModelLineAdd';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    ModelLine: TModelLine;
    sName: String;
    ii, jj: Integer;
begin
  Result:= '';
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrAddRecord));
    if not CheckIsTypeSys(pTypeSys) then
      raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(pTypeSys)));

    sName:= GetNameForSort(pName, pYS, pMS);
    if CheckHasModelLines(pTypeSys) and
      (FManufSysMLsSort.GetTypeListItemIDByName(pTypeSys, sName)>-1) then
      raise EBOBError.Create(MessText(mtkDuplicateName, sName)); // ��������

    ORD_IBD:= cntsOrd.GetFreeCnt;

    ModelLineID:= 0;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'insert into DIRMODELLINES (DRMLDTSYCODE, '+
        ' DRMLMFAUCODE, DRMLISTOP, DRMLNAME, '+
        fnIfStr(pMS=0,   '', 'DRMLMONTHSTART, ')+
        fnIfStr(pYS=0,   '', 'DRMLYEARSTART, ')+
        fnIfStr(pME=0,   '', 'DRMLMONTHEND, ')+
        fnIfStr(pYE=0,   '', 'DRMLYEAREND, ')+
        fnIfStr(pMLTD=0, '', 'DRMLTDCODE, ')+
        ' DRMLISVISIBLE, DRMLUSERID) values ('+
        IntToStr(pTypeSys)+', '+IntToStr(FID)+', :isTop, :DRMLNAME, '+
        fnIfStr(pMS=0,   '', IntToStr(pMS)+', ')+
        fnIfStr(pYS=0,   '', IntToStr(pYS)+', ')+
        fnIfStr(pME=0,   '', IntToStr(pME)+', ')+
        fnIfStr(pYE=0,   '', IntToStr(pYE)+', ')+
        fnIfStr(pMLTD=0, '', IntToStr(pMLTD)+', ')+
        ':IsVis, '+IntToStr(pUserID)+') RETURNING DRMLCODE';
      ORD_IBS.ParamByName('DRMLNAME').AsString:= pName;
      ORD_IBS.ParamByName('isTop').AsString:= fnIfStr(pIsTop, 'T', 'F');
      ORD_IBS.ParamByName('IsVis').AsString:= fnIfStr(pIsVis, 'T', 'F');;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then
        ModelLineID:= ORD_IBS.Fields[0].asInteger;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if ModelLineID<1 then raise EBOBError.Create(MessText(mtkErrAddRecord));

    ModelLine:= TModelLine.Create(ModelLineID, pMLTD, FID, pName);
    with ModelLine do begin
      FTypeSys:= pTypeSys;
      IsTop   := pIsTop;
      FYStart := pYS;
      FMStart := pMS;
      FYEnd   := pYE;
      FMEnd   := pME;
      IsVisible:= pIsVis;
    end;
    with Cache.FDCA.ModelLines do try
      CS_MLines.Enter;
      try
        if High(FarModelLines)<ModelLineID then begin
          jj:= Length(FarModelLines);            // ��������� ����� �������
          SetLength(FarModelLines, ModelLineID+100);   // � ���������� ��������
          for ii:= jj to High(FarModelLines) do
           if ii<>ModelLineID then FarModelLines[ii]:= nil;
        end;
        FarModelLines[ModelLineID]:= ModelLine;
      finally
        CS_MLines.Leave;
      end;
    except
      prFree(ModelLine);
      raise EBOBError.Create(MessText(mtkErrAddRecord));
    end;
    FManufSysMLsSort.SetTypeListDelimiter(pTypeSys, LCharUpdate);
    FManufSysMLsTopUp.SetTypeListDelimiter(pTypeSys, LCharUpdate);
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//================================== ������� ��������� ��� �� ���� �������������
function TManufacturer.ModelLineDel(pModelLineID: Integer): String;
const nmProc='ModelLineDel';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    SysID  : Integer;
begin
  Result:= '';
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrDelRecord));
    if not Cache.FDCA.ModelLines.ModelLineExists(pModelLineID) then
      raise EBOBError.Create(MessText(mtkNotFoundModLine, IntToStr(pModelLineID)));  // ��������� ��� � ����� ����� �����������
    if Cache.FDCA.ModelLines[pModelLineID].ModelsCount>0 then
      raise EBOBError.Create('��������� ��� ����� ������.');
    SysID:= Cache.FDCA.ModelLines[pModelLineID].FTypeSys;
    if CheckHasModelLines(SysID) and // ��������� ��� ����������� � ������ ��������� ����� ������������� �� ���� ������� ���������� ����
      not FManufSysMLsSort.TypeListItemExists(SysID, pModelLineID) then  // ???
      raise EBOBError.Create(MessText(mtkNotFoundModLine, IntToStr(pModelLineID)));

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'delete from DIRMODELLINES where DRMLCODE='+IntToStr(pModelLineID);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    with Cache.FDCA.ModelLines do   // �������� ���������� ���� �� ����
      if ModelLineExists(pModelLineID) then try
        CS_MLines.Enter;
        prFree(FarModelLines[pModelLineID]);
      finally
        CS_MLines.Leave;
      end;

    if FManufSysMLsSort[SysID].Delimiter=LCharGood then       // ���� ������ ��������
      FManufSysMLsSort.DelTypeListItem(SysID, pModelLineID);  // �������� ���������� ���� � ���� �� ������ �� �������������
    if FManufSysMLsTopUp[SysID].Delimiter=LCharGood then      // ���� ������ ��������
      FManufSysMLsTopUp.DelTypeListItem(SysID, pModelLineID); // �������� ���������� ���� � ���� �� ������ � ������
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//============== �������� ��������� ��� � ��� � � ���� � ������������� � �������
function TManufacturer.ModelLineEdit(pModelLineID, pYS, pMS, pYE, pME, pUserID: Integer;
         pIsTop, pIsVis: Boolean; pName: String=''; pMLTD: Integer=0): String;
const nmProc='ModelLineEdit';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    sName, sSql: String;
    SysID, i: Integer;
    fUp, fTop, fVis: Boolean;
    ModelLine: TModelLine;
begin
  Result:= '';
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrProcess));
    if not Cache.FDCA.ModelLines.ModelLineExists(pModelLineID) then
      raise Exception.Create(MessText(mtkNotFoundModLine, IntToStr(pModelLineID))); // ��������� ��� � ����� ����� �����������
    ModelLine:= Cache.FDCA.ModelLines[pModelLineID];
    SysID:= ModelLine.FTypeSys;
    if CheckHasModelLines(SysID) and // ��������� ��� ����������� � ������ ��������� ����� ������������� �� ���� ������� ���������� ����
      not FManufSysMLsSort.TypeListItemExists(SysID, pModelLineID) then
      raise Exception.Create(MessText(mtkNotFoundModLine, IntToStr(pModelLineID)));  // ???
    if not Assigned(ModelLine) then raise Exception.Create(MessText(mtkErrProcess));

    if pName<>'' then sName:= GetNameForSort(pName, pYS, pMS)
    else sName:= GetNameForSort(ModelLine.Name, pYS, pMS);
    i:= FManufSysMLsSort.GetTypeListItemIDByName(SysID, sName);
    if (i>-1) and (i<>pModelLineID) then
      raise Exception.Create(MessText(mtkDuplicateName, sName));  // �������� ������������

    sSql:= '';
    with ModelLine do begin
      if (pName<>'') and (Name<>pName) then sSql:= sSql+'DRMLNAME=:DRMLNAME, ';
      if (FYStart<>pYS) then sSql:= sSql+'DRMLYEARSTART='+fnIfStr(pYS>0, IntToStr(pYS), 'null')+', ';
      if (FMStart<>pMS) then sSql:= sSql+'DRMLMONTHSTART='+fnIfStr(pYS>0, IntToStr(pMS), 'null')+', ';
      fUp:= sSql<>''; // ������� ��������� ������������ � �������
      if (FYEnd<>pYE) then sSql:= sSql+'DRMLYEAREND='+fnIfStr(pYS>0, IntToStr(pYE), 'null')+', ';
      if (FMEnd<>pME) then sSql:= sSql+'DRMLMONTHEND='+fnIfStr(pYS>0, IntToStr(pME), 'null')+', ';
      if (pMLTD>0) and (SubCode<>pMLTD) then sSql:= sSql+'DRMLTDCODE='+IntToStr(pMLTD)+', ';
      fTop:= IsTop<>pIsTop;
      if fTop then sSql:= sSql+'DRMLISTOP=:IsTop, ';
      fVis:= IsVisible<>pIsVis;
      if fVis then sSql:= sSql+'DRMLISVISIBLE=:isVis, ';
    end;
    if sSql='' then raise Exception.Create(MessText(mtkNotParams));

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'update DIRMODELLINES set '+sSql+' DRMLUSERID='+IntToStr(pUserID)+
                         ' where DRMLCODE='+IntToStr(pModelLineID);
      if ModelLine.Name<>pName then ORD_IBS.ParamByName('DRMLNAME').AsString:=pName;
      if fTop then ORD_IBS.ParamByName('IsTop').AsString:= fnIfStr(pIsTop, 'T', 'F');
      if fVis then ORD_IBS.ParamByName('isVis').AsString:= fnIfStr(pIsVis, 'T', 'F');
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    with ModelLine do begin
      if (pName<>'') and (FName<>pName) then FName:= pName;
      if (FYStart<>pYS) then FYStart:= pYS;
      if (FMStart<>pMS) then FMStart:= pMS;
      if (FYEnd<>pYE)   then FYEnd  := pYE;
      if (FMEnd<>pME)   then FMEnd  := pME;
      if (pMLTD>0) and (SubCode<>pMLTD) then FSubCode:= pMLTD;
      if fTop then IsTop    := pIsTop;
      if fVis then IsVisible:= pIsVis;
    end;
    if fUP or fVis then FManufSysMLsSort.SetTypeListDelimiter(SysID, LCharUpdate)
    else if fTop then FManufSysMLsTopUp.SetTypeListDelimiter(SysID, LCharUpdate);
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;

//******************************************************************************
//                           TManufacturers
//******************************************************************************
//===== ���������� TStringList �������������� ������� - ��������� + ������������
function ManufSort(List: TStringList; Index1, Index2, SysID: Integer): Integer;
var fl1, fl2: Boolean;
begin
  with List do try
    fl1:= TManufacturer(Objects[Index1]).CheckIsVisible(SysID);
    fl2:= TManufacturer(Objects[Index2]).CheckIsVisible(SysID);
    if fl1=fl2 then Result:= AnsiCompareText(Strings[Index1], Strings[Index2])
    else if fl1 then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;
//=== ���������� TStringList �������������� ����.���� - ��������� + ������������
function AutoManufSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:= ManufSort(List, Index1, Index2, constIsAuto);
end;
//======== ���������� TStringList �������������� ���� - ��������� + ������������
function MotoManufSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:= ManufSort(List, Index1, Index2, constIsMoto);
end;
{//== ���������� TStringList �������������� ���������� - ��������� + ������������
function EngManufSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:= ManufSort(List, Index1, Index2, constIsEng);
end;  }
//=== ���������� TStringList �������������� ����.���� - ��������� + ������������
function CVManufSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:= ManufSort(List, Index1, Index2, constIsCV);
end;
//======== ���������� TStringList �������������� ���� - ��������� + ������������
function AxManufSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:= ManufSort(List, Index1, Index2, constIsAx);
end;
//==============================================================================
constructor TManufacturers.Create;
begin
  inherited;
  CS_Mfaus:= TCriticalSection.Create;
  SetLength(FarManufacturers, 1);               // ������ ��������������
  FarManufacturers[0]:= TManufacturer.Create(0, '');
  FSysManufListSort:= TArraySysTypeLists.Create(False, True);  // ������ �� �������� ����� (Objects-Pointer)
  FSysManufListTopUp:= TArraySysTypeLists.Create(False, True); // ������ � ������ ������ �� �������� ����� (Objects-Pointer)
end;
//==============================================================================
destructor TManufacturers.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= Low(FarManufacturers) to High(FarManufacturers) do
    if Assigned(FarManufacturers[i]) then try prFree(FarManufacturers[i]); except end;
  SetLength(FarManufacturers, 0);
  prFree(CS_Mfaus);
  prFree(FSysManufListSort);  // ������������� ������ �� �������� �����
  prFree(FSysManufListTopUp); // ������ � ������ ������ �� �������� �����
  inherited Destroy;
end;
//=================================== ������������� ���� �������� ���� ���������
procedure TManufacturers.SetStates(pState: Boolean; pTypeSys: Integer=0);
var i: Integer;
begin
  if not Assigned(self) or (length(FarManufacturers)<2) then Exit;
  CS_Mfaus.Enter;
  try
    for i:= 1 to High(FarManufacturers) do
      if Assigned(FarManufacturers[i]) and ((pTypeSys<1) or
        FarManufacturers[i].CheckIsTypeSys(pTypeSys)) then
        FarManufacturers[i].State:= pState;
  finally
    CS_Mfaus.Leave;
  end;
end;
//================================================ �������� ������ �������������
function TManufacturers.GetNotTestedList(pTypeSys: Integer=0; flTested: TBooleanDynArray=nil): TStringList; // must Free Result
var i: Integer;
    fl: Boolean;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TStringList.Create;
  for i:= 1 to High(FarManufacturers) do
    if Assigned(FarManufacturers[i]) then with FarManufacturers[i] do begin
      if Assigned(flTested) then // ���� ���� ������ ������ - ��������� �� ���
        fl:= not ((length(flTested)>i) and flTested[i])
      else fl:= not State;
      if fl and ((pTypeSys<1) or CheckIsTypeSys(pTypeSys)) then
        Result.AddObject(Name, Pointer(i));
    end;
  if (Result.Count>1) then Result.Sort;
end;
// �������� ������������� ������ �������������� ���������� (Object - Pointer(ID))
function TManufacturers.GetEngManufList: TStringList; // must Free Result
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  for i:= 1 to High(FarManufacturers) do
    if Assigned(FarManufacturers[i]) then with FarManufacturers[i] do begin
      if MfHasEngWares then Result.AddObject(Name, Pointer(i));
    end;
  if (Result.Count>1) then Result.Sort;
end;
//----- �������� ������������� ������ �������������� � �� (Object - Pointer(ID))
function TManufacturers.GetOEManufList: TStringList;  // must Free
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  for i:= 1 to High(FarManufacturers) do
    if Assigned(FarManufacturers[i]) then with FarManufacturers[i] do begin
      if (ManufSearchONlist.Count>0) then Result.AddObject(Name, Pointer(i));
    end;
  if (Result.Count>1) then Result.Sort;
end;

//============================================= ��������� ������������� ��������
function TManufacturers.CheckManufItem(pCODE: Integer; var flNew: Boolean; pNAME: String; pTDnr: Integer=0): Boolean;
// flNew=True - ��������� ����� �������, �� ������ ������� ������ ��������
var ii, jj: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= Cache.FDCA.ManufAutoExist(pCODE);
  if Result then flNew:= False else if flNew then begin
    if (High(FarManufacturers)<pCODE) then begin
      jj:= Length(FarManufacturers);            // ��������� ����� �������
      SetLength(FarManufacturers, pCode+100);   // � ���������� ��������
      for ii:= jj to High(FarManufacturers) do
       if ii<>pCode then FarManufacturers[ii]:= nil;
    end;
    FarManufacturers[pCODE]:= TManufacturer.Create(pCODE, pNAME, pTDnr); // �������� ������������� ����
    Result:= Assigned(FarManufacturers[pCODE]);
  end;
end;
//======== ���������� ��������� �� ������������� � ����� pIndex ��� �� 0 �������
function TManufacturers.GetManufItem(pIndex: Integer): TManufacturer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if ManufExists(pIndex) then Result:= FarManufacturers[pIndex]
  else Result:= FarManufacturers[0];
end;
//================================================ �������� ������������� ������
function TManufacturers.GetSortedList(pTypeSys: Integer): TStringList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if FSysManufListSort[pTypeSys].Delimiter=LCharUpdate then // ���� ���� �����������
    CheckManufLists(pTypeSys);
  Result:= FSysManufListSort[pTypeSys];
//  if pTypeSys=2 then for i:= 0 to FSysManufListSort[2].Count-1 do
//    prMessageLOGS('FSysManufListSort - '+FSysManufListSort[2].Strings[i], 'test', false);
end;
//============================================== �������� ������ � ������ ������
function TManufacturers.GetSortedListWithTops(pTypeSys: Integer): TStringList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if (FSysManufListSort[pTypeSys].Delimiter=LCharUpdate) or
    (FSysManufListTopUp[pTypeSys].Delimiter=LCharUpdate) then // ���� ���� ���������������
    CheckManufLists(pTypeSys);
  Result:= FSysManufListTopUp[pTypeSys];
//  if pTypeSys=2 then for i:= 0 to FSysManufListTopUp[2].Count-1 do
//    prMessageLOGS('FSysManufListTopUp - '+FSysManufListTopUp[2].Strings[i], 'test', false);
end;
//===================================================== ��������� ������ �������
procedure TManufacturers.CheckManufLists(pTypeSys: Integer);
var i   : Integer;
    Flst: TStringList;
    p: Pointer;
    fLast: Boolean;
begin
  if not Assigned(self) then Exit;
  Flst:= nil;
  try
    if FSysManufListSort[pTypeSys].Delimiter=LCharUpdate then begin // ���� ���� �����������
      Flst:= TStringList.Create;
      for i:= 1 to High(FarManufacturers) do // ��������
        if Assigned(FarManufacturers[i]) and FarManufacturers[i].CheckIsTypeSys(pTypeSys) then
          Flst.AddObject(FarManufacturers[i].Name, FarManufacturers[i]);
      FSysManufListSort.AddTypeListItems(pTypeSys, Flst, True); // ���������
      with FSysManufListSort[pTypeSys] do
        case pTypeSys of // ��������� � ������ ���������
          constIsAuto: CustomSort(AutoManufSortCompare);
          constIsMoto: CustomSort(MotoManufSortCompare);
//          constIsEng : CustomSort(EngManufSortCompare);
          constIsCV  : CustomSort(CVManufSortCompare);
          constIsAx  : CustomSort(AxManufSortCompare);
        end;
      FSysManufListTopUp.SetTypeListDelimiter(pTypeSys, LCharUpdate);
    end;

    with FSysManufListTopUp do
      if Items[pTypeSys].Delimiter=LCharUpdate then begin // ���� ���� ���������������
        AddTypeListItems(pTypeSys, FSysManufListSort[pTypeSys], True); // ��������� ������������� ������
        CS_ATLists.Enter;
        with Items[pTypeSys] do try
          if Count>0 then begin // ������������ ����
            p:= Objects[0];    // ���������� 1-� �������
            i:= Count-1;
            fLast:= False;
            while not fLast do begin    // ���������� � �����
              fLast:= Objects[i]=p;     // true - ��������� ��������
              if TManufacturer(Objects[i]).CheckIsTop(pTypeSys) then
                Move(i, 0)               // ��� ��������� � ������
              else inc(i, -1);
            end;
          end;
        finally
          CS_ATLists.Leave;
        end;
      end;
  finally
    if Assigned(Flst) then prFree(Flst);
  end;
end;
//======================================================= �������� �������������
function TManufacturers.ManufAdd(var ManufID: Integer; pName: String; pTypeSys, pUserID: Integer;
         pIsTop, pIsVis: boolean; pTDnr: Integer=0): String;
const nmProc='ManufAdd';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    s, s1: string;
    flNew: Boolean;
begin
  Result:= '';
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrAddRecord));
    ManufID:= -1;
    if ManufExistsByName(pName, ManufID) and
      FarManufacturers[ManufID].CheckIsTypeSys(pTypeSys) then
      raise EBOBError.Create(MessText(mtkDuplicateName, pName));

    if (ManufID>0) then begin // ���� ������������� ���� �� ������ �������
      Result:= ManufEdit(ManufID, pTypeSys, pUserID, pIsTop, True, pName, pTDnr);
      Exit;

    end else try  // ���� ������������� ������������� �����
      s:= '';
      s1:= '';
      if (pTypeSys in [constIsAuto, constIsMoto]) then begin
        case pTypeSys of
          constIsAuto: s:= ', MFAUISMFAUTO, MFAUISTOPAUTO, MFAUVISIBLEAUTO';
          constIsMoto: s:= ', MFAUISMFMOTO, MFAUISTOPMOTO, MFAUVISIBLEMOTO';
        end;
        s1:= ', "T", '+fnIfStr(pIsTop, '"T"', '"F"')+', '+fnIfStr(pIsVis, '"T"', '"F"');
      end else begin
        case pTypeSys of
  //        constIsEng : s:= ', MFAUISMFeng, MFAUISTOPeng, MFAUVISIBLEeng';
  //        constIsCV  : s:= ', MFAUISMFCV,  MFAUISTOPCV,  MFAUVISIBLECV';
  //        constIsAx  : s:= ', MFAUISMFAX,  MFAUISTOPAX,  MFAUVISIBLEAX';
          constIsCV  : s:= ', MFAUISMFCV';
          constIsAx  : s:= ', MFAUISMFAX';
        end;
        s1:= ', "T"';
      end;

      if (s='') then
        raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(pTypeSys)));
      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'insert into MANUFACTURERAUTO (MFAUNAME, MFAUISMFAU, '+
        fnIfStr(pTDnr<1, '', ' MFAUTDMFNR, ')+'MFAUUSERID'+s+
        ') values (:MFAUNAME, "T", '+fnIfStr(pTDnr<1, '', ' '+IntToStr(pTDnr)+', ')+
        IntToStr(pUserID)+s1+') RETURNING MFAUCODE';
      ORD_IBS.ParamByName('MFAUNAME').AsString:= pName;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then ManufID:= ORD_IBS.Fields[0].asInteger;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if (ManufID<1) then raise EBOBError.Create(MessText(mtkErrAddRecord));

    flNew:= True;
    CS_Mfaus.Enter;
    try
      if CheckManufItem(ManufID, flNew, pName, pTDnr) then begin // �������� ������������� ����
        with FarManufacturers[ManufID] do begin
          IsMF:= True;
          TypeSysSet(pTypeSys, True);   // �������������� �������
          TopsSet(pTypeSys, pIsTop);    // ���������
          VisibleSet(pTypeSys, pIsVis); // ���������
        end;
        FSysManufListSort[pTypeSys].Delimiter:= LCharUpdate;
        FSysManufListTopUp[pTypeSys].Delimiter:= LCharUpdate;
      end;
    finally
      CS_Mfaus.Leave;
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  if (Result<>'') and (ManufID>0) and ManufExists(ManufID) then 
    prFree(FarManufacturers[ManufID]);
end;
//======================================================== ������� �������������
function TManufacturers.ManufDel(var pID: Integer; pTypeSys: Integer): String;
const nmProc='ManufDel';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    s: string;
    CheckOther: boolean;
begin
  Result:= '';
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrDelRecord));
    if not ManufExists(pID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, IntToStr(pID))); // ������ ������� - ������������� ��� � ����
    if FarManufacturers[pID].CheckHasModelLines(pTypeSys) then
      raise EBOBError.Create('������������� ����� ��������� ����.'); // ���� ��������� ���� �� ������ ������� �����
    if (FarManufacturers[pID].ManufSearchONlist.Count>0) then
      raise EBOBError.Create('������������� ����� ������������ ������.'); // ���� ������������ ������

    CheckOther:= FarManufacturers[pID].CheckOtherTypeSys(pTypeSys);
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      if CheckOther then begin // ���� �������� �� ������ �������
        s:= '';
        case pTypeSys of
          constIsAuto: s:= 'MFAUISMFAUTO="F", MFAUISTOPAUTO="F", MFAUVISIBLEAUTO="F"';
          constIsMoto: s:= 'MFAUISMFMOTO="F", MFAUISTOPMOTO="F", MFAUVISIBLEMOTO="F"';
          constIsCV  : s:= 'MFAUISMFCV="F"';
          constIsAx  : s:= 'MFAUISMFAX="F"';
        end;
//        case pTypeSys of
//          constIsEng : s:= 'MFAUISMFeng="F", MFAUISTOPeng="F", MFAUVISIBLEeng="F"';
//          constIsCV  : s:= 'MFAUISMFCV="F",  MFAUISTOPCV="F",  MFAUVISIBLECV="F"';
//          constIsAx  : s:= 'MFAUISMFAX="F",  MFAUISTOPAX="F",  MFAUVISIBLEAX="F"';
//        end;
        if (s='') then
          raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(pTypeSys)));
        ORD_IBS.SQL.Text:= 'update MANUFACTURERAUTO set '+s+' where MFAUCODE='+IntToStr(pID);
      end else
        ORD_IBS.SQL.Text:= 'delete from MANUFACTURERAUTO where MFAUCODE='+IntToStr(pID);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    CS_Mfaus.Enter;
    try
      if FSysManufListSort[pTypeSys].Delimiter=LCharGood then
        FSysManufListSort.DelTypeListItem(pTypeSys, FarManufacturers[pID]);
      if FSysManufListTopUp[pTypeSys].Delimiter=LCharGood then
        FSysManufListTopUp.DelTypeListItem(pTypeSys, FarManufacturers[pID]);

      if CheckOther then with FarManufacturers[pID] do begin
        TypeSysSet(pTypeSys, False); // ����� ������� �������������� �������
        TopsSet(pTypeSys, False);    // ����� ��� ������� ��������� �������
        VisibleSet(pTypeSys, False); // ����� ������� ��������� �������
      end else begin
        prFree(FarManufacturers[pID]);    // ������������ ������ �� �������������
        pID:= 0;
      end;
    finally
      CS_Mfaus.Leave;
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//======================================================= �������� �������������
function TManufacturers.ManufEdit(var pID: Integer; pTypeSys, pUserID: Integer;
         pIsTop, pIsVis: boolean; pName: String=''; pTDnr: Integer=0): String;
const nmProc = 'ManufEdit';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    ManufID: Integer;
    s: string;
    SetSys, SetTop, SetNm, SetVis, SetTDnr: Boolean;
begin
  Result:= '';
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrEditRecord));
    if not ManufExists(pID) then raise EBOBError.Create(MessText(mtkNotFoundManuf, IntToStr(pID)));
    if (pName<>'') and (AnsiCompareText(FarManufacturers[pID].FName, pName)<>0)
      and ManufExistsByName(pName, ManufID) then
      raise EBOBError.Create(MessText(mtkDuplicateName, pName));

    with FarManufacturers[pID] do begin
      SetSys:= not CheckIsTypeSys(pTypeSys); // ���������, ���� �� ���-�� ������
      SetNm:= (pName<>'') and (Name<>pName);
      SetTDnr:= (pTDnr>0) and (SubCode<>pTDnr);
      if SetSys then begin
        SetTop:= True;
        SetVis:= True;
      end else begin
        SetTop:= CheckIsTop(pTypeSys)<>pIsTop;
        SetVis:= CheckIsVisible(pTypeSys)<>pIsVis;
      end;
    end;
    if not (SetTop or SetVis or SetNm or SetSys or SetTDnr) then
      raise EBOBError.Create(MessText(mtkNotParams));
    s:= '';
    case pTypeSys of
      constIsAuto: s:= fnIfStr(SetTop, ', MFAUISTOPAUTO='+fnIfStr(pIsTop, '"T"', '"F"'), '')+
                       fnIfStr(SetVis, ', MFAUVISIBLEAUTO='+fnIfStr(pIsVis, '"T"', '"F"'), '')+
                       fnIfStr(SetSys, ', MFAUISMFAUTO="T"', '');
      constIsMoto: s:= fnIfStr(SetTop, ', MFAUISTOPMOTO='+fnIfStr(pIsTop, '"T"', '"F"'), '')+
                       fnIfStr(SetVis, ', MFAUVISIBLEMOTO='+fnIfStr(pIsVis, '"T"', '"F"'), '')+
                       fnIfStr(SetSys, ', MFAUISMFMOTO="T"', '');
      constIsCV  : s:= fnIfStr(SetSys, ', MFAUISMFCV="T"', '');
      constIsAx  : s:= fnIfStr(SetSys, ', MFAUISMFAX="T"', '');
    end;
{    case pTypeSys of
      constIsEng : s:= fnIfStr(SetTop, ', MFAUISTOPeng='+fnIfStr(pIsTop, '"T"', '"F"'), '')+
                       fnIfStr(SetVis, ', MFAUVISIBLEeng='+fnIfStr(pIsVis, '"T"', '"F"'), '')+
                       fnIfStr(SetSys, ', MFAUISMFeng="T"', '');
      constIsCV  : s:= fnIfStr(SetTop, ', MFAUISTOPCV='+fnIfStr(pIsTop, '"T"', '"F"'), '')+
                       fnIfStr(SetVis, ', MFAUVISIBLECV='+fnIfStr(pIsVis, '"T"', '"F"'), '')+
                       fnIfStr(SetSys, ', MFAUISMFCV="T"', '');
      constIsAx  : s:= fnIfStr(SetTop, ', MFAUISTOPAX='+fnIfStr(pIsTop, '"T"', '"F"'), '')+
                       fnIfStr(SetVis, ', MFAUVISIBLEAX='+fnIfStr(pIsVis, '"T"', '"F"'), '')+
                       fnIfStr(SetSys, ', MFAUISMFAX="T"', '');
    end;  }
    if (s='') then raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(pTypeSys)));

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'update MANUFACTURERAUTO set MFAUUSERID='+IntToStr(pUserID)+
        fnIfStr(SetNm, ', MFAUNAME=:MFAUNAME', '')+
        fnIfStr(SetTDnr, ', MFAUTDMFNR=:MFAUTDMFNR', '')+
        s+' where MFAUCODE='+IntToStr(pID);
      if SetNm   then ORD_IBS.ParamByName('MFAUNAME').AsString:= pName;
      if SetTDnr then ORD_IBS.ParamByName('MFAUTDMFNR').AsInteger:= pTDnr;
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    CS_Mfaus.Enter;
    try
      with FarManufacturers[pID] do begin
        if SetNm then FName:= pName;
        if SetTDnr then FSubCode:= pTDnr;
        if SetSys then TypeSysSet(pTypeSys, True); // ??? ������ �������
        if SetTop then TopsSet(pTypeSys, pIsTop);
        if SetVis then VisibleSet(pTypeSys, pIsVis);
      end;
      if SetNm or SetSys or SetVis then FSysManufListSort.SetTypeListDelimiter(pTypeSys, LCharUpdate)
      else if SetTop then FSysManufListTopUp.SetTypeListDelimiter(pTypeSys, LCharUpdate);
    finally
      CS_Mfaus.Leave;
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//================================= �������� ������������� ������������� �� ���� 
function TManufacturers.ManufExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(FarManufacturers)>pID) and Assigned(FarManufacturers[pID]);
end;
//================================ �������� ������������� ������������� �� �����
function TManufacturers.ManufExistsByName(pName: String; var pID: Integer): Boolean;
var SysID, i, index: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  pName:= AnsiUpperCase(pName);
  with FSysManufListSort do
    for i:= 0 to ListTypes.Count-1 do begin
      SysID:= Integer(ListTypes.Objects[i]);
      CheckManufLists(SysID);
      index:= Items[SysID].IndexOf(pName);
      Result:= index>-1;
      if Result then begin
        pID:= TManufacturer(Items[SysID].Objects[index]).ID;
        Exit;
      end;
    end;
end;
//==================================== �������� ��� ������������� �� ���� TecDoc
function TManufacturers.GetManufIDByTDcode(pTDnr: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  for Result:= 1 to High(FarManufacturers) do
    if ManufExists(Result) and (FarManufacturers[Result].SubCode=pTDnr) then Exit;
  Result:= 0;
end;

//******************************************************************************
//                      TModelAuto - ������ ����/����
//******************************************************************************
constructor TModelAuto.Create(pModelID, pModelTDcode, pOrdNum, pModelLineID: Integer; pName: String);
begin
  inherited Create(pModelID, pModelTDcode, pOrdNum, pName);
  CS_mlinks:= TCriticalSection.Create;
//  FModelHasWares:= False;
  FParCode  := pModelLineID;
  FParams   := TModelParams.Create;               // ��������� ������
  FNodeLinks:= TNodeLinks.Create(CS_mlinks); // ������ 2 ����� ������ � �������
  FLinks    := TLinks.Create(CS_mlinks);     // ������ � ������������ ����������
end;
//==============================================================================
destructor TModelAuto.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FParams);
  prFree(FNodeLinks);
  prFree(CS_mlinks);
  inherited Destroy;
end;
//==============================================================================
procedure TModelAuto.ClearLinks;
var i, j, modID: integer;
    ware: TWareInfo;
begin
  modID:= ID;
  for i:= 0 to FNodeLinks.LinkCount-1 do try // �������� �� ������ �������
    with TSecondLink(FNodeLinks.ListLinks[i]) do if assigned(DoubleLinks) then
      with DoubleLinks do for j:= Count-1 downto 0 do try
        ware:= GetLinkPtr(Items[j]);
        if assigned(ware) and assigned(ware.ModelLinks) then
          ware.ModelLinks.DelLinkListItemByID(modID, lkDirNone, ware.CS_wlinks);
      except end;
  except end;
end;
//================================================================= �������� ���
function TModelAuto.GetIntM(const ik: T8InfoKinds): Integer;
var iSys: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of // 1
    ik8_3: Result:= FParCode;            // ��� ���������� ����
    ik8_4: Result:= FOrderNum;           // ������.� ������
    else with Cache.FDCA.ModelLines do if ModelLineExists(FParCode) then
      case ik of // 2
        ik8_2: Result:= GetModelLine(FParCode).MFAID;   // ��� �������������
        else begin
          iSys:= GetModelLine(FParCode).TypeSys;
          case ik of // 3
            ik8_1: Result:= iSys;                              // ��� ������� 1 - ����, 2 - ���� and etc.
          end; // case 3
        end;
      end; // case 2
  end; // case 1
end;
//================================================================= �������� ���
procedure TModelAuto.SetIntM(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of // 1
    ik8_3: if FParCode<>Value  then FParCode:= Value;  // ��� ���������� ����
    ik8_4: if FOrderNum<>Value then FOrderNum:= Value; // ������.� ������
  end; // case 1
end;
//============================================================== �������� ������
function TModelAuto.GetStrM(const ik: T8InfoKinds): String;
var i: integer;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of // ������������ ������ ��� ����������
    ik8_1: with Params do Result:= GetNameForSort(Name, pYStart, pMStart);
                                                     // ������ ���������� ����������
    ik8_2: if (EngLinks.LinkCount>0) then with EngLinks do for i:= 0 to LinkCount-1 do
           Result:= Result+fnIfStr(Result='', '', ', ')+GetLinkName(ListLinks[i]);
    ik8_3: with Cache.FDCA.ModelLines do             // �������� ���������� ���� ������
           if ModelLineExists(ModelLineID) then Result:= GetModelLine(ModelLineID).Name;
    ik8_4: begin
           i:= ModelMfauID;                          // �������� ������������� ������
           with Cache.FDCA.Manufacturers do if ManufExists(i) then Result:= Items[i].Name;
         end;
    ik8_5: begin                                     // �������� ������ ��� ������ � Web
           Result:= ModelMfauName+' | '+ModelLineName+' | '+Name;
           if Assigned(Params) then with Params do begin
             Result:= Result+' '+fnGetYMBE(pYStart, pMStart, pYEnd, pMEnd);
             case TypeSys of
               constIsAuto: Result:= Result+' | '+IntToStr(pHP)+'�� | '+MarksCommaText;
               constIsCV  : Result:= Result+' | '+cvHPaxLOout+'�� | '+MarksCommaText;
               constIsAx  : Result:= Result+' | '+cvHPaxLOout+'�� | '+
                            Cache.FDCA.TypesInfoModel.InfoItems[Params.pDriveID].Name;
             end; // case
           end; // if Assigned(Params)
         end;
  end;
end;
//================================= �������� ������ ��� ������ (property ...Out)
function TModelParams.GetStrMP(const ik: T16InfoKinds): String;
var i, j, ipos: integer;
    s, ss: String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of   // ������ ��� ������
    ik16_1: if (pValves>0) then Result:= FormatFloat(cFloatFormatSumm, pValves/100);
                            // Result:= FloatToStr(RoundTo(pValves/100, -2));
    ik16_2: Result:= StringReplace(cvHPaxLO, '-', ' - ', []);
    ik16_3: Result:= StringReplace(cvKWaxDI, '-', ' - ', []);
    ik16_4: Result:= StringReplace(cvSecTypes, ',', ', ', [rfReplaceAll]);
    ik16_5: Result:= StringReplace(cvIDaxBT, ',', '<br>&nbsp', [rfReplaceAll]);  // �������
    ik16_6: Result:= StringReplace(cvCabs, ',', '<br>&nbsp', [rfReplaceAll]);    // �������
    ik16_7: begin
              Result:= StringReplace(cvWheels, ',', '<br>&nbsp', [rfReplaceAll]); // �������
              Result:= StringReplace(Result, '/', ' / ', [rfReplaceAll]);
            end; // ik16_7
    ik16_8: with fnSplit(',', cvSUAxBR) do try
              for i:= 0 to Count-1 do begin
                j:= StrToIntDef(Strings[i], 0);
                if (j<1) then Continue;
                s:= Cache.FDCA.TypesInfoModel.InfoItems[j].Name;
                if (s='') then Continue;
                Result:= Result+fnIfStr(Result='', '', '<br>&nbsp')+ // �������
                                StringReplace(s, '/', ' / ', [rfReplaceAll]);
              end; // for
            finally Free; end; // ik16_8
    ik16_9: with fnSplit(',', cvAxles) do try // ��� [���.���]/[���] (������ ��� ���.��� TYPEDIR=38/��� ������ ���)
              for i:= 0 to Count-1 do begin
                s:= '';
                ss:= '';
                ipos:= pos('/', Strings[i]);
                j:= StrToIntDef(copy(Strings[i], 1, ipos-1), 0);
                if (j>0) then s:= Cache.FDCA.TypesInfoModel.InfoItems[j].Name;
                j:= StrToIntDef(copy(Strings[i], ipos+1, length(Strings[i])), 0);
                if (j>0) and Cache.FDCA.Models.ModelExists(j) then
                  with Cache.FDCA.Models[j] do ss:= ModelMfauName+' '+ModelLineName+' '+Name;
                if (s='') and (ss='') then Continue;
                Result:= Result+fnIfStr(Result='', '', '<br>&nbsp')+s+' / '+ss; // �������
              end; // for
            finally Free; end; // ik16_9
  end; // case ik of
end;
//============================================================= ������� ������ 2
function TModelAuto.GetNodesExists: boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= Assigned(NodeLinks) and (NodeLinks.LinkCount>0);
end;
//==================================================== �������� ��������� ������
function TModelAuto.SetModelVisible(isVis: Boolean): String;
const nmProc = 'SetModelVisible';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
  if not Assigned(self) then Exit;
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if IsVisible=isVis then raise EBOBError.Create(MessText(mtkNotParams));
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'update DIRMODELS set DMOSISVISIBLE=:vis where DMOSCODE='+IntToStr(ID);
      ORD_IBS.ParamByName('vis').AsString:= fnIfStr(isVis, 'T', 'F');
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    IsVisible:= isVis;
    with Cache.FDCA.ModelLines[ModelLineID] do FMLModelsSort.Delimiter:= lCharUpdate;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrEditRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//============================================================= ��������� ������
function TModelAuto.ModelEdit(pName: String; pVisible, pIsTop: Boolean; pUserID: Integer;
  mps: TModelParams; pOrdNum: Integer=-1; pTDcode: Integer=-1; marks: TStringList=nil): String;
const nmProc = 'ModelEdit';
// pOrdNum, pTDcode = -1 - �� ��������� (�� ������ ��� ���� ��� ����������)
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    sSql: String;
    flTop, flVisible, flName, fUpd, fOrdNum, flTD, flMarks, flCV: Boolean;
begin
  Result:= '';
  if not Assigned(self) then Exit;
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  flName:= Name<>pName;
  flVisible:= IsVisible<>pVisible;
  flTop:= IsTop<>pIsTop;
  fOrdNum:= (pOrdNum>-1) and (ModelOrderNum<>pOrdNum);
  flTD:= (pTDcode>-1) and (SubCode<>pTDcode);
  flMarks:= Assigned(marks) and CheckDiffModelMarks(marks);
  flCV:= (FParams.cvKWaxDI<>mps.cvKWaxDI) or (FParams.cvHPaxLO<>mps.cvHPaxLO); // ���������
  sSql:= '';
  if flName    then sSql:= sSql+'DMOSNAME=:NAME, ';
  if flVisible then sSql:= sSql+'DMOSISVISIBLE="'+fnIfStr(pVisible, 'T', 'F')+'", ';
  if flTop     then sSql:= sSql+'DMOSISTOP="'+fnIfStr(pIsTop, 'T', 'F')+'", ';
  if fOrdNum   then sSql:= sSql+'DMOSORDERNUM='+IntToStr(pOrdNum)+', ';
  if flTD      then sSql:= sSql+'DMOSTDCODE='+IntToStr(pTDcode)+', ';

  sSql:= sSql+GetModelParamsUpdSql(mps);
  fUpd:= (sSql<>'') and (flName or fOrdNum or
    (FParams.pYStart<>mps.pYStart) or (FParams.pMStart<>mps.pMStart));
  try
    if (sSql='') and not flMarks and not flCV then
      raise EBOBError.Create(MessText(mtkNotParams));
    if (sSql<>'') or flCV then begin
      ORD_IBD:= cntsOrd.GetFreeCnt;
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
        if (sSql<>'') then begin
          ORD_IBS.SQL.Text:= 'update DIRMODELS set '+sSql+
            ' DMOSUSERID='+IntToStr(pUserID)+' where DMOSCODE='+IntToStr(ID);
          if flName then ORD_IBS.ParamByName('NAME').AsString:= pName;
          ORD_IBS.ExecQuery;
        end;
        if flCV then begin // ���������
          ORD_IBS.Close;
          ORD_IBS.SQL.Clear;
          ORD_IBS.SQL.Add('execute block as begin');
          if (FParams.cvKWaxDI<>mps.cvKWaxDI) then begin
            ORD_IBS.SQL.Add(' if (exists(select * from DIRMODELS_add where'+
                            '  DMOSaDmos='+IntToStr(ID)+' and DMOSaDTIM=26)) then');
            ORD_IBS.SQL.Add('  update DIRMODELS_add set DMOSaText="'+mps.cvKWaxDI+'",'+
                            '  DMOSaUSERID='+IntToStr(pUserID)+
                            '  where DMOSaDmos='+IntToStr(ID)+' and DMOSaDTIM=26;');
            ORD_IBS.SQL.Add(' else insert into DIRMODELS_add'+
                            '  (DMOSaDmos, DMOSaDTIM, DMOSaText, DMOSaUSERID) values ('+
                            IntToStr(ID)+', 26, "'+mps.cvKWaxDI+'", '+IntToStr(pUserID)+');');
          end;
          if (FParams.cvHPaxLO<>mps.cvHPaxLO) then begin
            ORD_IBS.SQL.Add(' if (exists(select * from DIRMODELS_add where'+
                            '  DMOSaDmos='+IntToStr(ID)+' and DMOSaDTIM=27)) then');
            ORD_IBS.SQL.Add('  update DIRMODELS_add set DMOSaText="'+mps.cvHPaxLO+'",'+
                            '  DMOSaUSERID='+IntToStr(pUserID)+
                            '  where DMOSaDmos='+IntToStr(ID)+' and DMOSaDTIM=27;');
            ORD_IBS.SQL.Add(' else insert into DIRMODELS_add'+
                            '  (DMOSaDmos, DMOSaDTIM, DMOSaText, DMOSaUSERID) values ('+
                            IntToStr(ID)+', 27, "'+mps.cvHPaxLO+'", '+IntToStr(pUserID)+');');
          end;
          ORD_IBS.SQL.Add(' end');
          ORD_IBS.ExecQuery;
        end;
        ORD_IBS.Transaction.Commit;
      finally
        prFreeIBSQL(ORD_IBS);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;

      if flName    then Name      := pName;
      if flVisible then IsVisible:= pVisible;
      if flTop     then IsTop    := pIsTop;
      if fOrdNum   then ModelOrderNum:= pOrdNum;
      if flTD      then FSubCode  := pTDcode;
      SetModelParams(mps);
      with Cache.FDCA.ModelLines[ModelLineID] do
        if fUpd then FMLModelsSort.Delimiter:= lCharUpdate
        else if flTop then FMLModelsTopUp.Delimiter:= lCharUpdate;
    end; // if (sSql<>'')

    if flMarks then SetModelMarks(Marks, pUserID); // ���������� ����������
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrEditRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//================================== �������� / �������� ��������� ������ � ����
procedure TModelAuto.SetModelParams(mps: TModelParams; flFill: Boolean=False);
begin
  if not Assigned(self) then Exit else with FParams do if flFill then begin
    pYStart    := mps.pYStart;
    pMStart    := mps.pMStart;
    pYEnd      := mps.pYEnd;
    pMEnd      := mps.pMEnd;
    pKW        := mps.pKW;
    pHP        := mps.pHP;
    pCCM       := mps.pCCM;
    pCylinders := mps.pCylinders;
    pValves    := mps.pValves;
    pBodyID    := mps.pBodyID;
    pDriveID   := mps.pDriveID;
    pEngTypeID := mps.pEngTypeID;
    pFuelID    := mps.pFuelID;
    pFuelSupID := mps.pFuelSupID;
    pBrakeID   := mps.pBrakeID;
    pBrakeSysID:= mps.pBrakeSysID;
    pCatalID   := mps.pCatalID;
    pTransID   := mps.pTransID;

    cvHPaxLO   := mps.cvHPaxLO;
    cvKWaxDI   := mps.cvKWaxDI;
    cvSecTypes := mps.cvSecTypes;
    cvWheels   := mps.cvWheels;
    cvIDaxBT   := mps.cvIDaxBT;
    cvCabs     := mps.cvCabs;
    cvSUAxBR   := mps.cvSUAxBR;
    cvAxles    := mps.cvAxles;
  end else begin
    if pYStart     <>mps.pYStart      then pYStart    := mps.pYStart;
    if pMStart     <>mps.pMStart      then pMStart    := mps.pMStart;
    if pYEnd       <>mps.pYEnd        then pYEnd      := mps.pYEnd;
    if pMEnd       <>mps.pMEnd        then pMEnd      := mps.pMEnd;
    if (pKW        <>mps.pKW)         then pKW        := mps.pKW;
    if (pHP        <>mps.pHP)         then pHP        := mps.pHP;
    if (pCCM       <>mps.pCCM)        then pCCM       := mps.pCCM;
    if (pCylinders <>mps.pCylinders)  then pCylinders := mps.pCylinders;
    if (pValves    <>mps.pValves)     then pValves    := mps.pValves;
    if (pBodyID    <>mps.pBodyID)     then pBodyID    := mps.pBodyID;
    if (pDriveID   <>mps.pDriveID)    then pDriveID   := mps.pDriveID;
    if (pEngTypeID <>mps.pEngTypeID)  then pEngTypeID := mps.pEngTypeID;
    if (pFuelID    <>mps.pFuelID)     then pFuelID    := mps.pFuelID;
    if (pFuelSupID <>mps.pFuelSupID)  then pFuelSupID := mps.pFuelSupID;
    if (pBrakeID   <>mps.pBrakeID)    then pBrakeID   := mps.pBrakeID;
    if (pBrakeSysID<>mps.pBrakeSysID) then pBrakeSysID:= mps.pBrakeSysID;
    if (pCatalID   <>mps.pCatalID)    then pCatalID   := mps.pCatalID;
    if (pTransID   <>mps.pTransID)    then pTransID   := mps.pTransID;

    if (cvHPaxLO   <>mps.cvHPaxLO)    then cvHPaxLO   := mps.cvHPaxLO;
    if (cvKWaxDI   <>mps.cvKWaxDI)    then cvKWaxDI   := mps.cvKWaxDI;
    if (cvSecTypes <>mps.cvSecTypes)  then cvSecTypes := mps.cvSecTypes;
    if (cvWheels   <>mps.cvWheels)    then cvWheels   := mps.cvWheels;
    if (cvIDaxBT   <>mps.cvIDaxBT)    then cvIDaxBT   := mps.cvIDaxBT;
    if (cvCabs     <>mps.cvCabs)      then cvCabs     := mps.cvCabs;
    if (cvSUAxBR   <>mps.cvSUAxBR)    then cvSUAxBR   := mps.cvSUAxBR;
    if (cvAxles    <>mps.cvAxles)     then cvAxles    := mps.cvAxles;
  end;
end;
//================================== ������ �������������� ���������� ������
function TModelAuto.GetModelParamsUpdSql(mps: TModelParams): string;
begin
  if not Assigned(self) then Result:= '' else with FParams do begin // update
    if (pYStart    <>mps.pYStart)     then Result:= Result+'DMOSYEARSTART='     +IntToStr(mps.pYStart)+', ';
    if (pMStart    <>mps.pMStart)     then Result:= Result+'DMOSMONTHSTART='    +IntToStr(mps.pMStart)+', ';
    if (pYEnd      <>mps.pYEnd)       then Result:= Result+'DMOSYEAREND='       +IntToStr(mps.pYEnd)+', ';
    if (pMEnd      <>mps.pMEnd)       then Result:= Result+'DMOSMONTHEND='      +IntToStr(mps.pMEnd)+', ';
    if (pKW        <>mps.pKW)         then Result:= Result+'DMOSKW='            +IntToStr(mps.pKW)+', ';
    if (pHP        <>mps.pHP)         then Result:= Result+'DMOSHP='            +IntToStr(mps.pHP)+', ';
    if (pCCM       <>mps.pCCM)        then Result:= Result+'DMOSCCM='           +IntToStr(mps.pCCM)+', ';
    if (pCylinders <>mps.pCylinders)  then Result:= Result+'DMOSCylinders='     +IntToStr(mps.pCylinders)+', ';
    if (pValves    <>mps.pValves)     then Result:= Result+'DMOSValves='        +IntToStr(mps.pValves)+', ';
    if (pBodyID    <>mps.pBodyID)     then Result:= Result+'DMOSBodyCode='      +IntToStr(mps.pBodyID)+', ';
    if (pDriveID   <>mps.pDriveID)    then Result:= Result+'DMOSDriveCode='     +IntToStr(mps.pDriveID)+', ';
    if (pEngTypeID <>mps.pEngTypeID)  then Result:= Result+'DMOSEngineTypeCode='+IntToStr(mps.pEngTypeID)+', ';
    if (pFuelID    <>mps.pFuelID)     then Result:= Result+'DMOSFuelCode='      +IntToStr(mps.pFuelID)+', ';
    if (pFuelSupID <>mps.pFuelSupID)  then Result:= Result+'DMOSFuelSupCode='   +IntToStr(mps.pFuelSupID)+', ';
    if (pBrakeID   <>mps.pBrakeID)    then Result:= Result+'DMOSBrakeCode='     +IntToStr(mps.pBrakeID)+', ';
    if (pBrakeSysID<>mps.pBrakeSysID) then Result:= Result+'DMOSBRAKESYSCODE='  +IntToStr(mps.pBrakeSysID)+', ';
    if (pCatalID   <>mps.pCatalID)    then Result:= Result+'DMOSCATALCODE='     +IntToStr(mps.pCatalID)+', ';
    if (pTransID   <>mps.pTransID)    then Result:= Result+'DMOSTRANSCODE='     +IntToStr(mps.pTransID)+', ';
  end;
end;
//============================================== ������ ������ 2 � ������ ������
function TModelAuto.GetModelNodesList(OnlyVisible: boolean=False; flFromBase: boolean=False): TList;// must Free
// OnlyVisible=True - ������ ������� ����
var i: Integer;
    links2: TLinks;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  if flFromBase then links2:= GetModelNodesLinks else links2:= NodeLinks;
  with links2 do for i:= 0 to LinkCount-1 do begin
    if not OnlyVisible or TAutoTreeNode(GetLinkPtr(ListLinks[i])).Visible then
      Result.Add(ListLinks[i])
    else if flFromBase then TObject(ListLinks[i]).Free;
  end;
  if flFromBase then links2.ListLinks.Free;
end;
//=============================================== ������ ������ 2 ������ �� ����
function TModelAuto.GetModelNodesLinks: TLinks; // must Free Result
const nmProc = 'GetModelNodesLinks';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    lstLinks: TList;       // ������ ������ ��� ��������� ����������
    tnID, index, j, iCount, err2: Integer;
    pNode: TAutoTreeNode;
    haswares, hasFilters, HasPLs: Boolean;
    link2: TSecondLink;
    Nodes: TAutoTreeNodes;
  //---------------------- ��������� ��������� / ����������� ������� � ���������
  procedure AddParentLink(idp: Integer; hasw, hasM: Boolean);
  begin
    if (idp<1) then Exit; // ���� ���� ��� � ������ - �������
    index:= -1;
    if Nodes.NodeGet(idp, pNode) then index:= pNode.OrderNum-1;
    if (index<0) then Exit;
    if not assigned(lstLinks[index]) then  // ���� ����� �� ���� ��� � ������ - ���������
      lstLinks[index]:= TSecondLink.Create(0, 0, pNode, False, hasw, false, hasM)
    else begin
      link2:= lstLinks[index];             // ���� �������� ��� ���� - �������
      if (hasw=link2.NodeHasWares) and (hasM=link2.NodeHasPLs) then Exit;
      if (hasw and not link2.NodeHasWares) then link2.NodeHasWares:= hasw;
      if (hasM and not link2.NodeHasPLs) then link2.NodeHasPLs:= hasM;
    end;
    AddParentLink(pNode.ParentID, hasw, hasM); // ��������� ��������� / ����������� ������� � ���������
  end;
  //----------------------------------
begin
  Result:= TLinks.Create();
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  pNode:= nil;
  lstLinks:= TList.Create; // ��������� ������ �� ���-�� ����� �������
  err2:= 0;
  try
    ORD_IBD:= cntsOrd.GetFreeCnt;

    Nodes:= Cache.FDCA.AutoTreeNodesSys[TypeSys];
    with Nodes.NodesList do iCount:= Count; // ���������� ��� � ������ ��������������� ����� �������
    with lstLinks do begin
      Capacity:= iCount;  // ��������� ��������� ������
      for j:= 0 to iCount-1 do Add(nil);
    end;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    ORD_IBS.SQL.Text:= 'select * from GetModelNodes_new('+IntToStr(ID)+')';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      tnID := ORD_IBS.FieldByName('RNode').AsInteger;  // ��� ����
      index:= -1;
      if Nodes.NodeGet(tnID, pNode) and pNode.IsEnding // ���� ���� ���� � ��������
        and ((pNode.ID=pNode.MainCode) or pNode.Visible) then // ���� ������� ��� ������� �����������
        index:= pNode.OrderNum-1;
      if (index>-1) then begin                  // ������� ������� �������
        haswares:= (ORD_IBS.FieldByName('RHasWar').AsInteger=1);
        if (ORD_IBS.FieldIndex['RHasFilt']>-1) then
          hasFilters:= (ORD_IBS.FieldByName('RHasFilt').AsInteger=1) // ������� ������� �������� � ���� ������
        else hasFilters:= False;

        HasPLs:= (ORD_IBS.FieldByName('RhasPLs').AsInteger=1);

        lstLinks[index]:= TSecondLink.Create(ORD_IBS.FieldByName('Rsrc').AsInteger,
          ORD_IBS.FieldByName('RCount').AsFloat, pNode, True, haswares, hasFilters, HasPLs); // ������� ������ ����
        AddParentLink(pNode.ParentID, haswares, HasPLs); // ��������� ���������
      end else begin
        prMessageLOGS(nmProc+': not node ID= '+IntToStr(tnID), fLogCache+'_test', false);
        Inc(err2);
      end; // if index>-1
      cntsORD.TestSuspendException;
      ORD_IBS.Next;
    end;
    ORD_IBS.Close;

    Result.AddLinkItems(lstLinks); // ������� ����� ��������������� ������
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  prFree(lstLinks);
  if (err2>0) then prMessageLOGS(nmProc+': no Nodes='+IntToStr(err2), fLogCache, false);
end;
//=============================================== ������� 2-� ������ ���� ������
function TModelAuto.GetModelNodeIsSecondLink(nodeID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not NodeLinks.LinkExists(nodeID) then Exit;
  Result:= TSecondLink(NodeLinks[nodeID]).IsLinkNode;
end;
//===================================== must Free, ������ ������� �� ���� ������
function TModelAuto.GetModelNodeWaresList(nodeID: Integer; withChildNodes: boolean=True; flFromBase: boolean=False): TStringList;
const nmProc = 'GetModelNodeWaresList';
// ���������� ������ ������� �� ����, ��� withChildNodes=True � �������� �������� �����
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    iw: Integer;
    ware: TWareInfo;
  //---------------------------------- ��������� ������ � �������� �� ����� ������
  procedure AddLinkWares(idn: Integer);
  var i, idMain, iw: integer;
      lnks: TLinkList;
  begin
    if not NodeLinks.LinkExists(idn) then Exit;
    with TAutoTreeNode(GetLinkPtr(NodeLinks[idn])) do begin
      if not Visible then Exit; // ������ �������� ������ �� ������� �����
      idMain:= MainCode;        // ������ � �������� �������� �� ������� ����
    end;
    lnks:= NodeLinks.GetDoubleLinks(idMain);
    if Assigned(lnks) then with lnks do for i:= 0 to Count-1 do begin
      iw:= GetLinkID(Items[i]);
      if Cache.WareExist(iw) then with Cache.GetWare(iw) do
        if not IsArchive then Result.AddObject(Name, Pointer(iw));
    end;
    if withChildNodes then with TAutoTreeNode(GetLinkPtr(NodeLinks[idn])) do // �������� ���� �������� ����
      if Assigned(Children) then with Children do
        for i:= 0 to Count-1 do AddLinkWares(TAutoTreeNode(Objects[i]).ID);
  end;
  //----------------------------------
begin
  Result:= fnCreateStringList(True, DupIgnore);
  if not Assigned(self) then Exit;

  if not flFromBase then begin
    AddLinkWares(nodeID);
    Exit;
  end;

  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try  //---------------------------------------- �� ����
    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    ORD_IBS.SQL.Text:= 'select RWare from GetModelNodeWares('+IntToStr(ID)+', '+
      IntToStr(nodeID)+', '+fnIfStr(withChildNodes, '1', '0')+') group by RWare';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      iw:= ORD_IBS.FieldByName('RWare').AsInteger;  // ��� ������
      if Cache.WareExist(iw) then begin
        ware:= Cache.GetWare(iw, True);
        if (ware=NoWare) or ware.IsArchive or ware.IsINFOgr then ware:= nil;
      end else ware:= nil;
      if Assigned(ware) then Result.AddObject(ware.Name, Pointer(iw));
      cntsORD.TestSuspendException;
      ORD_IBS.Next;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
end;
//=============================== must Free, ������ ����� ������� �� ���� ������
function TModelAuto.GetModelNodeWares(nodeID: Integer; withChildNodes: boolean=True; flFromBase: boolean=False): Tai;
// ���������� ������ ����� ������� �� ����, ��� withChildNodes=True � ������ �������� �����
var i: integer;
begin
  setLength(Result, 0);
  if not Assigned(self) then Exit;
  with GetModelNodeWaresList(nodeID, withChildNodes, flFromBase) do try
    if Count>0 then begin
      setLength(Result, Count);
      for i:= 0 to Count-1 do Result[i]:= Integer(Objects[i]);
    end;
  finally Free; end;  
end;
//================================== ������� links � marks, True - ���� ��������
function TModelAuto.CheckDiffModelMarks(marks: TStringList): Boolean;
var i, j: Integer;
begin
  Result:= True;
  if EngLinks.LinkCount>marks.Count then Exit;
  for i:= 0 to marks.Count-1 do begin
    j:= TTwoCodes(marks.Objects[i]).ID2;
    if not EngLinks.LinkExists(j) then Exit;
  end;
  Result:= False;
end;
//================================================= �������� ���������� �� marks
procedure TModelAuto.SetModelMarks(marks: TStringList; pUserID: integer);
var i, iORD: Integer;
    s: string;
    tdCodes: Tai;
begin
  if not Assigned(marks) then exit;
  SetLength(tdCodes, 0);
  with EngLinks do begin  // ���������� ����������
    SetLinkStates(False);
    for i:= 0 to marks.Count-1 do try
      with TTwoCodes(marks.Objects[i]) do begin // ID1 - ��� TDT, ID2 - ��� ORD
        if (ID1<1) then raise Exception.Create('empty eng TD code');
        if (ID2<1) then ID2:= Cache.FDCA.Engines.GetIDBySubCode(ID1);
        if (ID2>0) and not Cache.FDCA.Engines.ItemExists(ID2) then ID2:= 0;
        if (ID2<1) then prAddItemToIntArray(ID1, tdCodes); // �������� ��� TD � ������, ���� ��� ��� ���
      end;
    except
      on E: Exception do prMessageLOGS('SetModelMarks: '+E.Message, fLogCache);
    end; // for

    if Length(tdCodes)>0 then CheckEnginesFromTDT(tdCodes, pUserID); // ��������� ��������� �� TDT

    for i:= 0 to marks.Count-1 do try
      with TTwoCodes(marks.Objects[i]) do begin
        if (ID1<1) then Continue;          // ���� ���������
        if (ID2<1) then ID2:= Cache.FDCA.Engines.GetIDBySubCode(ID1);
                           // ���� �� ����� - ����� � ���� �������� ������� ???
        if not Cache.FDCA.Engines.ItemExists(ID2) then begin
          if marks[i]='' then raise Exception.Create('empty eng.Mark');
          iORD:= 0; // ��� ������� (ID2 �� ��������)
          s:= Cache.FDCA.Models.SaveMarkAndGetID(iORD, ID1, ID, pUserID, marks[i]);
          if s<>'' then raise Exception.Create(s);
          ID2:= iORD;
        end;
        if (ID2<1) then Continue;
        if LinkExists(ID2) then begin
          TLink(Items[ID2]).State:= True;
          Continue;
        end;
        s:= AddModelEngLink(ID2, pUserID);
        if s<>'' then raise Exception.Create(s);
      end;
    except
      on E: Exception do prMessageLOGS('SetModelMarks: '+E.Message, fLogCache);
    end; // for
    DelNotTestedLinks;
    SortByLinkName;
  end;
  SetLength(tdCodes, 0);
end;
//=============================== �������� ������ ������ � ����������� ���������
function TModelAuto.AddModelEngLink(pEngID, pUserID: Integer): String;
const nmProc = 'AddModelEngLink';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrAddRecord));
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try                    // ����� � ���� ������ ������ � ����������� ���������
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'insert into LINKMODELSENGINES'+
        ' (LMENDMOSCODE, LMENDENGCODE, LMENSRCLECODE, LMENUSERID) values ('+
        ''+IntToStr(ID)+', '+IntToStr(pEngID)+', '+IntToStr(soTecDocBatch)+', '+
        IntToStr(pUserID)+') returning LMENCODE';
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Bof and ORD_IBS.Eof) then raise Exception.Create('empty link code');
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    EngLinks.CheckLink(pEngID, 0, Cache.FDCA.Engines[pEngID]); // ����� � ���
  except
    on E: EBOBError do Result:= nmProc+': '+E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': error add - '+E.Message, 'import', False);
    end;
  end;
end;

//******************************************************************************
//                       TModelsAuto - ������ �������
//******************************************************************************
constructor TModelsAuto.Create;
begin
  inherited Create;
  SetLength(FarModels, 1);
  FarModels[0]:= TModelAuto.Create(0, 0, 0, 0, '');
  CS_Models:= TCriticalSection.Create;
end;
//==============================================================================
destructor TModelsAuto.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= Low(FarModels) to High(FarModels) do
    if Assigned(FarModels[i]) then try prFree(FarModels[i]); except end;
  SetLength(FarModels, 0);
  prFree(CS_Models);
  inherited Destroy;
end;
//========================================== �������� ������ � ���������� � ����
function TModelsAuto.ModelAdd(var pModelID: Integer; pName: String;
         pVis, pTops: Boolean; UserID, MLineID: Integer; mps: TModelParams;
         pOrdNum: Integer=-1; pTDcode: Integer=0; marks: TStringList=nil): String;
const nmProc = 'ModelAdd';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    ModelLine: TModelLine;
    Model: TModelAuto;
    ii, jj, SysID: Integer;
    sUser, sModel, strSQL: String;
    lst, ls: TStringList;
begin
  Result:= '';
  pModelID:= 0;
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  sUser:= '';
  sModel:= '';
  lst:= TStringList.Create;
  ls:= TStringList.Create;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrAddRecord));
    if not Cache.FDCA.ModelLines.ModelLineExists(MLineID) then
      raise EBOBError.Create(MessText(mtkNotFoundModLine, IntToStr(MLineID)));

    if (pTDcode<0) then pTDcode:= 0;
    ModelLine:= Cache.FDCA.ModelLines[MLineID];
    SysID:= ModelLine.TypeSys;
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      sUser:= IntToStr(UserID);
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true); // ����� � ����
      ORD_IBS.SQL.Text:= 'insert into DIRMODELS ('+
        'DMOSNAME, DMOSISVISIBLE, DMOSISTOP, DMOSDRMLCODE, '+
        fnIfStr(mps.pMStart    <1, '', 'DMOSMONTHSTART, ')    +
        fnIfStr(mps.pYStart    <1, '', 'DMOSYEARSTART, ')     +
        fnIfStr(mps.pMEnd      <1, '', 'DMOSMONTHEND, ')      +
        fnIfStr(mps.pYEnd      <1, '', 'DMOSYEAREND, ')       +
        fnIfStr(mps.pKW        <1, '', 'DMOSKW, ')            +
        fnIfStr(mps.pHP        <1, '', 'DMOSHP, ')            +
        fnIfStr(mps.pCCM       <1, '', 'DMOSCCM, ')           +
        fnIfStr(mps.pCylinders <1, '', 'DMOSCYLINDERS, ')     +
        fnIfStr(mps.pValves    <1, '', 'DMOSVALVES, ')        +
        fnIfStr(mps.pBodyID    <1, '', 'DMOSBODYCODE, ')      +
        fnIfStr(mps.pDriveID   <1, '', 'DMOSDRIVECODE, ')     +
        fnIfStr(mps.pEngTypeID <1, '', 'DMOSENGINETYPECODE, ')+
        fnIfStr(mps.pFuelID    <1, '', 'DMOSFUELCODE, ')      +
        fnIfStr(mps.pFuelSupID <1, '', 'DMOSFUELSUPCODE, ')   +
        fnIfStr(mps.pBrakeID   <1, '', 'DMOSBRAKECODE, ')     +
        fnIfStr(mps.pBrakeSysID<1, '', 'DMOSBRAKESYSCODE, ')  +  // ��������� �������
        fnIfStr(mps.pCatalID   <1, '', 'DMOSCATALCODE, ')     +  // ��� ������������
        fnIfStr(mps.pTransID   <1, '', 'DMOSTRANSCODE, ')     +  // ��� ������� �������
        fnIfStr(pTDcode        <1, '', 'DMOSTDCODE, ')        +  // ��� TecDoc
        'DMOSUSERID'+fnIfStr(pOrdNum<0, '', ', DMOSORDERNUM')+
        ') values (:DMOSNAME, "'+fnIfStr(pVis, 'T', 'F')+'", "'+
        fnIfStr(pTops, 'T', 'F')+'", '+IntToStr(MLineID)+', '+
        fnIfStr(mps.pMStart    <1, '', IntToStr(mps.pMStart)+', ')    +
        fnIfStr(mps.pYStart    <1, '', IntToStr(mps.pYStart)+', ')    +
        fnIfStr(mps.pMEnd      <1, '', IntToStr(mps.pMEnd)+', ')      +
        fnIfStr(mps.pYEnd      <1, '', IntToStr(mps.pYEnd)+', ')      +
        fnIfStr(mps.pKW        <1, '', IntToStr(mps.pKW)+', ')        +
        fnIfStr(mps.pHP        <1, '', IntToStr(mps.pHP)+', ')        +
        fnIfStr(mps.pCCM       <1, '', IntToStr(mps.pCCM)+', ')       +
        fnIfStr(mps.pCylinders <1, '', IntToStr(mps.pCylinders)+', ') +
        fnIfStr(mps.pValves    <1, '', IntToStr(mps.pValves)+', ')    +
        fnIfStr(mps.pBodyID    <1, '', IntToStr(mps.pBodyID)+', ')    +
        fnIfStr(mps.pDriveID   <1, '', IntToStr(mps.pDriveID)+', ')   +
        fnIfStr(mps.pEngTypeID <1, '', IntToStr(mps.pEngTypeID)+', ') +
        fnIfStr(mps.pFuelID    <1, '', IntToStr(mps.pFuelID)+', ')    +
        fnIfStr(mps.pFuelSupID <1, '', IntToStr(mps.pFuelSupID)+', ') +
        fnIfStr(mps.pBrakeID   <1, '', IntToStr(mps.pBrakeID)+', ')   +
        fnIfStr(mps.pBrakeSysID<1, '', IntToStr(mps.pBrakeSysID)+', ')+
        fnIfStr(mps.pCatalID   <1, '', IntToStr(mps.pCatalID)+', ')   +
        fnIfStr(mps.pTransID   <1, '', IntToStr(mps.pTransID)+', ')   +
        fnIfStr(pTDcode        <1, '', IntToStr(pTDcode)+', ')        +
        sUser+fnIfStr(pOrdNum<0, '', ', '+IntToStr(pOrdNum))+') returning DMOSCODE';
      ORD_IBS.ParamByName('DMOSNAME').AsString:= pName;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then
        pModelID:= ORD_IBS.fieldByName('DMOSCODE').AsInteger;
      if (pModelID<1) then raise EBOBError.Create(MessText(mtkErrAddRecord));
      ORD_IBS.Close;
//---------------------------------------------------------------- DIRMODELS_add
      sModel:= IntToStr(pModelID);
      strSQL:= 'insert into DIRMODELS_add (DMOSaDmos, DMOSaUSERID,'+
               ' DMOSaDTIM, DMOSaText) values ('+sModel+', '+sUser+', ';
      case SysID of
        constIsCV: begin //------------------------------------------- ���������
          if (mps.cvHPaxLO<>'') then // �������� �� ��-��
            lst.Add(strSQL + IntToStr(cvtHP)+', "'+mps.cvHPaxLO+'");');
          if (mps.cvKWaxDI<>'') then // �������� ��� ��-��
            lst.Add(strSQL + IntToStr(cvtKW)+', "'+mps.cvKWaxDI+'");');
          if (mps.cvSecTypes<>'') then with fnSplit(',', mps.cvSecTypes) do try
            for ii:= 0 to Count-1 do // �������������� ���
              lst.Add(strSQL + IntToStr(cvtSecTyp)+', "'+Strings[ii]+'");');
          finally Free; end;
          if (mps.cvWheels<>'') then with fnSplit(',', mps.cvWheels) do try
            for ii:= 0 to Count-1 do // �������� ���� [���.����]/[��]
              lst.Add(strSQL + IntToStr(cvtWheel)+', "'+Strings[ii]+'");');
          finally Free; end;
          if (mps.cvIDaxBT<>'') then with fnSplit(',', mps.cvIDaxBT) do try
             for ii:= 0 to Count-1 do // ID �������������
              lst.Add(strSQL + IntToStr(cvtIDs)+', "'+Strings[ii]+'");');
          finally Free; end;
          if (mps.cvCabs<>'') then with fnSplit(',', mps.cvCabs) do try
             for ii:= 0 to Count-1 do // ������
              lst.Add(strSQL + IntToStr(cvtCabs)+', "'+Strings[ii]+'");');
          finally Free; end;
          if (mps.cvSUAxBR<>'') then with fnSplit(',', mps.cvSUAxBR) do try
             for ii:= 0 to Count-1 do // ��������/����������� (������ ����� TYPEDIR=cvtSusp)
              lst.Add(strSQL + IntToStr(cvtSusp)+', "'+Strings[ii]+'");');
          finally Free; end;
        end; // constIsCV

        constIsAx: begin //------------------------------------------------- ���
          if (mps.cvHPaxLO<>'') then  // �������� �� ��� [��] ��-��
            lst.Add(strSQL + IntToStr(axtLoad)+', "'+mps.cvHPaxLO+'");');
          if (mps.cvKWaxDI<>'') then  // ��������� [��] ��-��
            lst.Add(strSQL + IntToStr(axtDist)+', "'+mps.cvKWaxDI+'");');
          if (mps.cvSUAxBR<>'') then  // ������� ������� (������ ����� TYPEDIR=axtBrSize)
            lst.Add(strSQL + IntToStr(axtBrSize)+', "'+mps.cvSUAxBR+'");');
          if (mps.cvIDaxBT<>'') then with fnSplit(',', mps.cvIDaxBT) do try
             for ii:= 0 to Count-1 do // ��� ������
              lst.Add(strSQL + IntToStr(axtBoType)+', "'+Strings[ii]+'");');
          finally Free; end;
        end; // constIsAx
      end; // case

      if (lst.Count>0) then begin
        for ii:= 0 to lst.Count-1 do begin
          ls.Add(lst[ii]);
          if (ls.Count>100) then begin // ������ ������ �����
            ls.Insert(0, 'execute block as begin');
            ls.Add(' end');
            ORD_IBS.SQL.Clear;
            ORD_IBS.SQL.AddStrings(ls);
            ORD_IBS.ExecQuery;
            ls.Clear;
          end;
        end; // for ii:= 0
        if (ls.Count>0) then begin // ������ ��������� ������ �����
          ls.Insert(0, 'execute block as begin');
          ls.Add(' end');
          ORD_IBS.SQL.Clear;
          ORD_IBS.SQL.AddStrings(ls);
          ORD_IBS.ExecQuery;
        end;
      end; // if (lst.Count>0) then

//---------------------------------------------------
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    CS_Models.Enter;                            // ����� � ���
    try
      Model:= TModelAuto.Create(pModelID, pTDcode, pOrdNum, MLineID, pName);
      if (High(FarModels)<pModelID) then begin
        jj:= Length(FarModels);             // ��������� ����� �������
        SetLength(FarModels, pModelID+100); // � ���������� ��������
        for ii:= jj to High(FarModels) do if (ii<>pModelID) then FarModels[ii]:= nil;
      end;
      FarModels[pModelID]:= Model;
      with Model do begin
        FNodeLinks.dirNodes:= Cache.FDCA.AutoTreeNodesSys[SysID];
        IsTop:= pTops;
        IsVisible:= pVis;
        SetModelParams(mps, True);
      end;
    finally
      CS_Models.Leave;
    end;
    with ModelLine.FMLModelsSort do Delimiter:= LCharUpdate;
    if Assigned(marks) then Model.SetModelMarks(Marks, UserID); // ���������� ����������
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  prFree(lst);
  prFree(ls);
end;
//========================================== ������� ������, � ��������� �� ����
function TModelsAuto.ModelDel(pModelID: Integer): String;
const nmProc = 'ModelDel';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    Model: TModelAuto;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrDelRecord));
    if not ModelExists(pModelID) then
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(pModelID)));
    Model:= FarModels[pModelID];
    if Model.NodesExists then raise EBOBError.Create('������ ����� ����� � ������.');

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'delete from DIRMODELS where DMOSCODE='+IntToStr(pModelID);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    Cache.FDCA.ModelLines[Model.ModelLineID].ModelDelFromLine(pModelID);
    CS_Models.Enter;
    try
      prFree(Model);
    finally
      CS_Models.Leave;
    end;
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//============================================== �������� ������ �� ����� ������
function TModelsAuto.GetModel(pModelID: Integer): TModelAuto;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if ModelExists(pModelID) then Result:= FarModels[pModelID] else Result:= FarModels[0];
end;
//======================================== �������� ������������� ������ �� ����
function TModelsAuto.ModelExists(pModelID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pModelID>0) and (pModelID<length(FarModels)) and Assigned(FarModels[pModelID]);
end;
//==================================== ������ ������� ���������� ���������� ����
function TModelsAuto.GetMLModelsList(pModelLineID: Integer): Tai; // must Free
const nmProc = 'GetListModels';
var i, j: Integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  SetLength(Result, Length(FarModels));
  j:= 0;
  try
    for i:= 1 to High(FarModels) do
      if (FarModels[i]<> nil) and (FarModels[i].ModelLineID=pModelLineID) then begin
        Result[j]:= i;
        inc(j);
      end;
    if Length(Result)>j then SetLength(Result, j);
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
      SetLength(Result, 0);
    end;
  end;
end;
//===================== ������������� ���� �������� ���� ������� ���������� ����
procedure TModelsAuto.SetStates(pState: Boolean; pModelLineID: Integer=0);
var i: Integer;
begin
  if not Assigned(self) or (length(FarModels)<2) then Exit;
  CS_Models.Enter;
  try
    for i:= 1 to High(FarModels) do
      if Assigned(FarModels[i]) then with FarModels[i] do
        if (pModelLineID<1) or (ModelLineID=pModelLineID) then State:= pState;
  finally
    CS_Models.Leave;
  end;
end;
//=================================================== �������� ���������� � ����
function TModelsAuto.SaveMarkAndGetID(var pMarkID: Integer; pTDcode, pModelID, UserID: Integer; pName: String): String;
const nmProc = 'MarkAdd';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    p: Pointer;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrAddRecord));
    if pName='' then raise Exception.Create('empty eng.Mark');
    ORD_IBD:= cntsOrd.GetFreeCnt;
    pName:= copy(pName, 1, 30);
    try                                             // ����� � ����
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'select EngID from GetModelEngMarkByTD('+
        IntToStr(UserID)+', '+IntToStr(pModelID)+', '+IntToStr(pTDcode)+', :TDmark)';
      ORD_IBS.ParamByName('TDmark').AsString:= pName; // ���������� ����.
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Bof and ORD_IBS.Eof) then pMarkID:= 0
      else pMarkID:= ORD_IBS.fieldByName('EngID').AsInteger; // ��� ����.
      if pMarkID<1 then raise Exception.Create('empty eng.ORDcode');
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    p:= TEngine.Create(pMarkID, pTDcode, 0, pName);
    Cache.FDCA.Engines.CheckItem(p);
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': error add eng.mark '+pName+' - '+E.Message, fLogCache);
    end;
  end;
end;

//******************************************************************************
//                      TEngParams - ��������� ���������
//******************************************************************************
//=========================================================== �������� ���������
procedure TEngParams.Clear;
begin
  if not Assigned(self) then Exit;
  pCompFrom   := 0;  // ���������� * 100 ��
  pCompTo     := 0;  // ���������� * 100 ��
  pRPMtorqFrom:= 0;  // ������ �������� (Nm) ��� [��/���] ��
  pRPMtorqTo  := 0;  // ������ �������� (Nm) ��� [��/���] ��
  pBore       := 0;  // �������� * 1000
  pStroke     := 0;  // ��� ������ * 1000
  pYearFrom   := 0;  // ��� ������� ��
  pYearTo     := 0;  // ��� ������� ��
  pKWfrom     := 0;  // �������� ��� ��
  pRPMKWfrom  := 0;  // ��� [��/���] ��
  pKWto       := 0;  // �������� ��� ��
  pRPMKWto    := 0;  // ��� [��/���] ��
  pHPfrom     := 0;  // �������� �� ��
  pHPto       := 0;  // �������� �� ��
  pCCtecFrom  := 0;  // ���.����� � ���.��. ��
  pCCtecTo    := 0;  // ���.����� � ���.��. ��
  pMonFrom    := 0;  // ����� ������� ��
  pMonTo      := 0;  // ����� ������� ��
  pVal        := 0;  // ���������� ��������
  pCyl        := 0;  // ���������� ���������
  pCrank      := 0;  // ���-�� ����������� ���������
  pDesign     := 0;  // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
  pFuelType   := 0;  // ���, ��� �������            (KT 88) (TYPEDIR=12)
  pFuelMixt   := 0;  // ���, ������� �������        (KT 97) (TYPEDIR=5)
  pAspir      := 0;  // ���, ������ �������         (KT 99) (TYPEDIR=14)
  pType       := 0;  // ���, ��� ���������          (KT 80) (TYPEDIR=3)
  pNorm       := 0;  // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
  pCylDesign  := 0;  // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
  pManag      := 0;  // ���, ������ �����������     (KT 77) (TYPEDIR=17)
  pValCnt     := 0;  // ���, ������ �������         (KT 78) (TYPEDIR=18)
  pCoolType   := 0;  // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
  pSalesDesc  := ''; // ����������� �������
end;

//******************************************************************************
//                      TEngine - ���������
//******************************************************************************
constructor TEngine.Create(pID, pSubCode, pEngMFau: Integer; pName: String; WithLinks: Boolean=False);
begin
  inherited Create(pID, pSubCode, 0, pName, 0, WithLinks);
  FEngMFau:= pEngMFau;
  FParams := TEngParams.Create; // ��������� ���������
end;
//===========================================
destructor TEngine.Destroy;
begin
  prFree(FParams);
  inherited;
end;
//=============================== �������� / �������� ��������� ��������� � ����
procedure TEngine.SetParams(eps: TEngParams; flFill: Boolean);
begin
  if not Assigned(self) then Exit else with FParams do if flFill then begin
    pCompFrom   := eps.pCompFrom;    // ���������� * 100 ��
    pCompTo     := eps.pCompTo;      // ���������� * 100 ��
    pRPMtorqFrom:= eps.pRPMtorqFrom; // ������ �������� (Nm) ��� [��/���] ��
    pRPMtorqTo  := eps.pRPMtorqTo;   // ������ �������� (Nm) ��� [��/���] ��
    pBore       := eps.pBore;        // �������� * 1000
    pStroke     := eps.pStroke;      // ��� ������ * 1000
    pYearFrom   := eps.pYearFrom;    // ��� ������� ��
    pYearTo     := eps.pYearTo;      // ��� ������� ��
    pKWfrom     := eps.pKWfrom;      // �������� ��� ��
    pRPMKWfrom  := eps.pRPMKWfrom;   // ��� [��/���] ��
    pKWto       := eps.pKWto;        // �������� ��� ��
    pRPMKWto    := eps.pRPMKWto;     // ��� [��/���] ��
    pHPfrom     := eps.pHPfrom;      // �������� �� ��
    pHPto       := eps.pHPto;        // �������� �� ��
    pCCtecFrom  := eps.pCCtecFrom;   // ���.����� � ���.��. ��
    pCCtecTo    := eps.pCCtecTo;     // ���.����� � ���.��. ��
    pMonFrom    := eps.pMonFrom;     // ����� ������� ��
    pMonTo      := eps.pMonTo;       // ����� ������� ��
    pVal        := eps.pVal;         // ���������� ��������
    pCyl        := eps.pCyl;         // ���������� ���������
    pCrank      := eps.pCrank;       // ���-�� ����������� ���������
    pDesign     := eps.pDesign;      // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
    pFuelType   := eps.pFuelType;    // ���, ��� �������            (KT 88) (TYPEDIR=12)
    pFuelMixt   := eps.pFuelMixt;    // ���, ������� �������        (KT 97) (TYPEDIR=5)
    pAspir      := eps.pAspir;       // ���, ������ �������         (KT 99) (TYPEDIR=14)
    pType       := eps.pType;        // ���, ��� ���������          (KT 80) (TYPEDIR=3)
    pNorm       := eps.pNorm;        // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
    pCylDesign  := eps.pCylDesign;   // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
    pManag      := eps.pManag;       // ���, ������ �����������     (KT 77) (TYPEDIR=17)
    pValCnt     := eps.pValCnt;      // ���, ������ �������         (KT 78) (TYPEDIR=18)
    pCoolType   := eps.pCoolType;    // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
    pSalesDesc  := eps.pSalesDesc;   // ����������� �������
  end else begin
    if pCompFrom    <>eps.pCompFrom    then pCompFrom   := eps.pCompFrom;    // ���������� * 100 ��
    if pCompTo      <>eps.pCompTo      then pCompTo     := eps.pCompTo;      // ���������� * 100 ��
    if pRPMtorqFrom <>eps.pRPMtorqFrom then pRPMtorqFrom:= eps.pRPMtorqFrom; // ������ �������� (Nm) ��� [��/���] ��
    if pRPMtorqTo   <>eps.pRPMtorqTo   then pRPMtorqTo  := eps.pRPMtorqTo;   // ������ �������� (Nm) ��� [��/���] ��
    if pBore        <>eps.pBore        then pBore       := eps.pBore;        // �������� * 1000
    if pStroke      <>eps.pStroke      then pStroke     := eps.pStroke;      // ��� ������ * 1000
    if pYearFrom    <>eps.pYearFrom    then pYearFrom   := eps.pYearFrom;    // ��� ������� ��
    if pYearTo      <>eps.pYearTo      then pYearTo     := eps.pYearTo;      // ��� ������� ��
    if pKWfrom      <>eps.pKWfrom      then pKWfrom     := eps.pKWfrom;      // �������� ��� ��
    if pRPMKWfrom   <>eps.pRPMKWfrom   then pRPMKWfrom  := eps.pRPMKWfrom;   // ��� [��/���] ��
    if pKWto        <>eps.pKWto        then pKWto       := eps.pKWto;        // �������� ��� ��
    if pRPMKWto     <>eps.pRPMKWto     then pRPMKWto    := eps.pRPMKWto;     // ��� [��/���] ��
    if pHPfrom      <>eps.pHPfrom      then pHPfrom     := eps.pHPfrom;      // �������� �� ��
    if pHPto        <>eps.pHPto        then pHPto       := eps.pHPto;        // �������� �� ��
    if pCCtecFrom   <>eps.pCCtecFrom   then pCCtecFrom  := eps.pCCtecFrom;   // ���.����� � ���.��. ��
    if pCCtecTo     <>eps.pCCtecTo     then pCCtecTo    := eps.pCCtecTo;     // ���.����� � ���.��. ��
    if pMonFrom     <>eps.pMonFrom     then pMonFrom    := eps.pMonFrom;     // ����� ������� ��
    if pMonTo       <>eps.pMonTo       then pMonTo      := eps.pMonTo;       // ����� ������� ��
    if pVal         <>eps.pVal         then pVal        := eps.pVal;         // ���������� ��������
    if pCyl         <>eps.pCyl         then pCyl        := eps.pCyl;         // ���������� ���������
    if pCrank       <>eps.pCrank       then pCrank      := eps.pCrank;       // ���-�� ����������� ���������
    if pDesign      <>eps.pDesign      then pDesign     := eps.pDesign;      // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
    if pFuelType    <>eps.pFuelType    then pFuelType   := eps.pFuelType;    // ���, ��� �������            (KT 88) (TYPEDIR=12)
    if pFuelMixt    <>eps.pFuelMixt    then pFuelMixt   := eps.pFuelMixt;    // ���, ������� �������        (KT 97) (TYPEDIR=5)
    if pAspir       <>eps.pAspir       then pAspir      := eps.pAspir;       // ���, ������ �������         (KT 99) (TYPEDIR=14)
    if pType        <>eps.pType        then pType       := eps.pType;        // ���, ��� ���������          (KT 80) (TYPEDIR=3)
    if pNorm        <>eps.pNorm        then pNorm       := eps.pNorm;        // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
    if pCylDesign   <>eps.pCylDesign   then pCylDesign  := eps.pCylDesign;   // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
    if pManag       <>eps.pManag       then pManag      := eps.pManag;       // ���, ������ �����������     (KT 77) (TYPEDIR=17)
    if pValCnt      <>eps.pValCnt      then pValCnt     := eps.pValCnt;      // ���, ������ �������         (KT 78) (TYPEDIR=18)
    if pCoolType    <>eps.pCoolType    then pCoolType   := eps.pCoolType;    // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
    if pSalesDesc   <>eps.pSalesDesc   then pSalesDesc  := eps.pSalesDesc;   // ����������� �������
  end;
end;
//============================================================== �������� ������
function TEngine.GetStrEng(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) or not Assigned(EngParams) then exit;
  with EngParams do case ik of
    ik8_1: Result:= FName;          // ����������
    ik8_2: begin                    // ������ �������� ���
        if (pKWfrom>0) then Result:= Result+IntToStr(pKWfrom);
        if (pKWto>0) then
          Result:= Result+fnIfStr(Result='', '', ' - ')+IntToStr(pKWto);
      end;
    ik8_3: begin                    // ������ �������� ��
        if (pHPfrom>0) then Result:= Result+IntToStr(pHPfrom);
        if (pHPto>0) then
          Result:= Result+fnIfStr(Result='', '', ' - ')+IntToStr(pHPto);
      end;
    ik8_4: begin                    // ������ ���.����� � ���.��.
        if (pCCtecFrom>0) then Result:= Result+IntToStr(pCCtecFrom);
        if (pCCtecTo>0) then
          Result:= Result+fnIfStr(Result='', '', ' - ')+IntToStr(pCCtecTo);
      end;
    ik8_5: Result:= IntToStr(pCyl); // ������ ���������� ���������
    ik8_6: Result:= MfauName+' | '+Mark+' | '+EngCCstr+'���.��. | '+EngKWstr+'��� | '+EngHPstr+'�� | '+EngCYLstr+'���'; // WebName
    ik8_7: if Cache.FDCA.ManufAutoExist(EngMFau) then // MfauName
             Result:= Cache.FDCA.Manufacturers[EngMFau].Name;
  end;
end;
//==================================== ������ ���������� ��������� ��� ���������
function TEngine.GetViewList(Delim: String=cSpecDelim): TStringList; // must Free Result
const nmProc = 'GetViewList';
var s1, s2, sName, sValue: string;
    TS: TTypesInfoModel;
begin
  Result:= TStringList.Create;
  if not Assigned(self) or not Assigned(FParams) then exit;
  TS:= Cache.FDCA.TypesInfoModel;
  try
    if not Cache.FDCA.ManufAutoExist(EngMFau) then sValue:= ''
    else sValue:= Cache.FDCA.Manufacturers[EngMFau].Name;
    Result.Add('��� ���������'+Delim+sValue+fnIfStr(sValue='', '', ' ')+Mark);
    with EngParams do begin
      if pSalesDesc<>'' then Result.Add('����������� �������'+Delim+pSalesDesc);
      if (pType>0) and TS.ItemExists(pType) then                            // ���, ��� ��������� (KT 80) (TYPEDIR=3)
        Result.Add(TS.GetItemTypeName(pType)+Delim+TS.InfoItems[pType].Name);
      if (pYearFrom>0) or (pYearTo>0) then begin
        sName:= '��� �������';
        if (pYearFrom>0) and (pYearTo>0) then sName:= sName+' ��-��';
        sValue:= '';
        if (pYearFrom>0) then begin
          if pMonFrom>0 then s1:= fnMakeAddCharStr(IntToStr(pMonFrom), 2, '0')+'.' else s1:= '';
          sValue:= s1+copy(IntToStr(pYearFrom), 3, 2);
        end;
        if (pYearTo>0) then begin
          if pMonTo>0 then s1:= fnMakeAddCharStr(IntToStr(pMonTo), 2, '0')+'.' else s1:= '';
          sValue:= sValue+fnIfStr(sValue='', '', ' - ')+s1+copy(IntToStr(pYearTo), 3, 2);
        end;
        Result.Add(sName+Delim+sValue);
      end;
      if pRPMKWfrom>0 then s1:= IntToStr(pRPMKWfrom) else s1:= ''; // ��� [��/���] ��
      if pRPMKWto  >0 then s2:= IntToStr(pRPMKWto)   else s2:= ''; // ��� [��/���] ��
      if (s1='') and (s2<>'') then s1:= s2;
      if (s2='') and (s1<>'') then s2:= s1;
      if (pKWfrom>0) or (pKWto>0) then begin
        sName:= '�������� ���';
        if (pRPMKWfrom>0) or (pRPMKWto>0) then sName:= sName+' ��� [��/���]';
        if (pKWfrom>0) and (pKWto>0) then sName:= sName+' ��-��';
        sValue:= '';
        if (pKWfrom>0) then sValue:= sValue+IntToStr(pKWfrom)+fnIfStr(s1='', '', ' / ')+s1;
        if (pKWto>0) then
          sValue:= sValue+fnIfStr(sValue='', '', ' - ')+IntToStr(pKWto)+fnIfStr(s2='', '', ' / ')+s2;
        Result.Add(sName+Delim+sValue);
      end;
      if (pHPfrom>0) or (pHPto>0) then begin
        sName:= '�������� ��';
        if (pRPMKWfrom>0) or (pRPMKWto>0) then sName:= sName+' ��� [��/���]';
        if (pHPfrom>0) and (pHPto>0) then sName:= sName+' ��-��';
        sValue:= '';
        if (pHPfrom>0) then sValue:= sValue+IntToStr(pHPfrom)+fnIfStr(s1='', '', ' / ')+s1;
        if (pHPto>0) then
          sValue:= sValue+fnIfStr(sValue='', '', ' - ')+IntToStr(pHPto)+fnIfStr(s2='', '', ' / ')+s2;
        Result.Add(sName+Delim+sValue);
      end;
      if (pCCtecFrom>0) or (pCCtecTo>0) then begin
        sName:= '���.����� � ���.��.';
        if (pCCtecFrom>0) and (pCCtecTo>0) then sName:= sName+' ��-��';
        Result.Add(sName+Delim+EngCCstr);
      end;
      if (pCyl>0) then Result.Add('���-�� ���������'+Delim+EngCYLstr);
      if (pVal>0) then Result.Add('���-�� ��������'+Delim+IntToStr(pVal));
      if (pRPMtorqFrom>0) or (pRPMtorqTo>0) then begin
        sName:= '������ �������� (Nm) ��� (��/���)';
        if (pRPMtorqFrom>0) and (pRPMtorqTo>0) then sName:= sName+' ��-��';
        sValue:= '';
        if (pRPMtorqFrom>0) then sValue:= sValue+IntToStr(pRPMtorqFrom);
        if (pRPMtorqTo>0) then
          sValue:= sValue+fnIfStr(sValue='', '', ' - ')+IntToStr(pRPMtorqTo);
        Result.Add(sName+Delim+sValue);
      end;
      if (pCompFrom>0) or (pCompTo>0) then begin // ����������
        sName:= '������� ������';
        if (pCompFrom>0) and (pCompTo>0) then sName:= sName+' ��-��';
        sValue:= '';
        if (pCompFrom>0) then sValue:= sValue+FormatFloat('# ##0.000', pCompFrom/100)+':1';
        if (pCompTo>0) then
          sValue:= sValue+fnIfStr(sValue='', '', ' - ')+FormatFloat('# ##0.000', pCompTo/100)+':1';
        Result.Add(sName+Delim+sValue);
      end;
      if (pBore>0)   then Result.Add('������� ��������'+Delim+FormatFloat('# ##0.000', pBore/1000)); // ��������
      if (pStroke>0) then Result.Add('��� ������'+Delim+FormatFloat('# ##0.000', pStroke/1000));
      if (pCrank>0)  then Result.Add('���-�� ����������� ���������'+Delim+IntToStr(pCrank));
      if (pDesign>0) and TS.ItemExists(pDesign) then                        // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
        Result.Add(TS.GetItemTypeName(pDesign)+Delim+TS.InfoItems[pDesign].Name);
      if (pFuelType>0) and TS.ItemExists(pFuelType) then                    // ���, ��� �������            (KT 88) (TYPEDIR=12)
        Result.Add(TS.GetItemTypeName(pFuelType)+Delim+TS.InfoItems[pFuelType].Name);
      if (pFuelMixt>0) and TS.ItemExists(pFuelMixt) then                    // ���, ������� �������        (KT 97) (TYPEDIR=5)
        Result.Add(TS.GetItemTypeName(pFuelMixt)+Delim+TS.InfoItems[pFuelMixt].Name);
      if (pAspir>0) and TS.ItemExists(pAspir) then                          // ���, ������ �������         (KT 99) (TYPEDIR=14)
        Result.Add(TS.GetItemTypeName(pAspir)+Delim+TS.InfoItems[pAspir].Name);
      if (pNorm>0) and TS.ItemExists(pNorm) then                            // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
        Result.Add(TS.GetItemTypeName(pNorm)+Delim+TS.InfoItems[pNorm].Name);
      if (pCylDesign>0) and TS.ItemExists(pCylDesign) then                  // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
        Result.Add(TS.GetItemTypeName(pCylDesign)+Delim+TS.InfoItems[pCylDesign].Name);
      if (pManag>0) and TS.ItemExists(pManag) then                          // ���, ������ �����������     (KT 77) (TYPEDIR=17)
        Result.Add(TS.GetItemTypeName(pManag)+Delim+TS.InfoItems[pManag].Name);
      if (pValCnt>0) and TS.ItemExists(pValCnt) then                        // ���, ������ �������         (KT 78) (TYPEDIR=18)
        Result.Add(TS.GetItemTypeName(pValCnt)+Delim+TS.InfoItems[pValCnt].Name);
      if (pCoolType>0) and TS.ItemExists(pCoolType) then                    // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
        Result.Add(TS.GetItemTypeName(pCoolType)+Delim+TS.InfoItems[pCoolType].Name);
    end; // with Params
  except
    on E: Exception do begin
      Result.Clear;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//==================================================== ������ ������ 2 ���������
function TEngine.GetNodesLinks: TLinks; // must Free Result
const nmProc = 'GetNodesLinks';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    lstLinks: TList;       // ������ ������ ��� ��������� ����������
    tnID, index, j, iCount, err2: Integer;
    pNode: TAutoTreeNode;
    haswares, hasFilters: Boolean;
    link2: TSecondLink;
    Nodes: TAutoTreeNodes;
  //---------------------- ��������� ��������� / ����������� ������� � ���������
  procedure AddParentLink(idp: Integer; hasw: Boolean);
  begin
    if (idp<1) then Exit; // ���� ���� ��� � ������ - �������
    index:= -1;
    if Nodes.NodeGet(idp, pNode) then index:= pNode.OrderNum-1;
    if (index<0) then Exit;
    if not assigned(lstLinks[index]) then  // ���� ����� �� ���� ��� � ������ - ���������
      lstLinks[index]:= TSecondLink.Create(0, 0, pNode, False, hasw)
    else begin
      link2:= lstLinks[index];
      if not hasw or link2.NodeHasWares then Exit; // ���� �������� ��� ��� � ���� �� ��� ���� - �������
      link2.NodeHasWares:= hasw;
    end;
    AddParentLink(pNode.ParentID, hasw); // ��������� ��������� / ����������� ������� � ���������
  end;
  //----------------------------------
begin
  Result:= TLinks.Create();
  if not Assigned(self) or not EngHasNodes then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  pNode:= nil;
  lstLinks:= TList.Create; // ��������� ������ �� ���-�� ����� �������
  err2:= 0;
  try
    ORD_IBD:= cntsOrd.GetFreeCnt;

    Nodes:= Cache.FDCA.AutoTreeNodesSys[constIsAuto];  // ???
    with Nodes.NodesList do iCount:= Count; // ���������� ��� � ������ ��������������� ����� �������
    with lstLinks do begin
      Capacity:= iCount;  // ��������� ��������� ������
      for j:= 0 to iCount-1 do Add(nil);
    end;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    ORD_IBS.SQL.Text:= 'select * from GetEngNodes('+IntToStr(ID)+')';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      tnID := ORD_IBS.FieldByName('RNode').AsInteger;  // ��� ����
      index:= -1;
      if Nodes.NodeGet(tnID, pNode) and pNode.IsEnding // ���� ���� ���� � ��������
        and ((pNode.ID=pNode.MainCode) or pNode.Visible) then // ���� ������� ��� ������� �����������
        index:= pNode.OrderNum-1;
      if index>-1 then begin                  // ������� ������� �������
        haswares:= ORD_IBS.FieldByName('RHasWar').AsInteger=1;
        if ORD_IBS.FieldIndex['RHasFilt']>-1 then
          hasFilters:= ORD_IBS.FieldByName('RHasFilt').AsInteger=1 // ������� ������� �������� � ���� ���������
        else hasFilters:= False;
        lstLinks[index]:= TSecondLink.Create(ORD_IBS.FieldByName('Rsrc').AsInteger,
          ORD_IBS.FieldByName('RCount').AsFloat, pNode, True, haswares, hasFilters); // ������� ������ ����
        AddParentLink(pNode.ParentID, haswares); // ��������� ���������
      end else begin
        prMessageLOGS(nmProc+': not node ID= '+IntToStr(tnID), fLogCache+'_test', false);
        Inc(err2);
      end; // if index>-1
      cntsORD.TestSuspendException;
      ORD_IBS.Next;
    end;
    ORD_IBS.Close;

    Result.AddLinkItems(lstLinks); // ������� ����� ��������������� ������
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  prFree(lstLinks);
  if (err2>0) then prMessageLOGS(nmProc+': no Nodes='+IntToStr(err2), fLogCache, false);
end;
//=== ������.������ ������� � �������� � ��������� � ������� 3, Objects - WareID
function TEngine.GetEngNodeWaresWithUsesByFilters(NodeID: Integer; // must Free Result
         withChildNodes: boolean=True; sFilters: String=''): TStringList;
// sFilters - ���� �������� ��������� ����� �������
const nmProc = 'GetEngNodeWaresWithUsesByFilters';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    iType, i, iNode, iWare, index, iPart, pCount: integer;
    s, TypeName, str, nodeDelim, partDelim: String;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    arLst: TASL;
    WareCodes: Tai;
    lst: TStringList;
    flPart0: Boolean;
    ware: TWareInfo;
begin
  Result:= TStringList.Create;
  if not Assigned(self) or not EngHasNodes then Exit;
  lst:= TStringList.Create;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  setLength(WareCodes, 0);
  try
    nodes:= Cache.FDCA.AutoTreeNodesSys[constIsAuto];  // ???
    if not nodes.NodeExists(NodeID) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    node:= nodes[NodeID];

    if not node.IsEnding then str:= cWebSpace+cWebSpace+cWebSpace else str:= ''; // ������, ���� ��������� ���
    nodeDelim:= brcWebDelim;  // ����������� ����� / 0-� ������
    partDelim:= '---------- ��� ----------';      // ����������� ������
    partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // ������ ������ �����
//    partDelim:= cWebItalBegin+cWebBoldBlackBegin+partDelim+cWebBoldEnd+cWebItalEnd; // ������ ������ ������

    ORD_IBD:= cntsOrd.GetFreeCnt;

    sFilters:= StringReplace(sFilters, ' ', '', [rfReplaceAll]); // ������� ��� �������
//---------------------------------------------------------- ���� ������ �������
    if node.IsEnding and (sFilters<>'') then begin
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'select RWare, Rpart, Rtype, RtypeName, Rtext'+
        ' from GetModEngFiltWaresWithUseParts('+
        IntToStr(ID)+', '+IntToStr(NodeID)+', :sFilters)';
      ORD_IBS.ParamByName('sFilters').AsString:= sFilters;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        if (ORD_IBS.FieldByName('Rpart').AsInteger<0)
          and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
          sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
          TestCssStopException;
          ORD_IBS.Next;
          Continue;
        end;

        iWare:= ORD_IBS.FieldByName('RWare').AsInteger; // ��� ������
        if Cache.WareExist(iWare) then begin
          ware:= Cache.GetWare(iWare, True);
          if (ware=NoWare) or ware.IsArchive or ware.IsINFOgr then ware:= nil;
        end else ware:= nil;
        if not Assigned(ware) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        if (ORD_IBS.FieldByName('RtypeName').AsString='') then begin // ���� ������ ��� ������
          Result.AddObject('', Pointer(iWare));
          TestCssStopException;
          ORD_IBS.Next;
          Continue;
        end;

        pCount:= 0; // ������� ������
        if lst.Count>0 then lst.Clear;
        flPart0:= False;                    // �������� ������ ������� �� 1-�� ������
        while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger) do begin
          iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������

          if (iPart<0) and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
            sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
            TestCssStopException;
            ORD_IBS.Next;
            Continue;
          end;

          if (iPart=0) then flPart0:= True; // ���� 0-� ������ (�������� �������� ������� ������)
          if pCount>0 then
            if flPart0 then begin
              lst.Add(brcWebDelim); // ����������� 0-� ������
              flPart0:= False;
            end else lst.Add(partDelim); // ����������� ������

          while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
            and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // ������ ������� 1 ������
            iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
            TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
            s:= '';
            while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
              and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
              and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // ������ 1 ���� (��������)
              s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
              cntsORD.TestSuspendException;
              ORD_IBS.Next;
            end;
            s:= str+TypeName+fnIfStr(s='', '', ': '+s);  // ������ �� 1-�� ���� ������
            if (iPart=0) then  // �������� ������ 0-� ������
              s:= brcWebColorRedBegin+s+brcWebColorEnd; // ������� �����
            lst.Add(s);
          end; // while not ORD_IBS.Eof and (wareID=... and (iPart=

          inc(pCount); // ������� ������
        end; // while not ORD_IBS.Eof and (wareID=

        Result.AddObject(lst.Text, Pointer(iWare));
      end; // while not ORD_IBS.Eof
      ORD_IBS.Close;

      if Result.Count>1 then Result.CustomSort(ObjWareNameSortCompare); // ���������� �� ������������ ������

//------------------------------------------------------- ���� �� ������ �������
    end else begin
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
      ORD_IBS.SQL.Text:= 'select distinct RWare from GetEngNodeWares('+
        IntToStr(ID)+', '+IntToStr(nodeID)+', '+fnIfStr(withChildNodes, '1', '0')+')';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        i:= ORD_IBS.FieldByName('RWare').AsInteger;  // ��� ������
        if Cache.WareExist(i) then begin
          ware:= Cache.GetWare(i, True);
          if (ware=NoWare) or ware.IsArchive or ware.IsINFOgr then ware:= nil;
        end else ware:= nil;
        if Assigned(ware) then lst.AddObject(ware.Name, Pointer(i));
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
      ORD_IBS.Close;
      if (lst.Count>1) then lst.Sort;
      setLength(WareCodes, lst.Count);
      for i:= 0 to lst.Count-1 do WareCodes[i]:= Integer(lst.Objects[i]);

      SetLength(arLst, Length(WareCodes));

      ORD_IBS.SQL.Text:= 'select distinct RNode, RWare, Rpart, Rtype, RtypeName, Rtext'+
        ' from GetEngNodesWaresUseParts('+IntToStr(ID)+', '+IntToStr(nodeID)+', '+
        fnIfStr(node.IsEnding, '0', '1')+ // 1 - � �������� �������� ����� (������ ����� �������)
        ') order by RWare, RNode, Rpart, Rtype';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iWare:= ORD_IBS.FieldByName('RWare').AsInteger;  // ��� ������
        index:= fnInIntArray(iWare, WareCodes);          // ���� ������ ������ � �������� �����
        if (index<0) or not Cache.WareExist(iWare) then ware:= nil
        else begin
          ware:= Cache.GetWare(iWare, True);
          if (ware=NoWare) or ware.IsArchive or ware.IsINFOgr then ware:= nil;
        end;
        if not Assigned(ware) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        arLst[index]:= TStringList.Create; // ��������������� ������ ������ �������
        while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger) do begin
          iNode:= ORD_IBS.FieldByName('RNode').AsInteger;  // ��� ������� �������� ����
          if not nodes.NodeExists(iNode) then begin
            TestCssStopException;
            while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
              and (iNode=ORD_IBS.FieldByName('RNode').AsInteger) do ORD_IBS.Next;
            Continue;
          end;

          if not node.IsEnding then begin                // �������� ������ ������� �� 1-�� ����
            if arLst[index].Count>0 then arLst[index].Add(nodeDelim);  // ����������� �����
            s:= '���� - '+nodes[iNode].Name+': ';
            s:= brcWebColorBlueBegin+s+brcWebColorEnd; // ����� �����
            arLst[index].Add(s);
          end;
          pCount:= 0; // ������� ������
          while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
            and (iNode=ORD_IBS.FieldByName('RNode').AsInteger) do begin
            iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������
            if pCount>0 then arLst[index].Add(partDelim);   // ����������� ������

            while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
              and (iNode=ORD_IBS.FieldByName('RNode').AsInteger)
              and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin

              iType:= ORD_IBS.FieldByName('Rtype').AsInteger;       // ����� ���� ������
              TypeName:= ORD_IBS.FieldByName('RtypeName').AsString; // �������� ���� ������
              s:= '';
              while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
                and (iNode=ORD_IBS.FieldByName('RNode').AsInteger)
                and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin
                s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString; // �����
                cntsORD.TestSuspendException;
                ORD_IBS.Next;
              end;

              arLst[index].Add(str+TypeName+fnIfStr(s='', '', ': '+s)); // ������ �� 1-�� ����
            end; // while ... and (iWare= ... and (iNode= ... and (iPart=

            inc(pCount); // ������� ������
          end; // while ... and (WareID= ... and (iNode=
        end; // while ... and (WareID=
      end;
      ORD_IBS.Close;

      for i:= 0 to High(WareCodes) do // ������ ������� �� ������� � �������� �������
        if Assigned(arLst[i]) and (arLst[i].Count>0) then
          Result.AddObject(arLst[i].Text, Pointer(WareCodes[i]))
        else Result.AddObject('', Pointer(WareCodes[i]));
    end;

  except
    on E: Exception do begin
      Result.Clear;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  for i:= 0 to High(arLst) do if Assigned(arLst[i]) then prFree(arLst[i]);
  SetLength(arLst, 0);
  setLength(WareCodes, 0);
  prFree(lst);
end;

//============== ������ ������� �� �������� ������� ���� ��������� ��� ���������
function TEngine.GetEngNodeWareUsesView(nodeID: Integer; WareCodes: Tai; sFilters: String=''): TStringList; // must Free Result
const nmProc = 'GetEngNodeWareUsesView';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    iType, i, iNode, iWare, index, iPart, pCount: integer;
    s, TypeName, str, nodeDelim, partDelim: String;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    arLst: TASL;
    flPart0: Boolean;
begin
  Result:= TStringList.Create;
  if not Assigned(self) or not EngHasNodes or (Length(WareCodes)<1) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  SetLength(arLst, Length(WareCodes));
  try
    nodes:= Cache.FDCA.AutoTreeNodesSys[constIsAuto];   // ???
    if not nodes.NodeExists(NodeID) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    node:= nodes[NodeID];

    if not node.IsEnding then str:= cWebSpace+cWebSpace+cWebSpace else str:= ''; // ������, ���� ��������� ���
    nodeDelim:= brcWebDelim;       // ����������� ����� / 0-� ������
    partDelim:= '---------- ��� ----------';           // ����������� ������
    partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // ������ ������ �����
//    partDelim:= cWebItalBegin+cWebBoldBlackBegin+partDelim+cWebBoldEnd+cWebItalEnd; // ������ ������ ������

    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    ORD_IBS.SQL.Text:= 'select distinct RNode, RWare, Rpart, Rtype, RtypeName, Rtext'+
      ' from GetEngNodWareFiltUses('+IntToStr(ID)+', '+IntToStr(nodeID)+', '+
      fnIfStr(node.IsEnding, '0', '1')+ // 1 - � �������� �������� ����� (������ ����� �������)
      ', :sFilters) order by RWare, RNode, Rpart, Rtype';
    ORD_IBS.ParamByName('sFilters').AsString:= sFilters;
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      iWare:= ORD_IBS.FieldByName('RWare').AsInteger;  // ��� ������

      index:= fnInIntArray(iWare, WareCodes);          // ���� ������ ������ � �������� �����
      if (index<0) or not Cache.WareExist(iWare) or Cache.GetWare(iWare).IsArchive then begin
        TestCssStopException;
        while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger) do ORD_IBS.Next;
        Continue;
      end;

      arLst[index]:= TStringList.Create; // ��������������� ������ ������ �������
      while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger) do begin

        if (ORD_IBS.FieldByName('Rpart').AsInteger<0)
          and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
          sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
          TestCssStopException;
          ORD_IBS.Next;
          Continue;
        end;

        iNode:= ORD_IBS.FieldByName('RNode').AsInteger;  // ��� ������� �������� ����
        if not nodes.NodeExists(iNode) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
            and (iNode=ORD_IBS.FieldByName('RNode').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        if not node.IsEnding then begin                // �������� ������ �� 1-�� ����
          if arLst[index].Count>0 then arLst[index].Add(nodeDelim);  // ����������� �����
          s:= '���� - '+nodes[iNode].Name+': ';
          s:= brcWebColorBlueBegin+s+brcWebColorEnd; // ����� �����
          arLst[index].Add(s);
        end;
        pCount:= 0; // ������� ������
        flPart0:= False;
        while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
          and (iNode=ORD_IBS.FieldByName('RNode').AsInteger) do begin
          iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������

          if (iPart<0) and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
            sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
            TestCssStopException;
            ORD_IBS.Next;
            Continue;
          end;

          if (iPart=0) then flPart0:= True; // ���� 0-� ������ (�������� �������� ������� ������)
          if pCount>0 then
            if flPart0 then begin
              arLst[index].Add(brcWebDelim); // ����������� 0-� ������
              flPart0:= False;
            end else arLst[index].Add(partDelim);   // ����������� ������

          while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
            and (iNode=ORD_IBS.FieldByName('RNode').AsInteger)
            and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin

            iType:= ORD_IBS.FieldByName('Rtype').AsInteger;       // ����� ���� ������
            TypeName:= ORD_IBS.FieldByName('RtypeName').AsString; // �������� ���� ������
            s:= '';
            while not ORD_IBS.Eof and (iWare=ORD_IBS.FieldByName('RWare').AsInteger)
              and (iNode=ORD_IBS.FieldByName('RNode').AsInteger)
              and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin
              s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString; // �����
              cntsORD.TestSuspendException;
              ORD_IBS.Next;
            end;

            if (iPart=0) then  // �������� ������ 0-� ������
              s:= brcWebColorRedBegin+s+brcWebColorEnd; // ������� �����
            arLst[index].Add(str+TypeName+fnIfStr(s='', '', ': '+s)); // ������ �� 1-�� ����
          end; // while ... and (iWare= ... and (iNode= ... and (iPart=

          inc(pCount); // ������� ������
        end; // while ... and (WareID= ... and (iNode=
      end; // while ... and (WareID=
    end;
    ORD_IBS.Close;

    for i:= 0 to High(WareCodes) do // ������ ������� �� ������� � �������� �������
      if Assigned(arLst[i]) and (arLst[i].Count>0) then
        Result.AddObject(arLst[i].Text, Pointer(WareCodes[i]));
  except
    on E: Exception do begin
      Result.Clear;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  for i:= 0 to High(arLst) do if Assigned(arLst[i]) then prFree(arLst[i]);
  SetLength(arLst, 0);
end;

//******************************************************************************
//                      TEngines - ���������
//******************************************************************************
//=================================================== �������� ��������� �� ����
function TEngines.GetEngine(engID: integer): TEngine;
begin
  if not Assigned(self) then Result:= nil else Result:= DirItems[engID];
end;
//====================================================== ����� ��������� �� ����
function TEngines.FindEngineByTDcode(engTD: integer; var eng: TEngine): Boolean;
var i: integer;
begin
  eng:= nil;
  i:= GetIDBySubCode(engTD);
  if i>-1 then eng:= DirItems[i];
  Result:= Assigned(eng);
end;
//=========================================================== �������� ���������
function TEngines.AddEngine(var pID: Integer; pSys, pTDcode, pMFau, pUserID: Integer;
                             pMark: String; eps: TEngParams): String;
const nmProc = 'AddEngine';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    p: Pointer;
    s, sFiel, sVal: string;
    yfrom, yto: Integer;
begin
  Result:= '';
  pID:= 0;
  if not Assigned(self) then Exit;
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if (pMark='') or (pUserID<1) then
      raise EBOBError.Create(MessText(mtkNotEnoughParams));
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
//------------------------------------------------------------------------------
      sFiel:= 'DENGTDCODE, DENGENGINEMARK, DENGUSERID, DENGMFAU';
      sVal:= IntToStr(pTDcode)+', :pMark, '+IntToStr(pUserID)+', '+
             fnIfStr(pMFau>0, IntToStr(pMFau), 'null');
      if (pSys in [constIsAuto, constIsCV]) then begin
        case pSys of
          constIsCV  : sFiel:= sFiel+', DengByCV';
          constIsAuto: sFiel:= sFiel+', DengByAuto';
        end;
        sVal:= sVal+', "T"';
      end;
      if Assigned(eps) then with eps do begin
        if (pYearFrom>0) then yfrom:= pYearFrom*100+pMonFrom else yfrom:= 0;
        if (pYearTo>0)   then yto  := pYearTo*100+pMonTo     else yto  := 0;
        sFiel:= sFiel+', DENGMODFR, DENGMODTO, DENGCCTECFR, DENGCCTECTO, DENGHPFR'+
          ', DENGHPTO, DENGRPMKWFR, DENGRPMKWTO, DENGKWFR, DENGKWTO, DENGCOMPFR, DENGCOMPTO'+
          ', DENGRPMTORQFR, DENGRPMTORQTO, DENGSTROKE, DENGBORE, DENGVAL, DENGCYL'+
          ', DENGCRANK, DENGDESIGN, DENGFUELTYPE, DENGFUELMIXT, DENGASPIR, DENGTYPE'+
          ', DENGNORM, DENGCYLDESIGN, DENGMANAG, DENGVALCNT, DENGCOOLTYPE, DENGSALESDESC';
        sVal:= sVal+', '+fnIfStr(yfrom>0, IntToStr(yfrom),     'null')+ // ��� ������� ��
          ', '+fnIfStr(yto>0,          IntToStr(yto),          'null')+ // ��� ������� ��
          ', '+fnIfStr(pCCtecFrom>0,   IntToStr(pCCtecFrom),   'null')+ // ���.����� � ���.��. ��
          ', '+fnIfStr(pCCtecTo>0,     IntToStr(pCCtecTo),     'null')+ // ���.����� � ���.��. ��
          ', '+fnIfStr(pHPfrom>0,      IntToStr(pHPfrom),      'null')+ // �������� �� ��
          ', '+fnIfStr(pHPto>0,        IntToStr(pHPto),        'null')+ // �������� �� ��
          ', '+fnIfStr(pRPMKWFrom>0,   IntToStr(pRPMKWFrom),   'null')+ // ��� [��/���] ��
          ', '+fnIfStr(pRPMKWTo>0,     IntToStr(pRPMKWTo),     'null')+ // ��� [��/���] ��
          ', '+fnIfStr(pKWFrom>0,      IntToStr(pKWFrom),      'null')+ // �������� ��� ��
          ', '+fnIfStr(pKWTo>0,        IntToStr(pKWTo),        'null')+ // �������� ��� ��
          ', '+fnIfStr(pCompFrom>0,    IntToStr(pCompFrom),    'null')+ // ���������� * 100 ��
          ', '+fnIfStr(pCompTo>0,      IntToStr(pCompTo),      'null')+ // ���������� * 100 ��
          ', '+fnIfStr(pRPMtorqFrom>0, IntToStr(pRPMtorqFrom), 'null')+ // ������ �������� (Nm) ��� [��/���] ��
          ', '+fnIfStr(pRPMtorqTo>0,   IntToStr(pRPMtorqTo),   'null')+ // ������ �������� (Nm) ��� [��/���] ��
          ', '+fnIfStr(pStroke>0,      IntToStr(pStroke),      'null')+ // ��� ������ * 1000
          ', '+fnIfStr(pBore>0,        IntToStr(pBore),        'null')+ // �������� * 1000
          ', '+fnIfStr(pVal>0,         IntToStr(pVal),         'null')+ // ���������� ��������
          ', '+fnIfStr(pCyl>0,         IntToStr(pCyl),         'null')+ // ���������� ���������
          ', '+fnIfStr(pCrank>0,       IntToStr(pCrank),       'null')+ // ���-�� ����������� ���������
          ', '+fnIfStr(pDesign>0,      IntToStr(pDesign),      'null')+ // ���, ���������� ���������   (KT 96) (TYPEDIR=13)
          ', '+fnIfStr(pFuelType>0,    IntToStr(pFuelType),    'null')+ // ���, ��� �������            (KT 88) (TYPEDIR=12)
          ', '+fnIfStr(pFuelMixt>0,    IntToStr(pFuelMixt),    'null')+ // ���, ������� �������        (KT 97) (TYPEDIR=5)
          ', '+fnIfStr(pAspir>0,       IntToStr(pAspir),       'null')+ // ���, ������ �������         (KT 99) (TYPEDIR=14)
          ', '+fnIfStr(pType>0,        IntToStr(pType),        'null')+ // ���, ��� ���������          (KT 80) (TYPEDIR=3)
          ', '+fnIfStr(pNorm>0,        IntToStr(pNorm),        'null')+ // ���, ����� ��������� �����  (KT 63) (TYPEDIR=15)
          ', '+fnIfStr(pCylDesign>0,   IntToStr(pCylDesign),   'null')+ // ���, ��� ������� ���        (KT 79) (TYPEDIR=16)
          ', '+fnIfStr(pManag>0,       IntToStr(pManag),       'null')+ // ���, ������ �����������     (KT 77) (TYPEDIR=17)
          ', '+fnIfStr(pValCnt>0,      IntToStr(pValCnt),      'null')+ // ���, ������ �������         (KT 78) (TYPEDIR=18)
          ', '+fnIfStr(pCoolType>0,    IntToStr(pCoolType),    'null')+ // ���, ��� ������� ���������� (KT 76) (TYPEDIR=19)
          ', '+fnIfStr(pSalesDesc<>'', ':SALESDESC',           'null'); // ����������� ������
      end; // if Assigned(eps)
      ORD_IBS.SQL.Text:= 'insert into DIRENGINES ('+sFiel+') values ('+sVal+') returning DENGCODE';
//------------------------------------------------------------------------------
      if (Length(pMark)>30) then begin
        s:= pMark;
        pMark:= copy(pMark, 1, 30);
        prMessageLOGS(nmProc+': ���������� '+s+' �������� �� '+pMark, 'import', False);
      end;
      ORD_IBS.ParamByName('pMark').AsString:= pMark;
      if Assigned(eps) then with eps do if (pSalesDesc<>'') then
        ORD_IBS.ParamByName('SALESDESC').AsString:= pSalesDesc;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Eof and ORD_IBS.Bof) then pID:= ORD_IBS.Fields[0].AsInteger;
      if (pID<1) then raise Exception.Create(MessText(mtkErrAddRecord));
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    p:= TEngine.Create(pID, pTDcode, pMFau, pMark);
    CheckItem(p);

    CS_DirItems.Enter;
    try
      TEngine(p).SetParams(eps, True);
    finally
      CS_DirItems.Leave;
    end;

    // ������� ������ � �������� ???
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': '+E.Message, 'import', False);
    end;
  end;
end;
//=========================================================== �������� ���������
function TEngines.EditEngine(pID, pTDcode, pMFau, pSys, pUserID: Integer;
                             pMark: String; eps: TEngParams): String;
const nmProc = 'EditEngine';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    lst: TStringList;
    eng: TEngine;
    s: String;
begin
//  Result:= '';
  if not Assigned(self) then Exit;
  s:= '';
  ORD_IBS:= nil;
  try
    if not ItemExists(pID) then
      raise EBOBError.Create(MessText(mtkNotFoundEngine, IntToStr(pID)));
    lst:= TStringList.Create;
    try
      eng:= DirItems[pID]; //------------------ ���������, ���� �� ���-�� ������
      if (eng.TDCode<>pTDcode) then lst.Add('DENGTDCODE='+IntToStr(pTDcode)+',');
      if (eng.EngMFau<>pMFau) then lst.Add('DENGMFAU='+IntToStr(pMFau)+',');

      if Length(pMark)>30 then begin
        s:= pMark;
        pMark:= copy(pMark, 1, 30);
      end;
      if (eng.Mark<>pMark) then begin
        if s<>'' then prMessageLOGS(nmProc+': ���������� '+s+' �������� �� '+pMark, 'import', False);
        lst.Add('DENGENGINEMARK=:mark,');
      end;
      case pSys of
        constIsAuto: if not eng.EngByAuto then lst.Add('DengByAuto="T",');
        constIsCV  : if not eng.EngByCV then lst.Add('DengByCV="T",');
      end;
     if Assigned(eps) then with eng.EngParams do begin
        if (eps.pYearFrom<>pYearFrom) or (eps.pMonFrom<>pMonFrom) then
          lst.Add('DENGMODFR='+IntToStr(eps.pYearFrom*100+eps.pMonFrom)+',');
        if (eps.pYearTo<>pYearTo) or (eps.pMonTo<>pMonTo) then
          lst.Add('DENGMODTO='+IntToStr(eps.pYearTo*100+eps.pMonTo)+',');
        if (eps.pRPMtorqFrom<>pRPMtorqFrom) then lst.Add('DENGRPMTORQFR='+IntToStr(eps.pRPMtorqFrom)+',');
        if (eps.pRPMtorqTo<>pRPMtorqTo) then lst.Add('DENGRPMTORQTO='+IntToStr(eps.pRPMtorqTo)+',');
        if (eps.pCCtecFrom<>pCCtecFrom) then lst.Add('DENGCCTECFR='+IntToStr(eps.pCCtecFrom)+',');
        if (eps.pCCtecTo<>pCCtecTo)     then lst.Add('DENGCCTECTO='+IntToStr(eps.pCCtecTo)+',');
        if (eps.pHPfrom<>pHPfrom)       then lst.Add('DENGHPFR='+IntToStr(eps.pHPfrom)+',');
        if (eps.pHPto<>pHPto)           then lst.Add('DENGHPTO='+IntToStr(eps.pHPto)+',');
        if (eps.pRPMKWFrom<>pRPMKWFrom) then lst.Add('DENGRPMKWFR='+IntToStr(eps.pRPMKWFrom)+',');
        if (eps.pRPMKWTo<>pRPMKWTo)     then lst.Add('DENGRPMKWTO='+IntToStr(eps.pRPMKWTo)+',');
        if (eps.pKWFrom<>pKWFrom)       then lst.Add('DENGKWFR='+IntToStr(eps.pKWFrom)+',');
        if (eps.pKWTo<>pKWTo)           then lst.Add('DENGKWTO='+IntToStr(eps.pKWTo)+',');
        if (eps.pCompFrom<>pCompFrom)   then lst.Add('DENGCOMPFR='+IntToStr(eps.pCompFrom)+',');
        if (eps.pCompTo<>pCompTo)       then lst.Add('DENGCOMPTO='+IntToStr(eps.pCompTo)+',');
        if (eps.pStroke<>pStroke)       then lst.Add('DENGSTROKE='+IntToStr(eps.pStroke)+',');
        if (eps.pBore<>pBore)           then lst.Add('DENGBORE='+IntToStr(eps.pBore)+',');
        if (eps.pVal<>pVal)             then lst.Add('DENGVAL='+IntToStr(eps.pVal)+',');
        if (eps.pCyl<>pCyl)             then lst.Add('DENGCYL='+IntToStr(eps.pCyl)+',');
        if (eps.pCrank<>pCrank)         then lst.Add('DENGCRANK='+IntToStr(eps.pCrank)+',');
        if (eps.pDesign<>pDesign)       then lst.Add('DENGDESIGN='+IntToStr(eps.pDesign)+',');
        if (eps.pFuelType<>pFuelType)   then lst.Add('DENGFUELTYPE='+IntToStr(eps.pFuelType)+',');
        if (eps.pFuelMixt<>pFuelMixt)   then lst.Add('DENGFUELMIXT='+IntToStr(eps.pFuelMixt)+',');
        if (eps.pAspir<>pAspir)         then lst.Add('DENGASPIR='+IntToStr(eps.pAspir)+',');
        if (eps.pType<>pType)           then lst.Add('DENGTYPE='+IntToStr(eps.pType)+',');
        if (eps.pNorm<>pNorm)           then lst.Add('DENGNORM='+IntToStr(eps.pNorm)+',');
        if (eps.pCylDesign<>pCylDesign) then lst.Add('DENGCYLDESIGN='+IntToStr(eps.pCylDesign)+',');
        if (eps.pManag<>pManag)         then lst.Add('DENGMANAG='+IntToStr(eps.pManag)+',');
        if (eps.pValCnt<>pValCnt)       then lst.Add('DENGVALCNT='+IntToStr(eps.pValCnt)+',');
        if (eps.pCoolType<>pCoolType)   then lst.Add('DENGCOOLTYPE='+IntToStr(eps.pCoolType)+',');
        if (eps.pSalesDesc<>pSalesDesc) then lst.Add('DENGSALESDESC=:saledesc,');
      end;

      if (lst.Count<1) then Exit; // ���� ������ ������ - �������

      if (pUserID<1) then raise EBOBError.Create(MessText(mtkNotEnoughParams));
      lst.Insert(0, 'update DIRENGINES set ');
      lst.Add('DENGUSERID='+IntToStr(pUserID)+' where DENGCODE='+IntToStr(pID));

      ORD_IBD:= cntsOrd.GetFreeCnt; //---------------------------- ������ � ����
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
        ORD_IBS.SQL.AddStrings(lst);
        if (eng.Mark<>pMark) then ORD_IBS.ParamByName('mark').AsString:= pMark;
        if Assigned(eps) then if (eps.pSalesDesc<>eng.EngParams.pSalesDesc) then
          ORD_IBS.ParamByName('saledesc').AsString:= eps.pSalesDesc;
        ORD_IBS.ExecQuery;
        ORD_IBS.Transaction.Commit;
      finally
        prFreeIBSQL(ORD_IBS);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;
    finally
      prFree(lst);
    end;

    CS_DirItems.Enter;
    try
      if (eng.TDCode<>pTDcode) then eng.FSubCode:= pTDcode; //-------------- ���
      if (eng.EngMFau<>pMFau) then eng.FEngMFau:= pMFau;
      if (eng.Mark<>pMark) then eng.FName:= pMark;
      eng.SetParams(eps, False);
      case pSys of
        constIsAuto: if not eng.EngByAuto then eng.EngByAuto:= True;
        constIsCV  : if not eng.EngByCV then eng.EngByCV:= True;
      end;
    finally
      CS_DirItems.Leave;
    end;

  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//======== ������ ���������� ������������� (Object-TEngine)(����.�� �����������)
function TEngines.GetMfauEngList(mfau: integer): TStringList; // must clear Result
const nmProc = 'GetMfauEngList';
var i: Integer;
    eng: TEngine;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  try
    if not Cache.FDCA.ManufAutoExist(mfau) then
      raise Exception.Create(MessText(mtkNotValidParam)+' �������������, ���='+IntToStr(mfau));
    Result.Capacity:= FItemsList.Count;
    for i:= 0 to FItemsList.Count-1 do begin
      eng:= FItemsList[i];
      if eng.EngMFau<>mfau then Continue;
      Result.AddObject(eng.Mark, eng);
    end;
  except
    on E: Exception do begin
      Result.Clear;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
  if Result.Count>1 then Result.Sort;
end;

//=================================== ������������ ������ ��� ���������� �������
function GetNameForSort(pName: String; pY, pM: Integer): String;
const nmProc = 'GetNameForSort';
var s1, s2: String;
begin
  Result:= '';
  try
    if pY>0 then s1:= IntToStr(pY) else s1:= '    ';
    if pM>0 then s2:= IntToStr(pM) else s2:= '  ';
    Result:= fnMakeAddCharStr(pName, 60, True)+
             fnMakeAddCharStr(s1, 4, True)+fnMakeAddCharStr(s2, 2, True);
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//=== ��������� ������������ ������ � ��������� ��������� ������ � ��������� � P
function GetCutNameForSearchTD(pName: String): String;
begin
  Result:= fnGetStrPart(' ', fnGetStrPart('   ', Trim(pName)), 1);
end;

//******************************************************************************
end.

