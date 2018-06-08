program sCSSserver;

uses
  SvcMgr,
  WinSvc,
  Forms,
  Windows,
  SysUtils,
  n_constants in '..\Common\n_constants.pas',
  n_Functions in '..\Common\n_Functions.pas',
  v_constants in '..\common\v_constants.pas',
  v_DataTrans in '..\Common\v_DataTrans.pas',
  v_Functions in '..\Common\v_Functions.pas',
  n_CSSservice in 'n_CSSservice.pas' {ServiceCSS: TService},
  n_server_main in 'n_server_main.pas' {Form1},
  n_DataCacheInMemory in 'n_DataCacheInMemory.pas',
  n_LogThreads in 'n_LogThreads.pas',
  n_DataSetsManager in 'n_DataSetsManager.pas',
  n_IBCntsPool in 'n_IBCntsPool.pas',
  n_server_common in 'n_server_common.pas',
  n_DataCacheAddition in 'n_DataCacheAddition.pas',
  n_CSSThreads in 'n_CSSThreads.pas',
  n_DataCacheObjects in 'n_DataCacheObjects.pas',
  n_free_functions in '..\Common\n_free_functions.pas',
  Excel_TLB in '..\Common\Excel_TLB.pas',
  n_TD_functions in 'n_TD_functions.pas',
  t_WebArmProcedures in 't_WebArmProcedures.pas',
  t_ImportChecking in 't_ImportChecking.pas',
  n_xml_functions in '..\Common\n_xml_functions.pas',
  n_OnlinePocedures in 'n_OnlinePocedures.pas',
  n_WebArmProcedures in 'n_WebArmProcedures.pas',
  t_ExcelXmlUse in '..\Common\t_ExcelXmlUse.pas',
  s_OnlineProcedures in 's_OnlineProcedures.pas',
  s_Utils in 's_Utils.pas',
  s_CommandFunc in 's_CommandFunc.pas',
  s_WebArmProcedures in 's_WebArmProcedures.pas',
  s_OnlineCommandFunc in 's_OnlineCommandFunc.pas',
  t_CSSThreads in 't_CSSThreads.pas';

{$R *.RES}
begin
  IsServiceCSS:= not FindCmdLineSwitch('prg',['/','\','-'], True);

  Application.Name:= copy(ExtractFileName(Application.ExeName),
    1,pos('.',ExtractFileName(Application.ExeName))-1);
  prMessageLOG(' ', 'system');  
  prMessageLOG(StringOfChar('+', 50), 'system');

  nmIniFileBOB:= ExtractFilePath(Application.ExeName)+ChangeFileExt(ExtractFileName(Application.ExeName), '.ini');
  if not FileExists(nmIniFileBOB) then nmIniFileBOB:= ExtractFilePath(Application.ExeName)+'server.ini';
  flCSSnew:= GetIniParamInt(nmIniFileBOB, 'Manage', 'CSSnew', 0)=1;

  if IsServiceCSS then begin  // ������
    prMessageLOG('������ ������� '+Application.Name, 'system');
    try
      Installing:= FindCmdLineSwitch('INSTALL',['-','\','/'], True) or
                FindCmdLineSwitch('UNINSTALL',['-','\','/'], True);
      SvcMgr.Application.Initialize;
//prMessageLOGS('�������� �������������', 'startlog', False);
      SvcMgr.Application.CreateForm(TServiceCSS, ServiceCSS);
  //  prMessageLOGS('������� �����', 'startlog', False);
  SvcMgr.Application.Run;
    except
      on E: Exception do prMessageLOG('������ ������ ������� '+E.Message, 'system');
    end;
    prMessageLOG('��������� ������� '+Application.Name, 'system');
  end else begin             // ����������
    prMessageLOG('����� ��������� '+Application.Name, 'system');
    try
      Forms.Application.Initialize;
      Forms.Application.CreateForm(TForm1, Form1);
      Form1.Show;
      Forms.Application.ProcessMessages;
      if fnServerInit then begin // ��������� ����������� � ��������, ADS � ��.
        Forms.Application.Run;
      end;
      if (Form1<>nil) then Form1.Close;
    except
      on E: Exception do prMessageLOG('������ ������ ��������� '+E.Message, 'system');
    end;
    prMessageLOG('���������� ������ ��������� '+Application.Name, 'system');
  end;
  prMessageLOG(StringOfChar('+', 50), 'system');
end.
