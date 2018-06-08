unit n_xml_functions;

interface
uses Classes, SysUtils, Types, Graphics, a_XmlUse;

function sTxtCell(s: String; TextStyle: TXmlReportStyle=nil): String; // simple TXT cell
function sIntCell(i: Integer; TextStyle: TXmlReportStyle=nil): String; // simple Integer cell
function sHeadCell(s: String; TextStyle: TXmlReportStyle=nil): String; // simple Header cell
function sBoldCell(s: String; TextStyle: TXmlReportStyle=nil): String; // simple Bold cell
procedure AddXmlLine(lst: TStringList; s: String);
procedure AddXmlBookBegin(lst: TStringList; CellStylesArray: TXmlCellStylesArray=nil); // открываем Workbook
procedure AddXmlSheetBegin(lst: TStringList; SheetName: String; Ncolumns: Word=0); // открываем worksheet
procedure AddXmlSheetEnd(lst: TStringList; X: integer=0; Y: integer=0); // закрываем worksheet
procedure AddXmlBookEnd(lst: TStringList); // закрываем Workbook
procedure SaveXmlListToFile(lst: TStringList; fNameWithoutExt: String);
procedure CheckTxtStyle;
procedure CheckHeadStyle;
procedure CheckBoldStyle;
procedure ClearStyles;

var sTxtStyle, sHeadStyle, sBoldStyle: TXmlReportStyle;
    sStylesArray: TXmlCellStylesArray;

implementation
//============================================================== simple TXT cell
function sTxtCell(s: String; TextStyle: TXmlReportStyle=nil): String;
begin
  if not Assigned(TextStyle) then begin
    CheckTxtStyle;
    TextStyle:= sTxtStyle;
  end;
  Result:= fnGenerateXMLcell(s, TextStyle);
end;
//=========================================================  simple Integer cell
function sIntCell(i: Integer; TextStyle: TXmlReportStyle=nil): String;
begin
  if not Assigned(TextStyle) then begin
    CheckTxtStyle;
    TextStyle:= sTxtStyle;
  end;
  Result:= fnGenerateXMLcell(IntToStr(i), TextStyle, '', '', 0, 0, 0, cnXmlNumber);
end;
//==========================================================  simple Header cell
function sHeadCell(s: String; TextStyle: TXmlReportStyle=nil): String;
begin
  if not Assigned(TextStyle) then begin
    CheckHeadStyle;
    TextStyle:= sHeadStyle;
  end;
  Result:= fnGenerateXMLcell(s, TextStyle);
end;
//=======================================================  simple Bolder cell
function sBoldCell(s: String; TextStyle: TXmlReportStyle=nil): String;
begin
  if not Assigned(TextStyle) then begin
    CheckBoldStyle;
    TextStyle:= sBoldStyle;
  end;
  Result:= fnGenerateXMLcell(s, TextStyle);
end;
//==============================================================================
procedure AddXmlLine(lst: TStringList; s: String);
begin
  lst.Add('<Row>'#10+s+'</Row>'#10);
end;
//=========================================================== открываем Workbook
procedure AddXmlBookBegin(lst: TStringList; CellStylesArray: TXmlCellStylesArray=nil);
begin
  if not Assigned(lst) then lst:= TStringList.Create;
  lst.Add(cEX_Doc_Begin);
  lst.Add(cEX_Workbook_Begin);
  if not Assigned(CellStylesArray) then begin
    CheckTxtStyle;
    CellStylesArray:= sStylesArray;
  end;
  lst.Add(CellStylesArray.GetXmlStyles);
end;
//========================================================== открываем worksheet
procedure AddXmlSheetBegin(lst: TStringList; SheetName: String; Ncolumns: Word=0);
begin
  if not Assigned(lst) then lst:= TStringList.Create;
  lst.Add(fnOpenWorksheet(sheetName));
  while Ncolumns>0 do begin
    lst.Add('<Column ss:AutoFitWidth="1" />');
    inc(Ncolumns, -1);
  end;
end;
//========================================================== закрываем worksheet
procedure AddXmlSheetEnd(lst: TStringList; X: integer=0; Y: integer=0);
var s: String;
begin
  if not Assigned(lst) then Exit;
  if (X=0) and (Y=0) then s:= '' else s:= fnGetWorkSheetOptions(X, Y);
  Lst.Add(fnCloseWorkSheet(s));
end;
//=========================================================== закрываем Workbook
procedure AddXmlBookEnd(lst: TStringList);
begin
  if not Assigned(lst) then Exit;
  Lst.Add(cEX_Workbook_End);
end;
//==============================================================================
procedure SaveXmlListToFile(lst: TStringList; fNameWithoutExt: String);
begin
  if not Assigned(lst) then Exit;
  Lst.SaveToFile(fNameWithoutExt+'.xml');
end;
//==============================================================================
procedure CheckTxtStyle;
begin
  if not Assigned(sStylesArray) then
    sStylesArray:= TXmlCellStylesArray.Create;
  if not Assigned(sTxtStyle) then
    sTxtStyle:= sStylesArray.AddStyle(TXmlReportStyle.Create(''));
//    sTxtStyle:= sStylesArray.AddStyle(TXmlReportStyle.Create('#FFFFFF'));
end;
//==============================================================================
procedure CheckHeadStyle;
begin
  if not Assigned(sStylesArray) then
    sStylesArray:= TXmlCellStylesArray.Create;
  if not Assigned(sHeadStyle) then
    sHeadStyle:= sStylesArray.AddStyle(TXmlReportStyle.Create('',
      'Center', 'Center', [fsBold], '', false, true));
end;
//==============================================================================
procedure CheckBoldStyle;
begin
  if not Assigned(sStylesArray) then
    sStylesArray:= TXmlCellStylesArray.Create;
  if not Assigned(sBoldStyle) then
    sBoldStyle:= sStylesArray.AddStyle(TXmlReportStyle.Create('', '', '', [fsBold]));
end;
//==============================================================================
procedure ClearStyles;
begin
  try
    if Assigned(sBoldStyle) then FreeAndNil(sBoldStyle);
    if Assigned(sHeadStyle) then FreeAndNil(sHeadStyle);
    if Assigned(sTxtStyle) then FreeAndNil(sTxtStyle);
    if Assigned(sStylesArray) then FreeAndNil(sStylesArray);
  except end;  
end;

//******************************************************************************
initialization
begin

end;
finalization
begin
  ClearStyles;
end;
//******************************************************************************
end.
