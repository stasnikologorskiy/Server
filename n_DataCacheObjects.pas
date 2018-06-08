unit n_DataCacheObjects;

interface
uses Classes, Types, SysUtils, SyncObjs, Contnrs, Math, n_free_functions;

const
  LCharGood   = ',';  // Char ���� TStringList �� ������� ����������
  LCharUpdate = '!';  // Char ���� TStringList ��������� ��������

type
  TASL = array of TStringList; // ������ �������

  TListState = (lsEmpty, lsAllow, lsUpdate);
  T8InfoKinds  = (ik8_1, ik8_2, ik8_3, ik8_4, ik8_5, ik8_6, ik8_7, ik8_8);        //  8 �������� (1 ����)
  T16InfoKinds = (ik16_1, ik16_2, ik16_3, ik16_4, ik16_5, ik16_6, ik16_7, ik16_8, // 16 �������� (2 �����)
                  ik16_9, ik16_10, ik16_11, ik16_12, ik16_13, ik16_14, ik16_15, ik16_16);
  TLLKind = (lkDirNone, lkDirByID, lkLnkNone, lkLnkByID); // ���������� TLinkList � ��� ���������
// lkDir... - �������� �����������, lkLink... - �����
// ...None - ��� ����������, ...ID - ���������� �� ID, ...Name - ���������� �� Name

//----------------------------------------------------------- ������ �� ��������
{  TCacheList = Class (TList)        // ���������
  private
    FListState: TListState;
    FItemClass: TClass;
    procedure SetState(NewState: TListState);
  public
    constructor Create(aClass: TClass=nil);
    function GetItemVisible(index: Integer): Boolean;
    function CheckItemClass(aClass: TClass): Boolean;
    property ListState: TListState read FListState write SetState;
    property ItemClass: TClass     read FItemClass write FItemClass;
  end;
}

//---------------------------------------------------------------- ������ ������
  TLinkList = class(TList)
  protected
    function GetLinkListItemIndexByID(pID: Integer; lkind: TLLKind): Integer; // ����� ������ �������� �� ����
    function GetLinkCount: Integer;
  public
    function GetLinkListItemByID(pID: Integer; lkind: TLLKind): Pointer;      // ����� ������� �� ����
    function LinkListItemExists(pID: Integer; lkind: TLLKind): Boolean; // �������� ������������� �������� �� ����

    function GetIndexForInsItem(pItem: Pointer; lkind: TLLKind;     //
             Compare: TListSortCompare=nil): Integer;
    function AddLinkListItem(pItem: Pointer; lkind: TLLKind;     // �������� ������� (���������� ������)
             CS: TCriticalSection; Compare: TListSortCompare=nil): Integer;
    function DelLinkListItemByID(pID: Integer; lkind: TLLKind;   // ������� ������� �� ���� (���������� ������)
             CS: TCriticalSection; Compare: TListSortCompare=nil): Integer; virtual;
//    procedure FreeUnusedMem(CS: TCriticalSection); virtual; // ���������� ������ ������

    procedure SetLinkStates(pState: Boolean; CS: TCriticalSection); // ������������� ���� �������� ���� �������
    procedure DelNotTestedLinks(CS: TCriticalSection);              // ������� ��� ������ � State=False
    procedure ClearLinks(CS: TCriticalSection=nil);                 // ������ ��������� �����

    function GetLinkListCodes(lkind: TLLKind): Tai;         // �������� ������ ����� ����.���������
    property LinkCount: Integer read GetLinkCount;          // ���-�� ������ (��� ������������� � TLinks)
  end;
(*
//------------------------------ ������ ������ � ������������ ������� ����������
  TSrcLinkList = class(TLinkList)
  protected
    FarSrc: TByteDynArray;
    procedure TestSrcLength(CS: TCriticalSection; cutByCap: Boolean=False); // ��������� ����� ������� ����������
    function NotAllowSrcIndex(pIndex: Integer; CS: TCriticalSection): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function CheckSrcLinkListItem(pID: Integer; pSrcID: Byte; pPtr: Pointer; // ��������� / �������� ������� (���������� ������)
             lkind: TLLKind; CS: TCriticalSection; Compare: TListSortCompare=nil): Integer;
    procedure AddSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection);   // �������� �������� �� �������
    procedure CheckSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection); // ��������� �������� �� �������
    function DelLinkListItemByID(pID: Integer; lkind: TLLKind;                      // ������� ������� �� ���� (���������� ������)
             CS: TCriticalSection; Compare: TListSortCompare=nil): Integer; override;
//    procedure FreeUnusedMem(CS: TCriticalSection); override; // ���������� ������ ������
    property arItemSrc: TByteDynArray read FarSrc;
  end;
*)
//----------------------------------------------------------------------- ������
  TLink = Class (TObject) // ������� ����
  protected
    FLinkPtr: Pointer;
    FSrcID  : Byte;
    FLinkOpts: set of T8InfoKinds;
    function GetLinkItemID: Integer;
    function GetLinkBool(ik: T8InfoKinds): boolean;         // �������� �������
    procedure SetLinkBool(ik: T8InfoKinds; Value: boolean); // �������� �������
  public
    constructor Create(pSrcID: Integer; pLinkPtr: Pointer);
    destructor Destroy; override;
    property LinkID : Integer read GetLinkItemID;           // ��� ���������� ��������
    property SrcID  : Byte    read FSrcID write FSrcID;     // ��� ��������� �����
    property State  : boolean index ik8_1 read GetLinkBool write SetLinkBool; // ������� ��������
    property LinkPtr: Pointer read FLinkPtr write FLinkPtr; // ������ �� ��������� �������
  end;

//-----------------------------
  TLinkLink = Class (TLink) // ���� � ������� �������� ������
  protected
    FDoubleLinks: TLinkList; // Create � CheckDoubleLink
  public
    constructor Create(pSrcID: Integer; pLinkPtr: Pointer);
    destructor Destroy; override;
    procedure CheckDoubleLinks(CS: TCriticalSection);
    property DoubleLinks: TLinkList read FDoubleLinks;     // ������� ������
  end;
//-----------------------------
  TQtyLink = Class (TLink) // ���� � �����������
  protected
    FQty: Single;
  public
    constructor Create(pSrcID: Integer; pQty: Single; pLinkPtr: Pointer);
    property Qty: Single read FQty write FQty;       // ����������
  end;
//-----------------------------
  TTwoLink = Class (TLink) // ���� � 2-�� ��������
  protected
    FLinkPtrTwo: Pointer;
    function GetLinkTwoItemID: Integer;
  public
    constructor Create(pSrcID: Integer; pLinkPtr, pLinkPtrTwo: Pointer);
    property LinkTwoID : Integer read GetLinkTwoItemID;              // ��� 2-�� ���������� ��������
    property LinkPtrTwo: Pointer read FLinkPtrTwo write FLinkPtrTwo; // ������ �� 2-� ��������� �������
  end;
//-----------------------------
  TFlagLink = Class (TLink) // ���� � ���.���������
  public
    constructor Create(pSrcID: Integer; pLinkPtr: Pointer; pFlag: Boolean);
    property Flag: boolean index ik8_2 read GetLinkBool write SetLinkBool; // ���.�������
  end;

//-----------------------------
  TLinks = Class (TObject) // ����� ������ � �����-���� ������������
  protected
    FItems: TList;            // ������ ������ �� �����
    function GetLinkItemByID(pID: Integer): Pointer; virtual; // �������� ���� �� ���� ���������� ��������
    function GetLinkCount: Integer;
    procedure ListGrow(addCount: Integer=1);
  public
    CS_links: TCriticalSection; // ������ �� CriticalSection - �������� ��� �����
    constructor Create(CS: TCriticalSection=nil);
    destructor Destroy; override;
    property Items[ID: Integer]: Pointer read GetLinkItemByID; default; // ������ � ������ �� ���� ���������� ��������
    property ListLinks: TList read FItems;                 // ������ ������ �� ������ (���� ���� ��������� ������)
    property LinkCount: Integer read GetLinkCount;         // ���-�� ������

    function LinkExists(ID: Integer): Boolean;               // �������� ������������� ������
    function GetLinkCodes: Tai;                              // ������ ����� �������� 1-� ������
    procedure SortByLinkName;                                // ��������� ������ �� ����� ����.��������
    procedure SortByLinkOrdNumAndName;                       // ��������� ������ �� ���.� � ����� ����.�������� (TSubDirItem)
    procedure LinkSort(Compare: TListSortCompare);           // ��������� ������ �� ��������� ���������
    function GetLinkItemByName(pName: String): Pointer;      // ���������� ������ �� ������� � ������������� pName, ���� ��� - nil

    procedure SetLinkStates(pState: Boolean);                // ������������� ���� �������� ���� �������
    procedure DelNotTestedLinks;                             // ������� ��� �������� � State=False

    function AddLinkItem(NewItem: Pointer): Integer;            // ���������� ������
    function AddLinkItems(NewItems: TList): Integer; virtual;   // ���������� ������ ������
    function InsertLink(NewItem, BeforeItem: Pointer): Boolean; // ������� ������ NewItem ����� ������� BeforeItem
    function CheckLink(pLinkID, pSrcID: Integer; pLinkPtr: Pointer): Pointer; virtual; // ���������� / �������� ������
    procedure DeleteLinkItem(Item: Pointer); overload; // �������� ������ �� ������ �� ������
    procedure DeleteLinkItem(ID: Integer); overload;   // �������� ������ �� ���� ����.��������

    procedure FreeAddMem; // ���������� ������ ������
  end;

