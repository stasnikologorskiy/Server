unit n_OnlinePocedures; // ��������� ��� Web

interface
uses Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
     DB, IBDatabase, IBSQL, IBQuery,
     n_free_functions, v_constants, v_Functions, v_DataTrans, v_Server_Common,
     n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common;

procedure prAutenticateOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);

procedure prCreateNewOrderCommonOrd(UserId, FirmID: integer; var NewOrderID, contID: integer;
          var ErrorMessage: string; qID: integer=-1; OrdIBS: TIBSQL=nil);
procedure prGetOptionsOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSetOrderDefaultOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prChangePasswordOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebSetMainUserOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebCreateUserOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebResetPasswordOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCheckLoginOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetRegisterTableOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSaveRegOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCreateNewOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetOrderListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowACOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prDelLineFromOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prChangeQtyInOrderLineOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSendOrderToProcessingOrd (Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prRefreshPricesOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prRefreshPricesInFormingOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prEditOrderHeaderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetAccountListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCreateOrderByMarkedOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prJoinMarkedOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowGBAccountOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prDeleteOrderByMarkOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSetReservValueOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSetOrderPayTypeOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAddLinesToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ � �����
procedure prAddLineFromSearchResToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ����� � ����� ��������������� �� ����������� ������
 function fnRefreshPriceInOrderOrd(var SResult: string; OrderCode: string;      // ��������� ���� � ������ � ������ ��� �����
          acctype: string=''; ThreadData: TThreadData=nil): string;
 function fnRecaclQtyByDivisible(WareID: integer; var WareQty: double): string; // ���������� ���-�� ������ � ������ � ������������ � ����������
 function fnRecaclQtyByDivisibleEx(WareID: integer; WareQty: double): string;   // ��������� ������������ ���-�� ������ � ����������
procedure prChangeVisibilityOfStorage(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ��������� ������ �������
procedure prClientsStoreMove(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ����������� ����� � ������ ��������� ������� ����/����

procedure prChangeClientLastContract(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // �������� ��������� �������� �������/�������� ������
procedure prChangeOrderContract(FirmId, ContID, OrderID: integer;ThreadData: TThreadData); // �������� �������� ������ � ����������� ����

procedure prGetQtyByAnalogsAndStoragesOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ��� ������ �������� � 2 ������� ������� / ������ (Web)
procedure prAddLinesToOrderOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ � ����� - 2 ������� (Web)
procedure prAddLineFromSearchResToOrderOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData); // 2 ������� (Web)
procedure prShowOrderOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // �������� ������ - 2 ������� (Web)
procedure prCreateOrderByMarkedOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);
 function fnGetStoragesArray_2col(Contract: TContract; ReservedOnly: boolean=false; // ������ ��������� - 1/2/3 �������
                                  DefaultOnly: boolean=false): TasD;
procedure prSetCliContMargins(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // ��������� �������

implementation
uses n_MailServis, n_CSSservice, n_CSSThreads, n_vlad_mail, n_IBCntsPool, n_DataCacheObjects;
//*******************************************************************************
procedure prCreateNewOrderCommonOrd(UserId, FirmID: integer; var NewOrderID, contID: integer;
          var ErrorMessage: string; qID: integer=-1; OrdIBS: TIBSQL=nil);
const nmProc = 'prCreateNewOrderCommonOrd'; // ��� ���������/�������/������
var acctype, delivery, currID: integer;
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
    with Client do begin
      acctype:= DEFACCOUNTINGTYPE;
      delivery:= DEFDELIVERYTYPE;
    end;
    currID:= fnIfInt(acctype=1, 1, cDefCurrency);

    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select rOrderCode from CreateNewOrderHeaderC('+
      IntToStr(contID)+', "",'+IntToStr(acctype)+', '+IntToStr(Contract.Filial)+', '+
      Contract.MainStoreStr+','+IntToStr(cosByWeb)+', '+IntToStr(FirmID)+', '+
      IntToStr(delivery)+', '+IntToStr(currID)+  // fnIfStr(acctype=1, '1', IntToStr(cDefCurrency))+   // ???
      ', "", NULL, "", '+IntToStr(orstForming)+', "", NULL, '+IntToStr(UserID)+')';

    s:= RepeatExecuteIBSQL(OrdIBS, 'rOrderCode', NewOrderID);
    if s<>'' then raise Exception.Create('Not save order header: '+s);
    if NewOrderID<1  then raise Exception.Create('rOrderCode < 1');
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
//**************************************************** ������������� �����������
procedure prAutenticateWebInner(StreamIn, StreamOut: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAutenticateWebInner'; // ��� ���������/�������
var sid, UserLogin, UserPsw, IP, Ident, username, FirmCode, UserCode, ss, sParam: string;
    pUserID, pFirmID, i, iBlock, contID: integer;
    FullData, pResetPW, flEnterByLogin, flBaseAutorize: boolean;
//    LastAct: TDateTime;
    ibS: TIBSQL;
    ibDb: TIBDatabase;
    Client: TClientInfo;
    firma: TFirmInfo;
    Notifics: TIntegerList;
    Contract: TContract;
begin
  StreamIn.Position:= 0; // ???
  ibS:= nil;
  Client:= nil;
  pUserID:= 0;
  pFirmID:= 0;
  iBlock:= 0;
//  LastAct:= 0;
  pResetPW:= false;
  contID:= 0;
  flBaseAutorize:= False;
  UserCode:= '';
  try
    UserLogin:= trim(StreamIn.ReadStr);
    UserPsw:= trim(StreamIn.ReadStr);
    sid:= trim(StreamIn.ReadStr);
    IP:= trim(StreamIn.ReadStr);
    Ident:= trim(StreamIn.ReadStr);
    FullData:= boolean(StreamIn.ReadByte);
    contID:= StreamIn.ReadInt;   // ��� ����������

          // ����������� � ib_css - ������ �� �������, �������������� � ���� !!!
    sParam:= 'Login='+UserLogin+#13#10'Password='+UserPsw+
      #13#10'sid='+sid+#13#10'IP='+IP+#13#10'Browser='+Ident;
    try
  //---------------------------------------------------- ��������� ��������� �����
      flEnterByLogin:= (UserLogin<>'') and (UserPsw<>''); // ������� ����� �� ������
      if flEnterByLogin then begin
        if (Length(UserLogin)>Cache.ClientLoginLength) then
          raise EBOBError.Create('������������ ����� - '+UserLogin+'. '+MessText(mtkNotValidLogin));
        if (Length(UserPsw)>Cache.ClientPasswLength) then
          raise EBOBError.Create('������������ ������. '+MessText(mtkNotValidPassw));
  //      if not fnCheckOrderWebLogin(UserLogin) then
  //        raise EBOBError.Create(MessText(mtkNotValidLogin));
  //      if not fnCheckOrderWebPassword(UserPsw) then
  //        raise EBOBError.Create(MessText(mtkNotValidPassw));
      end else if (sid='') then
        raise EBOBError.Create(MessText(mtkNotParams));

  //---------------------------------------------- �������� �������������� �� ����
      if flEnterByLogin then with Cache.arClientInfo.WorkLogins do begin
        i:= IndexOf(UserLogin);
        if (i>-1) then pUserID:= Integer(Objects[i]);
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
          Cache.TestClients(pUserID, true); // �������� ������ ������� � ����
          Client:= Cache.arClientInfo[pUserID];
        end;
      if Assigned(Client) then begin // ���� ����� ������� - ��������� ������������� ���������� �� ����
        if not flEnterByLogin then flBaseAutorize:= (sid<>Client.Sid);
        flBaseAutorize:= flBaseAutorize or
          ((Now>IncMinute(Client.LastBaseAutorize, Cache.ClientActualInterval))
          and cntsGRB.NotManyLockConnects and cntsORD.NotManyLockConnects);
      end;
      flBaseAutorize:= flBaseAutorize or not Assigned(Client);

      if flBaseAutorize then begin
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
  //          LastAct  := ibS.FieldByName('rLastAct').AsDateTime;
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
        Client.LastBaseAutorize:= Now;
        Client.Login:= UserLogin;
        Client.Password:= UserPsw;
        Client.resetPW:= pResetPW;
        Client.BlockKind:= iBlock;
        Client.Sid:= sid;
      end // if flBaseAutorize
      else begin
        UserCode:= IntToStr(pUserID);
      end;
      Client.LastAct:= Now;
    finally
      if (pFirmID<1) and Assigned(Client) then pFirmID:= Client.FirmID;
      prSetThLogParams(ThreadData, 0, pUserID, pFirmID, sParam); // ����������� � ib_css
    end;

//---------------------------------------------------------- �������� ����������
    ss:= Client.CheckBlocked(True, True, cosByWeb);
    if Client.Blocked then raise EBOBError.Create(ss);

    firma:= Cache.arFirmInfo[pFirmID];
    if firma.Arhived or firma.Blocked then
      raise EBOBError.Create(MessText(mtkNotFirmProcess, firma.Name));
    if (firma.FirmContracts.Count<1) then
      raise EBOBError.Create('�� ������� ��������� �����������');

    Contract:= Client.GetCliContract(contID);

    FirmCode:= IntToStr(pFirmID);
    username:= fnCutFIO(Client.Name)+', '+firma.Name; // ������������ �����

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
            ibs.Next;
          end;
        finally
          prFreeIBSQL(ibS);
          cntsOrd.SetFreeCnt(ibDb);
        end;
      end; // if (Notifics.Count>0)
    end // if flEnterByLogin
    else Notifics:= TIntegerList.Create; // �� ����.������
//------------------------------------------------------------------------------

    StreamOut:= StreamIn; // debug

    StreamOut.Clear;
    StreamOut.WriteInt(aeSuccess);  // ���� ����, ��� ������ ��������� ���������
    StreamOut.WriteInt(Client.ID);       // ��� ������������
    StreamOut.WriteStr(Client.Login);    // ����� ������������
    StreamOut.WriteStr(Client.Password); // ������ ������������ �� ������, ���� ����� �������������� �����
    StreamOut.WriteInt(Client.FirmID);   // ��� �����
    StreamOut.WriteStr(Client.Sid);      // id ������
    StreamOut.WriteBool(Client.resetPW); // ������� ������ ������
    StreamOut.WriteInt(Cache.GetConstItem(pcClientTimeOutWeb).IntValue);
    StreamOut.WriteStr(username);        // ������������ ������� � �����
    StreamOut.WriteStr(Client.Mail);     // Email ������������ ����

    StreamOut.WriteBool(firma.SUPERVISOR=pUserID); // �������� �� ������������ ������������
    if (firma.SUPERVISOR<>pUserID) then begin    // ���� �� ��������, �� �������� ��� �����
      StreamOut.WriteBool(false); // WOCLRIGHTSENDORDER
      StreamOut.WriteBool(false); // WOCLRIGHTOWNPRICE
      StreamOut.WriteBool(false); // WOCLRIGHTVIEWDISCOUNTABLE
    end;

    StreamOut.WriteInt(ContID); // ��� ��������� (���� ���� - ����������)

    if FullData then begin
      StreamOut.WriteDouble(Contract.CredLimit);
      StreamOut.WriteDouble(Contract.DebtSum);
      StreamOut.WriteDouble(Contract.OrderSum);
      StreamOut.WriteDouble(Contract.PlanOutSum);
      StreamOut.WriteInt(Contract.CredCurrency);
      StreamOut.WriteStr(Cache.GetCurrName(Contract.CredCurrency));
      StreamOut.WriteStr(Contract.WarnMessage);
      StreamOut.WriteBool(Contract.SaleBlocked);
      StreamOut.WriteInt(Contract.CredDelay);
      if not Contract.SaleBlocked then
        StreamOut.WriteInt(Contract.WhenBlocked); // ���� �������� �� �����������
      StreamOut.WriteBool(firma.HasVINmail);
      ss:= '';
      if (firma.ActionText<>'') and
        (pos(cActionTextDelim, Cache.GetConstItem(pcCommonActionText).StrValue)>0) then
        ss:= StringReplace(Cache.GetConstItem(pcCommonActionText).StrValue, cActionTextDelim, firma.ActionText, []);
      StreamOut.WriteStr(ss); // ����� ����� ����� + ��������� ������� � �����
      StreamOut.WriteDouble(Cache.CURRENCYRATE);
      StreamOut.WriteInt(Client.CliContracts.Count); // ���-�� ��������� ����������
      StreamOut.WriteStr(Contract.Name);
    end;

    StreamOut.WriteDouble(Now);
    StreamOut.WriteStr(FirmCode);
    StreamOut.WriteBool(Contract.SysID=constIsMoto); // ������� ����

    StreamOut.WriteInt(Notifics.Count); //----------------------------- �����������
    for i:= 0 to Notifics.Count-1 do StreamOut.WriteInt(Notifics[i]);
//------------------------------------------------------------------------------

  except
    on E: EBOBError do  // '������ �����������. '
      prSaveCommonError(StreamOut, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do begin
      StreamOut.Clear;
      StreamOut.WriteInt(aeCommonError);
      StreamOut.WriteStr('������ �����.');
      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
    end;
  end;
//  StreamOut.Position:= 0;
  prFree(Notifics);
end;
//*******************************************************************************
procedure prAutenticateOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAutenticateOrd'; // ��� ���������/�������
var sid, UserLogin, UserPsw, IP, Ident, username, usermail,
      FirmCode, UserCode, ss, sParam: string;
    pUserId, pFirmID, i, iBlock, contID: integer;
    FullData, pResetPW, flEnterByLogin, flBaseAutorize: boolean;
//    LastAct: TDateTime;
    ibS: TIBSQL;
    ibDb: TIBDatabase;
    Client: TClientInfo;
    firma: TFirmInfo;
    Notifics: TIntegerList;
    Contract: TContract;
    lst: TList;
begin
  Stream.Position:= 0;
  ibS:= nil;
  Client:= nil;
  pFirmID:= 0;
  pUserID:= 0;
  iBlock:= 0;
//  LastAct:= 0;
  pResetPW:= false;
  contID:= 0;
  flBaseAutorize:= False;
  UserCode:= '';
  sParam:= '';
  try
    UserLogin:= trim(Stream.ReadStr);
    UserPsw:= trim(Stream.ReadStr);
    sid:= trim(Stream.ReadStr);
    IP:= trim(Stream.ReadStr);
    Ident:= trim(Stream.ReadStr);
    FullData:= boolean(Stream.ReadByte);
    contID:= Stream.ReadInt;   // ��� ����������
          // ����������� � ib_css - ������ �� �������, �������������� � ���� !!!
    sParam:= 'Login='+UserLogin+#13#10'Password='+UserPsw+
      #13#10'sid='+sid+#13#10'IP='+IP+#13#10'Browser='+Ident;
    try
  //---------------------------------------------------- ��������� ��������� �����
      flEnterByLogin:= (UserLogin<>'') and (UserPsw<>''); // ������� ����� �� ������
      if flEnterByLogin then begin
        if (Length(UserLogin)>Cache.ClientLoginLength) then
          raise EBOBError.Create('������������ ����� - '+UserLogin+'. '+MessText(mtkNotValidLogin));
        if (Length(UserPsw)>Cache.ClientPasswLength) then
          raise EBOBError.Create('������������ ������. '+MessText(mtkNotValidPassw));
  //      if not fnCheckOrderWebLogin(UserLogin) then
  //        raise EBOBError.Create(MessText(mtkNotValidLogin));
  //      if not fnCheckOrderWebPassword(UserPsw) then
  //        raise EBOBError.Create(MessText(mtkNotValidPassw));
      end else if (sid='') then
        raise EBOBError.Create(MessText(mtkNotParams));

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
          Cache.TestClients(pUserID, true); // �������� ������ ������� � ����
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
  //          LastAct  := ibS.FieldByName('rLastAct').AsDateTime;
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
        Client.LastBaseAutorize:= Now;
        Client.Login:= UserLogin;
        Client.Password:= UserPsw;
        Client.resetPW:= pResetPW;
        Client.BlockKind:= iBlock;
        Client.Sid:= sid;
      end // if flBaseAutorize
      else begin
        UserCode:= IntToStr(pUserID);
      end;
    finally
      if (pFirmID<1) and Assigned(Client) then pFirmID:= Client.FirmID;
      prSetThLogParams(ThreadData, 0, pUserID, pFirmID, sParam); // ����������� � ib_css
    end;
    Client.LastAct:= Now;

//---------------------------------------------------------- �������� ����������
    ss:= Client.CheckBlocked(True, True, cosByWeb);
    if Client.Blocked then raise EBOBError.Create(ss);

    firma:= Cache.arFirmInfo[pFirmID];
    if firma.Arhived or firma.Blocked then
      raise EBOBError.Create(MessText(mtkNotFirmProcess, firma.Name));
    if (firma.FirmContracts.Count<1) then
      raise EBOBError.Create('�� ������� ��������� �����������');

    Contract:= Client.GetCliContract(contID);

    FirmCode:= IntToStr(pFirmID);
    username:= fnCutFIO(Client.Name)+', '+firma.Name; // ������������ �����
    usermail:= Client.Mail;                         // Email ������������ ����

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
            ibs.Next;
          end;
        finally
          prFreeIBSQL(ibS);
          cntsOrd.SetFreeCnt(ibDb);
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
    Stream.WriteStr(Client.Mail);     // Email ������������ ����

    Stream.WriteBool(firma.SUPERVISOR=pUserID); // �������� �� ������������ ������������
    if firma.SUPERVISOR<>pUserID then begin    // ���� �� ��������, �� �������� ��� �����
      Stream.WriteBool(false); // WOCLRIGHTSENDORDER
      Stream.WriteBool(false); // WOCLRIGHTOWNPRICE
      Stream.WriteBool(false); // WOCLRIGHTVIEWDISCOUNTABLE
    end;

    Stream.WriteInt(ContID); // ��� ��������� (���� ���� - ����������)

    if FullData then begin
      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteDouble(Contract.DebtSum);
      Stream.WriteDouble(Contract.OrderSum);
      Stream.WriteDouble(Contract.PlanOutSum);
      Stream.WriteInt(Contract.CredCurrency);
      Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency));
      Stream.WriteStr(Contract.WarnMessage);
      Stream.WriteBool(Contract.SaleBlocked);
      Stream.WriteInt(Contract.CredDelay);
      if not Contract.SaleBlocked then
        Stream.WriteInt(Contract.WhenBlocked); // ���� �������� �� �����������
      Stream.WriteBool(firma.HasVINmail);
      ss:= '';
      if (firma.ActionText<>'') and
        (pos(cActionTextDelim, Cache.GetConstItem(pcCommonActionText).StrValue)>0) then
        ss:= StringReplace(Cache.GetConstItem(pcCommonActionText).StrValue, cActionTextDelim, firma.ActionText, []);
      Stream.WriteStr(ss); // ����� ����� ����� + ��������� ������� � �����
      Stream.WriteDouble(Cache.CURRENCYRATE);
      Stream.WriteInt(Client.CliContracts.Count); // ���-�� ��������� ����������
      Stream.WriteStr(Contract.Name);
    end;

    Stream.WriteDouble(Now);
    Stream.WriteStr(FirmCode);
    Stream.WriteBool(Contract.SysID=constIsMoto); // ������� ����

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
(*
procedure prAutenticateOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAutenticateOrd'; // ��� ���������/�������
var sid, UserLogin, UserPsw, FirmName, IP, Ident, username, usermail,
      FirmCode, UserCode, ss: string;
    pUserId, pFirmID, superID, i, {iBlock,} contID: integer;
    FullData, resetPW, flEnterByLogin: boolean;
    LastAct: TDateTime;
    ibS: TIBSQL;
    ibDb: TIBDatabase;
//    ibSt: TIBSQL;
//    ibDbt: TIBDatabase;
    Client: TClientInfo;
    firma: TFirmInfo;
    Notifics: TIntegerList;
    Contract: TContract;
{  //-------------------------------------------  �� �������� ???
  procedure SaveToLogTransInfo(emess, dop: string);
  var i: integer;
      s, ntr: string;
  begin
    i:= pos('concurrent transaction number is ', emess);
    if i<1 then exit;
    s:= '';
    ntr:= copy(emess, i+33, length(emess));
    for i:= 1 to length(ntr) do
      if SysUtils.CharInSet(ntr[i], ['0'..'9']) then s:= s+ntr[i] else break;
    if s='' then exit;
    try
      prMessageLOGS(' ', 'deadlock_ord', False);
      prMessageLOGS('E.Message: '+emess, 'deadlock_ord', False);
      prMessageLOGS('TransInfo (id='+s+') --------------- begin', 'deadlock_ord', False);
      if dop<>'' then prMessageLOGS('addi_info: '+dop, 'deadlock_ord', False);
      if not ibst.Transaction.InTransaction then ibst.Transaction.StartTransaction;
      if ibst.SQL.Text='' then begin
        ibst.SQL.Text:= 'select T.mon$timestamp tr_begin, '+
          ' DATEDIFF(SECOND FROM T.mon$timestamp TO current_timestamp) tr_sec, '+
          ' A.mon$user tr_user, A.mon$remote_process tr_proc, '+
          ' cast( S.mon$sql_text as varchar (2400)) tr_sql from MON$TRANSACTIONS T'+
          ' left join MON$STATEMENTS S on S.mon$transaction_id = T.mon$transaction_id'+
          ' left join MON$ATTACHMENTS A on A.mon$attachment_id = T.mon$attachment_id'+
          ' where T.mon$transaction_id = :tid';
        ibst.Prepare;
      end;
      ibst.ParamByName('tid').AsString:= s;
      ibst.ExecQuery;
      while not ibst.Eof do begin
        prMessageLOGS('tr_begin='+ibst.Fields[0].AsString+', tr_sec='+ibst.Fields[1].AsString+
          ', tr_user='+ibst.Fields[2].AsString+', tr_proc='+ibst.Fields[3].AsString, 'deadlock_ord', False);
        prMessageLOGS('tr_sql='+ibst.Fields[4].AsString, 'deadlock_ord', False);
        ibst.Next;
      end;
      prMessageLOGS('TransInfo (id='+s+') --------------- end'#10#10, 'deadlock_ord', False);
    except
      on E: Exception do prMessageLOGS('error SaveToLogTransInfo: '+E.Message, 'deadlock_ord', False);
    end;
    if ibst.Transaction.InTransaction then ibst.Transaction.Rollback;
    ibst.Close;
  end;
  //-------------------------------------------  }
begin

  prAutenticateWebInner(Stream, nil, ThreadData); // debug
  Stream.Position:= 0;                            // debug
  exit;                                           // debug

  Stream.Position:= 0;
  ibS:= nil;
  pUserId:= 0;
//  iBlock:= 0;
  LastAct:= 0;
  resetPW:= false;
  contID:= 0;
  try
    UserLogin:= trim(Stream.ReadStr);
    UserPsw:= trim(Stream.ReadStr);
    sid:= trim(Stream.ReadStr);
    IP:= trim(Stream.ReadStr);
    Ident:= trim(Stream.ReadStr);
    FullData:= boolean(Stream.ReadByte);
    contID:= Stream.ReadInt;   // ��� ����������
          // ����������� � ib_css - ������ �� �������, �������������� � ���� !!!
    prSetThLogParams(ThreadData, 0, 0, 0, 'Login='+UserLogin+#13#10'Password='+UserPsw+
      #13#10'sid='+sid+#13#10'IP='+IP+#13#10'Browser='+Ident);

    if ((UserLogin+UserPsw+sid)='') then
      raise EBOBError.Create(MessText(mtkNotParams));

    if (UserLogin<>'') and (Length(UserLogin)>Cache.ClientLoginLength) then
      raise EBOBError.Create('������������ ����� - '+UserLogin+'. '+MessText(mtkNotValidLogin));
    if (UserPsw<>'') and (Length(UserPsw)>Cache.ClientPasswLength) then
      raise EBOBError.Create('������������ ������. '+MessText(mtkNotValidPassw));
//    if (UserLogin<>'') and not fnCheckOrderWebLogin(UserLogin) then
//      raise EBOBError.Create(MessText(mtkNotValidLogin));
//    if (UserPsw<>'') and not fnCheckOrderWebPassword(UserPsw) then
//      raise EBOBError.Create(MessText(mtkNotValidPassw));

    flEnterByLogin:= (UserLogin<>'') and (UserPsw<>''); // ��������� ����������� ��� ����� �� ������

    ibDb:= cntsORD.GetFreeCnt;
//    ibDbt:= cntsORD.GetFreeCnt;
    try
//      ibSt:= fnCreateNewIBSQL(ibDbt, 'ibSt_'+nmProc, ThreadData.ID);
      ibS:= fnCreateNewIBSQL(ibDb, 'ibS_'+nmProc, ThreadData.ID, tpWrite, true);
//------------------------------------------------------------------------------
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
        pUserId  := ibS.FieldByName('rWOCLCODE').AsInteger;
        UserCode := ibS.FieldByName('rWOCLCODE').AsString;
        UserLogin:= ibS.FieldByName('rWOCLLOGIN').AsString;
        UserPsw  := ibS.FieldByName('rWOCLPASSWORD').AsString;
        resetPW  := GetBoolGB(ibs, 'rWOCLRESETPASWORD');
        sid      := ibS.FieldByName('rWOCLSESSIONID').AsString;
//        iBlock   := ibS.FieldByName('rBlock').AsInteger;
        LastAct  := ibS.FieldByName('rLastAct').AsDateTime;
        ibS.Transaction.Commit;
        ibS.Close;
        break;
      except
        on E: EBOBError do raise EBOBError.Create(fnReplaceQuotedForWeb(E.Message));
        on E: Exception do begin
//          if (Pos('lock', E.Message)>0) then SaveToLogTransInfo(E.Message, 'try '+IntToStr(i));
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
//      prFreeIBSQL(ibSt);
//      cntsOrd.SetFreeCnt(ibDbt);
    end;
//------------------------------------------------------------------------------
    Cache.TestClients(pUserID, true); // �������� ������ ������� � ����
    if not Cache.ClientExist(pUserID) then
      raise EBOBError.Create(MessText(mtkNotClientExist, UserCode));
    Client:= Cache.arClientInfo[pUserID];

    Client.LastAct:= LastAct;
    ss:= Client.CheckBlocked(True, True, cosByWeb); // �������� ����������
    if Client.Blocked then raise EBOBError.Create(ss);

    pFirmID := Client.FirmID;
    firma   := Cache.arFirmInfo[pFirmID];

    if (firma.FirmContracts.Count<1) then
      raise EBOBError.Create('�� ������� ��������� �����������');

    Contract:= Client.GetCliContract(contID);

    FirmCode:= IntToStr(pFirmID);
    FirmName:= firma.Name;
    username:= fnCutFIO(Client.Name)+', '+FirmName; // ������������ �����
    usermail:= Client.Mail;                         // Email ������������ ����
    superID := firma.SUPERVISOR;

    prSetThLogParams(ThreadData, 0, pUserID, pFirmID, ''); // ����������� � ib_css

    if firma.Arhived or firma.Blocked then
      raise EBOBError.Create(MessText(mtkNotFirmProcess, FirmName));
    with Client do begin
      if Arhived then raise EBOBError.Create(MessText(mtkNotLoginProcess, UserLogin));
      if Blocked then raise EBOBError.Create(MessText(mtkBlockCountLogin, UserLogin));
    end;
//------------------------------------------------------------------ �����������
    if flEnterByLogin then begin
      Notifics:= Cache.Notifications.GetFirmNotifications(pFirmID); // ������ ����������� �����
      if (Notifics.Count>0) then begin
        ibDb:= cntsORD.GetFreeCnt;
        ss:= fnIntegerListToStr(Notifics); // ������ � ������ ����������� �����
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
            ibs.Next;
          end;
        finally
          prFreeIBSQL(ibS);
          cntsOrd.SetFreeCnt(ibDb);
        end;
      end; // if (Notifics.Count>0)
    end // if flEnterByLogin
    else Notifics:= TIntegerList.Create; // �� ����.������
//------------------------------------------------------------------------------

    Stream.Clear;
    Stream.WriteInt(aeSuccess);  // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(pUserID);    // ��� ������������
    Stream.WriteStr(UserLogin);  // ����� ������������
    Stream.WriteStr(UserPsw);    // ������ ������������ �� ������, ���� ����� �������������� �����
    Stream.WriteInt(pFirmID);    // ��� �����
    Stream.WriteStr(sid);        // id ������
    Stream.WriteBool(resetPW);   // ������� ������ ������
    Stream.WriteInt(Cache.GetConstItem(pcClientTimeOutWeb).IntValue);
    Stream.WriteStr(username);   // ������������ ������� � �����
    Stream.WriteStr(usermail);   // Email ������������ ����

    Stream.WriteBool(superID=pUserID); // �������� �� ������������ ������������
    if superID<>pUserID then begin    // ���� �� ��������, �� �������� ��� �����
      Stream.WriteBool(false); // WOCLRIGHTSENDORDER
      Stream.WriteBool(false); // WOCLRIGHTOWNPRICE
      Stream.WriteBool(false); // WOCLRIGHTVIEWDISCOUNTABLE
    end;

    Stream.WriteInt(ContID); // ��� ��������� (���� ���� - ����������)

    if FullData then begin
      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteDouble(Contract.DebtSum);
      Stream.WriteDouble(Contract.OrderSum);
      Stream.WriteDouble(Contract.PlanOutSum);
      Stream.WriteInt(Contract.CredCurrency);
      Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency));
      Stream.WriteStr(Contract.WarnMessage);
      Stream.WriteBool(Contract.SaleBlocked);
      Stream.WriteInt(Contract.CredDelay);
      if not Contract.SaleBlocked then
        Stream.WriteInt(Contract.WhenBlocked); // ���� �������� �� �����������
      Stream.WriteBool(firma.HasVINmail);
      ss:= '';
      if (firma.ActionText<>'') and
        (pos(cActionTextDelim, Cache.GetConstItem(pcCommonActionText).StrValue)>0) then
        ss:= StringReplace(Cache.GetConstItem(pcCommonActionText).StrValue, cActionTextDelim, firma.ActionText, []);
      Stream.WriteStr(ss); // ����� ����� ����� + ��������� ������� � �����
      Stream.WriteDouble(Cache.CURRENCYRATE);
      Stream.WriteInt(Client.CliContracts.Count); // ���-�� ��������� ����������
      Stream.WriteStr(Contract.Name);
    end;

    Stream.WriteDouble(Now);
    Stream.WriteStr(FirmCode);
    Stream.WriteBool(Contract.SysID=constIsMoto); // ������� ����

    Stream.WriteInt(Notifics.Count); //----------------------------- �����������
    for i:= 0 to Notifics.Count-1 do Stream.WriteInt(Notifics[i]);
//------------------------------------------------------------------------------

{    if flEnterByLogin and cntsLog.BaseConnected then begin // ������ ������������ �����
      try
        ibDb:= cntsLog.GetFreeCnt;
        ibS:= fnCreateNewIBSQL(ibDb, 'ibSql', pUserID, tpWrite, true);
        ibS.SQL.Text:= 'execute procedure CheckLogFirmName('+FirmCode+', :aFName)';
        ibS.ParamByName('aFName').AsString:= FirmName;
        ss:= RepeatExecuteIBSQL(ibs);
        if ss<>'' then raise Exception.Create(ss);
      except
        on E: Exception do begin
          if Assigned(ibS) then with ibS.Transaction do if InTransaction then Rollback;
          fnWriteToLog(ThreadData, lgmsSysError, nmProc,
            '������ ������ ������������ ����� � ���� �����������: ', E.Message, ibS.SQL.Text);
        end;
      end;
      prFreeIBSQL(ibS);
      cntsLog.SetFreeCnt(ibDb);
    end;  }
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
*)
//*******************************************************************************
procedure prGetOptionsOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetOptionsOrd'; // ��� ���������/�������
var UserId, FirmID, i, j, ContID, ind, iCount: integer;
    Stores: Tasd;
    Store: TStoreInfo;
    Client: TClientInfo;
    firma: TFirmInfo;
    Contract: TContract;
    CliStores: TIntegerList;  // not Free
    errmess: String;
    grp: TWareInfo;
    cq: TCodeAndQty;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
//    ContID:= Stream.ReadInt; // ��� ���������� - ����� �� ����� ����
    prSetThLogParams(ThreadData, 0, UserID, FirmID, ''); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    Client:= Cache.arClientInfo[UserID];
    if (contID<1) then contID:= Client.LastContract;
    firma:= Cache.arFirmInfo[FirmID];
    Contract:= firma.GetContract(contID);
    CliStores:= Client.GetContStoreCodes(contID);
//----------------------------------------------------------- ��������� � ������
    with Client do begin
      Stream.WriteByte(DEFACCOUNTINGTYPE);
      Stream.WriteByte(DEFDELIVERYTYPE);
      Stream.WriteBool(NOTREMINDCOMMENT);
      Stream.WriteInt(SearchCurrencyID);
      Stream.WriteStr(IntToStr(MaxRowShowAnalogs));
      Stream.WriteBool(DocsByCurrContr);

      if flClientStoragesView_2col then SetLength(Stores, 0)
      else begin // ������� �������� �� ������, ������� ���� ��������� ��� �������
        SetLength(Stores, CliStores.Count);
        for i:= 0 to CliStores.Count-1 do begin
          j:= CliStores[i];
          Stores[i].Code:= IntToStr(j);
          Stores[i].FullName:= Cache.GetDprtMainName(j);
          Stores[i].IsVisible:= true;
          ind:= Contract.Get�ontStoreIndex(j);
          Stores[i].IsReserve:= Contract.ContStorages[ind].IsReserve;
        end;
      end;

    end; // with Client
    if not flClientStoragesView_2col and                  // ����� ��� ���������
      (Length(Contract.ContStorages)>CliStores.Count) then
      for i:= Low(Contract.ContStorages) to High(Contract.ContStorages) do begin
        Store:= Contract.ContStorages[i];
        if (CliStores.IndexOf(Store.DprtID)<0) then begin
          j:= Length(Stores);
          SetLength(Stores, j+1);
          Stores[j].Code:= Store.DprtCode;
          Stores[j].FullName:= Cache.GetDprtMainName(Store.DprtID);
          Stores[j].IsVisible:= false;
          Stores[j].IsReserve:= Store.IsReserve;
        end;
      end;
    prSendStorages(Stores, Stream);
    Stream.WriteBool(firma.EnablePriceLoad);
//---------------------------------------------------------- ������������ ������
    with Client do begin
      Stream.WriteStr(Name);
      Stream.WriteStr(Post);
      Stream.WriteInt(CliPhones.Count); // Client.CliPhones
      for i:= 0 to CliPhones.Count-1 do Stream.WriteStr(CliPhones[i]);
      Stream.WriteInt(CliMails.Count);  // Client.CliMails
      for i:= 0 to CliMails.Count-1 do Stream.WriteStr(CliMails[i]);
    end;
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
    end;
//----------------------------------------------------------
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
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserID, FirmID, i, j, index, contID, StoreID, opt: integer;
    StoreCode, Visibility, errmess: string;
    Storages: Tasd;
    Contract: TContract;
    Client: TClientInfo;
    CliStores: TIntegerList;  // not Free
begin
  Stream.Position:= 0;
  IBS:= nil;
  contID:= 0;
  opt:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
//    ContID:= Stream.ReadInt; // ��� ���������� - ����� �� �����
    StoreCode:= Stream.ReadStr;
    Visibility:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'StoreCode='+StoreCode+' Visibility='+Visibility); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    StoreID:= StrToIntDef(StoreCode, 0);
    Client:= Cache.arClientInfo[UserID];
                               // ���������, �������� �� ������ ���� �����
    Contract:= Cache.arFirmInfo[FirmID].GetContract(contID);
    if (Client.CliContracts.IndexOf(contID)<0) then raise EBOBError.Create('�������� �� ������');

    index:= Contract.Get�ontStoreIndex(StoreID);
    if (index<0) then raise EBOBError.Create('����� �� ������');
    if (Visibility='false') and Contract.ContStorages[index].IsReserve then
      raise Exception.Create('�����, ��������� ��� ��������������, ������ ������� ���������');

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
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserID, FirmID, i, j, jj, index, contID, StoreID, opt: integer;
    StoreCode, Direct, errmess: string;
    Storages: Tasd;
    Contract: TContract;
    Client: TClientInfo;
    CliStores: TIntegerList;  // not Free
begin
  Stream.Position:= 0;
  IBS:= nil;
  contID:= 0;
  opt:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
//    ContID:= Stream.ReadInt; // ��� ���������� - ����� �� �����
    StoreCode:= Stream.ReadStr;
    Direct:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'StoreCode='+StoreCode+' Direct='+Direct); // �����������

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

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'ContID='+IntToStr(ContID)+'OrderID='+IntToStr(OrderID)); // �����������

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
    curr, i, SysID: Integer;
    exlines: Boolean;
    CurrPrice: Double;
    s: String;
    ware: TWareInfo;
begin
  OrdIBS:=  nil;
  OrdIBD:= nil;
  lst:= TStringList.Create;
  try
    SysID:= Cache.Contracts[ContID].SysID;

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
        if not ware.CheckWareTypeSys(SysID) then // �������� �� ����.����.
          raise EBOBError.Create('����� '+ware.Name+' �� ������������� ���������');

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
    paytype:= Stream.ReadStr;
    reserv:= Stream.ReadStr;
    NotRemind:= Stream.ReadStr;
    SearchCurr:= Stream.ReadStr;
    AnaRows:= trim(Stream.ReadStr);
    Semafor:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'paytype='+paytype+#13#10+'reserv='+reserv+#13#10+
      'NotRemind='+NotRemind+#13#10+'SearchCurr='+SearchCurr+#13#10+'AnaRows='+AnaRows); // �����������

    iAnaRows:= StrToIntDef(AnaRows, -1);
    if iAnaRows<0 then
      raise EBOBError.Create('���������� ����� ������ ���� ����� ������.');

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= 'UPDATE WEBORDERCLIENTS SET WOCLNOTREMINDCOMMENT=:s'+
      ', WOCLSEARCHCURRENCY='+fnIfStr(SearchCurr='1', SearchCurr, cStrDefCurrCode)+
      ', WOCLDEFAULTACCOUNTINGTYPE='+fnIfStr(paytype='1', '1', '0')+
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
      DEFACCOUNTINGTYPE:= StrToIntDef(paytype, 0);
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
    UserId, FirmID: integer;
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
    prSetThLogParams(ThreadData, 0, UserID, FirmID,
      'oldpass='+oldpass+#13#10+'newpass1='+newpass1+#13#10+'newpass2='+newpass2); // �����������

    if (newpass1=oldpass) then
      raise EBOBError.Create('����� ������ �� ������ ��������� �� ������.');
    if not fnCheckOrderWebPassword(newpass1) then
      raise EBOBError.Create(MessText(mtkNotValidPassw));
    if (newpass1<>newpass2) then
      raise EBOBError.Create('����� ������ � ��� ������ �� ���������.');


    with Cache.arClientInfo[UserId] do begin
// vc +++
    if (newpass1=Login) then
      raise EBOBError.Create('������ �� ������ ��������� � �������.');
// vc ---

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
    newcode, s: string;
    Client: TClientInfo;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    newcode:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'newcode='+newcode); // �����������

    if (Cache.arFirmInfo[FirmId].SUPERVISOR<>UserId) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    inewcode:= StrToIntDef(newcode, -1);
    if inewcode<0 then raise EBOBError.Create(MessText(mtkErrorUserID));

    if not Cache.ClientExist(inewcode) then
      raise Exception.Create(MessText(mtkNotClientExist));

    Client:= Cache.arClientInfo[inewcode];
    if (Client.FirmID<>FirmId) or (Client.Login='') or (Client.Post='') then
      raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    OrdIBD:= cntsORD.GetFreeCnt;

    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= 'UPDATE WEBORDERFIRMS SET WOFRSUPERVISOR='+newcode+
                          ' WHERE WOFRCODE='+IntToStr(FirmID);
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);
    Cache.arFirmInfo[FirmId].SUPERVISOR:= inewcode;

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
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'newcode='+newcode); // �����������

    if (Cache.arFirmInfo[FirmId].SUPERVISOR<>UserId) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    inewcode:= StrToIntDef(newcode, -1);
    if inewcode<0 then raise EBOBError.Create(MessText(mtkErrorUserID));
    if not Cache.ClientExist(inewcode) then
      raise Exception.Create(MessText(mtkNotClientExist));

    Client:= Cache.arClientInfo[inewcode];
    if (Client.FirmID<>FirmId) or (Client.Login='') or (Client.Post='') then
      raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    OrdIBD:= cntsORD.GetFreeCnt;

    FnamesValues[0]:= 'rPassword';
    FnamesValues[1]:= 'rErrText';
