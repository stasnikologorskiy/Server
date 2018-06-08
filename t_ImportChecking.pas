unit t_ImportChecking;

interface
uses Classes, SysUtils, DateUtils, SyncObjs, 
     n_free_functions, n_server_common, n_LogThreads, n_DataCacheInMemory, 
     v_DataTrans, v_constants;

type 
  CountProcessRun = record
    All: integer;                           
    Rep: integer;
    Imp: integer; 
    User: integer;
  end;

  TCheckProcess = class (TObject)
   FCheckKind: integer;         //  constOpExport = 3 (�������/�����);     constOpImport = 4; (������) // TImpKind; 
   FCheckEmpl: integer;         // ������������
   FCheckThreadDataID: integer; //
   FCheckTypeName: string;      // ������������ ����: ��������� ������/������ �� ������ 
   FCheckImpType: word;         // ��� �������
   FCheckTimeBegin: TDateTime;  // ����� ������ ��������
   FCheckLastTime: TDateTime;   // ����� ��������� ��������
   FCheckFilterComment: string; // 
   FCheckStop: integer;         // ������� ������ �������� UserID, ������� ������� ������� 
   FCheckPercent: real;      // ������� ����������
   FCheckRun: boolean;       // �����������       //070715
  public
    constructor Create(pKindOp, pCheckEmpl: integer; pCheckImpType: word; pCheckTimeBegin: TDateTime; pCheckFilterComment: string; pCheckThreadDataID: integer; pCheckRun: boolean);
    //destructor Destroy; override;
  end;

  TImpKind = (ikBaseStamp, ikImport); //  ������-������� 

  TImpCheck = class 
    //CheckKind     : TImpKind; // ������� ������-�������
    CheckList: TList;         //������ ���������
    CrSection: TCriticalSection;
    MaxTime: integer;         // ��� ����� � ������� ��� ����������, ���� ������ - �������
    //LastTime: TDateTime;      // ����� ��������� ��������     ? � �������
  public
    //CheckList: TList;
    constructor Create;
    destructor Destroy; override;

    function FindUserProc( pUserID, pThreadDataID: Integer): integer;  //�������� ������� �������� �������� � ������������
    procedure AddProcess(pKindOp, pUserID, pProc: Integer; ThreadData: TThreadData; pComment: string=''){: Integer}; // �������� �������� � ��������
    procedure DelProcess( pUserID, pThreadDataID: Integer); // ������� �������� �� ��������
    function ListUserProcess( pUserIDFrom, pUserIDAbout: Integer; var PList: TStringList): boolean; // ������ ��������� ������������ (����� ������, �������)
    procedure SetCheckStop( pUserIDFrom, pThreadDataID: Integer); // ������������ � ������� �� ������ �������� UserID, �� �������� ������ ��������
    procedure SetProcessPercent( pUserID, pThreadDataID: Integer; pPercent: Real); // ������������ �������� ���������� ��������
    procedure SetComment( pUserID, pThreadDataID: Integer; pComment: string='') ; // ������������ �����������
    function GetImpType (pUserID, pThreadDataID: Integer) : word;
    function GetCheckKind (pUserID, pThreadDataID: Integer) : word;
    function GetCheckComment (pUserID, pThreadDataID: Integer) : String;
    function GetCountProcessRun( pUserID: integer): CountProcessRun;
  end;

  EStopError = class(Exception)
  end;
  
  var ImpCheck: TImpCheck;
      //StampCheck: TImpCheck;

 
  function CreateFilterComment(filter_data: string = ''): string;                // ����� �����������
  procedure prStopProcess( pUserID, pThreadDataID: Integer);
  function GetProcessName(pUserID, pThreadDataID: Integer): string;              //������ ������������ �������� 
  function GetProcessRun(pUserID, pThreadDataID: Integer): boolean;
procedure prStopProcessS(pUserID, pThreadDataID: Integer; var stopped: boolean);  

implementation

uses n_constants;
  
function TImpCheck.GetCheckComment (pUserID, pThreadDataID: Integer) : string;
  var Process: TCheckProcess;
      i: integer;
begin
  Result:= '';
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(ImpCheck.CheckList.Items[i]);
    Result:= Process.FCheckFilterComment;
  end;
end;

function TImpCheck.GetCheckKind (pUserID, pThreadDataID: Integer) : word;
  var Process: TCheckProcess;
      i: integer;
begin
  Result:= 0;
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(ImpCheck.CheckList.Items[i]);
    Result:= Process.FCheckKind;
  end;
end;