//-----------------------------
  TLinkLinks = Class (TLinks) // ����� ������� ������ � �����-���� ������������
  public
    destructor Destroy; override;
    function DoubleLinkExists(ID1, ID2: Integer): Boolean; overload;           // �������� ������������� 2-� ������ �� ����� ����.���������
    function DoubleLinkExists(Item: Pointer; ID2: Integer): Boolean; overload; // �������� ������������� 2-� ������ �� ������ �� 1-� ������ � ���� ����.�������� 2-�
    function GetDoubleLinks(ID: Integer): TLinkList; overload;   // ������� ������ 1-� ������ �� ���� ����.��������
    function GetDoubleLinks(Item: Pointer): TLinkList; overload; // ������� ������ 1-� ������ �� ������ �� ������
  end;

//------------------------------------------------------------------- ����������
  TBaseDirItem = Class (TObject) //========= ������� ������� �����������
  protected
    FID   : Integer;   // ���
    FName : String;    // ������������
    FDirBoolOpts: set of T8InfoKinds; // ��������
    function GetName: String; virtual;               // �������� FName
    procedure SetName(const Value: String); virtual; // �������� FName
    function GetDirBool(const ik: T8InfoKinds): boolean;         // �������� �������
    procedure SetDirBool(const ik: T8InfoKinds; Value: boolean); // �������� �������
  public
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    property ID   : Integer read FID;                                     // ���
    property Name : String  read GetName write SetName;                   // ������������
    property State: boolean index ik8_1 read GetDirBool write SetDirBool; // ������ ��������
  end;
//-----------------------------
  TDirItem = Class (TBaseDirItem) //========= ������� ����������� �� ��������
  protected
    FLinks: TLinks;    // ����� ������ � ������ ������������
  public
    constructor Create(pID: Integer; pName: String; WithLinks: Boolean=False);
    destructor Destroy; override;
    property Links: TLinks  read FLinks; // ����� ������ (��� WithLinks=False = nil)
  end;
//-----------------------------
  TSubDirItem = Class (TDirItem) //============ ������� ����������� � ���.������
  protected
    FSrcID   : Byte;    // �������� ������
    FOrderNum: Integer; // ������.�
    FSubCode : Integer; // ���.��� (��� TecDoc ��� ���, ������ � �.�.)
  public
    constructor Create(pID, pSubCode, pOrderNum: Integer; pName: String;
                       pSrcID: Integer=0; WithLinks: Boolean=False);
    property SubCode : Integer read FSubCode  write FSubCode;  // ���.���
    property OrderNum: Integer read FOrderNum write FOrderNum; // ������.�
    property SrcID   : Byte    read FSrcID    write FSrcID;    // �������� ������
  end;
//-----------------------------
  TSubVisDirItem = Class (TSubDirItem) // ������� ����������� � ��������� ��������� � Parent �����
  protected
    FParCode  : Integer;   // Parent ���
  public
    property ParCode  : Integer read FParCode;   // Parent ���
    property IsVisible: boolean index ik8_2 read GetDirBool write SetDirBool; // ������� ���������
  end;
//-----------------------------
  TDirItems = Class (TObject) //========= ����� ��������� ����������� (Index=ID)
  protected
    FSetLengthStep: Integer;          // ���������� ����� ������� ��� ���������� ��������� (def 10)
    FItems        : array of Pointer; // ����������� ������ ������ �� �������� �����������
    FItemsList    : TList;            // ������ ������ �� �������� (��� ���������� � ������ �������)
    function GetCount: Integer;
    function GetMaxCode: Integer;
    function GetItem(pIndex: Integer): Pointer;
  public
    CS_DirItems: TCriticalSection;
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    function ItemExists(pID: Integer): Boolean;        // �������� ������������� �������� ����������� �� ����
    function GetDirCodes: Tai;                         // ������ ����� ��������� �����������
    procedure SortDirListByName;                       // ��������� ������ ������ �� ����� ��������
    procedure SortDirListByOrdNumAndName;              // ��������� ������ ������ �� ���.� � ����� ����.��������
    procedure DirSort(Compare: TListSortCompare);      // ��������� ������ ������ �� ��������� ���������
    function CheckItem(var NewItem: Pointer): Boolean; // ���������� / �������� ��������
    procedure CheckLength;                             // �������� ����� �� ������������� ����
    function DeleteItem(pID: Integer): Boolean;        // �������� ��������
    function GetItemName(pID: Integer): String;        // ���������� ������������ ��������
    procedure SetItemName(pID: Integer; pName: String);  // �������� ������������ ��������
    function GetDirItem(pIndex: Integer): TDirItem;         // ���������� ������� � �����-�������� pIndex, ���� ��� - 0-�
    function GetIDBySubCode(pSubCode: Integer): Integer; virtual; // �������� ID �� SubCode
//    function GetIDByName(pName: String): Integer; virtual;  // �������� ID �� �����
    function GetListSubCodeItems(pSubCode: Integer): TList; // ������ ��������� � SubCode=pSubCode
    procedure SetDirStates(pState: Boolean);                // ������������� ���� �������� ���� ��������� � �� ������
    procedure DelDirNotTested;                              // ������� ��� ������������� ��������
    property DirItems[index: Integer]: Pointer read GetItem; default; // �������� ������ �� ������� ����������� �� ����
    property Count    : Integer read GetCount;         // ���-�� ��������� �����������
    property ItemsList: TList read FItemsList;         // ������ ������ �� ��������
    property MaxCode  : Integer read GetMaxCode;       // ������������ ��� ��������� �����������
  end;

//=================== ����� ��������� ����������� (Index=ID) �� ����� ����������
  TOwnDirItems = Class (TDirItems)
  protected
    FFreeCode: Integer; // ��������� ���
    function GetCode: Integer;
  public
    constructor Create(LengthStep: Integer=10);
    function AddItem(var NewItem: Pointer): Boolean; // ���������� �������� � ���������� ����
    function FindByName(pName: String; var FindItem: Pointer): Boolean;
//    function FindBySubCode(SubID: Integer; var FindItem: Pointer): Boolean;
  end;

//-----------------------------
  TDirObjects = Class (TObjectList) //========= ����� ��������� ����������� (Object-TBaseDirItem)
  protected
    function GetObjItem(pID: Integer): TObject;
  public
    CS_DirObj: TCriticalSection;
    constructor Create;
    destructor Destroy; override;
//    function ItemExists(pID: Integer): Boolean;
    function FindObjItem(pID: Integer; var obj: TObject): Boolean; // ����� �������� ����������� �� ����
    procedure SetDirStates(pState: Boolean);    // ������������� ���� �������� ���� ��������� � �� ������
    procedure DelDirNotTested;                  // ������� ��� ������������� ��������
    property ObjItems[index: Integer]: TObject read GetObjItem; // default; �������� ������ �� ������� ����������� �� ����
  end;

//------------------------------------------------------- ����� ������� �� �����
  TArrayTypeLists = Class (TObject)
  private
    FSortList: Boolean;                                 // ������� ���������� ���� �������
    function GetTypeList(TypeID: Word): TStringList;    // �������� ������ ������� ���� (� Objects - ��� ��������)       
    function GetListTypes: TStringList;                 // = FarLists[0] - ����� ����� ������� (� Objects - ID>0)
  protected
    FDelimiterFlag: Boolean;                            // Delimiter - ���� ���������
    FarLists: TASL;                                     // ������ �������
  public
    CS_ATLists: TCriticalSection;
    constructor Create(fSorted: Boolean=False; fDelimiter: Boolean=False);
    destructor Destroy; override;
    property Items[TypeID: Word]: TStringList read GetTypeList; default;     // ������ ������� ����
    property ListTypes: TStringList read GetListTypes;                       // ����� ����� �������
    property SortList : Boolean     read FSortList write FSortList;          // ������� ���������� ���� �������
    function GetListTypesCount: Word;                                        // ���-�� ����� �������
    function GetTypeListCount(TypeID: Word): Integer;                        // ���-�� ��������� � ������ ������� ����
    function CheckTypeOfList(TypeID: Word): boolean;                         // ��������� ��� ����
    function TypeOfListExists(TypeID: Word): boolean;                        // ��������� ������������� ������
    function AddTypeOfList(TypeID: Word; TypeName: String): boolean;         // �������� ��� ������
    procedure ClearTypeList(TypeID: Word);                                   // �������� ������
    procedure SetTypeListDelimiter(TypeID: Word; delim: Char);               // �������� Delimiter
    function AddTypeListItems(TypeID: Word; list: TStringList; fClear: Boolean=False): boolean; // �������� ����� ��������� � ������ ����
    // ���� � Objects - ID
    function GetTypeListItemIDByName(TypeID: Word; pName: String): Integer;                 // ����� ��� �������� �� ������ �� �����
    function TypeListItemExists(TypeID: Word; pID: Integer): boolean; overload;             // ��������� ������������� �������� ������
    function AddTypeListItem(TypeID: Word; pID: Integer; pName: String): boolean; overload; // �������� ������� � ������
    function DelTypeListItem(TypeID: Word; pID: Integer): boolean; overload;                // ������� ������� �� ������
    // ���� � Objects - ������ �� ������
    function TypeListItemExists(TypeID: Word; p: Pointer): boolean; overload;             // ��������� ������������� �������� ������
    function AddTypeListItem(TypeID: Word; p: Pointer; pName: String): boolean; overload; // �������� ������� � ������
    function DelTypeListItem(TypeID: Word; p: Pointer): boolean; overload;                // ������� ������� �� ������
  end;

