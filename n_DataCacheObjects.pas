unit n_DataCacheObjects;

interface
uses Classes, Types, SysUtils, SyncObjs, Contnrs, Math, n_free_functions;

const
  LCharGood   = ',';  // Char если TStringList не требует обновления
  LCharUpdate = '!';  // Char если TStringList требуется обновить

type
  TASL = array of TStringList; // Массив списков

  TListState = (lsEmpty, lsAllow, lsUpdate);
  T8InfoKinds  = (ik8_1, ik8_2, ik8_3, ik8_4, ik8_5, ik8_6, ik8_7, ik8_8);        //  8 индексов (1 байт)
  T16InfoKinds = (ik16_1, ik16_2, ik16_3, ik16_4, ik16_5, ik16_6, ik16_7, ik16_8, // 16 индексов (2 байта)
                  ik16_9, ik16_10, ik16_11, ik16_12, ik16_13, ik16_14, ik16_15, ik16_16);
  TLLKind = (lkDirNone, lkDirByID, lkLnkNone, lkLnkByID); // сортировка TLinkList и тип элементов
// lkDir... - элементы справочника, lkLink... - линки
// ...None - без сортировки, ...ID - сортировка по ID, ...Name - сортировка по Name

//----------------------------------------------------------- список со статусом
{  TCacheList = Class (TList)        // заготовка
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

//---------------------------------------------------------------- список связок
  TLinkList = class(TList)
  protected
    function GetLinkListItemIndexByID(pID: Integer; lkind: TLLKind): Integer; // найти индекс элемента по коду
    function GetLinkCount: Integer;
  public
    function GetLinkListItemByID(pID: Integer; lkind: TLLKind): Pointer;      // найти элемент по коду
    function LinkListItemExists(pID: Integer; lkind: TLLKind): Boolean; // проверка существования элемента по коду

    function GetIndexForInsItem(pItem: Pointer; lkind: TLLKind;     //
             Compare: TListSortCompare=nil): Integer;
    function AddLinkListItem(pItem: Pointer; lkind: TLLKind;     // добавить элемент (возвращает индекс)
             CS: TCriticalSection; Compare: TListSortCompare=nil): Integer;
    function DelLinkListItemByID(pID: Integer; lkind: TLLKind;   // удалить элемент по коду (возвращает индекс)
             CS: TCriticalSection; Compare: TListSortCompare=nil): Integer; virtual;
//    procedure FreeUnusedMem(CS: TCriticalSection); virtual; // освободить лишнюю память

    procedure SetLinkStates(pState: Boolean; CS: TCriticalSection); // устанавливает флаг проверки всем связкам
    procedure DelNotTestedLinks(CS: TCriticalSection);              // удаляет все связки с State=False
    procedure ClearLinks(CS: TCriticalSection=nil);                 // чистит связанные линки

    function GetLinkListCodes(lkind: TLLKind): Tai;         // получить список кодов связ.элементов
    property LinkCount: Integer read GetLinkCount;          // кол-во связок (для совместимости с TLinks)
  end;
(*
//------------------------------ список связок с параллельным списком источников
  TSrcLinkList = class(TLinkList)
  protected
    FarSrc: TByteDynArray;
    procedure TestSrcLength(CS: TCriticalSection; cutByCap: Boolean=False); // проверить длину массива источников
    function NotAllowSrcIndex(pIndex: Integer; CS: TCriticalSection): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function CheckSrcLinkListItem(pID: Integer; pSrcID: Byte; pPtr: Pointer; // проверить / добавить элемент (возвращает индекс)
             lkind: TLLKind; CS: TCriticalSection; Compare: TListSortCompare=nil): Integer;
    procedure AddSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection);   // добавить источник по индексу
    procedure CheckSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection); // проверить источник по индексу
    function DelLinkListItemByID(pID: Integer; lkind: TLLKind;                      // удалить элемент по коду (возвращает индекс)
             CS: TCriticalSection; Compare: TListSortCompare=nil): Integer; override;
//    procedure FreeUnusedMem(CS: TCriticalSection); override; // освободить лишнюю память
    property arItemSrc: TByteDynArray read FarSrc;
  end;
*)
//----------------------------------------------------------------------- связки
  TLink = Class (TObject) // простой линк
  protected
    FLinkPtr: Pointer;
    FSrcID  : Byte;
    FLinkOpts: set of T8InfoKinds;
    function GetLinkItemID: Integer;
    function GetLinkBool(ik: T8InfoKinds): boolean;         // получить признак
    procedure SetLinkBool(ik: T8InfoKinds; Value: boolean); // записать признак
  public
    constructor Create(pSrcID: Integer; pLinkPtr: Pointer);
    destructor Destroy; override;
    property LinkID : Integer read GetLinkItemID;           // Код связанного элемента
    property SrcID  : Byte    read FSrcID write FSrcID;     // Код источника связи
    property State  : boolean index ik8_1 read GetLinkBool write SetLinkBool; // признак проверки
    property LinkPtr: Pointer read FLinkPtr write FLinkPtr; // ссылка на связанный элемент
  end;

//-----------------------------
  TLinkLink = Class (TLink) // линк с набором дочерних линков
  protected
    FDoubleLinks: TLinkList; // Create в CheckDoubleLink
  public
    constructor Create(pSrcID: Integer; pLinkPtr: Pointer);
    destructor Destroy; override;
    procedure CheckDoubleLinks(CS: TCriticalSection);
    property DoubleLinks: TLinkList read FDoubleLinks;     // двойные связки
  end;