//    FnamesValues:= ('rPassword', 'rErrText');

    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
    OrdIBS.SQL.Text:= 'select rPassword, rErrText from SetUserPassword('+newcode+', :p, 1, 0)';
    OrdIBS.ParamByName('p').AsString:= '';
    s:= RepeatExecuteIBSQL(OrdIBS, FnamesValues);
    if s<>'' then raise Exception.Create(s);
    s:= FnamesValues[1];
    if s<>'' then raise EBOBError.Create(s);
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
    newpass, newlogin, newcode, errmes: string;
    Client: TClientInfo;
    Strings: TStringList; // vc
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    newcode:= Stream.ReadStr;
    newlogin:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID,
      'newcode='+newcode+#13#10+'newlogin='+newlogin); // �����������

    if (Cache.arFirmInfo[FirmId].SUPERVISOR<>UserId) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    inewcode:= StrToIntDef(newcode, -1);
    if inewcode<0 then raise EBOBError.Create(MessText(mtkErrorUserID));
    if not Cache.ClientExist(inewcode)then
      raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    Client:= Cache.arClientInfo[inewcode];
    if (Client.FirmID<>FirmId) then
      raise EBOBError.Create(MessText(mtkNotClientOfFirm));
    if (Client.Login<>'') then
      raise EBOBError.Create('������������ ��� ����� ������� ������ � �������.');
    if (Client.Name='') then
      raise EBOBError.Create('�� ������ ��� ������������.');
    if (Client.Post='') then
      raise EBOBError.Create('�� ������ ��������� ������������.');
    if (Client.Mail='') then // vc
      raise EBOBError.Create('�� ����� email ������������.'); // vc
    if newLogin='' then raise EBOBError.Create(MessText(mtkNotValidLogin));
    if not fnCheckOrderWebLogin(newLogin) then raise EBOBError.Create(MessText(mtkNotValidLogin));
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

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
// vc +++
//    Stream.WriteStr(newpass);
      Strings:=TStringList.Create;
      Strings.Add('������������');
      Strings.Add('��� ���, ��� ������� �������� "���������", ������� ������� ������ �� ����� http://order.vladislav.ua.');
      Strings.Add('�����: '+Client.Login);
      Strings.Add('������: '+Client.Password);
      Strings.Add('');
      errmes:= n_SysMailSend(Client.Mail, '��� ��� ������� ������� ������ �� ����� order.vladislav.ua', Strings, nil, '', '', true);
      prSaveCommonError(Stream, ThreadData, nmProc, errmes, '', True);
      if errmes<>'' then raise EBOBError.Create('������� ������ ������� �������, �� ��� �������� ������ � ������� ��������� ������.'
        +'  �������� ������ ���������� ��� ����� � ���������� �������� ������ ��� ����� ����� ������� �������������� ������');
