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
  NewIconThread: TNewIconThread; // поток управлени€ иконкой
  iFileDateIni: Integer;   // дата и врем€ последнего считывани€ ini-файла
  iAppStatus: Integer;     // значение последней проверки статуса
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
  IconID:= Random(High(Word)-1); // id иконки
  iAppStatus:= 0;
  iFileDateIni:= 0;
//  CreatePopupMenu; // создание меню иконки
  Synchronize(CreatePopupMenu); // —оздаЄм иконку в трее
  Application.ProcessMessages;

  if not CreateSuspended then Resume;
  sleep(101);
end;
//==============================================================================
function TNewIconThread.GetTerminated: Boolean;
begin
  Result:= Terminated;
end;
//========================================================== создаем меню иконки
procedure TNewIconThread.CreatePopupMenu;
var i,j: integer;
    aCaptions: Tas;
begin
  PopupMenuIcon:= TPopupMenu.Create(Form1);
  PopupMenuIcon.AutoHotkeys:= maManual;
  PopupMenuIcon.Tag:= 0; // индекс пункта информации
  PopupMenuIcon.AutoPopup:= False;
  PopupMenuIcon.Alignment:= paRight;
  PopupMenuIcon.WindowHandle:= Form1.Handle;
  PopupMenuIcon.OnPopup:= PopupMenuPopup;

  SetLength(aCaptions, 9); // названи€ пунктов меню
  aCaptions[0]:= '-'; // пункт информации - им€ и состо€ние сервиса
  aCaptions[1]:= '-'; // разделитель
  aCaptions[2]:= 'ќстановить '+Application.Name; // Items[i].Tag=0
  aCaptions[3]:= '-'; // разделитель
  aCaptions[4]:= 'ѕоказать окно';               // Items[i].Tag=1
  aCaptions[5]:= '—крыть окно';                 // Items[i].Tag=2
  aCaptions[6]:= '-'; // разделитель
  aCaptions[7]:= 'Suspend';                     // Items[i].Tag=3
  aCaptions[8]:= 'Resume';                      // Items[i].Tag=4

  j:= 0;
  for i:= 0 to Length(aCaptions)-1 do begin
    PopupMenuIcon.Items.Add(TMenuItem.Create(PopupMenuIcon));
    PopupMenuIcon.Items[PopupMenuIcon.Items.Count-1].Caption:= aCaptions[i];
    if (aCaptions[i][1]<>'-') then begin // если не разделитель или информаци€
      PopupMenuIcon.Items[PopupMenuIcon.Items.Count-1].Tag:= j;
      PopupMenuIcon.Items[PopupMenuIcon.Items.Count-1].OnClick:= PopupMenuItemsClick;
      inc(j);
    end;
  end;
end;
//======================================================= показываем меню иконки
procedure TNewIconThread.PopupMenuPopup(Sender: TObject);
var i: integer;
begin
  PopupMenuIcon.Items[PopupMenuIcon.Tag].Caption:= // им€ и состо€ние сервиса
    Application.Name+' - '+arCSSServerStatusNames[AppStatus];
  for i:= 0 to PopupMenuIcon.Items.Count-1 do
    case PopupMenuIcon.Items[i].Tag of
      1:  PopupMenuIcon.Items[i].Enabled:= not Form1.Visible;        // ѕоказать окно
      2:  PopupMenuIcon.Items[i].Enabled:= Form1.Visible;            // —крыть окно
      3:  PopupMenuIcon.Items[i].Enabled:= AppStatus in [stWork];      // Suspend
      4:  PopupMenuIcon.Items[i].Enabled:= AppStatus in [stSuspended]; // Resume
    end;
  SetForegroundWindow(Form1.Handle);
end;
//=================================================== выбираем пункт меню иконки
procedure TNewIconThread.PopupMenuItemsClick(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0:  begin
          ServiceGoOut:= True;                // устанавливаем флаг - ќстановить
          prMessageLOGS('¬ыбран пункт PopupMenu: «авершить работу', 'system');
          if not IsServiceCSS then Form1.Close;
        end;
    1:  if not Form1.Visible then Form1.Show; // ѕоказать окно
    2:  if Form1.Visible then Form1.Hide;     // —крыть окно
    3:  prSafeSuspendAll;                         // Suspend
    4:  begin                                     // Resume
          SetLength(StopList, 0);
          prResumeAll;
        end;
  end;
end;
//======================================= показ/изменение/удаление иконки в трее
procedure TNewIconThread.ShowIcon;
var res: boolean;
begin
  if flCSSnew then begin
    if icoMessage=NIM_MODIFY then begin
      SetTrayIconData;
      Shell_NotifyIcon(icoMessage, @TrayIconData); // мен€ем иконку
    end;
  end else begin
    if not fIconExist and ((FindWindow('Shell_TrayWnd', NIL)<1) or (icoMessage=NIM_DELETE)) then begin
      Exit;
    end else begin
      if not (icoMessage=NIM_DELETE) then SetTrayIconData;
      if fIconExist and (icoMessage=NIM_ADD) then icoMessage:= NIM_MODIFY
      else if not fIconExist and (icoMessage=NIM_MODIFY) then icoMessage:= NIM_ADD;
    end;
    res:= Shell_NotifyIcon(icoMessage, @TrayIconData); // мен€ем иконку в трее
    if res and (icoMessage=NIM_ADD) then fIconExist:= res; // если добавили иконку в трей -
                                                           // взводим флаг существовани€ иконки
  end;
  iAppStatus:= AppStatus;
end;
//===================================================== поток управлени€ иконкой
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
  fIconExist:= False;     // флаг существовани€ иконки
  icoMessage:= NIM_ADD;
  Synchronize(ShowIcon); // —оздаЄм иконку в трее
//  prMessageLOGS('  Synchronize(ShowIcon), AppStatus= '+IntToStr(AppStatus), 'system', False);
  Application.ProcessMessages;
  repeat
    if GoExit then break;
    if IsServiceCSS and (iFileDateIni<>FileAge(nmIniFileBOB)) then begin
      ServiceCSS.ServiceTestDescription; // если изменилс€ ini-файл - провер€ем описание службы
      iFileDateIni:= FileAge(nmIniFileBOB);
    end;
    for i:= 1 to 10 do begin
      if IsServiceCSS then ServiceCSS.ServiceThread.ProcessRequests(False); // провер€ем команды менеджера служб   ??? зачем
      if GoExit then break;
      if iAppStatus<>AppStatus then begin // если изменилс€ статус приложени€
        icoMessage:= NIM_MODIFY;
        Synchronize(ShowIcon); // мен€ем иконку в трее
//        prMessageLOGS('  Synchronize(ShowIcon), AppStatus= '+IntToStr(AppStatus), 'system', False);
        Application.ProcessMessages;
      end;
      if GoExit then break;
      j:= 61+Random(41);
      sleep(j);
    end;
  until GoExit;
  if fIconExist then begin   // если есть иконка в трее
    icoMessage:= NIM_DELETE;
    Synchronize(ShowIcon);   // ”бираем иконку в трее
  end;
  Terminate;
end;
//======================================================= свойства иконки в трее
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