//-----------------------------
  TQtyLink = Class (TLink) // линк с количеством
  protected
    FQty: Single;
  public
    constructor Create(pSrcID: Integer; pQty: Single; pLinkPtr: Pointer);
    property Qty: Single read FQty write FQty;       // количество
  end;
//-----------------------------
  TTwoLink = Class (TLink) // линк с 2-мя ссылками
  protected
    FLinkPtrTwo: Pointer;
    function GetLinkTwoItemID: Integer;
  public
    constructor Create(pSrcID: Integer; pLinkPtr, pLinkPtrTwo: Pointer);
    property LinkTwoID : Integer read GetLinkTwoItemID;              // Код 2-го связанного элемента
    property LinkPtrTwo: Pointer read FLinkPtrTwo write FLinkPtrTwo; // ссылка на 2-й связанный элемент
  end;
//-----------------------------
  TFlagLink = Class (TLink) // линк с доп.признаком
  public
    constructor Create(pSrcID: Integer; pLinkPtr: Pointer; pFlag: Boolean);
    property Flag: boolean index ik8_2 read GetLinkBool write SetLinkBool; // доп.признак
  end;

//-----------------------------
  TLinks = Class (TObject) // набор линков с каким-либо справочником
  protected
    FItems: TList;            // список ссылок на линки
    function GetLinkItemByID(pID: Integer): Pointer; virtual; // Получить линк по коду связанного элемента
    function GetLinkCount: Integer;
    procedure ListGrow(addCount: Integer=1);
  public
    CS_links: TCriticalSection; // ссылка на CriticalSection - заданную или общую
    constructor Create(CS: TCriticalSection=nil);
    destructor Destroy; override;
    property Items[ID: Integer]: Pointer read GetLinkItemByID; default; // доступ к связке по коду связанного элемента
    property ListLinks: TList read FItems;                 // список ссылок на связки (если надо перебрать связки)
    property LinkCount: Integer read GetLinkCount;         // кол-во связок

    function LinkExists(ID: Integer): Boolean;               // проверка существования связки
    function GetLinkCodes: Tai;                              // список кодов объектов 1-й связки
    procedure SortByLinkName;                                // сортирует связки по имени связ.элемента
    procedure SortByLinkOrdNumAndName;                       // сортирует связки по пор.№ и имени связ.элемента (TSubDirItem)
    procedure LinkSort(Compare: TListSortCompare);           // сортирует связки по заданному алгоритму
    function GetLinkItemByName(pName: String): Pointer;      // Возвращает ссылку на элемент с наименованием pName, если нет - nil

    procedure SetLinkStates(pState: Boolean);                // устанавливает флаг проверки всем связкам
    procedure DelNotTestedLinks;                             // удаляет все элементы с State=False

    function AddLinkItem(NewItem: Pointer): Integer;            // добавление связки
    function AddLinkItems(NewItems: TList): Integer; virtual;   // добавление набора связок
    function InsertLink(NewItem, BeforeItem: Pointer): Boolean; // вставка связки NewItem перед связкой BeforeItem
    function CheckLink(pLinkID, pSrcID: Integer; pLinkPtr: Pointer): Pointer; virtual; // добавление / проверка связки
    procedure DeleteLinkItem(Item: Pointer); overload; // удаление связки по ссылке на связку
    procedure DeleteLinkItem(ID: Integer); overload;   // удаление связки по коду связ.элемента

    procedure FreeAddMem; // освободить лишнюю память
  end;

//-----------------------------
  TLinkLinks = Class (TLinks) // набор двойных линков с каким-либо справочником
  public
    destructor Destroy; override;
    function DoubleLinkExists(ID1, ID2: Integer): Boolean; overload;           // проверка существования 2-й связки по кодам связ.элементов
    function DoubleLinkExists(Item: Pointer; ID2: Integer): Boolean; overload; // проверка существования 2-й связки по ссылке на 1-ю связку и коду связ.элемента 2-й
    function GetDoubleLinks(ID: Integer): TLinkList; overload;   // двойные связки 1-й связки по коду связ.элемента
    function GetDoubleLinks(Item: Pointer): TLinkList; overload; // двойные связки 1-й связки по ссылке на связку
  end;

//------------------------------------------------------------------- справочник
  TBaseDirItem = Class (TObject) //========= базовый элемент справочника
  protected
    FID   : Integer;   // Код
    FName : String;    // Наименование
    FDirBoolOpts: set of T8InfoKinds; // признаки
    function GetName: String; virtual;               // получить FName
    procedure SetName(const Value: String); virtual; // записать FName
    function GetDirBool(const ik: T8InfoKinds): boolean;         // получить признак
    procedure SetDirBool(const ik: T8InfoKinds; Value: boolean); // записать признак
  public
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    property ID   : Integer read FID;                                     // Код
    property Name : String  read GetName write SetName;                   // Наименование
    property State: boolean index ik8_1 read GetDirBool write SetDirBool; // Статус проверки
  end;
//-----------------------------
  TDirItem = Class (TBaseDirItem) //========= элемент справочника со связками
  protected
    FLinks: TLinks;    // набор связок с другим справочником
  public
    constructor Create(pID: Integer; pName: String; WithLinks: Boolean=False);
    destructor Destroy; override;
    property Links: TLinks  read FLinks; // набор связок (при WithLinks=False = nil)
  end;
