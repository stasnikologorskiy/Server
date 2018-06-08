unit s_Utils;

interface

uses Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
  DB, IBDatabase, IBSQL, IBQuery,
  n_free_functions, v_constants, v_Functions, v_DataTrans,
  n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager,
  n_server_common, IniFiles, JPEG, Graphics;

type

  TAccordionFileInfo = record
    NameFolder: string;
    NameFile: Array of String;
    DateFile: Array of Double;
    CountFiles: integer;
    HeaderFile: Array of String;
    IconName: String;
    Header: String;
    Caption: String;
    IsAccordion: integer;
    ViewOrder: integer;
    IsVisible: integer;
  end;

  TAFI = Array of TAccordionFileInfo;

  TEmplInfo = record
    Error: string;
    UserID: string;
    FirmID: string;
    IP: string;
    UserLogin: string;
    SessionID: string;
    UserName: string;
    ServerTime: TDateTime; // ����� �������
    Roles: Tai; // ���� ������������
    ShowImportPage: boolean; // ���� �� ����������� ���� �������
    SysOptions: boolean; // ���� �� ���������� �� ���������� �����������
    ShowNewAttr: boolean; // ���������� ���������� �� ����� New  � ���������
    Links23Loaded: boolean;
    Short: boolean;
    MustChangePass: boolean;
    SessionTimeMinStr: string;
    OnReadyScript: string;

    ContractId: longint;
    NeedCalendar: boolean; // true, ���� ����� ���������
    NeedDropFirmList: boolean; // true, ���� ����� ���������� ������ ����
    NeedTinyMCE: boolean; // true, ���� ����� �������� TinyMCE
    NeedTinyMCEAction: boolean; // true, ���� ����� �������� ��� �����
    PageName: string;
    strPost, strGet, strCookie, strOther: TStringList;
    LogText: string;
  end;

  TUserInfo = record
    Error: string;
    UserID: string;
    FirmID: string;
    IP: string;
    ResetPassword: boolean;
    UserLogin: string;
    UserPass: string;
    SessionID: string;
    UserName: string;
    ShowNewAttr: boolean; // ���������� ���������� �� ����� New  � ���������

    Result: string;
    FirmName: string;
    PrsnEmail: string;
    SuperVisor: boolean;
    riSendOrder: boolean;
    riViewOwnPrice: boolean;
    riViewDiscountTable: boolean;
    ServerTime: TDateTime; // ����� �������
    ShowImportPage: boolean; // ���� �� ����������� ���� �������
    SysOptions: boolean; // ���� �� ���������� �� ���������� �����������
    Links23Loaded: boolean;
    Short: boolean;
    FirstEnter: boolean;
    Autenticated: boolean;
    SessionTimeMinStr: string;
    TechWork: string;
    OnReadyScript: string;
    ContractsCount: longint;
    ContractName: string;
    LegalFirmName: string;
    StoreName: string;
    square_height: integer;
    ballsName: string; // ��� ��� �������
    contBonusOrd: integer; // �������� ���� ������ ��������������
    contBonusReserv: Double; // �������� ���� ������ ��������������
    qvPriceCol: integer; // ���������� �������  ��� ���
    // ------------------���� ���������� ��� ������
    DirectParams: integer; // ���-�� �����������
    DirectName: String; // �������� �����������
    LevelCount: integer; // ���-�� �������
    FirmModel_Rating: integer; // ������� �������
    FirmModel_Sales: integer; // ���������� ������� �������� ������
    NextModel_Rating: integer;
    // �������, �� �������� �/� �� ���������� �� ������� �������� ������
    NextModel_Sales: integer;
    // ���������� ������� ������, �� �������� �/� �� ����������
    ProcToNext: integer;
    // ������� ������� �����, �������� �� ������� �� ������, �� �������� �/� �� ����������
    FirmSales: integer; // ���������� �������� ������� �/�
    IsMotoClient: boolean;
    IsUberClient: boolean;
    PhoneClientCentr        :string ;
    PhoneSupport       :string;
    BaseUrl: string;
    BaseDir: string;
    DescrUrl: string;
    DescrImageUrl: string;
    OuterJSPatch: string;
    OuterCssPatch: string;
    BlockedIP: string;
    TmpDir: string;
    DescrDir: string;
    iniFileName: string;
    globToHeader: string;
    JSVersion: string;
    ContractId: longint;
    FastMessage: string;
    ScriptName: string;
    PageName: string;
    TitleStr: string;
    globToScript: string;
    strPost, strGet, strCookie, strOther: TStringList;
    LogText: string;
    Curs, CursBonus, BonusQty: Double;
    CredLimit, Debt, DebtEUR, DebtUAH, OrderSum, PlanOutSum, ResLimit,
    ResLimitRest: Double;
    CredCurrencyCode: integer;
    CredCurrency, FirmCode, WarningMessage: string;
    SaleBlock: boolean;
    DrawVinButton: boolean;
    FullData: boolean;
    ActionText: string;
    CredDelay: integer;
    WhenBlocked: integer;    // ����, ����� ������� �������� ���������� �� ������� ��������� ������
    flRedesign: boolean ; // ���� ��� ���������
    flUber: boolean;
    flInitMedia: boolean;
    flInitMediaUber: boolean;
    flCV: boolean;
    flFastMessage: boolean;
    flTechWork : boolean;
    flTest: boolean;
  end;