function TImpCheck.GetImpType (pUserID, pThreadDataID: Integer) : word;
  var Process: TCheckProcess;
      i: integer;
begin
  Result:= 0;
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(ImpCheck.CheckList.Items[i]);
    Result:= Process.FCheckImpType;
  end;
end;

function GetProcessName(pUserID, pThreadDataID: Integer): string;
  var Process: TCheckProcess;
      i: integer;
begin
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(ImpCheck.CheckList.Items[i]);
    Result:= Process.FCheckTypeName+' '+cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment;
  end;  
end;

function GetProcessRun(pUserID, pThreadDataID: Integer): boolean;
  var Process: TCheckProcess;
      i: integer;
begin
  Result:= false;
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(ImpCheck.CheckList.Items[i]);
    Result:= Process.FCheckRun;
  end;  
end;

function TImpCheck.GetCountProcessRun( pUserID: integer): CountProcessRun;
  var Process: TCheckProcess;
      i: integer;
      countAll, countRep, countImp, countUser: integer;  
begin
  Result.All:= 0;
  Result.Rep:= 0;
  Result.Imp:= 0;
  Result.User:= 0;
  
  for i:= 0 to CheckList.Count-1 do begin
    Process:= TCheckProcess(CheckList.Items[i]);
    if Process.FCheckRun then begin
      inc(Result.All);
      if Process.FCheckImpType=constOpExport then inc(Result.Rep);  
      if Process.FCheckImpType=constOpImport then inc(Result.Imp);  
      if Process.FCheckEmpl=pUserID then inc(Result.User);
    end;
  end;
 
end;

procedure TImpCheck.SetProcessPercent( pUserID, pThreadDataID: Integer; pPercent: Real);
  var Process: TCheckProcess;
      i: integer;
begin
  i:= FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(CheckList.Items[i]);
//while not Process.FCheckRun do sleep(100);
    
    if Process.FCheckPercent+ pPercent<= 100 then
    Process.FCheckPercent:= Process.FCheckPercent+ pPercent;
  end;
end;

procedure prStopProcess(pUserID, pThreadDataID: Integer);
const nmProc= 'prStopProcess';
  var i : integer;
      lstBodyMail: TStringList;
      Subj, ss: string;
      Process: TCheckProcess;
      
begin
  //lstBodyMail:= TStringList.Create;
  Subj:= '��������� ���������� �������';
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if (i> -1) then begin
    lstBodyMail:= TStringList.Create;
    try  
      Process:= TCheckProcess(ImpCheck.CheckList[i]);
      lstBodyMail.Add('���������� �������: '+Process.FCheckTypeName+' '+cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment);    
      if (Process.FCheckStop>0) then begin
        if Process.FCheckStop<> pUserID then begin
          lstBodyMail.Add('���� ����������� �� ���������� '+ cache.arEmplInfo[Process.FCheckStop].EmplShortName);
          ss:= n_SysMailSend(Cache.arEmplInfo[pUserID].Mail, Subj, lstBodyMail);
          if ss<>'' then 
            prMessageLOGS(nmProc+' ������ �������� ����� �� email '+Cache.arEmplInfo[pUserID].Mail+': '+ss,'Error' , true);
        end;
        raise EStopError.Create('������� '+Process.FCheckTypeName+' "'+cache.GetImpTypeName(Process.FCheckImpType)+'" '+ Process.FCheckFilterComment+' ������� �� ���������� ������������ '+ cache.arEmplInfo[Process.FCheckStop].EmplShortName);
      end 
      else                                                                               
        if AppStatus in [stSuspending, stSuspended, stExiting] then  begin
          if AppStatus in [stSuspending, stSuspended] then 
            while AppStatus in [stSuspending, stSuspended] 
              do sleep(100) 
          else begin
          lstBodyMail.Add('���� ����������� ��-�� ��������� ������� ');
          ss:= n_SysMailSend(Cache.arEmplInfo[pUserID].Mail, Subj, lstBodyMail);   
          if ss<>'' then 
            prMessageLOGS(nmProc+' ������ �������� ����� �� email '+Cache.arEmplInfo[pUserID].Mail+': '+ss,'Error' , true);   
          raise EStopError.Create('������� '+Process.FCheckTypeName+' '+cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment+' ������� ��-�� ��������� �������'); 
          end;
        end; 
    finally
      prFree(lstBodyMail);
      //lstBodyMail.Free; 
i:= ImpCheck.CheckList.Count;      
    end;      
  end
  else 
    raise EStopError.Create('������� '+Process.FCheckTypeName+' '+cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment+' ������� ��-�� ��������� �������'); 
 