// vc ---
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(IBS), 'IBS.SQL.Text='+IBS.SQL.Text, ''), False);
  end;
  Stream.Position:= 0;
  prFree(Strings);  // vc
end;
//********************************************* ������������� ����������� ������
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
    prSetThLogParams(ThreadData, 0, 0, 0, 'Login='+Login); // �����������

    if not fnCheckOrderWebLogin(Login) then
      raise EBOBError.Create(MessText(mtkNotValidLogin));
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

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'ContID='+IntToStr(ContID)); // �����������

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
end;  // prCreateNewOrderOrd
//*******************************************************************************
procedure prCreateOrderByMarkedOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCreateOrderByMarkedOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS, OrdIBS1, OrdIBS2: TIBSQL;
    UserId, FirmID, OrderID, WareID, CurrencyID, ContID: integer;
    s, ErrorMessage, OrderCode, DivisibleMess: string;
    Ware: TWareInfo;
    Qty: Double;
begin
  if flClientStoragesView_2col then begin
    prCreateOrderByMarkedOrd_2col(Stream, ThreadData);
    exit;
  end;
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  OrdIBS1:= nil;
  OrdIBS2:= nil;
  DivisibleMess:= '';
  ContID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    s:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'Orders='+s+#13#10'ContID='+IntToStr(ContID)); // �����������
    if s='' then  raise EBOBError.Create('�� ������� ������.');

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
    OrdIBS1:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS1_'+nmProc, ThreadData.ID, tpWrite);
    OrdIBS2:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS2_'+nmProc, ThreadData.ID, tpWrite);

    prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, ErrorMessage, ThreadData.ID, OrdIBS);

    if ErrorMessage<>'' then raise EBOBError.Create(ErrorMessage);
    if OrderID<1 then raise Exception.Create('NewOrderID<1');

    OrderCode:= IntToStr(OrderID);
    CurrencyID:= Cache.arClientInfo[UserID].SearchCurrencyID;
    with OrdIBD.DefaultTransaction do if not InTransaction then StartTransaction;
    // ������ ���������� ���� �������
    OrdIBS1.SQL.Text:= 'select rNewOrderLnCode from AddOrderLineQty'+
      '('+OrderCode+', :ORDRLNWARE, 0, :ORDRLNWAREMEASURE, :ORDRLNPRICE, 0, 0)';
    OrdIBS1.Prepare;

    OrdIBS2.SQL.Text:= 'EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', :WareCode, :Storage, :WareQty)';
    OrdIBS2.Prepare;

    OrdIBS.SQL.Text:= 'select sum(OWBSQTY) qty, OWBSSTORAGE, ORDRLNWARE'+   // , ORDRCONTRACT       ???
      ' from ORDERSREESTR left join ORDERSLINES on ORDRLNORDER=ORDRCODE'+
      ' left join ORDERSWAREBYSTORAGES on OWBSORDERLINE=ORDRLNCODE'+
      ' where ORDRFIRM='+IntToStr(FirmID)+' and ORDRCODE in ('+s+') and OWBSQTY>0'+
      ' group by ORDRLNWARE, OWBSSTORAGE order by ORDRLNWARE';
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      WareID:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
      Ware:= Cache.GetWare(WareID, True);
      if not Assigned(Ware) or (Ware=NoWare)
        then raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

      OrdIBS1.ParamByName('ORDRLNWARE').AsInteger       := WareID;       // ��� ������
      OrdIBS1.ParamByName('ORDRLNWAREMEASURE').AsInteger:= Ware.measID;  // ��.���.
      OrdIBS1.ParamByName('ORDRLNPRICE').AsFloat:= Ware.SellingPrice(FirmID, CurrencyID, contID); // ����
      OrdIBS1.ExecQuery;
      OrdIBS1.Close;

      while not OrdIBS.EOF and (OrdIBS.FieldByName('ORDRLNWARE').AsInteger=WareID) do begin
        OrdIBS2.ParamByName('WareCode').AsInteger:= WareID;
        Qty:= OrdIBS.FieldByName('qty').AsFloat;
        s:= fnRecaclQtyByDivisible(WareID, Qty); // ��������� ���������
        OrdIBS2.ParamByName('WareQty').AsFloat:= Qty;
        OrdIBS2.ParamByName('Storage').AsInteger:= OrdIBS.FieldByName('OWBSSTORAGE').AsInteger;
        OrdIBS2.ExecQuery;
        OrdIBS2.Close;
        if s<>'' then DivisibleMess:= DivisibleMess+fnIfStr(DivisibleMess='','',#13#10)+s;
        OrdIBS.Next;
      end;
    end;
    OrdIBS.Close;
    OrdIBD.DefaultTransaction.Commit;
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(OrderID);
    Stream.WriteInt(ContID);
    if DivisibleMess<>'' then
      DivisibleMess:= '� ��������� ������� ���������� ����������� �� ��������� �������.';
    Stream.WriteStr(DivisibleMess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
      fnIfStr(Assigned(OrdIBS), 'OrdIBS.SQL.Text='+OrdIBS.SQL.Text, ''), False);
  end;
  prFreeIBSQL(OrdIBS);
  prFreeIBSQL(OrdIBS1);
  prFreeIBSQL(OrdIBS2);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//*******************************************************************************
procedure prCreateOrderByMarkedOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCreateOrderByMarkedOrd_2col'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, OrderID, WareID, CurrencyID, ContID, SysID: integer;
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
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'Orders='+s+#13#10'ContID='+IntToStr(ContID)); // �����������

    if s='' then  raise EBOBError.Create('�� ������� ������.');
    if not Cache.ClientExist(UserID) then raise EBOBError.Create(MessText(mtkNotClientOfFirm));

    Client:= Cache.arClientInfo[UserID];
    Contract:= Client.GetCliContract(ContID);
    SysID:= Contract.SysID;
    sStore:= IntToStr(Contract.MainStorage);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);

    prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, ErrorMessage, ThreadData.ID, OrdIBS);
    if ErrorMessage<>'' then raise EBOBError.Create(ErrorMessage);
    if OrderID<1 then raise Exception.Create('NewOrderID<1');

    OrderCode:= IntToStr(OrderID);
    CurrencyID:= Client.SearchCurrencyID;
    lst.Add('execute block as declare variable xCode integer; begin');

    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select sum(ORDRLNCLIENTQTY) qty, ORDRLNWARE'+
      ' from ORDERSREESTR left join ORDERSLINES on ORDRLNORDER=ORDRCODE'+
      ' where ORDRFIRM='+IntToStr(FirmID)+' AND ORDRSTATUS='+IntToSTr(orstForming)+
      ' and ORDRCODE in ('+s+') and ORDRLNCLIENTQTY>0 group by ORDRLNWARE order by ORDRLNWARE';
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      WareID:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
      Ware:= Cache.GetWare(WareID, True);
      if not Assigned(Ware) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

      if not ware.CheckWareTypeSys(SysID) then
        raise EBOBError.Create('����� '+ware.Name+' �� ������������� ���������');

      sWare:= OrdIBS.FieldByName('ORDRLNWARE').AsString;
      Qty:= Ware.SellingPrice(FirmID, CurrencyID, contID);
      sPrice:= StringReplace(FloatToStr(Qty), ',', '.', [rfReplaceAll]);
      Qty:= OrdIBS.FieldByName('qty').AsFloat;
      s:= fnRecaclQtyByDivisible(WareID, Qty); // ��������� ���������
      if s<>'' then DivisibleMess:= DivisibleMess+fnIfStr(DivisibleMess='','',#13#10)+s;
      sQty:= StringReplace(FloatToStr(Qty), ',', '.', [rfReplaceAll]);

      lst.Add('select rNewOrderLnCode from AddOrderLineQty('+OrderCode+', '+
        sWare+', 0, '+IntToStr(Ware.measID)+', '+sPrice+', 0, 0) into :xCode;');
      lst.Add('if (xCode is null or xCode<1) then exception NotCorrect "������ ������ ������";');
      lst.Add('EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', '+sWare+', '+sStore+', '+sQty+');');

      OrdIBS.Next;
    end;
    OrdIBS.Close;
    lst.Add(' end');

    OrdIBS.SQL.Clear;
    OrdIBS.ParamCheck:= False;
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.AddStrings(lst);
    sQty:= RepeatExecuteIBSQL(OrdIBS);
    if sQty<>'' then raise Exception.Create(sQty);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(OrderID);
    Stream.WriteInt(ContID);
    if DivisibleMess<>'' then
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
//*******************************************************************************
procedure prJoinMarkedOrdersOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prJoinMarkedOrdersOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    FirmID, i, j: integer;
    s: string;
    codes: Tai;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  setLength(codes, 100);
  try
    Stream.ReadInt;       // UserID
    FirmId:= Stream.ReadInt;
    Stream.ReadInt;       // ContID
    s:= Stream.ReadStr;

    OrdIBD:= cntsORD.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      OrdIBS.SQL.Text:= 'select ORDRCODE, ORDRSTATUS FROM ORDERSREESTR'+
        ' WHERE ORDRFIRM='+IntToStr(FirmID)+' and ORDRCODE in ('+s+')';
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
//*******************************************************************************
procedure prGetOrderListOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetOrderListOrd'; // ��� ���������/�������
var i, ii, UserId, FirmID, Status, sPos, ContID: integer;
    Accounts, Invoices: TDocRecArr;
    s, err, SortOrder, SortDesc, stat, dat, ss, sParam: string;
    DateStart, DateFinish, TestDate, OrdProcDate: TDateTime;
    OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    Client: TClientInfo;
    Contract: TContract;
begin
  Stream.Position:= 0;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  OrdIBS:= nil;
  OrdIBD:= nil;
  ContID:= 0;
  sParam:= '';
  DateStart:= 0;
  DateFinish:= 0;
  Client:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    try
      if not Cache.ClientExist(UserID) then raise EBOBError.Create(MessText(mtkNotClientOfFirm));
      Client:= Cache.arClientInfo[UserID];
      Contract:= Client.GetCliContract(ContID);

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
      sParam:= 'Statuses='+stat+#13#10+
        'DateStart='+FormatDateTime(cDateFormatY2, DateStart)+#13#10+
        'DateFinish='+FormatDateTime(cDateFormatY2, DateFinish)+#13#10+
        'SortOrder='+SortOrder+#13#10+'SortDesc='+SortDesc;
    finally
      prSetThLogParams(ThreadData, 0, UserID, FirmID, sParam); // �����������
    end;

    TestDate:= IncYear(Date, -5);
    dat:= ''; // ������ �� ����
    if DateStart>TestDate  then dat:= dat+' AND ORDRDATE>=:DATESTART';
    if DateFinish>TestDate then dat:= dat+' AND ORDRDATE<=:DATEFINISH';

    s:= ' ORDER BY '+SortOrder+' '+SortDesc+', ORDRDATE '+SortDesc+', ORDRNUM '+SortDesc;

    ss:= 'SELECT ORDRSTATUS, ORDRCODE, ORDRDATE, ORDRNUM, ORDRSUMORDER,'+
         ' ORDRCURRENCY, ORDRTOPROCESSDATE, ORDRCONTRACT'+
         ' from ORDERSREESTR where ORDRFIRM='+IntToStr(FirmID);
    if (stat='') and (dat='') then // ���� ������� �� ������
      ss:= ss+' and (ORDRSTATUS<'+IntToStr(orstClosed)+
              ' or (ORDRSTATUS='+IntToStr(orstClosed)+' and (("TODAY"-ORDRDATE)<7)))'
    else
      ss:= ss+' AND ORDRSTATUS'+fnIfStr(stat='','<>'+IntToStr(orstDeleted),' in ('+stat+')')+dat;

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
    if not (OrdIBS.Bof and OrdIBS.Eof) then begin
      i:= 0;
      while not OrdIBS.EOF do begin
        ii:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
        //------------------------------- ������ �� ����������
        if (ii<1) then s:= ''                                  // �������� �����������
        else if (Client.CliContracts.IndexOf(ii)<0) or         // �������� ����������
          (Client.DocsByCurrContr and (ii<>ContID)) then begin // ������ ������ �� ��������
          OrdIBS.Next;
          Continue;
        end else s:= Client.GetCliContract(ii).Name;

        SetLength(Accounts, 0);
        SetLength(Invoices, 0);
        Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;
        OrdProcDate:= OrdIBS.FieldByName('ORDRTOPROCESSDATE').AsDateTime;
        if ((Status>orstProcessing) and (Status<orstAnnulated)) then begin
          err:= fnGetClosingDocsOrd(OrdIBS.FieldByName('ORDRCODE').AsString, Accounts, Invoices, Status, ThreadData.ID);
          if (err<>'') then raise Exception.Create(err);
        end;
        Stream.WriteInt(Length(Accounts));
        Stream.WriteInt(OrdIBS.FieldByName('ORDRCODE').AsInteger);

        Stream.WriteInt(ii); // ��� ���������
        Stream.WriteStr(s);  // ������� ����� ��������� ��� �����, ���� �����������

        Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
        Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
        Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
        Stream.WriteStr(Cache.GetCurrName(OrdIBS.FieldByName('ORDRCURRENCY').asInteger));
        Stream.WriteStr(arOrderStatusNames[Status]);
        if Status<>orstProcessing then s:= ''
        else s:= ' � '+FormatDateTime(cDateTimeFormatTnD, OrdProcDate);
        Stream.WriteStr(s);
        Stream.WriteStr(FormatDateTime(cDateTimeFormatY2N, OrdProcDate));
        for ii:= Low(Accounts) to High(Accounts) do begin
          if Invoices[ii].Number='' then begin
            Stream.WriteByte(fnIfInt(Accounts[ii].Processed, byte('t'), byte('f'))); // �.�. ���� f -���� �����., ���� t-  ���., ���� ������ - ���������
            Stream.WriteStr('����'+fnIfStr(Accounts[ii].Processed, cWebProcessed, ''));
            Stream.WriteStr('99');
            Stream.WriteStr(IntToStr(Accounts[ii].ID));
            Stream.WriteStr(Cache.GetDprtMainName(Accounts[ii].DprtID));
            Stream.WriteStr(Accounts[ii].Number);
            Stream.WriteStr(Accounts[ii].Commentary);
            Stream.WriteStr(FormatFloat('# ##0.00', Accounts[ii].Summa));
            Stream.WriteStr(Accounts[ii].CurrencyName);
            Stream.WriteStr(FormatDateTime(cDateFormatY2, Accounts[ii].Data));
          end else begin
            Stream.WriteByte(0);//
            Stream.WriteStr('���������');
            Stream.WriteStr('102');
            Stream.WriteStr(IntToStr(Invoices[ii].ID));
            Stream.WriteStr(Cache.GetDprtMainName(Invoices[ii].DprtID));
            Stream.WriteStr(Invoices[ii].Number);
            Stream.WriteStr(Accounts[ii].Commentary);
            Stream.WriteStr(FormatFloat('# ##0.00', Invoices[ii].Summa));
            Stream.WriteStr(Invoices[ii].CurrencyName);
            Stream.WriteStr(FormatDateTime(cDateFormatY2, Invoices[ii].Data));
          end;
        end;
        TestCssStopException;
        OrdIBS.Next;
        Inc(i);
      end;
      Stream.Position:= sPos;
      Stream.WriteInt(i); // �������� ���-�� �����
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
end;
//*******************************************************************************
procedure prShowOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, StorageCount, Status, i, j, spos, LineCount, SysID, contID: integer;
    OrderCode, err, s, s1, UserMessage: string;
    Accounts, Invoices: TDocRecArr;
    Storages: TaSD;
    Ware: TWareInfo;
    HasAnalogs: Boolean;
    anw: Tai;
    qty, price: Double;
begin
  if flClientStoragesView_2col then begin
    prShowOrderOrd_2col(Stream, ThreadData);
    exit;
  end;
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  contID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID,FirmID, 'OrderCode='+OrderCode); // �����������
    try
      i:= StrToInt(OrderCode);
      if i<1 then raise Exception.Create('');
    except
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    end;
    if not Cache.FirmExist(FirmId) then raise EBOBError.Create(MessText(mtkNotFirmExists));

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT  ORDRSTATUS, ORDRNUM, ORDRGBACCNUMBER, ORDRDATE,'+
      ' ORDRSUMORDER, ORDRCURRENCY, ORDRACCOUNTINGTYPE, ORDRDELIVERYTYPE,'+
      ' ORDRTOPROCESSDATE, ORDRCREATORPERSON, ORDRTOPROCESSPerson, ORDRWARRANT,'+
      ' ORDRWARRANTDATE, ORDRWARRANTPERSON, ORDRSTORAGECOMMENT,'+
      ' ORDRANNULATEDATE, ORDRANNULATEREASON, ORDRCONTRACT'+
      ' from ORDERSREESTR where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;

    if ((Status>orstProcessing) and (Status<orstAnnulated)) then begin
      err:= fnGetClosingDocsOrd(OrderCode, Accounts, Invoices, Status, ThreadData.ID);
      if (err<>'') then raise Exception.Create(err);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
