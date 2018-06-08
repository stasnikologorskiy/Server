unit n_icon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, WinSvc, INIFiles,
  Dialogs, Registry, Forms, ShellAPI, Menus, ImgList, n_free_functions, n_server_common;

const WM_ICONTRAY = WM_USER+1;

type
  TNewIconThread = class(TThread)
  private { Private declarations }
    function GetTerminated: Boolean;
  protected
    procedure Execute; override;
  public  { Public declarations }
    fIconExist: boolean;
    property isTerminated: Boolean read GetTerminated;
    constructor Create(CreateSuspended: Boolean);
    procedure ShowIcon;
    procedure CreatePopupMenu;
    procedure PopupMenuPopup(Sender: TObject);
    procedure PopupMenuItemsClick(Sender: TObject);
  end;

var
  NewIconThread: TNewIconThread; // ����� ���������� �������
  iFileDateIni: Integer;   // ���� � ����� ���������� ���������� ini-�����
  iAppStatus: Integer;     // �������� ��������� �������� �������
  IconID: Integer;
  icoMessage: DWORD;
  TrayIconData: TNotifyIconData;
  PopupMenuIcon: TPopupMenu;

  procedure SetTrayIconData;

implementation
uses v_server_main, v_constants, v_server_common, n_constants, n_CSSservice, n_CSSThreads;
//==============================================================================
constructor TNewIconThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(True);
  Randomize;
  IconID:= Random(High(Word)-1); // id ������
  iAppStatus:= 0;
  iFileDateIni:= 0;
//  CreatePopupMenu; // �������� ���� ������
  Synchronize(CreatePopupMenu); // ������ ������ � ����
  Application.ProcessMessages;

  if not CreateSuspended then Resume;
  sleep(101);
end;
//==============================================================================
function TNewIconThread.GetTerminated: Boolean;
begin
  Result:= Terminated;
end;
//========================================================== ������� ���� ������
procedure TNewIconThread.CreatePopupMenu;
var i,j: integer;
    aCaptions: Tas;
begin
  PopupMenuIcon:= TPopupMenu.Create(Form1);
  PopupMenuIcon.AutoHotkeys:= maManual;
  PopupMenuIcon.Tag:= 0; // ������ ������ ����������
  PopupMenuIcon.AutoPopup:= False;
  PopupMenuIcon.Alignment:= paRight;
  PopupMenuIcon.WindowHandle:= Form1.Handle;
  PopupMenuIcon.OnPopup:= PopupMenuPopup;

  SetLength(aCaptions, 9); // �������� ������� ����
  aCaptions[0]:= '-'; // ����� ���������� - ��� � ��������� �������
  aCaptions[1]:= '-'; // �����������
  aCaptions[2]:= '���������� '+Application.Name; // Items[i].Tag=0
  aCaptions[3]:= '-'; // �����������
  aCaptions[4]:= '�������� ����';               // Items[i].Tag=1
  aCaptions[5]:= '������ ����';                 // Items[i].Tag=2
  aCaptions[6]:= '-'; // �����������
  aCaptions[7]:= 'Suspend';                     // Items[i].Tag=3
  aCaptions[8]:= 'Resume';                      // Items[i].Tag=4

  j:= 0;
  for i:= 0 to Length(aCaptions)-1 do begin
    PopupMenuIcon.Items.Add(TMenuItem.Create(PopupMenuIcon));
    PopupMenuIcon.Items[PopupMenuIcon.Items.Count-1].Caption:= aCaptions[i];
    if (aCaptions[i][1]<>'-') then begin // ���� �� ����������� ��� ����������
      PopupMenuIcon.Items[PopupMenuIcon.Items.Count-1].Tag:= j;
      PopupMenuIcon.Items[PopupMenuIcon.Items.Count-1].OnClick:= PopupMenuItemsClick;
      inc(j);
    end;
  end;
end;
//======================================================= ���������� ���� ������
procedure TNewIconThread.PopupMenuPopup(Sender: TObject);
var i: integer;
begin
  PopupMenuIcon.Items[PopupMenuIcon.Tag].Caption:= // ��� � ��������� �������
    Application.Name+' - '+arCSSServerStatusNames[AppStatus];
  for i:= 0 to PopupMenuIcon.Items.Count-1 do
    case PopupMenuIcon.Items[i].Tag of
      1:  PopupMenuIcon.Items[i].Enabled:= not Form1.Visible;        // �������� ����
      2:  PopupMenuIcon.Items[i].Enabled:= Form1.Visible;            // ������ ����
      3:  PopupMenuIcon.Items[i].Enabled:= AppStatus in [stWork];      // Suspend
      4:  PopupMenuIcon.Items[i].Enabled:= AppStatus in [stSuspended]; // Resume
    end;
  SetForegroundWindow(Form1.Handle);