end;

procedure prStopProcessS(pUserID, pThreadDataID: Integer; var stopped: boolean);
const nmProc= 'prStopProcessS';
  var i : integer;
      lstBodyMail: TStringList;
      Subj, ss: string;
      Process: TCheckProcess;
      
begin
  //lstBodyMail:= TStringList.Create;
stopped:= false;
  Subj:= '��������� ���������� �������';
  i:= ImpCheck.FindUserProc( pUserID, pThreadDataID);
  if (i> -1) then begin
    lstBodyMail:= TStringList.Create;
    try  
    Process:= TCheckProcess(ImpCheck.CheckList[i]);
    lstBodyMail.Add('���������� �������: '+Process.FCheckTypeName+' '+cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment);    
    if (Process.FCheckStop>0) then begin
stopped:= true;     
      if Process.FCheckStop<> pUserID then begin
        lstBodyMail.Add('���� ����������� �� ���������� '+ cache.arEmplInfo[Process.FCheckStop].EmplShortName);
        ss:= n_SysMailSend(Cache.arEmplInfo[pUserID].Mail, Subj, lstBodyMail);
        if ss<>'' then 
          prMessageLOGS(nmProc+' ������ �������� ����� �� email '+Cache.arEmplInfo[pUserID].Mail+': '+ss,'Error' , true);
      end;
      raise EBOBError.Create('������� '+Process.FCheckTypeName+' "'+cache.GetImpTypeName(Process.FCheckImpType)+'" '+ Process.FCheckFilterComment+' ������� �� ���������� ������������ '+ cache.arEmplInfo[Process.FCheckStop].EmplShortName);
    end 
    else
      if AppStatus in [stSuspending, stSuspended, stExiting] then  begin
        lstBodyMail.Add('���� ����������� ��-�� ��������� ������� ');
        ss:= n_SysMailSend(Cache.arEmplInfo[pUserID].Mail, Subj, lstBodyMail); 
        if ss<>'' then 
          prMessageLOGS(nmProc+' ������ �������� ����� �� email '+Cache.arEmplInfo[pUserID].Mail+': '+ss,'Error' , true);     
        raise EBOBError.Create('������� '+Process.FCheckTypeName+' '+cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment+' ������� ��-�� ��������� �������'); 
      end; 
    finally
      prFree(lstBodyMail);
      //lstBodyMail.Free; 
    end;      
  end
  else stopped:= true;

end;

procedure TImpCheck.SetComment(pUserID, pThreadDataID: Integer; pComment: string='');
  var Process: TCheckProcess;
      i: integer;
begin
  i:= FindUserProc( pUserID, pThreadDataID);
  if i > -1 then begin
    Process:= TCheckProcess(CheckList.Items[i]);
    Process.FCheckFilterComment:= pComment;
  end;
end;

function TImpCheck.ListUserProcess( pUserIDFrom, pUserIDAbout: Integer; var PList: TStringList): boolean;
var i: integer;
    Process: TCheckProcess;
    ss: string;
begin
  ss:='';
  Result:= False;
  if (pUserIDAbout = pUserIDFrom) then Result:= True
  else begin
    Result:=cache.arEmplInfo[pUserIDFrom].UserRoleExists(rolManageUsers);
    {for i:= 0 to length(cache.arEmplInfo)-1 do begin
      if (cache.arEmplInfo[i].EmplID= pUserIDFrom) and (cache.arEmplInfo[i].UserRoleExists(rolManageUsers)) then begin
        Result:= True;
        break;
      end;
    end;}
  end; 
 
  if Result= True then begin
    for i:= 0 to CheckList.Count-1 do begin
      Process:= TCheckProcess(CheckList.Items[i]); 
      if pUserIDAbout = -1 then begin 
        ss:= DateTimeToStr(Process.FCheckTimeBegin); //PList.AddObject(DateTimeToStr(Process.CheckTimeBegin),Process)  
        ss:= ss+ ' '+Process.FCheckTypeName+' '+cache.arEmplInfo[Process.FCheckEmpl].Name +' '+ cache.arEmplInfo[Process.FCheckEmpl].Surname;
        ss:= ss  +' ' +cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment;
      end                      
      else if (Process.FCheckEmpl= pUserIDAbout) then begin
             ss:= DateTimeToStr(Process.FCheckTimeBegin)+' ';
             ss:= ss  +' '+Process.FCheckTypeName+' ' +cache.GetImpTypeName(Process.FCheckImpType)+' '+ Process.FCheckFilterComment;
             try
               prStopProcess(Process.FCheckEmpl, Process.FCheckThreadDataID);
             except
               on E: Exception do begin
                ImpCheck.DelProcess(Process.FCheckEmpl, Process.FCheckThreadDataID);
                ss:='';
               end;
             end;
           end;
      if ss<>'' then begin 
        PList.AddObject(ss,Process); 
        Process.FCheckLastTime:= Now;
      end;  
      ss:= '';    
  {ss:= DateTimeToStr(IncMinute(Process.CheckTimeBegin,-3)); //PList.AddObject(DateTimeToStr(Process.CheckTimeBegin),Process)  
  ss:= ss+ ' ' +cache.arEmplInfo[Process.CheckEmpl].Name +' '+ cache.arEmplInfo[Process.CheckEmpl].Surname;
  if CheckKind=ikBaseStamp then ss:= ss  +' �������� ��������� ������.'
  else ss:= ss  +' �������� ������� �� ������.';
  ss:= ss  +' ' +cache.GetImpTypeName(Process.CheckImpType)+' '+ Process.CheckFilterComment;   
  if ss<>'' then PList.AddObject(ss,Process);                                               
  //ss:=DateTimeToStr(IncMinute(Process.CheckLastTime, MaxTime));                     
        ss:= PList.CommaText;
        ss:= ''; }
    end;
  end;  
  PList.Sort; 