//    Stream.WriteStr(OrdIBS.FieldByName('ORDRCONTRACT').AsString);   // ��� ���������
    Stream.WriteStr(OrdIBS.FieldByName('ORDRGBACCNUMBER').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
    Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
    Stream.WriteStr(Cache.GetCurrName(OrdIBS.FieldByName('ORDRCURRENCY').asInteger));
    Stream.WriteStr(OrdIBS.FieldByName('ORDRACCOUNTINGTYPE').AsString);
    Stream.WriteInt(ord(OrdIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger<>0));
    Stream.WriteInt(Status);
    Stream.WriteStr(arOrderStatusDecor[Status].StatusName);
    if Status=orstProcessing then s:= ' � '+
      FormatDateTime(cDateTimeFormatTnD, OrdIBS.FieldByName('ORDRTOPROCESSDATE').AsDateTime)
    else s:= '';
    Stream.WriteStr(s);

    Stream.WriteStr('');      // ORDRTOTALWEIGHT

    // �������� ��������� ������ � ����������� �� ����������
    i:= OrdIBS.FieldByName('ORDRCREATORPERSON').AsInteger;
    if (i=0) or not Cache.ClientExist(i) then s:= ''
    else s:= fnCutFIO(Cache.arClientInfo[i].Name);
    Stream.WriteStr(s);

    j:= OrdIBS.FieldByName('ORDRTOPROCESSPerson').AsInteger;
    if (j<>i) then
      if (j=0) or not Cache.ClientExist(j) then s:= ''
      else s:= fnCutFIO(Cache.arClientInfo[j].Name);
    Stream.WriteStr(s);

    Stream.WriteStr(fnIfStr(Cache.arClientInfo[UserID].NOTREMINDCOMMENT, 'true', 'false'));
    Stream.WriteStr(OrdIBS.FieldByName('ORDRWARRANT').AsString);
    Stream.WriteDouble(OrdIBS.FieldByName('ORDRWARRANTDATE').AsDateTime);
    Stream.WriteStr(OrdIBS.FieldByName('ORDRWARRANTPERSON').AsString);
    Stream.WriteStr(OrdIBS.FieldByName('ORDRSTORAGECOMMENT').AsString);

    if Status=orstAnnulated then s:= '����������� '+
      FormatDateTime(cDateTimeFormatY2N, OrdIBS.FieldByName('ORDRANNULATEDATE').AsDateTime)+
      ' ������� ���������: '+OrdIBS.FieldByName('ORDRANNULATEREASON').AsString
    else s:= '';
    contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
    OrdIBS.Close;
    Stream.WriteStr(s);

    SysID:= Cache.arFirmInfo[FirmId].GetContract(contID).SysID;

    StorageCount:= 0;   // +++ ��������� ������ ����� ������� �������
    s:= '';
    s1:= '';
    if Status=orstForming then begin // ���� ����� �� ������ ������������
      Storages:= fnGetStoragesArray(UserId, FirmId, true, contID);
      StorageCount:= Length(Storages);
      prSendStorages(Storages, Stream);
      for i:= 0 to StorageCount-1 do with Storages[i] do if IsReserve then begin
        s:= s +', s'+Code+'.OWBSQTY Qty'+Code;
        s1:= s1 +' left join ORDERSWAREBYSTORAGES s'+Code+' on s'+Code+
             '.OWBSORDERLINE=OL.ORDRLNCODE and s'+Code+'.OWBSSTORAGE='+Code;
      end;
    end;
    LineCount:= 0;            // ������� - ���-�� �����
    sPos:= Stream.Position;
    Stream.WriteInt(0); //  ����� ��� ���-�� �����

    OrdIBS.SQL.Text:= 'SELECT OL.ORDRLNWARE, OL.ORDRLNCODE, OL.ORDRLNCLIENTQTY, OL.ORDRLNPRICE'+s+
      ' FROM ORDERSLINES OL'+s1+' where ORDRLNORDER='+OrderCode;
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      i:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
      qty:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
      price:= OrdIBS.FieldByName('ORDRLNPRICE').AsFloat;

      Ware:= Cache.GetWare(i);
      if not Assigned(Ware) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));
      Stream.WriteInt(OrdIBS.FieldByName('ORDRLNCODE').AsInteger);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRLNWARE').AsString);

      anw:= fnGetAllAnalogs(i, -1, SysID);
      HasAnalogs:= Length(anw)>0;
      SetLength(anw, 0);

      Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));

      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteDouble(qty);
      for j:= 0 to StorageCount-1 do with Storages[j] do if IsReserve then
            // ���� ����� �������� ��� ��������������, �� �������� ������� ���-�� ������
        Stream.WriteStr(trim(FormatFloat('###0.#', OrdIBS.FieldByName('QTY'+Code).AsFloat)));

      Stream.WriteStr(Ware.MeasName);
      Stream.WriteStr(FormatFloat('# ##0.00', price));
      Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(price*qty)));
      inc(LineCount);
      TestCssStopException;
      OrdIBS.Next;
    end;
    OrdIBS.Close;

    Stream.Position:= sPos;
    Stream.WriteInt(LineCount);
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
    Stream.WriteStr(UserMessage);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(anw, 0);
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  SetLength(Storages, 0);
end;  //prShowOrderOrd
//************************************************** �������� ������ - 2 �������
procedure prShowOrderOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowOrderOrd_2col'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, Status, i, j, spos, LineCount, SysID, contID, MainStore: integer;
    OrderCode, err, s, s1, UserMessage, sLine, sStore: string;
    Accounts, Invoices: TDocRecArr;
    Storages: TaSD;
    Ware: TWareInfo;
    HasAnalogs, CheckStores: Boolean;
    anw: Tai;
    qty, qtyM, price: Double;
    arlstSQL: TASL;
    Contract: TContract;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
//  OrdIBD:= nil;
  SetLength(Accounts, 0);
  SetLength(Invoices, 0);
  SetLength(arlstSQL, 1);
  arlstSQL[0]:= TStringList.Create;
  contID:= 0;
  sPos:= 0;
  LineCount:= 0;            // ������� - ���-�� �����
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID,FirmID, 'OrderCode='+OrderCode); // �����������
    try
      i:= StrToInt(OrderCode);
      if i<1 then raise Exception.Create('');
    except
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    end;
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Contract:= Cache.arClientInfo[UserID].GetCliContract(contID);
    SysID:= Contract.SysID;
    MainStore:= Contract.MainStorage;

    OrdIBD:= cntsORD.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      OrdIBS.SQL.Text:= 'SELECT  ORDRSTATUS, ORDRNUM, ORDRGBACCNUMBER, ORDRDATE,'+
        ' ORDRSUMORDER, ORDRCURRENCY, ORDRACCOUNTINGTYPE, ORDRDELIVERYTYPE,'+
        ' ORDRTOPROCESSDATE, ORDRCREATORPERSON, ORDRTOPROCESSPerson, ORDRWARRANT,'+
        ' ORDRWARRANTDATE, ORDRWARRANTPERSON, ORDRSTORAGECOMMENT,'+
        ' ORDRANNULATEDATE, ORDRANNULATEREASON, ORDRCONTRACT'+
        ' from ORDERSREESTR where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId);
      OrdIBS.ExecQuery;
      if OrdIBS.Bof and OrdIBS.Eof then
        raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

      Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;
      if ((Status>orstProcessing) and (Status<orstAnnulated)) then begin
        err:= fnGetClosingDocsOrd(OrderCode, Accounts, Invoices, Status, ThreadData.ID);
        if (err<>'') then raise Exception.Create(err);
      end;

      if (OrdIBS.FieldByName('ORDRCONTRACT').AsInteger<1) then begin
        arlstSQL[0].Add('update ORDERSREESTR set ORDRCONTRACT='+IntToStr(contID));
        arlstSQL[0].Add('where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId)+';');
      end else if (contID<>OrdIBS.FieldByName('ORDRCONTRACT').AsInteger) then
         raise EBOBError.Create('����� �� ������������� �������� ���������');

      CheckStores:= (Status=orstForming);

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRGBACCNUMBER').AsString);
      Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
      Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
      Stream.WriteStr(Cache.GetCurrName(OrdIBS.FieldByName('ORDRCURRENCY').asInteger));
      Stream.WriteStr(OrdIBS.FieldByName('ORDRACCOUNTINGTYPE').AsString);
      Stream.WriteInt(ord(OrdIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger<>0));
      Stream.WriteInt(Status);
      Stream.WriteStr(arOrderStatusDecor[Status].StatusName);
      if Status=orstProcessing then s:= ' � '+
        FormatDateTime(cDateTimeFormatTnD, OrdIBS.FieldByName('ORDRTOPROCESSDATE').AsDateTime)
      else s:= '';
      Stream.WriteStr(s);

      Stream.WriteStr('');      // ORDRTOTALWEIGHT

      // �������� ��������� ������ � ����������� �� ����������
      i:= OrdIBS.FieldByName('ORDRCREATORPERSON').AsInteger;
      if (i=0) or not Cache.ClientExist(i) then s:= ''
      else s:= fnCutFIO(Cache.arClientInfo[i].Name);
      Stream.WriteStr(s);

      j:= OrdIBS.FieldByName('ORDRTOPROCESSPerson').AsInteger;
      if (j<>i) then
        if (j=0) or not Cache.ClientExist(j) then s:= ''
        else s:= fnCutFIO(Cache.arClientInfo[j].Name);
      Stream.WriteStr(s);

      Stream.WriteStr(fnIfStr(Cache.arClientInfo[UserID].NOTREMINDCOMMENT, 'true', 'false'));
      Stream.WriteStr(OrdIBS.FieldByName('ORDRWARRANT').AsString);
      Stream.WriteDouble(OrdIBS.FieldByName('ORDRWARRANTDATE').AsDateTime);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRWARRANTPERSON').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRSTORAGECOMMENT').AsString);

      if Status=orstAnnulated then s:= '����������� '+
        FormatDateTime(cDateTimeFormatY2N, OrdIBS.FieldByName('ORDRANNULATEDATE').AsDateTime)+
        ' ������� ���������: '+OrdIBS.FieldByName('ORDRANNULATEREASON').AsString
      else s:= '';
      OrdIBS.Close;
      Stream.WriteStr(s);
      s:= '';
      s1:= '';
      sStore:= '';
      if Status=orstForming then begin // ���� ����� �� ������ ������������
        Storages:= fnGetStoragesArray_2col(Contract, true, True);
        prSendStorages(Storages, Stream);
        s:= s +', OWBSQTY QtyMain';
        sStore:= IntToStr(MainStore);
        s1:= s1 +' left join ORDERSWAREBYSTORAGES on '+
             'OWBSORDERLINE=OL.ORDRLNCODE and OWBSSTORAGE='+sStore;
      end;

      sPos:= Stream.Position;
      Stream.WriteInt(0); //  ����� ��� ���-�� �����

      OrdIBS.SQL.Text:= 'SELECT OL.ORDRLNWARE, OL.ORDRLNCODE, OL.ORDRLNCLIENTQTY, OL.ORDRLNPRICE'+s+
        ' FROM ORDERSLINES OL'+s1+' where ORDRLNORDER='+OrderCode;
      OrdIBS.ExecQuery;
      j:= 0;
      while not OrdIBS.EOF do begin
        i:= OrdIBS.FieldByName('ORDRLNWARE').AsInteger;
        qty:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
        price:= OrdIBS.FieldByName('ORDRLNPRICE').AsFloat;

        Ware:= Cache.GetWare(i);
        if not Assigned(Ware) or (Ware=NoWare) then
          raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));
        Stream.WriteInt(OrdIBS.FieldByName('ORDRLNCODE').AsInteger);
        Stream.WriteStr(OrdIBS.FieldByName('ORDRLNWARE').AsString);

        anw:= fnGetAllAnalogs(i, -1, SysID);
        HasAnalogs:= Length(anw)>0;
        SetLength(anw, 0);
        Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));

        Stream.WriteStr(Ware.WareBrandName);
        Stream.WriteStr(Ware.Name);
        Stream.WriteDouble(qty);

        if Status=orstForming then begin                // ���� ����� �� ������ ������������ -
          qtyM:= OrdIBS.FieldByName('QtyMain').AsFloat; // ������ � ���������� �� ������� �����
          if (qtyM<>qty) then begin
            sLine:= OrdIBS.FieldByName('ORDRLNCODE').AsString;
            if (arlstSQL[j].Count>240) then begin
              inc(j);
              SetLength(arlstSQL, j+1);
              arlstSQL[j]:= TStringList.Create;
            end;
            if (qtyM<1) then begin
              arlstSQL[j].Add('insert into ORDERSWAREBYSTORAGES (OWBSORDERLINE, OWBSSTORAGE, OWBSQTY)');
              arlstSQL[j].Add('values ('+sLine+', '+sStore+', (select ORDRLNCLIENTQTY');
              arlstSQL[j].Add('  from ORDERSLINES where ORDRLNCODE='+sLine+'));');
            end else begin
              arlstSQL[j].Add('update ORDERSWAREBYSTORAGES set OWBSQTY=');
              arlstSQL[j].Add(' (select ORDRLNCLIENTQTY from ORDERSLINES where ORDRLNCODE='+sLine+')');
              arlstSQL[j].Add('  where OWBSORDERLINE='+sLine+' and OWBSSTORAGE='+sStore+';');
            end;
            arlstSQL[j].Add('delete from ORDERSWAREBYSTORAGES');
            arlstSQL[j].Add('  where OWBSORDERLINE='+sLine+' and OWBSSTORAGE<>'+sStore+';');
            qtyM:= qty;
          end; // if (qtyM<>qty)
          Stream.WriteStr(trim(FormatFloat('###0.#', qtyM))); // �������� ������� ���-�� ������
        end;

        Stream.WriteStr(Ware.MeasName);
        Stream.WriteStr(FormatFloat('# ##0.00', price));
        Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(price*qty)));
        inc(LineCount);
        TestCssStopException;
        OrdIBS.Next;
      end; // while not OrdIBS.EOF
      OrdIBS.Close;

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
    Stream.WriteInt(LineCount);
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
    Stream.WriteStr(UserMessage);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(anw, 0);
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
    UserId, FirmID, Status, spos, LineCount, i, SysID, contID: integer;
    OrderCode, AccType, s: string;
    Curr, sum: Double;
    Ware: TWareInfo;
    HasAnalogs: Boolean;
    ar: Tai;
    Contract: TContract;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  contID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderID='+OrderCode); // �����������
    try
      spos:= StrToInt(OrderCode);
      if spos<1 then raise Exception.Create('');
    except
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    end;
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Contract:= Cache.arClientInfo[UserID].GetCliContract(contID);
    SysID:= Contract.SysID;

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRNUM, ORDRACCOUNTINGTYPE, ORDRGBACCNUMBER,'+
      ' ORDRDATE, ORDRSUMORDER, ORDRDELIVERYTYPE, ORDRSTATUS, ORDRTOPROCESSDATE,'+
      ' ORDRANNULATEDATE, ORDRANNULATEREASON, ORDRCONTRACT from ORDERSREESTR'+
      ' where ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));

    if (OrdIBS.FieldByName('ORDRCONTRACT').AsInteger>0) and
      (contID<>OrdIBS.FieldByName('ORDRCONTRACT').AsInteger) then
      raise EBOBError.Create('����� �� ������������� �������� ���������');

    AccType:= OrdIBS.FieldByName('ORDRACCOUNTINGTYPE').AsString;
    Curr:= Cache.CURRENCYRATE;
    sum := OrdIBS.FieldByName('ORDRSUMORDER').AsFloat;
    sum := RoundToHalfDown(fnIfDouble(AccType='0', sum*Curr, sum/Curr));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
    Stream.WriteStr(OrdIBS.FieldByName('ORDRGBACCNUMBER').AsString); // ���������� ����� ����� �� ������
    Stream.WriteStr(FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
    Stream.WriteStr(FormatFloat('# ##0.00', sum));
    Stream.WriteStr(fnIfStr(AccType='0', '���.', '�.�.'));
    Stream.WriteStr(AccType);
    Stream.WriteInt(ord(OrdIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger<>0));
    Status:= OrdIBS.FieldByName('ORDRSTATUS').AsInteger;
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

    LineCount:= 0;            // ������� - ���-�� �����
    sPos:= Stream.Position;
    Stream.WriteInt(0); //  ����� ��� ���-�� �����

    OrdIBS.Close;
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

      ar:= fnGetAllAnalogs(i, -1, SysID);
      HasAnalogs:= Length(ar)>0;
      SetLength(ar, 0);

      Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteDouble(OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat);
      Stream.WriteStr(Ware.MeasName);

      sum:= OrdIBS.FieldByName('ORDRLNPRICE').AsFloat;
      sum:= RoundToHalfDown(fnIfDouble(AccType='0', sum*Curr, sum/Curr));
      Stream.WriteStr(FormatFloat('# ##0.00', sum));

      sum:= sum*OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
      Stream.WriteStr(FormatFloat('# ##0.00', sum));

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
  SetLength(ar, 0);
  Stream.Position:= 0;
end;  //prShowACOrderOrd
//**************************************************** �������� ������ �� ������
procedure prDelLineFromOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prDelLineFromOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID: integer;
    j: integer;
    OrderCode, LineID, s: string;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    LineID:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderId='+OrderCode+#13#10+'LineID='+LineID); // �����������
    try
      j:= StrToInt(OrderCode);
      if j<1 then raise Exception.Create('');
    except
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
    end;

    OrdIBD:= cntsORD.GetFreeCnt;      // ������ ���������, ���������� �� ����� �����
    OrdIBS:= fnCreateNewIBSQL(OrdIBD,'OrdIBS_'+nmProc,ThreadData.ID, tpRead, true);
    OrdIBS.SQL.Text:= 'SELECT ORDRFIRM, ORDRSTATUS from ORDERSREESTR where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundOrder));
    // ����� ���������, ����� �� ����� �������������
    if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger>orstForming)  then
      raise EBOBError.Create(MessText(mtkNotEditOrder));
    // ����� ���������, ����� �� ����� ���� ������� ������������� ���� �����
    if OrdIBS.FieldByName('ORDRFIRM').AsInteger<>FirmID then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    OrdIBS.Close;

    // ����� ��� ���������, ������� ������
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.Text:= 'execute procedure DelOrderLine('+LineID+')';
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(MessText(mtkErrDelRecord)+': '+s);

    // �������� ����� ����� ����� � ������
    fnSetTransParams(OrdIBS.Transaction, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRSUMORDER, ORDRCURRENCY from ORDERSREESTR where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
    Stream.WriteStr(Cache.GetCurrName(OrdIBS.FieldByName('ORDRCURRENCY').asInteger));
    OrdIBS.Close;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end; 
//******************************************************************************
procedure prChangeQtyInOrderLineOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prChangeQtyInOrderLineOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, i, WareID, contID: integer;
    OrderCode, WareCode, Qty, s, StorageCode, UserMessage: string;
    QtyD: double;
    Storages: TaSD;
    Contract: TContract;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  UserMessage:='';
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    WareCode:= Stream.ReadStr;
    OrderCode:= Stream.ReadStr;
    Qty:= Stream.ReadStr;
    QtyD:= StrToFloatDef(Qty, 0);
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderId='+OrderCode+
      #13#10'WareCode='+WareCode+#13#10'Qty='+Qty); // �����������

    i:= Pos('_', WareCode);
    if (i>0) then begin
      StorageCode:= Copy(WareCode, i+1, 10000);
      WareCode:= Copy(WareCode, 1, i-1);
    end else raise Exception.Create('������ �������� ����� ������ � ������.');
    WareID:= StrToIntDef(WareCode, 0);

    if not Cache.WareExist(WareID) or Cache.GetWare(WareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, WareCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    s:= fnRecaclQtyByDivisibleEx(WareID, QtyD);   // ��������� ���������
    if (s<>'') then raise EBOBError.Create(s);

    OrdIBD:= cntsORD.GetFreeCnt; // ������ ���������, ���������� �� ����� �����
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);
    OrdIBS.SQL.Text:= 'SELECT ORDRFIRM, ORDRSTATUS, ORDRCONTRACT, ORDRLNCODE from ORDERSREESTR'+
      ' left join ORDERSLINES on ORDRLNORDER=ORDRCODE and ORDRLNWARE='+WareCode+
      ' where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder));
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
    OrdIBS.Close;

    with Cache.arFirmInfo[FirmID] do begin // ��������� ����������� ���������
      if not CheckContract(contID) then
        contID:= Cache.arClientInfo[UserID].LastContract;
      Contract:= GetContract(contID);
    end;

    if flClientStoragesView_2col then begin  // 2 �������
      i:= StrToInt(StorageCode);
      if (i<>Contract.MainStorage) then
        raise EBOBError.Create('�� ������ ����� ��� ��������������');
    end else begin
      i:= Contract.Get�ontStoreIndex(StrToInt(StorageCode));
      if i<0 then raise EBOBError.Create('�� ������ ����� ��� ��������������');
      if not Contract.ContStorages[i].IsReserve then
        raise EBOBError.Create('������ ������������� ����� �� ���� ������.');
    end;

    // ����� ��� ���������, ����������� ������
    fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
    OrdIBS.SQL.Text:= 'EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', '+WareCode+', '+ StorageCode+', :Qty)';
    OrdIBS.ParamByName('Qty').AsFloat:= QtyD;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);

    // ������������� ������, ����� �������� ����� �����
    fnSetTransParams(OrdIBS.Transaction, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRSUMORDER, ORDRCURRENCY,'+
      ' ORDRLNCLIENTQTY, ORDRLNPRICE from ORDERSREESTR'+
      ' left join ORDERSLINES on ORDRLNORDER=ORDRCODE and ORDRLNWARE='+WareCode+
      ' where ORDRCODE='+OrderCode;
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundRecord));
    if OrdIBS.FieldByName('ORDRLNCLIENTQTY').IsNull then
      raise Exception.Create(MessText(mtkNotValidParam));
  // � �������� �� � CGI-������
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(FormatFloat('# ##0.#', QtyD));
    QtyD:= OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
    Stream.WriteStr(FormatFloat('# ##0.#', QtyD));
    Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(OrdIBS.FieldByName('ORDRLNPRICE').AsFloat*QtyD)));
    Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
    Stream.WriteStr(Cache.GetCurrName(OrdIBS.FieldByName('ORDRCURRENCY').asInteger));
    Stream.WriteStr(UserMessage);
    OrdIBS.Close;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(Storages, 0);