type
  TTypeFile = (tfBMP, tfICON, tfCURSOR, tfWAVE, tfMIDI,
    // ��� �������� ����� ������ ��� jpeg
    tfHUC, tfJPG, tfGIF, tfTIF, tfMO3, tfPNG, tfPCX, tfUnknown);

procedure prOnReadyScriptAdd(text: string);
function fnWriteTableData(MainHeader, TableHeader, TableBody: string;
  MainHeaderWrapHeight: integer = 0): string;
function fnWriteSimpleText(s: string): string;
function fnGetFieldStrList(StL1: TStringList; StL2: TStringList;
  ValueName: String; ToANSI: boolean = false): string;
function GetJSSafeStringArg(s: string): string;
function parseRequestStr(parseStr: String; mode: integer = 0;
  divider: char = ';'): TStringList;
// ��������� ������ �� ��������� ����������� � ���������
function GetJSSafeStringArgMonoQuote(s: string): string;
function GetHTMLSafeString(s: string; ReplaceAmp: boolean = false): string;
function fnGetLTWHStyle(l, t, w, h: integer): string;
function GetJSSafeString(s: string): string;
function StripHTMLTags(txt: string): string;
function nonAutenticatedMessage(JSNA, JSTW: boolean): string;
function fnListToOptions(Stream: TBobMemoryStream): string;
procedure setErrorStrs(var userInf: TEmplInfo; var StreamIn: TBobMemoryStream;
  var StreamOut: TBobMemoryStream);
procedure setErrorCommand(var StreamIn: TBobMemoryStream;
  var StreamOut: TBobMemoryStream);
procedure setErrorCommandStr(var StreamOut: TBobMemoryStream; erStr: String);
procedure setOnlineErrorStrs(var userInf: TUserInfo;
  var StreamIn: TBobMemoryStream; var StreamOut: TBobMemoryStream);
procedure GetAllHTMLFiles(Path: string; var filelist: TAFI);
function fnBindFuncToNewNodes(NodeId: string): string;
function fnGetPortionWindow(Content: string = ''): string;
function fnPayFormByCode(code: integer): string;
function getBackGrColor(WarnMessage: String; status: integer;
  blocked: boolean): integer;
function fnGetValueFromPairCheckBoxes(var userInf: TEmplInfo;
  First, Second: string): integer;
function scaleImages(var jpg: TJpegImage; Width: integer; Height: integer)
  : string; // ������� ��� �������������� �������� ��������
function getTypeFile(AFileName: String): String;
function CheckTypeFile(P: Pointer): TTypeFile;
function fnReceiveStorages(Stream: TBobMemoryStream): TaSD;
function scaleImagesMotul(var jpg: TJpegImage; Width: integer; Height: integer)  : string; // ������� ��� �������������� �������� ��������
procedure setErrorStrsOrder(var userInf: TUserInfo; var StreamIn: TBobMemoryStream; var StreamOut: TBobMemoryStream);

const
  arDelayWarningsColor: array [0 .. 3] of string = ('green', '#f0f',
    'red', '#ddd');
  ignored_tags: array [0 .. 2] of string = ('<br', '<hr', '<img');
  // ���� ��� �������������
  oNonSavedColor: string = '#ffd2d2';
  cTitleLegal: string = '��. ����';
  arDelayWarningsColorRedisign: array [0 .. 3] of string = ('#00cb63', '#f0f',
    '#ff0000', '#ddd');

 InputbackColor: string = '#00cb63';

const
  THeaderFile: array [0 .. 11, 0 .. 6] of Byte = (
    { BMP } ($42, $4D, 0, 0, 0, 0, 2),
    { ICON } (0, 0, 1, 0, 0, 0, 4),
    { CURSOR } (0, 0, 2, 0, 0, 0, 4),
    { WAVE } ($52, $49, $46, $46, 0, 0, 4),
    { MIDI } ($4D, $54, $68, $64, 0, 0, 4),
    { HUC } ($48, $55, $43, 0, 0, 0, 3),
    { JPG } ($FF, $D8, $FF, 0, 0, 0, 3),
    { GIF } ($47, $49, $46, $38, 0, 0, 4),
    { TIF } ($49, $49, $2A, $00, 0, 0, 4),
    { MO3 } ($4D, $4F, $33, $04, 0, 0, 4),
    { PNG } ($89, $50, $4E, $47, $0D, $0A, 6),
    { PCX } ($0A, $05, 0, 0, 0, 0, 2));



