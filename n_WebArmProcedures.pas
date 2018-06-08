unit n_WebArmProcedures; // ��������� ��� WebArm

interface
uses Windows, Classes, SysUtils, Variants, Math, Forms, DateUtils, Contnrs,
     IBDatabase, IBSQL, Registry, ComObj, ActiveX, Excel2000, Types,
     n_free_functions, v_constants, v_DataTrans, n_LogThreads,
     n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common,
     n_DataCacheAddition, n_TD_functions, n_xml_functions, n_DataCacheObjects;

//------------------------------------------------------------ vc
procedure prWebArmAutenticate(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowWebArmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAEWebArmUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSaveWebArmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prManageBrands(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prTNAManagePage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetFilialList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAutoModelInfoLists(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prLoadModelData(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prImportPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetBrandsGB(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetWareList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prProductAddOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ��������� ��������� ������������ ����� � ������
procedure prProductDelOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� �������� ������������� ������ � ������
procedure prLoadModelDataText(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ���������� ������
procedure prShowModelsWhereUsed(Stream: TBoBMemoryStream; ThreadData: TThreadData); //���������� ������ �������, � ������� ����������� �����
procedure prProductGetOrigNumsAndWares(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ��������� ������ ������������ ������� ��� ������ � ����� ���������
procedure prMarkOrNum(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ���������� �������� �� ��������� ����� ������ � ��
procedure prShowCrossOE(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������������ ������, ����� ��� 2� �������
procedure prShowEngineOptions(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� �������������� ���������
procedure prGetTop10Model(Stream: TBoBMemoryStream; ThreadData: TThreadData); // "��������" ����� Top10 ��������� ���������� ������� � ���������� ������ ��� ����������� �����
procedure prLoadEngines(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ ���������� �� �������������
procedure prNewsPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prTestLinksLoading(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetFilterValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowActionNews(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAEActionNews(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSaveImgForAction(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowSysOptionsPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prEditSysOption(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSaveSysOption(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowConstRoles(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prEditConstRoles(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prMarkOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ���������� �������� �� ��������� ����� ������ c ������������� ��������
procedure prAddOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������������� ������ �������
procedure prUiKPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prProductPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);

//------------  �������� ������ ������� Grossbee, TecDoc � ������ ������ �������
procedure prGetLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAddLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ ������� �������� � �������������� ������
procedure prDelLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������� ������ ������� �������� � �������������� ������
procedure prAccountsGetFirmList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAccountsReestrPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSendWareDescrErrorMes(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ���������� ��������� ������������ �� ������
procedure prCheckWareManager(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prModifyLink3(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowConditionPortions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prMarkPortions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowPortion(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCOUPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetCateroryValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSavePortion(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetDeliveriesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prRestorePassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prBlockWebArmUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCheckRestsInStorageForAcc(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAEDNotification(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prNotificationPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prShowNotification(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prCheckContracts(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prWebarmContractList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prManageLogotypesPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prLogotypeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prLoadOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);
 function fnRep47(UserID: integer; var lstBodyMail: TStringList; var FName, Subj,
          ContentType: string; ThreadData: TThreadData; filter_data: string): string;
procedure prGetRadiatorList;
procedure prWebArmResetPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
//------------------------------------------------------------ vc

procedure prCheckEmplRights(cek: TCheckEmplKind; emplID: Integer;                       // ��������� ����� ����������
          var empl: TEmplInfoItem; var FiltCode: Integer); overload;
procedure prCheckEmplRights(cek: TCheckEmplKind; emplID, ForFirmID: Integer;
          var empl: TEmplInfoItem; var firm: TFirmInfo); overload;

//                       ������ � ���������
procedure prWebArmGetRegionalFirms(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // ������ ������������ ���������
procedure prWebArmGetFirmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������ ������ �����������
procedure prWebArmResetUserPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ����� ������
procedure prWebArmSetFirmMainUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // ��������� �������� ������������
procedure prUnblockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // ������������� �������

procedure prWebArmGetFirmAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ ������ �/� ��� ��

//                       ������ �� �������
//procedure prWebArmGetFirmInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // �������� ��������� �/�
procedure prWebArmShowAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // �������� ���� (���� ��� - ������� �����)
procedure prWebArmShowFirmWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // �������� ������� �� ������ � ������� �����
procedure prWebArmEditAccountHeader(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // �������������� ��������� �����
procedure prWebArmEditAccountLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // ����������/��������������/�������� ������ �����
 function fnGetStrSummByDoubleCurr(sum: Double; MainCurr: Integer; AddCurr: Integer=cDefCurrency): String; // ������ � ������ � 2-� �������
procedure prWebArmGetFilteredAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ ������ � ������ �������
procedure prWebArmMakeSecondAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������������ ����� �� �����������
procedure prWebArmMakeInvoiceFromAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������������ ��������� �� �����
procedure prWebArmGetTransInvoicesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // ������ ��������� �������� (����� WebArm)
procedure prWebArmGetTransInvoice(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // �������� ��������� �������� (����� WebArm)
procedure prWebArmAddWaresFromAccToTransInv(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ���������� ������� �� ����� � ��������� �������� (����� WebArm)

//                   ������ � �������� �� �����������
procedure prWebArmGetOrdersToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������ ������
procedure prWebArmAnnulateOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������������ ������
procedure prWebArmRegisterOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������� ������

//                       ������ � ���������
procedure prWebArmGetRegionalZones(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // ������ ��������
procedure prWebArmInsertRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ���������� �������
procedure prWebArmDeleteRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� �������
procedure prWebArmUpdateRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ��������� �������

//                                  ������
procedure prGetBrandsTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // (Web) ������ ������� TecDoc

//                              �������������
procedure prGetManufacturerList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) ������ ��������������
procedure prManufacturerAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // �������� �������������
procedure prManufacturerDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������� �������������
procedure prManufacturerEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // �������� �������������

//                             ��������� ���
procedure prGetModelLineList(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // (+ Web) ������ ��������� ����� �������������
procedure prModelLineAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // �������� ��������� ���
procedure prModelLineDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // ������� ��������� ���
procedure prModelLineEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // �������� ��������� ���

//                                ������
procedure prGetModelLineModels(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // (+ Web) ������ ������� ���������� ����
procedure prGetModelTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // (+ Web) ������ ����� ������
procedure prModelAddToModelLine(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������ � ��������� ���
procedure prModelDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);            // ������� ������
procedure prModelEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);           // �������� ������
procedure prModelSetVisible(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // �������� ��������� ������

//                                ������ �����
procedure prTNAGet(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������ �����
procedure prTNANodeAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // �������� ���� � ������
procedure prTNANodeDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // ������� ���� �� ������
procedure prTNANodeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������������� ���� � ������

//                                ���������
procedure prGetEngineTree(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) ������ ����� ���������

//                               ������, ��������
procedure prGetListAttrGroupNames(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // (+ Web) ������ ����� ���������
procedure prGetListGroupAttrs(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // (+ Web) ������ ��������� ������
procedure prGetWareInfoView(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // ��������� ������ ��� ���������
procedure prGetCompareWaresInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ��������� ������� ��� ���������
procedure prCommonGetRestsOfWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // ����� ��������� ������� ������� (Web & WebArm)
procedure prWebArmGetWaresDescrView(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� ������� ��� ��������� (����� WebArm)
procedure prWebarmGetDeliveries(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // ������ �������� ��� ��������� ������ (WebArm)
procedure prProductWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // ��������� ������ ������ �� �������, �����, ������, ������ ������
procedure prGetWareTypesTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // ������ ����� ������� (���������� �� ������������)
procedure prGetFilteredGBGroupAttValues(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) ������������� ������ �������� ��������� Grossbee
procedure prGetWareSatellites(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // ������ ������������� ������� (Web & WebArm)

//                                �����, ������
procedure prCommonGetWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ����� ������� �� ������.������ (Web & WebArm)  ???
// WebArm
procedure prCommonWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // ����� ������� (WebArm)
procedure prGetWareAnalogs(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // ������ �������� (WebArm)
procedure prCommonSearchWaresByAttr(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ����� ������� �� ��������� ��������� (WebArm)
procedure prCommonGetNodeWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������ ������� �� ���� (WebArm)
procedure prSearchWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // ����� ������� �� ������.������ �� Laximo (WebArm)
// Web
procedure prCommonWareSearch_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // ����� ������� (Web)
procedure prGetWareAnalogs_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // ������ �������� (Web)
procedure prCommonSearchWaresByAttr_new(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ����� ������� �� ��������� ��������� (Web)
procedure prCommonGetNodeWares_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // ������ ������� �� ���� (Web)
procedure prSearchWaresByOE_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // ����� ������� �� ������.������ �� Laximo (Web)
procedure prCommonGetNodeWares_Motul(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ ������� Motul �� ����� ������ (Web)

//                          ������� ��� ��������
procedure prgetTimeListSelfDelivery(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetContractDestPointsList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ �������� ����� ��������� (Web&Webarm)
procedure prGetAvailableTimeTablesList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // ������ ��������� ���������� �� ��������� (Web&Webarm)
procedure prGetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // �������� ���������� �������� �����
procedure prSetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // �������������� ���������� �������� �����
procedure prGetDprtAvailableShipDates(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // ������ ��������� ��� �������� �� ������ (Web & Webarm)

//                               ������
procedure prSaveStrListWithIDToStream(const pLst: TStringList; Stream: TBoBMemoryStream);       // ������ TStringList � ID � Objects � �����
procedure prWebArmGetNotificationsParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // ������ ����������� (WebArm)
 function fnChangePasswordWebarm(UserID: Integer; oldpass, newpass1, newpass2: string): string; // �������� ������ �������������

//**************************** ������ �� TDT, ������ ***************************
//procedure prTestFileExt(pFileExt: string; RepKind: integer);    // ��������� ���������� �����
procedure prFormRepFileName(pFilePath: string; var fname: string; RepKind: integer; flSet: Boolean=False); // ��������� ��� ����� ������
procedure prFormRepMailParams(var Subj, ContentType: string; // ��������� ������ � �������
          var BodyMail: TStringList; RepKind: integer; flSet: Boolean=False);
procedure prGetAutoDataFromTDT(ReportKind, UserID: integer;  // ����� ����� ������ ���� � TDT
          var BodyMail: TStringList; var pFileName, Subj, ContentType: string;
          ThreadData: TThreadData=nil; filter_data: String='');
procedure prSetAutoDataFromTDT(ReportKind, UserID: integer;  // �������� / ��������� ������ ���� �� TDT
          var BodyMail: TStringList; var pFileName, Subj, ContentType: string; ThreadData: TThreadData=nil);
procedure prGetFirmClones(pUserID: Integer; pFileName: String; ThreadData: TThreadData=nil); // 53-stamp - ���������� �/� �������

procedure prMotulSitePage(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // C����� ��� �������� "motul.vladislav.ua"
procedure prMotulSiteManage(Stream: TBoBMemoryStream; ThreadData: TThreadData); // �������� �� �������� "motul.vladislav.ua"

implementation
uses n_IBCntsPool, v_Functions, t_ImportChecking, s_WebArmProcedures;

//==============================================================================
procedure prWebArmAutenticate(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmAutenticate'; // ��� ���������/�������
var sid, UserLogin, UserPsw, sParam, IP, Ident, ErrorPos, s, ss: string;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    UserId, i: integer;
    TimeNow: TDateTime;
    empl: TEmplInfoItem;
    flEnable: Boolean;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBS:=  nil;
  empl:= nil;
  UserId:= 0;
  s:= '';
  try
    UserLogin:= trim(Stream.ReadStr);
    UserPsw:= trim(Stream.ReadStr);
    sid:= trim(Stream.ReadStr);
    IP:= trim(Stream.ReadStr);
    Ident:= trim(Stream.ReadStr);

    sParam:= 'Login='+UserLogin+#13#10'Password='+UserPsw+#13#10'sid='+sid+
             #13#10'IP='+IP+#13#10'Browser='+Ident;
    try
      if ((UserLogin+UserPsw+sid)='') then
        raise EBOBError.Create('�� ������ ��������� ������������.');

      if (UserLogin<>'') then begin
        // ������� ���������, ���� �� ����� ����� � �������
        UserId:= Cache.GetEmplIDbyLogin(UserLogin);
        if (UserId<1) then raise EBOBError.Create('�� ������ ����� '+UserLogin);
        //���� ����� �������� �����, �� ������������ ������� � ������
        if (UserPsw='') then raise EBOBError.Create('������ ������');

        empl:= Cache.arEmplInfo[UserId];
        if (empl.USERPASSFORSERVER<>UserPsw) then raise EBOBError.Create('�������� ������');
        if (empl.RESETPASSWORD) then raise EBoBAutenticationError.Create(IntToStr(aeResetPassword));
ErrorPos:='0-2';
        sid:= IntToStr(UserID)+'|'+fnGetSessionID;
        s:= ', EMPLSESSIONID="'+sid+'"';
ErrorPos:='1-0';

      end else begin // if (UserLogin<>'')
        if (sid='') then
          raise EBOBError.Create('������ �����������. ������ ������������� ���c��.');

        UserId:= Cache.GetEmplIDBySession(sid);
        if (UserId<1) then
          raise EBOBError.Create('������ �����������. ������������� ���c�� ������� ��� ��������.');
        if (Copy(sid, 1, Pos('|', sid)-1)<>IntToStr(UserId)) then
          raise EBOBError.Create('������ �����������. ������������ ������������� ���c��.');

        empl:= Cache.arEmplInfo[UserId];
        if ((now-empl.LastActionTime)>Cache.GetConstItem(pcClientTimeOutWebArm).IntValue/24/60) then
          raise EBOBError.Create('����� ���������������� ������ �������.'+
            ' �������� ������ ��������� �����������, ��������� ����� � ������.');
ErrorPos:='1-5';
      end; //if (UserLogin<>'') else

      if empl.Arhived then
        raise EBOBError.Create('������� ������ ������������� ��������������� GrossBee.');
      if empl.Blocked then
        raise EBOBError.Create('������� ������ ������������� ��������������� werbarm.');

//-------------------------------------- nk
if flDisableOut then begin
      flEnable:= not empl.DisableOut;
      if not flEnable then begin // ������ �������� ���������� IP ����� ������� (192.168.,172.20.)
        ss:= trim(Cache.GetConstItem(pcInnerIPshablons).StrValue);
        flEnable:= (ss=''); // ������� �� ������
      end; // if not flEnable
      if not flEnable then with fnSplit(',', ss) do try // TStringList
        for i:= 0 to Count-1 do begin
          ss:= trim(Strings[i]);
          flEnable:= (copy(trim(IP), 1, length(ss))=ss);
          if flEnable then break;
        end;
      finally
        Free;
      end; // with fnSplit
      if not flEnable then
        raise EBOBError.Create('�������� ������ � Webarm �� �� ���� ��������.'+
          cSpecDelim+'������ �� �������������� ������� ����������� �� '+
          Cache.GetConstItem(pcUIKdepartmentMail).StrValue);
end;
//-------------------------------------- nk

      TimeNow:= Now();
      try
        ordIBD:= CntsOrd.GetFreeCnt;
        OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);
ErrorPos:='1-10';
        OrdIBS.SQL.Text:= 'UPDATE EMPLOYEES SET EMPLLASTACTION=:TimeNow'+s+
                          ' WHERE EMPLCODE='+IntToStr(UserId);
        OrdIBS.ParamByName('TimeNow').AsDateTime:= TimeNow;
        s:= RepeatExecuteIBSQL(OrdIBS);
        if (s<>'') then raise Exception.Create(s);
      finally
        prFreeIBSQL(OrdIBS);
        cntsORD.SetFreeCnt(ordIBD);
      end;
ErrorPos:='1-15';
      if (UserLogin<>'') then Empl.Session:= sid;
      Empl.LastActionTime:= TimeNow;
ErrorPos:='2-0';
    finally
      prSetThLogParams(ThreadData, csWebArmAutentication, UserId, 0, sParam);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(UserID);
    Stream.WriteStr(sid);
    Stream.WriteDouble(Now());
ErrorPos:='2-5';
    Stream.WriteIntArray(Empl.UserRoles);
ErrorPos:='2-6';
//    Stream.WriteInt(Cache.GetEmplImportsCount(UserID));
//    Stream.WriteInt(Integer(Cache.GetEmplAllowRepImp(UserID)));
    Stream.WriteBool(Cache.GetEmplAllowRepImp(UserID)); // ������� ������� ����������� �������/�������� � ����������
ErrorPos:='2-7';
    Stream.WriteBool(Cache.WareCacheUnLocked);
ErrorPos:='2-8';
    Stream.WriteBool(Cache.GetEmplConstantsCount(UserID)>0);
ErrorPos:='2-9';
    Stream.WriteStr(Empl.EmplShortName);
ErrorPos:='2-10';
    Stream.WriteBool(Cache.GBAttributes.HasNewGroups); // ������� ������� ����� ����� ���������
  except
    on E: EBoBAutenticationError do begin
      i:= StrToIntDef(E.Message, -1);
      Stream.Clear;
      if (i=aeResetPassword) then begin
          Stream.WriteInt(i);
          Stream.WriteInt(UserID);
      end else begin
        s:= '����������� ��� ������ �����������';
        Stream.WriteInt(aeCommonError);
        Stream.WriteStr(s+' - '+E.Message);
        fnWriteToLog(ThreadData, lgmsUserError, nmProc, s, E.Message, '');
      end;
    end;
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prShowWebArmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowWebArmUsers'; // ��� ���������/�������
var UserId, i, iCount, j, Pos, pos1: integer;
    Empl: TEmplInfoItem;
    lst: TList;
    list: TStringList;
    Roles: Tai;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowWebArmUsers, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserId].UserRoleExists(rolManageUsers) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos1:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� �������

    pos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� �����������
    iCount:= 0;
    lst:= TList.Create;
    for i:= 0 to High(Cache.arEmplInfo) do if Cache.EmplExist(i) then begin
      Empl:= Cache.arEmplInfo[i];
      if Empl.Arhived then Continue;
      Stream.WriteInt(i);
      Stream.WriteStr(Empl.EmplShortName);
      if (Empl.UserPassForServer<>'') then lst.Add(Empl); // �������� ������ � ��������
      Inc(iCount);
    end;
    Stream.Position:= pos;
    Stream.WriteInt(iCount);
    Stream.Position:= Stream.Size;

    List:= Cache.GetFilialList(True); // ������������� ������ ����.������������ ��������
    Stream.WriteStringList(list, true);

    Roles:= Cache.GetAllRoleCodes;
    iCount:= Length(Roles);
    Stream.WriteInt(iCount); // ���-�� �����
    for i:= 0 to iCount-1 do begin
      j:= Roles[i];
      Stream.WriteInt(j);
      Stream.WriteStr(Cache.GetRoleName(j));
    end;

    iCount:= lst.Count;
    for i:= 0 to iCount-1 do begin
      Empl:= lst[i];
      Stream.WriteInt(Empl.ID);
      Stream.WriteStr(Empl.ServerLogin);
      Stream.WriteInt(Empl.EmplDprtID);
      Stream.WriteStr(Empl.GBLogin);
      Stream.WriteBool(Empl.Blocked);
    end;

    Stream.Position:= pos1;
    Stream.WriteInt(iCount);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(list);
  prFree(lst);
  SetLength(Roles, 0);
  Stream.Position:= 0;
end;
//==============================================================================
procedure prAEWebArmUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAEWebArmUser'; // ��� ���������/�������
var gbIBD: TIBDatabase;
    GBIBSQL: TIBSQL;
    UserId, EmplId, i: integer;
    Empl: TEmplInfoItem;
    list, loglist: TStringList;
    s: String;
    fl: Boolean;
begin
  Stream.Position:= 0;
  GBIBSQL:= nil;
//  gbIBD:= nil;
  list:= nil;
  loglist:= nil;
  try
    UserID:= Stream.ReadInt;
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csAEWebArmUser, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserId].UserRoleExists(rolManageUsers) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (EmplID>0) and not Cache.EmplExist(EmplID)  then
      raise EBOBError.Create('�� ������ ������������ ��� ��������������.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    loglist:= TStringList.Create; // ������ ������� ������� �������
    list:= TStringList.Create;
    for i:= 1 to High(Cache.arEmplInfo) do if Cache.EmplExist(i) then begin
      Empl:= Cache.arEmplInfo[i];
      if Empl.Arhived then Continue;
      fl:= (i=EmplID) or ((EmplID<1) and (Empl.ServerLogin=''));
      if fl then list.AddObject(Empl.EmplShortName, Pointer(i));
      if (i=EmplID) then Continue;
      if (Empl.GBLogin<>'') then loglist.Add(AnsiUpperCase(Empl.GBLogin));
      if (Empl.GBReportLogin<>'') then loglist.Add(AnsiUpperCase(Empl.GBReportLogin));
    end;
    list.Sort;
    Stream.WriteStringList(list, true);
    list.Clear;

    loglist.Sort;
    loglist.Sorted:= True;

    gbIBD:= CntsGRB.GetFreeCnt;
    try
      GBIBSQL:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBSQL.SQL.Text:= 'Select USLSUSERID from USERLIST'+
        ' left join USERROLES on USRLCODE=USLSROLECODE'+
        ' where uslsarchive="F" and usrlcode<>21 order by USLSUSERID'; // ���������� � ���� <> "�������� ������������"
      GBIBSQL.ExecQuery;
      while not GBIBSQL.EOF do begin
        s:= GBIBSQL.FieldByName('USLSUSERID').AsString;
{        fl:= False;
        for i:= 1 to High(Cache.arEmplInfo) do begin
          if not Cache.EmplExist(i) then Continue;
          if (i=EmplID) then Continue;
          Empl:= Cache.arEmplInfo[i];
          fl:= AnsiSameText(Empl.GBLogin, s) or
               AnsiSameText(Empl.GBReportLogin, s);
          if fl then break;
        end; // for  }
        fl:= loglist.IndexOf(AnsiUpperCase(s))<0;
        if fl then list.Add(s);
        TestCssStopException;
        GBIBSQL.Next;
      end;
    finally
      prFreeIBSQL(GBIBSQL);
      CntsGRB.SetFreeCnt(gbIBD, false);
    end;
    list.Sort;
    Stream.WriteStringList(list, false);

    if (EmplID>0) then begin
      Empl:= Cache.arEmplInfo[EmplID];
      Stream.WriteStr(Empl.ServerLogin);
      Stream.WriteStr(Empl.USERPASSFORSERVER);
      Stream.WriteStr(IntToStr(Empl.EmplDprtID));
      Stream.WriteStr(Empl.GBLogin);
      Stream.WriteStr(Empl.GBReportLogin);
//-------------------------------------- nk
if flDisableOut then
      Stream.WriteBool(empl.DisableOut); // ������ �� ������ � webarm � ������� IP
//-------------------------------------- nk
      Stream.WriteIntArray(Empl.UserRoles);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(list);
  prFree(loglist);
  Stream.Position:= 0;
end;
//==============================================================================
procedure prSaveWebArmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveWebArmUsers'; // ��� ���������/�������
var gbIBD, ordIBD: TIBDatabase;
    GBIBSQL, OrdIBSQL: TIBSQL;
    UserId, EmplID, aEmplCodeID, GBID, GBID_o, DprtID, i: integer;
    Empl, EmplUser: TEmplInfoItem;
    s, ss, aLogin, aPass, aGBLogin, aGBLogin_O, sEmpl, sDprt: string;
    NewRoles, Roles: Tai;
    flDisable, flGBLogin, flGBLogin_O, flDprt, flPassw: Boolean;
  //------------------------------------------
  procedure prRoleToBase(CurRole: integer; flAdd: boolean; Empl: TEmplInfoItem; OrdIBSQL: TIBSQL);
  var RolePresent: boolean;
  begin
    RolePresent:= empl.UserRoleExists(CurRole);
    if (RolePresent=flAdd) then Exit;

    s:= IntToStr(Empl.EmplID);
    ss:= IntToStr(CurRole);
    OrdIBSQL.SQL.Text:= fnIfStr(flAdd,
      'INSERT INTO EMPLOYEESROLES (EMRLEMPLCODE, EMRLROLECODE) VALUES ('+s+', '+ss+')',
      'DELETE FROM EMPLOYEESROLES where EMRLEMPLCODE='+s+' and EMRLROLECODE='+ss);
    try
      OrdIBSQL.ExecQuery;
    except
      on E: Exception do fnWriteToLog(ThreadData, lgmsUserError, 'prRoleToBase', '', E.Message, '');
    end;
  end;
  //------------------------------------------
  procedure prApplyRole(CurRole: integer; flAdd: boolean; Empl: TEmplInfoItem);
  var index: integer;
  begin
    index:= fnInIntArray(CurRole, Empl.UserRoles);
    if (index>-1)=flAdd then Exit;
    if flAdd then  prAddItemToIntArray(CurRole, Empl.UserRoles)
    else prDelItemFromArray(index, Empl.UserRoles);
  end;//
  //------------------------------------------
begin
  Stream.Position:= 0;
  GBIBSQL:= nil;
  gbIBD:= nil;
  OrdIBSQL:= nil;
  ordIBD:= nil;
  GBID:= 0;
  GBID_o:= 0;
  flDisable:= False;
  try
    UserID:= Stream.ReadInt;
    EmplID:= Stream.ReadInt;
    aLogin:= Stream.ReadStr;
    aPass:= Stream.ReadStr;
    sEmpl:= Stream.ReadStr;
    sDprt:= Stream.ReadStr;
    aGBLogin:= Stream.ReadStr;
    aGBLogin_O:= Stream.ReadStr;
    NewRoles:= Stream.ReadIntArray;
//--------------------------------------
if flDisableOut then
    flDisable:= Stream.ReadBool; // ������ �� ������ � webarm � ������� IP
//--------------------------------------

    prSetThLogParams(ThreadData, csSaveWebArmUsers, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    EmplUser:= Cache.arEmplInfo[UserId];
    if not EmplUser.UserRoleExists(rolManageUsers) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    DprtID:= StrToIntDef(sDprt, 0);
    if (DprtID<1) then raise EBOBError.Create('�������� ������������� �������  - '+sDprt);
    if (not Cache.DprtExist(DprtID) or not Cache.arDprtInfo[DprtID].IsFilial) then
      raise EBOBError.Create('������ �������� ������������� ��� ������������� �� �������� ��������.');

    if (EmplID>0) then begin
      if not Cache.EmplExist(EmplID) then
        raise EBOBError.Create('�� ������� ������ ��� ��������������.');
//      aEmplCodeID:= 0;
      Empl:= Cache.arEmplInfo[EmplID];
      flGBLogin:= not AnsiSameText(aGBLogin, Empl.GBLogin);
      flGBLogin_O:= not AnsiSameText(aGBLogin_O, Empl.GBReportLogin);
      flDprt:= (DprtID<>Empl.EmplDprtID);
      flPassw:= not AnsiSameText(aPass, Empl.UserPassForServer);

    end else begin // �����
      aEmplCodeID:= StrToIntDef(sEmpl, 0);
      if (aEmplCodeID<1) then
        raise EBOBError.Create('�������� ������������� �������������� ���������� - '+sEmpl);
      if not Cache.EmplExist(aEmplCodeID) then
        raise EBOBError.Create('�� ������� ������������� ������ ������������.');
      if not fnCheckOrderWebLogin(aLogin) then
  //      raise EBOBError.Create('����� �� ������������� �������� �����������.');
        raise EBOBError.Create('������������ ����� - '+aLogin+'. '+
          MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
      Empl:= Cache.arEmplInfo[aEmplCodeID];
      flGBLogin:= (aGBLogin<>'');
      flGBLogin_O:= (aGBLogin_O<>'');
      flDprt:= True;
      flPassw:= True;
    end;
//      raise EBOBError.Create('������ ���� ������ ���� ����� ��������� ��� ���������� ���� ������ ��� ��������������.');  // ???
    if not fnCheckOrderWebPassword(aPass) then
//      raise EBOBError.Create('������ �� ������������� �������� �����������.');
      raise EBOBError.Create('������������ ������. '+
        MessText(mtkNotValidPassw, IntToStr(Cache.CliPasswLength)));

//--------------------------------------
if not flDisableOut then
    flDisable:= Empl.DisableOut;
//--------------------------------------

    if flGBLogin and (aGBLogin<>'') then begin
      i:= Cache.GetEmplIDByGBLogin(aGBLogin);
      if (i>0) and (i<>Empl.ID) then
        raise EBOBError.Create('����� ����� GrossBee ��� ������������');
    end;
    if flGBLogin_O and (aGBLogin_O<>'') then begin
      i:= Cache.GetEmplIDByGBLogin(aGBLogin_O);
      if (i>0) and (i<>Empl.ID) then
        raise EBOBError.Create('����� ����� GrossBee ��� ������� ��� ������������');
    end;

    if (flGBLogin and (aGBLogin<>'')) or (flGBLogin_O and (aGBLogin_O<>'')) then try
      gbIBD:= CntsGRB.GetFreeCnt(EmplUser.GBLogin, cDefPassword, cDefGBrole);
      GBIBSQL:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      if (aGBLogin<>'') then begin
        GBIBSQL.SQL.Text:= 'Select USLSCODE from USERLIST'+
                           ' WHERE UPPERCASE(USLSUSERID)="'+UpperCase(aGBLogin)+'"';
        GBIBSQL.ExecQuery;
        if (GBIBSQL.BoF and GBIBSQL.EoF) then
          raise EBOBError.Create('�� ������ ����� GrossBee');
        GBID:= GBIBSQL.Fields[0].AsInteger;
        GBIBSQL.Close;
      end;
      if (aGBLogin_O<>'') then begin
        GBIBSQL.SQL.Text:= 'Select USLSCODE from USERLIST'+
                           ' WHERE UPPERCASE(USLSUSERID)="'+UpperCase(aGBLogin_O)+'"';
        GBIBSQL.ExecQuery;
        if (GBIBSQL.BoF and GBIBSQL.EoF) then
          raise EBOBError.Create('�� ������ ����� GrossBee ��� �������');
        GBID_o:= GBIBSQL.Fields[0].AsInteger;
        GBIBSQL.Close;
      end;
    finally
      prFreeIBSQL(GBIBSQL);
      CntsGRB.SetFreeCnt(gbIBD, false);
    end;

    s:= '';
    ss:= '';
    if (EmplID<1) then begin // �����
      if (GBID>0) then begin
        s:= s+', EMPLGBUSER';
        ss:= ss+', '+IntToStr(GBID);
      end;
      if (GBID_o>0) then begin
        s:= s+', EMPLGBREPORTUSER';
        ss:= ss+', '+IntToStr(GBID_o);
      end;
//--------------------------------------
if flDisableOut then
      if not flDisable then begin
        s:= s+', EMPLDISABLEOUT';
        ss:= ss+', "F"';
      end;
//--------------------------------------
      s:= 'INSERT INTO EMPLOYEES (EMPLCODE, EMPLDPRTCODE, EMPLLOGIN, EMPLPASS'+s+
          ') VALUES ('+IntToStr(Empl.ID)+', '+IntToStr(DprtID)+', '+
          QuotedStr(aLogin)+', '+QuotedStr(aPass)+ss+')';

    end else begin
      if flPassw then s:= s+fnIfStr(s='','',', ')+'EMPLPASS='+QuotedStr(aPass);
      if flDprt then s:= s+fnIfStr(s='', '', ', ')+'EMPLDPRTCODE='+IntToStr(DprtID);
      if flGBLogin then
        s:= s+fnIfStr(s='', '', ', ')+'EMPLGBUSER='+fnIfStr(GBID<1, 'NULL', IntToStr(GBID));
      if flGBLogin_O then
        s:= s+fnIfStr(s='', '', ', ')+'EMPLGBREPORTUSER='+fnIfStr(GBID_o<1, 'NULL', IntToStr(GBID_o));
//--------------------------------------
if flDisableOut then
      if (flDisable<>empl.DisableOut) then
        s:= s+fnIfStr(s='', '', ', ')+'EMPLDISABLEOUT="'+fnIfStr(flDisable, 'T', 'F')+'"';
//--------------------------------------
      if s<>'' then s:= 'UPDATE EMPLOYEES SET '+s+' WHERE EMPLCODE='+IntToStr(EmplID);
    end;

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);

    if (s<>'') then begin
      OrdIBSQL.SQL.Text:= s;
      OrdIBSQL.ExecQuery;
    end;

    Cache.CS_Empls.Enter;
    try
      if (EmplId<1) then Empl.ServerLogin:= aLogin;
      if flPassw then Empl.UserPassForServer:= aPass;
      if flDprt then Empl.EmplDprtID:= DprtID;
      if flGBLogin then Empl.GBLogin:= aGBLogin;
      if flGBLogin_O then Empl.GBReportLogin:= aGBLogin_O;
//--------------------------------------
if flDisableOut then
      if (flDisable<>empl.DisableOut) then empl.DisableOut:= flDisable;
//--------------------------------------

      if (fnInIntArray(rolCustomerService, NewRoles)>-1) then // �� - �������� ���
        prAddItemToIntArray(rolOPRSK, NewRoles);

      Roles:= Cache.GetAllRoleCodes;
      for i:= 0 to High(Roles) do
        prRoleToBase(Roles[i], (fnInIntArray(Roles[i], NewRoles)>-1), Empl, OrdIBSQL);

      OrdIBSQL.Transaction.Commit;

      for i:= 0 to High(Roles) do
        prApplyRole(Roles[i], (fnInIntArray(Roles[i], NewRoles)>-1), Empl);
    finally
      Cache.CS_Empls.Leave;
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(Empl.EmplId);
    Stream.WriteInt(Empl.EmplDprtID);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(NewRoles, 0);
  SetLength(Roles, 0);
  prFreeIBSQL(OrdIBSQL);
  CntsOrd.SetFreeCnt(ordIBD, false);
  Stream.Position:= 0;
end;
//==============================================================================
procedure prAccountsReestrPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAccountsReestrPage'; // ��� ���������/�������
var UserId, LineCount, sPos, k, sm: integer;
    SL: TStringList;
    Empl:  TEmplInfoItem;
    s: string;
    curr: TCurrency;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csAccountsReestrPage, UserId);

    if CheckNotValidUser(UserId, isWe, s) then raise EBOBError.Create(s); // �������� �����

    Empl:= Cache.arEmplInfo[UserId];
    if not Empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    prSaveEmplStoresChoiceList(Stream, UserId, true);  // ������ � Stream ������ ������� ���������� �������(+�����) ��� ������
    prSaveEmplFirmsChoiceList(Stream, UserId);

    //---------------------------------------------- �������� ��� ������
    LineCount:= 0;       // �������
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  ����� ��� ���-�� �����
    for k:= 0 to Cache.Currencies.ItemsList.Count-1 do begin
      curr:= Cache.Currencies.ItemsList[k];
      if not curr.Arhived and (curr.Name<>'') then begin
        Stream.WriteInt(curr.ID);   // ��� ������
        Stream.WriteStr(curr.Name); // ������������ ������
        inc(LineCount);
      end;
    end;
    Stream.Position:= sPos;
    Stream.WriteInt(LineCount);
    Stream.Position:= Stream.Size;

    SL:= Cache.GetShipMethodsList();
    try
      Stream.WriteInt(SL.Count-1);
      for k:=0 to SL.Count-1 do begin
        sm:= integer(SL.Objects[k]);
        Stream.WriteInt(sm);
        Stream.WriteStr(SL[k]);
        Stream.WriteBool(Cache.GetShipMethodNotTime(sm));
        Stream.WriteBool(Cache.GetShipMethodNotLabel(sm));
      end;
    finally
      prFree(SL);
    end;

    SL:= Cache.GetShipTimesList();
    try
      Stream.WriteStringList(SL, true);
    finally
      prFree(SL);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prAccountsGetFirmList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAccountsGetFirmList'; // ��� ���������/�������
var UserId, i, j, arlen, pos1: integer;
    templ: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    templ:= UpperCase(trim(Stream.ReadStr));

    prSetThLogParams(ThreadData, csAccountsGetFirmList, UserId);

    if not Cache.EmplExist(UserID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserId].UserRoleExists(rolOPRSK) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos1:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-�� ����
    if (Length(templ)>3) then begin
      arlen:= Length(Cache.arFirmInfo)-1;
      j:= 0;
      for i:= 0 to arlen do if Assigned(Cache.arFirmInfo[i]) then
        with Cache.arFirmInfo[i] do if not Arhived and (pos(templ, UpperCase(Name))>0) then begin
          Stream.WriteInt(i);
          Stream.WriteStr(Name);
          Inc(j);
        end;
      Stream.Position:= pos1;
      Stream.WriteInt(j);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================= ���������� ������ �������, � ������� ����������� �����
procedure prShowModelsWhereUsed(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowModelsWhereUsed'; // ��� ���������/�������
var s: string;
    UserId, WareID, FirmID, WhatShow, i, MFAID, j, jCount, sysID: integer;
    List: TList;
    Model: TModelAuto;
    mps: TModelParams;
    Manufs: TObjectList;
    flSaveModels: Boolean;
    lst: TStringList;
    tt: TTwoCodes;
begin
  Stream.Position:= 0;
  Manufs:= TObjectList.Create;
  List:= nil;
  Lst:= nil;
  jCount:= 0;
  try
    FirmID  := Stream.ReadInt;
    UserID  := Stream.ReadInt;
    WareID  := Stream.ReadInt;
    WhatShow:= Stream.ReadByte;
    MFAID   := Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowModelsWhereUsed, UserId, FirmID,
      'Wareid='+IntToStr(WareID)+#13#10'WhatShow='+IntToStr(WhatShow)+
      #13#10'MFAID='+IntToStr(MFAID)); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    sysID:= WhatShow;
    if not CheckTypeSys(sysID) then
      raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(sysID)));

    List:= Cache.arWareInfo[WareID].GetSysModels(sysID, MFAID, True);
    case sysID of
      constIsMoto: s:='����';
      constIsAuto: s:='����.����';
      constIsCV  : s:='����.����';
      constIsAx  : s:='����';
    end;
    if (List.Count<1) then raise EBOBError.Create('� ����� ������ �� ��������� ������ '+s+'.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    //----------------------------- ���� ����� - ��������� ������ ��������������
    flSaveModels:= (MFAID>0) or (List.Count<=Cache.GetConstItem(pcSearchCountTypeAsk).IntValue);
    if not flSaveModels then begin
      WhatShow:= 0;
      j:= -1;
      for i:= 0 to List.Count-1 do begin
        Model:= TModelAuto(List[i]);
        MFAID:= Model.ModelMfauID;
        if not (Cache.FDCA.ManufAutoExist(MFAID)) then Continue;

        if (MFAID<>WhatShow) then begin
          if (j>-1) and (jCount>0) then TTwoCodes(Manufs[j]).ID2:= jCount;
          jCount:= 0;
          j:= Manufs.Add(TTwoCodes.Create(MFAID, 0));
          WhatShow:= MFAID;
        end;
        inc(jCount);
//        if (Cache.FDCA.ManufAutoExist(MFAID)) then prAddOrIncTwoCode(Manufacturers, MFAID);
      end;
      if (j>-1) and (jCount>0) then TTwoCodes(Manufs[j]).ID2:= jCount;
      flSaveModels:= (Manufs.Count<2);
    end;

    if flSaveModels then begin //------------------------------- �������� ������
      lst:= Cache.GetWareModelUsesAndTextsView(WareID, List); // ������� ������������
      Stream.WriteInt(List.Count); // ���-�� �������
      for i:= 0 to List.Count-1 do begin
        Model:= TModelAuto(List[i]);
        mps:= Model.Params;
        Stream.WriteInt(Model.ID);
        Stream.WriteInt(Model.SubCode);
        Stream.WriteInt(Model.ModelLineID);
        Stream.WriteInt(Model.ModelMfauID);
        Stream.WriteStr(Lst[i]);               // ������� ������������
        Stream.WriteStr(Model.ModelMfauName);
        Stream.WriteStr(Model.ModelLineName);
        Stream.WriteStr(Model.Name);
        Stream.WriteInt(mps.pYStart); // ��� ������ �������
        Stream.WriteInt(mps.pMStart); // ����� ������ �������
        Stream.WriteInt(mps.pYEnd);   // ��� ��������� �������
        Stream.WriteInt(mps.pMEnd);   // ����� ��������� �������

        case sysID of
          constIsMoto, constIsAuto: begin
            Stream.WriteInt(mps.pHP);              // ��
            Stream.WriteStr(Model.MarksCommaText); // ���������
          end;
          constIsCV: begin
            Stream.WriteStr(mps.cvHPaxLOout);      // �� ��-��
            s:= mps.cvTonnOut;                     // ������
            if (s<>'') then s:=s+' �';
            Stream.WriteStr(s);
            Stream.WriteStr(Model.MarksCommaText); // ���������
          end;
          constIsAx: begin
            s:= mps.cvHPaxLOout;
            if (s<>'') then s:=s+' ��';
            Stream.WriteStr(s);                    // �������� �� ��� [��] ��-��
            if (mps.pDriveID<1) then s:= ''
            else s:= Cache.FDCA.TypesInfoModel.InfoItems[mps.pDriveID].Name;
            Stream.WriteStr(s);                    // ��� ���
          end;
        end; // case
      end;

    end else begin  //--------------------------- �������� ������ ��������������
      Manufs.Sort(@SortCompareManufNamesForTwoCodes);
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteInt(-Manufs.Count);// ���-�� ��������������
      for i:= 0 to Manufs.Count-1 do begin
        tt:= TTwoCodes(Manufs[i]);
        Stream.WriteInt(tt.ID1);
        Stream.WriteStr(Cache.FDCA.Manufacturers[tt.ID1].Name);
        Stream.WriteInt(tt.ID2);
      end;
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
  prFree(Manufs);
  prFree(Lst);
end;
//==============================================================================
procedure prManageBrands(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManageBrands'; // ��� ���������/�������
var UserId: integer;
    s: String;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csManageBrands, UserId);

    if CheckNotValidUser(UserID, isWe, s) then raise EBOBError.Create(s);

    if not Cache.arEmplInfo[UserId].UserRoleExists(rolManageBrands) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prTNAManagePage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNAManagePage'; // ��� ���������/�������
var UserId: integer;
    PageType: byte;
    s: String;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    PageType:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csTNAManagePage, UserId, 0, 'PageType='+IntToStr(PageType));

    if CheckNotValidUser(UserID, isWe, s) then raise EBOBError.Create(s);

    with Cache.arEmplInfo[UserId] do
      if ((PageType=constIsAuto) and not UserRoleExists(rolTNAManageAuto))
        or ((PageType=constIsMoto) and not UserRoleExists(rolTNAManageMoto))
        or ((PageType=constIsCV) and not UserRoleExists(rolTNAManageCV)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prGetFilialList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFilialList'; // ��� ���������/�������
var UserId, VarTo, i: integer;
    list: TStringList;
    s: String;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetFilialList, UserId);

    if CheckNotValidUser(UserID, isWe, s) then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    list:= TStringList.Create;

    varTo:= Length(Cache.arDprtInfo)-1;
    for i:= 0 to varTo do if Cache.DprtExist(i) and Cache.arDprtInfo[i].IsFilial then
      list.AddObject(Cache.arDprtInfo[i].ShortName, Pointer(i));

    if (list.Count>1) then list.Sort;
    Stream.WriteStringList(list, true);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//==============================================================================
procedure prAutoModelInfoLists(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAutoModelInfoLists'; // ��� ���������/�������
var UserId, FirmId, i: integer;
    list: TStringList;
    s: String;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    for i:= 1 to 9 do begin
      Stream.WriteStringList(Cache.FDCA.TypesInfoModel.InfoModelList[i], true);
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//==============================================================================
procedure prLoadModelData(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLoadModelData'; // ��� ���������/�������
var UserId, FirmId, i: integer;
    list: TStringList;
    Model: TModelAuto;
    s: String;
begin
  Stream.Position:= 0;
  List:=nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    i:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csLoadModelData, UserId, FirmID, '');

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if not Cache.FDCA.Models.ModelExists(i) then raise EBOBError.Create('�� ������� �������� ������');
    Model:= Cache.FDCA.Models.GetModel(i);

    Stream.WriteInt(Model.ID);                // ��� ������
    Stream.WriteStr(Model.Name);              // �������� ������
    Stream.WriteBool(Model.IsVisible);        // ��������� ������
    Stream.WriteBool(Model.IsTop);            // ��� ������
    Stream.WriteInt(Model.Params.pYStart);            // ��� ������ �������
    Stream.WriteInt(Model.Params.pMStart);            // ����� ������ �������
    Stream.WriteInt(Model.Params.pYEnd);              // ��� ��������� �������
    Stream.WriteInt(Model.Params.pMEnd);              // ����� ��������� �������

    Stream.WriteInt(Model.Params.pKW);                // �������� ���
    Stream.WriteInt(Model.Params.pHP);                // �������� ��
    Stream.WriteInt(Model.Params.pCCM);               // ���. ����� ���.��.
    Stream.WriteInt(Model.Params.pCylinders);         // ���������� ���������
    Stream.WriteInt(Model.Params.pValves);            // ���������� �������� �� ���� ������ ��������
    Stream.WriteInt(Model.Params.pBodyID);            // ���, ��� ������
    Stream.WriteInt(Model.Params.pDriveID);           // ���, ��� �������
    Stream.WriteInt(Model.Params.pEngTypeID);         // ���, ��� ���������
    Stream.WriteInt(Model.Params.pFuelID);            // ���, ��� �������
    Stream.WriteInt(Model.Params.pFuelSupID);         // ���, ������� �������
    Stream.WriteInt(Model.Params.pBrakeID);           // ���, ��� ��������� �������
    Stream.WriteInt(Model.Params.pBrakeSysID);        // ���, ��� ��������� �������
    Stream.WriteInt(Model.Params.pCatalID);           // ���, ��� ������������
    Stream.WriteInt(Model.Params.pTransID);           // ���, ��� ������� �������
    Stream.WriteInt(Model.ModelOrderNum);             // ���������� �����
    Stream.WriteStr(Model.MarksCommaText);            // ���������� ����������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//=================================================== �������� ���������� ������
procedure prLoadModelDataText(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLoadModelDataText'; // ��� ���������/�������
var UserId, FirmId, ModelID, sysID, iPos, iCount: integer;
    Model: TModelAuto;
    mps: TModelParams;
    tim: TTypesInfoModel;
    ErrorPos, s: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;
ErrorPos:='00';
    prSetThLogParams(ThreadData, csLoadModelDataText, UserId, FirmID, 'ModelID='+IntToStr(ModelID));

    if (FirmID<>isWe) then begin                               // �������� Web
      if not Cache.ClientExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotClientExist));
      if not Cache.FirmExist(FirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
      if Cache.arClientInfo[UserID].FirmID<>FirmID then
        raise EBOBError.Create(MessText(mtkNotClientOfFirm));
    end else                                                  // �������� WebArm
      if not Cache.EmplExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotEmplExist));
ErrorPos:='05';
    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create('�� ������� �������� ������');

    Model:= Cache.FDCA.Models.GetModel(ModelID);
    sysID:= Model.TypeSys;
    mps:= Model.Params;
    tim:= Cache.FDCA.TypesInfoModel;
ErrorPos:='10';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    iCount:= 0;
    iPos:= Stream.Position;
    Stream.WriteInt(iCount); // ����� ��� ���-�� ���: �������� - ��������

    Stream.WriteStr('������������ ������:');
    Stream.WriteStr(Model.Name);
    inc(iCount);

    if (mps.pYStart>0) then begin
      s:= IntToStr(mps.pYStart);
      if (mps.pMStart>0) then s:= fnMakeAddCharStr(IntToStr(mps.pMStart), 2, '0')+'.'+s;
      Stream.WriteStr('������ �������:');
      Stream.WriteStr(s);
      inc(iCount);
    end;
    if (mps.pYEnd>0) then begin
      s:= IntToStr(mps.pYEnd);
      if (mps.pMEnd>0) then s:= fnMakeAddCharStr(IntToStr(mps.pMEnd), 2, '0')+'.'+s;
      Stream.WriteStr('��������� �������:');
      Stream.WriteStr(s);
      inc(iCount);
    end;
ErrorPos:='15';
    case sysID of
      constIsAuto, constIsMoto: begin //----------------------------- auto, moto
        if (mps.pBodyID>0) then begin   // ��� ������
          Stream.WriteStr(tim.GetItemTypeName(mps.pBodyID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBodyID].Name);
          inc(iCount);
        end;
        if (mps.pDriveID>0) then begin // ��� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pDriveID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pDriveID].Name);
          inc(iCount);
        end;
        if (mps.pKW>0) then begin // �������� [���]
          Stream.WriteStr(tim.GetTypeName(cvtKW)+':');
          Stream.WriteStr(IntToStr(mps.pKW));
          inc(iCount);
        end;
        if (mps.pHP>0) then begin // �������� [��]
          Stream.WriteStr(tim.GetTypeName(cvtHP)+':');
          Stream.WriteStr(IntToStr(mps.pHP));
          inc(iCount);
        end;
        if (mps.pCCM>0) then begin
          Stream.WriteStr('���.����� [���.��]:');
          Stream.WriteStr(IntToStr(mps.pCCM));
          inc(iCount);
        end;
        if (mps.pValves>0) then begin
          Stream.WriteStr('���-�� �������� �� ������ ��������:');
          Stream.WriteStr(IntToStr(mps.pValves));
          inc(iCount);
        end;
        if (mps.pCylinders>0) then begin
          Stream.WriteStr('���������� ���������:');
          Stream.WriteStr(IntToStr(mps.pCylinders));
          inc(iCount);
        end;
        if (mps.pEngTypeID>0) then begin // ��� ���������
          Stream.WriteStr(tim.GetItemTypeName(mps.pEngTypeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pEngTypeID].Name);
          inc(iCount);
        end;
        if (mps.pFuelID>0) then begin // ��� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pFuelID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pFuelID].Name);
          inc(iCount);
        end;
        if (mps.pCatalID>0) then begin // ��� ������������
          Stream.WriteStr(tim.GetItemTypeName(mps.pCatalID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pCatalID].Name);
          inc(iCount);
        end;
        if (mps.pFuelSupID>0) then begin // ������� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pFuelSupID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pFuelSupID].Name);
          inc(iCount);
        end;
        if (mps.pBrakeID>0) then begin // ��� ��������� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pBrakeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBrakeID].Name);
          inc(iCount);
        end;
        if (mps.pBrakeSysID>0) then begin // ��������� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pBrakeSysID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBrakeSysID].Name);
          inc(iCount);
        end;
        if (mps.pTransID>0) then begin // ��� ������� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pTransID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pTransID].Name);
          inc(iCount);
        end;
        s:= Model.MarksCommaText;
        if (s<>'') then begin
          Stream.WriteStr('���������:');
          Stream.WriteStr(s);
          inc(iCount);
        end;
      end; // constIsAuto, constIsMoto

      constIsCV: begin //--------------------------------------------- ���������
        if (mps.pValves>0) then begin
          Stream.WriteStr('������ [�]:');
          Stream.WriteStr(mps.cvTonnOut);
          inc(iCount);
        end;
        if (mps.pBodyID>0) then begin // �����������
          Stream.WriteStr(tim.GetItemTypeName(mps.pBodyID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBodyID].Name);
          inc(iCount);
        end;
        if (mps.pDriveID>0) then begin // ������������ ���
          Stream.WriteStr(tim.GetItemTypeName(mps.pDriveID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pDriveID].Name);
          inc(iCount);
        end;
        if (mps.cvHPaxLO<>'') then begin // �������� [��]
          Stream.WriteStr(tim.GetTypeName(cvtHP)+':');
          Stream.WriteStr(mps.cvHPaxLOout);
          inc(iCount);
        end;
        if (mps.cvKWaxDI<>'') then begin // �������� [���]
          Stream.WriteStr(tim.GetTypeName(cvtKW)+':');
          Stream.WriteStr(mps.cvKWaxDIOut);
          inc(iCount);
        end;
        if (mps.pCCM>0) then begin
          Stream.WriteStr('���.����� [���.��]:');
          Stream.WriteStr(IntToStr(mps.pCCM));
          inc(iCount);
        end;
        if (mps.cvSUAxBR<>'') then begin   // ��������/�����������
          Stream.WriteStr(tim.GetTypeName(cvtSusp)+':');
          Stream.WriteStr(mps.cvSUAxBRout);
          inc(iCount);
        end;
        if (mps.cvWheels<>'') then begin // �������� ���� [���.����]/[��]
          Stream.WriteStr(tim.GetTypeName(cvtWheel)+':');
          Stream.WriteStr(mps.cvWheelsOut);
          inc(iCount);
        end;
        if (mps.pEngTypeID>0) then begin // ��� ���������
          Stream.WriteStr(tim.GetItemTypeName(mps.pEngTypeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pEngTypeID].Name);
          inc(iCount);
        end;
        s:= Model.MarksCommaText;
        if (s<>'') then begin
          Stream.WriteStr('���������:');
          Stream.WriteStr(s);
          inc(iCount);
        end;
        if (mps.cvIDaxBT<>'') then begin // ID �������������
          Stream.WriteStr(tim.GetTypeName(cvtIDs)+':');
          Stream.WriteStr(mps.cvIDaxBTOut);
          inc(iCount);
        end;
        if (mps.cvSecTypes<>'') then begin // �������������� ���
          Stream.WriteStr(tim.GetTypeName(cvtSecTyp)+':');
          Stream.WriteStr(mps.cvSecTypOut);
          inc(iCount);
        end;
        if (mps.cvCabs<>'') then begin // ������
          Stream.WriteStr(tim.GetTypeName(cvtCabs)+':');
          Stream.WriteStr(mps.cvCabsOut);
          inc(iCount);
        end;
        if (mps.cvAxles<>'') then begin // ���
          Stream.WriteStr('��� [���.���]/[���]:');
          Stream.WriteStr(mps.cvAxlesOut);
          inc(iCount);
        end;
      end; // constIsCV

      constIsAx: begin //--------------------------------------------------- ���
        if (mps.cvHPaxLO<>'') then begin // �������� �� ��� [��]
          Stream.WriteStr(tim.GetTypeName(axtLoad)+':');
          Stream.WriteStr(mps.cvHPaxLOout);
          inc(iCount);
        end;
        if (mps.pDriveID>0) then begin   // ��� ���
          Stream.WriteStr(tim.GetItemTypeName(mps.pDriveID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pDriveID].Name);
          inc(iCount);
        end;
        if (mps.pEngTypeID>0) then begin // ���������� ���
          Stream.WriteStr(tim.GetItemTypeName(mps.pEngTypeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pEngTypeID].Name);
          inc(iCount);
        end;
        if (mps.pBodyID>0) then begin    // ����� �����
          Stream.WriteStr(tim.GetItemTypeName(mps.pBodyID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBodyID].Name);
          inc(iCount);
        end;
        if (mps.pFuelID>0) then begin    // �������� ���������
          Stream.WriteStr(tim.GetItemTypeName(mps.pFuelID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pFuelID].Name);
          inc(iCount);
        end;
        if (mps.cvKWaxDI<>'') then begin // ���������[��]
          Stream.WriteStr(tim.GetTypeName(axtDist)+':');
          Stream.WriteStr(mps.cvKWaxDIout);
          inc(iCount);
        end;
        if (mps.pCCM>0) then begin
          Stream.WriteStr('������ ����� [��]:');
          Stream.WriteStr(IntToStr(mps.pCCM));
          inc(iCount);
        end;
        if (mps.pBrakeID>0) then begin   // ��� ��������� �������
          Stream.WriteStr(tim.GetItemTypeName(mps.pBrakeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBrakeID].Name);
          inc(iCount);
        end;
        if (mps.pTransID>0) then begin   // Hub system
          Stream.WriteStr(tim.GetItemTypeName(mps.pTransID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pTransID].Name);
          inc(iCount);
        end;
        if (mps.cvSUAxBR<>'') then begin   // ������� �������
          Stream.WriteStr(tim.GetTypeName(axtBrSize)+':');
          Stream.WriteStr(mps.cvSUAxBRout);
          inc(iCount);
        end;
        if (mps.cvIDaxBT<>'') then begin    // ��� ������
          Stream.WriteStr(tim.GetTypeName(axtBoType)+':');
          Stream.WriteStr(mps.cvIDaxBTOut);
          inc(iCount);
        end;
      end; // constIsAx
    end; // case

ErrorPos:='25';
    if (iCount>0) then begin
      Stream.Position:= iPos;
      Stream.WriteInt(iCount); // ���-�� ���: �������� - ��������
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, False);
  end;
  Stream.Position:= 0;
end;
//================================== ���������� ��������� ������������ �� ������
procedure prSendWareDescrErrorMes(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendWareDescrErrorMes'; // ��� ���������/�������
var UserId, FirmId, NodeId, ModelId, WareId, MesType, AnalogId, OrNumId, command: integer;
    ErrText, AtrErrText: string;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    MesType:= Stream.ReadInt;
    WareId:= Stream.ReadInt;
    ModelId:= Stream.ReadInt;
    NodeId:= Stream.ReadInt;
    AnalogId:= Stream.ReadInt;
    OrNumId:= Stream.ReadInt;
    ErrText:= Stream.ReadStr;
    AtrErrText:= Stream.ReadStr;

    if (FirmID<1) then command:= csSendWareDescrErrorMes
    else command:= csOrdSendWareDescrErrorMes;
                                                    // �����������
    prSetThLogParams(ThreadData, command, UserId, FirmId, 'MesType='+IntToStr(MesType)+
      #13#10'WareId='+IntToStr(WareId)+#13#10'ModelId='+IntToStr(ModelId)+
      #13#10'NodeId='+IntToStr(NodeId)+#13#10'AnalogId='+IntToStr(AnalogId)+
      #13#10'OrNumId='+IntToStr(OrNumId)+#13#10'ErrText='+ErrText+#13#10'AtrErrText='+AtrErrText);

    ErrText:= fnSendErrorMes(FirmID, UserID, MesType, WareId, AnalogId, OrNumId,
              ModelId, NodeId, ErrText, AtrErrText, ThreadData);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prImportPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prImportPage'; // ��� ���������/�������
var UserId: integer;
    list: TStringList;
    s, email: String;
begin
  List:= nil;
  Stream.Position:= 0;
  s:= '';
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csImportPage, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    // ��������� ������� ����������� �������/�������� � ����������
    if not Cache.GetEmplAllowRepImp(UserID) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    email:= Cache.arEmplInfo[UserID].Mail;
    if (email='') then
      s:= '��� e-mail �� ������ � ����������� ����������� Grossbee.'
    else if not fnCheckEmail(email) then
      s:= '��� e-mail "'+email+'" � ����������� ����������� Grossbee ������������.';
    if (s<>'') then
      raise EBOBError.Create('������ � ���������� ������� ������������ �� e-mail ����������.'+
        cSpecDelim+s+cSpecDelim+'���������� � ����� ��� ��������������� ��� ����� ������������.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    list:= Cache.GetEmplAllowRepOrImpList(UserID); // ������ �������
    Stream.WriteStringList(list, true);
    list.Clear;
    list:= Cache.GetEmplAllowRepOrImpList(UserID, False); // ������ ��������
    Stream.WriteStringList(list, true);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//==============================================================================
procedure prCheckWareManager(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCheckWareManager'; // ��� ���������/�������
var UserId, WareId: integer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    WareId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csCheckWareManager, UserId, 0, 'Ware='+IntToStr(WareId)); // �����������

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create('�� ������ �������� ������������');
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create('�� ������ �������� �����');

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolUiK) and
      (Cache.GetWare(WareID).ManagerID<>UserID) then
      raise EBOBError.Create('� ��� ��� ���� �� �������������� ����� ������');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prModifyLink3(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModifyLink3'; // ��� ���������/�������
var UserId, WareId, ModelId, NodeId, ResCode: integer;
    errmess: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    WareId:= Stream.ReadInt;
    ResCode:= Stream.ReadInt;
    NodeId:= Stream.ReadInt;
    ModelId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csModifyLink3, UserId, 0, 'Ware='+IntToStr(WareId)+#13#10'Act='+
      IntToStr(ResCode)+#13#10'NodeId='+IntToStr(NodeId)+#13#10'Model='+IntToStr(ModelId)); // �����������

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create('�� ������ �������� ������������');

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create('�� ������ �������� �����');

    if ((Cache.FDCA.GetModelTypeSys(ModelID)=constIsMoto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolTNAManageMoto))
      or ((Cache.FDCA.GetModelTypeSys(ModelID)=constIsAuto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolTNAManageAuto))
      or ((Cache.FDCA.GetModelTypeSys(ModelID)=constIsCV) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolTNAManageCV)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if (ResCode<>resDeleted) and (ResCode<>resAdded) then
      raise EBOBError.Create('������������ ��� �������� - '+IntToStr(ResCode));

    errmess:= Cache.FDCA.CheckWareModelNodeLink(WareID, ModelID, NodeID, ResCode, soHand, UserID);
    if (ResCode=resError) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(errmess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//========================================= �������� ������ ������� � 3-� ������
procedure prShowConditionPortions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowConditionPortions'; // ��� ���������/�������
var WareId, ModelID, NodeID, UserId, i, SysID: integer;
    OL: TObjectList;
    List: TStringList;
    Model: TModelAuto;
    flManagAuto, flManagMoto, flManagCV: Boolean;
    nodeName: String;
begin
  Stream.Position:= 0;
  OL:= nil;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowConditionPortions, UserId);

    if not Cache.EmplExist(UserID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    with Cache.arEmplInfo[UserId] do begin
      flManagAuto:= UserRoleExists(rolModelManageAuto);
      flManagMoto:= UserRoleExists(rolModelManageMoto);
//      flManagCV:= UserRoleExists(rolModelManageCV);
      flManagCV:= False;
    end;
    if not (flManagAuto or flManagMoto or flManagCV) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create('�� ������� �������� ������');

    Model:= Cache.FDCA.Models.GetModel(ModelId);
    SysID:= Model.TypeSys;
    if ((SysID=constIsAuto) and not flManagAuto)
      or ((SysID=constIsMoto) and not flManagMoto)
//      or ((SysID=constIsCV) and not flManagCV)
      then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    with Cache.FDCA.AutoTreeNodesSys[SysID] do begin
      if not NodeExists(NodeId) then raise EBOBError.Create('������� ������ ����');
      nodeName:= Items[NodeId].Name;
    end;

    OL:= GetModelNodeWareUsesAndTextsPartsView(ModelID, NodeID, WareID);
    if (OL.Count>1) then OL.Sort(@SortCompareConditionPortions);

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    Stream.WriteStr(Cache.GetWare(WareId).Name);
    Stream.WriteStr(nodeName);
    Stream.WriteStr(Model.WebName);

    Stream.WriteInt(OL.Count);
    for i:= 0 to OL.Count-1 do begin
      List:= TStringList(OL[i]);
      Stream.WriteInt(Ord(List.QuoteChar));
      Stream.WriteInt(Ord(List.Delimiter));
      Stream.WriteStr(List.Text);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(OL);
end;
//==============================================================================
procedure prMarkPortions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMarkPortions'; // ��� ���������/�������
var WareId, ModelID, NodeID, UserId, PortionID: integer;
    ss, Mark: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    PortionID:= Stream.ReadInt;
    Mark:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csMarkPortions, UserId, 0, 'ModelID='+IntToStr(ModelID)+
      #10#13'NodeID='+IntToStr(NodeID)+#10#13'WareID='+IntToStr(WareID)+
      #10#13'PortionID='+IntToStr(PortionID)+#10#13'Mark='+(Mark));

    if not Cache.EmplExist(UserID) then raise EBOBError.Create(MessText(mtkNotEmplExist));

    if not (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageAuto)
      or Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageMoto)
//      or Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageCV)
      ) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create('�� ������� �������� ������');

    if (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageAuto)
      and not Cache.FDCA.AutoTreeNodesSys[constIsAuto].NodeExists(NodeId))
      or (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageMoto)
     and not Cache.FDCA.AutoTreeNodesSys[constIsMoto].NodeExists(NodeId))
//     or (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageCV)
//      and not Cache.FDCA.AutoTreeNodesSys[constIsCV].NodeExists(NodeId))
      then
      raise EBOBError.Create('������� ������ ����');

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    if ((Cache.FDCA.Models[ModelID].TypeSys=constIsAuto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageAuto))
      or ((Cache.FDCA.Models[ModelID].TypeSys=constIsMoto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageMoto)) then begin
      raise EBOBError.Create(MessText(mtkNotRightExists));
    end;

    if (Mark<>'wrong') and (Mark<>'right') and (Mark<>'del') then
      raise EBOBError.Create('������������ ������ ������ - '+Mark);

    if (Mark='del') then
      ss:= Cache.DelModelNodeWareUseListLinks(ModelID, NodeID, WareID, PortionID)
    else
      ss:= SetUsageTextPartWrongMark(ModelID, NodeID, WareID, PortionID, UserID, Mark='wrong');

    if (ss<>'') then raise EBOBError.Create(ss);

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prGetBrandsGB(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBrandsGB'; // ��� ���������/�������
var UserId, i: integer;
    list: TStringList;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetBrandsGB, UserId);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    list:= TStringList.Create;

    for i:= 0 to Cache.WareBrands.ItemsList.Count-1 do
      with TBrandItem(Cache.WareBrands.ItemsList[i]) do
        list.AddObject(Name, Pointer(ID));

    list.Sort;
    Stream.WriteStringList(list, true);
    list.Clear;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//======================= ��������������� ���������� ������ �� ��������� �������
procedure prGetWareList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareList'; // ��� ���������/�������
var UserId, FirmID, i, ListType, ID, AnalogsCount, src: integer;
  list: TStringList;
  conditions, StrPos: string;
  Ware, Analog: TWareInfo;
  pAr1, pAr2, aiWares: Tai;
  OL: TObjectList;
  IBD: TIBDatabase;
  IBSQL: TIBSQL;
//  ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  List:= nil;
  OL:= nil;
//  IBD:=nil;
  IBSQL:= nil;
  StrPos:= '0';
  SetLength(pAr1, 0);
  SetLength(pAr2, 0);
//  ffp:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ListType:= Stream.ReadInt;
    conditions:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetWareList, UserId, FirmID, 'ListType='+
      IntToStr(ListType)+' conditions='+conditions);
    list:= TStringList.Create;
StrPos:='1';

    if not (ListType in [gwlWareByCode, gwlAnalogsGB, gwlAnalogsON,
      gwlAnalogsOneDirectWrong, gwlAnalogsOneDirect]) then
      raise EBOBError.Create('����������� ��� ������ - '+IntToStr(ListType));

    ID:= StrToIntDef(conditions, 0);
    if not Cache.WareExist(ID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, conditions));

    case ListType of // 1
      gwlWareByCode: begin
//          i:= StrToIntDef(conditions, 0);
//          if not Cache.WareExist(i) then
//            raise EBOBError.Create(MessText(mtkNotFoundWare, conditions));
          list.AddObject('', pointer(ID));
        end; // gwlWareByCode

      gwlAnalogsGB, gwlAnalogsON, gwlAnalogsOneDirectWrong, gwlAnalogsOneDirect: begin
StrPos:='2';
        Ware:= Cache.GetWare(ID, true);
        if (Ware.PgrID<1) and not ware.IsPrize then
          raise EBOBError.Create(MessText(mtkNotFoundWare, conditions));

        if not ware.IsPrize then case ListType of // 2
          gwlAnalogsGB: begin
StrPos:='3';
              OL:= Ware.GetSrcAnalogs(ca_GR);
              for i:= 0 to OL.Count-1 do begin
                Analog:= Cache.GetWare(TTwoCodes(OL[i]).ID1);
                list.AddObject(Analog.Name, pointer(Analog.ID));
              end;
            end; // gwlAnalogsGB

          gwlAnalogsON: try
              Cache.FDCA.fnGetListAnalogsWithManufacturer(ID, -1, pAr1, pAr2);
              for i:= 0 to High(pAr2) do begin
                Analog:= Cache.GetWare(pAr2[i]);
                list.AddObject(Analog.Name, pointer(Analog.ID));
              end;
            finally
              SetLength(pAr1, 0);
              SetLength(pAr2, 0);
            end; //  gwlAnalogsON

          gwlAnalogsOneDirectWrong, gwlAnalogsOneDirect: begin
StrPos:='4';
              OL:= TObjectList.Create;
              IBD:= CntsGrb.GetFreeCnt;
              try
                IBSQL:= fnCreateNewIBSQL(IBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
                IBSQL.SQL.Text:= 'SELECT PmWAWareCode, PmWASourceCode FROM PMWareAnalogs'+
                  ' WHERE PmWAWareAnalogCode='+IntToStr(Id)+' AND PmWAIsWrong="'+
                  fnIfStr(ListType=gwlAnalogsOneDirect, 'F', 'T')+'"';
                IBSQL.ExecQuery;
                while not IBSQL.EOF do begin
                  ID:= IBSQL.FieldByName('PmWAWareCode').AsInteger;
                  if Cache.WareExist(ID) then begin
                    Analog:= Cache.GetWare(ID);
                    src:= IBSQL.FieldByName('PmWASourceCode').AsInteger;
                    list.AddObject(Analog.Name, pointer(Analog.ID));
                    OL.Add(TTwoCodes.Create(ID, Cache.FDCA.GetSourceByGBcode(src)));
                  end;
                  TestCssStopException;
                  IBSQL.Next;
                end;
              finally
                prFreeIBSQL(IBSQL);
                cntsGRB.SetFreeCnt(IBD);
              end;
            end; // gwlAnalogsOneDirectWrong, gwlAnalogsOneDirect
        end; // case 2
      end; // gwlAnalogsGB, gwlAnalogsON, gwlAnalogsOneDirectWrong, gwlAnalogsOneDirect
//      else raise EBOBError.Create('����������� ��� ������ - '+IntToStr(ListType));
    end; // case 1
    List.Sort;

//    ffp:= TForFirmParams.Create(FirmID, UserID);

StrPos:='5';
    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    Stream.WriteInt(List.Count);
    SetLength(aiWares, List.Count);
StrPos:='6, List.Count='+intToStr(List.Count);
    for i:= 0 to List.Count-1 do begin
StrPos:='7, i='+intToStr(i);
      aiWares[i]:= integer(List.Objects[i]);
      Ware:= Cache.GetWare(aiWares[i], true);
      AnalogsCount:= 0;
      if not ware.IsPrize then begin
        if (ListType in [gwlAnalogsOneDirect, gwlAnalogsOneDirectWrong]) then
          AnalogsCount:= fnGetID2byID1Def(OL, integer(List.Objects[i]), -1);
        if (ListType in [gwlWareByCode]) then begin
          pAr1:= Cache.arWareInfo[aiWares[i]].Analogs;
          AnalogsCount:= Length(pAr1);
        end;
      end;
      prSaveShortWareInfoToStream(Stream, aiWares[i], FirmId, UserId, AnalogsCount);
      // � Webarm �� ���������� ���-�� ������ ����� !!!
//      prSaveShortWareInfoToStream(Stream, ffp, aiWares[i], AnalogsCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
  Stream.Position:= 0;
  prFree(list);
  prFree(OL);
  SetLength(aiWares, 0);
  SetLength(pAr1, 0);
  SetLength(pAr2, 0);
//  prFree(ffp);
end;
//============================== ��������� ��������� ������������ ����� � ������
procedure prProductAddOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductAddOrigNum'; // ��� ���������/�������
var UserId, WareID, ResCode, OrigId, SrcID, MfAuID: integer;
    OrigNum, MsgStr: string;
begin
  Stream.Position:= 0;
  OrigId:= 0;
  try
    UserID      := Stream.ReadInt;
    WareID      := Stream.ReadInt;   // ��� ������
    SrcID:= soHand;           // ��� ��������� ������
    MfAuID      := Stream.ReadInt;   // ��� ������������� ����
    OrigNum     := Stream.ReadStr;   // ������������ �����

    OrigNum:= fnDelSpcAndSumb(OrigNum, StrSpecSumbs);

    prSetThLogParams(ThreadData, csProductAddOrigNum, UserId, 0, 'WareID='+IntToStr(WareID)+
      'SrcID='+IntToStr(SrcID)+' MfAuID='+IntToStr(MfAuID)+' OrigNum='+OrigNum);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotClientExist));

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolProduct) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    ResCode:= resAdded;
    MsgStr:= Cache.FDCA.CheckOrigNumLink(ResCode, WareID, MfAuID, OrigId, OrigNum, SrcID, UserID);

    Case ResCode of
      resError: raise EBOBError.Create(MsgStr);
      resDoNothing:
        raise EBOBError.Create('�������� ������� ������������� ������ ��� ����������.');
    end;// Case ResCode of

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
//    Stream.WriteInt(OrigId);
//    Stream.WriteStr(OrigNum);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================== �������� �������� ������������� ������ � ������
procedure prProductDelOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductDelOrigNum'; // ��� ���������/�������
var UserId, WareID, ResCode, OrigId, SrcID, MfAuID: integer;
    OrigNum, MsgStr: string;
begin
  Stream.Position:= 0;
  OrigId:= 0;
  SrcID:= soHand;
  MfAuID:= 0;
  try
    UserID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;   // ��� ������
    OrigId:= Stream.ReadInt;   // ��� ������������� ������

    prSetThLogParams(ThreadData, csProductDelOrigNum, UserId, 0,
      'WareID='+IntToStr(WareID)+' OrigId='+IntToStr(OrigId));

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolProduct) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    ResCode:= resDeleted;
    MsgStr:= Cache.FDCA.CheckOrigNumLink(ResCode, WareID, MfAuID, OrigId, OrigNum, SrcID, UserID);

    Case ResCode of
      resError: begin
        raise EBOBError.Create('�� ������� ������� ������������ ����� - '+MsgStr);
      end;
      resDoNothing: begin
        raise EBOBError.Create('�������� ������� ������������� ������ �� ����������.');
      end;
    end;// Case ResCode of

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//----- ����� ��������� TecDoc, ��������������� ������ Grossbee �� �����(������)   ???
function SearchWareGBInTecDoc(pWareID: Integer; ThreadData: TThreadData): TStringList;
const nmProc='SearchWareGBInTecDocExtended';
var s, s1: String;
    lstWares, lstAddon: TStringList;
    i, j, Count: Integer;
    Ware: TWareInfo;
    IBS: TIBSQL;
    IBD: TIBDatabase;
  //-- ��������� ������������ ������ � ��������� ��������� ������ � ��������� � P
  function GetCutNameForSearchTD(pName: String): String;
  begin
    Result:= fnGetStrPart(' ', fnGetStrPart('   ', Trim(pName)), 1);
  end;
  //------------------------------
begin
  Result  := nil;
  lstAddon:= nil;
  lstWares:= nil;
  IBD     := nil;
  IBS     := nil;
  if not Cache.WareExist(pWareID) then
    raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(pWareID)));
  Ware:= Cache.GetWare(pWareID);
  try
    lstWares:= fnCreateStringList(True, dupIgnore);
    with Ware do begin
      lstWares.Append(GetCutNameForSearchTD(Name));
      lstWares.Append(AnsiUpperCase(fnDelSpcAndSumb(WareSupName)));
    end;
    if not Assigned(lstWares) then exit;

    Result:= fnCreateStringList(True, dupIgnore);

    case Ware.WareBrandID of

      brandCONTITECH: begin   // CONTITECH
        lstAddon:= GetLstPrefixAddon(Ware.WareBrandID);  // Prefix
        Count:=lstWares.Count-1;
        for i:= 0 to lstAddon.Count-1 do
          for j:= 0 to Count do
            lstWares.Add(lstAddon[i]+lstWares[j]);
        prFree(lstAddon);

        lstAddon:= GetLstSufixAddon(Ware.WareBrandID);  // Sufix
        Count:=lstWares.Count-1;
        for i:= 0 to lstAddon.Count-1 do
          for j:= 0 to Count do
            lstWares.Add(lstWares[j]+lstAddon[i]);
      end;
    end; // case

    Result:= fnCreateStringList(True, dupIgnore);
    IBS:= nil;
    IBD:= cntsTDT.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, true);
    s:=fnGetDelimiterText(lstWares);
    s1:=fnArrOfIntToString(TBrandItem(Cache.WareBrands[Ware.WareBrandID]).TDMFcodes);
    IBS.SQL.Text:= 'SELECT DS_MF_ID, ART_NR FROM ARTICLES, DATA_SUPPLIERS '#10+
      'WHERE (ART_NR in ('+s+')) and (ART_SUP_ID=DS_ID) and DS_MF_ID IN ('+s1+')'#10+
      'ORDER BY DS_BRA, ART_NR';
    IBS.Prepare;
    IBS.ExecQuery;
    while not IBS.EOF do begin
      Result.AddObject(IBS.FieldByName('DS_MF_ID').AsString+'|'+IBS.FieldByName('ART_NR').asString, pointer(0));
//      if cntsTDT.Suspend then raise Exception.Create(MessText(mtkExitBySuspend));
      TestCssStopException;
      IBS.Next;
    end;
    IBS.close;

  except
    on E: Exception do begin
      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
    end;
  end;
  prFree(lstAddon);
  prFree(lstWares);
  prFreeIBSQL(IBS);
  cntsTDT.SetFreeCnt(IBD);
end;
//============= �������� ������ ������� Grossbee, TecDoc � ������ ������ �������
procedure prGetLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetLinkBrandsGBTD';
var UserID: Integer;
    Position: Integer;
    VarTo, i, ii, j: integer;
    list: TStringList;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetLinkBrandsGBTD, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserID].UserRoleExists(rolManageBrands) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Position:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-��

    list:= TStringList.Create;

    varTo:= Cache.WareBrands.ItemsList.Count-1;
    j:= 0;
    for i:= 0 to varTo do with TBrandItem(Cache.WareBrands.ItemsList[i]) do
      list.AddObject(Name, Cache.WareBrands.ItemsList[i]);

    varTo:= List.Count-1;
    list.Sort;
    for i:= 0 to varTo do with TBrandItem(List.Objects[i]) do begin
      if (Length(TDMFcodes)>0) then
        for ii:= 0  to High(TDMFcodes) do begin
          Stream.WriteInt(ID);
          Stream.WriteInt(TDMFcodes[ii]);
          Inc(j);
        end;
//      list.AddObject(Name, Pointer(ID)); // ???
    end;
    Stream.Position:= Position;
    Stream.WriteInt(j);
  except
    on E: Exception do
      fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', E.Message, '');
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//==============================================================================
procedure prAddLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddLinkBrandsGBTD';
var UserID, idBrandGB, idBrandTD, ResCode: Integer;
    ErrText: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    idBrandGB:= Stream.ReadInt;
    idBrandTD:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csAddLinkBrandsGBTD, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserID].UserRoleExists(rolManageBrands) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (not Cache.WareBrands.ItemExists(idBrandGB)) then
      raise EBOBError.Create('�� ������ ����� � ����� '+IntToStr(idBrandGB));

    ResCode:= resAdded;
    ErrText:= Cache.CheckWareBrandReplace(idBrandGB, idBrandTD, UserID, ResCode);
    case ResCode of
      resDoNothing: raise EBOBError.Create('��� ������ ��� �������');
      resError    : raise EBOBError.Create(ErrText)
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prDelLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prDelLinkBrandsGBTD';
var UserID, idBrandGB, idBrandTD, ResCode: Integer;
    ErrText: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    idBrandGB:= Stream.ReadInt;
    idBrandTD:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csDelLinkBrandsGBTD, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserID].UserRoleExists(rolManageBrands) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (not Cache.WareBrands.ItemExists(idBrandGB)) then
      raise EBOBError.Create('�� ������ ����� � ����� '+IntToStr(idBrandGB));

    ResCode:= resDeleted;
    ErrText:= Cache.CheckWareBrandReplace(idBrandGB, idBrandTD, UserID, ResCode);
    case ResCode of
      resDoNothing: raise EBOBError.Create('����� ������ ������� �� �������');
      resError    : raise EBOBError.Create(ErrText)
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=========== ��������� ������ ������������ ������� ��� ������ � ����� ���������
procedure prProductGetOrigNumsAndWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductGetOrigNumsAndWares'; // ��� ���������/�������
var EmplID, WareID, j: integer;
    pos: int64;
    STai, SLTai: Tai;
    WhatReturn: byte;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    OrNum: TOriginalNumInfo;
    s: string;
    empl: TEmplInfoItem;
    flUik: Boolean;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try
    EmplID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    WhatReturn:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csProductGetOrigNumsAndWares, EmplID);

    if not Cache.EmplExist(EmplID) then raise EBOBError.Create(MessText(mtkNotEmplExist));

    empl:= Cache.arEmplInfo[EmplID];
    flUik:= empl.UserRoleExists(rolUiK);
    if not empl.UserRoleExists(rolProduct) and not flUik then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);
    j:= 0;
    if WhatReturn=0 then s:= 'F' else s:= 'T';

    IBD:= cntsORD.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, -1, tpRead, true);
    IBS.SQL.Text:= 'select ORLKONUMCODE, ORLKSOURCECODE'+
                      ' from ORIGINALLINKWARE where ORLKCODEWARE='+IntToStr(WareID)+
                      ' AND ORLKWRONG="'+s+'" order by ORLKSOURCECODE';
    IBS.Prepare;
    IBS.ExecQuery;
    while not IBS.EOF do begin
      OrNum:= Cache.FDCA.GetOriginalNum(IBS.FieldByName('ORLKONUMCODE').AsInteger);
      if (OrNum<>nil) then begin
        Stream.WriteInt(OrNum.ID);           // ��� ������������� ������
        Stream.WriteInt(OrNum.MfAutoID);     // ��� ������������� ����
        Stream.WriteByte(IBS.FieldByName('ORLKSOURCECODE').AsInteger); // ��� ��������� �����
        Stream.WriteStr(OrNum.OriginalNum);  // ������������ �����
        Stream.WriteStr(OrNum.ManufName);    //
        Inc(j);
      end;
      TestCssStopException;
      IBS.Next;
    end;
    IBS.close;
    if (j>0) then begin
      Stream.Position:= pos;
      Stream.WriteInt(j);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
  SetLength(STai, 0);
  SetLength(SLTai, 0);
end;
//=========================== ���������� �������� �� ��������� ����� ������ � ��
procedure prMarkOrNum(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMarkOrNum'; // ��� ���������/�������
var UserId, WareID, ResCode, OrigId: integer;
    OrigNum, MsgStr: string;
    SrcID: integer;
begin
  Stream.Position:= 0;
  SrcID:= soHand;
  try
    UserID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;  // ��� ������
    OrigId:= Stream.ReadInt;  // ��� ��
    ResCode:= Stream.ReadByte; // ��� ��������

    prSetThLogParams(ThreadData, csMarkOrNum, UserId, 0, 'WareID='+IntToStr(WareID)+
                     'OrigId='+IntToStr(OrigId)+' Operation='+IntToStr(ResCode));

    if not (ResCode in [resWrong, resNotWrong]) then
      raise EBOBError.Create('��������� ��� �������� '+IntToStr(resCode)+' !');
    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserID].UserRoleExists(rolProduct) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    if (ResCode=resWrong) then begin
//      MfAuID:=Cache.FDCA.arOriginalNumInfo[OrigId].MfAutoID;
      OrigNum:= Cache.FDCA.arOriginalNumInfo[OrigId].OriginalNum;
    end;

    MsgStr:= Cache.FDCA.CheckOrigNumLink(ResCode, WareID, 0, OrigId, OrigNum, SrcID, UserID);
    Case ResCode of
      resError, resDoNothing: raise EBOBError.Create(MsgStr);
    end;// Case ResCode of

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=========================== �������� ������������ ������, ����� ��� 2� �������
procedure prShowCrossOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowCrossOE'; // ��� ���������/�������
var UserId, FirmID, Ware1, Ware2, i, Position, Count, arlen: integer;
    errmess: string;
    STai1, SLTai1, STai2, SLTai2: Tai;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    Ware1:= Stream.ReadInt;  // ��� ������
    Ware2:= Stream.ReadInt;  // ��� ������

    prSetThLogParams(ThreadData, csShowCrossOE, UserId, FirmID, ' Ware1='+IntToStr(Ware1)+' Ware2='+IntToStr(Ware2));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if not Cache.WareExist(Ware1) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(Ware1)));
    if not Cache.WareExist(Ware2) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(Ware2)));

    Cache.arWareInfo[Ware1].SortOrigNumsWithSrc(STai1, SLTai1);
    Cache.arWareInfo[Ware2].SortOrigNumsWithSrc(STai2, SLTai2);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.arWareInfo[Ware1].Name);
    Stream.WriteStr(Cache.arWareInfo[Ware2].Name);

    arlen:= Length(STai2);
    Count:= 0;
    Position:= Stream.Position;
    Stream.WriteInt(0);
    for i:= 0 to arlen-1 do begin
      if not Cache.FDCA.OrigNumExist(STai2[i]) then Continue;
      if (fnInIntArray(STai2[i], STai1)=-1) then Continue;
      inc(Count);
      with Cache.FDCA.arOriginalNumInfo[STai2[i]] do begin
        Stream.WriteInt(STai2[i]);      // ��� ������������� ������
        Stream.WriteInt(MfAutoID);     // ��� ������������� ����
        Stream.WriteByte(SLTai2[i]);    // ��� ��������� �����
        Stream.WriteStr(OriginalNum);  // ������������ �����
        Stream.WriteStr(ManufName);  //
      end;
    end;
    Stream.Position:= Position;
    Stream.WriteInt(Count);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(STai1, 0);
  SetLength(SLTai1, 0);
  SetLength(STai2, 0);
  SetLength(SLTai2, 0);
end;
//==============================================================================
procedure prShowEngineOptions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowEngineOptions'; // ��� ���������/�������
var UserId, FirmID, ModelID, i, EngineID: integer;
    errmess, Engine: string;
    EngineData, List: TStringList;
    EngCodes: Tai;
    arlen: integer;
    eng: TEngine;
begin
  List:= nil;
  EngineData:= nil;
  Stream.Position:= 0;
  try
    FirmID  := Stream.ReadInt;
    UserID  := Stream.ReadInt;
    ModelID := Stream.ReadInt;
    Engine  := Stream.ReadStr;
    EngineID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowEngineOptions, UserId, FirmID,
      ' ModelID='+IntToStr(ModelID)+' Engine='+Engine); // �������� �����������!

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if (EngineID<1) then begin
      if not Cache.FDCA.Models.ModelExists(ModelID) then
        raise EBOBError.Create('�� ������� �������� ������');
      EngCodes:= Cache.FDCA.Models[ModelID].EngLinks.GetLinkCodes;

    end else begin
      if not Cache.FDCA.Engines.ItemExists(EngineID) then
        raise EBOBError.Create('�� ������ �������� ���������');
      SetLength(EngCodes, 1);
      EngCodes[0]:= EngineID;
      Engine:= Cache.FDCA.Engines.GetEngine(EngineID).Mark;
    end;

    EngineData:= TStringList.Create;

    for i:= 0 to High(EngCodes) do begin
      eng:= Cache.FDCA.Engines.GetEngine(EngCodes[i]);
      if (eng.Mark<>Engine) then Continue;
      if (EngineData.Count>0) then
        EngineData.Add('==========</td><td> ==========');
      List:= eng.GetViewList(' &nbsp</td><td>&nbsp ');
      EngineData.Assign(List);
      prFree(List);
    end;

    arlen:= EngineData.Count-1;
    if (arlen<0) then raise EBoBError.Create('��� ������ �� ����� ���������.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(arlen);
    for i:= 0 to arlen do Stream.WriteStr(EngineData[i]);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(EngCodes, 0);
  prFree(EngineData);
  prFree(List);
end;
//======================== "��������" ����� Top10 ��������� ���������� ������� �
//====================================== ���������� ������ ��� ����������� �����
procedure prGetTop10Model(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetTop10Model'; // ��� ���������/�������
var UserId, FirmID, ModelID, i, Sys, ModelLineID, MFAID, CurModel, arlen: integer;
    s, Codes: string;
    ModelCodesNew: Tai;
    ModelCodesOLD : Tas;
    Model: TModelAuto;
    ModelLine: TModelLine;
    MayAdd: boolean;
    Engine: TEngine;
    flNotEng: Boolean;
    mps: TModelParams;
begin
  Stream.Position:= 0;
  try
    FirmID := Stream.ReadInt;
    UserID := Stream.ReadInt;
    Sys    := Stream.ReadInt;
    ModelID:= Stream.ReadInt;
    Codes  := Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetTop10Model, UserId, FirmID,
      ' ModelID='+IntToStr(ModelID)+' Codes='+Codes); // �������� ����������� !

//if flDebugCV then Sys:= constIsCV;

    flNotEng:= CheckTypeSys(Sys);
    if not flNotEng and (Sys<>(constIsAuto+30)) then
      raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(Sys)));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if (ModelID<1) then SetLength(ModelCodesNew, 0)
    else begin
      if flNotEng then begin
        if not Cache.FDCA.Models.ModelExists(ModelID) then
          raise EBOBError.Create('�� ������� �������� ������');
        Model:= Cache.FDCA.Models[ModelID];
        if (Model.TypeSys<>Sys) then
          raise EBOBError.Create('������ �� ������������� ������� �����');
        if not Model.IsVisible then
          raise EBOBError.Create('������ �������� ��������� ������');
      end else if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create('�� ������ �������� ���������');

      SetLength(ModelCodesNew, 1);
      ModelCodesNew[0]:= ModelID;
    end;

    ModelCodesOld:= fnSplitString(Codes, ',');
    for i:= 0 to High(ModelCodesOld) do begin
      CurModel:= StrToIntDef(ModelCodesOld[i], 0);
      MayAdd:= (CurModel>0) and (CurModel<>ModelID);

      if flNotEng then begin
        MayAdd:= MayAdd and Cache.FDCA.Models.ModelExists(CurModel);
        if MayAdd then begin
          Model:= Cache.FDCA.Models[CurModel];
          MayAdd:= (Model.TypeSys=Sys) and Model.IsVisible;
        end;
      end else
        MayAdd:= MayAdd and Cache.FDCA.Engines.ItemExists(CurModel);

      if MayAdd then begin
        SetLength(ModelCodesNew, Length(ModelCodesNew)+1);
        ModelCodesNew[Length(ModelCodesNew)-1]:= CurModel;
      end;
    end;

    if (Length(ModelCodesNew)>10) then SetLength(ModelCodesNew, 10);

    arlen:= Length(ModelCodesNew)-1;
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(arlen);
    for i:= 0 to High(ModelCodesNew) do begin
      if flNotEng then begin
        Model:= Cache.FDCA.Models[ModelCodesNew[i]];
        ModelLineID:= Model.ModelLineID;
        ModelLine:= Cache.FDCA.ModelLines.GetModelLine(ModelLineID);
        MFAID:= ModelLine.MFAID;
        mps:= Model.Params;
//-------------------------------------------------------------- ����� ���������
        Stream.WriteInt(Model.ID);
        Stream.WriteInt(fnIfInt(sys=constIsMoto, Model.SubCode, 0));
        Stream.WriteInt(ModelLineID);
        Stream.WriteInt(MFAID);
        Stream.WriteStr(Cache.FDCA.Manufacturers[MFAID].Name);
        Stream.WriteStr(ModelLine.Name);
        Stream.WriteStr(Model.Name);
        Stream.WriteInt(mps.pYStart); // ��� ������ �������
        Stream.WriteInt(mps.pMStart); // ����� ������ �������
        Stream.WriteInt(mps.pYEnd);   // ��� ��������� �������
        Stream.WriteInt(mps.pMEnd);   // ����� ��������� �������

//---------------------------------------------- ������������� ��������� �������
        case sys of
          constIsMoto, constIsAuto: begin //--------------------- auto, moto
            Stream.WriteInt(mps.pHP);               // ��
            Stream.WriteStr(Model.MarksCommaText);  // ���������� ����������
          end;
          constIsCV: begin                //----------------------- ���������
            Stream.WriteStr(mps.cvHPaxLOout);       // �� ��-��
            s:= mps.cvTonnOut;
            if (s<>'') then s:= s+' �';
            Stream.WriteStr(s);                     // ������
            Stream.WriteStr(Model.MarksCommaText);  // ���������� ����������
          end;
          constIsAx: begin                //----------------------- ���
            s:= mps.cvHPaxLOout;
            if (s<>'') then s:= s+' ��';
            Stream.WriteStr(s);                     // �������� �� ��� [��] ��-��
            if (mps.pDriveID<1) then s:= ''
            else s:= Cache.FDCA.TypesInfoModel.InfoItems[mps.pDriveID].Name;
            Stream.WriteStr(s);                     // ��� ���
          end;
        end; // case
      end else begin
        Engine:= Cache.FDCA.Engines[ModelCodesNew[i]];
        Stream.WriteInt(Engine.ID); // Code
        Stream.WriteStr(Engine.MfauName);
        Stream.WriteStr(Engine.Name);
        Stream.WriteStr(Engine.EngCCstr);
        Stream.WriteStr(Engine.EngKWstr);
        Stream.WriteStr(Engine.EngHPstr);
        Stream.WriteStr(Engine.EngCYLstr);
      end;
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(ModelCodesOLD, 0);
  SetLength(ModelCodesNew, 0);
end;
//================================== �������� ������ ���������� �� �������������
procedure prLoadEngines(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLoadEngines'; // ��� ���������/�������
var UserId, FirmID, MFAUID, i, iCount, pos: integer;
    errmess: string;
    Engine: TEngine;
    EngineList: TStringList;
begin
  EngineList:= nil;
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    MFAUID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csLoadEngines, UserId, FirmID, ' MFAUID='+IntToStr(MFAUID)); // �������� �����������!

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if not Cache.FDCA.Manufacturers.ManufExists(MFAUID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, IntToStr(MFAUID)));

    EngineList:= Cache.FDCA.Engines.GetMfauEngList(MFAUID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);
    iCount:= 0;
    for i:= 0 to EngineList.Count-1 do begin
      Engine:= TEngine(EngineList.Objects[i]);
      if not Engine.EngHasWares then Continue;
      Stream.WriteInt(Engine.ID);        //
      Stream.WriteStr(Engine.Name);      //
      Stream.WriteStr(Engine.EngCCstr);  // ������ - �������� ���.����� � ���.��.
      Stream.WriteStr(Engine.EngKWstr);  // ������ - �������� �������� ���
      Stream.WriteStr(Engine.EngHPstr);  // ������ - �������� �������� ��
      Stream.WriteStr(Engine.EngCYLstr); // ������ - �������� ���������� ���������
      Inc(iCount);
    end;
    Stream.Position:= pos;
    Stream.WriteInt(iCount);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(EngineList);
end;
//==============================================================================
procedure prNewsPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prNewsPage'; // ��� ���������/�������
var UserId, Count, pos: integer;
    ordIBD: TIBDatabase;
    GBIBSQL: TIBSQL;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  GBIBSQL:= nil;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csNewsPage, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[UserId].UserRoleExists(rolNewsManage) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);

    ordIBD:= CntsOrd.GetFreeCnt;
    GBIBSQL:= fnCreateNewIBSQL(ordIBD, 'GBIBSQL_'+nmProc, ThreadData.ID, tpRead, true);
    GBIBSQL.SQL.Text:= 'Select * from infoboxviews i'+
                       ' order by i.ibvdateto desc, i.ibvdatefrom desc, i.ibvtitle';
    GBIBSQL.ExecQuery;
    Count:= 0;
    while not GBIBSQL.EOF do begin
      Stream.WriteInt(GBIBSQL.FieldByName('IBVCODE').AsInteger);
      Stream.WriteBool(GBIBSQL.FieldByName('IBVVISIBLE').AsString='T');
      Stream.WriteBool(GBIBSQL.FieldByName('IBVVISAUTO').AsString='T');
      Stream.WriteBool(GBIBSQL.FieldByName('IBVVISMOTO').AsString='T');
      Stream.WriteStr(FormatDateTime(cDateFormatY4, GBIBSQL.FieldByName('IBVDATEFROM').AsDate));
      Stream.WriteStr(FormatDateTime(cDateFormatY4, GBIBSQL.FieldByName('IBVDATETO').AsDate));
      Stream.WriteStr(GBIBSQL.FieldByName('IBVTITLE').AsString);
      Stream.WriteStr(GBIBSQL.FieldByName('IBVLINKTOPICT').AsString);
      Stream.WriteStr(GBIBSQL.FieldByName('IBVLINKTOSITE').AsString);
      UserID:= GBIBSQL.FieldByName('IBVUSERID').AsInteger;
      if Cache.EmplExist(UserID) then
        Stream.WriteStr(Cache.arEmplInfo[UserID].EmplShortName)
      else Stream.WriteStr('�����������');
      Stream.WriteStr(FormatDateTime(cDateTimeFormatY4N, GBIBSQL.FieldByName('IBVTIMEADD').AsDateTime));
      Stream.Writeint(GBIBSQL.FieldByName('IBVCLICKCOUNT').AsInteger);
      TestCssStopException;
      GBIBSQL.Next;
      Inc(Count);
    end;
    Stream.Position:= pos;
    Stream.WriteInt(Count);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(GBIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;

procedure prTestLinksLoading(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTestLinksLoading'; // ��� ���������/�������
begin
  try
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteBool(Cache.WareCacheUnLocked);
  except
    on E: EBOBError do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr(E.Message);
//      fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', E.Message, '');
    end;
    on E: Exception do begin
      Stream.Clear;
      Stream.WriteInt(aeCommonError);
      Stream.WriteStr('������ ���������� .');
//      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
    end;
  end;
  Stream.Position:= 0;
end;


procedure prGetFilterValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFilterValues'; // ��� ���������/�������
var
  UserId, NodeId, ModelId, FirmId: integer;
  i: integer;
  IsEngine: boolean;
  aiWares: Tai;
  errmess, StrPos: string;
  List: TStringList;
begin
  Stream.Position:= 0;
  List:=nil;
  try
    FirmId:=Stream.ReadInt;
    UserID:= Stream.ReadInt;
    NodeId:= Stream.ReadInt;
    ModelId:= Stream.ReadInt;
    IsEngine:= Stream.ReadBool;
StrPos:='0';
    prSetThLogParams(ThreadData, csGetFilterValues, UserId, FirmId,
     'Node='+IntToStr(NodeId)+#13#10'Model='+IntToStr(ModelId)+
     #13#10'isEngine='+fnIfStr(IsEngine, '1', '0')); // �����������
StrPos:='1';

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
StrPos:='1-1';

StrPos:='2';

    if not IsEngine and not Cache.FDCA.Models.ModelExists(ModelId) then begin
      raise EBOBError.Create('������� ������� ������');
    end;

    if IsEngine and not Cache.FDCA.Engines.ItemExists(ModelId) then begin
      raise EBOBError.Create('������� ������ ���������');
    end;
StrPos:='3';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    List:= Cache.FDCA.GetModelOrEngNodeFiltersList(NodeID, ModelID, IsEngine);
    Stream.WriteStr('����� ���������');
    Stream.WriteInt(List.Count); // ���-�� �������� � ���������
    for i:= 0 to List.Count-1 do begin
      Stream.WriteInt(integer(List.Objects[i])); //
      Stream.WriteStr(List[i]);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
StrPos:='30';
  Stream.Position:= 0;
  SetLength(aiWares, 0);
  prFree(List);
end;

procedure prShowActionNews(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowActionNews'; // ��� ���������/�������
var
  UserId, FirmId, NewsId: integer;
  errmess, StrPos: string;
  ordIBD: TIBDatabase;
  OrdIBSQL: TIBSQL;
begin
  Stream.Position:= 0;
  ordIBD:=nil;
  OrdIBSQL:= nil;
  try
    FirmId:=isWe;
    UserId:= Stream.ReadInt;
    NewsId:= Stream.ReadInt;
StrPos:='0';
    prSetThLogParams(ThreadData, csShowActionNews, UserId, 0, 'Newsid='+IntToStr(NewsId)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolNewsManage) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
StrPos:='2';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    ordIBD:=CntsOrd.GetFreeCnt;
    OrdIBSQL:=fnCreateNewIBSQL(ordIBD,'GBIBSQL_'+nmProc,ThreadData.ID, tpRead, true);
    OrdIBSQL.SQL.Text:='Select * from infoboxviews where ibvcode='+IntToStr(NewsId);
    OrdIBSQL.ExecQuery;
    if OrdIBSQL.EOF then begin
      raise EBOBError.Create('��������� ������� �� �������');
    end;

    Stream.WriteInt(OrdIBSQL.FieldByName('IBVCODE').Asinteger);
    Stream.WriteBool(OrdIBSQL.FieldByName('IBVVISAUTO').AsString='T');
    Stream.WriteBool(OrdIBSQL.FieldByName('IBVVISMOTO').AsString='T');
    Stream.WriteBool(OrdIBSQL.FieldByName('IBVVISIBLE').AsString='T');
    Stream.WriteDouble(OrdIBSQL.FieldByName('IBVDATEFROM').AsDate);
    Stream.WriteDouble(OrdIBSQL.FieldByName('IBVDATETO').AsDate);
    Stream.WriteInt(OrdIBSQL.FieldByName('IBVPRIORITY').Asinteger);
    Stream.WriteStr(OrdIBSQL.FieldByName('IBVTITLE').AsString);
    Stream.WriteStr(OrdIBSQL.FieldByName('IBVLINKTOSITE').AsString);
    Stream.WriteStr(OrdIBSQL.FieldByName('IBVLINKTOPICT').AsString);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
StrPos:='30';
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================
procedure prAEActionNews(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAEActionNews'; // ��� ���������/�������
var UserId, FirmId, NewsId, Priority: integer;
    errmess, StrPos, Link, title: string;
    ordIBD: TIBDatabase;
    OrdIBSQL: TIBSQL;
    Auto, Moto, InFrame: boolean;
    DateTo, DateFrom: TDateTime;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBSQL:= nil;
  try
    FirmId:= isWe;
    UserId:= Stream.ReadInt;
StrPos:='0';
    NewsId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csAEActionNews, UserId, 0, 'Newsid='+IntToStr(NewsId)); // �����������

    Auto:= Stream.ReadBool;
    Moto:= Stream.ReadBool;
    InFrame:= Stream.ReadBool;
    Link:= Stream.ReadStr;
    title:= trim(Stream.ReadStr);
    DateTo:= Stream.ReadDouble;
    DateFrom:= Stream.ReadDouble;
    Priority:= Stream.ReadInt;

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolNewsManage) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if (title='') then raise EBOBError.Create('�������� �� ����� ���� ������');

    if (DateFrom>DateTo) then
      raise EBOBError.Create('���� ��������� ������� ����������� �� ����� ���� ������ ���� ������.');

    if (Priority<0) then Priority:= 0;

StrPos:='2';
    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD, 'OrdIBSQL_'+nmProc, ThreadData.ID, tpWrite, true);
    if (NewsId<0) then begin
      OrdIBSQL.SQL.Text:='Insert into infoboxviews'+
        ' (IBVVISAUTO, IBVVISMOTO, IBVVISIBLE, IBVDATEFROM, IBVDATETO, IBVPRIORITY,'+
        ' IBVTITLE, IBVLINKTOSITE, IBVLINKTOPICT, IBVUSERID) values '+
        ' (:IBVVISAUTO, :IBVVISMOTO, :IBVVISIBLE, :IBVDATEFROM, :IBVDATETO, :IBVPRIORITY,'+
        ' :IBVTITLE, :IBVLINKTOSITE, :IBVLINKTOPICT, :IBVUSERID) returning ibvcode';
      OrdIBSQL.ParamByName('IBVLINKTOPICT').AsString:= 'addimage.jpg';
    end else
      OrdIBSQL.SQL.Text:='Update infoboxviews set IBVVISAUTO=:IBVVISAUTO,'+
        ' IBVVISMOTO=:IBVVISMOTO, IBVVISIBLE=:IBVVISIBLE, IBVDATEFROM=:IBVDATEFROM,'+
        ' IBVDATETO=:IBVDATETO, IBVPRIORITY=:IBVPRIORITY, IBVTITLE=:IBVTITLE,'+
        ' IBVLINKTOSITE=:IBVLINKTOSITE, IBVUSERID=:IBVUSERID where ibvcode='+IntToStr(NewsId);
    OrdIBSQL.ParamByName('IBVVISAUTO').AsString:= fnIfStr(Auto, 'T', 'F');
    OrdIBSQL.ParamByName('IBVVISMOTO').AsString:= fnIfStr(Moto, 'T', 'F');
    OrdIBSQL.ParamByName('IBVVISIBLE').AsString:= fnIfStr(InFrame, 'T', 'F');
    OrdIBSQL.ParamByName('IBVDATEFROM').AsDateTime:= DateFrom;
    OrdIBSQL.ParamByName('IBVDATETO').AsDateTime:= DateTo;
    OrdIBSQL.ParamByName('IBVPRIORITY').AsInteger:= Priority;
    OrdIBSQL.ParamByName('IBVTITLE').AsString:= title;
    OrdIBSQL.ParamByName('IBVLINKTOSITE').AsString:= Link;
    OrdIBSQL.ParamByName('IBVUSERID').AsInteger:= UserID;
    OrdIBSQL.ExecQuery;
    if (NewsId<0) then NewsID:= OrdIBSQL.FieldByName('IBVCODE').Asinteger;
    OrdIBSQL.Transaction.Commit;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(NewsId);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
StrPos:='30';
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================
procedure prSaveImgForAction(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveImgForAction'; // ��� ���������/�������
var UserId, FirmId, NewsId: integer;
    errmess, StrPos, Link, oldimage, s: string;
    ordIBD: TIBDatabase;
    OrdIBSQL: TIBSQL;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBSQL:= nil;
  try
    FirmId:=isWe;
    UserId:= Stream.ReadInt;
StrPos:='0';
    NewsId:= Stream.ReadInt;
    Link:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csSaveImgForAction, UserId, 0, 'Newsid='+IntToStr(NewsId)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolNewsManage) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
StrPos:='2';
    s:= IntToStr(NewsId);
    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD, 'OrdIBSQL_'+nmProc, ThreadData.ID, tpRead, true);
    oldimage:= '';
    OrdIBSQL.SQL.Text:= 'Select IBVLINKTOPICT from INFOBOXVIEWS where ibvcode='+s;
    OrdIBSQL.ExecQuery;
    if (not OrdIBSQL.EOF) then oldimage:= OrdIBSQL.FieldByName('IBVLINKTOPICT').AsString;
    OrdIBSQL.Close;

    fnSetTransParams(OrdIBSQL.Transaction, tpWrite, True);
    OrdIBSQL.SQL.Text:= 'Update infoboxviews set IBVLINKTOPICT=:IBVLINKTOPICT where ibvcode='+s;
    OrdIBSQL.ParamByName('IBVLINKTOPICT').AsString:= Link;
    OrdIBSQL.ExecQuery;
    OrdIBSQL.Transaction.Commit;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(oldimage);
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
StrPos:='30';
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================
procedure prShowSysOptionsPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowSysOptionsPage'; // ��� ���������/�������
var EmplID, FirmID, i: integer;
    errmess: String;
    List: TStringList;
    Item: TConstItem;
begin
  Stream.Position:= 0;
  List:= nil;
  try
    EmplID:= Stream.ReadInt;
    FirmID:= isWe;

    prSetThLogParams(ThreadData, csShowSysOptionsPage, EmplID);

    if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteBool(Cache.arEmplInfo[EmplID].UserRoleExists(rolManageSprav)); // ����� �� ������������� �������� ����� � ����������

    List:= Cache.GetEmplConstants(EmplID);
    Stream.WriteInt(List.Count);
    for i:= 0 to List.Count-1 do begin
      Item:= Cache.GetConstItem(integer(List.Objects[i]));
      Stream.WriteInt(Item.ID);
      Stream.WriteStr(Item.Grouping);
      Stream.WriteStr(Item.Name);
      Stream.WriteInt(Item.ItemType);
      Stream.WriteBool(Cache.CheckEmplConstant(EmplID, Item.ID, errmess, true));
      Stream.WriteStr(fnGetAdaptedConstValue(integer(List.Objects[i])));
      if Cache.EmplExist(Item.LastUser) then
        errmess:= Cache.arEmplInfo[Item.LastUser].EmplShortName
      else errmess:= '�����������';
      Stream.WriteStr(errmess);
      Stream.WriteDouble(Item.LastTime);
    end;
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
end;
//==============================================================================
procedure prSaveSysOption(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSaveSysOption'; // ��� ���������/�������
var EmplID, FirmID, ConstId: integer;
    errmess, Value, sParam: String;
    Item: TConstItem;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    FirmID:= isWe;
    ConstID:= Stream.ReadInt;
    value:= Stream.ReadStr;
    sParam:= 'ConstID='+IntToStr(ConstID);
    try
      if CheckNotValidUser(EmplID, FirmID, errmess) then
        raise EBOBError.Create(errmess);
      if not Cache.CheckEmplConstant(EmplID, ConstID, errmess, true) then
        raise EBOBError.Create(errmess);

      errmess:= Cache.SaveNewConstValue(ConstID, EmplID, Value); // ��������� �������� �� ������ ������
      if (errmess<>'') then raise EBOBError.Create(errmess);

      sParam:= sParam+#13#10'Value='+Value; // ���������� ��������
    finally
      prSetThLogParams(ThreadData, csSaveSysOption, EmplID, 0, sParam);
    end;
    Item:= Cache.GetConstItem(ConstID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(fnGetAdaptedConstValue(ConstID));
    if Cache.EmplExist(Item.LastUser) then
      sParam:= Cache.arEmplInfo[Item.LastUser].EmplShortName
    else sParam:= '�����������';
    Stream.WriteStr(sParam);
    Stream.WriteDouble(Item.LastTime);
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prEditSysOption(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prEditSysOption'; // ��� ���������/�������
var EmplID, FirmID, ConstId, i, j: integer;
    errmess: String;
    List: TStringList;
    Employee: TEmplInfoItem;
    aos: Tas;
    Item: TConstItem;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    ConstID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csEditSysOption, EmplID, 0, 'ConstID='+IntToStr(ConstID));

    FirmID:= isWe;
    if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if not Cache.ConstExists(ConstID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ���='+IntToStr(ConstID));
    if not Cache.CheckEmplConstant(EmplID, ConstID, errmess, true) then raise EBOBError.Create(errmess);

    Item:= Cache.GetConstItem(ConstID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    case ConstID of
      pcEmplID_list_Rep30, pcTestingSending1, pcTestingSending2, pcTestingSending3,
        pcEmpl_list_UnBlock, pcEmpl_list_TmpBlock, pcEmpl_list_FinalBlock, pcVINmailEmpl_list: begin
        List:= TStringList.Create;
        aos:= fnSplitString(Item.StrValue, ',');
        for i:= 1 to High(Cache.arEmplInfo) do if Cache.EmplExist(i) then begin
          Employee:= Cache.arEmplInfo[i];
          if Employee.Arhived or Employee.Blocked or (Employee.Mail='') then Continue;
          list.AddObject(Employee.EmplShortName, Pointer(i));
        end;
        List.Sort;
        for i:= 1 to Length(ceNames) do list.AddObject(ceNames[-i], Pointer(-i));
        Stream.WriteInt(List.Count);
        for i:= 0 to List.Count-1 do begin
          j:= integer(List.Objects[i]);
          Stream.WriteInt(j);
          Stream.WriteBool(fnInStrArrayBool(IntToStr(j), aos));
          Stream.WriteStr(List[i]);
        end;
      end;  //pcEmplID_list_Rep30

      pcVINmailFilial_list, pcVINmailFirmClass_list,
      pcVINmailFirmTypes_list, pcPriceLoadFirmClasses: begin
        aos:= fnSplitString(Item.StrValue, ',');
        case ConstID of
          pcVINmailFilial_list   : List:= Cache.GetFilialList();
          pcVINmailFirmTypes_list: List:= Cache.GetFirmTypesList();
          pcVINmailFirmClass_list,
          pcPriceLoadFirmClasses : List:= Cache.GetFirmClassesList();
        end;
        Stream.WriteInt(List.Count);
        for i:= 0 to List.Count-1 do begin
          j:= integer(List.Objects[i]);
          Stream.WriteInt(j);
          Stream.WriteBool(fnInStrArrayBool(IntToStr(j), aos));
          Stream.WriteStr(List[i]);
        end;
      end;

      pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto: begin
        Stream.WriteInt(StrToInt(Item.StrValue));
        List:= TStringList.Create;
        for i:= 1 to High(Cache.arEmplInfo) do if Cache.EmplExist(i) then begin
          Employee:= Cache.arEmplInfo[i];
          if Employee.Arhived or Employee.Blocked then Continue;
          list.AddObject(Employee.EmplShortName, Pointer(i));
        end;
        List.Sort;
        Stream.WriteInt(List.Count);
        for i:= 0 to List.Count-1 do begin
          Stream.WriteInt(integer(List.Objects[i]));
          Stream.WriteStr(List[i]);
        end;
      end;  // pcEmplSaleDirectorAuto, pcEmplSaleDirectorMoto

      else raise EBOBError.Create('�� ����, ��� ���������� ��������.');
    end; // case
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
  SetLength(aos, 0);
end;
//==============================================================================
procedure prShowConstRoles(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowConstRoles'; // ��� ���������/�������
var EmplID, FirmID, ConstId: integer;
    errmess: String;
    i, varTo: integer;
    Roles: Tai;
    Item: TConstItem;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    ConstID:= Stream.ReadInt;
    FirmID:=isWe;

    prSetThLogParams(ThreadData, csShowConstRoles, EmplID, 0, 'ConstID='+IntToStr(ConstID));

    if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.ConstExists(ConstID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ���='+IntToStr(ConstID));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    Roles:= Cache.GetAllRoleCodes;
    varTo:= Length(Roles)-1;
    Stream.WriteInt(varTo); // ����� ��� ���-�� �����
    for i:= 0 to varTo do begin
      Stream.WriteInt(Roles[i]);
      Stream.WriteStr(Cache.GetRoleName(Roles[i]));
      Item:= Cache.GetConstItem(ConstID);
      if Item.Links.LinkExists(Roles[i]) then
        Stream.WriteInt(TLink(Item.Links[Roles[i]]).SrcId+100)
      else Stream.WriteInt(0);
    end;
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Roles, 0);
end;
//==============================================================================
procedure prEditConstRoles(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prEditConstRoles'; // ��� ���������/�������
var EmplID, FirmID, ConstId, ResCode, RoleCode, Rights, i, varTo: integer;
    errmess, s: String;
    List: TStringList;
    Item: TConstItem;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    ConstID:= Stream.ReadInt;
    errmess:= Stream.ReadStr;
    errmess:= StringReplace(errmess, '-', '=', [rfReplaceAll]);
    errmess:= StringReplace(errmess, '|', #13#10, [rfReplaceAll]);

    prSetThLogParams(ThreadData, csEditConstRoles, EmplID, 0, 'ConstID='+IntToStr(ConstID));

    List:= TStringList.Create;
    List.Text:= errmess;
    FirmID:= isWe;
    if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.ConstExists(ConstID) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - ���='+IntToStr(ConstID));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    Item:= Cache.GetConstItem(ConstID);
    varTo:= List.Count-1;
    errmess:= '';
    for i:= 0 to varTo do begin
      RoleCode:= StrToIntDef(List.Names[i], -1);
      Rights:= StrToIntDef(List.Values[List.Names[i]], -1);
      if (Cache.RoleExists(RoleCode) and (Rights in [0..2])) then begin
        if (Rights=0) then begin //�������
          if Item.Links.LinkExists(RoleCode) then begin
            ResCode:= resDeleted;
            s:= Cache.CheckRoleConstLink(ConstID, RoleCode, EmplID, false, ResCode);
            if ResCode=resError then errmess:= errmess+s+#13#10;
          end;
        end else begin
          if Item.Links.LinkExists(RoleCode) then ResCode:= resEdited
          else ResCode:= resAdded;
          s:= Cache.CheckRoleConstLink(ConstID, RoleCode, EmplID, Rights=2, ResCode);
          if ResCode=resError then errmess:= errmess+s+#13#10;
        end;
      end;
    end;
    if errmess<>'' then
      raise EBOBError.Create('�� ����� ���������� �������� �������� ��������� ������: '#13#10+errmess);
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
end;
//======= ���������� �������� �� ��������� ����� ������ c ������������� ��������
procedure prMarkOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMarkOneDirectAnalog'; // ��� ���������/�������
var UserId, WareID, ResCode, AnalogId, SrcID: integer;
    MsgStr: string;
    Ware: TWareInfo;
begin
  Stream.Position:= 0;
  try
    UserID     := Stream.ReadInt;
    WareID     := Stream.ReadInt;    // ��� ������
    AnalogId   := Stream.ReadInt;    // ��� �������
    ResCode    := Stream.ReadByte;   // ��� ��������
    SrcID      := Stream.ReadInt;    // ��� ���������

    prSetThLogParams(ThreadData, csMarkOneDirectAnalog, UserId, isWe, 'WareID='+IntToStr(WareID)+
      #13#10'AnalogId='+IntToStr(AnalogId)+#13#10'Operation='+IntToStr(ResCode));

    if not (ResCode in [resWrong, resNotWrong, resDeleted]) then
      raise EBOBError.Create('��������� ��� �������� '+IntToStr(resCode)+' !');

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolProduct) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    if not Cache.WareExist(AnalogId) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(AnalogId)));

    Ware:= Cache.GetWare(WareId);
    if Ware.ManagerID<>UserId then
      raise EBOBError.Create('� ��� ��� ���� �� ������ � ������� '+Ware.Name);

    MsgStr:= Cache.CheckWareCrossLink(AnalogId, WareID, ResCode, SrcID, UserID);
    Case ResCode of
      resError, resDoNothing: raise EBOBError.Create(MsgStr);
    end;// Case ResCode of

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;


//======================================== �������� ������������� ������ �������
procedure prAddOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddOneDirectAnalog'; // ��� ���������/�������
var UserId, WareID, ResCode: integer;
    AnalogName, MsgStr: string;
    Ware: TWareInfo;
    Wares: Tai;
begin
  Stream.Position:= 0;
  try
    UserID  := Stream.ReadInt;
    WareID  := Stream.ReadInt;    // ��� ������
    AnalogName:= Stream.ReadStr;    // ������������ �������

    prSetThLogParams(ThreadData, csAddOneDirectAnalog, UserId, isWe, 'WareID='+
      IntToStr(WareID)+#13#10'AnalogName='+AnalogName);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    Ware:= Cache.GetWare(WareId);
    if Ware.ManagerID<>UserId then
      raise EBOBError.Create('� ��� ��� ���� �� ������ � ������� '+Ware.Name);

    Wares:= SearchWareNames(AnalogName, 3);

    if (Length(Wares)=0) then
      raise EBOBError.Create('�� ������ �����-������ [ '+(AnalogName)+' ] !');

    ResCode:= resAdded;
    MsgStr:= Cache.CheckWareCrossLink(Wares[0], WareID, ResCode, soHand, UserID);
    Case ResCode of
      resError, resDoNothing: raise EBOBError.Create(MsgStr);
    end;// Case ResCode of

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Wares, 0);
end;
//==============================================================================
procedure prUiKPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prUiKPage'; // ��� ���������/�������
var UserId: integer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    prSetThLogParams(ThreadData, csUiKPage, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    if not Cache.arEmplInfo[UserId].UserRoleExists(rolUiK) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prShowPortion(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowPortion'; // ��� ���������/�������
var WareId, ModelID, NodeID, UserId, PortionID, i, sysID, pos: integer;
    ordIBD: TIBDatabase;
    OrdIBSQL: TIBSQL;
    empl: TEmplInfoItem;
    flAuto, flMoto, flCV: Boolean;
begin
  Stream.Position:= 0;
  ordIBD:=nil;
  OrdIBSQL:= nil;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    PortionID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowPortion, UserId, 0, 'ModelID='+IntToStr(ModelID)+#10#13'NodeID='+
      IntToStr(NodeID)+#10#13'WareID='+IntToStr(WareID)+#10#13'PortionID='+IntToStr(PortionID));

    if not Cache.EmplExist(UserID) then raise EBOBError.Create(MessText(mtkNotEmplExist));

    empl:= Cache.arEmplInfo[UserId];
    flAuto:= empl.UserRoleExists(rolTNAManageAuto);
    flMoto:= empl.UserRoleExists(rolTNAManageMoto);
    flCV:= empl.UserRoleExists(rolTNAManageCV);

    if not (flAuto or flMoto or flCV) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create(MessText(mtkNotFoundModel, IntToStr(ModelID)));

    sysID:= Cache.FDCA.Models[ModelID].TypeSys;
    case sysID of
      constIsAuto: if not flAuto then raise EBOBError.Create(MessText(mtkNotRightExists));
      constIsMoto: if not flMoto then raise EBOBError.Create(MessText(mtkNotRightExists));
      constIsCV:   if not flCV   then raise EBOBError.Create(MessText(mtkNotRightExists));
      else raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));
    end; // case
    if not Cache.FDCA.AutoTreeNodesSys[sysID].NodeExists(NodeId) then
      raise EBOBError.Create(MessText(mtkNotFoundNode, IntToStr(NodeId)));

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD,'OrdIBS_'+nmProc,ThreadData.ID, tpRead, True);
    OrdIBSQL.SQl.Clear;
    OrdIBSQL.SQL.Add('select c.wcridescr, v.wcvsvalue from GetModelNodeWareLinkCode('+
                     IntToStr(ModelID)+', '+IntToStr(NodeID)+', '+IntToStr(WareID)+') l3');
    OrdIBSQL.SQL.Add(' left join linkwaremodelnodeusage u on u.lwmnuldmwcode=l3.rLDMWCODE'+
                     ' and u.lwmnupart='+IntToStr(PortionID));
    OrdIBSQL.SQL.Add(' left join warecrivalues v on v.wcvscode=u.lwmnuwcvscode');
    OrdIBSQL.SQL.Add(' left join warecriteries c on c.wcricode=v.wcvswcricode');
    OrdIBSQL.SQL.Add(' order by c.wcridescr, v.wcvsvalue');
    OrdIBSQL.ExecQuery;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0); // ����� ��� ���-��
    i:= 0;
    while not OrdIBSQL.EOF do begin
      Stream.WriteStr(OrdIBSQL.fieldByName('wcridescr').AsString);
      Stream.WriteStr(OrdIBSQL.fieldByName('wcvsvalue').AsString);
      Inc(i);
      TestCssStopException;
      OrdIBSQL.Next;
    end;
    Stream.Position:= pos;
    Stream.WriteInt(i);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================   ???
procedure prGetRadiatorList;
const nmProc = 'prGetRadiatorList'; // ��� ���������/�������
var TDIBDatabase: TIBDatabase;
    TDIBS: TIBSQL;
    arFirst, arSecond: Tai;
    OL, OL1: TObjectList;
    ArticlesMin, CurrentModel, i, j, k, jj, art_id: integer;
    Founded: boolean;
    TwoCodes: TTwoCodes;
    SL, SLTemp: TStringList;
    Articles, Models: Tas;
  //--------------------------------------
  function ComparePairs(Item1, Item2: Pointer): Integer;
  var TwoCode1, TwoCode2: TTwoCodes;
  begin
    TwoCode1:= TTwoCodes(TObjectList(Item1)[0]);
    TwoCode2:= TTwoCodes(TObjectList(Item2)[0]);
    if (TwoCode1.ID1<TwoCode2.ID1) then Result:= -1
    else if (TwoCode1.ID1>TwoCode2.ID1) then Result:= 1
    else if (TwoCode1.ID2<TwoCode2.ID2) then Result:= -1
    else if (TwoCode1.ID2>TwoCode2.ID2) then Result:= 1
    else Result:= 0;
  end;
  //--------------------------------------
begin
  TDIBDatabase:= nil;
  TDIBS:= nil;
  SetLength(arFirst, 0);
  SetLength(arSecond, 0);
  CurrentModel:= -1;
  OL1:= nil;
  OL:= TObjectList.Create;
  try
    TDIBDatabase:= CntsTDT.GetFreeCnt;
    TDIBS:= fnCreateNewIBSQL(TDIBDatabase, 'OrdIBS_'+nmProc, 0, tpRead, True);

    // ������� ������ ������� � ����, ��������� ��� ������� � csv ���� +++
    TDIBS.SQL.Text:= 'select Max(m.mt_id) max_ from model_types m';
    TDIBS.ExecQuery;
    SetLength(Models, TDIBS.FieldByName('max_').AsInteger+1);
    TDIBS.Close;

    for i:= 0 to High(Models) do Models[i]:= ''; // �������������� ������

    TDIBS.SQl.Clear;
    TDIBS.SQL.Add('select m.mt_id, mf.mf_descr, s.ms_descr, m.mt_descr,');
    TDIBS.SQL.Add(' m.mt_from, m.mt_to, m.mt_hp, e.eng_mark from model_types m');
    TDIBS.SQL.Add(' left join model_series s on s.ms_id=m.mt_ms_id');
    TDIBS.SQL.Add(' left join manufacturers mf on mf.mf_id=s.ms_mf_id');
    TDIBS.SQL.Add(' left outer join link_eng_model_types le on le.lemt_mt_id=m.mt_id');
    TDIBS.SQL.Add(' left join engines e on e.eng_id=le.lemt_eng_id');
    TDIBS.SQL.Add(' order by m.mt_id, e.eng_mark');
    TDIBS.ExecQuery;
    while not TDIBS.Eof do begin
      i:= TDIBS.FieldByName('mt_id').AsInteger;
      j:= TDIBS.FieldByName('mt_to').AsInteger;
      if Models[i]='' then
        Models[i]:= TDIBS.FieldByName('mf_descr').AsString+';" '+
                    TDIBS.FieldByName('ms_descr').AsString+' "'+';" '+
                    TDIBS.FieldByName('mt_descr').AsString+' "'+';'+
                    TDIBS.FieldByName('mt_from').AsString+'-'+
                    fnIfStr(j>0, TDIBS.FieldByName('mt_to').AsString, '')+';'+
                    TDIBS.FieldByName('mt_hp').AsString+';'+
                    TDIBS.FieldByName('mt_id').AsString+';'+
                    TDIBS.FieldByName('eng_mark').AsString
      else Models[i]:= Models[TDIBS.FieldByName('mt_id').AsInteger]+', '+
                       TDIBS.FieldByName('eng_mark').AsString;
      TestCssStopException;
      TDIBS.Next;
    end;
    TDIBS.Close;
    // ������� ������ ������� � ����, ��������� ��� ������� � csv ���� ---

// ������� ��� ��������, ������� ������ ����������� � ������� ������ � ��������,
// � ������� ��� ���������, ������ �������� �� ���� ������
    TDIBS.SQl.Clear;
    TDIBS.SQL.Add('select '); //    TDIBS.SQL.Add('first 100 ');
    TDIBS.SQL.Add('l.lacgs_ga_ID lagt_ga_id, l.lacgs_VknZielNr lagt_mt_id,'+
                  ' l.lacgs_art_ID lagt_art_id from link_art_cri_ga_sort l');
    TDIBS.SQL.Add('where l.lacgs_ga_ID in (447, 448, 2842, 2843)');
    TDIBS.SQL.Add(' and l.lacgs_VknZielArt=2 and l.lacgs_sup_ID in (66, 123)');
    TDIBS.SQL.Add('order by l.lacgs_VknZielNr');
    TDIBS.ExecQuery;
    while not TDIBS.Eof do begin
// ���� ��� ������ ����������� �� ������ ���, �� ��� �������� ����������� � ������ arFirst ��� arSecond
// (�� ������ ���� ����� TDIBS.Next;)
// ��������, � ����� ������ ���������, �������� �� ������ ���������, � ������, �������������� �������� ������ � ������(�������������)
      jj:= TDIBS.FieldByName('lagt_mt_id').AsInteger;
      if (jj<>CurrentModel) then begin
// ���� ������ ����������� ������ ���, �� ��� ����, ��� ���������� ����������� (��� ��� ���������� ������� ���� �� ���� ������)
// � ����� ����� ������� �����
// OL - ��� ObjectList, � ������� ����� ������� ���� ���� �ObjectList
// �� ���������� ObjectList �� ��� �������. ������ ���� TTwoCodes, ������� �������� ���� ��� ������� ������ � ������ ������
// ������ ���� TStringList, ������� �������� ������ � ��������.
{ TODO : ��� �����������, ��� � ��������� StringList ��� �������� ������ ����� �������, ��� �������� ������ ������. �������� �� Tlist }
// ���������� ��� ��������� ��������� ��������� �������� arFirst � arSecond
        for i:= 0 to High(arFirst) do for j:= 0 to High(arSecond) do begin
          Founded:= false;
          for k:= 0 to OL.Count-1 do begin
            OL1:= TObjectList(OL[k]);
            TwoCodes:= TTwoCodes(OL1[0]);
            Founded:= (TwoCodes.ID1=arFirst[i]) and (TwoCodes.ID2=arSecond[j]);
            if Founded then break;
          end;
// ���� �����, �� � OL1 ������ �� �����
          if not Founded then begin
            OL1:= TObjectList.Create;
            OL1.Add(TTWoCodes.Create(arFirst[i], arSecond[j]));
            OL.Add(OL1);
            SLTemp:= TStringList.Create;
            OL1.Add(SLTemp);
          end;
          SLTemp:= TStringList(OL1[1]);
          SLTemp.Add(Models[CurrentModel]);
        end;
        SetLength(arFirst, 0);
        SetLength(arSecond, 0);
        CurrentModel:= jj;
      end;
      jj:= TDIBS.FieldByName('lagt_ga_id').AsInteger;
      art_id:= TDIBS.FieldByName('lagt_art_id').AsInteger;
      if (jj=447) or (jj=2842) then prAddItemToIntArray(art_id, arFirst);
      if (jj=448) or (jj=2843) then prAddItemToIntArray(art_id, arSecond);
      TestCssStopException;
      TDIBS.Next;
    end;
    TDIBS.Close;

    TDIBS.SQl.Clear;
    TDIBS.SQL.Add('select Min(lacgs_art_ID) min_, Max(lacgs_art_ID) max_');
    TDIBS.SQL.Add(' from link_art_cri_ga_sort where lacgs_VknZielArt=2');
    TDIBS.SQL.Add('   and lacgs_ga_ID in (447, 448, 2842, 2843) ');
    TDIBS.SQL.Add('   and lacgs_sup_ID in (66, 123)');
    TDIBS.ExecQuery;
    ArticlesMin:= TDIBS.FieldByName('min_').AsInteger;
    SetLength(Articles, TDIBS.FieldByName('max_').AsInteger-ArticlesMin+1);
    TDIBS.Close;

    TDIBS.SQL.Clear;
    TDIBS.SQL.Add('select art_id, art_nr, art_warecode, ds_bra from articles, data_suppliers');
    TDIBS.SQL.Add(' where ds_id=art_sup_id and ds_id in (66, 123) and art_id in');
    TDIBS.SQL.Add(' (select lacgs_art_ID from link_art_cri_ga_sort where lacgs_ga_ID in (447, 448, 2842, 2843)');
    TDIBS.SQL.Add('  and lacgs_VknZielArt=2 and lacgs_sup_ID in (66, 123))');

    TDIBS.ExecQuery;
    while not TDIBS.Eof do begin
      Articles[TDIBS.FieldByName('art_id').AsInteger-ArticlesMin]:=
        TDIBS.FieldByName('art_warecode').AsString+
        TDIBS.FieldByName('ds_bra').AsString+' '+
        TDIBS.FieldByName('art_nr').AsString;
      TestCssStopException;
      TDIBS.Next;
    end;
    TDIBS.Close;

    OL.Sort(@ComparePairs);
    SL:= TStringList.Create;
    SL.Add('�������������;��������� ���;������;���� �������;��������;���;���������');
    for k:= 0 to OL.Count-1 do begin
      OL1:= TObjectList(OL[k]);
      TwoCodes:= TTwoCodes(OL1[0]);
      SLTemp:= TStringList(OL1[1]);
      SL.Add('');
      SL.Add(Copy(Articles[-ArticlesMin+TwoCodes.ID1], 2, 10000)+';'+Copy(Articles[-ArticlesMin+TwoCodes.ID2], 2, 10000));
      SL.Add(Copy(Articles[-ArticlesMin+TwoCodes.ID1], 1, 1)+';'+Copy(Articles[-ArticlesMin+TwoCodes.ID2], 1, 1));
      SL.AddStrings(SLTemp);
    end;

    SL.SaveToFile('111.csv');
    ShowMessage('I did it!');
  except
    on E: Exception do ShowMessage(E.Message);
  end;
  prFreeIBSQL(TDIBS);
  cntsTDT.SetFreeCnt(TDIBDatabase);
  SetLength(arFirst, 0);
  SetLength(arSecond, 0);
  SetLength(Articles, 0);
  SetLength(Models, 0);
end;
//====================================================== �������� "������������"
procedure prCOUPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCOUPage'; // ��� ���������/�������
var UserId, i: integer;
    ordIBD: TIBDatabase;
    OrdIBSQL: TIBSQL;
    empl: TEmplInfoItem;
    flAuto, flMoto: Boolean;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBSQL:= nil;
  try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csCOUPage, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    empl:= Cache.arEmplInfo[UserId];
    flAuto:= empl.UserRoleExists(rolTNAManageAuto);
    flMoto:= empl.UserRoleExists(rolTNAManageMoto);

    //-------------------------  �������� CV ???

    if not (flAuto or flMoto) then raise EBOBError.Create(MessText(mtkNotRightExists));
    if (flAuto and flMoto) then
      raise EBOBError.Create('���������� ���������� ������-����������� ��� ������ ���������.');

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD,'OrdIBS_'+nmProc,ThreadData.ID, tpWrite, True);
    OrdIBSQL.SQl.Clear;
    OrdIBSQL.SQL.Add('select wc.wcridescr from warecriteries wc where ');
    if flAuto then OrdIBSQL.SQL.Add('wc.wcriedituseauto="T"');
    if flMoto then OrdIBSQL.SQL.Add('wc.wcrieditusemoto="T"');
    OrdIBSQL.SQL.Add('group by wc.wcridescr order by wc.wcridescr');

    OrdIBSQL.ExecQuery;
    Stream.WriteInt(0); // ����� ��� ���-��
    i:= 0;
    while not OrdIBSQL.EOF do begin
      Stream.WriteStr(OrdIBSQL.fieldByName('wcridescr').AsString);
      Inc(i);
      TestCssStopException;
      OrdIBSQL.Next;
    end;
    OrdIBSQL.Close;
    Stream.Position:= 4;
    Stream.WriteInt(i);

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;

//===================================================== ������ �������� ��������
procedure prGetCateroryValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCateroryValues'; // ��� ���������/�������
var UserId, i, Position: integer;
    ordIBD: TIBDatabase;
    OrdIBSQL: TIBSQL;
    ss, Criteria: string;
    flAuto, flMoto: Boolean;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBSQL:= nil;
  try
    UserID:= Stream.ReadInt;
    Criteria:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetCateroryValues, UserId, isWe, 'Criteria='+Criteria);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    //-------------------------------- �������� CV ???

    with Cache.arEmplInfo[UserId] do begin
      flAuto:= UserRoleExists(rolTNAManageAuto);
      flMoto:= UserRoleExists(rolTNAManageMoto);
    end;
    if not (flAuto or flMoto) then raise EBOBError.Create(MessText(mtkNotRightExists));
    if (flAuto and flMoto) then
      raise EBOBError.Create('���������� ���������� ������-����������� ��� ������ ���������.');

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(0); // ����� ��� ���-�� ��������� ��������
    Stream.WriteInt(0); // ����� ��� ���-�� ???

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);

    OrdIBSQL.SQl.Clear;
    OrdIBSQL.SQL.Add('select first 1 wc.* from warecriteries wc');
    OrdIBSQL.SQL.Add(' where wc.wcridescr='''+Criteria+''' and ');
    OrdIBSQL.SQL.Add(' wc.wcriedituse'+fnIfStr(flAuto, 'auto', 'moto')+'="T"');
    OrdIBSQL.SQL.Add(' order by wc.wcricode');
    OrdIBSQL.ExecQuery;
    if OrdIBSQL.EOF then raise EBOBError.Create('�� ������ �������� "'+Criteria+'"');
    if OrdIBSQL.fieldByName('WCRICHOICE').AsString='T' then begin
      ss:= OrdIBSQL.fieldByName('wcricode').AsString;
      OrdIBSQL.Close;
//      Position:=Stream.Position;
      i:= 0;
      Stream.Position:= 8;
      if (Cache.GetConstItem(pcStartLastCriValues).IntValue>0) then begin
        OrdIBSQL.SQl.Clear;
        OrdIBSQL.SQL.Add(' select first '+Cache.GetConstItem(pcStartLastCriValues).StrValue);
        OrdIBSQL.SQL.Add('  lwmnuwcvscode, wcvsvalue, ftime');
        OrdIBSQL.SQL.Add('  from (select l.lwmnuwcvscode, v.wcvsvalue, max(l.lwmnutimeadd) ftime');
        OrdIBSQL.SQL.Add('    from LINKWAREMODELNODEUSAGE l ');
        OrdIBSQL.SQL.Add('    left join warecrivalues v on l.lwmnuwcvscode=v.wcvscode');
        OrdIBSQL.SQL.Add('    where v.wcvswcricode='+ss+' and l.lwmnuuserid='+IntToStr(UserId));
        OrdIBSQL.SQL.Add('      and l.lwmnusrclecode='+IntToStr(soHand));
        OrdIBSQL.SQL.Add('      group by l.lwmnuwcvscode, v.wcvsvalue)');
        OrdIBSQL.SQL.Add('  order by ftime desc');
        OrdIBSQL.ExecQuery;
        while not OrdIBSQL.EOF do begin
          Stream.WriteStr(OrdIBSQL.fieldByName('wcvsvalue').AsString);
          Inc(i);
          TestCssStopException;
          OrdIBSQL.Next;
        end;
        OrdIBSQL.Close;
        Position:= Stream.Position;
        Stream.Position:= 4;
        Stream.WriteInt(i);
        Stream.Position:= Position;
      end;

      OrdIBSQL.SQL.Text:= 'select wcvsvalue from warecrivalues wcv'+
                          ' where wcv.wcvswcricode='+ss+' order by wcv.wcvsvalue';
      OrdIBSQL.ExecQuery;
      Position:= Stream.Position;
      i:= 0;
      Stream.WriteInt(0); // ����� ��� ���-��
      while not OrdIBSQL.EOF do begin
        Stream.WriteStr(OrdIBSQL.fieldByName('wcvsvalue').AsString);
        Inc(i);
        TestCssStopException;
        OrdIBSQL.Next;
      end;
      OrdIBSQL.Close;
      Stream.Position:= Position;
      Stream.WriteInt(i);
    end;
    OrdIBSQL.Close;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;
//============ ����������/�������������� ������ ������� � 3-� ������ (���������)
procedure prSavePortion(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSavePortion'; // ��� ���������/�������
var WareId, ModelID, NodeID, UserId, PortionID, i, qty: integer;
    ss: string;
    SL: TStringList;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  try
    UserID   := Stream.ReadInt;
    ModelID  := Stream.ReadInt;
    NodeID   := Stream.ReadInt;
    WareID   := Stream.ReadInt;
    PortionID:= Stream.ReadInt;
    qty      := Stream.ReadInt; // ���-�� �������

    prSetThLogParams(ThreadData, csSavePortion, UserId, 0, 'ModelID='+IntToStr(ModelID)+
      #10#13'NodeID='+IntToStr(NodeID)+#10#13'WareID='+IntToStr(WareID)+
      #10#13'PortionID='+IntToStr(PortionID)+#10#13'qty='+IntToStr(qty));

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if (qty=0) then raise EBOBError.Create('������ ��������� ���� ��� �����������');

    SL:= TStringList.Create;
    for i:= 0 to qty-1 do SL.Add(Stream.ReadStr+cStrValueDelim+Stream.ReadStr);

    empl:= Cache.arEmplInfo[UserId];
    if not (empl.UserRoleExists(rolModelManageAuto)
      or empl.UserRoleExists(rolModelManageMoto)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create('�� ������� �������� ������');
    if empl.UserRoleExists(rolModelManageAuto)
      and not Cache.FDCA.AutoTreeNodesSys[constIsAuto].NodeExists(NodeId) then
      raise EBOBError.Create('������� ������ ����');
    if empl.UserRoleExists(rolModelManageMoto)
      and not Cache.FDCA.AutoTreeNodesSys[constIsMoto].NodeExists(NodeId) then
      raise EBOBError.Create('������� ������ ����');
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    if ((Cache.FDCA.Models[ModelID].TypeSys=constIsAuto)
      and not empl.UserRoleExists(rolModelManageAuto))
      or ((Cache.FDCA.Models[ModelID].TypeSys=constIsMoto)
      and not empl.UserRoleExists(rolModelManageMoto)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if (PortionId<0) then
      ss:= Cache.AddModelNodeWareUseListLinks(ModelID, NodeID, WareID, UserID, soHand, SL, PortionID)
    else
      ss:= Cache.ChangeModelNodeWareUsesPart(ModelID, NodeID, WareID, UserID, soHand, SL, PortionID);

    if (ss<>'') then raise EBOBError.Create(ss);

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(SL);
end;


procedure prGetDeliveriesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetDeliveriesList'; // ��� ���������/�������
var EmplID, StoreId, i: integer;
    s: string;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    StoreId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetDeliveriesList, EmplID, 0, 'StoreId='+IntToStr(StoreId)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
    with Cache.GetShipMethodsList(StoreId) do try                      // ������ ������� �������� �� ������
      Stream.WriteInt(Count);
      for i:= 0 to Count-1 do begin
        Stream.WriteInt(Integer(Objects[i]));
        Stream.WriteStr(Strings[i]);
      end;
    finally
      Free;
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//==============================================================================
procedure prRestorePassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prRestorePassword'; // ��� ���������/�������
var s, IP, s1, s2: string;
    empl: TEmplInfoItem;
    EmplID: integer;
    Body: TStringList;
begin
  Body:= nil;
  Stream.Position:= 0;
  try
    S:= Stream.ReadStr;
    IP:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csRestorePassword, 0, 0, 'login='+s+#13#10'IP='+IP); // �����������

    EmplID:= Cache.GetEmplIDbyLogin(s);
    if (EmplID<1) then raise EBOBError.Create('�� ������ ����� "'+s+'"');

    Empl:= Cache.arEmplInfo[EmplID];
    s1:= '���� ������� ������ ������������� ���������������';
    if (Empl.Arhived) then raise EBOBError.Create(s1+' ������� GrossBee.');
    if (Empl.Blocked) then raise EBOBError.Create(s1+' werbarm.');
    s1:= '';
    s:= Empl.Mail;
    if (s='') then begin
      s1:= '����������� ��� e-mail.';
      s2:= '������ ��� e-mail � ����������';
    end else if not fnCheckEmail(s) then begin
      s1:= '������� ����� ��� e-mail: '+s+'.';
      s2:= '��������� ��� e-mail � �����������';
    end;
    if (s1<>'') then raise EBOBError.Create('� ����������� ����������� GrossBee '+s1+
      ' ���������� � ����� ��� ��������������� ��� ����� ������ ������������ � �������� '+s2+'.');

{    s:= '172.20.10.';
    s1:= '192.168.2.';
    if ((Copy(IP, 1, Length(s))<>s) and (Copy(IP, 1, Length(s1))<>s1)) then
      raise EBOBError.Create('��� IP '+IP+' �� ��������� � ����� ����������� ��� �������������� ������.');   }

    Body:= TStringList.Create;
    Body.Add('�� �������, ������������ � IP '+IP+', ��� ���������� ������� ������ ��� ����� � webarm:');
    Body.Add('�����:  http://webarm.vladislav.ua/app/webarm.cgi');
    Body.Add('�����: '+Empl.ServerLogin);
    Body.Add('������: '+Empl.USERPASSFORSERVER);

    s:= n_SysMailSend(Empl.Mail, '�������������� ������ webarm', Body);

    if (s<>'') then raise EBOBError.Create('�� ���� ��������� �����. ������ "'+s+'"');

    raise EBOBError.Create('������ ��������� �� E-mail "'+Empl.Mail+'"');
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(Body);
end;
//========================================== ����������/������������� ����������
procedure prBlockWebArmUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prBlockWebArmUser'; // ��� ���������/�������
var ordIBD: TIBDatabase;
    OrdIBSQL: TIBSQL;
    EmplID, VictimID: integer;
    command, s: string;
    Victim: TEmplInfoItem;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBSQL:= nil;
  try
    EmplID:= Stream.ReadInt;
    VictimID:= Stream.ReadInt;
    command:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csBlockWebArmUser, EmplID, 0, 'VictimID='+IntToStr(VictimID)+#13#10'command='+command); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolManageUsers)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    if CheckNotValidUser(VictimID, isWe, s) then raise EBOBError.Create(s); // �������� ������
    Victim:= Cache.arEmplInfo[VictimId];

    if ((command<>'block') and (command<>'unblock')) then
      raise EBOBError.Create('����������� ���������� - "'+command+'"');

    if ((command='block') and Victim.Blocked) then
      raise EBOBError.Create('������������ ��� ������������');

    if ((command<>'block') and not Victim.Blocked) then
      raise EBOBError.Create('������������ �� ������������');

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);

    OrdIBSQL.SQl.Text:= 'UPDATE EMPLOYEES SET EMPLBLOCK='+
      fnIfStr(command='block', '1', '0')+' where EMPLCODE='+IntToStr(VictimID);
    OrdIBSQL.ExecQuery;
    OrdIBSQL.Transaction.Commit;

    Victim.Blocked:= (command='block');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBSQL);
  cntsORD.SetFreeCnt(ordIBD);
end;
//==============================================================================
procedure prCheckRestsInStorageForAcc(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCheckRestsInStorageForAcc'; // ��� ���������/�������
var EmplID, i, StorageId, Pos, Count: integer;
    s, waress: string;
    wares: Tai;
    link: TQtyLink;
    rest: Double;
begin
  Stream.Position:= 0;
  SetLength(wares, 0);
  try
    EmplID:= Stream.ReadInt;
    StorageId:= Stream.ReadInt;
    waress:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csCheckRestsInStorageForAcc, EmplID, 0,
      'Storage='+IntToStr(StorageId)+#13#10'wares='+s); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolOPRSK)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.DprtExist(StorageId) then
        raise EBOBError.Create('�� ������ ����� � ����� '+IntToStr(StorageId));

    wares:= fnArrOfCodesFromString(waress);
    if (Length(wares)=0) then raise EBOBError.Create('��� ������ ��� ���������');

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
    Pos:= Stream.Position;
    Stream.WriteInt(0);
    Count:= 0;
    for i:= 0 to High(wares) do begin
      if Cache.WareExist(wares[i]) then begin
        link:= Cache.GetWare(wares[i]).RestLinks[StorageID];
        if Assigned(link) then Rest:= link.Qty  else Rest:= 0;
        Stream.WriteInt(wares[i]);
        Stream.WriteDouble(Rest);
        Inc(Count);
      end;
    end;
    Stream.Position:= Pos;
    Stream.WriteInt(Count);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(wares, 0);
end;
//==============================================================================
function fnRep47(UserID: integer; var lstBodyMail: TStringList; var FName, Subj,
         ContentType:string; ThreadData: TThreadData; filter_data: string): string;
const nmProc = 'fnRep47'; // ��� ���������/�������
var
//  ordIBD: TIBDatabase;
//  OrdIBSQL: TIBSQL;
  gbIBD, gbIBDw: TIBDatabase;
  GBIBSelectSQL, GBIBInsertSQL: TIBSQL;
  ErrorMessage, PathFile, s: string;
  total, added, skipped, addeddelta, skippeddelta, startid, i, j: Integer;
  StartTime: TDateTime;
  Ware, Analog: TWareInfo;
  Analogs: Tai;
//  ShosBulo: boolean;
begin
//  ordIBD:=nil;
//  OrdIBSQL:= nil;
  gbIBD:= nil;
  gbIBDw:= nil;
  GBIBSelectSQL:= nil;
  GBIBInsertSQL:= nil;
  ErrorMessage:= '';
  added:= 0;
  skipped:= 0;
  StartTime:= Now();
  lstBodyMail:= TStringList.Create;
  try

//    ordIBD:=CntsOrd.GetFreeCnt;
//    OrdIBSQL:=fnCreateNewIBSQL(ordIBD,'OrdIBSQL_'+nmProc,ThreadData.ID, tpRead, true);
    s:= Cache.arEmplInfo[UserID].GBLogin;
    gbIBD:= CntsGrb.GetFreeCnt(s, cDefPassword, cDefGBrole);
    gbIBDw:= CntsGrb.GetFreeCnt(s, cDefPassword, cDefGBrole);

    GBIBSelectSQL:= fnCreateNewIBSQL(gbIBD, 'GBIBSelectSQL_'+nmProc, ThreadData.ID, tpRead, true);
    GBIBSelectSQL.SQL.Text:= 'SELECT * FROM PMWAREANALOGS'+
      ' WHERE PMWAWARECODE=:PMWAWARECODE and PMWAWAREANALOGCODE=:PMWAWAREANALOGCODE';
    GBIBSelectSQL.Prepare;

    GBIBInsertSQL:= fnCreateNewIBSQL(gbIBDw, 'GBIBInsertSQL_'+nmProc, ThreadData.ID, tpWrite, true);
    GBIBInsertSQL.SQL.Text:= 'INSERT INTO PMWAREANALOGS'+
      ' (PMWAWARECODE, PMWAWAREANALOGCODE, PMWASOURCECODE, PMWAISWRONG, PMWAUSERCODE) VALUES'+
      ' (:PMWAWARECODE, :PMWAWAREANALOGCODE, :PMWASOURCECODE, "F", :PMWAUSERCODE)';
    GBIBInsertSQL.Prepare;

    startid:= Cache.GetConstItem(pcLastAddLoadWare).IntValue;
    total:= High(Cache.arWareInfo)-StartID;

    for I:= StartID+1 to High(Cache.arWareInfo) do begin
      addeddelta:= 0;
      skippeddelta:= 0;
      if Cache.WareExist(i) then begin
        Ware:= Cache.GetWare(i);
//        if Ware.IsWare and not Ware.IsArchive then begin
        if Ware.IsWare and not Ware.IsArchive and (Ware.ArticleTD<>'') then begin
          Analogs:= Ware.Analogs;
          if (length(Analogs)>0) and not GBIBInsertSQL.Transaction.Active then
            GBIBInsertSQL.Transaction.StartTransaction;
          for j:= 0 to High(Analogs) do begin
            if not Cache.WareExist(Analogs[j]) then begin
              Inc(skippeddelta);
              continue;
            end;
            Analog:= Cache.GetWare(Analogs[j]);
            if not Analog.isWare or Analog.IsArchive or Analog.IsINFOgr or (Analog.ArticleTD='') then begin
              Inc(skippeddelta);
              continue;
            end;
            GBIBSelectSQL.ParamByname('PMWAWARECODE').Asinteger:= Ware.ID;
            GBIBSelectSQL.ParamByname('PMWAWAREANALOGCODE').Asinteger:= Analog.ID;
            GBIBSelectSQL.ExecQuery;
            if GBIBSelectSQL.EOF then begin
              GBIBInsertSQL.ParamByname('PMWAWARECODE').Asinteger:= Ware.ID;
              GBIBInsertSQL.ParamByname('PMWAWAREANALOGCODE').Asinteger:= Analog.ID;
              GBIBInsertSQL.ParamByname('PMWASOURCECODE').Asinteger:= Cache.FDCA.GetSourceGBcode(soGrossBee);
              GBIBInsertSQL.ParamByname('PMWAUSERCODE').Asinteger:= UserID;
              GBIBInsertSQL.ExecQuery;
              Inc(addeddelta);
            end else Inc(skippeddelta);
            GBIBSelectSQL.Close;
          end;
          SetLength(Analogs, 0);
        end;
      end;
      if addeddelta>0 then begin
        GBIBInsertSQL.Transaction.Commit;
        added:= added+addeddelta;
        skipped:= skipped+skippeddelta;
      end;
      Cache.SaveNewConstValue(pcLastAddLoadWare, UserId, IntToStr(i));
      prStopProcess(UserID, ThreadData.ID);
      ImpCheck.SetProcessPercent(UserId, ThreadData.ID, (i-StartID)/total);
//if (((i-startid)>100) and (added>0)) then break;
    end;
(* ������ ��������� - ��������� �������� �� ���� ORD
    GBIBSelectSQL.SQL.Text:='SELECT * FROM PMWAREANALOGS WHERE PMWAWARECODE=:PMWAWARECODE and PMWAWAREANALOGCODE=:PMWAWAREANALOGCODE';
    GBIBSelectSQL.Prepare;
    GBIBInsertSQL:=fnCreateNewIBSQL(gbIBD,'GBIBInsertSQL_'+nmProc,ThreadData.ID, tpWrite, true);
    GBIBInsertSQL.SQL.Text:='INSERT INTO PMWAREANALOGS (PMWAWARECODE, PMWAWAREANALOGCODE, PMWASOURCECODE, PMWAISWRONG, PMWAUSERCODE, PMWALASTEDITDATE) '
                     +'VALUES (:PMWAWARECODE, :PMWAWAREANALOGCODE, :PMWASOURCECODE, :PMWAISWRONG, :PMWAUSERCODE, :PMWALASTEDITDATE)';
    GBIBInsertSQL.Prepare;

    OrdIBSQL.SQL.Text:='Select count(LWACODE) from LINKWAREANALOGS where LWACODE>'+Cache.GetConstItem(pcLastAddLoadWare).StrValue;
    OrdIBSQL.ExecQuery;
    total:=OrdIBSQL.Fields[0].AsInteger;
    OrdIBSQL.Close;

    OrdIBSQL.SQL.Text:='Select FIRST 1000 * from LINKWAREANALOGS where LWACODE>:lastcode order by LWACODE';
    while true do begin
      addeddelta:=0;
      skippeddelta:=0;
      OrdIBSQL.ParamByname('lastcode').Asinteger:=Cache.GetConstItem(pcLastAddLoadWare).IntValue;
      OrdIBSQL.ExecQuery;
      if OrdIBSQL.EOF then break;
      if not GBIBInsertSQL.Transaction.Active then GBIBInsertSQL.Transaction.StartTransaction;
      while not OrdIBSQL.EOF do begin
        GBIBSelectSQL.ParamByname('PMWAWARECODE').Asinteger:=OrdIBSQL.FieldByName('LWAWARECODE').Asinteger;
        GBIBSelectSQL.ParamByname('PMWAWAREANALOGCODE').Asinteger:=OrdIBSQL.FieldByName('LWAANALOG').Asinteger;
        GBIBSelectSQL.ExecQuery;
        if GBIBSelectSQL.EOF then begin
          GBIBInsertSQL.ParamByname('PMWAWARECODE').Asinteger:=OrdIBSQL.FieldByName('LWAWARECODE').Asinteger;
          GBIBInsertSQL.ParamByname('PMWAWAREANALOGCODE').Asinteger:=OrdIBSQL.FieldByName('LWAANALOG').Asinteger;
          GBIBInsertSQL.ParamByname('PMWASOURCECODE').Asinteger:=Cache.FDCA.GetSourceGBcode(OrdIBSQL.FieldByName('LWASRCCODE').AsInteger);
          GBIBInsertSQL.ParamByname('PMWAISWRONG').AsString:=OrdIBSQL.FieldByName('LWAWRONG').AsString;
          GBIBInsertSQL.ParamByname('PMWAUSERCODE').Asinteger:=OrdIBSQL.FieldByName('LWAUSERID').Asinteger;
          GBIBInsertSQL.ParamByname('PMWALASTEDITDATE').AsDateTime:=OrdIBSQL.FieldByName('LWATIME').AsDateTime;
          GBIBInsertSQL.ExecQuery;
          Inc(addeddelta);
        end else begin
          Inc(skippeddelta);
        end;
        GBIBSelectSQL.Close;
        OrdIBSQL.Next;
      end;
      GBIBInsertSQL.Transaction.Commit;
      Cache.SaveNewConstValue(pcLastAddLoadWare, UserId, OrdIBSQL.FieldByName('LWACODE').AsString);
      OrdIBSQL.Close;
      added:=added+addeddelta;
      skipped:=skipped+skippeddelta;
      prStopProcess(UserID, ThreadData.ID);
      ImpCheck.SetProcessPercent(UserId,ThreadData.ID,(added+skipped)*100/total);
//break;
    end;
*)
  except
    on E: Exception do begin
      ErrorMessage:= '������ � ��������� '+nmProc+' '+ E.Message;
      prMessageLOGS(ErrorMessage, 'import', false) ;
    end;
  end;

  if (ErrorMessage='') then lstBodyMail.Add('������ ������������� �������� ������ �������.')
  else lstBodyMail.Add('������ ������������� �������� �������� � ������� '+ErrorMessage);
  lstBodyMail.Add('������������� '+IntToStr(added)+' ��������.');
  lstBodyMail.Add('��������� '+IntToStr(skipped)+' ��������.');
  lstBodyMail.Add('����� ���������� - '+FormatDateTime('hh:nn:ss.zzz', Now-StartTime));
  Subj:= '����� 47 (������ ������� � GrossBee) �� '+FormatDateTime(cDateTimeFormatY4S, Now);
  try
    if not GetEmplTmpFilePath(UserID, PathFile, ErrorMessage) then raise EBOBError.Create(ErrorMessage);
    FName:= PathFile+fnFormRepFileName('47_', '.txt', ImpCheck.GetCheckKind(UserID, ThreadData.ID));
    lstBodyMail.SaveToFile(FName);
  finally
    SetLength(Analogs, 0);
    if ((GBIBSelectSQL<>nil) and GBIBSelectSQL.Transaction.Active) then GBIBSelectSQL.Transaction.Rollback;
    prFreeIBSQL(GBIBSelectSQL);
    prFreeIBSQL(GBIBInsertSQL);
    cntsGRB.SetFreeCnt(gbIBD);
    cntsGRB.SetFreeCnt(gbIBDw);
//    prFreeIBSQL(OrdIBSQL);
//    cntsORD.SetFreeCnt(ordIBD);
  end;
end;
//******************************************************************************
procedure prNotificationPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prNotificationPage'; // ��� ���������/�������
var EmplID, i: integer;
    s: string;
    List: TStringList;
    firm: TFirmInfo;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csNotificationPage, EmplID); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    List:= Cache.GetFirmTypesList(); // �������������
    Stream.WriteStringList(List, true);
    prFree(List);

    List:= Cache.GetFirmClassesList(); // �������������
    Stream.WriteStringList(List, true);
    prFree(List);

    List:= Cache.GetFilialList(); // �������������
    Stream.WriteStringList(List, true);

    List.Clear;
    for i:= Low(Cache.arFirmInfo) to High(Cache.arFirmInfo) do
      if Assigned(Cache.arFirmInfo[i]) then begin
        firm:= Cache.arFirmInfo[i];
        if (not firm.Arhived) then List.AddObject(firm.Name, firm);
      end;
    List.Sort;
    Stream.WriteInt(List.Count); // ����� ��� ���-�� ����
    for i:= 0 to List.Count-1 do begin
      firm:= TFirmInfo(List.Objects[i]);
      Stream.WriteInt(firm.ID);
      Stream.WriteStr(firm.UPPERSHORTNAME);
      Stream.WriteStr(firm.Name);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
end;
//******************************************************************************
procedure prAEDNotification(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAEDNotification'; // ��� ���������/�������
var ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    EmplID, NotifyID: integer;
    DateFrom, DateTo: double;
    s, NotifyText, ClientType, ClientCategory, ClientFilial, Firms: string;
    AddFlag, Auto, Moto: boolean;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBS:= nil;
  try
    EmplID:= Stream.ReadInt;
    NotifyID:= Stream.ReadInt;
    DateFrom:= Stream.ReadDouble;
    DateTo:= Stream.ReadDouble;
    NotifyText:= Stream.ReadStr;
    ClientType:= Stream.ReadStr;
    ClientCategory:= Stream.ReadStr;
    ClientFilial:= Stream.ReadStr;
    Firms:= Stream.ReadStr;
    AddFlag:= Stream.ReadBool;
    Auto:= Stream.ReadBool;
    Moto:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csAEDNotification, EmplID, 0, 'NotifyID='+IntToStr(NotifyID)); // �����������

    if ((NotifyID>0) and not (Auto or Moto)) then
      raise EBOBError.Create('���� �� ���� �� ��������� Auto ��� Moto ������ ���� �����');

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);


    if NotifyID<0 then begin
      s:= 'WHERE NOCLNOTE='+IntToStr(-NotifyID);
      OrdIBS.SQL.Text:= 'SELECT * FROM NOTIFIEDCLIENTS '+s;
      OrdIBS.ExecQuery;
      if OrdIBS.EOF then s:= 'DELETE FROM NOTIFICATIONS '+s  // ���� ��� ������ - �������
      else s:= 'UPDATE NOTIFICATIONS SET NOTEARCHIVED="T" '+s; // ���� ���� - � �����
      OrdIBS.Close;
      OrdIBS.SQL.Text:= s;

    end else begin
      s:= ' RETURNING NOTECODE';
      if NotifyID=0 then
        s:= 'INSERT INTO NOTIFICATIONS (NOTETEXT, NOTEBEGDATE,'+
          ' NOTEENDDATE, NOTEFILIALS, NOTECLASSES, NOTETYPES, NOTEFIRMS, NOTEUSERID,'+
          ' NOTEFIRMSADDFLAG, NOTEAUTO, NOTEMOTO) VALUES (:NOTETEXT, :NOTEBEGDATE,'+
          ' :NOTEENDDATE, :NOTEFILIALS, :NOTECLASSES, :NOTETYPES, :NOTEFIRMS, '+
          IntToStr(EmplID)+', :NOTEFIRMSADDFLAG, :NOTEAUTO, :NOTEMOTO)'+s
      else
        s:= 'UPDATE NOTIFICATIONS SET NOTETEXT=:NOTETEXT,'+
          ' NOTEBEGDATE=:NOTEBEGDATE, NOTEENDDATE=:NOTEENDDATE, NOTEFILIALS=:NOTEFILIALS,'+
          ' NOTECLASSES=:NOTECLASSES, NOTETYPES=:NOTETYPES, NOTEFIRMS=:NOTEFIRMS,'+
          ' NOTEUSERID='+IntToStr(EmplID)+', NOTEFIRMSADDFLAG=:NOTEFIRMSADDFLAG,'+
          ' NOTEAUTO=:NOTEAUTO, NOTEMOTO=:NOTEMOTO WHERE NOTECODE='+IntToStr(NotifyID)+s;
      OrdIBS.SQL.Text:= s;
      OrdIBS.ParamByName('NOTETEXT').AsString:= NotifyText;
      OrdIBS.ParamByName('NOTEBEGDATE').AsDateTime:= DateFrom;
      OrdIBS.ParamByName('NOTEENDDATE').AsDateTime:= DateTo;
      OrdIBS.ParamByName('NOTEFILIALS').AsString:= ClientFilial;
      OrdIBS.ParamByName('NOTECLASSES').AsString:= ClientCategory;
      OrdIBS.ParamByName('NOTETYPES').AsString:= ClientType;
      OrdIBS.ParamByName('NOTEFIRMS').AsString:= Firms;
      OrdIBS.ParamByName('NOTEFIRMSADDFLAG').AsString:= fnIfStr(AddFlag, 'T', 'F');
      OrdIBS.ParamByName('NOTEAUTO').AsString:= fnIfStr(Auto, 'T', 'F');
      OrdIBS.ParamByName('NOTEMOTO').AsString:= fnIfStr(Moto, 'T', 'F');
      OrdIBS.Prepare;
    end;
    OrdIBS.ExecQuery;
    if (NotifyID=0) then NotifyID:= OrdIBS.FieldByName('NOTECODE').AsInteger;
    OrdIBS.Transaction.Commit;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(NotifyID);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(ordIBD);
end;
//******************************************************************************
procedure prShowNotification(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowNotification'; // ��� ���������/�������
var EmplID, i, NotifyCode: integer;
    s: string;
    List: TStringList;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    firms: tai;
    firm: TFirmInfo;
begin
  Stream.Position:= 0;
//  ordIBD:= nil;
  OrdIBS:= nil;
  List:= nil;
  SetLength(firms, 0);
  try
    EmplID:= Stream.ReadInt;
    NotifyCode:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csShowNotificationWA, EmplID, 0, 'NotifyCode='+IntToStr(NotifyCode)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    ordIBD:= CntsOrd.GetFreeCnt;
    try
      OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);

      Stream.Clear;
      Stream.Position:= 0;
      Stream.WriteInt(aeSuccess);

      OrdIBS.SQL.Text:='SELECT * FROM NOTIFICATIONS WHERE NOTEARCHIVED="F" and NOTECODE='+IntToStr(NotifyCode);
      OrdIBS.ExecQuery;
      if OrdIBS.EOF then raise EBOBError.Create('�� ������� ����������� � ����� '+IntToStr(NotifyCode));

      Stream.WriteDouble(OrdIBS.FieldByName('NOTEBEGDATE').AsDateTime);
      Stream.WriteDouble(OrdIBS.FieldByName('NOTEENDDATE').AsDateTime);
      Stream.WriteStr(OrdIBS.FieldByName('NOTETEXT').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('NOTETYPES').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('NOTECLASSES').AsString);
      Stream.WriteStr(OrdIBS.FieldByName('NOTEFILIALS').AsString);
      Stream.WriteBool(OrdIBS.FieldByName('NOTEFIRMSADDFLAG').AsString='T');
      Stream.WriteBool(OrdIBS.FieldByName('NOTEAUTO').AsString='T');
      Stream.WriteBool(OrdIBS.FieldByName('NOTEMOTO').AsString='T');

      firms:= fnArrOfCodesFromString(OrdIBS.FieldByName('NOTEFIRMS').AsString);
    finally
      prFreeIBSQL(OrdIBS);
      cntsORD.SetFreeCnt(ordIBD);
    end;

    List:= TStringList.Create;
    for i:= 0 to High(firms) do begin
      if not Cache.FirmExist(firms[i]) then continue;
      firm:= Cache.arFirmInfo[firms[i]];
      if firm.Arhived then continue;
      List.AddObject(firm.Name, firm);
    end;
    List.Sort;
    Stream.WriteInt(List.Count);
    for i:= 0 to List.Count-1 do begin
      firm:= TFirmInfo(List.Objects[i]);
      Stream.WriteInt(firm.ID);
      Stream.WriteStr(firm.UPPERSHORTNAME+'||'+List[i]);
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
  SetLength(firms, 0);
end;
//======================================= �������/������ ���������� �/� (Webarm)
procedure prCheckContracts(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCheckContracts'; // ��� ���������/�������
var EmplID, ForFirmID, ContIdAsk, ContIdGet: integer;
    Contract: TContract;
    s: string;
    firma: TFirmInfo;
    fl: Boolean;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContIdAsk:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csCheckContracts, EmplID, 0, 'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'ContID='+IntToStr(ContIdAsk)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolOPRSK)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.FirmExist(ForFirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));

    Cache.TestFirms(ForFirmID, True, True, False);
    firma:= Cache.arFirmInfo[ForFirmID];

    if (ContIdAsk>0) and not firma.CheckContract(ContIdAsk) then
      raise EBOBError.Create(MessText(mtkNotFoundCont, IntToStr(ContIdAsk)));

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    ContIdGet:= ContIdAsk;
    Contract:= firma.GetContract(ContIdGet);

    if ((firma.FirmContracts.Count>1) and (ContIdAsk=0)) then begin
      Stream.WriteInt(0);
      Stream.WriteInt(firma.FirmContracts.Count);
    end else begin
      Stream.WriteInt(ContIdGet);
      Stream.WriteInt(firma.FirmContracts.Count);
      Stream.WriteStr(Contract.Name);

      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteDouble(Contract.DebtSum);
      Stream.WriteDouble(Contract.OrderSum);
      Stream.WriteDouble(Contract.PlanOutSum);
      Stream.WriteInt(Contract.CredCurrency);
      Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency, False));
      Stream.WriteStr(Cache.GetCurrName(Contract.DutyCurrency, False));
      Stream.WriteInt(Contract.PayType);
      Stream.WriteStr(Contract.LegalFirmName); // ��.����

      s:= Contract.WarnMessage;
      Stream.WriteInt(Contract.Status);
      fl:= Contract.SaleBlocked;
// Status=cstClosed, WarnMessage=""   - ������              - ��� ����
// Status=cstWorked, WarnMessage=""   - ���������           - ������� ���
// SaleBlocked=True, WarnMessage<>""  - ������������/������ - ������� ���
// SaleBlocked=False, WarnMessage<>"" - ���������/������    - ��������� ���
      Stream.WriteStr(s);
      Stream.WriteBool(fl);
      Stream.WriteDouble(Contract.RedSum);
      Stream.WriteDouble(Contract.VioletSum);
      Stream.WriteInt(Contract.CredDelay);
      if not fl then Stream.WriteInt(Contract.WhenBlocked); // ���� �������� �� �����������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=============================================== ������ ���������� �/� (Webarm)
procedure prWebarmContractList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebarmContractList'; // ��� ���������/�������
var EmplID, FirmID, i, ContId: integer;
    Contract: TContract;
    s: string;
    Firm: TFirmInfo;
    fl: Boolean;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebarmContractList, EmplID, 0, 'FirmID='+IntToStr(FirmID)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolOPRSK)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
    Cache.TestFirms(FirmID, True, True, False);

    Firm:= Cache.arFirmInfo[FirmID];
    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    Stream.WriteInt(Firm.FirmContracts.Count);
    for i:= 0 to Firm.FirmContracts.Count-1 do begin
      ContId:= Firm.FirmContracts[i];
      Contract:= Firm.GetContract(ContId);
      Stream.WriteInt(Contract.ID);
      Stream.WriteStr(Contract.Name);
      Stream.WriteInt(Contract.PayType);
      Stream.WriteStr(Contract.LegalFirmName); // ��.����
      Stream.WriteStr(Cache.GetCurrName(Contract.DutyCurrency, False));
      Stream.WriteStr(Cache.GetDprtShortName(Contract.MainStorage));
      Stream.WriteStr(Cache.GetDprtMainName(Contract.MainStorage));
      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency, False));
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
//==============================================================================
procedure prManageLogotypesPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManageLogotypesPage'; // ��� ���������/�������
var EmplID, i: integer;
    s: string;
    Brand: TBrandItem;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csManageLogotypesPage, EmplID, 0, ''); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
//    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolManageBrands)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(Cache.WareBrands.ItemsList.Count);
    for i:= 0 to Cache.WareBrands.ItemsList.Count-1 do begin
      Brand:= Cache.WareBrands.ItemsList[i];
      Stream.WriteInt(Brand.ID);
      Stream.WriteStr(Brand.Name);
      Stream.WriteStr(Brand.NameWWW);
      Stream.WriteStr(Brand.WarePrefix);
      Stream.WriteStr(Brand.adressWWW);
      Stream.WriteBool(Brand.DownLoadExclude);
if flPictNotShow then
      Stream.WriteBool(Brand.PictShowExclude);
    end; // for
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prLogotypeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLogotypeEdit'; // ��� ���������/�������
var EmplID, BrandID: integer;
    s, NameWWW, Prefix, AdressWWW: string;
    DownLoadExclude, PictShowExclude: boolean;
begin
  Stream.Position:= 0;

  try
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csLogotypeEdit, EmplID, 0, ''); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
//    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolManageBrands)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    BrandID:= Stream.ReadInt;
    NameWWW:= Stream.ReadStr;
    Prefix:= Stream.ReadStr;
    AdressWWW:= Stream.ReadStr;
    DownLoadExclude:= Stream.ReadBool;
if not flPictNotShow then PictShowExclude:= False else
    PictShowExclude:= Stream.ReadBool;

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    s:= Cache.CheckBrandAdditionData(BrandID, EmplID, NameWWW, Prefix, AdressWWW,
                                     DownLoadExclude, PictShowExclude);
    if (s<>'') then raise EBOBError.Create(s);

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prLoadOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLoadOrder'; // ��� ���������/�������
var EmplID, contID, Pos, Count, DelivType, accType, DestID, ShipTableID,
      ShipMetID, ShipTimeID, DprtID, i, Curr, Status, firmID: integer;
    s, ORDRNUM, ss, sComm, sDestName, sDestAdr, sArrive, err,
      sShipMet, sShipTime, sShipView, sAccNum, sAccDate, sCreator, sSender: string;
    ordIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    Firm: TFirmInfo;
    Contract: TContract;
    Ware: TWareInfo;
    ShipDate: double;
    Client: TClientInfo;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBS:= nil;
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
  sAccNum:= '';
  sCreator:= '';
  sSender:= '';
  sAccDate:= '';
  if flNotReserve then DelivType:= cDelivTimeTable
  else DelivType:= cDelivReserve;
  contID:= 0;
  try
    EmplID:= Stream.ReadInt;
    ORDRNUM:= UpperCase(trim(Stream.ReadStr));

    prSetThLogParams(ThreadData, csLoadOrder, EmplID, 0, ''); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolOPRSK)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(ordIBD,'OrdIBS_'+nmProc, ThreadData.ID, tpRead, true);
    Pos:= 0;
    OrdIBS.SQL.Text:= 'select ff.RDB$FIELD_LENGTH fsize'+
      ' from rdb$relation_fields f, rdb$fields ff'+
      ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE'+
      ' and f.RDB$RELATION_NAME=:table and f.RDB$FIELD_NAME=:field';
    OrdIBS.ParamByName('table').AsString:= 'ORDERSREESTR';
    OrdIBS.ParamByName('field').AsString:= 'ORDRNUM';
    OrdIBS.ExecQuery;
    if not (OrdIBS.EOF and OrdIBS.BOF) then Pos:= OrdIBS.FieldByName('fsize').AsInteger;
    OrdIBS.Close;
    if (length(ORDRNUM)>Pos) then raise EBOBError.Create('������������ ����� ������ - '+ORDRNUM);

    OrdIBS.SQL.Text:='SELECT * FROM ORDERSREESTR WHERE ORDRNUM=:ORDRNUM'+
                       ' and ORDRSTATUS>'+IntToStr(orstForming); // ������ ������������
    OrdIBS.ParamByName('ORDRNUM').AsString:= ORDRNUM;
    OrdIBS.ExecQuery;
    if OrdIBS.EOF then raise EBOBError.Create('�� ������ ����� '+ORDRNUM);

    firmID:= OrdIBS.FieldByName('ORDRFIRM').AsInteger;  // ��������� �/�
    if not Cache.FirmExist(firmID) then
      raise EBOBError.Create('�� ������ ���������� ������');
//    if not Cache.CheckEmplVisFirm(EmplID, firmID) then
//      raise EBOBError.Create('���������� ���������� ������');

    contID:= OrdIBS.FieldByName('ORDRCONTRACT').AsInteger;

    Firm:= Cache.arFirmInfo[firmID];
    Contract:= Firm.GetContract(contID);

    Status:= ordIBS.FieldByName('ORDRSTATUS').AsInteger;
    DelivType:= ordIBS.FieldByName('ORDRDELIVERYTYPE').AsInteger;
    accType:= ordIBS.FieldByName('ORDRACCOUNTINGTYPE').AsInteger;
    DprtID:= ordIBS.FieldByName('ORDRSTORAGE').AsInteger;
    Curr:= OrdIBS.FieldByName('ORDRCURRENCY').AsInteger;
    sComm:= OrdIBS.FieldByName('ORDRSTORAGECOMMENT').AsString;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(OrdIBS.FieldByName('ORDRNUM').AsString);
    Stream.WriteStr(FormatDateTime(cDateFormatY4, OrdIBS.FieldByName('ORDRDATE').AsDate));
    Stream.WriteStr(arOrderStatusNames[Status]);

    if (ordIBS.FieldByName('ORDRGBACCCODE').AsInteger>0) then begin
      sAccNum:= ordIBS.FieldByName('ORDRGBACCNUMBER').AsString;
      sAccDate:= FormatDateTime(cDateTimeFormatY2N, ordIBS.FieldByName('ORDRGBACCTIME').AsDateTime);
    end;
    i:= ordIBS.FieldByName('ORDRCREATORPERSON').AsInteger;
    if Cache.ClientExist(i) then begin
      Client:= Cache.arClientInfo[i];
      sCreator:= fnIfStr(Client.Name='', '', Client.Name)+
                 fnIfStr(Client.Post='', '', fnIfStr(Client.Name='', '', ', ')+Client.Post)+
                 fnIfStr(Client.Phone='', '', ' ('+Client.Phone+')');
    end;
    pos:= ordIBS.FieldByName('ORDRTOPROCESSPERSON').AsInteger;
    if (pos=i) then sSender:= sCreator
    else if Cache.ClientExist(pos) then begin  // ���� �������� ������
      Client:= Cache.arClientInfo[pos];
      sSender:= fnIfStr(Client.Name='', '', Client.Name)+
                fnIfStr(Client.Post='', '', fnIfStr(Client.Name='', '', ', ')+Client.Post)+
                fnIfStr(Client.Phone='', '', ' ('+Client.Phone+')');
    end;

    Stream.WriteStr(sAccNum);  // � �����
    Stream.WriteStr(sAccDate); // ���� � ����� ������������ �����
    Stream.WriteStr(sCreator); // ������ �����
    Stream.WriteStr(sSender);  // �������� �����
    Stream.WriteStr(Firm.Name+' ('+Firm.UPPERSHORTNAME+')');
    Stream.WriteStr(fnIfStr(accType=0, '���', '�/���'));

    ss:= '';
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

    else if not flNotReserve then
        DelivType:= cDelivReserve; //--------------------------------- ������
    end; // case
    OrdIBS.Close;

    err:= fnGetShipParamsView(contID, DprtID, DestID, ShipTableID, ShipDate,
          DelivType, ShipMetID, ShipTimeID, sDestName, sDestAdr, sArrive,
          sShipMet, sShipTime, sShipView, True);
    if (err='') then ss:= sShipView;

    if (ss='') then case DelivType of
      cDelivTimeTable: ss:= '��������';
      cDelivReserve  : ss:= '������';
      cDelivSelfGet  : ss:= '���������';
    end;
    Stream.WriteStr(ss);
    Stream.WriteStr(sComm);
    Stream.WriteStr(Cache.GetCurrName(Curr, False));
    Stream.WriteStr(Contract.Name);

    Pos:= Stream.Position;
    Stream.WriteInt(0); // �������� ��� ���-��
    Count:= 0;

    OrdIBS.SQL.Text:= 'SELECT * FROM ORDERSLINES WHERE ORDRLNORDER='+OrdIBS.FieldByName('ORDRCODE').AsString+'';
    OrdIBS.ExecQuery;
    while not OrdIBS.EOF do begin
      Ware:= Cache.GetWare(OrdIBS.FieldByName('ORDRLNWARE').AsInteger);
      Stream.WriteStr(Ware.Name);
      Stream.WriteStr(Ware.MeasName);
      Stream.WriteDouble(OrdIBS.FieldByName('ORDRLNCLIENTQTY').AsFloat);
      Stream.WriteDouble(OrdIBS.FieldByName('ORDRLNPRICE').AsFloat);
      Inc(Count);
      TestCssStopException;
      OrdIBS.Next;
    end;
    Stream.Position:= Pos;
    Stream.WriteInt(Count);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(ordIBD);
end;
//------------------------------------------------------------ vc

(*//=================================================== ��������� ���������� �����
procedure prTestFileExt(pFileExt: string; RepKind: integer);
var rightExt: String;
    flWrongExt: Boolean;
begin
  case RepKind of
    13, 14, 36, 53: begin
        rightExt:= '.csv';
        flWrongExt:= pFileExt<>rightExt;
      end;
    15: begin
        rightExt:= '.xls';
        flWrongExt:= pFileExt<>rightExt;
      end;
    25, 34, 39: begin
        rightExt:= '.xls ��� .xlsx';
        flWrongExt:= not ((pFileExt='.xls') or (pFileExt='.xlsx'));
      end;
    24:                                // ����������������� ���
      case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
        1: begin // �������� �������������� �������� ����-������� TecDoc �� ����� Excel
            rightExt:= '.xls ��� .xlsx';
            flWrongExt:= not ((pFileExt='.xls') or (pFileExt='.xlsx'));
          end;
{        2: begin // ����� ����� ����� ���� �� TDT
            rightExt:= '.xls ��� .xlsx';
            flWrongExt:= not ((pFileExt='.xls') or (pFileExt='.xlsx'));
          end;   }
        else begin // def - �������� �������� ������, ���������, �������, ������ � �� ������� �� TDT
          rightExt:= '.xls';  
          flWrongExt:= pFileExt<>rightExt;
        end;
      end;
    else begin
      rightExt:= '';
      flWrongExt:= True;
    end;
  end;
  if flWrongExt then
    raise EBOBError.Create('�������� ������ ����� - '+pFileExt+', ����� '+rightExt);
end; *)
//=================================================== ��������� ��� ����� ������
procedure prFormRepFileName(pFilePath: string; var fname: string; RepKind: integer; flSet: Boolean=False);
var pFileExt{, MidName}: String;
begin
  if flSet then begin // ������ �� ����� � ����
    fname:= pFilePath+fnFormRepFileName(IntToStr(RepKind), fname, constOpImport);

  end else begin // ����� � ����������� ����������
    pFileExt:= '';
    case RepKind of
      13, 14, 36, 53: pFileExt:= '.csv';
      15, 25, 34, 39, 40, 67, 68: pFileExt:= '.xml';
      24:  // ����������������� ���
        case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
          4: pFileExt:= '.csv';
             // def - �������� �������� ������, ���������, �������, ������ � �� ������� �� TDT
          else
          pFileExt:= '.txt';
        end;
    end;
    fname:= pFilePath+fnFormRepFileName(IntToStr(RepKind), pFileExt, constOpExport);
  end;
  if FileExists(fname) and not SysUtils.DeleteFile(fname) then
    raise EBOBError.Create(MessText(mtkNotDelPrevFile));
end;
//=================================================== ��������� ������ � �������
procedure prFormRepMailParams(var Subj, ContentType: string;
          var BodyMail: TStringList; RepKind: integer; flSet: Boolean=False);
var sYearFrom: String;
  //--------------------------------
  function GetRepNameTD(s: string; SysID: Integer): string;
  var s1, s2, s3: String;
  begin
    if flSet then begin
      s1:= '�������� ';
      s3:= ' ��';
    end else begin
      s1:= '�������� ';
      s3:= ' ��';
    end;
    case SysID of
      0: s2:= '';
      constIsAuto: s2:= ' ����.����';
      constIsCV  : s2:= ' ����.����';
      constIsAx  : s2:= ' ����';
    end;
    Result:= '����� � '+s1+s+s2+s3+' TecDoc';
  end;
  //--------------------------------
begin
  if not flSet then begin
    sYearFrom:= GetYearFromLoadModels;
    if (sYearFrom<>'') then sYearFrom:=' (�� '+sYearFrom+'�.)';
  end else sYearFrom:= '';
  case RepKind of
//    13: Subj:= GetRepNameTD('��������������');
//    14: Subj:= GetRepNameTD('��������� �����');
//    15: Subj:= GetRepNameTD('�������');
    25: Subj:= GetRepNameTD('������.+�.�.+���.'+sYearFrom, constIsAuto);
    34: Subj:= GetRepNameTD('�����', 0);
    36: Subj:= '����� �� ��������� TecDoc ��� ����-����� �������';
    39: Subj:= '������ ����-������� TecDoc';
    40: Subj:= '����� � �������� �������� ������� � ��������� TecDoc';
    53: Subj:= '����� � ������������ �/�';
    67: Subj:= GetRepNameTD('������.+�.�.+���.'+sYearFrom, constIsCV);
    68: Subj:= GetRepNameTD('������.+�.�.+���.'+sYearFrom, constIsAx);
    24:  // ����������������� ���
      if flSet then begin
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'set24', 0) of
//          else
          Subj:= '����� �� �������� �������';
//        end;
      end else begin
        case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
          4: Subj:= '����� � ������� �������������';
          else
          Subj:= '����� � �������� ��������';
        end;
      end;
  end;
  if not Assigned(BodyMail) then BodyMail:= TStringList.Create;
  BodyMail.Add(Subj+' �� '+FormatDateTime(cDateTimeFormatY2S, Now()));
end;
//======================================== ����� - ����� ����� ������ ���� � TDT
procedure prGetAutoDataFromTDT(ReportKind, UserID: integer; var BodyMail: TStringList;
          var pFileName, Subj, ContentType: string; ThreadData: TThreadData=nil; filter_data: String='');
const nmProc = 'prGetAutoDataFromTDT'; // ��� ���������/�������
var pFilePath, errmess: String;
    lst: TStringList;
begin
  lst:= nil;
  pFilePath:= '';
  errmess:= '';
  if not GetEmplTmpFilePath(UserID, pFilePath, errmess) then raise EBOBError.Create(errmess);
//  if CheckNotValidModelManage(UserID, constIsAuto, errmess) then raise EBOBError.Create(errmess);
  try
    prFormRepFileName(pFilePath, pFileName, ReportKind, False); // ��������� ��� ����� ������
    case ReportKind of
      25: begin // 25-stamp - ����� ����� ��������������, �.�., ������� �������� ���� �� TDT
        lst:= fnGetNewAutoMfMlModFromTDT(UserID, ThreadData);
        SaveListToFile(lst, pFileName);          // xml
        ContentType:= XMLContentType;
      end;
      34: begin // 34-stamp - ����� ����� ����� ���� �� TDT (�������� + ��������� + ���)
          lst:= fnGetNewTreeNodesFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      36: begin // 36-stamp - ����� ��������� TDT ��� ����-����� �������
          prGetArticlesINFOgrFromTDT(UserID, pFileName, ThreadData);
          ContentType:= CSVFileContentType;
        end;
      39: begin // 39-stamp - ����� �� ����-������� TecDoc
          lst:= fnGetInfoTextsForTranslate(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      40: begin  // 40-stamp - ����� � �������� �������� ������� � ���������
          lst:= fnGetCheckWareTDTArticles(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      53: begin // 53-stamp - ���������� �/� �������
          prGetFirmClones(UserID, pFileName, ThreadData);
          ContentType:= CSVFileContentType;
        end;
      67: begin // 67-stamp - ����� ����� ��������������, �.�., ������� ���������� �� TDT
          lst:= fnGetNewCVMfMlModFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      68: begin // 68-stamp - ����� ����� ��������������, �.�., ������� ���� �� TDT
          lst:= fnGetNewAxMfMlModFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;

      24: begin // // 24-stamp - �������� �������� ������, ���������, �������, ������ � �� ������� �� TDT
          case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
            3: begin // ����������� ���������� � db_ORD
//                raise EBOBError.Create('����� '+IntToStr(ReportKind)+'(3) ����������');
                lst:= SetClientContractsToORD(UserID, ThreadData);
                SaveListToFile(lst, pFileName);          // txt
                ContentType:= FileContentType;
              end;
            4: begin // �������� ����.������������� � Grossbee
//                raise EBOBError.Create('����� '+IntToStr(ReportKind)+'(4) ����������');
                CheckGeneralPersonsForGB(UserID, pFileName, ThreadData);
                ContentType:= CSVFileContentType;
              end;
            5: begin // �������� ����.������������� � Grossbee + �������� ���������� ������� � �������� ��������
//                raise EBOBError.Create('����� '+IntToStr(ReportKind)+'(5) ����������');
                CheckGeneralPersonsForGB(UserID, pFileName, ThreadData, True);
                ContentType:= CSVFileContentType;
              end;
            else begin // def 24-stamp - �������� �������� ������, ���������, �������, ������ � �� ������� �� TDT
              if (Cache.LongProcessFlag=cdlpLoadData) then
                raise EBOBError.Create('�������� ��� ��������');
              if not SetLongProcessFlag(cdlpLoadData) then
                raise EBOBError.Create('�� ���� ��������� �������� - ���� �������: '+cdlpNames[Cache.LongProcessFlag]);
              try
                lst:= AddLoadWaresInfoFromTDT(UserID, ThreadData, filter_data);
                SaveListToFile(lst, pFileName);          // txt
                ContentType:= FileContentType;
              finally
                SetNotLongProcessFlag(cdlpLoadData);
              end;
            end;
          end;
        end;
      else raise EBOBError.Create('����������� ��� ������ - '+IntToStr(ReportKind));
    end;
    prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind); // ��������� ������ � �������
  finally
    prFree(lst);
  end;
end;
//====================================== �������� / ��������� ������ ���� �� TDT
procedure prSetAutoDataFromTDT(ReportKind, UserID: integer; var BodyMail: TStringList;
                               var pFileName, Subj, ContentType: string; ThreadData: TThreadData=nil);
const nmProc = 'prSetAutoDataFromTDT'; // ��� ���������/�������
var errmess, pFilePath, pFileName1: String;
    lst: TStringList;
begin
  lst:= nil;
  pFilePath:= '';
  if not FileExists(pFileName) then raise EBOBError.Create('�� ������ ���� ��������.');
  if not GetEmplTmpFilePath(UserID, pFilePath, errmess) then raise EBOBError.Create(errmess);
//  if CheckNotValidModelManage(UserID, constIsAuto, errmess) then raise EBOBError.Create(errmess);
  try
    case ReportKind of
      25: begin // 25-imp - �������� ����� ��������������, �.�., ������� ���� �� TDT
          pFileName1:= pFileName;                                    // ���������� ��� ��������� �����
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // ��������� ��� ����� ������
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // �������� �������� ���� � �����
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewAutoMfMlModFromTDT(UserID, pFileName, BodyMail, ThreadData);   // ������������ ���� � � ���� �� ����� �����
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // ��������� ������ � �������
        end;
      34: begin // 34-imp - ��������  / ������������� ����� ���� �� Excel
          pFileName1:= pFileName;                                    // ���������� ��� ��������� �����
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // ��������� ��� ����� ������
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // �������� �������� ���� � �����
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewTreeNodesFromTDT(UserID, pFileName, BodyMail, ThreadData);   // ������������ ���� � � ���� �� ����� �����
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // ��������� ������ � �������
        end;
      39: begin // 39-imp - �������� �������������� �������� ����-������� TecDoc �� ����� Excel
          pFileName1:= pFileName;                                    // ���������� ��� ��������� �����
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // ��������� ��� ����� ������
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // �������� �������� ���� � �����
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetAlternativeInfoTexts(UserID, pFileName, ThreadData);  // ������������ ���� � � ���� �� ����� �����
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // ��������� ������ � �������
        end;
      67: begin // 67-imp - �������� ����� ��������������, �.�., ������� ���������� �� TDT
          pFileName1:= pFileName;                                    // ���������� ��� ��������� �����
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // ��������� ��� ����� ������
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // �������� �������� ���� � �����
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewCVMfMlModFromTDT(UserID, pFileName, BodyMail, ThreadData);   // ������������ ���� � � ���� �� ����� �����
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // ��������� ������ � �������
        end;
      68: begin // 68-imp - �������� ����� ��������������, �.�., ������� ���� �� TDT
          pFileName1:= pFileName;                                    // ���������� ��� ��������� �����
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // ��������� ��� ����� ������
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // �������� �������� ���� � �����
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewAxMfMlModFromTDT(UserID, pFileName, BodyMail, ThreadData);   // ������������ ���� � � ���� �� ����� �����
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // ��������� ������ � �������
        end;

      24: begin // 24-imp - �������� ������� � �� ������ �� ORD
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'set24', 0) of
//          else begin //
            pFileName1:= pFileName;                                    // ���������� ��� ��������� �����
            prFormRepFileName(pFilePath, pFileName, ReportKind, True); // ��������� ��� ����� ������
            CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // �������� �������� ���� � �����
            if FileExists(pFileName) then DeleteFile(pFileName1);
            prDeleteAutoModels(UserID, pFileName, ThreadData);         // ������������ ���� � � ���� �� ����� �����
            ContentType:= FileContentType;                     // ???
            prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // ��������� ������ � �������
//          end;
//        end;
      end;
      36, 40, 53:  // 36-imp, 40-imp, 53-imp - ���
        raise EBOBError.Create('������ ('+IntToStr(ReportKind)+') �� ������������');
    else raise EBOBError.Create('����������� ��� ������� - '+IntToStr(ReportKind));
    end;
  finally
    prFree(lst);
  end;
end;

//******************************************************************************

//================ ��������� ����� ���������� �� �������� "�����������" (WebArm)
procedure prCheckEmplRights(cek: TCheckEmplKind; emplID: Integer;
                            var empl: TEmplInfoItem; var FiltCode: Integer);
//   TCheckEmplKind = (cekFirms, cekFirmUsers, cekFirmDocs);
var errmess: String;
    flManageSprav, flUiK, flService, flSuper, flReg: Boolean;
begin
  if CheckNotValidUser(EmplId, isWe, errmess) then raise EBOBError.Create(errmess);
  empl:= Cache.arEmplInfo[EmplId];

  flManageSprav:= empl.UserRoleExists(rolManageSprav);
  flUiK:= empl.UserRoleExists(rolUiK);
  flService:= empl.UserRoleExists(rolCustomerService);
  flSuper:= empl.UserRoleExists(rolSuperRegional);
  flReg:= empl.UserRoleExists(rolRegional);

  if not (flManageSprav or flUiK or flService or flReg or flSuper) then
    raise EBOBError.Create(MessText(mtkNotRightExists));

  FiltCode:= 0;
  if (cek=cekFirms) then begin
    if (flManageSprav or flUiK) then FiltCode:= 0
    else if flSuper and (empl.FaccRegion>0) then FiltCode:= -empl.FaccRegion
    else if flReg then FiltCode:= EmplID;
  end;
end;
//=================================== ��������� ����� ���������� �� �/� (WebArm)
procedure prCheckEmplRights(cek: TCheckEmplKind; emplID, ForFirmID: Integer;
                            var empl: TEmplInfoItem; var firm: TFirmInfo);
var errmess: String;
    flManageSprav, flUiK, flService, flSuper, flReg: Boolean;
begin
  if CheckNotValidUser(EmplId, isWe, errmess) then raise EBOBError.Create(errmess);
  empl:= Cache.arEmplInfo[EmplId];

  flManageSprav:= empl.UserRoleExists(rolManageSprav);
  flUiK:= empl.UserRoleExists(rolUiK);
  flService:= empl.UserRoleExists(rolCustomerService);
  flSuper:= empl.UserRoleExists(rolSuperRegional);     // ���
  flReg:= empl.UserRoleExists(rolRegional);            // �������� �/�

  Cache.TestFirms(ForFirmID, True, True, False); // ��������� �����
  if not Cache.FirmExist(ForFirmID) then
    raise EBOBError.Create(MessText(mtkNotFirmExists));
  firm:= Cache.arFirmInfo[ForFirmID];

  if not (flManageSprav or flUiK or flService
    or (flSuper and (empl.FaccRegion>0) and firm.CheckFirmRegion(empl.FaccRegion))
    or (flReg and firm.CheckFirmManager(emplID))) then
    raise EBOBError.Create(MessText(mtkNotRightExists));

//  if (cek=cekFirmUsers) then begin  end;
end;

//================================================ ������ ������������ ���������
procedure prWebArmGetRegionalFirms(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetRegionalFirms'; // ��� ���������/�������
var EmplId, FirmID, i, j: integer;
    Codes: Tai;
    Template: string;
    empl: TEmplInfoItem;
    firm: TFirmInfo;
begin
  Stream.Position:= 0;
  SetLength(Codes, 0);
  try
    EmplId:= Stream.ReadInt;          // ��� ��������� (0-���)
    Template:= trim(Stream.ReadStr);  // ������ ������������ �����������

    prSetThLogParams(ThreadData, csWebArmGetRegionalFirms, EmplId, 0, 'Template='+Template); // �����������

    prCheckEmplRights(cekFirms, emplID, empl, j); // ��������� ����� ������������

    Codes:= Cache.GetRegFirmCodes(j, Template); // ������ ����� ���������� ������������
    j:= length(Codes);
    if (j<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(j);
    for i:= 0 to j-1 do begin
      FirmID:= Codes[i];
      firm:= Cache.arFirmInfo[FirmID];

      Stream.WriteInt(FirmID);
      Stream.WriteStr(firm.UPPERSHORTNAME);
      Stream.WriteStr(firm.Name);
      Stream.WriteStr(firm.NUMPREFIX);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Codes, 0);
  Stream.Position:= 0;
end;
//==================================================== ������ ������ �����������
procedure prWebArmGetFirmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmUsers'; // ��� ���������/�������
var EmplId, FirmID, i, ii, j, CliCount, pFirm, pUser, dpCount,
      posProf, posCont, ProfCount, contCount: integer;
    Users: Tai;
    prof: TCredProfile;
    flManageSprav, flBlock: Boolean;
    firm: TFirmInfo;
    empl: TEmplInfoItem;
    dp: TDestPoint;
    Contract: TContract;
    dprtName, currName, sCred: String;
    CredLimitAll, DebtAll, OverAll: Double;
begin
  Stream.Position:= 0;
  pFirm:= 0;
  pUser:= 0;
  CredLimitAll:= 0;
  DebtAll:= 0;
  OverAll:= 0;
  try
    EmplId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmGetFirmUsers, EmplId, 0, 'FirmID='+IntToStr(FirmID)); // �����������

    prCheckEmplRights(cekFirmUsers, emplID, FirmID, empl, firm); // ��������� ����� ������������

    flManageSprav:= empl.UserRoleExists(rolManageSprav);
    if (firm.SUPERVISOR>0) then pUser:= firm.SUPERVISOR else pFirm:= FirmID;
    Cache.TestClients(pUser, True, False, True, pFirm); // ��������� �������� �����.��� �����������

    SetLength(Users, Length(firm.FirmClients)); // �������� ������ �����.��� �����������
    CliCount:= 0; // ������� �����.���
    for i:= Low(firm.FirmClients) to High(firm.FirmClients) do begin
      j:= firm.FirmClients[i];
      if not Cache.ClientExist(j) then Continue;
      Users[CliCount]:= j;
      inc(CliCount);
    end;

    dpCount:= firm.FirmDestPoints.Count;
    ContCount:= firm.FirmContracts.Count;
    if (CliCount<1) and (dpCount<1) and (ContCount<1) then
      raise EBOBError.Create('��� ������ �� �����������.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

//-------------------------------------------------------------- ���������� ����
    Stream.WriteInt(CliCount);        // ���-�� ����.���
    for i:= 0 to CliCount-1 do begin
      j:= Users[i];
      Stream.WriteInt(j); // ���
      with Cache.arClientInfo[j] do begin
        Stream.WriteStr(Name);  // ���
        Stream.WriteStr(Post);  // ���������
        Stream.WriteStr(Phone); // ��������
        Stream.WriteStr(Mail);
        Stream.WriteStr(Login); // �����
        Stream.WriteByte(byte(Blocked)+                       // ������� ���������������
                         2*fnIfInt(flManageSprav, 1, 0)+      // ������� ���������� ������������� (������ ������)
                         fnIfInt((firm.SUPERVISOR=j), 4, 0)); // ������� �����������
      end;
    end; // for i:= 0 to

//--------------------------------------------------------------- �������� �����
    Stream.WriteInt(dpCount);     // ���-��
    for i:= 0 to dpCount-1 do begin
      dp:= TDestPoint(firm.FirmDestPoints[i]);
      Stream.WriteStr(dp.Name);   // ��������
      Stream.WriteStr(dp.Adress); // �����
    end;

//-------------------------------------------------------------------- ���������
if flCredProfile then begin // �� ��������

    posProf:= Stream.Position;
    ProfCount:= 0;      // ������� ��������
    Stream.WriteInt(0); // ����� ��� ���-�� ��������

    for ii:= 0 to firm.FirmCredProfiles.Count-1 do begin
      prof:= TCredProfile(firm.FirmCredProfiles[ii]);
      if not Assigned(prof) then prof:= ZeroCredProfile;

      flBlock:= prof.Blocked or firm.SaleBlocked;

      posCont:= Stream.Position;
      contCount:= 0;      // ������� ���������� � �������
      Stream.WriteInt(0); // ����� ��� ���-�� ���������� � �������

      for i:= 0 to firm.FirmContracts.Count-1 do begin
        j:= firm.FirmContracts[i];
        Contract:= firm.GetContract(j);
        if (Contract.CredProfile<>prof.ID) then Continue; // ����� �� �������

        dprtName:= Cache.GetDprtMainName(Contract.MainStorage);
        currName:= Cache.GetCurrName(prof.ProfCredCurrency, True);
  // ������� "����.�������": ���� <����� �������> = 0 - "����������",
  // ����� - <����� �������> <������ �������> / <��������> ��.
        if (prof.ProfCredLimit>0) then sCred:= FloatToStr(prof.ProfCredLimit)+
          ' '+currName+' / '+IntToStr(prof.ProfCredDelay)+' ��.'
        else sCred:= '����������';

        Stream.WriteStr(Contract.Name);          // � ���������
        Stream.WriteStr(Contract.LegalFirmName); // ��.����
        Stream.WriteInt(Contract.PayType);       // ����� ������
        Stream.WriteStr(dprtName);               // ����� ��������

//------------------------------------------------- ������������ ������ �������
        Stream.WriteStr(sCred);                 // ����.�������

        Stream.WriteDouble(prof.ProfDebtAll);   // ����� ���� - ��������� ������ !!!
//-------------------------------------------------

        Stream.WriteDouble(Contract.DebtSum);     // ����/���������
        Stream.WriteDouble(Contract.OrderSum);    // ������

//        if flBlock then Stream.WriteInt(cstBlocked) else // ������ ����������  ???
        Stream.WriteInt(Contract.Status);      // ������ ���������

        Stream.WriteDouble(Contract.RedSum);      // ����������
        Stream.WriteDouble(Contract.VioletSum);   // �������� ����
        Stream.WriteStr(Contract.ContComments);   // �����������
        Stream.WriteDouble(Contract.ContBegDate); // ���� ������
        Stream.WriteDouble(Contract.ContEndDate); // ���� ���������

        //-------------------------------------- �������� ����� ���� � ���������
        if (Contract.DebtSum>0) then DebtAll:= DebtAll+Contract.DebtSum
        else if (Contract.DebtSum<0) then OverAll:= OverAll+Contract.DebtSum;
        Inc(contCount);
      end; // for i:= 0 to firm.FirmContracts.Count-1

      CredLimitAll:= CredLimitAll+prof.ProfCredLimit; //-- �������� ����� ������

      Stream.Position:= posCont; // ������������ �� ������� �������� ����������
      if (contCount>0) then begin // ���� ��������� �� �������
        Stream.WriteInt(contCount);    // ����� ���-�� ����������
        Stream.Position:= Stream.Size; // ���� � ����� Stream
        Inc(ProfCount);
      end;
    end; // for ii:= 0 to firm.FirmCredProfiles.Count-1

    if (ProfCount>0) then begin
      Stream.Position:= posProf;
      Stream.WriteInt(ProfCount); // ���-�� ��������
      Stream.Position:= Stream.Size; // ���� � ����� Stream
    end;

end // if flCredProfile
else begin // ������ �����

    Stream.WriteInt(ContCount);     // ���-��
    for i:= 0 to ContCount-1 do begin
      j:= firm.FirmContracts[i];
      Contract:= firm.GetContract(j);
      dprtName:= Cache.GetDprtMainName(Contract.MainStorage);
// ������� "����.�������": ���� <����� �������> = 0 - "����������",
// ����� - <����� �������> <������ �������> / <��������> ��.
      currName:= Cache.GetCurrName(Contract.CredCurrency, True);
      if (Contract.CredLimit>0) then
        sCred:= FloatToStr(Contract.CredLimit)+' '+currName+' / '+IntToStr(Contract.CredDelay)+' ��.'
      else sCred:= '����������';

      Stream.WriteStr(Contract.Name);           // � ���������
      Stream.WriteStr(Contract.LegalFirmName);  // ��.����
      Stream.WriteInt(Contract.PayType);        // ����� ������
      Stream.WriteStr(dprtName);                // ����� ��������
      Stream.WriteStr(sCred);                   // ����.�������
      Stream.WriteDouble(Contract.DebtSum);     // ����/���������
      Stream.WriteDouble(Contract.OrderSum);    // ������
      Stream.WriteInt(Contract.Status);         // ������
      Stream.WriteDouble(Contract.RedSum);      // ����������
      Stream.WriteDouble(Contract.VioletSum);   // �������� ����
      Stream.WriteStr(Contract.ContComments);   // �����������
      Stream.WriteDouble(Contract.ContBegDate); // ���� ������
      Stream.WriteDouble(Contract.ContEndDate); // ���� ���������
      //-------------------------------------------------------- ��������� �����
      if (Contract.Status<>cstClosed) then
        CredLimitAll:= CredLimitAll+Contract.CredLimit;
      if (Contract.DebtSum>0) then DebtAll:= DebtAll+Contract.DebtSum
      else if (Contract.DebtSum<0) then OverAll:= OverAll+Contract.DebtSum;
    end; // for i:= 0 to ContCount-1
end; // if not flCredProfile

    Stream.WriteDouble(CredLimitAll);  // ����� ����� ������� �� ���� ����������� ����������
    Stream.WriteDouble(DebtAll);       // ����� ����� ����� �� ���� ����������
    Stream.WriteDouble(OverAll);       // ����� ����� ��������� �� ���� ����������

if flCredProfile then begin // �� ��������
    //------------------------------------------------------------ ������ ������
    sCred:= '��: ';
    for i:= 0 to firm.FirmDiscModels.Count-1 do begin
      j:= TTwoCodes(firm.FirmDiscModels[i]).ID2; // ��� �������
      dprtName:= Cache.DiscountModels[j].Name;
      if (i>0) then dprtName:= ' / '+dprtName;
      sCred:= sCred+dprtName;
    end;
                                                        // ��������� ������ !!!
    Stream.WriteStr(sCred);   // ������ ������� ������ (����� ��������� ����� ��������)

end; // if flCredProfile

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Users, 0);
  Stream.Position:= 0;
end;
//============================================ �������� ������ ������ �/� ��� ��
procedure prWebArmGetFirmAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmAccountList'; // ��� ���������/�������
var EmplID, j, sPos, Curr, ForFirmID, sid: integer;
    sNum, sDays: string;
    GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    firm: TFirmInfo;
    empl: TEmplInfoItem;
    sum: Double;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  try
    EmplID   := Stream.ReadInt;    // ��� ����������
    ForFirmID:= Stream.ReadInt;    // ��� �/�

    prSetThLogParams(ThreadData, csLoadFirmAccountList, EmplID, 0,
                     'ForFirmID='+IntToStr(ForFirmID)); // �����������

    prCheckEmplRights(cekFirmDocs, EmplID, ForFirmID, empl, firm); // ��������� ����� ������������

    sDays:= Cache.GetConstItem(pcWebarmDocumsLimit).StrValue;

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select PInvCode, PInvNumber, PInvDate, PInvSumm,'+
        ' PInvCrncCode, PINVCONTRACTCODE, INVCCODE, INVCNUMBER, INVCSUMM,'+
        ' INVCCRNCCODE, gn.rNum contnumber from PayInvoiceReestr'+
        ' left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' left join CONTRACT c on c.contcode=PINVCONTRACTCODE'+
        ' left join Vlad_CSS_GetFullContNum(c.contnumber, c.contnkeyyear, c.contpaytype) gn on 1=1'+
        ' WHERE PInvRecipientCode='+IntToStr(ForFirmID)+
        '   and PInvDate>=("today"-'+sDays+')'+ // �� ... ����
        '   and PINVANNULKEY="F"'+ // ������������� �� ����������
//        '   and PInvLocked="F"'+   // ������������ �� ����������
        ' ORDER BY PInvDate, PInvNumber';

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      sPos:= Stream.Position;
      Stream.WriteInt(0); // ����� ��� ���-�� ������
      j:= 0;
      GBIBS.ExecQuery;
      while not GBIBS.EOF do begin
        sid:= GBIBS.FieldByName('INVCCODE').AsInteger;
        if (sid>0) then begin             // ���� ���������
          sNum:= GBIBS.FieldByName('INVCNUMBER').AsString;
          sum:= GBIBS.FieldByName('INVCSUMM').AsFloat;
          Curr:= GBIBS.FieldByName('INVCCRNCCODE').AsInteger;
        end else begin
          sNum:= '';
          sum:= GBIBS.FieldByName('PInvSumm').AsFloat;
          Curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
        end;
                                                                   // ���� �����
        Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('PInvDate').AsDateTime));
        Stream.WriteInt(GBIBS.FieldByName('PInvCode').AsInteger);  // ��� �����
        Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString); // ����� �����
        Stream.WriteInt(sID);                                      // ��� ���������
        Stream.WriteStr(sNum);                                     // ����� ���������
        Stream.WriteDouble(sum);                                   // �����
        Stream.WriteStr(Cache.GetCurrName(Curr, False));           // ������
        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString); // ����� ���������

        cntsGRB.TestSuspendException;
        GBIBS.Next;
        Inc(j);
      end;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
    if (j<1) then
      raise EBOBError.Create('�� ������� ��������� �� '+sDays+' ����');

    Stream.Position:= sPos;
    Stream.WriteInt(j); // �������� ���-��

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//================================================================= ����� ������
procedure prWebArmResetUserPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmResetUserPassword'; // ��� ���������/�������
var OrdIBD: TIBDatabase;
    OrdIBS: TIBSQL;
    EmplId, UserId, FirmID: integer;
    newpass, UserCode, errmess: string;
    Client: TClientInfo;
    empl: TEmplInfoItem;
//    firm: TFirmInfo;
begin
  OrdIBS:= nil;
  OrdIBD:= nil;
  Stream.Position:= 0;
  try
    EmplId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    UserCode:= Stream.ReadStr;
    UserId:= StrToIntDef(UserCode, 0);

    prSetThLogParams(ThreadData, csWebArmResetUserPassword, EmplId, 0,
       'FirmID='+IntToStr(FirmID)+#13#10'UserId='+UserCode); // �����������

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    empl:= Cache.arEmplInfo[EmplId];         // ��������� ����� ������������
    if not (empl.UserRoleExists(rolRegional) and                                  // ???
      Cache.arFirmInfo[FirmId].CheckFirmManager(emplID)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Client:= Cache.arClientInfo[UserId];
    if (Client.Login='') then raise EBOBError.Create(MessText(mtkNotClientExist));

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);
    OrdIBS.SQL.Text:= 'select rPassword, rErrText from SetUserPassword('+UserCode+', :p, 1, 0)';
    OrdIBS.ParamByName('p').AsString:= '';
    OrdIBS.ExecQuery;
    if (OrdIBS.Bof and OrdIBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
    if OrdIBS.FieldByName('rErrText').AsString<>'' then
      raise EBOBError.Create(OrdIBS.FieldByName('rErrText').AsString);

    newpass:= OrdIBS.FieldByName('rPassword').AsString;
    OrdIBS.Transaction.Commit;
    OrdIBS.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(newpass);
    Client.Password:= newpass;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
  Stream.Position:= 0;
end;
//============================================== ��������� �������� ������������
procedure prWebArmSetFirmMainUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmSetFirmMainUser'; // ��� ���������/�������
var IBS: TIBSQL;
    IBD: TIBDatabase;
    EmplId, UserId, FirmID: integer;
    newpass, UserCode, UserLogin, s, CliMail: string;
    flNewUser: boolean;
    Client: TClientInfo;
    firma: TFirmInfo;
    empl: TEmplInfoItem;
begin
  newpass:= '';
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try
    EmplId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    UserCode:= Stream.ReadStr;
    UserLogin:= Stream.ReadStr;
    UserId:= StrToIntDef(UserCode, 0);

    prSetThLogParams(ThreadData, csWebArmSetFirmMainUser, EmplId, 0, 'FirmID='+IntToStr(FirmID)+
      #13#10'UserId='+UserCode+#13#10'UserLogin='+UserLogin); // �����������

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    empl:= Cache.arEmplInfo[EmplId];             // ��������� ����� ������������
    if not (empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolCustomerService)) then  // ������ ���������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Client:= Cache.arClientInfo[UserId];
    CliMail:= ExtractFictiveEmail(Client.Mail);
    if (CliMail='') then raise EBOBError.Create('� ������� ��� email ��� email ���������');
    if not fnCheckEmail(CliMail) then
      raise EBOBError.Create('������������ E-mail ������� - '+Client.Mail);

    flNewUser:= (Client.Login='');
    firma:= Cache.arFirmInfo[FirmId];

    if flNewUser then begin
//      if (Client.Post='') then raise EBOBError.Create('� ������� ��� ���������.');
      s:= CheckClientFIO(Client.Name); // �������� ������������ ��� ������������ �������
      if s<>'' then raise EBOBError.Create(s);

      if (UserLogin='') then raise EBOBError.Create(MessText(mtkNotSetLogin));
      if not fnCheckOrderWebLogin(UserLogin) then
        raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
      if not fnNotLockingLogin(UserLogin) then // ���������, �� ��������� �� ����� � �����������
        raise EBOBError.Create(MessText(mtkLockingLogin, UserLogin));
        // ������������ ������ � ���� ����������� ��� ���������� ������������
    end;

    if flNewUser or (firma.SUPERVISOR<>UserId) then try
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
      IBS.SQL.Text:= 'select rPassw, rErrText from SetFirmMainUser('+
        UserCode+', '+IntToStr(FirmID)+', :login, '+IntToStr(EmplId)+', 0)';
      IBS.ParamByName('login').AsString:= UserLogin;
      IBS.ExecQuery;
      if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
      if IBS.FieldByName('rErrText').AsString<>'' then
        raise EBOBError.Create(IBS.FieldByName('rErrText').AsString);

      if flNewUser then begin  // ���� ����� ������������
        if (IBS.FieldByName('rPassw').AsString='') then
          raise EBOBError.Create(MessText(mtkErrFormTmpPass));
        newpass:= IBS.FieldByName('rPassw').AsString;
        Client.Login:= UserLogin;
        Client.Password:= newpass;
      end;

      IBS.Transaction.Commit;
      IBS.Close;
      firma.SUPERVISOR:= UserID;

      s:= SetMainUserToGB(FirmID, UserId, Date()); // ������ � Grossbee
      if (s<>'') then prMessageLOGS(nmProc+': '+s);

      if firma.IsFinalClient then try // ������ ������ (���)
        if not IBS.Transaction.InTransaction then IBS.Transaction.StartTransaction;
        IBS.SQL.Text:= 'UPDATE WEBORDERCLIENTS SET WOCLSEARCHCURRENCY='+
                       cStrUAHCurrCode+' where WOCLCODE='+UserCode;
        IBS.ExecQuery;
        if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
        IBS.Close;
        Client.SearchCurrencyID:= cUAHCurrency;
                                 // ������ �������� (���������)
        if not IBS.Transaction.InTransaction then IBS.Transaction.StartTransaction;
        IBS.SQL.Text:= 'UPDATE WEBCLIENTCONTRACTS SET wccDestDef=0, WCCDeliveryDef='+
                       IntToStr(cDelivSelfGet)+' where WCCCLIENT='+UserCode;
        IBS.ExecQuery;
        if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
        IBS.Close;
      except
        on E: Exception do prMessageLOGS(nmProc+'_1: '+E.Message);
      end;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;

    if flNewUser then try // ���� ����� ������ - ����� ����� � Grossbee
      IBD:= cntsGRB.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
      IBS.SQL.Text:= 'UPDATE PERSONS SET PRSNLOGIN=:login WHERE PRSNCODE='+UserCode;
      IBS.ParamByName('login').AsString:= UserLogin;
      IBS.ExecQuery;
      if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
      IBS.Close;

      s:= prSendMailWithClientPassw(kcmSetMainUser, Client.Login, Client.Password, CliMail, ThreadData);
      if s<>'' then raise EBOBError.Create(s);
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                   ������ � �������� �� �����������
//******************************************************************************
//================================================================ ������ ������
procedure prWebArmGetOrdersToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetOrdersToRegister'; // ��� ���������/�������
var IBS: TIBSQL;
    IBD: TIBDatabase;
    s, s1: string;
    i, Count, EmplId, sPos: integer;
    DateStart, DateFinish: TDateTime;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
//  empl:= nil;
  DateStart:= 0;
  DateFinish:= 0;
  i:= 0;
  try
    EmplId:= Stream.ReadInt;
    try
      if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
      empl:= Cache.arEmplInfo[EmplId];

      if not (empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolCustomerService)) then // ������ ���������
        raise EBOBError.Create(MessText(mtkNotRightExists));

      s:= '';                                        // ���� �� ����.������ - ���
      if boolean(Stream.ReadByte) then s:= 'OREGSTATE=0';
      if boolean(Stream.ReadByte) then s:= s+fnIfStr(s='','',' or ')+'OREGSTATE=1';
      if boolean(Stream.ReadByte) then s:= s+fnIfStr(s='','',' or ')+'OREGSTATE=2';
      if s<>'' then s:= '('+s+')';

      DateStart:= Stream.ReadDouble;
      DateFinish:= Stream.ReadDouble;
      s1:= Stream.ReadStr;
      i:= Stream.ReadInt; // dprtcode
    finally
      prSetThLogParams(ThreadData, csWebArmGetOrdersToRegister, EmplId, 0, 'DateStart='+
        fnIfStr(DateStart>0, FormatDateTime(cDateFormatY2, DateStart), '')+
        #13#10'DateFinish='+fnIfStr(DateFinish>0, FormatDateTime(cDateFormatY2, DateFinish), '')+
        #13#10'OREGFIRMNAME LIKE='+s1+#13#10'OREGDPRTCODE='+IntToStr(i)+#13#10+s); // �����������
    end;

    if (DateStart>0) then s:= s+fnIfStr(s='', '', ' and ')+'OREGCREATETIME>=:DateStart';
    if (DateFinish>0) then s:= s+fnIfStr(s='', '', ' and ')+'OREGCREATETIME<=:DateFinish';
    if (s1<>'')  then s:= s+fnIfStr(s='','',' and ')+' UPPERCASE(OREGFIRMNAME) LIKE ''%'+AnsiUpperCase(s1)+'%''';

    IBD:= cntsORD.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
    IBS.SQL.Text:= 'select * from ORDERTOREGISTER '+
      ' left join REGIONALZONES on RGZNCODE=OREGREGION'+fnIfStr(s='','',' where '+s);
    if DateStart>0 then IBS.ParamByName('DateStart').AsDateTime:= Round(DateStart);
    if DateFinish>0 then IBS.ParamByName('DateFinish').AsDateTime:= Round(DateFinish+1);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ������� ���� ����, ��� ������ ��������� ���������
    Count:= 0;
    sPos:= Stream.Position;
    Stream.WriteInt(Count);
    IBS.ExecQuery;                               // trim ???
    while not IBS.EOF do begin
      Stream.WriteInt(IBS.FieldByName('OREGCODE').AsInteger);
      Stream.WriteStr(IBS.FieldByName('OREGFIRMNAME').AsString);
      Stream.WriteStr(IBS.FieldByName('RGZNNAME').AsString);
      Stream.WriteStr(IBS.FieldByName('OREGMAINUSERFIO').AsString);
      Stream.WriteStr(IBS.FieldByName('OREGMAINUSERPOST').AsString);
      Stream.WriteStr(IBS.FieldByName('OREGLOGIN').AsString);
      Stream.WriteBool(GetBoolGB(IBS, 'OREGCLIENT'));
      Stream.WriteStr(IBS.FieldByName('OREGADDRESS').AsString);
      Stream.WriteStr(IBS.FieldByName('OREGPHONES').AsString);
      Stream.WriteStr(IBS.FieldByName('OREGEMAIL').AsString);
      Stream.WriteInt(IBS.FieldByName('OREGTYPE').AsInteger);
      Stream.WriteInt(IBS.FieldByName('OREGSTATE').AsInteger);
      Stream.WriteDouble(IBS.FieldByName('OREGPROCESSINGTIME').AsDateTime);
      Stream.WriteStr(IBS.FieldByName('OREGCOMMENT').AsString);
      Stream.WriteInt(IBS.FieldByName('OREGDPRTCODE').AsInteger);
      Stream.WriteInt(IBS.FieldByName('OREGUSERCODE').AsInteger);
      Stream.WriteStr(IBS.FieldByName('OREGUSERNAME').AsString);
      Stream.WriteDouble(IBS.FieldByName('OREGCREATETIME').AsDateTime);
      TestCssStopException;
      IBS.Next;
      Inc(Count);
    end;
    if Count<1 then raise EBOBError.Create('������ �� �������� ��������� �� �������.');
    Stream.Position:= sPos;
    Stream.WriteInt(Count);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end;
//========================================================== ������������ ������
procedure prWebArmAnnulateOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmAnnulateOrderToRegister'; // ��� ���������/�������
var IBS: TIBSQL;
    IBD: TIBDatabase;
    OREGCODE,EmplId: integer;
    OREGCOMMENT: String;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try                                                  // ��� ������ ��������
    EmplId:= Stream.ReadInt;
    OREGCODE:= Stream.ReadInt;
    OREGCOMMENT:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csWebArmAnnulateOrderToRegister, EmplId, 0,
      'OREGCODE='+IntToStr(OREGCODE)+#13#10'OREGCOMMENT='+OREGCOMMENT); // �����������

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    empl:= Cache.arEmplInfo[EmplId];
    if not (empl.UserRoleExists(rolCustomerService) or empl.UserRoleExists(rolUiK)) then // ������ ���������
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if OREGCOMMENT='' then raise EBOBError.Create('�� ������� ������� ������������� ������.');

    IBD:= cntsORD.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
    IBS.SQL.Text:= 'SELECT OREGSTATE, OREGDPRTCODE FROM ORDERTOREGISTER WHERE OREGCODE='+IntToStr(OREGCODE);
    IBS.ExecQuery;
    if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundRegOrd));
    if IBS.FieldByName('OREGSTATE').AsInteger>0 then
      raise EBOBError.Create(MessText(mtkRegOrdAddOrAnn));
    IBS.Close;
                                   // ��� �������� ��������, ����������
    fnSetTransParams(IBS.Transaction, tpWrite, True);
    IBS.SQL.Text:= 'update ORDERTOREGISTER set OREGSTATE=2,'+ // ������� ����������� ������
      ' OREGPROCESSINGTIME=:OREGPROCESSINGTIME, OREGCOMMENT=:OREGCOMMENT,'+
      ' OREGUSERNAME=:OREGUSERNAME WHERE OREGCODE='+IntToStr(OREGCODE);
    IBS.ParamByName('OREGPROCESSINGTIME').AsdateTime:= now();
    IBS.ParamByName('OREGCOMMENT').AsString:= OREGCOMMENT;
    IBS.ParamByName('OREGUSERNAME').AsString:= empl.EmplShortName;
    IBS.ExecQuery;
    IBS.Transaction.Commit;
    IBS.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end;
//=============================================================== ������� ������
procedure prWebArmRegisterOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmRegisterOrderToRegister'; // ��� ���������/�������
var IBS: TIBSQL;
    IBD: TIBDatabase;
    OREGCODE, EmplId, UserID, FirmID, i: integer;
    UserLogin, UserCode, FirmCode, newpass, comment, s: String;
    flNewUser, flNewFirm: Boolean;
    empl: TEmplInfoItem;
    Client: TClientInfo;
    firm: TFirmInfo;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  Client:= nil;
  try                                  // ��� ������ ��������
    EmplId:= Stream.ReadInt;
    OREGCODE:= Stream.ReadInt;
    UserLogin:= Stream.ReadStr;
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmRegisterOrderToRegister, EmplId, 0, 'OREGCODE='+IntToStr(OREGCODE)+
      #13#10'UserLogin='+UserLogin+#13#10'UserID='+UserCode+#13#10'FirmID='+FirmCode); // �����������

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    empl:= Cache.arEmplInfo[EmplId];
    if not (empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolCustomerService)) then // ������ ���������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    UserCode:= IntToStr(UserID);
    FirmCode:= IntToStr(FirmID);
    firm:= Cache.arFirmInfo[FirmID];
    flNewFirm:= StrToIntDef(firm.NUMPREFIX, 0)<1; // ����� Web-�����
    flNewUser:= True;
    if not flNewFirm then begin// ���� Web-����� ����
      for i:= Low(firm.FirmClients) to High(firm.FirmClients) do
        if Cache.ClientExist(firm.FirmClients[i]) and
          (Cache.arClientInfo[firm.FirmClients[i]].Login<>'') then begin
          flNewUser:= False; // ���� ���� ���� ���� Web-������
          break;
        end;
    end else if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if flNewUser then begin // ���� ����� Web-������
      Client:= Cache.arClientInfo[UserID];
      if (Client.Post='') then raise EBOBError.Create('� ������� ��� ���������.');
      if (Client.Mail='') then raise EBOBError.Create('� ������� ��� email');
      if (UserLogin='') then raise EBOBError.Create(MessText(mtkNotSetLogin));
      if not fnCheckEmail(Client.Mail) then
        raise EBOBError.Create('������������ E-mail ������� - '+Client.Mail);
      if not fnCheckOrderWebLogin(UserLogin) then
        raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
      if not fnNotLockingLogin(UserLogin) then // ���������, �� ��������� �� ����� � �����������
        raise EBOBError.Create(MessText(mtkLockingLogin, UserLogin));
          // ������������ ������ � ���� ����������� ��� ���������� ������������
    end;

    try
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'SELECT OREGSTATE, OREGDPRTCODE FROM ORDERTOREGISTER WHERE OREGCODE='+IntToStr(OREGCODE);
      IBS.ExecQuery;
      if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundRegOrd));
      if (IBS.FieldByName('OREGSTATE').AsInteger>0) then
        raise EBOBError.Create(MessText(mtkRegOrdAddOrAnn));
      IBS.Close;

      fnSetTransParams(IBS.Transaction, tpWrite); // ��������� ������
      s:= '';
      if flNewUser then begin // ���� ����� ������
        with ibs.Transaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= 'select rPassw,rErrText from SetFirmMainUser('+
          UserCode+', '+IntToStr(FirmID)+', :login, '+IntToStr(EmplID)+', 0)';
        IBS.ParamByName('login').AsString:= UserLogin;
        IBS.ExecQuery;
        if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));
        if IBS.FieldByName('rErrText').AsString<>'' then
          raise EBOBError.Create(IBS.FieldByName('rErrText').AsString);
        if (IBS.FieldByName('rPassw').AsString='') then
          raise EBOBError.Create(MessText(mtkErrFormTmpPass));
        newpass:= IBS.FieldByName('rPassw').AsString;
        IBS.Transaction.Commit;
        IBS.Close;
        comment:= '������ ��������� �� ������� � ������� '+UserLogin;
        Client.Login:= UserLogin;
        Client.Password:= newpass;
        s:= prSendMailWithClientPassw(kcmRegister, Client.Login, Client.Password, Client.Mail, ThreadData);

      end else begin
        newpass:= '������ ������� �� �����������'; // ��������� �����
        comment:= newpass+' '+firm.Name;
      end;
      comment:= comment+' ������������� '+empl.EmplShortName;
      if s<>'' then comment:= comment+', '+s;
                                          // ��� �������� ��������, ������������
      with ibs.Transaction do if not InTransaction then StartTransaction;
      IBS.SQL.Text:= 'update ORDERTOREGISTER set OREGSTATE=1,'+ // ������� �������� ������
        ' OREGPROCESSINGTIME=:OREGPROCESSINGTIME, OREGCOMMENT=:OREGCOMMENT,'+
        ' OREGUSERNAME=:OREGUSERNAME WHERE OREGCODE='+IntToStr(OREGCODE);
      IBS.ParamByName('OREGPROCESSINGTIME').AsdateTime:= now();
      IBS.ParamByName('OREGCOMMENT').AsString:= comment;
      IBS.ParamByName('OREGUSERNAME').AsString:= empl.EmplShortName;
      IBS.ExecQuery;
      IBS.Transaction.Commit;
      IBS.Close;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;

    if flNewUser then try // ���� ����� ������ - ����� ����� � Grossbee
      IBD:= cntsGRB.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
      IBS.SQL.Text:= 'UPDATE PERSONS SET PRSNLOGIN=:login WHERE PRSNCODE='+UserCode;
      IBS.ParamByName('login').AsString:= UserLogin;
      IBS.ExecQuery;
      if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
      IBS.Close;
      s:= SetMainUserToGB(FirmID, UserId, Date(), IBS); // ������ � Grossbee
      if (s<>'') then prMessageLOGS(nmProc+': '+s);
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    if flNewUser then Cache.TestClients(UserID, true, false, true); // ��������� ��������� ������� � ����� � ����

    Stream.Clear;
    Stream.WriteInt(aeSuccess);  // ���� ����, ��� ������ ��������� ���������
//    Stream.WriteBool(flNewUser); // ������� ������ ������������
    Stream.WriteStr(comment);    // ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                       ������ � ���������
//******************************************************************************
//============================================================== ������ ��������
procedure prWebArmGetRegionalZones(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetRegionalZones'; // ��� ���������/�������
var ibs: TIBSQL;
    IBD: TIBDatabase;
    Count, EmplId, sPos: integer;
begin
  Stream.Position:= 0;
  ibs:= nil;
  IBD:= nil;
  try
    EmplId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmGetRegionalZones, EmplId, 0, ''); // �����������

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select * from REGIONALZONES where not RGZNNAME="" order by RGZNNAME';
    ibs.ExecQuery;
    if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ������� ���� ����, ��� ������ ��������� ���������
    sPos:= Stream.Position;
    Count:= 0;
    Stream.WriteInt(Count);
    while not ibs.EOF do begin
      Stream.WriteInt(ibs.FieldByName('RGZNCODE').AsInteger);
      Stream.WriteStr(ibs.FieldByName('RGZNNAME').AsString);
      Stream.WriteStr(ibs.FieldByName('RGZNEMAIL').AsString);
      Stream.WriteInt(ibs.FieldByName('RGZNFILIALLINK').AsInteger);
      TestCssStopException;
      ibs.Next;
      Inc(Count);
    end;
    if Count<1 then raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Position:= sPos;
    Stream.WriteInt(Count);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end;
//=========================================================== ���������� �������
procedure prWebArmInsertRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmInsertRegionalZone'; // ��� ���������/�������
var ibs: TIBSQL;
    IBD: TIBDatabase;
    email, ZoneName, s: string;
    idprt, EmplId, i: integer;
begin
  ibs:= nil;
  IBD:= nil;
  try
    Stream.Position:= 0;
    EmplId:= Stream.ReadInt;
    ZoneName:= trim(Stream.ReadStr);
    email:= trim(Stream.ReadStr);
    idprt:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmInsertRegionalZone, EmplId, 0, 'email='+email+
      #13#10'ZoneName='+ZoneName+#13#10'idprt='+IntToStr(idprt)); // �����������

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (ZoneName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if (email='') then raise EBOBError.Create('�� ����� Email.');
    if (idprt<1) then raise EBOBError.Create('�� ������ �������������.');

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
                                // �������� ��������� �������� �� �������� �����
    ibs.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
    ' from rdb$relation_fields f, rdb$fields ff'+
    ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE and f.RDB$RELATION_NAME=:table';
    ibs.ParamByName('table').AsString:= 'REGIONALZONES';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      s:= trim(ibs.FieldByName('fname').AsString);
      i:= ibs.FieldByName('fsize').AsInteger;
      if (s='RGZNNAME')       and (length(ZoneName)>i) then ZoneName:= trim(Copy(ZoneName, 1, i))
      else if (s='RGZNEMAIL') and (length(email)>i)    then email:= trim(Copy(email, 1, i));
      TestCssStopException;
      ibs.Next;
    end;  
    ibs.Close;

    fnSetTransParams(ibs.Transaction, tpWrite, True);
    ibs.SQL.Text:= 'insert into REGIONALZONES (RGZNNAME, RGZNEMAIL, RGZNFILIALLINK)'+
                   ' values (:RGZNNAME, :RGZNEMAIL, :RGZNFILIALLINK)';
    ibs.ParamByName('RGZNNAME').AsString:= ZoneName;
    ibs.ParamByName('RGZNEMAIL').AsString:= email;
    ibs.ParamByName('RGZNFILIALLINK').AsInteger:= idprt;
    ibs.ExecQuery;
    ibs.Transaction.Commit;
    ibs.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ������� ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end;
//============================================================= �������� �������
procedure prWebArmDeleteRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmDeleteRegionalZone'; // ��� ���������/�������
var ibs: TIBSQL;
    IBD: TIBDatabase;
    zcode, EmplId: integer;
begin
  ibs:= nil;
  IBD:= nil;
  try
    Stream.Position:= 0;
    EmplId:= Stream.ReadInt;
    zcode:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmDeleteRegionalZone, EmplId, 0, 'zcode='+IntToStr(zcode)); // �����������

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (zcode<1) then raise EBOBError.Create(MessText(mtkNotSetRegion));

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpWrite, true);
//    ibs.SQL.Text:= 'delete from REGIONALZONES where RGZNCODE='+IntToStr(zcode);
    ibs.SQL.Text:= 'update REGIONALZONES set RGZNNAME="", RGZNEMAIL="" where RGZNCODE='+IntToStr(zcode);
    ibs.ExecQuery;
    ibs.Transaction.Commit;
    ibs.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ������� ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
end;
//============================================================ ��������� �������
procedure prWebArmUpdateRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmUpdateRegionalZone'; // ��� ���������/�������
var ibs: TIBSQL;
    IBD: TIBDatabase;
    email, ZoneName, s, ss: string;
    idprt, EmplId, zcode, i: integer;
begin
  ibs:= nil;
  IBD:= nil;
  Stream.Position:= 0;
  try
    EmplId:= Stream.ReadInt;
    zcode:= Stream.ReadInt;
    ZoneName:= trim(Stream.ReadStr);
    email:= trim(Stream.ReadStr);
    idprt:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmUpdateRegionalZone, EmplId, 0, 'zcode='+IntToStr(zcode)+
      #13#10'email='+email+#13#10'ZoneName='+ZoneName+#13#10'idprt='+IntToStr(idprt)); // �����������

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (zcode<1) then raise EBOBError.Create(MessText(mtkNotSetRegion));
    if (ZoneName='') and (email='') and (idprt<1) then
      raise EBOBError.Create(MessText(mtkNotParams));

    s:= '';
    if (ZoneName<>'') then s:= s+'RGZNNAME=:RGZNNAME';
    if (email<>'') then s:= s+fnIfStr(s='','',',')+'RGZNEMAIL=:RGZNEMAIL';
    if (idprt>0) then s:= s+fnIfStr(s='','',',')+'RGZNFILIALLINK=:RGZNFILIALLINK';

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
                                // �������� ��������� �������� �� �������� �����
    ibs.SQL.Text:= 'select f.RDB$FIELD_NAME fname, ff.RDB$FIELD_LENGTH fsize'+
    ' from rdb$relation_fields f, rdb$fields ff'+
    ' where ff.RDB$FIELD_NAME=f.RDB$FIELD_SOURCE and f.RDB$RELATION_NAME=:table';
    ibs.ParamByName('table').AsString:= 'REGIONALZONES';
    ibs.ExecQuery;
    while not ibs.Eof do begin
      ss:= trim(ibs.FieldByName('fname').AsString);
      i:= ibs.FieldByName('fsize').AsInteger;
      if (ss='RGZNNAME')       and (length(ZoneName)>i) then ZoneName:= trim(Copy(ZoneName, 1, i))
      else if (ss='RGZNEMAIL') and (length(email)>i)    then email:= trim(Copy(email, 1, i));
      TestCssStopException;
      ibs.Next;
    end;  
    ibs.Close;

    fnSetTransParams(ibs.Transaction, tpWrite, True);
    ibs.SQL.Text:= 'update REGIONALZONES set '+s+' where RGZNCODE='+IntToStr(zcode);
    if (ZoneName<>'') then ibs.ParamByName('RGZNNAME').AsString:= ZoneName;
    if (email<>'') then ibs.ParamByName('RGZNEMAIL').AsString:= email;
    if (idprt>0) then ibs.ParamByName('RGZNFILIALLINK').AsInteger:= idprt;
    ibs.ExecQuery;
    ibs.Transaction.Commit;
    ibs.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ������� ���� ����, ��� ������ ��������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
end;

//******************************************************************************
//                          ������ ���������
//******************************************************************************

//******************************************************************************
//                         ������, ��������
//******************************************************************************
//======================================= (+ Web) ������ ����� ��������� �������
procedure prGetListAttrGroupNames(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetListAttrGroupNames'; // ��� ���������/�������
var UserID, FirmID, SysID, i, pos, iCount, command: Integer;
    errmess: String;
    lst: TStringList;
    flNew: Boolean;
    attgr: TSubDirItem;
begin
  Stream.Position:= 0;
  iCount:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;  // ��� ������� - ����������

    if (FirmID<1) then command:= csGetListAttrGroupNames else command:= csOrdGetListAttrGroupNames;

    prSetThLogParams(ThreadData, command, UserId, FirmID, 'SysID='+IntToStr(SysID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);  // ����� ��� ���-�� �����
    //------------------- ������ ����� ��������� Moto (TStringList) not Free !!!
    lst:= Cache.AttrGroups.GetListAttrGroups(constIsMoto);
    if Assigned(lst) and (lst.Count>0) then begin
      for i:= 0 to lst.Count-1 do begin
        Stream.WriteInt(Integer(lst.Objects[i]));  // ���
        Stream.WriteStr(lst[i]);                   // ��������
        Stream.WriteBool(False);                   // ������� ������ ������ ���������
        Inc(iCount);
      end;
    end;

    //------------------- ������ ����� ��������� Grossbee (TList) not Free !!!
    with Cache.GBAttributes.Groups.ItemsList do begin
      for i:= 0 to Count-1 do begin
        attgr:= Items[i];
        if (attgr.Links.LinkCount<1) then Continue; // ���������� ������ ��������� ��� �������
        flNew:= (attgr.SrcID=1);
        Stream.WriteInt(attgr.ID+cGBattDelta); // ��� �� �������
        Stream.WriteStr(attgr.Name);           // ��������
        Stream.WriteBool(flNew);               // ������� ����� ������ ���������
        Inc(iCount);
      end;
    end;

    if (iCount<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Position:= pos;
    Stream.WriteInt(iCount);  // ���-�� �����
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================================== (+ Web) ������ ��������� ������
procedure prGetListGroupAttrs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetListGroupAttrs'; // ��� ���������/�������
var UserID, FirmID, grpID, i, ii, j, jj, pos, command: Integer;
    errmess: String;
    lst: TList;
begin
  Stream.Position:= 0;
  lst:= nil;
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    grpID:= Stream.ReadInt;  // ��� ������ ���������

    if (FirmID<1) then command:= csGetListGroupAttrs else command:= csOrdGetListGroupAttrs;

    prSetThLogParams(ThreadData, command, UserId, FirmID, 'grpID='+IntToStr(grpID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if (grpID>cGBattDelta) then begin //----------------- �������� Grossbee
      grpID:= grpID-cGBattDelta; // ������� ����� �����
      if not Cache.GBAttributes.Groups.ItemExists(grpID) then
        raise EBOBError.Create(MessText(mtkNotFoundAttGr, IntToStr(grpID)));

      lst:= Cache.GBAttributes.GetGBGroupAttsList(grpID);
      if (lst.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundData));
      Stream.WriteInt(lst.Count);       // ���-�� ���������
      for i:= 0 to lst.Count-1 do with TGBAttribute(lst[i]) do begin
        Stream.WriteInt(ID+cGBattDelta);   // ��� �������� �� �������
        Stream.WriteStr(Name);   // ��������
        Stream.WriteByte(SrcID); // ���
        with Links.ListLinks do begin // ������ ������ �� �������� ��������
          Stream.WriteInt(Count);                     // ����������
          for ii:= 0 to Count-1 do begin
            Stream.WriteInt(GetLinkID(Items[ii])+cGBattDelta); // ��� �������� �� �������
            Stream.WriteStr(GetLinkName(Items[ii]));  // ���� ��������
          end;
        end;
      end; // for

    end else begin                                       // �������� ORD
      if not Cache.AttrGroups.ItemExists(grpID) then
        raise EBOBError.Create(MessText(mtkNotFoundAttGr, IntToStr(grpID)));

      lst:= Cache.AttrGroups.GetAttrGroup(grpID).GetListGroupAttrs; // ������ ��������� ������ (TList)
      if (lst.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

      Stream.WriteInt(lst.Count);       // ���-�� ���������
      for i:= 0 to lst.Count-1 do with TAttributeItem(lst[i]) do begin
        Stream.WriteInt(ID);        // ���
        Stream.WriteStr(Name);      // ��������
        Stream.WriteByte(TypeAttr); // ���
        with ListValues do begin    // �������� ���������
          pos:= Stream.Position;
          Stream.WriteInt(0);                  // ����� ��� ����������
          jj:= 0;
          for ii:= 0 to Count-1 do begin
            j:= Integer(Objects[ii]);
            if not Cache.Attributes.GetAttrVal(j).State then Continue; // ���������� ��������������
            Stream.WriteInt(j);           // ��� ��������
            Stream.WriteStr(Strings[ii]); // ���� ��������
            inc(jj);
          end;
          Stream.Position:= pos;
          Stream.WriteInt(jj);  // ����������
          Stream.Position:= Stream.Size;
        end;
      end; // for
    end;
  finally
    lst.Free;
  end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=============================================== ��������� ������ ��� ���������
procedure prGetWareInfoView(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareInfoView'; // ��� ���������/�������
var UserID, FirmID, WareID, i, Count1, sPos, j, ModelID, NodeID, ContID,
      command, aCode, currID: Integer;
    s, sFilters, ActTitle, ActText, sLog, ss: string;
    Files: TarWareFileOpts;
    isEngine, flNews, flCatchMom: boolean;
    List, list1: TStringList;
    aiWares: Tai;
    Engine: TEngine;
    Model: TModelAuto;
    ware: TWareInfo;
    GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    price, curr: Double;
    prices: TDoubleDynArray;
    ffp: TForFirmParams;
begin
  List:= nil;
  List1:= nil;
  GBIBD:= nil;
  GBIBS:= nil;
  ware:= nil;
  ffp:= nil;
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    WareID:= Stream.ReadInt;  // ��� ������
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt; // <0 - ���� Motul
    isEngine:= Stream.ReadBool;
    sFilters:= Stream.ReadStr;

    if (FirmID<1) then command:= csGetWareInfoView else command:= csOrdGetWareInfo;

    sLog:= 'WareID='+IntToStr(WareID)+#13#10+
           fnIfStr(isEngine, 'EngineID=', 'ModelID=')+IntToStr(ModelID)+
           #13#10'NodeID='+IntToStr(NodeID)+#13#10'sFilters='+sFilters+
           #13#10'ContID='+IntToStr(ContID);
    try
      if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

      if not Cache.WareExist(WareID) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
      SetLength(aiWares, 1);
      aiWares[0]:= WareID;

      ware:= Cache.GetWare(WareID);
      if ware.IsArchive then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
      sLog:= sLog+#13#10'IsPrize='+fnIfStr(ware.IsPrize, '1', '0');

      Stream.Clear;
      Stream.WriteInt(aeSuccess);  // �������� ��������� ������
      Stream.WriteStr(ware.Name);          // ������������
      Stream.WriteBool(ware.IsSale);       // ������� ����������
      Stream.WriteBool(ware.IsNonReturn);  // ������� ����������
      Stream.WriteBool(ware.IsCutPrice);   // ������� ������

      aCode:= ware.GetActionParams(ActTitle, ActText);
      Stream.WriteInt(aCode);         // ��� �����
      Stream.WriteStr(ActTitle);      // ���������
      Stream.WriteStr(ActText);       // �����

      Stream.WriteStr(ware.PrDirectName);  // �������� ����������� �� ���������
      Stream.WriteStr(ware.BrandNameWWW);  // ����� ��� ����� ��������
      Stream.WriteStr(ware.BrandAdrWWW);   // ����� ������ �� ���� ������
      Stream.WriteStr(ware.WareBrandName); // �����
      Stream.WriteDouble(ware.divis);      // ���������
      Stream.WriteStr(ware.MeasName);      // ��.���.
      Stream.WriteStr(ware.Comment);       // ��������


      if ware.IsINFOgr then begin
        Stream.WriteInt(0);  // ��� ���������
        Stream.WriteStr(''); // ������� - ���
        Stream.WriteStr(''); // ��������- ���
        Stream.WriteInt(-1); // ��� ��������

      end else begin
        List:= ware.GetWareAttrValuesView;
        List1:= ware.GetWareGBAttValuesView;
        try
          Stream.WriteInt(List.Count+List1.Count); // ���-�� ���������
          // ������ �������� � �������� ��������� ORD ������ (TStringList)
          with List do for i:= 0 to Count-1 do begin
            Stream.WriteStr(Names[i]);                    // �������� ��������
            Stream.WriteStr(ExtractParametr(Strings[i])); // �������� ��������
          end;
          // ������ �������� � �������� ��������� Grossbee (TStringList)
          with List1 do for i:= 0 to Count-1 do begin
            Stream.WriteStr(Names[i]);                    // �������� ��������
            Stream.WriteStr(ExtractParametr(Strings[i])); // �������� ��������
          end;
        finally
          List.Clear;
          List1.Clear;
        end;

        s:= '';
        if (ModelID>0) then try               // ----------------------- ���������
          if IsEngine and (NodeID>0) and Cache.FDCA.Engines.ItemExists(ModelID)
            and Cache.FDCA.AutoTreeNodesSys[constIsAuto].NodeExists(NodeID) then begin
              Engine:= Cache.FDCA.Engines.GetEngine(ModelID);
              List:= Engine.GetEngNodeWareUsesView(NodeID, aiWares, sFilters);
          end else if not IsEngine and       // --------------------------- ������
            (NodeID<>0) and Cache.FDCA.Models.ModelExists(ModelID) then begin
            Model:= Cache.FDCA.Models[ModelID];
            if ((NodeID<0) and Cache.MotulTreeNodes.ItemExists(-NodeID)) or
              ((NodeID>0) and Cache.FDCA.AutoTreeNodesSys[Model.TypeSys].NodeExists(NodeID)) then
            List:= Cache.GetWaresModelNodeUsesAndTextsView(ModelID, NodeID, aiWares, sFilters);
          end;
          if (List.Count>0) then s:= List.Text;
        except
          on E: Exception do s:= '';
        end; // with Cache.FDCA
        List.Clear;
        Stream.WriteStr(s); // �������

        s:= '';
        List:= ware.GetWareCriValuesView;
        with List do try
          if (Count>0) then s:= Text;
        finally Clear; end;
        Stream.WriteStr(s); // ��������

  //      if (Cache.NoTDPictBrandCodes.IndexOf(ware.WareBrandID)<0) then
        if not ware.PictShowEx then
          Files:= ware.GetWareFiles
        else SetLength(Files, 0);

        Count1:= Length(Files)-1;
        j:= -1;
        sPos:= Stream.Position;
        Stream.WriteInt(j);
        for i:= 0  to Count1 do with Files[i] do if LinkURL then begin
          Stream.WriteStr(FileName);
          Stream.WriteInt(SupID);
          Stream.WriteStr(HeadName);
          Inc(j);
        end;
        Stream.Position:= sPos;
        Stream.WriteInt(j);  // ���-�� ��������
        Stream.Position:= Stream.Size; // ���� ����� ��� ��������� ���� �� ������
      end; // if not ware.IsINFOgr
    finally
      prSetThLogParams(ThreadData, command, UserId, FirmID, sLog);
    end;

    if (FirmId=IsWe) then //------------------------------ Webarm
      Stream.WriteInt(0)  // �������� ����� ���������

    else try              //------------------------------ Web
      if ware.IsPrize then begin //-------------------------------- ���� �������
        currID:= Cache.BonusCrncCode;
        curr:= ware.SellingPrice(FirmID, currID, contID);
        SetLength(prices, 3);
        for i:= 0 to High(prices) do prices[i]:= curr;
      end else begin
        currID:= Cache.arClientInfo[UserID].SEARCHCURRENCYID; // ����� ������ �� �������� ������������ (����)
        prices:= ware.CalcFirmPrices(FirmID, currID, contID); // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
      end;

      ffp:= TForFirmParams.Create(FirmID, UserID, 0, currID, contID);
      //------------------------ ������ � Stream ����� ��������� ������� �������
      prSaveWareRestsExists(Stream, ffp, aiWares);

      flNews:= ware.IsPrize and ware.IsNews;
      flCatchMom:= ware.IsPrize and ware.IsCatchMom;
      price:= 0; // ���������� ���� ��� ���� ������
      if flCatchMom then try
        GBIBD:= CntsGRB.GetFreeCnt();
        s:= IntToStr(Cache.arFirmInfo[FirmID].GetContract(contID).ContPriceType);
        ss:= cStrDefCurrCode;
        GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
        GBIBS.SQL.Text:='select warecode, coalesce(cm.RESULTVALUE, cm1.RESULTVALUE) prev'+
          '  from (select w.warecode, w.waremeas, (select MAX(PriceDate) from PRICELIST'+
          '    where PriceSubFirmCode=1 and PriceWareCode=w.warecode'+
          '      and PriceTypeCode='+s+' and PriceDate<="today") xDate'+
          '    from wares w where w.warecode='+IntToStr(WareID)+')'+
          '  left join GETWAREPRICE(xDate-1, warecode, '+s+', waremeas) p on 1=1'+
          '  left join ConvertMoney(p.RPRICEWARE, p.RCRNCCODE, '+ss+', xDate-1) cm'+
          '    on exists(select * from RateCrnc where RateCrncCode=p.RCRNCCODE)'+
          '  left join GETWAREPRICE("today", warecode, '+s+', waremeas) p1 on 1=1'+
          '  left join ConvertMoney(p1.RPRICEWARE, p1.RCRNCCODE, '+ss+', "today") cm1'+
          '    on exists(select * from RateCrnc where RateCrncCode=p1.RCRNCCODE)'+
          '  where xDate is not null';
        GBIBS.ExecQuery;
        if not (GBIBS.EOF and GBIBS.BOF) then begin
          price:= GBIBS.FieldByName('prev').AsFloat; // ����.���� � Euro
          curr:= Cache.Currencies.GetCurrRate(Cache.BonusCrncCode);
          if fnNotZero(curr) then                       // ����.���� � �������
            price:= price*Cache.Currencies.GetCurrRate(cDefCurrency)/curr;
          price:= RoundToHalfDown(price);
        end;
      finally
        prFreeIBSQL(GBIBS);
        cntsGRB.SetFreeCnt(GBIBD);
      end;

      //------------------------------------------------------ �������� � CGI
      Stream.WriteBool(flNews);      // �������
      Stream.WriteBool(flCatchMom);  // ���� ������
      Stream.WriteStr(Cache.GetCurrName(currID, True)); // ������
      Stream.WriteDouble(price);     // ����.���� � ������� ��� ���� ������ ��� 0
                          // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
      for i:= 0 to High(prices) do Stream.WriteStr(trim(FormatFloat(cFloatFormatSumm, prices[i])));
    finally
      prFree(ffp);
    end; // if (FirmId<>IsWe)

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Files, 0);
  prFree(List);
  prFree(List1);
  SetLength(aiWares, 0);
  SetLength(prices, 0);
end;
//============================================== ��������� ������� ��� ���������
procedure prGetCompareWaresInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCompareWaresInfo'; // ��� ���������/�������
var UserID, FirmID, WareID, agID, aggID, i, j, WareCount, contID, aCode: Integer;
    errmess, ActTitle, ActText: String;
    Ware: TWareInfo;
    WaresList: TStringList;
    attCodes, attgCodes, aiWares: Tai;
    prices: TDoubleDynArray;
    lst, lstg: TList;
    ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  setLength(attCodes, 0);
  setLength(attgCodes, 0);
  agID:= 0;
  aggID:= 0;
  WaresList:= nil;
  ffp:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    WareCount:= Stream.ReadInt;  // ������� ���-�� �������

    prSetThLogParams(ThreadData, csGetCompareWaresInfo, UserId, FirmID,
      'WareCount='+IntToStr(WareCount)+#13#10'ContID='+IntToStr(ContID));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    ffp:= TForFirmParams.Create(FirmID, UserID, 0, 0, contID);
    if not ffp.ForClient then ffp.CurrID:= cDefCurrency; // ��� ������ ���������

    WaresList:= fnCreateStringList(True, dupIgnore, WareCount); // ������ � ��������� �� ��������� ����� �������  ???

    for i:= 0 to WareCount-1 do begin           // ��������� ���� �������
      WareID:= Stream.ReadInt;
      if Cache.WareExist(WareID) then begin     // �������� ������������� ������
        Ware:= Cache.GetWare(WareID);
        if not Ware.IsArchive then begin
          if (agID<1) then agID:= Ware.AttrGroupID;    // ���������� ��� ������ ���������
          if (aggID<1) then aggID:= Ware.GBAttGroup;   // ���������� ��� ������ ��������� Grossbee
          if ((agID>0) and (agID=Ware.AttrGroupID)) or // ����� ����� ������ � ���� �������
            ((aggID>0) and (aggID=Ware.GBAttGroup)) then
            WaresList.AddObject(Ware.Name, Ware);      // � Object - ������ �� �����
        end;
      end;
    end;
    if ((agID+aggID)<1) or (WaresList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotParams));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient)); // ������������ ������ ���������

//--------------------------------------------------------------------- ��������
    lst:= Cache.AttrGroups.GetAttrGroup(agID).GetListGroupAttrs;
    lstg:= Cache.GBAttributes.GetGBGroupAttsList(aggID);
    Stream.WriteInt(lst.Count+lstg.Count);         // ���-�� ���������

    with lst do try // ������ ��������� ������ ORD (TList)
      setLength(attCodes, Count);     // ������� ����� ���������
      for j:= 0 to Count-1 do begin
        attCodes[j]:= GetDirItemID(Items[j]);      // ���������� ������� ����� ���������
        Stream.WriteStr(GetDirItemName(Items[j])); // �������� �������� ��������
      end;
    finally Free; end;

    with lstg do try // ������ ��������� ������ Grossbee (TList)
      setLength(attgCodes, Count);     // ������� ����� ���������
      for j:= 0 to Count-1 do begin
        attgCodes[j]:= GetDirItemID(Items[j]);     // ���������� ������� ����� ��������� Grossbee
        Stream.WriteStr(GetDirItemName(Items[j])); // �������� �������� ��������
      end;
    finally Free; end;
//------------------------------------------------------------------------------
    Stream.WriteInt(WaresList.Count); // ��������� ���-�� �������
    setLength(aiWares, WaresList.Count);
    for i:= 0 to WaresList.Count-1 do begin // �������� ��������� ������
      Ware:= TWareInfo(WaresList.Objects[i]);
      aiWares[i]:= Ware.ID;
      Stream.WriteInt(Ware.ID);            // ��� ������
      Stream.WriteStr(Ware.Name);          // ������������
      Stream.WriteBool(Ware.IsSale);       // ������� ����������
      Stream.WriteBool(Ware.IsNonReturn);  // ������� ����������
      Stream.WriteBool(Ware.IsCutPrice);   // ������� ������
      Stream.WriteStr(Ware.PrDirectName);  // �������� ����������� �� ���������
      Stream.WriteStr(Ware.BrandNameWWW);  // ����� ��� ����� ��������
      Stream.WriteStr(Ware.BrandAdrWWW);   // ����� ������ �� ���� ������
      Stream.WriteStr(Ware.WareBrandName); // �����
      Stream.WriteDouble(Ware.divis);      // ���������
      Stream.WriteStr(Ware.MeasName);      // ��.���.
      Stream.WriteStr(Ware.Comment);       // ��������

      aCode:= Ware.GetActionParams(ActTitle, ActText);
      Stream.WriteInt(aCode);         // ��� �����
      Stream.WriteStr(ActTitle);      // ���������
//      Stream.WriteStr(ActText);       // ����� �����
      ActText:= Ware.GetFirstTDPictName; // ����� ������ �������� 1-� �������� TD:
      Stream.WriteStr(ActText);          // ��� ����� � tdfiles / ��� ����� � �����������

      //---------------------------------------------------------- ���� Grossbee
      if ffp.ForClient then begin
        prices:= Ware.CalcFirmPrices(FirmID, ffp.currID, contID); // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
        for j:= 0 to High(prices) do Stream.WriteDouble(prices[j]);
      end else
        Stream.WriteDouble(Ware.RetailPrice(FirmID, ffp.currID, contID));
      //---------------------- �������� ��������� � ������ �������
      with Ware.GetWareAttrValuesByCodes(AttCodes) do try // (TStringList)
        for j:= 0 to Count-1 do Stream.WriteStr(Strings[j]);
      finally Free; end;
      //---------------------- �������� ��������� Grossbee � ������ �������
      with Ware.GetWareGBAttValuesByCodes(AttgCodes) do try // (TStringList)
        for j:= 0 to Count-1 do Stream.WriteStr(Strings[j]);
      finally Free; end;
    end; // for i:= 0 to WaresList.Count-1

    //------------------------ ������ � Stream ����� ��������� ������� �������
    prSaveWareRestsExists(Stream, ffp, aiWares);

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(WaresList);
  setLength(attCodes, 0);
  setLength(attgCodes, 0);
  setLength(prices, 0);
  setLength(aiWares, 0);
  prFree(ffp);
  Stream.Position:= 0;
end;

//******************************************************************************
//                                  ��������� ���
//******************************************************************************
//====================================== (+ Web) �������� ������ ��������� �����
procedure prGetModelLineList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelLineList'; // ��� ���������/�������
var UserID, FirmID, SysID, ManufID, i, sPos, iCount, command: Integer;
    isTops, OnlyVisible, OnlyWithWares: Boolean;
    errmess: String;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ManufID:= Stream.ReadInt;
    isTops:= Stream.ReadBool;  // ���� �����
    OnlyVisible:= Stream.ReadBool; // False - ���, True - ������ �������
    OnlyWithWares:= OnlyVisible;   // False - ���, True - ������ � ��������

    if (FirmID<1) then command:= csGetModelLineList else command:= csOrdGetModelLineList;

    prSetThLogParams(ThreadData, command, UserId, FirmID, 'ManufID='+IntToStr(ManufID)+#13#10'SysID='+IntToStr(SysID));

//if flDebugCV then SysID:= constIsCV;

    if CheckNotValidManuf(ManufID, SysID, Manuf, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    Stream.Clear;
    Stream.WriteInt(aeSuccess);        // ������ ������ ��������� ����� � �����
    with Manuf.GetModelLinesList(SysID, isTops) do begin
      sPos:= Stream.Position;
      iCount:= 0; // ������� - ���� �������� ������ �������
      Stream.WriteInt(iCount);
      for i:= 0 to Count-1 do with Cache.FDCA.ModelLines[Integer(Objects[i])] do begin
        if (OnlyVisible and not (IsVisible and HasVisModels)) then Continue;
        if (OnlyWithWares and not MLHasWares) then Continue; // ���� ��� �������
        Stream.WriteInt(ID);                // ��� ���������� ����
        Stream.WriteStr(Name);              // ������������
        Stream.WriteBool(IsVisible);        // ������� ��������� ���������� ����
        Stream.WriteBool(IsTop);            // ���
        Stream.WriteInt(YStart);            // ��� ������ �������
        Stream.WriteInt(MStart);            // ����� ������ �������
        Stream.WriteInt(YEnd);              // ��� ��������� �������
        Stream.WriteInt(MEnd);              // ����� ��������� �������
        Stream.WriteInt(ModelsCount);       // ������� ������� � ����
        Inc(iCount);
      end;
      Stream.Position:= sPos;
      Stream.WriteInt(iCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================= �������� ��������� ���
procedure prModelLineAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelLineAdd'; // ��� ���������/�������
var UserID, SysID, ManufID, fMS, fYS, fME, fYE, iCode: Integer;
    MLName, errmess: String;
    isTop, isVis: boolean;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ManufID:= Stream.ReadInt; // ��� ������������� ����
    MLName:= Stream.ReadStr;  // ������������ ���������� ����
    isTop:= Stream.ReadBool;
    fMS:= Stream.ReadInt;     // ����� ������ �������
    fYS:= Stream.ReadInt;     // ��� ������
    fME:= Stream.ReadInt;     // ����� ���������
    fYE:= Stream.ReadInt;     // ��� ���������
    isVis:= Stream.ReadBool;  // ������� ���������

    prSetThLogParams(ThreadData, csModelLineAdd, UserId, 0, 'ManufID='+IntToStr(ManufID)+
      ', MLName='+MLName+#13#10'SysID='+IntToStr(SysID));

    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    if MLName='' then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidManuf(ManufID, SysID, Manuf, errmess) then raise EBOBError.Create(errmess);

    errmess:= Manuf.ModelLineAdd(iCode, MLName, SysID, fYS, fMS, fYE, fME, UserID, isTop, isVis);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(iCode);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================== ������� ��������� ���
procedure prModelLineDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelLineDel'; // ��� ���������/�������
var UserID, ModelLineID, ManufID, SysID: Integer;
    errmess: String;
    ModelLine: TModelLine;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelLineID:= Stream.ReadInt;  // ��� ���������� ����

    prSetThLogParams(ThreadData, csModelLineDel, UserId, 0, 'ModelLineID='+IntToStr(ModelLineID));

    if CheckNotValidModelLine(ModelLineID, SysID, ModelLine, errmess) then
      raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then
      raise EBOBError.Create(errmess);
    ManufID:= ModelLine.MFAID;
    if CheckNotValidManuf(ManufID, SysID, Manuf, errmess) then
      raise EBOBError.Create(errmess);

    errmess:= Manuf.ModelLineDel(ModelLineID);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================= �������� ��������� ���
procedure prModelLineEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelLineEdit'; // ��� ���������/�������
var UserID, ModelLineID, ManufID, SysID, fMS, fYS, fME, fYE: Integer;
    MLName, errmess: String;
    isTop, isVis: Boolean;
    ModelLine: TModelLine;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelLineID:= Stream.ReadInt;    // ��� ���������� ����
    MLName:= Stream.ReadStr; // ������������ ���������� ����
    isTop:= Stream.ReadBool;
    fYS:= Stream.ReadInt;    // ��� ������
    fMS:= Stream.ReadInt;    // ����� ������ �������
    fYE:= Stream.ReadInt;    // ��� ���������
    fME:= Stream.ReadInt;    // ����� ���������
    isVis:= Stream.ReadBool; //������� ���������

    prSetThLogParams(ThreadData, csModelLineEdit, UserId, 0, 'ModelLineID='+IntToStr(ModelLineID)+', MLName='+MLName);

    if CheckNotValidModelLine(ModelLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    ManufID:= ModelLine.MFAID;
    if CheckNotValidManuf(ManufID, SysID, Manuf, errmess) then raise EBOBError.Create(errmess);

    errmess:= Manuf.ModelLineEdit(ModelLineID, fYS, fMS, fYE, fME, UserID, isTop, isVis, MLName);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                                  ������
//******************************************************************************
//============================== (+ Web) �������� ������ ������� ���������� ����
procedure prGetModelLineModels(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelLineModels'; // ��� ���������/�������
var UserID, FirmID, ModelLineID, SysID, i, sPos, iCount: Integer;
    TopsUp, OnlyVisible, OnlyWithWares: Boolean;
    ModelLine: TModelLine;
    errmess, s: String;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;    
    UserID:= Stream.ReadInt;
    ModelLineID:= Stream.ReadInt;  // ��� ���������� ����
    TopsUp:= Stream.ReadBool;      // ���� �����
    OnlyVisible:= Stream.ReadBool; // False - ���, True - ������ �������
    OnlyWithWares:= OnlyVisible;   // False - ���, True - ������ � ��������

    prSetThLogParams(ThreadData, csGetModelLineModels, UserId, FirmID, 'ModelLineID='+IntToStr(ModelLineID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelLine(ModelLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    Stream.Clear;                // ������ ������� ���������� ���� � �����
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    iCount:= 0; // ������� - ���� �������� ������ �������
    Stream.WriteInt(iCount);
    with ModelLine.GetListModels(TopsUp) do if (Count>0) then begin
      for i:= 0 to Count-1 do with Cache.FDCA.Models[Integer(Objects[i])] do begin
        if (OnlyVisible and not IsVisible) then Continue;
        if (OnlyWithWares and not ModelHasWares) then Continue; // ���� ��� �������
        Stream.WriteInt(ID);             // ��� ������
        s:= '';
        if OnlyWithWares then case SysID of
          constIsAuto, constIsMoto: begin //--------------------- auto, moto
            s:= MarksCommaText;
            if (s<>'') then s:= '('+s+')';
            if (Params.pHP>0) then s:= IntToStr(Params.pHP)+', '+s;
          end;
          constIsCV: begin                //----------------------- ���������
            s:= MarksCommaText;
            if (s<>'') then s:= '('+s+')';
            if (Params.pValves>0) then s:= '['+Params.cvTonnOut+' �], '+s;
            if (Params.cvHPaxLO<>'') then s:= Params.cvHPaxLOout+', '+s;
          end;
          constIsAx: begin                //----------------------- ���
            if (Params.pDriveID>0) then
              s:= '('+Cache.FDCA.TypesInfoModel.InfoItems[Params.pDriveID].Name+')'; // ��� ���
            if (Params.cvHPaxLO<>'') then s:= Params.cvHPaxLOout+' ��, '+s; // �������� �� ��� [��]
          end;
        end; // case

        if (s<>'') then s:= '||'+s;
        Stream.WriteStr(Name+s);         // �������� ������ + ���.������
        Stream.WriteBool(IsVisible);     // ��������� ������
        Stream.WriteBool(IsTop);         // ��� ������
        Stream.WriteInt(Params.pYStart); // ��� ������ �������
        Stream.WriteInt(Params.pMStart); // ����� ������ �������
        Stream.WriteInt(Params.pYEnd);   // ��� ��������� �������
        Stream.WriteInt(Params.pMEnd);   // ����� ��������� �������
        Stream.WriteInt(ModelOrderNum);  // ���������� �����
        Stream.WriteInt(SubCode);        // ����� TecDoc (����) / ��� ��� ����� (����)
        Inc(iCount);
      end;
      Stream.Position:= sPos;
      Stream.WriteInt(iCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//========================================= (+ Web) �������� ������ ����� ������
procedure prGetModelTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelTree'; // ��� ���������/�������
var UserID, FirmID, ModelID, SysID, i, j, spos: Integer;
    flNodesWithoutWares, flHideNodesWithOneChild, flHideOnlySameName,
      flHideOnlyOneLevel, flFromBase, fl: boolean;
    errmess: String;
    Model: TModelAuto;
    Node: TAutoTreeNode;
    link: TSecondLink;
    listParCodes, listNodes: TList;
begin
  Stream.Position:= 0;
  listParCodes:= nil;
  listNodes:= nil;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // ��� ������
    flNodesWithoutWares:= Stream.ReadBool; // ������� - ���������� ���� ��� �������

    flHideNodesWithOneChild:= not flNodesWithoutWares; // ����������� ���� � 1 ��������
    flHideOnlyOneLevel:= flHideNodesWithOneChild and Cache.HideOnlyOneLevel; // ����������� ������ 1 �������
    flHideOnlySameName:= flHideNodesWithOneChild and Cache.HideOnlySameName; // ����������� ������ ��� ���������� ����

    prSetThLogParams(ThreadData, csGetModelTree, UserId, FirmID, 'ModelID='+IntToStr(ModelID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    flFromBase:= not Cache.WareLinksUnLocked; // ���� ��� ������ �� �������� - ����� �� ����
    try // ������ ������ � �������� ������ ������
      listNodes:= Model.GetModelNodesList(True, flFromBase);

      if not flNodesWithoutWares then // ������ ���� ��� �������
        for i:= listNodes.Count-1 downto 0 do begin
          link:= listNodes[i];
          fl:= not link.NodeHasWares and not link.NodeHasPLs;
          if fl then listNodes.Delete(i);
        end;
      if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

      listParCodes:= TList.Create;
      listParCodes.Capacity:= listNodes.Count;
      for i:= 0 to listNodes.Count-1 do begin // ������ ����� ���������
        link:= listNodes[i];
        Node:= link.LinkPtr;
        listParCodes.Add(Pointer(Node.ParentID));
      end;

      if flHideNodesWithOneChild then  // ����������� ���� � 1-� ��������
        prHideTreeNodes(listNodes, listParCodes, flHideOnlySameName, flHideOnlyOneLevel);
      if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

      Stream.Clear;
      Stream.WriteInt(aeSuccess);  // ������ ������ ������ � �����
      Stream.WriteStr(Model.WebName);  // ������ �������� ������ � �����
      Stream.WriteBool(Model.ModelHasPLs); // ������� ������� ������ "������ MOTUL" � ������

      j:= 0; // ������� �����
      spos:= Stream.Position;
      Stream.WriteInt(j);
      for i:= 0 to listNodes.Count-1 do if Assigned(listNodes[i]) then begin
        link:= listNodes[i];
        Node:= link.LinkPtr;
        Stream.WriteInt(Node.ID);
        Stream.WriteInt(Integer(listParCodes[i]));
        Stream.WriteStr(Node.Name);
        Stream.WriteBool(link.IsLinkNode);
        if link.IsLinkNode then begin
          Stream.WriteDouble(link.Qty);
          Stream.WriteStr(Cache.GetMeasName(Node.MeasID));
          Stream.WriteBool(link.NodeHasFilters); // ������� ������� �������� � ���� ������
          Stream.WriteBool(link.NodeHasPLs);   // ������� ������� ������ "������ MOTUL" � ����
          Stream.WriteBool(link.NodeHasWares); // ������� ������� ������� ��������� ������� � ����
        end;
        inc(j);
      end;
      Stream.Position:= spos;
      Stream.WriteInt(j); // ���-�� ���������� ���������
    finally
      if flFromBase then for i:= 0 to listNodes.Count-1 do
        if Assigned(listNodes[i]) then TObject(listNodes[i]).Free;
      prFree(listNodes);
      prFree(listParCodes);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=========================================== ������� ��������� ������ �� ������
procedure ReadModelParams(Stream: TBoBMemoryStream; mps: TModelParams);
begin
  mps.pYStart:= Stream.ReadInt;       // ��� ������ �������
  mps.pMStart:= Stream.ReadInt;       // ����� ������ �������
  mps.pYEnd:= Stream.ReadInt;         // ��� ��������� �������
  mps.pMEnd:= Stream.ReadInt;         // ����� ��������� �������
  try // ���� �� ��� ������ ���� �������� � Stream
    mps.pKW      := Stream.ReadInt;   // �������� ���
    mps.pHP      := Stream.ReadInt;   // �������� ��
    mps.pCCM     := Stream.ReadInt;   // ���. ����� ���.��.
    mps.pCylinders:= Stream.ReadInt;  // ���������� ���������
    mps.pValves  := Stream.ReadInt;   // ���������� �������� �� ���� ������ ��������
    mps.pBodyID  := Stream.ReadInt;   // ���, ��� ������
    mps.pDriveID := Stream.ReadInt;   // ���, ��� �������
    mps.pEngTypeID:= Stream.ReadInt;  // ���, ��� ���������
    mps.pFuelID  := Stream.ReadInt;   // ���, ��� �������
    mps.pFuelSupID:= Stream.ReadInt;  // ���, ������� �������
    mps.pBrakeID := Stream.ReadInt;   // ���, ��� ��������� �������
    mps.pBrakeSysID:= Stream.ReadInt; // ���, ��������� �������
    mps.pCatalID := Stream.ReadInt;   // ���, ��� ������������
    mps.pTransID := Stream.ReadInt;   // ���, ��� ������� �������
  except
  end;
end;
//============================================== �������� ������ � ��������� ���
procedure prModelAddToModelLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelAddToModelLine'; // ��� ���������/�������
var UserID, MLineID, pModelID, SysID, pOrdNum, pTDcode: Integer;
    Top, isVis: Boolean;
    pName, errmess: String;
    ModelLine: TModelLine;
    mps: TModelParams;
begin
  Stream.Position:= 0;
  mps:= TModelParams.Create;
  try
    UserID:= Stream.ReadInt;
    MLineID:= Stream.ReadInt;  // ��� ���������� ����
    pName:= Stream.ReadStr;    // �������� ������

    prSetThLogParams(ThreadData, csModelAddToModelLine, UserId, 0, ' MLineID='+IntToStr(MLineID)+' pName='+pName);

    if (pName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidModelLine(MLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    Top      := Stream.ReadBool; // ���
    isVis    := Stream.ReadBool; // ���������
    ReadModelParams(Stream, mps);
    try
      pOrdNum:= Stream.ReadInt;    // ���������� �
    except
      pOrdNum:= -1;
    end;
    try
      pTDcode:= Stream.ReadInt;    // ����� TecDoc (����) / ��� ��� ����� (����)
    except
      pTDcode:= 0;
    end;
    if (pTDcode<0) then pTDcode:= 0;

    errmess:= Cache.FDCA.Models.ModelAdd(pModelID, pName, isVis, Top, UserID, MLineID, mps, pOrdNum, pTDcode);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(pModelID);   // ��� ������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(mps);
end;
//============================================================== �������� ������
procedure prModelEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelEdit'; // ��� ���������/�������
var UserID, ModelID, SysID, pOrdNum, pTDcode: Integer;
    Top, Visible: Boolean;
    pName, errmess: String;
    Model: TModelAuto;
    mps: TModelParams;
begin
  Stream.Position:= 0;
  mps:= TModelParams.Create;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // ��� ������
    pName:= Stream.ReadStr;    // �������� ������

    prSetThLogParams(ThreadData, csModelEdit, UserId, 0, 'ModelID='+IntToStr(ModelID)+', pName='+pName);

    if (pName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    Top      := Stream.ReadBool; // ���
    Visible  := Stream.ReadBool; // ���������
    ReadModelParams(Stream, mps);
    try
      pOrdNum:= Stream.ReadInt;    // ���������� �
    except
      pOrdNum:= -1;
    end;
    try
      pTDcode:= Stream.ReadInt;    // ����� TecDoc (����) / ��� ��� ����� (����)
    except
      pTDcode:= 0;
    end;
    if (pTDcode<0) then pTDcode:= 0;

    errmess:= Model.ModelEdit(pName, Visible, Top, UserID, mps, pOrdNum, pTDcode);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(mps);
end;
//=============================================================== ������� ������
procedure prModelDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelDel'; // ��� ���������/�������
var UserID, ModelID, SysID: Integer;
    errmess: String;
    Model: TModelAuto; // ��� ��������
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // ��� ������

    prSetThLogParams(ThreadData, csModelDel, UserId, 0, 'ModelID='+IntToStr(ModelID));

    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    errmess:= Cache.FDCA.Models.ModelDel(ModelID);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==================================================== �������� ��������� ������
procedure prModelSetVisible(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelSetVisible'; // ��� ���������/�������
var UserID, ModelID, SysID: Integer;
    Visible: Boolean;
    Model: TModelAuto;
    errmess: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // ��� ������
    Visible:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csModelSetVisible, UserId, 0, 'ModelID='+IntToStr(ModelID));

    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    errmess:= Model.SetModelVisible(Visible);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                                ������
//******************************************************************************
//=============================================== �������� ������ ������� TecDoc
procedure prGetBrandsTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBrandsTD'; // ��� ���������/�������
var UserID: Integer;
  lstBrand: TStringList;
begin
  Stream.Position:= 0;
  with Cache do try
    UserID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetBrandsTD, UserId);

    if not EmplExist(UserID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not arEmplInfo[UserId].UserRoleExists(rolManageBrands) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    lstBrand:= BrandTDList;
    if (lstBrand.Count<1) then raise EBOBError.Create('������ ������� TecDoc ����!');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    prSaveStrListWithIDToStream(lstBrand, Stream);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                                  �������������
//******************************************************************************
//========================== (+ Web) �������� ������ �������������� ����/�������
procedure prGetManufacturerList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetManufacturerList'; // ��� ���������/�������
var UserID, FirmID, SysID: Integer;
    errmess: String;
    OnlyVisible, OnlyWithWares: Boolean;
    lst: TStringList;
  //----------------------------------------
  procedure prSaveManufListToStream(pLst: TStringList; pTypeSys: Integer);
  var i, spos, icount: Integer;
  begin
    icount:= 0;
    spos:= Stream.Position;
    Stream.WriteInt(icount);
    for i:= 0 to pLst.Count-1 do with TManufacturer(pLst.Objects[i]) do begin
      if (OnlyVisible and not  // ���� ��� ������� �������
        (CheckIsVisible(pTypeSys) and HasVisMLModels(pTypeSys))) then Continue;
      if (OnlyWithWares and not ManufHasWares) then Continue; // ���� ��� �������
      Stream.WriteInt(ID);                            // ���
      Stream.WriteStr(Name);                          // ������������
      Stream.WriteBool(CheckIsTop(pTypeSys));         // ���
      Stream.WriteBool(CheckHasModelLines(pTypeSys)); // ������� ��������� ����� �� ������ �������
      Stream.WriteBool(CheckIsTypeSys(pTypeSys));
      Stream.WriteBool(CheckIsVisible(pTypeSys));
      inc(icount);
    end;
    Stream.Position:= spos;
    Stream.WriteInt(icount);
    Stream.Position:= Stream.Size;
  end;
  //----------------------------------------
begin                                  // �������� ������ �������������� SysID:
  lst:= nil;                           //  0 - ����
  Stream.Position:= 0;                 //  1 - ����
  OnlyVisible:= False;                 //  2 - ����
  try                                  // 11 - ����, ������� ������� ������
    FirmID:= Stream.ReadInt;           // 12 - ����, ������� ������� ������
    UserID:= Stream.ReadInt;           // 21 - � ����.��������
    SysID:= Stream.ReadInt;            // 31 - � �����������
    OnlyVisible:= Stream.ReadBool;     // False - ���, True - ������ �������
    OnlyWithWares:= OnlyVisible;       // False - ���, True - ������ � ��������

    prSetThLogParams(ThreadData, csGetManufacturerList, UserId, FirmID, 'SysID='+IntToStr(SysID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web ???

//if flDebugCV then SysID:= constIsCV;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    with Cache.FDCA.Manufacturers do case SysID of
      constIsAuto, constIsMoto, constIsCV, constIsAx:
        prSaveManufListToStream(GetSortedList(SysID), SysID);

      constIsAuto+10, constIsMoto+10:                 //, constIsCV+10, constIsAx+10 ???
        prSaveManufListToStream(GetSortedListWithTops(SysID-10), SysID-10);

      constIsAuto+20: begin
          lst:= Cache.FDCA.Manufacturers.GetOEManufList; // ������������� ������ �������������� � ��;
          prSaveStrListWithIDToStream(lst, Stream);
        end;

      constIsAuto+30: begin
          lst:= Cache.FDCA.Manufacturers.GetEngManufList;
          prSaveStrListWithIDToStream(lst, Stream);
        end;

    else prSaveManufListToStream(GetSortedList(SysID), 0);
    end; // case

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(lst);
end;
//======================================================= �������� �������������
procedure prManufacturerAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManufacturerAdd'; // ��� ���������/�������
var UserID, SysID, iCode: Integer;
    ManufName, errmess: String;
    isTop, isVis: boolean;
begin
  Stream.Position:= 0;
  iCode:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ManufName:= Stream.ReadStr; // ������������ �������������
    isTop := Stream.ReadBool; // ��� �������������
    isVis := Stream.ReadBool; // ���������

    prSetThLogParams(ThreadData, csManufacturerAdd, UserId, 0, 'SysID='+IntToStr(SysID)+', ManufName= '+ManufName);

    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    if (ManufName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if not CheckTypeSys(SysID) then errmess:= MessText(mtkNotFoundTypeSys, IntToStr(SysID));

    errmess:= Cache.FDCA.Manufacturers.ManufAdd(iCode, ManufName, SysID, UserID, isTop, isVis);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(iCode);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================== ������� �������������
procedure prManufacturerDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManufacturerDel'; // ��� ���������/�������
var UserID, SysID, ManufID: Integer;
    errmess: String;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ManufID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csManufacturerDel, UserId, 0, 'ManufID= '+IntToStr(ManufID)+#13#10'SysID='+IntToStr(SysID));

    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    errmess:= Cache.FDCA.Manufacturers.ManufDel(ManufID, SysID);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(ManufID);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================= �������� �������������
procedure prManufacturerEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManufacturerEdit'; // ��� ���������/�������
var UserID, SysID, ManufID: Integer;
    ManufName, errmess: String;
    isTop, isVis: boolean;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ManufID:= Stream.ReadInt;;
    SysID:= Stream.ReadInt;
    ManufName:= Stream.ReadStr; // ������������ �������������
    isTop := Stream.ReadBool; // ��� �������������
    isVis := Stream.ReadBool; // �������� �������������

    prSetThLogParams(ThreadData, csManufacturerEdit, UserId, 0, 'ManufID= '+
      IntToStr(ManufID)+', ManufName='+ManufName+#13#10'SysID='+IntToStr(SysID));

    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    errmess:= Cache.FDCA.Manufacturers.ManufEdit(ManufID, SysID, UserID, isTop, isVis, ManufName);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                                ������ �����
//******************************************************************************
//======================================================== �������� ������ �����
procedure prTNAGet(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNAGet'; // ��� ���������/�������
var UserID, SysID, FirmID, i, iCount, pos: Integer;
    errmess: String;
    Node: TAutoTreeNode;
begin
  Stream.Position:= 0;
  SysID:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csTNAGet, UserId, FirmID, 'SysID='+IntToStr(SysID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web
    if not CheckTypeSys(SysID) then
      raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);
    iCount:= 0;
    with Cache.FDCA.AutoTreeNodesSys[SysID].NodesList do begin // ������ ������ � �����
      for i:= 0 to Count-1 do if Assigned(Objects[i]) then begin
        Node:= TAutoTreeNode(Objects[i]);
        Stream.WriteInt(Node.ID);
        Stream.WriteInt(Node.ParentID);
        Stream.WriteStr(Node.Name);
        Stream.WriteStr(Node.NameSys);
        Stream.WriteBool(Node.Visible);
        Stream.WriteInt(Node.MainCode);
        Stream.WriteBool(Node.IsEnding);
        inc(iCount);
      end;
      if (iCount>0) then begin
        Stream.Position:= pos;
        Stream.WriteInt(iCount);
      end;
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'SysID='+IntToStr(SysID), True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'SysID='+IntToStr(SysID), False);
  end;
  Stream.Position:= 0;
end;
//======================================================= �������� ���� � ������
procedure prTNANodeAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANodeAdd'; // ��� ���������/�������
var UserID, ParentID, NodeID, SysID, Vis, NodeMain: Integer;
    NodeName, NodeNameSys, errmess: String;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ParentID:= Stream.ReadInt;           // ��� ��������
    NodeName:= Trim(Stream.ReadStr);     // ������������ ����
    NodeNameSys:= Trim(Stream.ReadStr);  // ��������� ������������ ����
    Vis:= Stream.ReadInt;
    NodeMain:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csTNANodeAdd, UserId, 0, 'NodeName= '+NodeName+
      ', NodeNameSys= '+NodeNameSys+', ParentID= '+IntToStr(ParentID)+#13#10'SysID='+IntToStr(SysID));

    if CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    NodeID:= -1;
    errmess:= Cache.FDCA.TreeNodeAdd(SysID, ParentID, NodeMain, NodeName, NodeNameSys, UserID, NodeID, Vis=1); // ���������� ����
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(NodeID);
    Stream.WriteStr(AnsiUpperCase(NodeNameSys));
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//================================================== ������������� ���� � ������
procedure prTNANodeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANodeEdit'; // ��� ���������/�������
var UserID, NodeID, SysID, Vis, NodeMain: Integer;
    NodeName, NodeNameSys, errmess: String;
    Nodes: TAutoTreeNodes;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    NodeName:= Trim(Stream.ReadStr);
    NodeNameSys:= Trim(Stream.ReadStr);
    Vis:= Stream.ReadInt;
    NodeMain:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csTNANodeEdit, UserId);

//    if not CheckTypeSys(SysID) then raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));
    if CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    Nodes:= Cache.FDCA.AutoTreeNodesSys[SysID];
    errmess:= Nodes.NodeEdit(NodeID, NodeMain, Vis, UserID, NodeName, NodeNameSys);
    if (errmess<>'') then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Nodes[NodeID].NameSys);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================= ������� ���� �� ������
procedure prTNANodeDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANodeDel'; // ��� ���������/�������
var UserID, NodeID, SysID: Integer;
    errmess: String;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csTNANodeDel, UserId);

//    if not CheckTypeSys(SysID) then raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));
    if CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    errmess:= Cache.FDCA.AutoTreeNodesSys[SysID].NodeDel(NodeID);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=================================================== ������ TStringList � �����
procedure prSaveStrListWithIDToStream(const pLst: TStringList; Stream: TBoBMemoryStream);
var i: Integer;
begin
  if not Assigned(pLst) then Exit;
  Stream.WriteInt(pLst.Count);
  for i:= 0 to pLst.Count-1 do begin
    Stream.WriteInt(Integer(pLst.Objects[i]));
    Stream.WriteStr(pLst[i]);
  end;
end;

//******************************************************************************
//                                ���������
//******************************************************************************
//=============================================== (+ Web) ������ ����� ���������
procedure prGetEngineTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetEngineTree'; // ��� ���������/�������
var UserID, FirmID, EngID, {SysID,} i, j, spos: Integer;
    flNodesWithoutWares, flHideNodesWithOneChild, flHideOnlySameName, flHideOnlyOneLevel: boolean;
    errmess: String;
    Eng: TEngine;
    Node: TAutoTreeNode;
    link: TSecondLink;
    listParCodes, listNodes: TList;
    nlinks: TLinks;
begin
  Stream.Position:= 0;
  listParCodes:= nil;
  listNodes:= nil;
  nlinks:= nil;
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    EngID:= Stream.ReadInt;  // ��� ���������
    flNodesWithoutWares:= Stream.ReadBool; // ������� - ���������� ���� ��� �������

    flHideNodesWithOneChild:= not flNodesWithoutWares; // ����������� ���� � 1 ��������
    flHideOnlyOneLevel:= flHideNodesWithOneChild and Cache.HideOnlyOneLevel; // ����������� ������ 1 �������
    flHideOnlySameName:= flHideNodesWithOneChild and Cache.HideOnlySameName; // ����������� ������ ��� ���������� ����

    prSetThLogParams(ThreadData, csGetEngineTree, UserId, FirmID, 'EngID='+IntToStr(EngID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    SysID:= constIsAuto;
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    if not Cache.FDCA.Engines.ItemExists(EngID) then
      raise EBOBError.Create(MessText(mtkNotFoundEngine, IntToStr(EngID)));

    Eng:= Cache.FDCA.Engines.GetEngine(EngID);
    if not Assigned(Eng) then
      raise EBOBError.Create(MessText(mtkNotFoundEngine, IntToStr(EngID)));

    nlinks:= Eng.GetNodesLinks;
    if nlinks.LinkCount<1 then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    listNodes:= TList.Create; // ������ ������ ��� ���������
    listNodes.Capacity:= nlinks.LinkCount;
    for i:= 0 to nlinks.LinkCount-1 do listNodes.Add(nlinks.ListLinks[i]);

    if not flNodesWithoutWares then // ������ ���� ��� �������
      for i:= listNodes.Count-1 downto 0 do begin
        link:= listNodes[i];
        if not link.NodeHasWares then listNodes.Delete(i);
      end;
    if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    listParCodes:= TList.Create;
    listParCodes.Capacity:= listNodes.Count;
    for i:= 0 to listNodes.Count-1 do begin // ������ ����� ���������
      link:= listNodes[i];
      Node:= link.LinkPtr;
      listParCodes.Add(Pointer(Node.ParentID));
    end;

    if flHideNodesWithOneChild then  // ����������� ���� � 1-� ��������
      prHideTreeNodes(listNodes, listParCodes, flHideOnlySameName, flHideOnlyOneLevel);
    if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);   //------------ ������ ������ ��������� � �����
    Stream.WriteStr(Eng.WebName); // ������ �������� ���������

    Stream.WriteBool(False); // �������� (������� ������� ������ "������ MOTUL" � ������)

    j:= 0; // ������� �����
    spos:= Stream.Position;
    Stream.WriteInt(j);
    for i:= 0 to listNodes.Count-1 do if Assigned(listNodes[i]) then begin
      link:= listNodes[i];
      Node:= link.LinkPtr;
      Stream.WriteInt(Node.ID);
      Stream.WriteInt(Integer(listParCodes[i]));
      Stream.WriteStr(Node.Name);
      Stream.WriteBool(link.IsLinkNode);
      if link.IsLinkNode then begin
        Stream.WriteDouble(link.Qty);
        Stream.WriteStr(Cache.GetMeasName(Node.MeasID));
        Stream.WriteBool(link.NodeHasFilters); // ������� ������� �������� � ���� ���������

        Stream.WriteBool(link.NodeHasPLs);   // �������� (������� ������� ������ "������ MOTUL" � ����)
        Stream.WriteBool(link.NodeHasWares); // �������� (������� ������� ������� ��������� ������� � ����)
      end;
      inc(j);
    end;
    Stream.Position:= spos;
    Stream.WriteInt(j); // ���-�� ���������� ���������
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  finally
    prFree(listNodes);
    prFree(listParCodes);
    prFree(nlinks);
  end;
  Stream.Position:= 0;
end;
//================================ ����������/������������� ����������� � WebArm
procedure prBlockActForWebUser(BlockKind, EmplID, UserID: integer; flFirm: Boolean;
                               reason: String; ThreadData: TThreadData);
const nmProc = 'prBlockActForWebUser'; // ��� ���������/�������
var FirmID, i, regMailKind: integer;
    errmess, s, regMail, sParam, txtlog, txtuser, unpref: String;
    WebUser: TClientInfo;
    WebFirm: TFirmInfo;
    Body: TStringList;
    Empl: TEmplInfoItem;
    BlockTime: TDateTime;
begin
  WebUser:= nil;
  WebFirm:= nil;
  Empl:= nil;
  FirmID:= isWe;
  regMailKind:= 0;
  try
    if not (BlockKind in [cbNotBlocked, cbBlockedByEmpl]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' BlockKind='+IntToStr(BlockKind));
    if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);

    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolManageSprav) then // ������ ������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    case BlockKind of
      cbBlockedByEmpl: begin
          txtlog:= ' blocked';
          unpref:= '';
          regMailKind:= pcEmpl_list_FinalBlock;
        end;
      cbNotBlocked   : begin
          txtlog:= ' unblocked';
          unpref:= '���';
          regMailKind:= pcEmpl_list_UnBlock;
        end;
    end;
    if (reason<>'') then reason:= #13#10'reason='+reason;

    if flFirm then begin  //----------------------------------------------- firm
      FirmID:= UserID;
      if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
      WebFirm:= Cache.arFirmInfo[FirmID];
      txtuser:= '����������';
      case BlockKind of
        cbBlockedByEmpl: if WebFirm.Blocked then raise EBOBError.Create(txtuser+' ����������');
        cbNotBlocked   : if not WebFirm.Blocked then raise EBOBError.Create(txtuser+' �� ����������');
      end;             // �������� ����� ���������� (��� GetUserSearchCount) ???
      sParam:= 'WebFirmID='+IntToStr(FirmID)+reason+#13#10'WebFirm '+IntToStr(FirmID)+txtlog;

    end else begin        //----------------------------------------------- user
      if not Cache.ClientExist(UserID) then raise EBOBError.Create(MessText(mtkNotClientExist));
      WebUser:= Cache.arClientInfo[UserID];
      FirmID:= WebUser.FirmID;
      if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
      WebFirm:= Cache.arFirmInfo[FirmID];
      txtuser:= '������';
      case BlockKind of
        cbBlockedByEmpl: if WebUser.Blocked then raise EBOBError.Create(txtuser+' ����������');
        cbNotBlocked   : if not WebUser.Blocked then raise EBOBError.Create(txtuser+' �� ����������');
      end;             // �������� ����� ���������� (��� GetUserSearchCount) ???
      sParam:= 'WebUserID='+IntToStr(UserID)+reason+#13#10'WebUser '+IntToStr(UserID)+txtlog;

      if not SaveClientBlockType(cbBlockedByEmpl, UserID, BlockTime, EmplID) then // ���������� ������� � ����
        raise EBOBError.Create('������ ���������� '+txtuser+'�');

      with WebUser do try // � ����
        CS_client.Enter;
        Blocked:= True;
        CountSearch:= 0;
        CountQty:= 0;
        CountConnect:= 0;
      finally
        CS_client.Leave;
      end;
    end;

  finally
    prSetThLogParams(ThreadData, 0, EmplID, 0, sParam);
  end;

//------------------------------- ��������� ��������� � ����������/�������������
  Body:= TStringList.Create;
  with Cache do try    //---------------------------------- �� ������ ��������
    regMail:= '';
    Body.Add(FormatDateTime(cDateTimeFormatY4S, Now())+' � ��� '+unpref+'����������');
    Body.Add('  ����������� '+empl.EmplShortName);
    if not flFirm then
      Body.Add('  ������ � ������� `'+WebUser.Login+'` (��� '+IntToStr(WebUser.ID)+')');
    Body.Add('  ���������� '+WebFirm.Name+' (��� '+IntToStr(WebFirm.ID)+')');
    if (reason<>'') then Body.Add('�������: '+reason);
    s:= WebFirm.GetFirmManagersString([fmpName, fmpShort, fmpPref]);
    if (s<>'') then Body.Add('  '+s);

    regMail:= Cache.GetConstEmails(regMailKind, errmess, FirmID);
    if (regMail='') then // � s ���������� ������ � ������ ��������
      s:= '��������� � '+unpref+'���������� '+txtuser+'� �� ���������� - �� ������� E-mail ��������'
    else begin
      s:= n_SysMailSend(regMail, unpref+'���������� '+txtuser+'�', Body, nil, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // ���� �� ���������� � ����
        fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', '������ ��������', s, '');
        s:= '������ �������� ��������� � '+unpref+'���������� '+txtuser+'� �� Email: '+regMail;
      end else s:= '��������� � '+unpref+'���������� '+txtuser+'� ���������� �� Email: '+regMail;
    end;
                             //-------------------------- ��������
    if (s<>'') then Body.Add(#10+s);
    if (errmess<>'') then Body.Add(#10+errmess); // ��������� � ����������� �������

    regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
    if (errmess<>'') then Body.Add(errmess);

    if (regMail='') then regMail:= GetSysTypeMail(constIsAuto); // �� ����.������

    if (regMail<>'') then begin
      s:= n_SysMailSend(regMail, unpref+'���������� '+txtuser+'�', Body, nil, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
        prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
    end;

    prMessageLOGS(nmProc+': '+unpref+'���������� '+txtuser+'�');  // ����� � ���
    for i:= 0 to Body.Count-1 do if (trim(Body[i])<>'') then
      prMessageLOGS(StringReplace(Body[i], #10, '', [rfReplaceAll]));
  except
    on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, '������ ��������', E.Message, '');
  end;
  prFree(Body);
end;

//=========================================================== ���������� �������
procedure prBlockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prBlockWebUser'; // ��� ���������/�������
var EmplID, FirmID, UserID, i: integer;
    errmess, s, regMail, sParam,  reason: String;
    WebUser: TClientInfo;
    Body: TStringList;
    Empl: TEmplInfoItem;
    BlockTime: TDateTime;
begin
  Stream.Position:= 0;
  WebUser:= nil;
  Empl:= nil;
  try
    FirmID:= isWe;
    EmplID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    reason:= trim(Stream.ReadStr);

    sParam:= 'WebUserID='+IntToStr(UserID)+#13#10'reason='+reason;
    try
      if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);
      if not Cache.ClientExist(UserID) then raise EBOBError.Create(MessText(mtkNotClientExist));

      WebUser:= Cache.arClientInfo[UserID];
      FirmID:= WebUser.FirmID;

      if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));

      empl:= Cache.arEmplInfo[EmplID];
      if not empl.UserRoleExists(rolManageSprav) then // ������ ������
        raise EBOBError.Create(MessText(mtkNotRightExists));

      if WebUser.Blocked then raise EBOBError.Create('������������ ����������');

      if not SaveClientBlockType(cbBlockedByEmpl, UserID, BlockTime, EmplID) then // ���������� ������� � ����
        raise EBOBError.Create('������ ���������� �������');
                      // �������� ����� ���������� (��� GetUserSearchCount) ???
      sParam:= sParam+#13#10'WebUser '+IntToStr(UserID)+' blocked';
    finally
      prSetThLogParams(ThreadData, 0, EmplID, 0, sParam);
    end;

    with WebUser do try // � ����
      CS_client.Enter;
      Blocked:= True;
      CountSearch:= 0;
      CountQty:= 0;
      CountConnect:= 0;
    finally
      CS_client.Leave;
    end;

//------------------------------------------ ��������� ��������� � ����������
    Body:= TStringList.Create;
    with Cache do try    //---------------------------------- �� ������ ��������
      regMail:= '';
      Body.Add(FormatDateTime(cDateTimeFormatY4S, Now())+' �����������');
      Body.Add('  ����������� '+empl.EmplShortName);
      Body.Add('  ������� ������ � ������� �������');
      Body.Add('������������ � ������� `'+WebUser.Login+'` (��� '+IntToStr(WebUser.ID)+')');
      Body.Add('  ���������� '+WebUser.FirmName);
      if (reason<>'') then Body.Add('�������: '+reason);
      if FirmExist(FirmID) then begin
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
        if (s<>'') then Body.Add('  '+s);
      end;

      regMail:= Cache.GetConstEmails(pcEmpl_list_UnBlock, errmess, FirmID);
      if (regMail='') then // � s ���������� ������ � ������ ��������
        s:= '��������� � ���������� ������� �� ���������� - �� ������� E-mail ��������'
      else begin
        s:= n_SysMailSend(regMail, '���������� ������� ������ ������������', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // ���� �� ���������� � ����
          fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', '������ ��������', s, '');
          s:= '������ �������� ��������� � ���������� ������� �� Email: '+regMail;
        end else s:= '��������� � ���������� ������� ���������� �� Email: '+regMail;
      end;
                               //-------------------------- �������� (���������)
      if (s<>'') then Body.Add(#10+s);
      if (errmess<>'') then Body.Add(#10+errmess); // ��������� � ����������� �������

      regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
      if (errmess<>'') then Body.Add(errmess);

      if (regMail='') then regMail:= GetSysTypeMail(constIsAuto); // ��������� (�� ����.������)

      if (regMail<>'') then begin
        s:= n_SysMailSend(regMail, '���������� ������� ������ ������������', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
          prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
      end;

      prMessageLOGS(nmProc+': ���������� �������');  // ����� � ���
      for i:= 0 to Body.Count-1 do if (trim(Body[i])<>'') then
        prMessageLOGS(StringReplace(Body[i], #10, '', [rfReplaceAll]));
    except
      on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, '������ ��������', E.Message, '');
    end;
    prFree(Body);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================== ������������� �������
procedure prUnblockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prUnblockWebUser'; // ��� ���������/�������
var EmplID, FirmID, UserID, i: integer;
    errmess, s, regMail, sParam: String;
    WebUser: TClientInfo;
    Body: TStringList;
    Empl: TEmplInfoItem;
    BlockTime: TDateTime;
begin
  Stream.Position:= 0;
  WebUser:= nil;
  Empl:= nil;
  try
    FirmID:= isWe;
    EmplID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    sParam:= 'WebUserID='+IntToStr(UserID);
    try
      if CheckNotValidUser(EmplID, FirmID, errmess) then
        raise EBOBError.Create(errmess);
      if not Cache.ClientExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotClientExist));

      WebUser:= Cache.arClientInfo[UserID];
      FirmID:= WebUser.FirmID;

      if not Cache.FirmExist(FirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));

      empl:= Cache.arEmplInfo[EmplID];
      if not empl.UserRoleExists(rolManageSprav) then // ������ ������
        raise EBOBError.Create(MessText(mtkNotRightExists));

      if not WebUser.Blocked then
        raise EBOBError.Create('������������ �� ����������');
                                                 // ������������� ������� � ����
      if not SaveClientBlockType(cbUnBlockedByEmpl, UserID, BlockTime, EmplID) then
        raise EBOBError.Create('������ ������������� �������');
                      // �������� ����� ������������� (��� GetUserSearchCount) ???
      sParam:= sParam+#13#10'WebUser '+IntToStr(UserID)+' unblocked';
    finally
      prSetThLogParams(ThreadData, csUnblockWebUser, EmplID, 0, sParam);
    end;

    with WebUser do try // � ����
      CS_client.Enter;
      Blocked:= False;
      CountSearch:= 0;
      CountQty:= 0;
      CountConnect:= 0;
    finally
      CS_client.Leave;
    end;

//------------------------------------------ ��������� ��������� � �������������
    Body:= TStringList.Create;
    with Cache do try    //---------------------------------- �� ������ ��������
      regMail:= '';
      Body.Add(FormatDateTime(cDateTimeFormatY4S, Now())+' ��������������');
      Body.Add('  ����������� '+empl.EmplShortName);
      Body.Add('  ������� ������ � ������� �������');
      Body.Add('������������ � ������� `'+WebUser.Login+'` (��� '+IntToStr(WebUser.ID)+')');
      Body.Add('  ���������� '+WebUser.FirmName);
      if FirmExist(FirmID) then begin
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
        if (s<>'') then Body.Add('  '+s);
      end;

      regMail:= Cache.GetConstEmails(pcEmpl_list_UnBlock, errmess, FirmID);
      if (regMail='') then // � s ���������� ������ � ������ ��������
        s:= '��������� � ������������� ������� �� ���������� - �� ������� E-mail ��������'
      else begin
        s:= n_SysMailSend(regMail, '������������� ������� ������ ������������', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // ���� �� ���������� � ����
          fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', '������ ��������', s, '');
          s:= '������ �������� ��������� � ������������� ������� �� Email: '+regMail;
        end else s:= '��������� � ������������� ������� ���������� �� Email: '+regMail;
      end;
                               //-------------------------- �������� (���������)
      if (s<>'') then Body.Add(#10+s);
      if (errmess<>'') then Body.Add(#10+errmess); // ��������� � ����������� �������

      regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
      if (errmess<>'') then Body.Add(errmess);

      if regMail='' then regMail:= GetSysTypeMail(constIsAuto); // ��������� (�� ����.������)

      if (regMail<>'') then begin
        s:= n_SysMailSend(regMail, '������������� ������� ������ ������������', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
          prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
      end;

      prMessageLOGS(nmProc+': ������������� �������');  // ����� � ���
      for i:= 0 to Body.Count-1 do if (trim(Body[i])<>'') then
        prMessageLOGS(StringReplace(Body[i], #10, '', [rfReplaceAll]));
    except
      on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, '������ ��������', E.Message, '');
    end;
    prFree(Body);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==== ������������ ��� ���������� �������� ���� TSearchWareOrOnum � TObjectList
function SearchWareOrONSortCompare(Item1, Item2: Pointer): Integer;
var sw1, sw2: TSearchWareOrOnum;
    s1, s2: String;
    ware1, ware2: TWareInfo;
begin
  try
    sw1:= TSearchWareOrOnum(Item1);
    sw2:= TSearchWareOrOnum(Item2);
    if (sw1.IsWare<>sw2.IsWare) then begin // ������ - ���� ��
      if sw1.IsWare then Result:= -1 else Result:= 1;

    end else if (sw1.RestSem<>sw2.RestSem) then begin // � ��������� - ����

      if (sw1.RestSem=3) and (sw2.RestSem=2) then Result:= 1       // 3 ���� 2
      else if (sw1.RestSem=2) and (sw2.RestSem=3) then Result:= -1 // 3 ���� 2
      else if (sw1.RestSem>sw2.RestSem) then Result:= -1 else Result:= 1;

    end else begin // �� ������������
      if sw1.IsWare then begin // �����
        ware1:= Cache.GetWare(sw1.ID, True);
        ware2:= Cache.GetWare(sw2.ID, True);
        if (ware1.TopRating<>ware2.TopRating) then begin // �� ��������
          if (ware1.TopRating=0) then Result:= 1
          else if (ware2.TopRating=0) then Result:= -1
          else if (ware1.TopRating>ware2.TopRating) then Result:= 1 else Result:= -1;
        end else begin  // �� ������������
          s1:= ware1.Name;
          s2:= ware2.Name;
          Result:= AnsiCompareText(s1, s2);
        end;
      end else begin // ��
        s1:= Cache.FDCA.GetOriginalNum(sw1.ID).Name;
        s2:= Cache.FDCA.GetOriginalNum(sw2.ID).Name;
        Result:= AnsiCompareText(s1, s2);
      end;
    end;
  except
    Result:= 0;
  end;
end;
//============ ������������ ��� ���������� �������� ���� TTwoCodes � TObjectList
function SearchWareAnalogsSortCompare(Item1, Item2: Pointer): Integer;
var tt1, tt2: TTwoCodes;
    s1, s2: String;
    ware1, ware2: TWareInfo;
begin
  try
    tt1:= TTwoCodes(Item1);
    tt2:= TTwoCodes(Item2);
    if (tt1.ID2<>tt2.ID2) then begin // � ��������� - ����

      if (tt1.ID2=3) and (tt2.ID2=2) then Result:= 1       // 3 ���� 2
      else if (tt1.ID2=2) and (tt2.ID2=3) then Result:= -1 // 3 ���� 2
      else if (tt1.ID2>tt2.ID2) then Result:= -1 else Result:= 1;

    end else begin
      ware1:= Cache.GetWare(tt1.ID1, True);
      ware2:= Cache.GetWare(tt2.ID1, True);
      if (ware1.TopRating<>ware2.TopRating) then begin // �� ��������
        if (ware1.TopRating=0) then Result:= 1
        else if (ware2.TopRating=0) then Result:= -1
        else if (ware1.TopRating>ware2.TopRating) then Result:= 1 else Result:= -1;
      end else begin  // �� ������������
        s1:= ware1.Name;
        s2:= ware2.Name;
        Result:= AnsiCompareText(s1, s2);
      end;
    end;
  except
    Result:= 0;
  end;
end;
//================================== ������ ������������� ������� (Web & WebArm)
procedure prGetWareSatellites(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareSatellites'; // ��� ���������/�������
var UserID, FirmID, WareID, currID, ForFirmID, i, contID, Rests: integer;
    wCodes: Tai;
    PriceInUah, flSemafores: boolean;
    OLmarkets: TObjectList;
    tc: TTwoCodes;
    ffp: TForFirmParams;
    ware: TWareInfo;
begin
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  OLmarkets:= TObjectList.Create;
  ffp:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    PriceInUah:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csGetSatellites, UserID, FirmID, 'WareID='+IntToStr(WareID)+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // �����������

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    wCodes:= Cache.GetWare(WareID).GetSatellites;
    for i:= 0 to High(wCodes) do begin
      if not Cache.WareExist(wCodes[i]) then Continue;
      ware:= Cache.GetWare(wCodes[i]);
      if not ware.IsPrize and ware.IsMarketWare(ffp) then
        OLmarkets.Add(TTwoCodes.Create(wCodes[i], 0));
    end;

    flSemafores:= ((ffp.FirmID<>IsWe) or (ffp.ForFirmID>0)) and (OLmarkets.Count>0);
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, Rests); // ���������
      if (Rests>0) and (OLmarkets.Count>1) then
        OLmarkets.Sort(SearchWareAnalogsSortCompare);
    end;
    Rests:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(OLmarkets.Count); // ���-�� ����� �������
    for i:= 0 to OLmarkets.Count-1 do begin
      tc:= TTwoCodes(OLmarkets[i]);
      if flSemafores then Rests:= tc.ID2;
      prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, Rests);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  prFree(OLmarkets);
  prFree(ffp);
end;
//===================================================== ������ �������� (WebArm)
procedure prGetWareAnalogs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareAnalogs'; // ��� ���������/�������
var i, UserId, WareID, WhatShow, FirmID, currID, ForFirmID, contID, Rests: integer;
    wCodes: Tai;
    PriceInUah, flSemafores: boolean;
    OLmarkets: TObjectList;
    tc: TTwoCodes;
    ffp: TForFirmParams;
    ware: TWareInfo;
begin
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  OLmarkets:= TObjectList.Create;
  ffp:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    PriceInUah:= Stream.ReadBool;
    WhatShow:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csWebArmGetAnalogs, UserId, FirmID,
      'WareID='+IntToStr(WareID)+#13#10'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'WhatShow='+IntToStr(WhatShow)+#13#10'ContID='+IntToStr(ContID)); // �����������
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������

    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    if (WhatShow=constThisIsOrNum) then begin
      if not Cache.FDCA.OrigNumExist(WareID) then
        raise EBOBError.Create(MessText(mtkNotFoundOrNum));
      wCodes:= Cache.FDCA.arOriginalNumInfo[WareID].arAnalogs;

    end else begin
      if not Cache.WareExist(WareID) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
      wCodes:= fnGetAllAnalogs(WareID);
    end;

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    for i:= 0 to High(wCodes) do begin
      if not Cache.WareExist(wCodes[i]) then Continue;
      ware:= Cache.GetWare(wCodes[i]);
      if not ware.IsPrize and ware.IsMarketWare(ffp) then
        OLmarkets.Add(TTwoCodes.Create(wCodes[i], 0));
    end;

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0);
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, Rests); // ���������
      if (Rests>0) and (OLmarkets.Count>1) then
        OLmarkets.Sort(SearchWareAnalogsSortCompare);
    end;
    Rests:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(OLmarkets.Count); // ���-�� ����� ��������
    for i:= 0 to OLmarkets.Count-1 do begin
      tc:= TTwoCodes(OLmarkets[i]);
      if flSemafores then Rests:= tc.ID2;
      prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, Rests);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  prFree(OLmarkets);
  prFree(ffp);
end;
//======================================================= ����� ������� (WebArm)
procedure prCommonWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonWareSearch'; // ��� ���������/�������
var Template, s, InnerErrorPos, sParam, sTypes: string;
    UserId, FirmID, currID, ForFirmID, i, j, arlen,
      CountAll, CountWares, CountON, contID, Rests: integer;
    IgnoreSpec: byte;
    ShowAnalogs, NeedGroups, NotWasGroups, PriceInUah,
      flSale, flCutPrice, flLamp, flSpecSearch, flSemafores: boolean;
    aiOrNums, aiWareByON, TypesI, TypesIon, arTotalWares: Tai;
    TypesS: Tas;
    OrigNum: TOriginalNumInfo;
    OList, WList, ONlist, OLmarkets: TObjectList;
    WA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ffp: TForFirmParams;
    lst: TStringList;
begin
  Stream.Position:= 0;
  WList:= nil;
  SetLength(aiOrNums, 0);
  SetLength(TypesI, 0);
  SetLength(TypesIon, 0);
  SetLength(TypesS, 0);
  SetLength(arTotalWares, 0);
  SetLength(aiWareByON, 0);
  OList:= TObjectList.Create;
  ONlist:= TObjectList.Create;
  OLmarkets:= TObjectList.Create;
  flSale:= False;
  flCutPrice:= False;
  flLamp:= False;
  CountON:= 0;
  CountWares:= 0;
  ffp:= nil;
  lst:= TStringList.Create;
  try try
InnerErrorPos:='0';
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    Template:= Stream.ReadStr;
    Template:= trim(Template);
    IgnoreSpec:= Stream.ReadByte;
    PriceInUah:= Stream.ReadBool;
          // ����������� � ib_css - ������ �� �������, �������������� � ���� !!!
    sParam:= 'ContID='+IntToStr(ContID)+#13#10'Template='+Template+
      #13#10'IgnoreSpec='+IntToStr(IgnoreSpec)+#13#10'ForFirmID='+IntToStr(ForFirmID);
    try
      if (Length(Template)<1) then raise EBOBError.Create('�� ����� ������ ������');
                 // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
      prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
//      if (FirmId<>IsWe) and (ForFirmID<1) then ForFirmID:= FirmID;

      if (FirmId<>IsWe) and Cache.arFirmInfo[FirmId].IsFinalClient then IgnoreSpec:= 2;

      flLamp:= (IgnoreSpec=coLampBaseIgnoreSpec);  // ����� �� ������
      if flLamp then  // ��������� � �������� ���� ������ ����� � �.�.
        sTypes:= Cache.GetConstItem(pcWareTypeLampCodes).StrValue
      else
        sTypes:= Stream.ReadStr; // �������� �������� ����� �������, ��������� �������������

//------------------------------------------------------------- ����.���� ������
      if flLamp then IgnoreSpec:= 0 // �������� ������� ����
      else begin
        s:= AnsiUpperCase(Template);
        flSale    := (s=cTemplateSale);        // ����������
        flCutPrice:= (s=cTemplateCutPrice);    // ������
        if not (IgnoreSpec in [1, 2]) then IgnoreSpec:= 0; // ���� IgnoreSpec=3 �� ��������
      end;
      flSpecSearch:= (flSale or flCutPrice or flLamp); // ������� ����.������
//-------------------------------------------------------------
InnerErrorPos:='1';
      if (sTypes<>'') then begin
        TypesS:= fnSplitString(sTypes, ',');
        SetLength(TypesI, Length(TypesS));
        if not flSpecSearch then SetLength(TypesIon, Length(TypesS));
        arlen:= 0;
        for i:= 0 to High(TypesS) do begin
          j:= StrToIntDef(TypesS[i], -1);
          if (j<0) then Continue;
          TypesI[arlen]:= j;
          if not flSpecSearch then TypesIon[arlen]:= j;
          Inc(arlen);
        end;
        if (Length(TypesI)>arlen) then SetLength(TypesI, arlen);
        if not flSpecSearch and (Length(TypesIon)>arlen) then SetLength(TypesIon, arlen);
      end;
      NotWasGroups:= (Length(TypesI)=0); // ����������, ������������ �� ������, �.�. ������ ���������������
InnerErrorPos:='2';
//------------------------------------------------------------- ���������� �����
      WList:= SearchWaresTypesAnalogs(Template, TypesI, IgnoreSpec, -1,
                                      false, true, flSale, flCutPrice, flLamp);
      CountWares:= WList.Count;
InnerErrorPos:='3';
      if not flSpecSearch then begin  // ������ ��� �������� ������
        aiOrNums:= Cache.FDCA.SearchWareOrigNums(Template, IgnoreSpec, True, TypesIon);
        CountON:= Length(aiOrNums);
        ONlist.Capacity:= CountON;
        for i:= 0 to High(aiOrNums) do begin
          OrigNum:= Cache.FDCA.arOriginalNumInfo[aiOrNums[i]];
          aiWareByON:= OrigNum.arAnalogs;
          ONlist.Add(TSearchWareOrOnum.Create(OrigNum.ID, 0, False, False, aiWareByON));
          SetLength(aiWareByON, 0);
        end;
      end;
      sParam:= sParam+#13#10'WareQty='+IntToStr(CountWares)+#13#10'OEQty='+IntToStr(CountON);
    finally
      prSetThLogParams(ThreadData, csSearchWithOrNums, UserID, FirmID, sParam); // �����������
    end;

    CountAll:= CountON+CountWares;
    if (CountAll<1) then begin
      s:= '�� ������� ';
      if flSale then s:= s+'������ ����������'                      // ����� �� ����������
      else if flCutPrice then s:= s+'��������� ������'              // ����� �� ������
      else if flLamp then s:= s+'����� � ����������� '+Template     // ����� �� ������
      else s:= s+'������/������������ ������ �� ������� '+Template; // ����� �� �������
      raise EBOBError.Create(s);
    end;
//------------------------------------------------------------------------
InnerErrorPos:='4';
    NeedGroups:= NotWasGroups and (CountAll>Cache.GetConstItem(pcSearchCountTypeAsk).IntValue);
    if NeedGroups then begin
      lst.Capacity:= lst.Capacity+Length(TypesI)+Length(TypesIon);
      for i:= 0 to High(TypesI) do begin
        j:= TypesI[i];
        if FindWareType(lst, j) then Continue;
        prAddWareType(lst, j, Cache.GetWareTypeName(j));
      end;
      for i:= 0 to High(TypesIon) do begin
        j:= TypesIon[i];
        if FindWareType(lst, j) then Continue;
        prAddWareType(lst, j, Cache.GetWareTypeName(j));
      end;
    end;
    NeedGroups:= NeedGroups and (lst.Count>1);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteBool(NeedGroups);
//-------------------------------------------------------------- �������� ������
    if NeedGroups then begin
InnerErrorPos:='5';
      lst.CustomSort(TypeNamesSortCompare);

      Stream.WriteInt(CountAll);
      Stream.WriteInt(lst.Count);
      for I:= 0 to lst.Count-1 do begin
        j:= Integer(lst.Objects[i]);
        Stream.WriteInt(j);
        Stream.WriteStr(lst[i]);
      end;
      Exit; // �������
    end;

//------------------------------------------------ ������� ������ ��� ����������
InnerErrorPos:='6';
    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    ShowAnalogs:= ffp.ForClient and (CountAll<Cache.arClientInfo[ffp.UserID].MaxRowShowAnalogs);
    flSemafores:= (ffp.ForClient or (ForFirmID>0));
    OLmarkets.Capacity:= WList.Count;
    //---------- �������� ���� ��������� ������� ��� ��������� � ������� �������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if (WA.RestSem>-1) then // 1-� ��� ����������� � SearchWaresTypesAnalogs
        if Cache.GetWare(WA.ID).IsMarketWare(ffp) then begin
          WA.RestSem:= 0;         // default - ������� ����������
          fnFindOrAddTwoCode(OLmarkets, WA.ID); // ���� ��������� �������
        end else WA.RestSem:= -1; // ����������� �����

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
          tc.ID2:= 0;           // default - ������� ����������
          fnFindOrAddTwoCode(OLmarkets, tc.ID1); // ���� ��������� �������
        end else tc.ID2:= -1;
      end;
    end; // for i:= 0 to WList.Count

    if flSemafores then // ��� ���������� �� ��������� - ������� ��
      for i:= 0 to ONlist.Count-1 do begin
        WA:= TSearchWareOrOnum(ONlist[i]);
        for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
          tc:= TTwoCodes(WA.OLAnalogs[j]);
          if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
            tc.ID2:= 0;         // default - ������� ����������
            fnFindOrAddTwoCode(OLmarkets, tc.ID1); // ���� ��������� �������
          end else tc.ID2:= -1;
        end;
      end;

    flSemafores:= flSemafores and (OLmarkets.Count>0); // ���� �������� ��������� �������
    //--------------------------------------------------------- �������� �������
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, Rests); // ���������
      if (Rests>0) then begin
        for i:= 0 to WList.Count-1 do begin    // ����������� �������� � �������
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count

        for i:= 0 to ONlist.Count-1 do begin    // ����������� �������� � ��
          WA:= TSearchWareOrOnum(ONlist[i]);
          for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2<0) then Continue;
            tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
            if (tc.ID2>0) then begin
              if (WA.RestSem<tc.ID2) then WA.RestSem:= tc.ID2; // � �������� ���� ������� ???
              if not ShowAnalogs and (WA.RestSem=2) then break;
            end;
          end;
          if ShowAnalogs and (WA.OLAnalogs.Count>1) then
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to ONlist.Count
      end; // if (RestWares.Count>0)
    end; // if flSemafores

//-------------------------------------------------------- ��������� ������ / ��
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare);
    if (ONlist.Count>1) then ONlist.Sort(SearchWareOrONSortCompare);

//-------------------------------------------------------------- �������� ������
    Rests:= -1;
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);   // �������� ������
    for i:= 0 to WList.Count-1 do begin
InnerErrorPos:='7-'+IntToStr(i);
      WA:= TSearchWareOrOnum(WList[i]);
      if flSemafores then Rests:= WA.RestSem;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, WA.OLAnalogs.Count, WA.SatCount, Rests);

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if flSemafores then Rests:= tc.ID2;
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, Rests);
      end;
    end; // for i:= 0 to CountWares

    Stream.WriteInt(ONlist.Count);  // �������� ������������ ������
    for i:= 0 to ONlist.Count-1 do begin
InnerErrorPos:='8-'+IntToStr(i);
      WA:= TSearchWareOrOnum(ONlist[i]);
      OrigNum:= Cache.FDCA.arOriginalNumInfo[WA.ID];
      Stream.WriteInt(OrigNum.ID);
      Stream.WriteInt(OrigNum.MfAutoID);
      Stream.WriteStr(OrigNum.ManufName);
      Stream.WriteStr(OrigNum.OriginalNum);
      Stream.WriteStr(OrigNum.CommentWWW);

      if not ShowAnalogs then Continue;

      Stream.WriteInt(WA.OLAnalogs.Count); // ���-�� ��������
      for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if flSemafores then Rests:= tc.ID2;
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, Rests);
      end;
    end; // for i:= 0 to ONlist.Count
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
                                         'InnerErrorPos='+InnerErrorPos, False);
  end;
  finally
    Stream.Position:= 0;
    SetLength(aiOrNums, 0);
    SetLength(aiWareByON, 0);
    SetLength(arTotalWares, 0);
    SetLength(TypesI, 0);
    SetLength(TypesIon, 0);
    SetLength(TypesS, 0);
    prFree(OList);
    prFree(WList);
    prFree(ONlist);
    prFree(OLmarkets);
    prFree(ffp);
    prFree(lst);
  end;
end;
//======================================================== ������ �������� (Web)
procedure prGetWareAnalogs_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareAnalogs_new'; // ��� ���������/�������
var i, UserId, WareID, WhatShow, FirmID, currID, ForFirmID, contID, sem: integer;
    wCodes: Tai;
    PriceInUah, flSemafores: boolean;
    OLmarkets: TObjectList;
    tc: TTwoCodes;
    ffp: TForFirmParams;
    ware: TWareInfo;
    sArrive: String;
begin
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  OLmarkets:= TObjectList.Create;
  ffp:= nil;
  ware:= NoWare;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    PriceInUah:= Stream.ReadBool;
    WhatShow:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csWebArmGetAnalogs, UserId, FirmID,
      'WareID='+IntToStr(WareID)+#13#10'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'WhatShow='+IntToStr(WhatShow)+#13#10'ContID='+IntToStr(ContID)); // �����������
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������

    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    if WhatShow=constThisIsOrNum then begin
      if not Cache.FDCA.OrigNumExist(WareID) then
        raise EBOBError.Create(MessText(mtkNotFoundOrNum));
      wCodes:= Cache.FDCA.arOriginalNumInfo[WareID].arAnalogs;

    end else begin
      if not Cache.WareExist(WareID) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
      wCodes:= Cache.GetWare(WareID, True).Analogs;
    end;

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
    flSemafores:= ffp.NeedSemafores;
    if flSemafores then ffp.FillStores;

    for i:= 0 to High(wCodes) do begin
      if not Cache.WareExist(wCodes[i]) then Continue;
      ware:= Cache.GetWare(wCodes[i]);
      if ware.IsPrize or not ware.IsMarketWare(ffp) then Continue;

      if flSemafores then begin
        sem:= GetContWareRestsSem(ware.ID, ffp, sArrive);
        if ffp.HideZeroRests and (sem<1) then Continue;
      end else begin
        sem:= -1;
        sArrive:= '';
      end;

      OLmarkets.Add(TTwoCodes.Create(ware.ID, sem, 0, sArrive));
    end;
    if flSemafores and (OLmarkets.Count>1) then
      OLmarkets.Sort(SearchWareAnalogsSortCompare);

    if (OLmarkets.Count<1) then raise EBOBError.Create(
      MessText(mtkNotFoundWaresSem)+' - ������� '+ware.Name);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(OLmarkets.Count); // ���-�� ����� ��������
    for i:= 0 to OLmarkets.Count-1 do begin
      tc:= TTwoCodes(OLmarkets[i]);
      prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, tc.ID2, tc.Name);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  prFree(OLmarkets);
  prFree(ffp);
end;
//=================================== ����� ������� �� ��������� ��������� (Web)
procedure prCommonSearchWaresByAttr_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonSearchWaresByAttr_new'; // ��� ���������/�������
var UserID, FirmID, i, ForFirmID, CurrID, aCount, contID, grpID, ii, sem: Integer;
    attCodes, valCodes, aar: Tai;
    PriceInUAH, flSemafores, flMarket, flGBatt: boolean;
    WList, OLmarkets: TObjectList;
    WA: TSearchWareOrOnum;
    ware: TWareInfo;
    ffp: TForFirmParams;
    sArrive: String;
begin
  Stream.Position:= 0;
  currID:= 0;
  WList:= TObjectList.Create;
  OLmarkets:= TObjectList.Create;
  ffp:= nil;
  grpID:= 0;
  flGBatt:= False;
  contID:= 0;
  PriceInUAH:= False;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    aCount:= Stream.ReadInt;  // ���-�� ���������
    try
      if (aCount<1) then raise EBOBError.Create(MessText(mtkNotParams));
      SetLength(attCodes, aCount);
      SetLength(valCodes, aCount);
      for i:= 0 to aCount-1 do begin
        attCodes[i]:= Stream.ReadInt;
        valCodes[i]:= Stream.ReadInt;
        if (i=0) then flGBatt:= (attCodes[i]>cGBattDelta);
        if (grpID<1) then //------------------ ��������� ������ ��� �����������
          if flGBatt then begin
            ii:= attCodes[i]-cGBattDelta;
            if Cache.GBAttributes.ItemExists(ii) then
              grpID:= Cache.GBAttributes.GetAtt(ii).Group;
            if (grpID>0) then grpID:= grpID+cGBattDelta;
          end else if Cache.Attributes.ItemExists(attCodes[i]) then
            grpID:= Cache.Attributes.GetAttr(attCodes[i]).SubCode;
      end; // for i:= 0 to aCount-1
      PriceInUAH:= Stream.ReadBool;
      ForFirmID:= Stream.ReadInt;
      ContID:= Stream.ReadInt; // ��� ����������
    finally
      prSetThLogParams(ThreadData, csSearchWaresByAttrValues, UserId, FirmID,
        'pCount='+IntToStr(aCount)+#13#10'grpID='+IntToStr(grpID)+
        #13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID));
    end;
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    if flGBatt then begin // �������� Grossbee
      for i:= 0 to aCount-1 do begin  // ������� ������ �����
        attCodes[i]:= attCodes[i]-cGBattDelta;
        valCodes[i]:= valCodes[i]-cGBattDelta;
      end;
      attCodes:= Cache.SearchWaresByGBAttValues(attCodes, valCodes);

    end else // �������� ORD
      attCodes:= Cache.SearchWaresByAttrValues(attCodes, valCodes);

    if (Length(attCodes)<1) then raise EBOBError.Create(MessText(mtkNotFoundWares));

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
    flSemafores:= ffp.NeedSemafores;
    if flSemafores then ffp.FillStores;

    for i:= 0 to High(attCodes) do begin
      ware:= Cache.GetWare(attCodes[i]);
      if ware.IsPrize then Continue;
      flMarket:= ware.IsMarketWare(ffp);
      if not flMarket then Continue; // ����� ����� ������ ��������� ������

      if flSemafores then begin  // �������� �������
        sem:= GetContWareRestsSem(ware.ID, ffp, sArrive);
        if ffp.HideZeroRests and (sem<1) then Continue;
      end else begin
        sem:= -1;
        sArrive:= '';
      end;

      WA:= TSearchWareOrOnum.Create(attCodes[i], 0, True, flMarket);
      WA.RestSem:= sem;
      WA.SemTitle:= sArrive;
      WList.Add(WA);
    end; // for i:= 0 to List.Count

    if (WList.Count<1) then raise EBOBError.Create(
      MessText(mtkNotFoundWaresSem)+' � �������� ���������� ����������');
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(false); // ��� �������������
    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, 0, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(attCodes, 0);
  SetLength(valCodes, 0);
  SetLength(aar, 0);
  prFree(WList);
  prFree(OLmarkets);
  prFree(ffp);
  Stream.Position:= 0;
end;

  //----------------------------------------------------------
type
  TNodePLdata = Class
    Node: TMotulNode;     // not Free !!!
    PLine: TProductLine;  // not Free !!!
    nCount: Double;
    prior: Integer;
    StrUses, plComm: String;
    WList: TObjectList;   // TSearchWareOrOnum
    constructor Create(pNode: TMotulNode; pPLine: TProductLine; pCount: Double;
                       pPrior: Integer; pUses, pComm: String);
    destructor Destroy; override;
  end;
//******************************************************************************
//                          TNodePLdata
//******************************************************************************
constructor TNodePLdata.Create(pNode: TMotulNode; pPLine: TProductLine;
            pCount: Double; pPrior: Integer; pUses, pComm: String);
begin
  Node:= pNode;
  PLine:= pPLine;
  nCount:= pCount;
  prior:= pPrior;
  StrUses:= pUses;
  plComm:= pComm;
  WList:= TObjectList.Create; // (TSearchWareOrOnum)
end;
destructor TNodePLdata.Destroy;
begin
  prFree(WList);
  inherited;
end;
//========== ������������ ��� ���������� �������� ���� TNodePLdata � TObjectList
function SearchNodePLdataSortCompare(Item1, Item2: Pointer): Integer;
var sw1, sw2: TNodePLdata;
    s1, s2: String;
begin
  try
    sw1:= TNodePLdata(Item1);
    sw2:= TNodePLdata(Item2);
    if (sw1.Node.ID<>sw2.Node.ID) then begin
//      Result:= 0; // ���� ����������� ��� ������� �� ���� !!!
      if (sw1.Node.OrderOut=sw2.Node.OrderOut) then // ���� ����������� �� ������.������
        Result:= AnsiCompareText(sw1.Node.Name, sw2.Node.Name)
      else if (sw1.Node.OrderOut>sw2.Node.OrderOut) then Result:= 1 else Result:= -1;

    end else if (sw1.prior<>sw2.prior) then begin // �� ����������
      if (sw1.prior>sw2.prior) then Result:= 1 else Result:= -1;

    end else begin // �� ������������ ����.�������
      s1:= sw1.PLine.Name;
      s2:= sw2.PLine.Name;
      Result:= AnsiCompareText(s1, s2);
    end;
  except
    Result:= 0;
  end;
end;
//==================================== ���������� ����� ����� ����� ������ Motul
function MotulNodeCodesSortCompare(Item1, Item2: Pointer): Integer;
var Node1: TMotulNode;
    Node2: TMotulNode;
begin
  try
    Node1:= Cache.MotulTreeNodes[Integer(Item1)];
    Node2:= Cache.MotulTreeNodes[Integer(Item2)];
    if (Node1.OrderOut=Node2.OrderOut) then
      Result:= AnsiCompareText(Node1.Name, Node2.Name)
    else if (Node1.OrderOut>Node2.OrderOut) then Result:= 1 else Result:= -1;
  except
    Result:= 0;
  end;
end;
//=================================== ������ ������� Motul �� ����� ������ (Web)
procedure prCommonGetNodeWares_Motul(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares_Motul'; // ��� ���������/�������
var UserId, NodeId, ModelId, FirmId, aPos, i, j, aCount, ForFirmID, Sys, CurrID,
      contID, plID, prior, iCode, aCode, ii, fsize: integer;
    PriceInUAH, flSemafores, flMarket, flAllNodes, fl: boolean;
    Model: TModelAuto;
    StrPos, s, ss, plComm, ActTitle, ActText, imgExt: string;
    lst: TStringList;
    olNodePLs: TObjectList; // TNodePLdata
    WA: TSearchWareOrOnum;
    ware: TWareInfo;
    ffp: TForFirmParams;
    codes: TIntegerList;
    ibd: TIBDatabase;
    ibs: TIBSQL;
    Node: TMotulNode;
    PLine: TProductLine;
    kolvo: Double;
    NodePLdata: TNodePLdata;
    prices: TDoubleDynArray;
    ms: TMemoryStream;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  Model:= nil;
  NodePLdata:= nil;
  ffp:= nil;
  ms:= nil;
  codes:= TIntegerList.Create; // ������ ���� ����� ������ ��� ������ ������
  lst:= TStringList.Create;
  olNodePLs:= TObjectList.Create;
  SetLength(prices, 0);
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // ��� ������
    NodeID:= Stream.ReadInt;   // ��� ����: 0- ���, <0- ���� ��������� �������, >0- ���� Motul
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt;   // ��� ���������
    PriceInUAH:= Stream.ReadBool;

StrPos:='0';
    prSetThLogParams(ThreadData, csGetNodeWaresMotul, UserID, FirmID,
      'Model='+IntToStr(ModelID)+#13#10'Node='+IntToStr(NodeID)+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // �����������
StrPos:='1';
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
StrPos:='2';

    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create(MessText(mtkNotFoundModel));
    Model:= Cache.FDCA.Models.GetModel(ModelID);
    Sys:= Model.TypeSys;

    if (NodeID<0) and not Cache.FDCA.AutoTreeNodesSys[Sys].NodeExists(-NodeID) then
      raise EBOBError.Create(MessText(mtkNotFoundNode));
    if (NodeID>0) and not Cache.MotulTreeNodes.ItemExists(NodeID)then
      raise EBOBError.Create(MessText(mtkNotFoundNode)+' MOTUL');

    flAllNodes:= (NodeID=0); // ��� ����, �������� �� 1-� �������
    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
    flSemafores:= ffp.NeedSemafores; // ���� ��������� �������
    if flSemafores then ffp.FillStores;
StrPos:='3';

    IBD:= cntsOrd.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);

      if not flAllNodes then begin //------------------ ������ ���� ����� ������
        ibs.SQL.Text:= 'select lmnmoTRNm from LINKMODELNode_motul'+
                           ' where lmnmoDMOS='+IntToStr(ModelID)+' and lmnmoHasPL="T"';
        ibs.ExecQuery;
        while not ibs.Eof do begin
          j:= ibs.FieldByName('lmnmoTRNm').asInteger;
          if Cache.MotulTreeNodes.ItemExists(j) then codes.Add(j);
          cntsOrd.TestSuspendException;
          ibs.Next;
        end; // while ...
        IBS.Close;
        if (codes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes)+' MOTUL');
      end;

      ibs.SQL.Text:= 'select * from GetModelNodesPLines('+
                         IntToStr(ModelID)+', '+IntToStr(NodeID)+')';
      ibs.ExecQuery;
      while not ibs.Eof do begin
        j:= ibs.FieldByName('rNode').asInteger; // ��� ����
        if not Cache.MotulTreeNodes.ItemExists(j) then begin
          TestCssStopException;
          while not ibs.Eof and (j=ibs.FieldByName('rNode').asInteger) do ibs.Next;
          Continue;
        end;
        if flAllNodes then codes.Add(j);
        Node:= Cache.MotulTreeNodes[j];
        kolvo:= ibs.FieldByName('RCount').AsFloat; // ���-�� �� ����

        while not ibs.Eof and (j=ibs.FieldByName('rNode').asInteger) do begin
          plID:= ibs.FieldByName('Rpline').asInteger;  // ��� ����.�������
          PLine:= Cache.ProductLines.GetProductLine(plID);
          if not Assigned(PLine) or (PLine.WareLinks.LinkCount<1) then begin
            TestCssStopException;
            while not ibs.Eof and (j=ibs.FieldByName('rNode').asInteger)
              and (plID=ibs.FieldByName('Rpline').asInteger) do ibs.Next;
            Continue;
          end;
          prior:= ibs.FieldByName('Rprior').asInteger; // ��������� �� ����
          plComm:= PLine.Comment;

          lst.Clear; // �������� ������� ������������ ����.�������
          while not ibs.Eof and (j=IBS.FieldByName('rNode').asInteger)
            and (plID=ibs.FieldByName('Rpline').asInteger) do begin
            ss:= ibs.FieldByName('RcriName').AsString;
            s:= ibs.FieldByName('Rvalues').AsString; // ������ �� 1-�� ��������
            if (s<>'') or (ss<>'') then lst.Add(ss+fnIfStr(s='', '', ': '+s));
            cntsOrd.TestSuspendException;
            ibs.Next;
          end; // while ... and (plID=ORD_IBS.FieldByName('Rpline').asInteger

          NodePLdata:= TNodePLdata.Create(Node, PLine, kolvo, prior, lst.Text, plComm);
StrPos:='4';
          // ������ ������� ����.������� � ���������� (������������ �� �������)
          for i:= 0 to PLine.WareLinks.ListLinks.Count-1 do begin
            ware:= GetLinkPtr(PLine.WareLinks.ListLinks[i]);
            flMarket:= ware.IsMarketWare(ffp);
            WA:= TSearchWareOrOnum.Create(Ware.ID, 0, True, flMarket);
            if flSemafores and flMarket then
              WA.RestSem:= GetContWareRestsSem(WA.ID, ffp, WA.SemTitle);
            if (flSemafores and ffp.HideZeroRests and (WA.RestSem<1)) then begin
              prFree(WA);
              Continue;
            end;
            NodePLdata.WList.Add(WA);
          end; // for i:= 0 to PLine.WareLinks.ListLinks.Count

          if (NodePLdata.WList.Count>0) then olNodePLs.Add(NodePLdata)
          else prFree(NodePLdata);
        end; // while ... and (j=ORD_IBS.FieldByName('rNode').asInteger
      end; // while not ORD_IBS.Eof
    finally
      prFreeIBSQL(ibs);
      cntsOrd.SetFreeCnt(IBD);
    end;
    if (codes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes)+' MOTUL');
    if (olNodePLs.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundWaresSem));
                     // ��������� ������ ���� ����� �� ����������� ������
    codes.SortList(MotulNodeCodesSortCompare);
        // ��������� ����  �� ������.������ � ����.������� � ����� �� ����������
    olNodePLs.Sort(SearchNodePLdataSortCompare);
StrPos:='5';

    ms:= TMemoryStream.Create;
    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'GB_IBS_'+nmProc, -1, tpRead, True);
{ 13593 ������� ���������� ������
 109678 ���� ���
 109675 ���� TecDoc1
 109676 ���� TecDoc2
 109677 ���� TecDoc3  }
      ibs.SQL.Text:= 'select WRBLFTEXTN, WRBLFTFOTO'+ //  first 1
        '  from (select WRBLFTEXTN, WRBLFTFOTO, DECODE(WRBLFTFOTOTYPE, 13593,1,'+
        '    109678,2, 109675,3, 109676,4, 109677,5) ftype from WAREBLOBFOTO'+
        '    where WRBLFTWARECODE=:wareID and WRBLFTFOTO is not null'+
        '    and WRBLFTEXTN is not null) where ftype is not null order by ftype';
StrPos:='6';
//---------------------------------- �������� � CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteInt(Sys);           // �������
      Stream.WriteStr(Model.WebName); // ������������ ������

      Stream.WriteInt(codes.Count);   // ���-�� ����� ��� ������ ������
      for i:= 0 to codes.Count-1 do begin
        Stream.WriteInt(codes[i]);      // ��� ����
        Node:= Cache.MotulTreeNodes[codes[i]];
        Stream.WriteStr(Node.Name);     // ������������ ����
      end;

      Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient)); // �������� ������
      aCount:= 0;
      aPos:= Stream.Position;
      Stream.WriteInt(aCount); // ���-�� ����.������ (������)
      NodeID:= -1;
      s:= '';
      for j:= 0 to olNodePLs.Count-1 do begin
        NodePLdata:= TNodePLdata(olNodePLs[j]);

        // ���� ��� ���� - �������� ������ 1-� ����.������� �� ����
        if flAllNodes and (NodePLdata.Node.ID=NodeID) then Continue;

        if (NodeID<>NodePLdata.Node.ID) then begin // ������ ��.���. ����
          if (NodePLdata.Node.MeasID<1) then s:= ' �'
          else s:= ' '+Cache.GetMeasName(NodePLdata.Node.MeasID);
        end;

        Stream.WriteInt(NodePLdata.Node.ID);    // ��� ���� (��� ������)
        Stream.WriteStr(NodePLdata.Node.Name);  // ������������ ����
        Stream.WriteInt(NodePLdata.PLine.ID);   // ��� ����.�������
        Stream.WriteStr(NodePLdata.PLine.Name); // ������������ ����.�������
        Stream.WriteStr(NodePLdata.plComm);     // ����������� ����.�������
        if fnNotZero(NodePLdata.nCount) then
          Stream.WriteStr(FloatToStr(RoundTo(NodePLdata.nCount, -3))+s) // ����� �������
        else Stream.WriteStr('');
        Stream.WriteStr(NodePLdata.StrUses);    // (i) ������� ������������ ����.�������

//-------------------------------------------------------- �������� ����.�������
        imgExt:= '';
        fsize:= 0;
        ms.Clear;
StrPos:='7';
        WA:= TSearchWareOrOnum(NodePLdata.WList[0]); // 1-� �����
        try
          if not ibs.Transaction.InTransaction then ibs.Transaction.StartTransaction;
          ibs.ParamByName('wareID').AsInteger:= Wa.ID;
          ibs.ExecQuery;
StrPos:='8';
          while not ibs.Eof do begin
            ibs.FieldByName('WRBLFTFOTO').SaveToStream(ms);
            fsize:= ms.Size;
            if (fsize>0) then begin
              imgExt:= ibs.FieldByName('WRBLFTEXTN').AsString;
              break;
            end else ms.Clear;
            ibs.Next;
          end;
        except
          on e: exception do ibs.Transaction.Rollback;
        end;
        ibs.Close;
        if (fsize<1) then begin
          ware:= GetLinkPtr(NodePLdata.PLine.WareLinks.ListLinks[0]);
          prMessageLOGS(nmProc+': Empty image: ware=['+IntToStr(ware.ID)+'] '+ware.Name+
                        ' PL=['+IntToStr(NodePLdata.PLine.ID)+'] '+NodePLdata.PLine.Name);
          imgExt:= '';
        end;
StrPos:='9';
        Stream.WriteStr(imgExt);      // ���������� ����� ��������
        Stream.WriteInt(fsize);       // ������ ��������
        if (fsize>0) then begin
          ms.Position:= 0;
          Stream.CopyFrom(ms, fsize); // ��������
        end;
//------------------------------------------------------------------------------
StrPos:='10';
        Stream.WriteInt(NodePLdata.WList.Count); // ���-�� ������� � ����.�������
        for i:= 0 to NodePLdata.WList.Count-1 do begin
          WA:= TSearchWareOrOnum(NodePLdata.WList[i]);
          ware:= Cache.GetWare(Wa.ID);
          iCode:= ware.AttrGroupID;
          if (iCode<1) then begin
            iCode:= ware.GBAttGroup;
            if (iCode>0) then iCode:= iCode+cGBattDelta;
          end;
          aCode:= Ware.GetActionParams(ActTitle, ActText);
          prices:= ware.CalcFirmPrices(ffp);

          Stream.WriteInt(ware.ID);             // ��� ������
          Stream.WriteInt(iCode);               // ������ ���������
          Stream.WriteDouble(ware.LitrCount);   // ������

          for ii:= 0 to High(prices) do // ���� (0- �������, 1- �� �������, 2- �� ����.�������)
            Stream.WriteDouble(prices[ii]);

          Stream.WriteInt(4);                  // ���-�� ������ �����
          Stream.WriteInt(constIsAuto);        // ��� ������� ����� AUTO
          fl:= ware.SysModelsExists(constIsAuto);
          Stream.WriteBool(fl);                // ������� ������� ������� AUTO

          Stream.WriteInt(constIsMoto);        // ��� ������� ����� MOTO
          fl:= ware.SysModelsExists(constIsMoto);
          Stream.WriteBool(fl);                // ������� ������� ������� MOTO

          Stream.WriteInt(constIsCV);          // ��� ������� ����� ����������
          fl:= ware.SysModelsExists(constIsCV);
          Stream.WriteBool(fl);                // ������� ������� ������� ����������

          Stream.WriteInt(constIsAx);          // ��� ������� ����� ����
          fl:= ware.SysModelsExists(constIsAx);
          Stream.WriteBool(fl);                // ������� ������� ������� ����

          Stream.WriteBool(ware.IsSale);        // ������� ����������
          Stream.WriteBool(ware.IsNonReturn);   // ������� ����������
          Stream.WriteBool(ware.IsCutPrice);    // ������� ������

          Stream.WriteInt(aCode);               // ��� �����
          Stream.WriteStr(ActTitle);            // ���������
          Stream.WriteStr(ActText);             // �����
//----------------------------------------------------------------- ������ �����
//          if (aCode<1) then begin
            Stream.WriteStr('');           // ����������
            Stream.WriteInt(0);            // ������
{
          end else try
            Cache.WareActions.CS_DirItems.Enter;
            wact:= Cache.WareActions[aCode];
            fsize:= wact.IconMS.Size;

            Stream.WriteStr(wact.IconExt); // ���������� ������
            Stream.WriteInt(fsize);        // ������
            if (fsize>0) then begin
              wact.IconMS.Position:= 0;
              Stream.CopyFrom(wact.IconMS, fsize); // ������
            end;

          finally
            Cache.WareActions.CS_DirItems.Leave;
          end;  }
//------------------------------------------------------------------------------
          Stream.WriteDouble(Ware.divis); // ��������� ������� ������
          Stream.WriteInt(Wa.RestSem);    // ������� ��������: 0- �������, 1- ������, 2- �������, 3- ����.�������, ������ - ���

if flSpecRestSem then
          Stream.WriteStr(WA.SemTitle);    // ��������� ��� ����.��������

        end; // for i:= 0 to NodePLdata.WList.Count

        Inc(aCount);
        NodeID:= NodePLdata.Node.ID;
      end; // for j:= 0 to olNodePLs.Count-1
      Stream.Position:= aPos;
      Stream.WriteInt(aCount);
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(IBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
  finally
    Stream.Position:= 0;
    prFree(ffp);
    prFree(codes);
    prFree(lst);
    prFree(olNodePLs);
    prFree(ms);
    SetLength(prices, 0);
  end;
end;
//================================================= ������ ������� �� ���� (Web)
procedure prCommonGetNodeWares_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares_new'; // ��� ���������/�������
var UserId, NodeId, ModelId, FirmId, aPos, i, j, aCount, ForFirmID, Sys, CurrID, WareID, contID, sem: integer;
    ShowChildWares, IsEngine, flag, PriceInUAH, ShowAnalogs, flSemafores, flMarket: boolean;
    Model: TModelAuto;
    StrPos, filter, NodeName, s, webMess: string;
    sArrive: String;
    List: TStringList;
    Engine: TEngine;
    empl: TEmplInfoItem;
    WList, AddList: TObjectList;
    WA, addWA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ware, analog: TWareInfo;
    ffp: TForFirmParams;
    codes, addCodes: TIntegerList;
    lst: TStringList;
begin
  Stream.Position:= 0;
  Engine:= nil;
  Model:= nil;
  List:= nil;
  empl:= nil;
  ffp:= nil;
  WList:= TObjectList.Create;
  AddList:= TObjectList.Create;
  codes:= TIntegerList.Create;
  addCodes:= TIntegerList.Create;
  lst:= TStringList.Create;
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    ShowChildWares:= Stream.ReadBool;
    IsEngine:= Stream.ReadBool;
    PriceInUAH:= Stream.ReadBool;
    filter:= Stream.ReadStr;

StrPos:='0';
    prSetThLogParams(ThreadData, csGetNodeWares, UserID, FirmID,
      'Node='+IntToStr(NodeID)+#13#10'Model='+IntToStr(ModelID)+
      #13#10'Filter='+(Filter)+#13#10'IsEngine='+fnIfStr(IsEngine, '1', '0')+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // �����������
StrPos:='1';
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
StrPos:='2';
    if IsEngine then begin  //--------- ���������
      Sys:= constIsAuto;
//      if Sys<>constIsAuto then raise EBOBError.Create(MessText(mtkNotFoundWares));
      if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundEngine));
      Engine:= Cache.FDCA.Engines[ModelID];

    end else begin          //--------- ������
      if not Cache.FDCA.Models.ModelExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundModel));
      Model:= Cache.FDCA.Models.GetModel(ModelID);
      Sys:= Model.TypeSys;
    end;

    if not Cache.FDCA.AutoTreeNodesSys[Sys].NodeExists(NodeID) then
      raise EBOBError.Create(MessText(mtkNotFoundNode));

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    if not ffp.ForClient then empl:= Cache.arEmplInfo[ffp.UserId];
StrPos:='3';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if IsEngine then begin  //--------- ���������
      Stream.WriteInt(31);
      Stream.WriteStr(Engine.WebName);
    // ������� ����, ��� ������������ WebArm ����� ������� ����� �� ������ 3
      flag:= not ffp.ForClient and empl.UserRoleExists(rolTNAManageAuto);
StrPos:='4-1';
      List:= Engine.GetEngNodeWaresWithUsesByFilters(NodeID, ShowChildWares, Filter);

    end else begin          //--------- ������
      Stream.WriteInt(Sys);
      Stream.WriteStr(Model.WebName);
    // ������� ����, ��� ������������ WebArm ����� ������� ����� �� ������ 3
      flag:= not ffp.ForClient and Cache.WareLinksUnLocked and
             Model.GetModelNodeIsSecondLink(NodeID) and
             (((Sys=constIsMoto) and empl.UserRoleExists(rolTNAManageMoto))
             or ((Sys=constIsAuto) and empl.UserRoleExists(rolTNAManageAuto))
             or ((Sys=constIsCV) and empl.UserRoleExists(rolTNAManageCV)));
StrPos:='4-2';
      List:= Cache.GetModelNodeWaresWithUsesByFilters(ModelID, NodeID, ShowChildWares, Filter);
    end;
    if (List.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundWares)+webMess);

    NodeName:= Cache.FDCA.AutoTreeNodesSys[Sys][NodeID].Name;
    webMess:= ' �� ���� "'+NodeName+'"';
//    webMess:= fnReplaceQuotedForWeb(' �� ���� "'+brcWebBoldBlackBegin+NodeName+brcWebBoldEnd+'"');
    ShowAnalogs:= False;
    flSemafores:= ffp.NeedSemafores; // ���� ��������� �������
    if flSemafores then ffp.FillStores;
    ShowChildWares:= flag or not flSemafores; // ����� - ���� ������ ��� WebArm

StrPos:='4-3';
    // --------------------------------------------- ������� ������ � ����������
    for i:= 0 to List.Count-1 do begin
      WareID:= integer(List.Objects[i]);
      ware:= Cache.GetWare(WareID);
      flMarket:= ware.IsMarketWare(ffp);
      WA:= TSearchWareOrOnum.Create(WareID, 0, True, flMarket);
      if flSemafores and flMarket then
        WA.RestSem:= GetContWareRestsSem(WA.ID, ffp, WA.SemTitle);

      for j:= 0 to ware.AnalogLinks.ListLinks.Count-1 do begin
        analog:= GetLinkPtr(ware.AnalogLinks.ListLinks[j]);
        if analog.IsINFOgr or not analog.IsMarketWare(ffp) then Continue; // ���� � ��� ��� ����������
        sem:= 0;
        sArrive:= '';
        if flSemafores then begin // ���� ����� ��������
          sem:= GetContWareRestsSem(analog.ID, ffp, sArrive);
          if ffp.HideZeroRests and (sem<1) then Continue; // ���� ���� - ��������� �������
        end;
        tc:= TTwoCodes.Create(analog.ID, sem, 0, sArrive);
        WA.OLAnalogs.Add(tc);
      end; // for j:= 0 to

      if (WA.OLAnalogs.Count<1) and not flMarket and not flag then begin
        prFree(WA);    // �� 1-� ������� ������ �� ��������� �� ��������� !!!
        Continue;
      end;

      WA.AddComment:= List[i]; // ��� ������ - ������� ������������
      WList.Add(WA);
      if not ShowChildWares then codes.Add(WA.ID); // ���� �������, ���. ���� � WList
    end; // for i:= 0 to List.Count

    //---------------------------------- ������� - � ������ ������� ��� �������
    if not ShowChildWares then begin
      for i:= WList.Count-1 downto 0 do begin
        WA:= TSearchWareOrOnum(WList[i]);
        ware:= Cache.GetWare(WA.ID);
        s:= '������ ����� ������������� ����� '+ware.Name; // ������� ��� �������
        for j:= 0 to WA.OLAnalogs.Count-1 do begin
          tc:= TTwoCodes(WA.OLAnalogs[j]);
          if (codes.IndexOf(tc.ID1)>-1) then Continue; // ����� ��� ����

          addWA:= TSearchWareOrOnum.Create(tc.ID1, 0, True, True);
          addWA.RestSem:= tc.ID2;
          addWA.SemTitle:= tc.Name; // ��������� � ��������
          lst.Clear;
          lst.Add(brcWebColorBlueBegin+s+brcWebColorEnd); // ����� �����
          addWA.AddComment:= lst.Text;
//          addWA.AddComment:= ''''+brcWebColorBlueBegin+s+brcWebColorEnd+''''; // ����� �����

          AddList.Add(addWA);   // ������� - � ���.������
          codes.Add(addWA.ID);  // ���� �������, ���. ���� � WList
        end;
        if ware.IsINFOgr or not ware.IsMarketWare(ffp)
          or (flSemafores and ffp.HideZeroRests and (WA.RestSem<1)) then begin
          WList.Delete(i);
          prFree(WA);    // �� 2-� ������� ��������� ����������� ������ + �� ���������
        end;
      end; // for i:= 0 to WList.Count

//      for i:= 0 to AddList.Count-1 do WList.Add(AddList[i]); // ���.������ + � ���������
    end; // if not ShowChildWares

    if (WList.Count<1) and (AddList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotFoundWaresSem)+webMess);

    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    if (AddList.Count>1) then AddList.Sort(SearchWareOrONSortCompare); // ��������� �������

StrPos:='5';
    Stream.WriteBool(flag);
    Stream.WriteStr(NodeName);
    Stream.WriteStr(Filter);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);

    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if ShowChildWares then j:= WA.OLAnalogs.Count else j:= 0;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, j, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count

    Stream.WriteInt(AddList.Count);       //------------------- �������� �������
    for i:= 0 to AddList.Count-1 do begin
      WA:= TSearchWareOrOnum(AddList[i]);
      if ShowChildWares then j:= WA.OLAnalogs.Count else j:= 0;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, j, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to AddList.Count

StrPos:='10';
//---------------------------- ���.���� � ����. ������� � ������� / ������ �����
    aCount:= 0;
    aPos:= Stream.Position;
    Stream.WriteInt(aCount);
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if (WA.AddComment<>'') then begin
        Stream.WriteInt(WA.ID);
        Stream.WriteStr(WA.AddComment);
        Inc(aCount);
      end;
    end;
    for i:= 0 to AddList.Count-1 do begin
      WA:= TSearchWareOrOnum(AddList[i]);
      if (WA.AddComment<>'') then begin
        Stream.WriteInt(WA.ID);
        Stream.WriteStr(WA.AddComment);
        Inc(aCount);
      end;
    end;
    Stream.Position:= aPos;
    Stream.WriteInt(aCount);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
  finally
    Stream.Position:= 0;
    prFree(List);
    prFree(WList);
    prFree(AddList);
    prFree(ffp);
    prFree(codes);
    prFree(addCodes);
    prFree(lst);
  end;
end;
//=============================== ����� ������� �� ������.������ �� Laximo (Web)
procedure prSearchWaresByOE_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSearchWaresByOE_new'; // ��� ���������/�������
      arManufDuo: array [0..3] of string = ('LEXUS','TOYOTA','INFINITI','NISSAN');
var UserId, FirmId, ContID, i, j, ManufID, ForFirmID, CurrID, m, pline, WareID, sem, aPos: integer;
    Manuf, OE, webMess, ManufDuo, ErrorPos, mess, s: string;
    sArrive: String;
    aiWareByON: Tai;
    PriceInUah, ShowAnalogs, flSemafores, flMarket: boolean;
    iListM, iListW, lst, codes: TIntegerList;  // lst - not Free !!!
    IBSORD: TIBSQL;
    IBORD: TIBDatabase;
    WList, AddList: TObjectList;
    WA, addWA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ware, analog: TWareInfo;
    ffp: TForFirmParams;
    slst: TStringList;
begin
  IBSORD:= nil;
//  IBORD:= nil;
  Stream.Position:= 0;
  SetLength(aiWareByON, 0);
  WList:= TObjectList.Create;
  AddList:= TObjectList.Create;
  slst:= TStringList.Create;
  ShowAnalogs:= False;
  flSemafores:= False;
  ffp:= nil;
  try try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt;       // ��� ����������
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;
    pline:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWaresByOE, UserID, FirmID, 'OE='+OE+
      #13#10'Manuf='+Manuf+#13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID)); // �����������
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������

    if (Manuf='') then raise EBOBError.Create('������������ �������� �������������');
    if (OE='') then raise EBOBError.Create('������������ �������� ������������� ������');
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    IBORD:= cntsORD.GetFreeCnt;
    try try
      IBSORD:= fnCreateNewIBSQL(IBORD, 'IBSORD_'+nmProc, -1, tpWrite, true);
      IBSORD.SQL.Text:='execute procedure LAXIMOSAVECLICKPROTONLINE('+IntToStr(pline)+')';
      IBSORD.ExecQuery;
      if IBSORD.Transaction.InTransaction then IBSORD.Transaction.Commit;
    except
      on E: Exception do prMessageLOGS(nmProc+': ' +E.Message+
        ' (ErrorPos='+ErrorPos+'), SQL.Text='+IBSORD.SQL.Text, 'error' , false);
    end;
    finally
      prFreeIBSQL(IBSORD);
      cntsORD.SetFreeCnt(IBORD);
    end;

    webMess:= ' �� ����.������ "'+OE+'"';
//    webMess:= fnReplaceQuotedForWeb(' �� ����.������ "'+brcWebBoldBlackBegin+OE+brcWebBoldEnd+'"');
    mess:= MessText(mtkNotFoundWares)+webMess;
    iListM:= TIntegerList.Create; // ���� ��������������
    iListW:= TIntegerList.Create; // ���� �������
    codes:= TIntegerList.Create; // ���� ������� ��� �������� �� ������
    try
      i:= Cache.BrandLaximoList.IndexOf(Manuf);
      if (i>-1) then begin
        lst:= TIntegerList(Cache.BrandLaximoList.Objects[i]);
        for i:= 0 to lst.Count-1 do iListM.Add(lst[i]);
      end;
      m:= fnInStrArray(Manuf, arManufDuo);
      if (m>-1) then begin
        if Odd(m) then ManufDuo:= arManufDuo[m-1] // �������� ������
                  else ManufDuo:= arManufDuo[m+1];
        Manuf:= {'"'+}Manuf+{'", "'}''', '''+ManufDuo{+'"'};
        i:= Cache.BrandLaximoList.IndexOf(ManufDuo);
        if i>-1 then begin
          lst:= TIntegerList(Cache.BrandLaximoList.Objects[i]);
          for i:= 0 to lst.Count-1 do iListM.Add(lst[i]);
        end;
      end; // if (m>-1)
      if (iListM.Count<1) then raise EBOBError.Create(mess);
  ErrorPos:='10';

      OE:= fnDelSpcAndSumb(OE);
      for m:= 0 to iListM.Count-1 do try //------ �������� ���� ������� � iListW
        ManufID:= iListM[m];
        if not Cache.FDCA.Manufacturers.ManufExists(ManufID) then continue;
        i:= Cache.FDCA.SearchOriginalNum(ManufID, OE);
        if (i<0) then continue;

        aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // ������ � ��
        for i:= 0 to High(aiWareByON) do begin
          WareID:= aiWareByON[i];
          ware:= Cache.GetWare(WareID);
          if ware.IsPrize then Continue;
          iListW.Add(WareID);
        end;
      finally
        SetLength(aiWareByON, 0);
      end; //  for m:= 0 to iList.Count-1
      if (iListW.Count<1) then raise EBOBError.Create(mess);

      ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
      flSemafores:= ffp.NeedSemafores; // ���� ��������� �������
      if flSemafores then ffp.FillStores;
      ShowAnalogs:= False;

    // --------------------------------------------- ������� ������ � ����������
      for i:= 0 to iListW.Count-1 do begin
        WareID:= iListW[i];
        ware:= Cache.GetWare(WareID);
        flMarket:= ware.IsMarketWare(ffp);
        WA:= TSearchWareOrOnum.Create(WareID, 0, True, flMarket);
        if flSemafores and flMarket then
          WA.RestSem:= GetContWareRestsSem(WA.ID, ffp, WA.SemTitle);

        for j:= 0 to ware.AnalogLinks.ListLinks.Count-1 do begin
          analog:= GetLinkPtr(ware.AnalogLinks.ListLinks[j]);
          if analog.IsINFOgr or not analog.IsMarketWare(ffp) then Continue; // ���� � ��� ��� ����������
          if flSemafores then begin // ���� ����� ��������
            sem:= GetContWareRestsSem(analog.ID, ffp, sArrive);
            if ffp.HideZeroRests and (sem<1) then Continue; // ���� ���� - ��������� �������
          end else begin
            sem:= 0;
            sArrive:= '';
          end;
          tc:= TTwoCodes.Create(analog.ID, sem, 0, sArrive);
          WA.OLAnalogs.Add(tc);
        end; // for j:= 0 to

        if (WA.OLAnalogs.Count<1) and not flMarket then begin
          prFree(WA);    // �� 1-� ������� ������ �� ��������� �� ��������� !!!
          Continue;
        end;

        WA.AddComment:= ''; // ��� ������ - �����
        WList.Add(WA);
        codes.Add(WA.ID); // ���� �������, ���. ���� � WList
      end; // for i:= 0 to iListW.Count
    finally
      prFree(iListM);
      prFree(iListW);
    end;

    //---------------------------------- ������� - � ������ ������� ��� �������
    for i:= WList.Count-1 downto 0 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      ware:= Cache.GetWare(WA.ID);
      s:= '������ ����� ������������� ����� '+ware.Name; // ������� ��� �������
      for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if (codes.IndexOf(tc.ID1)>-1) then Continue; // ����� ��� ����

        addWA:= TSearchWareOrOnum.Create(tc.ID1, 0, True, True);
        addWA.RestSem:= tc.ID2;
        addWA.SemTitle:= tc.Name; // ��������� � ��������
        slst.Clear;
        slst.Add(brcWebColorBlueBegin+s+brcWebColorEnd); // ����� �����
        addWA.AddComment:= slst.Text;
//        addWA.AddComment:= ''''+brcWebColorBlueBegin+s+brcWebColorEnd+''''; // ����� �����

        AddList.Add(addWA);   // ������� - � ���.������
        codes.Add(addWA.ID);  // ���� �������, ���. ���� � WList
      end;
      if ware.IsINFOgr or not ware.IsMarketWare(ffp)
        or (flSemafores and ffp.HideZeroRests and (WA.RestSem<1)) then begin
        WList.Delete(i);
        prFree(WA);    // �� 2-� ������� ��������� ����������� ������ + �� ���������
      end;
    end; // for i:= 0 to WList.Count

//    for i:= 0 to AddList.Count-1 do WList.Add(AddList[i]); // ���.������ + � ���������

    if (WList.Count<1) and (AddList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotFoundWaresSem)+webMess);

    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    if (AddList.Count>1) then AddList.Sort(SearchWareOrONSortCompare); // ��������� �������
//------------------------------------------------------------------------------

    Stream.Clear;
    Stream.WriteInt(aeSuccess);    // ����� ������ �� ��
    Stream.WriteStr(Manuf);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);

    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, 0, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count

    Stream.WriteInt(AddList.Count);        //------------------ �������� �������
    for i:= 0 to AddList.Count-1 do begin
      WA:= TSearchWareOrOnum(AddList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, 0, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count

    Stream.WriteStr('WaresByOE');

//---------------------------- ���.���� � "������ ����� ..."
    j:= 0;
    aPos:= Stream.Position;
    Stream.WriteInt(j);
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if (WA.AddComment<>'') then begin
        Stream.WriteInt(WA.ID);
        Stream.WriteStr(WA.AddComment);
        Inc(j);
      end;
    end;
    for i:= 0 to AddList.Count-1 do begin
      WA:= TSearchWareOrOnum(AddList[i]);
      if (WA.AddComment<>'') then begin
        Stream.WriteInt(WA.ID);
        Stream.WriteStr(WA.AddComment);
        Inc(j);
      end;
    end;
    Stream.Position:= aPos;
    Stream.WriteInt(j);
//---------------------------- ���.���� � "������ ����� ..."

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  finally
    Stream.Position:= 0;
    SetLength(aiWareByON, 0);
    prFree(WList);
    prFree(AddList);
    prFree(ffp);
    prFree(codes);
    prFree(slst);
  end;
end;
//========================================================== ����� ������� (Web)
procedure prCommonWareSearch_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonWareSearch_new'; // ��� ���������/�������
var Template, s, InnerErrorPos, sParam, sTypes: string;
    UserId, FirmID, currID, ForFirmID, i, j, arlen, CountAll, contID: integer;
    IgnoreSpec: byte;
    ShowAnalogs, NeedGroups, NotWasGroups, PriceInUah,
      flSale, flCutPrice, flSpecSearch, flSemafores: boolean;
    TypesI, TypesIon: Tai;
    TypesS: Tas;
    OrigNum: TOriginalNumInfo;
    WList, ONlist: TObjectList;
    WA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ffp: TForFirmParams;
    lst: TStringList;
    LocalStart, LocStart: TDateTime;
begin
  LocalStart:= now();
  LocStart:= now();
  Stream.Position:= 0;
  WList:= nil;
  SetLength(TypesI, 0);
  SetLength(TypesIon, 0);
  SetLength(TypesS, 0);
  ONlist:= nil;
  flSale:= False;
  flCutPrice:= False;
  flSemafores:= False;
  ffp:= nil;
  lst:= TStringList.Create;
  try try
InnerErrorPos:='0';

if flmyDebug then begin
    prMessageLOGS(nmProc+' ----------- begin search '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end; // if flmyDebug

    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    Template:= Stream.ReadStr;
    Template:= trim(Template);
    IgnoreSpec:= Stream.ReadByte;
    PriceInUah:= Stream.ReadBool;
          // ����������� � ib_css - ������ �� �������, �������������� � ���� !!!
    sParam:= 'ContID='+IntToStr(ContID)+#13#10'Template='+Template+
      #13#10'IgnoreSpec='+IntToStr(IgnoreSpec)+#13#10'ForFirmID='+IntToStr(ForFirmID);
    try
      if (Length(Template)<1) then raise EBOBError.Create('�� ����� ������ ������');
                 // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
      prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
//      if (FirmId<>IsWe) and (ForFirmID<1) then ForFirmID:= FirmID;

      if (FirmId<>IsWe) and Cache.arFirmInfo[FirmId].IsFinalClient then IgnoreSpec:= 2;

      sTypes:= Stream.ReadStr; // �������� �������� ����� �������, ��������� �������������
//------------------------------------------------------------- ����.���� ������
      s:= AnsiUpperCase(Template);
      flSale    := (s=cTemplateSale);        // ����������
      flCutPrice:= (s=cTemplateCutPrice);    // ������
      if not (IgnoreSpec in [1, 2]) then IgnoreSpec:= 0; // ���� IgnoreSpec=3 �� ��������
      flSpecSearch:= (flSale or flCutPrice); // ������� ����.������
//-------------------------------------------------------------
InnerErrorPos:='1';
      if (sTypes<>'') then begin
        TypesS:= fnSplitString(sTypes, ',');
        SetLength(TypesI, Length(TypesS));
        if not flSpecSearch then SetLength(TypesIon, Length(TypesS));
        arlen:= 0;
        for i:= 0 to High(TypesS) do begin
          j:= StrToIntDef(TypesS[i], -1);
          if (j<0) then Continue;
          TypesI[arlen]:= j;
          if not flSpecSearch then TypesIon[arlen]:= j;
          Inc(arlen);
        end;
        if (Length(TypesI)>arlen) then SetLength(TypesI, arlen);
        if not flSpecSearch and (Length(TypesIon)>arlen) then SetLength(TypesIon, arlen);
      end;
      NotWasGroups:= (Length(TypesI)=0); // ����������, ������������ �� ������, �.�. ������ ���������������
InnerErrorPos:='2';

      ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
      flSemafores:= ffp.NeedSemafores;
      if flSemafores then ffp.FillStores;
//------------------------------------------------------------- ���������� �����

      WList:= SearchWaresTypesAnalogs_new(Template, TypesI, IgnoreSpec,
                                      false, flSale, flCutPrice, flSemafores, ffp);

if flmyDebug then begin
    prMessageLOGS(nmProc+' form WList - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end; // if flmyDebug

InnerErrorPos:='3';
//---------------------------------------- ������ ��� �������� ������ - ����� ��
      if flSpecSearch then ONlist:= TObjectList.Create
      else ONlist:= SearchWareOrigNums_new(Template, IgnoreSpec, TypesIon, flSemafores, ffp);

if flmyDebug then begin
    prMessageLOGS(nmProc+' form ONlist - '+GetLogTimeStr(LocStart), fLogDebug, false); // ����� � log
    LocStart:= now();
end; // if flmyDebug

      sParam:= sParam+#13#10'WareQty='+IntToStr(WList.Count)+#13#10'OEQty='+IntToStr(ONlist.Count);
    finally
      prSetThLogParams(ThreadData, csSearchWithOrNums, UserID, FirmID, sParam); // �����������
    end;

    CountAll:= ONlist.Count+WList.Count;
    if (CountAll<1) then
      raise EBOBError.Create(MessText(mtkNotFoundWaresSem)+' �� ������� '+Template);

//------------------------------------------------------------------------
InnerErrorPos:='4';
    NeedGroups:= NotWasGroups and (CountAll>Cache.GetConstItem(pcSearchCountTypeAsk).IntValue);
    if NeedGroups then begin
      lst.Capacity:= lst.Capacity+Length(TypesI)+Length(TypesIon);
      for i:= 0 to High(TypesI) do begin
        j:= TypesI[i];
        if FindWareType(lst, j) then Continue;
        prAddWareType(lst, j, Cache.GetWareTypeName(j));
      end;
      for i:= 0 to High(TypesIon) do begin
        j:= TypesIon[i];
        if FindWareType(lst, j) then Continue;
        prAddWareType(lst, j, Cache.GetWareTypeName(j));
      end;
    end;
    NeedGroups:= NeedGroups and (lst.Count>1);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteBool(NeedGroups);
//-------------------------------------------------------------- �������� ������
    if NeedGroups then begin
InnerErrorPos:='5';
      lst.CustomSort(TypeNamesSortCompare);

      Stream.WriteInt(CountAll);
      Stream.WriteInt(lst.Count);
      for I:= 0 to lst.Count-1 do begin
        j:= Integer(lst.Objects[i]);
        Stream.WriteInt(j);
        Stream.WriteStr(lst[i]);
      end;
      Exit; // �������
    end;
InnerErrorPos:='6';

//--------------------------------------------------------------- ������� ������
    ShowAnalogs:= ffp.ForClient and (CountAll<Cache.arClientInfo[ffp.UserID].MaxRowShowAnalogs);

    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    for i:= 0 to WList.Count-1 do begin // ��������� �������
      WA:= TSearchWareOrOnum(WList[i]);
      if (WA.OLAnalogs.Count>1) and (ShowAnalogs or (WA.RestSem=0)) then
        WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
    end; // for i:= 0 to WList.Count

    if (ONlist.Count>1) then ONlist.Sort(SearchWareOrONSortCompare); // ��������� ��
    if ShowAnalogs then for i:= 0 to ONlist.Count-1 do begin // ��������� ������� ��
      WA:= TSearchWareOrOnum(ONlist[i]);
      if (WA.OLAnalogs.Count>1) then
        WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
    end;

//-------------------------------------------------------------- �������� ������
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);   // �������� ������
    for i:= 0 to WList.Count-1 do begin
InnerErrorPos:='7-'+IntToStr(i);
      WA:= TSearchWareOrOnum(WList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, WA.OLAnalogs.Count, 0, WA.RestSem, WA.SemTitle);

      if (ShowAnalogs or (WA.RestSem=0)) then for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, tc.ID2, tc.Name);
      end;
    end; // for i:= 0 to WList.Count-1
//------------------------------------------------------------------ �������� ��
    Stream.WriteInt(ONlist.Count);
    for i:= 0 to ONlist.Count-1 do begin
InnerErrorPos:='8-'+IntToStr(i);
      WA:= TSearchWareOrOnum(ONlist[i]);
      OrigNum:= Cache.FDCA.arOriginalNumInfo[WA.ID];
      Stream.WriteInt(OrigNum.ID);
      Stream.WriteInt(OrigNum.MfAutoID);
      Stream.WriteStr(OrigNum.ManufName);
      Stream.WriteStr(OrigNum.OriginalNum);
      Stream.WriteStr(OrigNum.CommentWWW);

      if not ShowAnalogs then Continue;

      Stream.WriteInt(WA.OLAnalogs.Count); // ���-�� ��������
      for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, tc.ID2, tc.Name);
      end;
    end; // for i:= 0 to ONlist.Count

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message,
                                         'InnerErrorPos='+InnerErrorPos, False);
  end;
  finally

if flmyDebug then begin
    prMessageLOGS(nmProc+' ----------- end search '+GetLogTimeStr(LocalStart), fLogDebug, false); // ����� � log
end; // if flmyDebug

    Stream.Position:= 0;
    SetLength(TypesI, 0);
    SetLength(TypesIon, 0);
    SetLength(TypesS, 0);
    prFree(WList);
    prFree(ONlist);
    prFree(ffp);
    prFree(lst);
  end;
end;
//============================================== ������ ������� �� ���� (WebArm)
procedure prCommonGetNodeWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares'; // ��� ���������/�������
var UserId, NodeId, ModelId, FirmId, aPos, i, j, aCount, ForFirmID, Sys, CurrID, WareID, contID: integer;
    ShowChildWares, IsEngine, flag, PriceInUAH, ShowAnalogs, flSemafores, flMarket: boolean;
    aar, aar1: Tai;
    Model: TModelAuto;
    StrPos, filter, NodeName, s: string;
    List: TStringList;
    Engine: TEngine;
    empl: TEmplInfoItem;
    WList, OLmarkets: TObjectList;
    WA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ware: TWareInfo;
    ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  Engine:= nil;
  Model:= nil;
  List:= nil;
  empl:= nil;
  ffp:= nil;
  WList:= TObjectList.Create;
  OLmarkets:= TObjectList.Create;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    ShowChildWares:= Stream.ReadBool;
    IsEngine:= Stream.ReadBool;
    PriceInUAH:= Stream.ReadBool;
    filter:= Stream.ReadStr;

StrPos:='0';
    prSetThLogParams(ThreadData, csGetNodeWares, UserID, FirmID,
      'Node='+IntToStr(NodeID)+#13#10'Model='+IntToStr(ModelID)+
      #13#10'Filter='+(Filter)+#13#10'IsEngine='+fnIfStr(IsEngine, '1', '0')+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // �����������
StrPos:='1';
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
StrPos:='2';
    if IsEngine then begin  //--------- ���������
      Sys:= constIsAuto;
//      if Sys<>constIsAuto then raise EBOBError.Create(MessText(mtkNotFoundWares));
      if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundEngine));
      Engine:= Cache.FDCA.Engines[ModelID];

    end else begin          //--------- ������
      if not Cache.FDCA.Models.ModelExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundModel));
      Model:= Cache.FDCA.Models.GetModel(ModelID);
      Sys:= Model.TypeSys;
    end;

    if not Cache.FDCA.AutoTreeNodesSys[Sys].NodeExists(NodeID) then
      raise EBOBError.Create(MessText(mtkNotFoundNode));

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    if not ffp.ForClient then empl:= Cache.arEmplInfo[ffp.UserId];
StrPos:='3';
    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if IsEngine then begin  //--------- ���������
      Stream.WriteInt(31);
      Stream.WriteStr(Engine.WebName);
    // ������� ����, ��� ������������ WebArm ����� ������� ����� �� ������ 3
      flag:= not ffp.ForClient and empl.UserRoleExists(rolTNAManageAuto);
StrPos:='4-1';
      List:= Engine.GetEngNodeWaresWithUsesByFilters(NodeID, ShowChildWares, Filter);

    end else begin          //--------- ������
      Stream.WriteInt(Sys);
      Stream.WriteStr(Model.WebName);
    // ������� ����, ��� ������������ WebArm ����� ������� ����� �� ������ 3
      flag:= not ffp.ForClient and Cache.WareLinksUnLocked and
             Model.GetModelNodeIsSecondLink(NodeID) and
             (((Sys=constIsMoto) and empl.UserRoleExists(rolTNAManageMoto))
             or ((Sys=constIsAuto) and empl.UserRoleExists(rolTNAManageAuto))
             or ((Sys=constIsCV) and empl.UserRoleExists(rolTNAManageCV)));
StrPos:='4-2';
      List:= Cache.GetModelNodeWaresWithUsesByFilters(ModelID, NodeID, ShowChildWares, Filter);
    end;
    if (List.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundWares));

StrPos:='4-3';
    NodeName:= Cache.FDCA.AutoTreeNodesSys[Sys][NodeID].Name;
    ShowAnalogs:= ffp.ForClient and (List.Count<Cache.arClientInfo[ffp.UserID].MaxRowShowAnalogs);

    //---------- �������� ���� ��������� ������� ��� ��������� � ������� �������
    for i:= 0 to List.Count-1 do begin
      WareID:= integer(List.Objects[i]);
      ware:= Cache.GetWare(WareID);
      flMarket:= ware.IsMarketWare(ffp);
      try
        aar:= fnGetAllAnalogs(WareID);
        aar1:= ware.GetSatellites; // �����.������
        WA:= TSearchWareOrOnum.Create(WareID, Length(aar1), True, flMarket, aar);
      finally
        SetLength(aar, 0);
        SetLength(aar1, 0);
      end;
      WList.Add(WA);
      if flMarket then fnFindOrAddTwoCode(OLmarkets, WA.ID); // ���� ��������� �������

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
          tc.ID2:= 0;           // default - ������� ����������
          fnFindOrAddTwoCode(OLmarkets, tc.ID1); // ���� ��������� �������
        end else tc.ID2:= -1;
      end;
    end; // for i:= 0 to List.Count

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // ���� ��������� �������
    //--------------------------------------------------------- �������� �������
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, aCount); // ���������
      if (aCount>0) then begin            // ����������� �������� � �������
        for i:= 0 to WList.Count-1 do begin
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then // ��������� �������
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    aCount:= -1;

StrPos:='5';
    Stream.WriteBool(flag);
    Stream.WriteStr(NodeName);
    Stream.WriteStr(Filter);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if flSemafores then aCount:= WA.RestSem;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, WA.OLAnalogs.Count, WA.SatCount, aCount);

      if ShowAnalogs then for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if flSemafores then aCount:= tc.ID2;
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, aCount);
      end;
    end; // for i:= 0 to WList.Count

StrPos:='10';
//------------------------------------ ���.���� � ������������ ������� � �������
    aCount:= 0;
    aPos:= Stream.Position;
    Stream.WriteInt(aCount);
    for i:= 0 to List.Count-1 do if (List.Strings[i]<>'') then begin
      j:= Integer(List.Objects[i]);
      s:= List[i];
      Stream.WriteInt(j);
      Stream.WriteStr(s);
      Inc(aCount);
    end;
    Stream.Position:= aPos;
    Stream.WriteInt(aCount);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
  Stream.Position:= 0;
  prFree(List);
  prFree(WList);
  prFree(OLmarkets);
  prFree(ffp);
end;
//================================ ����� ������� �� ������.������ (Web & WebArm)
procedure prCommonGetWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetWaresByOE'; // ��� ���������/�������
var UserId, FirmId, i, j, ManufID, ForFirmID, CurrID, WareID, iCount, contID: integer;
    Manuf, OE: string;
    ErrorPos: string;
    aiWareByON, aiAnalogs, aiSatells: Tai;
    PriceInUah, ShowAnalogs, flSemafores, flMarket: boolean;
    WList, OLmarkets: TObjectList;
    WA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ware: TWareInfo;
    ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  SetLength(aiWareByON, 0);
  WList:= TObjectList.Create;
  OLmarkets:= TObjectList.Create;
  ffp:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;

ErrorPos:='00';
    prSetThLogParams(ThreadData, csGetWaresByOE, UserId, FirmID,
      'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID));
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

ErrorPos:='05';
    if not Cache.FDCA.Manufacturers.ManufExistsByName(Manuf, ManufID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, Manuf));

ErrorPos:='10';
    i:= Cache.FDCA.SearchOriginalNum(ManufID, fnDelSpcAndSumb(OE));
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrNum)+' "'+OE+'"');

    aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // ������ � ��
    iCount:= Length(aiWareByON);
    if (iCount<1) then raise EBOBError.Create(MessText(mtkNotFoundWares)+
                                             ' � ������������ ������� "'+OE+'"');

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    ShowAnalogs:= not ffp.ForClient and (iCount<=Cache.arClientInfo[UserID].MaxRowShowAnalogs);

    //---------- �������� ���� ��������� ������� ��� ��������� � ������� �������
    for i:= 0 to High(aiWareByON) do begin
      WareID:= aiWareByON[i];
      ware:= Cache.GetWare(WareID);
      if ware.IsPrize then Continue;

      flMarket:= ware.IsMarketWare(ffp);
      try
        aiAnalogs:= fnGetAllAnalogs(WareID);
        aiSatells:= ware.GetSatellites; // �����.������
        WA:= TSearchWareOrOnum.Create(WareID, Length(aiSatells), True, flMarket, aiAnalogs);
      finally
        SetLength(aiAnalogs, 0);
        SetLength(aiSatells, 0);
      end;
      if flMarket then fnFindOrAddTwoCode(OLmarkets, WA.ID); // ���� ��������� �������
      WList.Add(WA);

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
          tc.ID2:= 0;           // default - ������� ����������
          fnFindOrAddTwoCode(OLmarkets, tc.ID1); // ���� ��������� �������
        end else tc.ID2:= -1;
      end;
    end; // for i:= 0 toHigh(aiWareByON)

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // ���� ��������� �������
    //--------------------------------------------------------- �������� �������
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, iCount); // ���������
      if (iCount>0) then begin
        for i:= 0 to WList.Count-1 do begin    // ����������� �������� � �������
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then // ��������� �������
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    iCount:= -1;

ErrorPos:='15';
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if flSemafores then iCount:= WA.RestSem;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, WA.OLAnalogs.Count, WA.SatCount, iCount);

      if ShowAnalogs then for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if flSemafores then iCount:= tc.ID2;
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, iCount);
      end;
    end; // for i:= 0 to WList.Count
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(aiWareByON, 0);
  prFree(WList);
  prFree(OLmarkets);
  Stream.Position:= 0;
  prFree(ffp);
end;
//============================ ����� ������� �� ������.������ �� Laximo (WebArm)
procedure prSearchWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSearchWaresByOE'; // ��� ���������/�������
      arManufDuo: array [0..3] of string = ('LEXUS','TOYOTA','INFINITI','NISSAN');
var UserId, FirmId, ContID, i, j, ManufID, ForFirmID, CurrID, iCount, m, pline, WareID: integer;
    Manuf, OE, ManufDuo, ErrorPos, mess: string;
    aiWareByON, aiAnalogs, aiSatells: Tai;
    PriceInUah, ShowAnalogs, flSemafores, flMarket: boolean;
    iListM, iListW, lst: TIntegerList;  // lst - not Free !!!
    IBSORD: TIBSQL;
    IBORD: TIBDatabase;
    WList, OLmarkets: TObjectList;
    WA: TSearchWareOrOnum;
    tc: TTwoCodes;
    ware: TWareInfo;
    ffp: TForFirmParams;
begin
  IBSORD:= nil;
//  IBORD:= nil;
  Stream.Position:= 0;
  SetLength(aiWareByON, 0);
  WList:= TObjectList.Create;
  OLmarkets:= TObjectList.Create;
  ShowAnalogs:= False;
  ffp:= nil;
  try try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt;       // ��� ����������
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;
    pline:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWaresByOE, UserID, FirmID, 'OE='+OE+
      #13#10'Manuf='+Manuf+#13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID)); // �����������
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������

    if (Manuf='') then raise EBOBError.Create('������������ �������� �������������');
    if (OE='') then raise EBOBError.Create('������������ �������� ������������� ������');

    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    IBORD:= cntsORD.GetFreeCnt;
    try try
      IBSORD:= fnCreateNewIBSQL(IBORD, 'IBSORD_'+nmProc, -1, tpWrite, true);
      IBSORD.SQL.Text:='execute procedure LAXIMOSAVECLICKPROTONLINE('+IntToStr(pline)+')';
      IBSORD.ExecQuery;
      if IBSORD.Transaction.InTransaction then IBSORD.Transaction.Commit;
    except
      on E: Exception do prMessageLOGS(nmProc+': ' +E.Message+
        ' (ErrorPos='+ErrorPos+'), SQL.Text='+IBSORD.SQL.Text, 'error' , false);
    end;
    finally
      prFreeIBSQL(IBSORD);
      cntsORD.SetFreeCnt(IBORD);
    end;

    mess:= MessText(mtkNotFoundWares)+' � ������������ ������� "'+OE+'"';
    iListM:= TIntegerList.Create; // ���� ��������������
    iListW:= TIntegerList.Create; // ���� �������
    try
      i:= Cache.BrandLaximoList.IndexOf(Manuf);
      if (i>-1) then begin
        lst:= TIntegerList(Cache.BrandLaximoList.Objects[i]);
        for i:= 0 to lst.Count-1 do iListM.Add(lst[i]);
      end;
      m:= fnInStrArray(Manuf, arManufDuo);
      if (m>-1) then begin
        if Odd(m) then ManufDuo:= arManufDuo[m-1] // �������� ������
                  else ManufDuo:= arManufDuo[m+1];
        Manuf:= {'"'+}Manuf+{'", "'}''', '''+ManufDuo{+'"'};
        i:= Cache.BrandLaximoList.IndexOf(ManufDuo);
        if i>-1 then begin
          lst:= TIntegerList(Cache.BrandLaximoList.Objects[i]);
          for i:= 0 to lst.Count-1 do iListM.Add(lst[i]);
        end;
      end; // if (m>-1)
      if (iListM.Count<1) then raise EBOBError.Create(mess);
  ErrorPos:='10';

      OE:= fnDelSpcAndSumb(OE);
      for m:= 0 to iListM.Count-1 do try //------ �������� ���� ������� � iListW
        ManufID:= iListM[m];
        if not Cache.FDCA.Manufacturers.ManufExists(ManufID) then continue;
        i:= Cache.FDCA.SearchOriginalNum(ManufID, OE);
        if (i<0) then continue;

        aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // ������ � ��
        for i:= 0 to High(aiWareByON) do begin
          WareID:= aiWareByON[i];
          ware:= Cache.GetWare(WareID);
          if ware.IsPrize then Continue;
          iListW.Add(WareID);
        end;
      finally
        SetLength(aiWareByON, 0);
      end; //  for m:= 0 to iList.Count-1
      if (iListW.Count<1) then raise EBOBError.Create(mess);

      ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

      ShowAnalogs:= ffp.ForClient and (iListW.Count<=Cache.arClientInfo[UserID].MaxRowShowAnalogs);

      //-------- �������� ���� ��������� ������� ��� ��������� � ������� �������
      for i:= 0 to iListW.Count-1 do begin
        WareID:= iListW[i];
        ware:= Cache.GetWare(WareID);
        flMarket:= ware.IsMarketWare(ffp);
        try
          aiAnalogs:= fnGetAllAnalogs(WareID);
          aiSatells:= ware.GetSatellites; // �����.������
          WA:= TSearchWareOrOnum.Create(WareID, Length(aiSatells), True, flMarket, aiAnalogs);
        finally
          SetLength(aiAnalogs, 0);
          SetLength(aiSatells, 0);
        end;
        if flMarket then fnFindOrAddTwoCode(OLmarkets, WA.ID); // ���� ��������� �������
        WList.Add(WA);

        if not ShowAnalogs then Continue;

        for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
          tc:= TTwoCodes(WA.OLAnalogs[j]);
          if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
            tc.ID2:= 0;           // default - ������� ����������
            fnFindOrAddTwoCode(OLmarkets, tc.ID1); // ���� ��������� �������
          end else tc.ID2:= -1;
        end;
      end; // for i:= 0 to iListW.Count
    finally
      prFree(iListM);
      prFree(iListW);
    end;

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // ���� �������� ��������� �������
    //--------------------------------------------------------- �������� �������
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, iCount); // ���������
      if (iCount>0) then begin
        for i:= 0 to WList.Count-1 do begin    // ����������� �������� � �������
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // �������
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then // ��������� ������� ������
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    iCount:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);    // ����� ������ �� ��
    Stream.WriteStr(Manuf);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if flSemafores then iCount:= WA.RestSem;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, WA.OLAnalogs.Count, WA.SatCount, iCount);

      if ShowAnalogs then for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if flSemafores then iCount:= tc.ID2;
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, iCount);
      end;
    end; // for i:= 0 to WList.Count
    Stream.WriteStr('WaresByOE');
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  finally
    Stream.Position:= 0;
    SetLength(aiWareByON, 0);
    prFree(WList);
    prFree(OLmarkets);
    prFree(ffp);
  end;
end;
//================================ ����� ������� �� ��������� ��������� (WebArm)
procedure prCommonSearchWaresByAttr(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonSearchWaresByAttr'; // ��� ���������/�������
var UserID, FirmID, i, ForFirmID, CurrID, aCount, contID, grpID, ii: Integer;
    attCodes, valCodes, aar: Tai;
    PriceInUAH, flSemafores, flMarket, flGBatt: boolean;
    WList, OLmarkets: TObjectList;
    WA: TSearchWareOrOnum;
    ware: TWareInfo;
    ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  currID:= 0;
  WList:= TObjectList.Create;
  OLmarkets:= TObjectList.Create;
  ffp:= nil;
  grpID:= 0;
  flGBatt:= False;
  contID:= 0;
  PriceInUAH:= False;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    aCount:= Stream.ReadInt;  // ���-�� ���������
    try
      if (aCount<1) then raise EBOBError.Create(MessText(mtkNotParams));
      SetLength(attCodes, aCount);
      SetLength(valCodes, aCount);
      for i:= 0 to aCount-1 do begin
        attCodes[i]:= Stream.ReadInt;
        valCodes[i]:= Stream.ReadInt;
        if (i=0) then flGBatt:= (attCodes[i]>cGBattDelta);
        if (grpID<1) then //------------------ ��������� ������ ��� �����������
          if flGBatt then begin
            ii:= attCodes[i]-cGBattDelta;
            if Cache.GBAttributes.ItemExists(ii) then
              grpID:= Cache.GBAttributes.GetAtt(ii).Group;
            if (grpID>0) then grpID:= grpID+cGBattDelta;
          end else if Cache.Attributes.ItemExists(attCodes[i]) then
            grpID:= Cache.Attributes.GetAttr(attCodes[i]).SubCode;
      end; // for i:= 0 to aCount-1
      PriceInUAH:= Stream.ReadBool;
      ForFirmID:= Stream.ReadInt;
      ContID:= Stream.ReadInt; // ��� ����������
    finally
      prSetThLogParams(ThreadData, csSearchWaresByAttrValues, UserId, FirmID,
        'pCount='+IntToStr(aCount)+#13#10'grpID='+IntToStr(grpID)+
        #13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID));
    end;
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    if flGBatt then begin // �������� Grossbee
      for i:= 0 to aCount-1 do begin  // ������� ������ �����
        attCodes[i]:= attCodes[i]-cGBattDelta;
        valCodes[i]:= valCodes[i]-cGBattDelta;
      end;
      attCodes:= Cache.SearchWaresByGBAttValues(attCodes, valCodes);

    end else // �������� ORD
      attCodes:= Cache.SearchWaresByAttrValues(attCodes, valCodes);

    if (Length(attCodes)<1) then raise EBOBError.Create(MessText(mtkNotFoundWares));

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    //---------- �������� ���� ��������� ������� ��� ��������� � ������� �������
    for i:= 0 to High(attCodes) do begin
      ware:= Cache.GetWare(attCodes[i]);
      if ware.IsPrize then Continue;
      flMarket:= ware.IsMarketWare(ffp);
      if not flMarket then Continue; // ����� ����� ������ ��������� ������
      try
        aar:= ware.GetSatellites; // �����.������
        WA:= TSearchWareOrOnum.Create(attCodes[i], Length(aar), True, flMarket);
      finally
        SetLength(aar, 0);
      end;
      fnFindOrAddTwoCode(OLmarkets, WA.ID); // ���� ��������� �������
      WList.Add(WA);
    end; // for i:= 0 to List.Count

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // ���� ��������� �������
    //--------------------------------------------------------- �������� �������
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, aCount); // ���������
      if (aCount>0) then begin
        for i:= 0 to WList.Count-1 do begin    // ����������� �������� � �������
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // ��������� ������
    aCount:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(false); // ��� �������������
    Stream.WriteInt(WList.Count);          //------------------- �������� ������
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if flSemafores then aCount:= WA.RestSem;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, 0, WA.SatCount, aCount);
    end; // for i:= 0 to WList.Count
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(attCodes, 0);
  SetLength(valCodes, 0);
  SetLength(aar, 0);
  prFree(WList);
  prFree(OLmarkets);
  prFree(ffp);
  Stream.Position:= 0;
end;
//=============================== ����� ��������� ������� ������� (Web & WebArm)
procedure prCommonGetRestsOfWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetRestsOfWares'; // ��� ���������/�������
var UserId, FirmID, NodeID, ModelID, WareCode, iCount, i, j, iSem,
      ForFirmID, iPos, CurrID, ContID: integer;
    WareCodes: string;
    First: Tas;
    Second, StorageCodes: Tai;
    Ware: TWareInfo;
//    Firm: TFirmInfo;
//    Contract: TContract;
//    flAdd: boolean;
    OList: TObjectList;
begin
  Stream.Position:= 0;
  SetLength(First, 0);
  SetLength(StorageCodes, 0);
  OList:= nil;
  try
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    WareCodes:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetRestsOfWares, UserID, FirmID, // �����������
      'WareCodes='+WareCodes+' ModelID='+IntToStr(ModelID)+' NodeID='+IntToStr(NodeID)+
      ' ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID));

    iCount:= 0;
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    iPos:= Stream.Position;
    Stream.WriteInt(iCount);

    if WareCodes='' then Exit;

    if (FirmID<>IsWe) then ForFirmID:= FirmID
    else if (ForFirmID<1) then Exit; // �� ���� ���������� ��� ForFirmID<1

    First:= fnSplitString(WareCodes, ',');
               // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, False, ContID);

    SetLength(Second, 0);
    for i:= 0 to High(First) do begin
      WareCode:= StrToIntDef(trim(First[i]), 0);
      if (WareCode>0) and Cache.WareExist(WareCode) then begin
        Ware:= Cache.GetWare(WareCode);
        if not Ware.IsMarketWare(ForFirmID, contID) then Continue;
        prAddItemToIntArray(WareCode, Second);
      end;
    end;
    if (Length(Second)<1) then Exit;

//    i:=
    fnGetContMainStoreAndStoreCodes(ForFirmID, ContID, StorageCodes);
    if (Length(StorageCodes)<1) then Exit; // �� ������� ������

    for i:= 0 to High(Second) do begin
      iSem:= 0;

      OList:= Cache.GetWareRestsByStores(Second[i]); // Webarm - prCommonGetRestsOfWares
      try
        for j:= 0 to OList.Count-1 do with TCodeAndQty(OList[j]) do
          if ((fnInIntArray(ID, StorageCodes)>-1) and (Qty>constDeltaZero)) then begin
            iSem:= 2;
            break;
          end;
      finally
        prFree(OList);
      end;

      Stream.Writeint(Second[i]);
      Stream.Writeint(iSem);
      Inc(iCount);
    end;

    if (iCount>0) then begin
      Stream.Position:= iPos;
      Stream.Writeint(iCount);
    end;
  except
    on E: Exception do begin
      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ������ ������ �� ������
      Stream.WriteInt(0);
    end;
  end;
  Stream.Position:= 0;
  SetLength(First, 0);
  SetLength(Second, 0);
  SetLength(StorageCodes, 0);
end;
{//======================================================= �������� ��������� �/�
procedure prWebArmGetFirmInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmInfo'; // ��� ���������/�������
var EmplID, ForFirmID, LineCount, sPos, k, i, ContID: integer;
    s: string;
    firm: TFirmInfo;
    Contract: TContract;
    fl: boolean;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    EmplID:= Stream.ReadInt;          // ��� �����
    ForFirmID:= Stream.ReadInt;          // ��� �����������
//    ContID:= Stream.ReadInt; // ��� ���������� - ������� ������

    prSetThLogParams(ThreadData, csGetClientData, EmplID, 0, 'FirmID='+IntToStr(ForFirmID)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s);
    if not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    Cache.TestFirms(ForFirmID, True, True, False);
    if not Cache.FirmExist(ForFirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

    Stream.WriteStr(firm.Name);   // ������������ �����
    Stream.WriteDouble(Contract.CredLimit);
    Stream.WriteDouble(Contract.DebtSum);
    Stream.WriteDouble(Contract.OrderSum);
    Stream.WriteDouble(Contract.PlanOutSum);
    Stream.WriteInt(Contract.CredCurrency);
    Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency, False));
    Stream.WriteStr(Cache.GetCurrName(Contract.DutyCurrency, False));

    s:= Contract.WarnMessage;
    Stream.WriteInt(Contract.Status);
    fl:= Contract.SaleBlocked;
    Stream.WriteStr(s);
    Stream.WriteBool(fl);
    Stream.WriteDouble(Contract.RedSum);
    Stream.WriteDouble(Contract.VioletSum);
    Stream.WriteInt(Contract.CredDelay);
    if not fl then Stream.WriteInt(Contract.WhenBlocked); // ���� �������� �� �����������

    //-------------- �������� ��� ������ �������������� ��������� �����
    LineCount:= 0;       // �������
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  ����� ��� ���-�� �������
    for i:= 0 to High(Contract.ContStorages) do if Contract.ContStorages[i].IsReserve then begin
      k:= Contract.ContStorages[i].DprtID;
      if not Cache.CheckEmplVisStore(EmplID, ForFirmID) then Continue; // �������� ��������� ������ ����������
      Stream.WriteInt(k);                        // ��� ������
      Stream.WriteStr(Cache.GetDprtMainName(k)); // ������������ ������
      inc(LineCount);
    end;
    if (LineCount>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(LineCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end; }
//=================================== �������� ������� �� ������ � ������� �����
procedure prWebArmShowFirmWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmShowFirmWareRests'; // ��� ���������/�������
var EmplID, ForFirmID, WareID, spos, LineCount, k, i, ContID: integer;
    s: string;
    Ware: TWareInfo;
    firm: TFirmInfo;
    dprt: TDprtInfo;
    Rest: Double;
    link: TQtyLink;
    Contract: TContract;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    EmplID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // ��� ����������

    prSetThLogParams(ThreadData, csWebArmShowFirmWareRests, EmplID, 0, // �����������
      'ForFirmID='+IntToStr(ForFirmID)+' WareID='+IntToStr(WareID)+#13#10'ContID='+IntToStr(ContID));

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FirmExist(ForFirmID) // �������� �����
      {or not Cache.CheckEmplVisFirm(EmplID, ForFirmID)} then
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    Ware:= Cache.GetWare(WareID, True);
    if not Assigned(Ware) or (Ware=NoWare) or Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteStr(Ware.Name); // ������������ ������

    //------------------------------- �������� ������� �� ���� ������� ���������
    LineCount:= 0;       // �������
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  ����� ��� ���-�� �������

    k:= Contract.MainStorage;
    Rest:= 0;
    if Assigned(ware.RestLinks) then begin
      link:= ware.RestLinks[k];
      if Assigned(link) then Rest:= link.Qty;
    end;
    Stream.WriteStr(Cache.GetDprtMainName(k));     // ������������ �������� ������
    Stream.WriteStr(IntToStr(round(Rest)));        // ���-��
    inc(LineCount);
    dprt:= Cache.arDprtInfo[k];
    for i:= 0 to dprt.StoresFrom.Count-1 do begin
      k:= TTwoCodes(dprt.StoresFrom[i]).ID1;
      Rest:= 0;
      if Assigned(ware.RestLinks) then begin
        link:= ware.RestLinks[k];
        if Assigned(link) then Rest:= link.Qty;
      end;
      Stream.WriteStr(Cache.GetDprtMainName(k));     // ������������ ������ ��������
      Stream.WriteStr(IntToStr(round(Rest)));        // ���-��
      inc(LineCount);
    end;

    if (LineCount>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(LineCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//====================================== �������� ������ ������ � ������ �������
procedure prWebArmGetFilteredAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFilteredAccountList'; // ��� ���������/�������
var EmplID, j, sPos, filtCurrency, filtStorage, filtShipMethod, filtForFirmID, filtContractID,
      filtShipTimeID, filtProcessed, filtWebAccount, filtBlocked, fid, sid: integer;
    s: string;
    GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    empl: TEmplInfoItem;
    filtFromDate, filtToDate, filtShipDate: TDate;
    filtExecuted, filtAnnulated, flSkip: Boolean;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  try
    EmplID      := Stream.ReadInt;    // ��� ����������
    filtFromDate:= Stream.ReadDouble; // ���� ��, 0 - �� ������
    filtToDate  := Stream.ReadDouble; // ���� ��, 0 - �� ������
    filtCurrency:= Stream.ReadInt;    // ��� ������, <1 - ���
    filtStorage := Stream.ReadInt;    // ��� ������, <1 - ���
    filtShipMethod:= Stream.ReadInt;    // ��� ������ ��������, <1 - ���
    filtShipDate:= Stream.ReadDouble; // ���� ��������, 0 - �� ������
    filtShipTimeID:= Stream.ReadInt;    // ��� ������� ��������, <1 - ���
    filtExecuted:= Stream.ReadBool;   // �����������: False - �� ����������, True - ����������
    filtAnnulated:= Stream.ReadBool;   // �������������: False - �� ����������, True - ����������
    filtProcessed:= Stream.ReadInt;    // -1 - ���, 0 - ��������������, 1 - ������������
    filtWebAccount:= Stream.ReadInt;    // -1 - ���, 0 - �� Web-�����, 1 - Web-�����
    filtBlocked := Stream.ReadInt;    // -1 - ���, 0 - �� �������������, 1 - �������������
    filtForFirmID:= Stream.ReadInt;    // ��� �����������, <1 - ���
    filtContractID:= Stream.ReadInt;    // ��� ���������, <1 - ���

    prSetThLogParams(ThreadData, csLoadAccountList, EmplID, 0, 'filtForFirmID='+IntToStr(filtForFirmID)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    s:= ''; // ��������� ������ ������� �������
    if (filtForFirmID>0) then begin         // ���� ������ ����� - �������� ���������
      if not Cache.FirmExist(filtForFirmID) {or not Cache.CheckEmplVisFirm(EmplID, filtForFirmID)} then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
      s:= s+fnIfStr(s='', '', ' and ')+' PInvRecipientCode='+IntToStr(filtForFirmID);
    end;
    if (filtContractID>0) then begin
      if not Cache.Contracts.ItemExists(filtContractID) then
        raise EBOBError.Create(MessText(mtkNotFoundCont));
      s:= s+fnIfStr(s='', '', ' and ')+' PINVCONTRACTCODE='+IntToStr(filtContractID);
    end;
    if (filtStorage>0) then begin           // ���� ����� ����� - �������� ���������
      if not Cache.DprtExist(filtStorage) {or not Cache.CheckEmplVisStore(EmplID, filtStorage)} then
        raise EBOBError.Create(MessText(mtkNotDprtExists));
      s:= s+fnIfStr(s='', '', ' and ')+' PInvSupplyDprtCode='+IntToStr(filtStorage);
    end else s:= s+fnIfStr(s='', '', ' and ')+' not PInvSupplyDprtCode is null';

    if Cache.DocmMinDate>filtFromDate then filtFromDate:= Cache.DocmMinDate;
    if (filtFromDate>DateNull) then               // ���� ��
      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate>=:filtFromDate';
    if (filtToDate>DateNull) then begin           // ���� ������ ���� ��
      if (Cache.DocmMinDate>filtToDate) then filtToDate:= Cache.DocmMinDate;
      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate<=:filtToDate';
    end;
//    if (filtFromDate<1) and (filtToDate<1) then // ���� ��/�� �� ������ - �� �����        ???
//      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate>DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_TIMESTAMP)-30, CURRENT_TIMESTAMP)';

    if (filtCurrency>0) then begin              // ���� ������ ������
      if not Cache.CurrExists(filtCurrency) then raise EBOBError.Create('�� ������� ������');
      s:= s+fnIfStr(s='', '', ' and ')+' PInvCrncCode='+IntToStr(filtCurrency);
    end;
    if not filtExecuted then                   // ����������� �� ����������
      s:= s+fnIfStr(s='', '', ' and ')+' (SbCnCode is null or INVCCODE is null)';
    if not filtAnnulated then                  // ������������� �� ����������
      s:= s+fnIfStr(s='', '', ' and ')+' PINVANNULKEY="F"';
    if (filtProcessed>-1) then                 // ��������������/������������
      if (filtProcessed=0) then s:= s+fnIfStr(s='', '', ' and ')+' PINVPROCESSED="F"'
      else if (filtProcessed=1) then s:= s+fnIfStr(s='', '', ' and ')+' PINVPROCESSED="T"';
    if (filtBlocked>-1) then                   // �� �������������/�������������
      if (filtBlocked=0) then s:= s+fnIfStr(s='', '', ' and ')+' PInvLocked="F"'
      else if (filtBlocked=1) then s:= s+fnIfStr(s='', '', ' and ')+' PInvLocked="T"';
    if (filtWebAccount>-1) then                 // �� Web-�����/Web-�����
      if (filtWebAccount=0) then
        s:= s+fnIfStr(s='', '', ' and ')+' (PINVWEBCOMMENT is null or PINVWEBCOMMENT="")'
      else if (filtWebAccount=1) then
        s:= s+fnIfStr(s='', '', ' and ')+' (not PINVWEBCOMMENT is null and PINVWEBCOMMENT>"")';
    if (filtShipDate>DateNull) then                    // ���� ������ ���� ��������
      s:= s+fnIfStr(s='', '', ' and ')+' PINVSHIPMENTDATE=:filtShipDate';
    if (filtShipMethod>0) then begin            // ���� ����� ����� ��������
      if not Cache.ShipMethods.ItemExists(filtShipMethod) then
        raise EBOBError.Create('�� ������ ����� ��������');
      if (filtShipTimeID>0) and Cache.GetShipMethodNotTime(filtShipMethod) then
        raise EBOBError.Create('���� ����� �������� - ��� �������� �������');
      s:= s+fnIfStr(s='', '', ' and ')+' PINVSHIPMENTMETHODCODE='+IntToStr(filtShipMethod);
    end;
    if (filtShipTimeID>0) then begin            // ���� ������ ����� ��������
      if not Cache.ShipTimes.ItemExists(filtShipTimeID) then
        raise EBOBError.Create('�� ������� ����� ��������');
      s:= s+fnIfStr(s='', '', ' and ')+' PINVSHIPMENTTIMECODE='+IntToStr(filtShipTimeID);
    end;

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select PInvCode, PInvNumber, PInvDate, PInvSumm, PINVPROCESSED,'+
        ' PInvLocked, PINVCLIENTCOMMENT, PInvCrncCode, u.uslsusername, PINVSHIPMENTDATE,'+ // ��������
        ' iif(TRTBSHIPMETHODCODE is null, PINVSHIPMENTMETHODCODE, TRTBSHIPMETHODCODE) PINVSHIPMENTMETHODCODE,'+
        ' iif(TRTBSHIPTIMECODE is null, PINVSHIPMENTTIMECODE, TRTBSHIPTIMECODE) PINVSHIPMENTTIMECODE,'+
        ' PInvRecipientCode, PInvSupplyDprtCode, PINVANNULKEY, PINVCOMMENT, PINVCONTRACTCODE,'+ // , c.CONTBUSINESSTYPECODE
//        ' c.contnumber, c.contbeginingdate,'+
        ' gn.rNum contnumber, iif(SbCnCode is null or INVCCODE is null, "F", "T") as pExecuted'+     // ???
        ' from PayInvoiceReestr'+
        ' left join TRANSPORTTIMETABLESLINES on TRTBLNCODE=pinvtripcode'+
        ' left join TRANSPORTTIMETABLESREESTR on TRTBCODE=TRTBLNDOCMCODE'+
        ' left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' left join CONTRACT c on c.contcode=PINVCONTRACTCODE'+
        ' left join Vlad_CSS_GetFullContNum(c.contnumber, c.contnkeyyear, c.contpaytype) gn on 1=1'+
        ' left join PROTOCOL pp on pp.ProtObjectCode=pinvcode'+
        '   and pp.ProtObjectType=55 and pp.ProtOperType=1'+ // ��������� �����
        ' left join userlist u on u.UsLsUserID=pp.ProtUserID'+
        ' WHERE '+s+' ORDER BY PInvNumber';
      if (filtFromDate>DateNull) then GBIBS.ParamByName('filtFromDate').AsDateTime:= filtFromDate;
      if (filtToDate>DateNull)   then GBIBS.ParamByName('filtToDate').AsDateTime:= filtToDate;
      if (filtShipDate>DateNull) then GBIBS.ParamByName('filtShipDate').AsDateTime:= filtShipDate;
      GBIBS.ExecQuery;

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      sPos:= Stream.Position;
      Stream.WriteInt(0); // ����� ��� ���-�� ������
      j:= 0;
      while not GBIBS.EOF do begin
        sid:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger; // ��������� �����
        flSkip:= False;
        if (filtStorage<>sid) then begin
          flSkip:= not Cache.DprtExist(sid); // or not Cache.CheckEmplVisStore(EmplID, sid);
          if not flSkip then with Cache.arDprtInfo[sid] do
            flSkip:= not (IsStoreHouse or IsStoreRoad);
        end;
        if flSkip then begin
          GBIBS.Next;
          Continue;
        end;
        fid:= GBIBS.FieldByName('PInvRecipientCode').AsInteger;  // ��������� �/�
        flSkip:= False;
        if (filtForFirmID<>fid) then with Cache do
          flSkip:= not FirmExist(fid); // or not CheckEmplVisFirm(EmplID, fid);
        if flSkip then begin
          GBIBS.Next;
          Continue;
        end;
        Stream.WriteBool(GetBoolGB(GBibs, 'PInvLocked'));  // ������� ���������� �����
        Stream.WriteInt(GBIBS.FieldByName('PInvCode').AsInteger);
        Stream.WriteBool(GetBoolGB(GBibs, 'PINVPROCESSED'));         // ���������
        Stream.WriteBool(GetBoolGB(GBibs, 'PINVANNULKEY'));          // �����������
        Stream.WriteBool(GetBoolGB(GBibs, 'pExecuted'));             // ��������
        Stream.WriteBool(CheckShipmentDateTime(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDate,
                         GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger));   // ���������� ��������
        Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString);
        Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('PInvDate').AsDateTime));
        Stream.WriteInt(fid);                                        // ��� �/�
        Stream.WriteStr(Cache.arFirmInfo[fid].Name);                 // ������������ �/�
        Stream.WriteInt(GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger);
        Stream.WriteBool(False); // �������� - is moto
//        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString+'-'+
//          FormatDateTime('yy', GBIBS.FieldByName('CONTBEGININGDATE').AsDateTime));
        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString);
        Stream.WriteInt(sid);                                        // �����
        Stream.WriteDouble(GBIBS.FieldByName('PInvSumm').AsFloat);
        Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('PInvCrncCode').AsInteger, False));
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger); // ����� ��������
        Stream.WriteDouble(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDate);       // ���� ��������
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger);   // ����� ��������
        Stream.WriteStr(GBIBS.FieldByName('uslsusername').AsString);            // ��������� �����
        Stream.WriteStr(GBIBS.FieldByname('PINVCOMMENT').AsString);
        Stream.WriteStr(fnReplaceQuotedForWeb(GBIBS.FieldByname('PINVCLIENTCOMMENT').AsString));

        cntsGRB.TestSuspendException;
        GBIBS.Next;
        Inc(j);
      end;
      GBIBS.Close;
      if (j>0) then begin
        Stream.Position:= sPos;
        Stream.WriteInt(j); // �������� ���-��
      end;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//===================================== �������� ���� (���� ��� - ������� �����)
procedure prWebArmShowAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmShowAccount'; // ��� ���������/�������
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    EmplID, ForFirmID, AccountID, spos, LineCount, k, curr, i, iStore, ContID: integer;
    AccountCode, FirmCode, s, sh: string;
    Ware: TWareInfo;
    empl: TEmplInfoItem;
    firm: TFirmInfo;
    sum: Double;
    Success: boolean;
    Contract: TContract;
  //----------------------------------------- �������� �����
  procedure CheckFirm(firmID: Integer);
  begin
    if (firmID<1) or Assigned(Firm) then Exit;
    if not Cache.FirmExist(firmID) {or not Cache.CheckEmplVisFirm(EmplID, firmID)} then
      raise EBOBError.Create(MessText(mtkNotFirmExists));
    Cache.TestFirms(firmID, True, True, False);
    if ForFirmID<>firmID then ForFirmID:= firmID;
    FirmCode:= IntToStr(ForFirmID);
    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);
  end;
  //-----------------------------------------
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  firm:= nil;
  contID:= 0;
  try
    EmplID:= Stream.ReadInt;
    AccountID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt;       // ��� ���������� - ����� �� �����

    AccountCode:= IntToStr(AccountID);
    FirmCode:= IntToStr(ForFirmID);

    prSetThLogParams(ThreadData, csWebArmShowAccount, EmplID, 0,
      'ForFirmID='+FirmCode+' AccountID='+AccountCode+#13#10'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if (ForFirmID>0) then CheckFirm(ForFirmID);  // �������� ����� (���� ����� ForFirmID)

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead);
//------------------------------ ����� ���� ------------------------------------
      if (AccountID=-1) and Assigned(Firm) then begin
        k:= Contract.MainStorage; // ����� �� ���������
        fnSetTransParams(GBIBS.Transaction, tpWrite, True);
        curr:= Contract.DutyCurrency;
        GBIBS.SQL.Text:= 'Select NewAccCode, NewDprtCode'+ // �������� ��� ������ �����
          ' from Vlad_CSS_AddAccHeaderC('+FirmCode+', '+IntToStr(ContID)+', '+
          IntToStr(k)+', '+IntToStr(curr)+', "")';

        Success:= false;
        for i:= 1 to RepeatCount do try
          GBIBS.Close;
          with GBIBS.Transaction do if not InTransaction then StartTransaction;
          GBIBS.ExecQuery;
          if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('������ �������� �����');

          if GBIBS.FieldByName('NewDprtCode').AsInteger<>k then // �������� ������ ������ (�� ����.������)
            raise EBOBError.Create('������ �������� ����� �� ������ '+Cache.GetDprtMainName(k));

          AccountID:= GBIBS.FieldByName('NewAccCode').AsInteger;
          AccountCode:= IntToStr(AccountID);

          GBIBS.Close;
          GBIBS.SQL.Text:= 'update PayInvoiceReestr set'+ // ����� ����������� �����������
            ' PINVCOMMENT=:comm where PInvCode='+AccountCode;
          GBIBS.ParamByName('comm').AsString:= cWebArmComment;
          GBIBS.ExecQuery;

          GBIBS.Transaction.Commit;
          GBIBS.Close;
          Success:= true;
          break;
        except
          on E: EBOBError do raise EBOBError.Create(E.Message);
          on E: Exception do
            if (Pos('lock', E.Message)>0) and (i<RepeatCount) then begin
              with GBIBS.Transaction do if InTransaction then RollbackRetaining;
              GBIBS.Close;
              sleep(RepeatSaveInterval);
            end else raise Exception.Create(E.Message);
        end;
        GBIBS.Close;
        if not Success then raise EBOBError.Create('������ �������� �����');

        fnSetTransParams(GBIBS.Transaction, tpRead);
      end;
//------------------------------- ������� ����� ���� ---------------------------

      with GBIBS.Transaction do if not InTransaction then StartTransaction;
      GBIBS.SQL.Text:= 'SELECT p1.PInvNumber, p1.PInvDate, p1.PInvProcessed, p1.PInvSumm,'+
        ' p1.PInvCrncCode, p1.PInvSupplyDprtCode, p1.PINVCOMMENT, p1.PINVWEBCOMMENT,'+
        ' p1.PINVCLIENTCOMMENT, p1.PInvLocked, p1.PINVWARELINECOUNT, p1.PINVANNULKEY,'+
        ' p2.PInvNumber AcntNumber, p2.PInvDate AcntDate, INVCCODE, u.uslsusername,'+
        ' p1.PINVSHIPMENTDATE,'+ // ��������
        ' iif(TRTBSHIPMETHODCODE is null, p1.PINVSHIPMENTMETHODCODE, TRTBSHIPMETHODCODE) PINVSHIPMENTMETHODCODE,'+
        ' iif(TRTBSHIPTIMECODE is null, p1.PINVSHIPMENTTIMECODE, TRTBSHIPTIMECODE) PINVSHIPMENTTIMECODE,'+
        ' p1.PInvRecipientCode, p2.PInvCode AcntCode, p1.PINVLABELCODE, p1.PINVCONTRACTCODE'+
        ' from PayInvoiceReestr p1'+
        ' left join TRANSPORTTIMETABLESLINES on TRTBLNCODE=p1.pinvtripcode'+
        ' left join TRANSPORTTIMETABLESREESTR tt on tt.TRTBCODE=TRTBLNDOCMCODE'+
        ' left join PROTOCOL pp on pp.ProtObjectCode=p1.pinvcode'+
        '   and pp.ProtObjectType=55 and pp.ProtOperType=1'+ // ��������� �����
        ' left join userlist u on u.UsLsUserID=pp.ProtUserID'+
        ' left join PayInvoiceReestr p2 on p2.PInvCode=p1.PINVSOURCEACNTCODE'+
        ' left join SUBCONTRACT on SbCnDocmCode=p1.PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' where p1.PInvCode='+AccountCode;
      GBIBS.ExecQuery;
      if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('�� ������ ���� � id='+AccountCode);
      s:= '���� '+GBIBS.FieldByName('PInvNumber').AsString;

//-------------------- ������� �� �������� ����� ------------------------------- ???
//      if GetBoolGB(GBibs, 'PInvLocked') then raise EBOBError.Create(s+' ����������');
//      if GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s+' �����������');
//      if GBIBS.FieldByName('INVCCODE').AsInteger>0 then raise EBOBError.Create(s+' ����������');
//-------------------- ������� �� �������� ����� -------------------------------

                                    // �������� ����� (���� �� ����� ForFirmID)
      if (ForFirmID<1) then CheckFirm(GBIBS.FieldByName('PInvRecipientCode').AsInteger);

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
      Stream.WriteBool(GetBoolGB(GBibs, 'PInvLocked'));
      Stream.WriteBool(GetBoolGB(GBibs, 'PINVANNULKEY'));
      Stream.WriteBool(GBIBS.FieldByName('INVCCODE').AsInteger>0);
//-------------------- �������� ��������� ����� --------------------------------
      Stream.WriteInt(ForFirmID);                                       // ��� ����������
      Stream.WriteStr(firm.UPPERSHORTNAME);                             // ������� ����. ����������
      Stream.WriteStr(firm.Name);                                       // ����. ����������
      i:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      contID:= i;
      if (Contract.ID<>contID) then Contract:= firm.GetContract(contID);
      if (i<>ContID) then raise EBOBError.Create(MessText(mtkNotFoundCont, IntToStr(i)));
      Stream.WriteInt(contID);                                          // ��� ���������
      Stream.WriteStr(Contract.Name);                                   // ������������ ���������
      Stream.WriteInt(Firm.FirmContracts.Count);                        // ���-�� ����������
//      Stream.WriteBool(Contract.SysID=constIsAuto);                     // �������� �� ��������������
      Stream.WriteBool(true);                     // ��������
      iStore:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
      Stream.WriteInt(iStore);                                          // ��� ������ �����
      curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
      Stream.WriteStr(Cache.GetCurrName(curr, False));                  // ������ �����
      Stream.WriteInt(AccountID);                                       // ��� �����
      Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString);        // ����� �����
      Stream.WriteDouble(GBIBS.FieldByName('PInvDate').AsDateTime);     // ����
      Stream.WriteBool(GetBoolGB(GBIBS, 'PInvProcessed'));              // ������� ���������

//      Stream.WriteBool(GetBoolGB(GBIBS, 'PInvLocked'));                // ������� ����������   ???

      sum:= GBIBS.FieldByName('PInvSumm').AsFloat;                      // ����� �����
      s:= fnGetStrSummByDoubleCurr(sum, curr);                          // ������ � ������ � 2-� �������
      Stream.WriteStr(s);
      Stream.WriteStr(GBIBS.FieldByName('PINVCOMMENT').AsString);       // ����������� �����������
      Stream.WriteStr(GBIBS.FieldByName('PINVWEBCOMMENT').AsString);    // ����������� WEB
      Stream.WriteStr(fnReplaceQuotedForWeb(GBIBS.FieldByName('PINVCLIENTCOMMENT').AsString)); // ����������� �������
      Stream.WriteInt(GBIBS.FieldByName('AcntCode').AsInteger);         // ��� ������������� �����
      s:= GBIBS.FieldByName('AcntNumber').AsString;                     // ����� � ���� ������������� �����
      if s<>'' then s:= s+' �� '+
        FormatDateTime(cDateFormatY2, GBIBS.FieldByName('AcntDate').AsDateTime);
      Stream.WriteStr(s);
      Stream.WriteStr(GBIBS.FieldByName('uslsusername').AsString);      // ��������� ����� (��������)

      with Cache.GetShipMethodsList(iStore) do try                      // ������ ������� �������� �� ������
        Stream.WriteInt(Count);
        for i:= 0 to Count-1 do begin
          Stream.WriteInt(Integer(Objects[i]));
          Stream.WriteStr(Strings[i]);
        end;
      finally
        Free;
      end;
      i:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
      Stream.WriteInt(i);                                                   // ��� ������ ��������
      if Cache.GetShipMethodNotTime(i) then k:= -1
      else k:= GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger;
      Stream.WriteInt(k);                                                   // ��� ������� ��������
      Stream.WriteDouble(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDateTime); // ���� ��������

      if Cache.GetShipMethodNotLabel(i) then k:= -1
      else k:= GBIBS.FieldByName('PINVLABELCODE').AsInteger;
      Stream.WriteInt(k);                                                   // ��� ��������

      LineCount:= GBIBS.FieldByName('PINVWARELINECOUNT').AsInteger; // ���-�� ����� ������� � �����
      GBIBS.Close;

      sh:= IntToStr(Cache.arFirmInfo[ForFirmID].HostCode);          // ������ ������� �������
      GBIBS.SQL.Text:= 'select FRLBCODE, FRLBNAME, FRLBFACENAME, FRLBPHONE,'+
        ' " " as FRLBCARRIER, FRLBDELIVERYTIME, FRLBCOMMENT from FIRMLABELREESTR'+   // ���� FRLBCARRIER ������
        ' where FRLBSUBJCODE='+sh+' and FRLBSUBJTYPE=1 and (FRLBARCHIVE="F" or FRLBCODE='+intToStr(k)+') ';
      sPos:= Stream.Position;
      k:= 0;
      Stream.WriteInt(0);  //  ����� ��� ���-�� �������
      GBIBS.ExecQuery;
      while not GBIBS.EOF do begin
        Inc(k);
        Stream.WriteInt(GBIBS.FieldByName('FRLBCODE').AsInteger);        // ��� ��������
        Stream.WriteStr(GBIBS.FieldByName('FRLBNAME').AsString);         //
        Stream.WriteStr(GBIBS.FieldByName('FRLBFACENAME').AsString);     //
        Stream.WriteStr(GBIBS.FieldByName('FRLBPHONE').AsString);        //
        Stream.WriteStr(GBIBS.FieldByName('FRLBCARRIER').AsString);      //
        Stream.WriteStr(GBIBS.FieldByName('FRLBDELIVERYTIME').AsString); //
        Stream.WriteStr(GBIBS.FieldByName('FRLBCOMMENT').AsString);      //
        TestCssStopException;
        GBIBS.Next;
      end;
      GBIBS.Close;
      if k>0 then begin
        Stream.Position:= sPos;
        Stream.WriteInt(k);
        Stream.Position:= Stream.Size;
      end;
//-------------------- �������� ��������� ����� --------------------------------

      sPos:= Stream.Position;
      Stream.WriteInt(0);  //  ����� ��� ���-�� �����
      if LineCount>0 then begin
//-------------------- �������� ������ ����� -----------------------------------
        LineCount:= 0;       // ������� - ���-�� �����
        GBIBS.SQL.Text:= 'select PInvLnCode, PInvLnWareCode, PInvLnOrder, PInvLnCount, PInvLnPrice'+
          ' from PayInvoiceLines where PInvLnDocmCode='+AccountCode;
        GBIBS.ExecQuery;
        while not GBIBS.EOF do begin
          k:= GBIBS.FieldByName('PInvLnWareCode').AsInteger;
          Ware:= Cache.GetWare(k, True);
          if not Assigned(Ware) or (Ware=NoWare) or Ware.IsArchive then
            raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(k)));

          Stream.WriteInt(GBIBS.FieldByName('PInvLnCode').AsInteger); // ��� ������
          Stream.WriteInt(k);                                         // ��� ������
          Stream.WriteStr(Ware.Name);                                 // ������������ ������
          Stream.WriteStr(GBIBS.FieldByName('PInvLnOrder').AsString); // �����
          Stream.WriteStr(GBIBS.FieldByName('PInvLnCount').AsString); // ����
          Stream.WriteStr(Ware.MeasName);                             // ������������ ��.���.
          sum:= GBIBS.FieldByName('PInvLnPrice').AsFloat;
          s:= fnGetStrSummByDoubleCurr(sum, curr);                    // ���� � 2-� �������
          Stream.WriteStr(s);
          if GBIBS.FieldByName('PInvLnCount').AsFloat=1 then
            Stream.WriteStr(s)
          else begin
            sum:= RoundToHalfDown(sum*GBIBS.FieldByName('PInvLnCount').AsFloat);
            s:= fnGetStrSummByDoubleCurr(sum, curr);
            Stream.WriteStr(s);                                       // ����� �� ������ � 2-� �������
          end;
          Stream.WriteStr(Ware.Comment);                              // �����������

          inc(LineCount);
          TestCssStopException;
          GBIBS.Next;
        end;
        if LineCount>0 then begin
          Stream.Position:= sPos;
          Stream.WriteInt(LineCount);
        end;
//-------------------- �������� ������ ����� -----------------------------------
      end;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=============================================== �������������� ��������� �����
procedure prWebArmEditAccountHeader(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmEditAccountHeader'; // ��� ���������/�������
      sNot = '��� ���������';
type RLineWareAndQties = record
    Ware: TWareInfo;
    OldQty, NewQty,
    DeltaQty: Double;
  end;
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    EmplID, ForFirmID, AccountID, ParamID, k, kk, i, LineCount, ContID{, SysID}: integer;
    AccountCode, FirmCode, s1, sWhere, ParamStr, ParamStr2, sf, CrncCode: string;
    empl: TEmplInfoItem;
    firm: TFirmInfo;
    dd: TDate;
    fl: Boolean;
    arLineWareAndQties: array of RLineWareAndQties;
    Contract: TContract;
  //----------------------------------------- �������� �����
  procedure CheckFirm(firmID: Integer);
  begin
    if not Cache.FirmExist(firmID)
      {or not Cache.CheckEmplVisFirm(EmplID, firmID)} then
      raise EBOBError.Create(MessText(mtkNotFirmExists));
    if ForFirmID<>firmID then ForFirmID:= firmID;
    FirmCode:= IntToStr(ForFirmID);
    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);
  end;
  //----------------------------------------- �������� ������ �����
  procedure CheckForFirmStore(StoreID: Integer);
//  var i: Integer;
  begin
//    i:= Contract.Get�ontStoreIndex(StoreID);
//    if (i<0) then raise EBOBError.Create('�� ������ ����� ��������������');
//    if not Contract.ContStorages[i].IsReserve then
//    if not Contract.ContStorages[i].IsDefault then
    if (Contract.MainStorage<>StoreID) then
      raise EBOBError.Create('����� ���������� ��� ��������������');
  end;
  //-----------------------------------------
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  firm:= nil;
  dd:= 0;
  k:= 0;
  ForFirmID:= 0;
  contID:= 0;
  SetLength(arLineWareAndQties, 0);
  CrncCode:= '';
  fl:= False;
  try
    EmplID:= Stream.ReadInt;
    AccountID:= Stream.ReadInt;
    ParamID:= Stream.ReadInt;    // ��� ���������
    ParamStr:= Stream.ReadStr;   // �������� ���������
    if (ParamID=ceahAnnulateInvoice) then
      ParamStr2:= Stream.ReadStr;   // �������� ���������2

    AccountCode:= IntToStr(AccountID);

    prSetThLogParams(ThreadData, csWebArmEditAccountHeader, EmplID, 0, ' AccountID='+AccountCode+
      ' ParamID='+IntToStr(ParamID)+' ParamStr='+ParamStr); // �����������

    if CheckNotValidUser(EmplID, isWe, s1) then raise EBOBError.Create(s1); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      sWhere:= ' where PInvCode='+AccountCode;

//------------------------------ ��� ������������ ���� -------------------------
      case ParamID of
        ceahChangeCurrency, ceahRecalcPrices : sf:= 'PInvCrncCode';
        ceahChangeRecipient, ceahRecalcCounts: sf:= 'PInvSupplyDprtCode';
        ceahChangeStorage   : sf:= 'PInvSupplyDprtCode, PINVSHIPMENTMETHODCODE';
        ceahChangeProcessed : sf:= 'PInvProcessed';
        ceahChangeEmplComm  : sf:= 'PINVCOMMENT';
        ceahChangeClientComm: sf:= 'PINVCLIENTCOMMENT';
        ceahChangeShipMethod: sf:= 'PINVSHIPMENTMETHODCODE, PINVSHIPMENTTIMECODE, PINVLABELCODE';
        ceahChangeShipTime  : sf:= 'PINVSHIPMENTMETHODCODE, PINVSHIPMENTTIMECODE';
        ceahChangeShipDate  : sf:= 'PINVSHIPMENTDATE';
        ceahChangeDocmDate  : sf:= 'PInvDate';
        ceahChangeLabel     : sf:= 'PINVLABELCODE, PINVSHIPMENTMETHODCODE';
        ceahAnnulateInvoice : sf:= 'PINVANNULKEY'; // , PINVUSEINREPORT
        ceahChangeContract  : sf:= 'PInvSupplyDprtCode, PInvCrncCode';
      end;

      GBIBS.SQL.Text:= 'select PInvNumber, PINVANNULKEY, PInvLocked, INVCCODE, PINVWARELINECOUNT,'+
        ' PInvRecipientCode, PINVCONTRACTCODE'+fnIfStr(sf='', '', ', ')+sf+' from PayInvoiceReestr'+
        ' left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+sWhere;
      GBIBS.ExecQuery;
      if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('�� ������ ���� � id='+AccountCode);
      s1:= '���� '+GBIBS.FieldByName('PInvNumber').AsString;
//-------------------- ������� �� ��������� ����� ------------------------------ ???
      if GetBoolGB(GBibs, 'PInvLocked') then raise EBOBError.Create(s1+' ����������');
      if ((ParamID<>ceahAnnulateInvoice) or (ParamStr<>'F'))
        and GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s1+' �����������');
//      if GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s1+' �����������');
      if GBIBS.FieldByName('INVCCODE').AsInteger>0 then raise EBOBError.Create(s1+' ����������');
//-------------------- ������� �� ��������� ����� ------------------------------

      LineCount:= GBIBS.FieldByName('PINVWARELINECOUNT').AsInteger; // ��������, ���� �� ������ � �����    ???
      ForFirmID:= GBIBS.FieldByName('PInvRecipientCode').AsInteger;
      contID:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      kk:= contID;
      CheckFirm(ForFirmID); // �������� �����

//------------------- ����������, �������� ������������ �������� ---------------
      case ParamID of
      ceahChangeContract: begin //------------------------------------- ��������
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVCONTRACTCODE';
          if kk=k then raise EBOBError.Create(sNot);
          if not Cache.Contracts.ItemExists(k) then
            raise EBOBError.Create(MessText(mtkNotFoundCont));
          contID:= k;
          Contract:= firm.GetContract(contID);
          if (contID<>k) then raise EBOBError.Create(MessText(mtkNotFoundCont));
          kk:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
          CheckForFirmStore(kk); // �������� ������������ ������ ������ ��������� �����
//          fl:= False;
          k:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
          fl:= (k<>Cache.BonusCrncCode) and (k<>Contract.DutyCurrency); // ������� ����� ������
          if fl then begin
            CrncCode:= IntToStr(Contract.DutyCurrency);
            ParamStr:= ParamStr+', PInvCrncCode='+CrncCode;
          end;
          fl:= fl and (LineCount>0);       // ������� ������������� ��������� ���
        end;

      ceahChangeStorage: begin //----------------------------------------- �����
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PInvSupplyDprtCode';
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if not Cache.DprtExist(k) then raise EBOBError.Create('�� ������ �����');
          CheckForFirmStore(k); // �������� ������ ��������� �����
          kk:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
                          // ��������� ����������� ������ �������� ������ ������
          if (kk>0) and Cache.ShipMethods.ItemExists(kk) then begin
            with Cache.GetShipMethodsList(k) do try // ������ ������� �������� �� ������ ������
              fl:= False;
              for i:= 0 to Count-1 do begin
                fl:= (Integer(Objects[i])=kk);
                if fl then break;
              end;
            finally Free; end;
            if not fl then raise EBOBError.Create('����� �������� ���������� ��� ������');
          end;
        end;

      ceahChangeCurrency: begin //--------------------------------------- ������
          k:= StrToIntDef(ParamStr, 0);
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if not Cache.CurrExists(k) or Cache.Currencies[k].Arhived then
            raise EBOBError.Create('�� ������� ������');
          if (contID>0) then begin
            if (k<>Cache.BonusCrncCode) and (k<>Contract.DutyCurrency) then // ��������� ������� �������� ������� ???
              raise EBOBError.Create('������ ���������� �� ������ ���������');
          end;
        end;

      ceahChangeProcessed: begin //--------------------------- ������� ���������
          k:= StrToIntDef(ParamStr, 0);
          if (fnIfInt(GBIBS.FieldByName(sf).AsString='T', 1, 0)=k) then raise EBOBError.Create(sNot);
          ParamStr:= fnIfStr(k=1, '"T"', '"F"');
        end;

      ceahChangeEmplComm: begin //---------- ����������� ����������� (�.�.�����)
          if (GBIBS.FieldByName(sf).AsString=ParamStr) then raise EBOBError.Create(sNot);
          k:= Length(ParamStr);
          if (k>Cache.AccEmpCommLength) then raise EBOBError.Create('������� ������� �����������');
        end;

      ceahChangeClientComm: begin //------------ ����������� ������� (�.�.�����)
          if (GBIBS.FieldByName(sf).AsString=ParamStr) then raise EBOBError.Create(sNot);
          k:= Length(ParamStr);
          if (k>Cache.AccCliCommLength) then raise EBOBError.Create('������� ������� �����������');
        end;

      ceahChangeShipMethod: begin //------------ ��� ������ �������� (�.�.�����)
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVSHIPMENTMETHODCODE';
          if (k>0) then begin
            if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
            if not Cache.ShipMethods.ItemExists(k) then
              raise EBOBError.Create('�� ������ ����� ��������');
            if (GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger>0) // ����� ������� ��������
              and Cache.GetShipMethodNotTime(k) then
              ParamStr:= ParamStr+', PINVSHIPMENTTIMECODE=null';
            if (GBIBS.FieldByName('PINVLABELCODE').AsInteger>0)        // ����� ��������
              and Cache.GetShipMethodNotLabel(k) then
              ParamStr:= ParamStr+', PINVLABELCODE=null';
          end else ParamStr:= 'null';
        end;

      ceahChangeShipTime: begin //------------- ��� ������� �������� (�.�.�����)
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVSHIPMENTTIMECODE';
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if (k>0) then begin
            if not Cache.ShipTimes.ItemExists(k) then
              raise EBOBError.Create('�� ������� ����� ��������');
            kk:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
            if (kk>0) and Cache.GetShipMethodNotTime(kk) then
              raise EBOBError.Create('���� ����� �������� - ��� �������� �������');
          end else ParamStr:= 'null';
        end;

      ceahChangeLabel: begin   //---------------------- ��� �������� (�.�.�����)
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVLABELCODE';
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if (k>0) then begin
            kk:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
            if (kk>0) and Cache.GetShipMethodNotLabel(kk) then
              raise EBOBError.Create('���� ����� �������� - ��� �������� ��������');
          end else ParamStr:= 'null';
        end;

      ceahChangeShipDate: begin //-------------------- ���� �������� (�.�.�����)
          if (ParamStr='') then begin
            if GBIBS.FieldByName(sf).IsNull then raise EBOBError.Create(sNot);
            dd:= 0;
          end else try
            dd:= StrToDate(ParamStr);
            if GBIBS.FieldByName(sf).AsDate=dd then raise EBOBError.Create(sNot);
            if dd<Date then raise EBOBError.Create('������ ����');  // ???
          except
            on E: EBOBError do raise EBOBError.Create(E.Message);
            on E: Exception do raise EBOBError.Create('������������ �������� ����');
          end;
        end;

      ceahChangeDocmDate: begin //---------------------------------- ���� ���-��
          try
            dd:= StrToDate(ParamStr);
            if GBIBS.FieldByName(sf).AsDate=dd then raise EBOBError.Create(sNot);
            if dd<Date then raise EBOBError.Create('������ ����');  // ???
          except
            on E: EBOBError do raise EBOBError.Create(E.Message);
            on E: Exception do raise EBOBError.Create('������������ �������� ����');
          end;
        end;

      ceahChangeRecipient: begin //---------------------------------- ����������
          ForFirmID:= StrToIntDef(ParamStr, 0);
          // ���� ���� ������ - ���������� ������-����������� �������� ���������
          CheckFirm(ForFirmID);                // �������� �����
          k:= GBIBS.FieldByName(sf).AsInteger; // ��� ������
          sf:= 'PInvRecipientCode';
          if GBIBS.FieldByName(sf).AsInteger=ForFirmID then raise EBOBError.Create(sNot);
          CheckForFirmStore(k); // �������� ������ �����
        end;

      ceahRecalcPrices: begin   //--------------------------------- �������� ���
          if (LineCount<1) then raise EBOBError.Create('��� �������');
          ParamStr:= GBIBS.FieldByName(sf).AsString;
        end;

      ceahRecalcCounts: begin   //------------------------------- �������� �����
          if (LineCount<1) then raise EBOBError.Create('��� �������');
          k:= GBIBS.FieldByName(sf).AsInteger; // ��� ������
          if not Cache.DprtExist(k) then raise EBOBError.Create('�� ������ �����');
          CheckForFirmStore(k); // �������� ������ �����
//          ParamStr:= '';
        end;

      ceahAnnulateInvoice: begin
          if (ParamStr<>'T') and (ParamStr<>'F') then
            raise EBOBError.Create('�������� �������� ��������� - "'+ParamStr+'"');
          if (ParamStr2<>'T') and (ParamStr2<>'F') then
            raise EBOBError.Create('�������� �������� ��������� - "'+ParamStr2+'"');
          ParamStr:= '"'+ParamStr+'", PINVUSEINREPORT="'+ParamStr2+'"';
        end;

      end;
      GBIBS.Close;

//------------------------- ������ ��������� -----------------------------------
      fnSetTransParams(GBIBS.Transaction, tpWrite, True);  // ��������� � ������
      s1:= 'update PayInvoiceReestr set '+sf+'=';

      case ParamID of // ��������� ������ SQL
        ceahChangeProcessed,           //--------------------- ������� ���������
        ceahChangeShipMethod,          //------------------------ ����� ��������
        ceahChangeShipTime,            //------------------------ ����� ��������
        ceahAnnulateInvoice,           //--- �������������/��������������� �����
        ceahChangeLabel,               //-------------------------- ��� ��������
        ceahChangeContract:            //------------------------------ ��������
          GBIBS.SQL.Text:= s1+ParamStr+sWhere;

        ceahChangeEmplComm,            //--------------- ����������� �����������
        ceahChangeClientComm:          //------------------- ����������� �������
          if (ParamStr<>'') then begin
            GBIBS.SQL.Text:= s1+':comm'+sWhere;
            GBIBS.ParamByName('comm').AsString:= ParamStr;
          end else GBIBS.SQL.Text:= s1+'null'+sWhere;

        ceahChangeShipDate:            //------------------------- ���� ��������
          if (dd>0) then begin
            GBIBS.SQL.Text:= s1+':dd'+sWhere;
            GBIBS.ParamByName('dd').AsDate:= dd;
          end else GBIBS.SQL.Text:= s1+'null'+sWhere;

        ceahChangeDocmDate: begin      //--------------------------- ���� ���-��
          GBIBS.SQL.Text:= s1+':dd'+sWhere;
          GBIBS.ParamByName('dd').AsDate:= dd;
        end;

        ceahChangeRecipient:           //---------------------------- ����������
          GBIBS.SQL.Text:= s1+FirmCode+', pinvcontractcode='+IntToStr(ContID)+sWhere;

        ceahChangeStorage:             //--------------------------------- �����
          GBIBS.SQL.Text:= 'execute procedure Vlad_CSS_ChangeAccDprtC('+AccountCode+', '+ParamStr+')';

        ceahChangeCurrency,            //-------------------------------- ������
        ceahRecalcPrices:       //--------------------------------- �������� ���
          GBIBS.SQL.Text:= 'execute procedure Vlad_CSS_RecalcAccSummC('+AccountCode+', '+ParamStr+')';

        ceahRecalcCounts: //-- �������� ����� (�����. ����. � ���.���� ��� ����)
          GBIBS.SQL.Text:= 'select rWareCode, rOldCount, rNewCount'+
                           ' from Vlad_CSS_RecalcAccFactC('+AccountCode+')';

        else raise EBOBError.Create(MessText(mtkNotValidParam));
      end; // case

      for i:= 0 to RepeatCount do with GBIBS.Transaction do try
        Application.ProcessMessages;
        GBIBS.Close;
        if not InTransaction then StartTransaction;
        GBIBS.ExecQuery;

        if ParamID=ceahRecalcCounts then begin // ���������� ������� �����
          SetLength(arLineWareAndQties, LineCount);
          LineCount:= 0;
          while not GBIBS.Eof do begin
            kk:= GBIBS.FieldByName('rWareCode').AsInteger;
            if Cache.WareExist(kk) then begin
              arLineWareAndQties[LineCount].Ware:= Cache.GetWare(kk);
              arLineWareAndQties[LineCount].DeltaQty:=
                GBIBS.FieldByName('rNewCount').AsFloat-GBIBS.FieldByName('rOldCount').AsFloat;
              inc(LineCount);
            end;
            TestCssStopException;
            GBIBS.Next;
          end;
          if LineCount<>Length(arLineWareAndQties) then SetLength(arLineWareAndQties, LineCount);
        end;  // if ParamID=ceahRecalcCounts

        if (ParamID=ceahChangeContract) and fl then begin // �������� ��� ��� ����� ������
          GBIBS.SQL.Text:= 'execute procedure Vlad_CSS_RecalcAccSummC('+AccountCode+', '+CrncCode+')';
          GBIBS.ExecQuery;
        end;

        Commit;
        break;
      except
        on E: Exception do begin
          RollbackRetaining;
          if (i<RepeatCount) then sleep(RepeatSaveInterval)
          else raise Exception.Create(E.Message);
        end;
      end;

      if ParamID=ceahRecalcCounts then  // ������� ������� ����� � �������� � ����
        for kk:= 0 to High(arLineWareAndQties) do with arLineWareAndQties[kk] do
          Cache.CheckWareRest(Ware.RestLinks, k, DeltaQty, True);

    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;

//--------------------------- �������� ����� -----------------------------------
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  SetLength(arLineWareAndQties, 0);
  Stream.Position:= 0;
end;
//============================== ����������/��������������/�������� ������ �����
procedure prWebArmEditAccountLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmEditAccountLine'; // ��� ���������/�������
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    EmplID, ForFirmID, AccountID, Option, LineID, dprt, WareID, curr, iLine, i: integer;
    AccountCode, FirmCode, s, meas, WarnMess: string;
    empl: TEmplInfoItem;
    Ware: TWareInfo;
    cliQty, oldQty, sum: Double;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  meas:= '';
  WarnMess:= '';
  try
    EmplID:= Stream.ReadInt;
    AccountID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    Option:= Stream.ReadInt; // �������� - constOpAdd, constOpEdit, constOpDel, constOpEditFact
    LineID:= Stream.ReadInt; // ��� ������
    WareID:= Stream.ReadInt; // ��� ������
    cliQty:= Stream.ReadDouble; // ����� ����� / ����
//    oldQty:= Stream.ReadDouble; // ������ ����

    cliQty:= abs(cliQty);
    AccountCode:= IntToStr(AccountID);
    FirmCode:= IntToStr(ForFirmID);

    prSetThLogParams(ThreadData, csWebArmEditAccountLine, EmplID, 0, 'ForFirmID='+FirmCode+' AccountID='+AccountCode+
      ' Option='+IntToStr(Option)+' LineID='+IntToStr(LineID)+' cliQty='+FloatToStr(cliQty)); // �����������

    if not (Option in [constOpAdd, constOpEdit, constOpDel, constOpEditFact]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ��������');
    if (Option<>constOpAdd) and (LineID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' ������ ������');

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����

    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FirmExist(ForFirmID) // �������� �����
      {or not Cache.CheckEmplVisFirm(EmplID, ForFirmID)} then
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
    Ware:= Cache.GetWare(WareID);

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);

      GBIBS.SQL.Text:= 'select PInvNumber, PINVANNULKEY, PInvSupplyDprtCode,'+ // , PINVWARELINECOUNT   ???
        ' PInvLocked, INVCCODE, PInvLnCount, PInvLnCode from PayInvoiceReestr'+  //
        ' left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' left join PayInvoiceLines on PInvLnDocmCode=PInvCode and PInvLnCode='+IntToStr(LineID)+
        ' where PInvCode='+AccountCode+' and PInvRecipientCode='+FirmCode;
      GBIBS.ExecQuery;
      if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('�� ������ ���� � id='+AccountCode);
      s:= '���� '+GBIBS.FieldByName('PInvNumber').AsString;
//-------------------- ������� �� ��������� ����� ------------------------------ ???
      if GetBoolGB(GBibs, 'PInvLocked') then raise EBOBError.Create(s+' ����������');
      if GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s+' �����������');
      if GBIBS.FieldByName('INVCCODE').AsInteger>0 then raise EBOBError.Create(s+' ����������');
//-------------------- ������� �� ��������� ����� ------------------------------
      if (Option=constOpAdd) then begin
        oldQty:= 0;
        LineID:= 0;
      end else begin
        oldQty:= GBIBS.FieldByName('PInvLnCount').AsFloat; // ������ ����
        LineID:= GBIBS.FieldByName('PInvLnCode').AsInteger;
        if LineID<1 then raise EBOBError.Create(MessText(mtkNotValidParam)+' - ��� ������');
      end;
      dprt:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;   // �����
      GBIBS.Close;

      fnSetTransParams(GBIBS.Transaction, tpWrite, True);

      case Option of // ��������� ������ SQL
      constOpAdd: begin //----------------------------------------- ��������
          if cliQty<1 then raise EBOBError.Create(MessText(mtkNotValidParam)+' ����������');

          GBIBS.SQL.Text:= 'select NewLineCode, WarnMess from Vlad_CSS_AddAccLineWC('+
            AccountCode+', '+IntToStr(dprt)+', '+IntToStr(WareID)+', :CLIENTQTY)';
          GBIBS.ParamByName('CLIENTQTY').AsFloat:= cliQty;
          for i:= 0 to RepeatCount do with GBIBS.Transaction do try
            Application.ProcessMessages;
            GBIBS.Close;
            if not InTransaction then StartTransaction;
            GBIBS.ExecQuery;
            if GBIBS.Bof and GBIBS.Eof then raise Exception.Create(MessText(mtkErrAddRecord));
            LineID:= GBIBS.FieldByName('NewLineCode').AsInteger; // ��� ����� ������
            WarnMess:= GBIBS.FieldByName('WarnMess').AsString;
            oldQty:= 0; // �������� ������ ����
            Commit;
            break;
          except
            on E: Exception do begin
              if (pos('PRS. LockCompletionCountKey~', E.Message)>0) then
                raise EBOBError.Create('���������� ���������� ������ � ���������� ������ ����������, '+
                  '� �������������� ��� ������ � ���������� '+FloatToStr(RoundTo(cliQty, -3)));
              if (i>=RepeatCount) then raise Exception.Create(E.Message);
              RollbackRetaining;
              sleep(RepeatSaveInterval);
            end;
          end;
        end; // constOpAdd

      constOpEdit, constOpEditFact: begin //-------------- �������� ����� / ����
          if (Option=constOpEditFact) then iLine:= -LineID else iLine:= LineID;  // iLine<0 - ������������� �����

          GBIBS.SQL.Text:= 'select WarnMess from Vlad_CSS_EditAccLineC('+IntToStr(iLine)+', :CLIENTQTY)';
          GBIBS.ParamByName('CLIENTQTY').AsFloat:= cliQty;
          for i:= 0 to RepeatCount do with GBIBS.Transaction do try
            Application.ProcessMessages;
            GBIBS.Close;
            if not InTransaction then StartTransaction;
            GBIBS.ExecQuery;
            if GBIBS.Bof and GBIBS.Eof then raise Exception.Create(MessText(mtkErrEditRecord));
            WarnMess:= GBIBS.FieldByName('WarnMess').AsString;
            Commit;
            break;
          except
            on E: Exception do begin
              RollbackRetaining;
              if (i<RepeatCount) then sleep(RepeatSaveInterval)
              else raise Exception.Create(E.Message);
            end;
          end;
        end; // constOpEdit, constOpEditFact

      constOpDel: begin //----------------------------------------- �������
          GBIBS.SQL.Text:= 'delete from PayInvoiceLines where PInvLnCode='+IntToStr(LineID);
          for i:= 0 to RepeatCount do with GBIBS.Transaction do try
            Application.ProcessMessages;
            GBIBS.Close;
            if not InTransaction then StartTransaction;
            GBIBS.ExecQuery;
            if (GBIBS.RowsAffected<1) then raise Exception.Create(MessText(mtkErrDelRecord));
            LineID:= 0; // �������� ��� ������
            Commit;
            break;
          except
            on E: Exception do begin
              RollbackRetaining;
              if (i<RepeatCount) then sleep(RepeatSaveInterval)
              else raise Exception.Create(E.Message);
            end;
          end;
        end; // constOpDel
      else raise EBOBError.Create(MessText(mtkNotValidParam));
      end; // case

//      GBIBS.Transaction.Commit;
      GBIBS.Close;
      fnSetTransParams(GBIBS.Transaction, tpRead, True);

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
                                  //-------------------------- ����� ����� �����
      GBIBS.SQL.Text:= 'SELECT PInvProcessed, PInvCrncCode, PInvSupplyDprtCode, PInvSumm'+
        ' from PayInvoiceReestr where PInvCode='+AccountCode+' and PInvRecipientCode='+FirmCode;
      GBIBS.ExecQuery;
      Stream.WriteBool(GetBoolGB(GBIBS, 'PInvProcessed'));        // ������� ���������
      s:= FormatFloat(cFloatFormatSumm, GBIBS.FieldByName('PInvSumm').AsFloat);
      curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;         // ������ �����
      dprt:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;   // �����
      sum:= GBIBS.FieldByName('PInvSumm').AsFloat;                // ����� �����
      GBIBS.Close;

      s:= fnGetStrSummByDoubleCurr(sum, curr); // ������ � ������ � 2-� �������
      Stream.WriteStr(s);

      Stream.WriteInt(LineID);    // ��� ������ (constOpDel - 0)

      if LineID>0 then begin      //-------------------- ����� ���������� ������
        GBIBS.SQL.Text:= 'select PInvLnOrder, PInvLnCount, PInvLnPrice'+
          ' from PayInvoiceLines where PInvLnCode='+IntToStr(LineID);
        GBIBS.ExecQuery;

        Stream.WriteInt(WareID);                                    // ��� ������
        Stream.WriteStr(Ware.Name);                                 // ������������ ������
        Stream.WriteStr(GBIBS.FieldByName('PInvLnOrder').AsString); // �����
        Stream.WriteStr(GBIBS.FieldByName('PInvLnCount').AsString); // ����
        Stream.WriteStr(Ware.MeasName);                             // ������������ ��.���.

        cliQty:= GBIBS.FieldByName('PInvLnCount').AsFloat;          // ����� ����
        sum:= GBIBS.FieldByName('PInvLnPrice').AsFloat;             // ����
        GBIBS.Close;

        s:= fnGetStrSummByDoubleCurr(sum, curr); // ������ � ����� � 2-� �������
        Stream.WriteStr(s);

        if cliQty=1 then Stream.WriteStr(s)                         // ����� �� ������
        else begin
          sum:= RoundToHalfDown(sum*cliQty);
          s:= fnGetStrSummByDoubleCurr(sum, curr); // ������ � ������ � 2-� �������
          Stream.WriteStr(s);
        end;
        Stream.WriteStr(Ware.Comment);                             // �����������
      end else cliQty:= 0; // �������� ����� ���� ��� ��������� ������

      Stream.WriteStr(WarnMess); // �������������� � ��������� �� ��������� � �.�.

      Cache.CheckWareRest(Ware.RestLinks, dprt, cliQty-oldQty, True); // ������� ������� ����� � ������� � ����
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;
//================================================ ������ � ������ � 2-� �������
function fnGetStrSummByDoubleCurr(sum: Double; MainCurr: Integer; AddCurr: Integer=cDefCurrency): String;
// ���� MainCurr <> ���, AddCurr ������������ � 2-� ������ - ���
var k: Integer;
    curr: Single;
begin
  Result:= '';
  if not Cache.CurrExists(MainCurr) then Exit;

  Result:= FormatFloat(cFloatFormatSumm, sum)+' '+Cache.GetCurrName(MainCurr, False); // ����� � 1-� ������

  k:= 0;
  if (MainCurr<>cUAHCurrency) then begin //----------------------- ������ -> ���
    curr:= Cache.Currencies.GetCurrRate(MainCurr);
    if fnNotZero(curr) then k:= cUAHCurrency;

  end else begin                         //----------------------- ��� -> ������
    curr:= Cache.Currencies.GetCurrRate(AddCurr); // ���� ������ � ���
    if fnNotZero(curr) then begin
      curr:= 1/curr;
      k:= AddCurr;
    end;
  end;
  if (k<1) then Exit;

  sum:= sum*curr;        // + ����� � 2-� ������
  Result:= Result+' ('+FormatFloat(cFloatFormatSumm, sum)+' '+Cache.GetCurrName(k, False)+')';
end;
//================================ �������� ������� ��� ��������� (����� WebArm)
procedure prWebArmGetWaresDescrView(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetWaresDescrView'; // ��� ���������/�������
var EmplID, ForFirmID, WareID, i, ii, sPos, j, {SysID, contID,} iCri, iNode: Integer;
    s, sView, sWareCodes, ss, CriName: string;
    Codes: Tas;
    empl: TEmplInfoItem;
    ware: TWareInfo;
    ORD_IBS, ORD_IBS1: TIBSQL;
    ORD_IBD: TIBDatabase;
begin
  ORD_IBS:= nil;
  ORD_IBS1:= nil;
  Stream.Position:= 0;
  SetLength(Codes, 0);
  try
    EmplID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
//    ContID:=
    Stream.ReadInt; // ��� ����������
    sWareCodes:= Stream.ReadStr; // ���� �������

    prSetThLogParams(ThreadData, csWebArmGetWaresDescrView, EmplID, 0,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'sWareCodes='+sWareCodes);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0);  // ����� ��� ���-�� �������

    Codes:= fnSplitString(sWareCodes, ',');
    if (Length(Codes)<1) then Exit; // ������� ��� - �������

    if CheckNotValidUser(EmplID, isWe, s) then Exit; // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then Exit; // ��������� ����� ������������

    if not Cache.FirmExist(ForFirmID) // �������� �����
      {or not Cache.CheckEmplVisFirm(EmplID, ForFirmID)} then Exit;

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc);
      ORD_IBS1:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS1_'+nmProc, -1, tpRead, true);
      //----------------------------------------------------- �������� ���������
      ORD_IBS.SQL.Text:= 'select WCRICODE, WCRIDESCR, WCVSVALUE'+
        ' from (select LWCVWCVSCODE from LINKWARECRIVALUES'+
        ' where LWCVWARECODE=:WareID and LWCVWRONG="F")'+
        ' left join WARECRIVALUES on WCVSCODE=LWCVWCVSCODE'+
        ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE'+
        ' order by WCRIORDNUM nulls last, WCRICODE, WCVSVALUE';
      ORD_IBS.Prepare;
        //------------------------------------------- ������ � ������ ����� - ����
      ORD_IBS1.SQL.Text:= 'select LWNTnodeID, LWNTinfotype, DITMNAME, TRNANAME,'+
        ' iif(ITATEXT is null, ITTEXT, ITATEXT) text'+
        ' from (select LWNTnodeID, LWNTinfotype, LWNTWIT'+
        '  from LinkWareNodeText where LWNTwareID=:WareID and LWNTWRONG="F")'+
        ' left join DIRINFOTYPEMODEL on DITMCODE = LWNTinfotype'+
        ' left join TREENODESAUTO on TRNACODE=LWNTnodeID'+
        ' left join WareInfoTexts on WITCODE=LWNTWIT'+
        ' left join INFOTEXTS on ITCODE=WITTEXTCODE'+
        ' left join INFOTEXTSaltern on ITACODE=ITALTERN'+
        ' order by LWNTnodeID, LWNTinfotype, text';
      ORD_IBS1.Prepare;

      j:= 0; // ������� �������
      for i:= 0 to High(Codes) do begin
        WareID:= StrToIntDef(Codes[i], 0);
        if not Cache.WareExist(WareID) then Continue;

        ware:= Cache.GetWare(WareID);
        if ware.IsArchive or not ware.IsWare then Continue;

        Stream.WriteInt(WareID); // �������� ��� ������
        inc(j);

        sView:= '';
        with ware.GetWareAttrValuesView do try // ������ �������� � �������� ��������� ������ (TStringList)
          for ii:= 0 to Count-1 do
            sView:= sView+fnIfStr(sView='', '', '; ')+Names[ii]+': '+ // �������� ��������
                    ExtractParametr(Strings[ii]);                     // �������� ��������
        finally Free; end;

        Stream.WriteStr(sView); // �������� ������ ���������

        sView:= ''; //--------------------------------------- �������� ���������
        ORD_IBS.ParamByName('WareID').AsInteger:= WareID;
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
          sView:= sView+fnIfStr(sView='', '', '; ')+CriName+fnIfStr(s='', '', ': '+s); // ������ �� 1-�� ��������
        end;
        ORD_IBS.Close;

        Stream.WriteStr(sView); // �������� ������ ���������

        sView:= ''; //----------------------------- ������ � ������ ����� - ����
        ORD_IBS1.ParamByName('WareID').AsInteger:= WareID;
        ORD_IBS1.ExecQuery;
        while not ORD_IBS1.Eof do begin
          iNode:= ORD_IBS1.FieldByName('LWNTnodeID').AsInteger;
          sView:= sView+fnIfStr(sView='', '', #13#10)+'���� '+ORD_IBS1.FieldByName('TRNANAME').AsString+': ';
          while not ORD_IBS1.Eof and (iNode=ORD_IBS1.FieldByName('LWNTnodeID').AsInteger) do begin
            iCri:= ORD_IBS1.FieldByName('LWNTinfotype').AsInteger;
            CriName:= ORD_IBS1.FieldByName('DITMNAME').AsString;
            s:= '';
            while not ORD_IBS1.Eof and (iNode=ORD_IBS1.FieldByName('LWNTnodeID').AsInteger)
              and (iCri=ORD_IBS1.FieldByName('LWNTinfotype').AsInteger) do begin
              ss:= ORD_IBS1.FieldByName('text').AsString;
              if ss<>'' then s:= s+fnIfStr(s='', '', ', ')+ss;
              cntsORD.TestSuspendException;
              ORD_IBS1.Next;
            end; // while ... and (iNode= ... and (iCri=
          end; // while ... and (iNode=
          sView:= sView+fnIfStr(sView='', '', '; ')+CriName+fnIfStr(s='', '', ': '+s); // ������ �� 1-�� ���� ������
        end;
        ORD_IBS1.Close;

        Stream.WriteStr(sView); // �������� ������ �������
      end; // for
    finally
      prFreeIBSQL(ORD_IBS);
      prFreeIBSQL(ORD_IBS1);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if j>0 then begin
      Stream.Position:= sPos;
      Stream.WriteInt(j);
//      Stream.Position:= Stream.Size; // ���� ����� ��� ��������� ���� �� ������
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Codes, 0);
end;
//================================ ������ �������� ��� ��������� ������ (WebArm)
procedure prWebarmGetDeliveries(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebarmGetDeliveries'; // ��� ���������/�������
var InnerErrorPos: string;
    UserId, FirmID, currID, ForFirmID, i, CountDeliv, wareID, contID: integer;
    PriceInUah: boolean;
    ffp: TForFirmParams;
begin
  Stream.Position:= 0;
  ForFirmID:= 0;
  contID:= 0;
  FirmId:= isWe;
  ffp:= nil;
  CountDeliv:= 0;
  try
InnerErrorPos:='0';
    UserId:= Stream.ReadInt;
    PriceInUah:= Stream.ReadBool;
    try
InnerErrorPos:='1';
                 // ��������� UserID, FirmID, ForFirmID � �������� �������, ������
      prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
InnerErrorPos:='2';
      CountDeliv:= Cache.DeliveriesList.Count;
    finally
      prSetThLogParams(ThreadData, csWebArmGetDeliviriesList, UserID, FirmID, 'DelivQty='+IntToStr(CountDeliv)); // �����������
    end;
    if (CountDeliv<1) then raise EBOBError.Create('�� ������� ��������');
InnerErrorPos:='3';
    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(False); // ShowAnalogs

    Stream.WriteInt(CountDeliv);   // �������� ��������
    for i:= 0 to CountDeliv-1 do begin
InnerErrorPos:='7-'+IntToStr(i);
      wareID:= Integer(Cache.DeliveriesList.Objects[i]);
      prSaveShortWareInfoToStream(Stream, ffp, wareID, 0, 0, -1, '', False);
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do
      prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'InnerErrorPos='+InnerErrorPos, False);
  end;
  Stream.Position:= 0;
  prFree(ffp);
end;
//============================================ ������������ ����� �� �����������
procedure prWebArmMakeSecondAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmMakeSecondAccount'; // ��� ���������/�������
      errmess = '������ �������� �����';
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    EmplID, AccountID, i: integer;
    AccountCode, s: string;
    empl: TEmplInfoItem;
    Success: boolean;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  try
    EmplID:= Stream.ReadInt;     // ��� ����������
    AccountID:= Stream.ReadInt;  // ��� �����

    AccountCode:= IntToStr(AccountID);

    prSetThLogParams(ThreadData, csCreateSubAcc, EmplID, 0, 'AccountID='+AccountCode); // �����������

    if (AccountID<1) then raise EBOBError.Create('�������� ��� ��������� �����');
    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpWrite, True);
//------------------------- ��� � ����� ������ ����� ---------------------------
      GBIBS.SQL.Text:= 'select RAccCode, Rnumber from Vlad_CSS_MakeSecondAcc('+AccountCode+')';
      AccountCode:= '';
      Success:= false;
      for i:= 1 to RepeatCount do try
        GBIBS.Close;
        with GBIBS.Transaction do if not InTransaction then StartTransaction;
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create(errmess);

        AccountID:= GBIBS.FieldByName('RAccCode').AsInteger;
        if (AccountID<1) then raise EBOBError.Create(errmess);
        AccountCode:= GBIBS.FieldByName('Rnumber').AsString;
        if (AccountCode='') then raise EBOBError.Create(errmess);

        GBIBS.Transaction.Commit;
        GBIBS.Close;
        Success:= true;
        break;
      except
        on E: EBOBError do raise EBOBError.Create(E.Message);
        on E: Exception do
          if (Pos('lock', E.Message)>0) and (i<RepeatCount) then begin
            with GBIBS.Transaction do if InTransaction then RollbackRetaining;
            GBIBS.Close;
            sleep(RepeatSaveInterval);
          end else raise Exception.Create(E.Message);
      end;
      GBIBS.Close;
      if not Success then raise EBOBError.Create(errmess);
//------------------------------- ������� ����� ���� ---------------------------
      Stream.Clear;
      Stream.WriteInt(aeSuccess);   // ���� ����, ��� ������ ��������� ���������
      Stream.WriteInt(AccountID);   // ��� ������ �����
      Stream.WriteStr(AccountCode); // ����� ������ �����
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;
//============================================== ������������ ��������� �� �����
procedure prWebArmMakeInvoiceFromAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmMakeInvoiceFromAccount'; // ��� ���������/�������
      errmess = '������ ������������ ��������� �� �����';
var GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    EmplID, AccountID, i, ForFirmID, ContID: integer;
    AccountCode, s: string;
    empl: TEmplInfoItem;
    Success: boolean;
    Contract: TContract;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  ContID:= 0;
  try
    EmplID:= Stream.ReadInt;     // ��� ����������
    AccountID:= Stream.ReadInt;  // ��� �����
    ForFirmID:= Stream.ReadInt;  // ��� �/�

    AccountCode:= IntToStr(AccountID);

    prSetThLogParams(ThreadData, csWebArmMakeInvoiceFromAccount, EmplID, 0,
      'AccountID='+AccountCode+', ForFirmID='+IntToStr(ForFirmID)); // �����������

    if (AccountID<1) then raise EBOBError.Create('�������� ��� �����');
    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

//    if not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then                 // �������� �����
//      raise EBOBError.Create(MessText(mtkNotFirmExists));
    Cache.TestFirms(ForFirmID, True, True, False);
    if not Cache.FirmExist(ForFirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select PINVCONTRACTCODE from PayInvoiceReestr'+
                       ' where PInvCode='+AccountCode;
      GBIBS.ExecQuery;
      if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create('�� ������ ���� ���='+AccountCode);
      i:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      GBIBS.Close;

      contID:= i;
      Contract:= Cache.arFirmInfo[ForFirmID].GetContract(contID);
      if (contID<>i) then  raise EBOBError.Create(MessText(mtkNotFoundCont, IntToStr(i)));

      if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
        raise EBOBError.Create('�������� '+Contract.Name+' ����������');

      if Contract.SaleBlocked then // �������� ����������� ��������        ???
        raise EBOBError.Create('�������� ���������');

      s:= FormatDateTime(cDateFormatY4, Date);
      i:= HourOf(Now);
//------------------------- ��� � ����� ��������� ------------------------------
      fnSetTransParams(GBIBS.Transaction, tpWrite, True);
      GBIBS.SQL.Text:= 'select InvcCode, InvcNumber from DCMAKEINVOICEFROMACCOUNTFOR35('+
                       AccountCode+', "'+s+'", '+IntToStr(i)+', 0, "") m'+
                       ' left join INVOICEREESTR on InvcCode=m.RINVCCODE';
      AccountCode:= '';
      Success:= false;
      for i:= 1 to RepeatCount do try
        GBIBS.Close;
        with GBIBS.Transaction do if not InTransaction then StartTransaction;
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create(errmess);

        AccountID:= GBIBS.FieldByName('InvcCode').AsInteger;
        if (AccountID<1) then raise EBOBError.Create(errmess);
        AccountCode:= GBIBS.FieldByName('InvcNumber').AsString;
        if (AccountCode='') then raise EBOBError.Create(errmess);

        GBIBS.Transaction.Commit;
        GBIBS.Close;
        Success:= true;
        break;
      except
        on E: EBOBError do raise EBOBError.Create(E.Message);
        on E: Exception do
          if (Pos('lock', E.Message)>0) and (i<RepeatCount) then begin
            with GBIBS.Transaction do if InTransaction then RollbackRetaining;
            GBIBS.Close;
            sleep(RepeatSaveInterval);
          end else raise Exception.Create(E.Message);
      end;
      GBIBS.Close;
      if not Success then raise EBOBError.Create(errmess);
//------------------------------- ������� ��������� ---------------------------
      Stream.Clear;
      Stream.WriteInt(aeSuccess);   // ���� ����, ��� ������ ��������� ���������
      Stream.WriteInt(AccountID);   // ��� ���������
      Stream.WriteStr(AccountCode); // ����� ���������
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;
//===================================== ������ ��������� �������� (����� WebArm)
procedure prWebArmGetTransInvoicesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetTransInvoicesList'; // ��� ���������/�������
var EmplID, i, sPos, j, DprtFrom, DprtTo: Integer;
    s: string;
    empl: TEmplInfoItem;
    GBIBS: TIBSQL;
    GBIBD: TIBDatabase;
    dd, ddFrom: Double;
    flOpened: Boolean;
begin
  GBIBS:= nil;
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;    // ��� ����������
    ddFrom:= Stream.ReadDouble; // ������� � ���� ���-��
    DprtFrom:= Stream.ReadInt;    // ����.��������
    DprtTo:= Stream.ReadInt;    // ����.������
    flOpened:= Stream.ReadBool;   // ������ ��������

    prSetThLogParams(ThreadData, csShowTransferInvoices, EmplID, 0, 'ddFrom='+DateToStr(ddFrom)+' DprtFrom='+
      IntToStr(DprtFrom)+' DprtTo='+IntToStr(DprtTo)+' flOpened='+BoolToStr(flOpened)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    dd:= IncDay(Date, -7); // ������������ ��������� ���� - �� ����� 7 ����
    if (ddFrom<dd) then ddFrom:= dd;
                           // ��������� ������� �� ��������
    s:= ' and TRINPRINTLOCK="F" and TRINBYNORMKEY="F"'; // ��������������� �� �� ������

    if (DprtFrom>0) then s:= s+' and TRINSORCDPRTCODE='+IntToStr(DprtFrom);    // ����.��������
    if (DprtTo>0)   then s:= s+' and TRINDESTDPRTCODE='+IntToStr(DprtTo);      // ����.��������
    if flOpened     then s:= s+' and TRINEXECUTED="F"'+                        // ������������� ��������
                               ' and (otwhcode is null and inwhcode is null)'; //
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteDouble(ddFrom); // ��������� ���� (����� ����������)

    sPos:= Stream.Position;
    Stream.WriteInt(0);  // ����� ��� ���-��

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select TRINCODE, TRINNUMBER, TRINDATE, TRINSORCDPRTCODE,'+
        ' TRINDESTDPRTCODE, TRINSHIPMENTMETHODCODE, TRINSHIPMENTDATE, TRINBYNORMKEY,'+
        ' TRINSHIPMENTTIMECODE, TRINCOMMENTS, TRINPRINTLOCK, TRINEXECUTED,'+
        ' iif(otwhcode is null and inwhcode is null, 0, 1) hcode from TRANSFERINVOICEREESTR'+
        ' left join AdditionalCheckMainWMSDocm(97, TrInCode, "T") io on 1=1'+
        ' left join AdditionalCheckMainWMSDocm(97, TrInCode, "F") ii on 1=1'+
        ' left join OUTWAREHOUSEREESTR ow on OTWHCODE=TrInWMSDocmCode'+
        '   and io.RCorrect="T" and OtWhMainDocmType=97'+
        ' left join inwarehousereestr iw on inwhcode=TrInWMSDocmCode'+
        '   and ii.RCorrect="T" and inwhmaindocmtype=97'+
        ' where TRINSUBFIRMCODE=1 and TRINDATE>=:dd'+s; // ������� � ���� ���-��
      GBIBS.ParamByName('dd').AsDateTime:= dd;
      GBIBS.ExecQuery;
      j:= 0; // ������� �����
      while not GBIBS.Eof do begin
        i:= GBIBS.FieldByName('TRINCODE').AsInteger;
        Stream.WriteInt(i);                              // ��� ���-��
        s:= GBIBS.FieldByName('TRINNUMBER').AsString;
        Stream.WriteStr(s);                              // ����� ���-��
        dd:= GBIBS.FieldByName('TRINDATE').AsDateTime;
        Stream.WriteDouble(dd);                          // ���� ���-��
        i:= GBIBS.FieldByName('TRINSORCDPRTCODE').AsInteger;
        Stream.WriteInt(i);                              // ��� ����. ��������
        i:= GBIBS.FieldByName('TRINDESTDPRTCODE').AsInteger;
        Stream.WriteInt(i);                              // ��� ����. ������
        i:= GBIBS.FieldByName('TRINSHIPMENTMETHODCODE').AsInteger;
        Stream.WriteInt(i);                              // ��� ������� ��������
        dd:= GBIBS.FieldByName('TRINSHIPMENTDATE').AsDateTime;
        Stream.WriteDouble(dd);                          // ���� ��������
        i:= GBIBS.FieldByName('TRINSHIPMENTTIMECODE').AsInteger;
        Stream.WriteInt(i);                              // ��� ������� ��������
        s:= GBIBS.FieldByName('TRINCOMMENTS').AsString;
        Stream.WriteStr(s);                              // �����������
        if (GBIBS.FieldByName('TRINEXECUTED').AsString='T') then s:= '��������'
        else if (GBIBS.FieldByName('hcode').AsInteger>0) then s:= '���������'
        else s:= '������';
        Stream.WriteStr(s);                              // ������
//        fl:= GBIBS.FieldByName('TRINPRINTLOCK').AsString='T';
//        Stream.WriteBool(fl); // ���������� ����� ������
//        fl:= GBIBS.FieldByName('TRINBYNORMKEY').AsString='T';
//        Stream.WriteBool(fl); // �� ������
//        fl:= False; // ��������
//        Stream.WriteBool(fl); // ������������� �������������
        inc(j);
        TestCssStopException;
        GBIBS.Next;
      end;

    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;

    if j>0 then begin
      Stream.Position:= sPos;
      Stream.WriteInt(j);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;
//=================================== �������� ��������� �������� (����� WebArm)
procedure prWebArmGetTransInvoice(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetTransInvoice'; // ��� ���������/�������
var EmplID, InvID, i, sPos, j: Integer;
    s, InvCode: string;
    empl: TEmplInfoItem;
    GBIBS: TIBSQL;
    GBIBD: TIBDatabase;
    dd: Double;
begin
  GBIBS:= nil;
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;    // ��� ����������
    InvID:= Stream.ReadInt;    // ��� ����.��������

    InvCode:= IntToStr(InvID);
    prSetThLogParams(ThreadData, csShowTransferInvoice, EmplID, 0, 'InvID='+InvCode); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    j:= 0; // ������� ����� �������
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select TRINNUMBER, TRINDATE, TRINSORCDPRTCODE,'+
        ' TRINDESTDPRTCODE, TRINSHIPMENTMETHODCODE, TRINSHIPMENTDATE, TRINBYNORMKEY,'+
        ' TRINSHIPMENTTIMECODE, TRINCOMMENTS, TRINPRINTLOCK, TRINEXECUTED,'+
        ' iif(otwhcode is null and inwhcode is null, 0, 1) hcode from TRANSFERINVOICEREESTR'+
        ' left join AdditionalCheckMainWMSDocm(97, TrInCode, "T") io on 1=1'+
        ' left join AdditionalCheckMainWMSDocm(97, TrInCode, "F") ii on 1=1'+
        ' left join OUTWAREHOUSEREESTR ow on OTWHCODE=TrInWMSDocmCode'+
        '   and io.RCorrect="T" and OtWhMainDocmType=97'+
        ' left join inwarehousereestr iw on inwhcode=TrInWMSDocmCode'+
        '   and ii.RCorrect="T" and inwhmaindocmtype=97'+
        ' where TRINCODE='+InvCode;
      GBIBS.ExecQuery;
      if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create('�� ������� ���������');

      Stream.WriteInt(InvID);                          // ��� ���-��
      s:= GBIBS.FieldByName('TRINNUMBER').AsString;
      Stream.WriteStr(s);                              // ����� ���-��
      dd:= GBIBS.FieldByName('TRINDATE').AsDateTime;
      Stream.WriteDouble(dd);                          // ���� ���-��
      i:= GBIBS.FieldByName('TRINSORCDPRTCODE').AsInteger;
      Stream.WriteInt(i);                              // ��� ����. ��������
      s:= Cache.GetDprtMainName(i);
      Stream.WriteStr(s);                              // ������. ����. ��������
      i:= GBIBS.FieldByName('TRINDESTDPRTCODE').AsInteger;
      Stream.WriteInt(i);                              // ��� ����. ������
      s:= Cache.GetDprtMainName(i);
      Stream.WriteStr(s);                              // ������. ����. ������
      i:= GBIBS.FieldByName('TRINSHIPMENTMETHODCODE').AsInteger;
      Stream.WriteInt(i);                              // ��� ������� ��������
      with Cache.ShipMethods do if ItemExists(i) then s:= GetItemName(i) else s:= '';
      Stream.WriteStr(s);                              // ������. ������� ��������
      dd:= GBIBS.FieldByName('TRINSHIPMENTDATE').AsDateTime;
      Stream.WriteDouble(dd);                          // ���� ��������
      i:= GBIBS.FieldByName('TRINSHIPMENTTIMECODE').AsInteger;
      Stream.WriteInt(i);                              // ��� ������� ��������
      with Cache.ShipTimes do if ItemExists(i) then s:= GetItemName(i) else s:= '';
      Stream.WriteStr(s);                              // �������� ������� ��������
      s:= GBIBS.FieldByName('TRINCOMMENTS').AsString;
      Stream.WriteStr(s);                              // �����������
      if (GBIBS.FieldByName('TRINEXECUTED').AsString='T') then s:= '��������'
      else if (GBIBS.FieldByName('hcode').AsInteger>0) then s:= '���������'
      else s:= '������';
      Stream.WriteStr(s);                              // ������
      GBIBS.Close;

      sPos:= Stream.Position;
      Stream.WriteInt(0);  // ����� ��� ���-��

      GBIBS.SQL.Text:= 'select TrInLnWareCode, TrInLnPlanCount, TrInLnCount, TrInLnUnitCode'+
        ' from TransferInvoiceLines where TrInLnDocmCode='+InvCode;
      GBIBS.ExecQuery;
      while not GBIBS.Eof do begin
        i:= GBIBS.FieldByName('TrInLnWareCode').AsInteger;
        Stream.WriteInt(i);                              // ��� ������
        if Cache.WareExist(i) then s:= Cache.GetWare(i).Name else s:= '';
        Stream.WriteStr(s);                              // ������. ������
        dd:= GBIBS.FieldByName('TrInLnPlanCount').AsFloat;
        Stream.WriteDouble(dd);                          // ����
        dd:= GBIBS.FieldByName('TrInLnCount').AsFloat;
        Stream.WriteDouble(dd);                          // ���-��
        i:= GBIBS.FieldByName('TrInLnUnitCode').AsInteger;
        Stream.WriteInt(i);                              // ��� ��.���.
        s:= Cache.GetMeasName(i);
        Stream.WriteStr(s);                              // ������. ��.���.
        inc(j);
        TestCssStopException;
        GBIBS.Next;
      end;
      if j>0 then begin
        Stream.Position:= sPos;
        Stream.WriteInt(j);
      end;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;
//============== ���������� ������� �� ����� � ��������� �������� (����� WebArm)
procedure prWebArmAddWaresFromAccToTransInv(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmAddWaresFromAccToTransInv'; // ��� ���������/�������
var EmplID, InvID, AccID, i, DprtFrom, DprtTo, TimeID, ii: Integer;
    s, InvCode, AccCode, sLineCodes, Comment, InvNumber: string;
    empl: TEmplInfoItem;
    GBIBS: TIBSQL;
    GBIBD: TIBDatabase;
    ddShip: Double;
    arLineCodes: Tas;
    lst: TStringList;
begin
  GBIBS:= nil;
  Stream.Position:= 0;
  SetLength(arLineCodes, 0);
  lst:= TStringList.Create;
  try
    EmplID:= Stream.ReadInt;     // ��� ����������
    AccID:= Stream.ReadInt;      // ��� �����
    sLineCodes:= Stream.ReadStr; // ���� ����� ����� ��� ���������
    InvID:= Stream.ReadInt;      // ��� ����.�������� (<1 - ��������� �����)
    if (InvID<1) then begin // ����� ���������
      DprtFrom:= Stream.ReadInt;   // ����� ��������
      DprtTo:= Stream.ReadInt;     // ����� ������
      ddShip:= Stream.ReadDouble;  // ���� ��������
      TimeID:= Stream.ReadInt;     // ��� ������� ��������
      Comment:= Stream.ReadStr;    // �����������
    end else begin
      DprtFrom:= 0;
      DprtTo:= 0;
      ddShip:= 0;
      TimeID:= 0;
      Comment:= '';
    end;
    AccCode:= IntToStr(AccID);
    InvCode:= IntToStr(InvID);

    prSetThLogParams(ThreadData, csWebArmAddWaresFromAccToTransInv, EmplID, 0,
      'AccID='+AccCode+', InvID='+InvCode+', InvID='); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // ��������� ����� ������������   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));
    arLineCodes:= fnSplitString(sLineCodes, ',');
    if length(arLineCodes)<1 then raise EBOBError.Create('��� ����� ��� ���������');

    if (InvID<1) then begin // ����� ���������
      if not Cache.DprtExist(DprtFrom) then raise EBOBError.Create('�� ������� �/� ��������');
      if not Cache.DprtExist(DprtTo) then raise EBOBError.Create('�� ������� �/� ������');
      if (TimeID>0) and not Cache.ShipTimes.ItemExists(TimeID) then
        raise EBOBError.Create('�� ������� ����� ��������');
    end;

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpWrite, True);
      if (InvID>0) then begin //-------- ��������� ������ ������������ ���������
        GBIBS.SQL.Text:= 'select iif(otwhcode is null and inwhcode is null, 0, 1) hcode,'+
          ' TRINNUMBER, TRINEXECUTED, TRINSORCDPRTCODE, TRINDESTDPRTCODE from TRANSFERINVOICEREESTR'+
          ' left join AdditionalCheckMainWMSDocm(97, TrInCode, "T") io on 1=1'+
          ' left join AdditionalCheckMainWMSDocm(97, TrInCode, "F") ii on 1=1'+
          ' left join OUTWAREHOUSEREESTR ow on OTWHCODE=TrInWMSDocmCode'+
          '   and io.RCorrect="T" and OtWhMainDocmType=97'+
          ' left join inwarehousereestr iw on inwhcode=TrInWMSDocmCode'+
          '   and ii.RCorrect="T" and inwhmaindocmtype=97'+
          ' where TRINCODE='+InvCode;
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create('�� ������� ��������� ��������');
        if (GBIBS.FieldByName('TRINEXECUTED').AsString='T') then s:= '��������'
        else if (GBIBS.FieldByName('hcode').AsInteger>0) then s:= '���������' else s:= '';
        InvNumber:= GBIBS.FieldByName('TRINNUMBER').AsString;
        DprtFrom:= GBIBS.FieldByName('TRINSORCDPRTCODE').AsInteger;
        DprtTo:= GBIBS.FieldByName('TRINDESTDPRTCODE').AsInteger;
        GBIBS.Close;
        if (s<>'') then raise EBOBError.Create('��������� �������� '+InvNumber+' ����� ������ '+s);
      end;

      if (InvID<1) then begin //-------------------------------- ����� ���������
        GBIBS.SQL.Text:= 'insert into TRANSFERINVOICEREESTR (TRINNUMBER, TRINDATE,'+
          ' TRINHOUR, TRINSUBFIRMCODE, TRINSORCDPRTCODE, TRINDESTDPRTCODE,'+
          ' TRINSHIPMENTDATE, TRINSHIPMENTTIMECODE, TRINCOMMENTS) values '+
          '("< ���� >", "TODAY", EXTRACT(HOUR FROM CURRENT_TIMESTAMP), 1,'+
          IntToStr(DprtFrom)+', '+IntToStr(DprtTo)+', '+
          fnIfStr(ddShip>DateNull, ':ddShip', 'null')+', '+
          fnIfStr(TimeID>0, IntToStr(TimeID), 'null')+', '+
          fnIfStr(Comment<>'', ':comm', 'null')+') returning TRINCODE, TRINNUMBER';
        if (ddShip>DateNull) then GBIBS.ParamByName('ddShip').AsDateTime:= ddShip;
        if (Comment<>'') then GBIBS.ParamByName('comm').AsString:= Comment;
        s:= '������ �������� ��������� ��������';
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create(s);
        InvID:= GBIBS.FieldByName('TRINCODE').AsInteger;
        if (InvID<1) then raise EBOBError.Create(s);
        InvCode:= IntToStr(InvID);
        InvNumber:= GBIBS.FieldByName('TRINNUMBER').AsString;
        GBIBS.Close;
      end;
                                     //---------------- ����� ������ � ���������
      GBIBS.SQL.Text:= 'select rWareCode, rTransfer, rUnitCode'+
        ' from Vlad_CSS_WaresFromAccToTrInv('+AccCode+', :aAccLineCode, '+InvCode+')';
      GBIBS.Prepare;
      for i:= 0 to High(arLineCodes) do try
        GBIBS.ParamByName('aAccLineCode').AsString:= arLineCodes[i];
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then Continue;
        ii:= GBIBS.FieldByName('rWareCode').AsInteger;                       // ��� ������
        if not Cache.WareExist(ii) then Continue;
        if (GBIBS.FieldByName('rTransfer').AsInteger<1) then Continue;

        s:= fnMakeAddCharStr(GBIBS.FieldByName('rTransfer').AsString, 10)+   // ���-��
            ' '+Cache.GetMeasName(GBIBS.FieldByName('rUnitCode').AsInteger); // ��.���.
        s:= Cache.GetWare(ii).Name+cSpecDelim+s;
        lst.Add(s);                   // ������.������|||���-�� ��.���.
      finally
        GBIBS.Close;
      end;
      if (lst.Count<1) then raise EBOBError.Create('��� ���������� �����');

      GBIBS.Transaction.Commit;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(lst.Count+2);
    s:= '��������� ������ � ��������� �������� '+InvNumber; // ��������� - 2 ������
    Stream.WriteStr(s);
    s:= '('+Cache.GetDprtMainName(DprtFrom)+' - '+Cache.GetDprtMainName(DprtTo)+')';
    Stream.WriteStr(s);
    for i:= 0 to lst.Count-1 do Stream.WriteStr(lst[i]); //------ ������ �������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
  SetLength(arLineCodes, 0);
  prFree(lst);
end;
//================================================== ������ ����������� (WebArm)
procedure prWebArmGetNotificationsParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetNotificationsParams'; // ��� ���������/�������
var EmplID, noteID, FirmID, LineCount, FirmCount, pos, j: Integer;
    s: string;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    Filials, Classes, Types, Firms: TIntegerList;
    flAdd, flAuto, flMoto: Boolean;
begin
  IBS:= nil;
  Stream.Position:= 0;
  Filials:= TIntegerList.Create;
  Classes:= TIntegerList.Create;
  Types:= TIntegerList.Create;
  Firms:= TIntegerList.Create;
  try
    EmplID:= Stream.ReadInt;     // ��� ����������
    noteID:= Stream.ReadInt;     // ��� ����������� (<1 - ���)

    prSetThLogParams(ThreadData, csWebArmGetNotificationsParams, EmplID, 0, 'noteID='+IntToStr(noteID)); // �����������

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // �������� �����
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolNewsManage) then // ��������� ����� ������������
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);
    LineCount:= 0;

    IBD:= CntsORD.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'select NoteCODE, NoteBegDate, NoteEndDate, NoteText,'+
        ' NoteFilials, NoteClasses, NoteTypes, NoteFirms, NoteUpdTime,'+
        ' NOTEUSERID, NOTEFIRMSADDFLAG, NOTEauto, NOTEmoto, c.rCliCount, c.rFirmCount'+
        ' from Notifications left join GetNotifiedCounts(NoteCODE) c on 1=1'+
        ' where NoteArchived="F"'+fnIfStr(noteID>0, ' and NoteCODE='+IntToStr(noteID), '')+
        ' order by NoteBegDate, NoteEndDate';
      IBS.ExecQuery;
      while not IBS.Eof do begin
        Stream.WriteInt(IBS.FieldByName('NoteCODE').AsInteger);    // ��� �����������
        Stream.WriteDouble(IBS.FieldByName('NoteBegDate').AsDate); // ���� ������
        Stream.WriteDouble(IBS.FieldByName('NoteEndDate').AsDate); // ���� ���������
        Stream.WriteStr(IBS.FieldByName('NoteText').AsString);     // ����� �����������
//------------------------------------------------------ ��������� �������������
        EmplID:= IBS.FieldByName('NOTEUSERID').AsInteger;              // ��� �����
        if Cache.EmplExist(EmplID) then s:= Cache.arEmplInfo[EmplID].EmplShortName else s:= '';
        Stream.WriteStr(s);                                            // ��� �����
        Stream.WriteDouble(IBS.FieldByName('NoteUpdTime').AsDateTime); // ���� � �����
//---------------------------------- ��������� �-�� �/�, ���������� ������������
        Filials.Clear;                                      // ���� �������� �/�
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteFilials').AsString) do Filials.Add(j);
        Classes.Clear;                                     // ���� ��������� �/�
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteClasses').AsString) do Classes.Add(j);
        Types.Clear;                                       // ���� ����� �/�
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteTypes').AsString) do Types.Add(j);
        Firms.Clear;                                       // ����  �/�
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteFirms').AsString) do Firms.Add(j);
        flAdd:= GetBoolGB(ibs, 'NOTEFIRMSADDFLAG'); // ���� - ���������/��������� ���� Firms
        flAuto:= GetBoolGB(ibs, 'NOTEauto');         // ���� �������� �/� � ����-�����������
        flMoto:= GetBoolGB(ibs, 'NOTEmoto');         // ���� �������� �/� � ����-�����������
        FirmCount:= 0;
        for FirmID:= 1 to High(Cache.arFirmInfo) do // �������� ������������ �/� �������� ����������
          if CheckFirmFilterConditions(FirmID, flAdd, flAuto, flMoto,
            Filials, Classes, Types, Firms) then inc(FirmCount);
        Stream.WriteInt(FirmCount);
//------------------------------------------------------------------------------
        Stream.WriteInt(IBS.FieldByName('rFirmCount').AsInteger); // �-�� ������������� �/�
        Stream.WriteInt(IBS.FieldByName('rCliCount').AsInteger);  // �-�� ������������� �������������
        inc(LineCount);
        TestCssStopException;
        IBS.Next;
      end;
    finally
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
    end;
    if LineCount>0 then begin
      Stream.Position:= pos;
      Stream.WriteInt(LineCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
  prFree(Filials);
  prFree(Classes);
  prFree(Types);
  prFree(Firms);
end;
//============================ ������ ����� ������� (���������� �� ������������)
procedure prGetWareTypesTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareTypesTree'; // ��� ���������/�������
var pos, LineCount: Integer;
//    UserID, FirmID: Integer;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    s: String;
begin
  IBS:= nil;
  Stream.Position:= 0;
  try
    s:= Cache.GetConstItem(pcWareTypeRootCode).StrValue;
    if (s='') then raise EBOBError.Create(MessText(mtkNotValidParam));
//    FirmID:= Stream.ReadInt;
//    UserID:= Stream.ReadInt;
    Stream.ReadInt;
    Stream.ReadInt;

    IBD:= CntsGRB.GetFreeCnt;

    LineCount:= 0;
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(LineCount);

    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.ParamCheck:= False;
      IBS.SQL.Add('execute block returns (Rmaster integer, Rcode integer, Rname varchar(100))');
      IBS.SQL.Add('as declare variable xMasterCode integer='+s+';');
      IBS.SQL.Add('declare variable xChild integer; begin');
      IBS.SQL.Add('  if (exists(select * from WARES where WAREMASTERCODE=:xMasterCode)) then begin');
      IBS.SQL.Add('    for select WARECODE, WAREOFFICIALNAME, WARECHILDCOUNT from WARES');
      IBS.SQL.Add('      where WAREMASTERCODE=:xMasterCode order by WAREOFFICIALNAME');
      IBS.SQL.Add('    into :Rmaster, :Rname, :xChild do begin Rcode=Rmaster; suspend;');
      IBS.SQL.Add('      if (xChild>0) then for select WARECODE, WAREOFFICIALNAME');
      IBS.SQL.Add('        from WARES where WAREMASTERCODE = :Rmaster order by WAREOFFICIALNAME');
      IBS.SQL.Add('      into :Rcode, :Rname do suspend; end end end');
      IBS.ExecQuery;
      while not IBS.Eof do begin
        Stream.WriteInt(IBS.FieldByName('Rmaster').AsInteger);
        Stream.WriteInt(IBS.FieldByName('Rcode').AsInteger);
        Stream.WriteStr(IBS.FieldByName('Rname').AsString);
        inc(LineCount);
        TestCssStopException;
        IBS.Next;
      end;
    finally
      prFreeIBSQL(IBS);
      CntsGRB.SetFreeCnt(IBD);
    end;
    if LineCount>0 then begin
      Stream.Position:= pos;
      Stream.WriteInt(LineCount);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
end;

//============================================ 53-stamp - ���������� �/� �������
procedure prGetFirmClones(pUserID: Integer; pFileName: String; ThreadData: TThreadData=nil);
const nmProc = 'prGetFirmClones'; // ��� ���������/�������
var ordIBD, gbIBD, gbIBDw: TIBDatabase;
    ordIBS, gbIBS, gbIBSw: TIBSQL;
    lstSQL, lstSQL1: TStringList;
    Firm1, Cont1, fil, dprt, i: Integer;
    s, ss, sf1, sFirm: String;
    Percent: real;
begin
  ordIBS:= nil;
  gbIBS:= nil;
  gbIBSw:= nil;
//  gbIBDw:= nil;
//  ordIBD:= nil;
  lstSQL:= fnCreateStringList(False, 10); // ������ ����� SQL ��� ��������� ������� � ��������� ��������� �/�
  lstSQL1:= fnCreateStringList(False, 10); // ������ ����� SQL ��� ��������� �������� �������
  Percent:= 1;
  SetExecutePercent(pUserID, ThreadData, Percent);
  try
    gbIBD:= cntsGRB.GetFreeCnt('', '', '', True);
    gbIBDw:= cntsGRB.GetFreeCnt('', '', '', True);
    ordIBD:= cntsORD.GetFreeCnt('', '', '', True);
    try
      gbIBS:= fnCreateNewIBSQL(gbIBD, 'gbIBS_'+nmProc, -1, tpRead, true);
      gbIBS.SQL.Text:= 'select count(*) from firms where FirmCloneSource="T"';
      gbIBS.ExecQuery;
      fil:= gbIBS.Fields[0].AsInteger; // ���-�� ���� ��� ���������
      gbIBS.Close;
      if (fil>0) then Percent:= 90/fil
      else raise EBOBError.Create('�� ������� �/� ��� ������������');

      SetExecutePercent(pUserID, ThreadData, Percent);
      prMessageLOGn('�/�-��������;��������;�/�-��������;��������;���������', pFileName);

      ordIBS:= fnCreateNewIBSQL(ordIBD, 'ordIBS_'+nmProc, -1, tpWrite, true);
      s:= IntToStr(pUserID);
      ordIBS.SQL.Text:= 'select rClientOld, rArhLogin from CloneFirm(:FirmFrom,'+
        ' :ContFrom, :FirmTo, :ContTo, :FilialTo, :DprtTo, '+s+', :Clients)';

      gbIBSw:= fnCreateNewIBSQL(gbIBDw, 'gbIBSw_'+nmProc, -1, tpWrite, true);

      gbIBS.SQL.Text:= 'select f.firmcode as firm1, f1.firmcode as Firm2,'+
        ' c.contcode as Cont1, c1.contcode as Cont2, h.ctshlkdprtcode as dprt,'+
        ' f.firmmainname as fname1, f1.firmmainname as fname2,'+
        ' gn.rNum cNum1, gn1.rNum cNum2,'+
        ' p.prsnlogin as login1, p.prsncode as CliCode1,'+
        ' p1.prsnlogin as login2, p1.prsncode as CliCode2 from firms f'+
        ' left join contract c on c.contsecondparty=f.firmcode'+
        ' left join contract c1 on c1.contclonecontsource=c.contcode'+
        ' left join Vlad_CSS_GetFullContNum(c.contnumber, c.contnkeyyear, c.contpaytype) gn on 1=1'+
        ' left join Vlad_CSS_GetFullContNum(c1.contnumber, c1.contnkeyyear, c1.contpaytype) gn1 on 1=1'+
        ' left join contractstorehouselink h on h.ctshlkcontcode=c1.contcode and h.ctshlkdefault="T"'+
        ' left join firms f1 on f1.firmcode=c1.contsecondparty'+
        ' left join persons p on p.prsnfirmcode=f.firmcode and p.prsnlogin is not null'+
        ' left join persons p1 on p1.prsnfirmcode=f1.firmcode and p1.prsnlogin=p.prsnlogin'+
        ' where f.FirmCloneSource="T" and c1.contcode>0 order by Firm1, Cont1';
//        ' where f.FirmCloneSource="T" and p.prsncode<>p1.prsncode order by Firm1, Cont1';
      gbIBS.ExecQuery;
      while not gbIBS.Eof do begin
        Firm1:= gbIBS.FieldByName('firm1').AsInteger;
        sFirm:= gbIBS.FieldByName('firm1').AsString;
        lstSQL.Clear;
        lstSQL.Add('execute block as begin');
        sf1:= gbIBS.FieldByName('fname1').AsString+'('+sFirm+');';

        while not gbIBS.Eof and (Firm1=gbIBS.FieldByName('firm1').AsInteger) do begin
          Cont1:= gbIBS.FieldByName('Cont1').AsInteger;
          ss:= sf1+gbIBS.FieldByName('cNum1').AsString+';'+
               gbIBS.FieldByName('fname2').AsString+'('+gbIBS.FieldByName('firm2').AsString+');'+
               gbIBS.FieldByName('cNum2').AsString+';';

          if (Firm1=gbIBS.FieldByName('firm2').AsInteger) then begin
            ss:= ss+'��������� ������ �/� � ��� �� �����������';
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // �����������
            TestCssStopException;
            while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do gbIBS.Next;
            Continue;
          end;
{
          ss:= gbIBS.FieldByName('fname1').AsString+'('+gbIBS.FieldByName('firm1').AsString+');'+
               gbIBS.FieldByName('cNum1').AsString+';';
          s:= '';
          if (gbIBS.FieldByName('Firm2').AsInteger<1) then begin
            s:= '�� ������ �/�-��������';
            ss:= ss+';';
          end else ss:= ss+gbIBS.FieldByName('fname2').AsString+'('+gbIBS.FieldByName('firm2').AsString+');';
          if (gbIBS.FieldByName('Cont2').AsInteger<1) then begin
            s:= '�� ������ ��������-��������';
            ss:= ss+';';
          end else ss:= ss+gbIBS.FieldByName('cNum2').AsString+';';
          if (s<>'') then begin // ���� �� �����, ���� ����������
            ss:= ss+s;
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // �����������
            TestCssStopException;
            while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do gbIBS.Next;
            Continue;
          end;
}
          with ordIBS.Transaction do if not InTransaction then StartTransaction;
          ordIBS.ParamByName('FirmFrom').AsInteger:= Firm1;
          ordIBS.ParamByName('ContFrom').AsInteger:= Cont1;
          ordIBS.ParamByName('FirmTo').AsInteger:= gbIBS.FieldByName('Firm2').AsInteger;
          ordIBS.ParamByName('ContTo').AsInteger:= gbIBS.FieldByName('Cont2').AsInteger;
          dprt:= gbIBS.FieldByName('dprt').AsInteger;
          ordIBS.ParamByName('DprtTo').AsInteger:= dprt;
          if Cache.DprtExist(dprt) then fil:= Cache.arDprtInfo[dprt].FilialID else fil:= 0;
          ordIBS.ParamByName('FilialTo').AsInteger:= fil;

          s:= '';   // �������� ������ � �������� � ������ ��������
          while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do begin
            if (gbIBS.FieldByName('CliCode1').AsInteger<>gbIBS.FieldByName('CliCode2').AsInteger)
              and (gbIBS.FieldByName('login1').AsString=gbIBS.FieldByName('login2').AsString) then
              s:= s+fnIfStr(s='', '', ';')+gbIBS.FieldByName('login2').AsString+'='+gbIBS.FieldByName('CliCode2').AsString;
            TestCssStopException;
            gbIBS.Next;
          end;
          if (s='') then begin
            ss:= ss+'��� ������ � ����������� � �������� ��� ������������ � ���';
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // �����������
            TestCssStopException;
            while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do gbIBS.Next;
            Continue;
          end;

          ordIBS.ParamByName('Clients').AsString:= s;
          try
            ordIBS.ExecQuery; //------------------------- ��������� �/� � db_ORD
            s:= '';
            while not ordIBS.Eof do begin
              if (ordIBS.FieldByName('rClientOld').AsInteger<0) then // ������������/���������� ������� - � ���
                s:= s+' '+ordIBS.FieldByName('rArhLogin').AsString
              else if (ordIBS.FieldByName('rClientOld').AsInteger>0) then
                lstSQL.Add('update persons set prsnlogin="'+ordIBS.FieldByName('rArhLogin').AsString+
                           '" where prsncode='+ordIBS.FieldByName('rClientOld').AsString+';');
              TestCssStopException;
              ordIBS.Next;
            end;
            ordIBS.Transaction.Commit;
            ss:= ss+'���������� � ���';
            prMessageLOGS(nmProc+': '+ss+#13#10+s, 'import_test', False); // ����������� �������� �������
          except
            on E: Exception do begin
              with ordIBS.Transaction do if InTransaction then Rollback;
              ss:= ss+'������ ������������ � ���';
              prMessageLOGS(nmProc+': '+ss+#13#10+CutEMess(E.Message), 'import');
            end;
          end;
          ordIBS.Close;
          prMessageLOGn(ss, pFileName);
        end; // while ... (Firm1=

        lstSQL1.Add(sFirm); // ����� �������� ���� ���������� �/�
        // ���������� �������� ������������ �/� � Grossbee � ������ ������� �� ������ ����� ��������
        lstSQL.Add('  update firms set FirmCloneSource="F" where firmcode='+sFirm+';');
        lstSQL.Add('end');
        with gbIBSw.Transaction do if not InTransaction then StartTransaction;
        gbIBSw.SQL.Clear;
        gbIBSw.SQL.AddStrings(lstSQL);
        try
          gbIBSw.ExecQuery;
          gbIBSw.Transaction.Commit;
          ss:= sf1+';;;�������� ������� ������������ � Grossbee';
        except
          on E: Exception do begin
            with gbIBSw.Transaction do if InTransaction then Rollback;
            ss:= sf1+';;;!!! ������ ���������� �������� ������������ � Grossbee';
            prMessageLOGS(nmProc+': '+ss+#13#10+CutEMess(E.Message), 'import');
         end;
        end;
        gbIBSw.Close;
        prMessageLOGn(ss, pFileName);
        SetExecutePercent(pUserID, ThreadData, Percent);
        CheckStopExecute(pUserID, ThreadData); // �������� ��������� �������� ��� �������
      end; // while not gbIBS.Eof
      gbIBS.Close;
//-------------------------------------------- �������� ������ ������������� �/�
      ss:= '';
      sf1:= '';
      if (lstSQL1.Count>0) then begin // ����
        lstSQL1.Delimiter:= ',';
        lstSQL1.QuoteChar:= ' ';
        lstSQL.Clear;
        gbIBSw.SQL.Clear;
        gbIBSw.ParamCheck:= False;
        with gbIBSw.Transaction do if not InTransaction then StartTransaction;
        gbIBSw.SQL.Add('execute block returns(rCli integer, rLog varchar(20))'+
                       ' as declare variable xArh char(1); begin');
        for i:= 0 to lstSQL1.Count-1 do begin
          gbIBSw.SQL.Add(' for select prsncode, prsnlogin, prsnarchivedkey from persons'+
          ' where prsnfirmcode='+lstSQL1[i]+' and prsnlogin is not null'+
          ' and left(prsnlogin, 1)<>"_" into :rCli, :rLog, :xArh do if (rCli>0) then begin'+
          ' if (xArh="T") then begin rLog=left("_"||rLog, 20);'+
          '  update persons p set p.prsnlogin=:rLog where p.prsncode=:rCli; end suspend; end');
        end;
        gbIBSw.SQL.Add('end');
        try
          gbIBSw.ExecQuery;
          while not gbIBSw.Eof do begin
            s:= gbIBSw.FieldByName('rLog').AsString;
            sFirm:= gbIBSw.FieldByName('rCli').AsString;
            if (copy(s, 1, 1)<>'_') then sf1:= sf1+' "'+s+'"('+sFirm+')' // �� ������������ ������
            else lstSQL.Add('update WEBORDERCLIENTS set WOCLLOGIN="'+s+'" where WOCLCODE='+sFirm+';');
            TestCssStopException;
            gbIBSw.Next;
          end;
          gbIBSw.Transaction.Commit;
          if (lstSQL.Count>0) then ss:= ss+' �������/�������� � Grossbee'
          else ss:= ss+' �� ������� � Grossbee';
        except
          on E: Exception do begin
            with gbIBSw.Transaction do if InTransaction then Rollback;
            ss:= ss+' !!! ������ ������ � Grossbee �� �/� '+lstSQL1.DelimitedText+#13#10+CutEMess(E.Message);
            lstSQL.Clear;
         end;
        end;
        gbIBSw.Close;

        if (lstSQL.Count>0) then begin
          lstSQL.Insert(0, 'execute block as begin');
          lstSQL.Add('end');
          ordIBS.SQL.Clear;
          ordIBS.SQL.AddStrings(lstSQL);
          with ordIBS.Transaction do if not InTransaction then StartTransaction;
          try
            ordIBS.ExecQuery; //------------------------- ��������� �/� � db_ORD
            ordIBS.Transaction.Commit;
            ss:= ss+' �������� � ORD';
          except
            on E: Exception do begin
              with ordIBS.Transaction do if InTransaction then Rollback;
              ss:= ss+' !!! ������ ������ � ORD'#13#10+CutEMess(E.Message);
            end;
          end;
          ordIBS.Close;
        end;
      end; // if (lstSQL1.Count>0)
      if (ss<>'') then
        prMessageLOGS(nmProc+': ----------- �������� ������ ������.�/� '+ss, 'import_test', False); // �����������
      if (sf1<>'') then
        prMessageLOGS(nmProc+': ----------- �� ���������� ������ ������.�/� � Grossbee '+sf1, 'import_test', False); // �����������
    finally
      prFreeIBSQL(ordIBS);
      cntsORD.SetFreeCnt(ordIBD, True);
      prFreeIBSQL(gbIBS);
      cntsGRB.SetFreeCnt(gbIBD, True);
      prFreeIBSQL(gbIBSw);
      cntsGRB.SetFreeCnt(gbIBDw, True);
      prFree(lstSQL);
      prFree(lstSQL1);
    end;
  except
    on E: EBOBError do raise EBOBError.Create(E.Message);
    on E: Exception do begin
      E.Message:= nmProc+': '+E.Message;
      prMessageLOGS(E.Message, 'import');
      raise Exception.Create(E.Message);
    end;
  end;
end;

//******************************************************************************
//                          ���������� ��������
//******************************************************************************
// Cache -> ShipMethods - ������ ��������, ShipTimes - ������� ��������
// Cache -> TDprtInfo.DelayTime - ����� ������������ � ���
// Grossbee ->
// FIRMDEPARTMENT - �������� ����� ����������
// CONTRACTDESTPOINT
// TRANSPORTTIMETABLESREESTR - ������ ����������
// PAYINVOICEREESTR->PINVTRIPCODE - ������ �� TRANSPORTTIMETABLESLINES->TRTBLNCODE
// select RLineCode from GETTRTBLINECODEFROMLOCATION(:ALocationCode, :ADocmCode) -
//   ��� ������ TRANSPORTTIMETABLESLINES �� ���� ��������������� � ���� ����������
// select RENABLEDDATE from CHECKTRTBDISABLEDDATE(:ADATE, :ADOCMCODE) - �������� ��������� ����
//******************************************************************************
//============================ ������ ��������� ������ ���������� (Web & Webarm)
procedure prGetTimeListSelfDelivery(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetTimeListSelfDelivery'; // ��� ���������/�������
var UserID, FirmID, ForFirmID, ContID, stID, i, aTime: integer;
    Firm: TFirmInfo;
    Contract: TContract;
    errmess: string;
    SL: TStringList;
    aDate: TDateTime;
    flNotAvailable, flWithSVKDelay: Boolean;
begin
  Stream.Position:= 0;
  SL:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // Web- ��� �/�, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- �������, Webarm- ��� �/�
    ContID:= Stream.ReadInt;
    aDate:= Stream.ReadDouble;
    aTime:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetTimeListSelfDelivery, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if (FirmID<>IsWe) then begin
      ForFirmID:= FirmID;
      if not Cache.FirmExist(ForFirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
    end;
    if not Cache.arFirmInfo[ForFirmID].CheckContract(ContID) then
      raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));

    Firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(ContID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');

    flWithSVKDelay:= (FirmID<>IsWe); // ��� �������� - ��������� ������������ ���
//    flWithSVKDelay:= False; // 06.08.2017 - ������ �������

    errmess:= GetAvailableSelfGetTimesList(Contract.MainStorage, aDate, aTime, SL, flWithSVKDelay);
    if (errmess<>'') then raise EBOBError.Create(errmess);

    flNotAvailable:= (aTime<0);
    if flNotAvailable then aTime:= -aTime;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(SL.Count);
    for I:= 0 to SL.Count-1 do begin
      stID:= integer(SL.Objects[i]);
      if flNotAvailable and (stID=aTime) then stID:= -stID;
      Stream.WriteInt(stID);
      Stream.WriteStr(SL[i]); //
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(SL);
end;
//======================= ������ ��������� ��� �������� �� ������ (Web & Webarm)
procedure prGetDprtAvailableShipDates(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetDprtAvailableShipDates'; // ��� ���������/�������
var UserID, FirmID, ForFirmID, ContID, stID, i, iDate: integer;
    Firm: TFirmInfo;
    Contract: TContract;
    errmess: string;
    SL: TStringList;
    aDate: TDateTime;
//    flWithSVKDelay: Boolean;
begin
  Stream.Position:= 0;
  SL:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // Web- ��� �/�, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- �������, Webarm- ��� �/�
    ContID:= Stream.ReadInt;
    aDate:= Stream.ReadDouble;

    prSetThLogParams(ThreadData, csGetDprtAvailableShipDates, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // �����������

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if (FirmID<>IsWe) then begin
      ForFirmID:= FirmID;
      if not Cache.FirmExist(ForFirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
    end;
    if not Cache.arFirmInfo[ForFirmID].CheckContract(ContID) then
      raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));

    Firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(ContID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');
    iDate:= Trunc(aDate);
//    flWithSVKDelay:= (FirmID<>IsWe); // ��� �������� - ��������� ������������ ���

//    errmess:= GetAvailableShipDatesList(Contract.MainStorage, iDate, SL, flWithSVKDelay);
    errmess:= GetAvailableShipDatesList(Contract.MainStorage, iDate, SL);
    if (errmess<>'') then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(SL.Count);
    for I:= 0 to SL.Count-1 do begin
      stID:= integer(SL.Objects[i]);
      Stream.WriteInt(stID);
      Stream.WriteStr(SL[i]); //
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(SL);
end;
//=============================== ������ �������� ����� ��������� (Web & Webarm)
procedure prGetContractDestPointsList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetContractDestPointsList'; // ��� ���������/�������
var i, UserID, FirmID, sPos, ContID, ForFirmID, j, dsID: integer;
    GBdirection: Boolean;
    s: string;
    Contract: TContract;
    dest: TDestPoint;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // Web- ��� �/�, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- �������, Webarm- ��� �/�
    ContID:= Stream.ReadInt;
    GBdirection:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csGetContractDestPointsList, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)+
      #13#10'GBdirection='+fnIfStr(GBdirection, '1', '0')); // �����������

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if (FirmID<>IsWe) then begin
      ForFirmID:= FirmID;
      if not Cache.FirmExist(ForFirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
    end;
    with Cache.arFirmInfo[ForFirmID] do begin
      if not CheckContract(ContID) then
        raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
      Contract:= GetContract(ContID);
      if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
        raise EBOBError.Create('�������� '+Contract.Name+' ����������');
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    sPos:= Stream.Position;
    j:= 0;
    Stream.WriteInt(j); // ����� ��� ���-�� �����
    for i:= 0 to Contract.ContDestPointCodes.Count-1 do begin
      dsID:= Contract.ContDestPointCodes[i];
      dest:= Contract.GetContDestPoint(dsID);
      if not Assigned(dest) or dest.Disabled then Continue;
      Stream.WriteInt(dest.ID);
      Stream.WriteStr(dest.Name);
      Stream.WriteStr(dest.Adress);
      Inc(j);
    end;
    if (j>0) then begin
      Stream.Position:= sPos;
      Stream.WriteInt(j); // �������� ���-�� �����
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//====================== ������ ��������� ���������� �� ��������� (Web & Webarm)
procedure prGetAvailableTimeTablesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetAvailableTimeTablesList'; // ��� ���������/�������
var i, UserID, FirmID, sPos, ContID, ForFirmID, DprtID, DestID, AccountID: integer;
    ttID, smID, stID, TestTime, TimeMin, TimeMax, ExCount, SVKDelay: Integer;
    ibd: TIBDatabase;
    ibs: TIBSQL;
    flWithSVKDelay, flEx: Boolean;
    pDate: TDateTime;
    s, s1, s2: String;
    st: TShipTimeItem;
    firma: TFirmInfo;
    Contract: TContract;
    dprt: TDprtInfo;
    ilst: TIntegerList;
begin
  Stream.Position:= 0;
  IBS:= nil;
  i:= 0;
  ilst:= TIntegerList.Create; // ������ ����� ��������� � ������ ����������
  ExCount:= 0;
  SVKDelay:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // Web- ��� �/�, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- �������, Webarm- ��� �/�
    ContID:= Stream.ReadInt;
    AccountID:= Stream.ReadInt;  // Web- �������, Webarm- ��� �����
    DestID:= Stream.ReadInt;
    pDate:= Stream.ReadDouble;

    prSetThLogParams(ThreadData, csGetAvailableTimeTablesList, UserID, FirmID, // �����������
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)+
      #13#10'DestID='+IntToStr(DestID)+#13#10'pDate='+FormatDateTime(cDateTimeFormatY2S, pDate));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if (FirmID<>IsWe) then begin
      ForFirmID:= FirmID;
      if not Cache.FirmExist(ForFirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
    end;

    if (DestID<1) then raise EBOBError.Create('�� ������ �������� �����');

    firma:= Cache.arFirmInfo[ForFirmID];
    if not firma.CheckContract(ContID) then
      raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
    Contract:= firma.GetContract(ContID);
    if (Contract.Status=cstClosed) then         // �������� �� ����������� ���������
      raise EBOBError.Create('�������� '+Contract.Name+' ����������');

    DprtID:= Contract.MainStorage;
    flWithSVKDelay:= (FirmID<>IsWe); // ��� �������� - ��������� ������������ ���

    dprt:= Cache.arDprtInfo[DprtID];
    s:= dprt.CheckShipAvailable(pDate, 0, 0, False, False);
    if (s<>'') then raise EBOBError.Create(s);

    if flWithSVKDelay then
      SVKDelay:= Cache.GetConstItem(pcSVKShipDelayMinutes).IntValue;
                                              // ������� ������ �������� �� ����
    s:= dprt.GetShipTimeLimits(pDate, TimeMin, TimeMax, SVKDelay, True);
    if (s<>'') then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    sPos:= Stream.Position;
    Stream.WriteInt(0);      // ����� ��� ���-�� �����
    Stream.WriteBool(False); // ����� ��� ������� - ���� ���������� �� ������

    ibd:= cntsGRB.GetFreeCnt;
    try  // ���� ��������� � ������ �/� ���������� ��� ���� ��������, ������ � ����.�����
      ibs:= fnCreateNewIBSQL(ibd, 'ibs_'+nmProc, -1, tpRead, True);
      if (pDate>DateNull) then begin
        ibs.SQL.Text:= 'select TRTBLNDOCMCODE'+
          ' from Vlad_CSS_GetFirmReserveDocsN('+IntToStr(ForFirmID)+', 0) g'+
          '  left join payinvoicereestr on pinvcode=g.rPInvCode'+
          '  left join TRANSPORTTIMETABLESLINES on TRTBLNCODE=pinvtripcode'+
          '  where rPInvLocked="F" and rPInvDprt='+IntToStr(DprtID)+
          '    and PINVSUPPLIERFIRMDPRT = '+IntToStr(DestID)+
          fnIfStr(AccountID>0, ' and rPInvCode<>'+IntToStr(AccountID), '')+
          '    and pinvshipmentdate=:pDate group by TRTBLNDOCMCODE';
        ibs.ParamByName('pDate').AsDate:= pDate;
        ibs.ExecQuery;
        while not ibs.Eof do begin
          ttID:= ibs.FieldByName('TRTBLNDOCMCODE').AsInteger;
          if (ttID>0) then ilst.Add(ttID);
          TestCssStopException;
          ibs.Next;
        end;
        ibs.Close;
      end;

      ibs.SQL.Text:= 'select RttID, rSMethodID, rSTimeID, rArrive, rTestTime'+
        '  from Vlad_CSS_GetContDestTimeTables1('+IntToStr(ContID)+', '+
        IntToStr(DestID)+', '+IntToStr(DprtID)+', :pDate) order by rTestTime';

      ibs.ParamByName('pDate').AsDate:= pDate;
      ibs.ExecQuery;
      while not ibs.Eof do begin
        ttID:= ibs.FieldByName('RttID').AsInteger;
        smID:= ibs.FieldByName('rSMethodID').AsInteger;
        stID:= ibs.FieldByName('rSTimeID').AsInteger;
        pDate:= ibs.FieldByName('rArrive').AsDateTime;
        s1:= '';
        s2:= '';
        st:= nil;
        if Cache.ShipMethods.ItemExists(smID) then
          s1:= TShipMethodItem(Cache.ShipMethods[smID]).Name;
        if (s1<>'') and Cache.ShipTimes.ItemExists(stID) then begin
          st:= Cache.ShipTimes[stID];
          s2:= st.Name;
        end;
        if ((s1='') or (s2='') or not Assigned(st)) then begin
          cntsGRB.TestSuspendException;
          TestCssStopException;
          ibs.Next;
          Continue;
        end;
        TestTime:= ibs.FieldByName('rTestTime').AsInteger*60;
        if (TestTime<TimeMin) or (TestTime>TimeMax) then begin // ��������� �����
          cntsGRB.TestSuspendException;
          ibs.Next;
          Continue;
        end;

        Stream.WriteInt(ttID);  // ��� ����������
        Stream.WriteStr(s1);   // ����� ��������
        Stream.WriteStr(s2);   // ����� ��������
        if (pDate>DateNull) then s1:= FormatDateTime(cDateTimeFormatY2N, pDate) else s1:= '';
        Stream.WriteStr(s1); // ����+����� ��������
        flEx:= (ilst.IndexOf(ttID)>-1);
        Stream.WriteBool(flEx); // ������� - ����� ���������� ���� � ������
        if flEx then Inc(ExCount);
        TestCssStopException;
        ibs.Next;
        Inc(i);
      end;
    finally
      prFreeIBSQL(ibs);
      cntsGRB.SetFreeCnt(ibd);
    end;
    Stream.Position:= sPos;
    Stream.WriteInt(i); // �������� ���-�� ����������
    if (ExCount>0) then Stream.WriteBool(True); // ������� - ���� ���������� �� ������

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(ilst);
  Stream.Position:= 0;
end;
//=========================================== �������� ���������� �������� �����
procedure prGetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetAccountShipParams'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserId, FirmID, ForFirmID, DestID, ShipTableID, ShipMetID, ShipTimeID, DelivType, i: integer;
    AccountCode, sDestName, sShipMet, sShipTime, sArrive, sDestAdr, err: string;
    ShipDate, pDate: double;
begin
  Stream.Position:= 0;
  IBS:= nil;
//  IBD:= nil;
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
  try
//-------------------------- from CGI - begin
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;    // IsWe
    ForFirmID:= Stream.ReadInt; // ��� �/�
    AccountCode:= Stream.ReadStr;
//-------------------------- from CGI - end

    prSetThLogParams(ThreadData, csGetAccountShipParams, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'AccountID='+AccountCode); // �����������

    if CheckNotValidUser(UserID, FirmID, err) then raise EBOBError.Create(err);
    i:= StrToIntDef(AccountCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));

    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'select sss.*, s.shmhname sShipMet, ss.shtiname sShipTime'+ // ����  ����
        ' from (SELECT PInvCode, PINVSUPPLIERFIRMDPRT, PInvRecipientCode,'+
//        ' TRTBLNDOCMCODE shiptab, gm.RFullName rAdress, PINVSHIPMENTDATE, fddprtname,'+
        ' TRTBLNDOCMCODE shiptab, gm.rAdress, PINVSHIPMENTDATE, fddprtname,'+
        ' iif(TRTBSHIPMETHODCODE is null, PINVSHIPMENTMETHODCODE, TRTBSHIPMETHODCODE) ShipMet,'+
        ' iif(TRTBSHIPTIMECODE is null, PINVSHIPMENTTIMECODE, TRTBSHIPTIMECODE) ShipTime,'+
        ' iif(trtblnarrivetime is null, null, DATEADD(MINUTE, round(trtblnarrivetime), PINVSHIPMENTDATE)) arrive'+
        ' from PayInvoiceReestr'+
        ' left join TRANSPORTTIMETABLESLINES on TRTBLNCODE=pinvtripcode'+
        ' left join TRANSPORTTIMETABLESREESTR tt on tt.TRTBCODE=TRTBLNDOCMCODE'+
        ' left join FIRMDEPARTMENT on fdcode=PINVSUPPLIERFIRMDPRT'+
//        ' left join GETANRGFULLLOCATIONNAME(fdplasement) gm on 1=1) sss'+
        ' left join GETADRESSSTREX(fdplasement, "T") gm on 1=1) sss'+
        ' left join shipmentmethods s on s.shmhcode=ShipMet'+
        ' left join shipmenttimes ss on ss.shticode=ShipTime'+
        ' where PInvCode='+AccountCode+' and PInvRecipientCode='+IntToStr(ForFirmID);
      IBS.ExecQuery;
      if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));

      DestID:= IBS.FieldByName('PINVSUPPLIERFIRMDPRT').AsInteger;
      sDestAdr:= trim(IBS.FieldByName('rAdress').AsString);
      sDestName:= trim(IBS.FieldByName('fddprtname').AsString);
      ShipDate:= IBS.FieldByName('PINVSHIPMENTDATE').AsDateTime;
      ShipTableID:= IBS.FieldByName('shiptab').AsInteger;
      ShipMetID:= IBS.FieldByName('ShipMet').AsInteger;
      sShipMet:= trim(IBS.FieldByName('sShipMet').AsString);
      ShipTimeID:= IBS.FieldByName('ShipTime').AsInteger;
      sShipTime:= trim(IBS.FieldByName('sShipTime').AsString);
      if (ShipTableID>0) and not IBS.FieldByName('arrive').IsNull then begin
        pDate:= IBS.FieldByName('arrive').AsDateTime;
        if (pDate>DateNull) then sArrive:= FormatDateTime(cDateTimeFormatY2N, pDate);
      end;
      IBS.Close;
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    if (ShipDate<DateNull) then ShipDate:= 0;
    if (ShipDate<1) or (DestID<1) then ShipTableID:= 0;

    if (ShipTableID>0) then DelivType:= cDelivTimeTable // �������� �� ����������
    else if (ShipMetID=Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue) then
      DelivType:= cDelivSelfGet                         // ���������
    else if (ShipMetID=Cache.GetConstItem(pcCliNowShipMethodCode).IntValue) then
      DelivType:= cDelivClientNow                       // ������ �� ������
    else DelivType:= cDelivReserve;                     // ������

    Stream.Clear;
//-------------------------- to CGI - begin
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
    Stream.WriteInt(DelivType);   // ��� ��������
    Stream.WriteInt(DestID);      // ��� �������� �����
    Stream.WriteStr(sDestName);   // �������� �������� �����
    Stream.WriteStr(sDestAdr);    // ����� �������� �����
    Stream.WriteDouble(ShipDate); // ���� ��������
    Stream.WriteInt(ShipTableID); // ��� ����������
    Stream.WriteStr(sShipMet);    // �������� ������� ��������
    Stream.WriteInt(ShipTimeID);  // ��� ������� ��������
    Stream.WriteStr(sShipTime);   // ����� ������� ��������
    Stream.WriteStr(sArrive);     // ����� ����/������� ��������
//-------------------------- to CGI - end
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//===================================== �������������� ���������� �������� �����
procedure prSetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetAccountShipParams'; // ��� ���������/�������
var IBD: TIBDatabase;
    IBS: TIBSQL;
    UserId, FirmID, ForFirmID, DestID, ShipTableID, ShipMetID, ShipTimeID,
      DelivType, ContID, DprtID, i: integer;
    AccountCode, sDestName, sShipMet, sShipTime, sArrive, sDestAdr, err: string;
    ShipDate: TDateTime;
begin
  Stream.Position:= 0;
  IBS:= nil;
//  IBD:= nil;
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
  try
//-------------------------- from CGI - begin
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;       // IsWe
    ForFirmID:= Stream.ReadInt;   // ��� �/�
    AccountCode:= Stream.ReadStr; // ��� ����� � ����.����
    DelivType:= Stream.ReadInt;   // ��� ��������: 0 - ��������, 1 - ������, 2 - ���������, 3 - ������ �� ������
    DestID:= Stream.ReadInt;      // ��� �������� �����
    ShipDate:= Stream.ReadDouble; // ���� ��������
    ShipTableID:= Stream.ReadInt; // ��� ����������
    ShipTimeID:= Stream.ReadInt;  // ��� ������� ��������
//-------------------------- from CGI - end
    if (ShipDate<DateNull) then ShipDate:= 0;
                                                                // �����������
    prSetThLogParams(ThreadData, csSetAccountShipParams, UserID, FirmID, 'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'AccountID='+AccountCode+#13#10'DELIVERYTYPE='+IntToStr(DelivType)+
      #13#10'DESTPOINT='+IntToStr(DestID)+#13#10'SHIPDATE='+FormatDateTime(cDateFormatY2, ShipDate)+
      #13#10'TIMETIBLE='+IntToStr(ShipTableID)+#13#10'SHIPTIMEID='+IntToStr(ShipTimeID));

    if CheckNotValidUser(UserID, FirmID, err) then raise EBOBError.Create(err);

    i:= StrToIntDef(AccountCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));

    if not (DelivType in [cDelivTimeTable, cDelivReserve, cDelivSelfGet, cDelivClientNow]) then
      raise EBOBError.Create('����������� ��� �������� - '+IntToStr(DelivType));

    IBD:= cntsGRB.GetFreeCnt(Cache.arEmplInfo[UserID].GBLogin, cDefPassword, cDefGBrole);
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'select PInvSupplyDprtCode, PINVCONTRACTCODE from PayInvoiceReestr'+ // ����  ����
        ' where PInvCode='+AccountCode+' and PInvRecipientCode='+IntToStr(ForFirmID);
      IBS.ExecQuery;
      if IBS.Bof and IBS.Eof then
        raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));
      ContID:= IBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      DprtID:= IBS.FieldByName('PInvSupplyDprtCode').AsInteger;
      IBS.Close;

      err:= CheckAccountShipParams(DelivType, ContID, DprtID, ShipDate, DestID, ShipTableID, ShipMetID, ShipTimeID, False);
      if (err<>'') then raise EBOBError.Create(err);
      if (DelivType=cDelivTimeTable) and (ShipTableID>0) then ShipTimeID:= 0;  // �������� �� ���������� - ��� ������� �� ����� - ���

      fnSetTransParams(ibs.Transaction, tpWrite, True);
      IBS.SQL.Text:= 'Select ErrMess from Vlad_CSS_SetAccountShipParams('+
        AccountCode+', '+fnIfStr(ShipDate>DateNull, ':dd', 'null')+', '+IntToStr(DestID)+', '+
        IntToStr(ShipTableID)+', '+IntToStr(ShipMetID)+', '+IntToStr(ShipTimeID)+')';
      if (ShipDate>DateNull) then IBS.ParamByName('dd').AsDate:= ShipDate;
      IBS.ExecQuery;
      if (IBS.Bof and IBS.Eof) then
        raise Exception.Create('Error Vlad_CSS_SetAccountShipParams');
      err:= IBS.FieldByName('ErrMess').AsString;
      if (err<>'') then raise EBOBError.Create(err);
      if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    Stream.Clear;
//-------------------------- to CGI - begin
    Stream.WriteInt(aeSuccess); // ���� ����, ��� ������ ��������� ���������
//-------------------------- to CGI - end
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prWebArmResetPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmResetPassword'; // ��� ���������/�������
var
  UserId, FirmID: integer;
  errmess: string;
  pass1, pass2: string;
  ordIBD: TIBDatabase;
  OrdIBS: TIBSQL;
  empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  ordIBD:= nil;
  OrdIBS:= nil;
  FirmID:= isWe;
  try
    UserID:= Stream.ReadInt;
    pass1:= trim(Stream.ReadStr);
    pass2:= trim(Stream.ReadStr);

    prSetThLogParams(ThreadData, csWebArmResetPassword, UserId, isWe,
      ' newpass1='+pass1+' newpass2='+pass2); // �������� �����������!

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    empl:= Cache.arEmplInfo[UserId];
    if (not empl.RESETPASSWORD) then
      raise EBoBAutenticationError.Create('� ����� ������� ������ ��� ������� �� ������������ ����� ������.');

    if (not fnCheckOrderWebPassword(pass1)) then
      raise EBOBError.Create('������ �� ������������� �������� �����������.');

    if (pass1<>pass2) then
      raise EBOBError.Create('��������� ������ �� ���������.');

    if (pass1=empl.USERPASSFORSERVER) then
      raise EBOBError.Create('����� ������ �� ������ ��������� �� ������');

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBSQL_'+nmProc, ThreadData.ID, tpWrite, True);
    ordIBS.SQL.Text:= 'UPDATE EMPLOYEES SET EMPLPASS=:pass, EMPLRESETPASWORD="F"'+
                      ' WHERE EMPLCODE='+IntToStr(UserId);
    ordIBS.ParamByName('pass').AsString:= pass1;
    ordIBS.ExecQuery;
    ordIBS.Transaction.Commit;
    empl.RESETPASSWORD:= false;
    empl.USERPASSFORSERVER:= pass1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(ordIBS);
  cntsORD.SetFreeCnt(ordIBD);
end;
//************************************************ �������� ������ �������������
function fnChangePasswordWebarm(UserID: Integer; oldpass, newpass1, newpass2: string): string;
const nmProc = 'fnChangePasswordWebarm'; // ��� ���������/�������
var OrdIBS: TIBSQL;
    OrdIBD: TIBDatabase;
    i: integer;
    s: string;
    Empl: TEmplInfoItem;
begin
  Result:= '';
  OrdIBS:= nil;
  OrdIBD:= nil;
  try
//    prSetThLogParams(ThreadData, 0, UserID, 0,
//      'oldpass='+oldpass+#13#10+'newpass1='+newpass1+#13#10+'newpass2='+newpass2); // �����������
    if CheckNotValidUser(UserID, IsWe, s) then raise EBOBError.Create(s);
    if (newpass1=oldpass) then
      raise EBOBError.Create('����� ������ �� ������ ��������� �� ������.');
    i:= Cache.CliPasswLength;
    if not fnCheckOrderWebPassword(newpass1) then
      raise EBOBError.Create(MessText(mtkNotValidPassw, IntToStr(i)));
    if (newpass1<>newpass2) then
      raise EBOBError.Create('����� ������ � ��� ������ �� ���������.');

    Empl:= Cache.arEmplInfo[UserID];
    if (newpass1=Empl.ServerLogin) then
      raise EBOBError.Create('������ �� ������ ��������� � �������.');
    if (oldpass<>Empl.USERPASSFORSERVER) then
      raise EBOBError.Create('������ ������ ������ �������.');

    OrdIBD:= cntsORD.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(OrdIBD, 'OrdIBS_'+nmProc, -1, tpWrite, true);
    ordIBS.SQL.Text:= 'UPDATE EMPLOYEES SET EMPLPASS=:pass, EMPLRESETPASWORD="F"'+
                      ' WHERE EMPLCODE='+IntToStr(UserId);
    ordIBS.ParamByName('pass').AsString:= newpass1;
    s:= RepeatExecuteIBSQL(OrdIBS);
    if s<>'' then raise Exception.Create(s);

    Empl.RESETPASSWORD:= false;
    Empl.USERPASSFORSERVER:= newpass1;
  except
    on E: Exception do Result:= E.Message;
  end;
  prFreeIBSQL(OrdIBS);
  cntsORD.SetFreeCnt(OrdIBD);
end;
//============= ��������� ������ ������ �� �������, �����, ������, ������ ������
procedure prProductWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductWareSearch'; // ��� ���������/�������
var EmplID, idxTemplate: integer;        // ��� ������/������ ��� ������ ������
    lstSearchWare: TStringList;  // ���� ��������� �������
    Template: string;            // ������ ������
    IgnoreSpec, TypeList: byte;
    flUik, flCheckUser, flProduct: Boolean;
    ware: TWareInfo;
    empl: TEmplInfoItem;
  //----------- ���������� ������ �������, ��������������� �� ������������
  procedure prSearchWareNames;
  var i: integer;
      fl: boolean;
      s, ss: String;
  begin
    fl:= False;
    if Template = '' then Exit;
    s:= AnsiUpperCase(Template);
    if IgnoreSpec > 0 then ss:= fnDelSpcAndSumb(s);
    for i:= 1 to High(Cache.arWareInfo) do if Cache.WareExist(i) then begin
      ware:= Cache.GetWare(i);
      if Ware.IsPrize then begin
        if not flUiK then Continue; // ��� - ��� �����
      end else begin
        if not flProduct or (ware.PgrID<1) then Continue;
        if flCheckUser and (ware.ManagerID<>EmplID) then Continue;
      end;
      case IgnoreSpec of
        0: fl:= pos(s, ware.Name)>0;
        1: fl:= pos(ss, ware.NameBS)>0;
        2: fl:= (pos(s, ware.Name)>0) or (pos(ss, ware.NameBS)>0);
      end;
      if fl then lstSearchWare.AddObject(ware.Name, ware);
    end; // for i:=
    lstSearchWare.Sort;
  end;
  //-------------------------- ����� ������ �� ���� ������/������
  procedure prSearchWareBGCode;
  var i: integer;
      fl, isBG, is0: boolean;
  begin
    is0:= (idxTemplate<1);
    isBG:= False;
    if not is0 then isBG:= Cache.WareBrands.ItemExists(idxTemplate);

    for i:= 1 to High(Cache.arWareInfo) do if Cache.WareExist(i) then begin
      ware:= Cache.GetWare(i);
      if (ware.PgrID=Cache.pgrDeliv) or ware.IsArchive then Continue; // ���������� �������� � ��������
      if Ware.IsPrize then begin
        if not flUiK then Continue; // ��� - ��� �����
      end else begin
        if not flProduct or (ware.PgrID<1) then Continue;
        if flCheckUser and (ware.ManagerID<>EmplID) then Continue;
      end;
      if is0 then fl:= Ware.IsPrize // True
      else if not isBG then fl:= (ware.PgrID=idxTemplate)
      else fl:= (ware.WareBrandID=idxTemplate);

      if fl then lstSearchWare.AddObject(ware.Name, ware);
    end;
    lstSearchWare.Sort;
  end;
 //-------------------------- �������� ������ ��������� ������� � �����
  procedure prSaveResultToStream;
  var i: integer;
  begin
    Stream.WriteInt(lstSearchWare.Count);
    for i:= 0 to lstSearchWare.Count-1 do begin // ������ ������ � �����
      ware:= TWareInfo(lstSearchWare.Objects[i]);
      Stream.WriteInt(ware.ID);
      if (TypeList=1) then begin
        Stream.WriteStr(ware.GrpName);
        Stream.WriteStr(ware.PgrName);
      end else begin
        Stream.WriteInt(ware.GrpID);
        Stream.WriteInt(ware.PgrID);
      end;
      Stream.WriteStr(ware.Name);
    end;
  end;
  //--------------------------
begin
  Stream.Position:= 0;
  lstSearchWare:= nil;
  try
    try
      EmplID:= Stream.ReadInt;
      flCheckUser:= Boolean(Stream.ReadByte); // ��������� ��������� � ������: 0 - ���, 1 - ��
      TypeList:= Stream.ReadByte;      // ��� ������������� ������: 0 - �������, 1 - ������

      prSetThLogParams(ThreadData, csProductWareSearch, EmplID);

      if not Cache.EmplExist(EmplID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
      empl:= Cache.arEmplInfo[EmplID];

      flUik:= empl.UserRoleExists(rolUik);
      flProduct:= empl.UserRoleExists(rolProduct);
      if not flProduct and not flUik then
        raise EBOBError.Create(MessText(mtkNotRightExists));

      lstSearchWare:= TStringList.Create;

      if Stream.ReadByte = 1 then begin // ����� �� ������
        IgnoreSpec:= Stream.ReadByte;
        Template:= Stream.ReadStr;
        if length(Template)<constMinSearchCharQty then
          raise EBOBError.Create('������ ������ ������ ���� �� ����� '+
            IntToStr(constMinSearchCharQty)+'-� ��������.');
        TestCssStopException;
        prSearchWareNames;
      end else begin // ����� �� ���� ������/������
        TestCssStopException;
        idxTemplate:= Stream.ReadInt;
        prSearchWareBGCode;
      end;
      if (lstSearchWare.Count<1) then
        raise EBOBError.Create('�� ������ ������� "'+Template+'" ����� �� ������.');

      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      TestCssStopException;
      prSaveResultToStream;  // ������ ���������� � �����
    except
      on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
      on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
    end;
  finally
    prFree(lstSearchWare);
    Stream.Position:= 0;
  end;
end;
//=================================================== �������� �������-��������,
//============= ��������� ������ ������ �� �������, �����, ������, ������ ������
procedure prProductPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductPage'; // ��� ���������/�������
var UserId: integer;
    lstBrand: TStringList;  // ������ ������� (0-������� ������)
    lstGroup: TStringList;  // ������ ����� ������ (1-������� �������� ������)
    ArLinkSources: tas;
    empl: TEmplInfoItem;
    flUiK, flProduct: Boolean;
  //--------------------- ������������ ������ �� ������ ������� � ����� (������)
  procedure prClearBrandList;
  var i: integer;  // loop local var
      list: TStringList;
  begin
    try
      for i:= 0 to lstBrand.Count-1 do
        if Assigned(lstBrand.Objects[i]) then begin
          list:= TStringList(lstBrand.Objects[i]);
          prFree(List);  // ������������ ������ �����
        end;
    except
     on E: Exception do
       fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', E.Message, 'prClearBrandList');
    end;
    prFree(lstBrand);  // ������������ ������ �������
  end;
  //--------------------------
  function fnGetTreeGroupWare: integer;
  var i, idxBrand: integer;
      Ware: TWareInfo;
  begin
    Result:= 0;
    lstBrand:= fnCreateStringList(true, dupIgnore);
    if Cache.WareCacheUnLocked then begin
      for i:= 0 to Length(Cache.arWareInfo)-1 do try
        if not Cache.WareExist(i) then Continue;
        Ware:= Cache.GetWare(i);
        if Ware.IsArchive or not Ware.isWare then Continue;
//        if (Ware.PgrID = pgrDeliv) then Continue; // ���������� ��������
        if Ware.IsPrize then begin
          if not flUiK then Continue;
        end else begin
          if not flProduct or (ware.PgrID<1) or (Ware.ManagerID<>UserId) then Continue;
        end;
        idxBrand:= lstBrand.IndexOf(Ware.GrpName+'='+IntToStr(Ware.GrpID));
        if (idxBrand<0) then begin
          lstGroup:= fnCreateStringList(true, dupIgnore);
          idxBrand:= lstBrand.AddObject(Ware.GrpName+'='+IntToStr(Ware.GrpID), lstGroup);
        end else lstGroup:= TStringList(lstBrand.Objects[idxBrand]);
        if (idxBrand<0) then Continue;
        lstGroup.AddObject(Ware.PgrName, pointer(Ware.PgrID));
      except
        Result:= -1;
      end;
    end else Result:= 1;
  end;
  //-------------------------- ������ ������ ������� � ����� (������) � �����
  procedure prSaveResultToStream;
  var i, j: integer;  // loop local var
  begin
    Stream.WriteInt(lstBrand.Count);
    for i:= 0 to lstBrand.Count-1 do begin // ������ ������� � �����
      j:= StrToInt(copy(lstBrand[i], Length(lstBrand.Names[i])+2, MaxInt));
      Stream.WriteInt(j);
      Stream.WriteStr(lstBrand.Names[i]);
      if not Assigned(lstBrand.Objects[i]) then begin // ������ ������������� ������ �����
        Stream.WriteInt(0);
        Exit;
      end;
      with TStringList(lstBrand.Objects[i]) do begin // ������ ����� � �����
        Stream.WriteInt(Count);
        for j:= 0 to Count-1 do begin
          Stream.WriteInt(Integer(Objects[j]));
          Stream.WriteStr(Strings[j]);
        end;
      end; // with
    end; // for
  end;
  //-------------------------- ������ ������� ����� � �����
  procedure prSaveTasToStream(_arTas: Tas; Stream: TBOBMemoryStream; pSort: Boolean = False);
  var i, CountIdx: Integer;
      position: int64;
      lstSort: TStringList;
  begin
    CountIdx:= 0;
    Position:= Stream.Position;
    Stream.WriteInt(0);
    if pSort then begin
      lstSort:= fnCreateStringList(true, dupIgnore);
      try
        for i:= 0 to High(_arTas) do if (_arTas[i]<>'') then
          lstSort.AddObject(_arTas[i], pointer(i));
        for i:= 0 to lstSort.Count-1 do begin
          Stream.WriteInt(Integer(lstSort.Objects[i]));
          Stream.WriteStr(lstSort[i]);
        end;
        CountIdx:= lstSort.Count;
      finally
        prFree(lstSort);
      end;
    end else for i:= 0 to High(_arTas) do if (_arTas[i]<>'') then begin
      Stream.WriteInt(i);
      Stream.WriteStr(_arTas[i]);
      inc(CountIdx);
    end;
    Stream.Position:= position;
    Stream.WriteInt(CountIdx);
    Stream.Position:= Stream.Size;
  end;
  //--------------------------
begin
  Stream.Position:= 0;
  lstBrand:= nil;
  try
    try
      UserID:= Stream.ReadInt;
      prSetThLogParams(ThreadData, csProductPage, UserId);

      if not Cache.EmplExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotEmplExist));
      empl:= Cache.arEmplInfo[UserId];
      flUiK:= empl.UserRoleExists(rolUiK);
      flProduct:= empl.UserRoleExists(rolProduct);
      if not flProduct and not flUiK then
        raise EBOBError.Create(MessText(mtkNotRightExists));
      TestCssStopException;

      case fnGetTreeGroupWare of
        0: if (lstBrand.Count<1) then raise EBOBError.Create('������ ������� � ����� ������.');
        1: raise EBOBError.Create('������ ������������ ������ - ��� ������������.');
      else raise EBOBError.Create('�������������� ������ ������������ ������ ������� � �����');
      end;

      if (lstBrand.Count<1) then raise EBOBError.Create('������ ������� � ����� ������.');

      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      TestCssStopException;
      prSaveResultToStream;      // ������ ������ � �����
      TestCssStopException;
      ArLinkSources:= Cache.FDCA.GetArLinkSources;
      prSaveTasToStream(ArLinkSources,  Stream); // ������ ����������� ���������� � �����;
    except
      on E: EBOBError do begin
        Stream.Clear;
        Stream.WriteInt(aeCommonError);
        Stream.WriteStr(E.Message);
        fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', E.Message, '');
      end;
      on E: Exception do begin
        Stream.Clear;
        Stream.WriteInt(aeCommonError);
        Stream.WriteStr(MessText(mtkErrProcess));
        fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
      end;
    end;
  finally
    SetLength(ArLinkSources,0);
    if (lstBrand<>nil) then prClearBrandList;
    Stream.Position:= 0;
  end;
end;
//=========== (+ Web) ������������� ������ �������� ��������� Grossbee �� ������
procedure prGetFilteredGBGroupAttValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFilteredGBGroupAttValues'; // ��� ���������/�������
var UserID, FirmID, grpID, i, ii, pCount, j, jj, ind, exCount: Integer;
    s: String;
    att: TGBattribute;
    lstAtts, lst: TList;
    attCodes, valCodes: Tai;
    ware: TWareInfo;
    link: TLink;
    linkt, linkAtt: TTwoLink;
    flAvailable: Boolean;
    arWareLinks: array of TTwoLink; // ������� ����� ������ � ����������/���������� ������
    arResult: array of TLinks;      // ������������� ������ ������ �� �������� ���������
    arFinded: TBooleanDynArray;     // ����� ������� �������� ��������
begin
  Stream.Position:= 0;
  SetLength(attCodes, 0);
  SetLength(valCodes, 0);
  SetLength(arWareLinks, 0);
  SetLength(arFinded, 0);
  SetLength(arResult, 0);
  lstAtts:= nil;
  exCount:= 0;
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    grpID:= Stream.ReadInt;   // ��� ������ ���������
    pCount:= Stream.ReadInt;  // ���-�� ���������

    prSetThLogParams(ThreadData, csGetFilteredGBGroupAttValues, UserId, FirmID,
      'grpID='+IntToStr(grpID)+#13#10'pCount='+IntToStr(pCount));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    grpID:= grpID-cGBattDelta;
    if not Cache.GBAttributes.Groups.ItemExists(grpID) then
      raise EBOBError.Create(MessText(mtkNotFoundAttGr, IntToStr(grpID)));

    lstAtts:= Cache.GBAttributes.GetGBGroupAttsList(grpID);
    if (lstAtts.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

    SetLength(attCodes, pCount);
    SetLength(valCodes, pCount);
    for i:= 0 to pCount-1 do begin // ��������� ��������
      attCodes[i]:= Stream.ReadInt-cGBattDelta; // ��� ��������
      j:= Stream.ReadInt;
      if (j>0) then begin // �������� ������
        j:= j-cGBattDelta;
        Inc(exCount); // ���-�� �������� ��������
      end;
      valCodes[i]:= j;                          // ��� �������� (�.�. 0)
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if (exCount<1) then begin //---------- ���� ������ �� ������ - ������ ������
      Stream.WriteInt(lstAtts.Count);       // ���-�� ���������
      for i:= 0 to lstAtts.Count-1 do begin
        att:= lstAtts[i];
        Stream.WriteInt(att.ID+cGBattDelta);   // ��� �������� �� �������
        with att.Links.ListLinks do begin // ������ ������ �� �������� ��������
          Stream.WriteInt(Count);                              // ����������
          for ii:= 0 to Count-1 do begin
            Stream.WriteInt(GetLinkID(Items[ii])+cGBattDelta); // ��� �������� �� �������
            Stream.WriteStr(GetLinkName(Items[ii]));           // ���� ��������
          end;
        end; // with
      end; // for
      Exit;
    end;

    for i:= lstAtts.Count-1 downto 0 do begin // ��������� ������������ ������� ���������
      att:= lstAtts[i];
      if (fnInIntArray(att.ID, attCodes)<0) then lstAtts.Delete(i);
    end;
    if (lstAtts.Count<>pCount) then
      raise EBOBError.Create('������ ������������ ���������, �������� ��������');

    for i:= pCount-1 downto 0 do if (valCodes[i]<1) then begin // ������ ���������� ��������
      prDelItemFromArray(i, attCodes);
      prDelItemFromArray(i, valCodes);
    end;
    pCount:= Length(attCodes);
    SetLength(arFinded, pCount);

    j:= lstAtts.Count;
    SetLength(arWareLinks, j);
    SetLength(arResult, j); // ������ ������� �������� �� ���-�� ���������
    for i:= 0 to High(arResult) do arResult[i]:= TLinks.Create;
    //---------------------------- ���������� ������ ������� � ���������� ������
    with Cache.GBAttributes.GetGrp(grpID).Links.ListLinks do
      for j:= 0 to Count-1 do begin
        link:= Items[j];
        ware:= link.LinkPtr;
        for i:= 0 to High(arWareLinks) do arWareLinks[i]:= nil; // ������ ������� �����
        for i:= 0 to High(arFinded) do arFinded[i]:= False;     // ���������� �����

        for ii:= 0 to lstAtts.Count-1 do begin // ������� ����� ������ � ���������� ������
          att:= lstAtts[ii];
          jj:= att.ID;
          if ware.GBAttLinks.LinkExists(jj) then begin // ��������� ����������� ��������
            linkt:= ware.GBAttLinks[jj];
            ind:= fnInIntArray(jj, attCodes);
            if (ind>-1) then            // ���� ������� ��������� ��������
              arFinded[ind]:= (valCodes[ind]=linkt.LinkTwoID);
            arWareLinks[ii]:= linkt;
          end;
        end;

        for i:= 0 to High(arWareLinks) do begin
          linkt:= arWareLinks[i];
          if not Assigned(linkt) then Continue;
          att:= arWareLinks[i].LinkPtr;

          flAvailable:= True;
          for ii:= 0 to High(arFinded) do begin
            // �������� ��������� �������� �� ���������, ����� � ��� ������ ����� 1 ��������
            if (attCodes[ii]=att.ID) then Continue;
            flAvailable:= (flAvailable and arFinded[ii]);
          end;
          if not flAvailable then Continue; // �� �������� - ����������

          if arResult[i].LinkExists(linkt.LinkTwoID) then Continue;

          linkAtt:= att.Links[linkt.LinkTwoID];
          linkAtt:= TTwoLink.Create(att.SrcID, linkt.LinkPtrTwo, linkAtt.LinkPtrTwo);
          arResult[i].AddLinkItem(linkAtt);
        end;
      end; // for j:= 0 to lstWareLinks.Count-1
    //----------------------------
    for i:= 0 to High(arResult) do arResult[i].LinkSort(AttValLinksSortCompare);

    Stream.WriteInt(lstAtts.Count);             // ���-�� ���������
    for i:= 0 to lstAtts.Count-1 do begin
      att:= lstAtts[i];
      j:= att.ID+cGBattDelta;                   // ��� �������� �� �������
      Stream.WriteInt(j);
      lst:= arResult[i].ListLinks; // ������������� ������ ������ �� �������� ��������
      j:= lst.Count;
      Stream.WriteInt(j);                       // ���������� ��������
      for ii:= 0 to j-1 do begin
        jj:= GetLinkID(lst[ii])+cGBattDelta;    // ��� �������� �� �������
        Stream.WriteInt(jj);
        Stream.WriteStr(GetLinkName(lst[ii]));  // ���� ��������
      end;
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  finally
    prFree(lstAtts);
    SetLength(attCodes, 0);
    SetLength(valCodes, 0);
    SetLength(arWareLinks, 0);
    SetLength(arFinded, 0);
    for i:= 0 to High(arResult) do prFree(arResult[i]);
    SetLength(arResult, 0);
    Stream.Position:= 0;
  end;
end;
//===================================== C����� ��� �������� "motul.vladislav.ua"
//====================== �����, ��������, ������ ������/����������� �����������
procedure prMotulSitePage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMotulSitePage'; // ��� ���������/�������
var iCount, UserID, sPos, fsize, ListKind: integer;
    empl: TEmplInfoItem;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    ms: TMemoryStream;
    mess, spec: String;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  ms:= nil;
  mess:= '';
  iCount:= 0;
  try
//----------- ����� �� CGI ��� ����
    UserID:= Stream.ReadInt;
    ListKind:= Stream.ReadInt;  // ��� ������
        //  mspAllActs    - ������ ���� ����� (������� ������)
        //  mspPrLines    - ������ ��������� (������� ����������)
        //  mspResumeInfo - ��������� � ������ ������, ����������� ����������� (������� ������������)
        //  mspEnableActs - ������ ���������� ����� ��� �������� (������� ����������)

    mess:= 'ListKind='+IntToStr(ListKind); // �������� ������ ��� �����������
    spec:= IntToStr(mspResumeCode)+', '+IntToStr(mspInfoCode); // ���� ����.�����
    try
      if not Cache.EmplExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotEmplExist));

      empl:= Cache.arEmplInfo[UserID];
      if not empl.UserRoleExists(rolManageMotulSite) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, true);

      //------------ �������� � CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      sPos:= Stream.Position;
      Stream.WriteInt(0); // ����� ��� ���-��

      case ListKind of
//------------------------------------------ ������ ���� ����� (������� ������)
      mspAllActs:  begin
          mess:= mess+' (AllActs)'; // ������ ��� �����������
          IBS.SQL.Text:= 'select MACTCODE, MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT'+
            ', iif(exists(select * from MOTULACTSPRODLINES where MAPLACTION=MACTCODE), 1, 0) as plex'+
            ', iif(exists(select * from MOTULACTSCIPHERS where MACPACTION=MACTCODE), 1, 0) as chex'+
            ' from MOTULACTACTIONS where not MACTCODE in ('+spec+')'+  // ��������� ����.�����
            ' order by MACTCODE';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ �������� � CGI
            Stream.WriteInt(ibs.FieldByName('MACTCODE').AsInteger);    // ��� �����
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString); // ��������� �����
            Stream.WriteDouble(ibs.FieldByName('MACTFIRSTDATE').AsDateTime); // ���� ������
            Stream.WriteDouble(ibs.FieldByName('MACTLASTDATE').AsDateTime);  // ���� ���������
            Stream.WriteLongStr(ibs.FieldByName('MACTACTTEXT').AsString); // ����� �� MEMO
            Stream.WriteBool(ibs.FieldByName('plex').AsInteger=1); // ������� ������� ��������� ���������
            Stream.WriteBool(ibs.FieldByName('chex').AsInteger=1); // ������� ������� ��������� CIPHER-��
            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspAllActs
//-------------------- ������ ���������� ����� ��� �������� (������� ����������)
      mspEnableActs:  begin
          mess:= mess+' (EnableActs)'; // ������ ��� �����������
          IBS.SQL.Text:= 'select MACTCODE, MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT'+
            ' from MOTULACTACTIONS where not MACTCODE in ('+spec+')'+  // ��������� ����.�����
            '   and (MACTLASTDATE is null or MACTLASTDATE > current_timestamp)'+
            ' order by MACTCODE';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ �������� � CGI
            Stream.WriteInt(ibs.FieldByName('MACTCODE').AsInteger);          // ��� �����
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString);       // ��������� �����
            Stream.WriteDouble(ibs.FieldByName('MACTFIRSTDATE').AsDateTime); // ���� ������
            Stream.WriteDouble(ibs.FieldByName('MACTLASTDATE').AsDateTime);  // ���� ���������
            Stream.WriteLongStr(ibs.FieldByName('MACTACTTEXT').AsString);    // ����� �� MEMO

            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspEnableActs
//---------------------------------------- ������ ��������� (������� ����������)
      mspPrLines:  begin
          ms:= TMemoryStream.Create;
          mess:= mess+' (PrLines)'; // ������ ��� �����������
          IBS.SQL.Text:= 'select MAPLCODE, MAPLNAME, MAPLPICTURE,'+
            ' MAPLACTION, MACTACTTITLE from MOTULACTSPRODLINES'+
            ' left join MOTULACTACTIONS on MACTCODE=MAPLACTION'+
            ' order by MAPLNAME';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ �������� � CGI
            Stream.WriteInt(ibs.FieldByName('MAPLCODE').AsInteger); // ��� ��������
            Stream.WriteStr(ibs.FieldByName('MAPLNAME').AsString);  // ������������ ��������
            try
              ibs.FieldByName('MAPLPICTURE').SaveToStream(ms); // �������� �������� (png)
              fsize:= ms.Size;
              Stream.WriteInt(fsize);       // ������ ��������
              if (fsize>0) then begin
                ms.Position:= 0;
                Stream.CopyFrom(ms, fsize); // ��������
              end;
            finally
              ms.Clear;
            end;
            Stream.WriteInt(ibs.FieldByName('MAPLACTION').AsInteger);  // ��� ��������� �����
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString); // ��������� ��������� �����

            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspPrLines
//------------------------------------ ��������� � ������ (������� ������������)
      mspResumeInfo:  begin //---- ��� = mspResumeCode - ������
                            //---- ��� = mspInfoCode   - ����������� �����������
          mess:= mess+' (Resume/Info)'; // ������ ��� �����������
          IBS.SQL.Text:= 'select MACTCODE, MACTACTTITLE, MACTACTTEXT'+
            ' from MOTULACTACTIONS where MACTCODE in ('+spec+')'+  // ����.�����
            ' order by MACTCODE';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ �������� � CGI
            Stream.WriteInt(ibs.FieldByName('MACTCODE').AsInteger);       // ���
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString);    // ���������
            Stream.WriteLongStr(ibs.FieldByName('MACTACTTEXT').AsString); // ����� �� MEMO

            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspResumeInfo

        else raise EBOBError.Create('����������� ��� ������ '+IntToStr(ListKind));
      end; // case
      IBS.Close;
      if (iCount>0) then begin
        Stream.Position:= sPos;
        Stream.WriteInt(iCount);
      end;
    finally
      Stream.Position:= 0;
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
      prFree(ms);
      prSetThLogParams(ThreadData, csMotulSitePage, UserID, IsWe, mess);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
end;
//==================================== �������� �� �������� "motul.vladislav.ua"
procedure prMotulSiteManage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMotulSiteManage'; // ��� ���������/�������
var iCount, UserID, sPos, fsize, OpKind, pl, act, actOld: integer;
    empl: TEmplInfoItem;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    ms: TMemoryStream;
    mess, title, text, titleOld, textOld, sAct, sUser, s, spl: String;
    DateBeg, DateEnd, DateBegOld, DateEndOld: TDateTime;
    fl, flDBeg, flDEnd, flTit, flTxt, flSpecAct: Boolean;
begin
  Stream.Position:= 0;
  IBD:= nil;
  IBS:= nil;
  ms:= nil;
  mess:= '';
  act:= 0;
  pl:= 0;
  DateBeg:= 0;
  DateEnd:= 0;
  try
//----------- ����� �� CGI ��� ����
    UserID:= Stream.ReadInt;
    OpKind:= Stream.ReadInt;  // ��� ��������

        //  mspAddAct    - �������� �����      (������� ������)
        //  mspEditAct   - ������������� ����� (������� ������ � ������������)
        //  mspDelAct    - ������� �����       (������� ������)
        //  mspAddPLine  - �������� �������           (������� ����������)
        //  mspEditPLine - ������������� �������      (������� ����������) (��� �������)
        //  mspDelPLine  - ������� �������            (������� ����������)
        //  mspPictPLine - ��������� ������� �������� (������� ����������)

    mess:= 'OpKind='+IntToStr(OpKind); // �������� ������ ��� �����������
    sUser:= IntToStr(UserID);
    try
      if not Cache.EmplExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotEmplExist));

      empl:= Cache.arEmplInfo[UserID];
      if not empl.UserRoleExists(rolManageMotulSite) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead);

      case OpKind of
//--------------------------------------------------------------- �������� �����
      mspAddAct: begin
            //------------ ����� �� CGI
            title  := Stream.ReadStr;     // ��������� �����
            DateBeg:= Stream.ReadDouble;  // ���� ������
            DateEnd:= Stream.ReadDouble;  // ���� ���������
            text   := Stream.ReadLongStr; // ����� ��� MEMO

            //------------ ��������
            flDBeg:= (DateBeg=0);
            flDEnd:= (DateEnd=0);
            mess:= mess+' (AddAct) title='+title+
              #13#10'DateBeg='+fnIfStr(flDBeg, '0', FormatDateTime('', DateBeg))+
              ' DateEnd='+fnIfStr(flDEnd, '0', FormatDateTime('', DateEnd))+
              #13#10'text='+text; // ������ ��� �����������

            if (title='') then raise EBOBError.Create('������������ ��������� �����');
            if (text='')  then raise EBOBError.Create('������������ ����� �����');
            if flDBeg then raise EBOBError.Create('������������ ���� ������ �����');
            if flDEnd then raise EBOBError.Create('������������ ���� ��������� �����');

            //----------- ������ � ����
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'insert into MOTULACTACTIONS'+
              ' (MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT, MACTuser)'+
              ' values (:title, :dbeg, :dend, :text, '+sUser+') returning MACTCODE';
            ibs.ParamByName('title').AsString:= title;
            ibs.ParamByName('dbeg').AsDateTime:= DateBeg;
            ibs.ParamByName('dend').AsDateTime:= DateEnd;
            ibs.ParamByName('text').AsString:= text;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then raise EBOBError.Create(MessText(mtkErrAddRecord));
            act:= IBS.FieldByName('MACTCODE').AsInteger;
            ibs.Transaction.Commit;
          end; // mspAddAct
//---------------------------------------------------------- ������������� �����
      mspEditAct: begin //---------- ������ (act = mspResumeCode)
                        //---------- ����������� ����������� (act = mspInfoCode)
            //------------ ����� �� CGI
            act    := Stream.ReadInt;     // ��� �����
            title  := Stream.ReadStr;     // ��������� �����
            text   := Stream.ReadLongStr; // ����� ��� MEMO

            flSpecAct:= (act in [mspResumeCode, mspInfoCode]); // ����.����� - ���� �� ����������
            if not flSpecAct then begin
              DateBeg:= Stream.ReadDouble;  // ���� ������
              DateEnd:= Stream.ReadDouble;  // ���� ���������
            end;

            //------------ ��������
            sact:= IntToStr(act);
            flDBeg:= (DateBeg=0);
            flDEnd:= (DateEnd=0);
            case act of
              1: s:= 'EditResume'; // ������
              2: s:= 'EditInfo';   // ����������� �����������
              else s:= 'EditAct';  // ������� �����
            end;
            mess:= mess+' ('+s+') code='+sact+' title='+title+fnIfStr(act>2,
              #13#10'DateBeg='+fnIfStr(flDBeg, '0', FormatDateTime('', DateBeg))+
              ' DateEnd='+fnIfStr(flDEnd, '0', FormatDateTime('', DateEnd)), '')+
              #13#10'text='+text; // ������ ��� �����������

            if (act<1)   then raise EBOBError.Create('������������ ��� �����');
            if (title='') then raise EBOBError.Create('������������ ��������� �����');
            if (text='')  then raise EBOBError.Create('������������ ����� �����');
            if not flSpecAct then begin  // ������� �����
              if flDBeg then raise EBOBError.Create('������������ ���� ������ �����');
              if flDEnd then raise EBOBError.Create('������������ ���� ��������� �����');
            end;

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT'+
              ' from MOTULACTACTIONS where MACTCODE='+sact;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('�� ������� ����� � ����� '+sact);
            titleOld:= IBS.FieldByName('MACTACTTITLE').AsString;
            textOld:= IBS.FieldByName('MACTACTTEXT').AsString;
            if not flSpecAct then begin // ������� �����
              DateBegOld:= IBS.FieldByName('MACTFIRSTDATE').AsDateTime;
              DateEndOld:= IBS.FieldByName('MACTLASTDATE').AsDateTime;
            end;
            IBS.Close;

            flTit:= (titleOld<>title);
            flTxt:= (textOld<>text);
            fl:= not flTit and not flTxt;
            if not flSpecAct then begin // ������� �����
              flDBeg:= (DateBegOld<>DateBeg);
              flDEnd:= (DateEndOld<>DateEnd);
              fl:= fl and not flDBeg and not flDEnd;
            end else begin         // �����/����
              flDBeg:= False;
              flDEnd:= False;
            end;
            if fl then raise EBOBError.Create('��� ���������');

            //----------- ������ � ����
            s:= '';
            if flTit then s:= s+' MACTACTTITLE=:title';
            if flDBeg then s:= s+fnIfStr(s='', '', ', ')+'MACTFIRSTDATE=:dbeg';
            if flDEnd then s:= s+fnIfStr(s='', '', ', ')+'MACTLASTDATE=:dend';
            if flTxt then s:= s+fnIfStr(s='', '', ', ')+'MACTACTTEXT=:text';

            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'update MOTULACTACTIONS set '+s+', MACTuser='+sUser+
                           ' where MACTCODE='+sact;
            if flTit  then ibs.ParamByName('title').AsString := title;
            if flDBeg then ibs.ParamByName('dbeg').AsDateTime:= DateBeg;
            if flDEnd then ibs.ParamByName('dend').AsDateTime:= DateEnd;
            if flTxt  then ibs.ParamByName('text').AsString  := text;
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspEditAct
//---------------------------------------------------------------- ������� �����
      mspDelAct: begin
            //------------ ����� �� CGI
            act:= Stream.ReadInt;         // ��� �����

            //------------ ��������
            sact:= IntToStr(act);
            mess:= mess+' (DelAct) code='+sact;
            if (act<1) then raise EBOBError.Create('������������ ��� �����');
            if (act<3) then raise EBOBError.Create('��������� ��� ����� '+sact);

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select iif(exists(select *'+
              ' from MOTULACTSPRODLINES where MAPLACTION=MACTCODE), 1, 0) as plex,'+
              ' iif(exists(select * from MOTULACTSCIPHERS'+
              '   where MACPACTION=MACTCODE), 1, 0) as chex'+
              ' from MOTULACTACTIONS where MACTCODE='+sact;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('�� ������� ����� � ����� '+sact);
            if (ibs.FieldByName('plex').AsInteger=1) then
              raise EBOBError.Create('����� ������� � ���������');
            if (ibs.FieldByName('chex').AsInteger=1) then
              raise EBOBError.Create('����� ������� � ������������');
            IBS.Close;

            //----------- ������ � ����
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'delete from MOTULACTACTIONS where MACTCODE='+sact;
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspDelAct
//------------------------------------------------------------- �������� �������
      mspAddPLine: begin
            //------------ ����� �� CGI
            title:= Stream.ReadStr;       // ��������� ��������
            act  := Stream.ReadInt;       // ��� ��������� ����� > 0 ��� 0 (��� �����)
            fsize:= Stream.ReadInt;       // ������ ��������
            if (fsize>0) then begin
              ms:= TMemoryStream.Create;
              ms.CopyFrom(Stream, fsize); // ��������
              ms.Position:= 0;
            end;

            //------------ ��������
            sact:= IntToStr(act);
            mess:= mess+' (AddPLine) title='+title+ // ������ ��� �����������
                   ' act='+sact+' fsize='+IntToStr(fsize);

            if (title='') then raise EBOBError.Create('������������ ������������ ��������');
            if (fsize<1) and (act>0) then
              raise EBOBError.Create('������ ������ ����� �������� ��� �������');
            // �������� �������� (png) - ������������ � Base64, ������ mspPictLimit �� �� ���������
            // �������� ������� ������� - � webarm.cgi !!!
//            if (fsize>mspPictLimit*1000) then
//              raise EBOBError.Create('������ ������� �� ������ ��������� '+IntToStr(mspPictLimit)+' ��');

            spl:= AnsiUpperCase(StringReplace(title, ' ', '', [rfReplaceAll]));
            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MAPLCODE from MOTULACTSPRODLINES where MAPLcheckNAME=:nm';
            ibs.ParamByName('nm').AsString:= spl;
            IBS.ExecQuery;
            if not (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('�������� �������� `'+title+'`');
            IBS.Close;

            //----------- ������ � ����
            s:= '';
            spl:= '';
            if (act>0) then begin
              s:= s+', MAPLACTION';
              spl:= spl+', '+sAct;
            end;
            if (fsize>0) then begin
              s:= s+', MAPLPICTURE';
              spl:= spl+', :pict';
            end;
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'insert into MOTULACTSPRODLINES (MAPLNAME, MAPLuser'+
              s+') values (:title, '+sUser+spl+') returning MAPLCODE';
            ibs.ParamByName('title').AsString:= title;
            if (fsize>0) then ibs.ParamByName('pict').LoadFromStream(ms);
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then raise EBOBError.Create(MessText(mtkErrAddRecord));
            pl:= IBS.FieldByName('MAPLCODE').AsInteger;
            ibs.Transaction.Commit;
          end; // mspAddPLine
//------------------------------------------ ������������� ������� (��� �������)
      mspEditPLine: begin
            //------------ ����� �� CGI
            pl   := Stream.ReadInt;       // ��� ��������
            title:= Stream.ReadStr;       // ��������� ��������
            act  := Stream.ReadInt;       // ��� ��������� ����� > 0 ��� 0 (��� �����)

            //------------ ��������
            spl:= IntToStr(pl);
            sact:= IntToStr(act);
            mess:= mess+' (EditPLine) code='+spl+' title='+title+' act='+sact;

            if (pl<1) then raise EBOBError.Create('������������ ��� ��������');
            if (title='') then raise EBOBError.Create('������������ ������������ ��������');

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MAPLNAME, MAPLACTION, iif(MAPLPICTURE is null, 0, 1) pEx'+
                           fnIfStr(act>0, ', iif(exists(select * from MOTULACTACTIONS'+
                           ' where MACTCODE='+sact+'), 1, 0) as actex', '')+
                           ' from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('�� ������ ������� � ����� '+spl);
            titleOld:= IBS.FieldByName('MAPLNAME').AsString;
            actOld:= IBS.FieldByName('MAPLACTION').AsInteger;
            fl:= (actOld<>act);
            if fl and (act>0) and (IBS.FieldByName('actex').AsInteger<1) then
              raise EBOBError.Create('�� ������� ����� � ����� '+sact);
            if (IBS.FieldByName('pEx').AsInteger<1) and (act>0) then
              raise EBOBError.Create('������ ������ ����� �������� ��� �������');
            IBS.Close;
            flTit:= (titleOld<>title);
            if not flTit and not fl then raise EBOBError.Create('��� ���������');

            //----------- ������ � ����
            s:= '';
            if flTit then s:= s+' MAPLNAME=:title';
            if fl then
              s:= s+fnIfStr(s='', '', ', ')+'MAPLACTION='+fnifStr(act>0, sact, 'null');

            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'update MOTULACTSPRODLINES set '+s+', MAPLuser='+sUser+
                           ' where MAPLCODE='+spl;
            if flTit then ibs.ParamByName('title').AsString:= title;
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspEditPLine
//-------------------------------------------------------------- ������� �������
      mspDelPLine: begin
            //------------ ����� �� CGI
            pl:= Stream.ReadInt;          // ��� ��������

            //------------ ��������
            spl:= IntToStr(pl);
            mess:= mess+' (DelPLine) code='+spl; // ������ ��� �����������
            if (pl<1) then raise EBOBError.Create('������������ ��� ��������');

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select iif(exists(select * from MOTULACTSCIPHERS'+
                           ' where MACPPRODUCTLINE=MAPLCODE), 1, 0) as chex'+
                           ' from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('�� ������ ������� � ����� '+spl);
            if (ibs.FieldByName('chex').AsInteger=1) then
              raise EBOBError.Create('������� ������ � ������������');
            IBS.Close;

            //----------- ������ � ����
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'delete from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspDelPLine
//--------------------------------------------------- ��������� ������� ��������
      mspPictPLine: begin
            //------------ ����� �� CGI
            pl:= Stream.ReadInt;          // ��� ��������
            fsize:= Stream.ReadInt;       // ������ ��������
            if (fsize>0) then begin
              ms:= TMemoryStream.Create;
              ms.CopyFrom(Stream, fsize); // ��������
              ms.Position:= 0;
            end;

            //------------ ��������
            spl:= IntToStr(pl);
            mess:= mess+' (PictPLine) code='+spl+' fsize='+IntToStr(fsize);

            if (pl<1) then raise EBOBError.Create('������������ ��� ��������');
            if (fsize<1) then raise EBOBError.Create('��� �������');
            // �������� �������� (png) - ������������ � Base64, ������ mspPictLimit �� �� ���������
            // �������� ������� ������� - � webarm.cgi !!!
//            if (fsize>mspPictLimit*1000) then
//              raise EBOBError.Create('������ ������� �� ������ ��������� '+IntToStr(mspPictLimit)+' ��');

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MAPLCODE from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('�� ������ ������� � ����� '+spl);
            IBS.Close;

            //----------- ������ � ����
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'update MOTULACTSPRODLINES set MAPLPICTURE=:pict,'+
                           ' MAPLuser='+sUser+' where MAPLCODE='+spl;
            ibs.ParamByName('pict').LoadFromStream(ms);
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspPictPLine

        else raise EBOBError.Create('����������� ��� �������� '+IntToStr(OpKind));
      end; // case OpKind
//------------------------------------------------------------------ ����� � CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      case OpKind of
        mspAddAct  : Stream.WriteInt(act); // �������� ����� - ��� �����
        mspAddPLine: Stream.WriteInt(pl);  // �������� ������� - ��� ��������
      end;

    finally
      Stream.Position:= 0;
      prFreeIBSQL(IBS);
      cntsORD.SetFreeCnt(IBD);
      prFree(ms);
      prSetThLogParams(ThreadData, csMotulSiteManage, UserID, IsWe, mess);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
end;

end.