end;
//************************************************* �������� ������ �� ���������
procedure prSendOrderToProcessingOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendOrderToProcessingOrd'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserId, FirmID, i, ContID: integer;
    OrderCode, ErrorPos, WrongWares: string;
    Qty: double;
    firma: TFirmInfo;
    Contract: TContract;
begin
  Stream.Position:= 0;
  IBS:= nil;
  WrongWares:= '';
  ContID:= 0;
  try
ErrorPos:='1';
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
//    ContID:= Stream.ReadInt; // ��� ���������� - ����� �� �����
    OrderCode:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderId='+OrderCode); // �����������

    if OrderCode='' then raise EBOBError.Create(MessText(mtkNotFoundOrder));
    if CheckNotValidUser(UserID, FirmID, WrongWares) then raise EBOBError.Create(WrongWares);
    firma:= Cache.arFirmInfo[FirmId];

ErrorPos:='2';
    IBD:= cntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'SELECT ORDRFIRM, ORDRCURRENCY, ORDRSTATUS, ORDRWARRANTDATE,'+
        ' ORDRCONTRACT from ORDERSREESTR where ORDRCODE='+OrderCode;
      IBS.ExecQuery;  // ������ ���������, ���������� �� ����� �����
      if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder));
      // ����� ���������, ����� �� ����� ���������� �� ���������
      if (IBS.FieldByName('ORDRSTATUS').AsInteger>orstForming)  then
        raise EBOBError.Create(MessText(mtkNotProcOrder));
      // ����� ���������, ����� �� ����� ���� ������� ���������� �� ��������� ������ �����
      if IBS.FieldByName('ORDRFIRM').AsInteger<>FirmID then
        raise EBOBError.Create(MessText(mtkNotRightExists));
      // ����� ��������� ���������� ���� ������������
      if (IBS.FieldByName('ORDRCURRENCY').AsInteger=1) and
         (IBS.FieldByName('ORDRWARRANTDATE').AsDateTime>constDeltaZero) and
         ((Date-IBS.FieldByName('ORDRWARRANTDATE').AsDateTime)>(WarrantValidTerm-1)) then
          raise EBOBError.Create('������������ ����������. ������� ���������� ������������'+
            ' ��� ������� ������ � ������������ �� ������.');

      if (contID<1) then contID:= IBS.FieldByName('ORDRCONTRACT').AsInteger;
      IBS.Close;

      Contract:= firma.GetContract(contID);

      if Contract.IsEnding then // �������� �� ��������� ���������
        raise EBOBError.Create('�������� '+Contract.Name+' ������');

ErrorPos:='3';
     // ��������� ������� ����������� ������� � �� ������ �� ��� �����
      Qty:= 0;
      IBS.SQL.Text:= 'SELECT ORDRLNWARE, ORDRLNCLIENTQTY'+ //, ORDRLNWareCountRequestCode'+
                     ' from ORDERSLINES where ORDRLNORDER='+OrderCode;
      IBS.ExecQuery;
      if (IBS.Bof and IBS.Eof) then raise EBOBError.Create(MessText(mtkNotProcOrder));
      while not IBS.EOF do begin
        i:= IBS.FieldByName('ORDRLNWARE').AsInteger;
        if not Cache.CheckWareAndFirmEqualSys(i, FirmID, contID) then
          WrongWares:= fnIfStr(WrongWares='', '', ', ')+Cache.GetWare(i).Name
       else Qty:= Qty+IBS.FieldByName('ORDRLNCLIENTQTY').AsFloat;
        TestCssStopException;
        IBS.Next;
      end; // while not IBS.EOF
      IBS.Close;
      if (WrongWares<>'') then raise EBOBError.Create('��� ��������� '+Contract.Name+
        ' ('+Contract.SysName+') ���������� ������: '+WrongWares+
        '\n����� ��������� ������ �� ��������� ������� ��� ������');
      if not fnNotZero(Qty) then raise EBOBError.Create(MessText(mtkNotProcOrder)+' - ��� �������');
ErrorPos:='4';
      // ����� ��� ���������, ������ ������
      fnSetTransParams(IBS.Transaction, tpWrite, True);
      IBS.SQL.Text:= 'UPDATE ORDERSREESTR SET ORDRSTATUS='+IntToStr(orstProcessing)+
        ', ORDRTOPROCESSPerson='+IntToStr(UserId)+
        ', ORDRTOPROCESSDATE="NOW" WHERE ORDRCODE='+OrderCode;
      WrongWares:= RepeatExecuteIBSQL(IBS);
      if WrongWares<>'' then raise Exception.Create(WrongWares);
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;

ErrorPos:='7';
    Stream.Clear;
    if firma.SKIPPROCESSING then begin
      Stream.WriteInt(StrToInt(OrderCode));
      prOrderToGBn_Ord(Stream, ThreadData, True);
    end else Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do
      prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, True);
    on E: Exception do
      prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, False);
  end;
  Stream.Position:= 0;
end;
//******************************************************************************
procedure prRefreshPricesOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prRefreshPricesOrd'; // ��� ���������/�������
var OrderCode, SResult, s: string;
    UserID, FirmID: integer;
begin
  SResult:= '';
  Stream.Position:= 0;
  try
    OrderCode:= Stream.ReadStr;
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderId='+OrderCode+
      ' UserID='+IntToStr(UserID)+' FirmID='+IntToStr(FirmID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    s:= fnRefreshPriceInOrderOrd(SResult, OrderCode, '', ThreadData);
    if (s<>'') then // ���� ������� ����������� � ������� - ���������� ������
      if copy(s, 1, 3)='EB:' then EBOBError.Create(copy(s, 4, length(s)))
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
function fnRefreshPriceInOrderOrd(var SResult: string; OrderCode: string;
         acctype: string=''; ThreadData: TThreadData=nil): string;
const nmProc = 'fnRefreshPriceInOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    CurPrice: Double;
    OrderID, FirmID, CurrencyOld, i, j, AccTypeOld, AccTypeNew, CurrencyNew, contID: integer;
    ChangeCodes: Tai;
    ChangePrices: TDoubleDynArray;
    s: string;
    fltype: Boolean;
begin
  Result:= '';
  setLength(ChangeCodes, 0);
  setLength(ChangePrices, 0);
  OrdIBS:= nil;
  OrdIBD:= nil;
  OrderID:= StrToIntDef(OrderCode, -1);
  CurrencyNew:= 1;
  j:= 0;
  try
    if OrderID<1 then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
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

      //  �������� ����� ��� ��������� ���� ����� (����� �� prSetOrderPayTypeOrd)
      if (acctype='') then AccTypeNew:= -1 else AccTypeNew:= StrToIntDef(acctype, -1);
      fltype:= (AccTypeNew>-1);
      if fltype then begin
        if AccTypeNew<>1 then CurrencyNew:= cDefCurrency;
        fltype:= (AccTypeNew<>AccTypeOld) or (CurrencyNew<>CurrencyOld);
      end;
      if fltype then begin
        fnSetTransParams(OrdIBS.Transaction, tpWrite, True);
        OrdIBS.SQL.Text:= 'Update ORDERSREESTR set ORDRACCOUNTINGTYPE=:ORDRACCOUNTINGTYPE,'+
          'ORDRCURRENCY=:ORDRCURRENCY WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
        OrdIBS.ParamByName('ORDRACCOUNTINGTYPE').AsInteger:= AccTypeNew;
        OrdIBS.ParamByName('ORDRCURRENCY').AsInteger:= CurrencyNew;
        s:= RepeatExecuteIBSQL(OrdIBS);
        if s<>'' then raise Exception.Create(s);
        fnSetTransParams(OrdIBS.Transaction, tpRead, True);
      end
      else CurrencyNew:= CurrencyOld;

      OrdIBS.SQL.Text:= 'select ORDRLNWARE, ORDRLNPRICE, ORDRLNCODE'+
        ' from ORDERSLINES where ORDRLNORDER='+OrderCode;
      OrdIBS.ExecQuery;
      j:= 0; // �������
      while not OrdIBS.EOF do begin
        CurPrice:= Cache.GetWare(OrdIBS.FieldByName('ORDRLNWARE').AsInteger).SellingPrice(FirmID, CurrencyNew, contID);
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
    prSetThLogParams(ThreadData, 0, UserID, FirmID, ''); // �����������

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRNUM FROM ORDERSREESTR WHERE ORDRSTATUS='+ // ������� ORDRNUM
      IntToStr(orstForming)+' and ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      s:= fnRefreshPriceInOrderOrd(SResult, OrdIBS.FieldByName('ORDRCODE').AsString);
      if (s<>'') then                               // �������� ��� ������
        sErr:= sErr+fnIfStr(sErr='', '', #13#10)+OrdIBS.FieldByName('ORDRNUM').AsString+' '+s;
      TestCssStopException;
      Inc(iCount);
      OrdIBS.Next;
    end;
    OrdIBS.Close;
    if iCount<1 then raise EBOBError.Create('�� ������� �������������� ������.');
    if sErr<>'' then raise Exception.Create(sErr);   // ���� ���� ������

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
//******************************************************************************
procedure prEditOrderHeaderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prEditOrderHeaderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID: integer;
    OrderCode: string;
    s1,s2,s3,s: string;
    d: double;
begin
  Stream.Position:= 0;
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    s1:= Stream.ReadStr;
    s2:= Stream.ReadStr;
    d:= Stream.ReadDouble;
    s3:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderId='+OrderCode+#13#10+
      'ORDRWARRANT='+s1+#13#10+'ORDRWARRANTPERSON='+s2+#13#10+     // �����������
      'ORDRWARRANTDATE='+FormatDateTime(cDateTimeFormatY2S, d)+#13#10+'ORDRSTORAGECOMMENT='+s3);

    if ((s1+s2+s3)='') and (d=0) then raise EBOBError.Create(MessText(mtkNotFoundData));

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
// ����  �����
    OrdIBS.SQL.Text:= 'Select ORDRSTATUS FROM ORDERSREESTR'+
      ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then
      raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderCode));
// ����� ���������, ����� �� ����� �������������
    if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming) then
      raise EBOBError.Create(MessText(mtkNotEditOrder));
    OrdIBS.Close;

    s:= '';
    if s1<>'' then s:= 'ORDRWARRANT=:ORDRWARRANT';
    if s2<>'' then s:= s+fnIfStr(s='','',',')+'ORDRWARRANTPERSON=:ORDRWARRANTPERSON';
    if d>0    then s:= s+fnIfStr(s='','',',')+'ORDRWARRANTDATE=:ORDRWARRANTDATE';
    if s3<>'' then s:= s+fnIfStr(s='','',',')+'ORDRSTORAGECOMMENT=:ORDRSTORAGECOMMENT';
    if s='' then raise EBOBError.Create(MessText(mtkNotFoundData));

    OrdIBS.SQL.Text:=  'Update ORDERSREESTR set '+s+
      ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmID);
    if s1<>'' then OrdIBS.ParamByName('ORDRWARRANT').AsString:= s1;
    if s2<>'' then OrdIBS.ParamByName('ORDRWARRANTPERSON').AsString:= s2;
    if d>0    then OrdIBS.ParamByName('ORDRWARRANTDATE').AsDateTime:= d;
    if s3<>'' then OrdIBS.ParamByName('ORDRSTORAGECOMMENT').AsString:= s3;
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
end;  //prEditOrderHeaderOrd
//******************************************************************************
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
//  contID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    SortOrder:= Stream.ReadStr;
    SortDesc:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'SortOrder='+SortOrder+#13#10+'SortDesc='+SortDesc); // �����������

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
      ' rCLIENTCOMMENT, rPInvCrnc DCACCRNCCODE, rPInvLocked PInvLocked, rContCode'+
      ' from Vlad_CSS_GetFirmReserveDocs('+IntToStr(FirmID)+', '+
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
      Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('DCACCRNCCODE').AsInteger));
      Stream.WriteStr(s);  // ������������ ���������

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
    UserId, FirmID, spos, LineCount, i: integer;
    AccountCode, Summa, s: string;
    Ware: TWareInfo;
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
    AccountCode:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'AccountID='+AccountCode); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserID];
    s:= fnIntegerListToStr(Client.CliContracts); // TIntegerList - � ������ ����� �������

    GBIBD:= cntsGRB.GetFreeCnt;
    GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
    GBIBS.SQL.Text:= 'SELECT PInvNumber aNUMBER, PInvDate aDATE, PInvProcessed aPROCESSED,'+
      ' PInvSupplyDprtCode aDPRTCODE, PINVCLIENTCOMMENT aClientComment, PInvSumm aSUMM,'+
      ' PInvCrncCode aCRNCCODE from PayInvoiceReestr where PInvCode='+AccountCode+
      ' and PInvRecipientCode='+IntToStr(FirmId)+' and PINVCONTRACTCODE in ('+s+')';
    GBIBS.ExecQuery;
    if GBIBS.Bof and GBIBS.Eof then
      raise EBOBError.Create('�� ������ ���� � id='+AccountCode);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(GBIBS.FieldByName('aNUMBER').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('aDATE').AsDateTime));
    Stream.WriteStr(fnIfStr(GetBoolGB(GBibs, 'aPROCESSED'), '���������', '�� ���������')+
      ', ����� �������������� "'+Cache.GetDprtMainName(GBIBS.FieldByName('aDPRTCODE').AsInteger)+'"');

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, True);
    OrdIBS.SQL.Text:= 'SELECT ORDRCODE, ORDRNUM, ORDRDATE from ORDERSREESTR'+
      ' where ORDRGBACCCODE='+AccountCode+' AND ORDRFIRM='+IntToStr(FirmId);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then Stream.WriteStr('')
    else begin
      Stream.WriteStr(OrdIBS.FieldByName('ORDRCODE').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString+' �� '+
        FormatDateTime(cDateFormatY2, OrdIBS.FieldByName('ORDRDATE').AsDateTime));
    end;
    OrdIBS.Close;

    Stream.WriteStr(GBIBS.FieldByName('aClientComment').AsString);
    Summa:= FormatFloat('# ##0.00', GBIBS.FieldByName('aSUMM').AsFloat)+' '+
      Cache.GetCurrName(GBIBS.FieldByName('aCRNCCODE').AsInteger);
    GBIBS.Close;

    LineCount:= 0;       // ������� - ���-�� �����
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  ����� ��� ���-�� �����

    GBIBS.SQL.Text:= 'select PInvLnWareCode aWARECODE,'+
      ' PInvLnOrder aORDER, PInvLnCount aCOUNT, PInvLnPrice aPRICE'+
      ' from PayInvoiceLines where PInvLnDocmCode='+AccountCode;
    GBIBS.ExecQuery;
    while not GBIBS.EOF do begin
      i:= GBIBS.FieldByName('aWARECODE').AsInteger;
      Ware:= Cache.GetWare(i);
      if not Assigned(Ware) or (Ware=NoWare) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(i)));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(GBIBS.FieldByName('aORDER').AsString);
      Stream.WriteStr(GBIBS.FieldByName('aCOUNT').AsString);
      Stream.WriteStr(Ware.MeasName);
      Stream.WriteStr(FormatFloat('# ##0.00', GBIBS.FieldByName('aPRICE').AsFloat));
      Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(GBIBS.FieldByName('aPRICE').AsFloat*GBIBS.FieldByName('aCOUNT').AsFloat)));
      inc(LineCount);
      TestCssStopException;
      GBIBS.Next;
    end;
    GBIBS.Close;
    Stream.WriteStr(Summa);
    Stream.Position:= sPos;
    Stream.WriteInt(LineCount);
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
procedure prDeleteOrderByMarkOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prDeleteOrderByMarkOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS, OrdIBS1: TIBSQL;
    UserId, FirmID: integer;
    s: string;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  OrdIBS1:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    s:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'IDs='+s); // �����������

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
    OrdIBS1:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS1_'+nmProc, ThreadData.ID, tpWrite);
    OrdIBD.DefaultTransaction.StartTransaction;

    OrdIBS.SQL.Text:= 'SELECT r.ORDRCODE, r.ORDRNUM, r.ORDRDATE,'+
    ' IIF( exists (select ordrlncode from ORDERSLINES where ORDRLNORDER=r.ORDRCODE), 1, 0) LineCount'+