implementation

uses s_WebArmProcedures,s_OnlineProcedures;

function fnReceiveStorages(Stream: TBobMemoryStream): TaSD;
var
  i, j: integer;
begin

  SetLength(Result, Stream.ReadInt);
  for i := 0 to Length(Result) - 1 do
  begin
    Result[i].code := Stream.ReadStr;
    Result[i].FullName := Stream.ReadStr;
    Result[i].ShortName := Stream.ReadStr;
    j := Stream.ReadInt;
    Result[i].IsDefault := ((constStorDefault and j) > 0);
    Result[i].IsVisible := ((constStorVisible and j) > 0);
    Result[i].IsReserve := ((constStorReserve and j) > 0);
    Result[i].IsSale := ((constStorSale and j) > 0);
  end;
end;

function fnPayFormByCode(code: integer): string;
begin
  Result := '';
  case code of
    0:
      Result := '��������';
    1:
      Result := '�����������';
  end;
end;

function fnGetValueFromPairCheckBoxes(var userInf: TEmplInfo;
  First, Second: string): integer;
var
  F, s: string;
begin
  Result := -1;
  F := fnGetFieldStrList(userInf.strPost, userInf.strGet, First);
  s := fnGetFieldStrList(userInf.strPost, userInf.strGet, Second);
  if ((F <> '') and (s = '')) then
    Result := 1;
  if ((F = '') and (s <> '')) then
    Result := 0;
end;

function getBackGrColor(WarnMessage: String; status: integer;
  blocked: boolean): integer;
begin
  if WarnMessage = '' then
  begin
    if status = cstClosed then
      Result := 3;
    if status = cstWorked then
      Result := 0;
  end
  else
  begin
    if blocked then
      Result := 2
    else
      Result := 1;
  end;
end;

function fnGetPortionWindow(Content: string = ''): string;
begin
  Result := '';
  Result := Result + '<div style="width: 500px; height: 500px;">';
  Result := Result + Content;
  Result := Result + '</div>';
  Result := Result + '<div style="white-space: nowrap;">';
  Result := Result + '<input type=hidden id=blocknum value=-1>';
  Result := Result +
    '<button onclick="$(\''#btnSaveCriteria\'').val(\''�������� ��������\''); $(\''#btnSaveCriteria\'').attr(\''rowcode\'', \''\''); $(\''#critname\'').val(\''\''); '
  // +'$(\''#critvalue\'').val(\''\''); $.fancybox.open($(\''#addcoudiv\''), {\''modal\'' : true, \''padding\'': 10});" id=uiAddCriteria>�������� ��������</button>';
    + '$(\''#critvalue\'').val(\''\''); $(\''#addcoudiv\'').dialog(\''open\'');" id=uiAddCriteria>�������� ��������</button>';
  Result := Result +
    '<button onclick="saveportionNew();" id=uiSavePortion>��������� ���������</button>';
  Result := Result +
    '<button onclick="if ($(\''#uiSavePortion\'').button( \''option\'', \''disabled\'') || confirm(\''�� ������������� ������ ������� ����?\'')) $(\''#jqueryuidiv\'').dialog(\''destroy\'');">������� ����</button>';
  Result := Result + '</div>';
end;

function GetFileDateTime(FileName: string): TDateTime;
var
  intFileAge: longint;
begin
  intFileAge := FileAge(FileName);
  if intFileAge = -1 then
    Result := 0
  else
    Result := FileDateToDateTime(intFileAge)
end;

procedure GetAllHTMLFiles(Path: string; var filelist: TAFI);
var
  sRec: TSearchRec;
  isFound: boolean;
  SL: TStringList;
  pIniFile: TIniFile;
  i: integer;
