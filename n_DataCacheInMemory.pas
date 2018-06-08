unit n_DataCacheInMemory;

interface

uses Windows, Classes, Types, SysUtils, Math, DateUtils, IniFiles, Forms, SyncObjs, Variants, Contnrs,
     IBDataBase, IBSQL, n_free_functions, v_constants, n_DataCacheAddition,
     n_constants, n_Functions, n_DataSetsManager, n_server_common, n_DataCacheObjects;

type                                            // ��������� ����� ��������
  TArrayKind = (taWare, taDprt, taEmpl, taFirm, taClie, taCurr, taFtyp, taFcls, taWaSt);
// �������� TWareInfo - ������, ���������, �����, ��� ������, ������� ��������� ���� ������ (1 ����)
  TKindBoolOptW = (ikwGrp, ikwPgr, ikwWare, ikwType, ikwTop, ikwFixT, ikwMod1, ikwMod2,
                   ikwNRet, ikwCatP, ikwPriz, ikwActN, ikwActM, ikwMod4, ikwMod5, ikwSea,
                   ikwNloa, ikwNpic);
  TFirmManagerParam = (fmpCode, fmpName, fmpEmail, fmpShort, fmpPref, fmpFacc);
  TFirmManagerParams = set of TFirmManagerParam;
  TSetWareParamKind = (spAll, spWithoutPrice, spOnlyPrice);

  //---------------------------------------------------------- ���� ��� ��������
  TAnalogLink = Class (TLink)
  public
    constructor Create(pSrcID: Integer; pWarePtr: Pointer; pAnalog, pCross: Boolean);
    property IsOldAnalog: boolean index ik8_3 read GetLinkBool write SetLinkBool; // ������� ������� �������
    property IsCross : boolean index ik8_4 read GetLinkBool write SetLinkBool; // ������� ������� �������
  end;

//---------------------------------------------------------------- ������� �����
  TSysItem = Class (TBaseDirItem)
  private
    FSysEmplID: Integer;
    FSysMail  : String;
  public
    constructor Create(pID: Integer; pName, pSysMail: String);
    property SysEmplID: Integer read FSysEmplID write FSysEmplID; // EmplID �������������� �� ������� �����
    property SysMail  : String  read FSysMail   write FSysMail;   // Email ��� ��������� �� ������� �����
  end;

//------------------------------------------------------------------------ �����
  TBrandItem = Class (TBaseDirItem)
  private
    FWarePrefix, FNameWWW, FadressWWW: String;
    FTDMFcodes: Tai;
  public
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    property WarePrefix: String read FWarePrefix write FWarePrefix; // ������� ������ � ������� Grossbee
    property NameWWW   : String read FNameWWW    write FNameWWW;    // ������������ ��� ����� ��������
    property adressWWW : String read FadressWWW  write FadressWWW;  // ����� - ������ �� ����
    property TDMFcodes : Tai    read FTDMFcodes; // ������ ����� TecDoc (TDT -> DATA_SUPPLIERS.DS_MF_ID)
    property DownLoadExclude: boolean index ik8_2 read GetDirBool write SetDirBool; // ������� "�� �������� � �����"
    property PictShowExclude: boolean index ik8_3 read GetDirBool write SetDirBool; // ������� "�� ���������� ��������"
  end;

//----------------------------------------------------------------------- ������
  TCurrency = Class (TBaseDirItem) // FName - shortname
  private
    FCurrRate: Single;
    FCliName : String;
  public
    constructor Create(pID: Integer; pName, pCliName: String; pRate: Single; pArh: Boolean);
    property Arhived  : boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ����������
//    property Available: boolean index ik8_4 read GetDirBool write SetDirBool; // ������� ������������
    property CurrRate : Single read FCurrRate write FCurrRate;                // ���� � ������
    property CliName  : String read FCliName  write FCliName;                 // ������������ � ��� ��� ��������
  end;

  TCurrencies = Class (TDirItems)  // ���������� �����
  private
    function GetCurrency(pCurrID: Integer): TCurrency; // �������� ������� ����������� �� ����
  public
    function GetCurrRate(pCurrID: Integer): Single;                         // �������� ���� ������ � ������
    property DirItems[index: Integer]: TCurrency read GetCurrency; default; // �������� ������� ����������� �� ����
  end;

//------------------------------------------------------------- ������ ���������
  TAttrGroupItem = Class (TDirItem) // 1 ������ ���������
  private // � Links -  ������ ��������� ������
    FTypeSys : Byte;   // ��� ������� 1 - ����, 2 - ���� and etc.
    FOrderNum: Word;   // ���������� ����� ������ ��� ������
  public
    constructor Create(pID, pTypeSys: Integer; pName: String; pOrderNum: Word=0);
    property TypeSys : Byte read FTypeSys;  // ��� ������� 1 - ����, 2 - ���� and etc.
    property OrderNum: Word read FOrderNum; // ���������� �����
    function GetListGroupAttrs: TList;      // must Free, ������ ������ �� �������� ������, ������. �� ������.� +������.
  end;

  TAttrGroupItems = Class (TDirItems)  // ���������� ����� ���������
  private
    FTypeSysLists: TArraySysTypeLists; // ����� ������������� ������� ����� �� ��������
  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    procedure SortTypeSysList(SysID: Word=0);                   // ��������� ������ ����� ��������� (SysID=0 - ���)
    function GetListAttrGroups(pTypeSys: Integer): TStringList; // �������� ������ ����� �������, ������������� �� ������������
    function GetAttrGroup(grpID: Integer): TAttrGroupItem;      // �������� ������  �� ����
  end;

//--------------------------------------------------------------------- ��������
  TAttributeItem = Class (TSubDirItem) // 1 �������
  private // FSubCode - ��� ������, FOrderNum - ���������� ����� �������� ��� ������
    FTypeAttr  : Byte;        // ���
    FPrecision : Byte;        // ���-�� ������ ����� ������� � ���� Double
    FListValues: TStringList; // ������ ��������� �������� ��������
//    function GetAttrTypeSys: Byte; // �������� ������� ��������
  public
    constructor Create(pID, pGroupID: Integer; pPrecision, pType: Byte;
                pOrderNum: Word; pName: String; pSrcID: Integer=0);
    destructor Destroy; override;
    property TypeAttr  : Byte        read FTypeAttr;   // ���
    property Precision : Byte        read FPrecision;  // ���-�� ������ ����� ������� � ���� Double
    property ListValues: TStringList read FListValues; // ������ �������� �������� � ����������� � ���-�� �� ����
    procedure CheckAttrStrValue(var pValue: String);   // ��������� ������������ �������� ��� ��������
  end;

  TAttributeItems = Class (TDirItems)  // ���������� ���������
  private
    FAttrValues: TDirItems; // ���������� �������� ���������
  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    function GetListAttrsOfGroup(pGrpID: Integer): TStringList; // must Free, ������ ������ �� �������� ������, ������. �� ������.� +������.
    function GetAttr(attrID: Integer): TAttributeItem;          // �������� ������� �� ����
    function GetAttrVal(attvID: Integer): TDirItem;             // �������� �������� �� ����
  end;

//------------------------------------------------------------ �������� Grossbee
  TGBAttribute = Class (TSubDirItem) // 1 �������
  private // FSubCode - ��� Grossbee, FOrderNum - ���������� �����, FSrcID - ���
          // � Links -  ������ ��������� �������� ��������, ������. � ���-�� �� ���� (TLink.srcID- ���)
    FGroup    : Integer;     // ��� ������
//    FPrecision: Byte;        // ���-�� ������ ����� ������� � ���� Double
  public
    constructor Create(pID, pSubCode, pGrpID, pOrderNum: Integer;
                       pPrecision, pType: Byte; pName: String);
//    destructor Destroy; override;
    property Group    : Integer     read FGroup write FGroup;      // ��� ������
//    property Precision: Byte        read FPrecision;  // ���-�� ������ ����� ������� � ���� Double
    procedure CheckAttrStrValue(var pValue: String);   // ��������� ������������ �������� ��� ��������
    procedure SortValues;
  end;

  TGBAttributes = Class (TOwnDirItems)  // ���������� ��������� Grossbee
  private
      // ������ ��������� (���������) - TSubDirItem, FSubCode - ��� Grossbee,
      // � Links -  ������ ������� � ���������� ������, ������. �� ������. ???
    FGroups   : TOwnDirItems; // ���������� ����� ���������, ������. �� ������.
    FAttValues: TOwnDirItems; // ���������� �������� ��������� (TBaseDirItem)
    FHasNewGroups: Boolean;   // ������� ������� ����� ����� ���������
  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    function GetGrp(grpID: Integer): TSubDirItem; // �������� ������ �� ����
    function GetAtt(attID: Integer): TGBAttribute; // �������� ������� �� ����
    function GetGBGroupAttsList(grpID: Integer): TList; // must Free, ������ ��������� ������, ������������� �� ������.� +������.
//    function GetAttIDByGroupAndName(grpID: Integer; pName: String): Integer; // �������� ID �� ������ + �����
    function GetAttIDByGroupAndSubCode(grpID, pSubCode: Integer): Integer;   // �������� ID �� ������ + SubCode
    property Groups: TOwnDirItems read FGroups;         // ���������� ����� ���������, ������. �� ������.
    property HasNewGroups: Boolean read FHasNewGroups write FHasNewGroups; // ������� ������� ����� ����� ���������
  end;

//------------------------------------------------------------------ ����� �����
  TStoreInfo = class (TBaseDirItem)
  private // FID - ��� ������
    function GetDprtCode: string; // ��� ������ ����������
  public
    property DprtID   : Integer read FID write FID;
    property DprtCode : string  read GetDprtCode; // ��� ������ ����������
    property IsVisible: boolean index ik8_2 read GetDirBool write SetDirBool;
    property IsReserve: boolean index ik8_3 read GetDirBool write SetDirBool;
//    property IsSale   : boolean index ik8_4 read GetDirBool write SetDirBool;
    property IsDefault: boolean index ik8_5 read GetDirBool write SetDirBool;
    property IsAddVis : boolean index ik8_6 read GetDirBool write SetDirBool;
//    property IsAccProc: boolean index ik8_6 read GetDirBool write SetDirBool;
  end;
  TarStoreInfo = array of TStoreInfo;

//--------------------------------------------------------------- ����� ��������
  TShipMethodItem = Class (TBaseDirItem)
  private // FID - ���, State- ������ ��������, FName - ������������
  public
    constructor Create(pID: Integer; pName: String; pTimeKey: Boolean=False; pLabelKey: Boolean=False);
    property TimeKey : boolean index ik8_2 read GetDirBool write SetDirBool; // ������� ������� ������� ��������
    property LabelKey: boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ������� ��������
  end;

//--------------------------------------------------------------- ����� ��������
  TShipTimeItem = Class (TBaseDirItem)
  private // FID - ���, State- ������ ��������, FName - ������������
    FHour, FMinute: Byte;   // ����, ������
  public
    constructor Create(pID: Integer; pName: String; pHour: Byte=0; pMinute: Byte=0);
    property Hour  : Byte read FHour   write FHour;   // ����
    property Minute: Byte read FMinute write FMinute; // ������
//    property SelfGetAllow: boolean index ik8_2 read GetDirBool write SetDirBool; // ������� ����������� ����������
  end;

//------------------------------------------------------------------ �����������
  TNotificationItem = Class (TBaseDirItem)
  private // FID - ���, FName - �����, State- ������ ��������
    FBegDate, FEndDate: TDateTime;
    FFirmFilials, FFirmClasses, FFirmTypes, FFirms: TIntegerList;
    function GetDateN(const ik: T8InfoKinds): TDateTime;         // �������� ����
    procedure SetDateN(const ik: T8InfoKinds; Value: TDateTime); // �������� ����
    function GetIntListN(const ik: T8InfoKinds): TIntegerList;   // �������� ������ �����
  public
    constructor Create(pID: Integer; pText: String);
    destructor Destroy; override;
    procedure CheckConditions(sFil, sClas, sTyp, sFirm: String); // ��������� ������� ����������
    property BegDate: TDateTime index ik8_1 read GetDateN write SetDateN; // ���� ������
    property EndDate: TDateTime index ik8_2 read GetDateN write SetDateN; // ���� ���������
    property FirmFilials: TIntegerList index ik8_1 read GetIntListN;      // ���� �������� �/�
    property FirmClasses: TIntegerList index ik8_2 read GetIntListN;      // ���� ��������� �/�
    property FirmTypes  : TIntegerList index ik8_3 read GetIntListN;      // ���� ����� �/�
    property Firms      : TIntegerList index ik8_4 read GetIntListN;      // ���� �/�
    property flFirmAdd  : boolean index ik8_3 read GetDirBool write SetDirBool; // ���� - ���������/��������� ���� arFirms
    property flFirmAuto : boolean index ik8_4 read GetDirBool write SetDirBool; // ���� �������� �/� � ����-�����������
    property flFirmMoto : boolean index ik8_5 read GetDirBool write SetDirBool; // ���� �������� �/� � ����-�����������
  end;

  TNotifications = Class (TDirItems)  // ���������� �����������
    function GetNotification(pID: integer): TNotificationItem;
  public
    function GetFirmNotifications(FirmID: integer): TIntegerList; // must Free, ������ ����������� �����
    property Items[pID: integer]: TNotificationItem read GetNotification; default;
  end;

//------------------------------------------------------------- ����� �� �������
  TWareAction = Class (TBaseDirItem)
  private // FID - ���, FName - ������� (��������), State - ������ ��������
    FBegDate, FEndDate: TDateTime;
    FComment, FNum, FIconExt: String; //
    function GetDateN(const ik: T8InfoKinds): TDateTime;         // �������� ����
    procedure SetDateN(const ik: T8InfoKinds; Value: TDateTime); // �������� ����
    function GetStrN(const ik: T8InfoKinds): String;             // �������� ������
    procedure SetStrN(const ik: T8InfoKinds; Value: String);     // �������� ������
  public
    IconMS: TMemoryStream;
    constructor Create(pID: Integer; pName, pComm: String; pBeg, pEnd: TDateTime);
    destructor Destroy; override;
    property BegDate    : TDateTime index ik8_1 read GetDateN write SetDateN; // ���� ������
    property EndDate    : TDateTime index ik8_2 read GetDateN write SetDateN; // ���� ���������
    property Num        : String    index ik8_2 read GetStrN  write SetStrN;
    property Comment    : String    index ik8_3 read GetStrN  write SetStrN;
    property IconExt    : String    index ik8_4 read GetStrN  write SetStrN;
    property IsAction   : boolean   index ik8_3 read GetDirBool write SetDirBool; // ���� - �����
    property IsCatchMom : boolean   index ik8_4 read GetDirBool write SetDirBool; // ���� - ���� ������
    property IsNews     : boolean   index ik8_5 read GetDirBool write SetDirBool; // ���� - �������
    property IsTopSearch: boolean   index ik8_6 read GetDirBool write SetDirBool; // ���� - ��� ������
  End;

//---------------------------------------------------------------- �������������
  TDprtInfo = class (TSubDirItem)
  private // FID, FName, State - ��� � ������������ �������������, ������� ��������
          // FOrderNum - MasterCode, FSubCode - ��� �������,
          // FLinks - ������ ������ � �������� ��������
    FDelayTime: Integer;
    FShort   : string;
    FSubName : string;   // Email ������ (�� �������) ��� ��������� ������� (�� ������)
    FAdress  : string;
    FLatitude, FLongitude: Single; // ����������
    // ������� ������ �� �������� ���-�� ����, 0- Date(), 1- Date()+1 � �.�.
    // Object - TTwoCodes, ����� ������ � ��������� � ���
    FSchedule: TObjectList;
    // ������ �������/������, Object - TTwoCodes, ��� ������, ���� � ����
    FStoresFrom: TObjectList;
    // ������ ���������� ���������� �������, Object - TCodeAndQty, ��� ������,
    // ��������� ����� ������ ����.��������, ������ ������� �����������
    FFillTT: TObjectList; // ������ ���������� ����������

    function GetStrD(const ik: T8InfoKinds): String;         // �������� ������
    procedure SetStrD(const ik: T8InfoKinds; Value: String); // �������� ������
    function GetIntD(const ik: T8InfoKinds): integer;         // �������� �����
    procedure SetIntD(const ik: T8InfoKinds; Value: integer); // �������� �����
    function GetDoubD(const ik: T8InfoKinds): Single;         // �������� ���.��������
    procedure SetDoubD(const ik: T8InfoKinds; Value: Single); // �������� ���.��������
    procedure SetFilialID(pID: integer);
  public
    constructor Create(pID, pSubCode, pOrderNum: Integer; pName: String;
                       pSrcID: Integer=0; WithLinks: Boolean=False);
    destructor Destroy; override;
    function IsInGroup(pGroup: Integer): Boolean; // ������� ��������� � �������� ������
//    function CheckShipAvailable(pShipDate: TDateTime; stID: Integer;  // ������� ����������� ��������
//             WithSVKDelay, WithSchedule, WithDprtDelay: Boolean): String; overload;
    function CheckShipAvailable(pShipDate: TDateTime; stID, SVKDelay: Integer;  // ������� ����������� ��������
             WithSchedule, WithDprtDelay: Boolean): String; // overload;
//    function GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer; // ������� ������ �������� �� ����
//                               WithSVKDelay, WithDprtDelay: Boolean): String; overload;
    function GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer; // ������� ������ �������� �� ����
                               SVKDelay: Integer; WithDprtDelay: Boolean): String; overload;
    property ParentID    : Integer index ik8_1 read GetIntD    write SetIntD;    // MasterCode
    property FilialID    : Integer index ik8_2 read GetIntD    write SetIntD;    // ��� �������
    property DelayTime   : Integer index ik8_3 read GetIntD    write SetIntD;    // ����� ������������ � ���
//    property Placement   : Integer index ik8_4 read GetIntD    write SetIntD;    // ��� ������
    property MainName    : string  index ik8_1 read GetStrD    write SetStrD;
    property ShortName   : string  index ik8_2 read GetStrD    write SetStrD;
    property ColumnName  : string  index ik8_3 read GetStrD    write SetStrD;    // ��������� ������� (�� ������)
    property MailOrder   : string  index ik8_4 read GetStrD    write SetStrD;    // Email ������ (�� �������)
    property FilialName  : string  index ik8_5 read GetStrD;
    property Adress      : string  index ik8_6 read GetStrD    write SetStrD;    // �����
    property IsStoreHouse: boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ������
    property IsFilial    : boolean index ik8_4 read GetDirBool write SetDirBool; // ������� �������
    property IsStoreRoad : boolean index ik8_5 read GetDirBool write SetDirBool; // ������� - �����-����
    property IsFilOnlyErr: boolean index ik8_6 read GetDirBool write SetDirBool; // ������� - ������ - ���������� ������ ������ � ������ � ��������
    property HasDprtFrom2: boolean index ik8_7 read GetDirBool write SetDirBool; // ������� - ���� ������ �������� >1 ���
    property AdrLatitude : Single  index ik8_1 read GetDoubD   write SetDoubD;   // ����������: ������
    property AdrLongitude: Single  index ik8_2 read GetDoubD   write SetDoubD;   // ����������: �������
    property ShipLinks   : TLinks read FLinks;  // ������ ������ � �������� ��������
    property Schedule    : TObjectList read FSchedule; // ������� ������ �� �������� ���-�� ����
    property StoresFrom  : TObjectList read FStoresFrom; // ������ �������/������
    property FillTT      : TObjectList read FFillTT;     // ������ ���������� ����������
  end;

//--------------------------------------------------- ����� / ������ / ���������
  TInfoWareOpts = class (TObject) // ��������� ������ (����� ��� ����, � �.�. ����-������)
    FManagerID  : Integer; // ��� ��������� (EMPLCODE)
    FTypeID     : Integer; // ��� ���� ������
    FProduct    : Integer; // �������
    FProductLine: Integer; // ����������� �������
    FProdDirect : Integer; // ����������� �� ���������
    FActionID   : Integer; // ��� �����
    FTopRating  : Byte;    // ������� ��� ������
    FmeasID     : Byte;    // ��� ��.���.
    FWareState  : Byte;    // ������
    FNameBS     : String;  // ������������ ������ �/������������
    FCommentUP  : String;  // �������� ������ � ������� ��������
    FWareSupName: String;  // ������������ ������ �� ����������
    FArticleTD  : String;  // Article TecDoc
    FMainName   : String;  // WAREMAINNAME
    FAnalogLinks: TLinks;  // ������ � ���������
    FONumLinks  : TLinkList; // ������ � ������������� ��������
    constructor Create(CS: TCriticalSection);
    destructor Destroy; override;
  end;

  TWareOpts = class (TObject) // ��������� ���������� ������ (�� ����� ��� ����-������)
    Fdivis       : Single;          // ���������
    Fweight      : Single;          // ���
    FLitrCount   : Single;          // ������
    FPrices      : TSingleDynArray; // ������ ����.��� � ���� � ����������� � PriceTypes
//    FSLASHCODE   : String;        // WARESLASHCODE
    FModelLinks  : TLinkList;       // ������ � ��������
    FFileLinks   : TLinks;          // ������ � ������� ��������
    FAttrLinks   : TLinks;          // ������ � ���������� � �� ����������
    FRestLinks   : TLinks;          // ������ � ��������� �� �������
    FSatelLinks  : TLinks;          // ������ � �������������� ��������
    FGBAttLinks  : TLinks;          // ������ � ���������� Grossbee � �� ����������
    FPrizAttLinks: TLinks;          // ������ � ���������� �������� � �� ����������
    constructor Create(CS: TCriticalSection);
    destructor Destroy; override;
  end;

  TWareTypeOpts = class (TObject) // ��������� ���� ������ (�� ����� ��� �������)
    FCountLimit : Single;          // ����� ����������
    FWeightLimit: Single;          // ����� ����
    constructor Create(pCountLimit: Single=0; pWeightLimit: Single=0);
  end;

  TWareInfo = class (TSubVisDirItem)
  private // FID, FName - ��� � ������������ ������/������/���������, FOrderNum - ��� ������ ������
          // State - ������� �������� ����������, FSubCode - SupID TecDoc (DS_MF_ID !!!)
          // FParCode - ��� �������� ������ ������/������/���������
    FComment     : String;               // �������� ������/������/���������
    FWareBoolOpts: set of TKindBoolOptW; // �������� ������/������/���������
    FInfoWareOpts: TInfoWareOpts;        // ��������� ���������� ������ (����� ��� ���� �������, � �.�. ����-������)
    FWareOpts    : TWareOpts;            // ��������� ���������� ������ (�� ����� ��� ����-������)
    FTypeOpts    : TWareTypeOpts;        // ��������� ���� ������ (�� ����� ��� �������)
    FDiscModLinks: TLinkList;            // ������ � ��������� ������
    function GetIntW(const ik: T16InfoKinds): Integer;              // �������� ���
    procedure SetIntW(const ik: T16InfoKinds; Value: Integer);      // �������� ���
    function GetStrW(const ik: T16InfoKinds): String;               // �������� ������
    procedure SetStrW(const ik: T16InfoKinds; Value: String);       // �������� ������
    function GetBoolW(const Index: TKindBoolOptW): boolean;         // �������� �������
    procedure SetBoolW(const Index: TKindBoolOptW; Value: boolean); // �������� �������
    function GetDoubW(const ik: T8InfoKinds): Single;              // �������� ���.��������
    procedure SetDoubW(const ik: T8InfoKinds; Value: Single);      // �������� ���.��������
    function GetWareLinks(const ik: T8InfoKinds): TLinks;        // �������� ������
    function GetWareLinkList(const ik: T8InfoKinds): TLinkList;  // �������� ������
    procedure CheckPrice(price: Single; pTypeInd: Integer); // �������� / ��������� ��������� ���� ������ � ���� �� ������
  protected
    procedure SetName(const Value: String); override; // �������� FName, FNameBS
  public
    CS_wlinks: TCriticalSection;     // ��� ��������� ������ � ��������
    constructor Create(pID, ParentID: Integer; pName: String);
    destructor Destroy; override;
    function RetailTypePrice(pTypeInd: Integer; currcode: Integer=cDefCurrency): double; // ��������� ���� ������ �� ������
    procedure GetFirmDiscAndPriceIndex(FirmID: Integer; var ind: Integer; // �������� ������ � ������ ������ �����
              var disc, disNext: double; contID: Integer=0);
    function RetailPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double;  // ��������� ���� ������ ��� �����
    function SellingPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double; // ��������� ���� ������ ��� �����
//    function MarginPrice(FirmID: Integer=IsWe; UserID: Integer=0;  // ���� ������ � �������� (% � ���������) ��� �������
//             currcode: Integer=cDefCurrency; contID: Integer=0): double; overload;
//    function MarginPrice(ffp: TForFirmParams): double; overload;
    function CalcFirmPrices(FirmID: Integer=IsWe; currID: Integer=cDefCurrency; // must Free, ���� ������ �� �����, ���������
                           contID: Integer=0): TDoubleDynArray; overload;
    function CalcFirmPrices(ffp: TForFirmParams): TDoubleDynArray; overload; // must Free !!!

    function CheckWareTypeSys(TypeSysID: Integer): Boolean;         // �������� �������������� � ������� AUTO / MOTO
    procedure SetWareParams(pPgrID: Integer; ibs: TIBSQL; fromGW:   // ��������� ��������� ������ �� Grossbee
              Boolean=False; spk: TSetWareParamKind=spAll);
    function GetSysModels(pSys: Integer; pMfau: Integer=0; flPL: Boolean=False): TList;  // must Free, TList �����.������� ������� �� ������ (Object - TModelAuto), ���������� - ������. + �.�. + ������.� + ������������
    function SysModelsExists(pSys: Integer): Boolean;               // ������� ������� �����.������� ������� �� ������
    function CheckHasModels(pSys: Integer): Boolean;                // �������� �������� ������� �����.������� ������� �� ������
    function GetWareAttrValuesView: TStringList;                    // must Free, ������ �������� ��������� ������ ��� ���������
    function GetWareAttrValuesByCodes(AttCodes: Tai): TStringList;  // must Free, ������ �������� ��������� ������ �� ����� � ������ �������
    function GetWareGBAttValuesView: TStringList;                   // must Free, ������ �������� ��������� Grossbee ������ ��� ���������
    function GetWareGBAttValuesByCodes(AttCodes: Tai): TStringList; // must Free, ������ �������� ��������� Grossbee ������ �� ����� � ������ �������
    function GetWareCriValuesView(SysID: Integer=0): TStringList;   // must Free, ������ �������� ��������� ������ ��� ���������
    procedure ClearOpts;                                            // ������� ������ (�������� ��� ��������)
    function CheckArticleLink(pArticle: String; pSupID: Integer;    // ���������� / ����� ����� � �������� TecDoc
             var ResCode: Integer; userID: Integer=0; flDelInfo: Boolean=True): String;
    function GetWareFiles: TarWareFileOpts;                        // ����� ���������� ������ �������� ������
    function CheckAnalogLink(AnalogID: Integer;   // �������� ���� � ��������/������� (def - ������ �������)
             pSrcID: Integer=soGrossBee; pCross: Boolean=True): Boolean;
    procedure DelAnalogLink(AnalogID: Integer;  pCross: Boolean=False); // ������� �� ���� ���� � ��������/������� (def - ������ �������)
    procedure SetAnalogLinkSrc(AnalogID, src: Integer);                 // �������� � ���� �������� ����� � ��������/�������
    procedure DelNotTestedAnalogs(pCross: Boolean=False; pDel: Boolean=False); // ������� �� ���� ������������� ����� � ���������/��������
    procedure SortAnalogsByName;  // ���������� �������� �� ������������
    function GetSrcAnalogs(ShowKind: Integer=-1): TObjectList; // must Free, ������ ����� �������� � �����������, Objects - TTwoCodes(wareID, link.SrcID)
    function Analogs: Tai;                                     // must Free, ������ ����� �������� ������
    function FindOriginalNum(ONumID, mfauID: Integer; OrigNum: String): Boolean; // ����� ������������� ������ � ������ ��.������� ������
    procedure SortOrigNumsWithSrc(var arCodes, arSrc: Tai);
    function IsMarketWare(FirmID: Integer=IsWe; contID: Integer=0): Boolean; overload; // ������� ������ ��� �������
    function IsMarketWare(ffp: TForFirmParams): Boolean; overload;
    function GetAnalogTypes(WithoutEmpty: Boolean=False): Tai; // must Free, ������ ����� ����� ��������
    function GetSatellites: Tai;                               // must Free, ������ ����� �����.�������
    function SatelliteExists: Boolean;                         // ������� ������� �����.�������
//    function RestExists(pContID: Integer=0): Boolean;          // ������� ������� ��������
    function GetActionParams(var ActTitle, ActText: String): Integer; // ���������� ��� � ����� ����� ������
    function GetFirstTDPictName: String;

    property GrpID        : Integer index ik16_1   read GetIntW;                     // ��� ������
    property AttrGroupID  : Integer index ik16_2   read GetIntW;                     // ��� ������ ���������
    property ManagerID    : Integer index ik16_3   read GetIntW    write SetIntW;    // ��� ��������� (EMPLCODE)
    property ArtSupTD     : Integer index ik16_4   read GetIntW    write SetIntW;    // SupID TecDoc (DS_MF_ID !!!)
    property PgrID        : Integer index ik16_5   read GetIntW    write SetIntW;    // ��� ���������
    property WareBrandID  : Integer index ik16_6   read GetIntW    write SetIntW;    // ��� ������ ������
    property measID       : Integer index ik16_7   read GetIntW    write SetIntW;    // ��� ��.���.
    property TypeID       : Integer index ik16_8   read GetIntW    write SetIntW;    // ��� ���� ������
    property ProdDirect   : Integer index ik16_9   read GetIntW    write SetIntW;    // ����������� �� ���������
    property GBAttGroup   : Integer index ik16_10  read GetIntW;                     // ��� ������ ��������� Grossbee
    property ActionID     : Integer index ik16_11  read GetIntW    write SetIntW;    // ��� �����
    property TopRating    : Integer index ik16_12  read GetIntW    write SetIntW;    // ������� ��� ������
    property PrizAttGroup : Integer index ik16_13  read GetIntW;                     // ��� ������ ��������� ��������
    property WareState    : Integer index ik16_14  read GetIntW    write SetIntW;    // ������
    property Product      : Integer index ik16_15  read GetIntW    write SetIntW;    // �������
    property ProductLine  : Integer index ik16_16  read GetIntW    write SetIntW;    // ����������� �������

    property IsGrp        : boolean index ikwGrp  read GetBoolW   write SetBoolW;   // ������� ������
    property IsPgr        : boolean index ikwPgr  read GetBoolW   write SetBoolW;   // ������� ���������
    property IsWare       : boolean index ikwWare read GetBoolW   write SetBoolW;   // ������� ������
    property IsType       : boolean index ikwType read GetBoolW   write SetBoolW;   // ������� ���� ������
    property IsTop        : boolean index ikwTop  read GetBoolW   write SetBoolW;   // ������� ���-������
    property HasFixedType : boolean index ikwFixT read GetBoolW;                    // ������� ��������� ���� ������
    property HasModelAuto : boolean index ikwMod1 read GetBoolW   write SetBoolW;   // ������� ������������ � ������� Auto
    property HasModelMoto : boolean index ikwMod2 read GetBoolW   write SetBoolW;   // ������� ������������ � ������� Moto
    property HasModelCV   : boolean index ikwMod4 read GetBoolW   write SetBoolW;   // ������� ������������ � ������� ����������
    property HasModelAx   : boolean index ikwMod5 read GetBoolW   write SetBoolW;   // ������� ������������ � ������� ����
    property IsNonReturn  : boolean index ikwNRet read GetBoolW   write SetBoolW;   // ������� ����������
    property IsCutPrice   : boolean index ikwCatP read GetBoolW   write SetBoolW;   // ������� ������
    property IsPrize      : boolean index ikwPriz read GetBoolW   write SetBoolW;   // ������� ����� �� ��������� �� ������
    property IsNews       : boolean index ikwActN read GetBoolW;                    // ������� ����� "�������"
    property IsCatchMom   : boolean index ikwActM read GetBoolW;                    // ������� ����� "���� ������"
    property ForSearch    : boolean index ikwSea  read GetBoolW   write SetBoolW;   // ������� ������� � ������
    property LoadPriceEx  : boolean index ikwNloa read GetBoolW;                    // ������� "�� �������� � �����
    property PictShowEx   : boolean index ikwNpic read GetBoolW;                    // ������� "�� ���������� ��������"

    property ModelsSorting: boolean index ik8_3   read GetDirBool write SetDirBool; // ������� ���������� �������
    property IsArchive    : boolean index ik8_4   read GetDirBool write SetDirBool; // ������� ��������� ������
    property IsSale       : boolean index ik8_5   read GetDirBool write SetDirBool; // ������� ����������
    property IsINFOgr     : boolean index ik8_6   read GetDirBool write SetDirBool; // ������� ����-������
    property IsAUTOWare   : boolean index ik8_7   read GetDirBool write SetDirBool; // ������� ������ AUTO
    property IsMOTOWare   : boolean index ik8_8   read GetDirBool write SetDirBool; // ������� ������ MOTO

    property divis        : Single  index ik8_1   read GetDoubW  write SetDoubW; // ���������
    property weight       : Single  index ik8_2   read GetDoubW  write SetDoubW; // ���������
    property CountLimit   : Single  index ik8_3   read GetDoubW  write SetDoubW; // ����� ����������
    property WeightLimit  : Single  index ik8_4   read GetDoubW  write SetDoubW; // ����� ����
    property LitrCount    : Single  index ik8_5   read GetDoubW  write SetDoubW; // ������

//    property SLASHCODE    : string  index ik16_1  read GetStrW  write SetStrW;   // WARESLASHCODE
    property StateName    : string  index ik16_1  read GetStrW;                  // ������������ ������� ������
    property WareSupName  : String  index ik16_2  read GetStrW   write SetStrW;  // ������������ ������ �� ����������
    property NameBS       : string  index ik16_3  read GetStrW;                  // ������������ ������ �/������������
    property Comment      : string  index ik16_4  read GetStrW   write SetStrW;  // �������� ������
    property CommentUP    : string  index ik16_5  read GetStrW;                  // �������� ������ � ������� ��������
    property BrandNameWWW : String  index ik16_6  read GetStrW;                  // ������������ ��� ����� �������� ������
    property WareBrandName: string  index ik16_7  read GetStrW;                  // ������������ ������ ������
    property MeasName     : string  index ik16_8  read GetStrW;                  // ������������ ��.���.
    property PgrName      : string  index ik16_9  read GetStrW;                  // ������������ ���������
    property ArticleTD    : string  index ik16_10 read GetStrW   write SetStrW;  // Article TecDoc
    property GrpName      : string  index ik16_11 read GetStrW;                  // ������������ ������
    property TypeName     : string  index ik16_12 read GetStrW;                  // ������������ ���� ������
    property CommentWWW   : string  index ik16_13 read GetStrW;                  // �������� ������ ��� Web � ������ ���� ������
    property BrandAdrWWW  : String  index ik16_14 read GetStrW;                  // ����� ��� ������ �� ���� ������
    property MainName     : string  index ik16_15 read GetStrW   write SetStrW;  // WAREMAINNAME
    property PrDirectName : string  index ik16_16 read GetStrW;                  // ������������ ����������� �� ���������

    property ONumLinks    : TLinkList index ik8_1 read GetWareLinkList;          // ������ � ������������� �������� (�����)
    property ModelLinks   : TLinkList index ik8_2 read GetWareLinkList;          // ������ � ��������
    property DiscModLinks : TLinkList index ik8_3 read GetWareLinkList;          // ������ � ��������� ������ (������/���������)
    property FileLinks    : TLinks    index ik8_1 read GetWareLinks;             // ������ � ������� ��������
    property AttrLinks    : TLinks    index ik8_2 read GetWareLinks;             // ������ � ���������� � �� ����������
    property RestLinks    : TLinks    index ik8_3 read GetWareLinks;             // ������ �� �������� � ���������
    property AnalogLinks  : TLinks    index ik8_4 read GetWareLinks;             // ������ � ���������        (�����)
    property SatelLinks   : TLinks    index ik8_5 read GetWareLinks;             // ������ � �������������� ��������
    property GBAttLinks   : TLinks    index ik8_6 read GetWareLinks;             // ������ � ���������� Grossbee � �� ����������
    property PrizAttLinks : TLinks    index ik8_7 read GetWareLinks;             // ������ � ���������� �������� � �� ����������

  end;

{//----------------------------------------------------- ������/��������� �������
// � TLinks - TLinkLink: LinkPtr- ������ �� ������(TWareInfo), State- ������� �������� ������,
// � DoubleLinks - TLink: LinkPtr- ������ �� ���������(TWareInfo), State- ������� �������� ���������
  TMarginGroups = class (TLinkLinks)
  private
  public
    function GetWareGroup(grID: integer): TWareInfo;                 // �������� TWareInfo ������
    function GetWareSubGroup(grID, pgrID: integer): TWareInfo;       // �������� TWareInfo ���������
    function GroupExists(grID: integer): Boolean;                    // �������� ������������� ������
    function SubGroupExists(grID, pgrID: integer): Boolean;          // �������� ������������� ��������� � ������
    function CheckGroup(grID: integer; SortAdd: Boolean=False): Boolean;           // ���������/�������� ������
    function CheckSubGroup(grID, pgrID: integer; SortAdd: Boolean=False): Boolean; // ���������/�������� ���������
    function GetGroupList(TypeSys: Integer=constIsAuto): TList;                   // must Free, ������ ������ �� ������ �� �������
    function GetSubGroupList(grID: integer; TypeSys: Integer=constIsAuto): TList; // must Free, ������ ������ �� ��������� � ������ �� �������
    procedure SortByName(grID: integer=0);                                        // ��������� ����� � ��������/����������� �� �����
    procedure SetLinkStatesAll(pState: Boolean);                                  // ������������� ���� �������� ���� �������
    procedure DelNotTestedLinksAll;                                               // ������� ��� ������ � State=False
  end;  }

//--------------------------------------- ��� (Grossbee->FISCALACCOUNTINGCENTER)
  TFiscalCenter = class (TBaseDirItem)
  private // FID - FACCCODE, FName - FACCNAME, State - ������� ��������
    FParent: Integer; // FACCMASTERCODE
    function GetRegion: Integer;   // ����� ������ (����������� �� ������������)
    function GetSaleType: Integer; // ������� AUTO/MOTO
    function GetROPfacc: Integer; // ��� ��� ���-� ������
    function CheckIsROPFacc: Boolean;  // ������� ��� ���-� ������ (����������� �� ������������)
  public
    BKEempls: TIntegerList;        // ����������
    constructor Create(pID, pParent: Integer; pName: String);
    destructor Destroy; override;
    property Parent    : Integer read FParent write FParent;
    property Region    : Integer read GetRegion;
    property ROPfacc   : Integer read GetROPfacc;
    property LastLevel : boolean index ik8_2 read GetDirBool write SetDirBool; // ������� ������� ������
    property IsAutoSale: boolean index ik8_3 read GetDirBool write SetDirBool; // ����� ������� AUTO
    property IsMotoSale: boolean index ik8_4 read GetDirBool write SetDirBool; // ����� ������� MOTO
  end;

  TEmplInfoItem = class;

//----------------------------------------------------- �������� ����� ���������
  TDestPoint = class (TBaseDirItem)
  private // FID - id, FName - ��������, State - ������� ��������
    FAdress: String; // �����
  public
    constructor Create(pID: Integer; pName, pAdress: String);
    property Adress: String read FAdress write FAdress; // �����
    property Disabled: boolean index ik8_2 read GetDirBool write SetDirBool; // ����������
  end;

//------------------------------------------------ �������� (Grossbee->CONTRACT)
  TContract = class (TSubDirItem)
  private // FID - CONTCODE, FName - CONTNUMBER, State - ������� ��������,
          // FSubCode - CONTSECONDPARTY  (CONTFIRSTPARTY - ?)
          // FOrderNum - ��� ������ �� ���������, // FSrcID - ContBusinessTypeCode - ������
    FContSumm, FCredLimit, FDebtSum, FOrderSum, FPlanOutSum, FRedSum, FVioletSum: Single;
    FContEmail, FWarnMessage, FContComments: String;
    // ..., CONTCRNCCODE, ContCreditCrncCode, ContContDelay, CONTDUTYCRNCCODE
    FWhenBlocked, {FCurrency,} FCredCurrency, FCredDelay, FDutyCurrency, FPayType, FStatus: Word;
    FContManager, FFacCenter, FContPriceType, FLegalEntity, FCredProfile: Integer;
    function GetIntFC(const ik: T16InfoKinds): Integer;          // �������� ���
    procedure SetIntFC(const ik: T16InfoKinds; Value: Integer);  // �������� ���
    function GetDoubFC(const ik: T8InfoKinds): Single;           // �������� ���.��������
    procedure SetDoubFC(const ik: T8InfoKinds; Value: Single);   // �������� ���.��������
    function GetStrFC(const ik: T16InfoKinds): String;            // �������� ������
    procedure SetStrFC(const ik: T16InfoKinds; Value: String);    // �������� ������
    function GetContManager: Integer;                            // ��� ������� ��������� ���������
    function GetContFaccName: String;                            // ������������ ���
    function GetContFaccParent: Integer;                         // ��� �������� ���
    function GetContFaccParentName: String;                      // ������������ �������� ���
  public
    ContBegDate, ContEndDate: TDateTime;
    ContProcDprts : Tai;                 // ���� ������� ��������� ������ ��������� // PartiallyFilled
    ContStorages  : TarStoreInfo;        // ������ ���������                        // PartiallyFilled
    ContDestPointCodes: TIntegerList;    // ���� �������� ����� ���������
    CS_cont       : TCriticalSection;    // ��� ��������� ����������
    constructor Create(pID, pFirmCode, pSysID: Integer; pNumber: String);
    destructor Destroy; override;
    procedure TestStoreArrayLength(kind: TArrayKind; len: integer; // ��������� ����� �������� �������
              ChangeOnlyLess: boolean=True; inCS: boolean=True);
    function FindContManager(var Empl: TEmplInfoItem): boolean;  // ����� ��������� ���������
    function CheckContManager(emplID: Integer): Boolean;         // �������� ��������� ���������
    function GetContBKEempls: TIntegerList; // not Free !!!, ���� ���������� ��������� �� ���
    function Get�ontStoreIndex(StorageID: integer): integer; // ���������� ������ ������ � ������� ContStorages
    function GetContDestPoint(destID: integer): TDestPoint;  // �������� ����.����� �� ����
    function ContDestPointExists(destID: integer): Boolean;  // ��������� ������� ����.�����
    function GetContVisStoreCodes: Tai;                      // ������ ����� ������� ������� ���������

    property ContFirm      : integer index ik16_1  read GetIntFC   write SetIntFC;
//    property ContCurrency  : integer index ik16_2  read GetIntFC   write SetIntFC;   // ������ ���������
    property DutyCurrency  : integer index ik16_3  read GetIntFC   write SetIntFC;
    property Status        : integer index ik16_4  read GetIntFC   write SetIntFC;   // ������ [cstUnKnown, cstClosed, cstBlocked, cstWorked]
    property WhenBlocked   : integer index ik16_5  read GetIntFC   write SetIntFC;
    property CredDelay     : integer index ik16_6  read GetIntFC   write SetIntFC;
    property CredCurrency  : integer index ik16_7  read GetIntFC   write SetIntFC;
    property MainStorage   : integer index ik16_8  read GetIntFC   write SetIntFC;   // ��� ������ �� ���������   // PartiallyFilled
    property Manager       : integer index ik16_9  read GetIntFC;                    // ��� ������� ���������     // PartiallyFilled
    property Filial        : integer index ik16_10 read GetIntFC;                    // ��� ������� (�� �������� ������)
    property FacCenter     : integer index ik16_11 read GetIntFC   write SetIntFC;   // ��� ���                   // PartiallyFilled
    property PayType       : integer index ik16_12 read GetIntFC   write SetIntFC;   // ��� ������: 0- ���, 1- ������, 2- �� ���.���-��                  // PartiallyFilled
    property FaccParent    : integer index ik16_13 read GetIntFC;                    // ��� �������� ���          // PartiallyFilled
    property ContPriceType : integer index ik16_14 read GetIntFC   write SetIntFC;   // ��� ������
    property LegalEntity   : integer index ik16_15 read GetIntFC   write SetIntFC;   // ��� ����.�����            // PartiallyFilled
    property CredProfile   : integer index ik16_16 read GetIntFC   write SetIntFC;   // ��� ������� ����.�������
    property ContSumm      : Single  index ik8_1   read GetDoubFC  write SetDoubFC;
    property CredLimit     : Single  index ik8_2   read GetDoubFC  write SetDoubFC;
    property DebtSum       : Single  index ik8_3   read GetDoubFC  write SetDoubFC;
    property OrderSum      : Single  index ik8_4   read GetDoubFC  write SetDoubFC;
    property PlanOutSum    : Single  index ik8_5   read GetDoubFC  write SetDoubFC;
    property RedSum        : Single  index ik8_6   read GetDoubFC  write SetDoubFC;  // ������������ �����
    property VioletSum     : Single  index ik8_7   read GetDoubFC  write SetDoubFC;  // ����� � ������ � ��������� �����
    property ContDefault   : boolean index ik8_2   read GetDirBool write SetDirBool; // CONTUSEBYDEFAULT
//    property EmptyInvoice  : boolean index ik8_3   read GetDirBool write SetDirBool; // ��������� ��� ���
    property HasSubPrice   : boolean index ik8_4   read GetDirBool write SetDirBool; // ������� ������� ���.������
    property SaleBlocked   : boolean index ik8_5   read GetDirBool write SetDirBool; // ������� - �������� ���������
    property Fictive       : boolean index ik8_6   read GetDirBool write SetDirBool; // ������� - ���������
//    property Disable       : boolean index ik8_7   read GetDirBool write SetDirBool; // ������� - ����������
    property HasAddVis     : boolean index ik8_8   read GetDirBool write SetDirBool; // ������� - ����� ������ ���.���������
    property ContEmail     : string  index ik16_2  read GetStrFC   write SetStrFC;   // EMAIL (���� ��� - �� arFirmInfo)
    property WarnMessage   : string  index ik16_3  read GetStrFC   write SetStrFC;
    property MainStoreStr  : string  index ik16_4  read GetStrFC;                    // ��� ������ �� ��������� ����������
    property LegalFirmName : string  index ik16_5  read GetStrFC;                    // ����.�����
    property CredCurrStr   : string  index ik16_6  read GetStrFC;                    // CredCurrency ����������
    property FaccName      : string  index ik16_7  read GetStrFC;                    // ������������ ���
    property FaccParentName: string  index ik16_8  read GetStrFC;                    // ������������ �������� ���
    property ContComments  : string  index ik16_9  read GetStrFC   write SetStrFC;   // �����������
  end;

  TContracts = class (TDirItems)       //
  private
    function GetContract(pID: integer): TContract;
  public
    property Items[pID: integer]: TContract read GetContract; default;
  end;

//--------------------------------------------------------------- ������� ������
  TDiscModel = Class (TBaseDirItem)
  private
    FDirectInd, FRating: Word;
    FSales: Integer;
    function GetIntDM(const ik: T8InfoKinds): Integer;          // ����� ��������
    procedure SetIntDM(const ik: T8InfoKinds; pValue: Integer); // �������� ����� ��������
  public
    constructor Create(pID, pDirect, pRate, pSales: Integer; pName: String);
    destructor Destroy; override;
    property DirectInd: Integer   index ik8_1 read GetIntDM write SetIntDM; // ������ ����������� � FProdDirects
    property Rating   : Integer   index ik8_2 read GetIntDM write SetIntDM; // �������
    property Sales    : Integer   index ik8_3 read GetIntDM write SetIntDM; // ���.������
  End;

  TDiscModels = Class (TObject)
  private
    FProdDirects: TStringList;
    FDiscModels: TObjectList;
    function GetDiscModel(pID: Integer): TDiscModel;          // ������
  public
    CS_DiscModels: TCriticalSection;
    EmptyModel: TDiscModel;
    constructor Create;
    destructor Destroy; override;
    property DmItems[index: Integer]: TDiscModel read GetDiscModel; default; // ������ �� ������� ����������� �� ����
    property ProdDirectList: TStringList read FProdDirects;   // �����������
    property DiscModels    : TObjectList read FDiscModels;    // �������
    procedure CheckProdDirect(pdID: Integer; pdName: String); // ��������/��������� �����������
    procedure CheckDiscModel(dmID, pdID, pRate, pSales: Integer; dmName: String); // ��������/��������� ������
    procedure DelProdDirect(pdID: Integer);                   // ������� �����������
    procedure DelDiscModel(dmID: Integer);                    // ������� ������
    procedure DelNotTestedDiscModels;                         // ������� ������ �������
    function GetDirectModelsList(pdID: Integer): TList;       // ������ �������� �����������
    function GetDirectModelsCount(pdID: Integer): Integer;    // ���-�� �������� �����������
    procedure SortDiscModels;                                 // ����������� �������
    function GetDirectIndex(pdID: Integer): Integer;          // ������ �����������
    function GetNextDirectModel(dmID: Integer): Integer;      // ��� ���������� ������� �����������
    function DirectExists(pdID: Integer): Boolean;            // ������������� �����������
  End;

//----------------------------------------------------- ������� ����.������� �/�
  TCredProfile = class (TBaseDirItem)
  private // FID - id, FName - ��������, State - ������� ��������
    FProfCredCurrency, FProfCredDelay: Word;
    FProfCredLimit, FProfDebtAll: Single;
  public
    constructor Create(pID, pCurr, pDelay: Integer; pName: String; pLimit, pDebt: Single);
    property Disabled: boolean index ik8_2 read GetDirBool write SetDirBool; // ����������
    property Blocked : boolean index ik8_3 read GetDirBool write SetDirBool; // ������������
    property ProfCredCurrency: Word   read FProfCredCurrency; //
    property ProfCredDelay   : Word   read FProfCredDelay;    //
    property ProfCredLimit   : Single read FProfCredLimit;    //
    property ProfDebtAll     : Single read FProfDebtAll;      //
    property WarnMessage     : String read FName; //
  end;

//------------------------------------------------------------------------ �����
  TFirmInfo = class (TSubDirItem)
  private // FID - FIRMCODE, FName - FIRMMAINNAME, State - ������� ��������,
          // FSubCode - ��� , FLinks - , FOrderNum -  // PartiallyFilled
    FSUPERVISOR, FFirmType, FHostCode: integer;       // ��� ��.������., ��� ����, ��� ��� ����� � ���������� // PartiallyFilled
    FContUnitOrd: integer;       // ��� ��������� unit-������ // PartiallyFilled
    FNUMPREFIX, FUPPERMAINNAME, FUPPERSHORTNAME, FActionText: string; // ������� ����� �������, ... // PartiallyFilled
    FBoolFOpts: set of T8InfoKinds; // ��������, ������� �� ����������� � FDirBoolOpts
    FBonusQty, FBonusRes: single;       // ���-�� ������� �/�, ������ �� unit-������ �������
    FResLimit, FAllOrderSum: single; // ����� �������, ����� �������
//    FLabelLinks: TLinks; // ������ � ����������
    function CheckFirmVINmail: boolean;         // �������� ������� WIN-��������
    function CheckFirmPriceLoadEnable: boolean; // �������� ���������� ���������� ������
    function CheckFirmOrderImportEnable: boolean; // �������� ���������� �������� �������
    function CheckShowZeroRests: boolean;         // �������� ������ ������� �/�������� � ������� (�����)
    function GetStrF(const ik: T8InfoKinds): String;           // �������� ������
    procedure SetStrF(const ik: T8InfoKinds; Value: String);   // �������� ������
    function GetIntF(const ik: T8InfoKinds): Integer;          // �������� ���
    procedure SetIntF(const ik: T8InfoKinds; Value: Integer);  // �������� ���
    function GetDoubF(const ik: T8InfoKinds): Double;          // �������� ���. ��������
    procedure SetDoubF(const ik: T8InfoKinds; pValue: Double); // �������� ���. ��������
    function GetBoolF(const ik: T8InfoKinds): boolean;         // �������� �������
    procedure SetBoolF(const ik: T8InfoKinds; Value: boolean); // �������� �������
    function GetRegional: Integer;
  public
    LastTestTime, LastDebtTime: TDateTime;
    FirmClients  : Tai;                 // ���� ����������� �����               // PartiallyFilled
    FirmClasses  : TIntegerList;        // ���� ��������� �����                 // PartiallyFilled
    FirmContracts: TIntegerList;        // ��������� �����                      // PartiallyFilled
    FirmManagers : TIntegerList;        // ��������� �����                      // PartiallyFilled
    FirmDiscModels: TObjectList;        // ����������� ������� ������ �����, Object - TTwoCodes:
                                        // ��� �����������, ��� �������, ������� ������ �/�
    LegalEntities: TObjectList;         // ����.����� �/�, Object - TBaseDirItem
    FirmDestPoints: TObjectList;        // �������� ����� �/�, Object - TDestPoint
    FirmCredProfiles: TObjectList;      // ������� ����.������� �/�, Object - TCredProf

    CS_firm      : TCriticalSection;    // ��� ��������� ����������
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    procedure TestFirmClients(codes: Tai; j: integer=0; inCS: boolean=True); // ��������� ������ ����������� �����
    function CheckContract(contID: Integer): boolean;  // �������� �������������� ��������� �����
    procedure SetContUnitOrd(contID: Integer);         // ��������/��������� ��������� unit-������
    function GetContract(var contID: Integer): TContract; // �������� �������� ����� �� ����
    function GetContracts: TStringList;                // must Free, �������� ������ ����������
    function GetDefContractID: Integer;                // �������� ��� def-���������
    function GetDefContract: TContract;                // �������� def-��������
    function GetAvailableContract: TContract;          // ����� ����������� �������� ����� (���������� ��������)
    function CheckFirmManager(emplID: Integer): Boolean;         // �������� ��������� �����
    function CheckFirmRegion(regNum: Integer): Boolean;          // �������� ������� �����
    function GetFirmManagersString(params: TFirmManagerParams=[fmpName, fmpShort]): String; // ������ ������/�����/���/Email-�� ���������� ����� (����� �������)
    function GetCurrentDiscModel(direct: Integer; var firmSales: Integer): TDiscModel; // ������� ������ ������ � ������ �� �����������
    function GetFirmDestPoint(destID: integer): TDestPoint;  // �������� ����.����� �� ����
    procedure CheckReserveLimit;                             // ��������� �������� ������ �������
    function GetOverSummAll(currID: integer; var OverSumm: Double): String; // �������� ����� ���������� ������ � �������� ������

    function GetFirmCredProfile(cpID: integer): TCredProfile; // �������� ����.������� �� ����

    property SUPERVISOR       : integer index ik8_2 read GetIntF    write SetIntF;    // ��� �������� ������������ // PartiallyFilled
    property FirmType         : integer index ik8_3 read GetIntF    write SetIntF;
    property HostCode         : integer index ik8_4 read GetIntF    write SetIntF;    // ��� ��� ����� � ����������
    property ContUnitOrd      : integer index ik8_5 read GetIntF    write SetIntF;    // ��� ��������� unit-������
    property Regional         : integer read GetRegional;                             // ��� ��������� �� def-��������� // ��������  fnRepWebArmSystemStatistic

    property Arhived          : boolean index ik8_2 read GetDirBool write SetDirBool;
    property PartiallyFilled  : boolean index ik8_3 read GetDirBool write SetDirBool;
    property HasVINmail       : boolean index ik8_4 read GetDirBool write SetDirBool; // ������� ������� WIN-��������
    property EnablePriceLoad  : boolean index ik8_5 read GetDirBool write SetDirBool; // ������� ���������� ���������� ������
    property SKIPPROCESSING   : boolean index ik8_6 read GetDirBool write SetDirBool; // ����� ����������� ���� // PartiallyFilled
    property Blocked          : boolean index ik8_7 read GetDirBool write SetDirBool; // ������� ���������� ����� � Weborderfirms
    property SendInvoice      : boolean index ik8_8 read GetDirBool write SetDirBool; // ������� �������� ���������
    property SaleBlocked      : boolean index ik8_2 read GetBoolF   write SetBoolF;   // ������� ������� ��������
    property IsFinalClient    : boolean index ik8_3 read GetBoolF   write SetBoolF;   // ������� ��������� �������
    property EnableOrderImport: boolean index ik8_4 read GetBoolF   write SetBoolF;   // ������� ���������� �������� �������
    property ShowZeroRests    : boolean index ik8_5 read GetBoolF   write SetBoolF;   // ������� ������ ������� ��� �������� � ������� (�����)

    property UPPERSHORTNAME   : string  index ik8_1 read GetStrF    write SetStrF;    // FIRMUPPERSHORTNAME     // PartiallyFilled
    property UPPERMAINNAME    : string  index ik8_2 read GetStrF    write SetStrF;    // FIRMUPPERMAINNAME      // PartiallyFilled
    property NUMPREFIX        : string  index ik8_3 read GetStrF    write SetStrF;    // ������� ����� �������  // PartiallyFilled
    property ActionText       : string  index ik8_4 read GetStrF    write SetStrF;    // ��������� ������� � �����
    property FirmTypeName     : string  index ik8_5 read GetStrF;                     // �������� ���� �����
//    property LabelLinks       : TLinks read FLabelLinks;                            // ������ � ����������
    property BonusQty         : Double  index ik8_1 read GetDoubF   write SetDoubF;   // ���-�� ������� �/�
    property BonusRes         : Double  index ik8_2 read GetDoubF   write SetDoubF;   // ���-�� ������� �/� � �������
    property ResLimit         : Double  index ik8_3 read GetDoubF   write SetDoubF;   // ����� �������
    property AllOrderSum      : Double  index ik8_4 read GetDoubF   write SetDoubF;   // ����� �������

/////////////////////////////////////////////
  end;

  TFirms = class (Tobject)       // ���������
  private
    FarFirmInfo: Array of TFirmInfo;
    function GetFirm(pID: integer): TFirmInfo;
  public
    CS_firms: TCriticalSection; // ��� ��������� ����������
    constructor Create;
    destructor Destroy; override;
    procedure CutEmptyCode;
    procedure AddFirm(pID: integer);
    function FirmExists(pID: Integer): Boolean;
    property Items[pID: integer]: TFirmInfo read GetFirm; default;
  end;

//-------------------------------------------------------- ������������ - ������
  TClientInfo = class (TSubDirItem)  // FOrderNum - SearchCurrency, FSrcID - MaxRowShowAnalogs
  private // FID - PRSNCODE, FName - ���, State - ������� ��������, FSubCode - ��� �����
    FCountSearch, FCountQty, FCountConnect, FLastContract: integer;
    FDEFDELIVERYTYPE, FBlockKind{, FLoadPriceCount}: Byte;  //    FDEFACCOUNTINGTYPE,
    FLogin, FPassword, FSid, FPost: string; // �����, ������, sid, ��������� // PartiallyFilled
    FCliPay: Boolean;
    function GetStrC(const ik: T8InfoKinds): String;               // �������� ������
    procedure SetStrC(const ik: T8InfoKinds; Value: String);       // �������� ������
    function GetIntC(const ik: T16InfoKinds): Integer;              // �������� ���
    procedure SetIntC(const ik: T16InfoKinds; Value: Integer);      // �������� ���
    procedure UpdateStorageOrderC; // ��������� ������������ ������ ������� ������� ������ ������� ������� ���������
  public
    TestSearchCountDay, LastTestTime, LastCountQtyTime, LastCountConnectTime,
      LastBaseAutorize, LastAct: TDateTime;
//    LastPriceLoadTime: TDateTime; // ����� ���������� ���������� ������
    TmpBlockTime: TDateTime;          // ����� ��������� ��������� ����������
    CliContracts: TIntegerList;       // ���� ���������� �������                      // PartiallyFilled
//    CliContStores: TObjectList;       // ������ ������� �� ���������� (TIntegerList) � �����.� CliContracts
//    CliContMargins: TObjectList;      // ������� ������� �� ���������� (TLinkList) � �����.� CliContracts
    CliContDefs: TObjectList;         // ��������� ������� �� ���������� (TTwoCodes) � �����.� CliContracts
    CliMails: TStringList; // Email-�
    CliPhones: TStringList; // ��������, � TObjects - TIntegerList ����� �������� SMS
    CS_client: TCriticalSection;      // ��� ��������� ���������� �������
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;

    function AddCliContract(contID: Integer; OnlyCache: Boolean=False): Integer; // ��������� �������� � ������ (� ����)
    procedure DelCliContract(contID: Integer; OnlyCache: Boolean=False);         // ������� �������� �� ������ (�� ����)
//    procedure AddCliStoreCode(contID, StoreID: Integer);          // ��������� ����� � ������ �� ���������
//    procedure DelCliStoreCode(contID, StoreID: Integer);          // ������� ����� �� ������ �� ���������
//    function GetCliStoreIndex(contID, StoreID: Integer): Integer; // ������ ������ � ������ �� ���������
//    function GetContStoreCodes(contID: Integer): TIntegerList;    // not Free, ������ �� ���������
    function SetLastContract(contID: Integer): String;            // �������� ��������� �������� �������
    function GetCliCurrContID: Integer;                           // �������� ��� ��������/���������� ��������� �������
    function GetCliContract(var contID: Integer; ChangeNotFound: Boolean=False): TContract;      // �������� �������� �������
    function CheckContract(contID: Integer): boolean;             // �������� ����������� ��������� �������
//    function GetContMarginLinks(contID: Integer): TLinkList;      // not Free !!! ������ �� ������� �� ���������
//    function GetContCacheGrpMargin(contID, grID: Integer): Double;      // ������� �� ������/��������� �� ���������
//    function GetContMarginListAll(contID: Integer; // must Free !!! ������ �����/�������� � ��������� �� ��������� (TCodeAndQty)
//             WithPgr: Boolean=False; OnlyNotZero: Boolean=False): TList;
//    function CheckCliContMargin(contID, grID: Integer; marg: Double): String; // ���������/������ ������� �� ������/�������� � ����
    function GetCliContDefs(contID: Integer=0): TTwoCodes; // not Free !!! ������ �� ��������� �� ���������
    procedure CheckCliContDefs(contID, deliv, dest: Integer); // �������� �������� �� ���������
    procedure CheckQtyCount;     // ��������� ������� �������� �������
    procedure CheckConnectCount; // ��������� ������� ���������
    function CheckBlocked(inCS: Boolean=False; mess: Boolean=False; Source: Integer=0): String; // �������� ����������
    function CheckIsFinalClient: Boolean;

    property FirmID            : Integer index ik16_1  read GetIntC    write SetIntC;    // ��� ����� // PartiallyFilled
    property MaxRowShowAnalogs : integer index ik16_2  read GetIntC    write SetIntC;
    property SearchCurrencyID  : integer index ik16_3  read GetIntC    write SetIntC;
//    property DEFACCOUNTINGTYPE : integer index ik16_4  read GetIntC    write SetIntC;
    property DEFDELIVERYTYPE   : integer index ik16_5  read GetIntC    write SetIntC;
    property CountSearch       : integer index ik16_6  read GetIntC    write SetIntC;    // ���-�� ��������� �������� �� ����
    property CountQty          : integer index ik16_7  read GetIntC    write SetIntC;    // ���-�� �������� ������� �� ������ � ���
    property CountConnect      : integer index ik16_8  read GetIntC    write SetIntC;    // ���-�� ��������� �� ������ � ���
    property LastContract      : integer index ik16_9  read GetIntC    write SetIntC;    // ��������� ��������� ��������
    property BlockKind         : integer index ik16_10 read GetIntC    write SetIntC;    // ��� ����������
//    property LoadPriceCount    : integer index ik16_11 read GetIntC    write SetIntC;    // ���-�� ���������� ������ �� �����
    property Login             : string  index ik8_1   read GetStrC    write SetStrC;    // �����     // PartiallyFilled
    property Password          : string  index ik8_2   read GetStrC    write SetStrC;    // ������    // PartiallyFilled
    property Mail              : string  index ik8_3   read GetStrC;                     // Email     // PartiallyFilled
    property Phone             : String  index ik8_4   read GetStrC;                     // ��������  // PartiallyFilled
    property Post              : string  index ik8_5   read GetStrC    write SetStrC;    // ��������� // PartiallyFilled
    property SearchCurrencyCode: string  index ik8_6   read GetStrC;                     // SearchCurrencyID ����������
    property FirmName          : string  index ik8_7   read GetStrC;                     // ������������ �����
    property Sid               : string  index ik8_8   read GetStrC    write SetStrC;    // sid       // PartiallyFilled
    property NOTREMINDCOMMENT  : boolean index ik8_2   read GetDirBool write SetDirBool; //
    property PartiallyFilled   : boolean index ik8_3   read GetDirBool write SetDirBool; // ������� ���������� ����������
    property Arhived           : boolean index ik8_4   read GetDirBool write SetDirBool; // ������� ����������
    property WareSemafor       : boolean index ik8_5   read GetDirBool write SetDirBool; // ������� ������ �������� ������� � ������ �������
    property Blocked           : boolean index ik8_6   read GetDirBool write SetDirBool; // ������� ���������� ������� � Weborderclients
    property DocsByCurrContr   : boolean index ik8_7   read GetDirBool write SetDirBool; // ������� ���������� ��������� ������ �� ���.��������
    property resetPW           : boolean index ik8_8   read GetDirBool write SetDirBool; // ������� ���������� ������
    property CliPay            : boolean read FCliPay write FCliPay; // T - ���������� ���� ��� ������ (� ����� �� ������)
  end;

  TClients = class (Tobject)
  private
    FarClientInfo: Array of TClientInfo;
    FcalcStart, FcalcDelta: Integer;
    FWorkLogins: TStringList;
    function GetClient(pID: integer): TClientInfo;
    function GetIndex(pID: integer): integer;
    function GetMaxIndex: integer;
  public
    CS_clients: TCriticalSection; // ��� ��������� ����������
    constructor Create;
    destructor Destroy; override;
    procedure TestMaxCode(MaxCode: Integer);
    procedure CutEmptyCode;
    procedure AddClient(pID: integer);
    procedure SetCalcBounds(iStart, iEnd: integer);
    function ClientExists(pID: Integer): Boolean;
    property Items[pID: integer]: TClientInfo read GetClient; default;
    property MaxIndex: integer read GetMaxIndex;
    property WorkLogins: TStringList read FWorkLogins;
  end;

//----------------------------------------------------- ������������ - ���������
  TEmplInfoItem = class (TSubDirItem)
  private // FName - ��� �� MANS, FID - EMPLCODE(GB), FSubCode - EMPLMANCODE(GB), 
          // FOrderNum - ��� ������������� �� EMPLDPRTCODE(ORD, EMPLOYEES)
          // FLinks - ������ � �������� ��������
    FSurname    : string;           // ������� �� MANS
    FPatron     : string;           // �������� �� MANS
    FServerLog  : string;           // ����� �� EMPLLOGIN(ORD, EMPLOYEES)
    FPASSFORSERV: string;           // ������ �� EMPLPASS(ORD, EMPLOYEES)
    FGBLogin    : string;           // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    FGBRepLogin : string;           // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    FMail       : string;           // Email
    FSession    : string;
    FFaccReg: Integer;
    function GetStrE(const ik: T16InfoKinds): String;          // �������� ������
    procedure SetStrE(const ik: T16InfoKinds; Value: String);  // �������� ������
    function GetIntE(const ik: T8InfoKinds): Integer;          // �������� ���
    procedure SetIntE(const ik: T8InfoKinds; Value: Integer);  // �������� ���
    procedure TestUserRolesLength(len: integer; ChangeOnlyLess: boolean=True; inCS: boolean=True);
  public
    LastTestTime     : TDateTime;        // ����� ��������� ��������
    LastActionTime   : TDateTime;        // ����� ���������� ��������
    UserRoles        : Tai;              // ������ ����� �� (ORD, ROLES)
    constructor Create(pID, pManID, pDprtID: Integer; pName: String);
    destructor Destroy; override;
    procedure TestUserRoles(roles: Tai);             // ��������� ������ �����
    procedure AddUserRole(role: Integer);            // ��������� ����
    procedure DelUserRole(role: Integer);            // ������� ����
    function UserRoleExists(role: Integer): boolean; // ��������� ������� ����
    property Arhived          : boolean index ik8_5   read GetDirBool write SetDirBool; // ������� ���������� �� EMPLARCHIVED(GB, EMPLOYEES)
    property RESETPASSWORD    : boolean index ik8_2   read GetDirBool write SetDirBool; // ������� ���������� ������
    property Blocked          : boolean index ik8_3   read GetDirBool write SetDirBool; // ������� ����������
    property DisableOut       : boolean index ik8_4   read GetDirBool write SetDirBool; // ������� ������� ������� �������
    property EmplID           : integer index ik8_1   read GetIntE  write SetIntE; // = EMPLCODE(GB)
    property ManID            : integer index ik8_2   read GetIntE  write SetIntE; // = EMPLMANCODE(GB)
    property EmplDprtID       : integer index ik8_3   read GetIntE  write SetIntE; // ��� ������������� �� EMPLDPRTCODE(ORD, EMPLOYEES)
    property FaccRegion       : integer index ik8_4   read GetIntE  write SetIntE; // ����� ������� ���
    property Surname          : string  index ik16_1  read GetStrE  write SetStrE; // ������� �� MANS
    property Name             : string  index ik16_2  read GetStrE  write SetStrE; // ��� �� MANS
    property Patronymic       : string  index ik16_3  read GetStrE  write SetStrE; // �������� �� MANS
    property ServerLogin      : string  index ik16_4  read GetStrE  write SetStrE; // ����� �� EMPLLOGIN(ORD, EMPLOYEES)
    property USERPASSFORSERVER: string  index ik16_5  read GetStrE  write SetStrE; // ������ �� EMPLPASS(ORD, EMPLOYEES)
    property GBLogin          : string  index ik16_6  read GetStrE  write SetStrE; // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    property GBReportLogin    : string  index ik16_7  read GetStrE  write SetStrE; // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    property Mail             : string  index ik16_8  read GetStrE  write SetStrE; // Email
    property Session          : string  index ik16_9  read GetStrE  write SetStrE;
    property EmplLongName     : string  index ik16_11 read GetStrE;
    property EmplShortName    : string  index ik16_10 read GetStrE;
    property VisStoreLinks    : TLinks read FLinks;                                // ������ � �������� ��������
  end;

//---------------------------------------- ����� ��������/���������� ��� �������
  TWareFile = Class (TSubDirItem)  // ����
  private // FSubCode - WGFSupTD (supID TecDoc !!!), FOrderNum - WGFHeadID, FName - WGFFileName
    function GetWFHeadName: String; // �������� ����� ���������
  public
    property supID   : Integer read FSubCode;      // SupID TecDoc (DS_ID !!!)
    property HeadID  : Integer read FOrderNum;     // ��� ���������
    property FileName: String  read FName;         // ��� �����
    property HeadName: String  read GetWFHeadName; // ����� ���������
  end;

//-------------------------------------------------------------------- ����-����
  TInfoBoxItem = Class (TSubDirItem)
  private
    FLinkToPict: String;
    FLinkToSite: String;
    FDateFrom  : TDateTime;
    FDateTo    : TDateTime;
    function GetStrI(const ik: T8InfoKinds): String;         // �������� ������
    procedure SetStrI(const ik: T8InfoKinds; Value: String); // �������� ������
  public
    property Title     : String  index ik8_1 read GetStrI    write SetStrI;    // ���������
    property LinkToPict: String  index ik8_2 read GetStrI    write SetStrI;    // ������ �� �������
    property LinkToSite: String  index ik8_3 read GetStrI    write SetStrI;    // ������ �� ���� / ���� ��������
    property InWindow  : boolean index ik8_2 read GetDirBool write SetDirBool; // ���������� � ����
    property VisAuto   : boolean index ik8_3 read GetDirBool write SetDirBool; // ��������� ��� ������� ����
    property VisMoto   : boolean index ik8_4 read GetDirBool write SetDirBool; // ��������� ��� ������� ����
    property DateFrom  : TDateTime read FDateFrom  write FDateFrom;            // ���� ������
    property DateTo    : TDateTime read FDateTo    write FDateTo;              // ���� ���������
    property Priority  : Integer   read FOrderNum  write FOrderNum;            // ���������
  end;

  TEmplRole = class (TDirItem)
  private
    FConstLinks: TLinks;
  public
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    property ImpLinks  : TLinks read FLinks;                        // ������ � ���������
    property ConstLinks: TLinks read FConstLinks write FConstLinks; // ������ � �����������
  end;

//------------------------------------------------------------- ��� �������
  TImportType = Class (TDirItem)
  private
  public
    constructor Create(pID: Integer; pName: String; pReport, pImport: Boolean);
    property RoleLinks  : TLinks  read FLinks;                                  // ������ � ������
    property ApplyReport: boolean index ik8_3 read GetDirBool write SetDirBool; // ������� ������� ������
    property ApplyImport: boolean index ik8_4 read GetDirBool write SetDirBool; // ������� ������� �������
  end;

//---------------------------------------- ��������� ������� - ��������� �������
  TConstItem = Class (TSubDirItem) // ������� ����������� ��������
    // Name - ������������ ���������, OrderNum - ���-�� ������ ����� ������� � Double
  private // SubCode - ��� ����� ����.���������, SrcID - ���, Links - ������ ������ � ������
    FLastTime: TDateTime; // ����� ����.���������
    FValue   : String;    // �������� � ��������� ����
    FMaxValue: String;    // Max �������� � ��������� ����
    FMinValue: String;    // Min �������� � ��������� ����
    FGrouping: String;    // ������������� �����������
    function GetStrCI(const ik: T8InfoKinds): String;              // ��������� ��������
    procedure SetStrCI(const ik: T8InfoKinds; pValue: String);     // �������� ��������� ��������
    function GetIntCI(const ik: T8InfoKinds): Integer;             // ����� ��������
    procedure SetIntCI(const ik: T8InfoKinds; pValue: Integer);    // �������� ����� ��������
    function GetDoubCI(const ik: T8InfoKinds): Double;             // ���. ��������
    function GetDateCI(const ik: T8InfoKinds): TDateTime;          // �������� ����
    procedure SetDateCI(const ik: T8InfoKinds; pValue: TDateTime); // �������� �������� ����
  public
    constructor Create(pID: Integer; pName: String; pType: Integer=1;
                pUserID: Integer=0; pPrecision: Integer=0; WithLinks: Boolean=False);
    function CheckConstValue(var pValue: String): String;                          // ��������� ������������ ��������
    property NotEmpty    : boolean   index ik8_3 read GetDirBool write SetDirBool; // ������� ������� ������� ��������
    property StrValue    : String    index ik8_1 read GetStrCI   write SetStrCI;   // �������� � ��������� ����
    property MaxStrValue : String    index ik8_2 read GetStrCI   write SetStrCI;   // Max �������� � ��������� ����
    property MinStrValue : String    index ik8_3 read GetStrCI   write SetStrCI;   // Min �������� � ��������� ����
    property Grouping    : String    index ik8_4 read GetStrCI   write SetStrCI;   // ������������� �����������
    property ItemType    : Integer   index ik8_4 read GetIntCI   write SetIntCI;   // ���
    property Precision   : Integer   index ik8_5 read GetIntCI   write SetIntCI;   // ���-�� ������ ����� ������� � Double
    property LastUser    : Integer   index ik8_6 read GetIntCI   write SetIntCI;   // ��� ����� ����.���������
    property IntValue    : Integer   index ik8_1 read GetIntCI;                    // ����� ��������
    property MaxIntValue : Integer   index ik8_2 read GetIntCI;                    // Max ����� ��������
    property MinIntValue : Integer   index ik8_3 read GetIntCI;                    // Min ����� ��������
    property DoubValue   : Double    index ik8_1 read GetDoubCI;                   // ���. ��������
    property MaxDoubValue: Double    index ik8_2 read GetDoubCI;                   // Max ���. ��������
    property MinDoubValue: Double    index ik8_3 read GetDoubCI;                   // Min ���. ��������
    property DateValue   : TDateTime index ik8_1 read GetDateCI;                   // �������� ����
    property MaxDateValue: TDateTime index ik8_2 read GetDateCI;                   // Max �������� ����
    property MinDateValue: TDateTime index ik8_3 read GetDateCI;                   // Min �������� ����
    property LastTime    : TDateTime index ik8_4 read GetDateCI  write SetDateCI;  // ����� ����.���������
  end;

//------------------------------------------------------------ ������� ���������
  TProductLine = Class (TDirItem)
  private
    function GetComment: String;
  public
//    constructor Create(pID: Integer; pName: String);
    property WareLinks: TLinks read FLinks;   // ������ � ��������
    property Comment: String read GetComment; // ����������� �� 1-�� ������
    property HasModelAuto: boolean index ik8_3 read GetDirBool write SetDirBool;   // ������� ������������ � ������� Auto
    property HasModelMoto: boolean index ik8_4 read GetDirBool write SetDirBool;   // ������� ������������ � ������� Moto
    property HasModelCV  : boolean index ik8_5 read GetDirBool write SetDirBool;   // ������� ������������ � ������� ����������
    property HasModelAx  : boolean index ik8_6 read GetDirBool write SetDirBool;   // ������� ������������ � ������� ����
  end;

  TProductLines = Class (TObjectList)
  private
  public
    function GetProductLine(pID: Integer): TProductLine; overload;  // ������ �� ���� �������
    function GetProductLine(pName: String): TProductLine; overload; // ������ �� �������� �������
  end;

//----------------------------------------------------------- ������ ����� Motul
  TMotulNode = Class (TSubDirItem)  // ���� ������
  private // FID - ��� ����, FName - ������������, State - ������, FSubCode - ��� ��������
          // FSrcID - �������, FOrderNum - ������.����� ���� � ������ ����� �������
          // FLinks - ������ ��������� ����� ��������� �������
    FMeasID  : Byte;            // ��� ��.���.
    FOrderOut: Byte;            // ������� ������
    FNameSys : String;          // ������������ ���������
    FChildren: TList;           // ������ ��������
    function GetIsEnding: boolean;
  public
    constructor Create(pID, pParentID, pMeasID, pSysID, pOrdnum: Integer;
                pName, pNameSys: String; pVisible: Boolean=True);
    destructor Destroy; override;
    property Children: TList read FChildren; // ������ ��������, Item - Pointer TMotulNode
    property NameSys : String  read FNameSys;    // ������������ ���������
    property ParentID: Integer read FSubCode;    // ��� ��������
    property MeasID  : Byte    read FMeasID;     // ��� ��.���.
    property OrderOut: Byte    read FOrderOut;   // ������� ������
    property TypeSys : Byte    read FSrcID;      // ��� ������� 1 - ����, 2 - ���� and etc.
    property Visible : Boolean index ik8_2 read GetDirBool write SetDirBool; // ������� ��������� ����
    property IsEnding: Boolean read GetIsEnding; // ������� �������� ����
    property DupNodes: TLinks read FLinks;       // ���� ��������� �������
  end;

  TMotulTreeNodes = Class (TDirItems)         // ������ �����
  private // FItems - ������ ������ �� ���� ������, FItems[0] - ������ �� �������� ���� ������
    function GetNodeByID(pID: Integer): TMotulNode;
    procedure SortNodesList; // ������������� ������ ������ ���������������� �� ���� ������

  public
    constructor Create(LengthStep: Integer=10);
//    destructor Destroy; override;
    function MotulNodeGet(pID: Integer; var pNodeGet: TMotulNode): Boolean; overload; // ����� ���� �� ����
    function MotulNodeGet(pSys: Integer; pNameSys: String; var pNodeGet: TMotulNode): Boolean; overload; // ����� ���� �� ���������� ������������
    function MotulGetSysTree(SysID: integer=0): TStringList; // must Free, �������� ������ ������ ������� (0 - ���) ���������������� �� ���� ������
    function MotulNodeValidForAdd(pID, pParentID: Integer; pName, pNameSys: String; // ��������� ���������� ���������� ����
             var pNodeAdd, pNodeParent: TMotulNode; pCheckTreeDup: Boolean=True): String;
    function MotulNodeDel(pNodeID: Integer): String;                                 // ������� ����
    function MotulNodeEdit(pNodeID, pVisible, pUserID, pOrdnum: Integer;             // �������� ��������� ����
             pName, pNameSys: String): String;
    function MotulNodeAdd(pParentID, pUserID, pSysID, pOrdnum: Integer; var pNodeID: Integer; // ���������� ���� � ������
             pNodeName, pNodeNameSys: String; pVisible: Boolean=True; pMeasID: Integer=0; ToBase: Boolean=False): String;

    property Nodes[ID: Integer]: TMotulNode read GetNodeByID; default;

  end;

//-------------------------------------------------------------------- ����� ���
  TDataCache = class
  private
    FMeasNames    : TDirItems;   // ���������� ��.���.
    FEmplRoles    : TDirItems;   // ���������� �����
    FWareFiles    : TDirItems;   // ���������� ������ ��������/����������
    FImportTypes  : TDirItems;   // ���������� ����� ������� ( FLinks - ����� �����)
    FParConstants : TDirItems;   // ���������� �������� ( FLinks - ����� �����)
    FCacheBoolOpts: set of T16InfoKinds;
     function GetBoolDC(ik: T16InfoKinds): boolean;        // �������� �������
    procedure SetBoolDC(ik: T16InfoKinds; Value: boolean); // �������� �������
    procedure SetWaresNotTested; // �������� ������ ������������ ���� �������
    procedure DelNotTestedWares; // ������� ������������� �������� ���� �������
    procedure TestParConstants(flFill: Boolean=True; alter: boolean=False);       // �������� ���� ��������
    procedure TestSmallDirectories(flFill: Boolean=True; alter: boolean=False); // ����������/�������� ����� ������������
     function TestCacheArrayItemExist(kind: TArrayKind; pID: integer; var flnew: boolean): boolean; // ��������� ������������� �������� ������� ����
    procedure TestCacheArrayLength(kind: TArrayKind; len: integer; ChangeOnlyLess: boolean=True);   // ��������� ����� ������� ����
    procedure TestWares(flFill: Boolean=True);          // ����������/�������� �������
    procedure TestWareRests(CompareTime: boolean=True); // ����������/�������� ������ � ��������� �������
    procedure FillWareTypes(GBIBS: TIBSQL);
    procedure FillWareFiles(fFill: Boolean=True); // �������� / ���������� ������ �������
    procedure FillInfoNews(flFill: Boolean=True); // ���������� / �������� ����-�����
     function FillBrandTDList: TStringList;       // ���������� ������ ������� TecDoc
//    procedure FillAttributes;                     // ���������� ���������
    procedure FillGBAttributes(fFill: Boolean=True); // ���������� / �������� ��������� Grossbee
    procedure FillNotifications(fFill: Boolean=True); // ���������� / �������� �����������
//    procedure CheckAttributes;                    // �������� ���������
//     function GetFilialROPcodes(var filials: Tai): Tai;        // ���� ���-�� ��������
  public
//    TestCacheAlterInterval: Integer;   // �������� �������� ���� �� alter-�������� � ��� (��� ���� � ��������)
    CliLoginLength        : Byte;      // ����� ���� ������
    CliPasswLength        : Byte;      // ����� ���� ������
    CliSessionLength      : Byte;      // ����� ���� �������������� ������
    OrdWarrNumLength      : Word;      // ����� ���� ������ ����� ������������
    OrdWarrPersLength     : Word;      // ����� ���� ������ ��� (������������)
    OrdCommentLength      : Word;      // ����� ���� ������ �����������
    OrdSelfCommLength     : Word;      // ����� ���� ������ ������ �����������
    AccEmpCommLength      : Word;      // ����� ���� ����� ����������� ����������
    AccCliCommLength      : Word;      // ����� ���� ����� ����������� �������
    AccWebCommLength      : Word;      // ����� ���� ����� ����������� Web

    TestCacheInterval     : Word;      // �������� ������ �������� ���� � ��� (��� ���� � ��������)
    TestCacheNightInt     : Word;      // ������ �������� ������ �������� ���� � ��� (��� ���� � ��������)
    ClientActualInterval  : Word;      // �������� ������������ ���� ������� � ���
    FirmActualInterval    : Word;      // �������� ������������ ���� ����� � ��� (����� ������)

    DefCurrRate           : Single;    // ���� EURO � ���
    CreditPercent         : Single;    // DTZNCREDITPERCENT (DUTYZONES)
    BonusVolumeCoeff      : Single;    // ����������� ������� ������� � cDefCurrency
    BankMinSumm	          : Single;    // ����������� ����� �������
    BankLimitSumm	        : Single;    // ����������� ����� �������� � �����

    BonusCrncCode	        : integer;   // ��� ������ �������
    LongProcessFlag       : Integer;   // ���� ����������� �������� � ����
    pgrDeliv              : Integer;   // ��������� �������
    TopActCode	          : integer;   // ��� ������� ����� ��� ������
    LastTimeCache         : TDateTime; // ����� ��������� ������ �������� ����
    LastTestRestTime      : TDateTime; // ����� ���������� ���������� ������ � ���������
    DocmMinDate           : TDate;     // ����������� ���� ���-��� Grossbee
//    LastTimeCacheAlter    : TDateTime; // ����� ��������� �������� ���� �� alter-��������
//    LastTimeMemUsed       : TDateTime;   // ����� ��������� �������� ���������� ������

    arWareInfo      : array of TWareInfo;
    arDprtInfo      : array of TDprtInfo;
    arEmplInfo      : array of TEmplInfoItem;
    arFirmInfo      : array of TFirmInfo;
    arClientInfo    : TClients;
    CScache         : TCriticalSection; // ��� ��������� ���� �������� � ������ ������ ����
    CS_Empls        : TCriticalSection; // ��� ��������� ���������� �����������
    CS_wares        : TCriticalSection; // ��� ��������� �������
    FDCA            : TDataCacheAdditionASON;
    AttrGroups      : TAttrGroupItems;  // ���������� ����� ���������
    Attributes      : TAttributeItems;  // ���������� ���������
    Contracts       : TContracts;       // ���������� ����������
    Notifications   : TNotifications;   // ���������� �����������
    WareBrands      : TDirItems;        // ���������� �������
    InfoNews        : TDirItems;        // ����-����
    ShipMethods     : TDirItems;        // ���������� ������� ��������
    ShipTimes       : TDirItems;        // ���������� ������ ��������
    FiscalCenters   : TDirItems;        // ���������� FISCALACCOUNTINGCENTER
    WareActions     : TDirItems;        // ���������� ����� �� �������
    Currencies      : TCurrencies;      // ���������� �����
//    FirmLabels      : TDirItems;        // ���������� �������

//    NoTDPictBrandCodes: TIntegerList;   // ���� ������� ��� ������ �������� TD
    ShowZeroRestsFirms: TIntegerList;   // ���� �/� ��� ������ ������� �/�������� � ������� (�����)

    BrandTDList     : TStringList;      // ������ ������� TecDoc
    BrandLaximoList : TStringList;      // ������ ������� Laximo
    DeliveriesList  : TStringList;      // ������ ��������
    SMSmodelsList   : TStringList;      // ������ SMS-��������
    MobilePhoneSigns: TStringList;      // ������ ����� ���.����������
    arFirmTypesNames: Tas;
    arFirmClassNames: Tas;
    arWareStateNames: Tas;
    arRegionROPFacc : Tai; // ���� ��� ���-� �� ������ �������
    PriceTypes      : Tai; // ���� ������������ �������
    arFictiveEmpl   : Tai; // ������ ����� ��������� ���������� (����, �������� � �.�.)
//    MarginGroups    : TMarginGroups; // ������/��������� �������
    DiscountModels  : TDiscModels;   // ���������� �������� ������
    GBAttributes    : TGBAttributes;  // ���������� ��������� Grossbee �������
    GBPrizeAttrs    : TGBAttributes;  // ���������� ��������� ��������
    WareProductList : TStringList;    // ������ ���������

    ProductLines    : TProductLines;   // �������� ����������� ������ (Motul)
    MotulTreeNodes  : TMotulTreeNodes; // ������ ����� Motul

    constructor Create;
    destructor Destroy; override;
    property WareCacheUnLocked : boolean index ik16_1  read GetBoolDC write SetBoolDC; // ������� ���������� ���������� ����
    property WareLinksUnLocked : boolean index ik16_2  read GetBoolDC write SetBoolDC; // ������� ���������� ���������� ������
    property WebAutoLinks      : boolean index ik16_3  read GetBoolDC write SetBoolDC; // ������� ���������� ������ AUTO (Web)
    property WareCacheTested   : boolean index ik16_4  read GetBoolDC write SetBoolDC; // ������� �������� ����������/�������� ����
    property flCheckClosingDocs: boolean index ik16_5  read GetBoolDC write SetBoolDC; // ���� - �������� �������� ����������� ���-��� �������
    property HideOnlyOneLevel  : boolean index ik16_6  read GetBoolDC write SetBoolDC; // ������� - ����������� ������ 1 ������� ������
    property HideOnlySameName  : boolean index ik16_7  read GetBoolDC write SetBoolDC; // ������� - ����������� ���� ������ ��� ���������� ����
    property flCheckDocSum     : boolean index ik16_8  read GetBoolDC write SetBoolDC; // ������� - ��������� ����� ���-���
    property flSendZeroPrices  : boolean index ik16_9  read GetBoolDC write SetBoolDC; // ������� - �������� ������ � ������� �����
    property flCheckCliEmails  : boolean index ik16_10 read GetBoolDC write SetBoolDC; // ���� - ��������� Email-�
    property flMailSendSys     : boolean index ik16_11 read GetBoolDC write SetBoolDC; // ���� - ���� �������� ����.��������� (��� ���������������� ����������� � ����.�������)
    property flCheckCliBankLim : Boolean index ik16_12 read GetBoolDC write SetBoolDC; // True - ��������� ����� ����� �� �������, False - �� �/�
    property AllowWeb          : boolean index ik16_13 read GetBoolDC write SetBoolDC; // ���� - ������� CSSWeb
    property AllowWebArm       : boolean index ik16_14 read GetBoolDC write SetBoolDC; // ���� - ������� CSSWebarm
    property AllowCheckStopOrds: boolean index ik16_15 read GetBoolDC write SetBoolDC;
    property SingleThreadExists: boolean index ik16_16 read GetBoolDC write SetBoolDC;

    function WareExist(pID: Integer): Boolean;
    function GrpExists(pID: Integer): Boolean;
    function PgrExists(pID: Integer): Boolean;
    function GrPgrExists(grID: integer): Boolean; // �������� ������������� ������/��������� ��� ������/�������
    function TypeExists(pID: Integer): Boolean;
    function DprtExist(pID: Integer): Boolean;
    function FirmExist(pID: Integer): Boolean;
    function ClientExist(pID: Integer): Boolean;
    function EmplExist(pID: Integer): Boolean;
    function MeasExists(pID: Integer): Boolean;
    function CurrExists(pID: Integer): Boolean;
    function FaccExists(pID: Integer): Boolean;
    function RoleExists(pID: Integer): Boolean;
    function ImpTypeExists(pID: Integer): Boolean;
    function ConstExists(pID: Integer): Boolean;
    function FirmTypeExists(pID: Integer): Boolean;
    function FirmClassExists(pID: Integer): Boolean;

    function GetWare(WareID: integer; OnlyCache: Boolean=False): TWareInfo; // ���������� ��������� ������ (���� � ���� ��� ��� � OnlyCache=False - ������� � ��� � PgrID=0)
    function GetEmplIDByLogin(login: string): Integer;
    function GetEmplIDByGBLogin(Login: string): Integer;
    function GetEmplIDBySession(pSession: string): Integer;
    function GetRegFirmCodes(RegID: Integer=0; Search: string=''; NotArchived: boolean=True): Tai; // must Free, RegID - ��� ��������� (0-���), Search - ���� ������ �� ������������, NotArchived - ������ ����������
    function GetEmplCodesByShortName(DprtID: Integer=0; role: Integer=0): Tai; // must Free, ������ ����� ����������, ���������� �� ���� ������� � ���
    function GetGrpID(ID: Integer): Integer;         // ��� ������
    function GetPgrID(ID: Integer): Integer;         // ��� ���������
    function GetDprtMainName(pID: Integer): string;  // ������������ �������������
    function GetDprtShortName(pID: Integer): string; // ��.������������ �������������
    function GetDprtColName(pID: Integer): string;   // ��������� ������� �������������
    function GetImpTypeName(pID: Integer): string;   // ������������ �������
    function GetMeasName(pID: Integer): string;      // ������������ ��.���.
    function GetCurrName(pID: Integer; ForClient: Boolean): string; // ������������ ������
    function GetFaccName(pID: Integer): string;      // ������������ ���
    function GetWareTypeName(typeID: Integer): string;   // ������������ ���� ������
    function GetFirmTypeName(typeID: Integer): string;   // ������������ ���� �����
    function GetFirmClassName(classID: Integer): string; // ������������ ��������� �����
    function GetLastTimeCache: Double;               // ����� ���������� ���.���� ��� ����������
    function GetTestCacheIndication: Integer;        // ��������� ��������������� �������� ����
    function GetRoleName(pID: Integer): string;      // ������������ ����
    function GetAllRoleCodes: Tai;                   // must Free, ���� ���� �����
    function GetEmplEmails(empls: Tai; pFirm: Integer=0; pWare: Integer=0; // ������ ������� �����������
             pSys: Integer=0; pRegion: Integer=0): String; overload;
    function GetEmplEmails(empls: Tai; var mess: String; pFirm: Integer=0;
             pWare: Integer=0; pSys: Integer=0; pRegion: Integer=0): String; overload;
    function GetConstItem(csID: Integer): TConstItem;  // ������� ����������� ��������
    function GetConstEmpls(pc: Integer): Tai;          // must Free, ������ ����� ����������� �� ���������-������
    function GetConstEmails(pc: Integer; pFirm: Integer=0; pWare: Integer=0): String; overload; // ������ ������� ���������-������ ����� �����������
    function GetConstEmails(pc: Integer; var mess: String; pFirm: Integer=0; pWare: Integer=0): String; overload;
    function GetEmplConstants(pEmplID: Integer): TStringList;  // must Free, ��������� ��������� ���������� (Object - ID)
    function GetEmplConstantsCount(pEmplID: Integer): Integer; // ���-�� ��������� �������� ����������
    function GetRepOrImpRoles(ImpID: Integer; flReport: Boolean=True): Tai; // must Free, ��������� ���� ��� ������/�������
    function GetEmplAllowRepImp(pEmplID: Integer): boolean;  // ������� ������� ����������� �������/�������� � ����������
//    function GetDownLoadExcludeBrands: Tai;                  // ���� ����������� ��� �������� ������ �������, must Free

    function GetEmplAllowRepOrImpList(pEmplID: Integer; flReport: Boolean=True): TStringList; // must Free, ������ ��������� �������/�������� ����������
    function GetRoleAllowRepOrImpList(pRoleID: Integer; flReport: Boolean=True): TStringList; // must Free, ��������� ���� �������/�������� ���� (Object - ID)

    function GetSysManagerWares(SysID: Integer=0; ManID: Integer=0; // must Free, ������������� ������ ������� (Object-ID) �� ������� �/��� ��������� �/��� ������
             Brand: integer=0; Sort: boolean=True): TStringList;
    function GetWaresModelNodeUsesAndTextsView(ModelID, NodeID: Integer; // must Free, ������ ������� � ������� � ������� 3, Objects - WareID
             WareCodes: Tai; var sFilters: String): TStringList;
    function GetModelNodeWaresWithUsesByFilters(ModelID, NodeID: Integer; // ������.������ ������� � �������� � ��������� � ������� 3, Objects - WareID
             withChildNodes: boolean; var sFilters: String): TStringList;  // must Free, sFilters - ���� �������� ��������� ����� �������
    function GetWareModelUsesAndTextsView(WareID: Integer; Models: TList): TStringList; // must Free, ������ ������� � ������� � ������� ������ � ��������

    function GetWareRestsByStores(pWareID: Integer; WithNegative: Boolean=False): TObjectList; // must Free, �������� ������� ������ �� �������
    function GetGroupDprts(pDprtGroup: Integer=0; StoreAndRoad: Boolean=False): Tai; // must Free, ������ ������������� � �������� ������
//    function GetEmplVisFirmLinkList(EmplID: Integer): TList;  // not Free !!! ������ ������ � �/� �� ����� ��������� ����������
//    function GetEmplVisStoreLinkList(EmplID: Integer): TList; // not Free !!! ������ ������ �� �������� �� ����� ��������� ����������
//--------------------------------------------------------------------
    function GetFilialList(flShortName: Boolean=False): TStringList; // must Free, ������ �������� (Objects - ID)
    function GetFirmTypesList: TStringList;                          // must Free, ������ ����� �/������� (Objects - ID)
    function GetFirmClassesList: TStringList;                        // must Free, ������ ��������� �/������� (Objects - ID)
    function GetShipMethodName(smID: Integer): string;               // ������������ ������ ��������
    function GetShipMethodNotTime(smID: Integer): Boolean;           // ������� ������� ������� � ������ ��������
    function GetShipMethodNotLabel(smID: Integer): Boolean;          // ������� ������� �������� � ������ ��������
    function GetShipTimeName(stID: Integer): string;                 // ������������ ������� ��������
    function GetShipMethodsList(dprt: Integer=0): TStringList;       // must Free, ������ ������� �������� �� ������ ��� ���� (Objects - ID)
    function GetShipTimesList: TStringList;                          // must Free, ������������� ������ ������ �������� (Objects - ID)
//--------------------------------------------------------------------

    function SearchWaresByAttrValues(attCodes, valCodes: Tai): Tai;             // must Free, ����� ������� �� ������ �������� ���������
    function SearchWaresByGBAttValues(attCodes, valCodes: Tai): Tai;            // must Free, ����� ������� �� ������ �������� ��������� Grossbee
    function SearchWareFileBySupAndName(pSup: Integer; pFileName: String): Integer;
    function SearchWaresByTDSupAndArticle(pSup: Integer; pArticle: String;      // must Free - ����� ������� �� �������� TD
             notInfo: Boolean=False): TStringList;

    procedure TestDataCache(CompareTime: boolean=True; alter: boolean=False);   // ����������/�������� ����
    procedure TestEmpls(pEmplID: Integer; FillNew: boolean=True;                // ����������/�������� �����������
              CompareTime: boolean=True; TestEmplFirms: boolean=False);
    procedure TestFirms(pID: Integer; FillNew: boolean=False;                   // ����������/�������� ����
              CompareTime: boolean=True; Partially: boolean=False; RegID: Integer=0);
    procedure TestClients(pID: Integer; FillNew: boolean=False;                 // ����������/�������� ��������
              CompareTime: boolean=True; Partially: boolean=False; pFirm: Integer=0);
    procedure TestGrPgrDiscModelLinks;                                          // ����������/�������� ������ �����/�������� � ��������� ������

    function SaveNewConstValue(csID, pUserID: Integer; pValue: String): String; // ����� �������� ���������
    function CheckRoleConstLink(csID, roleID, UserID: Integer;                  // ��������� ����� ���� � ����������
             flWrite: Boolean; var ResCode: Integer): String;
//    function CheckRoleImportLink(impID, roleID, UserID: Integer; flWrite: Boolean; var ResCode: Integer): String; // ��������� ����� ���� � ��������
    function CheckWareBrandReplace(brID, brTD, userID: Integer; var ResCode: Integer): String; // ���������� / �������� ������ �������������� Grossbe � Tecdoc
    function CheckWaresEqualSys(WareID1, WareID2: Integer): Boolean;            // �������� ������������ ������ ���� �������
    function CheckEmplIsFictive(pEmplID: Integer): Boolean;                     // �������� ����� ��������� ���������� (����, �������� � �.�.)
    function CheckEmplImpType(pEmplID, impID: Integer; flReport: Boolean=False): Boolean; // �������� ����������� ������/������� ����������
    function CheckEmplConstant(pEmplID, constID: Integer; var errmess: string;  // �������� ����������� ��������� ����������
             CheckWrite: Boolean=False): Boolean;
//    function CheckEmplVisFirm(pEmplID, pFirmID: Integer): Boolean;              // �������� ��������� �/� ����������
//    function CheckEmplVisStore(pEmplID, pDprtID: Integer): Boolean;             // �������� ��������� ������ ����������
    function CheckLinkAllowDelete(srcID: Integer): Boolean;                     // �������� ����������� �������� �� ���������
    function CheckLinkAllowWrong(srcID: Integer): Boolean;                      // �������� ����������� ������� �������� ������ �� ���������

    function CheckLinkMainAndDupNodes(NodeID, MainNodeID, userID: Integer;      // ���������� / �������� ������ ��� - �������, �����������
             var ResCode: Integer): String;
    function CheckWareAttrValue(WareID, AttrID, srcID, userID: Integer;         // �������� ��������� ������
             Value: String; var ResCode: Integer): String;
    function CheckWareCriValueLink(pWareID, criTD, UserID, srcID: Integer;      // �������� ���� ������ �� ��������� �������� � ����
             CriName, CriValue: String): String;
    function CheckModelNodeWareTextLink(var ResCode: Integer; pModelID, pNodeID, pWareID: Integer; // �������� ���� ������ 3 � ������� � ���� (������ 1 - �������� �� Excel)
             TextValue: String; TypeID: Integer=0; TypeName: String=''; UserID: Integer=0; srcID: Integer=0): String;
    function CheckWareCrossLink(pWareID, pCrossID: Integer;                               // ��������/������� ���� ������ � ��������
             var ResCode: Integer; srcID: Integer; UserID: Integer=0): String;            //          (Excel, �������)
    function CheckWareArtCrossLinks(pWareID: Integer; CrossArt: String; crossMF: Integer; // ��������/������� ����� ������ � ��������� �� 1 ��������
             var ResCode: Integer; srcID: Integer; UserID: Integer=0; ibsORD: TIBSQL=nil): String;          //          (�������� �� TDT)
   procedure CheckWareRest(wrLinks: TLinks; dprtID: Integer;          // ���������� / ��������� �������� ������� ������
                           pQty: Double; dec: Boolean=False);
    function CheckWareSatelliteLink(pWareID, pSatelID: Integer;       // ��������/������� ���� ������ � �����.������� (Excel, �������)
             var ResCode: Integer; srcID: Integer=0; UserID: Integer=0): String;
//---------- UseList - ������ ����� <��������>=<��������>, � Object - <��� TecDoc ��������>
//----------- ��� ������� �� Excel <��� TecDoc ��������>=0
    function GetModelNodeWareUseListNumber(pModelID, pNodeID, pWareID: Integer; // ����� ������ ������� ������ 3 (���������)
             UseList: TStringList): Integer;
    function AddModelNodeWareUseListLinks(pModelID, pNodeID, pWareID,   // �������� ����� ������ 3 � ����� ������� ������� � ����
             UserID, srcID: Integer; var UseList: TStringList; var pPart: Integer): String;
    function DelModelNodeWareUseListLinks(pModelID, pNodeID, pWareID, iUseList: Integer): String; // ������� ����� ������ 3 � ������� ������� �� ����
    function ChangeModelNodeWareUsesPart(pModelID, pNodeID, pWareID,    // �������� ����� ������ 3 � ������� �������� ������� � ����
             UserID, srcID: Integer; UseList: TStringList; var pPart: Integer): String;
//----- TxtList - ������, � Object - <��� supTD ������>
//----- GetModelNodeWareTextListNumber: String -
//-----   <IntToStr(��� ���� ������)>=<������������� TecDoc>+cSpecDelim+<�����>
//----- CheckModelNodeWareTextListLinks: String -
//-----   <IntToStr(��� ���� ������)>+cSpecDelim+<�������� ����>=<������������� TecDoc>+cSpecDelim+<�����>
//-----   ���� �����  <IntToStr(��� ���� ������)> - <�������� ����> ����� ���� ''
//----- ��� ������� �� Excel  <������������� TecDoc>='', <��� supTD ������>=0
    function GetModelNodeWareTextListNumber(pModelID, pNodeID, pWareID: Integer; // ����� ������ ������� ������ 3 (���������)
             TxtList: TStringList; nTxtList: Integer=0; ORD_IBSr: TIBSQL=nil): Integer;
    function CheckModelNodeWareTextListLinks(var ResCode: Integer; // �������� / ������� ����� ������ 3 � ������� �������
             pModelID, pNodeID, pWareID: Integer; TxtList: TStringList;
             UserID: Integer=0; srcID: Integer=0; PartID: Integer=0): String;
    function FindModelNodeWareUseAndTextListNumbers(pModelID, pNodeID, pWareID: Integer; // ������ ������ ������� � ������� ������ 3
             var UseLists: TASL; var TxtLists: TASL; var ListNumbers: Tai; var ErrUseNums: Tai;
             var ErrTxtNums: Tai; FromTDT: Boolean=False; CheckTexts: Boolean=False): String;
    function AddWareFile(var fID: Integer; pFname: String;             // �������� ���� � ���� � ���
             pSup, pHeadID, pUserID, pSrcID: Integer): String;
    function CheckWareFileLink(var ResCode: Integer; pFileID, pWareID: Integer;  // ��������/������� ���� ������ � ������ (toCache=True - � � ����)
             pSrcID: Integer=0; UserID: Integer=0; toCache: Boolean=True; linkURL: Boolean=True): String;
    function CheckWareFiles(var delCount: Integer): String; // �������� �������������� ������

    function GetNotificationText(noteID: Integer): String;                 // �������� ����� �����������
    function SetClientNotifiedKind(userID, noteID, kind: Integer): String; // �������� ����� ������/������������ ����������� ������������
    function CheckBrandAdditionData(pBrandID, UserID: Integer;             // ��������/������������� ���.��������� ������
             pNameWWW, pPrefix, pAdressWWW: String; pDownLoadEx, pPictShowEx: Boolean): String;

    function GetPriceBonusCoeff(currID: Integer): Single;
    function GetSMSmodelName(smsmID: Integer): String;
    function GetActionComment(ActID: Integer): String;
    function GetWareProductName(wareID: Integer): String; // ������������ �������� �� ���� ������

    procedure FillTreeNodesMotul;                                               // ���������� ������ ����� MOTUL
    function CheckPLineModelNodeLink(PlineID, ModelID, NodeID: Integer;         // ��������/����������/�������������� ������ 3 (Motul)
             var ResCode: Integer; pCount: Single=-1; prior: Integer=-1; userID: Integer=0): string;
    function CheckPLineModelNodeUsage(PlineID, ModelID, NodeID: Integer;        // ��������/���������� ������� ���������� ������ 3 (Motul)
             UsageName, UsageValue: String; var ResCode: Integer; userID: Integer=0): string;
  end;

//------------------------------------------ ��������� ������ (��� ������ �����)
  RaccOpts = record // ��������� �����
    ID, recDoc: Integer;
    Num, webcomm, sDate: String;
    AccSumm, sumlines, AddSumm: Double;
    accLines: TStringList;
  end;
  ROrderOpts = record // ��������� ������
    deliv, DprtID, DestID, ttID, smID, stID, accType, currID: Integer;
    ORDRNUM, commDeliv, commOrder, comment: String;
    pDate: TDateTime;
    Firma: TFirmInfo;
    Contract: TContract;
    olOrdWares: TObjectList;    // ������ ������� ������, � Object - TTwoCodes:
                       // ID1- ��� ������, Qty- ���-��, ID2: ��������� ���������
    accSing, accJoin: RaccOpts; // ����� - ���������, ������������
  end;

var
  NoWare: TWareInfo;
  Cache: TDataCache;
  SysTypes: TDirItems; // �������������� ������� �����
  ZeroCredProfile: TCredProfile;
  flBlockUber: Boolean; // ���� ���������� �������� �����������
//  CachePath: String; // def =..\

//                              ����������� �������
  procedure FillSysTypes;                               // ���������� �������������� ������� �����
  function CheckTypeSys(pTypeSys: Integer): Boolean;    // �������� ������������ ���� ������� ����/����
  function GetSysTypeMail(pTypeSys: Integer): String;   // Email ��� ��������� �� ������� �����
//  function GetSysTypeName(pTypeSys: Integer): String;   // �������� ������� �����
  function GetSysTypeEmpl(pTypeSys: Integer): Integer;  // EmplID �������������� �� ������� �����

  function WareModelsSortCompare(Item1, Item2: Pointer): Integer; // ���������� TList ������� - ������. + �.�. + ������.� + ������������
  function ShipTimesSortCompare(Item1, Item2: Pointer): Integer; // ������������ ��� ���������� TList ����������� ShipTimes
//  function CheckCacheTestAvailable: Boolean;
  function GetRepImpAllowFromLinkSrc(srcID: Integer; flReport: Boolean=False): Boolean; // �������� ������� ����������� ������/������� �� srcID �����
  function GetLinkSrcFromRepImpAllow(RepAllow, ImpAllow: Boolean): Integer; // �������� srcID ����� �� ��������� ����������� ������/�������

  function AttValLinksSortCompare(Item1, Item2: Pointer): Integer;          // ���������� TList ������ �������� ��������� � ���-�� �� ����

implementation
uses n_IBCntsPool;
//******************************************************************************
//                              ����������� �������
//******************************************************************************
//====================================== ���������� �������������� ������� �����
procedure FillSysTypes;
const nmProc = 'FillSysTypes'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdSql: TIBSQL;
    i, pEmplID: integer;
    s, n: string;
    Item: Pointer;
begin
//  OrdIBD:= nil;
  OrdSql:= nil;
  with Cache do try
    if not Assigned(cntsORD) then raise Exception.Create('not Assigned(cntsORD)');
    if not cntsORD.BaseConnected then cntsORD.CheckBaseConnection(30);
    OrdIBD:= cntsORD.GetFreeCnt;
    try
      OrdSql:= fnCreateNewIBSQL(OrdIBD, 'OrdIBSQL_'+nmProc, -1, tpRead, True);
      OrdSql.SQL.Text:= 'select * from DIRTYPESYSTEM order by DTSYCODE';
      OrdSql.ExecQuery;
      while not OrdSql.Eof do begin
        i:= OrdSql.FieldByName('DTSYCODE').AsInteger;
        n:= OrdSql.FieldByName('DTSYNAME').AsString;
        s:= OrdSql.FieldByName('DTSYMAIL').AsString;
        Item:= TSysItem.Create(i, n, s);
        if SysTypes.CheckItem(Item) then
          with TSysItem(SysTypes[i]) do begin
            if SysMail<>s then SysMail:= s;
            if (OrdSql.FieldIndex['DTSYEMPL']<0) then pEmplID:= 0
            else pEmplID:=OrdSql.FieldByName('DTSYEMPL').AsInteger;
            if SysEmplID<>pEmplID then SysEmplID:= pEmplID;
          end;
        cntsORD.TestSuspendException;
        OrdSql.Next;
      end;
      OrdSql.Close;
      OrdSql.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
      ' from rdb$relation_fields f, rdb$fields ff where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE'+
      ' and (f.RDB$RELATION_NAME=:table1 or f.RDB$RELATION_NAME=:table2)';
      OrdSql.ParamByName('table1').AsString:= 'WEBORDERCLIENTS';
      OrdSql.ParamByName('table2').AsString:= 'ORDERSREESTR';
      OrdSql.ExecQuery;
      while not OrdSql.Eof do begin
        i:= OrdSql.FieldByName('fsize').AsInteger;
        s:= OrdSql.FieldByName('fname').AsString;
        if      (s='WOCLLOGIN')          and (CliLoginLength<>i)    then CliLoginLength:= i
        else if (s='WOCLPASSWORD')       and (CliPasswLength<>i)    then CliPasswLength:= i
        else if (s='WOCLSESSIONID')      and (CliSessionLength<>i)  then CliSessionLength:= i
        else if (s='ORDRWARRANT')        and (OrdWarrNumLength<>i)  then OrdWarrNumLength:= i
        else if (s='ORDRWARRANTPERSON')  and (OrdWarrPersLength<>i) then OrdWarrPersLength:= i
        else if (s='ORDRSTORAGECOMMENT') and (OrdCommentLength<>i)  then OrdCommentLength:= i
        else if (s='ORDRSELFCOMMENT')    and (OrdSelfCommLength<>i) then OrdSelfCommLength:= i;
        cntsORD.TestSuspendException;
        OrdSql.Next;
      end;
      OrdSql.Close;
    finally
      prFreeIBSQL(OrdSql);
      cntsOrd.SetFreeCnt(OrdIBD);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;

  if SysTypes.Count<1 then try // ������� ����� ������ ���� ��������� ����������� !!!
    prMessageLOGS(nmProc+': �������� ������� ����� default-����������', fLogCache);
    Item:= TSysItem.Create(constIsAuto, IntToStr(constIsAuto), '');
    SysTypes.CheckItem(Item);
    Item:= TSysItem.Create(constIsMoto, IntToStr(constIsMoto), '');
    SysTypes.CheckItem(Item);
    Item:= TSysItem.Create(constIsCV, IntToStr(constIsCV), '');
    SysTypes.CheckItem(Item);
    Item:= TSysItem.Create(constIsAx, IntToStr(constIsAx), '');
    SysTypes.CheckItem(Item);
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//===================================== �������� ������������ ���� ������� �����
function CheckTypeSys(pTypeSys: Integer): Boolean;
begin
  Result:= SysTypes.ItemExists(pTypeSys);
end;
//========================================= Email ��� ��������� �� ������� �����
function GetSysTypeMail(pTypeSys: Integer): String;
begin
  if SysTypes.ItemExists(pTypeSys) then
    Result:= TSysItem(SysTypes[pTypeSys]).SysMail
  else Result:= '';
end;
//======================================= EmplID �������������� �� ������� �����
function GetSysTypeEmpl(pTypeSys: Integer): Integer;
begin
  if SysTypes.ItemExists(pTypeSys) then
    Result:= TSysItem(SysTypes[pTypeSys]).SysEmplID
  else Result:= 0;
end;
{//======================================================= �������� ������� �����
function GetSysTypeName(pTypeSys: Integer): String;
begin
  if SysTypes.ItemExists(pTypeSys) then
    Result:= AnsiUpperCase(TSysItem(SysTypes[pTypeSys]).Name)
  else Result:= '';
end;  }

//******************************************************************************
//                              TBrandItem
//******************************************************************************
constructor TBrandItem.Create(pID: Integer; pName: String);
begin
  inherited Create(pID, pName);
  FNameWWW:= '';
  FWarePrefix:= '';
  FadressWWW:= '';
  DownLoadExclude:= False;
  PictShowExclude:= False;
  SetLength(FTDMFcodes, 0);
end;
//==============================================================================
destructor TBrandItem.Destroy;
begin
  if not Assigned(self) then Exit;
  SetLength(FTDMFcodes, 0);
  inherited Destroy;
end;

//******************************************************************************
//                              TSysItem
//******************************************************************************
constructor TSysItem.Create(pID: Integer; pName, pSysMail: String);
begin
  inherited Create(pID, pName);
  FSysMail:= pSysMail;
end;

//******************************************************************************
//                                 TAttrGroupItem
//******************************************************************************
constructor TAttrGroupItem.Create(pID, pTypeSys: Integer; pName: String; pOrderNum: Word=0);
begin
  inherited Create(pID, pName, True);
  FTypeSys:= pTypeSys;
  FOrderNum:= pOrderNum;
end;
//=============== ������ ������ �� �������� ������, ������. �� ������.� +������.
function TAttrGroupItem.GetListGroupAttrs: TList; // must Free
var i: Integer;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  with Links do begin
    Result.Capacity:= Result.Capacity+LinkCount;
    for i:= 0 to ListLinks.Count-1 do Result.Add(GetLinkPtr(ListLinks[i]));
  end;
  Result.Sort(DirNumNameSortCompare); // ���������� ��������� (������.� +������.)
end;


//******************************************************************************
//                                 TAttrGroupItems
//******************************************************************************
//============= ���������� TStringList ����� ��������� - ������.� + ������������
function AttrGroupsSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var i1, i2: integer;
begin
  with Cache.AttrGroups do try
    i1:= GetAttrGroup(Integer(List.Objects[Index1])).OrderNum;
    i2:= GetAttrGroup(Integer(List.Objects[Index2])).OrderNum;
    if i1<i2 then Result:= -1 else if i1>i2 then Result:= 1
    else Result:= AnsiCompareText(List.Strings[Index1], List.Strings[Index2]);
  except
    Result:= 0;
  end;
end;
//==============================================================================
constructor TAttrGroupItems.Create(LengthStep: Integer=10);
begin
  inherited Create(LengthStep);
  FTypeSysLists:= TArraySysTypeLists.Create(False); // ������������� ������ �� ��������
end;
//==============================================================================
destructor TAttrGroupItems.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FTypeSysLists);
  inherited Destroy;
end;
//===== ������ ����� ��������� �������, ������������� �� ������.� + ������������
function TAttrGroupItems.GetListAttrGroups(pTypeSys: Integer): TStringList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= FTypeSysLists[pTypeSys];
end;
//====================================================== �������� ������ �� ����
function TAttrGroupItems.GetAttrGroup(grpID: Integer): TAttrGroupItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TAttrGroupItem(DirItems[grpID]);
end;
//============================= ��������� ������ ����� ��������� (SysID=0 - ���)
procedure TAttrGroupItems.SortTypeSysList(SysID: Word=0);
var i, j: integer;
begin
  if not Assigned(self) then Exit;
  if SysID>0 then FTypeSysLists[SysID].CustomSort(AttrGroupsSortCompare)
  else with FTypeSysLists.ListTypes do for i:= 0 to Count-1 do begin
    j:= Integer(Objects[i]);
    FTypeSysLists[j].CustomSort(AttrGroupsSortCompare);
  end;
end;

//******************************************************************************
//                              TAttributeItem
//******************************************************************************
//=================== ���������� TStringList �������� ��������� � ���-�� �� ����
function AttrValuesSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var d1, d2: Double;
    i, i1, i2: integer;
begin
  Result:= 0;
  with List do try
    i:= Ord(Delimiter);
    if i=constInteger then begin
      i1:= StrToIntDef(Strings[Index1], 0);
      i2:= StrToIntDef(Strings[Index2], 0);
      if i1<i2 then Result:= -1 else if i1>i2 then Result:= 1;
    end else if i=constDouble then begin
      d1:= StrToFloatDef(Strings[Index1], 0);
      d2:= StrToFloatDef(Strings[Index2], 0);
      if fnNotZero(d1-d2) then if d1<d2 then Result:= -1 else Result:= 1;
    end else Result:= AnsiCompareText(Strings[Index1], Strings[Index2]);
  except
    Result:= 0;
  end;
end;
//==============================================================================
constructor TAttributeItem.Create(pID, pGroupID: Integer; pPrecision, pType: Byte;
            pOrderNum: Word; pName: String; pSrcID: Integer=0);
begin
  inherited Create(pID, pGroupID, pOrderNum, pName, pSrcID);
  FTypeAttr := pType;       // ���
  FPrecision:= pPrecision;  // ���-�� ������ ����� ������� � ���� Double
  FListValues:= fnCreateStringList(False, Char(pType), dupIgnore); // ������ ��������� �������� ��������
  FListValues.CaseSensitive:= True;
end;
//==============================================================================
destructor TAttributeItem.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FListValues);
  inherited Destroy;
end;
//================================= ��������� ������������ �������� ��� ��������
procedure TAttributeItem.CheckAttrStrValue(var pValue: String);
var d: double;
    i: integer;
begin
  if not Assigned(self) then Exit;
  pValue:= trim(pValue);
  if pValue=''  then Exit;
  if (TypeAttr=constDouble) then begin
    pValue:= StrWithFloatDec(pValue); // ��������� DecimalSeparator
    try
      d:= StrToFloat(pValue);
      i:= Round(d);
      if (d>15) and not fnNotZero(d-i) then pValue:= FormatFloat('#0', d) //FloatToStr(d)
      else pValue:= FormatFloat('#0.'+StringOfChar('0', Precision), d);
    except
    end;
  end;
end;
{//==================================================== �������� ������� ��������
function TAttributeItem.GetAttrTypeSys: Byte;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if Cache.AttrGroups.ItemExists(FGroupID) then
    Result:= Cache.AttrGroups.GetAttrGroup(FGroupID).TypeSys;
end; }

//******************************************************************************
//                              TAttributeItems
//******************************************************************************
constructor TAttributeItems.Create(LengthStep: Integer=10);
begin
  inherited Create(LengthStep);
  FAttrValues:= TDirItems.Create; // ���������� �������� ���������
end;
//==============================================================================
destructor TAttributeItems.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FAttrValues);
  inherited Destroy;
end;
//================= ������ ��������� ������ (������������� �� ������.� +������.)
function TAttributeItems.GetListAttrsOfGroup(pGrpID: Integer): TStringList; // must Free
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  with GetListSubCodeItems(pGrpID) do try
    Result.Capacity:= Result.Capacity+Count;
    for i:= 0 to Count-1 do Result.AddObject(GetDirItemName(Items[i]), Items[i]);
  finally Free; end;
  if Result.Count>1 then Result.CustomSort(DirNumNameSortCompareSL); // ���������� ��������� (������.� +������.)
end;
//===================================================== �������� ������� �� ����
function TAttributeItems.GetAttr(attrID: Integer): TAttributeItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= DirItems[attrID];
end;
//==================================================== �������� �������� �� ����
function TAttributeItems.GetAttrVal(attvID: Integer): TDirItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= FAttrValues[attvID];
end;

//******************************************************************************
//                               TStoreInfo
//******************************************************************************
//==============================================================================
function TStoreInfo.GetDprtCode: string; // ��� ������ ����������
begin
  if not Assigned(self) then Result:= '0' else Result:= IntToStr(DprtID);
end;

//******************************************************************************
//                               TDprtInfo
//******************************************************************************
constructor TDprtInfo.Create(pID, pSubCode, pOrderNum: Integer; pName: String;
  pSrcID: Integer; WithLinks: Boolean);
begin
  inherited Create(pID, pSubCode, pOrderNum, pName, pSrcID, WithLinks);
  // ������� ������ �� �������� ���-�� ����, 0- Date(), 1- Date()+1 � �.�.
  FSchedule:= TObjectList.Create;
  // ������ �������/������, Object - TTwoCodes, ��� ������, ���� � ����
  FStoresFrom:= TObjectList.Create;
  // ������ �������/������ �������, Object - TCodeAndQty, ��� ������,
  // ��������� ����� ������ ����.��������, ������ ������� �����������
  FFillTT:= TObjectList.Create;
end;
//==============================================================================
destructor TDprtInfo.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FSchedule);
  prFree(FStoresFrom);
  prFree(FFillTT);
  inherited Destroy;
end;
//============================================================== �������� ������
function TDprtInfo.GetStrD(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FName;                            //
    ik8_2: Result:= FShort;                           //
    ik8_3: if IsStoreHouse then Result:= FSubName;    // ��������� ������� (�� ������)
    ik8_4: if IsFilial     then Result:= FSubName;    // Email ������ (�� �������)
    ik8_5: if not Cache.DprtExist(FilialID) then Result:= '��� �������'
           else Result:= Cache.GetDprtMainName(FilialID);
    ik8_6: Result:= FAdress;                           //
  end;
end;
//==============================================================================
procedure TDprtInfo.SetStrD(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
   ik8_1: if (FName <>Value) then FName := Value;  //
   ik8_2: if (FShort<>Value) then FShort:= Value;  //
   ik8_3: if IsStoreHouse and (FSubName<>Value) then FSubName:= Value;  // ��������� ������� (�� ������)
   ik8_4: if IsFilial     and (FSubName<>Value) then FSubName:= Value;  // Email ������ (�� �������)
   ik8_6: if (FAdress<>Value) then FAdress:= Value;  //
  end;
end;
//=============================================================== �������� �����
function TDprtInfo.GetIntD(const ik: T8InfoKinds): integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FOrderNum;  // MasterCode
    ik8_2: Result:= FSubCode;   // ��� �������
    ik8_3: Result:= FDelayTime; // ����� ������������ � ���
  end;
end;
//==============================================================================
procedure TDprtInfo.SetIntD(const ik: T8InfoKinds; Value: integer);
begin
  if not Assigned(self) then Exit;
  case ik of
   ik8_1: if (FOrderNum <>Value) then FOrderNum := Value;  // MasterCode
   ik8_2: if (FSubCode  <>Value) then FSubCode  := Value;  // ��� �������
   ik8_3: if (FDelayTime<>Value) then FDelayTime:= Value;  // ����� ������������ � ���
  end;
end;
//======================================================== �������� ���.��������
function TDprtInfo.GetDoubD(const ik: T8InfoKinds): Single;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FLatitude;   // ������
    ik8_2: Result:= FLongitude;   // �������
  end;
end;
//======================================================== �������� ���.��������
procedure TDprtInfo.SetDoubD(const ik: T8InfoKinds; Value: Single);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: begin                        // ������
           if (Value<-90) or (Value>90) then Value:= 0;
           if fnNotZero(FLatitude-Value) then FLatitude:= Value;
         end;
    ik8_2: begin                        // �������
           if (Value<-180) or (Value>180) then Value:= 0;
           if fnNotZero(FLongitude-Value) then FLongitude:= Value;
         end;
  end;
end;
//==============================================================================
procedure TDprtInfo.SetFilialID(pID: integer);
var Filial: integer;
begin
  if not Assigned(self) then Exit;
  if IsFilial then begin
    FilialID:= pID;
    Exit;
  end;
  FilialID:= 0;
  Filial:= ParentID;
  repeat
    if not Cache.DprtExist(Filial) then Filial:= -1
    else if Cache.arDprtInfo[Filial].IsFilial then begin
      FilialID:= Filial;
      Filial:= -1;
    end else Filial:= Cache.arDprtInfo[Filial].ParentID;
  until Filial<0;
//  prMessageLOGS('SetFilialID: id='+IntToStr(id)+' FilialID='+IntToStr(FilialID), fLogCache, false);
end;
//========================================== ������� ��������� � �������� ������
function TDprtInfo.IsInGroup(pGroup: Integer): Boolean;
var parID: Integer;
    Dprt: TDprtInfo;
begin
  Result:= False;
  if not Assigned(self) or not Cache.DprtExist(pGroup) then Exit;
  parID:= ParentID;
  Result:= (ID=pGroup) or (parID=pGroup);
  while not Result and Cache.DprtExist(parID) do begin
    Dprt:= Cache.arDprtInfo[parID];
    parID:= Dprt.ParentID;
    Result:= (Dprt.ID=pGroup) or (parID=pGroup);
  end;
end;
{//============================== �������� ����������� �������� �� ������� ������
function TDprtInfo.CheckShipAvailable(pShipDate: TDateTime; stID: Integer;
         WithSVKDelay, WithSchedule, WithDprtDelay: Boolean): String;
// ���� stID �� ����� - ����� �� ��������� !!!
var compDate, DayIndex, TestDayTime1, TestDayTime2: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    st: TShipTimeItem;
    sch: TTwoCodes;
    strErr: String;
begin
  Result:= '';
  sch:= nil;
  try
    if (pShipDate<DateNull) then raise EBOBError.Create('����������� ���� ��������');
    compDate:= CompareDate(pShipDate, Date);
    strErr:= '�������� ���� ��������  ���������� - '+FormatDateTime(cDateFormatY4, pShipDate);
    if (compDate<0) then raise EBOBError.Create(strErr); // ���� ������ �����������

    if WithSchedule then begin // ��������� ���� �� ������� ������ ������
      DayIndex:= trunc(pShipDate-Date);
      if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);
      sch:= TTwoCodes(Schedule[DayIndex]); // ��������� ���� �� ������� ������ ������
      if (sch.ID1<1) and (sch.ID2<1) then raise EBOBError.Create(strErr);
    end;

    if (stID<1) then Exit; // ����� �� ������ - �������
//    if (stID<1) then raise EBOBError.Create('����������� ����� ��������');

    strErr:= '�������� ����� �������� ����������';
    if not Cache.ShipTimes.ItemExists(stID) then raise EBOBError.Create(strErr);
    st:= Cache.ShipTimes[stID];
    strErr:= strErr+' - '+fnMakeAddCharStr(IntToStr(st.Hour), 2, '0', False)+':'+
             fnMakeAddCharStr(IntToStr(st.Minute), 2, '0', False);
    TestDayTime1:= (st.Hour*60+st.Minute);

    if WithSchedule then begin // ��������� ����� �� ������� ������ ������
      TestDayTime2:= TestDayTime1*60;
      if (TestDayTime2<sch.ID1) or (TestDayTime2>sch.ID2) then raise EBOBError.Create(strErr);
    end;

    if (compDate>0) then Exit; // ���� �� ������� - �������

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // ������� ��������� ������� �����
    TestDayTime2:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime2:= TestDayTime2+DelayTime; // + ������������ ������
    if WithSVKDelay then                                         // + ������������ ���
      TestDayTime2:= TestDayTime2+Cache.GetConstItem(pcSVKShipDelayMinutes).IntValue;
    if (TestDayTime1<TestDayTime2) then raise EBOBError.Create(strErr);
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS('CheckShipAvailable: '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;  }
//============================== �������� ����������� �������� �� ������� ������
function TDprtInfo.CheckShipAvailable(pShipDate: TDateTime; stID, SVKDelay: Integer;
         WithSchedule, WithDprtDelay: Boolean): String;
// ���� stID �� ����� - ����� �� ��������� !!!
var compDate, DayIndex, TestDayTime1, TestDayTime2: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    st: TShipTimeItem;
    sch: TTwoCodes;
    strErr: String;
begin
  Result:= '';
  sch:= nil;
  try
    if (pShipDate<DateNull) then raise EBOBError.Create('����������� ���� ��������');
    compDate:= CompareDate(pShipDate, Date);
    strErr:= '�������� ���� ��������  ���������� - '+FormatDateTime(cDateFormatY4, pShipDate);
    if (compDate<0) then raise EBOBError.Create(strErr); // ���� ������ �����������

    if WithSchedule then begin // ��������� ���� �� ������� ������ ������
      DayIndex:= trunc(pShipDate-Date);
      if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);
      sch:= TTwoCodes(Schedule[DayIndex]); // ��������� ���� �� ������� ������ ������
      if (sch.ID1<1) and (sch.ID2<1) then raise EBOBError.Create(strErr);
    end;

    if (stID<1) then Exit; // ����� �� ������ - �������
//    if (stID<1) then raise EBOBError.Create('����������� ����� ��������');

    strErr:= '�������� ����� �������� ����������';
    if not Cache.ShipTimes.ItemExists(stID) then raise EBOBError.Create(strErr);
    st:= Cache.ShipTimes[stID];
    strErr:= strErr+' - '+fnMakeAddCharStr(IntToStr(st.Hour), 2, '0', False)+':'+
             fnMakeAddCharStr(IntToStr(st.Minute), 2, '0', False);
    TestDayTime1:= (st.Hour*60+st.Minute);

    if WithSchedule then begin // ��������� ����� �� ������� ������ ������
      TestDayTime2:= TestDayTime1*60;
      if (TestDayTime2<sch.ID1) or (TestDayTime2>sch.ID2) then raise EBOBError.Create(strErr);
    end;

    if (compDate>0) then Exit; // ���� �� ������� - �������

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // ������� ��������� ������� �����
    TestDayTime2:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime2:= TestDayTime2+DelayTime; // + ������������ ������
    if (SVKDelay>0) then TestDayTime2:= TestDayTime2+SVKDelay;   // + ������������ ���
    if (TestDayTime1<TestDayTime2) then raise EBOBError.Create(strErr);
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS('CheckShipAvailable: '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;
{//============================================== ������� ������ �������� �� ����
function TDprtInfo.GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer;
                                     WithSVKDelay, WithDprtDelay: Boolean): String;
// �������� ������ ����� �������� ���� �������� !!!
var compDate, DayIndex, TestDayTime: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    strErr: String;
    sch: TTwoCodes;
begin
  Result:= '';
  try
    compDate:= CompareDate(pShipDate, Date);
    strErr:= '�������� ���� �������� ����������';
    if (compDate<0) then raise EBOBError.Create(strErr); // ���� ������ �����������

    DayIndex:= trunc(pShipDate-Date);
    if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);

    sch:= TTwoCodes(Schedule[DayIndex]);
    TimeMin:= sch.ID1;
    TimeMax:= sch.ID2;
    if (TimeMin<1) and (TimeMax<1) then raise EBOBError.Create(strErr);

    if (compDate>0) then Exit; // ���� �� ������� - �������

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // ������� ��������� ������� �����
    TestDayTime:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime:= TestDayTime+DelayTime; // ������������ ������
    if WithSVKDelay then                                       // ������������ ���
      TestDayTime:= TestDayTime+Cache.GetConstItem(pcSVKShipDelayMinutes).IntValue;
    TestDayTime:= TestDayTime*60;
    if (TimeMin<TestDayTime) then TimeMin:= TestDayTime;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS('GetShipTimeLimits: '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end; }
//============================================== ������� ������ �������� �� ����
function TDprtInfo.GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer;
                                     SVKDelay: Integer; WithDprtDelay: Boolean): String;
// �������� ������ ����� �������� ���� �������� !!!
var compDate, DayIndex, TestDayTime: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    strErr: String;
    sch: TTwoCodes;
begin
  Result:= '';
  try
    compDate:= CompareDate(pShipDate, Date);
    strErr:= '�������� ���� �������� ����������';
    if (compDate<0) then raise EBOBError.Create(strErr); // ���� ������ �����������

    DayIndex:= trunc(pShipDate-Date);
    if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);

    sch:= TTwoCodes(Schedule[DayIndex]);
    TimeMin:= sch.ID1;
    TimeMax:= sch.ID2;
    if (TimeMin<1) and (TimeMax<1) then raise EBOBError.Create(strErr);

    if (compDate>0) then Exit; // ���� �� ������� - �������

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // ������� ��������� ������� �����
    TestDayTime:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime:= TestDayTime+DelayTime; // + ������������ ������
    if (SVKDelay>0) then TestDayTime:= TestDayTime+SVKDelay;   // + ������������ ���
    TestDayTime:= TestDayTime*60;
    if (TimeMin<TestDayTime) then TimeMin:= TestDayTime;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS('GetShipTimeLimits: '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;
//******************************************************************************
//                               TClientInfo
//******************************************************************************
constructor TClientInfo.Create(pID: Integer; pName: String);
begin
  inherited Create(pID, 0, 0, pName, 2);
  LastTestTime:= DateNull;
//  LastPriceLoadTime:= DateNull;
  CS_client:= TCriticalSection.Create; // ��� ��������� ���������� �������
  TestSearchCountDay:= Date;
  FCountSearch := -1;                  // ��������� �������� ��������
  FCountQty    := 0;                   // ��������� �������� ��������
//  FLoadPriceCount:= 0;                 // ��������� �������� ��������
  LastCountQtyTime:= Now;
  LastCountConnectTime:= Now;
  FCountConnect:= 0;                   // ��������� �������� ��������
  TmpBlockTime:= 0;                    // ����� ��������� ��������� ����������
  FLastContract:= 0;
  CliContracts:= TIntegerList.Create;   // ��������� �������                      // PartiallyFilled
//  CliContStores:= TObjectList.Create;   // ������� ������� �� ���������� ������� �� ����������
//  CliContMargins:= TObjectList.Create;  // ������� ������� �� ����������
  CliMails:= fnCreateStringList(True, DupIgnore);
  CliPhones:= fnCreateStringList(True, DupIgnore);
  CliContDefs:= TObjectList.Create;      // ��������� ������� �� ���������� (TTwoCodes) � �����.� CliContracts
  FCliPay:= False;
end;
//==================================================
destructor TClientInfo.Destroy;
var i: Integer;
    obj: TObject;
begin
  if not Assigned(self) then Exit;
//  for i:= 0 to CliContStores.Count-1 do TIntegerList(CliContStores[i]).Free;
//  prFree(CliContStores);
//  for i:= 0 to CliContMargins.Count-1 do TLinkList(CliContMargins[i]).Free;
//  prFree(CliContMargins);
  for i:= 0 to CliContDefs.Count-1 do TTwoCodes(CliContDefs[i]).Free;
  prFree(CliContDefs);
  prFree(CliContracts);
  prFree(CS_client);
  prFree(CliMails);
  for i:= CliPhones.Count-1 downto 0 do begin
    obj:= CliPhones.Objects[i];
    if Assigned(Obj) then prFree(Obj);
  end;
  prFree(CliPhones);
  inherited;
end;
//============================================================== �������� ������
procedure TClientInfo.SetStrC(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik8_1: if (FLogin   <>Value) then FLogin   := Value; // �����
    ik8_2: if (FPassword<>Value) then FPassword:= Value; // ������
//    ik8_3: if (FMail    <>Value) then FMail    := Value; // Email
//    ik8_4: if (FPhone   <>Value) then FPhone   := Value; // ��������
    ik8_5: if (FPost    <>Value) then FPost    := Value; // ���������
    ik8_8: if (FSid     <>Value) then FSid     := Value; // sid
  end;
end;
//============================================================== �������� ������
function TClientInfo.GetStrC(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FLogin;    // �����
    ik8_2: Result:= FPassword; // ������
    ik8_3: Result:= fnGetDelimiterText(CliMails, ',', '');     // Email
//    ik8_3: Result:= FMail;     // Email
//    ik8_4: Result:= FPhone;    // ��������
    ik8_4: Result:= fnGetDelimiterText(CliPhones, ',', '');    // ��������
    ik8_5: Result:= FPost;     // ���������
    ik8_6: Result:= IntToStr(SearchCurrencyID);                                    // SearchCurrencyID ����������
    ik8_7: if Cache.FirmExist(FirmID) then Result:= Cache.arFirmInfo[FirmID].Name; // ������������ �����
    ik8_8: Result:= FSid;      // sid
  end;
end;
//================================================================= �������� ���
function TClientInfo.GetIntC(const ik: T16InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik16_1 : Result:= FSubCode;             // ��� �����
    ik16_2 : Result:= FSrcID;
    ik16_3 : Result:= FOrderNum;
//    ik16_4 : Result:= FDEFACCOUNTINGTYPE;
    ik16_5 : Result:= FDEFDELIVERYTYPE;
    ik16_6 : Result:= FCountSearch;
    ik16_7 : Result:= FCountQty;
    ik16_8 : Result:= FCountConnect;
    ik16_9 : Result:= FLastContract;
    ik16_10: Result:= FBlockKind;
//    ik16_11: Result:= FLoadPriceCount;
  end;
end;
//================================================================= �������� ���
procedure TClientInfo.SetIntC(const ik: T16InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik16_1 : if (FSubCode          <>Value) then FSubCode          := Value; // ��� �����
    ik16_2 : if (FSrcID            <>Value) then FSrcID            := Value;
    ik16_3 : if (FOrderNum         <>Value) then FOrderNum         := Value;
//    ik16_4 : if (FDEFACCOUNTINGTYPE<>Value) then FDEFACCOUNTINGTYPE:= Value;
    ik16_5 : if (FDEFDELIVERYTYPE  <>Value) then FDEFDELIVERYTYPE  := Value;
    ik16_6 : if (FCountSearch      <>Value) then FCountSearch      := Value;
    ik16_7 : if (FCountQty         <>Value) then FCountQty         := Value;
    ik16_8 : if (FCountConnect     <>Value) then FCountConnect     := Value;
    ik16_9 : if (FLastContract     <>Value) then FLastContract     := Value;
    ik16_10: if (FBlockKind        <>Value) then FBlockKind        := Value;
//    ik16_11: if (FLoadPriceCount   <>Value) then FLoadPriceCount   := Value;
  end;
end;
//======================================= �������� ����������� ��������� �������
function TClientInfo.CheckContract(contID: Integer): boolean;
begin
  Result:= False;
  if not Assigned(self) or (ID<1) or (CliContracts.Count<1) then Exit;
  Result:= Cache.Contracts.ItemExists(contID) and Cache.FirmExist(FirmID)
    and Cache.arFirmInfo[FirmID].CheckContract(contID)
    and (CliContracts.IndexOf(contID)>-1);
end;
{//========================================== ������ ������ � ������ �� ���������
function TClientInfo.GetCliStoreIndex(contID, StoreID: Integer): Integer;
var i: integer;
begin
  Result:= -1;
  if not Assigned(self) or (ID<1) then Exit;
  i:= CliContracts.IndexOf(contID);    // ������ ���������
  if (i<0) then Exit;
  if (CliContStores.Count<(i+1)) or not Assigned(CliContStores[i]) then Exit;
  try
    Result:= TIntegerList(CliContStores[i]).IndexOf(StoreID);    // ������ ������
  except
    Result:= -1;
  end;
end; }
//========================================= ��������� �������� � ������ (� ����)
function TClientInfo.AddCliContract(contID: Integer; OnlyCache: Boolean=False): Integer;
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
begin
  Result:= -1;
  if not Assigned(self) or (ID<1) then Exit;
  if not Cache.Contracts.ItemExists(contID) or not Cache.FirmExist(FirmID)
    or not Cache.arFirmInfo[FirmID].CheckContract(contID) then Exit;

  Result:= CliContracts.IndexOf(contID);        // ������ ���������
  if (Result>-1) then Exit;

  if not OnlyCache then begin
    ORDIBS:= nil;
    OrdIBD:= cntsOrd.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_AddCliContract', -1, tpWrite, true);
      OrdIBS.SQL.Text:= 'update or insert into WEBCLIENTCONTRACTS (WCCCLIENT, WCCCONTRACT, WCCARCHIVE)'+
        ' values ('+IntToStr(ID)+', '+IntToStr(contID)+', "F") matching (WCCCLIENT, WCCCONTRACT)';
      OrdIBS.ExecQuery;
      OrdIBS.Transaction.Commit;
    finally
      prFreeIBSQL(OrdIBS);
      cntsOrd.SetFreeCnt(OrdIBD);
    end;
  end;

  CS_client.Enter;
  try
    Result:= CliContracts.Add(contID);
//    CliContStores.Insert(Result, TIntegerList.Create);
//    CliContMargins.Insert(Result, TLinkList.Create);
    CliContDefs.Insert(Result, TTwoCodes.Create(0, 0));
    UpdateStorageOrderC;
  finally
    CS_client.Leave;
  end;
end;
//========================================= ������� �������� �� ������ (�� ����)
procedure TClientInfo.DelCliContract(contID: Integer; OnlyCache: Boolean=False);
var i: integer;
    OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
begin
  if not Assigned(self) or (ID<1) then Exit;
  i:= CliContracts.IndexOf(contID);      // ������ ���������
  if (i<0) then Exit;

  if not OnlyCache then begin
    ORDIBS:= nil;
    OrdIBD:= cntsOrd.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_DelCliContract', -1, tpWrite, true);
      OrdIBS.SQL.Text:= 'update or insert into WEBCLIENTCONTRACTS (WCCCLIENT, WCCCONTRACT, WCCARCHIVE)'+
        ' values ('+IntToStr(ID)+', '+IntToStr(contID)+', "T") matching (WCCCLIENT, WCCCONTRACT)';
      OrdIBS.ExecQuery;
      OrdIBS.Transaction.Commit;
    finally
      prFreeIBSQL(OrdIBS);
      cntsOrd.SetFreeCnt(OrdIBD);
    end;
  end;

  CS_client.Enter;
  try
//    CliContStores.Delete(i);             // ������� ������
//    CliContMargins.Delete(i);            // ������� �������
    CliContDefs.Delete(i);               // ������� ���������
    CliContracts.Delete(i);              // ������� ��������
  finally
    CS_client.Leave;
  end;
end;
//=========================== �������� ��� ��������/���������� ��������� �������
function TClientInfo.GetCliCurrContID: Integer;
var errmess: string;
begin
  Result:= 0;
  if not Assigned(self) or (ID<1) then Exit;
  if (CliContracts.Count<1) then // ���� ��� ��������� ����������
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  Result:= LastContract; //  ����� ��������� ��������
  if (Result<1) or (CliContracts.IndexOf(Result)<0) then  // ���� �� ��������
    Result:= Cache.arFirmInfo[FirmID].GetDefContractID; // ����� Default
  if (CliContracts.IndexOf(Result)<0) then  // ���� �� ��������
    Result:= CliContracts[0]; // ����� ������ � ������
  if not Cache.Contracts.ItemExists(Result) then
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  if (Result<>LastContract) then begin // ������ LastContract
    errmess:= SetLastContract(Result);
    if (errmess<>'') then raise EBOBError.Create(errmess);
  end;
end;
//========================================== �������� ��������� �������� �������
function TClientInfo.GetCliContract(var contID: Integer; ChangeNotFound: Boolean=False): TContract;
var i: integer;
begin
  Result:= nil;
  if not Assigned(self) or (ID<1) then Exit;
  if (CliContracts.Count<1) then // ���� ��� ��������� ����������
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  i:= ContID;
  if (i<1) then i:= GetCliCurrContID // ���� �������� �� ����� - ���� ��� ��������/���������� ��������� �������
  else if (CliContracts.IndexOf(i)<0) then begin // ���� �������� ����� - ���������
    if ChangeNotFound then i:= GetCliCurrContID
    else raise EBOBError.Create('�������� �� ��������');
  end;
  if not Cache.Contracts.ItemExists(i) then
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  contID:= i;
  Result:= Cache.Contracts[contID];
end;
//========================================== �������� ��������� �������� �������
function TClientInfo.SetLastContract(contID: Integer): String;
const nmProc = 'SetLastContract'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    firma: TFirmInfo;
begin
  Result:= '';
  if not Assigned(self) or (ID<1) then Exit;
  IBS:= nil;
  try
    if (CliContracts.Count<1) or (contID<1) or (CliContracts.IndexOf(contID)<0) then
      raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));

    if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
    firma:= Cache.arFirmInfo[FirmID]; // ���������, �������� �� ������ ���� ��������
    if not firma.CheckContract(contID) then raise EBOBError.Create('�������� �/� �� ������');

    if (contID=LastContract) then Exit;

    IBD:= cntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpWrite, true);
      IBS.SQL.Text:= 'update WEBORDERCLIENTS set WOCLLASTCONTRACT='+
        IntToStr(contID)+' where WOCLCODE='+IntToStr(ID);
      IBS.ExecQuery;
      IBS.Transaction.Commit;
      IBS.Close;
      LastContract:= contID;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
end;
//============================================= ������ �� ��������� �� ���������
function TClientInfo.GetCliContDefs(contID: Integer=0): TTwoCodes; // not Free !!!
var i: integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if not CheckContract(contID) then contID:= LastContract;
  i:= CliContracts.IndexOf(contID);        // ������ ���������
  if (i<0) then Exit;
  Result:= TTwoCodes(CliContDefs[i]);
end;
//=============================================== �������� �������� �� ���������
procedure TClientInfo.CheckCliContDefs(contID, deliv, dest: Integer);
var i: integer;
begin
  if not Assigned(self) then Exit;
  i:= CliContracts.IndexOf(contID);        // ������ ���������
  if (i<0) then Exit;
  with TTwoCodes(CliContDefs[i]) do begin
    if (ID1<>deliv) then ID1:= deliv;
    if (ID2<>dest)  then ID2:= dest;
  end;
end;

{//=============================================== ������ �� ������� �� ���������
function TClientInfo.GetContMarginLinks(contID: Integer): TLinkList; // not Free !!!
var i: integer;
begin
  Result:= TLinkList(EmptyList);
  if not Assigned(self) then Exit;
  i:= CliContracts.IndexOf(contID);        // ������ ���������
  if (i<0) then Exit;
  Result:= TLinkList(CliContMargins[i]);
end;
//===================================== ������� �� ������/��������� �� ���������
function TClientInfo.GetContCacheGrpMargin(contID, grID: Integer): Double;
var lst: TLinkList;
    link: TQtyLink;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  lst:= GetContMarginLinks(contID);
  if (lst.Count<1) then Exit;
  link:= lst.GetLinkListItemByID(grID, lkLnkByID);
  if Assigned(link) then Result:= link.Qty;
end;
//================= ������ �����/�������� � ��������� �� ��������� (TCodeAndQty)
function TClientInfo.GetContMarginListAll(contID: Integer;     // must Free !!!
         WithPgr: Boolean=False; OnlyNotZero: Boolean=False): TList;
var i, j, sysID, grID: integer;
    mlst: TLinkList;
    grlst, pgrlst: TList;
    marg: Double;
    gr: TWareInfo;
    mlink: TQtyLink;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  if not CheckContract(contID) then Exit;
//  sysID:= GetCliContract(contID).SysID;  // ������� - �� ���������
  sysID:= 0;  //
  mlst:= GetContMarginLinks(contID);         // ������ �� ������� �������
  grlst:= Cache.MarginGroups.GetGroupList(sysID); // ������ �����
  for i:= 0 to grlst.Count-1 do begin
    gr:= grlst[i];         // ������
    grID:= gr.ID;
    mlink:= mlst.GetLinkListItemByID(grID, lkLnkByID); // ���� �������
    if Assigned(mlink) then marg:= mlink.Qty else marg:= 0;
    if not OnlyNotZero or fnNotZero(marg) then
      Result.Add(TCodeAndQty.Create(Integer(gr), marg)); // ������ �� ������ -> Integer, �������

    if not WithPgr then Continue; // ������ ������

    pgrlst:= Cache.MarginGroups.GetSubGroupList(grID, sysID); // ������ �������� ������
    for j:= 0 to pgrlst.Count-1 do begin
      gr:= pgrlst[j];         // ���������
      grID:= gr.ID;
      mlink:= mlst.GetLinkListItemByID(grID, lkLnkByID); // ���� �������
      if Assigned(mlink) then marg:= mlink.Qty else marg:= 0;
      if not OnlyNotZero or fnNotZero(marg) then
        Result.Add(TCodeAndQty.Create(Integer(gr), marg)); // ������ �� ��������� -> Integer, �������
    end;
  end;
end;
//================================== ��������� ������� �� ������/�������� � ����
function TClientInfo.CheckCliContMargin(contID, grID: Integer; marg: Double): String;
const nmProc = 'CheckCliContMargin';
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    i: Integer;
begin
  Result:= '';
  if not Assigned(self) or (ID<1) then Exit;
  ORDIBD:= nil;
  ORDIBS:= nil;
  try try
    OrdIBD:= cntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, -1, tpWrite, true);
    OrdIBS.SQL.Text:= 'select ResCode from CheckCliContMargin('+
      IntToStr(ID)+', '+IntToStr(contID)+', '+IntToStr(grID)+', :marg)';
    OrdIBS.ParamByName('marg').AsFloat:= marg;
    for i:= 0 to RepeatCount do with OrdIBS.Transaction do try
      Application.ProcessMessages;
      OrdIBS.Close;
      if not InTransaction then StartTransaction;
      OrdIBS.ExecQuery;
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create('������ ������ � ����');
      if (OrdIBS.FieldByName('ResCode').AsInteger>0) then OrdIBS.Transaction.Commit;
      break;
    except
      on E: Exception do begin
        RollbackRetaining;
        if (i<RepeatCount) then sleep(RepeatSaveInterval) else Result:= E.Message;
      end;
    end;
  finally
    prFreeIBSQL(OrdIBS);
    cntsOrd.SetFreeCnt(OrdIBD);
  end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;   }
//============= ��������� ������������ ������� ������� ������� ������� ���������
procedure TClientInfo.UpdateStorageOrderC;
const nmProc = 'UpdateStorageOrder�';
var ii, contID, i, MainUser, deliv, dest: integer;
    flEx, flArh, flDel: boolean;
    FirmCode, UserCode: string;
    Firma: TFirmInfo;
//    Contract: TContract;
    listChange: TStringList;
    Conts: TIntegerList;
    IBSord: TIBSQL;
    IBDord: TIBDatabase;
//    marg: Double;
//    mlst: TLinkList;
//    link: TQtyLink;
begin
  if not Assigned(self) or (ID<1) then Exit;
  IBSord:= nil;
  IBDord:= nil;
  listChange:= TStringList.Create; // ������ SQL ��� ���������
  Conts:= TIntegerList.Create;     // ������� ������ ���������� ����� ��� ������
  try try
    IBDord:= cntsORD.GetFreeCnt;
    IBSord:= fnCreateNewIBSQL(IBDord, 'IBSord_'+nmProc, -1, tpRead, True);

    UserCode:= IntToStr(ID);
    FirmCode:= IntToStr(FirmID);
    Firma:= Cache.arFirmInfo[FirmID];
    MainUser:= Firma.SUPERVISOR;

    for i:= 0 to Firma.FirmContracts.Count-1 do // ��������� ����� - � ������� ������
      Conts.Add(Firma.FirmContracts[i]);

    IBSord.SQL.Text:= 'select WCCCONTRACT, WCCARCHIVE, WCCDeliveryDef, wccDestDef'+
                      ' from WEBCLIENTCONTRACTS WHERE WCCCLIENT='+UserCode;
    IBSord.ExecQuery;
    while not IBSord.EOF do begin
      contID:= IBSord.FieldByName('WCCCONTRACT').AsInteger;  // ��������
      flArh:= GetBoolGB(IBSord, 'WCCARCHIVE');
      flEx:= (CliContracts.IndexOf(contID)>-1);
//----------------------------------------- ��������� �������� �� ������ �������
      if (Conts.IndexOf(contID)<0) then begin // ���� � ����� ��� ��������� (������)
        if not flArh then begin
          flArh:= True;            // �������� �������� �������, ��� �����������
          listChange.Add('update WEBCLIENTCONTRACTS set WCCARCHIVE="T"'+
            ' WHERE WCCCLIENT='+UserCode+' and WCCCONTRACT='+IntToStr(contID)+';');
        end;
        flDel:= flEx;
      end else begin
        if flArh and (ID=MainUser) then begin
          flArh:= False;            // �������� �������� �������, ��� ���������
          listChange.Add('update WEBCLIENTCONTRACTS set WCCARCHIVE="F"'+
            ' WHERE WCCCLIENT='+UserCode+' and WCCCONTRACT='+IntToStr(contID)+';');
        end;
        flDel:= flEx and flArh;
        Conts.Remove(contID); // ��������� �������� - ������� �� �������� ������
      end;

      if flDel then DelCliContract(contID); // ���� �������� ��� � ������ ������� - �������
      if flArh then begin                   // ������������ ������ �� ������������ ���������
        TestCssStopException;
        while not IBSord.EOF and (contID=IBSord.FieldByName('WCCCONTRACT').AsInteger) do IBSord.Next;
        Continue;
      end;

      if not flEx then AddCliContract(contID, True); // ���� ��������� ��� � ������ ������� - ���������
//      Contract:= Firma.GetContract(contID);

      if firma.IsFinalClient then begin // ������ �������� (���������)
        deliv:= cDelivSelfGet;
        dest:= 0;
      end else begin
        deliv:= IBSord.FieldByName('WCCDeliveryDef').AsInteger;
        dest:= IBSord.FieldByName('wccDestDef').AsInteger;

if flNotReserve then
        if (deliv=cDelivReserve) then deliv:= cDelivTimeTable;
      end;

      CheckCliContDefs(contID, deliv, dest); // �������� �������� �� ���������

      TestCssStopException;
      IBSord.Next;
    end;
    IBSord.Close;

    for i:= 0 to Conts.Count-1 do begin // ���� ������� ������������ � �������� ������������� ��������� �����
      contID:= Conts[i];
      ii:= CliContracts.IndexOf(contID);
      if (ii<0) then begin
        if (ID<>MainUser) then Continue; // ���� �� ������� ������������ - ����������
        AddCliContract(contID, True); // ���� ������� ������������ - ��������� �������� � ������
      end;
      listChange.Add('update or insert into WEBCLIENTCONTRACTS (WCCCLIENT, WCCCONTRACT, WCCArchive)'+
        ' values ('+UserCode+', '+IntToStr(contID)+', "F") matching (WCCCLIENT, WCCCONTRACT);');
    end;

    if (CliContracts.Count>0) and ((LastContract<1) or (CliContracts.IndexOf(LastContract)<0)) then begin  // ???
      contID:= CliContracts[0];
      listChange.Add('update WEBORDERCLIENTS set WOCLLASTCONTRACT='+
        IntToStr(contID)+' where WOCLCODE='+UserCode+';');
      LastContract:= contID;
    end;
{
//---------------------------------------------------------------------- �������
    IBSord.SQL.Text:= 'Select WCCCONTRACT, WCCMGrPgrCode, WCCMmargin from'+
                      ' (select WCCCODE, WCCCONTRACT '+
                      '   from WEBCLIENTCONTRACTS WHERE WCCCLIENT='+UserCode+
                      '     and WCCARCHIVE="F" order by WCCCONTRACT)'+
                      ' left join WebCliContMargins on WCCMCliCont=WCCCODE';
    IBSord.ExecQuery;
    while not IBSord.EOF do begin
      contID:= IBSord.FieldByName('WCCCONTRACT').AsInteger;  // ��������
      i:= CliContracts.IndexOf(contID);
      if (i<0) then begin      // ������������ ������ �� ������������ ���������
        TestCssStopException;
        while not IBSord.EOF and (contID=IBSord.FieldByName('WCCCONTRACT').AsInteger) do IBSord.Next;
        Continue;
      end;

      mlst:= TLinkList(CliContMargins[i]);
      mlst.SetLinkStates(False, CS_client);
      while not IBSord.EOF and (contID=IBSord.FieldByName('WCCCONTRACT').AsInteger) do begin
        ii:= IBSord.FieldByName('WCCMGrPgrCode').AsInteger; // ��� ������/���������
        marg   := IBSord.FieldByName('WCCMmargin').AsFloat;      // �������
        if fnNotZero(marg) and Cache.GrPgrExists(ii) then begin
          link:= mlst.GetLinkListItemByID(ii, lkLnkByID);
          if not Assigned(link) then begin
            link:= TQtyLink.Create(0, marg, Cache.arWareInfo[ii]);
            mlst.AddLinkListItem(link, lkLnkByID, CS_client);
          end else begin
            link.Qty:= marg;
            link.State:= True;
          end;
        end;
        IBSord.Next;
      end;
      mlst.DelNotTestedLinks(CS_client);
    end;
    IBSord.Close;
}
    if (listChange.Count>0) then begin //------------------- ���� ���� ���������
      listChange.Insert(0, 'execute block as begin ');
      listChange.Add(' end');
      IBSord.SQL.Clear;
      fnSetTransParams(IBSord.Transaction, tpWrite, True);
      with IBSord.Transaction do if not InTransaction then StartTransaction;
      IBSord.SQL.AddStrings(listChange);
      IBSord.ExecQuery;                  // ������ � ����
      IBSord.Close;
      with IBSord.Transaction do if InTransaction then Commit;
    end;

  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'_'+UserCode+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
  end;
  finally
    prFree(listChange);
    prFree(Conts);
    prFreeIBSQL(IBSord);
    cntsORD.SetFreeCnt(IBDord);
  end;
end;
//=================================================== �������� ��������� �������
function TClientInfo.CheckIsFinalClient: Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not Cache.FirmExist(FirmID) then Exit;
  Result:= Cache.arFirmInfo[FirmID].IsFinalClient;
end;
//========================================================== �������� ����������
function TClientInfo.CheckBlocked(inCS: Boolean=False; mess: Boolean=False; Source: Integer=0): String;
const nmProc = 'CheckBlocked';
// iBlock, tLastAct - ���������� �������� �� ����, mess=True - ������� � Result ��������� ������������
var fl: Boolean;
    ss, sTimeTo, Delim: String;
//    tLastAct: TDateTime;
begin
  Result:= '';
  fl:= Blocked; // ���������� ��������� ����������
  if InCS then CS_client.Enter;
  try

//-------------------------------------------------------- �������� ������������
    if (BlockKind=cbBlockedTmpByConnLimit) then begin

      if (TmpBlockTime<1) then // ��������� ����� ���������
        TmpBlockTime:= IncMinute(LastAct, Cache.GetConstItem(pcTmpBlockInterval).IntValue);

      if (Now>TmpBlockTime) then  //-------------- ���� �������������� ���������
        if SaveClientBlockType(cbUnBlockedTmpByCSS, ID, LastAct) then // ������������� ������� � ����
          BlockKind:= 0;                  // � ����

//---------- ������ ���������� - ���������� ����� ��������� ��������� ����������
    end else if (BlockKind in [cbBlockedByAdmin, cbBlockedByConnectLimit]) and (TmpBlockTime>0) then begin
      TmpBlockTime:= 0;

//--------- ������� ����� ���� - ���������� ����� ��������� ��������� ����������
    end else if (BlockKind=0) and (TmpBlockTime>0) and not SameDate(Now, TmpBlockTime) then begin
      TmpBlockTime:= 0;
    end;

    Blocked:= (BlockKind>0); // � ����

    if Blocked and mess then begin // ��������� ��������� ������������ � ����������
      if not (Source in [cosByVlad, cosByWeb]) then Source:= cosByWeb;
      if (Source=cosByVlad) then Delim:= cStrVladDelim else Delim:= ''; // ����������� ��� Vlad

      ss:= MessText(mtkNotLoginProcess, Login); // '��������� �������� �� ������ '+Login+' �������������.'
      ss:= copy(ss, 1, length(ss)-1)+Delim; // �������� ����� � ��������� ����������� ��� Vlad
      case BlockKind of
        cbBlockedBySearchLimit : ss:= ss+' ��-�� ���������� ������ ��������.'; // ��-�� ���������� ������ ��������� �������� �� ����
        cbBlockedByAdmin       : ss:= ss+' ��������������� ������� �������.'; // (�������)
        cbBlockedTmpByConnLimit: begin
            sTimeTo:= FormatDateTime(cDateTimeFormatY4N, TmpBlockTime);
            ss:= ss+' �� '+sTimeTo+Delim+' ��-�� ���������� ������ ��������.';         // ��������
          end;
        cbBlockedByConnectLimit: ss:= ss+' ��-�� ���������� ���������� ������ ��������.'; // ������������
      end; // case
      Result:= ss;

    end else if not Blocked and fl then begin // ���� �������������� - ���������� ��������
      CountSearch:= 0;
      CountQty:= 0;
      CountConnect:= 0;
    end;
  finally
    if InCS then CS_client.Leave;
  end;
end;
//======================================== ���������� ����� �� �������� � ������
procedure CheckRequestsAttach(clientID: Integer; var Att: TStringList; bTime, eTime: TDateTime);
const nmProc = 'CheckRequestsAttach';
var ss, nf: String;
begin
  ss:= fnRepClientRequests(clientID, bTime, eTime, nf);
  if (ss<>'') then prMessageLOGS(nmProc+': '+ss)
  else if (nf<>'') then Att.Add(nf);
end;
//================================================== ��������� ������� ���������
procedure TClientInfo.CheckConnectCount; // ����� - � prSetThLogParams
const nmProc = 'CheckConnectCount';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    iCount, LimitCount, LimitInterval, HistInterval, BlockType, minCount, secCount, OldBlockKind: Integer;
    s, adrTo, regMail, cliMail, sTimeTo, mess, CliMess, sCount, ss: String;
//    Empl: TEmplInfoItem;
    Body, Attach: TStringList;
    flTmpBlock, TestSending, OldBlocked: Boolean;
    BlockTime, BeginTime, EndTime: TDateTime;
begin
  if not Assigned(self) or Arhived or Blocked then Exit; // ������������
  Body:= nil;
  Attach:= nil;
  ORD_IBS:= nil;
  sTimeTo    := '';
  adrTo      := '';
  cliMess    := '';
  flTmpBlock := (TmpBlockTime<1);
  TestSending:= GetIniParamInt(nmIniFileBOB, 'Options', 'ConnectLimit_tmp', 0)=1;
  BeginTime  := LastCountConnectTime;
  EndTime    := Now();
  secCount   := SecondsBetween(BeginTime, EndTime);
  minCount   := secCount div 60; // ���-�� �����
  secCount   := secCount mod 60;
  BlockTime  := EndTime;
  try //--------------------------------------------------------------- ��������
    LimitCount:= Cache.GetConstItem(pcClientConnectLimit).IntValue;
    LimitInterval:= Cache.GetConstItem(pcClientConnLimInterval).IntValue;
    CS_client.Enter;
    try
      if (minCount>=LimitInterval) then begin
        LastCountConnectTime:= Now;     // ���������� �������
        iCount:= 1;                                                         
      end else iCount:= CountConnect+1; // ��������� �������

      if (iCount<>CountConnect) then CountConnect:= iCount; // ������ �������� �������� �������
      if (CountConnect<=LimitCount) then Exit; // �� ��������� - �������

      sCount:= '  '+IntToStr(CountConnect)+' �������� �� '+IntToStr(minCount)+' ��� '+IntToStr(secCount)+' ���';

// begin ---------------- �������� �������� 2 - ��� [Options] ConnectLimit_tmp=1
      if TestSending then try
        Body:= TStringList.Create;
        Attach:= TStringList.Create;
        with Cache do try
          Body.Add(FormatDateTime(cDateTimeFormatY4S, Now()));
          Body.Add('������������ � ������� `'+Login+'` (��� '+IntToStr(ID)+')');
          Body.Add('  ���������� '+FirmName);
          if FirmExist(FirmID) then begin
            s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
            if (s<>'') then Body.Add('  '+s);
          end;
          Body.Add('�������� ����� ��������� � �������:');
          Body.Add(sCount);

          adrTo:= Cache.GetConstEmails(pcTestingSending2, FirmID);
          if adrTo='' then adrTo:= fnGetSysAdresVlad(caeOnlyDayLess);

          CheckRequestsAttach(ID, Attach, BeginTime, EndTime); // ���������� ����� �� ��������

          s:= n_SysMailSend(adrTo, '���������� ������ ��������� � �������', Body, Attach, '', '', True);
          if s<>'' then prMessageLOGS(nmProc+': error send mail to admins: '+s);

          for iCount:= 0 to Body.Count-1 do begin // ����� � ���
            s:= Body[iCount];
            if (trim(s)='') then Continue;
            if iCount=0 then prMessageLOGS(nmProc+': '+s) else prMessageLOGS(s);
          end;
          LastCountConnectTime:= EndTime; // ���������� �������
          CountConnect:= 0;
        except
          on E: Exception do prMessageLOGS(nmProc+'('+IntToStr(ID)+'): '+E.Message);
        end;
        exit;
      finally
        prFree(Body);
        ClearAttachments(Attach, True);
      end;
// end ----------------------------------------------------- �������� �������� 2     

//----------------------------------------------------------- ���������� �������
      BlockType:= fnIfInt(flTmpBlock, cbBlockedTmpByConnLimit, cbBlockedByConnectLimit);
      OldBlockKind:= BlockKind;
      OldBlocked:= Blocked;
      Blocked:= True;              // ���������� � ����
      BlockKind:= BlockType;
      if SaveClientBlockType(BlockType, ID, BlockTime) then begin // ���������� � ����
        LastCountConnectTime:= EndTime;
        CountConnect:= 0;            // ���������� �������
        if flTmpBlock then begin     // ��������� ����������
          TmpBlockTime:= IncMinute(BlockTime, Cache.GetConstItem(pcTmpBlockInterval).IntValue);
                       // ��������� 2 ��� ��-�� ����.������� ������� �� ��������
          sTimeTo:= FormatDateTime(cDateTimeFormatY4N, IncMinute(TmpBlockTime, 2));
        end else TmpBlockTime:= 0;   // ������������� ����������

      end else begin // �� ���������� ���������� - ����� � ����
        Blocked:= OldBlocked;
        BlockKind:= OldBlockKind;
      end;
    finally
      CS_client.Leave;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  if not Blocked then exit; // ���� �� ���������� - �������
                                                                                      
//--------------------------------------------- ��������� ��������� � ����������
  Body:= TStringList.Create;
  Attach:= TStringList.Create;
  with Cache do try
    cliMail:= ExtractFictiveEmail(Mail); //------------------------ ������������
    if (cliMail='') then begin  // ���� Mail ����� ???
      cliMess:= '����������� � ���������� ������� �� ���������� - �� ������ Email';
    end else begin
      Body.Add('������� ������ ������������ (����� `'+Login+'`) �������������');
      if flTmpBlock then begin // ��������� ����������
        Body.Add(' �� '+sTimeTo+' ��-�� ���������� ������ ��������� � �������.');
//        Body.Add('�� ������� ������� �������������'+#10' ����������� � ��������� ������������� ��������.');
      end else begin
        Body.Add(' ��-�� ���������� ���������� ������ ��������� � �������.');
        Body.Add('�� ������� ������������� �����������');
        Body.Add(' � ��������� ������������� ��������.');
      end;
      s:= n_SysMailSend(cliMail, '����������� � ���������� ������� ������', Body, nil, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // ���� �� ���������� � ����
        prMessageLOGS(nmProc+'(send mail to client): '+s);
        cliMess:= '������ �������� ����������� � ���������� �������';
      end else
        cliMess:= '����������� � ���������� ���������� ������� �� Email '+cliMail;
    end;

    regMail:= ''; //----------------------------------------- �� ������ ��������
    Body.Clear;
    Body.Add(FormatDateTime(cDateTimeFormatY4S, Now()));
    Body.Add('������������ � ������� `'+Login+'` (��� '+IntToStr(ID)+')');
    Body.Add('  ���������� '+FirmName);
    if FirmExist(FirmID) then begin
      s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
      if (s<>'') then Body.Add('  '+s);
    end;

    if flTmpBlock then begin // ��������� ����������
      regMail:= Cache.GetConstEmails(pcEmpl_list_TmpBlock, mess, FirmID);
      Body.Add('�������� ����� ��������� � �������.');
      iCount:= Body.Count; // ���������� ������� ��� ������� ���-�� ��������
      Body.Add(#10'������� ������ � ������� ������� ������������� �� '+sTimeTo);
    end else begin   // ������������� ����������
      regMail:= Cache.GetConstEmails(pcEmpl_list_FinalBlock, mess, FirmID);
      Body.Add('�������� �������� ����� ��������� � �������.');
      iCount:= Body.Count; // ���������� ������� ��� ������� ���-�� ��������
      Body.Add(#10'������� ������ � ������� ������� �������������.');
    end;
    if cliMess<>'' then Body.Add(#10+cliMess);

    cliMess:= '';                         // ������� ���������� �� ���������
    HistInterval:= Cache.GetConstItem(pcBlockHistoryIntMonth).IntValue;
    if HistInterval<1 then HistInterval:= 1;
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
        ORD_IBS.SQL.Text:= 'select protComment, PROTTIME'+ // protCommand, protType, protUSERID,
          ' from protocol where protWOCL='+IntToStr(ID)+
          ' and protCommand in ('+IntToStr(csBlockWebUser)+', '+IntToStr(csUnblockWebUser)+')'+
          ' and PROTTIME between :time1 and :time2 order by PROTTIME';
        ORD_IBS.ParamByName('time1').AsDateTime:= IncMonth(Date, -HistInterval); // �� HistInterval �-���
        ORD_IBS.ParamByName('time2').AsDateTime:= IncMinute(BlockTime, -5);      // �� ���� ����������
        ORD_IBS.ExecQuery;
        while not ORD_IBS.Eof do begin
          s:= FormatDateTime(cDateTimeFormatY4S, ORD_IBS.fieldByName('PROTTIME').AsDateTime);
          cliMess:= cliMess+#10+s+' - '+ORD_IBS.fieldByName('protComment').AsString;
          TestCssStopException;
          ORD_IBS.Next;
        end;
      finally
        prFreeIBSQL(ORD_IBS);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;
    except
      on E: Exception do prMessageLOGS(nmProc+'('+IntToStr(ID)+'): '+E.Message);
    end;
    if cliMess<>'' then begin
      case HistInterval of
        1: ss:= '�-�';
        2..4: ss:= '�-��';
        5..12: ss:= '�-���';
        else ss:= '';
      end;
      if ss<>'' then ss:= ' �� '+IntToStr(HistInterval)+' '+ss;
      Body.Add(#10+'������� ���������� �������'+ss+':'+cliMess);
    end;

    CheckRequestsAttach(ID, Attach, BeginTime, EndTime); // ���������� ����� �� ��������

    if regMail='' then // � s ���������� ������ � ������ ��������
      s:= '��������� � ���������� ������� �� ���������� - �� ������� E-mail ��������'
    else begin
      s:= n_SysMailSend(regMail, '���������� ������� ������ ������������', Body, Attach, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // ���� �� ���������� � ����
        prMessageLOGS(nmProc+'(send mail to empls): '+s);
        s:= '������ �������� ��������� � ���������� ������� �� Email: '+regMail;
      end else s:= '��������� � ���������� ������� ���������� �� Email: '+regMail;
    end;
                             //---------------------------- �������� (���������)
    if s<>''       then Body.Add(#10+s);
    if mess<>''    then Body.Add(#10+mess); // ��������� � ����������� �������

    adrTo:= Cache.GetConstEmails(pcBlockMonitoringEmpl, mess, FirmID);
    if mess<>'' then Body.Add(mess);

    if adrTo='' then adrTo:= GetSysTypeMail(constIsAuto); // ����� ���. �� ���� (�� ����.������)

    if adrTo<>'' then begin
      s:= n_SysMailSend(adrTo, '���������� ������� ������ ������������', Body, Attach, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
        prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
    end;
                             //----------------------------------------- �������
    Body.Insert(iCount, 'for admin ----- '+sCount); // ������� ���-�� ��������

    adrTo:= GetConstEmails(pcEmplORDERAUTO);
    if adrTo='' then adrTo:= fnGetSysAdresVlad(caeOnlyDayLess);
    if adrTo<>'' then begin
      s:= n_SysMailSend(adrTo, '���������� ������� ������ ������������', Body, Attach, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
        prMessageLOGS(nmProc+'(send mail to admins): '+s);
    end;
                             // ------------------------------------ ����� � ���
    prMessageLOGS(nmProc+': ���������� �������');
    for iCount:= 0 to Body.Count-1 do if trim(Body[iCount])<>'' then
      prMessageLOGS(StringReplace(Body[iCount], #10, '', [rfReplaceAll]));
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  prFree(Body);
  ClearAttachments(Attach, True);
end;
//======================= ��������� ������� �������� ������� (��������� �������)
procedure TClientInfo.CheckQtyCount;
const nmProc = 'CheckQtyCount';
var iCount, LimitCount, LimitInterval, minCount, secCount: Integer;
    s, adrTo: String;
    Body, Attach: TStringList;
    BeginTime, EndTime: TDateTime;
begin
  if not Assigned(self) or Arhived or Blocked then Exit; // ������������
  CS_client.Enter;
  try try
    LimitCount:= Cache.GetConstItem(pcMaxClientQtyCount).IntValue;
    LimitInterval:= Cache.GetConstItem(pcMaxClientQtyInterval).IntValue;
    BeginTime:= LastCountQtyTime;
    EndTime:= Now;
    secCount:= SecondsBetween(BeginTime, EndTime);
    minCount:= secCount div 60; // ���-�� ������ �����
    secCount:= secCount mod 60;
    if (minCount>=LimitInterval) then begin
      LastCountQtyTime:= EndTime;     // ���������� �������
      iCount:= 1;
    end else iCount:= CountQty+1; // ��������� �������
    if iCount<>CountQty then CountQty:= iCount; // ������ �������� ��������
    if CountQty<=LimitCount then Exit; // �� ��������� - �������

//---------------------------------------------------------  �������� �������� 1
    Body:= TStringList.Create;
    Attach:= TStringList.Create;
    with Cache do try
      Body.Add(FormatDateTime(cDateTimeFormatY4S, Now()));
      Body.Add('������������ � ������� `'+Login+'` (��� '+IntToStr(ID)+')');
      Body.Add('  ���������� '+FirmName);
      if FirmExist(FirmID) then
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref])
      else s:= '';
      if (s<>'') then Body.Add('  '+s);
      Body.Add('�������� ����� �������� �������:');
      Body.Add('  '+IntToStr(CountQty)+' �������� �� '+IntToStr(minCount)+' ��� '+IntToStr(secCount)+' ���');

      CheckRequestsAttach(ID, Attach, BeginTime, EndTime); // ���������� ����� �� ��������

      adrTo:= Cache.GetConstEmails(pcTestingSending1, FirmID);
      if adrTo='' then adrTo:= fnGetSysAdresVlad(caeOnlyDayLess);

      s:= n_SysMailSend(adrTo, '���������� ������ �������� �������', Body, Attach, '', '', True);
      if s<>'' then prMessageLOGS(nmProc+': error send mail to admins: '+s);

      for iCount:= 0 to Body.Count-1 do begin // ����� � ���
        s:= Body[iCount];
        if (trim(s)='') then Continue;
        if iCount=0 then prMessageLOGS(nmProc+': '+s) else prMessageLOGS(s);
      end;

      LastCountQtyTime:= EndTime; // ���������� �������
      CountQty:= 0;
    finally
      prFree(Body);
      ClearAttachments(Attach, True);
    end;
//---------------------------------------------------------  �������� �������� 1
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  finally
    CS_client.Leave;
  end;
end;

//******************************************************************************
//                               TEmplInfoItem
//******************************************************************************
constructor TEmplInfoItem.Create(pID, pManID, pDprtID: Integer; pName: String);
begin
  inherited Create(pID, pManID, pDprtID, pName, soGrossBee, True);
  SetLength(UserRoles, 0);
  LastTestTime:= DateNull;
  LastActionTime:= DateNull;
  Session:= '';
end;
//==================================================
destructor TEmplInfoItem.Destroy;
begin
  if not Assigned(self) then Exit;
  TestUserRolesLength(0, false);
  inherited;
end;
//================================================================= �������� ���
function TEmplInfoItem.GetIntE(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FID;       // = EMPLCODE(GB)
    ik8_2: Result:= FSubCode;  // = EMPLMANCODE(GB)
    ik8_3: Result:= FOrderNum; // ��� ������������� �� EMPLDPRTCODE(ORD, EMPLOYEES)
    ik8_4: Result:= FFaccReg;   // ������
  end;
end;
//================================================================= �������� ���
procedure TEmplInfoItem.SetIntE(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if (FID      <>Value) then FID      := Value; // = EMPLCODE(GB)
    ik8_2: if (FSubCode <>Value) then FSubCode := Value; // = EMPLMANCODE(GB)
    ik8_3: if (FOrderNum<>Value) then FOrderNum:= Value; // ��� ������������� �� EMPLDPRTCODE(ORD, EMPLOYEES)
    ik8_4: if (FFaccReg <>Value) then FFaccReg := Value; // ������
  end;
end;
//============================================================== �������� ������
function TEmplInfoItem.GetStrE(const ik: T16InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik16_1: Result:= FSurname;     // ������� �� MANS
    ik16_2: Result:= FName;        // ��� �� MANS
    ik16_3: Result:= FPatron;      // �������� �� MANS
    ik16_4: Result:= FServerLog;   // ����� �� EMPLLOGIN(ORD, EMPLOYEES)
    ik16_5: Result:= FPASSFORSERV; // ������ �� EMPLPASS(ORD, EMPLOYEES)
    ik16_6: Result:= FGBLogin;     // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    ik16_7: Result:= FGBRepLogin;  // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    ik16_8: Result:= FMail;        // Email
    ik16_9: Result:= FSession;
    ik16_10: begin                 // ������� � �.�. ����������
        Result:= FSurname;
        if FName<>''   then Result:= Result+' '+AnsiUpperCase(copy(FName, 1, 1))+'.';
        if FPatron<>'' then Result:= Result+AnsiUpperCase(copy(FPatron, 1, 1))+'.';
      end;
    ik16_11: begin                  // ������ � � � ����������
        Result:= FSurname;
        if FName<>''   then Result:= Result+' '+FName;
        if FPatron<>'' then Result:= Result+' '+FPatron;
      end;
  end;
end;
//============================================================== �������� ������
procedure TEmplInfoItem.SetStrE(const ik: T16InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik16_1: if (FSurname    <>Value) then FSurname    := Value; // ������� �� MANS
    ik16_2: if (FName       <>Value) then FName       := Value; // ��� �� MANS
    ik16_3: if (FPatron     <>Value) then FPatron     := Value; // �������� �� MANS
    ik16_4: if (FServerLog  <>Value) then FServerLog  := Value; // ����� �� EMPLLOGIN(ORD, EMPLOYEES)
    ik16_5: if (FPASSFORSERV<>Value) then FPASSFORSERV:= Value; // ������ �� EMPLPASS(ORD, EMPLOYEES)
    ik16_6: if (FGBLogin    <>Value) then FGBLogin    := Value; // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    ik16_7: if (FGBRepLogin <>Value) then FGBRepLogin := Value; // ����� �� USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    ik16_8: if (FMail       <>Value) then FMail       := Value; // Email
    ik16_9: if (FSession    <>Value) then FSession    := Value;
  end;
end;
//================================================ ��������� ����� ������� �����
procedure TEmplInfoItem.TestUserRolesLength(len: integer; ChangeOnlyLess: boolean=True; inCS: boolean=True);
var fl: boolean;
begin
  if not Assigned(self) then Exit;
  if ChangeOnlyLess then fl:= (Length(UserRoles)<len) else fl:= (Length(UserRoles)<>len);
  if fl then try // ���� ���� ������ �����
    if inCS then Cache.CS_Empls.Enter;
    if Length(UserRoles)<len then
      prCheckLengthIntArray(UserRoles, len-1) // ��������� ����� �������, ���� ����, � ���������� ��������
    else SetLength(UserRoles, len);
  finally
    if inCS then Cache.CS_Empls.Leave;
  end;
end;
//======================================================= ��������� ������ �����
procedure TEmplInfoItem.TestUserRoles(roles: Tai);
var i: integer;
begin
  if not Assigned(self) then Exit else try
    Cache.CS_Empls.Enter;                    // ��������� /�������� ����� �������
    TestUserRolesLength(length(roles), false, false);
    for i:= 0 to High(roles) do  // ���� �� ������ ������
      if UserRoles[i]<>roles[i] then UserRoles[i]:= roles[i];
  finally
    Cache.CS_Empls.Leave;
  end;
end;
//=============================================================== ��������� ����
procedure TEmplInfoItem.AddUserRole(role: Integer);
var i: integer;
begin
  if not Assigned(self) then Exit;
  i:= fnInIntArray(role, UserRoles); // ��������� ����������� ���� � �������
  if i>-1 then Exit;                 // ���� ���� - �������
  i:= Length(UserRoles);
  try
    Cache.CS_Empls.Enter;
    TestUserRolesLength(i+1, true, false); // ��������� ����� �������
    UserRoles[i]:= role;                   // ��������� ����
  finally
    Cache.CS_Empls.Leave;
  end;
end;
//================================================================= ������� ����
procedure TEmplInfoItem.DelUserRole(role: Integer);
var i, j: integer;
begin
  if not Assigned(self) then Exit;
  i:= fnInIntArray(role, UserRoles); // ��������� ����������� ���� � �������
  if i<0 then Exit;                  // ���� ��� - �������
  try
    Cache.CS_Empls.Enter;                                         // ������� ����
    for j:= i to Length(UserRoles)-2 do UserRoles[j]:= UserRoles[j+1];
    TestUserRolesLength(Length(UserRoles)-1, false, false); // �������� ����� �������
  finally
    Cache.CS_Empls.Leave;
  end;
end;
//=============================================================== ��������� ����
function TEmplInfoItem.UserRoleExists(role: Integer): boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= fnInIntArray(role, UserRoles)>-1; // ��������� ����������� ���� � �������
end;
//======================================== ���������� ������ � �������� ��������
function VisStoresSortCompare(Item1, Item2: Pointer): Integer;
var Store1, Store2: TDprtInfo;
    Par1, Par2: Integer;
begin
  with Cache do try
    Store1:= GetLinkPtr(Item1);
    Store2:= GetLinkPtr(Item2);
    Par1:= Store1.ParentID;
    Par2:= Store2.ParentID;
    if (Par1<>Par2) and DprtExist(Par1) and DprtExist(Par2) then begin
      Store1:= arDprtInfo[Par1];
      Store2:= arDprtInfo[Par2];
      Result:= AnsiCompareText(Store1.MainName, Store2.MainName);
    end else begin
      if Store1.IsStoreHouse then Par1:= 0 else Par1:= 2;
      if Store2.IsStoreHouse then Par2:= 0 else Par2:= 2;
      if (Par1=Par2) then
        Result:= AnsiCompareText(Store1.MainName, Store2.MainName)
      else if (Par1>Par2) then Result:= 1 else  Result:= -1;
    end;
  except
    Result:= 0;
  end;
end;

//******************************************************************************
//                               TFirmInfo
//******************************************************************************
constructor TFirmInfo.Create(pID: Integer; pName: String);
begin
  inherited Create(pID, 0, 0, pName, 2);
  CS_firm:= TCriticalSection.Create; // ��� ��������� ����������
  SetLength(FirmClients, 0);
  FirmClasses:= TIntegerList.Create;   // ���� ��������� �����
  FirmContracts:= TIntegerList.Create; // ��������� �����
  FirmManagers:= TIntegerList.Create;  // ��������� �����
  LastDebtTime:= DateNull;
  LastTestTime:= DateNull;
  PartiallyFilled:= True;
  FHostCode:= pID;
  FBonusQty:= 0;
  FResLimit:= -1;
  FAllOrderSum:= 0;
  FBoolFOpts:= [];
//  FLabelLinks:= TLinks.Create(CS_firm); // ������ � ����������
  FirmDiscModels:= TObjectList.Create; // ����������� ������� ������ �����
  LegalEntities:= TObjectList.Create;  // ����.����� �/�, Object - TBaseDirItem
  FirmDestPoints:= TObjectList.Create; // �������� ����� �/�, Object - TDestPoint
  FirmCredProfiles:= TObjectList.Create; // ������� ����.������� �/�, Object - TCredProfile
end;
//==================================================
destructor TFirmInfo.Destroy;
begin
  if not Assigned(self) then Exit;
  SetLength(FirmClients, 0);
  prFree(FirmClasses);
  prFree(FirmContracts);
  prFree(FirmManagers);
  prFree(FirmDiscModels);
//  prFree(FLabelLinks);
  prFree(CS_firm);
  prFree(LegalEntities);
  prFree(FirmDestPoints);
  prFree(FirmCredProfiles);
  FBoolFOpts:= [];
  inherited;
end;
//============================================================== �������� ������
procedure TFirmInfo.SetStrF(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik8_1: if (FUPPERSHORTNAME<>Value) then FUPPERSHORTNAME:= Value;
    ik8_2: if (FUPPERMAINNAME <>Value) then FUPPERMAINNAME := Value;
    ik8_3: if (FNUMPREFIX     <>Value) then FNUMPREFIX     := Value; // ������� ����� �������
    ik8_4: if (FActionText    <>Value) then FActionText:= Value;     // ��������� ������� � �����
  end;
end;
//============================================================== �������� ������
function TFirmInfo.GetStrF(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FUPPERSHORTNAME;
    ik8_2: Result:= FUPPERMAINNAME;
    ik8_3: Result:= FNUMPREFIX;               // ������� ����� �������
    ik8_4: Result:= FActionText;             // ��������� ������� � �����
    ik8_5: Result:= Cache.GetFirmTypeName(FFirmType);
  end;
end;
//================================================================= �������� ���
function TFirmInfo.GetIntF(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_2: Result:= FSUPERVISOR;  // ��� �������� ������������
    ik8_3: Result:= FFirmType;
    ik8_4: Result:= FHostCode;    // ��� ��� ����� � ����������
    ik8_5: Result:= FContUnitOrd; // ��� ��������� unit-������
  end;
end;
//================================================================= �������� ���
procedure TFirmInfo.SetIntF(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_2: if (FSUPERVISOR  <>Value) then FSUPERVISOR  := Value; // ��� �������� ������������
    ik8_3: if (FFirmType    <>Value) then FFirmType    := Value;
    ik8_4: if (FHostCode    <>Value) then FHostCode    := Value; // ��� ��� ����� � ����������
    ik8_5: if (FContUnitOrd <>Value) then FContUnitOrd := Value; // ��� ��������� unit-������
  end;
end;
//======================================================= �������� ���. ��������
function TFirmInfo.GetDoubF(const ik: T8InfoKinds): Double;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FBonusQty;     // ���-�� ������� �/�
    ik8_2: Result:= FBonusRes;     // ���-�� ������� �/� � �������
    ik8_3: Result:= FResLimit;     // ����� �������
    ik8_4: Result:= FAllOrderSum;  // ����� �������
  end;
end;
//======================================================= �������� ���. ��������
procedure TFirmInfo.SetDoubF(const ik: T8InfoKinds; pValue: Double);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: if fnNotZero(FBonusQty    -pValue) then FBonusQty    := pValue;
    ik8_2: if fnNotZero(FBonusRes    -pValue) then FBonusRes    := pValue;
    ik8_3: if fnNotZero(FResLimit    -pValue) then FResLimit    := pValue;
    ik8_4: if fnNotZero(FAllOrderSum -pValue) then FAllOrderSum := pValue;
  end;
end;
//============================================================= �������� �������
function TFirmInfo.GetBoolF(const ik: T8InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FBoolFOpts);
end;
//============================================================= �������� �������
procedure TFirmInfo.SetBoolF(const ik: T8InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FBoolFOpts:= FBoolFOpts+[ik] else FBoolFOpts:= FBoolFOpts-[ik];
end;
//================================================================= �������� ���
function TFirmInfo.GetRegional: Integer;          // �������� ��� ��������� �� def-���������  // ��������
var empl: TEmplInfoItem;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if GetDefContract.FindContManager(empl) then Result:= Empl.ID; // ��� ���������
end;
//=============== ������ �����/���/���/Email-�� ���������� ����� (����� �������)
function TFirmInfo.GetFirmManagersString(params: TFirmManagerParams=[fmpName, fmpShort]): String;
//    TFirmManagerParam = (fmpCode, fmpName, fmpEmail, fmpShort, fmpPref, fmpFacc);
// 1. fmpCode - ������ ����� ����������, +fmpFacc - ������ ����� ��� (��������� ������������)
// 2. fmpEmail - ������ Email-�� ���������� (��������� ������������)
// 3. fmpName - ������ ������ ��� ����������, +fmpShort - �������+��������,
// 4. fmpName + fmpFacc - ������ ������ ������������ ���
// 3-4. +fmpPref - � ��������� '��������� �/� ' ��� '��� �/� '

var i, j, pID: Integer;
    Empl: TEmplInfoItem;
    s: String;
    ilst: TIntegerList;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  j:= 0; // �������
//-------------------------------------------------------------------------- ���
  if (fmpFacc in params) then try
    ilst:= TIntegerList.Create;
    for i:= 0 to FirmContracts.Count-1 do begin // �������� ���� ���, ������� ������
      pID:= FirmContracts[i];
      if not Cache.Contracts.ItemExists(pID) then Continue;
      ilst.Add(Cache.Contracts[pID].FacCenter);
    end;
    for i:= 0 to ilst.Count-1 do begin
      pID:= ilst[i];
      if not Cache.FiscalCenters.ItemExists(pID) then Continue;
      s:= '';
      if (fmpCode in params) then s:= IntToStr(pID) // ����
      else if (fmpName in params) then              // ������������
        s:= TFiscalCenter(Cache.FiscalCenters[pID]).Name;
      if (s<>'') then begin
        Result:= Result+fnIfStr(Result='', '', ', ')+s;
        inc(j);
      end;
    end;
  finally
    prFree(ilst);
//-------------------------------------------------------------------- ���������
  end else for i:= 0 to FirmManagers.Count-1 do begin
    pID:= FirmManagers[i];
    if not Cache.EmplExist(pID) then Cache.TestEmpls(pID);
    if not Cache.EmplExist(pID) then Continue;
    s:= '';
    if (fmpCode in params) then s:= IntToStr(pID) // ����
    else begin
      Empl:= Cache.arEmplInfo[pID];
      if (fmpEmail in params) then s:= Empl.Mail
      else if (fmpName in params) then
        if (fmpShort in params) then s:= Empl.EmplShortName
        else s:= Empl.EmplLongName;
    end;
    if (s<>'') then begin
      Result:= Result+fnIfStr(Result='', '', ', ')+s;
      inc(j);
    end;
  end;
  if (j<1) then Exit;

  if (fmpPref in params) then begin
    s:= '';
    if (fmpFacc in params) then s:= '��� �/� '
    else if (fmpName in params) then begin
      if j>1 then s:= '��������� �/� '
      else if j>0 then s:= '�������� �/� ';
    end;
    if (s<>'') then Result:= s+' '+Result;
  end;
end;
//===================================================== �������� ��������� �����
function TFirmInfo.CheckFirmManager(emplID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (FirmManagers.IndexOf(emplID)>-1);
  if not Result then Exit;
  if not Cache.EmplExist(emplID) then Cache.TestEmpls(emplID);
  Result:= Cache.EmplExist(emplID) and not Cache.arEmplInfo[emplID].Arhived;
end;
//======================================================= �������� ������� �����
function TFirmInfo.CheckFirmRegion(regNum: Integer): Boolean;
var i, j: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  for i:= 0 to FirmContracts.Count-1 do begin
    j:= FirmContracts[i];
    if not Cache.Contracts.ItemExists(j) then Continue;
    j:= Cache.Contracts[j].FacCenter;
    if not Cache.FiscalCenters.ItemExists(j) then Continue;
    Result:= (TFiscalCenter(Cache.FiscalCenters[j]).Region=regNum);
    if Result then Exit;
  end;
end;
/////////////////////////////////////////////////////////////////////////////////////////////////////
//=================================================== �������� ��� def-���������
function TFirmInfo.GetDefContractID: Integer;
var i, k, kp: Integer;
begin
  Result:= 0;
  kp:= 0;
  if not Assigned(self) or not Assigned(FirmContracts) then Exit;
  with FirmContracts do begin
    if (Count<1) then Exit;
    if (Count=1) then begin
      Result:= Items[0];
      Exit;
    end;
    for i:= Count-1 downto 0 do begin // ���� � �����
      k:= Items[i];
      if not Cache.Contracts.ItemExists(k) then Continue;
      Result:= k;
      with Cache.Contracts[k] do begin
        if (Status=cstClosed) then Continue; // ����������� ����������
        if ContDefault then Exit; // ����� �� �������� - �������
        if (kp<1) and (PayType=0) then kp:= k; // ���������� ��� ���������� ��������� ���������
      end;
    end; // ���� �� �������� �� �����, � Result - ��� 1-�� ������������� ���������
    if (kp>0) and (kp<>Result) then Result:= kp; // ���� ����� �������� - ����� ���
  end;
end;
//======================================================== �������� def-��������
function TFirmInfo.GetDefContract: TContract;
var i, k: Integer;
    cc: TContract;
begin
  Result:= nil;
  if not Assigned(self) or not Assigned(FirmContracts) then Exit;
  with FirmContracts do begin
    if (Count<1) then Exit;
    for i:= 0 to Count-1 do begin
      k:= Items[i];
      if not Cache.Contracts.ItemExists(k) then Continue;
      cc:= Cache.Contracts[k];
      if (cc.Status=cstClosed) then Continue;
      Result:= cc;
      if Result.ContDefault then Exit; // ����� �� ��������
    end; // ���� �� �������� �� �����, � Result - ��������� ����������� ��������
  end;
end;
//====================================== �������� �������������� ��������� �����
function TFirmInfo.CheckContract(contID: Integer): boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (contID>0) and Cache.Contracts.ItemExists(contID) and (FirmContracts.IndexOf(contID)>-1);
end;
//============================================= �������� ������ ���������� �����
function TFirmInfo.GetContracts: TStringList;  // must Free !!!
var i, k: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  with FirmContracts do for i:= 0 to Count-1 do with Cache do begin
    k:= Items[i];
    if Contracts.ItemExists(k) then Result.AddObject(Contracts[k].Name, Pointer(k));
  end;
end;
//============================================== �������� �������� ����� �� ����
function TFirmInfo.GetContract(var contID: Integer): TContract;
// ���� �������� �� ������, ���������� def-�������� � ������ contID
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if CheckContract(contID) then Result:= Cache.Contracts[contID]
  else begin
    Result:= GetDefContract;
    if Assigned(Result) then contID:= Result.ID;
  end;
end;
//======================= ����� ����������� �������� ����� (���������� ��������)
function TFirmInfo.GetAvailableContract: TContract;
// ���� �������� �� ������, ���������� nil
var j, jj: Integer;
    Contract, Contract1: TContract;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Contract:= nil;
  Contract1:= nil;
  for j:= FirmContracts.Count-1 downto 0 do begin
    jj:= FirmContracts[j];
    if Cache.Contracts.ItemExists(jj) then begin
      Contract:= Cache.Contracts[jj];             // ���� ����������� ��������
      if (Contract.Status>cstClosed) then begin
        if (Contract.PayType=0) then break; // ����� ��������
        if not Assigned(Contract1) then Contract1:= Contract;  // ���������� ��������� �����������
      end;
      Contract:= nil;
    end;
  end;
  if Assigned(Contract) then Result:= Contract // �� ����� �������� - ����� ��������� �����������
  else if Assigned(Contract1) then Result:= Contract1;
end;
//===================================== ��������/��������� ��������� unit-������
procedure TFirmInfo.SetContUnitOrd(contID: Integer);
begin
  if not Assigned(self) then Exit;
  if (ContUnitOrd=contID) then Exit;
  if (contID>0) and not CheckContract(contID) then Exit;
  CS_firm.Enter;
  try
    ContUnitOrd:= contID;
  finally
    CS_firm.Leave;
  end;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
//=========================================== ��������� ������ ����������� �����
procedure TFirmInfo.TestFirmClients(codes: Tai; j: integer=0; inCS: boolean=True);
// codes- ������ ����� �����������, j- ���-��, ���� 0 - ����� ������� codes
// inCS=True - ��������� � CriticalSection
var i: integer;
begin
  if not Assigned(self) then Exit;
  if j=0 then j:= length(codes);
  try
    if inCS then CS_firm.Enter;
    if (j<>Length(FirmClients)) then SetLength(FirmClients, j);
    for i:= 0 to j-1 do if FirmClients[i]<>codes[i] then FirmClients[i]:= codes[i];
  finally
    if inCS then CS_firm.Leave;
  end; // if FirmExist(FirmID)
end;
//======================================================== �������� WIN-��������
function TFirmInfo.CheckFirmVINmail: boolean;
var i: Integer;
    ar: Tai;
    s1, s2, s3: String;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  s1:= Cache.GetConstItem(pcVINmailEmpl_list).StrValue;
  if (s1='') then Exit; // ������� ��� - �������

  s1:= Cache.GetConstItem(pcVINmailFirmTypes_list).StrValue;
  s2:= Cache.GetConstItem(pcVINmailFilial_list).StrValue;
  s3:= Cache.GetConstItem(pcVINmailFirmClass_list).StrValue;
  if (s1='') and (s2='') and (s3='') then Exit; // ���������� ��� - �������
  SetLength(ar, 0);
  try
    if (s1<>'') then begin // ���� ������ ����
      ar:= fnArrOfCodesFromString(s1);
      if (fnInIntArray(FirmType, ar)<0) then Exit; // ��� �� �������� - �������
    end;

    if (s2<>'') then begin // ���� ������ �������
      ar:= fnArrOfCodesFromString(s2);
      if (fnInIntArray(GetDefContract.Filial, ar)<0) then Exit; // ������ �� �������� - �������
    end;

    if (s3<>'') then begin // ���� ������ ���������
      ar:= fnArrOfCodesFromString(s3);
      for i:= 0 to FirmClasses.Count-1 do begin
        Result:= (fnInIntArray(FirmClasses[i], ar)>-1);
        if Result then Break; // ��������� �������� - �������
      end;
    end else Result:= True;

  finally
    SetLength(ar, 0);
  end;
end;
//======================================== �������� ���������� ���������� ������
function TFirmInfo.CheckFirmPriceLoadEnable: boolean;
var i: Integer;
    ar: Tai;
    s1: String;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  s1:= Cache.GetConstItem(pcPriceLoadFirmClasses).StrValue;
  if (s1='') then Exit; // ��������� ��� - �������

  SetLength(ar, 0);
  try
    ar:= fnArrOfCodesFromString(s1);
    for i:= 0 to FirmClasses.Count-1 do begin
      Result:= (fnInIntArray(FirmClasses[i], ar)>-1);
      if Result then Break; // ��������� �������� - �������
    end;
  finally
    SetLength(ar, 0);
  end;
end;
//========================= �������� ������ ������� �/�������� � ������� (�����)
function TFirmInfo.CheckShowZeroRests: boolean;
var ar: Tai;
    s1: String;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  s1:= Cache.GetConstItem(pcShowZeroRestsFirms).StrValue;
  if (s1='') then Exit; // ����� ��� - �������

  SetLength(ar, 0);
  try
    ar:= fnArrOfCodesFromString(s1);
    Result:= (fnInIntArray(ID, ar)>-1);
  finally
    SetLength(ar, 0);
  end;
end;
//========================================= �������� ���������� �������� �������
function TFirmInfo.CheckFirmOrderImportEnable: boolean;
var ii: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  ii:= Cache.GetConstItem(pcOrderImportFirmClass).IntValue;
  if (ii<1) then Exit; // ��������� ��� - �������

  Result:= (FirmClasses.IndexOf(ii)>-1);
end;
//================================ ������� ������ ������ � ������ �� �����������
function TFirmInfo.GetCurrentDiscModel(direct: Integer; var firmSales: Integer): TDiscModel;
var i, j: Integer;
begin
  Result:= Cache.DiscountModels.EmptyModel;
  firmSales:= 0;
  for i:= FirmDiscModels.Count-1 downto 0 do begin
    with TTwoCodes(FirmDiscModels[i]) do
    if (ID1=direct) then begin
      j:= ID2;              // ��� �������� �������
      Result:= Cache.DiscountModels[j];
      firmSales:= Round(Qty); // ������. ������� ������
      Exit;
    end;
  end;
end;
//================================================== �������� ����.����� �� ����
function TFirmInfo.GetFirmDestPoint(destID: integer): TDestPoint;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to FirmDestPoints.Count-1 do begin
    Result:= TDestPoint(FirmDestPoints[i]);
    if (Result.ID=destID) then break else Result:= nil;
  end;
end;
//================================================ �������� ����.������� �� ����
function TFirmInfo.GetFirmCredProfile(cpID: integer): TCredProfile;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to FirmCredProfiles.Count-1 do begin
    Result:= TCredProfile(FirmCredProfiles[i]);
    if (Result.ID=cpID) then break else Result:= nil;
  end;
end;
//=========================== �������� ����� ���������� ������ � �������� ������
function TFirmInfo.GetOverSummAll(currID: integer; var OverSumm: Double): String;
// ���� ����� �������� - ���������� ��������� � ����������
var curr: Double;
begin
  Result:= '';
  OverSumm:= 0;
  if not Assigned(self) or (ResLimit<0) then Exit;

  if (ResLimit=0) then begin
    Result:= '�������������� �������������';
    Exit;
  end;

  OverSumm:= AllOrderSum-ResLimit; // ���������� � �.�.
  if (CurrID<>cDefCurrency) then begin
    curr:= Cache.Currencies.GetCurrRate(CurrID);
    if fnNotZero(curr) then                // ���������� � �������� ������
      OverSumm:= OverSumm*Cache.Currencies.GetCurrRate(cDefCurrency)/curr;
  end;
  if (OverSumm>0.0099) then Result:= '����� ������� �������� �� '+
    FormatFloat(cFloatFormatSumm, OverSumm)+' '+Cache.GetCurrName(CurrID, True);
end;
//============================================ ��������� �������� ������ �������
procedure TFirmInfo.CheckReserveLimit;
const nmProc = 'CheckReserveLimit'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    sum, lim: Double;
begin
  try
    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, True);
      ibs.SQL.Text:= 'select FirmOrderLimit, (select sum(ResultValue)'+
        '  from Vlad_CSS_GetFirmReserveDocsN(FirmCode, 0) g'+
        '  left join ConvertMoney(g.rPInvSumm, g.rPInvCrnc, '+cStrDefCurrCode+', "Now") on 1=1'+
        '  where g.rPInvCrnc<>'+IntToStr(Cache.BonusCrncCode)+') Reserve '+
        ' from firms where firmcode='+IntToStr(ID);
      IBS.ExecQuery;
      if (ibs.Bof and ibs.Eof) then raise Exception.Create('Empty limit/reserve');

      if ibs.FieldByName('FirmOrderLimit').IsNull then lim:= -1
      else lim:= RoundTo(ibs.FieldByName('FirmOrderLimit').AsFloat, -2); // �����
      sum:= RoundTo(IBS.FieldByName('Reserve').AsFloat, -2);        // ������ � �.�.
      if fnNotZero(ResLimit-lim) or fnNotZero(AllOrderSum-sum) then try
        CS_firm.Enter;    // ��������� ��������
        ResLimit:= lim;
        AllOrderSum:= sum;
      finally
        CS_firm.Leave;
      end;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(IBD);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;

//******************************************************************************
//                                TWareOpts
//******************************************************************************
constructor TWareOpts.Create(CS: TCriticalSection);
var i: integer;
begin
  Fdivis:= 1.0;
  Fweight:= 0;
  FLitrCount:= 0;
  FModelLinks:= TLinkList.Create;  // ������ � ��������
  FFileLinks := TLinks.Create(CS); // ������ � �������
  FAttrLinks := TLinks.Create(CS); // ������ � ���������� � �� ����������
  FRestLinks := TLinks.Create(CS); // ������ �� �������� � ���������
  FSatelLinks:= TLinks.Create(CS); // ������ � �������������� ��������
  FGBAttLinks:= TLinks.Create(CS); // ������ � ���������� Grossbee � �� ����������
  FPrizAttLinks:= TLinks.Create(CS); // ������ � ���������� �������� � �� ����������
  SetLength(FPrices, Length(Cache.PriceTypes));
  for i:= 0 to High(FPrices) do FPrices[i]:= 0;
end;
//==================================================
destructor TWareOpts.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FModelLinks);
  prFree(FFileLinks);
  prFree(FAttrLinks);
  prFree(FRestLinks);
  prFree(FSatelLinks);
  prFree(FGBAttLinks);
  prFree(FPrizAttLinks);
  SetLength(FPrices, 0);
  inherited Destroy;
end;

//******************************************************************************
//                                TInfoWareOpts
//******************************************************************************
constructor TInfoWareOpts.Create(CS: TCriticalSection);
begin
  FWareSupName:= '';
  FCommentUP:= '';
  FNameBS:= '';
  FMainName:= '';
  FTypeID:= 0;
  FProdDirect:= 0;
  FManagerID:= 0;
  FmeasID:= 0;
  FActionID:= 0;
  FTopRating:= 0;
  FWareState:= 0;
  FAnalogLinks:= TLinks.Create(CS); // ������ � ���������
  FONumLinks  := TLinkList.Create;  // ������ � ������������� ��������
end;
//==================================================
destructor TInfoWareOpts.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FAnalogLinks); // ������ � ���������
  prFree(FONumLinks);   // ������ � ������������� ��������
  inherited Destroy;
end;

//******************************************************************************
//                               TWareInfo
//******************************************************************************
constructor TWareInfo.Create(pID, ParentID: Integer; pName: String);
begin
  inherited Create(pID, 0, 0, pName, 2);
  FParCode:= ParentID;
  FComment:= '';
  FWareBoolOpts:= [];
  FWareOpts:= nil;
  FInfoWareOpts:= nil;
  CS_wlinks:= TCriticalSection.Create; // ��� ��������� ������, ��������
  FDiscModLinks:= nil;    // ������ � ��������� ������
  FTypeOpts:= nil; //
end;
//==================================================
destructor TWareInfo.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FWareOpts);
  prFree(FInfoWareOpts);
  prFree(CS_wlinks);
  FWareBoolOpts:= [];
  prFree(FDiscModLinks);
  prFree(FTypeOpts);
  inherited Destroy;
end;
//======================================= ������� ������ (�������� ��� ��������)
procedure TWareInfo.ClearOpts;
var i, j, wareID: integer;
begin
  if not Assigned(self) then Exit;
  wareID:= ID;
  if Assigned(FWareOpts) then with FWareOpts do if Assigned(FModelLinks) then
    for i:= 0 to FModelLinks.Count-1 do try // ������ � ��������
      if assigned(FModelLinks[i]) then with TModelAuto(FModelLinks[i]) do
        if assigned(NodeLinks) then with NodeLinks do for j:= LinkCount-1 downto 0 do
          if DoubleLinkExists(ListLinks[j], wareID) then try
            GetDoubleLinks(ListLinks[j]).DelLinkListItemByID(wareID, lkLnkNone, CS_wlinks);
          except end;
    except end;

  if Assigned(FInfoWareOpts) then with FInfoWareOpts do try
    // �������  ???
    if Assigned(ONumLinks) then // ������ � ��
      for i:= 0 to ONumLinks.Count-1 do begin
        j:= GetLinkID(ONumLinks[i]);
        with Cache.FDCA do if OrigNumExist(j) then try
          arOriginalNumInfo[j].Links.DeleteLinkItem(wareID);
        except end;
      end;
  except end;
end;
//============================================================== �������� ������
function TWareInfo.GetWareLinks(const ik: T8InfoKinds): TLinks;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
   ik8_4: if IsWare then Result:= FAnalogLinks;
  end;
  if assigned(FWareOpts) then with FWareOpts do case ik of
   ik8_1: Result:= FFileLinks;
   ik8_2: Result:= FAttrLinks;
   ik8_3: Result:= FRestLinks;
   ik8_5: Result:= FSatelLinks;
   ik8_6: Result:= FGBAttLinks;
   ik8_7: Result:= FPrizAttLinks;
  end;
end;
//============================================================== �������� ������
function TWareInfo.GetWareLinkList(const ik: T8InfoKinds): TLinkList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  case ik of
   ik8_1: if assigned(FInfoWareOpts) then Result:= FInfoWareOpts.FONumLinks;
   ik8_2: if assigned(FWareOpts) then Result:= FWareOpts.FModelLinks;
   ik8_3: begin // ������ � ��������� ������
            if not assigned(FDiscModLinks) then FDiscModLinks:= TLinkList.Create;
            Result:= FDiscModLinks;
          end;
  end;
end;
//=================================================== ������� ������ ��� �������
function TWareInfo.IsMarketWare(FirmID: Integer=IsWe; contID: Integer=0): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(Cache) or IsINFOgr or IsArchive then Exit;

  Result:= fnNotZero(RetailPrice(FirmID, cDefCurrency, contID));
end;
//=================================================== ������� ������ ��� �������
function TWareInfo.IsMarketWare(ffp: TForFirmParams): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(Cache) or IsINFOgr or IsArchive then Exit;

  Result:= fnNotZero(RetailPrice(ffp.ForFirmID, cDefCurrency, ffp.contID));
end;
//==============================================================================
function CheckAnalogLinkKind(Kind: Integer; link: TAnalogLink): Boolean;
begin
  Result:= False;
  with link do case Kind of
    ca_GR,       ca_GR_OE      : Result:= IsOldAnalog or (IsCross and (SrcID=soGrossBee));      // ������ ������� + ������ GrossBee
//        ca_GR,       ca_GR_OE      : Result:= IsOldAnalog;  // ������ �������
    ca_Ex_TD,    ca_Ex_TD_OE   : Result:= IsCross;                                              // ��� ������
    ca_TD,       ca_TD_OE      : Result:= IsCross and (SrcID in [soTecDocBatch, soTDparts, soTDsupersed, soTDold]); // ������ TD
    ca_Ex,       ca_Ex_OE      : Result:= IsCross and (SrcID in [soHand, soGrossBee, soExcel]);             // ������ Excel
    ca_GR_TD,    ca_GR_TD_OE   : Result:= IsOldAnalog or (IsCross and (SrcID in [soTecDocBatch, soTDparts, soTDsupersed, soTDold])); // ������ + ������ TD
    ca_GR_Ex,    ca_GR_Ex_OE   : Result:= IsOldAnalog or (IsCross and (SrcID in [soHand, soGrossBee, soExcel])); // ������ + ������ Excel
    ca_GR_Ex_TD, ca_GR_Ex_TD_OE: Result:= IsOldAnalog or IsCross;                               // ���
  end; // case
end;
//========================== �������� ������ ����� �������� ������ � �����������
function TWareInfo.GetSrcAnalogs(ShowKind: Integer=-1): TObjectList;  // must Free
// Objects - TTwoCodes(wareID, link.SrcID)
var i: Integer;
    link: TAnalogLink;
begin
  Result:= nil;
  if not Assigned(self) then Exit;

  Result:= TObjectList.Create;
  if not Assigned(FInfoWareOpts) or not Assigned(FInfoWareOpts.FAnalogLinks) then Exit;

  if ShowKind<0 then ShowKind:= Cache.GetConstItem(pcAnalogsShowKind).IntValue;
  if (ShowKind=ca_OE) then Exit;                // ������ OE

  CS_wlinks.Enter;
  with FInfoWareOpts.FAnalogLinks do try
    i:= LinkCount;
    Result.Capacity:= i;
    for i:= 0 to LinkCount-1 do try
      link:= ListLinks[i];
      if CheckAnalogLinkKind(ShowKind, link) then
        Result.Add(TTwoCodes.Create(link.LinkID, link.SrcID));
    except end; // for
  finally
    CS_wlinks.Leave;
  end;
end;
//======================================== �������� ������ ����� �������� ������
function TWareInfo.Analogs: Tai;  // must Free
var i, j, ShowKind: Integer;
    link: TAnalogLink;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not Assigned(FInfoWareOpts)
    or not Assigned(FInfoWareOpts.FAnalogLinks) then Exit;

  ShowKind:= Cache.GetConstItem(pcAnalogsShowKind).IntValue;
  if (ShowKind=ca_OE) then Exit;                // ������ OE

  CS_wlinks.Enter;
  with FInfoWareOpts.FAnalogLinks do try
    SetLength(Result, LinkCount);
    j:= 0;    // ������� Result
    for i:= 0 to LinkCount-1 do try
      link:= ListLinks[i];
      if CheckAnalogLinkKind(ShowKind, link) then begin
        Result[j]:= link.LinkID;
        inc(j);
      end;
    except end; // for
    if (Length(Result)>j) then SetLength(Result, j);
  finally
    CS_wlinks.Leave;
  end;
end;
//======================== �������� � ��� ���� � �������� (def - ������ �������)
function TWareInfo.CheckAnalogLink(AnalogID: Integer;  pSrcID: Integer=soGrossBee; pCross: Boolean=True): Boolean;
var iCount: Integer;
    link: TAnalogLink;
    Ware: TWareInfo;
begin
  Result:= False;
  if not Assigned(self) or (AnalogID<1) or not assigned(FInfoWareOpts)
    or not Cache.WareExist(AnalogID) then exit;
  with FInfoWareOpts do begin
    Result:= FAnalogLinks.LinkExists(AnalogID);
    if not Result then begin
      Ware:= Cache.GetWare(AnalogID, True);
      if (Ware=NoWare) or Ware.IsArchive or Ware.IsINFOgr then Exit; // �� ����� � ������� ����-������
      iCount:= FAnalogLinks.LinkCount;
      link:= TAnalogLink.Create(pSrcID, Ware, not pCross, pCross);
      FAnalogLinks.AddLinkItem(link);
      Result:= FAnalogLinks.LinkCount>iCount;
    end else try
      CS_wlinks.Enter;
      link:= FAnalogLinks[AnalogID];
      if pCross and not link.IsCross then begin
        link.IsCross:= True;
        if {link.IsOldAnalog and} (link.SrcID<>pSrcID) then link.SrcID:= pSrcID; // �������� ������
      end;
      if not pCross and not link.IsOldAnalog then link.IsOldAnalog:= True;
      link.State:= True;
    finally
      CS_wlinks.Leave;
    end;
  end;
end;
//=============== ������� �� ���� ���� � ��������/������� (def - ������ �������)
procedure TWareInfo.DelAnalogLink(AnalogID: Integer;  pCross: Boolean=False);
var link: TAnalogLink;
begin
  if not Assigned(self) or (AnalogID<1) or not assigned(FInfoWareOpts) then exit;
  with FInfoWareOpts do begin
    if not FAnalogLinks.LinkExists(AnalogID) then exit;
    link:= FAnalogLinks[AnalogID];
    if pCross and link.IsCross then link.IsCross:= False;
    if not pCross and link.IsOldAnalog then link.IsOldAnalog:= False;
    if not link.IsOldAnalog and not link.IsCross then
      FAnalogLinks.DeleteLinkItem(AnalogID);
  end;
end;
//============================ �������� � ���� �������� ����� � ��������/�������
procedure TWareInfo.SetAnalogLinkSrc(AnalogID, src: Integer);
var link: TAnalogLink;
begin
  if not Assigned(self) or (AnalogID<1) or not assigned(FInfoWareOpts) then exit;
  with FInfoWareOpts do begin
    if not FAnalogLinks.LinkExists(AnalogID) then exit;
    link:= FAnalogLinks[AnalogID];
    if (link.SrcID<>src) then link.SrcID:= src;
  end;
end;
//===================== ������� �� ���� ������������� ����� � ���������/��������
procedure TWareInfo.DelNotTestedAnalogs(pCross: Boolean=False; pDel: Boolean=False);
var i: Integer;
    link: TAnalogLink;
begin
  if not Assigned(self) or not assigned(FInfoWareOpts) then exit;
  with FInfoWareOpts do for i:= FAnalogLinks.LinkCount-1 downto 0 do begin
    link:= FAnalogLinks.ListLinks[i];
    if link.State then Continue;
    if pCross and link.IsCross then link.IsCross:= False;
    if not pCross and link.IsOldAnalog then link.IsOldAnalog:= False;
    if not pDel then Continue;
    if not link.IsOldAnalog and not link.IsCross then
      FAnalogLinks.DeleteLinkItem(link);
  end;
end;
//========================================== ���������� �������� �� ������������
procedure TWareInfo.SortAnalogsByName;
begin
  if not Assigned(self) or not assigned(FInfoWareOpts) then exit;
  with FInfoWareOpts do FAnalogLinks.SortByLinkName;
end;
//==============================================================================
procedure TWareInfo.SetName(const Value: String);
var s: String;
begin
  if not Assigned(self) then exit;
  s:= AnsiUpperCase(fnChangeEndOfStrBySpace(Value));
  if (FName=s) then Exit;
  FName:= s;
  SetStrW(ik16_3, FName);
end;
//========================================== ���������� ��� � ����� ����� ������
function TWareInfo.GetActionParams(var ActTitle, ActText: String): Integer;
var wa: TWareAction;
begin
  Result:= 0;
  ActTitle:= '';
  ActText:= '';
  if not Assigned(self) or IsArchive then Exit;
  if Cache.WareActions.ItemExists(ActionID) then begin
    wa:= Cache.WareActions[ActionID];
    if wa.IsAction and (wa.EndDate>=Date) then begin
      Result:= wa.ID;
      ActTitle:= wa.Name;
//          ActText:= wa.Comment;
      ActText:= '';
    end;
  end;
end;
//======================================= ��� 1-�� ������� TD � ������ � tdfiles
function TWareInfo.GetFirstTDPictName: String;
var i: Integer;
    link: TFlagLink;
    wfItem: TWareFile;
    s: String;
begin
  Result:= '';
  if not Assigned(self) or IsArchive then Exit;
//  if (Cache.NoTDPictBrandCodes.IndexOf(WareBrandID)>-1) then Exit;
  if PictShowEx then Exit;
  if not Assigned(FileLinks) or (FileLinks.LinkCount<1) then Exit;

  for i:= 0 to FileLinks.ListLinks.Count-1 do begin
    link:= FileLinks.ListLinks[i];   // ���� �� ����
    if not link.Flag then Continue;  // ������� URL-������ �� ����

    wfItem:= link.LinkPtr;                              // ������ �����
    s:= AnsiUpperCase(ExtractFileExt(wfItem.FileName)); // ���������� �����
    if (s<>'.JPG') and (s<>'.BMP') and (s<>'.JPEG')
      and (s<>'.GIF') and (s<>'.PNG') and (s<>'.TIF') then Continue;

    s:= fnMakeAddCharStr(wfItem.supID, 4, '0'); // ��� ����� � tdfiles �� supID
    Result:= s+'/'+wfItem.FileName; // ��� ����� � tdfiles + ��� ����� � �����������
    Exit;
  end; // for i:= 0 to FileLinks.ListLinks.Count-1
end;
//================================================== ������ ����� ����� ��������
function TWareInfo.GetAnalogTypes(WithoutEmpty: Boolean=False): Tai; // must Free
var i, pType: Integer;
    analog: TWareInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) or IsArchive or not Assigned(AnalogLinks)
    or (AnalogLinks.LinkCount<1) then Exit;
  pType:= 0;
  for i:= 0 to AnalogLinks.LinkCount-1 do begin    // ���� �� ��������
    analog:= GetLinkPtr(AnalogLinks.ListLinks[i]);
    if not Assigned(analog) or (analog=NoWare) then Continue;
    with analog do begin
      if IsArchive or (PgrID<1) or IsINFOgr then Continue; // ���� ����������
      pType:= analog.TypeID;
    end;
    if WithoutEmpty and (pType<1) then Continue; // ���� ����� ������ ��������� ����
//    if (fnInIntArray(pType, Result)>-1) then Continue; // ��� ��� ���
    prAddItemToIntArray(pType, Result);
  end;
end;
//============================================================== �������� ������
procedure TWareInfo.SetStrW(const ik: T16InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik16_4: if (FComment<>Value) then FComment:= Value;
  end;
  if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
//    ik16_1: if (FSLASHCODE<>Value) then FSLASHCODE:= Value;
    ik16_2: begin
        Value:= AnsiUpperCase(Value);
        if (FWareSupName<>Value) then
          if (FName<>Value) then FWareSupName:= Value else FWareSupName:= '';
      end;
    ik16_3: begin
        Value:= fnDelSpcAndSumb(FName);
        if Value<>FName then FNameBS:= Value else FNameBS:= '';
      end;
    ik16_4: begin
       Value:= AnsiUpperCase(FComment);
       if (Value<>FComment) then FCommentUP:= Value else FCommentUP:= '';
      end;
    ik16_10: if (FArticleTD<>Value) then FArticleTD:= Value; // Article TecDoc
    ik16_15: if Value<>FName then FMainName:= Value else FMainName:= ''; // WAREMAINNAME
  end;
//  if assigned(FWareOpts) then with FWareOpts do case ik of
//  end;
end;
//============================================================== �������� ������
function TWareInfo.GetStrW(const ik: T16InfoKinds): String;
var i, j: Integer;
    kind: TCommentKind;
    s: String;
    arTypes: Tai;
    lst: TStringList;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik16_4 : Result:= FComment;
    ik16_9 : with Cache do Result:= arWareInfo[GetPgrID(ID)].Name; // ������������ ���������
    ik16_11: with Cache do Result:= arWareInfo[GetGrpID(ID)].Name; // ������������ ������
  end;

  if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
//        ik16_1:  Result:= FSLASHCODE;
    ik16_1: if (FWareState>0) and (FWareState<length(Cache.arWareStateNames)) then
              Result:= Cache.arWareStateNames[FWareState]
            else Result:= Cache.arWareStateNames[0];
    ik16_2:  Result:= fnIfStr(FWareSupName='', FName, FWareSupName);
    ik16_3:  Result:= fnIfStr(FNameBS='', FName, FNameBS);
    ik16_5:  Result:= fnIfStr(FCommentUP='', FComment, FCommentUP);
    ik16_8:  Result:= Cache.GetMeasName(measID);     // ������������ ��.���.
    ik16_10: Result:= FArticleTD;                    // Article TecDoc
    ik16_12: Result:= Cache.GetWareTypeName(TypeID); // ������������ ���� ������
    ik16_13: begin //------------------ ����������� ��� Web � ������ ���� ������
        kind:= ckEmpty;
        Result:= trim(FComment); // ������� �����, ��� ����
        //---------- ����-������: ���� FComment ������ ��� 'OE' - ��������� ����
        if IsINFOgr then begin
          i:= length(Result);
          if (i=2) then begin // ��������� �� 'OE'
            s:= AnsiUpperCase(Result);
            if (s='OE') or (s='��') or (s='O�') or (s='�E') then i:= 0;
          end;
          if (i<1) then
            if (FTypeID>0) then kind:= ckByType // ��� �����
            else if Assigned(AnalogLinks) and   // ���� �� ��������
              (AnalogLinks.LinkCount>0) then kind:= ckByTypes;
        end //---------- �����: ���� FComment ������ � ��� ����� - ��������� ���
        else if (Result='') and (FTypeID>0) then kind:= ckByType;

        if (kind=ckByType) then                               // ��� �����
          Result:= Result+fnIfStr(Result='', '', ', ')+Cache.GetWareTypeName(FTypeID)
        else if (kind=ckByTypes) then try // ���� �� ��������
          s:= ''; // �������� ������ �� �������� �����
          arTypes:= GetAnalogTypes(True); // ������ ����� ����� (��� ��������)
          for i:= 0 to High(arTypes) do
            s:= s+fnIfStr(s='', '', ' / ')+Cache.GetWareTypeName(arTypes[i]);
          if s<>'' then Result:= Result+fnIfStr(Result='', '', ', ')+s;
        finally
          SetLength(arTypes, 0);
        end;
      end; // ik16_13
    ik16_15:  Result:= fnIfStr(FMainName='', FName, FMainName); // WAREMAINNAME
    ik16_16: begin //------------------------- �������� ����������� �� ���������
        lst:= Cache.DiscountModels.ProdDirectList;
        for i:= 0 to lst.Count-1 do begin
          j:= Integer(lst.Objects[i]);
          if (j<>ProdDirect) then Continue;
          Result:= lst[i];
          Exit;
        end;
      end; // ik16_16
  end; // with FInfoWareOpts do case ik of

  if (ik in [ik16_6, ik16_7, ik16_14]) and Cache.WareBrands.ItemExists(WareBrandID) then
    with TBrandItem(Cache.WareBrands[WareBrandID]) do case ik of
      ik16_6 : Result:= NameWWW;   // ������������ ��� ����� �������� ������
      ik16_7 : Result:= Name;      // ������������ ������
      ik16_14: Result:= adressWWW; // ����� ������ �� ���� ������
    end;
end;
//======================================================== �������� ���.��������
function TWareInfo.GetDoubW(const ik: T8InfoKinds): Single;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if IsWare and Assigned(FWareOpts) then with FWareOpts do case ik of
   ik8_1: Result:= Fdivis;       // ���������
   ik8_2: Result:= Fweight;      // ���
   ik8_3: if Cache.TypeExists(TypeID) then Result:= Cache.arWareInfo[TypeID].CountLimit;
   ik8_4: if Cache.TypeExists(TypeID) then Result:= Cache.arWareInfo[TypeID].WeightLimit;
   ik8_5: Result:= FLitrCount;      // ������
  end else if IsWare and Assigned(FInfoWareOpts) then case ik of
   ik8_1: Result:= 1.0;          // ��������� ��� ����
  end else if IsType and Assigned(FTypeOpts) then with FTypeOpts do case ik of
   ik8_3: Result:= FCountLimit;  // ����� ����������
   ik8_4: Result:= FWeightLimit; // ����� ����
  end;
end;
//======================================================== �������� ���.��������
procedure TWareInfo.SetDoubW(const ik: T8InfoKinds; Value: Single);
begin
  if not Assigned(self) then Exit;
  if IsWare and Assigned(FWareOpts) then with FWareOpts do case ik of
   ik8_1: begin                        // ���������
            if not fnNotZero(Value) then Value:= 1.0;
            if fnNotZero(Fdivis-Value) then Fdivis:= RoundTo(Value, -3);
          end;
   ik8_2: if fnNotZero(Fweight-Value) then Fweight:= RoundTo(Value, -3); // ���
   ik8_5: if fnNotZero(FLitrCount-Value) then FLitrCount:= RoundTo(Value, -3); // ������
  end else if IsType and Assigned(FTypeOpts) then with FTypeOpts do case ik of
   ik8_3: if fnNotZero(FCountLimit-Value) then FCountLimit:= RoundTo(Value, -3);   // ����� ����������
   ik8_4: if fnNotZero(FWeightLimit-Value) then FWeightLimit:= RoundTo(Value, -3); // ����� ����
  end;
end;
//============================================================= �������� �������
function TWareInfo.GetBoolW(const Index: TKindBoolOptW): boolean;
var wa: TWareAction;
    br: TBrandItem;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  case Index of
    ikwFixT: if Assigned(FInfoWareOpts) then Result:= (FInfoWareOpts.FTypeID>0);
    ikwActN, ikwActM:
      if Cache.WareActions.ItemExists(ActionID) then begin
        wa:= Cache.WareActions[ActionID];
        Result:= (wa.BegDate<=Date) and (wa.EndDate>=Date);
        if Result then case Index of
          ikwActN: Result:= Result and wa.IsNews;     // ������� ����� "�������"
          ikwActM: Result:= Result and wa.IsCatchMom; // ������� ����� "���� ������"
        end;
      end;
    ikwNloa, ikwNpic:
      if Cache.WareBrands.ItemExists(WareBrandID) then begin
        br:= Cache.WareBrands[WareBrandID];
        case Index of
          ikwNloa: Result:= br.DownLoadExclude; // ������� "�� �������� � �����"
          ikwNpic: Result:= br.PictShowExclude; // ������� "�� ���������� ��������"
        end;
      end;
  else Result:= (Index in FWareBoolOpts);
  end;
end;
//============================================================= �������� �������
procedure TWareInfo.SetBoolW(const Index: TKindBoolOptW; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then begin
    FWareBoolOpts:= FWareBoolOpts+[Index];
    if not (Index in [ikwWare, ikwPgr, ikwGrp, ikwType]) then Exit;
    if IsGrp then begin
      FWareBoolOpts:= FWareBoolOpts-[ikwWare, ikwPgr, ikwType];
    end else if IsPgr then begin
      FWareBoolOpts:= FWareBoolOpts-[ikwWare, ikwGrp, ikwType];
    end else if IsWare then begin
      FWareBoolOpts:= FWareBoolOpts-[ikwPgr, ikwGrp, ikwType];
    end else if IsType then begin
      FWareBoolOpts:= FWareBoolOpts-[ikwPgr, ikwGrp, ikwWare];
    end;
  end else FWareBoolOpts:= FWareBoolOpts-[Index];
end;
//================================================================= �������� ���
function TWareInfo.GetIntW(const ik: T16InfoKinds): Integer;
var i, pType: Integer;
    analog: TWareInfo;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik16_1: if Cache.PgrExists(PgrID) then Result:= Cache.arWareInfo[PgrID].PgrID; // ��� ������
    ik16_5: Result:= FParCode;     // ��� ���������
    ik16_6: Result:= FOrderNum;    // ��� ������ ������
    else if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
      ik16_3: Result:= FManagerID;   // ��� ��������� (EMPLCODE)
      ik16_7: Result:= FmeasID;      // ��� ��.���.
      ik16_4: Result:= FSubCode;     // SupID TecDoc (DS_MF_ID !!!)
      ik16_8: if FTypeID>0 then Result:= FTypeID  // ��� ���� ������
             else if IsINFOgr and Assigned(AnalogLinks) then // � ���� ���������� �� ��������
               with AnalogLinks do if (LinkCount>0) then begin
                 analog:= GetLinkPtr(ListLinks[0]);
                 pType:= analog.TypeID; // ����� ��� �������
                 for i:= 1 to LinkCount-1 do begin
                   analog:= GetLinkPtr(ListLinks[i]);
                   if analog.IsINFOgr then Continue;
                   if (pType<>analog.TypeID) then Exit; // ���� ����� ������ ��� - �������
                 end;
                 Result:= pType;
               end; // with AnalogLinks ... if (LinkCount>0)
      ik16_9: Result:= FProdDirect; // ����������� �� ���������
      ik16_11: Result:= FActionID;  // ��� �����
      ik16_12: Result:= FTopRating; // ������� ��� ������
//      ik16_12: if (FActionID>0) and Cache.WareActions.ItemExists(FActionID) then
//                 if (TWareAction(Cache.WareActions[FActionID]).EndDate>=Date) then Result:= 1;
      ik16_14: Result:= FWareState;   // ������-���������
      ik16_15: Result:= FProduct;     // �������
      ik16_16: Result:= FProductLine; // ����������� �������
      else if assigned(FWareOpts) then with FWareOpts do case ik of
        ik16_2: if Assigned(AttrLinks) then with AttrLinks do try // ��� ������ ���������
                  if LinkCount>0 then Result:= GetDirItemSubCode(GetLinkPtr(ListLinks[0]));
                except end;
        ik16_10: if Assigned(GBAttLinks) then with GBAttLinks do try // ��� ������ ��������� Grossbee
                   if LinkCount>0 then Result:= TGBAttribute(GetLinkPtr(ListLinks[0])).Group;
                 except end;
        ik16_13: if Assigned(PrizAttLinks) then with PrizAttLinks do try // ��� ������ ��������� ��������
                   if LinkCount>0 then Result:= TGBAttribute(GetLinkPtr(ListLinks[0])).Group;
                 except end;
      end;
    end;
  end;
end;
//================================================================= �������� ���
procedure TWareInfo.SetIntW(const ik: T16InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik16_5:     if (FParCode    <>Value) then FParCode    := Value; // ��� ���������
    ik16_6:     if (FOrderNum   <>Value) then FOrderNum   := Value; // ��� ������ ������
    else if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
      ik16_3:   if (FManagerID  <>Value) then FManagerID  := Value; // ��� ��������� (EMPLCODE)
      ik16_7:   if (FmeasID     <>Value) then FmeasID     := Value; // ��� ��.���.
      ik16_4:   if (FSubCode    <>Value) then FSubCode    := Value; // SupID TecDoc (DS_MF_ID !!!)
      ik16_8:   if (FTypeID     <>Value) then FTypeID     := fnIfInt(Cache.TypeExists(Value), Value, 0); // ��� ���� ������
      ik16_9:   if (FProdDirect <>Value) then FProdDirect := Value; // ����������� �� ���������
      ik16_11:  if (FActionID   <>Value) then FActionID   := Value; // ��� �����
      ik16_12:  if (FTopRating  <>Value) then FTopRating  := Value; // ������� ��� ������
      ik16_14:  if (FWareState  <>Value) then FWareState  := Value; // ������
      ik16_15:  if (FProduct    <>Value) then FProduct    := Value; // �������
      ik16_16:  if (FProductLine<>Value) then FProductLine:= Value; // ����������� �������
//      else if assigned(FWareOpts) then with FWareOpts do case ik of
//      end;
    end;
  end;
end;
//============================================== ��������� ���� ������ �� ������
function TWareInfo.RetailTypePrice(pTypeInd: Integer; currcode: Integer=cDefCurrency): double;
var curr: Single;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) then Exit;
  with Cache do begin                      // �������� ���������� ������� ������
    if (pTypeInd<Low(PriceTypes)) or (pTypeInd>High(PriceTypes)) then pTypeInd:= Low(PriceTypes);
    if (pTypeInd<Low(FWareOpts.FPrices)) or (pTypeInd>High(FWareOpts.FPrices)) then Exit;
    if not CurrExists(currcode) then currcode:= cDefCurrency; // �������� ������
    Result:= FWareOpts.FPrices[pTypeInd];                        // ����.���� ������ � ����
//    if currcode<>cDefCurrency then Result:= Result*DefCurrRate; // ����.���� ������ � ���.
    if (currcode<>cDefCurrency) then begin
      curr:= Currencies.GetCurrRate(currcode);
      if fnNotZero(curr) then // ����.���� ������ � ������(�� ����)
        Result:= Result*Currencies.GetCurrRate(cDefCurrency)/curr;
    end;
  end;
//  Result:= RoundToHalfDown(Result);
end;
//========================= �������� / ��������� ��������� ���� ������ �� ������
procedure TWareInfo.CheckPrice(price: Single; pTypeInd: Integer);
begin
  if not Assigned(self) or not IsWare or not Assigned(FWareOpts) then Exit;
  with Cache do if (pTypeInd<Low(PriceTypes)) or (pTypeInd>High(PriceTypes)) then
    pTypeInd:= Low(PriceTypes);            // �������� ���������� ������� ������
  with FWareOpts do begin
    if (High(FPrices)<pTypeInd) then try
      CS_wlinks.Enter;
      SetLength(FPrices, Length(Cache.PriceTypes));
    finally
      CS_wlinks.Leave;
    end;
    if fnNotZero(FPrices[pTypeInd]-price) then FPrices[pTypeInd]:= price;
  end;
end;
//======================================== �������� ������ � ������ ������ �����
procedure TWareInfo.GetFirmDiscAndPriceIndex(FirmID: Integer; var ind: Integer;
                    var disc, disNext: double; contID: Integer=0);
var link: TQtyLink;
    Contract: TContract;
    firm: TFirmInfo;
    gr: TWareInfo;
    id1, id2, dm, i: Integer;
  //-------------------------------- ������ �� �������
  function _GetDiscByModel: double;
  begin
    link:= nil;
    Result:= 0;
    if Assigned(FDiscModLinks) and (FDiscModLinks.Count>0) then // ���� ������ ������
      link:= FDiscModLinks.GetLinkListItemByID(dm, lkLnkByID);
    if not Assigned(link) then begin                          // ���� ������ ���������
      gr:= Cache.arWareInfo[id1];
      if Assigned(gr.FDiscModLinks) and (gr.FDiscModLinks.Count>0) then
        link:= gr.FDiscModLinks.GetLinkListItemByID(dm, lkLnkByID);
    end;
    if not Assigned(link) and (id2>0) then begin              // ���� ������ ������
      gr:= Cache.arWareInfo[id2];
      if Assigned(gr.FDiscModLinks) and (gr.FDiscModLinks.Count>0) then
        link:= gr.FDiscModLinks.GetLinkListItemByID(dm, lkLnkByID);
    end;
    if not Assigned(link) then Exit;
    Result:= link.Qty;
  end;
  //--------------------------------
begin
  if Assigned(Cache) then ind:= Low(Cache.PriceTypes) else ind:= 0;
  disc:= 0;
  disNext:= 0;
  link:= nil;
  if not Assigned(self) or (FirmID=IsWe) or not Cache.FirmExist(FirmID) then Exit;
  firm:= Cache.arFirmInfo[FirmID];
  Contract:= firm.GetContract(contID);
  if IsWare then begin         // ������ ������� �� �����
    id1:= PgrID;
    id2:= GrpID;
  end else if IsPgr then begin // ������ ������� �� ���������
    id1:= ID;
    id2:= PgrID;
  end else if IsGrp then begin // ������ ������� �� ������
    id1:= ID;
    id2:= 0;
  end else Exit;

  i:= fnInIntArray(Contract.ContPriceType, Cache.PriceTypes);
  if (i>-1) then ind:= i;      // ������ ������
  if (ProdDirect<1) then Exit; // �� ������ ����������� ������

  dm:= firm.GetCurrentDiscModel(ProdDirect, i).ID;  // ��� �������� ������� ������
  if (dm<1) then Exit; // �� ������ ������� ������
  disc:= _GetDiscByModel;                           // ������ �� �������� �������

  dm:= Cache.DiscountModels.GetNextDirectModel(dm); // ��� ���������� �������
  if (dm<1) then disNext:= disc // �� ������ ��������� ������ - ����� �� ��������
  else disNext:= _GetDiscByModel;                   // ������ �� ���������� �������
end;
//============================================== ��������� ���� ������ ��� �����
function TWareInfo.RetailPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double;
var i: Integer;
    dis, disNext: double;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  GetFirmDiscAndPriceIndex(FirmID, i, dis, disNext, contID); // ������ ������
  Result:= RetailTypePrice(i, currcode);    // ����.���� ������
  Result:= RoundTo(Result, -2);
//  Result:= RoundToHalfDown(Result);
end;
//============================================== ��������� ���� ������ ��� �����
function TWareInfo.SellingPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double;
var i: Integer;
    dis, disNext: double;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  GetFirmDiscAndPriceIndex(FirmID, i, dis, disNext, contID); // ������ ������, ������ �����
  Result:= RetailTypePrice(i, currcode);    // ����.���� ������

  if not fnNotZero(Result) then Exit; // 0-� ����

  Result:= RoundTo(Result, -2);
//  Result:= RoundToHalfDown(Result);
  if IsSale or IsCutPrice or not fnNotZero(dis) then Exit; // ����������/������/��� ������

  Result:= Result*(1.0-dis/100.0); // ��������� ���� ������
  Result:= RoundTo(Result, -2);
//  Result:= RoundToHalfDown(Result);
//  if currcode=1 then Result:= RoundTo(Result/6, -2)*6; // �������� ��� ��� ���
end;
{//=========================== ���� ������ � �������� (% � ���������) ��� �������
function TWareInfo.MarginPrice(FirmID: Integer=IsWe; UserID: Integer=0;
         currcode: Integer=cDefCurrency; contID: Integer=0): double;
var marg: double;
    Client: TClientInfo;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  Result:= SellingPrice(FirmID, currcode, contID);
  Result:= RoundToHalfDown(Result);

  if not fnNotZero(Result) then Exit; // 0-� ����
  if (FirmID=IsWe) or not Cache.ClientExist(UserID) then Exit;

  Client:= Cache.arClientInfo[UserID];
  if not Client.CheckContract(contID) then Exit; // ����������� ��������

  marg:= Client.GetContCacheGrpMargin(contID, self.PgrID); // ���� ������� �� ���������
  if not fnNotZero(marg) then  // ���� ��� - ���� ������� �� ������
    marg:= Client.GetContCacheGrpMargin(contID, self.GrpID);
  if not fnNotZero(marg) then Exit;  // ������� ���

  Result:= Result*(1.0+marg/100.0); // ���� � �������� (% � ���������)
  Result:= RoundToHalfDown(Result);
end;
//=========================== ���� ������ � �������� (% � ���������) ��� �������
function TWareInfo.MarginPrice(ffp: TForFirmParams): double;
var marg: double;
    Client: TClientInfo;
begin
  Result:= 0;
  if not Assigned(self) or (ffp.currID<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  Result:= SellingPrice(ffp.ForFirmID, ffp.currID, ffp.contID);
  Result:= RoundToHalfDown(Result);

  if not fnNotZero(Result) then Exit; // 0-� ����
  if not ffp.ForClient or not Cache.ClientExist(ffp.UserID) then Exit;

  Client:= Cache.arClientInfo[ffp.UserID];
  if not Client.CheckContract(ffp.contID) then Exit; // ����������� ��������

  marg:= Client.GetContCacheGrpMargin(ffp.contID, self.PgrID); // ���� ������� �� ���������
  if not fnNotZero(marg) then  // ���� ��� - ���� ������� �� ������
    marg:= Client.GetContCacheGrpMargin(ffp.contID, self.GrpID);
  if not fnNotZero(marg) then Exit;  // ������� ���

  Result:= Result*(1.0+marg/100.0); // ���� � �������� (% � ���������)
  Result:= RoundToHalfDown(Result);
end;  }
//========================================== ��� ���� ������ �� �����, ���������
function TWareInfo.CalcFirmPrices(FirmID: Integer=IsWe; currID: Integer=cDefCurrency; // must Free !!!
                                 contID: Integer=0): TDoubleDynArray;
// 0- �������, 1- �� �������, 2- �� ����.�������
var i, len: Integer;
    dis, disNext: double;
begin
  len:= Length(arPriceColNames);
  SetLength(Result, len);
  for i:= 0 to High(Result) do Result[i]:= 0;
  if not Assigned(self) or (currID<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  GetFirmDiscAndPriceIndex(FirmID, i, dis, disNext, contID); // ������ ������, ������ �����
  Result[0]:= RoundTo(RetailTypePrice(i, currID), -2);   // ����.���� ������
//  Result[0]:= RoundToHalfDown(RetailTypePrice(i, currID));   // ����.���� ������

  if IsSale or IsCutPrice then begin // ����������/������
    Result[1]:= Result[0];
    Result[2]:= Result[0];
    Exit;
  end;

  if not fnNotZero(dis) then Result[1]:= Result[0]
  else Result[1]:= RoundTo(Result[0]*(1.0-dis/100.0), -2); // ��������� ���� ������
//  else Result[1]:= RoundToHalfDown(Result[0]*(1.0-dis/100.0)); // ��������� ���� ������
//  if currcode=cUAHCurrency then Result[1]:= RoundTo(Result[1]/6, -2)*6; // �������� ��� ��� ���

  if not fnNotZero(disNext) then Result[2]:= Result[0]
  else if not fnNotZero(dis-disNext) then Result[2]:= Result[1]
  else Result[2]:= RoundTo(Result[0]*(1.0-disNext/100.0), -2); // ���� �� ������� ����.������
//  else Result[2]:= RoundToHalfDown(Result[0]*(1.0-disNext/100.0)); // ���� �� ������� ����.������
end;
//========================================== ��� ���� ������ �� �����, ���������
function TWareInfo.CalcFirmPrices(ffp: TForFirmParams): TDoubleDynArray; // must Free !!!
// 0- �������, 1- �� �������, 2- �� ����.�������
var i, len: Integer;
    dis, disNext: double;
begin
  len:= Length(arPriceColNames);
  SetLength(Result, len);
  for i:= 0 to High(Result) do Result[i]:= 0;
  if not Assigned(self) or (ffp.currID<1) or not IsWare or not Assigned(FWareOpts) then Exit;

  GetFirmDiscAndPriceIndex(ffp.ForFirmID, i, dis, disNext, ffp.contID); // ������ ������, ������ �����
  Result[0]:= RoundTo(RetailTypePrice(i, ffp.currID), -2);   // ����.���� ������
//  Result[0]:= RoundToHalfDown(RetailTypePrice(i, ffp.currID));   // ����.���� ������

  if IsSale or IsCutPrice then begin // ����������/������
    Result[1]:= Result[0];
    Result[2]:= Result[0];
    Exit;
  end;

  if not fnNotZero(dis) then Result[1]:= Result[0]
  else Result[1]:= RoundTo(Result[0]*(1.0-dis/100.0), -2); // ��������� ���� ������
//  else Result[1]:= RoundToHalfDown(Result[0]*(1.0-dis/100.0)); // ��������� ���� ������
//  if currcode=1 then Result[1]:= RoundTo(Result[1]/6, -2)*6; // �������� ��� ��� ���

  if not fnNotZero(disNext) then Result[2]:= Result[0]
  else if not fnNotZero(dis-disNext) then Result[2]:= Result[1]
  else Result[2]:= RoundTo(Result[0]*(1.0-disNext/100.0), -2); // ���� �� ������� ����.������
//  else Result[2]:= RoundToHalfDown(Result[0]*(1.0-disNext/100.0)); // ���� �� ������� ����.������
end;
//=============================== ������ �������� ��������� ������ ��� ���������
function TWareInfo.GetWareAttrValuesView: TStringList; // must Free Result
// ���������� ������: ��� �������� = �������� ��������
const nmProc='GetWareAttrValuesView';
var i: integer;
    s1, s2: string;
    attlink: TTwoLink;
begin
  Result:= TStringList.Create;
  Result.Sorted:= False;
  attlink:= nil;
  if not Assigned(self) or not IsWare or not Assigned(AttrLinks) then Exit;
  with AttrLinks do try // ������ ���������
    if LinkCount<1 then Exit;
    Result.Capacity:= Result.Capacity+LinkCount;
    for i:= 0 to LinkCount-1 do begin
      s1:= GetLinkName(ListLinks[i]);
      if (s1='') then Continue else attlink:= ListLinks[i];
      if Assigned(attlink.LinkPtrTwo) then begin
        s2:= GetDirItemName(attlink.LinkPtrTwo); // �������� ��������
        Result.Add(s1+'='+s2);
      end;
    end; // for
  except end; // with AttrLinks
end;
//=================== ������ �������� ��������� ������ �� ����� � ������ �������
function TWareInfo.GetWareAttrValuesByCodes(AttCodes: Tai): TStringList; // must Free
const nmProc='GetWareAttrValuesByCodes';
var i, attcode: integer;
    s2: string;
    fl: Boolean;
    attlink: TTwoLink;
begin
  Result:= fnCreateStringList(False, Length(AttCodes));
  fl:= Assigned(self) and IsWare and Assigned(AttrLinks) and (AttrLinks.LinkCount>0);
  for i:= Low(AttCodes) to High(AttCodes) do begin
    s2:= '';
    attcode:= AttCodes[i];
    if fl and AttrLinks.LinkExists(attcode) then try // ���� ���� ���� �� ����� �������
      attlink:= AttrLinks[attcode];
      if Assigned(attlink.LinkPtrTwo) then
        s2:= GetDirItemName(attlink.LinkPtrTwo); // �������� ��������
    except end;
    Result.Add(s2);
  end;
end;
//====================== ������ �������� ��������� Grossbee ������ ��� ���������
function TWareInfo.GetWareGBAttValuesView: TStringList; // must Free Result
// ���������� ������: ��� �������� = �������� ��������
const nmProc='GetWareGBAttValuesView';
var i: integer;
    s1, s2: string;
    attlink: TTwoLink;
begin
  Result:= TStringList.Create;
  Result.Sorted:= False;
  attlink:= nil;
  if not Assigned(self) or not IsWare or not Assigned(GBAttLinks) then Exit;
  with GBAttLinks do try // ������ ���������
    if LinkCount<1 then Exit;
    Result.Capacity:= Result.Capacity+LinkCount;
    for i:= 0 to LinkCount-1 do begin
      s1:= GetLinkName(ListLinks[i]);
      if (s1='') then Continue else attlink:= ListLinks[i];
      if Assigned(attlink.LinkPtrTwo) then begin
        s2:= GetDirItemName(attlink.LinkPtrTwo); // �������� ��������
        Result.Add(s1+'='+s2);
      end;
    end; // for
  except end; // with AttrLinks
end;
//========== ������ �������� ��������� Grossbee ������ �� ����� � ������ �������
function TWareInfo.GetWareGBAttValuesByCodes(AttCodes: Tai): TStringList; // must Free
const nmProc='GetWareGBAttValuesByCodes';
var i, attcode: integer;
    s2: string;
    fl: Boolean;
    attlink: TTwoLink;
begin
  Result:= fnCreateStringList(False, Length(AttCodes));
  fl:= Assigned(self) and IsWare and Assigned(GBAttLinks) and (GBAttLinks.LinkCount>0);
  for i:= Low(AttCodes) to High(AttCodes) do begin
    s2:= '';
    attcode:= AttCodes[i];
    if fl and GBAttLinks.LinkExists(attcode) then try // ���� ���� ���� �� ����� �������
      attlink:= GBAttLinks[attcode];
      if Assigned(attlink.LinkPtrTwo) then
        s2:= GetDirItemName(attlink.LinkPtrTwo); // �������� ��������
    except end;
    Result.Add(s2);
  end;
end;
//================================ �������� �������������� � ������� ���� / ����
function TWareInfo.CheckWareTypeSys(TypeSysID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then exit;

  Result:= IsPrize or (TypeSysID=0);
  if Result then Exit;

  case TypeSysID of
    constIsAuto: Result:= IsAUTOWare;
    constIsMoto: Result:= IsMOTOWare;
  end;
end;
//=== ������ ����.������� ������, ������������� �� �������������� � ������������
procedure TWareInfo.SortOrigNumsWithSrc(var arCodes, arSrc: Tai);
var i, onID, src: Integer;
    TwoCodes: TTwoCodes;
begin
  SetLength(arCodes, 0);
  SetLength(arSrc, 0);
  if not Assigned(self) or not Assigned(Cache) then Exit;
  with TStringList.Create do try
    Capacity:= Capacity+ONumLinks.Count;
    for i:= 0 to ONumLinks.Count-1 do begin
      onID:= GetLinkID(ONumLinks[i]);
      src:= GetLinkSrc(ONumLinks[i]);
      if Cache.FDCA.OrigNumExist(onID) then
        AddObject(Cache.FDCA.GetOriginalNum(onID).SortString, TTwoCodes.Create(onID, src));
    end; // for i:= 0 to ONumLinks.Count-1
    if Count>1 then Sort;
    SetLength(arCodes, Count);
    SetLength(arSrc, Count);
    for i:= 0 to Count-1 do begin
      TwoCodes:= TTwoCodes(Objects[i]);
      arCodes[i]:= TwoCodes.ID1;
      arSrc[i]:= TwoCodes.ID2;
      prFree(TwoCodes);
    end;
  finally Free; end;
end;
//======================== ����� ������������� ������ � ������ ��.������� ������
function TWareInfo.FindOriginalNum(ONumID, mfauID: Integer; OrigNum: String): Boolean;
var  i, j, mfID: Integer;
   s: String;
   fMF, fON, fID: Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(Cache) then Exit;
  mfID:= 0;
  s:= '';
  OrigNum:= AnsiUpperCase(fnDelSpcAndSumb(OrigNum));
  fON:= OrigNum<>'';
  fMF:= mfauID>0;
  fID:= ONumID>0;
  if not (fON or fMF or fID) then Exit;
  for i:= 0 to ONumLinks.Count-1 do begin
    j:= GetLinkID(ONumLinks[i]);
    if not Cache.FDCA.OrigNumExist(j) then Continue;
    with Cache.FDCA.arOriginalNumInfo[j] do begin
      if fMF then mfID:= MfAutoID;
      if fON then s:= OriginalNum;
    end;
    Result:= (fID and (j=ONumID)) or (fON and (s=OrigNum) and (not fMF or (mfID=mfauID)));
    if Result then Exit;
  end; // for
end;
//======== ���������� TList ������� - ������. + �.�. + ������.� + ������������
function WareModelsSortCompare(Item1, Item2: Pointer): Integer;
var i1, i2: Integer;
    Model1, Model2: TModelAuto;
begin
  with Cache.FDCA do try
    Model1:= Item1;
    Model2:= Item2;
    if Model1.ModelMfauID<>Model2.ModelMfauID then
      Result:= AnsiCompareText(Model1.ModelMfauName, Model2.ModelMfauName)
    else if Model1.ModelLineID<>Model2.ModelLineID then
      Result:= AnsiCompareText(Model1.ModelLineName, Model2.ModelLineName)
    else begin
      i1:= Model1.ModelOrderNum;
      i2:= Model2.ModelOrderNum;
      if i1=i2 then Result:= AnsiCompareText(Model1.SortName, Model2.SortName)
      else if i1<i2 then Result:= -1 else Result:= 1;
    end;
  except
    Result:= 0;
  end;
end;
//==== �����.������ ������� �� ������ - ������. + �.�. + ������.� + ������������
function TWareInfo.GetSysModels(pSys: Integer; pMfau: Integer=0; flPL: Boolean=False): TList; // Object - TModelAuto, must Free
const nmProc = 'GetSysModels';
// pMfau=0 - ��� ������ ������ �� �������, pMfau>0 - ������ ��������� �������������
var i: Integer;
    model: TModelAuto;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    s: String;
    pl: TProductLine;
begin
  pl:= nil;
  Result:= TList.Create;
  if not Assigned(self) or not IsWare or
    not Assigned(FWareOpts) or not CheckTypeSys(pSys) then Exit;

if flPL then begin
  pl:= Cache.ProductLines.GetProductLine(ProductLine);
  flPL:= Assigned(pl);
  if flPL then case pSys of
    constIsAuto: flPL:= pl.HasModelAuto;
    constIsMoto: flPL:= pl.HasModelMoto;
    constIsCV  : flPL:= pl.HasModelCV;
    constIsAx  : flPL:= pl.HasModelAx;
  end;
end;

//---------------------------------------------------------------------- �� ����
  if Cache.WareLinksUnLocked and not flPL then begin
    if not ModelsSorting and (ModelLinks.Count>1) then begin
      ModelLinks.Sort(WareModelsSortCompare); // ��������� ����� ��� ������ ������
      ModelsSorting:= True;        // ���� - ��� ������������
    end;
    for i:= 0 to ModelLinks.Count-1 do try
      model:= ModelLinks[i];
      if not model.IsVisible or (model.TypeSys<>pSys) then Continue;
      if (pMfau>0) and (model.ModelMfauID<>pMfau) then Continue;
      Result.Add(model);
    except end;
    Exit;
  end;

  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try try  //--------------------------------------------------------------- �� ����
    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);

if flPL then
    s:= 'select LDEMDMOSCODE DMOSCODE from (select LDEMDMOSCODE from (select LDEMDMOSCODE'+
    '  from (select LDMWLDEMCODE from LINKDETMODWARE'+
    '    where LDMWWARECODE='+IntToStr(ID)+' and LDMWWRONG="F")'+
    '  inner join LINKDETAILMODEL on LDEMCODE=LDMWLDEMCODE and LDEMWRONG="F"'+
    ' union select LMNMODMOS LDEMDMOSCODE from (select LMNPMLMNM'+
    '  from LINKMODNODEPL_MOTUL where LMNPMPRLI='+IntToStr(pl.ID)+')'+
    '  inner join LINKMODELNODE_MOTUL on LMNMOCODE=LMNPMLMNM) group by LDEMDMOSCODE)'
else
    s:= 'select LDEMDMOSCODE DMOSCODE from'+
      ' (select LDEMDMOSCODE from (select LDMWLDEMCODE from LINKDETMODWARE'+
      '   where LDMWWARECODE='+IntToStr(ID)+' and LDMWWRONG="F")'+
      '   inner join LINKDETAILMODEL on LDEMCODE=LDMWLDEMCODE and LDEMWRONG="F"'+
      '   group by LDEMDMOSCODE)';

    s:= s+' inner join DIRMODELS on DMOSCODE=LDEMDMOSCODE and dmosisvisible="T"'+
      ' inner join DIRMODELLINES on DRMLCODE=DMOSDRMLCODE and DRMLISVISIBLE="T"'+
      '  and drmldtsycode='+IntToStr(pSys);
    if (pMfau>0) then s:= s+' where drmlmfaucode='+IntToStr(pMfau)+
                            ' order by drmlname, DRMLCODE, dmosname'
    else s:= s+' inner join manufacturerauto on mfaucode=drmlmfaucode'+
               ' order by mfauname, mfaucode, drmlname, DRMLCODE, dmosname';
    ORD_IBS.SQL.Text:= s;
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      i:= ORD_IBS.FieldByName('DMOSCODE').AsInteger;  // ��� ������
      if Cache.FDCA.Models.ModelExists(i) then Result.Add(Cache.FDCA.Models[i]);
      cntsORD.TestSuspendException;
      ORD_IBS.Next;
    end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ORD_IBS);
    cntsOrd.SetFreeCnt(ORD_IBD);
    if (Result.Count>1) then Result.Sort(WareModelsSortCompare); // ���������
  end;
end;
//============================== ������� ������� �����.������� ������� �� ������
function TWareInfo.SysModelsExists(pSys: Integer): Boolean;
var pl: TProductLine;
    flPL: Boolean;
begin
  Result:= False;
  if not Assigned(self) or not IsWare or not Assigned(FWareOpts) or not CheckTypeSys(pSys) then Exit;

  case pSys of
    constIsAuto: Result:= HasModelAuto;
    constIsMoto: Result:= HasModelMoto;
    constIsCV  : Result:= HasModelCV;
    constIsAx  : Result:= HasModelAx;
  end;
  if Result then Exit;

  flPL:= (ProductLine>0);
  if flPL then pl:= Cache.ProductLines.GetProductLine(ProductLine) else pl:= nil;
  flPL:= Assigned(pl);
  if not flPL then Exit;
  case pSys of
    constIsAuto: Result:= pl.HasModelAuto;
    constIsMoto: Result:= pl.HasModelMoto;
    constIsCV  : Result:= pl.HasModelCV;
    constIsAx  : Result:= pl.HasModelAx;
  end;
end;
//==================== �������� �������� ������� �����.������� ������� �� ������
function TWareInfo.CheckHasModels(pSys: Integer): Boolean;
var i: Integer;
    model: TModelAuto;
    fl: Boolean;
begin
  Result:= False;
  if not Assigned(self) or not IsWare or not Assigned(FWareOpts) or not CheckTypeSys(pSys) then Exit;
  fl:= False;
  with ModelLinks do for i:= 0 to Count-1 do try
    model:= Items[i];
    fl:= model.IsVisible and (model.TypeSys=pSys);
    if fl then break;
  except end;
  case pSys of
    constIsAuto: HasModelAuto:= fl;
    constIsMoto: HasModelMoto:= fl;
    constIsCV  : HasModelCV  := fl;
    constIsAx  : HasModelAx  := fl;
  end;
end;
//=================== ���������� TLinks ������� � ����������� ������� �� �������
function ProdLineWaresSortCompare(Item1, Item2: Pointer): Integer;
var l1, l2: Single;
    ware1, ware2: TWareInfo;
begin
  Result:= 0;
  try
    ware1:= TLink(Item1).LinkPtr;
    ware2:= TLink(Item2).LinkPtr;
    l1:= ware1.LitrCount;
    l2:= ware2.LitrCount;
    if (l1<l2) then Result:= -1 else if (l1>l2) then Result:= 1;
  except
    Result:= 0;
  end;
end;
//=========================================== ��������� ��������� ������ �� ����
procedure TWareInfo.SetWareParams(pPgrID: Integer; ibs: TIBSQL;
          fromGW: Boolean=False; spk: TSetWareParamKind=spAll);
// TSetWareParamKind = (spAll, spWithoutPrice, spOnlyPrice)
var flWareOpts, flInfo: boolean;
    k: Integer;
    n: String;
    pl: TProductLine;
begin
  if (spk in [spAll, spWithoutPrice]) then begin
    IsWare:= True;
    IsPrize:= GetBoolGB(ibs, 'WAREBONUS');
    flInfo:= (ibs.FieldByName('wState').AsInteger=cWStateInfo);

    if not fromGW then begin // ����� �� TestWares
      IsArchive:= False;
      PgrID:= pPgrID;

if flShowWareByState then begin
      IsINFOgr:= flInfo;
end else begin
      IsINFOgr:= Cache.arWareInfo[pPgrID].IsINFOgr;
end; // flShowWareByState

      IsSale:= not IsINFOgr and GetBoolGB(ibs, 'sale');
      flWareOpts:= not IsINFOgr; // WareOpts ��������� ������ � ������ �������

    end else begin // ����� �� GetWare
      IsArchive:= GetBoolGB(ibs, 'warearchive');
      flWareOpts:= not IsArchive and (IsPrize or ((pPgrID>0) and Cache.PgrExists(pPgrID)));
      if flWareOpts then begin // WareOpts ��������� ������ � ���������� �������
        PgrID:= pPgrID;
        IsSale:= GetBoolGB(ibs, 'sale');   // ???
//        IsINFOgr:= (ibs.FieldByName('wState').AsInteger=cInfoWareState);  // �������� ???
      end;
    end;

    if not assigned(FInfoWareOpts) then
      FInfoWareOpts:= TInfoWareOpts.Create(CS_wlinks);

    Name       := ibs.FieldByName('WAREOFFICIALNAME').AsString;
    MainName   := ibs.FieldByName('WAREMAINNAME').AsString;
    Comment    := ibs.FieldByName('WARECOMMENT').AsString;
    WareSupName:= ibs.FieldByName('WARESUPPLIERNAME').AsString;
    measID     := ibs.FieldByName('WAREMEAS').AsInteger;
    WareBrandID:= ibs.FieldByName('WAREBRANDCODE').AsInteger;
    ManagerID  := ibs.FieldByName('REmplCode').AsInteger; // ��� ���������
    TypeID     := ibs.FieldByName('wType').AsInteger;
    IsTop      := (ibs.FieldByName('wTOP').AsInteger=1);
    IsCutPrice := not IsINFOgr and (ibs.FieldByName('wCutPrice').AsInteger=1);
    IsNonReturn:= False;  //  IsNonReturn:= IsSale or IsCutPrice;

    WareState  := ibs.FieldByName('wState').AsInteger;
    Product    := ibs.FieldByName('product').AsInteger;
    ProductLine:= ibs.FieldByName('ProdLine').AsInteger;

    k:= ibs.FieldByName('WrPrProductDirection').AsInteger;
    if not IsPrize and (PgrID<>Cache.pgrDeliv)
      and not Cache.DiscountModels.DirectExists(k) then begin
//      IsArchive:= True;
      ProdDirect:= 0;
      PgrID:= 0;
      IsAUTOWare:= False;
      IsMOTOWare:= False;
    end else begin // ������ ����������� AUTO, MOTO, MOTUL... � �����
      ProdDirect:= k;
      if IsPrize or (PgrID=Cache.pgrDeliv) or (k=cpdCodeMotul) then begin
        IsAUTOWare:= True;
        IsMOTOWare:= True;
      end else begin
        IsMOTOWare:= (k=cpdCodeMoto);
        IsAUTOWare:= (k<>cpdCodeMoto);
      end;
    end;
    if not flWareOpts then Exit;
    if not assigned(FWareOpts) then FWareOpts:= TWareOpts.Create(CS_wlinks);
  //  SLASHCODE:= ibs.FieldByName('WARESLASHCODE').AsString;
    divis:= ibs.FieldByName('WAREDIVISIBLE').AsFloat;
    weight:= ibs.FieldByName('wareweight').AsFloat;
    LitrCount:= RoundTo(ibs.FieldByName('WareLitrCount').AsFloat, -3);

{if (weight>0) and (ID>150000) and (ID<155000) then
  prMessageLOGS('SetWareParams: ('+IntToStr(ID)+') '+Name+' - weight='+
    FormatFloat('# ##0.000', weight), fLogDebug, false); // ����� � log  }

    if not IsArchive and not IsINFOgr and (ProductLine>0) then begin
      pl:= Cache.ProductLines.GetProductLine(ProductLine);
      if Assigned(pl) then begin // ��������� ���� �� ����� � ����������� �������
        if pl.WareLinks.LinkExists(ID) then try
          pl.WareLinks.CS_links.Enter;
          TLink(pl.WareLinks[ID]).State:= True
        finally
          pl.WareLinks.CS_links.Leave;
        end else begin
          pl.WareLinks.AddLinkItem(TLink.Create(soHand, self));
          pl.WareLinks.LinkSort(ProdLineWaresSortCompare);
        end;
      end;
    end;

  end; // if (spk in [spAll, spWithoutPrice])

  if (spk in [spAll, spOnlyPrice]) then begin

    if (spk=spOnlyPrice) then begin // ������������, ���� ������ ����
      if not assigned(FInfoWareOpts) then
        FInfoWareOpts:= TInfoWareOpts.Create(CS_wlinks);
      if not fromGW then flWareOpts:= not IsINFOgr  // ����� �� TestWares
      else  // ����� �� GetWare
        flWareOpts:= not IsArchive and (IsPrize or ((pPgrID>0) and Cache.PgrExists(pPgrID)));
      if not flWareOpts then Exit;
      if not assigned(FWareOpts) then FWareOpts:= TWareOpts.Create(CS_wlinks);
    end; // if (spk=spOnlyPrice)

    for k:= 0 to High(Cache.PriceTypes) do begin // ���� �� �������
      if k=0 then n:= '' else n:= IntToStr(k);
      if (ibs.FieldIndex['priceEUR'+n]>-1) then    // ������������
        CheckPrice(ibs.FieldByName('priceEUR'+n).AsFloat, k);
    end;
  end; //  if (spk in [spAll, spOnlyPrice])
end;
//=============================== ������ �������� ��������� ������ ��� ���������
function TWareInfo.GetWareCriValuesView(SysID: Integer=0): TStringList; // must Free Result
const nmProc = 'GetWareCriValuesView';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    iCri, iNode, i: integer;
    s, ss, CriName: String;
    flSysOnly: Boolean;
begin
  Result:= TStringList.Create;
  if not Assigned(self) or not IsWare then Exit;
  ORD_IBS:= nil;
  ORD_IBD:= nil;
  try try
   ORD_IBD:= cntsOrd.GetFreeCnt;
   ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    //----------------------------------------------------- �������� ���������
    ORD_IBS.SQL.Text:= 'select WCRICODE, WCRIDESCR, WCVSVALUE'+
      ' from (select LWCVWCVSCODE from LINKWARECRIVALUES'+
      ' where LWCVWARECODE='+IntToStr(ID)+' and LWCVWRONG="F")'+
      ' left join WARECRIVALUES on WCVSCODE=LWCVWCVSCODE'+
      ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE'+
      ' order by WCRIORDNUM nulls last, WCRICODE, WCVSVALUE';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      iCri:= ORD_IBS.FieldByName('WCRICODE').AsInteger;
      CriName:= ORD_IBS.FieldByName('WCRIDESCR').AsString;
      s:= '';
      while not ORD_IBS.Eof and (iCri=ORD_IBS.FieldByName('WCRICODE').AsInteger) do begin
        ss:= ORD_IBS.FieldByName('WCVSVALUE').AsString;
        if ss<>'' then s:= s+fnIfStr(s='', '', ', ')+ss;
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
      Result.Add(CriName+fnIfStr(s='', '', ': '+s)); // ������ �� 1-�� ��������
    end;
    ORD_IBS.Close;
    //------------------------------------------- ������ � ������ ����� - ����
    flSysOnly:= CheckTypeSys(SysID); // ������� ������ ������� ������ �� �������� �������
    ORD_IBS.SQL.Text:= 'select LWNTnodeID, LWNTinfotype, DITMNAME, TRNANAME,'+
      ' iif(ITATEXT is null, ITTEXT, ITATEXT) text'+
      fnIfStr(flSysOnly, '', ', TRNADTSYCODE')+
      ' from (select LWNTnodeID, LWNTinfotype, LWNTWIT'+
      '  from LinkWareNodeText where LWNTwareID='+IntToStr(ID)+' and LWNTWRONG="F")'+
      ' left join DIRINFOTYPEMODEL on DITMCODE=LWNTinfotype'+
      ' left join TREENODESAUTO on TRNACODE=LWNTnodeID'+
      ' left join WareInfoTexts on WITCODE=LWNTWIT'+
      ' left join INFOTEXTS on ITCODE=WITTEXTCODE'+
      ' left join INFOTEXTSaltern on ITACODE=ITALTERN'+
      fnIfStr(flSysOnly, ' where TRNADTSYCODE='+IntToStr(SysID), '')+
      ' order by'+fnIfStr(flSysOnly, '', ' TRNADTSYCODE,')+' LWNTnodeID, LWNTinfotype, text';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      iNode:= ORD_IBS.FieldByName('LWNTnodeID').AsInteger;
      s:= '���� - '+ORD_IBS.FieldByName('TRNANAME').AsString+':';
      s:= brcWebColorBlueBegin+s+brcWebColorEnd; // ����� �����
      Result.Add(s);
      while not ORD_IBS.Eof and (iNode=ORD_IBS.FieldByName('LWNTnodeID').AsInteger) do begin
        iCri:= ORD_IBS.FieldByName('LWNTinfotype').AsInteger;
        CriName:= ORD_IBS.FieldByName('DITMNAME').AsString;
        s:= '';
        while not ORD_IBS.Eof and (iNode=ORD_IBS.FieldByName('LWNTnodeID').AsInteger)
          and (iCri=ORD_IBS.FieldByName('LWNTinfotype').AsInteger) do begin
          ss:= ORD_IBS.FieldByName('text').AsString;
          if ss<>'' then s:= s+fnIfStr(s='', '', ', ')+ss;
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
        end; // while ... and (iNode= ... and (iCri=
        Result.Add(cWebSpace+cWebSpace+CriName+fnIfStr(s='', '', ': '+s)); // ������ + ������ �� 1-�� ���� ������
      end; // while ... and (iNode=
    end;
    ORD_IBS.Close;

    //------------------------------------------ ������ EAN � ��������� ��������
    ORD_IBS.SQL.Text:= 'select ean, 0 PackUnit, 0 PackCount'+
      ' from (select list(g.rEAN) ean from LinkWareEAN'+
      '  left join WareEANnumbers on weanCODE=lweanEAN'+
      '  left join getformatean(weanNumber) g on 1=1'+
      '  where lweanWare='+IntToStr(ID)+' and lweanWRONG="F")'+
      ' union select "" ean, woPackUnit PackUnit, woPackCount PackCount'+
      ' from WAREOPTIONS where WOWARECODE='+IntToStr(ID);
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      s:= ORD_IBS.FieldByName('ean').AsString;
      if (s<>'') then Result.Add('����� EAN: '+s);
      i:= ORD_IBS.FieldByName('PackUnit').AsInteger;
      if (i>0) then Result.Add('����������� �������: '+IntToStr(i));
      i:= ORD_IBS.FieldByName('PackCount').AsInteger;
      if (i>1) then Result.Add('���������� � ��������: '+IntToStr(i));
      TestCssStopException;
      ORD_IBS.Next;
    end;

  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  finally
    prFreeIBSQL(ORD_IBS);
    cntsOrd.SetFreeCnt(ORD_IBD);
  end;
end;
//=================================== ���������� / ����� ����� � �������� TecDoc
function TWareInfo.CheckArticleLink(pArticle: String; pSupID: Integer;
         var ResCode: Integer; userID: Integer=0; flDelInfo: Boolean=True): String;
const nmProc = 'CheckArticleLink';
// ��� �������� - ResCode - �� ����� (resAdded, resDeleted, resWrong, resNotWrong)
// (flDelInfo=True) + (ResCode in [resDeleted, resWrong]) - ������� ��� ���-���, ���������� �� TecDoc
// ResCode �� ������: resError- ������, resDoNothing - �� ��������,
// resAdded - ������ ���������, resDeleted - ������ �������,
// resWrong - �������� ��������� ������ � ���� � ������� �� ����
// resNotWrong - ����� ������� ��������� ������ � ���� � ������ ��������� � ���
type RWareIndo = record
    kind, rCode, rCode1, rCode2: Integer;
  end;
var IBDord, IBDtdt: TIBDatabase;
    IBSord, IBStdt: TIBSQL;
    ari: array of RWareIndo;
    j, i, k, OpCode, wCount: Integer;
    Model: TModelAuto;
    Eng: TEngine;
    link: TLink;
    link2: TSecondLink;
    flEx: Boolean;
    sArtLink: String;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  if not Assigned(self) or not IsWare or not Assigned(FInfoWareOpts) then Exit;
  pArticle:= Trim(pArticle);
  wCount:= 0;
  IBSord:= nil;
  IBStdt:= nil;
  j:= 0;
  SetLength(ari, 0);
  try
//-------------------------------------------------------------------- ���������
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if (pArticle='') or (pSupID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');

    sArtLink:= MessText(mtkWareArticleLink);
    if (OpCode in [resAdded, resNotWrong]) then begin
      if not IsInfoGr and
        (fnInIntArray(pSupID, TBrandItem(Cache.WareBrands[WareBrandID]).TDMFcodes)<0) then
        raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
      if (pArticle=ArticleTD) and (pSupID=ArtSupTD) then begin
        ResCode:= resDoNothing;
        raise EBOBError.Create('����� '+sArtLink+' ��� ����');
      end;
      if (ArticleTD<>'') and (ArtSupTD>0) then
        raise EBOBError.Create('����� ������ � ������ ���������');
      if (userID<1) then raise EBOBError.Create(MessText(mtkNotParams));

    end else if (pArticle<>ArticleTD) or (pSupID<>ArtSupTD) then begin
      ResCode:= resDoNothing;
      raise EBOBError.Create('�� ������� ����� '+sArtLink);
    end;
//--------------------------------------------------- ������������ ������ � ����
    IBDtdt:= cntsTDT.GetFreeCnt;
    try
      IBDord:= cntsOrd.GetFreeCnt;

      IBStdt:= fnCreateNewIBSQL(IBDtdt, 'IBS_'+nmProc, -1, tpWrite, True);
      try
        IBSord:= fnCreateNewIBSQL(IBDord, 'IBS_'+nmProc, -1, tpWrite, True);

        if (OpCode in [resWrong, resDeleted]) then begin
          if flDelInfo then           // ������� ���� ������ �� ���������-TecDoc
            IBSord.SQL.Text:= 'select * from DelWareInfoByTDsrc('+IntToStr(ID)+')'
          else // �������� �������� ����-������ � ���������-TecDoc �� TecDoc-������
            IBSord.SQL.Text:= 'select * from ChangeWareInfoSrcFromTDtoTDold('+IntToStr(ID)+')';
      // ���������� ���� ��� ��������� ����, kind - ��� ������������ �����:
      // 1 - rCode - ��� ������� ��������� ������;
      // 2 - rCode - ��� ������, � �������� �������� ����� - ������;
      // 3 - rCode - ��� ������������� ������ ������;
      // 4 - rCode - ��� ����� ������;
      // 5 - rCode - ��� ����, rCode1 - ��� ������, (flDelInfo) rCode2 - ������� ������� ��������;
      // (flDelInfo) 6 - rCode - ������� ������� �����, rCode1 - ��� ���������, rCode2 - ������� ������� �������
          IBSord.ExecQuery;
          while not IBSord.Eof do begin  // ���������� ������������ ����
            if High(ari)<j then SetLength(ari, j+10);
            with ari[j] do begin
              kind  := IBSord.FieldByName('kind').AsInteger;
              rCode := IBSord.FieldByName('rCode').AsInteger;
              rCode1:= IBSord.FieldByName('rCode1').AsInteger;
              rCode2:= IBSord.FieldByName('rCode2').AsInteger;
            end;
            inc(j);
            TestCssStopException;
            IBSord.Next;
          end;
          IBSord.Close;
        end; // if (OpCode in [resWrong, resDeleted])

        if (OpCode in [resAdded, resNotWrong]) then begin //-- ��������� ������� �������� � TDT
          IBStdt.SQL.Text:= 'select art_id from articles left join data_suppliers'+
            ' on ds_id=art_sup_id where art_nr=:art and ds_mf_id='+IntToStr(pSupID);
          IBStdt.ParamByName('art').AsString:= pArticle;
          IBStdt.ExecQuery;
          if (IBStdt.Bof and IBStdt.Eof) or (IBStdt.Fields[0].AsInteger<1) then
            raise EBOBError.Create('�� ������ ������� Tecdoc '+pArticle);
          IBStdt.Close;
        end; // if (OpCode in [resAdded, resNotWrong])

        IBSord.SQL.Text:= 'execute procedure CheckWareArticleTDLink('+IntToStr(OpCode)+', '+
          IntToStr(ID)+', '+IntToStr(pSupID)+', :art, '+IntToStr(userID)+')';
        IBSord.ParamByName('art').AsString:= pArticle;
        IBSord.ExecQuery;
        IBSord.Transaction.Commit;
        IBSord.Close;
        try             // ������������ ������� ������� ������� � �������� � TDT
          with IBSord.Transaction do if not InTransaction then StartTransaction;
          IBSord.SQL.Text:= 'select count(WATDWARECODE) from WAREARTICLETD'+
            ' where WATDWRONG="F" and WATDARTSUP='+IntToStr(pSupID)+' and WATDARTICLE=:art';
          IBSord.ParamByName('art').AsString:= pArticle;
          IBSord.ExecQuery;
          if not (IBSord.Bof and IBSord.Eof) then wCount:= IBSord.Fields[0].AsInteger;
          IBSord.Close;

          IBStdt.SQL.Text:= 'SELECT rResult from CheckArtWarecode(:Art, '+IntToStr(pSupID)+', '+IntToStr(wCount)+')';
          IBStdt.ParamByName('art').AsString:= pArticle;
          IBStdt.ExecQuery;
          if (IBStdt.Bof and IBStdt.Eof) or IBStdt.fieldByName('rResult').IsNull then wCount:= -1
          else wCount:= IBStdt.fieldByName('rResult').AsInteger;
          if not (wCount in [0, 1]) then raise Exception.Create(' result='+IntToStr(wCount));
          with IBStdt.Transaction do if InTransaction then Commit;
        except
          on E:Exception do prMessageLOGS(nmProc+': error TDT->CheckArtWarecode, '+E.Message, 'import', False);
        end;
      finally
        prFreeIBSQL(IBSord);
        cntsOrd.SetFreeCnt(IBDord);
      end;
    finally
      prFreeIBSQL(IBStdt);
      cntsTDT.SetFreeCnt(IBDtdt);
    end;
//------------------------------------------------------------- ������������ ���
    try
      CS_wlinks.Enter;
      if OpCode in [resAdded, resNotWrong] then begin // ��������� / ���������������
        ArticleTD:= pArticle;
        ArtSupTD:= pSupID;  // SupID TecDoc (DS_MF_ID !!!)
      end else begin // ������� / ��������, ��� ���������
        ArticleTD:= '';
        ArtSupTD:= 0;
      end;
    finally
      CS_wlinks.Leave;
    end;

    if (j>0) then begin
      i:= 0;
      while (i<j) do begin
        if flDelInfo then begin
//-------------------------- ������� ���� ������ �� ���������-TecDoc (���� ����)
          with ari[i] do case kind of
          1: DelAnalogLink(rCode, True);    //------------------- ������� ������
          2: if Cache.WareExist(rCode) then //----------------- ������ � �������
              Cache.GetWare(rCode).DelAnalogLink(ID, True);
          3: begin //------------------------------------------------- �� ������
              ONumLinks.DelLinkListItemByID(rCode, lkLnkByID, CS_wlinks); // ����.������ � ������
              with Cache.FDCA do if OrigNumExist(rCode) then // ����.������ � ��
                GetOriginalNum(rCode).Links.DeleteLinkItem(ID);
            end;
          4: FileLinks.DeleteLinkItem(rCode); //------------------- ����� ������
          5: begin //------------------------------------------- 3 ������ ������
              Model:= Cache.FDCA.Models[rCode1];
              if Assigned(Model) and Model.NodeLinks.LinkExists(rCode) then begin
                link2:= Model.NodeLinks[rCode];
                link2.DoubleLinks.DelLinkListItemByID(ID, lkLnkNone, Model.CS_mlinks);
                                       // �������� ������� �������� � 2-� ������
                if link2.NodeHasFilters and (rCode2<1) then link2.NodeHasFilters:= False;
                if link2.NodeHasWares and (link2.DoubleLinks.LinkCount<1) then link2.NodeHasWares:= False;
              end;
            end;
          6: begin //------------------------------- ������ ������ � �����������
              Eng:= Cache.FDCA.Engines[rCode1];
              if Assigned(Eng) then begin // �������� ������� ����� � ������� � ���������
                if Eng.EngHasNodes and (rCode<1) then Eng.EngHasNodes:= False;
                if Eng.EngHasWares and (rCode2<1) then Eng.EngHasNodes:= False;
              end;
            end;
          // �������� ������, ����-������ �����-���� ��������� ��� �������� �����
          end; // case

        end else begin
//--------------------------------------------------- �������� �������� �� TDold
          with ari[i] do case kind of
          1: SetAnalogLinkSrc(rCode, soTDold); //---------------- ������� ������
          2: if Cache.WareExist(rCode) then    //-------------- ������ � �������
               Cache.GetWare(rCode).SetAnalogLinkSrc(ID, soTDold);
          3: begin //------------------------------------------------- �� ������
               if ONumLinks.LinkListItemExists(rCode, lkLnkByID) then begin
                 link:= ONumLinks.GetLinkListItemByID(rCode, lkLnkByID);
                 link.SrcID:= soTDold; // ������ � ������
               end;
               with Cache.FDCA do if OrigNumExist(rCode) then // ������ � ��
                 with GetOriginalNum(rCode) do if Links.LinkExists(ID) then begin
                   link:= Links[ID];
                   link.SrcID:= soTDold;
                 end;
            end;
          4: if FileLinks.LinkExists(rCode) then begin //---------- ����� ������
               link:= FileLinks[rCode];
               link.SrcID:= soTDold;
            end;
          5: begin //------------------------------------------- 3 ������ ������
              Model:= Cache.FDCA.Models[rCode1];
              if Assigned(Model) and Model.NodeLinks.LinkExists(rCode) then begin
                link2:= Model.NodeLinks[rCode];
                with link2.DoubleLinks do if LinkListItemExists(ID, lkLnkNone) then begin
                  link:= GetLinkListItemByID(ID, lkLnkNone);
                  link.SrcID:= soTDold;
                end;
              end;
            end;
          end; // case
        end;
//------------------------------------------------------------------------------
        inc(i);
      end; // while

      i:= 0;
      if flDelInfo then while (i<j) do begin
        with ari[i] do case kind of
        5: begin //------------------------------------ ������ ������ � ��������
            Model:= Cache.FDCA.Models[rCode1];
            if Assigned(Model) then begin
              flEx:= False; // ���������, �������� �� ����� �� ����� � ������
              with Model.NodeLinks do for k:= 0 to LinkCount-1 do begin
                with TSecondLink(ListLinks[k]) do
                  flEx:= Assigned(DoubleLinks) and DoubleLinks.LinkListItemExists(ID, lkLnkNone);
                if flEx then break;
              end;
              if not flEx then // ���� �� �������� - ������� ���� ������ � �������
                ModelLinks.DelLinkListItemByID(Model.ID, lkDirNone, CS_wlinks);
            end;
          end; // 5
        end; // case
        inc(i);
      end; // while
    end; // if (j>0)

    case OpCode of
      resAdded:    Result:= sArtLink+' ���������';
      resDeleted:  Result:= sArtLink+' �������';
      resWrong:    Result:= sArtLink+' ��������, ��� ��������';
      resNotWrong: Result:= sArtLink+' �������������';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
  SetLength(ari, 0);
end;
//====================================== ����� ���������� ������ �������� ������
function TWareInfo.GetWareFiles: TarWareFileOpts; // array of records
var i: Integer;
    link: TFlagLink;
    wfItem: TWareFile;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not IsWare or not Assigned(FWareOpts) then Exit;
  with FileLinks do begin
    SetLength(Result, LinkCount);
    for i:= 0 to ListLinks.Count-1 do begin
      link:= ListLinks[i];                  // ���� �� ����
      wfItem:= link.LinkPtr;                // ������ �����
      Result[i].SupID   := wfItem.supID;    // ��� SupID (��� ������ �����)
      Result[i].FileName:= wfItem.FileName; // ��� ����� � �����������
      Result[i].HeadName:= wfItem.HeadName; // ��������� �����
      Result[i].LinkURL := link.Flag;       // ������� URL-������ �� ����
    end;
  end;
end;
//========================================== �������� ������ ����� �����.�������
function TWareInfo.GetSatellites: Tai;  // must Free
var i, j: Integer;
    ware: TWareInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not Assigned(SatelLinks) then Exit;

  with SatelLinks do for i:= 0 to ListLinks.Count-1 do begin
    j:= GetLinkID(ListLinks[i]);
    if not Cache.WareExist(j) then Continue;
    ware:= GetLinkPtr(ListLinks[i]); // ��������� �����.�����
    if not Assigned(ware) then Continue;
    try
      if ware.IsINFOgr or ware.IsArchive then Continue;     // ��������� ����-������
    except
      Continue;
    end;
    prAddItemToIntArray(ware.ID, Result);
  end;
end;
//================================================ ������� ������� �����.�������
function TWareInfo.SatelliteExists: Boolean;
var i: Integer;
    ware: TWareInfo;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(SatelLinks) then Exit;

  with SatelLinks do for i:= 0 to ListLinks.Count-1 do begin
    ware:= TLink(ListLinks[i]).LinkPtr;               // ��������� �����.�����
    if ware.IsINFOgr or ware.IsArchive then Continue; // ��������� ����-������
    Result:= True; // ����� 1-�
    break;
  end;
end;
{//===================================================== ������� ������� ��������
function TWareInfo.RestExists(pContID: Integer=0): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(RestLinks) or (RestLinks.LinkCount<1) then Exit;
end; }

//******************************************************************************
//                               TWareFile
//******************************************************************************
//================================================== �������� �������� ���������
function TWareFile.GetWFHeadName: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  Result:= Cache.FDCA.TypesInfoModel.InfoItems[headID].Name;
end;

//******************************************************************************
//                               TShipMethodItem
//******************************************************************************
constructor TShipMethodItem.Create(pID: Integer; pName: String; pTimeKey: Boolean=False; pLabelKey: Boolean=False);
begin
  inherited Create(pID, pName);
  TimeKey:= pTimeKey;
  LabelKey:= pLabelKey;
end;

//******************************************************************************
//                                TShipTimeItem
//******************************************************************************
constructor TShipTimeItem.Create(pID: Integer; pName: String; pHour: Byte=0; pMinute: Byte=0);
begin
  inherited Create(pID, pName);
  FHour:= pHour;
  FMinute:= pMinute;
end;

//******************************************************************************
//                               TDataCache
//******************************************************************************
constructor TDataCache.Create;
begin
  inherited;
  flMailSendSys:= False; // �� ���������
  flCheckClosingDocs:= False;
  SingleThreadExists:= False;
  WareCacheTested:= True;
  LongProcessFlag:= cdlpNotLongPr;
  CliLoginLength:= 20;
  CliPasswLength:= 20;
  CliSessionLength:= 30;
  OrdWarrNumLength:= 20;
  OrdWarrPersLength:= 100;
  OrdSelfCommLength:= 30;
  OrdCommentLength:= 255;
  AccEmpCommLength:= 255;      // ����� ���� ����� ����������� ����������
  AccCliCommLength:= 255;      // ����� ���� ����� ����������� �������
  AccWebCommLength:= 255;      // ����� ���� ����� ����������� Web
  CScache := TCriticalSection.Create; // ��� ���������
  CS_Empls:= TCriticalSection.Create; // ��� ��������� ���������� �����������
  CS_wares:= TCriticalSection.Create; // ��� ��������� ���������� �������

  SysTypes:= TDirItems.Create;
  FillSysTypes; // �������������� ������� �����
  if not Assigned(SysTypes) or (SysTypes.Count<1) then
    raise Exception.Create('�� ���� ���������� ������� �����');

  SetLength(arFirmTypesNames, 1);
  arFirmTypesNames[0]:= '�����.';

  SetLength(arFirmClassNames, 1);
  arFirmClassNames[0]:= '�����.';

  SetLength(arWareStateNames, 1);
  arWareStateNames[0]:= '�����.';

  SetLength(arDprtInfo, 1);
  arDprtInfo[0]:= TDprtInfo.Create(0, 0, 0, '�����.�������������');

  arClientInfo:= TClients.Create;

  Contracts:= TContracts.Create;       // ���������� ����������

  SetLength(arFirmInfo, 1);
  arFirmInfo[0]:= TFirmInfo.Create(0, '�����.�����');

  SetLength(arEmplInfo, 1);
  arEmplInfo[0]:= TEmplInfoItem.Create(0, 0, 1, '');
  arEmplInfo[0].Surname:= '�� ���������';

  setLength(arFictiveEmpl, 0);
  setLength(arRegionROPFacc, 0);  // ���� ��� ���-� �� ������ �������

  FDCA:= TDataCacheAdditionASON.Create; // Galeta

  SetLength(arWareInfo, 1);
  arWareInfo[0]:= TWareInfo.Create(0, 0, '�����.������');  // ��������� ��� ������ �������
  with arWareInfo[0] do begin
    IsPgr:= True;
//    IsAUTOWare:= True; // �������� AUTO / MOTO ���������
//    IsMOTOWare:= True;
  end; // with arWareInfo[0]

  NoWare:= TWareInfo.Create(-1, 0, '�����.�����'); // ��������� �����
  NoWare.IsWare:= True;

  SetLength(PriceTypes, 0);
  DefCurrRate:= 0;
  CreditPercent:= 90;
  BankLimitSumm:= 0;
  BankMinSumm:= 10;
  flCheckCliBankLim:= False;
//  flNewComplMode:= False;
  LastTimeCache:= DateNull;
//  LastTimeMemUsed:= DateNull;
  LastTestRestTime:= DateNull;
//  LastTimeCacheAlter:= DateNull;

  BonusCrncCode:= 22;     // ��� ������ �������
  TopActCode:= 0;

  BrandTDList   := nil;                    // ������ ������� TecDoc
  FWareFiles    := TDirItems.Create;       // ���������� ������ ��������/����������
  WareBrands    := TDirItems.Create;       // ���������� �������
  FImportTypes  := TDirItems.Create;       // ���������� ����� �������
  FParConstants := TDirItems.Create;       // ���������� ��������
  FEmplRoles    := TDirItems.Create;       // ���������� �����
  FMeasNames    := TDirItems.Create;       // ���������� ��.���.
  InfoNews      := TDirItems.Create;       // ����-����
  ShipMethods   := TDirItems.Create;       // ���������� ������� ��������
  ShipTimes     := TDirItems.Create;       // ���������� ������ ��������
  FiscalCenters := TDirItems.Create;       // ���������� FISCALACCOUNTINGCENTER
  WareActions   := TDirItems.Create;       // ���������� ����� �� �������

  Currencies    := TCurrencies.Create;     // ���������� �����
  Notifications := TNotifications.Create;  // ���������� �����������
  AttrGroups    := TAttrGroupItems.Create; // ���������� ����� ���������
  Attributes    := TAttributeItems.Create; // ���������� ���������
  GBAttributes  := TGBAttributes.Create;   // ���������� ��������� Grossbee
  GBPrizeAttrs  := TGBAttributes.Create;   // ���������� ��������� ��������
  ProductLines  := TProductLines.Create;   // �������� ����������� ������ (Motul)
  DiscountModels:= TDiscModels.Create;     // ���������� �������� ������
  MotulTreeNodes:= TMotulTreeNodes.Create; // ������ ����� Motul

  DeliveriesList  := fnCreateStringList(true, dupIgnore); // ������ ��������
  BrandLaximoList := fnCreateStringList(true, dupIgnore); // ������ ������� Laximo
  SMSmodelsList   := TStringList.Create;   // ������ SMS-��������
  MobilePhoneSigns:= TStringList.Create;   // ������ ����� ���.����������
  WareProductList := TStringList.Create;   // ������ ���������

//  NoTDPictBrandCodes:= TIntegerList.Create; // ���� ������� ��� ������ �������� TD
  ShowZeroRestsFirms:= TIntegerList.Create; // ���� �/� ��� ������ ������� �/�������� � ������� (�����)

//  FirmLabels    := TDirItems.Create;       // ���������� �������
//  MarginGroups  := TMarginGroups.Create;   // ������/��������� �������

  WareCacheUnLocked:= False;
  WareLinksUnLocked:= False;
  WebAutoLinks:= False;
  WareCacheTested:= False;
end;
//==================================================
destructor TDataCache.Destroy;
const nmProc = 'Cache_Destroy'; // ��� ���������/�������
var i: Integer;
    LocalStart: TDateTime;
begin
  if not Assigned(self) then Exit;
  LocalStart:= now();
  prFree(arClientInfo);
  if flTest then begin
    prMessageLOGS(nmProc+'_Clients: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  TestCacheArrayLength(taCurr, 0, false);
  TestCacheArrayLength(taDprt, 0, false);
  TestCacheArrayLength(taFirm, 0, false);
  prFree(Contracts);
  if flTest then begin
    prMessageLOGS(nmProc+'_Firms: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  TestCacheArrayLength(taWare, 0, false);
  if flTest then begin
    prMessageLOGS(nmProc+'_Wares: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  TestCacheArrayLength(taEmpl, 0, false);
  if flTest then begin
    prMessageLOGS(nmProc+'_Empls: - '+GetLogTimeStr(LocalStart), fLogDebug, false);
    LocalStart:= now();
  end;
  TestCacheArrayLength(taFtyp, 0, false);
  TestCacheArrayLength(taFcls, 0, false);
  setLength(arFictiveEmpl, 0);
  SetLength(PriceTypes, 0);
  setLength(arRegionROPFacc, 0);  // ���� ��� ���-� �� ������ �������
  prFree(NoWare);
  FDCA.Free;
  FDCA:= nil;

  prFree(AttrGroups);
  prFree(Attributes);
  prFree(GBAttributes); // ���������� ��������� Grossbee
  if flTest then prMessageLOGS(nmProc+'_Attributes: - '+
                            GetLogTimeStr(LocalStart), fLogDebug, false);
  prFree(WareBrands);
  prFree(FImportTypes);
  prFree(FParConstants);      // ���������� ��������
  prFree(FEmplRoles);
  prFree(FMeasNames);
  prFree(FWareFiles);
  prFree(BrandTDList);
  prFree(InfoNews);
  prFree(Notifications);
  prFree(SysTypes);
  prFree(ShipMethods);
  prFree(ShipTimes);
  prFree(FiscalCenters);   // ���������� FISCALACCOUNTINGCENTER
  prFree(Currencies);      // ���������� �����
  prFree(ShipTimes);
//  prFree(FirmLabels);
  prFree(WareActions);        // ���������� ����� �� �������
//  prFree(MarginGroups);
  prFree(DeliveriesList);
  for i:= 0 to BrandLaximoList.Count-1 do TObject(BrandLaximoList.Objects[i]).Free;
  prFree(BrandLaximoList); // ������ ������� Laximo
//  prFree(NoTDPictBrandCodes);
  prFree(ShowZeroRestsFirms);
  prFree(DiscountModels);
  prFree(SMSmodelsList);
  prFree(MobilePhoneSigns);  // ������ ����� ���.����������
  prFree(ProductLines);
  prFree(WareProductList);
  prFree(MotulTreeNodes);

  prFree(CScache);
  prFree(CS_Empls);
  prFree(CS_wares);
  inherited;
end;
//============================================================= �������� �������
function TDataCache.GetBoolDC(ik: T16InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FCacheBoolOpts);
end;
//============================================================= �������� �������
procedure TDataCache.SetBoolDC(ik: T16InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FCacheBoolOpts:= FCacheBoolOpts+[ik]
  else FCacheBoolOpts:= FCacheBoolOpts-[ik];
end;
//================================================= ��������� ����� ������� ����
procedure TDataCache.TestCacheArrayLength(kind: TArrayKind; len: integer; ChangeOnlyLess: boolean=True);
var fl: boolean;
    i, j: integer;
begin
  if not Assigned(self) then Exit else case kind of
    taWare: i:= Length(arWareInfo);
    taEmpl: i:= Length(arEmplInfo);
    taFirm: i:= Length(arFirmInfo);
    taDprt: i:= Length(arDprtInfo);
    taFtyp: i:= Length(arFirmTypesNames);
    taFcls: i:= Length(arFirmClassNames);
    taWaSt: i:= Length(arWareStateNames);
    else Exit;
  end;
  if ChangeOnlyLess then fl:= (i<len) else fl:= (i<>len);
  if fl then try // ���� ���� ������ �����
    CScache.Enter;
    if (i>len) then case kind of // ���� �������� - ���� �������� ��������
      taWare: for j:= len to High(arWareInfo) do try prFree(arWareInfo[j]); except end;
      taEmpl: for j:= len to High(arEmplInfo) do try prFree(arEmplInfo[j]); except end;
      taFirm: for j:= len to High(arFirmInfo) do try prFree(arFirmInfo[j]); except end;
      taDprt: for j:= len to High(arDprtInfo) do try prFree(arDprtInfo[j]); except end;
    end;
    case kind of
      taWare: SetLength(arWareInfo, len);
      taEmpl: SetLength(arEmplInfo, len);
      taFirm: SetLength(arFirmInfo, len);
      taDprt: SetLength(arDprtInfo, len);
      taFtyp: SetLength(arFirmTypesNames, len);
      taFcls: SetLength(arFirmClassNames, len);
      taWaSt: SetLength(arWareStateNames, len);
    end;
    if (i<len) then case kind of // ���� ��������� - ���� ������������ ��������
      taWare: for j:= i to High(arWareInfo) do arWareInfo[j]:= nil;
      taEmpl: for j:= i to High(arEmplInfo) do arEmplInfo[j]:= nil;
      taFirm: for j:= i to High(arFirmInfo) do arFirmInfo[j]:= nil;
      taDprt: for j:= i to High(arDprtInfo) do arDprtInfo[j]:= nil;
      taFtyp: for j:= i to High(arFirmTypesNames) do arFirmTypesNames[j]:= '';
      taFcls: for j:= i to High(arFirmClassNames) do arFirmClassNames[j]:= '';
      taWaSt: for j:= i to High(arWareStateNames) do arWareStateNames[j]:= '';
    end;
  finally
    CScache.Leave;
  end;
end;
//================================ ��������� ������������� �������� ������� ����
function TDataCache.TestCacheArrayItemExist(kind: TArrayKind; pID: integer; var flnew: boolean): boolean;
var fl: boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  fl:= false;
  TestCacheArrayLength(kind, pID+1);
  case kind of
    taWare: fl:= not Assigned(arWareInfo[pID]);
    taEmpl: fl:= not Assigned(arEmplInfo[pID]);
    taFirm: fl:= not Assigned(arFirmInfo[pID]);
    taClie: fl:= not Assigned(arClientInfo[pID]);
    taDprt: fl:= not Assigned(arDprtInfo[pID]);
  end;
  flnew:= flnew and fl;
  if flnew then try
    CScache.Enter;
    case kind of
      taWare: arWareInfo[pID]:= TWareInfo.Create(pID, 0, '');
      taEmpl: arEmplInfo[pID]:= TEmplInfoItem.Create(pID, 0, 1, '');
      taFirm: arFirmInfo[pID]:= TFirmInfo.Create(pID, '');
      taClie: arClientInfo.AddClient(pID);
//      taDprt: arDprtInfo[pID]:= TDprtInfo.Create(pID, 0, 0, '');
      taDprt: arDprtInfo[pID]:= TDprtInfo.Create(pID, 0, 0, '', 0, True);
    end;
  finally
    CScache.Leave;
  end;
  case kind of
    taWare: Result:= Assigned(arWareInfo[pID]);
    taEmpl: Result:= Assigned(arEmplInfo[pID]);
    taFirm: Result:= Assigned(arFirmInfo[pID]);
    taClie: Result:= Assigned(arClientInfo[pID]);
    taDprt: Result:= Assigned(arDprtInfo[pID]);
  end;
  if flnew then flnew:= Result; // ���������� ������� �������� ������ ��������
end;
//==================================================
function TDataCache.GrpExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arWareInfo)>pID) and
    Assigned(arWareInfo[pID]) and (arWareInfo[pID].IsGrp);
end;
//==================================================
function TDataCache.PgrExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arWareInfo)>pID) and
    Assigned(arWareInfo[pID]) and (arWareInfo[pID].IsPgr);
end;
//=================== �������� ������������� ������/��������� ��� ������/�������
function TDataCache.GrPgrExists(grID: integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if PgrExists(grID) then
    Result:= (grID<>pgrDeliv)
  else Result:= GrpExists(grID);
end;
//==================================================
function TDataCache.WareExist(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arWareInfo)>pID) and
    Assigned(arWareInfo[pID]) and (arWareInfo[pID].IsWare);
end;
//==================================================
function TDataCache.TypeExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arWareInfo)>pID) and
    Assigned(arWareInfo[pID]) and (arWareInfo[pID].IsType);
end;
//==================================================
function TDataCache.ClientExist(pID: Integer): Boolean;
begin
//  Result:= Assigned(self) and (pID>0) // and (length(arClientInfo)>pID)
//    and Assigned(arClientInfo[pID]);
  Result:= arClientInfo.ClientExists(pID);
end;
//==================================================
function TDataCache.EmplExist(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arEmplInfo)>pID)
    and Assigned(arEmplInfo[pID]);
end;
//==================================================
function TDataCache.DprtExist(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arDprtInfo)>pID)
    and Assigned(arDprtInfo[pID]);
end;
//==================================================
function TDataCache.FirmExist(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arFirmInfo)>pID)
    and Assigned(arFirmInfo[pID]);
end;
//==================================================
function TDataCache.MeasExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and FMeasNames.ItemExists(pID);
end;
//==================================================
function TDataCache.RoleExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and FEmplRoles.ItemExists(pID);
end;
//==================================================
function TDataCache.ImpTypeExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and FImportTypes.ItemExists(pID);
end;
//==================================================
function TDataCache.ConstExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and FParConstants.ItemExists(pID);
end;
//==================================================
function TDataCache.CurrExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and Currencies.ItemExists(pID);
end;
//==================================================
function TDataCache.FaccExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and FiscalCenters.ItemExists(pID);
end;
//==================================================
function TDataCache.FirmTypeExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arFirmTypesNames)>pID)
    and (arFirmTypesNames[pID]<>'');
end;
//==================================================
function TDataCache.FirmClassExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(arFirmClassNames)>pID)
    and (arFirmClassNames[pID]<>'');
end;
//=================================================================== ��� ������
function TDataCache.GetGrpID(ID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or (ID<1) or not Assigned(arWareInfo[ID]) then Exit;
  with arWareInfo[ID] do if IsGrp then Result:= ID
    else if IsPgr then Result:= PgrID else if IsWare then Result:= GrpID;
end;
//================================================================ ��� ���������
function TDataCache.GetPgrID(ID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or (ID<1) or not Assigned(arWareInfo[ID]) then Exit;
  with arWareInfo[ID] do if IsGrp then Exit
    else if IsPgr then Result:= ID else if IsWare then Result:= PgrID;
end;
//===================== ����������� ��� ������� ������� �� ����� � ������ currID
function TDataCache.GetPriceBonusCoeff(currID: Integer): Single;
// ��� ������ "unit" ���������� 0
var rate: Single;
begin
  Result:= 0;
  if not Assigned(self) or not Currencies.ItemExists(currID) then Exit;
  if (currID=BonusCrncCode) then Exit;
  if (currID=cDefCurrency) then Result:= BonusVolumeCoeff
  else begin
    rate:= Currencies.GetCurrRate(currID);
  //  if not fnNotZero(rate) then rate:= 1;
    Result:= BonusVolumeCoeff*rate/DefCurrRate;
  end;
end;
//========================================================= ������������ ��.���.
function TDataCache.GetMeasName(pID: Integer): string;
begin
  if not Assigned(self) or not MeasExists(pID) then Result:= ''
  else Result:= FMeasNames.GetItemName(pID);
end;
//========================================================== ������������ ������
function TDataCache.GetCurrName(pID: Integer; ForClient: Boolean): string;
begin
  if not Assigned(self) or not CurrExists(pID) then Result:= ''
  else if ForClient then Result:= Currencies[pID].CliName
  else Result:= Currencies[pID].Name;
end;
//============================================================= ������������ ���
function TDataCache.GetFaccName(pID: Integer): string;
begin
  if not Assigned(self) or not FaccExists(pID) then Result:= ''
  else Result:= FiscalCenters.GetItemName(pID);
end;
//====================================================== ������������ ���� �����
function TDataCache.GetFirmTypeName(typeID: Integer): string;
begin
  if not Assigned(self) or not FirmTypeExists(typeID) then Result:= ''
  else Result:= arFirmTypesNames[typeID];
end;
//================================================= ������������ ��������� �����
function TDataCache.GetFirmClassName(ClassID: Integer): string;
begin
  if not Assigned(self) or not FirmClassExists(ClassID) then Result:= ''
  else Result:= arFirmClassNames[ClassID];
end;
//=================================================== ������������ �������������
function TDataCache.GetDprtMainName(pID: Integer): string;
begin
  if not Assigned(self) or not DprtExist(pID) then Result:= ''
  else Result:= arDprtInfo[pID].MainName;
end;
//================================================ ��.������������ �������������
function TDataCache.GetDprtShortName(pID: Integer): string;
begin
  if not Assigned(self) or not DprtExist(pID) then Result:= ''
  else Result:= arDprtInfo[pID].ShortName;
end;
//============================================== ��������� ������� �������������
function TDataCache.GetDprtColName(pID: Integer): string;
begin
  if not Assigned(self) or not DprtExist(pID) then Result:= ''
  else Result:= arDprtInfo[pID].ColumnName;
end;
//========================================================= ������������ �������
function TDataCache.GetImpTypeName(pID: Integer): string;
begin
  if Assigned(self) then Result:= FImportTypes.GetItemName(pID) else Result:= '';
end;
//============================================================ ������������ ����
function TDataCache.GetRoleName(pID: Integer): string;
begin
  if Assigned(self) then Result:= FEmplRoles.GetItemName(pID) else Result:= '';
end;
//===================================================== ������������ ���� ������
function TDataCache.GetWareTypeName(typeID: Integer): string;
begin
  if Assigned(self) and TypeExists(typeID) then Result:= arWareInfo[typeID].Name
  else Result:= '�� ���������';
end;
//================================================================== ����� �����
function TDataCache.GetActionComment(ActID: Integer): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if not WareActions.ItemExists(ActID) then Exit;
  Result:= TWareAction(WareActions[ActID]).Comment;
end;
//=================================================== ���� ���� �����, must Free
function TDataCache.GetAllRoleCodes: Tai;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  Result:= FEmplRoles.GetDirCodes;
end;
{//====================== ���� ����������� ��� �������� ������ �������, must Free
function TDataCache.GetDownLoadExcludeBrands: Tai;
var i: integer;
    br: TBrandItem;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  for i:= 0 to WareBrands.ItemsList.Count-1 do begin
    br:= WareBrands.ItemsList[i];
    if br.DownLoadExclude then prAddItemToIntArray(br.ID, Result);
  end;
end;   }
//==================================================
function TDataCache.GetEmplIDByLogin(login: string): Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  login:= UpperCase(login);
  for Result:= 1 to High(arEmplInfo) do
    if EmplExist(Result) and (UpperCase(arEmplInfo[Result].ServerLogin)=login) then exit;
  Result:= -1;
end;
//==================================================
function TDataCache.GetEmplIDByGBLogin(Login: string): Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  login:= UpperCase(login);
  for Result:= 1 to High(arEmplInfo) do
    if EmplExist(Result) then with arEmplInfo[Result] do
      if (UpperCase(GBLogin)=login) or (UpperCase(GBReportLogin)=login) then exit;
  Result:= -1;
end;
//==================================================
function TDataCache.GetEmplIDBySession(pSession: string): Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  for Result:= 1 to High(arEmplInfo) do
    if EmplExist(Result) and (arEmplInfo[Result].Session=pSession) then exit;
  Result:= -1;
end;
//============================================================ ������ ����� ����
function TDataCache.GetRegFirmCodes(RegID: Integer=0; Search: string=''; NotArchived: boolean=True): Tai;
// RegID>0 - ��� ���������, 0- ���, <0 - �����.����� ������� ���
// Search - ���� ������ �� ������������, NotArchived - ������ ����������
var i: integer;
    flReg, flSearch, flFaccReg: boolean;
    list: TStringList;
begin
  SetLength(Result, 0);
  if not Assigned(self) or (length(arFirmInfo)<2) then Exit;

  flFaccReg:= (RegID<0);
  if flFaccReg then begin
    RegID:= -RegID;
    flReg:= False;
  end else flReg:= (RegID>0);

  flSearch:= (Search<>'');
  if flSearch then Search:= AnsiUpperCase(Search);
  list:= TStringList.Create;
  try
    for i:= 1 to High(arFirmInfo) do if FirmExist(i) then with arFirmInfo[i] do begin
      if NotArchived and Arhived then Continue;
      if flFaccReg and not CheckFirmRegion(RegID) then Continue;
      if flReg and not CheckFirmManager(RegID) then Continue;
      if not flSearch or ((pos(Search, UPPERMAINNAME)>0)
        or (pos(Search, UPPERSHORTNAME)>0)) then
        list.AddObject(arFirmInfo[i].Name, Pointer(i));
    end;
    list.Sort; // ��������� �� ������������
    SetLength(Result, list.Count);
    for i:= 0 to list.Count-1 do Result[i]:= integer(list.Objects[i]);
  finally
    prFree(list);
  end;
end;
//==================== ������ ����� ����������, ���������� �� ���� ������� � ���
function TDataCache.GetEmplCodesByShortName(DprtID: Integer=0; role: Integer=0): Tai;
//DprtID - ��� ������� (0-���)
var list: TStringList;
    i, j: integer;
    s: string;
    flDprt, flRole: boolean;
    empl: TEmplInfoItem;
begin
  SetLength(Result, 0);
  if not Assigned(self) or (length(arEmplInfo)<2) then Exit;
  list:= TStringList.Create;
  flDprt:= DprtID>0;
  flRole:= role>0;
  for i:= 1 to High(arEmplInfo) do if EmplExist(i) then begin
    empl:= arEmplInfo[i];
    if flRole and not empl.UserRoleExists(role) then Continue;
    if flDprt then begin
      if (Empl.EmplDprtID<>DprtID) then Continue;
      s:= Empl.EmplShortName;
    end else
      s:= String(fnMakeAddCharStr(Empl.EmplDprtID, 10, '*'))+Empl.EmplShortName;
    list.AddObject(s, Pointer(i));
  end;
  list.Sort; // ��������� �� �� ���� ������� � ���
  SetLength(Result, list.Count);
  for i:= 0 to list.Count-1 do begin
    j:= Integer(list.Objects[i]);
    Result[i]:= j;
  end;
  prFree(list);
end;
//======================================= ������ ������������� � �������� ������
function TDataCache.GetGroupDprts(pDprtGroup: Integer=0; StoreAndRoad: Boolean=False): Tai; // must Free
// StoreAndRoad=True - ������ ������ � ����, pDprtGroup=0 - ���
var i: Integer;
    Dprt: TDprtInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  if (pDprtGroup>0) and not DprtExist(pDprtGroup) then Exit;
  for i:= 1 to High(arDprtInfo) do if DprtExist(i) then begin
    Dprt:= arDprtInfo[i];
    if StoreAndRoad and not (Dprt.IsStoreHouse or Dprt.IsStoreRoad) then Continue;
    if (pDprtGroup>0) and not Dprt.IsInGroup(pDprtGroup) then Continue;
    prAddItemToIntArray(i, Result);
  end;
end;
//============================================================== ������ ��������
function TDataCache.GetFilialList(flShortName: Boolean=False): TStringList; // must Free
var i, j: Integer;
    Dprt: TDprtInfo;
    s: String;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  for i:= 1 to High(arDprtInfo) do if DprtExist(i) then try
    Dprt:= arDprtInfo[i];
    if not Dprt.IsFilial then Continue;
    if flShortName then s:= Dprt.ShortName else s:= Dprt.Name;
    if (pos('��������', s)>0) then Continue;
    j:= Dprt.ID;
    Result.AddObject(s, Pointer(j));
  except end;
  if Result.Count>1 then Result.Sort;
end;
//============================================================= ������ ����� �/�
function TDataCache.GetFirmTypesList: TStringList; // must Free
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  for i:= 1 to High(arFirmTypesNames) do if arFirmTypesNames[i]<>'' then try
    Result.AddObject(arFirmTypesNames[i], Pointer(i));
  except end;
  if Result.Count>1 then Result.Sort;
end;
//========================================================= ������ ��������� �/�
function TDataCache.GetFirmClassesList: TStringList; // must Free
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  for i:= 1 to High(arFirmClassNames) do if arFirmClassNames[i]<>'' then try
    Result.AddObject(arFirmClassNames[i], Pointer(i));
  except end;
  if Result.Count>1 then Result.Sort;
end;
//=================================================== ���������� / �������� ����
procedure TDataCache.TestDataCache(CompareTime: boolean=True; alter: boolean=False);
// CompareTime=True - ��������� ����� ���������� ����������, False - �� ���������
// alter=True - �� alter-��������, False - ������
const nmProc = 'TestDataCache'; // ��� ���������/�������
var LocalStart: TDateTime;
    flFill, fl: Boolean;
    interval, cdlp: Integer;
begin
  if not Assigned(self) or WareCacheTested then Exit;
  flFill:= (LastTimeCache=DateNull) or (Length(arDprtInfo)<2);
  LocalStart:= now();
  WareCacheTested:= True;
  try
    try
      if flFill then begin //------- �������������� ����������
        FillSysTypes; // �������������� ������� �����
        cdlp:= cdlpFillCache;
        if CompareTime then CompareTime:= False;
      end else begin
        cdlp:= cdlpTestCache;
      end;

      TestParConstants(flFill); // ���������

//if flDebug then TestFile;

      if not flFill then begin //----- ��������
        if (CompareDate(LastTimeCache, Now)=EqualsValue) and CompareTime then begin // ��� �� ����
          fl:= fnGetActionTimeEnable(caeTechWork); //----- ������ ���.�����
          if not fl then begin                     //----- � ������ �� ���� ����������� ��������
            Interval:= fnIfInt(fnGetActionTimeEnable(caeOnlyDay), TestCacheInterval, TestCacheNightInt);
            fl:= (Now<IncMinute(LastTimeCache, Interval));
          end;
          if fl then begin
            TestWareRests(); // �������� ������ � ��������� ������� (���� ��������)
            Exit;
          end;
        end;
      end; // if not flFill

      prMessageLOGS(' ', fLogCache, false);
      prMessageLOGS('................ '+
        fnIfStr(flFill, 'filling', 'testing')+' cache ...', fLogCache, false);

      SetLongProcessFlag(cdlp, flFill); // ���� - ����������/�������� ����
      try
        TestSmallDirectories(flFill);
        FillInfoNews(flFill);             // ����������/�������� ����-�����
        FillNotifications(flFill);        // ����������/�������� ����������� (Web)
        if AllowWebArm then begin
          TestEmpls(0, true, CompareTime, true);
          if flFill then BrandTDList:= FillBrandTDList;   // ���������� ������ ������� TecDoc
//          if flDebug and flFill then CheckClientsEmails;
        end;
        TestCssStopException;

if flFill or not flSkipTestWares then
        TestWares(flFill);          // ����������/�������� �������

        TestWareRests(CompareTime); // ����������/�������� ������ � ��������� �������
        TestCssStopException;
                 // ����������/�������� ������ �����/�������� � ��������� ������
        TestGrPgrDiscModelLinks;

        with FDCA do begin
          FillSourceLinks;
          if flFill then FillDirManuf(flFill);  //------- ����������
          FillOriginalNums(flFill);
          FillWareONLinks(flFill);
          TestCssStopException;
          if flFill and (AllowWeb or AllowWebArm) then begin //------- ����������
            FillTreeNodesAuto;
            FillTreeNodesMotul; // ���������� ������ ����� MOTUL (!!! ����� FillTreeNodesAuto)
            FillTypesInfoModel;
            FillDirModelLines(flFill);
            FillDirEngines(flFill);
            FillDirModels(flFill);
            TestCssStopException;
          end; // if flFill
        end; // with FDCA

        FillWareFiles(flFill);                // ��������/�������� ������ �������

//        if flFill then FillAttributes;        // ���������� ���������

        FillGBAttributes(flFill); // ���������� / �������� ��������� Grossbee

        if AllowWebArm then begin
          CheckGAMainNodesLinks; // ������ TD->GA � TreeNodesAuto->MainNode
          CheckArticleWareMarks(fLogCache); // ��������� ������� ������� � ��������� � TDT (�� �������)

        end else if not flFill and not CompareTime then begin // ���� �� ������� � ����� ��� �� ����������
          TestFirms(0, false, CompareTime, true);   // ��������� �������� ���� ����
          TestClients(0, false, CompareTime, true); // ��������� �������� ���� ��������
        end;

        if flFill then begin //------------ �������������� ����������

          WareCacheUnLocked:= True;  // ��������� ������ � ����� �������
          Application.ProcessMessages;

          if AllowWeb or AllowWebArm then
            prMessageLOGS('................ �������� ��� �� ������', fLogCache);
        end; // if flFill
      finally
        SetNotLongProcessFlag(cdlp); // ���������� ���� �������� ��������
      end;

      if flFill and (AllowWeb or AllowWebArm) then with FDCA do begin
        TestCssStopException;
        sleep(3*997); // ���� - ����� ����-�� ���� �����������
        cdlp:= cdlpFillLinks;
        SetLongProcessFlag(cdlp, flFill); // ���� - ���������� ������
        try
  //          LongProcessFlag:= cdlpFillLinks; // ���� - ���������� ������
  //          while not SetLongProcessFlag(cdlpFillLinks) do begin // ���� - ���������� ������
  //            sleep(997);                                        // ����, ���� ���� ������ ������� �������
  //            TestCssStopException;
  //          end;
          FillModelNodeLinks;       // �������� ������ ������� � ������� ����� (������ 2)
          FillWareModelNodeLinks;   // �������� ������ ������ �� ������� 2 (������ 3)
          WareLinksUnLocked:= True; // ��������� ������ � ��������
          prMessageLOGS('................ ��������� ������', fLogCache);
        finally
          SetNotLongProcessFlag(cdlp); // ���������� ���� �������� ��������
        end;
      end; // if flFill
//    end;
      LastTimeCache:= Now;

      prMessageLOGS(StringOfChar('-', 10)+nmProc+'_'+
        fnIfStr(flFill, 'start_fill', 'full_test')+': - '+
        GetLogTimeStr(LocalStart), fLogCache, false);
    except
      on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  finally
    WareCacheTested:= False;
  end;
end;
//====================================== ��������� ��������������� �������� ����
function TDataCache.GetTestCacheIndication: Integer;
var Interval: Integer;
begin
  Result:= 0;
//  if AppStatus in [stSuspending, stSuspended] then begin
//    Result:= 1;
//    Exit;
//  end;
                            // ���������� �������� �������� ���� (����-����)
  Interval:= fnIfInt(fnGetActionTimeEnable(caeOnlyDay), TestCacheInterval, TestCacheNightInt);
  Interval:= Interval*60;    // ��������� � ���
  if WareCacheTested then
    Interval:= Interval+(Interval div 2) // ���� ���� �������� - ��������� ��� ��������
  else begin
    Interval:= Interval+       // ��������� �������� ������� �������� ����
      GetIniParamInt(nmIniFileBOB, 'intervals', 'CheckDBConnectInterval', 30);
    Interval:= Interval+5*60;  // ��������� ��� ����� - 5 ���
  end;
  if (Now<IncSecond(LastTimeCache, Interval)) then Result:= 1;
end;
//====================== ������������ ��� ���������� TList ����������� ShipTimes
function ShipTimesSortCompare(Item1, Item2: Pointer): Integer;
var st1, st2: TShipTimeItem;
begin
  Result:= 0;
  with Cache do try
    st1:= TShipTimeItem(Item1);
    st2:= TShipTimeItem(Item2);
    if st1.Hour>st2.Hour then Result:= 1
    else if st1.Hour<st2.Hour then Result:= -1
    else if st1.Minute>st2.Minute then Result:= 1
    else if st1.Minute<st2.Minute then Result:= -1;
  except
    Result:= 0;
  end;
end;
//===================== ������������ ��� ���������� TList ����������� DiscModels
function DiscModelsSortCompare(Item1, Item2: Pointer): Integer;
var i1, i2: TDiscModel;
begin
  try
    i1:= TDiscModel(Item1);
    i2:= TDiscModel(Item2);
    if i1.DirectInd>i2.DirectInd then Result:= 1 // ������� �� ������� �����������
    else if i1.DirectInd<i2.DirectInd then Result:= -1
    else if i1.Rating>i2.Rating then Result:= 1 // ����� �� ��������
    else if i1.Rating<i2.Rating then Result:= -1
    else Result:= AnsiCompareText(i1.Name, i2.Name); // ����� �� ��������
  except
    Result:= 0;
  end;
end;
//===================================== ���������� ����� �� �������� ���� ������
function WareActionsDescSortCompare(Item1, Item2: Pointer): Integer;
var R1, R2: TDateTime;
    wa1, wa2: TWareAction;
begin
  try
    wa1:= TWareAction(Item1);
    wa2:= TWareAction(Item2);
    R1:= wa1.BegDate;
    R2:= wa2.BegDate;
    if (R1=R2) then Result:= 0 else if (R1>R2) then result:= -1 else result:= 1;
  except
    Result:= 0;
  end;
end;
//=================================================== ���������� ����� �� ������
function WareActionsNumSortCompare(Item1, Item2: Pointer): Integer;
var wa1, wa2: TWareAction;
    s1, s2: String;
begin
  try
    wa1:= TWareAction(Item1);
    wa2:= TWareAction(Item2);
    s1:= fnMakeAddCharStr(wa1.Num, 10);
    s2:= fnMakeAddCharStr(wa2.Num, 10);
    Result:= AnsiCompareText(s1, s2);
  except
    Result:= 0;
  end;
end;
//====================================== ���������� ���������� ���������� ������
function FillTTSortCompare(Item1, Item2: Pointer): Integer;
var R1, R2: TDateTime;
    tt1, tt2: TCodeAndDates;
begin
  try
    tt1:= TCodeAndDates(Item1);
    tt2:= TCodeAndDates(Item2);
    R1:= tt1.Date2;  // 1 - �� ����/������� ��������
    R2:= tt2.Date2;
    if (R1=R2) then begin
      R1:= tt1.Date1; // 2 - �� ����/������� ������
      R2:= tt2.Date1;
      if (R1=R2) then Result:= 0 else if (R1>R2) then result:= 1 else result:= -1;
    end else if (R1>R2) then result:= 1 else result:= -1;
  except
    Result:= 0;
  end;
end;
//======================================= ����������/�������� ����� ������������
procedure TDataCache.TestSmallDirectories(flFill: Boolean=True; alter: boolean=False);
// alter=True - �� alter-��������, False - ������
const nmProc = 'TestSmallDirectories'; // ��� ���������/�������
var i, j, ii, jj, mStart, mEnd, k: integer;
    s, ss, n, str: string;
    ibs, ibsOrd: TIBSQL;
    ibd, ibdOrd: TIBDatabase;
    fl, flnew, flOnlyErrAll: boolean;
    Item: Pointer;
    BonusCrncRate, BonusVolumePercent, curr: double;
    mDate: TDate;
    ar: Tai;
    TimeProc, d1, d2: TDateTime;
    h, m, Hmin, Hmax, Mmin, Mmax: Byte;
    fc: TFiscalCenter;
    sch: TTwoCodes;
    dprt: TDprtInfo;
    ilst: TIntegerList;
    lst: TList;
    wa, wat: TWareAction;
    Strings: TStringList;
    ProductLine: TProductLine;
    cq: TCodeAndQty;
    cds: TCodeAndDates;
begin
  if not Assigned(self) then Exit;
  if alter then str:= 'alter' else str:= 'full';
  ibs:= nil;
  ibd:= nil;
  ibsOrd:= nil;
  ibdOrd:= nil;
  mDate:= 0;
  TimeProc:= Now;
  SetLength(ar, 0);
  BonusCrncRate:= 0;
  BonusVolumePercent:= 0; // ������� ���������� �� ������
  ilst:= TIntegerList.Create;
  lst:= TList.Create;
  try try
////////////////////////////////////////////////////////////////////////////////
    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibsGRB_'+nmProc, -1, tpRead, True);

///////////////////////////////////////////////////// ����� ������������ � �����
    ibs.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
    ' from rdb$relation_fields f, rdb$fields ff where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE'+
    ' and (f.RDB$RELATION_NAME=:table1)';
    ibs.ParamByName('table1').AsString:= 'PAYINVOICEREESTR';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.FieldByName('fsize').AsInteger;
      s:= ibs.FieldByName('fname').AsString;
      if      (s='PINVCOMMENT')       and (AccEmpCommLength<>i) then AccEmpCommLength:= i
      else if (s='PINVCLIENTCOMMENT') and (AccCliCommLength<>i) then AccCliCommLength:= i
      else if (s='PINVWEBCOMMENT')    and (AccWebCommLength<>i) then AccWebCommLength:= i;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;

////////////////////////////////////////////// ����������� ���� ���-��� Grossbee
    ibs.SQL.Text:= 'select max(LockDate) from (select TuneWageSuperLockDate LockDate'+
      ' from TuneParametrs union select UserDocmIntermediateDate LockDate'+
      ' from userpsevdonimreestr where USERCODE=1)';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then mDate:= ibs.Fields[0].AsDate+1;
    ibs.Close;
    if (mDate>0) and (mDate<>DocmMinDate) then DocmMinDate:= mDate;
    TestCssStopException;

//////////////////////////////////////////////////// �������� ��� ������ �������
    i:= 0;                     //
//    fl:= TestRDB(cntsGRB, trkField, 'TUNEPARAMETRS', 'TuneNewCompletionMode');
    ibs.SQL.Text:= 'SELECT TUNEBONUSCRNCCODE, TUNEBANKLIMITSUMM'+
//      fnIfStr(fl, ', TuneNewCompletionMode', '')+
      ', TUNENEWSTYLEBKATCHECKING, TUNEBANKLIMITMINSUMM FROM TUNEPARAMETRS';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then begin
      BonusCrncCode:= ibs.FieldByName('TUNEBONUSCRNCCODE').AsInteger;
      BankLimitSumm:= ibs.FieldByName('TUNEBANKLIMITSUMM').AsFloat;
      BankMinSumm:= ibs.FieldByName('TUNEBANKLIMITMINSUMM').AsFloat;
      flCheckCliBankLim:= GetBoolGB(IBS, 'TUNENEWSTYLEBKATCHECKING');
//      if fl then flNewComplMode:= GetBoolGB(IBS, 'TuneNewCompletionMode');
    end;
//    flCheckCliBankLim:= False; // ???
    ibs.Close;
    if (i>0) and (i<>BonusCrncCode) then BonusCrncCode:= i;
    TestCssStopException;

////////////////////////////////////////// �������� ������� ���������� �� ������
    curr:= 0;
    ibs.SQL.Text:= 'select p.bnprpercent from BONUSPERCENT p order by p.bnprdate desc';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then curr:= ibs.Fields[0].AsFloat;
    ibs.Close;
    if fnNotZero(curr) and fnNotZero(curr-BonusVolumePercent) then BonusVolumePercent:= curr;
    TestCssStopException;

////////////////////////////////////////// ������� ������� ������� ��� ���������
    curr:= 0;
    ibs.SQL.Text:= 'SELECT DTZNCREDITPERCENT FROM DUTYZONES where DTZNCODE=2';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then curr:= ibs.Fields[0].AsFloat;
    ibs.Close;
    if fnNotZero(curr) and fnNotZero(curr-CreditPercent) then CreditPercent:= curr;
    TestCssStopException;

///////////////////////////////////////////////////////////////////////// ������
    if not flFill then Currencies.SetDirStates(False);
    ibs.SQL.Text:= 'SELECT CRNCCODE, CRNCSHORTNAME, CRNCARCHIVE, RESULTVALUE FROM CURRENCY'+
                   ' left join convertmoney (1.0, CRNCCODE, '+IntToStr(cUAHCurrency)+', "TODAY")'+
                   ' on exists(select * from RateCrnc where RateCrncCode=CRNCCODE)';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('CRNCCODE').AsInteger;
      n:= fnChangeEndOfStrBySpace(ibs.fieldByName('CRNCSHORTNAME').AsString);
      fl:= GetBoolGB(ibs, 'CRNCARCHIVE');
      curr:= ibs.fieldByName('RESULTVALUE').AsFloat;
      if (i in [cUAHCurrency, BonusCrncCode]) then ss:= n else ss:= '�.�.'; // ������������ ��� �������
      if not Currencies.ItemExists(i) then begin
        Item:= TCurrency.Create(i, n, ss, curr, fl);
        Currencies.CheckItem(Item);
      end else with Currencies[i] do begin
        Name:= n;
        Arhived:= fl;
        if (CliName<>ss) then CliName:= ss;
        if fnNotZero(curr-CurrRate) then CurrRate:= curr;
        State:= True;
      end;
      if fnNotZero(curr) then begin
        if (i=cDefCurrency) and fnNotZero(curr-DefCurrRate) then DefCurrRate:= curr;
        if (i=BonusCrncCode) and fnNotZero(curr-BonusCrncRate) then BonusCrncRate:= curr;
      end;

      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then Currencies.DelDirNotTested;

    if not fnNotZero(BonusCrncRate) then BonusCrncRate:= DefCurrRate;
    if fnNotZero(BonusVolumePercent) then begin
      curr:= RoundTo(DefCurrRate/BonusCrncRate*BonusVolumePercent/100, -4);
      if fnNotZero(curr-BonusVolumeCoeff) then BonusVolumeCoeff:= curr;
    end;
{    if flDebug then with Currencies.ItemsList do
      for i:= 0 to Count-1 do if not TCurrency(Items[i]).Arhived then begin
        j:= TCurrency(Items[i]).ID;
        n:= TCurrency(Items[i]).Name;
        ss:= TCurrency(Items[i]).CliName;
        curr:= TCurrency(Items[i]).CurrRate;
        prMessageLOGS(fnMakeAddCharStr(j, 5)+' '+fnMakeAddCharStr(n, 6, True)+
          fnMakeAddCharStr(ss, 6, True)+fnMakeAddCharStr(FormatFloat(cFloatFormatSumm, curr), 10), fLogDebug, false); // ����� � log
      end;  }
    TestCssStopException;

////////////////////////////////////////////////////////////////////// ���� ����
    if Length(arFirmTypesNames)<2 then begin
      ibs.SQL.Text:= 'SELECT GEN_ID (CLTPCODEGEN, 0) FROM RDB$DATABASE';
      ibs.ExecQuery;
      i:= ibs.Fields[0].AsInteger;
      ibs.Close;
      TestCacheArrayLength(taFtyp, i);
    end;
    ibs.SQL.Text:= 'SELECT CLTPCODE, CLTPNAME FROM CLIENTTYPES where CLTPARCHIVE="F"';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('CLTPCODE').AsInteger;
      TestCacheArrayLength(taFtyp, i+1);
      ss:= fnChangeEndOfStrBySpace(ibs.fieldByName('CLTPNAME').AsString);
      if arFirmTypesNames[i]<>ss then arFirmTypesNames[i]:= ss;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    TestCssStopException;

//////////////////////////////////////////////////////////////// ������� �������
    ibs.SQL.Text:= 'SELECT WRSTTPCODE, WRSTTPNAME FROM WARESTATETYPE';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('WRSTTPCODE').AsInteger;
      TestCacheArrayLength(taWaSt, i+1);
      ss:= fnChangeEndOfStrBySpace(ibs.fieldByName('WRSTTPNAME').AsString);
      if (arWareStateNames[i]<>ss) then arWareStateNames[i]:= ss;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    TestCssStopException;

///////////////////////////////////////////////////////////////// ��������� ����
    if Length(arFirmTypesNames)<2 then begin
      ibs.SQL.Text:= 'SELECT GEN_ID (FRCLCODEGEN, 0) FROM RDB$DATABASE';
      ibs.ExecQuery;
      i:= ibs.Fields[0].AsInteger;
      ibs.Close;
      TestCacheArrayLength(taFtyp, i);
    end;
    ibs.SQL.Text:= 'SELECT FRCLCODE, FRCLNAME from FIRMCLASS where FRCLARCHIVE="F"';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('FRCLCODE').AsInteger;
      TestCacheArrayLength(taFcls, i+1);
      ss:= fnChangeEndOfStrBySpace(ibs.fieldByName('FRCLNAME').AsString);
      if arFirmClassNames[i]<>ss then arFirmClassNames[i]:= ss;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    TestCssStopException;

//////////////////////////////////////////////////////////////////////// ��.���.
    if not flFill then FMeasNames.SetDirStates(False);
    ibs.SQL.Text:= 'SELECT MEASCODE, MEASNAME from MEASURE';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('MEASCODE').AsInteger;
      ss:= fnChangeEndOfStrBySpace(ibs.fieldByName('MEASNAME').AsString);
      Item:= TDirItem.Create(i, ss);
      FMeasNames.CheckItem(Item);
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then FMeasNames.DelDirNotTested;
    FMeasNames.CheckLength;
    TestCssStopException;

//////////////////////////////////////////////////////////////// ������ ��������
    ShipMethods.SetDirStates(False);
    ibs.SQL.Text:= 'SELECT SHMHCODE, SHMHNAME, SHMHTIMEKEY, SHMHLABELKEY'+
      ' from SHIPMENTMETHODS where SHMHARCHIVE="F"'; // +fnIfStr(ss='', '', ' and SHMHCODE in ('+ss+')');
    ibs.ExecQuery;
    while not ibs.Eof do begin
      Item:= TShipMethodItem.Create(ibs.fieldByName('SHMHCODE').AsInteger,
        fnChangeEndOfStrBySpace(ibs.fieldByName('SHMHNAME').AsString),
        GetBoolGB(ibs, 'SHMHTIMEKEY'), GetBoolGB(ibs, 'SHMHLABELKEY'));
      ShipMethods.CheckItem(Item);
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    ShipMethods.DelDirNotTested;
    ShipMethods.CheckLength;
    ShipMethods.SortDirListByName; // ���������� ������ �� ������������
    TestCssStopException;

/////////////////////////////////////////////////////////////// ������� ��������
    Hmin:= 0;
    Hmax:= 24;
    Mmin:= 0;
    Mmax:= 0;
    ss:= GetConstItem(pcSelfGetShipPeriod).StrValue;
    i:= pos('-', ss);
    if (i>0) then begin
      s:= copy(ss, 1, i-1);
      ii:= pos(':', s);
      if (ii>0) then begin
        n:= trim(copy(s, 1, ii-1));
        Hmin:= StrToIntDef(n, 0);
        n:= trim(copy(s, i+1, length(s)));
        Mmin:= StrToIntDef(n, 0);
      end;
      s:= copy(ss, i+1, length(ss));
      ii:= pos(':', s);
      if (ii>0) then begin
        n:= trim(copy(s, 1, ii-1));
        Hmax:= StrToIntDef(n, 24);
        n:= trim(copy(s, i+1, length(s)));
        Mmax:= StrToIntDef(n, 0);
      end;
    end;
    mStart:= Hmin*60+Mmin;
    mEnd:= Hmax*60+Mmax;

    ShipTimes.SetDirStates(False);
    ibs.SQL.Text:= 'SELECT SHTICODE, SHTINAME, SHTIHOUR, SHTIMINUTE'+
      ' from SHIPMENTTIMES where SHTIARCHIVE="F"';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('SHTICODE').AsInteger;
      ss:= fnChangeEndOfStrBySpace(ibs.fieldByName('SHTINAME').AsString);
      h:= ibs.fieldByName('SHTIHOUR').AsInteger;
      m:= ibs.fieldByName('SHTIMINUTE').AsInteger;
      if not ShipTimes.ItemExists(i) then begin
        Item:= TShipTimeItem.Create(i, ss, h, m);
        ShipTimes.CheckItem(Item);                //
      end else with TShipTimeItem(ShipTimes[i]) do begin
        Name:= ss;
        if (Hour  <>h) then Hour  := h;
        if (Minute<>m) then Minute:= m;
        State:= True;
      end;
//      j:= h*60+m;
//      TShipTimeItem(ShipTimes[i]).SelfGetAllow:= not ((j<mStart) or (j>mEnd));
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    ShipTimes.DelDirNotTested;
    ShipTimes.CheckLength;
    ShipTimes.DirSort(ShipTimesSortCompare); // ���������� ������ - ��� + ���
    TestCssStopException;

////////////////////////////////////////////////////////////////// �������������
                // ���� �������� - ���������� ������ ������ � ������ � ��������
    ss:= GetConstItem(pcOnlyErrAccMailFilials).StrValue;
    flOnlyErrAll:= (ss='');
    if not flOnlyErrAll then ar:= fnArrOfCodesFromString(ss);
    if Length(arDprtInfo)<2 then begin
      ibs.SQL.Text:= 'SELECT GEN_ID (DPRTCODEGEN, 0) FROM RDB$DATABASE';
      ibs.ExecQuery;
      i:= ibs.Fields[0].AsInteger;
      ibs.Close;
      TestCacheArrayLength(taDprt, i);
    end;
    if alter then begin
    {  ibs.SQL.Text:='SELECT DPRTCODE, DPRTSHORTNAME, DPRTCOLUMNNAME, DPRTMAINNAME, DprtKind, DPRTMASTERCODE'+
        ' FROM DEPARTMENT inner join DEPARTMENTALTER on DPRTALTERTIME>:time and DPRTALTERCODE=DPRTCODE'+
        ' order by DPRTCODE';
      ibs.ParamByName('time').AsDateTime:= IncMinute(LastTimeCacheAlter, -1);   }
    end else begin
      ibs.SQL.Text:= 'SELECT DPRTCODE, DPRTSHORTNAME, DPRTCOLUMNNAME,'+
        ' DPRTMAINNAME, DprtKind, DPRTMASTERCODE, DPRTEMAILORDER, DPRTDELAYTIME,'+
        ' adradlatitude/3600 latitude, adradlongitude/3600 longitude,'+
        ' g.rAdress FROM DEPARTMENT'+
        ' left join ADRESSADDPARM on adradregistrcode = dprtplasement'+
        ' left join getadressstr(dprtplasement) g on 1=1'+
        ' where DPRTARCHIVE="F" order by DPRTCODE';
    end;
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('DPRTCODE').AsInteger;
      flnew:= True;
      if TestCacheArrayItemExist(taDprt, i, flnew) then with arDprtInfo[i] do begin
        MainName:= fnChangeEndOfStrBySpace(ibs.fieldByName('DPRTMAINNAME').AsString);
        ParentID:= ibs.fieldByName('DPRTMASTERCODE').AsInteger;
        DelayTime:= ibs.fieldByName('DPRTDELAYTIME').AsInteger;

        fl:= not ibs.fieldByName('DprtKind').IsNull;
        m:= ibs.fieldByName('DprtKind').AsInteger;
        IsStoreHouse:= fl and (m=0);
        IsFilial    := fl and (m=1);
        IsStoreRoad := fl and (m=2);

        if IsStoreHouse or IsFilial or IsStoreRoad then
          ShortName:= fnChangeEndOfStrBySpace(ibs.fieldByName('DPRTSHORTNAME').AsString);

        if IsStoreHouse then begin
          ColumnName:= fnChangeEndOfStrBySpace(ibs.fieldByName('DPRTCOLUMNNAME').AsString);
          Adress:= fnChangeEndOfStrBySpace(ibs.fieldByName('rAdress').AsString);
          AdrLatitude:= RoundTo(ibs.fieldByName('latitude').AsFloat, -10);
          AdrLongitude:= RoundTo(ibs.fieldByName('longitude').AsFloat, -10);
//if flDebug and flFill then prMessageLOGS('dprt '+ fnMakeAddCharStr(IntToStr(i), 5)+': '+
//  FormatFloat('#00.0000000000', AdrLatitude)+'  '+FormatFloat('#00.0000000000', AdrLongitude)+'  '+Adress, fLogDebug);
        end;
        if IsFilial then begin
          ss:= fnChangeEndOfStrBySpace(ibs.fieldByName('DPRTEMAILORDER').AsString);
          if not fnCheckEmail(ss) then begin
// if flDebug then prMessageLOGS(nmProc+'_dprt'+IntToStr(i)+': not correct Email '+ss, fLogDebug);
            ss:= '';
          end;
          MailOrder:= ss;
          IsFilOnlyErr:= flOnlyErrAll or (fnInIntArray(i, ar)>-1);
        end;
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;

    for i:= 1 to High(arDPRTInfo) do          // ����������� ������ �� ����
      if Assigned(arDPRTInfo[i]) then arDPRTInfo[i].SetFilialID(i);

    j:= Length(arDprtInfo);
    for i:= High(arDprtInfo) downto 1 do if Assigned(arDprtInfo[i]) then begin
      j:= arDprtInfo[i].ID+1;
      break;
    end;
    if (Length(arDprtInfo)>j) then try
      CScache.Enter;
      SetLength(arDprtInfo, j); // �������� �� ���.����
    finally
      CScache.Leave;
    end;
    TestCssStopException;

///////////////////////////////////////////////////// ������ �������� �� �������
    ibs.SQL.Text:= 'SELECT DPSHMHDPRTCODE, DPSHMHMETHODCODE'+
      ' FROM DPRTSHIPMENTMETHODS order by DPSHMHDPRTCODE';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('DPSHMHDPRTCODE').AsInteger;
      if not DprtExist(i) then begin
        TestCssStopException;
        while not ibs.Eof and (i=ibs.fieldByName('DPSHMHDPRTCODE').AsInteger) do ibs.Next;
        Continue;
      end;
      with arDprtInfo[i].ShipLinks do begin
        SetLinkStates(False);
        while not ibs.Eof and (i=ibs.fieldByName('DPSHMHDPRTCODE').AsInteger) do begin
          j:= ibs.fieldByName('DPSHMHMETHODCODE').AsInteger;
          if ShipMethods.ItemExists(j) then CheckLink(j, 0, ShipMethods[j]);
          cntsGRB.TestSuspendException;
          ibs.Next;
        end;
        DelNotTestedLinks;
        SortByLinkName; // ���������� ������ �� ������������
      end;
    end;
    ibs.Close;
    TestCssStopException;

///////////// ������ �������/������, Object - TTwoCodes: ��� ������, ���� � ����
    try
      ibs.SQL.Text:= 'SELECT DPCMDEPARTMENTCODE, DPCMSTORECODE, DPCMDELAYDAY'+
        ' FROM DEPARTMENTCOMPLETION order by DPCMDEPARTMENTCODE, DPCMSORT';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('DPCMDEPARTMENTCODE').AsInteger; // �����/����
        if DprtExist(i) then begin
          dprt:= arDprtInfo[i];
          if not dprt.IsStoreHouse then dprt:= nil;
        end else dprt:= nil;

        if not Assigned(dprt) then begin
          TestCssStopException;
          while not ibs.Eof and (i=ibs.fieldByName('DPCMDEPARTMENTCODE').AsInteger) do ibs.Next;
          Continue;
        end;

        CScache.Enter;
        try
          for k:= dprt.StoresFrom.Count-1 downto 0 do
            TTwoCodes(dprt.StoresFrom[k]).Qty:= -1; // ������ - �� ���������
        finally
          CScache.Leave;
        end;
        fl:= False;
//        ilst.Clear;
        //---------------------------------------------------- ��������� 1 �����
        while not ibs.Eof and (i=ibs.fieldByName('DPCMDEPARTMENTCODE').AsInteger) do begin
          j:= ibs.fieldByName('DPCMSTORECODE').AsInteger;    // �����/������
          m:= ibs.fieldByName('DPCMDELAYDAY').AsInteger;     // ���� � ����
          fl:= fl or (m>1);
          jj:= -1;
          for ii:= 0 to dprt.StoresFrom.Count-1 do begin
            sch:= TTwoCodes(dprt.StoresFrom[ii]);
            if (sch.ID1=j) then begin
              jj:= ii;
              break;
            end;
          end;
//          ilst.Add(j); // ���� ������� � ������ ������� ��� �������� ����������
          try
            CScache.Enter;
            if (jj<0) then  // �� ����� - ���������
              dprt.StoresFrom.Add(TTwoCodes.Create(j, m, 1))
            else begin     // ����� - ���������
              if (sch.ID2<>m) then sch.ID2:= m;
              sch.Qty:= 1;
            end;
          finally
            CScache.Leave;
          end;
          cntsGRB.TestSuspendException;
          ibs.Next;
        end; // while not ibs.Eof and (i=

        CScache.Enter;
        try
          dprt.HasDprtFrom2:= fl;
          for k:= dprt.StoresFrom.Count-1 downto 0 do begin // ������� �������������
            sch:= TTwoCodes(dprt.StoresFrom[k]);
            if (sch.Qty<0) then begin
              dprt.StoresFrom.Delete(k);
              prFree(sch);
            end;
          end;
          // ��������� ������� ����������   ???
{          j:= min(ilst.Count, dprt.StoresFrom.Count)-1; // ��� ���������
          for k:= 0 to j do begin
            sch:= TTwoCodes(dprt.StoresFrom[k]);
          end;   }
        finally
          CScache.Leave;
        end;

{if flDebug and flFill then
  for k:= 0 to dprt.StoresFrom.Count-1 do with TTwoCodes(dprt.StoresFrom[k]) do
    prMessageLOGS('dprt='+fnMakeAddCharStr(IntToStr(dprt.ID), 5)+', from='+
      fnMakeAddCharStr(IntToStr(ID1), 5)+', delay= '+IntToStr(ID2), fLogDebug, false); }

      //------------------------------------------------------ ��������� 1 �����
      end; // while not ibs.Eof
    except
      on E: EBOBError do raise EBOBError.Create('_StoresFrom: '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_StoresFrom: '+E.Message, fLogCache);
    end;
    ibs.Close;
    TestCssStopException;

//if TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetDprtTimeTables') then
/////////////////////////////////////////// ������ ���������� ������� ����������
// Object - TCodeAndDates: ��� ������, ��������� ����/����� ������,
//                         ����/����� ��������, ����� ������� ��������
    try
//      ss:= fnIfStr(TodayFillDprts='', '', ' where DPCMDEPARTMENTCODE in ('+TodayFillDprts+')');
if flNewRestCols then begin
      ibs.SQL.Clear;
      ibs.ParamCheck:= False;
      ibs.SQL.Add('execute block returns (DprtTo integer, DprtFrom integer,'+
                  ' RttID integer, rArrive Date, rShowTime Date)');
      ibs.SQL.Add('as declare variable xDate Date; declare variable xShowCount integer;'+
                  ' declare variable xDayCount integer; begin');
      ibs.SQL.Add(' for select DPCMDEPARTMENTCODE, DPCMSTORECODE'+
                  '   from DEPARTMENTCOMPLETION'+//ss+
                  '  order by DPCMDEPARTMENTCODE into :DprtTo, :DprtFrom do begin');
      ibs.SQL.Add('   xShowCount=0; xDayCount=0; xDate="today";');
      ibs.SQL.Add('   while (xShowCount<2 and xDayCount<7) do begin');
      ibs.SQL.Add('    for select RttID, rArrive, rShowTime');
      ibs.SQL.Add('     from Vlad_CSS_GetDprtTimeTables(:DprtFrom, :DprtTo, :xDate)');
      ibs.SQL.Add('     where rShowTime>="now" order by rArrive');
      ibs.SQL.Add('    into :RttID, :rArrive, :rShowTime do begin');
      ibs.SQL.Add('     suspend; xShowCount=xShowCount+1; if (xShowCount>1) then break;');
      ibs.SQL.Add('    end xDayCount=xDayCount+1; xDate=xDate+1; end end end');
end else
      ibs.SQL.Text:= 'SELECT dprtTo, dprtFrom, g.rShowTime, g.rArrive'+
        ' from (SELECT DPCMDEPARTMENTCODE dprtTo, DPCMSTORECODE dprtFrom'+
        '  FROM DEPARTMENTCOMPLETION'+//ss+
        '  order by DPCMDEPARTMENTCODE)'+  // , DPCMSORT
        '  left join Vlad_CSS_GetDprtTimeTables(dprtFrom, dprtTo, "today") g on 1=1'+
        '  where g.rShowTime>"now"'; //  and g.rArrive<"tomorrow"
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('dprtTo').AsInteger; // �����/����
        if DprtExist(i) then begin
          dprt:= arDprtInfo[i];
          if not dprt.IsStoreHouse then dprt:= nil;
        end else dprt:= nil;

        if not Assigned(dprt) then begin
          TestCssStopException;
          while not ibs.Eof and (i=ibs.fieldByName('dprtTo').AsInteger) do ibs.Next;
          Continue;
        end;

        CScache.Enter;
        try
          for k:= dprt.FillTT.Count-1 downto 0 do
            TCodeAndDates(dprt.FillTT[k]).State:= False; // ������ - �� ���������
        finally
          CScache.Leave;
        end;
        //---------------------------------------------------- ��������� 1 �����
        while not ibs.Eof and (i=ibs.fieldByName('dprtTo').AsInteger) do begin
          j:= ibs.fieldByName('dprtFrom').AsInteger;    // �����/������
          d1:= ibs.fieldByName('rShowTime').AsDateTime; // ��������� ����/����� ������
          d2:= ibs.fieldByName('rArrive').AsDateTime;   // ����/����� ��������

          ii:= Trunc(d2); // ������ - ����/����� �������� - ��������� ������� ��������
          if (ii=Date()) then
            s:= '�������, ����� '+FormatDateTime(cTimeFormatN, d2)
          else if (ii=(Date()+1)) then
            s:= '������, ����� '+FormatDateTime(cTimeFormatN, d2)
          else s:= FormatDateTime('dd.mm.yyyy, ����� hh:nn', d2);

          jj:= -1;
          for ii:= 0 to dprt.FillTT.Count-1 do begin
            cds:= TCodeAndDates(dprt.FillTT[ii]);
            if (cds.ID<>j) or fnNotZero(cds.Date1-d1)
              or fnNotZero(cds.Date2-d2) then Continue;
            jj:= ii;
            break;
          end;
          try
            CScache.Enter;
            if (jj<0) then  // �� ����� - ���������
              dprt.FillTT.Add(TCodeAndDates.Create(j, d1, d2, s))
            else begin     // ����� - ��������� ��������� �������
//              if fnNotZero(cds.Date1-d1) then cds.Date1:= d1;
//              if fnNotZero(cds.Date2-d2) then cds.Date2:= d2;
              if (cds.Name<>s) then cds.Name:= s;
              cds.State:= True;
            end;
          finally
            CScache.Leave;
          end;

          cntsGRB.TestSuspendException;
          ibs.Next;
        end; // while not ibs.Eof and (i=

        CScache.Enter;
        try
          for k:= dprt.FillTT.Count-1 downto 0 do begin
            cds:= TCodeAndDates(dprt.FillTT[k]);
            if not cds.State then begin
              dprt.FillTT.Delete(k); // ������� �������������
              prFree(cds);
            end;
          end;
          dprt.FillTT.SortList(FillTTSortCompare); // ���������
        finally
          CScache.Leave;
        end;
{if flDebug and flFill then
  for k:= 0 to dprt.FillTT.Count-1 do begin
    cds:= TCodeAndDates(dprt.FillTT[k]);
    prMessageLOGS('dprt='+fnMakeAddCharStr(IntToStr(dprt.ID), 5)+
      ', from='+fnMakeAddCharStr(IntToStr(cds.ID), 5)+
      ', show= '+FormatDateTime(cDateTimeFormatY2N, cds.Date1)+
      ', arrive= '+cds.Name, fLogDebug, false);
  end;    }
      //------------------------------------------------------ ��������� 1 �����
      end; // while not ibs.Eof
    except
      on E: EBOBError do raise EBOBError.Create('_DprtTodayTT: '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_DprtTodayTT: '+E.Message, fLogCache);
    end;
    ibs.Close;
if flNewRestCols then
    ibs.ParamCheck:= True;
    TestCssStopException;

///////////////////////////////////////////////// ���������� �������� �� �������
    try
      mDate:= Date();
      ibs.SQL.Text:= 'SELECT SHBDDATE, DpScDprtCode,'+
        ' iif(DpExScCode is null, DpScStartTime, DpExScStartTime) StartTime,'+
        ' iif(DpExScCode is null, DpScStopTime, DpExScStopTime) StopTime'+
        ' FROM OPERSCHDBODY left join DprtSchedule on dpscdaytype=SHBDSHIFT'+
        ' left join DprtExceptSchedule on DpExScDprtCode=DpScDprtCode and DpExScDate=SHBDDATE'+
        ' where SHBDDATE between :d1 and :d2 and DpScDprtCode is not null'+
        ' order by DpScDprtCode, SHBDDATE';
      ibs.ParamByName('d1').AsDate:= mDate;            // � ������� ��� �������� � ���������
      ibs.ParamByName('d2').AsDate:= mDate+(Cache.GetConstItem(pcShipChoiceDays).IntValue*2);
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('DpScDprtCode').AsInteger;
        if not DprtExist(i) then begin
          TestCssStopException;
          while not ibs.Eof and (i=ibs.fieldByName('DpScDprtCode').AsInteger) do ibs.Next;
          Continue;
        end;
        dprt:= arDprtInfo[i];
        lst.Clear;
        for j:= 0 to dprt.Schedule.Count-1 do lst.Add(Pointer(0)); // ����� ��������
        while not ibs.Eof and (i=ibs.fieldByName('DpScDprtCode').AsInteger) do begin
          ii:= trunc(ibs.fieldByName('SHBDDATE').AsDate-mDate);
          if (ii>-1) then begin
            j:= ibs.fieldByName('StartTime').AsInteger;
            jj:= ibs.fieldByName('StopTime').AsInteger;
            try
              CScache.Enter;
              while (dprt.Schedule.Count<=ii) do begin // ���� ���� �������� ���
                dprt.Schedule.Add(TTwoCodes.Create(0, 0));
                lst.Add(Pointer(0));
              end;
              if not assigned(dprt.Schedule[ii]) then
                dprt.Schedule[ii]:= TTwoCodes.Create(j, jj)
              else begin
                sch:= TTwoCodes(dprt.Schedule[ii]);
                if (sch.ID1<>j) then sch.ID1:= j;
                if (sch.ID2<>jj) then sch.ID2:= jj;
              end;
            finally
              CScache.Leave;
            end;
            lst[ii]:= Pointer(1);
          end; // if (ii>-1)
          cntsGRB.TestSuspendException;
          ibs.Next;
        end; // while not ibs.Eof and (i=
        try
          CScache.Enter;
          for i:= 0 to dprt.Schedule.Count-1 do begin // ���� �������������
            if not Assigned(dprt.Schedule[i]) then
              dprt.Schedule[i]:= TTwoCodes.Create(0, 0)
            else if not Assigned(lst[i]) or (Integer(lst[i])=0) then begin
              sch:= TTwoCodes(dprt.Schedule[i]);
              sch.ID1:= 0;
              sch.ID2:= 0;
            end
          end;
        finally
          CScache.Leave;
        end;
      end; // while not ibs.Eof
    except
      on E: EBOBError do raise EBOBError.Create('_Schedules: '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_Schedules: '+E.Message, fLogCache);
    end;
    ibs.Close;
    TestCssStopException;

/////////////////////////////////////////////////// ��� (FISCALACCOUNTINGCENTER)
    if not flFill then FiscalCenters.SetDirStates(False);   // ������ ��������� <������������ ������>
    SetLength(ar, 0);
    ibs.ParamCheck:= False;
    ibs.SQL.Clear;
    ibs.SQL.Add('execute block returns (rCode integer, rPar integer, rName varchar(100), rEmpl integer)');
    ibs.SQL.Add('as declare variable xCode integer=0; declare variable xCount integer=0;');
    ibs.SQL.Add('declare variable xDate Date; begin');
    ibs.SQL.Add('  for select FcGrFiscalCode, FcGrMasterCode, FCGRFISCALNAME, FCGRSTARTDATE');
    ibs.SQL.Add('    from fiscalcentergroup where FcGrClassCode='+GetConstItem(pcFaccPlanSaleClassCode).StrValue);
    ibs.SQL.Add('      and FCGRSTARTDATE<="today" and FCGRFISCALARCHIVE="F"');
    ibs.SQL.Add('    order by FcGrMasterCode, FcGrFiscalCode, FCGRSTARTDATE desc');
    ibs.SQL.Add('  into :rCode, :rPar, :rName, :xDate do if (xCode<>rCode) then begin xCode=rCode; xCount=0;');
    ibs.SQL.Add('    if (exists(select * from fiscalcentergroup f where f.FcGrMasterCode=:rCode'); // ������� �������
    ibs.SQL.Add('      and f.FcGrClassCode=6 and f.FCGRSTARTDATE<="today" and f.FCGRFISCALARCHIVE="F"))');
    ibs.SQL.Add('    then begin rEmpl=-1; suspend; end');
    ibs.SQL.Add('    else begin for select e.emplcode from CONTROLUNITLINK cul'); // ������ �������
    ibs.SQL.Add('      left join AnalitDict BKE on BKE.andtCode = cul.CnUnLnControlUnitCode');
    ibs.SQL.Add('      left join AnalitDict EmplAnalit on EmplAnalit.AnDtCode = BKE.AnDtMasterDict');
    ibs.SQL.Add('      left join employees e on e.emplmancode = EmplAnalit.AnDtMasterDict');
    ibs.SQL.Add('      where cul.CNUNLNFACCCODE = :rCode and "TODAY" between cul.CnUnLnStartDate');
    ibs.SQL.Add('        and cul.CnUnLnStopDate and e.emplcode is not null and e.emplarchive = "F"');
    ibs.SQL.Add('      group by e.emplcode into :rEmpl do begin xCount=xCount+1;');
    ibs.SQL.Add('      if (rEmpl is null or rEmpl <1) then rEmpl=0; suspend; end');
    ibs.SQL.Add('      if (xCount<1) then begin rEmpl=0; suspend; end end end end');
    ibs.ExecQuery;
    while not ibs.EOF do begin
      i:= ibs.FieldByName('rCode').AsInteger;  // ID
      j:= ibs.FieldByName('rPar').AsInteger;   // Parent
      n:= fnChangeEndOfStrBySpace(ibs.FieldByName('rName').AsString);
      fl:= (ibs.FieldByName('rEmpl').AsInteger<0);
      if not FiscalCenters.ItemExists(i) then begin
        fc:= TFiscalCenter.Create(i, j, n);
        fc.LastLevel:= not fl;
        Item:= fc;
        FiscalCenters.CheckItem(Item);
      end else begin
        fc:= FiscalCenters[i];
        fc.Name:= n;
        FiscalCenters.CS_DirItems.Enter;
        try
          if (fc.Parent<>j) then fc.Parent:= j;
          fc.LastLevel:= not fl;
          fc.State:= True;
        finally
          FiscalCenters.CS_DirItems.Leave;
        end;
      end;
      s:= '';
      TestCssStopException;
      if fl then ibs.Next
      else while not ibs.EOF and (i=ibs.FieldByName('rCode').AsInteger) do begin
        if (ibs.FieldByName('rEmpl').AsInteger>0) then
          s:= s+fnIfStr(s='', '', ',')+ibs.FieldByName('rEmpl').AsString;
        ibs.Next;
      end;
      j:= fc.Region;
      if fc.CheckIsROPFacc and (j>0) then begin // ��� ���-� ������
        if High(ar)<j then SetLength(ar, j+1);
        if ar[j]<>i then ar[j]:= i;
      end;
      FiscalCenters.CS_DirItems.Enter;
      try
        if (s<>'') then begin
          prCheckIntegerListByCodesString(fc.BKEempls, s);
          for ii:= 0 to fc.BKEempls.Count-1 do begin
            jj:= fc.BKEempls[ii];
            if not Cache.EmplExist(jj) then Continue;
            Cache.arEmplInfo[jj].FaccRegion:= j;
          end;
        end else if (fc.BKEempls.Count>0) then fc.BKEempls.Clear;
      finally
        FiscalCenters.CS_DirItems.Leave;
      end;
      cntsGRB.TestSuspendException;
    end;
    ibs.Close;

    if not flFill then FiscalCenters.DelDirNotTested;
    FiscalCenters.CheckLength;
    FiscalCenters.CS_DirItems.Enter;
    try
      for j:= 0 to FiscalCenters.ItemsList.Count-1 do begin
        fc:= FiscalCenters.ItemsList[j];
        jj:= fc.GetSaleType;
        fc.IsAutoSale:= (jj=constIsAuto);
        fc.IsMotoSale:= (jj=constIsMoto);
      end;
    finally
      FiscalCenters.CS_DirItems.Leave;
    end;
    try // ������� ������ ��� ���-� ������ �� ������ ������
      CScache.Enter;
      if Length(arRegionROPFacc)<>Length(ar) then
        SetLength(arRegionROPFacc, Length(ar));
      for i:= Low(ar) to High(ar) do
        if arRegionROPFacc[i]<>ar[i] then arRegionROPFacc[i]:= ar[i];
    finally
      CScache.Leave;
    end;
{      if flDebug then begin
      prMessageLOGS('-------------------', fLogDebug, false); // ����� � log
      for i:= 0 to ItemsList.Count-1 do with TFiscalCenter(ItemsList[i]) do
        prMessageLOGS(fnMakeAddCharStr(GetSaleType, 3)+' '+fnMakeAddCharStr(Parent, 5)+' '+
          fnMakeAddCharStr(ID, 5)+' '+Name, fLogDebug, false); // ����� � log
    end;   }
    TestCssStopException;

////////////////////////////// ���� ������� ����� ������� ��� ������ �������� TD
//    s:= GetConstItem(pcBrandsWithoutTDPicts).StrValue;
//    prCheckIntegerListByCodesString(NoTDPictBrandCodes, s); // ������� TIntegerList �� ������� �����

    ibs.ParamCheck:= True;
///////////////////////////////////////////////////////////////////////// ������
    s:= GetConstItem(pcUsedPriceTypes).StrValue;
    ibs.SQL.Text:= 'SELECT PRTPCODE from PRICETYPE where PRTPARCHIVE="F"'+
      fnIfStr(s='', '', ' and PRTPCODE in ('+s+')')+' order by PRTPCODE';
    ibs.ExecQuery;
    ilst.Clear;
    while not ibs.Eof do begin
      ilst.Add(ibs.fieldByName('PRTPCODE').AsInteger);
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    j:= ilst.Count;
    CScache.Enter;
    try // ������� ������ �������
      if (j<1) then begin // ������������
        SetLength(PriceTypes, 1);
        PriceTypes[0]:= 1;
      end else begin
        if (Length(PriceTypes)<j) then SetLength(PriceTypes, j);
        for i:= 0 to ilst.Count-1 do begin
          ii:= ilst[i];
          if (ii>0) and (PriceTypes[i]<>ii) then PriceTypes[i]:= ii;
        end;
        if (Length(PriceTypes)>j) then SetLength(PriceTypes, j);
      end;
    finally
      CScache.Leave;
    end;

///////////////////////////////////////////////////////////////// ������� ������
    ibs.SQL.Clear;         // ����������� �� ���������
    ibs.SQL.Text:= 'SELECT rProdDirect, rPrDirName from Vlad_CSS_GetProdDirects';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('rProdDirect').AsInteger;
      s:= ibs.fieldByName('rPrDirName').AsString;
      if (i<>cpdNotDirect) then begin
        DiscountModels.CheckProdDirect(i, s); // ���������/��������� �����������
        if not flFill then ilst.Add(i);
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then with DiscountModels do for i:= ProdDirectList.Count-1 downto 0 do begin
      jj:= Integer(ProdDirectList.Objects[i]);
      if (ilst.IndexOf(jj)<0) then DelProdDirect(jj);     // ������� ������
    end;

{    if flDebug then begin
      prMessageLOGS('-------------------', fLogDebug, false); // ����� � log
      for i:= 0 to DiscountModels.ProdDirectList.Count-1 do
      with DiscountModels.ProdDirectList do
        prMessageLOGS(fnMakeAddCharStr(IntToStr(integer(Objects[i])), 3)+' '+
          Strings[i], fLogDebug, false); // ����� � log
      prMessageLOGS('-------------------', fLogDebug, false); // ����� � log
    end;  }

    ibs.SQL.Text:= 'SELECT rProdDirect, rDiscModel, rModelName, rRating, rValue'+
                   ' from Vlad_CSS_GetProdDirDiscModels';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('rProdDirect').AsInteger;
      while not ibs.EOF and (i=ibs.FieldByName('rProdDirect').AsInteger) do begin
        if (i<>cpdNotDirect) then begin
          j:= ibs.fieldByName('rDiscModel').AsInteger; // ���������/��������� ������
          DiscountModels.CheckDiscModel(j, i, ibs.fieldByName('rRating').AsInteger,
            ibs.fieldByName('rValue').AsInteger, ibs.fieldByName('rModelName').AsString);
        end;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
    end;
    ibs.Close;
    if not flFill then DiscountModels.DelNotTestedDiscModels; // ������� ������ �������
    DiscountModels.SortDiscModels;

{    if flDebug then begin
      prMessageLOGS('-------------------', fLogDebug, false); // ����� � log
      for i:= 0 to DiscountModels.DiscModels.Count-1 do
      with TDiscModel(DiscountModels.DiscModels[i]) do
        prMessageLOGS(fnMakeAddCharStr(ID, 3)+' '+fnMakeAddCharStr(DirectInd, 5)+' '+
          fnMakeAddCharStr(Rating, 5)+' '+fnMakeAddCharStr(Sales, 5)+' '+Name, fLogDebug, false); // ����� � log
      prMessageLOGS('-------------------', fLogDebug, false); // ����� � log
    end; }

/////////////////////////////////////////////////////////////////////// ��������
    ilst.Clear;
    ibs.SQL.Clear;
    ibs.SQL.Text:= 'SELECT AnDtCode, AnDtName from WAREPRODUCTS'+
      ' left join analitdict on AnDtCode=WRPRREGISTRCODE'+
      ' where WRPRPRODUCTDIRECTION<>'+IntToStr(cpdNotDirect)+
      '  and AnDtCode is not null and AnDtCode>0';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('AnDtCode').AsInteger;
      s:= ibs.fieldByName('AnDtName').AsString;
      if not flFill then ilst.Add(i); // ��� ��������
      Item:= Pointer(i);
      jj:= WareProductList.IndexOfObject(Item);
      Cache.CScache.Enter;
      try
        if (jj<0) then WareProductList.AddObject(s, Item)
        else if (WareProductList[jj]<>s) then WareProductList[jj]:= s;
      finally
        Cache.CScache.Leave;
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then try
      Cache.CScache.Enter;
      for i:= WareProductList.Count-1 downto 0 do begin
        jj:= Integer(WareProductList.Objects[i]);
        if (ilst.IndexOf(jj)<0) then WareProductList.Delete(i);     // ������� ������
      end;
    finally
      Cache.CScache.Leave;
    end;

//////////////////////////////////////////////////////////////////// ������� SMS
    ilst.Clear;
    ibs.SQL.Clear;
    ibs.SQL.Text:= 'SELECT AnDtCode, AnDtName'+
      ' from SMSMODELS left join analitdict on AnDtCode=SMRegistrCode'+
      ' where AnDtCode is not null and AnDtCode>0 and not (andtname starting "_")';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('AnDtCode').AsInteger;
      s:= ibs.fieldByName('AnDtName').AsString;
      if not flFill then ilst.Add(i); // ��� ��������
      Item:= Pointer(i);
      jj:= SMSmodelsList.IndexOfObject(Item);
      Cache.CScache.Enter;
      try
        if (jj<0) then SMSmodelsList.AddObject(s, Item)
        else if (SMSmodelsList[jj]<>s) then SMSmodelsList[jj]:= s;
      finally
        Cache.CScache.Leave;
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then try
      Cache.CScache.Enter;
      for i:= SMSmodelsList.Count-1 downto 0 do begin
        jj:= Integer(SMSmodelsList.Objects[i]);
        if (ilst.IndexOf(jj)<0) then SMSmodelsList.Delete(i);     // ������� ������
      end;
    finally
      Cache.CScache.Leave;
    end;

//////////////////////////////////////////////////// ������ ����� ���.����������
    if not flFill then
      for i:= 0 to MobilePhoneSigns.Count-1 do MobilePhoneSigns.Objects[i]:= Pointer(0);
    ibs.SQL.Clear;
    ibs.SQL.Text:= 'SELECT MPhSignature from MobilePhoneSignature';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      s:= fnChangeEndOfStrBySpace(ibs.fieldByName('MPhSignature').AsString);
      if flFill then i:= -1 else i:= MobilePhoneSigns.IndexOf(s);
      if (i<0) then MobilePhoneSigns.AddObject(s, Pointer(1))
      else MobilePhoneSigns.Objects[i]:= Pointer(1);
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then for i:= MobilePhoneSigns.Count-1 downto 0 do
      if (Integer(MobilePhoneSigns.Objects[i])<1) then MobilePhoneSigns.Delete(i);

//////////////////////////////////////////////////////// ������ ����� �� �������
    if not flFill then WareActions.SetDirStates(False);
    ibs.SQL.Clear;
    s:= Cache.GetConstItem(pcCauseActions).StrValue;     // �����
    n:= ' iif(a.andtcode='+s+' or a1.andtcode='+s+' or a2.andtcode='+s+
        ' or a3.andtcode='+s+' or a4.andtcode='+s+', 1, 0) acts,';
    s:= Cache.GetConstItem(pcCauseCatchMoment).StrValue; // ���� ������
    n:= n+' iif(WrAcCauseCode='+s+', 1, 0) cms,';
    s:= Cache.GetConstItem(pcCauseNews).StrValue;        // �������
    n:= n+' iif(WrAcCauseCode='+s+', 1, 0) news,';
    s:= Cache.GetConstItem(pcCauseTopSearch).StrValue;   // ��� ������
    n:= n+' iif(WrAcCauseCode='+s+', 1, 0) tops,';
    ibs.SQL.Text:= 'SELECT WrAcCode, a.AnDtName, WrAcStartDate, WrAcStopDate,'+
      n+' WrAcComment, WrAcNumber, WrAcExtn, WrAcPhoto from WareActionReestr'+
      ' left join analitdict a on a.andtcode=WrAcCauseCode'+
      ' left join analitdict a1 on a1.andtcode = a.andtmastercode'+
      ' left join analitdict a2 on a2.andtcode = a1.andtmastercode'+
      ' left join analitdict a3 on a3.andtcode = a2.andtmastercode'+
      ' left join analitdict a4 on a4.andtcode = a3.andtmastercode'+
      ' where WrAcSubFirmCode=1 and WrAcDocmState=1'+
      '   and WrAcStartDate<="today" and WrAcStopDate>("today"-'+
      Cache.GetConstItem(pcClosedActionShowDays).StrValue+')';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('WrAcCode').AsInteger;
      s:= fnChangeEndOfStrBySpace(ibs.fieldByName('AnDtName').AsString);
      n:= fnChangeEndOfStrBySpace(ibs.FieldByName('WrAcComment').AsString);
      d1:= ibs.fieldByName('WrAcStartDate').AsDateTime;
      d2:= ibs.fieldByName('WrAcStopDate').AsDateTime;
      fl:= WareActions.ItemExists(i);
      if fl then begin // ��� ���� - ���������
        wa:= WareActions[i];
        wa.Name:= s;
      end else begin   // ����� - �������
        wa:= TWareAction.Create(i, s, n, d1, d2);
        WareActions.CheckItem(Pointer(wa));
      end;
      WareActions.CS_DirItems.Enter;
      try
        wa.IsAction   := (ibs.fieldByName('acts').AsInteger=1); // ���� - �����
        wa.IsCatchMom := (ibs.fieldByName('cms').AsInteger=1);  // ���� - ���� ������
        wa.IsNews     := (ibs.fieldByName('news').AsInteger=1); // ���� - �������
        wa.IsTopSearch:= (ibs.fieldByName('tops').AsInteger=1); // ���� - ��� ������
        wa.Num        := ibs.FieldByName('WrAcNumber').AsString;
        if fl then begin // ��� ���� - ���������
          if (wa.Comment<>n) then wa.Comment:= n;
          wa.BegDate:= d1;
          wa.EndDate:= d2;
          wa.State:= True;
        end;
        wa.IconExt:= ibs.FieldByName('WrAcExtn').AsString; // ���������� ������
        wa.IconMS.Clear;
        if (wa.IconExt<>'') then
          IBS.FieldByName('WrAcPhoto').SaveToStream(wa.IconMS); // ������
{if flDebug then
  if wa.IsNews then
    prMessageLOGS(nmProc+': IsNews      - '+IntToStr(wa.ID), fLogDebug, false)
  else if wa.IsCatchMom then
    prMessageLOGS(nmProc+': IsCatchMom  - '+IntToStr(wa.ID), fLogDebug, false)
  else if wa.IsTopSearch then
    prMessageLOGS(nmProc+': IsTopSearch - '+IntToStr(wa.ID), fLogDebug, false)
  else if wa.IsAction then
    prMessageLOGS(nmProc+': IsAction    - '+IntToStr(wa.ID), fLogDebug, false);
}
      finally
        WareActions.CS_DirItems.Leave;
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then WareActions.DelDirNotTested; // ������� ������
    WareActions.DirSort(WareActionsNumSortCompare); // ���������� ����� �� ������
//    WareActions.DirSort(WareActionsDescSortCompare); // ���������� ����� �� �������� ���� ������

    jj:= 0;
    wat:= nil;  //---------------------------- ���� ����������� ����� ��� ������
    for i:= 0 to WareActions.ItemsList.Count-1 do begin
      wa:= WareActions.ItemsList[i];
      if not wa.IsTopSearch then Continue;
      if (wa.BegDate>Date) or (wa.EndDate<Date) then Continue;
      if not Assigned(wat) or (wa.BegDate<wat.BegDate)
        or ((wa.BegDate=wat.BegDate) and (wa.ID<wat.ID)) then wat:= wa;
      inc(jj);
    end; // for

    if Assigned(wat) and (TopActCode<>wat.ID) then try
      Cache.CScache.Enter;
      TopActCode:= wat.ID; // ���������� ����������� ����� ��� ������
    finally
      Cache.CScache.Leave;
    end;

    if (jj>1) and AllowWeb then // ����� > 1
    if not flFill then // �������� - � ���
      prMessageLOGS(nmProc+': ���������� '+IntToStr(jj)+
        ' ������.���.`��� ������`, ��� ���������� N '+wat.Num, fLogCache)
    else try  // ��� �������� - ������
      Strings:= TStringList.Create;
      Strings.Add('������ ������� �������� ���');
      Strings.Add(' ');
      Strings.Add('���������� ��������� ('+IntToStr(jj)+
                  ') ����������� ���������� ����� `��� ������`,');
      Strings.Add('��� ���������� �������� N '+wat.Num);
      n:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ���������� � ���
      n:= n_SysMailSend(n, '��������� �� ������� ���', Strings, nil, cNoReplayEmail, '', true);
      if (n<>'') and (Pos(MessText(mtkErrMailToFile), n)>0) then begin  // ���� �� �������� � ����
        Strings.Insert(0, GetMessageFromSelf);
        Strings.Add(#10'����� ������:'#10+n); // ��������� ����� ������ 1-� �������� � ���������� �������
        n:= n_SysMailSend(Cache.GetConstEmails(pcEmplORDERAUTO),
            MessText(mtkErrSendMess, '�� ������� ���'), Strings, nil, '', '', true);
        if (n<>'') then prMessageLOGS(nmProc+': '+n+#10+
          MessText(mtkErrSendMess, '�������')+#10'����� ������: '+Strings.Text, fLogCache);
      end;
    finally
      prFree(Strings);
    end;

//////////////////////////////////////////////////////////// ����������� �������
    ilst.Clear;
    if not flFill then for i:= ProductLines.Count-1 downto 0 do begin
      ProductLine:= TProductLine(ProductLines[i]);
      if not Assigned(ProductLine) then Continue;
      Cache.CScache.Enter;
      try
        ProductLine.State:= False;
      finally
        Cache.CScache.Leave;
      end;
    end; // if not flFill ... for

    ibs.SQL.Clear;
    ibs.SQL.Text:= 'select AnDtCode, AnDtName from analitdict'+
      ' where andtmastercode='+Cache.GetConstItem(pcMotulProdLineAndtCode).StrValue;
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('AnDtCode').AsInteger;
      s:= ibs.fieldByName('AnDtName').AsString;

      ProductLine:= ProductLines.GetProductLine(i);
      Cache.CScache.Enter;
      try
        if Assigned(ProductLine) then begin
          ProductLine.Name:= s;
          ProductLine.State:= True;
        end else begin
          ProductLine:= TProductLine.Create(i, s, True);
          ProductLines.Add(ProductLine);
        end;
      finally
        Cache.CScache.Leave;
      end;
      if flDebug or AllowWebarm then
        iLst.Add(i); // �������� ���� ���������� ����.������ ��� ������
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;

    if not flFill then for i:= ProductLines.Count-1 downto 0 do begin
      ProductLine:= TProductLine(ProductLines[i]);
      if not ProductLine.State then try
        Cache.CScache.Enter;
        ProductLines.Delete(i);  // TObjectList ��� ������� �������
//          prFree(ProductLine);
      finally
        Cache.CScache.Leave;
      end;
    end; // if not flFill ... for
    Cache.CScache.Enter;
    try
      ProductLines.SortList(DirNameSortCompare);
    finally
      Cache.CScache.Leave;
    end;
{if flDebug then for i:= 0 to ProductLines.Count-1 do begin
  ProductLine:= TProductLine(ProductLines[i]);
  prMessageLOGS('----- ProductLine: '+fnMakeAddCharStr(ProductLine.Name, 30, True), fLogDebug, false); // debug
end;  }

    try
      ibdOrd:= cntsORD.GetFreeCnt;
      ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibsOrd_'+nmProc, -1, tpRead, True);

      if flDebug or AllowWebarm then try //----------------- ������� PrLiOPTIONS
        Strings:= TStringList.Create;
        ibsOrd.SQL.Text:= 'select lploPrLine, lploARHIVED from PrLiOPTIONS';
        ibsOrd.ExecQuery;
        while not ibsOrd.Eof do begin
          i:= ibsOrd.fieldByName('lploPrLine').AsInteger;
          n:= ibsOrd.fieldByName('lploARHIVED').AsString;
          s:= IntToStr(i);
          jj:= iLst.IndexOf(i);
          if (jj<0) then begin
            if (n='F') then
              Strings.Add(' update PrLiOPTIONS set lploARHIVED="T" where lploPrLine='+s+';');
          end else begin
            if (n='T') then
              Strings.Add(' update PrLiOPTIONS set lploARHIVED="F" where lploPrLine='+s+';');
            iLst.Delete(jj);
          end;
          cntsORD.TestSuspendException;
          ibsOrd.Next;
        end;
        ibsOrd.Close;

        for i:= 0 to iLst.Count-1 do
          Strings.Add(' update or insert into PrLiOPTIONS (lploPrLine, lploARHIVED)'+
                      ' values ('+IntToStr(iLst[i])+', "F") matching (lploPrLine);');

        if (Strings.Count>0) then try try //----------- ���� ���� - ����� � ����
          fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
          jj:= 0;
          repeat
            ibsOrd.Close;
            ibsOrd.SQL.Clear;
            for i:= jj to Strings.Count-1 do
              // �� 50 ����� (100 �� ����: Dynamic SQL Error Too many Contexts)
              if (ibsOrd.SQL.Count>50) then break
              else ibsOrd.SQL.Add(Strings[i]);
            if (ibsOrd.SQL.Count>0) then begin
              jj:= jj+ibsOrd.SQL.Count;
              ibsOrd.SQL.Insert(0, 'execute block as begin');
              ibsOrd.SQL.Add(' end');
              ibsOrd.ExecQuery;
            end else jj:= -1;
          until (jj<0);
          ibsOrd.Transaction.Commit;
        except
          on E: Exception do prMessageLOGS(nmProc+'_PrLiOPTIONS_edit: '+E.Message, fLogCache);
        end;
        finally
          ibsOrd.Close;
          fnSetTransParams(ibsOrd.Transaction, tpRead, True);
        end;
      finally
        prFree(Strings);
      end;
      //------------------------- �������� ������������ � ������� �� PrLiOPTIONS
      for i:= ProductLines.Count-1 downto 0 do begin
        ProductLine:= TProductLine(ProductLines[i]);
        if not Assigned(ProductLine) then Continue;
        Cache.CScache.Enter;
        try
          ProductLine.State:= False;
        finally
          Cache.CScache.Leave;
        end;
      end; // for
      ibsOrd.SQL.Text:= 'select lploPrLine, lploHASAUTO, lploHASMOTO, lploHASCV,'+
                        ' lploHASAX from PrLiOPTIONS where lploARHIVED="F"';
      ibsOrd.ExecQuery;
      while not ibsOrd.Eof do begin
        i:= ibsOrd.fieldByName('lploPrLine').AsInteger;
        ProductLine:= ProductLines.GetProductLine(i);
        if Assigned(ProductLine) then try
          Cache.CScache.Enter;
          ProductLine.HasModelAuto:= GetBoolGB(ibsOrd, 'lploHASAUTO'); // Auto
          ProductLine.HasModelMoto:= GetBoolGB(ibsOrd, 'lploHASMOTO'); // Moto
          ProductLine.HasModelCV:= GetBoolGB(ibsOrd, 'lploHASCV');     // ����������
          ProductLine.HasModelAx:= GetBoolGB(ibsOrd, 'lploHASAX');     // ����
          ProductLine.State:= True;
        finally
          Cache.CScache.Leave;
        end;
        cntsORD.TestSuspendException;
        ibsOrd.Next;
      end;
      ibsOrd.Close;

      for i:= ProductLines.Count-1 downto 0 do begin
        ProductLine:= TProductLine(ProductLines[i]);
        if not Assigned(ProductLine) then Continue;
        if ProductLine.State then Continue;
        Cache.CScache.Enter;
        try
          ProductLine.HasModelAuto:= False;
          ProductLine.HasModelMoto:= False;
          ProductLine.HasModelCV:= False;
          ProductLine.HasModelAx:= False;
        finally
          Cache.CScache.Leave;
        end;
      end; // if not flFill ... for
    finally
      prFreeIBSQL(ibsOrd);
      cntsORD.SetFreeCnt(ibdOrd, True);
    end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'_'+s+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+'_'+str+': '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ibs);
    cntsGRB.SetFreeCnt(ibd, True);
    SetLength(ar, 0);
    prFree(lst);
    prFree(ilst);
    prMessageLOGS(nmProc+': '+GetLogTimeStr(TimeProc), fLogCache, false);
  end;
  TestCssStopException;
end;
//================================================= ������������ ������ ��������
function TDataCache.GetShipMethodName(smID: Integer): string;
begin
  Result:= '';
  if not Assigned(self) or not ShipMethods.ItemExists(smID) then Exit;
  Result:= GetDirItemName(ShipMethods[smID]);
end;
//==================================== ������� ������� ������� � ������ ��������
function TDataCache.GetShipMethodNotTime(smID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not ShipMethods.ItemExists(smID) then Exit;
  Result:= not TShipMethodItem(ShipMethods[smID]).TimeKey;
end;
//=================================== ������� ������� �������� � ������ ��������
function TDataCache.GetShipMethodNotLabel(smID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not ShipMethods.ItemExists(smID) then Exit;
  Result:= not TShipMethodItem(ShipMethods[smID]).LabelKey;
end;
//================================================ ������������ ������� ��������
function TDataCache.GetShipTimeName(stID: Integer): string;
begin
  Result:= '';
  if not Assigned(self) or not ShipTimes.ItemExists(stID) then Exit;
  Result:= GetDirItemName(ShipTimes[stID]);
end;
//====== ������������� ������ ������� �������� �� ������ ��� ���� (Objects - ID)
function TDataCache.GetShipMethodsList(dprt: Integer=0): TStringList; // must Free
var i, id: Integer;
    s: String;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  if dprt<1 then begin // ���
    with ShipMethods do for i:= 0 to ItemsList.Count-1 do begin
      s:= GetDirItemName(ItemsList[i]);
      id:= GetDirItemID(ItemsList[i]);
      Result.AddObject(s, Pointer(id));
    end;
    Exit;
  end;
  if not DprtExist(dprt) then Exit;            // �� ������
  with arDprtInfo[dprt].ShipLinks do for i:= 0 to ListLinks.Count-1 do begin
    s:= GetLinkName(ListLinks[i]);
    id:= GetLinkID(ListLinks[i]);
    Result.AddObject(s, Pointer(id));
  end;
end;
//============================================= ������������ ������� SMS �� ����
function TDataCache.GetSMSmodelName(smsmID: Integer): String;
var i: Integer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if (SMSmodelsList.Count<1) then Exit;
  for i:= 0 to SMSmodelsList.Count-1 do
    if (Integer(SMSmodelsList.Objects[i])=smsmID) then begin
      Result:= SMSmodelsList[i];
      Exit;
    end;
end;
//========================== ������������� ������ ������ �������� (Objects - ID)
function TDataCache.GetShipTimesList: TStringList; // must Free
var i, id: Integer;
    s: String;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  with ShipTimes do for i:= 0 to ItemsList.Count-1 do begin
    s:= GetDirItemName(ItemsList[i]);
    id:= GetDirItemID(ItemsList[i]);
    Result.AddObject(s, Pointer(id));
  end;
end;
//========================================= ������������ �������� �� ���� ������
function TDataCache.GetWareProductName(wareID: Integer): String;
var i, pID: Integer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if (WareProductList.Count<1) then Exit;
  if not WareExist(wareID) then Exit;
  pID:= arWareInfo[wareID].Product;
  if (pID<1) then Exit;
  for i:= 0 to WareProductList.Count-1 do
    if (Integer(WareProductList.Objects[i])=pID) then begin
      Result:= WareProductList[i];
      Exit;
    end;
end;
//======================================================= �������� ���� ��������
procedure TDataCache.TestParConstants(flFill: Boolean=True; alter: boolean=False);
// alter=True - �� alter-��������, False - ������
const nmProc = 'TestParConstants'; // ��� ���������/�������
var i, j: integer;
    s: string;
    ibs: TIBSQL;
    ibd: TIBDatabase;
    flnew: boolean;
    Item: Pointer;
    ars: Tas;
//    curr: Double;
begin
  if not Assigned(self) then Exit;
  if alter then s:= 'alter' else s:= 'full';
  ibd:= nil;
  ibs:= nil;
//////////////////////////////////////////////////////////////
  try try
    if flFill then begin
      Item:= TConstItem.Create(0, '�����.��������', 2);
      FParConstants.CheckItem(Item); // ��������� � ���������� 0-� �������
    end{ else FParConstants.SetDirStates(False)};
    try
      ibd:= cntsORD.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibsORD_'+nmProc, -1, tpRead, True);
      ibs.SQL.Text:= 'select * from SERVERPARAMCONSTANTS'; // ������ ��������
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('SPCCODE').asInteger;
        s:= IntToStr(i);
        flnew:= not FParConstants.ItemExists(i);
        if flnew then begin
          Item:= TConstItem.Create(i, ibs.fieldByName('SPCNAME').asString,
            ibs.fieldByName('SPCTYPECODE').asInteger,
            ibs.fieldByName('SPCUSERID').asInteger,
            ibs.fieldByName('SPCPRECISION').asInteger, True); // Links - ����
          FParConstants.CheckItem(Item);                  // ��������� � ����������
        end;
        with GetConstItem(i) do try
          FParConstants.CS_DirItems.Enter;
          if not flnew then begin
            Name     := ibs.fieldByName('SPCNAME').asString;
            ItemType := ibs.fieldByName('SPCTYPECODE').asInteger;
            Precision:= ibs.fieldByName('SPCPRECISION').asInteger;
            LastUser := ibs.fieldByName('SPCUSERID').asInteger;
          end;
          StrValue   := ibs.fieldByName('SPCVALUE').asString;
          maxStrValue:= ibs.fieldByName('SPCmaxVALUE').asString;
          minStrValue:= ibs.fieldByName('SPCminVALUE').asString;
          NotEmpty   := GetBoolGB(ibs, 'SPCnotEmptyValue');
          LastTime   := ibs.fieldByName('SPCTIME').AsDateTime; // ����� ����.���������
          Grouping   := ibs.fieldByName('SPCGROUP').asString;
        finally
          FParConstants.CS_DirItems.Leave;
        end;
        cntsORD.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
    finally
      prFreeIBSQL(ibs);
      cntsORD.SetFreeCnt(ibd);
    end;
//    if not flFill then FParConstants.DelDirNotTested; // �������� ������������
    FParConstants.CheckLength;

    //-------------- ������ ��� ������� � ��������� ������ (SysMailSend)
    VSMail.CheckXstring(GetConstItem(pcX_section).StrValue, GetConstItem(pcX_value).StrValue);

    //--------------  ������ ����� ��������� ���������� (����, �������� � �.�.)
    s:= GetConstItem(pcFictiveEmplCodes).StrValue;
    ars:= fnSplitString(S, ',');
    CScache.Enter;
    try
      if Length(ars)<>Length(arFictiveEmpl) then SetLength(arFictiveEmpl, Length(ars));
      for i:= 0 to High(ars) do begin
        j:= StrToIntDef(ars[i], 0);
        if arFictiveEmpl[i]<>j then arFictiveEmpl[i]:= j;
      end;
    finally
      CScache.Leave;
    end;

    //-----------------------------------------------------  ��� ������ ��������
    pgrDeliv:= GetConstItem(pcDeliveriesMasterCode).IntValue;

    //----------  ������������� ���������� �������� �����������: 0- ���, 1- ����
    flBlockUber:= (Cache.GetConstItem(pcBlockFinalClient).IntValue=1);

///////////////////////////////////////////////////////////////////////// ������
{    s:= GetConstItem(pcUsedPriceTypes).StrValue;
    if s<>'' then try
      ars:= fnSplitString(s, ',');
      j:= Length(ars);
      CScache.Enter;
      try
        if Length(PriceTypes)<j then SetLength(PriceTypes, j);
        for i:= 0 to High(ars) do begin
          ii:= StrToIntDef(ars[i], 0);
          if (ii>0) and (PriceTypes[i]<>ii) then PriceTypes[i]:= ii;
        end;
        if Length(PriceTypes)>j then SetLength(PriceTypes, j);
      finally
        CScache.Leave;
      end;
    finally
      SetLength(ars, 0);
    end;    }
    if (Length(PriceTypes)<1) then begin // ������������
      SetLength(PriceTypes, 1);
      PriceTypes[0]:= 1;
    end;

    //--------------- Email ����������� ��� ����� �� ��� (no.reply@vladislav.ua)
    cNoReplayEmail:= Cache.GetConstItem(pcEmailFromBySVK).StrValue;
    //--------------------------------------- ��������� Email (xyz@vladislav.ua)
    cFictiveEmail:= Cache.GetConstItem(pcFictiveEmail).StrValue;
    //--------------------------- ����� ����� � ������ ���������� ������� (5-50)
    FormingOrdersLimit:= Cache.GetConstItem(pcFormingOrdersLimit).IntValue;
    if (FormingOrdersLimit<5) then FormingOrdersLimit:= 5;
    //------------------ ����� ����� � ������ �������, 0- �� ��������� ��� >= 20
    OrderListLimit:= Cache.GetConstItem(pcOrderListLimit).IntValue;
    if (OrderListLimit>0) and (OrderListLimit<20) then OrderListLimit:= 20;

  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'_'+s+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+'_'+s+': '+E.Message, fLogCache);
  end;
  finally
    SetLength(ars, 0);
  end;
  TestCssStopException;
end;
//============================================== ����������/�������� �����������
procedure TDataCache.TestEmpls(pEmplID: Integer; FillNew: boolean=True;
          CompareTime: boolean=True; TestEmplFirms: boolean=False);
const nmProc = 'TestEmpls'; // ��� ���������/�������
type
  TUserGBInfo = record //----- ��� ���������� USERLIST
    UserLogin: string;    // ����� Grossbee
    UserMail : string;    // Email ����������
  end;
var UserCode, s: string;
    i, j, iw, iCount, iUser, iORDERAUTO: integer;
    roles{, rules}: Tai;
    flfill, flnew: boolean;
    userslist: array of TUserGBInfo;
    LocalStart, dd: TDateTime;
    ibs: TIBSQL;
    ibd: TIBDatabase;
    Item, Item1: Pointer;
begin
  iCount:= 0;
  if not Assigned(self) then Exit;
  if (pEmplID>0) and EmplExist(pEmplID) and (CompareTime and
    (Now<IncMinute(arEmplInfo[pEmplID].LastTestTime, ClientActualInterval))) then Exit;
  ibd:= nil;
  ibs:= nil;
  flfill:= length(arEmplInfo)<2;
//  SetLength(rules, 0);
  SetLength(roles, 0);
  SetLength(userslist, 0);
  iORDERAUTO:= 0;
//  try
  try
    if pEmplID<0 then UserCode:= 'alter'
    else if pEmplID>0 then UserCode:= IntToStr(pEmplID)
    else UserCode:= fnIfStr(flfill, 'fill_', 'test_')+'full';
    LocalStart:= now();
    try try                                      // ��������� ������ �� Grossbee
      ibd:= cntsGRB.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc+'_'+UserCode, -1, tpRead, True);
      s:= 'Select EMPLCODE, EMPLMANCODE, EMPLARCHIVE,'+
          ' MANLASTNAME, MANNAME, MANPATRONYMICNAME, MANARCHIVE, MANWORKEMAIL,'+
          ' (select first 1 cl.CNUNLNFACCCODE from ControlUnitLink cl'+
          ' where cl.CnUnLnControlUnitCode=(select BKE.andtCode from AnalitDict BKE'+
          ' where BKE.AnDtAnalitTypeCode=(select AntpCode from AnalitType'+
          ' where AntpLinkDictType=130) and BKE.AnDtMasterDict=(select ea.andtCode'+
          ' from AnalitDict ea where ea.AnDtAnalitTypeCode=(select ancoanalittypecode'+
          ' from analitconformity where ancoobjecttype=184)'+
          ' and ea.AnDtMasterDict=e.emplmancode)) and "TODAY" between cl.CnUnLnStartDate'+
          ' and cl.CnUnLnStopDate order by cl.cnunlnstartdate desc) Facc'+
          ' FROM EMPLOYEES e inner join MANS on EMPLMANCODE=MANCODE';
      if pEmplID<0 then begin                            // �� alter-��������

      end else if pEmplID=0 then begin                    // ������ ��������
        ibs.SQL.Text:= s;
      end else begin                                 // 1 ���������
        ibs.SQL.Text:= s+' where EMPLCODE='+UserCode;
      end;
      iORDERAUTO:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;

      ibs.ExecQuery;       // ��������� ������ ����������� �� EMPLOYEES, MANS Grossbee
      while not ibs.Eof do begin
        i:= ibs.fieldByName('EMPLCODE').AsInteger;
        j:= ibs.fieldByName('Facc').AsInteger; // ��� �������� �� �����������
        flnew:= FillNew;
        if TestCacheArrayItemExist(taEmpl, i, flnew) then with arEmplInfo[i] do try
          CS_Empls.Enter;
          try
            ManID     := ibs.fieldByName('EMPLMANCODE').AsInteger;
            Name      := fnChangeEndOfStrBySpace(ibs.fieldByName('MANNAME').AsString);
            Surname   := fnChangeEndOfStrBySpace(ibs.fieldByName('MANLASTNAME').AsString);
            Patronymic:= fnChangeEndOfStrBySpace(ibs.fieldByName('MANPATRONYMICNAME').AsString);
            Mail      := fnChangeEndOfStrBySpace(trim(ibs.fieldByName('MANWORKEMAIL').AsString));
            Arhived   := GetBoolGB(ibs, 'EMPLARCHIVE') or GetBoolGB(ibs, 'MANARCHIVE')
                         or ((i<>iORDERAUTO) and (j<1));
//              if not fnCheckEmail(Mail) then
//                if flDebug then prMessageLOGS(nmProc+'_empl'+IntToStr(j)+': not correct Email '+Mail, fLogDebug);
            if Arhived then begin // � ��������/��������� �������� ������
              ServerLogin:= '';
              GBLogin:= '';
              GBReportLogin:= '';
              Session:= '';
            end;
            LastTestTime:= Now;
            if pEmplID=0 then inc(iCount);
          finally
            CS_Empls.leave;
          end;
        except
          on E: Exception do prMessageLOGS(nmProc+'_'+IntToStr(i)+'g: '+E.Message, fLogCache);
        end;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
                                    // ��������� ������ �� USERLIST Grossbee
      ibs.SQL.Text:= 'select USLSCODE, USLSUSERID, USLSEMAIL'+  // , USRLVISIBLEGROUPCODE
                     ' from USERLIST left join USERROLES on USRLCODE=USLSROLECODE'+
                               // ���������� � ���� <> "�������� ������������"
                     ' where uslsarchive="F" and usrlcode<>21 order by USLSCODE desc';
      ibs.ExecQuery; // �������� ������������ ����� ������ ���� ���������
      while not ibs.Eof do begin
        i:= ibs.fieldByName('USLSCODE').AsInteger;
        if High(userslist)<i then begin // ������ ���������� 1 ���
          iw:= Length(userslist);
          SetLength(userslist, i+1);
          for j:= iw to High(userslist) do with userslist[j] do begin
            UserLogin:= '';
            UserMail := '';
          end;
        end;
        with userslist[i] do begin
          UserLogin:= fnChangeEndOfStrBySpace(ibs.fieldByName('USLSUSERID').AsString);
          UserMail := fnChangeEndOfStrBySpace(ibs.fieldByName('USLSEMAIL').AsString);
        end;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
      if ibs.Transaction.InTransaction then ibs.Transaction.Rollback;
    except
      on E: EBOBError do raise EBOBError.Create(nmProc+'_'+UserCode+': '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
    end;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(ibd);
    end;
    TestCssStopException;

    if (pEmplID in [0, iORDERAUTO]) and not EmplExist(iORDERAUTO) then begin //  empl - ORDERAUTO
      flnew:= FillNew;
      if TestCacheArrayItemExist(taEmpl, iORDERAUTO, flnew) then with arEmplInfo[iORDERAUTO] do try
        CS_Empls.Enter;
        ManID     := 0;
        Surname   := 'ORDERAUTO';  //        Name      := 'ORDERAUTO';
        Patronymic:= '';
        Mail      := '';
        Arhived   :=  False;
        LastTestTime:= Now;
      finally
        CS_Empls.leave;
      end;
    end;
    TestCssStopException;

    try try                                     // ��������� ������ �� css_ord
      ibd:= cntsOrd.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc+'_'+UserCode, -1, tpRead, True);
      s:= 'Select EMPLCODE, EMPLDPRTCODE, EMPLLOGIN, EMPLPASS,'+
          ' EMPLRESETPASWORD, EMPLGBUSER, EMPLGBREPORTUSER, EMRLROLECODE,'+
          ' EMPLSESSIONID, EMPLLASTACTION, EMPLBLOCK, EMPLDISABLEOUT'+
          ' FROM EMPLOYEES left join EMPLOYEESROLES on EMRLEMPLCODE=EMPLCODE';
      if pEmplID<0 then begin                             // �� alter-��������

      end else if pEmplID=0 then begin                    // ������ ��������
        s:= s+' order by EMPLCODE, EMRLROLECODE';
      end else begin                                      // 1 ���������
        s:= s+' where EMPLCODE='+UserCode+' order by EMRLROLECODE';
      end;
      ibs.SQL.Text:= s;
      ibs.ExecQuery;                  // ��������� ������ ����������� �� dbOrd
      while not ibs.Eof do begin
        cntsORD.TestSuspendException;
        i:= ibs.fieldByName('EMPLCODE').AsInteger;
        if not EmplExist(i) or arEmplInfo[i].Arhived then begin // �������� �� ���������
          TestCssStopException;
          while not ibs.Eof and (i=ibs.fieldByName('EMPLCODE').AsInteger) do ibs.Next;
          Continue;
        end;
//          iUser:= 0;
        with arEmplInfo[i] do try try   // ������������ ������ ���������
          CS_Empls.Enter;
          ServerLogin:= ibs.fieldByName('EMPLLOGIN').AsString;
          USERPASSFORSERVER:= ibs.fieldByName('EMPLPASS').AsString;
          Session:= ibs.fieldByName('EMPLSESSIONID').AsString;
          dd:= ibs.fieldByName('EMPLLASTACTION').AsDateTime;
          if (dd>DateNull) and (LastActionTime<>dd) then LastActionTime:= dd;
          EmplDprtID:= ibs.fieldByName('EMPLDPRTCODE').AsInteger;  // ����
          RESETPASSWORD:= GetBoolGB(ibs, 'EMPLRESETPASWORD');
          Blocked:= (ibs.fieldByName('EMPLBLOCK').AsInteger>0);
          DisableOut:= GetBoolGB(ibs, 'EMPLDISABLEOUT');

          iUser:= ibs.fieldByName('EMPLGBUSER').AsInteger;
          if (iUser>0) and (length(userslist)>iUser) then begin
            s:= userslist[iUser].UserLogin;
            if (s<>'') and (GBLogin<>s) then GBLogin:= s;
            s:= userslist[iUser].UserMail;
            if (s<>'') and (Mail='') then Mail:= s; // ??? ���� ��� ORDERAUTO
          end; // else iUser:= 0;
          j:= ibs.fieldByName('EMPLGBREPORTUSER').AsInteger;
          if (j>0) and (length(userslist)>j) then begin
            s:= userslist[j].UserLogin;
            if (s<>'') and (GBReportLogin<>s) then GBReportLogin:= s;
          end;
          LastTestTime:= Now;
        except
          on E: Exception do prMessageLOGS(nmProc+'_'+IntToStr(i)+'o: '+E.Message, fLogCache);
        end;
        finally
          CS_Empls.leave;
        end;

        SetLength(roles, 0);
        while not ibs.Eof and (i=ibs.fieldByName('EMPLCODE').AsInteger) do begin
          prAddItemToIntArray(ibs.fieldByName('EMRLROLECODE').AsInteger, roles);
          ibs.Next;
        end;

        arEmplInfo[i].TestUserRoles(roles); // ��������� ����
        TestCssStopException;
      end;
      ibs.Close;

      if (pEmplID=0) then begin
        i:= 0;
        try
          if not flfill then FEmplRoles.SetDirStates(False); // ������ �����
          ibs.SQL.Text:= 'Select ROLECODE, ROLENAME FROM ROLES';
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('ROLECODE').AsInteger;
            s:= ibs.fieldByName('ROLENAME').AsString;
            Item:= TEmplRole.Create(i, s);
            FEmplRoles.CheckItem(Item);          // ��������� � ����������
            cntsORD.TestSuspendException;
            ibs.Next;
          end;
          ibs.Close;
          if not flfill then FEmplRoles.DelDirNotTested;
          FEmplRoles.CheckLength;
        except
          on E: Exception do prMessageLOGS(nmProc+'_'+IntToStr(i)+'rol: '+E.Message, fLogCache);
        end;
        i:= 0;
        try
          if not flfill then FImportTypes.SetDirStates(False); // ������ ����� �������
          ibs.SQL.Text:= 'select IMTPCODE, IMTPNAME, IMTPREPORT, IMTPIMPORT from ImportTypes';
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('IMTPCODE').AsInteger;
            s:= ibs.fieldByName('IMTPNAME').AsString;
            if not FImportTypes.ItemExists(i) then begin
              Item:= TImportType.Create(i, s,
                GetBoolGB(ibs, 'IMTPREPORT'), GetBoolGB(ibs, 'IMTPIMPORT'));
              FImportTypes.CheckItem(Item);       // ��������� � ����������
            end else with TImportType(FImportTypes[i]) do begin
              Name:= s;
              ApplyReport:= GetBoolGB(ibs, 'IMTPREPORT');
              ApplyImport:= GetBoolGB(ibs, 'IMTPIMPORT');
              State:= True;
            end;
            cntsORD.TestSuspendException;
            ibs.Next;
          end;
          ibs.Close;
          if not flfill then FImportTypes.DelDirNotTested;
          FImportTypes.CheckLength;
        except
          on E: Exception do prMessageLOGS(nmProc+'_'+IntToStr(i)+'imp: '+E.Message, fLogCache);
        end;

        try
          ibs.SQL.Text:= 'select LITRIMTPCODE, LITRROLECODE,'+ // ������ ����� ������� � ������
            ' LITRAllowRep, LITRAllowImp from LINKIMPTYPEROLE';
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('LITRIMTPCODE').asInteger; // ��� �������
            j:= ibs.fieldByName('LITRROLECODE').asInteger; // ����
            if FImportTypes.ItemExists(i) and FEmplRoles.ItemExists(j) then begin
              iw:= GetLinkSrcFromRepImpAllow(GetBoolGB(ibs, 'LITRAllowRep'),
                GetBoolGB(ibs, 'LITRAllowImp')); // SrcID= 1- �����, 2- ������, 3- ����� + ������
              Item:= FImportTypes[i];
              Item1:= FEmplRoles[j];
              TImportType(Item).RoleLinks.CheckLink(j, iw, Item1);
              TEmplRole(Item1).ImpLinks.CheckLink(i, iw, Item);
            end;
            cntsORD.TestSuspendException;
            ibs.Next;
          end;
          ibs.Close;
        except
          on E: Exception do prMessageLOGS(nmProc+'_'+IntToStr(i)+'li: '+E.Message, fLogCache);
        end;

        try // ������ �������� ����������� ������, � TestSmallDirectories
          ibs.SQL.Text:= 'select SPCRSPCCODE, SPCRROLECODE, SPCRWRITE'+
            ' from LINKSERVPARCONSTROLE'; // ������ �������� � ������
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('SPCRSPCCODE').asInteger; // ��� �������
            j:= ibs.fieldByName('SPCRROLECODE').asInteger; // ����
            iw:= FnIfInt(GetBoolGB(ibs, 'SPCRWRITE'), 1, 0);
            if FParConstants.ItemExists(i) and FEmplRoles.ItemExists(j) then begin
              TConstItem(FParConstants[i]).Links.CheckLink(j, iw, FEmplRoles[j]);     // SrcID=1 - ������� ���������� ������
              TEmplRole(FEmplRoles[j]).ConstLinks.CheckLink(i, iw, FParConstants[i]); // SrcID=1 - ������� ���������� ������
            end;
            cntsORD.TestSuspendException;
            ibs.Next;
          end;
        except
          on E: Exception do prMessageLOGS(nmProc+'_'+IntToStr(i)+'lc: '+E.Message, fLogCache);
        end;
        ibs.Close;
      end; //  if (ID=0)
      if ibs.Transaction.InTransaction then ibs.Transaction.Rollback;

      j:= Length(arEmplInfo);
      for i:= High(arEmplInfo) downto 1 do if Assigned(arEmplInfo[i]) then begin
        j:= arEmplInfo[i].EmplID+1;
        break;
      end;
      if Length(arEmplInfo)>j then try
        CS_Empls.Enter;
        SetLength(arEmplInfo, j); // �������� �� ���.����
      finally
        CS_Empls.Leave;
      end;
    except
      on E: EBOBError do raise EBOBError.Create(nmProc+'_'+UserCode+': '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
    end;
    finally
      prFreeIBSQL(ibs);
      cntsOrd.SetFreeCnt(ibd);
    end;
  finally
    SetLength(userslist, 0);
    SetLength(roles, 0);
  end;

  if (pEmplID=0) then begin
    prMessageLOGS(nmProc+'_'+UserCode+' '+IntToStr(iCount)+' ����: - '+
      GetLogTimeStr(LocalStart), fLogCache, false);
    if TestEmplFirms then begin
      TestFirms(0, FillNew, CompareTime, True);
      TestClients(0, FillNew, CompareTime, True);
    end;
  end else if (pEmplID>0) and TestEmplFirms then
    TestFirms(0, FillNew, CompareTime, True, pEmplID); // �������� ���� ���������
  TestCssStopException;
//---------------------------------------------------------
end;
//=================== �������� ������� ����������� ������/������� �� srcID �����
function GetRepImpAllowFromLinkSrc(srcID: Integer; flReport: Boolean=False): Boolean;
// flReport=True - ��������� ���������� ������, False - ���������� �������
// � ����� - SrcId= 1- �����, 2- ������, 3- ����� + ������
begin
  Result:= False;
  if (srcID<1) then Exit
  else if (srcID=3) then Result:= True
  else if flReport then Result:= (srcID=1)
  else Result:= (srcID=2);
end;
//================= �������� srcID ����� �� ��������� ����������� ������/�������
function GetLinkSrcFromRepImpAllow(RepAllow, ImpAllow: Boolean): Integer;
// � ����� - SrcId= 1- �����, 2- ������, 3- ����� + ������
begin
  Result:= 0;
  if not (RepAllow or ImpAllow) then Exit;
  if RepAllow then Result:= 1;
  if ImpAllow then Result:= Result+2;
end;
//============================================ ��������� ���� ��� ������/�������
function TDataCache.GetRepOrImpRoles(ImpID: Integer; flReport: Boolean=True): Tai; // must Free
// flReport=True - ��������� ���������� �� �����, False - ������
var j: integer;
    link: TLink;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not FImportTypes.ItemExists(impID) then Exit;
  with TImportType(FImportTypes[ImpID]) do
    if Assigned(RoleLinks) then with RoleLinks do for j:= 0 to LinkCount-1 do begin
      link:= ListLinks[j];
      if not GetRepImpAllowFromLinkSrc(link.SrcID, flReport) then Continue;
      prAddItemToIntArray(link.LinkID, Result);
    end;
end;
//================================= ������ ��������� �������/�������� ����������
function TDataCache.GetEmplAllowRepOrImpList(pEmplID: Integer; flReport: Boolean=True): TStringList; // must Free
// flReport=True - ������ �������, False - ��������
const nmProc = 'GetEmplAllowRepOrImpList'; // ��� ���������/�������
var i, j, k: integer;
    s: String;
    empl: TEmplInfoItem;
    rol: TEmplRole;
    lnks: TLinks;
    link: TLink;
    ilst: TIntegerList;
begin
  Result:= fnCreateStringList(True, dupIgnore);
  ilst:= TIntegerList.Create;
  try
    if not Assigned(self) or not EmplExist(pEmplID) then Exit;
    empl:= arEmplInfo[pEmplID];
    for i:= 0 to High(empl.UserRoles) do begin
      k:= empl.UserRoles[i];
      if not RoleExists(k) then Continue;
      rol:= FEmplRoles[k];
      if not Assigned(rol.ImpLinks) then Continue;
      lnks:= rol.ImpLinks;
      for j:= 0 to lnks.ListLinks.Count-1 do begin
        link:= lnks.ListLinks[j];
        k:= link.SrcID;
        if GetRepImpAllowFromLinkSrc(k, flReport) then ilst.Add(link.LinkID);
      end;
    end;
    for i:= 0 to ilst.Count-1 do begin
      j:= ilst[i];
      if not Cache.ImpTypeExists(j) then Continue;
      s:= GetDirItemName(Cache.FImportTypes[j]);
      Result.AddObject(s, Pointer(j));
    end;
  except
    on e: Exception do prMessageLOGS(nmProc+': '+E.Message); // ����� � log
  end;
  prFree(ilst);
end;
//========================================= ��������� ���� �������/�������� ����
function TDataCache.GetRoleAllowRepOrImpList(pRoleID: Integer; flReport: Boolean=True): TStringList; // must Free
const nmProc = 'GetRoleImports'; // ��� ���������/�������
var j, k: integer;
    rol: TEmplRole;
    lnks: TLinks;
    link: TLink;
begin
  Result:= fnCreateStringList(True, dupIgnore);
  try
    if not Assigned(self) or not RoleExists(pRoleID) then Exit;

    rol:= FEmplRoles[pRoleID];
    if not Assigned(rol.ImpLinks) then Exit;

    lnks:= rol.ImpLinks;
    for j:= 0 to lnks.ListLinks.Count-1 do begin
      link:= lnks.ListLinks[j];
      if not Cache.ImpTypeExists(link.LinkID) then Continue;
      k:= link.SrcID;
      if GetRepImpAllowFromLinkSrc(k, flReport) then
        Result.AddObject(GetLinkName(link), Pointer(link.LinkID));
    end;
  except
    on e: Exception do prMessageLOGS(nmProc+': '+E.Message); // ����� � log
  end;
end;
//==================== ������� ������� ����������� �������/�������� � ����������
function TDataCache.GetEmplAllowRepImp(pEmplID: Integer): boolean;
const nmProc = 'GetEmplAllowRepImp'; // ��� ���������/�������
var i, j, k: integer;
    rol: TEmplRole;
    lnks: TLinks;
    link: TLink;
    empl: TEmplInfoItem;
begin
  Result:= False;
  if not Assigned(self) or not EmplExist(pEmplID) then Exit;
  empl:= arEmplInfo[pEmplID];
  try
    for i:= 0 to High(empl.UserRoles) do begin
      k:= empl.UserRoles[i];
      if not RoleExists(k) then Continue;
      rol:= FEmplRoles[k];
      if not Assigned(rol.ImpLinks) then Continue;
      lnks:= rol.ImpLinks;
      for j:= 0 to lnks.ListLinks.Count-1 do begin
        link:= lnks.ListLinks[j];
        Result:= (link.SrcID>0);
        if Result then Exit;
      end;
    end;
  except
    on e: Exception do prMessageLOGS(nmProc+': '+E.Message); // ����� � log
  end;
end;
 //================== �������� ����� ��������� ���������� (����, �������� � �.�.)
function TDataCache.CheckEmplIsFictive(pEmplID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not EmplExist(pEmplID) then Exit;
  Result:= (fnInIntArray(pEmplID, arFictiveEmpl)>-1);
end;
//=============================== �������� ����������� ������/������� ����������  - ������
function TDataCache.CheckEmplImpType(pEmplID, impID: Integer; flReport: Boolean=False): Boolean;
// flReport=True - ��������� ���������� ������, False - ���������� �������
var i, j: integer;
begin
  Result:= False;
  if not Assigned(self) or not EmplExist(pEmplID) or not FImportTypes.ItemExists(impID) then Exit;

  with arEmplInfo[pEmplID] do for i:= 0 to High(UserRoles) do begin
    j:= UserRoles[i];
    if RoleExists(j) then with TEmplRole(FEmplRoles[j]) do
      if Assigned(ImpLinks) then with ImpLinks do begin
        Result:= LinkExists(impID) and
          GetRepImpAllowFromLinkSrc(GetLinkSrc(Items[impID]), flReport);
        if Result then exit;
      end;
  end;
end;
//================== ���������� TStringList (Objects-ID ConstItem) Grouping+Name
function EmplConstSortCompareSL(List: TStringList; Index1, Index2: Integer): Integer;
var s1, s2: String;
begin
  with List do try
    with Cache.GetConstItem(Integer(Objects[Index1])) do s1:= Grouping+Name;
    with Cache.GetConstItem(Integer(Objects[Index2])) do s2:= Grouping+Name;
    Result:= AnsiCompareText(s1, s2);
  except
    Result:= 0;
  end;
end;
//=============================================== ��������� ��������� ����������
function TDataCache.GetEmplConstants(pEmplID: Integer): TStringList; // must Free
var i, j, k: integer;
begin
  Result:= fnCreateStringList(True, dupIgnore);
  if not Assigned(self) or not EmplExist(pEmplID) then Exit;
  try
    with arEmplInfo[pEmplID] do for i:= 0 to High(UserRoles) do begin
      k:= UserRoles[i];
      if RoleExists(k) then with TEmplRole(FEmplRoles[k]) do
        if Assigned(ConstLinks) then with ConstLinks.ListLinks do for j:= 0 to Count-1 do
          Result.AddObject(GetLinkName(items[j]), Pointer(GetLinkID(items[j])));
    end;
  except
  end;
  if Result.Count<2 then exit;

  Result.Sorted:= False;
  Result.CustomSort(EmplConstSortCompareSL);
end;
//==================================== �������� ����������� ��������� ����������
function TDataCache.CheckEmplConstant(pEmplID, constID: Integer; var errmess: string; CheckWrite: Boolean=False): Boolean;
// CheckWrite=True - ��������� ���������� �� ������ (� ����� - SrcId=1)
var i, j: integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  errmess:= '';
  if not EmplExist(pEmplID) then errmess:= MessText(mtkNotEmplExist)
  else if not FParConstants.ItemExists(constID) then errmess:= MessText(mtkNotValidParam);
  if errmess<>'' then Exit;

  with arEmplInfo[pEmplID] do for i:= 0 to High(UserRoles) do begin
    j:= UserRoles[i];
    if RoleExists(j) then with TEmplRole(FEmplRoles[j]) do
      if Assigned(ConstLinks) then with ConstLinks do begin
        Result:= LinkExists(constID) and (not CheckWrite or (GetLinkSrc(Items[constID])=1));
        if Result then exit;
      end;
  end;
  if not Result then errmess:= MessText(mtkNotRightExists);
end;
//========================================= ���-�� ��������� �������� ����������
function TDataCache.GetEmplConstantsCount(pEmplID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or not EmplExist(pEmplID) then Exit;
  with GetEmplConstants(pEmplID) do try
    Result:= Count;
  finally Free; end;
end;
//============================ ������ ������� ���������-������ ����� �����������
function TDataCache.GetConstEmails(pc: Integer; pFirm: Integer=0; pWare: Integer=0): String;
var s: String;
begin
  Result:= GetConstEmails(pc, s, pFirm, pWare);
  s:= '';
end;
//============================ ������ ������� ���������-������ ����� �����������
function TDataCache.GetConstEmails(pc: Integer; var mess: String; pFirm: Integer=0; pWare: Integer=0): String;
// � mess ���������� ��������� � ����������� �������
var ar: Tai;
//    index: Integer;
begin
  Result:= '';
  mess:= '';
  if not Assigned(self) or not ConstExists(pc) then Exit;
  try
    ar:= GetConstEmpls(pc);
    if length(ar)<1 then exit;
{                                 // ������� ���-����
    if (length(ar)>1) and FirmExist(pFirm) and arFirmInfo[pFirm].IsMOTOFirm
      and not arFirmInfo[pFirm].IsAUTOFirm then begin
      index:= fnInIntArray(ceFilialROP, ar);
      prDelItemFromArray(index, ar);
    end; }

    if length(ar)<1 then exit;
    Result:= GetEmplEmails(ar, mess, pFirm, pWare);
  finally
    SetLength(ar, 0);
  end;
end;
//================================= ������ ����� ����������� �� ���������-������
function TDataCache.GetConstEmpls(pc: Integer): Tai; // must Free
var emplID, i, iCount: Integer;
    s: string;
    ars: Tas;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not ConstExists(pc) then Exit;
  s:= GetConstItem(pc).StrValue;
  if (s='') then Exit;
  ars:= fnSplitString(s, ',');
  SetLength(Result, Length(ars));
  iCount:= 0;
  try
    for i:= 0 to High(ars) do if ars[i]<>'' then try
      emplID:= StrToIntDef(ars[i], 0);
      if fnInIntArray(emplID, Result)>-1 then Continue; // ��������� �� ������
      if (emplID>0) then begin // ���� emplID>0 - ��������� ����������
        if not EmplExist(emplID) then TestEmpls(emplID);
        if not EmplExist(emplID) then Continue;
      end;
      Result[iCount]:= emplID;
      inc(iCount);
    except
      on E: Exception do prMessageLOGS('Cache.GetConstEmpls: '+E.Message);
    end;
    if Length(Result)>iCount then SetLength(Result, iCount);
  finally
    SetLength(ars, 0);
  end;
end;
//=================================================== ������ ������� �����������
function TDataCache.GetEmplEmails(empls: Tai; pFirm: Integer=0; pWare: Integer=0;
                    pSys: Integer=0; pRegion: Integer=0): String;
const nmProc = 'GetEmplEmails';
var s: string;
begin
  Result:= GetEmplEmails(empls, s, pFirm, pWare, pSys, pRegion);
  s:= '';
end;
//=================================================== ������ ������� �����������
function TDataCache.GetEmplEmails(empls: Tai; var mess: String; pFirm: Integer=0;
                    pWare: Integer=0; pSys: Integer=0; pRegion: Integer=0): String;
// � mess ���������� ��������� � ����������� �������
const nmProc = 'GetEmplEmails';
var emplID, i, j, jj: Integer;
    ar, arCodes, arFirmCodes, arFil: Tai;
    Firm: TFirmInfo;
    Empl: TEmplInfoItem;
    facc: TFiscalCenter;
  //----------------------------------- ���� �����
  function _FindFirm: Boolean;
  begin
    Result:= Assigned(Firm);
    if Result then exit;     // ��� ����� ������
    Result:= (pFirm>0) and FirmExist(pFirm);
    if Result then Firm:= arFirmInfo[pFirm]
    else mess:= mess+fnIfStr(mess='', '', #13#10)+
      MessText(mtkNotFirmExists, IntToStr(pFirm));
  end;
  //----------------------------------- ���� ����������
  function _FindEmpl: Boolean;
  begin
    Result:= False;
    if (emplID<1) then exit;
    if not EmplExist(emplID) then TestEmpls(emplID);
    Result:= EmplExist(emplID);
    if Result then begin
      Empl:= Cache.arEmplInfo[emplID];
      Result:= not Empl.Arhived and not Empl.Blocked;
      if not Result then  mess:= mess+fnIfStr(mess='', '', #13#10)+
        ' ��������� '+Empl.EmplShortName+' (��� '+IntToStr(emplID)+') ������������';
    end else mess:= mess+fnIfStr(mess='', '', #13#10)+
      MessText(mtkNotEmplExist, IntToStr(emplID));
  end;
  //----------------------------------- ��������� ����� � Result
  procedure _AddEmplMail;
  begin
    if (fnInIntArray(Empl.ID, arCodes)>-1) then exit; // ��������� �� ������
    prAddItemToIntArray(Empl.ID, arCodes); // �������� ��� � ������, ���� ��� ��� ���
    if Empl.Mail='' then
      mess:= mess+fnIfStr(mess='', '', #13#10)+MessText(mtkNotFoundEmplMail, Empl.EmplShortName)
    else Result:= Result+fnIfStr(Result='', '', ',')+Empl.Mail;
  end;
  //-----------------------------------
begin
  Result:= '';
  mess:= '';
  if not Assigned(self) or (Length(empls)<1) then Exit;
  SetLength(ar, 0);
  SetLength(arCodes, 0); // ���� �������� ���� ��� �������� �������
  SetLength(arFirmCodes, 0);     // ������ ������/���������� �����
  SetLength(arFil, 0);
  Firm:= nil;
  try
    for i:= 0 to High(empls) do if (empls[i]<>0) then
      prAddItemToIntArray(empls[i], ar); // �������� ��� � ������, ���� ��� ��� ���

    for i:= 0 to High(ar) do try
      if (ar[i]=0) then Continue;
//--------------------------------------------------- ������� ���������� (���>0)
      if (ar[i]>0) then begin
        emplID:= ar[i];
        if _FindEmpl then _AddEmplMail;
        Continue;
      end;
//------------------------------------------ "��������������" ���������� (���<0)
      case ar[i] of
      ceWareProduct: //--------------------------------- �������-�������� ������
        if (pWare>0) and WareExist(pWare) then begin
          emplID:= GetWare(pWare).ManagerID;
          if _FindEmpl then _AddEmplMail;
        end;

      ceSysSaleDirector: begin //------- �������� �� �������� ������-�����������
          EmplID:= GetConstItem(pcEmplSaleDirectorAuto).IntValue;
          if _FindEmpl then _AddEmplMail; // dmitriy.voloshin@vladislav.ua
        end;                              // valeriy.nestjurin@motogorodok.com - ������

      ceSysResponsible:       //--------------- ������������� ������-�����������
        if CheckTypeSys(pSys) then begin
          EmplID:= GetSysTypeEmpl(pSys);
          if _FindEmpl then _AddEmplMail;
        end else begin
          if not _FindFirm then Continue;
          EmplID:= GetSysTypeEmpl(constIsAuto);
          if _FindEmpl then _AddEmplMail;
          EmplID:= GetSysTypeEmpl(constIsMoto);
          if _FindEmpl then _AddEmplMail;
        end;

      ceFirmManager:       //------------------------------ �������� �����������
        if _FindFirm then for j:= 0 to Firm.FirmManagers.Count-1 do begin
          EmplID:= Firm.FirmManagers[j];
          if _FindEmpl then _AddEmplMail;
        end;

      ceFilialROP: begin //-------------------------------- ��� ������� (������)
          SetLength(arFil, 0); // ���� ��� ���-��
          if (pRegion>0) then begin
            if (pRegion>High(Cache.arRegionROPFacc)) then j:= 0
            else j:= Cache.arRegionROPFacc[pRegion];
            if (j>0) then prAddItemToIntArray(j, arFil);
          end else begin // ���� �� ����� ����� - ���� �� ����������
            if not _FindFirm then Continue;
            SetLength(arFirmCodes, 0); // ���� ���
            for j:= 0 to Firm.FirmContracts.Count-1 do begin // ���� ���������� �����
              jj:= Firm.FirmContracts[j];
              if not Cache.Contracts.ItemExists(jj) then Continue;
              pRegion:= Cache.Contracts[jj].FacCenter;
              if (pRegion<1) then Continue;
              prAddItemToIntArray(pRegion, arFirmCodes); //  �������� ���� ���
            end;
            for j:= 0 to High(arFirmCodes) do begin
              jj:= arFirmCodes[j]; // ��� ���
              if not Cache.FiscalCenters.ItemExists(jj) then Continue;
              facc:= Cache.FiscalCenters[jj];
              pRegion:= facc.ROPfacc;         // �������� ���� ��� ���-��
              if (pRegion>0) then prAddItemToIntArray(pRegion, arFil)
              else if facc.IsAutoSale then
                mess:= mess+fnIfStr(mess='', '', #13#10)+'�� ������ ��� ��� ��� ��� '+facc.Name;
            end;
          end;

          for j:= 0 to High(arFil) do begin
            jj:= arFil[j];
            if not Cache.FiscalCenters.ItemExists(jj) then Continue;
            facc:= Cache.FiscalCenters[jj];
            if (facc.BKEempls.Count<1) then
              mess:= mess+fnIfStr(mess='', '', #13#10)+'�� ������ ��������� ��� ��� '+facc.Name
            else for jj:= 0 to facc.BKEempls.Count-1 do begin
              EmplID:= facc.BKEempls[jj];
              if _FindEmpl then _AddEmplMail;
            end;
          end;
        end;

//      ceUIKdepartment: begin //--------------------------------------- ����� ���
//        end;
      end; // case
    except
      on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
    end;
  finally
    SetLength(ar, 0);
    SetLength(arCodes, 0);
    SetLength(arFirmCodes, 0);
    SetLength(arFil, 0);
  end;
end;
{//========================================================= ���� ���-�� ��������
function TDataCache.GetFilialROPcodes(var filials: Tai): Tai;
// ���������� ��������� ���� ���-��, � filials ������� � ���������� ���-��� ��������
const nmProc = 'GetFilialROPcodes';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    i, j: integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  ORD_IBD:= nil;
  try try
   ORD_IBD:= cntsOrd.GetFreeCnt;
   ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    ORD_IBS.SQL.Text:= 'select EMPLCODE, EMPLDPRTCODE from EMPLOYEES'+ //
      ' left join EMPLOYEESROLES on EMRLEMPLCODE=EMPLCODE'+
      ' where EMPLDPRTCODE in ('+fnArrOfIntToString(filials)+')'+
      ' and EMRLROLECODE='+IntToStr(rolSuperRegional)+' group by EMPLCODE, EMPLDPRTCODE';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      i:= ORD_IBS.Fields[0].AsInteger;
      if not EmplExist(i) then TestEmpls(i);
      if EmplExist(i) and not arEmplInfo[i].Arhived then begin
        prAddItemToIntArray(i, Result);
        j:= fnInIntArray(ORD_IBS.Fields[1].AsInteger, filials);
        if (j>-1) then filials[j]:= 0; // �������� ������� � ���������� ���-���
     end;
      ORD_IBS.Next;
    end;
  finally
    prFreeIBSQL(ORD_IBS);
    cntsOrd.SetFreeCnt(ORD_IBD);
  end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end; }
//======================================================
function TDataCache.GetConstItem(csID: Integer): TConstItem;
begin
  if not Assigned(self) or not ConstExists(csID) then Result:= FParConstants[0]
  else Result:= FParConstants[csID];
end;
//===================================================== ����� �������� ���������
function TDataCache.SaveNewConstValue(csID, pUserID: Integer; pValue: String): String;
const nmProc = 'SaveNewConstValue';
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    pLastTime: TDateTime;
    ConstItem: TConstItem;
    iValue, i: Integer;
    list: TStringList;
begin
  Result:= '';
  pLastTime:= Now;
  iValue:= 0;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrEditRecord));
    if not ConstExists(csID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - constID='+IntToStr(csID));

    ConstItem:= FParConstants[csID];
    pValue:= trim(pValue);
    if ConstItem.StrValue=pValue then Exit; // �������� �� ����������

    if ConstItem.NotEmpty and (pValue='') then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - �������� �� ����� ���� ������');

    try //------------------------------------------- ��������� �������� �� ����
      case ConstItem.ItemType of
      constInteger: iValue:= StrToInt(pValue);
      constDouble: begin
          pValue:= StrWithFloatDec(pValue); // ��������� DecimalSeparator
          StrToFloat(pValue);
        end;
      constDateTime: begin
          if ConstItem.Precision=0 then System.SysUtils.StrToDate(pValue)
          else System.SysUtils.StrToDateTime(pValue);
        end;
      end; // case
    except
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ��������='+pValue);
    end;

    if (pValue<>'') then case ConstItem.ID of //--- ��������� �������� �� ������
    pcUIKdepartmentMail, pcCheckDocMail: begin                  // ������
        list:= fnSplit(',', pValue);
        try
          for i:= 0 to list.Count-1 do if not fnCheckEmail(list[i]) then
            raise EBOBError.Create(MessText(mtkNotValidParam)+' - ��������='+list[i]);
        finally prFree(list); end;
      end;

    pcTestingSending1, pcTestingSending2, pcTestingSending3, // ������ ����� �����������
      pcEmpl_list_TmpBlock, pcEmpl_list_FinalBlock, pcEmpl_list_UnBlock,
      pcBlockMonitoringEmpl, pcErrMessMonitoringEmpl, pcEmplID_list_Rep30: begin
        list:= fnSplit(',', pValue);
        try
          for i:= 0 to list.Count-1 do begin
            iValue:= StrToIntDef(list[i], 0);
            if (iValue=0) or ((iValue>0) and not EmplExist(iValue)) or
              ((iValue<0) and ((iValue<Low(ceNames)) or (iValue>High(ceNames)))) then
              raise EBOBError.Create(MessText(mtkNotEmplExist, pValue));
          end;
        finally prFree(list); end;
      end;

    pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto, pcEmplORDERAUTO: // ��� ����������
      if not EmplExist(iValue) then
        raise EBOBError.Create(MessText(mtkNotEmplExist, pValue));
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt; //------------------------------- ����� � ����
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'update SERVERPARAMCONSTANTS set SPCVALUE=:SPCVALUE, SPCUSERID='+
        IntToStr(pUserID)+' where SPCCODE='+IntToStr(csID)+' returning SPCTIME';
      if ConstItem.ItemType=constDouble then
        ORD_IBS.ParamByName('SPCVALUE').AsString:= fnSetDecSep(pValue, ConstItem.Precision) // ��� ������ � ���� '.'
      else ORD_IBS.ParamByName('SPCVALUE').AsString:= pValue;
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Bof and ORD_IBS.Eof) then raise Exception.Create('empty LastTime');
      pLastTime:= ORD_IBS.fieldByName('SPCTIME').AsDateTime;
      ORD_IBS.Transaction.Commit;
      ORD_IBS.Close;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    
    ConstItem.StrValue:= pValue; //--------------------------------- ����� � ���
    ConstItem.LastUser:= pUserID;
    ConstItem.LastTime:= pLastTime;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
//============================================ ��������� ����� ���� � ����������
function TDataCache.CheckRoleConstLink(csID, roleID, UserID: Integer; flWrite: Boolean; var ResCode: Integer): String;
const nmProc = 'CheckRoleConstLink';
// ��� �������� - ResCode - �� ����� (resAdded, resEdited, resDeleted)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������,
//                    resAdded - ���������, resEdited - ��������, resDeleted - �������
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    ConstItem: TConstItem;
    EmplRole: TEmplRole;
    OpCode, iw: Integer;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrProcess));
    if not (OpCode in [resAdded, resEdited, resDeleted]) then       // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');
    if not ConstExists(csID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����., ���='+IntToStr(csID));
    if not RoleExists(roleID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ����, ���='+IntToStr(roleID));

    ConstItem:= FParConstants[csID];
    EmplRole:= FEmplRoles[roleID];
    iw:= fnIfInt(flWrite, 1, 0); // SrcID=1 - ������� ���������� ������

    case OpCode of // ��������� ������
    resAdded: if EmplRole.ConstLinks.LinkExists(csID) then begin
        ResCode:= resDoNothing;
        if not ConstItem.Links.LinkExists(roleID) then  // �� ����.������
          ConstItem.Links.CheckLink(roleID, iw, EmplRole);
        raise Exception.Create('����� ������ ��� ����');
      end;
    resEdited: begin
        if not EmplRole.ConstLinks.LinkExists(csID) then
          raise Exception.Create(MessText(mtkNotFoundRecord));
        if (GetLinkSrc(EmplRole.ConstLinks[csID])=iw) then begin
          ResCode:= resDoNothing;
          if (GetLinkSrc(ConstItem.Links[roleID])<>iw) then // �� ����.������
            TLink(ConstItem.Links[roleID]).SrcID:= iw;
          raise Exception.Create(MessText(mtkNotChanges));
        end;
      end;
    resDeleted: if not EmplRole.ConstLinks.LinkExists(csID) and
      not ConstItem.Links.LinkExists(roleID) then begin
        ResCode:= resDoNothing;
        raise Exception.Create(MessText(mtkNotFoundRecord));
      end;
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt;                             // ����� � ����
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      case OpCode of
      resAdded  : begin
          ORD_IBS.SQL.Text:= 'insert into LINKSERVPARCONSTROLE'+
            ' (SPCRSPCCODE, SPCRROLECODE, SPCRUSERID, SPCRWRITE) values ('+
            IntToStr(csID)+', '+IntToStr(roleID)+', '+IntToStr(UserID)+', "'+
            fnIfStr(flWrite, 'T', 'F')+'") returning SPCRCODE';
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Bof and ORD_IBS.Eof) or (ORD_IBS.Fields[0].AsInteger<1) then
            raise Exception.Create('empty SPCRCODE');
        end;
      resEdited : begin
          ORD_IBS.SQL.Text:= 'update LINKSERVPARCONSTROLE set SPCRWRITE="'+
            fnIfStr(flWrite, 'T', 'F')+'", SPCRUSERID='+IntToStr(UserID)+
            ' where SPCRSPCCODE='+IntToStr(csID)+' and SPCRROLECODE='+IntToStr(roleID);
          ORD_IBS.ExecQuery;
        end;
      resDeleted: begin
          ORD_IBS.SQL.Text:= 'delete from LINKSERVPARCONSTROLE'+
            ' where SPCRSPCCODE='+IntToStr(csID)+' and SPCRROLECODE='+IntToStr(roleID);
          ORD_IBS.ExecQuery;
        end;
      end; // case
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    Result:= '������ ���� � ����������';
    case OpCode of
    resAdded  : begin
        ConstItem.Links.CheckLink(roleID, iw, EmplRole);
        EmplRole.ConstLinks.CheckLink(csID, iw, ConstItem);
        Result:= Result+' ���������';
      end;
    resEdited : begin
        TLink(ConstItem.Links[roleID]).SrcID:= iw;
        TLink(EmplRole.ConstLinks[csID]).SrcID:= iw;
        Result:= Result+' ��������';
      end;
    resDeleted: begin
        ConstItem.Links.DeleteLinkItem(roleID);
        EmplRole.ConstLinks.DeleteLinkItem(csID);
        Result:= Result+' �������';
      end;
    end;  // case
    ResCode:= OpCode;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
{//============================================ ��������� ����� ���� � ��������
function TDataCache.CheckRoleImportLink(impID, roleID, UserID: Integer; flWrite: Boolean; var ResCode: Integer): String;
const nmProc = 'CheckRoleImportLink';
// ��� �������� - ResCode - �� ����� (resAdded, resEdited, resDeleted)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������,
//                    resAdded - ���������, resEdited - ��������, resDeleted - �������
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    ImpItem: TImportType;
    EmplRole: TEmplRole;
    OpCode, iw: Integer;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrProcess));
    if not (OpCode in [resAdded, resEdited, resDeleted]) then       // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');
    if not ImpTypeExists(impID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �������, ���='+IntToStr(impID));
    if not RoleExists(roleID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ����, ���='+IntToStr(roleID));

    ImpItem:= FImportTypes[impID];
    EmplRole:= FEmplRoles[roleID];
    iw:= fnIfInt(flWrite, 1, 0); // SrcID=1 - ������� ���������� ������

    case OpCode of // ��������� ������
    resAdded: if EmplRole.ImpLinks.LinkExists(impID) then begin
        ResCode:= resDoNothing;
        if not ImpItem.RoleLinks.LinkExists(roleID) then  // �� ����.������
          ImpItem.RoleLinks.CheckLink(roleID, iw, EmplRole);
        raise Exception.Create('����� ������ ��� ����');
      end;

    resEdited: begin
        if not EmplRole.ImpLinks.LinkExists(impID) then
          raise Exception.Create(MessText(mtkNotFoundRecord));
        if (GetLinkSrc(EmplRole.ImpLinks[impID])=iw) then begin
          ResCode:= resDoNothing;
          if (GetLinkSrc(ImpItem.RoleLinks[roleID])<>iw) then // �� ����.������
            TLink(ImpItem.RoleLinks[roleID]).SrcID:= iw;
          raise Exception.Create(MessText(mtkNotChanges));
        end;
      end;

    resDeleted: if not EmplRole.ImpLinks.LinkExists(impID) and
      not ImpItem.RoleLinks.LinkExists(roleID) then begin
        ResCode:= resDoNothing;
        raise Exception.Create(MessText(mtkNotFoundRecord));
      end;
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt;                             // ����� � ����
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      case OpCode of
      resAdded  : begin
          ORD_IBS.SQL.Text:= 'insert into LINKIMPTYPEROLE'+
            ' (LITRIMTPCODE, LITRROLECODE, LITRUSERID, LITRWRITE) values ('+
            IntToStr(impID)+', '+IntToStr(roleID)+', '+IntToStr(UserID)+', "'+
            fnIfStr(flWrite, 'T', 'F')+'") returning LITRCODE';
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Bof and ORD_IBS.Eof) or (ORD_IBS.Fields[0].AsInteger<1) then
            raise Exception.Create('empty LITRCODE');
        end;
      resEdited : begin
          ORD_IBS.SQL.Text:= 'update LINKIMPTYPEROLE set LITRWRITE="'+
            fnIfStr(flWrite, 'T', 'F')+'", LITRUSERID='+IntToStr(UserID)+
            ' where LITRIMTPCODE='+IntToStr(impID)+' and LITRROLECODE='+IntToStr(roleID);
          ORD_IBS.ExecQuery;
        end;
      resDeleted: begin
          ORD_IBS.SQL.Text:= 'delete from LINKIMPTYPEROLE'+
            ' where LITRIMTPCODE='+IntToStr(impID)+' and LITRROLECODE='+IntToStr(roleID);
          ORD_IBS.ExecQuery;
        end;
      end; // case
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    Result:= '������ ���� � ��������';
    case OpCode of
    resAdded: begin
        ImpItem.RoleLinks.CheckLink(roleID, iw, EmplRole);
        EmplRole.ImpLinks.CheckLink(impID, iw, ImpItem);
        Result:= Result+' ���������';
      end;
    resEdited: begin
        TLink(ImpItem.RoleLinks[roleID]).SrcID:= iw;
        TLink(EmplRole.ImpLinks[impID]).SrcID:= iw;
        Result:= Result+' ��������';
      end;
    resDeleted: begin
        ImpItem.RoleLinks.DeleteLinkItem(roleID);
        EmplRole.ImpLinks.DeleteLinkItem(impID);
        Result:= Result+' �������';
      end;
    end;  // case
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;   }
//=================================== �������� ����������� �������� �� ���������
function TDataCache.CheckLinkAllowDelete(srcID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(FDCA)
    or not FDCA.LinkSources.ItemExists(srcID) then Exit;
  Result:= TSubDirItem(FDCA.LinkSources[srcID]).OrderNum=0;
end;
//==================== �������� ����������� ������� �������� ������ �� ���������
function TDataCache.CheckLinkAllowWrong(srcID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(FDCA)
    or not FDCA.LinkSources.ItemExists(srcID) then Exit;
  Result:= TSubDirItem(FDCA.LinkSources[srcID]).OrderNum=1;
end;
//================= ����������/�������� ������ �����/�������� � ��������� ������
procedure TDataCache.TestGrPgrDiscModelLinks;
const nmProc = 'TestGrPgrDiscModelLinks'; // ��� ���������/�������
var gID, dmID: Integer;
    flNew: boolean;
    disg: Double;
    ibd: TIBDatabase;
    ibs: TIBSQL;
    link: TQtyLink;
    gr: TWareInfo;
    dm: TDiscModel;
    LocalStart: TDateTime;
begin
  LocalStart:= now();
  if not Assigned(self) then Exit;
  ibd:= nil;
  ibs:= nil;
  try try
    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);

    flNew:= flShowWareByState
      and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetPrDirDiscModParams1');

    ibs.SQL.Text:= 'select rDiscModel, rWareCode, rDiscValue from '+
      fnIfStr(flNew, 'Vlad_CSS_GetPrDirDiscModParams1',
      'Vlad_CSS_GetPrDirDiscModParams order by rWareCode');
    ibs.ExecQuery;
    while not ibs.Eof do begin
      gID:= ibs.fieldByName('rWareCode').AsInteger;
      if not GrPgrExists(gID) then begin
        TestCssStopException;
        while not ibs.Eof and (gID=ibs.fieldByName('rWareCode').AsInteger) do ibs.Next;
        Continue;
      end;

      gr:= arWareInfo[gID];
      flNew:= (gr.DiscModLinks.Count<1);
      if not flNew then gr.DiscModLinks.SetLinkStates(False, gr.CS_wlinks);

      while not ibs.Eof and (gID=ibs.fieldByName('rWareCode').AsInteger) do begin
        dmID:= ibs.fieldByName('rDiscModel').AsInteger;
        disg:= RoundTo(ibs.fieldByName('rDiscValue').AsFloat, -2);
        dm:= Cache.DiscountModels[dmID]; // ������
        if flNew then link:= nil
        else link:= gr.DiscModLinks.GetLinkListItemByID(dmID, lkLnkByID);

        if Assigned(link) then try // ���� ���� ���� - ���������
          gr.CS_wlinks.Enter;
          if fnNotZero(disg-Link.Qty) then Link.Qty:= disg;
          if (Link.LinkPtr<>dm) then Link.LinkPtr:= dm;
          Link.State:= True; // ���� ��������
        finally
          gr.CS_wlinks.Leave;

        end else begin // ������� ����� ����
          link:= TQtyLink.Create(0, disg, dm);
          gr.DiscModLinks.AddLinkListItem(link, lkLnkByID, gr.CS_wlinks);
        end;

        cntsGRB.TestSuspendException;
        ibs.Next;
      end; // while not ibs.Eof and (gID=
      if not flNew then gr.DiscModLinks.DelNotTestedLinks(gr.CS_wlinks); // ������� ��� ������ � State = False
    end; // while not ibs.Eof

  finally
    prFreeIBSQL(ibs);
    cntsGRB.SetFreeCnt(ibd, True);
  end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  if flDebug then prMessageLOGS(nmProc+': '+GetLogTimeStr(LocalStart), fLogCache, false);
end;

//=========================================================== �������� ���� ����
procedure TDataCache.TestFirms(pID: Integer; FillNew: boolean=False;
           CompareTime: boolean=True; Partially: boolean=False; RegID: Integer=0);
// CompareTime=True - ��������� ����� ���������� ����������, False - �� ��������� (ID>0)
// ID=-1 - �� alter-��������, ID=0 - ������, ID>0 - �� 1 �����
// FillNew=True - ���������� �����, FillNew=False - �������� ������������
// Partially=True - ��������� ��������(WebArm), Partially=False - ������ ��������
// RegID>0 - �������� ���� ���������
const nmProc = 'TestFirms'; // ��� ���������/�������
var FirmCode, sSqlOrd, sSqlGb, s: string;
    FirmID, iCount, i, ii: Integer;
    ibsGB, ibs, ibsOrd, ibs1: TIBSQL;
    LocalStart, DateTemp, DateBeg, DateEnd: TDateTime;
    ibdGB, ibdOrd: TIBDatabase;
    flnew, PrevPartFilled: boolean;
    Contract: TContract;
    dest: TDestPoint;
    firma0: TFirmInfo;
    prof: TCredProfile;
//----------------------------------- ����������/�������� ������ ���������� ����
  procedure TestFirmContracts(ppID: Integer; InCS: boolean);
  var fcode, ss, s1, s, sDests, n: string;
      i, cc, sys, j, iState, cpID, cpContCount, cpDelay, cpCurr: Integer;
      fl, flFirmSaleBlocked, flProfBlocked, flFillProf: boolean;
      arFC, arFM, arFS, arDP: Tai;
      Item: Pointer;
      sum, cpDebt, cpLimit: Double;
  //------------------------------ ����������/�������� ������ �������� ����� �/�
    procedure TestFirmDestPoints;
    var destID, i: Integer;
    begin
      try
        if firma0.IsFinalClient then begin
          if (firma0.FirmDestPoints.Count>0) then try
            if InCS then firma0.CS_firm.Enter;
            firma0.FirmDestPoints.Clear;
          finally
            if InCS then firma0.CS_firm.Leave;
          end;

        end else begin
          if InCS then firma0.CS_firm.Enter;
          try
            for i:= 0 to firma0.FirmDestPoints.Count-1 do
              TDestPoint(firma0.FirmDestPoints[i]).State:= False;
          finally
            if InCS then firma0.CS_firm.Leave;
          end;

          ibs1.Close;
          if (ibs1.SQL.Text='') then
            ibs1.SQL.Text:= 'select RDestID, rDestName, rDestAdr'+
                            ' from Vlad_CSS_GetFirmContDestPoints(:firmID, 1)';
          ibs1.ParamByName('firmID').AsInteger:= firma0.ID;
          ibs1.ExecQuery;
          while not ibs1.Eof do begin
            destID:= ibs1.FieldByName('RDestID').AsInteger;
            dest:= firma0.GetFirmDestPoint(destID);
            n:= ibs1.FieldByName('rDestName').AsString;
            n:= fnReplaceQuotedForWeb(n); // ��������� ������� ' � " � `
            s:= ibs1.FieldByName('rDestAdr').AsString;
            s:= fnReplaceQuotedForWeb(s); // ��������� ������� ' � " � `

            if InCS then firma0.CS_firm.Enter;
            try
              if not Assigned(dest) then begin
                dest:= TDestPoint.Create(destID, n, s);
                firma0.FirmDestPoints.Add(dest);
              end else begin
                dest.Name:= n;
                dest.Adress:= s;
                dest.Disabled:= False;
                dest.State:= True;
              end;
            finally
              if InCS then firma0.CS_firm.Leave;
            end;

            cntsGRB.TestSuspendException;
            ibs1.Next;
          end;

          if InCS then firma0.CS_firm.Enter;
          try
            for i:= firma0.FirmDestPoints.Count-1 downto 0 do begin
              dest:= TDestPoint(firma0.FirmDestPoints[i]);
              if not dest.State then dest.Disabled:= True;
            end;
          finally
            if InCS then firma0.CS_firm.Leave;
          end;
        end;
      except
        on E: EBOBError do raise EBOBError.Create('TestFirmDestPoints_'+fcode+': '+E.Message);
        on E: Exception do prMessageLOGS('TestFirmDestPoints_'+IntToStr(firma0.ID)+': '+E.Message);
      end;
      ibs1.Close;
    end;
  //----------------------------------------------------------------------------
  begin
//    if not Assigned(self) or (ppID<0) or ((ppID>0) and not FirmExist(ppID)) then Exit;
    if not Assigned(self) or (ppID<1) then Exit;
    try
      TestFirmDestPoints;  // ����������/�������� ������ �������� ����� �/�

//-------------------------
      if not firma0.PartiallyFilled then try
        if InCS then firma0.CS_firm.Enter;
        for i:= 0 to firma0.FirmCredProfiles.Count-1 do
          TCredProfile(firma0.FirmCredProfiles[i]).State:= False;
      finally
        if InCS then firma0.CS_firm.Leave;
      end;
//-------------------------
      sum:= 0;
      if AllowWebarm then ss:= '0'
      else ss:= 'iif(("TODAY"<=CONTENDINGDATE) and (CONTSTATE=2), 0, 1)';

      s1:= 'select CONTCODE, CONTSECONDPARTY, CONTSUMM, CONTUSEBYDEFAULT,'+ // ContEmptyInvoice,
           ' CONTBEGININGDATE, CONTENDINGDATE, CONTPAYTYPE, CONTSECONDFIRMLEGALENTITY,'+
           ' CONTCRNCCODE, ContComments, CONTSTATE, ContPriceType, CONTDUTYCRNCCODE,'+
           ' contfirmcondprofilecode condprofile,'+
           ' CONTSECONDEMAIL, FirmEmail, gn.rNum contnumber, g.rEmplCode, g.rFaccCode'#10;

      if not firma0.PartiallyFilled then  // ������ �������� - ���.����, ����.����� ���������
        s1:= s1+', g.rContCreditCrnc, g.rContCreditSumm, g.rDebtSum,'+
                ' g.rContDelay, g.rWhenBlocked, g.rWarnMessage, g.rOrderSum,'+
                ' g.rPlanOutSum, g.rSaleBlocked, g.rRedSum, g.rVioletSum,'#10+
                ' (select list(RDestID) from Vlad_CSS_GetContDestPointCodes(CONTCODE)) sDests';

      s1:= s1+' from CONTRACT left join firms on firmcode=CONTSECONDPARTY'#10+
              ' left join Vlad_CSS_GetFullContNum(contnumber, contnkeyyear, contpaytype) gn on 1=1'+
              ' left join Vlad_CSS_GetFirmContOptions(CONTSECONDPARTY, CONTCODE, '+
//              IntToStr(constDaysForBlockWarninig)+', '+fnIfStr(Partially, '0', '1')+', '+ss+') g on 1=1'#10;
              IntToStr(constDaysForBlockWarninig)+', '+
              fnIfStr(firma0.PartiallyFilled, '0', '1')+', '+ss+') g on 1=1'#10;

      setLength(arFC, 0); // ���� ���������� �����
      setLength(arFS, 0); // ���� ������ ����� �����
      setLength(arFM, 0); // ���� ���������� �����
      setLength(arDP, 0); // ���� ����.����� ���������
      fcode:= IntToStr(ppID);
      DateTemp:= IncMonth(EncodeDate(CurrentYear, CurrentMonth, 1), -1); // ������ �������� �-��
      flFirmSaleBlocked:= False;
      ibs.Close;                        // ���.���� >= ���� ���������� ���������
      ibs.SQL.Text:= s1+' where CONTSECONDPARTY='+fcode+' and CONTBEGININGDATE<="TODAY"'+// ' and CONTTYPE=9' // ��� - ������� �����-�������
                     ' and contfirstparty=(select userfirmcode from userpsevdonimreestr where usercode=1)'+
                     ' order by condprofile';

      with ibs.Transaction do if not InTransaction then StartTransaction;
      ibs.ExecQuery;
      while not ibs.Eof do begin
        cpID:= ibs.FieldByName('condprofile').AsInteger; // �������
        cpContCount:= 0; // ������� ���������� � �������
        cpDelay:= 0;
        cpLimit:= 0;
        cpDebt:= 0;
        flProfBlocked:= False; // ���� ���������� ���� ������ ��������� �������
        cpCurr:= cDefCurrency;
        flFillProf:= True; // ���� ��� ����������� ����.������� ������� 1 ���
        while not ibs.Eof and (cpID=ibs.FieldByName('condprofile').AsInteger) do begin
          DateBeg:= ibs.FieldByName('CONTBEGININGDATE').AsDateTime;
          DateEnd:= ibs.FieldByName('CONTENDINGDATE').AsDateTime;
          iState:= ibs.FieldByName('CONTSTATE').AsInteger; // 2= "���������"
          fl:= False;
          if AllowWebArm then fl:= (DateEnd<Date) or (iState<>2); // WebArm - �������� ��������
          if AllowWeb then fl:= (DateEnd<DateTemp); // Web - ��������� ����� ������ �������� �-��

          if fl and not firma0.PartiallyFilled then      // ��� ������/��������
            fl:= not fnNotZero(ibs.FieldByName('rDebtSum').AsFloat);

          if fl then begin
            ibs.Next;                  // ���������� �������� ��� ������/��������
            Continue;
          end;

          cc:= ibs.FieldByName('CONTCODE').AsInteger;
          ss:= ibs.FieldByName('CONTNUMBER').AsString;
          sys:= 0;
          fl:= Contracts.ItemExists(cc);
          if not fl then begin // ����� ��������
            Item:= TContract.Create(cc, ppID, sys, ss); // Contract.Status:= cstUnKnown;
            Contracts.CheckItem(Item);
          end;
          Contract:= Contracts[cc];
          Contract.CS_cont.Enter;
          try // ���������/��������� ��������� ���������
            if fl then begin  // � ������������ ��������� ��������� Create
              Contract.ContFirm:= ppID;
              Contract.Name:= ss;
            end;
            if (DateEnd<Date) or (iState<>2) then  // ������� ������������ ���������
              Contract.Status:= cstClosed;
            if (Contract.ContBegDate<>DateBeg) then Contract.ContBegDate:= DateBeg;
            if (Contract.ContEndDate<>DateEnd) then Contract.ContEndDate:= DateEnd;
            Contract.CredProfile:= cpID;

            if not firma0.PartiallyFilled then begin // ������ �������� - ���.����
              Contract.DebtSum     := ibs.FieldByName('rDebtSum').AsFloat;   // ����
              Contract.RedSum      := ibs.FieldByName('rRedSum').AsFloat;    // ������������ ������
              Contract.VioletSum   := ibs.FieldByName('rVioletSum').AsFloat; // ���������� ������
              Contract.WarnMessage := ibs.FieldByName('rWarnMessage').AsString;
              Contract.WhenBlocked := ibs.FieldByName('rWhenBlocked').AsInteger;
              Contract.SaleBlocked:= (ibs.FieldByName('rSaleBlocked').AsInteger=1);
              flFirmSaleBlocked:= flFirmSaleBlocked or Contract.SaleBlocked;
              flProfBlocked:= flProfBlocked or Contract.SaleBlocked;

              if (Contract.Status=cstClosed) then begin // ����������� ��������
                Contract.OrderSum  := 0;
                Contract.PlanOutSum:= 0;
              end else begin
                if Contract.SaleBlocked then Contract.Status:= cstBlocked
                else Contract.Status:= cstWorked;
                Contract.OrderSum  := ibs.FieldByName('rOrderSum').AsFloat;
                Contract.PlanOutSum:= ibs.FieldByName('rPlanOutSum').AsFloat;
              end;
              if AllowWebArm or (Contract.Status<>cstClosed) then begin
                j:= ibs.FieldByName('rContDelay').AsInteger;
                if (j<0) then j:= 0;
                Contract.CredDelay:= j;
                Contract.CredLimit:= ibs.FieldByName('rContCreditSumm').AsFloat;
              end else begin
                Contract.CredDelay:= 0;
                Contract.CredLimit:= 0;
              end;
              sum:= sum+Contract.OrderSum;
              //---------------------------------------- ���� ����.����� ���������
              sDests:= ibs.FieldByName('sDests').AsString;
              arDP:= fnArrOfCodesFromString(sDests);
              for i:= Contract.ContDestPointCodes.Count-1 downto 0 do begin
                j:= Contract.ContDestPointCodes[i];
                fl:= (fnInIntArray(j, arDP)<0);
                if not fl then begin
                  dest:= firma0.GetFirmDestPoint(j);
                  fl:= not Assigned(dest) or dest.Disabled;
                end;
                if fl then Contract.ContDestPointCodes.Delete(i);
              end;
              for i:= 0 to High(arDP) do begin
                j:= arDP[i];
                if Contract.ContDestPointExists(j) then Continue;
                dest:= firma0.GetFirmDestPoint(j);
                if not Assigned(dest) or dest.Disabled then Continue;
                Contract.ContDestPointCodes.Add(j);  // ������� ???
              end;
              setLength(arDP, 0);
              //----------------------------------------
              i:= ibs.FieldByName('rContCreditCrnc').AsInteger;
              if (i<1) then begin
                if firma0.IsFinalClient then i:= cUAHCurrency else i:= cDefCurrency;
              end;
              Contract.CredCurrency:= i;
//-------------------------
              cpDebt:= cpDebt+Contract.DebtSum; // ���� �� �������
              if flFillProf and                      // ����.���.������� - 1 ���
                (AllowWebArm or (Contract.Status<>cstClosed)) then begin
                cpDelay:= ibs.FieldByName('rContDelay').AsInteger;
                cpCurr:= Contract.CredCurrency;
                cpLimit:= ibs.FieldByName('rContCreditSumm').AsFloat;
                flFillProf:= False;
              end;
//-------------------------
            end   //  if not Partially
            else if (Contract.CredCurrency<1) then begin
              if firma0.IsFinalClient then Contract.CredCurrency:= cUAHCurrency
              else Contract.CredCurrency:= cDefCurrency;
            end;
  //          i:= ibs.FieldByName('CONTCRNCCODE').AsInteger;
  //          Contract.ContCurrency:= fnIfInt(i<1, Contract.CredCurrency, i);
            i:= ibs.FieldByName('CONTDUTYCRNCCODE').AsInteger;
            Contract.DutyCurrency:= fnIfInt(i<1, Contract.CredCurrency, i);
            s:= ibs.FieldByName('CONTSECONDEMAIL').AsString;
            if (s='') then s:= ibs.FieldByName('FirmEmail').AsString;
            Contract.ContEmail:= s;
            i:= 0; // ������ �� BKE
            if (Contract.FContManager<>i) then Contract.FContManager:= i;
            Contract.PayType     := ibs.FieldByName('CONTPAYTYPE').AsInteger;
            Contract.ContPriceType:= ibs.FieldByName('ContPriceType').AsInteger;
            Contract.FacCenter    := ibs.FieldByName('rFaccCode').AsInteger;
            Contract.ContSumm     := ibs.FieldByName('CONTSUMM').AsFloat;
  //          Contract.EmptyInvoice := GetBoolGB(ibs, 'ContEmptyInvoice');
            Contract.ContDefault  := GetBoolGB(ibs, 'CONTUSEBYDEFAULT');
            Contract.LegalEntity:= ibs.FieldByName('CONTSECONDFIRMLEGALENTITY').AsInteger;
            Contract.Fictive:= False;
            Contract.ContComments:= ibs.FieldByName('ContComments').AsString;
            prAddItemToIntArray(cc, arFC);      // �������� ���� ���������� �����
            With Contract.GetContBKEempls do for i:= 0 to Count-1 do
              prAddItemToIntArray(Items[i], arFM); // ��������� ���� ���������� ��� �� BKE
          finally
            Contract.CS_cont.Leave;
          end;
          inc(cpContCount);

          cntsGRB.TestSuspendException;
          ibs.Next;
        end; // while not ibs.Eof and (cpID=
//-------------------------
        if (cpContCount>0) then begin
          prof:= firma0.GetFirmCredProfile(cpID);
          flFillProf:= not assigned(prof); // ������� ������ �������
          if flFillProf then try
            if InCS then firma0.CS_firm.Enter;
            prof:= TCredProfile.Create(cpID, cpCurr, cpDelay, '', cpLimit, cpDebt);
            firma0.FirmCredProfiles.Add(prof);
          finally
            if InCS then firma0.CS_firm.Leave;
          end;
          if not firma0.PartiallyFilled then begin
            if InCS then firma0.CS_firm.Enter;
            try
              if not flFillProf then begin // ��������� ��-����� �������
                if fnNotZero(prof.FProfDebtAll-cpDebt) then prof.FProfDebtAll:= cpDebt;
                if fnNotZero(prof.FProfCredLimit-cpLimit) then prof.FProfCredLimit:= cpLimit;
                if (prof.FProfCredDelay<>cpDelay) then prof.FProfCredDelay:= cpDelay;
                if (prof.FProfCredCurrency<>cpCurr) then prof.FProfCredCurrency:= cpCurr;
                prof.State:= True;
              end;                 // ��������� ������� �� ������.�������
              if (prof.FProfCredLimit>0) and (prof.FProfDebtAll>prof.FProfCredLimit) then begin
                prof.Blocked:= True;
                prof.FName:= '�������� ������';
//              end else if flProfBlocked then begin // ��������� �� ���������� ���������
//                prof.Blocked:= True;
//                prof.FName:= '';
//                prof.FName:= '�������� ���������';  // ???
              end else begin
                prof.Blocked:= False;
                prof.FName:= '';
              end;
            finally
              if InCS then firma0.CS_firm.Leave;
            end;
            flFirmSaleBlocked:= flFirmSaleBlocked or prof.Blocked;
          end; // if not firma0.PartiallyFilled

        end; // if (cpContCount>0)
//-------------------------
      end; // while not ibs.Eof

      if InCS then firma0.CS_firm.Enter;
      try
        prCheckIntegerListByCodesArray(firma0.FirmContracts, arFC); // ������� TIntegerList � �������� �����
        if (firma0.FirmContracts.Count>1) then firma0.FirmContracts.Sort;  // ???
        prCheckIntegerListByCodesArray(firma0.FirmManagers, arFM);  // ������� TIntegerList � �������� �����

        if not firma0.PartiallyFilled then begin
          firma0.AllOrderSum:= sum;
//-------------------------
          for i:= firma0.FirmCredProfiles.Count-1 downto 0 do begin
            prof:= TCredProfile(firma0.FirmCredProfiles[i]);
            if not prof.State then prof.Disabled:= True;
          end;
//-------------------------
          if (firma0.SaleBlocked<>flFirmSaleBlocked) then
            firma0.SaleBlocked:= flFirmSaleBlocked;
        end;

        firma0.LastDebtTime:= Now;
      finally
        if InCS then firma0.CS_firm.Leave;
      end;
    except
      on E: EBOBError do raise EBOBError.Create('TestFirmContracts_'+fcode+': '+E.Message);
      on E: Exception do prMessageLOGS('TestFirmContracts_'+fcode+': '+E.Message, fLogCache);
    end;
    setLength(arFC, 0);
    setLength(arFM, 0);
    setLength(arFS, 0);
    setLength(arDP, 0);
    ibs.Close;
  end; // TestFirmContracts
//------------------------------------ ����������/�������� ������ ��������� ����
  procedure TestFirmClasses(ppID: Integer=0; pRegID: Integer=0); // ppID=0 - ��� ������������
  var fcode, ss, s, sSQLreg: string;
      i, j, fid: Integer;
      ff, flReg, flAll, ff1, ff2, ff3: boolean;
      ar, ar1: Tai;
      firma: TFirmInfo;
      tt: TTwoCodes;
      sums: TDoubleDynArray;
      le: TBaseDirItem;
    //----------------------------
    procedure SetLengthArrs(len: Integer);
    begin
      setLength(ar, len);
      setLength(ar1, len);
      setLength(sums, len);
    end;
    //----------------------------
  begin
    if not Assigned(self) or (ppID<0) or ((ppID>0) and not FirmExist(ppID)) then Exit;
    firma:= nil;
    tt:= nil;
    try
      flAll:= (ppID=0);
      if pID>0 then begin // 1 �����
        fcode:= IntToStr(ppID);
        ibsGB.SQL.Text:= 'select FRGRFIRMCODE, FRGRCLASSCODE from FIRMGROUP'+
          ' where FRGRFIRMCODE='+fcode+' and FRGRFIRMARCHIVE="F" and FrGrArchived="F"';

      end else if (pRegID>0) then begin // ����� ���������
        ss:= IntToStr(pRegID);
        fcode:= 'RegID='+ss;
//        s:= IntToStr(constIsAuto)+','+IntToStr(constIsMoto);
        sSQLreg:= ' from (select c.CONTSECONDPARTY Firm from CONTRACT c'#10+
          ' inner join firms on FirmCode=c.CONTSECONDPARTY'#10+
          '   and c.contfirstparty=(select userfirmcode from userpsevdonimreestr where usercode=1)'+
          '   and firmarchivedkey="F" and firmservicefirm="F"'+
          '   and FirmOrganizationType=0 and (firmchildcount=0'+
          '   or not exists(select * from firms ff where ff.firmmastercode=firmcode'+
          '    and ff.FirmOrganizationType=0))'+
          ' left join Vlad_CSS_GetFirmContOptions(c.CONTSECONDPARTY, c.CONTCODE, 1, 0, 0) m on 1=1'#10+
          ' where ("TODAY">=c.contbeginingdate) and (exists(select * from'+
          ' Vlad_CSS_GetFaccBKEempls(m.rFaccCode) b where b.rEmplCode='+ss+')) group by Firm) f ';

        ibsGB.SQL.Text:= 'select FRGRFIRMCODE, FRGRCLASSCODE '#10+sSQLreg+
          ' inner join FIRMGROUP on FRGRFIRMCODE=f.Firm'+
          '   and FRGRFIRMARCHIVE="F" and FrGrArchived="F"';

      end else begin // ���
        fcode:= 'all';
        ibsGB.SQL.Text:= 'select FRGRFIRMCODE, FRGRCLASSCODE from FIRMGROUP'+
          ' where FRGRFIRMARCHIVE="F" and FrGrArchived="F" order by FRGRFIRMCODE';
      end;
      try
        ibsGB.ExecQuery;
        while not ibsGB.Eof do begin
          fid:= ibsGB.FieldByName('FRGRFIRMCODE').AsInteger;
          ff:= FirmExist(fid);
          if ff then firma:= arFirmInfo[fid];
          flReg:= ff and ((pRegID<1) or firma.CheckFirmManager(pRegID));
          if not (ff and flReg) then begin
            TestCssStopException;
            while not ibsGB.Eof and (fid=ibsGB.FieldByName('FRGRFIRMCODE').AsInteger) do ibsGB.Next;
            Continue;
          end;

          j:= 0; // ������� ��������� �����
          setLength(ar, 10);
          while not ibsGB.Eof and (fid=ibsGB.FieldByName('FRGRFIRMCODE').AsInteger) do begin
            if High(ar)<j then setLength(ar, j+10);
            ar[j]:= ibsGB.FieldByName('FRGRCLASSCODE').AsInteger;
            inc(j);
            cntsGRB.TestSuspendException;
            ibsGB.Next;
          end; // while not ibsGB.Eof and (fid=ibsGB.FieldByName('FRGRFIRMCODE').AsInteger)
          if Length(ar)>j then setLength(ar, j);

          if flAll then firma.CS_firm.Enter;
          try
            for j:= 0 to High(ar) do
              if (firma.FirmClasses.IndexOf(ar[j])<0) then firma.FirmClasses.Add(ar[j]);
            for j:= firma.FirmClasses.Count-1 downto 0 do
              if fnInIntArray(firma.FirmClasses[j], ar)<0 then firma.FirmClasses.Delete(j);
          finally
            if flAll then firma.CS_firm.Leave;
          end;
          setLength(ar, 0);
        end; // while not ibsGB.Eof
      finally
        ibsGB.Close;
      end;
      //----------------------- VIN �������, ���������� ������, �������� �������
      if (ppID>0) then begin
        if FirmExist(ppID) then with arFirmInfo[ppID] do begin
          HasVINmail:= CheckFirmVINmail;
          EnablePriceLoad:= CheckFirmPriceLoadEnable;
          EnableOrderImport:= flOrderImport and CheckFirmOrderImportEnable;
          ShowZeroRests:= CheckShowZeroRests; // (�����)
        end;
      end else for j:= 0 to High(arFirmInfo) do begin
        if not FirmExist(j) then Continue;
        firma:= arFirmInfo[j];
        if ((pRegID>0) and not firma.CheckFirmManager(pRegID)) then Continue;
        with firma do begin
          ff:= CheckFirmVINmail;
          ff1:= CheckFirmPriceLoadEnable;
          ff2:= flOrderImport and CheckFirmOrderImportEnable;
          ff3:= CheckShowZeroRests; //  (�����)
          if (HasVINmail<>ff) or (EnablePriceLoad<>ff1)
            or (EnableOrderImport<>ff2) or (ShowZeroRests<>ff3) then try
            if flAll then CS_firm.Enter;
            if (HasVINmail<>ff) then HasVINmail:= ff;
            if (EnablePriceLoad<>ff1) then EnablePriceLoad:= ff1;
            if (EnableOrderImport<>ff2) then EnableOrderImport:= ff2;
            if (ShowZeroRests<>ff3) then ShowZeroRests:= ff3;
          finally
            if flAll then CS_firm.Leave;
          end;
        end; // with firma
      end;

      //----------------------- ������� ������� ������ � ������� �� ������������
      if pID>0 then s:= IntToStr(ppID)+', 0' // 1 �����
      else if (pRegID>0) then s:= '0, '+IntToStr(pRegID) // ����� ���������
      else s:= '0, 0'; // ���
      ibsGB.SQL.Text:= 'select rFirmCode, rProdDirect, rDiscModel, rSumm'+
        ' from Vlad_CSS_GetFirmsPrDirDiscMods('+s+')';
      try
        ibsGB.ExecQuery;
        while not ibsGB.Eof do begin
          fid:= ibsGB.FieldByName('rFirmCode').AsInteger;
          ff:= FirmExist(fid);
          if ff then firma:= arFirmInfo[fid];
          flReg:= ff and ((pRegID<1) or firma.CheckFirmManager(pRegID));
          if not (ff and flReg) then begin
            TestCssStopException;
            while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger) do ibsGB.Next;
            Continue;
          end;
          j:= 0; // ������� �����������
          SetLengthArrs(10);
          while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger) do begin
            if High(ar)<j then SetLengthArrs(j+10);
            ar[j]:= ibsGB.FieldByName('rProdDirect').AsInteger; // ��� �����������
            ar1[j]:= ibsGB.FieldByName('rDiscModel').AsInteger; // ��� �������
            sums[j]:= ibsGB.FieldByName('rSumm').AsFloat;       // ������� ������ �/�
            inc(j);
            cntsGRB.TestSuspendException;
            ibsGB.Next;
          end; // while not ibsGB.Eof and (fid=ibsGB.FieldByName('FRGRFIRMCODE').AsInteger)
          if Length(ar)>j then setLength(ar, j);

          if flAll then firma.CS_firm.Enter;
          try
            for j:= 0 to High(ar) do begin
              ff:= False;
              for i:= 0 to firma.FirmDiscModels.Count-1 do begin
                tt:= TTwoCodes(firma.FirmDiscModels[i]);
                ff:= (tt.ID1=ar[j]); // ��������� ��� �����������
                if ff then break;
              end;
              if ff then begin
                if (tt.ID2<>ar1[j]) then tt.ID2:= ar1[j];           // ��������� ��� �������
                if fnNotZero(tt.Qty-sums[j]) then tt.Qty:= sums[j]; // ��������� ������� ������ �/�
              end else firma.FirmDiscModels.Add(TTwoCodes.Create(ar[j], ar1[j], sums[j]));
            end;
            for j:= firma.FirmDiscModels.Count-1 downto 0 do begin
              tt:= TTwoCodes(firma.FirmDiscModels[j]);
              if (fnInIntArray(tt.ID1, ar)<0) then firma.FirmDiscModels.Delete(j);
            end;
          finally
            if flAll then firma.CS_firm.Leave;
          end;
  {          if flDebug then begin
              setLength(ar, FirmDiscModels.Count);
              for j:= 0 to FirmDiscModels.Count-1 do ar[j]:= TTwoCodes(FirmDiscModels[j]).ID1;
              prMessageLOGS('_FirmDiscModels_'+inttostr(fid)+': '+fnArrOfIntToString(ar), fLogDebug, false);
            end;  }
          SetLengthArrs(0);
        end; // while not ibsGB.Eof
      finally
        ibsGB.Close;
      end;

      //---------------------------------- ����.����� �/�, Object - TBaseDirItem
      if pID>0 then  // 1 �����
        ibsGB.SQL.Text:= 'select LgEnCode, LgEnFirmCode, fl.firmmainname LgEnFullName'+
          ' from LegalEntities'+
          ' inner join firms fl on fl.firmcode=LgEnEntityFirmCode and fl.FirmOrganizationType=1'+
          ' where LgEnFirmCode='+fcode
      else if (pRegID>0) then  // ����� ���������
        ibsGB.SQL.Text:= 'select LgEnCode, LgEnFirmCode, fl.firmmainname LgEnFullName '#10+sSQLreg+
          ' inner join LegalEntities on LgEnFirmCode=f.Firm'+
          ' inner join firms fl on fl.firmcode=LgEnEntityFirmCode and fl.FirmOrganizationType=1'
      else  // ���
        ibsGB.SQL.Text:= 'select LgEnCode, LgEnFirmCode, fl.firmmainname LgEnFullName'+
          ' from LegalEntities'+
          ' inner join firms fl on fl.firmcode=LgEnEntityFirmCode and fl.FirmOrganizationType=1'+
          ' order by LgEnFirmCode';
      try
        ibsGB.ExecQuery;
        while not ibsGB.Eof do begin
          fid:= ibsGB.FieldByName('LgEnFirmCode').AsInteger;
          ff:= FirmExist(fid);
          if ff then firma:= arFirmInfo[fid];
          flReg:= ff and ((pRegID<1) or firma.CheckFirmManager(pRegID));
          if not (ff and flReg) then begin
            TestCssStopException;
            while not ibsGB.Eof and (fid=ibsGB.FieldByName('LgEnFirmCode').AsInteger) do ibsGB.Next;
            Continue;
          end;

          if flAll then firma.CS_firm.Enter;
          try
            for j:= 0 to firma.LegalEntities.Count-1 do begin
              le:= TBaseDirItem(firma.LegalEntities[j]);
              le.State:= False;
            end;

            while not ibsGB.Eof and (fid=ibsGB.FieldByName('LgEnFirmCode').AsInteger) do begin
              i:= ibsGB.FieldByName('LgEnCode').AsInteger;
              s:= ibsGB.FieldByName('LgEnFullName').AsString;
              s:= fnReplaceQuotedForWeb(s); // ��������� ������� ' � " � `
              ff:= False;
              for j:= 0 to firma.LegalEntities.Count-1 do begin
                le:= TBaseDirItem(firma.LegalEntities[j]);
                ff:= (le.ID=i);
                if ff then begin // ����� - ���������
                  le.Name:= s;
                  le.State:= True;
                  break;
                end;
              end; // for j
              if not ff then begin // �� ����� - ���������
                le:= TBaseDirItem.Create(i, s);
                firma.LegalEntities.Add(le);
              end;
              cntsGRB.TestSuspendException;
              ibsGB.Next;
            end; // while not ibsGB.Eof and (fid=

            for j:= firma.LegalEntities.Count-1 downto 0 do begin
              le:= TBaseDirItem(firma.LegalEntities[j]);
              if not le.State then begin
                firma.LegalEntities.Delete(j);
                prFree(le);
              end;
            end;
          finally
            if flAll then firma.CS_firm.Leave;
          end;
        end; // while not ibsGB.Eof
      finally
        ibsGB.Close;
      end;

    except
      on E: EBOBError do raise EBOBError.Create('TestFirmClasses_'+fcode+': '+E.Message);
      on E: Exception do prMessageLOGS('TestFirmClasses_'+fcode+': '+E.Message, fLogCache);
    end;
    SetLengthArrs(0);
  end;
//------------------------------- ����������/�������� ������� ������� ����������
  procedure TestContractStores(ppID: Integer=0; pRegID: Integer=0); // ppID=0 - ��� ������������
  var fcode, sParam, s: string;
      j, fid, cid, sid, jj: Integer;
      ff, flReg, flAll, flAdd: boolean;
      ar: Tai;
      firma: TFirmInfo;
      Contract: TContract;
//      dprt: TDprtInfo;
//      tc: TTwoCodes;
  begin
    setLength(ar, 0);
    if not Assigned(self) or (ppID<0) or ((ppID>0) and not FirmExist(ppID)) then Exit;
    try
      flAll:= (ppID=0);
      if (pID>0) then begin // 1 �����
        fcode:= IntToStr(ppID);
        sParam:= fcode+', 0';
      end else if (pRegID>0) then begin // ����� ���������
        sParam:= IntToStr(pRegID);
        fcode:= 'RegID='+sParam;
        sParam:= '0, '+sParam;
      end else begin // ��� �����
        fcode:= 'all';
        sParam:= '0, 0';
      end;
      with ibsGB.Transaction do if not InTransaction then StartTransaction;

      ibsGB.SQL.Text:= 'select rFirmCode, rContCode, rDprtCode, rDefault, rVisible,'+
        ' rReserve, rSale, rAddVis, rOrdProc from Vlad_CSS_GetFirmContrStores('+sParam+')';

      ibsGB.ExecQuery;
      while not ibsGB.Eof do begin
        fid:= ibsGB.FieldByName('rFirmCode').AsInteger;
        ff:= FirmExist(fid);
        if not ff then begin
          TestCssStopException;
          while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger) do ibsGB.Next;
          Continue;
        end;
        firma:= arFirmInfo[fid];

        while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger) do begin
          cid:= ibsGB.FieldByName('rContCode').AsInteger;
          ff:= firma.CheckContract(cid) and Contracts.ItemExists(cid);
          flReg:= False;
          if ff then begin
            Contract:= Contracts[cid];
            flReg:= ff and ((pRegID<1) or Contract.CheckContManager(pRegID));
          end else Contract:= nil;
          if not (ff and flReg) then begin
            TestCssStopException;
            while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger)
              and (cid=ibsGB.FieldByName('rContCode').AsInteger) do ibsGB.Next;
            Continue;
          end;

          j:= 0; // ������� �������
          setLength(ar, 0);
          Contract.CS_cont.Enter;
          try
            while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger)
              and (cid=ibsGB.FieldByName('rContCode').AsInteger) do begin
              sid:= ibsGB.FieldByName('rDprtCode').AsInteger;
//--------------------------------------------------------- ������ ����� �������
              if GetBoolGB(ibsGB, 'rOrdProc') then begin
                jj:= Length(ar);      // ������ �������� ��������� ������
                setLength(ar, jj+1);
                ar[jj]:= sid;
              end;
              if GetBoolGB(ibsGB, 'rVisible') or GetBoolGB(ibsGB, 'rReserve')
                or GetBoolGB(ibsGB, 'rAddVis') then begin
                Contract.TestStoreArrayLength(taCurr, j+1, true, not (ff and flAll));
                if not Assigned(Contract.ContStorages[j]) then
                  Contract.ContStorages[j]:= TStoreInfo.Create(sid, '');
                with Contract.ContStorages[j] do begin
                  if DprtID<>sid then DprtID:= sid;
                  IsDefault:= GetBoolGB(ibsGB, 'rDefault');
                  if IsDefault and (Contract.MainStorage<>sid) then
                    Contract.MainStorage:= sid;
                  IsVisible:= GetBoolGB(ibsGB, 'rVisible');
                  IsReserve:= GetBoolGB(ibsGB, 'rReserve');
                  IsAddVis:= GetBoolGB(ibsGB, 'rAddVis'); // ����� ���.���������
                end;
                inc(j);
              end; // if GetBoolGB

              cntsGRB.TestSuspendException;
              ibsGB.Next;
            end;
                                                  // ���� �����-�� ����� �������
            Contract.TestStoreArrayLength(taCurr, j, false, not (ff and flAll and flReg));
            jj:= Length(ar);
            Contract.TestStoreArrayLength(taDprt, jj, false, not (ff and flAll and flReg));
            for jj:= Low(ar) to High(ar) do // ������ �������� ��������� ������
              if (Contract.ContProcDprts[jj]<>ar[jj]) then Contract.ContProcDprts[jj]:= ar[jj];
  //            prMessageLOGS('ContStores_'+inttostr(fid)+': '+fnArrOfIntToString(ContProcDprts), fLogCache);
            flAdd:= False;
            for jj:= 0 to High(Contract.ContStorages) do begin
              flAdd:= Contract.ContStorages[jj].IsAddVis;
              if flAdd then break;
            end;
            Contract.HasAddVis:= flAdd;
          finally
            Contract.CS_cont.Leave;
            setLength(ar, 0);
          end;
        end; // while not ibsGB.Eof and (fid=...

        if AllowWeb then begin //---------------- ��������� �������� unit-������
          cid:= firma.ContUnitOrd;
          flAdd:= (cid>0) and (not firma.CheckContract(cid)
                  or (Cache.Contracts[cid].Status<=cstClosed));
          if flAdd then begin // ���� �������� unit-������ ������� (������ � �.�.)
            Contract:= firma.GetAvailableContract; // ����� ����������� �������� ����� (���������� ��������)
            if Assigned(Contract) then cid:= Contract.ID else cid:= 0;
            if (cid>0) then try try // ������ �������� unit-������
              s:= IntToStr(firma.ID);
              sParam:= IntToStr(firma.ContUnitOrd);
              ibsOrd.Close;
              ibsOrd.SQL.Clear;
              fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
              ibsOrd.ParamCheck:= False;
              ibsOrd.SQL.Add('execute block as declare variable xCode integer=0; begin');
              ibsOrd.SQL.Add(' select first 1 ORDRCODE from ORDERSREESTR');
              ibsOrd.SQL.Add(' where ORDRFIRM='+s+' and ORDRSTATUS='+IntToStr(orstForming));
              ibsOrd.SQL.Add('  and ORDRCURRENCY='+IntToStr(Cache.BonusCrncCode));
              ibsOrd.SQL.Add('  and ORDRCONTRACT='+sParam+' into :xCode;');
              ibsOrd.SQL.Add(' if (xCode is null or xCode<1) then');
              ibsOrd.SQL.Add('  exception NonFound "Not found UnitOrd, Cont='+sParam+'";');
              ibsOrd.SQL.Add(' update ORDERSREESTR set ORDRCONTRACT='+IntToStr(cid));
              ibsOrd.SQL.Add('  where ORDRCODE=:xCode; end');
              ibsOrd.ExecQuery;
              ibsOrd.Transaction.Commit;
              firma.SetContUnitOrd(cid);
              prMessageLOGS('_ChangeUnitOrd: firm='+s+', cont='+sParam+
                ' to cont='+IntToStr(cid), fLogDebug, False);
            except
              on E: Exception do begin
                ibsOrd.Transaction.Rollback;
                prMessageLOGS('_ChangeUnitOrd_'+s+': '+E.Message, fLogDebug, False);
              end;
            end;
            finally
              ibsOrd.Close;
              ibsOrd.SQL.Clear;
              ibsOrd.ParamCheck:= True;
              fnSetTransParams(ibsOrd.Transaction, tpRead);
            end;
          end; // if flAdd
        end; // if AllowWeb
      end; // while not ibsGB.Eof
    except
      on E: EBOBError do raise EBOBError.Create('TestContractStores_'+fcode+': '+E.Message);
      on E: Exception do prMessageLOGS('TestContractStores_'+fcode+': '+E.Message, fLogCache);
    end;
    ibsGB.Close;
    setLength(ar, 0);
  end;
//-------------------------------------- �������� ���������� ����� �� Grossbee
  procedure TestFirmDataFromGrossbee(jj: integer; new: boolean; InCS: boolean=True);
  var ss: string;
  begin
//    if not FirmExist(jj) then Exit;
    with firma0 do begin
      if InCS then CS_firm.Enter;
      try
        ss:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('FIRMUPPERMAINNAME').AsString);
        ss:= fnReplaceQuotedForWeb(ss); // ��������� ������� ' � " � `
        UPPERMAINNAME:= ss;
        UPPERSHORTNAME:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('FIRMUPPERSHORTNAME').AsString);
        ss:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('FIRMMAINNAME').AsString);
        ss:= fnReplaceQuotedForWeb(ss); // ��������� ������� ' � " � `
        if new or (Name<>ss) then Name:= ss;
                                      // ������ ������ � ��������� �� ������ !!!
        if not Partially and PartiallyFilled then PartiallyFilled:= Partially;
        Arhived := GetBoolGB(ibsGB, 'FIRMARCHIVEDKEY');
        FirmType:= ibsGB.FieldByName('FirmType').AsInteger;
        HostCode:= ibsGB.FieldByName('HOSTCODE').AsInteger;
        BonusQty:= ibsGB.FieldByName('bnrssumm').AsFloat;
        BonusRes:= ibsGB.FieldByName('UnitReserve').AsFloat;
        SendInvoice:= GetBoolGB(ibsGB, 'FirmSendInvoice');
        if Partially then
          AllOrderSum:= RoundTo(ibsGB.FieldByName('Reserve').AsFloat, -2);
        if ibsGB.FieldByName('FirmOrderLimit').IsNull then ResLimit:= -1
        else ResLimit:= RoundTo(ibsGB.FieldByName('FirmOrderLimit').AsFloat, -2);
        IsFinalClient:= GetBoolGB(ibsGB, 'PMFirmFinalClient'); // ������� ��������� �������
      finally
        if InCS then CS_firm.Leave;
      end;
      TestFirmContracts(jj, InCS); // ��������� ����� (+ ���������, ������� �����)
      LastTestTime:= Now;
    end;
  end;
//-------------------------------------- �������� ���������� ����� �� ib_ord
  procedure TestFirmDataFromWebTables(jj: integer; InCS: boolean=True);
  begin
//    if not FirmExist(jj) then Exit;
    with firma0 do try
      if InCS then CS_firm.Enter;
      NUMPREFIX     := ibsOrd.fieldByName('WOFRNUMPREFIX').AsString;
      SUPERVISOR    := ibsOrd.fieldByName('WOFRSUPERVISOR').AsInteger;
      SKIPPROCESSING:= GetBoolGB(ibsOrd, 'WOFRSKIPPROCESSING');
      Blocked       := (ibsOrd.fieldByName('wofrblock').AsInteger>0);
      ActionText    := ibsOrd.fieldByName('WOFRActionStateText').AsString;
      ContUnitOrd   := ibsOrd.fieldByName('ContUnitOrd').AsInteger;
    finally
      if InCS then CS_firm.Leave;
    end;
  end;
//--------------------- ������� ������������� �������� �����
  function FirmNeedTesting(jj: integer): boolean;
  begin // ���� ������ ��������, � ����� ��������� �������� - CompareTime �� ���������
    Result:= not FirmExist(jj);
    if not Result then with arFirmInfo[jj] do Result:= (LastTestTime=DateNull)
      or not CompareTime or (not Partially and PartiallyFilled)
      or ((Now>IncMinute(LastTestTime, FirmActualInterval))
        and cntsGRB.NotManyLockConnects and cntsORD.NotManyLockConnects);
  end;
//------------------------------------------
begin
  if not Assigned(self) then Exit;
  LocalStart:= now();
  iCount:= 0;
  ibdGB:= nil;
  ibdOrd:= nil;
  ibs:= nil;
  ibsGB:= nil;
  ibsOrd:= nil;
  ibs1:= nil;
  if (pID>0) then
    if (not FirmExist(pID) and not FillNew) or not FirmNeedTesting(pID) then Exit;
  if pID<0 then FirmCode:= 'alter'
  else if pID>0 then FirmCode:= IntToStr(pID)
  else FirmCode:= fnIfStr(length(arFirmInfo)<2, 'fill_', 'test_')+
    fnIfStr(RegID>0, 'RegID='+IntToStr(RegID), 'full');
  try
    try
      ibdOrd:= cntsORD.GetFreeCnt;
      ibdGB:= cntsGRB.GetFreeCnt;
      ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibsOrd_'+nmProc+'_'+FirmCode, -1, tpRead, True);
      ibs:= fnCreateNewIBSQL(ibdGB, 'ibs_'+nmProc+'_'+FirmCode); // ��� TestFirmContracts
      ibs1:= fnCreateNewIBSQL(ibdGB, 'ibs1_'+nmProc+'_'+FirmCode); // ��� TestFirmDestPoints
      ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc+'_'+FirmCode, -1, tpRead, True);
      if Length(arFirmInfo)<2 then begin  // ��� ������ ���������
        cntsORD.TestSuspendException;
        ibsOrd.SQL.Text:= 'SELECT GEN_ID (WOFRCODEGEN, 0) FROM RDB$DATABASE';
        ibsOrd.ExecQuery;
        FirmID:= ibsOrd.fields[0].AsInteger;
        ibsOrd.Close;
        TestCacheArrayLength(taFirm, FirmID+100);
      end;
      s:= IntToStr(Cache.BonusCrncCode);
      sSqlOrd:= 'Select WOFRCODE, WOFRSKIPPROCESSING, WOFRNUMPREFIX,'+
        ' wofrblock, WOFRSUPERVISOR, WOFRActionStateText, (SELECT first 1 ORDRCONTRACT'+
        '  from ORDERSREESTR where ORDRFIRM=WOFRCODE and ORDRSTATUS='+IntToStr(orstForming)+
        '  and ORDRCURRENCY='+s+') ContUnitOrd FROM WEBORDERFIRMS';

      sSqlGb:= 'select f.FIRMCODE, f.FIRMMAINNAME, f.FIRMUPPERMAINNAME,'+ // f.FIRMMASTERCODE, f.firmchildcount,
        ' f.PMFirmFinalClient,'+  // ������� ��������� ������� UBER
        ' f.FIRMARCHIVEDKEY, f.FIRMUPPERSHORTNAME, f.FirmSendInvoice, f.FirmOrderLimit,'+
        ' iif(f.firmhostcode is null, f.FirmCode, f.firmhostcode) HOSTCODE,'+
        ' RClTpCode FirmType, br.bnrssumm, (select sum(rPInvSumm) from'+
        '   Vlad_CSS_GetFirmReserveDocsN(f.FirmCode, 0) where rPInvCrnc='+s+') UnitReserve'+
        fnIfStr(Partially, // ��� not Partially ����������� � TestFirmContracts
        ', (select sum(ResultValue) from Vlad_CSS_GetFirmReserveDocsN(f.FirmCode, 0)'+
        '  left join ConvertMoney(rPInvSumm, rPInvCrnc, '+cStrDefCurrCode+', "Now") on 1=1'+
        '  where rPInvCrnc<>'+s+') Reserve', '')+
        ' from FIRMS f left join GETFIRMCLIENTTYPE(f.firmcode, "TODAY") on 1=1'+
        ' left join BONUSREST br on br.bnrsfirmcode=f.firmcode and br.bnrssubfirmcode=1'+
        ' where f.FirmServiceFirm="F" and f.FirmOrganizationType=0'+ // ������� "����������� ������"
        '   and (f.firmchildcount=0 or not exists(select * from firms ff'+
        '   where ff.firmmastercode=f.firmcode and ff.FirmOrganizationType=0 and ff.FIRMARCHIVEDKEY="F"))';
      cntsGRB.TestSuspendException;

  //--------------------------------------- �� alter-��������  // ���� �� ��������
      if pID<0 then begin

  //------------------------------------------------------ �������� �� ���� ������
      end else if (pID=0) and (RegID<1) then begin
        ibsGB.SQL.Text:= sSqlGb+' order by FIRMMAINNAME';
        ibsGB.ExecQuery;                      // ���� �� ������ Grossbee
        while not ibsGB.Eof do begin
          FirmID:= ibsGB.fieldByName('FIRMCODE').AsInteger;
          flnew:= FillNew and not FirmExist(FirmID);
          if TestCacheArrayItemExist(taFirm, FirmID, flnew) and FirmNeedTesting(FirmID) then begin
              firma0:= arFirmInfo[FirmID];
              TestFirmDataFromGrossbee(FirmID, flnew); // �������� ���������� ����� �� Grossbee
              inc(iCount);
            end;
          cntsGRB.TestSuspendException;
          ibsGB.Next;
        end;
        ibsGB.Close;

        cntsORD.TestSuspendException;
        ibsOrd.SQL.Text:= sSqlOrd+' order by WOFRCODE';
        ibsOrd.ExecQuery;
        while not ibsOrd.Eof do begin
          FirmID:= ibsOrd.fieldByName('WOFRCODE').AsInteger;
          if FirmExist(FirmID) then begin
            firma0:= arFirmInfo[FirmID];
            TestFirmDataFromWebTables(FirmID); // ������������ ������ ���������
          end;
          cntsORD.TestSuspendException;
          ibsOrd.Next;
        end;
        ibsOrd.Close;

        TestFirmClasses(pID); // ��������� ����, VIN �������
        TestContractStores(pID); // ������ ���������� ����

        prMessageLOGS(nmProc+'_'+FirmCode+' '+IntToStr(iCount)+' �/�: - '+
          GetLogTimeStr(LocalStart)+fnIfStr(Partially, ' Partially', ''), fLogCache, false);

  //------------------------------------------------- �������� �� ������ ���������
      end else if (pID=0) and (RegID>0) then begin
        ibsGB.SQL.Text:= sSqlGb+' order by FIRMMAINNAME';
        ibsGB.ExecQuery;                      // ���� �� ������ Grossbee
        while not ibsGB.Eof do begin
          FirmID:= ibsGB.fieldByName('FIRMCODE').AsInteger;
          flnew:= FillNew and not FirmExist(FirmID);
          if TestCacheArrayItemExist(taFirm, FirmID, flnew) and FirmNeedTesting(FirmID) then begin
            firma0:= arFirmInfo[FirmID];
            TestFirmDataFromGrossbee(FirmID, flnew); // �������� ���������� ����� �� Grossbee
            if length(firma0.FirmClients)>0 then
//              TestClients(firma0.FirmClients[0], FillNew, CompareTime, Partially); // ��������� �������� �����
              TestClients(firma0.FirmClients[0], FillNew, CompareTime, firma0.PartiallyFilled); // ��������� �������� �����
            inc(iCount);
          end;
          cntsGRB.TestSuspendException;
          ibsGB.Next;
        end;
        ibsGB.Close;

        cntsORD.TestSuspendException;
        ibsOrd.SQL.Text:= sSqlOrd+' order by WOFRCODE';
        ibsOrd.ExecQuery;
        while not ibsOrd.Eof do begin
          FirmID:= ibsOrd.fieldByName('WOFRCODE').AsInteger;
          if FirmExist(FirmID) then begin
            firma0:= arFirmInfo[FirmID];
            if Firma0.CheckFirmManager(RegID) then
              TestFirmDataFromWebTables(FirmID); // ������������ ������ ���������
          end;
          cntsORD.TestSuspendException;
          ibsOrd.Next;
        end;
        ibsOrd.Close;

        TestFirmClasses(pID, RegID);      // ��������� ���� ���������, VIN �������
        TestContractStores(pID, RegID); // ������ ���������� ���� ���������

        prMessageLOGS(nmProc+'_'+FirmCode+' '+IntToStr(iCount)+'�/�: - '+
          GetLogTimeStr(LocalStart)+fnIfStr(Partially, ' Partially', ''), fLogCache, false);

  //------------------------------------------------------------- �������� 1 �����
      end else begin
        flnew:= FillNew and not FirmExist(pID); // ���� 1 �����
        if TestCacheArrayItemExist(taFirm, pID, flnew) then begin
          firma0:= arFirmInfo[pID];
          if (flnew or not CompareTime or (not Partially and firma0.PartiallyFilled) or
            (Now>IncMinute(firma0.LastTestTime, FirmActualInterval))) then try

            firma0.CS_firm.Enter; // �������� - ������ CS_firm !!!
            ibsGB.SQL.Text:= sSqlGb+' and f.FIRMCODE='+FirmCode;
            ibsGB.ExecQuery;
            if not (ibsGB.Bof and ibsGB.Eof) then begin
              PrevPartFilled:= firma0.PartiallyFilled; // ���������� ���������� ���������
              TestFirmDataFromGrossbee(pID, flnew, false); // �������� ���������� ����� �� Grossbee
            end else PrevPartFilled:= False;
            ibsGB.Close;

            cntsORD.TestSuspendException;
            ibsOrd.SQL.Text:= sSqlOrd+' where WOFRCODE='+FirmCode;
            ibsOrd.ExecQuery;
            if not (ibsOrd.Bof and ibsOrd.Eof) then
              TestFirmDataFromWebTables(pID, false); // ������������ ������ ���������
            ibsOrd.Close;

            if flnew or PrevPartFilled or cntsGRB.NotManyLockConnects then begin // ���� ���������� ��� �� ���������� ���
              TestFirmClasses(pID); // ��������� �����, VIN �������
              TestContractStores(pID); // ������ ���������� �����
            end;
          finally
            firma0.CS_firm.Leave;
          end;
        end; // if TestCacheArrayItemExist
      end;
    finally
      prFreeIBSQL(ibs);
      prFreeIBSQL(ibsGB);
      prFreeIBSQL(ibs1);
      cntsGRB.SetFreeCnt(ibdGB);
      prFreeIBSQL(ibsOrd);
      cntsORD.SetFreeCnt(ibdOrd);
    end;
    ii:= Length(arFirmInfo);
    for i:= High(arFirmInfo) downto 1 do if Assigned(arFirmInfo[i]) then begin
      ii:= arFirmInfo[i].ID+1;
      break;
    end;
    if Length(arFirmInfo)>ii then try
      CScache.Enter;
      SetLength(arFirmInfo, ii); // �������� �� ���.����
    finally
      CScache.Leave;
    end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'_'+FirmCode+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+'_'+FirmCode+': '+E.Message, fLogCache);
  end;
  TestCssStopException;
{  if flDebug then begin
    for i:= 1 to High(arFirmInfo) do if FirmExist(i) then
      if not arFirmInfo[i].Arhived then
      prMessageLOGS('  '+fnMakeAddCharStr(IntToStr(i), 7, True)+
        fnMakeAddCharStr(arFirmInfo[i].FirmTypeName, 20, True)+
        arFirmInfo[i].Name, fLogDebug, false);
  end; }
end;
//======================================================= �������� ���� ��������
procedure TDataCache.TestClients(pID: Integer; FillNew: boolean=False;
          CompareTime: boolean=True; Partially: boolean=False; pFirm: Integer=0);
// CompareTime=True - ��������� ����� ���������� ����������, False - �� ��������� (ID>0)
// ID=-1 - �� alter-��������, ID>0 - 1 ������, ID=0 - ��� ������� (����� �������� ���� ���� !!!)
// FillNew=True - ���������� �����, FillNew=False - �������� ������ ������������
// Partially=True - ��������� ��������(���), Partially=False - ������ ��������
const nmProc = 'TestClients'; // ��� ���������/�������
type
  TChange = record
    code, firmID: integer;
    name: string;
  end;
var i, pFirmID, j, j1, iCount: integer;
    UserCode, s, sSQLord, sSQLgb: string;
    ibsGB, ibsOrd: TIBSQL;
    ibdGB, ibdOrd: TIBDatabase;
    LocalStart, LocStart: TDateTime;
    Change: array of TChange;
    codes: Tai;
    flnew, PrevPartFilled: boolean;
    Client: TClientInfo;
    Firma: TFirmInfo;
//    lst: TStringList;
//-------------------------------------- �������� ���������� ������� �� Grossbee
  procedure TestClientDataFromGrossbee(Client: TClientInfo; new: boolean; InCS: boolean=True);
  var fl: boolean;
      lst: TStringList;
      iList: TIntegerList;
      s, strSMS: String;
      i, j: integer;
      obj: TObject;
  begin
    if not Assigned(Client) then Exit else with Client do try
      if InCS then CS_client.Enter;
      Post:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('PRSNPOST').AsString);
      Post:= fnReplaceQuotedForWeb(Post); // ��������� ������� ' � " � `
      Name:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('PRSNNAME').AsString);
      Name:= fnReplaceQuotedForWeb(Name); // ��������� ������� ' � " � `
//if flDebug then
//  prMessageLOGS(fnMakeAddCharStr(Name, 50, True)+' - CheckResult= '+CheckClientFIO(Name), fLogDebug, False);
      FirmID  := ibsGB.fieldByName('PRSNFIRMCODE').AsInteger;
      fl:= GetBoolGB(ibsGB, 'PRSNARCHIVEDKEY');
      if (Arhived<>fl) then Arhived:= fl;
      fl:= GetBoolGB(ibsGB, 'PrSnForPay');
      if (CliPay<>fl) then CliPay:= fl;
      //------------------------------------------------------------ Email-�
      s:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('Mails').AsString);
      lst:= fnSplit(cSplitDelim, s);
      CheckStringList(CliMails, Lst);
      DelEmptyStrings(CliMails); // ������ ������ �����
      Lst.Clear;
      //------------------------------------------------------------ ��������
      s:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('PHONEs').AsString);
      lst:= fnSplit(cSplitDelim, s);
      for i:= 0 to lst.Count-1 do begin
        j:= pos('=', lst[i]); // ������ 1 ��������
        if (j>0) then begin
          strSMS:= copy(lst[i], j+1, length(lst[i]));  // ���� SMS-��������
          lst[i]:= copy(lst[i], 1, j-1);               // �������� ����
        end else strSMS:= '';
{if flDebug then
  if CheckMobileNumber(lst[i]) then
    prMessageLOGS(nmProc+':     mobile = '+lst[i], fLogDebug, False)
  else
    prMessageLOGS(nmProc+': not mobile = '+lst[i], fLogDebug, False); }
        j:= CliPhones.IndexOf(lst[i]);
        if (j<0) then begin // �� ����� - ��������� �������
          if (strSMS<>'') then iList:= fnStrToIntegerList(strSMS) // TIntegerList �� ������ ����� ����� �������
          else iList:= TIntegerList.Create;
          CliPhones.AddObject(lst[i], iList);
        end else begin // ����� - ��������� SMS-�������
          if not Assigned(CliPhones.Objects[i]) then
            CliPhones.Objects[i]:= TIntegerList.Create;
          iList:= TIntegerList(CliPhones.Objects[i]);
          prCheckIntegerListByCodesString(iList, strSMS); // ������� TIntegerList �� ������� �����
        end;
      end; // for i:= 0 to lst.Count
      for i:= CliPhones.Count-1 downto 0 do begin
        j:= lst.IndexOf(CliPhones[i]);
        if (j>-1) then begin
          lst.Delete(j);
          Continue;
        end;
        obj:= CliPhones.Objects[i];
        CliPhones.Delete(i);                // ������� ������
        if Assigned(obj) then prFree(obj);
      end; // for i:= CliPhones.Count
      DelEmptyStrings(CliPhones, True); // ������ ������ ����� (with free Objects)
      Lst.Clear;
{      if flDebug then
        for i:= 0 to CliPhones.Count-1 do begin
          s:= CliPhones[i];
          iList:= TIntegerList(CliPhones.Objects[i]);
          if iList.count>0 then
            prMessageLOGS(nmProc+'_client_'+IntToStr(ID)+': '+s+' - sms-models = '+IntToStr(iList.count), fLogDebug);
        end; }
      //------------------------------------------------------------
      PrevPartFilled:= PartiallyFilled;
//                                    // ������ ������ � ��������� �� ������ !!!
//      if not Partially and PartiallyFilled then PartiallyFilled:= Partially;
      PartiallyFilled:= Partially;
      LastTestTime:= Now;
    finally
      if InCS then CS_client.Leave;
      prFree(lst);
    end;
  end;
//-------------------------------------- �������� ���������� ������� �� ib_ord
  procedure TestClientDataFromWebTables(Client: TClientInfo; new: boolean=false; InCS: boolean=True);
  begin
    if not Assigned(Client) then Exit else with Client do try
      if InCS then CS_client.Enter;
      Login:= ibsOrd.fieldByName('WOCLLOGIN').AsString;
      Password:= ibsOrd.fieldByName('WOCLPASSWORD').AsString;
      WareSemafor:= GetBoolGB(ibsOrd, 'WOCLWARERESTSEMAFOR');
      resetPW:= GetBoolGB(ibsOrd, 'WOCLRESETPASWORD');
      BlockKind:= ibsOrd.fieldByName('WOCLBLOCK').AsInteger;
      if ibsOrd.fieldByName('WOCLLASTACTIONTIME').AsDateTime>LastAct then
        LastAct:= ibsOrd.fieldByName('WOCLLASTACTIONTIME').AsDateTime;
      CheckBlocked(); // �������� ����������
      LastContract:= ibsOrd.fieldByName('woclLastContract').AsInteger;
      if not Partially then begin // ���� ������
        if Firma.IsFinalClient then begin
          SearchCurrencyID:= cUAHCurrency; // ������ ������ (���)
          DocsByCurrContr := True;
        end else begin
          SearchCurrencyID:= ibsOrd.fieldByName('WOCLSEARCHCURRENCY').AsInteger;
          DocsByCurrContr := GetBoolGB(ibsOrd, 'WOCLDocsByContr');
        end;
        MaxRowShowAnalogs:= ibsOrd.fieldByName('WOCLMAXROWFORSHOWANALOGS').AsInteger;
//        DEFACCOUNTINGTYPE:= ibsOrd.fieldByName('WOCLDEFAULTACCOUNTINGTYPE').AsInteger;
        DEFDELIVERYTYPE  := ibsOrd.fieldByName('WOCLDEFAULTDELIVERYTYPE').AsInteger;
        NOTREMINDCOMMENT := GetBoolGB(ibsOrd, 'WOCLNOTREMINDCOMMENT');
      end;
      if not Partially and       // ���� ������ ��������
        (new or PrevPartFilled or cntsGRB.NotManyLockConnects) then begin // ���� ���������� ��� �� ���������� ���
        UpdateStorageOrderC;
      end;
      CheckWorkLogins(ID, Login); // �������� ������ � ������ ������ �������
      LastTestTime:= Now;
    finally
      if InCS then CS_client.Leave;
    end;
  end;
//--------------------- ������� ������������� �������� �������
  function ClientNeedTesting(ii: integer): boolean;
  begin // ���� ������ ��������, � ������ �������� �������� - CompareTime �� ���������
    Result:= not ClientExist(ii);
    if not Result then with arClientInfo[ii] do
      Result:= (LastTestTime=DateNull) or not CompareTime
               or (not Partially and PartiallyFilled)
               or ((Now>IncMinute(LastTestTime, ClientActualInterval))
                 and cntsGRB.NotManyLockConnects and cntsORD.NotManyLockConnects);
  end;
//------------------------------------------
begin
  if not Assigned(self) then Exit;
  iCount:= 0;  // �������
  LocalStart:= now();
  LocStart:= now();
  ibdGB:= nil;
  ibsGB:= nil;
  ibdOrd:= nil;
  ibsOrd:= nil;
  if pID<0 then UserCode:= 'alter'
  else if (pID=0) then begin
    if (pFirm=0) then
      UserCode:= fnIfStr(arClientInfo.MaxIndex<2, 'fill_', 'test_')+'full'
    else UserCode:= 'test_f'+IntToStr(pFirm);
  end else if (pID>0) then begin
    if not ClientNeedTesting(pID) then Exit;
    UserCode:= IntToStr(pID);
  end;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': ---------- start', fLogDebug, false); // ����� � log
    LocStart:= now();
end;

  try try
    ibdOrd:= cntsORD.GetFreeCnt;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': cntsORD.GetFreeCnt - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
    ibdGB:= cntsGRB.GetFreeCnt;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': cntsGRB.GetFreeCnt - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;

    ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibsOrd_'+nmProc+'_'+UserCode, -1, tpRead, True);
    ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc+'_'+UserCode, -1, tpRead, True);

    if (arClientInfo.MaxIndex<2) then begin // ��� ������ ���������
                                            // ��������� �������� ����������� �����
      ibsGB.SQL.Text:= 'SELECT PRSNCODE from PERSONS'+
        ' inner join FIRMS on FIRMCODE=PRSNFIRMCODE and FirmOrganizationType=0'+
        ' and (firmchildcount=0 or not exists(select * from firms ff'+
        '   where ff.firmmastercode=firmcode and ff.FirmOrganizationType=0))'+
        ' order by PRSNCODE';
      ibsGB.ExecQuery;
      i:= 0;
      j:= 0;
      while not ibsGB.Eof do begin
        j:= ibsGB.fieldByName('PRSNCODE').AsInteger;
        if (j-i)>30000 then break;
        i:= j;
        TestCssStopException;
        ibsGB.Next;
      end;
      ibsGB.Close;
      arClientInfo.SetCalcBounds(i, j);

      ibsOrd.SQL.Text:= 'SELECT GEN_ID (WOCLCODEGEN, 0) FROM RDB$DATABASE';
      ibsOrd.ExecQuery;
      i:= ibsOrd.fields[0].AsInteger;
      ibsOrd.Close;
      arClientInfo.TestMaxCode(i);
    end;
    setlength(Change, 0);
    setlength(codes, 100);

    sSQLord:= 'Select WOCLCODE, WOCLLOGIN, WOCLPASSWORD, WOCLDEFAULTACCOUNTINGTYPE,'+
      ' WOCLDEFAULTDELIVERYTYPE, WOCLMAXROWFORSHOWANALOGS, WOCLNOTREMINDCOMMENT,'+
      ' WOCLSEARCHCURRENCY, WOCLWARERESTSEMAFOR, woclLastContract, WOCLLASTACTIONTIME,'+
      ' WOCLBLOCK, WOCLFIRMCODE, WOCLDocsByContr, WOCLRESETPASWORD FROM WEBORDERCLIENTS';

    sSQLgb:= 'select PRSNCODE, PRSNNAME, PRSNFIRMCODE, PRSNPOST, PRSNARCHIVEDKEY,'+
      ' PrSnForPay, (select LIST(PEEMAIL, "'+cSplitDelim+'") from PERSONEMAILS'+
      '   where PEPERSONCODE=PRSNCODE and PEARCHIVEDKEY="F") MAILs,'+
      // ��������� ������: phone1=smsmodel11,smsmodel12,...~phone2=smsmodel12,smsmodel22,...
      ' (select LIST(PPHPHONE||iif(exists(select * from PERSONPHONESSMSMODELLINK'+
      '   where psmlpersonphonecode=pphcode), "="||(select list(psmlsmsmodel, ",")'+
      '   from PERSONPHONESSMSMODELLINK where psmlpersonphonecode=pphcode), ""), "'+
      cSplitDelim+'") from PERSONPHONES'+
      ' where PPHPERSONCODE=PRSNCODE and PPHARCHIVEDKEY="F") PHONEs from PERSONS';

//------------------------------------------------------------ �� alter-��������
    if pID<0 then begin

//------------------------------------------------------------------ ��� �������
    end else if (pID=0) and (pFirm=0) then begin
      ibsGB.SQL.Text:= sSQLgb+
        ' inner join FIRMS on FIRMCODE=PRSNFIRMCODE and FirmOrganizationType=0'+
        ' and (firmchildcount=0 or not exists(select * from firms ff'+
        '   where ff.firmmastercode=firmcode and ff.FirmOrganizationType=0))'+
        ' order by PRSNFIRMCODE';
      ibsGB.ExecQuery;                     // ��������� ��������� �� Grossbee
      setlength(codes, 100);
      if not ((ibsGB.Bof and ibsGB.Eof)) then repeat
        pFirmID:= ibsGB.fieldByName('PRSNFIRMCODE').AsInteger;
        j:= 0; // ������� �������� �����
        if not FirmExist(pFirmID) then begin
          TestCssStopException;
          while not ibsGB.Eof and (pFirmID=ibsGB.fieldByName('PRSNFIRMCODE').AsInteger) do ibsGB.Next;
        end else begin
          Firma:= arFirmInfo[pFirmID];
          Firma.CS_firm.Enter; // ��������� �����, ����� �� ����� ������ �� ����������
          try
            while not ibsGB.Eof and (pFirmID=ibsGB.fieldByName('PRSNFIRMCODE').AsInteger) do begin
              i:= ibsGB.fieldByName('PRSNCODE').AsInteger;
              flnew:= FillNew and not ClientExist(i); // ������� ��������������� ����������
              if TestCacheArrayItemExist(taClie, i, flnew)
                and (flnew or ClientNeedTesting(i)) then begin
                Client:= arClientInfo[i];
                TestClientDataFromGrossbee(Client, flnew); // �������� ���������� ������� �� Grossbee
                if not Client.Arhived then begin  // ���� ���������� ���������
                  if High(codes)>j then SetLength(codes, j+100);
                  codes[j]:= i;
                  inc(j);
                end;
                inc(iCount);
              end;
              cntsGRB.TestSuspendException;
              ibsGB.Next;
            end; // while not ibsGB.Eof and (FirmID=ibsGB.fieldByName('PRSNFIRMCODE').AsInteger)
            Firma.TestFirmClients(codes, j, false); // ��������� ������ ����� ����������� �����
          finally
            Firma.CS_firm.Leave;
          end;
        end;
      until ibsGB.Eof;
      ibsGB.Close;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': ibsGB read (all) - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;

      ibsOrd.SQL.Text:= sSQLord;
      ibsOrd.ExecQuery;                            // ��������� ��������� �� ib_ord
      while not ibsOrd.Eof do begin
        i:= ibsOrd.fieldByName('WOCLCODE').AsInteger; // ������������ ������ ���������
        if ClientExist(i)  then begin
          Client:= arClientInfo[i];
          if FirmExist(Client.FirmID) then begin
            Firma:= arFirmInfo[Client.FirmID];
            TestClientDataFromWebTables(Client); // �������� ���������� ������� �� ib_ord
            if (Client.FirmID<>ibsOrd.fieldByName('WOCLFIRMCODE').AsInteger) then begin
              j1:= Length(Change); // ����������, ���� ���� �������� � ib_ord
              SetLength(Change, j1+1);
              Change[j1].code:= i;
              Change[j1].firmID:= Client.FirmID;
              Change[j1].name:= Client.Name;
            end;
          end;
        end;
        cntsORD.TestSuspendException;
        ibsOrd.Next;
      end;
      ibsOrd.Close;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': ibsOrd read (all) - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
      prMessageLOGS(nmProc+'_'+UserCode+' '+IntToStr(iCount)+' ��: - '+
        GetLogTimeStr(LocalStart)+fnIfStr(Partially, ' Partially', ''), fLogCache, false);

//------------------------------------------------------------- ������� 1 �����
    end else begin
      if (pID=0) and (pFirm>0) then pFirmID:= pFirm
      else begin
        ibsGB.SQL.Text:= 'select PRSNFIRMCODE from PERSONS where PRSNCODE='+UserCode;
        ibsGB.ExecQuery;
        if (ibsGB.Bof and ibsGB.Eof) then
          raise Exception.Create(MessText(mtkNotClientExist, UserCode));
        pFirmID:= ibsGB.fieldByName('PRSNFIRMCODE').AsInteger;
        ibsGB.Close;
      end;
      s:= IntToStr(pFirmID);

      TestFirms(pFirmID, FillNew, CompareTime, Partially);

      j:= 0; // ������� �������� �����
      if FirmExist(pFirmID) then begin        // ��������� ���� �� �����
        Firma:= arFirmInfo[pFirmID];
        ibsOrd.SQL.Text:= sSQLord+' where WOCLCODE=:WOCLCODE';
        ibsOrd.Prepare;
        ibsGB.SQL.Text:= sSQLgb+' WHERE PRSNFIRMCODE='+s;
        Firma.CS_firm.Enter; // ��������� �����, ����� �� ����� ������ �� ����������
        try
          ibsGB.ExecQuery;                   // ��������� ��������� �� Grossbee
          while not ibsGB.Eof do begin
            i:= ibsGB.fieldByName('PRSNCODE').AsInteger;
            flnew:= FillNew and not ClientExist(i); // ������� ��������������� ����������
            if TestCacheArrayItemExist(taClie, i, flnew)
              and (flnew or ClientNeedTesting(i)) then begin
              Client:= arClientInfo[i];
              try
                Client.CS_client.Enter;
                TestClientDataFromGrossbee(Client, flnew, false); // �������� ���������� ������� �� Grossbee
                if not Client.Arhived then begin  // ���� ���������� ���������
                  if High(codes)>j then SetLength(codes, j+100);
                  codes[j]:= i;
                  inc(j);
                end;
                ibsOrd.ParamByName('WOCLCODE').AsInteger:= i;
                ibsOrd.ExecQuery;
                if not (ibsOrd.Bof and ibsOrd.Eof) then begin
                  TestClientDataFromWebTables(Client, flnew, false); // �������� ���������� ������� �� ib_ord
                  if (pFirmID<>ibsOrd.fieldByName('WOCLFIRMCODE').AsInteger) then begin
                    j1:= Length(Change); // ����������, ���� ���� �������� � ib_ord
                    SetLength(Change, j1+1);
                    Change[j1].code:= i;
                    Change[j1].firmID:= pFirmID;
                    Change[j1].name:= Client.Name;
                  end;
                end;
                ibsOrd.Close;
              finally
                Client.CS_client.Leave;
              end;
            end;
            cntsGRB.TestSuspendException;
            ibsGB.Next;
          end; // while not ibsGB.Eof
          ibsGB.Close;
          Firma.TestFirmClients(codes, j, false); // ��������� ������ ����� ����������� �����
        finally
          Firma.CS_firm.Leave;
        end;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': (firm '+IntToStr(pFirmID)+') - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
      end; // if FirmExist(FirmID)
    end;
    arClientInfo.CutEmptyCode;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'_'+UserCode+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
  end;

  if length(Change)>0 then try  // ���� ���� ��������� � ib_ord
    fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
    ibsOrd.SQL.Text:= 'Update WEBORDERCLIENTS set WOCLFIRMCODE=:WOCLFIRMCODE where WOCLCODE=:WOCLCODE';
    ibsOrd.Prepare;
    for j:= 0 to High(Change) do if Change[j].code>0 then try
      with ibsOrd.Transaction do if not InTransaction then StartTransaction;
      ibsOrd.ParamByName('WOCLCODE').AsInteger:= Change[j].code;
      ibsOrd.ParamByName('WOCLFIRMCODE').AsInteger:= Change[j].firmID;
      ibsOrd.ExecQuery;
      ibsOrd.Transaction.Commit;
      ibsOrd.Close;
    except
      on E: Exception do begin
        ibsOrd.Transaction.Rollback;
        prMessageLOGS('Update '+IntToStr(Change[j].code)+' '+Change[j].name+': '+E.Message, fLogCache);
      end;
    end;
{    if flDebug then if (pID=0) and (pFirm=0) then
    try
      lst:= TStringList.Create;
      for j1:= 1 to High(Cache.arFirmInfo) do if Cache.FirmExist(j1) then begin
        Firma:= Cache.arFirmInfo[j1];
        if Firma.Arhived then Continue;
        for j:= 0 to High(Firma.FirmClients) do
          if Cache.ClientExist(Firma.FirmClients[j]) then begin
            Client:= Cache.arClientInfo[Firma.FirmClients[j]];
            if not Client.Arhived then Continue;
            for i:= 0 to Client.CliMails.Count-1 do begin
              s:= Client.CliMails[i];
              if not fnCheckEmail(s) then
                lst.Add(IntToStr(Firma.ID)+';'+Firma.Name+';'+IntToStr(Client.ID)+';'+Client.Name+';'+s);
  //              prMessageLOGS(nmProc+'_client'+IntToStr(ID)+': not correct Email '+s, fLogDebug);
            end;
          end;
      end;

      if lst.Count>0 then lst.SaveToFile('d:\notcorrectemals.csv');
    finally
      prFree(lst);
    end;            }

if flLogTestClients then begin
    prMessageLOGS(nmProc+': ibsOrd write - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
//    LocStart:= now();
end;

  except
    on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ibsGB);     // ��������� �������� Grossbee
    cntsGRB.SetFreeCnt(ibdGB);
    prFreeIBSQL(ibsOrd);     // ��������� ������� ib_ord
    cntsORD.SetFreeCnt(ibdOrd);
    setlength(Change, 0);
    setlength(codes, 0);
  end;
  TestCssStopException;
end;
//========================================= �������� / ���������� ������ �������
procedure TDataCache.FillWareFiles(fFill: Boolean=True);
const nmProc = 'FillWareFiles'; // ��� ���������/�������/������
var ORD_IBS: TIBSQL;
    ORD_IBD: TIBDatabase;
    TimeProc: TDateTime;
    iCount, wareID, fileID, srcID: Integer;
    flLinkURL: Boolean;
    nlinks: TLinks;
    p: Pointer;
    s: String;
    ware: TWareInfo;
begin
  if not Assigned(self) then Exit;
  iCount:= 0;
  TimeProc:= Now;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  with FWareFiles do try try
  if not fFill then SetDirStates(False);

  ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
    ORD_IBS.SQL.Text:= 'select WGFCODE, WGFSupTD, WGFFileName, WGFHeadID,'+
      ' WGFSRCLECODE from WareGraFiles';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      p:= TWareFile.Create(ORD_IBS.FieldByName('WGFCODE').AsInteger,
        ORD_IBS.FieldByName('WGFSupTD').AsInteger,       // SubCode (supID TecDoc !!!)
        ORD_IBS.FieldByName('WGFHeadID').AsInteger,      // OrderNum
        ORD_IBS.FieldByName('WGFFileName').AsString,     // Name
        ORD_IBS.FieldByName('WGFSRCLECODE').AsInteger);
      CheckItem(p);
      Inc(iCount);
      cntsORD.TestSuspendException;
      ORD_IBS.Next;
    end; // while ...
    ORD_IBS.Close;
    CheckLength;  // DelDirNotTested - ����� �������� ������
    s:= IntToStr(iCount)+' ������, ';

    iCount:= 0;
    ORD_IBS.SQL.Text:= 'select LWGFWGFCODE, LWGFWareID, LWGFLinkURL, LWGFSRCLECODE'+
      ' from LinkWareGraFiles inner join WareOptions on wowarecode=LWGFWareID and WOARHIVED="F"'+
       ' where LWGFWRONG="F" order by LWGFWareID';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      wareID:= ORD_IBS.FieldByName('LWGFWareID').AsInteger; // ��� ������
      if WareExist(wareID) then begin
        ware:= GetWare(wareID, True);
        if ware.IsArchive or (ware=NoWare) then ware:= nil;
      end else ware:= nil;
      if not Assigned(ware) then begin
        TestCssStopException;
        while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('LWGFWareID').AsInteger) do ORD_IBS.Next;
        Continue;
      end;

      nlinks:= ware.FileLinks;
      if not fFill then nlinks.SetLinkStates(False);
      while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('LWGFWareID').AsInteger) do begin
        fileID:= ORD_IBS.FieldByName('LWGFWGFCODE').AsInteger; // ��� �����
        if FWareFiles.ItemExists(fileID) then begin
          srcID:= ORD_IBS.FieldByName('LWGFSRCLECODE').AsInteger;
          flLinkURL:= GetBoolGB(ORD_IBS, 'LWGFLinkURL');
          p:= FWareFiles[fileID];
          with nlinks do if not fFill and LinkExists(fileID) then try
            CS_Links.Enter;
            with TFlagLink(nlinks[fileID]) do begin
              if SrcID  <>srcID     then SrcID  := srcID;
              if LinkPtr<>p         then LinkPtr:= p;
              if Flag   <>flLinkURL then Flag   := flLinkURL;
              State:= True;
            end;
            if not TDirItem(p).State then TDirItem(p).State:= True; // �� ���� ������
          finally
            CS_Links.Leave;
          end else AddLinkItem(TFlagLink.Create(srcID, p, flLinkURL));
          Inc(iCount);
        end;
{if flDebug then begin
  if (ware.FileLinks.LinkCount>0)
    and not FileExists('S:\home\prg01_orders\www\wareimages\'+IntToStr(wareID)+'.jpg') then
    prMessageLOGS(IntToStr(ware.ID)+': '+ware.Name, fLogDebug, false);
end; // if flDebug   }
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end; // while ... and (wareID=

      if not fFill then nlinks.DelNotTestedLinks;
    end; // while ...
    ORD_IBS.Close;
    if not fFill then DelDirNotTested; // ����� �������� ������
  finally
    prFreeIBSQL(ORD_IBS);
    cntsOrd.SetFreeCnt(ORD_IBD);
  end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
//  prMessageLOGS(nmProc+': '+IntToStr(iCount)+' ������ - '+GetLogTimeStr(TimeProc), fLogCache, false);
  prMessageLOGS(nmProc+': '+s+IntToStr(iCount)+' ��. - '+GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;
//=============================== ����������/�������� ������ � ��������� �������
procedure TDataCache.TestWareRests(CompareTime: boolean=True);
const nmProc = 'TestWareRests'; // ��� ���������/�������/������
var Store, kod, wCount: integer;
    flFill: boolean;
    sd, ss, sDprts: string;
    ibs: TIBSQL;
    ibd: TIBDatabase;
    qty: double;
    Ware: TWareInfo;
    rLinks: TLinks;
    LocalStart: TDateTime;
begin
  if not Assigned(self) then Exit;
  if not (AllowWeb or AllowWebArm) then Exit; // ������ Web ��� WebArm
  flFill:= (LastTestRestTime=DateNull);
  if flFill then ss:= '_fill'
  else begin                              // ���� ���� ���������
    if CompareTime and ((IncMinute(LastTestRestTime, GetConstItem(pcTestRestsIntMinute).IntValue))>Now) then Exit;
    ss:= '_test';
  end;
  ibd:= nil;
  ibs:= nil;
  wCount:= 0;
  LocalStart:= now();
  try try
    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);

    sDprts:= '';
if flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetWareDprtRests') then begin
{ ������������: 95515 - ����������� "�������" }

    if AllowWebArm then sDprts:= '1' else sDprts:= '0'; // ������ � ���� ��� ������ ������

    if flFill then begin // ���������� - ������ ��������� �������
      ibs.SQL.Text:= 'select Rware, Rstore, Rmarket'+
                     ' from Vlad_CSS_GetWareDprtRests(0, '+sDprts+', null)';
    end else begin // �������� - ������ �� ������, ��� ��������
                                                 // ������ ������ ��� ���������
      sd:= FormatDateTime(cDateTimeFormatY4S, IncMinute(LastTestRestTime, -1));
      ibs.SQL.Text:= 'select Rware, Rstore, Rmarket'+
                     ' from Vlad_CSS_GetWareDprtRests(2, '+sDprts+', "'+sd+'")';
    end;

end else begin
    if AllowWeb then sDprts:= 'and DprtKind=0'                   // ������ ������
    else if AllowWebArm then sDprts:= 'and DprtKind in (0, 2)';  // ������ � ����
    ibs.ParamCheck:= False;
    if flFill then begin // ���������� - ������ ��������� �������
      ibs.SQL.Add('execute block returns (Rware integer, Rstore integer, Rmarket double precision)');
      ibs.SQL.Add('as declare variable XCoeff integer=1; begin');
      ibs.SQL.Add('for select RestWareCode, RestDprtCode, Rest, MeasCoefficient from');
      ibs.SQL.Add('  (select RestWareCode, RestDprtCode,');
      ibs.SQL.Add('    SUM(RestCurrent-RestOrder-RESTPLANOUTPUT-RestPlanTransfer) as Rest');
      ibs.SQL.Add('    from WAREREST inner join DEPARTMENT on DPRTCODE=RestDprtCode');
      ibs.SQL.Add('      where RestSubFirmCode=1 and not DprtKind is null '+sDprts);
      ibs.SQL.Add('    group by RestWareCode, RestDprtCode order by RestWareCode)');
      ibs.SQL.Add('  left join wares w on w.warecode=RestWareCode');
      ibs.SQL.Add('  left join VLADPGR pg on pg.KODPGR=w.waremastercode');
      ibs.SQL.Add('  left join VLADGR g on g.KODGR=pg.KODGR');
      ibs.SQL.Add('  left join MEASURE on MeasCode=w.WareMeas');
      ibs.SQL.Add('  where w.warearchive="F" and w.WARECHILDCOUNT=0');
      ibs.SQL.Add('    and (g.KODTG='+IntToStr(codeTovar)+' or w.warebonus="T")');
      ibs.SQL.Add('  into :Rware, :Rstore, :Rmarket, :XCoeff do if (Rmarket<>0) then begin');
      ibs.SQL.Add('    if (XCoeff>1) then Rmarket=ROUNDSUMMWITHSHIFT(Rmarket/XCoeff); suspend; end end');

    end else begin // �������� - ������ �� ������, ��� ��������
      sd:= FormatDateTime(cDateTimeFormatY4S, IncMinute(LastTestRestTime, -1)); // ������ ������ ��� ���������
      ibs.SQL.Add('execute block returns (Rware integer, Rstore integer, Rmarket double precision)');
      ibs.SQL.Add('as declare variable xTime timestamp = "'+sd+'"; begin');
      ibs.SQL.Add(' for select coalesce(WACACODE, 0), coalesce(DPRTCODE, 0),');
      ibs.SQL.Add('  (select SUM(RestCurrent-RestOrder-RESTPLANOUTPUT-RestPlanTransfer)');
      ibs.SQL.Add('    from WAREREST where RestSubFirmCode=1 and');
      ibs.SQL.Add('    RestWareCode=WACACODE and RestDprtCode=DPRTCODE) Rmarket');
      ibs.SQL.Add('  from (select WACACODE from (select WACACODE');
      ibs.SQL.Add('    from WARECACHE_VLAD where WACARESTUPDATETIME>:xTime');
//if TestRDB(CntsGRB, trkField, 'WARECACHE_VLAD', 'WACAWAREALTERTIME') then begin // ������� � WAREALTER �� WARECACHE_VLAD
//      ibs.SQL.Add('      or WACAWAREALTERTIME>:xTime');  // ���� �������, �.�. WAREALTER ������������ � NormExp
//end else begin
      ibs.SQL.Add('    union select wa.warealterwarecode WACACODE from wareAlter wa');
      ibs.SQL.Add('      where wa.warealtertime>:xTime');
//end;
      ibs.SQL.Add('    union select w1.warecode WACACODE from VladgrAlter va');
      ibs.SQL.Add('      left join wares w1 on w1.waremastercode = va.vgalterkodpgr');
      ibs.SQL.Add('      where va.vgalterdate>:xTime and va.vgalterkodpgr>0');
      ibs.SQL.Add('        and va.vgalterattr=2) group by WACACODE order by WACACODE)');
      ibs.SQL.Add('  left join wares w on w.warecode=WACACODE');
      ibs.SQL.Add('  left join VLADPGR pg on pg.KODPGR=w.waremastercode');
      ibs.SQL.Add('  left join VLADGR g on g.KODGR=pg.KODGR');
      ibs.SQL.Add('  left join DEPARTMENT on not DprtKind is null '+sDprts);
      ibs.SQL.Add('    and exists(select * from WAREREST where RestSubFirmCode=1');
      ibs.SQL.Add('      and RestWareCode=WACACODE and RestDprtCode=DPRTCODE)');
      ibs.SQL.Add('  where w.warearchive="F" and w.WARECHILDCOUNT=0');
      ibs.SQL.Add('    and (g.KODTG='+IntToStr(codeTovar)+' or w.warebonus="T")');
      ibs.SQL.Add('  into :Rware, :Rstore, :Rmarket do if (Rware>0 and Rstore>0) then suspend; end');
    end;
end; // if flShowWareByState

    ibs.ExecQuery;       // ��������� ������ �������� �� Grossbee
    while not ibs.Eof do begin
      kod:= ibs.FieldByName('Rware').AsInteger;
      Ware:= GetWare(kod, True);
      if (Ware=NoWare) or not Ware.IsMarketWare then begin
        TestCssStopException;
        while not ibs.Eof and (kod=ibs.FieldByName('Rware').AsInteger) do ibs.Next;
        Continue;
      end;

      rLinks:= Ware.RestLinks;
      if not flFill then rLinks.SetLinkStates(False);
      while not ibs.Eof and (kod=ibs.FieldByName('Rware').AsInteger) do begin
        Store:= ibs.FieldByName('Rstore').AsInteger;
        qty:= ibs.FieldByName('Rmarket').AsFloat;
        CheckWareRest(rLinks, Store, qty);
        ibs.Next;
      end;
      if not flFill then rLinks.DelNotTestedLinks;
      inc(wCount); // ������� ����������� �������
      cntsGRB.TestSuspendException;
   end;
    ss:= ss+'('+IntToStr(wCount)+'): ';
    LastTestRestTime:= Now;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ibs);
    cntsGRB.SetFreeCnt(ibd, True);
  end;
  prMessageLOGS(nmProc+ss+' - '+GetLogTimeStr(LocalStart), fLogCache, false); // ����� � log
  TestCssStopException;
end;
//================================ ��������� / ��������� �������� ������� ������
procedure TDataCache.CheckWareRest(wrLinks: TLinks; dprtID: Integer; pQty: Double; dec: Boolean=False);
const nmProc = 'CheckWareRest'; // ��� ���������/�������/������
// ���������� False, ���� ������ �� �������, ��� dec=False ����������� State:= True
var link: TQtyLink;
    NewQty: Double;
    Dprt: TDprtInfo;
begin
  if not Assigned(self) or not Assigned(wrLinks) then Exit;
  if not DprtExist(dprtID) then Exit;

  with wrLinks do try
    if not LinkExists(dprtID) then begin // ���� ����� �� ������� ���
      if not fnNotZero(pQty) then Exit;  // ��������� ���-��

      Dprt:= arDprtInfo[dprtID];         // ��������� �����
      if not (Dprt.IsStoreHouse or (AllowWebArm and Dprt.IsStoreRoad)) then Exit;

      NewQty:= fnIfDouble(dec, -pQty, pQty);
      if (NewQty>0) then AddLinkItem(TQtyLink.Create(0, NewQty, Dprt)); // ��������� ����
      Exit;
    end;

    link:= Items[dprtID]; // ���� �� �������
    NewQty:= fnIfDouble(dec, link.Qty-pQty, pQty);
    if (NewQty<0) then NewQty:= 0;

    if not fnNotZero(NewQty) then begin  // ���� ����� ���-�� = 0
      DeleteLinkItem(link);
      Exit;
    end;

    if fnNotZero(link.Qty-NewQty) then try // ���� ����� ���-�� <> ������� - ������
      CS_links.Enter;
      link.Qty:= NewQty;
    finally
      CS_links.Leave;
    end;
    if not dec then link.State:= True; // ������� ��������
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//=========================================== �������� ������� ������ �� �������
function TDataCache.GetWareRestsByStores(pWareID: Integer; WithNegative: Boolean=False): TObjectList; // must Free
const nmProc = 'GetWareRestsByStores';
var i: Integer;
    p: Pointer;
    ware: TWareInfo;
    pQty: Single;
begin
  Result:= TObjectList.Create;
  if not Assigned(self) or not WareExist(pWareID) then Exit;
  try
    ware:= GetWare(pWareID, True);
    if not Assigned(ware) or (Ware=NoWare) or Ware.IsArchive or not Assigned(ware.RestLinks) then Exit;
    with Ware.RestLinks do begin
      if (LinkCount<1) then Exit;
      CS_links.Enter;
      try
        for i:= 0 to LinkCount-1 do begin
          p:= ListLinks[i];
          pQty:= GetLinkQty(p);
          if (pQty<0) and not WithNegative then Continue;
          Result.Add(TCodeAndQty.Create(GetLinkID(p), pQty));
        end;
      finally
        CS_links.Leave;
      end;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
end;
//========================================================
procedure TDataCache.FillWareTypes(GBIBS: TIBSQL);
const nmProc = 'FillWareTypes'; // ��� ���������/�������
var Code: integer;
    flnew: Boolean;
    pCountLimit, pWeightLimit: Single;
begin
  if not Assigned(self) or not Assigned(GBIBS) then exit;
//if flDebug then prMessageLOGS('------------------- FillWareTypes', fLogDebug, false); // ����� � log
  try
    Code:= GetConstItem(pcWareTypeRootCode).IntValue;
    with GBIBS.Transaction do if not InTransaction then StartTransaction;
    GBIBS.SQL.Clear;
    GBIBS.ParamCheck:= False;
    GBIBS.SQL.Add('execute block returns (Rcode integer, Rname varchar(100),');
    GBIBS.SQL.Add(' CountLimit double precision, WeightLimit double precision)');
    GBIBS.SQL.Add(' as declare variable xMasterCode integer='+IntToStr(Code)+';');
    GBIBS.SQL.Add('  declare variable xCode integer=0; declare variable xChild integer=0;');
    GBIBS.SQL.Add('  declare variable xStr varchar(10)="";');
    GBIBS.SQL.Add('  declare variable xStrCodes varchar(2048)=""; begin');
    GBIBS.SQL.Add('  while (xMasterCode>0) do begin');
    GBIBS.SQL.Add('    if (exists(select * from WARES where WAREMASTERCODE=:xMasterCode)) then begin');
    GBIBS.SQL.Add('      for select WARECODE, WAREOFFICIALNAME, WARECHILDCOUNT from WARES');
    GBIBS.SQL.Add('        where WAREMASTERCODE=:xMasterCode into :Rcode, :Rname, :xChild do begin');
    GBIBS.SQL.Add('        if (xChild>0) then begin');  // ������������ ����������
    GBIBS.SQL.Add('          if (xStrCodes="") then xStrCodes=cast(Rcode as varchar(10));');
    GBIBS.SQL.Add('          else xStrCodes=xStrCodes||","||cast(Rcode as varchar(10));');
    GBIBS.SQL.Add('        end else begin CountLimit=0; WeightLimit=0;');  // ������ ���-�� � ����
    GBIBS.SQL.Add('          select wrlmwarecount, wrlmwareweight from PMWareLimit');
    GBIBS.SQL.Add('            where wrlmwaremastercode=:Rcode and wrlmarchivedkey="F"');
    GBIBS.SQL.Add('          into :CountLimit, :WeightLimit; suspend; end end end'); // �������� ��������
    GBIBS.SQL.Add('    if (xStrCodes="") then xStr="";');
    GBIBS.SQL.Add('    else begin xChild=position("," IN xStrCodes);');
    GBIBS.SQL.Add('      if (xChild<1) then begin xStr=xStrCodes; xStrCodes=""; end');
    GBIBS.SQL.Add('      else begin xStr=SUBSTRING(xStrCodes FROM 1 FOR xChild-1);');
    GBIBS.SQL.Add('        xStrCodes=SUBSTRING(xStrCodes FROM xChild+1); end end');
    GBIBS.SQL.Add('    if (xStr="") then xMasterCode=0;');
    GBIBS.SQL.Add('    else xMasterCode=cast(xStr as varchar(10)); end end');
    GBIBS.ExecQuery;
    while not GBIBS.Eof do begin
      Code:= GBIBS.FieldByName('Rcode').AsInteger;
      flnew:= true;
      if not TypeExists(Code) or not arWareInfo[Code].State then
        if TestCacheArrayItemExist(taWare, Code, flnew) then
          with arWareInfo[Code] do try
            CS_wares.Enter;
            IsType:= True;
            Name:= GBIBS.FieldByName('Rname').AsString;
            pCountLimit:= GBIBS.FieldByName('CountLimit').AsFloat;
            pWeightLimit:= GBIBS.FieldByName('WeightLimit').AsFloat;
                                 // ��������� ���� ������ (�� ����� ��� �������)
            if not Assigned(FTypeOpts) then begin
              FTypeOpts:= TWareTypeOpts.Create(pCountLimit, pWeightLimit);

{if flDebug then if (CountLimit>0) or (WeightLimit>0) then
  prMessageLOGS(nmProc+': '+Name+' - CountLimit='+FloatToStr(CountLimit)+
    ', WeightLimit='+FloatToStr(WeightLimit), fLogDebug, false); // ����� � log
}
            end else begin
              CountLimit:= pCountLimit;
              WeightLimit:= pWeightLimit;
            end;
            State:= True;
          finally
            CS_wares.Leave;
          end; // with arWareInfo[Code]
      TestCssStopException;
      GBIBS.Next;
    end;
  except
    on E:Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  GBIBS.Close;
end;
//======================================================== ��������� ��� �������
procedure TDataCache.TestWares(flFill: Boolean=True);
const nmProc = 'TestWares'; // ��� ���������/�������/������
var i, j, ii, jj, k, jm, jam, iGr, kGr, kPgr, iaGB, iaComm, iaOrd, jtop, jp, jw, bm: integer;
    fl, flnew, fGrInfo, flDeliv, flShowByState: boolean;
    s, n, ss, ss1, ss2, ss3, s1, s2, s3, sm, st, sp, sd, sa1, sa2, sa3, sdirect, sWStat: string;
    tmpar, tmpar1, arActs, arTops: Tai;
    ibs: TIBSQL;
    ibd: TIBDatabase;
    LocalStart, LocStart: TDateTime;
    fs: TFileStream;
    Item: Pointer;
    ware, wareA, gr, pgr: TWareInfo;
    br: TBrandItem;
//    pl: TProductLine;
begin
  if not Assigned(self) then Exit;
  if flFill then s:= '_fill: ' else s:= '_test: ';
  LocalStart:= now();
  LocStart:= now();
  ibd:= nil;
  ibs:= nil;
  fs:= nil;
  ware:= NoWare;
  iaGB  := 0;
  iaComm:= 0;
  iaOrd := 0;
  SetLength(arActs, 0);
  SetLength(arTops, 0);
  try try
if flLogTestWares then
    prMessageLOGS(nmProc+s+'-------------------- start', fLogDebug, false); // ����� � log

    if not flFill then begin
      SetWaresNotTested; // ���������� ������ ��������
//      MarginGroups.SetLinkStatesAll(False);
    end;

    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc);

    if (AllowWebarm or flmyDebug) then try // ������ � Webarm, �.�. Web ������������  ???
      flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_CheckWareStates');
      if flShowByState then try
        fnSetTransParams(ibs.Transaction, tpWrite, True);
        if flFill then // ���������� - ���
          ibs.SQL.Text:= 'execute procedure Vlad_CSS_CheckWareStates(null)'
        else begin     // �������� - ������ ��, ��� ��������
          ibs.SQL.Text:= 'execute procedure Vlad_CSS_CheckWareStates(:d)';
          ibs.ParamByName('d').AsDateTime:= IncMinute(LastTimeCache, -TestCacheInterval); // �����
        end;
        ibs.ExecQuery;
        ibs.Transaction.Commit;
      finally
        fnSetTransParams(ibs.Transaction, tpRead);
      end;
    except
      on E:Exception do prMessageLOGS(nmProc+'_CheckWareStates: '+E.Message, fLogCache);
    end;

if flLogTestWares then begin
    prMessageLOGS(nmProc+' CheckWareStates - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;

    with IBS.Transaction do if not InTransaction then StartTransaction;
//------------------------------------------------- ��������� / ��������� ������
    with WareBrands do begin
      if not flFill then SetDirStates(False);
      ibs.SQL.Text:= 'Select WRBDCODE, WRBDUPPERNAME from WAREBRANDS';
      ibs.ExecQuery;
      while not ibs.EOF do begin
        i:= ibs.FieldByName('WRBDCODE').AsInteger;
        n:= fnChangeEndOfStrBySpace(ibs.FieldByName('WRBDUPPERNAME').AsString);
        Item:= TBrandItem.Create(i, n);
        CheckItem(Item);
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
      if not flFill then DelDirNotTested;
      CheckLength;
    end; // with WareBrands

    ibs.SQL.Text:= 'SELECT GEN_ID (WARECODEGEN, 0) FROM RDB$DATABASE';
    ibs.ExecQuery;
    i:= ibs.Fields[0].AsInteger;
    ibs.Close;
    TestCacheArrayLength(taWare, i+100);  // ��������� ����� �������
    prCheckLengthIntArray(arActs, i+100); // ��������� ����� �������
    prCheckLengthIntArray(arTops, i+100); // ��������� ����� �������

//---------------------------------------------- ��������� ������� ����� �������
    FillWareTypes(ibs);

    st:= IntToStr(codeTovar);
    sd:= GetConstItem(pcDeliveriesMasterCode).StrValue;
//-------------------------------------------------- ��������� ������, ���������
    iGr:= 0;  // ������� ����� � ��������

if flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetFillGroupsParams') then begin
{ ������������: 116632 - ��� ����� ��������               codeWare = 6683;
                107685 - ��� ������ �� ������ (��������)  codeInfo = 30011; }
    ibs.SQL.Text:= 'select * from Vlad_CSS_GetFillGroupsParams';
end else begin
    ibs.SQL.Text:= 'select KODPGR, pgrName, KODTG, KODGR, grName, IsDeliv'#10+
      '  from (select p2.KODPGR, w4.wareofficialname pgrName, g.KODTG, g.KODGR,'#10+
      '    w3.wareofficialname grName, 0 IsDeliv'#10+
      '    from VLADPGR p1 left join VLADPGR p2 on p2.KODPGR=p1.pgrvlad'#10+
      '    left join VLADGR g on g.KODGR=p2.KODGR'#10+
      '    left join wares w3 on w3.warecode=g.KODGR'#10+
      '    left join wares w4 on w4.warecode=p2.KODPGR'#10+
      '  union select w1.warecode KODPGR, w1.wareofficialname pgrName, '+st+' KODTG,'#10+
      '    w1.waremastercode KODGR, w2.wareofficialname grName,'#10+
      '    1 IsDeliv from wares w1 left join wares w2 on w2.warecode=w1.waremastercode'#10+
      '  where w1.warecode='+sd+') order by KODGR, KODPGR';
end;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      kGr:= ibs.FieldByName('KODGR').AsInteger; //-------------- ������ (������)
      if GrpExists(kGr) then gr:= arWareInfo[kGr] else gr:= nil;
      if not Assigned(Gr) or not gr.State then begin
        flnew:= true;
        if TestCacheArrayItemExist(taWare, kGr, flnew) then begin
          gr:= arWareInfo[kGr];
          CS_wares.Enter;
          try
            gr.IsGrp   := True;
            gr.Name    := ibs.FieldByName('grName').AsString;
            gr.PgrID   := ibs.FieldByName('KODTG').AsInteger;
            gr.IsINFOgr:= (gr.PgrID=codeInfo);
            gr.State:= True;
          finally
            CS_wares.Leave;
          end;
          inc(iGr);
        end;
      end;
      if not GrpExists(kGr) then begin
        TestCssStopException;
        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do ibs.Next;
        Continue;
      end;

      fGrInfo:= gr.IsINFOgr;
      flDeliv:= (ibs.FieldByName('IsDeliv').AsInteger=1);
//      if not gr.IsINFOgr and not flDeliv then // ���������� ����-������ � ��������
//        MarginGroups.CheckGroup(kGr); // ��������� ������ �������

      while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do begin
        kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- ���������
        if PgrExists(kPgr) then pgr:= arWareInfo[kPgr] else pgr:= nil;
        if not Assigned(Pgr) or not pgr.State then begin
          flnew:= true;
          if TestCacheArrayItemExist(taWare, kPgr, flnew) then begin
            pgr:= arWareInfo[kPgr];
            CS_wares.Enter;
            try
              pgr.IsPgr:= True;
              pgr.Name:= ibs.FieldByName('pgrName').AsString;
              pgr.PgrID:= kGr;
              pgr.IsINFOgr:= gr.IsINFOgr;
              pgr.State:= True;
            finally
              CS_wares.Leave;
            end;
            inc(iGr);
          end;
        end;                                // ���������� ����-������ � ��������
//        if PgrExists(kPgr) and not pgr.IsINFOgr and not flDeliv then
//          MarginGroups.CheckSubGroup(kGr, kPgr); // ��������� ��������� �������

        cntsGRB.TestSuspendException;
        ibs.Next;
      end; // while ... and (kGr=...
    end;
    ibs.Close;
//    MarginGroups.DelNotTestedLinksAll; // ������� �������������
//    MarginGroups.SortByName(-1); // ����������� ���

//------------------------------------ ��������� ������� � ������ ����� � ������
    sa1:= Cache.GetConstItem(pcCauseActions).StrValue;
    sa2:= Cache.GetConstItem(pcCauseCatchMoment).StrValue;
    sa3:= Cache.GetConstItem(pcCauseNews).StrValue;
    i:= Length(arWareInfo);
    prCheckLengthIntArray(arActs, i);  // ��������� ����� �������
    prCheckLengthIntArray(arTops, i);  // ��������� ����� �������

if flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetActsAndTopWares') then begin
    ibs.ParamCheck:= True;
    ibs.SQL.Text:= 'select * from Vlad_CSS_GetActsAndTopWares('+
                   IntToStr(TopActCode)+', '+sa1+', '+sa2+', '+sa3+')';
end else begin
    ibs.ParamCheck:= False;
    ibs.SQL.Text:= 'execute block returns (RWare integer, ActCode integer, Kind integer)'#10+
      ' as declare variable xMin integer=0; declare variable xGroup integer;'#10+
      ' declare variable xCodeTop integer='+IntToStr(TopActCode)+';'#10+
      ' declare variable xChild integer; begin ActCode=0; Kind=1;'#10+ // actMoment
      '  for select coalesce(WrAcCode, 0) from WareActionReestr'#10+
      '    where WrAcSubFirmCode=1 and WrAcDocmState=1 and (WrAcCauseCode='+sa2+')'#10+
      '    and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '    order by WrAcStartDate into :ActCode do'#10+
      '    if (ActCode is not null and ActCode>0) then begin'#10+
      '      for select WrAcLnWareCode from WareActionLines'#10+
      '        where WrAcLnDocmCode=:ActCode into :RWare do suspend; end'#10+
      '  ActCode=0; Kind=2;'#10+         //  actNews
      '  for select coalesce(WrAcCode, 0) from WareActionReestr'#10+
      '    where WrAcSubFirmCode=1 and WrAcDocmState=1 and (WrAcCauseCode='+sa3+')'#10+
      '      and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '    order by WrAcStartDate into :ActCode do'#10+
      '    if (ActCode is not null and ActCode>0) then begin'#10+
      '      for select WrAcLnWareCode from WareActionLines'#10+
      '        where WrAcLnDocmCode=:ActCode into :RWare do suspend; end'#10+
      '  Kind=3;'#10+                    // acts
      '  for select coalesce(WrAcLnDocmCode, 0), WrAcLnWareCode from WareActionLines'#10+
      '    inner join (select WrAcCode, WrAcStartDate from WareActionReestr'#10+
      '    left join analitdict a on a.andtcode=WrAcCauseCode'#10+
      '    left join analitdict a1 on a1.andtcode=a.andtmastercode'#10+
      '    left join analitdict a2 on a2.andtcode=a1.andtmastercode'#10+
      '    left join analitdict a3 on a3.andtcode=a2.andtmastercode'#10+
      '    left join analitdict a4 on a4.andtcode=a3.andtmastercode'#10+
      '    where WrAcSubFirmCode=1 and WrAcDocmState=1'#10+
      '      and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '      and (a.andtcode='+sa1+' or a1.andtcode='+sa1+' or a2.andtcode='+sa1+
      '      or a3.andtcode='+sa1+' or a4.andtcode='+sa1+')) on WrAcCode=WrAcLnDocmCode'#10+
      '    order by WrAcStartDate, WRACLNCode into :ActCode, :RWare do begin'#10+
      '      if (ActCode is not null and ActCode>0) then suspend; end'#10+
      '  if (xCodeTop>0) then begin select first 1 coalesce(WRACLNCode, 0)'#10+ // ���
      '    from WareActionLines where WrAcLnDocmCode=:xCodeTop order by WRACLNCode into :xMin;'#10+
      '    if (xMin is null or xMin<1) then xCodeTop=0; end'#10+
      '  if (xCodeTop>0) then begin Kind=4;'#10+ // ������� ��� ������
      '    for select WrAcLnWareCode, WRACLNCode, w.WareChildCount'#10+
      '      from WareActionLines left join wares w on w.warecode=WrAcLnWareCode'#10+
      '      where WrAcLnDocmCode=:xCodeTop and w.WareArchive="F"'#10+
      '    into :xGroup, :ActCode, :xChild do begin ActCode=ActCode-xMin+1;'#10+
      '      if (xChild=0) then begin RWare=xGroup; suspend; end else begin'#10+ // �����
      '        for select w1.WARECODE from wares w1 where w1.WareMasterCode=:xGroup'#10+ // ������
      '          and w1.WareArchive="F" and w1.WareChildCount=0 into :RWare do suspend;'#10+
      '        for select w1.WARECODE from GetAllWareGroups(:xGroup) g'#10+ // ��� ������ ������
      '          left join wares w1 on w1.WareMasterCode=g.RWareCode'#10+
      '          where w1.WareArchive="F" and w1.WareChildCount=0 into :RWare do suspend;'#10+
      '      end end end end';
end;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      i:= ibs.FieldByName('RWare').AsInteger;
      k:= ibs.FieldByName('Kind').AsInteger;
      prCheckLengthIntArray(arActs, i, 100);  // ��������� ����� �������
      prCheckLengthIntArray(arTops, i, 100);  // ��������� ����� �������
      case k of
        1,2,3: if (arActs[i]<1) then arActs[i]:= ibs.FieldByName('ActCode').AsInteger;
            4: if (arTops[i]<1) then arTops[i]:= ibs.FieldByName('ActCode').AsInteger;
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    ibs.ParamCheck:= True;

if flLogTestWares then begin
    prMessageLOGS(nmProc+': Brands/Groups/Actions - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
//------------------------------------------------------------------------------
    if not flFill then for i:= ProductLines.Count-1 downto 0 do
      TProductLine(ProductLines[i]).WareLinks.SetLinkStates(False);
    jw:= 0;   // ������� �������
    jm:= 0;   // ������� MOTO
    jam:= 0;  // ������� AUTO & MOTO
    jtop:= 0;
    jp:= 0;   // ������� ��������

//------------------------------------ ��������� ������/��������/������� ��� ���
    sWStat:= Cache.GetConstItem(pcNotShowWareStates).StrValue;
if flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetFillWaresParams') then begin
{ ������������: 116632 - ��� ����� ��������               codeWare = 6683;
                107685 - ��� ������ �� ������ (��������)  codeInfo = 30011;
  58 - ��� ������ MOTUL           123572 - ��� ��������� 07.MOTUL ����������� �������
  95515 - ����������� "�������"   34835 - ��� ��������� 03.��� ������
  69369 - ��� ��������� ������    32458 - ��� ��������� ��� ������ }
    ibs.SQL.Text:= 'select * from Vlad_CSS_GetFillWaresParams';
end else begin
    s1:= ' left join WAREGROUP wg1 on wg1.WRGRCLASSCODE='+
         GetConstItem(pcWareTypeClassCode).StrValue+' and wg1.WRGRWARECODE=w.WARECODE'#10;
    s2:= ' left join WAREGROUP wg2 on wg2.WRGRCLASSCODE='+
         GetConstItem(pcWareTOPClassCode).StrValue+' and wg2.WRGRWARECODE=w.WARECODE'#10;
    s3:= ' left join WAREGROUP wg3 on wg3.WRGRCLASSCODE='+
         GetConstItem(pcWareCutPriceClassCode).StrValue+' and wg3.WRGRWARECODE=w.WARECODE'#10;
    sm:= ' left join GETWAREMANAGER(w.warecode, "TODAY") mg on 1=1'#10;
    sp:= ' left join WareProducts on wrprregistrcode=w.wareproductscode'#10;
    sdirect:= IntToStr(cpdNotDirect);
    bm:= Cache.GetConstItem(pcMotulProdLineAndtCode).IntValue;
    ibs.ParamCheck:= False;
    ibs.SQL.Text:= 'execute block returns (KODPGR integer, KODGR integer,'#10+
      '  IsDeliv integer, WARECODE integer, WAREMEAS integer, WAREBONUS varchar(1),'#10+
      '  WrPrProductDirection integer, WARESUPPLIERNAME varchar(100), wTOP integer,'+
      '  WAREDIVISIBLE integer, WAREOFFICIALNAME varchar(100), wState integer,'#10+
      '  WARECOMMENT varchar(255), WAREMAINNAME varchar(100), WAREBRANDCODE integer,'#10+
      '  sale varchar(1), REmplCode integer, wtype integer, wCutPrice integer,'#10+
      '  wareweight double precision, WareLitrCount double precision,'+
      '  product integer, ProdLine integer)'#10+
      ' as declare variable mastercode integer;'#10+
      ' begin REmplCode=0; wtype=0; wTOP=0; IsDeliv=1; sale="F";'+ //--- ��������
      '  wCutPrice=0; WAREDIVISIBLE=1; WAREBONUS="F"; KODPGR='+sd+';'#10+
      '  wState=0; WareLitrCount=0; wareweight=0; product=0; ProdLine=0;'+
      '  select w.waremastercode from wares w where w.warecode=:KODPGR into :KODGR;'#10+
      '  for select s.* from (select coalesce(w.WARECODE, 0) WARECODE,'+
      '    coalesce(WrPrProductDirection, 0) WrPrProductDirection,'#10+
      '    (select first 1 WSState from WareState where WSWareCode=w.warecode'+
      '      and WSDate<current_timestamp order by WSDate desc) wState,'#10+
      '    w.WARESUPPLIERNAME, w.WAREMEAS, w.WAREOFFICIALNAME,'+
      '    w.WARECOMMENT, w.WAREMAINNAME, w.WAREBRANDCODE, w.wareproductscode'#10+
      '    from wares w'+sp+' where w.waremastercode=:KODPGR'+
      '      and w.WareCode>0 and w.WARECHILDCOUNT=0 and w.warearchive="F") s'#10+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE, :WrPrProductDirection, :wState, :WARESUPPLIERNAME,'#10+
      '    :WAREMEAS, :WAREOFFICIALNAME, :WARECOMMENT, :WAREMAINNAME,'+
      '    :WAREBRANDCODE, :product do suspend;'#10+

      '  IsDeliv=0; KODPGR=0; KODGR=0; WAREBONUS="T";'#10+  //---------- �������
      '  for select s.* from (select coalesce(w.WARECODE, 0) WARECODE, w.WAREMEAS,'+
      '    coalesce(WrPrProductDirection, 0) WrPrProductDirection,'#10+
      '    w.WARESUPPLIERNAME, coalesce(w.WAREDIVISIBLE, 1) WAREDIVISIBLE,'+
      '    w.WAREOFFICIALNAME, w.WARECOMMENT, coalesce(w.wareweight, 0) wareweight,'#10+
      '    w.wareproductscode, coalesce(w.WareLitrCount, 0) WareLitrCount,'+
      '    (select first 1 WSState from WareState where WSWareCode=w.warecode'+
      '      and WSDate<current_timestamp order by WSDate desc) wState,'#10+
      '    w.WAREMAINNAME, w.WAREBRANDCODE, mg.REmplCode, wg1.WRGRMASTERCODE'#10+
      '    from wares w'#10+sp+s1+sm+' where w.WareCode>0 and w.WARECHILDCOUNT=0'+
      '      and w.warearchive="F" and w.warebonus="T") s'#10+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE, :WAREMEAS, :WrPrProductDirection, :WARESUPPLIERNAME,'#10+
      '    :WAREDIVISIBLE, :WAREOFFICIALNAME, :WARECOMMENT, :wareweight, :product,'+
      '    :WareLitrCount, :wState, :WAREMAINNAME, :WAREBRANDCODE, :REmplCode, :wtype'+
      '  do suspend; WAREBONUS="F";'#10+

      '  for select p1.pgrvlad, p1.KODGR, p1.KODPGR from VLADPGR p1'+ //--- ������
      '    order by p1.KODGR, p1.pgrvlad into :KODPGR, :KODGR, :mastercode do begin'#10+
      '    for select s.* from (select coalesce(w.WARECODE, 0) WARECODE, w.WAREMEAS,'#10+
      '      w.WARESUPPLIERNAME, coalesce(WrPrProductDirection, 0) WrPrProductDirection,'+
      '      coalesce(w.WAREDIVISIBLE, 1) WAREDIVISIBLE, coalesce(wareweight, 0) wareweight,'#10+
      '      w.wareproductscode, coalesce(WareLitrCount, 0) WareLitrCount,'+
      '      w.WAREOFFICIALNAME, w.WARECOMMENT, w.WAREMAINNAME,'#10+
      '      w.WAREBRANDCODE, sl.rsalekey, mg.REmplCode, wg1.WRGRMASTERCODE,'#10+
      '      (select first 1 WSState from WareState where WSWareCode=w.warecode'+
      '        and WSDate<current_timestamp order by WSDate desc) wState,'#10+
      '      iif(w.WAREBRANDCODE<>'+IntToStr(cbrMotul)+', 0,'+ // ����������� �������
      '       (select first 1 wg4.wrgrclasscode from WAREGROUP wg4'+
      '        left join analitdict a on a.andtcode=wg4.wrgrclasscode'+
      '        where wg4.WRGRWARECODE=w.warecode and a.andtmastercode='+IntToStr(bm)+')) ProdLine,'#10+
      '       iif(wg2.WRGRCODE is null, 0, 1) wT, iif(wg3.WRGRCODE is null, 0, 1) wC'#10+
      '      from wares w'+sp+s1+s2+s3+
      '      left join GetWareSaleKey(w.warecode, "TODAY") sl on 1=1'#10+sm+
      '      where w.waremastercode=:mastercode and w.WareCode>0'+
      '        and w.WARECHILDCOUNT=0 and w.warearchive="F" and w.warebonus="F"'+
      '        and WrPrProductDirection<>'+sdirect+') s'#10+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '    into :WARECODE, :WAREMEAS, :WARESUPPLIERNAME, :WrPrProductDirection,'+
      '      :WAREDIVISIBLE, :wareweight, :product, :WareLitrCount, :WAREOFFICIALNAME,'+
      '      :WARECOMMENT, :WAREMAINNAME, :WAREBRANDCODE, :sale, :REmplCode,'+
      '      :wtype, :wState, :ProdLine, :wTOP, :wCutPrice do suspend; end end';

end;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      kGr:= ibs.FieldByName('KODGR').AsInteger;     //------------------- ������
      if (kGr>0) and not GrpExists(kGr) then gr:= nil else gr:= arWareInfo[kGr];
      if assigned(gr) and not gr.State then gr:= nil;
      if not assigned(gr) then begin
        TestCssStopException;
        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do ibs.Next;
        Continue;
      end;

      while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do begin
        kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- ���������
        if (kPgr>0) and not PgrExists(kPgr) then pgr:= nil else pgr:= arWareInfo[kPgr];
        if assigned(pgr) and not pgr.State then pgr:= nil;
        if not assigned(pgr) then begin
          while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger)
            and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do ibs.Next;
          Continue;
        end;

        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger)
          and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do begin
          i:= ibs.FieldByName('WARECODE').AsInteger; //------------------- �����
          flnew:= true;
          if TestCacheArrayItemExist(taWare, i, flnew) then begin
            ware:= arWareInfo[i];
            prCheckLengthIntArray(arActs, i, 100);  // ��������� ����� �������
            prCheckLengthIntArray(arTops, i, 100);  // ��������� ����� �������
            CS_wares.Enter;
            try
              ware.SetWareParams(kPgr, ibs, False, spWithoutPrice);
              if ware.IsPrize then begin                   //--- �������
                ware.ActionID:= arActs[i];
                ware.TopRating:= arTops[i];
                Inc(jp);
//if flDebug and (ware.ActionID>0) then
//  prMessageLOGS('   ������� '+fnMakeAddCharStr(ware.Name, 40, True)+' - ����� '+IntToStr(ware.ActionID), fLogDebug, false); // debug
              end else if (kPgr=Cache.pgrDeliv) then begin //--- ��������
                ware.TopRating:= 0;
                ware.ActionID:= 0;
                if not DeliveriesList.Find(ware.Name, ii) then
                  DeliveriesList.AddObject(ware.Name, Pointer(ware.ID));

              end else begin                               //--- �����
                ware.TopRating:= arTops[i];
                ware.ActionID:= arActs[i];
{if flDebug and (ware.ID>500000) and (ware.ID<500500) then
  prMessageLOGS(' w '+fnMakeAddCharStr(ware.Name, 30, True)+' - p '+
    cache.GetWareProductName(ware.ID), fLogDebug, false); // debug  }
                if ware.IsTop then inc(jtop);
                if ware.IsAUTOWare then begin
                  if not pgr.IsAUTOWare then pgr.IsAUTOWare:= True; // ������� AUTO ���������
                  if not gr.IsAUTOWare then gr.IsAUTOWare:= True;   // ������� AUTO ������
                end;
                if ware.IsMOTOWare then begin
                  if not pgr.IsMOTOWare then pgr.IsMOTOWare:= True; // ������� MOTO ���������
                  if not gr.IsMOTOWare then gr.IsMOTOWare:= True;   // ������� MOTO ������
                  inc(jm);                          // ������� MOTO
                  if ware.IsAUTOWare then inc(jam); // ������� AUTO - MOTO
                end;
                if flnew then begin
                  if AllowWebArm and not EmplExist(ware.ManagerID) then // ��� WebArm
                    prMessageLOGS('WareCode='+IntToStr(i)+' '+ware.Name+' - not found WareManager'+
                      fnIfStr(ware.ManagerID>0, ' EmplCode= '+IntToStr(ware.ManagerID), ''),
                      'NotWareManager', false); // ����� � log (������ ��� ��������� ����������)
                  if (ware.WareBrandID=bm) and (ware.LitrCount=0) then
                    prMessageLOGS('WareCode='+IntToStr(i)+' '+ware.Name+' - LitrCount=0',
                      fLogCache, false); // ����� � log (������ ��� ��������� ����������)
                end;
              end;
              ware.State:= True;
            finally
              CS_wares.Leave;
            end;
            inc(jw);
          end;
          cntsGRB.TestSuspendException;
          ibs.Next;
        end; // while ... (kGr=... and (kPgr=...
      end; // while ... and (kGr=...
    end;
    ibs.Close;
    ibs.ParamCheck:= True;
    if not flFill then for i:= 0 to ProductLines.Count-1 do
      TProductLine(ProductLines[i]).WareLinks.DelNotTestedLinks;

{if flDebug then for i:= 0 to ProductLines.Count-1 do begin
  pl:= TProductLine(ProductLines[i]);
  prMessageLOGS('----- ProductLine: '+fnMakeAddCharStr(pl.ID, 10)+' '+fnMakeAddCharStr(pl.Name, 30, True), fLogDebug, false); // debug
  for kGr:= 0 to pl.WareLinks.ListLinks.Count-1 do begin
    ware:= TWareInfo(TLink(pl.WareLinks.ListLinks[kGr]).LinkPtr);
    prMessageLOGS('--- ware: '+fnMakeAddCharStr(ware.Name, 30, True)+
      ', litr: '+FloatToStr(ware.LitrCount), fLogDebug, false); // debug
  end;
end; }

//------------------------------------------------------------------------------
if flLogTestWares then begin
    prMessageLOGS(nmProc+': WareParams - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;

//------------------------------------- ��������� ������/��������/������� - ����
    i:= 0;
    SetLength(arTops, 0);  // ����� ������������ ��� ������ �������� ���
    prCheckLengthIntArray(arTops, i+100); // ��������� ����� ������� � ��������� ������
    ss:= '';
    ss1:= '';
    ss2:= '';
    ss3:= '';
    flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetWaresForPrices');
    for k:= 0 to High(PriceTypes) do begin // ������ � ������� ���
      if k=0 then n:= '' else n:= IntToStr(k);
      ss:= ss+', priceEUR'+n+' double precision';
      ss1:= ss1+', coalesce(cm'+n+'.RESULTVALUE, 0)';
      if flShowByState then ss1:= ss1+' priceEUR'+n;
      ss2:= ss2+', :priceEUR'+n;
      ss3:= ss3+' left join GETWAREPRICE("TODAY", s.warecode, '+
                IntToStr(PriceTypes[k])+', s.waremeas) p'+n+' on 1=1'#10+
                ' left join ConvertMoney(p'+n+'.RPRICEWARE, p'+n+'.RCRNCCODE, '+
                cStrDefCurrCode+', "TODAY") cm'+n+' on exists(select * from'+
                ' RateCrnc where RateCrncCode=p'+n+'.RCRNCCODE)'#10;
    end;

if flShowByState then begin
{ ������������: 116632 - ��� ����� ��������      95515 - ����������� "�������"
                107685 - ��� ������ �� ������ (��������)  }
    ibs.SQL.Text:= 'select g.KODPGR, s.WARECODE'+ss1+
                   ' from Vlad_CSS_GetWaresForPrices g'+
                   ' left join wares s on s.warecode=g.warecode'+ss3;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- ���������
      if (kPgr>0) and not PgrExists(kPgr) then pgr:= nil else pgr:= arWareInfo[kPgr];
      if assigned(pgr) and not pgr.State then pgr:= nil;
      if not assigned(pgr) then begin
        TestCssStopException;
        while not ibs.EOF and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do ibs.Next;
        Continue;
      end;

      while not ibs.EOF and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do begin
        i:= ibs.FieldByName('WARECODE').AsInteger; //------------------- �����
        if WareExist(i) then begin
          ware:= arWareInfo[i];
          if not ware.IsArchive and not ware.IsINFOgr and ware.State then try
            CS_wares.Enter;
            ware.SetWareParams(kPgr, ibs, False, spOnlyPrice);
            if not flFill then begin
              prCheckLengthIntArray(arTops, i+100); // ��������� ����� �������
              arTops[i]:= 1;  // ������� �������� ���
            end;
          finally
            CS_wares.Leave;
          end;
        end; // if WareExist(i)
        cntsGRB.TestSuspendException;
        ibs.Next;
      end; // while ... (kPgr=...
    end;

end else begin  // if flShowByState
    ibs.ParamCheck:= False;
    ibs.SQL.Text:= 'execute block returns (WARECODE integer, KODPGR integer,'#10+
      ' KODGR integer'+ss+') as declare variable master integer;'+
      ' begin KODPGR='+sd+';'#10+ //----------------------------------- ��������
      '  select w.waremastercode from wares w where w.warecode=:KODPGR into :KODGR;'#10+
      '  for select s.WARECODE'+ss1+
      '    from (select coalesce(w.WARECODE, 0) WARECODE, w.waremeas,'#10+
      '      (select first 1 WSState from WareState where WSWareCode=w.warecode'#10+
      '        and WSDate<current_timestamp order by WSDate desc) wState'#10+
      '    from wares w where w.waremastercode=:KODPGR and w.WareCode>0'#10+
      '      and w.WARECHILDCOUNT=0 and w.warearchive="F") s'#10+ss3+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE'+ss2+' do suspend;'#10+
      '  KODPGR=0; KODGR=0; for select s.WARECODE'+ss1+ //-------------- �������
      '  from (select coalesce(w.WARECODE, 0) WARECODE, w.waremeas,'#10+
      '    (select first 1 WSState from WareState where WSWareCode=w.warecode'#10+
      '      and WSDate<current_timestamp order by WSDate desc) wState'#10+
      '    from wares w where w.WareCode>0 and w.WARECHILDCOUNT=0'#10+
      '      and w.warearchive="F" and w.warebonus="T") s'#10+ss3+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE'+ss2+' do suspend;'#10+
      '  for select pg.PGRvlad, pg.KODGR, pg.KODPGR from VLADPGR pg'#10+ //-- ������
      fnIfStr(flShowWareByState, '', ' inner join VLADGR gr on gr.KODGR=pg.KODGR and gr.KODTG='+IntToStr(codeTovar))+
      '  order by KODGR, PGRvlad into :KODPGR, :KODGR, :master do begin'#10+
      '    for select s.WARECODE'#10+ss1+#10+
      '    from (select coalesce(w.WARECODE, 0) WARECODE, w.waremeas,'#10+
      '      (select first 1 WSState from WareState where WSWareCode=w.warecode'#10+
      '        and WSDate<current_timestamp order by WSDate desc) wState'#10+
      '    from wares w left join WareProducts on wrprregistrcode=w.wareproductscode'#10+
      '    where w.waremastercode=:master and w.WareCode>0 and w.warearchive="F"'#10+
      '      and w.WARECHILDCOUNT=0 and w.warebonus="F"'#10+
      '      and WrPrProductDirection<>'+sdirect+') s'#10+ss3+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE'+ss2+' do suspend; end end'#10;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      kGr:= ibs.FieldByName('KODGR').AsInteger;     //------------------- ������
      if (kGr>0) and not GrpExists(kGr) then gr:= nil else gr:= arWareInfo[kGr];
      if assigned(gr) and not gr.State then gr:= nil;
      if not assigned(gr) then begin
        TestCssStopException;
        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do ibs.Next;
        Continue;
      end;

      while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do begin
        kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- ���������
        if (kPgr>0) and not PgrExists(kPgr) then pgr:= nil else pgr:= arWareInfo[kPgr];
        if assigned(pgr) and not pgr.State then pgr:= nil;
        if not assigned(pgr) then begin
          TestCssStopException;
          while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger)
            and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do ibs.Next;
          Continue;
        end;

        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger)
          and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do begin
          i:= ibs.FieldByName('WARECODE').AsInteger; //------------------- �����
          if WareExist(i) then begin
            ware:= arWareInfo[i];
            if not ware.IsArchive and not ware.IsINFOgr and ware.State then try
              CS_wares.Enter;
              ware.SetWareParams(kPgr, ibs, False, spOnlyPrice);
              if not flFill then begin
                prCheckLengthIntArray(arTops, i+100); // ��������� ����� �������
                arTops[i]:= 1;  // ������� �������� ���
              end;
            finally
              CS_wares.Leave;
            end;
          end;

          cntsGRB.TestSuspendException;
          ibs.Next;
        end; // while ... (kGr=... and (kPgr=...
      end; // while ... and (kGr=...
    end; // while not ibs.EOF
end; // if flShowByState
    ibs.Close;
    ibs.ParamCheck:= True;

    if not flFill then begin  // �������� ���� � �������������
      prCheckLengthIntArray(arTops, length(arWareInfo)); // ��������� ����� �������
      for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then begin
        ware:= arWareInfo[i];
        if not ware.IsWare or not ware.State or not Assigned(ware.FWareOpts) then Continue;
        if (arTops[i]<1) then
          for j:= 0 to High(ware.FWareOpts.FPrices) do ware.FWareOpts.FPrices[j]:= 0;
      end;
    end;
//------------------------------------------------------------------------------
if flLogTestWares then begin
    prMessageLOGS(nmProc+': WarePrices - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;

    if not flFill then DelNotTestedWares;  // ������� ������������� ������

    s:= s+IntToStr(iGr)+'g,'+IntToStr(jw)+'w('+IntToStr(jm)+'m,'+
        IntToStr(jam)+'am,'+IntToStr(jtop)+'t,'+IntToStr(jp)+'p)';
//    LocStart:= now();
    cntsGRB.TestSuspendException;


    flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_CheckWareStates');
    //------------------------------------------- ������������� ������� Grossbee
    SetWaresNotTested; // ���������� ������ �������� ������� � ��������   ???
    with ibs.Transaction do if not InTransaction then StartTransaction;
    ibs.SQL.Text:= 'Select PMWAWARECODE, PMWAWAREANALOGCODE, (AnDtSyncCode-'+
      Cache.GetConstItem(pcCrossAnalogsDeltaSync).StrValue+') SrcCode'+
      ' from PMWAREANALOGS left join AnalitDict on ANDTCODE=PMWASOURCECODE'+
      fnIfStr(flShowByState,
      ' left join warecache_vlad wc1 on wc1.wacacode=PMWAWARECODE'+
      ' left join warecache_vlad wc2 on wc2.wacacode=PMWAWAREANALOGCODE',
        ' left join wares w1 on w1.warecode=PMWAWARECODE'+
        ' left join wares w2 on w2.warecode=PMWAWAREANALOGCODE')+
      ' where PMWAISWRONG="F"'+
      fnIfStr(flShowByState,
      ' and wc1.wacawaresvkstate>0 and not wc1.wacawaresvkstate in ('+sWStat+')'+
      ' and wc2.wacawaresvkstate>0 and not wc2.wacawaresvkstate in (2,'+sWStat+')',
        ' and w1.warearchive="F" and w2.warearchive="F"')+
      ' order by PMWAWARECODE';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.FieldByName('PMWAWARECODE').AsInteger;
      fl:= WareExist(i);
      if fl then begin
        ware:= arWareInfo[i];
        fl:= (not ware.IsArchive) and Assigned(ware.AnalogLinks);
      end;
      while not ibs.Eof and (i=ibs.FieldByName('PMWAWARECODE').AsInteger) do begin
        if not fl then begin
          ibs.Next;
          Continue;
        end;
        j:= ibs.FieldByName('PMWAWAREANALOGCODE').AsInteger;
        if not WareExist(j) then begin
          ibs.Next;
          Continue;
        end;
        wareA:= arWareInfo[j];
        if wareA.IsArchive or not wareA.IsMarketWare or Ware.IsPrize then begin
          ibs.Next;
          Continue;
        end;                         // �������� ��� � �������, ���� ��� ��� ���
        ware.CheckAnalogLink(j, ibs.FieldByName('SrcCode').AsInteger);
        ibs.Next;
      end;
      cntsORD.TestSuspendException;
    end;
    if ibs.Transaction.InTransaction then ibs.Transaction.Rollback;
    ibs.Close;

    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then
      with arWareInfo[i] do if Assigned(AnalogLinks) and (AnalogLinks.LinkCount>0) then begin
        if not flFill then DelNotTestedAnalogs(True, True); // ������� ������������� �������-������
        SortAnalogsByName; // ���������� �������� �� ������������
      end; // AnalogLinks

if flLogTestWares then begin
    prMessageLOGS(nmProc+': WareAnalogs - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;

    ii:= Length(arWareInfo);
    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then begin
      ii:= arWareInfo[i].ID+1;
      break;
    end;
    if Length(arWareInfo)>ii then try
      CS_wares.Enter;
      SetLength(arWareInfo, ii); // �������� �� ���.����
    finally
      CS_wares.Leave;
    end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ibs);
    cntsGRB.SetFreeCnt(ibd, True);
    SetLength(tmpar, 0);
    SetLength(tmpar1, 0);
    SetLength(arActs, 0);
    SetLength(arTops, 0);
    if Assigned(fs) then begin
      fs.Position:= 0;
      prFree(fs);
    end;
  end;

  try try
    ibd:= cntsORD.GetFreeCnt; // �� dbOrder
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);

//if flLogTestWares then
//    prMessageLOGS(nmProc+': ORD Connect - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log

    //--------------------------------------------------------- ������ ��� �����
    WareBrands.SetDirStates(False);
    ibs.SQL.Text:= 'Select BRADCODE, BRADNAMEWWW, BRADprefix, BRADaddress,'+
                   ' BRADNotPriceLoad, BRADNOTPictShow from BRANDADDITIONDATA';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.FieldByName('BRADCODE').AsInteger;
      if WareBrands.ItemExists(i) then begin
        n:= ibs.FieldByName('BRADNAMEWWW').AsString;
        br:= WareBrands[i];
        WareBrands.CS_DirItems.Enter;
        try
          if flFill or (br.NameWWW<>n) then br.NameWWW:= n;
          ss:= ibs.FieldByName('BRADprefix').AsString;
          if flFill or (br.WarePrefix<>ss) then br.WarePrefix:= ss;
          ss:= ibs.FieldByName('BRADaddress').AsString;
          if flFill or (br.adressWWW<>ss) then br.adressWWW:= ss;
          br.DownLoadExclude:= GetBoolGB(ibs, 'BRADNotPriceLoad');
          br.PictShowExclude:= GetBoolGB(ibs, 'BRADNOTPictShow');
          br.State:= True;
        finally
          WareBrands.CS_DirItems.Leave;
        end;
      end; // if WareBrands.ItemExists(i)
      cntsORD.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    for i:= 0 to WareBrands.ItemsList.Count-1 do with TBrandItem(WareBrands.ItemsList[i]) do
      if not State then begin
        NameWWW:= '';
        WarePrefix:= '';
        adressWWW:= '';
        DownLoadExclude:= False;
      end;

    //------------------------------------------- ���� ������� TecDoc - WebArm
    if AllowWebArm then begin
      WareBrands.SetDirStates(False);
      with ibs.Transaction do if not InTransaction then StartTransaction;
      ibs.SQL.Text:= 'Select BRRPGBCODE, BRRPTDCODE from BRANDREPLACE order by BRRPGBCODE';
      ibs.ExecQuery;
      while not ibs.EOF do begin
        i:= ibs.FieldByName('BRRPGBCODE').AsInteger;
        SetLength(tmpar, 0);
        while not ibs.EOF and (i=ibs.FieldByName('BRRPGBCODE').AsInteger) do begin
          ii:= ibs.FieldByName('BRRPTDCODE').AsInteger;
          jj:= BrandTDList.IndexOfObject(Pointer(ii));
          if jj>-1 then prAddItemToIntArray(ii, tmpar);
          cntsORD.TestSuspendException;
          ibs.Next;
        end;
        if WareBrands.ItemExists(i) then with TBrandItem(WareBrands[i]) do try
          WareBrands.CS_DirItems.Enter;
          if Length(FTDMFcodes)<>Length(tmpar) then
            SetLength(FTDMFcodes, Length(tmpar));
          for i:= 0 to High(tmpar) do
            if FTDMFcodes[i]<>tmpar[i] then FTDMFcodes[i]:= tmpar[i];
          State:= True;
        finally
          WareBrands.CS_DirItems.Leave;
        end;
      end;
      ibs.Close;
      for i:= 0 to WareBrands.ItemsList.Count-1 do with TBrandItem(WareBrands.ItemsList[i]) do
        if not State and (Length(FTDMFcodes)>0) then try
          WareBrands.CS_DirItems.Enter;
          SetLength(FTDMFcodes, 0);
        finally
          WareBrands.CS_DirItems.Leave;
        end;
      WareBrands.SortDirListByName;
    end; // if AllowWebArm

    //--------------------------------------------------------- ��������  TecDoc
    if not flFill then SetWaresNotTested; // ���������� ������ �������� �������
    ibs.SQL.Text:= 'Select WATDWARECODE, WATDArtSup, WATDArticle from WareArticleTD'+
      ' where WATDWRONG="F"';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.FieldByName('WATDWARECODE').AsInteger;
      if WareExist(i) then with arWareInfo[i] do if not IsArchive then try
        CS_wlinks.Enter;
        if flFill or (ArticleTD<>ibs.FieldByName('WATDARTICLE').AsString) then
          ArticleTD:= ibs.FieldByName('WATDARTICLE').AsString; // Article TecDoc
        if flFill or (ArtSupTD<>ibs.FieldByName('WATDArtSup').AsInteger) then
          ArtSupTD:= ibs.FieldByName('WATDArtSup').AsInteger;  // SupID TecDoc (DS_MF_ID !!!)
        State:= True;
      finally
        CS_wlinks.Leave;
      end;
      cntsORD.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then
      with arWareInfo[i] do if not State and ((ArticleTD<>'') or (ArtSupTD>0)) then try
        CS_wlinks.Enter;
        ArticleTD:= '';
        ArtSupTD:= 0;
      finally
        CS_wlinks.Leave;
      end;

    SetWaresNotTested; // ���������� ������ �������� �������
    //----------------------------------------------------- ������������� ������
    ibs.SQL.Text:= 'Select LWSWARECODE, LWSSatel, LWSSRCCODE from LinkWareSatellites'+
      ' where LWSWRONG="F" order by LWSWARECODE';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.FieldByName('LWSWARECODE').AsInteger;
      fl:= WareExist(i);
      if fl then with arWareInfo[i] do
        fl:= (not IsArchive) and (not IsInfoGr) and Assigned(SatelLinks);
      while not ibs.Eof and (i=ibs.FieldByName('LWSWARECODE').AsInteger) do begin
        if fl then begin
          j:= ibs.FieldByName('LWSSatel').AsInteger;
          flnew:= WareExist(j);
          if flnew then with arWareInfo[j] do // ��������� ���� � �������
            flnew:= (not IsArchive) and (not IsInfoGr) and CheckWaresEqualSys(i, j);
          if flnew then arWareInfo[i].SatelLinks.CheckLink(j, // �������� ����, ���� ��� ���
            ibs.FieldByName('LWSSRCCODE').AsInteger, arWareInfo[j]);
        end;
        ibs.Next;
      end;
      cntsORD.TestSuspendException;
    end;
    ibs.Close;

    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then
      with arWareInfo[i] do
        if Assigned(SatelLinks) and (SatelLinks.LinkCount>0) then begin
          if not flFill then SatelLinks.DelNotTestedLinks; // ������� ������������� �����.������
          SatelLinks.SortByLinkName;
        end; // SatelLinks

//-------------------------------------------------------- ��������� WareOptions
    SetWaresNotTested; // ���������� ������ �������� �������
    SetLength(tmpar, 0);   // ���� Update WOArhived='F'
    SetLength(tmpar1, 0);  // ���� ��� Update WOArhived='T'
    j:= 0;  // ������� ��� tmpar
    jj:= 0;  // ������� ��� tmpar1
    ss:= '';
    ibs.SQL.Text:= 'Select WOWARECODE, WOArhived, woHasModAuto, woHasModMoto,'+
      ' woHasModCV, woHasModAx from WareOptions order by WOWARECODE, WOArhived';
    ibs.ExecQuery; // ��������� �� ����, ��� ��� ���� � WareOptions
    while not ibs.Eof do begin
      i:= ibs.FieldByName('WOWARECODE').AsInteger;
      fl:= GetBoolGB(ibs, 'WOArhived');
      if WareExist(i) then begin
        ware:= arWareInfo[i];
        try
          CS_wares.Enter;
          if ware.IsArchive then begin
            ware.HasModelAuto:= False;
            ware.HasModelMoto:= False;
            ware.HasModelCV:= False;
            ware.HasModelAx:= False;
          end else begin
            ware.HasModelAuto:= GetBoolGB(ibs, 'woHasModAuto');
            ware.HasModelMoto:= GetBoolGB(ibs, 'woHasModMoto');
            ware.HasModelCV:= GetBoolGB(ibs, 'woHasModCV');
            ware.HasModelAx:= GetBoolGB(ibs, 'woHasModAx');
          end;
          ware.State:= True;
        finally
          CS_wares.Leave;
        end;
        if AllowWebarm then begin  // ������ � Webarm, �.�. Web ������������
          if fl and not ware.IsArchive then begin
            if High(tmpar)<j then SetLength(tmpar, j+1000);
            tmpar[j]:= i;
            inc(j);
          end else if not fl and ware.IsArchive then begin
            if High(tmpar1)<jj then SetLength(tmpar1, jj+1000);
            tmpar1[jj]:= i;
            inc(jj);
          end;
        end; // if AllowWebarm

      end // if WareExist(i)
      else if AllowWebarm then begin // ������ � Webarm, �.�. Web ������������
        if not fl then begin
          if High(tmpar1)<jj then SetLength(tmpar1, jj+1000);
          tmpar1[jj]:= i;
          inc(jj);
        end;
      end; // if AllowWebarm

      cntsORD.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;

    if AllowWebarm then begin  // ������ � Webarm, �.�. Web ������������
//------------------------------------------------------------------------------
      fnSetTransParams(ibs.Transaction, tpWrite);

      if (j>0) then begin // ������� ������� ���������� � WareOptions
        with ibs.Transaction do if not InTransaction then StartTransaction;
        ibs.SQL.Text:= 'update WareOptions set WOArhived="F" where WOWARECODE=:WARECODE';
        for i:= 0 to j-1 do begin
          with ibs.Transaction do if not InTransaction then StartTransaction;
          ibs.ParamByName('WARECODE').AsInteger:= tmpar[i];
          n:= RepeatExecuteIBSQL(IBS);
          if (n<>'') then
            prMessageLOGS(nmProc+'(upd_F/'+IntToStr(tmpar[i])+'): '+n, fLogCache, false);
        end;
        ss:= ss+' upd_F='+intToStr(j);
        ibs.Close;
      end;

      if (jj>0) then begin // ����������� ������� ���������� � WareOptions
        with ibs.Transaction do if not InTransaction then StartTransaction;
        ibs.SQL.Text:= 'update WareOptions set WOArhived="T" where WOWARECODE=:WARECODE';
        for i:= 0 to jj-1 do begin
          with ibs.Transaction do if not InTransaction then StartTransaction;
          ibs.ParamByName('WARECODE').AsInteger:= tmpar1[i];
          n:= RepeatExecuteIBSQL(IBS);
          if (n<>'') then
            prMessageLOGS(nmProc+'(upd_T/'+IntToStr(tmpar1[i])+'): '+n, fLogCache, false);
        end;
        ibs.Close;
        ss:= ss+' upd_T='+intToStr(jj);
      end;
//------------------------------------------------------------------------------
      SetLength(tmpar, 0);   // ���� ��� Insert
      SetLength(tmpar1, 0);  // �������� ���������� ��� Insert
      j:= 0;  // ������� ��� tmpar
      for i:= 1 to High(arWareInfo) do begin // ��������� ���������� � WareOptions
        if not WareExist(i) then  Continue;
        ware:= arWareInfo[i];
        if ware.State then Continue;
        if (High(tmpar)<j) then begin
          SetLength(tmpar, j+1000);
          SetLength(tmpar1, j+1000);
        end;
        tmpar[j]:= i;
        tmpar1[j]:= fnIfInt(ware.IsArchive, 1, 0);
        inc(j);
      end;
      if (j>0) then begin // ��������� � WareOptions
        with ibs.Transaction do if not InTransaction then StartTransaction;
        ibs.SQL.Text:= 'update or insert into WareOptions (WOWARECODE, WOArhived)'+
                       ' values (:WARECODE, :Arhived) MATCHING (WOWARECODE)';
        for i:= 0 to j-1 do begin
          with ibs.Transaction do if not InTransaction then StartTransaction;
          ibs.ParamByName('WARECODE').AsInteger:= tmpar[i];
          ibs.ParamByName('Arhived').AsString:= fnIfStr(tmpar1[i]=1, 'T', 'F');
          n:= RepeatExecuteIBSQL(IBS);
          if (n<>'') then
            prMessageLOGS(nmProc+'(ins/'+IntToStr(tmpar[i])+'): '+n, fLogCache, false);
        end;
        ibs.Close;
        ss:= ss+' ins='+intToStr(j);
      end;
      if {flFill and} (ss<>'') then prMessageLOGS('WareOptions - '+ss, fLogCache, false); // ����� � log
//-------------------------------------------------------- ��������� WareOptions
    end; // if AllowWebarm

if flLogTestWares then begin
    prMessageLOGS(nmProc+': WareOptions - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
//    LocStart:= now();
end;

if flWareForSearch then begin
    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then begin
      ware:= arWareInfo[i];
      fl:= ware.IsWare and (ware<>NoWare)
           and not ware.IsArchive and (ware.PgrID>0) // ����� �� ����������
           and not ware.IsPrize                  // ����� ������
           and (ware.PgrID<>Cache.pgrDeliv)      // ����� ��������
           and not (ware.IsINFOgr and (ware.AnalogLinks.LinkCount<1)); // ���� ��� ��������
      if (ware.ForSearch<>fl) then try
        CS_wares.Enter;
        ware.ForSearch:= fl;
      finally
        CS_wares.Leave;
      end;
    end;
end; // if flWareForSearch

    // �������� ������������� !!!
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  finally
    SetLength(tmpar, 0);
    SetLength(tmpar1, 0);
    prFreeIBSQL(ibs);
    cntsORD.SetFreeCnt(ibd, True);
  end;
  prMessageLOGS(nmProc+s+' - '+GetLogTimeStr(LocalStart), fLogCache, false); // ����� � log
  TestCssStopException;
end;
//==============================================================================
function TDataCache.GetWare(WareID: integer; OnlyCache: Boolean=False): TWareInfo;
// ���������� ��������� ������ (���� � ���� ��� ��� - ������� � ��� � PgrID=0)
const nmProc = 'GetWare'; // ��� ���������/�������/������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    fl, flShowByState: boolean;
    k, i: Integer;
    n, ss, sa1, sa2, sa3, ss1, ss2, ss3, st, s1, s2, s3, sd: String;
begin
  Result:= NoWare;
  if not Assigned(self) then Exit;
  if WareExist(WareID) then begin
    Result:= Cache.arWareInfo[WareID];
    Exit;
  end;
  if OnlyCache then Exit;
  ibd:= nil;
  ibs:= nil;
  fl:= True;
  try try
    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, WareID, tpRead, True);
    st:= IntToStr(codeTovar);
    sd:= GetConstItem(pcDeliveriesMasterCode).StrValue;
    s1:= ' left join WAREGROUP wg1 on wg1.WRGRCLASSCODE='+
         GetConstItem(pcWareTypeClassCode).StrValue+' and wg1.WRGRWARECODE=w.WARECODE'#10;
    s2:= ' left join WAREGROUP wg2 on wg2.WRGRCLASSCODE='+
         GetConstItem(pcWareTOPClassCode).StrValue+' and wg2.WRGRWARECODE=w.WARECODE'#10;
    s3:= ' left join WAREGROUP wg3 on wg3.WRGRCLASSCODE='+
         GetConstItem(pcWareCutPriceClassCode).StrValue+' and wg3.WRGRWARECODE=w.WARECODE'#10;
    sa1:= Cache.GetConstItem(pcCauseActions).StrValue;
    sa2:= Cache.GetConstItem(pcCauseCatchMoment).StrValue;
    sa3:= Cache.GetConstItem(pcCauseNews).StrValue;
    ss:= '';
    ss1:= '';
    ss2:= '';
    ss3:= '';
    for k:= 0 to High(PriceTypes) do begin // ������ � ������� ���
      if k=0 then n:= '' else n:= IntToStr(k);
      ss:= ss+ ', priceEUR'+n+' double precision';
      ss1:= ss1+ ', cm'+n+'.RESULTVALUE';
      ss2:= ss2+ ', :priceEUR'+n;
      ss3:= ss3+ ' left join GETWAREPRICE("TODAY", w.warecode, '+IntToStr(PriceTypes[k])+
                 ', w.waremeas) p'+n+' on 1=1'#10+
                 ' left join ConvertMoney(p'+n+'.RPRICEWARE, p'+n+'.RCRNCCODE, '+
                 cStrDefCurrCode+', "TODAY") cm'+n+
                 ' on exists(select * from RateCrnc where RateCrncCode=p'+n+'.RCRNCCODE)'#10;
    end; // for
    flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_CheckWareStates');
    ibs.ParamCheck:= False;
    ibs.SQL.Text:= 'execute block returns (KODPGR integer, warearchive varchar(1),'#10+
      '  WAREMEAS integer, WrPrProductDirection integer, WAREBONUS varchar(1),'#10+
      '  WARESUPPLIERNAME varchar(100), WAREDIVISIBLE integer, WAREOFFICIALNAME varchar(100),'#10+
      '  WARECOMMENT varchar(255), WAREMAINNAME varchar(100), WAREBRANDCODE integer,'#10+
      '  sale varchar(1), REmplCode integer, wtype integer, wTOP integer,'#10+
      '  wCutPrice integer, ActCode integer, TopRating integer, actNews integer,'+
      '  wState integer, product integer, ProdLine integer,'+
      '  actMoment integer, wareweight double precision, WareLitrCount double precision'+ss+#10+
      ') as declare variable xMin integer; declare variable xCodeTop integer='+IntToStr(TopActCode)+';'#10+
      ' declare variable xWare integer='+IntToStr(WareID)+'; begin ProdLine=0;'#10+
      '    select w.warearchive, w.WAREMEAS, coalesce(WrPrProductDirection, 0),'+

      fnIfStr(flShowWareByState, '    w.waremastercode,',
      '    iif(w.waremastercode='+sd+','+sd+', coalesce(pg.PGRvlad, 0)),')+

      '    coalesce(wareweight, 0), coalesce(WareLitrCount, 0), w.wareproductscode,'#10+
      '    w.WARESUPPLIERNAME, coalesce(w.WAREDIVISIBLE, 1), w.WAREOFFICIALNAME, w.WARECOMMENT,'#10+
      '    w.WAREMAINNAME, w.WAREBRANDCODE, sl.rsalekey, mg.REmplCode, wg1.WRGRMASTERCODE,'#10+

      fnIfStr(flShowByState,'    wc.wacawaresvkstate wState,'#10,
      '    (select first 1 WSState from WareState where WSWareCode=w.warecode'#10+
      '      and WSDate<current_timestamp order by WSDate desc) wState,'#10)+

      '    iif(w.WAREBRANDCODE<>'+IntToStr(cbrMotul)+', 0,'+ // ����������� �������
      '     (select first 1 wg4.wrgrclasscode from WAREGROUP wg4'+
      '      left join analitdict a on a.andtcode=wg4.wrgrclasscode'+
      '      where wg4.WRGRWARECODE=w.warecode and a.andtmastercode='+
      Cache.GetConstItem(pcMotulProdLineAndtCode).StrValue+')) ProdLine,'#10+
      '    iif(wg2.WRGRCODE is null, 0, 1), iif(wg3.WRGRCODE is null, 0, 1), w.WAREBONUS'+ss1+#10+
      '    from wares w'+
      '    left join WareProducts on wrprregistrcode=w.wareproductscode'#10+s1+s2+s3+

      fnIfStr(flShowWareByState,'',
      '    left join VLADPGR pg on pg.KODPGR=w.waremastercode and w.WARECHILDCOUNT=0'#10)+

      fnIfStr(not flShowByState,'',
      '    left join warecache_vlad wc on wc.wacacode=w.warecode'#10)+

      '    left join GetWareSaleKey(w.warecode, "TODAY") sl on 1=1'+
      '    left join GETWAREMANAGER(w.warecode, "TODAY") mg on 1=1'#10+ss3+
      '    where w.WARECODE=:xWare'#10+
      '  into :warearchive, :WAREMEAS, :WrPrProductDirection, :KODPGR, :wareweight,'#10+
      '    :WareLitrCount, :product, :WARESUPPLIERNAME, :WAREDIVISIBLE, :WAREOFFICIALNAME,'#10+
      '    :WARECOMMENT, :WAREMAINNAME, :WAREBRANDCODE, :sale, :REmplCode, :wtype,'+
      '    :wState, :ProdLine, :wTOP, :wCutPrice, :WAREBONUS'+ss2+';'#10+
      '  ActCode=0; TopRating=0; actNews=0; actMoment=0;'#10+
      '  if (warearchive="T") then begin suspend; exit; end'+
      '  if (WAREBONUS="T") then begin'#10+ //---------- �������
      '    select first 1 coalesce(WrAcLnDocmCode, 0)'#10+ // ���� ������
      '      from WareActionLines left join WareActionReestr on WrAcCode=WrAcLnDocmCode'#10+
      '      where (WrAcLnWareCode=:xWare) and WrAcSubFirmCode=1 and WrAcDocmState=1'#10+
      '        and (WrAcCauseCode='+sa2+') and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '      order by WrAcStartDate, WrAcLnDocmCode into :actMoment;'#10+
      '    if (actMoment<1) then select first 1 coalesce(WrAcLnDocmCode, 0)'#10+ // �������
      '      from WareActionLines left join WareActionReestr on WrAcCode=WrAcLnDocmCode'#10+
      '      where (WrAcLnWareCode=:xWare) and WrAcSubFirmCode=1 and WrAcDocmState=1'#10+
      '        and (WrAcCauseCode='+sa3+') and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '      order by WrAcStartDate, WrAcLnDocmCode into :actNews;'#10+
      '  end else begin'+                //---------- �����
      '    select first 1 coalesce(WrAcLnDocmCode, 0) from WareActionLines'#10+ // �����
      '      left join WareActionReestr on WrAcCode=WrAcLnDocmCode'#10+
      '      left join analitdict a on a.andtcode=WrAcCauseCode'#10+
      '      left join analitdict a1 on a1.andtcode = a.andtmastercode'#10+
      '      left join analitdict a2 on a2.andtcode = a1.andtmastercode'#10+
      '      left join analitdict a3 on a3.andtcode = a2.andtmastercode'#10+
      '      left join analitdict a4 on a4.andtcode = a3.andtmastercode'#10+
      '      where WrAcLnWareCode=:xWare and WrAcSubFirmCode=1 and WrAcDocmState=1'#10+
      '        and ("today" between WrAcStartDate and WrAcStopDate) and'#10+
      '        (a.andtcode='+sa1+' or a1.andtcode='+sa1+' or a2.andtcode='+sa1+#10+
      '        or a3.andtcode='+sa1+' or a4.andtcode='+sa1+')'#10+
      '    order by WrAcStartDate, WRACLNCode into :ActCode;'#10+
      '    if (xCodeTop>0) then begin select first 1 coalesce(WRACLNCode, 0)'#10+ // ��� �����
      '      from WareActionLines where WrAcLnDocmCode=:xCodeTop order by WRACLNCode into :xMin;'#10+
      '      if (xMin is null or xMin<1) then xCodeTop=0; end'#10+ // �������� ������� �����, ���.��� ������ � ���-��
      '    if (xCodeTop>0) then begin while (TopRating<1 and xWare>0) do begin'#10+
      '      select coalesce(WRACLNCode, 0) from WareActionLines'#10+      // ������� ��� ������
      '      where WrAcLnWareCode=:xWare and WrAcLnDocmCode=:xCodeTop into :TopRating;'#10+
      '      if (TopRating<1) then select coalesce(w1.waremastercode, 0)'#10+
      '        from wares w1 where w1.warecode=:xWare into :xWare; end end'#10+
      '    if (TopRating>0) then TopRating=TopRating-xMin+1; end suspend; end';
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then Exit;
    if not TestCacheArrayItemExist(taWare, WareID, fl) then Exit;
    Result:= arWareInfo[WareID];
    try
      CS_wares.Enter;
      k:= ibs.FieldByName('KODPGR').AsInteger;
      Result.SetWareParams(k, ibs, True);
      if Result.IsPrize then begin //---------- �������
        k:= ibs.FieldByName('actMoment').AsInteger; // ���� ������
        i:= ibs.FieldByName('actNews').AsInteger;  // �������
        if (k>0) then Result.ActionID:= k
        else if (i>0) then Result.ActionID:= i
        else Result.ActionID:= 0;
      end;
      if not Result.IsArchive and not Result.IsPrize and (Result.PgrID<>pgrDeliv) then
        Result.TopRating:= ibs.FieldByName('TopRating').AsInteger
      else Result.TopRating:= 0;
      Result.State:= True;
    finally
      CS_wares.Leave;
    end;
  except
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
      if flDebug and Assigned(ibs) then prMessageLOGS('SQL.Text: '+ibs.SQL.Text, fLogCache);
    end;
  end;
  finally
    prFreeIBSQL(ibs);
    cntsGRB.SetFreeCnt(ibd);
  end;
end;
//=========================================== ���������� ������ �������� �������
procedure TDataCache.SetWaresNotTested;
var i: integer;
begin
  if not Assigned(self) then Exit;
  for i:= 1 to High(arWareInfo) do // �������� ������� �������� ������, ������, ���������
    if Assigned(arWareInfo[i]) then with arWareInfo[i] do begin
      State:= False;
      if assigned(AnalogLinks) then AnalogLinks.SetLinkStates(False); // ���������� �������� �������� ��������
      if assigned(SatelLinks) then SatelLinks.SetLinkStates(False); // ���������� �������� �������� �����.�������
    end;
end;
//================================= ������� �� ����������� �������� ���� �������
procedure TDataCache.DelNotTestedWares;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= 1 to High(arWareInfo) do if Assigned(arWareInfo[i]) then
    with arWareInfo[i] do if (not IsArchive) and (not State) then begin // ���� �� ��������
      PgrID:= 0;                 // ��������� � �����
      IsArchive:= True;
      ClearOpts;                 // ������� �����
    end;
end;
//------------------------ ��������� ���������� ���� �������� �������� ���������
function fnAttrValEquals(aLinks: TLinks; attCodes, valCodes: Tai): Boolean;
var ii: integer;
    lnk: TTwoLink;
begin
  Result:= False;
  if (aLinks.LinkCount<1) then exit;
  for ii:= 0 to High(attCodes) do begin
    if not aLinks.LinkExists(attCodes[ii]) then exit;
    lnk:= aLinks[attCodes[ii]];
    if not assigned(lnk.LinkPtrTwo) then exit;
    if (lnk.LinkTwoID<>valCodes[ii]) then exit;
  end;
  Result:= True;
end;
//=================================== ����� ������� �� ������ �������� ���������
function TDataCache.SearchWaresByAttrValues(attCodes, valCodes: Tai): Tai; // must Free
// ���������� ������ ����� �������, ��������������� �� ������������
const nmProc='SearchWaresByAttrValues';
var i: integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  if (length(attCodes)<1) or (length(valCodes)<length(attCodes)) then Exit;
  with fnCreateStringList(False, 100) do try
    for i:= 1 to High(arWareInfo) do if WareExist(i) then with GetWare(i) do begin
      if IsArchive or (PgrID<1) or (PgrID=pgrDeliv) or IsPrize then Continue; // ���������� ��������
      if fnAttrValEquals(AttrLinks, attCodes, valCodes) then AddObject(Name, pointer(i));
    end;
    if Count>1 then Sort;
    SetLength(Result, Count);
    for i:= 0 to Count-1 do Result[i]:= integer(Objects[i]);
  finally
    Free;
  end;
end;
//========================== ����� ������� �� ������ �������� ��������� Grossbee
function TDataCache.SearchWaresByGBAttValues(attCodes, valCodes: Tai): Tai; // must Free
// ���������� ������ ����� �������, ��������������� �� ������������
const nmProc='SearchWaresByGBAttValues';
var i: integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  if (length(attCodes)<1) or (length(valCodes)<length(attCodes)) then Exit;
  with fnCreateStringList(False, 100) do try
    for i:= 1 to High(arWareInfo) do if WareExist(i) then with GetWare(i) do begin
      if IsArchive or (PgrID<1) or (PgrID=pgrDeliv) or IsPrize then Continue; // ���������� ��������
      if fnAttrValEquals(GBAttLinks, attCodes, valCodes) then AddObject(Name, pointer(i));
    end;
    if Count>1 then Sort;
    SetLength(Result, Count);
    for i:= 0 to Count-1 do Result[i]:= integer(Objects[i]);
  finally
    Free;
  end;
end;
//================================================= ����� ������� �� �������� TD
function TDataCache.SearchWaresByTDSupAndArticle(pSup: Integer; pArticle: String; // must Free
                                                 notInfo: Boolean=False): TStringList;
// ���������� ������ ����� �������, ��������������� �� ������������
// notInfo=True - ������ ��-���� ������
const nmProc='SearchWaresByTDSupAndArticle';
var i: integer;
    Ware: TWareInfo;
begin
  Result:= fnCreateStringList(False, 10);
  if not Assigned(self) then Exit;
  if (pSup<1) or (pArticle='') then Exit;
  for i:= 1 to High(arWareInfo) do if WareExist(i) then begin
    Ware:= GetWare(i);
    if Ware.IsArchive or (Ware.PgrID<1) then Continue;
    if (Ware.PgrID=pgrDeliv) then Continue; // ���������� ��������
    if notInfo and Ware.IsINFOgr then Continue;
    if (Ware.ArticleTD<>pArticle) or (pSup<>Ware.ArtSupTD) then Continue;
    Result.AddObject(Ware.Name, pointer(i));
  end;
  if Result.Count>1 then Result.Sort;
end;
//======== ���������� TList - ��������� desc + ���� ������ desc + ���� ���������
function InfoBoxItemsSortCompare(Item1, Item2: Pointer): Integer;
var ib1, ib2: TInfoBoxItem;
begin
  try
    ib1:= Item1;
    ib2:= Item2;
    if ib1.Priority=ib2.Priority then begin
      if (ib1.DateFrom=ib2.DateFrom) then begin
        if (ib1.DateTo=ib2.DateTo) then Result:= 0
        else if (ib1.DateTo>ib2.DateTo) then Result:= 1 else Result:= -1;
      end else if (ib1.DateFrom<ib2.DateFrom) then Result:= 1 else Result:= -1;
    end else if (ib1.Priority<ib2.Priority) then Result:= 1 else Result:= -1;
  except
    Result:= 0;
  end;
end;
//======================================================== ���������� ����-�����
procedure TDataCache.FillInfoNews(flFill: Boolean=True);
const nmProc='FillInfoNews';
var ORD_IBD: TIBDatabase;
    ibs: TIBSQL;
    dd1, dd2: TDateTime;
    i, j: Integer;
    s: String;
    inItem: TInfoBoxItem;
    Item: Pointer;
    fl: Boolean;
begin
  if not Assigned(self) then Exit;
  if not AllowWeb then Exit; // ��������� ������ ��� Web
  IBS:= nil;
  try
    if not flFill then InfoNews.SetDirStates(False);
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ibs:= fnCreateNewIBSQL(ORD_IBD, 'ibs_'+nmProc, -1, tpRead, true);
      ibs.SQL.Text:= 'SELECT * from InfoBoxViews where ("TODAY" between ibvDateFrom and ibvDateTo)';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('ibvCODE').AsInteger; // ���
        s:= ibs.fieldByName('ibvTitle').AsString; // ���������
        j:= ibs.fieldByName('ibvPriority').AsInteger;
        if not InfoNews.ItemExists(i) then begin
          Item:= TInfoBoxItem.Create(i, 0, j, s);
          InfoNews.CheckItem(Item); // ����� inItem.State=True
        end;
        inItem:= InfoNews[i];
        if not inItem.State then begin
          if (inItem.Title<>s)    then inItem.Title:= s;    // ���������
          if (inItem.Priority<>j) then inItem.Priority:= j; // ���������
        end;
        dd1:= ibs.fieldByName('ibvDateFrom').AsDateTime;    // ���� ������
        if inItem.DateFrom<>dd1 then inItem.DateFrom:= dd1;
        dd2:= ibs.fieldByName('ibvDateTo').AsDateTime;      // ���� ���������
        if inItem.DateTo<>dd2   then inItem.DateTo:= dd2;
        fl:= GetBoolGB(ibs, 'ibvVisible');                  // ���������� � ����
        if inItem.InWindow<>fl then inItem.InWindow:= fl;
        fl:= GetBoolGB(ibs, 'ibvVisAuto');                  // ��������� ��� ������� ����
        if inItem.VisAuto<>fl then inItem.VisAuto:= fl;
        fl:= GetBoolGB(ibs, 'ibvVisMoto');                  // ��������� ��� ������� ����
        if inItem.VisMoto<>fl then inItem.VisMoto:= fl;
        s:= ibs.fieldByName('ibvLinkToSite').AsString;      // ������ �� ���� / ���� ��������
        if inItem.LinkToSite<>s then inItem.LinkToSite:= s;
        s:= ibs.fieldByName('ibvLinkToPict').AsString;      // ������ �� �������
        if inItem.LinkToPict<>s then inItem.LinkToPict:= s;
        if not inItem.State then inItem.State:= True;
        cntsOrd.TestSuspendException;
        ibs.Next;
      end;
      ibs.Close;
    finally
      prFreeIBSQL(ibs);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if not flFill then InfoNews.DelDirNotTested;
    InfoNews.CheckLength;
    InfoNews.DirSort(InfoBoxItemsSortCompare);
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  TestCssStopException;
end;
//============================================ ���������� / �������� �����������
procedure TDataCache.FillNotifications(fFill: Boolean=True);
const nmProc = 'FillNotifications'; // ��� ���������/�������
var noteID: Integer;
    sText: String;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    flAdd, flNew, flAuto, flMoto: Boolean;
    item: Pointer;
    noteItem: TNotificationItem;
    pBegDate, pEndDate: TDateTime;
begin
  if not Assigned(self) then Exit;
  if not AllowWeb then Exit; // ��������� ������ ��� Web
  IBS:= nil;
  try
    if not fFill then Notifications.SetDirStates(False);
    IBD:= CntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, True);
      IBS.SQL.Text:= 'select NoteCODE, NoteBegDate, NoteEndDate, NoteText, NoteFilials,'+
        ' NoteClasses, NoteTypes, NoteFirms, NOTEFIRMSADDFLAG, NOTEauto, NOTEmoto from Notifications'+
        ' where NoteArchived="F" and ("TODAY" between NoteBegDate and NoteEndDate)';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        noteID  := IBS.FieldByName('NoteCODE').AsInteger;     // ��� �����������
        pBegDate:= IBS.FieldByName('NoteBegDate').AsDateTime; // ���� ������
        pEndDate:= IBS.FieldByName('NoteEndDate').AsDateTime; // ���� ���������
        sText   := IBS.FieldByName('NoteText').AsString;      // ����� �����������
        flAdd   := GetBoolGB(ibs, 'NOTEFIRMSADDFLAG');        // ���� - ���������/��������� ���� Firms
        flAuto  := GetBoolGB(ibs, 'NOTEauto');                // ����  �������� �/� � ����-�����������
        flMoto  := GetBoolGB(ibs, 'NOTEmoto');                // ���� �������� �/� � ����-�����������
        flNew:= not Notifications.ItemExists(noteID);
        if flNew then begin // �����
          item:= TNotificationItem.Create(noteID, sText);
          Notifications.CheckItem(item); // ����� State=True
          noteItem:= item;
        end else noteItem:= Notifications[noteID];
        Notifications.CS_DirItems.Enter;
        with noteItem do try      //--------- ���������
          if not flNew then begin
            Name:= sText;
            State:= True;
          end;
          BegDate   := pBegDate;
          EndDate   := pEndDate;
          flFirmAdd := flAdd;
          flFirmAuto:= flAuto;
          flFirmMoto:= flMoto;
          CheckConditions(IBS.FieldByName('NoteFilials').AsString, // ���� �������� �/�
                          IBS.FieldByName('NoteClasses').AsString, // ���� ��������� �/�
                          IBS.FieldByName('NoteTypes').AsString,   // ���� ����� �/�
                          IBS.FieldByName('NoteFirms').AsString);  // ����  �/�
        finally
          Notifications.CS_DirItems.Leave;
        end;
        cntsOrd.TestSuspendException;
        IBS.Next;
      end;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;
    if not fFill then Notifications.DelDirNotTested;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  TestCssStopException;
end;
//============================================ �������� �������� �������� ������
function TDataCache.CheckWareAttrValue(WareID, AttrID, srcID, userID: Integer;
         Value: String; var ResCode: Integer): String;
const nmProc='CheckWareAttrValue';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    newatv, oldatv, j: Integer;
    attr: TAttributeItem;
    attv: TDirItem;
    attlink: TTwoLink;
    Ware: TWareInfo;
    Item: Pointer;
    flinkEx: Boolean;
    sValue: String;
begin
  Result:= '';
  ResCode:= resError;
  newatv:= 0;
  oldatv:= 0;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrProcess));
    if not WareExist(WareID) then // ��������� ��� ������
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    if not Attributes.ItemExists(AttrID) then // ��������� ��� ��������
      raise EBOBError.Create('�� ������ �������, ���='+IntToStr(AttrID));

    Ware:= GetWare(WareID);                  // ������ �� �����
    if Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    Value:= trim(Value);
    flinkEx:= Ware.AttrLinks.LinkExists(AttrID); // ������� ������� � ������ ����� �� �������
    if not flinkEx and (Value='') then begin // ���� ����� ��� � ������ ������ ��������
      ResCode:= resDoNothing;
      raise EBOBError.Create('�� ������� '+MessText(mtkWareAttrValue));
    end;

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite);

      if (Value='') then begin // ���� ������ ������ �������� - ������� �����
        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'delete from LINKWAREATTRVAL'+ // ������� ������ �� ����
          ' where LWAWWARECODE=:LWAWWARECODE and LWAWATTRCODE=:LWAWATTRCODE';
        ORD_IBS.ParamByName('LWAWWARECODE').AsInteger:= WareID;
        ORD_IBS.ParamByName('LWAWATTRCODE').AsInteger:= AttrID;
        ORD_IBS.ExecQuery;
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        Ware.AttrLinks.DeleteLinkItem(AttrID); // ������� ���� �� ����
        ResCode:= resDeleted;
        raise EBOBError.Create(MessText(mtkWareAttrValue)+' �������');
      end;
//------------------------ ������ �������� (��������) ����������

      sValue:= Value; // ���������� �������� ��������
      attr:= Attributes.GetAttr(AttrID); // ������ �� �������
      if attr.TypeAttr=constDouble then attr.CheckAttrStrValue(sValue); // ��������� ��������

      j:= attr.FListValues.IndexOf(sValue); // ���� ����� �������� ��������
      if (j>-1) then newatv:= Integer(attr.FListValues.Objects[j]); // ��� ������ ��������

      if flinkEx then begin
        attlink:= Ware.AttrLinks[AttrID];
        with attlink do if assigned(LinkPtrTwo) then oldatv:= LinkTwoID; // ��� ������� ��������
      end else attlink:= nil;

      if (oldatv>0) then begin // ���� ������ �������� ����
        if (newatv>0) and (oldatv=newatv) then begin // ���� �������� �� ��
          ResCode:= resDoNothing;
          raise EBOBError.Create(MessText(mtkWareAttrValue)+' �� ����������');
        end;
        if assigned(attlink) then attlink.LinkPtrTwo:= nil;  // ������� ������ ��������  ???
      end;
//------------------------ ����������� �������� ����������

      if newatv<1 then begin // ���� ��� ������ �������� �������� - ��������� � ����
        if (attr.TypeAttr=constDouble) and (FormatSettings.DecimalSeparator<>'.') then
          Value:= StringReplace(sValue, FormatSettings.DecimalSeparator, '.', [rfReplaceAll]); // � ���� ����� � '.'
        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'insert into ATTRVALUES (ATVLATTRCODE, ATVLVALUESTR, ATVLUSERID)'+
          ' values (:ATVLATTRCODE, :ATVLVALUESTR, :ATVLUSERID) returning ATVLCODE';
        ORD_IBS.ParamByName('ATVLATTRCODE').AsInteger:= AttrID;
        ORD_IBS.ParamByName('ATVLVALUESTR').AsString := Value;
        ORD_IBS.ParamByName('ATVLUSERID').AsInteger  := userID;
        ORD_IBS.ExecQuery;
        if not (ORD_IBS.Bof and ORD_IBS.Eof) then newatv:= ORD_IBS.Fields[0].AsInteger; // ��� ��������
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;
      end;
      if newatv<1 then raise EBOBError.Create(MessText(mtkErrAddRecord));

      if Attributes.FAttrValues.ItemExists(newatv) then
        attv:= Attributes.FAttrValues[newatv] // ������ �� �������� ��������
      else begin
        Item:= TDirItem.Create(newatv, sValue);
        if not Attributes.FAttrValues.CheckItem(Item) then // ��������� � ���������� ��������
           raise EBOBError.Create(MessText(mtkErrAddRecord));
        attv:= Item;
      end;

      with attr.FListValues do if (IndexOfObject(Pointer(newatv))<0) then begin
        AddObject(sValue, Pointer(newatv));  // ��������� � ������ �������� ��������
        CustomSort(AttrValuesSortCompare);   // ��������� ������ �������� ��������
      end;
//------------------------ ����������� �������� ����������

      if not flinkEx then begin // ���� �� ���� ����� �� ������� - ���������

        if (Ware.AttrLinks.LinkCount>0) and (Ware.AttrGroupID<>attr.SubCode) then // �������� ������
           raise EBOBError.Create('����� ����� �������� ������ ������');

        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'insert into LINKWAREATTRVAL'+
          ' (LWAWWARECODE, LWAWATTRCODE, LWAWATVLCODE, LWAWSRCLECODE, LWAWUSERID) values'+
          ' ('+IntToStr(WareID)+', '+IntToStr(AttrID)+', '+IntToStr(newatv)+', '+
          IntToStr(srcID)+', '+IntToStr(userID)+') returning LWAWATVLCODE';
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Bof and ORD_IBS.Eof) or (ORD_IBS.Fields[0].AsInteger<1) then
          raise EBOBError.Create(MessText(mtkErrAddRecord));
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        attlink:= TTwoLink.Create(srcID, attr, attv);
        with Ware.AttrLinks do begin
          AddLinkItem(attlink);    // ��������� ���� �� ������� � ���
          SortByLinkOrdNumAndName; // ��������� �� ������.� + ������������
        end;
        attv.State:= True; // ����� ������� ������������� ��������

        ResCode:= resAdded;
        Result:= MessText(mtkWareAttrValue)+' ���������';

      end else begin // ���� ���� ��� - ������ ��������
        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'update LINKWAREATTRVAL set LWAWATVLCODE='+IntToStr(newatv)+
          ' where LWAWWARECODE='+IntToStr(WareID)+' and LWAWATTRCODE='+IntToStr(AttrID);
        ORD_IBS.ExecQuery;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        if assigned(attlink) then begin
          attlink.LinkPtrTwo:= attv; // ����� ��������
          attv.State:= True; // ����� ������� ������������� ��������
        end;
        ResCode:= resEdited;
        Result:= MessText(mtkWareAttrValue)+' ��������';
      end;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;

//================= ���������� / �������� ������ �������������� Grossbe � Tecdoc
function TDataCache.CheckWareBrandReplace(brID, brTD, userID: Integer; var ResCode: Integer): String;
// ���������� ��������� � ���������� ����������
// ��� �������� - ResCode - �� ����� (resAdded, resDeleted)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������, resAdded - ���������, resDeleted - �������
const nmProc='CheckWareBrandReplace';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    OpCode, index: Integer;
    fAdd: Boolean;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise EBOBError.Create(MessText(mtkErrProcess));
    if not (OpCode in [resAdded, resDeleted]) then       // ��������� ��� ��������
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if not WareBrands.ItemExists(brID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, IntToStr(brID)));

    fAdd:= OpCode<>resDeleted;
    index:= fnInIntArray(brTD, TBrandItem(WareBrands[brID]).TDMFcodes);
    if fAdd and (index>-1) then begin            // ���� ����������
      ResCode:= resDoNothing;
      raise EBOBError.Create('����� ������������ �������������� ��� ����');
    end else if not fAdd and (index<0) then begin     // ���� ��������
      ResCode:= resDoNothing;
      raise EBOBError.Create('�� ������� ����� ������������ ��������������');
    end;

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      if fAdd then begin  // ���� ����������
        ORD_IBS.SQL.Text:= 'insert into BRANDREPLACE (BRRPGBCODE, BRRPTDCODE, BRRPUSERID)'+
          ' values ('+IntToStr(brID)+', '+IntToStr(brTD)+', '+IntToStr(userID)+
          ') returning BRRPCODE';
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Bof and ORD_IBS.Eof) or (ORD_IBS.Fields[0].AsInteger<1) then
          raise EBOBError.Create(MessText(mtkErrAddRecord));
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        prAddItemToIntArray(brTD, TBrandItem(WareBrands[brID]).FTDMFcodes);
        ResCode:= resAdded;
        Result:= '������������ �������������� ���������';

      end else begin      // ���� ��������
        ORD_IBS.SQL.Text:= 'delete from BRANDREPLACE'+ // ������� ������ �� ����
          ' where BRRPGBCODE='+IntToStr(brID)+' and BRRPTDCODE='+IntToStr(brTD);
        ORD_IBS.ExecQuery;
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        prDelItemFromArray(index, TBrandItem(WareBrands[brID]).FTDMFcodes);
        ResCode:= resDeleted;
        Result:= '������������ �������������� �������';
      end;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;
//======================= ���������� / �������� ������ ������� � ����������� ���
function TDataCache.CheckLinkMainAndDupNodes(NodeID, MainNodeID, userID: Integer; var ResCode: Integer): String;
// ���������� ��������� � ���������� ����������, ��� �������� - ResCode - �� ����� (resAdded, resDeleted)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������, resAdded - ���������, resDeleted - �������
const nmProc='CheckLinkMainAndDupNodes';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    OpCode, i, j, j3, ModelID, WareID, res, utID, uID, SysID: Integer;
    flag, fLinkEx, fMainLinkEx: Boolean;
    Node, NodeMain: TAutoTreeNode;
    NodeName, MainNodeName, s: String;
    Model: TModelAuto;
    link2, link2main: TSecondLink;
    link3: TLink;
    links3: TLinkList;
    codes: Tai;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  SysID:= 0;
  ModelID:= 0;
  WareID:= 0;
  utID:= 0;
  uID:= 0;
  Node:= nil;
  SetLength(codes, 0);
  ORD_IBS:= nil;
  try try
//------------------------------------------------------------- ������� ��������
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrProcess));
    if not (OpCode in [resAdded, resDeleted]) then       // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');
    if (userID<1) then raise Exception.Create(MessText(mtkErrorUserID)); // ��������� userID

    flag:= OpCode<>resDeleted; // flag - ���� ��������

    with SysTypes do for i:= 0 to Count-1 do begin // ���������� ��� �������
      j:= GetDirItemID(ItemsList[i]);
      if Assigned(FDCA.AutoTreeNodesSys[j]) then with FDCA.AutoTreeNodesSys[j] do
        if NodeGet(NodeID, Node) then begin // ��������� �������� ����
          if (NodeID<>MainNodeID) and not NodeExists(MainNodeID) then // ��������� ������� ����
            raise Exception.Create('� ����� ������ ������� �����');
          SysID:= j;
          Break;
        end;
    end; // for i:= 0 to Count-1
    if (SysID<1) then raise Exception.Create(MessText(mtkNotFoundTypeSys));

    if (NodeID=MainNodeID) then NodeMain:= Node
    else NodeMain:= FDCA.AutoTreeNodesSys[SysID][MainNodeID];
    NodeName:= Node.NameSys;
    MainNodeName:= NodeMain.NameSys;
    if not Node.IsEnding then // ���� ������ ���� ��������
      raise Exception.Create('���� ('+IntToStr(NodeID)+')'+NodeName+' �� ��������');
    if (NodeID<>MainNodeID) and not NodeMain.IsEnding then // ������� ���� ������ ���� ��������
      raise Exception.Create('���� ('+IntToStr(MainNodeID)+')'+MainNodeName+' �� ��������');

    if flag then begin // ��������� ����������� ��������
      j:= Node.MainCode;
      if (NodeID=j) then begin
                               // ���� �� ������ ���� ������� � ������������ ������
        with FDCA.AutoTreeNodesSys[SysID].GetDuplicateNodes(NodeID) do try
          if (Count>0) then
            raise Exception.Create('���� ('+IntToStr(NodeID)+')'+NodeName+' ����� ����������� ����');
        finally Free; end;

      end else if (FDCA.AutoTreeNodesSys[SysID].NodeExists(j)) then // ���� ������ ���� �������������
        raise Exception.Create('���� ('+IntToStr(NodeID)+')'+NodeName+' �������� � ���� ('+
          IntToStr(j)+')'+FDCA.AutoTreeNodesSys[SysID][j].NameSys);

    end else if (Node.MainCode<>MainNodeID) then // ��������� ����������� �������
      raise Exception.Create('���� ('+IntToStr(NodeID)+')'+NodeName+
        ' �� �������� � ���� ('+IntToStr(MainNodeID)+')'+MainNodeName);

//--------------------------------------------------------- ������������ �������
    if not flag then begin
      flag:= False; // ������ flag - ���� ������
      SetLength(codes, 100);
      j:= 0;
      ORD_IBD:= cntsOrd.GetFreeCnt;
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
        ORD_IBS.SQL.Text:= 'update TREENODESAUTO set TRNAMAINCODE=TRNACODE'+
          ', TRNAUSERID='+IntToStr(userID)+' where TRNACODE='+IntToStr(NodeID);
        ORD_IBS.ExecQuery;
        ORD_IBS.Transaction.Commit;
        ORD_IBS.Close;

        fnSetTransParams(ORD_IBS.Transaction, tpRead, True);
        ORD_IBS.SQL.Text:= 'select LDEMDMOSCODE from LINKDETAILMODEL'+
          ' where LDEMTRNACODE='+IntToStr(NodeID)+' group by LDEMDMOSCODE';
        ORD_IBS.ExecQuery;
        while not ORD_IBS.Eof do begin // �������� ���� �������, ������� ���� �����������
          if Length(codes)<(j+1) then SetLength(codes, j+100);
          codes[j]:= ORD_IBS.FieldByName('LDEMDMOSCODE').AsInteger;
          inc(j);
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
        end;
      finally
        prFreeIBSQL(ORD_IBS);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;
      if Length(codes)>j then SetLength(codes, j);

      for j:= 0 to High(codes) do try //-------------------- ���������� ������
        ModelID:= codes[j];
        if not FDCA.Models.ModelExists(ModelID) then Continue;
        Model:= FDCA.Models[ModelID];
        if not Assigned(Model.NodeLinks) or // ���� ������ 2 �� ���� ����
          not Model.NodeLinks.LinkExists(NodeID) then Continue;

        link2:= Model.NodeLinks[NodeID];         // ��������� ������ 2 ����
        if link2.IsLinkNode and
          Assigned(link2.DoubleLinks) then Continue; // ���� ���� ������ 3 - ����������

        Model.NodeLinks.DeleteLinkItem(NodeID); // ������� ������ 2
      except
        on E: Exception do begin
          flag:= True;
          prMessageLOGS(nmProc+': ModelID='+IntToStr(ModelID)+
            ', NodeID='+IntToStr(NodeID)+': '+E.Message, 'import', False);
        end;
      end; // for j:= 0 to High(codes)
      TestCssStopException;

      if not flag then begin //------------------------------- ���������� ����
        Node.MainCode:= NodeID;
        ResCode:= resDeleted;
        Result:= '���� ('+IntToStr(NodeID)+')'+NodeName+
          ' ������� �� ���� ('+IntToStr(MainNodeID)+')'+MainNodeName;
      end;
      Exit;
    end;

//---- ��������� ����� ������� � ������� � ������� 3, ����� ����� - ���� - �����
//---- ������� ������ ������� � ������� � ������� 3, ����� - ���� - ����� - ��������
    flag:= False; // ������ flag - ���� ������
    SetLength(codes, 100);
    j:= 0;
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'update TREENODESAUTO set TRNAMAINCODE='+IntToStr(MainNodeID)+
        ', TRNAUSERID='+IntToStr(userID)+' where TRNACODE='+IntToStr(NodeID);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
      ORD_IBS.Close;

      fnSetTransParams(ORD_IBS.Transaction, tpRead, True);
      ORD_IBS.SQL.Text:= 'select LDEMDMOSCODE from LINKDETAILMODEL'+
        ' where LDEMTRNACODE in ('+IntToStr(NodeID)+', '+IntToStr(MainNodeID)+
        ') group by LDEMDMOSCODE';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin // �������� ���� �������, ������� ���� �����������
        if Length(codes)<(j+1) then SetLength(codes, j+100);
        codes[j]:= ORD_IBS.FieldByName('LDEMDMOSCODE').AsInteger;
        inc(j);
        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if Length(codes)>j then SetLength(codes, j);

   //------------------------------------------------ ���������� ������
    for j:= 0 to High(codes) do try
      ModelID:= codes[j];
      if not FDCA.Models.ModelExists(ModelID) then Continue;
      Model:= FDCA.Models[ModelID];
      if not Assigned(Model.NodeLinks) then Continue; // ���� ������ 2 �� ���� ����

      fLinkEx:= Model.NodeLinks.LinkExists(NodeID);
      fMainLinkEx:= Model.NodeLinks.LinkExists(MainNodeID);
      if not fLinkEx and not fMainLinkEx then Continue;

   //------------------------------------------------ ���������� ������ 2
      link2main:= nil;
      link2:= nil; // ������ 2
      if not fLinkEx then begin
        link2main:= Model.NodeLinks[MainNodeID]; // ��������� ������ 2 ������� ����
        s:= FDCA.CheckModelNodeLinkDup(ModelID, NodeID, FloatToStr(link2main.Qty), res, link2main.SrcID, userID);
        if (res=resError) then raise Exception.Create(s);
      end;
      if not fMainLinkEx then begin
        link2:= Model.NodeLinks[NodeID];         // ��������� ������ 2 ����
        s:= FDCA.CheckModelNodeLinkDup(ModelID, MainNodeID, FloatToStr(link2.Qty), res, link2.SrcID, userID);
        if (res=resError) then raise Exception.Create(s);
        TestCssStopException;
      end;
      if not Assigned(link2) then link2:= Model.NodeLinks[NodeID];             // ��������� ������ 2 ����
      if not Assigned(link2main) then link2main:= Model.NodeLinks[MainNodeID]; // ��������� ������ 2 ������� ����
      if not Assigned(link2) or not Assigned(link2main) then
        raise Exception.Create('error create link');

      if (link2.Qty>link2main.Qty) then begin // ��������� ���-�� �� ������� ����
        s:= FDCA.CheckModelNodeLinkDup(ModelID, MainNodeID, FloatToStr(link2.Qty), res, link2.SrcID, userID);
        if (res=resError) then raise Exception.Create(s);
        TestCssStopException;
      end;

      if not link2.IsLinkNode or
        not Assigned(link2.DoubleLinks) then Continue; // ���� ������ 3 �� ������ 2 ����

      links3:= link2.DoubleLinks;
      for j3:= links3.Count-1 downto 0 do try //---- ���������� ������ 3
        link3:= links3[j3]; // ��������� ������ 3 ����
        WareID:= TDirItem(link3).ID;
//        if Cache.WareExist(WareID) then begin  // ???
          res:= resAdded;  // ��������� ������ 3 � ������ ������� ���� (���� ����� ���)
          s:= FDCA.CheckWareModelNodeLink(WareID, ModelID, MainNodeID, res, link3.srcID, userID);
          if (res=resError) then raise Exception.Create(s);
          TestCssStopException;

     //------------------------------------ ������� ������ 3 �� ������ ����
          res:= resDeleted;
          s:= FDCA.CheckWareModelNodeLink(WareID, ModelID, NodeID, res);
          if (res=resError) then raise Exception.Create(s);
//        end;
        TestCssStopException;
      except
        on E: EBOBError do raise EBOBError.Create(E.Message);
        on E: Exception do begin
          flag:= True;
          prMessageLOGS(nmProc+': ModelID='+IntToStr(ModelID)+
            ', NodeID='+IntToStr(NodeID)+', WareID='+IntToStr(WareID)+': '+E.Message, 'import', False);
        end;
      end; // for j3:= links3.ListLinks.Count-1 downto 0

    except
      on E: EBOBError do raise EBOBError.Create(E.Message);
      on E: Exception do begin
        flag:= True;
        prMessageLOGS(nmProc+': ModelID='+IntToStr(ModelID)+
          ', NodeID='+IntToStr(NodeID)+': '+E.Message, 'import', False);
      end;
    end; // for j:= 0 to High(codes)

    if not flag then begin //-------------------------------- ����������� ����
      Node.MainCode:= MainNodeID;
      ResCode:= resAdded;
      Result:= '���� ('+IntToStr(NodeID)+')'+NodeName+
        ' �������� � ���� ('+IntToStr(MainNodeID)+')'+MainNodeName;
    end;
  finally
    SetLength(codes, 0);
  end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;
//==================================== �������� ������������ ������ ���� �������
function TDataCache.CheckWaresEqualSys(WareID1, WareID2: Integer): Boolean;
var i, k: integer;
    ware1, ware2: TWareInfo;
begin
  Result:= False;
  if not Assigned(self) or not WareExist(WareID1) or not WareExist(WareID2) then exit;
  ware1:= arWareInfo[WareID1];
  if ware1.IsArchive then exit;
  ware2:= arWareInfo[WareID2];
  if ware2.IsArchive then exit;
  with SysTypes do for i:= 0 to Count-1 do begin // ����� ����� ������
    k:= GetDirItemID(ItemsList[i]);
    Result:= ware1.CheckWareTypeSys(k) and ware2.CheckWareTypeSys(k);
    if Result then break;
  end;
end;
// ������������� ������ ������� (Object-ID) �� ������� �/��� ��������� �/��� ������
function TDataCache.GetSysManagerWares(SysID: Integer=0; ManID: Integer=0;
         Brand: integer=0; Sort: boolean=True): TStringList; // must Free Result
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  if (Brand>0) and not WareBrands.ItemExists(Brand) then Exit;
//    raise EBOBError.Create('�� ������ ����� � ����� '+IntToStr(Brand));
  if (ManID>0) and not EmplExist(ManID) then Exit;
//    raise EBOBError.Create('�� ������ �������� � ����� '+IntToStr(ManID));
  if (SysID>0) and not CheckTypeSys(SysID) then Exit;
//    raise EBOBError.Create('�� ������� ������� ����� � ����� '+IntToStr(SysID));
  Result.Capacity:= length(ArWareInfo);
  for i:= 1 to High(arWareInfo) do
    if not WareExist(i) then Continue else with GetWare(i) do begin
      if IsArchive or (PgrID<1) then Continue;
      if (PgrID=pgrDeliv) then Continue; // ���������� ��������
      if (ManID>0) and (ManID<>ManagerID) then Continue;
      if (SysID>0) and not CheckWareTypeSys(SysID) then Continue;
      if (Brand>0) and (WareBrandID<>Brand) then Continue;
      Result.AddObject(Name, Pointer(ID));
    end;
  if Sort and (Result.Count>1) then Result.Sort;
end;
//============================================= ���������� ������ ������� TecDoc
function TDataCache.FillBrandTDList: TStringList;
const nmProc = 'FillBrandTDList';
var IBD: TIBDatabase;
    IBS: TIBSQL;
    sBrand: String;
    iMF: Integer;
begin
  Result:= fnCreateStringList(True, dupIgnore);
  IBS:= nil;
  try
    IBD:= cntsTDT.GetFreeCnt;
  except
    Exit;
  end;
  try
    IBS:= fnCreateNewIBsql(IBD, 'IBS_'+nmProc, -1, tpRead, True);
    IBS.SQL.Text:= 'select DS_MF_ID mfID,'+
      ' iif(ICN_NEWDESCR is null, DS_BRA, ICN_NEWDESCR) mfName'+
      ' from DATA_SUPPLIERS'+
      ' left join IMPORT_CHANGE_NAMES on ICN_TAB_ID = 100 and ICN_KE_KEY = DS_MF_ID'+
      ' order by mfName';
    IBS.ExecQuery;
    while not IBS.Eof do begin
      sBrand:= Trim(IBS.FieldByName('mfName').asString);
      iMF:= IBS.FieldByName('mfID').asInteger;
      Result.AddObject(sBrand, Pointer(iMF));
      cntsTDT.TestSuspendException;
      IBS.Next;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(IBS);
  cntsTDT.SetFreeCnt(IBD);
  TestCssStopException;
end;
//===================================== ����� ���������� ���.���� ��� ����������
function TDataCache.GetLastTimeCache: Double;
begin
  if WareCacheTested then Result:= -1 else Result:= LastTimeCache;
end;
//================ ������ ������� � ������� �� ����� � ������� ������ � ��������
function TDataCache.GetWareModelUsesAndTextsView(WareID: Integer; Models: TList): TStringList; // must Free Result
const nmProc = 'GetWareModelUsesAndTextsView';
var iType, iPart, pCount, NodeID, sysID, i: integer;
    s, TypeName, nodeDelim, partDelim: String;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    Model: TModelAuto;
    lst: TStringList;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  nodes:= nil;
  sysID:= 0;
  lst:= TStringList.Create;
  try
    if not WareExist(WareID) or not Assigned(Models) or (Models.Count<1) then Exit;

    nodeDelim:= brcWebDelim; // ����������� �����
    partDelim:= '---------- ��� ----------';     // ����������� ������
    partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // ������ ������ �����
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);
      ORD_IBS.SQL.Text:= 'select rNodeID, Rpart, Rtype, RtypeName, Rtext'+
        ' from GetModelWareTextUses(:ModelID, '+IntToStr(WareID)+')';
      ORD_IBS.Prepare;
      for i:= 0 to Models.Count-1 do begin
        Model:= TModelAuto(Models[i]);
        if (sysID<>Model.TypeSys) then begin
          sysID:= Model.TypeSys;
          nodes:= FDCA.AutoTreeNodesSys[sysID];
        end;
        lst.Clear;

        ORD_IBS.ParamByName('ModelID').AsInteger:= Model.ID;
        ORD_IBS.ExecQuery;
        while not ORD_IBS.Eof do begin
          NodeID:= ORD_IBS.FieldByName('rNodeID').AsInteger; // ��� ����

          if nodes.NodeExists(NodeID) then begin
            node:= nodes[NodeID];
            if not node.IsEnding then node:= nil;
          end else node:= nil;

          if not Assigned(node) then begin
            TestCssStopException;
            while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger) do ORD_IBS.Next;
            Continue;
          end;

          if (lst.Count>0) then lst.Add(nodeDelim); // ����������� �����
          s:= '���� - '+node.Name+': ';
          s:= brcWebColorBlueBegin+s+brcWebColorEnd; // ����� �����
          lst.Add(s); // �������� ����

          pCount:= 0; // ������� ������
          while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger) do begin // �������� ������ �� 1-�� ����
            iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������
            if pCount>0 then lst.Add(partDelim);   // ����������� ������
            while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger)
              and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // ������ �� 1 ������
              iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
              TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
              s:= '';
              while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger)
                and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
                and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // ������ �� 1 ���� ������
                s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
                cntsORD.TestSuspendException;
                ORD_IBS.Next;
              end;
              s:= TypeName+fnIfStr(s='', '', ': '+s);  // ������ �� 1-�� ���� ������
              lst.Add(s);
            end; // while not ORD_IBS.Eof and (NodeID=... and (iPart=
            inc(pCount); // ������� ������
          end; // while not ORD_IBS.Eof and (NodeID=
        end; //  while not ORD_IBS.Eof
        ORD_IBS.Close;

        if (Lst.Count>0) then s:= Lst.Text else s:= '';
        Result.Add(s);
      end; // for
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
      if (Result.Count<Models.Count) then begin
        prMessageLOGS(nmProc+': Result.Count<Models.Count', fLogCache);
        sysID:= Result.Count;
        for i:= sysID to Models.Count-1 do Result.Add('');
      end;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//======================= ������ ������� � ������� � ������� 3, Objects - WareID
function TDataCache.GetWaresModelNodeUsesAndTextsView(ModelID, NodeID: Integer;
         WareCodes: Tai; var sFilters: String): TStringList; // must Free Result
const nmProc = 'GetWaresModelNodeUsesAndTextsView';
// �� ����� ��� ���� Motul < 0  !!!
var iType, i, ii, NodeCount, iPart, pCount, j: integer;
    s, TypeName, str, nodeDelim, partDelim, sSQL, ss, sn, snPrev: String;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    lst, lstPLs: TStringList;
    arNodeCodes, arNodeCodesM: Tai;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    Model: TModelAuto;
    flNotEndNode, flPart0, flMotulNode: Boolean;
    link: TSecondLink;
    ware: TWareInfo;
    mNode: TMotulNode;
  //---------------------------------
  procedure AddCodes(inode: integer);
  var j: Integer;
  begin
    if not nodes.NodeExists(inode) then exit;
    node:= nodes[inode];
    if node.IsEnding then begin // ���� �������� ����
      if Model.NodeLinks.LinkExists(inode) then begin
        link:= Model.NodeLinks[inode];           // ���������� ��� ������� ����
        j:= node.MainCode;
        if link.NodeHasWares then prAddItemToIntArray(j, arNodeCodes);
              // ����� ��� ���� ��������� ������� < 0  !!!
        if link.NodeHasPLs then prAddItemToIntArray(-j, arNodeCodesM);
      end;
    end else with node.Children do
      for j:= 0 to Count-1 do AddCodes(TAutoTreeNode(Objects[j]).ID);
  end;
  //---------------------------------
begin
  Result:= TStringList.Create;
  if not Assigned(self) or (length(WareCodes)<1) then Exit;
  lst:= TStringList.Create;
  lstPLs:= TStringList.Create;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
//  NodeCount:= 0;
  SetLength(arNodeCodes, 0);
  SetLength(arNodeCodesM, 0);
  sSQL:= '';
  try try
    if not FDCA.Models.ModelExists(ModelID) then
      raise Exception.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));

    flMotulNode:= (NodeID<0);
    if flMotulNode then begin  //-------------------------- ���� Motul (0 - ���)
      NodeID:= -NodeID;
      prAddItemToIntArray(NodeID, arNodeCodesM);
      flNotEndNode:= False;
    end else if (NodeID<1) then begin
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    end else begin           //-------------------------- ���� ��������� �������
      Model:= FDCA.Models[ModelID];
      nodes:= FDCA.AutoTreeNodesSys[Model.TypeSys];
      if not nodes.NodeExists(NodeID) then
        raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
      node:= nodes[NodeID];
      flNotEndNode:= not node.IsEnding;
      AddCodes(NodeID);         // �������� ���� ���� ������� �������� ���
      if (Length(arNodeCodes)<1) and (Length(arNodeCodesM)<1) then Exit; // ���� ��� ���

      if flNotEndNode then str:= cWebSpace+cWebSpace+cWebSpace else str:= ''; // ������, ���� ���.���� �� ��������
      nodeDelim:= brcWebDelim; // ����������� ����� / 0-� ������
      partDelim:= '---------- ��� ----------';     // ����������� ������
      partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // ������ ������ �����
//      partDelim:= cWebItalBegin+cWebBoldBlackBegin+partDelim+cWebBoldEnd+cWebItalEnd; // ������ ������ ������
    end;

      //-------------------- ����� SQL ��� ������������ ������� �� ������� Motul
      if (Length(arNodeCodesM)>0) then begin
        for ii:= 0 to High(arNodeCodesM) do begin
          NodeID:= arNodeCodesM[ii];
          if (sSQL<>'') then sSQL:= sSQL+#13#10' union ';
          sSQL:= sSQL+'select Rpline, rNode, RcriName, Rvalues'+
            ' from GetModelNodesPLines('+IntToStr(ModelID)+', '+IntToStr(NodeID)+')';
        end; // for ii:= 0 to High(arNodeCodes)
        if (sSQL<>'') then
          sSQL:= 'select rNode, RcriName, Rvalues from ('+sSQL+')'+
                 ' where Rpline=:pline order by rNode, RcriName';
      end; // if (Length(arNodeCodesM)>0)

      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, true);

      if (sSQL<>'') then begin //----------- ���������� ������� �� ������� Motul
        ORD_IBS.SQL.Text:= sSQL;
        for i:= 0 to High(WareCodes) do begin // �������� ���� ����.������
          ware:= GetWare(WareCodes[i], True);
          if (ware=NoWare) then Continue;
          ii:= ware.ProductLine;
          if Assigned(ProductLines.GetProductLine(ii))
            and (lstPLs.IndexOfObject(Pointer(ii))<0) then
            lstPLs.AddObject('', Pointer(ii));
        end;
        for i:= 0 to lstPLs.Count-1 do try
          ORD_IBS.ParamByName('pline').AsInteger:= Integer(lstPLs.Objects[i]);
          ORD_IBS.ExecQuery;

          if (lst.Count>0) then lst.Clear; // �������� ������� ������������ ����.�������
          NodeCount:= 0; // ���-�� ����� � ���������
          while not ORD_IBS.Eof do begin
            ii:= ORD_IBS.FieldByName('rNode').AsInteger; // ��� ���� Motul
            if not MotulTreeNodes.ItemExists(ii) then begin
              TestCssStopException;
              while not ORD_IBS.Eof and (ii=ORD_IBS.FieldByName('rNode').asInteger) do ORD_IBS.Next;
              Continue;
            end;
            j:= 0;
            while not ORD_IBS.Eof and (ii=ORD_IBS.FieldByName('rNode').asInteger) do begin
              ss:= ORD_IBS.FieldByName('RcriName').AsString;
              s:= ORD_IBS.FieldByName('Rvalues').AsString;
              if (s<>'') or (ss<>'') then begin //-------- ���� �������

                if (j=0) then begin // 1-� ������ � ��������� �� ����
                  mNode:= MotulTreeNodes[ii];
                  sn:= '���� Motul - '+mNode.Name+': ';        // �������� ����
                  sn:= brcWebColorBlueBegin+sn+brcWebColorEnd; // ����� �����
                  //------------- �������� ���������� ���� ��� ����� ���������
                  if flNotEndNode or (NodeCount>0) then begin
                    // ���� ����� �� 2-� ���� - ��������� � ������ �������� 1-��
                    if (NodeCount=1) then lst.Insert(0, snPrev);
                    lst.Add(sn); // ����� �������� ����
                  end; // if flNotEndNode or (NodeCount>0)
                  inc(NodeCount); // ���-�� ����� � ���������
                  snPrev:= sn; // ���������� �������� ����������� ����
                end; // if (j=0)

                lst.Add(ss+fnIfStr(s='', '', ': '+s)); // ������ �� 1-�� ��������
                inc(j);
              end; // if (s<>'') or (ss<>'')
              cntsORD.TestSuspendException;
              ORD_IBS.Next;
            end; // while ... and (ii= ...
          end; // while not ORD_IBS.Eof
          lstPLs[i]:= lst.Text;
        finally
          ORD_IBS.Close;
        end;
      end; // if (sSQL<>'')

      if not flMotulNode then begin
        ORD_IBS.SQL.Text:= 'select Rpart, Rtype, RtypeName, Rtext'+
                           ' from GetModelNodeWareFiltTextUses_n('+
                           IntToStr(ModelID)+', :NodeID, :WareID, :sFilters)';
        ORD_IBS.ParamByName('sFilters').AsString:= sFilters;
      end; // if not flMotulNode

      for i:= 0 to High(WareCodes) do begin
        ware:= GetWare(WareCodes[i], True);
        if (ware=NoWare) then Continue;

        if (lst.Count>0) then lst.Clear;

        if (lstPLs.Count>0) then begin
          s:= '';
          ii:= ware.ProductLine;
          //---------- ������� ��������� ������� ������� �� ����.�������
          if (ii>0) and (sSQL<>'') then begin
            iPart:= lstPLs.IndexOfObject(Pointer(ii));
            if (iPart>-1) then s:= lstPLs[iPart];
          end;
          if (s<>'') then begin // ���� - ����� ��� ������ ����
            lst.Text:= s;
            if not flNotEndNode then lst.Add(nodeDelim); // �������� ������� Motul
  //          Result.AddObject(s, Pointer(WareCodes[i]));
  //          Continue;
          end;
        end; // if (lstPLs.Count>0)

        if not flMotulNode then begin  // ���� ������� �� ���� ��������� �������
          ORD_IBS.ParamByName('WareID').AsInteger:= WareCodes[i];
          flPart0:= False;
          for ii:= 0 to High(arNodeCodes) do begin
            NodeID:= arNodeCodes[ii];
            ORD_IBS.ParamByName('NodeID').AsInteger:= NodeID;
            ORD_IBS.ExecQuery;
            // ���� �� ���� ���-�� ���� � ���.���� �� �������� - ����� �������� ����
            if flNotEndNode and not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
              if (lst.Count>0) then lst.Add(nodeDelim);  // ����������� �����
              s:= '���� - '+nodes[NodeID].Name+': ';
              s:= brcWebColorBlueBegin+s+brcWebColorEnd; // ����� �����
              lst.Add(s);
            end;

            pCount:= 0; // ������� ������
            while not ORD_IBS.Eof do begin // �������� ������ �� 1-�� ����
              iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������
              if (iPart<0) and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
                sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
                cntsORD.TestSuspendException;
                ORD_IBS.Next;
                Continue;
              end;

              if (iPart=0) then flPart0:= True; // ���� 0-� ������ (�������� �������� ������� ������)
              if (pCount>0) then
                if flPart0 then begin
                  lst.Add(brcWebDelim); // ����������� 0-� ������
                  flPart0:= False;
                end else lst.Add(partDelim);   // ����������� ������

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
                if (iPart=0) then  // �������� ������ 0-� ������
                  s:= brcWebColorRedBegin+s+brcWebColorEnd; // ������� �����
                lst.Add(s);
              end; // while not ORD_IBS.Eof and (iPart=

              inc(pCount); // ������� ������
            end; //  while not ORD_IBS.Eof
            ORD_IBS.Close;
          end; // for ii:= 0 to High(arNodeCodes)
        end; // if not flMotulNode

        if (lst.Count>0) then begin
          iPart:= lst.Count-1; // ���� � ��������� ������ ����������� - �������
          if (lst[iPart]=nodeDelim) then lst.Delete(iPart);
        end;

        if (lst.Count>0) then Result.AddObject(lst.Text, Pointer(WareCodes[i]));
      end; // for i:= 0 to High(WareCodes)
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
      SetLength(arNodeCodes, 0);
      SetLength(arNodeCodesM, 0);
      prFree(lst);
      prFree(lstPLs);
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//=== ������.������ ������� � �������� � ��������� � ������� 3, Objects - WareID
function TDataCache.GetModelNodeWaresWithUsesByFilters(ModelID, NodeID: Integer;
         withChildNodes: boolean; var sFilters: String): TStringList; // must Free Result
// sFilters - ���� �������� ��������� ����� �������
const nmProc = 'GetModelNodeWaresWithUsesByFilters';
var iType, i, ii, NodeCount, iPart, pCount, wareID, j: integer;
    s, TypeName, str, nodeDelim, partDelim, sSQL, ss, sn, snPrev: String;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    lst: TStringList;
    arNodeCodes, arNodeCodesM: Tai;
    nodes: TAutoTreeNodes;
    node: TAutoTreeNode;
    Model: TModelAuto;
    flNotEndNode, flPart0, flFromBase: Boolean;
    WareCodes: Tai;
    nlinks: TLinks;
    mNode: TMotulNode;
    PLine: TProductLine;
    link: TSecondLink;
    ware: TWareInfo;
  //---------------------------------
  procedure AddCodes(inode: integer);
  var j: Integer;
  begin
    if not nodes.NodeExists(inode) then exit;
    node:= nodes[inode];
    if node.IsEnding then begin // ���� �������� ����
      if nlinks.LinkExists(inode) then begin
        link:= nlinks[inode];              // ���������� ��� ������� ����
        if link.NodeHasWares then prAddItemToIntArray(node.MainCode, arNodeCodes);
        if link.NodeHasPLs then prAddItemToIntArray(node.MainCode, arNodeCodesM);
      end;
    end else with node.Children do
      for j:= 0 to Count-1 do AddCodes(TAutoTreeNode(Objects[j]).ID);
  end;
  //---------------------------------
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  lst:= TStringList.Create;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
//  NodeCount:= 0;
  SetLength(arNodeCodes, 0);
  SetLength(WareCodes, 0);
  SetLength(arNodeCodesM, 0);
  sSQL:= '';
  try try
    with FDCA do begin
      if not Models.ModelExists(ModelID) then
        raise Exception.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));
      Model:= Models[ModelID];
      nodes:= AutoTreeNodesSys[Model.TypeSys];
    end;

    if not nodes.NodeExists(NodeID) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    node:= nodes[NodeID];
    flNotEndNode:= not node.IsEnding;

    nodeDelim:= brcWebDelim;      // ����������� ����� / 0-� ������
    partDelim:= '---------- ��� ----------';           // ����������� ������
    partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // ������ ������ �����
    if flNotEndNode then str:= cWebSpace+cWebSpace+cWebSpace else str:= ''; // ������, ���� ���.���� �� ��������
//    partDelim:= cWebItalBegin+cWebBoldBlackBegin+partDelim+cWebBoldEnd+cWebItalEnd; // ������ ������ ������

    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);

    sFilters:= StringReplace(sFilters, ' ', '', [rfReplaceAll]); // ������� ��� �������
//------------------------------------------ ���� ������ ������� (���� ��������)
    if not flNotEndNode and (sFilters<>'') then begin
      ORD_IBS.SQL.Text:= 'select RWare, Rpart, Rtype, RtypeName, Rtext'+
        ' from GetModNodFiltWaresWithUseParts_('+
        IntToStr(ModelID)+', '+IntToStr(NodeID)+', :sFilters)';
      ORD_IBS.ParamByName('sFilters').AsString:= sFilters;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        if (ORD_IBS.FieldByName('Rpart').AsInteger<0)
          and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
          sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
          Continue;
        end;

        wareID:= ORD_IBS.FieldByName('RWare').AsInteger; // ��� ������
        if Cache.WareExist(wareID) then begin
          ware:= Cache.GetWare(wareID, True);
          if (ware=NoWare) or ware.IsArchive or ware.IsINFOgr then ware:= nil;
        end else ware:= nil;
        if not Assigned(ware) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        if (ORD_IBS.FieldByName('RtypeName').AsString='') then begin // ���� ������ ��� ������
          Result.AddObject('', Pointer(wareID));
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
          Continue;
        end;

        pCount:= 0; // ������� ������
        if (lst.Count>0) then lst.Clear;
        flPart0:= False;                    // �������� ������ �� 1-�� ������
        while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger) do begin
          iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������

          if (iPart<0) and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
            sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // ������ �������� ��������
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
            Continue;
          end;

          if (iPart=0) then flPart0:= True; // ���� 0-� ������ (�������� �������� ������� ������)
          if pCount>0 then
            if flPart0 then begin
              lst.Add(brcWebDelim); // ����������� 0-� ������
              flPart0:= False;
            end else lst.Add(partDelim); // ����������� ������

          while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger)
            and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // ������ �� 1 ������
            iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
            TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
            s:= '';
            while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger)
              and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
              and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // ������ �� 1 ���� ������
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

        Result.AddObject(lst.Text, Pointer(wareID));
      end; // while not ORD_IBS.Eof
      ORD_IBS.Close;
                          // ����� SQL ��� ������������ ������� �� ������� Motul
      sSQL:= 'select Rpline, rNode, RcriName, Rvalues'+
        ' from GetModelNodesPLines('+IntToStr(ModelID)+', -'+IntToStr(NodeID)+')'+
        ' order by Rpline, rNode, RcriName';

//      if (Result.Count>1) then Result.CustomSort(ObjWareNameSortCompare); // ���������� �� ������������ ������

//------------------------------------------------------- ���� �� ������ �������
    end else begin
      flFromBase:= not Cache.WareLinksUnLocked; // ���� ��� ������ �� �������� - ����� �� ����
      WareCodes:= Model.GetModelNodeWares(NodeId, withChildNodes, flFromBase); // ���� ������� �� ���� ������
      try
        if flFromBase then nlinks:= Model.GetModelNodesLinks else nlinks:= Model.NodeLinks;
        AddCodes(NodeID);         // �������� ���� ���� ������� �������� ���
        if (Length(arNodeCodes)<1) and (Length(arNodeCodesM)<1) then begin // ���� ��� ���
          for i:= 0 to High(WareCodes) do Result.AddObject('', Pointer(WareCodes[i]));
          Exit;
        end;
      finally
        if flFromBase then nlinks.Free;
      end;

      if (Length(WareCodes)>0) then begin
        ORD_IBS.SQL.Text:= 'select Rpart, Rtype, RtypeName, Rtext'+
          ' from GetWareModelNodeUseTextParts_n('+IntToStr(ModelID)+', :NodeID, :WareID)';
        for i:= 0 to High(WareCodes) do begin
          if (lst.Count>0) then lst.Clear;
          ORD_IBS.ParamByName('WareID').AsInteger:= WareCodes[i];

          for ii:= 0 to High(arNodeCodes) do begin
            NodeID:= arNodeCodes[ii];
            ORD_IBS.ParamByName('NodeID').AsInteger:= NodeID;
            ORD_IBS.ExecQuery;
            // ���� �� ���� ���-�� ���� � ���.���� �� �������� - ����� �������� ����
            if flNotEndNode and not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
              if lst.Count>0 then lst.Add(nodeDelim);    // ����������� �����
              s:= '���� - '+nodes[NodeID].Name+': ';
              s:= brcWebColorBlueBegin+s+brcWebColorEnd; // ����� �����
              lst.Add(s);
            end;

            pCount:= 0; // ������� ������
            while not ORD_IBS.Eof do begin // �������� ������ �� 1-�� ����
              iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // ������
              if pCount>0 then lst.Add(partDelim);            // ����������� ������

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

              inc(pCount); // ������� ������
            end; //  while not ORD_IBS.Eof
            ORD_IBS.Close;
          end; // for ii:= 0 to High(arNodeCodes)

          Result.AddObject(lst.Text, Pointer(WareCodes[i]));
        end; // for i:= 0 to High(WareCodes)
      end; // if (Length(WareCodes)>0)
                          // ����� SQL ��� ������������ ������� �� ������� Motul
      if (Length(arNodeCodesM)>0) then begin
        for ii:= 0 to High(arNodeCodesM) do begin
          NodeID:= arNodeCodesM[ii];
          if (NodeID<1) then Continue;
          if (sSQL<>'') then sSQL:= sSQL+#13#10' union ';
          sSQL:= sSQL+'select Rpline, rNode, RcriName, Rvalues'+
            ' from GetModelNodesPLines('+IntToStr(ModelID)+', -'+IntToStr(NodeID)+')';
        end; // for ii:= 0 to High(arNodeCodesM)
        if (sSQL<>'') then
          sSQL:= 'select Rpline, rNode, RcriName, Rvalues from ('+sSQL+')'+
                 ' order by Rpline, rNode, RcriName';
      end; // if (Length(arNodeCodesM)>0)
    end;

    if (sSQL<>'') then begin // ����������� ������ �� ������� Motul
      ORD_IBS.SQL.Text:= sSQL;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iType:= ORD_IBS.FieldByName('Rpline').AsInteger; // ��� ����.�������
        PLine:= Cache.ProductLines.GetProductLine(iType);
        if not Assigned(PLine) or (PLine.WareLinks.LinkCount<1) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (iType=ORD_IBS.FieldByName('Rpline').asInteger) do ORD_IBS.Next;
          Continue;
        end;

        if (lst.Count>0) then lst.Clear; // �������� ������� ������������ ����.�������
        NodeCount:= 0; // ���-�� ����� � ���������
        while not ORD_IBS.Eof and (iType=ORD_IBS.FieldByName('Rpline').asInteger) do begin
          iPart:= ORD_IBS.FieldByName('rNode').AsInteger; // ��� ���� Motul
          if not Cache.MotulTreeNodes.ItemExists(iPart) then begin
            TestCssStopException;
            while not ORD_IBS.Eof and (iType=ORD_IBS.FieldByName('Rpline').asInteger)
              and (iPart=ORD_IBS.FieldByName('rNode').asInteger) do ORD_IBS.Next;
            Continue;
          end;
          j:= 0;
          while not ORD_IBS.Eof and (iType=ORD_IBS.FieldByName('Rpline').asInteger)
            and (iPart=ORD_IBS.FieldByName('rNode').asInteger) do begin
            ss:= ORD_IBS.FieldByName('RcriName').AsString;
            s:= ORD_IBS.FieldByName('Rvalues').AsString;
            if (s<>'') or (ss<>'') then begin //-------- ���� �������

              if (j=0) then begin // 1-� ������ � ��������� �� ����
                mNode:= Cache.MotulTreeNodes[iPart];
                sn:= '���� Motul - '+mNode.Name+': ';        // �������� ����
                sn:= brcWebColorBlueBegin+sn+brcWebColorEnd; // ����� �����
                //------------- �������� ���������� ���� ��� ����� ���������
                if flNotEndNode or (NodeCount>0) then begin
                  // ���� ����� �� 2-� ���� - ��������� � ������ �������� 1-��
                  if (NodeCount=1) then lst.Insert(0, snPrev);
                  lst.Add(sn); // ����� �������� ����
                end; // if flNotEndNode or (NodeCount>0)
                inc(NodeCount); // ���-�� ����� � ���������
                snPrev:= sn; // ���������� �������� ����������� ����
              end; // if (j=0)

              lst.Add(ss+fnIfStr(s='', '', ': '+s)); // ������ �� 1-�� ��������
              inc(j);
            end; // if (s<>'') or (ss<>'')
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
          end; // while ... and (plID= ... and (iPart=
        end; // while not ORD_IBS.Eof and (iType= ... and
        //---------------------- ������ ������� ����.�������
        for i:= 0 to PLine.WareLinks.ListLinks.Count-1 do begin
          wareID:= GetLinkID(PLine.WareLinks.ListLinks[i]);
          if (Result.IndexOfObject(Pointer(wareID))<0) then
            Result.AddObject(lst.Text, Pointer(wareID));
        end; // for i:= 0 to PLine.WareLinks.ListLinks.Count

      end; // while not ORD_IBS.Eof
      ORD_IBS.Close;
    end; // if (sSQL<>'')

  except
    on E: Exception do prMessageLOGS(nmProc+': ModelID='+IntToStr(ModelID)+
      ' NodeID='+IntToStr(NodeID)+' sFilters='+sFilters+#10+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ORD_IBS);
    cntsOrd.SetFreeCnt(ORD_IBD);
    SetLength(arNodeCodes, 0);
    SetLength(WareCodes, 0);
    SetLength(arNodeCodesM, 0);
    prFree(lst);
  end;
end;
//===================== ��������/������� ���� ������ � �������� (Excel, �������)
function TDataCache.CheckWareCrossLink(pWareID, pCrossID: Integer;
         var ResCode: Integer; srcID: Integer; UserID: Integer=0): String;
const nmProc = 'CheckWareCrossLink';
// ResCode �� ����� - ��� �������� (resAdded, resDeleted, resWrong, resNotWrong)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������, resAdded - ���������,
// resDeleted - �������, resWrong - ��������, ��� ��������, resNotWrong - �������������
// �����������: ������� ����� ������ ������ � ���������� (Excel ��� �������)
//              �������� Wrong ����� ������ ������ � ���������� (TD)
var ibd: TIBDatabase;
    ibs: TIBSQL;
    Ware: TWareInfo;
    OpCode, LinkSrc: Integer;
    fex: Boolean;
    mess, s, sWare, sCross, sUser, mess1: string;
    pool: TIBCntsPool;
    empl: TEmplInfoItem;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  OpCode:= ResCode;
  ResCode:= resError;
  ibs:= nil;
  mess1:= '';
  try
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');
    if (pCrossID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' �������');

    Ware:= GetWare(pWareID, True);
    if (Ware=NoWare) or Ware.IsArchive then                   // ��������� �����
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));

    fex:= Ware.AnalogLinks.LinkExists(pCrossID) // �������� ������������� ������
          and TAnalogLink(Ware.AnalogLinks[pCrossID]).IsCross;
    if fex then begin
      mess:= '';
      case OpCode of
        resAdded   : mess:= '����� '+MessText(mtkWareAnalogLink)+' ����';
        resNotWrong: mess:= MessText(mtkWareAnalogLink)+' �� ��������, ��� ���������';
      end; // case
      if mess<>'' then begin
        ResCode:= resDoNothing;
        raise Exception.Create(mess);
      end;
    end else if (OpCode in [resDeleted, resWrong]) then begin
      ResCode:= resDoNothing;
      raise Exception.Create('�� ������� '+MessText(mtkWareAnalogLink));
    end;
                       // �������� ����������� ���������� � ����������� ��������
    if (OpCode in [resAdded, resNotWrong, resWrong]) and (userID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' �����')
    else if (OpCode in [resAdded]) and (srcID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' ���������')
    else if (OpCode in [resDeleted, resWrong]) then begin
      LinkSrc:= GetLinkSrc(Ware.AnalogLinks[pCrossID]);
      case OpCode of
      resDeleted: // ������� ����� ������ ������ � ���������� (Excel, GrossBee ��� �������)
        if not Cache.CheckLinkAllowDelete(LinkSrc) then begin
          if not Cache.CheckLinkAllowWrong(LinkSrc) then
            raise Exception.Create(MessText(mtkFuncNotAvailabl));
          if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' �����');
          OpCode:= resWrong; // ������ TecDoc �� �������, � �������� ���������
          mess1:= ' (TecDoc)';
        end;
      resWrong:  // �������� Wrong ����� ������ ������ � ���������� (TD)
        if not Cache.CheckLinkAllowWrong(LinkSrc) then
          raise Exception.Create(MessText(mtkFuncNotAvailabl));
      end; // case
    end;

    if CheckNotValidUser(userID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[userID];
//--------------------------------------------------- ������������ ������ � ����
    pool:= cntsGRB;
    ibd:= pool.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    LinkSrc:= FDCA.GetSourceGBcode(srcID);
    sWare:= IntToStr(pWareID);
    sCross:= IntToStr(pCrossID);
    sUser:= IntToStr(UserID);
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, true);

      case OpCode of
      resAdded: begin                // ���������
          ibs.SQL.Text:= 'select rCrossID, errLink from Vlad_CSS_AddWareCross('+
            sWare+', '+sCross+', '+sUser+', '+IntToStr(LinkSrc)+')';
          ibs.ExecQuery;
          if (ibs.Eof and ibs.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ibs.Fields[1].AsInteger>0) then
            raise EBOBError.Create('����� ������ � �������� � ���� ��������, ��� ��������')
          else if (ibs.Fields[1].AsInteger<0) then begin
            with Ware do if not AnalogLinks.LinkExists(pCrossID) and
              CheckAnalogLink(pCrossID, srcID) then SortAnalogsByName; // �� ����.������
            ResCode:= resDoNothing;
            raise EBOBError.Create('����� '+MessText(mtkWareAnalogLink)+' ����');
          end else if (ibs.Fields[0].AsInteger<1) then
            raise Exception.Create('error add cross Ware='+sWare+' Cross='+sCross);
        end; // resAdded

      resWrong, resNotWrong: begin // ������ ������� Wrong
          s:= fnIfStr(OpCode=resWrong, 'T', 'F');
          ibs.SQL.Text:= 'update PMWAREANALOGS set PMWAISWRONG="'+s+'", PMWAUSERCODE='+sUser+
            ' where PMWAWARECODE='+sWare+' and PMWAWAREANALOGCODE='+sCross;
          ibs.ExecQuery;
        end; // resWrong, resNotWrong

      resDeleted: begin              // �������
          ibs.SQL.Text:= 'select rCrossID from Vlad_CSS_DelWareCross('+
            sWare+', '+sCross+', '+IntToStr(LinkSrc)+')';
          ibs.ExecQuery;
          if (ibs.Bof and ibs.Eof) or (ibs.Fields[0].AsInteger<1) then
            raise Exception.Create('error del cross Ware='+sWare+' Cross='+sCross);
        end; // resDeleted
      end; // case
      ibs.Transaction.Commit;
    finally
      prFreeIBSQL(ibs);
      pool.SetFreeCnt(ibd);
    end;

//------------------------------------------------------------- ������������ ���
    with Ware do case OpCode of
      resAdded, resNotWrong:                               // ���������
        if CheckAnalogLink(pCrossID, srcID) then SortAnalogsByName;
      resDeleted, resWrong: DelAnalogLink(pCrossID, True); // �������
    end; // case

    mess:= MessText(mtkWareAnalogLink);
    case OpCode of
      resAdded:    Result:= mess+' ���������';
      resDeleted:  Result:= mess+' �������';
      resWrong:    Result:= mess+mess1+' ��������, ��� ��������';
      resNotWrong: Result:= mess+' �������������';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;
//==== ��������/������� ����� ������ � ��������� �� 1 �������� (�������� �� TDT)
function TDataCache.CheckWareArtCrossLinks(pWareID: Integer; CrossArt: String; crossMF: Integer;
         var ResCode: Integer; srcID: Integer; UserID: Integer=0; ibsORD: TIBSQL=nil): String;
const nmProc = 'CheckWareArtCrossLinks';
// ��� �������� - ResCode - �� ����� (resAdded, resDeleted)
// ResCode �� ������: resError- ������, resAdded - ���������, resDeleted - �������
var ibd: TIBDatabase;
    ibs: TIBSQL;
    Ware: TWareInfo;
    OpCode, i, j, srcGB: Integer;
    mess: string;
    ArCross: array of TCrossInfo; // ������ �������� �� �������� CrossArt
begin
  Result:= '';
  if not Assigned(self) then Exit;
  SetLength(ArCross, 0);
  OpCode:= ResCode;
  ResCode:= resError;
  ibs:= nil;
  ibd:= nil;
  srcGB:= FDCA.GetSourceGBcode(srcID);
  try
    if not (OpCode in [resAdded, resDeleted]) then // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');

    if (crossMF<1) or (CrossArt='') then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');

    Ware:= GetWare(pWareID, True);
    if (Ware=NoWare) or Ware.IsArchive then        // ��������� �����
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));

    if OpCode=resAdded then begin
      if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' �����');
      if (srcID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' ���������');
    end; // resAdded

    j:= 0; // ������� �������� �� �������� CrossArt
//--------------------------------------------------- ������������ ������ � ����
    if Assigned(ibsORD) then begin
      ibs:= ibsORD;
      with ibs.Transaction do if not InTransaction then StartTransaction;
    end else begin
      ibd:= cntsOrd.GetFreeCnt; // ���� �������, ����������� � �������� CrossArt, �� ���� dbOrder
      ibs:= fnCreateNewIBSQL(ibd, 'ibsOrd_'+nmProc, -1, tpRead, true);
    end;

    try
      if IBS.SQL.Text='' then
        IBS.SQL.Text:= 'select WATDWARECODE from WAREARTICLETD'+
          ' inner join wareoptions on wowarecode=WATDWARECODE and woarhived="F"'+
          ' where WATDARTSUP=:crossMF and WATDARTICLE=:CrossArt and WATDWRONG="F"';
      ibs.ParamByName('crossMF').AsInteger:= crossMF;
      ibs.ParamByName('CrossArt').AsString:= CrossArt;  // ������� TD
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.Fields[0].AsInteger;  // ��� ������ �� ��������-�������
        if WareExist(i) then begin
          if Length(ArCross)<(j+1) then SetLength(ArCross, j+100);
          ArCross[j].cross:= i;  // ��� ������ �� ��������-�������
          inc(j);
        end;
        TestCssStopException;
        ibs.Next;
      end;
    finally
      if Assigned(ibsORD) then ibs.Close
      else begin
        prFreeIBSQL(ibs);
        cntsOrd.SetFreeCnt(ibd);
      end;
    end;
    if Length(ArCross)>j then SetLength(ArCross, j);

    ibd:= cntsGRB.GetFreeCnt;                         // ����� � ���� Grossbee
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibsGRB_'+nmProc, -1, tpWrite, true);

      case OpCode of
      resAdded: begin         // ��������� / ��������� ������� �� ������ �����
          ibs.SQL.Text:= 'select rCrossID, errLink from Vlad_CSS_AddWareCross('+
            IntToStr(pWareID)+', :CrossID, '+IntToStr(UserID)+', '+IntToStr(srcGB)+')';
          for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then begin
            ibs.ParamByName('CrossID').AsInteger:= ArCross[j].cross;
            ibs.ExecQuery;
            if not (ibs.Bof and ibs.Eof) and (ibs.Fields[0].AsInteger>0) then begin
              ArCross[j].wrong:= ibs.Fields[1].AsInteger>0; // ������� ������������ ������
              ArCross[j].exist:= ibs.Fields[1].AsInteger<0; // ������� - ��� ����
            end else ArCross[j].cross:= 0; // ���� ���� �� ��������� - �������� ���
            ibs.Close;
          end;
        end; // resAdded

      resDeleted: begin              // ������� ������� �� ������ �����
          ibs.SQL.Text:= 'select rCrossID from Vlad_CSS_DelWareCross('+
            IntToStr(pWareID)+', :CrossID, '+IntToStr(srcGB)+')';
          for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then begin
            ibs.ParamByName('CrossID').AsInteger:= ArCross[j].cross;
            ibs.ExecQuery;
            if not (ibs.Bof and ibs.Eof) or (ibs.Fields[0].AsInteger<1) then
              ArCross[j].cross:= 0; // ���� ���� �� �������� - �������� ���
            ibs.Close;
          end;

        end; // resDeleted
      end; // case
      ibs.Transaction.Commit;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(ibd);
    end;

//------------------------------------------------------------- ������������ ���
    case OpCode of
      resAdded: begin  // ��������� / �������
          i:= 0; // ������� ����������� ������
          for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then with ArCross[j] do
            if wrong then Ware.DelAnalogLink(cross, True)
            else if (not exist or not Ware.AnalogLinks.LinkExists(cross)) and
              Ware.CheckAnalogLink(cross, srcID) then inc(i);
          if i>0 then Ware.SortAnalogsByName; // ���� ��������� - ���������
        end; // resAdded

      resDeleted:
        for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then
          Ware.DelAnalogLink(ArCross[j].cross, True);
    end; // case

    mess:= '����� ������ � ��������� �� �������� ';
    case OpCode of
      resAdded:    Result:= mess+'���������';
      resDeleted:  Result:= mess+'�������';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
  SetLength(ArCross, 0);
end;
//============================ �������� ���� ������ �� ��������� �������� � ����
function TDataCache.CheckWareCriValueLink(pWareID, criTD, UserID, srcID: Integer;
         CriName, CriValue: String): String;
const nmProc = 'CheckWareCriValueLink';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    sWare: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (CriName='') then raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    sWare:= intToStr(pWareID);
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;                 // ����� � ����
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'select linkID, errLink from AddWareCriLink('+
        sWare+', '+intToStr(criTD)+', :CriName, :CriValue, '+
        intToStr(UserID)+', '+intToStr(srcID)+')';
      ORD_IBS.ParamByName('CriName').AsString:= CriName;
      ORD_IBS.ParamByName('CriValue').AsString:= CriValue;
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Eof and ORD_IBS.Bof) then
        raise EBOBError.Create(MessText(mtkErrAddRecord))
      else if (ORD_IBS.Fields[1].AsInteger>0) then
        raise EBOBError.Create('����� ������ � ��������� � ���� ��������, ��� ��������')
      else if (ORD_IBS.Fields[1].AsInteger<0) then raise EBOBError.Create('exists')
      else if (ORD_IBS.Fields[0].AsInteger<1) then
        raise Exception.Create('error add cri link Ware='+sWare+
                               ' CriName='+CriName+' CriValue='+CriValue);
      ORD_IBS.Transaction.Commit;
      ORD_IBS.Close;
    finally
      with ORD_IBS.Transaction do if InTransaction then Rollback;
      ORD_IBS.Close;
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
//================================== ��������/������������� ���.��������� ������
function TDataCache.CheckBrandAdditionData(pBrandID, UserID: Integer;
         pNameWWW, pPrefix, pAdressWWW: String; pDownLoadEx, pPictShowEx: Boolean): String;
const nmProc = 'CheckBrandAdditionData';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    brand: TBrandItem;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  try
    if not WareBrands.ItemExists(pBrandID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');

    pPrefix:= trim(pPrefix);
    pAdressWWW:= trim(pAdressWWW);
    pNameWWW:= trim(pNameWWW);

    brand:= WareBrands[pBrandID];

if not flPictNotShow then pPictShowEx:= brand.PictShowExclude;

    if (pNameWWW=brand.NameWWW) and (pPrefix=brand.WarePrefix)
      and (pAdressWWW=brand.adressWWW) and (pDownLoadEx=brand.DownLoadExclude)
      and (pPictShowEx=brand.PictShowExclude) then Exit;

    try
      ORD_IBD:= cntsOrd.GetFreeCnt;                 // ����� � ����
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);

      ORD_IBS.SQL.Text:= 'update or insert into BRANDADDITIONDATA (BRADCODE,'+
        ' BRADNAMEWWW, BRADprefix, BRADaddress, BRADUSERID, BRADNotPriceLoad, BRADNOTPictShow)'+
        ' values ('+IntToStr(pBrandID)+', :nameWW, :pref, :adr, '+IntToStr(UserID)+
        ', :loadEx, :pictEx) matching (BRADCODE)';
      ORD_IBS.ParamByName('nameWW').AsString:= pNameWWW;
      ORD_IBS.ParamByName('pref').AsString:= pPrefix;
      ORD_IBS.ParamByName('adr').AsString:= pAdressWWW;
      ORD_IBS.ParamByName('loadEx').AsString:= fnIfStr(pDownLoadEx, 'T', 'F');
      ORD_IBS.ParamByName('pictEx').AsString:= fnIfStr(pPictShowEx, 'T', 'F');
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;

      WareBrands.CS_DirItems.Enter;
      try
        with brand do begin
          NameWWW:= pNameWWW;
          WarePrefix:= pPrefix;
          adressWWW:= pAdressWWW;
          DownLoadExclude:= pDownLoadEx;
          PictShowExclude:= pPictShowEx;
        end;
      finally
        WareBrands.CS_DirItems.Leave;
      end;

    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
//=========================== ����� ������ �������� ������� ������ 3 (���������)
function TDataCache.GetModelNodeWareUseListNumber(pModelID, pNodeID, pWareID: Integer;
         UseList: TStringList): Integer;
const nmProc = 'GetModelNodeWareUseListNumber';
// UseList - ������ ����� <��������>cStrValueDelim<��������>, � Object - <��� TecDoc ��������>
// ��� ������� �� Excel <��� TecDoc ��������>=0
// � Result - ����� ��������� ������, ����� -1
var ORD_IBD: TIBDatabase;
    ORD_IBSr: TIBSQL;
    criTD, iUseList, i, j, ii: Integer;
    UseName, UseValue, s: String;
    ordUses: TStringList;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  ORD_IBSr:= nil;
  ordUses:= TStringList.Create;
  j:= -1;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if not Assigned(UseList) or (UseList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- ������ ������ �������');

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBSr:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBSr_'+nmProc);
                                                   // ������� � �����e 3 �� ORD
      with ORD_IBSr.Transaction do if not InTransaction then StartTransaction;
      if ORD_IBSr.SQL.Text='' then
        ORD_IBSr.SQL.Text:= 'select LWMNUPART, WCRITDCODE, WCRIDESCRUP, WCVSVALUEUP'+
          ' from (select LWMNUPART, LWMNUWCVSCODE'+
          '   from (select ldmwcode from (select LDEMCODE from LINKDETAILMODEL'+
          '     where LDEMTRNACODE='+IntToStr(pNodeID)+' and LDEMDMOSCODE='+IntToStr(pModelID)+')'+   // and LDEMWRONG="F"
          '     inner join LINKDETMODWARE on LDMWLDEMCODE=LDEMCODE'+
          '       and LDMWWARECODE='+IntToStr(pWareID)+')'+                               // and LDMWWRONG="F"
          '   inner join LinkWareModelNodeUsage on LWMNULDMWCODE=ldmwcode)'+ // and LWMNUWRONG="F"
          ' left join WARECRIVALUES on WCVSCODE=LWMNUWCVSCODE'+
          ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE order by LWMNUPART';
      ORD_IBSr.ExecQuery;
      while not ORD_IBSr.Eof do begin
        iUseList:= ORD_IBSr.FieldByName('LWMNUPART').AsInteger; // 1 ������
        if ordUses.Count>0 then ordUses.Clear;

        while not ORD_IBSr.Eof and (iUseList=ORD_IBSr.FieldByName('LWMNUPART').AsInteger) do begin
          UseName:= ORD_IBSr.FieldByName('WCRIDESCRUP').AsString;
          UseValue:= ORD_IBSr.FieldByName('WCVSVALUEUP').AsString;
          criTD:= ORD_IBSr.FieldByName('WCRITDCODE').AsInteger;
          ordUses.AddObject(UseName+cStrValueDelim+UseValue, Pointer(criTD));
          TestCssStopException; // �������� ��������� �������
          ORD_IBSr.Next;
        end;
        if (ordUses.Count<>UseList.Count) then Continue; // �� ��������� ���-�� � ������

        for i:= 0 to UseList.Count-1 do begin
          j:= -1; // ������� ������ �������� ������ � ������ �� ����� ����
          criTD:= Integer(UseList.Objects[i]); // ��� �������� TD
          s:= fnGetBefore(cStrValueDelim, UseList[i]);
          if s='' then begin
            UseName:= AnsiUpperCase(UseList[i]);
            UseValue:= '';
          end else begin
            UseName:= AnsiUpperCase(s);
            UseValue:= AnsiUpperCase(fnGetAfter(cStrValueDelim, UseList[i]));
          end;
          if criTD>0 then begin // ���� ���� ��� TD
            for ii:= 0 to ordUses.Count-1 do
              if (criTD=Integer(ordUses.Objects[ii])) then begin
                s:= fnGetAfter(cStrValueDelim, ordUses[ii]); // ���� ��������
                if s=UseValue then j:= ii;
              end;
          end;
          if j<0 then begin // ���� �� ����� �������� ��������
            s:= UseName+cStrValueDelim+UseValue; // ���� ������ <��������>=<��������>
            j:= ordUses.IndexOf(s);
          end;
          if (j<0) then Break;  // ���� ����� �� �����
        end; // for i:= 0 to UseList.Count-1

        if (j>-1) then begin
          Result:= iUseList; // ���� ��� ����� - ���������� ����� ������
          Exit;
        end;
      end;
    finally
      prFreeIBSQL(ORD_IBSr);
      cntsOrd.SetFreeCnt(ORD_IBD);
      prFree(ordUses);
    end;
  except
    on E: Exception do begin
      Result:= -1;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//=================================================== �������� ����� �����������
function TDataCache.GetNotificationText(noteID: Integer): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if Notifications.ItemExists(noteID) then Result:= Notifications[noteID].Name;
end;
//================== �������� ����� ������/������������ ����������� ������������
function TDataCache.SetClientNotifiedKind(userID, noteID, kind: Integer): String;
// kind=0 - ����� �����������, kind>0 - ������������
const nmProc='SetClientNotifiedKind';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    sUser, sNote: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try // ����� ������� ��������
    if not Notifications.ItemExists(noteID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����������');
    if not ClientExist(userID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������������');
    sUser:= IntToStr(userID);
    sNote:= IntToStr(noteID);

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      case kind of
      0: ORD_IBS.SQL.Text:= 'UPDATE OR INSERT INTO NOTIFIEDCLIENTS'+    // �����
           ' (NOCLSHOWTIME, NOCLCLIENT, NOCLNOTE) VALUES (current_timestamp, '+
           sUser+', '+sNote+') MATCHING (NOCLCLIENT, NOCLNOTE)';
      else                                                       // ������������
        ORD_IBS.SQL.Text:= 'UPDATE NOTIFIEDCLIENTS set NOCLVIEWTIME=current_timestamp'+
                           ' where NOCLCLIENT='+sUser+' and NOCLNOTE='+sNote;
      end; // case
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrProcess);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//==================== �������� ����� ������ 3 � ������� �������� ������� � ����
function TDataCache.AddModelNodeWareUseListLinks(pModelID, pNodeID, pWareID,
         UserID, srcID: Integer; var UseList: TStringList; var pPart: Integer): String;
const nmProc = 'AddModelNodeWareUseListLinks';
// �������� ������������� 3-� ������ � ���������� ������ - �� ������ ������� !!!
// UseList - ������ ����� <��������>cStrValueDelim<��������>, � Object - <��� TecDoc ��������>
// ��� ������� �� Excel <��� TecDoc ��������> = 0
// pPart �� ������ - ����� ������ (����� ��� ����� � ����-��������)
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    criTD, iUseList, i: Integer;
    UseName, UseValue, s: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try // ����� ������� ��������
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if not Assigned(UseList) or (UseList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- ������ ������ �������');

    iUseList:= pPart;
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select partID, errLink from AddModelNodeWarePartUsageLink('+
        IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', :iUseList,'+
        ' :criTD, :CriName, :CriValue, '+IntToStr(UserID)+', '+IntToStr(srcID)+')';

      for i:= 0 to UseList.Count-1 do begin
        if not Assigned(UseList.Objects[i]) then criTD:= 0
        else criTD:= Integer(UseList.Objects[i]);
        UseName:= fnGetBefore(cStrValueDelim, UseList[i]);
        if UseName='' then begin
          UseName:= UseList[i];
          UseValue:= '';
        end else UseValue:= fnGetAfter(cStrValueDelim, UseList[i]);

        ORD_IBS.ParamByName('criTD').AsInteger:= criTD;
        ORD_IBS.ParamByName('CriName').AsString:= UseName;
        ORD_IBS.ParamByName('CriValue').AsString:= UseValue;
        ORD_IBS.ParamByName('iUseList').AsInteger:= iUseList; // ����� ������ (����� ���� <1)
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Eof and ORD_IBS.Bof) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else begin
          if ORD_IBS.FieldByName('errLink').AsInteger>0 then
            raise EBOBError.Create(MessText(mtkWareModNodeUse)+' � ���� ��������, ��� ��������');
          if (ORD_IBS.FieldByName('partID').AsInteger<1) then begin
            s:= 'error add use part: Model='+IntToStr(pModelID)+' Node='+IntToStr(pNodeID)+
                ' Ware='+IntToStr(pWareID)+' Cri='+UseName+' Value='+UseValue;
            raise Exception.Create(s);
          end;
          if iUseList<1 then iUseList:= ORD_IBS.FieldByName('partID').AsInteger;
        end;
        ORD_IBS.Close;
      end; // for

      ORD_IBS.Transaction.Commit;
      pPart:= iUseList; // ���������� ����� ������
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do if E.Message<>'duplicate' then begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//==================== ������� ����� ������ 3 � ������� �������� ������� �� ����
function TDataCache.DelModelNodeWareUseListLinks(pModelID, pNodeID, pWareID, iUseList: Integer): String;
const nmProc = 'DelModelNodeWareUseListLinks';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (iUseList<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������ ������ �������');

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWarePartUsageLinks('+IntToStr(pModelID)+
        ', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+IntToStr(iUseList)+')';
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrDelRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//==================== �������� ����� ������ 3 � ������� �������� ������� � ����
function TDataCache.ChangeModelNodeWareUsesPart(pModelID, pNodeID, pWareID,
         UserID, srcID: Integer; UseList: TStringList; var pPart: Integer): String;
const nmProc = 'ChangeModelNodeWareUsesPart';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    criTD, i: Integer;
    UseName, UseValue, s: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');

    if (pPart<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������ ������ �������');
    if not Assigned(UseList) or (UseList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- ������ ������ �������');

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWarePartUsageLinks('+IntToStr(pModelID)+
        ', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+IntToStr(pPart)+')';
      ORD_IBS.ExecQuery;
      ORD_IBS.Close;

      ORD_IBS.SQL.Text:= 'select partID, errLink from AddModelNodeWarePartUsageLink('+
        IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', :iUseList,'+
        ' :criTD, :CriName, :CriValue, '+IntToStr(UserID)+', '+IntToStr(srcID)+')';

      for i:= 0 to UseList.Count-1 do begin
        if not Assigned(UseList.Objects[i]) then criTD:= 0
        else criTD:= Integer(UseList.Objects[i]);
        UseName:= fnGetBefore(cStrValueDelim, UseList[i]);
        if UseName='' then begin
          UseName:= UseList[i];
          UseValue:= '';
        end else UseValue:= fnGetAfter(cStrValueDelim, UseList[i]);

        ORD_IBS.ParamByName('criTD').AsInteger:= criTD;
        ORD_IBS.ParamByName('CriName').AsString:= UseName;
        ORD_IBS.ParamByName('CriValue').AsString:= UseValue;
        ORD_IBS.ParamByName('iUseList').AsInteger:= pPart; // ����� ������
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Eof and ORD_IBS.Bof) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else begin
          if ORD_IBS.FieldByName('errLink').AsInteger>0 then
            raise EBOBError.Create(MessText(mtkWareModNodeUse)+' � ���� ��������, ��� ��������');
          if (ORD_IBS.FieldByName('partID').AsInteger<1) then begin
            s:= 'error add use part: Model='+IntToStr(pModelID)+' Node='+IntToStr(pNodeID)+
                ' Ware='+IntToStr(pWareID)+' Cri='+UseName+' Value='+UseValue;
            raise Exception.Create(s);
          end;
          if pPart<>ORD_IBS.FieldByName('partID').AsInteger then
            raise EBOBError.Create('������������ ������� ������');            // ???
        end;
        ORD_IBS.Close;
      end; // for

      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrEditRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//==================================== ����� ������ ������� ������ 3 (���������)
function TDataCache.GetModelNodeWareTextListNumber(pModelID, pNodeID, pWareID: Integer;
         TxtList: TStringList; nTxtList: Integer=0; ORD_IBSr: TIBSQL=nil): Integer;
const nmProc = 'GetModelNodeWareTextListNumber';
// ORD_IBSr ���������� ��� �������� �������� ��� ���������� �������� ���������
// TxtList - ������, � Object - <��� supTD ������>
// String - <IntToStr(��� ���� ������)>=<������������� TecDoc>+cSpecDelim+<�����>
// ��� ������� �� Excel <������������� TecDoc>='', <��� supTD ������>=0
// � Result - ����� ��������� ������, ����� -1
// ���� ����� nTxtList - ��������� ������ �������� ������
var ORD_IBD: TIBDatabase;
    flCreate, flNo: Boolean;
    supTD, iTxtList, i, j: Integer;
    TxtValue, TypeStr: String;
    ordTxts: TStringList;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  ORD_IBD:= nil;
  flCreate:= not assigned(ORD_IBSr);
  ordTxts:= TStringList.Create;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if not Assigned(TxtList) or (TxtList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- ������ ������ �������');
    try
      if flCreate then begin
        ORD_IBD:= cntsOrd.GetFreeCnt;
        ORD_IBSr:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBSr_'+nmProc);
      end else ORD_IBSr.Close;
                                                   // ������ � �����e 3 �� ORD
      with ORD_IBSr.Transaction do if not InTransaction then StartTransaction;
      if ORD_IBSr.SQL.Text='' then
        ORD_IBSr.SQL.Text:= 'select LWNMTPART, LWNMTinfotype, WITSUPTD, WITTMTD, ITTEXT'+
          ' from (select LWNMTPART, LWNMTWIT, LWNMTinfotype'+
          '   from (select ldmwcode from (select LDEMCODE from LINKDETAILMODEL'+
          '     where LDEMTRNACODE='+IntToStr(pNodeID)+' and LDEMDMOSCODE='+IntToStr(pModelID)+')'+ // and LDEMWRONG="F"
          '     inner join LINKDETMODWARE on LDMWLDEMCODE=LDEMCODE'+
          '       and LDMWWARECODE='+IntToStr(pWareID)+')'+                             // and LDMWWRONG="F"
          '   inner join LinkWareNodeModelText on LWNMTLDMW=ldmwcode)'+    // and LWNMTWRONG="F"
          ' left join WareInfoTexts on WITCODE=LWNMTWIT'+
          ' left join INFOTEXTS on ITCODE = WITTEXTCODE'+
          fnIfStr(nTxtList>0, ' where LWNMTPART='+IntToStr(nTxtList), ' order by LWNMTPART');
      ORD_IBSr.ExecQuery;
      while not ORD_IBSr.Eof do begin
        iTxtList:= ORD_IBSr.FieldByName('LWNMTPART').AsInteger; // 1 ������
        if ordTxts.Count>0 then ordTxts.Clear;
        ordTxts.Sorted:= False;
        while not ORD_IBSr.Eof and (iTxtList=ORD_IBSr.FieldByName('LWNMTPART').AsInteger) do begin
          supTD   := ORD_IBSr.FieldByName('WITSUPTD').AsInteger;
          TypeStr := ORD_IBSr.FieldByName('LWNMTinfotype').AsString;
          TxtValue:= ORD_IBSr.FieldByName('WITTMTD').AsString+cSpecDelim+
                     ORD_IBSr.FieldByName('ITTEXT').AsString;
          ordTxts.AddObject(TypeStr+cStrValueDelim+TxtValue, Pointer(supTD));
                   // <IntToStr(��� ���� ������)>=<������������� TecDoc>+cSpecDelim+<�����>
          TestCssStopException; // �������� ��������� �������
          ORD_IBSr.Next;
        end;
        if (ordTxts.Count<>TxtList.Count) then Continue; // �� ��������� ���-�� � ������

        ordTxts.Sort;
        ordTxts.Sorted:= True;
        flNo:= False;
        for i:= 0 to TxtList.Count-1 do begin
          flNo:= not ordTxts.Find(TxtList[i], j); // ���� ������ <��� ������>=<�������.>+cSpecDelim+<�����>
          if flNo then Break;
          supTD:= Integer(TxtList.Objects[i]); // ��������� ��� supTD
          flNo:= (supTD<>Integer(ordTxts.Objects[j]));
          if flNo then Break;
        end;
        if flNo then Continue; // �� ��������� ������ ������

        Result:= iTxtList; // ���� ������ ������� - ���������� ����� ������
        Break;
      end;
      ORD_IBSr.Close;
    finally
      if assigned(ORD_IBSr) then begin
        with ORD_IBSr.Transaction do if InTransaction then Rollback;
        ORD_IBSr.Close;
      end;
      if flCreate then begin
        prFreeIBSQL(ORD_IBSr);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;
      prFree(ordTxts);
    end;
  except
    on E: Exception do begin
      Result:= -1;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//===================================== ������ ������ ������� � ������� ������ 3
function TDataCache.FindModelNodeWareUseAndTextListNumbers(pModelID, pNodeID, pWareID: Integer;
         var UseLists: TASL; var TxtLists: TASL; var ListNumbers: Tai; var ErrUseNums: Tai;
         var ErrTxtNums: Tai; FromTDT: Boolean=False; CheckTexts: Boolean=False): String;
const nmProc = 'FindModelNodeWareUseAndTextListNumbers';
// FromTDT=True - ������ � ���������� �� TDT, CheckTexts - ����������� ��������� ������
// ListNumbers - ������ ������� ������ (������ �����. UseLists, TxtLists)
// ErrUseNums  - ������ ������� ������ �������, ���.���� �������
// ErrTxtNums  - ������ ������� ������ �������, ���.���� �������
// UseLists - ������ ������� ����� <��������>=<��������>, � Object - <��� TecDoc ��������>
//   ��� ������� �� Excel <��� TecDoc ��������>=0
// TxtLists - ������ ������� �������, � Object - <��� supTD ������>
//   String - <IntToStr(��� ���� ������)>=<������������� TecDoc>+cSpecDelim+<�����>
//   ��� ������� �� Excel <������������� TecDoc>='', <��� supTD ������>=0
// � Result - ��������� �� ������
// �� ������ � ��������� UseLists[i] - Delimiter=LCharGood, � ����������� - Delimiter=LCharUpdate
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    flErr, fl, flKod: Boolean;
    kodTD, TypeID, iUseList, ij, iAr, iTxtList: Integer;
    s, UseName, UseValue, TxtValue, TypeStr, TxtTM: String;
    ArOrdUses: TarCriInfo;
    ArOrdTexts: TarTextInfo;
  //---------------------------------------------------- �������� ������ �������
  function CheckUseList(index: Integer; var ArOrdUses: TarCriInfo): Boolean;
  var i, ii, j: Integer;
  begin
    j:= -1;
    with UseLists[index] do for i:= 0 to Count-1 do try  // ������� ������ � ArOrdUses
      j:= -1; // ������� ������ �������� ������ � ������ �� ����� ����
      if Assigned(Objects[i]) then kodTD:= Integer(Objects[i]) else kodTD:= 0; // ��� �������� TD
      UseValue:= fnGetAfter(cStrValueDelim, Strings[i]);
      flKod:= (kodTD>0);
      if flKod then UseName:= ''  // ���� ���� ��� - ����� ������ ��������
      else begin
        UseName:= fnGetBefore(cStrValueDelim, Strings[i]);
        if UseName='' then UseName:= Strings[i];
      end;
      if (UseValue<>'') then UseValue:= AnsiUpperCase(UseValue);
      if (UseName<>'') then UseName:= AnsiUpperCase(UseName);
      for ii:= 0 to iAr-1 do begin
        if flKod then fl:= (kodTD=ArOrdUses[ii].CRITD) // ���� ���� ��� - ��������� ��� � ��������
        else fl:= (UseName=ArOrdUses[ii].CriNameUp);   // ����� ��������� ������������ � ��������
        if fl and (UseValue=ArOrdUses[ii].ValueUp) then begin
          j:= ii;
          Break;
        end;
      end; // for ii:= 0 to iAr-1
      if (j<0) then Break;  // ���� ������ �� �������
    except end; // with UseLists[index] do for i:= 0 to Count-1
    Result:= (j>-1);
  end;
  //---------------------------------------------------- �������� ������ �������
  function CheckTxtList(index: Integer; var ArOrdTexts: TarTextInfo): Boolean;
  var i, ii, j: Integer;
  begin
    j:= -1;
    with TxtLists[index] do for i:= 0 to Count-1 do try  // ���� ����� �� ������ � ArOrdTexts
      j:= -1; // ������ �������� TxtLists[index] � ������ �� ����� ����
      if Assigned(Objects[i]) then kodTD:= Integer(Objects[i]) else kodTD:= 0; // ��� supTD
      // <IntToStr(��� ���� ������)>=<������������� TecDoc>+cSpecDelim+<�����>
      TypeStr:= fnGetBefore(cStrValueDelim, Strings[i]);
      TypeID:= StrToIntDef(TypeStr, 0);
      s:= fnGetAfter(cStrValueDelim, Strings[i]);
      TxtTM:= fnGetBefore(cSpecDelim, s);
      flKod:= (kodTD>0) and (TxtTM<>'');  // ���� ���� supTD � ������������� � CheckTexts=False - ����� �� �����
      if flKod and not CheckTexts then TxtValue:= ''
      else TxtValue:= AnsiUpperCase(StringReplace(fnGetAfter(cSpecDelim, s), ' ', '', [rfReplaceAll]));

      for ii:= 0 to iAr-1 do begin
        if (TypeID<>ArOrdTexts[ii].infotype) then Continue; // ���� ��� �� ���
        fl:= False;
        if flKod then          // ���� ���� supTD � ������������� - ��������� ��
          fl:= (kodTD=ArOrdTexts[ii].supTD) and (TxtTM=ArOrdTexts[ii].tmTD);
        if not fl or CheckTexts then fl:= (TxtValue=ArOrdTexts[ii].search); // ��������� ��������� �����
        if fl then begin
          j:= ii;
          Break;
        end;
      end; // for ii:= 0 to iAr-1
      if (j<0) then Break;  // ���� ������ �� �������
    except end; // with TxtLists[index] do for i:= 0 to Count-1
    Result:= (j>-1);
  end;
  //--------------------------------------------------
begin
  Result:= '';
  if not Assigned(self) then Exit;
  SetLength(ErrUseNums, 0);
  SetLength(ErrTxtNums, 0);
  ORD_IBS:= nil;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if (Length(UseLists)<1) and (Length(TxtLists)<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- ������ ����� �������');
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try                                    // ���������� ��������
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBSr_'+nmProc);
      if not Assigned(ORD_IBS) then raise EBOBError.Create(MessText(mtkErrConnectToDB));
      for ij:= 0 to High(UseLists) do UseLists[ij].Delimiter:= LCharUpdate;
      for ij:= 0 to High(TxtLists) do TxtLists[ij].Delimiter:= LCharUpdate;
      for ij:= 0 to High(ListNumbers) do ListNumbers[ij]:= 0;
      //----------------------------------- ��� ������ ������� � �����e 3 �� ORD
      SetLength(ArOrdUses, 10);
      with ORD_IBS.Transaction do if not InTransaction then StartTransaction;
      ORD_IBS.SQL.Text:= 'select LWMNUPART, WCRITDCODE, WCRIDESCRUP, WCVSVALUEUP'+
        ' from (select LWMNUPART, LWMNUWCVSCODE'+
        '   from (select ldmwcode from (select LDEMCODE from LINKDETAILMODEL'+
        '     where LDEMTRNACODE=:pNodeID and LDEMDMOSCODE=:pModelID)'+   // and LDEMWRONG="F"
        '     inner join LINKDETMODWARE on LDMWLDEMCODE=LDEMCODE and LDMWWARECODE=:pWareID)'+ // and LDMWWRONG="F"
        '   inner join LinkWareModelNodeUsage on LWMNULDMWCODE=ldmwcode'+ // and LWMNUWRONG="F"
        fnIfStr(FromTDT, ' and LWMNUSRCLECODE in ('+IntToStr(soTecDocBatch)+', '+
        IntToStr(soTDparts)+', '+IntToStr(soTDsupersed)+')', '')+
        ') left join WARECRIVALUES on WCVSCODE=LWMNUWCVSCODE'+
        ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE order by LWMNUPART';
      ORD_IBS.ParamByName('pModelID').AsInteger:= pModelID;
      ORD_IBS.ParamByName('pNodeID').AsInteger:= pNodeID;
      ORD_IBS.ParamByName('pWareID').AsInteger:= pWareID;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iUseList:= ORD_IBS.FieldByName('LWMNUPART').AsInteger; // ����� ������
        iAr:= 0; // ������� ������� � ArOrdUses
        while not ORD_IBS.Eof and (iUseList=ORD_IBS.FieldByName('LWMNUPART').AsInteger) do begin
          if High(ArOrdUses)<iAr then SetLength(ArOrdUses, iAr+10);
          ArOrdUses[iAr].CriNameUp:= ORD_IBS.FieldByName('WCRIDESCRUP').AsString;
          ArOrdUses[iAr].ValueUp  := ORD_IBS.FieldByName('WCVSVALUEUP').AsString;
          ArOrdUses[iAr].CRITD    := ORD_IBS.FieldByName('WCRITDCODE').AsInteger;
          inc(iAr);
          TestCssStopException; // �������� ��������� �������
          ORD_IBS.Next;
        end;

        flErr:= True;
        for ij:= 0 to High(UseLists) do begin
          if (iAr<>UseLists[ij].Count) then Continue; // �� ��������� ���-�� � ������
          if (ListNumbers[ij]>0) then Continue;       // ������ ��� ����������
          if CheckUseList(ij, ArOrdUses) then begin // ���� �����
            ListNumbers[ij]:= iUseList; // ���������� ����� ������
            UseLists[ij].Delimiter:= LCharGood; // ������� ��������� ������
            flErr:= False;
            Break;
          end;
        end; // for ij:= 0 to High(UseLists)

        if flErr and (fnInIntArray(iUseList, ErrUseNums)<0) then begin // ���� �� �����
          ij:= Length(ErrUseNums);
          SetLength(ErrUseNums, ij+1);
          ErrUseNums[ij]:= iUseList;
        end;
      end; // while not ORD_IBSr.Eof
      ORD_IBS.Close;

      //----------------------------------------------- ������ � �����e 3 �� ORD
      SetLength(ArOrdTexts, 10);
      with ORD_IBS.Transaction do if not InTransaction then StartTransaction;
      ORD_IBS.SQL.Text:= 'select LWNMTPART, LWNMTinfotype, WITSUPTD, WITTMTD, ITTEXT, ITSEARCH'+
        ' from (select LWNMTPART, LWNMTWIT, LWNMTinfotype'+
        '   from (select ldmwcode from (select LDEMCODE from LINKDETAILMODEL'+
        '     where LDEMTRNACODE=:pNodeID and LDEMDMOSCODE=:pModelID)'+ // and LDEMWRONG="F"
        '     inner join LINKDETMODWARE on LDMWLDEMCODE=LDEMCODE and LDMWWARECODE=:pWareID)'+ // and LDMWWRONG="F"
        '   inner join LinkWareNodeModelText on LWNMTLDMW=ldmwcode'+    // and LWNMTWRONG="F"
        fnIfStr(FromTDT, ' and LWNMTSRCLECODE in ('+IntToStr(soTecDocBatch)+', '+
        IntToStr(soTDparts)+', '+IntToStr(soTDsupersed)+')', '')+
        ') left join WareInfoTexts on WITCODE=LWNMTWIT'+
        ' left join INFOTEXTS on ITCODE=WITTEXTCODE order by LWNMTPART';
      ORD_IBS.ParamByName('pModelID').AsInteger:= pModelID;
      ORD_IBS.ParamByName('pNodeID').AsInteger:= pNodeID;
      ORD_IBS.ParamByName('pWareID').AsInteger:= pWareID;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iTxtList:= ORD_IBS.FieldByName('LWNMTPART').AsInteger; // ����� ������ �������

        if (fnInIntArray(iTxtList, ErrUseNums)>-1) then begin // ���� �����.������ ������� �������� �� ��������
          if (fnInIntArray(iTxtList, ErrTxtNums)<0) then begin
            ij:= Length(ErrTxtNums);
            SetLength(ErrTxtNums, ij+1);
            ErrTxtNums[ij]:= iTxtList;
          end;                                                // ������������
          TestCssStopException;
          while not ORD_IBS.Eof and (iTxtList=ORD_IBS.FieldByName('LWNMTPART').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        iAr:= 0; // ������� ������� � ArOrdTexts
        while not ORD_IBS.Eof and (iTxtList=ORD_IBS.FieldByName('LWNMTPART').AsInteger) do begin
          if High(ArOrdTexts)<iAr then SetLength(ArOrdTexts, iAr+10);
          ArOrdTexts[iAr].supTD   := ORD_IBS.FieldByName('WITSUPTD').AsInteger;
          ArOrdTexts[iAr].infotype:= ORD_IBS.FieldByName('LWNMTinfotype').AsInteger;
          ArOrdTexts[iAr].tmTD    := ORD_IBS.FieldByName('WITTMTD').AsString;
          ArOrdTexts[iAr].text    := ORD_IBS.FieldByName('ITTEXT').AsString;
          ArOrdTexts[iAr].search  := ORD_IBS.FieldByName('ITSEARCH').AsString;
          inc(iAr);
          TestCssStopException; // �������� ��������� �������
          ORD_IBS.Next;
        end;
        ij:= fnInIntArray(iTxtList, ListNumbers); // ���� ������ ������ � ��������� ������� �������

        flErr:= True;
        if (ij<0) then begin // ���� ������ <0 (�� ������� �������) - ���� ������ ������ � �������
          for ij:= 0 to High(TxtLists) do begin
            if (ListNumbers[ij]>0) then Continue;       // ��� ������� ������ ������� ��� �������
            if (UseLists[ij].Count>0) then Continue;    // ���� �������
            if (TxtLists[ij].Count<1) then Continue;    // ��� �������
            if (iAr<>TxtLists[ij].Count) then Continue; // �� ��������� ���-�� � ������
            if CheckTxtList(ij, ArOrdTexts) then begin
              ListNumbers[ij]:= iTxtList;
              TxtLists[ij].Delimiter:= LCharGood;       // ������� ��������� ������
              flErr:= False;
              Break;
            end;
          end; // for ij:= 0 to High(TxtLists)

        end else if (TxtLists[ij].Count>0) and (iAr=TxtLists[ij].Count)
          and CheckTxtList(ij, ArOrdTexts) then begin
          TxtLists[ij].Delimiter:= LCharGood; // ���� ��� ������� - ������� ��������� ������
          flErr:= False;
        end;

        if flErr and (fnInIntArray(iTxtList, ErrTxtNums)<0) then begin // ���� �� �����
          ij:= Length(ErrTxtNums);
          SetLength(ErrTxtNums, ij+1);
          ErrTxtNums[ij]:= iTxtList;
        end; // if flErr
      end; // while not ORD_IBSr.Eof
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
      SetLength(ArOrdUses, 0);
      SetLength(ArOrdTexts, 0);
    end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= '������ ������ ������� � �������';
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//========================== �������� / ������� ����� ������ 3 � ������� �������
function TDataCache.CheckModelNodeWareTextListLinks(var ResCode: Integer;
         pModelID, pNodeID, pWareID: Integer; TxtList: TStringList;
         UserID: Integer=0; srcID: Integer=0; PartID: Integer=0): String;
const nmProc = 'CheckModelNodeWareTextListLinks';
// TxtList - ������, � Object - <��� supTD ������>
// String - <IntToStr(��� ���� ������)>+cSpecDelim+<�������� ����>=<������������� TecDoc>+cSpecDelim+<�����>
// ���� �����  <IntToStr(��� ���� ������)> - <�������� ����> ����� ���� ''
// ��� ������� �� Excel <������������� TecDoc>='', <��� supTD ������>=0
// srcID, userID ����� ������ ��� ����������
// ResCode �� ����� - ��� �������� (resAdded, resDeleted)
// ResCode �� ������ - ���������: resError - ������, resDoNothing - �� ��������,
// resAdded - ������ ������� ���������, resDeleted - ������ ������� �������
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    OpCode, SysID, i, pSupID: Integer;
    s, TextValue, tmTD, TypeStr: String;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
//-------------------------------------------------------------------- ���������
    if not (OpCode in [resAdded, resDeleted]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if (OpCode=resAdded) then begin
      if ((userID<1) or (srcID<1)) then  // ���� ����������
        raise EBOBError.Create(MessText(mtkNotParams));
      if not Assigned(TxtList) or (TxtList.Count<1) then
        raise EBOBError.Create(MessText(mtkNotValidParam)+'- ������ ������ �������');
    end;
    if (OpCode=resDeleted) and (PartID<1) then  // ���� ��������
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������ ������ �������');

    if not WareExist(pWareID) or GetWare(pWareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if not FDCA.Models.ModelExists(pModelID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    SysID:= FDCA.Models[pModelID].TypeSys;
    if not FDCA.AutoTreeNodesSys[SysID].NodeExists(pNodeID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ����');

//--------------------------------------------------- ������������ ������ � ����
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);

      if OpCode=resAdded then begin // ���������
        ORD_IBS.SQL.Text:= 'select PartID, errLink from AddModelNodeWarePartTextLink_n('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+
          ', :PartID, :TypeID, :pSupID, :tmTD, :pText, '+IntToStr(UserID)+', '+IntToStr(srcID)+')';

        for i:= 0 to TxtList.Count-1 do begin
          if not Assigned(TxtList.Objects[i]) then pSupID:= 0
          else pSupID:= Integer(TxtList.Objects[i]);
          TypeStr:= fnGetBefore(cStrValueDelim, TxtList[i]);  // ��� ���� ������ ����������
          s:= fnGetAfter(cStrValueDelim, TxtList[i]);         // ����� TxtList[i] � �������
          tmTD:= fnGetBefore(cSpecDelim, s);                  // ������������� TecDoc
          TextValue:= fnGetAfter(cSpecDelim, s);              // �����
          ORD_IBS.ParamByName('TypeID').AsString:= TypeStr;
          ORD_IBS.ParamByName('PartID').AsInteger:= PartID;
          ORD_IBS.ParamByName('tmTD').AsString:= tmTD;
          ORD_IBS.ParamByName('pText').AsString:= TextValue;
          ORD_IBS.ParamByName('pSupID').AsInteger:= pSupID;
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Eof and ORD_IBS.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ORD_IBS.Fields[1].AsInteger>0) then
            raise EBOBError.Create(MessText(mtkWareModNodeText)+' � ���� ��������, ��� ��������')
          else begin
  //          if (ORD_IBS.Fields[1].AsInteger<0) or (ORD_IBS.Fields[0].AsInteger<1) then begin
            if (ORD_IBS.Fields[0].AsInteger<1) then begin
              s:= 'Model='+IntToStr(pModelID)+' Node='+IntToStr(pNodeID)+
                  ' Ware='+IntToStr(pWareID)+' TypeID='+TypeStr+' Text='+TextValue;
  //            if (ORD_IBS.Fields[1].AsInteger<0) then s:= 'duplicate' else
              s:= 'error add use link: '+s;
              raise Exception.Create(s);
            end;
            if PartID<1 then PartID:= ORD_IBS.Fields[0].AsInteger;
          end;
          ORD_IBS.Close;
        end; // for i:= 0 to TxtList.Count-1
        Result:= MessText(mtkWareModNodeTexts)+' ��������';

      end else begin // ������� �� ����
        ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWarePartTextLinks('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+IntToStr(PartID)+')';
        ORD_IBS.ExecQuery;
        Result:= MessText(mtkWareModNodeTexts)+' ������';
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do if E.Message<>'duplicate' then begin
      if OpCode=resAdded then Result:= MessText(mtkErrAddRecord)
      else Result:= MessText(mtkErrDelRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//==== �������� / ������� ���� ������ 3 � ������� (������ 1 - �������� �� Excel)
function TDataCache.CheckModelNodeWareTextLink(var ResCode: Integer;
         pModelID, pNodeID, pWareID: Integer; TextValue: String; TypeID: Integer=0;
         TypeName: String=''; UserID: Integer=0; srcID: Integer=0): String;
// srcID, userID ����� ������ ��� ����������, ���� ����� TypeID - TypeName ������������ !!!
const nmProc = 'CheckModelNodeWareTextLink';
// ResCode �� ����� - ��� �������� (resAdded, resDeleted)
// ResCode �� ������ - ���������: resError - ������, resDoNothing - �� ��������, 
// resAdded - ������ ���������, resDeleted - ������ �������
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    OpCode, SysID, i: Integer;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
//-------------------------------------------------------------------- ���������
    if not (OpCode in [resAdded, resDeleted]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if (TextValue='') then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if ((TypeID<1) and (TypeName='')) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ���� ������');
    if not WareExist(pWareID) or GetWare(pWareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if not FDCA.Models.ModelExists(pModelID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    SysID:= FDCA.Models[pModelID].TypeSys;
    if not FDCA.AutoTreeNodesSys[SysID].NodeExists(pNodeID) then
      raise EBOBError.Create(MessText(mtkNotEnoughParams));

    if (OpCode=resAdded) and ((userID<1) or (srcID<1)) then  // ���� ����������
      raise EBOBError.Create(MessText(mtkNotParams));

    with FDCA.TypesInfoModel do if not ItemExists(TypeID) then begin // ���� ��� ������
      i:= InfoModelList[11].IndexOf(TypeName);
      if i<0 then raise EBOBError.Create('�� ������ ��� ������');
      TypeID:= Integer(InfoModelList[11].Objects[i]);
    end;

//--------------------------------------------------- ������������ ������ � ����
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      if OpCode=resAdded then begin // ���������
        ORD_IBS.SQL.Text:= 'select linkID, errLink from AddModelNodeWareTextLink_new('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+
          IntToStr(TypeID)+', 0, "", :pText, '+IntToStr(UserID)+', '+IntToStr(srcID)+')';
        ORD_IBS.ParamByName('pText').AsString:= TextValue;
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Eof and ORD_IBS.Bof) or (ORD_IBS.Fields[0].AsInteger<1) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else if (ORD_IBS.Fields[1].AsInteger>0) then
          raise EBOBError.Create(MessText(mtkWareModNodeText)+' � ���� ��������, ��� ��������')
        else if (ORD_IBS.Fields[1].AsInteger<0) then begin
          ResCode:= resDoNothing;
          raise EBOBError.Create(MessText(mtkWareModNodeText)+' ����')
        end else Result:= MessText(mtkWareModNodeText)+' ���������';

      end else begin // ������� �� ����
        ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWareTextLink_new('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+
          IntToStr(TypeID)+', 0, 0, "", :pText)';
        ORD_IBS.ParamByName('pText').AsString:= TextValue;
        ORD_IBS.ExecQuery;
        Result:= MessText(mtkWareModNodeText)+' �������';
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//=================================== ����� ��� �������� ������ �� ����� � SupID
function TDataCache.SearchWareFileBySupAndName(pSup: Integer; pFileName: String): Integer;
var i: Integer;
    wf: TWareFile;
begin
  Result:= 0;
  with FWareFiles do for i:= 0 to ItemsList.Count-1 do begin
    wf:= ItemsList[i];
    if (wf.supID=pSup) and (wf.FileName=pFileName) then begin
      Result:= wf.ID;
      exit;
    end;
  end;
end;
//=================================================== �������� ���� � ���� � ���
function TDataCache.AddWareFile(var fID: Integer; pFname: String;
         pSup, pHeadID, pUserID, pSrcID: Integer): String;
const nmProc = 'AddWareFile';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    p: Pointer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  fID:= 0;
  with FWareFiles do try
    if (pFname='') or (pUserID<1) then raise EBOBError.Create(MessText(mtkNotEnoughParams));
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'insert into WareGraFiles'+
        ' (WGFSupTD, WGFHeadID, WGFFileName, '+fnIfStr(pSrcID>0, 'WGFSRCLECODE, ', '')+
        'WGFUSERID) values ('+IntToStr(pSup)+', '+IntToStr(pHeadID)+', :Fname, '+
        fnIfStr(pSrcID>0, IntToStr(pSrcID)+', ', '')+IntToStr(pUserID)+') returning WGFCODE';
      ORD_IBS.ParamByName('Fname').AsString:= pFname;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Eof and ORD_IBS.Bof) then fID:= ORD_IBS.Fields[0].AsInteger;
      if fID<1 then raise Exception.Create(MessText(mtkErrAddRecord));
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    p:= TWareFile.Create(fID, pSup, pHeadID, pFname, pSrcID);
    CheckItem(p);
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrAddRecord);
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//=============================================== �������� �������������� ������
function TDataCache.CheckWareFiles(var delCount: Integer): String;
const nmProc = 'CheckWareFiles';
// ������ ���������� � AddLoadWaresInfoFromTDT ����� ��������� ��������
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    fID: Integer;
begin
  Result:= '';
  delCount:= 0;
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'select delCode from CheckGraFiles';
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        fID:= ORD_IBS.Fields[0].AsInteger;
        FWareFiles.DeleteItem(fID);
        inc(delCount);
        TestCssStopException;
        ORD_IBS.Next;
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
  except
    on E: Exception do begin
      delCount:= 0;
      Result:= nmProc+': '+E.Message;
    end;
  end;
end;
//=============== ��������/������� ���� ������ � ������ (toCache=True - � � ����)
function TDataCache.CheckWareFileLink(var ResCode: Integer; pFileID, pWareID: Integer;
         pSrcID: Integer=0; UserID: Integer=0; toCache: Boolean=True; linkURL: Boolean=True): String;
const nmProc = 'CheckWareFileLink';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    p: Pointer;
    OpCode: Integer;
    Ware: TWareInfo;
    s: String;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;

  with FWareFiles do try
    if not (OpCode in [resAdded, resDeleted]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if not WareExist(pWareID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if not FWareFiles.ItemExists(pFileID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����');

    Ware:= GetWare(pWareID);
    if Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');

    case OpCode of
    resAdded: begin
        if Ware.FileLinks.LinkExists(pFileID) then begin
          ResCode:= resDoNothing;
          raise EBOBError.Create('����� ������ ������ � ������ ��� ����');
        end;
        if (UserID<1) or (pSrcID<1) then
          raise EBOBError.Create(MessText(mtkNotEnoughParams));
      end;
    resDeleted: begin
        if not Ware.FileLinks.LinkExists(pFileID) then begin
          ResCode:= resDoNothing;
          raise EBOBError.Create('�� ������� ������ ������ � ������');
        end;
        if (pSrcID>0) and (GetLinkSrc(Ware.FileLinks[pFileID])<>pSrcID) then
          raise EBOBError.Create('�� ��������� ��������');
      end;
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt;                 // ����� � ����
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      case OpCode of
      resAdded: begin
          ORD_IBS.ParamCheck:= False;
          s:= 'from LinkWareGraFiles where LWGFWareID='+IntToStr(pWareID)+
              ' and LWGFWGFCODE='+IntToStr(pFileID);
          ORD_IBS.SQL.Add('execute block returns(flag integer) as begin flag=0;');
          ORD_IBS.SQL.Add('if (exists(select * '+s+')) then');
          ORD_IBS.SQL.Add(' select iif(LWGFWRONG="T", -1, 0) '+s+' into :flag;');
          ORD_IBS.SQL.Add('else insert into LinkWareGraFiles');
          ORD_IBS.SQL.Add(' (LWGFWareID, LWGFWGFCODE, LWGFUSERID, LWGFSRCLECODE');
          ORD_IBS.SQL.Add(fnIfStr(linkURL, '', ', LWGFLinkURL')+') values (');
          ORD_IBS.SQL.Add(IntToStr(pWareID)+', '+IntToStr(pFileID)+', '+IntToStr(UserID)+', ');
          ORD_IBS.SQL.Add(IntToStr(pSrcID)+fnIfStr(linkURL, '', ', "F"')+')');
          ORD_IBS.SQL.Add(' returning LWGFCODE into :flag; suspend; end');
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Eof and ORD_IBS.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ORD_IBS.Fields[0].AsInteger<0) then
            raise EBOBError.Create('������ ������ � ������ ��������, ��� ���������')
//          else if (ORD_IBS.Fields[0].AsInteger<1) then
//            raise Exception.Create('������ ������ � ������ ��� ����')
          ;
        end;
      resDeleted: begin
          ORD_IBS.SQL.Text:= 'delete from LinkWareGraFiles'+
            ' where LWGFWareID='+IntToStr(pWareID)+' and LWGFWGFCODE='+IntToStr(pFileID);
          ORD_IBS.ExecQuery;
        end;
      end; // case
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    if toCache then with Ware.FileLinks do begin // ��������� � ��� / ������� �� ���� ���� ������ � ������
      case OpCode of
      resAdded: begin
          p:= FWareFiles[pFileID];
          AddLinkItem(TFlagLink.Create(pSrcID, p, linkURL));
        end;
      resDeleted: DeleteLinkItem(pFileID);
      end; // case
    end; // if toCache

    case OpCode of
    resAdded  : Result:= '������ ������ � ������ ���������';
    resDeleted: Result:= '������ ������ � ������ �������';
    end; // case
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      Result:= MessText(mtkErrProcess);
      prMessageLOGS(nmProc+': '+E.Message, 'import');
    end;
  end;
end;
//================ ��������/������� ���� ������ � �����.������� (Excel, �������)
function TDataCache.CheckWareSatelliteLink(pWareID, pSatelID: Integer;
         var ResCode: Integer; srcID: Integer=0; UserID: Integer=0): String;
const nmProc = 'CheckWareSatelliteLink';
// ResCode �� ����� - ��� �������� (resAdded, resDeleted, resWrong, resNotWrong)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������, resAdded - ���������,
// resDeleted - �������, resWrong - ��������, ��� ��������, resNotWrong - �������������
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    Ware, Satel: TWareInfo;
    OpCode: Integer;
    mess: string;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBS:= nil;
  try
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then // ��������� ��� ��������
      raise Exception.Create(MessText(mtkNotValidParam)+' ��������');

    Ware:= GetWare(pWareID, True);
    if (Ware=NoWare) or Ware.IsArchive then                   // ��������� �����
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));
    if Ware.IsINFOgr then                   // ��������� �����
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ����-�����');

    Satel:= GetWare(pSatelID, True);
    if (Satel=NoWare) or Satel.IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����.������');
    if Satel.IsINFOgr then                   // ��������� �����
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - �����.����-�����');

    if not CheckWaresEqualSys(pWareID, pSatelID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ������ ������-�����������');

    if Ware.SatelLinks.LinkExists(pSatelID) then begin // �������� ������������� �����.������
      mess:= '';
      case OpCode of
        resAdded   : mess:= '����� '+MessText(mtkWareSatelLink)+' ����';
        resNotWrong: mess:= MessText(mtkWareSatelLink)+' �� ��������, ��� ���������';
      end; // case
      if mess<>'' then begin
        ResCode:= resDoNothing;
        raise Exception.Create(mess);
      end;
    end else if (OpCode in [resDeleted, resWrong]) then begin
      ResCode:= resDoNothing;
      raise Exception.Create('�� ������� '+MessText(mtkWareSatelLink));
    end;
                       // �������� ����������� ���������� � ����������� ��������
    if (OpCode in [resAdded, resNotWrong, resWrong]) and (userID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' �����')
    else if (OpCode in [resAdded]) and (srcID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' ���������');

//--------------------------------------------------- ������������ ������ � ����
    ORD_IBD:= cntsOrd.GetFreeCnt;                 // ����� � ����
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);

      case OpCode of
      resAdded: begin                // ���������
          ORD_IBS.SQL.Text:= 'select linkID, errLink from AddWareSatellite('+
            IntToStr(pWareID)+', '+IntToStr(pSatelID)+', '+IntToStr(UserID)+', '+IntToStr(srcID)+')';
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Eof and ORD_IBS.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ORD_IBS.Fields[1].AsInteger>0) then
            raise EBOBError.Create(MessText(mtkWareSatelLink)+' � ���� ��������, ��� ��������')
          else if (ORD_IBS.Fields[1].AsInteger<0) then begin
            with Ware do if not SatelLinks.LinkExists(pSatelID) then begin // �� ����.������
              SatelLinks.CheckLink(pSatelID, srcID, Satel);
              SatelLinks.SortByLinkName;
            end;
            ResCode:= resDoNothing;
            raise EBOBError.Create('����� '+MessText(mtkWareSatelLink)+' ����');
          end else if (ORD_IBS.Fields[0].AsInteger<1) then
            raise Exception.Create('error add link Ware='+IntToStr(pWareID)+
                                   ' satellite='+IntToStr(pSatelID));
        end; // resAdded

      resWrong, resNotWrong: begin // ������ ������� Wrong
          ORD_IBS.SQL.Text:= 'update LinkWareSatellites set LWSWRONG="'+
            fnIfStr(OpCode=resWrong, 'T', 'F')+'", LWSUSERID='+IntToStr(UserID)+
            ' where LWSWARECODE='+IntToStr(pWareID)+' and LWSSatel='+IntToStr(pSatelID);
          ORD_IBS.ExecQuery;
        end; // resWrong, resNotWrong

      resDeleted: begin              // �������
          ORD_IBS.SQL.Text:= 'delete from LinkWareSatellites where LWSWARECODE='+
            IntToStr(pWareID)+' and LWSSatel='+IntToStr(pSatelID);
          ORD_IBS.ExecQuery;
        end; // resDeleted
      end; // case
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

//------------------------------------------------------------- ������������ ���
    with Ware do case OpCode of
      resAdded, resNotWrong: begin                         // ���������
          SatelLinks.CheckLink(pSatelID, srcID, Satel);
          SatelLinks.SortByLinkName;
        end;
      resDeleted, resWrong: SatelLinks.DeleteLinkItem(pSatelID); // �������
    end; // case

    mess:= MessText(mtkWareAnalogLink);
    case OpCode of
      resAdded:    Result:= mess+' ���������';
      resDeleted:  Result:= mess+' �������';
      resWrong:    Result:= mess+' ��������, ��� ��������';
      resNotWrong: Result:= mess+' �������������';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;

//******************************************************************************
//                               TClients
//******************************************************************************
constructor TClients.Create;
begin
  SetLength(FarClientInfo, 0);
//  SetLength(FarClientInfo, 1);
//  FarClientInfo[0]:= TClientInfo.Create(0, '�����.������');
//  FarClientInfo[0].Arhived:= True;
  FcalcStart:= 0;
  FcalcDelta:= 0;
  CS_clients:= TCriticalSection.Create;
  FWorkLogins:= fnCreateStringList(True, 100);
end;
//=========================================
destructor TClients.Destroy;
var j: Integer;
begin
  for j:= Low(FarClientInfo) to High(FarClientInfo) do
    try prFree(FarClientInfo[j]); except end;
  SetLength(FarClientInfo, 0);
  prFree(CS_clients);
  prFree(FWorkLogins);
  inherited;
end;
//=========================================
function TClients.GetClient(pID: integer): TClientInfo;
var i: Integer;
begin
  i:= GetIndex(pID);
  if (i<Low(FarClientInfo)) or (i>High(FarClientInfo)) then Result:= nil // FarClientInfo[0]
  else Result:= FarClientInfo[i];
end;
//=========================================
procedure TClients.TestMaxCode(MaxCode: Integer);
var i, ii, jj: Integer;
begin
  i:= GetIndex(MaxCode);
  if Length(FarClientInfo)>i then exit;
  try // ���� ���� ������ �����
    CS_clients.Enter;
    jj:= Length(FarClientInfo);        // ��������� ����� �������
    SetLength(FarClientInfo, i+100);   // � ���������� ��������
    for ii:= jj to High(FarClientInfo) do FarClientInfo[ii]:= nil;
  finally
    CS_clients.Leave;
  end;
end;
//=========================================
procedure TClients.AddClient(pID: integer);
var i: Integer;
begin
  TestMaxCode(pID);
  i:= GetIndex(pID);
  FarClientInfo[i]:= TClientInfo.Create(pID, '');
end;
//=========================================
procedure TClients.CutEmptyCode;
var i, j: Integer;
//    Client: TClientInfo;
begin
  j:= Length(FarClientInfo);
  for i:= High(FarClientInfo) downto 1 do begin
//    Client:= FarClientInfo[i];
    if Assigned(FarClientInfo[i]) then begin
      j:= i+1;
      break;
    end;
  end;
  if Length(FarClientInfo)>j then try
    CS_clients.Enter;
    SetLength(FarClientInfo, j); // �������� �� ���.����
  finally
    CS_clients.Leave;
  end;
end;
//=========================================
function TClients.GetMaxIndex: integer;
begin
  Result:= High(FarClientInfo);
end;
//=========================================
function TClients.ClientExists(pID: Integer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then exit;
  i:= GetIndex(pID);
  Result:= (i>0) and (length(FarClientInfo)>i) and Assigned(FarClientInfo[i]);
end;
//=========================================
procedure TClients.SetCalcBounds(iStart, iEnd: integer);
begin
  FcalcStart:= iStart+1;
  FcalcDelta:= iEnd-iStart-5;
end;
//=========================================
function TClients.GetIndex(pID: integer): integer;
begin
  if (FcalcStart<1) or (pID<FcalcStart) then Result:= pID else Result:= pID-FcalcDelta;
end;

//******************************************************************************
//                               TFirms
//******************************************************************************
constructor TFirms.Create;
begin
  SetLength(FarFirmInfo, 0);
//  SetLength(FarFirmInfo, 1);
//  FarFirmInfo[0]:= TFirmInfo.Create(0, '�����.������');
//  FarFirmInfo[0].Arhived:= True;
  CS_firms:= TCriticalSection.Create;
end;
//=========================================
destructor TFirms.Destroy;
var j: Integer;
begin
  for j:= Low(FarFirmInfo) to High(FarFirmInfo) do
    try prFree(FarFirmInfo[j]); except end;
  SetLength(FarFirmInfo, 0);
  prFree(CS_firms);
  inherited;
end;
//=========================================
function TFirms.GetFirm(pID: integer): TFirmInfo;
begin
  if (pID<Low(FarFirmInfo)) or (pID>High(FarFirmInfo)) then Result:= nil // FarFirmInfo[0]
  else Result:= FarFirmInfo[pID];
end;
//=========================================
procedure TFirms.AddFirm(pID: integer);
var ii, jj: Integer;
begin
  if High(FarFirmInfo)<pID then try
    CS_firms.Enter;
    jj:= Length(FarFirmInfo);         // ��������� ����� �������
    SetLength(FarFirmInfo, pID+100);  // � ���������� ��������
    for ii:= jj to High(FarFirmInfo) do FarFirmInfo[ii]:= nil;
  finally
    CS_firms.Leave;
  end;
  FarFirmInfo[pID]:= TFirmInfo.Create(pID, '');
end;
//=========================================
procedure TFirms.CutEmptyCode;
var i, j: Integer;
begin
  j:= Length(FarFirmInfo);
  for i:= High(FarFirmInfo) downto 1 do if Assigned(FarFirmInfo[i]) then begin
    j:= i+1;
    break;
  end;
  if Length(FarFirmInfo)>j then try
    CS_firms.Enter;
    SetLength(FarFirmInfo, j); // �������� �� ���.����
  finally
    CS_firms.Leave;
  end;
end;
//=========================================
function TFirms.FirmExists(pID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then exit;
  Result:= (pID>0) and (length(FarFirmInfo)>pID) and Assigned(FarFirmInfo[pID]);
end;

//******************************************************************************
//                             TInfoBoxItem
//******************************************************************************
//============================================================== �������� ������
function TInfoBoxItem.GetStrI(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then exit;
  case ik of
    ik8_1: Result:= FName;       // ���������
    ik8_2: Result:= FLinkToPict; // ������ �� �������
    ik8_3: Result:= FLinkToSite; // ������ �� ����
  end;
end;
//============================================================= �������� ������
procedure TInfoBoxItem.SetStrI(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then exit;
  case ik of
    ik8_1: if (FName      <>Value) then FName      := Value; // ���������
    ik8_2: if (FLinkToPict<>Value) then FLinkToPict:= Value; // ������ �� �������
    ik8_3: if (FLinkToSite<>Value) then FLinkToSite:= Value; // ������ �� ���� / ���� ��������
  end;
end;

//******************************************************************************
//                             TEmplRole
//******************************************************************************
constructor TEmplRole.Create(pID: Integer; pName: String);
begin
  inherited Create(pID, pName, True);
  FConstLinks:= TLinks.Create(nil);
end;
//==============================================
destructor TEmplRole.Destroy;
begin
  prFree(FConstLinks);
  inherited;
end;

//******************************************************************************
//                             TConstItem
//******************************************************************************
constructor TConstItem.Create(pID: Integer; pName: String; pType: Integer=1;
            pUserID: Integer=0; pPrecision: Integer=0; WithLinks: Boolean=False);
begin
  inherited Create(pID, pUserID, pPrecision, pName, pType, WithLinks);
  case ItemType of
    constString: begin
        StrValue   := '';
        maxStrValue:= '';
        minStrValue:= '';
      end;
    else begin
        StrValue   := '0';
        maxStrValue:= '0';
        minStrValue:= '0';
      end;
  end;
  NotEmpty:= False;
  LastTime:= Now;
  Grouping:= '';
end;
//============================================== ��������� ������������ ��������
function TConstItem.CheckConstValue(var pValue: String): String;
var d: double;
    i: Integer;
    ValueStart: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ValueStart:= pValue;
  pValue:= trim(pValue);

  if pValue='' then begin
    if NotEmpty then Result:= MessText(mtkNotValidParam)+' - ������ ��������';
    case ItemType of
      constInteger, constDouble, constDateTime: pValue:= '0';
    end;

  end else try
    case ItemType of
      constInteger: begin  // ����� ��������
          i:= StrToInt(pValue);
          pValue:= IntToStr(i);
        end;
      constDouble: begin  // ������������ ��������
          d:= StrToFloat(StrWithFloatDec(pValue)); // ��������� DecimalSeparator
          pValue:= FormatFloat('#0.'+StringOfChar('0', Precision), d);
        end;
      constDateTime: begin  // �������� ����
          d:= StrToDateTimeDef(pValue, 0);
          if d=0 then pValue:= '0'
          else case Precision of
            0: pValue:= FormatDateTime(cDateFormatY4, d);
            1: pValue:= FormatDateTime(cDateTimeFormatY4S, d);
          end;
        end;
    end; // case ItemType of
  except
    Result:= MessText(mtkNotValidParam)+': constID='+IntToStr(ID)+' ValueStart='+ValueStart+' ValueEnd='+pValue;
    case ItemType of
      constInteger, constDouble, constDateTime: pValue:= '0';
    end;
  end;
end;
//================================================== �������� ��������� ��������
function TConstItem.GetStrCI(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FValue;
    ik8_2: Result:= FMaxValue;
    ik8_3: Result:= FMinValue;
    ik8_4: Result:= FGrouping;
  end;
end;
//================================================== �������� ��������� ��������
procedure TConstItem.SetStrCI(const ik: T8InfoKinds; pValue: String);
var s: string;
begin
  if not Assigned(self) then Exit;
  try
    if ik in [ik8_1, ik8_2, ik8_3] then begin 
      s:= CheckConstValue(pValue);          // ��������� ������������ ��������
      if s<>'' then raise Exception.Create(s);
    end;
    case ik of
      ik8_1: if (FValue   <>pValue) then FValue   := pValue;
      ik8_2: if (FMaxValue<>pValue) then FMaxValue:= pValue;
      ik8_3: if (FMinValue<>pValue) then FMinValue:= pValue;
      ik8_4: if (FGrouping<>pValue) then FGrouping:= pValue;
    end;
  except
    on E: Exception do prMessageLOGS('ConstItem.SetStrCI: '+E.Message, fLogCache);
  end;
end;
//======================================================= �������� ���. ��������
function TConstItem.GetDoubCI(const ik: T8InfoKinds): Double;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ItemType of
    constDouble: case ik of
        ik8_1: Result:= StrToFloatDef(StrValue, 0);
        ik8_2: Result:= StrToFloatDef(FMaxValue, 0);
        ik8_3: Result:= StrToFloatDef(FMinValue, 0);
      end;
    constDateTime: case ik of
        ik8_1: Result:= StrToDateTimeDef(StrValue, 0);
        ik8_2: Result:= StrToDateTimeDef(FMaxValue, 0);
        ik8_3: Result:= StrToDateTimeDef(FMinValue, 0);
      end;
  end; // case ItemType of
end;
//======================================================= �������� �������� ����
function TConstItem.GetDateCI(const ik: T8InfoKinds): TDateTime;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: if (ItemType=constDateTime) then Result:= StrToDateTimeDef(StrValue, 0);
    ik8_2: if (ItemType=constDateTime) then Result:= StrToDateTimeDef(FMaxValue, 0);
    ik8_3: if (ItemType=constDateTime) then Result:= StrToDateTimeDef(FMinValue, 0);
    ik8_4: Result:= FLastTime;
  end;
end;
//======================================================= �������� �������� ����
procedure TConstItem.SetDateCI(const ik: T8InfoKinds; pValue: TDateTime);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_4: if (FLastTime<>pValue) then FLastTime:= pValue; // ����� ����.���������
  end;
end;

//====================================================== �������� ����� ��������
function TConstItem.GetIntCI(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: if (ItemType=constInteger) then Result:= StrToIntDef(StrValue, 0);
    ik8_2: if (ItemType=constInteger) then Result:= StrToIntDef(FMaxValue, 0);
    ik8_3: if (ItemType=constInteger) then Result:= StrToIntDef(FMinValue, 0);
    ik8_4: Result:= FSrcID;     // ���
    ik8_5: Result:= FOrderNum;  // ���-�� ������ ����� ������� � ���� Double
    ik8_6: Result:= FSubCode;   // ��� ����� ����.���������
  end;
end;
//====================================================== �������� ����� ��������
procedure TConstItem.SetIntCI(const ik: T8InfoKinds; pValue: Integer);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_4: if (FSrcID    <>pValue) then FSrcID   := pValue; // ���
    ik8_5: if (FOrderNum <>pValue) then FOrderNum:= pValue; // ���-�� ������ ����� ������� � ���� Double
    ik8_6: if (FSubCode  <>pValue) then FSubCode := pValue; // ��� ����� ����.���������
  end;
end;

//******************************************************************************
//                             TAnalogLink
//******************************************************************************
constructor TAnalogLink.Create(pSrcID: Integer; pWarePtr: Pointer; pAnalog, pCross: Boolean);
begin
  inherited Create(pSrcID, pWarePtr);
  IsOldAnalog:= pAnalog;
  IsCross := pCross;
end;

//******************************************************************************
//                              TImportType
//******************************************************************************
constructor TImportType.Create(pID: Integer; pName: String; pReport, pImport: Boolean);
begin
  inherited Create(pID, pName, True);
  ApplyReport:= pReport;
  ApplyImport:= pImport;
end;
//******************************************************************************
//                              TContract
//******************************************************************************
constructor TContract.Create(pID, pFirmCode, pSysID: Integer; pNumber: String);
begin
  inherited Create(pID, pFirmCode, 0, pNumber, pSysID);
  SetLength(ContProcDprts, 0);
  SetLength(ContStorages, 0);
  CS_cont       := TCriticalSection.Create; // ��� ��������� ����������
  ContDestPointCodes:= TIntegerList.Create; // ���� �������� ����� ���������
  FLegalEntity:= 0;
  Status:= cstUnKnown;
end;
//==============================================================================
destructor TContract.Destroy;
var j: Integer;
begin
  if not Assigned(self) then Exit;
  SetLength(ContProcDprts, 0);
  for j:= 0 to High(ContStorages) do prFree(ContStorages[j]);
  SetLength(ContStorages, 0);
  prFree(CS_cont);
  prFree(ContDestPointCodes);
  inherited Destroy;
end;
//================================================================= �������� ���
function TContract.GetIntFC(const ik: T16InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik16_1 : Result:= FSubCode;       // ContFirm
//    ik16_2 : Result:= FCurrency;
    ik16_3 : Result:= FDutyCurrency;
    ik16_4 : Result:= FStatus;        // ������ [cstClosed, cstBlocked, cstWorked]
    ik16_5 : Result:= FWhenBlocked;
    ik16_6 : Result:= FCredDelay;
    ik16_7 : Result:= FCredCurrency;
    ik16_8 : Result:= FOrderNum;      // MainStorage
    ik16_9 : Result:= GetContManager;
    ik16_10: if Cache.DprtExist(FOrderNum) then // ��� ������� (�� �������� ������)
               Result:= Cache.arDprtInfo[FOrderNum].FilialID;
    ik16_11: Result:= FFacCenter;
    ik16_12: Result:= FPayType;
    ik16_13: Result:= GetContFaccParent;
    ik16_14: Result:= FContPriceType;
    ik16_15: Result:= FLegalEntity;
    ik16_16: Result:= FCredProfile;
  end;
end;
//================================================================= �������� ���
procedure TContract.SetIntFC(const ik: T16InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik16_1 : if (FSubCode      <>Value) then FSubCode      := Value; // ContFirm
//    ik16_2 : if (FCurrency     <>Value) then FCurrency     := Value;
    ik16_3 : if (FDutyCurrency <>Value) then FDutyCurrency := Value;
    ik16_4 : if (FStatus       <>Value) then FStatus       := Value; // ������ [cstClosed, cstBlocked, cstWorked]
    ik16_5 : if (FWhenBlocked  <>Value) then FWhenBlocked  := Value;
    ik16_6 : if (FCredDelay    <>Value) then FCredDelay    := Value;
    ik16_7 : if (FCredCurrency <>Value) then FCredCurrency := Value;
    ik16_8 : if (FOrderNum     <>Value) then FOrderNum     := Value; // MainStorage
    ik16_11: if (FFacCenter    <>Value) then FFacCenter    := Value;
    ik16_12: if (FPayType      <>Value) then FPayType      := Value;
    ik16_14: if (FContPriceType<>Value) then FContPriceType:= Value;
    ik16_15: if (FLegalEntity  <>Value) then FLegalEntity  := Value;
    ik16_16: if (FCredProfile  <>Value) then FCredProfile  := Value;
  end;
end;
//======================================================== �������� ���.��������
function TContract.GetDoubFC(const ik: T8InfoKinds): Single;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FContSumm;
    ik8_2: Result:= FCredLimit;
    ik8_3: Result:= FDebtSum;
    ik8_4: Result:= FOrderSum;
    ik8_5: Result:= FPlanOutSum;
    ik8_6: Result:= FRedSum;     // ������������ �����
    ik8_7: Result:= FVioletSum;  // ����� � ������ � ��������� �����
  end;
end;
//======================================================== �������� ���.��������
procedure TContract.SetDoubFC(const ik: T8InfoKinds; Value: Single);
begin
  Value:= RoundToHalfDown(Value);
  if not Assigned(self) then Exit else case ik of
    ik8_1: if not fnNotZero(FContSumm)   or fnNotZero(FContSumm  -Value) then FContSumm  := Value;
    ik8_2: if not fnNotZero(FCredLimit)  or fnNotZero(FCredLimit -Value) then FCredLimit := Value;
    ik8_3: if not fnNotZero(FDebtSum)    or fnNotZero(FDebtSum   -Value) then FDebtSum   := Value;
    ik8_4: if not fnNotZero(FOrderSum)   or fnNotZero(FOrderSum  -Value) then FOrderSum  := Value;
    ik8_5: if not fnNotZero(FPlanOutSum) or fnNotZero(FPlanOutSum-Value) then FPlanOutSum:= Value;
    ik8_6: if not fnNotZero(FRedSum)     or fnNotZero(FRedSum    -Value) then FRedSum    := Value;
    ik8_7: if not fnNotZero(FVioletSum)  or fnNotZero(FVioletSum -Value) then FVioletSum := Value;
  end;
end;
//============================================================== �������� ������
procedure TContract.SetStrFC(const ik: T16InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik16_2: if (FContEmail   <>Value) then FContEmail   := Value;
    ik16_3: if (FWarnMessage <>Value) then FWarnMessage := Value;
    ik16_9: if (FContComments<>Value) then FContComments:= Value;
  end;
end;
//============================================================== �������� ������
function TContract.GetStrFC(const ik: T16InfoKinds): String;
var i: Integer;
    le: TBaseDirItem;
    firma: TFirmInfo;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik16_2: Result:= FContEmail;
    ik16_3: Result:= FWarnMessage;
    ik16_4: Result:= IntToStr(MainStorage);  // ��� ������ �� ��������� ����������
    ik16_5: if Cache.FirmExist(FSubCode) then begin
             firma:= Cache.arFirmInfo[FSubCode];
             for i:= 0 to firma.LegalEntities.Count-1 do begin
               le:= TBaseDirItem(firma.LegalEntities[i]);
               if (le.ID=LegalEntity) then begin
                 Result:= le.Name;
                 Exit;
               end;
             end;
           end;
    ik16_6: Result:= IntToStr(CredCurrency); // CredCurrency ����������
    ik16_7: Result:= GetContFaccName;        // ������������ ���
    ik16_8: Result:= GetContFaccParentName;  // ������������ ���
    ik16_9: Result:= FContComments;          // �����������
  end;
end;
//==================================================== ����� ��������� ���������
function TContract.FindContManager(var Empl: TEmplInfoItem): boolean;
var i, emplID: Integer;
begin
  Result:= False;
  Empl:= nil;
  emplID:= 0;
  if not Assigned(self) then Exit;
  if not Result then with GetContBKEempls do for i:= 0 to Count-1 do begin // �� BKE ���� �������
    emplID:= Items[i];
    if not Cache.EmplExist(emplID) then Cache.TestEmpls(emplID);
    Result:= Cache.EmplExist(emplID) and not Cache.arEmplInfo[emplID].Arhived;
    if Result then break;
  end;
  if Result then Empl:= Cache.arEmplInfo[emplID];  // ��������
end;
//================================================= �������� ��������� ���������
function TContract.CheckContManager(emplID: Integer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  with GetContBKEempls do for i:= 0 to Count-1 do begin
    Result:= (emplID=Items[i]);
    if Result then break;
  end;
end;
//====================================================== ��� ��������� ���������
function TContract.GetContManager: Integer;
var Empl: TEmplInfoItem;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if FindContManager(empl) then Result:= Empl.ID; // ��� ���������
end;
//============================================================= ������������ ���
function TContract.GetContFaccName: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if not Cache.FiscalCenters.ItemExists(FacCenter) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[FacCenter]).Name;
end;
//============================================================= ��� �������� ���
function TContract.GetContFaccParent: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if not Cache.FiscalCenters.ItemExists(FacCenter) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[FacCenter]).Parent;
end;
//==================================================== ������������ �������� ���
function TContract.GetContFaccParentName: String;
var i: Integer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  i:= GetContFaccParent;
  if not Cache.FiscalCenters.ItemExists(i) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[i]).Name;
end;
//============================================= ���� ���������� ��������� �� ���
function TContract.GetContBKEempls: TIntegerList; // not Free !!!
begin
  Result:= EmptyIntegerList;
  if not Assigned(self) then Exit;
  if not Cache.FiscalCenters.ItemExists(FacCenter) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[FacCenter]).BKEempls;
end;
//================================================== �������� ����.����� �� ����
function TContract.GetContDestPoint(destID: integer): TDestPoint;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if (ContDestPointCodes.IndexOf(destID)<0) then Exit;
  Result:= Cache.arFirmInfo[ContFirm].GetFirmDestPoint(destID);
end;
//================================================  ��������� ������� ����.�����
function TContract.ContDestPointExists(destID: integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (ContDestPointCodes.IndexOf(destID)>-1);
end;
//======================================= ������ ����� ������� ������� ���������
function TContract.GetContVisStoreCodes: Tai;
var i: Integer;
    dprt: TDprtInfo;
begin
  SetLength(Result, 0);

  if not Cache.DprtExist(MainStorage) then Exit; // �� ������ ������� �����
  prAddItemToIntArray(MainStorage, Result);
  dprt:= Cache.arDprtInfo[MainStorage];
  for i:= 0 to dprt.StoresFrom.Count-1 do with TTwoCodes(dprt.StoresFrom[i]) do
    if (ID2>0) then prAddItemToIntArray(ID1, Result);
end;
//============================================= ��������� ����� �������� �������
procedure TContract.TestStoreArrayLength(kind: TArrayKind; len: integer; ChangeOnlyLess: boolean=True; inCS: boolean=True);
// len- ������ ����� �������, inCS=True - �������� ����� � CriticalSection
// ChangeOnlyLess=True - �������� ������, ���� ����� ������, False - ���� �� �����
var fl: boolean;
    i, j: integer;
begin
  if not Assigned(self) then Exit;
  i:= -1;
  case kind of
     taCurr: i:= Length(ContStorages);
     taDprt: i:= Length(ContProcDprts);
  end;
  if i<0 then Exit;
  if ChangeOnlyLess then fl:= (i<len) else fl:= (i<>len);
  if fl then try // ���� ���� ������ �����
    if inCS then CS_cont.Enter;

    case kind of
      taDprt: if i<len then prCheckLengthIntArray(ContProcDprts, len-1) else SetLength(ContProcDprts, len);
      taCurr: begin  // ���� �������� - ���� �������� ��������
                if (i>len) then for j:= len to High(ContStorages) do prFree(ContStorages[j]);
                SetLength(ContStorages, len);
                if (i<len) then for j:= i to High(ContStorages) do ContStorages[j]:= nil;
              end;
    end; // case
  finally
    if inCS then CS_cont.Leave;
  end;
end;
//========================================= ������ ������ � ������� ContStorages
function TContract.Get�ontStoreIndex(StorageID: integer): integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  for Result:= 0 to High(ContStorages) do
    if (ContStorages[Result].DprtID=StorageID) then exit;
  Result:= -1;
end;
//******************************************************************************
//                               TContracts
//******************************************************************************
function TContracts.GetContract(pID: integer): TContract;
begin
  Result:= TContract(inherited GetItem(pID));
end;

//******************************************************************************
//                            TNotificationItem
//******************************************************************************
constructor TNotificationItem.Create(pID: Integer; pText: String);
begin
  inherited Create(pID, pText);
  FFirmFilials:= TIntegerList.Create; // ���� �������� �/�
  FFirmClasses:= TIntegerList.Create; // ���� ��������� �/�
  FFirmTypes  := TIntegerList.Create; // ���� ����� �/�
  FFirms      := TIntegerList.Create; // ����  �/�
end;
//==============================================================
destructor TNotificationItem.Destroy;
begin
  prFree(FFirmFilials);
  prFree(FFirmClasses);
  prFree(FFirmTypes);
  prFree(FFirms);
  inherited;
end;
//================================================================ �������� ����
function TNotificationItem.GetDateN(const ik: T8InfoKinds): TDateTime;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FBegDate;
    ik8_2: Result:= FEndDate;
  end;
end;
//================================================================ �������� ����
procedure TNotificationItem.SetDateN(const ik: T8InfoKinds; Value: TDateTime);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if fnNotZero(FBegDate-Value) then FBegDate:= Value;
    ik8_2: if fnNotZero(FEndDate-Value) then FEndDate:= Value;
  end;
end;
//======================================================== �������� ������ �����
function TNotificationItem.GetIntListN(const ik: T8InfoKinds): TIntegerList;
begin
  Result:= nil;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FFirmFilials;
    ik8_2: Result:= FFirmClasses;
    ik8_3: Result:= FFirmTypes;
    ik8_4: Result:= FFirms;
  end;
end;
//================================================= ��������� ������� ����������
procedure TNotificationItem.CheckConditions(sFil, sClas, sTyp, sFirm: String);
begin
  if not Assigned(self) then Exit;
  prCheckIntegerListByCodesString(FFirmFilials, sFil);
  prCheckIntegerListByCodesString(FFirmClasses, sClas);
  prCheckIntegerListByCodesString(FFirmTypes, sTyp);
  prCheckIntegerListByCodesString(FFirms, sFirm);
end;
//******************************************************************************
//                             TNotifications
//******************************************************************************
function TNotifications.GetNotification(pID: integer): TNotificationItem;
begin
  Result:= TNotificationItem(inherited GetItem(pID));
end;
//===================================================== ������ ����������� �����
function TNotifications.GetFirmNotifications(FirmID: integer): TIntegerList; // must Free
var i: Integer;
    note: TNotificationItem;
begin
  Result:= TIntegerList.Create;
  for i:= 0 to ItemsList.Count-1 do begin
    note:= ItemsList[i];
    with note do if CheckFirmFilterConditions(FirmID, flFirmAdd, flFirmAuto, flFirmMoto,
      FirmFilials, FirmClasses, FirmTypes, Firms) then Result.Add(ID);
  end;
end;

//******************************************************************************
//                                   TFiscalCenter
//******************************************************************************
constructor TFiscalCenter.Create(pID, pParent: Integer; pName: String);
begin
  inherited Create(pID, pName);
  FParent:= pParent;
  BKEempls:= TIntegerList.Create;
end;
//==============================================================================
destructor TFiscalCenter.Destroy;
begin
  prFree(BKEempls);
  inherited;
end;
//================================================================= ����� ������
function TFiscalCenter.GetRegion: Integer;
var i: Integer;
begin
  Result:= 0;
  if not IsAutoSale then Exit; // ������ AUTO
  if (copy(FName, 1, 1)='0') then Exit;
  i:= pos('-', FName);
  if (i<2) then Exit;
  Result:= StrToIntDef(copy(FName, 1, i-1), 0);
end;
//========================================================= ��� ��� ���-� ������
function TFiscalCenter.GetROPfacc: Integer;
var i: Integer;
begin
  Result:= -1;
  i:= GetRegion;           // 1-� �� �����
  if (i<2) then Exit;
  if (i<Length(Cache.arRegionROPFacc)) then Result:= Cache.arRegionROPFacc[i];
end;
//===================================================== ������� ��� ���-� ������
function TFiscalCenter.CheckIsROPFacc: Boolean;
begin
  Result:= (pos('-00-01', FName)>1);
end;
//============================================================ ������� AUTO/MOTO
function TFiscalCenter.GetSaleType: Integer;
var i, iAUTO, iMOTO: Integer;
    fc: TFiscalCenter;
begin
  Result:= 0;
  iAUTO:= Cache.GetConstItem(pcFaccAUTOSaleCode).IntValue;
  iMOTO:= Cache.GetConstItem(pcFaccMOTOSaleCode).IntValue;
  i:= ID;
  fc:= nil;
  try
    while (i>0) do begin
      if (i=iAUTO) then Result:= constIsAUTO
      else if (i=iMOTO) then Result:= constIsMOTO;
      if (Result>0) then Exit;
      if (i=ID) then fc:= self
      else if Cache.FiscalCenters.ItemExists(i) then fc:= Cache.FiscalCenters[i]
      else Exit;
      i:= fc.Parent;
    end;
  except
  end;
end;

{//******************************************************************************
//                           TMarginGroups
//******************************************************************************
// � TLinks - TLinkLink: LinkPtr- ������ �� ������(TWareInfo), State- ������� �������� ������,
// � DoubleLinks - TLink: LinkPtr- ������ �� ���������(TWareInfo), State- ������� �������� ���������
//====================================================== �������� ������ �������
//==================================================== �������� TWareInfo ������
function TMarginGroups.GetWareGroup(grID: integer): TWareInfo;
var grLink: TLinkLink;
begin
  Result:= NoWare;
  if not Assigned(self) then Exit;
  grLink:= GetLinkItemByID(grID);
  if Assigned(grLink) and Assigned(grLink.LinkPtr) then Result:= grLink.LinkPtr;
end;
//================================================= �������� TWareInfo ���������
function TMarginGroups.GetWareSubGroup(grID, pgrID: integer): TWareInfo;
var pgrLinks: TLinkList;
    pgrLink: TLink;
begin
  Result:= NoWare;
  if not Assigned(self) then Exit;
  pgrLinks:= GetDoubleLinks(grID);
  if not Assigned(pgrLinks) then Exit;
  pgrLink:= pgrLinks.GetLinkListItemByID(pgrID, lkDirNone);
  if Assigned(pgrLink) and Assigned(pgrLink.LinkPtr) then Result:= pgrLink.LinkPtr;
end;
//================================================ �������� ������������� ������
function TMarginGroups.GroupExists(grID: integer): Boolean;
begin
  Result:= False;
  if Assigned(self) then Result:= LinkExists(grID);
end;
//==================================== �������� ������������� ��������� � ������
function TMarginGroups.SubGroupExists(grID, pgrID: integer): Boolean;
begin
  Result:= False;
  if Assigned(self) then Result:= DoubleLinkExists(grID, pgrID);
end;
//==================================================== ���������/�������� ������
function TMarginGroups.CheckGroup(grID: integer; SortAdd: Boolean=False): Boolean;
var grLink: TLinkLink;
    Grp: TWareInfo;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not Cache.GrpExists(grID) then Exit;
  Grp:= Cache.arWareInfo[grID];
  grLink:= GetLinkItemByID(grID);
  if not Assigned(grLink) then begin
    grLink:= TLinkLink.Create(0, Grp);
    AddLinkItem(grLink);
    if SortAdd then SortByName(0);
  end else try
    CS_Links.Enter;
    if grLink.LinkPtr<>Grp then grLink.LinkPtr:= Grp;
    grLink.State:= True;
  finally
    CS_Links.Leave;
  end;
end;
//================================================= ���������/�������� ���������
function TMarginGroups.CheckSubGroup(grID, pgrID: integer; SortAdd: Boolean=False): Boolean;
var grLink: TLinkLink;
    pgrLink: TLink;
    Pgr: TWareInfo;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not Cache.PgrExists(pgrID) then Exit;
  Pgr:= Cache.arWareInfo[pgrID];
  grLink:= GetLinkItemByID(grID);
  if not Assigned(grLink) then Exit;
  pgrLink:= grLink.DoubleLinks.GetLinkListItemByID(pgrID, lkDirNone);
  if not Assigned(pgrLink) then begin
    pgrLink:= TLink.Create(0, Pgr);
    grLink.CheckDoubleLinks(CS_Links);
    grLink.DoubleLinks.AddLinkListItem(pgrLink, lkLnkNone, CS_Links); // ������
    if SortAdd then SortByName(grID);
  end else try
    CS_Links.Enter;
    if pgrLink.LinkPtr<>Pgr then pgrLink.LinkPtr:= Pgr;
    pgrLink.State:= True;
  finally
    CS_Links.Leave;
  end;
end;
//=========================================== ������ ������ �� ������ �� �������
function TMarginGroups.GetGroupList(TypeSys: Integer=constIsAuto): TList; // must Free
var i: Integer;
    Grp: TWareInfo;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  for i:= 0 to ListLinks.Count-1 do begin
    Grp:= GetLinkPtr(ListLinks[i]);
    if not Grp.IsGrp then Continue;
    if (TypeSys>0) and not Grp.CheckWareTypeSys(TypeSys) then Continue;
    Result.Add(Grp);
  end;
end;
//=============================== ������ ������ �� ��������� � ������ �� �������
function TMarginGroups.GetSubGroupList(grID: integer; TypeSys: Integer=constIsAuto): TList; // must Free
var i: Integer;
    pgrLinks: TLinkList;
    Pgr: TWareInfo;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  if not GroupExists(grID) then Exit;
  pgrLinks:= GetDoubleLinks(grID);
  if not Assigned(pgrLinks) then Exit;
  for i:= 0 to pgrLinks.Count-1 do begin
    Pgr:= GetLinkPtr(pgrLinks[i]);
    if not Pgr.IsPgr then Continue;
    if (TypeSys>0) and not Pgr.CheckWareTypeSys(TypeSys) then Continue;
    Result.Add(Pgr);
  end;
end;
//============================= ��������� ������ � ��������/����������� �� �����
procedure TMarginGroups.SortByName(grID: integer=0);
// grID<0 - ��������� ���, grID=0 - ��������� ������ � ��������,
// grID>0 - ��������� ������ � ���������� ������ grID
var pgrLinks: TLinkList;
    i: Integer;
begin
  if not Assigned(self) then Exit;
  if (grID<1) and (LinkCount>1) then SortByLinkName; // ��� ��� ������
  if (grID=0) then Exit; // ������ ������

  if (grID>0) then begin // ��������� �������� ������
    if not LinkExists(grID) then Exit;
    pgrLinks:= GetDoubleLinks(grID);
    if not Assigned(pgrLinks) then Exit;
    if (pgrLinks.Count>1) then pgrLinks.Sort(LinkNameSortCompare);

  end else for i:= 0 to ListLinks.Count-1 do begin
    grID:= GetLinkID(ListLinks[i]);
    pgrLinks:= GetDoubleLinks(grID);
    if not Assigned(pgrLinks) then Continue;
    if (pgrLinks.Count>1) then pgrLinks.Sort(LinkNameSortCompare);
  end;
end;
//=================================== ������������� ���� �������� ���� ���������
procedure TMarginGroups.SetLinkStatesAll(pState: Boolean);
var i, grID: Integer;
    pgrLinks: TLinkList;
begin
  SetLinkStates(pState);
  for i:= 0 to ListLinks.Count-1 do begin
    grID:= GetLinkID(ListLinks[i]);
    pgrLinks:= GetDoubleLinks(grID);
    pgrLinks.SetLinkStates(pState, CS_links);
  end;
end;
//=========================================== ������� ��� �������� � State=False
procedure TMarginGroups.DelNotTestedLinksAll;
var i, grID: Integer;
    pgrLinks: TLinkList;
begin
  DelNotTestedLinks;
  for i:= 0 to ListLinks.Count-1 do begin
    grID:= GetLinkID(ListLinks[i]);
    pgrLinks:= GetDoubleLinks(grID);
    pgrLinks.DelNotTestedLinks(CS_links);
  end;
end;  }

//******************************************************************************
//                              TCurrency
//******************************************************************************
constructor TCurrency.Create(pID: Integer; pName, pCliName: String; pRate: Single; pArh: Boolean);
begin
  inherited Create(pID, pName);
  FCliName:= pCliName;
  FCurrRate:= pRate;
  Arhived:= pArh;
end;

//******************************************************************************
//                              TCurrencies
//******************************************************************************
function TCurrencies.GetCurrency(pCurrID: Integer): TCurrency;
begin
  Result:= nil;
  if not Assigned(self) or not ItemExists(pCurrID) then Exit;
  Result:= TCurrency(GetItem(pCurrID));
end;
//==============================================================================
function TCurrencies.GetCurrRate(pCurrID: Integer): Single;
begin
  Result:= 0;
  if not Assigned(self) or not ItemExists(pCurrID) then Exit;
  Result:= GetCurrency(pCurrID).CurrRate;
end;

//******************************************************************************
//                              TDiscModel
//******************************************************************************
//==============================================================================
constructor TDiscModel.Create(pID, pDirect, pRate, pSales: Integer; pName: String);
begin
  inherited Create(pID, pName);
  FDirectInd:= pDirect;
  FRating:= pRate;
  FSales:= pSales;
end;
//==============================================================================
destructor TDiscModel.Destroy;
begin

  inherited;
end;
//====================================================== �������� ����� ��������
function TDiscModel.GetIntDM(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FDirectInd; // ������ �����������
    ik8_2: Result:= FRating;   // �������
    ik8_3: Result:= FSales;    // ���.������
  end;
end;
//====================================================== �������� ����� ��������
procedure TDiscModel.SetIntDM(const ik: T8InfoKinds; pValue: Integer);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: if (FDirectInd<>pValue) then FDirectInd:= pValue; // ������ �����������
    ik8_2: if (FRating   <>pValue) then FRating   := pValue; // �������
    ik8_3: if (FSales    <>pValue) then FSales    := pValue; // ���.������
  end;
end;

//******************************************************************************
//                              TDiscModels
//******************************************************************************
constructor TDiscModels.Create;
begin
  inherited Create;
  EmptyModel:= TDiscModel.Create(0, 0, 0, 0, '');
  FDiscModels:= TObjectList.Create;
  FProdDirects:= fnCreateStringList(True, 3); // ���������� �� ������������
  CS_DiscModels:= TCriticalSection.Create;
end;
//==============================================================================
destructor TDiscModels.Destroy;
begin
  prFree(EmptyModel);
  prFree(FDiscModels);
  prFree(FProdDirects);
  prFree(CS_DiscModels);
  inherited Destroy;
end;
//==============================================================================
function TDiscModels.DirectExists(pdID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (GetDirectIndex(pdID)>-1);
end;
//=============================================== ��������/��������� �����������
procedure TDiscModels.CheckProdDirect(pdID: Integer; pdName: String);
var j: Integer;
begin
  if not Assigned(self) then Exit;
  j:= GetDirectIndex(pdID);
  if (j<0) then FProdDirects.AddObject(pdName, Pointer(pdID))
  else if (FProdDirects[j]<>pdName) then begin
    CS_DiscModels.Enter;
    try
      FProdDirects[j]:= pdName;
    finally
      CS_DiscModels.Leave;
    end;
  end;
end;
//========================================================== ������� �����������
procedure TDiscModels.DelProdDirect(pdID: Integer);
var i, j: Integer;
    dm: TDiscModel;
begin
  if not Assigned(self) then Exit;
  j:= GetDirectIndex(pdID);
  if (j<0) then exit;
  CS_DiscModels.Enter;
  try
    for i:= FDiscModels.Count-1 downto 0 do begin
      dm:= TDiscModel(FDiscModels[i]);
      if (dm.DirectInd=j) then begin
        FDiscModels.Delete(i);
        dm.Free;
      end;
    end;
    FProdDirects.Delete(j);
  finally
    CS_DiscModels.Leave;
  end;
end;
//==================================================== ��������/��������� ������
procedure TDiscModels.CheckDiscModel(dmID, pdID, pRate, pSales: Integer; dmName: String);
var j: Integer;
    dm: TDiscModel;
begin
  if not Assigned(self) then Exit;
  j:= GetDirectIndex(pdID);
  if (j<0) then exit;
  dm:= GetDiscModel(dmID);
  if (dm=EmptyModel) then begin
    dm:= TDiscModel.Create(dmID, j, pRate, pSales, dmName);
    FDiscModels.Add(dm);
  end else begin
    dm.DirectInd:= j;
    dm.Rating:= pRate;
    dm.Sales:= pSales;
    dm.Name:= dmName;
    dm.State:= True;
  end;
end;
//=============================================================== ������� ������
procedure TDiscModels.DelDiscModel(dmID: Integer);
var i: Integer;
    dm: TDiscModel;
begin
  if not Assigned(self) then Exit;
  CS_DiscModels.Enter;
  try
    for i:= FDiscModels.Count-1 downto 0 do begin
      dm:= TDiscModel(FDiscModels[i]);
      if (dm.ID=dmID) then begin
        FDiscModels.Delete(i);
        dm.Free;
        Exit;
      end;
    end;
  finally
    CS_DiscModels.Leave;
  end;
end;
//======================================================= ������� ������ �������
procedure TDiscModels.DelNotTestedDiscModels;
var i: Integer;
    dm: TDiscModel;
begin
  if not Assigned(self) then Exit;
  CS_DiscModels.Enter;
  try
    for i:= FDiscModels.Count-1 downto 0 do begin
      dm:= TDiscModel(FDiscModels[i]);
      if not dm.State then begin
        FDiscModels.Delete(i);
        dm.Free;
      end;
    end;
  finally
    CS_DiscModels.Leave;
  end;
end;
//======================================================================= ������
function TDiscModels.GetDiscModel(pID: Integer): TDiscModel;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to FDiscModels.Count-1 do begin
    Result:= TDiscModel(FDiscModels[i]);
    if (Result.ID=pID) then Exit;
  end;
  Result:= EmptyModel;
end;
//=========================================== ��� ���������� ������� �����������
function TDiscModels.GetNextDirectModel(dmID: Integer): Integer;
var i, direct, ind: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  ind:= -1;
  direct:= 0;
  for i:= 0 to FDiscModels.Count-1 do with TDiscModel(FDiscModels[i]) do
    if (ID=dmID) then begin // ����� ��.������
      ind:= i;
      direct:= DirectInd;
    end else if (ind<0) then Continue
    else if (DirectInd=direct) then begin // ��������� �� �����������
      Result:= ID;
      Exit;
    end;
end;
//================================================== ������ �������� �����������
function TDiscModels.GetDirectModelsList(pdID: Integer): TList; // must Free !!!
var i, j: Integer;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  j:= GetDirectIndex(pdID);
  if (j<0) then exit;
  for i:= 0 to FDiscModels.Count-1 do
    if (TDiscModel(FDiscModels[i]).DirectInd=j) then
      Result.Add(FDiscModels[i]);
end;
//================================================== ���-�� �������� �����������
function TDiscModels.GetDirectModelsCount(pdID: Integer): Integer;
var i, j: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  j:= GetDirectIndex(pdID);
  if (j<0) then exit;
  for i:= 0 to FDiscModels.Count-1 do
    if (TDiscModel(FDiscModels[i]).DirectInd=j) then inc(Result);
end;
//========================================================== ����������� �������
procedure TDiscModels.SortDiscModels;
begin
  if not Assigned(self) then Exit;
  CS_DiscModels.Enter;
  try
    FDiscModels.Sort(DiscModelsSortCompare);
  finally
    CS_DiscModels.Leave;
  end;
end;
//=========================================================== ������ �����������
function TDiscModels.GetDirectIndex(pdID: Integer): Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  Result:= FProdDirects.IndexOfObject(Pointer(pdID));
end;

//******************************************************************************
{function CheckCacheTestAvailable: Boolean;
begin
  Result:= fnTestExistsFiles('*'+FlagCacheFile+'*', FlagCachePath)='';
end; }
{ �� ����� ������ ������ -> Ctrl+Shift+C -> ��������� ��� ������� ��������� }

//******************************************************************************
//                                TDestPoint
//******************************************************************************
constructor TDestPoint.Create(pID: Integer; pName, pAdress: String);
begin
  inherited Create(pID, pName);
  FAdress:= pAdress;
  Disabled:= False;
end;

//===================================== ���������� / �������� ��������� Grossbee
procedure TDataCache.FillGBAttributes(fFill: Boolean=True);
const nmProc='FillGBAttributes';
      sTabPref = 'AG_WARECLASS';
      sColPref = 'AG_WRCLCOLUMN';
type
  RAttOpts = record
    att: TGBAttribute;
    AttField, ValField, OrdField: String;
    FlagSortVal: Boolean;
    Attv: TBaseDirItem;
//    Attv: TSubDirItem;
  end;
var IBD: TIBDatabase;
    IBS: TIBSQL;
    parID, pID, j, jj, i, ii, ordN, jp: Integer;
    pName, s, sTabNum, sColNum, sOrderBy, sSelects, sJoins, TabName, sColTab, sWareField, sp: String;
    TimeProc: TDateTime;
    ware: TWareInfo;
    attgr: TSubDirItem;
    att: TGBAttribute;
    attv: TBaseDirItem;
//    attv: TSubDirItem;
    ar: array of RAttOpts;
//    link: TLink;
    link: TTwoLink;
    linkt: TTwoLink;
    flNew, fl, flNewP: Boolean;
begin
  if not Assigned(self) then Exit;
  TimeProc:= Now;
  IBS:= nil;
  SetLength(ar, 0);
  flNew:= False;
  flNewP:= False;
  try
    if not fFill then begin
      GBAttributes.SetDirStates(False);
      GBAttributes.FAttValues.SetDirStates(False);
      GBAttributes.Groups.SetDirStates(False);
      for i:= 0 to GBAttributes.Groups.ItemsList.Count-1 do begin
        attgr:= GBAttributes.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          fl:= Assigned(link) and Assigned(link.LinkPtr);
          if fl then begin
            ware:= link.LinkPtr;
            ware.GBAttLinks.SetLinkStates(False);
          end else try
            attgr.Links.CS_links.Enter;
            attgr.Links.ListLinks.Delete(ii);
            if Assigned(link) then prFree(link);
          finally
            attgr.Links.CS_links.Leave;
          end;
        end; // for ii:=
        attgr.Links.SetLinkStates(False);
      end; // for i:= 0
//------------------------------------------ GBPrizeAttrs
      GBPrizeAttrs.SetDirStates(False);
      GBPrizeAttrs.FAttValues.SetDirStates(False);
      GBPrizeAttrs.Groups.SetDirStates(False);
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do begin
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          fl:= Assigned(link) and Assigned(link.LinkPtr);
          if fl then begin
            ware:= link.LinkPtr;
            ware.PrizAttLinks.SetLinkStates(False);
          end else try
            attgr.Links.CS_links.Enter;
            attgr.Links.ListLinks.Delete(ii);
            if Assigned(link) then prFree(link);
          finally
            attgr.Links.CS_links.Leave;
          end;
        end; // for ii:=
        attgr.Links.SetLinkStates(False);
      end; // for i:= 0
    end; // if not fFill

    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, true);
//---------------------------- ��������� / ��������� ������ ��������� � ��������
      IBS.SQL.Text:= 'select a0.gr, a0.grname, wp.att, wp.num, gp.glprname attname,'+
        '  gp.GLPRCLASSTYPE attType'+    //  gp.glpranrganalittype analit,
        '  from (select andtcode gr, andtname grname from analitdict'+
        '    where andtmastercode='+GetConstItem(pcWareAttributeAnDtCode).StrValue+
        '    and not (andtname starting "_")'+ // ������� - ��������� �� ����������
        '    and exists(select * from RDB$RELATIONS where RDB$SYSTEM_FLAG=0'+ // ��������� ������� �������
        '    and RDB$VIEW_SOURCE is null and RDB$RELATION_NAME="'+sTabPref+'"||andtcode)) a0'+
        '  left join (select wcprclasscode, wcprparamtype att, wcprorder num'+
        '    from wareclassparams where exists(select * from RDB$RELATION_FIELDS'+
        '    where RDB$RELATION_NAME= "'+sTabPref+'"||wcprclasscode'+
        '      and RDB$FIELD_NAME="'+sColPref+'"||wcprclasscode'+ // ��������� ������� ����� � �������
        '      ||"_"||wcprparamtype)) wp on wp.wcprclasscode = a0.gr'+
        '  left join GLSYSTEMOFWORKPARM gp on gp.glprcode=wp.att'+
        '  order by gr, att';
      IBS.ExecQuery;
      while not IBS.Eof do begin
//------------------------------------------------------------- ������ ���������
        parID:= IBS.fieldByName('gr').asInteger;
        pName:= IBS.fieldByName('grname').asString;
        j:= pos('(NEW)', AnsiUpperCase(pName));
        if (j>0) then begin
          pName:= trim(copy(pName, 1, j-1));
          j:= 1; // ������� ����� ������
          flNew:= True;
        end;

        jj:= GBAttributes.Groups.GetIDBySubCode(parID);
        if (jj>0) then begin // ����� - ���������
          attgr:= GBAttributes.Groups[jj];
          GBAttributes.Groups.CS_DirItems.Enter;
          try
            attgr.Name:= pName;
            attgr.SrcID:= j;
            attgr.State:= True;
          finally
            GBAttributes.Groups.CS_DirItems.Leave;
          end;
        end else begin
          attgr:= TSubDirItem.Create(0, parID, 0, pName, j, True); // ���=0
          GBAttributes.Groups.AddItem(Pointer(attgr)); // ��������� (���������� ���)
        end;

        while not IBS.Eof and (parID=IBS.fieldByName('gr').asInteger) do begin
//---------------------------------------------------------------------- �������
          pID:= IBS.fieldByName('att').asInteger;
          pName:= IBS.fieldByName('attname').asString;
          ordN:= IBS.fieldByName('num').asInteger;
          case IBS.fieldByName('attType').asInteger of // ���
            cWrDcAnDtClass   : j:= constAnalit;
            cWrDcIntegerClass: j:= constInteger;
            cWrDcStringClass : j:= constString;
            cWrDcDateClass   : j:= constDateTime;
            cWrDcSummClass, cWrDcPersentClass, cWrDcCoefClass: j:= constDouble;
            else j:= constString;
          end; // case

          jj:= GBAttributes.GetAttIDByGroupAndSubCode(attgr.ID, pID);
          if (jj>0) then begin // ����� - ���������
            att:= GBAttributes[jj];
            GBAttributes.CS_DirItems.Enter;
            try
              att.Name:= pName;
//              att.Group:= attgr.ID;
              att.OrderNum:= ordN;
              att.srcID:= j;
              att.State:= True;
            finally
              GBAttributes.CS_DirItems.Leave;
            end;
          end else begin
            att:= TGBAttribute.Create(0, pID, attgr.ID, ordN, 0, j, pName); // ���=0
            GBAttributes.AddItem(Pointer(att)); // ��������� (���������� ���)
          end;

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof and (parID=
//---------------------------------------------
      end;  // while not IBS.Eof
      IBS.Close;

//------------------------------------- ��������� / ��������� �������� ���������
      j:= 0; // ������� ����������� �������
      for i:= 0 to GBAttributes.Groups.ItemsList.Count-1 do try
        attgr:= GBAttributes.Groups.ItemsList[i];
        if not attgr.State then Continue;

        sTabNum:= IntToStr(attgr.SubCode);
        TabName:= sTabPref+sTabNum; // ��� ������� ������ ���������
        sColTab:= sColPref+sTabNum+'_';
        sWareField:= 'AG_WRCLWARECODE'+sTabNum;

        SetLength(ar, GBAttributes.ItemsList.Count);
        jj:= 0;
        for ii:= 0 to GBAttributes.ItemsList.Count-1 do begin
          att:= GBAttributes.ItemsList[ii];
          if not att.State or (att.FGroup<>attgr.ID) then Continue; // �������� �������� ������

          ar[jj].att:= att;
          if not fFill then att.Links.SetLinkStates(False);

          sColNum:= IntToStr(ar[jj].att.SubCode);
          ar[jj].AttField:= sColTab+sColNum; // ���� �������� / ���� Analitdict
          ar[jj].ValField:= 'val'+sColNum;   // ��������� ���� ��������
          ar[jj].OrdField:= 'ord'+sColNum;   // ��������� ���� ������.������

          ar[jj].FlagSortVal:= False;
          ar[jj].Attv:= nil;
          Inc(jj);
        end;
        if (Length(ar)>jj) then SetLength(ar, jj);
        //---------------------------------------- ��������� SQL.Text ��� ������
        sOrderBy:= '';
        sSelects:= '';
        sJoins:= '';
        for ii:= 0 to High(ar) do begin // ���������� �������� ������
          sColNum:= IntToStr(ar[ii].att.ID);
                                  // ��������� ������ ����� ��� ����������
          sOrderBy:= sOrderBy+fnIfStr(sOrderBy='', '', ', ')+ar[ii].AttField;
                                  // ��������� ������ ����� ��� ������� ��������
          if (ar[ii].att.SrcID=constAnalit) then begin
            sSelects:= sSelects+fnIfStr(sSelects='', '', ', ')+
                 ' a'+sColNum+'.andtname '+ar[ii].ValField+
                 ', a'+sColNum+'.AnDtNumberPartSlash '+ar[ii].OrdField;  // AnDtSlashCode (string)
            sJoins:= sJoins+' left join analitdict a'+sColNum+
                 ' on a'+sColNum+'.andtcode='+ar[ii].AttField;
          end else
            sSelects:= sSelects+fnIfStr(sSelects='', '', ', ')+
                       ar[ii].AttField+' '+ar[ii].ValField+
                       ', 0 '+ar[ii].OrdField;
        end; // for ii:=
        //-----------------------------------------
        IBS.SQL.Text:= 'select '+sWareField+', '+sSelects+' from '+TabName+
          ' left join wares w on w.warecode='+sWareField+sJoins+' where'+
          ' AG_WRCLWAREARCHIVE'+sTabNum+'="F" and w.warearchive="F"'+
          ' order by '+sOrderBy; // ���������� - ��� ����������� �������� ��������
        IBS.ExecQuery;
        while not IBS.Eof do begin
          pID:= IBS.fieldByName(sWareField).asInteger; // ��� ������
          if WareExist(pID) then begin
            ware:= GetWare(pID, True);
            if not ware.IsMarketWare then ware:= nil;
            if ware.IsPrize then ware:= nil;  // ���������� �������
          end else ware:= nil;
          if not Assigned(ware) then begin
            IBS.Next;
            Continue;
          end;

          for ii:= 0 to High(ar) do begin // ���������� ��������
            pName:= IBS.fieldByName(ar[ii].ValField).AsString; // �������� ���� � ��������� ����
            ordN:= IBS.fieldByName(ar[ii].OrdField).asInteger;
            ar[ii].att.CheckAttrStrValue(pName); // ��������� �������� � ����������� �� ����
            //-------------------------------- ���� ���������� �������� ��������
            if not Assigned(ar[ii].attv) or (pName<>ar[ii].attv.Name) then begin
              link:= ar[ii].Att.Links.GetLinkItemByName(pName);
              if Assigned(link) then begin // ����� ���� �� ��������
                attv:= GetLinkPtr(link);
                GBAttributes.FAttValues.CS_DirItems.Enter;
                try
                  attv.State:= True;
                finally
                  GBAttributes.FAttValues.CS_DirItems.Leave;
                end;
                ar[ii].Att.Links.CS_links.Enter;
                try
                  link.State:= True;
                finally
                  ar[ii].Att.Links.CS_links.Leave;
                end;
              end else begin
                if GBAttributes.FAttValues.FindByName(pName, Pointer(attv)) then begin
                  GBAttributes.FAttValues.CS_DirItems.Enter; // ����� ����� �������� � �����������
                  try
                    attv.State:= True;
                  finally
                    GBAttributes.FAttValues.CS_DirItems.Leave;
                  end;
                end else begin
                  attv:= TBaseDirItem.Create(0, pName); // ����� ��������
//                  attv:= TSubDirItem.Create(0, 0, ordN, pName); // ����� ��������
                  GBAttributes.FAttValues.AddItem(Pointer(attv));
                end;
                link:= TTwoLink.Create(ar[ii].Att.SrcID, attv, Pointer(ordN)); // ����� ���� (� ����� � ���.�������)
//                link:= TLink.Create(ar[ii].Att.SrcID, attv); // ����� ���� (� �����)
                ar[ii].Att.Links.AddLinkItem(link);
              end;
              ar[ii].Attv:= attv;
            end; // if ... (pName<>ar[ii].attv.Name)
            //------------------------------

            linkt:= ware.GBAttLinks[ar[ii].att.ID]; // ���� �� ������� � ������
            if Assigned(linkt) then try
              ware.GBAttLinks.CS_links.Enter; // ����� ����� �������� � �����������
              if (linkt.LinkPtrTwo<>ar[ii].attv) then linkt.LinkPtrTwo:= ar[ii].attv;
              linkt.State:= True;
            finally
              ware.GBAttLinks.CS_links.Leave;
            end else begin
              linkt:= TTwoLink.Create(0, ar[ii].att, ar[ii].attv);
              ware.GBAttLinks.AddLinkItem(linkt); // ���� �� ������� � ��������
            end;
          end; // for ii:=

          attgr.Links.CheckLink(ware.ID, 0, ware); // ���� � ������ �� �����
          inc(j); // ������� ����������� �������

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof
        IBS.Close;

        for ii:= 0 to High(ar) do begin // ���������� ��������
          if not fFill then ar[ii].att.Links.DelNotTestedLinks; // ������ ��������
          ar[ii].att.SortValues; // ���������� �������� � ����������� �� ����
        end; // for ii:=

        attgr.Links.SortByLinkName; // ��������� ����� �� ������ � ������ ���������
      except
        on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
      end; // for i:= 0 to GBAttributes.Groups.ItemsList.Count-1

//------------------------------------------ GBPrizeAttrs
//------------------- ��������� / ��������� ������ ��������� � �������� ��������
      IBS.SQL.Text:= 'select a0.gr, a0.grname, wp.att, wp.num, gp.glprname attname,'+
        '  gp.GLPRCLASSTYPE attType'+    //  gp.glpranrganalittype analit,
        '  from (select andtcode gr, andtname grname from analitdict'+
        '    where andtmastercode='+GetConstItem(pcPrizAttributeAnDtCode).StrValue+
//        '    and not (andtname starting "_")'+ // ������� - ��������� �� ����������
        fnIfStr(flDebug, '', '    and not (andtname starting "_")')+
        '    and exists(select * from RDB$RELATIONS where RDB$SYSTEM_FLAG=0'+ // ��������� ������� �������
        '    and RDB$VIEW_SOURCE is null and RDB$RELATION_NAME="'+sTabPref+'"||andtcode)) a0'+
        '  left join (select wcprclasscode, wcprparamtype att, wcprorder num'+
        '    from wareclassparams where exists(select * from RDB$RELATION_FIELDS'+
        '    where RDB$RELATION_NAME= "'+sTabPref+'"||wcprclasscode'+
        '      and RDB$FIELD_NAME="'+sColPref+'"||wcprclasscode'+ // ��������� ������� ����� � �������
        '      ||"_"||wcprparamtype)) wp on wp.wcprclasscode = a0.gr'+
        '  left join GLSYSTEMOFWORKPARM gp on gp.glprcode=wp.att'+
        '  order by gr, att';
      IBS.ExecQuery;
      while not IBS.Eof do begin
//------------------------------------------------------------- ������ ���������
        parID:= IBS.fieldByName('gr').asInteger;
        pName:= IBS.fieldByName('grname').asString;
        j:= pos('(NEW)', AnsiUpperCase(pName));
        if (j>0) then begin
          pName:= trim(copy(pName, 1, j-1));
          j:= 1; // ������� ����� ������
          flNewP:= True;
        end;

        jj:= GBPrizeAttrs.Groups.GetIDBySubCode(parID);
        if (jj>0) then begin // ����� - ���������
          attgr:= GBPrizeAttrs.Groups[jj];
          GBPrizeAttrs.Groups.CS_DirItems.Enter;
          try
            attgr.Name:= pName;
            attgr.SrcID:= j;
            attgr.State:= True;
          finally
            GBPrizeAttrs.Groups.CS_DirItems.Leave;
          end;
        end else begin
          attgr:= TSubDirItem.Create(0, parID, 0, pName, j, True); // ���=0
          GBPrizeAttrs.Groups.AddItem(Pointer(attgr)); // ��������� (���������� ���)
        end;

        while not IBS.Eof and (parID=IBS.fieldByName('gr').asInteger) do begin
//---------------------------------------------------------------------- �������
          pID:= IBS.fieldByName('att').asInteger;
          pName:= IBS.fieldByName('attname').asString;
          ordN:= IBS.fieldByName('num').asInteger;
          case IBS.fieldByName('attType').asInteger of // ���
            cWrDcAnDtClass   : j:= constAnalit;
            cWrDcIntegerClass: j:= constInteger;
            cWrDcStringClass : j:= constString;
            cWrDcDateClass   : j:= constDateTime;
            cWrDcSummClass, cWrDcPersentClass, cWrDcCoefClass: j:= constDouble;
            else j:= constString;
          end; // case

          jj:= GBPrizeAttrs.GetAttIDByGroupAndSubCode(attgr.ID, pID);
          if (jj>0) then begin // ����� - ���������
            att:= GBPrizeAttrs[jj];
            GBPrizeAttrs.CS_DirItems.Enter;
            try
              att.Name:= pName;
//              att.Group:= attgr.ID;
              att.OrderNum:= ordN;
              att.srcID:= j;
              att.State:= True;
            finally
              GBPrizeAttrs.CS_DirItems.Leave;
            end;
          end else begin
            att:= TGBAttribute.Create(0, pID, attgr.ID, ordN, 0, j, pName); // ���=0
            GBPrizeAttrs.AddItem(Pointer(att)); // ��������� (���������� ���)
          end;

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof and (parID=
//---------------------------------------------
      end;  // while not IBS.Eof
      IBS.Close;

//---------------------------- ��������� / ��������� �������� ��������� ��������
      jp:= 0; // ������� ����������� ��������
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do try
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        if not attgr.State then Continue;

        sTabNum:= IntToStr(attgr.SubCode);
        TabName:= sTabPref+sTabNum; // ��� ������� ������ ���������
        sColTab:= sColPref+sTabNum+'_';
        sWareField:= 'AG_WRCLWARECODE'+sTabNum;

        SetLength(ar, GBPrizeAttrs.ItemsList.Count);
        jj:= 0;
        for ii:= 0 to GBPrizeAttrs.ItemsList.Count-1 do begin
          att:= GBPrizeAttrs.ItemsList[ii];
          if not att.State or (att.FGroup<>attgr.ID) then Continue; // �������� �������� ������

          ar[jj].att:= att;
          if not fFill then att.Links.SetLinkStates(False);

          sColNum:= IntToStr(ar[jj].att.SubCode);
          ar[jj].AttField:= sColTab+sColNum; // ���� �������� / ���� Analitdict
          ar[jj].ValField:= 'val'+sColNum;   // ��������� ���� ��������
          ar[jj].OrdField:= 'ord'+sColNum;   // ��������� ���� ������.������

          ar[jj].FlagSortVal:= False;
          ar[jj].Attv:= nil;
          Inc(jj);
        end;
        if (Length(ar)>jj) then SetLength(ar, jj);
        //---------------------------------------- ��������� SQL.Text ��� ������
        sOrderBy:= '';
        sSelects:= '';
        sJoins:= '';
        for ii:= 0 to High(ar) do begin // ���������� �������� ������
          sColNum:= IntToStr(ar[ii].att.ID);
                                  // ��������� ������ ����� ��� ����������
          sOrderBy:= sOrderBy+fnIfStr(sOrderBy='', '', ', ')+ar[ii].AttField;
                                  // ��������� ������ ����� ��� ������� ��������
          if (ar[ii].att.SrcID=constAnalit) then begin
            sSelects:= sSelects+fnIfStr(sSelects='', '', ', ')+
                 ' a'+sColNum+'.andtname '+ar[ii].ValField+
                 ', a'+sColNum+'.AnDtNumberPartSlash '+ar[ii].OrdField;  // AnDtSlashCode (string)
            sJoins:= sJoins+' left join analitdict a'+sColNum+
                 ' on a'+sColNum+'.andtcode='+ar[ii].AttField;
          end else
            sSelects:= sSelects+fnIfStr(sSelects='', '', ', ')+
                       ar[ii].AttField+' '+ar[ii].ValField+
                       ', 0 '+ar[ii].OrdField;
        end; // for ii:=
        //-----------------------------------------
        IBS.SQL.Text:= 'select '+sWareField+', '+sSelects+' from '+TabName+
          ' left join wares w on w.warecode='+sWareField+sJoins+' where'+
          ' AG_WRCLWAREARCHIVE'+sTabNum+'="F" and w.warearchive="F"'+
          ' order by '+sOrderBy; // ���������� - ��� ����������� �������� ��������
        IBS.ExecQuery;
        while not IBS.Eof do begin
          pID:= IBS.fieldByName(sWareField).asInteger; // ��� ������
          ware:= nil;
          if WareExist(pID) then begin
            ware:= GetWare(pID, True);
            if not ware.IsMarketWare or not ware.IsPrize then ware:= nil; // ���������� �� �������
//            if not ware.IsMarketWare or not ware.IsPrize       // ���������� �� �������
//              or (Ware.RestLinks.LinkCount<1) then ware:= nil; // ���������� ��� �������
          end;
          if not Assigned(ware) then begin
            IBS.Next;
            Continue;
          end;

          for ii:= 0 to High(ar) do begin // ���������� ��������
            pName:= IBS.fieldByName(ar[ii].ValField).AsString; // �������� ���� � ��������� ����
            ordN:= IBS.fieldByName(ar[ii].OrdField).asInteger;
            ar[ii].att.CheckAttrStrValue(pName); // ��������� �������� � ����������� �� ����
            //-------------------------------- ���� ���������� �������� ��������
            if not Assigned(ar[ii].attv) or (pName<>ar[ii].attv.Name) then begin
              link:= ar[ii].Att.Links.GetLinkItemByName(pName);
              if Assigned(link) then begin // ����� ���� �� ��������
                attv:= GetLinkPtr(link);
                GBPrizeAttrs.FAttValues.CS_DirItems.Enter;
                try
                  attv.State:= True;
                finally
                  GBPrizeAttrs.FAttValues.CS_DirItems.Leave;
                end;
                ar[ii].Att.Links.CS_links.Enter;
                try
                  link.State:= True;
                finally
                  ar[ii].Att.Links.CS_links.Leave;
                end;
              end else begin
                if GBPrizeAttrs.FAttValues.FindByName(pName, Pointer(attv)) then begin
                  GBPrizeAttrs.FAttValues.CS_DirItems.Enter; // ����� ����� �������� � �����������
                  try
                    attv.State:= True;
                  finally
                    GBPrizeAttrs.FAttValues.CS_DirItems.Leave;
                  end;
                end else begin
                  attv:= TBaseDirItem.Create(0, pName); // ����� ��������
//                  attv:= TSubDirItem.Create(0, 0, ordN, pName); // ����� ��������
                  GBPrizeAttrs.FAttValues.AddItem(Pointer(attv));
                end;
                link:= TTwoLink.Create(ar[ii].Att.SrcID, attv, Pointer(ordN)); // ����� ���� (� ����� � ���.�������)
//                link:= TLink.Create(ar[ii].Att.SrcID, attv); // ����� ���� (� �����)
                ar[ii].Att.Links.AddLinkItem(link);
              end;
              ar[ii].Attv:= attv;
            end; // if ... (pName<>ar[ii].attv.Name)
            //------------------------------

            linkt:= ware.PrizAttLinks[ar[ii].att.ID]; // ���� �� ������� � ������
            if Assigned(linkt) then try
              ware.PrizAttLinks.CS_links.Enter; // ����� ����� �������� � �����������
              if (linkt.LinkPtrTwo<>ar[ii].attv) then linkt.LinkPtrTwo:= ar[ii].attv;
              linkt.State:= True;
            finally
              ware.PrizAttLinks.CS_links.Leave;
            end else begin
              linkt:= TTwoLink.Create(0, ar[ii].att, ar[ii].attv);
              ware.PrizAttLinks.AddLinkItem(linkt); // ���� �� ������� � ��������
            end;
          end; // for ii:=

          attgr.Links.CheckLink(ware.ID, 0, ware); // ���� � ������ �� �����
          inc(jp); // ������� ����������� ��������

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof
        IBS.Close;

        for ii:= 0 to High(ar) do begin // ���������� ��������
          if not fFill then ar[ii].att.Links.DelNotTestedLinks; // ������ ��������
          ar[ii].att.SortValues; // ���������� �������� � ����������� �� ����
        end; // for ii:=

        attgr.Links.SortByLinkName; // ��������� ����� �� ������ � ������ ���������
      except
        on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
      end; // for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1

    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    if (flNew<>GBAttributes.HasNewGroups) then begin
      GBAttributes.CS_DirItems.Enter;
      try
        GBAttributes.HasNewGroups:= flNew;
      finally
        GBAttributes.CS_DirItems.Leave;
      end;
    end;
//------------------------------------------ GBPrizeAttrs
    if (flNewP<>GBPrizeAttrs.HasNewGroups) then begin
      GBPrizeAttrs.CS_DirItems.Enter;
      try
        GBPrizeAttrs.HasNewGroups:= flNewP;
      finally
        GBPrizeAttrs.CS_DirItems.Leave;
      end;
    end;

    if fFill then begin
      for i:= 0 to GBAttributes.Groups.ItemsList.Count-1 do begin
        attgr:= GBAttributes.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.GBAttLinks.SortByLinkOrdNumAndName; // ��������� �� ���.� + ������������
        end; // for ii:=
      end; // for i:= 0
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do begin
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.PrizAttLinks.SortByLinkOrdNumAndName; // ��������� �� ���.� + ������������
        end; // for ii:=
      end; // for i:= 0

    end else begin
      for i:= 0 to GBAttributes.Groups.ItemsList.Count-1 do begin // ������ ����� � �������
        attgr:= GBAttributes.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.GBAttLinks.DelNotTestedLinks;
          ware.GBAttLinks.SortByLinkOrdNumAndName; // ��������� �� ���.� + ������������
        end; // for ii:=
        attgr.Links.DelNotTestedLinks;
      end; // for i:= 0
      GBAttributes.Groups.DelDirNotTested;
      GBAttributes.Groups.CheckLength; // �������� ����� �� ������������� ����
      GBAttributes.FAttValues.DelDirNotTested;
      GBAttributes.FAttValues.CheckLength;
      GBAttributes.DelDirNotTested;
      GBAttributes.CheckLength;
//------------------------------------------ GBPrizeAttrs
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do begin // ������ ����� � �������
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.PrizAttLinks.DelNotTestedLinks;
          ware.PrizAttLinks.SortByLinkOrdNumAndName; // ��������� �� ���.� + ������������
        end; // for ii:=
        attgr.Links.DelNotTestedLinks;
      end; // for i:= 0
      GBPrizeAttrs.Groups.DelDirNotTested;
      GBPrizeAttrs.Groups.CheckLength; // �������� ����� �� ������������� ����
      GBPrizeAttrs.FAttValues.DelDirNotTested;
      GBPrizeAttrs.FAttValues.CheckLength;
      GBPrizeAttrs.DelDirNotTested;
      GBPrizeAttrs.CheckLength;
    end; // if not fFill
    GBAttributes.Groups.SortDirListByName;  // ��������� ������ �� ������������
    GBAttributes.SortDirListByOrdNumAndName; // ��������� �������� �� ���.� + ������������

    s:= IntToStr(GBAttributes.Groups.ItemsList.Count)+' �� ';
    s:= s+IntToStr(GBAttributes.ItemsList.Count)+' ��� ';
    s:= s+IntToStr(GBAttributes.FAttValues.ItemsList.Count)+' ��/� ';
    s:= s+IntToStr(j)+' ��/�/� ';

//------------------------------------------ GBPrizeAttrs
    GBPrizeAttrs.Groups.SortDirListByName;  // ��������� ������ �� ������������
    GBPrizeAttrs.SortDirListByOrdNumAndName; // ��������� �������� �� ���.� + ������������

    sp:= IntToStr(GBPrizeAttrs.Groups.ItemsList.Count)+' ��.� ';
    sp:= sp+IntToStr(GBPrizeAttrs.ItemsList.Count)+' ���.� ';
    sp:= sp+IntToStr(GBPrizeAttrs.FAttValues.ItemsList.Count)+' ��/�.� ';
    sp:= sp+IntToStr(jp)+' ��/�/� ';

{  if flDebug then begin
     prMessageLOGS(nmProc+': ----------------------------', fLogDebug, False);
     prMessageLOGS(nmProc+': --------------- GBPrizeAttrs', fLogDebug, False);
      for i:= 0 to GBPrizeAttrs.ItemsList.Count-1 do begin
        att:= GBPrizeAttrs.ItemsList[i];
        prMessageLOGS(nmProc+': --------------- att= '+IntToStr(att.SubCode)+' '+att.Name, fLogDebug, False);
        for ii:= 0 to att.Links.ListLinks.Count-1 do begin
          link:= att.Links.ListLinks[ii];
          attv:= link.LinkPtr;
          prMessageLOGS(nmProc+': attval= '+IntToStr(attv.ID)+' '+attv.Name, fLogDebug, False);
        end;
      end;

      prMessageLOGS(nmProc+': --------------- wares GBPrizeAttrs', fLogDebug, False);
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do begin
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        prMessageLOGS(nmProc+': --------------- gr='+IntToStr(attgr.SubCode)+' '+attgr.Name, fLogDebug, False);
        for ii:= 0 to attgr.Links.ListLinks.Count-1 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          sJoins:= 'ware= '+fnMakeAddCharStr(ware.Name, 40, True);
          for j:= 0 to ware.PrizAttLinks.ListLinks.Count-1 do begin
            linkt:= ware.PrizAttLinks.ListLinks[j];
            att:= linkt.LinkPtr;
            attv:= linkt.LinkPtrTwo;
            sJoins:= sJoins+' '+fnMakeAddCharStr(att.Name, 10, True)+' '+fnMakeAddCharStr(attv.Name, 10, True);
          end;
          prMessageLOGS(nmProc+': '+sJoins, fLogDebug, False);
        end; // for ii:=
      end;
end; }
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  SetLength(ar, 0);
  prMessageLOGS(nmProc+': '+s+' - '+GetLogTimeStr(TimeProc), fLogCache, false);
  prMessageLOGS(nmProc+': '+sp+' - '+GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;

//******************************************************************************
//                                  TGBAttribute
//******************************************************************************
{function StrByTypeSortCompare(s1, s2: String): Integer;
var i1, i2: integer;
begin
  Result:= 0;
  try
    i1:= StrToIntDef(s1, 0);
    i2:= StrToIntDef(s2, 0);
    if i1<i2 then Result:= -1 else if i1>i2 then Result:= 1;
  except
    Result:= 0;
  end;
end; }
//================== ���������� TList ������ �������� ��������� � ���-�� �� ����
function AttValLinksSortCompare(Item1, Item2: Pointer): Integer;
var d1, d2: Double;
    i1, i2: integer;
    s1, s2: String;
begin
  Result:= 0;
  try
    i1:= Integer(TTwoLink(Item1).LinkPtrTwo);
    i2:= Integer(TTwoLink(Item2).LinkPtrTwo);
    if (i1<>i2) then begin
      if i1<i2 then Result:= -1 else if i1>i2 then Result:= 1;
      Exit;
    end;
    s1:= GetLinkName(Item1);
    s2:= GetLinkName(Item2);
    case TLink(Item1).SrcID of
      constInteger: begin
        i1:= StrToIntDef(s1, 0);
        i2:= StrToIntDef(s2, 0);
        if i1<i2 then Result:= -1 else if i1>i2 then Result:= 1;
      end;
      constDouble: begin
        d1:= StrToFloatDef(s1, 0);
        d2:= StrToFloatDef(s2, 0);
        if fnNotZero(d1-d2) then if d1<d2 then Result:= -1 else Result:= 1;
      end;
      else Result:= AnsiCompareText(S1, S2);
    end; // case
  except
    Result:= 0;
  end;
end;
//===========================================================
constructor TGBAttribute.Create(pID, pSubCode, pGrpID, pOrderNum: Integer;
                                pPrecision, pType: Byte; pName: String);
begin
  inherited Create(pID, pSubCode, pOrderNum, pName, pType, True);
  FGroup     := pGrpID;
//  FPrecision := 0;
 end;
{//===========================================================
destructor TGBAttribute.Destroy;
begin

  inherited;
end; }
//===========================================================
procedure TGBAttribute.SortValues;
begin
  if not Assigned(self) then Exit;
  Links.LinkSort(AttValLinksSortCompare);
end;
//===========================================================
procedure TGBAttribute.CheckAttrStrValue(var pValue: String);
var d: double;
//    i: integer;
begin
  if not Assigned(self) then Exit;
  pValue:= trim(pValue);
  if pValue=''  then Exit;
  case FSrcID of
    constDouble: begin
        pValue:= StrWithFloatDec(pValue); // ��������� DecimalSeparator
        try
          d:= StrToFloat(pValue);
          pValue:= FormatFloat('###0.#', d);
{          i:= Round(d);
          if (d>15) and not fnNotZero(d-i) then pValue:= FormatFloat('#0', d) //FloatToStr(d)
          else begin
            pValue:= FormatFloat('#0.'+StringOfChar('0', Prec), d);
          end; }
        except
//          pValue:= '0';
        end;
      end; // constDouble
  end; // case
end;

//******************************************************************************
//                              TGBAttributes
//******************************************************************************
constructor TGBAttributes.Create(LengthStep: Integer);
begin
  inherited;
  FGroups:= TOwnDirItems.Create(LengthStep);  // ���������� ����� ���������
  FAttValues:= TOwnDirItems.Create(LengthStep); // ���������� �������� ���������
end;
//===========================================================
destructor TGBAttributes.Destroy;
begin
  prFree(FAttValues);
  prFree(FGroups);
  inherited;
end;
//===========================================================
function TGBAttributes.GetAtt(attID: Integer): TGBAttribute;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TGBAttribute(DirItems[attID]);
end;
//===========================================================
function TGBAttributes.GetGrp(grpID: Integer): TSubDirItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TSubDirItem(FGroups[grpID]);
end;
//================== ������ ��������� ������, ������������� �� ������.� +������.
function TGBAttributes.GetGBGroupAttsList(grpID: Integer): TList; // must Free
var i: integer;
    att: TGBAttribute;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  for i:= 0 to ItemsList.Count-1 do begin
    att:= ItemsList[i];
    if (att.Group=grpID) then Result.Add(att);
  end;
end;
{//================================================ �������� ID �� ������ + �����
function TGBAttributes.GetAttIDByGroupAndName(grpID: Integer; pName: String): Integer;
var i: Integer;
    att: TGBAttribute;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  try
    for i:= 0 to ItemsList.Count-1 do begin
      att:= ItemsList[i];
      if (att.Group=grpID) and (att.Name=pName) then begin
        Result:= att.ID;
        exit;
      end;
    end;
  except end;
end;  }
//============================================== �������� ID �� ������ + SubCode
function TGBAttributes.GetAttIDByGroupAndSubCode(grpID, pSubCode: Integer): Integer;
var i: Integer;
    att: TGBAttribute;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  try
    for i:= 0 to ItemsList.Count-1 do begin
      att:= ItemsList[i];
      if (att.Group=grpID) and (att.SubCode=pSubCode) then begin
        Result:= att.ID;
        exit;
      end;
    end;
  except end;
end;

//******************************************************************************
//                              TWareAction
//******************************************************************************
constructor TWareAction.Create(pID: Integer; pName, pComm: String; pBeg, pEnd: TDateTime);
begin
  inherited Create(pID, pName);
  FComment:= pComm;
  FBegDate:= pBeg;
  FEndDate:= pEnd;
  IsAction   := False; // ���� - �����
  IsCatchMom := False; // ���� - ���� ������
  IsNews     := False; // ���� - �������
  IsTopSearch:= False; // ���� - ��� ������
  IconMS:= TMemoryStream.Create;
end;
//==============================================================================
destructor TWareAction.Destroy;
begin
  prFree(IconMS);
  inherited;
end;
//================================================================ �������� ����
function TWareAction.GetDateN(const ik: T8InfoKinds): TDateTime;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FBegDate;
    ik8_2: Result:= FEndDate;
  end;
end;
//================================================================ �������� ����
procedure TWareAction.SetDateN(const ik: T8InfoKinds; Value: TDateTime);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if fnNotZero(FBegDate-Value) then FBegDate:= Value;
    ik8_2: if fnNotZero(FEndDate-Value) then FEndDate:= Value;
  end;
end;
//============================================================== �������� ������
function TWareAction.GetStrN(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FName;
    ik8_2: Result:= FNum;                             // �����
    ik8_3: Result:= FComment;
    ik8_4: Result:= FIconExt;
  end;
end;
//==============================================================================
procedure TWareAction.SetStrN(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
   ik8_1: if (FName   <>Value) then FName   := Value;  //
   ik8_2: if (FNum    <>Value) then FNum    := Value;  //
   ik8_3: if (FComment<>Value) then FComment:= Value;  //
   ik8_4: if (FIconExt<>Value) then FIconExt:= Value;  //
  end;
end;

//******************************************************************************
//                              TWareTypeOpts
//******************************************************************************
constructor TWareTypeOpts.Create(pCountLimit: Single=0; pWeightLimit: Single=0);
begin
  inherited Create;
  FCountLimit:= RoundTo(pCountLimit, -3);
  FWeightLimit:= RoundTo(pWeightLimit, -3);
end;

//******************************************************************************
//                              TProductLine
//******************************************************************************
//=================================================== ����������� �� 1-�� ������
function TProductLine.GetComment: String;
var link: TLink;
    ware: TWareInfo;
begin
  Result:= '';
  if not Assigned(self) or not Assigned(FLinks) then Exit;
  if (FLinks.LinkCount<1) then Exit;
  link:= FLinks.ListLinks[0];
  ware:= link.LinkPtr;
  if Assigned(ware) then Result:= ware.Comment;
end;

//******************************************************************************
//                              TProductLines
//******************************************************************************
//======================================================= ������ �� ���� �������
function TProductLines.GetProductLine(pID: Integer): TProductLine;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to Count-1 do begin
    Result:= TProductLine(inherited Items[i]);
    if (Result.ID=pID) then Exit;
  end;
  Result:= nil;
end;
//=================================================== ������ �� �������� �������
function TProductLines.GetProductLine(pName: String): TProductLine;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to Count-1 do begin
    Result:= TProductLine(inherited Items[i]);
    if (Result.Name=pName) then Exit;
  end;
  Result:= nil;
end;

//******************************************************************************
//                                  TMotulNode
//******************************************************************************
constructor TMotulNode.Create(pID, pParentID, pMeasID, pSysID, pOrdnum: Integer; pName,
                              pNameSys: String; pVisible: Boolean);
begin
  inherited Create(pID, pParentID, 0, pName, pSysID, True); // TDirItem � �������
  State    := True;
  FNameSys := pNameSys;     // ������������ ���� (���������)
  FChildren:= TList.Create; // ������ ����������� ����� (������������� �� �����)
  FMeasID  := pMeasID;
  FOrderOut:= pOrdnum;
  Visible  := pVisible;     // ������� ��������� ����
end;
//==============================================================================
destructor TMotulNode.Destroy;
begin
  if not Assigned(self) then Exit;
  if Assigned(FChildren) then prFree(FChildren);
  inherited Destroy;
end;
//======================================================== ������� �������� ����
function TMotulNode.GetIsEnding: boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= not Assigned(FChildren) or (FChildren.Count<1);
end;

//******************************************************************************
//                               TMotulTreeNodes
//******************************************************************************
constructor TMotulTreeNodes.Create(LengthStep: Integer=10);
begin
  inherited Create(LengthStep);
  SetLength(FItems, 1);
  FItems[0]:= TMotulNode.Create(0, -1, 0, 0, 0, '������ MOTUL', 'Root'); // �������� ���� ������
end;
//==============================================================================
{destructor TMotulTreeNodes.Destroy;
begin
  if not Assigned(self) then Exit;
  inherited Destroy;
end;  }
//======================================================== �������� ���� �� ����
function TMotulTreeNodes.GetNodeByID(pID: Integer): TMotulNode;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if (pID>0) and not ItemExists(pID) then Exit;
  Result:= TMotulNode(FItems[pID]);
end;
//=========================================================== ����� ���� �� ����
function TMotulTreeNodes.MotulNodeGet(pID: Integer; var pNodeGet: TMotulNode): Boolean;
begin
  Result:= False;
  pNodeGet:= nil;
  if not Assigned(self) then Exit;
  pNodeGet:= GetNodeByID(pID);
  Result:= Assigned(pNodeGet);
end;
//======================================== ����� ���� �� ���������� ������������
function TMotulTreeNodes.MotulNodeGet(pSys: Integer; pNameSys: String; var pNodeGet: TMotulNode): Boolean;
var j: Integer;
begin
  Result:= False;
  pNodeGet:= nil;
  if not Assigned(self) then Exit;

  for j:= 0 to ItemsList.Count-1 do begin
    pNodeGet:= ItemsList[j];
    if ((pSys=0) or (pSys=pNodeGet.TypeSys)) and (pNodeGet.NameSys=pNameSys) then break;
    pNodeGet:= nil;
  end;
  Result:= Assigned(pNodeGet);
end;
//================== ������������� ������ ������ ���������������� �� ���� ������
procedure TMotulTreeNodes.SortNodesList;
var j: Integer;
  //----------------------------
  procedure GetNodes(pNode: TMotulNode);
  var i: Integer;
  begin
    if (pNode.ParentID>-1) then begin
      inc(j);
      pNode.OrderNum:= j;
    end;
    if Assigned(pNode.Children) then
      for i:= 0 to pNode.Children.Count-1 do GetNodes(TMotulNode(pNode.Children[i]));
  end;
  //-----------------------------
begin
  if not Assigned(self) then Exit;
  j:= 0;
  CS_DirItems.Enter;
  try
    GetNodes(Nodes[0]);     // ����������� ���������� ����� �����
  finally
    CS_DirItems.Leave;
  end;
  SortDirListByOrdNumAndName; // ��������� �� ������.������
end;
//----- �������� ������ ������ ������� (0 - ���) ���������������� �� ���� ������
function TMotulTreeNodes.MotulGetSysTree(SysID: integer=0): TStringList; // must Free
var j: Integer;
    pNode: TMotulNode;
begin
  Result:= TStringList.Create;
  if not Assigned(self) or (ItemsList.Count<2) then Exit;

  if (SysID>0) and not CheckTypeSys(SysID) then
    raise Exception.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));

  Result.Capacity:= ItemsList.Count;
  for j:= 0 to ItemsList.Count-1 do begin
    pNode:= ItemsList[j];
    if (SysID>0) and (SysID<>pNode.TypeSys) then Continue;
    Result.AddObject(pNode.Name, pNode);
  end;
end;
//========================================= ��������� ���������� ���������� ����
function TMotulTreeNodes.MotulNodeValidForAdd(pID, pParentID: Integer; pName, pNameSys: String;
         var pNodeAdd, pNodeParent: TMotulNode; pCheckTreeDup: Boolean=True): String;
const nmProc = 'MotulNodeValidForAdd';
var i, sysID: Integer;
    pNode: TMotulNode;
begin
  Result:= '';
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrProcess));
    if (pName='') then raise Exception.Create(MessText(mtkEmptyName));
    if (pNameSys='') then raise Exception.Create(MessText(mtkEmptySysName));

    if not MotulNodeGet(pParentID, pNodeParent) then // ���� �������� �� ������
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pParentID)));
    if (pID>0) and MotulNodeGet(pID, pNodeAdd) then // ���� � ����� ����� �������
      raise Exception.Create('�������� ���� ����');

    if not pCheckTreeDup then Exit;

    if Assigned(pNodeParent.Children) then
      for i:= 0 to pNodeParent.Children.Count-1 do begin
        pNode:= pNodeParent.Children[i];
        if not Assigned(pNode) or (pNode.Name<>pName) then Continue;
        pNodeAdd:= pNode; // �������� ����� � 1-� �����
        raise Exception.Create('��� ������ ���� ����� �������� ����� ����� ��������.');
      end;

    pNameSys:= AnsiUpperCase(pNameSys);
    sysID:= pNodeParent.TypeSys;
    for i:= 0 to ItemsList.Count-1 do begin
      pNode:= ItemsList[i];              // �������� ���������� �����
      if not Assigned(pNode) then Continue;
      if (sysID>0) and (pNode.TypeSys<>sysID) then Continue;
      if (AnsiUpperCase(pNode.NameSys)=pNameSys) then
        raise Exception.Create(MessText(mtkDuplicateSysNm, pNameSys));
    end;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
end;
//========================================== ���������� ����� ����� ������ Motul
function MotulNodeChildSortCompare(Item1, Item2: Pointer): Integer;
var Node1: TMotulNode;
    Node2: TMotulNode;
begin
  try
    Node1:= Item1;
    Node2:= Item2;
    if (Node1.OrderOut=Node2.OrderOut) then
      Result:= AnsiCompareText(Node1.Name, Node2.Name)
    else if (Node1.OrderOut>Node2.OrderOut) then Result:= 1 else Result:= -1;
  except
    Result:= 0;
  end;
end;
//================================================================= ������� ����
function TMotulTreeNodes.MotulNodeDel(pNodeID: Integer): String;
const nmProc = 'NodeDel';
var Node, NodeParent: TMotulNode;
    idxParent: Integer;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrDelRecord));
    if not MotulNodeGet(pNodeID, Node) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pNodeID)));

    if not Node.IsEnding then
      raise Exception.Create('���� ����� ����������� ����.');
    if not MotulNodeGet(Node.ParentID, NodeParent) then
      raise Exception.Create('�� ������ ������������ ����.');

    ORD_IBD:= cntsORD.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True); //  �������� � ����
      ORD_IBS.SQL.Text:= 'delete from TREENODESmotul where TRNmCODE='+IntToStr(pNodeId);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    idxParent:= NodeParent.Children.IndexOf(Node);  // ������� ���� � ������ ��������
    CS_DirItems.Enter;
    try
      NodeParent.Children.Delete(idxParent); // ������� �� ������ �����
    finally
      CS_DirItems.Leave;
    end;
    DeleteItem(pNodeID); // ������� ���� �� ����
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//====================================================== �������� ��������� ����
function TMotulTreeNodes.MotulNodeEdit(pNodeID, pVisible, pUserID, pOrdnum: Integer;
                                       pName, pNameSys: String): String;
const nmProc = 'NodeEdit';
// pVisible<0 - �� ������, pName, pNameSys='' - �� ������
var Node, NodeParent, pNode: TMotulNode;
    i: Integer;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    flUpdName, flUpdSysName, flUpdVis, flUpdord: Boolean;
begin
  Result:= '';
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrEditRecord));
    if not MotulNodeGet(pNodeID, Node) then
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pNodeID))); // ���� � ����� pID �� ������
    pName:= Trim(pName);
    pNameSys:= Trim(pNameSys);
    if (pNameSys<>'') then pNameSys:= AnsiUpperCase(pNameSys);

    flUpdName   := (pName<>'')    and (Node.Name<>pName);
    flUpdSysName:= (pNameSys<>'') and (Node.NameSys<>pNameSys);
    flUpdVis    := (pVisible>-1)  and (Node.Visible<>(pVisible=1));
    flUpdord    := (pOrdnum>0)    and (Node.OrderOut<>pOrdnum);

    if not flUpdName and not flUpdSysName and not flUpdVis and not flUpdord then
      raise Exception.Create(MessText(mtkNotChanges));

    if not MotulNodeGet(Node.ParentID, NodeParent) then
      raise Exception.Create('�� ������ ������������ ����.');

    if flUpdName then for i:= 0 to NodeParent.Children.Count-1 do begin
      pNode:= NodeParent.Children[i];   // ���� ���� � ����� ������ � ��������
      if Assigned(pNode) and (pNode.Name=pName) then
        raise Exception.Create('����� ��� ���� ����� �������� ����� ����� ��������.');
    end;

    if flUpdSysName then for i:= 0 to ItemsList.Count-1 do begin
      pNode:= ItemsList[i];             // ���� ���� � ����� ��������� ������
      if not Assigned(pNode) or (pNode.ID=Node.ID) then Continue;
      if (pNode.TypeSys<>Node.TypeSys) then Continue;
      if (AnsiUpperCase(pNode.NameSys)=pNameSys) then
        raise Exception.Create(MessText(mtkDuplicateSysNm, pNameSys));
    end;

//------------------------------------------- ��������� ������������ � ���������
    if flUpdName or flUpdSysName or flUpdVis or flUpdord then begin
      ORD_IBD:= cntsORD.GetFreeCnt;
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);  // � ����
        ORD_IBS.SQL.Text:= 'update TREENODESmotul set '+
          fnIfStr(flUpdName,    'TRNmNAME=:TRNmNAME, ', '')+
          fnIfStr(flUpdSysName, 'TRNmNAMESYS=:TRNmNAMESYS, ', '')+
          fnIfStr(flUpdVis,     'TRNmVISIBLE='+fnIfStr((pVisible=1), '"T"', '"F"')+', ', '')+
          fnIfStr(flUpdord,     'TRNMordnum='+IntToStr(pOrdnum)+', ', '')+
          'TRNmUSERID='+IntToStr(pUserID)+' where TRNmCODE='+IntToStr(pNodeID);
        if flUpdName    then ORD_IBS.ParamByName('TRNmNAME').AsString:= pName;
        if flUpdSysName then ORD_IBS.ParamByName('TRNmNAMESYS').AsString:= pNameSys;
        ORD_IBS.ExecQuery;
        ORD_IBS.Transaction.Commit;
      finally
        prFreeIBSQL(ORD_IBS);
        cntsOrd.SetFreeCnt(ORD_IBD);
      end;

      CS_DirItems.Enter;
      try
        if flUpdSysName then Node.FNameSys:= pNameSys;
        if flUpdVis     then Node.Visible:= (pVisible=1);
        if flUpdord     then Node.FOrderOut:= pOrdnum;
        if flUpdName    then Node.Name:= pName;
        if flUpdord or flUpdName then
          NodeParent.Children.SortList(MotulNodeChildSortCompare);
      finally
        CS_DirItems.Leave;
      end;
                       // ������������� ������ ��������������� ����� �������
      if flUpdord or flUpdName then SortNodesList;
    end;
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//=========================================== ���������� �������� � ������ �����
function TMotulTreeNodes.MotulNodeAdd(pParentID, pUserID, pSysID, pOrdnum: Integer;
         var pNodeID: Integer; pNodeName, pNodeNameSys: String; pVisible: Boolean=True;
         pMeasID: Integer=0; ToBase: Boolean=False): String;
const nmProc = 'MotulNodeAdd';
var Node, NodeParent: TMotulNode;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
//    kind: Integer;
begin
  Result:= '';
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  Node:= nil;
  NodeParent:= nil;
//  kind:= -1;
  try
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrAddRecord));

    pNodeNameSys:= AnsiUpperCase(pNodeNameSys);
    if (pNodeID<1) then pNodeID:= -1;

    Result:= MotulNodeValidForAdd(pNodeID, pParentID, pNodeName, pNodeNameSys, Node, NodeParent, ToBase);
    if (Result<>'') then raise Exception.Create(Result);

    if ToBase then try //------------------------------------- ���������� � ����
      ORD_IBD:= cntsORD.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select * from CheckMotulNode('+IntToStr(pSysID)+', '+
        IntToStr(pUserID)+', '+IntToStr(pMeasID)+', '+IntToStr(pParentID)+', '+
        fnIfStr(pVisible, '"T", ', '"F", ')+':TRNANAME, :TRNANAMESYS)';
      ORD_IBS.ParamByName('TRNANAME').AsString:= pNodeName;
      ORD_IBS.ParamByName('TRNANAMESYS').AsString:= pNodeNameSys;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
//        kind:= ORD_IBS.FieldByName('rKind').asInteger; // kind= 0 - ������ �� ��������, 1 - ���� ����������
        pNodeID:= ORD_IBS.FieldByName('rNode').asInteger;
        pMeasID:= ORD_IBS.FieldByName('rmeasID').asInteger;
        pParentID:= ORD_IBS.FieldByName('rParent').asInteger;
        pVisible:= (ORD_IBS.FieldByName('rIsVis').AsString='T');
        pNodeName:= ORD_IBS.FieldByName('rNodeName').AsString;
        pNodeNameSys:= ORD_IBS.FieldByName('rSysName').AsString;
      end;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end; // if ToBase
    if (pNodeID<1) then raise Exception.Create('pNodeID<1');

    Node:= TMotulNode.Create(pNodeID, pParentID, pMeasID, pSysID, pOrdnum, pNodeName, pNodeNameSys, pVisible);
    CheckItem(Pointer(Node));
    CS_DirItems.Enter;
    try
      if not Assigned(NodeParent.Children) then NodeParent.FChildren:= TList.Create;
      NodeParent.Children.Add(Node);
      if ToBase then NodeParent.Children.SortList(MotulNodeChildSortCompare);
    finally
      CS_DirItems.Leave;
    end;

    if ToBase then SortNodesList;
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//====================================================== ���������� ������ �����
procedure TDataCache.FillTreeNodesMotul;
const nmProc = 'FillTreeNodesMotul';
var TimeProc: TDateTime;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    i, j, k, MeasCode, Code, CodeParent, sysID, pOrdnum: Integer;
    pName, pNameSys, s: String;
    TempList: TList;
    pVisible: Boolean;
    pNode: TMotulNode;
    Node: TAutoTreeNode;
begin
  if not Assigned(self) then Exit;
  TimeProc:= Now;
  ORD_IBS:= nil;
  ORD_IBD:= nil;
  TempList:= TList.Create;
  j:= 0; // ����� �������
  pOrdnum:= 1;
  try
    ORD_IBD:= cntsORD.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
    ORD_IBS.SQL.Text:= 'select * from TREENODESmotul'+
                       ' order by TRNmDTSYCODE, TRNmCODEPARENT, TRNMcode';
    ORD_IBS.ExecQuery;

    while not ORD_IBS.Eof do begin
      sysID:= ORD_IBS.FieldByName('TRNmDTSYCODE').asInteger;
      //--------------------------------------------------------- 1 �������
      if TempList.Count>0 then TempList.Clear; // ������ ������� �����
      while not ORD_IBS.Eof and (sysID=ORD_IBS.FieldByName('TRNmDTSYCODE').asInteger) do begin
        CodeParent:= ORD_IBS.FieldByName('TRNmCODEPARENT').asInteger;

        Code      := ORD_IBS.FieldByName('TRNmCODE').asInteger;
        pName     := ORD_IBS.FieldByName('TRNmNAME').asString;
        pNameSys  := ORD_IBS.FieldByName('TRNmNAMESYS').asString; // ������� �������� ���� � ������ � ����
        MeasCode  := ORD_IBS.FieldByName('TRNmMEAS').asInteger;
        pVisible  := GetBoolGB(ORD_IBS, 'TRNmVISIBLE');
        pOrdnum   := ORD_IBS.FieldByName('TRNMordnum').asInteger;

        s:= MotulTreeNodes.MotulNodeAdd(CodeParent, 0, sysID, pOrdnum, Code, pName, pNameSys, pVisible, MeasCode);

        if (s<>'') then begin // ���� �� ���������� - ���������� � ������
          pNode:= TMotulNode.Create(Code, CodeParent, MeasCode, sysID, pOrdnum, pName, pNameSys, pVisible);
          TempList.Add(pNode)
        end else inc(j); // ������� ���������� ����

        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end; // while ...DTSYCode=...

      k:= 0; // ������� ��������
      if TempList.Count>0 then repeat // ����� �� ������ ������� �����
        for i:= TempList.Count-1 downto 0 do begin
          pNode:= TempList[i];
          if not Assigned(pNode) then begin
            TempList.Delete(i);
            Continue;
          end;
          Code:= pNode.ID;  // ����� ��� var ���������
                                      // ����� ������� �������� ���� � ������
          s:= MotulTreeNodes.MotulNodeAdd(pNode.ParentID, 0, pNode.TypeSys, pOrdnum,
              Code, pNode.Name, pNode.NameSys, pNode.Visible, pNode.MeasID);
          if (s='') then begin // ���� ����������
            inc(j);            // ������� ���������� ����
            TempList.Delete(i);
            prFree(pNode);     // ������ ������� ������
          end;
        end; // for

        inc(k);
      until (TempList.Count<1) or (k>RepeatCount); // ���� ��� �� �������, �� �� ����� RepeatCount ��������

      if (TempList.Count>0) then begin // ���� �� ��� ���� - ����� � ���
        prMessageLOGS(nmProc+': ������ ������ � ��� '+IntToStr(TempList.Count)+' �����:', fLogCache, false);
        for i:= TempList.Count-1 downto 0 do begin
          pNode:= TempList[i];
          prMessageLOGS(nmProc+':    ��� ���� -'+IntToStr(pNode.ID)+', '+pNode.Name, fLogCache, false);
          prFree(pNode);
        end;
      end;
      //--------------------------------------------------------- 1 �������
    end; //  while not ORD_IBS.Eof
    ORD_IBS.Close;

    for i:= 0 to MotulTreeNodes.ItemsList.Count-1 do begin // ��������� ������ �����
      pNode:= MotulTreeNodes.ItemsList[i];
      if not Assigned(pNode) or not Assigned(pNode.Children) then Continue;
      if (pNode.Children.Count<2) then Continue;
      MotulTreeNodes.CS_DirItems.Enter;
      try
        pNode.Children.SortList(MotulNodeChildSortCompare);
      finally
        MotulTreeNodes.CS_DirItems.Leave;
      end;
    end;
    MotulTreeNodes.SortNodesList; // ��������� ������ �����

    //------------------- ��������� ������������ ����� ������� Motul � ���������
    ORD_IBS.SQL.Text:= 'select LTNMTRNM, TRNACODE from LINKTREENODES_MOTUL'+
                       ' left join treenodesauto on TRNAMainCode=LTNMTRNA'+
                       ' order by LTNMTRNM, TRNACODE';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      Code:= ORD_IBS.FieldByName('LTNMTRNM').asInteger;
      pNode:= MotulTreeNodes[Code];
      if Assigned(pNode) then sysID:= pNode.TypeSys else sysID:= 0;
{if flDebug then
  if Assigned(pNode) then prMessageLOGS(nmProc+': motul - '+IntToStr(pNode.TypeSys)+
                          ' - '+IntToStr(pNode.ID)+' - '+pNode.Name, fLogDebug, false);  }
      while not ORD_IBS.Eof and (Code=ORD_IBS.FieldByName('LTNMTRNM').asInteger) do begin
        if Assigned(pNode) then begin
          MeasCode:= ORD_IBS.FieldByName('TRNACODE').asInteger;
          if FDCA.AutoTreeNodesSys[SysID].NodeGet(MeasCode, Node) then
            pNode.DupNodes.CheckLink(MeasCode, 0, Node);
        end;

        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end; //  while ... Code= ...
{if flDebug then for i:= 0 to pNode.DupNodes.ListLinks.Count-1 do begin
  Node:= TLink(pNode.DupNodes.ListLinks[i]).LinkPtr;
  prMessageLOGS(nmProc+': ------- '+IntToStr(Node.ID)+' - '+Node.Name, fLogDebug, false);
end; }
    end; //  while not ORD_IBS.Eof
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
  prFreeIBSQL(ORD_IBS);
  cntsOrd.SetFreeCnt(ORD_IBD);
  prFree(TempList);
  prMessageLOGS(nmProc+': '+IntToStr(j)+' ����� - '+GetLogTimeStr(TimeProc), fLogCache, false);
{if flDebug then for i:= 0 to MotulTreeNodes.ItemsList.Count-1 do begin
  pNode:= MotulTreeNodes.ItemsList[i];
  prMessageLOGS(nmProc+': '+IntToStr(pNode.TypeSys)+' - '+IntToStr(pNode.ID)+' - '+pNode.Name, fLogDebug, false);
  Code:= pNode.ID;
  pNode:= MotulTreeNodes[Code];
  prMessageLOGS(nmProc+': other - '+IntToStr(pNode.ID)+' - '+pNode.Name, fLogDebug, false);
end;   }
  TestCssStopException;
end;

//==== ���������� ������� ������� ����.������ ������ �� ���� � ������������ ����
procedure SetHasPLsModelNodeParentLinks(Model: TModelAuto; NodeID: Integer; fHas: Boolean=True);
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

      if (link.NodeHasPLs=fHas) then Continue; // ���� ������� ���, ��� ����

      link.NodeHasPLs:= fHas;                   // ������ ������ ������� �������
      Node:= GetLinkPtr(link);                    // ������ �� ����
      if not Assigned(Node) then Continue;

      if fHas and not Node.Visible then fHas:= False; // �� ��������� ��������� ��� ������� True �� �����������

      repeat  // ������������ ��������� �������� ����� �� ������
        i:= Node.ParentID;
        link:= mlinks[i];                         // ������ � ����� ��������
        if not Assigned(link) then break;
        if (link.NodeHasPLs=fHas) then break;     // ���� ������� ������� ������ - ������ ����� �� ������ �� ����
        Node:= GetLinkPtr(link);                  // ������ �� ���� ��������
        if not Assigned(Node) then break;

        if not fHas and Assigned(Node.Children) then // ���� ����� �������
          with Node.Children do begin                // ��������� ����� ������������ ����
            fbreak:= False;                          // ���� ��� ������ �� 2-� ������
            for j:= 0 to Count-1 do begin
              ci:= TAutoTreeNode(Objects[j]).ID;     // ��� ������
              fbreak:= mlinks.LinkExists(ci) and     // ���� ���� ���� �� ���� � ������ ��������� - �������
                (TSecondLink(mlinks[ci]).NodeHasPLs<>fHas);
              if fbreak then break;                  // ������� �� for
            end;
            if fbreak then break;                    // ������� �� repeat
          end; // with Node.Children

        link.NodeHasPLs:= fHas; // ������ ������ ������� ������� ����� �� ���� ��������
      until i<0;
    end; // for ii:= High(codes) downto 0
  finally
    setLength(codes, 0);
  end;
end;

//========================== ��������/����������/�������������� ������ 3 (Motul)
function TDataCache.CheckPLineModelNodeLink(PlineID, ModelID, NodeID: Integer;
         var ResCode: Integer; pCount: Single=-1; prior: Integer=-1; userID: Integer=0): string;
const nmProc = 'CheckPLineModelNodeLink';
// ��� �������� - ResCode - �� ����� (resAdded, resEdited, resDeleted)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������,
// resAdded - ���������, resEdited - ��������, resDeleted - �������
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    OpCode, i, j: Integer;
    Model: TModelAuto;
    Node: TMotulNode;
    mess: string;
    pl: TProductLine;
    fl: Boolean;
    link2: TSecondLink;
//    Nodes: TAutoTreeNodes;
//    aNode: TAutoTreeNode;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  OpCode:= ResCode;
  ResCode:= resError;
  ORD_IBD:= nil;
  ORD_IBS:= nil;
  fl:= False;
  try
    if not (OpCode in [resAdded, resEdited, resDeleted]) then // ��������� ��� ��������
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');

    if (OpCode in [resAdded, resEdited]) and (userID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����');

    if not FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));

    if not MotulTreeNodes.MotulNodeGet(NodeID, Node) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));

    pl:= ProductLines.GetProductLine(PlineID);
    if not Assigned(pl) then
      raise EBOBError.Create('�� ������� ����.�������, ��� - '+IntToStr(PlineID));

    Model:= FDCA.Models.GetModel(ModelID);
    if (Model.TypeSys<>Node.TypeSys) then
      raise EBOBError.Create('������� ������ � ���� �� ���������');

//--------------------------------------------------- ������������ ������ � ����
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select ResCode from CheckModelNodePLineLink('+
        IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(PlineID)+
        ', :aCount, '+IntToStr(prior)+', '+IntToStr(UserID)+', '+IntToStr(OpCode)+')';
      ORD_IBS.ParamByName('aCount').AsFloat:= pCount;
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Bof and ORD_IBS.Eof) then
        raise EBOBError.Create(MessText(mtkErrAddRecord))
      else ResCode:= ORD_IBS.FieldByName('ResCode').AsInteger;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
//------------------------------------------------------------- �����
    mess:= '������ '; // ������-����-����.�������
    case ResCode of
      resDoNothing: Result:= mess+'�� ����������';
      resAdded    : Result:= mess+'���������';
      resDeleted  : Result:= mess+'�������';
      resEdited   : Result:= mess+'��������';
    end;
//---------------------------------------------------- ��������� �������� � ����
    if (ResCode=resAdded) then try
      if not Model.ModelHasPLs then try  //---------- � ������
        FDCA.Models.CS_Models.Enter;
        Model.ModelHasPLs:= True;
      finally
        FDCA.Models.CS_Models.Leave;
      end;                               //---------- � ������ ��������� �������
      for i:= 0 to Node.DupNodes.ListLinks.Count-1 do begin
        j:= GetLinkID(Node.DupNodes.ListLinks[i]);
        link2:= Model.NodeLinks[j];
        if not Assigned(link2) then Continue;

        if not link2.NodeHasPLs then
          // ���������� ������� ������� ����.������ ������ �� ���� � ������������ ����
          SetHasPLsModelNodeParentLinks(Model, j);
{        try
          Model.NodeLinks.CS_links.Enter;
          link2.NodeHasPLs:= True;
        finally
          Model.NodeLinks.CS_links.Leave;
        end; }
      end; // for i:= 0 to Node.DupNodes.ListLinks.Count-1

      case Model.TypeSys of              //---------- � ����.�������
        constIsAuto: fl:= not pl.HasModelAuto;
        constIsMoto: fl:= not pl.HasModelMoto;
        constIsCV  : fl:= not pl.HasModelCV;
        constIsAx  : fl:= not pl.HasModelAx;
//        else fl:= False;
      end;
      if fl then try
        Cache.CScache.Enter;
        case Model.TypeSys of
          constIsAuto: pl.HasModelAuto:= True;
          constIsMoto: pl.HasModelMoto:= True;
          constIsCV  : pl.HasModelCV:= True;
          constIsAx  : pl.HasModelAx:= True;
        end;
      finally
        Cache.CScache.Leave;
      end;
    except
      on E: Exception do prMessageLOGS(nmProc+'_cache_add: '+E.Message, fLogCache);
    end; // if (ResCode=resAdded)

  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= CutEMess(E.Message, ResCode);
  end;
end;
//====================== ��������/���������� ������� ���������� ������ 3 (Motul)
function TDataCache.CheckPLineModelNodeUsage(PlineID, ModelID, NodeID: Integer;
         UsageName, UsageValue: String; var ResCode: Integer; userID: Integer=0): string;
const nmProc = 'CheckPLineModelNodeUsage';
// ��� �������� - ResCode - �� ����� (resAdded, resDeleted)
// ResCode �� ������: resError- ������, resDoNothing - �� ��������,
// resAdded - ���������, resDeleted - �������
// UsageName - �������� �������� �������, UsageValue - �������� �������� �������
var OpCode: Integer;
    Model: TModelAuto;
    mess: string;
    ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    Node: TMotulNode;
    pl: TProductLine;
begin
  Result:= '';
  OpCode:= ResCode;
  ResCode:= resError;
//  ORD_IBD:= nil;
  ORD_IBS:= nil;
  try
    if not (OpCode in [resAdded, resDeleted]) then // ��������� ��� ��������
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');

    if (OpCode=resAdded) and (userID<1) then  // ���� ���������� - ��������� userID
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����');

    if not FDCA.Models.ModelExists(ModelID) then              // ��������� ������
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));

    if not MotulTreeNodes.MotulNodeGet(NodeID, Node) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));

    pl:= ProductLines.GetProductLine(PlineID);
    if not Assigned(pl) then
      raise EBOBError.Create('�� ������� ����.�������, ��� - '+IntToStr(PlineID));

    Model:= FDCA.Models.GetModel(ModelID);
    if (Model.TypeSys<>Node.TypeSys) then
      raise EBOBError.Create('������� ������ � ���� �� ���������');

    ORD_IBD:= cntsOrd.GetFreeCnt; //---------------------------- ������ � ����
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select ResCode from CheckModelNodePLineUsageLink('+
        IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(PlineID)+
        ', :CriName, :CriValue, '+IntToStr(OpCode)+', '+IntToStr(UserID)+')';
      ORD_IBS.ParamByName('CriName').AsString:= UsageName;
      ORD_IBS.ParamByName('CriValue').AsString:= UsageValue;
      ORD_IBS.ExecQuery;
      if (ORD_IBS.Bof and ORD_IBS.Eof) then
        raise EBOBError.Create(MessText(mtkErrAddRecord))
      else ResCode:= ORD_IBS.FieldByName('ResCode').AsInteger;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
//------------------------------------------------------------- �����
    mess:= '������� ���������� ';
    case ResCode of
      resDoNothing: Result:= mess+'�� ����������';
      resAdded    : Result:= mess+'���������';
      resDeleted  : Result:= mess+'�������';
      resEdited   : Result:= mess+'��������';
    end;
//------------------------------------------------------------- ������������ ���
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= CutEMess(E.Message, ResCode);
  end;
end;

//******************************************************************************
//                              TCredProf
//******************************************************************************
constructor TCredProfile.Create(pID, pCurr, pDelay: Integer; pName: String; pLimit, pDebt: Single);
begin
  inherited Create(pID, pName);
  FProfCredCurrency:= pCurr;
  FProfCredDelay:= pDelay;
  FProfCredLimit:= pLimit;
  FProfDebtAll:= pDebt;
  Disabled:= False;
end;

//******************************************************************************
initialization
begin
  ZeroCredProfile:= TCredProfile.Create(0, cDefCurrency, 0, '', 0, 0);
end;
finalization
begin
  prFree(ZeroCredProfile);
end;
//******************************************************************************

end.