//    ' (select count(ordrlncode) from ORDERSLINES where ORDRLNORDER=r.ORDRCODE) LineCount'+
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
    UserId, FirmID: integer;
    s, OrderID: string;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderID:= Stream.ReadStr;
    s:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderID='+OrderID+#13#10+'Delivery='+s); // �����������
// ����  �����
    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD,'OrdIBS_'+nmProc,ThreadData.ID, tpWrite, True);

    OrdIBS.SQL.Text:= 'Select ORDRSTATUS FROM ORDERSREESTR'+
      ' WHERE ORDRCODE='+OrderID+' and ORDRFIRM='+IntToStr(FirmID);
    OrdIBS.ExecQuery;
    if OrdIBS.Bof and OrdIBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundOrder, OrderID));
    // ����� ���������, ����� �� ����� �������������
    if (OrdIBS.FieldByName('ORDRSTATUS').AsInteger<>orstForming) then
      raise EBOBError.Create(MessText(mtkNotEditOrder));
    OrdIBS.Close;

    OrdIBS.SQL.Text:= 'Update ORDERSREESTR set ORDRDELIVERYTYPE=:ORDRDELIVERYTYPE'+
      ' WHERE ORDRCODE='+OrderID+' and ORDRFIRM='+IntToStr(FirmID);
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
//********************************* ���������� �������� ���� "��� ������" ������
procedure prSetOrderPayTypeOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetOrderPayTypeOrd'; // ��� ���������/�������
var UserId, FirmID: integer;
    acctype, OrderCode, SResult, s: string;
begin
  SResult:= '';
  Stream.Position:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    OrderCode:= Stream.ReadStr;
    acctype:= Stream.ReadStr;
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderID='+OrderCode+#13#10+'acctype='+acctype); // �����������

    s:= fnRefreshPriceInOrderOrd(SResult, OrderCode, acctype);
    if (s<>'') then // ���� ������� ����������� � ������� - ���������� ������
      if copy(s, 1, 3)='EB:' then EBOBError.Create(copy(s, 4, length(s)))
      else raise Exception.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end; 
//****************************************************** �������� ������ � �����
procedure prAddLinesToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLinesToOrderOrd'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS, OrdIBS1, OrdIBS2: TIBSQL;
    UserId, FirmID, WareCount, DataCount, i, j, k, ResLineQty, StorageCount, ii,
      LineID, sPos, WareID, OrderID, contID: integer;
    s, OrderCode, WareCode, Currency, acctype, UserMessage,
      DivisibleMess, WrongWares, sSQL: string;
    OrderExists, LineExists: boolean;
    AnalogQty, price: double;
    WareCodes: Tas;
    WareQties: array of TDoubleDynArray; // ���-�� ������ �� �������
    WareQty: TDoubleDynArray; // ���-�� �� �������
    Storages: TaSD;
    Ware: TWareInfo;
    firma: TFirmInfo;
    HasAnalogs: Boolean;
    AnCodes: Tai;
    Contract: TContract;
begin
  if flClientStoragesView_2col then begin // 2 �������
    prAddLinesToOrderOrd_2col(Stream, ThreadData);
    exit;
  end;

  UserMessage:= '';
  WrongWares:='';
  Stream.Position:= 0;
//  IBD:= nil;
  IBS:= nil;
  OrdIBS1:= nil;
  OrdIBS2:= nil;
  UserId:= 0;
  FirmId:= 0;
  price:= 0;
  LineExists:= False;
  LineID:= 0;
  SetLength(AnCodes, 0);
  contID:= 0;
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
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'WareCode='+WareCode); // �����������

    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmID];
    if not firma.CheckContract(contID) then
      contID:= Cache.arClientInfo[UserId].LastContract;

    OrderID:= StrToIntDef(OrderCode, -1);
    if not Cache.CheckWareAndFirmEqualSys(WareID, FirmID, contID) then
      WrongWares:= Cache.GetWare(WareID).Name;

    IBD:= cntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
      OrdIBS1:= fnCreateNewIBSQL(IBD, 'OrdIBS1_'+nmProc, ThreadData.ID, tpWrite);
      OrdIBS2:= fnCreateNewIBSQL(IBD, 'OrdIBS2_'+nmProc, ThreadData.ID, tpWrite);
      IBD.DefaultTransaction.StartTransaction;

      sSQL:= 'Select ORDRCURRENCY, ORDRACCOUNTINGTYPE, ORDRCONTRACT FROM ORDERSREESTR'+
          ' WHERE ORDRCODE=:ORDRCODE and ORDRSTATUS='+IntToStr(orstForming);
      OrderExists:= OrderID>0;
      if OrderExists then begin
        IBS.SQL.Text:= sSQL;
        IBS.ParamByName('ORDRCODE').AsInteger:= OrderID;
        IBS.ExecQuery;
        OrderExists:= not (IBS.Bof and IBS.Eof);
      end;
      if not OrderExists then begin // ���� ��� ������ - �������
        IBS.Close;
        prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, contID, s, ThreadData.ID, OrdIBS1);
        if s<>'' then raise Exception.Create(s);
        OrderCode:= IntToStr(OrderID);
        with IBD.DefaultTransaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= sSQL;
        IBS.ParamByName('ORDRCODE').AsInteger:= OrderID;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      end;
  // ���-��� ���������� ��� ����
      CURRENCY:= IBS.FieldByName('ORDRCURRENCY').AsString;
      acctype:= IBS.FieldByName('ORDRACCOUNTINGTYPE').AsString;
      if (contID<1) then contID:= IBS.FieldByName('ORDRCONTRACT').AsInteger;
      IBS.Close;

      Contract:= firma.GetContract(contID);

  // +++ ��������� ������ ����� ������������� �������
      Storages:= fnGetStoragesArray(UserId, FirmId, true, contID);

      StorageCount:= Length(Storages);
      SetLength(WareCodes, 10);
      WareCodes[0]:= WareCode;

      j:= 1;
      AnCodes:= fnGetAllAnalogs(WareID, -1, Contract.SysID);
      for i:= 0 to High(AnCodes) do
        if (fnNotZero(Cache.GetWare(AnCodes[i]).RetailPrice)) then begin
          if High(WareCodes)<j then SetLength(WareCodes, j+10);
          WareCodes[j]:= IntToStr(AnCodes[i]);
          inc(j);
        end;
      if Length(WareCodes)>j then SetLength(WareCodes, j);
      SetLength(AnCodes, 0);
      WareCount:= Length(WareCodes);

      SetLength(WareQties, WareCount);   // ��������� ��������
      SetLength(WareQty, WareCount);
      for i:= 0 to WareCount-1 do begin
        SetLength(WareQties[i], StorageCount);
        WareQty[i]:= 0;
        for j:= 0 to StorageCount-1 do WareQties[i, j]:= 0;
      end;

      DivisibleMess:= '';
      for i:= 0 to DataCount-1 do begin // ���������� ��������
        s:= Stream.ReadStr;
        AnalogQty:= Stream.ReadDouble;
        k:= Pos('_', s);
        if (k<1) then Continue;
        j:= StrToIntDef(Copy(s, 1, k-1), 0);
        if (j<1) then Continue;
        k:= StrToIntDef(Copy(s, k+1, 10000), 0);
        if (k<1) then Continue;
        j:= fnInStrArray(IntToStr(j), WareCodes); // ��� �������� ������ ������
        if (j<0) then Continue;
        k:= fnGetStorageIndex(IntToStr(k), Storages); // ��� �������� ������ ������
        if (k<0) then Continue;

        WareID:= StrToIntDef(WareCodes[j], 0);
        if (warecode<>WareCodes[j]) and not Cache.CheckWareAndFirmEqualSys(WareID, FirmID, contID) then
          WrongWares:= WrongWares+fnIfStr(WrongWares='', '', ', ')+Cache.GetWare(WareID).Name;

        DivisibleMess:= fnRecaclQtyByDivisibleEx(WareID, AnalogQty); // ��������� ���������
        if (DivisibleMess<>'') then raise EBOBError.Create(DivisibleMess);

        WareQties[j, k]:= AnalogQty;
        WareQty[j]:= WareQty[j]+AnalogQty;
      end;

      if (WrongWares<>'') then raise EBOBError.Create('��� ������-����������� '+
        Contract.SysName+' ���������� ������: '+WrongWares);

  // ������ ���������� ��������� ������
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
        '('+OrderCode+', :ORDRLNWARE, 0, :ORDRLNWAREMEASURE, :ORDRLNPRICE, 0, 0)';
      IBS.Prepare;

      OrdIBS1.SQL.Text:='EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', :WareCode, :Storage, :WareQty)';
      OrdIBS1.Prepare;

      OrdIBS2.SQL.Text:= 'execute procedure DelOrderWareLine(:WARE, '+OrderCode+')';
      OrdIBS2.Prepare;

      SetLength(AnCodes, 0);
      for i:= 0 to WareCount-1 do begin
        Ware:= Cache.GetWare(StrToInt(WareCodes[i]));
        if not fnNotZero(Ware.RetailPrice) then Continue;

        if fnNotZero(WareQty[i]) then begin
          price:= Ware.SellingPrice(FirmID, StrToInt(Currency), ContID);
          with IBS.Transaction do if not InTransaction then StartTransaction;
          IBS.ParamByName('ORDRLNWARE').AsString        := WareCodes[i]; // ��� ������
          IBS.ParamByName('ORDRLNWAREMEASURE').AsInteger:= Ware.MeasId;  // ��.���.
          IBS.ParamByName('ORDRLNPRICE').AsFloat        := price;        // ����
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
          if LineID<1 then raise Exception.Create('������ ������ ������ ������.');

          // ������ ����������� �� �������
          with OrdIBS1.Transaction do if not InTransaction then StartTransaction;
          OrdIBS1.ParamByName('WareCode').AsString:= WareCodes[i];
          for j:= 0 to StorageCount-1 do begin
            OrdIBS1.ParamByName('Storage').AsString:= Storages[j].Code;
            OrdIBS1.ParamByName('WareQty').AsFloat := WareQties[i, j];
            s:= RepeatExecuteIBSQL(OrdIBS1);
            if s<>'' then raise Exception.Create(s);
          end;

          if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
            // � �������� �� � CGI-������
            Stream.WriteByte(fnIfInt(LineExists, constOpEdit, constOpAdd));
            Stream.WriteInt(LineID);
            Stream.WriteStr(WareCodes[i]);

            AnCodes:= fnGetAllAnalogs(StrToInt(WareCodes[i]), -1, Contract.SysID);
            HasAnalogs:= Length(AnCodes)>0;
            SetLength(AnCodes, 0);

            Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
            Stream.WriteStr(Ware.WareBrandName);
            Stream.WriteStr(Ware.Name);
            Stream.WriteStr(FormatFloat('# ##0', WareQty[i]));
            Stream.WriteStr(Ware.MeasName);
            Stream.WriteStr(FormatFloat('# ##0.00', price));
            Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(price*WareQty[i])));
            for j:= 0 to StorageCount-1 do if (Storages[j].IsReserve) then
               // ���� ����� �������� ��� ��������������, �� �������� ������� ���-�� ������
                Stream.WriteStr(trim(FormatFloat('###0.#', WareQties[i, j])));
            Inc(ResLineQty);
          end; //  if not OrderExists then begin // ���� �� ����� �����, �� �������� ��� ��� ������ ������

        end else if OrderExists then begin // ���� ������ �������� 0 � ����� ����������, �� ������� ������ ������ � ��������� ������ �� �������
          with OrdIBS2.Transaction do if not InTransaction then StartTransaction;
          OrdIBS2.ParamByName('WARE').AsString:= WareCodes[i];
          s:= RepeatExecuteIBSQL(OrdIBS2);
          if s<>'' then raise Exception.Create(s);
          Stream.WriteByte(constOpDel);
          Stream.WriteStr(WareCodes[i]);
          Inc(ResLineQty);
        end; // if fnNotZero(WareQty[i])
        IBS.Close;
        OrdIBS1.Close;
        OrdIBS2.Close;
      end; // for i:=0 to WareCount-1 do begin

      if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ����� ����� ������ � ������
        with IBS.Transaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= 'SELECT ORDRSUMORDER from ORDERSREESTR where ORDRCODE='+OrderCode;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
        Stream.WriteStr(FormatFloat('# ##0.00', IBS.FieldByName('ORDRSUMORDER').AsFloat));
        Stream.WriteStr(Cache.GetCurrName(StrToInt(Currency)));
        Stream.WriteStr(UserMessage);
        Stream.Position:= sPos;
        Stream.WriteInt(ResLineQty); // ���������� ���-�� ������� (������������ �������)
      end else Stream.WriteStr(UserMessage);
    finally
      prFreeIBSQL(IBS);
      prFreeIBSQL(OrdIBS1);
      prFreeIBSQL(OrdIBS2);
      cntsORD.SetFreeCnt(IBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
                      ' UID='+IntToStr(UserID)+' FID='+IntToStr(FirmID)+' OID='+OrderCode+
                      ' price='+FormatFloat('# ##0.00', price), False);
  end;
  Stream.Position:= 0;
  SetLength(Storages, 0);
  SetLength(WareCodes, 0);
  SetLength(WareQty, 0);
  SetLength(AnCodes, 0);
end;
//************************************ �������� ������ � ����� - 2 ������� (Web)
procedure prAddLinesToOrderOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLinesToOrderOrd_2col'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS, OrdIBS1, OrdIBS2: TIBSQL;
    UserId, FirmID, WareCount, DataCount, i, j, k, ResLineQty, ii,
      LineID, sPos, WareID, OrderID, contID: integer;
    s, OrderCode, WareCode, Currency, acctype, UserMessage,
      DivisibleMess, WrongWares, sSQL: string;
    OrderExists, LineExists: boolean;
    AnalogQty, price: double;
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
  OrdIBS2:= nil;
  UserId:= 0;
  FirmId:= 0;
  price:= 0;
  LineExists:= False;
  LineID:= 0;
  SetLength(AnCodes, 0);
  contID:= 0;
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
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'WareCode='+WareCode); // �����������

    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������');
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmID];
    OrderID:= StrToIntDef(OrderCode, -1);

    IBD:= cntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite);
      OrdIBS1:= fnCreateNewIBSQL(IBD, 'OrdIBS1_'+nmProc, ThreadData.ID, tpWrite);
      OrdIBS2:= fnCreateNewIBSQL(IBD, 'OrdIBS2_'+nmProc, ThreadData.ID, tpWrite);
      IBD.DefaultTransaction.StartTransaction;

      sSQL:= 'Select ORDRCURRENCY, ORDRACCOUNTINGTYPE, ORDRCONTRACT FROM ORDERSREESTR'+
          ' WHERE ORDRCODE=:ORDRCODE and ORDRSTATUS='+IntToStr(orstForming);
      OrderExists:= OrderID>0;
      if OrderExists then begin
        IBS.SQL.Text:= sSQL;
        IBS.ParamByName('ORDRCODE').AsInteger:= OrderID;
        IBS.ExecQuery;
        OrderExists:= not (IBS.Bof and IBS.Eof);
      end;
      if OrderExists then contID:= IBS.FieldByName('ORDRCONTRACT').AsInteger
      else begin // ���� ��� ������ - �������
        IBS.Close;
        prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, contID, s, ThreadData.ID, OrdIBS1);
        if s<>'' then raise Exception.Create(s);
        OrderCode:= IntToStr(OrderID);
        with IBD.DefaultTransaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= sSQL;
        IBS.ParamByName('ORDRCODE').AsInteger:= OrderID;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      end;
  // ���-��� ���������� ��� ����
      CURRENCY:= IBS.FieldByName('ORDRCURRENCY').AsString;
      acctype:= IBS.FieldByName('ORDRACCOUNTINGTYPE').AsString;
      IBS.Close;

      if not firma.CheckContract(contID) then
        contID:= Cache.arClientInfo[UserId].LastContract;
      Contract:= firma.GetContract(contID);
      if not Cache.CheckWareAndFirmEqualSys(WareID, FirmID, contID) then
        WrongWares:= Cache.GetWare(WareID).Name;

  // +++ ��������� ������ ����� ������������� �������
      Storages:= fnGetStoragesArray_2col(Contract, true, True);

      SetLength(WareCodes, 10);
      WareCodes[0]:= WareCode;
      j:= 1;
      AnCodes:= fnGetAllAnalogs(WareID, -1, Contract.SysID);
      for i:= 0 to High(AnCodes) do
        if (fnNotZero(Cache.GetWare(AnCodes[i]).RetailPrice)) then begin
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
      for i:= 0 to DataCount-1 do begin // ���������� ��������
        s:= Stream.ReadStr;
        AnalogQty:= Stream.ReadDouble;
        k:= Pos('_', s);
        if (k<1) then Continue;

        j:= StrToIntDef(Copy(s, 1, k-1), 0);
        if (j<1) then Continue;
        j:= fnInStrArray(IntToStr(j), WareCodes); // ��� �������� ������ ������
        if (j<0) then Continue;

        k:= StrToIntDef(Copy(s, k+1, 10000), 0);
        if (k<1) or (k<>Contract.MainStorage) then Continue;

        WareID:= StrToIntDef(WareCodes[j], 0);
        if (warecode<>WareCodes[j]) and not Cache.CheckWareAndFirmEqualSys(WareID, FirmID, contID) then
          WrongWares:= WrongWares+fnIfStr(WrongWares='', '', ', ')+Cache.GetWare(WareID).Name;

        DivisibleMess:= fnRecaclQtyByDivisibleEx(WareID, AnalogQty); // ��������� ���������
        if (DivisibleMess<>'') then raise EBOBError.Create(DivisibleMess);

        WareQties[j]:= AnalogQty;
        WareQty[j]:= WareQty[j]+AnalogQty;
      end;

      if (WrongWares<>'') then raise EBOBError.Create('��� ������-����������� '+
        Contract.SysName+' ���������� ������: '+WrongWares);

  // ������ ���������� ��������� ������
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
        '('+OrderCode+', :ORDRLNWARE, 0, :ORDRLNWAREMEASURE, :ORDRLNPRICE, 0, 0)';
      IBS.Prepare;

      OrdIBS1.SQL.Text:='EXECUTE PROCEDURE AEWareByStorages('+OrderCode+', :WareCode, :Storage, :WareQty)';
      OrdIBS1.Prepare;

      OrdIBS2.SQL.Text:= 'execute procedure DelOrderWareLine(:WARE, '+OrderCode+')';
      OrdIBS2.Prepare;

      SetLength(AnCodes, 0);
      for i:= 0 to WareCount-1 do begin
        Ware:= Cache.GetWare(StrToInt(WareCodes[i]));
        if not fnNotZero(Ware.RetailPrice) then Continue;
