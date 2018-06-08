unit n_DataCacheInMemory;

interface

uses Windows, Classes, Types, SysUtils, Math, DateUtils, IniFiles, Forms, SyncObjs, Variants, Contnrs,
     IBDataBase, IBSQL, n_free_functions, v_constants, n_DataCacheAddition,
     n_constants, n_Functions, n_DataSetsManager, n_server_common, n_DataCacheObjects;

type                                            // проверяем длину массивов
  TArrayKind = (taWare, taDprt, taEmpl, taFirm, taClie, taCurr, taFtyp, taFcls, taWaSt);
// признаки TWareInfo - группа, подгруппа, товар, тип товара, признак заданного типа товара (1 байт)
  TKindBoolOptW = (ikwGrp, ikwPgr, ikwWare, ikwType, ikwTop, ikwFixT, ikwMod1, ikwMod2,
                   ikwNRet, ikwCatP, ikwPriz, ikwActN, ikwActM, ikwMod4, ikwMod5, ikwSea,
                   ikwNloa, ikwNpic);
  TFirmManagerParam = (fmpCode, fmpName, fmpEmail, fmpShort, fmpPref, fmpFacc);
  TFirmManagerParams = set of TFirmManagerParam;
  TSetWareParamKind = (spAll, spWithoutPrice, spOnlyPrice);

  //---------------------------------------------------------- линк для аналогов
  TAnalogLink = Class (TLink)
  public
    constructor Create(pSrcID: Integer; pWarePtr: Pointer; pAnalog, pCross: Boolean);
    property IsOldAnalog: boolean index ik8_3 read GetLinkBool write SetLinkBool; // признак аналога Гроссби
    property IsCross : boolean index ik8_4 read GetLinkBool write SetLinkBool; // признак аналога Гроссби
  end;

//---------------------------------------------------------------- система учета
  TSysItem = Class (TBaseDirItem)
  private
    FSysEmplID: Integer;
    FSysMail  : String;
  public
    constructor Create(pID: Integer; pName, pSysMail: String);
    property SysEmplID: Integer read FSysEmplID write FSysEmplID; // EmplID ответственного по системе учета
    property SysMail  : String  read FSysMail   write FSysMail;   // Email для сообщений по системе учета
  end;

//------------------------------------------------------------------------ бренд
  TBrandItem = Class (TBaseDirItem)
  private
    FWarePrefix, FNameWWW, FadressWWW: String;
    FTDMFcodes: Tai;
  public
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    property WarePrefix: String read FWarePrefix write FWarePrefix; // префикс бренда у товаров Grossbee
    property NameWWW   : String read FNameWWW    write FNameWWW;    // Наименование для файла логотипа
    property adressWWW : String read FadressWWW  write FadressWWW;  // адрес - ссылка на сайт
    property TDMFcodes : Tai    read FTDMFcodes; // список кодов TecDoc (TDT -> DATA_SUPPLIERS.DS_MF_ID)
    property DownLoadExclude: boolean index ik8_2 read GetDirBool write SetDirBool; // признак "не включать в прайс"
    property PictShowExclude: boolean index ik8_3 read GetDirBool write SetDirBool; // признак "не показывать картинки"
  end;

//----------------------------------------------------------------------- валюты
  TCurrency = Class (TBaseDirItem) // FName - shortname
  private
    FCurrRate: Single;
    FCliName : String;
  public
    constructor Create(pID: Integer; pName, pCliName: String; pRate: Single; pArh: Boolean);
    property Arhived  : boolean index ik8_3 read GetDirBool write SetDirBool; // признак архивности
//    property Available: boolean index ik8_4 read GetDirBool write SetDirBool; // признак применимости
    property CurrRate : Single read FCurrRate write FCurrRate;                // курс к гривне
    property CliName  : String read FCliName  write FCliName;                 // наименование в СВК для клиентов
  end;

  TCurrencies = Class (TDirItems)  // справочник валют
  private
    function GetCurrency(pCurrID: Integer): TCurrency; // получить элемент справочника по коду
  public
    function GetCurrRate(pCurrID: Integer): Single;                         // получить курс валюты к гривне
    property DirItems[index: Integer]: TCurrency read GetCurrency; default; // получить элемент справочника по коду
  end;

//------------------------------------------------------------- группы атрибутов
  TAttrGroupItem = Class (TDirItem) // 1 группа атрибутов
  private // в Links -  Список атрибутов группы
    FTypeSys : Byte;   // Тип системы 1 - Авто, 2 - Мото and etc.
    FOrderNum: Word;   // порядковый номер группы для вывода
  public
    constructor Create(pID, pTypeSys: Integer; pName: String; pOrderNum: Word=0);
    property TypeSys : Byte read FTypeSys;  // Тип системы 1 - Авто, 2 - Мото and etc.
    property OrderNum: Word read FOrderNum; // порядковый номер
    function GetListGroupAttrs: TList;      // must Free, Список ссылок на атрибуты группы, сортир. по порядк.№ +наимен.
  end;

  TAttrGroupItems = Class (TDirItems)  // справочник групп атрибутов
  private
    FTypeSysLists: TArraySysTypeLists; // набор сортированных списков групп по системам
  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    procedure SortTypeSysList(SysID: Word=0);                   // сортируем список групп атрибутов (SysID=0 - все)
    function GetListAttrGroups(pTypeSys: Integer): TStringList; // Получить Список групп системы, сортированный по наименованию
    function GetAttrGroup(grpID: Integer): TAttrGroupItem;      // Получить группу  по коду
  end;

//--------------------------------------------------------------------- атрибуты
  TAttributeItem = Class (TSubDirItem) // 1 атрибут
  private // FSubCode - Код группы, FOrderNum - порядковый номер атрибута для вывода
    FTypeAttr  : Byte;        // Тип
    FPrecision : Byte;        // кол-во знаков после запятой в типе Double
    FListValues: TStringList; // Список доступных значений атрибута
//    function GetAttrTypeSys: Byte; // получить систему атрибута
  public
    constructor Create(pID, pGroupID: Integer; pPrecision, pType: Byte;
                pOrderNum: Word; pName: String; pSrcID: Integer=0);
    destructor Destroy; override;
    property TypeAttr  : Byte        read FTypeAttr;   // Тип
    property Precision : Byte        read FPrecision;  // кол-во знаков после запятой в типе Double
    property ListValues: TStringList read FListValues; // Список значений атрибута с сортировкой в зав-ти от типа
    procedure CheckAttrStrValue(var pValue: String);   // проверяем корректность значения для атрибута
  end;

  TAttributeItems = Class (TDirItems)  // Справочник атрибутов
  private
    FAttrValues: TDirItems; // Справочник значений атрибутов
  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    function GetListAttrsOfGroup(pGrpID: Integer): TStringList; // must Free, Список ссылок на атрибуты группы, сортир. по порядк.№ +наимен.
    function GetAttr(attrID: Integer): TAttributeItem;          // получить атрибут по коду
    function GetAttrVal(attvID: Integer): TDirItem;             // получить значение по коду
  end;

//------------------------------------------------------------ атрибуты Grossbee
  TGBAttribute = Class (TSubDirItem) // 1 атрибут
  private // FSubCode - Код Grossbee, FOrderNum - порядковый номер, FSrcID - Тип
          // в Links -  Список доступных значений атрибута, сортир. в зав-ти от типа (TLink.srcID- Тип)
    FGroup    : Integer;     // Код группы
//    FPrecision: Byte;        // кол-во знаков после запятой в типе Double
  public
    constructor Create(pID, pSubCode, pGrpID, pOrderNum: Integer;
                       pPrecision, pType: Byte; pName: String);
//    destructor Destroy; override;
    property Group    : Integer     read FGroup write FGroup;      // Код группы
//    property Precision: Byte        read FPrecision;  // кол-во знаков после запятой в типе Double
    procedure CheckAttrStrValue(var pValue: String);   // проверяем корректность значения для атрибута
    procedure SortValues;
  end;

  TGBAttributes = Class (TOwnDirItems)  // Справочник атрибутов Grossbee
  private
      // группа атрибутов (категория) - TSubDirItem, FSubCode - код Grossbee,
      // в Links -  Список товаров с атрибутами группы, сортир. по наимен. ???
    FGroups   : TOwnDirItems; // справочник групп атрибутов, сортир. по наимен.
    FAttValues: TOwnDirItems; // справочник значений атрибутов (TBaseDirItem)
    FHasNewGroups: Boolean;   // признак наличия новых групп атрибутов
  public
    constructor Create(LengthStep: Integer=10);
    destructor Destroy; override;
    function GetGrp(grpID: Integer): TSubDirItem; // Получить группу по коду
    function GetAtt(attID: Integer): TGBAttribute; // получить атрибут по коду
    function GetGBGroupAttsList(grpID: Integer): TList; // must Free, Список атрибутов группы, сортированный по порядк.№ +наимен.
//    function GetAttIDByGroupAndName(grpID: Integer; pName: String): Integer; // получить ID по группе + имени
    function GetAttIDByGroupAndSubCode(grpID, pSubCode: Integer): Integer;   // получить ID по группе + SubCode
    property Groups: TOwnDirItems read FGroups;         // справочник групп атрибутов, сортир. по наимен.
    property HasNewGroups: Boolean read FHasNewGroups write FHasNewGroups; // признак наличия новых групп атрибутов
  end;

//------------------------------------------------------------------ склад фирмы
  TStoreInfo = class (TBaseDirItem)
  private // FID - код склада
    function GetDprtCode: string; // код склада символьный
  public
    property DprtID   : Integer read FID write FID;
    property DprtCode : string  read GetDprtCode; // код склада символьный
    property IsVisible: boolean index ik8_2 read GetDirBool write SetDirBool;
    property IsReserve: boolean index ik8_3 read GetDirBool write SetDirBool;
//    property IsSale   : boolean index ik8_4 read GetDirBool write SetDirBool;
    property IsDefault: boolean index ik8_5 read GetDirBool write SetDirBool;
    property IsAddVis : boolean index ik8_6 read GetDirBool write SetDirBool;
//    property IsAccProc: boolean index ik8_6 read GetDirBool write SetDirBool;
  end;
  TarStoreInfo = array of TStoreInfo;

//--------------------------------------------------------------- метод отгрузки
  TShipMethodItem = Class (TBaseDirItem)
  private // FID - Код, State- Статус проверки, FName - Наименование
  public
    constructor Create(pID: Integer; pName: String; pTimeKey: Boolean=False; pLabelKey: Boolean=False);
    property TimeKey : boolean index ik8_2 read GetDirBool write SetDirBool; // признак наличия времени отгрузки
    property LabelKey: boolean index ik8_3 read GetDirBool write SetDirBool; // признак наличия наклейки
  end;

//--------------------------------------------------------------- время отгрузки
  TShipTimeItem = Class (TBaseDirItem)
  private // FID - Код, State- Статус проверки, FName - Наименование
    FHour, FMinute: Byte;   // часы, минуты
  public
    constructor Create(pID: Integer; pName: String; pHour: Byte=0; pMinute: Byte=0);
    property Hour  : Byte read FHour   write FHour;   // часы
    property Minute: Byte read FMinute write FMinute; // минуты
//    property SelfGetAllow: boolean index ik8_2 read GetDirBool write SetDirBool; // признак доступности самовывоза
  end;

//------------------------------------------------------------------ уведомление
  TNotificationItem = Class (TBaseDirItem)
  private // FID - Код, FName - текст, State- Статус проверки
    FBegDate, FEndDate: TDateTime;
    FFirmFilials, FFirmClasses, FFirmTypes, FFirms: TIntegerList;
    function GetDateN(const ik: T8InfoKinds): TDateTime;         // получить дату
    procedure SetDateN(const ik: T8InfoKinds; Value: TDateTime); // записать дату
    function GetIntListN(const ik: T8InfoKinds): TIntegerList;   // получить список кодов
  public
    constructor Create(pID: Integer; pText: String);
    destructor Destroy; override;
    procedure CheckConditions(sFil, sClas, sTyp, sFirm: String); // проверить условия фильтрации
    property BegDate: TDateTime index ik8_1 read GetDateN write SetDateN; // дата начала
    property EndDate: TDateTime index ik8_2 read GetDateN write SetDateN; // дата окончания
    property FirmFilials: TIntegerList index ik8_1 read GetIntListN;      // коды филиалов к/а
    property FirmClasses: TIntegerList index ik8_2 read GetIntListN;      // коды категорий к/а
    property FirmTypes  : TIntegerList index ik8_3 read GetIntListN;      // коды типов к/а
    property Firms      : TIntegerList index ik8_4 read GetIntListN;      // коды к/а
    property flFirmAdd  : boolean index ik8_3 read GetDirBool write SetDirBool; // флаг - добавлять/исключать коды arFirms
    property flFirmAuto : boolean index ik8_4 read GetDirBool write SetDirBool; // флаг рассылки к/а с авто-контрактами
    property flFirmMoto : boolean index ik8_5 read GetDirBool write SetDirBool; // флаг рассылки к/а с мото-контрактами
  end;

  TNotifications = Class (TDirItems)  // Справочник уведомлений
    function GetNotification(pID: integer): TNotificationItem;
  public
    function GetFirmNotifications(FirmID: integer): TIntegerList; // must Free, список уведомлений фирмы
    property Items[pID: integer]: TNotificationItem read GetNotification; default;
  end;

//------------------------------------------------------------- акции по товарам
  TWareAction = Class (TBaseDirItem)
  private // FID - Код, FName - причина (название), State - Статус проверки
    FBegDate, FEndDate: TDateTime;
    FComment, FNum, FIconExt: String; //
    function GetDateN(const ik: T8InfoKinds): TDateTime;         // получить дату
    procedure SetDateN(const ik: T8InfoKinds; Value: TDateTime); // записать дату
    function GetStrN(const ik: T8InfoKinds): String;             // получить строку
    procedure SetStrN(const ik: T8InfoKinds; Value: String);     // записать строку
  public
    IconMS: TMemoryStream;
    constructor Create(pID: Integer; pName, pComm: String; pBeg, pEnd: TDateTime);
    destructor Destroy; override;
    property BegDate    : TDateTime index ik8_1 read GetDateN write SetDateN; // дата начала
    property EndDate    : TDateTime index ik8_2 read GetDateN write SetDateN; // дата окончания
    property Num        : String    index ik8_2 read GetStrN  write SetStrN;
    property Comment    : String    index ik8_3 read GetStrN  write SetStrN;
    property IconExt    : String    index ik8_4 read GetStrN  write SetStrN;
    property IsAction   : boolean   index ik8_3 read GetDirBool write SetDirBool; // флаг - акция
    property IsCatchMom : boolean   index ik8_4 read GetDirBool write SetDirBool; // флаг - Лови момент
    property IsNews     : boolean   index ik8_5 read GetDirBool write SetDirBool; // флаг - Новинки
    property IsTopSearch: boolean   index ik8_6 read GetDirBool write SetDirBool; // флаг - ТОП поиска
  End;

//---------------------------------------------------------------- подразделение
  TDprtInfo = class (TSubDirItem)
  private // FID, FName, State - код и наименование подразделения, признак проверки
          // FOrderNum - MasterCode, FSubCode - код филиала,
          // FLinks - список связок с методами отгрузки
    FDelayTime: Integer;
    FShort   : string;
    FSubName : string;   // Email счетов (на филиале) или заголовок колонки (на складе)
    FAdress  : string;
    FLatitude, FLongitude: Single; // координаты
    // графики работы на заданное кол-во дней, 0- Date(), 1- Date()+1 и т.д.
    // Object - TTwoCodes, время начала и окончания в сек
    FSchedule: TObjectList;
    // список складов/откуда, Object - TTwoCodes, код склада, дней в пути
    FStoresFrom: TObjectList;
    // список расписаний пополнения сегодня, Object - TCodeAndQty, код склада,
    // граничное время показа спец.семафора, строка времени доступности
    FFillTT: TObjectList; // список расписаний пополнения

    function GetStrD(const ik: T8InfoKinds): String;         // получить строку
    procedure SetStrD(const ik: T8InfoKinds; Value: String); // записать строку
    function GetIntD(const ik: T8InfoKinds): integer;         // получить число
    procedure SetIntD(const ik: T8InfoKinds; Value: integer); // записать число
    function GetDoubD(const ik: T8InfoKinds): Single;         // получить вещ.значение
    procedure SetDoubD(const ik: T8InfoKinds; Value: Single); // записать вещ.значение
    procedure SetFilialID(pID: integer);
  public
    constructor Create(pID, pSubCode, pOrderNum: Integer; pName: String;
                       pSrcID: Integer=0; WithLinks: Boolean=False);
    destructor Destroy; override;
    function IsInGroup(pGroup: Integer): Boolean; // признак вхождения в заданную группу
//    function CheckShipAvailable(pShipDate: TDateTime; stID: Integer;  // признак доступности отгрузки
//             WithSVKDelay, WithSchedule, WithDprtDelay: Boolean): String; overload;
    function CheckShipAvailable(pShipDate: TDateTime; stID, SVKDelay: Integer;  // признак доступности отгрузки
             WithSchedule, WithDprtDelay: Boolean): String; // overload;
//    function GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer; // границы времен отгрузки на дату
//                               WithSVKDelay, WithDprtDelay: Boolean): String; overload;
    function GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer; // границы времен отгрузки на дату
                               SVKDelay: Integer; WithDprtDelay: Boolean): String; overload;
    property ParentID    : Integer index ik8_1 read GetIntD    write SetIntD;    // MasterCode
    property FilialID    : Integer index ik8_2 read GetIntD    write SetIntD;    // код филиала
    property DelayTime   : Integer index ik8_3 read GetIntD    write SetIntD;    // время запаздывания в мин
//    property Placement   : Integer index ik8_4 read GetIntD    write SetIntD;    // код адреса
    property MainName    : string  index ik8_1 read GetStrD    write SetStrD;
    property ShortName   : string  index ik8_2 read GetStrD    write SetStrD;
    property ColumnName  : string  index ik8_3 read GetStrD    write SetStrD;    // заголовок колонки (на складе)
    property MailOrder   : string  index ik8_4 read GetStrD    write SetStrD;    // Email счетов (на филиале)
    property FilialName  : string  index ik8_5 read GetStrD;
    property Adress      : string  index ik8_6 read GetStrD    write SetStrD;    // адрес
    property IsStoreHouse: boolean index ik8_3 read GetDirBool write SetDirBool; // признак склада
    property IsFilial    : boolean index ik8_4 read GetDirBool write SetDirBool; // признак филиала
    property IsStoreRoad : boolean index ik8_5 read GetDirBool write SetDirBool; // признак - склад-путь
    property IsFilOnlyErr: boolean index ik8_6 read GetDirBool write SetDirBool; // признак - филиал - отправлять только письма о счетах с ошибками
    property HasDprtFrom2: boolean index ik8_7 read GetDirBool write SetDirBool; // признак - есть склады поставки >1 дня
    property AdrLatitude : Single  index ik8_1 read GetDoubD   write SetDoubD;   // координата: широта
    property AdrLongitude: Single  index ik8_2 read GetDoubD   write SetDoubD;   // координата: долгота
    property ShipLinks   : TLinks read FLinks;  // список связок с методами отгрузки
    property Schedule    : TObjectList read FSchedule; // графики работы на заданное кол-во дней
    property StoresFrom  : TObjectList read FStoresFrom; // список складов/откуда
    property FillTT      : TObjectList read FFillTT;     // список расписаний пополнения
  end;

//--------------------------------------------------- товар / группа / подгруппа
  TInfoWareOpts = class (TObject) // параметры товара (нужны для всех, в т.ч. ИНФО-группы)
    FManagerID  : Integer; // код менеджера (EMPLCODE)
    FTypeID     : Integer; // код типа товара
    FProduct    : Integer; // продукт
    FProductLine: Integer; // продуктовая линейка
    FProdDirect : Integer; // Направление по продуктам
    FActionID   : Integer; // код акции
    FTopRating  : Byte;    // рейтинг Топ поиска
    FmeasID     : Byte;    // код ед.изм.
    FWareState  : Byte;    // статус
    FNameBS     : String;  // наименование товара б/спецсимволов
    FCommentUP  : String;  // описание товара в верхнем регистре
    FWareSupName: String;  // Наименование товара от поставщика
    FArticleTD  : String;  // Article TecDoc
    FMainName   : String;  // WAREMAINNAME
    FAnalogLinks: TLinks;  // связки с аналогами
    FONumLinks  : TLinkList; // связки с оригинальными номерами
    constructor Create(CS: TCriticalSection);
    destructor Destroy; override;
  end;

  TWareOpts = class (TObject) // параметры собственно товара (не нужны для ИНФО-группы)
    Fdivis       : Single;          // кратность
    Fweight      : Single;          // вес
    FLitrCount   : Single;          // литраж
    FPrices      : TSingleDynArray; // массив розн.цен в евро в соотвествии с PriceTypes
//    FSLASHCODE   : String;        // WARESLASHCODE
    FModelLinks  : TLinkList;       // связки с моделями
    FFileLinks   : TLinks;          // связки с файлами рисунков
    FAttrLinks   : TLinks;          // связки с атрибутами и их значениями
    FRestLinks   : TLinks;          // связки с остатками по складам
    FSatelLinks  : TLinks;          // связки с сопутствующими товарами
    FGBAttLinks  : TLinks;          // связки с атрибутами Grossbee и их значениями
    FPrizAttLinks: TLinks;          // связки с атрибутами подарков и их значениями
    constructor Create(CS: TCriticalSection);
    destructor Destroy; override;
  end;

  TWareTypeOpts = class (TObject) // параметры типа товара (не нужны для товаров)
    FCountLimit : Single;          // лимит количества
    FWeightLimit: Single;          // лимит веса
    constructor Create(pCountLimit: Single=0; pWeightLimit: Single=0);
  end;

  TWareInfo = class (TSubVisDirItem)
  private // FID, FName - код и наименование товара/группы/подгруппы, FOrderNum - код бренда товара
          // State - признак проверки параметров, FSubCode - SupID TecDoc (DS_MF_ID !!!)
          // FParCode - код верхнего уровня товара/группы/подгруппы
    FComment     : String;               // описание товара/группы/подгруппы
    FWareBoolOpts: set of TKindBoolOptW; // признаки товара/группы/подгруппы
    FInfoWareOpts: TInfoWareOpts;        // параметры собственно товара (нужны для всех товаров, в т.ч. ИНФО-группы)
    FWareOpts    : TWareOpts;            // параметры собственно товара (не нужны для ИНФО-группы)
    FTypeOpts    : TWareTypeOpts;        // параметры типа товара (не нужны для товаров)
    FDiscModLinks: TLinkList;            // связки с шаблонами скидок
    function GetIntW(const ik: T16InfoKinds): Integer;              // получить код
    procedure SetIntW(const ik: T16InfoKinds; Value: Integer);      // записать код
    function GetStrW(const ik: T16InfoKinds): String;               // получить строку
    procedure SetStrW(const ik: T16InfoKinds; Value: String);       // записать строку
    function GetBoolW(const Index: TKindBoolOptW): boolean;         // получить признак
    procedure SetBoolW(const Index: TKindBoolOptW; Value: boolean); // записать признак
    function GetDoubW(const ik: T8InfoKinds): Single;              // получить вещ.значение
    procedure SetDoubW(const ik: T8InfoKinds; Value: Single);      // записать вещ.значение
    function GetWareLinks(const ik: T8InfoKinds): TLinks;        // получить связки
    function GetWareLinkList(const ik: T8InfoKinds): TLinkList;  // получить связки
    procedure CheckPrice(price: Single; pTypeInd: Integer); // записать / проверить розничную цену товара в евро по прайсу
  protected
    procedure SetName(const Value: String); override; // записать FName, FNameBS
  public
    CS_wlinks: TCriticalSection;     // для изменения линков и аналогов
    constructor Create(pID, ParentID: Integer; pName: String);
    destructor Destroy; override;
    function RetailTypePrice(pTypeInd: Integer; currcode: Integer=cDefCurrency): double; // розничная цена товара по прайсу
    procedure GetFirmDiscAndPriceIndex(FirmID: Integer; var ind: Integer; // получить скидки и индекс прайса фирмы
              var disc, disNext: double; contID: Integer=0);
    function RetailPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double;  // розничная цена товара для фирмы
    function SellingPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double; // продажная цена товара для фирмы
//    function MarginPrice(FirmID: Integer=IsWe; UserID: Integer=0;  // цена товара с наценкой (% к продажной) для клиента
//             currcode: Integer=cDefCurrency; contID: Integer=0): double; overload;
//    function MarginPrice(ffp: TForFirmParams): double; overload;
    function CalcFirmPrices(FirmID: Integer=IsWe; currID: Integer=cDefCurrency; // must Free, цены товара по фирме, контракту
                           contID: Integer=0): TDoubleDynArray; overload;
    function CalcFirmPrices(ffp: TForFirmParams): TDoubleDynArray; overload; // must Free !!!

    function CheckWareTypeSys(TypeSysID: Integer): Boolean;         // Проверка принадлежности к системе AUTO / MOTO
    procedure SetWareParams(pPgrID: Integer; ibs: TIBSQL; fromGW:   // заполнить параметры товара из Grossbee
              Boolean=False; spk: TSetWareParamKind=spAll);
    function GetSysModels(pSys: Integer; pMfau: Integer=0; flPL: Boolean=False): TList;  // must Free, TList видим.моделей системы по товару (Object - TModelAuto), сортировка - произв. + м.р. + порядк.№ + наименование
    function SysModelsExists(pSys: Integer): Boolean;               // признак наличия видим.моделей системы по товару
    function CheckHasModels(pSys: Integer): Boolean;                // проверка признака наличия видим.моделей системы по товару
    function GetWareAttrValuesView: TStringList;                    // must Free, список значений атрибутов товара для просмотра
    function GetWareAttrValuesByCodes(AttCodes: Tai): TStringList;  // must Free, список значений атрибутов товара по кодам в нужном порядке
    function GetWareGBAttValuesView: TStringList;                   // must Free, список значений атрибутов Grossbee товара для просмотра
    function GetWareGBAttValuesByCodes(AttCodes: Tai): TStringList; // must Free, список значений атрибутов Grossbee товара по кодам в нужном порядке
    function GetWareCriValuesView(SysID: Integer=0): TStringList;   // must Free, список значений критериев товара для просмотра
    procedure ClearOpts;                                            // очистка связей (удаление при проверке)
    function CheckArticleLink(pArticle: String; pSupID: Integer;    // Установить / снять связь с артиклем TecDoc
             var ResCode: Integer; userID: Integer=0; flDelInfo: Boolean=True): String;
    function GetWareFiles: TarWareFileOpts;                        // набор параметров файлов рисунков товара
    function CheckAnalogLink(AnalogID: Integer;   // добавить линк с аналогом/кроссом (def - аналог Гроссби)
             pSrcID: Integer=soGrossBee; pCross: Boolean=True): Boolean;
    procedure DelAnalogLink(AnalogID: Integer;  pCross: Boolean=False); // удалить из кеша линк с аналогом/кроссом (def - аналог Гроссби)
    procedure SetAnalogLinkSrc(AnalogID, src: Integer);                 // заменить в кеше источник линка с аналогом/кроссом
    procedure DelNotTestedAnalogs(pCross: Boolean=False; pDel: Boolean=False); // удалить из кеша непроверенные линки с аналогами/кроссами
    procedure SortAnalogsByName;  // сортировка аналогов по наименованию
    function GetSrcAnalogs(ShowKind: Integer=-1): TObjectList; // must Free, список кодов аналогов с источниками, Objects - TTwoCodes(wareID, link.SrcID)
    function Analogs: Tai;                                     // must Free, массив кодов аналогов товара
    function FindOriginalNum(ONumID, mfauID: Integer; OrigNum: String): Boolean; // Поиск оригинального номера в списке ор.номеров товара
    procedure SortOrigNumsWithSrc(var arCodes, arSrc: Tai);
    function IsMarketWare(FirmID: Integer=IsWe; contID: Integer=0): Boolean; overload; // признак товара для продажи
    function IsMarketWare(ffp: TForFirmParams): Boolean; overload;
    function GetAnalogTypes(WithoutEmpty: Boolean=False): Tai; // must Free, массив кодов типов аналогов
    function GetSatellites: Tai;                               // must Free, массив кодов сопут.товаров
    function SatelliteExists: Boolean;                         // признак наличия сопут.товаров
//    function RestExists(pContID: Integer=0): Boolean;          // признак наличия остатков
    function GetActionParams(var ActTitle, ActText: String): Integer; // возвращает код и текст акции товара
    function GetFirstTDPictName: String;

    property GrpID        : Integer index ik16_1   read GetIntW;                     // код группы
    property AttrGroupID  : Integer index ik16_2   read GetIntW;                     // код группы атрибутов
    property ManagerID    : Integer index ik16_3   read GetIntW    write SetIntW;    // код менеджера (EMPLCODE)
    property ArtSupTD     : Integer index ik16_4   read GetIntW    write SetIntW;    // SupID TecDoc (DS_MF_ID !!!)
    property PgrID        : Integer index ik16_5   read GetIntW    write SetIntW;    // код подгруппы
    property WareBrandID  : Integer index ik16_6   read GetIntW    write SetIntW;    // код бренда товара
    property measID       : Integer index ik16_7   read GetIntW    write SetIntW;    // код ед.изм.
    property TypeID       : Integer index ik16_8   read GetIntW    write SetIntW;    // код типа товара
    property ProdDirect   : Integer index ik16_9   read GetIntW    write SetIntW;    // Направление по продуктам
    property GBAttGroup   : Integer index ik16_10  read GetIntW;                     // код группы атрибутов Grossbee
    property ActionID     : Integer index ik16_11  read GetIntW    write SetIntW;    // код акции
    property TopRating    : Integer index ik16_12  read GetIntW    write SetIntW;    // рейтинг Топ поиска
    property PrizAttGroup : Integer index ik16_13  read GetIntW;                     // код группы атрибутов подарков
    property WareState    : Integer index ik16_14  read GetIntW    write SetIntW;    // статус
    property Product      : Integer index ik16_15  read GetIntW    write SetIntW;    // продукт
    property ProductLine  : Integer index ik16_16  read GetIntW    write SetIntW;    // продуктовая линейка

    property IsGrp        : boolean index ikwGrp  read GetBoolW   write SetBoolW;   // признак группы
    property IsPgr        : boolean index ikwPgr  read GetBoolW   write SetBoolW;   // признак подгруппы
    property IsWare       : boolean index ikwWare read GetBoolW   write SetBoolW;   // признак товара
    property IsType       : boolean index ikwType read GetBoolW   write SetBoolW;   // признак типа товара
    property IsTop        : boolean index ikwTop  read GetBoolW   write SetBoolW;   // признак ТОП-товара
    property HasFixedType : boolean index ikwFixT read GetBoolW;                    // признак заданного типа товара
    property HasModelAuto : boolean index ikwMod1 read GetBoolW   write SetBoolW;   // признак применимости к моделям Auto
    property HasModelMoto : boolean index ikwMod2 read GetBoolW   write SetBoolW;   // признак применимости к моделям Moto
    property HasModelCV   : boolean index ikwMod4 read GetBoolW   write SetBoolW;   // признак применимости к моделям грузовиков
    property HasModelAx   : boolean index ikwMod5 read GetBoolW   write SetBoolW;   // признак применимости к моделям осей
    property IsNonReturn  : boolean index ikwNRet read GetBoolW   write SetBoolW;   // признак невозврата
    property IsCutPrice   : boolean index ikwCatP read GetBoolW   write SetBoolW;   // признак уценки
    property IsPrize      : boolean index ikwPriz read GetBoolW   write SetBoolW;   // признак можно ли продавать за бонусы
    property IsNews       : boolean index ikwActN read GetBoolW;                    // признак акции "Новинки"
    property IsCatchMom   : boolean index ikwActM read GetBoolW;                    // признак акции "Лови момент"
    property ForSearch    : boolean index ikwSea  read GetBoolW   write SetBoolW;   // признак участия в поиске
    property LoadPriceEx  : boolean index ikwNloa read GetBoolW;                    // признак "не включать в прайс
    property PictShowEx   : boolean index ikwNpic read GetBoolW;                    // признак "не показывать картинки"

    property ModelsSorting: boolean index ik8_3   read GetDirBool write SetDirBool; // признак сортировки моделей
    property IsArchive    : boolean index ik8_4   read GetDirBool write SetDirBool; // признак архивного товара
    property IsSale       : boolean index ik8_5   read GetDirBool write SetDirBool; // признак распродажи
    property IsINFOgr     : boolean index ik8_6   read GetDirBool write SetDirBool; // признак ИНФО-группы
    property IsAUTOWare   : boolean index ik8_7   read GetDirBool write SetDirBool; // признак товара AUTO
    property IsMOTOWare   : boolean index ik8_8   read GetDirBool write SetDirBool; // признак товара MOTO

    property divis        : Single  index ik8_1   read GetDoubW  write SetDoubW; // кратность
    property weight       : Single  index ik8_2   read GetDoubW  write SetDoubW; // кратность
    property CountLimit   : Single  index ik8_3   read GetDoubW  write SetDoubW; // лимит количества
    property WeightLimit  : Single  index ik8_4   read GetDoubW  write SetDoubW; // лимит веса
    property LitrCount    : Single  index ik8_5   read GetDoubW  write SetDoubW; // литраж

//    property SLASHCODE    : string  index ik16_1  read GetStrW  write SetStrW;   // WARESLASHCODE
    property StateName    : string  index ik16_1  read GetStrW;                  // наименование статуса товара
    property WareSupName  : String  index ik16_2  read GetStrW   write SetStrW;  // Наименование товара от поставщика
    property NameBS       : string  index ik16_3  read GetStrW;                  // наименование товара б/спецсимволов
    property Comment      : string  index ik16_4  read GetStrW   write SetStrW;  // описание товара
    property CommentUP    : string  index ik16_5  read GetStrW;                  // описание товара в верхнем регистре
    property BrandNameWWW : String  index ik16_6  read GetStrW;                  // наименование для файла логотипа бренда
    property WareBrandName: string  index ik16_7  read GetStrW;                  // наименование бренда товара
    property MeasName     : string  index ik16_8  read GetStrW;                  // наименование ед.изм.
    property PgrName      : string  index ik16_9  read GetStrW;                  // наименование подгруппы
    property ArticleTD    : string  index ik16_10 read GetStrW   write SetStrW;  // Article TecDoc
    property GrpName      : string  index ik16_11 read GetStrW;                  // наименование группы
    property TypeName     : string  index ik16_12 read GetStrW;                  // наименование типа товара
    property CommentWWW   : string  index ik16_13 read GetStrW;                  // описание товара для Web с учетом типа товара
    property BrandAdrWWW  : String  index ik16_14 read GetStrW;                  // адрес для ссылки на сайт бренда
    property MainName     : string  index ik16_15 read GetStrW   write SetStrW;  // WAREMAINNAME
    property PrDirectName : string  index ik16_16 read GetStrW;                  // наименование направления по продуктам

    property ONumLinks    : TLinkList index ik8_1 read GetWareLinkList;          // связки с оригинальными номерами (товар)
    property ModelLinks   : TLinkList index ik8_2 read GetWareLinkList;          // связки с моделями
    property DiscModLinks : TLinkList index ik8_3 read GetWareLinkList;          // связки с шаблонами скидок (группа/подгруппа)
    property FileLinks    : TLinks    index ik8_1 read GetWareLinks;             // связки с файлами рисунков
    property AttrLinks    : TLinks    index ik8_2 read GetWareLinks;             // связки с атрибутами и их значениями
    property RestLinks    : TLinks    index ik8_3 read GetWareLinks;             // связки со складами и остатками
    property AnalogLinks  : TLinks    index ik8_4 read GetWareLinks;             // связки с аналогами        (товар)
    property SatelLinks   : TLinks    index ik8_5 read GetWareLinks;             // связки с сопутствующими товарами
    property GBAttLinks   : TLinks    index ik8_6 read GetWareLinks;             // связки с атрибутами Grossbee и их значениями
    property PrizAttLinks : TLinks    index ik8_7 read GetWareLinks;             // связки с атрибутами подарков и их значениями

  end;

{//----------------------------------------------------- группы/подгруппы наценок
// в TLinks - TLinkLink: LinkPtr- ссылка на группу(TWareInfo), State- признак проверки группы,
// в DoubleLinks - TLink: LinkPtr- ссылка на подгруппу(TWareInfo), State- признак проверки подгруппы
  TMarginGroups = class (TLinkLinks)
  private
  public
    function GetWareGroup(grID: integer): TWareInfo;                 // получить TWareInfo группы
    function GetWareSubGroup(grID, pgrID: integer): TWareInfo;       // получить TWareInfo подгруппы
    function GroupExists(grID: integer): Boolean;                    // проверка существования группы
    function SubGroupExists(grID, pgrID: integer): Boolean;          // проверка существования подгруппы в группе
    function CheckGroup(grID: integer; SortAdd: Boolean=False): Boolean;           // проверить/добавить группу
    function CheckSubGroup(grID, pgrID: integer; SortAdd: Boolean=False): Boolean; // проверить/добавить подгруппу
    function GetGroupList(TypeSys: Integer=constIsAuto): TList;                   // must Free, список ссылок на группы по системе
    function GetSubGroupList(grID: integer; TypeSys: Integer=constIsAuto): TList; // must Free, список ссылок на подгруппы в группе по системе
    procedure SortByName(grID: integer=0);                                        // сортирует связк с группами/подгруппами по имени
    procedure SetLinkStatesAll(pState: Boolean);                                  // устанавливает флаг проверки всем связкам
    procedure DelNotTestedLinksAll;                                               // удаляет все связки с State=False
  end;  }

//--------------------------------------- ЦФУ (Grossbee->FISCALACCOUNTINGCENTER)
  TFiscalCenter = class (TBaseDirItem)
  private // FID - FACCCODE, FName - FACCNAME, State - признак проверки
    FParent: Integer; // FACCMASTERCODE
    function GetRegion: Integer;   // номер округа (вычисляется по наименованию)
    function GetSaleType: Integer; // продажи AUTO/MOTO
    function GetROPfacc: Integer; // код ЦФУ РОП-а округа
    function CheckIsROPFacc: Boolean;  // признак ЦФУ РОП-а округа (вычисляется по наименованию)
  public
    BKEempls: TIntegerList;        // сотрудники
    constructor Create(pID, pParent: Integer; pName: String);
    destructor Destroy; override;
    property Parent    : Integer read FParent write FParent;
    property Region    : Integer read GetRegion;
    property ROPfacc   : Integer read GetROPfacc;
    property LastLevel : boolean index ik8_2 read GetDirBool write SetDirBool; // признак нижнего уровня
    property IsAutoSale: boolean index ik8_3 read GetDirBool write SetDirBool; // ветка продажи AUTO
    property IsMotoSale: boolean index ik8_4 read GetDirBool write SetDirBool; // ветка продажи MOTO
  end;

  TEmplInfoItem = class;

//----------------------------------------------------- торговая точка контракта
  TDestPoint = class (TBaseDirItem)
  private // FID - id, FName - название, State - признак проверки
    FAdress: String; // адрес
  public
    constructor Create(pID: Integer; pName, pAdress: String);
    property Adress: String read FAdress write FAdress; // адрес
    property Disabled: boolean index ik8_2 read GetDirBool write SetDirBool; // недоступна
  end;

//------------------------------------------------ контракт (Grossbee->CONTRACT)
  TContract = class (TSubDirItem)
  private // FID - CONTCODE, FName - CONTNUMBER, State - признак проверки,
          // FSubCode - CONTSECONDPARTY  (CONTFIRSTPARTY - ?)
          // FOrderNum - код склада по умолчанию, // FSrcID - ContBusinessTypeCode - убрать
    FContSumm, FCredLimit, FDebtSum, FOrderSum, FPlanOutSum, FRedSum, FVioletSum: Single;
    FContEmail, FWarnMessage, FContComments: String;
    // ..., CONTCRNCCODE, ContCreditCrncCode, ContContDelay, CONTDUTYCRNCCODE
    FWhenBlocked, {FCurrency,} FCredCurrency, FCredDelay, FDutyCurrency, FPayType, FStatus: Word;
    FContManager, FFacCenter, FContPriceType, FLegalEntity, FCredProfile: Integer;
    function GetIntFC(const ik: T16InfoKinds): Integer;          // получить код
    procedure SetIntFC(const ik: T16InfoKinds; Value: Integer);  // записать код
    function GetDoubFC(const ik: T8InfoKinds): Single;           // получить вещ.значение
    procedure SetDoubFC(const ik: T8InfoKinds; Value: Single);   // записать вещ.значение
    function GetStrFC(const ik: T16InfoKinds): String;            // получить строку
    procedure SetStrFC(const ik: T16InfoKinds; Value: String);    // записать строку
    function GetContManager: Integer;                            // код первого менеджера контракта
    function GetContFaccName: String;                            // наименование ЦФУ
    function GetContFaccParent: Integer;                         // код верхнего ЦФУ
    function GetContFaccParentName: String;                      // наименование верхнего ЦФУ
  public
    ContBegDate, ContEndDate: TDateTime;
    ContProcDprts : Tai;                 // коды складов обработки счетов контракта // PartiallyFilled
    ContStorages  : TarStoreInfo;        // склады контракта                        // PartiallyFilled
    ContDestPointCodes: TIntegerList;    // коды торговых точек контракта
    CS_cont       : TCriticalSection;    // для изменения параметров
    constructor Create(pID, pFirmCode, pSysID: Integer; pNumber: String);
    destructor Destroy; override;
    procedure TestStoreArrayLength(kind: TArrayKind; len: integer; // проверяем длину массивов складов
              ChangeOnlyLess: boolean=True; inCS: boolean=True);
    function FindContManager(var Empl: TEmplInfoItem): boolean;  // поиск менеджера контракта
    function CheckContManager(emplID: Integer): Boolean;         // проверка менеджера контракта
    function GetContBKEempls: TIntegerList; // not Free !!!, коды менеджеров контракта по ЦФУ
    function GetСontStoreIndex(StorageID: integer): integer; // возвращает индекс склада в массиве ContStorages
    function GetContDestPoint(destID: integer): TDestPoint;  // получить торг.точку по коду
    function ContDestPointExists(destID: integer): Boolean;  // проверить наличие торг.точки
    function GetContVisStoreCodes: Tai;                      // список кодов видимых складов контракта

    property ContFirm      : integer index ik16_1  read GetIntFC   write SetIntFC;
//    property ContCurrency  : integer index ik16_2  read GetIntFC   write SetIntFC;   // валюта контракта
    property DutyCurrency  : integer index ik16_3  read GetIntFC   write SetIntFC;
    property Status        : integer index ik16_4  read GetIntFC   write SetIntFC;   // статус [cstUnKnown, cstClosed, cstBlocked, cstWorked]
    property WhenBlocked   : integer index ik16_5  read GetIntFC   write SetIntFC;
    property CredDelay     : integer index ik16_6  read GetIntFC   write SetIntFC;
    property CredCurrency  : integer index ik16_7  read GetIntFC   write SetIntFC;
    property MainStorage   : integer index ik16_8  read GetIntFC   write SetIntFC;   // код склада по умолчанию   // PartiallyFilled
    property Manager       : integer index ik16_9  read GetIntFC;                    // код первого менеджера     // PartiallyFilled
    property Filial        : integer index ik16_10 read GetIntFC;                    // код филиала (по главному складу)
    property FacCenter     : integer index ik16_11 read GetIntFC   write SetIntFC;   // код ЦФУ                   // PartiallyFilled
    property PayType       : integer index ik16_12 read GetIntFC   write SetIntFC;   // тип оплаты: 0- нал, 1- безнал, 2- по вал.док-та                  // PartiallyFilled
    property FaccParent    : integer index ik16_13 read GetIntFC;                    // код верхнего ЦФУ          // PartiallyFilled
    property ContPriceType : integer index ik16_14 read GetIntFC   write SetIntFC;   // код прайса
    property LegalEntity   : integer index ik16_15 read GetIntFC   write SetIntFC;   // код юрид.фирмы            // PartiallyFilled
    property CredProfile   : integer index ik16_16 read GetIntFC   write SetIntFC;   // код профиля кред.условий
    property ContSumm      : Single  index ik8_1   read GetDoubFC  write SetDoubFC;
    property CredLimit     : Single  index ik8_2   read GetDoubFC  write SetDoubFC;
    property DebtSum       : Single  index ik8_3   read GetDoubFC  write SetDoubFC;
    property OrderSum      : Single  index ik8_4   read GetDoubFC  write SetDoubFC;
    property PlanOutSum    : Single  index ik8_5   read GetDoubFC  write SetDoubFC;
    property RedSum        : Single  index ik8_6   read GetDoubFC  write SetDoubFC;  // просроченная сумма
    property VioletSum     : Single  index ik8_7   read GetDoubFC  write SetDoubFC;  // сумма к оплате в ближайшее время
    property ContDefault   : boolean index ik8_2   read GetDirBool write SetDirBool; // CONTUSEBYDEFAULT
//    property EmptyInvoice  : boolean index ik8_3   read GetDirBool write SetDirBool; // накладные без цен
    property HasSubPrice   : boolean index ik8_4   read GetDirBool write SetDirBool; // признак наличия доп.прайса
    property SaleBlocked   : boolean index ik8_5   read GetDirBool write SetDirBool; // признак - отгрузка запрещена
    property Fictive       : boolean index ik8_6   read GetDirBool write SetDirBool; // признак - фиктивный
//    property Disable       : boolean index ik8_7   read GetDirBool write SetDirBool; // признак - недоступен
    property HasAddVis     : boolean index ik8_8   read GetDirBool write SetDirBool; // признак - имеет склады доп.видимости
    property ContEmail     : string  index ik16_2  read GetStrFC   write SetStrFC;   // EMAIL (если нет - из arFirmInfo)
    property WarnMessage   : string  index ik16_3  read GetStrFC   write SetStrFC;
    property MainStoreStr  : string  index ik16_4  read GetStrFC;                    // код склада по умолчанию символьный
    property LegalFirmName : string  index ik16_5  read GetStrFC;                    // юрид.фирма
    property CredCurrStr   : string  index ik16_6  read GetStrFC;                    // CredCurrency символьный
    property FaccName      : string  index ik16_7  read GetStrFC;                    // наименование ЦФУ
    property FaccParentName: string  index ik16_8  read GetStrFC;                    // наименование верхнего ЦФУ
    property ContComments  : string  index ik16_9  read GetStrFC   write SetStrFC;   // комментарий
  end;

  TContracts = class (TDirItems)       //
  private
    function GetContract(pID: integer): TContract;
  public
    property Items[pID: integer]: TContract read GetContract; default;
  end;

//--------------------------------------------------------------- шаблоны скидок
  TDiscModel = Class (TBaseDirItem)
  private
    FDirectInd, FRating: Word;
    FSales: Integer;
    function GetIntDM(const ik: T8InfoKinds): Integer;          // целое значение
    procedure SetIntDM(const ik: T8InfoKinds; pValue: Integer); // записать целое значение
  public
    constructor Create(pID, pDirect, pRate, pSales: Integer; pName: String);
    destructor Destroy; override;
    property DirectInd: Integer   index ik8_1 read GetIntDM write SetIntDM; // индекс направления в FProdDirects
    property Rating   : Integer   index ik8_2 read GetIntDM write SetIntDM; // рейтинг
    property Sales    : Integer   index ik8_3 read GetIntDM write SetIntDM; // мин.оборот
  End;

  TDiscModels = Class (TObject)
  private
    FProdDirects: TStringList;
    FDiscModels: TObjectList;
    function GetDiscModel(pID: Integer): TDiscModel;          // шаблон
  public
    CS_DiscModels: TCriticalSection;
    EmptyModel: TDiscModel;
    constructor Create;
    destructor Destroy; override;
    property DmItems[index: Integer]: TDiscModel read GetDiscModel; default; // ссылка на элемент справочника по коду
    property ProdDirectList: TStringList read FProdDirects;   // направления
    property DiscModels    : TObjectList read FDiscModels;    // шаблоны
    procedure CheckProdDirect(pdID: Integer; pdName: String); // добавить/проверить направление
    procedure CheckDiscModel(dmID, pdID, pRate, pSales: Integer; dmName: String); // добавить/проверить шаблон
    procedure DelProdDirect(pdID: Integer);                   // удалить направление
    procedure DelDiscModel(dmID: Integer);                    // удалить шаблон
    procedure DelNotTestedDiscModels;                         // удалить лишние шаблоны
    function GetDirectModelsList(pdID: Integer): TList;       // список шаблонов направления
    function GetDirectModelsCount(pdID: Integer): Integer;    // кол-во шаблонов направления
    procedure SortDiscModels;                                 // сортировать шаблоны
    function GetDirectIndex(pdID: Integer): Integer;          // индекс направления
    function GetNextDirectModel(dmID: Integer): Integer;      // код следующего шаблона направления
    function DirectExists(pdID: Integer): Boolean;            // существование направления
  End;

//----------------------------------------------------- профиль кред.условий к/а
  TCredProfile = class (TBaseDirItem)
  private // FID - id, FName - название, State - признак проверки
    FProfCredCurrency, FProfCredDelay: Word;
    FProfCredLimit, FProfDebtAll: Single;
  public
    constructor Create(pID, pCurr, pDelay: Integer; pName: String; pLimit, pDebt: Single);
    property Disabled: boolean index ik8_2 read GetDirBool write SetDirBool; // недоступен
    property Blocked : boolean index ik8_3 read GetDirBool write SetDirBool; // заблокирован
    property ProfCredCurrency: Word   read FProfCredCurrency; //
    property ProfCredDelay   : Word   read FProfCredDelay;    //
    property ProfCredLimit   : Single read FProfCredLimit;    //
    property ProfDebtAll     : Single read FProfDebtAll;      //
    property WarnMessage     : String read FName; //
  end;

//------------------------------------------------------------------------ фирма
  TFirmInfo = class (TSubDirItem)
  private // FID - FIRMCODE, FName - FIRMMAINNAME, State - признак проверки,
          // FSubCode - код , FLinks - , FOrderNum -  // PartiallyFilled
    FSUPERVISOR, FFirmType, FHostCode: integer;       // код гл.пользо., код типа, код для связи с наклейками // PartiallyFilled
    FContUnitOrd: integer;       // код контракта unit-заказа // PartiallyFilled
    FNUMPREFIX, FUPPERMAINNAME, FUPPERSHORTNAME, FActionText: string; // префикс фирмы клиента, ... // PartiallyFilled
    FBoolFOpts: set of T8InfoKinds; // признаки, которые не поместились в FDirBoolOpts
    FBonusQty, FBonusRes: single;       // кол-во бонусов к/а, бонусы по unit-счетам резерва
    FResLimit, FAllOrderSum: single; // лимит резерва, сумма резерва
//    FLabelLinks: TLinks; // связки с наклейками
    function CheckFirmVINmail: boolean;         // проверка наличия WIN-запросов
    function CheckFirmPriceLoadEnable: boolean; // проверка разрешения скачивания прайса
    function CheckFirmOrderImportEnable: boolean; // проверка разрешения загрузки заказов
    function CheckShowZeroRests: boolean;         // проверка показа товаров б/остатков в поисках (Ирбис)
    function GetStrF(const ik: T8InfoKinds): String;           // получить строку
    procedure SetStrF(const ik: T8InfoKinds; Value: String);   // записать строку
    function GetIntF(const ik: T8InfoKinds): Integer;          // получить код
    procedure SetIntF(const ik: T8InfoKinds; Value: Integer);  // записать код
    function GetDoubF(const ik: T8InfoKinds): Double;          // получить вещ. значение
    procedure SetDoubF(const ik: T8InfoKinds; pValue: Double); // записать вещ. значение
    function GetBoolF(const ik: T8InfoKinds): boolean;         // получить признак
    procedure SetBoolF(const ik: T8InfoKinds; Value: boolean); // записать признак
    function GetRegional: Integer;
  public
    LastTestTime, LastDebtTime: TDateTime;
    FirmClients  : Tai;                 // коды сотрудников фирмы               // PartiallyFilled
    FirmClasses  : TIntegerList;        // коды категорий фирмы                 // PartiallyFilled
    FirmContracts: TIntegerList;        // контракты фирмы                      // PartiallyFilled
    FirmManagers : TIntegerList;        // менеджеры фирмы                      // PartiallyFilled
    FirmDiscModels: TObjectList;        // действующие шаблоны скидок фирмы, Object - TTwoCodes:
                                        // код направления, код шаблона, текущий оборот к/а
    LegalEntities: TObjectList;         // юрид.фирмы к/а, Object - TBaseDirItem
    FirmDestPoints: TObjectList;        // торговые точки к/а, Object - TDestPoint
    FirmCredProfiles: TObjectList;      // профили кред.условий к/а, Object - TCredProf

    CS_firm      : TCriticalSection;    // для изменения параметров
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    procedure TestFirmClients(codes: Tai; j: integer=0; inCS: boolean=True); // проверяем список сотрудников фирмы
    function CheckContract(contID: Integer): boolean;  // проверка принадлежности контракта фирме
    procedure SetContUnitOrd(contID: Integer);         // проверка/изменение контракта unit-заказа
    function GetContract(var contID: Integer): TContract; // получить контракт фирмы по коду
    function GetContracts: TStringList;                // must Free, получить список контрактов
    function GetDefContractID: Integer;                // получить код def-контракта
    function GetDefContract: TContract;                // получить def-контракт
    function GetAvailableContract: TContract;          // найти действующий контракт фирмы (желательно наличный)
    function CheckFirmManager(emplID: Integer): Boolean;         // проверка менеджера фирмы
    function CheckFirmRegion(regNum: Integer): Boolean;          // проверка региона фирмы
    function GetFirmManagersString(params: TFirmManagerParams=[fmpName, fmpShort]): String; // список систем/кодов/ФИО/Email-ов менеджеров фирмы (через запятую)
    function GetCurrentDiscModel(direct: Integer; var firmSales: Integer): TDiscModel; // текущие шаблон скидок и оборот по направлению
    function GetFirmDestPoint(destID: integer): TDestPoint;  // получить торг.точку по коду
    procedure CheckReserveLimit;                             // нештатная проверка лимита резерва
    function GetOverSummAll(currID: integer; var OverSumm: Double): String; // получить общее превышение лимита в заданной валюте

    function GetFirmCredProfile(cpID: integer): TCredProfile; // получить кред.профиль по коду

    property SUPERVISOR       : integer index ik8_2 read GetIntF    write SetIntF;    // код главного пользователя // PartiallyFilled
    property FirmType         : integer index ik8_3 read GetIntF    write SetIntF;
    property HostCode         : integer index ik8_4 read GetIntF    write SetIntF;    // код для связи с наклейками
    property ContUnitOrd      : integer index ik8_5 read GetIntF    write SetIntF;    // код контракта unit-заказа
    property Regional         : integer read GetRegional;                             // код менеджера по def-контракту // временно  fnRepWebArmSystemStatistic

    property Arhived          : boolean index ik8_2 read GetDirBool write SetDirBool;
    property PartiallyFilled  : boolean index ik8_3 read GetDirBool write SetDirBool;
    property HasVINmail       : boolean index ik8_4 read GetDirBool write SetDirBool; // признак наличия WIN-запросов
    property EnablePriceLoad  : boolean index ik8_5 read GetDirBool write SetDirBool; // признак разрешения скачивания прайса
    property SKIPPROCESSING   : boolean index ik8_6 read GetDirBool write SetDirBool; // сразу формировать счет // PartiallyFilled
    property Blocked          : boolean index ik8_7 read GetDirBool write SetDirBool; // признак блокировки фирмы в Weborderfirms
    property SendInvoice      : boolean index ik8_8 read GetDirBool write SetDirBool; // признак рассылки накладных
    property SaleBlocked      : boolean index ik8_2 read GetBoolF   write SetBoolF;   // признак запрета отгрузки
    property IsFinalClient    : boolean index ik8_3 read GetBoolF   write SetBoolF;   // признак конечного клиента
    property EnableOrderImport: boolean index ik8_4 read GetBoolF   write SetBoolF;   // признак разрешения загрузки заказов
    property ShowZeroRests    : boolean index ik8_5 read GetBoolF   write SetBoolF;   // признак показа товаров без остатков в поисках (Ирбис)

    property UPPERSHORTNAME   : string  index ik8_1 read GetStrF    write SetStrF;    // FIRMUPPERSHORTNAME     // PartiallyFilled
    property UPPERMAINNAME    : string  index ik8_2 read GetStrF    write SetStrF;    // FIRMUPPERMAINNAME      // PartiallyFilled
    property NUMPREFIX        : string  index ik8_3 read GetStrF    write SetStrF;    // префикс фирмы клиента  // PartiallyFilled
    property ActionText       : string  index ik8_4 read GetStrF    write SetStrF;    // состояние участия в акции
    property FirmTypeName     : string  index ik8_5 read GetStrF;                     // название типа фирмы
//    property LabelLinks       : TLinks read FLabelLinks;                            // связки с наклейками
    property BonusQty         : Double  index ik8_1 read GetDoubF   write SetDoubF;   // кол-во бонусов к/а
    property BonusRes         : Double  index ik8_2 read GetDoubF   write SetDoubF;   // кол-во бонусов к/а в резерве
    property ResLimit         : Double  index ik8_3 read GetDoubF   write SetDoubF;   // лимит резерва
    property AllOrderSum      : Double  index ik8_4 read GetDoubF   write SetDoubF;   // сумма резерва

/////////////////////////////////////////////
  end;

  TFirms = class (Tobject)       // заготовка
  private
    FarFirmInfo: Array of TFirmInfo;
    function GetFirm(pID: integer): TFirmInfo;
  public
    CS_firms: TCriticalSection; // для изменения параметров
    constructor Create;
    destructor Destroy; override;
    procedure CutEmptyCode;
    procedure AddFirm(pID: integer);
    function FirmExists(pID: Integer): Boolean;
    property Items[pID: integer]: TFirmInfo read GetFirm; default;
  end;

//-------------------------------------------------------- пользователь - клиент
  TClientInfo = class (TSubDirItem)  // FOrderNum - SearchCurrency, FSrcID - MaxRowShowAnalogs
  private // FID - PRSNCODE, FName - ФИО, State - признак проверки, FSubCode - код фирмы
    FCountSearch, FCountQty, FCountConnect, FLastContract: integer;
    FDEFDELIVERYTYPE, FBlockKind{, FLoadPriceCount}: Byte;  //    FDEFACCOUNTINGTYPE,
    FLogin, FPassword, FSid, FPost: string; // логин, пароль, sid, должность // PartiallyFilled
    FCliPay: Boolean;
    function GetStrC(const ik: T8InfoKinds): String;               // получить строку
    procedure SetStrC(const ik: T8InfoKinds; Value: String);       // записать строку
    function GetIntC(const ik: T16InfoKinds): Integer;              // получить код
    procedure SetIntC(const ik: T16InfoKinds; Value: Integer);      // записать код
    procedure UpdateStorageOrderC; // проверяет соответствие набора складов клиента набору видимых складов контракта
  public
    TestSearchCountDay, LastTestTime, LastCountQtyTime, LastCountConnectTime,
      LastBaseAutorize, LastAct: TDateTime;
//    LastPriceLoadTime: TDateTime; // время последнего скачивания прайса
    TmpBlockTime: TDateTime;          // время окончания временной блокировки
    CliContracts: TIntegerList;       // коды контрактов клиента                      // PartiallyFilled
//    CliContStores: TObjectList;       // склады клиента по контрактам (TIntegerList) в соотв.с CliContracts
//    CliContMargins: TObjectList;      // наценки клиента по контрактам (TLinkList) в соотв.с CliContracts
    CliContDefs: TObjectList;         // настройки клиента по контрактам (TTwoCodes) в соотв.с CliContracts
    CliMails: TStringList; // Email-ы
    CliPhones: TStringList; // телефоны, в TObjects - TIntegerList кодов шаблонов SMS
    CS_client: TCriticalSection;      // для изменения параметров клиента
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;

    function AddCliContract(contID: Integer; OnlyCache: Boolean=False): Integer; // добавляем контракт в список (в базу)
    procedure DelCliContract(contID: Integer; OnlyCache: Boolean=False);         // удаляем контракт из списка (из базы)
//    procedure AddCliStoreCode(contID, StoreID: Integer);          // добавляем склад в список по контракту
//    procedure DelCliStoreCode(contID, StoreID: Integer);          // удаляем склад из списка по контракту
//    function GetCliStoreIndex(contID, StoreID: Integer): Integer; // индекс склада в списке по контракту
//    function GetContStoreCodes(contID: Integer): TIntegerList;    // not Free, склады по контракту
    function SetLastContract(contID: Integer): String;            // изменить последний контракт клиента
    function GetCliCurrContID: Integer;                           // получить код текущего/доступного контракта клиента
    function GetCliContract(var contID: Integer; ChangeNotFound: Boolean=False): TContract;      // получить контракт клиента
    function CheckContract(contID: Integer): boolean;             // проверка доступности контракта клиенту
//    function GetContMarginLinks(contID: Integer): TLinkList;      // not Free !!! ссылки на наценкы по контракту
//    function GetContCacheGrpMargin(contID, grID: Integer): Double;      // наценка по группе/подгруппе по контракту
//    function GetContMarginListAll(contID: Integer; // must Free !!! список групп/подгрупп с наценками по контракту (TCodeAndQty)
//             WithPgr: Boolean=False; OnlyNotZero: Boolean=False): TList;
//    function CheckCliContMargin(contID, grID: Integer; marg: Double): String; // проверяем/меняем наценку по группе/подгуппе в базе
    function GetCliContDefs(contID: Integer=0): TTwoCodes; // not Free !!! ссылка на настройки по контракту
    procedure CheckCliContDefs(contID, deliv, dest: Integer); // проверка настроек по контракту
    procedure CheckQtyCount;     // проверяет счетчик запросов наличия
    procedure CheckConnectCount; // проверяет счетчик коннектов
    function CheckBlocked(inCS: Boolean=False; mess: Boolean=False; Source: Integer=0): String; // проверка блокировки
    function CheckIsFinalClient: Boolean;

    property FirmID            : Integer index ik16_1  read GetIntC    write SetIntC;    // код фирмы // PartiallyFilled
    property MaxRowShowAnalogs : integer index ik16_2  read GetIntC    write SetIntC;
    property SearchCurrencyID  : integer index ik16_3  read GetIntC    write SetIntC;
//    property DEFACCOUNTINGTYPE : integer index ik16_4  read GetIntC    write SetIntC;
    property DEFDELIVERYTYPE   : integer index ik16_5  read GetIntC    write SetIntC;
    property CountSearch       : integer index ik16_6  read GetIntC    write SetIntC;    // кол-во поисковых запросов за день
    property CountQty          : integer index ik16_7  read GetIntC    write SetIntC;    // кол-во запросов наличия за период в мин
    property CountConnect      : integer index ik16_8  read GetIntC    write SetIntC;    // кол-во коннектов за период в мин
    property LastContract      : integer index ik16_9  read GetIntC    write SetIntC;    // последний выбранный контракт
    property BlockKind         : integer index ik16_10 read GetIntC    write SetIntC;    // тип блокировки
//    property LoadPriceCount    : integer index ik16_11 read GetIntC    write SetIntC;    // кол-во скачиваний прайса за сутки
    property Login             : string  index ik8_1   read GetStrC    write SetStrC;    // логин     // PartiallyFilled
    property Password          : string  index ik8_2   read GetStrC    write SetStrC;    // пароль    // PartiallyFilled
    property Mail              : string  index ik8_3   read GetStrC;                     // Email     // PartiallyFilled
    property Phone             : String  index ik8_4   read GetStrC;                     // телефоны  // PartiallyFilled
    property Post              : string  index ik8_5   read GetStrC    write SetStrC;    // должность // PartiallyFilled
    property SearchCurrencyCode: string  index ik8_6   read GetStrC;                     // SearchCurrencyID символьный
    property FirmName          : string  index ik8_7   read GetStrC;                     // наименование фирмы
    property Sid               : string  index ik8_8   read GetStrC    write SetStrC;    // sid       // PartiallyFilled
    property NOTREMINDCOMMENT  : boolean index ik8_2   read GetDirBool write SetDirBool; //
    property PartiallyFilled   : boolean index ik8_3   read GetDirBool write SetDirBool; // признак частичного заполнения
    property Arhived           : boolean index ik8_4   read GetDirBool write SetDirBool; // признак архивности
    property WareSemafor       : boolean index ik8_5   read GetDirBool write SetDirBool; // Признак вывода семафора наличия в списке товаров
    property Blocked           : boolean index ik8_6   read GetDirBool write SetDirBool; // признак блокировки клиента в Weborderclients
    property DocsByCurrContr   : boolean index ik8_7   read GetDirBool write SetDirBool; // признак показывать документы только по тек.контакту
    property resetPW           : boolean index ik8_8   read GetDirBool write SetDirBool; // признак временного пароля
    property CliPay            : boolean read FCliPay write FCliPay; // T - Контактное лицо для оплаты (в счете на оплату)
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
    CS_clients: TCriticalSection; // для изменения параметров
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

//----------------------------------------------------- пользователь - сотрудник
  TEmplInfoItem = class (TSubDirItem)
  private // FName - имя из MANS, FID - EMPLCODE(GB), FSubCode - EMPLMANCODE(GB), 
          // FOrderNum - код подразделения из EMPLDPRTCODE(ORD, EMPLOYEES)
          // FLinks - связки с видимыми складами
    FSurname    : string;           // фамилия из MANS
    FPatron     : string;           // отчество из MANS
    FServerLog  : string;           // логин из EMPLLOGIN(ORD, EMPLOYEES)
    FPASSFORSERV: string;           // пароль из EMPLPASS(ORD, EMPLOYEES)
    FGBLogin    : string;           // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    FGBRepLogin : string;           // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    FMail       : string;           // Email
    FSession    : string;
    FFaccReg: Integer;
    function GetStrE(const ik: T16InfoKinds): String;          // получить строку
    procedure SetStrE(const ik: T16InfoKinds; Value: String);  // записать строку
    function GetIntE(const ik: T8InfoKinds): Integer;          // получить код
    procedure SetIntE(const ik: T8InfoKinds; Value: Integer);  // записать код
    procedure TestUserRolesLength(len: integer; ChangeOnlyLess: boolean=True; inCS: boolean=True);
  public
    LastTestTime     : TDateTime;        // время последней проверки
    LastActionTime   : TDateTime;        // время последнего действия
    UserRoles        : Tai;              // список ролей из (ORD, ROLES)
    constructor Create(pID, pManID, pDprtID: Integer; pName: String);
    destructor Destroy; override;
    procedure TestUserRoles(roles: Tai);             // проверяем список ролей
    procedure AddUserRole(role: Integer);            // добавляем роль
    procedure DelUserRole(role: Integer);            // удаляем роль
    function UserRoleExists(role: Integer): boolean; // проверяем наличие роли
    property Arhived          : boolean index ik8_5   read GetDirBool write SetDirBool; // признак архивности из EMPLARCHIVED(GB, EMPLOYEES)
    property RESETPASSWORD    : boolean index ik8_2   read GetDirBool write SetDirBool; // признак временного пароля
    property Blocked          : boolean index ik8_3   read GetDirBool write SetDirBool; // признак блокировки
    property DisableOut       : boolean index ik8_4   read GetDirBool write SetDirBool; // признак запрета доступа снаружи
    property EmplID           : integer index ik8_1   read GetIntE  write SetIntE; // = EMPLCODE(GB)
    property ManID            : integer index ik8_2   read GetIntE  write SetIntE; // = EMPLMANCODE(GB)
    property EmplDprtID       : integer index ik8_3   read GetIntE  write SetIntE; // код подразделения из EMPLDPRTCODE(ORD, EMPLOYEES)
    property FaccRegion       : integer index ik8_4   read GetIntE  write SetIntE; // номер региона ЦФУ
    property Surname          : string  index ik16_1  read GetStrE  write SetStrE; // фамилия из MANS
    property Name             : string  index ik16_2  read GetStrE  write SetStrE; // имя из MANS
    property Patronymic       : string  index ik16_3  read GetStrE  write SetStrE; // отчество из MANS
    property ServerLogin      : string  index ik16_4  read GetStrE  write SetStrE; // логин из EMPLLOGIN(ORD, EMPLOYEES)
    property USERPASSFORSERVER: string  index ik16_5  read GetStrE  write SetStrE; // пароль из EMPLPASS(ORD, EMPLOYEES)
    property GBLogin          : string  index ik16_6  read GetStrE  write SetStrE; // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    property GBReportLogin    : string  index ik16_7  read GetStrE  write SetStrE; // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    property Mail             : string  index ik16_8  read GetStrE  write SetStrE; // Email
    property Session          : string  index ik16_9  read GetStrE  write SetStrE;
    property EmplLongName     : string  index ik16_11 read GetStrE;
    property EmplShortName    : string  index ik16_10 read GetStrE;
    property VisStoreLinks    : TLinks read FLinks;                                // связки с видимыми складами
  end;

//---------------------------------------- файлы рисунков/документов для товаров
  TWareFile = Class (TSubDirItem)  // файл
  private // FSubCode - WGFSupTD (supID TecDoc !!!), FOrderNum - WGFHeadID, FName - WGFFileName
    function GetWFHeadName: String; // Получить текст заголовка
  public
    property supID   : Integer read FSubCode;      // SupID TecDoc (DS_ID !!!)
    property HeadID  : Integer read FOrderNum;     // код заголовка
    property FileName: String  read FName;         // имя файла
    property HeadName: String  read GetWFHeadName; // текст заголовка
  end;

//-------------------------------------------------------------------- инфо-блок
  TInfoBoxItem = Class (TSubDirItem)
  private
    FLinkToPict: String;
    FLinkToSite: String;
    FDateFrom  : TDateTime;
    FDateTo    : TDateTime;
    function GetStrI(const ik: T8InfoKinds): String;         // получить строку
    procedure SetStrI(const ik: T8InfoKinds; Value: String); // записать строку
  public
    property Title     : String  index ik8_1 read GetStrI    write SetStrI;    // заголовок
    property LinkToPict: String  index ik8_2 read GetStrI    write SetStrI;    // ссылка на рисунок
    property LinkToSite: String  index ik8_3 read GetStrI    write SetStrI;    // ссылка на сайт / окно описания
    property InWindow  : boolean index ik8_2 read GetDirBool write SetDirBool; // показывать в окне
    property VisAuto   : boolean index ik8_3 read GetDirBool write SetDirBool; // видимость для системы авто
    property VisMoto   : boolean index ik8_4 read GetDirBool write SetDirBool; // видимость для системы мото
    property DateFrom  : TDateTime read FDateFrom  write FDateFrom;            // дата начала
    property DateTo    : TDateTime read FDateTo    write FDateTo;              // дата окончания
    property Priority  : Integer   read FOrderNum  write FOrderNum;            // приоритет
  end;

  TEmplRole = class (TDirItem)
  private
    FConstLinks: TLinks;
  public
    constructor Create(pID: Integer; pName: String);
    destructor Destroy; override;
    property ImpLinks  : TLinks read FLinks;                        // связки с импортами
    property ConstLinks: TLinks read FConstLinks write FConstLinks; // связки с константами
  end;

//------------------------------------------------------------- вид импорта
  TImportType = Class (TDirItem)
  private
  public
    constructor Create(pID: Integer; pName: String; pReport, pImport: Boolean);
    property RoleLinks  : TLinks  read FLinks;                                  // связки с ролями
    property ApplyReport: boolean index ik8_3 read GetDirBool write SetDirBool; // признак наличия отчета
    property ApplyImport: boolean index ik8_4 read GetDirBool write SetDirBool; // признак наличия импорта
  end;

//---------------------------------------- константы сервера - настройки системы
  TConstItem = Class (TSubDirItem) // элемент справочника констант
    // Name - наименование константы, OrderNum - кол-во знаков после запятой в Double
  private // SubCode - код юзера посл.изменений, SrcID - Тип, Links - список связок с ролями
    FLastTime: TDateTime; // время посл.изменения
    FValue   : String;    // значение в строковом виде
    FMaxValue: String;    // Max значение в строковом виде
    FMinValue: String;    // Min значение в строковом виде
    FGrouping: String;    // идентификатор группировки
    function GetStrCI(const ik: T8InfoKinds): String;              // строковое значение
    procedure SetStrCI(const ik: T8InfoKinds; pValue: String);     // записать строковое значение
    function GetIntCI(const ik: T8InfoKinds): Integer;             // целое значение
    procedure SetIntCI(const ik: T8InfoKinds; pValue: Integer);    // записать целое значение
    function GetDoubCI(const ik: T8InfoKinds): Double;             // вещ. значение
    function GetDateCI(const ik: T8InfoKinds): TDateTime;          // значение даты
    procedure SetDateCI(const ik: T8InfoKinds; pValue: TDateTime); // записать значение даты
  public
    constructor Create(pID: Integer; pName: String; pType: Integer=1;
                pUserID: Integer=0; pPrecision: Integer=0; WithLinks: Boolean=False);
    function CheckConstValue(var pValue: String): String;                          // проверяем корректность значения
    property NotEmpty    : boolean   index ik8_3 read GetDirBool write SetDirBool; // признак запрета пустого значения
    property StrValue    : String    index ik8_1 read GetStrCI   write SetStrCI;   // значение в строковом виде
    property MaxStrValue : String    index ik8_2 read GetStrCI   write SetStrCI;   // Max значение в строковом виде
    property MinStrValue : String    index ik8_3 read GetStrCI   write SetStrCI;   // Min значение в строковом виде
    property Grouping    : String    index ik8_4 read GetStrCI   write SetStrCI;   // идентификатор группировки
    property ItemType    : Integer   index ik8_4 read GetIntCI   write SetIntCI;   // Тип
    property Precision   : Integer   index ik8_5 read GetIntCI   write SetIntCI;   // кол-во знаков после запятой в Double
    property LastUser    : Integer   index ik8_6 read GetIntCI   write SetIntCI;   // код юзера посл.изменений
    property IntValue    : Integer   index ik8_1 read GetIntCI;                    // целое значение
    property MaxIntValue : Integer   index ik8_2 read GetIntCI;                    // Max целое значение
    property MinIntValue : Integer   index ik8_3 read GetIntCI;                    // Min целое значение
    property DoubValue   : Double    index ik8_1 read GetDoubCI;                   // вещ. значение
    property MaxDoubValue: Double    index ik8_2 read GetDoubCI;                   // Max вещ. значение
    property MinDoubValue: Double    index ik8_3 read GetDoubCI;                   // Min вещ. значение
    property DateValue   : TDateTime index ik8_1 read GetDateCI;                   // значение даты
    property MaxDateValue: TDateTime index ik8_2 read GetDateCI;                   // Max значение даты
    property MinDateValue: TDateTime index ik8_3 read GetDateCI;                   // Min значение даты
    property LastTime    : TDateTime index ik8_4 read GetDateCI  write SetDateCI;  // время посл.изменения
  end;

//------------------------------------------------------------ линейка продуктов
  TProductLine = Class (TDirItem)
  private
    function GetComment: String;
  public
//    constructor Create(pID: Integer; pName: String);
    property WareLinks: TLinks read FLinks;   // связки с товарами
    property Comment: String read GetComment; // комментарий по 1-му товару
    property HasModelAuto: boolean index ik8_3 read GetDirBool write SetDirBool;   // признак применимости к моделям Auto
    property HasModelMoto: boolean index ik8_4 read GetDirBool write SetDirBool;   // признак применимости к моделям Moto
    property HasModelCV  : boolean index ik8_5 read GetDirBool write SetDirBool;   // признак применимости к моделям грузовиков
    property HasModelAx  : boolean index ik8_6 read GetDirBool write SetDirBool;   // признак применимости к моделям осей
  end;

  TProductLines = Class (TObjectList)
  private
  public
    function GetProductLine(pID: Integer): TProductLine; overload;  // доступ по коду линейки
    function GetProductLine(pName: String): TProductLine; overload; // доступ по названию линейки
  end;

//----------------------------------------------------------- Дерево узлов Motul
  TMotulNode = Class (TSubDirItem)  // Узел дерева
  private // FID - Код узла, FName - Наименование, State - Статус, FSubCode - Код родителя
          // FSrcID - система, FOrderNum - порядк.номер узла в дереве своей системы
          // FLinks - список связанных узлов основного подбора
    FMeasID  : Byte;            // Код ед.изм.
    FOrderOut: Byte;            // порядок вывода
    FNameSys : String;          // Наименование системное
    FChildren: TList;           // Список подузлов
    function GetIsEnding: boolean;
  public
    constructor Create(pID, pParentID, pMeasID, pSysID, pOrdnum: Integer;
                pName, pNameSys: String; pVisible: Boolean=True);
    destructor Destroy; override;
    property Children: TList read FChildren; // Список подузлов, Item - Pointer TMotulNode
    property NameSys : String  read FNameSys;    // Наименование системное
    property ParentID: Integer read FSubCode;    // Код родителя
    property MeasID  : Byte    read FMeasID;     // Код ед.изм.
    property OrderOut: Byte    read FOrderOut;   // порядок вывода
    property TypeSys : Byte    read FSrcID;      // Тип системы 1 - Авто, 2 - Мото and etc.
    property Visible : Boolean index ik8_2 read GetDirBool write SetDirBool; // признак видимости узла
    property IsEnding: Boolean read GetIsEnding; // признак конечной ноды
    property DupNodes: TLinks read FLinks;       // узлы основного подбора
  end;

  TMotulTreeNodes = Class (TDirItems)         // Дерево узлов
  private // FItems - массив ссылок на узлы дерева, FItems[0] - ссылка на корневой узел дерева
    function GetNodeByID(pID: Integer): TMotulNode;
    procedure SortNodesList; // отсортировать список дерева последовательный по всем ветвям

  public
    constructor Create(LengthStep: Integer=10);
//    destructor Destroy; override;
    function MotulNodeGet(pID: Integer; var pNodeGet: TMotulNode): Boolean; overload; // Найти узел по коду
    function MotulNodeGet(pSys: Integer; pNameSys: String; var pNodeGet: TMotulNode): Boolean; overload; // Найти узел по системному наименованию
    function MotulGetSysTree(SysID: integer=0): TStringList; // must Free, Получить список дерева системы (0 - все) последовательный по всем ветвям
    function MotulNodeValidForAdd(pID, pParentID: Integer; pName, pNameSys: String; // Проверить валидность добавления узла
             var pNodeAdd, pNodeParent: TMotulNode; pCheckTreeDup: Boolean=True): String;
    function MotulNodeDel(pNodeID: Integer): String;                                 // Удалить узел
    function MotulNodeEdit(pNodeID, pVisible, pUserID, pOrdnum: Integer;             // Изменить параметры узла
             pName, pNameSys: String): String;
    function MotulNodeAdd(pParentID, pUserID, pSysID, pOrdnum: Integer; var pNodeID: Integer; // Добавление узла в дерево
             pNodeName, pNodeNameSys: String; pVisible: Boolean=True; pMeasID: Integer=0; ToBase: Boolean=False): String;

    property Nodes[ID: Integer]: TMotulNode read GetNodeByID; default;

  end;

//-------------------------------------------------------------------- общий кэш
  TDataCache = class
  private
    FMeasNames    : TDirItems;   // справочник ед.изм.
    FEmplRoles    : TDirItems;   // справочник ролей
    FWareFiles    : TDirItems;   // справочник файлов рисунков/документов
    FImportTypes  : TDirItems;   // справочник видов импорта ( FLinks - набор ролей)
    FParConstants : TDirItems;   // справочник констант ( FLinks - набор ролей)
    FCacheBoolOpts: set of T16InfoKinds;
     function GetBoolDC(ik: T16InfoKinds): boolean;        // получить признак
    procedure SetBoolDC(ik: T16InfoKinds; Value: boolean); // записать признак
    procedure SetWaresNotTested; // сбросить флажки тестирования кэша товаров
    procedure DelNotTestedWares; // убираем непроверенные элементы кэша товаров
    procedure TestParConstants(flFill: Boolean=True; alter: boolean=False);       // проверка кэша констант
    procedure TestSmallDirectories(flFill: Boolean=True; alter: boolean=False); // заполнение/проверка малых справочников
     function TestCacheArrayItemExist(kind: TArrayKind; pID: integer; var flnew: boolean): boolean; // проверяем существование элемента массива кэша
    procedure TestCacheArrayLength(kind: TArrayKind; len: integer; ChangeOnlyLess: boolean=True);   // проверяем длину массива кэша
    procedure TestWares(flFill: Boolean=True);          // заполнение/проверка товаров
    procedure TestWareRests(CompareTime: boolean=True); // заполнение/проверка связок с остатками товаров
    procedure FillWareTypes(GBIBS: TIBSQL);
    procedure FillWareFiles(fFill: Boolean=True); // Загрузка / обновление файлов товаров
    procedure FillInfoNews(flFill: Boolean=True); // Заполнение / проверка инфо-блока
     function FillBrandTDList: TStringList;       // Возвращает список брендов TecDoc
//    procedure FillAttributes;                     // Заполнение атрибутов
    procedure FillGBAttributes(fFill: Boolean=True); // Заполнение / проверка атрибутов Grossbee
    procedure FillNotifications(fFill: Boolean=True); // Заполнение / проверка уведомлений
//    procedure CheckAttributes;                    // Проверка атрибутов
//     function GetFilialROPcodes(var filials: Tai): Tai;        // коды РОП-ов филиалов
  public
//    TestCacheAlterInterval: Integer;   // интервал проверки кэша по alter-таблицам в мин (без фирм и клиентов)
    CliLoginLength        : Byte;      // длина поля логина
    CliPasswLength        : Byte;      // длина поля пароля
    CliSessionLength      : Byte;      // длина поля идентификатора сессии
    OrdWarrNumLength      : Word;      // длина поля заказа Номер доверенности
    OrdWarrPersLength     : Word;      // длина поля заказа ФИО (доверенности)
    OrdCommentLength      : Word;      // длина поля заказа Комментарий
    OrdSelfCommLength     : Word;      // длина поля заказа Личный комментарий
    AccEmpCommLength      : Word;      // длина поля счета Комментарий сотрудника
    AccCliCommLength      : Word;      // длина поля счета Комментарий клиента
    AccWebCommLength      : Word;      // длина поля счета Комментарий Web

    TestCacheInterval     : Word;      // интервал полной проверки кэша в мин (без фирм и клиентов)
    TestCacheNightInt     : Word;      // ночной интервал полной проверки кэша в мин (без фирм и клиентов)
    ClientActualInterval  : Word;      // интервал актуальности кэша клиента в мин
    FirmActualInterval    : Word;      // интервал актуальности кэша фирмы в мин (кроме долгов)

    DefCurrRate           : Single;    // курс EURO к грн
    CreditPercent         : Single;    // DTZNCREDITPERCENT (DUTYZONES)
    BonusVolumeCoeff      : Single;    // коэффициент расчета бонусов к cDefCurrency
    BankMinSumm	          : Single;    // минимальная сумма платежа
    BankLimitSumm	        : Single;    // ограничение суммы платежей в сутки

    BonusCrncCode	        : integer;   // код валюты бонусов
    LongProcessFlag       : Integer;   // флаг длительного процесса в кеше
    pgrDeliv              : Integer;   // подгруппа наценки
    TopActCode	          : integer;   // код текущей акции ТОП поиска
    LastTimeCache         : TDateTime; // время последней полной проверки кэша
    LastTestRestTime      : TDateTime; // время последнего обновления связок с остатками
    DocmMinDate           : TDate;     // минимальная дата док-тов Grossbee
//    LastTimeCacheAlter    : TDateTime; // время последней проверки кэша по alter-таблицам
//    LastTimeMemUsed       : TDateTime;   // время последней проверки занимаемой памяти

    arWareInfo      : array of TWareInfo;
    arDprtInfo      : array of TDprtInfo;
    arEmplInfo      : array of TEmplInfoItem;
    arFirmInfo      : array of TFirmInfo;
    arClientInfo    : TClients;
    CScache         : TCriticalSection; // для изменения длин массивов и замены файлов Влад
    CS_Empls        : TCriticalSection; // для изменения параметров сотрудников
    CS_wares        : TCriticalSection; // для изменения товаров
    FDCA            : TDataCacheAdditionASON;
    AttrGroups      : TAttrGroupItems;  // справочник групп атрибутов
    Attributes      : TAttributeItems;  // справочник атрибутов
    Contracts       : TContracts;       // справочник контрактов
    Notifications   : TNotifications;   // Справочник уведомлений
    WareBrands      : TDirItems;        // справочник брендов
    InfoNews        : TDirItems;        // инфо-блок
    ShipMethods     : TDirItems;        // справочник методов отгрузки
    ShipTimes       : TDirItems;        // справочник времен отгрузки
    FiscalCenters   : TDirItems;        // справочник FISCALACCOUNTINGCENTER
    WareActions     : TDirItems;        // справочник акций по товарам
    Currencies      : TCurrencies;      // справочник валют
//    FirmLabels      : TDirItems;        // справочник наклеек

//    NoTDPictBrandCodes: TIntegerList;   // коды брендов без показа рисунков TD
    ShowZeroRestsFirms: TIntegerList;   // коды к/а для показа товаров б/остатков в поисках (Ирбис)

    BrandTDList     : TStringList;      // список брендов TecDoc
    BrandLaximoList : TStringList;      // список брендов Laximo
    DeliveriesList  : TStringList;      // список доставок
    SMSmodelsList   : TStringList;      // список SMS-шаблонов
    MobilePhoneSigns: TStringList;      // список кодов моб.операторов
    arFirmTypesNames: Tas;
    arFirmClassNames: Tas;
    arWareStateNames: Tas;
    arRegionROPFacc : Tai; // коды ЦФУ РОП-а по номеру региона
    PriceTypes      : Tai; // коды используемых прайсов
    arFictiveEmpl   : Tai; // массив кодов фиктивных менеджеров (ИНФО, ЯяяАРХИВ и т.п.)
//    MarginGroups    : TMarginGroups; // группы/подгруппы наценок
    DiscountModels  : TDiscModels;   // справочник шаблонов скидок
    GBAttributes    : TGBAttributes;  // справочник атрибутов Grossbee товаров
    GBPrizeAttrs    : TGBAttributes;  // справочник атрибутов подарков
    WareProductList : TStringList;    // список продуктов

    ProductLines    : TProductLines;   // перечень продуктовых линеек (Motul)
    MotulTreeNodes  : TMotulTreeNodes; // дерево узлов Motul

    constructor Create;
    destructor Destroy; override;
    property WareCacheUnLocked : boolean index ik16_1  read GetBoolDC write SetBoolDC; // признак начального заполнения кеша
    property WareLinksUnLocked : boolean index ik16_2  read GetBoolDC write SetBoolDC; // признак начального заполнения связок
    property WebAutoLinks      : boolean index ik16_3  read GetBoolDC write SetBoolDC; // признак заполнения связок AUTO (Web)
    property WareCacheTested   : boolean index ik16_4  read GetBoolDC write SetBoolDC; // признак текущего заполнения/проверки кеша
    property flCheckClosingDocs: boolean index ik16_5  read GetBoolDC write SetBoolDC; // флаг - пакетная проверка закрывающих док-тов заказов
    property HideOnlyOneLevel  : boolean index ik16_6  read GetBoolDC write SetBoolDC; // признак - сворачивать только 1 уровень дерева
    property HideOnlySameName  : boolean index ik16_7  read GetBoolDC write SetBoolDC; // признак - сворачивать ноды только при совпадении имен
    property flCheckDocSum     : boolean index ik16_8  read GetBoolDC write SetBoolDC; // признак - проверять суммы док-тов
    property flSendZeroPrices  : boolean index ik16_9  read GetBoolDC write SetBoolDC; // признак - отсылать письмо о нулевых ценах
    property flCheckCliEmails  : boolean index ik16_10 read GetBoolDC write SetBoolDC; // флаг - проверять Email-ы
    property flMailSendSys     : boolean index ik16_11 read GetBoolDC write SetBoolDC; // флаг - идет отправка сист.сообщения (для неодновременного подключения к почт.серверу)
    property flCheckCliBankLim : Boolean index ik16_12 read GetBoolDC write SetBoolDC; // True - проверять лимит оплат по клиенту, False - по к/а
    property AllowWeb          : boolean index ik16_13 read GetBoolDC write SetBoolDC; // флаг - запущен CSSWeb
    property AllowWebArm       : boolean index ik16_14 read GetBoolDC write SetBoolDC; // флаг - запущен CSSWebarm
    property AllowCheckStopOrds: boolean index ik16_15 read GetBoolDC write SetBoolDC;
    property SingleThreadExists: boolean index ik16_16 read GetBoolDC write SetBoolDC;

    function WareExist(pID: Integer): Boolean;
    function GrpExists(pID: Integer): Boolean;
    function PgrExists(pID: Integer): Boolean;
    function GrPgrExists(grID: integer): Boolean; // проверка существования группы/подгруппы для скидок/наценок
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

    function GetWare(WareID: integer; OnlyCache: Boolean=False): TWareInfo; // возвращает параметры товара (если в кэше его нет и OnlyCache=False - заносит в кэш с PgrID=0)
    function GetEmplIDByLogin(login: string): Integer;
    function GetEmplIDByGBLogin(Login: string): Integer;
    function GetEmplIDBySession(pSession: string): Integer;
    function GetRegFirmCodes(RegID: Integer=0; Search: string=''; NotArchived: boolean=True): Tai; // must Free, RegID - код регионала (0-все), Search - ключ поиска по наименованию, NotArchived - только неархивные
    function GetEmplCodesByShortName(DprtID: Integer=0; role: Integer=0): Tai; // must Free, список кодов регионалов, сортировка по коду филиала и ФИО
    function GetGrpID(ID: Integer): Integer;         // код группы
    function GetPgrID(ID: Integer): Integer;         // код подгруппы
    function GetDprtMainName(pID: Integer): string;  // наименование подразделения
    function GetDprtShortName(pID: Integer): string; // кр.наименование подразделения
    function GetDprtColName(pID: Integer): string;   // заголовок колонки подразделения
    function GetImpTypeName(pID: Integer): string;   // наименование импорта
    function GetMeasName(pID: Integer): string;      // наименование ед.изм.
    function GetCurrName(pID: Integer; ForClient: Boolean): string; // наименование валюты
    function GetFaccName(pID: Integer): string;      // наименование ЦФУ
    function GetWareTypeName(typeID: Integer): string;   // наименование типа товара
    function GetFirmTypeName(typeID: Integer): string;   // наименование типа фирмы
    function GetFirmClassName(classID: Integer): string; // наименование категории фирмы
    function GetLastTimeCache: Double;               // время последнего обн.кеша для коммандера
    function GetTestCacheIndication: Integer;        // индикатор своевременности проверки кеша
    function GetRoleName(pID: Integer): string;      // наименование роли
    function GetAllRoleCodes: Tai;                   // must Free, коды всех ролей
    function GetEmplEmails(empls: Tai; pFirm: Integer=0; pWare: Integer=0; // список адресов сотрудников
             pSys: Integer=0; pRegion: Integer=0): String; overload;
    function GetEmplEmails(empls: Tai; var mess: String; pFirm: Integer=0;
             pWare: Integer=0; pSys: Integer=0; pRegion: Integer=0): String; overload;
    function GetConstItem(csID: Integer): TConstItem;  // элемент справочника констант
    function GetConstEmpls(pc: Integer): Tai;          // must Free, список кодов сотрудников из константы-списка
    function GetConstEmails(pc: Integer; pFirm: Integer=0; pWare: Integer=0): String; overload; // список адресов константы-списка кодов сотрудников
    function GetConstEmails(pc: Integer; var mess: String; pFirm: Integer=0; pWare: Integer=0): String; overload;
    function GetEmplConstants(pEmplID: Integer): TStringList;  // must Free, доступные константы сотрудника (Object - ID)
    function GetEmplConstantsCount(pEmplID: Integer): Integer; // кол-во доступных констант сотрудника
    function GetRepOrImpRoles(ImpID: Integer; flReport: Boolean=True): Tai; // must Free, доступные роли для отчета/импорта
    function GetEmplAllowRepImp(pEmplID: Integer): boolean;  // признак наличия разрешенных отчетов/импортов у сотрудника
//    function GetDownLoadExcludeBrands: Tai;                  // коды запрещенных для загрузки прайса брендов, must Free

    function GetEmplAllowRepOrImpList(pEmplID: Integer; flReport: Boolean=True): TStringList; // must Free, список доступных отчетов/импортов сотрудника
    function GetRoleAllowRepOrImpList(pRoleID: Integer; flReport: Boolean=True): TStringList; // must Free, доступные виды отчетов/импортов роли (Object - ID)

    function GetSysManagerWares(SysID: Integer=0; ManID: Integer=0; // must Free, сортированный список товаров (Object-ID) по системе и/или менеджеру и/или бренду
             Brand: integer=0; Sort: boolean=True): TStringList;
    function GetWaresModelNodeUsesAndTextsView(ModelID, NodeID: Integer; // must Free, список текстов и условий к связкам 3, Objects - WareID
             WareCodes: Tai; var sFilters: String): TStringList;
    function GetModelNodeWaresWithUsesByFilters(ModelID, NodeID: Integer; // фильтр.список товаров с текстами и условиями к связкам 3, Objects - WareID
             withChildNodes: boolean; var sFilters: String): TStringList;  // must Free, sFilters - коды значений критериев через запятую
    function GetWareModelUsesAndTextsView(WareID: Integer; Models: TList): TStringList; // must Free, список текстов и условий к связкам товара с моделями

    function GetWareRestsByStores(pWareID: Integer; WithNegative: Boolean=False): TObjectList; // must Free, получить остатки товара по складам
    function GetGroupDprts(pDprtGroup: Integer=0; StoreAndRoad: Boolean=False): Tai; // must Free, список подразделений в заданной группе
//    function GetEmplVisFirmLinkList(EmplID: Integer): TList;  // not Free !!! список связок с к/а по схеме видимости сотрудника
//    function GetEmplVisStoreLinkList(EmplID: Integer): TList; // not Free !!! список связок со складами по схеме видимости сотрудника
//--------------------------------------------------------------------
    function GetFilialList(flShortName: Boolean=False): TStringList; // must Free, список филиалов (Objects - ID)
    function GetFirmTypesList: TStringList;                          // must Free, список типов к/агентов (Objects - ID)
    function GetFirmClassesList: TStringList;                        // must Free, список категорий к/агентов (Objects - ID)
    function GetShipMethodName(smID: Integer): string;               // наименование метода отгрузки
    function GetShipMethodNotTime(smID: Integer): Boolean;           // признак запрета времени у метода отгрузки
    function GetShipMethodNotLabel(smID: Integer): Boolean;          // признак запрета наклейки у метода отгрузки
    function GetShipTimeName(stID: Integer): string;                 // наименование времени отгрузки
    function GetShipMethodsList(dprt: Integer=0): TStringList;       // must Free, список методов отгрузки по складу или всех (Objects - ID)
    function GetShipTimesList: TStringList;                          // must Free, сортированный список времен отгрузки (Objects - ID)
//--------------------------------------------------------------------

    function SearchWaresByAttrValues(attCodes, valCodes: Tai): Tai;             // must Free, поиск товаров по набору значений атрибутов
    function SearchWaresByGBAttValues(attCodes, valCodes: Tai): Tai;            // must Free, поиск товаров по набору значений атрибутов Grossbee
    function SearchWareFileBySupAndName(pSup: Integer; pFileName: String): Integer;
    function SearchWaresByTDSupAndArticle(pSup: Integer; pArticle: String;      // must Free - поиск товаров по артикулу TD
             notInfo: Boolean=False): TStringList;

    procedure TestDataCache(CompareTime: boolean=True; alter: boolean=False);   // заполнение/проверка кэша
    procedure TestEmpls(pEmplID: Integer; FillNew: boolean=True;                // заполнение/проверка сотрудников
              CompareTime: boolean=True; TestEmplFirms: boolean=False);
    procedure TestFirms(pID: Integer; FillNew: boolean=False;                   // заполнение/проверка фирм
              CompareTime: boolean=True; Partially: boolean=False; RegID: Integer=0);
    procedure TestClients(pID: Integer; FillNew: boolean=False;                 // заполнение/проверка клиентов
              CompareTime: boolean=True; Partially: boolean=False; pFirm: Integer=0);
    procedure TestGrPgrDiscModelLinks;                                          // заполнение/проверка линков групп/подгрупп с шаблонами скидок

    function SaveNewConstValue(csID, pUserID: Integer; pValue: String): String; // новое значение константы
    function CheckRoleConstLink(csID, roleID, UserID: Integer;                  // проверить связь роли с константой
             flWrite: Boolean; var ResCode: Integer): String;
//    function CheckRoleImportLink(impID, roleID, UserID: Integer; flWrite: Boolean; var ResCode: Integer): String; // проверить связь роли с импортом
    function CheckWareBrandReplace(brID, brTD, userID: Integer; var ResCode: Integer): String; // добавление / удаление связки производителей Grossbe и Tecdoc
    function CheckWaresEqualSys(WareID1, WareID2: Integer): Boolean;            // проверка ссответствия систем двух товаров
    function CheckEmplIsFictive(pEmplID: Integer): Boolean;                     // проверка кодов фиктивных менеджеров (ИНФО, ЯяяАРХИВ и т.п.)
    function CheckEmplImpType(pEmplID, impID: Integer; flReport: Boolean=False): Boolean; // проверка доступности отчета/импорта сотруднику
    function CheckEmplConstant(pEmplID, constID: Integer; var errmess: string;  // проверка доступности константы сотруднику
             CheckWrite: Boolean=False): Boolean;
//    function CheckEmplVisFirm(pEmplID, pFirmID: Integer): Boolean;              // проверка видимости к/а сотруднику
//    function CheckEmplVisStore(pEmplID, pDprtID: Integer): Boolean;             // проверка видимости склада сотруднику
    function CheckLinkAllowDelete(srcID: Integer): Boolean;                     // проверка доступности удаления по источнику
    function CheckLinkAllowWrong(srcID: Integer): Boolean;                      // проверка доступности пометки неверной связки по источнику

    function CheckLinkMainAndDupNodes(NodeID, MainNodeID, userID: Integer;      // добавление / удаление связки нод - главная, дублирующая
             var ResCode: Integer): String;
    function CheckWareAttrValue(WareID, AttrID, srcID, userID: Integer;         // проверка атрибутов товара
             Value: String; var ResCode: Integer): String;
    function CheckWareCriValueLink(pWareID, criTD, UserID, srcID: Integer;      // добавить линк товара со значением критерия в базу
             CriName, CriValue: String): String;
    function CheckModelNodeWareTextLink(var ResCode: Integer; pModelID, pNodeID, pWareID: Integer; // добавить линк связки 3 с текстом в базу (порция 1 - загрузка из Excel)
             TextValue: String; TypeID: Integer=0; TypeName: String=''; UserID: Integer=0; srcID: Integer=0): String;
    function CheckWareCrossLink(pWareID, pCrossID: Integer;                               // добавить/удалить линк товара с аналогом
             var ResCode: Integer; srcID: Integer; UserID: Integer=0): String;            //          (Excel, вручную)
    function CheckWareArtCrossLinks(pWareID: Integer; CrossArt: String; crossMF: Integer; // добавить/удалить линки товара с аналогами по 1 артикулу
             var ResCode: Integer; srcID: Integer; UserID: Integer=0; ibsORD: TIBSQL=nil): String;          //          (загрузка из TDT)
   procedure CheckWareRest(wrLinks: TLinks; dprtID: Integer;          // установить / уменьшить значение остатка товара
                           pQty: Double; dec: Boolean=False);
    function CheckWareSatelliteLink(pWareID, pSatelID: Integer;       // добавить/удалить линк товара с сопут.товаром (Excel, вручную)
             var ResCode: Integer; srcID: Integer=0; UserID: Integer=0): String;
//---------- UseList - список строк <критерий>=<значение>, в Object - <код TecDoc критерия>
//----------- при посадке из Excel <код TecDoc критерия>=0
    function GetModelNodeWareUseListNumber(pModelID, pNodeID, pWareID: Integer; // номер порции условий связки 3 (заготовка)
             UseList: TStringList): Integer;
    function AddModelNodeWareUseListLinks(pModelID, pNodeID, pWareID,   // добавить линки связки 3 с новой порцией условий в базу
             UserID, srcID: Integer; var UseList: TStringList; var pPart: Integer): String;
    function DelModelNodeWareUseListLinks(pModelID, pNodeID, pWareID, iUseList: Integer): String; // удалить линки связки 3 с порцией условий из базы
    function ChangeModelNodeWareUsesPart(pModelID, pNodeID, pWareID,    // заменить линки связки 3 с порцией значений условий в базе
             UserID, srcID: Integer; UseList: TStringList; var pPart: Integer): String;
//----- TxtList - список, в Object - <код supTD текста>
//----- GetModelNodeWareTextListNumber: String -
//-----   <IntToStr(код типа текста)>=<идентификатор TecDoc>+cSpecDelim+<текст>
//----- CheckModelNodeWareTextListLinks: String -
//-----   <IntToStr(код типа текста)>+cSpecDelim+<название типа>=<идентификатор TecDoc>+cSpecDelim+<текст>
//-----   если задан  <IntToStr(код типа текста)> - <название типа> может быть ''
//----- при посадке из Excel  <идентификатор TecDoc>='', <код supTD текста>=0
    function GetModelNodeWareTextListNumber(pModelID, pNodeID, pWareID: Integer; // номер порции текстов связки 3 (заготовка)
             TxtList: TStringList; nTxtList: Integer=0; ORD_IBSr: TIBSQL=nil): Integer;
    function CheckModelNodeWareTextListLinks(var ResCode: Integer; // добавить / удалить линки связки 3 с порцией текстов
             pModelID, pNodeID, pWareID: Integer; TxtList: TStringList;
             UserID: Integer=0; srcID: Integer=0; PartID: Integer=0): String;
    function FindModelNodeWareUseAndTextListNumbers(pModelID, pNodeID, pWareID: Integer; // номера порций условий и текстов связки 3
             var UseLists: TASL; var TxtLists: TASL; var ListNumbers: Tai; var ErrUseNums: Tai;
             var ErrTxtNums: Tai; FromTDT: Boolean=False; CheckTexts: Boolean=False): String;
    function AddWareFile(var fID: Integer; pFname: String;             // добавить файл в базу и кеш
             pSup, pHeadID, pUserID, pSrcID: Integer): String;
    function CheckWareFileLink(var ResCode: Integer; pFileID, pWareID: Integer;  // добавить/удалить линк товара с файлом (toCache=True - и в кеше)
             pSrcID: Integer=0; UserID: Integer=0; toCache: Boolean=True; linkURL: Boolean=True): String;
    function CheckWareFiles(var delCount: Integer): String; // удаление неиспользуемых файлов

    function GetNotificationText(noteID: Integer): String;                 // получить текст уведомления
    function SetClientNotifiedKind(userID, noteID, kind: Integer): String; // записать время показа/ознакомления уведомления пользователю
    function CheckBrandAdditionData(pBrandID, UserID: Integer;             // добавить/редактировать доп.параметры бренда
             pNameWWW, pPrefix, pAdressWWW: String; pDownLoadEx, pPictShowEx: Boolean): String;

    function GetPriceBonusCoeff(currID: Integer): Single;
    function GetSMSmodelName(smsmID: Integer): String;
    function GetActionComment(ActID: Integer): String;
    function GetWareProductName(wareID: Integer): String; // наименование продукта по коду товара

    procedure FillTreeNodesMotul;                                               // заполнение дерева узлов MOTUL
    function CheckPLineModelNodeLink(PlineID, ModelID, NodeID: Integer;         // удаление/добавление/редактирование связки 3 (Motul)
             var ResCode: Integer; pCount: Single=-1; prior: Integer=-1; userID: Integer=0): string;
    function CheckPLineModelNodeUsage(PlineID, ModelID, NodeID: Integer;        // удаление/добавление условия применения связки 3 (Motul)
             UsageName, UsageValue: String; var ResCode: Integer; userID: Integer=0): string;
  end;

//------------------------------------------ параметры заказа (для записи счета)
  RaccOpts = record // параметры счета
    ID, recDoc: Integer;
    Num, webcomm, sDate: String;
    AccSumm, sumlines, AddSumm: Double;
    accLines: TStringList;
  end;
  ROrderOpts = record // параметры заказа
    deliv, DprtID, DestID, ttID, smID, stID, accType, currID: Integer;
    ORDRNUM, commDeliv, commOrder, comment: String;
    pDate: TDateTime;
    Firma: TFirmInfo;
    Contract: TContract;
    olOrdWares: TObjectList;    // список товаров заказа, в Object - TTwoCodes:
                       // ID1- код товара, Qty- кол-во, ID2: состояние обработки
    accSing, accJoin: RaccOpts; // счета - отдельный, объединенный
  end;

var
  NoWare: TWareInfo;
  Cache: TDataCache;
  SysTypes: TDirItems; // контролируемые системы учета
  ZeroCredProfile: TCredProfile;
  flBlockUber: Boolean; // флаг блокировки конечных покупателей
//  CachePath: String; // def =..\

//                              независимые функции
  procedure FillSysTypes;                               // определить контролируемые системы учета
  function CheckTypeSys(pTypeSys: Integer): Boolean;    // Проверка корректности кода системы Авто/Мото
  function GetSysTypeMail(pTypeSys: Integer): String;   // Email для сообщений по системе учета
//  function GetSysTypeName(pTypeSys: Integer): String;   // название системы учета
  function GetSysTypeEmpl(pTypeSys: Integer): Integer;  // EmplID ответственного по системе учета

  function WareModelsSortCompare(Item1, Item2: Pointer): Integer; // сортировка TList моделей - произв. + м.р. + порядк.№ + наименование
  function ShipTimesSortCompare(Item1, Item2: Pointer): Integer; // используется для сортировки TList справочника ShipTimes
//  function CheckCacheTestAvailable: Boolean;
  function GetRepImpAllowFromLinkSrc(srcID: Integer; flReport: Boolean=False): Boolean; // получить признак доступности отчета/импорта из srcID линка
  function GetLinkSrcFromRepImpAllow(RepAllow, ImpAllow: Boolean): Integer; // получить srcID линка из признаков доступности отчета/импорта

  function AttValLinksSortCompare(Item1, Item2: Pointer): Integer;          // сортировка TList линков значений атрибутов в зав-ти от типа

implementation
uses n_IBCntsPool;
//******************************************************************************
//                              независимые функции
//******************************************************************************
//====================================== определить контролируемые системы учета
procedure FillSysTypes;
const nmProc = 'FillSysTypes'; // имя процедуры/функции
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

  if SysTypes.Count<1 then try // системы учета должны быть заполнены обязательно !!!
    prMessageLOGS(nmProc+': заполняю системы учета default-значениями', fLogCache);
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
//===================================== Проверка корректности кода системы учета
function CheckTypeSys(pTypeSys: Integer): Boolean;
begin
  Result:= SysTypes.ItemExists(pTypeSys);
end;
//========================================= Email для сообщений по системе учета
function GetSysTypeMail(pTypeSys: Integer): String;
begin
  if SysTypes.ItemExists(pTypeSys) then
    Result:= TSysItem(SysTypes[pTypeSys]).SysMail
  else Result:= '';
end;
//======================================= EmplID ответственного по системе учета
function GetSysTypeEmpl(pTypeSys: Integer): Integer;
begin
  if SysTypes.ItemExists(pTypeSys) then
    Result:= TSysItem(SysTypes[pTypeSys]).SysEmplID
  else Result:= 0;
end;
{//======================================================= название системы учета
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
//=============== Список ссылок на атрибуты группы, сортир. по порядк.№ +наимен.
function TAttrGroupItem.GetListGroupAttrs: TList; // must Free
var i: Integer;
begin
  Result:= TList.Create;
  if not Assigned(self) then Exit;
  with Links do begin
    Result.Capacity:= Result.Capacity+LinkCount;
    for i:= 0 to ListLinks.Count-1 do Result.Add(GetLinkPtr(ListLinks[i]));
  end;
  Result.Sort(DirNumNameSortCompare); // сортировка атрибутов (порядк.№ +наимен.)
end;


//******************************************************************************
//                                 TAttrGroupItems
//******************************************************************************
//============= сортировка TStringList групп атрибутов - порядк.№ + наименование
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
  FTypeSysLists:= TArraySysTypeLists.Create(False); // сортированные списки по системам
end;
//==============================================================================
destructor TAttrGroupItems.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FTypeSysLists);
  inherited Destroy;
end;
//===== Список групп атрибутов системы, сортированный по порядк.№ + наименованию
function TAttrGroupItems.GetListAttrGroups(pTypeSys: Integer): TStringList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= FTypeSysLists[pTypeSys];
end;
//====================================================== Получить группу по коду
function TAttrGroupItems.GetAttrGroup(grpID: Integer): TAttrGroupItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= TAttrGroupItem(DirItems[grpID]);
end;
//============================= сортируем список групп атрибутов (SysID=0 - все)
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
//=================== сортировка TStringList значений атрибутов в зав-ти от типа
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
  FTypeAttr := pType;       // Тип
  FPrecision:= pPrecision;  // кол-во знаков после запятой в типе Double
  FListValues:= fnCreateStringList(False, Char(pType), dupIgnore); // Список доступных значений атрибута
  FListValues.CaseSensitive:= True;
end;
//==============================================================================
destructor TAttributeItem.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FListValues);
  inherited Destroy;
end;
//================================= проверяем корректность значения для атрибута
procedure TAttributeItem.CheckAttrStrValue(var pValue: String);
var d: double;
    i: integer;
begin
  if not Assigned(self) then Exit;
  pValue:= trim(pValue);
  if pValue=''  then Exit;
  if (TypeAttr=constDouble) then begin
    pValue:= StrWithFloatDec(pValue); // проверяем DecimalSeparator
    try
      d:= StrToFloat(pValue);
      i:= Round(d);
      if (d>15) and not fnNotZero(d-i) then pValue:= FormatFloat('#0', d) //FloatToStr(d)
      else pValue:= FormatFloat('#0.'+StringOfChar('0', Precision), d);
    except
    end;
  end;
end;
{//==================================================== получить систему атрибута
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
  FAttrValues:= TDirItems.Create; // Справочник значений атрибутов
end;
//==============================================================================
destructor TAttributeItems.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FAttrValues);
  inherited Destroy;
end;
//================= Список атрибутов группы (сортированный по порядк.№ +наимен.)
function TAttributeItems.GetListAttrsOfGroup(pGrpID: Integer): TStringList; // must Free
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  with GetListSubCodeItems(pGrpID) do try
    Result.Capacity:= Result.Capacity+Count;
    for i:= 0 to Count-1 do Result.AddObject(GetDirItemName(Items[i]), Items[i]);
  finally Free; end;
  if Result.Count>1 then Result.CustomSort(DirNumNameSortCompareSL); // сортировка атрибутов (порядк.№ +наимен.)
end;
//===================================================== получить атрибут по коду
function TAttributeItems.GetAttr(attrID: Integer): TAttributeItem;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  Result:= DirItems[attrID];
end;
//==================================================== получить значение по коду
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
function TStoreInfo.GetDprtCode: string; // код склада символьный
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
  // графики работы на заданное кол-во дней, 0- Date(), 1- Date()+1 и т.д.
  FSchedule:= TObjectList.Create;
  // список складов/откуда, Object - TTwoCodes, код склада, дней в пути
  FStoresFrom:= TObjectList.Create;
  // список складов/откуда сегодня, Object - TCodeAndQty, код склада,
  // граничное время показа спец.семафора, строка времени доступности
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
//============================================================== получить строку
function TDprtInfo.GetStrD(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FName;                            //
    ik8_2: Result:= FShort;                           //
    ik8_3: if IsStoreHouse then Result:= FSubName;    // заголовок колонки (на складе)
    ik8_4: if IsFilial     then Result:= FSubName;    // Email счетов (на филиале)
    ik8_5: if not Cache.DprtExist(FilialID) then Result:= 'Нет филиала'
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
   ik8_3: if IsStoreHouse and (FSubName<>Value) then FSubName:= Value;  // заголовок колонки (на складе)
   ik8_4: if IsFilial     and (FSubName<>Value) then FSubName:= Value;  // Email счетов (на филиале)
   ik8_6: if (FAdress<>Value) then FAdress:= Value;  //
  end;
end;
//=============================================================== получить число
function TDprtInfo.GetIntD(const ik: T8InfoKinds): integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FOrderNum;  // MasterCode
    ik8_2: Result:= FSubCode;   // код филиала
    ik8_3: Result:= FDelayTime; // время запаздывания в мин
  end;
end;
//==============================================================================
procedure TDprtInfo.SetIntD(const ik: T8InfoKinds; Value: integer);
begin
  if not Assigned(self) then Exit;
  case ik of
   ik8_1: if (FOrderNum <>Value) then FOrderNum := Value;  // MasterCode
   ik8_2: if (FSubCode  <>Value) then FSubCode  := Value;  // код филиала
   ik8_3: if (FDelayTime<>Value) then FDelayTime:= Value;  // время запаздывания в мин
  end;
end;
//======================================================== получить вещ.значение
function TDprtInfo.GetDoubD(const ik: T8InfoKinds): Single;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FLatitude;   // широта
    ik8_2: Result:= FLongitude;   // долгота
  end;
end;
//======================================================== записать вещ.значение
procedure TDprtInfo.SetDoubD(const ik: T8InfoKinds; Value: Single);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: begin                        // широта
           if (Value<-90) or (Value>90) then Value:= 0;
           if fnNotZero(FLatitude-Value) then FLatitude:= Value;
         end;
    ik8_2: begin                        // долгота
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
//========================================== признак вхождения в заданную группу
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
{//============================== проверка доступности отгрузки по графику работы
function TDprtInfo.CheckShipAvailable(pShipDate: TDateTime; stID: Integer;
         WithSVKDelay, WithSchedule, WithDprtDelay: Boolean): String;
// если stID не задан - время не проверяем !!!
var compDate, DayIndex, TestDayTime1, TestDayTime2: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    st: TShipTimeItem;
    sch: TTwoCodes;
    strErr: String;
begin
  Result:= '';
  sch:= nil;
  try
    if (pShipDate<DateNull) then raise EBOBError.Create('Отсутствует дата отгрузки');
    compDate:= CompareDate(pShipDate, Date);
    strErr:= 'Заданная дата отгрузки  недоступна - '+FormatDateTime(cDateFormatY4, pShipDate);
    if (compDate<0) then raise EBOBError.Create(strErr); // дата меньше сегодняшней

    if WithSchedule then begin // проверяем дату по графику работы склада
      DayIndex:= trunc(pShipDate-Date);
      if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);
      sch:= TTwoCodes(Schedule[DayIndex]); // проверяем дату по графику работы склада
      if (sch.ID1<1) and (sch.ID2<1) then raise EBOBError.Create(strErr);
    end;

    if (stID<1) then Exit; // время не задано - выходим
//    if (stID<1) then raise EBOBError.Create('Отсутствует время отгрузки');

    strErr:= 'Заданное время отгрузки недоступно';
    if not Cache.ShipTimes.ItemExists(stID) then raise EBOBError.Create(strErr);
    st:= Cache.ShipTimes[stID];
    strErr:= strErr+' - '+fnMakeAddCharStr(IntToStr(st.Hour), 2, '0', False)+':'+
             fnMakeAddCharStr(IntToStr(st.Minute), 2, '0', False);
    TestDayTime1:= (st.Hour*60+st.Minute);

    if WithSchedule then begin // проверяем время по графику работы склада
      TestDayTime2:= TestDayTime1*60;
      if (TestDayTime2<sch.ID1) or (TestDayTime2>sch.ID2) then raise EBOBError.Create(strErr);
    end;

    if (compDate>0) then Exit; // если не сегодня - выходим

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // сегодня проверяем текущее время
    TestDayTime2:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime2:= TestDayTime2+DelayTime; // + запаздывание склада
    if WithSVKDelay then                                         // + запаздывание СВК
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
//============================== проверка доступности отгрузки по графику работы
function TDprtInfo.CheckShipAvailable(pShipDate: TDateTime; stID, SVKDelay: Integer;
         WithSchedule, WithDprtDelay: Boolean): String;
// если stID не задан - время не проверяем !!!
var compDate, DayIndex, TestDayTime1, TestDayTime2: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    st: TShipTimeItem;
    sch: TTwoCodes;
    strErr: String;
begin
  Result:= '';
  sch:= nil;
  try
    if (pShipDate<DateNull) then raise EBOBError.Create('Отсутствует дата отгрузки');
    compDate:= CompareDate(pShipDate, Date);
    strErr:= 'Заданная дата отгрузки  недоступна - '+FormatDateTime(cDateFormatY4, pShipDate);
    if (compDate<0) then raise EBOBError.Create(strErr); // дата меньше сегодняшней

    if WithSchedule then begin // проверяем дату по графику работы склада
      DayIndex:= trunc(pShipDate-Date);
      if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);
      sch:= TTwoCodes(Schedule[DayIndex]); // проверяем дату по графику работы склада
      if (sch.ID1<1) and (sch.ID2<1) then raise EBOBError.Create(strErr);
    end;

    if (stID<1) then Exit; // время не задано - выходим
//    if (stID<1) then raise EBOBError.Create('Отсутствует время отгрузки');

    strErr:= 'Заданное время отгрузки недоступно';
    if not Cache.ShipTimes.ItemExists(stID) then raise EBOBError.Create(strErr);
    st:= Cache.ShipTimes[stID];
    strErr:= strErr+' - '+fnMakeAddCharStr(IntToStr(st.Hour), 2, '0', False)+':'+
             fnMakeAddCharStr(IntToStr(st.Minute), 2, '0', False);
    TestDayTime1:= (st.Hour*60+st.Minute);

    if WithSchedule then begin // проверяем время по графику работы склада
      TestDayTime2:= TestDayTime1*60;
      if (TestDayTime2<sch.ID1) or (TestDayTime2>sch.ID2) then raise EBOBError.Create(strErr);
    end;

    if (compDate>0) then Exit; // если не сегодня - выходим

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // сегодня проверяем текущее время
    TestDayTime2:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime2:= TestDayTime2+DelayTime; // + запаздывание склада
    if (SVKDelay>0) then TestDayTime2:= TestDayTime2+SVKDelay;   // + запаздывание СВК
    if (TestDayTime1<TestDayTime2) then raise EBOBError.Create(strErr);
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS('CheckShipAvailable: '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;
{//============================================== границы времен отгрузки на дату
function TDprtInfo.GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer;
                                     WithSVKDelay, WithDprtDelay: Boolean): String;
// вызывать только после проверки даты отгрузки !!!
var compDate, DayIndex, TestDayTime: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    strErr: String;
    sch: TTwoCodes;
begin
  Result:= '';
  try
    compDate:= CompareDate(pShipDate, Date);
    strErr:= 'Заданная дата отгрузки недоступна';
    if (compDate<0) then raise EBOBError.Create(strErr); // дата меньше сегодняшней

    DayIndex:= trunc(pShipDate-Date);
    if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);

    sch:= TTwoCodes(Schedule[DayIndex]);
    TimeMin:= sch.ID1;
    TimeMax:= sch.ID2;
    if (TimeMin<1) and (TimeMax<1) then raise EBOBError.Create(strErr);

    if (compDate>0) then Exit; // если не сегодня - выходим

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // сегодня проверяем текущее время
    TestDayTime:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime:= TestDayTime+DelayTime; // запаздывание склада
    if WithSVKDelay then                                       // запаздывание СВК
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
//============================================== границы времен отгрузки на дату
function TDprtInfo.GetShipTimeLimits(pShipDate: TDateTime; var TimeMin, TimeMax: Integer;
                                     SVKDelay: Integer; WithDprtDelay: Boolean): String;
// вызывать только после проверки даты отгрузки !!!
var compDate, DayIndex, TestDayTime: Integer;
    iHour, iMinute, iSec, iMsec: Word;
    strErr: String;
    sch: TTwoCodes;
begin
  Result:= '';
  try
    compDate:= CompareDate(pShipDate, Date);
    strErr:= 'Заданная дата отгрузки недоступна';
    if (compDate<0) then raise EBOBError.Create(strErr); // дата меньше сегодняшней

    DayIndex:= trunc(pShipDate-Date);
    if (Schedule.Count<(DayIndex+1)) then raise EBOBError.Create(strErr);

    sch:= TTwoCodes(Schedule[DayIndex]);
    TimeMin:= sch.ID1;
    TimeMax:= sch.ID2;
    if (TimeMin<1) and (TimeMax<1) then raise EBOBError.Create(strErr);

    if (compDate>0) then Exit; // если не сегодня - выходим

    DecodeTime(Now, iHour, iMinute, iSec, iMsec); // сегодня проверяем текущее время
    TestDayTime:= iHour*60+iMinute;
    if WithDprtDelay then TestDayTime:= TestDayTime+DelayTime; // + запаздывание склада
    if (SVKDelay>0) then TestDayTime:= TestDayTime+SVKDelay;   // + запаздывание СВК
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
  CS_client:= TCriticalSection.Create; // для изменения параметров клиента
  TestSearchCountDay:= Date;
  FCountSearch := -1;                  // начальное значение счетчика
  FCountQty    := 0;                   // начальное значение счетчика
//  FLoadPriceCount:= 0;                 // начальное значение счетчика
  LastCountQtyTime:= Now;
  LastCountConnectTime:= Now;
  FCountConnect:= 0;                   // начальное значение счетчика
  TmpBlockTime:= 0;                    // время окончания временной блокировки
  FLastContract:= 0;
  CliContracts:= TIntegerList.Create;   // контракты клиента                      // PartiallyFilled
//  CliContStores:= TObjectList.Create;   // порядок складов по настройкам клиента по контрактам
//  CliContMargins:= TObjectList.Create;  // наценки клиента по контрактам
  CliMails:= fnCreateStringList(True, DupIgnore);
  CliPhones:= fnCreateStringList(True, DupIgnore);
  CliContDefs:= TObjectList.Create;      // настройки клиента по контрактам (TTwoCodes) в соотв.с CliContracts
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
//============================================================== записать строку
procedure TClientInfo.SetStrC(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik8_1: if (FLogin   <>Value) then FLogin   := Value; // логин
    ik8_2: if (FPassword<>Value) then FPassword:= Value; // пароль
//    ik8_3: if (FMail    <>Value) then FMail    := Value; // Email
//    ik8_4: if (FPhone   <>Value) then FPhone   := Value; // телефоны
    ik8_5: if (FPost    <>Value) then FPost    := Value; // должность
    ik8_8: if (FSid     <>Value) then FSid     := Value; // sid
  end;
end;
//============================================================== получить строку
function TClientInfo.GetStrC(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FLogin;    // логин
    ik8_2: Result:= FPassword; // пароль
    ik8_3: Result:= fnGetDelimiterText(CliMails, ',', '');     // Email
//    ik8_3: Result:= FMail;     // Email
//    ik8_4: Result:= FPhone;    // телефоны
    ik8_4: Result:= fnGetDelimiterText(CliPhones, ',', '');    // телефоны
    ik8_5: Result:= FPost;     // должность
    ik8_6: Result:= IntToStr(SearchCurrencyID);                                    // SearchCurrencyID символьный
    ik8_7: if Cache.FirmExist(FirmID) then Result:= Cache.arFirmInfo[FirmID].Name; // наименование фирмы
    ik8_8: Result:= FSid;      // sid
  end;
end;
//================================================================= получить код
function TClientInfo.GetIntC(const ik: T16InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik16_1 : Result:= FSubCode;             // код фирмы
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
//================================================================= записать код
procedure TClientInfo.SetIntC(const ik: T16InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik16_1 : if (FSubCode          <>Value) then FSubCode          := Value; // код фирмы
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
//======================================= проверка доступности контракта клиенту
function TClientInfo.CheckContract(contID: Integer): boolean;
begin
  Result:= False;
  if not Assigned(self) or (ID<1) or (CliContracts.Count<1) then Exit;
  Result:= Cache.Contracts.ItemExists(contID) and Cache.FirmExist(FirmID)
    and Cache.arFirmInfo[FirmID].CheckContract(contID)
    and (CliContracts.IndexOf(contID)>-1);
end;
{//========================================== индекс склада в списке по контракту
function TClientInfo.GetCliStoreIndex(contID, StoreID: Integer): Integer;
var i: integer;
begin
  Result:= -1;
  if not Assigned(self) or (ID<1) then Exit;
  i:= CliContracts.IndexOf(contID);    // индекс контракта
  if (i<0) then Exit;
  if (CliContStores.Count<(i+1)) or not Assigned(CliContStores[i]) then Exit;
  try
    Result:= TIntegerList(CliContStores[i]).IndexOf(StoreID);    // индекс склада
  except
    Result:= -1;
  end;
end; }
//========================================= добавляем контракт в список (в базу)
function TClientInfo.AddCliContract(contID: Integer; OnlyCache: Boolean=False): Integer;
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
begin
  Result:= -1;
  if not Assigned(self) or (ID<1) then Exit;
  if not Cache.Contracts.ItemExists(contID) or not Cache.FirmExist(FirmID)
    or not Cache.arFirmInfo[FirmID].CheckContract(contID) then Exit;

  Result:= CliContracts.IndexOf(contID);        // индекс контракта
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
//========================================= удаляем контракт из списка (из базы)
procedure TClientInfo.DelCliContract(contID: Integer; OnlyCache: Boolean=False);
var i: integer;
    OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
begin
  if not Assigned(self) or (ID<1) then Exit;
  i:= CliContracts.IndexOf(contID);      // индекс контракта
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
//    CliContStores.Delete(i);             // удаляем склады
//    CliContMargins.Delete(i);            // удаляем наценки
    CliContDefs.Delete(i);               // удаляем настройки
    CliContracts.Delete(i);              // удаляем контракт
  finally
    CS_client.Leave;
  end;
end;
//=========================== получить код текущего/доступного контракта клиента
function TClientInfo.GetCliCurrContID: Integer;
var errmess: string;
begin
  Result:= 0;
  if not Assigned(self) or (ID<1) then Exit;
  if (CliContracts.Count<1) then // если нет доступных контрактов
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  Result:= LastContract; //  берем последний активный
  if (Result<1) or (CliContracts.IndexOf(Result)<0) then  // если не подходит
    Result:= Cache.arFirmInfo[FirmID].GetDefContractID; // берем Default
  if (CliContracts.IndexOf(Result)<0) then  // если не подходит
    Result:= CliContracts[0]; // берем первый в списке
  if not Cache.Contracts.ItemExists(Result) then
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  if (Result<>LastContract) then begin // меняем LastContract
    errmess:= SetLastContract(Result);
    if (errmess<>'') then raise EBOBError.Create(errmess);
  end;
end;
//========================================== получить доступный контракт клиента
function TClientInfo.GetCliContract(var contID: Integer; ChangeNotFound: Boolean=False): TContract;
var i: integer;
begin
  Result:= nil;
  if not Assigned(self) or (ID<1) then Exit;
  if (CliContracts.Count<1) then // если нет доступных контрактов
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  i:= ContID;
  if (i<1) then i:= GetCliCurrContID // если контракт не задан - ищем код текущего/доступного контракта клиента
  else if (CliContracts.IndexOf(i)<0) then begin // если контракт задан - проверяем
    if ChangeNotFound then i:= GetCliCurrContID
    else raise EBOBError.Create('Контракт не доступен');
  end;
  if not Cache.Contracts.ItemExists(i) then
    raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
  contID:= i;
  Result:= Cache.Contracts[contID];
end;
//========================================== изменить последний контракт клиента
function TClientInfo.SetLastContract(contID: Integer): String;
const nmProc = 'SetLastContract'; // имя процедуры/функции
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
    firma:= Cache.arFirmInfo[FirmID]; // Проверяем, доступен ли вообще этот контракт
    if not firma.CheckContract(contID) then raise EBOBError.Create('Контракт к/а не найден');

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
//============================================= ссылка на настройки по контракту
function TClientInfo.GetCliContDefs(contID: Integer=0): TTwoCodes; // not Free !!!
var i: integer;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if not CheckContract(contID) then contID:= LastContract;
  i:= CliContracts.IndexOf(contID);        // индекс контракта
  if (i<0) then Exit;
  Result:= TTwoCodes(CliContDefs[i]);
end;
//=============================================== проверка настроек по контракту
procedure TClientInfo.CheckCliContDefs(contID, deliv, dest: Integer);
var i: integer;
begin
  if not Assigned(self) then Exit;
  i:= CliContracts.IndexOf(contID);        // индекс контракта
  if (i<0) then Exit;
  with TTwoCodes(CliContDefs[i]) do begin
    if (ID1<>deliv) then ID1:= deliv;
    if (ID2<>dest)  then ID2:= dest;
  end;
end;

{//=============================================== ссылки на наценки по контракту
function TClientInfo.GetContMarginLinks(contID: Integer): TLinkList; // not Free !!!
var i: integer;
begin
  Result:= TLinkList(EmptyList);
  if not Assigned(self) then Exit;
  i:= CliContracts.IndexOf(contID);        // индекс контракта
  if (i<0) then Exit;
  Result:= TLinkList(CliContMargins[i]);
end;
//===================================== наценка по группе/подгруппе по контракту
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
//================= список групп/подгрупп с наценками по контракту (TCodeAndQty)
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
//  sysID:= GetCliContract(contID).SysID;  // систему - по контракту
  sysID:= 0;  //
  mlst:= GetContMarginLinks(contID);         // ссылки на наценки клиента
  grlst:= Cache.MarginGroups.GetGroupList(sysID); // список групп
  for i:= 0 to grlst.Count-1 do begin
    gr:= grlst[i];         // группа
    grID:= gr.ID;
    mlink:= mlst.GetLinkListItemByID(grID, lkLnkByID); // ищем наценку
    if Assigned(mlink) then marg:= mlink.Qty else marg:= 0;
    if not OnlyNotZero or fnNotZero(marg) then
      Result.Add(TCodeAndQty.Create(Integer(gr), marg)); // ссылка на группу -> Integer, наценка

    if not WithPgr then Continue; // только группы

    pgrlst:= Cache.MarginGroups.GetSubGroupList(grID, sysID); // список подгрупп группы
    for j:= 0 to pgrlst.Count-1 do begin
      gr:= pgrlst[j];         // подгруппа
      grID:= gr.ID;
      mlink:= mlst.GetLinkListItemByID(grID, lkLnkByID); // ищем наценку
      if Assigned(mlink) then marg:= mlink.Qty else marg:= 0;
      if not OnlyNotZero or fnNotZero(marg) then
        Result.Add(TCodeAndQty.Create(Integer(gr), marg)); // ссылка на подгруппу -> Integer, наценка
    end;
  end;
end;
//================================== проверяем наценку по группе/подгуппе в базе
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
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create('ошибка записи в базу');
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
//============= проверяет соответствие складов клиента видимым складам контракта
procedure TClientInfo.UpdateStorageOrderC;
const nmProc = 'UpdateStorageOrderС';
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
  listChange:= TStringList.Create; // строки SQL для изменений
  Conts:= TIntegerList.Create;     // рабочий список контрактов фирмы для сверки
  try try
    IBDord:= cntsORD.GetFreeCnt;
    IBSord:= fnCreateNewIBSQL(IBDord, 'IBSord_'+nmProc, -1, tpRead, True);

    UserCode:= IntToStr(ID);
    FirmCode:= IntToStr(FirmID);
    Firma:= Cache.arFirmInfo[FirmID];
    MainUser:= Firma.SUPERVISOR;

    for i:= 0 to Firma.FirmContracts.Count-1 do // контракты фирмы - в рабочий список
      Conts.Add(Firma.FirmContracts[i]);

    IBSord.SQL.Text:= 'select WCCCONTRACT, WCCARCHIVE, WCCDeliveryDef, wccDestDef'+
                      ' from WEBCLIENTCONTRACTS WHERE WCCCLIENT='+UserCode;
    IBSord.ExecQuery;
    while not IBSord.EOF do begin
      contID:= IBSord.FieldByName('WCCCONTRACT').AsInteger;  // контракт
      flArh:= GetBoolGB(IBSord, 'WCCARCHIVE');
      flEx:= (CliContracts.IndexOf(contID)>-1);
//----------------------------------------- проверяем контракт из списка клиента
      if (Conts.IndexOf(contID)<0) then begin // если у фирмы нет контракта (закрыт)
        if not flArh then begin
          flArh:= True;            // пометить контракт клиента, как недоступный
          listChange.Add('update WEBCLIENTCONTRACTS set WCCARCHIVE="T"'+
            ' WHERE WCCCLIENT='+UserCode+' and WCCCONTRACT='+IntToStr(contID)+';');
        end;
        flDel:= flEx;
      end else begin
        if flArh and (ID=MainUser) then begin
          flArh:= False;            // пометить контракт клиента, как доступный
          listChange.Add('update WEBCLIENTCONTRACTS set WCCARCHIVE="F"'+
            ' WHERE WCCCLIENT='+UserCode+' and WCCCONTRACT='+IntToStr(contID)+';');
        end;
        flDel:= flEx and flArh;
        Conts.Remove(contID); // проверили контракт - удаляем из рабочего списка
      end;

      if flDel then DelCliContract(contID); // если контракт был в списке клиента - удаляем
      if flArh then begin                   // прокручиваем записи по недоступному контракту
        TestCssStopException;
        while not IBSord.EOF and (contID=IBSord.FieldByName('WCCCONTRACT').AsInteger) do IBSord.Next;
        Continue;
      end;

      if not flEx then AddCliContract(contID, True); // если контракта нет в списке клиента - добавляем
//      Contract:= Firma.GetContract(contID);

      if firma.IsFinalClient then begin // задать доставку (самовывоз)
        deliv:= cDelivSelfGet;
        dest:= 0;
      end else begin
        deliv:= IBSord.FieldByName('WCCDeliveryDef').AsInteger;
        dest:= IBSord.FieldByName('wccDestDef').AsInteger;

if flNotReserve then
        if (deliv=cDelivReserve) then deliv:= cDelivTimeTable;
      end;

      CheckCliContDefs(contID, deliv, dest); // проверка настроек по контракту

      TestCssStopException;
      IBSord.Next;
    end;
    IBSord.Close;

    for i:= 0 to Conts.Count-1 do begin // если главный пользователь и остались непроверенные контракты фирмы
      contID:= Conts[i];
      ii:= CliContracts.IndexOf(contID);
      if (ii<0) then begin
        if (ID<>MainUser) then Continue; // если не главный пользователь - пропускаем
        AddCliContract(contID, True); // если главный пользователь - добавляем контракт в список
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
//---------------------------------------------------------------------- наценки
    IBSord.SQL.Text:= 'Select WCCCONTRACT, WCCMGrPgrCode, WCCMmargin from'+
                      ' (select WCCCODE, WCCCONTRACT '+
                      '   from WEBCLIENTCONTRACTS WHERE WCCCLIENT='+UserCode+
                      '     and WCCARCHIVE="F" order by WCCCONTRACT)'+
                      ' left join WebCliContMargins on WCCMCliCont=WCCCODE';
    IBSord.ExecQuery;
    while not IBSord.EOF do begin
      contID:= IBSord.FieldByName('WCCCONTRACT').AsInteger;  // контракт
      i:= CliContracts.IndexOf(contID);
      if (i<0) then begin      // прокручиваем записи по недоступному контракту
        TestCssStopException;
        while not IBSord.EOF and (contID=IBSord.FieldByName('WCCCONTRACT').AsInteger) do IBSord.Next;
        Continue;
      end;

      mlst:= TLinkList(CliContMargins[i]);
      mlst.SetLinkStates(False, CS_client);
      while not IBSord.EOF and (contID=IBSord.FieldByName('WCCCONTRACT').AsInteger) do begin
        ii:= IBSord.FieldByName('WCCMGrPgrCode').AsInteger; // код группы/подгруппы
        marg   := IBSord.FieldByName('WCCMmargin').AsFloat;      // наценка
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
    if (listChange.Count>0) then begin //------------------- если есть изменения
      listChange.Insert(0, 'execute block as begin ');
      listChange.Add(' end');
      IBSord.SQL.Clear;
      fnSetTransParams(IBSord.Transaction, tpWrite, True);
      with IBSord.Transaction do if not InTransaction then StartTransaction;
      IBSord.SQL.AddStrings(listChange);
      IBSord.ExecQuery;                  // меняем в базе
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
//=================================================== проверка конечного клиента
function TClientInfo.CheckIsFinalClient: Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  if not Cache.FirmExist(FirmID) then Exit;
  Result:= Cache.arFirmInfo[FirmID].IsFinalClient;
end;
//========================================================== проверка блокировки
function TClientInfo.CheckBlocked(inCS: Boolean=False; mess: Boolean=False; Source: Integer=0): String;
const nmProc = 'CheckBlocked';
// iBlock, tLastAct - актуальные значения из базы, mess=True - вернуть в Result сообщение пользователю
var fl: Boolean;
    ss, sTimeTo, Delim: String;
//    tLastAct: TDateTime;
begin
  Result:= '';
  fl:= Blocked; // запоминаем состояние блокировки
  if InCS then CS_client.Enter;
  try

//-------------------------------------------------------- временно заблокирован
    if (BlockKind=cbBlockedTmpByConnLimit) then begin

      if (TmpBlockTime<1) then // вычисляем время окончания
        TmpBlockTime:= IncMinute(LastAct, Cache.GetConstItem(pcTmpBlockInterval).IntValue);

      if (Now>TmpBlockTime) then  //-------------- пора разблокировать временную
        if SaveClientBlockType(cbUnBlockedTmpByCSS, ID, LastAct) then // разблокировка клиента в базе
          BlockKind:= 0;                  // в кеше

//---------- другая блокировка - сбрасываем время окончания временной блокировки
    end else if (BlockKind in [cbBlockedByAdmin, cbBlockedByConnectLimit]) and (TmpBlockTime>0) then begin
      TmpBlockTime:= 0;

//--------- начался новый день - сбрасываем время окончания временной блокировки
    end else if (BlockKind=0) and (TmpBlockTime>0) and not SameDate(Now, TmpBlockTime) then begin
      TmpBlockTime:= 0;
    end;

    Blocked:= (BlockKind>0); // в кеше

    if Blocked and mess then begin // формируем сообщение пользователю о блокировке
      if not (Source in [cosByVlad, cosByWeb]) then Source:= cosByWeb;
      if (Source=cosByVlad) then Delim:= cStrVladDelim else Delim:= ''; // разделитель для Vlad

      ss:= MessText(mtkNotLoginProcess, Login); // 'Обработка запросов по логину '+Login+' заблокирована.'
      ss:= copy(ss, 1, length(ss)-1)+Delim; // отрезаем точку и добавляем разделитель для Vlad
      case BlockKind of
        cbBlockedBySearchLimit : ss:= ss+' из-за превышения лимита запросов.'; // из-за превышения лимита поисковых запросов за день
        cbBlockedByAdmin       : ss:= ss+' администратором системы заказов.'; // (вручную)
        cbBlockedTmpByConnLimit: begin
            sTimeTo:= FormatDateTime(cDateTimeFormatY4N, TmpBlockTime);
            ss:= ss+' до '+sTimeTo+Delim+' из-за превышения лимита запросов.';         // временно
          end;
        cbBlockedByConnectLimit: ss:= ss+' из-за повторного превышения лимита запросов.'; // окончательно
      end; // case
      Result:= ss;

    end else if not Blocked and fl then begin // если разблокировали - сбрасываем счетчики
      CountSearch:= 0;
      CountQty:= 0;
      CountConnect:= 0;
    end;
  finally
    if InCS then CS_client.Leave;
  end;
end;
//======================================== вкладываем отчет по запросам в письмо
procedure CheckRequestsAttach(clientID: Integer; var Att: TStringList; bTime, eTime: TDateTime);
const nmProc = 'CheckRequestsAttach';
var ss, nf: String;
begin
  ss:= fnRepClientRequests(clientID, bTime, eTime, nf);
  if (ss<>'') then prMessageLOGS(nmProc+': '+ss)
  else if (nf<>'') then Att.Add(nf);
end;
//================================================== проверяет счетчик коннектов
procedure TClientInfo.CheckConnectCount; // вызов - в prSetThLogParams
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
  if not Assigned(self) or Arhived or Blocked then Exit; // заблокирован
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
  minCount   := secCount div 60; // кол-во минут
  secCount   := secCount mod 60;
  BlockTime  := EndTime;
  try //--------------------------------------------------------------- проверка
    LimitCount:= Cache.GetConstItem(pcClientConnectLimit).IntValue;
    LimitInterval:= Cache.GetConstItem(pcClientConnLimInterval).IntValue;
    CS_client.Enter;
    try
      if (minCount>=LimitInterval) then begin
        LastCountConnectTime:= Now;     // сбрасываем счетчик
        iCount:= 1;                                                         
      end else iCount:= CountConnect+1; // добавляем счетчик

      if (iCount<>CountConnect) then CountConnect:= iCount; // меняем значение счетчика клиента
      if (CountConnect<=LimitCount) then Exit; // не превышает - выходим

      sCount:= '  '+IntToStr(CountConnect)+' запросов за '+IntToStr(minCount)+' мин '+IntToStr(secCount)+' сек';

// begin ---------------- тестовая рассылка 2 - при [Options] ConnectLimit_tmp=1
      if TestSending then try
        Body:= TStringList.Create;
        Attach:= TStringList.Create;
        with Cache do try
          Body.Add(FormatDateTime(cDateTimeFormatY4S, Now()));
          Body.Add('Пользователь с логином `'+Login+'` (код '+IntToStr(ID)+')');
          Body.Add('  контрагент '+FirmName);
          if FirmExist(FirmID) then begin
            s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
            if (s<>'') then Body.Add('  '+s);
          end;
          Body.Add('превысил лимит обращений к системе:');
          Body.Add(sCount);

          adrTo:= Cache.GetConstEmails(pcTestingSending2, FirmID);
          if adrTo='' then adrTo:= fnGetSysAdresVlad(caeOnlyDayLess);

          CheckRequestsAttach(ID, Attach, BeginTime, EndTime); // вкладываем отчет по запросам

          s:= n_SysMailSend(adrTo, 'превышение лимита обращений к системе', Body, Attach, '', '', True);
          if s<>'' then prMessageLOGS(nmProc+': error send mail to admins: '+s);

          for iCount:= 0 to Body.Count-1 do begin // пишем в лог
            s:= Body[iCount];
            if (trim(s)='') then Continue;
            if iCount=0 then prMessageLOGS(nmProc+': '+s) else prMessageLOGS(s);
          end;
          LastCountConnectTime:= EndTime; // сбрасываем счетчик
          CountConnect:= 0;
        except
          on E: Exception do prMessageLOGS(nmProc+'('+IntToStr(ID)+'): '+E.Message);
        end;
        exit;
      finally
        prFree(Body);
        ClearAttachments(Attach, True);
      end;
// end ----------------------------------------------------- тестовая рассылка 2     

//----------------------------------------------------------- блокировка клиента
      BlockType:= fnIfInt(flTmpBlock, cbBlockedTmpByConnLimit, cbBlockedByConnectLimit);
      OldBlockKind:= BlockKind;
      OldBlocked:= Blocked;
      Blocked:= True;              // блокировка в кеше
      BlockKind:= BlockType;
      if SaveClientBlockType(BlockType, ID, BlockTime) then begin // блокировка в базе
        LastCountConnectTime:= EndTime;
        CountConnect:= 0;            // сбрасываем счетчик
        if flTmpBlock then begin     // временная блокировка
          TmpBlockTime:= IncMinute(BlockTime, Cache.GetConstItem(pcTmpBlockInterval).IntValue);
                       // добавляем 2 мин из-за возм.разницы времени на серверах
          sTimeTo:= FormatDateTime(cDateTimeFormatY4N, IncMinute(TmpBlockTime, 2));
        end else TmpBlockTime:= 0;   // окончательная блокировка

      end else begin // не получилась блокировка - откат в кеше
        Blocked:= OldBlocked;
        BlockKind:= OldBlockKind;
      end;
    finally
      CS_client.Leave;
    end;
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  if not Blocked then exit; // если не получилось - выходим
                                                                                      
//--------------------------------------------- рассылаем извещения о блокировке
  Body:= TStringList.Create;
  Attach:= TStringList.Create;
  with Cache do try
    cliMail:= ExtractFictiveEmail(Mail); //------------------------ пользователю
    if (cliMail='') then begin  // ищем Mail фирмы ???
      cliMess:= 'Уведомление о блокировке клиенту не отправлено - не найден Email';
    end else begin
      Body.Add('Учётная запись пользователя (логин `'+Login+'`) заблокирована');
      if flTmpBlock then begin // временная блокировка
        Body.Add(' до '+sTimeTo+' из-за превышения лимита обращений к системе.');
//        Body.Add('По вопросу срочной разблокировки'+#10' обращайтесь к торговому представителю Компании.');
      end else begin
        Body.Add(' из-за повторного превышения лимита обращений к системе.');
        Body.Add('По вопросу разблокировки обращайтесь');
        Body.Add(' к торговому представителю Компании.');
      end;
      s:= n_SysMailSend(cliMail, 'Уведомление о блокировке учетной записи', Body, nil, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // если не записалось в файл
        prMessageLOGS(nmProc+'(send mail to client): '+s);
        cliMess:= 'Ошибка отправки уведомления о блокировке клиенту';
      end else
        cliMess:= 'Уведомление о блокировке отправлено клиенту на Email '+cliMail;
    end;

    regMail:= ''; //----------------------------------------- по списку рассылки
    Body.Clear;
    Body.Add(FormatDateTime(cDateTimeFormatY4S, Now()));
    Body.Add('Пользователь с логином `'+Login+'` (код '+IntToStr(ID)+')');
    Body.Add('  контрагент '+FirmName);
    if FirmExist(FirmID) then begin
      s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
      if (s<>'') then Body.Add('  '+s);
    end;

    if flTmpBlock then begin // временная блокировка
      regMail:= Cache.GetConstEmails(pcEmpl_list_TmpBlock, mess, FirmID);
      Body.Add('превысил лимит обращений к системе.');
      iCount:= Body.Count; // запоминаем позицию для вставки кол-ва запросов
      Body.Add(#10'Учетная запись в системе заказов заблокирована до '+sTimeTo);
    end else begin   // окончательная блокировка
      regMail:= Cache.GetConstEmails(pcEmpl_list_FinalBlock, mess, FirmID);
      Body.Add('повторно превысил лимит обращений к системе.');
      iCount:= Body.Count; // запоминаем позицию для вставки кол-ва запросов
      Body.Add(#10'Учетная запись в системе заказов заблокирована.');
    end;
    if cliMess<>'' then Body.Add(#10+cliMess);

    cliMess:= '';                         // история блокировок из протокола
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
        ORD_IBS.ParamByName('time1').AsDateTime:= IncMonth(Date, -HistInterval); // за HistInterval м-цев
        ORD_IBS.ParamByName('time2').AsDateTime:= IncMinute(BlockTime, -5);      // до этой блокировки
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
        1: ss:= 'м-ц';
        2..4: ss:= 'м-ца';
        5..12: ss:= 'м-цев';
        else ss:= '';
      end;
      if ss<>'' then ss:= ' за '+IntToStr(HistInterval)+' '+ss;
      Body.Add(#10+'История блокировок клиента'+ss+':'+cliMess);
    end;

    CheckRequestsAttach(ID, Attach, BeginTime, EndTime); // вкладываем отчет по запросам

    if regMail='' then // в s запоминаем строку в письмо контролю
      s:= 'Сообщение о блокировке клиента не отправлено - не найдены E-mail рассылки'
    else begin
      s:= n_SysMailSend(regMail, 'Блокировка учетной записи пользователя', Body, Attach, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // если не записалось в файл
        prMessageLOGS(nmProc+'(send mail to empls): '+s);
        s:= 'Ошибка отправки сообщения о блокировке клиента на Email: '+regMail;
      end else s:= 'Сообщение о блокировке клиента отправлено на Email: '+regMail;
    end;
                             //---------------------------- контролю (Щербакову)
    if s<>''       then Body.Add(#10+s);
    if mess<>''    then Body.Add(#10+mess); // сообщение о ненайденных адресах

    adrTo:= Cache.GetConstEmails(pcBlockMonitoringEmpl, mess, FirmID);
    if mess<>'' then Body.Add(mess);

    if adrTo='' then adrTo:= GetSysTypeMail(constIsAuto); // адрес отв. за авто (на всяк.случай)

    if adrTo<>'' then begin
      s:= n_SysMailSend(adrTo, 'Блокировка учетной записи пользователя', Body, Attach, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
        prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
    end;
                             //----------------------------------------- админам
    Body.Insert(iCount, 'for admin ----- '+sCount); // вставка кол-ва запросов

    adrTo:= GetConstEmails(pcEmplORDERAUTO);
    if adrTo='' then adrTo:= fnGetSysAdresVlad(caeOnlyDayLess);
    if adrTo<>'' then begin
      s:= n_SysMailSend(adrTo, 'Блокировка учетной записи пользователя', Body, Attach, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
        prMessageLOGS(nmProc+'(send mail to admins): '+s);
    end;
                             // ------------------------------------ пишем в лог
    prMessageLOGS(nmProc+': блокировка клиента');
    for iCount:= 0 to Body.Count-1 do if trim(Body[iCount])<>'' then
      prMessageLOGS(StringReplace(Body[iCount], #10, '', [rfReplaceAll]));
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message);
  end;
  prFree(Body);
  ClearAttachments(Attach, True);
end;
//======================= проверяет счетчик запросов наличия (сообщение админам)
procedure TClientInfo.CheckQtyCount;
const nmProc = 'CheckQtyCount';
var iCount, LimitCount, LimitInterval, minCount, secCount: Integer;
    s, adrTo: String;
    Body, Attach: TStringList;
    BeginTime, EndTime: TDateTime;
begin
  if not Assigned(self) or Arhived or Blocked then Exit; // заблокирован
  CS_client.Enter;
  try try
    LimitCount:= Cache.GetConstItem(pcMaxClientQtyCount).IntValue;
    LimitInterval:= Cache.GetConstItem(pcMaxClientQtyInterval).IntValue;
    BeginTime:= LastCountQtyTime;
    EndTime:= Now;
    secCount:= SecondsBetween(BeginTime, EndTime);
    minCount:= secCount div 60; // кол-во полных минут
    secCount:= secCount mod 60;
    if (minCount>=LimitInterval) then begin
      LastCountQtyTime:= EndTime;     // сбрасываем счетчик
      iCount:= 1;
    end else iCount:= CountQty+1; // добавляем счетчик
    if iCount<>CountQty then CountQty:= iCount; // меняем значение счетчика
    if CountQty<=LimitCount then Exit; // не превышает - выходим

//---------------------------------------------------------  тестовая рассылка 1
    Body:= TStringList.Create;
    Attach:= TStringList.Create;
    with Cache do try
      Body.Add(FormatDateTime(cDateTimeFormatY4S, Now()));
      Body.Add('Пользователь с логином `'+Login+'` (код '+IntToStr(ID)+')');
      Body.Add('  контрагент '+FirmName);
      if FirmExist(FirmID) then
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref])
      else s:= '';
      if (s<>'') then Body.Add('  '+s);
      Body.Add('превысил лимит запросов наличия:');
      Body.Add('  '+IntToStr(CountQty)+' запросов за '+IntToStr(minCount)+' мин '+IntToStr(secCount)+' сек');

      CheckRequestsAttach(ID, Attach, BeginTime, EndTime); // вкладываем отчет по запросам

      adrTo:= Cache.GetConstEmails(pcTestingSending1, FirmID);
      if adrTo='' then adrTo:= fnGetSysAdresVlad(caeOnlyDayLess);

      s:= n_SysMailSend(adrTo, 'превышение лимита запросов наличия', Body, Attach, '', '', True);
      if s<>'' then prMessageLOGS(nmProc+': error send mail to admins: '+s);

      for iCount:= 0 to Body.Count-1 do begin // пишем в лог
        s:= Body[iCount];
        if (trim(s)='') then Continue;
        if iCount=0 then prMessageLOGS(nmProc+': '+s) else prMessageLOGS(s);
      end;

      LastCountQtyTime:= EndTime; // сбрасываем счетчик
      CountQty:= 0;
    finally
      prFree(Body);
      ClearAttachments(Attach, True);
    end;
//---------------------------------------------------------  тестовая рассылка 1
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
//================================================================= получить код
function TEmplInfoItem.GetIntE(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FID;       // = EMPLCODE(GB)
    ik8_2: Result:= FSubCode;  // = EMPLMANCODE(GB)
    ik8_3: Result:= FOrderNum; // код подразделения из EMPLDPRTCODE(ORD, EMPLOYEES)
    ik8_4: Result:= FFaccReg;   // регион
  end;
end;
//================================================================= записать код
procedure TEmplInfoItem.SetIntE(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if (FID      <>Value) then FID      := Value; // = EMPLCODE(GB)
    ik8_2: if (FSubCode <>Value) then FSubCode := Value; // = EMPLMANCODE(GB)
    ik8_3: if (FOrderNum<>Value) then FOrderNum:= Value; // код подразделения из EMPLDPRTCODE(ORD, EMPLOYEES)
    ik8_4: if (FFaccReg <>Value) then FFaccReg := Value; // регион
  end;
end;
//============================================================== получить строку
function TEmplInfoItem.GetStrE(const ik: T16InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik16_1: Result:= FSurname;     // фамилия из MANS
    ik16_2: Result:= FName;        // имя из MANS
    ik16_3: Result:= FPatron;      // отчество из MANS
    ik16_4: Result:= FServerLog;   // логин из EMPLLOGIN(ORD, EMPLOYEES)
    ik16_5: Result:= FPASSFORSERV; // пароль из EMPLPASS(ORD, EMPLOYEES)
    ik16_6: Result:= FGBLogin;     // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    ik16_7: Result:= FGBRepLogin;  // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    ik16_8: Result:= FMail;        // Email
    ik16_9: Result:= FSession;
    ik16_10: begin                 // краткое Ф И.О. сотрудника
        Result:= FSurname;
        if FName<>''   then Result:= Result+' '+AnsiUpperCase(copy(FName, 1, 1))+'.';
        if FPatron<>'' then Result:= Result+AnsiUpperCase(copy(FPatron, 1, 1))+'.';
      end;
    ik16_11: begin                  // полное Ф И О сотрудника
        Result:= FSurname;
        if FName<>''   then Result:= Result+' '+FName;
        if FPatron<>'' then Result:= Result+' '+FPatron;
      end;
  end;
end;
//============================================================== записать строку
procedure TEmplInfoItem.SetStrE(const ik: T16InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik16_1: if (FSurname    <>Value) then FSurname    := Value; // фамилия из MANS
    ik16_2: if (FName       <>Value) then FName       := Value; // имя из MANS
    ik16_3: if (FPatron     <>Value) then FPatron     := Value; // отчество из MANS
    ik16_4: if (FServerLog  <>Value) then FServerLog  := Value; // логин из EMPLLOGIN(ORD, EMPLOYEES)
    ik16_5: if (FPASSFORSERV<>Value) then FPASSFORSERV:= Value; // пароль из EMPLPASS(ORD, EMPLOYEES)
    ik16_6: if (FGBLogin    <>Value) then FGBLogin    := Value; // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTCODE
    ik16_7: if (FGBRepLogin <>Value) then FGBRepLogin := Value; // логин из USLSUSERID (GB, USERLIST) USLSCODE=TEmplInfoItem.USERLISTREPORTCODE
    ik16_8: if (FMail       <>Value) then FMail       := Value; // Email
    ik16_9: if (FSession    <>Value) then FSession    := Value;
  end;
end;
//================================================ проверяем длину массива ролей
procedure TEmplInfoItem.TestUserRolesLength(len: integer; ChangeOnlyLess: boolean=True; inCS: boolean=True);
var fl: boolean;
begin
  if not Assigned(self) then Exit;
  if ChangeOnlyLess then fl:= (Length(UserRoles)<len) else fl:= (Length(UserRoles)<>len);
  if fl then try // если надо менять длину
    if inCS then Cache.CS_Empls.Enter;
    if Length(UserRoles)<len then
      prCheckLengthIntArray(UserRoles, len-1) // добавляем длину массива, если надо, и инициируем элементы
    else SetLength(UserRoles, len);
  finally
    if inCS then Cache.CS_Empls.Leave;
  end;
end;
//======================================================= проверяем список ролей
procedure TEmplInfoItem.TestUserRoles(roles: Tai);
var i: integer;
begin
  if not Assigned(self) then Exit else try
    Cache.CS_Empls.Enter;                    // проверяем /изменяем длину массива
    TestUserRolesLength(length(roles), false, false);
    for i:= 0 to High(roles) do  // идем по новому списку
      if UserRoles[i]<>roles[i] then UserRoles[i]:= roles[i];
  finally
    Cache.CS_Empls.Leave;
  end;
end;
//=============================================================== добавляем роль
procedure TEmplInfoItem.AddUserRole(role: Integer);
var i: integer;
begin
  if not Assigned(self) then Exit;
  i:= fnInIntArray(role, UserRoles); // проверяем присутствие роли в массиве
  if i>-1 then Exit;                 // если есть - выходим
  i:= Length(UserRoles);
  try
    Cache.CS_Empls.Enter;
    TestUserRolesLength(i+1, true, false); // добавляем длину массива
    UserRoles[i]:= role;                   // добавляем роль
  finally
    Cache.CS_Empls.Leave;
  end;
end;
//================================================================= удаляем роль
procedure TEmplInfoItem.DelUserRole(role: Integer);
var i, j: integer;
begin
  if not Assigned(self) then Exit;
  i:= fnInIntArray(role, UserRoles); // проверяем присутствие роли в массиве
  if i<0 then Exit;                  // если нет - выходим
  try
    Cache.CS_Empls.Enter;                                         // удаляем роль
    for j:= i to Length(UserRoles)-2 do UserRoles[j]:= UserRoles[j+1];
    TestUserRolesLength(Length(UserRoles)-1, false, false); // обрезаем длину массива
  finally
    Cache.CS_Empls.Leave;
  end;
end;
//=============================================================== проверяем роль
function TEmplInfoItem.UserRoleExists(role: Integer): boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= fnInIntArray(role, UserRoles)>-1; // проверяем присутствие роли в массиве
end;
//======================================== сортировка линков с видимыми складами
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
  CS_firm:= TCriticalSection.Create; // для изменения параметров
  SetLength(FirmClients, 0);
  FirmClasses:= TIntegerList.Create;   // коды категорий фирмы
  FirmContracts:= TIntegerList.Create; // контракты фирмы
  FirmManagers:= TIntegerList.Create;  // менеджеры фирмы
  LastDebtTime:= DateNull;
  LastTestTime:= DateNull;
  PartiallyFilled:= True;
  FHostCode:= pID;
  FBonusQty:= 0;
  FResLimit:= -1;
  FAllOrderSum:= 0;
  FBoolFOpts:= [];
//  FLabelLinks:= TLinks.Create(CS_firm); // связки с наклейками
  FirmDiscModels:= TObjectList.Create; // действующие шаблоны скидок фирмы
  LegalEntities:= TObjectList.Create;  // юрид.фирмы к/а, Object - TBaseDirItem
  FirmDestPoints:= TObjectList.Create; // торговые точки к/а, Object - TDestPoint
  FirmCredProfiles:= TObjectList.Create; // профили кред.условий к/а, Object - TCredProfile
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
//============================================================== записать строку
procedure TFirmInfo.SetStrF(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then Exit;
  Value:= fnChangeEndOfStrBySpace(Value);
  case ik of
    ik8_1: if (FUPPERSHORTNAME<>Value) then FUPPERSHORTNAME:= Value;
    ik8_2: if (FUPPERMAINNAME <>Value) then FUPPERMAINNAME := Value;
    ik8_3: if (FNUMPREFIX     <>Value) then FNUMPREFIX     := Value; // префикс фирмы клиента
    ik8_4: if (FActionText    <>Value) then FActionText:= Value;     // состояние участия в акции
  end;
end;
//============================================================== получить строку
function TFirmInfo.GetStrF(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FUPPERSHORTNAME;
    ik8_2: Result:= FUPPERMAINNAME;
    ik8_3: Result:= FNUMPREFIX;               // префикс фирмы клиента
    ik8_4: Result:= FActionText;             // состояние участия в акции
    ik8_5: Result:= Cache.GetFirmTypeName(FFirmType);
  end;
end;
//================================================================= получить код
function TFirmInfo.GetIntF(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_2: Result:= FSUPERVISOR;  // код главного пользователя
    ik8_3: Result:= FFirmType;
    ik8_4: Result:= FHostCode;    // код для связи с наклейками
    ik8_5: Result:= FContUnitOrd; // код контракта unit-заказа
  end;
end;
//================================================================= записать код
procedure TFirmInfo.SetIntF(const ik: T8InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_2: if (FSUPERVISOR  <>Value) then FSUPERVISOR  := Value; // код главного пользователя
    ik8_3: if (FFirmType    <>Value) then FFirmType    := Value;
    ik8_4: if (FHostCode    <>Value) then FHostCode    := Value; // код для связи с наклейками
    ik8_5: if (FContUnitOrd <>Value) then FContUnitOrd := Value; // код контракта unit-заказа
  end;
end;
//======================================================= получить вещ. значение
function TFirmInfo.GetDoubF(const ik: T8InfoKinds): Double;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FBonusQty;     // кол-во бонусов к/а
    ik8_2: Result:= FBonusRes;     // кол-во бонусов к/а в резерве
    ik8_3: Result:= FResLimit;     // лимит резерва
    ik8_4: Result:= FAllOrderSum;  // сумма резерва
  end;
end;
//======================================================= записать вещ. значение
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
//============================================================= получить признак
function TFirmInfo.GetBoolF(const ik: T8InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FBoolFOpts);
end;
//============================================================= записать признак
procedure TFirmInfo.SetBoolF(const ik: T8InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FBoolFOpts:= FBoolFOpts+[ik] else FBoolFOpts:= FBoolFOpts-[ik];
end;
//================================================================= получить код
function TFirmInfo.GetRegional: Integer;          // получить код менеджера по def-контракту  // временно
var empl: TEmplInfoItem;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if GetDefContract.FindContManager(empl) then Result:= Empl.ID; // код менеджера
end;
//=============== список кодов/ЦФУ/ФИО/Email-ов менеджеров фирмы (через запятую)
function TFirmInfo.GetFirmManagersString(params: TFirmManagerParams=[fmpName, fmpShort]): String;
//    TFirmManagerParam = (fmpCode, fmpName, fmpEmail, fmpShort, fmpPref, fmpFacc);
// 1. fmpCode - список кодов менеджеров, +fmpFacc - список кодов ЦФУ (остальные игнорируются)
// 2. fmpEmail - список Email-ов менеджеров (остальные игнорируются)
// 3. fmpName - список полных ФИО менеджеров, +fmpShort - фамилия+инициалы,
// 4. fmpName + fmpFacc - список полных наименований ЦФУ
// 3-4. +fmpPref - с префиксом 'менеджеры к/а ' или 'ЦФУ к/а '

var i, j, pID: Integer;
    Empl: TEmplInfoItem;
    s: String;
    ilst: TIntegerList;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  j:= 0; // счетчик
//-------------------------------------------------------------------------- ЦФУ
  if (fmpFacc in params) then try
    ilst:= TIntegerList.Create;
    for i:= 0 to FirmContracts.Count-1 do begin // собираем коды ЦФУ, убираем дубляж
      pID:= FirmContracts[i];
      if not Cache.Contracts.ItemExists(pID) then Continue;
      ilst.Add(Cache.Contracts[pID].FacCenter);
    end;
    for i:= 0 to ilst.Count-1 do begin
      pID:= ilst[i];
      if not Cache.FiscalCenters.ItemExists(pID) then Continue;
      s:= '';
      if (fmpCode in params) then s:= IntToStr(pID) // коды
      else if (fmpName in params) then              // наименования
        s:= TFiscalCenter(Cache.FiscalCenters[pID]).Name;
      if (s<>'') then begin
        Result:= Result+fnIfStr(Result='', '', ', ')+s;
        inc(j);
      end;
    end;
  finally
    prFree(ilst);
//-------------------------------------------------------------------- менеджеры
  end else for i:= 0 to FirmManagers.Count-1 do begin
    pID:= FirmManagers[i];
    if not Cache.EmplExist(pID) then Cache.TestEmpls(pID);
    if not Cache.EmplExist(pID) then Continue;
    s:= '';
    if (fmpCode in params) then s:= IntToStr(pID) // коды
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
    if (fmpFacc in params) then s:= 'ЦФУ к/а '
    else if (fmpName in params) then begin
      if j>1 then s:= 'менеджеры к/а '
      else if j>0 then s:= 'менеджер к/а ';
    end;
    if (s<>'') then Result:= s+' '+Result;
  end;
end;
//===================================================== проверка менеджера фирмы
function TFirmInfo.CheckFirmManager(emplID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (FirmManagers.IndexOf(emplID)>-1);
  if not Result then Exit;
  if not Cache.EmplExist(emplID) then Cache.TestEmpls(emplID);
  Result:= Cache.EmplExist(emplID) and not Cache.arEmplInfo[emplID].Arhived;
end;
//======================================================= проверка региона фирмы
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
//=================================================== получить код def-контракта
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
    for i:= Count-1 downto 0 do begin // ищем с конца
      k:= Items[i];
      if not Cache.Contracts.ItemExists(k) then Continue;
      Result:= k;
      with Cache.Contracts[k] do begin
        if (Status=cstClosed) then Continue; // недоступный пропускаем
        if ContDefault then Exit; // нашли по признаку - выходим
        if (kp<1) and (PayType=0) then kp:= k; // запоминаем код последнего наличного контракта
      end;
    end; // если по признаку не нашли, в Result - код 1-го существующего контракта
    if (kp>0) and (kp<>Result) then Result:= kp; // если нашли наличный - берем его
  end;
end;
//======================================================== получить def-контракт
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
      if Result.ContDefault then Exit; // нашли по признаку
    end; // если по признаку не нашли, в Result - последний действующий контракт
  end;
end;
//====================================== проверка принадлежности контракта фирме
function TFirmInfo.CheckContract(contID: Integer): boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (contID>0) and Cache.Contracts.ItemExists(contID) and (FirmContracts.IndexOf(contID)>-1);
end;
//============================================= получить список контрактов фирмы
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
//============================================== получить контракт фирмы по коду
function TFirmInfo.GetContract(var contID: Integer): TContract;
// если контракт не найден, возвращает def-контракт и меняет contID
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if CheckContract(contID) then Result:= Cache.Contracts[contID]
  else begin
    Result:= GetDefContract;
    if Assigned(Result) then contID:= Result.ID;
  end;
end;
//======================= найти действующий контракт фирмы (желательно наличный)
function TFirmInfo.GetAvailableContract: TContract;
// если контракт не найден, возвращает nil
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
      Contract:= Cache.Contracts[jj];             // ищем действующий наличный
      if (Contract.Status>cstClosed) then begin
        if (Contract.PayType=0) then break; // нашли наличный
        if not Assigned(Contract1) then Contract1:= Contract;  // запоминаем последний действующий
      end;
      Contract:= nil;
    end;
  end;
  if Assigned(Contract) then Result:= Contract // не нашли наличный - берем последний действующий
  else if Assigned(Contract1) then Result:= Contract1;
end;
//===================================== проверка/изменение контракта unit-заказа
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
//=========================================== проверяем список сотрудников фирмы
procedure TFirmInfo.TestFirmClients(codes: Tai; j: integer=0; inCS: boolean=True);
// codes- массив кодов сотрудников, j- кол-во, если 0 - длина массива codes
// inCS=True - проверять в CriticalSection
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
//======================================================== проверка WIN-запросов
function TFirmInfo.CheckFirmVINmail: boolean;
var i: Integer;
    ar: Tai;
    s1, s2, s3: String;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  s1:= Cache.GetConstItem(pcVINmailEmpl_list).StrValue;
  if (s1='') then Exit; // адресов нет - выходим

  s1:= Cache.GetConstItem(pcVINmailFirmTypes_list).StrValue;
  s2:= Cache.GetConstItem(pcVINmailFilial_list).StrValue;
  s3:= Cache.GetConstItem(pcVINmailFirmClass_list).StrValue;
  if (s1='') and (s2='') and (s3='') then Exit; // параметров нет - выходим
  SetLength(ar, 0);
  try
    if (s1<>'') then begin // если заданы типы
      ar:= fnArrOfCodesFromString(s1);
      if (fnInIntArray(FirmType, ar)<0) then Exit; // тип не подходит - выходим
    end;

    if (s2<>'') then begin // если заданы филиалы
      ar:= fnArrOfCodesFromString(s2);
      if (fnInIntArray(GetDefContract.Filial, ar)<0) then Exit; // филиал не подходит - выходим
    end;

    if (s3<>'') then begin // если заданы категории
      ar:= fnArrOfCodesFromString(s3);
      for i:= 0 to FirmClasses.Count-1 do begin
        Result:= (fnInIntArray(FirmClasses[i], ar)>-1);
        if Result then Break; // категория подходит - выходим
      end;
    end else Result:= True;

  finally
    SetLength(ar, 0);
  end;
end;
//======================================== проверка разрешения скачивания прайса
function TFirmInfo.CheckFirmPriceLoadEnable: boolean;
var i: Integer;
    ar: Tai;
    s1: String;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  s1:= Cache.GetConstItem(pcPriceLoadFirmClasses).StrValue;
  if (s1='') then Exit; // категорий нет - выходим

  SetLength(ar, 0);
  try
    ar:= fnArrOfCodesFromString(s1);
    for i:= 0 to FirmClasses.Count-1 do begin
      Result:= (fnInIntArray(FirmClasses[i], ar)>-1);
      if Result then Break; // категория подходит - выходим
    end;
  finally
    SetLength(ar, 0);
  end;
end;
//========================= проверка показа товаров б/остатков в поисках (Ирбис)
function TFirmInfo.CheckShowZeroRests: boolean;
var ar: Tai;
    s1: String;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  s1:= Cache.GetConstItem(pcShowZeroRestsFirms).StrValue;
  if (s1='') then Exit; // кодов нет - выходим

  SetLength(ar, 0);
  try
    ar:= fnArrOfCodesFromString(s1);
    Result:= (fnInIntArray(ID, ar)>-1);
  finally
    SetLength(ar, 0);
  end;
end;
//========================================= проверка разрешения загрузки заказов
function TFirmInfo.CheckFirmOrderImportEnable: boolean;
var ii: Integer;
begin
  Result:= False;
  if not Assigned(self) then Exit;

  ii:= Cache.GetConstItem(pcOrderImportFirmClass).IntValue;
  if (ii<1) then Exit; // категории нет - выходим

  Result:= (FirmClasses.IndexOf(ii)>-1);
end;
//================================ текущие шаблон скидок и оборот по направлению
function TFirmInfo.GetCurrentDiscModel(direct: Integer; var firmSales: Integer): TDiscModel;
var i, j: Integer;
begin
  Result:= Cache.DiscountModels.EmptyModel;
  firmSales:= 0;
  for i:= FirmDiscModels.Count-1 downto 0 do begin
    with TTwoCodes(FirmDiscModels[i]) do
    if (ID1=direct) then begin
      j:= ID2;              // код текущего шаблона
      Result:= Cache.DiscountModels[j];
      firmSales:= Round(Qty); // округл. текущий оборот
      Exit;
    end;
  end;
end;
//================================================== получить торг.точку по коду
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
//================================================ получить кред.профиль по коду
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
//=========================== получить общее превышение лимита в заданной валюте
function TFirmInfo.GetOverSummAll(currID: integer; var OverSumm: Double): String;
// если лимит превышен - возвращает сообщение о превышении
var curr: Double;
begin
  Result:= '';
  OverSumm:= 0;
  if not Assigned(self) or (ResLimit<0) then Exit;

  if (ResLimit=0) then begin
    Result:= 'Резервирование заблокировано';
    Exit;
  end;

  OverSumm:= AllOrderSum-ResLimit; // превышение в у.е.
  if (CurrID<>cDefCurrency) then begin
    curr:= Cache.Currencies.GetCurrRate(CurrID);
    if fnNotZero(curr) then                // превышение в заданной валюте
      OverSumm:= OverSumm*Cache.Currencies.GetCurrRate(cDefCurrency)/curr;
  end;
  if (OverSumm>0.0099) then Result:= 'Лимит резерва превышен на '+
    FormatFloat(cFloatFormatSumm, OverSumm)+' '+Cache.GetCurrName(CurrID, True);
end;
//============================================ нештатная проверка лимита резерва
procedure TFirmInfo.CheckReserveLimit;
const nmProc = 'CheckReserveLimit'; // имя процедуры/функции
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
      else lim:= RoundTo(ibs.FieldByName('FirmOrderLimit').AsFloat, -2); // лимит
      sum:= RoundTo(IBS.FieldByName('Reserve').AsFloat, -2);        // резерв в у.е.
      if fnNotZero(ResLimit-lim) or fnNotZero(AllOrderSum-sum) then try
        CS_firm.Enter;    // обновляем значения
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
  FModelLinks:= TLinkList.Create;  // связки с моделями
  FFileLinks := TLinks.Create(CS); // связки с файлами
  FAttrLinks := TLinks.Create(CS); // связки с атрибутами и их значениями
  FRestLinks := TLinks.Create(CS); // связки со складами и остатками
  FSatelLinks:= TLinks.Create(CS); // связки с сопутствующими товарами
  FGBAttLinks:= TLinks.Create(CS); // связки с атрибутами Grossbee и их значениями
  FPrizAttLinks:= TLinks.Create(CS); // связки с атрибутами подарков и их значениями
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
  FAnalogLinks:= TLinks.Create(CS); // связки с аналогами
  FONumLinks  := TLinkList.Create;  // связки с оригинальными номерами
end;
//==================================================
destructor TInfoWareOpts.Destroy;
begin
  if not Assigned(self) then Exit;
  prFree(FAnalogLinks); // связки с аналогами
  prFree(FONumLinks);   // связки с оригинальными номерами
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
  CS_wlinks:= TCriticalSection.Create; // для изменения линков, аналогов
  FDiscModLinks:= nil;    // связки с шаблонами скидок
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
//======================================= очистка связей (удаление при проверке)
procedure TWareInfo.ClearOpts;
var i, j, wareID: integer;
begin
  if not Assigned(self) then Exit;
  wareID:= ID;
  if Assigned(FWareOpts) then with FWareOpts do if Assigned(FModelLinks) then
    for i:= 0 to FModelLinks.Count-1 do try // связки с моделями
      if assigned(FModelLinks[i]) then with TModelAuto(FModelLinks[i]) do
        if assigned(NodeLinks) then with NodeLinks do for j:= LinkCount-1 downto 0 do
          if DoubleLinkExists(ListLinks[j], wareID) then try
            GetDoubleLinks(ListLinks[j]).DelLinkListItemByID(wareID, lkLnkNone, CS_wlinks);
          except end;
    except end;

  if Assigned(FInfoWareOpts) then with FInfoWareOpts do try
    // аналоги  ???
    if Assigned(ONumLinks) then // связки с ОН
      for i:= 0 to ONumLinks.Count-1 do begin
        j:= GetLinkID(ONumLinks[i]);
        with Cache.FDCA do if OrigNumExist(j) then try
          arOriginalNumInfo[j].Links.DeleteLinkItem(wareID);
        except end;
      end;
  except end;
end;
//============================================================== получить связки
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
//============================================================== получить связки
function TWareInfo.GetWareLinkList(const ik: T8InfoKinds): TLinkList;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  case ik of
   ik8_1: if assigned(FInfoWareOpts) then Result:= FInfoWareOpts.FONumLinks;
   ik8_2: if assigned(FWareOpts) then Result:= FWareOpts.FModelLinks;
   ik8_3: begin // связки с шаблонами скидок
            if not assigned(FDiscModLinks) then FDiscModLinks:= TLinkList.Create;
            Result:= FDiscModLinks;
          end;
  end;
end;
//=================================================== признак товара для продажи
function TWareInfo.IsMarketWare(FirmID: Integer=IsWe; contID: Integer=0): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(Cache) or IsINFOgr or IsArchive then Exit;

  Result:= fnNotZero(RetailPrice(FirmID, cDefCurrency, contID));
end;
//=================================================== признак товара для продажи
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
    ca_GR,       ca_GR_OE      : Result:= IsOldAnalog or (IsCross and (SrcID=soGrossBee));      // старые аналоги + кроссы GrossBee
//        ca_GR,       ca_GR_OE      : Result:= IsOldAnalog;  // старые аналоги
    ca_Ex_TD,    ca_Ex_TD_OE   : Result:= IsCross;                                              // все кроссы
    ca_TD,       ca_TD_OE      : Result:= IsCross and (SrcID in [soTecDocBatch, soTDparts, soTDsupersed, soTDold]); // кроссы TD
    ca_Ex,       ca_Ex_OE      : Result:= IsCross and (SrcID in [soHand, soGrossBee, soExcel]);             // кроссы Excel
    ca_GR_TD,    ca_GR_TD_OE   : Result:= IsOldAnalog or (IsCross and (SrcID in [soTecDocBatch, soTDparts, soTDsupersed, soTDold])); // старые + кроссы TD
    ca_GR_Ex,    ca_GR_Ex_OE   : Result:= IsOldAnalog or (IsCross and (SrcID in [soHand, soGrossBee, soExcel])); // старые + кроссы Excel
    ca_GR_Ex_TD, ca_GR_Ex_TD_OE: Result:= IsOldAnalog or IsCross;                               // все
  end; // case
end;
//========================== получить список кодов аналогов товара с источниками
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
  if (ShowKind=ca_OE) then Exit;                // только OE

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
//======================================== получить массив кодов аналогов товара
function TWareInfo.Analogs: Tai;  // must Free
var i, j, ShowKind: Integer;
    link: TAnalogLink;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not Assigned(FInfoWareOpts)
    or not Assigned(FInfoWareOpts.FAnalogLinks) then Exit;

  ShowKind:= Cache.GetConstItem(pcAnalogsShowKind).IntValue;
  if (ShowKind=ca_OE) then Exit;                // только OE

  CS_wlinks.Enter;
  with FInfoWareOpts.FAnalogLinks do try
    SetLength(Result, LinkCount);
    j:= 0;    // счетчик Result
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
//======================== добавить в кеш линк с аналогом (def - аналог Гроссби)
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
      if (Ware=NoWare) or Ware.IsArchive or Ware.IsINFOgr then Exit; // не пишем в аналоги ИНФО-группу
      iCount:= FAnalogLinks.LinkCount;
      link:= TAnalogLink.Create(pSrcID, Ware, not pCross, pCross);
      FAnalogLinks.AddLinkItem(link);
      Result:= FAnalogLinks.LinkCount>iCount;
    end else try
      CS_wlinks.Enter;
      link:= FAnalogLinks[AnalogID];
      if pCross and not link.IsCross then begin
        link.IsCross:= True;
        if {link.IsOldAnalog and} (link.SrcID<>pSrcID) then link.SrcID:= pSrcID; // источник кросса
      end;
      if not pCross and not link.IsOldAnalog then link.IsOldAnalog:= True;
      link.State:= True;
    finally
      CS_wlinks.Leave;
    end;
  end;
end;
//=============== удалить из кеша линк с аналогом/кроссом (def - аналог Гроссби)
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
//============================ заменить в кеше источник линка с аналогом/кроссом
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
//===================== удалить из кеша непроверенные линки с аналогами/кроссами
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
//========================================== сортировка аналогов по наименованию
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
//========================================== возвращает код и текст акции товара
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
//======================================= имя 1-го рисунка TD с папкой в tdfiles
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
    link:= FileLinks.ListLinks[i];   // линк на файл
    if not link.Flag then Continue;  // признак URL-ссылки на файл

    wfItem:= link.LinkPtr;                              // объект файла
    s:= AnsiUpperCase(ExtractFileExt(wfItem.FileName)); // расширение файла
    if (s<>'.JPG') and (s<>'.BMP') and (s<>'.JPEG')
      and (s<>'.GIF') and (s<>'.PNG') and (s<>'.TIF') then Continue;

    s:= fnMakeAddCharStr(wfItem.supID, 4, '0'); // имя папки в tdfiles по supID
    Result:= s+'/'+wfItem.FileName; // имя папки в tdfiles + имя файла с расширением
    Exit;
  end; // for i:= 0 to FileLinks.ListLinks.Count-1
end;
//================================================== массив кодов типов аналогов
function TWareInfo.GetAnalogTypes(WithoutEmpty: Boolean=False): Tai; // must Free
var i, pType: Integer;
    analog: TWareInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) or IsArchive or not Assigned(AnalogLinks)
    or (AnalogLinks.LinkCount<1) then Exit;
  pType:= 0;
  for i:= 0 to AnalogLinks.LinkCount-1 do begin    // идем по аналогам
    analog:= GetLinkPtr(AnalogLinks.ListLinks[i]);
    if not Assigned(analog) or (analog=NoWare) then Continue;
    with analog do begin
      if IsArchive or (PgrID<1) or IsINFOgr then Continue; // инфо пропускаем
      pType:= analog.TypeID;
    end;
    if WithoutEmpty and (pType<1) then Continue; // если нужны только ненулевые типы
//    if (fnInIntArray(pType, Result)>-1) then Continue; // тип уже был
    prAddItemToIntArray(pType, Result);
  end;
end;
//============================================================== записать строку
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
//============================================================== получить строку
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
    ik16_9 : with Cache do Result:= arWareInfo[GetPgrID(ID)].Name; // наименование подгруппы
    ik16_11: with Cache do Result:= arWareInfo[GetGrpID(ID)].Name; // наименование группы
  end;

  if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
//        ik16_1:  Result:= FSLASHCODE;
    ik16_1: if (FWareState>0) and (FWareState<length(Cache.arWareStateNames)) then
              Result:= Cache.arWareStateNames[FWareState]
            else Result:= Cache.arWareStateNames[0];
    ik16_2:  Result:= fnIfStr(FWareSupName='', FName, FWareSupName);
    ik16_3:  Result:= fnIfStr(FNameBS='', FName, FNameBS);
    ik16_5:  Result:= fnIfStr(FCommentUP='', FComment, FCommentUP);
    ik16_8:  Result:= Cache.GetMeasName(measID);     // наименование ед.изм.
    ik16_10: Result:= FArticleTD;                    // Article TecDoc
    ik16_12: Result:= Cache.GetWareTypeName(TypeID); // наименование типа товара
    ik16_13: begin //------------------ комментарий для Web с учетом типа товара
        kind:= ckEmpty;
        Result:= trim(FComment); // сначала берем, что есть
        //---------- инфо-группа: если FComment пустой или 'OE' - добавляем типы
        if IsINFOgr then begin
          i:= length(Result);
          if (i=2) then begin // проверяем на 'OE'
            s:= AnsiUpperCase(Result);
            if (s='OE') or (s='ОЕ') or (s='OЕ') or (s='ОE') then i:= 0;
          end;
          if (i<1) then
            if (FTypeID>0) then kind:= ckByType // тип задан
            else if Assigned(AnalogLinks) and   // типы по аналогам
              (AnalogLinks.LinkCount>0) then kind:= ckByTypes;
        end //---------- товар: если FComment пустой и тип задан - добавляем тип
        else if (Result='') and (FTypeID>0) then kind:= ckByType;

        if (kind=ckByType) then                               // тип задан
          Result:= Result+fnIfStr(Result='', '', ', ')+Cache.GetWareTypeName(FTypeID)
        else if (kind=ckByTypes) then try // типы по аналогам
          s:= ''; // собираем строку из названий типов
          arTypes:= GetAnalogTypes(True); // массив кодов типов (без нулевого)
          for i:= 0 to High(arTypes) do
            s:= s+fnIfStr(s='', '', ' / ')+Cache.GetWareTypeName(arTypes[i]);
          if s<>'' then Result:= Result+fnIfStr(Result='', '', ', ')+s;
        finally
          SetLength(arTypes, 0);
        end;
      end; // ik16_13
    ik16_15:  Result:= fnIfStr(FMainName='', FName, FMainName); // WAREMAINNAME
    ik16_16: begin //------------------------- название направления по продуктам
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
      ik16_6 : Result:= NameWWW;   // наименование для файла логотипа бренда
      ik16_7 : Result:= Name;      // наименование бренда
      ik16_14: Result:= adressWWW; // адрес ссылки на сайт бренда
    end;
end;
//======================================================== получить вещ.значение
function TWareInfo.GetDoubW(const ik: T8InfoKinds): Single;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if IsWare and Assigned(FWareOpts) then with FWareOpts do case ik of
   ik8_1: Result:= Fdivis;       // кратность
   ik8_2: Result:= Fweight;      // вес
   ik8_3: if Cache.TypeExists(TypeID) then Result:= Cache.arWareInfo[TypeID].CountLimit;
   ik8_4: if Cache.TypeExists(TypeID) then Result:= Cache.arWareInfo[TypeID].WeightLimit;
   ik8_5: Result:= FLitrCount;      // литраж
  end else if IsWare and Assigned(FInfoWareOpts) then case ik of
   ik8_1: Result:= 1.0;          // кратность для ИНФО
  end else if IsType and Assigned(FTypeOpts) then with FTypeOpts do case ik of
   ik8_3: Result:= FCountLimit;  // лимит количества
   ik8_4: Result:= FWeightLimit; // лимит веса
  end;
end;
//======================================================== записать вещ.значение
procedure TWareInfo.SetDoubW(const ik: T8InfoKinds; Value: Single);
begin
  if not Assigned(self) then Exit;
  if IsWare and Assigned(FWareOpts) then with FWareOpts do case ik of
   ik8_1: begin                        // кратность
            if not fnNotZero(Value) then Value:= 1.0;
            if fnNotZero(Fdivis-Value) then Fdivis:= RoundTo(Value, -3);
          end;
   ik8_2: if fnNotZero(Fweight-Value) then Fweight:= RoundTo(Value, -3); // вес
   ik8_5: if fnNotZero(FLitrCount-Value) then FLitrCount:= RoundTo(Value, -3); // литраж
  end else if IsType and Assigned(FTypeOpts) then with FTypeOpts do case ik of
   ik8_3: if fnNotZero(FCountLimit-Value) then FCountLimit:= RoundTo(Value, -3);   // лимит количества
   ik8_4: if fnNotZero(FWeightLimit-Value) then FWeightLimit:= RoundTo(Value, -3); // лимит веса
  end;
end;
//============================================================= получить признак
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
          ikwActN: Result:= Result and wa.IsNews;     // признак акции "Новинки"
          ikwActM: Result:= Result and wa.IsCatchMom; // признак акции "Лови момент"
        end;
      end;
    ikwNloa, ikwNpic:
      if Cache.WareBrands.ItemExists(WareBrandID) then begin
        br:= Cache.WareBrands[WareBrandID];
        case Index of
          ikwNloa: Result:= br.DownLoadExclude; // признак "не включать в прайс"
          ikwNpic: Result:= br.PictShowExclude; // признак "не показывать картинки"
        end;
      end;
  else Result:= (Index in FWareBoolOpts);
  end;
end;
//============================================================= записать признак
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
//================================================================= получить код
function TWareInfo.GetIntW(const ik: T16InfoKinds): Integer;
var i, pType: Integer;
    analog: TWareInfo;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik16_1: if Cache.PgrExists(PgrID) then Result:= Cache.arWareInfo[PgrID].PgrID; // код группы
    ik16_5: Result:= FParCode;     // код подгруппы
    ik16_6: Result:= FOrderNum;    // код бренда товара
    else if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
      ik16_3: Result:= FManagerID;   // код менеджера (EMPLCODE)
      ik16_7: Result:= FmeasID;      // код ед.изм.
      ik16_4: Result:= FSubCode;     // SupID TecDoc (DS_MF_ID !!!)
      ik16_8: if FTypeID>0 then Result:= FTypeID  // код типа товара
             else if IsINFOgr and Assigned(AnalogLinks) then // у ИНФО определяем по аналогам
               with AnalogLinks do if (LinkCount>0) then begin
                 analog:= GetLinkPtr(ListLinks[0]);
                 pType:= analog.TypeID; // берем тип первого
                 for i:= 1 to LinkCount-1 do begin
                   analog:= GetLinkPtr(ListLinks[i]);
                   if analog.IsINFOgr then Continue;
                   if (pType<>analog.TypeID) then Exit; // если нашли другой тип - выходим
                 end;
                 Result:= pType;
               end; // with AnalogLinks ... if (LinkCount>0)
      ik16_9: Result:= FProdDirect; // Направление по продуктам
      ik16_11: Result:= FActionID;  // код акции
      ik16_12: Result:= FTopRating; // рейтинг Топ поиска
//      ik16_12: if (FActionID>0) and Cache.WareActions.ItemExists(FActionID) then
//                 if (TWareAction(Cache.WareActions[FActionID]).EndDate>=Date) then Result:= 1;
      ik16_14: Result:= FWareState;   // статус-состояние
      ik16_15: Result:= FProduct;     // продукт
      ik16_16: Result:= FProductLine; // продуктовая линейка
      else if assigned(FWareOpts) then with FWareOpts do case ik of
        ik16_2: if Assigned(AttrLinks) then with AttrLinks do try // код группы атрибутов
                  if LinkCount>0 then Result:= GetDirItemSubCode(GetLinkPtr(ListLinks[0]));
                except end;
        ik16_10: if Assigned(GBAttLinks) then with GBAttLinks do try // код группы атрибутов Grossbee
                   if LinkCount>0 then Result:= TGBAttribute(GetLinkPtr(ListLinks[0])).Group;
                 except end;
        ik16_13: if Assigned(PrizAttLinks) then with PrizAttLinks do try // код группы атрибутов подарков
                   if LinkCount>0 then Result:= TGBAttribute(GetLinkPtr(ListLinks[0])).Group;
                 except end;
      end;
    end;
  end;
end;
//================================================================= записать код
procedure TWareInfo.SetIntW(const ik: T16InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik16_5:     if (FParCode    <>Value) then FParCode    := Value; // код подгруппы
    ik16_6:     if (FOrderNum   <>Value) then FOrderNum   := Value; // код бренда товара
    else if assigned(FInfoWareOpts) then with FInfoWareOpts do case ik of
      ik16_3:   if (FManagerID  <>Value) then FManagerID  := Value; // код менеджера (EMPLCODE)
      ik16_7:   if (FmeasID     <>Value) then FmeasID     := Value; // код ед.изм.
      ik16_4:   if (FSubCode    <>Value) then FSubCode    := Value; // SupID TecDoc (DS_MF_ID !!!)
      ik16_8:   if (FTypeID     <>Value) then FTypeID     := fnIfInt(Cache.TypeExists(Value), Value, 0); // код типа товара
      ik16_9:   if (FProdDirect <>Value) then FProdDirect := Value; // Направление по продуктам
      ik16_11:  if (FActionID   <>Value) then FActionID   := Value; // код акции
      ik16_12:  if (FTopRating  <>Value) then FTopRating  := Value; // рейтинг Топ поиска
      ik16_14:  if (FWareState  <>Value) then FWareState  := Value; // статус
      ik16_15:  if (FProduct    <>Value) then FProduct    := Value; // продукт
      ik16_16:  if (FProductLine<>Value) then FProductLine:= Value; // продуктовая линейка
//      else if assigned(FWareOpts) then with FWareOpts do case ik of
//      end;
    end;
  end;
end;
//============================================== розничная цена товара по прайсу
function TWareInfo.RetailTypePrice(pTypeInd: Integer; currcode: Integer=cDefCurrency): double;
var curr: Single;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) then Exit;
  with Cache do begin                      // проверка валидности индекса прайса
    if (pTypeInd<Low(PriceTypes)) or (pTypeInd>High(PriceTypes)) then pTypeInd:= Low(PriceTypes);
    if (pTypeInd<Low(FWareOpts.FPrices)) or (pTypeInd>High(FWareOpts.FPrices)) then Exit;
    if not CurrExists(currcode) then currcode:= cDefCurrency; // проверка валюты
    Result:= FWareOpts.FPrices[pTypeInd];                        // розн.цена товара в евро
//    if currcode<>cDefCurrency then Result:= Result*DefCurrRate; // розн.цена товара в грн.
    if (currcode<>cDefCurrency) then begin
      curr:= Currencies.GetCurrRate(currcode);
      if fnNotZero(curr) then // розн.цена товара в валюте(не евро)
        Result:= Result*Currencies.GetCurrRate(cDefCurrency)/curr;
    end;
  end;
//  Result:= RoundToHalfDown(Result);
end;
//========================= записать / проверить розничную цену товара по прайсу
procedure TWareInfo.CheckPrice(price: Single; pTypeInd: Integer);
begin
  if not Assigned(self) or not IsWare or not Assigned(FWareOpts) then Exit;
  with Cache do if (pTypeInd<Low(PriceTypes)) or (pTypeInd>High(PriceTypes)) then
    pTypeInd:= Low(PriceTypes);            // проверка валидности индекса прайса
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
//======================================== получить скидки и индекс прайса фирмы
procedure TWareInfo.GetFirmDiscAndPriceIndex(FirmID: Integer; var ind: Integer;
                    var disc, disNext: double; contID: Integer=0);
var link: TQtyLink;
    Contract: TContract;
    firm: TFirmInfo;
    gr: TWareInfo;
    id1, id2, dm, i: Integer;
  //-------------------------------- скидка по шаблону
  function _GetDiscByModel: double;
  begin
    link:= nil;
    Result:= 0;
    if Assigned(FDiscModLinks) and (FDiscModLinks.Count>0) then // ищем скидку товара
      link:= FDiscModLinks.GetLinkListItemByID(dm, lkLnkByID);
    if not Assigned(link) then begin                          // ищем скидку подгруппы
      gr:= Cache.arWareInfo[id1];
      if Assigned(gr.FDiscModLinks) and (gr.FDiscModLinks.Count>0) then
        link:= gr.FDiscModLinks.GetLinkListItemByID(dm, lkLnkByID);
    end;
    if not Assigned(link) and (id2>0) then begin              // ищем скидку группы
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
  if IsWare then begin         // скидка клиента на товар
    id1:= PgrID;
    id2:= GrpID;
  end else if IsPgr then begin // скидка клиента на подгруппу
    id1:= ID;
    id2:= PgrID;
  end else if IsGrp then begin // скидка клиента на группу
    id1:= ID;
    id2:= 0;
  end else Exit;

  i:= fnInIntArray(Contract.ContPriceType, Cache.PriceTypes);
  if (i>-1) then ind:= i;      // индекс прайса
  if (ProdDirect<1) then Exit; // не задано направление товара

  dm:= firm.GetCurrentDiscModel(ProdDirect, i).ID;  // код текущего шаблона скидок
  if (dm<1) then Exit; // не найден текущий шаблон
  disc:= _GetDiscByModel;                           // скидка по текущему шаблону

  dm:= Cache.DiscountModels.GetNextDirectModel(dm); // код следующего шаблона
  if (dm<1) then disNext:= disc // не найден следующий шаблон - берем по текущему
  else disNext:= _GetDiscByModel;                   // скидка по следующему шаблону
end;
//============================================== розничная цена товара для фирмы
function TWareInfo.RetailPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double;
var i: Integer;
    dis, disNext: double;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  GetFirmDiscAndPriceIndex(FirmID, i, dis, disNext, contID); // индекс прайса
  Result:= RetailTypePrice(i, currcode);    // розн.цена товара
  Result:= RoundTo(Result, -2);
//  Result:= RoundToHalfDown(Result);
end;
//============================================== продажная цена товара для фирмы
function TWareInfo.SellingPrice(FirmID: Integer=IsWe; currcode: Integer=cDefCurrency; contID: Integer=0): double;
var i: Integer;
    dis, disNext: double;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  GetFirmDiscAndPriceIndex(FirmID, i, dis, disNext, contID); // индекс прайса, скидка фирмы
  Result:= RetailTypePrice(i, currcode);    // розн.цена товара

  if not fnNotZero(Result) then Exit; // 0-я цена

  Result:= RoundTo(Result, -2);
//  Result:= RoundToHalfDown(Result);
  if IsSale or IsCutPrice or not fnNotZero(dis) then Exit; // распродажа/уценка/нет скидки

  Result:= Result*(1.0-dis/100.0); // продажная цена товара
  Result:= RoundTo(Result, -2);
//  Result:= RoundToHalfDown(Result);
//  if currcode=1 then Result:= RoundTo(Result/6, -2)*6; // пересчет грн под НДС
end;
{//=========================== цена товара с наценкой (% к продажной) для клиента
function TWareInfo.MarginPrice(FirmID: Integer=IsWe; UserID: Integer=0;
         currcode: Integer=cDefCurrency; contID: Integer=0): double;
var marg: double;
    Client: TClientInfo;
begin
  Result:= 0;
  if not Assigned(self) or (currcode<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  Result:= SellingPrice(FirmID, currcode, contID);
  Result:= RoundToHalfDown(Result);

  if not fnNotZero(Result) then Exit; // 0-я цена
  if (FirmID=IsWe) or not Cache.ClientExist(UserID) then Exit;

  Client:= Cache.arClientInfo[UserID];
  if not Client.CheckContract(contID) then Exit; // недоступный контракт

  marg:= Client.GetContCacheGrpMargin(contID, self.PgrID); // ищем наценку на подгруппу
  if not fnNotZero(marg) then  // если нет - ищем наценку на группу
    marg:= Client.GetContCacheGrpMargin(contID, self.GrpID);
  if not fnNotZero(marg) then Exit;  // наценки нет

  Result:= Result*(1.0+marg/100.0); // цена с наценкой (% к продажной)
  Result:= RoundToHalfDown(Result);
end;
//=========================== цена товара с наценкой (% к продажной) для клиента
function TWareInfo.MarginPrice(ffp: TForFirmParams): double;
var marg: double;
    Client: TClientInfo;
begin
  Result:= 0;
  if not Assigned(self) or (ffp.currID<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  Result:= SellingPrice(ffp.ForFirmID, ffp.currID, ffp.contID);
  Result:= RoundToHalfDown(Result);

  if not fnNotZero(Result) then Exit; // 0-я цена
  if not ffp.ForClient or not Cache.ClientExist(ffp.UserID) then Exit;

  Client:= Cache.arClientInfo[ffp.UserID];
  if not Client.CheckContract(ffp.contID) then Exit; // недоступный контракт

  marg:= Client.GetContCacheGrpMargin(ffp.contID, self.PgrID); // ищем наценку на подгруппу
  if not fnNotZero(marg) then  // если нет - ищем наценку на группу
    marg:= Client.GetContCacheGrpMargin(ffp.contID, self.GrpID);
  if not fnNotZero(marg) then Exit;  // наценки нет

  Result:= Result*(1.0+marg/100.0); // цена с наценкой (% к продажной)
  Result:= RoundToHalfDown(Result);
end;  }
//========================================== все цены товара по фирме, контракту
function TWareInfo.CalcFirmPrices(FirmID: Integer=IsWe; currID: Integer=cDefCurrency; // must Free !!!
                                 contID: Integer=0): TDoubleDynArray;
// 0- Розница, 1- со скидкой, 2- со след.скидкой
var i, len: Integer;
    dis, disNext: double;
begin
  len:= Length(arPriceColNames);
  SetLength(Result, len);
  for i:= 0 to High(Result) do Result[i]:= 0;
  if not Assigned(self) or (currID<1) or not IsWare or not Assigned(FWareOpts) then Exit;
  GetFirmDiscAndPriceIndex(FirmID, i, dis, disNext, contID); // индекс прайса, скидка фирмы
  Result[0]:= RoundTo(RetailTypePrice(i, currID), -2);   // розн.цена товара
//  Result[0]:= RoundToHalfDown(RetailTypePrice(i, currID));   // розн.цена товара

  if IsSale or IsCutPrice then begin // распродажа/уценка
    Result[1]:= Result[0];
    Result[2]:= Result[0];
    Exit;
  end;

  if not fnNotZero(dis) then Result[1]:= Result[0]
  else Result[1]:= RoundTo(Result[0]*(1.0-dis/100.0), -2); // продажная цена товара
//  else Result[1]:= RoundToHalfDown(Result[0]*(1.0-dis/100.0)); // продажная цена товара
//  if currcode=cUAHCurrency then Result[1]:= RoundTo(Result[1]/6, -2)*6; // пересчет грн под НДС

  if not fnNotZero(disNext) then Result[2]:= Result[0]
  else if not fnNotZero(dis-disNext) then Result[2]:= Result[1]
  else Result[2]:= RoundTo(Result[0]*(1.0-disNext/100.0), -2); // цена со скидкой след.уровня
//  else Result[2]:= RoundToHalfDown(Result[0]*(1.0-disNext/100.0)); // цена со скидкой след.уровня
end;
//========================================== все цены товара по фирме, контракту
function TWareInfo.CalcFirmPrices(ffp: TForFirmParams): TDoubleDynArray; // must Free !!!
// 0- Розница, 1- со скидкой, 2- со след.скидкой
var i, len: Integer;
    dis, disNext: double;
begin
  len:= Length(arPriceColNames);
  SetLength(Result, len);
  for i:= 0 to High(Result) do Result[i]:= 0;
  if not Assigned(self) or (ffp.currID<1) or not IsWare or not Assigned(FWareOpts) then Exit;

  GetFirmDiscAndPriceIndex(ffp.ForFirmID, i, dis, disNext, ffp.contID); // индекс прайса, скидка фирмы
  Result[0]:= RoundTo(RetailTypePrice(i, ffp.currID), -2);   // розн.цена товара
//  Result[0]:= RoundToHalfDown(RetailTypePrice(i, ffp.currID));   // розн.цена товара

  if IsSale or IsCutPrice then begin // распродажа/уценка
    Result[1]:= Result[0];
    Result[2]:= Result[0];
    Exit;
  end;

  if not fnNotZero(dis) then Result[1]:= Result[0]
  else Result[1]:= RoundTo(Result[0]*(1.0-dis/100.0), -2); // продажная цена товара
//  else Result[1]:= RoundToHalfDown(Result[0]*(1.0-dis/100.0)); // продажная цена товара
//  if currcode=1 then Result[1]:= RoundTo(Result[1]/6, -2)*6; // пересчет грн под НДС

  if not fnNotZero(disNext) then Result[2]:= Result[0]
  else if not fnNotZero(dis-disNext) then Result[2]:= Result[1]
  else Result[2]:= RoundTo(Result[0]*(1.0-disNext/100.0), -2); // цена со скидкой след.уровня
//  else Result[2]:= RoundToHalfDown(Result[0]*(1.0-disNext/100.0)); // цена со скидкой след.уровня
end;
//=============================== список значений атрибутов товара для просмотра
function TWareInfo.GetWareAttrValuesView: TStringList; // must Free Result
// возвращает список: имя атрибута = значение атрибута
const nmProc='GetWareAttrValuesView';
var i: integer;
    s1, s2: string;
    attlink: TTwoLink;
begin
  Result:= TStringList.Create;
  Result.Sorted:= False;
  attlink:= nil;
  if not Assigned(self) or not IsWare or not Assigned(AttrLinks) then Exit;
  with AttrLinks do try // список атрибутов
    if LinkCount<1 then Exit;
    Result.Capacity:= Result.Capacity+LinkCount;
    for i:= 0 to LinkCount-1 do begin
      s1:= GetLinkName(ListLinks[i]);
      if (s1='') then Continue else attlink:= ListLinks[i];
      if Assigned(attlink.LinkPtrTwo) then begin
        s2:= GetDirItemName(attlink.LinkPtrTwo); // значение атрибута
        Result.Add(s1+'='+s2);
      end;
    end; // for
  except end; // with AttrLinks
end;
//=================== список значений атрибутов товара по кодам в нужном порядке
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
    if fl and AttrLinks.LinkExists(attcode) then try // если есть линк на такой атрибут
      attlink:= AttrLinks[attcode];
      if Assigned(attlink.LinkPtrTwo) then
        s2:= GetDirItemName(attlink.LinkPtrTwo); // значение атрибута
    except end;
    Result.Add(s2);
  end;
end;
//====================== список значений атрибутов Grossbee товара для просмотра
function TWareInfo.GetWareGBAttValuesView: TStringList; // must Free Result
// возвращает список: имя атрибута = значение атрибута
const nmProc='GetWareGBAttValuesView';
var i: integer;
    s1, s2: string;
    attlink: TTwoLink;
begin
  Result:= TStringList.Create;
  Result.Sorted:= False;
  attlink:= nil;
  if not Assigned(self) or not IsWare or not Assigned(GBAttLinks) then Exit;
  with GBAttLinks do try // список атрибутов
    if LinkCount<1 then Exit;
    Result.Capacity:= Result.Capacity+LinkCount;
    for i:= 0 to LinkCount-1 do begin
      s1:= GetLinkName(ListLinks[i]);
      if (s1='') then Continue else attlink:= ListLinks[i];
      if Assigned(attlink.LinkPtrTwo) then begin
        s2:= GetDirItemName(attlink.LinkPtrTwo); // значение атрибута
        Result.Add(s1+'='+s2);
      end;
    end; // for
  except end; // with AttrLinks
end;
//========== список значений атрибутов Grossbee товара по кодам в нужном порядке
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
    if fl and GBAttLinks.LinkExists(attcode) then try // если есть линк на такой атрибут
      attlink:= GBAttLinks[attcode];
      if Assigned(attlink.LinkPtrTwo) then
        s2:= GetDirItemName(attlink.LinkPtrTwo); // значение атрибута
    except end;
    Result.Add(s2);
  end;
end;
//================================ Проверка принадлежности к системе Авто / Мото
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
//=== список ориг.номеров товара, сортированный по производителям и наименованию
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
//======================== Поиск оригинального номера в списке ор.номеров товара
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
//======== сортировка TList моделей - произв. + м.р. + порядк.№ + наименование
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
//==== видим.модели системы по товару - произв. + м.р. + порядк.№ + наименование
function TWareInfo.GetSysModels(pSys: Integer; pMfau: Integer=0; flPL: Boolean=False): TList; // Object - TModelAuto, must Free
const nmProc = 'GetSysModels';
// pMfau=0 - все модели товара по системе, pMfau>0 - только заданного производителя
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

//---------------------------------------------------------------------- из кеша
  if Cache.WareLinksUnLocked and not flPL then begin
    if not ModelsSorting and (ModelLinks.Count>1) then begin
      ModelLinks.Sort(WareModelsSortCompare); // сортируем линки при первом вызове
      ModelsSorting:= True;        // флаг - уже отсортирован
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
  try try  //--------------------------------------------------------------- из базы
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
      i:= ORD_IBS.FieldByName('DMOSCODE').AsInteger;  // Код модели
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
    if (Result.Count>1) then Result.Sort(WareModelsSortCompare); // сортируем
  end;
end;
//============================== признак наличия видим.моделей системы по товару
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
//==================== проверка признака наличия видим.моделей системы по товару
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
//=================== сортировка TLinks товаров в продуктовой линейке по литражу
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
//=========================================== заполнить параметры товара из базы
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

    if not fromGW then begin // вызов из TestWares
      IsArchive:= False;
      PgrID:= pPgrID;

if flShowWareByState then begin
      IsINFOgr:= flInfo;
end else begin
      IsINFOgr:= Cache.arWareInfo[pPgrID].IsINFOgr;
end; // flShowWareByState

      IsSale:= not IsINFOgr and GetBoolGB(ibs, 'sale');
      flWareOpts:= not IsINFOgr; // WareOpts заполняем только у неИНФО товаров

    end else begin // вызов из GetWare
      IsArchive:= GetBoolGB(ibs, 'warearchive');
      flWareOpts:= not IsArchive and (IsPrize or ((pPgrID>0) and Cache.PgrExists(pPgrID)));
      if flWareOpts then begin // WareOpts заполняем только у неархивных товаров
        PgrID:= pPgrID;
        IsSale:= GetBoolGB(ibs, 'sale');   // ???
//        IsINFOgr:= (ibs.FieldByName('wState').AsInteger=cInfoWareState);  // добавить ???
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
    ManagerID  := ibs.FieldByName('REmplCode').AsInteger; // код менеджера
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
    end else begin // только направления AUTO, MOTO, MOTUL... и призы
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
    FormatFloat('# ##0.000', weight), fLogDebug, false); // пишем в log  }

    if not IsArchive and not IsINFOgr and (ProductLine>0) then begin
      pl:= Cache.ProductLines.GetProductLine(ProductLine);
      if Assigned(pl) then begin // проверяем линк на товар в продуктовой линейке
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

    if (spk=spOnlyPrice) then begin // подстраховка, если только цены
      if not assigned(FInfoWareOpts) then
        FInfoWareOpts:= TInfoWareOpts.Create(CS_wlinks);
      if not fromGW then flWareOpts:= not IsINFOgr  // вызов из TestWares
      else  // вызов из GetWare
        flWareOpts:= not IsArchive and (IsPrize or ((pPgrID>0) and Cache.PgrExists(pPgrID)));
      if not flWareOpts then Exit;
      if not assigned(FWareOpts) then FWareOpts:= TWareOpts.Create(CS_wlinks);
    end; // if (spk=spOnlyPrice)

    for k:= 0 to High(Cache.PriceTypes) do begin // цены по прайсам
      if k=0 then n:= '' else n:= IntToStr(k);
      if (ibs.FieldIndex['priceEUR'+n]>-1) then    // подстраховка
        CheckPrice(ibs.FieldByName('priceEUR'+n).AsFloat, k);
    end;
  end; //  if (spk in [spAll, spOnlyPrice])
end;
//=============================== список значений критериев товара для просмотра
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
    //----------------------------------------------------- значения критериев
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
      Result.Add(CriName+fnIfStr(s='', '', ': '+s)); // строка по 1-му критерию
    end;
    ORD_IBS.Close;
    //------------------------------------------- тексты к связке товар - нода
    flSysOnly:= CheckTypeSys(SysID); // признак вывода текстов только по заданной системе
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
      s:= 'Узел - '+ORD_IBS.FieldByName('TRNANAME').AsString+':';
      s:= brcWebColorBlueBegin+s+brcWebColorEnd; // синий шрифт
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
        Result.Add(cWebSpace+cWebSpace+CriName+fnIfStr(s='', '', ': '+s)); // отступ + строка по 1-му типу текста
      end; // while ... and (iNode=
    end;
    ORD_IBS.Close;

    //------------------------------------------ номера EAN и параметры упаковки
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
      if (s<>'') then Result.Add('Номер EAN: '+s);
      i:= ORD_IBS.FieldByName('PackUnit').AsInteger;
      if (i>0) then Result.Add('Упаковочная единица: '+IntToStr(i));
      i:= ORD_IBS.FieldByName('PackCount').AsInteger;
      if (i>1) then Result.Add('Количество в упаковке: '+IntToStr(i));
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
//=================================== Установить / снять связь с артиклем TecDoc
function TWareInfo.CheckArticleLink(pArticle: String; pSupID: Integer;
         var ResCode: Integer; userID: Integer=0; flDelInfo: Boolean=True): String;
const nmProc = 'CheckArticleLink';
// вид операции - ResCode - на входе (resAdded, resDeleted, resWrong, resNotWrong)
// (flDelInfo=True) + (ResCode in [resDeleted, resWrong]) - удалить всю инф-цию, посаженную из TecDoc
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось,
// resAdded - связка добавлена, resDeleted - связка удалена,
// resWrong - отмечена ошибочная связка в базе и удалена из кеша
// resNotWrong - снята отметка ошибочной связки в базе и связка добавлена в кеш
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
//-------------------------------------------------------------------- проверяем
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');
    if (pArticle='') or (pSupID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' артикула');

    sArtLink:= MessText(mtkWareArticleLink);
    if (OpCode in [resAdded, resNotWrong]) then begin
      if not IsInfoGr and
        (fnInIntArray(pSupID, TBrandItem(Cache.WareBrands[WareBrandID]).TDMFcodes)<0) then
        raise EBOBError.Create(MessText(mtkNotValidParam)+' бренда');
      if (pArticle=ArticleTD) and (pSupID=ArtSupTD) then begin
        ResCode:= resDoNothing;
        raise EBOBError.Create('такая '+sArtLink+' уже есть');
      end;
      if (ArticleTD<>'') and (ArtSupTD>0) then
        raise EBOBError.Create('товар связан с другим артикулом');
      if (userID<1) then raise EBOBError.Create(MessText(mtkNotParams));

    end else if (pArticle<>ArticleTD) or (pSupID<>ArtSupTD) then begin
      ResCode:= resDoNothing;
      raise EBOBError.Create('не найдена такая '+sArtLink);
    end;
//--------------------------------------------------- отрабатываем запись в базу
    IBDtdt:= cntsTDT.GetFreeCnt;
    try
      IBDord:= cntsOrd.GetFreeCnt;

      IBStdt:= fnCreateNewIBSQL(IBDtdt, 'IBS_'+nmProc, -1, tpWrite, True);
      try
        IBSord:= fnCreateNewIBSQL(IBDord, 'IBS_'+nmProc, -1, tpWrite, True);

        if (OpCode in [resWrong, resDeleted]) then begin
          if flDelInfo then           // удалить инфо товара по источнику-TecDoc
            IBSord.SQL.Text:= 'select * from DelWareInfoByTDsrc('+IntToStr(ID)+')'
          else // изменить источник инфо-товара с источника-TecDoc на TecDoc-старый
            IBSord.SQL.Text:= 'select * from ChangeWareInfoSrcFromTDtoTDold('+IntToStr(ID)+')';
      // возвращает коды для отработки кеша, kind - вид возвращаемых кодов:
      // 1 - rCode - код аналога заданного товара;
      // 2 - rCode - код товара, у которого заданный товар - аналог;
      // 3 - rCode - код оригинального номера товара;
      // 4 - rCode - код файла товара;
      // 5 - rCode - код узла, rCode1 - код модели, (flDelInfo) rCode2 - признак наличия фильтров;
      // (flDelInfo) 6 - rCode - признак наличия узлов, rCode1 - код двигателя, rCode2 - признак наличия товаров
          IBSord.ExecQuery;
          while not IBSord.Eof do begin  // запоминаем возвращаемые коды
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

        if (OpCode in [resAdded, resNotWrong]) then begin //-- проверить наличие артикула в TDT
          IBStdt.SQL.Text:= 'select art_id from articles left join data_suppliers'+
            ' on ds_id=art_sup_id where art_nr=:art and ds_mf_id='+IntToStr(pSupID);
          IBStdt.ParamByName('art').AsString:= pArticle;
          IBStdt.ExecQuery;
          if (IBStdt.Bof and IBStdt.Eof) or (IBStdt.Fields[0].AsInteger<1) then
            raise EBOBError.Create('Не найден артикул Tecdoc '+pArticle);
          IBStdt.Close;
        end; // if (OpCode in [resAdded, resNotWrong])

        IBSord.SQL.Text:= 'execute procedure CheckWareArticleTDLink('+IntToStr(OpCode)+', '+
          IntToStr(ID)+', '+IntToStr(pSupID)+', :art, '+IntToStr(userID)+')';
        IBSord.ParamByName('art').AsString:= pArticle;
        IBSord.ExecQuery;
        IBSord.Transaction.Commit;
        IBSord.Close;
        try             // отрабатываем признак наличия товаров у артикула в TDT
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
//------------------------------------------------------------- отрабатываем кеш
    try
      CS_wlinks.Enter;
      if OpCode in [resAdded, resNotWrong] then begin // добавляем / восстанавливаем
        ArticleTD:= pArticle;
        ArtSupTD:= pSupID;  // SupID TecDoc (DS_MF_ID !!!)
      end else begin // удаляем / отмечаем, как ошибочную
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
//-------------------------- удалить инфо товара по источнику-TecDoc (если надо)
          with ari[i] do case kind of
          1: DelAnalogLink(rCode, True);    //------------------- аналоги товара
          2: if Cache.WareExist(rCode) then //----------------- кроссы с товаром
              Cache.GetWare(rCode).DelAnalogLink(ID, True);
          3: begin //------------------------------------------------- ОН товара
              ONumLinks.DelLinkListItemByID(rCode, lkLnkByID, CS_wlinks); // удал.связку у товара
              with Cache.FDCA do if OrigNumExist(rCode) then // удал.связку у ОН
                GetOriginalNum(rCode).Links.DeleteLinkItem(ID);
            end;
          4: FileLinks.DeleteLinkItem(rCode); //------------------- файлы товара
          5: begin //------------------------------------------- 3 связки товара
              Model:= Cache.FDCA.Models[rCode1];
              if Assigned(Model) and Model.NodeLinks.LinkExists(rCode) then begin
                link2:= Model.NodeLinks[rCode];
                link2.DoubleLinks.DelLinkListItemByID(ID, lkLnkNone, Model.CS_mlinks);
                                       // уточняем наличие фильтров у 2-й связки
                if link2.NodeHasFilters and (rCode2<1) then link2.NodeHasFilters:= False;
                if link2.NodeHasWares and (link2.DoubleLinks.LinkCount<1) then link2.NodeHasWares:= False;
              end;
            end;
          6: begin //------------------------------- связки товара с двигателями
              Eng:= Cache.FDCA.Engines[rCode1];
              if Assigned(Eng) then begin // уточняем наличие узлов и товаров у двигателя
                if Eng.EngHasNodes and (rCode<1) then Eng.EngHasNodes:= False;
                if Eng.EngHasWares and (rCode2<1) then Eng.EngHasNodes:= False;
              end;
            end;
          // критерии товара, инфо-тексты товар-нода удаляются без возврата кодов
          end; // case

        end else begin
//--------------------------------------------------- изменить источник на TDold
          with ari[i] do case kind of
          1: SetAnalogLinkSrc(rCode, soTDold); //---------------- аналоги товара
          2: if Cache.WareExist(rCode) then    //-------------- кроссы с товаром
               Cache.GetWare(rCode).SetAnalogLinkSrc(ID, soTDold);
          3: begin //------------------------------------------------- ОН товара
               if ONumLinks.LinkListItemExists(rCode, lkLnkByID) then begin
                 link:= ONumLinks.GetLinkListItemByID(rCode, lkLnkByID);
                 link.SrcID:= soTDold; // связка у товара
               end;
               with Cache.FDCA do if OrigNumExist(rCode) then // связка у ОН
                 with GetOriginalNum(rCode) do if Links.LinkExists(ID) then begin
                   link:= Links[ID];
                   link.SrcID:= soTDold;
                 end;
            end;
          4: if FileLinks.LinkExists(rCode) then begin //---------- файлы товара
               link:= FileLinks[rCode];
               link.SrcID:= soTDold;
            end;
          5: begin //------------------------------------------- 3 связки товара
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
        5: begin //------------------------------------ связки товара с моделями
            Model:= Cache.FDCA.Models[rCode1];
            if Assigned(Model) then begin
              flEx:= False; // проверяем, остались ли линки на товар у модели
              with Model.NodeLinks do for k:= 0 to LinkCount-1 do begin
                with TSecondLink(ListLinks[k]) do
                  flEx:= Assigned(DoubleLinks) and DoubleLinks.LinkListItemExists(ID, lkLnkNone);
                if flEx then break;
              end;
              if not flEx then // если не осталось - удаляем линк товара с моделью
                ModelLinks.DelLinkListItemByID(Model.ID, lkDirNone, CS_wlinks);
            end;
          end; // 5
        end; // case
        inc(i);
      end; // while
    end; // if (j>0)

    case OpCode of
      resAdded:    Result:= sArtLink+' добавлена';
      resDeleted:  Result:= sArtLink+' удалена';
      resWrong:    Result:= sArtLink+' отмечена, как неверная';
      resNotWrong: Result:= sArtLink+' восстановлена';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
  SetLength(ari, 0);
end;
//====================================== набор параметров файлов рисунков товара
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
      link:= ListLinks[i];                  // линк на файл
      wfItem:= link.LinkPtr;                // объект файла
      Result[i].SupID   := wfItem.supID;    // код SupID (для поиска папки)
      Result[i].FileName:= wfItem.FileName; // имя файла с расширением
      Result[i].HeadName:= wfItem.HeadName; // заголовок файла
      Result[i].LinkURL := link.Flag;       // признак URL-ссылки на файл
    end;
  end;
end;
//========================================== получить массив кодов сопут.товаров
function TWareInfo.GetSatellites: Tai;  // must Free
var i, j: Integer;
    ware: TWareInfo;
begin
  SetLength(Result, 0);
  if not Assigned(self) or not Assigned(SatelLinks) then Exit;

  with SatelLinks do for i:= 0 to ListLinks.Count-1 do begin
    j:= GetLinkID(ListLinks[i]);
    if not Cache.WareExist(j) then Continue;
    ware:= GetLinkPtr(ListLinks[i]); // проверяем сопут.товар
    if not Assigned(ware) then Continue;
    try
      if ware.IsINFOgr or ware.IsArchive then Continue;     // исключаем инфо-группу
    except
      Continue;
    end;
    prAddItemToIntArray(ware.ID, Result);
  end;
end;
//================================================ признак наличия сопут.товаров
function TWareInfo.SatelliteExists: Boolean;
var i: Integer;
    ware: TWareInfo;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(SatelLinks) then Exit;

  with SatelLinks do for i:= 0 to ListLinks.Count-1 do begin
    ware:= TLink(ListLinks[i]).LinkPtr;               // проверяем сопут.товар
    if ware.IsINFOgr or ware.IsArchive then Continue; // исключаем инфо-группу
    Result:= True; // нашли 1-й
    break;
  end;
end;
{//===================================================== признак наличия остатков
function TWareInfo.RestExists(pContID: Integer=0): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(RestLinks) or (RestLinks.LinkCount<1) then Exit;
end; }

//******************************************************************************
//                               TWareFile
//******************************************************************************
//================================================== получить значение заголовка
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
  flMailSendSys:= False; // по умолчанию
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
  AccEmpCommLength:= 255;      // длина поля счета Комментарий сотрудника
  AccCliCommLength:= 255;      // длина поля счета Комментарий клиента
  AccWebCommLength:= 255;      // длина поля счета Комментарий Web
  CScache := TCriticalSection.Create; // для изменений
  CS_Empls:= TCriticalSection.Create; // для изменения параметров сотрудников
  CS_wares:= TCriticalSection.Create; // для изменения параметров товаров

  SysTypes:= TDirItems.Create;
  FillSysTypes; // контролируемые системы учета
  if not Assigned(SysTypes) or (SysTypes.Count<1) then
    raise Exception.Create('не могу определить системы учета');

  SetLength(arFirmTypesNames, 1);
  arFirmTypesNames[0]:= 'Неизв.';

  SetLength(arFirmClassNames, 1);
  arFirmClassNames[0]:= 'Неизв.';

  SetLength(arWareStateNames, 1);
  arWareStateNames[0]:= 'Неизв.';

  SetLength(arDprtInfo, 1);
  arDprtInfo[0]:= TDprtInfo.Create(0, 0, 0, 'Неизв.подразделение');

  arClientInfo:= TClients.Create;

  Contracts:= TContracts.Create;       // справочник контрактов

  SetLength(arFirmInfo, 1);
  arFirmInfo[0]:= TFirmInfo.Create(0, 'Неизв.фирма');

  SetLength(arEmplInfo, 1);
  arEmplInfo[0]:= TEmplInfoItem.Create(0, 0, 1, '');
  arEmplInfo[0].Surname:= 'Не определен';

  setLength(arFictiveEmpl, 0);
  setLength(arRegionROPFacc, 0);  // коды ЦФУ РОП-а по номеру региона

  FDCA:= TDataCacheAdditionASON.Create; // Galeta

  SetLength(arWareInfo, 1);
  arWareInfo[0]:= TWareInfo.Create(0, 0, 'Неизв.группа');  // подгруппа для старых товаров
  with arWareInfo[0] do begin
    IsPgr:= True;
//    IsAUTOWare:= True; // признаки AUTO / MOTO подгруппы
//    IsMOTOWare:= True;
  end; // with arWareInfo[0]

  NoWare:= TWareInfo.Create(-1, 0, 'Неизв.товар'); // фиктивный товар
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

  BonusCrncCode:= 22;     // код валюты бонусов
  TopActCode:= 0;

  BrandTDList   := nil;                    // список брендов TecDoc
  FWareFiles    := TDirItems.Create;       // справочник файлов рисунков/документов
  WareBrands    := TDirItems.Create;       // справочник брендов
  FImportTypes  := TDirItems.Create;       // справочник видов импорта
  FParConstants := TDirItems.Create;       // справочник констант
  FEmplRoles    := TDirItems.Create;       // справочник ролей
  FMeasNames    := TDirItems.Create;       // справочник ед.изм.
  InfoNews      := TDirItems.Create;       // инфо-блок
  ShipMethods   := TDirItems.Create;       // справочник методов отгрузки
  ShipTimes     := TDirItems.Create;       // справочник времен отгрузки
  FiscalCenters := TDirItems.Create;       // справочник FISCALACCOUNTINGCENTER
  WareActions   := TDirItems.Create;       // справочник акций по товарам

  Currencies    := TCurrencies.Create;     // справочник валют
  Notifications := TNotifications.Create;  // Справочник уведомлений
  AttrGroups    := TAttrGroupItems.Create; // справочник групп атрибутов
  Attributes    := TAttributeItems.Create; // справочник атрибутов
  GBAttributes  := TGBAttributes.Create;   // справочник атрибутов Grossbee
  GBPrizeAttrs  := TGBAttributes.Create;   // справочник атрибутов подарков
  ProductLines  := TProductLines.Create;   // перечень продуктовых линеек (Motul)
  DiscountModels:= TDiscModels.Create;     // справочник шаблонов скидок
  MotulTreeNodes:= TMotulTreeNodes.Create; // дерево узлов Motul

  DeliveriesList  := fnCreateStringList(true, dupIgnore); // список доставок
  BrandLaximoList := fnCreateStringList(true, dupIgnore); // список брендов Laximo
  SMSmodelsList   := TStringList.Create;   // список SMS-шаблонов
  MobilePhoneSigns:= TStringList.Create;   // список кодов моб.операторов
  WareProductList := TStringList.Create;   // список продуктов

//  NoTDPictBrandCodes:= TIntegerList.Create; // коды брендов без показа рисунков TD
  ShowZeroRestsFirms:= TIntegerList.Create; // коды к/а для показа товаров б/остатков в поисках (Ирбис)

//  FirmLabels    := TDirItems.Create;       // справочник наклеек
//  MarginGroups  := TMarginGroups.Create;   // группы/подгруппы наценок

  WareCacheUnLocked:= False;
  WareLinksUnLocked:= False;
  WebAutoLinks:= False;
  WareCacheTested:= False;
end;
//==================================================
destructor TDataCache.Destroy;
const nmProc = 'Cache_Destroy'; // имя процедуры/функции
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
  setLength(arRegionROPFacc, 0);  // коды ЦФУ РОП-а по номеру региона
  prFree(NoWare);
  FDCA.Free;
  FDCA:= nil;

  prFree(AttrGroups);
  prFree(Attributes);
  prFree(GBAttributes); // справочник атрибутов Grossbee
  if flTest then prMessageLOGS(nmProc+'_Attributes: - '+
                            GetLogTimeStr(LocalStart), fLogDebug, false);
  prFree(WareBrands);
  prFree(FImportTypes);
  prFree(FParConstants);      // справочник констант
  prFree(FEmplRoles);
  prFree(FMeasNames);
  prFree(FWareFiles);
  prFree(BrandTDList);
  prFree(InfoNews);
  prFree(Notifications);
  prFree(SysTypes);
  prFree(ShipMethods);
  prFree(ShipTimes);
  prFree(FiscalCenters);   // справочник FISCALACCOUNTINGCENTER
  prFree(Currencies);      // справочник валют
  prFree(ShipTimes);
//  prFree(FirmLabels);
  prFree(WareActions);        // справочник акций по товарам
//  prFree(MarginGroups);
  prFree(DeliveriesList);
  for i:= 0 to BrandLaximoList.Count-1 do TObject(BrandLaximoList.Objects[i]).Free;
  prFree(BrandLaximoList); // список брендов Laximo
//  prFree(NoTDPictBrandCodes);
  prFree(ShowZeroRestsFirms);
  prFree(DiscountModels);
  prFree(SMSmodelsList);
  prFree(MobilePhoneSigns);  // список кодов моб.операторов
  prFree(ProductLines);
  prFree(WareProductList);
  prFree(MotulTreeNodes);

  prFree(CScache);
  prFree(CS_Empls);
  prFree(CS_wares);
  inherited;
end;
//============================================================= получить признак
function TDataCache.GetBoolDC(ik: T16InfoKinds): boolean;
begin
  if not Assigned(self) then Result:= False else Result:= (ik in FCacheBoolOpts);
end;
//============================================================= записать признак
procedure TDataCache.SetBoolDC(ik: T16InfoKinds; Value: boolean);
begin
  if not Assigned(self) then Exit;
  if Value then FCacheBoolOpts:= FCacheBoolOpts+[ik]
  else FCacheBoolOpts:= FCacheBoolOpts-[ik];
end;
//================================================= проверяем длину массива кэша
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
  if fl then try // если надо менять длину
    CScache.Enter;
    if (i>len) then case kind of // если обрезаем - надо очистить элементы
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
    if (i<len) then case kind of // если добавляем - надо инициировать элементы
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
//================================ проверяем существование элемента массива кэша
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
  if flnew then flnew:= Result; // возвращаем признак создания нового элемента
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
//=================== проверка существования группы/подгруппы для скидок/наценок
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
//=================================================================== код группы
function TDataCache.GetGrpID(ID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or (ID<1) or not Assigned(arWareInfo[ID]) then Exit;
  with arWareInfo[ID] do if IsGrp then Result:= ID
    else if IsPgr then Result:= PgrID else if IsWare then Result:= GrpID;
end;
//================================================================ код подгруппы
function TDataCache.GetPgrID(ID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or (ID<1) or not Assigned(arWareInfo[ID]) then Exit;
  with arWareInfo[ID] do if IsGrp then Exit
    else if IsPgr then Result:= ID else if IsWare then Result:= PgrID;
end;
//===================== коэффициент для расчета бонусов от суммы в валюте currID
function TDataCache.GetPriceBonusCoeff(currID: Integer): Single;
// для валюты "unit" возвращает 0
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
//========================================================= наименование ед.изм.
function TDataCache.GetMeasName(pID: Integer): string;
begin
  if not Assigned(self) or not MeasExists(pID) then Result:= ''
  else Result:= FMeasNames.GetItemName(pID);
end;
//========================================================== наименование валюты
function TDataCache.GetCurrName(pID: Integer; ForClient: Boolean): string;
begin
  if not Assigned(self) or not CurrExists(pID) then Result:= ''
  else if ForClient then Result:= Currencies[pID].CliName
  else Result:= Currencies[pID].Name;
end;
//============================================================= наименование ЦФУ
function TDataCache.GetFaccName(pID: Integer): string;
begin
  if not Assigned(self) or not FaccExists(pID) then Result:= ''
  else Result:= FiscalCenters.GetItemName(pID);
end;
//====================================================== наименование типа фирмы
function TDataCache.GetFirmTypeName(typeID: Integer): string;
begin
  if not Assigned(self) or not FirmTypeExists(typeID) then Result:= ''
  else Result:= arFirmTypesNames[typeID];
end;
//================================================= наименование категории фирмы
function TDataCache.GetFirmClassName(ClassID: Integer): string;
begin
  if not Assigned(self) or not FirmClassExists(ClassID) then Result:= ''
  else Result:= arFirmClassNames[ClassID];
end;
//=================================================== наименование подразделения
function TDataCache.GetDprtMainName(pID: Integer): string;
begin
  if not Assigned(self) or not DprtExist(pID) then Result:= ''
  else Result:= arDprtInfo[pID].MainName;
end;
//================================================ кр.наименование подразделения
function TDataCache.GetDprtShortName(pID: Integer): string;
begin
  if not Assigned(self) or not DprtExist(pID) then Result:= ''
  else Result:= arDprtInfo[pID].ShortName;
end;
//============================================== заголовок колонки подразделения
function TDataCache.GetDprtColName(pID: Integer): string;
begin
  if not Assigned(self) or not DprtExist(pID) then Result:= ''
  else Result:= arDprtInfo[pID].ColumnName;
end;
//========================================================= наименование импорта
function TDataCache.GetImpTypeName(pID: Integer): string;
begin
  if Assigned(self) then Result:= FImportTypes.GetItemName(pID) else Result:= '';
end;
//============================================================ наименование роли
function TDataCache.GetRoleName(pID: Integer): string;
begin
  if Assigned(self) then Result:= FEmplRoles.GetItemName(pID) else Result:= '';
end;
//===================================================== наименование типа товара
function TDataCache.GetWareTypeName(typeID: Integer): string;
begin
  if Assigned(self) and TypeExists(typeID) then Result:= arWareInfo[typeID].Name
  else Result:= 'Не определен';
end;
//================================================================== текст акции
function TDataCache.GetActionComment(ActID: Integer): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if not WareActions.ItemExists(ActID) then Exit;
  Result:= TWareAction(WareActions[ActID]).Comment;
end;
//=================================================== коды всех ролей, must Free
function TDataCache.GetAllRoleCodes: Tai;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  Result:= FEmplRoles.GetDirCodes;
end;
{//====================== коды запрещенных для загрузки прайса брендов, must Free
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
//============================================================ список кодов фирм
function TDataCache.GetRegFirmCodes(RegID: Integer=0; Search: string=''; NotArchived: boolean=True): Tai;
// RegID>0 - код регионала, 0- все, <0 - отриц.номер региона ЦФУ
// Search - ключ поиска по наименованию, NotArchived - только неархивные
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
    list.Sort; // сортируем по наименованию
    SetLength(Result, list.Count);
    for i:= 0 to list.Count-1 do Result[i]:= integer(list.Objects[i]);
  finally
    prFree(list);
  end;
end;
//==================== список кодов менеджеров, сортировка по коду филиала и ФИО
function TDataCache.GetEmplCodesByShortName(DprtID: Integer=0; role: Integer=0): Tai;
//DprtID - код филиала (0-все)
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
  list.Sort; // сортируем по по коду филиала и ФИО
  SetLength(Result, list.Count);
  for i:= 0 to list.Count-1 do begin
    j:= Integer(list.Objects[i]);
    Result[i]:= j;
  end;
  prFree(list);
end;
//======================================= список подразделений в заданной группе
function TDataCache.GetGroupDprts(pDprtGroup: Integer=0; StoreAndRoad: Boolean=False): Tai; // must Free
// StoreAndRoad=True - только склады и пути, pDprtGroup=0 - все
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
//============================================================== список филиалов
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
    if (pos('переучет', s)>0) then Continue;
    j:= Dprt.ID;
    Result.AddObject(s, Pointer(j));
  except end;
  if Result.Count>1 then Result.Sort;
end;
//============================================================= список типов к/а
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
//========================================================= список категорий к/а
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
//=================================================== заполнение / проверка кэша
procedure TDataCache.TestDataCache(CompareTime: boolean=True; alter: boolean=False);
// CompareTime=True - проверять время последнего обновления, False - не проверять
// alter=True - по alter-таблицам, False - полная
const nmProc = 'TestDataCache'; // имя процедуры/функции
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
      if flFill then begin //------- первоначальное заполнение
        FillSysTypes; // контролируемые системы учета
        cdlp:= cdlpFillCache;
        if CompareTime then CompareTime:= False;
      end else begin
        cdlp:= cdlpTestCache;
      end;

      TestParConstants(flFill); // настройки

//if flDebug then TestFile;

      if not flFill then begin //----- проверка
        if (CompareDate(LastTimeCache, Now)=EqualsValue) and CompareTime then begin // тот же день
          fl:= fnGetActionTimeEnable(caeTechWork); //----- период тех.работ
          if not fl then begin                     //----- с вечера до утра увеличиваем интервал
            Interval:= fnIfInt(fnGetActionTimeEnable(caeOnlyDay), TestCacheInterval, TestCacheNightInt);
            fl:= (Now<IncMinute(LastTimeCache, Interval));
          end;
          if fl then begin
            TestWareRests(); // проверка связок с остатками товаров (свой интервал)
            Exit;
          end;
        end;
      end; // if not flFill

      prMessageLOGS(' ', fLogCache, false);
      prMessageLOGS('................ '+
        fnIfStr(flFill, 'filling', 'testing')+' cache ...', fLogCache, false);

      SetLongProcessFlag(cdlp, flFill); // флаг - заполнение/проверка кеша
      try
        TestSmallDirectories(flFill);
        FillInfoNews(flFill);             // заполнение/проверка инфо-блока
        FillNotifications(flFill);        // заполнение/проверка уведомлений (Web)
        if AllowWebArm then begin
          TestEmpls(0, true, CompareTime, true);
          if flFill then BrandTDList:= FillBrandTDList;   // Заполнение списка брендов TecDoc
//          if flDebug and flFill then CheckClientsEmails;
        end;
        TestCssStopException;

if flFill or not flSkipTestWares then
        TestWares(flFill);          // заполнение/проверка товаров

        TestWareRests(CompareTime); // заполнение/проверка связок с остатками товаров
        TestCssStopException;
                 // заполнение/проверка линков групп/подгрупп с шаблонами скидок
        TestGrPgrDiscModelLinks;

        with FDCA do begin
          FillSourceLinks;
          if flFill then FillDirManuf(flFill);  //------- заполнение
          FillOriginalNums(flFill);
          FillWareONLinks(flFill);
          TestCssStopException;
          if flFill and (AllowWeb or AllowWebArm) then begin //------- заполнение
            FillTreeNodesAuto;
            FillTreeNodesMotul; // заполнение дерева узлов MOTUL (!!! после FillTreeNodesAuto)
            FillTypesInfoModel;
            FillDirModelLines(flFill);
            FillDirEngines(flFill);
            FillDirModels(flFill);
            TestCssStopException;
          end; // if flFill
        end; // with FDCA

        FillWareFiles(flFill);                // Загрузка/проверка файлов товаров

//        if flFill then FillAttributes;        // Заполнение атрибутов

        FillGBAttributes(flFill); // Заполнение / проверка атрибутов Grossbee

        if AllowWebArm then begin
          CheckGAMainNodesLinks; // сверка TD->GA и TreeNodesAuto->MainNode
          CheckArticleWareMarks(fLogCache); // проверить наличие товаров у артикулов в TDT (по запросу)

        end else if not flFill and not CompareTime then begin // если по запросу с формы или из коммандера
          TestFirms(0, false, CompareTime, true);   // частичная проверка кэша фирм
          TestClients(0, false, CompareTime, true); // частичная проверка кэша клиентов
        end;

        if flFill then begin //------------ первоначальное заполнение

          WareCacheUnLocked:= True;  // разрешаем работу с кешем товаров
          Application.ProcessMessages;

          if AllowWeb or AllowWebArm then
            prMessageLOGS('................ загружен кеш до связок', fLogCache);
        end; // if flFill
      finally
        SetNotLongProcessFlag(cdlp); // сбрасываем флаг длинного процесса
      end;

      if flFill and (AllowWeb or AllowWebArm) then with FDCA do begin
        TestCssStopException;
        sleep(3*997); // ждем - может кому-то надо запуститься
        cdlp:= cdlpFillLinks;
        SetLongProcessFlag(cdlp, flFill); // флаг - заполнение связок
        try
  //          LongProcessFlag:= cdlpFillLinks; // флаг - заполнение связок
  //          while not SetLongProcessFlag(cdlpFillLinks) do begin // флаг - заполнение связок
  //            sleep(997);                                        // ждем, если идет другой длинный процесс
  //            TestCssStopException;
  //          end;
          FillModelNodeLinks;       // Загрузка связей моделей с деревом узлов (связка 2)
          FillWareModelNodeLinks;   // Загрузка связей товара со связкой 2 (связка 3)
          WareLinksUnLocked:= True; // разрешаем работу с подбором
          prMessageLOGS('................ загружены связки', fLogCache);
        finally
          SetNotLongProcessFlag(cdlp); // сбрасываем флаг длинного процесса
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
//====================================== индикатор своевременности проверки кеша
function TDataCache.GetTestCacheIndication: Integer;
var Interval: Integer;
begin
  Result:= 0;
//  if AppStatus in [stSuspending, stSuspended] then begin
//    Result:= 1;
//    Exit;
//  end;
                            // определяем интервал проверки кеша (день-ночь)
  Interval:= fnIfInt(fnGetActionTimeEnable(caeOnlyDay), TestCacheInterval, TestCacheNightInt);
  Interval:= Interval*60;    // переводим в сек
  if WareCacheTested then
    Interval:= Interval+(Interval div 2) // если идет проверка - добавляем еще половину
  else begin
    Interval:= Interval+       // добавляем интервал запуска проверки кеша
      GetIniParamInt(nmIniFileBOB, 'intervals', 'CheckDBConnectInterval', 30);
    Interval:= Interval+5*60;  // добавляем еще запас - 5 мин
  end;
  if (Now<IncSecond(LastTimeCache, Interval)) then Result:= 1;
end;
//====================== используется для сортировки TList справочника ShipTimes
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
//===================== используется для сортировки TList справочника DiscModels
function DiscModelsSortCompare(Item1, Item2: Pointer): Integer;
var i1, i2: TDiscModel;
begin
  try
    i1:= TDiscModel(Item1);
    i2:= TDiscModel(Item2);
    if i1.DirectInd>i2.DirectInd then Result:= 1 // сначала по индексу направления
    else if i1.DirectInd<i2.DirectInd then Result:= -1
    else if i1.Rating>i2.Rating then Result:= 1 // потом по рейтингу
    else if i1.Rating<i2.Rating then Result:= -1
    else Result:= AnsiCompareText(i1.Name, i2.Name); // потом по названию
  except
    Result:= 0;
  end;
end;
//===================================== сортировка акций по убыванию даты старта
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
//=================================================== сортировка акций по номеру
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
//====================================== сортировка расписаний пополнения склада
function FillTTSortCompare(Item1, Item2: Pointer): Integer;
var R1, R2: TDateTime;
    tt1, tt2: TCodeAndDates;
begin
  try
    tt1:= TCodeAndDates(Item1);
    tt2:= TCodeAndDates(Item2);
    R1:= tt1.Date2;  // 1 - по дате/времени прибытия
    R2:= tt2.Date2;
    if (R1=R2) then begin
      R1:= tt1.Date1; // 2 - по дате/времени показа
      R2:= tt2.Date1;
      if (R1=R2) then Result:= 0 else if (R1>R2) then result:= 1 else result:= -1;
    end else if (R1>R2) then result:= 1 else result:= -1;
  except
    Result:= 0;
  end;
end;
//======================================= заполнение/проверка малых справочников
procedure TDataCache.TestSmallDirectories(flFill: Boolean=True; alter: boolean=False);
// alter=True - по alter-таблицам, False - полная
const nmProc = 'TestSmallDirectories'; // имя процедуры/функции
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
  BonusVolumePercent:= 0; // процент отчислений на бонусы
  ilst:= TIntegerList.Create;
  lst:= TList.Create;
  try try
////////////////////////////////////////////////////////////////////////////////
    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibsGRB_'+nmProc, -1, tpRead, True);

///////////////////////////////////////////////////// длины комментариев в счете
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

////////////////////////////////////////////// минимальная дата док-тов Grossbee
    ibs.SQL.Text:= 'select max(LockDate) from (select TuneWageSuperLockDate LockDate'+
      ' from TuneParametrs union select UserDocmIntermediateDate LockDate'+
      ' from userpsevdonimreestr where USERCODE=1)';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then mDate:= ibs.Fields[0].AsDate+1;
    ibs.Close;
    if (mDate>0) and (mDate<>DocmMinDate) then DocmMinDate:= mDate;
    TestCssStopException;

//////////////////////////////////////////////////// получаем код валюты бонусов
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

////////////////////////////////////////// получаем процент отчислений на бонусы
    curr:= 0;
    ibs.SQL.Text:= 'select p.bnprpercent from BONUSPERCENT p order by p.bnprdate desc';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then curr:= ibs.Fields[0].AsFloat;
    ibs.Close;
    if fnNotZero(curr) and fnNotZero(curr-BonusVolumePercent) then BonusVolumePercent:= curr;
    TestCssStopException;

////////////////////////////////////////// процент кредита клиента для сообщения
    curr:= 0;
    ibs.SQL.Text:= 'SELECT DTZNCREDITPERCENT FROM DUTYZONES where DTZNCODE=2';
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then curr:= ibs.Fields[0].AsFloat;
    ibs.Close;
    if fnNotZero(curr) and fnNotZero(curr-CreditPercent) then CreditPercent:= curr;
    TestCssStopException;

///////////////////////////////////////////////////////////////////////// валюты
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
      if (i in [cUAHCurrency, BonusCrncCode]) then ss:= n else ss:= 'у.е.'; // наименование для клиента
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
          fnMakeAddCharStr(ss, 6, True)+fnMakeAddCharStr(FormatFloat(cFloatFormatSumm, curr), 10), fLogDebug, false); // пишем в log
      end;  }
    TestCssStopException;

////////////////////////////////////////////////////////////////////// типы фирм
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

//////////////////////////////////////////////////////////////// статусы товаров
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

///////////////////////////////////////////////////////////////// категории фирм
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

//////////////////////////////////////////////////////////////////////// ед.изм.
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

//////////////////////////////////////////////////////////////// методы отгрузки
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
    ShipMethods.SortDirListByName; // сортировка списка по наименованию
    TestCssStopException;

/////////////////////////////////////////////////////////////// времена отгрузки
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
    ShipTimes.DirSort(ShipTimesSortCompare); // сортировка списка - час + мин
    TestCssStopException;

////////////////////////////////////////////////////////////////// подразделения
                // коды филиалов - отправлять только письма о счетах с ошибками
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

    for i:= 1 to High(arDPRTInfo) do          // проставляем филиал по всем
      if Assigned(arDPRTInfo[i]) then arDPRTInfo[i].SetFilialID(i);

    j:= Length(arDprtInfo);
    for i:= High(arDprtInfo) downto 1 do if Assigned(arDprtInfo[i]) then begin
      j:= arDprtInfo[i].ID+1;
      break;
    end;
    if (Length(arDprtInfo)>j) then try
      CScache.Enter;
      SetLength(arDprtInfo, j); // обрезаем по мах.коду
    finally
      CScache.Leave;
    end;
    TestCssStopException;

///////////////////////////////////////////////////// методы отгрузки по складам
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
        SortByLinkName; // сортировка списка по наименованию
      end;
    end;
    ibs.Close;
    TestCssStopException;

///////////// список складов/откуда, Object - TTwoCodes: код склада, дней в пути
    try
      ibs.SQL.Text:= 'SELECT DPCMDEPARTMENTCODE, DPCMSTORECODE, DPCMDELAYDAY'+
        ' FROM DEPARTMENTCOMPLETION order by DPCMDEPARTMENTCODE, DPCMSORT';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('DPCMDEPARTMENTCODE').AsInteger; // склад/куда
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
            TTwoCodes(dprt.StoresFrom[k]).Qty:= -1; // флажки - не проверено
        finally
          CScache.Leave;
        end;
        fl:= False;
//        ilst.Clear;
        //---------------------------------------------------- проверяем 1 склад
        while not ibs.Eof and (i=ibs.fieldByName('DPCMDEPARTMENTCODE').AsInteger) do begin
          j:= ibs.fieldByName('DPCMSTORECODE').AsInteger;    // склад/откуда
          m:= ibs.fieldByName('DPCMDELAYDAY').AsInteger;     // дней в пути
          fl:= fl or (m>1);
          jj:= -1;
          for ii:= 0 to dprt.StoresFrom.Count-1 do begin
            sch:= TTwoCodes(dprt.StoresFrom[ii]);
            if (sch.ID1=j) then begin
              jj:= ii;
              break;
            end;
          end;
//          ilst.Add(j); // коды складов в нужном порядке для проверки сортировки
          try
            CScache.Enter;
            if (jj<0) then  // не нашли - добавляем
              dprt.StoresFrom.Add(TTwoCodes.Create(j, m, 1))
            else begin     // нашли - проверяем
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
          for k:= dprt.StoresFrom.Count-1 downto 0 do begin // удаляем непроверенные
            sch:= TTwoCodes(dprt.StoresFrom[k]);
            if (sch.Qty<0) then begin
              dprt.StoresFrom.Delete(k);
              prFree(sch);
            end;
          end;
          // проверить порядок сортировки   ???
{          j:= min(ilst.Count, dprt.StoresFrom.Count)-1; // для страховки
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

      //------------------------------------------------------ проверили 1 склад
      end; // while not ibs.Eof
    except
      on E: EBOBError do raise EBOBError.Create('_StoresFrom: '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_StoresFrom: '+E.Message, fLogCache);
    end;
    ibs.Close;
    TestCssStopException;

//if TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetDprtTimeTables') then
/////////////////////////////////////////// список расписаний складов пополнения
// Object - TCodeAndDates: код склада, граничное дата/время показа,
//                         дата/время прибытия, текст времени прибытия
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
        i:= ibs.fieldByName('dprtTo').AsInteger; // склад/куда
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
            TCodeAndDates(dprt.FillTT[k]).State:= False; // флажки - не проверено
        finally
          CScache.Leave;
        end;
        //---------------------------------------------------- проверяем 1 склад
        while not ibs.Eof and (i=ibs.fieldByName('dprtTo').AsInteger) do begin
          j:= ibs.fieldByName('dprtFrom').AsInteger;    // склад/откуда
          d1:= ibs.fieldByName('rShowTime').AsDateTime; // граничное дата/время показа
          d2:= ibs.fieldByName('rArrive').AsDateTime;   // дата/время прибытия

          ii:= Trunc(d2); // строка - дата/время прибытия - заголовок колонки остатков
          if (ii=Date()) then
            s:= 'Сегодня, после '+FormatDateTime(cTimeFormatN, d2)
          else if (ii=(Date()+1)) then
            s:= 'Завтра, после '+FormatDateTime(cTimeFormatN, d2)
          else s:= FormatDateTime('dd.mm.yyyy, после hh:nn', d2);

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
            if (jj<0) then  // не нашли - добавляем
              dprt.FillTT.Add(TCodeAndDates.Create(j, d1, d2, s))
            else begin     // нашли - проверяем заголовок колонки
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
              dprt.FillTT.Delete(k); // удаляем непроверенные
              prFree(cds);
            end;
          end;
          dprt.FillTT.SortList(FillTTSortCompare); // сортируем
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
      //------------------------------------------------------ проверили 1 склад
      end; // while not ibs.Eof
    except
      on E: EBOBError do raise EBOBError.Create('_DprtTodayTT: '+E.Message);
      on E: Exception do prMessageLOGS(nmProc+'_DprtTodayTT: '+E.Message, fLogCache);
    end;
    ibs.Close;
if flNewRestCols then
    ibs.ParamCheck:= True;
    TestCssStopException;

///////////////////////////////////////////////// расписания отгрузки по складам
    try
      mDate:= Date();
      ibs.SQL.Text:= 'SELECT SHBDDATE, DpScDprtCode,'+
        ' iif(DpExScCode is null, DpScStartTime, DpExScStartTime) StartTime,'+
        ' iif(DpExScCode is null, DpScStopTime, DpExScStopTime) StopTime'+
        ' FROM OPERSCHDBODY left join DprtSchedule on dpscdaytype=SHBDSHIFT'+
        ' left join DprtExceptSchedule on DpExScDprtCode=DpScDprtCode and DpExScDate=SHBDDATE'+
        ' where SHBDDATE between :d1 and :d2 and DpScDprtCode is not null'+
        ' order by DpScDprtCode, SHBDDATE';
      ibs.ParamByName('d1').AsDate:= mDate;            // с запасом под выходные и праздники
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
        for j:= 0 to dprt.Schedule.Count-1 do lst.Add(Pointer(0)); // флаги проверки
        while not ibs.Eof and (i=ibs.fieldByName('DpScDprtCode').AsInteger) do begin
          ii:= trunc(ibs.fieldByName('SHBDDATE').AsDate-mDate);
          if (ii>-1) then begin
            j:= ibs.fieldByName('StartTime').AsInteger;
            jj:= ibs.fieldByName('StopTime').AsInteger;
            try
              CScache.Enter;
              while (dprt.Schedule.Count<=ii) do begin // если есть пропуски дат
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
          for i:= 0 to dprt.Schedule.Count-1 do begin // ищем непроверенные
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

/////////////////////////////////////////////////// ЦФУ (FISCALACCOUNTINGCENTER)
    if not flFill then FiscalCenters.SetDirStates(False);   // только категория <Планирование ПРОДАЖ>
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
    ibs.SQL.Add('    if (exists(select * from fiscalcentergroup f where f.FcGrMasterCode=:rCode'); // верхний уровень
    ibs.SQL.Add('      and f.FcGrClassCode=6 and f.FCGRSTARTDATE<="today" and f.FCGRFISCALARCHIVE="F"))');
    ibs.SQL.Add('    then begin rEmpl=-1; suspend; end');
    ibs.SQL.Add('    else begin for select e.emplcode from CONTROLUNITLINK cul'); // нижний уровень
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
      if fc.CheckIsROPFacc and (j>0) then begin // ЦФУ РОП-а округа
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
    try // сверяем массив ЦФУ РОП-а округа по номеру округа
      CScache.Enter;
      if Length(arRegionROPFacc)<>Length(ar) then
        SetLength(arRegionROPFacc, Length(ar));
      for i:= Low(ar) to High(ar) do
        if arRegionROPFacc[i]<>ar[i] then arRegionROPFacc[i]:= ar[i];
    finally
      CScache.Leave;
    end;
{      if flDebug then begin
      prMessageLOGS('-------------------', fLogDebug, false); // пишем в log
      for i:= 0 to ItemsList.Count-1 do with TFiscalCenter(ItemsList[i]) do
        prMessageLOGS(fnMakeAddCharStr(GetSaleType, 3)+' '+fnMakeAddCharStr(Parent, 5)+' '+
          fnMakeAddCharStr(ID, 5)+' '+Name, fLogDebug, false); // пишем в log
    end;   }
    TestCssStopException;

////////////////////////////// коды брендов через запятую без показа рисунков TD
//    s:= GetConstItem(pcBrandsWithoutTDPicts).StrValue;
//    prCheckIntegerListByCodesString(NoTDPictBrandCodes, s); // сверить TIntegerList со строкой кодов

    ibs.ParamCheck:= True;
///////////////////////////////////////////////////////////////////////// прайсы
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
    try // сверяем список прайсов
      if (j<1) then begin // подстраховка
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

///////////////////////////////////////////////////////////////// шаблоны скидок
    ibs.SQL.Clear;         // направления по продуктам
    ibs.SQL.Text:= 'SELECT rProdDirect, rPrDirName from Vlad_CSS_GetProdDirects';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('rProdDirect').AsInteger;
      s:= ibs.fieldByName('rPrDirName').AsString;
      if (i<>cpdNotDirect) then begin
        DiscountModels.CheckProdDirect(i, s); // проверяем/добавляем направление
        if not flFill then ilst.Add(i);
      end;
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;
    if not flFill then with DiscountModels do for i:= ProdDirectList.Count-1 downto 0 do begin
      jj:= Integer(ProdDirectList.Objects[i]);
      if (ilst.IndexOf(jj)<0) then DelProdDirect(jj);     // удаляем лишние
    end;

{    if flDebug then begin
      prMessageLOGS('-------------------', fLogDebug, false); // пишем в log
      for i:= 0 to DiscountModels.ProdDirectList.Count-1 do
      with DiscountModels.ProdDirectList do
        prMessageLOGS(fnMakeAddCharStr(IntToStr(integer(Objects[i])), 3)+' '+
          Strings[i], fLogDebug, false); // пишем в log
      prMessageLOGS('-------------------', fLogDebug, false); // пишем в log
    end;  }

    ibs.SQL.Text:= 'SELECT rProdDirect, rDiscModel, rModelName, rRating, rValue'+
                   ' from Vlad_CSS_GetProdDirDiscModels';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('rProdDirect').AsInteger;
      while not ibs.EOF and (i=ibs.FieldByName('rProdDirect').AsInteger) do begin
        if (i<>cpdNotDirect) then begin
          j:= ibs.fieldByName('rDiscModel').AsInteger; // проверяем/добавляем шаблон
          DiscountModels.CheckDiscModel(j, i, ibs.fieldByName('rRating').AsInteger,
            ibs.fieldByName('rValue').AsInteger, ibs.fieldByName('rModelName').AsString);
        end;
        cntsGRB.TestSuspendException;
        ibs.Next;
      end;
    end;
    ibs.Close;
    if not flFill then DiscountModels.DelNotTestedDiscModels; // удалить лишние шаблоны
    DiscountModels.SortDiscModels;

{    if flDebug then begin
      prMessageLOGS('-------------------', fLogDebug, false); // пишем в log
      for i:= 0 to DiscountModels.DiscModels.Count-1 do
      with TDiscModel(DiscountModels.DiscModels[i]) do
        prMessageLOGS(fnMakeAddCharStr(ID, 3)+' '+fnMakeAddCharStr(DirectInd, 5)+' '+
          fnMakeAddCharStr(Rating, 5)+' '+fnMakeAddCharStr(Sales, 5)+' '+Name, fLogDebug, false); // пишем в log
      prMessageLOGS('-------------------', fLogDebug, false); // пишем в log
    end; }

/////////////////////////////////////////////////////////////////////// продукты
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
      if not flFill then ilst.Add(i); // для проверки
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
        if (ilst.IndexOf(jj)<0) then WareProductList.Delete(i);     // удаляем лишние
      end;
    finally
      Cache.CScache.Leave;
    end;

//////////////////////////////////////////////////////////////////// шаблоны SMS
    ilst.Clear;
    ibs.SQL.Clear;
    ibs.SQL.Text:= 'SELECT AnDtCode, AnDtName'+
      ' from SMSMODELS left join analitdict on AnDtCode=SMRegistrCode'+
      ' where AnDtCode is not null and AnDtCode>0 and not (andtname starting "_")';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      i:= ibs.fieldByName('AnDtCode').AsInteger;
      s:= ibs.fieldByName('AnDtName').AsString;
      if not flFill then ilst.Add(i); // для проверки
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
        if (ilst.IndexOf(jj)<0) then SMSmodelsList.Delete(i);     // удаляем лишние
      end;
    finally
      Cache.CScache.Leave;
    end;

//////////////////////////////////////////////////// список кодов моб.операторов
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

//////////////////////////////////////////////////////// реестр акций по товарам
    if not flFill then WareActions.SetDirStates(False);
    ibs.SQL.Clear;
    s:= Cache.GetConstItem(pcCauseActions).StrValue;     // Акции
    n:= ' iif(a.andtcode='+s+' or a1.andtcode='+s+' or a2.andtcode='+s+
        ' or a3.andtcode='+s+' or a4.andtcode='+s+', 1, 0) acts,';
    s:= Cache.GetConstItem(pcCauseCatchMoment).StrValue; // Лови момент
    n:= n+' iif(WrAcCauseCode='+s+', 1, 0) cms,';
    s:= Cache.GetConstItem(pcCauseNews).StrValue;        // Новинки
    n:= n+' iif(WrAcCauseCode='+s+', 1, 0) news,';
    s:= Cache.GetConstItem(pcCauseTopSearch).StrValue;   // ТОП поиска
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
      if fl then begin // уже есть - проверяем
        wa:= WareActions[i];
        wa.Name:= s;
      end else begin   // новая - создаем
        wa:= TWareAction.Create(i, s, n, d1, d2);
        WareActions.CheckItem(Pointer(wa));
      end;
      WareActions.CS_DirItems.Enter;
      try
        wa.IsAction   := (ibs.fieldByName('acts').AsInteger=1); // флаг - Акции
        wa.IsCatchMom := (ibs.fieldByName('cms').AsInteger=1);  // флаг - Лови момент
        wa.IsNews     := (ibs.fieldByName('news').AsInteger=1); // флаг - Новинки
        wa.IsTopSearch:= (ibs.fieldByName('tops').AsInteger=1); // флаг - ТОП поиска
        wa.Num        := ibs.FieldByName('WrAcNumber').AsString;
        if fl then begin // уже есть - проверяем
          if (wa.Comment<>n) then wa.Comment:= n;
          wa.BegDate:= d1;
          wa.EndDate:= d2;
          wa.State:= True;
        end;
        wa.IconExt:= ibs.FieldByName('WrAcExtn').AsString; // расширение иконки
        wa.IconMS.Clear;
        if (wa.IconExt<>'') then
          IBS.FieldByName('WrAcPhoto').SaveToStream(wa.IconMS); // иконка
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
    if not flFill then WareActions.DelDirNotTested; // удалить лишние
    WareActions.DirSort(WareActionsNumSortCompare); // сортировка акций по номеру
//    WareActions.DirSort(WareActionsDescSortCompare); // сортировка акций по убыванию даты старта

    jj:= 0;
    wat:= nil;  //---------------------------- ищем действующую акцию ТОП поиска
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
      TopActCode:= wat.ID; // запоминаем действующую акцию ТОП поиска
    finally
      Cache.CScache.Leave;
    end;

    if (jj>1) and AllowWeb then // нашли > 1
    if not flFill then // проверка - в лог
      prMessageLOGS(nmProc+': Обнаружено '+IntToStr(jj)+
        ' действ.док.`ТОП поиска`, СВК использует N '+wat.Num, fLogCache)
    else try  // при загрузке - письмо
      Strings:= TStringList.Create;
      Strings.Add('Письмо создано сервером СВК');
      Strings.Add(' ');
      Strings.Add('Обнаружено несколько ('+IntToStr(jj)+
                  ') действующих документов акции `ТОП поиска`,');
      Strings.Add('СВК использует документ N '+wat.Num);
      n:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // отправляем в УиК
      n:= n_SysMailSend(n, 'Сообщение от сервера СВК', Strings, nil, cNoReplayEmail, '', true);
      if (n<>'') and (Pos(MessText(mtkErrMailToFile), n)>0) then begin  // если не записали в файл
        Strings.Insert(0, GetMessageFromSelf);
        Strings.Add(#10'Текст ошибки:'#10+n); // добавляем Текст ошибки 1-й отправки и отправляем админам
        n:= n_SysMailSend(Cache.GetConstEmails(pcEmplORDERAUTO),
            MessText(mtkErrSendMess, 'от сервера СВК'), Strings, nil, '', '', true);
        if (n<>'') then prMessageLOGS(nmProc+': '+n+#10+
          MessText(mtkErrSendMess, 'админам')+#10'Текст письма: '+Strings.Text, fLogCache);
      end;
    finally
      prFree(Strings);
    end;

//////////////////////////////////////////////////////////// продуктовые линейки
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
        iLst.Add(i); // собираем коды актуальных прод.линеек для сверки
      cntsGRB.TestSuspendException;
      ibs.Next;
    end;
    ibs.Close;

    if not flFill then for i:= ProductLines.Count-1 downto 0 do begin
      ProductLine:= TProductLine(ProductLines[i]);
      if not ProductLine.State then try
        Cache.CScache.Enter;
        ProductLines.Delete(i);  // TObjectList сам фрикает элемент
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

      if flDebug or AllowWebarm then try //----------------- сверяем PrLiOPTIONS
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

        if (Strings.Count>0) then try try //----------- если надо - пишем в базу
          fnSetTransParams(ibsOrd.Transaction, tpWrite, True);
          jj:= 0;
          repeat
            ibsOrd.Close;
            ibsOrd.SQL.Clear;
            for i:= jj to Strings.Count-1 do
              // по 50 строк (100 не дает: Dynamic SQL Error Too many Contexts)
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
      //------------------------- признаки применимости к моделям из PrLiOPTIONS
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
          ProductLine.HasModelCV:= GetBoolGB(ibsOrd, 'lploHASCV');     // грузовиков
          ProductLine.HasModelAx:= GetBoolGB(ibsOrd, 'lploHASAX');     // осей
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
//================================================= наименование метода отгрузки
function TDataCache.GetShipMethodName(smID: Integer): string;
begin
  Result:= '';
  if not Assigned(self) or not ShipMethods.ItemExists(smID) then Exit;
  Result:= GetDirItemName(ShipMethods[smID]);
end;
//==================================== признак запрета времени у метода отгрузки
function TDataCache.GetShipMethodNotTime(smID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not ShipMethods.ItemExists(smID) then Exit;
  Result:= not TShipMethodItem(ShipMethods[smID]).TimeKey;
end;
//=================================== признак запрета наклейки у метода отгрузки
function TDataCache.GetShipMethodNotLabel(smID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not ShipMethods.ItemExists(smID) then Exit;
  Result:= not TShipMethodItem(ShipMethods[smID]).LabelKey;
end;
//================================================ наименование времени отгрузки
function TDataCache.GetShipTimeName(stID: Integer): string;
begin
  Result:= '';
  if not Assigned(self) or not ShipTimes.ItemExists(stID) then Exit;
  Result:= GetDirItemName(ShipTimes[stID]);
end;
//====== сортированный список методов отгрузки по складу или всех (Objects - ID)
function TDataCache.GetShipMethodsList(dprt: Integer=0): TStringList; // must Free
var i, id: Integer;
    s: String;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  if dprt<1 then begin // все
    with ShipMethods do for i:= 0 to ItemsList.Count-1 do begin
      s:= GetDirItemName(ItemsList[i]);
      id:= GetDirItemID(ItemsList[i]);
      Result.AddObject(s, Pointer(id));
    end;
    Exit;
  end;
  if not DprtExist(dprt) then Exit;            // по складу
  with arDprtInfo[dprt].ShipLinks do for i:= 0 to ListLinks.Count-1 do begin
    s:= GetLinkName(ListLinks[i]);
    id:= GetLinkID(ListLinks[i]);
    Result.AddObject(s, Pointer(id));
  end;
end;
//============================================= наименование шаблона SMS по коду
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
//========================== сортированный список времен отгрузки (Objects - ID)
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
//========================================= наименование продукта по коду товара
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
//======================================================= проверка кэша констант
procedure TDataCache.TestParConstants(flFill: Boolean=True; alter: boolean=False);
// alter=True - по alter-таблицам, False - полная
const nmProc = 'TestParConstants'; // имя процедуры/функции
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
      Item:= TConstItem.Create(0, 'Неизв.параметр', 2);
      FParConstants.CheckItem(Item); // добавляем в справочник 0-й элемент
    end{ else FParConstants.SetDirStates(False)};
    try
      ibd:= cntsORD.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibsORD_'+nmProc, -1, tpRead, True);
      ibs.SQL.Text:= 'select * from SERVERPARAMCONSTANTS'; // список констант
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('SPCCODE').asInteger;
        s:= IntToStr(i);
        flnew:= not FParConstants.ItemExists(i);
        if flnew then begin
          Item:= TConstItem.Create(i, ibs.fieldByName('SPCNAME').asString,
            ibs.fieldByName('SPCTYPECODE').asInteger,
            ibs.fieldByName('SPCUSERID').asInteger,
            ibs.fieldByName('SPCPRECISION').asInteger, True); // Links - роли
          FParConstants.CheckItem(Item);                  // добавляем в справочник
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
          LastTime   := ibs.fieldByName('SPCTIME').AsDateTime; // время посл.изменения
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
//    if not flFill then FParConstants.DelDirNotTested; // удаление маловероятно
    FParConstants.CheckLength;

    //-------------- строка для вставки в заголовок письма (SysMailSend)
    VSMail.CheckXstring(GetConstItem(pcX_section).StrValue, GetConstItem(pcX_value).StrValue);

    //--------------  список кодов фиктивных менеджеров (ИНФО, ЯяяАРХИВ и т.п.)
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

    //-----------------------------------------------------  код группы ДОСТАВКИ
    pgrDeliv:= GetConstItem(pcDeliveriesMasterCode).IntValue;

    //----------  переключатель блокировки конечных покупателей: 0- нет, 1- блок
    flBlockUber:= (Cache.GetConstItem(pcBlockFinalClient).IntValue=1);

///////////////////////////////////////////////////////////////////////// прайсы
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
    if (Length(PriceTypes)<1) then begin // подстраховка
      SetLength(PriceTypes, 1);
      PriceTypes[0]:= 1;
    end;

    //--------------- Email отправителя для писем от СВК (no.reply@vladislav.ua)
    cNoReplayEmail:= Cache.GetConstItem(pcEmailFromBySVK).StrValue;
    //--------------------------------------- фиктивный Email (xyz@vladislav.ua)
    cFictiveEmail:= Cache.GetConstItem(pcFictiveEmail).StrValue;
    //--------------------------- лимит строк в списке незакрытых заказов (5-50)
    FormingOrdersLimit:= Cache.GetConstItem(pcFormingOrdersLimit).IntValue;
    if (FormingOrdersLimit<5) then FormingOrdersLimit:= 5;
    //------------------ лимит строк в списке заказов, 0- не проверять или >= 20
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
//============================================== заполнение/проверка сотрудников
procedure TDataCache.TestEmpls(pEmplID: Integer; FillNew: boolean=True;
          CompareTime: boolean=True; TestEmplFirms: boolean=False);
const nmProc = 'TestEmpls'; // имя процедуры/функции
type
  TUserGBInfo = record //----- для параметров USERLIST
    UserLogin: string;    // логин Grossbee
    UserMail : string;    // Email сотрудника
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
    try try                                      // проверяем данные из Grossbee
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
      if pEmplID<0 then begin                            // по alter-таблицам

      end else if pEmplID=0 then begin                    // полная проверка
        ibs.SQL.Text:= s;
      end else begin                                 // 1 сотрудник
        ibs.SQL.Text:= s+' where EMPLCODE='+UserCode;
      end;
      iORDERAUTO:= Cache.GetConstItem(pcEmplORDERAUTO).IntValue;

      ibs.ExecQuery;       // заполняем данные сотрудников из EMPLOYEES, MANS Grossbee
      while not ibs.Eof do begin
        i:= ibs.fieldByName('EMPLCODE').AsInteger;
        j:= ibs.fieldByName('Facc').AsInteger; // для проверки на уволенность
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
            if Arhived then begin // у архивных/уволенных вычищаем логины
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
                                    // заполняем массив из USERLIST Grossbee
      ibs.SQL.Text:= 'select USLSCODE, USLSUSERID, USLSEMAIL'+  // , USRLVISIBLEGROUPCODE
                     ' from USERLIST left join USERROLES on USRLCODE=USLSROLECODE'+
                               // неархивные и роль <> "Архивные пользователи"
                     ' where uslsarchive="F" and usrlcode<>21 order by USLSCODE desc';
      ibs.ExecQuery; // вынимаем максимальную длину текста прав видимости
      while not ibs.Eof do begin
        i:= ibs.fieldByName('USLSCODE').AsInteger;
        if High(userslist)<i then begin // должно отработать 1 раз
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

    try try                                     // проверяем данные из css_ord
      ibd:= cntsOrd.GetFreeCnt;
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc+'_'+UserCode, -1, tpRead, True);
      s:= 'Select EMPLCODE, EMPLDPRTCODE, EMPLLOGIN, EMPLPASS,'+
          ' EMPLRESETPASWORD, EMPLGBUSER, EMPLGBREPORTUSER, EMRLROLECODE,'+
          ' EMPLSESSIONID, EMPLLASTACTION, EMPLBLOCK, EMPLDISABLEOUT'+
          ' FROM EMPLOYEES left join EMPLOYEESROLES on EMRLEMPLCODE=EMPLCODE';
      if pEmplID<0 then begin                             // по alter-таблицам

      end else if pEmplID=0 then begin                    // полная проверка
        s:= s+' order by EMPLCODE, EMRLROLECODE';
      end else begin                                      // 1 сотрудник
        s:= s+' where EMPLCODE='+UserCode+' order by EMRLROLECODE';
      end;
      ibs.SQL.Text:= s;
      ibs.ExecQuery;                  // заполняем данные сотрудников из dbOrd
      while not ibs.Eof do begin
        cntsORD.TestSuspendException;
        i:= ibs.fieldByName('EMPLCODE').AsInteger;
        if not EmplExist(i) or arEmplInfo[i].Arhived then begin // архивных не заполняем
          TestCssStopException;
          while not ibs.Eof and (i=ibs.fieldByName('EMPLCODE').AsInteger) do ibs.Next;
          Continue;
        end;
//          iUser:= 0;
        with arEmplInfo[i] do try try   // существующий объект проверяем
          CS_Empls.Enter;
          ServerLogin:= ibs.fieldByName('EMPLLOGIN').AsString;
          USERPASSFORSERVER:= ibs.fieldByName('EMPLPASS').AsString;
          Session:= ibs.fieldByName('EMPLSESSIONID').AsString;
          dd:= ibs.fieldByName('EMPLLASTACTION').AsDateTime;
          if (dd>DateNull) and (LastActionTime<>dd) then LastActionTime:= dd;
          EmplDprtID:= ibs.fieldByName('EMPLDPRTCODE').AsInteger;  // пока
          RESETPASSWORD:= GetBoolGB(ibs, 'EMPLRESETPASWORD');
          Blocked:= (ibs.fieldByName('EMPLBLOCK').AsInteger>0);
          DisableOut:= GetBoolGB(ibs, 'EMPLDISABLEOUT');

          iUser:= ibs.fieldByName('EMPLGBUSER').AsInteger;
          if (iUser>0) and (length(userslist)>iUser) then begin
            s:= userslist[iUser].UserLogin;
            if (s<>'') and (GBLogin<>s) then GBLogin:= s;
            s:= userslist[iUser].UserMail;
            if (s<>'') and (Mail='') then Mail:= s; // ??? пока для ORDERAUTO
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

        arEmplInfo[i].TestUserRoles(roles); // проверяем роли
        TestCssStopException;
      end;
      ibs.Close;

      if (pEmplID=0) then begin
        i:= 0;
        try
          if not flfill then FEmplRoles.SetDirStates(False); // список ролей
          ibs.SQL.Text:= 'Select ROLECODE, ROLENAME FROM ROLES';
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('ROLECODE').AsInteger;
            s:= ibs.fieldByName('ROLENAME').AsString;
            Item:= TEmplRole.Create(i, s);
            FEmplRoles.CheckItem(Item);          // добавляем в справочник
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
          if not flfill then FImportTypes.SetDirStates(False); // список видов импорта
          ibs.SQL.Text:= 'select IMTPCODE, IMTPNAME, IMTPREPORT, IMTPIMPORT from ImportTypes';
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('IMTPCODE').AsInteger;
            s:= ibs.fieldByName('IMTPNAME').AsString;
            if not FImportTypes.ItemExists(i) then begin
              Item:= TImportType.Create(i, s,
                GetBoolGB(ibs, 'IMTPREPORT'), GetBoolGB(ibs, 'IMTPIMPORT'));
              FImportTypes.CheckItem(Item);       // добавляем в справочник
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
          ibs.SQL.Text:= 'select LITRIMTPCODE, LITRROLECODE,'+ // связки видов импорта с ролями
            ' LITRAllowRep, LITRAllowImp from LINKIMPTYPEROLE';
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('LITRIMTPCODE').asInteger; // вид импорта
            j:= ibs.fieldByName('LITRROLECODE').asInteger; // роль
            if FImportTypes.ItemExists(i) and FEmplRoles.ItemExists(j) then begin
              iw:= GetLinkSrcFromRepImpAllow(GetBoolGB(ibs, 'LITRAllowRep'),
                GetBoolGB(ibs, 'LITRAllowImp')); // SrcID= 1- отчет, 2- импорт, 3- отчет + импорт
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

        try // список констант заполняется раньше, в TestSmallDirectories
          ibs.SQL.Text:= 'select SPCRSPCCODE, SPCRROLECODE, SPCRWRITE'+
            ' from LINKSERVPARCONSTROLE'; // связки констант с ролями
          ibs.ExecQuery;
          while not ibs.Eof do begin
            i:= ibs.fieldByName('SPCRSPCCODE').asInteger; // вид импорта
            j:= ibs.fieldByName('SPCRROLECODE').asInteger; // роль
            iw:= FnIfInt(GetBoolGB(ibs, 'SPCRWRITE'), 1, 0);
            if FParConstants.ItemExists(i) and FEmplRoles.ItemExists(j) then begin
              TConstItem(FParConstants[i]).Links.CheckLink(j, iw, FEmplRoles[j]);     // SrcID=1 - признак разрешения записи
              TEmplRole(FEmplRoles[j]).ConstLinks.CheckLink(i, iw, FParConstants[i]); // SrcID=1 - признак разрешения записи
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
        SetLength(arEmplInfo, j); // обрезаем по мах.коду
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
    prMessageLOGS(nmProc+'_'+UserCode+' '+IntToStr(iCount)+' сотр: - '+
      GetLogTimeStr(LocalStart), fLogCache, false);
    if TestEmplFirms then begin
      TestFirms(0, FillNew, CompareTime, True);
      TestClients(0, FillNew, CompareTime, True);
    end;
  end else if (pEmplID>0) and TestEmplFirms then
    TestFirms(0, FillNew, CompareTime, True, pEmplID); // проверка фирм регионала
  TestCssStopException;
//---------------------------------------------------------
end;
//=================== получить признак доступности отчета/импорта из srcID линка
function GetRepImpAllowFromLinkSrc(srcID: Integer; flReport: Boolean=False): Boolean;
// flReport=True - проверять разрешение отчета, False - разрешение импорта
// в линке - SrcId= 1- отчет, 2- импорт, 3- отчет + импорт
begin
  Result:= False;
  if (srcID<1) then Exit
  else if (srcID=3) then Result:= True
  else if flReport then Result:= (srcID=1)
  else Result:= (srcID=2);
end;
//================= получить srcID линка из признаков доступности отчета/импорта
function GetLinkSrcFromRepImpAllow(RepAllow, ImpAllow: Boolean): Integer;
// в линке - SrcId= 1- отчет, 2- импорт, 3- отчет + импорт
begin
  Result:= 0;
  if not (RepAllow or ImpAllow) then Exit;
  if RepAllow then Result:= 1;
  if ImpAllow then Result:= Result+2;
end;
//============================================ доступные роли для отчета/импорта
function TDataCache.GetRepOrImpRoles(ImpID: Integer; flReport: Boolean=True): Tai; // must Free
// flReport=True - проверять разрешение на отчет, False - импорт
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
//================================= список доступных отчетов/импортов сотрудника
function TDataCache.GetEmplAllowRepOrImpList(pEmplID: Integer; flReport: Boolean=True): TStringList; // must Free
// flReport=True - список отчетов, False - импортов
const nmProc = 'GetEmplAllowRepOrImpList'; // имя процедуры/функции
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
    on e: Exception do prMessageLOGS(nmProc+': '+E.Message); // пишем в log
  end;
  prFree(ilst);
end;
//========================================= доступные виды отчетов/импортов роли
function TDataCache.GetRoleAllowRepOrImpList(pRoleID: Integer; flReport: Boolean=True): TStringList; // must Free
const nmProc = 'GetRoleImports'; // имя процедуры/функции
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
    on e: Exception do prMessageLOGS(nmProc+': '+E.Message); // пишем в log
  end;
end;
//==================== признак наличия разрешенных отчетов/импортов у сотрудника
function TDataCache.GetEmplAllowRepImp(pEmplID: Integer): boolean;
const nmProc = 'GetEmplAllowRepImp'; // имя процедуры/функции
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
    on e: Exception do prMessageLOGS(nmProc+': '+E.Message); // пишем в log
  end;
end;
 //================== проверка кодов фиктивных менеджеров (ИНФО, ЯяяАРХИВ и т.п.)
function TDataCache.CheckEmplIsFictive(pEmplID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not EmplExist(pEmplID) then Exit;
  Result:= (fnInIntArray(pEmplID, arFictiveEmpl)>-1);
end;
//=============================== проверка доступности отчета/импорта сотруднику  - убрать
function TDataCache.CheckEmplImpType(pEmplID, impID: Integer; flReport: Boolean=False): Boolean;
// flReport=True - проверять разрешение отчета, False - разрешение импорта
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
//================== сортировка TStringList (Objects-ID ConstItem) Grouping+Name
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
//=============================================== доступные константы сотрудника
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
//==================================== проверка доступности константы сотруднику
function TDataCache.CheckEmplConstant(pEmplID, constID: Integer; var errmess: string; CheckWrite: Boolean=False): Boolean;
// CheckWrite=True - проверять разрешение на запись (в линке - SrcId=1)
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
//========================================= кол-во доступных констант сотрудника
function TDataCache.GetEmplConstantsCount(pEmplID: Integer): Integer;
begin
  Result:= 0;
  if not Assigned(self) or not EmplExist(pEmplID) then Exit;
  with GetEmplConstants(pEmplID) do try
    Result:= Count;
  finally Free; end;
end;
//============================ список адресов константы-списка кодов сотрудников
function TDataCache.GetConstEmails(pc: Integer; pFirm: Integer=0; pWare: Integer=0): String;
var s: String;
begin
  Result:= GetConstEmails(pc, s, pFirm, pWare);
  s:= '';
end;
//============================ список адресов константы-списка кодов сотрудников
function TDataCache.GetConstEmails(pc: Integer; var mess: String; pFirm: Integer=0; pWare: Integer=0): String;
// в mess возвращает сообщения о ненайденных адресах
var ar: Tai;
//    index: Integer;
begin
  Result:= '';
  mess:= '';
  if not Assigned(self) or not ConstExists(pc) then Exit;
  try
    ar:= GetConstEmpls(pc);
    if length(ar)<1 then exit;
{                                 // удалить РОП-мото
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
//================================= список кодов сотрудников из константы-списка
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
      if fnInIntArray(emplID, Result)>-1 then Continue; // проверяем на дубляж
      if (emplID>0) then begin // если emplID>0 - проверяем сотрудника
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
//=================================================== список адресов сотрудников
function TDataCache.GetEmplEmails(empls: Tai; pFirm: Integer=0; pWare: Integer=0;
                    pSys: Integer=0; pRegion: Integer=0): String;
const nmProc = 'GetEmplEmails';
var s: string;
begin
  Result:= GetEmplEmails(empls, s, pFirm, pWare, pSys, pRegion);
  s:= '';
end;
//=================================================== список адресов сотрудников
function TDataCache.GetEmplEmails(empls: Tai; var mess: String; pFirm: Integer=0;
                    pWare: Integer=0; pSys: Integer=0; pRegion: Integer=0): String;
// в mess возвращает сообщения о ненайденных адресах
const nmProc = 'GetEmplEmails';
var emplID, i, j, jj: Integer;
    ar, arCodes, arFirmCodes, arFil: Tai;
    Firm: TFirmInfo;
    Empl: TEmplInfoItem;
    facc: TFiscalCenter;
  //----------------------------------- ищем фирму
  function _FindFirm: Boolean;
  begin
    Result:= Assigned(Firm);
    if Result then exit;     // уже нашли раньше
    Result:= (pFirm>0) and FirmExist(pFirm);
    if Result then Firm:= arFirmInfo[pFirm]
    else mess:= mess+fnIfStr(mess='', '', #13#10)+
      MessText(mtkNotFirmExists, IntToStr(pFirm));
  end;
  //----------------------------------- ищем сотрудника
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
        ' сотрудник '+Empl.EmplShortName+' (код '+IntToStr(emplID)+') заблокирован';
    end else mess:= mess+fnIfStr(mess='', '', #13#10)+
      MessText(mtkNotEmplExist, IntToStr(emplID));
  end;
  //----------------------------------- добавляем адрес в Result
  procedure _AddEmplMail;
  begin
    if (fnInIntArray(Empl.ID, arCodes)>-1) then exit; // проверяем на дубляж
    prAddItemToIntArray(Empl.ID, arCodes); // добавить код в массив, если его там нет
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
  SetLength(arCodes, 0); // сюда собираем коды для проверки дубляжа
  SetLength(arFirmCodes, 0);     // список систем/менеджеров фирмы
  SetLength(arFil, 0);
  Firm:= nil;
  try
    for i:= 0 to High(empls) do if (empls[i]<>0) then
      prAddItemToIntArray(empls[i], ar); // добавить код в массив, если его там нет

    for i:= 0 to High(ar) do try
      if (ar[i]=0) then Continue;
//--------------------------------------------------- обычные сотрудники (код>0)
      if (ar[i]>0) then begin
        emplID:= ar[i];
        if _FindEmpl then _AddEmplMail;
        Continue;
      end;
//------------------------------------------ "типизированные" сотрудники (код<0)
      case ar[i] of
      ceWareProduct: //--------------------------------- Продукт-менеджер товара
        if (pWare>0) and WareExist(pWare) then begin
          emplID:= GetWare(pWare).ManagerID;
          if _FindEmpl then _AddEmplMail;
        end;

      ceSysSaleDirector: begin //------- Директор по продажам бизнес-направления
          EmplID:= GetConstItem(pcEmplSaleDirectorAuto).IntValue;
          if _FindEmpl then _AddEmplMail; // dmitriy.voloshin@vladislav.ua
        end;                              // valeriy.nestjurin@motogorodok.com - убрали

      ceSysResponsible:       //--------------- Ответственный бизнес-направления
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

      ceFirmManager:       //------------------------------ Менеджер контрагента
        if _FindFirm then for j:= 0 to Firm.FirmManagers.Count-1 do begin
          EmplID:= Firm.FirmManagers[j];
          if _FindEmpl then _AddEmplMail;
        end;

      ceFilialROP: begin //-------------------------------- РОП филиала (округа)
          SetLength(arFil, 0); // коды ЦФУ РОП-ов
          if (pRegion>0) then begin
            if (pRegion>High(Cache.arRegionROPFacc)) then j:= 0
            else j:= Cache.arRegionROPFacc[pRegion];
            if (j>0) then prAddItemToIntArray(j, arFil);
          end else begin // если не задан округ - ищем по контрактам
            if not _FindFirm then Continue;
            SetLength(arFirmCodes, 0); // коды ЦФУ
            for j:= 0 to Firm.FirmContracts.Count-1 do begin // коды контрактов фирмы
              jj:= Firm.FirmContracts[j];
              if not Cache.Contracts.ItemExists(jj) then Continue;
              pRegion:= Cache.Contracts[jj].FacCenter;
              if (pRegion<1) then Continue;
              prAddItemToIntArray(pRegion, arFirmCodes); //  собираем коды ЦФУ
            end;
            for j:= 0 to High(arFirmCodes) do begin
              jj:= arFirmCodes[j]; // код ЦФУ
              if not Cache.FiscalCenters.ItemExists(jj) then Continue;
              facc:= Cache.FiscalCenters[jj];
              pRegion:= facc.ROPfacc;         // собираем коды ЦФУ РОП-ов
              if (pRegion>0) then prAddItemToIntArray(pRegion, arFil)
              else if facc.IsAutoSale then
                mess:= mess+fnIfStr(mess='', '', #13#10)+'Не найден ЦФУ РОП для ЦФУ '+facc.Name;
            end;
          end;

          for j:= 0 to High(arFil) do begin
            jj:= arFil[j];
            if not Cache.FiscalCenters.ItemExists(jj) then Continue;
            facc:= Cache.FiscalCenters[jj];
            if (facc.BKEempls.Count<1) then
              mess:= mess+fnIfStr(mess='', '', #13#10)+'Не найден сотрудник для ЦФУ '+facc.Name
            else for jj:= 0 to facc.BKEempls.Count-1 do begin
              EmplID:= facc.BKEempls[jj];
              if _FindEmpl then _AddEmplMail;
            end;
          end;
        end;

//      ceUIKdepartment: begin //--------------------------------------- Отдел УИК
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
{//========================================================= коды РОП-ов филиалов
function TDataCache.GetFilialROPcodes(var filials: Tai): Tai;
// возвращает найденные коды РОП-ов, в filials филиалы с найденными РОП-ами обнуляем
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
        if (j>-1) then filials[j]:= 0; // обнуляем филиалы с найденными РОП-ами
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
//===================================================== новое значение константы
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
    if ConstItem.StrValue=pValue then Exit; // значение не изменилось

    if ConstItem.NotEmpty and (pValue='') then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - значение не может быть пустым');

    try //------------------------------------------- проверяем значение по типу
      case ConstItem.ItemType of
      constInteger: iValue:= StrToInt(pValue);
      constDouble: begin
          pValue:= StrWithFloatDec(pValue); // проверяем DecimalSeparator
          StrToFloat(pValue);
        end;
      constDateTime: begin
          if ConstItem.Precision=0 then System.SysUtils.StrToDate(pValue)
          else System.SysUtils.StrToDateTime(pValue);
        end;
      end; // case
    except
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - значение='+pValue);
    end;

    if (pValue<>'') then case ConstItem.ID of //--- проверяем значение по смыслу
    pcUIKdepartmentMail, pcCheckDocMail: begin                  // адреса
        list:= fnSplit(',', pValue);
        try
          for i:= 0 to list.Count-1 do if not fnCheckEmail(list[i]) then
            raise EBOBError.Create(MessText(mtkNotValidParam)+' - значение='+list[i]);
        finally prFree(list); end;
      end;

    pcTestingSending1, pcTestingSending2, pcTestingSending3, // список кодов сотрудников
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

    pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto, pcEmplORDERAUTO: // код сотрудника
      if not EmplExist(iValue) then
        raise EBOBError.Create(MessText(mtkNotEmplExist, pValue));
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt; //------------------------------- пишем в базу
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);
      ORD_IBS.SQL.Text:= 'update SERVERPARAMCONSTANTS set SPCVALUE=:SPCVALUE, SPCUSERID='+
        IntToStr(pUserID)+' where SPCCODE='+IntToStr(csID)+' returning SPCTIME';
      if ConstItem.ItemType=constDouble then
        ORD_IBS.ParamByName('SPCVALUE').AsString:= fnSetDecSep(pValue, ConstItem.Precision) // для записи в базу '.'
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
    
    ConstItem.StrValue:= pValue; //--------------------------------- пишем в кеш
    ConstItem.LastUser:= pUserID;
    ConstItem.LastTime:= pLastTime;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
//============================================ проверить связь роли с константой
function TDataCache.CheckRoleConstLink(csID, roleID, UserID: Integer; flWrite: Boolean; var ResCode: Integer): String;
const nmProc = 'CheckRoleConstLink';
// вид операции - ResCode - на входе (resAdded, resEdited, resDeleted)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось,
//                    resAdded - добавлено, resEdited - изменено, resDeleted - удалено
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
    if not (OpCode in [resAdded, resEdited, resDeleted]) then       // проверяем код операции
      raise Exception.Create(MessText(mtkNotValidParam)+' операции');
    if not ConstExists(csID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' конст., код='+IntToStr(csID));
    if not RoleExists(roleID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' роли, код='+IntToStr(roleID));

    ConstItem:= FParConstants[csID];
    EmplRole:= FEmplRoles[roleID];
    iw:= fnIfInt(flWrite, 1, 0); // SrcID=1 - признак разрешения записи

    case OpCode of // проверяем связку
    resAdded: if EmplRole.ConstLinks.LinkExists(csID) then begin
        ResCode:= resDoNothing;
        if not ConstItem.Links.LinkExists(roleID) then  // на всяк.случай
          ConstItem.Links.CheckLink(roleID, iw, EmplRole);
        raise Exception.Create('Такая связка уже есть');
      end;
    resEdited: begin
        if not EmplRole.ConstLinks.LinkExists(csID) then
          raise Exception.Create(MessText(mtkNotFoundRecord));
        if (GetLinkSrc(EmplRole.ConstLinks[csID])=iw) then begin
          ResCode:= resDoNothing;
          if (GetLinkSrc(ConstItem.Links[roleID])<>iw) then // на всяк.случай
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

    ORD_IBD:= cntsOrd.GetFreeCnt;                             // пишем в базу
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

    Result:= 'связка роли с параметром';
    case OpCode of
    resAdded  : begin
        ConstItem.Links.CheckLink(roleID, iw, EmplRole);
        EmplRole.ConstLinks.CheckLink(csID, iw, ConstItem);
        Result:= Result+' добавлена';
      end;
    resEdited : begin
        TLink(ConstItem.Links[roleID]).SrcID:= iw;
        TLink(EmplRole.ConstLinks[csID]).SrcID:= iw;
        Result:= Result+' изменена';
      end;
    resDeleted: begin
        ConstItem.Links.DeleteLinkItem(roleID);
        EmplRole.ConstLinks.DeleteLinkItem(csID);
        Result:= Result+' удалена';
      end;
    end;  // case
    ResCode:= OpCode;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;
{//============================================ проверить связь роли с импортом
function TDataCache.CheckRoleImportLink(impID, roleID, UserID: Integer; flWrite: Boolean; var ResCode: Integer): String;
const nmProc = 'CheckRoleImportLink';
// вид операции - ResCode - на входе (resAdded, resEdited, resDeleted)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось,
//                    resAdded - добавлено, resEdited - изменено, resDeleted - удалено
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
    if not (OpCode in [resAdded, resEdited, resDeleted]) then       // проверяем код операции
      raise Exception.Create(MessText(mtkNotValidParam)+' операции');
    if not ImpTypeExists(impID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' импорта, код='+IntToStr(impID));
    if not RoleExists(roleID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' роли, код='+IntToStr(roleID));

    ImpItem:= FImportTypes[impID];
    EmplRole:= FEmplRoles[roleID];
    iw:= fnIfInt(flWrite, 1, 0); // SrcID=1 - признак разрешения записи

    case OpCode of // проверяем связку
    resAdded: if EmplRole.ImpLinks.LinkExists(impID) then begin
        ResCode:= resDoNothing;
        if not ImpItem.RoleLinks.LinkExists(roleID) then  // на всяк.случай
          ImpItem.RoleLinks.CheckLink(roleID, iw, EmplRole);
        raise Exception.Create('Такая связка уже есть');
      end;

    resEdited: begin
        if not EmplRole.ImpLinks.LinkExists(impID) then
          raise Exception.Create(MessText(mtkNotFoundRecord));
        if (GetLinkSrc(EmplRole.ImpLinks[impID])=iw) then begin
          ResCode:= resDoNothing;
          if (GetLinkSrc(ImpItem.RoleLinks[roleID])<>iw) then // на всяк.случай
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

    ORD_IBD:= cntsOrd.GetFreeCnt;                             // пишем в базу
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

    Result:= 'связка роли с импортом';
    case OpCode of
    resAdded: begin
        ImpItem.RoleLinks.CheckLink(roleID, iw, EmplRole);
        EmplRole.ImpLinks.CheckLink(impID, iw, ImpItem);
        Result:= Result+' добавлена';
      end;
    resEdited: begin
        TLink(ImpItem.RoleLinks[roleID]).SrcID:= iw;
        TLink(EmplRole.ImpLinks[impID]).SrcID:= iw;
        Result:= Result+' изменена';
      end;
    resDeleted: begin
        ImpItem.RoleLinks.DeleteLinkItem(roleID);
        EmplRole.ImpLinks.DeleteLinkItem(impID);
        Result:= Result+' удалена';
      end;
    end;  // case
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
end;   }
//=================================== проверка доступности удаления по источнику
function TDataCache.CheckLinkAllowDelete(srcID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(FDCA)
    or not FDCA.LinkSources.ItemExists(srcID) then Exit;
  Result:= TSubDirItem(FDCA.LinkSources[srcID]).OrderNum=0;
end;
//==================== проверка доступности пометки неверной связки по источнику
function TDataCache.CheckLinkAllowWrong(srcID: Integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) or not Assigned(FDCA)
    or not FDCA.LinkSources.ItemExists(srcID) then Exit;
  Result:= TSubDirItem(FDCA.LinkSources[srcID]).OrderNum=1;
end;
//================= заполнение/проверка линков групп/подгрупп с шаблонами скидок
procedure TDataCache.TestGrPgrDiscModelLinks;
const nmProc = 'TestGrPgrDiscModelLinks'; // имя процедуры/функции
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
        dm:= Cache.DiscountModels[dmID]; // шаблон
        if flNew then link:= nil
        else link:= gr.DiscModLinks.GetLinkListItemByID(dmID, lkLnkByID);

        if Assigned(link) then try // если линк есть - проверяем
          gr.CS_wlinks.Enter;
          if fnNotZero(disg-Link.Qty) then Link.Qty:= disg;
          if (Link.LinkPtr<>dm) then Link.LinkPtr:= dm;
          Link.State:= True; // флаг проверки
        finally
          gr.CS_wlinks.Leave;

        end else begin // создаем новый линк
          link:= TQtyLink.Create(0, disg, dm);
          gr.DiscModLinks.AddLinkListItem(link, lkLnkByID, gr.CS_wlinks);
        end;

        cntsGRB.TestSuspendException;
        ibs.Next;
      end; // while not ibs.Eof and (gID=
      if not flNew then gr.DiscModLinks.DelNotTestedLinks(gr.CS_wlinks); // удаляет все связки с State = False
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

//=========================================================== проверка кэша фирм
procedure TDataCache.TestFirms(pID: Integer; FillNew: boolean=False;
           CompareTime: boolean=True; Partially: boolean=False; RegID: Integer=0);
// CompareTime=True - проверять время последнего обновления, False - не проверять (ID>0)
// ID=-1 - по alter-таблицам, ID=0 - полная, ID>0 - по 1 фирме
// FillNew=True - заполнение новых, FillNew=False - проверка существующих
// Partially=True - частичная проверка(WebArm), Partially=False - полная проверка
// RegID>0 - проверка фирм регионала
const nmProc = 'TestFirms'; // имя процедуры/функции
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
//----------------------------------- заполнение/проверка списка контрактов фирм
  procedure TestFirmContracts(ppID: Integer; InCS: boolean);
  var fcode, ss, s1, s, sDests, n: string;
      i, cc, sys, j, iState, cpID, cpContCount, cpDelay, cpCurr: Integer;
      fl, flFirmSaleBlocked, flProfBlocked, flFillProf: boolean;
      arFC, arFM, arFS, arDP: Tai;
      Item: Pointer;
      sum, cpDebt, cpLimit: Double;
  //------------------------------ заполнение/проверка списка торговых точек к/а
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
            n:= fnReplaceQuotedForWeb(n); // переводит кавычки ' и " в `
            s:= ibs1.FieldByName('rDestAdr').AsString;
            s:= fnReplaceQuotedForWeb(s); // переводит кавычки ' и " в `

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
      TestFirmDestPoints;  // заполнение/проверка списка торговых точек к/а

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

      if not firma0.PartiallyFilled then  // полная проверка - фин.инфо, торг.точки контракта
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

      setLength(arFC, 0); // коды контрактов фирмы
      setLength(arFS, 0); // коды систем учета фирмы
      setLength(arFM, 0); // коды менеджеров фирмы
      setLength(arDP, 0); // коды торг.точек контракта
      fcode:= IntToStr(ppID);
      DateTemp:= IncMonth(EncodeDate(CurrentYear, CurrentMonth, 1), -1); // начало прошлого м-ца
      flFirmSaleBlocked:= False;
      ibs.Close;                        // тек.дата >= дате заключения контракта
      ibs.SQL.Text:= s1+' where CONTSECONDPARTY='+fcode+' and CONTBEGININGDATE<="TODAY"'+// ' and CONTTYPE=9' // Тип - договор купли-продажи
                     ' and contfirstparty=(select userfirmcode from userpsevdonimreestr where usercode=1)'+
                     ' order by condprofile';

      with ibs.Transaction do if not InTransaction then StartTransaction;
      ibs.ExecQuery;
      while not ibs.Eof do begin
        cpID:= ibs.FieldByName('condprofile').AsInteger; // профиль
        cpContCount:= 0; // счетчик контрактов в профиле
        cpDelay:= 0;
        cpLimit:= 0;
        cpDebt:= 0;
        flProfBlocked:= False; // флаг блокировки хоть одного контракта профиля
        cpCurr:= cDefCurrency;
        flFillProf:= True; // флаг для запоминания кред.условий профиля 1 раз
        while not ibs.Eof and (cpID=ibs.FieldByName('condprofile').AsInteger) do begin
          DateBeg:= ibs.FieldByName('CONTBEGININGDATE').AsDateTime;
          DateEnd:= ibs.FieldByName('CONTENDINGDATE').AsDateTime;
          iState:= ibs.FieldByName('CONTSTATE').AsInteger; // 2= "действует"
          fl:= False;
          if AllowWebArm then fl:= (DateEnd<Date) or (iState<>2); // WebArm - закрытый контракт
          if AllowWeb then fl:= (DateEnd<DateTemp); // Web - окончание ранее начала прошлого м-ца

          if fl and not firma0.PartiallyFilled then      // нет долгов/переплат
            fl:= not fnNotZero(ibs.FieldByName('rDebtSum').AsFloat);

          if fl then begin
            ibs.Next;                  // пропускаем закрытые без долгов/переплат
            Continue;
          end;

          cc:= ibs.FieldByName('CONTCODE').AsInteger;
          ss:= ibs.FieldByName('CONTNUMBER').AsString;
          sys:= 0;
          fl:= Contracts.ItemExists(cc);
          if not fl then begin // новый контракт
            Item:= TContract.Create(cc, ppID, sys, ss); // Contract.Status:= cstUnKnown;
            Contracts.CheckItem(Item);
          end;
          Contract:= Contracts[cc];
          Contract.CS_cont.Enter;
          try // заполняем/проверяем параметры контракта
            if fl then begin  // в существующем проверяем параметры Create
              Contract.ContFirm:= ppID;
              Contract.Name:= ss;
            end;
            if (DateEnd<Date) or (iState<>2) then  // признак недоступного контракта
              Contract.Status:= cstClosed;
            if (Contract.ContBegDate<>DateBeg) then Contract.ContBegDate:= DateBeg;
            if (Contract.ContEndDate<>DateEnd) then Contract.ContEndDate:= DateEnd;
            Contract.CredProfile:= cpID;

            if not firma0.PartiallyFilled then begin // полная проверка - фин.инфо
              Contract.DebtSum     := ibs.FieldByName('rDebtSum').AsFloat;   // долг
              Contract.RedSum      := ibs.FieldByName('rRedSum').AsFloat;    // просроченные оплаты
              Contract.VioletSum   := ibs.FieldByName('rVioletSum').AsFloat; // истекающие оплаты
              Contract.WarnMessage := ibs.FieldByName('rWarnMessage').AsString;
              Contract.WhenBlocked := ibs.FieldByName('rWhenBlocked').AsInteger;
              Contract.SaleBlocked:= (ibs.FieldByName('rSaleBlocked').AsInteger=1);
              flFirmSaleBlocked:= flFirmSaleBlocked or Contract.SaleBlocked;
              flProfBlocked:= flProfBlocked or Contract.SaleBlocked;

              if (Contract.Status=cstClosed) then begin // недоступный контракт
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
              //---------------------------------------- коды торг.точек контракта
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
                Contract.ContDestPointCodes.Add(j);  // порядок ???
              end;
              setLength(arDP, 0);
              //----------------------------------------
              i:= ibs.FieldByName('rContCreditCrnc').AsInteger;
              if (i<1) then begin
                if firma0.IsFinalClient then i:= cUAHCurrency else i:= cDefCurrency;
              end;
              Contract.CredCurrency:= i;
//-------------------------
              cpDebt:= cpDebt+Contract.DebtSum; // долг по профилю
              if flFillProf and                      // кред.усл.профиля - 1 раз
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
            i:= 0; // только по BKE
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
            prAddItemToIntArray(cc, arFC);      // собираем коды контрактов фирмы
            With Contract.GetContBKEempls do for i:= 0 to Count-1 do
              prAddItemToIntArray(Items[i], arFM); // добавляем коды менеджеров ЦФУ по BKE
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
          flFillProf:= not assigned(prof); // признак нового профиля
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
              if not flFillProf then begin // проверяем не-новый профиль
                if fnNotZero(prof.FProfDebtAll-cpDebt) then prof.FProfDebtAll:= cpDebt;
                if fnNotZero(prof.FProfCredLimit-cpLimit) then prof.FProfCredLimit:= cpLimit;
                if (prof.FProfCredDelay<>cpDelay) then prof.FProfCredDelay:= cpDelay;
                if (prof.FProfCredCurrency<>cpCurr) then prof.FProfCredCurrency:= cpCurr;
                prof.State:= True;
              end;                 // блокируем профиль по превыш.кредита
              if (prof.FProfCredLimit>0) and (prof.FProfDebtAll>prof.FProfCredLimit) then begin
                prof.Blocked:= True;
                prof.FName:= 'Превышен кредит';
//              end else if flProfBlocked then begin // блокируем по блокировке контракта
//                prof.Blocked:= True;
//                prof.FName:= '';
//                prof.FName:= 'Отгрузка запрещена';  // ???
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
        prCheckIntegerListByCodesArray(firma0.FirmContracts, arFC); // сверить TIntegerList с массивом кодов
        if (firma0.FirmContracts.Count>1) then firma0.FirmContracts.Sort;  // ???
        prCheckIntegerListByCodesArray(firma0.FirmManagers, arFM);  // сверить TIntegerList с массивом кодов

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
//------------------------------------ заполнение/проверка списка категорий фирм
  procedure TestFirmClasses(ppID: Integer=0; pRegID: Integer=0); // ppID=0 - все существующие
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
      if pID>0 then begin // 1 фирма
        fcode:= IntToStr(ppID);
        ibsGB.SQL.Text:= 'select FRGRFIRMCODE, FRGRCLASSCODE from FIRMGROUP'+
          ' where FRGRFIRMCODE='+fcode+' and FRGRFIRMARCHIVE="F" and FrGrArchived="F"';

      end else if (pRegID>0) then begin // фирмы регионала
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

      end else begin // все
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

          j:= 0; // счетчик категорий фирмы
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
      //----------------------- VIN запросы, скачивание прайса, загрузка заказов
      if (ppID>0) then begin
        if FirmExist(ppID) then with arFirmInfo[ppID] do begin
          HasVINmail:= CheckFirmVINmail;
          EnablePriceLoad:= CheckFirmPriceLoadEnable;
          EnableOrderImport:= flOrderImport and CheckFirmOrderImportEnable;
          ShowZeroRests:= CheckShowZeroRests; // (Ирбис)
        end;
      end else for j:= 0 to High(arFirmInfo) do begin
        if not FirmExist(j) then Continue;
        firma:= arFirmInfo[j];
        if ((pRegID>0) and not firma.CheckFirmManager(pRegID)) then Continue;
        with firma do begin
          ff:= CheckFirmVINmail;
          ff1:= CheckFirmPriceLoadEnable;
          ff2:= flOrderImport and CheckFirmOrderImportEnable;
          ff3:= CheckShowZeroRests; //  (Ирбис)
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

      //----------------------- текущие шаблоны скидок и обороты по направлениям
      if pID>0 then s:= IntToStr(ppID)+', 0' // 1 фирма
      else if (pRegID>0) then s:= '0, '+IntToStr(pRegID) // фирмы регионала
      else s:= '0, 0'; // все
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
          j:= 0; // счетчик направлений
          SetLengthArrs(10);
          while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger) do begin
            if High(ar)<j then SetLengthArrs(j+10);
            ar[j]:= ibsGB.FieldByName('rProdDirect').AsInteger; // код направления
            ar1[j]:= ibsGB.FieldByName('rDiscModel').AsInteger; // код шаблона
            sums[j]:= ibsGB.FieldByName('rSumm').AsFloat;       // текущий оборот к/а
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
                ff:= (tt.ID1=ar[j]); // проверяем код направления
                if ff then break;
              end;
              if ff then begin
                if (tt.ID2<>ar1[j]) then tt.ID2:= ar1[j];           // проверяем код шаблона
                if fnNotZero(tt.Qty-sums[j]) then tt.Qty:= sums[j]; // проверяем текущий оборот к/а
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

      //---------------------------------- юрид.фирмы к/а, Object - TBaseDirItem
      if pID>0 then  // 1 фирма
        ibsGB.SQL.Text:= 'select LgEnCode, LgEnFirmCode, fl.firmmainname LgEnFullName'+
          ' from LegalEntities'+
          ' inner join firms fl on fl.firmcode=LgEnEntityFirmCode and fl.FirmOrganizationType=1'+
          ' where LgEnFirmCode='+fcode
      else if (pRegID>0) then  // фирмы регионала
        ibsGB.SQL.Text:= 'select LgEnCode, LgEnFirmCode, fl.firmmainname LgEnFullName '#10+sSQLreg+
          ' inner join LegalEntities on LgEnFirmCode=f.Firm'+
          ' inner join firms fl on fl.firmcode=LgEnEntityFirmCode and fl.FirmOrganizationType=1'
      else  // все
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
              s:= fnReplaceQuotedForWeb(s); // переводит кавычки ' и " в `
              ff:= False;
              for j:= 0 to firma.LegalEntities.Count-1 do begin
                le:= TBaseDirItem(firma.LegalEntities[j]);
                ff:= (le.ID=i);
                if ff then begin // нашли - проверяем
                  le.Name:= s;
                  le.State:= True;
                  break;
                end;
              end; // for j
              if not ff then begin // не нашли - добавляем
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
//------------------------------- заполнение/проверка списков складов контрактов
  procedure TestContractStores(ppID: Integer=0; pRegID: Integer=0); // ppID=0 - все существующие
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
      if (pID>0) then begin // 1 фирма
        fcode:= IntToStr(ppID);
        sParam:= fcode+', 0';
      end else if (pRegID>0) then begin // фирмы регионала
        sParam:= IntToStr(pRegID);
        fcode:= 'RegID='+sParam;
        sParam:= '0, '+sParam;
      end else begin // все фирмы
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

          j:= 0; // счетчик складов
          setLength(ar, 0);
          Contract.CS_cont.Enter;
          try
            while not ibsGB.Eof and (fid=ibsGB.FieldByName('rFirmCode').AsInteger)
              and (cid=ibsGB.FieldByName('rContCode').AsInteger) do begin
              sid:= ibsGB.FieldByName('rDprtCode').AsInteger;
//--------------------------------------------------------- старая схема складов
              if GetBoolGB(ibsGB, 'rOrdProc') then begin
                jj:= Length(ar);      // склады филиалов обработки счетов
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
                  IsAddVis:= GetBoolGB(ibsGB, 'rAddVis'); // склад доп.видимости
                end;
                inc(j);
              end; // if GetBoolGB

              cntsGRB.TestSuspendException;
              ibsGB.Next;
            end;
                                                  // если какой-то склад закрыли
            Contract.TestStoreArrayLength(taCurr, j, false, not (ff and flAll and flReg));
            jj:= Length(ar);
            Contract.TestStoreArrayLength(taDprt, jj, false, not (ff and flAll and flReg));
            for jj:= Low(ar) to High(ar) do // склады филиалов обработки счетов
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

        if AllowWeb then begin //---------------- проверяем контракт unit-заказа
          cid:= firma.ContUnitOrd;
          flAdd:= (cid>0) and (not firma.CheckContract(cid)
                  or (Cache.Contracts[cid].Status<=cstClosed));
          if flAdd then begin // если контракт unit-заказа устарел (закрыт и т.п.)
            Contract:= firma.GetAvailableContract; // найти действующий контракт фирмы (желательно наличный)
            if Assigned(Contract) then cid:= Contract.ID else cid:= 0;
            if (cid>0) then try try // меняем контракт unit-заказа
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
//-------------------------------------- проверка параметров фирмы из Grossbee
  procedure TestFirmDataFromGrossbee(jj: integer; new: boolean; InCS: boolean=True);
  var ss: string;
  begin
//    if not FirmExist(jj) then Exit;
    with firma0 do begin
      if InCS then CS_firm.Enter;
      try
        ss:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('FIRMUPPERMAINNAME').AsString);
        ss:= fnReplaceQuotedForWeb(ss); // переводит кавычки ' и " в `
        UPPERMAINNAME:= ss;
        UPPERSHORTNAME:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('FIRMUPPERSHORTNAME').AsString);
        ss:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('FIRMMAINNAME').AsString);
        ss:= fnReplaceQuotedForWeb(ss); // переводит кавычки ' и " в `
        if new or (Name<>ss) then Name:= ss;
                                      // меняем только с частичной на полную !!!
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
        IsFinalClient:= GetBoolGB(ibsGB, 'PMFirmFinalClient'); // признак конечного клиента
      finally
        if InCS then CS_firm.Leave;
      end;
      TestFirmContracts(jj, InCS); // контракты фирмы (+ менеджеры, системы учета)
      LastTestTime:= Now;
    end;
  end;
//-------------------------------------- проверка параметров фирмы из ib_ord
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
//--------------------- признак необходимости проверки фирмы
  function FirmNeedTesting(jj: integer): boolean;
  begin // если полная проверка, а фирма заполнена частично - CompareTime не учитываем
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
      ibs:= fnCreateNewIBSQL(ibdGB, 'ibs_'+nmProc+'_'+FirmCode); // для TestFirmContracts
      ibs1:= fnCreateNewIBSQL(ibdGB, 'ibs1_'+nmProc+'_'+FirmCode); // для TestFirmDestPoints
      ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc+'_'+FirmCode, -1, tpRead, True);
      if Length(arFirmInfo)<2 then begin  // при первом обращении
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
        ' f.PMFirmFinalClient,'+  // признак конечного клиента UBER
        ' f.FIRMARCHIVEDKEY, f.FIRMUPPERSHORTNAME, f.FirmSendInvoice, f.FirmOrderLimit,'+
        ' iif(f.firmhostcode is null, f.FirmCode, f.firmhostcode) HOSTCODE,'+
        ' RClTpCode FirmType, br.bnrssumm, (select sum(rPInvSumm) from'+
        '   Vlad_CSS_GetFirmReserveDocsN(f.FirmCode, 0) where rPInvCrnc='+s+') UnitReserve'+
        fnIfStr(Partially, // при not Partially вычисляется в TestFirmContracts
        ', (select sum(ResultValue) from Vlad_CSS_GetFirmReserveDocsN(f.FirmCode, 0)'+
        '  left join ConvertMoney(rPInvSumm, rPInvCrnc, '+cStrDefCurrCode+', "Now") on 1=1'+
        '  where rPInvCrnc<>'+s+') Reserve', '')+
        ' from FIRMS f left join GETFIRMCLIENTTYPE(f.firmcode, "TODAY") on 1=1'+
        ' left join BONUSREST br on br.bnrsfirmcode=f.firmcode and br.bnrssubfirmcode=1'+
        ' where f.FirmServiceFirm="F" and f.FirmOrganizationType=0'+ // признак "Технический клиент"
        '   and (f.firmchildcount=0 or not exists(select * from firms ff'+
        '   where ff.firmmastercode=f.firmcode and ff.FirmOrganizationType=0 and ff.FIRMARCHIVEDKEY="F"))';
      cntsGRB.TestSuspendException;

  //--------------------------------------- по alter-таблицам  // пока не работает
      if pID<0 then begin

  //------------------------------------------------------ проверка по всем фирмам
      end else if (pID=0) and (RegID<1) then begin
        ibsGB.SQL.Text:= sSqlGb+' order by FIRMMAINNAME';
        ibsGB.ExecQuery;                      // идем по фирмам Grossbee
        while not ibsGB.Eof do begin
          FirmID:= ibsGB.fieldByName('FIRMCODE').AsInteger;
          flnew:= FillNew and not FirmExist(FirmID);
          if TestCacheArrayItemExist(taFirm, FirmID, flnew) and FirmNeedTesting(FirmID) then begin
              firma0:= arFirmInfo[FirmID];
              TestFirmDataFromGrossbee(FirmID, flnew); // проверка параметров фирмы из Grossbee
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
            TestFirmDataFromWebTables(FirmID); // существующий объект проверяем
          end;
          cntsORD.TestSuspendException;
          ibsOrd.Next;
        end;
        ibsOrd.Close;

        TestFirmClasses(pID); // категории фирм, VIN запросы
        TestContractStores(pID); // склады контрактов фирм

        prMessageLOGS(nmProc+'_'+FirmCode+' '+IntToStr(iCount)+' к/а: - '+
          GetLogTimeStr(LocalStart)+fnIfStr(Partially, ' Partially', ''), fLogCache, false);

  //------------------------------------------------- проверка по фирмам регионала
      end else if (pID=0) and (RegID>0) then begin
        ibsGB.SQL.Text:= sSqlGb+' order by FIRMMAINNAME';
        ibsGB.ExecQuery;                      // идем по фирмам Grossbee
        while not ibsGB.Eof do begin
          FirmID:= ibsGB.fieldByName('FIRMCODE').AsInteger;
          flnew:= FillNew and not FirmExist(FirmID);
          if TestCacheArrayItemExist(taFirm, FirmID, flnew) and FirmNeedTesting(FirmID) then begin
            firma0:= arFirmInfo[FirmID];
            TestFirmDataFromGrossbee(FirmID, flnew); // проверка параметров фирмы из Grossbee
            if length(firma0.FirmClients)>0 then
//              TestClients(firma0.FirmClients[0], FillNew, CompareTime, Partially); // проверяем клиентов фирмы
              TestClients(firma0.FirmClients[0], FillNew, CompareTime, firma0.PartiallyFilled); // проверяем клиентов фирмы
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
              TestFirmDataFromWebTables(FirmID); // существующий объект проверяем
          end;
          cntsORD.TestSuspendException;
          ibsOrd.Next;
        end;
        ibsOrd.Close;

        TestFirmClasses(pID, RegID);      // категории фирм регионала, VIN запросы
        TestContractStores(pID, RegID); // склады контрактов фирм регионала

        prMessageLOGS(nmProc+'_'+FirmCode+' '+IntToStr(iCount)+'к/а: - '+
          GetLogTimeStr(LocalStart)+fnIfStr(Partially, ' Partially', ''), fLogCache, false);

  //------------------------------------------------------------- проверка 1 фирмы
      end else begin
        flnew:= FillNew and not FirmExist(pID); // если 1 фирма
        if TestCacheArrayItemExist(taFirm, pID, flnew) then begin
          firma0:= arFirmInfo[pID];
          if (flnew or not CompareTime or (not Partially and firma0.PartiallyFilled) or
            (Now>IncMinute(firma0.LastTestTime, FirmActualInterval))) then try

            firma0.CS_firm.Enter; // проверка - внутри CS_firm !!!
            ibsGB.SQL.Text:= sSqlGb+' and f.FIRMCODE='+FirmCode;
            ibsGB.ExecQuery;
            if not (ibsGB.Bof and ibsGB.Eof) then begin
              PrevPartFilled:= firma0.PartiallyFilled; // запоминаем предыдущее состояние
              TestFirmDataFromGrossbee(pID, flnew, false); // проверка параметров фирмы из Grossbee
            end else PrevPartFilled:= False;
            ibsGB.Close;

            cntsORD.TestSuspendException;
            ibsOrd.SQL.Text:= sSqlOrd+' where WOFRCODE='+FirmCode;
            ibsOrd.ExecQuery;
            if not (ibsOrd.Bof and ibsOrd.Eof) then
              TestFirmDataFromWebTables(pID, false); // существующий объект проверяем
            ibsOrd.Close;

            if flnew or PrevPartFilled or cntsGRB.NotManyLockConnects then begin // если заполнение или не перегружен пул
              TestFirmClasses(pID); // категории фирмы, VIN запросы
              TestContractStores(pID); // склады контрактов фирмы
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
      SetLength(arFirmInfo, ii); // обрезаем по мах.коду
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
//======================================================= проверка кэша клиентов
procedure TDataCache.TestClients(pID: Integer; FillNew: boolean=False;
          CompareTime: boolean=True; Partially: boolean=False; pFirm: Integer=0);
// CompareTime=True - проверять время последнего обновления, False - не проверять (ID>0)
// ID=-1 - по alter-таблицам, ID>0 - 1 клиент, ID=0 - все клиенты (после проверки всех фирм !!!)
// FillNew=True - заполнение новых, FillNew=False - проверка только существующих
// Partially=True - частичная проверка(АРМ), Partially=False - полная проверка
const nmProc = 'TestClients'; // имя процедуры/функции
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
//-------------------------------------- проверка параметров клиента из Grossbee
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
      Post:= fnReplaceQuotedForWeb(Post); // переводит кавычки ' и " в `
      Name:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('PRSNNAME').AsString);
      Name:= fnReplaceQuotedForWeb(Name); // переводит кавычки ' и " в `
//if flDebug then
//  prMessageLOGS(fnMakeAddCharStr(Name, 50, True)+' - CheckResult= '+CheckClientFIO(Name), fLogDebug, False);
      FirmID  := ibsGB.fieldByName('PRSNFIRMCODE').AsInteger;
      fl:= GetBoolGB(ibsGB, 'PRSNARCHIVEDKEY');
      if (Arhived<>fl) then Arhived:= fl;
      fl:= GetBoolGB(ibsGB, 'PrSnForPay');
      if (CliPay<>fl) then CliPay:= fl;
      //------------------------------------------------------------ Email-ы
      s:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('Mails').AsString);
      lst:= fnSplit(cSplitDelim, s);
      CheckStringList(CliMails, Lst);
      DelEmptyStrings(CliMails); // чистка пустых строк
      Lst.Clear;
      //------------------------------------------------------------ телефоны
      s:= fnChangeEndOfStrBySpace(ibsGB.fieldByName('PHONEs').AsString);
      lst:= fnSplit(cSplitDelim, s);
      for i:= 0 to lst.Count-1 do begin
        j:= pos('=', lst[i]); // строка 1 телефона
        if (j>0) then begin
          strSMS:= copy(lst[i], j+1, length(lst[i]));  // коды SMS-шаблонов
          lst[i]:= copy(lst[i], 1, j-1);               // обрезаем коды
        end else strSMS:= '';
{if flDebug then
  if CheckMobileNumber(lst[i]) then
    prMessageLOGS(nmProc+':     mobile = '+lst[i], fLogDebug, False)
  else
    prMessageLOGS(nmProc+': not mobile = '+lst[i], fLogDebug, False); }
        j:= CliPhones.IndexOf(lst[i]);
        if (j<0) then begin // не нашли - добавляем телефон
          if (strSMS<>'') then iList:= fnStrToIntegerList(strSMS) // TIntegerList из строки кодов через запятую
          else iList:= TIntegerList.Create;
          CliPhones.AddObject(lst[i], iList);
        end else begin // нашли - проверяем SMS-шаблоны
          if not Assigned(CliPhones.Objects[i]) then
            CliPhones.Objects[i]:= TIntegerList.Create;
          iList:= TIntegerList(CliPhones.Objects[i]);
          prCheckIntegerListByCodesString(iList, strSMS); // сверить TIntegerList со строкой кодов
        end;
      end; // for i:= 0 to lst.Count
      for i:= CliPhones.Count-1 downto 0 do begin
        j:= lst.IndexOf(CliPhones[i]);
        if (j>-1) then begin
          lst.Delete(j);
          Continue;
        end;
        obj:= CliPhones.Objects[i];
        CliPhones.Delete(i);                // удаляем лишние
        if Assigned(obj) then prFree(obj);
      end; // for i:= CliPhones.Count
      DelEmptyStrings(CliPhones, True); // чистка пустых строк (with free Objects)
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
//                                    // меняем только с частичной на полную !!!
//      if not Partially and PartiallyFilled then PartiallyFilled:= Partially;
      PartiallyFilled:= Partially;
      LastTestTime:= Now;
    finally
      if InCS then CS_client.Leave;
      prFree(lst);
    end;
  end;
//-------------------------------------- проверка параметров клиента из ib_ord
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
      CheckBlocked(); // проверка блокировки
      LastContract:= ibsOrd.fieldByName('woclLastContract').AsInteger;
      if not Partially then begin // если полная
        if Firma.IsFinalClient then begin
          SearchCurrencyID:= cUAHCurrency; // задать валюту (грн)
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
      if not Partially and       // если полная проверка
        (new or PrevPartFilled or cntsGRB.NotManyLockConnects) then begin // если заполнение или не перегружен пул
        UpdateStorageOrderC;
      end;
      CheckWorkLogins(ID, Login); // проверка логина в списке поиска логинов
      LastTestTime:= Now;
    finally
      if InCS then CS_client.Leave;
    end;
  end;
//--------------------- признак необходимости проверки клиента
  function ClientNeedTesting(ii: integer): boolean;
  begin // если полная проверка, а клиент заполнен частично - CompareTime не учитываем
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
  iCount:= 0;  // счетчик
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
    prMessageLOGS(nmProc+': ---------- start', fLogDebug, false); // пишем в log
    LocStart:= now();
end;

  try try
    ibdOrd:= cntsORD.GetFreeCnt;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': cntsORD.GetFreeCnt - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;
    ibdGB:= cntsGRB.GetFreeCnt;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': cntsGRB.GetFreeCnt - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;

    ibsOrd:= fnCreateNewIBSQL(ibdOrd, 'ibsOrd_'+nmProc+'_'+UserCode, -1, tpRead, True);
    ibsGB:= fnCreateNewIBSQL(ibdGB, 'ibsGB_'+nmProc+'_'+UserCode, -1, tpRead, True);

    if (arClientInfo.MaxIndex<2) then begin // при первом обращении
                                            // вычисляем диапазон пропущенных кодов
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
      // структура строки: phone1=smsmodel11,smsmodel12,...~phone2=smsmodel12,smsmodel22,...
      ' (select LIST(PPHPHONE||iif(exists(select * from PERSONPHONESSMSMODELLINK'+
      '   where psmlpersonphonecode=pphcode), "="||(select list(psmlsmsmodel, ",")'+
      '   from PERSONPHONESSMSMODELLINK where psmlpersonphonecode=pphcode), ""), "'+
      cSplitDelim+'") from PERSONPHONES'+
      ' where PPHPERSONCODE=PRSNCODE and PPHARCHIVEDKEY="F") PHONEs from PERSONS';

//------------------------------------------------------------ по alter-таблицам
    if pID<0 then begin

//------------------------------------------------------------------ все клиенты
    end else if (pID=0) and (pFirm=0) then begin
      ibsGB.SQL.Text:= sSQLgb+
        ' inner join FIRMS on FIRMCODE=PRSNFIRMCODE and FirmOrganizationType=0'+
        ' and (firmchildcount=0 or not exists(select * from firms ff'+
        '   where ff.firmmastercode=firmcode and ff.FirmOrganizationType=0))'+
        ' order by PRSNFIRMCODE';
      ibsGB.ExecQuery;                     // проверяем параметры из Grossbee
      setlength(codes, 100);
      if not ((ibsGB.Bof and ibsGB.Eof)) then repeat
        pFirmID:= ibsGB.fieldByName('PRSNFIRMCODE').AsInteger;
        j:= 0; // счетчик клиентов фирмы
        if not FirmExist(pFirmID) then begin
          TestCssStopException;
          while not ibsGB.Eof and (pFirmID=ibsGB.fieldByName('PRSNFIRMCODE').AsInteger) do ibsGB.Next;
        end else begin
          Firma:= arFirmInfo[pFirmID];
          Firma.CS_firm.Enter; // блокируем фирму, чтобы не лезли другие ее сотрудники
          try
            while not ibsGB.Eof and (pFirmID=ibsGB.fieldByName('PRSNFIRMCODE').AsInteger) do begin
              i:= ibsGB.fieldByName('PRSNCODE').AsInteger;
              flnew:= FillNew and not ClientExist(i); // признак первоначального заполнения
              if TestCacheArrayItemExist(taClie, i, flnew)
                and (flnew or ClientNeedTesting(i)) then begin
                Client:= arClientInfo[i];
                TestClientDataFromGrossbee(Client, flnew); // проверка параметров клиента из Grossbee
                if not Client.Arhived then begin  // если неархивный сотрудник
                  if High(codes)>j then SetLength(codes, j+100);
                  codes[j]:= i;
                  inc(j);
                end;
                inc(iCount);
              end;
              cntsGRB.TestSuspendException;
              ibsGB.Next;
            end; // while not ibsGB.Eof and (FirmID=ibsGB.fieldByName('PRSNFIRMCODE').AsInteger)
            Firma.TestFirmClients(codes, j, false); // проверяем список кодов сотрудников фирмы
          finally
            Firma.CS_firm.Leave;
          end;
        end;
      until ibsGB.Eof;
      ibsGB.Close;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': ibsGB read (all) - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;

      ibsOrd.SQL.Text:= sSQLord;
      ibsOrd.ExecQuery;                            // проверяем параметры из ib_ord
      while not ibsOrd.Eof do begin
        i:= ibsOrd.fieldByName('WOCLCODE').AsInteger; // существующий объект проверяем
        if ClientExist(i)  then begin
          Client:= arClientInfo[i];
          if FirmExist(Client.FirmID) then begin
            Firma:= arFirmInfo[Client.FirmID];
            TestClientDataFromWebTables(Client); // проверка параметров клиента из ib_ord
            if (Client.FirmID<>ibsOrd.fieldByName('WOCLFIRMCODE').AsInteger) then begin
              j1:= Length(Change); // запоминаем, кого надо изменить в ib_ord
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
    prMessageLOGS(nmProc+': ibsOrd read (all) - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;
      prMessageLOGS(nmProc+'_'+UserCode+' '+IntToStr(iCount)+' кл: - '+
        GetLogTimeStr(LocalStart)+fnIfStr(Partially, ' Partially', ''), fLogCache, false);

//------------------------------------------------------------- клиенты 1 фирмы
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

      j:= 0; // счетчик клиентов фирмы
      if FirmExist(pFirmID) then begin        // проверяем всех по фирме
        Firma:= arFirmInfo[pFirmID];
        ibsOrd.SQL.Text:= sSQLord+' where WOCLCODE=:WOCLCODE';
        ibsOrd.Prepare;
        ibsGB.SQL.Text:= sSQLgb+' WHERE PRSNFIRMCODE='+s;
        Firma.CS_firm.Enter; // блокируем фирму, чтобы не лезли другие ее сотрудники
        try
          ibsGB.ExecQuery;                   // проверяем параметры из Grossbee
          while not ibsGB.Eof do begin
            i:= ibsGB.fieldByName('PRSNCODE').AsInteger;
            flnew:= FillNew and not ClientExist(i); // признак первоначального заполнения
            if TestCacheArrayItemExist(taClie, i, flnew)
              and (flnew or ClientNeedTesting(i)) then begin
              Client:= arClientInfo[i];
              try
                Client.CS_client.Enter;
                TestClientDataFromGrossbee(Client, flnew, false); // проверка параметров клиента из Grossbee
                if not Client.Arhived then begin  // если неархивный сотрудник
                  if High(codes)>j then SetLength(codes, j+100);
                  codes[j]:= i;
                  inc(j);
                end;
                ibsOrd.ParamByName('WOCLCODE').AsInteger:= i;
                ibsOrd.ExecQuery;
                if not (ibsOrd.Bof and ibsOrd.Eof) then begin
                  TestClientDataFromWebTables(Client, flnew, false); // проверка параметров клиента из ib_ord
                  if (pFirmID<>ibsOrd.fieldByName('WOCLFIRMCODE').AsInteger) then begin
                    j1:= Length(Change); // запоминаем, кого надо изменить в ib_ord
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
          Firma.TestFirmClients(codes, j, false); // проверяем список кодов сотрудников фирмы
        finally
          Firma.CS_firm.Leave;
        end;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': (firm '+IntToStr(pFirmID)+') - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;
      end; // if FirmExist(FirmID)
    end;
    arClientInfo.CutEmptyCode;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+'_'+UserCode+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
  end;

  if length(Change)>0 then try  // если есть изменения в ib_ord
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
    prMessageLOGS(nmProc+': ibsOrd write - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
//    LocStart:= now();
end;

  except
    on E: Exception do prMessageLOGS(nmProc+'_'+UserCode+': '+E.Message, fLogCache);
  end;
  finally
    prFreeIBSQL(ibsGB);     // отпускаем коннекты Grossbee
    cntsGRB.SetFreeCnt(ibdGB);
    prFreeIBSQL(ibsOrd);     // отпускаем коннект ib_ord
    cntsORD.SetFreeCnt(ibdOrd);
    setlength(Change, 0);
    setlength(codes, 0);
  end;
  TestCssStopException;
end;
//========================================= Загрузка / обновление файлов товаров
procedure TDataCache.FillWareFiles(fFill: Boolean=True);
const nmProc = 'FillWareFiles'; // имя процедуры/функции/потока
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
    CheckLength;  // DelDirNotTested - после проверки связок
    s:= IntToStr(iCount)+' файлов, ';

    iCount:= 0;
    ORD_IBS.SQL.Text:= 'select LWGFWGFCODE, LWGFWareID, LWGFLinkURL, LWGFSRCLECODE'+
      ' from LinkWareGraFiles inner join WareOptions on wowarecode=LWGFWareID and WOARHIVED="F"'+
       ' where LWGFWRONG="F" order by LWGFWareID';
    ORD_IBS.ExecQuery;
    while not ORD_IBS.Eof do begin
      wareID:= ORD_IBS.FieldByName('LWGFWareID').AsInteger; // Код товара
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
        fileID:= ORD_IBS.FieldByName('LWGFWGFCODE').AsInteger; // Код файла
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
            if not TDirItem(p).State then TDirItem(p).State:= True; // на всяк случай
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
    if not fFill then DelDirNotTested; // после проверки связок
  finally
    prFreeIBSQL(ORD_IBS);
    cntsOrd.SetFreeCnt(ORD_IBD);
  end;
  except
    on E: EBOBError do raise EBOBError.Create(nmProc+': '+E.Message);
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
//  prMessageLOGS(nmProc+': '+IntToStr(iCount)+' файлов - '+GetLogTimeStr(TimeProc), fLogCache, false);
  prMessageLOGS(nmProc+': '+s+IntToStr(iCount)+' св. - '+GetLogTimeStr(TimeProc), fLogCache, false);
  TestCssStopException;
end;
//=============================== заполнение/проверка связок с остатками товаров
procedure TDataCache.TestWareRests(CompareTime: boolean=True);
const nmProc = 'TestWareRests'; // имя процедуры/функции/потока
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
  if not (AllowWeb or AllowWebArm) then Exit; // только Web или WebArm
  flFill:= (LastTestRestTime=DateNull);
  if flFill then ss:= '_fill'
  else begin                              // если рано проверять
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
{ используются: 95515 - направление "Реклама" }

    if AllowWebArm then sDprts:= '1' else sDprts:= '0'; // склады и пути или только склады

    if flFill then begin // заполнение - только ненулевые остатки
      ibs.SQL.Text:= 'select Rware, Rstore, Rmarket'+
                     ' from Vlad_CSS_GetWareDprtRests(0, '+sDprts+', null)';
    end else begin // проверка - только те товары, что менялись
                                                 // лишняя минута для страховки
      sd:= FormatDateTime(cDateTimeFormatY4S, IncMinute(LastTestRestTime, -1));
      ibs.SQL.Text:= 'select Rware, Rstore, Rmarket'+
                     ' from Vlad_CSS_GetWareDprtRests(2, '+sDprts+', "'+sd+'")';
    end;

end else begin
    if AllowWeb then sDprts:= 'and DprtKind=0'                   // только склады
    else if AllowWebArm then sDprts:= 'and DprtKind in (0, 2)';  // склады и пути
    ibs.ParamCheck:= False;
    if flFill then begin // заполнение - только ненулевые остатки
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

    end else begin // проверка - только те товары, что менялись
      sd:= FormatDateTime(cDateTimeFormatY4S, IncMinute(LastTestRestTime, -1)); // лишняя минута для страховки
      ibs.SQL.Add('execute block returns (Rware integer, Rstore integer, Rmarket double precision)');
      ibs.SQL.Add('as declare variable xTime timestamp = "'+sd+'"; begin');
      ibs.SQL.Add(' for select coalesce(WACACODE, 0), coalesce(DPRTCODE, 0),');
      ibs.SQL.Add('  (select SUM(RestCurrent-RestOrder-RESTPLANOUTPUT-RestPlanTransfer)');
      ibs.SQL.Add('    from WAREREST where RestSubFirmCode=1 and');
      ibs.SQL.Add('    RestWareCode=WACACODE and RestDprtCode=DPRTCODE) Rmarket');
      ibs.SQL.Add('  from (select WACACODE from (select WACACODE');
      ibs.SQL.Add('    from WARECACHE_VLAD where WACARESTUPDATETIME>:xTime');
//if TestRDB(CntsGRB, trkField, 'WARECACHE_VLAD', 'WACAWAREALTERTIME') then begin // перевод с WAREALTER на WARECACHE_VLAD
//      ibs.SQL.Add('      or WACAWAREALTERTIME>:xTime');  // пока отложен, т.к. WAREALTER используется в NormExp
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

    ibs.ExecQuery;       // открываем список остатков из Grossbee
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
      inc(wCount); // счетчик проверенных товаров
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
  prMessageLOGS(nmProc+ss+' - '+GetLogTimeStr(LocalStart), fLogCache, false); // пишем в log
  TestCssStopException;
end;
//================================ проверить / уменьшить значение остатка товара
procedure TDataCache.CheckWareRest(wrLinks: TLinks; dprtID: Integer; pQty: Double; dec: Boolean=False);
const nmProc = 'CheckWareRest'; // имя процедуры/функции/потока
// возвращает False, если связка не найдена, при dec=False проставляет State:= True
var link: TQtyLink;
    NewQty: Double;
    Dprt: TDprtInfo;
begin
  if not Assigned(self) or not Assigned(wrLinks) then Exit;
  if not DprtExist(dprtID) then Exit;

  with wrLinks do try
    if not LinkExists(dprtID) then begin // если линка на остаток нет
      if not fnNotZero(pQty) then Exit;  // проверяем кол-во

      Dprt:= arDprtInfo[dprtID];         // проверяем склад
      if not (Dprt.IsStoreHouse or (AllowWebArm and Dprt.IsStoreRoad)) then Exit;

      NewQty:= fnIfDouble(dec, -pQty, pQty);
      if (NewQty>0) then AddLinkItem(TQtyLink.Create(0, NewQty, Dprt)); // добавляем линк
      Exit;
    end;

    link:= Items[dprtID]; // линк на остаток
    NewQty:= fnIfDouble(dec, link.Qty-pQty, pQty);
    if (NewQty<0) then NewQty:= 0;

    if not fnNotZero(NewQty) then begin  // если новое кол-во = 0
      DeleteLinkItem(link);
      Exit;
    end;

    if fnNotZero(link.Qty-NewQty) then try // если новое кол-во <> старому - меняем
      CS_links.Enter;
      link.Qty:= NewQty;
    finally
      CS_links.Leave;
    end;
    if not dec then link.State:= True; // признак проверки
  except
    on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
  end;
end;
//=========================================== получить остатки товара по складам
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
const nmProc = 'FillWareTypes'; // имя процедуры/функции
var Code: integer;
    flnew: Boolean;
    pCountLimit, pWeightLimit: Single;
begin
  if not Assigned(self) or not Assigned(GBIBS) then exit;
//if flDebug then prMessageLOGS('------------------- FillWareTypes', fLogDebug, false); // пишем в log
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
    GBIBS.SQL.Add('        if (xChild>0) then begin');  // родительский запоминаем
    GBIBS.SQL.Add('          if (xStrCodes="") then xStrCodes=cast(Rcode as varchar(10));');
    GBIBS.SQL.Add('          else xStrCodes=xStrCodes||","||cast(Rcode as varchar(10));');
    GBIBS.SQL.Add('        end else begin CountLimit=0; WeightLimit=0;');  // лимиты кол-ва и веса
    GBIBS.SQL.Add('          select wrlmwarecount, wrlmwareweight from PMWareLimit');
    GBIBS.SQL.Add('            where wrlmwaremastercode=:Rcode and wrlmarchivedkey="F"');
    GBIBS.SQL.Add('          into :CountLimit, :WeightLimit; suspend; end end end'); // конечный передаем
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
                                 // параметры типа товара (не нужны для товаров)
            if not Assigned(FTypeOpts) then begin
              FTypeOpts:= TWareTypeOpts.Create(pCountLimit, pWeightLimit);

{if flDebug then if (CountLimit>0) or (WeightLimit>0) then
  prMessageLOGS(nmProc+': '+Name+' - CountLimit='+FloatToStr(CountLimit)+
    ', WeightLimit='+FloatToStr(WeightLimit), fLogDebug, false); // пишем в log
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
//======================================================== проверяем кэш товаров
procedure TDataCache.TestWares(flFill: Boolean=True);
const nmProc = 'TestWares'; // имя процедуры/функции/потока
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
    prMessageLOGS(nmProc+s+'-------------------- start', fLogDebug, false); // пишем в log

    if not flFill then begin
      SetWaresNotTested; // сбрасываем флажки проверки
//      MarginGroups.SetLinkStatesAll(False);
    end;

    ibd:= cntsGRB.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc);

    if (AllowWebarm or flmyDebug) then try // только в Webarm, т.к. Web переписывает  ???
      flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_CheckWareStates');
      if flShowByState then try
        fnSetTransParams(ibs.Transaction, tpWrite, True);
        if flFill then // заполнение - все
          ibs.SQL.Text:= 'execute procedure Vlad_CSS_CheckWareStates(null)'
        else begin     // проверка - только те, что менялись
          ibs.SQL.Text:= 'execute procedure Vlad_CSS_CheckWareStates(:d)';
          ibs.ParamByName('d').AsDateTime:= IncMinute(LastTimeCache, -TestCacheInterval); // запас
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
    prMessageLOGS(nmProc+' CheckWareStates - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;

    with IBS.Transaction do if not InTransaction then StartTransaction;
//------------------------------------------------- заполняем / проверяем бренды
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
    TestCacheArrayLength(taWare, i+100);  // проверяем длину массива
    prCheckLengthIntArray(arActs, i+100); // проверяем длину массива
    prCheckLengthIntArray(arTops, i+100); // проверяем длину массива

//---------------------------------------------- заполняем объекты типов товаров
    FillWareTypes(ibs);

    st:= IntToStr(codeTovar);
    sd:= GetConstItem(pcDeliveriesMasterCode).StrValue;
//-------------------------------------------------- заполняем группы, подгруппы
    iGr:= 0;  // счетчик групп и подгрупп

if flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetFillGroupsParams') then begin
{ используются: 116632 - код ветки ДОСТАВКИ               codeWare = 6683;
                107685 - код группы ПО ГОРОДУ (ДОСТАВКИ)  codeInfo = 30011; }
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
      kGr:= ibs.FieldByName('KODGR').AsInteger; //-------------- группы (бренды)
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
//      if not gr.IsINFOgr and not flDeliv then // пропускаем инфо-группы и доставки
//        MarginGroups.CheckGroup(kGr); // проверяем группу наценки

      while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do begin
        kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- подгруппы
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
        end;                                // пропускаем инфо-группы и доставки
//        if PgrExists(kPgr) and not pgr.IsINFOgr and not flDeliv then
//          MarginGroups.CheckSubGroup(kGr, kPgr); // проверяем подгруппу наценки

        cntsGRB.TestSuspendException;
        ibs.Next;
      end; // while ... and (kGr=...
    end;
    ibs.Close;
//    MarginGroups.DelNotTestedLinksAll; // удаляем непроверенные
//    MarginGroups.SortByName(-1); // сортировать все

//------------------------------------ заполняем массивы с кодами акций и топами
    sa1:= Cache.GetConstItem(pcCauseActions).StrValue;
    sa2:= Cache.GetConstItem(pcCauseCatchMoment).StrValue;
    sa3:= Cache.GetConstItem(pcCauseNews).StrValue;
    i:= Length(arWareInfo);
    prCheckLengthIntArray(arActs, i);  // проверяем длину массива
    prCheckLengthIntArray(arTops, i);  // проверяем длину массива

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
      '  if (xCodeTop>0) then begin select first 1 coalesce(WRACLNCode, 0)'#10+ // топ
      '    from WareActionLines where WrAcLnDocmCode=:xCodeTop order by WRACLNCode into :xMin;'#10+
      '    if (xMin is null or xMin<1) then xCodeTop=0; end'#10+
      '  if (xCodeTop>0) then begin Kind=4;'#10+ // рейтинг ТОП поиска
      '    for select WrAcLnWareCode, WRACLNCode, w.WareChildCount'#10+
      '      from WareActionLines left join wares w on w.warecode=WrAcLnWareCode'#10+
      '      where WrAcLnDocmCode=:xCodeTop and w.WareArchive="F"'#10+
      '    into :xGroup, :ActCode, :xChild do begin ActCode=ActCode-xMin+1;'#10+
      '      if (xChild=0) then begin RWare=xGroup; suspend; end else begin'#10+ // товар
      '        for select w1.WARECODE from wares w1 where w1.WareMasterCode=:xGroup'#10+ // группа
      '          and w1.WareArchive="F" and w1.WareChildCount=0 into :RWare do suspend;'#10+
      '        for select w1.WARECODE from GetAllWareGroups(:xGroup) g'#10+ // все нижние группы
      '          left join wares w1 on w1.WareMasterCode=g.RWareCode'#10+
      '          where w1.WareArchive="F" and w1.WareChildCount=0 into :RWare do suspend;'#10+
      '      end end end end';
end;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      i:= ibs.FieldByName('RWare').AsInteger;
      k:= ibs.FieldByName('Kind').AsInteger;
      prCheckLengthIntArray(arActs, i, 100);  // проверяем длину массива
      prCheckLengthIntArray(arTops, i, 100);  // проверяем длину массива
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
    prMessageLOGS(nmProc+': Brands/Groups/Actions - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;
//------------------------------------------------------------------------------
    if not flFill then for i:= ProductLines.Count-1 downto 0 do
      TProductLine(ProductLines[i]).WareLinks.SetLinkStates(False);
    jw:= 0;   // счетчик товаров
    jm:= 0;   // счетчик MOTO
    jam:= 0;  // счетчик AUTO & MOTO
    jtop:= 0;
    jp:= 0;   // счетчик подарков

//------------------------------------ заполняем товары/доставки/подарки без цен
    sWStat:= Cache.GetConstItem(pcNotShowWareStates).StrValue;
if flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetFillWaresParams') then begin
{ используются: 116632 - код ветки ДОСТАВКИ               codeWare = 6683;
                107685 - код группы ПО ГОРОДУ (ДОСТАВКИ)  codeInfo = 30011;
  58 - код бренда MOTUL           123572 - код категории 07.MOTUL Продуктовая линейка
  95515 - направление "Реклама"   34835 - код категории 03.ТИП ТОВАРА
  69369 - код категории УЦЕНКА    32458 - код категории ТОП ТОВАРЫ }
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
      ' begin REmplCode=0; wtype=0; wTOP=0; IsDeliv=1; sale="F";'+ //--- доставки
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

      '  IsDeliv=0; KODPGR=0; KODGR=0; WAREBONUS="T";'#10+  //---------- подарки
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

      '  for select p1.pgrvlad, p1.KODGR, p1.KODPGR from VLADPGR p1'+ //--- товары
      '    order by p1.KODGR, p1.pgrvlad into :KODPGR, :KODGR, :mastercode do begin'#10+
      '    for select s.* from (select coalesce(w.WARECODE, 0) WARECODE, w.WAREMEAS,'#10+
      '      w.WARESUPPLIERNAME, coalesce(WrPrProductDirection, 0) WrPrProductDirection,'+
      '      coalesce(w.WAREDIVISIBLE, 1) WAREDIVISIBLE, coalesce(wareweight, 0) wareweight,'#10+
      '      w.wareproductscode, coalesce(WareLitrCount, 0) WareLitrCount,'+
      '      w.WAREOFFICIALNAME, w.WARECOMMENT, w.WAREMAINNAME,'#10+
      '      w.WAREBRANDCODE, sl.rsalekey, mg.REmplCode, wg1.WRGRMASTERCODE,'#10+
      '      (select first 1 WSState from WareState where WSWareCode=w.warecode'+
      '        and WSDate<current_timestamp order by WSDate desc) wState,'#10+
      '      iif(w.WAREBRANDCODE<>'+IntToStr(cbrMotul)+', 0,'+ // продуктовая линейка
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
      kGr:= ibs.FieldByName('KODGR').AsInteger;     //------------------- группа
      if (kGr>0) and not GrpExists(kGr) then gr:= nil else gr:= arWareInfo[kGr];
      if assigned(gr) and not gr.State then gr:= nil;
      if not assigned(gr) then begin
        TestCssStopException;
        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do ibs.Next;
        Continue;
      end;

      while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do begin
        kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- подгруппа
        if (kPgr>0) and not PgrExists(kPgr) then pgr:= nil else pgr:= arWareInfo[kPgr];
        if assigned(pgr) and not pgr.State then pgr:= nil;
        if not assigned(pgr) then begin
          while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger)
            and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do ibs.Next;
          Continue;
        end;

        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger)
          and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do begin
          i:= ibs.FieldByName('WARECODE').AsInteger; //------------------- товар
          flnew:= true;
          if TestCacheArrayItemExist(taWare, i, flnew) then begin
            ware:= arWareInfo[i];
            prCheckLengthIntArray(arActs, i, 100);  // проверяем длину массива
            prCheckLengthIntArray(arTops, i, 100);  // проверяем длину массива
            CS_wares.Enter;
            try
              ware.SetWareParams(kPgr, ibs, False, spWithoutPrice);
              if ware.IsPrize then begin                   //--- подарок
                ware.ActionID:= arActs[i];
                ware.TopRating:= arTops[i];
                Inc(jp);
//if flDebug and (ware.ActionID>0) then
//  prMessageLOGS('   подарок '+fnMakeAddCharStr(ware.Name, 40, True)+' - акция '+IntToStr(ware.ActionID), fLogDebug, false); // debug
              end else if (kPgr=Cache.pgrDeliv) then begin //--- доставка
                ware.TopRating:= 0;
                ware.ActionID:= 0;
                if not DeliveriesList.Find(ware.Name, ii) then
                  DeliveriesList.AddObject(ware.Name, Pointer(ware.ID));

              end else begin                               //--- товар
                ware.TopRating:= arTops[i];
                ware.ActionID:= arActs[i];
{if flDebug and (ware.ID>500000) and (ware.ID<500500) then
  prMessageLOGS(' w '+fnMakeAddCharStr(ware.Name, 30, True)+' - p '+
    cache.GetWareProductName(ware.ID), fLogDebug, false); // debug  }
                if ware.IsTop then inc(jtop);
                if ware.IsAUTOWare then begin
                  if not pgr.IsAUTOWare then pgr.IsAUTOWare:= True; // признак AUTO подгруппы
                  if not gr.IsAUTOWare then gr.IsAUTOWare:= True;   // признак AUTO группы
                end;
                if ware.IsMOTOWare then begin
                  if not pgr.IsMOTOWare then pgr.IsMOTOWare:= True; // признак MOTO подгруппы
                  if not gr.IsMOTOWare then gr.IsMOTOWare:= True;   // признак MOTO группы
                  inc(jm);                          // счетчик MOTO
                  if ware.IsAUTOWare then inc(jam); // счетчик AUTO - MOTO
                end;
                if flnew then begin
                  if AllowWebArm and not EmplExist(ware.ManagerID) then // для WebArm
                    prMessageLOGS('WareCode='+IntToStr(i)+' '+ware.Name+' - not found WareManager'+
                      fnIfStr(ware.ManagerID>0, ' EmplCode= '+IntToStr(ware.ManagerID), ''),
                      'NotWareManager', false); // пишем в log (только при первичном заполнении)
                  if (ware.WareBrandID=bm) and (ware.LitrCount=0) then
                    prMessageLOGS('WareCode='+IntToStr(i)+' '+ware.Name+' - LitrCount=0',
                      fLogCache, false); // пишем в log (только при первичном заполнении)
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
    prMessageLOGS(nmProc+': WareParams - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;

//------------------------------------- заполняем товары/доставки/подарки - цены
    i:= 0;
    SetLength(arTops, 0);  // эдесь используется для флагов проверки цен
    prCheckLengthIntArray(arTops, i+100); // проверяем длину массива и заполняем нулями
    ss:= '';
    ss1:= '';
    ss2:= '';
    ss3:= '';
    flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_GetWaresForPrices');
    for k:= 0 to High(PriceTypes) do begin // строки с набором цен
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
{ используются: 116632 - код ветки ДОСТАВКИ      95515 - направление "Реклама"
                107685 - код группы ПО ГОРОДУ (ДОСТАВКИ)  }
    ibs.SQL.Text:= 'select g.KODPGR, s.WARECODE'+ss1+
                   ' from Vlad_CSS_GetWaresForPrices g'+
                   ' left join wares s on s.warecode=g.warecode'+ss3;
    ibs.ExecQuery;
    while not ibs.EOF do begin
      kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- подгруппа
      if (kPgr>0) and not PgrExists(kPgr) then pgr:= nil else pgr:= arWareInfo[kPgr];
      if assigned(pgr) and not pgr.State then pgr:= nil;
      if not assigned(pgr) then begin
        TestCssStopException;
        while not ibs.EOF and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do ibs.Next;
        Continue;
      end;

      while not ibs.EOF and (kPgr=ibs.FieldByName('KODPGR').AsInteger) do begin
        i:= ibs.FieldByName('WARECODE').AsInteger; //------------------- товар
        if WareExist(i) then begin
          ware:= arWareInfo[i];
          if not ware.IsArchive and not ware.IsINFOgr and ware.State then try
            CS_wares.Enter;
            ware.SetWareParams(kPgr, ibs, False, spOnlyPrice);
            if not flFill then begin
              prCheckLengthIntArray(arTops, i+100); // проверяем длину массива
              arTops[i]:= 1;  // признак проверки цен
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
      ' begin KODPGR='+sd+';'#10+ //----------------------------------- доставки
      '  select w.waremastercode from wares w where w.warecode=:KODPGR into :KODGR;'#10+
      '  for select s.WARECODE'+ss1+
      '    from (select coalesce(w.WARECODE, 0) WARECODE, w.waremeas,'#10+
      '      (select first 1 WSState from WareState where WSWareCode=w.warecode'#10+
      '        and WSDate<current_timestamp order by WSDate desc) wState'#10+
      '    from wares w where w.waremastercode=:KODPGR and w.WareCode>0'#10+
      '      and w.WARECHILDCOUNT=0 and w.warearchive="F") s'#10+ss3+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE'+ss2+' do suspend;'#10+
      '  KODPGR=0; KODGR=0; for select s.WARECODE'+ss1+ //-------------- подарки
      '  from (select coalesce(w.WARECODE, 0) WARECODE, w.waremeas,'#10+
      '    (select first 1 WSState from WareState where WSWareCode=w.warecode'#10+
      '      and WSDate<current_timestamp order by WSDate desc) wState'#10+
      '    from wares w where w.WareCode>0 and w.WARECHILDCOUNT=0'#10+
      '      and w.warearchive="F" and w.warebonus="T") s'#10+ss3+
      fnIfStr(flShowWareByState, '  where not s.wState in ('+sWStat+')', '')+
      '  into :WARECODE'+ss2+' do suspend;'#10+
      '  for select pg.PGRvlad, pg.KODGR, pg.KODPGR from VLADPGR pg'#10+ //-- товары
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
      kGr:= ibs.FieldByName('KODGR').AsInteger;     //------------------- группа
      if (kGr>0) and not GrpExists(kGr) then gr:= nil else gr:= arWareInfo[kGr];
      if assigned(gr) and not gr.State then gr:= nil;
      if not assigned(gr) then begin
        TestCssStopException;
        while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do ibs.Next;
        Continue;
      end;

      while not ibs.EOF and (kGr=ibs.FieldByName('KODGR').AsInteger) do begin
        kPgr:= ibs.FieldByName('KODPGR').AsInteger; //---------------- подгруппа
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
          i:= ibs.FieldByName('WARECODE').AsInteger; //------------------- товар
          if WareExist(i) then begin
            ware:= arWareInfo[i];
            if not ware.IsArchive and not ware.IsINFOgr and ware.State then try
              CS_wares.Enter;
              ware.SetWareParams(kPgr, ibs, False, spOnlyPrice);
              if not flFill then begin
                prCheckLengthIntArray(arTops, i+100); // проверяем длину массива
                arTops[i]:= 1;  // признак проверки цен
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

    if not flFill then begin  // обнуляем цены у непроверенных
      prCheckLengthIntArray(arTops, length(arWareInfo)); // проверяем длину массива
      for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then begin
        ware:= arWareInfo[i];
        if not ware.IsWare or not ware.State or not Assigned(ware.FWareOpts) then Continue;
        if (arTops[i]<1) then
          for j:= 0 to High(ware.FWareOpts.FPrices) do ware.FWareOpts.FPrices[j]:= 0;
      end;
    end;
//------------------------------------------------------------------------------
if flLogTestWares then begin
    prMessageLOGS(nmProc+': WarePrices - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;

    if not flFill then DelNotTestedWares;  // удаляем непроверенные товары

    s:= s+IntToStr(iGr)+'g,'+IntToStr(jw)+'w('+IntToStr(jm)+'m,'+
        IntToStr(jam)+'am,'+IntToStr(jtop)+'t,'+IntToStr(jp)+'p)';
//    LocStart:= now();
    cntsGRB.TestSuspendException;


    flShowByState:= flShowWareByState and TestRDB(cntsGRB, trkProc, 'Vlad_CSS_CheckWareStates');
    //------------------------------------------- односторонние аналоги Grossbee
    SetWaresNotTested; // сбрасываем флажки проверки товаров и аналогов   ???
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
        end;                         // добавить код в аналоги, если его там нет
        ware.CheckAnalogLink(j, ibs.FieldByName('SrcCode').AsInteger);
        ibs.Next;
      end;
      cntsORD.TestSuspendException;
    end;
    if ibs.Transaction.InTransaction then ibs.Transaction.Rollback;
    ibs.Close;

    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then
      with arWareInfo[i] do if Assigned(AnalogLinks) and (AnalogLinks.LinkCount>0) then begin
        if not flFill then DelNotTestedAnalogs(True, True); // удаляем непроверенные аналоги-кроссы
        SortAnalogsByName; // сортировка аналогов по наименованию
      end; // AnalogLinks

if flLogTestWares then begin
    prMessageLOGS(nmProc+': WareAnalogs - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end;

    ii:= Length(arWareInfo);
    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then begin
      ii:= arWareInfo[i].ID+1;
      break;
    end;
    if Length(arWareInfo)>ii then try
      CS_wares.Enter;
      SetLength(arWareInfo, ii); // обрезаем по мах.коду
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
    ibd:= cntsORD.GetFreeCnt; // из dbOrder
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);

//if flLogTestWares then
//    prMessageLOGS(nmProc+': ORD Connect - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log

    //--------------------------------------------------------- бренды для сайта
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

    //------------------------------------------- коды брендов TecDoc - WebArm
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

    //--------------------------------------------------------- артикулы  TecDoc
    if not flFill then SetWaresNotTested; // сбрасываем флажки проверки товаров
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

    SetWaresNotTested; // сбрасываем флажки проверки товаров
    //----------------------------------------------------- сопутствующие товары
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
          if flnew then with arWareInfo[j] do // проверяем инфо и систему
            flnew:= (not IsArchive) and (not IsInfoGr) and CheckWaresEqualSys(i, j);
          if flnew then arWareInfo[i].SatelLinks.CheckLink(j, // добавить линк, если его нет
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
          if not flFill then SatelLinks.DelNotTestedLinks; // удаляем непроверенные сопут.товары
          SatelLinks.SortByLinkName;
        end; // SatelLinks

//-------------------------------------------------------- проверяем WareOptions
    SetWaresNotTested; // сбрасываем флажки проверки товаров
    SetLength(tmpar, 0);   // коды Update WOArhived='F'
    SetLength(tmpar1, 0);  // коды для Update WOArhived='T'
    j:= 0;  // счетчик для tmpar
    jj:= 0;  // счетчик для tmpar1
    ss:= '';
    ibs.SQL.Text:= 'Select WOWARECODE, WOArhived, woHasModAuto, woHasModMoto,'+
      ' woHasModCV, woHasModAx from WareOptions order by WOWARECODE, WOArhived';
    ibs.ExecQuery; // проверяем те коды, что уже есть в WareOptions
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
        if AllowWebarm then begin  // только в Webarm, т.к. Web переписывает
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
      else if AllowWebarm then begin // только в Webarm, т.к. Web переписывает
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

    if AllowWebarm then begin  // только в Webarm, т.к. Web переписывает
//------------------------------------------------------------------------------
      fnSetTransParams(ibs.Transaction, tpWrite);

      if (j>0) then begin // снимаем признак архивности в WareOptions
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

      if (jj>0) then begin // проставляем признак архивности в WareOptions
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
      SetLength(tmpar, 0);   // коды для Insert
      SetLength(tmpar1, 0);  // признаки архивности для Insert
      j:= 0;  // счетчик для tmpar
      for i:= 1 to High(arWareInfo) do begin // проверяем добавление в WareOptions
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
      if (j>0) then begin // добавляем в WareOptions
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
      if {flFill and} (ss<>'') then prMessageLOGS('WareOptions - '+ss, fLogCache, false); // пишем в log
//-------------------------------------------------------- проверили WareOptions
    end; // if AllowWebarm

if flLogTestWares then begin
    prMessageLOGS(nmProc+': WareOptions - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
//    LocStart:= now();
end;

if flWareForSearch then begin
    for i:= High(arWareInfo) downto 1 do if Assigned(arWareInfo[i]) then begin
      ware:= arWareInfo[i];
      fl:= ware.IsWare and (ware<>NoWare)
           and not ware.IsArchive and (ware.PgrID>0) // отсев по архивности
           and not ware.IsPrize                  // отсев призов
           and (ware.PgrID<>Cache.pgrDeliv)      // отсев доставок
           and not (ware.IsINFOgr and (ware.AnalogLinks.LinkCount<1)); // инфо без аналогов
      if (ware.ForSearch<>fl) then try
        CS_wares.Enter;
        ware.ForSearch:= fl;
      finally
        CS_wares.Leave;
      end;
    end;
end; // if flWareForSearch

    // очистить непроверенные !!!
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
  prMessageLOGS(nmProc+s+' - '+GetLogTimeStr(LocalStart), fLogCache, false); // пишем в log
  TestCssStopException;
end;
//==============================================================================
function TDataCache.GetWare(WareID: integer; OnlyCache: Boolean=False): TWareInfo;
// возвращает параметры товара (если в кэше его нет - заносит в кэш с PgrID=0)
const nmProc = 'GetWare'; // имя процедуры/функции/потока
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
    for k:= 0 to High(PriceTypes) do begin // строки с набором цен
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

      '    iif(w.WAREBRANDCODE<>'+IntToStr(cbrMotul)+', 0,'+ // продуктовая линейка
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
      '  if (WAREBONUS="T") then begin'#10+ //---------- подарок
      '    select first 1 coalesce(WrAcLnDocmCode, 0)'#10+ // Лови момент
      '      from WareActionLines left join WareActionReestr on WrAcCode=WrAcLnDocmCode'#10+
      '      where (WrAcLnWareCode=:xWare) and WrAcSubFirmCode=1 and WrAcDocmState=1'#10+
      '        and (WrAcCauseCode='+sa2+') and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '      order by WrAcStartDate, WrAcLnDocmCode into :actMoment;'#10+
      '    if (actMoment<1) then select first 1 coalesce(WrAcLnDocmCode, 0)'#10+ // Новинки
      '      from WareActionLines left join WareActionReestr on WrAcCode=WrAcLnDocmCode'#10+
      '      where (WrAcLnWareCode=:xWare) and WrAcSubFirmCode=1 and WrAcDocmState=1'#10+
      '        and (WrAcCauseCode='+sa3+') and ("today" between WrAcStartDate and WrAcStopDate)'#10+
      '      order by WrAcStartDate, WrAcLnDocmCode into :actNews;'#10+
      '  end else begin'+                //---------- товар
      '    select first 1 coalesce(WrAcLnDocmCode, 0) from WareActionLines'#10+ // акции
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
      '    if (xCodeTop>0) then begin select first 1 coalesce(WRACLNCode, 0)'#10+ // ТОП поиск
      '      from WareActionLines where WrAcLnDocmCode=:xCodeTop order by WRACLNCode into :xMin;'#10+
      '      if (xMin is null or xMin<1) then xCodeTop=0; end'#10+ // проверка наличия строк, мин.код строки в док-те
      '    if (xCodeTop>0) then begin while (TopRating<1 and xWare>0) do begin'#10+
      '      select coalesce(WRACLNCode, 0) from WareActionLines'#10+      // рейтинг ТОП поиска
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
      if Result.IsPrize then begin //---------- подарки
        k:= ibs.FieldByName('actMoment').AsInteger; // Лови момент
        i:= ibs.FieldByName('actNews').AsInteger;  // Новинки
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
//=========================================== сбрасываем флажки проверки товаров
procedure TDataCache.SetWaresNotTested;
var i: integer;
begin
  if not Assigned(self) then Exit;
  for i:= 1 to High(arWareInfo) do // сбросить признак проверки товара, группы, подгруппы
    if Assigned(arWareInfo[i]) then with arWareInfo[i] do begin
      State:= False;
      if assigned(AnalogLinks) then AnalogLinks.SetLinkStates(False); // сбрасываем признаки проверки аналогов
      if assigned(SatelLinks) then SatelLinks.SetLinkStates(False); // сбрасываем признаки проверки сопут.товаров
    end;
end;
//================================= убираем не проверенные элементы кэша товаров
procedure TDataCache.DelNotTestedWares;
var i: Integer;
begin
  if not Assigned(self) then Exit;
  for i:= 1 to High(arWareInfo) do if Assigned(arWareInfo[i]) then
    with arWareInfo[i] do if (not IsArchive) and (not State) then begin // если не проверен
      PgrID:= 0;                 // переносим в архив
      IsArchive:= True;
      ClearOpts;                 // очищаем связи
    end;
end;
//------------------------ проверяем совпадение всех значений заданных атрибутов
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
//=================================== поиск товаров по набору значений атрибутов
function TDataCache.SearchWaresByAttrValues(attCodes, valCodes: Tai): Tai; // must Free
// возвращает массив кодов товаров, отсортированных по наименованию
const nmProc='SearchWaresByAttrValues';
var i: integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  if (length(attCodes)<1) or (length(valCodes)<length(attCodes)) then Exit;
  with fnCreateStringList(False, 100) do try
    for i:= 1 to High(arWareInfo) do if WareExist(i) then with GetWare(i) do begin
      if IsArchive or (PgrID<1) or (PgrID=pgrDeliv) or IsPrize then Continue; // пропускаем доставки
      if fnAttrValEquals(AttrLinks, attCodes, valCodes) then AddObject(Name, pointer(i));
    end;
    if Count>1 then Sort;
    SetLength(Result, Count);
    for i:= 0 to Count-1 do Result[i]:= integer(Objects[i]);
  finally
    Free;
  end;
end;
//========================== поиск товаров по набору значений атрибутов Grossbee
function TDataCache.SearchWaresByGBAttValues(attCodes, valCodes: Tai): Tai; // must Free
// возвращает массив кодов товаров, отсортированных по наименованию
const nmProc='SearchWaresByGBAttValues';
var i: integer;
begin
  SetLength(Result, 0);
  if not Assigned(self) then Exit;
  if (length(attCodes)<1) or (length(valCodes)<length(attCodes)) then Exit;
  with fnCreateStringList(False, 100) do try
    for i:= 1 to High(arWareInfo) do if WareExist(i) then with GetWare(i) do begin
      if IsArchive or (PgrID<1) or (PgrID=pgrDeliv) or IsPrize then Continue; // пропускаем доставки
      if fnAttrValEquals(GBAttLinks, attCodes, valCodes) then AddObject(Name, pointer(i));
    end;
    if Count>1 then Sort;
    SetLength(Result, Count);
    for i:= 0 to Count-1 do Result[i]:= integer(Objects[i]);
  finally
    Free;
  end;
end;
//================================================= поиск товаров по артикулу TD
function TDataCache.SearchWaresByTDSupAndArticle(pSup: Integer; pArticle: String; // must Free
                                                 notInfo: Boolean=False): TStringList;
// возвращает массив кодов товаров, отсортированных по наименованию
// notInfo=True - только не-ИНФО товары
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
    if (Ware.PgrID=pgrDeliv) then Continue; // пропускаем доставки
    if notInfo and Ware.IsINFOgr then Continue;
    if (Ware.ArticleTD<>pArticle) or (pSup<>Ware.ArtSupTD) then Continue;
    Result.AddObject(Ware.Name, pointer(i));
  end;
  if Result.Count>1 then Result.Sort;
end;
//======== сортировка TList - приоритет desc + дата начала desc + дата окончания
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
//======================================================== Заполнение инфо-блока
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
  if not AllowWeb then Exit; // заполняем только для Web
  IBS:= nil;
  try
    if not flFill then InfoNews.SetDirStates(False);
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ibs:= fnCreateNewIBSQL(ORD_IBD, 'ibs_'+nmProc, -1, tpRead, true);
      ibs.SQL.Text:= 'SELECT * from InfoBoxViews where ("TODAY" between ibvDateFrom and ibvDateTo)';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.fieldByName('ibvCODE').AsInteger; // код
        s:= ibs.fieldByName('ibvTitle').AsString; // заголовок
        j:= ibs.fieldByName('ibvPriority').AsInteger;
        if not InfoNews.ItemExists(i) then begin
          Item:= TInfoBoxItem.Create(i, 0, j, s);
          InfoNews.CheckItem(Item); // здесь inItem.State=True
        end;
        inItem:= InfoNews[i];
        if not inItem.State then begin
          if (inItem.Title<>s)    then inItem.Title:= s;    // заголовок
          if (inItem.Priority<>j) then inItem.Priority:= j; // приоритет
        end;
        dd1:= ibs.fieldByName('ibvDateFrom').AsDateTime;    // дата начала
        if inItem.DateFrom<>dd1 then inItem.DateFrom:= dd1;
        dd2:= ibs.fieldByName('ibvDateTo').AsDateTime;      // дата окончания
        if inItem.DateTo<>dd2   then inItem.DateTo:= dd2;
        fl:= GetBoolGB(ibs, 'ibvVisible');                  // показывать в окне
        if inItem.InWindow<>fl then inItem.InWindow:= fl;
        fl:= GetBoolGB(ibs, 'ibvVisAuto');                  // видимость для системы авто
        if inItem.VisAuto<>fl then inItem.VisAuto:= fl;
        fl:= GetBoolGB(ibs, 'ibvVisMoto');                  // видимость для системы мото
        if inItem.VisMoto<>fl then inItem.VisMoto:= fl;
        s:= ibs.fieldByName('ibvLinkToSite').AsString;      // ссылка на сайт / окно описания
        if inItem.LinkToSite<>s then inItem.LinkToSite:= s;
        s:= ibs.fieldByName('ibvLinkToPict').AsString;      // ссылка на рисунок
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
//============================================ Заполнение / проверка уведомлений
procedure TDataCache.FillNotifications(fFill: Boolean=True);
const nmProc = 'FillNotifications'; // имя процедуры/функции
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
  if not AllowWeb then Exit; // заполняем только для Web
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
        noteID  := IBS.FieldByName('NoteCODE').AsInteger;     // код уведомления
        pBegDate:= IBS.FieldByName('NoteBegDate').AsDateTime; // дата начала
        pEndDate:= IBS.FieldByName('NoteEndDate').AsDateTime; // дата окончания
        sText   := IBS.FieldByName('NoteText').AsString;      // текст уведомления
        flAdd   := GetBoolGB(ibs, 'NOTEFIRMSADDFLAG');        // флаг - добавлять/исключать коды Firms
        flAuto  := GetBoolGB(ibs, 'NOTEauto');                // флаг  рассылки к/а с авто-контрактами
        flMoto  := GetBoolGB(ibs, 'NOTEmoto');                // флаг рассылки к/а с мото-контрактами
        flNew:= not Notifications.ItemExists(noteID);
        if flNew then begin // новый
          item:= TNotificationItem.Create(noteID, sText);
          Notifications.CheckItem(item); // здесь State=True
          noteItem:= item;
        end else noteItem:= Notifications[noteID];
        Notifications.CS_DirItems.Enter;
        with noteItem do try      //--------- проверяем
          if not flNew then begin
            Name:= sText;
            State:= True;
          end;
          BegDate   := pBegDate;
          EndDate   := pEndDate;
          flFirmAdd := flAdd;
          flFirmAuto:= flAuto;
          flFirmMoto:= flMoto;
          CheckConditions(IBS.FieldByName('NoteFilials').AsString, // коды филиалов к/а
                          IBS.FieldByName('NoteClasses').AsString, // коды категорий к/а
                          IBS.FieldByName('NoteTypes').AsString,   // коды типов к/а
                          IBS.FieldByName('NoteFirms').AsString);  // коды  к/а
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
//============================================ проверка значения атрибута товара
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
    if not WareExist(WareID) then // проверяем код товара
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    if not Attributes.ItemExists(AttrID) then // проверяем код атрибута
      raise EBOBError.Create('Не найден атрибут, код='+IntToStr(AttrID));

    Ware:= GetWare(WareID);                  // ссылка на товар
    if Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    Value:= trim(Value);
    flinkEx:= Ware.AttrLinks.LinkExists(AttrID); // признак наличия у товара линка на атрибут
    if not flinkEx and (Value='') then begin // если линка нет и пришло пустое значение
      ResCode:= resDoNothing;
      raise EBOBError.Create('Не найдено '+MessText(mtkWareAttrValue));
    end;

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite);

      if (Value='') then begin // если пришло пустое значение - удаляем связи
        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'delete from LINKWAREATTRVAL'+ // удаляем связку из базы
          ' where LWAWWARECODE=:LWAWWARECODE and LWAWATTRCODE=:LWAWATTRCODE';
        ORD_IBS.ParamByName('LWAWWARECODE').AsInteger:= WareID;
        ORD_IBS.ParamByName('LWAWATTRCODE').AsInteger:= AttrID;
        ORD_IBS.ExecQuery;
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        Ware.AttrLinks.DeleteLinkItem(AttrID); // удаляем линк из кеша
        ResCode:= resDeleted;
        raise EBOBError.Create(MessText(mtkWareAttrValue)+' удалено');
      end;
//------------------------ пустое значение (удаление) отработали

      sValue:= Value; // запоминаем принятое значение
      attr:= Attributes.GetAttr(AttrID); // ссылка на атрибут
      if attr.TypeAttr=constDouble then attr.CheckAttrStrValue(sValue); // проверяем значение

      j:= attr.FListValues.IndexOf(sValue); // ищем новое значение атрибута
      if (j>-1) then newatv:= Integer(attr.FListValues.Objects[j]); // код нового значения

      if flinkEx then begin
        attlink:= Ware.AttrLinks[AttrID];
        with attlink do if assigned(LinkPtrTwo) then oldatv:= LinkTwoID; // код старого значения
      end else attlink:= nil;

      if (oldatv>0) then begin // если старое значение есть
        if (newatv>0) and (oldatv=newatv) then begin // если значение то же
          ResCode:= resDoNothing;
          raise EBOBError.Create(MessText(mtkWareAttrValue)+' не изменилось');
        end;
        if assigned(attlink) then attlink.LinkPtrTwo:= nil;  // удаляем старое значение  ???
      end;
//------------------------ совпадаюшие значения отработали

      if newatv<1 then begin // если нет такого значения атрибута - добавляем в базу
        if (attr.TypeAttr=constDouble) and (FormatSettings.DecimalSeparator<>'.') then
          Value:= StringReplace(sValue, FormatSettings.DecimalSeparator, '.', [rfReplaceAll]); // в базу пишем с '.'
        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'insert into ATTRVALUES (ATVLATTRCODE, ATVLVALUESTR, ATVLUSERID)'+
          ' values (:ATVLATTRCODE, :ATVLVALUESTR, :ATVLUSERID) returning ATVLCODE';
        ORD_IBS.ParamByName('ATVLATTRCODE').AsInteger:= AttrID;
        ORD_IBS.ParamByName('ATVLVALUESTR').AsString := Value;
        ORD_IBS.ParamByName('ATVLUSERID').AsInteger  := userID;
        ORD_IBS.ExecQuery;
        if not (ORD_IBS.Bof and ORD_IBS.Eof) then newatv:= ORD_IBS.Fields[0].AsInteger; // код значения
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;
      end;
      if newatv<1 then raise EBOBError.Create(MessText(mtkErrAddRecord));

      if Attributes.FAttrValues.ItemExists(newatv) then
        attv:= Attributes.FAttrValues[newatv] // ссылка на значение атрибута
      else begin
        Item:= TDirItem.Create(newatv, sValue);
        if not Attributes.FAttrValues.CheckItem(Item) then // добавляем в справочник значений
           raise EBOBError.Create(MessText(mtkErrAddRecord));
        attv:= Item;
      end;

      with attr.FListValues do if (IndexOfObject(Pointer(newatv))<0) then begin
        AddObject(sValue, Pointer(newatv));  // добавляем в список значений атрибута
        CustomSort(AttrValuesSortCompare);   // сортируем список значений атрибута
      end;
//------------------------ справочники значений отработали

      if not flinkEx then begin // если не было линка на атрибут - добавляем

        if (Ware.AttrLinks.LinkCount>0) and (Ware.AttrGroupID<>attr.SubCode) then // проверка группы
           raise EBOBError.Create('товар имеет атрибуты другой группы');

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
          AddLinkItem(attlink);    // добавляем линк на атрибут в кэш
          SortByLinkOrdNumAndName; // сортируем по порядк.№ + наименованию
        end;
        attv.State:= True; // здесь признак используемого значения

        ResCode:= resAdded;
        Result:= MessText(mtkWareAttrValue)+' добавлено';

      end else begin // если линк был - меняем значение
        with ORD_ibs.Transaction do if not InTransaction then StartTransaction;
        ORD_IBS.SQL.Text:= 'update LINKWAREATTRVAL set LWAWATVLCODE='+IntToStr(newatv)+
          ' where LWAWWARECODE='+IntToStr(WareID)+' and LWAWATTRCODE='+IntToStr(AttrID);
        ORD_IBS.ExecQuery;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        if assigned(attlink) then begin
          attlink.LinkPtrTwo:= attv; // новое значение
          attv.State:= True; // здесь признак используемого значения
        end;
        ResCode:= resEdited;
        Result:= MessText(mtkWareAttrValue)+' изменено';
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

//================= добавление / удаление связки производителей Grossbe и Tecdoc
function TDataCache.CheckWareBrandReplace(brID, brTD, userID: Integer; var ResCode: Integer): String;
// возвращает сообщение о результате выполнения
// вид операции - ResCode - на входе (resAdded, resDeleted)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось, resAdded - добавлено, resDeleted - удалено
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
    if not (OpCode in [resAdded, resDeleted]) then       // проверяем код операции
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');
    if not WareBrands.ItemExists(brID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, IntToStr(brID)));

    fAdd:= OpCode<>resDeleted;
    index:= fnInIntArray(brTD, TBrandItem(WareBrands[brID]).TDMFcodes);
    if fAdd and (index>-1) then begin            // если добавление
      ResCode:= resDoNothing;
      raise EBOBError.Create('Такое соответствие производителей уже есть');
    end else if not fAdd and (index<0) then begin     // если удаление
      ResCode:= resDoNothing;
      raise EBOBError.Create('Не найдено такое соответствие производителей');
    end;

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      if fAdd then begin  // если добавление
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
        Result:= 'соответствие производителей добавлено';

      end else begin      // если удаление
        ORD_IBS.SQL.Text:= 'delete from BRANDREPLACE'+ // удаляем связку из базы
          ' where BRRPGBCODE='+IntToStr(brID)+' and BRRPTDCODE='+IntToStr(brTD);
        ORD_IBS.ExecQuery;
        ORD_IBS.Close;
        if ORD_IBS.Transaction.InTransaction then ORD_IBS.Transaction.Commit;

        prDelItemFromArray(index, TBrandItem(WareBrands[brID]).FTDMFcodes);
        ResCode:= resDeleted;
        Result:= 'соответствие производителей удалено';
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
//======================= добавление / удаление связки главной и дублирующей нод
function TDataCache.CheckLinkMainAndDupNodes(NodeID, MainNodeID, userID: Integer; var ResCode: Integer): String;
// возвращает сообщение о результате выполнения, вид операции - ResCode - на входе (resAdded, resDeleted)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось, resAdded - добавлено, resDeleted - удалено
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
//------------------------------------------------------------- сначала проверки
    if not Assigned(self) then raise Exception.Create(MessText(mtkErrProcess));
    if not (OpCode in [resAdded, resDeleted]) then       // проверяем код операции
      raise Exception.Create(MessText(mtkNotValidParam)+' операции');
    if (userID<1) then raise Exception.Create(MessText(mtkErrorUserID)); // проверяем userID

    flag:= OpCode<>resDeleted; // flag - флаг привязки

    with SysTypes do for i:= 0 to Count-1 do begin // определяем тип системы
      j:= GetDirItemID(ItemsList[i]);
      if Assigned(FDCA.AutoTreeNodesSys[j]) then with FDCA.AutoTreeNodesSys[j] do
        if NodeGet(NodeID, Node) then begin // проверяем заданную ноду
          if (NodeID<>MainNodeID) and not NodeExists(MainNodeID) then // проверяем главную ноду
            raise Exception.Create('У узлов разные системы учета');
          SysID:= j;
          Break;
        end;
    end; // for i:= 0 to Count-1
    if (SysID<1) then raise Exception.Create(MessText(mtkNotFoundTypeSys));

    if (NodeID=MainNodeID) then NodeMain:= Node
    else NodeMain:= FDCA.AutoTreeNodesSys[SysID][MainNodeID];
    NodeName:= Node.NameSys;
    MainNodeName:= NodeMain.NameSys;
    if not Node.IsEnding then // нода должна быть конечной
      raise Exception.Create('Узел ('+IntToStr(NodeID)+')'+NodeName+' не конечный');
    if (NodeID<>MainNodeID) and not NodeMain.IsEnding then // главная нода должна быть конечной
      raise Exception.Create('Узел ('+IntToStr(MainNodeID)+')'+MainNodeName+' не конечный');

    if flag then begin // проверяем возможность привязки
      j:= Node.MainCode;
      if (NodeID=j) then begin
                               // нода не должна быть главной с дублирующими узлами
        with FDCA.AutoTreeNodesSys[SysID].GetDuplicateNodes(NodeID) do try
          if (Count>0) then
            raise Exception.Create('Узел ('+IntToStr(NodeID)+')'+NodeName+' имеет дублирующие узлы');
        finally Free; end;

      end else if (FDCA.AutoTreeNodesSys[SysID].NodeExists(j)) then // нода должна быть непривязанной
        raise Exception.Create('Узел ('+IntToStr(NodeID)+')'+NodeName+' привязан к узлу ('+
          IntToStr(j)+')'+FDCA.AutoTreeNodesSys[SysID][j].NameSys);

    end else if (Node.MainCode<>MainNodeID) then // проверяем возможность отвязки
      raise Exception.Create('Узел ('+IntToStr(NodeID)+')'+NodeName+
        ' не привязан к узлу ('+IntToStr(MainNodeID)+')'+MainNodeName);

//--------------------------------------------------------- отрабатываем отвязку
    if not flag then begin
      flag:= False; // теперь flag - флаг ошибок
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
        while not ORD_IBS.Eof do begin // выбираем коды моделей, которые надо проработать
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

      for j:= 0 to High(codes) do try //-------------------- перебираем модели
        ModelID:= codes[j];
        if not FDCA.Models.ModelExists(ModelID) then Continue;
        Model:= FDCA.Models[ModelID];
        if not Assigned(Model.NodeLinks) or // ищем связки 2 на нашу ноду
          not Model.NodeLinks.LinkExists(NodeID) then Continue;

        link2:= Model.NodeLinks[NodeID];         // фиксируем связку 2 ноды
        if link2.IsLinkNode and
          Assigned(link2.DoubleLinks) then Continue; // если есть связки 3 - пропускаем

        Model.NodeLinks.DeleteLinkItem(NodeID); // удаляем связку 2
      except
        on E: Exception do begin
          flag:= True;
          prMessageLOGS(nmProc+': ModelID='+IntToStr(ModelID)+
            ', NodeID='+IntToStr(NodeID)+': '+E.Message, 'import', False);
        end;
      end; // for j:= 0 to High(codes)
      TestCssStopException;

      if not flag then begin //------------------------------- отвязываем ноду
        Node.MainCode:= NodeID;
        ResCode:= resDeleted;
        Result:= 'Узел ('+IntToStr(NodeID)+')'+NodeName+
          ' отвязан от узла ('+IntToStr(MainNodeID)+')'+MainNodeName;
      end;
      Exit;
    end;

//---- переносим линки условий и текстов к связкам 3, линки товар - нода - текст
//---- перенос линков условий и текстов к связкам 3, товар - нода - текст - триггеры
    flag:= False; // теперь flag - флаг ошибок
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
      while not ORD_IBS.Eof do begin // выбираем коды моделей, которые надо проработать
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

   //------------------------------------------------ перебираем модели
    for j:= 0 to High(codes) do try
      ModelID:= codes[j];
      if not FDCA.Models.ModelExists(ModelID) then Continue;
      Model:= FDCA.Models[ModelID];
      if not Assigned(Model.NodeLinks) then Continue; // ищем связки 2 на нашу ноду

      fLinkEx:= Model.NodeLinks.LinkExists(NodeID);
      fMainLinkEx:= Model.NodeLinks.LinkExists(MainNodeID);
      if not fLinkEx and not fMainLinkEx then Continue;

   //------------------------------------------------ объединяем связки 2
      link2main:= nil;
      link2:= nil; // связка 2
      if not fLinkEx then begin
        link2main:= Model.NodeLinks[MainNodeID]; // фиксируем связку 2 главной ноды
        s:= FDCA.CheckModelNodeLinkDup(ModelID, NodeID, FloatToStr(link2main.Qty), res, link2main.SrcID, userID);
        if (res=resError) then raise Exception.Create(s);
      end;
      if not fMainLinkEx then begin
        link2:= Model.NodeLinks[NodeID];         // фиксируем связку 2 ноды
        s:= FDCA.CheckModelNodeLinkDup(ModelID, MainNodeID, FloatToStr(link2.Qty), res, link2.SrcID, userID);
        if (res=resError) then raise Exception.Create(s);
        TestCssStopException;
      end;
      if not Assigned(link2) then link2:= Model.NodeLinks[NodeID];             // фиксируем связку 2 ноды
      if not Assigned(link2main) then link2main:= Model.NodeLinks[MainNodeID]; // фиксируем связку 2 главной ноды
      if not Assigned(link2) or not Assigned(link2main) then
        raise Exception.Create('error create link');

      if (link2.Qty>link2main.Qty) then begin // переносим кол-во на главную ноду
        s:= FDCA.CheckModelNodeLinkDup(ModelID, MainNodeID, FloatToStr(link2.Qty), res, link2.SrcID, userID);
        if (res=resError) then raise Exception.Create(s);
        TestCssStopException;
      end;

      if not link2.IsLinkNode or
        not Assigned(link2.DoubleLinks) then Continue; // ищем связки 3 по связке 2 ноды

      links3:= link2.DoubleLinks;
      for j3:= links3.Count-1 downto 0 do try //---- перебираем связки 3
        link3:= links3[j3]; // фиксируем связку 3 ноды
        WareID:= TDirItem(link3).ID;
//        if Cache.WareExist(WareID) then begin  // ???
          res:= resAdded;  // добавляем связку 3 к линкам главной ноды (если такой нет)
          s:= FDCA.CheckWareModelNodeLink(WareID, ModelID, MainNodeID, res, link3.srcID, userID);
          if (res=resError) then raise Exception.Create(s);
          TestCssStopException;

     //------------------------------------ удаляем связку 3 из связок ноды
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

    if not flag then begin //-------------------------------- привязываем ноду
      Node.MainCode:= MainNodeID;
      ResCode:= resAdded;
      Result:= 'Узел ('+IntToStr(NodeID)+')'+NodeName+
        ' привязан к узлу ('+IntToStr(MainNodeID)+')'+MainNodeName;
    end;
  finally
    SetLength(codes, 0);
  end;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;
//==================================== проверка ссответствия систем двух товаров
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
  with SysTypes do for i:= 0 to Count-1 do begin // набор типов систем
    k:= GetDirItemID(ItemsList[i]);
    Result:= ware1.CheckWareTypeSys(k) and ware2.CheckWareTypeSys(k);
    if Result then break;
  end;
end;
// сортированный список товаров (Object-ID) по системе и/или менеджеру и/или бренду
function TDataCache.GetSysManagerWares(SysID: Integer=0; ManID: Integer=0;
         Brand: integer=0; Sort: boolean=True): TStringList; // must Free Result
var i: Integer;
begin
  Result:= TStringList.Create;
  if not Assigned(self) then Exit;
  if (Brand>0) and not WareBrands.ItemExists(Brand) then Exit;
//    raise EBOBError.Create('Не найден бренд с кодом '+IntToStr(Brand));
  if (ManID>0) and not EmplExist(ManID) then Exit;
//    raise EBOBError.Create('Не найден менеджер с кодом '+IntToStr(ManID));
  if (SysID>0) and not CheckTypeSys(SysID) then Exit;
//    raise EBOBError.Create('Не найдена система учета с кодом '+IntToStr(SysID));
  Result.Capacity:= length(ArWareInfo);
  for i:= 1 to High(arWareInfo) do
    if not WareExist(i) then Continue else with GetWare(i) do begin
      if IsArchive or (PgrID<1) then Continue;
      if (PgrID=pgrDeliv) then Continue; // пропускаем доставки
      if (ManID>0) and (ManID<>ManagerID) then Continue;
      if (SysID>0) and not CheckWareTypeSys(SysID) then Continue;
      if (Brand>0) and (WareBrandID<>Brand) then Continue;
      Result.AddObject(Name, Pointer(ID));
    end;
  if Sort and (Result.Count>1) then Result.Sort;
end;
//============================================= Возвращает список брендов TecDoc
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
//===================================== время последнего обн.кеша для коммандера
function TDataCache.GetLastTimeCache: Double;
begin
  if WareCacheTested then Result:= -1 else Result:= LastTimeCache;
end;
//================ список текстов и условий по узлам к связкам товара с моделями
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

    nodeDelim:= brcWebDelim; // разделитель узлов
    partDelim:= '---------- или ----------';     // разделитель порций
    partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // жирный черный шрифт
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
          NodeID:= ORD_IBS.FieldByName('rNodeID').AsInteger; // код узла

          if nodes.NodeExists(NodeID) then begin
            node:= nodes[NodeID];
            if not node.IsEnding then node:= nil;
          end else node:= nil;

          if not Assigned(node) then begin
            TestCssStopException;
            while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger) do ORD_IBS.Next;
            Continue;
          end;

          if (lst.Count>0) then lst.Add(nodeDelim); // разделитель узлов
          s:= 'Узел - '+node.Name+': ';
          s:= brcWebColorBlueBegin+s+brcWebColorEnd; // синий шрифт
          lst.Add(s); // название узла

          pCount:= 0; // счетчик порций
          while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger) do begin // собираем тексты по 1-му узлу
            iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // порция
            if pCount>0 then lst.Add(partDelim);   // разделитель порций
            while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger)
              and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // тексты по 1 порции
              iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
              TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
              s:= '';
              while not ORD_IBS.Eof and (NodeID=ORD_IBS.FieldByName('rNodeID').AsInteger)
                and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
                and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // тексты по 1 типу текста
                s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
                cntsORD.TestSuspendException;
                ORD_IBS.Next;
              end;
              s:= TypeName+fnIfStr(s='', '', ': '+s);  // строка по 1-му типу текста
              lst.Add(s);
            end; // while not ORD_IBS.Eof and (NodeID=... and (iPart=
            inc(pCount); // счетчик порций
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
//======================= список текстов и условий к связкам 3, Objects - WareID
function TDataCache.GetWaresModelNodeUsesAndTextsView(ModelID, NodeID: Integer;
         WareCodes: Tai; var sFilters: String): TStringList; // must Free Result
const nmProc = 'GetWaresModelNodeUsesAndTextsView';
// на входе код узла Motul < 0  !!!
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
    if node.IsEnding then begin // если конечная нода
      if Model.NodeLinks.LinkExists(inode) then begin
        link:= Model.NodeLinks[inode];           // запоминаем код главной ноды
        j:= node.MainCode;
        if link.NodeHasWares then prAddItemToIntArray(j, arNodeCodes);
              // здесь код узла основного подбора < 0  !!!
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
    if flMotulNode then begin  //-------------------------- узел Motul (0 - все)
      NodeID:= -NodeID;
      prAddItemToIntArray(NodeID, arNodeCodesM);
      flNotEndNode:= False;
    end else if (NodeID<1) then begin
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
    end else begin           //-------------------------- узел основного подбора
      Model:= FDCA.Models[ModelID];
      nodes:= FDCA.AutoTreeNodesSys[Model.TypeSys];
      if not nodes.NodeExists(NodeID) then
        raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));
      node:= nodes[NodeID];
      flNotEndNode:= not node.IsEnding;
      AddCodes(NodeID);         // собираем коды всех главных конечных нод
      if (Length(arNodeCodes)<1) and (Length(arNodeCodesM)<1) then Exit; // если нет нод

      if flNotEndNode then str:= cWebSpace+cWebSpace+cWebSpace else str:= ''; // отступ, если исх.нода не конечная
      nodeDelim:= brcWebDelim; // разделитель узлов / 0-й порции
      partDelim:= '---------- или ----------';     // разделитель порций
      partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // жирный черный шрифт
//      partDelim:= cWebItalBegin+cWebBoldBlackBegin+partDelim+cWebBoldEnd+cWebItalEnd; // жирный черный курсив
    end;

      //-------------------- текст SQL для подтягивания условий из подбора Motul
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

      if (sSQL<>'') then begin //----------- вытягиваем условия из подбора Motul
        ORD_IBS.SQL.Text:= sSQL;
        for i:= 0 to High(WareCodes) do begin // собираем коды прод.линеек
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

          if (lst.Count>0) then lst.Clear; // собираем условия применимости прод.линейки
          NodeCount:= 0; // кол-во узлов с условиями
          while not ORD_IBS.Eof do begin
            ii:= ORD_IBS.FieldByName('rNode').AsInteger; // код узла Motul
            if not MotulTreeNodes.ItemExists(ii) then begin
              TestCssStopException;
              while not ORD_IBS.Eof and (ii=ORD_IBS.FieldByName('rNode').asInteger) do ORD_IBS.Next;
              Continue;
            end;
            j:= 0;
            while not ORD_IBS.Eof and (ii=ORD_IBS.FieldByName('rNode').asInteger) do begin
              ss:= ORD_IBS.FieldByName('RcriName').AsString;
              s:= ORD_IBS.FieldByName('Rvalues').AsString;
              if (s<>'') or (ss<>'') then begin //-------- есть условия

                if (j=0) then begin // 1-я строка с условиями по узлу
                  mNode:= MotulTreeNodes[ii];
                  sn:= 'Узел Motul - '+mNode.Name+': ';        // название узла
                  sn:= brcWebColorBlueBegin+sn+brcWebColorEnd; // синий шрифт
                  //------------- исходный неконечный узел или узлов несколько
                  if flNotEndNode or (NodeCount>0) then begin
                    // если пошли на 2-й узел - вставляем в начало название 1-го
                    if (NodeCount=1) then lst.Insert(0, snPrev);
                    lst.Add(sn); // пишем название узла
                  end; // if flNotEndNode or (NodeCount>0)
                  inc(NodeCount); // кол-во узлов с условиями
                  snPrev:= sn; // запоминаем название предыдущего узла
                end; // if (j=0)

                lst.Add(ss+fnIfStr(s='', '', ': '+s)); // строка по 1-му критерию
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
          //---------- сначала проверяем наличие условий по прод.линейке
          if (ii>0) and (sSQL<>'') then begin
            iPart:= lstPLs.IndexOfObject(Pointer(ii));
            if (iPart>-1) then s:= lstPLs[iPart];
          end;
          if (s<>'') then begin // есть - берем для любого узла
            lst.Text:= s;
            if not flNotEndNode then lst.Add(nodeDelim); // отделяем условия Motul
  //          Result.AddObject(s, Pointer(WareCodes[i]));
  //          Continue;
          end;
        end; // if (lstPLs.Count>0)

        if not flMotulNode then begin  // ищем условия по узлу основного подбора
          ORD_IBS.ParamByName('WareID').AsInteger:= WareCodes[i];
          flPart0:= False;
          for ii:= 0 to High(arNodeCodes) do begin
            NodeID:= arNodeCodes[ii];
            ORD_IBS.ParamByName('NodeID').AsInteger:= NodeID;
            ORD_IBS.ExecQuery;
            // если по узлу что-то есть и исх.узел не конечный - пишем название узла
            if flNotEndNode and not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
              if (lst.Count>0) then lst.Add(nodeDelim);  // разделитель узлов
              s:= 'Узел - '+nodes[NodeID].Name+': ';
              s:= brcWebColorBlueBegin+s+brcWebColorEnd; // синий шрифт
              lst.Add(s);
            end;

            pCount:= 0; // счетчик порций
            while not ORD_IBS.Eof do begin // собираем тексты по 1-му узлу
              iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // порция
              if (iPart<0) and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
                sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // строка значений фильтров
                cntsORD.TestSuspendException;
                ORD_IBS.Next;
                Continue;
              end;

              if (iPart=0) then flPart0:= True; // флаг 0-й порции (значение критерия фильтра товара)
              if (pCount>0) then
                if flPart0 then begin
                  lst.Add(brcWebDelim); // разделитель 0-й порции
                  flPart0:= False;
                end else lst.Add(partDelim);   // разделитель порций

              while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // тексты по 1 порции
                iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
                TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
                s:= '';
                while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
                  and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // тексты по 1 типу текста
                  s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
                  cntsORD.TestSuspendException;
                  ORD_IBS.Next;
                end;

                s:= str+TypeName+fnIfStr(s='', '', ': '+s);  // строка по 1-му типу текста
                if (iPart=0) then  // выделяем строки 0-й порции
                  s:= brcWebColorRedBegin+s+brcWebColorEnd; // красный шрифт
                lst.Add(s);
              end; // while not ORD_IBS.Eof and (iPart=

              inc(pCount); // счетчик порций
            end; //  while not ORD_IBS.Eof
            ORD_IBS.Close;
          end; // for ii:= 0 to High(arNodeCodes)
        end; // if not flMotulNode

        if (lst.Count>0) then begin
          iPart:= lst.Count-1; // если в последней строке разделитель - убираем
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
//=== фильтр.список товаров с текстами и условиями к связкам 3, Objects - WareID
function TDataCache.GetModelNodeWaresWithUsesByFilters(ModelID, NodeID: Integer;
         withChildNodes: boolean; var sFilters: String): TStringList; // must Free Result
// sFilters - коды значений критериев через запятую
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
    if node.IsEnding then begin // если конечная нода
      if nlinks.LinkExists(inode) then begin
        link:= nlinks[inode];              // запоминаем код главной ноды
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

    nodeDelim:= brcWebDelim;      // разделитель узлов / 0-й порции
    partDelim:= '---------- или ----------';           // разделитель порций
    partDelim:= brcWebBoldBlackBegin+partDelim+brcWebBoldEnd;  // жирный черный шрифт
    if flNotEndNode then str:= cWebSpace+cWebSpace+cWebSpace else str:= ''; // отступ, если исх.нода не конечная
//    partDelim:= cWebItalBegin+cWebBoldBlackBegin+partDelim+cWebBoldEnd+cWebItalEnd; // жирный черный курсив

    ORD_IBD:= cntsOrd.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);

    sFilters:= StringReplace(sFilters, ' ', '', [rfReplaceAll]); // убираем все пробелы
//------------------------------------------ если заданы фильтры (нода конечная)
    if not flNotEndNode and (sFilters<>'') then begin
      ORD_IBS.SQL.Text:= 'select RWare, Rpart, Rtype, RtypeName, Rtext'+
        ' from GetModNodFiltWaresWithUseParts_('+
        IntToStr(ModelID)+', '+IntToStr(NodeID)+', :sFilters)';
      ORD_IBS.ParamByName('sFilters').AsString:= sFilters;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        if (ORD_IBS.FieldByName('Rpart').AsInteger<0)
          and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
          sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // строка значений фильтров
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
          Continue;
        end;

        wareID:= ORD_IBS.FieldByName('RWare').AsInteger; // код товара
        if Cache.WareExist(wareID) then begin
          ware:= Cache.GetWare(wareID, True);
          if (ware=NoWare) or ware.IsArchive or ware.IsINFOgr then ware:= nil;
        end else ware:= nil;
        if not Assigned(ware) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        if (ORD_IBS.FieldByName('RtypeName').AsString='') then begin // если только код товара
          Result.AddObject('', Pointer(wareID));
          cntsORD.TestSuspendException;
          ORD_IBS.Next;
          Continue;
        end;

        pCount:= 0; // счетчик порций
        if (lst.Count>0) then lst.Clear;
        flPart0:= False;                    // собираем тексты по 1-му товару
        while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger) do begin
          iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // порция

          if (iPart<0) and (ORD_IBS.FieldByName('Rtext').AsString<>'') then begin
            sFilters:= ORD_IBS.FieldByName('Rtext').AsString; // строка значений фильтров
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
            Continue;
          end;

          if (iPart=0) then flPart0:= True; // флаг 0-й порции (значение критерия фильтра товара)
          if pCount>0 then
            if flPart0 then begin
              lst.Add(brcWebDelim); // разделитель 0-й порции
              flPart0:= False;
            end else lst.Add(partDelim); // разделитель порций

          while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger)
            and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // тексты по 1 порции
            iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
            TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
            s:= '';
            while not ORD_IBS.Eof and (wareID=ORD_IBS.FieldByName('RWare').AsInteger)
              and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
              and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // тексты по 1 типу текста
              s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
              cntsORD.TestSuspendException;
              ORD_IBS.Next;
            end;
            s:= str+TypeName+fnIfStr(s='', '', ': '+s);  // строка по 1-му типу текста
            if (iPart=0) then  // выделяем строки 0-й порции
              s:= brcWebColorRedBegin+s+brcWebColorEnd; // красный шрифт
            lst.Add(s);
          end; // while not ORD_IBS.Eof and (wareID=... and (iPart=

          inc(pCount); // счетчик порций
        end; // while not ORD_IBS.Eof and (wareID=

        Result.AddObject(lst.Text, Pointer(wareID));
      end; // while not ORD_IBS.Eof
      ORD_IBS.Close;
                          // текст SQL для подтягивания товаров из подбора Motul
      sSQL:= 'select Rpline, rNode, RcriName, Rvalues'+
        ' from GetModelNodesPLines('+IntToStr(ModelID)+', -'+IntToStr(NodeID)+')'+
        ' order by Rpline, rNode, RcriName';

//      if (Result.Count>1) then Result.CustomSort(ObjWareNameSortCompare); // сортировка по наименованию товара

//------------------------------------------------------- если не заданы фильтры
    end else begin
      flFromBase:= not Cache.WareLinksUnLocked; // пока кеш связок не заполнен - берем из базы
      WareCodes:= Model.GetModelNodeWares(NodeId, withChildNodes, flFromBase); // коды товаров по ноде модели
      try
        if flFromBase then nlinks:= Model.GetModelNodesLinks else nlinks:= Model.NodeLinks;
        AddCodes(NodeID);         // собираем коды всех главных конечных нод
        if (Length(arNodeCodes)<1) and (Length(arNodeCodesM)<1) then begin // если нет нод
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
            // если по ноде что-то есть и исх.нода не конечная - пишем название ноды
            if flNotEndNode and not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
              if lst.Count>0 then lst.Add(nodeDelim);    // разделитель узлов
              s:= 'Узел - '+nodes[NodeID].Name+': ';
              s:= brcWebColorBlueBegin+s+brcWebColorEnd; // синий шрифт
              lst.Add(s);
            end;

            pCount:= 0; // счетчик порций
            while not ORD_IBS.Eof do begin // собираем тексты по 1-му узлу
              iPart:= ORD_IBS.FieldByName('Rpart').AsInteger; // порция
              if pCount>0 then lst.Add(partDelim);            // разделитель порций

              while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger) do begin // тексты по 1 порции
                iType:= ORD_IBS.FieldByName('Rtype').AsInteger;
                TypeName:= ORD_IBS.FieldByName('RtypeName').AsString;
                s:= '';
                while not ORD_IBS.Eof and (iPart=ORD_IBS.FieldByName('Rpart').AsInteger)
                  and (iType=ORD_IBS.FieldByName('Rtype').AsInteger) do begin // тексты по 1 типу текста
                  s:= s+fnIfStr(s='', '', ', ')+ORD_IBS.FieldByName('Rtext').AsString;
                  cntsORD.TestSuspendException;
                  ORD_IBS.Next;
                end;
                s:= str+TypeName+fnIfStr(s='', '', ': '+s);  // строка по 1-му типу текста
                lst.Add(s);
              end; // while not ORD_IBS.Eof and (iPart=

              inc(pCount); // счетчик порций
            end; //  while not ORD_IBS.Eof
            ORD_IBS.Close;
          end; // for ii:= 0 to High(arNodeCodes)

          Result.AddObject(lst.Text, Pointer(WareCodes[i]));
        end; // for i:= 0 to High(WareCodes)
      end; // if (Length(WareCodes)>0)
                          // текст SQL для подтягивания товаров из подбора Motul
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

    if (sSQL<>'') then begin // подтягиваем товары из подбора Motul
      ORD_IBS.SQL.Text:= sSQL;
      ORD_IBS.ExecQuery;
      while not ORD_IBS.Eof do begin
        iType:= ORD_IBS.FieldByName('Rpline').AsInteger; // код прод.линейки
        PLine:= Cache.ProductLines.GetProductLine(iType);
        if not Assigned(PLine) or (PLine.WareLinks.LinkCount<1) then begin
          TestCssStopException;
          while not ORD_IBS.Eof and (iType=ORD_IBS.FieldByName('Rpline').asInteger) do ORD_IBS.Next;
          Continue;
        end;

        if (lst.Count>0) then lst.Clear; // собираем условия применимости прод.линейки
        NodeCount:= 0; // кол-во узлов с условиями
        while not ORD_IBS.Eof and (iType=ORD_IBS.FieldByName('Rpline').asInteger) do begin
          iPart:= ORD_IBS.FieldByName('rNode').AsInteger; // код узла Motul
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
            if (s<>'') or (ss<>'') then begin //-------- есть условия

              if (j=0) then begin // 1-я строка с условиями по узлу
                mNode:= Cache.MotulTreeNodes[iPart];
                sn:= 'Узел Motul - '+mNode.Name+': ';        // название узла
                sn:= brcWebColorBlueBegin+sn+brcWebColorEnd; // синий шрифт
                //------------- исходный неконечный узел или узлов несколько
                if flNotEndNode or (NodeCount>0) then begin
                  // если пошли на 2-й узел - вставляем в начало название 1-го
                  if (NodeCount=1) then lst.Insert(0, snPrev);
                  lst.Add(sn); // пишем название узла
                end; // if flNotEndNode or (NodeCount>0)
                inc(NodeCount); // кол-во узлов с условиями
                snPrev:= sn; // запоминаем название предыдущего узла
              end; // if (j=0)

              lst.Add(ss+fnIfStr(s='', '', ': '+s)); // строка по 1-му критерию
              inc(j);
            end; // if (s<>'') or (ss<>'')
            cntsORD.TestSuspendException;
            ORD_IBS.Next;
          end; // while ... and (plID= ... and (iPart=
        end; // while not ORD_IBS.Eof and (iType= ... and
        //---------------------- список товаров прод.линейки
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
//===================== добавить/удалить линк товара с аналогом (Excel, вручную)
function TDataCache.CheckWareCrossLink(pWareID, pCrossID: Integer;
         var ResCode: Integer; srcID: Integer; UserID: Integer=0): String;
const nmProc = 'CheckWareCrossLink';
// ResCode на входе - вид операции (resAdded, resDeleted, resWrong, resNotWrong)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось, resAdded - добавлена,
// resDeleted - удалена, resWrong - отмечена, как неверная, resNotWrong - восстановлена
// ограничения: удалять можно связки только с источником (Excel или вручную)
//              пометить Wrong можно только связки с источником (TD)
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
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then // проверяем код операции
      raise Exception.Create(MessText(mtkNotValidParam)+' операции');
    if (pCrossID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' аналога');

    Ware:= GetWare(pWareID, True);
    if (Ware=NoWare) or Ware.IsArchive then                   // проверяем товар
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));

    fex:= Ware.AnalogLinks.LinkExists(pCrossID) // проверка существования кросса
          and TAnalogLink(Ware.AnalogLinks[pCrossID]).IsCross;
    if fex then begin
      mess:= '';
      case OpCode of
        resAdded   : mess:= 'Такая '+MessText(mtkWareAnalogLink)+' есть';
        resNotWrong: mess:= MessText(mtkWareAnalogLink)+' не отмечена, как ошибочная';
      end; // case
      if mess<>'' then begin
        ResCode:= resDoNothing;
        raise Exception.Create(mess);
      end;
    end else if (OpCode in [resDeleted, resWrong]) then begin
      ResCode:= resDoNothing;
      raise Exception.Create('Не найдена '+MessText(mtkWareAnalogLink));
    end;
                       // проверка необходимых параметров и доступности операции
    if (OpCode in [resAdded, resNotWrong, resWrong]) and (userID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' юзера')
    else if (OpCode in [resAdded]) and (srcID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' источника')
    else if (OpCode in [resDeleted, resWrong]) then begin
      LinkSrc:= GetLinkSrc(Ware.AnalogLinks[pCrossID]);
      case OpCode of
      resDeleted: // удалять можно связки только с источником (Excel, GrossBee или вручную)
        if not Cache.CheckLinkAllowDelete(LinkSrc) then begin
          if not Cache.CheckLinkAllowWrong(LinkSrc) then
            raise Exception.Create(MessText(mtkFuncNotAvailabl));
          if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' юзера');
          OpCode:= resWrong; // связки TecDoc не удаляем, а отмечаем неверными
          mess1:= ' (TecDoc)';
        end;
      resWrong:  // пометить Wrong можно только связки с источником (TD)
        if not Cache.CheckLinkAllowWrong(LinkSrc) then
          raise Exception.Create(MessText(mtkFuncNotAvailabl));
      end; // case
    end;

    if CheckNotValidUser(userID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[userID];
//--------------------------------------------------- отрабатываем запись в базу
    pool:= cntsGRB;
    ibd:= pool.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    LinkSrc:= FDCA.GetSourceGBcode(srcID);
    sWare:= IntToStr(pWareID);
    sCross:= IntToStr(pCrossID);
    sUser:= IntToStr(UserID);
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpWrite, true);

      case OpCode of
      resAdded: begin                // добавляем
          ibs.SQL.Text:= 'select rCrossID, errLink from Vlad_CSS_AddWareCross('+
            sWare+', '+sCross+', '+sUser+', '+IntToStr(LinkSrc)+')';
          ibs.ExecQuery;
          if (ibs.Eof and ibs.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ibs.Fields[1].AsInteger>0) then
            raise EBOBError.Create('связь товара с аналогом в базе отмечена, как неверная')
          else if (ibs.Fields[1].AsInteger<0) then begin
            with Ware do if not AnalogLinks.LinkExists(pCrossID) and
              CheckAnalogLink(pCrossID, srcID) then SortAnalogsByName; // на всяк.случай
            ResCode:= resDoNothing;
            raise EBOBError.Create('Такая '+MessText(mtkWareAnalogLink)+' есть');
          end else if (ibs.Fields[0].AsInteger<1) then
            raise Exception.Create('error add cross Ware='+sWare+' Cross='+sCross);
        end; // resAdded

      resWrong, resNotWrong: begin // меняем признак Wrong
          s:= fnIfStr(OpCode=resWrong, 'T', 'F');
          ibs.SQL.Text:= 'update PMWAREANALOGS set PMWAISWRONG="'+s+'", PMWAUSERCODE='+sUser+
            ' where PMWAWARECODE='+sWare+' and PMWAWAREANALOGCODE='+sCross;
          ibs.ExecQuery;
        end; // resWrong, resNotWrong

      resDeleted: begin              // удаляем
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

//------------------------------------------------------------- отрабатываем кэш
    with Ware do case OpCode of
      resAdded, resNotWrong:                               // добавляем
        if CheckAnalogLink(pCrossID, srcID) then SortAnalogsByName;
      resDeleted, resWrong: DelAnalogLink(pCrossID, True); // удаляем
    end; // case

    mess:= MessText(mtkWareAnalogLink);
    case OpCode of
      resAdded:    Result:= mess+' добавлена';
      resDeleted:  Result:= mess+' удалена';
      resWrong:    Result:= mess+mess1+' отмечена, как неверная';
      resNotWrong: Result:= mess+' восстановлена';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
end;
//==== добавить/удалить линки товара с аналогами по 1 артикулу (загрузка из TDT)
function TDataCache.CheckWareArtCrossLinks(pWareID: Integer; CrossArt: String; crossMF: Integer;
         var ResCode: Integer; srcID: Integer; UserID: Integer=0; ibsORD: TIBSQL=nil): String;
const nmProc = 'CheckWareArtCrossLinks';
// вид операции - ResCode - на входе (resAdded, resDeleted)
// ResCode на выходе: resError- ошибка, resAdded - добавлены, resDeleted - удалены
var ibd: TIBDatabase;
    ibs: TIBSQL;
    Ware: TWareInfo;
    OpCode, i, j, srcGB: Integer;
    mess: string;
    ArCross: array of TCrossInfo; // список аналогов по артикулу CrossArt
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
    if not (OpCode in [resAdded, resDeleted]) then // проверяем код операции
      raise Exception.Create(MessText(mtkNotValidParam)+' операции');

    if (crossMF<1) or (CrossArt='') then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' артикула');

    Ware:= GetWare(pWareID, True);
    if (Ware=NoWare) or Ware.IsArchive then        // проверяем товар
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));

    if OpCode=resAdded then begin
      if (userID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' юзера');
      if (srcID<1) then raise Exception.Create(MessText(mtkNotValidParam)+' источника');
    end; // resAdded

    j:= 0; // счетчик аналогов по артикулу CrossArt
//--------------------------------------------------- отрабатываем запись в базу
    if Assigned(ibsORD) then begin
      ibs:= ibsORD;
      with ibs.Transaction do if not InTransaction then StartTransaction;
    end else begin
      ibd:= cntsOrd.GetFreeCnt; // коды товаров, привязанных к артикулу CrossArt, из базы dbOrder
      ibs:= fnCreateNewIBSQL(ibd, 'ibsOrd_'+nmProc, -1, tpRead, true);
    end;

    try
      if IBS.SQL.Text='' then
        IBS.SQL.Text:= 'select WATDWARECODE from WAREARTICLETD'+
          ' inner join wareoptions on wowarecode=WATDWARECODE and woarhived="F"'+
          ' where WATDARTSUP=:crossMF and WATDARTICLE=:CrossArt and WATDWRONG="F"';
      ibs.ParamByName('crossMF').AsInteger:= crossMF;
      ibs.ParamByName('CrossArt').AsString:= CrossArt;  // артикул TD
      ibs.ExecQuery;
      while not ibs.Eof do begin
        i:= ibs.Fields[0].AsInteger;  // код товара по артикулу-аналогу
        if WareExist(i) then begin
          if Length(ArCross)<(j+1) then SetLength(ArCross, j+100);
          ArCross[j].cross:= i;  // код товара по артикулу-аналогу
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

    ibd:= cntsGRB.GetFreeCnt;                         // пишем в базу Grossbee
    try
      ibs:= fnCreateNewIBSQL(ibd, 'ibsGRB_'+nmProc, -1, tpWrite, true);

      case OpCode of
      resAdded: begin         // добавляем / проверяем аналоги по списку кодов
          ibs.SQL.Text:= 'select rCrossID, errLink from Vlad_CSS_AddWareCross('+
            IntToStr(pWareID)+', :CrossID, '+IntToStr(UserID)+', '+IntToStr(srcGB)+')';
          for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then begin
            ibs.ParamByName('CrossID').AsInteger:= ArCross[j].cross;
            ibs.ExecQuery;
            if not (ibs.Bof and ibs.Eof) and (ibs.Fields[0].AsInteger>0) then begin
              ArCross[j].wrong:= ibs.Fields[1].AsInteger>0; // признак неправильной связки
              ArCross[j].exist:= ibs.Fields[1].AsInteger<0; // признак - уже есть
            end else ArCross[j].cross:= 0; // если линк не записался - обнуляем код
            ibs.Close;
          end;
        end; // resAdded

      resDeleted: begin              // удаляем аналоги по списку кодов
          ibs.SQL.Text:= 'select rCrossID from Vlad_CSS_DelWareCross('+
            IntToStr(pWareID)+', :CrossID, '+IntToStr(srcGB)+')';
          for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then begin
            ibs.ParamByName('CrossID').AsInteger:= ArCross[j].cross;
            ibs.ExecQuery;
            if not (ibs.Bof and ibs.Eof) or (ibs.Fields[0].AsInteger<1) then
              ArCross[j].cross:= 0; // если линк не удалился - обнуляем код
            ibs.Close;
          end;

        end; // resDeleted
      end; // case
      ibs.Transaction.Commit;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(ibd);
    end;

//------------------------------------------------------------- отрабатываем кэш
    case OpCode of
      resAdded: begin  // добавляем / сверяем
          i:= 0; // счетчик добавленных связок
          for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then with ArCross[j] do
            if wrong then Ware.DelAnalogLink(cross, True)
            else if (not exist or not Ware.AnalogLinks.LinkExists(cross)) and
              Ware.CheckAnalogLink(cross, srcID) then inc(i);
          if i>0 then Ware.SortAnalogsByName; // если добавляли - сортируем
        end; // resAdded

      resDeleted:
        for j:= 0 to High(ArCross) do if (ArCross[j].cross>0) then
          Ware.DelAnalogLink(ArCross[j].cross, True);
    end; // case

    mess:= 'связи товара с аналогами по артикулу ';
    case OpCode of
      resAdded:    Result:= mess+'добавлены';
      resDeleted:  Result:= mess+'удалены';
    end;
    ResCode:= OpCode;
  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message, ResCode);
  end;
  SetLength(ArCross, 0);
end;
//============================ добавить линк товара со значением критерия в базу
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
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if (CriName='') then raise EBOBError.Create(MessText(mtkNotValidParam)+' критерия');
    sWare:= intToStr(pWareID);
    try
      ORD_IBD:= cntsOrd.GetFreeCnt;                 // пишем в базу
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
        raise EBOBError.Create('связь товара с критерием в базе отмечена, как неверная')
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
//================================== добавить/редактировать доп.параметры бренда
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
      raise EBOBError.Create(MessText(mtkNotValidParam)+' бренда');

    pPrefix:= trim(pPrefix);
    pAdressWWW:= trim(pAdressWWW);
    pNameWWW:= trim(pNameWWW);

    brand:= WareBrands[pBrandID];

if not flPictNotShow then pPictShowEx:= brand.PictShowExclude;

    if (pNameWWW=brand.NameWWW) and (pPrefix=brand.WarePrefix)
      and (pAdressWWW=brand.adressWWW) and (pDownLoadEx=brand.DownLoadExclude)
      and (pPictShowEx=brand.PictShowExclude) then Exit;

    try
      ORD_IBD:= cntsOrd.GetFreeCnt;                 // пишем в базу
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
//=========================== номер порции значений условий связки 3 (заготовка)
function TDataCache.GetModelNodeWareUseListNumber(pModelID, pNodeID, pWareID: Integer;
         UseList: TStringList): Integer;
const nmProc = 'GetModelNodeWareUseListNumber';
// UseList - список строк <критерий>cStrValueDelim<значение>, в Object - <код TecDoc критерия>
// при посадке из Excel <код TecDoc критерия>=0
// в Result - номер найденной порции, иначе -1
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
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if not Assigned(UseList) or (UseList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- пустой список условий');

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBSr:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBSr_'+nmProc);
                                                   // условия к связкe 3 из ORD
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
        iUseList:= ORD_IBSr.FieldByName('LWMNUPART').AsInteger; // 1 порция
        if ordUses.Count>0 then ordUses.Clear;

        while not ORD_IBSr.Eof and (iUseList=ORD_IBSr.FieldByName('LWMNUPART').AsInteger) do begin
          UseName:= ORD_IBSr.FieldByName('WCRIDESCRUP').AsString;
          UseValue:= ORD_IBSr.FieldByName('WCVSVALUEUP').AsString;
          criTD:= ORD_IBSr.FieldByName('WCRITDCODE').AsInteger;
          ordUses.AddObject(UseName+cStrValueDelim+UseValue, Pointer(criTD));
          TestCssStopException; // проверка остановки системы
          ORD_IBSr.Next;
        end;
        if (ordUses.Count<>UseList.Count) then Continue; // не совпадает кол-во в порции

        for i:= 0 to UseList.Count-1 do begin
          j:= -1; // искомый индекс элемента порции в списке из нашей базы
          criTD:= Integer(UseList.Objects[i]); // код критерия TD
          s:= fnGetBefore(cStrValueDelim, UseList[i]);
          if s='' then begin
            UseName:= AnsiUpperCase(UseList[i]);
            UseValue:= '';
          end else begin
            UseName:= AnsiUpperCase(s);
            UseValue:= AnsiUpperCase(fnGetAfter(cStrValueDelim, UseList[i]));
          end;
          if criTD>0 then begin // если есть код TD
            for ii:= 0 to ordUses.Count-1 do
              if (criTD=Integer(ordUses.Objects[ii])) then begin
                s:= fnGetAfter(cStrValueDelim, ordUses[ii]); // ищем значение
                if s=UseValue then j:= ii;
              end;
          end;
          if j<0 then begin // если не нашли значение критерия
            s:= UseName+cStrValueDelim+UseValue; // ищем строку <критерий>=<значение>
            j:= ordUses.IndexOf(s);
          end;
          if (j<0) then Break;  // если никак не нашли
        end; // for i:= 0 to UseList.Count-1

        if (j>-1) then begin
          Result:= iUseList; // если все нашли - возвращаем номер порции
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
//=================================================== получить текст уведомления
function TDataCache.GetNotificationText(noteID: Integer): String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if Notifications.ItemExists(noteID) then Result:= Notifications[noteID].Name;
end;
//================== записать время показа/ознакомления уведомления пользователю
function TDataCache.SetClientNotifiedKind(userID, noteID, kind: Integer): String;
// kind=0 - показ уведомления, kind>0 - ознакомление
const nmProc='SetClientNotifiedKind';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    sUser, sNote: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try // самые простые проверки
    if not Notifications.ItemExists(noteID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' уведомления');
    if not ClientExist(userID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' пользователя');
    sUser:= IntToStr(userID);
    sNote:= IntToStr(noteID);

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      case kind of
      0: ORD_IBS.SQL.Text:= 'UPDATE OR INSERT INTO NOTIFIEDCLIENTS'+    // показ
           ' (NOCLSHOWTIME, NOCLCLIENT, NOCLNOTE) VALUES (current_timestamp, '+
           sUser+', '+sNote+') MATCHING (NOCLCLIENT, NOCLNOTE)';
      else                                                       // ознакомление
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
//==================== добавить линки связки 3 с порцией значений условий в базу
function TDataCache.AddModelNodeWareUseListLinks(pModelID, pNodeID, pWareID,
         UserID, srcID: Integer; var UseList: TStringList; var pPart: Integer): String;
const nmProc = 'AddModelNodeWareUseListLinks';
// проверка существования 3-й связки и отсутствия порции - до вызова функции !!!
// UseList - список строк <критерий>cStrValueDelim<значение>, в Object - <код TecDoc критерия>
// при посадке из Excel <код TecDoc критерия> = 0
// pPart на выходе - номер порции (нужен для связи с инфо-текстами)
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    criTD, iUseList, i: Integer;
    UseName, UseValue, s: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try // самые простые проверки
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if not Assigned(UseList) or (UseList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- пустой список условий');

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
        ORD_IBS.ParamByName('iUseList').AsInteger:= iUseList; // номер порции (может быть <1)
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Eof and ORD_IBS.Bof) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else begin
          if ORD_IBS.FieldByName('errLink').AsInteger>0 then
            raise EBOBError.Create(MessText(mtkWareModNodeUse)+' в базе отмечено, как неверное');
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
      pPart:= iUseList; // возвращаем номер порции
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
//==================== удалить линки связки 3 с порцией значений условий из базы
function TDataCache.DelModelNodeWareUseListLinks(pModelID, pNodeID, pWareID, iUseList: Integer): String;
const nmProc = 'DelModelNodeWareUseListLinks';
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  ORD_IBS:= nil;
  try
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if (iUseList<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' номера списка условий');

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
//==================== заменить линки связки 3 с порцией значений условий в базе
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
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');

    if (pPart<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' номера списка условий');
    if not Assigned(UseList) or (UseList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- пустой список условий');

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
        ORD_IBS.ParamByName('iUseList').AsInteger:= pPart; // номер порции
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Eof and ORD_IBS.Bof) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else begin
          if ORD_IBS.FieldByName('errLink').AsInteger>0 then
            raise EBOBError.Create(MessText(mtkWareModNodeUse)+' в базе отмечено, как неверное');
          if (ORD_IBS.FieldByName('partID').AsInteger<1) then begin
            s:= 'error add use part: Model='+IntToStr(pModelID)+' Node='+IntToStr(pNodeID)+
                ' Ware='+IntToStr(pWareID)+' Cri='+UseName+' Value='+UseValue;
            raise Exception.Create(s);
          end;
          if pPart<>ORD_IBS.FieldByName('partID').AsInteger then
            raise EBOBError.Create('несовпадение номеров порций');            // ???
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
//==================================== номер порции текстов связки 3 (заготовка)
function TDataCache.GetModelNodeWareTextListNumber(pModelID, pNodeID, pWareID: Integer;
         TxtList: TStringList; nTxtList: Integer=0; ORD_IBSr: TIBSQL=nil): Integer;
const nmProc = 'GetModelNodeWareTextListNumber';
// ORD_IBSr передается при пакетной загрузке для увеличения скорости обработки
// TxtList - список, в Object - <код supTD текста>
// String - <IntToStr(код типа текста)>=<идентификатор TecDoc>+cSpecDelim+<текст>
// при посадке из Excel <идентификатор TecDoc>='', <код supTD текста>=0
// в Result - номер найденной порции, иначе -1
// если задан nTxtList - проверяем только заданную порцию
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
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if not Assigned(TxtList) or (TxtList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- пустой список текстов');
    try
      if flCreate then begin
        ORD_IBD:= cntsOrd.GetFreeCnt;
        ORD_IBSr:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBSr_'+nmProc);
      end else ORD_IBSr.Close;
                                                   // тексты к связкe 3 из ORD
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
        iTxtList:= ORD_IBSr.FieldByName('LWNMTPART').AsInteger; // 1 порция
        if ordTxts.Count>0 then ordTxts.Clear;
        ordTxts.Sorted:= False;
        while not ORD_IBSr.Eof and (iTxtList=ORD_IBSr.FieldByName('LWNMTPART').AsInteger) do begin
          supTD   := ORD_IBSr.FieldByName('WITSUPTD').AsInteger;
          TypeStr := ORD_IBSr.FieldByName('LWNMTinfotype').AsString;
          TxtValue:= ORD_IBSr.FieldByName('WITTMTD').AsString+cSpecDelim+
                     ORD_IBSr.FieldByName('ITTEXT').AsString;
          ordTxts.AddObject(TypeStr+cStrValueDelim+TxtValue, Pointer(supTD));
                   // <IntToStr(код типа текста)>=<идентификатор TecDoc>+cSpecDelim+<текст>
          TestCssStopException; // проверка остановки системы
          ORD_IBSr.Next;
        end;
        if (ordTxts.Count<>TxtList.Count) then Continue; // не совпадает кол-во в порции

        ordTxts.Sort;
        ordTxts.Sorted:= True;
        flNo:= False;
        for i:= 0 to TxtList.Count-1 do begin
          flNo:= not ordTxts.Find(TxtList[i], j); // ищем строку <тип текста>=<идентиф.>+cSpecDelim+<текст>
          if flNo then Break;
          supTD:= Integer(TxtList.Objects[i]); // проверяем код supTD
          flNo:= (supTD<>Integer(ordTxts.Objects[j]));
          if flNo then Break;
        end;
        if flNo then Continue; // не совпадает список порции

        Result:= iTxtList; // если порция найдена - возвращаем номер порции
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
//===================================== номера порций условий и текстов связки 3
function TDataCache.FindModelNodeWareUseAndTextListNumbers(pModelID, pNodeID, pWareID: Integer;
         var UseLists: TASL; var TxtLists: TASL; var ListNumbers: Tai; var ErrUseNums: Tai;
         var ErrTxtNums: Tai; FromTDT: Boolean=False; CheckTexts: Boolean=False): String;
const nmProc = 'FindModelNodeWareUseAndTextListNumbers';
// FromTDT=True - только с источником из TDT, CheckTexts - обязательно проверять тексты
// ListNumbers - массив номеров порций (индекс соотв. UseLists, TxtLists)
// ErrUseNums  - массив номеров порций условий, кот.надо удалять
// ErrTxtNums  - массив номеров порций текстов, кот.надо удалять
// UseLists - массив списков строк <критерий>=<значение>, в Object - <код TecDoc критерия>
//   при посадке из Excel <код TecDoc критерия>=0
// TxtLists - массив списков текстов, в Object - <код supTD текста>
//   String - <IntToStr(код типа текста)>=<идентификатор TecDoc>+cSpecDelim+<текст>
//   при посадке из Excel <идентификатор TecDoc>='', <код supTD текста>=0
// в Result - сообщение об ошибке
// на выходе в найденных UseLists[i] - Delimiter=LCharGood, в ненайденных - Delimiter=LCharUpdate
var ORD_IBD: TIBDatabase;
    ORD_IBS: TIBSQL;
    flErr, fl, flKod: Boolean;
    kodTD, TypeID, iUseList, ij, iAr, iTxtList: Integer;
    s, UseName, UseValue, TxtValue, TypeStr, TxtTM: String;
    ArOrdUses: TarCriInfo;
    ArOrdTexts: TarTextInfo;
  //---------------------------------------------------- проверка порции условий
  function CheckUseList(index: Integer; var ArOrdUses: TarCriInfo): Boolean;
  var i, ii, j: Integer;
  begin
    j:= -1;
    with UseLists[index] do for i:= 0 to Count-1 do try  // сверяем порцию с ArOrdUses
      j:= -1; // искомый индекс элемента порции в списке из нашей базы
      if Assigned(Objects[i]) then kodTD:= Integer(Objects[i]) else kodTD:= 0; // код критерия TD
      UseValue:= fnGetAfter(cStrValueDelim, Strings[i]);
      flKod:= (kodTD>0);
      if flKod then UseName:= ''  // если есть код - нужно только значение
      else begin
        UseName:= fnGetBefore(cStrValueDelim, Strings[i]);
        if UseName='' then UseName:= Strings[i];
      end;
      if (UseValue<>'') then UseValue:= AnsiUpperCase(UseValue);
      if (UseName<>'') then UseName:= AnsiUpperCase(UseName);
      for ii:= 0 to iAr-1 do begin
        if flKod then fl:= (kodTD=ArOrdUses[ii].CRITD) // если есть код - проверяем код и значение
        else fl:= (UseName=ArOrdUses[ii].CriNameUp);   // иначе проверяем наименование и значение
        if fl and (UseValue=ArOrdUses[ii].ValueUp) then begin
          j:= ii;
          Break;
        end;
      end; // for ii:= 0 to iAr-1
      if (j<0) then Break;  // если строка не найдена
    except end; // with UseLists[index] do for i:= 0 to Count-1
    Result:= (j>-1);
  end;
  //---------------------------------------------------- проверка порции текстов
  function CheckTxtList(index: Integer; var ArOrdTexts: TarTextInfo): Boolean;
  var i, ii, j: Integer;
  begin
    j:= -1;
    with TxtLists[index] do for i:= 0 to Count-1 do try  // ищем такую же порцию в ArOrdTexts
      j:= -1; // индекс элемента TxtLists[index] в списке из нашей базы
      if Assigned(Objects[i]) then kodTD:= Integer(Objects[i]) else kodTD:= 0; // код supTD
      // <IntToStr(код типа текста)>=<идентификатор TecDoc>+cSpecDelim+<текст>
      TypeStr:= fnGetBefore(cStrValueDelim, Strings[i]);
      TypeID:= StrToIntDef(TypeStr, 0);
      s:= fnGetAfter(cStrValueDelim, Strings[i]);
      TxtTM:= fnGetBefore(cSpecDelim, s);
      flKod:= (kodTD>0) and (TxtTM<>'');  // если есть supTD и идентификатор и CheckTexts=False - текст не нужен
      if flKod and not CheckTexts then TxtValue:= ''
      else TxtValue:= AnsiUpperCase(StringReplace(fnGetAfter(cSpecDelim, s), ' ', '', [rfReplaceAll]));

      for ii:= 0 to iAr-1 do begin
        if (TypeID<>ArOrdTexts[ii].infotype) then Continue; // если тип не тот
        fl:= False;
        if flKod then          // если есть supTD и идентификатор - проверяем их
          fl:= (kodTD=ArOrdTexts[ii].supTD) and (TxtTM=ArOrdTexts[ii].tmTD);
        if not fl or CheckTexts then fl:= (TxtValue=ArOrdTexts[ii].search); // проверяем поисковый текст
        if fl then begin
          j:= ii;
          Break;
        end;
      end; // for ii:= 0 to iAr-1
      if (j<0) then Break;  // если строка не найдена
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
    if (pModelID<1) then raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    if (pNodeID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');
    if (pWareID<1)  then raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if (Length(UseLists)<1) and (Length(TxtLists)<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+'- пустой набор условий');
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try                                    // сбрасываем признаки
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBSr_'+nmProc);
      if not Assigned(ORD_IBS) then raise EBOBError.Create(MessText(mtkErrConnectToDB));
      for ij:= 0 to High(UseLists) do UseLists[ij].Delimiter:= LCharUpdate;
      for ij:= 0 to High(TxtLists) do TxtLists[ij].Delimiter:= LCharUpdate;
      for ij:= 0 to High(ListNumbers) do ListNumbers[ij]:= 0;
      //----------------------------------- все порции условий к связкe 3 из ORD
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
        iUseList:= ORD_IBS.FieldByName('LWMNUPART').AsInteger; // номер порции
        iAr:= 0; // счетчик условий в ArOrdUses
        while not ORD_IBS.Eof and (iUseList=ORD_IBS.FieldByName('LWMNUPART').AsInteger) do begin
          if High(ArOrdUses)<iAr then SetLength(ArOrdUses, iAr+10);
          ArOrdUses[iAr].CriNameUp:= ORD_IBS.FieldByName('WCRIDESCRUP').AsString;
          ArOrdUses[iAr].ValueUp  := ORD_IBS.FieldByName('WCVSVALUEUP').AsString;
          ArOrdUses[iAr].CRITD    := ORD_IBS.FieldByName('WCRITDCODE').AsInteger;
          inc(iAr);
          TestCssStopException; // проверка остановки системы
          ORD_IBS.Next;
        end;

        flErr:= True;
        for ij:= 0 to High(UseLists) do begin
          if (iAr<>UseLists[ij].Count) then Continue; // не совпадает кол-во в порции
          if (ListNumbers[ij]>0) then Continue;       // порция уже определена
          if CheckUseList(ij, ArOrdUses) then begin // если нашли
            ListNumbers[ij]:= iUseList; // запоминаем номер порции
            UseLists[ij].Delimiter:= LCharGood; // признак найденной порции
            flErr:= False;
            Break;
          end;
        end; // for ij:= 0 to High(UseLists)

        if flErr and (fnInIntArray(iUseList, ErrUseNums)<0) then begin // если не нашли
          ij:= Length(ErrUseNums);
          SetLength(ErrUseNums, ij+1);
          ErrUseNums[ij]:= iUseList;
        end;
      end; // while not ORD_IBSr.Eof
      ORD_IBS.Close;

      //----------------------------------------------- тексты к связкe 3 из ORD
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
        iTxtList:= ORD_IBS.FieldByName('LWNMTPART').AsInteger; // номер порции текстов

        if (fnInIntArray(iTxtList, ErrUseNums)>-1) then begin // если соотв.порция условий помечена на удаление
          if (fnInIntArray(iTxtList, ErrTxtNums)<0) then begin
            ij:= Length(ErrTxtNums);
            SetLength(ErrTxtNums, ij+1);
            ErrTxtNums[ij]:= iTxtList;
          end;                                                // прокручиваем
          TestCssStopException;
          while not ORD_IBS.Eof and (iTxtList=ORD_IBS.FieldByName('LWNMTPART').AsInteger) do ORD_IBS.Next;
          Continue;
        end;

        iAr:= 0; // счетчик текстов в ArOrdTexts
        while not ORD_IBS.Eof and (iTxtList=ORD_IBS.FieldByName('LWNMTPART').AsInteger) do begin
          if High(ArOrdTexts)<iAr then SetLength(ArOrdTexts, iAr+10);
          ArOrdTexts[iAr].supTD   := ORD_IBS.FieldByName('WITSUPTD').AsInteger;
          ArOrdTexts[iAr].infotype:= ORD_IBS.FieldByName('LWNMTinfotype').AsInteger;
          ArOrdTexts[iAr].tmTD    := ORD_IBS.FieldByName('WITTMTD').AsString;
          ArOrdTexts[iAr].text    := ORD_IBS.FieldByName('ITTEXT').AsString;
          ArOrdTexts[iAr].search  := ORD_IBS.FieldByName('ITSEARCH').AsString;
          inc(iAr);
          TestCssStopException; // проверка остановки системы
          ORD_IBS.Next;
        end;
        ij:= fnInIntArray(iTxtList, ListNumbers); // ищем индекс порции в найденных порциях условий

        flErr:= True;
        if (ij<0) then begin // если индекс <0 (не найдены условия) - ищем порцию только с текстом
          for ij:= 0 to High(TxtLists) do begin
            if (ListNumbers[ij]>0) then Continue;       // уже найдена порция условий или текстов
            if (UseLists[ij].Count>0) then Continue;    // есть условия
            if (TxtLists[ij].Count<1) then Continue;    // нет текстов
            if (iAr<>TxtLists[ij].Count) then Continue; // не совпадает кол-во в порции
            if CheckTxtList(ij, ArOrdTexts) then begin
              ListNumbers[ij]:= iTxtList;
              TxtLists[ij].Delimiter:= LCharGood;       // признак найденной порции
              flErr:= False;
              Break;
            end;
          end; // for ij:= 0 to High(TxtLists)

        end else if (TxtLists[ij].Count>0) and (iAr=TxtLists[ij].Count)
          and CheckTxtList(ij, ArOrdTexts) then begin
          TxtLists[ij].Delimiter:= LCharGood; // если все совпало - признак найденной порции
          flErr:= False;
        end;

        if flErr and (fnInIntArray(iTxtList, ErrTxtNums)<0) then begin // если не нашли
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
      Result:= 'ошибка сверки условий и текстов';
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//========================== добавить / удалить линки связки 3 с порцией текстов
function TDataCache.CheckModelNodeWareTextListLinks(var ResCode: Integer;
         pModelID, pNodeID, pWareID: Integer; TxtList: TStringList;
         UserID: Integer=0; srcID: Integer=0; PartID: Integer=0): String;
const nmProc = 'CheckModelNodeWareTextListLinks';
// TxtList - список, в Object - <код supTD текста>
// String - <IntToStr(код типа текста)>+cSpecDelim+<название типа>=<идентификатор TecDoc>+cSpecDelim+<текст>
// если задан  <IntToStr(код типа текста)> - <название типа> может быть ''
// при посадке из Excel <идентификатор TecDoc>='', <код supTD текста>=0
// srcID, userID нужны только при добавлении
// ResCode на входе - вид операции (resAdded, resDeleted)
// ResCode на выходе - результат: resError - ошибка, resDoNothing - не менялось,
// resAdded - порция текстов добавлена, resDeleted - порция текстов удалена
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
//-------------------------------------------------------------------- проверяем
    if not (OpCode in [resAdded, resDeleted]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');
    if (OpCode=resAdded) then begin
      if ((userID<1) or (srcID<1)) then  // если добавление
        raise EBOBError.Create(MessText(mtkNotParams));
      if not Assigned(TxtList) or (TxtList.Count<1) then
        raise EBOBError.Create(MessText(mtkNotValidParam)+'- пустой список текстов');
    end;
    if (OpCode=resDeleted) and (PartID<1) then  // если удаление
      raise EBOBError.Create(MessText(mtkNotValidParam)+' номера списка текстов');

    if not WareExist(pWareID) or GetWare(pWareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if not FDCA.Models.ModelExists(pModelID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    SysID:= FDCA.Models[pModelID].TypeSys;
    if not FDCA.AutoTreeNodesSys[SysID].NodeExists(pNodeID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' узла');

//--------------------------------------------------- отрабатываем запись в базу
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);

      if OpCode=resAdded then begin // добавляем
        ORD_IBS.SQL.Text:= 'select PartID, errLink from AddModelNodeWarePartTextLink_n('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+
          ', :PartID, :TypeID, :pSupID, :tmTD, :pText, '+IntToStr(UserID)+', '+IntToStr(srcID)+')';

        for i:= 0 to TxtList.Count-1 do begin
          if not Assigned(TxtList.Objects[i]) then pSupID:= 0
          else pSupID:= Integer(TxtList.Objects[i]);
          TypeStr:= fnGetBefore(cStrValueDelim, TxtList[i]);  // код типа текста символьный
          s:= fnGetAfter(cStrValueDelim, TxtList[i]);         // часть TxtList[i] с текстом
          tmTD:= fnGetBefore(cSpecDelim, s);                  // идентификатор TecDoc
          TextValue:= fnGetAfter(cSpecDelim, s);              // текст
          ORD_IBS.ParamByName('TypeID').AsString:= TypeStr;
          ORD_IBS.ParamByName('PartID').AsInteger:= PartID;
          ORD_IBS.ParamByName('tmTD').AsString:= tmTD;
          ORD_IBS.ParamByName('pText').AsString:= TextValue;
          ORD_IBS.ParamByName('pSupID').AsInteger:= pSupID;
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Eof and ORD_IBS.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ORD_IBS.Fields[1].AsInteger>0) then
            raise EBOBError.Create(MessText(mtkWareModNodeText)+' в базе отмечена, как неверная')
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
        Result:= MessText(mtkWareModNodeTexts)+' добавлен';

      end else begin // удаляем из базы
        ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWarePartTextLinks('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+IntToStr(PartID)+')';
        ORD_IBS.ExecQuery;
        Result:= MessText(mtkWareModNodeTexts)+' удален';
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
//==== добавить / удалить линк связки 3 с текстом (порция 1 - загрузка из Excel)
function TDataCache.CheckModelNodeWareTextLink(var ResCode: Integer;
         pModelID, pNodeID, pWareID: Integer; TextValue: String; TypeID: Integer=0;
         TypeName: String=''; UserID: Integer=0; srcID: Integer=0): String;
// srcID, userID нужны только при добавлении, если задан TypeID - TypeName игнорируется !!!
const nmProc = 'CheckModelNodeWareTextLink';
// ResCode на входе - вид операции (resAdded, resDeleted)
// ResCode на выходе - результат: resError - ошибка, resDoNothing - не менялось, 
// resAdded - связка добавлена, resDeleted - связка удалена
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
//-------------------------------------------------------------------- проверяем
    if not (OpCode in [resAdded, resDeleted]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');
    if (TextValue='') then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' текста');
    if ((TypeID<1) and (TypeName='')) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' типа текста');
    if not WareExist(pWareID) or GetWare(pWareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if not FDCA.Models.ModelExists(pModelID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' модели');
    SysID:= FDCA.Models[pModelID].TypeSys;
    if not FDCA.AutoTreeNodesSys[SysID].NodeExists(pNodeID) then
      raise EBOBError.Create(MessText(mtkNotEnoughParams));

    if (OpCode=resAdded) and ((userID<1) or (srcID<1)) then  // если добавление
      raise EBOBError.Create(MessText(mtkNotParams));

    with FDCA.TypesInfoModel do if not ItemExists(TypeID) then begin // ищем тип текста
      i:= InfoModelList[11].IndexOf(TypeName);
      if i<0 then raise EBOBError.Create('не найден вид текста');
      TypeID:= Integer(InfoModelList[11].Objects[i]);
    end;

//--------------------------------------------------- отрабатываем запись в базу
    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      if OpCode=resAdded then begin // добавляем
        ORD_IBS.SQL.Text:= 'select linkID, errLink from AddModelNodeWareTextLink_new('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+
          IntToStr(TypeID)+', 0, "", :pText, '+IntToStr(UserID)+', '+IntToStr(srcID)+')';
        ORD_IBS.ParamByName('pText').AsString:= TextValue;
        ORD_IBS.ExecQuery;
        if (ORD_IBS.Eof and ORD_IBS.Bof) or (ORD_IBS.Fields[0].AsInteger<1) then
          raise EBOBError.Create(MessText(mtkErrAddRecord))
        else if (ORD_IBS.Fields[1].AsInteger>0) then
          raise EBOBError.Create(MessText(mtkWareModNodeText)+' в базе отмечена, как неверная')
        else if (ORD_IBS.Fields[1].AsInteger<0) then begin
          ResCode:= resDoNothing;
          raise EBOBError.Create(MessText(mtkWareModNodeText)+' есть')
        end else Result:= MessText(mtkWareModNodeText)+' добавлена';

      end else begin // удаляем из базы
        ORD_IBS.SQL.Text:= 'execute procedure DelModelNodeWareTextLink_new('+
          IntToStr(pModelID)+', '+IntToStr(pNodeID)+', '+IntToStr(pWareID)+', '+
          IntToStr(TypeID)+', 0, 0, "", :pText)';
        ORD_IBS.ParamByName('pText').AsString:= TextValue;
        ORD_IBS.ExecQuery;
        Result:= MessText(mtkWareModNodeText)+' удалена';
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
//=================================== найти код элемента списка по имени и SupID
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
//=================================================== добавить файл в базу и кеш
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
//=============================================== удаление неиспользуемых файлов
function TDataCache.CheckWareFiles(var delCount: Integer): String;
const nmProc = 'CheckWareFiles';
// штатно вызывается в AddLoadWaresInfoFromTDT после окончания загрузки
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
//=============== добавить/удалить линк товара с файлом (toCache=True - и в кеше)
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
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');
    if not WareExist(pWareID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');
    if not FWareFiles.ItemExists(pFileID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' файла');

    Ware:= GetWare(pWareID);
    if Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' товара');

    case OpCode of
    resAdded: begin
        if Ware.FileLinks.LinkExists(pFileID) then begin
          ResCode:= resDoNothing;
          raise EBOBError.Create('Такая связка товара с файлом уже есть');
        end;
        if (UserID<1) or (pSrcID<1) then
          raise EBOBError.Create(MessText(mtkNotEnoughParams));
      end;
    resDeleted: begin
        if not Ware.FileLinks.LinkExists(pFileID) then begin
          ResCode:= resDoNothing;
          raise EBOBError.Create('Не найдена связка товара с файлом');
        end;
        if (pSrcID>0) and (GetLinkSrc(Ware.FileLinks[pFileID])<>pSrcID) then
          raise EBOBError.Create('не совпадает источник');
      end;
    end; // case

    ORD_IBD:= cntsOrd.GetFreeCnt;                 // пишем в базу
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
            raise EBOBError.Create('связка товара с файлом отмечена, как ошибочная')
//          else if (ORD_IBS.Fields[0].AsInteger<1) then
//            raise Exception.Create('связка товара с файлом уже есть')
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

    if toCache then with Ware.FileLinks do begin // добавляем в кеш / удаляем из кеша линк товара с файлом
      case OpCode of
      resAdded: begin
          p:= FWareFiles[pFileID];
          AddLinkItem(TFlagLink.Create(pSrcID, p, linkURL));
        end;
      resDeleted: DeleteLinkItem(pFileID);
      end; // case
    end; // if toCache

    case OpCode of
    resAdded  : Result:= 'связка товара с файлом добавлена';
    resDeleted: Result:= 'связка товара с файлом удалена';
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
//================ добавить/удалить линк товара с сопут.товаром (Excel, вручную)
function TDataCache.CheckWareSatelliteLink(pWareID, pSatelID: Integer;
         var ResCode: Integer; srcID: Integer=0; UserID: Integer=0): String;
const nmProc = 'CheckWareSatelliteLink';
// ResCode на входе - вид операции (resAdded, resDeleted, resWrong, resNotWrong)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось, resAdded - добавлена,
// resDeleted - удалена, resWrong - отмечена, как неверная, resNotWrong - восстановлена
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
    if not (OpCode in [resAdded, resDeleted, resWrong, resNotWrong]) then // проверяем код операции
      raise Exception.Create(MessText(mtkNotValidParam)+' операции');

    Ware:= GetWare(pWareID, True);
    if (Ware=NoWare) or Ware.IsArchive then                   // проверяем товар
      raise Exception.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));
    if Ware.IsINFOgr then                   // проверяем товар
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - инфо-товар');

    Satel:= GetWare(pSatelID, True);
    if (Satel=NoWare) or Satel.IsArchive then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' сопут.товара');
    if Satel.IsINFOgr then                   // проверяем товар
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - сопут.инфо-товар');

    if not CheckWaresEqualSys(pWareID, pSatelID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - разные бизнес-направления');

    if Ware.SatelLinks.LinkExists(pSatelID) then begin // проверка существования сопут.товара
      mess:= '';
      case OpCode of
        resAdded   : mess:= 'Такая '+MessText(mtkWareSatelLink)+' есть';
        resNotWrong: mess:= MessText(mtkWareSatelLink)+' не отмечена, как ошибочная';
      end; // case
      if mess<>'' then begin
        ResCode:= resDoNothing;
        raise Exception.Create(mess);
      end;
    end else if (OpCode in [resDeleted, resWrong]) then begin
      ResCode:= resDoNothing;
      raise Exception.Create('Не найдена '+MessText(mtkWareSatelLink));
    end;
                       // проверка необходимых параметров и доступности операции
    if (OpCode in [resAdded, resNotWrong, resWrong]) and (userID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' юзера')
    else if (OpCode in [resAdded]) and (srcID<1) then
      raise Exception.Create(MessText(mtkNotValidParam)+' источника');

//--------------------------------------------------- отрабатываем запись в базу
    ORD_IBD:= cntsOrd.GetFreeCnt;                 // пишем в базу
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, true);

      case OpCode of
      resAdded: begin                // добавляем
          ORD_IBS.SQL.Text:= 'select linkID, errLink from AddWareSatellite('+
            IntToStr(pWareID)+', '+IntToStr(pSatelID)+', '+IntToStr(UserID)+', '+IntToStr(srcID)+')';
          ORD_IBS.ExecQuery;
          if (ORD_IBS.Eof and ORD_IBS.Bof) then
            raise EBOBError.Create(MessText(mtkErrAddRecord))
          else if (ORD_IBS.Fields[1].AsInteger>0) then
            raise EBOBError.Create(MessText(mtkWareSatelLink)+' в базе отмечена, как неверная')
          else if (ORD_IBS.Fields[1].AsInteger<0) then begin
            with Ware do if not SatelLinks.LinkExists(pSatelID) then begin // на всяк.случай
              SatelLinks.CheckLink(pSatelID, srcID, Satel);
              SatelLinks.SortByLinkName;
            end;
            ResCode:= resDoNothing;
            raise EBOBError.Create('Такая '+MessText(mtkWareSatelLink)+' есть');
          end else if (ORD_IBS.Fields[0].AsInteger<1) then
            raise Exception.Create('error add link Ware='+IntToStr(pWareID)+
                                   ' satellite='+IntToStr(pSatelID));
        end; // resAdded

      resWrong, resNotWrong: begin // меняем признак Wrong
          ORD_IBS.SQL.Text:= 'update LinkWareSatellites set LWSWRONG="'+
            fnIfStr(OpCode=resWrong, 'T', 'F')+'", LWSUSERID='+IntToStr(UserID)+
            ' where LWSWARECODE='+IntToStr(pWareID)+' and LWSSatel='+IntToStr(pSatelID);
          ORD_IBS.ExecQuery;
        end; // resWrong, resNotWrong

      resDeleted: begin              // удаляем
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

//------------------------------------------------------------- отрабатываем кэш
    with Ware do case OpCode of
      resAdded, resNotWrong: begin                         // добавляем
          SatelLinks.CheckLink(pSatelID, srcID, Satel);
          SatelLinks.SortByLinkName;
        end;
      resDeleted, resWrong: SatelLinks.DeleteLinkItem(pSatelID); // удаляем
    end; // case

    mess:= MessText(mtkWareAnalogLink);
    case OpCode of
      resAdded:    Result:= mess+' добавлена';
      resDeleted:  Result:= mess+' удалена';
      resWrong:    Result:= mess+' отмечена, как неверная';
      resNotWrong: Result:= mess+' восстановлена';
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
//  FarClientInfo[0]:= TClientInfo.Create(0, 'Неизв.клиент');
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
  try // если надо менять длину
    CS_clients.Enter;
    jj:= Length(FarClientInfo);        // добавляем длину массива
    SetLength(FarClientInfo, i+100);   // и инициируем элементы
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
    SetLength(FarClientInfo, j); // обрезаем по мах.коду
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
//  FarFirmInfo[0]:= TFirmInfo.Create(0, 'Неизв.клиент');
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
    jj:= Length(FarFirmInfo);         // добавляем длину массива
    SetLength(FarFirmInfo, pID+100);  // и инициируем элементы
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
    SetLength(FarFirmInfo, j); // обрезаем по мах.коду
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
//============================================================== получить строку
function TInfoBoxItem.GetStrI(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then exit;
  case ik of
    ik8_1: Result:= FName;       // заголовок
    ik8_2: Result:= FLinkToPict; // ссылка на рисунок
    ik8_3: Result:= FLinkToSite; // ссылка на сайт
  end;
end;
//============================================================= записать строку
procedure TInfoBoxItem.SetStrI(const ik: T8InfoKinds; Value: String);
begin
  if not Assigned(self) then exit;
  case ik of
    ik8_1: if (FName      <>Value) then FName      := Value; // заголовок
    ik8_2: if (FLinkToPict<>Value) then FLinkToPict:= Value; // ссылка на рисунок
    ik8_3: if (FLinkToSite<>Value) then FLinkToSite:= Value; // ссылка на сайт / окно описания
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
//============================================== проверяем корректность значения
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
    if NotEmpty then Result:= MessText(mtkNotValidParam)+' - пустое значение';
    case ItemType of
      constInteger, constDouble, constDateTime: pValue:= '0';
    end;

  end else try
    case ItemType of
      constInteger: begin  // целое значение
          i:= StrToInt(pValue);
          pValue:= IntToStr(i);
        end;
      constDouble: begin  // вещественное значение
          d:= StrToFloat(StrWithFloatDec(pValue)); // проверяем DecimalSeparator
          pValue:= FormatFloat('#0.'+StringOfChar('0', Precision), d);
        end;
      constDateTime: begin  // значение даты
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
//================================================== получить строковое значение
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
//================================================== записать строковое значение
procedure TConstItem.SetStrCI(const ik: T8InfoKinds; pValue: String);
var s: string;
begin
  if not Assigned(self) then Exit;
  try
    if ik in [ik8_1, ik8_2, ik8_3] then begin 
      s:= CheckConstValue(pValue);          // проверяем корректность значения
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
//======================================================= получить вещ. значение
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
//======================================================= получить значение даты
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
//======================================================= записать значение даты
procedure TConstItem.SetDateCI(const ik: T8InfoKinds; pValue: TDateTime);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_4: if (FLastTime<>pValue) then FLastTime:= pValue; // время посл.изменения
  end;
end;

//====================================================== получить целое значение
function TConstItem.GetIntCI(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: if (ItemType=constInteger) then Result:= StrToIntDef(StrValue, 0);
    ik8_2: if (ItemType=constInteger) then Result:= StrToIntDef(FMaxValue, 0);
    ik8_3: if (ItemType=constInteger) then Result:= StrToIntDef(FMinValue, 0);
    ik8_4: Result:= FSrcID;     // Тип
    ik8_5: Result:= FOrderNum;  // кол-во знаков после запятой в типе Double
    ik8_6: Result:= FSubCode;   // код юзера посл.изменений
  end;
end;
//====================================================== записать целое значение
procedure TConstItem.SetIntCI(const ik: T8InfoKinds; pValue: Integer);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_4: if (FSrcID    <>pValue) then FSrcID   := pValue; // Тип
    ik8_5: if (FOrderNum <>pValue) then FOrderNum:= pValue; // кол-во знаков после запятой в типе Double
    ik8_6: if (FSubCode  <>pValue) then FSubCode := pValue; // код юзера посл.изменений
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
  CS_cont       := TCriticalSection.Create; // для изменения параметров
  ContDestPointCodes:= TIntegerList.Create; // коды торговых точек контракта
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
//================================================================= получить код
function TContract.GetIntFC(const ik: T16InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik16_1 : Result:= FSubCode;       // ContFirm
//    ik16_2 : Result:= FCurrency;
    ik16_3 : Result:= FDutyCurrency;
    ik16_4 : Result:= FStatus;        // статус [cstClosed, cstBlocked, cstWorked]
    ik16_5 : Result:= FWhenBlocked;
    ik16_6 : Result:= FCredDelay;
    ik16_7 : Result:= FCredCurrency;
    ik16_8 : Result:= FOrderNum;      // MainStorage
    ik16_9 : Result:= GetContManager;
    ik16_10: if Cache.DprtExist(FOrderNum) then // код филиала (по главному складу)
               Result:= Cache.arDprtInfo[FOrderNum].FilialID;
    ik16_11: Result:= FFacCenter;
    ik16_12: Result:= FPayType;
    ik16_13: Result:= GetContFaccParent;
    ik16_14: Result:= FContPriceType;
    ik16_15: Result:= FLegalEntity;
    ik16_16: Result:= FCredProfile;
  end;
end;
//================================================================= записать код
procedure TContract.SetIntFC(const ik: T16InfoKinds; Value: Integer);
begin
  if not Assigned(self) then Exit else case ik of
    ik16_1 : if (FSubCode      <>Value) then FSubCode      := Value; // ContFirm
//    ik16_2 : if (FCurrency     <>Value) then FCurrency     := Value;
    ik16_3 : if (FDutyCurrency <>Value) then FDutyCurrency := Value;
    ik16_4 : if (FStatus       <>Value) then FStatus       := Value; // статус [cstClosed, cstBlocked, cstWorked]
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
//======================================================== получить вещ.значение
function TContract.GetDoubFC(const ik: T8InfoKinds): Single;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FContSumm;
    ik8_2: Result:= FCredLimit;
    ik8_3: Result:= FDebtSum;
    ik8_4: Result:= FOrderSum;
    ik8_5: Result:= FPlanOutSum;
    ik8_6: Result:= FRedSum;     // просроченная сумма
    ik8_7: Result:= FVioletSum;  // сумма к оплате в ближайшее время
  end;
end;
//======================================================== записать вещ.значение
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
//============================================================== записать строку
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
//============================================================== получить строку
function TContract.GetStrFC(const ik: T16InfoKinds): String;
var i: Integer;
    le: TBaseDirItem;
    firma: TFirmInfo;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik16_2: Result:= FContEmail;
    ik16_3: Result:= FWarnMessage;
    ik16_4: Result:= IntToStr(MainStorage);  // код склада по умолчанию символьный
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
    ik16_6: Result:= IntToStr(CredCurrency); // CredCurrency символьный
    ik16_7: Result:= GetContFaccName;        // наименование ЦФУ
    ik16_8: Result:= GetContFaccParentName;  // наименование ЦФУ
    ik16_9: Result:= FContComments;          // комментарий
  end;
end;
//==================================================== поиск менеджера контракта
function TContract.FindContManager(var Empl: TEmplInfoItem): boolean;
var i, emplID: Integer;
begin
  Result:= False;
  Empl:= nil;
  emplID:= 0;
  if not Assigned(self) then Exit;
  if not Result then with GetContBKEempls do for i:= 0 to Count-1 do begin // по BKE ищем первого
    emplID:= Items[i];
    if not Cache.EmplExist(emplID) then Cache.TestEmpls(emplID);
    Result:= Cache.EmplExist(emplID) and not Cache.arEmplInfo[emplID].Arhived;
    if Result then break;
  end;
  if Result then Empl:= Cache.arEmplInfo[emplID];  // регионал
end;
//================================================= проверка менеджера контракта
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
//====================================================== код менеджера контракта
function TContract.GetContManager: Integer;
var Empl: TEmplInfoItem;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if FindContManager(empl) then Result:= Empl.ID; // код менеджера
end;
//============================================================= наименование ЦФУ
function TContract.GetContFaccName: String;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  if not Cache.FiscalCenters.ItemExists(FacCenter) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[FacCenter]).Name;
end;
//============================================================= код верхнего ЦФУ
function TContract.GetContFaccParent: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  if not Cache.FiscalCenters.ItemExists(FacCenter) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[FacCenter]).Parent;
end;
//==================================================== наименование верхнего ЦФУ
function TContract.GetContFaccParentName: String;
var i: Integer;
begin
  Result:= '';
  if not Assigned(self) then Exit;
  i:= GetContFaccParent;
  if not Cache.FiscalCenters.ItemExists(i) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[i]).Name;
end;
//============================================= коды менеджеров контракта по ЦФУ
function TContract.GetContBKEempls: TIntegerList; // not Free !!!
begin
  Result:= EmptyIntegerList;
  if not Assigned(self) then Exit;
  if not Cache.FiscalCenters.ItemExists(FacCenter) then Exit;
  Result:= TFiscalCenter(Cache.FiscalCenters[FacCenter]).BKEempls;
end;
//================================================== получить торг.точку по коду
function TContract.GetContDestPoint(destID: integer): TDestPoint;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if (ContDestPointCodes.IndexOf(destID)<0) then Exit;
  Result:= Cache.arFirmInfo[ContFirm].GetFirmDestPoint(destID);
end;
//================================================  проверить наличие торг.точки
function TContract.ContDestPointExists(destID: integer): Boolean;
begin
  Result:= False;
  if not Assigned(self) then Exit;
  Result:= (ContDestPointCodes.IndexOf(destID)>-1);
end;
//======================================= список кодов видимых складов контракта
function TContract.GetContVisStoreCodes: Tai;
var i: Integer;
    dprt: TDprtInfo;
begin
  SetLength(Result, 0);

  if not Cache.DprtExist(MainStorage) then Exit; // не найден главный склад
  prAddItemToIntArray(MainStorage, Result);
  dprt:= Cache.arDprtInfo[MainStorage];
  for i:= 0 to dprt.StoresFrom.Count-1 do with TTwoCodes(dprt.StoresFrom[i]) do
    if (ID2>0) then prAddItemToIntArray(ID1, Result);
end;
//============================================= проверяем длину массивов складов
procedure TContract.TestStoreArrayLength(kind: TArrayKind; len: integer; ChangeOnlyLess: boolean=True; inCS: boolean=True);
// len- нужная длина массива, inCS=True - изменять длину в CriticalSection
// ChangeOnlyLess=True - изменять только, если длина меньше, False - если не равна
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
  if fl then try // если надо менять длину
    if inCS then CS_cont.Enter;

    case kind of
      taDprt: if i<len then prCheckLengthIntArray(ContProcDprts, len-1) else SetLength(ContProcDprts, len);
      taCurr: begin  // если обрезаем - надо очистить элементы
                if (i>len) then for j:= len to High(ContStorages) do prFree(ContStorages[j]);
                SetLength(ContStorages, len);
                if (i<len) then for j:= i to High(ContStorages) do ContStorages[j]:= nil;
              end;
    end; // case
  finally
    if inCS then CS_cont.Leave;
  end;
end;
//========================================= индекс склада в массиве ContStorages
function TContract.GetСontStoreIndex(StorageID: integer): integer;
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
  FFirmFilials:= TIntegerList.Create; // коды филиалов к/а
  FFirmClasses:= TIntegerList.Create; // коды категорий к/а
  FFirmTypes  := TIntegerList.Create; // коды типов к/а
  FFirms      := TIntegerList.Create; // коды  к/а
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
//================================================================ получить дату
function TNotificationItem.GetDateN(const ik: T8InfoKinds): TDateTime;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FBegDate;
    ik8_2: Result:= FEndDate;
  end;
end;
//================================================================ записать дату
procedure TNotificationItem.SetDateN(const ik: T8InfoKinds; Value: TDateTime);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if fnNotZero(FBegDate-Value) then FBegDate:= Value;
    ik8_2: if fnNotZero(FEndDate-Value) then FEndDate:= Value;
  end;
end;
//======================================================== получить список кодов
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
//================================================= проверить условия фильтрации
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
//===================================================== список уведомлений фирмы
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
//================================================================= номер округа
function TFiscalCenter.GetRegion: Integer;
var i: Integer;
begin
  Result:= 0;
  if not IsAutoSale then Exit; // только AUTO
  if (copy(FName, 1, 1)='0') then Exit;
  i:= pos('-', FName);
  if (i<2) then Exit;
  Result:= StrToIntDef(copy(FName, 1, i-1), 0);
end;
//========================================================= код ЦФУ РОП-а округа
function TFiscalCenter.GetROPfacc: Integer;
var i: Integer;
begin
  Result:= -1;
  i:= GetRegion;           // 1-й не берем
  if (i<2) then Exit;
  if (i<Length(Cache.arRegionROPFacc)) then Result:= Cache.arRegionROPFacc[i];
end;
//===================================================== признак ЦФУ РОП-а округа
function TFiscalCenter.CheckIsROPFacc: Boolean;
begin
  Result:= (pos('-00-01', FName)>1);
end;
//============================================================ продажи AUTO/MOTO
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
// в TLinks - TLinkLink: LinkPtr- ссылка на группу(TWareInfo), State- признак проверки группы,
// в DoubleLinks - TLink: LinkPtr- ссылка на подгруппу(TWareInfo), State- признак проверки подгруппы
//====================================================== получить группу наценки
//==================================================== получить TWareInfo группы
function TMarginGroups.GetWareGroup(grID: integer): TWareInfo;
var grLink: TLinkLink;
begin
  Result:= NoWare;
  if not Assigned(self) then Exit;
  grLink:= GetLinkItemByID(grID);
  if Assigned(grLink) and Assigned(grLink.LinkPtr) then Result:= grLink.LinkPtr;
end;
//================================================= получить TWareInfo подгруппы
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
//================================================ проверка существования группы
function TMarginGroups.GroupExists(grID: integer): Boolean;
begin
  Result:= False;
  if Assigned(self) then Result:= LinkExists(grID);
end;
//==================================== проверка существования подгруппы в группе
function TMarginGroups.SubGroupExists(grID, pgrID: integer): Boolean;
begin
  Result:= False;
  if Assigned(self) then Result:= DoubleLinkExists(grID, pgrID);
end;
//==================================================== проверить/добавить группу
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
//================================================= проверить/добавить подгруппу
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
    grLink.DoubleLinks.AddLinkListItem(pgrLink, lkLnkNone, CS_Links); // связка
    if SortAdd then SortByName(grID);
  end else try
    CS_Links.Enter;
    if pgrLink.LinkPtr<>Pgr then pgrLink.LinkPtr:= Pgr;
    pgrLink.State:= True;
  finally
    CS_Links.Leave;
  end;
end;
//=========================================== список ссылок на группы по системе
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
//=============================== список ссылок на подгруппы в группе по системе
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
//============================= сортирует связки с группами/подгруппами по имени
procedure TMarginGroups.SortByName(grID: integer=0);
// grID<0 - сортирует все, grID=0 - сортирует связки с группами,
// grID>0 - сортирует связки с подруппами группы grID
var pgrLinks: TLinkList;
    i: Integer;
begin
  if not Assigned(self) then Exit;
  if (grID<1) and (LinkCount>1) then SortByLinkName; // все или группы
  if (grID=0) then Exit; // только группы

  if (grID>0) then begin // подгруппы заданной группы
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
//=================================== устанавливает флаг проверки всем элементам
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
//=========================================== удаляет все элементы с State=False
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
//====================================================== получить целое значение
function TDiscModel.GetIntDM(const ik: T8InfoKinds): Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: Result:= FDirectInd; // индекс направления
    ik8_2: Result:= FRating;   // рейтинг
    ik8_3: Result:= FSales;    // мин.оборот
  end;
end;
//====================================================== записать целое значение
procedure TDiscModel.SetIntDM(const ik: T8InfoKinds; pValue: Integer);
begin
  if not Assigned(self) then Exit;
  case ik of
    ik8_1: if (FDirectInd<>pValue) then FDirectInd:= pValue; // индекс направления
    ik8_2: if (FRating   <>pValue) then FRating   := pValue; // рейтинг
    ik8_3: if (FSales    <>pValue) then FSales    := pValue; // мин.оборот
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
  FProdDirects:= fnCreateStringList(True, 3); // сортировка по наименованию
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
//=============================================== добавить/проверить направление
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
//========================================================== удалить направление
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
//==================================================== добавить/проверить шаблон
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
//=============================================================== удалить шаблон
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
//======================================================= удалить лишние шаблоны
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
//======================================================================= шаблон
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
//=========================================== код следующего шаблона направления
function TDiscModels.GetNextDirectModel(dmID: Integer): Integer;
var i, direct, ind: Integer;
begin
  Result:= 0;
  if not Assigned(self) then Exit;
  ind:= -1;
  direct:= 0;
  for i:= 0 to FDiscModels.Count-1 do with TDiscModel(FDiscModels[i]) do
    if (ID=dmID) then begin // нашли вх.шаблон
      ind:= i;
      direct:= DirectInd;
    end else if (ind<0) then Continue
    else if (DirectInd=direct) then begin // следующий по направлению
      Result:= ID;
      Exit;
    end;
end;
//================================================== список шаблонов направления
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
//================================================== кол-во шаблонов направления
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
//========================================================== сортировать шаблоны
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
//=========================================================== индекс направления
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
{ на имени метода класса -> Ctrl+Shift+C -> шаблончик для будущей процедуры }

//******************************************************************************
//                                TDestPoint
//******************************************************************************
constructor TDestPoint.Create(pID: Integer; pName, pAdress: String);
begin
  inherited Create(pID, pName);
  FAdress:= pAdress;
  Disabled:= False;
end;

//===================================== Заполнение / проверка атрибутов Grossbee
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
//---------------------------- заполняем / проверяем группы атрибутов и атрибуты
      IBS.SQL.Text:= 'select a0.gr, a0.grname, wp.att, wp.num, gp.glprname attname,'+
        '  gp.GLPRCLASSTYPE attType'+    //  gp.glpranrganalittype analit,
        '  from (select andtcode gr, andtname grname from analitdict'+
        '    where andtmastercode='+GetConstItem(pcWareAttributeAnDtCode).StrValue+
        '    and not (andtname starting "_")'+ // признак - категорию не показывать
        '    and exists(select * from RDB$RELATIONS where RDB$SYSTEM_FLAG=0'+ // проверяем наличие таблицы
        '    and RDB$VIEW_SOURCE is null and RDB$RELATION_NAME="'+sTabPref+'"||andtcode)) a0'+
        '  left join (select wcprclasscode, wcprparamtype att, wcprorder num'+
        '    from wareclassparams where exists(select * from RDB$RELATION_FIELDS'+
        '    where RDB$RELATION_NAME= "'+sTabPref+'"||wcprclasscode'+
        '      and RDB$FIELD_NAME="'+sColPref+'"||wcprclasscode'+ // проверяем наличие полей в таблице
        '      ||"_"||wcprparamtype)) wp on wp.wcprclasscode = a0.gr'+
        '  left join GLSYSTEMOFWORKPARM gp on gp.glprcode=wp.att'+
        '  order by gr, att';
      IBS.ExecQuery;
      while not IBS.Eof do begin
//------------------------------------------------------------- группа атрибутов
        parID:= IBS.fieldByName('gr').asInteger;
        pName:= IBS.fieldByName('grname').asString;
        j:= pos('(NEW)', AnsiUpperCase(pName));
        if (j>0) then begin
          pName:= trim(copy(pName, 1, j-1));
          j:= 1; // признак новой группы
          flNew:= True;
        end;

        jj:= GBAttributes.Groups.GetIDBySubCode(parID);
        if (jj>0) then begin // нашли - проверяем
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
          attgr:= TSubDirItem.Create(0, parID, 0, pName, j, True); // код=0
          GBAttributes.Groups.AddItem(Pointer(attgr)); // добавляем (генерирует код)
        end;

        while not IBS.Eof and (parID=IBS.fieldByName('gr').asInteger) do begin
//---------------------------------------------------------------------- атрибут
          pID:= IBS.fieldByName('att').asInteger;
          pName:= IBS.fieldByName('attname').asString;
          ordN:= IBS.fieldByName('num').asInteger;
          case IBS.fieldByName('attType').asInteger of // тип
            cWrDcAnDtClass   : j:= constAnalit;
            cWrDcIntegerClass: j:= constInteger;
            cWrDcStringClass : j:= constString;
            cWrDcDateClass   : j:= constDateTime;
            cWrDcSummClass, cWrDcPersentClass, cWrDcCoefClass: j:= constDouble;
            else j:= constString;
          end; // case

          jj:= GBAttributes.GetAttIDByGroupAndSubCode(attgr.ID, pID);
          if (jj>0) then begin // нашли - проверяем
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
            att:= TGBAttribute.Create(0, pID, attgr.ID, ordN, 0, j, pName); // код=0
            GBAttributes.AddItem(Pointer(att)); // добавляем (генерирует код)
          end;

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof and (parID=
//---------------------------------------------
      end;  // while not IBS.Eof
      IBS.Close;

//------------------------------------- заполняем / проверяем значения атрибутов
      j:= 0; // счетчик проверенных товаров
      for i:= 0 to GBAttributes.Groups.ItemsList.Count-1 do try
        attgr:= GBAttributes.Groups.ItemsList[i];
        if not attgr.State then Continue;

        sTabNum:= IntToStr(attgr.SubCode);
        TabName:= sTabPref+sTabNum; // имя таблицы группы атрибутов
        sColTab:= sColPref+sTabNum+'_';
        sWareField:= 'AG_WRCLWARECODE'+sTabNum;

        SetLength(ar, GBAttributes.ItemsList.Count);
        jj:= 0;
        for ii:= 0 to GBAttributes.ItemsList.Count-1 do begin
          att:= GBAttributes.ItemsList[ii];
          if not att.State or (att.FGroup<>attgr.ID) then Continue; // отбираем атрибуты группы

          ar[jj].att:= att;
          if not fFill then att.Links.SetLinkStates(False);

          sColNum:= IntToStr(ar[jj].att.SubCode);
          ar[jj].AttField:= sColTab+sColNum; // поле значения / кода Analitdict
          ar[jj].ValField:= 'val'+sColNum;   // псевдоним поля значения
          ar[jj].OrdField:= 'ord'+sColNum;   // псевдоним поля порядк.номера

          ar[jj].FlagSortVal:= False;
          ar[jj].Attv:= nil;
          Inc(jj);
        end;
        if (Length(ar)>jj) then SetLength(ar, jj);
        //---------------------------------------- формируем SQL.Text для группы
        sOrderBy:= '';
        sSelects:= '';
        sJoins:= '';
        for ii:= 0 to High(ar) do begin // перебираем атрибуты группы
          sColNum:= IntToStr(ar[ii].att.ID);
                                  // формируем список полей для сортировки
          sOrderBy:= sOrderBy+fnIfStr(sOrderBy='', '', ', ')+ar[ii].AttField;
                                  // формируем список полей для выборки значений
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
          ' order by '+sOrderBy; // сортировка - для минимизации проверок значений
        IBS.ExecQuery;
        while not IBS.Eof do begin
          pID:= IBS.fieldByName(sWareField).asInteger; // код товара
          if WareExist(pID) then begin
            ware:= GetWare(pID, True);
            if not ware.IsMarketWare then ware:= nil;
            if ware.IsPrize then ware:= nil;  // пропускаем подарки
          end else ware:= nil;
          if not Assigned(ware) then begin
            IBS.Next;
            Continue;
          end;

          for ii:= 0 to High(ar) do begin // перебираем атрибуты
            pName:= IBS.fieldByName(ar[ii].ValField).AsString; // значение поля в строковом виде
            ordN:= IBS.fieldByName(ar[ii].OrdField).asInteger;
            ar[ii].att.CheckAttrStrValue(pName); // проверяем значение в зависимости от типа
            //-------------------------------- если изменилось значение атрибута
            if not Assigned(ar[ii].attv) or (pName<>ar[ii].attv.Name) then begin
              link:= ar[ii].Att.Links.GetLinkItemByName(pName);
              if Assigned(link) then begin // нашли линк на значение
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
                  GBAttributes.FAttValues.CS_DirItems.Enter; // нашли такое значение в справочнике
                  try
                    attv.State:= True;
                  finally
                    GBAttributes.FAttValues.CS_DirItems.Leave;
                  end;
                end else begin
                  attv:= TBaseDirItem.Create(0, pName); // новое значение
//                  attv:= TSubDirItem.Create(0, 0, ordN, pName); // новое значение
                  GBAttributes.FAttValues.AddItem(Pointer(attv));
                end;
                link:= TTwoLink.Create(ar[ii].Att.SrcID, attv, Pointer(ordN)); // новый линк (с типом и пор.номером)
//                link:= TLink.Create(ar[ii].Att.SrcID, attv); // новый линк (с типом)
                ar[ii].Att.Links.AddLinkItem(link);
              end;
              ar[ii].Attv:= attv;
            end; // if ... (pName<>ar[ii].attv.Name)
            //------------------------------

            linkt:= ware.GBAttLinks[ar[ii].att.ID]; // линк на атрибут у товара
            if Assigned(linkt) then try
              ware.GBAttLinks.CS_links.Enter; // нашли такое значение в справочнике
              if (linkt.LinkPtrTwo<>ar[ii].attv) then linkt.LinkPtrTwo:= ar[ii].attv;
              linkt.State:= True;
            finally
              ware.GBAttLinks.CS_links.Leave;
            end else begin
              linkt:= TTwoLink.Create(0, ar[ii].att, ar[ii].attv);
              ware.GBAttLinks.AddLinkItem(linkt); // линк на атрибут и значение
            end;
          end; // for ii:=

          attgr.Links.CheckLink(ware.ID, 0, ware); // линк у группы на товар
          inc(j); // счетчик проверенных товаров

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof
        IBS.Close;

        for ii:= 0 to High(ar) do begin // перебираем атрибуты
          if not fFill then ar[ii].att.Links.DelNotTestedLinks; // чистим значения
          ar[ii].att.SortValues; // сортировка значений в зависимости от типа
        end; // for ii:=

        attgr.Links.SortByLinkName; // сортируем линки на товары у группы атрибутов
      except
        on E: Exception do prMessageLOGS(nmProc+': '+E.Message, fLogCache);
      end; // for i:= 0 to GBAttributes.Groups.ItemsList.Count-1

//------------------------------------------ GBPrizeAttrs
//------------------- заполняем / проверяем группы атрибутов и атрибуты подарков
      IBS.SQL.Text:= 'select a0.gr, a0.grname, wp.att, wp.num, gp.glprname attname,'+
        '  gp.GLPRCLASSTYPE attType'+    //  gp.glpranrganalittype analit,
        '  from (select andtcode gr, andtname grname from analitdict'+
        '    where andtmastercode='+GetConstItem(pcPrizAttributeAnDtCode).StrValue+
//        '    and not (andtname starting "_")'+ // признак - категорию не показывать
        fnIfStr(flDebug, '', '    and not (andtname starting "_")')+
        '    and exists(select * from RDB$RELATIONS where RDB$SYSTEM_FLAG=0'+ // проверяем наличие таблицы
        '    and RDB$VIEW_SOURCE is null and RDB$RELATION_NAME="'+sTabPref+'"||andtcode)) a0'+
        '  left join (select wcprclasscode, wcprparamtype att, wcprorder num'+
        '    from wareclassparams where exists(select * from RDB$RELATION_FIELDS'+
        '    where RDB$RELATION_NAME= "'+sTabPref+'"||wcprclasscode'+
        '      and RDB$FIELD_NAME="'+sColPref+'"||wcprclasscode'+ // проверяем наличие полей в таблице
        '      ||"_"||wcprparamtype)) wp on wp.wcprclasscode = a0.gr'+
        '  left join GLSYSTEMOFWORKPARM gp on gp.glprcode=wp.att'+
        '  order by gr, att';
      IBS.ExecQuery;
      while not IBS.Eof do begin
//------------------------------------------------------------- группа атрибутов
        parID:= IBS.fieldByName('gr').asInteger;
        pName:= IBS.fieldByName('grname').asString;
        j:= pos('(NEW)', AnsiUpperCase(pName));
        if (j>0) then begin
          pName:= trim(copy(pName, 1, j-1));
          j:= 1; // признак новой группы
          flNewP:= True;
        end;

        jj:= GBPrizeAttrs.Groups.GetIDBySubCode(parID);
        if (jj>0) then begin // нашли - проверяем
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
          attgr:= TSubDirItem.Create(0, parID, 0, pName, j, True); // код=0
          GBPrizeAttrs.Groups.AddItem(Pointer(attgr)); // добавляем (генерирует код)
        end;

        while not IBS.Eof and (parID=IBS.fieldByName('gr').asInteger) do begin
//---------------------------------------------------------------------- атрибут
          pID:= IBS.fieldByName('att').asInteger;
          pName:= IBS.fieldByName('attname').asString;
          ordN:= IBS.fieldByName('num').asInteger;
          case IBS.fieldByName('attType').asInteger of // тип
            cWrDcAnDtClass   : j:= constAnalit;
            cWrDcIntegerClass: j:= constInteger;
            cWrDcStringClass : j:= constString;
            cWrDcDateClass   : j:= constDateTime;
            cWrDcSummClass, cWrDcPersentClass, cWrDcCoefClass: j:= constDouble;
            else j:= constString;
          end; // case

          jj:= GBPrizeAttrs.GetAttIDByGroupAndSubCode(attgr.ID, pID);
          if (jj>0) then begin // нашли - проверяем
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
            att:= TGBAttribute.Create(0, pID, attgr.ID, ordN, 0, j, pName); // код=0
            GBPrizeAttrs.AddItem(Pointer(att)); // добавляем (генерирует код)
          end;

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof and (parID=
//---------------------------------------------
      end;  // while not IBS.Eof
      IBS.Close;

//---------------------------- заполняем / проверяем значения атрибутов подарков
      jp:= 0; // счетчик проверенных подарков
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do try
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        if not attgr.State then Continue;

        sTabNum:= IntToStr(attgr.SubCode);
        TabName:= sTabPref+sTabNum; // имя таблицы группы атрибутов
        sColTab:= sColPref+sTabNum+'_';
        sWareField:= 'AG_WRCLWARECODE'+sTabNum;

        SetLength(ar, GBPrizeAttrs.ItemsList.Count);
        jj:= 0;
        for ii:= 0 to GBPrizeAttrs.ItemsList.Count-1 do begin
          att:= GBPrizeAttrs.ItemsList[ii];
          if not att.State or (att.FGroup<>attgr.ID) then Continue; // отбираем атрибуты группы

          ar[jj].att:= att;
          if not fFill then att.Links.SetLinkStates(False);

          sColNum:= IntToStr(ar[jj].att.SubCode);
          ar[jj].AttField:= sColTab+sColNum; // поле значения / кода Analitdict
          ar[jj].ValField:= 'val'+sColNum;   // псевдоним поля значения
          ar[jj].OrdField:= 'ord'+sColNum;   // псевдоним поля порядк.номера

          ar[jj].FlagSortVal:= False;
          ar[jj].Attv:= nil;
          Inc(jj);
        end;
        if (Length(ar)>jj) then SetLength(ar, jj);
        //---------------------------------------- формируем SQL.Text для группы
        sOrderBy:= '';
        sSelects:= '';
        sJoins:= '';
        for ii:= 0 to High(ar) do begin // перебираем атрибуты группы
          sColNum:= IntToStr(ar[ii].att.ID);
                                  // формируем список полей для сортировки
          sOrderBy:= sOrderBy+fnIfStr(sOrderBy='', '', ', ')+ar[ii].AttField;
                                  // формируем список полей для выборки значений
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
          ' order by '+sOrderBy; // сортировка - для минимизации проверок значений
        IBS.ExecQuery;
        while not IBS.Eof do begin
          pID:= IBS.fieldByName(sWareField).asInteger; // код товара
          ware:= nil;
          if WareExist(pID) then begin
            ware:= GetWare(pID, True);
            if not ware.IsMarketWare or not ware.IsPrize then ware:= nil; // пропускаем не подарки
//            if not ware.IsMarketWare or not ware.IsPrize       // пропускаем не подарки
//              or (Ware.RestLinks.LinkCount<1) then ware:= nil; // пропускаем без наличия
          end;
          if not Assigned(ware) then begin
            IBS.Next;
            Continue;
          end;

          for ii:= 0 to High(ar) do begin // перебираем атрибуты
            pName:= IBS.fieldByName(ar[ii].ValField).AsString; // значение поля в строковом виде
            ordN:= IBS.fieldByName(ar[ii].OrdField).asInteger;
            ar[ii].att.CheckAttrStrValue(pName); // проверяем значение в зависимости от типа
            //-------------------------------- если изменилось значение атрибута
            if not Assigned(ar[ii].attv) or (pName<>ar[ii].attv.Name) then begin
              link:= ar[ii].Att.Links.GetLinkItemByName(pName);
              if Assigned(link) then begin // нашли линк на значение
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
                  GBPrizeAttrs.FAttValues.CS_DirItems.Enter; // нашли такое значение в справочнике
                  try
                    attv.State:= True;
                  finally
                    GBPrizeAttrs.FAttValues.CS_DirItems.Leave;
                  end;
                end else begin
                  attv:= TBaseDirItem.Create(0, pName); // новое значение
//                  attv:= TSubDirItem.Create(0, 0, ordN, pName); // новое значение
                  GBPrizeAttrs.FAttValues.AddItem(Pointer(attv));
                end;
                link:= TTwoLink.Create(ar[ii].Att.SrcID, attv, Pointer(ordN)); // новый линк (с типом и пор.номером)
//                link:= TLink.Create(ar[ii].Att.SrcID, attv); // новый линк (с типом)
                ar[ii].Att.Links.AddLinkItem(link);
              end;
              ar[ii].Attv:= attv;
            end; // if ... (pName<>ar[ii].attv.Name)
            //------------------------------

            linkt:= ware.PrizAttLinks[ar[ii].att.ID]; // линк на атрибут у товара
            if Assigned(linkt) then try
              ware.PrizAttLinks.CS_links.Enter; // нашли такое значение в справочнике
              if (linkt.LinkPtrTwo<>ar[ii].attv) then linkt.LinkPtrTwo:= ar[ii].attv;
              linkt.State:= True;
            finally
              ware.PrizAttLinks.CS_links.Leave;
            end else begin
              linkt:= TTwoLink.Create(0, ar[ii].att, ar[ii].attv);
              ware.PrizAttLinks.AddLinkItem(linkt); // линк на атрибут и значение
            end;
          end; // for ii:=

          attgr.Links.CheckLink(ware.ID, 0, ware); // линк у группы на товар
          inc(jp); // счетчик проверенных подарков

          cntsORD.TestSuspendException;
          IBS.Next;
        end; // while not IBS.Eof
        IBS.Close;

        for ii:= 0 to High(ar) do begin // перебираем атрибуты
          if not fFill then ar[ii].att.Links.DelNotTestedLinks; // чистим значения
          ar[ii].att.SortValues; // сортировка значений в зависимости от типа
        end; // for ii:=

        attgr.Links.SortByLinkName; // сортируем линки на товары у группы атрибутов
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
          ware.GBAttLinks.SortByLinkOrdNumAndName; // сортируем по пор.№ + наименованию
        end; // for ii:=
      end; // for i:= 0
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do begin
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.PrizAttLinks.SortByLinkOrdNumAndName; // сортируем по пор.№ + наименованию
        end; // for ii:=
      end; // for i:= 0

    end else begin
      for i:= 0 to GBAttributes.Groups.ItemsList.Count-1 do begin // чистим линки у товаров
        attgr:= GBAttributes.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.GBAttLinks.DelNotTestedLinks;
          ware.GBAttLinks.SortByLinkOrdNumAndName; // сортируем по пор.№ + наименованию
        end; // for ii:=
        attgr.Links.DelNotTestedLinks;
      end; // for i:= 0
      GBAttributes.Groups.DelDirNotTested;
      GBAttributes.Groups.CheckLength; // обрезать длину по максимальному коду
      GBAttributes.FAttValues.DelDirNotTested;
      GBAttributes.FAttValues.CheckLength;
      GBAttributes.DelDirNotTested;
      GBAttributes.CheckLength;
//------------------------------------------ GBPrizeAttrs
      for i:= 0 to GBPrizeAttrs.Groups.ItemsList.Count-1 do begin // чистим линки у товаров
        attgr:= GBPrizeAttrs.Groups.ItemsList[i];
        for ii:= attgr.Links.ListLinks.Count-1 downto 0 do begin
          link:= attgr.Links.ListLinks[ii];
          ware:= link.LinkPtr;
          ware.PrizAttLinks.DelNotTestedLinks;
          ware.PrizAttLinks.SortByLinkOrdNumAndName; // сортируем по пор.№ + наименованию
        end; // for ii:=
        attgr.Links.DelNotTestedLinks;
      end; // for i:= 0
      GBPrizeAttrs.Groups.DelDirNotTested;
      GBPrizeAttrs.Groups.CheckLength; // обрезать длину по максимальному коду
      GBPrizeAttrs.FAttValues.DelDirNotTested;
      GBPrizeAttrs.FAttValues.CheckLength;
      GBPrizeAttrs.DelDirNotTested;
      GBPrizeAttrs.CheckLength;
    end; // if not fFill
    GBAttributes.Groups.SortDirListByName;  // сортируем группы по наименованию
    GBAttributes.SortDirListByOrdNumAndName; // сортируем атрибуты по пор.№ + наименованию

    s:= IntToStr(GBAttributes.Groups.ItemsList.Count)+' гр ';
    s:= s+IntToStr(GBAttributes.ItemsList.Count)+' атр ';
    s:= s+IntToStr(GBAttributes.FAttValues.ItemsList.Count)+' зн/а ';
    s:= s+IntToStr(j)+' зн/а/т ';

//------------------------------------------ GBPrizeAttrs
    GBPrizeAttrs.Groups.SortDirListByName;  // сортируем группы по наименованию
    GBPrizeAttrs.SortDirListByOrdNumAndName; // сортируем атрибуты по пор.№ + наименованию

    sp:= IntToStr(GBPrizeAttrs.Groups.ItemsList.Count)+' гр.п ';
    sp:= sp+IntToStr(GBPrizeAttrs.ItemsList.Count)+' атр.п ';
    sp:= sp+IntToStr(GBPrizeAttrs.FAttValues.ItemsList.Count)+' зн/а.п ';
    sp:= sp+IntToStr(jp)+' зн/а/п ';

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
//================== сортировка TList линков значений атрибутов в зав-ти от типа
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
        pValue:= StrWithFloatDec(pValue); // проверяем DecimalSeparator
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
  FGroups:= TOwnDirItems.Create(LengthStep);  // справочник групп атрибутов
  FAttValues:= TOwnDirItems.Create(LengthStep); // Справочник значений атрибутов
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
//================== Список атрибутов группы, сортированный по порядк.№ +наимен.
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
{//================================================ получить ID по группе + имени
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
//============================================== получить ID по группе + SubCode
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
  IsAction   := False; // флаг - Акции
  IsCatchMom := False; // флаг - Лови момент
  IsNews     := False; // флаг - Новинки
  IsTopSearch:= False; // флаг - ТОП поиска
  IconMS:= TMemoryStream.Create;
end;
//==============================================================================
destructor TWareAction.Destroy;
begin
  prFree(IconMS);
  inherited;
end;
//================================================================ получить дату
function TWareAction.GetDateN(const ik: T8InfoKinds): TDateTime;
begin
  Result:= 0;
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FBegDate;
    ik8_2: Result:= FEndDate;
  end;
end;
//================================================================ записать дату
procedure TWareAction.SetDateN(const ik: T8InfoKinds; Value: TDateTime);
begin
  if not Assigned(self) then Exit else case ik of
    ik8_1: if fnNotZero(FBegDate-Value) then FBegDate:= Value;
    ik8_2: if fnNotZero(FEndDate-Value) then FEndDate:= Value;
  end;
end;
//============================================================== получить строку
function TWareAction.GetStrN(const ik: T8InfoKinds): String;
begin
  Result:= '';
  if not Assigned(self) then Exit else case ik of
    ik8_1: Result:= FName;
    ik8_2: Result:= FNum;                             // номер
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
//=================================================== комментарий по 1-му товару
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
//======================================================= доступ по коду линейки
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
//=================================================== доступ по названию линейки
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
  inherited Create(pID, pParentID, 0, pName, pSysID, True); // TDirItem с линками
  State    := True;
  FNameSys := pNameSys;     // Наименование узла (служебное)
  FChildren:= TList.Create; // Список подчиненных узлов (сортированный по имени)
  FMeasID  := pMeasID;
  FOrderOut:= pOrdnum;
  Visible  := pVisible;     // признак видимости ноды
end;
//==============================================================================
destructor TMotulNode.Destroy;
begin
  if not Assigned(self) then Exit;
  if Assigned(FChildren) then prFree(FChildren);
  inherited Destroy;
end;
//======================================================== признак конечной ноды
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
  FItems[0]:= TMotulNode.Create(0, -1, 0, 0, 0, 'Подбор MOTUL', 'Root'); // корневой узел дерева
end;
//==============================================================================
{destructor TMotulTreeNodes.Destroy;
begin
  if not Assigned(self) then Exit;
  inherited Destroy;
end;  }
//======================================================== Получить узел по коду
function TMotulTreeNodes.GetNodeByID(pID: Integer): TMotulNode;
begin
  Result:= nil;
  if not Assigned(self) then Exit;
  if (pID>0) and not ItemExists(pID) then Exit;
  Result:= TMotulNode(FItems[pID]);
end;
//=========================================================== Найти узел по коду
function TMotulTreeNodes.MotulNodeGet(pID: Integer; var pNodeGet: TMotulNode): Boolean;
begin
  Result:= False;
  pNodeGet:= nil;
  if not Assigned(self) then Exit;
  pNodeGet:= GetNodeByID(pID);
  Result:= Assigned(pNodeGet);
end;
//======================================== Найти узел по системному наименованию
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
//================== отсортировать список дерева последовательный по всем ветвям
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
    GetNodes(Nodes[0]);     // проставляем порядковый номер нодам
  finally
    CS_DirItems.Leave;
  end;
  SortDirListByOrdNumAndName; // сортируем по порядк.номеру
end;
//----- Получить список дерева системы (0 - все) последовательный по всем ветвям
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
//========================================= Проверить валидность добавления узла
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

    if not MotulNodeGet(pParentID, pNodeParent) then // Узел родителя не найден
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pParentID)));
    if (pID>0) and MotulNodeGet(pID, pNodeAdd) then // Узел с таким кодом имеется
      raise Exception.Create('Дубликат кода узла');

    if not pCheckTreeDup then Exit;

    if Assigned(pNodeParent.Children) then
      for i:= 0 to pNodeParent.Children.Count-1 do begin
        pNode:= pNodeParent.Children[i];
        if not Assigned(pNode) or (pNode.Name<>pName) then Continue;
        pNodeAdd:= pNode; // дубликат имени в 1-й ветке
        raise Exception.Create('Имя нового узла имеет дубликат среди детей родителя.');
      end;

    pNameSys:= AnsiUpperCase(pNameSys);
    sysID:= pNodeParent.TypeSys;
    for i:= 0 to ItemsList.Count-1 do begin
      pNode:= ItemsList[i];              // дубликат системного имени
      if not Assigned(pNode) then Continue;
      if (sysID>0) and (pNode.TypeSys<>sysID) then Continue;
      if (AnsiUpperCase(pNode.NameSys)=pNameSys) then
        raise Exception.Create(MessText(mtkDuplicateSysNm, pNameSys));
    end;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
end;
//========================================== сортировка узлов ветки дерева Motul
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
//================================================================= Удалить узел
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
      raise Exception.Create('Узел имеет подчиненные узлы.');
    if not MotulNodeGet(Node.ParentID, NodeParent) then
      raise Exception.Create('Не найден родительский узел.');

    ORD_IBD:= cntsORD.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True); //  удаление в базе
      ORD_IBS.SQL.Text:= 'delete from TREENODESmotul where TRNmCODE='+IntToStr(pNodeId);
      ORD_IBS.ExecQuery;
      ORD_IBS.Transaction.Commit;
    finally
      prFreeIBSQL(ORD_IBS);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;

    idxParent:= NodeParent.Children.IndexOf(Node);  // Находим узел в списке подузлов
    CS_DirItems.Enter;
    try
      NodeParent.Children.Delete(idxParent); // Удаляем из списка детей
    finally
      CS_DirItems.Leave;
    end;
    DeleteItem(pNodeID); // Удаляем узел из кеша
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//====================================================== Изменить параметры узла
function TMotulTreeNodes.MotulNodeEdit(pNodeID, pVisible, pUserID, pOrdnum: Integer;
                                       pName, pNameSys: String): String;
const nmProc = 'NodeEdit';
// pVisible<0 - не менять, pName, pNameSys='' - не менять
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
      raise Exception.Create(MessText(mtkNotFoundNode, IntToStr(pNodeID))); // узел с кодом pID не найден
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
      raise Exception.Create('Не найден родительский узел.');

    if flUpdName then for i:= 0 to NodeParent.Children.Count-1 do begin
      pNode:= NodeParent.Children[i];   // Ищем узел с таким именем у родителя
      if Assigned(pNode) and (pNode.Name=pName) then
        raise Exception.Create('Новое имя узла имеет дубликат среди детей родителя.');
    end;

    if flUpdSysName then for i:= 0 to ItemsList.Count-1 do begin
      pNode:= ItemsList[i];             // Ищем узел с таким системным именем
      if not Assigned(pNode) or (pNode.ID=Node.ID) then Continue;
      if (pNode.TypeSys<>Node.TypeSys) then Continue;
      if (AnsiUpperCase(pNode.NameSys)=pNameSys) then
        raise Exception.Create(MessText(mtkDuplicateSysNm, pNameSys));
    end;

//------------------------------------------- изменение наименований и видимости
    if flUpdName or flUpdSysName or flUpdVis or flUpdord then begin
      ORD_IBD:= cntsORD.GetFreeCnt;
      try
        ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);  // в базе
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
                       // перестраиваем список отсортированных узлов системы
      if flUpdord or flUpdName then SortNodesList;
    end;
  except
    on E: Exception do begin
      Result:= E.Message;
      prMessageLOGS(nmProc+': '+E.Message, fLogCache);
    end;
  end;
end;
//=========================================== Добавление элемента в дерево узлов
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

    if ToBase then try //------------------------------------- добавление в базу
      ORD_IBD:= cntsORD.GetFreeCnt;
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpWrite, True);
      ORD_IBS.SQL.Text:= 'select * from CheckMotulNode('+IntToStr(pSysID)+', '+
        IntToStr(pUserID)+', '+IntToStr(pMeasID)+', '+IntToStr(pParentID)+', '+
        fnIfStr(pVisible, '"T", ', '"F", ')+':TRNANAME, :TRNANAMESYS)';
      ORD_IBS.ParamByName('TRNANAME').AsString:= pNodeName;
      ORD_IBS.ParamByName('TRNANAMESYS').AsString:= pNodeNameSys;
      ORD_IBS.ExecQuery;
      if not (ORD_IBS.Bof and ORD_IBS.Eof) then begin
//        kind:= ORD_IBS.FieldByName('rKind').asInteger; // kind= 0 - Ничего не менялось, 1 - Было добавление
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
//====================================================== заполнение дерева узлов
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
  j:= 0; // общий счетчик
  pOrdnum:= 1;
  try
    ORD_IBD:= cntsORD.GetFreeCnt;
    ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);
    ORD_IBS.SQL.Text:= 'select * from TREENODESmotul'+
                       ' order by TRNmDTSYCODE, TRNmCODEPARENT, TRNMcode';
    ORD_IBS.ExecQuery;

    while not ORD_IBS.Eof do begin
      sysID:= ORD_IBS.FieldByName('TRNmDTSYCODE').asInteger;
      //--------------------------------------------------------- 1 система
      if TempList.Count>0 then TempList.Clear; // список сбойных узлов
      while not ORD_IBS.Eof and (sysID=ORD_IBS.FieldByName('TRNmDTSYCODE').asInteger) do begin
        CodeParent:= ORD_IBS.FieldByName('TRNmCODEPARENT').asInteger;

        Code      := ORD_IBS.FieldByName('TRNmCODE').asInteger;
        pName     := ORD_IBS.FieldByName('TRNmNAME').asString;
        pNameSys  := ORD_IBS.FieldByName('TRNmNAMESYS').asString; // пробуем посадить узел в дерево с ходу
        MeasCode  := ORD_IBS.FieldByName('TRNmMEAS').asInteger;
        pVisible  := GetBoolGB(ORD_IBS, 'TRNmVISIBLE');
        pOrdnum   := ORD_IBS.FieldByName('TRNMordnum').asInteger;

        s:= MotulTreeNodes.MotulNodeAdd(CodeParent, 0, sysID, pOrdnum, Code, pName, pNameSys, pVisible, MeasCode);

        if (s<>'') then begin // если не получилось - запоминаем в список
          pNode:= TMotulNode.Create(Code, CodeParent, MeasCode, sysID, pOrdnum, pName, pNameSys, pVisible);
          TempList.Add(pNode)
        end else inc(j); // считаем посаженные узлы

        cntsORD.TestSuspendException;
        ORD_IBS.Next;
      end; // while ...DTSYCode=...

      k:= 0; // счетчик проходов
      if TempList.Count>0 then repeat // ходим по списку сбойных узлов
        for i:= TempList.Count-1 downto 0 do begin
          pNode:= TempList[i];
          if not Assigned(pNode) then begin
            TempList.Delete(i);
            Continue;
          end;
          Code:= pNode.ID;  // нужно для var параметра
                                      // опять пробуем посадить узел в дерево
          s:= MotulTreeNodes.MotulNodeAdd(pNode.ParentID, 0, pNode.TypeSys, pOrdnum,
              Code, pNode.Name, pNode.NameSys, pNode.Visible, pNode.MeasID);
          if (s='') then begin // если получилось
            inc(j);            // считаем посаженные узлы
            TempList.Delete(i);
            prFree(pNode);     // чистим элемент списка
          end;
        end; // for

        inc(k);
      until (TempList.Count<1) or (k>RepeatCount); // пока все не посадим, но не более RepeatCount проходов

      if (TempList.Count>0) then begin // если не все село - пишем в лог
        prMessageLOGS(nmProc+': ошибка записи в кеш '+IntToStr(TempList.Count)+' узлов:', fLogCache, false);
        for i:= TempList.Count-1 downto 0 do begin
          pNode:= TempList[i];
          prMessageLOGS(nmProc+':    код узла -'+IntToStr(pNode.ID)+', '+pNode.Name, fLogCache, false);
          prFree(pNode);
        end;
      end;
      //--------------------------------------------------------- 1 система
    end; //  while not ORD_IBS.Eof
    ORD_IBS.Close;

    for i:= 0 to MotulTreeNodes.ItemsList.Count-1 do begin // сортируем списки детей
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
    MotulTreeNodes.SortNodesList; // сортируем список узлов

    //------------------- заполняем соответствия узлов подбора Motul и основного
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
  prMessageLOGS(nmProc+': '+IntToStr(j)+' узлов - '+GetLogTimeStr(TimeProc), fLogCache, false);
{if flDebug then for i:= 0 to MotulTreeNodes.ItemsList.Count-1 do begin
  pNode:= MotulTreeNodes.ItemsList[i];
  prMessageLOGS(nmProc+': '+IntToStr(pNode.TypeSys)+' - '+IntToStr(pNode.ID)+' - '+pNode.Name, fLogDebug, false);
  Code:= pNode.ID;
  pNode:= MotulTreeNodes[Code];
  prMessageLOGS(nmProc+': other - '+IntToStr(pNode.ID)+' - '+pNode.Name, fLogDebug, false);
end;   }
  TestCssStopException;
end;

//==== проставить признак наличия прод.линеек линкам на ноду и родительские ноды
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
      j:= Node.MainCode; // код главной ноды
      codes:= GetDuplicateNodeCodes(j, True); // коды видимых дублирующих нод
      prAddItemToIntArray(j, codes);    // добавляем код главной ноды
    end;
    mlinks:= Model.NodeLinks;
    for ii:= High(codes) downto 0 do begin        // идем по кодам нод, начиная с главной
      nodeID:= codes[ii];
      link:= mlinks[nodeID];                      // связка с нодой - связка 2
      if not Assigned(link) then Continue;

      if (link.NodeHasPLs=fHas) then Continue; // если признак тот, что надо

      link.NodeHasPLs:= fHas;                   // ставим нужный признак наличия
      Node:= GetLinkPtr(link);                    // ссылка на ноду
      if not Assigned(Node) then Continue;

      if fHas and not Node.Visible then fHas:= False; // на родителей невидимых нод признак True не проставляем

      repeat  // отрабатываем изменение признака вверх по дереву
        i:= Node.ParentID;
        link:= mlinks[i];                         // связка с нодой родителя
        if not Assigned(link) then break;
        if (link.NodeHasPLs=fHas) then break;     // если признак наличия нужный - дальше вверх по дереву не идем
        Node:= GetLinkPtr(link);                  // ссылка на ноду родителя
        if not Assigned(Node) then break;

        if not fHas and Assigned(Node.Children) then // если снять признак
          with Node.Children do begin                // проверяем детей родительской ноды
            fbreak:= False;                          // флаг для выхода из 2-х циклов
            for j:= 0 to Count-1 do begin
              ci:= TAutoTreeNode(Objects[j]).ID;     // код дитяти
              fbreak:= mlinks.LinkExists(ci) and     // если есть линк на дитя с другим признаком - выходим
                (TSecondLink(mlinks[ci]).NodeHasPLs<>fHas);
              if fbreak then break;                  // выходим из for
            end;
            if fbreak then break;                    // выходим из repeat
          end; // with Node.Children

        link.NodeHasPLs:= fHas; // ставим нужный признак наличия линку на ноду родителя
      until i<0;
    end; // for ii:= High(codes) downto 0
  finally
    setLength(codes, 0);
  end;
end;

//========================== удаление/добавление/редактирование связки 3 (Motul)
function TDataCache.CheckPLineModelNodeLink(PlineID, ModelID, NodeID: Integer;
         var ResCode: Integer; pCount: Single=-1; prior: Integer=-1; userID: Integer=0): string;
const nmProc = 'CheckPLineModelNodeLink';
// вид операции - ResCode - на входе (resAdded, resEdited, resDeleted)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось,
// resAdded - добавлена, resEdited - изменена, resDeleted - удалена
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
    if not (OpCode in [resAdded, resEdited, resDeleted]) then // проверяем код операции
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');

    if (OpCode in [resAdded, resEdited]) and (userID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' юзера');

    if not FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));

    if not MotulTreeNodes.MotulNodeGet(NodeID, Node) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));

    pl:= ProductLines.GetProductLine(PlineID);
    if not Assigned(pl) then
      raise EBOBError.Create('Не найдена прод.линейка, код - '+IntToStr(PlineID));

    Model:= FDCA.Models.GetModel(ModelID);
    if (Model.TypeSys<>Node.TypeSys) then
      raise EBOBError.Create('Системы модели и узла не совпадают');

//--------------------------------------------------- отрабатываем запись в базу
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
//------------------------------------------------------------- ответ
    mess:= 'связка '; // модель-узел-прод.линейка
    case ResCode of
      resDoNothing: Result:= mess+'не изменилась';
      resAdded    : Result:= mess+'добавлена';
      resDeleted  : Result:= mess+'удалена';
      resEdited   : Result:= mess+'изменена';
    end;
//---------------------------------------------------- проверяем признаки в кеше
    if (ResCode=resAdded) then try
      if not Model.ModelHasPLs then try  //---------- у модели
        FDCA.Models.CS_Models.Enter;
        Model.ModelHasPLs:= True;
      finally
        FDCA.Models.CS_Models.Leave;
      end;                               //---------- у связок основного подбора
      for i:= 0 to Node.DupNodes.ListLinks.Count-1 do begin
        j:= GetLinkID(Node.DupNodes.ListLinks[i]);
        link2:= Model.NodeLinks[j];
        if not Assigned(link2) then Continue;

        if not link2.NodeHasPLs then
          // проставить признак наличия прод.линеек линкам на ноду и родительские ноды
          SetHasPLsModelNodeParentLinks(Model, j);
{        try
          Model.NodeLinks.CS_links.Enter;
          link2.NodeHasPLs:= True;
        finally
          Model.NodeLinks.CS_links.Leave;
        end; }
      end; // for i:= 0 to Node.DupNodes.ListLinks.Count-1

      case Model.TypeSys of              //---------- у прод.линейки
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
//====================== удаление/добавление условия применения связки 3 (Motul)
function TDataCache.CheckPLineModelNodeUsage(PlineID, ModelID, NodeID: Integer;
         UsageName, UsageValue: String; var ResCode: Integer; userID: Integer=0): string;
const nmProc = 'CheckPLineModelNodeUsage';
// вид операции - ResCode - на входе (resAdded, resDeleted)
// ResCode на выходе: resError- ошибка, resDoNothing - не менялось,
// resAdded - добавлено, resDeleted - удалено
// UsageName - название критерия условия, UsageValue - значение критерия условия
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
    if not (OpCode in [resAdded, resDeleted]) then // проверяем код операции
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');

    if (OpCode=resAdded) and (userID<1) then  // если добавление - проверяем userID
      raise EBOBError.Create(MessText(mtkNotValidParam)+' юзера');

    if not FDCA.Models.ModelExists(ModelID) then              // проверяем модель
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));

    if not MotulTreeNodes.MotulNodeGet(NodeID, Node) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeID)));

    pl:= ProductLines.GetProductLine(PlineID);
    if not Assigned(pl) then
      raise EBOBError.Create('Не найдена прод.линейка, код - '+IntToStr(PlineID));

    Model:= FDCA.Models.GetModel(ModelID);
    if (Model.TypeSys<>Node.TypeSys) then
      raise EBOBError.Create('Системы модели и узла не совпадают');

    ORD_IBD:= cntsOrd.GetFreeCnt; //---------------------------- запись в базу
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
//------------------------------------------------------------- ответ
    mess:= 'условие применения ';
    case ResCode of
      resDoNothing: Result:= mess+'не изменилось';
      resAdded    : Result:= mess+'добавлено';
      resDeleted  : Result:= mess+'удалено';
      resEdited   : Result:= mess+'изменено';
    end;
//------------------------------------------------------------- отрабатываем кэш
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