var EmptyStringList: TStringList; // ������ TStringList - ����� �� ���������� nil
    EmptyIntegerList: TIntegerList; // ������ TIntegerList - ����� �� ���������� nil
    EmptyList: TList;             // ������ TList - ����� �� ���������� nil
    CS_any: TCriticalSection;     // ����� TCriticalSection ��� ��������� ������
//                          �����������
  function GetDirItemID(Item: Pointer): Integer;      // ID �������� TSubDirItem
  function GetDirItemName(Item: Pointer): String;     // ��� �������� TSubDirItem
  function GetDirItemOrdNum(Item: Pointer): Integer;  // ���.� �������� TSubDirItem
  function GetDirItemSubCode(Item: Pointer): Integer; // SubCode �������� TSubDirItem
  function GetDirItemSrc(Item: Pointer): Integer;     // SrcID �������� TSubDirItem
//                          ������
  function GetLinkID(link: Pointer): Integer;         // ID ����.�������� �� ������ �� ������
  function GetLinkName(link: Pointer): String;        // ��� ����.�������� �� ������ �� ������
  function GetLinkPtr(link: Pointer): Pointer;        // ������ �� ����.������� �� ������ �� ������
  function GetLinkSrc(link: Pointer): Integer;        // �������� ����.�������� �� ������ �� ������
  function GetLinkQty(link: Pointer): Double;         // ���-�� �� ������ �� ������
 procedure SetLinkQty(link: Pointer; pQty: Double; cs: TCriticalSection); // ����� ���-�� �� ������ �� ������
//                          ����������
  function LinkNameSortCompare(Item1, Item2: Pointer): Integer;    // ���������� ������ �� ������. ����.�������
  function LinkNumNameSortCompare(Item1, Item2: Pointer): Integer; // ���������� ������ �� ���.� + ������. ����.������� TSubDirItem
  function DirNameSortCompare(Item1, Item2: Pointer): Integer;     // ���������� TList �� ������. ������� TBaseDirItem
  function DirNumNameSortCompare(Item1, Item2: Pointer): Integer;  // ���������� TList �� ���.� + ������. ������� TSubDirItem
  function DirNumNameSortCompareSL(List: TStringList; Index1, Index2: Integer): Integer; // ���������� TStringList (Objects-TSubDirItem) �� ���.� + ������.

implementation
//******************************************************************************
//                          ����������
//******************************************************************************
//================================ ���������� TList �������� TDirItem �� ������.
function DirNameSortCompare(Item1, Item2: Pointer): Integer;
begin
  try
    Result:= AnsiCompareText(GetDirItemName(Item1), GetDirItemName(Item2));
  except
    Result:= 0;
  end;
end;
//===================== ���������� TList �������� TSubDirItem �� ���.� + ������.
function DirNumNameSortCompare(Item1, Item2: Pointer): Integer;
var p1, p2: TSubDirItem;
    i1, i2: Integer;
begin
  try
    p1:= Item1;
    p2:= Item2;
    i1:= p1.OrderNum;
    i2:= p2.OrderNum;
    if i1=i2 then Result:= AnsiCompareText(p1.Name, p2.Name)
    else if i1<i2 then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;
//======================== ���������� TList ������ �� ������. ���������� �������
function LinkNameSortCompare(Item1, Item2: Pointer): Integer;
begin
  try
    Result:= AnsiCompareText(GetLinkName(Item1), GetLinkName(Item2));
  except
    Result:= 0;
  end;
end;
//======== ���������� TList ������ �� ���.� � ������. ����.������� (TSubDirItem)
function LinkNumNameSortCompare(Item1, Item2: Pointer): Integer;
var p1, p2: TSubDirItem;
    i1, i2: Integer;
begin
  try
    p1:= GetLinkPtr(Item1);
    p2:= GetLinkPtr(Item2);
    i1:= p1.OrderNum;
    i2:= p2.OrderNum;
    if i1=i2 then Result:= AnsiCompareText(p1.Name, p2.Name)
    else if i1<i2 then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;
//============ ���������� TStringList (Objects-TSubDirItem) �� ������.� +������.
function DirNumNameSortCompareSL(List: TStringList; Index1, Index2: Integer): Integer;
var i1, i2: integer;
begin
  with List do try
    i1:= TSubDirItem(Objects[Index1]).OrderNum;
    i2:= TSubDirItem(Objects[Index2]).OrderNum;
    if i1=i2 then Result:= AnsiCompareText(Strings[Index1], Strings[Index2])
    else if i1<i2 then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end;