//------------------------------------------------------------------------------
        if fnNotZero(WareQty[i]) then begin
          price:= Ware.SellingPrice(FirmID, StrToInt(Currency), ContID);
          with IBS.Transaction do if not InTransaction then StartTransaction;
          IBS.ParamByName('ORDRLNWARE').AsString        := WareCodes[i]; // ��� ������
          IBS.ParamByName('ORDRLNWAREMEASURE').AsInteger:= Ware.MeasId;  // ��.���.
          IBS.ParamByName('ORDRLNPRICE').AsFloat        := price;        // ����
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
          if LineID<1 then raise Exception.Create('������ ������ ������ ������.');

          // ������ ����������� �� ������� �����
          with OrdIBS1.Transaction do if not InTransaction then StartTransaction;
          OrdIBS1.ParamByName('WareCode').AsString:= WareCodes[i];
          OrdIBS1.ParamByName('Storage').AsString:= Contract.MainStoreStr;
          OrdIBS1.ParamByName('WareQty').AsFloat := WareQties[i];
          s:= RepeatExecuteIBSQL(OrdIBS1);
          if s<>'' then raise Exception.Create(s);

          if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
            // � �������� �� � CGI-������
            Stream.WriteByte(fnIfInt(LineExists, constOpEdit, constOpAdd));
            Stream.WriteInt(LineID);
            Stream.WriteStr(WareCodes[i]);

            AnCodes:= fnGetAllAnalogs(StrToInt(WareCodes[i]), -1, Contract.SysID);
            HasAnalogs:= Length(AnCodes)>0;
            SetLength(AnCodes, 0);

            Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
            Stream.WriteStr(Ware.WareBrandName);
            Stream.WriteStr(Ware.Name);
            Stream.WriteStr(FormatFloat('# ##0', WareQty[i]));
            Stream.WriteStr(Ware.MeasName);
            Stream.WriteStr(FormatFloat('# ##0.00', price));
            Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(price*WareQty[i])));
            Stream.WriteStr(trim(FormatFloat('###0.#', WareQties[i])));  // �������� ������� ���-�� ������
            Inc(ResLineQty);
          end; //  if not OrderExists then begin // ���� �� ����� �����, �� �������� ��� ��� ������ ������
//------------------------------------------------------------------------------
        end else if OrderExists then begin // ���� ������ �������� 0 � ����� ����������, �� ������� ������ ������ � ��������� ������ �� �������
          with OrdIBS2.Transaction do if not InTransaction then StartTransaction;
          OrdIBS2.ParamByName('WARE').AsString:= WareCodes[i];
          s:= RepeatExecuteIBSQL(OrdIBS2);
          if s<>'' then raise Exception.Create(s);
          Stream.WriteByte(constOpDel);
          Stream.WriteStr(WareCodes[i]);
          Inc(ResLineQty);
        end; // if fnNotZero(WareQty[i])
        IBS.Close;
        OrdIBS1.Close;
        OrdIBS2.Close;
      end; // for i:=0 to WareCount-1 do begin

      if OrderExists then begin // ���� ����� ����������� � ������, �� �������� ����� ����� ������ � ������
        with IBS.Transaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= 'SELECT ORDRSUMORDER from ORDERSREESTR where ORDRCODE='+OrderCode;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
        Stream.WriteStr(FormatFloat('# ##0.00', IBS.FieldByName('ORDRSUMORDER').AsFloat));
        Stream.WriteStr(Cache.GetCurrName(StrToInt(Currency)));
        Stream.WriteStr(UserMessage);
        Stream.Position:= sPos;
        Stream.WriteInt(ResLineQty); // ���������� ���-�� ������� (������������ �������)
      end else Stream.WriteStr(UserMessage);
    finally
      prFreeIBSQL(IBS);
      prFreeIBSQL(OrdIBS1);
      prFreeIBSQL(OrdIBS2);
      cntsORD.SetFreeCnt(IBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
                      ' UID='+IntToStr(UserID)+' FID='+IntToStr(FirmID)+' OID='+OrderCode+
                      ' price='+FormatFloat('# ##0.00', price), False);
  end;
  Stream.Position:= 0;
  SetLength(Storages, 0);
  SetLength(WareCodes, 0);
  SetLength(WareQty, 0);
  SetLength(AnCodes, 0);
end;
//******************************************************************************
procedure prAddLineFromSearchResToOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLineFromSearchResToOrderOrd'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, j, StorageCount, LineID, OrderID, WareID, Currency, ContID: integer;
    s, OrderCode, WareCode, UserMessage: string;
    OrderExist: boolean;
    WareQty, price: double;
    Storages: TaSD;
    Ware: TWareInfo;
    HasAnalogs: Boolean;
    anw: Tai;
    firma: TFirmInfo;
    Contract: TContract;
    Client: TClientInfo;
  //-------------------------------
  procedure AddWareLine; // ������ ������ ������ � �����������
  begin
    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select rNewOrderLnCode from AddOrderLineQty'+
      '('+OrderCode+', '+WareCode+', 0, :ORDRLNMEAS, :ORDRLNPRICE, 0, 0)'; // ��� ������, ��� ������, ...
    OrdIBS.ParamByName('ORDRLNMEAS').AsInteger:= Ware.MeasId;  // ��.���.
    OrdIBS.ParamByName('ORDRLNPRICE').AsFloat := price;        // ����
    LineID:= 0;
    s:= RepeatExecuteIBSQL(OrdIBS, 'rNewOrderLnCode', LineID);
    if (s<>'') then raise Exception.Create(s);
    if (LineID<1) then raise Exception.Create('rNewOrderLnCode < 1');

    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'EXECUTE PROCEDURE AEWareByStorages('+
      OrderCode+', '+WareCode+', '+Contract.MainStoreStr+', :WareQty)';
    OrdIBS.ParamByName('WareQty').AsFloat:= WareQty;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if (s<>'') then raise Exception.Create(s);
  end;
  //-------------------------------
begin
  if flClientStoragesView_2col then begin
    prAddLineFromSearchResToOrderOrd_2col(Stream, ThreadData);
    exit;
  end;
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
  UserId:= 0;
  FirmId:= 0;
  price:= 0;
  LineID:= 0;
  Currency:= 0;
  contID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;
    WareCode:= Stream.ReadStr;
    WareQty:= StrToFloatDef(Stream.ReadStr, 1);

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'WareCode='+WareCode+
      #13#10'WareQty='+FormatFloat('###0.#', WareQty)+#13#10'OrderCode='+OrderCode+
      #13#10'ContID='+IntToStr(ContID)); // �����������

    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) or Cache.GetWare(WareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, WareCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Client:= Cache.arClientInfo[UserId];
    firma:= Cache.arFirmInfo[FirmId];
    OrderID:= StrToIntDef(OrderCode, -1);
    OrderCode:= IntToStr(OrderID);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrderExist:= (OrderID>0);
    if OrderExist then begin
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY, ORDRCONTRACT'+ // , ORDRACCOUNTINGTYPE'+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      OrderExist:= not (OrdIBS.Bof and OrdIBS.Eof);
      if OrderExist then begin       // ���-��� ���������� ��� ����
        CURRENCY:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
        j:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
        if firma.CheckContract(j) then ContID:= j;
      end;
      OrdIBS.Close;
    end;
    if not firma.CheckContract(contID) then contID:= Client.LastContract;
    Contract:= firma.GetContract(contID);

    if not Cache.CheckWareAndFirmEqualSys(WareID, FirmID, ContID) then
      raise EBOBError.Create('����� ���������� ��� ������-����������� '+Contract.SysName);

    Stream.Clear;
    Ware:= Cache.GetWare(WareID);
    if OrderExist then begin       // ���-��� ���������� ��� ����
      price   := Ware.SellingPrice(FirmID, CURRENCY, ContID);
      OrdIBS.SQL.Text:= 'Select ORDRLNCODE FROM ORDERSLINES WHERE ORDRLNORDER='+
                        OrderCode+' and ORDRLNWARE='+WareCode;
      OrdIBS.ExecQuery;      // ���� ����� ��� ����, �� �������� ������������
      if not (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create('WareExists');
      OrdIBS.Close;

      UserMessage:= fnRecaclQtyByDivisibleEx(WareID, WareQty);   // ��������� ���������
      if UserMessage<>'' then raise EBOBError.Create(UserMessage);

  // +++ ��������� ������ ����� ������� ������������� �������
      Storages:= fnGetStoragesArray(UserId, FirmId, true, ContID);
      StorageCount:= Length(Storages);
  // ������ ���������� ��������� ������
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteBool(OrderExist); // ����� �� ������������ ������
      // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
      prSendStorages(Storages, Stream);

      AddWareLine; // ������ ������ ������ � �����������

      Stream.WriteInt(LineID);        // �������� ���������� ������ � CGI-������
      Stream.WriteStr(WareCode);

      anw:= fnGetAllAnalogs(StrToInt(WareCode), -1, Contract.SysID);
      HasAnalogs:= Length(anw)>0;
      SetLength(anw, 0);

      Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(FormatFloat('# ##0', WareQty));
      Stream.WriteStr(Ware.MeasName);
      Stream.WriteStr(FormatFloat('# ##0.00', price));
      Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(price*WareQty)));

      for j:= 0 to StorageCount-1 do if (Storages[j].IsReserve) then
        // ���� ����� �������� ��� ��������������, �� �������� ������� ���-�� ������
        Stream.WriteStr(fnIfStr(Contract.MainStoreStr=Storages[j].Code, trim(FormatFloat('###0.#', WareQty)), '0'));

      OrdIBS.Close;
      with OrdIBS.Transaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'Select ORDRSUMORDER FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+
        ' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
      Stream.WriteStr(Cache.GetCurrName(CURRENCY)); //
      Stream.WriteStr(UserMessage);

    end else begin  // ���� ��� ������ - �������
      prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, s, ThreadData.ID, OrdIBS);

      if s<>'' then raise Exception.Create(s);
      OrderCode:= IntToStr(OrderID);
      with OrdIBD.DefaultTransaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY'+ // , ORDRACCOUNTINGTYPE'+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;              // ���-��� ���������� ��� ����
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      CURRENCY:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
      OrdIBS.Close;
      price:= Ware.SellingPrice(FirmID, CURRENCY, ContID);

      UserMessage:= fnRecaclQtyByDivisibleEx(WareID, WareQty);   // ��������� ���������
      if UserMessage<>'' then raise EBOBError.Create(UserMessage);
  // ������ ���������� ��������� ������
      Stream.WriteInt(aeSuccess);   // ���� ����, ��� ������ ��������� ���������
      Stream.WriteBool(OrderExist); // ����� �� ������������ ������
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
        ' price='+FormatFloat('# ##0.00', price), False);

  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(Storages, 0);
  SetLength(anw, 0);
end;
//************************************************************** 2 ������� (Web)
procedure prAddLineFromSearchResToOrderOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLineFromSearchResToOrderOrd_2col'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, j, LineID, OrderID, WareID, Currency, ContID: integer;
    s, OrderCode, WareCode, UserMessage: string;
    OrderExist: boolean;
    WareQty, price: double;
    Storages: TaSD;
    Ware: TWareInfo;
    HasAnalogs: Boolean;
    anw: Tai;
    firma: TFirmInfo;
    Contract: TContract;
  //-------------------------------
  procedure AddWareLine; // ������ ������ ������ � �����������
  begin
    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'select rNewOrderLnCode from AddOrderLineQty'+
      '('+OrderCode+', '+WareCode+', 0, :ORDRLNMEAS, :ORDRLNPRICE, 0, 0)'; // ��� ������, ��� ������, ...
    OrdIBS.ParamByName('ORDRLNMEAS').AsInteger:= Ware.MeasId;  // ��.���.
    OrdIBS.ParamByName('ORDRLNPRICE').AsFloat := price;        // ����
    LineID:= 0;
    s:= RepeatExecuteIBSQL(OrdIBS, 'rNewOrderLnCode', LineID);
    if (s<>'') then raise Exception.Create(s);
    if (LineID<1) then raise Exception.Create('rNewOrderLnCode < 1');

    with OrdIBS.Transaction do if not InTransaction then StartTransaction;
    OrdIBS.SQL.Text:= 'EXECUTE PROCEDURE AEWareByStorages('+
      OrderCode+', '+WareCode+', '+Contract.MainStoreStr+', :WareQty)';
    OrdIBS.ParamByName('WareQty').AsFloat:= WareQty;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if (s<>'') then raise Exception.Create(s);
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
  Currency:= 0;
  contID:= 0;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    OrderCode:= Stream.ReadStr;
    WareCode:= Stream.ReadStr;
    WareQty:= StrToFloatDef(Stream.ReadStr, 1);

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'WareCode='+WareCode+
      #13#10'WareQty='+FormatFloat('###0.#', WareQty)+#13#10'OrderCode='+OrderCode+
      #13#10'ContID='+IntToStr(ContID)); // �����������

    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) or Cache.GetWare(WareID).IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, WareCode));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    firma:= Cache.arFirmInfo[FirmId];
    OrderID:= StrToIntDef(OrderCode, -1);
    OrderCode:= IntToStr(OrderID);

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrderExist:= (OrderID>0);
    if OrderExist then begin
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY, ORDRCONTRACT'+ // , ORDRACCOUNTINGTYPE'+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      OrderExist:= not (OrdIBS.Bof and OrdIBS.Eof);
      if OrderExist then begin       // ���-��� ���������� ��� ����
        CURRENCY:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
        j:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;
        if firma.CheckContract(j) then ContID:= j;
      end;
      OrdIBS.Close;
    end;
    if not firma.CheckContract(contID) then
      contID:= Cache.arClientInfo[UserID].LastContract;
    Contract:= firma.GetContract(contID);

    if not Cache.CheckWareAndFirmEqualSys(WareID, FirmID, ContID) then
      raise EBOBError.Create('����� ���������� ��� ������-����������� '+Contract.SysName);

    Stream.Clear;
    Ware:= Cache.GetWare(WareID);
    if OrderExist then begin       // ���-��� ���������� ��� ����
      price   := Ware.SellingPrice(FirmID, CURRENCY, ContID);
      OrdIBS.SQL.Text:= 'Select ORDRLNCODE FROM ORDERSLINES WHERE ORDRLNORDER='+
                        OrderCode+' and ORDRLNWARE='+WareCode;
      OrdIBS.ExecQuery;      // ���� ����� ��� ����, �� �������� ������������
      if not (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create('WareExists');
      OrdIBS.Close;

      UserMessage:= fnRecaclQtyByDivisibleEx(WareID, WareQty);   // ��������� ���������
      if UserMessage<>'' then raise EBOBError.Create(UserMessage);

  // +++ ��������� ������ ����� ������� ������������� �������
      Storages:= fnGetStoragesArray_2col(Contract, true, True);

  // ������ ���������� ��������� ������
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteBool(OrderExist); // ����� �� ������������ ������
      // ���� ����� ����������� � ������, �� �������� ��� ��� ������ ������
      prSendStorages(Storages, Stream);

      AddWareLine; // ������ ������ ������ � �����������

      Stream.WriteInt(LineID);        // �������� ���������� ������ � CGI-������
      Stream.WriteStr(WareCode);

      anw:= fnGetAllAnalogs(StrToInt(WareCode), -1, Contract.SysID);
      HasAnalogs:= Length(anw)>0;
      SetLength(anw, 0);

      Stream.WriteStr(fnIfStr(HasAnalogs, '1', '0'));
      Stream.WriteStr(Ware.WareBrandName);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(FormatFloat('# ##0', WareQty));
      Stream.WriteStr(Ware.MeasName);
      Stream.WriteStr(FormatFloat('# ##0.00', price));
      Stream.WriteStr(FormatFloat('# ##0.00', RoundToHalfDown(price*WareQty)));
      Stream.WriteStr(trim(FormatFloat('###0.#', WareQty))); // �������� ������� ���-�� ������

      OrdIBS.Close;
      with OrdIBS.Transaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'Select ORDRSUMORDER FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+
        ' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      Stream.WriteStr(FormatFloat('# ##0.00', OrdIBS.FieldByName('ORDRSUMORDER').AsFloat));
      Stream.WriteStr(Cache.GetCurrName(CURRENCY)); //
      Stream.WriteStr(UserMessage);

    end else begin  // ���� ��� ������ - �������
      prCreateNewOrderCommonOrd(UserId, FirmID, OrderID, ContID, s, ThreadData.ID, OrdIBS);

      if s<>'' then raise Exception.Create(s);
      OrderCode:= IntToStr(OrderID);
      with OrdIBD.DefaultTransaction do if not InTransaction then StartTransaction;
      OrdIBS.SQL.Text:= 'Select ORDRCURRENCY'+ // , ORDRACCOUNTINGTYPE'+
        ' FROM ORDERSREESTR WHERE ORDRCODE='+OrderCode+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBS.ExecQuery;              // ���-��� ���������� ��� ����
      if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      CURRENCY:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
      OrdIBS.Close;
      price:= Ware.SellingPrice(FirmID, CURRENCY, ContID);

      UserMessage:= fnRecaclQtyByDivisibleEx(WareID, WareQty);   // ��������� ���������
      if UserMessage<>'' then raise EBOBError.Create(UserMessage);
  // ������ ���������� ��������� ������
      Stream.WriteInt(aeSuccess);   // ���� ����, ��� ������ ��������� ���������
      Stream.WriteBool(OrderExist); // ����� �� ������������ ������
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
        ' price='+FormatFloat('# ##0.00', price), False);

  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
  SetLength(Storages, 0);
  SetLength(anw, 0);