//-----------------------------
  TSubDirItem = Class (TDirItem) //============ элемент справочника с доп.кодами
  protected
    FSrcID   : Byte;    // источник данных
    FOrderNum: Integer; // порядк.№
    FSubCode : Integer; // доп.код (код TecDoc или тип, группа и т.п.)
  public
    constructor Create(pID, pSubCode, pOrderNum: Integer; pName: String;
                       pSrcID: Integer=0; WithLinks: Boolean=False);
    property SubCode : Integer read FSubCode  write FSubCode;  // доп.код
    property OrderNum: Integer read FOrderNum write FOrderNum; // порядк.№
    property SrcID   : Byte    read FSrcID    write FSrcID;    // источник данных
  end;
//-----------------------------
  TSubVisDirItem = Class (TSubDirItem) // элемент справочника с признаком видимости и Parent кодом
  protected
    FParCode  : Integer;   // Parent код
  public
    property ParCode  : Integer read FParCode;   // Parent код
    property IsVisible: boolean index ik8_2 read GetDirBool write SetDirBool; // Признак видимости
  end;
//-----------------------------
  TDirItems = Class (TObject) //========= набор элементов справочника (Index=ID)
  protected
    FSetLengthStep: Integer;          // приращение длины массива при добавлении элементов (def 10)
    FItems        : array of Pointer; // разреженный массив ссылок на элементы справочника
    FItemsList    : TList;            // список ссылок на элементы (для сортировки в нужном порядке)
    function GetCount: Integer;
    function GetMaxCode: Integer;
    function GetItem(pIndex: Integer): Pointer;
  public
    CS_DirItems: TCriticalSection;
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    function ItemExists(pID: Integer): Boolean;        // проверка существования элемента справочника по коду
    function GetDirCodes: Tai;                         // массив кодов элементов справочника
    procedure SortDirListByName;                       // сортирует список ссылок по имени элемента
    procedure SortDirListByOrdNumAndName;              // сортирует список ссылок по пор.№ и имени связ.элемента
    procedure DirSort(Compare: TListSortCompare);      // сортирует список ссылок по заданному алгоритму
    function CheckItem(var NewItem: Pointer): Boolean; // добавление / проверка элемента
    procedure CheckLength;                             // обрезать длину по максимальному коду
    function DeleteItem(pID: Integer): Boolean;        // удаление элемента
    function GetItemName(pID: Integer): String;        // Возвращает Наименование элемента
    procedure SetItemName(pID: Integer; pName: String);  // изменить Наименование элемента
    function GetDirItem(pIndex: Integer): TDirItem;         // Возвращает элемент с кодом-индексом pIndex, если нет - 0-й
    function GetIDBySubCode(pSubCode: Integer): Integer; virtual; // получить ID по SubCode
//    function GetIDByName(pName: String): Integer; virtual;  // получить ID по имени
    function GetListSubCodeItems(pSubCode: Integer): TList; // Список элементов с SubCode=pSubCode
    procedure SetDirStates(pState: Boolean);                // устанавливает флаг проверки всем элементам и их линкам
    procedure DelDirNotTested;                              // удаляет все непроверенные элементы
    property DirItems[index: Integer]: Pointer read GetItem; default; // получить ссылку на элемент справочника по коду
    property Count    : Integer read GetCount;         // кол-во элементов справочника
    property ItemsList: TList read FItemsList;         // список ссылок на элементы
    property MaxCode  : Integer read GetMaxCode;       // максимальный код элементов справочника
  end;

//=================== набор элементов справочника (Index=ID) со своей нумерацией
  TOwnDirItems = Class (TDirItems)
  protected
    FFreeCode: Integer; // свободный код
    function GetCode: Integer;
  public
    constructor Create(LengthStep: Integer=10);
    function AddItem(var NewItem: Pointer): Boolean; // добавление элемента с генерацией кода
    function FindByName(pName: String; var FindItem: Pointer): Boolean;
//    function FindBySubCode(SubID: Integer; var FindItem: Pointer): Boolean;
  end;

//-----------------------------
  TDirObjects = Class (TObjectList) //========= набор элементов справочника (Object-TBaseDirItem)
  protected
    function GetObjItem(pID: Integer): TObject;
  public
    CS_DirObj: TCriticalSection;
    constructor Create;
    destructor Destroy; override;
//    function ItemExists(pID: Integer): Boolean;
    function FindObjItem(pID: Integer; var obj: TObject): Boolean; // поиск элемента справочника по коду
    procedure SetDirStates(pState: Boolean);    // устанавливает флаг проверки всем элементам и их линкам
    procedure DelDirNotTested;                  // удаляет все непроверенные элементы
    property ObjItems[index: Integer]: TObject read GetObjItem; // default; получить ссылку на элемент справочника по коду
  end;

