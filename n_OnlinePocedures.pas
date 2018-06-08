unit n_OnlinePocedures; // ��������� ��� Web

interface
uses Windows, Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
     DB, IBDatabase, IBSQL, Forms, n_free_functions, v_constants, v_Functions, v_DataTrans,
     n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common;

procedure prAutenticateOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);

procedure prCreateNewOrderCommonOrd(UserId, FirmID: integer; var NewOrderID, contID: integer;
          var ErrorMessage: string; qID: integer=-1; OrdIBS: TIBSQL=nil; currID: Integer=0);
procedure prGetOptionsOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSetOrderDefaultOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prChangePasswordOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebSetMainUserOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebCreateUserOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebResetPasswordOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCheckLoginOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetRegisterTableOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // ������ �������� ��� ����� �����������
procedure prSaveRegOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������ ������ �� ����������� � ������� ���
procedure prGetRegisterUberTowns(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ ������� ��� ����� ����������� UBER
procedure prSaveRegOrderUber(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������ ������ �� ����������� UBER � ������� ���
procedure prCreateNewOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetOrderListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // ������ �������
procedure prShowOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowACOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prDelLineFromOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prChangeQtyInOrderLineOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prRefreshPricesOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prRefreshPricesInFormingOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetAccountListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // ������ ������ �������
procedure prCreateOrderByMarkedOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prJoinMarkedOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowGBAccountOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prDeleteOrderByMarkOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSetReservValueOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
//procedure prSetOrderPayTypeOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAddLinesToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ � �����
procedure prAddLineFromSearchResToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ����� � ����� ��������������� �� ����������� ������
 function fnRefreshPriceInOrderOrd(var SResult: string; OrderCode: string; ThreadData: TThreadData=nil): string; // ��������� ���� � ������

 function fnRecaclQtyByDivisible(WareID: integer; var WareQty: double): string; // ���������� ���-�� ������ � ������ � ������������ � ����������
 function fnRecaclQtyByDivisibleEx(WareID: integer; WareQty: double): string;   // ��������� ������������ ���-�� ������ � ����������
procedure prChangeVisibilityOfStorage(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ��������� ������ �������
procedure prClientsStoreMove(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ����������� ����� � ������ ��������� ������� ����/����

procedure prChangeClientLastContract(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // �������� ��������� �������� �������/�������� ������
procedure prChangeOrderContract(FirmId, ContID, OrderID: integer;ThreadData: TThreadData); // �������� �������� ������ � ����������� ����

 function fnGetStoragesArray_2col(Contract: TContract; ReservedOnly: boolean=false; // ������ ��������� - 1/2/3 �������
                                  DefaultOnly: boolean=false): TasD;
//procedure prSetCliContMargins(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // ��������� �������

//------------------------------------------------------------ vc
procedure prGetAllUsersInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetWaresFromAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ ������� �������
procedure prShowGBOutInvoice(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowGBBack(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetUnpayedDocs(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������ ������������ ���-���
procedure prGetCheck(Stream: TBoBMemoryStream; ThreadData: TThreadData);            // ������
procedure prSendMessage2Manager(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ��������� ��������� ������
procedure prGetActions(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // ������ ���� �� ������ � ��
procedure prClickOnNewsCounting(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ����� �� ��������/������
procedure prSaveOption(Stream: TBoBMemoryStream; ThreadData: TThreadData);          //
procedure prGetQtyByAnalogsAndStoragesOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData); //������ ������ � ��������� �� ���a��� � ����������� ���-�� �� ������ � ��������� � ������������ �������������� ���������
procedure prGetQtyByAnalogsAndStorages_new(Stream: TBoBMemoryStream; ThreadData: TThreadData); //������ ������ � ��������� �� ���a��� � ����������� ���-�� �� ������ � ��������� � ������������ �������������� ���������
procedure prSendVINOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);         //
procedure prDownloadPrice(Stream: TBoBMemoryStream; ThreadData: TThreadData);        //
procedure prShowNotificationOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);  //
procedure prConfirmNotification(Stream: TBoBMemoryStream; ThreadData: TThreadData);  //
procedure prContractList(Stream: TBoBMemoryStream; ThreadData: TThreadData);         //
procedure prContractList_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������ ���������� �/� �� �������� (Web)
procedure prChangeContractAccess(Stream: TBoBMemoryStream; ThreadData: TThreadData); //
procedure prSendOrderForChangeData(kind: Integer; Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ �� ��������� ������ (Web)
procedure prRemindPass(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // ����������� ������
procedure prGetContracts(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetMainStoreLocation(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetBonusWares(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ �������� �������
//------------------------------------------------------------ vc

procedure prGetOrderHeaderParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // �������� ���������� ��������� ������
procedure prEditOrderHeaderParams(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������������� ��������� ������
procedure prShowBonusFormingOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ��������� ��������������� ������
procedure prEditOrderSelfComment(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // �������������� ����������� "��� ����"
procedure prCheckOrderWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // �������� ������� �������� ������� �� ������
procedure prGetCheckBonus(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // unit-��������
procedure prShowGBManual(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // �������� �������������
procedure prGetFormingOrdersList(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // �������� ������ �������������� �������
procedure prGetWareActions(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // ������ ����� ��� "����������"
 function CheckOrdWaresExAndOverLimit(FirmID, UserID, ContID, OrderID, CurrID: Integer; // �������� ������� ������� � ������ � ������� ������ ������� �/�
                                    flResLimit, flExWares, flSingleLine: Boolean; ibs: TIBSQL=nil): String;
 function GetOrderOverSummMess(currID: integer; OverSumm, OrderSum, LastLineSum: Double): String; // �������� ���������� ������ �� ������ � ������ ������

procedure prGetBankAccountsList(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // ������ ������ �� ������
procedure prNewBankAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // ����� ���� �� ������
procedure prSaveBankAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // �������� ���� �� ������
procedure prGetBankAccountFile(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // �������� ���� ����� �� ������
procedure prSendSMSfromBankAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ��������� SMS �� ����� �� ������
procedure prGetReclamationList(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������ ����������
procedure prGetMeetPersonsList(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // �������� ������ ����������� �/�

procedure prOrderImport(Stream: TBoBMemoryStream; ThreadData: TThreadData);            // ������ ������
procedure prGetDestPointParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������ ���������� ��� ���������� ��������� ������� (Web)

 function prSendMessAboutCreateAccount(Ord: ROrderOpts; IDq: Integer; ErrStr: string): string; overload;
 function prSendMessAboutCreateAccount(ORDRCODE, DCACCODE, FirmID, // ��������� ������ � ������������ ����� � Grossbee
          contID, storID, crnc, IDq: Integer; SumDoc, SumLines: Double;
          DCACNUMBER, ORDRNUM, sDate, ErrStr: string; accLines: TStringList): string; overload;


implementation
uses n_CSSservice, n_CSSThreads, n_DataCacheObjects, n_DataCacheAddition, n_IBCntsPool,
  n_xml_functions, n_Functions;

//*******************************************************************************
procedure prCreateNewOrderCommonOrd(UserId, FirmID: integer; var NewOrderID, contID: integer;
          var ErrorMessage: string; qID: integer=-1; OrdIBS: TIBSQL=nil; currID: Integer=0);
const nmProc = 'prCreateNewOrderCommonOrd'; // ��� ���������/�������/������
var acctype, delivery, dest: integer;
    FirmCode, s: string;
    OrdIBD: TIBDatabase;
    flCreate: boolean;
    Contract: TContract;
    Client: TClientInfo;
begin
  OrdIBD:= nil;
  NewOrderID:= 0;
  ErrorMessage:= '';
  flCreate:= False;
  FirmCode:= IntToStr(FirmID);
  if qID<0 then qID:= FirmID;
  try
    flCreate:= not Assigned(OrdIBS);
    if flCreate then begin
      OrdIBD:= cntsORD.GetFreeCnt;
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, qID, tpWrite);
    end else fnSetTransParams(OrdIBS.Transaction, tpWrite);

    Cache.TestClients(UserID, true);
    if not Cache.ClientExist(UserId) then raise Exception.Create(MessText(mtkNotClientExist));
    Client:= Cache.arClientInfo[UserId];

    if (contID<1) then contID:= Client.LastContract;
    Contract:= Cache.arFirmInfo[FirmID].GetContract(contID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');

    acctype:= Contract.PayType;
    if Client.CheckIsFinalClient then begin
      delivery:= cDelivSelfGet;
      dest    := 0;
    end else with Client.GetCliContDefs(contID) do begin
      delivery:= ID1;
      dest    := ID2;

if flNotReserve then
      if (delivery=cDelivReserve) then delivery:= cDelivTimeTable;
    end;

    if (currID<>Cache.BonusCrncCode) then
      if (Contract.DutyCurrency>0) then currID:= Contract.DutyCurrency
      else currID:= fnIfInt((acctype=1) or Client.CheckIsFinalClient, cUAHCurrency, cDefCurrency);

    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select rOrderCode from CreateNewOrderHeaderC('+
      IntToStr(contID)+', "",'+IntToStr(acctype)+', '+IntToStr(Contract.Filial)+', '+
      Contract.MainStoreStr+','+IntToStr(cosByWeb)+', '+IntToStr(FirmID)+', '+
      IntToStr(delivery)+', '+IntToStr(currID)+', "", NULL, "", '+
      IntToStr(orstForming)+', "", NULL, '+IntToStr(UserID)+')';

    s:= RepeatExecuteIBSQL(OrdIBS, 'rOrderCode', NewOrderID);
    if s<>'' then raise Exception.Create('Not save order header: '+s);
    if NewOrderID<1  then raise Exception.Create('rOrderCode < 1');

    if (delivery=cDelivTimeTable) and (dest>0) then begin
      with OrdIBS.Transaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'update ORDERSREESTR set ORDRDESTPOINT='+IntToStr(dest)+
        ' where ORDRCODE='+IntToStr(NewOrderID);
      s:= RepeatExecuteIBSQL(OrdIBS);
      if s<>'' then prMessageLOGS(nmProc+'_dest: '+s, fLogCache);
    end;
  except
    on E: Exception do begin
      if Assigned(OrdIBS) then with OrdIBS.Transaction do if InTransaction then Rollback;
      NewOrderID:= 0;
      ErrorMessage:= '������ � '+nmProc+': '+E.Message
    end;
  end;
  if flcreate then begin
    prFreeIBSQL(OrdIBS);
    cntsORD.SetFreeCnt(OrdIBD);
  end;
end;
//*******************************************************************************
procedure prAutenticateOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAutenticateOrd'; // ��� ���������/�������
type RDirectParams = record
  Name: String;          // �������� �����������
  LevelCount: Integer;   // ���-�� �������
  ProcToNext: Integer;   // ������� ������� �����, �������� �� ������� �� ������, �� �������� �/� �� ����������
  FirmSales: Integer;    // ������. ������� ������ �/�
  FirmModel: TDiscModel; // ������� ������ �/�
  NextModel: TDiscModel; // ������, �� �������� �/� �� ���������� �� ������� �������� ������
end;
var sid, UserLogin, UserPsw, IP, Ident, username, usermail,
      FirmCode, UserCode, ss, sParam: string;
    pUserId, pFirmID, i, iBlock, contID, contBonusOrd, j, command: integer;
    FullData, pResetPW, flEnterByLogin, flBaseAutorize, fl: boolean;
    ibS: TIBSQL;
    ibDb: TIBDatabase;
    Client: TClientInfo;
    firma: TFirmInfo;
    Notifics: TIntegerList;
    Contract: TContract;
    DirectParams: array of RDirectParams;
    dm: TDiscModel;
    tt: TTWoCodes;
    LocStart: TDateTime;
    prof: TCredProfile;
begin
  Stream.Position:= 0;
  ibS:= nil;
  Client:= nil;
  Notifics:= nil;
  pFirmID:= 0;
  pUserID:= 0;
  iBlock:= 0;
  pResetPW:= false;
  contID:= 0;
  flBaseAutorize:= False;
  UserCode:= '';
  sParam:= '';
  LocStart:= now();
  try

if flLogTestClients then
    prMessageLOGS(nmProc+'-------------------- start', fLogDebug, false); // ����� � log

    UserLogin:= trim(Stream.ReadStr);
    UserPsw:= trim(Stream.ReadStr);
    sid:= trim(Stream.ReadStr);
    IP:= trim(Stream.ReadStr);
    Ident:= trim(Stream.ReadStr);
    FullData:= boolean(Stream.ReadByte);
    contID:= Stream.ReadInt;   // ��� ����������

    if FullData then command:= csWebAutentication
    else command:= csBackJobAutentication;

          // ����������� � ib_css - ������ �� �������, �������������� � ���� !!!
    sParam:= 'Login='+UserLogin+#13#10'Password='+UserPsw+#13#10'sid='+sid+
             #13#10'IP='+IP+#13#10'Browser='+Ident+#13#10'ContID='+IntToStr(contID);
    try
  //---------------------------------------------------- ��������� ��������� �����
      flEnterByLogin:= (UserLogin<>'') and (UserPsw<>''); // ������� ����� �� ������
      if flEnterByLogin then begin
        i:= Cache.CliLoginLength;
        if (Length(UserLogin)>i) then
          raise EBOBError.Create('������������ ����� - '+UserLogin+'. '+MessText(mtkNotValidLogin, IntToStr(i)));
        i:= Cache.CliPasswLength;
        if (Length(UserPsw)>i) then
          raise EBOBError.Create('������������ ������. '+MessText(mtkNotValidPassw, IntToStr(i)));
  //      if not fnCheckOrderWebLogin(UserLogin) then
  //        raise EBOBError.Create(MessText(mtkNotValidLogin));
  //      if not fnCheckOrderWebPassword(UserPsw) then
  //        raise EBOBError.Create(MessText(mtkNotValidPassw));
      end else if (sid='') then raise EBOBError.Create(MessText(mtkNotParams))
      else if (Length(sid)>Cache.CliSessionLength) then raise EBOBError.Create(
        '������������ ������������� ������. ������������� � �������������� ������ � ������.');

  //---------------------------------------------- �������� �������������� �� ����
      if flEnterByLogin then with Cache.arClientInfo.WorkLogins do begin
        i:= IndexOf(UserLogin);
        if (i>-1) then pUserID:= Integer(Objects[i]);
        flBaseAutorize:= True; // ����������� �� ����
      end else begin
        i:= pos('|', sid);
        if (i>1) then UserCode:= copy(sid, 1, i-1);
        if (UserCode<>'') then begin
          pUserID:= StrToIntDef(UserCode, 0);
          if (pUserID<1) then UserCode:= '';
        end;
      end;
      if (pUserID>0) then
        if not Cache.ClientExist(pUserID) then pUserID:= 0
        else begin

if flLogTestClients then begin
    prMessageLOGS(nmProc+': TestClients start ----------', fLogDebug, false); // ����� � log
    LocStart:= now();
end;
          Cache.TestClients(pUserID, true); // �������� ������ ������� � ����

if flLogTestClients then begin
    prMessageLOGS(nmProc+': TestClients - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
          Client:= Cache.arClientInfo[pUserID];
        end;
      if Assigned(Client) then begin // ���� ����� ������� - ��������� ������������� ���������� �� ����
        if not flEnterByLogin then flBaseAutorize:= flBaseAutorize or (sid<>Client.Sid);
        flBaseAutorize:= flBaseAutorize or
          ((Now>IncMinute(Client.LastBaseAutorize, Cache.ClientActualInterval))
          and cntsGRB.NotManyLockConnects and cntsORD.NotManyLockConnects);
      end;
      flBaseAutorize:= flBaseAutorize or not Assigned(Client);

      if flBaseAutorize then begin

if flLogTestClients then begin
    prMessageLOGS(nmProc+': BaseAutorize start ----------', fLogDebug, false); // ����� � log
    LocStart:= now();
end;

  //---------------------------------------------------------- ����������� �� ����
        ibDb:= cntsORD.GetFreeCnt;
        try
          ibS:= fnCreateNewIBSQL(ibDb, 'ibS_'+nmProc, ThreadData.ID, tpWrite, true);
          ibS.SQL.Text:= 'Select * from AutenticateUserCSS(:LOGIN, :PASSW, :Ses, '+
            Cache.GetConstItem(pcClientTimeOutWeb).StrValue+', '+IntToStr(cosByWeb)+')';
          ibS.ParamByName('LOGIN').AsString:= UserLogin;
          ibS.ParamByName('PASSW').AsString:= UserPsw;
          ibS.ParamByName('Ses').AsString:= sid;
          ibS.Prepare;
          for i:= 1 to RepeatCount do try
            with ibS.Transaction do if not InTransaction then StartTransaction;
            ibS.ExecQuery;
            if (ibS.Bof and ibS.Eof) then
              raise Exception.Create('AutenticateUserCSS - Empty');
            if ibS.FieldByName('rErrText').AsString<>'' then
              raise EBOBError.Create(ibS.FieldByName('rErrText').AsString);
            pUserID  := ibS.FieldByName('rWOCLCODE').AsInteger;
            UserCode := ibS.FieldByName('rWOCLCODE').AsString;
            UserLogin:= ibS.FieldByName('rWOCLLOGIN').AsString;
            UserPsw  := ibS.FieldByName('rWOCLPASSWORD').AsString;
            pResetPW := GetBoolGB(ibs, 'rWOCLRESETPASWORD');
            sid      := ibS.FieldByName('rWOCLSESSIONID').AsString;
            iBlock   := ibS.FieldByName('rBlock').AsInteger;
            ibS.Transaction.Commit;
            ibS.Close;
            break;
          except
            on E: EBOBError do raise EBOBError.Create(E.Message);
            on E: Exception do begin
              if ibS.Transaction.InTransaction then ibS.Transaction.RollbackRetaining;
              ibS.Close;
              if (Pos('lock', E.Message)>0) or ((Pos('Empty', E.Message)>0)) then begin
                if (i<RepeatCount) then Sleep(RepeatSaveInterval) // ���� �������
                else raise Exception.Create('try '+IntToStr(RepeatCount)+': '+CutLockMess(E.Message));
              end else raise Exception.Create(E.Message);
            end;
          end;
        finally
          prFreeIBSQL(ibS);
          cntsOrd.SetFreeCnt(ibDb);
        end;
        if not Assigned(Client) then begin
          Cache.TestClients(pUserID, true);
          if not Cache.ClientExist(pUserID) then
            raise EBOBError.Create(MessText(mtkNotClientExist, UserCode));
          Client:= Cache.arClientInfo[pUserID];
        end;
        Client.CS_client.Enter;
        try
          Client.LastBaseAutorize:= Now;
          Client.Login:= UserLogin;
          Client.Password:= UserPsw;
          Client.resetPW:= pResetPW;
          Client.BlockKind:= iBlock;
          Client.Sid:= sid;
        finally
          Client.CS_client.Leave;
        end;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': BaseAutorize - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
      end // if flBaseAutorize
      else begin
        UserCode:= IntToStr(pUserID);
      end;
    finally
      if (pFirmID<1) and Assigned(Client) then pFirmID:= Client.FirmID;
      prSetThLogParams(ThreadData, command, pUserID, pFirmID, sParam); // ����������� � ib_css
    end;
    Client.CS_client.Enter;
    try
      Client.LastAct:= Now;
    finally
      Client.CS_client.Leave;
    end;

//---------------------------------------------------------- �������� ����������
    ss:= Client.CheckBlocked(True, True, cosByWeb);
    if Client.Blocked then raise EBOBError.Create(ss);

    firma:= Cache.arFirmInfo[pFirmID];
    if firma.Arhived or firma.Blocked then
      raise EBOBError.Create(MessText(mtkNotFirmProcess, firma.Name));
    if (firma.FirmContracts.Count<1) then
      raise EBOBError.Create('�� ������� ��������� �����������');

    // ���������� ������ �������� �������������
    if firma.IsFinalClient and (Cache.GetConstItem(pcBlockFinalClient).IntValue=1) then
      raise EBOBError.Create('������ �������� ����������. ���������� �����, ����������.');

    Contract:= Client.GetCliContract(contID, True);

    FirmCode:= IntToStr(pFirmID);
    username:= fnCutFIO(Client.Name)+', '+firma.Name+cSpecDelim+firma.UPPERSHORTNAME; // ������������ �����
    usermail:= ExtractFictiveEmail(Client.Mail);      // Email ������������ ����

    with Client do begin
      if Arhived then raise EBOBError.Create(MessText(mtkNotLoginProcess, Client.Login));
      if Blocked then raise EBOBError.Create(MessText(mtkBlockCountLogin, Client.Login));
    end;
//------------------------------------------------------------------ �����������
    if flEnterByLogin then begin
      Notifics:= Cache.Notifications.GetFirmNotifications(pFirmID); // ������ ����������� �����
      if (Notifics.Count>0) then begin
        ibDb:= cntsORD.GetFreeCnt;
        ss:= fnIntegerListToStr(Notifics); // ������ � ������ ����������� �����

if flLogTestClients then begin
    prMessageLOGS(nmProc+': Notifications - start', fLogDebug, false); // ����� � log
    LocStart:= now();
end;
        try
          ibS:= fnCreateNewIBSQL(ibDb, 'ibS_'+nmProc, ThreadData.ID, tpRead, true);
          ibS.SQL.Text:= 'Select noclnote from notifiedclients'+
            ' left join Notifications on NoteCODE=NoClNote'+
            ' where (NoClClient='+UserCode+') and (NoClNote in ('+ss+'))'+
            ' and (NoClViewTime is not null or (NoClShowTime is not null and'+
            ' (DATEADD(HOUR, NoteHourInterval, NoClShowTime)>current_timestamp)))';
          ibS.ExecQuery;
          while not ibs.Eof do begin // ������� �����������, � ���.���������� ��� �������� ���������� ����
            Notifics.Remove(ibS.FieldByName('noclnote').AsInteger);
            TestCssStopException;
            ibs.Next;
          end;
        finally
          prFreeIBSQL(ibS);
          cntsOrd.SetFreeCnt(ibDb);
        end;

if flLogTestClients then begin
    prMessageLOGS(nmProc+': Notifications - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end;
      end; // if (Notifics.Count>0)
    end // if flEnterByLogin
    else Notifics:= TIntegerList.Create; // �� ����.������
//------------------------------------------------------------------------------

    Stream.Clear;
    Stream.WriteInt(aeSuccess);       // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(Client.ID);       // ��� ������������
    Stream.WriteStr(Client.Login);    // ����� ������������
    Stream.WriteStr(Client.Password); // ������ ������������ �� ������, ���� ����� �������������� �����
    Stream.WriteInt(Client.FirmID);   // ��� �����
    Stream.WriteStr(Client.Sid);      // id ������
    Stream.WriteBool(Client.resetPW); // ������� ������ ������
    Stream.WriteInt(Cache.GetConstItem(pcClientTimeOutWeb).IntValue);
    Stream.WriteStr(username);        // ������������ ������� � �����
    Stream.WriteStr(usermail);        // Email ������������ ����

    Stream.WriteBool(firma.SUPERVISOR=pUserID); // �������� �� ������������ ������������
    if (firma.SUPERVISOR<>pUserID) then begin   // ���� �� ��������, �� �������� ��� �����
      Stream.WriteBool(false); // WOCLRIGHTSENDORDER
      Stream.WriteBool(false); // WOCLRIGHTOWNPRICE
      Stream.WriteBool(false); // WOCLRIGHTVIEWDISCOUNTABLE
    end;

    Stream.WriteInt(ContID); // ��� ��������� (���� ���� - ����������)

    if FullData then begin
      prof:= firma.GetFirmCredProfile(Contract.CredProfile);
      if not Assigned(prof) then prof:= ZeroCredProfile;

//      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteDouble(prof.ProfCredLimit);
      Stream.WriteDouble(Contract.DebtSum);

//      Stream.WriteDouble(Contract.OrderSum); // ������ �� ���������
      Stream.WriteDouble(firma.AllOrderSum);  // ����� ������ �� �/�
      Stream.WriteDouble(firma.ResLimit);     // ����� �������
      if (firma.ResLimit>0) then
        Stream.WriteDouble(firma.ResLimit-firma.AllOrderSum) // ������� ������
      else Stream.WriteDouble(0);
// ResLimit<0 - ������ �� ������, >=0 ���������� � ������� ����� /,
// � ��������� �� ���� ����� "����� ������� (�������/���������� - ...)"
      Stream.WriteDouble(Contract.PlanOutSum);
      i:= Contract.CredCurrency;
      Stream.WriteInt(i);
      Stream.WriteStr(Cache.GetCurrName(i, True));

      ss:= Contract.WarnMessage;
      if firma.SaleBlocked then begin
        fl:= True;
        ss:= '�������� ������� ������ ��� ����� ����������';
      end else if (Contract.Status=cstClosed) then begin
        fl:= True;
        if (ss='') then ss:= '�������� ������';
      end else begin
        fl:= Contract.SaleBlocked or prof.Blocked;
        if fl and (ss='') then ss:= prof.WarnMessage;
      end;

      Stream.WriteStr(ss);
      Stream.WriteBool(fl);
//      Stream.WriteInt(Contract.CredDelay);
      Stream.WriteInt(prof.ProfCredDelay);
      if not fl then Stream.WriteInt(Contract.WhenBlocked); // ���� �������� �� �����������

      Stream.WriteBool(firma.HasVINmail);
      ss:= '';
      if (firma.ActionText<>'') and
        (pos(cActionTextDelim, Cache.GetConstItem(pcCommonActionText).StrValue)>0) then
        ss:= StringReplace(Cache.GetConstItem(pcCommonActionText).StrValue,
             cActionTextDelim, firma.ActionText, []);
      Stream.WriteStr(ss); // ����� ����� ����� + ��������� ������� � �����
      Stream.WriteDouble(Cache.DefCurrRate);
      Stream.WriteDouble(Cache.BonusVolumeCoeff);
      Stream.WriteDouble(Trunc(firma.BonusQty));
      Stream.WriteInt(Client.CliContracts.Count); // ���-�� ��������� ����������
      Stream.WriteStr(Contract.Name);
      Stream.WriteStr(Contract.LegalFirmName); // ��.����
      if (Contract.Status=cstClosed) then Stream.WriteStr('')
      else Stream.WriteStr(Cache.GetDprtMainName(Contract.MainStorage));
      Stream.WriteStr(Cache.Currencies.GetItemName(Cache.BonusCrncCode)); // �������� ������ �������
      contBonusOrd:= firma.ContUnitOrd;
      if (contBonusOrd>0) and not Client.CheckContract(contBonusOrd) then contBonusOrd:= -1;
      Stream.WriteInt(contBonusOrd); // �������� UNIT-������, <0 - ����������
      Stream.WriteDouble(Trunc(firma.BonusRes)); // UNIT-������

//--------------------------------------------------------------- ������ �������
      try
        SetLength(DirectParams, Cache.DiscountModels.ProdDirectList.Count); // ���-�� �����������
        for i:= 0 to High(DirectParams) do with DirectParams[i] do begin // 1- ��������� �����������
          Name:= Cache.DiscountModels.ProdDirectList[i]; // �������� �����������
          j:= Integer(Cache.DiscountModels.ProdDirectList.Objects[i]);
          LevelCount:= Cache.DiscountModels.GetDirectModelsCount(j); // ���-�� �������
          ProcToNext:= 0;
          FirmSales:= 0;
          FirmModel:= nil;
          NextModel:= nil;
        end;

        for i:= 0 to firma.FirmDiscModels.Count-1 do begin // 2- ������� ��������� �/�
          tt:= TTwoCodes(firma.FirmDiscModels[i]);
          j:= Cache.DiscountModels.GetDirectIndex(tt.ID1); // ������ �����������
          if (j>High(DirectParams)) then Continue;
          with DirectParams[j] do begin
            FirmModel:= Cache.DiscountModels[tt.ID2]; // ������� ������ �/�
            FirmSales:= Round(tt.Qty);                // ������. ������� ������ �/�
          end;
        end;

        j:= -1;
        for i:= 0 to Cache.DiscountModels.DiscModels.Count-1 do begin // 3- ���� ������, �� ������� �/� �� ����������
          dm:= TDiscModel(Cache.DiscountModels.DiscModels[i]);
          if (j<>dm.DirectInd) then begin // ����� �����������
            j:= dm.DirectInd;
            iBlock:= 0;
          end;
          with DirectParams[j] do begin
            if Assigned(NextModel) then Continue         // ����������, ���� ��� �����
            else if ((FirmSales<0) and (dm.Sales=0)) then Continue // ������<0 - ���������� 1-� �������
            else if (FirmSales>=dm.Sales) then begin
              iBlock:= dm.Sales; // ���������� ������ �������
              Continue; // ���������� ������, �� ������� �/� ��� �������
            end;
            NextModel:= dm; // ������ ������, �� �������� �/� �� ����������
            if (FirmSales<0) then ProcToNext:= 100  // ������<0 - ������� ������� ����� 100%
            else begin
              iBlock:= dm.Sales-iBlock; // ������� ������� �����, �������� �� ������� �� ������, �� �������� �/� �� ����������
              if (iBlock<>0) then ProcToNext:= Round((dm.Sales-FirmSales)*100/iBlock);
            end;
          end;
        end;
        //------------------------------------------------------- �������� � CGI
        Stream.WriteInt(Length(DirectParams)); // ���-�� �����������
        for i:= 0 to High(DirectParams) do with DirectParams[i] do begin
          dm:= Cache.DiscountModels.EmptyModel;
          if not Assigned(FirmModel) then FirmModel:= dm;
          if not Assigned(NextModel) then NextModel:= dm;
          Stream.WriteStr(Name);             // �������� �����������
          Stream.WriteInt(LevelCount);       // ���-�� �������
          Stream.WriteInt(FirmModel.Rating); // ������� �������
          Stream.WriteInt(FirmModel.Sales);  // ���������� ������� �������� ������
          Stream.WriteInt(NextModel.Rating); // �������, �� �������� �/� �� ���������� �� ������� �������� ������
          Stream.WriteInt(NextModel.Sales);  // ���������� ������� ������, �� �������� �/� �� ����������
          Stream.WriteInt(ProcToNext);       // ������� ������� �����, �������� �� ������� �� ������, �� �������� �/� �� ����������
          Stream.WriteInt(FirmSales);        // ���������� �������� ������� �/�
        end;
      finally
        SetLength(DirectParams, 0);
      end;
//--------------------------------------------------------------- ������ �������
      Stream.WriteBool(Cache.GBAttributes.HasNewGroups); // ������� ������� ����� ����� ���������
    end; // if FullData

    Stream.WriteDouble(Now);
    Stream.WriteStr(FirmCode);
//    Stream.WriteBool(Contract.SysID=constIsMoto); // ������� ����
//    Stream.WriteBool(false); // ��������
    Stream.WriteBool(firma.IsFinalClient); // ������� ��������� �������

    Stream.WriteInt(Notifics.Count); //----------------------------- �����������
    for i:= 0 to Notifics.Count-1 do Stream.WriteInt(Notifics[i]);

  except
    on E: EBOBError do  // '������ �����������. '
      prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr('������ �����.');
      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
    end;
  end;
  Stream.Position:= 0;
  prFree(Notifics);
end;
//*******************************************************************************
procedure prGetOptionsOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetOptionsOrd'; // ��� ���������/�������
var UserId, FirmID, i, j, ContID, ind, iCount, deliv, destID, ii: integer;
    Stores: Tasd;
//    Store: TStoreInfo;
    Client, cli: TClientInfo;
    firma: TFirmInfo;
    Contract: TContract;
    iList: TIntegerList;  // not Free
    errmess, destName, destAdr: String;
//    grp: TWareInfo;
//    cq: TCodeAndQty;
    fl: Boolean;
    dest: TDestPoint;
    lst: TStringList;
    fpp: TFirmPhoneParams;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetOptions, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    Client:= Cache.arClientInfo[UserID];
    if (contID<1) then contID:= Client.LastContract;
    firma:= Cache.arFirmInfo[FirmID];
    Contract:= firma.GetContract(contID);
//    iList:= EmptyIntegerList;
    if firma.IsFinalClient then begin
      deliv:= cDelivSelfGet;
      destID:= 0;
    end else with Client.GetCliContDefs(contID) do begin
      deliv:= ID1;
      destID:= ID2;
if flNotReserve then
      if (deliv=cDelivReserve) then deliv:= cDelivTimeTable;
    end;
//----------------------------------------------------------- ��������� � ������
    Stream.WriteByte(Contract.PayType);
    Stream.WriteByte(deliv);
    destName:= '';
    destAdr := '';
    if (destID>0) then begin
      dest:= Contract.GetContDestPoint(destID);
      if Assigned(dest) then begin
        destName:= dest.Name;
        destAdr := dest.Adress;
      end else destID:= 0;
    end;
    Stream.WriteInt(destID);  // �������� �����
    Stream.WriteStr(destName);
    Stream.WriteStr(destAdr);
    Stream.WriteBool(Client.NOTREMINDCOMMENT);
    Stream.WriteInt(Client.SearchCurrencyID);
    Stream.WriteStr(IntToStr(Client.MaxRowShowAnalogs));
    Stream.WriteBool(Client.DocsByCurrContr);
    SetLength(Stores, 0);

    prSendStorages(Stores, Stream);
    Stream.WriteBool(firma.EnablePriceLoad);
//---------------------------------------------------------- ������������ ������
    with Client do begin
      Stream.WriteStr(Name);
      Stream.WriteStr(Post);
      Stream.WriteInt(CliPhones.Count); // Client.CliPhones
      for i:= 0 to CliPhones.Count-1 do Stream.WriteStr(CliPhones[i]);
      lst:= ExtractFictiveEmail(CliMails);
      try
        Stream.WriteInt(lst.Count);
        for i:= 0 to lst.Count-1 do Stream.WriteStr(lst[i]);
      finally
        prFree(lst);
      end;
      Stream.WriteBool(firma.SendInvoice); // ������� �������� ���������
    end; //  with Client

{if flMargins then begin
//---------------------------------------------------------------------- �������
    iCount:= 0;
    ind:= Stream.Position;
    Stream.WriteInt(iCount); // ����� ��� ���-�� �����
    with Client.GetContMarginListAll(contID, False) do try
      for i:= 0 to Count-1 do begin
        cq:= Items[i];
        grp:= TWareInfo(Pointer(cq.ID));
        if not grp.IsGrp and not grp.IsPgr then Continue;
        if grp.IsGrp then Stream.WriteInt(0) else Stream.WriteInt(grp.PgrID); // 0     /������
        Stream.WriteInt(grp.ID);                                             // ������/���������
        Stream.WriteStr(grp.Name);                                           // ������������
        Stream.WriteDouble(cq.Qty);                                         // �������
        inc(iCount);
//if flDebug then prMessageLOGS('������ '+fnMakeAddCharStr(gr.Name, 60, True)+' ������� '+FloatToStr(cq.Qty), fLogDebug, false); // debug
      end;
    finally
      Free;
    end;
    if (iCount>0) then begin
      Stream.Position:= ind;
      Stream.WriteInt(iCount); // ���-�� �����
      Stream.Position:= Stream.Size;
    end;
end; // if flMargins   }

//-------------------------------------------------------- ��������� SMS   begin
    if (Client.ID<>firma.SUPERVISOR) then // ���� �� �������
      Stream.WriteInt(0)
    else if firma.IsFinalClient then      // ���� �������� ����������
      Stream.WriteInt(0)
    else try
      lst:= TStringList.Create;
      iCount:= Cache.SMSmodelsList.Count; //----------- ������� ������ ���������

      for i:= 0 to High(firma.FirmClients) do begin // ���������� �/�
        deliv:= firma.FirmClients[i];
        if not Cache.ClientExist(deliv) then Continue;
        Cli:= Cache.arClientInfo[deliv];
        if Cli.Arhived or (Cli.CliPhones.Count<1) then Continue;

        destAdr:= Cli.Name+fnIfStr(Cli.Post<>'', ', ', '')+Cli.Post; // ���+��������� ����������
        for ii:= 0 to Cli.CliPhones.Count-1 do begin
          destName:= Cli.CliPhones[ii]; // �������

          if not CheckMobileNumber(destName) then Continue; // �������� ���������� ������ ��������

          ind:= lst.IndexOf(destName);
          if (ind<0) then begin
            fpp:= TFirmPhoneParams.Create(destAdr, iCount);
            lst.AddObject(destName, fpp);
          end else begin
            fpp:= TFirmPhoneParams(lst.Objects[ind]);
            fpp.Names:= fpp.Names+fnIfStr(fpp.Names='', '', '; ')+destAdr;
          end;

          iList:= TIntegerList(Cli.CliPhones.Objects[ii]);
          for j:= 0 to Cache.SMSmodelsList.Count-1 do begin
            destID:= Integer(Cache.SMSmodelsList.Objects[j]);
            if (iList.IndexOf(destID)>-1) then Inc(fpp.arSMSind[j]);
          end;
        end; // for ii:= 0 to Cli.CliPhones.Count
      end; // for i:= 0 to High(firma.FirmClients)

                                           //-------------------------- ��������
      Stream.WriteInt(iCount); //-------- ���-�� �������� SMS
      for j:= 0 to Cache.SMSmodelsList.Count-1 do begin
        destID:= Integer(Cache.SMSmodelsList.Objects[j]);
//        Stream.WriteInt(destID);                        // ��� ������� SMS
        destName:= Cache.GetSMSmodelName(destID);
        Stream.WriteStr(destName); // �������� ������� SMS
      end;

      Stream.WriteInt(lst.Count); //-------- ���-�� ���������
      for j:= 0 to lst.Count-1 do begin
        fpp:= TFirmPhoneParams(lst.Objects[j]);
        Stream.WriteStr(lst[j]);    // �������
        Stream.WriteStr(fpp.Names); // ������ �����������
        for i:= 0 to High(fpp.arSMSind) do begin // ����� SMS �� ��������
          fl:= (fpp.arSMSind[i]>0);
          Stream.WriteBool(fl);
        end;
      end; // for j:= 0 to lst.Count-1
    finally
      for i:= 0 to lst.Count-1 do begin
        fpp:= TFirmPhoneParams(lst.Objects[i]);
        prFree(fpp);
      end;
      prFree(lst);
    end;
//---------------------------------------------------------- ��������� SMS   end

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Stores, 0);
  Stream.Position:= 0;
end;
//============================================ �������� ��������� ������ �������
procedure prChangeVisibilityOfStorage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prChangeVisibilityOfStorage'; // ��� ���������/�������
var {IBD: TIBDatabase;
    IBS: TIBSQL;
    UserID, FirmID, i, j, index, contID, StoreID, opt: integer;
    StoreCode, Visibility, errmess: string; }
    Storages: Tasd;
{    Contract: TContract;
    Client: TClientInfo;
    CliStores: TIntegerList;  // not Free  }
begin
  Stream.Position:= 0;
  SetLength(Storages, 0);
//  IBS:= nil;
//  contID:= 0;
//  opt:= 0;
  try
{    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
//    ContID:= Stream.ReadInt; // ��� ���������� - ����� �� �����
    StoreCode:= Stream.ReadStr;
    Visibility:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csChangeVisibilityOfStorage, UserID, FirmID, 'StoreCode='+StoreCode+' Visibility='+Visibility); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    StoreID:= StrToIntDef(StoreCode, 0);
    Client:= Cache.arClientInfo[UserID];
                               // ���������, �������� �� ������ ���� �����
    Contract:= Cache.arFirmInfo[FirmID].GetContract(contID);
    if (Client.CliContracts.IndexOf(contID)<0) then raise EBOBError.Create('�������� �� ������');

    index:= Contract.Get�ontStoreIndex(StoreID);
    if (index<0) then raise EBOBError.Create('����� �� ������');
    if (Visibility='false') and Contract.ContStorages[index].IsReserve then
      raise EBOBError.Create('�����, ��������� ��� ��������������, ������ ������� ���������');

    index:= Client.GetCliStoreIndex(contID, StoreID);
    If (Visibility='false') then begin
      if (index>-1) then opt:= 1000;
    end else If (index<0) then opt:= 100;

    if (opt>0) then begin
      IBD:= cntsORD.GetFreeCnt;
      try
        IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
        IBS.SQL.Text:= 'execute procedure ChangeCliContrStoreOrder('+
          IntToStr(UserID)+', '+IntToStr(contID)+', '+IntToStr(StoreID)+', '+IntToStr(opt)+')';
        IBS.ExecQuery;
        IBS.Transaction.Commit;
        IBS.Close;
      finally
        prFreeIBSQL(IBS);
        cntsORD.SetFreeCnt(IBD);
      end;
      If (opt=1000) then Client.DelCliStoreCode(contID, StoreID)
      else If (opt=100) then Client.AddCliStoreCode(contID, StoreID);
    end;

    //------------------------------------- ���� ��������� ������ ��� � ��������
    // ������� �������� �� ������, ������� ���� ��������� ��� �������
    CliStores:= Client.GetContStoreCodes(contID);
    SetLength(Storages, CliStores.Count);
    for i:= 0 to CliStores.Count-1 do begin
      StoreID:= CliStores[i];
      Storages[i].Code:= IntToStr(StoreID);
      Storages[i].FullName:= Cache.GetDprtMainName(StoreID);
      Storages[i].IsVisible:= true;
      index:= Contract.Get�ontStoreIndex(StoreID);
      Storages[i].IsReserve:= Contract.ContStorages[index].IsReserve;
    end;
    // ����� ��� ���������
    if (Length(Contract.ContStorages)>CliStores.Count) then
      for i:= 0 to High(Contract.ContStorages) do begin
        StoreID:= Contract.ContStorages[i].DprtID;
        if (CliStores.IndexOf(StoreID)>-1) then Continue;
        j:= Length(Storages);
        SetLength(Storages, j+1);
        Storages[j].Code:= IntToStr(StoreID);
        Storages[j].FullName:= Cache.GetDprtMainName(StoreID);
        Storages[j].IsVisible:= false;
        Storages[j].IsReserve:= Contract.ContStorages[i].IsReserve;
      end;
}
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    prSendStorages(Storages, Stream);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Storages, 0);
  Stream.Position:= 0;
end;
//======================= ����������� ����� � ������ ��������� ������� ����/����
procedure prClientsStoreMove(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prClientsStoreMove'; // ��� ���������/�������
var {IBD: TIBDatabase;
    IBS: TIBSQL;
    UserID, FirmID, i, j, jj, index, contID, StoreID, opt: integer;
    StoreCode, Direct, errmess: string; }
    Storages: Tasd;
{    Contract: TContract;
    Client: TClientInfo;
    CliStores: TIntegerList;  // not Free    }
begin
  Stream.Position:= 0;
  SetLength(Storages, 0);
//  IBS:= nil;
//  contID:= 0;
//  opt:= 0;
  try
{    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
//    ContID:= Stream.ReadInt; // ��� ���������� - ����� �� �����
    StoreCode:= Stream.ReadStr;
    Direct:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csClientsStoreMove, UserID, FirmID, 'StoreCode='+StoreCode+' Direct='+Direct); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    StoreID:= StrToIntDef(StoreCode, 0);
    Client:= Cache.arClientInfo[UserID];

    Contract:= Cache.arFirmInfo[FirmID].GetContract(contID);
    if (Client.CliContracts.IndexOf(contID)<0) then raise EBOBError.Create('�������� �� ������');

    // ���������, �������� �� ������ ���� �����
    index:= Contract.Get�ontStoreIndex(StoreID);
    if (index<0) then raise EBOBError.Create('����� �� ������');

    CliStores:= Client.GetContStoreCodes(contID);
    index:= CliStores.IndexOf(StoreID);
    if (index<0) then raise EBOBError.Create('����� �� ������');

    If (Direct='up') then begin
      if (index>0) then opt:= -1;
    end else If (index<(CliStores.Count-1)) then opt:= 1;

    if (opt<>0) then begin
      IBD:= cntsORD.GetFreeCnt;
      try
        IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
        IBS.SQL.Text:= 'execute procedure ChangeCliContrStoreOrder('+
          IntToStr(UserID)+', '+IntToStr(contID)+', '+IntToStr(StoreID)+', '+IntToStr(opt)+')';
        IBS.ExecQuery;
        IBS.Transaction.Commit;
        IBS.Close;
      finally
        prFreeIBSQL(IBS);
        cntsORD.SetFreeCnt(IBD);
      end;
      j:= index+opt;
      jj:= CliStores[j];
      Client.CS_client.Enter;
      try
        CliStores[j]:= StoreID;
        CliStores[index]:= jj;
      finally
        Client.CS_client.Leave;
      end;
    end;

    //------------------------------------- ���� ��������� ������ ��� � ��������
    // ������� �������� �� ������, ������� ���� ��������� ��� �������
    CliStores:= Client.GetContStoreCodes(contID);
    SetLength(Storages, CliStores.Count);
    for i:= 0 to CliStores.Count-1 do begin
      StoreID:= CliStores[i];
      Storages[i].Code:= IntToStr(StoreID);
      Storages[i].FullName:= Cache.GetDprtMainName(StoreID);
      Storages[i].IsVisible:= true;
      index:= Contract.Get�ontStoreIndex(StoreID);
      Storages[i].IsReserve:= Contract.ContStorages[index].IsReserve;
    end;
    // ����� ��� ���������
    if (Length(Contract.ContStorages)>CliStores.Count) then
      for i:= 0 to High(Contract.ContStorages) do begin
        StoreID:= Contract.ContStorages[i].DprtID;
        if (CliStores.IndexOf(StoreID)>-1) then Continue;
        j:= Length(Storages);
        SetLength(Storages, j+1);
        Storages[j].Code:= IntToStr(StoreID);
        Storages[j].FullName:= Cache.GetDprtMainName(StoreID);
        Storages[j].IsVisible:= false;
        Storages[j].IsReserve:= Contract.ContStorages[i].IsReserve;
      end;
}
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    prSendStorages(Storages, Stream);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Storages, 0);
  Stream.Position:= 0;
end;
//========================== �������� ��������� �������� �������/�������� ������
procedure prChangeClientLastContract(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prChangeClientLastContract'; // ��� ���������/�������
var UserID, FirmID, contID, contIdNew, OrderID: integer;
    errmess: String;
begin
  Stream.Position:= 0;
  errmess:= '';
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderID:= Stream.ReadInt; //

    prSetThLogParams(ThreadData, csChangeContract, UserID, FirmID,
      'ContID='+IntToStr(ContID)+#13#10'OrderID='+IntToStr(OrderID)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if (OrderID=0) then
      errmess:= Cache.arClientInfo[UserID].SetLastContract(contID)
    else begin
      contIdNew:= ContID;
      Cache.arClientInfo[UserID].GetCliContract(contIdNew);
      if (contIdNew=contId) then
        prChangeOrderContract(FirmId, contID, OrderID, ThreadData)
      else errmess:= '�������� �� ������������� ������.';
    end;
    if (errmess<>'') then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//================================== �������� �������� ������ � ����������� ����
procedure prChangeOrderContract(FirmID, ContID, OrderID: integer; ThreadData: TThreadData);
const nmProc = 'prChangeOrderContract'; // ��� ���������/�������
// ������������ FirmID, ContID ����������� �� ������ !!!
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    lst: TStringList;
    curr, i: Integer;
    exlines: Boolean;
    CurrPrice: Double;
    s: String;
    ware: TWareInfo;
begin
  OrdIBS:=  nil;
  OrdIBD:= nil;
  lst:= TStringList.Create;
  try

    OrdIBD:= cntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);
    OrdIBS.SQL.Text:= 'select ORDRCONTRACT, ORDRFIRM, ORDRSTATUS, ORDRCURRENCY,'+
      ' iif(exists(select * from ORDERSLINES where ORDRLNORDER=ORDRCODE), 1, 0) ex'+
      ' from ORDERSREESTR where ORDRCODE='+IntToStr(OrderID);
    OrdIBS.ExecQuery;
    if (OrdIBS.Eof and OrdIBS.Bof) then
      raise EBOBError.Create(MessText(mtkNotFoundOrder, IntToStr(OrderID)))
    else if (OrdIBS.fieldByName('ORDRFIRM').AsInteger<>FirmID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' �����������')
    else if (OrdIBS.fieldByName('ORDRSTATUS').AsInteger<>orstForming) then
      raise EBOBError.Create(MessText(mtkOnlyFormingOrd))
    else  // if (ContID<1) then ContID:= Cache.arClientInfo[UserID].GetCliCurrContID;
    if (OrdIBS.fieldByName('ORDRCONTRACT').AsInteger=ContID) then Exit;

    curr:= OrdIBS.fieldByName('ORDRCURRENCY').AsInteger;
    exlines:= (OrdIBS.fieldByName('ex').AsInteger=1); // ������� ������� ������� � ������
    OrdIBS.Close;

    if exlines then begin
      OrdIBS.SQL.Text:= 'select ORDRLNCODE, ORDRLNWARE, ORDRLNPRICE'+
                        ' from ORDERSLINES where ORDRLNORDER='+IntToStr(OrderID);
      OrdIBS.ExecQuery;
      while not OrdIBS.EOF do begin
        ware:= Cache.GetWare(OrdIBS.FieldByName('ORDRLNWARE').AsInteger);

        CurrPrice:= ware.SellingPrice(FirmID, curr, contID);
        if fnNotZero(OrdIBS.FieldByName('ORDRLNPRICE').AsFloat-CurrPrice) then
          lst.Add('UPDATE ORDERSLINES set ORDRLNPRICE='+ // ������ ��� ��������� ���
            StringReplace(FloatToStr(CurrPrice), ',', '.', [rfReplaceAll])+
            ' where ORDRLNCODE='+OrdIBS.FieldByName('ORDRLNCODE').AsString+';');
        TestCssStopException;
        OrdIBS.Next;
      end;
      OrdIBS.Close;
    end; // if exlines

    i:= lst.Count;
    lst.Insert(0, 'execute block as begin');
    lst.Add('update ORDERSREESTR set ORDRCONTRACT='+IntToStr(ContID)+
      fnIfStr(i>0, ', ORDRRECALCTIME="NOW"', '')+
      ' where ORDRCODE='+IntToStr(OrderID)+'; end');

    OrdIBS.SQL.Clear;
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.AddStrings(lst);
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(nmProc+': '+s);
  finally
    prFreeIBSQL(OrdIBS);
    cntsOrd.SetFreeCnt(OrdIBD);
    prFree(lst);
  end;
end;
//****************** ��������������� ��������� ������ �� ��������� �������������
procedure prSetOrderDefaultOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetOrderDefaultOrd'; // ��� ���������/�������
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    UserId, FirmID, iAnaRows: integer;
    paytype, reserv, AnaRows, NotRemind, SearchCurr, Semafor, s: string;
begin
  OrdIBS:= nil;
  OrdIBD:= nil;
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    paytype:= Stream.ReadStr;  // ��������
    reserv:= Stream.ReadStr;
    NotRemind:= Stream.ReadStr;
    SearchCurr:= Stream.ReadStr;
    AnaRows:= trim(Stream.ReadStr);
    Semafor:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csSetOrderDefault, UserID, FirmID,
      'paytype='+paytype+#13#10'reserv='+reserv+#13#10'NotRemind='+NotRemind+
      #13#10'SearchCurr='+SearchCurr+#13#10'AnaRows='+AnaRows); // �����������

    iAnaRows:= StrToIntDef(AnaRows, -1);
    if (iAnaRows<0) then
      raise EBOBError.Create('���������� ����� ������ ���� ����� ������.');

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= 'UPDATE WEBORDERCLIENTS SET WOCLNOTREMINDCOMMENT=:s'+
      ', WOCLSEARCHCURRENCY='+fnIfStr(SearchCurr='1', SearchCurr, cStrDefCurrCode)+
      ', WOCLDEFAULTDELIVERYTYPE='+fnIfStr(reserv='1', '1', '0')+
      ', WOCLMAXROWFORSHOWANALOGS='+AnaRows+
      ', WOCLWARERESTSEMAFOR=:semafor '+
      ' where WOCLCODE='+IntToStr(UserID);
    OrdIBS.ParamByName('s').AsString:= fnIfStr(NotRemind='on', 'T', 'F');
    OrdIBS.ParamByName('semafor').AsString:= fnIfStr(Semafor='on', 'T', 'F');
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);
    with Cache.arClientInfo[UserID] do begin
      MaxRowShowAnalogs:= iAnaRows;
      SearchCurrencyId:= StrToInt(SearchCurr);
      NOTREMINDCOMMENT:= (NotRemind='on');
      DEFDELIVERYTYPE:= StrToIntDef(reserv, 0);
      WareSemafor:= (Semafor='on');
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(OrdIBS), 'OrdIBS.SQL.Text='+OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//************************************************ �������� ������ �������������
procedure prChangePasswordOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prChangePasswordOrd'; // ��� ���������/�������
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    UserId, FirmID, i: integer;
    oldpass, newpass1, newpass2, s, ss: string;
begin
  OrdIBS:= nil;
  OrdIBD:= nil;
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    oldpass:= Stream.ReadStr;
    newpass1:= Stream.ReadStr;
    newpass2:= Stream.ReadStr;
                                     // csChangePass   ???
    prSetThLogParams(ThreadData, csChangePassword, UserID, FirmID,
      'oldpass='+oldpass+#13#10'newpass1='+newpass1+#13#10'newpass2='+newpass2); // �����������

    if (newpass1=oldpass) then
      raise EBOBError.Create('����� ������ �� ������ ��������� �� ������.');
    i:= Cache.CliPasswLength;
    if not fnCheckOrderWebPassword(newpass1) then
      raise EBOBError.Create(MessText(mtkNotValidPassw, IntToStr(i)));
    if (newpass1<>newpass2) then
      raise EBOBError.Create('����� ������ � ��� ������ �� ���������.');
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    with Cache.arClientInfo[UserId] do begin
      if (newpass1=Login) then
        raise EBOBError.Create('������ �� ������ ��������� � �������.');
      if (Password<>oldpass) then
        raise EBOBError.Create('������ ������ ������ �������.');

      OrdIBD:= cntsORD.GetFreeCnt;
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
      OrdIBS.SQL.Text:= 'select rErrText from SetUserPassword('+IntToStr(UserID)+', :p, 0, 0)';
      OrdIBS.ParamByName('p').AsString:= newpass1;
      s:= RepeatExecuteIBSQL(OrdIBS, 'rErrText', ss);
      if s<>'' then raise Exception.Create(s);
      if ss<>'' then raise EBOBError.Create(ss);
      Password:= newpass1;
    end; // with Cache.arClientInfo[UserId]
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr('��� ������ ������� �������.');
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(OrdIBS), 'OrdIBS.SQL.Text='+OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end; 
//*******************************************************************************
procedure prWebSetMainUserOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebSetMainUserOrd'; // ��� ���������/�������
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    UserId, FirmID, inewcode: integer;
    newcode, s, CliMail: string;
    Client: TClientInfo;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    newcode:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csWebSetMainUser, UserID, FirmID, 'newcode='+newcode); // �����������

    inewcode:= StrToIntDef(newcode, -1);
    if (inewcode<0) then raise EBOBError.Create(MessText(mtkErrorUserID));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if (Cache.arFirmInfo[FirmId].SUPERVISOR<>UserId) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.ClientExist(inewcode) then
      raise EBOBError.Create(MessText(mtkNotClientExist));

    Client:= Cache.arClientInfo[inewcode];
    if (Client.FirmID<>FirmId) then raise EBOBError.Create(MessText(mtkNotClientOfFirm));
    if (Client.Login='') then raise EBOBError.Create('�� ������� ������� ������ ������������.');
    if (Client.Name='') then raise EBOBError.Create('�� ������ ��� ������������.');
//    if (Client.Post='') then raise EBOBError.Create('�� ������ ��������� ������������.');
    CliMail:= ExtractFictiveEmail(Client.Mail);
    if (CliMail='') then raise EBOBError.Create('�� ����� E-mail ������������.');
    if not fnCheckEmail(CliMail) then raise EBOBError.Create('������������ E-mail ������������ - '+CliMail);

    OrdIBD:= cntsORD.GetFreeCnt;

    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= 'UPDATE WEBORDERFIRMS SET WOFRSUPERVISOR='+newcode+
                          ' WHERE WOFRCODE='+IntToStr(FirmID);
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);
    Cache.arFirmInfo[FirmId].SUPERVISOR:= inewcode;

    s:= SetMainUserToGB(FirmID, inewcode, Date()); // ������ � Grossbee
    if (s<>'') then prMessageLOGS(nmProc+': '+s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(OrdIBS), 'OrdIBS.SQL.Text='+OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end; 
//*******************************************************************************
procedure prWebResetPasswordOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebResetPasswordOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, inewcode: integer;
    newpass, newcode, s: string;
    Client: TClientInfo;
    FnamesValues: Tas;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  SetLength(FnamesValues, 2);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    newcode:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csWebResetPassword, UserID, FirmID, 'newcode='+newcode); // �����������

    inewcode:= StrToIntDef(newcode, -1);
    if (inewcode<0) then raise EBOBError.Create(MessText(mtkErrorUserID));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if (Cache.arFirmInfo[FirmId].SUPERVISOR<>UserId) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.ClientExist(inewcode) then
      raise EBOBError.Create(MessText(mtkNotClientExist));

    Client:= Cache.arClientInfo[inewcode];
    if (Client.FirmID<>FirmId) or (Client.Login=''){ or (Client.Post='')} then
      raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    OrdIBD:= cntsORD.GetFreeCnt;

    FnamesValues[0]:= 'rPassword';
    FnamesValues[1]:= 'rErrText';
//    FnamesValues:= ('rPassword', 'rErrText');

    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
    OrdIBS.SQL.Text:= 'select rPassword, rErrText from SetUserPassword('+newcode+', :p, 1, 0)';
    OrdIBS.ParamByName('p').AsString:= '';
    s:= RepeatExecuteIBSQL(OrdIBS, FnamesValues);
    if (s<>'') then raise Exception.Create(s);
    s:= FnamesValues[1];
    if (s<>'') then raise EBOBError.Create(s);
    newpass:= FnamesValues[0];
    Client.Password:= newpass;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(newpass);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(OrdIBS), 'OrdIBS.SQL.Text='+OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  SetLength(FnamesValues, 0);
  Stream.Position:= 0;
end; 
//******************************************************* ��������� ������������
procedure prWebCreateUserOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebCreateUserOrd'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserId, FirmID, inewcode: integer;
    newpass, newlogin, newcode, s, CliMail: string;
    Client: TClientInfo;
    firma: TFirmInfo;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    newcode:= Stream.ReadStr;
    newlogin:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csWebCreateUser, UserID, FirmID,
      'newcode='+newcode+#13#10'newlogin='+newlogin); // �����������

    inewcode:= StrToIntDef(newcode, -1);
    if (inewcode<0) then raise EBOBError.Create(MessText(mtkErrorUserID));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmId];
    if (firma.SUPERVISOR<>UserId) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.ClientExist(inewcode)then
      raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    Client:= Cache.arClientInfo[inewcode];
    if (Client.FirmID<>FirmId) then raise EBOBError.Create(MessText(mtkNotClientOfFirm));
    if (Client.Login<>'') then
      raise EBOBError.Create('������������ ��� ����� ������� ������ � �������.');

    if (Client.Name='') then raise EBOBError.Create('�� ������ ��� ������������.');
//    if (Client.Post='') then raise EBOBError.Create('�� ������ ��������� ������������.');
    s:= CheckClientFIO(Client.Name); // �������� ������������ ��� ������������ �������
    if (s<>'') then raise EBOBError.Create(s);

    CliMail:= ExtractFictiveEmail(Client.Mail);
    if (CliMail='') then raise EBOBError.Create('�� ����� E-mail ������������.');
    if not fnCheckEmail(CliMail) then
      raise EBOBError.Create('������������ E-mail ������������ - '+CliMail);

    if (newLogin='') or not fnCheckOrderWebLogin(newLogin) then
      raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
    if not fnNotLockingLogin(newlogin) then // ���������, �� ��������� �� ����� � �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, newLogin));
    try
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, True);
      IBS.SQL.Text:= 'select rPassword, rErrText from AddNewWebClientU('+
                         newCode+', '+IntToStr(FirmID)+', :login, 0, 0)'; // 4-� �����.=0 - ������� ������������
      IBS.ParamByName('login').AsString:= newlogin;
      IBS.ExecQuery;
      if not (IBS.Bof and IBS.Eof) and (IBS.FieldByName('rErrText').AsString<>'') then
        raise EBOBError.Create(IBS.FieldByName('rErrText').AsString);
      newpass:= IBS.FieldByName('rPassword').AsString;
      IBS.Transaction.Commit;
      IBS.Close;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;
    try
      IBD:= cntsGRB.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, True);
      IBS.SQL.Text:= 'UPDATE PERSONS SET PRSNLOGIN=:login WHERE PRSNCODE='+newCode;
      IBS.ParamByName('login').AsString:= newlogin;
      IBS.ExecQuery;
      if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;
    Cache.TestClients(UserId, True, False);

    s:= prSendMailWithClientPassw(kcmCreateUser, Client.Login, Client.Password, CliMail, ThreadData);
    if (s<>'') then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);   // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(Client.Post); // ���������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(IBS), 'IBS.SQL.Text='+IBS.SQL.Text, ''), False);
  end;
  Stream.Position:= 0;
end;
//============================================= ������������� ����������� ������
procedure prCheckLoginOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
// ���������� ��������� ��������� � ���������� ��� ����������� ������
const nmProc = 'prCheckLoginOrd'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    Login: string;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try
    Login:= Stream.ReadStr;
    prSetThLogParams(ThreadData, csCheckLogin, 0, 0, 'Login='+Login); // �����������

    if not fnCheckOrderWebLogin(Login) then
      raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
    if not fnNotLockingLogin(Login) then // ���������, �� ��������� �� ����� � �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));

    IBD:= cntsORD.GetFreeCnt; // ���������, �� ��������� �� ����� � ��� �����������
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
    IBS.SQL.Text:= 'Select WOCLCODE from WEBORDERCLIENTS where WOCLUPPERLOGIN=:Login';
    IBS.ParamByName('login').AsString:= UpperCase(Login);
    IBS.ExecQuery;
    if not (IBS.Bof and IBS.Eof) then
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));
    IBS.Close;
    
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr('����� `'+Login+'` �������� ��� �������������.');
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(IBS), 'IBS.SQL.Text='+IBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end; 
//*******************************************************************************
procedure prCreateNewOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCreateNewOrderOrd'; // ��� ���������/�������/������
var NewOrderID, UserId, FirmID, ContID: integer;
    ErrorMessage: string;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������

    prSetThLogParams(ThreadData, csCreateNewOrder, UserID, FirmID, 'ContID='+IntToStr(ContID)); // �����������

    prCreateNewOrderCommonOrd(UserId, FirmID, NewOrderID, ContID, ErrorMessage, ThreadData.ID);
    if ErrorMessage<>'' then raise EBOBError.Create(ErrorMessage);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(NewOrderID);
    Stream.WriteInt(ContID);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//*******************************************************************************
procedure prCreateOrderByMarkedOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCreateOrderByMarkedOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, OrderID, WareID, CurrencyID, ContID: integer;
    s, ErrorMessage, OrderCode, DivisibleMess, sStore, sWare, sPrice, sQty: string;
    Ware: TWareInfo;
    Qty: Double;
    Client: TClientInfo;
    Contract: TContract;
    lst: TStringList;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  DivisibleMess:= '';
  ContID:= 0;
  try
    lst:= TStringList.Create;
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    s:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csCreateOrderByMarked, UserID, FirmID,
      'Orders='+s+#13#10'ContID='+IntToStr(ContID)); // �����������

    if (s='') then  raise EBOBError.Create(MessText(mtkNotFoundOrders));
    if CheckNotValidUser(UserID, FirmID, ErrorMessage) then
      raise EBOBError.Create(ErrorMessage);
    ErrorMessage:= '';

    Client:= Cache.arClientInfo[UserID];
    Contract:= Client.GetCliContract(ContID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');

    sStore:= IntToStr(Contract.MainStorage);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);

    prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, ErrorMessage, ThreadData.ID, OrdIBS);
    if (ErrorMessage<>'') then raise EBOBError.Create(ErrorMessage);
    if (OrderID<1) then raise Exception.Create('NewOrderID<1');

    OrderCode:= IntToStr(OrderID);

    if (contID>0) then CurrencyID:= Cache.Contracts[contID].DutyCurrency
    else CurrencyID:= Client.SearchCurrencyID;

    lst.Add('execute block as declare variable xCode integer; begin');

    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select sum(ORDRLNCLIENTQTY) qty, ORDRLNWARE'+
      ' from ORDERSREESTR left join ORDERSLINES on ORDRLNORDER=ORDRCODE'+
      ' where ORDRFIRM='+IntToStr(FirmID)+  // ' AND ORDRSTATUS='+IntToSTr(orstForming)+
      ' and ORDRCODE in ('+s+') and ORDRCURRENCY<>'+IntToStr(Cache.BonusCrncCode)+ // ���������� �������� ������
      ' and ORDRLNCLIENTQTY>0 group by ORDRLNWARE order by ORDRLNWARE';
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      WareID:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
      Ware:= Cache.GetWare(WareID, True);
      if not Assigned(Ware) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

      sWare:= OrdIBS.FieldByName('ORDRLNWARE').AsString;
      Qty:= Ware.SellingPrice(FirmID, CurrencyID, contID);
      sPrice:= StringReplace(FloatToStr(Qty), ',', '.', [rfReplaceAll]);
      Qty:= OrdIBS.FieldByName('qty').AsFloat;
      s:= fnRecaclQtyByDivisible(WareID, Qty); // ��������� ���������
      if (s<>'') then DivisibleMess:= DivisibleMess+fnIfStr(DivisibleMess='','',#13#10)+s;
      sQty:= StringReplace(FloatToStr(Qty), ',', '.', [rfReplaceAll]);

{      lst.Add('select rNewOrderLnCode from AddOrderLineQty('+OrderCode+', '+
        sWare+', 0, '+IntToStr(Ware.measID)+', '+sPrice+', 0, 0) into :xCode;');
      lst.Add('if (xCode is null or xCode<1) then exception NotCorrect "������ ������ ������";');
      lst.Add('EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', '+sWare+', '+sStore+', '+sQty+');'); }
      lst.Add('select rNewOrderLnCode from AddOrderLineQty('+OrderCode+', '+
        sWare+', '+sQty+', '+IntToStr(Ware.measID)+', '+sPrice+', 0, 0) into :xCode;');
      lst.Add('if (xCode is null or xCode<1) then exception NotCorrect "������ ������ ������";');

      TestCssStopException;
      OrdIBS.Next;
    end;
    OrdIBS.Close;
    lst.Add(' end');

    OrdIBS.SQL.Clear;
    OrdIBS.ParamCheck:= False;
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.AddStrings(lst);
    sQty:= RepeatExecuteIBSQL(OrdIBS);
    if (sQty<>'') then raise Exception.Create(sQty);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(OrderID);
    Stream.WriteInt(ContID);
    if (DivisibleMess<>'') then
      DivisibleMess:= '� ��������� ������� ���������� ����������� �� ��������� �������.';
    Stream.WriteStr(DivisibleMess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(OrdIBS), 'OrdIBS.SQL.Text='+OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  prFree(lst);
  Stream.Position:= 0;
end; 
//================================================================ ������ ������
procedure prOrderImport(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prOrderImport'; // ��� ���������/�������/������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    NewOrderID, UserId, FirmID, ContID, iCount, i, Ncolumns, pos1, pos2, Curr,
      AddCount, DivCount, ErrCount: integer;
    ErrMess, StrIN, sStore, OrderCode, DivMess, sWare, sPrice, sQty, sQty1, sQty2,
      sParam, FName, ORDRNUM, wName, zipName: string;
    lstOrd, lstOut, lstW: TStringList;
    Widths: Tai;
    Ware: TWareInfo;
    Qty, Price: Double;
    Client: TClientInfo;
    Contract: TContract;
    rbs, FileName: RawByteString;
    Stream1: TBoBMemoryStream;
  //----------------------------------------------
  procedure AddStr(s: string);
  begin
    if (lstOut.Capacity=lstOut.Count) then lstOut.Capacity:= lstOut.Capacity+1000;
    AddXmlLine(lstOut, s);
  end;
  //----------------------------------------------
begin
  Stream.Position:= 0;
  ContID:= 0;
  NewOrderID:= 0;
  lstOrd:= TStringList.Create; // ������ ������� � ������ ��� �������� �������
  lstOrd.Sorted:= True;
  lstOut:= TStringList.Create; // xml-������ ������
  lstOut.Capacity:= 1000;
  lstW:= TStringList.Create;   // ������ ������� ��� ������
  lstW.Capacity:= 1000;
  Ncolumns:= 4;
  Setlength(Widths, Ncolumns);
  Widths[0]:= 250; // ������������
  Widths[3]:= 400; // ���������
  CheckStyle(skTxt);
  CheckStyle(skCTxt);
  CheckStyle(skHead);
  CheckStyle(skTxtYellow);
  CheckStyle(skTxtGreen);
  CheckStyle(skBold);
  CheckStyle(skCBold);
  Stream1:= nil;
  AddCount:= 0;
  DivCount:= 0;
  ErrCount:= 0;
  ORDRNUM:= '';
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    iCount:= Stream.ReadInt; // ��������� ���-�� �����

    sParam:= 'ContID='+IntToStr(ContID)+#13#10'iCount='+IntToStr(iCount);
    try
      if CheckNotValidUser(UserID, FirmID, ErrMess) then
        raise EBOBError.Create(ErrMess);
      if (iCount<1) then EBOBError.Create(MessText(mtkNotFoundData));

      Client:= Cache.arClientInfo[UserID];
      Contract:= Client.GetCliContract(ContID);
      if (Contract.Status=cstClosed) then raise EBOBError.Create('�������� '+
        Contract.Name+' ������, ������� � ����������� ��������');
      sStore:= IntToStr(Contract.MainStorage);

      OrdIBD:= cntsORD.GetFreeCnt;
      try
        OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
                                    //---------------------- ������� ����� �����
        prCreateNewOrderCommonOrd(UserId, FirmID, NewOrderID, ContID, ErrMess, ThreadData.ID, OrdIBS);
        if (ErrMess<>'') then raise EBOBError.Create(ErrMess);
        ErrMess:= '������ ������ ��������� ������';
        if (NewOrderID<1) then raise EBOBError.Create(ErrMess);

        Curr:= Cache.Contracts[contID].DutyCurrency;
        OrderCode:= IntToStr(NewOrderID);

        with OrdIBS.Transaction do if not InTransaction then StartTransaction;
        OrdIBS.SQL.Text:= 'select ORDRNUM from ORDERSREESTR where ORDRCODE='+OrderCode;
        OrdIBS.ExecQuery;
        if (OrdIBS.Bof and OrdIBS.Eof) then raise EBOBError.Create(ErrMess);
        ORDRNUM:= OrdIBS.FieldByName('ORDRNUM').AsString;
        OrdIBS.Close;
        fnSetTransParams(OrdIBS.Transaction, tpWrite);
        OrdIBS.ParamCheck:= False;

        //-------------------------------------- ������� ������ ������� ��� ������
        for i:= 1 to High(Cache.arWareInfo) do if Assigned(Cache.arWareInfo[i]) then begin
          Ware:= Cache.arWareInfo[i];
          if not ware.IsWare or (ware=NoWare)              // ����� �� �������
            or ware.IsArchive or (ware.PgrID<1)            // ����� �� ����������
            or ware.IsPrize or ware.IsINFOgr               // ����� ������, ����-�������
            or (ware.PgrID=Cache.pgrDeliv)                 // ����� ��������
            or (ware.WareState=cWStateInfo) then Continue; // ����� ������������

          if (lstW.Capacity=lstW.Count) then lstW.Capacity:= lstW.Capacity+1000;
          lstW.AddObject(ware.Name, Pointer(i));
        end;
        lstW.Sort;
        lstW.Sorted:= True;

        AddXmlBookBegin(lstOut);                 //---------------- ����� ������
        AddXmlSheetBegin(lstOut, '������ ������', Ncolumns, Widths);
        AddStr(sBoldCell('������ ������� � ����� '+ORDRNUM));
        AddStr(sHeadCell('������������')+sHeadCell('���-��')+
               sHeadCell('�����')+sHeadCell('����������'));

        for i:= 1 to iCount do try //------------------- ��������� ������ ������
          StrIN:= trim(Stream.ReadStr);
          wName:= StrIN;
          sQty:= '0';
          sQty1:= '0';
          //--------------------------------------------------- ��������� ������
          ErrMess:= '������������ �������� ���-��';
          pos1:= pos(#9, StrIN);
          if (pos1<1) then raise Exception.Create(ErrMess); // �� ����� 2-� �������

          wName:= copy(StrIN, 1, pos1-1); // ����� - ������������
          DivMess:= copy(StrIN, pos1+1);
          pos2:= pos(#9, DivMess);
          if (pos2<1) then sQty:= DivMess else sQty:= copy(DivMess, 1, pos2-1);
          sQty:= fnDelEndOfStr(sQty);   // ������ ��.���-��
          Qty:= StrToFloatDef(sQty, 0);
          if not fnNotZero(Qty) then raise Exception.Create(ErrMess); // ������������ ���-��

          //------------------------------------------- ��������� ������ �������
          pos1:= lstORD.IndexOf(wName);
          if (pos1>-1) then
            raise Exception.Create('�������� ������, �������� ���-�� � ������');

          //--------------------------------------------------------- ���� �����
          ErrMess:= '����� �� ������ ��� ����������';
          pos1:= lstW.IndexOf(wName);
          if (pos1<0) then raise Exception.Create(ErrMess); // �� ����� � ���������

          pos2:= Integer(lstW.Objects[pos1]);
          Ware:= Cache.arWareInfo[pos2];
          sWare:= IntToStr(ware.ID); // ������ ���� ������
          Price:= Ware.SellingPrice(FirmID, Curr, contID);
          if not fnNotZero(Price) then raise Exception.Create(ErrMess); // ��� ����

          DivMess:= fnRecaclQtyByDivisible(Ware.ID, Qty); // ��������� ���������
          sQty1:= FloatToStr(RoundTo(Qty, -3)); // ������ �������������� ���-��
          sQty2:= StringReplace(sQty1, ',', '.', [rfReplaceAll]);
          sPrice:= StringReplace(FloatToStr(Price), ',', '.', [rfReplaceAll]);
{          OrdIBS.SQL.Text:= 'execute block as declare variable xCode integer; begin'#10+
            'select rNewOrderLnCode from AddOrderLineQty('+OrderCode+', '+
                    sWare+', 0, '+IntToStr(Ware.measID)+', '+sPrice+', 0, 0) into :xCode;'#10+
            'if (xCode is null or xCode<1) then exception NotCorrect "������ ������";'#10+
            'EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', '+sWare+', '+
                    sStore+', '+StringReplace(sQty1, ',', '.', [rfReplaceAll])+'); end';  }
          OrdIBS.SQL.Text:= 'execute block as declare variable xCode integer; begin'#10+
            'select rNewOrderLnCode from AddOrderLineQty('+OrderCode+', '+
            sWare+', '+sQty2+', '+IntToStr(Ware.measID)+', '+sPrice+', 0, 0) into :xCode;'#10+
            'if (xCode is null or xCode<1) then exception NotCorrect "������ ������"; end';
          ErrMess:= RepeatExecuteIBSQL(OrdIBS);
          if (ErrMess<>'') then begin                        // ������� � ���
            fnWriteToLog(ThreadData, lgmsSysError, nmProc, 'wareID='+sWare, ErrMess, '');
            raise Exception.Create('������ ������ ������');
          end;

          if (DivMess='') then ErrMess:= sCTxtCell(sQty1)+sTxtCell('��������')
          else begin
            ErrMess:= sCBoldCell(sQty1)+sTxtGreenCell('��������, '+DivMess);
            Inc(DivCount);
          end;
          AddStr(sTxtCell(wName)+sCTxtCell(sQty)+ErrMess);

          lstOrd.Add(wName);
          Inc(AddCount);
        except
          on E: EBOBError do raise EBOBError.Create(E.Message); // ��������� ������
          on E: Exception do begin                              // ������ � ������
              AddStr(sTxtCell(wName)+sCTxtCell(sQty)+sCBoldCell('0')+sTxtYellowCell(E.Message));
              Inc(ErrCount);
            end;
        end; // for i:= 1 to iCount
      finally
        prFreeIBSQL(OrdIBS);
        cntsORD.SetFreeCnt(OrdIBD);
      end;
      AddXmlSheetEnd(lstOut, 0, 0);
      AddXmlBookEnd(lstOut); // ����� �����

// -------------------------------------------------------------- �������� � CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);  // ������� - ������ ��������� ���������
      Stream.WriteInt(NewOrderID); // ��� ������ ������
      Stream.WriteInt(ContID);     // ��� ���������

      sParam:= sParam+#13#10'NewOrderID='+OrderCode+#13#10'NewOrderNum='+ORDRNUM; // ����������� ������ ������

      FName:= GetAppExePath+fnTestDirEnd(DirMailFiles)+'imp_ord'; // ����� ��� ������
      if not DirectoryExists(FName) then CreateDir(FName); // ���� ��� - �������

      FName:= fnTestDirEnd(FName)+'imp_ord_'+ORDRNUM+'_'+FormatDateTime('yyyymmdd_hhnnss', Now());
      zipName:= FName+'.zip';
      FName:= FName+'.xml';
      SaveListToFile(lstOut, FName);    // ���������� ����� � ���� xml

      ErrMess:= ZipAddFiles(zipName, FName); // ������ � zip
      if (ErrMess<>'') then begin
        fnWriteToLog(ThreadData, lgmsSysError, nmProc, 'ZipAddFiles', ErrMess, '');
      end;
      sleep(10);
      SysUtils.DeleteFile(FName);       // ������� xml

      Stream1:= TBoBMemoryStream.Create;
      try
        Stream1.LoadFromFile(zipName);
                                 //-------------- �������� ���� � �������
        Stream.WriteStr(ZipContentType);       // ��� �����
        Stream.WriteStr(ExtractFileName(zipName));         // ��� �����
        Stream.WriteInt(Stream1.Size);         // ������
        Stream.CopyFrom(Stream1, 0);           // ����
      finally
        prFree(Stream1);
      end;
      sParam:= sParam+#13#10'SendFile= true'; // ����������� �������� �����

      //--------------------------------------------------------- ������ �������
      ErrMess:= ExtractFictiveEmail(Client.Mail);
      if (ErrMess='') then
        sParam:= sParam+#13#10'SendMail= email not found' // ����������� ���������� email
      else begin
        lstW.Clear; // ����� ������
        lstW.Sorted:= False;
        lstW.Add('���������� ������� ������� � ����� '+ORDRNUM+':');
        lstW.Add('--- ������� - '+IntToStr(iCount));
        lstW.Add('--- ��������� � ����� - '+IntToStr(AddCount));
        if (DivCount>0) then lstW.Add('--- ����������� ���-�� - '+IntToStr(DivCount));
        if (ErrCount>0) then lstW.Add('--- �������� - '+IntToStr(ErrCount));
        lstW.Add('��������� ��. � ����������� �����');

        lstOrd.Clear; // ����������
        lstOrd.Sorted:= False;
        lstOrd.Add(zipName);

        ErrMess:= n_SysMailSend(ErrMess, '������ ������� � ����� '+ORDRNUM,
                                lstW, lstOrd, cNoReplayEmail, '', true);
                                        // ���� �� �������� � ���� ��� ��������
        if (ErrMess<>'') and (Pos(MessText(mtkErrMailToFile), ErrMess)>0) then begin
          fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', ErrMess, '');
          sParam:= sParam+#13#10'SendMail= false'
        end else sParam:= sParam+#13#10'SendMail= true'; // ����������� �������� ������
      end;
    finally
      prSetThLogParams(ThreadData, csOrderImport, UserID, FirmID, sParam); // �����������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(lstOrd);
  prFree(lstOut);
  prFree(lstW);
end;
//*******************************************************************************
procedure prJoinMarkedOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prJoinMarkedOrdersOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    FirmID, UserID, i, j: integer;
    s, ErrorMessage: string;
    codes: Tai;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  setLength(codes, 100);
  try
    UserID:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    Stream.ReadInt;       // ContID
    s:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csJoinMarkedOrders, UserID, FirmID, 'Orders='+s); // �����������

    if s='' then  raise EBOBError.Create(MessText(mtkNotFoundOrders));
    if CheckNotValidUser(UserID, FirmID, ErrorMessage) then raise EBOBError.Create(ErrorMessage);

    OrdIBD:= cntsORD.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      OrdIBS.SQL.Text:= 'select ORDRCODE, ORDRSTATUS FROM ORDERSREESTR'+
        ' WHERE ORDRFIRM='+IntToStr(FirmID)+' and ORDRCODE in ('+s+')'+
        ' and ORDRCURRENCY<>'+IntToStr(Cache.BonusCrncCode); // ���������� �������� ������
      OrdIBS.ExecQuery;
      j:= 0; // �������
      while not OrdIBS.Eof do begin
        if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming) then
          raise EBOBError.Create(MessText(mtkOnlyFormingOrd));
        i:= OrdIBS.FieldByName('ORDRCODE').AsInteger;
        if Length(codes)<(i+1) then setLength(codes, i+100);
        codes[j]:= i;
        inc(j);
        TestCssStopException;
        OrdIBS.Next;
      end;
      OrdIBS.Close;

      Stream.Position:= 0;
      prCreateOrderByMarkedOrd(Stream, ThreadData);

      Stream.Position:= 0;
      if Stream.ReadInt=aeSuccess then begin
        if (j<1) then Exit;

        fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
        OrdIBS.SQL.Text:= 'execute procedure DelOrder(:CODE)';
        OrdIBS.Prepare;
        for i:= 0 to j-1 do try
          with OrdIBS.Transaction do if not InTransaction then StartTransaction;
          OrdIBS.ParamByName('CODE').AsInteger:= codes[i];
          OrdIBS.ExecQuery;
          OrdIBS.Close;
          OrdIBS.Transaction.Commit;
        except
          on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc,
            'can not delete order '+IntToStr(codes[i]), E.Message, '');
        end;
      end;
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(OrdIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  setLength(codes, 0);
  Stream.Position:= 0;
end;
//======================================= �������� ������ �������������� �������
procedure prGetFormingOrdersList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFormingOrdersList'; // ��� ���������/�������
type RorderOpts = record
  ordID, contID, currID: Integer;
  contName, ordNum, comm, strDate, strSum, OverMess: String;
end;
var i, ii, UserId, FirmID, iCount, WareCount: integer;
    s, sMess, OverMessAll: string;
    OrdIBS, ibs: TIBSQL;
    OrdIBD, ibd: TIBDatabase;
    Client: TClientInfo;
    Contract: TContract;
    fl, flResLimit{, flCheckRes}: Boolean;
    arOpts: array of RorderOpts;
    sum: Double;
    firma: TFirmInfo;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  IBS:= nil;
  IBD:= nil;
  Contract:= nil;
  SetLength(arOpts, FormingOrdersLimit);
  sMess:= '';
  OverMessAll:= '';
//  flResLimit:= False;
//  flCheckRes:= False;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetFormingOrdersList, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    Client:= Cache.arClientInfo[UserID];
    firma:= Cache.arFirmInfo[FirmID];

    if (firma.ResLimit=0) then OverMessAll:= '�������������� �������������';
    flResLimit:= (firma.ResLimit>0);
//    flCheckRes:= flResLimit;
    if flResLimit then begin
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead);
    end;

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRDATE, ORDRNUM, ORDRSUMORDER,'+
      ' ORDRCURRENCY, ORDRCONTRACT, ORDRSELFCOMMENT, OrdrWareLineCount'+
      ' from ORDERSREESTR where ORDRFIRM='+IntToStr(FirmID)+
      '   and ORDRSTATUS='+IntToStr(orstForming)+
      '   and ORDRCURRENCY<>'+IntToStr(Cache.BonusCrncCode)+ // ��� ��������� ������
      ' order by ORDRCODE desc'; // ������� � ���������
    OrdIBS.ExecQuery;

    iCount:= 0;
    s:= '';
    while not OrdIBS.EOF do begin
      ii:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
      //------------------------------- ������ �� ����������
      s:= '';
      fl:= (ii>0) and Client.CheckContract(ii);
      if fl then begin
        Contract:= Client.GetCliContract(ii);
        fl:= (Contract.ID=ii) and (Contract.Status<>cstClosed);
      end;
      if fl and Client.DocsByCurrContr then // ������ ������ �� ��������
        fl:= (ii=Client.GetCliCurrContID);
      if fl then s:= Contract.Name
      else begin
        OrdIBS.Next;                              // - ����������
        Continue;
      end;

      if (iCount>High(arOpts)) then begin
        sMess:= '������� ����� �������������� �������, �������� ��������� '+IntToStr(iCount);
        break;
      end;
      sum:= OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;

      arOpts[iCount].contID:= ii;
      arOpts[iCount].contName:= s;
      arOpts[iCount].ordID:= OrdIBS.FieldByName('ORDRCODE').AsInteger;
      arOpts[iCount].currID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
      arOpts[iCount].strDate:= FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime);
      arOpts[iCount].ordNum:= OrdIBS.FieldByName('ORDRNUM').AsString;
      arOpts[iCount].strSum:= FormatFloat(cFloatFormatSumm, sum);
      arOpts[iCount].comm:= OrdIBS.FieldByName('ORDRSELFCOMMENT').AsString;
      arOpts[iCount].OverMess:= OverMessAll;

      if flResLimit and fnNotZero(sum) then begin
        WareCount:= OrdIBS.FieldByName('OrdrWareLineCount').AsInteger;
//          if flCheckRes then begin
//            firma.CheckReserveLimit; // ��������� ����� 1 ��� �� 1-� ������  ???
//            flCheckRes:= False;
//          end;
                                       // �������� ���������� ������ ������� �/�
        arOpts[iCount].OverMess:= CheckOrdWaresExAndOverLimit(FirmID, UserID, ii,
           arOpts[iCount].ordID, arOpts[iCount].CurrID, True, False, (WareCount<2), ibs)
      end; // if flResLimit

      TestCssStopException;
      OrdIBS.Next;
      Inc(iCount);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(sMess); // ���������
    Stream.WriteInt(iCount);    // ���-�� �����
    for i:= iCount-1 downto 0 do begin // ������ ������� �� ������������
      Stream.WriteInt(arOpts[i].ordID);
      Stream.WriteInt(arOpts[i].contID);   // ��� ���������
      Stream.WriteStr(arOpts[i].contName); // ������� ����� ��������� ��� �����, ���� �����������
      Stream.WriteStr(arOpts[i].strDate);
      Stream.WriteStr(arOpts[i].ordNum);
      Stream.WriteStr(arOpts[i].OverMess);
      Stream.WriteStr(arOpts[i].strSum);
      Stream.WriteStr(Cache.GetCurrName(arOpts[i].currID, True));
      Stream.WriteStr(arOpts[i].comm); // ������ �����������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  SetLength(arOpts, 0);
  Stream.Position:= 0;
end;
//*******************************************************************************
procedure prGetOrderListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetOrderListOrd'; // ��� ���������/�������
var i, ii, UserId, FirmID, Status, sPos, ContID, currID, OrderID, WareCount: integer;
    Accounts, Invoices: TDocRecArr;
    s, err, SortOrder, SortDesc, stat, dat, ss, sParam, OverMess, OverMessAll, ErrMess: string;
    DateStart, DateFinish, TestDate, OrdProcDate: TDateTime;
    OrdIBS, ibs: TIBSQL;
    OrdIBD, ibd: TIBDatabase;
    Firm: TFirmInfo;
    Client: TClientInfo;
    Contract: TContract;
    sum: Double;
    {flCheckRes,} flResLimit, flErrMess, flCreateFilter: Boolean;
begin
  Stream.Position:= 0;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  OrdIBS:= nil;
  OrdIBD:= nil;
  IBS:= nil;
  IBD:= nil;
  ContID:= 0;
  sParam:= '';
  DateStart:= 0;
  DateFinish:= 0;
  Client:= nil;
  Firm:= nil;
  flResLimit:= False;
  OverMessAll:= '';
  ErrMess:= '';
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    flErrMess:= (OrderListLimit>0);
    try
      if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
      Firm:= Cache.arFirmInfo[FirmID];
      Client:= Cache.arClientInfo[UserID];
      Contract:= Client.GetCliContract(ContID);

      if (firm.ResLimit=0) then OverMessAll:= '�������������� �������������';
      flResLimit:= (firm.ResLimit>0);
//      flCheckRes:= flResLimit;

      stat:= '';  // �������� ��������
      if Stream.ReadByte=1 then stat:= stat+fnIfStr(stat='', '', ',')+IntToStr(orstForming);
      if Stream.ReadByte=1 then stat:= stat+fnIfStr(stat='', '', ',')+IntToStr(orstClosed);
      if Stream.ReadByte=1 then stat:= stat+fnIfStr(stat='', '', ',')+IntToStr(orstProcessing);
      if Stream.ReadByte=1 then stat:= stat+fnIfStr(stat='', '', ',')+IntToStr(orstAnnulated);
      if Stream.ReadByte=1 then stat:= stat+fnIfStr(stat='', '', ',')+IntToStr(orstAccepted);
      DateStart:= Stream.ReadDouble;
      DateFinish:= Stream.ReadDouble;
      SortOrder:= Stream.ReadStr;
      SortDesc:= Stream.ReadStr;
      sParam:= 'Statuses='+stat+
        #13#10'DateStart='+FormatDateTime(cDateFormatY2, DateStart)+
        #13#10'DateFinish='+FormatDateTime(cDateFormatY2, DateFinish)+
        #13#10'SortOrder='+SortOrder+#13#10'SortDesc='+SortDesc;
    finally
      prSetThLogParams(ThreadData, csGetOrderList, UserID, FirmID, sParam); // �����������
    end;

    TestDate:= IncYear(Date, -5);
    dat:= ''; // ������ �� ����
    DateFinish:= DateFinish+1;
    if (DateStart>TestDate)  then dat:= dat+' AND ORDRDATE>=:DATESTART';
    if (DateFinish>TestDate) then dat:= dat+' AND ORDRDATE<=:DATEFINISH';

    s:= ' ORDER BY '+SortOrder+' '+SortDesc+', ORDRDATE '+SortDesc+', ORDRNUM '+SortDesc;

    ss:= 'SELECT ORDRSTATUS, ORDRCODE, ORDRDATE, ORDRNUM, ORDRSUMORDER, ORDRCURRENCY,'+
         ' ORDRTOPROCESSDATE, ORDRCONTRACT, ORDRSELFCOMMENT, OrdrWareLineCount'+
         ' from ORDERSREESTR where ORDRFIRM='+IntToStr(FirmID);

    flCreateFilter:= (stat='') and (dat='');
    if flCreateFilter then begin // ���� ������� �� ������
      flErrMess:= False;
      ss:= ss+' and (ORDRSTATUS<'+IntToStr(orstClosed)+
              ' or (ORDRSTATUS='+IntToStr(orstClosed)+' and (("TODAY"-ORDRDATE)<7)))';
    end else ss:= ss+' AND ORDRSTATUS'+
                 fnIfStr(stat='', '<>'+IntToStr(orstDeleted), ' in ('+stat+')')+dat;
    if Firm.IsFinalClient then ss:= ss+' and ORDRCURRENCY<>'+IntToStr(Cache.BonusCrncCode);

    if flResLimit then begin
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead);
    end;

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= ss+s;
    if DateStart>TestDate  then OrdIBS.paramByName('DATESTART').AsDateTime:= DateStart;
    if DateFinish>TestDate then OrdIBS.paramByName('DATEFINISH').AsDateTime:= DateFinish;
    OrdIBS.ExecQuery;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    sPos:= Stream.Position;
    Stream.WriteInt(0); // �������� ����� ��� ���-�� �����
    i:= 0;
    while not OrdIBS.EOF do begin
      ii:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
      currID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
//      if Firm.IsFinalClient and (currID=Cache.BonusCrncCode) then begin
//        OrdIBS.Next;                              // ����������
//        Continue;
//      end;
      //------------------------------- ������ �� ����������
      if (ii<1) then s:= ''                       // �������� �����������
      else if (ii=ContID) then s:= Contract.Name  // ������� ��������
      else if //(currID<>Cache.BonusCrncCode) and   // ���� ������� ����� �
        (Client.DocsByCurrContr or                   // ������ ������ �� ��������
        not Client.CheckContract(ii)) then begin     // ��� �������� ����������
        OrdIBS.Next;                              // - ����������
        Continue;
      end else s:= firm.GetContract(ii).Name;

      SetLength(Accounts, 0);
      SetLength(Invoices, 0);
      OrderID:= OrdIBS.FieldByName('ORDRCODE').AsInteger;
      Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;
      if ((Status>orstProcessing) and (Status<orstAnnulated)) then begin
        err:= fnGetClosingDocsOrd(IntToStr(OrderID), Accounts, Invoices, Status, ThreadData.ID);
        if (err<>'') then raise Exception.Create(err);
      end;
      OrdProcDate:= OrdIBS.FieldByName('ORDRTOPROCESSDATE').AsDateTime;
      sum:= OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;

      Stream.WriteInt(Length(Accounts));
      Stream.WriteInt(OrderID);
      Stream.WriteInt(ii); // ��� ���������
      Stream.WriteStr(s);  // ������� ����� ��������� ��� �����, ���� �����������
      Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
      Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
      OverMess:= '';

      if (Status=orstForming) and fnNotZero(sum) then begin // ������������� ����� ��������
        if flResLimit then begin
//          if flCheckRes then begin
  //          firm.CheckReserveLimit; // ��������� ����� 1 ��� �� 1-� ������ ???
//            flCheckRes:= False;
//          end;
          WareCount:= OrdIBS.FieldByName('OrdrWareLineCount').AsInteger;
                                       // �������� ���������� ������ ������� �/�
          OverMess:= CheckOrdWaresExAndOverLimit(FirmID, UserID, ii, OrderID,
                     CurrID, flResLimit, False, (WareCount<2), ibs);
        end else OverMess:= OverMessAll;
      end; // if (Status=orstForming)
      Stream.WriteStr(OverMess);

      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));
      Stream.WriteStr(Cache.GetCurrName(currID, True));
      Stream.WriteStr(arOrderStatusNames[Status]);
      if (Status<>orstProcessing) then s:= ''
      else s:= ' � '+FormatDateTime(cDateTimeFormatTnD, OrdProcDate);
      Stream.WriteStr(s);
      Stream.WriteStr(FormatDateTime(cDateTimeFormatY2N, OrdProcDate));
      for ii:= Low(Accounts) to High(Accounts) do begin
        if Invoices[ii].Number='' then begin
          Stream.WriteByte(fnIfInt(Accounts[ii].Processed, byte('t'), byte('f'))); // �.�. ���� f -���� �����., ���� t-  ���., ���� ������ - ���������
          Stream.WriteStr(fnGetGBDocName(docAccount)+fnIfStr(Accounts[ii].Processed, cWebProcessed, ''));
          Stream.WriteStr(IntToStr(docAccount));
          Stream.WriteStr(IntToStr(Accounts[ii].ID));
          Stream.WriteStr(Cache.GetDprtMainName(Accounts[ii].DprtID));
          Stream.WriteStr(Accounts[ii].Number);
          Stream.WriteStr(Accounts[ii].Commentary);
          Stream.WriteStr(FormatFloat(cFloatFormatSumm, Accounts[ii].Summa));
          Stream.WriteStr(Accounts[ii].CurrencyName);
          Stream.WriteStr(FormatDateTime(cDateFormatY2, Accounts[ii].Data));
        end else begin
          Stream.WriteByte(0);//
          Stream.WriteStr(fnGetGBDocName(docInvoice));
          Stream.WriteStr(IntToStr(docInvoice));
          Stream.WriteStr(IntToStr(Invoices[ii].ID));
          Stream.WriteStr(Cache.GetDprtMainName(Invoices[ii].DprtID));
          Stream.WriteStr(Invoices[ii].Number);
          Stream.WriteStr(Accounts[ii].Commentary);
          Stream.WriteStr(FormatFloat(cFloatFormatSumm, Invoices[ii].Summa));
          Stream.WriteStr(Invoices[ii].CurrencyName);
          Stream.WriteStr(FormatDateTime(cDateFormatY2, Invoices[ii].Data));
        end;
      end;
      Stream.WriteStr(OrdIBS.FieldByName('ORDRSELFCOMMENT').AsString); // ������ �����������
      TestCssStopException;
      OrdIBS.Next;
      Inc(i);

      if flErrMess and (i>OrderListLimit) then begin // ������ �� ��������� ��� ������� ���-�� �������
        ErrMess:= '������� ����� �������, �������� ������ '+
          IntToStr(OrderListLimit)+'. �������� ��������� �������.';
        break;
      end;
    end;
    Stream.WriteStr(ErrMess);  // ��������� - ��������������
    if (i>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(i); // �������� ���-�� �����
    end;
    Stream.Position:= Stream.Size;

    Stream.WriteBool(Firm.EnableOrderImport); // ���������� �������� �������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
end;
//************************************************** �������� ������ - 2 �������
procedure prShowOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, Status, i, j, spos, LineCount, contID, MainStore,
      DestID, ShipTableID, DelivType, ShipMetID, ShipTimeID, currID, accType: integer;
    OrderCode, err, s, s1, sLine, sStore, sDestName, sDestAdr,
      sArrive, sShipMet, sShipTime, sShipView, OverMess, ordNum: string;
    Accounts, Invoices: TDocRecArr;
    Storages: TaSD;
    Ware: TWareInfo;
    HasAnalogs, GBdirection, flResLimit: Boolean;
    qty, qtyM, price, bonus, totalbonus, ShipDate, sum, LineSum, OverSumm: Double;
    arlstSQL: TASL;
    Contract: TContract;
    Client: TClientInfo;
    firma: TFirmInfo;
begin
  Stream.Position:= 0;
  totalbonus:= 0;
  OrdIBS:= nil;
//  OrdIBD:= nil;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  SetLength(arlstSQL, 1);
  arlstSQL[0]:= TStringList.Create;
  contID:= 0;
  sPos:= 0;
  LineCount:= 0;            // ������� - ���-�� �����
  GBdirection:= False;
  OverMess:= '';
//  flResLimit:= False;
  OverSumm:= 0;
  LineSum:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;
    GBdirection:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csShowOrder, UserID, FirmID,
      'OrderCode='+OrderCode+#13#10'ContID='+IntToStr(ContID)); // �����������

    i:= StrToIntDef(OrderCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    Client:= Cache.arClientInfo[UserID];
    Contract:= Client.GetCliContract(contID);
    MainStore:= Contract.MainStorage;

    OrdIBD:= cntsORD.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      OrdIBS.SQL.Text:= 'SELECT  ORDRSTATUS, ORDRNUM, ORDRGBACCNUMBER, ORDRDATE,'+
        ' ORDRSUMORDER, ORDRCURRENCY, ORDRACCOUNTINGTYPE, ORDRDELIVERYTYPE,'+
        ' ORDRTOPROCESSDATE, ORDRCREATORPERSON, ORDRTOPROCESSPerson, ORDRWARRANT,'+
        ' ORDRWARRANTDATE, ORDRWARRANTPERSON, ORDRSTORAGECOMMENT, ORDRSELFCOMMENT,'+
        ' ORDRDESTPOINT, ORDRSHIPDATE, ORDRTIMETIBLE, ORDRSHIPMETHOD, ORDRSHIPTIMEID,'+
        ' ORDRANNULATEDATE, ORDRANNULATEREASON, ORDRCONTRACT'+
        fnIfStr(flMeetPerson, ', ordrAccMeetText', '')+
        ' from ORDERSREESTR where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId);
      OrdIBS.ExecQuery;
      if OrdIBS.Bof and OrdIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

      currID:= OrdIBS.FieldByName('ORDRCURRENCY').asInteger;
      Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;

      if (currID=Cache.BonusCrncCode) and (Status=orstForming) then // unit-����� �����������
        raise Exception.Create('������������ ������� ��������� unit-������ �� �������� "�����������"');

      if ((Status>orstProcessing) and (Status<orstAnnulated)) then begin
        err:= fnGetClosingDocsOrd(OrderCode, Accounts, Invoices, Status, ThreadData.ID);
        if (err<>'') then raise Exception.Create(err);
      end;

      if (OrdIBS.FieldByName('ORDRCONTRACT').AsInteger<1) then begin
        arlstSQL[0].Add('update ORDERSREESTR set ORDRCONTRACT='+IntToStr(contID));
        arlstSQL[0].Add(' where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId)+';');
      end else if (contID<>OrdIBS.FieldByName('ORDRCONTRACT').AsInteger) then
         raise EBOBError.Create('����� �� ������������� �������� ���������');

      accType:= OrdIBS.FieldByName('ORDRACCOUNTINGTYPE').AsInteger;
      if (Contract.PayType<>accType) then begin
        accType:= Contract.PayType;
        arlstSQL[0].Add('update ORDERSREESTR set ORDRACCOUNTINGTYPE='+IntToStr(accType));
        arlstSQL[0].Add(' where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId)+';');
      end;

      DelivType:= OrdIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger;
      if flNotReserve and (DelivType=cDelivReserve) and (Status=orstForming) then
        DelivType:= cDelivTimeTable;
      DestID:= OrdIBS.FieldByName('ORDRDESTPOINT').AsInteger;
      ShipTableID:= OrdIBS.FieldByName('ORDRTIMETIBLE').AsInteger;
      ShipDate:= OrdIBS.FieldByName('ORDRSHIPDATE').AsDateTime;
      ShipMetID:= OrdIBS.FieldByName('ORDRSHIPMETHOD').AsInteger;
      ShipTimeID:= OrdIBS.FieldByName('ORDRSHIPTIMEID').AsInteger;
      sum:= OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;
      ordNum:= OrdIBS.FieldByName('ORDRNUM').AsString;

      firma:= Cache.arFirmInfo[FirmID]; // � �������� ������� ����� �� ���������
      flResLimit:= (firma.ResLimit>=0) and (currID<>Cache.BonusCrncCode)
                   and (Status=orstForming) and fnNotZero(sum);
      if flResLimit then begin //-------------------- ��������� ����� ����������
        OverMess:= firma.GetOverSummAll(currID, OverSumm);
        flResLimit:= (OverMess='');
      end; // if flResLimit

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteStr(ordNum);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRGBACCNUMBER').AsString);
      Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));
      Stream.WriteStr(Cache.GetCurrName(currID, True));
      Stream.WriteInt(accType);
      Stream.WriteInt(DelivType);
      Stream.WriteInt(Status);
      Stream.WriteStr(arOrderStatusDecor[Status].StatusName);
      if (Status=orstProcessing) then s:= ' � '+
        FormatDateTime(cDateTimeFormatTnD, OrdIBS.FieldByName('ORDRTOPROCESSDATE').AsDateTime)
      else s:= '';
      Stream.WriteStr(s);
      Stream.WriteStr('');      // ORDRTOTALWEIGHT

      i:= OrdIBS.FieldByName('ORDRCREATORPERSON').AsInteger;
      if (i=0) or not Cache.ClientExist(i) then s:= ''
      else s:= fnCutFIO(Cache.arClientInfo[i].Name);
      Stream.WriteStr(s); // �������� ��������� ������

      j:= OrdIBS.FieldByName('ORDRTOPROCESSPerson').AsInteger;
      if (j<>i) then
        if (j=0) or not Cache.ClientExist(j) then s:= ''
        else s:= fnCutFIO(Cache.arClientInfo[j].Name);
      Stream.WriteStr(s); // �������� ����������� �� ����������

      Stream.WriteStr(BOBBoolToStr(Client.NOTREMINDCOMMENT));

      err:= fnGetShipParamsView(contID, MainStore, DestID, ShipTableID, ShipDate,
            DelivType, ShipMetID, ShipTimeID, sDestName, sDestAdr, sArrive,
            sShipMet, sShipTime, sShipView, GBdirection);
      if (err<>'') then sShipView:= '';
      Stream.WriteStr(sShipView); // �������� ������ � ����������� ��������

      Stream.WriteStr(OrdIBS.FieldByName('ORDRWARRANT').AsString);
      Stream.WriteDouble(OrdIBS.FieldByName('ORDRWARRANTDATE').AsDateTime);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRWARRANTPERSON').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRSTORAGECOMMENT').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRSELFCOMMENT').AsString);

      if (Status=orstAnnulated) then s:= '����������� '+
        FormatDateTime(cDateTimeFormatY2N, OrdIBS.FieldByName('ORDRANNULATEDATE').AsDateTime)+
        ' ������� ���������: '+OrdIBS.FieldByName('ORDRANNULATEREASON').AsString
      else s:= '';
      Stream.WriteStr(s);

if flMeetPerson then
      Stream.WriteStr(trim(OrdIBS.FieldByName('ordrAccMeetText').AsString)); // �����������

      OrdIBS.Close;
      s:= '';
      s1:= '';
      sStore:= '';
      if (Status=orstForming) then begin // ���� ����� �� ������ ������������
        Storages:= fnGetStoragesArray_2col(Contract, true, True);
        prSendStorages(Storages, Stream);
      end;

      sPos:= Stream.Position;
      Stream.WriteInt(0); //  ����� ��� ���-�� �����

      OrdIBS.SQL.Text:= 'SELECT ORDRLNWARE, ORDRLNCODE, ORDRLNCLIENTQTY, ORDRLNPRICE'+
        ' FROM ORDERSLINES where ORDRLNORDER='+OrderCode+' order by ORDRLNCODE';
      OrdIBS.ExecQuery;
      sum:= 0;
      while not OrdIBS.EOF do begin
        i:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
        qty:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
        price:= OrdIBS.FieldByName('ORDRLNPRICE').AsFloat;

        Ware:= Cache.GetWare(i);
        if not Assigned(Ware) or (Ware=NoWare) then
          raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));
        Stream.WriteInt(OrdIBS.FieldByName('ORDRLNCODE').AsInteger);
        Stream.WriteStr(OrdIBS.FieldByName('ORDRLNWARE').AsString);

        if (currID=Cache.BonusCrncCode) then HasAnalogs:= False // unit-�����
        else HasAnalogs:= (ware.AnalogLinks.LinkCount>0);       // ������� �����
        Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));

        Stream.WriteStr(Ware.WareBrandName);
        Stream.WriteStr(Ware.Name);
        Stream.WriteDouble(qty);

        if (Status=orstForming) then                 // ���� ����� �� ������ ������������ -
          Stream.WriteStr(trim(FormatFloat('###0.#', qty))); // �������� ������� ���-�� ������

        Stream.WriteStr(Ware.MeasName);
        s:= FormatFloat(cFloatFormatSumm, price);                                   // ����
        Stream.WriteStr(s);
        Stream.WriteStr(FormatFloat(cFloatFormatSumm, RoundToHalfDown(price*qty))); // ����� �� ������

        if (currID=Cache.BonusCrncCode) then begin // unit-�����
          s:= '';
          bonus:= 0;
        end else begin                             // ������� �����
          // ����� s ��������
          bonus:= price*qty*Cache.GetPriceBonusCoeff(currID);
        end;
        Stream.WriteStr(s); // ���� ������ � �������� (% � ���������) ��� �������

        s:= trim(FormatFloat(cFloatFormatSumm, bonus));
        Stream.WriteStr(s); // �����
        totalbonus:= totalbonus+bonus;

        if flResLimit then begin
          price:= Ware.SellingPrice(FirmID, CurrID, contID);
          LineSum:= price*qty;
          sum:= sum+LineSum;
        end; // if flResLimit

        inc(LineCount);
        TestCssStopException;
        OrdIBS.Next;
      end; // while not OrdIBS.EOF
      OrdIBS.Close;

      if flResLimit then  //---------------- ��������� ��������� ����������
        OverMess:= GetOrderOverSummMess(currID, OverSumm, Sum, LineSum);

      s:= trim(FormatFloat(cFloatFormatSumm, totalbonus)); // �����
      Stream.WriteStr(s);

      if (arlstSQL[0].Count>0) then begin // ���������� ���-�� �� ������� �����, ������ ���� ���������
        fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
        for j:= 0 to High(arlstSQL) do
        if (arlstSQL[j].Count>0) then begin
          arlstSQL[j].Insert(0, 'execute block as begin');
          arlstSQL[j].Add('end');
          OrdIBS.SQL.Clear;
          OrdIBS.SQL.AddStrings(arlstSQL[j]);
          OrdIBS.ExecQuery;
        end;
        OrdIBS.Transaction.Commit;
      end;
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(OrdIBD);
    end;

    Stream.Position:= sPos;
    Stream.WriteInt(LineCount); // ���-�� �����
    Stream.Position:= Stream.Size;

    Stream.WriteInt(Length(Accounts));
    for i:= Low(Accounts) to High(Accounts) do begin
      Stream.WriteInt(Accounts[i].ID);
      if Accounts[i].ID>0 then with Accounts[i] do begin
                  // ���� f -���� �����., ���� t-  ���., ���� ������ - ���������
        Stream.WriteByte(fnIfInt(Accounts[i].Processed, byte('t'), byte('f')));
        Stream.WriteStr(Cache.GetDprtMainName(DprtID));
        Stream.WriteStr(Number+cWebSpace+fnIfStr(Accounts[i].Processed, cWebProcessed, ''));
        Stream.WriteStr(Commentary);
        Stream.WriteDouble(Data);
        Stream.WriteDouble(Summa);
        Stream.WriteStr(CurrencyName);
      end;
      Stream.WriteInt(Invoices[i].ID);
      if Invoices[i].ID>0 then with Invoices[i] do begin
        Stream.WriteStr(Cache.GetDprtMainName(DprtID));
        Stream.WriteStr(Number);
        Stream.WriteDouble(Data);
        Stream.WriteDouble(Summa);
        Stream.WriteStr(CurrencyName);
      end;
    end;

    Stream.WriteStr(OverMess); // ��������� � ���������� ������
//if flDebug and (OverMess<>'') then prMessageLOGS(' firm= '+IntToStr(firmID)+
//  ', ordnum= '+OrdNUM+'- mess= '+OverMess, fLogDebug, False);

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
//  SetLength(anw, 0);
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  SetLength(Storages, 0);
  for i:= 0 to High(arlstSQL) do prFree(arlstSQL[i]);
  SetLength(arlstSQL, 0);
end;
//*******************************************************************************
procedure prShowACOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowACOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, Status, spos, LineCount, i, DelivType, contID, currID, currTo: integer;
    OrderCode, AccType, s, CurrName: string;
    CoeffCurr, sum: Double;
    Ware: TWareInfo;
    HasAnalogs: Boolean;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csShowACOrder, UserID, FirmID,
      'OrderID='+OrderCode+#13#10'ContID='+IntToStr(ContID)); // �����������

    spos:= StrToIntDef(OrderCode, 0);
    if (spos<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRNUM, ORDRACCOUNTINGTYPE, ORDRGBACCNUMBER,'+
      ' ORDRDATE, ORDRSUMORDER, ORDRDELIVERYTYPE, ORDRSTATUS, ORDRTOPROCESSDATE,'+
      ' ORDRANNULATEDATE, ORDRANNULATEREASON, ORDRCONTRACT, ORDRCURRENCY'+
      fnIfStr(flMeetPerson, ', ordrAccMeetText', '')+
      ' from ORDERSREESTR where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

    if (OrdIBS.FieldByName('ORDRCONTRACT').AsInteger>0) and
      (contID<>OrdIBS.FieldByName('ORDRCONTRACT').AsInteger) then
      raise EBOBError.Create('����� �� ������������� �������� ���������');

    AccType:= OrdIBS.FieldByName('ORDRACCOUNTINGTYPE').AsString;
    // ���������� �������������� ������ ��������� ������ � �����.��������� ����
    currID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;

    if (currID=cUAHCurrency) then begin  // ��� -> ������
      currTo:= cDefCurrency;
      CoeffCurr:= Cache.Currencies.GetCurrRate(currTo); // ���� � ������ �������.������
      if fnNotZero(Coeffcurr) then CoeffCurr:= 1/CoeffCurr;
    end else begin                       // ������ -> ���
      CoeffCurr:= Cache.Currencies.GetCurrRate(currID); // ���� � ������ ������ ������
      currTo:= cUAHCurrency;
    end;
    CurrName:= Cache.GetCurrName(currTo, True); // ������������ �������.������
    sum:= RoundToHalfDown(OrdIBS.FieldByName('ORDRSUMORDER').AsFloat*CoeffCurr);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
    Stream.WriteStr(OrdIBS.FieldByName('ORDRGBACCNUMBER').AsString); // ���������� ����� ����� �� ������
    Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
    Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));
    Stream.WriteStr(CurrName);
    Stream.WriteStr(AccType);

    Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;
    DelivType:= OrdIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger;
    if flNotReserve and (DelivType=cDelivReserve) and (Status=orstForming) then
      DelivType:= cDelivTimeTable;

    Stream.WriteInt(DelivType);
    Stream.WriteInt(Status);
    Stream.WriteStr(arOrderStatusDecor[Status].StatusName);
    if Status=orstProcessing then s:= ' � '+
      FormatDateTime(cDateTimeFormatTnD, OrdIBS.FieldByName('ORDRTOPROCESSDATE').AsDateTime)
    else s:= '';
    Stream.WriteStr(s);
    Stream.WriteStr('');       // ORDRTOTALWEIGHT

    if Status=orstAnnulated then s:= '����������� '+
      FormatDateTime(cDateTimeFormatY2N, OrdIBS.FieldByName('ORDRANNULATEDATE').AsDateTime)+
      ' ������� ���������: '+OrdIBS.FieldByName('ORDRANNULATEREASON').AsString
    else s:= '';
    Stream.WriteStr(s);

if flMeetPerson then
    Stream.WriteStr(OrdIBS.FieldByName('ordrAccMeetText').AsString); // �����������

    OrdIBS.Close;
    LineCount:= 0;      // ������� - ���-�� �����
    sPos:= Stream.Position;
    Stream.WriteInt(0); //  ����� ��� ���-�� �����
    OrdIBS.SQL.Text:= 'SELECT ORDRLNWARE, ORDRLNCODE, ORDRLNCLIENTQTY, ORDRLNPRICE'+
      ' FROM ORDERSLINES where ORDRLNORDER='+OrderCode;
    OrdIBS.ExecQuery;    //
    while not OrdIBS.EOF do begin
      i:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
      Ware:= Cache.GetWare(i);
      if not Assigned(Ware) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));

      Stream.WriteInt(OrdIBS.FieldByName('ORDRLNCODE').AsInteger);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRLNWARE').AsString);
      HasAnalogs:= (ware.AnalogLinks.LinkCount>0);
      Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteDouble(OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat);
      Stream.WriteStr(Ware.MeasName);

      sum:= RoundToHalfDown(OrdIBS.FieldByName('ORDRLNPRICE').AsFloat*CoeffCurr);
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));
      sum:= sum*OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));

      inc(LineCount);
      TestCssStopException;
      OrdIBS.Next;
    end;
    OrdIBS.Close;
    Stream.Position:= sPos;
    Stream.WriteInt(LineCount);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//**************************************************** �������� ������ �� ������
procedure prDelLineFromOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prDelLineFromOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, CurrID, ContID, OrderID, WareCount, i: integer;
    OrderCode, LineID, s, OverMess, ordNum, ErrLineCodes, sLog: string;
    sum, bon: Double;
    firma: TFirmInfo;
    arLineCodes: Tai;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  OverMess:= '';
  SetLength(arLineCodes, 0);
  ErrLineCodes:= '';
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    LineID:= Stream.ReadStr;  // � ����� ������� - ��������� ����� ����� �������

    sLog:= 'OrderId='+OrderCode+#13#10'LineID='+LineID;
    try
      OrderID:= StrToIntDef(OrderCode, 0);
      if (OrderID<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

      i:= Length(LineID);
      if (copy(LineID, 1, 1)=',') then LineID:= copy(LineID, 2, i-1);
      if (copy(LineID, i, 1)=',') then LineID:= copy(LineID, 1, i-1);
      arLineCodes:= fnArrOfCodesFromString(LineID);
      i:= Length(arLineCodes);

      if (i<1) then raise EBOBError.Create(MessText(mtkNotValidParam, ' - ��� ������'));

      OrdIBD:= cntsORD.GetFreeCnt;
      OrdIBS:= fnCreateNewIBSQL(OrdIBD,'OrdIBS_'+nmProc,ThreadData.ID, tpRead, true);
      OrdIBS.SQL.Text:= 'SELECT ORDRFIRM, ORDRSTATUS, ORDRCURRENCY, (select'+
        ' list(ORDRLNWARE) from ORDERSLINES where ORDRLNCODE in ('+LineID+')) warecodes'+
        ' from ORDERSREESTR where ORDRCODE='+OrderCode;
      OrdIBS.ExecQuery;
      if OrdIBS.Bof and OrdIBS.Eof then // ���������, ���������� �� ����� �����
        raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
      // ���������, ����� �� ����� �������������
      if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger>orstForming)  then
        raise EBOBError.Create(MessText(mtkNotEditOrder));
      // ���������, ����� �� ����� ���� ������� ������������� ���� �����
      if OrdIBS.FieldByName('ORDRFIRM').AsInteger<>FirmID then
        raise EBOBError.Create(MessText(mtkNotRightExists));
      sLog:= sLog+#13#10'Wares='+OrdIBS.FieldByName('warecodes').asString+#13#10'IsPrize='+
             fnIfStr(OrdIBS.FieldByName('ORDRCURRENCY').AsInteger=Cache.BonusCrncCode, '1', '0');
      OrdIBS.Close;
    finally
      prSetThLogParams(ThreadData, csDelLineFromOrder, UserID, FirmID, sLog); // �����������
    end;

    // ����� ��� ���������, ������� ������ (������)
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);

    OrdIBS.SQL.Text:= 'execute procedure DelOrderLine(:LineID)';
    for i:= 0 to High(arLineCodes) do begin
      OrdIBS.ParamByName('LineID').AsInteger:= arLineCodes[i];
      s:= RepeatExecuteIBSQL(OrdIBS);
      if (s<>'') then begin
        ErrLineCodes:= ErrLineCodes+fnIFStr(ErrLineCodes='', '', ',')+IntToStr(arLineCodes[i]);
        fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', MessText(mtkErrDelRecord)+': '+s, '');
      end;
    end; // for

    // ������ ����� ����� ����� � ������
    fnSetTransParams(OrdIBS.Transaction, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRSUMORDER, ORDRCURRENCY, ORDRCONTRACT, ORDRNUM,'+
                      ' OrdrWareLineCount from ORDERSREESTR where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if (OrdIBS.Bof and OrdIBS.Eof) then raise EBOBError.Create(MessText(mtkNotValidParam));
    sum:= OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;
    CurrID:= OrdIBS.FieldByName('ORDRCURRENCY').asInteger;
    ContID:= OrdIBS.FieldByName('ORDRCONTRACT').asInteger;
    ordNum:= OrdIBS.FieldByName('ORDRNUM').AsString;
    bon:= sum*Cache.GetPriceBonusCoeff(CurrID);
//----------------------------- �������� ����� ����� ����� � ������ � CGI-������
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    if (currID=Cache.BonusCrncCode) then begin // unit-�����
      Stream.WriteStr(FloatToStr(RoundToHalfDown(sum))); // ����� ����� ������
      Stream.WriteStr(Cache.GetCurrName(CurrID, True));  // ������������ ������
      Stream.WriteStr('0');
    end else begin                             // ������� �����
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));    // ����� ����� ������
      Stream.WriteStr(Cache.GetCurrName(CurrID, True)); // ������������ ������
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, bon));    // ������ �� ������
    end;

    firma:= Cache.arFirmInfo[FirmID];
    if (firma.ResLimit>=0) and (currID<>Cache.BonusCrncCode) and fnNotZero(sum) then begin
      WareCount:= OrdIBS.FieldByName('OrdrWareLineCount').AsInteger;
      OrdIBS.Close;
      OrdIBS.SQL.Clear;                // �������� ���������� ������ ������� �/�
      OverMess:= CheckOrdWaresExAndOverLimit(FirmID, UserID,
                 ContID, OrderID, CurrID, True, False, (WareCount<2), OrdIBS);
    end;
    Stream.WriteStr(OverMess);

    Stream.WriteStr(ErrLineCodes); // ���� �����, ���. �� ���������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  SetLength(arLineCodes, 0);
  Stream.Position:= 0;
end; 
//******************************************************************************
procedure prChangeQtyInOrderLineOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prChangeQtyInOrderLineOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserID, FirmID, i, WareID, contID, currID, OrderID, WareCount: integer;
    OrderCode, WareCode, Qty, s, StorageCode, UserMessage, OverMess, ordNum: string;
    QtyD, bon, price, sum, sumLn: double;
    Storages: TaSD;
    Contract: TContract;
    firma: TFirmInfo;
    ware: TWareInfo;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  UserMessage:='';
  ware:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    WareCode:= Stream.ReadStr;
    OrderCode:= Stream.ReadStr;
    Qty:= Stream.ReadStr;
    QtyD:= StrToFloatDef(Qty, 0);

    prSetThLogParams(ThreadData, csChangeQtyInOrderLine, UserID, FirmID,
      'OrderId='+OrderCode+#13#10'WareCode='+WareCode+#13#10'Qty='+Qty); // �����������

    OrderID:= StrToIntDef(OrderCode, 0);
    if (OrderID<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    if (QtyD<0) then raise EBOBError.Create('���������� �� ����� ���� �������������');

    i:= Pos('_', WareCode);
    if (i<1) then raise EBOBError.Create('������ �������� ����� ������ � ������.');
    StorageCode:= Copy(WareCode, i+1, 10000);
    WareCode:= Copy(WareCode, 1, i-1);
    WareID:= StrToIntDef(WareCode, 0);
    if (WareID>0) and not Cache.WareExist(WareID) then WareID:= 0;
    if (WareID>0) then ware:= Cache.GetWare(WareID);
    if Assigned(Ware) and ware.IsArchive then WareID:= 0;
    if (WareID<1) then raise EBOBError.Create(MessText(mtkNotFoundWare, WareCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    s:= fnRecaclQtyByDivisibleEx(WareID, QtyD);   // ��������� ���������
    if (s<>'') then raise EBOBError.Create(s);

    OrdIBD:= cntsORD.GetFreeCnt; // ������ ���������, ���������� �� ����� �����
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);
    OrdIBS.SQL.Text:= 'SELECT ORDRFIRM, ORDRSTATUS, ORDRCONTRACT, ORDRLNCODE, ORDRNUM'+ // , ORDRSTORAGE
      ' from ORDERSREESTR left join ORDERSLINES on ORDRLNORDER=ORDRCODE and ORDRLNWARE='+
      WareCode+' where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    // ����� ���������, ����� �� ����� �������������
    if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger>orstForming) then
      raise EBOBError.Create(MessText(mtkNotEditOrder));
    // ����� ���������, ����� �� ����� ���� ������� ������������� ���� �����
    if OrdIBS.FieldByName('ORDRFIRM').AsInteger<>FirmID then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    // ���������, ���������� �� ����� ������
    if OrdIBS.FieldByName('ORDRLNCODE').IsNull then      //  ??? ���������
      raise EBOBError.Create(MessText(mtkNotFoundRecord));
    contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
    ordNum:= OrdIBS.FieldByName('ORDRNUM').AsString;
//    StorageCode:= OrdIBS.FieldByName('ORDRSTORAGE').AsString;
    OrdIBS.Close;

    with Cache.arFirmInfo[FirmID] do begin // ��������� ����������� ���������
      if not CheckContract(contID) then
        contID:= Cache.arClientInfo[UserID].LastContract;
      Contract:= GetContract(contID);
      if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
        raise EBOBError.Create('�������� '+Contract.Name+' ����������');
    end;

    i:= StrToInt(StorageCode);
    if (i<>Contract.MainStorage) then
      raise EBOBError.Create('�� ������ ����� ��� ��������������');

    // ����� ��� ���������, ����������� ������
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
//    OrdIBS.SQL.Text:= 'EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', '+
//                      WareCode+', '+ StorageCode+', :Qty)';
    OrdIBS.SQL.Text:= 'select rNewOrderLnCode, rLineExists from AddOrderLineQty'+
      '('+OrderCode+', '+WareCode+', :Qty, :ORDRLNWAREMEASURE, :ORDRLNPRICE, 0, 0)';
    OrdIBS.ParamByName('Qty').AsFloat:= QtyD;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if (s<>'') then raise Exception.Create(s);

    // ������������� ������, ����� �������� ����� �����
    fnSetTransParams(OrdIBS.Transaction, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRSUMORDER, ORDRCURRENCY, ORDRLNCLIENTQTY, ORDRLNPRICE, OrdrWareLineCount'+
      ' from ORDERSREESTR left join ORDERSLINES on ORDRLNORDER=ORDRCODE and ORDRLNWARE='+
      WareCode+' where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundRecord));
    if OrdIBS.FieldByName('ORDRLNCLIENTQTY').IsNull then
      raise EBOBError.Create(MessText(mtkNotValidParam));
//--------------------------------------------------- � �������� �� � CGI-������
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(FormatFloat('# ##0.#', QtyD));       // ������� ���-�� � ������

    QtyD:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
    price:= OrdIBS.FieldByName('ORDRLNPRICE').AsFloat;
    sum:= OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;
    CurrID:= OrdIBS.FieldByName('ORDRCURRENCY').asInteger;
    bon:= Cache.GetPriceBonusCoeff(CurrID);
    sumLn:= RoundToHalfDown(price*QtyD);

    Stream.WriteStr(FormatFloat('# ##0.#', QtyD));      // ����� ���-�� � ������
    if (currID=Cache.BonusCrncCode) then begin // unit-�����
      Stream.WriteStr(FloatToStr(sumLn));                // ����� ����� � ������
      Stream.WriteStr(FloatToStr(RoundToHalfDown(sum))); // ����� ����� ������
      Stream.WriteStr(Cache.GetCurrName(CurrID, True));  // ������������ ������
      Stream.WriteStr('0');
      Stream.WriteStr('0');
    end else begin                             // ������� �����
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sumLn));     // ����� ����� � ������
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));       // ����� ����� ������
      Stream.WriteStr(Cache.GetCurrName(CurrID, True));          // ������������ ������
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sumLn*bon)); // ������ �� ������
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum*bon));   // ������ �� ������
    end;
    Stream.WriteStr(UserMessage);

    firma:= Cache.arFirmInfo[FirmID];
    if (firma.ResLimit>=0) and (currID<>Cache.BonusCrncCode) and fnNotZero(sum) then begin
      WareCount:= OrdIBS.FieldByName('OrdrWareLineCount').AsInteger;
      OrdIBS.Close;
      OrdIBS.SQL.Clear;                // �������� ���������� ������ ������� �/�
      OverMess:= CheckOrdWaresExAndOverLimit(FirmID, UserID,
                 ContID, OrderID, CurrID, True, False, (WareCount<2), OrdIBS);
    end;
    Stream.WriteStr(OverMess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(Storages, 0);
end;
//******************************************************************************
procedure prRefreshPricesOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prRefreshPricesOrd'; // ��� ���������/�������
var OrderCode, SResult, s: string;
    UserID, FirmID, i: integer;
begin
  SResult:= '';
  Stream.Position:= 0;
  try
    OrderCode:= Stream.ReadStr;
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csRefreshPrices, UserID, FirmID, // �����������
      'OrderCode='+OrderCode+' UserID='+IntToStr(UserID)+' FirmID='+IntToStr(FirmID));

    i:= StrToIntDef(OrderCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    s:= fnRefreshPriceInOrderOrd(SResult, OrderCode, ThreadData);
    if (s<>'') then // ���� ������� ����������� � ������� - ���������� ������
      if copy(s, 1, 3)='EB:' then raise EBOBError.Create(copy(s, 4, length(s)))
      else raise Exception.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(SResult);                      //  �������� ����� ������ ???
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end; 
//*********************************** ��������� ���� � ������ � ������ ��� �����
function fnRefreshPriceInOrderOrd(var SResult: string; OrderCode: string; ThreadData: TThreadData=nil): string;
const nmProc = 'fnRefreshPriceInOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    CurPrice: Double;
    OrderID, FirmID, CurrencyOld, i, j, AccTypeOld, AccTypeNew, CurrencyNew, contID: integer;
    ChangeCodes: Tai;
    ChangePrices: TDoubleDynArray;
    s: string;
    fltype: Boolean;
    Contract: TContract;
begin
  Result:= '';
  setLength(ChangeCodes, 0);
  setLength(ChangePrices, 0);
  OrdIBS:= nil;
  OrdIBD:= nil;
//  CurrencyNew:= 1;
  j:= 0;
  try
    OrderID:= StrToIntDef(OrderCode, -1);
    if (OrderID<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    try
      OrdIBD:= cntsORD.GetFreeCnt;
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, OrderID, tpRead, true);
      OrdIBS.SQL.Text:= 'select ORDRFIRM, ORDRSTATUS, ORDRCURRENCY, ORDRACCOUNTINGTYPE,'+
        ' ORDRCONTRACT from ORDERSREESTR where ORDRCODE='+OrderCode;
      OrdIBS.ExecQuery;
      if OrdIBS.Bof and OrdIBS.Eof then
        raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
      if OrdIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming then
        raise EBOBError.Create(MessText(mtkOnlyFormingOrd));

      FirmID:= OrdIBS.FieldByName('ORDRFIRM').AsInteger;
      contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
      CurrencyOld:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
      AccTypeOld:= OrdIBS.FieldByName('ORDRACCOUNTINGTYPE').AsInteger;
      OrdIBS.Close;

      with Cache.arFirmInfo[FirmID] do
        if not CheckContract(contID) then contID:= GetDefContractID;
      Contract:= Cache.Contracts[ContID];

      if (CurrencyOld<>Cache.BonusCrncCode) then begin
        AccTypeNew:= Contract.PayType;
        CurrencyNew:= Contract.DutyCurrency;
      end else begin
        CurrencyNew:= CurrencyOld;
        AccTypeNew:= AccTypeOld;
      end;
      fltype:= (AccTypeNew<>AccTypeOld) or (CurrencyNew<>CurrencyOld);
      if fltype then begin
        fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
        OrdIBS.SQL.Text:= 'Update ORDERSREESTR set ORDRACCOUNTINGTYPE=:ORDRACCOUNTINGTYPE,'+  //
          'ORDRCURRENCY=:ORDRCURRENCY WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
        OrdIBS.ParamByName('ORDRACCOUNTINGTYPE').AsInteger:= AccTypeNew;
        OrdIBS.ParamByName('ORDRCURRENCY').AsInteger:= CurrencyNew;
        s:= RepeatExecuteIBSQL(OrdIBS);
        if s<>'' then raise Exception.Create(s);
        fnSetTransParams(OrdIBS.Transaction, tpRead, True);
      end;

      OrdIBS.SQL.Text:= 'select ORDRLNWARE, ORDRLNPRICE, ORDRLNCODE'+
        ' from ORDERSLINES where ORDRLNORDER='+OrderCode;
      OrdIBS.ExecQuery;
      j:= 0; // �������
      while not OrdIBS.EOF do begin
        i:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
        CurPrice:= Cache.GetWare(i).SellingPrice(FirmID, CurrencyNew, contID);
        if fnNotZero(OrdIBS.FieldByName('ORDRLNPRICE').AsFloat-CurPrice) then begin
          if Length(ChangeCodes)<(j+1) then begin
            setLength(ChangeCodes, j+10);
            setLength(ChangePrices, j+10);
          end;
          ChangeCodes[j]:= OrdIBS.FieldByName('ORDRLNCODE').AsInteger;
          ChangePrices[j]:= CurPrice;
          inc(j);
        end;
        TestCssStopException;
        OrdIBS.Next;
      end;
      OrdIBS.Close;

      fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
      if (j>0) then begin
        OrdIBS.SQL.Text:= 'UPDATE ORDERSLINES set ORDRLNPRICE=:ORDRLNPRICE where ORDRLNCODE=:ORDRLNCODE';
        OrdIBS.Prepare;
        for i:= 0 to j-1 do begin
          with OrdIBS.Transaction do if not InTransaction then StartTransaction;
          OrdIBS.ParamByName('ORDRLNCODE').AsInteger:= ChangeCodes[i];
          OrdIBS.ParamByName('ORDRLNPRICE').AsFloat:= ChangePrices[i];
          s:= RepeatExecuteIBSQL(OrdIBS);
          if s<>'' then raise Exception.Create(s);
        end;
      end;
      with OrdIBS.Transaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'UPDATE ORDERSREESTR SET ORDRRECALCTIME="NOW" WHERE ORDRCODE='+OrderCode;
      s:= RepeatExecuteIBSQL(OrdIBS);
      if s<>'' then raise Exception.Create(s);
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(OrdIBD);
    end;
    if (j>0) then SResult:= '���� � ������ ���������.'  // ������ Result �� SResult
    else SResult:= '���� � ������ �� ����������.';
  except
    on E: EBOBError do Result:= 'EB:'+E.Message;
    on E: Exception do Result:= nmProc+': '+CutEMess(E.Message);
  end;
  setLength(ChangeCodes, 0);
  setLength(ChangePrices, 0);
end;
//******************************************************************************
procedure prRefreshPricesInFormingOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prRefreshPricesInFormingOrdersOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, iCount: integer;
    s, sResult, sErr: string;
begin
  sResult:= '';
  sErr:= '';
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  iCount:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csRefreshPricesInFormingOrders, UserID, FirmID, ''); // �����������

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRNUM FROM ORDERSREESTR WHERE ORDRSTATUS='+ // ������� ORDRNUM
      IntToStr(orstForming)+' and ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      s:= fnRefreshPriceInOrderOrd(SResult, OrdIBS.FieldByName('ORDRCODE').AsString, ThreadData);
      if (s<>'') then                               // �������� ��� ������
        sErr:= sErr+fnIfStr(sErr='', '', #13#10)+OrdIBS.FieldByName('ORDRNUM').AsString+' '+s;
      Inc(iCount);
      TestCssStopException;
      OrdIBS.Next;
    end;
    OrdIBS.Close;
    if (iCount<1) then raise EBOBError.Create('�� ������� �������������� ������.');
    if (sErr<>'') then raise Exception.Create(sErr);   // ���� ���� ������

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//======================================================== ������ ������ �������
procedure prGetAccountListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetAccountListOrd'; // ��� ���������/�������
var GBIBD, OrdIBD: TIBDatabase;
    GBIBS, OrdIBS: TIBSQL;
    i, UserId, FirmID, sPos, contID, ii: integer;
    SortOrder, SortDesc, s: string;
    Client: TClientInfo;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  GBIBS:= nil;
  GBIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    SortOrder:= Stream.ReadStr;
    SortDesc:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetAccountList, UserID, FirmID,
      'SortOrder='+SortOrder+#13#10'SortDesc='+SortDesc); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserID];
    ContID:= Client.GetCliCurrContID;  // ��� ��������/���������� ��������� �������

    OrdIBD:= cntsORD.GetFreeCnt;
    GBIBD:= cntsGRB.GetFreeCnt;

    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'select ORDRCODE, ORDRNUM, ORDRDATE from ORDERSREESTR WHERE ORDRFIRM='+
      IntToStr(FirmID)+' and ORDRGBACCCODE=:ORDRGBACCCODE';
    OrdIBS.Prepare;

    GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'select rPInvCode DCACCODE, rPInvNumber DCACNUMBER,'+
      ' rPInvDate DCACDATE, rPInvSumm DCACSUMM, rPROCESSED DCACPROCESSED,'+
      ' rCLIENTCOMMENT, rPInvCrnc DCACCRNCCODE, rPInvLocked, rContCode'+
      ' from Vlad_CSS_GetFirmReserveDocsN('+IntToStr(FirmID)+', '+
      fnIfStr(Client.DocsByCurrContr, IntToStr(contID), '0')+')'+
      ' ORDER BY '+SortOrder+' '+SortDesc+', DCACDATE '+SortDesc+', DCACNUMBER '+SortDesc;

    GBIBS.Prepare;
    GBIBS.ExecQuery;
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    sPos:= Stream.Position;
    Stream.WriteInt(0); // �������� ����� ��� ���-��
    i:= 0;
    while not GBIBS.EOF do begin
      //------------------------------- ������ �� ����������
      ii:= GBIBS.FieldByName('rContCode').AsInteger;
      if (ii<1) then s:= ''                                  // �������� �����������
      else if (Client.CliContracts.IndexOf(ii)<0) or         // �������� ����������
        (Client.DocsByCurrContr and (ii<>ContID)) then begin // ������ ������ �� ��������
        GBIBS.Next;
        Continue;
      end else s:= Client.GetCliContract(ii).Name;

      Stream.WriteInt(GBIBS.FieldByName('DCACCODE').AsInteger);
      Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('DCACDATE').AsDateTime));
      Stream.WriteByte(fnIfInt(GetBoolGB(GBibs, 'DCACPROCESSED'), byte('t'), byte('f')));
      Stream.WriteStr(GBIBS.FieldByName('DCACNUMBER').AsString+fnIfStr(GetBoolGB(GBibs, 'DCACPROCESSED'), cWebProcessed, ''));
      Stream.WriteStr(GBIBS.FieldByname('rCLIENTCOMMENT').AsString);
      Stream.WriteDouble(GBIBS.FieldByName('DCACSUMM').AsFloat);
      Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('DCACCRNCCODE').AsInteger, True));
      Stream.WriteStr(s);                                     // ����� ���������
      Stream.WriteBool(GetBoolGB(GBibs, 'rPInvLocked')); // ������� ���������� �����
      OrdIBS.ParamByName('ORDRGBACCCODE').AsInteger:= GBIBS.FieldByName('DCACCODE').AsInteger;
      OrdIBS.ExecQuery;
      if OrdIBS.Bof and OrdIBS.Eof then Stream.WriteStr('')
      else begin
        Stream.WriteStr(OrdIBS.FieldByname('ORDRCODE').AsString);
        Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByname('ORDRDATE').AsDateTime));
        Stream.WriteStr(OrdIBS.FieldByname('ORDRNUM').AsString);
      end;
      OrdIBS.Close;
      TestCssStopException;
      GBIBS.Next;
      Inc(i);
    end;
    GBIBS.Close;
    Stream.Position:= sPos;
    Stream.WriteInt(i); // �������� ���-��
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(GBIBD);
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//******************************************************************************
procedure prShowGBAccountOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowGBAccountOrd'; // ��� ���������/�������
var GBIBD, OrdIBD: TIBDatabase;
    GBIBS, OrdIBS: TIBSQL;
    UserId, FirmID, spos, LineCount, i, DprtID, currID, contID, ForFirmID: integer;
    AccountCode, Summa, bonuses, s, sDestName, sDestAdr, sArrive, sShipMet, sShipTime, sShipView, ss: string;
    Ware: TWareInfo;
    Client: TClientInfo;
    ShipDate, wCount, price, pDate, sum, bon: Double;
    GBdirection: Boolean;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  GBIBS:= nil;
  GBIBD:= nil;
  Client:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    AccountCode:= Stream.ReadStr;
    GBdirection:= Stream.ReadBool;

    if (FirmID<>IsWe) then ForFirmID:= FirmID  // Web
    else try
      ForFirmID:= Stream.ReadInt; // Webarm  ��� �/� - �������� �������� !!!
    except
      ForFirmID:= 0;
    end;

    s:= 'AccountID='+AccountCode;
    if (FirmID=IsWe) then s:= s+#10#13'ForFirmID='+IntToStr(ForFirmID);

    prSetThLogParams(ThreadData, csShowGBAccount, UserID, FirmID, s); // �����������

    if (ForFirmID<1) then
      raise EBOBError.Create(MessText(mtkNotFirmExists, IntToStr(ForFirmID)));
    i:= StrToIntDef(AccountCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if (FirmID<>IsWe) then begin
      Client:= Cache.arClientInfo[UserID];
      s:= fnIntegerListToStr(Client.CliContracts); // TIntegerList - � ������ ����� �������
    end else s:= '';

    GBIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'select sss.*, s.shmhname sShipMet, ss.shtiname sShipTime'+
      ' from (SELECT PInvCode, PInvNumber, PInvDate, PInvProcessed,'+
      ' PInvRecipientCode, PInvSupplyDprtCode, PINVCLIENTCOMMENT, PInvSumm,'+
      ' PINVSHIPMENTDATE, PInvCrncCode, PINVCONTRACTCODE, fddprtname,'+
      ' iif(TRTBSHIPMETHODCODE is null, PINVSHIPMENTMETHODCODE, TRTBSHIPMETHODCODE) ShipMet,'+
      ' iif(TRTBSHIPTIMECODE is null, PINVSHIPMENTTIMECODE, TRTBSHIPTIMECODE) ShipTime,'+
      ' iif(trtblnarrivetime is null, null,'+
      '   DATEADD(MINUTE, round(trtblnarrivetime), PINVSHIPMENTDATE)) arrive,'+
//      ' TRTBLNDOCMCODE shiptab, gm.'+fnIfStr(GBdirection, 'RFullName ', '')+'rAdress'+
      ' TRTBLNDOCMCODE shiptab, gm.rAdress'+
      fnIfStr(flMeetPerson, ', pphphone, prsnname', '')+
      fnIfStr(FirmID<>IsWe, '', ', gn.rNum contnum')+
      ' from PayInvoiceReestr'+
      fnIfStr(flMeetPerson,
      ' left join personphones on pphcode=PINVMEETPERSON'+
      ' left join persons on prsncode=PPhPersonCode', '')+
      ' left join TRANSPORTTIMETABLESLINES on TRTBLNCODE=pinvtripcode'+
      ' left join TRANSPORTTIMETABLESREESTR tt on tt.TRTBCODE=TRTBLNDOCMCODE'+
      ' left join FIRMDEPARTMENT on fdcode=PINVSUPPLIERFIRMDPRT'+
      fnIfStr(FirmID<>IsWe, '',
      ' left join CONTRACT on contcode=PINVCONTRACTCODE'+
      ' left join Vlad_CSS_GetFullContNum(contnumber, contnkeyyear, contpaytype) gn on 1=1')+
//      ' left join '+fnIfStr(GBdirection, 'GETANRGFULLLOCATIONNAME', 'GETADRESSSTR')+
//      '   (fdplasement) gm on 1=1) sss'+
      ' left join GETADRESSSTREX(fdplasement, "'+fnIfStr(GBdirection, 'T', 'F')+'") gm on 1=1) sss'+
      ' left join shipmentmethods s on s.shmhcode=ShipMet'+
      ' left join shipmenttimes ss on ss.shticode=ShipTime'+
      ' where PInvCode='+AccountCode+' and PInvRecipientCode='+IntToStr(ForFirmID)+
      fnIfStr(s='', '', ' and PINVCONTRACTCODE in ('+s+')');
    GBIBS.ExecQuery;
    if GBIBS.Bof and GBIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));

    DprtID:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
    currID:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
    sum:= GBIBS.FieldByName('PInvSumm').AsFloat;
    Summa:= FormatFloat(cFloatFormatSumm, sum)+' '+Cache.GetCurrName(currID, True);
    bon:= Cache.GetPriceBonusCoeff(currID);
    bonuses:= FormatFloat(cFloatFormatSumm, sum*bon);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('PInvDate').AsDateTime));

    contID:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
    s:= '';
    if (FirmID=IsWe) then s:= GBIBS.FieldByName('contnum').AsString
    else if Assigned(Client) and Client.CheckContract(contID) then
      s:= Cache.Contracts[contID].Name;
    Stream.WriteStr(s); // ����� ���������

    s:= fnIfStr(GetBoolGB(GBibs, 'PInvProcessed'), '���-� ���������', '���-� �� ���������');
    Stream.WriteStr(s+', ����� �������������� "'+Cache.GetDprtMainName(DprtID)+'"');

    s:= '';
    ss:= '';
    if (FirmID<>IsWe) then try
      OrdIBD:= cntsORD.GetFreeCnt;
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRNUM, ORDRDATE from ORDERSREESTR'+
        ' where ORDRGBACCCODE='+AccountCode+' AND ORDRFIRM='+IntToStr(ForFirmID);
      OrdIBS.ExecQuery;
      if not (OrdIBS.Bof and OrdIBS.Eof) then begin
        s:= OrdIBS.FieldByName('ORDRCODE').AsString;
        ss:= OrdIBS.FieldByName('ORDRNUM').AsString+' �� '+
          FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime);
      end;
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(OrdIBD);
    end;
    Stream.WriteStr(s);
    Stream.WriteStr(ss);
    Stream.WriteStr(fnReplaceQuotedForWeb(GBIBS.FieldByName('PINVCLIENTCOMMENT').AsString));

    ShipDate:= GBIBS.FieldByName('pinvshipmentdate').AsDateTime;
    sDestAdr:= trim(GBIBS.FieldByName('rAdress').AsString);
    if (GBIBS.FieldByName('shiptab').AsInteger>0) and not GBIBS.FieldByName('arrive').IsNull then begin
      pDate:= GBIBS.FieldByName('arrive').AsDateTime;
      if (pDate>DateNull) then sArrive:= FormatDateTime(cDateTimeFormatY2N, pDate);
    end;
    sShipMet:= trim(GBIBS.FieldByName('sShipMet').AsString);
    sShipTime:= trim(GBIBS.FieldByName('sShipTime').AsString);
    sDestName:= trim(GBIBS.FieldByName('fddprtname').AsString);
    GBIBS.Close;

    sShipView:= '';
    if (ShipDate>DateNull) then sShipView:= sShipView+FormatDateTime(cDateFormatY2, ShipDate);
    if (sShipTime<>'') then sShipView:= sShipView+fnIfStr(sShipView='', '', ', ')+sShipTime;
    if (sShipMet<>'') then sShipView:= sShipView+fnIfStr(sShipView='', '', ', ')+sShipMet;
    if (sDestName<>'') then sShipView:= sShipView+fnIfStr(sShipView='', '', ', ')+sDestName;
    if (sDestAdr<>'') then sShipView:= sShipView+fnIfStr(sShipView='', '', ', ')+sDestAdr;
    if (sArrive<>'') then sShipView:= sShipView+fnIfStr(sShipView='', '', ', ')+'����.����.'+sArrive;
    if (sShipView<>'') then sShipView:= '��������: '+sShipView;
    Stream.WriteStr(sShipView);

if flMeetPerson then begin
    s:= trim(GBIBS.FieldByName('prsnname').AsString);
    ss:= GBIBS.FieldByName('pphphone').AsString;
    if (s<>'') or (ss<>'') then s:= s+' ('+ss+')';
    Stream.WriteStr(s); // �����������
end; // flMeetPerson

    LineCount:= 0;       // ������� - ���-�� �����
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  ����� ��� ���-�� �����

    GBIBS.SQL.Text:= 'select PInvLnWareCode aWARECODE,'+
      ' PInvLnOrder aORDER, PInvLnCount aCOUNT, PInvLnPrice aPRICE'+
      ' from PayInvoiceLines where PInvLnDocmCode='+AccountCode;
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      i:= GBIBS.FieldByName('aWARECODE').AsInteger;
      wCount:= GBIBS.FieldByName('aCOUNT').AsFloat;
      price:= GBIBS.FieldByName('aPRICE').AsFloat;
      Ware:= Cache.GetWare(i);
      if not Assigned(Ware) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(GBIBS.FieldByName('aORDER').AsString);
      Stream.WriteStr(GBIBS.FieldByName('aCOUNT').AsString);
      Stream.WriteStr(Ware.MeasName);
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));     // ����
      price:= RoundToHalfDown(price*wCount);                     // ����� �� ������
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, price*bon)); // ������ �� ������ (�� unit-����)
      inc(LineCount);
      TestCssStopException;
      GBIBS.Next;
    end;
    GBIBS.Close;
    Stream.WriteStr(Summa);   // ����� + ������ �����
    Stream.WriteStr(bonuses); // ������ �� �����
    s:= Cache.GetCurrName(Cache.BonusCrncCode, True);
    Stream.WriteStr(s);

    Stream.Position:= sPos;
    Stream.WriteInt(LineCount);

    if (FirmID=IsWe) then begin
      Stream.Position:= Stream.Size;
      Stream.WriteStr(Cache.arFirmInfo[ForFirmID].Name);
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(GBIBD);
  Stream.Position:= 0;
end; 
//******************************************************************************
procedure prDeleteOrderByMarkOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prDeleteOrderByMarkOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS, OrdIBS1: TIBSQL;
    UserId, FirmID: integer;
    s, ss: string;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  OrdIBS1:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    s:= trim(Stream.ReadStr);

    prSetThLogParams(ThreadData, csDeleteOrderByMark, UserID, FirmID, 'IDs='+s); // �����������

    if (s='') then raise EBOBError.Create('�� ������� ���������, ����='+s);

    if CheckNotValidUser(UserID, FirmID, ss) then raise EBOBError.Create(ss);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
    OrdIBS1:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS1_'+nmProc, ThreadData.ID, tpWrite);
    OrdIBD.DefaultTransaction.StartTransaction;

    OrdIBS.SQL.Text:= 'SELECT r.ORDRCODE, r.ORDRNUM, r.ORDRDATE,'+
    ' IIF(exists(select ordrlncode from ORDERSLINES where ORDRLNORDER=r.ORDRCODE), 1, 0) LineCount'+
    ' from ORDERSREESTR r where r.ORDRCODE in ('+s+') and r.ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    while not OrdIBS.EOF do begin
      if OrdIBS.FieldByName('LineCount').AsInteger=0 then begin
        OrdIBS1.SQL.Text:= 'DELETE FROM ORDERSREESTR WHERE ORDRCODE='+OrdIBS.FieldByName('ORDRCODE').AsString;
      end else begin
        OrdIBS1.SQL.Text:= 'UPDATE ORDERSREESTR SET ORDRSTATUS='+IntToStr(orstDeleted)+
          ' WHERE ORDRCODE='+OrdIBS.FieldByName('ORDRCODE').AsString;
      end;
      OrdIBS1.ExecQuery;
      TestCssStopException;
      OrdIBS.Next;
    end;
    OrdIBD.DefaultTransaction.Commit;
  except
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  prFreeIBSQL(OrdIBS1);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end; 
//******************************************************************************
procedure prSetReservValueOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetReservValueOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, i: integer;
    s, OrderCode: string;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    s:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csSetReservValue, UserID, FirmID,
      'OrderCode='+OrderCode+#13#10'Delivery='+s); // �����������

    i:= StrToIntDef(OrderCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

// ����  �����
    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
    OrdIBS.SQL.Text:= 'Select ORDRSTATUS FROM ORDERSREESTR'+
      ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    // ����� ���������, ����� �� ����� �������������
    if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming) then
      raise EBOBError.Create(MessText(mtkNotEditOrder));
    OrdIBS.Close;

    OrdIBS.SQL.Text:= 'Update ORDERSREESTR set ORDRDELIVERYTYPE=:ORDRDELIVERYTYPE'+
      ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
    OrdIBS.ParamByName('ORDRDELIVERYTYPE').AsInteger:= ord(S='1');
    OrdIBS.ExecQuery;
    OrdIBS.Close;
    OrdIBS.Transaction.Commit;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(assigned(OrdIBS), OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end; 
{//********************************* ���������� �������� ���� "��� ������" ������
procedure prSetOrderPayTypeOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetOrderPayTypeOrd'; // ��� ���������/�������
var UserId, FirmID, i: integer;
    acctype, OrderCode, SResult, s: string;
begin
  SResult:= '';
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    acctype:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csSetOrderPayType, UserID, FirmID,
      'OrderID='+OrderCode+#13#10'acctype='+acctype); // �����������

    i:= StrToIntDef(OrderCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

    s:= fnRefreshPriceInOrderOrd(SResult, OrderCode, ThreadData);
    if (s<>'') then // ���� ������� ����������� � ������� - ���������� ������
      if copy(s, 1, 3)='EB:' then raise EBOBError.Create(copy(s, 4, length(s)))
      else raise Exception.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end; }
//********************** �������� ������ � ����� �� ����� �������� ������� (Web)
procedure prAddLinesToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLinesToOrderOrd'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS, OrdIBS1: TIBSQL;
    UserId, FirmID, WareCount, DataCount, i, j, k, ResLineQty, ii,
      LineID, sPos, WareID, OrderID, contID, currID: integer;
    s, OrderCode, WareCode, Currency, acctype, UserMessage,
      DivisibleMess, WrongWares, sSQL, OverMess, ordnum: string;
    OrderExists, LineExists, flBonusOrder: boolean;
    AnalogQty, price, bon, sum: double;
    WareCodes: Tas;
    WareQties: TDoubleDynArray; // ���-�� ������ �� �������
    WareQty: TDoubleDynArray; // ���-�� �� �������
    Storages: TaSD;
    Ware: TWareInfo;
    firma: TFirmInfo;
    HasAnalogs: Boolean;
    AnCodes: Tai;
    Contract: TContract;
begin
  UserMessage:= '';
  WrongWares:='';
  Stream.Position:= 0;
//  IBD:= nil;
  IBS:= nil;
  OrdIBS1:= nil;
  UserId:= 0;
  FirmId:= 0;
  price:= 0;
  LineExists:= False;
  LineID:= 0;
  SetLength(AnCodes, 0);
  contID:= 0;
  OverMess:= '';
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    contID:= Stream.ReadInt;  // ��� ����������
    DataCount:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;

    sPos:= Stream.Position;
    WareCode:= Stream.ReadStr;
    Stream.Position:= sPos;

    i:= Pos('_', WareCode);
    if (i>0) then WareCode:= Copy(WareCode, 1, i-1);

    prSetThLogParams(ThreadData, csAddLinesToOrder, UserID, FirmID,
      'WareCode='+WareCode+#13#10'ContID='+IntToStr(ContID)); // �����������

    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) then
      raise Exception.Create(MessText(mtkNotFoundWare, WareCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmID];

    if (OrderCode='') then OrderID:= 0
    else OrderID:= StrToIntDef(OrderCode, 0);
    OrderExists:= (OrderID>0);

    IBD:= cntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
      OrdIBS1:= fnCreateNewIBSQL(IBD, 'OrdIBS1_'+nmProc, ThreadData.ID, tpWrite);
      IBD.DefaultTransaction.StartTransaction;

      sSQL:= 'Select ORDRCURRENCY, ORDRACCOUNTINGTYPE, ORDRCONTRACT, ORDRNUM'+
          ' FROM ORDERSREESTR WHERE ORDRCODE=:ORDRCODE and ORDRSTATUS='+IntToStr(orstForming);
      if OrderExists then begin
        IBS.SQL.Text:= sSQL;
        IBS.ParamByName('ORDRCODE').AsInteger:= OrderID;
        IBS.ExecQuery;
        OrderExists:= not (IBS.Bof and IBS.Eof);
      end;
      if OrderExists then begin
        contID:= IBS.FieldByName('ORDRCONTRACT').AsInteger;
        ordnum:= IBS.FieldByName('ORDRNUM').AsString;
      end else begin // ���� ��� ������ - �������
        IBS.Close;
        prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, contID, s, ThreadData.ID, OrdIBS1);
        if s<>'' then raise EBOBError.Create(s);
        OrderCode:= IntToStr(OrderID);
        with IBD.DefaultTransaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= sSQL;
        IBS.ParamByName('ORDRCODE').AsInteger:= OrderID;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      end;
      // ���-��� ���������� ��� ����
      currID:= IBS.FieldByName('ORDRCURRENCY').AsInteger;
      CURRENCY:= IBS.FieldByName('ORDRCURRENCY').AsString;
      acctype:= IBS.FieldByName('ORDRACCOUNTINGTYPE').AsString;
      IBS.Close;

      flBonusOrder:= (currID=Cache.BonusCrncCode);
      Ware:= Cache.GetWare(WareID);
      if (flBonusOrder<>ware.IsPrize) then
        raise EBOBError.Create('����� '+Ware.Name+' ������ �������� � ���� �����');

      if not firma.CheckContract(contID) then
        contID:= Cache.arClientInfo[UserId].LastContract;
      Contract:= firma.GetContract(contID);
      if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
        raise EBOBError.Create('�������� '+Contract.Name+' ����������');

      // ��������� ������ ����� ������������� �������      ???
      Storages:= fnGetStoragesArray_2col(Contract, true, True);

      SetLength(WareCodes, 10);
      WareCodes[0]:= WareCode;
      j:= 1;
      AnCodes:= fnGetAllAnalogs(WareID);
      for i:= 0 to High(AnCodes) do
        if Cache.GetWare(AnCodes[i]).IsMarketWare(FirmID, ContID) then begin
          if (High(WareCodes)<j) then SetLength(WareCodes, j+10);
          WareCodes[j]:= IntToStr(AnCodes[i]);
          inc(j);
        end;
      if Length(WareCodes)>j then SetLength(WareCodes, j);
      SetLength(AnCodes, 0);
      WareCount:= Length(WareCodes);

      SetLength(WareQties, WareCount);   // ��������� ��������
      SetLength(WareQty, WareCount);
      for i:= 0 to WareCount-1 do begin
        WareQty[i]:= 0;
        WareQties[i]:= 0;
      end;

      DivisibleMess:= '';
      for i:= 0 to DataCount-1 do begin //------------------ ���������� ��������
        s:= Stream.ReadStr;            // ��������� <��� ������>_<��� ������>
        AnalogQty:= Stream.ReadDouble; // ��������� ���-��

        k:= Pos('_', s);                          // ��� ������ - ����������
        if (k<1) then Continue;

        WareID:= StrToIntDef(Copy(s, 1, k-1), 0);   // ��� ���� ������ - ����������
        if (WareID<1) then Continue;

        j:= fnInStrArray(IntToStr(WareID), WareCodes); // ���� ������ ������
        if (j<0) then Continue;                   // �� ����� - ����������

        k:= StrToIntDef(Copy(s, k+1, 10000), 0);  // ��� ������ - ����������
        if (k<1) then Continue;
        if (k<>Contract.MainStorage) then // �� ����.�����
          raise EBOBError.Create('����� �������� �� ������������� ������ '+
            fnIfStr(OrderExists, '������ '+ordnum, '���������'));

        Ware:= Cache.GetWare(WareID);
        if (flBonusOrder<>ware.IsPrize) then
          raise EBOBError.Create('����� '+Ware.Name+' ������ �������� � ���� �����');

        if (AnalogQty<0) then
          raise EBOBError.Create('����� '+Ware.Name+' - ���������� �� ����� ���� �������������');

        DivisibleMess:= fnRecaclQtyByDivisibleEx(WareID, AnalogQty); // ��������� ���������
        if (DivisibleMess<>'') then raise EBOBError.Create(DivisibleMess);

        WareQties[j]:= AnalogQty;
        WareQty[j]:= WareQty[j]+AnalogQty;
      end;
  //----------------------------------------- ������ ���������� ��������� ������
      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteBool(OrderExists); // ����� �� ������������ ������
      sPos:= Stream.Position;
      Stream.WriteInt(OrderID); // ��� ������ ������. � ���� ����� ������, �� ��� ����� ����� ��� ���-�� ������������ �����.
      ResLineQty:= 0;
      if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
        Stream.WriteStr(AccType); // ��� ������. ����� ��� ������������ ������ �� �������, ����� ���������� ������.
        prSendStorages(Storages, Stream);
      end;

      IBS.SQL.Text:= 'select rNewOrderLnCode, rLineExists from AddOrderLineQty'+
        '('+OrderCode+', :ORDRLNWARE, :WareQty, :ORDRLNWAREMEASURE, :ORDRLNPRICE, 0, 0)';
//        '('+OrderCode+', :ORDRLNWARE, 0, :ORDRLNWAREMEASURE, :ORDRLNPRICE, 0, 0)';

//      OrdIBS1.SQL.Text:='EXECUTE PROCEDURE AEWareByStorages('+OrderCode+
//                        ', :WareCode, :Storage, :WareQty)';

      bon:= Cache.GetPriceBonusCoeff(currID);
      SetLength(AnCodes, 0);
      for i:= 0 to WareCount-1 do begin
        Ware:= Cache.GetWare(StrToInt(WareCodes[i]));
        if not Ware.IsMarketWare(FirmID, ContID) then Continue;
//------------------------------------------------------------------------------
        if fnNotZero(WareQty[i]) then begin
          price:= Ware.SellingPrice(FirmID, currID, ContID);
          with IBS.Transaction do if not InTransaction then StartTransaction;
          IBS.ParamByName('ORDRLNWARE').AsString        := WareCodes[i]; // ��� ������
          IBS.ParamByName('ORDRLNWAREMEASURE').AsInteger:= Ware.MeasId;  // ��.���.
          IBS.ParamByName('ORDRLNPRICE').AsFloat        := price;        // ����
          IBS.ParamByName('WareQty').AsFloat            := WareQties[i];
          for ii:= 1 to RepeatCount do try
            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.ExecQuery;
            if (IBS.Bof and IBS.Eof) then raise Exception.Create('empty IBS');
            LineID:= IBS.FieldByName('rNewOrderLnCode').AsInteger;
            LineExists:= (IBS.FieldByName('rLineExists').AsInteger=1);
            IBS.Transaction.Commit;
            IBS.Close;
            break;
          except
            on E: Exception do begin
              IBS.Transaction.RollbackRetaining;
              LineID:= 0;
              LineExists:= False;
              if (ii<RepeatCount) then sleep(RepeatSaveInterval)
              else raise Exception.Create(E.Message);
            end;
          end;
          if (LineID<1) then raise Exception.Create('������ ������ ������ ������.');

{          // ������ ����������� �� ������� �����
          with OrdIBS1.Transaction do if not InTransaction then StartTransaction;
          OrdIBS1.ParamByName('WareCode').AsString:= WareCodes[i];
          OrdIBS1.ParamByName('Storage').AsString:= Contract.MainStoreStr;
          OrdIBS1.ParamByName('WareQty').AsFloat := WareQties[i];
          s:= RepeatExecuteIBSQL(OrdIBS1);
          if (s<>'') then raise Exception.Create(s);  }

          if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
            // � �������� �� � CGI-������
            Stream.WriteByte(fnIfInt(LineExists, constOpEdit, constOpAdd));
            Stream.WriteInt(LineID);
            Stream.WriteStr(WareCodes[i]);

            HasAnalogs:= (ware.AnalogLinks.LinkCount>0);
            sum:= RoundToHalfDown(price*WareQty[i]); // ����� �� ������

            Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
            Stream.WriteStr(Ware.WareBrandName);
            Stream.WriteStr(Ware.Name);
            Stream.WriteStr(FormatFloat('# ##0', WareQty[i]));
            Stream.WriteStr(Ware.MeasName);
            if (currID=Cache.BonusCrncCode) then begin // unit-�����
              Stream.WriteStr(FloatToStr(RoundToHalfDown(price)));  // ����
              Stream.WriteStr(FloatToStr(sum));                     // ����� �� ������
              Stream.WriteStr('0');
            end else begin                             // ������� �����
              Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));   // ����
              Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));     // ����� �� ������
              Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum*bon)); // ������
            end;
            Stream.WriteStr(trim(FormatFloat('###0.#', WareQties[i])));  // �������� ������� ���-�� ������
            Inc(ResLineQty);
          end; //  if not OrderExists then begin // ���� �� ����� �����, �� �������� ��� ��� ������ ������
//------------------------------------------------------------------------------
        end; // if fnNotZero(WareQty[i])
        IBS.Close;
        OrdIBS1.Close;
      end; // for i:=0 to WareCount-1 do begin

      if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ����� ����� ������ � ������
        with IBS.Transaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= 'SELECT ORDRSUMORDER, OrdrWareLineCount'+
                       ' from ORDERSREESTR where ORDRCODE='+OrderCode;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
        price:= IBS.FieldByName('ORDRSUMORDER').AsFloat;
        if (currID=Cache.BonusCrncCode) then begin // unit-�����
          Stream.WriteStr(FloatToStr(RoundToHalfDown(price)));
          Stream.WriteStr(Cache.GetCurrName(currID, True));
          Stream.WriteStr('0');
        end else begin                             // ������� �����
          Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));
          Stream.WriteStr(Cache.GetCurrName(currID, True));
          Stream.WriteStr(FormatFloat(cFloatFormatSumm, price*bon));
        end;
        Stream.WriteStr(UserMessage);
        Stream.Position:= sPos;
        Stream.WriteInt(ResLineQty); // ���������� ���-�� ������� (������������ �������)

        if (firma.ResLimit>=0) and OrderExists and not flBonusOrder and fnNotZero(price) then begin
          WareCount:= IBS.FieldByName('OrdrWareLineCount').AsInteger;
          IBS.Close;
          IBS.SQL.Clear;               // �������� ���������� ������ ������� �/�
          OverMess:= CheckOrdWaresExAndOverLimit(FirmID, UserID,
                     ContID, OrderID, CurrID, True, False, (WareCount<2), IBS);
        end;
        Stream.Position:= Stream.Size;
        Stream.WriteStr(OverMess);

      end else Stream.WriteStr(UserMessage);
    finally
      prFreeIBSQL(IBS);
      prFreeIBSQL(OrdIBS1);
      cntsORD.SetFreeCnt(IBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
                      ' UID='+IntToStr(UserID)+' FID='+IntToStr(FirmID)+' OID='+OrderCode+
                      ' price='+FormatFloat(cFloatFormatSumm, price), False);
  end;
  Stream.Position:= 0;
  SetLength(Storages, 0);
  SetLength(WareCodes, 0);
  SetLength(WareQty, 0);
  SetLength(AnCodes, 0);
  SetLength(WareQties, 0);
end;
//=========== �������� ����� � ����� ��������������� �� ����������� ������ (Web)
procedure prAddLineFromSearchResToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLineFromSearchResToOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, j, LineID, OrderID, WareID, CurrID, ContID, WareCount: integer;
    s, OrderCode, WareCode, UserMessage, OverMess, ordNum: string;
    OrderExists, flBonusOrder: boolean;
    WareQty, price, bon, sum: double;
    Storages: TaSD;
    Ware: TWareInfo;
    HasAnalogs{, NotSendLine}: Boolean;
    anw: Tai;
    firma: TFirmInfo;
    Contract: TContract;
  //-------------------------------
  procedure AddWareLine; // ������ ������ ������ � �����������
  begin
    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select rNewOrderLnCode from AddOrderLineQty'+
                      '('+OrderCode+', '+WareCode+', :WareQty, '+ // ��� ������, ��� ������, ...
                      IntToStr(Ware.MeasId)+', :ORDRLNPRICE, 0, 0)';
    OrdIBS.ParamByName('ORDRLNPRICE').AsFloat := price;        // ����
    OrdIBS.ParamByName('WareQty').AsFloat     := WareQty;      //
    LineID:= 0;
    s:= RepeatExecuteIBSQL(OrdIBS, 'rNewOrderLnCode', LineID);
    if (s<>'') then raise Exception.Create(s);
    if (LineID<1) then raise Exception.Create('rNewOrderLnCode < 1');
{    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'EXECUTE PROCEDURE AEWareByStorages('+
      OrderCode+', '+WareCode+', '+Contract.MainStoreStr+', :WareQty)';
    OrdIBS.ParamByName('WareQty').AsFloat:= WareQty;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if (s<>'') then raise Exception.Create(s);  }
  end;
  //-------------------------------
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  UserId:= 0;
  FirmId:= 0;
  price:= 0;
  LineID:= 0;
  CurrID:= 0;
  contID:= 0;
  OverMess:= '';
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;
    WareCode:= Stream.ReadStr;
    WareQty:= StrToFloatDef(Stream.ReadStr, 1);
//    NotSendLine:= (Stream.ReadInt=1); // �� ���������� ������

    prSetThLogParams(ThreadData, csAddLineFromSearchResToOrder, UserID, FirmID,
      'WareCode='+WareCode+#13#10'WareQty='+FormatFloat('###0.#', WareQty)+
      #13#10'OrderCode='+OrderCode+#13#10'ContID='+IntToStr(ContID)); // �����������

    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) or Cache.GetWare(WareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, WareCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if (WareQty<0) then
      raise EBOBError.Create('���������� �� ����� ���� �������������');

    firma:= Cache.arFirmInfo[FirmId];
    OrderID:= StrToIntDef(OrderCode, -1);
    OrderCode:= IntToStr(OrderID);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrderExists:= (OrderID>0);
    if OrderExists then begin
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY, ORDRCONTRACT, ORDRNUM FROM ORDERSREESTR'+
        ' WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      OrderExists:= not (OrdIBS.Bof and OrdIBS.Eof);
      if OrderExists then begin       // ���-��� ���������� ��� ����
        CURRID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
        j:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
        if firma.CheckContract(j) then ContID:= j;
        ordNum:= OrdIBS.FieldByName('ORDRNUM').AsString;
      end;
      OrdIBS.Close;
    end;
    if not firma.CheckContract(contID) then
      contID:= Cache.arClientInfo[UserID].LastContract;
    Contract:= firma.GetContract(contID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteBool(OrderExists); // ����� �� ������������ ������

    Ware:= Cache.GetWare(WareID);
//------------------------------------------------------------------- ����� ����
    if OrderExists then begin
      flBonusOrder:= (currID=Cache.BonusCrncCode);
      if (flBonusOrder<>ware.IsPrize) then
        raise EBOBError.Create('����� '+Ware.Name+' ������ �������� � ���� �����');
                                               // ���-��� ���������� ��� ����
      OrdIBS.SQL.Text:= 'Select ORDRLNCODE FROM ORDERSLINES WHERE ORDRLNORDER='+
                        OrderCode+' and ORDRLNWARE='+WareCode;
      OrdIBS.ExecQuery;      // ���� ����� ��� ����, �� �������� ������������
      if not (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create('WareExists');
      OrdIBS.Close;

      UserMessage:= fnRecaclQtyByDivisibleEx(WareID, WareQty);   // ��������� ���������
      if (UserMessage<>'') then raise EBOBError.Create(UserMessage);

      // ��������� ������ ����� ������� ������������� �������
      Storages:= fnGetStoragesArray_2col(Contract, true, True);

      price:= Ware.SellingPrice(FirmID, CURRID, ContID);
      if flBonusOrder then HasAnalogs:= False           // unit-�����
      else HasAnalogs:= (ware.AnalogLinks.LinkCount>0); // ������� �����

      // ������ ���������� ��������� ������
      // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
      prSendStorages(Storages, Stream);

      AddWareLine; // ������ ������ ������ � �����������
      sum:= RoundToHalfDown(price*WareQty);
      bon:= Cache.GetPriceBonusCoeff(CURRID);

      Stream.WriteInt(LineID);        // �������� ���������� ������ � CGI-������
      Stream.WriteStr(WareCode);

      Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(FormatFloat('# ##0', WareQty));
      Stream.WriteStr(Ware.MeasName);
      if flBonusOrder then begin                // unit-�����
        Stream.WriteStr(FloatToStr(RoundToHalfDown(price)));
        Stream.WriteStr(FloatToStr(sum));
        Stream.WriteStr('0');
      end else begin                            // ������� �����
        Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));
        Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum));
        Stream.WriteStr(FormatFloat(cFloatFormatSumm, RoundToHalfDown(price*WareQty*bon)));
      end;
      Stream.WriteStr(trim(FormatFloat('###0.#', WareQty))); // �������� ������� ���-�� ������

      OrdIBS.Close;
      with OrdIBS.Transaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'Select ORDRSUMORDER, OrdrWareLineCount'+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      price:= OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;
      if flBonusOrder then begin                 // unit-�����
        Stream.WriteStr(FloatToStr(RoundToHalfDown(price)));
        Stream.WriteStr(Cache.GetCurrName(CURRID, True));
        Stream.WriteStr('0');
      end else begin                             // ������� �����
        Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));
        Stream.WriteStr(Cache.GetCurrName(CURRID, True));
        Stream.WriteStr(FormatFloat(cFloatFormatSumm, RoundToHalfDown(price*bon)));
      end;
      Stream.WriteStr(UserMessage);

      if (firma.ResLimit>=0) and OrderExists and not flBonusOrder and fnNotZero(price) then begin
        WareCount:= OrdIBS.FieldByName('OrdrWareLineCount').AsInteger;
        OrdIBS.Close;
        OrdIBS.SQL.Clear;              // �������� ���������� ������ ������� �/�
        OverMess:= CheckOrdWaresExAndOverLimit(FirmID, UserID,
                                    ContID, OrderID, CurrID, True, False, (WareCount<2), OrdIBS);
      end;
      Stream.WriteStr(OverMess);

//------------------------------------------------------------------- ��� ������
    end else begin
      //------------------------------------------------------- �������� �����
      if ware.IsPrize then begin
        CurrID:= Cache.BonusCrncCode;
        OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRCONTRACT,'+ // ���� �������� �����
          ' iif(exists(select * from ORDERSLINES where ORDRLNORDER='+OrderCode+
          '   and ORDRLNWARE='+WareCode+'), 1, 0) WareEx'+
          ' from ORDERSREESTR where ORDRFIRM='+IntToStr(FirmID)+
          ' and ORDRSTATUS='+IntToStr(orstForming)+' and ORDRCURRENCY='+IntToStr(CurrID);
        OrdIBS.ExecQuery;
        if not (OrdIBS.Bof and OrdIBS.Eof) then begin // �����
          if (OrdIBS.FieldByName('WareEx').AsInteger>0) then // ����� ����� � ������ ����
            raise Exception.Create('WareExists');
          contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger; // ��� ������
          OrderID:= OrdIBS.FieldByName('ORDRCODE').AsInteger;    // ��� �����
          OrdIBS.Close;
        end else begin // ���� ��� - ������� ����� �������� �����
          OrdIBS.Close;
//          contID:= Cache.arClientInfo[UserID].LastContract;
          contID:= 0;
          prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, contID, s, ThreadData.ID, OrdIBS, CurrID);
          if (s<>'') then raise EBOBError.Create(s);
        end;
        OrderCode:= IntToStr(OrderID);

      //-------------------------------------------------------- ������� �����
      end else begin                   // �������
        prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, s, ThreadData.ID, OrdIBS);
        if s<>'' then raise EBOBError.Create(s);
        OrderCode:= IntToStr(OrderID);
        with OrdIBD.DefaultTransaction do if not InTransaction then StartTransaction;
        OrdIBS.SQL.Text:= 'Select ORDRCURRENCY FROM ORDERSREESTR'+
          ' WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
        OrdIBS.ExecQuery;              // ���-��� ���������� ��� ����
        if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
        CURRID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
        OrdIBS.Close;
      end;

      UserMessage:= fnRecaclQtyByDivisibleEx(WareID, WareQty);   // ��������� ���������
      if (UserMessage<>'') then raise EBOBError.Create(UserMessage);

      price:= Ware.SellingPrice(FirmID, CURRID, ContID);
      //-------------------------------- ������ ���������� ��������� ������
      AddWareLine; // ������ ������ ������ � �����������
      Stream.WriteStr(UserMessage);
      Stream.WriteStr(OrderCode);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do if (E.Message='WareExists') then begin
        Stream.Clear;
        Stream.WriteInt(erFindedDouble)
      end else prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
        ' UID='+IntToStr(UserID)+' FID='+IntToStr(FirmID)+' OID='+OrderCode+
        ' price='+FormatFloat(cFloatFormatSumm, price), False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(Storages, 0);
  SetLength(anw, 0);
end;
//================================== ������ �������� ��� ����� ����������� �����
procedure prGetRegisterTableOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetRegisterTableOrd'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    j, sPos: integer;
begin
  ibs:= nil;
  ibd:= nil;
  Stream.Position:= 0;
  try
    prSetThLogParams(ThreadData, csGetRegisterTable, 0, 0, ''); // �����������

    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select RGZNCODE, RGZNNAME from REGIONALZONES z'+
                   ' where not RGZNNAME="" and not z.rgznemail="" order by RGZNNAME';
    ibs.ExecQuery;
    if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� �����
    j:= 0; // �������
    while not ibs.EOF do begin
      Stream.WriteInt(ibs.FieldByName('RGZNCODE').AsInteger);
      Stream.WriteStr(ibs.FieldByName('RGZNNAME').AsString);
      inc(j);
      TestCssStopException;
      ibs.Next;
    end;
    ibs.Close;
    Stream.Position:= sPos;
    Stream.WriteInt(j);
  except
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(ibd);
  Stream.Position:= 0;
end;
//============================= ������ ������ �� ����������� ����� � ������� ���
procedure prSaveRegOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveRegOrderOrd'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    Firm, FIO, Post, Login, Address, Phones, Email, IP, s, RegName, RegMail,
      link, Town, sFirmType, sRegion: string;
    IsClient: boolean;
    Region, FirmType, dprtID,i: integer;
    Strings: TStringList;
  //------------------------------- ������ ��������
  procedure SetIbsParams;
  begin
    ibs.ParamByName('OREGFIRMNAME').AsString    := Firm;
    ibs.ParamByName('OREGREGION').AsInteger     := Region;
    ibs.ParamByName('OREGMAINUSERFIO').AsString := FIO;
    ibs.ParamByName('OREGMAINUSERPOST').AsString:= Post;
    ibs.ParamByName('OREGLOGIN').AsString       := Login;
    ibs.ParamByName('OREGCLIENT').AsString      := fnIfStr(IsClient, 'T', 'F');
    ibs.ParamByName('OREGADDRESS').AsString     := Address;
    ibs.ParamByName('OREGPHONES').AsString      := Phones;
    ibs.ParamByName('OREGEMAIL').AsString       := Email;
    ibs.ParamByName('OREGTYPE').AsInteger       := FirmType;
    ibs.ParamByName('OREGIP').AsString          := IP;
    ibs.ParamByName('OREGDPRTCODE').AsInteger   := dprtID;
  end;
  //-------------------------------
begin
  Stream.Position:= 0;
  link:= 'order';
  dprtID:= 0;
  ibs:= nil;
  ibd:= nil;
  Strings:= nil;
  try
    Firm:= trim(Stream.ReadStr);
    sRegion:= trim(Stream.ReadStr);
    FIO:= trim(Stream.ReadStr);
    Post:= trim(Stream.ReadStr);
    Login:= trim(Stream.ReadStr);
    IsClient:= trim(Stream.ReadStr)='1';
    Town:= trim(Stream.ReadStr);
    Address:= trim(Stream.ReadStr);
    Phones:= trim(Stream.ReadStr);
    Email:= trim(Stream.ReadStr);
    sFirmType:= trim(Stream.ReadStr);
    IP:= trim(Stream.ReadStr);

    prSetThLogParams(ThreadData, csSaveRegOrder, 0, 0, 'Firm='+Firm+ // �����������
      #13#10' Region='+sRegion+#13#10' FIO='+FIO+#13#10' Post='+Post+
      #13#10' Login='+Login+#13#10+fnIfStr(IsClient, 'is Client', 'not Client')+
      #13#10' Town='+Town+#13#10' Address='+Address+#13#10' Phones='+Phones+
      #13#10' Email='+Email+#13#10' FirmType='+sFirmType+#13#10' IP='+IP);

    Region:= StrToInt(sRegion);
    FirmType:= StrToInt(sFirmType);

    if (Firm='') then raise EBOBError.Create('�� ������ ������������ ������������.');
    if (FIO='') then raise EBOBError.Create('�� ������ ��� �������� ������������.');
    if (Post='') then raise EBOBError.Create('�� ������ ��������� �������� ������������.');
    if (Town='') then raise EBOBError.Create('�� ����� �����/���');
    if (Address='') then raise EBOBError.Create('�� ����� �����');
    if (Phones='') then raise EBOBError.Create('�� ����� �������');
    if (Email='') then raise EBOBError.Create('�� ����� Email');
    if not fnCheckEmail(Email) then raise EBOBError.Create('������������ Email');
    if (not FirmType in [0..3]) then raise EBOBError.Create('������������ ��� �����������');
    if (Login='') then raise EBOBError.Create('�� ����� ����� �������� ������������');
    if not fnCheckOrderWebLogin(Login) then  // ��������� �����
      raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
    if not fnNotLockingLogin(Login) then // ���������, �� ��������� �� ����� � �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));

    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'Select WOCLCODE from WEBORDERCLIENTS where WOCLUPPERLOGIN='+QuotedStr(UpperCase(Login));
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then // ���������, �� ��������� �� ����� � ��� �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));
    ibs.Close;

    ibs.SQL.Text:= 'select RGZNNAME, RGZNFILIALLINK'+  // , RGZNEMAIL
      ' from REGIONALZONES WHERE RGZNCODE='+IntToStr(Region);
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise EBOBError.Create('������������ ������.');
    dprtID:= ibs.FieldByName('RGZNFILIALLINK').AsInteger;
    RegName:= ibs.FieldByName('RGZNNAME').AsString;
//    RegMail:= ibs.FieldByName('RGZNEMAIL').AsString;
    ibs.Close;

    if Cache.DprtExist(dprtID) and Cache.arDprtInfo[dprtID].IsFilial then begin
      s:= Cache.arDprtInfo[dprtID].MailOrder;
      link:= copy(s, 1, pos('@', s)-1);
    end else dprtID:= Cache.arDprtInfo[1].FilialID; // �����

    Strings:= TStringList.Create;      // ������� ������ � ������������� ����������
    Strings.Add('�����������: '+Firm);
    Strings.Add('������: '+RegName);
    Strings.Add('�����/���: '+Town);
    Strings.Add('�����: '+Address);
    Strings.Add('��� �������� ������������: '+FIO);
    Strings.Add('��������� �������� ������������: '+Post);
    Strings.Add('����� �������� ������������: '+Login);
    Strings.Add('������ ��������: '+fnIfStr(IsClient, '��', '���'));
    Strings.Add('�������: '+Phones);
    Strings.Add('Email: '+Email);
    case FirmType of
      0: s:= '���';
      1: s:= '�������';
      2: s:= '���� �������';
      else s:= '������';
    end;
    Strings.Add('��� �����������: '+s);

    Address:= Town+', '+Address;
                                // �������� ��������� �������� �� �������� �����
    ibs.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
    ' from rdb$relation_fields f, rdb$fields ff'+
    ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE and f.RDB$RELATION_NAME=:table';
    ibs.ParamByName('table').AsString:= 'ORDERTOREGISTER';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      s:= trim(ibs.FieldByName('fname').AsString);
      i:= ibs.FieldByName('fsize').AsInteger;
      if (s='OREGFIRMNAME')          and (length(Firm)>i)    then Firm:= Copy(Firm, 1, i)
      else if (s='OREGMAINUSERFIO')  and (length(FIO)>i)     then FIO:= Copy(FIO, 1, i)
      else if (s='OREGMAINUSERPOST') and (length(Post)>i)    then Post:= Copy(Post, 1, i)
      else if (s='OREGLOGIN')        and (length(Login)>i)   then Login:= Copy(Login, 1, i)
      else if (s='OREGADDRESS')      and (length(Address)>i) then Address:= Copy(Address, 1, i)
      else if (s='OREGPHONES')       and (length(Phones)>i)  then Phones:= Copy(Phones, 1, i)
      else if (s='OREGEMAIL')        and (length(Email)>i)   then Email:= Copy(Email, 1, i)
      else if (s='OREGIP')           and (length(IP)>i)      then IP:= Copy(IP, 1, i);
      TestCssStopException;
      ibs.Next;
    end;  
    ibs.Close;
                                   // ���������, ��� �� ��� ����� ������
    ibs.SQL.Text:= 'select OREGCODE FROM ORDERTOREGISTER'+
      ' where OREGFIRMNAME=:OREGFIRMNAME and OREGREGION=:OREGREGION'+
      ' and OREGMAINUSERFIO=:OREGMAINUSERFIO and OREGMAINUSERPOST=:OREGMAINUSERPOST'+
      ' and OREGLOGIN=:OREGLOGIN and OREGCLIENT=:OREGCLIENT'+
      ' and OREGADDRESS=:OREGADDRESS and OREGPHONES=:OREGPHONES'+
      ' and OREGEMAIL=:OREGEMAIL and OREGTYPE=:OREGTYPE'+
      ' and OREGIP=:OREGIP and OREGDPRTCODE=:OREGDPRTCODE';
    SetIbsParams; // ������ ��������
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then
      raise EBOBError.Create('����� ������ ��� ���������������� � �������.');
    ibs.Close;

    fnSetTransParams(ibs.Transaction, tpWrite, True);
    ibs.SQL.Text:= 'insert into ORDERTOREGISTER'+
      ' (OREGFIRMNAME, OREGREGION, OREGMAINUSERFIO, OREGMAINUSERPOST,'+
      ' OREGLOGIN, OREGCLIENT, OREGADDRESS, OREGPHONES,'+
      ' OREGEMAIL, OREGTYPE, OREGIP, OREGDPRTCODE) values'+
      ' (:OREGFIRMNAME, :OREGREGION, :OREGMAINUSERFIO, :OREGMAINUSERPOST,'+
      ' :OREGLOGIN, :OREGCLIENT, :OREGADDRESS, :OREGPHONES,'+
      ' :OREGEMAIL, :OREGTYPE, :OREGIP, :OREGDPRTCODE)';
    SetIbsParams; // ������ ��������
    s:= RepeatExecuteIBSQL(IBS);
    if s<>'' then raise Exception.Create(s);

    RegMail:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ��
    s:= n_SysMailSend(RegMail, '������ �� ����������� � ������� ���', Strings, nil, '', '', true);
    if s<>'' then fnWriteToLog(ThreadData, lgmsCryticalSysError, nmProc,
      '������ �������� ������ � ����� ������ �� �����������: ', s, '');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(link);
  except
    on E: EBOBError do begin
      Stream.Clear;
      Stream.WriteInt(erMissRegData);
      Stream.WriteStr(fnReplaceQuotedForWeb(E.Message));
    end;
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(ibd);
  prFree(Strings);
  Stream.Position:= 0;
end;
//==================================== ������ ������� ��� ����� ����������� UBER
procedure prGetRegisterUberTowns(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetRegisterUberTowns'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    j: integer;
    lst, ls: TStringList;
begin
  ibs:= nil;
  ibd:= nil;
  Stream.Position:= 0;
  lst:= fnCreateStringList(True, dupIgnore);
  ls:= TStringList.Create;
  try
    prSetThLogParams(ThreadData, csGetRegisterUberTowns, 0, 0, ''); // �����������

    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select RGZNuberTowns from REGIONALZONES z'+
                   ' where RGZNuberTowns is not null and RGZNuberTowns<>""';
    ibs.ExecQuery;
    while not ibs.EOF do begin
      ls:= fnSplit(',', ibs.FieldByName('RGZNuberTowns').AsString);
      try
        for j:= 0 to ls.Count-1 do lst.Add(ls[j]);
      finally
        ls.Clear;
      end;
      TestCssStopException;
      ibs.Next;
    end;
    ibs.Close;
    if (lst.Count<1) then raise EBOBError.Create('�� ������ ������ �������');
    if (lst.Count>1) then lst.Sort;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(lst.Count); // ���-�� �����
    for j:= 0 to lst.Count-1 do Stream.WriteStr(lst[j]);

  except
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(ibd);
  prFree(lst);
  prFree(ls);
  Stream.Position:= 0;
end;
//============================== ������ ������ �� ����������� UBER � ������� ���
procedure prSaveRegOrderUber(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveRegOrderUber'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    Firm, FIO, Login, Phone, Email, IP, s, RegName, RegMail, link, Town, Card: string;
    Region, dprtID, i: integer;
    Strings: TStringList;
  //------------------------------- ������ ��������
  procedure SetIbsParams;
  begin
    ibs.ParamByName('OREGFIRMNAME').AsString    := Firm;
    ibs.ParamByName('OREGREGION').AsInteger     := Region;
    ibs.ParamByName('OREGMAINUSERFIO').AsString := FIO;
    ibs.ParamByName('OREGMAINUSERPOST').AsString:= '-';    // ���������
    ibs.ParamByName('OREGLOGIN').AsString       := Login;
    ibs.ParamByName('OREGADDRESS').AsString     := Town;
    ibs.ParamByName('OREGPHONES').AsString      := Phone;
    ibs.ParamByName('OREGEMAIL').AsString       := Email;
    ibs.ParamByName('OREGTYPE').AsInteger       := 3;      // ������
    ibs.ParamByName('OREGIP').AsString          := IP;
    ibs.ParamByName('OREGDPRTCODE').AsInteger   := dprtID;
  end;
  //-------------------------------
begin
  Stream.Position:= 0;
  link:= 'order';
  ibs:= nil;
  ibd:= nil;
  Strings:= nil;
  Region:= 0;
  dprtID:= 0;
  RegName:= '';
  try
    Card:= trim(Stream.ReadStr);   // ����� ����� UBER
    Town:= trim(Stream.ReadStr);   // ����� (���� - ����, ������, �������, �����, �����)
    FIO:= trim(Stream.ReadStr);    // ���
    Phone:= trim(Stream.ReadStr);  // �������
    Email:= trim(Stream.ReadStr);  // E-mail
    IP:= trim(Stream.ReadStr);

    prSetThLogParams(ThreadData, csSaveRegOrderUber, 0, 0, 'Card='+Card+ // �����������
      #13#10' Town='+Town+#13#10' FIO='+FIO+#13#10' Phone='+Phone+
      #13#10' Email='+Email+#13#10' IP='+IP);

    if (Card='')  then raise EBOBError.Create('�� ����� N �����.');
    if (FIO='')   then raise EBOBError.Create('�� ������ ��� ������������.');
    if (Town='')  then raise EBOBError.Create('�� ����� �����');
    if (Email='') then raise EBOBError.Create('�� ����� Email');
    if not fnCheckEmail(Email) then raise EBOBError.Create('������������ Email');
    if (Phone='') then raise EBOBError.Create('�� ����� �������');
//    if not CheckMobileNumber(Phone) then raise EBOBError.Create('������������ ����� ���������� ��������');
    Login:= GetMobileNumber10(Phone); // ����� ���������� �������� ��� +38 ��� �����, ���� ����� ������������
    if (Login='') then raise EBOBError.Create('������������ ����� ���������� ��������');
    Phone:= '+38'+Login; // �������� � ���/���
    Firm:= 'UBER '+Card;

{   if not fnCheckOrderWebLogin(Login) then  // ��������� �����
      raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
    if not fnNotLockingLogin(Login) then // ���������, �� ��������� �� ����� � �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));   }

    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'Select WOCLCODE from WEBORDERCLIENTS where WOCLUPPERLOGIN='+QuotedStr(UpperCase(Login));
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then // ���������, �� ��������� �� ����� � ��� �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));
    ibs.Close;

    ibs.SQL.Text:= 'select RGZNCODE, RGZNNAME, RGZNFILIALLINK from REGIONALZONES'+
      ' WHERE ","||RGZNuberTowns||"," containing ",'+Town+',"';
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise EBOBError.Create('�� ������ ������.');
    Region:= ibs.FieldByName('RGZNCODE').AsInteger;
    dprtID:= ibs.FieldByName('RGZNFILIALLINK').AsInteger;
    RegName:= ibs.FieldByName('RGZNNAME').AsString;
    ibs.Close;

    if Cache.DprtExist(dprtID) and Cache.arDprtInfo[dprtID].IsFilial then begin
      s:= Cache.arDprtInfo[dprtID].MailOrder;
      link:= copy(s, 1, pos('@', s)-1);
    end else dprtID:= Cache.arDprtInfo[1].FilialID; // �����

    Strings:= TStringList.Create;      // ������� ������ � ������������� ����������
    Strings.Add('������������: '+Firm);
    Strings.Add('�����: '+Town);
    Strings.Add('��� ������������: '+FIO);
    Strings.Add('�������: '+Phone);
    Strings.Add('Email: '+Email);
    Strings.Add('����� ������������: '+Login);
    Strings.Add('������: '+RegName);
                                // �������� ��������� �������� �� �������� �����
    ibs.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
    ' from rdb$relation_fields f, rdb$fields ff'+
    ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE and f.RDB$RELATION_NAME=:table';
    ibs.ParamByName('table').AsString:= 'ORDERTOREGISTER';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      s:= trim(ibs.FieldByName('fname').AsString);
      i:= ibs.FieldByName('fsize').AsInteger;
      if (s='OREGFIRMNAME')          and (length(Firm)>i)  then Firm := Copy(Firm, 1, i)
      else if (s='OREGMAINUSERFIO')  and (length(FIO)>i)   then FIO  := Copy(FIO, 1, i)
      else if (s='OREGLOGIN')        and (length(Login)>i) then Login:= Copy(Login, 1, i)
      else if (s='OREGADDRESS')      and (length(Town)>i)  then Town := Copy(Town, 1, i)
      else if (s='OREGPHONES')       and (length(Phone)>i) then Phone:= Copy(Phone, 1, i)
      else if (s='OREGEMAIL')        and (length(Email)>i) then Email:= Copy(Email, 1, i)
      else if (s='OREGIP')           and (length(IP)>i)    then IP   := Copy(IP, 1, i);
      TestCssStopException;
      ibs.Next;
    end;
    ibs.Close;
                                   // ���������, ��� �� ��� ����� ������
    ibs.SQL.Text:= 'select OREGCODE FROM ORDERTOREGISTER'+
      ' where OREGFIRMNAME=:OREGFIRMNAME and OREGREGION=:OREGREGION'+
      ' and OREGMAINUSERFIO=:OREGMAINUSERFIO and OREGLOGIN=:OREGLOGIN'+
      ' and OREGMAINUSERPOST=:OREGMAINUSERPOST and OREGCLIENT=:OREGCLIENT'+
      ' and OREGADDRESS=:OREGADDRESS and OREGPHONES=:OREGPHONES'+
      ' and OREGEMAIL=:OREGEMAIL and OREGTYPE=:OREGTYPE'+
      ' and OREGIP=:OREGIP and OREGDPRTCODE=:OREGDPRTCODE';
    SetIbsParams; // ������ ��������
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then
      raise EBOBError.Create('����� ������ ��� ���������������� � �������.');
    ibs.Close;

    fnSetTransParams(ibs.Transaction, tpWrite, True); // ����� ������ � ����
    ibs.SQL.Text:= 'insert into ORDERTOREGISTER (OREGFIRMNAME, OREGREGION,'+
      ' OREGMAINUSERFIO, OREGMAINUSERPOST, OREGLOGIN, OREGADDRESS, OREGPHONES,'+
      ' OREGEMAIL, OREGTYPE, OREGIP, OREGDPRTCODE) values (:OREGFIRMNAME,'+
      ' :OREGREGION, :OREGMAINUSERFIO, :OREGMAINUSERPOST, :OREGLOGIN,'+
      ' :OREGADDRESS, :OREGPHONES, :OREGEMAIL, :OREGTYPE, :OREGIP, :OREGDPRTCODE)';
    SetIbsParams; // ������ ��������
    s:= RepeatExecuteIBSQL(IBS);
    if s<>'' then raise Exception.Create(s);

    RegMail:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ��
    s:= n_SysMailSend(RegMail, '������ �� ����������� UBER � ������� ���', Strings, nil, '', '', true);
    if s<>'' then fnWriteToLog(ThreadData, lgmsCryticalSysError, nmProc,
      '������ �������� ������ � ����� ������ �� ����������� UBER: ', s, '');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(link);
  except
    on E: EBOBError do begin
      Stream.Clear;
      Stream.WriteInt(erMissRegData);
      Stream.WriteStr(fnReplaceQuotedForWeb(E.Message));
    end;
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(ibd);
  prFree(Strings);
  Stream.Position:= 0;
end;

//******************************************************************************
//================ ���������� ���-�� ������ � ������ � ������������ � ����������
function fnRecaclQtyByDivisible(WareID: integer; var WareQty: double): string;
var Ware: TWareInfo;
    d: Double;
begin
  Result:= '';
  Ware:= Cache.GetWare(WareID);
  d:= WareQty/Ware.Divis;
  if not (fnNotZero(d-Round(d))) then Exit;
  WareQty:= (Trunc(d)+1)*Ware.Divis;
  Result:= '���-�� ������ �������� �� '+FormatFloat('# ##0.#', WareQty)+
    ' � ������������ � ���������� '+FormatFloat('# ##0.#', Ware.Divis);
end;
//============================ ��������� ������������ ���-�� ������ � ����������
function fnRecaclQtyByDivisibleEx(WareID: integer; WareQty: double): string;
var Ware: TWareInfo;
    d: Double;
begin
  Result:= '';
  Ware:= Cache.GetWare(WareID);
  d:= WareQty/Ware.Divis;
  if not fnNotZero(d-Round(d)) then Exit;
  WareQty:= (Trunc(d)+1)*Ware.Divis;
  Result:= '���-�� ������ '+Ware.Name+' �� ������������� ��������� '+
    FormatFloat('# ##0.#', Ware.Divis)+', ����������� �������� '+FormatFloat('# ##0.#', WareQty);
end;
//************************************ ��� ������ �������� � 1/2/3 ������� (Web)
procedure prGetQtyByAnalogsAndStoragesOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetQtyByAnalogsAndStoragesOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserID, FirmID, i, ia, StorageCount, WareCount, WareID, sPos, currID, aCode: integer;
    s, WareCode, OrderCode, ErrPos, PriceFormat, ActTitle, ActText: string;
    Storages: TaSD;
    WareQty, WareTotal: double;
    qty, qty0, qty1, qty2: double;
    OrderExists, WareOrAnalogInOrder, flAdd: boolean;
    Ware: TWareInfo;
//    OList: TObjectList;
    ar: Tai;
    firma: TFirmInfo;
    arOrderWareQties: Tas;
    owID, owIndex: integer;
    contID: integer;
    Contract: TContract;
    prices, rests: TDoubleDynArray;
//    wa: TWareAction;
begin

if flNewRestCols then begin
  prGetQtyByAnalogsAndStorages_new(Stream, ThreadData);
  exit;
end;

  Stream.Position:= 0;
  FirmID:= 0;
  UserID:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  SetLength(ar, 0);
  SetLength(arOrderWareQties, 0);
  OrderExists:= false;
  WareTotal:= 0;
  WareOrAnalogInOrder:= false;
  WareQty:= -1;
  contID:= 0;
  currID:= 0;
  try
ErrPos:= '1';
    try
      UserID:= Stream.ReadInt;
      FirmID:= Stream.ReadInt;
      ContID:= Stream.ReadInt; // ��� ����������
      OrderCode:= trim(Stream.ReadStr);
      WareCode:= trim(Stream.ReadStr);
      WareQty:= Stream.ReadDouble;
      if (WareQty<constDeltaZero) then WareQty:= 1;
ErrPos:= '2';
    finally
      prSetThLogParams(ThreadData, csGetQtyByAnalogsAndStorages, UserID, FirmID,
        'OrderCode='+OrderCode+', WareCode='+WareCode+', WareQty='+FloatToStr(WareQty)+
        #13#10'ContID='+IntToStr(ContID)); // �����������
    end;
ErrPos:= '3';
    aCode:= StrToIntDef(OrderCode, 0);
    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) then raise Exception.Create(MessText(mtkNotFoundWare, WareCode));
ErrPos:= '4';
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    firma:= Cache.arFirmInfo[FirmID];
    Cache.arClientInfo[UserID].CheckQtyCount; // ������� �������� �������

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrderExists:= (aCode>0);

    if OrderExists then try
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY, ORDRLNCODE, ORDRCONTRACT FROM ORDERSREESTR'+
        ' left join ORDERSLINES on ORDRLNORDER=ORDRCODE and ORDRLNWARE='+WareCode+
        ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId)+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      OrderExists:= not (OrdIBS.Bof and OrdIBS.Eof);
      if OrderExists then begin // ���� ����� ��� ���� � ������ - ����� ����� ������������ ����
        WareOrAnalogInOrder:= not OrdIBS.FieldByName('ORDRLNCODE').IsNull;
        currID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
        contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
      end;
    finally
      OrdIBS.Close;
    end;

    Contract:= firma.GetContract(contID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');
//    if (not OrderExists) then Currency:= IntToStr(Contract.DutyCurrency); // ���� ������ ���, ����� ������ �� �������� ���������
    if not OrderExists then  // ���� ������ ���
      currID:= Cache.arClientInfo[UserID].SearchCurrencyID;  // ����� ������ �� �������� ������������

ErrPos:= '5';
    ar:= fnGetAllAnalogs(WareID);
ErrPos:= '6';
    Storages:= fnGetStoragesArray_2col(Contract); // ��������� ������ ����� ������� - 2 �������
    StorageCount:= Length(Storages);
    flAdd:= (StorageCount>2);

    if OrderExists then try
      SetLength(arOrderWareQties, Length(ar)+1); // ������� ����.�����(������ 0), ����� �������(������� �� 1)
      for i:= 0 to High(arOrderWareQties) do arOrderWareQties[i]:= '0';

      OrdIBS.SQL.Text:= 'Select ORDRLNCLIENTQTY, ORDRLNWARE FROM ORDERSLINES'+
                        ' WHERE ORDRLNORDER='+OrderCode+' order by ORDRLNWARE';
ErrPos:= '11';
      OrdIBS.ExecQuery; // ���������� ��������� ���������� �� ������ � ������
      while not OrdIBS.Eof do begin
        owID:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger; // ���� ������ ������
        if (owID=WareID) then owIndex:= 0   // ������� ����.�����
        else begin
          owIndex:= fnInIntArray(owID, ar); // ����� �������
          if (owIndex>-1) then Inc(owIndex);
        end;
        qty:= 0;
        while not OrdIBS.Eof and (owID=OrdIBS.FieldByName('ORDRLNWARE').AsInteger) do begin
//          if (owIndex>-1) then qty:= qty+OrdIBS.FieldByName('OWBSQTY').AsFloat;
          if (owIndex>-1) then qty:= qty+OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
          TestCssStopException;
          OrdIBS.Next;
        end;
        if fnNotZero(qty) then arOrderWareQties[owIndex]:= trim(FormatFloat('###0.#', qty));
      end; // while not OrdIBS.Eof
    finally
      OrdIBS.Close;
    end; // if OrderExists

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� ������������ �������. �������� ���� �� ���
                        // �������� �����, �� ���� ������� ����� ������������ ��� ���������� �����
    Stream.WriteStr(Cache.GetCurrName(currID, True)); //
    Stream.WriteStr(FormatFloat('###0.#', WareQty)); //
    Stream.WriteStr(WareCode); //
    prSendStorages(Storages, Stream);

    WareCount:= 0;
    for ia:= 0 to High(ar)+1 do begin
      if (ia=0) then Ware:= Cache.GetWare(WareID) else Ware:= Cache.GetWare(ar[ia-1]);
      Stream.WriteInt(Ware.ID);            // ��� ������
      Stream.WriteStr(Ware.PgrName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteBool(Ware.IsSale);       // ������� ����������
      Stream.WriteBool(ware.IsNonReturn);  // ������� ����������
      Stream.WriteBool(ware.IsCutPrice);   // ������� ������
      Stream.WriteStr(Ware.PrDirectName);  // �������� ����������� �� ���������

      aCode:= Ware.GetActionParams(ActTitle, ActText);
      Stream.WriteInt(aCode);         // ��� �����
      Stream.WriteStr(ActTitle);      // ���������
      Stream.WriteStr(ActText);       // �����

//------------------------------------------------- ���� �������
      prices:= ware.CalcFirmPrices(FirmID, currID, contID); // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
      if Ware.IsPrize then PriceFormat:= '# ##0.#' else PriceFormat:= cFloatFormatSumm;
      for i:= 0 to High(prices) do Stream.WriteStr(trim(FormatFloat(PriceFormat, prices[i])));
//------------------------------------------------- ���� �������
      Stream.WriteStr(Ware.MeasName);
//      qty0:= 0; // ���-�� �� ������ �� ���������
//      qty1:= 0; // ���-�� �� ��������� ������� �������
//      qty2:= 0; // ���-�� �� ������� ���.���������
      rests:= GetContWareRestsByCols(ware.ID, ContID, StorageCount);
      qty0:= rests[0];                                        // ���-�� �� ������ �� ���������
      if (StorageCount>1) then qty1:= rests[1] else qty1:= 0; // ���-�� �� ������� �������� �� ������
      if flAdd then qty2:= rests[2] else qty2:= 0;             // ���-�� �� ������� �������� > 1 ���

      Stream.WriteStr(fnRestValuesForWeb(WareQty, qty0)); // 1 - ���-�� �� ������ �� ���������
      if (ia=0) then begin // �����
        WareTotal:= qty0+qty1+qty2;
        if WareOrAnalogInOrder then s:= arOrderWareQties[ia]  // �������� ������� ���-�� ������
        else s:= FormatFloat('###0.#', WareQty); // � ������ ����� ������ ������� �������������� ��������
      end else begin       // ������
        if OrderExists then s:= arOrderWareQties[ia] else s:= '0';
      end;
      Stream.WriteStr(s);

      Stream.WriteStr(fnRestValuesForWeb(WareQty, qty1)); // 2 - ���-�� �� ������� �������� �� ������
      if flAdd then
        Stream.WriteStr(fnRestValuesForWeb(WareQty, qty2)); // 3 - ���-�� �� ������� �������� > 1 ���

      Inc(WareCount);
    end;

    Stream.Position:= sPos;
    Stream.WriteInt(WareCount); // ���������� ���-�� ������� (������������ �������)

//---------------- ���������� ���� �������� ������������ ��� ����������� �������
ErrPos:= '18-1';
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.Text:= 'INSERT INTO WareRequests (WRWAREID, WRUSERID, WRFROM,'+
      ' WRQTY, WRREST, WRTIME)VALUES ('+WareCode+', '+IntToStr(UserID)+', '+
      fnIfStr(OrderExists, '1', '0')+', :clientqty, :totalqty, "NOW")';
    OrdIBS.ParamByName('clientqty').AsFloat:= WareQty;
    OrdIBS.ParamByName('totalqty').AsFloat:= WareTotal;
ErrPos:= '18-2';
    s:= RepeatExecuteIBSQL(OrdIBS);
    if (s<>'') then fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', s, 'ErrPos='+ErrPos);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrPos='+ErrPos, False);
  end;
  Stream.Position:= 0;
  SetLength(ar, 0);
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  SetLength(Storages, 0);
  SetLength(prices, 0);
  SetLength(rests, 0);
  if OrderExists then SetLength(arOrderWareQties, 0);
//  prFree(OList);
end;
//============================= ��� ������ �������� �� �������� ���������� (Web)
procedure prGetQtyByAnalogsAndStorages_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetQtyByAnalogsAndStorages_new'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserID, FirmID, i, ia, StorageCount, WareCount, WareID, sPos, currID, aCode: integer;
    s, WareCode, OrderCode, ErrPos, PriceFormat, ActTitle, ActText: string;
    Storages: TaSD;
    WareQty, WareTotal, OrderQty: double;
    qty, qty0, qty1, qty2: double;
    OrderExists, flAdd, flOnlyWare: boolean;
    Ware: TWareInfo;
    ar: Tai;
    firma: TFirmInfo;
    arOrderWareQties: Tas;
    owID, owIndex: integer;
    contID: integer;
    Contract: TContract;
    prices, rests: TDoubleDynArray;
    wrba: TWareRestsByArrive;
begin
  Stream.Position:= 0;
  FirmID:= 0;
  UserID:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  SetLength(ar, 0);
  SetLength(arOrderWareQties, 0);
  OrderExists:= false;
  WareTotal:= 0;
  WareQty:= -1;
  contID:= 0;
  currID:= 0;
  OrderQty:= 0;
  flOnlyWare:= False;
  try
ErrPos:= '1';
    try
      UserID:= Stream.ReadInt;
      FirmID:= Stream.ReadInt;
      ContID:= Stream.ReadInt; // ��� ����������
      OrderCode:= trim(Stream.ReadStr);
      WareCode:= trim(Stream.ReadStr);
      WareQty:= Stream.ReadDouble;
      if not fnNotZero(WareQty) then WareQty:= 1;
if flNewRestCols then
      try
        flOnlyWare:= Stream.ReadBool;  // ������ ����� (����� �� ���-��� ������)
      except
        flOnlyWare:= False;
      end;
    finally
      prSetThLogParams(ThreadData, csGetQtyByAnalogsAndStorages, UserID, FirmID,
        'OrderCode='+OrderCode+', WareCode='+WareCode+', WareQty='+FloatToStr(WareQty)+
        #13#10'ContID='+IntToStr(ContID)+#13#10'OnlyWare='+BoolToStr(flOnlyWare)); // �����������
    end;

    aCode:= StrToIntDef(OrderCode, 0);
    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) then
      raise Exception.Create(MessText(mtkNotFoundWare, WareCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    firma:= Cache.arFirmInfo[FirmID];
    Cache.arClientInfo[UserID].CheckQtyCount; // ������� �������� �������

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrderExists:= (aCode>0);

    if OrderExists then try
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY, ORDRCONTRACT'+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+
        IntToStr(FirmId)+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      OrderExists:= not (OrdIBS.Bof and OrdIBS.Eof);
      if OrderExists then begin
        currID:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
        contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
      end;
    finally
      OrdIBS.Close;
    end;

    Contract:= firma.GetContract(contID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');

    if not OrderExists then  // ���� ������ ���
      currID:= Cache.arClientInfo[UserID].SearchCurrencyID;  // ����� ������ �� �������� ������������
//      Currency:= IntToStr(Contract.DutyCurrency); // ���� ������ ���, ����� ������ �� �������� ���������
ErrPos:= '5';

    if not flOnlyWare then ar:= fnGetAllAnalogs(WareID); // ������� ������

ErrPos:= '6';
    wrba:= TWareRestsByArrive.Create; // ������ ��� ������� �������� �� ����������
    SetLength(wrba.arWares, Length(ar)+1); // 0- ��� ������, 1... - ���� ��������
    // ������� ����.�����(������ 0), ����� �������(������� �� 1)
    wrba.arWares[0]:= WareID;
    for i:= 0 to High(ar) do wrba.arWares[i+1]:= ar[i];

    s:= GetDprtWareRestsByArrive(Contract.MainStorage, WareQty, wrba);
    if (s<>'') then raise EBOBError.Create('������ ������������ ��������');

    if flOnlyWare and (wrba.arRestLists[0].Count=1)
      and (wrba.arRestLists[0][0]='0') then
      raise EBOBError.Create('������ ��� � �������');

    SetLength(arOrderWareQties, Length(wrba.arWares));
    for i:= 0 to High(arOrderWareQties) do arOrderWareQties[i]:= '0';

    if OrderExists then try
      OrdIBS.SQL.Text:= 'Select ORDRLNCLIENTQTY, ORDRLNWARE'+
        ' FROM ORDERSLINES WHERE ORDRLNORDER='+OrderCode;
      OrdIBS.ExecQuery; // ���������� ��������� ���������� �� ������ � ������
      while not OrdIBS.Eof do begin
        owID:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
        owIndex:= fnInIntArray(owID, wrba.arWares); // ���� ������ ������
        if (owIndex>-1) then begin
          qty:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
          if fnNotZero(qty) then
            arOrderWareQties[owIndex]:= trim(FormatFloat('###0.#', qty));
        end;
        TestCssStopException;
        OrdIBS.Next;
      end;
    finally
      OrdIBS.Close;
    end; // if OrderExists

    if (arOrderWareQties[0]='0') then // ���� ����.������ � ������ ���, � ������ �����
      arOrderWareQties[0]:= FormatFloat('###0.#', WareQty); // - ����.���-��

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� ������������ �������
    Stream.WriteStr(Cache.GetCurrName(currID, True)); // ������
    Stream.WriteStr(FormatFloat('###0.#', WareQty));  // ����.���-��
    Stream.WriteStr(WareCode);                        // ��� ����.������

    prSendStorages(wrba.Storages, Stream);

    WareCount:= 0;
    for ia:= 0 to High(wrba.arWares) do begin
      WareID:= wrba.arWares[ia];
      if (WareID<1) then Continue;  // �������� ���� �������� ��� ��������

      Ware:= Cache.GetWare(WareID);
      Stream.WriteInt(Ware.ID);            // ��� ������
      Stream.WriteStr(Ware.PgrName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteBool(Ware.IsSale);       // ������� ����������
      Stream.WriteBool(ware.IsNonReturn);  // ������� ����������
      Stream.WriteBool(ware.IsCutPrice);   // ������� ������
      Stream.WriteStr(Ware.PrDirectName);  // �������� ����������� �� ���������

      aCode:= Ware.GetActionParams(ActTitle, ActText);
      Stream.WriteInt(aCode);         // ��� �����
      Stream.WriteStr(ActTitle);      // ���������
      Stream.WriteStr(ActText);       // �����

//------------------------------------------------- ���� �������
      prices:= ware.CalcFirmPrices(FirmID, currID, contID); // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
      if Ware.IsPrize then PriceFormat:= '# ##0.#' else PriceFormat:= cFloatFormatSumm;
      for i:= 0 to High(prices) do Stream.WriteStr(trim(FormatFloat(PriceFormat, prices[i])));
//------------------------------------------------- ���� �������
      Stream.WriteStr(Ware.MeasName);           // ��.���.
      Stream.WriteStr(wrba.arRestLists[ia][0]); // 1 - ���-�� �� ������ �� ���������
      Stream.WriteStr(arOrderWareQties[ia]);    // ���-�� � ������
      for i:= 1 to wrba.arRestLists[ia].Count-1 do
        Stream.WriteStr(wrba.arRestLists[ia][i]); // ������� �� �����������

      Inc(WareCount);
    end;

    Stream.Position:= sPos;
    Stream.WriteInt(WareCount); // ���������� ���-�� ������� (������������ �������)

//---------------- ���������� ���� �������� ������������ ��� ����������� �������
ErrPos:= '18-1';
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.Text:= 'INSERT INTO WareRequests (WRWAREID, WRUSERID, WRFROM,'+
      ' WRQTY, WRREST, WRTIME)VALUES ('+WareCode+', '+IntToStr(UserID)+', '+
      fnIfStr(OrderExists, '1', '0')+', :clientqty, :totalqty, "NOW")';
    OrdIBS.ParamByName('clientqty').AsFloat:= WareQty;
    OrdIBS.ParamByName('totalqty').AsFloat:= wrba.WareTotal; //WareTotal;
ErrPos:= '18-2';
    s:= RepeatExecuteIBSQL(OrdIBS);
    if (s<>'') then fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', s, 'ErrPos='+ErrPos);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrPos='+ErrPos, False);
  end;
  Stream.Position:= 0;
  SetLength(ar, 0);
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  SetLength(Storages, 0);
  SetLength(prices, 0);
  SetLength(rests, 0);
  if OrderExists then SetLength(arOrderWareQties, 0);
  prFree(wrba);
end;
//============================================= ������ ��������� - 1/2/3 �������
function fnGetStoragesArray_2col(Contract: TContract; ReservedOnly: boolean=false;
                                 DefaultOnly: boolean=false): TasD;
var j, StoreID: integer;
    s: string;
    flAdd: Boolean;
begin
  SetLength(Result, 0);
  StoreID:= Contract.MainStorage;
  flAdd:= Cache.arDprtInfo[Contract.MainStorage].HasDprtFrom2;
  s:= '-'+Cache.GetDprtMainName(StoreID);

  if DefaultOnly then SetLength(Result, 1)
  else if not flAdd then SetLength(Result, 2)
  else SetLength(Result, 3);

  j:= 0;
  Result[j].Code     := IntToStr(StoreID);
  Result[j].FullName := s+', �������';
  Result[j].ShortName:= Cache.GetDprtColName(StoreID);
  Result[j].IsVisible:= True;
  Result[j].IsReserve:= True;
  Result[j].IsSale   := True;
  if DefaultOnly then Exit;

  j:= 1;
  Result[j].Code     := IntToStr(cAggregativeStorage);
  Result[j].FullName := s+', ������';
  Result[j].ShortName:= '������';
  Result[j].IsVisible:= True;
  Result[j].IsReserve:= False;
  Result[j].IsSale   := False;
  if not flAdd then Exit;

  j:= 2;
  Result[j].Code     := IntToStr(cAggregativeStorage+1);
  Result[j].FullName := s+', > 1 ���';
  Result[j].ShortName:= '> 1 ���';
  Result[j].IsVisible:= True;
  Result[j].IsReserve:= False;
  Result[j].IsSale   := False;
end;
{//************************************************************ ��������� �������
procedure prSetCliContMargins(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetCliContMargins'; // ��� ���������/�������
var UserId, FirmID, contID, i, iCount, grpID, parID, errCount: integer;
    errmess, s, ss: string;
    mlst: TLinkList;
    link, ParLink: TQtyLink;
    Client: TClientInfo;
    grp: TWareInfo;
    marg: Double;
    err: array of TCodeAndQty;
begin
  Stream.Position:= 0;
//  contID:= 0;
  errCount:= 0;
  errmess:= '';
  SetLength(err, 0);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    contID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csSetCliContMargins, UserID, FirmID, 'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserID];
    if not Client.CheckContract(contID) then raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));

    mlst:= Client.GetContMarginLinks(contID);         // ������ �� ������� �������

    iCount:= Stream.ReadInt; // ���-�� �����
    SetLength(err, iCount);
    for i:= 1 to iCount do begin
      grpID:= Stream.ReadInt;
      marg:= Stream.ReadDouble;

      if not Cache.GrPgrExists(grpID) then begin
        ss:= '�� ������� ������, ��� '+IntToStr(grpID);
        errmess:= errmess+fnIfStr(errmess='', '', #13#10)+ss;
        err[errCount].ID:= grpID;
        err[errCount].Qty:= 0;
        Inc(errCount);
        Continue;
      end;

      link:= mlst.GetLinkListItemByID(grpID, lkLnkByID);
      if Assigned(link) and fnNotZero(marg)
        and not fnNotZero(link.Qty-marg) then Continue; // ����� ������� ����

      grp:= Cache.arWareInfo[grpID];
      if grp.IsPgr and fnNotZero(marg) then begin  // ���� ��������� � �������<>0
        parID:= grp.PgrID; // ��� ������
        ParLink:= mlst.GetLinkListItemByID(parID, lkLnkByID);
        if Assigned(ParLink) and not fnNotZero(ParLink.Qty-marg) then begin
          marg:= 0; // ������� ������ ������� ������
          if not Assigned(link) then Continue;
        end;
      end;

      s:= Client.CheckCliContMargin(contID, grpID, marg); // ����� � ����

      if (s<>'') then begin // ������
        ss:= '������ ������ ������� �� ������ '+grp.Name;
        errmess:= errmess+fnIfStr(errmess='', '', #13#10)+ss+' ('+IntToStr(grpID)+'): '+s;
        err[errCount].ID:= grpID;
        if Assigned(link) then marg:= link.Qty else marg:= 0;
        err[errCount].Qty:= marg;
        Inc(errCount);
        Continue;
      end;

      if not Assigned(link) and fnNotZero(marg) then begin // ���������
        link:= TQtyLink.Create(0, marg, grp);
        mlst.AddLinkListItem(link, lkLnkByID, Client.CS_client);
      end else if Assigned(link) then
        if not fnNotZero(marg) then                        // �������
          mlst.DelLinkListItemByID(grpID, lkLnkByID, Client.CS_client)
        else try                                           // ������
          Client.CS_client.Enter;
          link.Qty:= marg;
        finally
          Client.CS_client.Leave;
        end;
    end; // for

    if (errmess<>'') then prMessageLOGS(nmProc+': '+errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(errCount); // ���-�� ������
    for i:= 0 to errCount-1 do begin
      Stream.WriteInt(err[i].ID);     // ��� ������/���������
      Stream.WriteDouble(err[i].Qty); // ������� ������� ������/���������
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(err, 0);
  Stream.Position:= 0;
end; }

//------------------------------------------------------------ vc
//========================= �������� ������ �� ������ ������ ������� �����������
procedure prGetAllUsersInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetAllUsersInfo'; // ��� ���������/�������
var UserId, FirmID, i, ii: integer;
    Users, NonUsers: Tai;
    Person: TClientInfo;
    s: string;
    Firm: TFirmInfo;
    Contracts: TIntegerList;
    Contract: TContract;
begin
  Stream.Position:= 0;
  SetLength(Users, 0);
  SetLength(NonUsers, 0);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetAllUsersInfo, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Firm:= Cache.arFirmInfo[FirmId];
    // ������� ���������, ���� �� � ������������ ����� �� ����� ������
    if (UserID<>Firm.SUPERVISOR) or Firm.IsFinalClient then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    for i:= 0 to High(Firm.FirmClients) do begin  // �������� ������ �����.���, �������� ��������
      ii:= Firm.FirmClients[i];
      if not Cache.ClientExist(ii) or (ii=UserID) then Continue;
      Person:= Cache.arClientInfo[ii];
      if (Person.Login<>'') then
        prAddItemToIntArray(ii, Users)
      else if (ExtractFictiveEmail(Person.Mail)<>'') // ������� ������������ Email
//        and (Person.Post<>'') then                   // ������� ���������
        and (CheckClientFIO(Person.Name)='') then    // ������������ ��� ������������ �������
        prAddItemToIntArray(ii, NonUsers);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    Contracts:= Firm.FirmContracts;
    for i:= 0 to Contracts.Count-1 do begin
      ii:= Contracts[i];
      Contract:= Cache.Contracts[ii];
      Stream.WriteInt(Contract.ID);
      Stream.WriteStr(Contract.Name);
      Stream.WriteInt(0);  //      Stream.WriteInt(Contract.SysID);
    end;

    Stream.WriteInt(Length(Users));  // ���-�� ������������� � ��������
    for i:= 0 to High(Users) do begin
      ii:= Users[i];
      Person:= Cache.arClientInfo[ii];
      Stream.WriteInt(ii);           // ���
      Stream.WriteStr(Person.Name);  // ���
      Stream.WriteStr(Person.Post);  // ���������
      Stream.WriteStr(Person.Login); // �����
      for ii:= 0 to Contracts.Count-1 do
        Stream.WriteBool(Person.CheckContract(Contracts[ii]));
    end;

    Stream.WriteInt(Length(NonUsers)); // ���-�� ������������� �/�������
    for i:= 0 to High(NonUsers) do begin
      ii:= NonUsers[i];
      Stream.WriteInt(ii);             // ���
      Person:= Cache.arClientInfo[ii];
      Stream.WriteStr(Person.Name);    // ���
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Users, 0);
  SetLength(NonUsers, 0);
  Stream.Position:= 0;
end;
//============================================= ������ �� ��������� ������ (Web)
procedure prSendOrderForChangeData(kind: Integer; Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendOrderForChangeData'; // ��� ���������/�������
var UserId, FirmID, UserDel, i, j, command, jj: integer;
    Person: TClientInfo;
    Firm: TFirmInfo;
    text, s, sKind, sUser, sFirm, FIO: string;
    lstBodyMail: TStringList;
begin
  Stream.Position:= 0;
  lstBodyMail:= nil;
  UserDel:= 0;
  FIO:= '';
  lstBodyMail:= TStringList.Create;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    case kind of // ��������� ������ � ����������� �� ����
      resAdded: begin
        command:= csSendOrderForAddContactPerson;
        text:= '';
        FIO:= trim(Stream.ReadStr);  // FIO
        s:= 'FIO='+FIO;
        if (FIO<>'') then text:= '���      : '+FIO;
        sFirm:= trim(Stream.ReadStr);  // Post
        s:= s+#13#10'Post='+sFirm;
        if (sFirm<>'') then
          text:= text+fnIfStr(s='', '', #13#10)+'���������: '+sFirm;
        sFirm:= trim(Stream.ReadStr);  // Mail
        if not fnCheckEmail(sFirm) then
          raise EBOBError.Create('������������ E-mail: '+sFirm);
        s:= s+#13#10'Mail='+sFirm;
        if (sFirm<>'') then
          text:= text+fnIfStr(s='', '', #13#10)+'Email    : '+sFirm;
        sFirm:= trim(Stream.ReadStr);  // Phones
        s:= s+#13#10'Phones='+sFirm;
        if (sFirm<>'') then
          text:= text+fnIfStr(s='', '', #13#10)+'�������� : '+sFirm;
      end; // resAdded

      resEdited: begin
        command:= csSendOrderForChangePersonData;
        text:= trim(Stream.ReadStr);
        lstBodyMail.Text:= text;
        for i:= 0 to lstBodyMail.Count-1 do begin // ���� email
          sFirm:= lstBodyMail[i];
          j:= pos('�������', sFirm);
          if (j>0) then Continue;    // ������ �������� �� ���������
          j:= pos('email', sFirm);
          if (j<1) then Continue;    // �� email �� ���������

          sFirm:= copy(sFirm, j+6, length(sFirm));
          jj:= pos('��', sFirm); // ���� "�������� ... �� ..."
          if (jj>0) then sFirm:= copy(sFirm, jj+2, length(sFirm));
          if not fnCheckEmail(sFirm) then
            raise EBOBError.Create('������������ E-mail: '+sFirm);
        end;
        lstBodyMail.Clear;
        s:= 'text='+text;
      end; // resEdited

      resDeleted: begin
        command:= csSendOrderForDelContactPerson;
        UserDel:= Stream.ReadInt;
        s:= 'UserDel='+IntToStr(UserDel);
      end; // resDeleted
      else raise Exception.Create('����������� ��� ������ - '+IntToStr(kind));
    end;

    prSetThLogParams(ThreadData, command, UserID, FirmID, s); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Firm:= Cache.arFirmInfo[FirmID];
    if Firm.IsFinalClient and (kind in [resAdded, resDeleted]) then
      raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

    if (UserID=Firm.SUPERVISOR) then sUser:= '������� ������������'
    else sUser:= '������������';

    case kind of
      resAdded: begin
        if (text='') then raise EBOBError.Create(MessText(mtkNotFoundData));
        if (UserID<>Firm.SUPERVISOR) then // ��������� ����� ������������ �� ������
          raise EBOBError.Create(MessText(mtkNotRightExists));
        sKind:= '���������� ����������� ����';
      end; // resAdded

      resEdited: begin
        if (text='') then raise EBOBError.Create(MessText(mtkNotFoundData));
        sKind:= '��������� ������������'+
          fnIfStr((UserID=Firm.SUPERVISOR), ' ��� ����������', '')+' ������';
      end; // resEdited

      resDeleted: begin
        if (UserID<>Firm.SUPERVISOR) then // ��������� ����� ������������ �� ������
          raise EBOBError.Create(MessText(mtkNotRightExists));
        if CheckNotValidUser(UserDel, FirmID, s) then raise EBOBError.Create(s);
        sKind:= '�������� ����������� ����';
        Person:= Cache.arClientInfo[UserDel];
        text:= '���      : '+Person.Name+#13#10'���������: '+Person.Post+
               #13#10'�����    : '+Person.Login;
      end; // resDeleted
    end;

    Person:= Cache.arClientInfo[UserID];
    sFirm:= '(�/� '+Firm.Name+' ['+Firm.UPPERSHORTNAME+'])';
    sUser:= sUser+' '+Person.Name+' � ������� `'+Person.Login+'`';
    if (FIO='') then FIO:= Person.Name;

    lstBodyMail.Add(sUser);
    lstBodyMail.Add(sFirm);
    lstBodyMail.Add('Email: '+Person.Mail);
    lstBodyMail.Add('�������� ������ �� '+sKind+':');
    lstBodyMail.Add('');
    lstBodyMail.Add(text);

    s:= n_SysMailSend(Cache.GetConstItem(pcUIKdepartmentMail).StrValue,
                      '������ �� '+sKind+' '+FIO+' '+sFirm, lstBodyMail);
    if s<>'' then begin
      if (Pos(MessText(mtkErrMailToFile), s)<1) then
        s:= '������ �������� ������.'#13#10+'������ �������� � ����� ���������� �����.'
      else s:= '������ �������� ������: '#13#10+s;
      raise EBOBError.Create(s);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(lstBodyMail);
end;
//================================================ ������� ����������� ���������
procedure prChangeContractAccess(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prChangeContractAccess'; // ��� ���������/�������
var UserId, FirmID, Victim, Contract: integer;
    Person: TClientInfo;
    s: string;
    AllowContract: boolean;
begin
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    Victim:= Stream.ReadInt;
    Contract:= Stream.ReadInt;
    AllowContract:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csChangeContractAccess, UserID, FirmID, // �����������
      'Victim='+IntToStr(Victim)+#13#10'Contract='+IntToStr(Contract)+
      #13#10'AllowContract='+BoBBoolToStr(AllowContract));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    // ������� ���������, ���� �� � ������������ ����� �� ����� ������
    if (UserID<>Cache.arFirmInfo[FirmId].SUPERVISOR) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if CheckNotValidUser(Victim, FirmID, s) then raise EBOBError.Create(s);

    Person:= Cache.arClientInfo[Victim];
    if (AllowContract) then Person.AddCliContract(Contract)
    else Person.DelCliContract(Contract);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================= ������ ������� �������
procedure prGetWaresFromAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWaresFromAccountList'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    i, UserId, FirmID, ii, contID, pos: Integer;
    SortOrder, SortDesc, s: string;
    Ware: TWareInfo;
    Client: TClientInfo;
    fl: Boolean;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    SortOrder:= Stream.ReadStr;
    SortDesc:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetWaresFromAccountList, UserID, FirmID,
      'SortOrder='+SortOrder+#13#10'SortDesc='+SortDesc); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserID];
    ContID:= Client.GetCliCurrContID;  // ��� ��������/���������� ��������� �������

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'select PINVLNWARECODE DCACLNWARECODE, '+
      ' WAREOFFICIALNAME, PINVLNCOUNT DCACLNCOUNT, rPROCESSED DCACPROCESSED,'+
      ' PINVLNPRICE DCACLNPRICE, rPInvCrnc DCACCRNCCODE, rPInvCode DCACCODE,'+
      ' rPInvNumber DCACNUMBER, rPInvDate DCACDATE, rContCode'+
      ' from Vlad_CSS_GetFirmReserveDocsN('+IntToStr(FirmID)+ ', '+
      fnIfStr(Client.DocsByCurrContr, IntToStr(contID), '0')+')'+
      ' left join PAYINVOICELINES on PINVLNDOCMCODE=rPInvCode'+
      ' left join WARES on WARECODE=PINVLNWARECODE where PINVLNCOUNT>0'+
      ' ORDER BY '+SortOrder+' '+SortDesc+', WAREOFFICIALNAME '+SortDesc+
      ', DCACDATE '+SortDesc+', DCACNUMBER '+SortDesc;
    GBIBS.Prepare;
    GBIBS.ExecQuery;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    pos:= Stream.Position;
    Stream.WriteInt(0); // �������� ����� ��� ���-��
    i:= 0;
    while not GBIBS.EOF do begin
      //------------------------------- ������ �� ����������
      ii:= GBIBS.FieldByName('rContCode').AsInteger;
      if (ii<1) then s:= ''                                  // �������� �����������
      else if (Client.CliContracts.IndexOf(ii)<0) or         // �������� ����������
        (Client.DocsByCurrContr and (ii<>ContID)) then begin // ������ ������ �� ��������
        TestCssStopException;
        GBIBS.Next;
        Continue;
      end else s:= Client.GetCliContract(ii).Name;
      fl:= GetBoolGB(GBIBS, 'DCACPROCESSED');
      Ware:= Cache.GetWare(GBIBS.FieldByName('DCACLNWARECODE').AsInteger);
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(GBIBS.FieldByName('WAREOFFICIALNAME').AsString);
      Stream.WriteDouble(GBIBS.FieldByName('DCACLNCOUNT').AsFloat);
      Stream.WriteDouble(GBIBS.FieldByName('DCACLNPRICE').AsFloat);
      Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('DCACCRNCCODE').AsInteger, True));
      Stream.WriteStr(s);                                     // ����� ���������
      Stream.WriteByte(fnIfInt(fl, byte('t'), byte('f')));
      Stream.WriteStr(GBIBS.FieldByName('DCACCODE').AsString);
      Stream.WriteStr(GBIBS.FieldByName('DCACNUMBER').AsString+fnIfStr(fl, cWebProcessed, ''));
      Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('DCACDATE').AsDateTime));
      TestCssStopException;
      GBIBS.Next;
      Inc(i);
    end;
    GBIBS.Close;
    Stream.Position:= pos;
    Stream.WriteInt(i); // �������� ���-��
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
end;
//=========================================================== �������� ���������
procedure prShowGBOutInvoice(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowGBOutInvoice'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    UserId, FirmID, ForFirmID, LineCount, Pos, contID, WareID: integer;
    OutInvoiceID, Summa, s, ss: string;
    Ware: TWareInfo;
    Client: TClientInfo;
    price, qty: Double;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  Client:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OutInvoiceID:= Stream.ReadStr;

    if (FirmID<>IsWe) then ForFirmID:= FirmID  // Web
    else try
      ForFirmID:= Stream.ReadInt; // Webarm  ��� �/� - �������� �������� !!!
    except
      ForFirmID:= 0;
    end;

    s:= 'OutInvoiceID='+OutInvoiceID;
    if (FirmID=IsWe) then s:= s+#10#13'ForFirmID='+IntToStr(ForFirmID);

    prSetThLogParams(ThreadData, csShowGBOutInvoice, UserID, FirmID, s); // �����������

    LineCount:= StrToIntDef(OutInvoiceID, 0);
    if (LineCount<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, OutInvoiceID));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    s:= '';
    if (FirmID<>IsWe) then begin
      Client:= Cache.arClientInfo[UserID];
      s:= fnIntegerListToStr(Client.CliContracts); // TIntegerList - � ������ ����� �������
    end;

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'SELECT INVCNUMBER, INVCDATE, INVCSUMM, INVCCRNCCODE,'+
      ' INVCCONTRACTCODE, bc.bnclcalcbonussumm'+
      fnIfStr(flMeetPerson, ', pphphone, prsnname', '')+
      fnIfStr(FirmID<>IsWe, '', ', gn.rNum contnum')+
      ' from INVOICEREESTR left outer join bonuscalculations bc'+
      ' on bc.bncldocmcode=invccode and bc.bncldocmtype='+IntToStr(docInvoice)+
      fnIfStr(flMeetPerson,
      ' left join personphones on pphcode=INVCMEETPERSON'+
      ' left join persons on prsncode=PPhPersonCode', '')+
      fnIfStr(FirmID<>IsWe, '',
      ' left join CONTRACT on contcode=INVCCONTRACTCODE'+
      ' left join Vlad_CSS_GetFullContNum(contnumber, contnkeyyear, contpaytype) gn on 1=1')+
      ' where INVCCODE='+OutInvoiceID+' and INVCRECIPIENTCODE='+IntToStr(ForFirmID)+
      fnIfStr(s='', '', ' and INVCCONTRACTCODE in ('+s+')');
    GBIBS.ExecQuery;
    if GBIBS.Bof and GBIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundDocum, OutInvoiceID));
    Summa:= FormatFloat(cFloatFormatSumm, GBIBS.FieldByName('INVCSUMM').AsFloat)+' '+
            Cache.GetCurrName(GBIBS.FieldByName('INVCCRNCCODE').AsInteger, True);
    LineCount:= 0;            // ������� - ���-�� �����

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(GBIBS.FieldByName('INVCNUMBER').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('INVCDATE').AsDateTime));
    contID:= GBIBS.FieldByName('INVCCONTRACTCODE').AsInteger;

    s:= '';
    if (FirmID=IsWe) then s:= GBIBS.FieldByName('contnum').AsString
    else if Assigned(Client) and Client.CheckContract(contID) then
      s:= Cache.Contracts[contID].Name;
    Stream.WriteStr(s); // ����� ���������

    Stream.WriteDouble(GBIBS.FieldByName('bnclcalcbonussumm').AsDouble);
    Stream.WriteStr(Cache.GetCurrName(Cache.BonusCrncCode, True));

if flMeetPerson then begin
    s:= trim(GBIBS.FieldByName('prsnname').AsString);
    ss:= GBIBS.FieldByName('pphphone').AsString;
    if (s<>'') or (ss<>'') then s:= s+' ('+ss+')';
    Stream.WriteStr(s); // �����������
end; // flMeetPerson

    Pos:= Stream.Position;
    Stream.WriteInt(0); //  ����� ��� ���-�� �����

    GBIBS.Close;
    GBIBS.SQL.Text:= 'select INVCLNWARECODE, INVCLNCOUNT, INVCLNPRICE'+
                     ' from INVOICELINES where INVCLNDOCMCODE='+OutInvoiceID;
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      WareID:= GBIBS.FieldByName('INVCLNWARECODE').AsInteger;
      Ware:= Cache.GetWare(WareID);
      if (Ware=nil) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
      price:= GBIBS.FieldByName('INVCLNPRICE').AsFloat;
      qty  := GBIBS.FieldByName('INVCLNCOUNT').AsFloat;
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(GBIBS.FieldByName('INVCLNCOUNT').AsString);
      Stream.WriteStr(Ware.MeasName);
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, RoundToHalfDown(price*qty, -2)));
      inc(LineCount);
      TestCssStopException;
      GBIBS.Next;
    end;
    GBIBS.Close;
    Stream.WriteStr(Summa);

    Stream.Position:= Pos;
    Stream.WriteInt(LineCount);

    if (FirmID=IsWe) then begin
      Stream.Position:= Stream.Size;
      Stream.WriteStr(Cache.arFirmInfo[ForFirmID].Name);
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
end;
//================================================ �������� ���������� ���������
procedure prShowGBBack(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowGBBack'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    UserId, FirmID, LineCount, Pos, ContID: integer;
    OutInvoiceID, Summa, s: string;
    Client: TClientInfo;
    price, qty: Double;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OutInvoiceID:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csShowGBBack, UserID, FirmID, 'DocID='+OutInvoiceID); // �����������

    LineCount:= StrToIntDef(OutInvoiceID, 0);
    if (LineCount<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, OutInvoiceID));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserID];
    s:= fnIntegerListToStr(Client.CliContracts); // TIntegerList - � ������ ����� �������

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'SELECT RTINNUMBER, RTINDATE, RTINSUMM, RTINCRNCCODE, RTINCONTRACTCODE,'+
      ' bc.bnclcalcbonussumm from RETURNINVOICEREESTR left outer join bonuscalculations bc'+
      '   on bc.bncldocmcode=rtincode and bc.bncldocmtype='+IntToStr(docBackInvoice)+
      ' where RTINCODE='+OutInvoiceID+' and RTINRECIPIENTCODE='+IntToStr(FirmId)+
      ' and RTINCONTRACTCODE in ('+s+')';
    GBIBS.ExecQuery;
    if GBIBS.Bof and GBIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundDocum, OutInvoiceID));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(GBIBS.FieldByName('RTINNUMBER').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('RTINDATE').AsDateTime));

    contID:= GBIBS.FieldByName('RTINCONTRACTCODE').AsInteger;
    if Client.CheckContract(contID) then s:= Cache.Contracts[contID].Name else s:= '';
    Stream.WriteStr(s); // ����� ���������

    Summa:= FormatFloat(cFloatFormatSumm, GBIBS.FieldByName('RTINSUMM').AsFloat)+
      ' '+Cache.GetCurrName(GBIBS.FieldByName('RTINCRNCCODE').AsInteger, True);

    Stream.WriteDouble(GBIBS.FieldByName('bnclcalcbonussumm').AsDouble);
    Stream.WriteStr(Cache.GetCurrName(Cache.BonusCrncCode, True));
    GBIBS.Close;

    LineCount:= 0;            // ������� - ���-�� �����
    Pos:= Stream.Position;
    Stream.WriteInt(0);       //  ����� ��� ���-�� �����

    GBIBS.SQL.Text:= 'select RTINLNWARECODE, RTINLNCOUNT, RTINLNPRICE, RTINLNUNITCODE'+
      ' from RETURNINVOICELINES where RTINLNDOCMCODE='+OutInvoiceID;
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      with Cache.GetWare(GBIBS.FieldByName('RTINLNWARECODE').AsInteger) do begin
        Stream.WriteStr(GrpName);
        Stream.WriteStr(Name);
      end;
      price:= GBIBS.FieldByName('RTINLNPRICE').AsFloat;
      qty:= GBIBS.FieldByName('RTINLNCOUNT').AsFloat;
      Stream.WriteStr(GBIBS.FieldByName('RTINLNCOUNT').AsString);
      Stream.WriteStr(Cache.GetMeasName(GBIBS.FieldByName('RTINLNUNITCODE').AsInteger));
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, price));
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, RoundToHalfDown(price*qty, -2)));
      inc(LineCount);
      TestCssStopException;
      GBIBS.Next;
    end;
    GBIBS.Close;
    Stream.WriteStr(Summa);
    Stream.Position:= Pos;
    Stream.WriteInt(LineCount);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
end;
//======================================================= �������� �������������
procedure prShowGBManual(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowGBManual'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    UserId, FirmID, ManualID, DocmType: integer;
    s, DocmCode: string;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ManualID:= Stream.ReadInt;
    DocmType:= Stream.ReadInt;

    DocmCode:= IntToStr(ManualID);
    prSetThLogParams(ThreadData, csShowGBManual, UserID, FirmID,
      'DocType='+IntToStr(DocmType)+#13#10'DocID='+DocmCode); // �����������

    if not (DocmType in [docManualCorr, docHandOper]) then
      raise EBOBError.Create('����������� ��� ��������� - '+IntToStr(DocmType));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);

    if (DocmType=docManualCorr) then
      GBIBS.SQL.Text:= 'select bnmcnumber rNumber, bnmcdate rDate, bnmcsumm rSumma,'+
        ' BNMCCOMMENT rComment from BNManualCorrectReestr where BNMCCode='+DocmCode+
        ' and bnmcsubfirmcode=1 and bnmcfirmcode='+IntToStr(FirmID)
    else
      GBIBS.SQL.Text:= 'select BNHONumber rNumber, BNHODate rDate,  BNHOCOMMENT rComment,'+
        ' (select sum(BNHOLnSumm) from BNHandOperLines where BNHOLNDocmCode=BNHOCode'+
        '   and BNHOLnFirmCode='+IntToStr(FirmID)+') rSumma'+
        ' from BNHANDOPERREESTR where BNHOCode='+DocmCode+' and BNHOSubFirmCode=1';

    GBIBS.ExecQuery;
    if GBIBS.Bof and GBIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundDocum, DocmCode));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(GBIBS.FieldByName('rNumber').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('rDate').AsDateTime));
    Stream.WriteStr(FormatFloat(cFloatFormatSumm, GBIBS.FieldByName('rSumma').AsFloat));
    Stream.WriteStr(GBIBS.FieldByName('rComment').AsString);

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
end;
//================================================== ������ ������������ ���-���
procedure prGetUnpayedDocs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetUnpayedDocs'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    UserId, FirmID, iCount, index, curr, iDate, contID, ii, pos{, i}: Integer;
    Currencies, conts: tai;
    RedSumms, VioletSumms: array of double;
    ShowRed, ShowViolet: boolean;
    sum: double;
    Client: TClientInfo;
    s: String;
//-----------------------------------------
  function fnGetWarningText(Summs: array of double): string;
  var i: integer;
  begin
    Result:= '';
    for i:= 0 to High(Summs) do if (Summs[i]>0) then
      Result:= Result+fnIfStr(Result<>'', ', ', '')+
        FormatFloat(cFloatFormatSumm, Summs[i])+' '+Cache.GetCurrName(Currencies[i], True);
  end;
//-----------------------------------------
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  SetLength(Currencies, 0);
  SetLength(RedSumms, 0);
  SetLength(VioletSumms, 0);
  SetLength(conts, 0);
  ShowRed:= false;
  ShowViolet:= false;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetUnpayedDocs, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserID];
    ContID:= Client.GetCliCurrContID;  // ��� ��������/���������� ��������� �������

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'select rDocmTYPE, rDocmCODE, rDocmDate, rDocmCrnc RCrncCode,'+
      ' rDocmDuty RDutySumm, rDocmDPRT DPRTCODE, rDocmDELAY DELAYCALC,'+
      ' rDocmSUMM DTLNSUMM, rDocmNUMBER DTLNNUMBER, rContCode from'+
      ' Vlad_CSS_GetFirmDutyDocms('+IntToStr(FirmID)+ ', '+
      fnIfStr(Client.DocsByCurrContr, IntToStr(contID), '0')+', '+
      Cache.GetConstItem(pcDutyDocsWithPlan).StrValue+')';

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    pos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� �����

    GBIBS.ExecQuery;
    iCount:= 0;
    while not GBIBS.EOF do begin
      //------------------------------- ������ �� ���������� +++
      ii:= GBIBS.FieldByName('rContCode').AsInteger;
      if (ii<1) then s:= ''                                  // �������� �����������
      else if (Client.CliContracts.IndexOf(ii)<0)         // �������� ���������� �������
        or (Client.DocsByCurrContr and (ii<>ContID))      // ������ ������ �� �������� ???
      then begin
        TestCssStopException;
        GBIBS.Next;
        Continue;
      end else begin
         s:= Client.GetCliContract(ii).Name;
         prAddItemToIntArray(ii, conts);
      end;
      //------------------------------- ������ �� ���������� ---

      Stream.WriteInt(GBIBS.FieldByName('RDOCMTYPE').AsInteger); // ��� ���� ���������
      Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('RDOCMDATE').AsDateTime));  // ���� ���������
      Stream.WriteStr(GBIBS.FieldByName('RDOCMCODE').AsString);  // ��� ��������� (id)
      Stream.WriteStr(GBIBS.FieldByName('DTLNNUMBER').AsString); // ����� ���������

      sum:= RoundToHalfDown(GBIBS.FieldByName('DTLNSUMM').AsFloat);
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum)); // ����� ���������

      sum:= RoundToHalfDown(GBIBS.FieldByName('RDUTYSUMM').AsFloat);
      Stream.WriteStr(FormatFloat(cFloatFormatSumm, sum)); // ������������ �����

      curr:= GBIBS.FieldByName('RCrncCode').AsInteger;
      Stream.WriteStr(Cache.GetCurrName(curr, True)); // ������ ���������
      Stream.WriteStr(s);                             // ����� ��������� ���������

      if (fnInIntArray(curr, Currencies)=-1) then begin
        prAddItemToIntArray(curr, Currencies);
        index:= Length(Currencies);
        SetLength(RedSumms, index);
        SetLength(VioletSumms, index);
        RedSumms[index-1]:= 0;
        VioletSumms[index-1]:= 0;
      end;

      iDate:= Trunc(GBIBS.FieldByName('RDOCMDATE').AsDateTime)+
              GBIBS.FieldByName('DELAYCALC').AsInteger;
      if (iDate<Date) then begin
        Stream.WriteByte(2); // ������� ���
        index:= fnInIntArray(curr, Currencies);
        RedSumms[index]:= RedSumms[index]+sum; // ������������ �����
        ShowRed:= true;
      end else if ((iDate-Date)<constDaysForBlockWarninig) then begin
        Stream.WriteByte(1); // ���������� ���
        index:= fnInIntArray(curr, Currencies);
        VioletSumms[index]:= VioletSumms[index]+sum; // ������������ �����
        ShowViolet:= true;
      end else Stream.WriteByte(0);
      Stream.WriteInt(iDate);
//------------------------------------------------------------------------------
      TestCssStopException;
      GBIBS.Next;
      Inc(iCount)
    end;
    GBIBS.Close;

    s:= '���������� �������� ';
    if ShowRed then begin
      Stream.WriteByte(2);
      Stream.WriteStr('�� ������������ ���������� '+s+fnGetWarningText(RedSumms));
    end else if ShowViolet then begin
      Stream.WriteByte(1);
      Stream.WriteStr('� ��������� ����� '+s+fnGetWarningText(VioletSumms));
    end else Stream.WriteByte(0);

    Stream.Position:= pos;
    Stream.WriteInt(iCount); // ���-�� �����
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
  SetLength(Currencies, 0);
  SetLength(RedSumms, 0);
  SetLength(VioletSumms, 0);
  SetLength(conts, 0);
end;
//======================================================================= ������
procedure prGetCheck(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCheck'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    UserId, FirmID, i, contID, ipos: integer;
    DateBegin, DateEnd, DateMin, DateTemp: TDateTime;
    CurrCode, c, s: string;
    Debt: double;
    Client: TClientInfo;
    Contract: TContract;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  contID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    DateBegin:= Trunc(Stream.ReadDouble);
    DateEnd:= Trunc(Stream.ReadDouble);

    prSetThLogParams(ThreadData, csGetCheck, UserID, FirmID,
      'DateBegin='+FormatDateTime(cDateFormatY2, DateBegin)+
      #13#10'DateEnd='+FormatDateTime(cDateFormatY2, DateEnd)+
      #13#10'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserID];
    if Client.CheckIsFinalClient then raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

    if not Client.CheckContract(ContID) then ContID:= Client.LastContract; // ???
    Contract:= Client.GetCliContract(contID);
    CurrCode:= IntToStr(Contract.DutyCurrency);

    If DateEnd<DateBegin then begin
      DateTemp:= DateEnd;
      DateEnd:= DateBegin;
      DateBegin:= DateTemp;
    end;
    if DateEnd>Date() then DateEnd:= Date();
    //------------------------------- ��������� ���������� ��������� ���� ������
    DateMin:= IncMonth(EncodeDate(CurrentYear, CurrentMonth, 1), -1);
    if DateBegin<DateMin then DateBegin:= DateMin;
    Debt:= 0;

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    //------------------------------------------ ������������� �� ������� ������
    GBIBS.SQL.Text:= 'select ABDTCURRECYCODE DUTYCRNCCODE, ABDTSUMM DUTYCURRENT'+
      ' from ABSOLUTEDUTY where ABDTCURRECYCODE='+CurrCode+
      ' and ABDTFIRMCODE='+IntToStr(FirmId)+' and ABDTCONTRACTCODE='+IntToStr(contID);
    GBIBS.ExecQuery;
    while not GBIBS.Eof do begin
      Debt:= Debt+GBIBS.FieldByName('DUTYCURRENT').AsFloat;
      TestCssStopException;
      GBIBS.Next;
    end;
    GBIBS.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    ipos:= Stream.Position;
    Stream.WriteInt(0);         // ����� ��� ���-�� �����
    Stream.WriteDouble(Debt/100);    // ������������� �� ������� ������
    Stream.WriteDouble(DateBegin);   // ���� ������ ������
    Stream.WriteDouble(DateEnd);     // ���� ��������� ������
    Stream.WriteStr(Contract.Name);  // ������������ ���������
    Stream.WriteStr(fnIfStr(CurrCode=cStrUAHCurrCode, '���.', '�.�.')); // ������ ������ (��� ����������� � ���������)
    Stream.WriteDouble(DateMin);     // ���������� ��������� ���� (���� �� ��������� �� �� �������) ������ ������
    Stream.WriteDouble(Date());      // ������������ ��������� ���� (���� �� ��������� �� �� �������) ����� ������
    //-------------------------------------------------- ��������� ������ ������
    Debt:= 0;
    GBIBS.SQL.Text:= 'select rDuty from GETDUTYONDATE(:DateBegin, '+
      IntToStr(FirmId)+', 1, '+CurrCode+', '+IntToStr(contID)+', 0)';
    GBIBS.Prepare;
    GBIBS.ParamByName('DateBegin').AsDateTime:= DateBegin;
    GBIBS.ExecQuery;
    if not (GBIBS.EOF and GBIBS.Bof) then Debt:= GBIBS.Fields[0].AsFloat/100;
    GBIBS.Close;
    Stream.WriteDouble(Debt); // ��������� ������ ������
    i:= 0;
//------------------------------------------------------------- ��������� ������
    GBIBS.SQL.Text:= 'select rSUMM, rDATE, rDOCMTYPE, rDOCMCODE, rDUTYTYPE,'+
      ' rNUMBER from Vlad_CSS_GetFirmCheckDocs('+IntToStr(FirmId)+', '+
      IntToStr(contID)+', :DateBegin, :DateEnd) where rCRNC='+CurrCode;
    GBIBS.ParamByName('DateBegin').AsDateTime:= DateBegin;
    GBIBS.ParamByName('DateEnd').AsDateTime:= DateEnd;
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      c:= GBIBS.FieldByName('rDUTYTYPE').AsString;                // ��� �������������  0 - �����, 5 - ������
      Stream.WriteByte(byte(c[1]));                               // ��� �������������
      Stream.WriteDouble(GBIBS.FieldByName('rDATE').AsDateTime);  // ���� ���������
      Stream.WriteInt(GBIBS.FieldByName('rDOCMTYPE').AsInteger);  // ��� ���� ���������
      Stream.WriteStr(GBIBS.FieldByName('rDOCMCODE').AsString);   // ��� ��������� (id)
      Stream.WriteStr(GBIBS.FieldByName('rNUMBER').AsString);     // ����� ���������
      Stream.WriteDouble(GBIBS.FieldByName('rSUMM').AsFloat/100); // ����� ���������
      TestCssStopException;
      GBIBS.Next;
      Inc(i)
    end;
    GBIBS.Close;
    if (i>0) then begin
      Stream.Position:= ipos;
      Stream.WriteInt(i); // ���-�� �����
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
end;
//================================================================ unit-��������
procedure prGetCheckBonus(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCheckBonus'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBS: TIBSQL;
    UserId, FirmID, i, ipos: integer;
    DateBegin, DateEnd, DateTemp: TDateTime;
    c, s: string;
    Debt, sum: double;
    firma: TFirmInfo;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  gbIBD:= nil;
  Debt:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    DateBegin:= Trunc(Stream.ReadDouble);
    DateEnd:= Trunc(Stream.ReadDouble);

    prSetThLogParams(ThreadData, csGetCheckBonus, UserID, FirmID,
      'DateBegin='+FormatDateTime(cDateFormatY2, DateBegin)+
      #13#10'DateEnd='+FormatDateTime(cDateFormatY2, DateEnd)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmID];
    if firma.IsFinalClient then raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

    If DateEnd<DateBegin then begin
      DateTemp:= DateEnd;
      DateEnd:= DateBegin;
      DateBegin:= DateTemp;
    end;
    if DateEnd>Date() then DateEnd:= Date();

    gbIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);

    //-------------------------------------- ��������� ������� �� ������� ������
    GBIBS.SQL.Text:= 'select bnrssumm from bonusrest'+
                     ' where bnrssubfirmcode=1 and bnrsfirmcode='+IntToStr(FirmID);
    GBIBS.ExecQuery;
    if not (GBIBS.Eof and GBIBS.Bof) then Debt:= RoundTo(GBIBS.FieldByName('bnrssumm').AsFloat, -2);
    GBIBS.Close;
    if fnNotZero(firma.BonusQty-Debt) then try
      firma.CS_firm.Enter;
      firma.BonusQty:= Debt;
    finally
      firma.CS_firm.Leave;
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    ipos:= Stream.Position;
    Stream.WriteInt(0);         // ����� ��� ���-�� ����� ���-���
    Stream.WriteDouble(DateBegin);   // ��������� ���� ������
    Stream.WriteDouble(DateEnd);     // �������� ���� ������
    //-------------------------------------------------- ��������� ������ ������
    GBIBS.SQL.Text:= 'select sum(InSumm-OutSumm) from'+  // ������ �� ��������� ����
      ' (select iif(BnTrDirection="0", BnTrSumm, 0) as InSumm,'+
      '  iif(BnTrDirection="1", BnTrSumm, 0) as OutSumm from BonusTransactions'+
      '  join UnitedReestr on UnTdDocmType=BnTrDocmType and UnTdDocmCode=BnTrDocmCode'+
      '  where BnTrFirmCode='+IntToStr(FirmId)+' and UnTdDate Between :DateBegin and "today")';
    GBIBS.ParamByName('DateBegin').AsDateTime:= DateBegin;
    GBIBS.ExecQuery;
    if not (GBIBS.EOF and GBIBS.Bof) then Debt:= RoundTo(Debt-GBIBS.Fields[0].AsFloat, -2);
    GBIBS.Close;

    Stream.WriteDouble(-Debt); // ��������� ������ ������

    i:= 0;
//------------------------------------------------------------- ��������� ������
    GBIBS.SQL.Text:= 'select BnTrDocmType rType, BnTrDocmCode rDocm, UnTdNumber rNUMBER,'+
      '  UnTdDate rDate, BnTrDirection rDUTYTYPE, BnTrSumm rSumma from BonusTransactions'+
      '  join UnitedReestr on UnTdDocmType=BnTrDocmType and UnTdDocmCode=BnTrDocmCode'+
      '  where BnTrFirmCode='+IntToStr(FirmId)+' and UnTdDate Between :DateBegin'+
      '    and :DateEnd and BnTrSumm<>0 order by UnTdDate, UnTdNumber';
    GBIBS.ParamByName('DateBegin').AsDateTime:= DateBegin;
    GBIBS.ParamByName('DateEnd').AsDateTime:= DateEnd;
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      c:= GBIBS.FieldByName('rDUTYTYPE').AsString;               // ���: 0 - ���������, 1 - ������������
      Stream.WriteByte(byte(c[1]));
      Stream.WriteDouble(GBIBS.FieldByName('rDATE').AsDateTime); // ���� ���������
      Stream.WriteInt(GBIBS.FieldByName('rType').AsInteger);     // ��� ���� ���������
      Stream.WriteStr(GBIBS.FieldByName('rDocm').AsString);      // ��� ��������� (id)
      Stream.WriteStr(GBIBS.FieldByName('rNUMBER').AsString);    // ����� ���������
      sum:= RoundTo(GBIBS.FieldByName('rSumma').AsFloat, -2);
      Stream.WriteDouble(sum);   // ����� �������
      TestCssStopException;
      GBIBS.Next;
      Inc(i)
    end;
    GBIBS.Close;
    if (i>0) then begin
      Stream.Position:= ipos;
      Stream.WriteInt(i); // ���-�� �����
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(gbIBD);
  Stream.Position:= 0;
end;
//=================================================== ��������� ��������� ������
procedure prSendMessage2Manager(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendMessage2Manager'; // ��� ���������/�������
var UserId, FirmID, contID: Integer;
    Mess, mes, s, To_, From, ToAdm: string;
    Strings: TStrings;
    firma: TFirmInfo;
    Client: TClientInfo;
    Contract: TContract;
begin
  Stream.Position:= 0;
  contID:= 0;
  Strings:= TStringList.Create;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    Mess:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csSendMessage2Manager, UserID, FirmID,
      'Mess='+Mess+#13#10'ContID='+IntToStr(ContID)); // �����������

    if (trim(Mess)='') then raise EBOBError.Create('������ ��������� ������ ���������');
    if not Cache.ClientExist(UserID) then
      raise Exception.Create(MessText(mtkNotClientExist, IntToStr(UserID)));

    Client:= Cache.arClientInfo[UserID];
    if not Cache.FirmExist(FirmID) then FirmID:= Client.FirmID;
    if not Cache.FirmExist(FirmID) then
      raise Exception.Create(MessText(mtkNotFirmExists, IntToStr(FirmID)));
    if (FirmID<>Client.FirmID) then raise Exception.Create(MessText(mtkNotClientOfFirm));

    From:= ExtractFictiveEmail(Client.Mail);
    if (From='') then
      raise EBOBError.Create('�������� ��������� ���������� - ������ E-mail ��� � ����'+
        ' ������. �������� ���� ����� � E-mail ��������� ������������� ��������.');

    firma:= Cache.arFirmInfo[FirmID];
    Contract:= firma.GetContract(contID);
    mes:= '';
    if (Contract.Name<>'') then mes:= '�� ���������� ��������� � '+Contract.Name;
    if (Contract.Status=cstClosed) then begin
      if (mes<>'') then mes:= mes+' (����������)';
      Contract:= Firma.GetDefContract;
    end;
                                                 // ��������� � ������ �����
    Strings.Add('������ ������� �������� ��� �� ������� ������������');
    Strings.Add('� ������� '+Client.Login+' [�/� '+firma.Name+']');
    if (mes<>'') then Strings.Add(mes);
    Strings.Add(' ');

// 20.10.2016 - ��������� ��-�� �������� � �������������� �� order@motogorodok.com
//    Strings.Add('E-mail ������������ ������ ��� ����������� ������ ��� ������.');
    Strings.Add('E-mail ������������ ��� ������: '+From);

    Strings.Add(' ');
    Strings.Add('����� ���������:');
    Strings.Add(StringOfChar('-', 40));
    Strings.Add(Mess); // ����� ������������
    Strings.Add(StringOfChar('-', 40));

    ToAdm:= Cache.GetConstEmails(pcEmplORDERAUTO);
    if (ToAdm='') then ToAdm:= fnGetSysAdresVlad(caeOnlyWorkDay); // 3 - �� ���������� ��� �� ����� � ��������

    To_:= fnGetManagerMail(Contract.Filial, ToAdm);
    if (To_=ToAdm) then begin
      To_:= Cache.GetConstItem(pcUIKdepartmentMail).StrValue; // ���� �� ����� ���� - ���������� � ���
      Strings.Add('�� ������ E-mail ������� ������� ��� �������� ������');
    end;

// 20.10.2016 - ��������� ��-�� �������� � �������������� �� order@motogorodok.com
//    s:= n_SysMailSend(To_, '��������� �� ������������ ���', Strings, nil, From, '', true);
    s:= n_SysMailSend(To_, '��������� �� ������������ ���', Strings, nil, cNoReplayEmail, '', true);

    if (s<>'') then
      if (Pos(MessText(mtkErrMailToFile), s)>0) then begin  // ���� �� �������� � ����
        Strings.Insert(0, GetMessageFromSelf);
        if ToAdm<>'' then begin
          Strings.Add(#10'����� ������:'#10+s); // ��������� ����� ������ 1-� �������� � ���������� �������
          ToAdm:= n_SysMailSend(ToAdm, MessText(mtkErrSendMess, '�� ������������'), Strings, nil, '', '', true);
          if ToAdm<>'' then s:= s+#10+MessText(mtkErrSendMess, '�������')+#10+ToAdm+
                                #10'����� ������: '+Strings.Text;
        end;
        raise Exception.Create(s);
      end else raise EBOBError.Create('������ �������� ������.'+
        #13#10'��������� �������� � ����� ���������� �����.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(Strings);
  Stream.Position:= 0;
end;
//=================================================== ������ ���� �� ������ � ��
procedure prGetActions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetActions'; // ��� ���������/�������
var UserId, FirmID, i, arlen, Count, Count1, Pos, pos1, {ContractID,} MaxCount{, iVis}: integer;
    Wares: tai;
    InfoBoxItem: TInfoBoxItem;
    ErrorPos: string;
begin
  Stream.Position:= 0;
  ErrorPos:= '0';
  MaxCount:= 10;
  SetLength(Wares, 0);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetActions, UserID, FirmID, ''); // �����������

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos1:= Stream.Position;
    Stream.WriteInt(0); // �������� ��� ���-��

    Count:= 0;
    Count1:= 0;
    Pos:= 0;
    arlen:= Cache.InfoNews.ItemsList.Count-1;
  ErrorPos:='5';
    // ������� ��������� ������������ ����
    while (Pos<=arlen) and (TInfoBoxItem(Cache.InfoNews.ItemsList[Pos]).Priority>0) do begin
      InfoBoxItem:= Cache.InfoNews.ItemsList[Pos];
      Stream.WriteBool(InfoBoxItem.InWindow);
      Stream.WriteStr(InfoBoxItem.Title);
      Stream.WriteInt(InfoBoxItem.ID);
      Stream.WriteStr(InfoBoxItem.LinkToSite);
      Stream.WriteStr(InfoBoxItem.LinkToPict);
      Inc(Count);
      Inc(Pos);
    end;
    // ��� ������������� - ��������������
    if (Count<MaxCount) and (Pos<=arlen) then begin
      Setlength(Wares, arlen-Pos+1);
      while (Count<MaxCount) and (Pos<=arlen) do begin
        Wares[Count1]:= Pos;
        Inc(Count1);
        Inc(Pos);
      end;
      Setlength(Wares, Count1);
      // �������� ������ ������ �� ����� 10-Count �������� ��������� �� ��������� ������� ���������
      Wares:= fnGetRandomArray(Wares, MaxCount-Count);
      arlen:= Length(Wares)-1;
      for i:=0  to arlen do begin
        InfoBoxItem:= Cache.InfoNews.ItemsList[Wares[i]];
        Stream.WriteBool(InfoBoxItem.InWindow);
        Stream.WriteStr(InfoBoxItem.Title);
        Stream.WriteInt(InfoBoxItem.ID);
        Stream.WriteStr(InfoBoxItem.LinkToSite);
        Stream.WriteStr(InfoBoxItem.LinkToPict);
      end;
      Count:= Count+arlen+1;
    end;
  ErrorPos:='20';
    Stream.Position:= pos1;
    Stream.WriteInt(Count); // ���-��
  except
    on E: Exception do
      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message+#13#10' ErrorPos='+ErrorPos, '');
  end;
  Stream.Position:= 0;
  SetLength(Wares, 0);
end;
//============================================ �������� ����� �� ��������/������
procedure prClickOnNewsCounting(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prClickOnNewsCounting'; // ��� ���������/�������
var UserId, FirmID, ActionID : integer;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  ordIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ActionID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csClickOnNewsCounting, UserID, FirmID,
      'ActionID='+IntToStr(ActionID)); // �����������

    ordIBD:= cntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(ordIBD,'OrdIBS_'+nmProc,ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= 'Update INFOBOXVIEWS set IBVCLICKCOUNT=IBVCLICKCOUNT+1 where IBVCODE='+IntToStr(ActionID);
    OrdIBS.ExecQuery;
    OrdIBS.Transaction.Commit;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================
procedure prSaveOption(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveOption'; // ��� ���������/�������
var UserId, FirmID, ActionID, Value : integer;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    s, sUser: string;
    Client: TClientInfo;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  ordIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ActionID:= Stream.ReadInt;
    Value:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csSaveOption, UserID, FirmID,
      'ActionID='+IntToStr(ActionID)+#13#10'Value='+IntToStr(Value)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    Client:= Cache.arClientInfo[UserID];

    s:= 'UPDATE WEBORDERCLIENTS SET ';
    sUser:= ' where WOCLCODE='+IntToStr(UserID);
    case ActionID of
//      optPayType:
//        s:= s+'WOCLDEFAULTACCOUNTINGTYPE='+fnIfStr(Value=1, '1', '0')+sUser;
//      optDeliveryType:
//        s:= s+'WOCLDEFAULTDELIVERYTYPE='+fnIfStr(Value=1, '1', '0')+sUser;
      optNoRemindAboutComment: begin
        s:= s+'WOCLNOTREMINDCOMMENT='+fnIfStr(Value=1, '"T"', '"F"')+sUser;
      end;
      optThisContractDocsOnly: begin
        s:= s+'WOCLDOCSBYCONTR='+fnIfStr(Value=1, '"T"', '"F"')+sUser;
      end;
      optSearchCurrency: begin
        s:= s+'WOCLSEARCHCURRENCY='+fnIfStr(Value=1, cStrUAHCurrCode, cStrDefCurrCode)+sUser;
      end;
      optResultLimitForAnalog: begin
        if (Value<1) then Value:= 1 else if (Value>30) then Value:= 30;
        s:= s+'WOCLMAXROWFORSHOWANALOGS='+IntToStr(Value)+sUser;
      end;
      else begin
        s:= 'UPDATE WEBCLIENTCONTRACTS set ';
        sUser:= ' where WCCCLIENT='+IntToStr(UserID)+
          ' and WCCCONTRACT='+IntToStr(Client.LastContract);
        case ActionID of
          optDeliveryType: begin
            if not (Value in [cDelivTimeTable, cDelivReserve, cDelivSelfGet]) then
              raise EBOBError.Create('����������� ��� �������� - '+IntToStr(Value));
            s:= s+'WCCDeliveryDef='+IntToStr(Value)+sUser;
          end;
          optDestPoint: begin
            s:= s+'wccDestDef='+IntToStr(Value)+sUser;
          end;
          else raise EBOBError.Create('����������� ����� ��������� - '+IntToStr(ActionID));
        end;
      end;
    end;

    ordIBD:= cntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= s;

    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);

    with Client do case ActionID of
      optNoRemindAboutComment: NOTREMINDCOMMENT:= (Value=1);
      optThisContractDocsOnly: DocsByCurrContr:= (Value=1);
      optSearchCurrency      : SearchCurrencyId:= fnIfint(Value=1, cUAHCurrency, cDefCurrency);
      optResultLimitForAnalog: MaxRowShowAnalogs:= Value;
//      optDeliveryType        : DEFDELIVERYTYPE:= fnIfInt(Value=1, 1, 0);
      optDeliveryType        : GetCliContDefs.ID1:= Value;  // �� LastContract
      optDestPoint           : GetCliContDefs.ID2:= Value;  // �� LastContract
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================
procedure prSendVINOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendVINOrder'; // ��� ���������/�������
var UserId, FirmID : integer;
    s1, s2, s3, mail, s: string;
    Body: TStringList;
begin
  Stream.Position:= 0;
  Body:= TStringList.Create;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    s1:= Stream.ReadStr;
    s2:= Stream.ReadStr;
    s3:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csSendVINOrder, UserID, FirmID); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Body.Add('������������� ����������� '+Cache.arFirmInfo[FirmID].Name+
      ' ��� ������� '+Cache.arClientInfo[UserID].Login+' '+
      FormatDateTime('dd.mm.yyyy � hh:nn', Now)+' �������� ������ �� ���-����'#13#10);
    Body.Add(s1);
    Body.Add('����������� ��������:'#13#10);
    Body.Add(s2);
    Body.Add('���������� ������:'#13#10);
    Body.Add(s3);
    mail:= Cache.GetConstEmails(pcVINmailEmpl_list, s);
    if mail='' then raise EBOBError.Create('��������, �� ��� ������ �� ����� ���� ��������� -'+
                                     ' � ������� ����������� E-mail �������� �������');
    s:= n_SysMailSend(mail, '������ �� VIN-����', Body, nil, '', '', True);
    if s<>'' then
      fnWriteToLog(ThreadData, lgmsSysError, nmProc,
        '�� ������� E-mail ����������� � ������ E-mail ��� ������ ������� �� VIN-����', s, '');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(Body);
end;
//================================================================ ������ ������
procedure prDownloadPrice(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prDownloadPrice'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserId, FirmID, i, Version, contID, LoadLimit, LoadCount, currID, pDirect: integer;
    s, sParam, PrDirName, sAddVis: String;
    rbs, FileName: RawByteString;
    Body: TStringList;
    Ware: TWareInfo;
    Firm: TFirmInfo;
    RestMain, RestAll, RestThird: double;
    Stream1: TBoBMemoryStream;
    Contract: TContract;
//    ForbiddenBrands: Tai;
    rests: TDoubleDynArray;
    flAdd: Boolean;
//    slashes: Tas;
begin
  Stream.Position:= 0;
  Stream1:= nil;
  Body:= nil;
  contID:= 0;
//  SetLength(ForbiddenBrands, 0);
//  SetLength(slashes, 0);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    Version:= Stream.ReadInt; // �����������
    sParam:= 'version='+IntToStr(Version)+#13#10'ContID='+IntToStr(ContID);
    try
      if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

      Firm:= Cache.arFirmInfo[FirmId];
      if not Firm.EnablePriceLoad or Firm.IsFinalClient then
        raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

      Contract:= firm.GetContract(contID);
      if (Contract.Status=cstClosed) then raise EBOBError.Create('�������� '+
        Contract.Name+' ������, ������� � ����������� ��������');

     //------------------------------- ��������� ����� ����������, ���� �� �����
      LoadLimit:= Cache.GetConstItem(pcLoadPriceBlockLimit).IntValue;
      if (LoadLimit>0) then begin
        IBD:= cntsLOG.GetFreeCnt;
        try
          IBS:= fnCreateNewIBSQL(IBD, 'IBSLOG_'+nmProc, ThreadData.ID, tpRead, True);
          IBS.SQL.Text:= 'Select LUCLOADPRICE FROM LOGUSERCOUNTS WHERE LUCDATE="today"'+
            ' and LUCFIRMID='+IntToStr(FirmId)+' and LUCUSERID='+IntToStr(UserID);
          IBS.ExecQuery;
          if (IBS.EOF and ibs.Bof) then LoadCount:= 0
          else LoadCount:= IBS.FieldByName('LUCLOADPRICE').AsInteger;
        finally
          prFreeIBSQL(IBS);
          cntsLOG.SetFreeCnt(IBD);
        end;
        if (LoadCount>=LoadLimit) then
          raise EBOBError.Create('�������� ����� ���������� �������');
      end; // if (LoadLimit>0)

//      ForbiddenBrands:= Cache.GetDownLoadExcludeBrands;

{
      SetLength(slashes, length(Cache.arWareInfo));
      for i:= 0 to High(slashes) do slashes[i]:= '';

      if Firm.ShowZeroRests                                         // �����
        and (Version in [cpdHD, cpdAutoHD, cpdMotoHD, cpdMotulHD,
        cpdAutoMotoHD, cpdAutoMotulHD, cpdMotoMotulHD]) then begin  // ���� HD

        IBD:= cntsGRB.GetFreeCnt;
        try
          IBS:= fnCreateNewIBSQL(IBD, 'IBSGRB_'+nmProc, ThreadData.ID, tpRead, True);

          s:= Cache.GetConstItem(pcNotShowWareStates).StrValue;
if flShowWareByState then
          IBS.SQL.Text:= 'Select warecode, WARESLASHCODE FROM wares'+
            ' inner join WareProducts on wrprregistrcode=wareproductscode'+
            '   and WrPrProductDirection='+IntToStr(cpdCodeHD)+
            ' inner join WARECACHE_VLAD wc on wc.wacacode=warecode'+
            '   and wc.WACAWAREsvkState>0 and not wc.WACAWAREsvkState in ('+s+')'+
            ' where WARESLASHCODE is not null'
else
          IBS.SQL.Text:= 'Select warecode, WARESLASHCODE FROM wares'+
            ' inner join WareProducts on wrprregistrcode=wareproductscode'+
            '   and WrPrProductDirection='+IntToStr(cpdCodeHD)+
            ' where WARECHILDCOUNT=0 and warearchive="F" and warebonus="F"'+
            '   and not (select first 1 WSState from WareState'+
            '   where WSWareCode=warecode and WSDate<current_timestamp'+
            '   order by WSDate desc) in ('+s+') and WARESLASHCODE is not null';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            i:= IBS.FieldByName('warecode').AsInteger;
            if (i>0) and (i<Length(slashes)) then
              slashes[i]:= IBS.FieldByName('WARESLASHCODE').AsString;
            IBS.Next;
          end;
        finally
          prFreeIBSQL(IBS);
          cntsGRB.SetFreeCnt(IBD);
        end;
      end; // if Firm.ShowZeroRests
}
      flAdd:= Cache.arDprtInfo[Contract.MainStorage].HasDprtFrom2;
      if flContCurrPrice then currID:= Contract.DutyCurrency else currID:= cDefCurrency;

      Body:= TStringList.Create;
      for i:= 0 to High(Cache.arWareInfo) do begin
        if not Cache.WareExist(i) then continue;
        Ware:= Cache.GetWare(i);
        if not Ware.isWare or Ware.IsArchive then continue;
        if Ware.IsINFOgr or Ware.IsPrize then continue;                        // ���������� ���� � �����
        if (Ware.PgrID=0) or (Ware.PgrID=Cache.pgrDeliv) then continue;        // ���������� ��������
        if not Ware.IsMarketWare(FirmID, contID) then continue;                // ���������� �����������
//        if (fnInIntArray(Ware.WareBrandID, ForbiddenBrands)>-1) then continue; // ���������� ����������� ������
        if Ware.LoadPriceEx then continue;                                     // ���������� ����������� ������

        PrDirName:= Ware.PrDirectName;
        pDirect:= Ware.ProdDirect;
        case Version of // ���������� ����������� �����������
          cpdAuto         : if (pDirect<>cpdCodeAuto)  then Continue;
          cpdMoto         : if (pDirect<>cpdCodeMoto)  then Continue;
          cpdMotul        : if (pDirect<>cpdCodeMotul) then Continue;
          cpdHD           : if (pDirect<>cpdCodeHD)    then Continue;
          cpdAutoMoto     : if (pDirect<>cpdCodeAuto)  and (pDirect<>cpdCodeMoto)  then Continue;
          cpdAutoMotul    : if (pDirect<>cpdCodeAuto)  and (pDirect<>cpdCodeMotul) then Continue;
          cpdMotoMotul    : if (pDirect<>cpdCodeMoto)  and (pDirect<>cpdCodeMotul) then Continue;
          cpdAutoHD       : if (pDirect<>cpdCodeAuto)  and (pDirect<>cpdCodeHD)    then Continue;
          cpdMotoHD       : if (pDirect<>cpdCodeMoto)  and (pDirect<>cpdCodeHD)    then Continue;
          cpdMotulHD      : if (pDirect<>cpdCodeMotul) and (pDirect<>cpdCodeHD)    then Continue;
          cpdAutoMotoHD   : if (pDirect<>cpdCodeAuto)  and (pDirect<>cpdCodeMoto)  and (pDirect<>cpdCodeHD)    then Continue;
          cpdAutoMotulHD  : if (pDirect<>cpdCodeAuto)  and (pDirect<>cpdCodeMotul) and (pDirect<>cpdCodeHD)    then Continue;
          cpdMotoMotulHD  : if (pDirect<>cpdCodeMoto)  and (pDirect<>cpdCodeMotul) and (pDirect<>cpdCodeHD)    then Continue;
          cpdAutoMotoMotul: if (pDirect<>cpdCodeAuto)  and (pDirect<>cpdCodeMoto)  and (pDirect<>cpdCodeMotul) then Continue;
        end;

        rests:= GetContWareRestsByCols(ware.ID, ContID, fnIfInt(flAdd, 3, 2));
        RestMain:= rests[0];
        RestAll:= rests[1];
        if flAdd then RestThird:= rests[2] else RestThird:= 0;
        sAddVis:= fnIfStr(flAdd, '"'+fnRestValuesForReport(RestThird)+'"', '');

        s:='"'+IntToStr(Ware.ID)+'";"'+Ware.WareBrandName+'";"'+Ware.Name+'";"'+Ware.WareSupName+
          '";"'+FormatFloat(cFloatFormatSumm, Ware.SellingPrice(FirmID, currID, contID))+
          '";"'+fnRestValuesForReport(RestMain)+'";"'+fnRestValuesForReport(RestAll)+'";"'+
          StringReplace(Ware.Comment, '"', '""', [rfReplaceAll])+'";'+sAddVis+';"'+PrDirName+'"';
//          +fnIfStr(Firm.ShowZeroRests, ';"'+slashes[i]+'"', '');
        Body.Add(s);
      end; // for i:= 0 to High(Cache.arWareInfo)
//      Body.Sort;

      s:= '"���������� ���";"�����";"������ ������������";"�������";'+
          '"����,'+Cache.GetCurrName(currID, True)+
          '";"������� �� ������ �� ���������";"��������� ������� �� ��������� �������";'+
          '"�����������";'+fnIfStr(flAdd, '"�������� >1 ���"', '')+';"�����������"';
//          +fnIfStr(Firm.ShowZeroRests, ';"����-���"', '');
      Body.Insert(0, s);

      Stream.Clear;
      Stream.WriteInt(aeSuccess);

      FileName:= RawByteString('pricevlad_'+FormatDateTime('yyyymmdd_hhnnss', Now())+'_Contr#'+Contract.Name);
      rbs:= RawByteString(Body.Text);
      i:= Length(rbs);

      Stream1:= TBoBMemoryStream.Create;
      Stream1.Write(Pointer(rbs)^, i);
      rbs:= RawByteString(GetAppExePath);
      Stream1.Position:= 0;
      ZipStream(Stream1, rbs, FileName+'.csv');

      Stream.WriteStr(ZipContentType);
      Stream.WriteStr(String(FileName+'.zip'));
      Stream.WriteInt(Stream1.Size);
      Stream.CopyFrom(Stream1, Stream1.Size);
      sParam:= sParam+#13#10'Succes=true'; // ����������� - ������� �������� ��������
    finally
      prSetThLogParams(ThreadData, csDownloadPrice, UserID, FirmID, sParam);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(Body);
  prFree(Stream1);
//  SetLength(ForbiddenBrands, 0);
  SetLength(rests, 0);
//  SetLength(slashes, 0);
end;

//==============================================================================
procedure prShowNotificationOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowNotification'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    ordIBS: TIBSQL;
    UserId, FirmID, NotifyID : integer;
    s: string;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
//  ordIBS:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    NotifyID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowNotification, UserID, FirmID, 'NotifyID='+IntToStr(NotifyID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if (FirmID<>isWe) then begin
      s:= Cache.SetClientNotifiedKind(UserId, NotifyID, 0);
      if s<>'' then raise EBOBError.Create(s);
      s:= Cache.Notifications[NotifyID].Name;
    end else try
      OrdIBD:= cntsORD.GetFreeCnt;
      ordIBS:= fnCreateNewIBSQL(OrdIBD, 'ordIBS_'+nmProc, ThreadData.ID, tpRead, True);
      ordIBS.SQL.Text:= 'Select * FROM NOTIFICATIONS WHERE NOTECODE='+IntToStr(NotifyID);
      ordIBS.ExecQuery;
      if ordIBS.EOF then raise EBOBError.Create('�� ������� ����������� � ����� '+IntToStr(NotifyID));
      s:= ordIBS.FieldByName('NOTETEXT').AsString;
    finally
      prFreeIBSQL(ordIBS);
      cntsORD.SetFreeCnt(OrdIBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(s);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prConfirmNotification(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prConfirmNotification'; // ��� ���������/�������
var UserId, FirmID, NotifyID : integer;
    s: string;
begin
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    NotifyID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csConfirmNotification, UserID, FirmID, 'NotifyID='+IntToStr(NotifyID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Cache.SetClientNotifiedKind(UserId, NotifyID, 1);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//================================================== ������ ���������� �/� (Web)
procedure prContractList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prContractList'; // ��� ���������/�������
var UserId, FirmID, i, iCount, j: integer;
    s: string;
    Contract: TContract;
    Client: TClientInfo;
    fl: Boolean;
begin

if flCredProfile then begin
  prContractList_new(Stream, ThreadData);
  Exit;
end;

  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csContractList, UserID, FirmID); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Client:= Cache.arClientInfo[UserID];
    iCount:= Client.CliContracts.Count;
    Stream.WriteInt(iCount);
    for i:= 0 to iCount-1 do begin
      j:= Client.CliContracts[i];
      Contract:= Client.GetCliContract(j);
      Stream.WriteInt(Contract.ID);
      Stream.WriteStr(Contract.Name);
      Stream.WriteInt(Contract.PayType);
      Stream.WriteStr(Contract.LegalFirmName); // ��.����
      Stream.WriteInt(Contract.DutyCurrency);
      if (Contract.Status=cstClosed) then begin
        Stream.WriteStr('');
        Stream.WriteStr('');
      end else begin
        Stream.WriteStr(Cache.GetDprtShortName(Contract.MainStorage));
        Stream.WriteStr(Cache.GetDprtMainName(Contract.MainStorage));
      end;

      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency, True));
      Stream.WriteInt(Contract.CredDelay);

      Stream.WriteDouble(Contract.DebtSum);
      Stream.WriteDouble(Contract.OrderSum); // ������
      s:= Contract.WarnMessage;
      Stream.WriteInt(Contract.Status);
      fl:= Contract.SaleBlocked;
// Status=cstClosed, WarnMessage=""   - ������              - ��� ����
// Status=cstWorked, WarnMessage=""   - ���������           - ������� ���
// SaleBlocked=True, WarnMessage<>""  - ������������/������ - ������� ���
// SaleBlocked=False, WarnMessage<>"" - ���������/������    - ��������� ���
      Stream.WriteBool(fl);
      Stream.WriteStr(s);
      Stream.WriteDouble(Contract.RedSum);
      Stream.WriteDouble(Contract.VioletSum);
      Stream.WriteStr(Contract.ContComments); // �����������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//====================================== ������ ���������� �/� �� �������� (Web)
procedure prContractList_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prContractList'; // ��� ���������/�������
var UserId, FirmID, i, ii, j, posProf, posCont, ProfCount, contCount, stat: integer;
    sWarn, sDprt1, sDprt2: string;
    Contract: TContract;
    Client: TClientInfo;
    firma: TFirmInfo;
    prof: TCredProfile;
    flBlock: Boolean;
begin
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csContractList, UserID, FirmID); // �����������

    if CheckNotValidUser(UserID, FirmID, sWarn) then raise EBOBError.Create(sWarn);

    firma:= Cache.arFirmInfo[FirmID];
    Client:= Cache.arClientInfo[UserID];

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    posProf:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� ��������
    ProfCount:= 0;      // ������� ��������

    for ii:= 0 to firma.FirmCredProfiles.Count-1 do begin
      prof:= TCredProfile(firma.FirmCredProfiles[ii]);
      if not Assigned(prof) then prof:= ZeroCredProfile;

      posCont:= Stream.Position;
      Stream.WriteInt(0); // ����� ��� ���-�� ���������� � �������
      contCount:= 0;      // ������� ���������� � �������

      for i:= 0 to Client.CliContracts.Count-1 do begin
        j:= Client.CliContracts[i];
        Contract:= Client.GetCliContract(j);
        if (Contract.CredProfile<>prof.ID) then Continue; // ����� �� �������

        sWarn:= Contract.WarnMessage;
        flBlock:= Contract.SaleBlocked or prof.Blocked or firma.SaleBlocked;
        if flBlock and (Contract.Status=cstWorked) then begin
          stat:= cstBlocked;
          if prof.Blocked then
            sWarn:= sWarn+fnIfStr(sWarn='', '', ', ')+prof.WarnMessage;
          if firma.SaleBlocked then
            sWarn:= sWarn+fnIfStr(sWarn='', '', ', ')+'�������� ���������';
        end else stat:= Contract.Status;          // ������ ��������� ��� ������

        if (Contract.Status=cstClosed) then begin
          sDprt1:= '';
          sDprt2:= '';
        end else begin
          sDprt1:= Cache.GetDprtShortName(Contract.MainStorage);
          sDprt2:= Cache.GetDprtMainName(Contract.MainStorage);
        end;

        Stream.WriteInt(Contract.ID);            // ��� ���������
        Stream.WriteStr(Contract.Name);          // ����� ���������
        Stream.WriteInt(Contract.PayType);
        Stream.WriteStr(Contract.LegalFirmName); // ��.����
        Stream.WriteInt(Contract.DutyCurrency);  // ������ ������
        Stream.WriteStr(sDprt1);                 // DprtShortName
        Stream.WriteStr(sDprt2);                 // DprtMainName
//--------------------- ������������ ������ �������
        Stream.WriteDouble(prof.ProfCredLimit); // ����� ����� �������
        Stream.WriteStr(Cache.GetCurrName(prof.ProfCredCurrency, True)); // ������
        Stream.WriteInt(prof.ProfCredDelay);    // ����� ��������
        Stream.WriteDouble(prof.ProfDebtAll);   // ����� ���� - ��������� ������ !!!
//-------------------------------------------------
        Stream.WriteDouble(Contract.DebtSum);  // ���� ���������
        Stream.WriteDouble(Contract.OrderSum); // ������ ���������
// Status=cstClosed, WarnMessage=""   - ������              - ��� ����
// Status=cstWorked, WarnMessage=""   - ���������           - ������� ���
// SaleBlocked=True, WarnMessage<>""  - ������������/������ - ������� ���
// SaleBlocked=False, WarnMessage<>"" - ���������/������    - ��������� ���
        Stream.WriteInt(stat);     // ������ ���������
        Stream.WriteBool(flBlock); // SaleBlocked
        Stream.WriteStr(sWarn);    // WarnMessage
        Stream.WriteDouble(Contract.RedSum);    // ����������
        Stream.WriteDouble(Contract.VioletSum); // �������� ����
        Stream.WriteStr(Contract.ContComments); // �����������
        Inc(contCount);
      end; // for i:= 0 to Client.CliContracts.Count-1

      Stream.Position:= posCont; // ������������ �� ������� �������� ����������
      if (contCount>0) then begin // ���� ��������� �� �������
        Stream.WriteInt(contCount);    // ����� ���-�� ����������
        Stream.Position:= Stream.Size; // ���� � ����� Stream
        Inc(ProfCount);
      end;
    end; // for ii:= 0 to firma.FirmCredProfiles.Count-1

    if (ProfCount>0) then begin
      Stream.Position:= posProf;
      Stream.WriteInt(ProfCount); // ���-�� ��������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prRemindPass(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prRemindPass'; // ��� ���������/�������
      ErrStr = '������ �������������� ������ - ';
var IBS: TIBSQL;
    IBD: TIBDatabase;
    UserId, FirmID, ind, ps: integer;
    s, login, IP, CliMail: string;
    Client: TClientInfo;
    flMail: Boolean;
    ilst: TIntegerList;
    lst: TStringList;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
//  Client:= nil;
  ilst:= TIntegerList.Create; // ����� �� Email: ���� �/�
  lst:= TStringList.Create;   // ����� �� Email: ����� � ������
//  flMail:= False;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    login:= Stream.ReadStr;  // ��� Email
    IP:= Stream.ReadStr;

    ps:= pos('@', login);
    flMail:= (ps>0); // ���� ������ �� Email

    prSetThLogParams(ThreadData, csRemindPass, UserID, FirmID,
      fnIfStr(flMail, 'Email=', 'login=')+login+' IP='+IP); // �����������
//    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if (login='') then raise EBOBError.Create('����������� ����� ��� Email.');

    UserId:= -1;
    if flMail then begin //-------------------------------------------- �� Email
      CliMail:= ExtractFictiveEmail(Login);
      if not fnCheckEmail(CliMail) then  // ��������� Email
        raise EBOBError.Create('������������ Email');
      try                     // ���� � ����
        IBD:= cntsGRB.GetFreeCnt;
        IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
        IBS.SQL.Text:= 'Select PEPERSONCODE from PERSONEMAILS'+
          ' inner join PERSONS on PRSNCODE=PEPERSONCODE and PRSNARCHIVEDKEY="F"'+
          '   and PRSNLOGIN is not null and trim(PRSNLOGIN)<>""'+
          ' inner join firms on firmcode=PRSNFIRMCODE and FIRMARCHIVEDKEY="F"'+
          '   and FirmServiceFirm="F" where PEARCHIVEDKEY="F"'+
          '   and :email containing ","||PEUPPEREMAIL||","';
        IBS.ParamByName('email').AsString:= ','+UpperCase(CliMail)+',';
        IBS.ExecQuery;
        while not IBS.Eof do begin
          UserId:= IBS.FieldByName('PEPERSONCODE').AsInteger;
          Cache.TestClients(UserId, true); // �������� ������ ������� � ���
          if Cache.ClientExist(UserId) then begin
            Client:= Cache.arClientInfo[UserId];
            if Client.Blocked then
              s:= ErrStr+'����� "'+Client.Login+'" ������������.'
            else s:= '�����: '+Client.Login+' - ������: '+Client.Password;
            lst.AddObject(s, Pointer(UserId));
            ilst.Add(Client.FirmID);
          end; // if Cache.ClientExist
          TestCssStopException;
          IBS.Next;
        end;
        IBS.Close;
      finally
        prFreeIBSQL(IBS);
        cntsGRB.SetFreeCnt(IBD);
      end;
      if (lst.Count<1) then raise EBOBError.Create(ErrStr+'Email "'+login+'" �� ������.');

    end //--------------------- �� Email
    else begin //----------------------------------------------------- �� ������

      if not fnCheckOrderWebLogin(Login) then  // ��������� �����
        raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));

      ind:= Cache.arClientInfo.WorkLogins.IndexOf(login);
      if (ind>-1) then UserId:= integer(Cache.arClientInfo.WorkLogins.Objects[ind])
      else try                     // ���� �� ����� � ����, �� ���� � ����
        IBD:= cntsORD.GetFreeCnt;
        IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
        IBS.SQL.Text:= 'Select WOCLCODE from WEBORDERCLIENTS where WOCLLOGIN=:LOGIN';
        IBS.ParamByName('LOGIN').AsString:= login;
        IBS.ExecQuery;
        if not (IBS.Bof and IBS.Eof) then UserId:= IBS.FieldByName('WOCLCODE').AsInteger;
        IBS.Close;
      finally
        prFreeIBSQL(IBS);
        cntsORD.SetFreeCnt(IBD);
      end;
      if (UserId<1) then raise EBOBError.Create(ErrStr+'����� "'+login+'" �� ������.');
      Cache.TestClients(UserId, true); // �������� ������ ������� � ���
      if not Cache.ClientExist(UserId) then
        raise EBOBError.Create(ErrStr+'����� "'+login+'" �� ������.');

      Client:= Cache.arClientInfo[UserId];
      if Client.Blocked then raise EBOBError.Create(ErrStr+'����� "'+login+'" ������������.');

      s:= '';
      CliMail:= ExtractFictiveEmail(Client.Mail);
      if (CliMail='') then s:= '����������� e-mail.'
      else if not fnCheckEmail(CliMail) then s:= '������������ e-mail: '+CliMail+'.';
      if (s<>'') then raise EBOBError.Create(ErrStr+'� ������� ������ � ������� "'+login+'" '+s+
        ' �������� ���� ����� � e-mail �������������� ���� ����������� ��������� �������� "���������".');

      lst.Add('�����: '+Client.Login);
      lst.Add('������: '+Client.Password);
      lst.Add('������� ������ ����������� ����������� '+Client.FirmName);
      ilst.Add(Client.FirmID);
    end; //--------------------- �� ������
    s:= '';
    try
      IBD:= cntsLOG.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, True);
      IBS.SQL.Text:= 'select rErrText from CheckFirmIPRePass(:FirmID, :IP, '+
        Cache.GetConstItem(pcClientRePassTryLimit).StrValue+', '+
        Cache.GetConstItem(pcClientRePassMinutes).StrValue+')';
      IBS.ParamByName('IP').AsString:= IP;
      for ind:= 0 to ilst.Count-1 do begin
        with IBS.Transaction do if not InTransaction then StartTransaction;
        IBS.ParamByName('FirmID').AsInteger:= ilst[ind];
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
        if (IBS.FieldByName('rErrText').AsString<>'') then
          s:= s+fnIfStr(s='', '', ' ')+IBS.FieldByName('rErrText').AsString;
        IBS.Transaction.Commit;
      end;
    finally
      prFreeIBSQL(IBS);
      cntsLOG.SetFreeCnt(IBD);
    end;
    if (s<>'') then raise EBOBError.Create(s);

//    if flMail then  //--------------------- �� Email
      s:= prSendMailWithClientPassw(kcmRemindPass, '', '', CliMail, ThreadData, '', lst);
//    else            //--------------------- �� ������
//      s:= prSendMailWithClientPassw(kcmRemindPass, Client.Login, Client.Password,
//                                    CliMail, ThreadData, Client.FirmName);

    if (s='') then s:= '����������� ������ ���������� �� Email '+
      fnIfStr(flMail, CliMail, '������������ � ������� '+login)+
      '. ��������! ���� ������ ��� � ����� �������� - ��������� ����� ����.';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(s);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(ilst);
  prFree(lst);
end;
//==============================================================================
procedure prGetContracts(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetContracts'; // ��� ���������/�������
var UserId, FirmID, ContID, MainStorage: integer;
    Client: TClientInfo;
    Firm: TFirmInfo;
    Contract: TContract;
    errmess: string;
begin
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetContracts, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserID];
    Firm:= Cache.arFirmInfo[FirmID];
    ContID:= Client.LastContract;
    Contract:= firm.GetContract(ContID);
    MainStorage:= Contract.MainStorage;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(Cache.arDprtInfo[MainStorage].ColumnName); //
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prGetMainStoreLocation(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetMainStoreLocation'; // ��� ���������/�������
var UserId, FirmID, ContID, MainStorage: integer;
    firm: TFirmInfo;
    Contract: TContract;
    s: string;
    x, y: Single;
    dprt: TDprtInfo;
begin
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetMainStoreLocation, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    s:= '';
    x:= 0;
    y:= 0;
    ContID:= Cache.arClientInfo[UserID].LastContract;
    firm:= Cache.arFirmInfo[FirmID];
    Contract:= firm.GetContract(ContID);
    if (Contract.Status=cstClosed) then Contract:= firm.GetDefContract;
    MainStorage:= Contract.MainStorage;
    if Cache.DprtExist(MainStorage) then begin
      dprt:= Cache.arDprtInfo[MainStorage];
      s:= dprt.Adress;
      x:= dprt.AdrLatitude;
      y:= dprt.AdrLongitude;
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(s);    // �����
    Stream.WriteDouble(x); // ������
    Stream.WriteDouble(y); // �������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
{//== ���������� TStringList ������ - ���� �� �����������/�������� + ������������
function BonusWaresSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
// � Object ������������ Integer(Round(price)), � List.Delimiter: 'U'- Up, 'D'- Down
// ���������� ���������� List.CustomSort(BonusWaresSortCompare);
var i1, i2: integer;
    s1, s2, delim: String;
begin
  try
    i1:= 0;
    i2:= 0;
    delim:= '=';
    if Assigned(List.Objects[Index1]) then i1:= Integer(List.Objects[Index1]);
    if Assigned(List.Objects[Index2]) then i2:= Integer(List.Objects[Index2]);
    s1:= fnGetBefore(delim, List[Index1]);
    s2:= fnGetBefore(delim, List[Index2]);
    if i1=i2 then Result:= AnsiCompareText(s1, s2)
    else if (List.Delimiter='D') then begin
      if i1<i2 then Result:= 1 else Result:= -1;
    end else if i1<i2 then Result:= -1 else Result:= 1;
  except
    Result:= 0;
  end;
end; }
//============================================ ���������� �� ������� �� ��������
function BonusDescSortCompare(Item1, Item2: Pointer): Integer;
var R1, R2: Double;
    cq1, cq2: TCodeAndQty;
//    ware: TWareInfo;
//    s1, s2: String;
begin
  try
    cq1:= TCodeAndQty(Item1);
    cq2:= TCodeAndQty(Item2);
    R1:= cq1.Qty;
    R2:= cq2.Qty;
    if (R1>R2) then result:= -1 else if (R1<R2) then result:= 1
    else begin
{      ware:= Cache.arWareInfo[cq1.ID];
      s1:= ware.Name;
      ware:= Cache.arWareInfo[cq2.ID];
      s2:= ware.Name;
      result:= AnsiCompareText(s1, s2); }
      Result:= 0;
    end;
  except
    Result:= 0;
  end;
end;
(*
//====================================================== ������ �������� �������
procedure prGetBonusWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBonusWares'; // ��� ���������/�������
var UserId, FirmID, ContID, Pos, i, j, ii, kAtt, kAttv: integer;
    errmess: string;
    olWares:  TObjectList;
    pSelling: Double;
    cq: TCodeAndQty;
    Client: TClientInfo;
    ware: TWareInfo;
    Files: TarWareFileOpts;
    linkt: TTwoLink;
    lst: TList;
  //------------------------------------------ ������ � ����� ��������� ��������
  procedure prSaveToStreamPrizAttributes;
  var i, ii, j, grPos, grCount: Integer;
      lstGr, lst: TList;
      flNew: Boolean;
      attgr: TSubDirItem;
  begin
    grCount:= 0;
    grPos:= Stream.Position;
    Stream.WriteInt(0);             // ����� ��� ���-�� ����� ���������
    lstGr:= Cache.GBPrizeAttrs.Groups.ItemsList; // ������ ����� ��������� (TList) not Free !!!
    for i:= 0 to lstGr.Count-1 do begin
      attgr:= lstGr[i];
      if (attgr.Links.LinkCount<1) then Continue; // ���������� ������ ��������� ��� �������
      flNew:= (attgr.SrcID=1);
  //    Stream.WriteInt(attgr.ID+cGBattDelta); // ��� �� �������
      Stream.WriteInt(attgr.ID);             // ��� ������ ���������
      Stream.WriteStr(attgr.Name);           // ��������
      Stream.WriteBool(flNew);               // ������� ����� ������ ���������
      Inc(grCount);

      lst:= Cache.GBPrizeAttrs.GetGBGroupAttsList(attgr.ID); // ������ ��������� ������
      try
        Stream.WriteInt(lst.Count);       // ���-�� ���������
        for j:= 0 to lst.Count-1 do with TGBAttribute(lst[j]) do begin
  //        Stream.WriteInt(ID+cGBattDelta);   // ��� �������� �� �������
          Stream.WriteInt(ID);               // ��� ��������
          Stream.WriteStr(Name);             // ��������
          Stream.WriteByte(SrcID);           // ���
          with Links.ListLinks do begin //----- ������ ������ �� �������� ��������
            Stream.WriteInt(Count);                     // ���������� ��������
            for ii:= 0 to Count-1 do begin
  //            Stream.WriteInt(GetLinkID(Items[ii])+cGBattDelta); // ��� �������� �� �������
              Stream.WriteInt(GetLinkID(Items[ii]));    // ��� ��������
              Stream.WriteStr(GetLinkName(Items[ii]));  // ���� ��������
            end;
          end;
        end; // for
      finally
        lst.free;
      end;
    end; // for i= 0
    if (grCount<1) then raise EBOBError.Create(MessText(mtkNotFoundData));
    Stream.Position:= grPos;
    Stream.WriteInt(grCount);  // ���-�� �����
    Stream.Position:= Stream.Size;
  end;
  //--------------------------------------------------------------
begin
  Stream.Position:= 0;
  olWares:= TObjectList.Create;
  SetLength(Files, 0);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetBonusWares, UserID, FirmID, 'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserID];
    ContID:= Client.LastContract;

    for i:= 1 to High(Cache.arWareInfo) do if Cache.WareExist(i) then begin
      ware:= Cache.arWareInfo[i];
      if ware.IsArchive then Continue;              // ����� �� ����������
      if not ware.IsPrize then Continue;            // ����� �� ������������
      if (ware.PgrID=Cache.pgrDeliv) then Continue; // ���������� ��������
      pSelling:= ware.SellingPrice(FirmID, Cache.BonusCrncCode, contID);
      if not fnNotZero(pSelling) then Continue;     // ���������� ������ ��� ����
      cq:= TCodeAndQty.Create(ware.ID, pSelling, ware.Name);
      olWares.Add(cq);
    end;

    olWares.Sort(BonusDescSortCompare);   // ���������� �� ������� �� ��������

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

if flBonusAttr then
    prSaveToStreamPrizAttributes; // ������ � ����� ��������� ��������

    Pos:= Stream.Position;
    j:= 0;
    Stream.WriteInt(0); //
    for I:= 0 to olWares.Count-1 do begin
      cq:= TCodeAndQty(olWares[i]);
      ware:= Cache.arWareInfo[cq.ID];
      Stream.WriteInt(cq.ID);        // ��� ������
      Stream.WriteDouble(cq.Qty);    // ���-�� �������
      Stream.WriteStr(ware.Name);    // ������������ ������
      Stream.WriteStr(ware.Comment); // �������� ������
      inc(j);
if flBonusAttr then begin
      lst:= ware.PrizAttLinks.ListLinks;
      Stream.WriteInt(ware.PrizAttGroup); // �������� ��� ������ ���������
      Stream.WriteInt(lst.Count);         // �������� ���-�� �������� ���������
      for ii:= 0 to lst.Count-1 do begin
        linkt:= TTwoLink(lst[ii]);
        kAtt:= TGBAttribute(linkt.LinkPtr).ID;     // ��� ��������
        kAttv:= TBaseDirItem(linkt.LinkPtrTwo).ID; // ��� ��������
        Stream.WriteInt(kAtt);   // �������� ��� ��������
        Stream.WriteInt(kAttv);  // �������� ��� ��������
      end;
end; // if flBonusAttr
    end;
    if (j>0) then begin
      Stream.Position:= Pos;
      Stream.WriteInt(j);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(olWares);
  SetLength(Files, 0);
end;
*)
//====================================================== ������ �������� �������
procedure prGetBonusWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBonusWares'; // ��� ���������/�������
var UserId, FirmID, ContID, Pos, AttvPos, i, wareCount, ii, j, kAtt, kAttv,
      attCount, gr, storeMain, sem: integer;
    errmess, sPrev, s, ss, sArrive: string;
    olWares, olExcludes, olPrevPrices: TObjectList;
    pSelling, curr: Single;
    cq, tc: TTwoCodes;
    Client: TClientInfo;
    ware: TWareInfo;
    linkt: TTwoLink;
    lst: TList;
    StorageCodes: Tai;
    GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
  //------------------------------------------ ������ � ����� ��������� ��������
  procedure prSaveToStreamPrizAttributes;
  var i, ii, j, grPos, grCount: Integer;
      lstGr, lst: TList;
      flNew: Boolean;
      attgr: TSubDirItem;
  begin
    grCount:= 0;
    grPos:= Stream.Position;
    Stream.WriteInt(0);             // ����� ��� ���-�� ����� ���������
    lstGr:= Cache.GBPrizeAttrs.Groups.ItemsList; // ������ ����� ��������� (TList) not Free !!!
    for i:= 0 to lstGr.Count-1 do begin
      attgr:= lstGr[i];
      if (attgr.Links.LinkCount<1) then Continue; // ���������� ������ ��������� ��� �������

      flNew:= (attgr.SrcID=1);
  //    Stream.WriteInt(attgr.ID+cGBattDelta); // ��� �� �������
      Stream.WriteInt(attgr.ID);             // ��� ������ ���������
      Stream.WriteStr(attgr.Name);           // ��������
      Stream.WriteBool(flNew);               // ������� ����� ������ ���������
      Inc(grCount);

      lst:= Cache.GBPrizeAttrs.GetGBGroupAttsList(attgr.ID); // ������ ��������� ������
      for j:= lst.Count-1 downto 0 do with TGBAttribute(lst[j]) do
        if (Links.ListLinks.Count<2) then begin // ���� �������� �������� < 2
          tc:= TTwoCodes.Create(attgr.ID, ID);
          olExcludes.Add(tc); // ���������� ���������� - ���� ������ � ��������
          lst.Delete(j);      // �������
        end;

      try
        Stream.WriteInt(lst.Count);       // ���-�� ���������
        for j:= 0 to lst.Count-1 do with TGBAttribute(lst[j]) do begin
  //        Stream.WriteInt(ID+cGBattDelta);   // ��� �������� �� �������
          if (Links.ListLinks.Count<2) then Continue;
          Stream.WriteInt(ID);               // ��� ��������
          Stream.WriteStr(Name);             // ��������
          Stream.WriteByte(SrcID);           // ���
          with Links.ListLinks do begin //----- ������ ������ �� �������� ��������
            Stream.WriteInt(Count);                     // ���������� ��������
            for ii:= 0 to Count-1 do begin
  //            Stream.WriteInt(GetLinkID(Items[ii])+cGBattDelta); // ��� �������� �� �������
              Stream.WriteInt(GetLinkID(Items[ii]));    // ��� ��������
              Stream.WriteStr(GetLinkName(Items[ii]));  // ���� ��������
            end;
          end;
        end; // for
      finally
        lst.free;
      end;
    end; // for i= 0
    if (grCount<1) then raise EBOBError.Create(MessText(mtkNotFoundData));
    Stream.Position:= grPos;
    Stream.WriteInt(grCount);  // ���-�� �����
    Stream.Position:= Stream.Size;
  end;
  //--------------------------------------------------------------
  function GetPrizeRestSem(wareID: Integer): Integer;
  // -1 - ��� �����, 0- ��� �� ������� ���������, 1- ���� �� �����, 2- ���� �� �������
  var j: Integer;
      q: TCodeAndQty;
      OList: TObjectList;
  begin
    Result:= -1;
    sArrive:= '';
    OList:= Cache.GetWareRestsByStores(wareID); // �������
    try
      for j:= 0 to OList.Count-1 do begin
        q:= TCodeAndQty(OList[j]);
        if (q.Qty<constDeltaZero) then Continue; // ������� ���
        if (Result<0) then Result:= 0;           // ���-�� ����

        if (fnInIntArray(q.ID, StorageCodes)<0) then Continue; // ����� �� ���
        if (q.ID=storeMain) then begin // ������� �����
          Result:= 2;        // ���� �� �������
          break;
        end else if (Result<1) then Result:= 1; // ���� �� �����
      end; // for j:= 0 to OList.Count-1

if flSpecRestSem then
      //------------- ��������� ����������� �������� �� ������� (����.�������=3)
      if (Result=1) then begin
        sArrive:= CheckDprtTodayFill(StoreMain, OList); // ��������� ��� ����.��������
        if (sArrive<>'') then Result:= 3;
      end;
    finally
      prFree(OList);
    end;

  end;
  //--------------------------------------------------------------
begin
  Stream.Position:= 0;
  GBIBD:= nil;
  GBIBS:= nil;
  olWares:= TObjectList.Create;
  olExcludes:= TObjectList.Create;
  olPrevPrices:= TObjectList.Create;
  SetLength(StorageCodes, 0);
  storeMain:= 0;
  sPrev:= '';
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetBonusWares, UserID, FirmID, 'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserID];

    if Client.CheckIsFinalClient then raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

    ContID:= Client.LastContract;          // ???

    storeMain:= fnGetContMainStoreAndStoreCodes(FirmID, ContID, StorageCodes);

    for i:= 1 to High(Cache.arWareInfo) do if Cache.WareExist(i) then begin
      ware:= Cache.arWareInfo[i];
      if ware.IsArchive then Continue;               // ����� �� ����������
      if (ware.PgrID=Cache.pgrDeliv) then Continue;  // ���������� ��������
      if not ware.IsPrize then Continue;             // ����� �� ������������
      pSelling:= ware.SellingPrice(FirmID, Cache.BonusCrncCode, contID);
      if not fnNotZero(pSelling) then Continue;     // ���������� ������ ��� ����
      sem:= GetPrizeRestSem(i);
//      if (sem<0) then Continue;                      // ����� �� ������� - ��� �����
      if (sem<1) then Continue;                      // ����� �� ������� - ��� �� ������� ���������
      cq:= TTwoCodes.Create(ware.ID, sem, pSelling, sArrive);
      olWares.Add(cq);

      if ware.IsCatchMom then begin // ������ ���������� ��� ��� "���� ������"
        cq:= TTwoCodes.Create(ware.ID, 0);
        olPrevPrices.Add(cq);
        sPrev:= sPrev+fnIfStr(sPrev='', '', ',')+IntToStr(ware.ID);
      end;

    end; // for i:= 1 to High(Cache.arWareInfo)

    if (olPrevPrices.Count>0) then begin // ���� ���������� ����
      GBIBD:= CntsGRB.GetFreeCnt();
      try
        s:= IntToStr(Cache.arFirmInfo[FirmID].GetContract(contID).ContPriceType);
        ss:= cStrDefCurrCode;
        GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
        GBIBS.SQL.Text:='select warecode, coalesce(cm.RESULTVALUE, cm1.RESULTVALUE) prev'+
          '  from (select w.warecode, w.waremeas, (select MAX(PriceDate) from PRICELIST'+
          '    where PriceSubFirmCode=1 and PriceWareCode=w.warecode'+
          '      and PriceTypeCode='+s+' and PriceDate<="today") xDate'+
          '    from wares w where w.warecode in ('+sPrev+'))'+
          '  left join GETWAREPRICE(xDate-1, warecode, '+s+', waremeas) p on 1=1'+
          '  left join ConvertMoney(p.RPRICEWARE, p.RCRNCCODE, '+ss+', xDate-1) cm'+
          '    on exists(select * from RateCrnc where RateCrncCode=p.RCRNCCODE)'+
          '  left join GETWAREPRICE("today", warecode, '+s+', waremeas) p1 on 1=1'+
          '  left join ConvertMoney(p1.RPRICEWARE, p1.RCRNCCODE, '+ss+', "today") cm1'+
          '    on exists(select * from RateCrnc where RateCrncCode=p1.RCRNCCODE)'+
          '  where xDate is not null';
        GBIBS.ExecQuery;
        while not GBIBS.EOF do begin
          i:= GBIBS.FieldByName('WareCode').AsInteger;
          for ii:= 0 to olPrevPrices.Count-1 do begin
            tc:= TTwoCodes(olPrevPrices[ii]);
            if (i<>tc.ID1) then Continue;

            pSelling:= GBIBS.FieldByName('prev').AsFloat; // ����.���� � Euro
            curr:= Cache.Currencies.GetCurrRate(Cache.BonusCrncCode);
            if fnNotZero(curr) then                       // ����.���� � �������
              pSelling:= pSelling*Cache.Currencies.GetCurrRate(cDefCurrency)/curr;
            tc.Qty:= RoundToHalfDown(pSelling);
            break;
          end; // for ii:= 0 to olPrevPrices.Count-1
          TestCssStopException;
          GBIBS.Next;
        end;
      finally
        prFreeIBSQL(GBIBS);
        cntsGRB.SetFreeCnt(GBIBD);
      end;
    end; // if (olPrevPrices.Count>0)

    olWares.Sort(BonusDescSortCompare);   // ���������� �� ������� �� ��������

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

if flBonusAttr then
    prSaveToStreamPrizAttributes; // ������ � ����� ��������� ��������

    Pos:= Stream.Position;
    wareCount:= 0;
    Stream.WriteInt(0); //
    for i:= 0 to olWares.Count-1 do begin
      cq:= TTwoCodes(olWares[i]);
      ware:= Cache.arWareInfo[cq.ID1];
      Stream.WriteInt(ware.ID);      // ��� ������
      Stream.WriteDouble(cq.Qty);    // ������ (����)
      Stream.WriteStr(ware.Name);    // ������������ ������
      Stream.WriteStr(ware.Comment); // �������� ������

if flNewBonusFilter then
      Stream.WriteInt(ware.WareBrandID); // ��� ������ ������ (MOTUL - cbrMotul in v_constants)

      pSelling:= 0;
      if ware.IsCatchMom then for ii:= 0 to olPrevPrices.Count-1 do begin
        tc:= TTwoCodes(olPrevPrices[ii]);
        if (ware.ID<>tc.ID1) then Continue;
        pSelling:= tc.Qty;
        break;
      end;
      Stream.WriteBool(ware.IsNews);     // ������� ����� "�������"
      Stream.WriteBool(ware.IsCatchMom); // ������� ����� "���� ������"
      Stream.WriteDouble(pSelling);      // ����������� ������ ("���� ������") ��� 0
      Stream.WriteInt(cq.ID2);           // ������� ��������

if flSpecRestSem then
      Stream.WriteStr(cq.Name);          // ��������� � �������� (���� ������ � 3)

{if flDebug then begin
  if ware.IsNews then
    prMessageLOGS(nmProc+': Ware.IsNews     - '+ware.Name, fLogDebug, false); // ����� � log
  if ware.IsCatchMom then
    prMessageLOGS(nmProc+': Ware.IsCatchMom - '+ware.Name+', now= '+FloatToStr(cq.Qty)+
                  ', prev= '+FloatToStr(pSelling), fLogDebug, false); // ����� � log
end; // if flDebug  }

//------------------------------------------------------ �������� �������
if flBonusAttr then begin
      gr:= ware.PrizAttGroup; // ��� ������ ���������
      attCount:= 0;
      lst:= ware.PrizAttLinks.ListLinks;
      Stream.WriteInt(gr);        // �������� ��� ������ ���������
      AttvPos:= Stream.Position;
      Stream.WriteInt(0);         // ����� ��� ���-�� �������� ���������
      for ii:= 0 to lst.Count-1 do begin
        linkt:= TTwoLink(lst[ii]);
        kAtt:= TGBAttribute(linkt.LinkPtr).ID;   // ��� ��������
        for j:= 0 to olExcludes.Count-1 do begin // ��������� ����������
          tc:= TTwoCodes(olExcludes[j]);
          if (tc.ID1=gr) and (tc.ID2=kAtt) then begin
            kAtt:= 0; //
            break;
          end;
        end;
        if (kAtt<1) then Continue;
        kAttv:= TBaseDirItem(linkt.LinkPtrTwo).ID; // ��� ��������
        Stream.WriteInt(kAtt);   // �������� ��� ��������
        Stream.WriteInt(kAttv);  // �������� ��� ��������
        Inc(attCount);
      end;
      if (attCount>0) then begin
        Stream.Position:= AttvPos;
        Stream.WriteInt(attCount); // �������� ���-�� �������� ���������
        Stream.Position:= Stream.Size;
      end;
end; // if flBonusAttr
//------------------------------------------------------
      inc(wareCount);
    end; // for I:= 0 to olWares.Count-1
    if (wareCount>0) then begin
      Stream.Position:= Pos;
      Stream.WriteInt(wareCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(olWares);
  prFree(olExcludes);
  prFree(olPrevPrices);
  SetLength(StorageCodes, 0);
end;
//------------------------------------------------------------ vc

//========================================= �������� ���������� ��������� ������
procedure prGetOrderHeaderParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetOrderHeaderParams'; // ��� ���������/�������
var ordIBD: TIBDatabase;
    ordIBS: TIBSQL;
    UserId, FirmID, DestID, ShipTableID, ShipMetID, ShipTimeID, DelivType,
      ContID, DprtID, accType, Status, i, MeetPerson: integer;
    OrderCode, sWarrNum, sWarrPers, sStoreComm, sDestName, sShipMet, sShipTime,
      sArrive, sDestAdr, err, sShipView, sSelfComm, sMeetText: string;
    WarrDate, ShipDate: double;
    Accounts, Invoices: TDocRecArr;
    GBdirection, flDontJoin: Boolean;
begin
  Stream.Position:= 0;
  ordIBS:= nil;
//  ordIBD:= nil;
  DestID:= 0;
  ShipDate:= 0;
  ShipTableID:= 0;
  ShipMetID:= 0;
  ShipTimeID:= 0;
  sShipMet:= '';
  sShipTime:= '';
  sArrive:= '';
  sDestName:= '';
  sDestAdr:= '';
  DelivType:= cDelivReserve;
  WarrDate:= 0;
  accType:= 0;
  contID:= 0;
  DprtID:= 0;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  flDontJoin:= False;
  MeetPerson:= 0;
  sMeetText:= '';
  try
//-------------------------- from CGI - begin
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    GBdirection:= Stream.ReadBool;
//-------------------------- from CGI - end

    prSetThLogParams(ThreadData, csGetOrderHeaderParams, UserID, FirmID, 'OrderId='+OrderCode); // �����������

    i:= StrToIntDef(OrderCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    if CheckNotValidUser(UserID, FirmID, err) then raise EBOBError.Create(err);

    ordIBD:= cntsORD.GetFreeCnt;
    try
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, ThreadData.ID, tpWrite, True);
      ordIBS.SQL.Text:= 'Select ORDRSTATUS, ORDRWARRANT, ORDRWARRANTPERSON,'+ // ����  �����
        ' ORDRCONTRACT, ORDRWARRANTDATE, ORDRSTORAGECOMMENT, ORDRDESTPOINT,'+
        ' ORDRSHIPDATE, ORDRTIMETIBLE, ORDRSHIPMETHOD, ORDRSHIPTIMEID, ORDRSTORAGE,'+
        ' ORDRDELIVERYTYPE, ORDRACCOUNTINGTYPE, ORDRSELFCOMMENT, OrdrDontJoinAcc'+
        fnIfStr(flMeetPerson, ', ordrAccMeetPerson, ordrAccMeetText', '')+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
      ordIBS.ExecQuery;
      if ordIBS.Bof and ordIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

      sWarrNum:= ordIBS.FieldByName('ORDRWARRANT').AsString;
      sWarrPers:= ordIBS.FieldByName('ORDRWARRANTPERSON').AsString;
      WarrDate:= ordIBS.FieldByName('ORDRWARRANTDATE').AsDateTime;
      sStoreComm:= ordIBS.FieldByName('ORDRSTORAGECOMMENT').AsString;
      sSelfComm:= ordIBS.FieldByName('ORDRSELFCOMMENT').AsString;
      DelivType:= ordIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger;
      accType:= ordIBS.FieldByName('ORDRACCOUNTINGTYPE').AsInteger;
      Status:= ordIBS.FieldByName('ORDRSTATUS').AsInteger;
      contID:= ordIBS.FieldByName('ORDRCONTRACT').AsInteger;
      if Cache.arClientInfo[UserID].CheckContract(contID) then
        DprtID:= Cache.arClientInfo[UserID].GetCliContract(contID).MainStorage
      else DprtID:= ordIBS.FieldByName('ORDRSTORAGE').AsInteger;

if not flNewSaveAcc then flDontJoin:= True else
      flDontJoin:= GetBoolGB(ordIBS, 'OrdrDontJoinAcc');  // True - �� ���������� �����

if flMeetPerson then begin
      MeetPerson:= ordIBS.FieldByName('ordrAccMeetPerson').AsInteger;
      sMeetText := ordIBS.FieldByName('ordrAccMeetText').AsString;
end; // flMeetPerson

      if ((Status>orstProcessing) and (Status<orstAnnulated)) then begin
        err:= fnGetClosingDocsOrd(OrderCode, Accounts, Invoices, Status, ThreadData.ID);
        if (err<>'') then raise Exception.Create(err);
      end;

     case DelivType of
        cDelivTimeTable: begin //------------------------ �������� �� ����������
          ShipDate:= ordIBS.FieldByName('ORDRSHIPDATE').AsDateTime;
          if (ShipDate<DateNull) then ShipDate:= 0;
          DestID:= ordIBS.FieldByName('ORDRDESTPOINT').AsInteger;
          ShipTableID:= ordIBS.FieldByName('ORDRTIMETIBLE').AsInteger;
          ShipMetID:= ordIBS.FieldByName('ORDRSHIPMETHOD').AsInteger;
          ShipTimeID:= ordIBS.FieldByName('ORDRSHIPTIMEID').AsInteger;
        end; // cDelivTimeTable

        cDelivReserve: begin // ������
        end; // cDelivReserve

        cDelivSelfGet: begin //--------------------------------------- ���������
          ShipDate:= ordIBS.FieldByName('ORDRSHIPDATE').AsDateTime;
//          ShipMetID:= ordIBS.FieldByName('ORDRSHIPMETHOD').AsInteger;
          ShipMetID:= Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue;
          ShipTimeID:= ordIBS.FieldByName('ORDRSHIPTIMEID').AsInteger;
        end; // cDelivSelfGet

      else DelivType:= cDelivReserve; //--------------------------------- ������
      end; // case
      ordIBS.Close;
    finally
      prFreeIBSQL(ordIBS);
      cntsORD.SetFreeCnt(ordIBD);
    end;
    err:= fnGetShipParamsView(contID, DprtID, DestID, ShipTableID, ShipDate,
          DelivType, ShipMetID, ShipTimeID, sDestName, sDestAdr, sArrive,
          sShipMet, sShipTime, sShipView, GBdirection);
    if (err<>'') then raise Exception.Create(err);

    if (WarrDate<DateNull) then WarrDate:= 0;
    if (ShipDate<DateNull) then ShipDate:= 0;

    Stream.Clear;
//-------------------------- to CGI - begin
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(sWarrNum);    // ����� �����������
    Stream.WriteStr(sWarrPers);   // ��� � �����������
    Stream.WriteDouble(WarrDate); // ���� �����������
    Stream.WriteStr(sStoreComm);  // �����������
    Stream.WriteStr(sSelfComm);   // ������ �����������
    Stream.WriteInt(DelivType);   // ��� ��������
    Stream.WriteInt(accType);     // ��� ������: 0- ���, 1- �/���

    Stream.WriteInt(DestID);      // ��� �������� �����
    Stream.WriteStr(sDestName);   // �������� �������� �����
    Stream.WriteStr(sDestAdr);    // ����� �������� �����
    Stream.WriteDouble(ShipDate); // ���� ��������
    Stream.WriteInt(ShipTableID); // ��� ����������
//    Stream.WriteInt(ShipMetID);   // ��� ������� ��������
    Stream.WriteStr(sShipMet);    // �������� ������� ��������
    Stream.WriteInt(ShipTimeID);  // ��� ������� ��������
    Stream.WriteStr(sShipTime);   // ����� ������� ��������
    Stream.WriteStr(sArrive);     // ����� ����/������� ��������

    Stream.WriteInt(Length(Accounts)); // ���-��
    for i:= Low(Accounts) to High(Accounts) do begin
      Stream.WriteInt(Accounts[i].ID);
      if (Accounts[i].ID>0) then with Accounts[i] do begin
                  // ���� f -���� �����., ���� t-  ���., ���� ������ - ���������
        Stream.WriteByte(fnIfInt(Accounts[i].Processed, byte('t'), byte('f')));
        Stream.WriteStr(Cache.GetDprtMainName(DprtID));
        Stream.WriteStr(Number+cWebSpace+fnIfStr(Accounts[i].Processed, cWebProcessed, ''));
        Stream.WriteStr(Commentary);
        Stream.WriteDouble(Data);
        Stream.WriteDouble(Summa);
        Stream.WriteStr(CurrencyName);
      end;
      Stream.WriteInt(Invoices[i].ID);
      if (Invoices[i].ID>0) then with Invoices[i] do begin
        Stream.WriteStr(Cache.GetDprtMainName(DprtID));
        Stream.WriteStr(Number);
        Stream.WriteDouble(Data);
        Stream.WriteDouble(Summa);
        Stream.WriteStr(CurrencyName);
      end;
    end;

if flNewSaveAcc then
    Stream.WriteBool(flDontJoin); // True - �� ���������� �����

if flMeetPerson then begin
    Stream.WriteInt(MeetPerson);  // ��� ������������
    Stream.WriteStr(sMeetText);   // ����� ������������
end; // flMeetPerson

//-------------------------- to CGI - end
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
end;
//============================================== �������������� ��������� ������
procedure prEditOrderHeaderParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prEditOrderHeaderParams'; // ��� ���������/�������
      Mess1  = ' ����� ��������� �� ����� ';
      Mess2  = ' ��������, ������ - ';
var ordIBD, grbIBD: TIBDatabase;
    ordIBS, grbIBS: TIBSQL;
    UserID, FirmID, DestID, stID, smID, ttID, deliv, ContID, DprtID, i, Curr,
      OrderID, WareCount, MeetPerson, lenMeetText: integer;
    OrderCode, sWarrNum, sWarrPers, sStoreComm, s, ss, ErrorPos, SResult, sMeetText: string;
    flWarrNum, flWarrPers, flStoreComm, flWarrDate, flShipDate, flRefreshPrice,
      flSendToProcessing, flSelfComm, flResLimit, flDontJoin, flMeetText, flCheckWareLimits: Boolean;
    WarrDate, d, sum, LineSum, OrderSum: double;
    firma: TFirmInfo;
    Contract: TContract;
    ShipDate: TDateTime;
//    ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  ordIBS:= nil;
//  ordIBD:= nil;
  grbIBS:= nil;
  grbIBD:= nil;
//  ffp:= nil;
  flWarrNum:= False;
  flWarrPers:= False;
  flWarrDate:= False;
  flStoreComm:= False;
  flShipDate:= False;
  flSelfComm:= False;
  flMeetText:= False;
  ContID:= 0;
  smID:= 0;   // ��� ������� ��������
  MeetPerson:= 0;
  sMeetText:= '';
  try
//-------------------------- from CGI - begin
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;   // ��� ������ � ����.����
    sWarrNum:= Stream.ReadStr;    // ����� �����������
    sWarrPers:= Stream.ReadStr;   // ��� � �����������
    WarrDate:= Stream.ReadDouble; // ���� �����������
    sStoreComm:= Stream.ReadStr;  // ����������� � ����
    deliv:= Stream.ReadInt;       // ��� ��������: 0 - ��������, 1 - ������, 2 - ���������
    DestID:= Stream.ReadInt;      // ��� �������� �����
    ShipDate:= Stream.ReadDouble; // ���� ��������
    ttID:= Stream.ReadInt;        // ��� ����������
    stID:= Stream.ReadInt;        // ��� ������� ��������
    flSendToProcessing:= Stream.ReadBool; // True - ���������� �� ���������

if flNewSaveAcc then begin
    flDontJoin:= Stream.ReadBool;  // True - �� ���������� �����
end else flDontJoin:= True;

if flMeetPerson then begin
    MeetPerson:= Stream.ReadInt; // ��� (��������) ������������ (��� ������� - 0)
    sMeetText := Stream.ReadStr; // ����� ������������
end; // flMeetPerson

if not flCheckLimits then flCheckWareLimits:= False else
    flCheckWareLimits:= Stream.ReadBool; // ���� �������� ������� �� ���-�� � ����

//-------------------------- from CGI - end

    if (WarrDate<DateNull) then WarrDate:= 0;
    if (ShipDate<DateNull) then ShipDate:= 0;

    prSetThLogParams(ThreadData, csEditOrderHeaderParams, UserID, FirmID, 'OrderId='+OrderCode+ // �����������
      #13#10'ORDRWARRANT='+sWarrNum+#13#10'ORDRWARRANTPERSON='+sWarrPers+
      #13#10'ORDRWARRANTDATE='+FormatDateTime(cDateFormatY2, WarrDate)+
      #13#10'ORDRSTORAGECOMMENT='+sStoreComm+#13#10'ORDRDELIVERYTYPE='+IntToStr(deliv)+
      #13#10'ORDRDESTPOINT='+IntToStr(DestID)+
      #13#10'ORDRSHIPDATE='+FormatDateTime(cDateFormatY2, ShipDate)+
      #13#10'ORDRTIMETIBLE='+IntToStr(ttID)+#13#10'ORDRSHIPTIMEID='+IntToStr(stID));

    OrderID:= StrToIntDef(OrderCode, 0);
    if (OrderID<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    i:= Length(sWarrNum)-Cache.OrdWarrNumLength; // ��������� ����� ��������� ��������
    if (i>0) then raise EBOBError.Create('����� ������������'+Mess1+
      IntToStr(Cache.OrdWarrNumLength)+Mess2+IntToStr(i));
    i:= Length(sWarrPers)-Cache.OrdWarrPersLength;
    if (i>0) then raise EBOBError.Create('���'+Mess1+
      IntToStr(Cache.OrdWarrPersLength)+Mess2+IntToStr(i));
    i:= Length(sStoreComm)-Cache.OrdCommentLength;
    if (i>0) then raise EBOBError.Create('�����������'+Mess1+
      IntToStr(Cache.OrdCommentLength)+Mess2+IntToStr(i));

    if not (deliv in [cDelivTimeTable, cDelivReserve, cDelivSelfGet]) then
      raise EBOBError.Create('����������� ��� �������� - '+IntToStr(deliv));

    firma:= Cache.arFirmInfo[FirmId];

ErrorPos:= '1';
    ordIBD:= cntsORD.GetFreeCnt;
    try
      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, ThreadData.ID, tpRead, True);
      ordIBS.SQL.Text:= 'Select ORDRSTATUS, ORDRWARRANT, ORDRWARRANTPERSON,'+ // ����  �����
        ' ORDRCONTRACT, ORDRWARRANTDATE, ORDRSTORAGECOMMENT, ORDRDESTPOINT,'+
        ' ORDRDELIVERYTYPE, ORDRSTORAGE, ORDRSHIPDATE, ORDRTIMETIBLE, ORDRSUMORDER,'+
        ' ORDRSHIPMETHOD, ORDRSHIPTIMEID, ORDRFIRM, ORDRCURRENCY, ORDRSELFCOMMENT,'+
        ' OrdrWareLineCount, OrdrDontJoinAcc'+
        fnIfStr(flMeetPerson, ', ordrAccMeetPerson, ordrAccMeetText', '')+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
      ordIBS.ExecQuery;
      if ordIBS.Bof and ordIBS.Eof then
        raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
                                      // ���������, ����� �� ����� �������������
      if (ordIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming) then
        raise EBOBError.Create(MessText(mtkNotEditOrder));
                   // ���������, ����� �� ����� ���� ������� ������������� �����
      if ordIBS.FieldByName('ORDRFIRM').AsInteger<>FirmID then
        raise EBOBError.Create(MessText(mtkNotRightExists));

      sum:= ordIBS.FieldByName('ORDRSUMORDER').AsFloat;
      Curr:= ordIBS.FieldByName('ORDRCURRENCY').AsInteger;
      if (contID<1) then contID:= ordIBS.FieldByName('ORDRCONTRACT').AsInteger;

      Contract:= firma.GetContract(contID);
      if (Contract.Status=cstClosed) then   // �������� �� ����������� ���������
        raise EBOBError.Create('�������� '+Contract.Name+' ����������');

      DprtID:= Contract.MainStorage;
      case deliv of
        cDelivTimeTable: begin // �������� �� ����������
          stID:= 0;
          if (ShipDate<1) or (DestID<1) or (DprtID<1) then ttID:= 0
          else if (ttID>0) then try
            grbIBD:= cntsGRB.GetFreeCnt;
            grbIBS:= fnCreateNewIBSQL(grbIBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
            grbIBS.SQL.Text:= 'select rSMethodID, rSTimeID'+
              ' from Vlad_CSS_GetContDestTimeTables1'+
              '('+IntToStr(contID)+', '+IntToStr(DestID)+', '+IntToStr(DprtID)+
              ', :pDate) where RttID='+IntToStr(ttID);
            grbIBS.ParamByName('pDate').AsDate:= ShipDate;
            grbIBS.ExecQuery;
            if not (grbIBS.Bof and grbIBS.Eof) then begin
              smID:= grbIBS.FieldByName('rSMethodID').AsInteger;
              stID:= grbIBS.FieldByName('rSTimeID').AsInteger;
            end else ttID:= 0;
          finally
            prFreeIBSQL(grbIBS);
            cntsGRB.SetFreeCnt(grbIBD);
          end;
        end; // cDelivTimeTable

        cDelivReserve: begin // ������
          DestID:= 0;
          ShipDate:= 0;
          ttID:= 0;
          stID:= 0;
        end; // cDelivReserve

        cDelivSelfGet: begin // ���������
          DestID:= 0;
          ttID:= 0;
          smID:= Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue;
        end; // cDelivSelfGet
      end; // case

      s:= '';
      if (sWarrNum<>ordIBS.FieldByName('ORDRWARRANT').AsString) then begin
        flWarrNum:= (sWarrNum<>'');
        if flWarrNum then ss:= ':ORDRWARRANT' else ss:= 'null';
        s:= s+fnIfStr(s='','',',')+'ORDRWARRANT='+ss;
      end;
      if (sWarrPers<>ordIBS.FieldByName('ORDRWARRANTPERSON').AsString) then begin
        flWarrPers:= (sWarrPers<>'');
        if flWarrPers then ss:= ':ORDRWARRANTPERSON' else ss:= 'null';
        s:= s+fnIfStr(s='','',',')+'ORDRWARRANTPERSON='+ss;
      end;
      d:= ordIBS.FieldByName('ORDRWARRANTDATE').AsDateTime;
      if (trunc(abs(WarrDate-d))>0) then begin
        flWarrDate:= (WarrDate>DateNull);
        if flWarrDate then ss:= ':ORDRWARRANTDATE' else ss:= 'null';
        s:= s+fnIfStr(s='','',',')+'ORDRWARRANTDATE='+ss;
      end;
      if (sStoreComm<>ordIBS.FieldByName('ORDRSTORAGECOMMENT').AsString) then begin
        flStoreComm:= (sStoreComm<>'');  // ����������� � ����
        if flStoreComm then ss:= ':ORDRSTORAGECOMMENT' else ss:= 'null';
        s:= s+fnIfStr(s='','',',')+'ORDRSTORAGECOMMENT='+ss;
      end;
      d:= ordIBS.FieldByName('ORDRSHIPDATE').AsDateTime;
      if (trunc(abs(ShipDate-d))>0) then begin
        flShipDate:= (ShipDate>DateNull);
        if flShipDate then ss:= ':ORDRSHIPDATE' else ss:= 'null';
        s:= s+fnIfStr(s='','',',')+'ORDRSHIPDATE='+ss;
      end;
      if (DestID<>ordIBS.FieldByName('ORDRDESTPOINT').AsInteger) then
        s:= s+fnIfStr(s='','',',')+'ORDRDESTPOINT='+
            fnIfStr(DestID>0, IntToStr(DestID), 'null');
      if (ttID<>ordIBS.FieldByName('ORDRTIMETIBLE').AsInteger) then
        s:= s+fnIfStr(s='','',',')+'ORDRTIMETIBLE='+
            fnIfStr(ttID>0, IntToStr(ttID), 'null');
      if (smID<>ordIBS.FieldByName('ORDRSHIPMETHOD').AsInteger) then
        s:= s+fnIfStr(s='','',',')+'ORDRSHIPMETHOD='+
            fnIfStr(smID>0, IntToStr(smID), 'null');
      if (stID<>ordIBS.FieldByName('ORDRSHIPTIMEID').AsInteger) then
        s:= s+fnIfStr(s='','',',')+'ORDRSHIPTIMEID='+
            fnIfStr(stID>0, IntToStr(stID), 'null');
      if (deliv<>ordIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger) then
        s:= s+fnIfStr(s='','',',')+'ORDRDELIVERYTYPE='+IntToStr(deliv);

if flNewSaveAcc then begin
      if (flDontJoin<>GetBoolGB(ordIBS, 'OrdrDontJoinAcc')) then
        s:= s+fnIfStr(s='','',',')+'OrdrDontJoinAcc="'+fnIfStr(flDontJoin, 'T', 'F')+'"';
end; // flNewSaveAcc

if flMeetPerson then begin
      lenMeetText:= ordIBS.FieldByName('ordrAccMeetText').Size; // �����������
      if not (deliv in [cDelivTimeTable, cDelivSelfGet]) then begin
        MeetPerson:= 0;
        sMeetText:= '';
      end else sMeetText:= copy(sMeetText, 1, lenMeetText);
      if (MeetPerson<>ordIBS.FieldByName('ordrAccMeetPerson').AsInteger) then
        s:= s+fnIfStr(s='','',',')+'ordrAccMeetPerson='+
            fnIfStr(MeetPerson>0, IntToStr(MeetPerson), 'null');
      if (sMeetText<>ordIBS.FieldByName('ordrAccMeetText').AsString) then begin
        flMeetText:= (sMeetText<>'');  //
        if flMeetText then ss:= ':ordrAccMeetText' else ss:= 'null';
        s:= s+fnIfStr(s='','',',')+'ordrAccMeetText='+ss;
      end;
end; // flMeetPerson
      ordIBS.Close;

      fnSetTransParams(ordIBS.Transaction, tpWrite, True); // ������� � ������

  ErrorPos:= '2';
      if (s<>'') then begin //--------- ���� ���� - ����������� ��������� ������
         ordIBS.SQL.Text:=  'Update ORDERSREESTR set '+s+
          ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
        if flWarrNum   then ordIBS.ParamByName('ORDRWARRANT').AsString       := sWarrNum;
        if flWarrPers  then ordIBS.ParamByName('ORDRWARRANTPERSON').AsString := sWarrPers;
        if flWarrDate  then ordIBS.ParamByName('ORDRWARRANTDATE').AsDateTime := WarrDate;
        if flStoreComm then ordIBS.ParamByName('ORDRSTORAGECOMMENT').AsString:= sStoreComm;
        if flShipDate  then ordIBS.ParamByName('ORDRSHIPDATE').AsDateTime    := ShipDate;
        if flMeetText  then ordIBS.ParamByName('ordrAccMeetText').AsString   := sMeetText;
        s:= RepeatExecuteIBSQL(ordIBS);
        if s<>'' then raise Exception.Create(s);

      end else if not flSendToProcessing then raise EBOBError.Create('��� ���������');

//------------------------------------------ ���� ���� - ���������� �� ���������
      if flSendToProcessing then begin

      if flNotReserve and (deliv=cDelivReserve) then
        raise EBOBError.Create('�������������� �������������');

if flMeetPerson then begin
        if (deliv in [cDelivTimeTable, cDelivSelfGet]) and (MeetPerson<1) then
          raise EBOBError.Create('�� ������ �����������');
end; // flMeetPerson
                                                 // ���� �������� ������ �������
        flResLimit:= (firma.ResLimit>=0) and (Curr<>Cache.BonusCrncCode);
        if flResLimit and (firma.ResLimit=0) then
          raise EBOBError.Create('�������������� �������������'); // ???

        //----------------- ��������� ������ ��������
        if (firma.SaleBlocked or Contract.SaleBlocked) then begin
          if (deliv=cDelivTimeTable) then s:= '�������� ����������'
          else if (deliv=cDelivSelfGet) then s:= '��������� ����������'
          else s:= '';
          if (s<>'') then raise EBOBError.Create(s);
        end;

        OrderSum:= 0;
        LineSum:= 0;
        flRefreshPrice:= (Curr<>Cache.BonusCrncCode) and (Curr<>Contract.DutyCurrency);
  ErrorPos:= '3';
        s:= CheckAccountShipParams(deliv, ContID, DprtID, ShipDate, DestID, ttID, smID, stID, True);
        if (s<>'') then raise EBOBError.Create(s);

        //----------------- ��������� ������� �������, ���������� ������ �������
        if flResLimit then firma.CheckReserveLimit; // ��������� ����� �������
        i:= fnIfInt(flRefreshPrice, Contract.DutyCurrency, Curr); // � ����� ������
        if not flResLimit then WareCount:= 2
        else WareCount:= OrdIBS.FieldByName('OrdrWareLineCount').AsInteger;
        s:= CheckOrdWaresExAndOverLimit(FirmID, UserID, ContID, OrderID, i, flResLimit, True, (WareCount<2));
        if s<>'' then raise EBOBError.Create(MessText(mtkNotProcOrder)+' '+s);

        if flRefreshPrice then begin
  ErrorPos:= '4';
          s:= fnRefreshPriceInOrderOrd(SResult, OrderCode, ThreadData);
          if (s<>'') then // ���� ������� ����������� � ������� - ���������� ������
            if copy(s, 1, 3)='EB:' then raise EBOBError.Create(copy(s, 4, length(s)))
            else raise Exception.Create(s);
        end;

        if flCheckWareLimits then begin // ��������� ������ �� ���-�� � ����
  ErrorPos:= '5';


          if ( false ) then begin
            Stream.Clear;
            Stream.WriteInt(erWareLimitOut); // ���������� ������� - ��������� �������������


            Exit;
          end;
        end;

  ErrorPos:= '6';
        //-------------------------------------- ��� ������� ����������� �������
        if flSendToProcessing and (deliv=cDelivReserve) and (sStoreComm<>'') then
          sStoreComm:= ', ORDRSTORAGECOMMENT=""'
        else sStoreComm:= '';
                                               // ��� ��������� - ������ ������
        with ordIBS.Transaction do if not InTransaction then StartTransaction;
        ordIBS.SQL.Text:= 'UPDATE ORDERSREESTR SET ORDRSTATUS='+IntToStr(orstProcessing)+
          ', ORDRTOPROCESSPerson='+IntToStr(UserId)+', ORDRTOPROCESSDATE="NOW"'+sStoreComm+
          ' WHERE ORDRCODE='+OrderCode;
        s:= RepeatExecuteIBSQL(ordIBS);
        if s<>'' then raise Exception.Create(s);

        firma.SetContUnitOrd(0); // �������� �������� unit-������
      end; // if flSendToProcessing
//-------------------------------------------------------- if flSendToProcessing
    finally
      prFreeIBSQL(ordIBS);
      cntsORD.SetFreeCnt(ordIBD);
    end;

    Stream.Clear;
//-------------------------- to CGI - begin
    if flSendToProcessing and firma.SKIPPROCESSING then begin

//      if flNewSaveAcc then begin
        // �������� ������ � ���� Grossbee � ������������ ������
        i:= fnOrderToGB(OrderID, False, True, ss, ThreadData);
        Stream.WriteInt(i);
        case i of
          aeCommonError  : Stream.WriteStr('������ ������ ���������.');
          erWareToAccount: Stream.WriteStr(ss); // ���� ������ ��� ������ �������
        end;

{      end else begin
        Stream.WriteInt(OrderID);
        Stream.WriteBool(False); // �� ��������� ��������� ��������
        prOrderToGBn_Ord(Stream, ThreadData, True); // ����� ����� ������������ ������
      end;  }
      Firma.CheckReserveLimit; // �������� ����� � ������ �/�

    end else Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
//-------------------------- to CGI - end
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, False);
  end;
  Stream.Position:= 0;
end;
//======================================== �������������� ����������� "��� ����"
procedure prEditOrderSelfComment(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prEditOrderSelfComment'; // ��� ���������/�������
      Mess1 = ' ����� ��������� �� ����� ';
      Mess2 = ' ��������';
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, i: integer;
    OrderCode, SelfComm, s: string;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    SelfComm:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csEditOrderSelfComment, UserID, FirmID, 'OrderCode='+OrderCode+ // �����������
      #13#10'ORDRSELFCOMMENT='+SelfComm);

    i:= StrToIntDef(OrderCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    i:= Length(SelfComm)-Cache.OrdSelfCommLength;
    if (i>0) then raise EBOBError.Create('������ �����������'+Mess1+
      IntToStr(Cache.OrdSelfCommLength)+Mess2+IntToStr(i));

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
// ����  �����
    OrdIBS.SQL.Text:= 'Select ORDRSTATUS, ORDRSELFCOMMENT'+
      ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
// ����� ���������, ����� �� ����� �������������
    if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming) then
      raise EBOBError.Create(MessText(mtkNotEditOrder));

    if (OrdIBS.FieldByName('ORDRSELFCOMMENT').AsString=SelfComm) then // ��� ���������
      raise EBOBError.Create(MessText(mtkNotChanges));
    OrdIBS.Close;

    OrdIBS.SQL.Text:= 'Update ORDERSREESTR set ORDRSELFCOMMENT=:ORDRSELFCOMMENT'+
      ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
    OrdIBS.ParamByName('ORDRSELFCOMMENT').AsString:= SelfComm;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//==================================== �������� ��������� ��������������� ������
procedure prShowBonusFormingOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowBonusFormingOrder'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserId, FirmID, i, spos, LineCount, contID, MainStore,
      DestID, ShipTableID, DelivType, ShipMetID, ShipTimeID, OrderID: integer;
    OrderCode, err, s, sDestName, sDestAdr, sArrive, sShipMet, sShipTime, sShipView, CurrCode: string;
    Storages: TaSD;
    Ware: TWareInfo;
    GBdirection: Boolean;
    anw: Tai;
    qty, price, ShipDate, bonFormOrd, bonAccount, bonUnitAcc: Double;
    Contract: TContract;
    firma: TFirmInfo;
    Client: TClientInfo;
begin
  Stream.Position:= 0;
  IBS:= nil;
//  OrdIBD:= nil;
  contID:= 0;
  LineCount:= 0;            // ������� - ���-�� �����
  OrderCode:= '';
  bonFormOrd:= 0; // ������ �� �������������� �������
  bonAccount:= 0; // ������ �� ������ �������
  bonUnitAcc:= 0; // ������ �� unit-������ �������
  try
//----------------------------------------------------------- read from stream +
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    GBdirection:= Stream.ReadBool;
//----------------------------------------------------------- read from stream -

    prSetThLogParams(ThreadData, csShowBonusFormingOrder, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmId];
    if firma.IsFinalClient then raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

    Client:= Cache.arClientInfo[UserID];
    CurrCode:= IntToStr(Cache.BonusCrncCode);

    IBD:= cntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      s:= 'SELECT ORDRCODE, ORDRSUMORDER, ORDRNUM, ORDRDATE, ORDRSELFCOMMENT,'+  // , ORDRACCOUNTINGTYPE
        ' ORDRDELIVERYTYPE, ORDRCREATORPERSON, ORDRSTORAGECOMMENT, ORDRDESTPOINT,'+
        ' ORDRSHIPDATE, ORDRTIMETIBLE, ORDRSHIPMETHOD, ORDRSHIPTIMEID, ORDRCONTRACT'+
        ' from ORDERSREESTR';
      IBS.SQL.Text:= s+' where ORDRFIRM='+IntToStr(FirmId)+
        ' and ORDRSTATUS='+IntToStr(orstForming)+' and ORDRCURRENCY='+CurrCode;
      IBS.ExecQuery;
      if IBS.Bof and IBS.Eof then begin // ���� ��� - ������� ����� �������� �����
        IBS.Close;
        contID:= Client.LastContract;
{
        Contract:= firma.GetContract(contID);
        if (Contract.PayType>0) then begin
          Contract:= firma.GetAvailableContract; // ����� ����������� �������� ����� (���������� ��������)
          if Assigned(Contract) then contID:= Contract.ID;
        end;
}
        prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, err, ThreadData.ID, nil, Cache.BonusCrncCode);
        if (err<>'') then raise EBOBError.Create(err);
        OrderCode:= IntToStr(OrderID);
        IBS.SQL.Text:= s+' where ORDRCODE='+OrderCode;
        IBS.ExecQuery;
      end else begin
        contID:= IBS.FieldByName('ORDRCONTRACT').AsInteger;

        if (contID>0) and not Client.CheckContract(contID) then
          raise EBOBError.Create(MessText(mtkFuncNotAvailabl));

        OrderID:= IBS.FieldByName('ORDRCODE').AsInteger;
        OrderCode:= IBS.FieldByName('ORDRCODE').AsString;
      end;
      Contract:= firma.GetContract(contID);
      MainStore:= Contract.MainStorage;

      firma.SetContUnitOrd(contID); // ��������� �������� unit-������

      DelivType:= IBS.FieldByName('ORDRDELIVERYTYPE').AsInteger;
      DestID:= IBS.FieldByName('ORDRDESTPOINT').AsInteger;
      ShipTableID:= IBS.FieldByName('ORDRTIMETIBLE').AsInteger;
      ShipDate:= IBS.FieldByName('ORDRSHIPDATE').AsDateTime;
      ShipMetID:= IBS.FieldByName('ORDRSHIPMETHOD').AsInteger;
      ShipTimeID:= IBS.FieldByName('ORDRSHIPTIMEID').AsInteger;
      err:= fnGetShipParamsView(contID, MainStore, DestID, ShipTableID, ShipDate,
            DelivType, ShipMetID, ShipTimeID, sDestName, sDestAdr, sArrive,
            sShipMet, sShipTime, sShipView, GBdirection);
      if (err<>'') then sShipView:= '';
      i:= IBS.FieldByName('ORDRCREATORPERSON').AsInteger; // �������� ��������� ������
      if (i=0) or not Cache.ClientExist(i) then s:= ''
      else s:= fnCutFIO(Cache.arClientInfo[i].Name);
      price:= IBS.FieldByName('ORDRSUMORDER').AsFloat;
//------------------------------------------------------------- save to stream +
      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteInt(contID);                               // ��� ���������
      Stream.WriteStr(Contract.Name);                        // ����� ���������
      Stream.WriteInt(OrderID);                              // ��� ������
      Stream.WriteStr(IBS.FieldByName('ORDRNUM').AsString);  // ����� ������
      Stream.WriteStr(FormatDateTime(cDateFormatY2, IBS.FieldByName('ORDRDATE').AsDateTime)); // ����
      Stream.WriteStr(FloatToStr(RoundToHalfDown(price)));       // ����� ������ = ������ �������� unit-������ (-)
      Stream.WriteInt(DelivType);                            // ��� ��������
      Stream.WriteStr(sShipView);                            // ������ ���������� ��������
      Stream.WriteStr(IBS.FieldByName('ORDRSTORAGECOMMENT').AsString); // �����������
      Stream.WriteStr(Cache.GetDprtColName(Contract.MainStorage));     // ��������� �/������
      Stream.WriteStr(Cache.GetDprtMainName(Contract.MainStorage));    // ��������� �/������
      Stream.WriteStr(IBS.FieldByName('ORDRSELFCOMMENT').AsString);    // ������ �����������
      Stream.WriteStr(IntToStr(Contract.MainStorage));                 // ��� ������

      sPos:= Stream.Position;
      Stream.WriteInt(0); //  ����� ��� ���-�� �����
//------------------------------------------------------------- save to stream -
      IBS.Close;
      IBS.SQL.Text:= 'SELECT OL.ORDRLNWARE, OL.ORDRLNCODE, OL.ORDRLNCLIENTQTY, OL.ORDRLNPRICE'+
        ' from ORDERSLINES OL where ORDRLNORDER='+OrderCode;
      IBS.ExecQuery;
      while not IBS.EOF do begin
        i:= IBS.FieldByName('ORDRLNWARE').AsInteger;
        Ware:= Cache.GetWare(i);
        if not Assigned(Ware) or (Ware=NoWare) then
          raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));

        qty:= IBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
        price:= IBS.FieldByName('ORDRLNPRICE').AsFloat;
//------------------------------------------------------------- save to stream +
        Stream.WriteInt(IBS.FieldByName('ORDRLNCODE').AsInteger);
        Stream.WriteStr(IBS.FieldByName('ORDRLNWARE').AsString);
        Stream.WriteStr(Ware.WareBrandName);
        Stream.WriteStr(Ware.Name);
        Stream.WriteDouble(qty);
        Stream.WriteStr(Ware.MeasName);
        Stream.WriteStr(FloatToStr(RoundToHalfDown(price)));
        Stream.WriteStr(FloatToStr(RoundToHalfDown(price*qty)));
//------------------------------------------------------------- save to stream -
        inc(LineCount);
        TestCssStopException;
        IBS.Next;
      end; // while not OrdIBS.EOF
//------------------------------------------------------------- save to stream +
    Stream.Position:= sPos;
    Stream.WriteInt(LineCount);
    Stream.Position:= Stream.Size;
//------------------------------------------------------------- save to stream -

//--------------------------------------------- ������ �� �������������� �������
      IBS.Close;
      IBS.SQL.Text:= 'SELECT sum(ORDRSUMORDER) summa, ORDRCURRENCY'+
        ' from ORDERSREESTR where ORDRFIRM='+IntToStr(FirmId)+
        ' and ORDRCODE<>'+OrderCode+' and ORDRCURRENCY<>'+CurrCode+
        ' and ORDRSTATUS='+IntToStr(orstForming)+' group by ORDRCURRENCY';
      IBS.ExecQuery;
      while not IBS.EOF do begin
        i:= IBS.FieldByName('ORDRCURRENCY').AsInteger;                   // ������
        price:= IBS.FieldByName('summa').AsFloat*Cache.GetPriceBonusCoeff(i); // ���-�� �������
        bonFormOrd:= bonFormOrd+price;
        TestCssStopException;
        IBS.Next;
      end; // while not OrdIBS.EOF
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;
//----------------------------------------------------- ������ �� ������ �������
    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'gbIBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'SELECT sum(rPInvSumm) summa, rPInvCrnc'+
        ' from Vlad_CSS_GetFirmReserveDocsN('+IntToStr(FirmID)+', '+'0)'+
        ' group by rPInvCrnc';
      IBS.ExecQuery;
      while not IBS.EOF do begin
        i:= IBS.FieldByName('rPInvCrnc').AsInteger;                   // ������
        price:= IBS.FieldByName('summa').AsFloat;
        if (i=Cache.BonusCrncCode) then
          bonUnitAcc:= bonUnitAcc+price  // ������ �� unit-������ �������
        else begin
          price:= price*Cache.GetPriceBonusCoeff(i); // ���-�� �������
          bonAccount:= bonAccount+price; // ������ �� ������� ������ �������
        end;
        TestCssStopException;
        IBS.Next;
      end; // while not OrdIBS.EOF
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;
    if fnNotZero(firma.BonusRes-bonUnitAcc) then try
      firma.CS_firm.Enter;
      firma.BonusRes:= bonUnitAcc;
    finally
      firma.CS_firm.Leave;
    end;

//------------------------------------------------------------- save to stream +
    Stream.WriteStr(FloatToStr(Trunc(bonFormOrd))); // ���-�� ������� �� �������������� ������� (+)
    Stream.WriteStr(FloatToStr(Trunc(bonAccount))); // ������ �� ������� ������ �������         (+)
    Stream.WriteStr(FloatToStr(Trunc(firma.BonusRes))); // ������ �� unit-������ �������            (-)
//------------------------------------------------------------- save to stream -
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(anw, 0);
  SetLength(Storages, 0);
end;
//================================================ ������ ����� ��� "����������"
procedure prGetWareActions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareActions'; // ��� ���������/�������
var i, iCount, FirmID, UserID, iPos: Integer;
    s: String;
    wa: TWareAction;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetWareActions, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    iPos:= Stream.Position;
    Stream.WriteInt(0);    // ����� ��� ���-�� �����
    iCount:= 0;
    for i:= 0 to Cache.WareActions.ItemsList.Count-1 do begin
      wa:= Cache.WareActions.ItemsList[i];
      if not wa.IsAction then Continue;
      s:= wa.Comment;
      Stream.WriteInt(wa.ID);    // ��� �����
      Stream.WriteStr(wa.Name);  // ���������
      Stream.WriteStr(s);        // �����
      Inc(iCount);
    end;
    if (iCount>0) then begin
      Stream.Position:= iPos;
      Stream.WriteInt(iCount);    // ���-�� �����
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//================================== �������� ������� �������� ������� �� ������
procedure prCheckOrderWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCheckOrderWareRests'; // ��� ���������/�������
var UserID, FirmID, WareID, DprtID, Count, i, OrderID, compDate, deliv, limit: integer;
    s, OrderCode, s1, s2, ss: string;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    Ware: TWareInfo;
    OrdQty, ShipDate: double;
    OList: TObjectList;
    flToday: Boolean;
  //---------------------------------------
  procedure AddWareName;
  begin
    ss:= ss+fnIfStr(ss='', '', '; ')+Ware.Name;
    Inc(Count);
  end;
  //---------------------------------------
  procedure SaveReportToStream;
  begin
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(s); // ����� ��������������
    Stream.Position:= 0;
  end;
  //---------------------------------------
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBS:= nil;
  OList:= nil;
  s:= '';
  ss:= '';
  DprtID:= 0;
  Count:= 0;
  limit:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    OrderID:= Stream.ReadInt;      // ��� ������
    ShipDate:= Stream.ReadDouble;  // ���� ��������
    deliv:= Stream.ReadInt;        // ��� ��������

    OrderCode:= IntToStr(OrderID);
    prSetThLogParams(ThreadData, csCheckOrderWareRests, UserID, FirmID, 'OrderCode='+OrderCode); // �����������

    if (OrderID<1) then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if (ShipDate<=DateNull) then compDate:= -1
    else compDate:= CompareDate(ShipDate, Date);
    flToday:= (compDate=0); // ���� ��������� ������� ������ �������
    s:= '';

    if not (deliv in [cDelivTimeTable, cDelivReserve, cDelivSelfGet]) then  // , cDelivClientNow
      deliv:= cDelivReserve; // ������

    //------------------------------------------------ ��������� ���� ��������
    with fnSplit(',', Cache.GetConstItem(pcAccountStorageDays).StrValue) do try  // TStringList
      if (Count>deliv) then limit:= StrToIntDef(Strings[deliv], 0);
      if (limit>0) then begin
        s1:= '��������! ����� '+Strings[deliv]+' ��. ������ ';
        s2:= ' ����� ������������.';
        case deliv of
          cDelivTimeTable: // �������� �� ����������
            if ((Date()+limit)<ShipDate) then s:= s+s1+'(��������)'+s2;
          cDelivSelfGet  : // ���������
            if ((Date()+limit)<ShipDate) then s:= s+s1+'(���������)'+s2;
          cDelivReserve  : // ������
            s:= s+s1+'(������)'+s2;
        end;
      end; // if (limit>0)
    finally
      Free;
    end;

    if (compDate<0) or not flToday then begin  // ���� <> ����������� - ������� �� ���������
      SaveReportToStream;
      Exit;
    end;

    try
      ordIBD:= CntsOrd.GetFreeCnt();
      OrdIBS:= fnCreateNewIBSQL(ordIBD,'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);
      OrdIBS.SQL.Text:= 'SELECT ORDRSTORAGE, ORDRLNWARE, ORDRLNCLIENTQTY'+
        ' FROM ORDERSREESTR left join ORDERSLINES on ORDRLNORDER=ORDRCODE'+
        ' WHERE ORDRCODE='+OrderCode;
      OrdIBS.ExecQuery;
      if (OrdIBS.EOF and OrdIBS.BOF) then
        raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

      while not OrdIBS.EOF do begin
        if (DprtID<1) then  // �� 1-� ������ ������� �����
          DprtID:= OrdIBS.FieldByName('ORDRSTORAGE').AsInteger;
        WareID:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
        if (WareID<1) then Ware:= NoWare else Ware:= Cache.GetWare(WareID, True);
        if (Ware<>NoWare) then begin
          OrdQty:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;

          OList:= Cache.GetWareRestsByStores(WareID); // �������� �������� �� ������
          try
            if (OList.Count<1) then AddWareName
            else for i:= 0 to OList.Count-1 do with TCodeAndQty(OList[i]) do
              if flToday and (ID=DprtID) and (OrdQty>Qty) then begin // ���� ����� ����� �� �������
                AddWareName;                                         // � �������� ������, ��� ����
                break;
              end;
          finally
            prFree(OList);
          end;

        end; // if (Ware<>NoWare)
        cntsORD.TestSuspendException;
        OrdIBS.Next;
      end;
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(ordIBD);
    end;

    if (Count>0) then begin
      s1:= '��������! �� ������ �������� ';
      s2:= ' ����������� ���������� �����'+fnIfStr(Count=1, '�', '��');
      if flToday then s:= s+fnIfStr(s='', '', ' ')+s1+'������� ��� � �������'+s2+' '+ss+'.';
//      s:= s+' ���������� �������� ���� ��������.';
    end;

    SaveReportToStream;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================= �������� ��������� � ���������� ������ �� ������
function GetOrderOverSummMess(currID: integer; OverSumm, OrderSum, LastLineSum: Double): String;
// ���� ����� �������� - ���������� ��������� � ����������
begin
  Result:= '';
  OrderSum:= RoundTo(OrderSum, -2);
  LastLineSum:= RoundTo(LastLineSum, -2);
  OverSumm:= OverSumm+OrderSum-LastLineSum; // ��������� ��� ����� ��������� ������ ������
  if (OverSumm>0.0099) then // ���������� - � ��������� (� ������ ��������� ������ ������)
    Result:= '����� ������ ��������� ������� ������ ������� �� '+
      FormatFloat(cFloatFormatSumm, OverSumm+LastLineSum)+' '+Cache.GetCurrName(CurrID, True);
end;
//=============== �������� ������� ������� � ������ � ������� ������ ������� �/�
function CheckOrdWaresExAndOverLimit(FirmID, UserID, ContID, OrderID, CurrID: Integer;
                                    flResLimit, flExWares, flSingleLine: Boolean; ibs: TIBSQL=nil): String;
const nmProc = 'CheckOrdWaresExAndOverLimit'; // ��� ���������/�������
var IBD: TIBDatabase;
    s: String;
    i: Integer;
    OrderSum, LineSum, Qty, LineQty, OverSumm, price: Double;
    prices: TDoubleDynArray;
    Firma: TFirmInfo;
    flCreate: Boolean;
begin
  Result:= '';
  if not flExWares and not flResLimit then Exit; // ������ ���������
  ibd:= nil;
  s:= '';
  Qty:= 0;
  OrderSum:= 0;
  LineSum:= 0;
  OverSumm:= 0;
  flCreate:= False;
  try
    Firma:= Cache.arFirmInfo[FirmID];
    flResLimit:= flResLimit and (CurrID<>Cache.BonusCrncCode); // � �������� ������� ����� �� ���������
//--------------------------------------------------- ��������� ����� ����������
    if flResLimit then begin
      s:= firma.GetOverSummAll(currID, OverSumm);
      if (s<>'') then raise EBOBError.Create(s);
      flResLimit:= (firma.ResLimit>0);   // � ������� � 1-� ������� �� ���������
      if flResLimit and not flExWares and flSingleLine then Exit;
    end;

//------------------ ��������� ������� ������� / ������� ���������� ����� ������
    if flExWares or flResLimit then try
      flCreate:= not Assigned(ibs);
      if flCreate then begin
        IBD:= cntsORD.GetFreeCnt;
        IBS:= fnCreateNewIBSQL(IBD, 'ordIBS_'+nmProc, -1, tpRead, True);
      end;
      with IBS.Transaction do if not InTransaction then StartTransaction;
      if (IBS.SQL.Text='') then IBS.SQL.Text:= 'SELECT ORDRLNWARE, ORDRLNCLIENTQTY'+
        ', ORDRLNPRICE from ORDERSLINES where ORDRLNORDER=:ord order by ORDRLNCODE';
      IBS.ParamByName('ord').AsInteger:= OrderID;
      IBS.ExecQuery;
      if (IBS.Bof and IBS.Eof) then
        if flExWares then raise EBOBError.Create('��� �������') else Exit;

      while not IBS.EOF do begin
        LineQty:= IBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
        LineSum:= 0;
        if fnNotZero(LineQty) then begin
          Qty:= Qty+LineQty;
          if flResLimit then begin
            i:= IBS.FieldByName('ORDRLNWARE').AsInteger;
            price:= Cache.GetWare(i).SellingPrice(FirmID, CurrID, contID);
            //--------------------------- ��������� ���������� ����� �� ������
            LineSum:= price*LineQty;
            OrderSum:= OrderSum+LineSum; // ������� ���������� ����� ������
          end; // if flResLimit
        end; // if fnNotZero(LineQty)
        TestCssStopException;
        IBS.Next;
      end; // while not IBS.EOF
    finally
      IBS.Close;
      if flCreate then begin
        prFreeIBSQL(IBS);
        cntsORD.SetFreeCnt(IBD);
      end;
      SetLength(prices, 0);
    end; // if flExWares or flResLimit

    if not fnNotZero(Qty) then
      if flExWares then raise EBOBError.Create('��� �������') else Exit;
    if not flResLimit then Exit; // ���������� ������ �� ���� ��������� - �������

//----------------------------------------------- ��������� ��������� ����������
    s:= GetOrderOverSummMess(currID, OverSumm, OrderSum, LineSum);
    if (s<>'') then raise EBOBError.Create(s);

  except
    on E: EBOBError do Result:= E.Message;
    on E: Exception do begin
      prMessageLOGS(nmProc+': '+E.Message);
      Result:= MessText(mtkErrProcess);
    end;
  end;
end;
//============================================= �������� ������ ������ �� ������
procedure prGetBankAccountsList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBankAccountsList'; // ��� ���������/�������
var UserID, FirmID, iCount, pos: integer;
    s, sFirm, sNum, sPname: string;
    IBD: TIBDatabase;
    IBS: TIBSQL;
    fl: Boolean;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetBankAccountsList, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    sFirm:= Cache.arFirmInfo[FirmID].UPPERSHORTNAME;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    iCount:= 0;
    pos:= Stream.Position;
    Stream.WriteInt(iCount); //----- �������� ���-�� ������
    try
      IBD:= CntsGRB.GetFreeCnt();                      //
      IBS:= fnCreateNewIBSQL(IBD,'IBS_'+nmProc, ThreadData.ID, tpRead, true);
      IBS.SQL.Text:= 'SELECT BKATCODE, BKATNUMBER, BKATSUMM, cs.RHaveDuplicate,'+
        ' iif(BKATPERSONCODE is null, BKATPERSONNAME, p.prsnname) pname,'+
        ' iif(BKATPERSONPHONECODE is null, bkatpersonphone, pphphone) phone,'+
        ' gn.rNum contnumber FROM bankaccountreestr'+
        ' left join persons p on p.prsncode=BKATPERSONCODE'+
        ' left join personphones on pphcode=BKATPERSONPHONECODE'+
        ' left join contract on contcode=BKATCONTRACTCODE'+
        ' left join Vlad_CSS_GetFullContNum(contnumber, contnkeyyear, contpaytype) gn on 1=1'+
        ' left join SENDSMSFROMBANKACCOUNT(BKATCODE, 2) cs on 1=1'+ // 2- check insert
        ' WHERE BKATFIRMCODE='+IntToStr(FirmID)+
        '   and bkatdate>="today" and BKATPAYMENTCODE is null and BKATSUMM>0';
      IBS.ExecQuery;
      while not IBS.EOF do begin
        sNum:= IBS.FieldByName('BKATNUMBER').AsString;
        s:= IBS.FieldByName('phone').AsString;
        fl:= GetBoolGB(ibs, 'RHaveDuplicate') or (s='') or not CheckMobileNumber(s);

        Stream.WriteInt(IBS.FieldByName('BKATCODE').AsInteger);  //----- �������� ��� �����
        Stream.WriteStr(IBS.FieldByName('contnumber').AsString); //----- �������� ��������
        Stream.WriteStr(sNum);                                   //----- �������� � �����
        Stream.WriteDouble(IBS.FieldByName('BKATSUMM').AsFloat); //----- �������� �����
        sPname:= fnReplaceQuotedForWeb(IBS.FieldByName('pname').AsString); // ��������� ������� ' � " � `
        Stream.WriteStr(sPname);      //----- �������� ����.����
        Stream.WriteStr('����: '+sNum+', ��� �������: '+sFirm);  //----- �������� ��������� ��� �� ����������
        Stream.WriteBool(fl);                                    //----- �������� ������� ������� �������� SMS

        inc(iCount);
        CntsGRB.TestSuspendException;
        IBS.Next;
      end;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;
    if (iCount>0) then begin
      Stream.Position:= pos;
      Stream.WriteInt(iCount); // ���-�� ������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================================ ������������ ����� ���� �� ������
procedure prNewBankAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prNewBankAccount'; // ��� ���������/�������
var UserID, FirmID, ii, iCount, i, j, pos: integer;
    s, sCliCodes: string;
    IBD: TIBDatabase;
    IBS: TIBSQL;
    sum: double;
    Contract: TContract;
    Client: TClientInfo;
    firma: TFirmInfo;
    arLimits: TDoubleDynArray;
    lstCliCodes: TIntegerList;
//    lst: TStringList;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  SetLength(arLimits, 0);
  lstCliCodes:= TIntegerList.Create;
//  lst:= TStringList.Create;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csNewBankAccount, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmID];
    Client:= Cache.arClientInfo[UserID];

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    //----------------------------------------- ��������� ��������� ������������
    iCount:= 0;
    pos:= Stream.Position;
    Stream.WriteInt(iCount);          //----- �������� ���-�� ����������
    for i:= 0 to Client.CliContracts.Count-1 do begin
      ii:= Client.CliContracts[i];
      if not Cache.Contracts.ItemExists(ii) then Continue;

      Contract:= Cache.Contracts[ii];
      if (Contract.Status<cstBlocked) then Continue; // �������� ����������   ???
      if (Contract.PayType>0) then Continue;         // ������ ����������

      Stream.WriteInt(Contract.ID);   //----- �������� ��� ���������
      Stream.WriteStr(Contract.Name); //----- �������� � ���������
      inc(iCount);
    end;
    if (iCount>0) then begin
      Stream.Position:= pos;
      Stream.WriteInt(iCount);
      Stream.Position:= Stream.Size;
    end else raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));

    //------------------------------------------------------ ��������� ����.����
    sCliCodes:= ''; // ������ � ������ �������� ��� SQL (��� Cache.flCheckCliBankLim=True)
    for i:= 0 to High(Firma.FirmClients) do begin
      ii:= Firma.FirmClients[i];
      if not Cache.ClientExist(ii) then Continue;

      Client:= Cache.arClientInfo[ii];
      if Client.Arhived then Continue;             // �������� ����������
//      if (Client.CliMails.Count<1) then Continue;  // ��� Email-�� ����������
//      if (Client.CliPhones.Count<1) then Continue; // ��� ��������� ����������
//      s:= CheckClientFIO(Client.Name); // �������� ������������ ��� ��������
//      if s<>'' then Continue;

      if not Client.CliPay then Continue; // �������� ����.������

      lstCliCodes.Add(ii);
      if Cache.flCheckCliBankLim then
        sCliCodes:= sCliCodes+fnIfStr(sCliCodes='', '', ', ')+IntToStr(ii);
    end;
    if (lstCliCodes.Count<1) then
      raise EBOBError.Create('�� ������� ���������� ���� ��� ���������');

    //------------- ��������� ��������� ����� ������ (� �������� ������ � �����)
    SetLength(arLimits, lstCliCodes.Count); // ������ ��������� ���� ��������
    try
      IBD:= CntsGRB.GetFreeCnt();
      IBS:= fnCreateNewIBSQL(IBD,'IBS_'+nmProc, ThreadData.ID, tpRead, true);

      if Cache.flCheckCliBankLim then begin //----- �������� ������ �� ����.����
        for i:= 0 to High(arLimits) do
          arLimits[i]:= Cache.BankLimitSumm; // ������� ����������� ���� ����� �����
        IBS.SQL.Text:= 'select sum(BKATSUMM) summa, BKATPERSONCODE'+
          ' from bankaccountreestr where bkatdate="today"'+
          '   and BKATPERSONCODE in ('+sCliCodes+') group by BKATPERSONCODE';
        IBS.ExecQuery; // ��������� ����� ��� ������������ ������ ��������
        while not IBS.EOF do begin
          ii:= IBS.FieldByName('BKATPERSONCODE').AsInteger;
          sum:= IBS.FieldByName('summa').AsFloat;
          j:= -1; // ���� ������ ������� � ������
          for i:= 0 to lstCliCodes.Count-1 do if (lstCliCodes[i]=ii) then begin
            j:= i;
            break;
          end;
          if (j>-1) then begin             // ����� ������ ������� -
            arLimits[j]:= arLimits[j]-sum; // ������������ ��� ��������� �����
            if (arLimits[j]<0) then arLimits[j]:= 0;
          end;
          TestCssStopException;
          IBS.Next;
        end;

      end else begin                       //------------ �������� ������ �� �/�
        sum:= Cache.BankLimitSumm; // ����� �����
        IBS.SQL.Text:= 'select sum(BKATSUMM) summa from bankaccountreestr'+
          ' where bkatdate="today" and BKATFIRMCODE='+IntToStr(FirmID);
        IBS.ExecQuery;             // �������� ����� ��� ������������ ������ �/�
        if not (IBS.EOF and IBS.BOF) then sum:= sum-IBS.FieldByName('summa').AsFloat;
        if (sum<0.01) then raise EBOBError.Create('�������� ����� ����� ������ �� �����'); // ???
        for i:= 0 to High(arLimits) do arLimits[i]:= sum; // ���� ����������� ��������� ����� �/�
      end;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;

    Stream.WriteInt(lstCliCodes.Count); //----- �������� ���-�� ����.���
    for i:= 0 to lstCliCodes.Count-1 do begin
      Client:= Cache.arClientInfo[lstCliCodes[i]];
      Stream.WriteInt(Client.ID);       //----- �������� ��� ����.����
      Stream.WriteStr(Client.Name);     //----- �������� ��� ����.����
      Stream.WriteDouble(arLimits[i]);  //----- �������� ��������� ����� ��� ����.����
{
      lst.Clear;
      for ii:= 0 to Client.CliPhones.Count-1 do
//        if CheckMobileNumber(trim(Client.CliPhones[ii])) then // ��������� �������� ����.���� ???
        lst.Add(Client.CliPhones[ii]);
      Stream.WriteInt(lst.Count);              //----- �������� ���-�� ��������� ����.����
      for ii:= 0 to lst.Count-1 do
        Stream.WriteStr(lst[ii]);              //----- �������� �������� ����.����
}
      Stream.WriteInt(Client.CliPhones.Count); //----- �������� ���-�� ��������� ����.����
      for ii:= 0 to Client.CliPhones.Count-1 do
        Stream.WriteStr(Client.CliPhones[ii]); //----- �������� �������� ����.����

      Stream.WriteInt(Client.CliMails.Count);  //----- �������� ���-�� Email-�� ����.����
      for ii:= 0 to Client.CliMails.Count-1 do
        Stream.WriteStr(Client.CliMails[ii]);  //----- �������� Email-� ����.����
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(arLimits, 0);
  prFree(lstCliCodes);
//  prFree(lst);
  Stream.Position:= 0;
end;
//====================================================== �������� ���� �� ������
procedure prSaveBankAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveBankAccount'; // ��� ���������/�������
var UserID, FirmID, ContID, persID, bkat, TryCount: integer;
    s, phone, email, sFirmID, sContID, sPersID, sNum: string;
    IBD: TIBDatabase;
    IBS: TIBSQL;
    AvailSum, AccSum: double;
    Contract: TContract;
    Client: TClientInfo;
    firma: TFirmInfo;
    flPhone, flEmail, fl: Boolean;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt;    // ��� ���������
    persID:= Stream.ReadInt;    // ��� ����.����
    phone := Stream.ReadStr;    // �������
    email := Stream.ReadStr;    // Email
    AccSum:= Stream.ReadDouble; // �����

    sFirmID:= IntToStr(FirmID);
    sContID:= IntToStr(ContID);
    sPersID:= IntToStr(persID);
    flPhone:= (trim(phone)<>'');
    flEmail:= (trim(email)<>'');

    prSetThLogParams(ThreadData, csSaveBankAccount, UserID, FirmID,
      'ContID='+sContID+#13#10'person='+sPersID+#13#10'phone='+phone+
      #13#10'email='+email+#13#10'AccSum='+FloatToStr(AccSum)); // �����������

    if (AccSum<0.01) then raise EBOBError.Create('�� ������ �����');

    if (AccSum<Cache.BankMinSumm) then // 26.10.2016 - ������ �������
      raise EBOBError.Create('����������� ����� ������ '+
        FormatFloat(cFloatFormatSumm, Cache.BankMinSumm)+' ���.');

    if not flPhone then raise EBOBError.Create('�� ����� ����� ��������');
    if flPhone and not CheckMobileNumber(trim(phone)) then
      raise EBOBError.Create('����� �������� '+phone+' �� ���������');
//    if not flEmail then raise EBOBError.Create('�� ����� E-mail');    // ???
//    if flEmail and not fnCheckEmail(trim(email)) then
//      raise EBOBError.Create('������������ E-mail - '+email);

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
//    if CheckNotValidUser(persID, FirmID, s) then raise EBOBError.Create(s); // ??? Blocked
    if not Cache.ClientExist(persID) then
      raise EBOBError.Create(MessText(mtkNotClientExist));

    Client:= Cache.arClientInfo[persID];
    if Client.Arhived then raise EBOBError.Create(MessText(mtkNotClientExist));
    if (Client.FirmID<>FirmID) then raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    if flPhone and (Client.CliPhones.IndexOf(phone)<0) then    // ???
      raise EBOBError.Create('�� ������ ����� �������� ����.���� '+phone);
//    if flEmail and (Client.CliMails.IndexOf(email)<0) then     // ???
//      raise EBOBError.Create('�� ������ E-mail ����.���� '+email);

    firma:= Cache.arFirmInfo[FirmID]; // �������� ��������� � �/� !!!
    if not firma.CheckContract(ContID)then
      raise EBOBError.Create(MessText(mtkNotFoundFirmCont, sContID));

    Contract:= Cache.Contracts[ContID];
    if (Contract.Status<cstBlocked) then raise EBOBError.Create('�������� ������');
    if (Contract.PayType>0) then raise EBOBError.Create('�������� �����������');

    //------------- ��������� ��������� ����� ������ (� �������� ������ � �����)
    AvailSum:= Cache.BankLimitSumm; // ����� �����
    s:= '';
    bkat:= 0;
    try
      IBD:= CntsGRB.GetFreeCnt();
      IBS:= fnCreateNewIBSQL(IBD,'IBS_'+nmProc, ThreadData.ID, tpRead, true);
      IBS.SQL.Text:= 'select sum(BKATSUMM) summa from bankaccountreestr'+
        ' where bkatdate="today" and '+fnIfStr(Cache.flCheckCliBankLim,
        'BKATPERSONCODE='+sPersID, 'BKATFIRMCODE='+sFirmID); // �� ����.���� ��� �� �/�
      IBS.ExecQuery;
      if not (IBS.EOF and IBS.BOF) then // �������� ����� ��� ������������ ������
        AvailSum:= AvailSum-IBS.FieldByName('summa').AsFloat;
      IBS.Close;
      if (AvailSum<0.01) then
        raise EBOBError.Create('�������� ����� ����� ������ �� �����');
      if (AccSum>AvailSum) then
        raise EBOBError.Create('�������� ����� ����� ������ �� �����,'+
          ' �������� '+FloatToStr(AvailSum)+' ���');

      fnSetTransParams(ibs.Transaction, tpWrite, True);
      IBS.SQL.Text:= 'insert into bankaccountreestr (BKATFIRMCODE, BKATNUMBER,'+
        ' BKATCONTRACTCODE, BKATHOUR, BKATSUMM, BKATCRNCCODE, BKATPERSONCODE'+
        fnIfStr(flPhone, ', BKATPERSONPHONECODE', '')+
        fnIfStr(flEmail, ', BKATPERSONEMAILCODE', '')+', BKATFIRSTPARTY) values ('+sFirmID+
        ', "< ���� >",'+sContID+', EXTRACT(HOUR FROM CURRENT_TIMESTAMP), :sum, 1, '+sPersID+
        fnIfStr(flPhone, ', (select first 1 pphcode from personphones where'+
          ' PPHPersonCode='+sPersID+' and pphphone=:phone and ppharchivedkey="F")', '')+
        fnIfStr(flEmail, ', (select first 1 pecode from personemails where'+
          ' PEPERSONCODE='+sPersID+' and peemail=:email and pearchivedkey="F")', '')+
        ', (select userfirmcode from userpsevdonimreestr where usercode=1)'+
        ') returning BKATCODE, BKATNUMBER, BKATSUMM, BKATPERSONPHONECODE';  //, BKATPERSONEMAILCODE ???
      IBS.ParamByName('sum').AsFloat:= AccSum;
      if flPhone then IBS.ParamByName('phone').AsString:= phone;
      if flEmail then IBS.ParamByName('email').AsString:= email;

      for TryCount:= 1 to RepeatCount do try // RepeatCount �������
        Application.ProcessMessages;
        with ibs.Transaction do if not InTransaction then StartTransaction;
        ibs.ExecQuery;
        if flPhone and ibs.FieldByName('BKATPERSONPHONECODE').IsNull then    // ???
          raise EBOBError.Create('�� ������ ����� �������� '+phone);
  //      if flEmail and ibs.FieldByName('BKATPERSONEMAILCODE').IsNull then    // ???
  //        raise EBOBError.Create('�� ������ E-mail '+email);
        bkat:= IBS.FieldByName('BKATCODE').AsInteger;
        sNum:= ibs.FieldByName('BKATNUMBER').AsString;
        AccSum:= ibs.FieldByName('BKATSUMM').AsFloat;
        ibs.Transaction.Commit;
        break;
      except
        on E: EBOBError do raise EBOBError.Create(E.Message);
        on E: Exception do begin
          with ibs.Transaction do if InTransaction then RollbackRetaining;
          if (Pos('lock', E.Message)>0) and (TryCount<RepeatCount) then
            Sleep(RepeatSaveInterval) // ���� deadlock, �� ���� �������
          else raise Exception.Create(E.Message);
        end;
      end;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;
    s:= '����: '+sNum+', ��� �������: '+firma.UPPERSHORTNAME;
    fl:= not CheckMobileNumber(trim(phone));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    Stream.WriteInt(bkat);          //----- �������� ��� �����
    Stream.WriteStr(Contract.Name); //----- �������� ��������
    Stream.WriteStr(sNum);          //----- �������� � �����
    Stream.WriteDouble(AccSum);     //----- �������� �����
    Stream.WriteStr(Client.Name);   //----- �������� ����.����
    Stream.WriteStr(s);             //----- �������� ��������� ��� �� ����������
    Stream.WriteBool(fl);           //----- �������� ������� ������� �������� SMS

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;
//================================================ �������� ���� ����� �� ������
procedure prGetBankAccountFile(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBankAccountFile'; // ��� ���������/�������
var UserID, FirmID, i, baccID: integer;
    ss, sNum, s, sPers, sDate, sSum, sSum0, sNds, nf, nfOut, sumstr, sShort: string;
    IBD: TIBDatabase;
    IBS: TIBSQL;
    sum, nds: Double;
    lst: TStringList;
    firma: TFirmInfo;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  lst:= TStringList.Create;
  sum:= 0;
  nds:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    baccID:= Stream.ReadInt; // ��� �����

    prSetThLogParams(ThreadData, csGetBankAccountFile, UserID, FirmID, 'baccID='+IntToStr(baccID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    firma:= Cache.arFirmInfo[FirmID];

    nf:= GetAppExePath+fnTestDirEnd(cShablonDir)+cShablon_bkat_xml; // ���� ������� �����
    if not FileExists(nf) then raise EBOBError.Create('�� ������ ����-������ �����');

    try
      IBD:= CntsGRB.GetFreeCnt();
      IBS:= fnCreateNewIBSQL(IBD,'IBS_'+nmProc, ThreadData.ID, tpRead, true);
      IBS.SQL.Text:= 'SELECT BKATNUMBER, BKATDATE, BKATSUMM, SummOfNDS(BKATSUMM, 20,"0") nds,'+  //
        ' iif(BKATPERSONCODE is null, BKATPERSONNAME, p.prsnname) pname'+
        ' FROM bankaccountreestr left join persons p on p.prsncode=BKATPERSONCODE'+
        ' WHERE BKATCODE='+IntToStr(baccID)+' and BKATFIRMCODE='+IntToStr(FirmID);
      IBS.ExecQuery;
      if (IBS.EOF and IBS.BOF) then raise EBOBError.Create('�� ������ ����');
      sNum:= IBS.FieldByName('BKATNUMBER').AsString; // � �����
      sPers:= IBS.FieldByName('pname').AsString;     // ����������
      sDate:= FormatDateTime(cDateFormatY4, IBS.FieldByName('BKATDATE').AsDateTime); // ������ ����
      sum:= IBS.FieldByName('BKATSUMM').AsFloat;     // �����
      nds:= IBS.FieldByName('nds').AsFloat;          // ���
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;
    sSum:= FormatFloat(cFloatFormatSumm, sum);      // ������ �����
    sNds:= FormatFloat(cFloatFormatSumm, nds);      // ������ ���
    sSum0:= FormatFloat(cFloatFormatSumm, sum-nds); // ������ ����� �/���
    sumstr:= SumNumToFullUkr(sum);            // ����� ��������
    sShort:= firma.UPPERSHORTNAME;            // ��� �/�

    nfOut:= 'bkat_'+sNum+'_'+FormatDateTime('ddmmyyhhnnss', Now)+'.xml';
    try
      Cache.CScache.Enter;
      try
        lst.LoadFromFile(nf, TEncoding.UTF8);
      finally
        Cache.CScache.Leave;
      end;

      for i:= 0 to lst.Count-1 do begin
        ss:= lst[i];
        if (pos('@@', lst[i])>0) then begin
          if (pos('@@number@@', ss)>0) then
            ss:= StringReplace(ss, '@@number@@', sNum, [rfReplaceAll]);
          if (pos('@@date@@', ss)>0) then
            ss:= StringReplace(ss, '@@date@@',   sDate, [rfReplaceAll]);
          if (pos('@@person@@', ss)>0) then
            ss:= StringReplace(ss, '@@person@@', sPers, [rfReplaceAll]);
          if (pos('@@short@@', ss)>0) then
            ss:= StringReplace(ss, '@@short@@',  sShort, [rfReplaceAll]);
          if (pos('@@sum@@', ss)>0) then
            ss:= StringReplace(ss, '@@sum@@',    sSum0, [rfReplaceAll]);
          if (pos('@@nds@@', ss)>0) then
            ss:= StringReplace(ss, '@@nds@@',    sNds, [rfReplaceAll]);
          if (pos('@@sumall@@', ss)>0) then
            ss:= StringReplace(ss, '@@sumall@@', sSum, [rfReplaceAll]);
          if (pos('@@sumstr@@', ss)>0) then
            ss:= StringReplace(ss, '@@sumstr@@', sumstr, [rfReplaceAll]);
        end;
        lst[i]:= AnsiToUTF8(ss);
      end;

      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteStr(XMLContentType);
      Stream.WriteStr(nfOut);
      Stream.WriteLongStr(lst.Text);
    finally
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(lst);
  Stream.Position:= 0;
end;
//============================================= ��������� SMS �� ����� �� ������
procedure prSendSMSfromBankAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendSMSfromBankAccount'; // ��� ���������/�������
var UserID, FirmID, baccID: integer;
    sDup, s: string;
    IBD: TIBDatabase;
    IBS: TIBSQL;
begin
  Stream.Position:= 0;
//  IBD:= nil;
  IBS:= nil;
  try
    UserID:= Stream.ReadInt;               // 3854562
    FirmID:= Stream.ReadInt;               // 32751
    baccID:= Stream.ReadInt; // ��� �����  // 284288

    prSetThLogParams(ThreadData, csSendSMSfromBankAccount, UserID, FirmID, 'baccID='+IntToStr(baccID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    IBD:= CntsGRB.GetFreeCnt();
    try
      IBS:= fnCreateNewIBSQL(IBD,'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
      IBS.ParamCheck:= False;
      IBS.SQL.Add('execute block returns (rDup varchar(1))');
      IBS.SQL.Add('as declare variable firmID integer='+IntToStr(FirmID)+';');
      IBS.SQL.Add(' declare variable baccID integer='+IntToStr(baccID)+';');
      IBS.SQL.Add('begin rDup=""; if (exists(select * from bankaccountreestr');
      IBS.SQL.Add(' WHERE BKATCODE=:baccID and BKATFIRMCODE=:firmID)) then begin'); // �������� ��������
      IBS.SQL.Add(' select iif((select RConvertedNumber from PhoneNumberConverter(Phone))="", "N",'); // �� ������������
      IBS.SQL.Add('  iif((select RResult from TestMobilePhone(Phone))="F", "M", "")) from');          // �� �����������
      IBS.SQL.Add('   (select iif(BKATPERSONPHONECODE is null, bkatpersonphone, pphphone) phone');
      IBS.SQL.Add('   from bankaccountreestr left join personphones on pphcode=BKATPERSONPHONECODE');
      IBS.SQL.Add('   WHERE BKATCODE=:baccID and BKATFIRMCODE=:firmID) into rDup;');
      IBS.SQL.Add(' if (rDup<>"") then begin suspend; exit; end');
      IBS.SQL.Add(' SELECT RHaveDuplicate from SENDSMSFROMBANKACCOUNT(:baccID, 2) into rDup;');
      IBS.SQL.Add(' if (rDup<>"T") then SELECT RHaveDuplicate -- 2- check insert, 0- insert');
      IBS.SQL.Add('  from SENDSMSFROMBANKACCOUNT(:baccID, 0) into rDup; end suspend; end');
      IBS.ExecQuery;
      if (IBS.EOF and IBS.BOF) then raise EBOBError.Create('�� ������ ����');
      sDup:= IBS.FieldByName('rDup').AsString; // ���������
      if (sDup='') then raise EBOBError.Create('�� ������ ����');
      if (sDup='N') then raise EBOBError.Create('����� �������� ������������');
      if (sDup='M') then raise EBOBError.Create('����� �������� �� ���������');
      if (sDup='T') then raise EBOBError.Create('SMS ��������� � ������� �� ����� ��� ����������');
      IBS.Transaction.Commit;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================= ��������� ������ � ������������ ����� � Grossbee
function prSendMessAboutCreateAccount(ORDRCODE, DCACCODE, FirmID,
         contID, storID, crnc, IDq: Integer; SumDoc, SumLines: Double;
         DCACNUMBER, ORDRNUM, sDate, ErrStr: string; accLines: TStringList): string;
const nmProc = 'prSendMessAboutCreateAccount'; // ��� ���������/�������
var i, j, FilID: integer;
    s, ss1, ss2, AccCode, attFile, SysAdr, sacc: string;
    Strings, Attachments: TStringList;
    arDprts: Tai;
    firma: TFirmInfo;
    Contract: TContract;
begin
  Result:= '';
  Strings:= nil;
  Attachments:= nil;
  setLength(arDprts, 0);
//  if flDebug and (ErrStr='') then ErrStr:= 'test/mail';
  with Cache do try try
    if not FirmExist(FirmID) then raise Exception.Create('Not correct FirmID');
    firma:= arFirmInfo[FirmID];

    Strings:= TStringList.Create;
    AccCode:= IntToStr(DCACCODE);
    attFile:= DirFileErr+'c'+ORDRNUM+'n'+DCACNUMBER+'.txt'; // ��� ����� ����� �����
    if CurrExists(crnc) then s:= ' '+GetCurrName(crnc, True) else s:= '';
    sacc:= ' N '+DCACNUMBER+' �� '+sDate;
    if (ErrStr>'') then ss2:= '������ ������ �����'+sacc else ss2:= '������ ����'+sacc;

    Strings.Clear;
    Strings.Add('�������� ��������������� ������ �������');
    Strings.Add('��� ����������� '+firma.Name);
    Strings.Add('������ ����'+sacc+' �� ����� '+FormatFloat(cFloatFormatSumm, SumDoc)+s);
    if ORDRNUM<>'' then Strings.Add('( �� ������ ��� N '+ORDRNUM+' )');
    // ��������� ����� �����
    if (abs(SumDoc-SumLines)>0.03) then begin // ������� � ��� ���������� �����
      prMessageLOGS('---------- ������������ ���� N '+DCACNUMBER+' �� '+sDate, 'err_acc', false);
      prMessageLOGS('           ����������= '+firma.Name, 'err_acc', false);
      prMessageLOGS('   ����� � �������= '+FormatFloat(cFloatFormatSumm, SumDoc)+
        ', ����� �� �������= '+FormatFloat(cFloatFormatSumm, SumLines)+' ('+s+')', 'err_acc', false);
    end;

    FilID:= 0;
    if DprtExist(storID) then with arDprtInfo[storID] do begin  // ����� ��������������
      FilID:= FilialID; // ������ ��������������
      Strings.Add(' ����� ��������������: '+MainName);
    end;
    with firma do if (FilID>0) then begin
      Contract:= GetContract(contID);
      j:= 1;
      setLength(arDprts, j);
      arDprts[0]:= FilID; // ������ ��������������
      for i:= 0 to High(Contract.ContProcDprts) do begin // ���������� ���.������� ��������� ������
        storID:= Contract.ContProcDprts[i];
        if not DprtExist(storID) then Continue;
        FilID:= arDprtInfo[storID].FilialID;
        if (fnInIntArray(FilID, arDprts)>-1) then Continue;
        setLength(arDprts, j+1);
        arDprts[j]:= FilID;
        inc(j);
      end;
    end;
    for i:= High(arDprts) downto 0 do begin // ��������� ������� ��������� ������
      FilID:= arDprts[i];
      if DprtExist(FilID) then with arDprtInfo[FilID] do // ������ - ���������� ������ ������ � ������ � ��������
        if IsFilial and IsFilOnlyErr and (ErrStr='') then prDelItemFromArray(i, arDprts);
    end;

    if (Length(arDprts)<1) then Exit; // ���� ������ ���������� - �������

    if (ErrStr>'') then Strings.Add(ErrStr); // ������ ������ �������

    if (accLines.Count>0) then try
      s:= fnMakeAddCharStr('���� N '+DCACNUMBER+': �����', 40, True)+
        fnMakeAddCharStr('�����', 10)+fnMakeAddCharStr('����', 10);
      accLines.Insert(0, s);
      accLines.Insert(1, '');
      fnStringsLogToFile(accLines, attFile);
      Attachments:= TStringList.Create;
      Attachments.Add(attFile);
    except
      if Assigned(Attachments) then Attachments.Clear;
    end;

    SysAdr:= fnGetSysAdresVlad(caeOnlyWorkTime); // ����� ��� ������ � ������ ����
    for i:= 0 to High(arDprts) do begin // ��������� �� �������� ��������� ������
      FilID:= arDprts[i];
      ss1:= fnGetManagerMail(FilID, SysAdr); // �������� ������ � �������� �����
      s:= n_SysMailSend(ss1, ss2+' ('+fnGetComputerName+', create account)', Strings, Attachments, '', '', true);
      if s<>'' then Result:= '������ �������� ������: '+#13#10+ss2+#13#10+s;
    end;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
  finally
    prFree(Strings);
    if Assigned(Attachments) and FileExists(attFile) then DeleteFile(attFile);
    prFree(Attachments);
    setLength(arDprts, 0);
  end;
end;
//============================= ��������� ������ � ������������ ����� � Grossbee
function prSendMessAboutCreateAccount(Ord: ROrderOpts; IDq: Integer; ErrStr: string): string;
const nmProc = 'prSendMessAboutCreateAccount'; // ��� ���������/�������
var i, j, FilID, storID: integer;
    s, ss1, ss2,  attFile, SysAdr: string;
    Strings, Attachments: TStringList;
    arDprts: Tai;
begin
  Result:= '';
  Strings:= nil;
  Attachments:= nil;
  setLength(arDprts, 0);
  with Cache do try try
//    if not FirmExist(Ord.Firma.ID) then raise Exception.Create('Not correct FirmID');
    Strings:= TStringList.Create;
    if (ord.accSing.ID>0) then ss1:= ord.accSing.Num
    else if (ord.accJoin.ID>0) then ss1:= ord.accJoin.Num
    else ss1:= '';
    attFile:= DirFileErr+'c'+Ord.ORDRNUM+'n'+ss1+'.txt'; // ��� ����� ����� �����
    if CurrExists(Ord.currID) then s:= ' '+GetCurrName(Ord.currID, True) else s:= '';

    Strings.Clear;
    Strings.Add('�������� ��������������� ������ �������');
    Strings.Add('��� ����������� '+Ord.firma.Name);
    if (Ord.ORDRNUM<>'') then Strings.Add('   �� ������ ��� N '+Ord.ORDRNUM);
    Strings.Add('');

    ss2:= '';
    if (ord.accJoin.ID>0) then begin
      ss2:= ord.accJoin.Num;
      Strings.Add('��������� ������ � ���� '+ord.accJoin.Num+' �� '+ord.accJoin.sDate+
                  ' �� ����� '+FormatFloat(cFloatFormatSumm, ord.accJoin.sumlines)+s);
    end;
    if (ord.accSing.ID>0) then begin
      ss2:= ss2+fnIfStr(ss2='', '', ', ')+ord.accSing.Num;
      Strings.Add('������ ���� '+ord.accSing.Num+' �� '+ord.accSing.sDate+
                  ' �� ����� '+FormatFloat(cFloatFormatSumm, ord.accSing.AccSumm)+s);
    end;
    if (ErrStr>'') then ss2:= '������ ��� ������������ �����: '+ss2
    else ss2:= '��������� ������ � ����: '+ss2;

    // ��������� ����� �����                 // ������� � ��� ���������� �����
    if (ord.accSing.ID>0) and (abs(ord.accSing.AccSumm-ord.accSing.SumLines)>0.03) then begin
      prMessageLOGS('---------- ������������ ���� N '+ord.accSing.Num+' �� '+ord.accSing.sDate, 'err_acc', false);
      prMessageLOGS('           ����������= '+Ord.firma.Name, 'err_acc', false);
      prMessageLOGS('   ����� � �������= '+FormatFloat(cFloatFormatSumm, ord.accSing.AccSumm)+
        ', ����� �� �������= '+FormatFloat(cFloatFormatSumm, ord.accSing.SumLines)+' ('+s+')', 'err_acc', false);
    end;

    FilID:= 0;
    if DprtExist(Ord.DprtID) then with arDprtInfo[Ord.DprtID] do begin  // ����� ��������������
      FilID:= FilialID; // ������ ��������������
      Strings.Add('');
      Strings.Add(' ����� ��������������: '+MainName);
    end;
    with Ord.firma do if (FilID>0) then begin
      j:= 1;
      setLength(arDprts, j);
      arDprts[0]:= FilID; // ������ ��������������
      for i:= 0 to High(Ord.Contract.ContProcDprts) do begin // ���������� ���.������� ��������� ������
        storID:= Ord.Contract.ContProcDprts[i];
        if not DprtExist(storID) then Continue;
        FilID:= arDprtInfo[storID].FilialID;
        if (fnInIntArray(FilID, arDprts)>-1) then Continue;
        setLength(arDprts, j+1);
        arDprts[j]:= FilID;
        inc(j);
      end;
    end;
    for i:= High(arDprts) downto 0 do begin // ��������� ������� ��������� ������
      FilID:= arDprts[i];
      if DprtExist(FilID) then with arDprtInfo[FilID] do // ������ - ���������� ������ ������ � ������ � ��������
        if IsFilial and IsFilOnlyErr and (ErrStr='') then prDelItemFromArray(i, arDprts);
    end;

    if (Length(arDprts)<1) then Exit; // ���� ������ ���������� - �������

    if (ErrStr>'') then begin
      Strings.Add('');
      Strings.Add(ErrStr); // ������ ��� ������������ �����
    end;

    try
      if (ord.accJoin.accLines.Count>0) then begin
        s:= fnMakeAddCharStr('���� N '+ord.accJoin.Num+': �����', 40, True)+
          fnMakeAddCharStr('�����', 10)+fnMakeAddCharStr('����', 10);
        ord.accJoin.accLines.Insert(0, s);
        ord.accJoin.accLines.Insert(1, '');
      end;
      if (ord.accSing.accLines.Count>0) then begin
        s:= fnMakeAddCharStr('���� N '+ord.accSing.Num+': �����', 40, True)+
          fnMakeAddCharStr('�����', 10)+fnMakeAddCharStr('����', 10);
        if (ord.accJoin.accLines.Count>0) then ord.accJoin.accLines.Add('');
        ord.accJoin.accLines.Add(s);
        ord.accJoin.accLines.Add('');
        for i:= 0 to ord.accSing.accLines.Count-1 do
          ord.accJoin.accLines.Add(ord.accSing.accLines[i]);
      end;
      fnStringsLogToFile(ord.accJoin.accLines, attFile);
      Attachments:= TStringList.Create;
      Attachments.Add(attFile);
    except
      if Assigned(Attachments) then Attachments.Clear;
    end;

    SysAdr:= fnGetSysAdresVlad(caeOnlyWorkTime); // ����� ��� ������ � ������ ����
    for i:= 0 to High(arDprts) do begin // ��������� �� �������� ��������� ������
      FilID:= arDprts[i];
      ss1:= fnGetManagerMail(FilID, SysAdr); // �������� ������ � �������� �����
      s:= n_SysMailSend(ss1, ss2+' ('+fnGetComputerName+', create account)', Strings, Attachments, '', '', true);
      if s<>'' then Result:= '������ �������� ������: '+#13#10+ss2+#13#10+s;
    end;
  except
    on E: Exception do Result:= nmProc+': '+E.Message;
  end;
  finally
    prFree(Strings);
    if Assigned(Attachments) and FileExists(attFile) then DeleteFile(attFile);
    prFree(Attachments);
    setLength(arDprts, 0);
  end;
end;
//============================================================ ������ ����������
procedure prGetReclamationList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetReclamationList'; // ��� ���������/�������
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    iCount, UserID, FirmID, sPos, iState, iRes: integer;
    s: string;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  GBIBD:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetReclamationList, UserID, FirmID); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    GBIBD:= CntsGRB.GetFreeCnt();
    GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'select RCNUMBER, RCDATE, RCSTATE,'+ // RCCODE, RCCONTRACTCODE, RCWARECODE,
      ' RCWARECOUNT, RCCOMMENT, RCRESOLUTION, WAREOFFICIALNAME,'+
      ' gn.rNum contnumber from RECLAMATIONREESTR'+
      ' left join Contract on contcode=RCCONTRACTCODE'+
      ' left join Vlad_CSS_GetFullContNum(contnumber, contnkeyyear, contpaytype) gn on 1=1'+
      ' left join Wares on warecode=RCWARECODE'+
      ' where RCFIRMCODE='+IntToStr(FirmID)+' order by RCDATE desc';

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    sPos:= Stream.Position;
    Stream.WriteInt(0); // �������� ����� ��� ���-��
    iCount:= 0;

    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
//      Stream.WriteInt(GBIBS.FieldByName('RCCODE').AsInteger); // ��� ���-��
      iState:= GBIBS.FieldByName('RCSTATE').AsInteger; // ���������
      if not (iState in [crsPrepared..crsExecuted]) then iState:= crsUnknown;
      if GBIBS.FieldByName('RCRESOLUTION').IsNull then iRes:= crsUnknown
      else begin                                       // �������� �������
        iRes:= GBIBS.FieldByName('RCRESOLUTION').AsInteger;
        if not (iRes in [crsDefected..crsReturned]) then iRes:= crsUnknown;
      end;

      Stream.WriteStr(GBIBS.FieldByname('RCNUMBER').AsString);    // ����� ���������
      Stream.WriteDouble(GBIBS.FieldByName('RCDATE').AsDateTime); // ���� ����������� ����������
      Stream.WriteStr(GBIBS.FieldByname('CONTNUMBER').AsString);  // ��������
      Stream.WriteStr(GBIBS.FieldByname('WAREOFFICIALNAME').AsString); // �����
      Stream.WriteDouble(GBIBS.FieldByName('RCWARECOUNT').AsFloat);    // ���-��
      Stream.WriteStr(GBIBS.FieldByname('RCCOMMENT').AsString);   // �����������

      if (iState=crsUnknown) then begin
        Stream.WriteStr('');          // ���������: ��������
        Stream.WriteStr('');         // ���������: ���������
      end else begin
        Stream.WriteStr(ReclStateNames[iState]);          // ���������: ��������
        Stream.WriteStr(ReclStateTitles[iState]);         // ���������: ���������
      end;

      if (iRes=crsUnknown) then begin
        Stream.WriteStr('');          // �������: ��������
        Stream.WriteStr('');         // �������: ���������
      end else begin
        Stream.WriteStr(ReclResNames[iRes]);              // �������: ��������
        Stream.WriteStr(ReclResTitles[iRes]);             // �������: ���������
      end;

//      Stream.WriteInt(iState); // ���������: �������� - ReclStateNames[i], ��������� - ReclStateTitles[i]
//      Stream.WriteInt(iRes);   // �������� �������: �������� - ReclResNames[i], ��������� - ReclResTitles[i]
      TestCssStopException;
      GBIBS.Next;
      Inc(iCount);
    end;
    GBIBS.Close;

    if (iCount>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(iCount); // �������� ���-��
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(GBIBS);
  cntsGRB.SetFreeCnt(GBIBD);
  Stream.Position:= 0;
end;
//============================================== �������� ������ ����������� �/�
procedure prGetMeetPersonsList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetMeetPersonsList'; // ��� ���������/�������
var UserID, FirmID, iCount, i: integer;
    s, ss: string;
    IBD: TIBDatabase;
    IBS: TIBSQL;
    lst: TStringList;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  lst:= fnCreateStringList(True, dupIgnore); // ������������� ������ ��� ����������
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetMeetPersonsList, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    try
      IBD:= CntsGRB.GetFreeCnt();
      IBS:= fnCreateNewIBSQL(IBD,'IBS_'+nmProc, ThreadData.ID, tpRead, true);
      IBS.SQL.Text:= 'SELECT pp.pphcode, pp.pphphone, p.prsnname'+
        '  from persons p left join personphones pp on pp.PPhPersonCode=p.prsncode'+
        '  left join TestMobilePhone(pp.PPhPhone) t on 1=1'+
        '  WHERE p.PrSnFirmCode='+IntToStr(FirmID)+' and t.RResult="T"'+
        '   and p.prsnarchivedkey="F" and pp.PPhArchivedKey="F" order by p.prsncode';
      IBS.ExecQuery;
      while not IBS.EOF do begin
        ss:= IBS.FieldByName('pphphone').AsString;
        if CheckMobileNumber(ss) then begin // �������� ���������� ������ ��������
          i:= IBS.FieldByName('pphcode').AsInteger;
          s:= trim(fnReplaceQuotedForWeb(IBS.FieldByName('prsnname').AsString))+' ('+ss+')';
          if (lst.IndexOf(s)<0) then lst.AddObject(s, Pointer(i));
        end;
        CntsGRB.TestSuspendException;
        IBS.Next;
      end;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(lst.Count); //----- �������� ���-��
    for iCount:= 0 to lst.Count-1 do begin
      i:= Integer(lst.Objects[iCount]);
      Stream.WriteInt(i);           //----- �������� ��� ������������ (��� �����)
      Stream.WriteStr(lst[iCount]); //----- �������� ����� ������������
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(lst);
end;
//===================== ������ ���������� ��� ���������� ��������� ������� (Web)
procedure prGetDestPointParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetDestPointParams'; // ��� ���������/�������
var iCount, UserID, FirmID, sPos: integer;
    s: string;
    Client: TClientInfo;
    firma: TFirmInfo;
    IBS: TIBSQL;
    IBD: TIBDatabase;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // ��� �/�

    prSetThLogParams(ThreadData, csGetDestPointParams, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmID];
    Client:= Cache.arClientInfo[UserID];

    if firma.IsFinalClient or (Client.ID<>firma.SUPERVISOR) then
      raise EBOBError.Create(MessText(mtkNotRightExists)); // �������� ����.�����.

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    IBD:= cntsGRB.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, true);
//---------------------------------------------------------------------- �������
    iCount:= 0;
    sPos:= Stream.Position;
    Stream.WriteInt(iCount); // ����� ��� ���-�� ��������
    IBS.SQL.Text:= 'select andtcode, andtname'+
      ' from ADRESSADDPARM left join analitdict on andtcode=adradregistrcode'+
      ' where adradadrclasscode=36517 order by andtname';
//      IBS.SQL.Text:= 'select adradregistrcode, adradnamemain'+
//        ' from ADRESSADDPARM where adradadrclasscode=36517 order by adradnamemain';
    IBS.ExecQuery;
    while not IBS.EOF do begin
      Stream.WriteInt(ibs.FieldByName('andtcode').AsInteger); // ��� �������
      Stream.WriteStr(ibs.FieldByName('andtname').AsString);  // �������� �������
      inc(iCount);
      cntsGRB.TestSuspendException;
      IBS.Next;
    end;
    IBS.Close;
    if (iCount>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(iCount);
      Stream.Position:= Stream.Size;
    end;

    IBS.SQL.Text:= ' select adrcllevel, andtcode, andtname, adrclshortname'+
      ' from analitdict left join ADRESSCLASSADDPARM on adrcladregistrcode=andtcode'+
      ' where andtmastercode=13589 and adrcllevel in (20, 25, 30)'+
      ' order by adrcllevel, andtname';
    IBS.ExecQuery;
//--------------------------- ��� ����������� ������ (����, �����, ���, �������)
    iCount:= 0;
    sPos:= Stream.Position;
    Stream.WriteInt(iCount); // ����� ��� ���-�� ����� ���������� �������
    while not IBS.EOF and (ibs.FieldByName('adrcllevel').AsInteger=20) do begin
      Stream.WriteInt(ibs.FieldByName('andtcode').AsInteger);      // ��� ���� ���.������
      Stream.WriteStr(ibs.FieldByName('andtname').AsString);       // �������� ���� ���.������
      Stream.WriteStr(ibs.FieldByName('adrclshortname').AsString); // ����.�������� ���� ���.������
      inc(iCount);
      cntsGRB.TestSuspendException;
      IBS.Next;
    end;
    if (iCount>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(iCount);
      Stream.Position:= Stream.Size;
    end;
//----------------------------------------------------------- ��� ��������������
//--- (�������, ��������, �������, ������, ��������, �����, �����, �����, �����)
    iCount:= 0;
    sPos:= Stream.Position;
    Stream.WriteInt(iCount); // ����� ��� ���-�� ����� ��������������
    while not IBS.EOF do begin
      Stream.WriteInt(ibs.FieldByName('andtcode').AsInteger);      // ��� ���� ��������������
      Stream.WriteStr(ibs.FieldByName('andtname').AsString);       // �������� ���� ��������������
      Stream.WriteStr(ibs.FieldByName('adrclshortname').AsString); // ����.�������� ���� ��������������
      inc(iCount);
      cntsGRB.TestSuspendException;
      IBS.Next;
    end;
    if (iCount>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(iCount);
//    Stream.Position:= Stream.Size;
    end;
  finally
    prFreeIBSQL(IBS);
    cntsGRB.SetFreeCnt(IBD);
  end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;



//******************************************************************************
end.