end;
//******************************************************************************
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
    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select RGZNCODE, RGZNNAME from REGIONALZONES order by RGZNNAME';
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
//******************************************************************************
procedure prSaveRegOrderOrd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveRegOrderOrd'; // ��� ���������/�������
var ibs: TIBSQL;
    ibd: TIBDatabase;
    Firm, FIO, Post, Login, Address, Phones, Email, IP, s, RegName, RegMail, link: string;
    IsClient: boolean;
    Region, FirmType, dprtID,i: integer;
    Strings: TStringList;
  //------------------------------- ������ ��������
  procedure SetIbsParams;
  begin
    ibs.ParamByName('OREGFIRMNAME').AsString    := trim(Firm);
    ibs.ParamByName('OREGREGION').AsInteger     := Region;
    ibs.ParamByName('OREGMAINUSERFIO').AsString := trim(FIO);
    ibs.ParamByName('OREGMAINUSERPOST').AsString:= trim(Post);
    ibs.ParamByName('OREGLOGIN').AsString       := trim(Login);
    ibs.ParamByName('OREGCLIENT').AsString      := fnIfStr(IsClient,'T','F');
    ibs.ParamByName('OREGADDRESS').AsString     := trim(Address);
    ibs.ParamByName('OREGPHONES').AsString      := trim(Phones);
    ibs.ParamByName('OREGEMAIL').AsString       := trim(Email);
    ibs.ParamByName('OREGTYPE').AsInteger       := FirmType;
    ibs.ParamByName('OREGIP').AsString          := trim(IP);
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
    Firm:= Stream.ReadStr;
    Region:= StrToInt(Stream.ReadStr);
    FIO:= Stream.ReadStr;
    Post:= Stream.ReadStr;
    Login:= Stream.ReadStr;
    IsClient:= Stream.ReadStr='1';
    Address:= Stream.ReadStr;
    Phones:= Stream.ReadStr;
    Email:= Stream.ReadStr;
    FirmType:= StrToInt(Stream.ReadStr);
    IP:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, 0, 0, 'Firm='+Firm+#13#10' Region='+IntToStr(Region)+
      #13#10' FIO='+FIO+#13#10' Post='+Post+#13#10' Login='+Login+#13#10+
      fnIfStr(IsClient,'is Client', 'not Client')+#13#10' Address='+Address+
      #13#10' Phones='+Phones+#13#10' Email='+Email+
      #13#10' FirmType='+IntToStr(FirmType)+#13#10' IP='+IP); // �����������

    if (Firm='') then raise EBOBError.Create('�� ������ ������������ ������������.');
    if (FIO='') then raise EBOBError.Create('�� ������ ��� �������� ������������.');
    if (Post='') then raise EBOBError.Create('�� ������ ��������� �������� ������������.');
    if (not IsClient and (Address='')) then raise EBOBError.Create('�� ����� �����');
    if (not IsClient and (Phones='')) then raise EBOBError.Create('�� ����� �������');
    if (not FirmType in [0..3]) then raise EBOBError.Create('����� �������������� ��� �����������');
    if not fnCheckOrderWebLogin(Login) then  // ��������� �����
      raise EBOBError.Create(MessText(mtkNotValidLogin));
    if not fnNotLockingLogin(Login) then // ���������, �� ��������� �� ����� � �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));

    ibd:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'Select WOCLCODE from WEBORDERCLIENTS where WOCLUPPERLOGIN='+QuotedStr(UpperCase(Login));
    ibs.ExecQuery;
    if not (ibs.Bof and ibs.Eof) then // ���������, �� ��������� �� ����� � ��� �����������
      raise EBOBError.Create(MessText(mtkLockingLogin, Login));
    ibs.Close;

    ibs.SQL.Text:= 'select RGZNNAME,RGZNFILIALLINK,RGZNEMAIL'+
      ' from REGIONALZONES WHERE RGZNCODE='+IntToStr(Region);
    ibs.ExecQuery;
    if (ibs.Bof and ibs.Eof) then raise EBOBError.Create('����� �������������� ������.');
    dprtID:= ibs.FieldByName('RGZNFILIALLINK').AsInteger;
    RegName:= ibs.FieldByName('RGZNNAME').AsString;
    RegMail:= ibs.FieldByName('RGZNEMAIL').AsString;
    ibs.Close;

    if Cache.DprtExist(dprtID) and Cache.arDprtInfo[dprtID].IsFilial then begin
      s:= Cache.arDprtInfo[dprtID].MailOrder;
      link:= copy(s, 1, pos('@', s)-1);
    end else dprtID:= Cache.arDprtInfo[1].FilialID; // �����

    Strings:= TStringList.Create;      // ������� ������ � ������������� ����������
    Strings.Add('�����������: '+Firm);
    Strings.Add('������: '+RegName);
    Strings.Add('��� �������� ������������: '+FIO);
    Strings.Add('��������� �������� ������������: '+Post);
    Strings.Add('�������� ����� �������� ������������: '+Login);
    Strings.Add('�������� �� �������� ��������: '+fnIfStr(IsClient,'��','���'));
    Strings.Add('����� �����������: '+Address);
    Strings.Add('�������: '+Phones);
    Strings.Add('Email: '+Email);
    s:= '��� �����������: ';
    case FirmType of
      0: s:= s+'���';
      1: s:= s+'�������';
      2: s:= s+'���� �������';
      else s:= s+'������';
    end;
    Strings.Add(s);
                                // �������� ��������� �������� �� �������� �����
    ibs.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
    ' from rdb$relation_fields f, rdb$fields ff'+
    ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE and f.RDB$RELATION_NAME=:table';
    ibs.ParamByName('table').AsString:= 'ORDERTOREGISTER';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      s:= trim(ibs.FieldByName('fname').AsString);
      i:= ibs.FieldByName('fsize').AsInteger;
      if (s='OREGFIRMNAME')          and (length(Firm)>i)    then Firm:= Copy(Firm,1,i)
      else if (s='OREGMAINUSERFIO')  and (length(FIO)>i)     then FIO:= Copy(FIO,1,i)
      else if (s='OREGMAINUSERPOST') and (length(Post)>i)    then Post:= Copy(Post,1,i)
      else if (s='OREGLOGIN')        and (length(Login)>i)   then Login:= Copy(Login,1,i)
      else if (s='OREGADDRESS')      and (length(Address)>i) then Address:= Copy(Address,1,i)
      else if (s='OREGPHONES')       and (length(Phones)>i)  then Phones:= Copy(Phones,1,i)
      else if (s='OREGEMAIL')        and (length(Email)>i)   then Email:= Copy(Email,1,i)
      else if (s='OREGIP')           and (length(IP)>i)      then IP:= Copy(IP,1,i);
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

    s:= n_SysMailSend(RegMail, '������ �� ����������� � �������'+
      ' ��������������� ������ �������', Strings, nil, '', '', true);
    if s<>'' then fnWriteToLog(ThreadData, lgmsCryticalSysError, nmProc,
      '������ �������� ������ � �������� ����� ������ �� �����������: ', s, '');

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

//*********************** ��� ������ �������� � 2 ������� ������� / ������ (Web)
procedure prGetQtyByAnalogsAndStoragesOrd_2col(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetQtyByAnalogsAndStoragesOrd_2col'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBQuery: TIBSQL;
    UserID, FirmID, i, j, ia, StorageCount, WareCount, WareID, sPos: integer;
    s, WareCode, OrderCode, Currency, ErrPos: string;
    Storages: TaSD;
    WareQty, WareTotal: double;
    pRetail, pSelling, qty, qty0, qty1, qty2: double;
    OrderExists, WareOrAnalogInOrder, flAdd: boolean;
    Ware: TWareInfo;
    OList: TObjectList;
    ar: Tai;
    firma: TFirmInfo;
    arOrderWareQties: Tas;
    owID, owIndex: integer;
    contID: integer;
    Contract: TContract;
begin
  Stream.Position:= 0;
  FirmID:= 0;
  UserID:= 0;
  OrdIBD:= nil;
  OrdIBQuery:= nil;
  SetLength(ar, 0);
  SetLength(arOrderWareQties, 0);
  OrderExists:= false;
  WareTotal:= 0;
  WareOrAnalogInOrder:= false;
  WareQty:= -1;
  contID:= 0;
  try
ErrPos:= '1';
    try
      UserID:= Stream.ReadInt;
      FirmID:= Stream.ReadInt;
      ContID:= Stream.ReadInt; // ��� ����������
      OrderCode:= Stream.ReadStr;
      WareCode:= Stream.ReadStr;
      WareQty:= Stream.ReadDouble;
      if (WareQty<constDeltaZero) then WareQty:= 1;
ErrPos:= '2';
    finally
      prSetThLogParams(ThreadData, 0, UserID, FirmID, 'OrderCode='+OrderCode+
        ', WareCode='+WareCode+', WareQty='+FloatToStr(WareQty)); // �����������
    end;
    WareID:= StrToIntDef(WareCode, 0);
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, WareCode));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    firma:= Cache.arFirmInfo[FirmID];

    Cache.arClientInfo[UserID].CheckQtyCount; // ��������� ������� �������� �������

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBQuery:= fnCreateNewIBSQL(OrdIBD, 'OrdIBQuery_'+nmProc, ThreadData.ID, tpRead, True);
    OrderExists:= OrderCode<>'';

    if OrderExists then try
      OrdIBQuery.SQL.Text:= 'Select ORDRCURRENCY, ORDRLNCODE, ORDRCONTRACT FROM ORDERSREESTR'+
        ' left join ORDERSLINES on ORDRLNORDER=ORDRCODE and ORDRLNWARE='+WareCode+
        ' WHERE ORDRCODE='+OrderCode+' and ORDRFIRM='+IntToStr(FirmId)+' and ORDRSTATUS='+IntToStr(orstForming);
      OrdIBQuery.ExecQuery;
      OrderExists:= not (OrdIBQuery.Bof and OrdIBQuery.Eof);
      if OrderExists then begin // ���� ����� ��� ���� � ������ - ����� ����� ������������ ����
        WareOrAnalogInOrder:= not OrdIBQuery.FieldByName('ORDRLNCODE').IsNull;
        Currency:= OrdIBQuery.FieldByName('ORDRCURRENCY').AsString;
        contID:= OrdIBQuery.FieldByName('ORDRCONTRACT').AsInteger;
      end;
    finally
      OrdIBQuery.Close;
    end;

    Contract:= firma.GetContract(contID);
//    if (not OrderExists) then Currency:= IntToStr(Contract.ContCurrency); // ���� ������ ���, ����� ������ �� �������� ���������
    if (not OrderExists) then begin // ���� ������ ���
      Currency:= IntToStr(Cache.arClientInfo[UserID].SearchCurrencyID);  // ����� ������ �� �������� ������������
    end;

ErrPos:= '3';
    ar:= fnGetAllAnalogs(WareID, -1, Contract.SysID);   //
ErrPos:= '6';
// +++ ��������� ������ ����� ������� - 2 �������
    Storages:= fnGetStoragesArray_2col(Contract);
    StorageCount:= Length(Storages);
    flAdd:= (StorageCount>2);

    if OrderExists then try
      SetLength(arOrderWareQties, Length(ar)+1); // ������� ����.�����(������ 0), ����� �������(������� �� 1)
      for i:= 0 to High(arOrderWareQties) do arOrderWareQties[i]:= '0';

      OrdIBQuery.SQL.Text:= 'Select OWBSSTORAGE, OWBSQTY, ORDRLNWARE'+
        ' FROM ORDERSLINES, ORDERSWAREBYSTORAGES'+
        ' WHERE OWBSORDERLINE=ORDRLNCODE AND ORDRLNORDER='+OrderCode+
        ' order by ORDRLNWARE, OWBSSTORAGE';
ErrPos:= '11';
      OrdIBQuery.ExecQuery; // ���������� ��������� ���������� �� ������ � ������
      while not OrdIBQuery.Eof do begin
        owID:= OrdIBQuery.FieldByName('ORDRLNWARE').AsInteger; // ���� ������ ������
        if (owID=WareID) then owIndex:= 0   // ������� ����.�����
        else begin
          owIndex:= fnInIntArray(owID, ar); // ����� �������
          if owIndex>-1 then Inc(owIndex);
        end;
        qty:= 0;
        while not OrdIBQuery.Eof and (owID=OrdIBQuery.FieldByName('ORDRLNWARE').AsInteger) do begin
          if owIndex>-1 then qty:= qty+OrdIBQuery.FieldByName('OWBSQTY').AsFloat;
          OrdIBQuery.Next;
        end;
        if fnNotZero(qty) then arOrderWareQties[owIndex]:= trim(FormatFloat('###0.#', qty));
      end;
    finally
      OrdIBQuery.Close;
    end; // if OrderExists

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� ������������ �������. �������� ���� �� ��� �������� �����, �� ���� ������� ����� ������������ ��� ���������� �����
    Stream.WriteStr(Cache.GetCurrName(StrToInt(Currency))); //
    Stream.WriteStr(FormatFloat('###0.#', WareQty)); //
    Stream.WriteStr(WareCode); //
    prSendStorages(Storages, Stream);

    WareCount:= 0;
    for ia:= 0 to High(ar)+1 do begin
      if (ia=0) then Ware:= Cache.GetWare(WareID) else Ware:= Cache.GetWare(ar[ia-1]);
      Stream.WriteInt(Ware.ID);     // ��� ������
      Stream.WriteStr(Ware.PgrName);       //
      Stream.WriteStr(Ware.Name);          //
      Stream.WriteBool(Ware.IsSale);            // ������� ����������
      Stream.WriteBool(ware.IsNonReturn);       // ������� ����������
      Stream.WriteBool(ware.IsCutPrice);       // ������� ������
      Ware.CalcFirmPrices(pRetail, pSelling, FirmID, StrToInt(Currency), contID);
      Stream.WriteStr(trim(FormatFloat('# ##0.00', pRetail)));  // �������
      Stream.WriteStr(trim(FormatFloat('# ##0.00', pSelling))); // �� �������
      Stream.WriteStr(Ware.MeasName);     //
      qty0:= 0; // ���-�� �� ������ �� ���������
      qty1:= 0; // ���-�� �� ��������� ������� �������
      qty2:= 0; // ���-�� �� ������� ���.���������
      OList:= Cache.GetWareRestsByStores(Ware.ID);
      try
        for i:= 0 to High(Contract.ContStorages) do with Contract.ContStorages[i] do
          if IsVisible or (flAdd and IsAddVis) then begin
            j:= DprtID;
            qty:= fnGetQtybyIDDef(OList, j, 0);
            if (j=Contract.MainStorage) then qty0:= qty
            else if IsVisible then qty1:= qty1+qty
            else qty2:= qty2+qty;
          end;
      finally
        prFree(OList);
      end;

      Stream.WriteStr(fnRestValuesForWeb(WareQty, qty0)); // 1 - ���-�� �� ������ �� ���������
      if (ia=0) then begin // �����
        WareTotal:= qty0+qty1+qty2;
        if WareOrAnalogInOrder then s:= arOrderWareQties[ia]  // �������� ������� ���-�� ������
        else s:= FormatFloat('###0.#', WareQty); // � ������ ����� ������ ������� �������������� ��������
      end else begin       // ������
        if OrderExists then s:= arOrderWareQties[ia] else s:= '0';
      end;
      Stream.WriteStr(s);

      Stream.WriteStr(fnRestValuesForWeb(WareQty, qty1)); // 2 - ���-�� �� ��������� ������� �������
      if flAdd then
        Stream.WriteStr(fnRestValuesForWeb(WareQty, qty2)); // 3 - ���-�� �� ������� ���.���������

      Inc(WareCount);
    end;

    Stream.Position:= sPos;
    Stream.WriteInt(WareCount); // ���������� ���-�� ������� (������������ �������)

// ���������� ���� �������� ������������ ��� ����������� �������

ErrPos:= '18-1';
    fnSetTransParams(OrdIBQuery.Transaction, tpWrite, True);
    OrdIBQuery.SQL.Text:= 'INSERT INTO WareRequests (WRWAREID, WRUSERID, WRFROM, WRQTY, WRREST, WRTIME)'+
      'VALUES ('+WareCode+', '+IntToStr(UserID)+', '+fnIfStr(OrderExists, '1', '0')+', :clientqty, :totalqty, "NOW")';
    OrdIBQuery.ParamByName('clientqty').AsFloat:= WareQty;
    OrdIBQuery.ParamByName('totalqty').AsFloat:= WareTotal;
ErrPos:= '18-2';
    s:= RepeatExecuteIBSQL(OrdIBQuery);
    if (s<>'') then fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', s, 'ErrPos='+ErrPos);
  except
    on E: EBOBError do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr(fnReplaceQuotedForWeb(E.Message));
      fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', E.Message, '');
    end;
    on E: Exception do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr(MessText(mtkErrProcess));
      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, 'ErrPos='+ErrPos);
    end;
  end;
  Stream.Position:= 0;
  SetLength(ar, 0);
  prFreeIBSQL(OrdIBQuery);
  cntsORD.SetFreeCnt(OrdIBD);
  SetLength(Storages, 0);
  if OrderExists then SetLength(arOrderWareQties, 0);
  prFree(OList);
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
  flAdd:= flClientStoragesView_add and Contract.HasAddVis;
  //  s:= '�� ������ �������� '+Cache.GetDprtShortName(StoreID);
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
//************************************************************ ��������� �������
procedure prSetCliContMargins(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetCliContMargins'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, FirmID, contID, i, iCount, grpID, parID, errCount: integer;
    errmess, s, ss: string;
    mlst: TLinkList;
    link, ParLink: TQtyLink;
    Client: TClientInfo;
    grp: TWareInfo;
    marg: Double;
    err: array of TCodeAndQty;
begin
  Stream.Position:= 0;
  OrdIBD:= nil;
  OrdIBS:= nil;
//  contID:= 0;
  errCount:= 0;
  errmess:= '';
  SetLength(err, 0);
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    contID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, 0, UserID, FirmID); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserID];
    if not Client.CheckContract(contID) then
      raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));

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
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  SetLength(err, 0);
  Stream.Position:= 0;
end;

{
prGetQtyByAnalogsAndStoragesOrd    +
prGetOptionsOrd                    +
prChangeQtyInOrderLineOrd          +
prShowOrderOrd                     +
prAddLinesToOrderOrd               +
prAddLineFromSearchResToOrderOrd   +
}
//******************************************************************************
end.