end;
//=================================================== �������� ����� ���� ������
procedure TNewIconThread.PopupMenuItemsClick(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0:  begin
          ServiceGoOut:= True;                // ������������� ���� - ����������
          prMessageLOGS('������ ����� PopupMenu: ��������� ������', 'system');
          if not IsServiceCSS then Form1.Close;
        end;
    1:  if not Form1.Visible then Form1.Show; // �������� ����
    2:  if Form1.Visible then Form1.Hide;     // ������ ����
    3:  prSafeSuspendAll;                         // Suspend
    4:  begin                                     // Resume
          SetLength(StopList, 0);
          prResumeAll;
        end;
  end;
end;
//======================================= �����/���������/�������� ������ � ����
procedure TNewIconThread.ShowIcon;
var res: boolean;
begin
  if flCSSnew then begin
    if icoMessage=NIM_MODIFY then begin
      SetTrayIconData;
      Shell_NotifyIcon(icoMessage, @TrayIconData); // ������ ������
    end;
  end else begin
    if not fIconExist and ((FindWindow('Shell_TrayWnd', NIL)<1) or (icoMessage=NIM_DELETE)) then begin
      Exit;
    end else begin
      if not (icoMessage=NIM_DELETE) then SetTrayIconData;
      if fIconExist and (icoMessage=NIM_ADD) then icoMessage:= NIM_MODIFY
      else if not fIconExist and (icoMessage=NIM_MODIFY) then icoMessage:= NIM_ADD;
    end;
    res:= Shell_NotifyIcon(icoMessage, @TrayIconData); // ������ ������ � ����
    if res and (icoMessage=NIM_ADD) then fIconExist:= res; // ���� �������� ������ � ���� -
                                                           // ������� ���� ������������� ������
  end;
  iAppStatus:= AppStatus;
end;
//===================================================== ����� ���������� �������
procedure TNewIconThread.Execute;
var i, j: integer;
//--------------------------
function GoExit: Boolean;
begin
  Result:= Terminated or Application.Terminated or (AppStatus=stClosed);
  if not Result and IsServiceCSS then Result:= (not Assigned(ServiceCSS) or ServiceCSS.Terminated);
end;
//--------------------------
begin
  Randomize;
  iAppStatus:= -1;
  fIconExist:= False;     // ���� ������������� ������
  icoMessage:= NIM_ADD;
  Synchronize(ShowIcon); // ������ ������ � ����
//  prMessageLOGS('  Synchronize(ShowIcon), AppStatus= '+IntToStr(AppStatus), 'system', False);
  Application.ProcessMessages;
  repeat
    if GoExit then break;
    if IsServiceCSS and (iFileDateIni<>FileAge(nmIniFileBOB)) then begin
      ServiceCSS.ServiceTestDescription; // ���� ��������� ini-���� - ��������� �������� ������
      iFileDateIni:= FileAge(nmIniFileBOB);
    end;
    for i:= 1 to 10 do begin
      if IsServiceCSS then ServiceCSS.ServiceThread.ProcessRequests(False); // ��������� ������� ��������� �����   ??? �����
      if GoExit then break;
      if iAppStatus<>AppStatus then begin // ���� ��������� ������ ����������
        icoMessage:= NIM_MODIFY;
        Synchronize(ShowIcon); // ������ ������ � ����
//        prMessageLOGS('  Synchronize(ShowIcon), AppStatus= '+IntToStr(AppStatus), 'system', False);
        Application.ProcessMessages;
      end;
      if GoExit then break;
      j:= 61+Random(41);
      sleep(j);
    end;
  until GoExit;
  if fIconExist then begin   // ���� ���� ������ � ����
    icoMessage:= NIM_DELETE;
    Synchronize(ShowIcon);   // ������� ������ � ����
  end;
  Terminate;
end;
//======================================================= �������� ������ � ����
procedure SetTrayIconData;
begin
  with TrayIconData do begin
    cbSize:= SizeOf(TrayIconData);
    Wnd:= Form1.Handle;
    uID:= IconID;
    uFlags:= NIF_MESSAGE or NIF_ICON or NIF_TIP;
    hIcon:= Application.Icon.Handle;
    uCallbackMessage:= WM_ICONTRAY;
    StrCopy(szTip, PChar(Application.Name+#13+arCSSServerStatusNames[AppStatus]));
  end;
end;

end.