//******************************************************************************
//                          �����������
//******************************************************************************
//========================================================= ID �������� TDirItem
function GetDirItemID(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TBaseDirItem(Item).ID;
end;
//======================================================== ��� �������� TDirItem
function GetDirItemName(Item: Pointer): String;
begin
  if not Assigned(Item) then Result:= '' else Result:= TBaseDirItem(Item).Name;
end;
//=================================================== ���.� �������� TSubDirItem
function GetDirItemOrdNum(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TSubDirItem(Item).OrderNum;
end;
//================================================= SubCode �������� TSubDirItem
function GetDirItemSubCode(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TSubDirItem(Item).SubCode;
end;
//=================================================== SrcID �������� TSubDirItem
function GetDirItemSrc(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TSubDirItem(Item).SrcID;
end;

//******************************************************************************
//                          ������
//******************************************************************************
//================================== ��� ���������� �������� �� ������ �� ������
function GetLinkID(link: Pointer): Integer;
begin
  if not Assigned(link) then Result:= 0 else Result:= TLink(link).LinkID;
end;
//================================== ��� ���������� �������� �� ������ �� ������
function GetLinkName(link: Pointer): String;
begin
  if not Assigned(link) then Result:= '' else Result:= GetDirItemName(GetLinkPtr(link));
end;
//============================== ������ �� ��������� ������� �� ������ �� ������
function GetLinkPtr(link: Pointer): Pointer;
begin
  if not Assigned(link) then Result:= nil else Result:= TLink(link).LinkPtr;
end;
//============================= �������� ���������� �������� �� ������ �� ������
function GetLinkSrc(link: Pointer): Integer;
begin
  if not Assigned(link) then Result:= 0 else Result:= TLink(link).SrcID;
end;
//=================================================== ���-�� �� ������ �� ������
function GetLinkQty(link: Pointer): Double;
begin
  Result:= 0;
  if not Assigned(link) then Exit;
  try
    Result:= TQtyLink(link).Qty;
  except end;  
end;
//============================================= ����� ���-�� �� ������ �� ������
procedure SetLinkQty(link: Pointer; pQty: Double; cs: TCriticalSection);
begin
  if not Assigned(link) then Exit;
  cs.Enter;
  try
    TQtyLink(link).Qty:= pQty;
  finally
    cs.leave;
  end;
end;

//******************************************************************************
//                          TArrayTypeLists
//******************************************************************************
constructor TArrayTypeLists.Create(fSorted: Boolean=False; fDelimiter: Boolean=False);
begin
  inherited Create;
  FSortList:= fSorted;
  FDelimiterFlag:= fDelimiter;
  SetLength(FarLists, 1);
  FarLists[0]:= TStringList.Create; // ����� ����� ������� (� Objects - ID>0)
  FarLists[0].Sorted:= FSortList;
  CS_ATLists:= TCriticalSection.Create;
end;
//==============================================================================
destructor TArrayTypeLists.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= Low(FarLists) to High(FarLists) do
    if Assigned(FarLists[i]) then try prFree(FarLists[i]); except end;
  SetLength(FarLists, 0);
  prFree(CS_ATLists);
  inherited Destroy;
end;
//========================================================= ���-�� ����� �������
function TArrayTypeLists.GetListTypesCount: Word;
begin
  if not Assigned(self) then Result:= 0 else Result:= FarLists[0].Count;
end;
//======================================== ���-�� ��������� � ������ ���� TypeID
function TArrayTypeLists.GetTypeListCount(TypeID: Word): Integer;
begin
  if not Assigned(self) then Result:= 0 else Result:= FarLists[TypeID].Count;
end;
//========================================== ��������� ������������� ���� TypeID
function TArrayTypeLists.CheckTypeOfList(TypeID: Word): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= FarLists[0].IndexOfObject(Pointer(TypeID))>-1;
end;
//======================================= �������� ������ �� ����� ����� �������
function TArrayTypeLists.GetListTypes: TStringList;
begin
  if not Assigned(self) then Result:= EmptyStringList else Result:= FarLists[0];
end;
//======================================== �������� ������ �� ������ ���� TypeID
function TArrayTypeLists.GetTypeList(TypeID: Word): TStringList;
begin
  if Assigned(self) and TypeOfListExists(TypeID) then Result:= FarLists[TypeID]
  else Result:= EmptyStringList;
end;
//=================================== ��������� ������������� ������ ���� TypeID
function TArrayTypeLists.TypeOfListExists(TypeID: Word): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= (TypeID>0) and (TypeID<Length(FarLists)) and Assigned(FarLists[TypeID]);
end;
//========================================================== �������� ��� ������
function TArrayTypeLists.AddTypeOfList(TypeID: Word; TypeName: String): boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  CS_ATLists.Enter;
  try
    if not CheckTypeOfList(TypeID) then FarLists[0].AddObject(TypeName, Pointer(TypeID));
    if TypeOfListExists(TypeID) then Exit;
    if High(FarLists)<TypeID then SetLength(FarLists, TypeID+1);
    FarLists[TypeID]:= TStringList.Create;
    FarLists[TypeID].Sorted:= FSortList;
    if FDelimiterFlag then FarLists[TypeID].Delimiter:= LCharUpdate;
  finally
    CS_ATLists.Leave;
  end;
end;
//================================ �������� ����� ��������� � ������ ���� TypeID
function TArrayTypeLists.AddTypeListItems(TypeID: Word; list: TStringList; fClear: Boolean=False): boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) or not TypeOfListExists(TypeID) then Exit; // ������ ���� ���
  CS_ATLists.Enter;
  try
    with GetTypeList(TypeID) do begin
      if FDelimiterFlag then Delimiter:= LCharUpdate;
      if FSortList then Sorted:= False; // ��������� ����������
      if fClear then Clear;
      if list.Count>0 then begin
        Capacity:= Capacity+list.Count;
        for i:= 0 to list.Count-1 do AddObject(list.Strings[i],list.Objects[i]);
      end;
      if FSortList then begin
        if Count>1 then Sort;
        Sorted:= True;  // �������� ����������
      end;
      if FDelimiterFlag then Delimiter:= LCharGood;
    end;
    Result:= True;
  finally
    CS_ATLists.Leave;
  end;
end;
//======================================== �������� Delimiter ������ ���� TypeID
procedure TArrayTypeLists.SetTypeListDelimiter(TypeID: Word; delim: Char);
begin
  if not Assigned(self) then Exit;
  CS_ATLists.Enter;
  try
    with GetTypeList(TypeID) do if FDelimiterFlag then Delimiter:= delim;
  finally
    CS_ATLists.Leave;
  end;
end;
//============= ����� ��� �������� �� ������ ���� TypeID �� ����� (� Objects-ID)
function TArrayTypeLists.GetTypeListItemIDByName(TypeID: Word; pName: String): Integer;
var i: Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
//  CS_ATLists.Enter;
  try
    with GetTypeList(TypeID) do if Count>0 then begin
      i:= IndexOf(pName);
      if i>-1 then Result:= Integer(Objects[i]);
    end;
//  finally
//    CS_ATLists.Leave;
  except
  end;
end;
//================================================== �������� ������ ���� TypeID
procedure TArrayTypeLists.ClearTypeList(TypeID: Word);
begin
  if not Assigned(self) or not TypeOfListExists(TypeID) then Exit; // ������ ���� ���
  with GetTypeList(TypeID) do if Count>0 then try
    CS_ATLists.Enter;
    Clear;
  finally
    CS_ATLists.Leave;
  end;
end;
//========================== ��������� ������������� �������� ������ ���� TypeID
function TArrayTypeLists.TypeListItemExists(TypeID: Word; pID: Integer): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= TypeListItemExists(TypeID,Pointer(pID));
end;
//========================== ��������� ������������� �������� ������ ���� TypeID
function TArrayTypeLists.TypeListItemExists(TypeID: Word; p: Pointer): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= TypeOfListExists(TypeID) and (GetTypeList(TypeID).IndexOfObject(p)>-1);
end;
//======================================== �������� ������� � ������ ���� TypeID
function TArrayTypeLists.AddTypeListItem(TypeID: Word; pID: Integer; pName: String): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= AddTypeListItem(TypeID, Pointer(pID), pName);
end;
//========================================
function TArrayTypeLists.AddTypeListItem(TypeID: Word; p: Pointer; pName: String): boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not TypeOfListExists(TypeID) then Exit; // ������ ���� ���
  if TypeListItemExists(TypeID, p) then Exit; // ����� ������� ��� ����
  with GetTypeList(TypeID) do try
    CS_ATLists.Enter;
    if FDelimiterFlag then Delimiter:= LCharUpdate;
    if FSortList then Sorted:= False; // ��������� ����������
    Result:= AddObject(pName, p)>-1;
    if FSortList then begin
      if Count>1 then Sort;
      Sorted:= True;  // �������� ����������
    end;
    if FDelimiterFlag then Delimiter:= LCharGood;
  finally
    CS_ATLists.Leave;
  end;
end;
//======================================== ������� ������� �� ������ ���� TypeID
function TArrayTypeLists.DelTypeListItem(TypeID: Word; pID: Integer): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= DelTypeListItem(TypeID, Pointer(pID));
end;
//======================================== 
function TArrayTypeLists.DelTypeListItem(TypeID: Word; p: Pointer): boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not TypeOfListExists(TypeID) then Exit; // ������ ���� ���
  i:= -1;
  with GetTypeList(TypeID) do if Count>0 then begin
    i:= IndexOfObject(p);
    if i>-1 then try
      CS_ATLists.Enter;
      Delete(i);
    finally
      CS_ATLists.Leave;
    end;
  end;
  Result:= (i<0) or not TypeListItemExists(TypeID, p); // ���������, ��� ������ �������� ���
end;

//******************************************************************************
//                                     TLink
//******************************************************************************
constructor TLink.Create(pSrcID: Integer; pLinkPtr: Pointer);
begin
  inherited Create;
  FLinkPtr:= pLinkPtr;
  FSrcID  := pSrcID;
  FLinkOpts:= [];
  State:= True;
end;
//==============================================================================
destructor TLink.Destroy;
begin
  FLinkOpts:= [];
  inherited;
end;
//============================================================= �������� �������
procedure TLink.SetLinkBool(ik: T8InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FLinkOpts:= FLinkOpts+[ik] else FLinkOpts:= FLinkOpts-[ik];
end;
//============================================================= �������� �������
function TLink.GetLinkBool(ik: T8InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FLinkOpts);
end;
//==============================================================================
function TLink.GetLinkItemID: Integer;
begin
  Result:= 0;
  if not Assigned(self) or not Assigned(FLinkPtr) then Exit;
  Result:= TDirItem(FLinkPtr).ID;
end;

//******************************************************************************
//                              TLinkLink
//******************************************************************************
constructor TLinkLink.Create(pSrcID: Integer; pLinkPtr: Pointer);
begin
  inherited Create(pSrcID, pLinkPtr);
  FDoubleLinks:= nil;
end;
//==============================================================================
destructor TLinkLink.Destroy;
begin
  if not Assigned(self) then Exit;
  if Assigned(FDoubleLinks) then try prFree(FDoubleLinks); except end;
  inherited Destroy;
end;
//==============================================================================
procedure TLinkLink.CheckDoubleLinks(CS: TCriticalSection);
begin
  if Assigned(FDoubleLinks) and (FDoubleLinks.Count>0) then Exit;
  if not assigned(CS) then CS:= CS_any;
  try
    CS.Enter;
    if not Assigned(FDoubleLinks) then FDoubleLinks:= TLinkList.Create
    else if FDoubleLinks.Count<1 then prFree(FDoubleLinks);
  finally
    CS.Leave;
  end;
end;

//******************************************************************************
//                            TQtyLink
//******************************************************************************
constructor TQtyLink.Create(pSrcID: Integer; pQty: Single; pLinkPtr: Pointer);
begin
  inherited Create(pSrcID, pLinkPtr);
  FQty:= RoundTo(pQty, -3);
end;

//******************************************************************************
//                         TTwoLink
//******************************************************************************
constructor TTwoLink.Create(pSrcID: Integer; pLinkPtr, pLinkPtrTwo: Pointer);
begin
  inherited Create(pSrcID, pLinkPtr);
  FLinkPtrTwo:= pLinkPtrTwo;
end;
//==============================================================================
function TTwoLink.GetLinkTwoItemID: Integer;
begin
  Result:= 0;
  if not Assigned(self) or not Assigned(FLinkPtrTwo) then Exit;
  Result:= TDirItem(FLinkPtrTwo).ID;
end;

//******************************************************************************
//                             TFlagLink
//******************************************************************************
constructor TFlagLink.Create(pSrcID: Integer; pLinkPtr: Pointer; pFlag: Boolean);
begin
  inherited Create(pSrcID, pLinkPtr);
  Flag:= pFlag;
end;

//******************************************************************************
//                              TLinks
//******************************************************************************
//==============================================================================
constructor TLinks.Create(CS: TCriticalSection=nil);
begin
  inherited Create;
  FItems:= TList.Create;
  if assigned(CS) then CS_links:= CS else CS_links:= CS_any;
end;
//==============================================================================
destructor TLinks.Destroy;
var i: Integer;
    link: TLink;
begin
  if not Assigned(self) then Exit;
  for i:= 0 to FItems.Count-1 do try
    link:= FItems[i];
    prFree(Link);
  except end;
  prFree(FItems);
  inherited Destroy;
end;
//==============================================================================
procedure TLinks.ListGrow(addCount: Integer);
var NewCapacity, NewCount: Integer;
begin
  NewCount:= FItems.Count+addCount;
  if FItems.Capacity>NewCount then Exit;
  NewCapacity:= FItems.Capacity;
  while NewCapacity<NewCount do
    if NewCapacity>8 then NewCapacity:= NewCapacity+16 else NewCapacity:= NewCapacity+4;
  FItems.Capacity:= NewCapacity;
end;
//============================================================ ���������� ������
function TLinks.GetLinkCount: Integer;
begin
  if not Assigned(self) then Result:= 0 else Result:= FItems.Count;
end;
//===========================================  �������� ������������� 1-� ������
function TLinks.LinkExists(ID: Integer): Boolean;
begin
  Result:= Assigned(self) and Assigned(GetLinkItemByID(ID));
end;
//===================== ���������� ������ �� ������� � ����� pID, ���� ��� - nil
function TLinks.GetLinkItemByID(pID: Integer): Pointer;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) or (pID<1) then Exit;
  for i:= 0 to FItems.Count-1 do   // ����� ������������ ��������
    if Assigned(FItems[i]) and (GetLinkID(FItems[i])=pID) then begin
      Result:= FItems[i];
      Exit;
    end;
end;
//=========== ���������� ������ �� ������� � ������������� pName, ���� ��� - nil
function TLinks.GetLinkItemByName(pName: String): Pointer;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to FItems.Count-1 do   // ����� ������������ ��������
    if Assigned(FItems[i]) and (GetLinkName(FItems[i])=pName) then begin
      Result:= FItems[i];
      Exit;
    end;
end;
//============================== ������� ������ NewItem ����� ������� BeforeItem
function TLinks.InsertLink(NewItem, BeforeItem: Pointer): Boolean;
var i, index: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  i:= 0;
  CS_Links.Enter;
  try
    if Assigned(BeforeItem) then index:= FItems.IndexOf(BeforeItem) else index:= -1;
    if index<0 then index:= FItems.Add(NewItem) else FItems.Insert(index, NewItem);
    if index>-1 then begin
      TLink(FItems[index]).State:= True;
      i:= GetLinkID(FItems[index]);
    end;
  finally
    CS_Links.Leave;
  end;
  if i>0 then Result:= LinkExists(i);
end;
//============================================= ���������� / �������� 1-� ������
function TLinks.CheckLink(pLinkID, pSrcID: Integer; pLinkPtr: Pointer): Pointer;
var Link: TLink;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Link:= GetLinkItemByID(pLinkID);
  CS_Links.Enter;
  try
    if Assigned(Link) then begin // ���� � ����� ����� ��� ���� - ���������
      if Link.FSrcID  <>pSrcID   then Link.FSrcID  := pSrcID;
      if Link.FLinkPtr<>pLinkPtr then Link.FLinkPtr:= pLinkPtr;
    end else begin
      Link:= TLink.Create(pSrcID, pLinkPtr);
      FItems.Add(Link);
    end;
    Link.State:= True;
  finally
    CS_Links.Leave;
  end;
  Result:= Link;
end;
//===================================================== ���������� ������ ������
procedure TLinks.FreeAddMem;
begin
  if not Assigned(self) then Exit;
  if (FItems.Capacity-FItems.Count)<4 then Exit;
  CS_Links.Enter;
  try
    FItems.Capacity:= (FItems.Count div 4)+4;
  finally
    CS_Links.Leave;
  end;
end;
//====================================== ��������� ������ �� ����� ����.��������
procedure TLinks.SortByLinkName;
begin
  if not Assigned(self) or (FItems.Count<2) then Exit;
  CS_Links.Enter;
  try
    FItems.Sort(LinkNameSortCompare);
  finally
    CS_Links.Leave;
  end;
end;
//============================== ��������� ������ �� ���.� � ����� ����.��������
procedure TLinks.SortByLinkOrdNumAndName;
begin
  if not Assigned(self) or (FItems.Count<2) then Exit;
  CS_Links.Enter;
  try
    FItems.Sort(LinkNumNameSortCompare);
  finally
    CS_Links.Leave;
  end;
end;
//====================================== ��������� ������ �� ��������� ���������
procedure TLinks.LinkSort(Compare: TListSortCompare);
begin
  if not Assigned(self) or (FItems.Count<2) then Exit;
  CS_Links.Enter;
  try
    FItems.Sort(Compare);
  finally
    CS_Links.Leave;
  end;
end;
//============================================================== �������� ������
function TLinks.AddLinkItem(NewItem: Pointer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or not Assigned(NewItem) then Exit;
  CS_Links.Enter;
  try
    TLink(NewItem).State:= True;
    Result:= FItems.Add(NewItem);
  except end;
  CS_Links.Leave;
end;
//============================================= �������� ������ ������ �� ������
function TLinks.AddLinkItems(NewItems: TList): Integer;
var i: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  CS_Links.Enter;
  try
    ListGrow(NewItems.Count);
    for i:= 0 to NewItems.Count-1 do
      if Assigned(NewItems[i]) then try
        TLink(NewItems[i]).State:= True;
        FItems.Add(NewItems[i]); // ��������� ������ �� ����
        NewItems[i]:= nil;
        inc(Result);
      except end;
  finally
    CS_Links.Leave;
  end;
end;
//===================================================== ������� ������ �� ������
procedure TLinks.DeleteLinkItem(ID: Integer);    // �� ���� ����.��������
var DelItem: Pointer;
begin
  if not Assigned(self) then Exit;
  DelItem:= GetLinkItemByID(ID);
  if Assigned(DelItem) then DeleteLinkItem(DelItem);
end;
//==================================
procedure TLinks.DeleteLinkItem(Item: Pointer);  // �� ������ �� ������
var i: Integer;
    Link: TLink;
begin
  if not Assigned(self) or not Assigned(Item) then Exit;
  i:= FItems.IndexOf(Item);
  if i<0 then Exit;
  Link:= Item;
  CS_Links.Enter;
  try
    FItems.Delete(i);
    prFree(Link);
    FItems.Capacity:= FItems.Count;
  finally
    CS_Links.Leave;
  end;
end;
//========================================= �������� ������ ����� ����.���������
function TLinks.GetLinkCodes: Tai;
var i, j: Integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit else SetLength(Result, FItems.Count);
  j:= 0;
  try
    for i:= 0 to FItems.Count-1 do if Assigned(FItems[i]) then begin
      Result[j]:= GetLinkID(FItems[i]);
      inc(j);
    end;
  except end;
  if Length(Result)>j then SetLength(Result, j);
end;
//=================================== ������������� ���� �������� ���� ���������
procedure TLinks.SetLinkStates(pState: Boolean);
var i: Integer;
begin
  if not Assigned(self) or (FItems.Count<1) then Exit;
  CS_Links.Enter;
  try
    for i:= 0 to FItems.Count-1 do TLink(FItems[i]).State:= pState;
  finally
    CS_Links.Leave;
  end;
end;
//=========================================== ������� ��� �������� � State=False
procedure TLinks.DelNotTestedLinks;
var i: Integer;
    Link: TLink;
begin
  if not Assigned(self) or (FItems.Count<1) then Exit;
  for i:= FItems.Count-1 downto 0 do begin
    Link:= FItems[i];
    if not Link.State then try
      CS_Links.Enter;
      FItems.Delete(i);
      prFree(Link);
    finally
      CS_Links.Leave;
    end;
  end;
end;

//******************************************************************************
//                              TLinkLinks
//******************************************************************************
//==============================================================================
destructor TLinkLinks.Destroy;
var i: Integer;
    link: TLinkLink;
begin
  if not Assigned(self) then Exit;
  for i:= 0 to FItems.Count-1 do try
    link:= FItems[i];
    prFree(Link);
  except end;
  prFree(FItems);
end;
//==================================================== ������� ������ 1-� ������
function TLinkLinks.GetDoubleLinks(ID: Integer): TLinkList; // �� ���� ����.��������
begin
  if not Assigned(self) then Result:= nil else Result:= GetDoubleLinks(GetLinkItemByID(ID));
end;
//==================================
function TLinkLinks.GetDoubleLinks(Item: Pointer): TLinkList; // �� ������ �� ������
begin
  if not Assigned(self) or not Assigned(Item) then Result:= nil
  else Result:= TLinkLink(Item).FDoubleLinks;
end;
//===========================================  �������� ������������� 2-� ������
function TLinkLinks.DoubleLinkExists(ID1, ID2: Integer): Boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= DoubleLinkExists(GetLinkItemByID(ID1), ID2);
end;
// �������� ������������� 2-� ������ �� ������ �� 1-� ������ � ���� ����.�������� 2-�
function TLinkLinks.DoubleLinkExists(Item: Pointer; ID2: Integer): Boolean;
var link: TLinkLink;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(Item) then Exit;
  link:= Item;
  if not Assigned(link.FDoubleLinks) then Exit;
  Result:= link.FDoubleLinks.LinkListItemExists(ID2, lkLnkNone);
end;

//******************************************************************************
//                              TBaseDirItem
//******************************************************************************
constructor TBaseDirItem.Create(pID: Integer; pName: String);
begin
  inherited Create;
  FID  := pID;
  FName:= pName;
  FDirBoolOpts:= [];
  State:= True;
end;
//==============================================================================
destructor TBaseDirItem.Destroy;
begin
  if not Assigned(self) then Exit;
  FDirBoolOpts:= [];
  inherited Destroy;
end;
//==============================================================================
function TBaseDirItem.GetName: String;
begin
  if not Assigned(self) then Result:= '' else Result:= FName;
end;
//==============================================================================
procedure TBaseDirItem.SetName(const Value: String);
begin
  if not Assigned(self) then exit else if (FName='') or (FName<>Value) then FName:= Value;
end;
//==============================================================================
function TBaseDirItem.GetDirBool(const ik: T8InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FDirBoolOpts);
end;
//==============================================================================
procedure TBaseDirItem.SetDirBool(const ik: T8InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FDirBoolOpts:= FDirBoolOpts+[ik] else FDirBoolOpts:= FDirBoolOpts-[ik];
end;

//******************************************************************************
//                              TDirItem
//******************************************************************************
constructor TDirItem.Create(pID: Integer; pName: String; WithLinks: Boolean=False);
begin
  inherited Create(pID, pName);
  if WithLinks then FLinks:= TLinks.Create else FLinks:= nil;
end;
//==============================================================================
destructor TDirItem.Destroy;
begin
  if not Assigned(self) then Exit;
  try if Assigned(FLinks) then prFree(FLinks); except end;
  inherited Destroy;
end;

//******************************************************************************
//                              TSubDirItem
//******************************************************************************
constructor TSubDirItem.Create(pID, pSubCode, pOrderNum: Integer; pName: String;
            pSrcID: Integer=0; WithLinks: Boolean=False);
begin
  inherited Create(pID, pName, WithLinks);
  FSubCode := pSubCode; // ��� TecDoc ��� ���, ������ � �.�.
  FOrderNum:= pOrderNum;
  FSrcID   := pSrcID;
end;

//******************************************************************************
//                              TDirItems
//******************************************************************************
//==============================================================================
constructor TDirItems.Create(LengthStep: Integer=10);
begin
  inherited Create;
  SetLength(FItems, 1);
  FItems[0]:= TDirItem.Create(0, '', True); // ��������� ������� � ������ ������� ������, ����� �� ���������� nil
  FItemsList:= TList.Create;                // ������ ������ �� ��������
  CS_DirItems:= TCriticalSection.Create;
  if LengthStep<10 then FSetLengthStep:= 10 else FSetLengthStep:= LengthStep;
end;
//==============================================================================
destructor TDirItems.Destroy;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  prFree(FItemsList);
  for i:= Low(FItems) to High(FItems) do
    if Assigned(FItems[i]) then try prFree(TObject(FItems[i])); except end;
  SetLength(FItems, 0);
  prFree(CS_DirItems);
  inherited Destroy;
end;
//==================================================
function TDirItems.ItemExists(pID: Integer): Boolean;
begin
  Result:= Assigned(self) and (pID>0) and (length(FItems)>pID) and Assigned(FItems[pID]);
end;
//========================================================= ���������� ���������
function TDirItems.GetCount: Integer;
begin
  if not Assigned(self) then Result:= 0 else Result:= FItemsList.Count;
end;
//============================================== �������� ������ ����� ���������
function TDirItems.GetDirCodes: Tai;
var i, j: Integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit else SetLength(Result, FItemsList.Count);
  j:= 0;
  try
    for i:= 0 to FItemsList.Count-1 do if Assigned(FItemsList[i]) then begin
      Result[j]:= GetDirItemID(FItemsList[i]);
      inc(j);
    end;
  except end;
  if Length(Result)>j then SetLength(Result, j);
end;
//========= ���������� ������ �� ������� � �����-�������� pIndex, ���� ��� - 0-�
function TDirItems.GetItem(pIndex: Integer): Pointer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
//  CS_DirItems.Enter; // ���� ����������� ������ �������, ���� �����
  try
    if ItemExists(pIndex) then Result:= FItems[pIndex] else Result:= FItems[0];
//  finally
//    CS_DirItems.Leave;
  except
  end;
end;
//=================== ���������� ������� � �����-�������� pIndex, ���� ��� - 0-�
function TDirItems.GetDirItem(pIndex: Integer): TDirItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TDirItem(DirItems[pIndex]);
end;
//======================================= ��������� ���������� �� ����� ��������
procedure TDirItems.SortDirListByName;
begin
  if not Assigned(self) or (FItemsList.Count<2) then Exit;
  CS_DirItems.Enter;
  try
    FItemsList.Sort(DirNameSortCompare);
  finally
    CS_DirItems.Leave;
  end;
end;
//=============================== ��������� ���������� �� ���.� � ����� ��������
procedure TDirItems.SortDirListByOrdNumAndName;
begin
  if not Assigned(self) or (FItemsList.Count<2) then Exit;
  CS_DirItems.Enter;
  try
    FItemsList.Sort(DirNumNameSortCompare);
  finally
    CS_DirItems.Leave;
  end;
end;
//================================== ��������� ���������� �� ��������� ���������
procedure TDirItems.DirSort(Compare: TListSortCompare);
begin
  if not Assigned(self) or (FItemsList.Count<2) then Exit;
  CS_DirItems.Enter;
  try
    FItemsList.Sort(Compare);
  finally
    CS_DirItems.Leave;
  end;
end;
//================================================= �������� / ��������� �������
function TDirItems.CheckItem(var NewItem: Pointer): Boolean;
var i, j, jj: Integer;
    item, oldItem: TDirItem;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(NewItem) then exit;
  try
    item:= NewItem;
    i:= item.ID;
    if ItemExists(i) then oldItem:= FItems[i] else oldItem:= nil;
    CS_DirItems.Enter;
    try
      if Assigned(oldItem) then begin // ���� � ����� ����� ���� - ��������� ���
        oldItem.Name:= item.FName;
        prFree(item);
        oldItem.State:= True;
        NewItem:= oldItem;
      end else begin             // ���� ��� - ���������
        if High(FItems)<i then begin
          jj:= Length(FItems);                  // ��������� ����� �������
          SetLength(FItems, i+FSetLengthStep);  // � ���������� ��������
          for j:= jj to High(FItems) do if j<>i then FItems[j]:= nil;
        end;
        FItems[i]:= NewItem;
        FItemsList.Add(NewItem);
        item.State:= True;
      end;
    finally
      CS_DirItems.Leave;
    end;
    Result:= ItemExists(i);
  except
    Result:= False;
  end;
end;
//============================================================== ������� �������
function TDirItems.DeleteItem(pID: Integer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) or not ItemExists(pID) then Exit; // � ����� ����� ���
  CS_DirItems.Enter;
  try
    i:= FItemsList.IndexOf(Pointer(pID));
    if i>-1 then FItemsList.Delete(i);
    prFree(TDirItem(FItems[pID]));
    FItems[pID]:= nil;
    Result:= True;
  finally
    CS_DirItems.Leave;
  end;
end;
//============================================= ���������� ������������ ��������
function TDirItems.GetItemName(pID: Integer): String;
begin
  if not Assigned(self) or not ItemExists(pID) then Result:= '' // � ����� ����� ���
  else Result:= TBaseDirItem(FItems[pID]).Name;
end;
//=============================================== �������� ������������ ��������
procedure TDirItems.SetItemName(pID: Integer; pName: String);
begin
  if not Assigned(self) or not ItemExists(pID) then Exit; // � ����� ����� ���
  CS_DirItems.Enter;
  try
    TBaseDirItem(FItems[pID]).Name:= pName;
  finally
    CS_DirItems.Leave;
  end;
end;
//=================================== ������������� ���� �������� ���� ���������
procedure TDirItems.SetDirStates(pState: Boolean);
var i: Integer;
begin
  if not Assigned(self) or (length(FItems)<2) then Exit;
  CS_DirItems.Enter;
  try
    for i:= 1 to High(FItems) do
      if Assigned(FItems[i]) then TBaseDirItem(FItems[i]).State:= pState;
  finally
    CS_DirItems.Leave;
  end;
end;
//=========================================== ������� ��� �������� � State=False
procedure TDirItems.DelDirNotTested;
var i, ii: Integer;
begin
  if not Assigned(self) or (length(FItems)<2) then Exit;
  CS_DirItems.Enter;
  try
    for i:= length(FItems)-1 downto 1 do
      if Assigned(FItems[i]) and not TBaseDirItem(FItems[i]).State then begin
        ii:= FItemsList.IndexOf(FItems[i]);
        if ii>-1 then FItemsList.Delete(ii);
        try prFree(TObject(FItems[i])); except end;
        FItems[i]:= nil;
      end;
  finally
    CS_DirItems.Leave;
  end;
end;
//======================================================= �������� ID �� SubCode
function TDirItems.GetIDBySubCode(pSubCode: Integer): Integer;
var i: Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  try
    for i:= 0 to ItemsList.Count-1 do with TSubDirItem(ItemsList[i]) do
      if FSubCode=pSubCode then begin
        Result:= FID;
        exit;
      end;
  except end;
end;
{//========================================================= �������� ID �� �����
function TDirItems.GetIDByName(pName: String): Integer;
var i: Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  try
    for i:= 0 to ItemsList.Count-1 do with TDirItem(ItemsList[i]) do
      if FName=pName then begin
        Result:= FID;
        exit;
      end;
  except end;
end; }
//========================================== ������ ��������� � SubCode=pSubCode
function TDirItems.GetListSubCodeItems(pSubCode: Integer): TList; // must Free
var i: Integer;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  Result.Capacity:= Result.Capacity+ItemsList.Count;
  try
    for i:= 0 to ItemsList.Count-1 do
      if (TSubDirItem(ItemsList[i]).SubCode=pSubCode) then Result.Add(ItemsList[i]);
  except end;
end;
//========================================= �������� ����� �� ������������� ����
procedure TDirItems.CheckLength;
var i, j: Integer;
begin
  if not Assigned(self) then Exit;
  j:= Length(FItems);
  for i:= High(FItems) downto 0 do if Assigned(FItems[i]) then begin
    j:= i+1;
    break;
  end;
  if Length(FItems)>j then try
    CS_DirItems.Enter;
    SetLength(FItems, j);
  finally
    CS_DirItems.Leave;
  end;
end;
//======================================= ������������ ��� ��������� �����������
function TDirItems.GetMaxCode: Integer;
var i: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  for i:= High(FItems) downto 0 do if Assigned(FItems[i]) then begin
    Result:= i;
    break;
  end;
end;
//******************************************************************************
//                             TCacheList   ���������
//******************************************************************************
{constructor TCacheList.Create(aClass: TClass=nil);
begin
  inherited Create;
  if not Assigned(aClass) then aClass:= TSubDirItem;
  FItemClass:= aClass;
  FListState:= lsEmpty;
end;
//======================================================= ��������� ����� ������
procedure TCacheList.SetState(NewState: TListState);
begin
  if (FListState<>NewState) then FListState:= NewState;
end;
//============================================================== ��������� �����
function TCacheList.CheckItemClass(aClass: TClass): Boolean;
var xClass: TClass;
begin
  Result:= False;
  xClass:= FItemClass;
  while Assigned(xClass) do begin
    Result:= (xClass = aClass);
    if Result then exit;
    xClass:= xClass.ClassParent;
  end;
end;
//============================================================ ������� ���������
function TCacheList.GetItemVisible(index: Integer): Boolean;
begin
  Result:= False;
  if (index<0) or (index>(Count-1)) or not Assigned(Items[index]) then exit;
  if CheckItemClass(TSubVisDirItem) then Result:= TSubVisDirItem(Items[index]).IsVisible;
end;
}
//******************************************************************************
//                           TLinkList
//******************************************************************************
function GetItemID(pItem: Pointer; lkind: TLLKind): Integer;
begin
  case lkind of
    lkDirNone, lkDirByID: Result:= GetDirItemID(pItem);
    lkLnkNone, lkLnkByID: Result:= GetLinkID(pItem);
    else Result:= 0;
  end;
end;
//==============================================================================
function GetItemName(pItem: Pointer; lkind: TLLKind): String;
begin
  case lkind of
    lkDirNone, lkDirByID: Result:= GetDirItemName(pItem);
    lkLnkNone, lkLnkByID: Result:= GetLinkName(pItem);
    else Result:= '';
  end;
end;
//============================================== �������� ������������� ��������
function TLinkList.LinkListItemExists(pID: Integer; lkind: TLLKind): Boolean;
begin
  Result:= GetLinkListItemIndexByID(pID, lkind)>-1;
end;
//============================================= �������� ������ �������� �� ����
function TLinkList.GetLinkListItemIndexByID(pID: Integer; lkind: TLLKind): Integer;
var iLow, iHigh, iNum: Integer;
begin
  Result:= -1;
  if not Assigned(self) or (pID<1) then Exit;

  iLow:= 0;              // ������ ������
  iHigh:= Count-1;       // ������� ������
  case lkind of
    lkDirByID, lkLnkByID: begin //-------------------- ����� ����������� �������
      while (iHigh-iLow)>4 do begin
        Result:= (iLow+iHigh) div 2;        // ������ �������� ��-��
        iNum:= GetItemID(Items[Result], lkind); // ID �������� ��-��

        if (iNum=pID) then Exit
        else if (pID<iNum) then iHigh:= Result-1 else iLow:= Result+1;

      end;
      for Result:= iLow to iHigh do // ���� ��������� � ���������� ���������
        if GetItemID(Items[Result], lkind)=pID then Exit;
    end; // lkDirByID

    else for Result:= iLow to iHigh do //----------------------- ����� ���������
      if Assigned(Items[Result]) and (GetItemID(Items[Result], lkind)=pID) then Exit;
  end; // case
  Result:= -1;
end;
//======================================================== ����� ������� �� ����
function TLinkList.GetLinkListItemByID(pID: Integer; lkind: TLLKind): Pointer;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) or (pID<1) then Exit;
  i:= GetLinkListItemIndexByID(pID, lkind); // �������� ������ �� ����
  if (i>-1) then Result:= Items[i];
end;
//============================================ ����� ������ ��� ������� ��������
function TLinkList.GetIndexForInsItem(pItem: Pointer; lkind: TLLKind;
                                      Compare: TListSortCompare): Integer;
var pID: Integer;
begin
  Result:= -1;
  if not Assigned(self) or not Assigned(pItem) then Exit;
  pID:= GetItemID(pItem, lkind);       // �������� ���
  if (pID<1) then Exit;

  case lkind of
    lkDirByID, lkLnkByID:  //------------------------------- ���������� �� ����
      if (Count<1) or (GetItemID(Last, lkind)<pID) then Result:= Count
      else begin
        Result:= 0;
        while (Result<Count) and (GetItemID(Items[Result], lkind)<pID) do inc(Result);
      end; // lkDirByID

    else Result:= Count;
  end; // case
end;
//========================================= �������� ������� (���������� ������)
function TLinkList.AddLinkListItem(pItem: Pointer; lkind: TLLKind;
         CS: TCriticalSection; Compare: TListSortCompare): Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  Result:= GetIndexForInsItem(pItem, lkind, Compare);
  if (Result<0) then Exit;

  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    if (Result<Count) then Insert(Result, pItem) else Result:= Add(pItem); // ��������� / ���������
  except
    Result:= -1;
  end;
  CS.Leave;
end;
//====================================================== ������� ������� �� ����
function TLinkList.DelLinkListItemByID(pID: Integer; lkind: TLLKind;
         CS: TCriticalSection; Compare: TListSortCompare): Integer;
begin
  Result:= -1;
  if not Assigned(self) or (pID<1) then Exit;
  Result:= GetLinkListItemIndexByID(pID, lkind); // �������� ������ �� ����
  if (Result<0) then Exit;
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    Delete(Result);               // �������
//    Capacity:= Count;             // ��������
  except
    Result:= -1;
  end;
  CS.Leave;
end;
//========================================= �������� ������ ����� ����.���������
function TLinkList.GetLinkListCodes(lkind: TLLKind): Tai;
var i, j: Integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit else SetLength(Result, Count);
  j:= 0;
  try
    for i:= 0 to Count-1 do if Assigned(Items[i]) then begin
      Result[j]:= GetItemID(Items[i], lkind);
      inc(j);
    end;
  except end;
  if Length(Result)>j then SetLength(Result, j);
end;
//===================================================== ���������� ������ ������
{procedure TLinkList.FreeUnusedMem(CS: TCriticalSection);
var delta: Byte;
begin
  if not Assigned(self) or ((Capacity-Count)<4) then Exit;
  delta:= 4-(Count mod 4);
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    Capacity:= Count+delta; // ��������, ��������� ����� �� 4    ???
  finally
    CS.Leave;
  end;
end; }
//=================================== ���-�� ������ (��� ������������� � TLinks)
function TLinkList.GetLinkCount: Integer;
begin
  Result:= Count;
end;
//=================================== ������������� ���� �������� ���� ���������
procedure TLinkList.SetLinkStates(pState: Boolean; CS: TCriticalSection);
var i: Integer;
begin
  if not Assigned(self) or (Count<1) then Exit;
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    for i:= 0 to Count-1 do TLink(Items[i]).State:= pState;
  finally
    CS.Leave;
  end;
end;
//=========================================== ������� ��� �������� � State=False
procedure TLinkList.DelNotTestedLinks(CS: TCriticalSection);
var i: Integer;
    Link: TLink;
begin
  if not Assigned(self) or (Count<1) then Exit;
  if not assigned(CS) then CS:= CS_any;
  for i:= Count-1 downto 0 do begin
    Link:= Items[i];
    if not Link.State then try
      CS.Enter;
      Delete(i);
      prFree(Link);
    finally
      CS.Leave;
    end;
  end;
end;
//===========================================
procedure TLinkList.ClearLinks(CS: TCriticalSection=nil);
var i: Integer;
    link: TLink;
begin
  if not Assigned(self) or (Count<1) then Exit;
  if not assigned(CS) then CS:= CS_any;
  for i:= Count-1 downto 0 do if Assigned(Items[i]) then try
    CS.Enter;
    link:= Items[i];
    prFree(Link);
  finally
    CS.Leave;
  end;
end;

(*
//******************************************************************************
//                            TSrcLinkList
//******************************************************************************
constructor TSrcLinkList.Create;
begin
  inherited Create;
  SetLength(FarSrc, 0);
end;
//=========================================
destructor TSrcLinkList.Destroy;
begin
  SetLength(FarSrc, 0);
  inherited Destroy;
end;
//============================== ��������� ���������� ������� ������� ����������
function TSrcLinkList.NotAllowSrcIndex(pIndex: Integer; CS: TCriticalSection): Boolean;
begin
  Result:= not Assigned(self) or (pIndex<0);
  if Result then Exit;
  TestSrcLength(CS);
  Result:= pIndex>High(FarSrc);
end;
//=========================================== ��������� ����� ������� ����������
procedure TSrcLinkList.TestSrcLength(CS: TCriticalSection; cutByCap: Boolean=False);
// cutByCap=True - �������� �� Capacity, False - ������ �����������
var i: Integer;
begin
  if not Assigned(self) then Exit;
  i:= Length(FarSrc);
  case cutByCap of
    False: if (i>=Count) then exit;
    True : if (i>=Count) and (i<=Capacity) then exit;
  end;

  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    SetLength(FarSrc, Capacity); // ����� �����
    for i:= Count to Length(FarSrc)-1 do FarSrc[i]:= 0; // �������� ������
  except end;
  CS.Leave;
end;
//================================================= �������� �������� �� �������
procedure TSrcLinkList.AddSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection);
var i: Integer;
begin
  if not Assigned(self) or NotAllowSrcIndex(pIndex, CS) then Exit;
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    if pIndex<(Count-1) then // ���� �� ��������� - ��������� ���������
      for i:= Count-1 downto pIndex+1 do FarSrc[i]:= FarSrc[i-1];
    FarSrc[pIndex]:= pSrcID; // ����� ��������
  except end;
  CS.Leave;
end;
//================================================ ��������� �������� �� �������
procedure TSrcLinkList.CheckSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection);
begin
  if not Assigned(self) or NotAllowSrcIndex(pIndex, CS) then Exit;

  if FarSrc[pIndex]=pSrcID then Exit;

  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    FarSrc[pIndex]:= pSrcID; // ������ ��������
  except end;
  CS.Leave;
end;
//====================================================== ������� ������� �� ����
function TSrcLinkList.DelLinkListItemByID(pID: Integer; lkind: TLLKind;
         CS: TCriticalSection; Compare: TListSortCompare): Integer;
var i: Integer;
begin
  Result:= -1;
  if not Assigned(self) then Exit;
  if not Assigned(CS) then CS:= CS_any;

  Result:= inherited DelLinkListItemByID(pID, lkind, CS, Compare);
  if NotAllowSrcIndex(Result, CS) then Exit;

  CS.Enter;
  try
    for i:= Result to Count-1 do FarSrc[i]:= FarSrc[i+1];  // ��������� ���������
    FarSrc[Count]:= 0;
  except end;
  CS.Leave;
end;
//===================================================== ���������� ������ ������
{procedure TSrcLinkList.FreeUnusedMem(CS: TCriticalSection);
begin
  if not Assigned(self) then Exit;
  if not assigned(CS) then CS:= CS_any;
  inherited FreeUnusedMem(CS);
  TestSrcLength(CS, True);
end;   }
//=========================================
function TSrcLinkList.CheckSrcLinkListItem(pID: Integer; pSrcID: Byte; pPtr: Pointer;
         lkind: TLLKind; CS: TCriticalSection; Compare: TListSortCompare): Integer;
begin
  Result:= -1;
  if not Assigned(self) or (pID<1) or not Assigned(pPtr) then Exit;
  Result:= GetLinkListItemIndexByID(pID, lkind);

  if not assigned(CS) then CS:= CS_any;
  if (Result>-1) then begin               // ���� ���� - ��������� ��������
    CheckSrcByIndex(Result, pSrcID, CS);
    Exit;
  end;

  Result:= AddLinkListItem(pPtr, lkind, CS, Compare); // ��������� / ���������

  if Result>-1 then AddSrcByIndex(Result, pSrcID, CS); // ��������� ��������
end;
*)
//******************************************************************************

//******************************************************************************
//                                TDirObjects
//******************************************************************************
constructor TDirObjects.Create;
begin
  inherited;
  CS_DirObj:= TCriticalSection.Create;
  OwnsObjects:= True;
end;
//=========================================
destructor TDirObjects.Destroy;
begin
  prFree(CS_DirObj);
  inherited;
end;
//=========================================
function TDirObjects.FindObjItem(pID: Integer; var obj: TObject): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then exit;
  for i:= 0 to Count-1 do if Assigned(Items[i]) then begin
    obj:= Items[i];
    Result:= (TBaseDirItem(obj).ID=pID);
    if Result then exit;
  end;
  obj:= nil;
end;
//=========================================
function TDirObjects.GetObjItem(pID: Integer): TObject;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then exit;
  for i:= 0 to Count-1 do if Assigned(Items[i]) then begin
    Result:= Items[i];
    if (TBaseDirItem(Result).ID=pID) then exit;
  end;
  Result:= nil;
end;
{//=========================================
function TDirObjects.ItemExists(pID: Integer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then exit;
  for i:= 0 to Count-1 do if Assigned(Items[i]) then begin
    Result:= (TBaseDirItem(Items[i]).ID=pID);
    if Result then exit;
  end;
end; }
//=========================================
procedure TDirObjects.DelDirNotTested;
var i: Integer;
//    item: TObject;
begin
  if not Assigned(self) then exit;
  CS_DirObj.Enter;
  try
    for i:= Count-1 downto 0 do if Assigned(Items[i])
      and not TBaseDirItem(Items[i]).State then begin
//      item:= Items[i];
      Delete(i);
//      prFree(item);
    end;
  finally
    CS_DirObj.Leave;
  end;
end;
//=========================================
procedure TDirObjects.SetDirStates(pState: Boolean);
var i: Integer;
begin
  if not Assigned(self) then exit;
  CS_DirObj.Enter;
  try
    for i:= 0 to Count-1 do if Assigned(Items[i]) then
      TBaseDirItem(Items[i]).State:= pState;
  finally
    CS_DirObj.Leave;
  end;
end;


//******************************************************************************
//                          TOwnDirItems
//******************************************************************************
constructor TOwnDirItems.Create(LengthStep: Integer);
begin
  inherited Create(LengthStep);
  FFreeCode:= 1; // ��������� ���
end;
//=========================================
function TOwnDirItems.GetCode: Integer;
begin
  Result:= 0;
  if not Assigned(self) then exit;
  CS_DirItems.Enter;
  try
    Result:= FFreeCode;
    Inc(FFreeCode);
  finally
    CS_DirItems.Leave;
  end;
end;
//=========================================
function TOwnDirItems.AddItem(var NewItem: Pointer): Boolean;
var j, jj: Integer;
    item: TBaseDirItem;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(NewItem) then exit;
  try
    item:= NewItem;
    if (item.ID<1) then item.FID:= GetCode;
    CS_DirItems.Enter;
    try
      if (High(FItems)<item.ID) then begin
        jj:= Length(FItems);                        // ��������� ����� �������
        SetLength(FItems, item.ID+FSetLengthStep);  // � ���������� ��������
        for j:= jj to High(FItems) do if j<>item.ID then FItems[j]:= nil;
      end;
      FItems[item.ID]:= NewItem;
      FItemsList.Add(NewItem);
      item.State:= True;
    finally
      CS_DirItems.Leave;
    end;
    Result:= ItemExists(item.ID);
  except
    Result:= False;
  end;
end;
//===========================================================
function TOwnDirItems.FindByName(pName: String; var FindItem: Pointer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  for i:= 0 to ItemsList.Count-1 do begin
    FindItem:= ItemsList[i];
    Result:= (TBaseDirItem(FindItem).Name=pName);
    if Result then Exit;
  end;
  FindItem:= nil;
end;
{//===========================================================
function TOwnDirItems.FindBySubCode(SubID: Integer; var FindItem: Pointer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  for i:= 0 to ItemsList.Count-1 do begin
    FindItem:= ItemsList[i];
    Result:= (TSubDirItem(FindItem).SubCode=SubID);
    if Result then Exit;
  end;
  FindItem:= nil;
end;
}
//******************************************************************************
initialization
begin // ������ ������ - ����� �� ���������� nil
  EmptyStringList:= fnCreateStringList(False, LCharGood);
  EmptyIntegerList:= TIntegerList.Create;
  EmptyList:= TList.Create;             // ������ TList - ����� �� ���������� nil
  CS_any:= TCriticalSection.Create; // ��� ��������� ������, ������� �� ��������� TCriticalSection � �.�.
end;
finalization
begin
  prFree(EmptyStringList);
  prFree(EmptyIntegerList);
  prFree(CS_any);
  prFree(EmptyList);
end;
//******************************************************************************
end.