//------------------------------------------------------- набор списков по типам
  TArrayTypeLists = Class (TObject)
  private
    FSortList: Boolean;                                 // признак сортировки всех списков
    function GetTypeList(TypeID: Word): TStringList;    // Получить список нужного типа (в Objects - что положили)       
    function GetListTypes: TStringList;                 // = FarLists[0] - набор типов списков (в Objects - ID>0)
  protected
    FDelimiterFlag: Boolean;                            // Delimiter - флаг изменений
    FarLists: TASL;                                     // Массив списков
  public
    CS_ATLists: TCriticalSection;
    constructor Create(fSorted: Boolean=False; fDelimiter: Boolean=False);
    destructor Destroy; override;
    property Items[TypeID: Word]: TStringList read GetTypeList; default;     // список нужного типа
    property ListTypes: TStringList read GetListTypes;                       // набор типов списков
    property SortList : Boolean     read FSortList write FSortList;          // признак сортировки всех списков
    function GetListTypesCount: Word;                                        // кол-во типов списков
    function GetTypeListCount(TypeID: Word): Integer;                        // кол-во элементов в списке нужного типа
    function CheckTypeOfList(TypeID: Word): boolean;                         // Проверить код типа
    function TypeOfListExists(TypeID: Word): boolean;                        // Проверить существование списка
    function AddTypeOfList(TypeID: Word; TypeName: String): boolean;         // Добавить тип списка
    procedure ClearTypeList(TypeID: Word);                                   // очистить список
    procedure SetTypeListDelimiter(TypeID: Word; delim: Char);               // изменить Delimiter
    function AddTypeListItems(TypeID: Word; list: TStringList; fClear: Boolean=False): boolean; // Добавить набор элементов в список типа
    // если в Objects - ID
    function GetTypeListItemIDByName(TypeID: Word; pName: String): Integer;                 // найти код элемента из списка по имени
    function TypeListItemExists(TypeID: Word; pID: Integer): boolean; overload;             // Проверить существование элемента списка
    function AddTypeListItem(TypeID: Word; pID: Integer; pName: String): boolean; overload; // Добавить элемент в список
    function DelTypeListItem(TypeID: Word; pID: Integer): boolean; overload;                // удалить элемент из списка
    // если в Objects - ссылка на объект
    function TypeListItemExists(TypeID: Word; p: Pointer): boolean; overload;             // Проверить существование элемента списка
    function AddTypeListItem(TypeID: Word; p: Pointer; pName: String): boolean; overload; // Добавить элемент в список
    function DelTypeListItem(TypeID: Word; p: Pointer): boolean; overload;                // удалить элемент из списка
  end;

var EmptyStringList: TStringList; // пустой TStringList - чтобы не возвращать nil
    EmptyIntegerList: TIntegerList; // пустой TIntegerList - чтобы не возвращать nil
    EmptyList: TList;             // пустой TList - чтобы не возвращать nil
    CS_any: TCriticalSection;     // общая TCriticalSection для изменения линков
//                          справочники
  function GetDirItemID(Item: Pointer): Integer;      // ID элемента TSubDirItem
  function GetDirItemName(Item: Pointer): String;     // имя элемента TSubDirItem
  function GetDirItemOrdNum(Item: Pointer): Integer;  // пор.№ элемента TSubDirItem
  function GetDirItemSubCode(Item: Pointer): Integer; // SubCode элемента TSubDirItem
  function GetDirItemSrc(Item: Pointer): Integer;     // SrcID элемента TSubDirItem
//                          связки
  function GetLinkID(link: Pointer): Integer;         // ID связ.элемента по ссылке на связку
  function GetLinkName(link: Pointer): String;        // имя связ.элемента по ссылке на связку
  function GetLinkPtr(link: Pointer): Pointer;        // ссылка на связ.элемент по ссылке на связку
  function GetLinkSrc(link: Pointer): Integer;        // источник связ.элемента по ссылке на связку
  function GetLinkQty(link: Pointer): Double;         // кол-во по ссылке на связку
 procedure SetLinkQty(link: Pointer; pQty: Double; cs: TCriticalSection); // новое кол-во по ссылке на связку
//                          сортировки
  function LinkNameSortCompare(Item1, Item2: Pointer): Integer;    // сортировка линков по наимен. связ.объекта
  function LinkNumNameSortCompare(Item1, Item2: Pointer): Integer; // сортировка линков по пор.№ + наимен. связ.объекта TSubDirItem
  function DirNameSortCompare(Item1, Item2: Pointer): Integer;     // сортировка TList по наимен. объекта TBaseDirItem
  function DirNumNameSortCompare(Item1, Item2: Pointer): Integer;  // сортировка TList по пор.№ + наимен. объекта TSubDirItem
  function DirNumNameSortCompareSL(List: TStringList; Index1, Index2: Integer): Integer; // сортировка TStringList (Objects-TSubDirItem) по пор.№ + наимен.

implementation
//******************************************************************************
//                          сортировки
//******************************************************************************
//================================ сортировка TList объектов TDirItem по наимен.
function DirNameSortCompare(Item1, Item2: Pointer): Integer;
begin
  try
    Result:= AnsiCompareText(GetDirItemName(Item1), GetDirItemName(Item2));
  except
    Result:= 0;
  end;
end;
//===================== сортировка TList объектов TSubDirItem по пор.№ + наимен.
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
//======================== сортировка TList линков по наимен. связанного объекта
function LinkNameSortCompare(Item1, Item2: Pointer): Integer;
begin
  try
    Result:= AnsiCompareText(GetLinkName(Item1), GetLinkName(Item2));
  except
    Result:= 0;
  end;