end;

function CreateFilterComment(filter_data: string = ''): string;
  var ss: integer;
      FilterData: TStringList;
begin
  Result:= '';
  FilterData:= TStringList.Create;
  FilterData.Text:= filter_data;
  if {filter_data}FilterData.Text = '' then begin
     Result:= ''; 
     exit;
  end;  
  if pos('dop_gbbrand',FilterData.Text{filter_data})>0 then begin  
    ss:= StrToIntDef(FilterData.Values['dop_gbbrand'],-1);
    if ss>-1 then Result:= '����� '+TBrandItem(Cache.WareBrands[ss]).Name;
    exit;
  end;    
  if pos('dop_manuflistauto',FilterData.Text{filter_data})>0 then begin  
    ss:= StrToIntDef(FilterData.Values['dop_manuflistauto'],-1);
    if ss>-1 then Result:= '������������� ���� '+Cache.FDCA.Manufacturers[ss].Name;
    exit;
  end; 
  prFree(FilterData);
  //FilterData.Free;       
end;

procedure TImpCheck.AddProcess(pKindOp,pUserID, pProc: Integer; ThreadData: TThreadData; pComment: string='');
  var Process: TCheckProcess;  
      i, iProcess: integer;
      pRun: boolean;
      CountRun: CountProcessRun;
begin
  iProcess:= -1;
  for i:= 0 to CheckList.Count-1 do begin
  Process:= TCheckProcess(CheckList.Items[i]);                              
    if (Process.FCheckEmpl = pUserID) {20.03.14} and (Process.FCheckKind = pKindOp) and (Process.FCheckImpType = pProc) then begin
      iProcess:= i;
      break;
    end;
  end;
  //i:= FindUserProc( pUserID, ThreadData.ID );
  if iProcess < 0 then begin 
    try
    CrSection.Enter;
//    if CheckList.Count>0 then pRun:= false 
//    else 
      
    CountRun:= ImpCheck.GetCountProcessRun(pUserID);
    if (CountRun.All<Cache.GetConstItem(pcStartImportLimit).IntValue )
    and (CountRun.User<Cache.GetConstItem(pcStartImportLimit).IntValue)
    and (((CountRun.Rep<Cache.GetConstItem(pcStartImportLimit).IntValue) and (pKindOp=constOpExport))
       or ((CountRun.Imp<Cache.GetConstItem(pcStartImportLimit).IntValue) and (pKindOp=constOpImport))) 
    then pRun:= true
    else pRun:= false;
    Process:= TCheckProcess.Create(pKindOp, pUserID, pProc,Now, CreateFilterComment(pComment),ThreadData.ID, pRun);
    CheckList.Add(Process);
    ThreadData.pProcess:= Pointer(Process);
    finally;
      CrSection.Leave;
    end;
  end
  else begin
    Process:= TCheckProcess(ImpCheck.CheckList[i]);
    raise EBOBError.Create({200314} Process.FCheckTypeName+' '+ cache.GetImpTypeName(pProc)+#13#10+
      CreateFilterComment(pComment)+'������� �������/�������� �� ��� ����������. ��������� ����������!'); //vv
  end;
end;