begin
  isFound := FindFirst(Path + '\*.*', faAnyFile, sRec) = 0;
  SL := TStringList.create;
  try
    while isFound do
    begin
      if (sRec.Name <> '.') and (sRec.Name <> '..') then
      begin
        if (ExtractFileExt(sRec.Name) = '.html') or
          ((sRec.Attr and faDirectory) = faDirectory) then
        begin
          if (sRec.Attr and faDirectory) = faDirectory then
          begin
            SetLength(filelist, Length(filelist) + 1);
            SetLength(filelist[Length(filelist) - 1].NameFile, 0);
            SetLength(filelist[Length(filelist) - 1].DateFile, 0);
            SetLength(filelist[Length(filelist) - 1].HeaderFile, 0);
            filelist[Length(filelist) - 1].NameFolder := sRec.Name;
            GetAllHTMLFiles(Path + '\' + sRec.Name, filelist);
          end
          else
          begin
            SL.Clear;
            SL.LoadFromFile(Path + '\' + sRec.Name);
            SetLength(filelist[Length(filelist) - 1].HeaderFile,
              Length(filelist[Length(filelist) - 1].HeaderFile) + 1);
            filelist[Length(filelist) - 1].HeaderFile
              [Length(filelist[Length(filelist) - 1].HeaderFile) - 1] := SL[0];
          end;
          SetLength(filelist[Length(filelist) - 1].NameFile,
            Length(filelist[Length(filelist) - 1].NameFile) + 1);
          SetLength(filelist[Length(filelist) - 1].DateFile,
            Length(filelist[Length(filelist) - 1].DateFile) + 1);
          filelist[Length(filelist) - 1].NameFile
            [Length(filelist[Length(filelist) - 1].NameFile) - 1] := sRec.Name;
          filelist[Length(filelist) - 1].DateFile
            [Length(filelist[Length(filelist) - 1].NameFile) - 1] :=
            GetFileDateTime(Path + '\' + sRec.Name);
          Inc(filelist[Length(filelist) - 1].CountFiles);
        end
        else
        begin
          if (ExtractFileExt(sRec.Name) = '.ini') then
          begin
            // prMessageLOG(IntToStr(Length(filelist)));
            pIniFile := TIniFile.create(DescrDir + '/InfoFiles1/' +
              filelist[Length(filelist) - 1].NameFolder + '/header.ini');
            filelist[Length(filelist) - 1].Header :=
              pIniFile.ReadString('Options', 'TopicName', '');
            filelist[Length(filelist) - 1].Caption :=
              pIniFile.ReadString('Options', 'GeneralText', '');
            filelist[Length(filelist) - 1].IconName :=
              pIniFile.ReadString('Options', 'IconName', '');
            filelist[Length(filelist) - 1].ViewOrder :=
              pIniFile.ReadInteger('Options', 'TabOrder', 0);
            filelist[Length(filelist) - 1].IsVisible :=
              pIniFile.ReadInteger('Options', 'Visible', 0);
            prFree(pIniFile);
          end;
        end;

      end;
      isFound := FindNext(sRec) = 0;
    end;
    for i := 0 to Length(filelist) - 1 do
    begin
      pIniFile := TIniFile.create(DescrDir + '/InfoFiles1/' + filelist[i]
        .NameFolder + '/header.ini');
      if filelist[i].CountFiles > 2 then
      begin
        pIniFile.WriteString('Options', 'Accord', '1');
        filelist[i].IsAccordion := 1;
      end
      else
      begin
        pIniFile.WriteString('Options', 'Accord', '0');
        filelist[i].IsAccordion := 0;
      end;
      prFree(pIniFile);
    end;
  finally
    FreeAndNil(SL);
    SysUtils.FindClose(sRec);
  end;
end;

// ������� ��������� ������ �� ��������
function fnWriteTableData(MainHeader, TableHeader, TableBody: string;
  MainHeaderWrapHeight: integer = 0): string;
begin
  Result := '';
  Result := Result +
    '<div id=thw><div id=tht></div><img id=thlt src="/images/window/corner-top-left.png"><img id=thrt src="/images/window/corner-top-right.png">'#13#10;
  Result := Result + '</div>'#13#10; // <div id=thw>

  Result := Result +
    '<div id=tcdbackground></div><div id=mfb></div><img id=mflb src="/images/window/corner-bottom-left.png"><img id=mfrb src="/images/window/corner-bottom-right.png">';
  Result := Result + '<div id=mainheaderwrap ' +
    fnIfStr(MainHeaderWrapHeight = 0, '', ' style="height: ' +
    IntToStr(MainHeaderWrapHeight) + 'px;"') + '>' + MainHeader +
    '<div style="clear: both;"></div>';
  Result := Result + '</div>'; // mainheader, mainheaderwrap

  Result := Result +
    '<div id=tableheaderdiv><table id="tableheader" class=st cellspacing=0>' +
    TableHeader + '</table></div>'#13#10;

  Result := Result + '<div id=tablecontentdiv>'#13#10;
  Result := Result + '<table class=st cellspacing=0 id="tablecontent">' +
    TableBody + '</table>'#13#10;
  Result := Result +
    '<table class=st cellspacing=0 id="tablecontent2"></table>'#13#10;
  Result := Result + '</div>'#13#10; // <div id=tablecontentdiv>
end;

// ������� ����� � maindiv �� ����� ���������. ������������ ��� ������������ ���� � ������������� � ������
function fnWriteSimpleText(s: string): string;
begin
  Result := '';
  Result := Result +
    '<div id=tcdbackground></div><div id=mfb></div><img id=mflb src="/images/window/corner-bottom-left.png">';
  Result := Result + '<div id=mainheaderwrap>';
  Result := Result + '</div>'; // mainheader, mainheaderwrap
  Result := Result +
    '<div id=thw><div id=tht></div><img id=thlt src="/images/window/corner-top-left.png"><img id=thrt src="/images/window/corner-top-right.png"></div>';
  Result := Result + '<div id=tablecontentdiv>';
  Result := Result + '<div style="margin: 10px;">' + s + '</div>';
  Result := Result + '</div>';
end;

// ���� � ����� �����������, ���� ����, �� � ������
function fnGetFieldStrList(StL1: TStringList; StL2: TStringList;
  ValueName: String; ToANSI: boolean = false): string;
begin
  Result := trim(StL1.Values[ValueName]);
  if (Result = '') then
  begin
    Result := trim(StL2.Values[ValueName]);
  end;
  if ToANSI then
    Result := UTF8ToANSI(Result);

end;

function parseRequestStr(parseStr: String; mode: integer = 0;
  divider: char = ';'): TStringList;
// ��������� ������ �� ��������� ����������� � ���������
var
  StL1, StL2: TStringList;
  i: integer;
begin
  StL1 := TStringList.create;
  StL2 := TStringList.create;
  Result := TStringList.create;
  try
    if mode = 0 then
    begin
      parseStr := StringReplace(parseStr, #13#10, ';', [rfReplaceAll]);
      parseStr := StringReplace(parseStr, '%7C', '|', [rfReplaceAll]);
      parseStr := StringReplace(parseStr, '%2C', ',', [rfReplaceAll]);
      StL1.Clear;
      StL2.Clear;
      StL1 := fnSplit(';', parseStr);
      for i := 0 to StL1.Count - 1 do
      begin
        StL2 := fnSplit('=', StL1[i]);
        if StL2.Count > 1 then
          Result.Add(Format('%s=%s', [StL2[0], StL2[1]]))
        else
          Result.Add(Format('%s=%s', [StL2[0], ' ']));
      end;
    end;
    if mode = 1 then
    begin
      StL1.Clear;
      StL2.Clear;
      StL1 := fnSplit(divider, parseStr);
      for i := 0 to StL1.Count - 1 do
      begin
        StL2 := fnSplit('=', StL1[i]);
        if StL2.Count > 1 then
          Result.Add(Format('%s=%s', [StL2[0], StL2[1]]))
        else
          Result.Add(Format('%s=%s', [StL2[0], ' ']));
      end;
    end;
  finally
    StL1.Free;
    StL2.Free;
  end;

end;

// ������� ������ � ������������� ��� �������� �������
function GetJSSafeStringArg(s: string): string;
begin
  s := StringReplace(s, '\', '\\', [rfReplaceAll]);
  s := StringReplace(s, '"', '\"', [rfReplaceAll]);
  s := StringReplace(s, #39, '`', [rfReplaceAll]);
  s := StringReplace(s, #13#10, '<br>', [rfReplaceAll]);
  s := StringReplace(s, #13, '<br>', [rfReplaceAll]);
  s := StringReplace(s, #10, '<br>', [rfReplaceAll]);
  Result := s;
end;

// ������� ������ � ������������� ��� �������� �������
function GetJSSafeStringArgMonoQuote(s: string): string;
begin
  s := StringReplace(s, '\', '\\', [rfReplaceAll]);
  s := StringReplace(s, '''', '\''', [rfReplaceAll]);
  s := StringReplace(s, #39, '`', [rfReplaceAll]);
  s := StringReplace(s, #13, '', [rfReplaceAll]);
  s := StringReplace(s, #10, '', [rfReplaceAll]);
  Result := s;
end;

// ������� ������ ��������� � ������ � ���� HTML
function GetHTMLSafeString(s: string; ReplaceAmp: boolean = false): string;
begin
  s := StringReplace(s, '<', '&lt;', [rfReplaceAll]);
  s := StringReplace(s, '>', '&gt;', [rfReplaceAll]);
  s := StringReplace(s, '"', '&quot;', [rfReplaceAll]);
  s := StringReplace(s, '''', '&#0039;', [rfReplaceAll]);
  s := StringReplace(s, #13#10, '<br>', [rfReplaceAll]);
  s := StringReplace(s, #13, '<br>', [rfReplaceAll]);
  s := StringReplace(s, #10, '<br>', [rfReplaceAll]);
  s := StringReplace(s, '#$&', '"', [rfReplaceAll]);
  if ReplaceAmp then
    s := StringReplace(s, '&', '&amp;', [rfReplaceAll]);
  Result := fnDeCodeBracketsInWeb(s);
end;

// ������ ������ ��� ����� � ���������� left, top, width, height
function fnGetLTWHStyle(l, t, w, h: integer): string;
begin
  Result := 'style="left: ' + IntToStr(l) + 'px; top: ' + IntToStr(t) +
    'px; width: ' + IntToStr(w) + 'px; ' +
    fnIfStr(h > 0, 'height: ' + IntToStr(h), 'bottom: ' + IntToStr(-h))
    + 'px;"';
end;

function ReadMultipartRequest(const Boundary: string; ARequest: string;
  var AHeader: TStrings; var Data: string): string;
var
  Req, RHead: string;
  i: integer;
begin
  Result := '';
  AHeader.Clear;
  Data := '';
  if (Pos(Boundary, ARequest) < Pos(Boundary + '--', ARequest)) and
    (Pos(Boundary, ARequest) = 1) then
  begin
    Delete(ARequest, 1, Length(Boundary) + 2);
    Req := Copy(ARequest, 1, Pos(Boundary, ARequest) - 3);
    Delete(ARequest, 1, Length(Req) + 2);
    RHead := Copy(Req, 1, Pos(#13#10#13#10, Req) - 1);
    Delete(Req, 1, Length(RHead) + 4);
    // Delete(Req, 1, Length(RHead));
    AHeader.text := RHead;
    for i := 0 to AHeader.Count - 1 do
      if Pos(':', AHeader.Strings[i]) > 0 then
        AHeader.Strings[i] :=
          trim(Copy(AHeader.Strings[i], 1, Pos(':', AHeader.Strings[i]) - 1)) +
          '=' + trim(Copy(AHeader.Strings[i], Pos(':', AHeader.Strings[i]) + 1,
          Length(AHeader.Strings[i]) - Pos(':', AHeader.Strings[i])));
    Data := Req;
    Result := ARequest;
  end
end;

// ������� ������ ��������� � ������ � ������� alert � JavaScript
function GetJSSafeString(s: string): string;
begin
  s := StringReplace(s, '"', '`', [rfReplaceAll]);
  s := StringReplace(s, #13#10, '\n', [rfReplaceAll]);
  s := StringReplace(s, #13, '\n', [rfReplaceAll]);
  s := StringReplace(s, #10, '\n', [rfReplaceAll]);
  // s:=StringReplace(s, '#$&', '"', [rfReplaceAll]);
  Result := s;
end;

function StripHTMLTags(txt: string): string;
var
  i: integer;
begin
  Result := '';
  i := Pos('<', txt);
  while i > 0 do
  begin
    Result := Result + Copy(txt, 1, i - 1);
    i := Pos('>', txt);
    if i = 0 then
    begin
      txt := '';
    end
    else
    begin
      txt := Copy(txt, i + 1, Length(txt));
    end;
    i := Pos('<', txt);
  end;
  Result := Result + txt;
end;

function nonAutenticatedMessage(JSNA, JSTW: boolean): string;
var
  s, s1: string;
  F: text;
begin
  if FileExists('.\' + TechWork) then
  begin
    AssignFile(F, '.\' + TechWork);
    Reset(F);
    s := '';
    while not eof(F) do
    begin
      Readln(F, s1);
      s := s + s1;
    end;
    CloseFile(F);
    if JSTW then
    begin
      Result := 'alert("' + GetJSSafeString(StripHTMLTags(s)) + '");';
    end
    else
    begin
      Result := s;
    end;
  end
  else
  begin
    if JSNA then
    begin
      Result := 'alert("' + coReloginText + '");';
    end
    else
    begin
      Result := '<span class=errormess>' + coReloginText + '</span>';
    end;
  end;
end;

procedure prOnReadyScriptAdd(text: string);
begin
  OnReadyScript := OnReadyScript + text;
end;

function fnListToOptions(Stream: TBobMemoryStream): string;
var
  Count, i: integer;
begin
  Result := '';
  Count := Stream.ReadInt;
  for i := 0 to Count do
  begin
    Result := Result + '<option value=' + IntToStr(Stream.ReadInt) + '>' +
      GetHTMLSafeString(Stream.ReadStr) + '</option>';
  end;
end;

procedure setErrorStrs(var userInf: TEmplInfo; var StreamIn: TBobMemoryStream;
  var StreamOut: TBobMemoryStream);
var
  s, Error: String;
begin
  OnReadyScript := '';
  StreamOut.Clear;
  StreamOut.WriteInt(aeCommonError);
  StreamOut.WriteLongStr(fnHeader(userInf));
  Error := StreamIn.ReadStr;
  s := 'jqswMessageError(''' + GetHTMLSafeString(Error) + ''');';
  StreamOut.WriteStr(s + fnWriteSimpleText('������ ����������: ' +
    GetHTMLSafeString(Error)));
  StreamOut.WriteLongStr(fnFooter(userInf));
end;

procedure setErrorStrsOrder(var userInf: TUserInfo; var StreamIn: TBobMemoryStream; var StreamOut: TBobMemoryStream);
var
  s, Error: String;
begin
  OnReadyScript := '';
  StreamOut.Clear;
  StreamOut.WriteInt(aeCommonError);
  StreamOut.WriteLongStr(fnHeaderRedisign(userInf));
  Error := StreamIn.ReadStr;
  s := '<script> jqswMessageError(''' + GetHTMLSafeString(Error) + '''); </script>';
  StreamOut.WriteStr(s);
  StreamOut.WriteStr(fnFooterRedisign(userInf));
  StreamOut.WriteStr(userInf.UserID);
  StreamOut.WriteStr(userInf.FirmID);
  StreamOut.WriteStr(IntToStr(userInf.ContractId));
end;

procedure setErrorCommand(var StreamIn: TBobMemoryStream;
  var StreamOut: TBobMemoryStream);
var
  Error: String;
begin
  StreamOut.Clear;
  StreamOut.WriteInt(aeCommonError);
  Error := StreamIn.ReadStr;
  StreamOut.WriteStr(GetHTMLSafeString(Error));
end;

procedure setErrorCommandStr(var StreamOut: TBobMemoryStream; erStr: String);
var
  Error: String;
begin
  StreamOut.Clear;
  StreamOut.WriteInt(aeCommonError);
  StreamOut.WriteStr(erStr);
end;

procedure setOnlineErrorStrs(var userInf: TUserInfo;
  var StreamIn: TBobMemoryStream; var StreamOut: TBobMemoryStream);
var
  s, Error: String;
begin
  OnReadyScript := '';
  StreamOut.Clear;
  StreamOut.WriteInt(aeCommonError);
  // StreamOut.WriteLongStr(fnHeader(userInf));
  Error := StreamIn.ReadStr;
  s := 'jqswMessageError(''' + GetHTMLSafeString(Error) + ''');';
  StreamOut.WriteStr(s + fnWriteSimpleText('������ ����������: ' +
    GetHTMLSafeString(Error)));
  // StreamOut.WriteLongStr(fnFooter(userInf));
end;

function fnBindFuncToNewNodes(NodeId: string): string;
var
  s: string;
begin
  s := '';
  // s:=s+'$(''#tv_a1_'+NodeId+''').each(function(index) {'#13#10;
  s := s + '$(''a[id^="tv_a1_' + NodeId + '"]'').each(function(index) {'#13#10;
  s := s + '  var num=parseInt($(this)[0].id.substr(6));'#13#10;
  s := s + '  if ($(''#tv_ul_''+num)[0]) {'#13#10;
  s := s + '  $(this).html(''&#9658;'');'#13#10;
  s := s + '  $(this).bind(''click'', function(event) {;'#13#10;
  s := s + '    UnHide(this);'#13#10;
  s := s + '  });'#13#10;
  s := s + '  }'#13#10;
  s := s + '});'#13#10;

  // �������� ������� ����������� � �������� �����������
  // s:=s+'$(''#tv_a2_'+NodeId+''').each(function(index) {'#13#10;
  s := s + '$(''a[id^="tv_a2_' + NodeId + '"]'').each(function(index) {'#13#10;
  s := s + '  $(this).bind(''click'', function(event) {;'#13#10;
  s := s + '    $("#outername").val(this.innerHTML);'#13#10;
  s := s + '    $("#innername").val(this.title);'#13#10;
  s := s + '    $("#curnodetd").html(this.title);'#13#10;
  s := s + '    $("#nodevisibility")[0].checked=$("#tv_cb_"+$(this).attr("code"))[0].checked;'#13#10;
  s := s + '    $("#mainnodecode").val($(this).attr("mainnode"));'#13#10;
  s := s + '    if ($(this).attr("isend")!="true") {'#13#10;
  s := s + '      $("#mainnodename").html("�� ��������� ��� ���������� �����");'#13#10;
  s := s + '    } else if ($(this).attr("code")==$(this).attr("mainnode")) {'#13#10;
  s := s + '      $("#mainnodename").html("���� ���� - �������");'#13#10;
  s := s + '    } else { '#13#10;
  s := s + '      $("#mainnodename").html($("#tv_a2_"+$(this).attr("mainnode")).attr("title"));'#13#10;
  s := s + '    } '#13#10;

  s := s + '    $(''a[id^="tv_a2_"]'').removeClass("fatbrowntext");'#13#10;
  s := s + '    $(this).addClass("fatbrowntext");'#13#10;
  s := s + '    curnode=this;'#13#10;
  s := s + '  });'#13#10;
  s := s + '});'#13#10;
  Result := s;
end;

function scaleImages(var jpg: TJpegImage; Width: integer; Height: integer)
  : string; // ������� ��� �������������� �������� ��������
var
  scale: Double; // ����������� ������/������
  dw: Double;
  bmp: TBitmap;
begin
  try
    bmp := TBitmap.create;
    bmp.Width := jpg.Width;
    bmp.Height := jpg.Height;
    // if jpg.Width<jpg.Height then
    scale := jpg.Width / jpg.Height;
    // else
    // scale:=jpg.Height/jpg.Width;
    if (jpg.Width > Width) then
    begin
      dw := jpg.Width - Width;
      bmp.Width := Width;
      if (scale >= 1) then
        bmp.Height := jpg.Height - Round(dw / scale)
      else
        bmp.Height := jpg.Height - Round(dw * scale)
    end;
    if (bmp.Height > Height) then
    begin
      dw := bmp.Height - Height;
      bmp.Height := Height;
      // prMessageLOG(FloatToStr(dw));
      // prMessageLOG(FloatToStr(scale));
      // prMessageLOG(FloatToStr(bmp.Width-Round(dw*scale)));
      if (scale >= 1) then
        bmp.Width := jpg.Width - Round(dw / scale)
      else
        bmp.Width := jpg.Width - Round(dw * scale)
    end;
    bmp.Canvas.StretchDraw(bmp.Canvas.Cliprect, jpg);
    jpg.Assign(bmp);
  finally
    bmp.Free;
  end;
end; // scaleImages

function scaleImagesMotul(var jpg: TJpegImage; Width: integer; Height: integer)
  : string; // ������� ��� �������������� �������� ��������
var
  scale: Double; // ����������� ������/������
  dw: Double;
  bmp: TBitmap;
begin
  try
    bmp := TBitmap.create;
    bmp.Width := jpg.Width;
    bmp.Height := jpg.Height;
    // if jpg.Width<jpg.Height then
    scale := jpg.Width / jpg.Height;
    // else
    // scale:=jpg.Height/jpg.Width;
    while ((bmp.Width > Width) or (bmp.Height > Height)) do
    begin
      if (bmp.Width > Width) then
      begin
        dw := bmp.Width - Width;
        bmp.Width := Width;
        if (scale <= 1) then
          bmp.Height := bmp.Height - Round(dw / scale)
        else
          bmp.Height := bmp.Height - Round(dw * scale)
      end;
      if (bmp.Height > Height) then
      begin
        dw := bmp.Height - Height;
        bmp.Height := Height;
        if (scale >= 1) then
          bmp.Width := bmp.Width - Round(dw / scale)
        else
          bmp.Width := bmp.Width - Round(dw * scale)
      end;
    end;

    bmp.Canvas.StretchDraw(bmp.Canvas.Cliprect, jpg);
    jpg.Assign(bmp);
  finally
    bmp.Free;
  end;
end; // scaleImages

function getTypeFile(AFileName: String): String;
var
  Stream: TFileStream;
  Buf: Pointer;
begin
  GetMEm(Buf, 5);
  Stream := TFileStream.create(AFileName, fmOpenRead);
  Result := 'Unknown format';
  Try
    Stream.ReadBuffer(Buf^, 5);
    case CheckTypeFile(Buf) of
      tfJPG:
        Begin
          Result := 'JPEG';
        End;
      tfBMP:
        Begin
          Result := 'BMP';
        End;
      tfGIF:
        Begin
          Result := 'GIF';
        End;
      tfTIF:
        Begin
          Result := 'TIF';
        End;
      tfPNG:
        Begin
          Result := 'PNG';
        End;
      // Else Raise Exception.Create('Unknown format');
    end;
  Finally
    Stream.Free;
    FreeMem(Buf, 5);
  End;
end;

function CheckTypeFile(P: Pointer): TTypeFile;
var
  i: integer;
begin
  Result := tfUnknown;
  for i := Low(THeaderFile) to High(THeaderFile) do
    if CompareMem(P, @THeaderFile[i], THeaderFile[i][High(THeaderFile[0])]) then
    begin
      Result := TTypeFile(i);
      Break;
    end;
end;

end.