end;
//======== сортировка TList линков по пор.№ и наимен. связ.объекта (TSubDirItem)
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
//============ сортировка TStringList (Objects-TSubDirItem) по порядк.№ +наимен.
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
//                          справочники
//******************************************************************************
//========================================================= ID элемента TDirItem
function GetDirItemID(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TBaseDirItem(Item).ID;
end;
//======================================================== имя элемента TDirItem
function GetDirItemName(Item: Pointer): String;
begin
  if not Assigned(Item) then Result:= '' else Result:= TBaseDirItem(Item).Name;
end;
//=================================================== пор.№ элемента TSubDirItem
function GetDirItemOrdNum(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TSubDirItem(Item).OrderNum;
end;
//================================================= SubCode элемента TSubDirItem
function GetDirItemSubCode(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TSubDirItem(Item).SubCode;
end;
//=================================================== SrcID элемента TSubDirItem
function GetDirItemSrc(Item: Pointer): Integer;
begin
  if not Assigned(Item) then Result:= 0 else Result:= TSubDirItem(Item).SrcID;
end;

//******************************************************************************
//                          связки
//******************************************************************************
//================================== код связанного элемента по ссылке на связку
function GetLinkID(link: Pointer): Integer;
begin
  if not Assigned(link) then Result:= 0 else Result:= TLink(link).LinkID;
end;
//================================== имя связанного элемента по ссылке на связку
function GetLinkName(link: Pointer): String;
begin
  if not Assigned(link) then Result:= '' else Result:= GetDirItemName(GetLinkPtr(link));
end;
//============================== ссылка на связанный элемент по ссылке на связку
function GetLinkPtr(link: Pointer): Pointer;
begin
  if not Assigned(link) then Result:= nil else Result:= TLink(link).LinkPtr;
end;
//============================= источник связанного элемента по ссылке на связку
function GetLinkSrc(link: Pointer): Integer;
begin
  if not Assigned(link) then Result:= 0 else Result:= TLink(link).SrcID;
end;
//=================================================== кол-во по ссылке на связку
function GetLinkQty(link: Pointer): Double;
begin
  Result:= 0;
  if not Assigned(link) then Exit;
  try
    Result:= TQtyLink(link).Qty;
  except end;  
end;
//============================================= новое кол-во по ссылке на связку
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
  FarLists[0]:= TStringList.Create; // набор типов списков (в Objects - ID>0)
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
//========================================================= кол-во типов списков
function TArrayTypeLists.GetListTypesCount: Word;
begin
  if not Assigned(self) then Result:= 0 else Result:= FarLists[0].Count;
end;
//======================================== кол-во элементов в списке типа TypeID
function TArrayTypeLists.GetTypeListCount(TypeID: Word): Integer;
begin
  if not Assigned(self) then Result:= 0 else Result:= FarLists[TypeID].Count;
end;
//========================================== Проверить существование типа TypeID
function TArrayTypeLists.CheckTypeOfList(TypeID: Word): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= FarLists[0].IndexOfObject(Pointer(TypeID))>-1;
end;
//======================================= Получить ссылку на набор типов списков
function TArrayTypeLists.GetListTypes: TStringList;
begin
  if not Assigned(self) then Result:= EmptyStringList else Result:= FarLists[0];
end;
//======================================== Получить ссылку на список типа TypeID
function TArrayTypeLists.GetTypeList(TypeID: Word): TStringList;
begin
  if Assigned(self) and TypeOfListExists(TypeID) then Result:= FarLists[TypeID]
  else Result:= EmptyStringList;
end;
//=================================== Проверить существование списка типа TypeID
function TArrayTypeLists.TypeOfListExists(TypeID: Word): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= (TypeID>0) and (TypeID<Length(FarLists)) and Assigned(FarLists[TypeID]);
end;
//========================================================== Добавить тип списка
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
//================================ Добавить набор элементов в список типа TypeID
function TArrayTypeLists.AddTypeListItems(TypeID: Word; list: TStringList; fClear: Boolean=False): boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) or not TypeOfListExists(TypeID) then Exit; // такого типа нет
  CS_ATLists.Enter;
  try
    with GetTypeList(TypeID) do begin
      if FDelimiterFlag then Delimiter:= LCharUpdate;
      if FSortList then Sorted:= False; // отключаем сортировку
      if fClear then Clear;
      if list.Count>0 then begin
        Capacity:= Capacity+list.Count;
        for i:= 0 to list.Count-1 do AddObject(list.Strings[i],list.Objects[i]);
      end;
      if FSortList then begin
        if Count>1 then Sort;
        Sorted:= True;  // включаем сортировку
      end;
      if FDelimiterFlag then Delimiter:= LCharGood;
    end;
    Result:= True;
  finally
    CS_ATLists.Leave;
  end;
end;
//======================================== изменить Delimiter списка типа TypeID
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
//============= найти код элемента из списка типа TypeID по имени (в Objects-ID)
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
//================================================== очистить список типа TypeID
procedure TArrayTypeLists.ClearTypeList(TypeID: Word);
begin
  if not Assigned(self) or not TypeOfListExists(TypeID) then Exit; // такого типа нет
  with GetTypeList(TypeID) do if Count>0 then try
    CS_ATLists.Enter;
    Clear;
  finally
    CS_ATLists.Leave;
  end;
end;
//========================== Проверить существование элемента списка типа TypeID
function TArrayTypeLists.TypeListItemExists(TypeID: Word; pID: Integer): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= TypeListItemExists(TypeID,Pointer(pID));
end;
//========================== Проверить существование элемента списка типа TypeID
function TArrayTypeLists.TypeListItemExists(TypeID: Word; p: Pointer): boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= TypeOfListExists(TypeID) and (GetTypeList(TypeID).IndexOfObject(p)>-1);
end;
//======================================== Добавить элемент в список типа TypeID
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
  if not TypeOfListExists(TypeID) then Exit; // такого типа нет
  if TypeListItemExists(TypeID, p) then Exit; // такой элемент уже есть
  with GetTypeList(TypeID) do try
    CS_ATLists.Enter;
    if FDelimiterFlag then Delimiter:= LCharUpdate;
    if FSortList then Sorted:= False; // отключаем сортировку
    Result:= AddObject(pName, p)>-1;
    if FSortList then begin
      if Count>1 then Sort;
      Sorted:= True;  // включаем сортировку
    end;
    if FDelimiterFlag then Delimiter:= LCharGood;
  finally
    CS_ATLists.Leave;
  end;
end;
//======================================== удалить элемент из списка типа TypeID
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
  if not TypeOfListExists(TypeID) then Exit; // такого типа нет
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
  Result:= (i<0) or not TypeListItemExists(TypeID, p); // проверяем, что такого элемента нет
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
//============================================================= записать признак
procedure TLink.SetLinkBool(ik: T8InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FLinkOpts:= FLinkOpts+[ik] else FLinkOpts:= FLinkOpts-[ik];
end;
//============================================================= получить признак
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
//============================================================ Количество связок
function TLinks.GetLinkCount: Integer;
begin
  if not Assigned(self) then Result:= 0 else Result:= FItems.Count;
end;
//===========================================  проверка существования 1-й связки
function TLinks.LinkExists(ID: Integer): Boolean;
begin
  Result:= Assigned(self) and Assigned(GetLinkItemByID(ID));
end;
//===================== Возвращает ссылку на элемент с кодом pID, если нет - nil
function TLinks.GetLinkItemByID(pID: Integer): Pointer;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) or (pID<1) then Exit;
  for i:= 0 to FItems.Count-1 do   // Поиск необходимого элемента
    if Assigned(FItems[i]) and (GetLinkID(FItems[i])=pID) then begin
      Result:= FItems[i];
      Exit;
    end;
end;
//=========== Возвращает ссылку на элемент с наименованием pName, если нет - nil
function TLinks.GetLinkItemByName(pName: String): Pointer;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  for i:= 0 to FItems.Count-1 do   // Поиск необходимого элемента
    if Assigned(FItems[i]) and (GetLinkName(FItems[i])=pName) then begin
      Result:= FItems[i];
      Exit;
    end;
end;
//============================== вставка связки NewItem перед связкой BeforeItem
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
//============================================= добавление / проверка 1-й связки
function TLinks.CheckLink(pLinkID, pSrcID: Integer; pLinkPtr: Pointer): Pointer;
var Link: TLink;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Link:= GetLinkItemByID(pLinkID);
  CS_Links.Enter;
  try
    if Assigned(Link) then begin // если с таким кодом уже есть - проверяем
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
//===================================================== освободить лишнюю память
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
//====================================== сортирует связки по имени связ.элемента
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
//============================== сортирует связки по пор.№ и имени связ.элемента
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
//====================================== сортирует связки по заданному алгоритму
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
//============================================================== Добавить связку
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
//============================================= Добавить порцию ссылок на связки
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
        FItems.Add(NewItems[i]); // добавляем ссылку на линк
        NewItems[i]:= nil;
        inc(Result);
      except end;
  finally
    CS_Links.Leave;
  end;
end;
//===================================================== Удалить связку из списка
procedure TLinks.DeleteLinkItem(ID: Integer);    // по коду связ.элемента
var DelItem: Pointer;
begin
  if not Assigned(self) then Exit;
  DelItem:= GetLinkItemByID(ID);
  if Assigned(DelItem) then DeleteLinkItem(DelItem);
end;
//==================================
procedure TLinks.DeleteLinkItem(Item: Pointer);  // по ссылке на связку
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
//========================================= получить список кодов связ.элементов
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
//=================================== устанавливает флаг проверки всем элементам
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
//=========================================== удаляет все элементы с State=False
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
//==================================================== двойные связки 1-й связки
function TLinkLinks.GetDoubleLinks(ID: Integer): TLinkList; // по коду связ.элемента
begin
  if not Assigned(self) then Result:= nil else Result:= GetDoubleLinks(GetLinkItemByID(ID));
end;
//==================================
function TLinkLinks.GetDoubleLinks(Item: Pointer): TLinkList; // по ссылке на связку
begin
  if not Assigned(self) or not Assigned(Item) then Result:= nil
  else Result:= TLinkLink(Item).FDoubleLinks;
end;
//===========================================  проверка существования 2-й связки
function TLinkLinks.DoubleLinkExists(ID1, ID2: Integer): Boolean;
begin
  if not Assigned(self) then Result:= False
  else Result:= DoubleLinkExists(GetLinkItemByID(ID1), ID2);
end;
// проверка существования 2-й связки по ссылке на 1-ю связку и коду связ.элемента 2-й
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
  FSubCode := pSubCode; // код TecDoc или тип, группа и т.п.
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
  FItems[0]:= TDirItem.Create(0, '', True); // фиктивный элемент с пустым набором связок, чтобы не возвращать nil
  FItemsList:= TList.Create;                // список ссылок на элементы
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
//========================================================= Количество элементов
function TDirItems.GetCount: Integer;
begin
  if not Assigned(self) then Result:= 0 else Result:= FItemsList.Count;
end;
//============================================== получить список кодов элементов
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
//========= Возвращает ссылку на элемент с кодом-индексом pIndex, если нет - 0-й
function TDirItems.GetItem(pIndex: Integer): Pointer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
//  CS_DirItems.Enter; // Если критическая секция активна, надо ждать
  try
    if ItemExists(pIndex) then Result:= FItems[pIndex] else Result:= FItems[0];
//  finally
//    CS_DirItems.Leave;
  except
  end;
end;
//=================== Возвращает элемент с кодом-индексом pIndex, если нет - 0-й
function TDirItems.GetDirItem(pIndex: Integer): TDirItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TDirItem(DirItems[pIndex]);
end;
//======================================= сортирует справочник по имени элемента
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
//=============================== сортирует справочник по пор.№ и имени элемента
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
//================================== сортирует справочник по заданному алгоритму
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
//================================================= Добавить / проверить элемент
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
      if Assigned(oldItem) then begin // если с таким кодом есть - проверяем имя
        oldItem.Name:= item.FName;
        prFree(item);
        oldItem.State:= True;
        NewItem:= oldItem;
      end else begin             // если нет - добавляем
        if High(FItems)<i then begin
          jj:= Length(FItems);                  // добавляем длину массива
          SetLength(FItems, i+FSetLengthStep);  // и инициируем элементы
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
//============================================================== удалить элемент
function TDirItems.DeleteItem(pID: Integer): Boolean;
var i: Integer;
begin
  Result:= False;
  if not Assigned(self) or not ItemExists(pID) then Exit; // с таким кодом нет
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
//============================================= Возвращает Наименование элемента
function TDirItems.GetItemName(pID: Integer): String;
begin
  if not Assigned(self) or not ItemExists(pID) then Result:= '' // с таким кодом нет
  else Result:= TBaseDirItem(FItems[pID]).Name;
end;
//=============================================== изменить Наименование элемента
procedure TDirItems.SetItemName(pID: Integer; pName: String);
begin
  if not Assigned(self) or not ItemExists(pID) then Exit; // с таким кодом нет
  CS_DirItems.Enter;
  try
    TBaseDirItem(FItems[pID]).Name:= pName;
  finally
    CS_DirItems.Leave;
  end;
end;
//=================================== устанавливает флаг проверки всем элементам
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
//=========================================== удаляет все элементы с State=False
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
//======================================================= получить ID по SubCode
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
{//========================================================= получить ID по имени
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
//========================================== Список элементов с SubCode=pSubCode
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
//========================================= обрезать длину по максимальному коду
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
//======================================= максимальный код элементов справочника
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
//                             TCacheList   заготовка
//******************************************************************************
{constructor TCacheList.Create(aClass: TClass=nil);
begin
  inherited Create;
  if not Assigned(aClass) then aClass:= TSubDirItem;
  FItemClass:= aClass;
  FListState:= lsEmpty;
end;
//======================================================= назначить новый статус
procedure TCacheList.SetState(NewState: TListState);
begin
  if (FListState<>NewState) then FListState:= NewState;
end;
//============================================================== проверить класс
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
//============================================================ признак видимости
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
//============================================== проверка существования элемента
function TLinkList.LinkListItemExists(pID: Integer; lkind: TLLKind): Boolean;
begin
  Result:= GetLinkListItemIndexByID(pID, lkind)>-1;
end;
//============================================= получить индекс элемента по коду
function TLinkList.GetLinkListItemIndexByID(pID: Integer; lkind: TLLKind): Integer;
var iLow, iHigh, iNum: Integer;
begin
  Result:= -1;
  if not Assigned(self) or (pID<1) then Exit;

  iLow:= 0;              // нижний индекс
  iHigh:= Count-1;       // верхний индекс
  case lkind of
    lkDirByID, lkLnkByID: begin //-------------------- метод половинного деления
      while (iHigh-iLow)>4 do begin
        Result:= (iLow+iHigh) div 2;        // индекс среднего эл-та
        iNum:= GetItemID(Items[Result], lkind); // ID среднего эл-та

        if (iNum=pID) then Exit
        else if (pID<iNum) then iHigh:= Result-1 else iLow:= Result+1;

      end;
      for Result:= iLow to iHigh do // ищем перебором в оставшемся интервале
        if GetItemID(Items[Result], lkind)=pID then Exit;
    end; // lkDirByID

    else for Result:= iLow to iHigh do //----------------------- Поиск перебором
      if Assigned(Items[Result]) and (GetItemID(Items[Result], lkind)=pID) then Exit;
  end; // case
  Result:= -1;
end;
//======================================================== найти элемент по коду
function TLinkList.GetLinkListItemByID(pID: Integer; lkind: TLLKind): Pointer;
var i: Integer;
begin
  Result:= nil;
  if not Assigned(self) or (pID<1) then Exit;
  i:= GetLinkListItemIndexByID(pID, lkind); // получаем индекс по коду
  if (i>-1) then Result:= Items[i];
end;
//============================================ найти индекс для вставки элемента
function TLinkList.GetIndexForInsItem(pItem: Pointer; lkind: TLLKind;
                                      Compare: TListSortCompare): Integer;
var pID: Integer;
begin
  Result:= -1;
  if not Assigned(self) or not Assigned(pItem) then Exit;
  pID:= GetItemID(pItem, lkind);       // получаем код
  if (pID<1) then Exit;

  case lkind of
    lkDirByID, lkLnkByID:  //------------------------------- сортировка по коду
      if (Count<1) or (GetItemID(Last, lkind)<pID) then Result:= Count
      else begin
        Result:= 0;
        while (Result<Count) and (GetItemID(Items[Result], lkind)<pID) do inc(Result);
      end; // lkDirByID

    else Result:= Count;
  end; // case
end;
//========================================= добавить элемент (возвращает индекс)
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
    if (Result<Count) then Insert(Result, pItem) else Result:= Add(pItem); // вставляем / добавляем
  except
    Result:= -1;
  end;
  CS.Leave;
end;
//====================================================== удалить элемент по коду
function TLinkList.DelLinkListItemByID(pID: Integer; lkind: TLLKind;
         CS: TCriticalSection; Compare: TListSortCompare): Integer;
begin
  Result:= -1;
  if not Assigned(self) or (pID<1) then Exit;
  Result:= GetLinkListItemIndexByID(pID, lkind); // получаем индекс по коду
  if (Result<0) then Exit;
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    Delete(Result);               // удаляем
//    Capacity:= Count;             // обрезаем
  except
    Result:= -1;
  end;
  CS.Leave;
end;
//========================================= получить список кодов связ.элементов
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
//===================================================== освободить лишнюю память
{procedure TLinkList.FreeUnusedMem(CS: TCriticalSection);
var delta: Byte;
begin
  if not Assigned(self) or ((Capacity-Count)<4) then Exit;
  delta:= 4-(Count mod 4);
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    Capacity:= Count+delta; // обрезаем, оставляем запас до 4    ???
  finally
    CS.Leave;
  end;
end; }
//=================================== кол-во связок (для совместимости с TLinks)
function TLinkList.GetLinkCount: Integer;
begin
  Result:= Count;
end;
//=================================== устанавливает флаг проверки всем элементам
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
//=========================================== удаляет все элементы с State=False
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
//============================== проверить валидность индекса массива источников
function TSrcLinkList.NotAllowSrcIndex(pIndex: Integer; CS: TCriticalSection): Boolean;
begin
  Result:= not Assigned(self) or (pIndex<0);
  if Result then Exit;
  TestSrcLength(CS);
  Result:= pIndex>High(FarSrc);
end;
//=========================================== проверить длину массива источников
procedure TSrcLinkList.TestSrcLength(CS: TCriticalSection; cutByCap: Boolean=False);
// cutByCap=True - обрезать по Capacity, False - только увеличивать
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
    SetLength(FarSrc, Capacity); // новая длина
    for i:= Count to Length(FarSrc)-1 do FarSrc[i]:= 0; // обнуляем лишние
  except end;
  CS.Leave;
end;
//================================================= добавить источник по индексу
procedure TSrcLinkList.AddSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection);
var i: Integer;
begin
  if not Assigned(self) or NotAllowSrcIndex(pIndex, CS) then Exit;
  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    if pIndex<(Count-1) then // если не последний - переносим источники
      for i:= Count-1 downto pIndex+1 do FarSrc[i]:= FarSrc[i-1];
    FarSrc[pIndex]:= pSrcID; // пишем значение
  except end;
  CS.Leave;
end;
//================================================ проверить источник по индексу
procedure TSrcLinkList.CheckSrcByIndex(pIndex: Integer; pSrcID: Byte; CS: TCriticalSection);
begin
  if not Assigned(self) or NotAllowSrcIndex(pIndex, CS) then Exit;

  if FarSrc[pIndex]=pSrcID then Exit;

  if not assigned(CS) then CS:= CS_any;
  CS.Enter;
  try
    FarSrc[pIndex]:= pSrcID; // меняем значение
  except end;
  CS.Leave;
end;
//====================================================== удалить элемент по коду
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
    for i:= Result to Count-1 do FarSrc[i]:= FarSrc[i+1];  // переносим источники
    FarSrc[Count]:= 0;
  except end;
  CS.Leave;
end;
//===================================================== освободить лишнюю память
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
  if (Result>-1) then begin               // если есть - проверяем источник
    CheckSrcByIndex(Result, pSrcID, CS);
    Exit;
  end;

  Result:= AddLinkListItem(pPtr, lkind, CS, Compare); // вставляем / добавляем

  if Result>-1 then AddSrcByIndex(Result, pSrcID, CS); // добавляем источник
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
  FFreeCode:= 1; // свободный код
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
        jj:= Length(FItems);                        // добавляем длину массива
        SetLength(FItems, item.ID+FSetLengthStep);  // и инициируем элементы
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
begin // пустой список - чтобы не возвращать nil
  EmptyStringList:= fnCreateStringList(False, LCharGood);
  EmptyIntegerList:= TIntegerList.Create;
  EmptyList:= TList.Create;             // пустой TList - чтобы не возвращать nil
  CS_any:= TCriticalSection.Create; // для изменения линков, которым не назначена TCriticalSection и т.п.
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