function TImpCheck.FindUserProc(pUserID, pThreadDataID: Integer): integer;
{ Result
  -1: �� ������
   i: ������(������)}
  var Process: TCheckProcess;   
begin
  try
    for Result:= 0 to CheckList.Count-1 do begin
      Process:= TCheckProcess(CheckList.Items[Result]);
      if (Process.FCheckThreadDataID = pThreadDataID) {and (Process.FCheckEmpl = pUserID)} then begin
        exit;
      end;
    end;
  except
    on E: Exception do begin
//    Result:= -1;
    prMessageLOGS('������ �������� ������� �������� � �����������. '+E.Message ,'Import', false);
    end;
  end;  
  Result:= -1; 
end;

procedure TImpCheck.DelProcess(pUserID, pThreadDataID: Integer);
  var i, j: integer; 
      Proc: TCheckProcess; 
      pRun: boolean;
      CountRun: CountProcessRun;
begin
    i:= FindUserProc( pUserID, pThreadDataID);
    if i > -1 then begin
      try
        CrSection.Enter;
        Proc:= TCheckProcess(CheckList.Items[i]);
        pRun:= Proc.FCheckRun;
        self.CheckList.Delete(i);
        prFree(Proc);
        if pRun and (CheckList.Count>0) then                   //070715
          for j:=0 to CheckList.Count-1 do begin
            Proc:= TCheckProcess(CheckList.Items[j]);
            if Proc<>nil then begin
              CountRun:= ImpCheck.GetCountProcessRun(Proc.FCheckEmpl);
              if (CountRun.All<Cache.GetConstItem(pcStartImportLimit).IntValue )
              and (CountRun.User<Cache.GetConstItem(pcStartImportLimit).IntValue)
              and (((CountRun.Rep<Cache.GetConstItem(pcStartImportLimit).IntValue) and (Proc.FCheckKind=constOpExport))
                 or ((CountRun.Imp<Cache.GetConstItem(pcStartImportLimit).IntValue) and (Proc.FCheckKind=constOpImport))) 
              then begin 
                Proc.FCheckRun:= true;
                break;
              end;
            end;
          end;

        //TCheckProcess(CheckList.Items[i]).Free;
         //Remove(Process);
        //Process.Destroy;
      finally  
       CrSection.Leave; 
      end;
    {end
    else begin
      raise Exception.Create('������� ��� ��������.'); //vv}   
    end;  
end;

{ TImpCheck }
constructor TImpCheck.Create;
begin
  CheckList:= TList.Create;
  CrSection := TCriticalSection.Create;
  self.MaxTime:= 15;
end;

destructor TImpCheck.Destroy;
begin
  prFree(CheckList);
  prFree(CrSection);
  //CheckList.Free;
  //CrSection.Free;
  inherited;
end;

procedure TImpCheck.SetCheckStop({pUserID,} pUserIDFrom, pThreadDataID: Integer);
var i: integer;  
    Process: TCheckProcess;
//    Result: boolean;
begin
  {if pUserID = pUserIDFrom then Result:= True
  else begin
    for i:= 0 to length(cache.arEmplInfo)-1 do begin
      if (cache.arEmplInfo[i].EmplID= pUserIDFrom) and (cache.arEmplInfo[i].UserRoleExists(rolManageUsers)) then begin
        Result:= True;
        break;
      end;
    end;
  end; 
  if Result = True then begin }
    i:= FindUserProc(pUserIDFrom, pThreadDataID);
    if i > -1 then begin
      Process:= TCheckProcess(CheckList.Items[i]);
      Process.FCheckStop:= pUserIDFrom;
    end;
  {end;}
end;


{ TCheckProcess }
constructor TCheckProcess.Create(pKindOp, pCheckEmpl: integer; pCheckImpType: word;
  pCheckTimeBegin: TDateTime; pCheckFilterComment: string; pCheckThreadDataID: integer; pCheckRun: boolean);
begin
  FCheckKind:= pKindOp;
  FCheckEmpl:= pCheckEmpl;
  FCheckThreadDataID:= pCheckThreadDataID;
  if pKindOp= constOpExport then FCheckTypeName:= '��������� ������.';
  if pKindOp= constOpImport then FCheckTypeName:= '������ �� ������.';
  FCheckImpType:= pCheckImpType;
  FCheckTimeBegin:= pCheckTimeBegin;
  FCheckLastTime:= pCheckTimeBegin;
  FCheckFilterComment:= pCheckFilterComment;
  FCheckStop:= 0;
  FCheckPercent:= 1;
  FCheckRun:= pCheckRun;     //070715
end;


end.


 