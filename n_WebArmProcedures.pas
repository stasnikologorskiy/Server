unit n_WebArmProcedures; // процедуры для WebArm

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
procedure prProductAddOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData); // добавляет единичный оригинальный номер к товару
procedure prProductDelOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Удаление привязки оригинального номера к товару
procedure prLoadModelDataText(Stream: TBoBMemoryStream; ThreadData: TThreadData); // просмотр параметров модели
procedure prShowModelsWhereUsed(Stream: TBoBMemoryStream; ThreadData: TThreadData); //отображает список моделей, в которых применяется товар
procedure prProductGetOrigNumsAndWares(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Получение списка оригинальных номеров для товара с кодом источника
procedure prMarkOrNum(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Управление отметкой об ошибочной связи товара и ОЕ
procedure prShowCrossOE(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Получить оригинальные номера, общие для 2х товаров
procedure prShowEngineOptions(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Показать характеристики двигателя
procedure prGetTop10Model(Stream: TBoBMemoryStream; ThreadData: TThreadData); // "освежает" набор Top10 последних выбираемых моделей и возвращает данные для отображения строк
procedure prLoadEngines(Stream: TBoBMemoryStream; ThreadData: TThreadData); // получить список двигателей по производителю
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
procedure prMarkOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Управление отметкой об ошибочной связи товара c односторонним аналогом
procedure prAddOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Добавить односторонний аналог вручную
procedure prUiKPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prProductPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);

//------------  Получить списки Брендов Grossbee, TecDoc и список связей брендов
procedure prGetLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAddLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData); // добавить связку брендов ГроссБии и производителей ТекДок
procedure prDelLinkBrandsGBTD(Stream: TBoBMemoryStream; ThreadData: TThreadData); // удалить связку брендов ГроссБии и производителей ТекДок
procedure prAccountsGetFirmList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prAccountsReestrPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prSendWareDescrErrorMes(Stream: TBoBMemoryStream; ThreadData: TThreadData); // отправляет сообщение пользователя об ошибке
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

procedure prCheckEmplRights(cek: TCheckEmplKind; emplID: Integer;                       // Проверить права сотрудника
          var empl: TEmplInfoItem; var FiltCode: Integer); overload;
procedure prCheckEmplRights(cek: TCheckEmplKind; emplID, ForFirmID: Integer;
          var empl: TEmplInfoItem; var firm: TFirmInfo); overload;

//                       работа с клиентами
procedure prWebArmGetRegionalFirms(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // список контрагентов регионала
procedure prWebArmGetFirmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // список юзеров контрагента
procedure prWebArmResetUserPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData); // сброс пароля
procedure prWebArmSetFirmMainUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // назначить главного пользователя
procedure prUnblockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // разблокировка клиента

procedure prWebArmGetFirmAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // список счетов к/а для МП

//                       работа со счетами
//procedure prWebArmGetFirmInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // передать реквизиты к/а
procedure prWebArmShowAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // показать счет (если нет - создать новый)
procedure prWebArmShowFirmWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // показать остатки по товару и складам фирмы
procedure prWebArmEditAccountHeader(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // редактирование заголовка счета
procedure prWebArmEditAccountLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // добавление/редактирование/удаление строки счета
 function fnGetStrSummByDoubleCurr(sum: Double; MainCurr: Integer; AddCurr: Integer=cDefCurrency): String; // строка с суммой в 2-х валютах
procedure prWebArmGetFilteredAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // передать список счетов с учетом фильтра
procedure prWebArmMakeSecondAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // формирование счета на недостающие
procedure prWebArmMakeInvoiceFromAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData); // формирование накладной из счета
procedure prWebArmGetTransInvoicesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // список накладных передачи (счета WebArm)
procedure prWebArmGetTransInvoice(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // просмотр накладной передачи (счета WebArm)
procedure prWebArmAddWaresFromAccToTransInv(Stream: TBoBMemoryStream; ThreadData: TThreadData); // добавление товаров из счета в накладную передачи (счета WebArm)

//                   работа с заявками на регистрацию
procedure prWebArmGetOrdersToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // список заявок
procedure prWebArmAnnulateOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData); // аннулировать заявку
procedure prWebArmRegisterOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData); // принять заявку

//                       работа с регионами
procedure prWebArmGetRegionalZones(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // список регионов
procedure prWebArmInsertRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // добавление региона
procedure prWebArmDeleteRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // удаление региона
procedure prWebArmUpdateRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // изменение региона

//                                  Бренды
procedure prGetBrandsTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // (Web) Список брендов TecDoc

//                              Производители
procedure prGetManufacturerList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) Список производителей
procedure prManufacturerAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // Добавить производителя
procedure prManufacturerDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // Удалить производителя
procedure prManufacturerEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // Изменить производителя

//                             Модельный ряд
procedure prGetModelLineList(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // (+ Web) Список модельных рядов производителя
procedure prModelLineAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // Добавить модельный ряд
procedure prModelLineDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // Удалить модельный ряд
procedure prModelLineEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // изменить модельный ряд

//                                Модель
procedure prGetModelLineModels(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // (+ Web) Список моделей модельного ряда
procedure prGetModelTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // (+ Web) Дерево узлов модели
procedure prModelAddToModelLine(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Добавить модель в модельный ряд
procedure prModelDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);            // Удалить модель
procedure prModelEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);           // Изменить модель
procedure prModelSetVisible(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // Изменить видимость модели

//                                Дерево узлов
procedure prTNAGet(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // Дерево узлов
procedure prTNANodeAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // Добавить узел в дерево
procedure prTNANodeDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // Удалить узел из дерева
procedure prTNANodeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData); // редактировать узел в дереве

//                                Двигатель
procedure prGetEngineTree(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) Дерево узлов двигателя

//                               Товары, атрибуты
procedure prGetListAttrGroupNames(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // (+ Web) Список групп атрибутов
procedure prGetListGroupAttrs(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // (+ Web) Список атрибутов группы
procedure prGetWareInfoView(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // параметры товара для просмотра
procedure prGetCompareWaresInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // параметры товаров для сравнения
procedure prCommonGetRestsOfWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // вывод семафоров наличия товаров (Web & WebArm)
procedure prWebArmGetWaresDescrView(Stream: TBoBMemoryStream; ThreadData: TThreadData); // описания товаров для просмотра (счета WebArm)
procedure prWebarmGetDeliveries(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // список доставок как результат поиска (WebArm)
procedure prProductWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // Получение списка товара по условию, Бренд, Группа, строка поиска
procedure prGetWareTypesTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // дерево типов товаров (сортировка по наименованию)
procedure prGetFilteredGBGroupAttValues(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) Фильтрованные списки значений атрибутов Grossbee
procedure prGetWareSatellites(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // список сопутствующих товаров (Web & WebArm)

//                                Поиск, подбор
procedure prCommonGetWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // поиск товаров по оригин.номеру (Web & WebArm)  ???
// WebArm
procedure prCommonWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // поиск товаров (WebArm)
procedure prGetWareAnalogs(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // список аналогов (WebArm)
procedure prCommonSearchWaresByAttr(Stream: TBoBMemoryStream; ThreadData: TThreadData); // поиск товаров по значениям атрибутов (WebArm)
procedure prCommonGetNodeWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // список товаров по узлу (WebArm)
procedure prSearchWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // поиск товаров по оригин.номеру из Laximo (WebArm)
// Web
procedure prCommonWareSearch_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // поиск товаров (Web)
procedure prGetWareAnalogs_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // список аналогов (Web)
procedure prCommonSearchWaresByAttr_new(Stream: TBoBMemoryStream; ThreadData: TThreadData); // поиск товаров по значениям атрибутов (Web)
procedure prCommonGetNodeWares_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // список товаров по узлу (Web)
procedure prSearchWaresByOE_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // поиск товаров по оригин.номеру из Laximo (Web)
procedure prCommonGetNodeWares_Motul(Stream: TBoBMemoryStream; ThreadData: TThreadData); // список товаров Motul по узлам модели (Web)

//                          функции для доставок
procedure prgetTimeListSelfDelivery(Stream: TBoBMemoryStream; ThreadData: TThreadData);
procedure prGetContractDestPointsList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // список торговых точек контракта (Web&Webarm)
procedure prGetAvailableTimeTablesList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // список доступных расписаний по контракту (Web&Webarm)
procedure prGetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // просмотр параметров отгрузки счета
procedure prSetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // редактирование параметров отгрузки счета
procedure prGetDprtAvailableShipDates(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // список доступных дат отгрузки по складу (Web & Webarm)

//                               разное
procedure prSaveStrListWithIDToStream(const pLst: TStringList; Stream: TBoBMemoryStream);       // Запись TStringList с ID в Objects в поток
procedure prWebArmGetNotificationsParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // список уведомлений (WebArm)
 function fnChangePasswordWebarm(UserID: Integer; oldpass, newpass1, newpass2: string): string; // Меняется пароль пользователем

//**************************** импорт из TDT, отчеты ***************************
//procedure prTestFileExt(pFileExt: string; RepKind: integer);    // проверяем расширение файла
procedure prFormRepFileName(pFilePath: string; var fname: string; RepKind: integer; flSet: Boolean=False); // формируем имя файла отчета
procedure prFormRepMailParams(var Subj, ContentType: string; // параметры письма с отчетом
          var BodyMail: TStringList; RepKind: integer; flSet: Boolean=False);
procedure prGetAutoDataFromTDT(ReportKind, UserID: integer;  // поиск новых данных авто в TDT
          var BodyMail: TStringList; var pFileName, Subj, ContentType: string;
          ThreadData: TThreadData=nil; filter_data: String='');
procedure prSetAutoDataFromTDT(ReportKind, UserID: integer;  // загрузка / изменение данных авто из TDT
          var BodyMail: TStringList; var pFileName, Subj, ContentType: string; ThreadData: TThreadData=nil);
procedure prGetFirmClones(pUserID: Integer; pFileName: String; ThreadData: TThreadData=nil); // 53-stamp - переброска к/а Гроссби

procedure prMotulSitePage(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // Cписки для страницы "motul.vladislav.ua"
procedure prMotulSiteManage(Stream: TBoBMemoryStream; ThreadData: TThreadData); // Операции на странице "motul.vladislav.ua"

implementation
uses n_IBCntsPool, v_Functions, t_ImportChecking, s_WebArmProcedures;

//==============================================================================
procedure prWebArmAutenticate(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmAutenticate'; // имя процедуры/функции
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
        raise EBOBError.Create('Не заданы реквизиты аутентикации.');

      if (UserLogin<>'') then begin
        // сначала проверяем, есть ли такой логин в системе
        UserId:= Cache.GetEmplIDbyLogin(UserLogin);
        if (UserId<1) then raise EBOBError.Create('Не найден логин '+UserLogin);
        //если задан параметр логин, то предполагаем наличие и пароля
        if (UserPsw='') then raise EBOBError.Create('Пустой пароль');

        empl:= Cache.arEmplInfo[UserId];
        if (empl.USERPASSFORSERVER<>UserPsw) then raise EBOBError.Create('Неверный пароль');
        if (empl.RESETPASSWORD) then raise EBoBAutenticationError.Create(IntToStr(aeResetPassword));
ErrorPos:='0-2';
        sid:= IntToStr(UserID)+'|'+fnGetSessionID;
        s:= ', EMPLSESSIONID="'+sid+'"';
ErrorPos:='1-0';

      end else begin // if (UserLogin<>'')
        if (sid='') then
          raise EBOBError.Create('Ошибка авторизации. Пустой идентификатор сесcии.');

        UserId:= Cache.GetEmplIDBySession(sid);
        if (UserId<1) then
          raise EBOBError.Create('Ошибка авторизации. Идентификатор сесcии устарел или испорчен.');
        if (Copy(sid, 1, Pos('|', sid)-1)<>IntToStr(UserId)) then
          raise EBOBError.Create('Ошибка авторизации. Некорректный идентификатор сесcии.');

        empl:= Cache.arEmplInfo[UserId];
        if ((now-empl.LastActionTime)>Cache.GetConstItem(pcClientTimeOutWebArm).IntValue/24/60) then
          raise EBOBError.Create('Время действительности сессии истекло.'+
            ' Пройдите заново процедуру авторизации, используя логин и пароль.');
ErrorPos:='1-5';
      end; //if (UserLogin<>'') else

      if empl.Arhived then
        raise EBOBError.Create('Учетная запись заблокирована администратором GrossBee.');
      if empl.Blocked then
        raise EBOBError.Create('Учетная запись заблокирована администратором werbarm.');

//-------------------------------------- nk
if flDisableOut then begin
      flEnable:= not empl.DisableOut;
      if not flEnable then begin // список шаблонов внутренних IP через запятую (192.168.,172.20.)
        ss:= trim(Cache.GetConstItem(pcInnerIPshablons).StrValue);
        flEnable:= (ss=''); // шаблоны не заданы
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
        raise EBOBError.Create('Запрещен доступ к Webarm не из сети Компании.'+
          cSpecDelim+'Запрос на предоставление доступа отправляйте на '+
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
    Stream.WriteBool(Cache.GetEmplAllowRepImp(UserID)); // признак наличия разрешенных отчетов/импортов у сотрудника
ErrorPos:='2-7';
    Stream.WriteBool(Cache.WareCacheUnLocked);
ErrorPos:='2-8';
    Stream.WriteBool(Cache.GetEmplConstantsCount(UserID)>0);
ErrorPos:='2-9';
    Stream.WriteStr(Empl.EmplShortName);
ErrorPos:='2-10';
    Stream.WriteBool(Cache.GBAttributes.HasNewGroups); // признак наличия новых групп атрибутов
  except
    on E: EBoBAutenticationError do begin
      i:= StrToIntDef(E.Message, -1);
      Stream.Clear;
      if (i=aeResetPassword) then begin
          Stream.WriteInt(i);
          Stream.WriteInt(UserID);
      end else begin
        s:= 'Неизвестный код ошибки авторизации';
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
const nmProc = 'prShowWebArmUsers'; // имя процедуры/функции
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
    Stream.WriteInt(0); // место под кол-во логинов

    pos:= Stream.Position;
    Stream.WriteInt(0); // место под кол-во сотрудников
    iCount:= 0;
    lst:= TList.Create;
    for i:= 0 to High(Cache.arEmplInfo) do if Cache.EmplExist(i) then begin
      Empl:= Cache.arEmplInfo[i];
      if Empl.Arhived then Continue;
      Stream.WriteInt(i);
      Stream.WriteStr(Empl.EmplShortName);
      if (Empl.UserPassForServer<>'') then lst.Add(Empl); // собираем ссылки с логинами
      Inc(iCount);
    end;
    Stream.Position:= pos;
    Stream.WriteInt(iCount);
    Stream.Position:= Stream.Size;

    List:= Cache.GetFilialList(True); // сортированный список крат.наименований филиалов
    Stream.WriteStringList(list, true);

    Roles:= Cache.GetAllRoleCodes;
    iCount:= Length(Roles);
    Stream.WriteInt(iCount); // кол-во ролей
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
const nmProc = 'prAEWebArmUser'; // имя процедуры/функции
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
      raise EBOBError.Create('Не найден пользователь для редактирования.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    loglist:= TStringList.Create; // список занятых логинов Гроссби
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
        ' where uslsarchive="F" and usrlcode<>21 order by USLSUSERID'; // неархивные и роль <> "Архивные пользователи"
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
      Stream.WriteBool(empl.DisableOut); // запрет на работу с webarm с внешних IP
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
const nmProc = 'prSaveWebArmUsers'; // имя процедуры/функции
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
    flDisable:= Stream.ReadBool; // запрет на работу с webarm с внешних IP
//--------------------------------------

    prSetThLogParams(ThreadData, csSaveWebArmUsers, UserId);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    EmplUser:= Cache.arEmplInfo[UserId];
    if not EmplUser.UserRoleExists(rolManageUsers) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    DprtID:= StrToIntDef(sDprt, 0);
    if (DprtID<1) then raise EBOBError.Create('Неверный идентификатор филиала  - '+sDprt);
    if (not Cache.DprtExist(DprtID) or not Cache.arDprtInfo[DprtID].IsFilial) then
      raise EBOBError.Create('Задано неверное подразделение или подразделение не является филиалом.');

    if (EmplID>0) then begin
      if not Cache.EmplExist(EmplID) then
        raise EBOBError.Create('Не найдена запись для редактирования.');
//      aEmplCodeID:= 0;
      Empl:= Cache.arEmplInfo[EmplID];
      flGBLogin:= not AnsiSameText(aGBLogin, Empl.GBLogin);
      flGBLogin_O:= not AnsiSameText(aGBLogin_O, Empl.GBReportLogin);
      flDprt:= (DprtID<>Empl.EmplDprtID);
      flPassw:= not AnsiSameText(aPass, Empl.UserPassForServer);

    end else begin // новый
      aEmplCodeID:= StrToIntDef(sEmpl, 0);
      if (aEmplCodeID<1) then
        raise EBOBError.Create('Неверный идентификатор привязываемого сотрудника - '+sEmpl);
      if not Cache.EmplExist(aEmplCodeID) then
        raise EBOBError.Create('Не найдена привязываемая запись пользователя.');
      if not fnCheckOrderWebLogin(aLogin) then
  //      raise EBOBError.Create('Логин не соответствует принятым соглашениям.');
        raise EBOBError.Create('Некорректный логин - '+aLogin+'. '+
          MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
      Empl:= Cache.arEmplInfo[aEmplCodeID];
      flGBLogin:= (aGBLogin<>'');
      flGBLogin_O:= (aGBLogin_O<>'');
      flDprt:= True;
      flPassw:= True;
    end;
//      raise EBOBError.Create('Должен быть указан либо новый сотрудник для добавления либо старый для редактирования.');  // ???
    if not fnCheckOrderWebPassword(aPass) then
//      raise EBOBError.Create('Пароль не соответствует принятым соглашениям.');
      raise EBOBError.Create('Некорректный пароль. '+
        MessText(mtkNotValidPassw, IntToStr(Cache.CliPasswLength)));

//--------------------------------------
if not flDisableOut then
    flDisable:= Empl.DisableOut;
//--------------------------------------

    if flGBLogin and (aGBLogin<>'') then begin
      i:= Cache.GetEmplIDByGBLogin(aGBLogin);
      if (i>0) and (i<>Empl.ID) then
        raise EBOBError.Create('Такой логин GrossBee уже используется');
    end;
    if flGBLogin_O and (aGBLogin_O<>'') then begin
      i:= Cache.GetEmplIDByGBLogin(aGBLogin_O);
      if (i>0) and (i<>Empl.ID) then
        raise EBOBError.Create('Такой логин GrossBee для отчетов уже используется');
    end;

    if (flGBLogin and (aGBLogin<>'')) or (flGBLogin_O and (aGBLogin_O<>'')) then try
      gbIBD:= CntsGRB.GetFreeCnt(EmplUser.GBLogin, cDefPassword, cDefGBrole);
      GBIBSQL:= fnCreateNewIBSQL(gbIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      if (aGBLogin<>'') then begin
        GBIBSQL.SQL.Text:= 'Select USLSCODE from USERLIST'+
                           ' WHERE UPPERCASE(USLSUSERID)="'+UpperCase(aGBLogin)+'"';
        GBIBSQL.ExecQuery;
        if (GBIBSQL.BoF and GBIBSQL.EoF) then
          raise EBOBError.Create('Не найден логин GrossBee');
        GBID:= GBIBSQL.Fields[0].AsInteger;
        GBIBSQL.Close;
      end;
      if (aGBLogin_O<>'') then begin
        GBIBSQL.SQL.Text:= 'Select USLSCODE from USERLIST'+
                           ' WHERE UPPERCASE(USLSUSERID)="'+UpperCase(aGBLogin_O)+'"';
        GBIBSQL.ExecQuery;
        if (GBIBSQL.BoF and GBIBSQL.EoF) then
          raise EBOBError.Create('Не найден логин GrossBee для отчетов');
        GBID_o:= GBIBSQL.Fields[0].AsInteger;
        GBIBSQL.Close;
      end;
    finally
      prFreeIBSQL(GBIBSQL);
      CntsGRB.SetFreeCnt(gbIBD, false);
    end;

    s:= '';
    ss:= '';
    if (EmplID<1) then begin // новый
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

      if (fnInIntArray(rolCustomerService, NewRoles)>-1) then // СП - добавить ЦОК
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
const nmProc = 'prAccountsReestrPage'; // имя процедуры/функции
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

    if CheckNotValidUser(UserId, isWe, s) then raise EBOBError.Create(s); // проверка юзера

    Empl:= Cache.arEmplInfo[UserId];
    if not Empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    prSaveEmplStoresChoiceList(Stream, UserId, true);  // запись в Stream списка видимых сотруднику складов(+путей) для выбора
    prSaveEmplFirmsChoiceList(Stream, UserId);

    //---------------------------------------------- передаем все валюты
    LineCount:= 0;       // счетчик
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  место под кол-во валют
    for k:= 0 to Cache.Currencies.ItemsList.Count-1 do begin
      curr:= Cache.Currencies.ItemsList[k];
      if not curr.Arhived and (curr.Name<>'') then begin
        Stream.WriteInt(curr.ID);   // код валюты
        Stream.WriteStr(curr.Name); // наименование валюты
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
const nmProc = 'prAccountsGetFirmList'; // имя процедуры/функции
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
    Stream.WriteInt(0); // место под кол-во фирм
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
//======================= отображает список моделей, в которых применяется товар
procedure prShowModelsWhereUsed(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowModelsWhereUsed'; // имя процедуры/функции
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
      #13#10'MFAID='+IntToStr(MFAID)); // логирование

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    sysID:= WhatShow;
    if not CheckTypeSys(sysID) then
      raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(sysID)));

    List:= Cache.arWareInfo[WareID].GetSysModels(sysID, MFAID, True);
    case sysID of
      constIsMoto: s:='мото';
      constIsAuto: s:='легк.авто';
      constIsCV  : s:='груз.авто';
      constIsAx  : s:='осей';
    end;
    if (List.Count<1) then raise EBOBError.Create('К этому товару не привязаны модели '+s+'.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    //----------------------------- если много - формируем список производителей
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

    if flSaveModels then begin //------------------------------- передаем модели
      lst:= Cache.GetWareModelUsesAndTextsView(WareID, List); // условия применимости
      Stream.WriteInt(List.Count); // кол-во моделей
      for i:= 0 to List.Count-1 do begin
        Model:= TModelAuto(List[i]);
        mps:= Model.Params;
        Stream.WriteInt(Model.ID);
        Stream.WriteInt(Model.SubCode);
        Stream.WriteInt(Model.ModelLineID);
        Stream.WriteInt(Model.ModelMfauID);
        Stream.WriteStr(Lst[i]);               // условия применимости
        Stream.WriteStr(Model.ModelMfauName);
        Stream.WriteStr(Model.ModelLineName);
        Stream.WriteStr(Model.Name);
        Stream.WriteInt(mps.pYStart); // Год начала выпуска
        Stream.WriteInt(mps.pMStart); // Месяц начала выпуска
        Stream.WriteInt(mps.pYEnd);   // Год окончания выпуска
        Stream.WriteInt(mps.pMEnd);   // Месяц окончания выпуска

        case sysID of
          constIsMoto, constIsAuto: begin
            Stream.WriteInt(mps.pHP);              // лс
            Stream.WriteStr(Model.MarksCommaText); // двигатели
          end;
          constIsCV: begin
            Stream.WriteStr(mps.cvHPaxLOout);      // лс от-до
            s:= mps.cvTonnOut;                     // тоннаж
            if (s<>'') then s:=s+' т';
            Stream.WriteStr(s);
            Stream.WriteStr(Model.MarksCommaText); // двигатели
          end;
          constIsAx: begin
            s:= mps.cvHPaxLOout;
            if (s<>'') then s:=s+' кг';
            Stream.WriteStr(s);                    // Нагрузка на ось [кг] от-до
            if (mps.pDriveID<1) then s:= ''
            else s:= Cache.FDCA.TypesInfoModel.InfoItems[mps.pDriveID].Name;
            Stream.WriteStr(s);                    // Тип оси
          end;
        end; // case
      end;

    end else begin  //--------------------------- передаем список производителей
      Manufs.Sort(@SortCompareManufNamesForTwoCodes);
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteInt(-Manufs.Count);// кол-во производителей
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
const nmProc = 'prManageBrands'; // имя процедуры/функции
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
const nmProc = 'prTNAManagePage'; // имя процедуры/функции
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
const nmProc = 'prGetFilialList'; // имя процедуры/функции
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
const nmProc = 'prAutoModelInfoLists'; // имя процедуры/функции
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
const nmProc = 'prLoadModelData'; // имя процедуры/функции
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

    if not Cache.FDCA.Models.ModelExists(i) then raise EBOBError.Create('Не найдена заданная модель');
    Model:= Cache.FDCA.Models.GetModel(i);

    Stream.WriteInt(Model.ID);                // Код модели
    Stream.WriteStr(Model.Name);              // Название модели
    Stream.WriteBool(Model.IsVisible);        // Видимость модель
    Stream.WriteBool(Model.IsTop);            // Топ модель
    Stream.WriteInt(Model.Params.pYStart);            // Год начала выпуска
    Stream.WriteInt(Model.Params.pMStart);            // Месяц начала выпуска
    Stream.WriteInt(Model.Params.pYEnd);              // Год окончания выпуска
    Stream.WriteInt(Model.Params.pMEnd);              // Месяц окончания выпуска

    Stream.WriteInt(Model.Params.pKW);                // Мощность кВт
    Stream.WriteInt(Model.Params.pHP);                // Мощность ЛС
    Stream.WriteInt(Model.Params.pCCM);               // Тех. обьем куб.см.
    Stream.WriteInt(Model.Params.pCylinders);         // Количество цилиндров
    Stream.WriteInt(Model.Params.pValves);            // Количество клапанов на одну камеру сгорания
    Stream.WriteInt(Model.Params.pBodyID);            // Код, тип кузова
    Stream.WriteInt(Model.Params.pDriveID);           // Код, тип привода
    Stream.WriteInt(Model.Params.pEngTypeID);         // Код, тип двигателя
    Stream.WriteInt(Model.Params.pFuelID);            // Код, тип топлива
    Stream.WriteInt(Model.Params.pFuelSupID);         // Код, система впрыска
    Stream.WriteInt(Model.Params.pBrakeID);           // Код, тип тормозной системы
    Stream.WriteInt(Model.Params.pBrakeSysID);        // Код, тип тормозная система
    Stream.WriteInt(Model.Params.pCatalID);           // Код, тип катализатора
    Stream.WriteInt(Model.Params.pTransID);           // Код, тип коробки передач
    Stream.WriteInt(Model.ModelOrderNum);             // Порядковый номер
    Stream.WriteStr(Model.MarksCommaText);            // маркировки двигателей

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(list);
end;
//=================================================== просмотр параметров модели
procedure prLoadModelDataText(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLoadModelDataText'; // имя процедуры/функции
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

    if (FirmID<>isWe) then begin                               // проверки Web
      if not Cache.ClientExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotClientExist));
      if not Cache.FirmExist(FirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
      if Cache.arClientInfo[UserID].FirmID<>FirmID then
        raise EBOBError.Create(MessText(mtkNotClientOfFirm));
    end else                                                  // проверки WebArm
      if not Cache.EmplExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotEmplExist));
ErrorPos:='05';
    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create('Не найдена заданная модель');

    Model:= Cache.FDCA.Models.GetModel(ModelID);
    sysID:= Model.TypeSys;
    mps:= Model.Params;
    tim:= Cache.FDCA.TypesInfoModel;
ErrorPos:='10';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    iCount:= 0;
    iPos:= Stream.Position;
    Stream.WriteInt(iCount); // место под кол-во пар: параметр - значение

    Stream.WriteStr('Наименование модели:');
    Stream.WriteStr(Model.Name);
    inc(iCount);

    if (mps.pYStart>0) then begin
      s:= IntToStr(mps.pYStart);
      if (mps.pMStart>0) then s:= fnMakeAddCharStr(IntToStr(mps.pMStart), 2, '0')+'.'+s;
      Stream.WriteStr('Начало выпуска:');
      Stream.WriteStr(s);
      inc(iCount);
    end;
    if (mps.pYEnd>0) then begin
      s:= IntToStr(mps.pYEnd);
      if (mps.pMEnd>0) then s:= fnMakeAddCharStr(IntToStr(mps.pMEnd), 2, '0')+'.'+s;
      Stream.WriteStr('Окончание выпуска:');
      Stream.WriteStr(s);
      inc(iCount);
    end;
ErrorPos:='15';
    case sysID of
      constIsAuto, constIsMoto: begin //----------------------------- auto, moto
        if (mps.pBodyID>0) then begin   // Тип кузова
          Stream.WriteStr(tim.GetItemTypeName(mps.pBodyID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBodyID].Name);
          inc(iCount);
        end;
        if (mps.pDriveID>0) then begin // Тип привода
          Stream.WriteStr(tim.GetItemTypeName(mps.pDriveID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pDriveID].Name);
          inc(iCount);
        end;
        if (mps.pKW>0) then begin // Мощность [кВт]
          Stream.WriteStr(tim.GetTypeName(cvtKW)+':');
          Stream.WriteStr(IntToStr(mps.pKW));
          inc(iCount);
        end;
        if (mps.pHP>0) then begin // Мощность [лс]
          Stream.WriteStr(tim.GetTypeName(cvtHP)+':');
          Stream.WriteStr(IntToStr(mps.pHP));
          inc(iCount);
        end;
        if (mps.pCCM>0) then begin
          Stream.WriteStr('Тех.обьем [куб.см]:');
          Stream.WriteStr(IntToStr(mps.pCCM));
          inc(iCount);
        end;
        if (mps.pValves>0) then begin
          Stream.WriteStr('Кол-во клапанов на камеру сгорания:');
          Stream.WriteStr(IntToStr(mps.pValves));
          inc(iCount);
        end;
        if (mps.pCylinders>0) then begin
          Stream.WriteStr('Количество цилиндров:');
          Stream.WriteStr(IntToStr(mps.pCylinders));
          inc(iCount);
        end;
        if (mps.pEngTypeID>0) then begin // Тип двигателя
          Stream.WriteStr(tim.GetItemTypeName(mps.pEngTypeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pEngTypeID].Name);
          inc(iCount);
        end;
        if (mps.pFuelID>0) then begin // Тип топлива
          Stream.WriteStr(tim.GetItemTypeName(mps.pFuelID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pFuelID].Name);
          inc(iCount);
        end;
        if (mps.pCatalID>0) then begin // Тип катализатора
          Stream.WriteStr(tim.GetItemTypeName(mps.pCatalID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pCatalID].Name);
          inc(iCount);
        end;
        if (mps.pFuelSupID>0) then begin // Система впрыска
          Stream.WriteStr(tim.GetItemTypeName(mps.pFuelSupID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pFuelSupID].Name);
          inc(iCount);
        end;
        if (mps.pBrakeID>0) then begin // Тип тормозной системы
          Stream.WriteStr(tim.GetItemTypeName(mps.pBrakeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBrakeID].Name);
          inc(iCount);
        end;
        if (mps.pBrakeSysID>0) then begin // Тормозная система
          Stream.WriteStr(tim.GetItemTypeName(mps.pBrakeSysID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBrakeSysID].Name);
          inc(iCount);
        end;
        if (mps.pTransID>0) then begin // Вид коробки передач
          Stream.WriteStr(tim.GetItemTypeName(mps.pTransID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pTransID].Name);
          inc(iCount);
        end;
        s:= Model.MarksCommaText;
        if (s<>'') then begin
          Stream.WriteStr('Двигатель:');
          Stream.WriteStr(s);
          inc(iCount);
        end;
      end; // constIsAuto, constIsMoto

      constIsCV: begin //--------------------------------------------- грузовики
        if (mps.pValves>0) then begin
          Stream.WriteStr('Тоннаж [т]:');
          Stream.WriteStr(mps.cvTonnOut);
          inc(iCount);
        end;
        if (mps.pBodyID>0) then begin // Конструкция
          Stream.WriteStr(tim.GetItemTypeName(mps.pBodyID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBodyID].Name);
          inc(iCount);
        end;
        if (mps.pDriveID>0) then begin // Конфигурация оси
          Stream.WriteStr(tim.GetItemTypeName(mps.pDriveID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pDriveID].Name);
          inc(iCount);
        end;
        if (mps.cvHPaxLO<>'') then begin // Мощность [лс]
          Stream.WriteStr(tim.GetTypeName(cvtHP)+':');
          Stream.WriteStr(mps.cvHPaxLOout);
          inc(iCount);
        end;
        if (mps.cvKWaxDI<>'') then begin // Мощность [кВт]
          Stream.WriteStr(tim.GetTypeName(cvtKW)+':');
          Stream.WriteStr(mps.cvKWaxDIOut);
          inc(iCount);
        end;
        if (mps.pCCM>0) then begin
          Stream.WriteStr('Тех.обьем [куб.см]:');
          Stream.WriteStr(IntToStr(mps.pCCM));
          inc(iCount);
        end;
        if (mps.cvSUAxBR<>'') then begin   // Подвеска/амортизация
          Stream.WriteStr(tim.GetTypeName(cvtSusp)+':');
          Stream.WriteStr(mps.cvSUAxBRout);
          inc(iCount);
        end;
        if (mps.cvWheels<>'') then begin // Колесная база [поз.осей]/[мм]
          Stream.WriteStr(tim.GetTypeName(cvtWheel)+':');
          Stream.WriteStr(mps.cvWheelsOut);
          inc(iCount);
        end;
        if (mps.pEngTypeID>0) then begin // Тип двигателя
          Stream.WriteStr(tim.GetItemTypeName(mps.pEngTypeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pEngTypeID].Name);
          inc(iCount);
        end;
        s:= Model.MarksCommaText;
        if (s<>'') then begin
          Stream.WriteStr('Двигатель:');
          Stream.WriteStr(s);
          inc(iCount);
        end;
        if (mps.cvIDaxBT<>'') then begin // ID производителя
          Stream.WriteStr(tim.GetTypeName(cvtIDs)+':');
          Stream.WriteStr(mps.cvIDaxBTOut);
          inc(iCount);
        end;
        if (mps.cvSecTypes<>'') then begin // Второстепенный тип
          Stream.WriteStr(tim.GetTypeName(cvtSecTyp)+':');
          Stream.WriteStr(mps.cvSecTypOut);
          inc(iCount);
        end;
        if (mps.cvCabs<>'') then begin // Кабина
          Stream.WriteStr(tim.GetTypeName(cvtCabs)+':');
          Stream.WriteStr(mps.cvCabsOut);
          inc(iCount);
        end;
        if (mps.cvAxles<>'') then begin // Ось
          Stream.WriteStr('Ось [поз.оси]/[тип]:');
          Stream.WriteStr(mps.cvAxlesOut);
          inc(iCount);
        end;
      end; // constIsCV

      constIsAx: begin //--------------------------------------------------- оси
        if (mps.cvHPaxLO<>'') then begin // Нагрузка на ось [кг]
          Stream.WriteStr(tim.GetTypeName(axtLoad)+':');
          Stream.WriteStr(mps.cvHPaxLOout);
          inc(iCount);
        end;
        if (mps.pDriveID>0) then begin   // Тип оси
          Stream.WriteStr(tim.GetItemTypeName(mps.pDriveID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pDriveID].Name);
          inc(iCount);
        end;
        if (mps.pEngTypeID>0) then begin // Исполнение оси
          Stream.WriteStr(tim.GetItemTypeName(mps.pEngTypeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pEngTypeID].Name);
          inc(iCount);
        end;
        if (mps.pBodyID>0) then begin    // Балка моста
          Stream.WriteStr(tim.GetItemTypeName(mps.pBodyID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBodyID].Name);
          inc(iCount);
        end;
        if (mps.pFuelID>0) then begin    // Колесное крепление
          Stream.WriteStr(tim.GetItemTypeName(mps.pFuelID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pFuelID].Name);
          inc(iCount);
        end;
        if (mps.cvKWaxDI<>'') then begin // Дистанция[мм]
          Stream.WriteStr(tim.GetTypeName(axtDist)+':');
          Stream.WriteStr(mps.cvKWaxDIout);
          inc(iCount);
        end;
        if (mps.pCCM>0) then begin
          Stream.WriteStr('Ширина колеи [мм]:');
          Stream.WriteStr(IntToStr(mps.pCCM));
          inc(iCount);
        end;
        if (mps.pBrakeID>0) then begin   // Тип тормозной системы
          Stream.WriteStr(tim.GetItemTypeName(mps.pBrakeID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pBrakeID].Name);
          inc(iCount);
        end;
        if (mps.pTransID>0) then begin   // Hub system
          Stream.WriteStr(tim.GetItemTypeName(mps.pTransID)+':');
          Stream.WriteStr(tim.InfoItems[mps.pTransID].Name);
          inc(iCount);
        end;
        if (mps.cvSUAxBR<>'') then begin   // Размеры тормоза
          Stream.WriteStr(tim.GetTypeName(axtBrSize)+':');
          Stream.WriteStr(mps.cvSUAxBRout);
          inc(iCount);
        end;
        if (mps.cvIDaxBT<>'') then begin    // Тип модели
          Stream.WriteStr(tim.GetTypeName(axtBoType)+':');
          Stream.WriteStr(mps.cvIDaxBTOut);
          inc(iCount);
        end;
      end; // constIsAx
    end; // case

ErrorPos:='25';
    if (iCount>0) then begin
      Stream.Position:= iPos;
      Stream.WriteInt(iCount); // кол-во пар: параметр - значение
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'ErrorPos='+ErrorPos, False);
  end;
  Stream.Position:= 0;
end;
//================================== отправляет сообщение пользователя об ошибке
procedure prSendWareDescrErrorMes(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSendWareDescrErrorMes'; // имя процедуры/функции
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
                                                    // логирование
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
const nmProc = 'prImportPage'; // имя процедуры/функции
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
    // проверяем наличие разрешенных отчетов/импортов у сотрудника
    if not Cache.GetEmplAllowRepImp(UserID) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    email:= Cache.arEmplInfo[UserID].Mail;
    if (email='') then
      s:= 'Ваш e-mail не указан в справочнике сотрудников Grossbee.'
    else if not fnCheckEmail(email) then
      s:= 'Ваш e-mail "'+email+'" в справочнике сотрудников Grossbee некорректный.';
    if (s<>'') then
      raise EBOBError.Create('Отчеты и результаты импорта отправляются на e-mail сотрудника.'+
        cSpecDelim+s+cSpecDelim+'Обратитесь в отдел УиК непосредственно или через руководителя.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    list:= Cache.GetEmplAllowRepOrImpList(UserID); // список отчетов
    Stream.WriteStringList(list, true);
    list.Clear;
    list:= Cache.GetEmplAllowRepOrImpList(UserID, False); // список импортов
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
const nmProc = 'prCheckWareManager'; // имя процедуры/функции
var UserId, WareId: integer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    WareId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csCheckWareManager, UserId, 0, 'Ware='+IntToStr(WareId)); // логирование

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create('Не найден заданный пользователь');
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create('Не найден заданный товар');

    if not Cache.arEmplInfo[UserID].UserRoleExists(rolUiK) and
      (Cache.GetWare(WareID).ManagerID<>UserID) then
      raise EBOBError.Create('У Вас нет прав на редактирование этого товара');

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
const nmProc = 'prModifyLink3'; // имя процедуры/функции
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
      IntToStr(ResCode)+#13#10'NodeId='+IntToStr(NodeId)+#13#10'Model='+IntToStr(ModelId)); // логирование

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create('Не найден заданный пользователь');

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create('Не найден заданный товар');

    if ((Cache.FDCA.GetModelTypeSys(ModelID)=constIsMoto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolTNAManageMoto))
      or ((Cache.FDCA.GetModelTypeSys(ModelID)=constIsAuto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolTNAManageAuto))
      or ((Cache.FDCA.GetModelTypeSys(ModelID)=constIsCV) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolTNAManageCV)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if (ResCode<>resDeleted) and (ResCode<>resAdded) then
      raise EBOBError.Create('Неопознанный код операции - '+IntToStr(ResCode));

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
//========================================= просмотр порций условий к 3-й связке
procedure prShowConditionPortions(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowConditionPortions'; // имя процедуры/функции
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
      raise EBOBError.Create('Не найдена заданная модель');

    Model:= Cache.FDCA.Models.GetModel(ModelId);
    SysID:= Model.TypeSys;
    if ((SysID=constIsAuto) and not flManagAuto)
      or ((SysID=constIsMoto) and not flManagMoto)
//      or ((SysID=constIsCV) and not flManagCV)
      then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    with Cache.FDCA.AutoTreeNodesSys[SysID] do begin
      if not NodeExists(NodeId) then raise EBOBError.Create('Неверно указан узел');
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
const nmProc = 'prMarkPortions'; // имя процедуры/функции
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
      raise EBOBError.Create('Не найдена заданная модель');

    if (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageAuto)
      and not Cache.FDCA.AutoTreeNodesSys[constIsAuto].NodeExists(NodeId))
      or (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageMoto)
     and not Cache.FDCA.AutoTreeNodesSys[constIsMoto].NodeExists(NodeId))
//     or (Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageCV)
//      and not Cache.FDCA.AutoTreeNodesSys[constIsCV].NodeExists(NodeId))
      then
      raise EBOBError.Create('Неверно указан узел');

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    if ((Cache.FDCA.Models[ModelID].TypeSys=constIsAuto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageAuto))
      or ((Cache.FDCA.Models[ModelID].TypeSys=constIsMoto) and
      not Cache.arEmplInfo[UserId].UserRoleExists(rolModelManageMoto)) then begin
      raise EBOBError.Create(MessText(mtkNotRightExists));
    end;

    if (Mark<>'wrong') and (Mark<>'right') and (Mark<>'del') then
      raise EBOBError.Create('Неправильный маркер связки - '+Mark);

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
const nmProc = 'prGetBrandsGB'; // имя процедуры/функции
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
//======================= централизованно возвращает товары по заданному условию
procedure prGetWareList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareList'; // имя процедуры/функции
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
      raise EBOBError.Create('Неизвестный тип списка - '+IntToStr(ListType));

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
//      else raise EBOBError.Create('Неизвестный тип списка - '+IntToStr(ListType));
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
      // в Webarm не передается кол-во систем учета !!!
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
//============================== добавляет единичный оригинальный номер к товару
procedure prProductAddOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductAddOrigNum'; // имя процедуры/функции
var UserId, WareID, ResCode, OrigId, SrcID, MfAuID: integer;
    OrigNum, MsgStr: string;
begin
  Stream.Position:= 0;
  OrigId:= 0;
  try
    UserID      := Stream.ReadInt;
    WareID      := Stream.ReadInt;   // Код товара
    SrcID:= soHand;           // Код источника данных
    MfAuID      := Stream.ReadInt;   // Код производителя авто
    OrigNum     := Stream.ReadStr;   // Оригинальный номер

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
        raise EBOBError.Create('Привязка данного оригинального номера уже существует.');
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
//============================== Удаление привязки оригинального номера к товару
procedure prProductDelOrigNum(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductDelOrigNum'; // имя процедуры/функции
var UserId, WareID, ResCode, OrigId, SrcID, MfAuID: integer;
    OrigNum, MsgStr: string;
begin
  Stream.Position:= 0;
  OrigId:= 0;
  SrcID:= soHand;
  MfAuID:= 0;
  try
    UserID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;   // Код товара
    OrigId:= Stream.ReadInt;   // Код оригинального номера

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
        raise EBOBError.Create('Не удалось удалить оригинальный номер - '+MsgStr);
      end;
      resDoNothing: begin
        raise EBOBError.Create('Привязка данного оригинального номера не существует.');
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
//----- Поиск артикулов TecDoc, соответствующих товару Grossbee по имени(группе)   ???
function SearchWareGBInTecDoc(pWareID: Integer; ThreadData: TThreadData): TStringList;
const nmProc='SearchWareGBInTecDocExtended';
var s, s1: String;
    lstWares, lstAddon: TStringList;
    i, j, Count: Integer;
    Ware: TWareInfo;
    IBS: TIBSQL;
    IBD: TIBDatabase;
  //-- Получение наименование товара с отбошеным префиксом Бренда и окончания с P
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
//============= Получить списки Брендов Grossbee, TecDoc и список связей брендов
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
    Stream.WriteInt(0); // место под кол-во

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
      raise EBOBError.Create('Не найден бренд с кодом '+IntToStr(idBrandGB));

    ResCode:= resAdded;
    ErrText:= Cache.CheckWareBrandReplace(idBrandGB, idBrandTD, UserID, ResCode);
    case ResCode of
      resDoNothing: raise EBOBError.Create('Эти бренды уже связаны');
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
      raise EBOBError.Create('Не найден бренд с кодом '+IntToStr(idBrandGB));

    ResCode:= resDeleted;
    ErrText:= Cache.CheckWareBrandReplace(idBrandGB, idBrandTD, UserID, ResCode);
    case ResCode of
      resDoNothing: raise EBOBError.Create('Такая связка брендов не найдена');
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
//=========== Получение списка оригинальных номеров для товара с кодом источника
procedure prProductGetOrigNumsAndWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductGetOrigNumsAndWares'; // имя процедуры/функции
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
        Stream.WriteInt(OrNum.ID);           // Код оригинального номера
        Stream.WriteInt(OrNum.MfAutoID);     // код производителя авто
        Stream.WriteByte(IBS.FieldByName('ORLKSOURCECODE').AsInteger); // Код источника связи
        Stream.WriteStr(OrNum.OriginalNum);  // оригинальный номер
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
//=========================== Управление отметкой об ошибочной связи товара и ОЕ
procedure prMarkOrNum(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMarkOrNum'; // имя процедуры/функции
var UserId, WareID, ResCode, OrigId: integer;
    OrigNum, MsgStr: string;
    SrcID: integer;
begin
  Stream.Position:= 0;
  SrcID:= soHand;
  try
    UserID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;  // Код товара
    OrigId:= Stream.ReadInt;  // Код ОЕ
    ResCode:= Stream.ReadByte; // Код операции

    prSetThLogParams(ThreadData, csMarkOrNum, UserId, 0, 'WareID='+IntToStr(WareID)+
                     'OrigId='+IntToStr(OrigId)+' Operation='+IntToStr(ResCode));

    if not (ResCode in [resWrong, resNotWrong]) then
      raise EBOBError.Create('Ошибочный код операции '+IntToStr(resCode)+' !');
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
//=========================== Получить оригинальные номера, общие для 2х товаров
procedure prShowCrossOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prShowCrossOE'; // имя процедуры/функции
var UserId, FirmID, Ware1, Ware2, i, Position, Count, arlen: integer;
    errmess: string;
    STai1, SLTai1, STai2, SLTai2: Tai;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    Ware1:= Stream.ReadInt;  // Код товара
    Ware2:= Stream.ReadInt;  // Код товара

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
        Stream.WriteInt(STai2[i]);      // Код оригинального номера
        Stream.WriteInt(MfAutoID);     // код производителя авто
        Stream.WriteByte(SLTai2[i]);    // Код источника связи
        Stream.WriteStr(OriginalNum);  // оригинальный номер
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
const nmProc = 'prShowEngineOptions'; // имя процедуры/функции
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
      ' ModelID='+IntToStr(ModelID)+' Engine='+Engine); // дописать подробности!

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if (EngineID<1) then begin
      if not Cache.FDCA.Models.ModelExists(ModelID) then
        raise EBOBError.Create('Не найдена заданная модель');
      EngCodes:= Cache.FDCA.Models[ModelID].EngLinks.GetLinkCodes;

    end else begin
      if not Cache.FDCA.Engines.ItemExists(EngineID) then
        raise EBOBError.Create('Не найден заданный двигатель');
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
    if (arlen<0) then raise EBoBError.Create('Нет данных по этому двигателю.');

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
//======================== "освежает" набор Top10 последних выбираемых моделей и
//====================================== возвращает данные для отображения строк
procedure prGetTop10Model(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetTop10Model'; // имя процедуры/функции
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
      ' ModelID='+IntToStr(ModelID)+' Codes='+Codes); // дописать подробности !

//if flDebugCV then Sys:= constIsCV;

    flNotEng:= CheckTypeSys(Sys);
    if not flNotEng and (Sys<>(constIsAuto+30)) then
      raise EBOBError.Create(MessText(mtkUnknownSysType, IntToStr(Sys)));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if (ModelID<1) then SetLength(ModelCodesNew, 0)
    else begin
      if flNotEng then begin
        if not Cache.FDCA.Models.ModelExists(ModelID) then
          raise EBOBError.Create('Не найдена заданная модель');
        Model:= Cache.FDCA.Models[ModelID];
        if (Model.TypeSys<>Sys) then
          raise EBOBError.Create('Модель не соответствует системе учета');
        if not Model.IsVisible then
          raise EBOBError.Create('Нельзя добавить невидимую модель');
      end else if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create('Не найден заданный двигатель');

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
//-------------------------------------------------------------- общие параметры
        Stream.WriteInt(Model.ID);
        Stream.WriteInt(fnIfInt(sys=constIsMoto, Model.SubCode, 0));
        Stream.WriteInt(ModelLineID);
        Stream.WriteInt(MFAID);
        Stream.WriteStr(Cache.FDCA.Manufacturers[MFAID].Name);
        Stream.WriteStr(ModelLine.Name);
        Stream.WriteStr(Model.Name);
        Stream.WriteInt(mps.pYStart); // Год начала выпуска
        Stream.WriteInt(mps.pMStart); // Месяц начала выпуска
        Stream.WriteInt(mps.pYEnd);   // Год окончания выпуска
        Stream.WriteInt(mps.pMEnd);   // Месяц окончания выпуска

//---------------------------------------------- специфические параметры системы
        case sys of
          constIsMoto, constIsAuto: begin //--------------------- auto, moto
            Stream.WriteInt(mps.pHP);               // лс
            Stream.WriteStr(Model.MarksCommaText);  // маркировки двигателей
          end;
          constIsCV: begin                //----------------------- грузовики
            Stream.WriteStr(mps.cvHPaxLOout);       // лс от-до
            s:= mps.cvTonnOut;
            if (s<>'') then s:= s+' т';
            Stream.WriteStr(s);                     // тоннаж
            Stream.WriteStr(Model.MarksCommaText);  // маркировки двигателей
          end;
          constIsAx: begin                //----------------------- оси
            s:= mps.cvHPaxLOout;
            if (s<>'') then s:= s+' кг';
            Stream.WriteStr(s);                     // Нагрузка на ось [кг] от-до
            if (mps.pDriveID<1) then s:= ''
            else s:= Cache.FDCA.TypesInfoModel.InfoItems[mps.pDriveID].Name;
            Stream.WriteStr(s);                     // Тип оси
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
//================================== получить список двигателей по производителю
procedure prLoadEngines(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prLoadEngines'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csLoadEngines, UserId, FirmID, ' MFAUID='+IntToStr(MFAUID)); // дописать подробности!

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
      Stream.WriteStr(Engine.EngCCstr);  // строка - значение Тех.обьем в куб.см.
      Stream.WriteStr(Engine.EngKWstr);  // строка - значение Мощность кВт
      Stream.WriteStr(Engine.EngHPstr);  // строка - значение Мощность ЛС
      Stream.WriteStr(Engine.EngCYLstr); // строка - значение Количество цилиндров
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
const nmProc = 'prNewsPage'; // имя процедуры/функции
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
      else Stream.WriteStr('Неизвестный');
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
const nmProc = 'prTestLinksLoading'; // имя процедуры/функции
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
      Stream.WriteStr('Ошибка выполнения .');
//      fnWriteToLog(ThreadData, lgmsSysError, nmProc, '', E.Message, '');
    end;
  end;
  Stream.Position:= 0;
end;


procedure prGetFilterValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFilterValues'; // имя процедуры/функции
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
     #13#10'isEngine='+fnIfStr(IsEngine, '1', '0')); // логирование
StrPos:='1';

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
StrPos:='1-1';

StrPos:='2';

    if not IsEngine and not Cache.FDCA.Models.ModelExists(ModelId) then begin
      raise EBOBError.Create('Неверно указана модель');
    end;

    if IsEngine and not Cache.FDCA.Engines.ItemExists(ModelId) then begin
      raise EBOBError.Create('Неверно указан двигатель');
    end;
StrPos:='3';

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    List:= Cache.FDCA.GetModelOrEngNodeFiltersList(NodeID, ModelID, IsEngine);
    Stream.WriteStr('Место установки');
    Stream.WriteInt(List.Count); // кол-во значений в категории
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
const nmProc = 'prShowActionNews'; // имя процедуры/функции
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
    prSetThLogParams(ThreadData, csShowActionNews, UserId, 0, 'Newsid='+IntToStr(NewsId)); // логирование

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
      raise EBOBError.Create('Указанная новость не найдена');
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
const nmProc = 'prAEActionNews'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csAEActionNews, UserId, 0, 'Newsid='+IntToStr(NewsId)); // логирование

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

    if (title='') then raise EBOBError.Create('Название не может быть пустым');

    if (DateFrom>DateTo) then
      raise EBOBError.Create('Дата окончания периода отображения не может быть меньше даты начала.');

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
const nmProc = 'prSaveImgForAction'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csSaveImgForAction, UserId, 0, 'Newsid='+IntToStr(NewsId)); // логирование

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
const nmProc = 'prShowSysOptionsPage'; // имя процедуры/функции
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
    Stream.WriteBool(Cache.arEmplInfo[EmplID].UserRoleExists(rolManageSprav)); // может ли редактировать привязки ролей к константам

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
      else errmess:= 'Неизвестный';
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
const nmProc = 'prSaveSysOption'; // имя процедуры/функции
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

      errmess:= Cache.SaveNewConstValue(ConstID, EmplID, Value); // проверяем значение по смыслу внутри
      if (errmess<>'') then raise EBOBError.Create(errmess);

      sParam:= sParam+#13#10'Value='+Value; // дописываем значение
    finally
      prSetThLogParams(ThreadData, csSaveSysOption, EmplID, 0, sParam);
    end;
    Item:= Cache.GetConstItem(ConstID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(fnGetAdaptedConstValue(ConstID));
    if Cache.EmplExist(Item.LastUser) then
      sParam:= Cache.arEmplInfo[Item.LastUser].EmplShortName
    else sParam:= 'Неизвестный';
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
const nmProc = 'prEditSysOption'; // имя процедуры/функции
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
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - код='+IntToStr(ConstID));
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

      else raise EBOBError.Create('Не знаю, как обработать значение.');
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
const nmProc = 'prShowConstRoles'; // имя процедуры/функции
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
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - код='+IntToStr(ConstID));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    Roles:= Cache.GetAllRoleCodes;
    varTo:= Length(Roles)-1;
    Stream.WriteInt(varTo); // место под кол-во ролей
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
const nmProc = 'prEditConstRoles'; // имя процедуры/функции
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
      raise EBOBError.Create(MessText(mtkNotValidParam)+' - код='+IntToStr(ConstID));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    Item:= Cache.GetConstItem(ConstID);
    varTo:= List.Count-1;
    errmess:= '';
    for i:= 0 to varTo do begin
      RoleCode:= StrToIntDef(List.Names[i], -1);
      Rights:= StrToIntDef(List.Values[List.Names[i]], -1);
      if (Cache.RoleExists(RoleCode) and (Rights in [0..2])) then begin
        if (Rights=0) then begin //удаляем
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
      raise EBOBError.Create('Во время выполнения операции возникли следующие ошибки: '#13#10+errmess);
 except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(List);
end;
//======= Управление отметкой об ошибочной связи товара c односторонним аналогом
procedure prMarkOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMarkOneDirectAnalog'; // имя процедуры/функции
var UserId, WareID, ResCode, AnalogId, SrcID: integer;
    MsgStr: string;
    Ware: TWareInfo;
begin
  Stream.Position:= 0;
  try
    UserID     := Stream.ReadInt;
    WareID     := Stream.ReadInt;    // Код товара
    AnalogId   := Stream.ReadInt;    // Код аналога
    ResCode    := Stream.ReadByte;   // Код операции
    SrcID      := Stream.ReadInt;    // Код источника

    prSetThLogParams(ThreadData, csMarkOneDirectAnalog, UserId, isWe, 'WareID='+IntToStr(WareID)+
      #13#10'AnalogId='+IntToStr(AnalogId)+#13#10'Operation='+IntToStr(ResCode));

    if not (ResCode in [resWrong, resNotWrong, resDeleted]) then
      raise EBOBError.Create('Ошибочный код операции '+IntToStr(resCode)+' !');

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
      raise EBOBError.Create('У Вас нет прав на работу с товаром '+Ware.Name);

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


//======================================== Добавить односторонний аналог вручную
procedure prAddOneDirectAnalog(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prAddOneDirectAnalog'; // имя процедуры/функции
var UserId, WareID, ResCode: integer;
    AnalogName, MsgStr: string;
    Ware: TWareInfo;
    Wares: Tai;
begin
  Stream.Position:= 0;
  try
    UserID  := Stream.ReadInt;
    WareID  := Stream.ReadInt;    // Код товара
    AnalogName:= Stream.ReadStr;    // Наименование аналога

    prSetThLogParams(ThreadData, csAddOneDirectAnalog, UserId, isWe, 'WareID='+
      IntToStr(WareID)+#13#10'AnalogName='+AnalogName);

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    Ware:= Cache.GetWare(WareId);
    if Ware.ManagerID<>UserId then
      raise EBOBError.Create('У Вас нет прав на работу с товаром '+Ware.Name);

    Wares:= SearchWareNames(AnalogName, 3);

    if (Length(Wares)=0) then
      raise EBOBError.Create('Не найден товар-аналог [ '+(AnalogName)+' ] !');

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
const nmProc = 'prUiKPage'; // имя процедуры/функции
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
const nmProc = 'prShowPortion'; // имя процедуры/функции
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
    Stream.WriteInt(0); // место под кол-во
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
const nmProc = 'prGetRadiatorList'; // имя процедуры/функции
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

    // создаем массив моделей в виде, пригодном для вставки в csv файл +++
    TDIBS.SQL.Text:= 'select Max(m.mt_id) max_ from model_types m';
    TDIBS.ExecQuery;
    SetLength(Models, TDIBS.FieldByName('max_').AsInteger+1);
    TDIBS.Close;

    for i:= 0 to High(Models) do Models[i]:= ''; // инициализируем массив

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
    // создаем массив моделей в виде, пригодном для вставки в csv файл ---

// выбираю все артикулы, которые должны участвовать в выборке вместе с моделями,
// к которым они привязаны, причем сортирую по коду модели
    TDIBS.SQl.Clear;
    TDIBS.SQL.Add('select '); //    TDIBS.SQL.Add('first 100 ');
    TDIBS.SQL.Add('l.lacgs_ga_ID lagt_ga_id, l.lacgs_VknZielNr lagt_mt_id,'+
                  ' l.lacgs_art_ID lagt_art_id from link_art_cri_ga_sort l');
    TDIBS.SQL.Add('where l.lacgs_ga_ID in (447, 448, 2842, 2843)');
    TDIBS.SQL.Add(' and l.lacgs_VknZielArt=2 and l.lacgs_sup_ID in (66, 123)');
    TDIBS.SQL.Add('order by l.lacgs_VknZielNr');
    TDIBS.ExecQuery;
    while not TDIBS.Eof do begin
// если эта модель встретилась не первый раз, то код артикула добавляется в массив arFirst или arSecond
// (см строки кода перед TDIBS.Next;)
// Проверки, в какой массив вставлять, основаны на данных заказчика, а именно, принадлежности ариткула группе и бренду(производителю)
      jj:= TDIBS.FieldByName('lagt_mt_id').AsInteger;
      if (jj<>CurrentModel) then begin
// если модель встретилась первый раз, то это знак, что предыдущая закончилась (так как сортировка выборки идет по коду модели)
// и самое время подбить итоги
// OL - это ObjectList, в котором лежат объекты типа тоже ТObjectList
// во внутреннем ObjectList по два объекта. Первый типа TTwoCodes, который содержит коды пар товаров первой и второй группы
// Второй типа TStringList, который содержит строки с моделями.
{ TODO : Это неправильно, что я использую StringList для хранения полных строк моделей, это занимает лишнюю память. Заменить на Tlist }
// перебираем все возможные сочетания элементов массивов arFirst и arSecond
        for i:= 0 to High(arFirst) do for j:= 0 to High(arSecond) do begin
          Founded:= false;
          for k:= 0 to OL.Count-1 do begin
            OL1:= TObjectList(OL[k]);
            TwoCodes:= TTwoCodes(OL1[0]);
            Founded:= (TwoCodes.ID1=arFirst[i]) and (TwoCodes.ID2=arSecond[j]);
            if Founded then break;
          end;
// если нашли, то в OL1 ссылка на новый
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
    SL.Add('Производитель;Модельный ряд;Модель;Даты выпуска;Мощность;Код;Двигатели');
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
//====================================================== страница "Применимость"
procedure prCOUPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCOUPage'; // имя процедуры/функции
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

    //-------------------------  добавить CV ???

    if not (flAuto or flMoto) then raise EBOBError.Create(MessText(mtkNotRightExists));
    if (flAuto and flMoto) then
      raise EBOBError.Create('Невозможно определить бизнес-направление для выбора критериев.');

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
    Stream.WriteInt(0); // место под кол-во
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

//===================================================== список значений критерия
procedure prGetCateroryValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCateroryValues'; // имя процедуры/функции
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

    //-------------------------------- добавить CV ???

    with Cache.arEmplInfo[UserId] do begin
      flAuto:= UserRoleExists(rolTNAManageAuto);
      flMoto:= UserRoleExists(rolTNAManageMoto);
    end;
    if not (flAuto or flMoto) then raise EBOBError.Create(MessText(mtkNotRightExists));
    if (flAuto and flMoto) then
      raise EBOBError.Create('Невозможно определить бизнес-направление для выбора критериев.');

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(0); // место под кол-во последних значений
    Stream.WriteInt(0); // место под кол-во ???

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBSQL:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, True);

    OrdIBSQL.SQl.Clear;
    OrdIBSQL.SQL.Add('select first 1 wc.* from warecriteries wc');
    OrdIBSQL.SQL.Add(' where wc.wcridescr='''+Criteria+''' and ');
    OrdIBSQL.SQL.Add(' wc.wcriedituse'+fnIfStr(flAuto, 'auto', 'moto')+'="T"');
    OrdIBSQL.SQL.Add(' order by wc.wcricode');
    OrdIBSQL.ExecQuery;
    if OrdIBSQL.EOF then raise EBOBError.Create('Не найден критерий "'+Criteria+'"');
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
      Stream.WriteInt(0); // место под кол-во
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
//============ добавление/редактирование порции условий к 3-й связке (интерфейс)
procedure prSavePortion(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSavePortion'; // имя процедуры/функции
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
    qty      := Stream.ReadInt; // кол-во условий

    prSetThLogParams(ThreadData, csSavePortion, UserId, 0, 'ModelID='+IntToStr(ModelID)+
      #10#13'NodeID='+IntToStr(NodeID)+#10#13'WareID='+IntToStr(WareID)+
      #10#13'PortionID='+IntToStr(PortionID)+#10#13'qty='+IntToStr(qty));

    if not Cache.EmplExist(UserID) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if (qty=0) then raise EBOBError.Create('Нельзя сохранить блок без содержимого');

    SL:= TStringList.Create;
    for i:= 0 to qty-1 do SL.Add(Stream.ReadStr+cStrValueDelim+Stream.ReadStr);

    empl:= Cache.arEmplInfo[UserId];
    if not (empl.UserRoleExists(rolModelManageAuto)
      or empl.UserRoleExists(rolModelManageMoto)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FDCA.Models.ModelExists(ModelID) then
      raise EBOBError.Create('Не найдена заданная модель');
    if empl.UserRoleExists(rolModelManageAuto)
      and not Cache.FDCA.AutoTreeNodesSys[constIsAuto].NodeExists(NodeId) then
      raise EBOBError.Create('Неверно указан узел');
    if empl.UserRoleExists(rolModelManageMoto)
      and not Cache.FDCA.AutoTreeNodesSys[constIsMoto].NodeExists(NodeId) then
      raise EBOBError.Create('Неверно указан узел');
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
const nmProc = 'prGetDeliveriesList'; // имя процедуры/функции
var EmplID, StoreId, i: integer;
    s: string;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;
    StoreId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetDeliveriesList, EmplID, 0, 'StoreId='+IntToStr(StoreId)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);
    with Cache.GetShipMethodsList(StoreId) do try                      // список методов отгрузки по складу
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
const nmProc = 'prRestorePassword'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csRestorePassword, 0, 0, 'login='+s+#13#10'IP='+IP); // логирование

    EmplID:= Cache.GetEmplIDbyLogin(s);
    if (EmplID<1) then raise EBOBError.Create('Не найден логин "'+s+'"');

    Empl:= Cache.arEmplInfo[EmplID];
    s1:= 'Ваша учетная запись заблокирована администратором';
    if (Empl.Arhived) then raise EBOBError.Create(s1+' системы GrossBee.');
    if (Empl.Blocked) then raise EBOBError.Create(s1+' werbarm.');
    s1:= '';
    s:= Empl.Mail;
    if (s='') then begin
      s1:= 'отсутствует Ваш e-mail.';
      s2:= 'внести Ваш e-mail в справочник';
    end else if not fnCheckEmail(s) then begin
      s1:= 'неверно задан Ваш e-mail: '+s+'.';
      s2:= 'исправить Ваш e-mail в справочнике';
    end;
    if (s1<>'') then raise EBOBError.Create('В справочнике сотрудников GrossBee '+s1+
      ' Обратитесь в отдел УиК непосредственно или через Вашего руководителя с просьбой '+s2+'.');

{    s:= '172.20.10.';
    s1:= '192.168.2.';
    if ((Copy(IP, 1, Length(s))<>s) and (Copy(IP, 1, Length(s1))<>s1)) then
      raise EBOBError.Create('Ваш IP '+IP+' не относится к числу разрешенных для восстановления пароля.');   }

    Body:= TStringList.Create;
    Body.Add('По запросу, выполненному с IP '+IP+', Вам направлены учетные данные для входа в webarm:');
    Body.Add('Адрес:  http://webarm.vladislav.ua/app/webarm.cgi');
    Body.Add('Логин: '+Empl.ServerLogin);
    Body.Add('Пароль: '+Empl.USERPASSFORSERVER);

    s:= n_SysMailSend(Empl.Mail, 'Восстановление пароля webarm', Body);

    if (s<>'') then raise EBOBError.Create('Не могу отправить почту. Ошибка "'+s+'"');

    raise EBOBError.Create('Пароль отправлен на E-mail "'+Empl.Mail+'"');
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(Body);
end;
//========================================== блокировка/разблокировка сотрудника
procedure prBlockWebArmUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prBlockWebArmUser'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csBlockWebArmUser, EmplID, 0, 'VictimID='+IntToStr(VictimID)+#13#10'command='+command); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolManageUsers)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    if CheckNotValidUser(VictimID, isWe, s) then raise EBOBError.Create(s); // проверка жертвы
    Victim:= Cache.arEmplInfo[VictimId];

    if ((command<>'block') and (command<>'unblock')) then
      raise EBOBError.Create('Неизвестная подкоманда - "'+command+'"');

    if ((command='block') and Victim.Blocked) then
      raise EBOBError.Create('Пользователь уже заблокирован');

    if ((command<>'block') and not Victim.Blocked) then
      raise EBOBError.Create('Пользователь не заблокирован');

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
const nmProc = 'prCheckRestsInStorageForAcc'; // имя процедуры/функции
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
      'Storage='+IntToStr(StorageId)+#13#10'wares='+s); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolOPRSK)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));
    if not Cache.DprtExist(StorageId) then
        raise EBOBError.Create('Не найден склад с кодом '+IntToStr(StorageId));

    wares:= fnArrOfCodesFromString(waress);
    if (Length(wares)=0) then raise EBOBError.Create('Нет данных для сравнения');

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
const nmProc = 'fnRep47'; // имя процедуры/функции
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
(* старая процедура - перекачка аналогов из базы ORD
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
      ErrorMessage:= 'Ошибка в процедуре '+nmProc+' '+ E.Message;
      prMessageLOGS(ErrorMessage, 'import', false) ;
    end;
  end;

  if (ErrorMessage='') then lstBodyMail.Add('Импорт односторонних аналогов прошел успешно.')
  else lstBodyMail.Add('Импорт односторонних аналогов завершен с ошибкой '+ErrorMessage);
  lstBodyMail.Add('Импортировано '+IntToStr(added)+' аналогов.');
  lstBodyMail.Add('Пропущено '+IntToStr(skipped)+' аналогов.');
  lstBodyMail.Add('Время выполнения - '+FormatDateTime('hh:nn:ss.zzz', Now-StartTime));
  Subj:= 'Отчет 47 (импорт товаров в GrossBee) от '+FormatDateTime(cDateTimeFormatY4S, Now);
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
const nmProc = 'prNotificationPage'; // имя процедуры/функции
var EmplID, i: integer;
    s: string;
    List: TStringList;
    firm: TFirmInfo;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csNotificationPage, EmplID); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.Position:= 0;
    Stream.WriteInt(aeSuccess);

    List:= Cache.GetFirmTypesList(); // сортированный
    Stream.WriteStringList(List, true);
    prFree(List);

    List:= Cache.GetFirmClassesList(); // сортированный
    Stream.WriteStringList(List, true);
    prFree(List);

    List:= Cache.GetFilialList(); // сортированный
    Stream.WriteStringList(List, true);

    List.Clear;
    for i:= Low(Cache.arFirmInfo) to High(Cache.arFirmInfo) do
      if Assigned(Cache.arFirmInfo[i]) then begin
        firm:= Cache.arFirmInfo[i];
        if (not firm.Arhived) then List.AddObject(firm.Name, firm);
      end;
    List.Sort;
    Stream.WriteInt(List.Count); // место под кол-во фирм
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
const nmProc = 'prAEDNotification'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csAEDNotification, EmplID, 0, 'NotifyID='+IntToStr(NotifyID)); // логирование

    if ((NotifyID>0) and not (Auto or Moto)) then
      raise EBOBError.Create('Хотя бы один из признаков Auto или Moto должен быть задан');

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not (Cache.arEmplInfo[EmplId].UserRoleExists(rolNewsManage)) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

    ordIBD:= CntsOrd.GetFreeCnt;
    OrdIBS:= fnCreateNewIBSQL(ordIBD, 'OrdIBS_'+nmProc, ThreadData.ID, tpWrite, true);


    if NotifyID<0 then begin
      s:= 'WHERE NOCLNOTE='+IntToStr(-NotifyID);
      OrdIBS.SQL.Text:= 'SELECT * FROM NOTIFIEDCLIENTS '+s;
      OrdIBS.ExecQuery;
      if OrdIBS.EOF then s:= 'DELETE FROM NOTIFICATIONS '+s  // если нет связок - удаляем
      else s:= 'UPDATE NOTIFICATIONS SET NOTEARCHIVED="T" '+s; // если есть - в архив
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
const nmProc = 'prShowNotification'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csShowNotificationWA, EmplID, 0, 'NotifyCode='+IntToStr(NotifyCode)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
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
      if OrdIBS.EOF then raise EBOBError.Create('Не найдено уведомление с кодом '+IntToStr(NotifyCode));

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
//======================================= наличие/список контрактов к/а (Webarm)
procedure prCheckContracts(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCheckContracts'; // имя процедуры/функции
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
      #13#10'ContID='+IntToStr(ContIdAsk)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
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
      Stream.WriteStr(Contract.LegalFirmName); // юр.лицо

      s:= Contract.WarnMessage;
      Stream.WriteInt(Contract.Status);
      fl:= Contract.SaleBlocked;
// Status=cstClosed, WarnMessage=""   - закрыт              - без фона
// Status=cstWorked, WarnMessage=""   - действует           - зеленый фон
// SaleBlocked=True, WarnMessage<>""  - заблокирован/закрыт - красный фон
// SaleBlocked=False, WarnMessage<>"" - действует/закрыт    - сиреневый фон
      Stream.WriteStr(s);
      Stream.WriteBool(fl);
      Stream.WriteDouble(Contract.RedSum);
      Stream.WriteDouble(Contract.VioletSum);
      Stream.WriteInt(Contract.CredDelay);
      if not fl then Stream.WriteInt(Contract.WhenBlocked); // если отгрузка не блокирована
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=============================================== список контрактов к/а (Webarm)
procedure prWebarmContractList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebarmContractList'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csWebarmContractList, EmplID, 0, 'FirmID='+IntToStr(FirmID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
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
      Stream.WriteStr(Contract.LegalFirmName); // юр.лицо
      Stream.WriteStr(Cache.GetCurrName(Contract.DutyCurrency, False));
      Stream.WriteStr(Cache.GetDprtShortName(Contract.MainStorage));
      Stream.WriteStr(Cache.GetDprtMainName(Contract.MainStorage));
      Stream.WriteDouble(Contract.CredLimit);
      Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency, False));
      Stream.WriteInt(Contract.CredDelay);
      Stream.WriteDouble(Contract.DebtSum);
      Stream.WriteDouble(Contract.OrderSum); // резерв
      s:= Contract.WarnMessage;
      Stream.WriteInt(Contract.Status);
      fl:= Contract.SaleBlocked;
// Status=cstClosed, WarnMessage=""   - закрыт              - без фона
// Status=cstWorked, WarnMessage=""   - действует           - зеленый фон
// SaleBlocked=True, WarnMessage<>""  - заблокирован/закрыт - красный фон
// SaleBlocked=False, WarnMessage<>"" - действует/закрыт    - сиреневый фон
      Stream.WriteBool(fl);
      Stream.WriteStr(s);
      Stream.WriteDouble(Contract.RedSum);
      Stream.WriteDouble(Contract.VioletSum);
      Stream.WriteStr(Contract.ContComments); // комментарий
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prManageLogotypesPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManageLogotypesPage'; // имя процедуры/функции
var EmplID, i: integer;
    s: string;
    Brand: TBrandItem;
begin
  Stream.Position:= 0;
  try
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csManageLogotypesPage, EmplID, 0, ''); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
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
const nmProc = 'prLogotypeEdit'; // имя процедуры/функции
var EmplID, BrandID: integer;
    s, NameWWW, Prefix, AdressWWW: string;
    DownLoadExclude, PictShowExclude: boolean;
begin
  Stream.Position:= 0;

  try
    EmplID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csLogotypeEdit, EmplID, 0, ''); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
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
const nmProc = 'prLoadOrder'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csLoadOrder, EmplID, 0, ''); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
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
    if (length(ORDRNUM)>Pos) then raise EBOBError.Create('Некорректный номер заказа - '+ORDRNUM);

    OrdIBS.SQL.Text:='SELECT * FROM ORDERSREESTR WHERE ORDRNUM=:ORDRNUM'+
                       ' and ORDRSTATUS>'+IntToStr(orstForming); // только отправленные
    OrdIBS.ParamByName('ORDRNUM').AsString:= ORDRNUM;
    OrdIBS.ExecQuery;
    if OrdIBS.EOF then raise EBOBError.Create('Не найден заказ '+ORDRNUM);

    firmID:= OrdIBS.FieldByName('ORDRFIRM').AsInteger;  // проверяем к/а
    if not Cache.FirmExist(firmID) then
      raise EBOBError.Create('Не найден контрагент заказа');
//    if not Cache.CheckEmplVisFirm(EmplID, firmID) then
//      raise EBOBError.Create('Недоступен контрагент заказа');

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
    else if Cache.ClientExist(pos) then begin  // если отправил другой
      Client:= Cache.arClientInfo[pos];
      sSender:= fnIfStr(Client.Name='', '', Client.Name)+
                fnIfStr(Client.Post='', '', fnIfStr(Client.Name='', '', ', ')+Client.Post)+
                fnIfStr(Client.Phone='', '', ' ('+Client.Phone+')');
    end;

    Stream.WriteStr(sAccNum);  // № счета
    Stream.WriteStr(sAccDate); // дата и время формирования счета
    Stream.WriteStr(sCreator); // создал заказ
    Stream.WriteStr(sSender);  // отправил заказ
    Stream.WriteStr(Firm.Name+' ('+Firm.UPPERSHORTNAME+')');
    Stream.WriteStr(fnIfStr(accType=0, 'нал', 'б/нал'));

    ss:= '';
    case DelivType of
      cDelivTimeTable: begin //------------------------ Доставка по расписанию
        ShipDate:= ordIBS.FieldByName('ORDRSHIPDATE').AsDateTime;
        if (ShipDate<DateNull) then ShipDate:= 0;
        DestID:= ordIBS.FieldByName('ORDRDESTPOINT').AsInteger;
        ShipTableID:= ordIBS.FieldByName('ORDRTIMETIBLE').AsInteger;
        ShipMetID:= ordIBS.FieldByName('ORDRSHIPMETHOD').AsInteger;
        ShipTimeID:= ordIBS.FieldByName('ORDRSHIPTIMEID').AsInteger;
      end; // cDelivTimeTable

      cDelivReserve: begin // Резерв
      end; // cDelivReserve

      cDelivSelfGet: begin //--------------------------------------- Самовывоз
        ShipDate:= ordIBS.FieldByName('ORDRSHIPDATE').AsDateTime;
//          ShipMetID:= ordIBS.FieldByName('ORDRSHIPMETHOD').AsInteger;
        ShipMetID:= Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue;
        ShipTimeID:= ordIBS.FieldByName('ORDRSHIPTIMEID').AsInteger;
      end; // cDelivSelfGet

    else if not flNotReserve then
        DelivType:= cDelivReserve; //--------------------------------- резерв
    end; // case
    OrdIBS.Close;

    err:= fnGetShipParamsView(contID, DprtID, DestID, ShipTableID, ShipDate,
          DelivType, ShipMetID, ShipTimeID, sDestName, sDestAdr, sArrive,
          sShipMet, sShipTime, sShipView, True);
    if (err='') then ss:= sShipView;

    if (ss='') then case DelivType of
      cDelivTimeTable: ss:= 'Доставка';
      cDelivReserve  : ss:= 'Резерв';
      cDelivSelfGet  : ss:= 'Самовывоз';
    end;
    Stream.WriteStr(ss);
    Stream.WriteStr(sComm);
    Stream.WriteStr(Cache.GetCurrName(Curr, False));
    Stream.WriteStr(Contract.Name);

    Pos:= Stream.Position;
    Stream.WriteInt(0); // заглушка под кол-во
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

(*//=================================================== проверяем расширение файла
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
        rightExt:= '.xls или .xlsx';
        flWrongExt:= not ((pFileExt='.xls') or (pFileExt='.xlsx'));
      end;
    24:                                // администрирование баз
      case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
        1: begin // загрузка альтернативных значений инфо-текстов TecDoc из файла Excel
            rightExt:= '.xls или .xlsx';
            flWrongExt:= not ((pFileExt='.xls') or (pFileExt='.xlsx'));
          end;
{        2: begin // поиск новых узлов авто из TDT
            rightExt:= '.xls или .xlsx';
            flWrongExt:= not ((pFileExt='.xls') or (pFileExt='.xlsx'));
          end;   }
        else begin // def - пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
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
    raise EBOBError.Create('Неверный формат файла - '+pFileExt+', нужен '+rightExt);
end; *)
//=================================================== формируем имя файла отчета
procedure prFormRepFileName(pFilePath: string; var fname: string; RepKind: integer; flSet: Boolean=False);
var pFileExt{, MidName}: String;
begin
  if flSet then begin // импорт из файла в базу
    fname:= pFilePath+fnFormRepFileName(IntToStr(RepKind), fname, constOpImport);

  end else begin // отчет о необходимых изменениях
    pFileExt:= '';
    case RepKind of
      13, 14, 36, 53: pFileExt:= '.csv';
      15, 25, 34, 39, 40, 67, 68: pFileExt:= '.xml';
      24:  // администрирование баз
        case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
          4: pFileExt:= '.csv';
             // def - пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
          else
          pFileExt:= '.txt';
        end;
    end;
    fname:= pFilePath+fnFormRepFileName(IntToStr(RepKind), pFileExt, constOpExport);
  end;
  if FileExists(fname) and not SysUtils.DeleteFile(fname) then
    raise EBOBError.Create(MessText(mtkNotDelPrevFile));
end;
//=================================================== параметры письма с отчетом
procedure prFormRepMailParams(var Subj, ContentType: string;
          var BodyMail: TStringList; RepKind: integer; flSet: Boolean=False);
var sYearFrom: String;
  //--------------------------------
  function GetRepNameTD(s: string; SysID: Integer): string;
  var s1, s2, s3: String;
  begin
    if flSet then begin
      s1:= 'загрузке ';
      s3:= ' из';
    end else begin
      s1:= 'проверке ';
      s3:= ' по';
    end;
    case SysID of
      0: s2:= '';
      constIsAuto: s2:= ' легк.авто';
      constIsCV  : s2:= ' груз.авто';
      constIsAx  : s2:= ' осей';
    end;
    Result:= 'Отчет о '+s1+s+s2+s3+' TecDoc';
  end;
  //--------------------------------
begin
  if not flSet then begin
    sYearFrom:= GetYearFromLoadModels;
    if (sYearFrom<>'') then sYearFrom:=' (от '+sYearFrom+'г.)';
  end else sYearFrom:= '';
  case RepKind of
//    13: Subj:= GetRepNameTD('производителей');
//    14: Subj:= GetRepNameTD('модельных рядов');
//    15: Subj:= GetRepNameTD('моделей');
    25: Subj:= GetRepNameTD('произв.+м.р.+мод.'+sYearFrom, constIsAuto);
    34: Subj:= GetRepNameTD('узлов', 0);
    36: Subj:= 'Отчет об артикулах TecDoc для инфо-групп Гроссби';
    39: Subj:= 'Замены инфо-текстов TecDoc';
    40: Subj:= 'Отчет о проверке привязок товаров к артикулам TecDoc';
    53: Subj:= 'Отчет о клонировании к/а';
    67: Subj:= GetRepNameTD('произв.+м.р.+мод.'+sYearFrom, constIsCV);
    68: Subj:= GetRepNameTD('произв.+м.р.+мод.'+sYearFrom, constIsAx);
    24:  // администрирование баз
      if flSet then begin
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'set24', 0) of
//          else
          Subj:= 'Отчет об удалении моделей';
//        end;
      end else begin
        case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
          4: Subj:= 'Отчет о главных пользователях';
          else
          Subj:= 'Отчет о пакетной загрузке';
        end;
      end;
  end;
  if not Assigned(BodyMail) then BodyMail:= TStringList.Create;
  BodyMail.Add(Subj+' от '+FormatDateTime(cDateTimeFormatY2S, Now()));
end;
//======================================== отчет - поиск новых данных авто в TDT
procedure prGetAutoDataFromTDT(ReportKind, UserID: integer; var BodyMail: TStringList;
          var pFileName, Subj, ContentType: string; ThreadData: TThreadData=nil; filter_data: String='');
const nmProc = 'prGetAutoDataFromTDT'; // имя процедуры/функции
var pFilePath, errmess: String;
    lst: TStringList;
begin
  lst:= nil;
  pFilePath:= '';
  errmess:= '';
  if not GetEmplTmpFilePath(UserID, pFilePath, errmess) then raise EBOBError.Create(errmess);
//  if CheckNotValidModelManage(UserID, constIsAuto, errmess) then raise EBOBError.Create(errmess);
  try
    prFormRepFileName(pFilePath, pFileName, ReportKind, False); // формируем имя файла отчета
    case ReportKind of
      25: begin // 25-stamp - поиск новых производителей, м.р., моделей легковых авто из TDT
        lst:= fnGetNewAutoMfMlModFromTDT(UserID, ThreadData);
        SaveListToFile(lst, pFileName);          // xml
        ContentType:= XMLContentType;
      end;
      34: begin // 34-stamp - поиск новых узлов авто из TDT (легковые + грузовики + оси)
          lst:= fnGetNewTreeNodesFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      36: begin // 36-stamp - поиск артикулов TDT для инфо-групп Гроссби
          prGetArticlesINFOgrFromTDT(UserID, pFileName, ThreadData);
          ContentType:= CSVFileContentType;
        end;
      39: begin // 39-stamp - Отчет по инфо-текстам TecDoc
          lst:= fnGetInfoTextsForTranslate(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      40: begin  // 40-stamp - Отчет о проверке привязок товаров к артикулам
          lst:= fnGetCheckWareTDTArticles(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      53: begin // 53-stamp - переброска к/а Гроссби
          prGetFirmClones(UserID, pFileName, ThreadData);
          ContentType:= CSVFileContentType;
        end;
      67: begin // 67-stamp - поиск новых производителей, м.р., моделей грузовиков из TDT
          lst:= fnGetNewCVMfMlModFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;
      68: begin // 68-stamp - поиск новых производителей, м.р., моделей осей из TDT
          lst:= fnGetNewAxMfMlModFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;

      24: begin // // 24-stamp - пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
          case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
            3: begin // простановка контрактов в db_ORD
//                raise EBOBError.Create('отчет '+IntToStr(ReportKind)+'(3) недоступен');
                lst:= SetClientContractsToORD(UserID, ThreadData);
                SaveListToFile(lst, pFileName);          // txt
                ContentType:= FileContentType;
              end;
            4: begin // проверка глав.пользователей в Grossbee
//                raise EBOBError.Create('отчет '+IntToStr(ReportKind)+'(4) недоступен');
                CheckGeneralPersonsForGB(UserID, pFileName, ThreadData);
                ContentType:= CSVFileContentType;
              end;
            5: begin // проверка глав.пользователей в Grossbee + проверка неархивных логинов у архивных клиентов
//                raise EBOBError.Create('отчет '+IntToStr(ReportKind)+'(5) недоступен');
                CheckGeneralPersonsForGB(UserID, pFileName, ThreadData, True);
                ContentType:= CSVFileContentType;
              end;
            else begin // def 24-stamp - пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
              if (Cache.LongProcessFlag=cdlpLoadData) then
                raise EBOBError.Create('Загрузка уже запущена');
              if not SetLongProcessFlag(cdlpLoadData) then
                raise EBOBError.Create('Не могу запустить загрузку - идет процесс: '+cdlpNames[Cache.LongProcessFlag]);
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
      else raise EBOBError.Create('Неизвестный вид отчета - '+IntToStr(ReportKind));
    end;
    prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind); // параметры письма с отчетом
  finally
    prFree(lst);
  end;
end;
//====================================== загрузка / изменение данных авто из TDT
procedure prSetAutoDataFromTDT(ReportKind, UserID: integer; var BodyMail: TStringList;
                               var pFileName, Subj, ContentType: string; ThreadData: TThreadData=nil);
const nmProc = 'prSetAutoDataFromTDT'; // имя процедуры/функции
var errmess, pFilePath, pFileName1: String;
    lst: TStringList;
begin
  lst:= nil;
  pFilePath:= '';
  if not FileExists(pFileName) then raise EBOBError.Create('Не найден файл загрузки.');
  if not GetEmplTmpFilePath(UserID, pFilePath, errmess) then raise EBOBError.Create(errmess);
//  if CheckNotValidModelManage(UserID, constIsAuto, errmess) then raise EBOBError.Create(errmess);
  try
    case ReportKind of
      25: begin // 25-imp - загрузка новых производителей, м.р., моделей авто из TDT
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewAutoMfMlModFromTDT(UserID, pFileName, BodyMail, ThreadData);   // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      34: begin // 34-imp - загрузка  / корректировка узлов авто из Excel
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewTreeNodesFromTDT(UserID, pFileName, BodyMail, ThreadData);   // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      39: begin // 39-imp - загрузка альтернативных значений инфо-текстов TecDoc из файла Excel
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetAlternativeInfoTexts(UserID, pFileName, ThreadData);  // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      67: begin // 67-imp - загрузка новых производителей, м.р., моделей грузовиков из TDT
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewCVMfMlModFromTDT(UserID, pFileName, BodyMail, ThreadData);   // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      68: begin // 68-imp - загрузка новых производителей, м.р., моделей осей из TDT
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewAxMfMlModFromTDT(UserID, pFileName, BodyMail, ThreadData);   // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;

      24: begin // 24-imp - удаление моделей и их связок из ORD
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'set24', 0) of
//          else begin //
            pFileName1:= pFileName;                                    // запоминаем имя исходного файла
            prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
            CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
            if FileExists(pFileName) then DeleteFile(pFileName1);
            prDeleteAutoModels(UserID, pFileName, ThreadData);         // обрабатываем файл и в него же пишем отчет
            ContentType:= FileContentType;                     // ???
            prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
//          end;
//        end;
      end;
      36, 40, 53:  // 36-imp, 40-imp, 53-imp - нет
        raise EBOBError.Create('Импорт ('+IntToStr(ReportKind)+') не предусмотрен');
    else raise EBOBError.Create('Неизвестный вид импорта - '+IntToStr(ReportKind));
    end;
  finally
    prFree(lst);
  end;
end;

//******************************************************************************

//================ Проверить права сотрудника на страницу "Контрагенты" (WebArm)
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
//=================================== Проверить права сотрудника на к/а (WebArm)
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
  flSuper:= empl.UserRoleExists(rolSuperRegional);     // РОП
  flReg:= empl.UserRoleExists(rolRegional);            // менеджер к/а

  Cache.TestFirms(ForFirmID, True, True, False); // проверяем фирму
  if not Cache.FirmExist(ForFirmID) then
    raise EBOBError.Create(MessText(mtkNotFirmExists));
  firm:= Cache.arFirmInfo[ForFirmID];

  if not (flManageSprav or flUiK or flService
    or (flSuper and (empl.FaccRegion>0) and firm.CheckFirmRegion(empl.FaccRegion))
    or (flReg and firm.CheckFirmManager(emplID))) then
    raise EBOBError.Create(MessText(mtkNotRightExists));

//  if (cek=cekFirmUsers) then begin  end;
end;

//================================================ список контрагентов регионала
procedure prWebArmGetRegionalFirms(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetRegionalFirms'; // имя процедуры/функции
var EmplId, FirmID, i, j: integer;
    Codes: Tai;
    Template: string;
    empl: TEmplInfoItem;
    firm: TFirmInfo;
begin
  Stream.Position:= 0;
  SetLength(Codes, 0);
  try
    EmplId:= Stream.ReadInt;          // код регионала (0-все)
    Template:= trim(Stream.ReadStr);  // фильтр наименования контрагента

    prSetThLogParams(ThreadData, csWebArmGetRegionalFirms, EmplId, 0, 'Template='+Template); // логирование

    prCheckEmplRights(cekFirms, emplID, empl, j); // проверяем право пользователя

    Codes:= Cache.GetRegFirmCodes(j, Template); // список кодов неархивных контрагентов
    j:= length(Codes);
    if (j<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
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
//==================================================== список юзеров контрагента
procedure prWebArmGetFirmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmUsers'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csWebArmGetFirmUsers, EmplId, 0, 'FirmID='+IntToStr(FirmID)); // логирование

    prCheckEmplRights(cekFirmUsers, emplID, FirmID, empl, firm); // проверяем право пользователя

    flManageSprav:= empl.UserRoleExists(rolManageSprav);
    if (firm.SUPERVISOR>0) then pUser:= firm.SUPERVISOR else pFirm:= FirmID;
    Cache.TestClients(pUser, True, False, True, pFirm); // проверяем частично должн.лиц контрагента

    SetLength(Users, Length(firm.FirmClients)); // получаем список должн.лиц контрагента
    CliCount:= 0; // счетчик должн.лиц
    for i:= Low(firm.FirmClients) to High(firm.FirmClients) do begin
      j:= firm.FirmClients[i];
      if not Cache.ClientExist(j) then Continue;
      Users[CliCount]:= j;
      inc(CliCount);
    end;

    dpCount:= firm.FirmDestPoints.Count;
    ContCount:= firm.FirmContracts.Count;
    if (CliCount<1) and (dpCount<1) and (ContCount<1) then
      raise EBOBError.Create('Нет данных по контрагенту.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно

//-------------------------------------------------------------- Контактные лица
    Stream.WriteInt(CliCount);        // кол-во конт.лиц
    for i:= 0 to CliCount-1 do begin
      j:= Users[i];
      Stream.WriteInt(j); // код
      with Cache.arClientInfo[j] do begin
        Stream.WriteStr(Name);  // ФИО
        Stream.WriteStr(Post);  // должность
        Stream.WriteStr(Phone); // телефоны
        Stream.WriteStr(Mail);
        Stream.WriteStr(Login); // логин
        Stream.WriteByte(byte(Blocked)+                       // признак блокированности
                         2*fnIfInt(flManageSprav, 1, 0)+      // признак разрешения разблокировки (только админы)
                         fnIfInt((firm.SUPERVISOR=j), 4, 0)); // признак суперпупера
      end;
    end; // for i:= 0 to

//--------------------------------------------------------------- торговые точки
    Stream.WriteInt(dpCount);     // кол-во
    for i:= 0 to dpCount-1 do begin
      dp:= TDestPoint(firm.FirmDestPoints[i]);
      Stream.WriteStr(dp.Name);   // название
      Stream.WriteStr(dp.Adress); // адрес
    end;

//-------------------------------------------------------------------- контракты
if flCredProfile then begin // по профилям

    posProf:= Stream.Position;
    ProfCount:= 0;      // счетчик профилей
    Stream.WriteInt(0); // место под кол-во профилей

    for ii:= 0 to firm.FirmCredProfiles.Count-1 do begin
      prof:= TCredProfile(firm.FirmCredProfiles[ii]);
      if not Assigned(prof) then prof:= ZeroCredProfile;

      flBlock:= prof.Blocked or firm.SaleBlocked;

      posCont:= Stream.Position;
      contCount:= 0;      // счетчик контрактов в профиле
      Stream.WriteInt(0); // место под кол-во контрактов в профиле

      for i:= 0 to firm.FirmContracts.Count-1 do begin
        j:= firm.FirmContracts[i];
        Contract:= firm.GetContract(j);
        if (Contract.CredProfile<>prof.ID) then Continue; // отбор по профилю

        dprtName:= Cache.GetDprtMainName(Contract.MainStorage);
        currName:= Cache.GetCurrName(prof.ProfCredCurrency, True);
  // колонка "Кред.условия": если <сумма кредита> = 0 - "Предоплата",
  // иначе - <сумма кредита> <валюта кредита> / <отсрочка> дн.
        if (prof.ProfCredLimit>0) then sCred:= FloatToStr(prof.ProfCredLimit)+
          ' '+currName+' / '+IntToStr(prof.ProfCredDelay)+' дн.'
        else sCred:= 'Предоплата';

        Stream.WriteStr(Contract.Name);          // № контракта
        Stream.WriteStr(Contract.LegalFirmName); // юр.лицо
        Stream.WriteInt(Contract.PayType);       // форма оплаты
        Stream.WriteStr(dprtName);               // склад отгрузки

//------------------------------------------------- объединенные ячейки таблицы
        Stream.WriteStr(sCred);                 // Кред.условия

        Stream.WriteDouble(prof.ProfDebtAll);   // общий долг - добавлена строка !!!
//-------------------------------------------------

        Stream.WriteDouble(Contract.DebtSum);     // долг/переплата
        Stream.WriteDouble(Contract.OrderSum);    // резерв

//        if flBlock then Stream.WriteInt(cstBlocked) else // статус блокировки  ???
        Stream.WriteInt(Contract.Status);      // статус контракта

        Stream.WriteDouble(Contract.RedSum);      // просрочено
        Stream.WriteDouble(Contract.VioletSum);   // истекает срок
        Stream.WriteStr(Contract.ContComments);   // комментарий
        Stream.WriteDouble(Contract.ContBegDate); // дата начала
        Stream.WriteDouble(Contract.ContEndDate); // дата окончания

        //-------------------------------------- собираем общие долг и переплату
        if (Contract.DebtSum>0) then DebtAll:= DebtAll+Contract.DebtSum
        else if (Contract.DebtSum<0) then OverAll:= OverAll+Contract.DebtSum;
        Inc(contCount);
      end; // for i:= 0 to firm.FirmContracts.Count-1

      CredLimitAll:= CredLimitAll+prof.ProfCredLimit; //-- собираем общий кредит

      Stream.Position:= posCont; // возвращаемся на позицию счетчика контрактов
      if (contCount>0) then begin // есть контракты по профилю
        Stream.WriteInt(contCount);    // пишем кол-во контрактов
        Stream.Position:= Stream.Size; // идем в конец Stream
        Inc(ProfCount);
      end;
    end; // for ii:= 0 to firm.FirmCredProfiles.Count-1

    if (ProfCount>0) then begin
      Stream.Position:= posProf;
      Stream.WriteInt(ProfCount); // кол-во профилей
      Stream.Position:= Stream.Size; // идем в конец Stream
    end;

end // if flCredProfile
else begin // старый вывод

    Stream.WriteInt(ContCount);     // кол-во
    for i:= 0 to ContCount-1 do begin
      j:= firm.FirmContracts[i];
      Contract:= firm.GetContract(j);
      dprtName:= Cache.GetDprtMainName(Contract.MainStorage);
// колонка "Кред.условия": если <сумма кредита> = 0 - "Предоплата",
// иначе - <сумма кредита> <валюта кредита> / <отсрочка> дн.
      currName:= Cache.GetCurrName(Contract.CredCurrency, True);
      if (Contract.CredLimit>0) then
        sCred:= FloatToStr(Contract.CredLimit)+' '+currName+' / '+IntToStr(Contract.CredDelay)+' дн.'
      else sCred:= 'Предоплата';

      Stream.WriteStr(Contract.Name);           // № контракта
      Stream.WriteStr(Contract.LegalFirmName);  // юр.лицо
      Stream.WriteInt(Contract.PayType);        // форма оплаты
      Stream.WriteStr(dprtName);                // склад отгрузки
      Stream.WriteStr(sCred);                   // Кред.условия
      Stream.WriteDouble(Contract.DebtSum);     // долг/переплата
      Stream.WriteDouble(Contract.OrderSum);    // резерв
      Stream.WriteInt(Contract.Status);         // статус
      Stream.WriteDouble(Contract.RedSum);      // просрочено
      Stream.WriteDouble(Contract.VioletSum);   // истекает срок
      Stream.WriteStr(Contract.ContComments);   // комментарий
      Stream.WriteDouble(Contract.ContBegDate); // дата начала
      Stream.WriteDouble(Contract.ContEndDate); // дата окончания
      //-------------------------------------------------------- суммируем итоги
      if (Contract.Status<>cstClosed) then
        CredLimitAll:= CredLimitAll+Contract.CredLimit;
      if (Contract.DebtSum>0) then DebtAll:= DebtAll+Contract.DebtSum
      else if (Contract.DebtSum<0) then OverAll:= OverAll+Contract.DebtSum;
    end; // for i:= 0 to ContCount-1
end; // if not flCredProfile

    Stream.WriteDouble(CredLimitAll);  // общая сумма кредита по всем действующим контрактам
    Stream.WriteDouble(DebtAll);       // общая сумма долга по всем контрактам
    Stream.WriteDouble(OverAll);       // общая сумма переплаты по всем контрактам

if flCredProfile then begin // по профилям
    //------------------------------------------------------------ пакеты скидок
    sCred:= 'ПС: ';
    for i:= 0 to firm.FirmDiscModels.Count-1 do begin
      j:= TTwoCodes(firm.FirmDiscModels[i]).ID2; // код шаблона
      dprtName:= Cache.DiscountModels[j].Name;
      if (i>0) then dprtName:= ' / '+dprtName;
      sCred:= sCred+dprtName;
    end;
                                                        // добавлена строка !!!
    Stream.WriteStr(sCred);   // строка пакетов скидок (после ПЕРЕПЛАТА через интервал)

end; // if flCredProfile

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Users, 0);
  Stream.Position:= 0;
end;
//============================================ передать список счетов к/а для МП
procedure prWebArmGetFirmAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmAccountList'; // имя процедуры/функции
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
    EmplID   := Stream.ReadInt;    // код сотрудника
    ForFirmID:= Stream.ReadInt;    // код к/а

    prSetThLogParams(ThreadData, csLoadFirmAccountList, EmplID, 0,
                     'ForFirmID='+IntToStr(ForFirmID)); // логирование

    prCheckEmplRights(cekFirmDocs, EmplID, ForFirmID, empl, firm); // проверяем право пользователя

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
        '   and PInvDate>=("today"-'+sDays+')'+ // за ... дней
        '   and PINVANNULKEY="F"'+ // аннулированые не показывать
//        '   and PInvLocked="F"'+   // блокированые не показывать
        ' ORDER BY PInvDate, PInvNumber';

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
      sPos:= Stream.Position;
      Stream.WriteInt(0); // место под кол-во счетов
      j:= 0;
      GBIBS.ExecQuery;
      while not GBIBS.EOF do begin
        sid:= GBIBS.FieldByName('INVCCODE').AsInteger;
        if (sid>0) then begin             // есть накладная
          sNum:= GBIBS.FieldByName('INVCNUMBER').AsString;
          sum:= GBIBS.FieldByName('INVCSUMM').AsFloat;
          Curr:= GBIBS.FieldByName('INVCCRNCCODE').AsInteger;
        end else begin
          sNum:= '';
          sum:= GBIBS.FieldByName('PInvSumm').AsFloat;
          Curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
        end;
                                                                   // дата счета
        Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('PInvDate').AsDateTime));
        Stream.WriteInt(GBIBS.FieldByName('PInvCode').AsInteger);  // код счета
        Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString); // номер счета
        Stream.WriteInt(sID);                                      // код накладной
        Stream.WriteStr(sNum);                                     // номер накладной
        Stream.WriteDouble(sum);                                   // сумма
        Stream.WriteStr(Cache.GetCurrName(Curr, False));           // валюта
        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString); // номер контракта

        cntsGRB.TestSuspendException;
        GBIBS.Next;
        Inc(j);
      end;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
    if (j<1) then
      raise EBOBError.Create('Не найдены документы за '+sDays+' дней');

    Stream.Position:= sPos;
    Stream.WriteInt(j); // передаем кол-во

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//================================================================= сброс пароля
procedure prWebArmResetUserPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmResetUserPassword'; // имя процедуры/функции
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
       'FirmID='+IntToStr(FirmID)+#13#10'UserId='+UserCode); // логирование

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    empl:= Cache.arEmplInfo[EmplId];         // проверяем право пользователя
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
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
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
//============================================== назначить главного пользователя
procedure prWebArmSetFirmMainUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmSetFirmMainUser'; // имя процедуры/функции
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
      #13#10'UserId='+UserCode+#13#10'UserLogin='+UserLogin); // логирование

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    empl:= Cache.arEmplInfo[EmplId];             // проверяем право пользователя
    if not (empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolCustomerService)) then  // Служба поддержки
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Client:= Cache.arClientInfo[UserId];
    CliMail:= ExtractFictiveEmail(Client.Mail);
    if (CliMail='') then raise EBOBError.Create('У клиента нет email или email фиктивный');
    if not fnCheckEmail(CliMail) then
      raise EBOBError.Create('Некорректный E-mail клиента - '+Client.Mail);

    flNewUser:= (Client.Login='');
    firma:= Cache.arFirmInfo[FirmId];

    if flNewUser then begin
//      if (Client.Post='') then raise EBOBError.Create('У клиента нет должности.');
      s:= CheckClientFIO(Client.Name); // проверка соответствия ФИО пользователя шаблону
      if s<>'' then raise EBOBError.Create(s);

      if (UserLogin='') then raise EBOBError.Create(MessText(mtkNotSetLogin));
      if not fnCheckOrderWebLogin(UserLogin) then
        raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
      if not fnNotLockingLogin(UserLogin) then // проверяем, не относится ли логин к запрещенным
        raise EBOBError.Create(MessText(mtkLockingLogin, UserLogin));
        // уникальность логина в базе проверяется при добавлении пользователя
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

      if flNewUser then begin  // если новый пользователь
        if (IBS.FieldByName('rPassw').AsString='') then
          raise EBOBError.Create(MessText(mtkErrFormTmpPass));
        newpass:= IBS.FieldByName('rPassw').AsString;
        Client.Login:= UserLogin;
        Client.Password:= newpass;
      end;

      IBS.Transaction.Commit;
      IBS.Close;
      firma.SUPERVISOR:= UserID;

      s:= SetMainUserToGB(FirmID, UserId, Date()); // запись в Grossbee
      if (s<>'') then prMessageLOGS(nmProc+': '+s);

      if firma.IsFinalClient then try // задать валюту (грн)
        if not IBS.Transaction.InTransaction then IBS.Transaction.StartTransaction;
        IBS.SQL.Text:= 'UPDATE WEBORDERCLIENTS SET WOCLSEARCHCURRENCY='+
                       cStrUAHCurrCode+' where WOCLCODE='+UserCode;
        IBS.ExecQuery;
        if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
        IBS.Close;
        Client.SearchCurrencyID:= cUAHCurrency;
                                 // задать доставку (самовывоз)
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

    if flNewUser then try // если новый клиент - пишем логин в Grossbee
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
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                   работа с заявками на регистрацию
//******************************************************************************
//================================================================ список заявок
procedure prWebArmGetOrdersToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetOrdersToRegister'; // имя процедуры/функции
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

      if not (empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolCustomerService)) then // Служба поддержки
        raise EBOBError.Create(MessText(mtkNotRightExists));

      s:= '';                                        // если не указ.фильтр - все
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
        #13#10'OREGFIRMNAME LIKE='+s1+#13#10'OREGDPRTCODE='+IntToStr(i)+#13#10+s); // логирование
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
    Stream.WriteInt(aeSuccess); // сначала знак того, что запрос обработан корректно
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
    if Count<1 then raise EBOBError.Create('Заявки по заданным критериям не найдены.');
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
//========================================================== аннулировать заявку
procedure prWebArmAnnulateOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmAnnulateOrderToRegister'; // имя процедуры/функции
var IBS: TIBSQL;
    IBD: TIBDatabase;
    OREGCODE,EmplId: integer;
    OREGCOMMENT: String;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try                                                  // тут всякие проверки
    EmplId:= Stream.ReadInt;
    OREGCODE:= Stream.ReadInt;
    OREGCOMMENT:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csWebArmAnnulateOrderToRegister, EmplId, 0,
      'OREGCODE='+IntToStr(OREGCODE)+#13#10'OREGCOMMENT='+OREGCOMMENT); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    empl:= Cache.arEmplInfo[EmplId];
    if not (empl.UserRoleExists(rolCustomerService) or empl.UserRoleExists(rolUiK)) then // Служба поддержки
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if OREGCOMMENT='' then raise EBOBError.Create('Не указана причина аннулирования заявки.');

    IBD:= cntsORD.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
    IBS.SQL.Text:= 'SELECT OREGSTATE, OREGDPRTCODE FROM ORDERTOREGISTER WHERE OREGCODE='+IntToStr(OREGCODE);
    IBS.ExecQuery;
    if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundRegOrd));
    if IBS.FieldByName('OREGSTATE').AsInteger>0 then
      raise EBOBError.Create(MessText(mtkRegOrdAddOrAnn));
    IBS.Close;
                                   // все проверки пройдены, аннулируем
    fnSetTransParams(IBS.Transaction, tpWrite, True);
    IBS.SQL.Text:= 'update ORDERTOREGISTER set OREGSTATE=2,'+ // признак отклоненной заявки
      ' OREGPROCESSINGTIME=:OREGPROCESSINGTIME, OREGCOMMENT=:OREGCOMMENT,'+
      ' OREGUSERNAME=:OREGUSERNAME WHERE OREGCODE='+IntToStr(OREGCODE);
    IBS.ParamByName('OREGPROCESSINGTIME').AsdateTime:= now();
    IBS.ParamByName('OREGCOMMENT').AsString:= OREGCOMMENT;
    IBS.ParamByName('OREGUSERNAME').AsString:= empl.EmplShortName;
    IBS.ExecQuery;
    IBS.Transaction.Commit;
    IBS.Close;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(IBS);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end;
//=============================================================== принять заявку
procedure prWebArmRegisterOrderToRegister(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmRegisterOrderToRegister'; // имя процедуры/функции
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
  try                                  // тут всякие проверки
    EmplId:= Stream.ReadInt;
    OREGCODE:= Stream.ReadInt;
    UserLogin:= Stream.ReadStr;
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmRegisterOrderToRegister, EmplId, 0, 'OREGCODE='+IntToStr(OREGCODE)+
      #13#10'UserLogin='+UserLogin+#13#10'UserID='+UserCode+#13#10'FirmID='+FirmCode); // логирование

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    empl:= Cache.arEmplInfo[EmplId];
    if not (empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolCustomerService)) then // Служба поддержки
      raise EBOBError.Create(MessText(mtkNotRightExists));

    UserCode:= IntToStr(UserID);
    FirmCode:= IntToStr(FirmID);
    firm:= Cache.arFirmInfo[FirmID];
    flNewFirm:= StrToIntDef(firm.NUMPREFIX, 0)<1; // новая Web-фирма
    flNewUser:= True;
    if not flNewFirm then begin// если Web-фирма есть
      for i:= Low(firm.FirmClients) to High(firm.FirmClients) do
        if Cache.ClientExist(firm.FirmClients[i]) and
          (Cache.arClientInfo[firm.FirmClients[i]].Login<>'') then begin
          flNewUser:= False; // если есть хоть один Web-клиент
          break;
        end;
    end else if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);

    if flNewUser then begin // если новый Web-клиент
      Client:= Cache.arClientInfo[UserID];
      if (Client.Post='') then raise EBOBError.Create('У клиента нет должности.');
      if (Client.Mail='') then raise EBOBError.Create('У клиента нет email');
      if (UserLogin='') then raise EBOBError.Create(MessText(mtkNotSetLogin));
      if not fnCheckEmail(Client.Mail) then
        raise EBOBError.Create('Некорректный E-mail клиента - '+Client.Mail);
      if not fnCheckOrderWebLogin(UserLogin) then
        raise EBOBError.Create(MessText(mtkNotValidLogin, IntToStr(Cache.CliLoginLength)));
      if not fnNotLockingLogin(UserLogin) then // проверяем, не относится ли логин к запрещенным
        raise EBOBError.Create(MessText(mtkLockingLogin, UserLogin));
          // уникальность логина в базе проверяется при добавлении пользователя
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

      fnSetTransParams(IBS.Transaction, tpWrite); // готовимся писать
      s:= '';
      if flNewUser then begin // если новый клиент
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
        comment:= 'Заявка оформлена на клиента с логином '+UserLogin;
        Client.Login:= UserLogin;
        Client.Password:= newpass;
        s:= prSendMailWithClientPassw(kcmRegister, Client.Login, Client.Password, Client.Mail, ThreadData);

      end else begin
        newpass:= 'Заявка закрыта по контрагенту'; // сообщение юзеру
        comment:= newpass+' '+firm.Name;
      end;
      comment:= comment+' пользователем '+empl.EmplShortName;
      if s<>'' then comment:= comment+', '+s;
                                          // все проверки пройдены, регистрируем
      with ibs.Transaction do if not InTransaction then StartTransaction;
      IBS.SQL.Text:= 'update ORDERTOREGISTER set OREGSTATE=1,'+ // признак принятой заявки
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

    if flNewUser then try // если новый клиент - пишем логин в Grossbee
      IBD:= cntsGRB.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
      IBS.SQL.Text:= 'UPDATE PERSONS SET PRSNLOGIN=:login WHERE PRSNCODE='+UserCode;
      IBS.ParamByName('login').AsString:= UserLogin;
      IBS.ExecQuery;
      if IBS.Transaction.InTransaction then IBS.Transaction.Commit;
      IBS.Close;
      s:= SetMainUserToGB(FirmID, UserId, Date(), IBS); // запись в Grossbee
      if (s<>'') then prMessageLOGS(nmProc+': '+s);
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    if flNewUser then Cache.TestClients(UserID, true, false, true); // обновляем параметры клиента и фирмы в кэше

    Stream.Clear;
    Stream.WriteInt(aeSuccess);  // знак того, что запрос обработан корректно
//    Stream.WriteBool(flNewUser); // признак нового пользователя
    Stream.WriteStr(comment);    // сообщение
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;

//******************************************************************************
//                       работа с регионами
//******************************************************************************
//============================================================== список регионов
procedure prWebArmGetRegionalZones(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetRegionalZones'; // имя процедуры/функции
var ibs: TIBSQL;
    IBD: TIBDatabase;
    Count, EmplId, sPos: integer;
begin
  Stream.Position:= 0;
  ibs:= nil;
  IBD:= nil;
  try
    EmplId:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWebArmGetRegionalZones, EmplId, 0, ''); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select * from REGIONALZONES where not RGZNNAME="" order by RGZNNAME';
    ibs.ExecQuery;
    if (IBS.Bof and IBS.Eof) then raise Exception.Create(MessText(mtkNotValidParam));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // сначала знак того, что запрос обработан корректно
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
//=========================================================== добавление региона
procedure prWebArmInsertRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmInsertRegionalZone'; // имя процедуры/функции
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
      #13#10'ZoneName='+ZoneName+#13#10'idprt='+IntToStr(idprt)); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolManageSprav) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (ZoneName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if (email='') then raise EBOBError.Create('Не задан Email.');
    if (idprt<1) then raise EBOBError.Create('Не задано подразделение.');

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
                                // обрезаем текстовые значения по размерам полей
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
    Stream.WriteInt(aeSuccess); // сначала знак того, что запрос обработан корректно
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
  Stream.Position:= 0;
end;
//============================================================= удаление региона
procedure prWebArmDeleteRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmDeleteRegionalZone'; // имя процедуры/функции
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

    prSetThLogParams(ThreadData, csWebArmDeleteRegionalZone, EmplId, 0, 'zcode='+IntToStr(zcode)); // логирование

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
    Stream.WriteInt(aeSuccess); // сначала знак того, что запрос обработан корректно
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
end;
//============================================================ изменение региона
procedure prWebArmUpdateRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmUpdateRegionalZone'; // имя процедуры/функции
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
      #13#10'email='+email+#13#10'ZoneName='+ZoneName+#13#10'idprt='+IntToStr(idprt)); // логирование

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
                                // обрезаем текстовые значения по размерам полей
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
    Stream.WriteInt(aeSuccess); // сначала знак того, что запрос обработан корректно
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFreeIBSQL(ibs);
  cntsORD.SetFreeCnt(IBD);
end;

//******************************************************************************
//                          подбор запчастей
//******************************************************************************

//******************************************************************************
//                         Товары, атрибуты
//******************************************************************************
//======================================= (+ Web) Список групп атрибутов системы
procedure prGetListAttrGroupNames(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetListAttrGroupNames'; // имя процедуры/функции
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
    SysID:= Stream.ReadInt;  // код системы - игнорируем

    if (FirmID<1) then command:= csGetListAttrGroupNames else command:= csOrdGetListAttrGroupNames;

    prSetThLogParams(ThreadData, command, UserId, FirmID, 'SysID='+IntToStr(SysID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    pos:= Stream.Position;
    Stream.WriteInt(0);  // место под кол-во групп
    //------------------- Список групп атрибутов Moto (TStringList) not Free !!!
    lst:= Cache.AttrGroups.GetListAttrGroups(constIsMoto);
    if Assigned(lst) and (lst.Count>0) then begin
      for i:= 0 to lst.Count-1 do begin
        Stream.WriteInt(Integer(lst.Objects[i]));  // код
        Stream.WriteStr(lst[i]);                   // название
        Stream.WriteBool(False);                   // признак старой группы атрибутов
        Inc(iCount);
      end;
    end;

    //------------------- Список групп атрибутов Grossbee (TList) not Free !!!
    with Cache.GBAttributes.Groups.ItemsList do begin
      for i:= 0 to Count-1 do begin
        attgr:= Items[i];
        if (attgr.Links.LinkCount<1) then Continue; // пропускаем группы атрибутов без товаров
        flNew:= (attgr.SrcID=1);
        Stream.WriteInt(attgr.ID+cGBattDelta); // код со сдвигом
        Stream.WriteStr(attgr.Name);           // название
        Stream.WriteBool(flNew);               // признак новой группы атрибутов
        Inc(iCount);
      end;
    end;

    if (iCount<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Position:= pos;
    Stream.WriteInt(iCount);  // кол-во групп
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================================== (+ Web) Список атрибутов группы
procedure prGetListGroupAttrs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetListGroupAttrs'; // имя процедуры/функции
var UserID, FirmID, grpID, i, ii, j, jj, pos, command: Integer;
    errmess: String;
    lst: TList;
begin
  Stream.Position:= 0;
  lst:= nil;
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    grpID:= Stream.ReadInt;  // код группы атрибутов

    if (FirmID<1) then command:= csGetListGroupAttrs else command:= csOrdGetListGroupAttrs;

    prSetThLogParams(ThreadData, command, UserId, FirmID, 'grpID='+IntToStr(grpID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if (grpID>cGBattDelta) then begin //----------------- атрибуты Grossbee
      grpID:= grpID-cGBattDelta; // снимаем сдвиг кодов
      if not Cache.GBAttributes.Groups.ItemExists(grpID) then
        raise EBOBError.Create(MessText(mtkNotFoundAttGr, IntToStr(grpID)));

      lst:= Cache.GBAttributes.GetGBGroupAttsList(grpID);
      if (lst.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundData));
      Stream.WriteInt(lst.Count);       // кол-во атрибутов
      for i:= 0 to lst.Count-1 do with TGBAttribute(lst[i]) do begin
        Stream.WriteInt(ID+cGBattDelta);   // код атрибута со сдвигом
        Stream.WriteStr(Name);   // название
        Stream.WriteByte(SrcID); // Тип
        with Links.ListLinks do begin // список линков на значения атрибута
          Stream.WriteInt(Count);                     // Количество
          for ii:= 0 to Count-1 do begin
            Stream.WriteInt(GetLinkID(Items[ii])+cGBattDelta); // код значения со сдвигом
            Stream.WriteStr(GetLinkName(Items[ii]));  // само значение
          end;
        end;
      end; // for

    end else begin                                       // атрибуты ORD
      if not Cache.AttrGroups.ItemExists(grpID) then
        raise EBOBError.Create(MessText(mtkNotFoundAttGr, IntToStr(grpID)));

      lst:= Cache.AttrGroups.GetAttrGroup(grpID).GetListGroupAttrs; // Список атрибутов группы (TList)
      if (lst.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

      Stream.WriteInt(lst.Count);       // кол-во атрибутов
      for i:= 0 to lst.Count-1 do with TAttributeItem(lst[i]) do begin
        Stream.WriteInt(ID);        // код
        Stream.WriteStr(Name);      // название
        Stream.WriteByte(TypeAttr); // Тип
        with ListValues do begin    // значения атрибутов
          pos:= Stream.Position;
          Stream.WriteInt(0);                  // место под количество
          jj:= 0;
          for ii:= 0 to Count-1 do begin
            j:= Integer(Objects[ii]);
            if not Cache.Attributes.GetAttrVal(j).State then Continue; // пропускаем неиспользуемые
            Stream.WriteInt(j);           // код значения
            Stream.WriteStr(Strings[ii]); // само значение
            inc(jj);
          end;
          Stream.Position:= pos;
          Stream.WriteInt(jj);  // Количество
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
//=============================================== параметры товара для просмотра
procedure prGetWareInfoView(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareInfoView'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    WareID:= Stream.ReadInt;  // код товара
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt; // <0 - узел Motul
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
      Stream.WriteInt(aeSuccess);  // Передаем параметры товара
      Stream.WriteStr(ware.Name);          // наименование
      Stream.WriteBool(ware.IsSale);       // признак распродажи
      Stream.WriteBool(ware.IsNonReturn);  // признак невозврата
      Stream.WriteBool(ware.IsCutPrice);   // признак уценки

      aCode:= ware.GetActionParams(ActTitle, ActText);
      Stream.WriteInt(aCode);         // код акции
      Stream.WriteStr(ActTitle);      // заголовок
      Stream.WriteStr(ActText);       // текст

      Stream.WriteStr(ware.PrDirectName);  // название направления по продуктам
      Stream.WriteStr(ware.BrandNameWWW);  // бренд для файла логотипа
      Stream.WriteStr(ware.BrandAdrWWW);   // адрес ссылки на сайт бренда
      Stream.WriteStr(ware.WareBrandName); // бренд
      Stream.WriteDouble(ware.divis);      // кратность
      Stream.WriteStr(ware.MeasName);      // ед.изм.
      Stream.WriteStr(ware.Comment);       // описание


      if ware.IsINFOgr then begin
        Stream.WriteInt(0);  // нет атрибутов
        Stream.WriteStr(''); // условия - нет
        Stream.WriteStr(''); // критерии- нет
        Stream.WriteInt(-1); // нет рисунков

      end else begin
        List:= ware.GetWareAttrValuesView;
        List1:= ware.GetWareGBAttValuesView;
        try
          Stream.WriteInt(List.Count+List1.Count); // кол-во атрибутов
          // список названий и значений атрибутов ORD товара (TStringList)
          with List do for i:= 0 to Count-1 do begin
            Stream.WriteStr(Names[i]);                    // название атрибута
            Stream.WriteStr(ExtractParametr(Strings[i])); // значение атрибута
          end;
          // список названий и значений атрибутов Grossbee (TStringList)
          with List1 do for i:= 0 to Count-1 do begin
            Stream.WriteStr(Names[i]);                    // название атрибута
            Stream.WriteStr(ExtractParametr(Strings[i])); // значение атрибута
          end;
        finally
          List.Clear;
          List1.Clear;
        end;

        s:= '';
        if (ModelID>0) then try               // ----------------------- двигатель
          if IsEngine and (NodeID>0) and Cache.FDCA.Engines.ItemExists(ModelID)
            and Cache.FDCA.AutoTreeNodesSys[constIsAuto].NodeExists(NodeID) then begin
              Engine:= Cache.FDCA.Engines.GetEngine(ModelID);
              List:= Engine.GetEngNodeWareUsesView(NodeID, aiWares, sFilters);
          end else if not IsEngine and       // --------------------------- модель
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
        Stream.WriteStr(s); // условия

        s:= '';
        List:= ware.GetWareCriValuesView;
        with List do try
          if (Count>0) then s:= Text;
        finally Clear; end;
        Stream.WriteStr(s); // критерии

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
        Stream.WriteInt(j);  // кол-во рисунков
        Stream.Position:= Stream.Size; // если будем еще добавлять инфо по товару
      end; // if not ware.IsINFOgr
    finally
      prSetThLogParams(ThreadData, command, UserId, FirmID, sLog);
    end;

    if (FirmId=IsWe) then //------------------------------ Webarm
      Stream.WriteInt(0)  // заглушка блока семафоров

    else try              //------------------------------ Web
      if ware.IsPrize then begin //-------------------------------- цены Гроссби
        currID:= Cache.BonusCrncCode;
        curr:= ware.SellingPrice(FirmID, currID, contID);
        SetLength(prices, 3);
        for i:= 0 to High(prices) do prices[i]:= curr;
      end else begin
        currID:= Cache.arClientInfo[UserID].SEARCHCURRENCYID; // берем валюту из настроек пользователя (пока)
        prices:= ware.CalcFirmPrices(FirmID, currID, contID); // цены (0- Розница, 1- со скидкой, 2- со след.скидкой)
      end;

      ffp:= TForFirmParams.Create(FirmID, UserID, 0, currID, contID);
      //------------------------ запись в Stream блока семафоров наличия товаров
      prSaveWareRestsExists(Stream, ffp, aiWares);

      flNews:= ware.IsPrize and ware.IsNews;
      flCatchMom:= ware.IsPrize and ware.IsCatchMom;
      price:= 0; // предыдущая цена для Лови момент
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
          price:= GBIBS.FieldByName('prev').AsFloat; // пред.цена в Euro
          curr:= Cache.Currencies.GetCurrRate(Cache.BonusCrncCode);
          if fnNotZero(curr) then                       // пред.цена в бонусах
            price:= price*Cache.Currencies.GetCurrRate(cDefCurrency)/curr;
          price:= RoundToHalfDown(price);
        end;
      finally
        prFreeIBSQL(GBIBS);
        cntsGRB.SetFreeCnt(GBIBD);
      end;

      //------------------------------------------------------ передаем в CGI
      Stream.WriteBool(flNews);      // Новинка
      Stream.WriteBool(flCatchMom);  // Лови момент
      Stream.WriteStr(Cache.GetCurrName(currID, True)); // валюта
      Stream.WriteDouble(price);     // пред.цена в бонусах для Лови момент или 0
                          // цены (0- Розница, 1- со скидкой, 2- со след.скидкой)
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
//============================================== параметры товаров для сравнения
procedure prGetCompareWaresInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCompareWaresInfo'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    WareCount:= Stream.ReadInt;  // входное кол-во товаров

    prSetThLogParams(ThreadData, csGetCompareWaresInfo, UserId, FirmID,
      'WareCount='+IntToStr(WareCount)+#13#10'ContID='+IntToStr(ContID));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    ffp:= TForFirmParams.Create(FirmID, UserID, 0, 0, contID);
    if not ffp.ForClient then ffp.CurrID:= cDefCurrency; // код валюты сравнения

    WaresList:= fnCreateStringList(True, dupIgnore, WareCount); // список с проверкой на дубликаты кодов товаров  ???

    for i:= 0 to WareCount-1 do begin           // принимаем коды товаров
      WareID:= Stream.ReadInt;
      if Cache.WareExist(WareID) then begin     // проверка существования товара
        Ware:= Cache.GetWare(WareID);
        if not Ware.IsArchive then begin
          if (agID<1) then agID:= Ware.AttrGroupID;    // определяем код группы атрибутов
          if (aggID<1) then aggID:= Ware.GBAttGroup;   // определяем код группы атрибутов Grossbee
          if ((agID>0) and (agID=Ware.AttrGroupID)) or // потом берем только с этой группой
            ((aggID>0) and (aggID=Ware.GBAttGroup)) then
            WaresList.AddObject(Ware.Name, Ware);      // в Object - ссылка на товар
        end;
      end;
    end;
    if ((agID+aggID)<1) or (WaresList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotParams));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient)); // наименование валюты сравнения

//--------------------------------------------------------------------- атрибуты
    lst:= Cache.AttrGroups.GetAttrGroup(agID).GetListGroupAttrs;
    lstg:= Cache.GBAttributes.GetGBGroupAttsList(aggID);
    Stream.WriteInt(lst.Count+lstg.Count);         // кол-во атрибутов

    with lst do try // список атрибутов группы ORD (TList)
      setLength(attCodes, Count);     // порядок кодов атрибутов
      for j:= 0 to Count-1 do begin
        attCodes[j]:= GetDirItemID(Items[j]);      // запоминаем порядок кодов атрибутов
        Stream.WriteStr(GetDirItemName(Items[j])); // передаем название атрибута
      end;
    finally Free; end;

    with lstg do try // список атрибутов группы Grossbee (TList)
      setLength(attgCodes, Count);     // порядок кодов атрибутов
      for j:= 0 to Count-1 do begin
        attgCodes[j]:= GetDirItemID(Items[j]);     // запоминаем порядок кодов атрибутов Grossbee
        Stream.WriteStr(GetDirItemName(Items[j])); // передаем название атрибута
      end;
    finally Free; end;
//------------------------------------------------------------------------------
    Stream.WriteInt(WaresList.Count); // исходящее кол-во товаров
    setLength(aiWares, WaresList.Count);
    for i:= 0 to WaresList.Count-1 do begin // передаем параметры товара
      Ware:= TWareInfo(WaresList.Objects[i]);
      aiWares[i]:= Ware.ID;
      Stream.WriteInt(Ware.ID);            // код товара
      Stream.WriteStr(Ware.Name);          // наименование
      Stream.WriteBool(Ware.IsSale);       // признак распродажи
      Stream.WriteBool(Ware.IsNonReturn);  // признак невозврата
      Stream.WriteBool(Ware.IsCutPrice);   // признак уценки
      Stream.WriteStr(Ware.PrDirectName);  // название направления по продуктам
      Stream.WriteStr(Ware.BrandNameWWW);  // бренд для файла логотипа
      Stream.WriteStr(Ware.BrandAdrWWW);   // адрес ссылки на сайт бренда
      Stream.WriteStr(Ware.WareBrandName); // бренд
      Stream.WriteDouble(Ware.divis);      // кратность
      Stream.WriteStr(Ware.MeasName);      // ед.изм.
      Stream.WriteStr(Ware.Comment);       // описание

      aCode:= Ware.GetActionParams(ActTitle, ActText);
      Stream.WriteInt(aCode);         // код акции
      Stream.WriteStr(ActTitle);      // заголовок
//      Stream.WriteStr(ActText);       // текст акции
      ActText:= Ware.GetFirstTDPictName; // здесь теперь передаем 1-ю картинку TD:
      Stream.WriteStr(ActText);          // имя папки в tdfiles / имя файла с расширением

      //---------------------------------------------------------- цены Grossbee
      if ffp.ForClient then begin
        prices:= Ware.CalcFirmPrices(FirmID, ffp.currID, contID); // цены (0- Розница, 1- со скидкой, 2- со след.скидкой)
        for j:= 0 to High(prices) do Stream.WriteDouble(prices[j]);
      end else
        Stream.WriteDouble(Ware.RetailPrice(FirmID, ffp.currID, contID));
      //---------------------- значения атрибутов в нужном порядке
      with Ware.GetWareAttrValuesByCodes(AttCodes) do try // (TStringList)
        for j:= 0 to Count-1 do Stream.WriteStr(Strings[j]);
      finally Free; end;
      //---------------------- значения атрибутов Grossbee в нужном порядке
      with Ware.GetWareGBAttValuesByCodes(AttgCodes) do try // (TStringList)
        for j:= 0 to Count-1 do Stream.WriteStr(Strings[j]);
      finally Free; end;
    end; // for i:= 0 to WaresList.Count-1

    //------------------------ запись в Stream блока семафоров наличия товаров
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
//                                  модельный ряд
//******************************************************************************
//====================================== (+ Web) Получить список модельных рядов
procedure prGetModelLineList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelLineList'; // имя процедуры/функции
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
    isTops:= Stream.ReadBool;  // Топы вверх
    OnlyVisible:= Stream.ReadBool; // False - все, True - только видимые
    OnlyWithWares:= OnlyVisible;   // False - все, True - только с товарами

    if (FirmID<1) then command:= csGetModelLineList else command:= csOrdGetModelLineList;

    prSetThLogParams(ThreadData, command, UserId, FirmID, 'ManufID='+IntToStr(ManufID)+#13#10'SysID='+IntToStr(SysID));

//if flDebugCV then SysID:= constIsCV;

    if CheckNotValidManuf(ManufID, SysID, Manuf, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    Stream.Clear;
    Stream.WriteInt(aeSuccess);        // Запись списка модельных рядов в поток
    with Manuf.GetModelLinesList(SysID, isTops) do begin
      sPos:= Stream.Position;
      iCount:= 0; // счетчик - если передаем только видимые
      Stream.WriteInt(iCount);
      for i:= 0 to Count-1 do with Cache.FDCA.ModelLines[Integer(Objects[i])] do begin
        if (OnlyVisible and not (IsVisible and HasVisModels)) then Continue;
        if (OnlyWithWares and not MLHasWares) then Continue; // если нет товаров
        Stream.WriteInt(ID);                // Код модельного ряда
        Stream.WriteStr(Name);              // Наименование
        Stream.WriteBool(IsVisible);        // Признак видимости модельного ряда
        Stream.WriteBool(IsTop);            // Топ
        Stream.WriteInt(YStart);            // Год начала выпуска
        Stream.WriteInt(MStart);            // Месяц начала выпуска
        Stream.WriteInt(YEnd);              // Год окончание выпуска
        Stream.WriteInt(MEnd);              // Месяц окончание выпуска
        Stream.WriteInt(ModelsCount);       // Наличие моделей в ряду
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
//======================================================= Добавить модельный ряд
procedure prModelLineAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelLineAdd'; // имя процедуры/функции
var UserID, SysID, ManufID, fMS, fYS, fME, fYE, iCode: Integer;
    MLName, errmess: String;
    isTop, isVis: boolean;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ManufID:= Stream.ReadInt; // Код производителя авто
    MLName:= Stream.ReadStr;  // Наименование модельного ряда
    isTop:= Stream.ReadBool;
    fMS:= Stream.ReadInt;     // Месяц начала выпуска
    fYS:= Stream.ReadInt;     // Год начала
    fME:= Stream.ReadInt;     // Месяц окончания
    fYE:= Stream.ReadInt;     // Год окончания
    isVis:= Stream.ReadBool;  // Признак видимости

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
//======================================================== Удалить модельный ряд
procedure prModelLineDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelLineDel'; // имя процедуры/функции
var UserID, ModelLineID, ManufID, SysID: Integer;
    errmess: String;
    ModelLine: TModelLine;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelLineID:= Stream.ReadInt;  // Код модельного ряда

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
//======================================================= Изменить модельный ряд
procedure prModelLineEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelLineEdit'; // имя процедуры/функции
var UserID, ModelLineID, ManufID, SysID, fMS, fYS, fME, fYE: Integer;
    MLName, errmess: String;
    isTop, isVis: Boolean;
    ModelLine: TModelLine;
    Manuf: TManufacturer;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelLineID:= Stream.ReadInt;    // Код модельного ряда
    MLName:= Stream.ReadStr; // Наименование модельного ряда
    isTop:= Stream.ReadBool;
    fYS:= Stream.ReadInt;    // Год начала
    fMS:= Stream.ReadInt;    // Месяц начала выпуска
    fYE:= Stream.ReadInt;    // Год окончания
    fME:= Stream.ReadInt;    // Месяц окончания
    isVis:= Stream.ReadBool; //Признак видимости

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
//                                  модель
//******************************************************************************
//============================== (+ Web) Получить список моделей модельного ряда
procedure prGetModelLineModels(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelLineModels'; // имя процедуры/функции
var UserID, FirmID, ModelLineID, SysID, i, sPos, iCount: Integer;
    TopsUp, OnlyVisible, OnlyWithWares: Boolean;
    ModelLine: TModelLine;
    errmess, s: String;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;    
    UserID:= Stream.ReadInt;
    ModelLineID:= Stream.ReadInt;  // Код модельного ряда
    TopsUp:= Stream.ReadBool;      // Топы вверх
    OnlyVisible:= Stream.ReadBool; // False - все, True - только видимые
    OnlyWithWares:= OnlyVisible;   // False - все, True - только с товарами

    prSetThLogParams(ThreadData, csGetModelLineModels, UserId, FirmID, 'ModelLineID='+IntToStr(ModelLineID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelLine(ModelLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    Stream.Clear;                // Запись моделей модельного ряда в поток
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    iCount:= 0; // счетчик - если передаем только видимые
    Stream.WriteInt(iCount);
    with ModelLine.GetListModels(TopsUp) do if (Count>0) then begin
      for i:= 0 to Count-1 do with Cache.FDCA.Models[Integer(Objects[i])] do begin
        if (OnlyVisible and not IsVisible) then Continue;
        if (OnlyWithWares and not ModelHasWares) then Continue; // если нет товаров
        Stream.WriteInt(ID);             // Код модели
        s:= '';
        if OnlyWithWares then case SysID of
          constIsAuto, constIsMoto: begin //--------------------- auto, moto
            s:= MarksCommaText;
            if (s<>'') then s:= '('+s+')';
            if (Params.pHP>0) then s:= IntToStr(Params.pHP)+', '+s;
          end;
          constIsCV: begin                //----------------------- грузовики
            s:= MarksCommaText;
            if (s<>'') then s:= '('+s+')';
            if (Params.pValves>0) then s:= '['+Params.cvTonnOut+' т], '+s;
            if (Params.cvHPaxLO<>'') then s:= Params.cvHPaxLOout+', '+s;
          end;
          constIsAx: begin                //----------------------- оси
            if (Params.pDriveID>0) then
              s:= '('+Cache.FDCA.TypesInfoModel.InfoItems[Params.pDriveID].Name+')'; // Тип оси
            if (Params.cvHPaxLO<>'') then s:= Params.cvHPaxLOout+' кг, '+s; // Нагрузка на ось [кг]
          end;
        end; // case

        if (s<>'') then s:= '||'+s;
        Stream.WriteStr(Name+s);         // Название модели + доп.данные
        Stream.WriteBool(IsVisible);     // Видимость модели
        Stream.WriteBool(IsTop);         // Топ модель
        Stream.WriteInt(Params.pYStart); // Год начала выпуска
        Stream.WriteInt(Params.pMStart); // Месяц начала выпуска
        Stream.WriteInt(Params.pYEnd);   // Год окончания выпуска
        Stream.WriteInt(Params.pMEnd);   // Месяц окончания выпуска
        Stream.WriteInt(ModelOrderNum);  // Порядковый номер
        Stream.WriteInt(SubCode);        // Номер TecDoc (авто) / код для сайта (мото)
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
//========================================= (+ Web) Получить дерево узлов модели
procedure prGetModelTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelTree'; // имя процедуры/функции
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
    ModelID:= Stream.ReadInt;  // код модели
    flNodesWithoutWares:= Stream.ReadBool; // признак - передавать ноды без товаров

    flHideNodesWithOneChild:= not flNodesWithoutWares; // сворачивать ноды с 1 ребенком
    flHideOnlyOneLevel:= flHideNodesWithOneChild and Cache.HideOnlyOneLevel; // сворачивать только 1 уровень
    flHideOnlySameName:= flHideNodesWithOneChild and Cache.HideOnlySameName; // сворачивать только при совпадении имен

    prSetThLogParams(ThreadData, csGetModelTree, UserId, FirmID, 'ModelID='+IntToStr(ModelID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    flFromBase:= not Cache.WareLinksUnLocked; // пока кеш связок не заполнен - берем из базы
    try // список связок с видимыми нодами модели
      listNodes:= Model.GetModelNodesList(True, flFromBase);

      if not flNodesWithoutWares then // чистим ноды без товаров
        for i:= listNodes.Count-1 downto 0 do begin
          link:= listNodes[i];
          fl:= not link.NodeHasWares and not link.NodeHasPLs;
          if fl then listNodes.Delete(i);
        end;
      if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

      listParCodes:= TList.Create;
      listParCodes.Capacity:= listNodes.Count;
      for i:= 0 to listNodes.Count-1 do begin // список кодов родителей
        link:= listNodes[i];
        Node:= link.LinkPtr;
        listParCodes.Add(Pointer(Node.ParentID));
      end;

      if flHideNodesWithOneChild then  // сворачиваем ноды с 1-м ребенком
        prHideTreeNodes(listNodes, listParCodes, flHideOnlySameName, flHideOnlyOneLevel);
      if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

      Stream.Clear;
      Stream.WriteInt(aeSuccess);  // Запись дерева модели в поток
      Stream.WriteStr(Model.WebName);  // Запись названия модели в поток
      Stream.WriteBool(Model.ModelHasPLs); // признак наличия кнопки "Подбор MOTUL" у модели

      j:= 0; // счетчик строк
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
          Stream.WriteBool(link.NodeHasFilters); // признак наличия фильтров в узле модели
          Stream.WriteBool(link.NodeHasPLs);   // признак наличия кнопки "Подбор MOTUL" в узле
          Stream.WriteBool(link.NodeHasWares); // признак наличия товаров основного подбора в узле
        end;
        inc(j);
      end;
      Stream.Position:= spos;
      Stream.WriteInt(j); // кол-во переданных элементов
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
//=========================================== считать параметры модели из потока
procedure ReadModelParams(Stream: TBoBMemoryStream; mps: TModelParams);
begin
  mps.pYStart:= Stream.ReadInt;       // Год начала выпуска
  mps.pMStart:= Stream.ReadInt;       // Месяц начала выпуска
  mps.pYEnd:= Stream.ReadInt;         // Год окончания выпуска
  mps.pMEnd:= Stream.ReadInt;         // Месяц окончания выпуска
  try // если не все данные были записаны в Stream
    mps.pKW      := Stream.ReadInt;   // Мощность кВт
    mps.pHP      := Stream.ReadInt;   // Мощность ЛС
    mps.pCCM     := Stream.ReadInt;   // Тех. обьем куб.см.
    mps.pCylinders:= Stream.ReadInt;  // Количество цилиндров
    mps.pValves  := Stream.ReadInt;   // Количество клапанов на одну камеру сгорания
    mps.pBodyID  := Stream.ReadInt;   // Код, тип кузова
    mps.pDriveID := Stream.ReadInt;   // Код, тип привода
    mps.pEngTypeID:= Stream.ReadInt;  // Код, тип двигателя
    mps.pFuelID  := Stream.ReadInt;   // Код, тип топлива
    mps.pFuelSupID:= Stream.ReadInt;  // Код, система впрыска
    mps.pBrakeID := Stream.ReadInt;   // Код, тип тормозной системы
    mps.pBrakeSysID:= Stream.ReadInt; // Код, Тормозная система
    mps.pCatalID := Stream.ReadInt;   // Код, Тип катализатора
    mps.pTransID := Stream.ReadInt;   // Код, Вид коробки передач
  except
  end;
end;
//============================================== Добавить модель в модельный ряд
procedure prModelAddToModelLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelAddToModelLine'; // имя процедуры/функции
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
    MLineID:= Stream.ReadInt;  // Код модельного ряда
    pName:= Stream.ReadStr;    // Название модели

    prSetThLogParams(ThreadData, csModelAddToModelLine, UserId, 0, ' MLineID='+IntToStr(MLineID)+' pName='+pName);

    if (pName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidModelLine(MLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    Top      := Stream.ReadBool; // Топ
    isVis    := Stream.ReadBool; // видимость
    ReadModelParams(Stream, mps);
    try
      pOrdNum:= Stream.ReadInt;    // порядковый №
    except
      pOrdNum:= -1;
    end;
    try
      pTDcode:= Stream.ReadInt;    // Номер TecDoc (авто) / код для сайта (мото)
    except
      pTDcode:= 0;
    end;
    if (pTDcode<0) then pTDcode:= 0;

    errmess:= Cache.FDCA.Models.ModelAdd(pModelID, pName, isVis, Top, UserID, MLineID, mps, pOrdNum, pTDcode);
    if errmess<>'' then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(pModelID);   // Код модели
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(mps);
end;
//============================================================== Изменить модель
procedure prModelEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelEdit'; // имя процедуры/функции
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
    ModelID:= Stream.ReadInt;  // Код модели
    pName:= Stream.ReadStr;    // Название модели

    prSetThLogParams(ThreadData, csModelEdit, UserId, 0, 'ModelID='+IntToStr(ModelID)+', pName='+pName);

    if (pName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    Top      := Stream.ReadBool; // Топ
    Visible  := Stream.ReadBool; // видимость
    ReadModelParams(Stream, mps);
    try
      pOrdNum:= Stream.ReadInt;    // порядковый №
    except
      pOrdNum:= -1;
    end;
    try
      pTDcode:= Stream.ReadInt;    // Номер TecDoc (авто) / код для сайта (мото)
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
//=============================================================== Удалить модель
procedure prModelDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelDel'; // имя процедуры/функции
var UserID, ModelID, SysID: Integer;
    errmess: String;
    Model: TModelAuto; // для проверки
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // Код модели

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
//==================================================== Изменить видимость модели
procedure prModelSetVisible(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prModelSetVisible'; // имя процедуры/функции
var UserID, ModelID, SysID: Integer;
    Visible: Boolean;
    Model: TModelAuto;
    errmess: string;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // Код модели
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
//                                Бренды
//******************************************************************************
//=============================================== Получить список брендов TecDoc
procedure prGetBrandsTD(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetBrandsTD'; // имя процедуры/функции
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
    if (lstBrand.Count<1) then raise EBOBError.Create('Список брендов TecDoc пуст!');

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
//                                  Производители
//******************************************************************************
//========================== (+ Web) Получить список производителей авто/брендов
procedure prGetManufacturerList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetManufacturerList'; // имя процедуры/функции
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
      if (OnlyVisible and not  // если нет видимых моделей
        (CheckIsVisible(pTypeSys) and HasVisMLModels(pTypeSys))) then Continue;
      if (OnlyWithWares and not ManufHasWares) then Continue; // если нет товаров
      Stream.WriteInt(ID);                            // Код
      Stream.WriteStr(Name);                          // Наименование
      Stream.WriteBool(CheckIsTop(pTypeSys));         // Топ
      Stream.WriteBool(CheckHasModelLines(pTypeSys)); // Наличие модельных рядов по данной системе
      Stream.WriteBool(CheckIsTypeSys(pTypeSys));
      Stream.WriteBool(CheckIsVisible(pTypeSys));
      inc(icount);
    end;
    Stream.Position:= spos;
    Stream.WriteInt(icount);
    Stream.Position:= Stream.Size;
  end;
  //----------------------------------------
begin                                  // получить список производителей SysID:
  lst:= nil;                           //  0 - весь
  Stream.Position:= 0;                 //  1 - авто
  OnlyVisible:= False;                 //  2 - мото
  try                                  // 11 - авто, топовые позиции вверху
    FirmID:= Stream.ReadInt;           // 12 - мото, топовые позиции вверху
    UserID:= Stream.ReadInt;           // 21 - с ориг.номерами
    SysID:= Stream.ReadInt;            // 31 - с двигателями
    OnlyVisible:= Stream.ReadBool;     // False - все, True - только видимые
    OnlyWithWares:= OnlyVisible;       // False - все, True - только с товарами

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
          lst:= Cache.FDCA.Manufacturers.GetOEManufList; // сортированный список производителей с ОН;
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
//======================================================= Добавить производителя
procedure prManufacturerAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManufacturerAdd'; // имя процедуры/функции
var UserID, SysID, iCode: Integer;
    ManufName, errmess: String;
    isTop, isVis: boolean;
begin
  Stream.Position:= 0;
  iCode:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ManufName:= Stream.ReadStr; // Наименование производителя
    isTop := Stream.ReadBool; // Топ производитель
    isVis := Stream.ReadBool; // видимость

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
//======================================================== Удалить производителя
procedure prManufacturerDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManufacturerDel'; // имя процедуры/функции
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
//======================================================= Изменить производителя
procedure prManufacturerEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prManufacturerEdit'; // имя процедуры/функции
var UserID, SysID, ManufID: Integer;
    ManufName, errmess: String;
    isTop, isVis: boolean;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    ManufID:= Stream.ReadInt;;
    SysID:= Stream.ReadInt;
    ManufName:= Stream.ReadStr; // Наименование производителя
    isTop := Stream.ReadBool; // Топ производитель
    isVis := Stream.ReadBool; // Доступен пользователям

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
//                                Дерево узлов
//******************************************************************************
//======================================================== Получить дерево узлов
procedure prTNAGet(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNAGet'; // имя процедуры/функции
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
    with Cache.FDCA.AutoTreeNodesSys[SysID].NodesList do begin // Запись дерева в поток
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
//======================================================= Добавить узел в дерево
procedure prTNANodeAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANodeAdd'; // имя процедуры/функции
var UserID, ParentID, NodeID, SysID, Vis, NodeMain: Integer;
    NodeName, NodeNameSys, errmess: String;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;
    ParentID:= Stream.ReadInt;           // Код родителя
    NodeName:= Trim(Stream.ReadStr);     // Наименование узла
    NodeNameSys:= Trim(Stream.ReadStr);  // Системное наименование узла
    Vis:= Stream.ReadInt;
    NodeMain:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csTNANodeAdd, UserId, 0, 'NodeName= '+NodeName+
      ', NodeNameSys= '+NodeNameSys+', ParentID= '+IntToStr(ParentID)+#13#10'SysID='+IntToStr(SysID));

    if CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    NodeID:= -1;
    errmess:= Cache.FDCA.TreeNodeAdd(SysID, ParentID, NodeMain, NodeName, NodeNameSys, UserID, NodeID, Vis=1); // Добавление узла
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
//================================================== редактировать узел в дереве
procedure prTNANodeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANodeEdit'; // имя процедуры/функции
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
//======================================================= Удалить узел из дерева
procedure prTNANodeDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANodeDel'; // имя процедуры/функции
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
//=================================================== Запись TStringList в поток
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
//                                Двигатель
//******************************************************************************
//=============================================== (+ Web) Дерево узлов двигателя
procedure prGetEngineTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetEngineTree'; // имя процедуры/функции
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
    EngID:= Stream.ReadInt;  // код двигателя
    flNodesWithoutWares:= Stream.ReadBool; // признак - передавать ноды без товаров

    flHideNodesWithOneChild:= not flNodesWithoutWares; // сворачивать ноды с 1 ребенком
    flHideOnlyOneLevel:= flHideNodesWithOneChild and Cache.HideOnlyOneLevel; // сворачивать только 1 уровень
    flHideOnlySameName:= flHideNodesWithOneChild and Cache.HideOnlySameName; // сворачивать только при совпадении имен

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

    listNodes:= TList.Create; // список линков для обработки
    listNodes.Capacity:= nlinks.LinkCount;
    for i:= 0 to nlinks.LinkCount-1 do listNodes.Add(nlinks.ListLinks[i]);

    if not flNodesWithoutWares then // чистим ноды без товаров
      for i:= listNodes.Count-1 downto 0 do begin
        link:= listNodes[i];
        if not link.NodeHasWares then listNodes.Delete(i);
      end;
    if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    listParCodes:= TList.Create;
    listParCodes.Capacity:= listNodes.Count;
    for i:= 0 to listNodes.Count-1 do begin // список кодов родителей
      link:= listNodes[i];
      Node:= link.LinkPtr;
      listParCodes.Add(Pointer(Node.ParentID));
    end;

    if flHideNodesWithOneChild then  // сворачиваем ноды с 1-м ребенком
      prHideTreeNodes(listNodes, listParCodes, flHideOnlySameName, flHideOnlyOneLevel);
    if (listNodes.Count<1) then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);   //------------ Запись дерева двигателя в поток
    Stream.WriteStr(Eng.WebName); // Запись названия двигателя

    Stream.WriteBool(False); // заглушка (признак наличия кнопки "Подбор MOTUL" у модели)

    j:= 0; // счетчик строк
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
        Stream.WriteBool(link.NodeHasFilters); // признак наличия фильтров в узле двигателя

        Stream.WriteBool(link.NodeHasPLs);   // заглушка (признак наличия кнопки "Подбор MOTUL" в узле)
        Stream.WriteBool(link.NodeHasWares); // заглушка (признак наличия товаров основного подбора в узле)
      end;
      inc(j);
    end;
    Stream.Position:= spos;
    Stream.WriteInt(j); // кол-во переданных элементов
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
//================================ блокировка/разблокировка сотрудником в WebArm
procedure prBlockActForWebUser(BlockKind, EmplID, UserID: integer; flFirm: Boolean;
                               reason: String; ThreadData: TThreadData);
const nmProc = 'prBlockActForWebUser'; // имя процедуры/функции
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
    if not empl.UserRoleExists(rolManageSprav) then // только админы
      raise EBOBError.Create(MessText(mtkNotRightExists));

    case BlockKind of
      cbBlockedByEmpl: begin
          txtlog:= ' blocked';
          unpref:= '';
          regMailKind:= pcEmpl_list_FinalBlock;
        end;
      cbNotBlocked   : begin
          txtlog:= ' unblocked';
          unpref:= 'раз';
          regMailKind:= pcEmpl_list_UnBlock;
        end;
    end;
    if (reason<>'') then reason:= #13#10'reason='+reason;

    if flFirm then begin  //----------------------------------------------- firm
      FirmID:= UserID;
      if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
      WebFirm:= Cache.arFirmInfo[FirmID];
      txtuser:= 'контрагент';
      case BlockKind of
        cbBlockedByEmpl: if WebFirm.Blocked then raise EBOBError.Create(txtuser+' блокирован');
        cbNotBlocked   : if not WebFirm.Blocked then raise EBOBError.Create(txtuser+' не блокирован');
      end;             // ключевой текст блокировки (для GetUserSearchCount) ???
      sParam:= 'WebFirmID='+IntToStr(FirmID)+reason+#13#10'WebFirm '+IntToStr(FirmID)+txtlog;

    end else begin        //----------------------------------------------- user
      if not Cache.ClientExist(UserID) then raise EBOBError.Create(MessText(mtkNotClientExist));
      WebUser:= Cache.arClientInfo[UserID];
      FirmID:= WebUser.FirmID;
      if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
      WebFirm:= Cache.arFirmInfo[FirmID];
      txtuser:= 'клиент';
      case BlockKind of
        cbBlockedByEmpl: if WebUser.Blocked then raise EBOBError.Create(txtuser+' блокирован');
        cbNotBlocked   : if not WebUser.Blocked then raise EBOBError.Create(txtuser+' не блокирован');
      end;             // ключевой текст блокировки (для GetUserSearchCount) ???
      sParam:= 'WebUserID='+IntToStr(UserID)+reason+#13#10'WebUser '+IntToStr(UserID)+txtlog;

      if not SaveClientBlockType(cbBlockedByEmpl, UserID, BlockTime, EmplID) then // блокировка клиента в базе
        raise EBOBError.Create('ошибка блокировки '+txtuser+'а');

      with WebUser do try // в кеше
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

//------------------------------- рассылаем извещения о блокировке/разблокировке
  Body:= TStringList.Create;
  with Cache do try    //---------------------------------- по списку рассылки
    regMail:= '';
    Body.Add(FormatDateTime(cDateTimeFormatY4S, Now())+' в СВК '+unpref+'блокирован');
    Body.Add('  сотрудником '+empl.EmplShortName);
    if not flFirm then
      Body.Add('  клиент с логином `'+WebUser.Login+'` (код '+IntToStr(WebUser.ID)+')');
    Body.Add('  контрагент '+WebFirm.Name+' (код '+IntToStr(WebFirm.ID)+')');
    if (reason<>'') then Body.Add('причина: '+reason);
    s:= WebFirm.GetFirmManagersString([fmpName, fmpShort, fmpPref]);
    if (s<>'') then Body.Add('  '+s);

    regMail:= Cache.GetConstEmails(regMailKind, errmess, FirmID);
    if (regMail='') then // в s запоминаем строку в письмо контролю
      s:= 'Сообщение о '+unpref+'блокировке '+txtuser+'а не отправлено - не найдены E-mail рассылки'
    else begin
      s:= n_SysMailSend(regMail, unpref+'блокировка '+txtuser+'а', Body, nil, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // если не записалось в файл
        fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', 'ошибка рассылки', s, '');
        s:= 'Ошибка отправки сообщения о '+unpref+'блокировке '+txtuser+'а на Email: '+regMail;
      end else s:= 'Сообщение о '+unpref+'блокировке '+txtuser+'а отправлено на Email: '+regMail;
    end;
                             //-------------------------- контролю
    if (s<>'') then Body.Add(#10+s);
    if (errmess<>'') then Body.Add(#10+errmess); // сообщение о ненайденных адресах

    regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
    if (errmess<>'') then Body.Add(errmess);

    if (regMail='') then regMail:= GetSysTypeMail(constIsAuto); // на всяк.случай

    if (regMail<>'') then begin
      s:= n_SysMailSend(regMail, unpref+'блокировка '+txtuser+'а', Body, nil, '', '', True);
      if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
        prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
    end;

    prMessageLOGS(nmProc+': '+unpref+'блокировка '+txtuser+'а');  // пишем в лог
    for i:= 0 to Body.Count-1 do if (trim(Body[i])<>'') then
      prMessageLOGS(StringReplace(Body[i], #10, '', [rfReplaceAll]));
  except
    on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, 'ошибка рассылки', E.Message, '');
  end;
  prFree(Body);
end;

//=========================================================== блокировка клиента
procedure prBlockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prBlockWebUser'; // имя процедуры/функции
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
      if not empl.UserRoleExists(rolManageSprav) then // только админы
        raise EBOBError.Create(MessText(mtkNotRightExists));

      if WebUser.Blocked then raise EBOBError.Create('пользователь блокирован');

      if not SaveClientBlockType(cbBlockedByEmpl, UserID, BlockTime, EmplID) then // блокировка клиента в базе
        raise EBOBError.Create('ошибка блокировки клиента');
                      // ключевой текст блокировки (для GetUserSearchCount) ???
      sParam:= sParam+#13#10'WebUser '+IntToStr(UserID)+' blocked';
    finally
      prSetThLogParams(ThreadData, 0, EmplID, 0, sParam);
    end;

    with WebUser do try // в кеше
      CS_client.Enter;
      Blocked:= True;
      CountSearch:= 0;
      CountQty:= 0;
      CountConnect:= 0;
    finally
      CS_client.Leave;
    end;

//------------------------------------------ рассылаем извещения о блокировке
    Body:= TStringList.Create;
    with Cache do try    //---------------------------------- по списку рассылки
      regMail:= '';
      Body.Add(FormatDateTime(cDateTimeFormatY4S, Now())+' блокирована');
      Body.Add('  сотрудником '+empl.EmplShortName);
      Body.Add('  учетная запись в системе заказов');
      Body.Add('пользователя с логином `'+WebUser.Login+'` (код '+IntToStr(WebUser.ID)+')');
      Body.Add('  контрагент '+WebUser.FirmName);
      if (reason<>'') then Body.Add('причина: '+reason);
      if FirmExist(FirmID) then begin
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
        if (s<>'') then Body.Add('  '+s);
      end;

      regMail:= Cache.GetConstEmails(pcEmpl_list_UnBlock, errmess, FirmID);
      if (regMail='') then // в s запоминаем строку в письмо контролю
        s:= 'Сообщение о блокировке клиента не отправлено - не найдены E-mail рассылки'
      else begin
        s:= n_SysMailSend(regMail, 'Блокировка учетной записи пользователя', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // если не записалось в файл
          fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', 'ошибка рассылки', s, '');
          s:= 'Ошибка отправки сообщения о блокировке клиента на Email: '+regMail;
        end else s:= 'Сообщение о блокировке клиента отправлено на Email: '+regMail;
      end;
                               //-------------------------- контролю (Щербакову)
      if (s<>'') then Body.Add(#10+s);
      if (errmess<>'') then Body.Add(#10+errmess); // сообщение о ненайденных адресах

      regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
      if (errmess<>'') then Body.Add(errmess);

      if (regMail='') then regMail:= GetSysTypeMail(constIsAuto); // Щербакову (на всяк.случай)

      if (regMail<>'') then begin
        s:= n_SysMailSend(regMail, 'Блокировка учетной записи пользователя', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
          prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
      end;

      prMessageLOGS(nmProc+': блокировка клиента');  // пишем в лог
      for i:= 0 to Body.Count-1 do if (trim(Body[i])<>'') then
        prMessageLOGS(StringReplace(Body[i], #10, '', [rfReplaceAll]));
    except
      on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, 'ошибка рассылки', E.Message, '');
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
//======================================================== разблокировка клиента
procedure prUnblockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prUnblockWebUser'; // имя процедуры/функции
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
      if not empl.UserRoleExists(rolManageSprav) then // только админы
        raise EBOBError.Create(MessText(mtkNotRightExists));

      if not WebUser.Blocked then
        raise EBOBError.Create('пользователь не блокирован');
                                                 // разблокировка клиента в базе
      if not SaveClientBlockType(cbUnBlockedByEmpl, UserID, BlockTime, EmplID) then
        raise EBOBError.Create('ошибка разблокировки клиента');
                      // ключевой текст разблокировки (для GetUserSearchCount) ???
      sParam:= sParam+#13#10'WebUser '+IntToStr(UserID)+' unblocked';
    finally
      prSetThLogParams(ThreadData, csUnblockWebUser, EmplID, 0, sParam);
    end;

    with WebUser do try // в кеше
      CS_client.Enter;
      Blocked:= False;
      CountSearch:= 0;
      CountQty:= 0;
      CountConnect:= 0;
    finally
      CS_client.Leave;
    end;

//------------------------------------------ рассылаем извещения о разблокировке
    Body:= TStringList.Create;
    with Cache do try    //---------------------------------- по списку рассылки
      regMail:= '';
      Body.Add(FormatDateTime(cDateTimeFormatY4S, Now())+' разблокирована');
      Body.Add('  сотрудником '+empl.EmplShortName);
      Body.Add('  учетная запись в системе заказов');
      Body.Add('пользователя с логином `'+WebUser.Login+'` (код '+IntToStr(WebUser.ID)+')');
      Body.Add('  контрагент '+WebUser.FirmName);
      if FirmExist(FirmID) then begin
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
        if (s<>'') then Body.Add('  '+s);
      end;

      regMail:= Cache.GetConstEmails(pcEmpl_list_UnBlock, errmess, FirmID);
      if (regMail='') then // в s запоминаем строку в письмо контролю
        s:= 'Сообщение о разблокировке клиента не отправлено - не найдены E-mail рассылки'
      else begin
        s:= n_SysMailSend(regMail, 'Разблокировка учетной записи пользователя', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // если не записалось в файл
          fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', 'ошибка рассылки', s, '');
          s:= 'Ошибка отправки сообщения о разблокировке клиента на Email: '+regMail;
        end else s:= 'Сообщение о разблокировке клиента отправлено на Email: '+regMail;
      end;
                               //-------------------------- контролю (Щербакову)
      if (s<>'') then Body.Add(#10+s);
      if (errmess<>'') then Body.Add(#10+errmess); // сообщение о ненайденных адресах

      regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
      if (errmess<>'') then Body.Add(errmess);

      if regMail='' then regMail:= GetSysTypeMail(constIsAuto); // Щербакову (на всяк.случай)

      if (regMail<>'') then begin
        s:= n_SysMailSend(regMail, 'Разблокировка учетной записи пользователя', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
          prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
      end;

      prMessageLOGS(nmProc+': разблокировка клиента');  // пишем в лог
      for i:= 0 to Body.Count-1 do if (trim(Body[i])<>'') then
        prMessageLOGS(StringReplace(Body[i], #10, '', [rfReplaceAll]));
    except
      on E: Exception do fnWriteToLog(ThreadData, lgmsSysError, nmProc, 'ошибка рассылки', E.Message, '');
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
//==== используется для сортировки объектов типа TSearchWareOrOnum в TObjectList
function SearchWareOrONSortCompare(Item1, Item2: Pointer): Integer;
var sw1, sw2: TSearchWareOrOnum;
    s1, s2: String;
    ware1, ware2: TWareInfo;
begin
  try
    sw1:= TSearchWareOrOnum(Item1);
    sw2:= TSearchWareOrOnum(Item2);
    if (sw1.IsWare<>sw2.IsWare) then begin // товары - выше ОН
      if sw1.IsWare then Result:= -1 else Result:= 1;

    end else if (sw1.RestSem<>sw2.RestSem) then begin // с остатками - выше

      if (sw1.RestSem=3) and (sw2.RestSem=2) then Result:= 1       // 3 ниже 2
      else if (sw1.RestSem=2) and (sw2.RestSem=3) then Result:= -1 // 3 ниже 2
      else if (sw1.RestSem>sw2.RestSem) then Result:= -1 else Result:= 1;

    end else begin // по наименованию
      if sw1.IsWare then begin // товар
        ware1:= Cache.GetWare(sw1.ID, True);
        ware2:= Cache.GetWare(sw2.ID, True);
        if (ware1.TopRating<>ware2.TopRating) then begin // по рейтингу
          if (ware1.TopRating=0) then Result:= 1
          else if (ware2.TopRating=0) then Result:= -1
          else if (ware1.TopRating>ware2.TopRating) then Result:= 1 else Result:= -1;
        end else begin  // по наименованию
          s1:= ware1.Name;
          s2:= ware2.Name;
          Result:= AnsiCompareText(s1, s2);
        end;
      end else begin // ОН
        s1:= Cache.FDCA.GetOriginalNum(sw1.ID).Name;
        s2:= Cache.FDCA.GetOriginalNum(sw2.ID).Name;
        Result:= AnsiCompareText(s1, s2);
      end;
    end;
  except
    Result:= 0;
  end;
end;
//============ используется для сортировки объектов типа TTwoCodes в TObjectList
function SearchWareAnalogsSortCompare(Item1, Item2: Pointer): Integer;
var tt1, tt2: TTwoCodes;
    s1, s2: String;
    ware1, ware2: TWareInfo;
begin
  try
    tt1:= TTwoCodes(Item1);
    tt2:= TTwoCodes(Item2);
    if (tt1.ID2<>tt2.ID2) then begin // с остатками - выше

      if (tt1.ID2=3) and (tt2.ID2=2) then Result:= 1       // 3 ниже 2
      else if (tt1.ID2=2) and (tt2.ID2=3) then Result:= -1 // 3 ниже 2
      else if (tt1.ID2>tt2.ID2) then Result:= -1 else Result:= 1;

    end else begin
      ware1:= Cache.GetWare(tt1.ID1, True);
      ware2:= Cache.GetWare(tt2.ID1, True);
      if (ware1.TopRating<>ware2.TopRating) then begin // по рейтингу
        if (ware1.TopRating=0) then Result:= 1
        else if (ware2.TopRating=0) then Result:= -1
        else if (ware1.TopRating>ware2.TopRating) then Result:= 1 else Result:= -1;
      end else begin  // по наименованию
        s1:= ware1.Name;
        s2:= ware2.Name;
        Result:= AnsiCompareText(s1, s2);
      end;
    end;
  except
    Result:= 0;
  end;
end;
//================================== список сопутствующих товаров (Web & WebArm)
procedure prGetWareSatellites(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareSatellites'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csGetSatellites, UserID, FirmID, 'WareID='+IntToStr(WareID)+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // логирование

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
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
      prCheckWareRestsExists(ffp, OLmarkets, Rests); // проверяем
      if (Rests>0) and (OLmarkets.Count>1) then
        OLmarkets.Sort(SearchWareAnalogsSortCompare);
    end;
    Rests:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteInt(OLmarkets.Count); // кол-во строк товаров
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
//===================================================== список аналогов (WebArm)
procedure prGetWareAnalogs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareAnalogs'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;
    WhatShow:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csWebArmGetAnalogs, UserId, FirmID,
      'WareID='+IntToStr(WareID)+#13#10'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'WhatShow='+IntToStr(WhatShow)+#13#10'ContID='+IntToStr(ContID)); // логирование
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту

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
      prCheckWareRestsExists(ffp, OLmarkets, Rests); // проверяем
      if (Rests>0) and (OLmarkets.Count>1) then
        OLmarkets.Sort(SearchWareAnalogsSortCompare);
    end;
    Rests:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(OLmarkets.Count); // кол-во строк аналогов
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
//======================================================= поиск товаров (WebArm)
procedure prCommonWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonWareSearch'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    Template:= Stream.ReadStr;
    Template:= trim(Template);
    IgnoreSpec:= Stream.ReadByte;
    PriceInUah:= Stream.ReadBool;
          // логирование в ib_css - формат НЕ ТРОГАТЬ, обрабатывается в базе !!!
    sParam:= 'ContID='+IntToStr(ContID)+#13#10'Template='+Template+
      #13#10'IgnoreSpec='+IntToStr(IgnoreSpec)+#13#10'ForFirmID='+IntToStr(ForFirmID);
    try
      if (Length(Template)<1) then raise EBOBError.Create('Не задан шаблон поиска');
                 // проверить UserID, FirmID, ForFirmID и получить систему, валюту
      prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
//      if (FirmId<>IsWe) and (ForFirmID<1) then ForFirmID:= FirmID;

      if (FirmId<>IsWe) and Cache.arFirmInfo[FirmId].IsFinalClient then IgnoreSpec:= 2;

      flLamp:= (IgnoreSpec=coLampBaseIgnoreSpec);  // поиск по лампам
      if flLamp then  // добавляем в перечень типы товара ЛАМПА и т.п.
        sTypes:= Cache.GetConstItem(pcWareTypeLampCodes).StrValue
      else
        sTypes:= Stream.ReadStr; // получаем перечень типов товаров, выбранных пользователем

//------------------------------------------------------------- спец.виды поиска
      if flLamp then IgnoreSpec:= 0 // обнуляем признак ламп
      else begin
        s:= AnsiUpperCase(Template);
        flSale    := (s=cTemplateSale);        // РАСПРОДАЖА
        flCutPrice:= (s=cTemplateCutPrice);    // УЦЕНКА
        if not (IgnoreSpec in [1, 2]) then IgnoreSpec:= 0; // пока IgnoreSpec=3 не работает
      end;
      flSpecSearch:= (flSale or flCutPrice or flLamp); // признак спец.поиска
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
      NotWasGroups:= (Length(TypesI)=0); // запоминаем, передавались ли группы, т.к. массив переопределится
InnerErrorPos:='2';
//------------------------------------------------------------- собственно поиск
      WList:= SearchWaresTypesAnalogs(Template, TypesI, IgnoreSpec, -1,
                                      false, true, flSale, flCutPrice, flLamp);
      CountWares:= WList.Count;
InnerErrorPos:='3';
      if not flSpecSearch then begin  // только для обычного поиска
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
      prSetThLogParams(ThreadData, csSearchWithOrNums, UserID, FirmID, sParam); // логирование
    end;

    CountAll:= CountON+CountWares;
    if (CountAll<1) then begin
      s:= 'Не найдены ';
      if flSale then s:= s+'товары распродажи'                      // поиск по распродаже
      else if flCutPrice then s:= s+'уцененные товары'              // поиск по уценке
      else if flLamp then s:= s+'лампы с параметрами '+Template     // поиск по лампам
      else s:= s+'товары/оригинальные номера по шаблону '+Template; // поиск по шаблону
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
//-------------------------------------------------------------- передаем группы
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
      Exit; // выходим
    end;

//------------------------------------------------ готовим товары для сортировки
InnerErrorPos:='6';
    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    ShowAnalogs:= ffp.ForClient and (CountAll<Cache.arClientInfo[ffp.UserID].MaxRowShowAnalogs);
    flSemafores:= (ffp.ForClient or (ForFirmID>0));
    OLmarkets.Capacity:= WList.Count;
    //---------- собираем коды продажных товаров для семафоров и наличия моделей
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if (WA.RestSem>-1) then // 1-й раз проверяется в SearchWaresTypesAnalogs
        if Cache.GetWare(WA.ID).IsMarketWare(ffp) then begin
          WA.RestSem:= 0;         // default - семафор отсутствия
          fnFindOrAddTwoCode(OLmarkets, WA.ID); // коды продажных товаров
        end else WA.RestSem:= -1; // непродажный товар

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
          tc.ID2:= 0;           // default - семафор отсутствия
          fnFindOrAddTwoCode(OLmarkets, tc.ID1); // коды продажных товаров
        end else tc.ID2:= -1;
      end;
    end; // for i:= 0 to WList.Count

    if flSemafores then // для сортировки по семафорам - аналоги ОН
      for i:= 0 to ONlist.Count-1 do begin
        WA:= TSearchWareOrOnum(ONlist[i]);
        for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
          tc:= TTwoCodes(WA.OLAnalogs[j]);
          if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
            tc.ID2:= 0;         // default - семафор отсутствия
            fnFindOrAddTwoCode(OLmarkets, tc.ID1); // коды продажных товаров
          end else tc.ID2:= -1;
        end;
      end;

    flSemafores:= flSemafores and (OLmarkets.Count>0); // флаг проверки семафоров наличия
    //--------------------------------------------------------- семафоры наличия
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, Rests); // проверяем
      if (Rests>0) then begin
        for i:= 0 to WList.Count-1 do begin    // проставляем семафоры у товаров
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count

        for i:= 0 to ONlist.Count-1 do begin    // проставляем семафоры у ОН
          WA:= TSearchWareOrOnum(ONlist[i]);
          for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2<0) then Continue;
            tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
            if (tc.ID2>0) then begin
              if (WA.RestSem<tc.ID2) then WA.RestSem:= tc.ID2; // у аналогов есть наличие ???
              if not ShowAnalogs and (WA.RestSem=2) then break;
            end;
          end;
          if ShowAnalogs and (WA.OLAnalogs.Count>1) then
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to ONlist.Count
      end; // if (RestWares.Count>0)
    end; // if flSemafores

//-------------------------------------------------------- сортируем товары / ОН
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare);
    if (ONlist.Count>1) then ONlist.Sort(SearchWareOrONSortCompare);

//-------------------------------------------------------------- передаем товары
    Rests:= -1;
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);   // Передаем товары
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

    Stream.WriteInt(ONlist.Count);  // Передаем оригинальные номера
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

      Stream.WriteInt(WA.OLAnalogs.Count); // кол-во аналогов
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
//======================================================== список аналогов (Web)
procedure prGetWareAnalogs_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareAnalogs_new'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;
    WhatShow:= Stream.ReadByte;

    prSetThLogParams(ThreadData, csWebArmGetAnalogs, UserId, FirmID,
      'WareID='+IntToStr(WareID)+#13#10'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'WhatShow='+IntToStr(WhatShow)+#13#10'ContID='+IntToStr(ContID)); // логирование
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту

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
      MessText(mtkNotFoundWaresSem)+' - аналоги '+ware.Name);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(OLmarkets.Count); // кол-во строк аналогов
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
//=================================== поиск товаров по значениям атрибутов (Web)
procedure prCommonSearchWaresByAttr_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonSearchWaresByAttr_new'; // имя процедуры/функции
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
    aCount:= Stream.ReadInt;  // кол-во атрибутов
    try
      if (aCount<1) then raise EBOBError.Create(MessText(mtkNotParams));
      SetLength(attCodes, aCount);
      SetLength(valCodes, aCount);
      for i:= 0 to aCount-1 do begin
        attCodes[i]:= Stream.ReadInt;
        valCodes[i]:= Stream.ReadInt;
        if (i=0) then flGBatt:= (attCodes[i]>cGBattDelta);
        if (grpID<1) then //------------------ вычисляем группу для логирования
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
      ContID:= Stream.ReadInt; // для контрактов
    finally
      prSetThLogParams(ThreadData, csSearchWaresByAttrValues, UserId, FirmID,
        'pCount='+IntToStr(aCount)+#13#10'grpID='+IntToStr(grpID)+
        #13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID));
    end;
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    if flGBatt then begin // атрибуты Grossbee
      for i:= 0 to aCount-1 do begin  // снимаем сдвиги кодов
        attCodes[i]:= attCodes[i]-cGBattDelta;
        valCodes[i]:= valCodes[i]-cGBattDelta;
      end;
      attCodes:= Cache.SearchWaresByGBAttValues(attCodes, valCodes);

    end else // атрибуты ORD
      attCodes:= Cache.SearchWaresByAttrValues(attCodes, valCodes);

    if (Length(attCodes)<1) then raise EBOBError.Create(MessText(mtkNotFoundWares));

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
    flSemafores:= ffp.NeedSemafores;
    if flSemafores then ffp.FillStores;

    for i:= 0 to High(attCodes) do begin
      ware:= Cache.GetWare(attCodes[i]);
      if ware.IsPrize then Continue;
      flMarket:= ware.IsMarketWare(ffp);
      if not flMarket then Continue; // здесь нужны только продажные товары

      if flSemafores then begin  // семафоры наличия
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
      MessText(mtkNotFoundWaresSem)+' с заданным сочетанием параметров');
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(false); // для совместимости
    Stream.WriteInt(WList.Count);          //------------------- передаем товары
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
//========== используется для сортировки объектов типа TNodePLdata в TObjectList
function SearchNodePLdataSortCompare(Item1, Item2: Pointer): Integer;
var sw1, sw2: TNodePLdata;
    s1, s2: String;
begin
  try
    sw1:= TNodePLdata(Item1);
    sw2:= TNodePLdata(Item2);
    if (sw1.Node.ID<>sw2.Node.ID) then begin
//      Result:= 0; // узлы сортируются при выборке из базы !!!
      if (sw1.Node.OrderOut=sw2.Node.OrderOut) then // узлы сортируются по порядк.номеру
        Result:= AnsiCompareText(sw1.Node.Name, sw2.Node.Name)
      else if (sw1.Node.OrderOut>sw2.Node.OrderOut) then Result:= 1 else Result:= -1;

    end else if (sw1.prior<>sw2.prior) then begin // по приоритету
      if (sw1.prior>sw2.prior) then Result:= 1 else Result:= -1;

    end else begin // по наименованию прод.линейки
      s1:= sw1.PLine.Name;
      s2:= sw2.PLine.Name;
      Result:= AnsiCompareText(s1, s2);
    end;
  except
    Result:= 0;
  end;
end;
//==================================== сортировка кодов узлов ветки дерева Motul
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
//=================================== список товаров Motul по узлам модели (Web)
procedure prCommonGetNodeWares_Motul(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares_Motul'; // имя процедуры/функции
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
  codes:= TIntegerList.Create; // список всех узлов модели для полосы иконок
  lst:= TStringList.Create;
  olNodePLs:= TObjectList.Create;
  SetLength(prices, 0);
  try try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // код модели
    NodeID:= Stream.ReadInt;   // код узла: 0- все, <0- узел основного подбора, >0- узел Motul
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt;   // код контракта
    PriceInUAH:= Stream.ReadBool;

StrPos:='0';
    prSetThLogParams(ThreadData, csGetNodeWaresMotul, UserID, FirmID,
      'Model='+IntToStr(ModelID)+#13#10'Node='+IntToStr(NodeID)+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // логирование
StrPos:='1';
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
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

    flAllNodes:= (NodeID=0); // все узлы, выдавать по 1-й линейке
    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
    flSemafores:= ffp.NeedSemafores; // флаг семафоров наличия
    if flSemafores then ffp.FillStores;
StrPos:='3';

    IBD:= cntsOrd.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'ORD_IBS_'+nmProc, -1, tpRead, True);

      if not flAllNodes then begin //------------------ список всех узлов модели
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
        j:= ibs.FieldByName('rNode').asInteger; // код узла
        if not Cache.MotulTreeNodes.ItemExists(j) then begin
          TestCssStopException;
          while not ibs.Eof and (j=ibs.FieldByName('rNode').asInteger) do ibs.Next;
          Continue;
        end;
        if flAllNodes then codes.Add(j);
        Node:= Cache.MotulTreeNodes[j];
        kolvo:= ibs.FieldByName('RCount').AsFloat; // кол-во по узлу

        while not ibs.Eof and (j=ibs.FieldByName('rNode').asInteger) do begin
          plID:= ibs.FieldByName('Rpline').asInteger;  // код прод.линейки
          PLine:= Cache.ProductLines.GetProductLine(plID);
          if not Assigned(PLine) or (PLine.WareLinks.LinkCount<1) then begin
            TestCssStopException;
            while not ibs.Eof and (j=ibs.FieldByName('rNode').asInteger)
              and (plID=ibs.FieldByName('Rpline').asInteger) do ibs.Next;
            Continue;
          end;
          prior:= ibs.FieldByName('Rprior').asInteger; // приоритет по узлу
          plComm:= PLine.Comment;

          lst.Clear; // собираем условия применимости прод.линейки
          while not ibs.Eof and (j=IBS.FieldByName('rNode').asInteger)
            and (plID=ibs.FieldByName('Rpline').asInteger) do begin
            ss:= ibs.FieldByName('RcriName').AsString;
            s:= ibs.FieldByName('Rvalues').AsString; // строка по 1-му критерию
            if (s<>'') or (ss<>'') then lst.Add(ss+fnIfStr(s='', '', ': '+s));
            cntsOrd.TestSuspendException;
            ibs.Next;
          end; // while ... and (plID=ORD_IBS.FieldByName('Rpline').asInteger

          NodePLdata:= TNodePLdata.Create(Node, PLine, kolvo, prior, lst.Text, plComm);
StrPos:='4';
          // список товаров прод.линейки с семафорами (отсортирован по литражу)
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
                     // сортируем список всех узлов по порядковому номеру
    codes.SortList(MotulNodeCodesSortCompare);
        // сортируем узлы  по порядк.номеру и прод.линейки в узлах по приоритету
    olNodePLs.Sort(SearchNodePLdataSortCompare);
StrPos:='5';

    ms:= TMemoryStream.Create;
    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'GB_IBS_'+nmProc, -1, tpRead, True);
{ 13593 Главная фотография товара
 109678 Фото СВК
 109675 Фото TecDoc1
 109676 Фото TecDoc2
 109677 Фото TecDoc3  }
      ibs.SQL.Text:= 'select WRBLFTEXTN, WRBLFTFOTO'+ //  first 1
        '  from (select WRBLFTEXTN, WRBLFTFOTO, DECODE(WRBLFTFOTOTYPE, 13593,1,'+
        '    109678,2, 109675,3, 109676,4, 109677,5) ftype from WAREBLOBFOTO'+
        '    where WRBLFTWARECODE=:wareID and WRBLFTFOTO is not null'+
        '    and WRBLFTEXTN is not null) where ftype is not null order by ftype';
StrPos:='6';
//---------------------------------- передача в CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteInt(Sys);           // система
      Stream.WriteStr(Model.WebName); // наименование модели

      Stream.WriteInt(codes.Count);   // кол-во узлов для полосы иконок
      for i:= 0 to codes.Count-1 do begin
        Stream.WriteInt(codes[i]);      // код узла
        Node:= Cache.MotulTreeNodes[codes[i]];
        Stream.WriteStr(Node.Name);     // наименование узла
      end;

      Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient)); // название валюты
      aCount:= 0;
      aPos:= Stream.Position;
      Stream.WriteInt(aCount); // кол-во прод.линеек (блоков)
      NodeID:= -1;
      s:= '';
      for j:= 0 to olNodePLs.Count-1 do begin
        NodePLdata:= TNodePLdata(olNodePLs[j]);

        // если все узлы - передаем только 1-ю прод.линейку по узлу
        if flAllNodes and (NodePLdata.Node.ID=NodeID) then Continue;

        if (NodeID<>NodePLdata.Node.ID) then begin // строка ед.изм. узла
          if (NodePLdata.Node.MeasID<1) then s:= ' л'
          else s:= ' '+Cache.GetMeasName(NodePLdata.Node.MeasID);
        end;

        Stream.WriteInt(NodePLdata.Node.ID);    // код узла (для иконки)
        Stream.WriteStr(NodePLdata.Node.Name);  // наименование узла
        Stream.WriteInt(NodePLdata.PLine.ID);   // код прод.линейки
        Stream.WriteStr(NodePLdata.PLine.Name); // наименование прод.линейки
        Stream.WriteStr(NodePLdata.plComm);     // комментарий прод.линейки
        if fnNotZero(NodePLdata.nCount) then
          Stream.WriteStr(FloatToStr(RoundTo(NodePLdata.nCount, -3))+s) // объем заливки
        else Stream.WriteStr('');
        Stream.WriteStr(NodePLdata.StrUses);    // (i) условия применимости прод.линейки

//-------------------------------------------------------- картинка прод.линейки
        imgExt:= '';
        fsize:= 0;
        ms.Clear;
StrPos:='7';
        WA:= TSearchWareOrOnum(NodePLdata.WList[0]); // 1-й товар
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
        Stream.WriteStr(imgExt);      // расширение файла картинки
        Stream.WriteInt(fsize);       // размер картинки
        if (fsize>0) then begin
          ms.Position:= 0;
          Stream.CopyFrom(ms, fsize); // картинка
        end;
//------------------------------------------------------------------------------
StrPos:='10';
        Stream.WriteInt(NodePLdata.WList.Count); // кол-во товаров в прод.линейке
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

          Stream.WriteInt(ware.ID);             // код товара
          Stream.WriteInt(iCode);               // группа атрибутов
          Stream.WriteDouble(ware.LitrCount);   // литраж

          for ii:= 0 to High(prices) do // цены (0- Розница, 1- со скидкой, 2- со след.скидкой)
            Stream.WriteDouble(prices[ii]);

          Stream.WriteInt(4);                  // кол-во систем учета
          Stream.WriteInt(constIsAuto);        // код системы учета AUTO
          fl:= ware.SysModelsExists(constIsAuto);
          Stream.WriteBool(fl);                // признак наличия моделей AUTO

          Stream.WriteInt(constIsMoto);        // код системы учета MOTO
          fl:= ware.SysModelsExists(constIsMoto);
          Stream.WriteBool(fl);                // признак наличия моделей MOTO

          Stream.WriteInt(constIsCV);          // код системы учета грузовиков
          fl:= ware.SysModelsExists(constIsCV);
          Stream.WriteBool(fl);                // признак наличия моделей грузовиков

          Stream.WriteInt(constIsAx);          // код системы учета осей
          fl:= ware.SysModelsExists(constIsAx);
          Stream.WriteBool(fl);                // признак наличия моделей осей

          Stream.WriteBool(ware.IsSale);        // признак распродажи
          Stream.WriteBool(ware.IsNonReturn);   // признак невозврата
          Stream.WriteBool(ware.IsCutPrice);    // признак уценки

          Stream.WriteInt(aCode);               // код акции
          Stream.WriteStr(ActTitle);            // заголовок
          Stream.WriteStr(ActText);             // текст
//----------------------------------------------------------------- иконка акции
//          if (aCode<1) then begin
            Stream.WriteStr('');           // расширение
            Stream.WriteInt(0);            // размер
{
          end else try
            Cache.WareActions.CS_DirItems.Enter;
            wact:= Cache.WareActions[aCode];
            fsize:= wact.IconMS.Size;

            Stream.WriteStr(wact.IconExt); // расширение иконки
            Stream.WriteInt(fsize);        // размер
            if (fsize>0) then begin
              wact.IconMS.Position:= 0;
              Stream.CopyFrom(wact.IconMS, fsize); // иконка
            end;

          finally
            Cache.WareActions.CS_DirItems.Leave;
          end;  }
//------------------------------------------------------------------------------
          Stream.WriteDouble(Ware.divis); // кратность отпуска товара
          Stream.WriteInt(Wa.RestSem);    // семафор остатков: 0- красный, 1- желтый, 2- зеленый, 3- спец.семафор, другое - нет

if flSpecRestSem then
          Stream.WriteStr(WA.SemTitle);    // подсказка для спец.семафора

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
//================================================= список товаров по узлу (Web)
procedure prCommonGetNodeWares_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares_new'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    ShowChildWares:= Stream.ReadBool;
    IsEngine:= Stream.ReadBool;
    PriceInUAH:= Stream.ReadBool;
    filter:= Stream.ReadStr;

StrPos:='0';
    prSetThLogParams(ThreadData, csGetNodeWares, UserID, FirmID,
      'Node='+IntToStr(NodeID)+#13#10'Model='+IntToStr(ModelID)+
      #13#10'Filter='+(Filter)+#13#10'IsEngine='+fnIfStr(IsEngine, '1', '0')+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // логирование
StrPos:='1';
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
StrPos:='2';
    if IsEngine then begin  //--------- двигатель
      Sys:= constIsAuto;
//      if Sys<>constIsAuto then raise EBOBError.Create(MessText(mtkNotFoundWares));
      if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundEngine));
      Engine:= Cache.FDCA.Engines[ModelID];

    end else begin          //--------- модель
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

    if IsEngine then begin  //--------- двигатель
      Stream.WriteInt(31);
      Stream.WriteStr(Engine.WebName);
    // Признак того, что пользователь WebArm может удалять товар из связки 3
      flag:= not ffp.ForClient and empl.UserRoleExists(rolTNAManageAuto);
StrPos:='4-1';
      List:= Engine.GetEngNodeWaresWithUsesByFilters(NodeID, ShowChildWares, Filter);

    end else begin          //--------- модель
      Stream.WriteInt(Sys);
      Stream.WriteStr(Model.WebName);
    // Признак того, что пользователь WebArm может удалять товар из связки 3
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
    webMess:= ' по узлу "'+NodeName+'"';
//    webMess:= fnReplaceQuotedForWeb(' по узлу "'+brcWebBoldBlackBegin+NodeName+brcWebBoldEnd+'"');
    ShowAnalogs:= False;
    flSemafores:= ffp.NeedSemafores; // флаг семафоров наличия
    if flSemafores then ffp.FillStores;
    ShowChildWares:= flag or not flSemafores; // здесь - флаг вывода для WebArm

StrPos:='4-3';
    // --------------------------------------------- готовим список с семафорами
    for i:= 0 to List.Count-1 do begin
      WareID:= integer(List.Objects[i]);
      ware:= Cache.GetWare(WareID);
      flMarket:= ware.IsMarketWare(ffp);
      WA:= TSearchWareOrOnum.Create(WareID, 0, True, flMarket);
      if flSemafores and flMarket then
        WA.RestSem:= GetContWareRestsSem(WA.ID, ffp, WA.SemTitle);

      for j:= 0 to ware.AnalogLinks.ListLinks.Count-1 do begin
        analog:= GetLinkPtr(ware.AnalogLinks.ListLinks[j]);
        if analog.IsINFOgr or not analog.IsMarketWare(ffp) then Continue; // инфо и без цен пропускаем
        sem:= 0;
        sArrive:= '';
        if flSemafores then begin // если нужны семафоры
          sem:= GetContWareRestsSem(analog.ID, ffp, sArrive);
          if ffp.HideZeroRests and (sem<1) then Continue; // если надо - отсеиваем красные
        end;
        tc:= TTwoCodes.Create(analog.ID, sem, 0, sArrive);
        WA.OLAnalogs.Add(tc);
      end; // for j:= 0 to

      if (WA.OLAnalogs.Count<1) and not flMarket and not flag then begin
        prFree(WA);    // на 1-м проходе товары по семафорам не отсеиваем !!!
        Continue;
      end;

      WA.AddComment:= List[i]; // для товара - условия применимости
      WList.Add(WA);
      if not ShowChildWares then codes.Add(WA.ID); // коды товаров, кот. есть в WList
    end; // for i:= 0 to List.Count

    //---------------------------------- аналоги - в список товаров без дубляжа
    if not ShowChildWares then begin
      for i:= WList.Count-1 downto 0 do begin
        WA:= TSearchWareOrOnum(WList[i]);
        ware:= Cache.GetWare(WA.ID);
        s:= 'Найден через сравнительный номер '+ware.Name; // коммент для аналога
        for j:= 0 to WA.OLAnalogs.Count-1 do begin
          tc:= TTwoCodes(WA.OLAnalogs[j]);
          if (codes.IndexOf(tc.ID1)>-1) then Continue; // товар уже есть

          addWA:= TSearchWareOrOnum.Create(tc.ID1, 0, True, True);
          addWA.RestSem:= tc.ID2;
          addWA.SemTitle:= tc.Name; // подсказка к семафору
          lst.Clear;
          lst.Add(brcWebColorBlueBegin+s+brcWebColorEnd); // синий шрифт
          addWA.AddComment:= lst.Text;
//          addWA.AddComment:= ''''+brcWebColorBlueBegin+s+brcWebColorEnd+''''; // синий шрифт

          AddList.Add(addWA);   // аналоги - в доп.список
          codes.Add(addWA.ID);  // коды товаров, кот. есть в WList
        end;
        if ware.IsINFOgr or not ware.IsMarketWare(ffp)
          or (flSemafores and ffp.HideZeroRests and (WA.RestSem<1)) then begin
          WList.Delete(i);
          prFree(WA);    // на 2-м проходе отсеиваем непродажные товары + по семафорам
        end;
      end; // for i:= 0 to WList.Count

//      for i:= 0 to AddList.Count-1 do WList.Add(AddList[i]); // доп.список + к основному
    end; // if not ShowChildWares

    if (WList.Count<1) and (AddList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotFoundWaresSem)+webMess);

    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    if (AddList.Count>1) then AddList.Sort(SearchWareOrONSortCompare); // сортируем аналоги

StrPos:='5';
    Stream.WriteBool(flag);
    Stream.WriteStr(NodeName);
    Stream.WriteStr(Filter);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);

    Stream.WriteInt(WList.Count);          //------------------- передаем товары
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      if ShowChildWares then j:= WA.OLAnalogs.Count else j:= 0;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, j, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count

    Stream.WriteInt(AddList.Count);       //------------------- передаем аналоги
    for i:= 0 to AddList.Count-1 do begin
      WA:= TSearchWareOrOnum(AddList[i]);
      if ShowChildWares then j:= WA.OLAnalogs.Count else j:= 0;
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, j, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to AddList.Count

StrPos:='10';
//---------------------------- Доп.инфо о прим. товаров к моделям / Найден через
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
//=============================== поиск товаров по оригин.номеру из Laximo (Web)
procedure prSearchWaresByOE_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSearchWaresByOE_new'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt;       // для контрактов
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;
    pline:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWaresByOE, UserID, FirmID, 'OE='+OE+
      #13#10'Manuf='+Manuf+#13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID)); // логирование
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту

    if (Manuf='') then raise EBOBError.Create('Некорректное значение производителя');
    if (OE='') then raise EBOBError.Create('Некорректное значение оригинального номера');
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

    webMess:= ' по ориг.номеру "'+OE+'"';
//    webMess:= fnReplaceQuotedForWeb(' по ориг.номеру "'+brcWebBoldBlackBegin+OE+brcWebBoldEnd+'"');
    mess:= MessText(mtkNotFoundWares)+webMess;
    iListM:= TIntegerList.Create; // коды производителей
    iListW:= TIntegerList.Create; // коды товаров
    codes:= TIntegerList.Create; // коды товаров для проверки на дубляж
    try
      i:= Cache.BrandLaximoList.IndexOf(Manuf);
      if (i>-1) then begin
        lst:= TIntegerList(Cache.BrandLaximoList.Objects[i]);
        for i:= 0 to lst.Count-1 do iListM.Add(lst[i]);
      end;
      m:= fnInStrArray(Manuf, arManufDuo);
      if (m>-1) then begin
        if Odd(m) then ManufDuo:= arManufDuo[m-1] // нечетный индекс
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
      for m:= 0 to iListM.Count-1 do try //------ собираем коды товаров в iListW
        ManufID:= iListM[m];
        if not Cache.FDCA.Manufacturers.ManufExists(ManufID) then continue;
        i:= Cache.FDCA.SearchOriginalNum(ManufID, OE);
        if (i<0) then continue;

        aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // товары к ОН
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
      flSemafores:= ffp.NeedSemafores; // флаг семафоров наличия
      if flSemafores then ffp.FillStores;
      ShowAnalogs:= False;

    // --------------------------------------------- готовим список с семафорами
      for i:= 0 to iListW.Count-1 do begin
        WareID:= iListW[i];
        ware:= Cache.GetWare(WareID);
        flMarket:= ware.IsMarketWare(ffp);
        WA:= TSearchWareOrOnum.Create(WareID, 0, True, flMarket);
        if flSemafores and flMarket then
          WA.RestSem:= GetContWareRestsSem(WA.ID, ffp, WA.SemTitle);

        for j:= 0 to ware.AnalogLinks.ListLinks.Count-1 do begin
          analog:= GetLinkPtr(ware.AnalogLinks.ListLinks[j]);
          if analog.IsINFOgr or not analog.IsMarketWare(ffp) then Continue; // инфо и без цен пропускаем
          if flSemafores then begin // если нужны семафоры
            sem:= GetContWareRestsSem(analog.ID, ffp, sArrive);
            if ffp.HideZeroRests and (sem<1) then Continue; // если надо - отсеиваем красные
          end else begin
            sem:= 0;
            sArrive:= '';
          end;
          tc:= TTwoCodes.Create(analog.ID, sem, 0, sArrive);
          WA.OLAnalogs.Add(tc);
        end; // for j:= 0 to

        if (WA.OLAnalogs.Count<1) and not flMarket then begin
          prFree(WA);    // на 1-м проходе товары по семафорам не отсеиваем !!!
          Continue;
        end;

        WA.AddComment:= ''; // для товара - пусто
        WList.Add(WA);
        codes.Add(WA.ID); // коды товаров, кот. есть в WList
      end; // for i:= 0 to iListW.Count
    finally
      prFree(iListM);
      prFree(iListW);
    end;

    //---------------------------------- аналоги - в список товаров без дубляжа
    for i:= WList.Count-1 downto 0 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      ware:= Cache.GetWare(WA.ID);
      s:= 'Найден через сравнительный номер '+ware.Name; // коммент для аналога
      for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if (codes.IndexOf(tc.ID1)>-1) then Continue; // товар уже есть

        addWA:= TSearchWareOrOnum.Create(tc.ID1, 0, True, True);
        addWA.RestSem:= tc.ID2;
        addWA.SemTitle:= tc.Name; // подсказка к семафору
        slst.Clear;
        slst.Add(brcWebColorBlueBegin+s+brcWebColorEnd); // синий шрифт
        addWA.AddComment:= slst.Text;
//        addWA.AddComment:= ''''+brcWebColorBlueBegin+s+brcWebColorEnd+''''; // синий шрифт

        AddList.Add(addWA);   // аналоги - в доп.список
        codes.Add(addWA.ID);  // коды товаров, кот. есть в WList
      end;
      if ware.IsINFOgr or not ware.IsMarketWare(ffp)
        or (flSemafores and ffp.HideZeroRests and (WA.RestSem<1)) then begin
        WList.Delete(i);
        prFree(WA);    // на 2-м проходе отсеиваем непродажные товары + по семафорам
      end;
    end; // for i:= 0 to WList.Count

//    for i:= 0 to AddList.Count-1 do WList.Add(AddList[i]); // доп.список + к основному

    if (WList.Count<1) and (AddList.Count<1) then
      raise EBOBError.Create(MessText(mtkNotFoundWaresSem)+webMess);

    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    if (AddList.Count>1) then AddList.Sort(SearchWareOrONSortCompare); // сортируем аналоги
//------------------------------------------------------------------------------

    Stream.Clear;
    Stream.WriteInt(aeSuccess);    // нашли товары по ОЕ
    Stream.WriteStr(Manuf);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);

    Stream.WriteInt(WList.Count);          //------------------- передаем товары
    for i:= 0 to WList.Count-1 do begin
      WA:= TSearchWareOrOnum(WList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, 0, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count

    Stream.WriteInt(AddList.Count);        //------------------ передаем аналоги
    for i:= 0 to AddList.Count-1 do begin
      WA:= TSearchWareOrOnum(AddList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, 0, 0, WA.RestSem, WA.SemTitle);
    end; // for i:= 0 to WList.Count

    Stream.WriteStr('WaresByOE');

//---------------------------- Доп.инфо о "Найден через ..."
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
//---------------------------- Доп.инфо о "Найден через ..."

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
//========================================================== поиск товаров (Web)
procedure prCommonWareSearch_new(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonWareSearch_new'; // имя процедуры/функции
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
    prMessageLOGS(nmProc+' ----------- begin search '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end; // if flmyDebug

    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // для контрактов
    Template:= Stream.ReadStr;
    Template:= trim(Template);
    IgnoreSpec:= Stream.ReadByte;
    PriceInUah:= Stream.ReadBool;
          // логирование в ib_css - формат НЕ ТРОГАТЬ, обрабатывается в базе !!!
    sParam:= 'ContID='+IntToStr(ContID)+#13#10'Template='+Template+
      #13#10'IgnoreSpec='+IntToStr(IgnoreSpec)+#13#10'ForFirmID='+IntToStr(ForFirmID);
    try
      if (Length(Template)<1) then raise EBOBError.Create('Не задан шаблон поиска');
                 // проверить UserID, FirmID, ForFirmID и получить систему, валюту
      prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
//      if (FirmId<>IsWe) and (ForFirmID<1) then ForFirmID:= FirmID;

      if (FirmId<>IsWe) and Cache.arFirmInfo[FirmId].IsFinalClient then IgnoreSpec:= 2;

      sTypes:= Stream.ReadStr; // получаем перечень типов товаров, выбранных пользователем
//------------------------------------------------------------- спец.виды поиска
      s:= AnsiUpperCase(Template);
      flSale    := (s=cTemplateSale);        // РАСПРОДАЖА
      flCutPrice:= (s=cTemplateCutPrice);    // УЦЕНКА
      if not (IgnoreSpec in [1, 2]) then IgnoreSpec:= 0; // пока IgnoreSpec=3 не работает
      flSpecSearch:= (flSale or flCutPrice); // признак спец.поиска
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
      NotWasGroups:= (Length(TypesI)=0); // запоминаем, передавались ли группы, т.к. массив переопределится
InnerErrorPos:='2';

      ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);
      flSemafores:= ffp.NeedSemafores;
      if flSemafores then ffp.FillStores;
//------------------------------------------------------------- собственно поиск

      WList:= SearchWaresTypesAnalogs_new(Template, TypesI, IgnoreSpec,
                                      false, flSale, flCutPrice, flSemafores, ffp);

if flmyDebug then begin
    prMessageLOGS(nmProc+' form WList - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end; // if flmyDebug

InnerErrorPos:='3';
//---------------------------------------- только для обычного поиска - поиск ОН
      if flSpecSearch then ONlist:= TObjectList.Create
      else ONlist:= SearchWareOrigNums_new(Template, IgnoreSpec, TypesIon, flSemafores, ffp);

if flmyDebug then begin
    prMessageLOGS(nmProc+' form ONlist - '+GetLogTimeStr(LocStart), fLogDebug, false); // пишем в log
    LocStart:= now();
end; // if flmyDebug

      sParam:= sParam+#13#10'WareQty='+IntToStr(WList.Count)+#13#10'OEQty='+IntToStr(ONlist.Count);
    finally
      prSetThLogParams(ThreadData, csSearchWithOrNums, UserID, FirmID, sParam); // логирование
    end;

    CountAll:= ONlist.Count+WList.Count;
    if (CountAll<1) then
      raise EBOBError.Create(MessText(mtkNotFoundWaresSem)+' по шаблону '+Template);

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
//-------------------------------------------------------------- передаем группы
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
      Exit; // выходим
    end;
InnerErrorPos:='6';

//--------------------------------------------------------------- готовим товары
    ShowAnalogs:= ffp.ForClient and (CountAll<Cache.arClientInfo[ffp.UserID].MaxRowShowAnalogs);

    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    for i:= 0 to WList.Count-1 do begin // сортируем аналоги
      WA:= TSearchWareOrOnum(WList[i]);
      if (WA.OLAnalogs.Count>1) and (ShowAnalogs or (WA.RestSem=0)) then
        WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
    end; // for i:= 0 to WList.Count

    if (ONlist.Count>1) then ONlist.Sort(SearchWareOrONSortCompare); // сортируем ОН
    if ShowAnalogs then for i:= 0 to ONlist.Count-1 do begin // сортируем аналоги ОН
      WA:= TSearchWareOrOnum(ONlist[i]);
      if (WA.OLAnalogs.Count>1) then
        WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
    end;

//-------------------------------------------------------------- передаем товары
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);   // Передаем товары
    for i:= 0 to WList.Count-1 do begin
InnerErrorPos:='7-'+IntToStr(i);
      WA:= TSearchWareOrOnum(WList[i]);
      prSaveShortWareInfoToStream(Stream, ffp, WA.ID, WA.OLAnalogs.Count, 0, WA.RestSem, WA.SemTitle);

      if (ShowAnalogs or (WA.RestSem=0)) then for j:= 0 to WA.OLAnalogs.Count-1 do begin
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        prSaveShortWareInfoToStream(Stream, ffp, tc.ID1, 0, 0, tc.ID2, tc.Name);
      end;
    end; // for i:= 0 to WList.Count-1
//------------------------------------------------------------------ передаем ОН
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

      Stream.WriteInt(WA.OLAnalogs.Count); // кол-во аналогов
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
    prMessageLOGS(nmProc+' ----------- end search '+GetLogTimeStr(LocalStart), fLogDebug, false); // пишем в log
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
//============================================== список товаров по узлу (WebArm)
procedure prCommonGetNodeWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    ShowChildWares:= Stream.ReadBool;
    IsEngine:= Stream.ReadBool;
    PriceInUAH:= Stream.ReadBool;
    filter:= Stream.ReadStr;

StrPos:='0';
    prSetThLogParams(ThreadData, csGetNodeWares, UserID, FirmID,
      'Node='+IntToStr(NodeID)+#13#10'Model='+IntToStr(ModelID)+
      #13#10'Filter='+(Filter)+#13#10'IsEngine='+fnIfStr(IsEngine, '1', '0')+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // логирование
StrPos:='1';
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
StrPos:='2';
    if IsEngine then begin  //--------- двигатель
      Sys:= constIsAuto;
//      if Sys<>constIsAuto then raise EBOBError.Create(MessText(mtkNotFoundWares));
      if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundEngine));
      Engine:= Cache.FDCA.Engines[ModelID];

    end else begin          //--------- модель
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

    if IsEngine then begin  //--------- двигатель
      Stream.WriteInt(31);
      Stream.WriteStr(Engine.WebName);
    // Признак того, что пользователь WebArm может удалять товар из связки 3
      flag:= not ffp.ForClient and empl.UserRoleExists(rolTNAManageAuto);
StrPos:='4-1';
      List:= Engine.GetEngNodeWaresWithUsesByFilters(NodeID, ShowChildWares, Filter);

    end else begin          //--------- модель
      Stream.WriteInt(Sys);
      Stream.WriteStr(Model.WebName);
    // Признак того, что пользователь WebArm может удалять товар из связки 3
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

    //---------- собираем коды продажных товаров для семафоров и наличия моделей
    for i:= 0 to List.Count-1 do begin
      WareID:= integer(List.Objects[i]);
      ware:= Cache.GetWare(WareID);
      flMarket:= ware.IsMarketWare(ffp);
      try
        aar:= fnGetAllAnalogs(WareID);
        aar1:= ware.GetSatellites; // сопут.товары
        WA:= TSearchWareOrOnum.Create(WareID, Length(aar1), True, flMarket, aar);
      finally
        SetLength(aar, 0);
        SetLength(aar1, 0);
      end;
      WList.Add(WA);
      if flMarket then fnFindOrAddTwoCode(OLmarkets, WA.ID); // коды продажных товаров

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
          tc.ID2:= 0;           // default - семафор отсутствия
          fnFindOrAddTwoCode(OLmarkets, tc.ID1); // коды продажных товаров
        end else tc.ID2:= -1;
      end;
    end; // for i:= 0 to List.Count

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // флаг семафоров наличия
    //--------------------------------------------------------- семафоры наличия
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, aCount); // проверяем
      if (aCount>0) then begin            // проставляем семафоры у товаров
        for i:= 0 to WList.Count-1 do begin
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then // сортируем аналоги
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    aCount:= -1;

StrPos:='5';
    Stream.WriteBool(flag);
    Stream.WriteStr(NodeName);
    Stream.WriteStr(Filter);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);          //------------------- передаем товары
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
//------------------------------------ Доп.инфо о применимости товаров к моделям
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
//================================ поиск товаров по оригин.номеру (Web & WebArm)
procedure prCommonGetWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetWaresByOE'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;

ErrorPos:='00';
    prSetThLogParams(ThreadData, csGetWaresByOE, UserId, FirmID,
      'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID));
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

ErrorPos:='05';
    if not Cache.FDCA.Manufacturers.ManufExistsByName(Manuf, ManufID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, Manuf));

ErrorPos:='10';
    i:= Cache.FDCA.SearchOriginalNum(ManufID, fnDelSpcAndSumb(OE));
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundOrNum)+' "'+OE+'"');

    aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // товары к ОН
    iCount:= Length(aiWareByON);
    if (iCount<1) then raise EBOBError.Create(MessText(mtkNotFoundWares)+
                                             ' с оригинальным номером "'+OE+'"');

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    ShowAnalogs:= not ffp.ForClient and (iCount<=Cache.arClientInfo[UserID].MaxRowShowAnalogs);

    //---------- собираем коды продажных товаров для семафоров и наличия моделей
    for i:= 0 to High(aiWareByON) do begin
      WareID:= aiWareByON[i];
      ware:= Cache.GetWare(WareID);
      if ware.IsPrize then Continue;

      flMarket:= ware.IsMarketWare(ffp);
      try
        aiAnalogs:= fnGetAllAnalogs(WareID);
        aiSatells:= ware.GetSatellites; // сопут.товары
        WA:= TSearchWareOrOnum.Create(WareID, Length(aiSatells), True, flMarket, aiAnalogs);
      finally
        SetLength(aiAnalogs, 0);
        SetLength(aiSatells, 0);
      end;
      if flMarket then fnFindOrAddTwoCode(OLmarkets, WA.ID); // коды продажных товаров
      WList.Add(WA);

      if not ShowAnalogs then Continue;

      for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
        tc:= TTwoCodes(WA.OLAnalogs[j]);
        if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
          tc.ID2:= 0;           // default - семафор отсутствия
          fnFindOrAddTwoCode(OLmarkets, tc.ID1); // коды продажных товаров
        end else tc.ID2:= -1;
      end;
    end; // for i:= 0 toHigh(aiWareByON)

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // флаг семафоров наличия
    //--------------------------------------------------------- семафоры наличия
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, iCount); // проверяем
      if (iCount>0) then begin
        for i:= 0 to WList.Count-1 do begin    // проставляем семафоры у товаров
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then // сортируем аналоги
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    iCount:= -1;

ErrorPos:='15';
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);          //------------------- передаем товары
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
//============================ поиск товаров по оригин.номеру из Laximo (WebArm)
procedure prSearchWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSearchWaresByOE'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt;       // для контрактов
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;
    pline:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csWaresByOE, UserID, FirmID, 'OE='+OE+
      #13#10'Manuf='+Manuf+#13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID)); // логирование
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту

    if (Manuf='') then raise EBOBError.Create('Некорректное значение производителя');
    if (OE='') then raise EBOBError.Create('Некорректное значение оригинального номера');

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

    mess:= MessText(mtkNotFoundWares)+' с оригинальным номером "'+OE+'"';
    iListM:= TIntegerList.Create; // коды производителей
    iListW:= TIntegerList.Create; // коды товаров
    try
      i:= Cache.BrandLaximoList.IndexOf(Manuf);
      if (i>-1) then begin
        lst:= TIntegerList(Cache.BrandLaximoList.Objects[i]);
        for i:= 0 to lst.Count-1 do iListM.Add(lst[i]);
      end;
      m:= fnInStrArray(Manuf, arManufDuo);
      if (m>-1) then begin
        if Odd(m) then ManufDuo:= arManufDuo[m-1] // нечетный индекс
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
      for m:= 0 to iListM.Count-1 do try //------ собираем коды товаров в iListW
        ManufID:= iListM[m];
        if not Cache.FDCA.Manufacturers.ManufExists(ManufID) then continue;
        i:= Cache.FDCA.SearchOriginalNum(ManufID, OE);
        if (i<0) then continue;

        aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // товары к ОН
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

      //-------- собираем коды продажных товаров для семафоров и наличия моделей
      for i:= 0 to iListW.Count-1 do begin
        WareID:= iListW[i];
        ware:= Cache.GetWare(WareID);
        flMarket:= ware.IsMarketWare(ffp);
        try
          aiAnalogs:= fnGetAllAnalogs(WareID);
          aiSatells:= ware.GetSatellites; // сопут.товары
          WA:= TSearchWareOrOnum.Create(WareID, Length(aiSatells), True, flMarket, aiAnalogs);
        finally
          SetLength(aiAnalogs, 0);
          SetLength(aiSatells, 0);
        end;
        if flMarket then fnFindOrAddTwoCode(OLmarkets, WA.ID); // коды продажных товаров
        WList.Add(WA);

        if not ShowAnalogs then Continue;

        for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
          tc:= TTwoCodes(WA.OLAnalogs[j]);
          if Cache.GetWare(tc.ID1).IsMarketWare(ffp) then begin
            tc.ID2:= 0;           // default - семафор отсутствия
            fnFindOrAddTwoCode(OLmarkets, tc.ID1); // коды продажных товаров
          end else tc.ID2:= -1;
        end;
      end; // for i:= 0 to iListW.Count
    finally
      prFree(iListM);
      prFree(iListW);
    end;

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // флаг проверки семафоров наличия
    //--------------------------------------------------------- семафоры наличия
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, iCount); // проверяем
      if (iCount>0) then begin
        for i:= 0 to WList.Count-1 do begin    // проставляем семафоры у товаров
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);

          if not ShowAnalogs then Continue;

          for j:= 0 to WA.OLAnalogs.Count-1 do begin // аналоги
            tc:= TTwoCodes(WA.OLAnalogs[j]);
            if (tc.ID2=0) then tc.ID2:= fnGetID2byID1Def(OLmarkets, tc.ID1, 0);
          end;
          if (WA.OLAnalogs.Count>1) then // сортируем аналоги товара
            WA.OLAnalogs.Sort(SearchWareAnalogsSortCompare);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    iCount:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);    // нашли товары по ОЕ
    Stream.WriteStr(Manuf);
    Stream.WriteStr(Cache.GetCurrName(ffp.CurrID, ffp.ForClient));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(WList.Count);          //------------------- передаем товары
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
//================================ поиск товаров по значениям атрибутов (WebArm)
procedure prCommonSearchWaresByAttr(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonSearchWaresByAttr'; // имя процедуры/функции
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
    aCount:= Stream.ReadInt;  // кол-во атрибутов
    try
      if (aCount<1) then raise EBOBError.Create(MessText(mtkNotParams));
      SetLength(attCodes, aCount);
      SetLength(valCodes, aCount);
      for i:= 0 to aCount-1 do begin
        attCodes[i]:= Stream.ReadInt;
        valCodes[i]:= Stream.ReadInt;
        if (i=0) then flGBatt:= (attCodes[i]>cGBattDelta);
        if (grpID<1) then //------------------ вычисляем группу для логирования
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
      ContID:= Stream.ReadInt; // для контрактов
    finally
      prSetThLogParams(ThreadData, csSearchWaresByAttrValues, UserId, FirmID,
        'pCount='+IntToStr(aCount)+#13#10'grpID='+IntToStr(grpID)+
        #13#10'ContID='+IntToStr(ContID)+#13#10'ForFirmID='+IntToStr(ForFirmID));
    end;
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);

    if flGBatt then begin // атрибуты Grossbee
      for i:= 0 to aCount-1 do begin  // снимаем сдвиги кодов
        attCodes[i]:= attCodes[i]-cGBattDelta;
        valCodes[i]:= valCodes[i]-cGBattDelta;
      end;
      attCodes:= Cache.SearchWaresByGBAttValues(attCodes, valCodes);

    end else // атрибуты ORD
      attCodes:= Cache.SearchWaresByAttrValues(attCodes, valCodes);

    if (Length(attCodes)<1) then raise EBOBError.Create(MessText(mtkNotFoundWares));

    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    //---------- собираем коды продажных товаров для семафоров и наличия моделей
    for i:= 0 to High(attCodes) do begin
      ware:= Cache.GetWare(attCodes[i]);
      if ware.IsPrize then Continue;
      flMarket:= ware.IsMarketWare(ffp);
      if not flMarket then Continue; // здесь нужны только продажные товары
      try
        aar:= ware.GetSatellites; // сопут.товары
        WA:= TSearchWareOrOnum.Create(attCodes[i], Length(aar), True, flMarket);
      finally
        SetLength(aar, 0);
      end;
      fnFindOrAddTwoCode(OLmarkets, WA.ID); // коды продажных товаров
      WList.Add(WA);
    end; // for i:= 0 to List.Count

    flSemafores:= (ffp.ForClient or (ffp.ForFirmID>0)) and (OLmarkets.Count>0); // флаг семафоров наличия
    //--------------------------------------------------------- семафоры наличия
    if flSemafores then begin
      prCheckWareRestsExists(ffp, OLmarkets, aCount); // проверяем
      if (aCount>0) then begin
        for i:= 0 to WList.Count-1 do begin    // проставляем семафоры у товаров
          WA:= TSearchWareOrOnum(WList[i]);
          if (WA.RestSem=0) then WA.RestSem:= fnGetID2byID1Def(OLmarkets, WA.ID, 0);
        end; // for i:= 0 to WList.Count
      end; // if (aCount>0)
    end; // if flSemafores
    if (WList.Count>1) then WList.Sort(SearchWareOrONSortCompare); // сортируем товары
    aCount:= -1;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(false); // для совместимости
    Stream.WriteInt(WList.Count);          //------------------- передаем товары
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
//=============================== вывод семафоров наличия товаров (Web & WebArm)
procedure prCommonGetRestsOfWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetRestsOfWares'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    WareCodes:= Stream.ReadStr;

    prSetThLogParams(ThreadData, csGetRestsOfWares, UserID, FirmID, // логирование
      'WareCodes='+WareCodes+' ModelID='+IntToStr(ModelID)+' NodeID='+IntToStr(NodeID)+
      ' ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID));

    iCount:= 0;
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    iPos:= Stream.Position;
    Stream.WriteInt(iCount);

    if WareCodes='' then Exit;

    if (FirmID<>IsWe) then ForFirmID:= FirmID
    else if (ForFirmID<1) then Exit; // не надо передавать при ForFirmID<1

    First:= fnSplitString(WareCodes, ',');
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
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
    if (Length(StorageCodes)<1) then Exit; // не найдены склады

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
      Stream.WriteInt(aeSuccess); // просто ничего не красим
      Stream.WriteInt(0);
    end;
  end;
  Stream.Position:= 0;
  SetLength(First, 0);
  SetLength(Second, 0);
  SetLength(StorageCodes, 0);
end;
{//======================================================= передать реквизиты к/а
procedure prWebArmGetFirmInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmInfo'; // имя процедуры/функции
var EmplID, ForFirmID, LineCount, sPos, k, i, ContID: integer;
    s: string;
    firm: TFirmInfo;
    Contract: TContract;
    fl: boolean;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    EmplID:= Stream.ReadInt;          // код юзера
    ForFirmID:= Stream.ReadInt;          // код контрагента
//    ContID:= Stream.ReadInt; // для контрактов - функция уходит

    prSetThLogParams(ThreadData, csGetClientData, EmplID, 0, 'FirmID='+IntToStr(ForFirmID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s);
    if not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    Cache.TestFirms(ForFirmID, True, True, False);
    if not Cache.FirmExist(ForFirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));
    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно

    Stream.WriteStr(firm.Name);   // наименование фирмы
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
    if not fl then Stream.WriteInt(Contract.WhenBlocked); // если отгрузка не блокирована

    //-------------- передаем все склады резервирования контракта фирмы
    LineCount:= 0;       // счетчик
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  место под кол-во складов
    for i:= 0 to High(Contract.ContStorages) do if Contract.ContStorages[i].IsReserve then begin
      k:= Contract.ContStorages[i].DprtID;
      if not Cache.CheckEmplVisStore(EmplID, ForFirmID) then Continue; // проверка видимости склада сотруднику
      Stream.WriteInt(k);                        // код склада
      Stream.WriteStr(Cache.GetDprtMainName(k)); // наименование склада
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
//=================================== показать остатки по товару и складам фирмы
procedure prWebArmShowFirmWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmShowFirmWareRests'; // имя процедуры/функции
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
    ContID:= Stream.ReadInt; // для контрактов

    prSetThLogParams(ThreadData, csWebArmShowFirmWareRests, EmplID, 0, // логирование
      'ForFirmID='+IntToStr(ForFirmID)+' WareID='+IntToStr(WareID)+#13#10'ContID='+IntToStr(ContID));

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FirmExist(ForFirmID) // проверка фирмы
      {or not Cache.CheckEmplVisFirm(EmplID, ForFirmID)} then
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    Ware:= Cache.GetWare(WareID, True);
    if not Assigned(Ware) or (Ware=NoWare) or Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteStr(Ware.Name); // наименование товара

    //------------------------------- передаем остатки по всем складам контракта
    LineCount:= 0;       // счетчик
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  место под кол-во складов

    k:= Contract.MainStorage;
    Rest:= 0;
    if Assigned(ware.RestLinks) then begin
      link:= ware.RestLinks[k];
      if Assigned(link) then Rest:= link.Qty;
    end;
    Stream.WriteStr(Cache.GetDprtMainName(k));     // наименование главного склада
    Stream.WriteStr(IntToStr(round(Rest)));        // кол-во
    inc(LineCount);
    dprt:= Cache.arDprtInfo[k];
    for i:= 0 to dprt.StoresFrom.Count-1 do begin
      k:= TTwoCodes(dprt.StoresFrom[i]).ID1;
      Rest:= 0;
      if Assigned(ware.RestLinks) then begin
        link:= ware.RestLinks[k];
        if Assigned(link) then Rest:= link.Qty;
      end;
      Stream.WriteStr(Cache.GetDprtMainName(k));     // наименование склада поставки
      Stream.WriteStr(IntToStr(round(Rest)));        // кол-во
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
//====================================== передать список счетов с учетом фильтра
procedure prWebArmGetFilteredAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFilteredAccountList'; // имя процедуры/функции
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
    EmplID      := Stream.ReadInt;    // код сотрудника
    filtFromDate:= Stream.ReadDouble; // дата от, 0 - не задана
    filtToDate  := Stream.ReadDouble; // дата до, 0 - не задана
    filtCurrency:= Stream.ReadInt;    // код валюты, <1 - все
    filtStorage := Stream.ReadInt;    // код склада, <1 - все
    filtShipMethod:= Stream.ReadInt;    // код метода отгрузки, <1 - все
    filtShipDate:= Stream.ReadDouble; // дата отгрузки, 0 - не задана
    filtShipTimeID:= Stream.ReadInt;    // код времени отгрузки, <1 - все
    filtExecuted:= Stream.ReadBool;   // исполненные: False - не показывать, True - показывать
    filtAnnulated:= Stream.ReadBool;   // аннулированые: False - не показывать, True - показывать
    filtProcessed:= Stream.ReadInt;    // -1 - все, 0 - необработанные, 1 - обработанные
    filtWebAccount:= Stream.ReadInt;    // -1 - все, 0 - не Web-счета, 1 - Web-счета
    filtBlocked := Stream.ReadInt;    // -1 - все, 0 - не блокированные, 1 - блокированные
    filtForFirmID:= Stream.ReadInt;    // код контрагента, <1 - все
    filtContractID:= Stream.ReadInt;    // код контракта, <1 - все

    prSetThLogParams(ThreadData, csLoadAccountList, EmplID, 0, 'filtForFirmID='+IntToStr(filtForFirmID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    s:= ''; // формируем строку условий фильтра
    if (filtForFirmID>0) then begin         // если задана фирма - проверка видимости
      if not Cache.FirmExist(filtForFirmID) {or not Cache.CheckEmplVisFirm(EmplID, filtForFirmID)} then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
      s:= s+fnIfStr(s='', '', ' and ')+' PInvRecipientCode='+IntToStr(filtForFirmID);
    end;
    if (filtContractID>0) then begin
      if not Cache.Contracts.ItemExists(filtContractID) then
        raise EBOBError.Create(MessText(mtkNotFoundCont));
      s:= s+fnIfStr(s='', '', ' and ')+' PINVCONTRACTCODE='+IntToStr(filtContractID);
    end;
    if (filtStorage>0) then begin           // если задан склад - проверка видимости
      if not Cache.DprtExist(filtStorage) {or not Cache.CheckEmplVisStore(EmplID, filtStorage)} then
        raise EBOBError.Create(MessText(mtkNotDprtExists));
      s:= s+fnIfStr(s='', '', ' and ')+' PInvSupplyDprtCode='+IntToStr(filtStorage);
    end else s:= s+fnIfStr(s='', '', ' and ')+' not PInvSupplyDprtCode is null';

    if Cache.DocmMinDate>filtFromDate then filtFromDate:= Cache.DocmMinDate;
    if (filtFromDate>DateNull) then               // дата от
      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate>=:filtFromDate';
    if (filtToDate>DateNull) then begin           // если задана дата до
      if (Cache.DocmMinDate>filtToDate) then filtToDate:= Cache.DocmMinDate;
      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate<=:filtToDate';
    end;
//    if (filtFromDate<1) and (filtToDate<1) then // если от/до не заданы - за месяц        ???
//      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate>DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_TIMESTAMP)-30, CURRENT_TIMESTAMP)';

    if (filtCurrency>0) then begin              // если задана валюта
      if not Cache.CurrExists(filtCurrency) then raise EBOBError.Create('Не найдена валюта');
      s:= s+fnIfStr(s='', '', ' and ')+' PInvCrncCode='+IntToStr(filtCurrency);
    end;
    if not filtExecuted then                   // исполненные не показывать
      s:= s+fnIfStr(s='', '', ' and ')+' (SbCnCode is null or INVCCODE is null)';
    if not filtAnnulated then                  // аннулированые не показывать
      s:= s+fnIfStr(s='', '', ' and ')+' PINVANNULKEY="F"';
    if (filtProcessed>-1) then                 // необработанные/обработанные
      if (filtProcessed=0) then s:= s+fnIfStr(s='', '', ' and ')+' PINVPROCESSED="F"'
      else if (filtProcessed=1) then s:= s+fnIfStr(s='', '', ' and ')+' PINVPROCESSED="T"';
    if (filtBlocked>-1) then                   // не блокированные/блокированные
      if (filtBlocked=0) then s:= s+fnIfStr(s='', '', ' and ')+' PInvLocked="F"'
      else if (filtBlocked=1) then s:= s+fnIfStr(s='', '', ' and ')+' PInvLocked="T"';
    if (filtWebAccount>-1) then                 // не Web-счета/Web-счета
      if (filtWebAccount=0) then
        s:= s+fnIfStr(s='', '', ' and ')+' (PINVWEBCOMMENT is null or PINVWEBCOMMENT="")'
      else if (filtWebAccount=1) then
        s:= s+fnIfStr(s='', '', ' and ')+' (not PINVWEBCOMMENT is null and PINVWEBCOMMENT>"")';
    if (filtShipDate>DateNull) then                    // если задана дата отгрузки
      s:= s+fnIfStr(s='', '', ' and ')+' PINVSHIPMENTDATE=:filtShipDate';
    if (filtShipMethod>0) then begin            // если задан метод отгрузки
      if not Cache.ShipMethods.ItemExists(filtShipMethod) then
        raise EBOBError.Create('Не найден метод отгрузки');
      if (filtShipTimeID>0) and Cache.GetShipMethodNotTime(filtShipMethod) then
        raise EBOBError.Create('Этот метод отгрузки - без указания времени');
      s:= s+fnIfStr(s='', '', ' and ')+' PINVSHIPMENTMETHODCODE='+IntToStr(filtShipMethod);
    end;
    if (filtShipTimeID>0) then begin            // если задано время отгрузки
      if not Cache.ShipTimes.ItemExists(filtShipTimeID) then
        raise EBOBError.Create('Не найдено время отгрузки');
      s:= s+fnIfStr(s='', '', ' and ')+' PINVSHIPMENTTIMECODE='+IntToStr(filtShipTimeID);
    end;

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select PInvCode, PInvNumber, PInvDate, PInvSumm, PINVPROCESSED,'+
        ' PInvLocked, PINVCLIENTCOMMENT, PInvCrncCode, u.uslsusername, PINVSHIPMENTDATE,'+ // отгрузка
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
        '   and pp.ProtObjectType=55 and pp.ProtOperType=1'+ // создатель счета
        ' left join userlist u on u.UsLsUserID=pp.ProtUserID'+
        ' WHERE '+s+' ORDER BY PInvNumber';
      if (filtFromDate>DateNull) then GBIBS.ParamByName('filtFromDate').AsDateTime:= filtFromDate;
      if (filtToDate>DateNull)   then GBIBS.ParamByName('filtToDate').AsDateTime:= filtToDate;
      if (filtShipDate>DateNull) then GBIBS.ParamByName('filtShipDate').AsDateTime:= filtShipDate;
      GBIBS.ExecQuery;

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
      sPos:= Stream.Position;
      Stream.WriteInt(0); // место под кол-во счетов
      j:= 0;
      while not GBIBS.EOF do begin
        sid:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger; // проверяем склад
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
        fid:= GBIBS.FieldByName('PInvRecipientCode').AsInteger;  // проверяем к/а
        flSkip:= False;
        if (filtForFirmID<>fid) then with Cache do
          flSkip:= not FirmExist(fid); // or not CheckEmplVisFirm(EmplID, fid);
        if flSkip then begin
          GBIBS.Next;
          Continue;
        end;
        Stream.WriteBool(GetBoolGB(GBibs, 'PInvLocked'));  // признак блокировки счета
        Stream.WriteInt(GBIBS.FieldByName('PInvCode').AsInteger);
        Stream.WriteBool(GetBoolGB(GBibs, 'PINVPROCESSED'));         // обработан
        Stream.WriteBool(GetBoolGB(GBibs, 'PINVANNULKEY'));          // аннулирован
        Stream.WriteBool(GetBoolGB(GBibs, 'pExecuted'));             // исполнен
        Stream.WriteBool(CheckShipmentDateTime(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDate,
                         GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger));   // просрочена доставка
        Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString);
        Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('PInvDate').AsDateTime));
        Stream.WriteInt(fid);                                        // код к/а
        Stream.WriteStr(Cache.arFirmInfo[fid].Name);                 // наименование к/а
        Stream.WriteInt(GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger);
        Stream.WriteBool(False); // заглушка - is moto
//        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString+'-'+
//          FormatDateTime('yy', GBIBS.FieldByName('CONTBEGININGDATE').AsDateTime));
        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString);
        Stream.WriteInt(sid);                                        // склад
        Stream.WriteDouble(GBIBS.FieldByName('PInvSumm').AsFloat);
        Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('PInvCrncCode').AsInteger, False));
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger); // метод отгрузки
        Stream.WriteDouble(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDate);       // дата отгрузки
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger);   // время отгрузки
        Stream.WriteStr(GBIBS.FieldByName('uslsusername').AsString);            // создатель счета
        Stream.WriteStr(GBIBS.FieldByname('PINVCOMMENT').AsString);
        Stream.WriteStr(fnReplaceQuotedForWeb(GBIBS.FieldByname('PINVCLIENTCOMMENT').AsString));

        cntsGRB.TestSuspendException;
        GBIBS.Next;
        Inc(j);
      end;
      GBIBS.Close;
      if (j>0) then begin
        Stream.Position:= sPos;
        Stream.WriteInt(j); // передаем кол-во
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
//===================================== показать счет (если нет - создать новый)
procedure prWebArmShowAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmShowAccount'; // имя процедуры/функции
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
  //----------------------------------------- проверка фирмы
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
    ContID:= Stream.ReadInt;       // для контрактов - здесь не нужен

    AccountCode:= IntToStr(AccountID);
    FirmCode:= IntToStr(ForFirmID);

    prSetThLogParams(ThreadData, csWebArmShowAccount, EmplID, 0,
      'ForFirmID='+FirmCode+' AccountID='+AccountCode+#13#10'ContID='+IntToStr(ContID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if (ForFirmID>0) then CheckFirm(ForFirmID);  // проверка фирмы (если задан ForFirmID)

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead);
//------------------------------ новый счет ------------------------------------
      if (AccountID=-1) and Assigned(Firm) then begin
        k:= Contract.MainStorage; // склад по умолчанию
        fnSetTransParams(GBIBS.Transaction, tpWrite, True);
        curr:= Contract.DutyCurrency;
        GBIBS.SQL.Text:= 'Select NewAccCode, NewDprtCode'+ // получаем код нового счета
          ' from Vlad_CSS_AddAccHeaderC('+FirmCode+', '+IntToStr(ContID)+', '+
          IntToStr(k)+', '+IntToStr(curr)+', "")';

        Success:= false;
        for i:= 1 to RepeatCount do try
          GBIBS.Close;
          with GBIBS.Transaction do if not InTransaction then StartTransaction;
          GBIBS.ExecQuery;
          if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('Ошибка создания счета');

          if GBIBS.FieldByName('NewDprtCode').AsInteger<>k then // проверка замены склада (на всяк.случай)
            raise EBOBError.Create('Ошибка создания счета по складу '+Cache.GetDprtMainName(k));

          AccountID:= GBIBS.FieldByName('NewAccCode').AsInteger;
          AccountCode:= IntToStr(AccountID);

          GBIBS.Close;
          GBIBS.SQL.Text:= 'update PayInvoiceReestr set'+ // пишем комментарий сотрудникам
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
        if not Success then raise EBOBError.Create('Ошибка создания счета');

        fnSetTransParams(GBIBS.Transaction, tpRead);
      end;
//------------------------------- создали новый счет ---------------------------

      with GBIBS.Transaction do if not InTransaction then StartTransaction;
      GBIBS.SQL.Text:= 'SELECT p1.PInvNumber, p1.PInvDate, p1.PInvProcessed, p1.PInvSumm,'+
        ' p1.PInvCrncCode, p1.PInvSupplyDprtCode, p1.PINVCOMMENT, p1.PINVWEBCOMMENT,'+
        ' p1.PINVCLIENTCOMMENT, p1.PInvLocked, p1.PINVWARELINECOUNT, p1.PINVANNULKEY,'+
        ' p2.PInvNumber AcntNumber, p2.PInvDate AcntDate, INVCCODE, u.uslsusername,'+
        ' p1.PINVSHIPMENTDATE,'+ // отгрузка
        ' iif(TRTBSHIPMETHODCODE is null, p1.PINVSHIPMENTMETHODCODE, TRTBSHIPMETHODCODE) PINVSHIPMENTMETHODCODE,'+
        ' iif(TRTBSHIPTIMECODE is null, p1.PINVSHIPMENTTIMECODE, TRTBSHIPTIMECODE) PINVSHIPMENTTIMECODE,'+
        ' p1.PInvRecipientCode, p2.PInvCode AcntCode, p1.PINVLABELCODE, p1.PINVCONTRACTCODE'+
        ' from PayInvoiceReestr p1'+
        ' left join TRANSPORTTIMETABLESLINES on TRTBLNCODE=p1.pinvtripcode'+
        ' left join TRANSPORTTIMETABLESREESTR tt on tt.TRTBCODE=TRTBLNDOCMCODE'+
        ' left join PROTOCOL pp on pp.ProtObjectCode=p1.pinvcode'+
        '   and pp.ProtObjectType=55 and pp.ProtOperType=1'+ // создатель счета
        ' left join userlist u on u.UsLsUserID=pp.ProtUserID'+
        ' left join PayInvoiceReestr p2 on p2.PInvCode=p1.PINVSOURCEACNTCODE'+
        ' left join SUBCONTRACT on SbCnDocmCode=p1.PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' where p1.PInvCode='+AccountCode;
      GBIBS.ExecQuery;
      if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('Не найден счет с id='+AccountCode);
      s:= 'Счет '+GBIBS.FieldByName('PInvNumber').AsString;

//-------------------- запреты на просмотр счета ------------------------------- ???
//      if GetBoolGB(GBibs, 'PInvLocked') then raise EBOBError.Create(s+' блокирован');
//      if GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s+' аннулирован');
//      if GBIBS.FieldByName('INVCCODE').AsInteger>0 then raise EBOBError.Create(s+' недоступен');
//-------------------- запреты на просмотр счета -------------------------------

                                    // проверка фирмы (если не задан ForFirmID)
      if (ForFirmID<1) then CheckFirm(GBIBS.FieldByName('PInvRecipientCode').AsInteger);

      Stream.Clear;
      Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
      Stream.WriteBool(GetBoolGB(GBibs, 'PInvLocked'));
      Stream.WriteBool(GetBoolGB(GBibs, 'PINVANNULKEY'));
      Stream.WriteBool(GBIBS.FieldByName('INVCCODE').AsInteger>0);
//-------------------- передаем заголовок счета --------------------------------
      Stream.WriteInt(ForFirmID);                                       // код получателя
      Stream.WriteStr(firm.UPPERSHORTNAME);                             // краткое наим. получателя
      Stream.WriteStr(firm.Name);                                       // наим. получателя
      i:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      contID:= i;
      if (Contract.ID<>contID) then Contract:= firm.GetContract(contID);
      if (i<>ContID) then raise EBOBError.Create(MessText(mtkNotFoundCont, IntToStr(i)));
      Stream.WriteInt(contID);                                          // код контракта
      Stream.WriteStr(Contract.Name);                                   // наименование контракта
      Stream.WriteInt(Firm.FirmContracts.Count);                        // кол-во контрактов
//      Stream.WriteBool(Contract.SysID=constIsAuto);                     // Является ли автоконтрактом
      Stream.WriteBool(true);                     // заглушка
      iStore:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
      Stream.WriteInt(iStore);                                          // код склада счета
      curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
      Stream.WriteStr(Cache.GetCurrName(curr, False));                  // валюта счета
      Stream.WriteInt(AccountID);                                       // код счета
      Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString);        // номер счета
      Stream.WriteDouble(GBIBS.FieldByName('PInvDate').AsDateTime);     // дата
      Stream.WriteBool(GetBoolGB(GBIBS, 'PInvProcessed'));              // признак обработки

//      Stream.WriteBool(GetBoolGB(GBIBS, 'PInvLocked'));                // признак блокировки   ???

      sum:= GBIBS.FieldByName('PInvSumm').AsFloat;                      // сумма счета
      s:= fnGetStrSummByDoubleCurr(sum, curr);                          // строка с суммой в 2-х валютах
      Stream.WriteStr(s);
      Stream.WriteStr(GBIBS.FieldByName('PINVCOMMENT').AsString);       // комментарий сотрудникам
      Stream.WriteStr(GBIBS.FieldByName('PINVWEBCOMMENT').AsString);    // комментарий WEB
      Stream.WriteStr(fnReplaceQuotedForWeb(GBIBS.FieldByName('PINVCLIENTCOMMENT').AsString)); // комментарий клиенту
      Stream.WriteInt(GBIBS.FieldByName('AcntCode').AsInteger);         // код родительского счета
      s:= GBIBS.FieldByName('AcntNumber').AsString;                     // номер и дата родительского счета
      if s<>'' then s:= s+' от '+
        FormatDateTime(cDateFormatY2, GBIBS.FieldByName('AcntDate').AsDateTime);
      Stream.WriteStr(s);
      Stream.WriteStr(GBIBS.FieldByName('uslsusername').AsString);      // создатель счета (оператор)

      with Cache.GetShipMethodsList(iStore) do try                      // список методов отгрузки по складу
        Stream.WriteInt(Count);
        for i:= 0 to Count-1 do begin
          Stream.WriteInt(Integer(Objects[i]));
          Stream.WriteStr(Strings[i]);
        end;
      finally
        Free;
      end;
      i:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
      Stream.WriteInt(i);                                                   // код метода отгрузки
      if Cache.GetShipMethodNotTime(i) then k:= -1
      else k:= GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger;
      Stream.WriteInt(k);                                                   // код времени отгрузки
      Stream.WriteDouble(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDateTime); // дата отгрузки

      if Cache.GetShipMethodNotLabel(i) then k:= -1
      else k:= GBIBS.FieldByName('PINVLABELCODE').AsInteger;
      Stream.WriteInt(k);                                                   // код наклейки

      LineCount:= GBIBS.FieldByName('PINVWARELINECOUNT').AsInteger; // кол-во строк товаров в счете
      GBIBS.Close;

      sh:= IntToStr(Cache.arFirmInfo[ForFirmID].HostCode);          // список наклеек клиента
      GBIBS.SQL.Text:= 'select FRLBCODE, FRLBNAME, FRLBFACENAME, FRLBPHONE,'+
        ' " " as FRLBCARRIER, FRLBDELIVERYTIME, FRLBCOMMENT from FIRMLABELREESTR'+   // поле FRLBCARRIER убрали
        ' where FRLBSUBJCODE='+sh+' and FRLBSUBJTYPE=1 and (FRLBARCHIVE="F" or FRLBCODE='+intToStr(k)+') ';
      sPos:= Stream.Position;
      k:= 0;
      Stream.WriteInt(0);  //  место под кол-во наклеек
      GBIBS.ExecQuery;
      while not GBIBS.EOF do begin
        Inc(k);
        Stream.WriteInt(GBIBS.FieldByName('FRLBCODE').AsInteger);        // код наклейки
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
//-------------------- передали заголовок счета --------------------------------

      sPos:= Stream.Position;
      Stream.WriteInt(0);  //  место под кол-во строк
      if LineCount>0 then begin
//-------------------- передаем товары счета -----------------------------------
        LineCount:= 0;       // счетчик - кол-во строк
        GBIBS.SQL.Text:= 'select PInvLnCode, PInvLnWareCode, PInvLnOrder, PInvLnCount, PInvLnPrice'+
          ' from PayInvoiceLines where PInvLnDocmCode='+AccountCode;
        GBIBS.ExecQuery;
        while not GBIBS.EOF do begin
          k:= GBIBS.FieldByName('PInvLnWareCode').AsInteger;
          Ware:= Cache.GetWare(k, True);
          if not Assigned(Ware) or (Ware=NoWare) or Ware.IsArchive then
            raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(k)));

          Stream.WriteInt(GBIBS.FieldByName('PInvLnCode').AsInteger); // код строки
          Stream.WriteInt(k);                                         // код товара
          Stream.WriteStr(Ware.Name);                                 // наименование товара
          Stream.WriteStr(GBIBS.FieldByName('PInvLnOrder').AsString); // заказ
          Stream.WriteStr(GBIBS.FieldByName('PInvLnCount').AsString); // факт
          Stream.WriteStr(Ware.MeasName);                             // наименование ед.изм.
          sum:= GBIBS.FieldByName('PInvLnPrice').AsFloat;
          s:= fnGetStrSummByDoubleCurr(sum, curr);                    // цена в 2-х валютах
          Stream.WriteStr(s);
          if GBIBS.FieldByName('PInvLnCount').AsFloat=1 then
            Stream.WriteStr(s)
          else begin
            sum:= RoundToHalfDown(sum*GBIBS.FieldByName('PInvLnCount').AsFloat);
            s:= fnGetStrSummByDoubleCurr(sum, curr);
            Stream.WriteStr(s);                                       // сумма по строке в 2-х валютах
          end;
          Stream.WriteStr(Ware.Comment);                              // комментарий

          inc(LineCount);
          TestCssStopException;
          GBIBS.Next;
        end;
        if LineCount>0 then begin
          Stream.Position:= sPos;
          Stream.WriteInt(LineCount);
        end;
//-------------------- передали товары счета -----------------------------------
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
//=============================================== редактирование заголовка счета
procedure prWebArmEditAccountHeader(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmEditAccountHeader'; // имя процедуры/функции
      sNot = 'Нет изменений';
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
  //----------------------------------------- проверка фирмы
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
  //----------------------------------------- проверка склада фирмы
  procedure CheckForFirmStore(StoreID: Integer);
//  var i: Integer;
  begin
//    i:= Contract.GetСontStoreIndex(StoreID);
//    if (i<0) then raise EBOBError.Create('Не найден склад резервирования');
//    if not Contract.ContStorages[i].IsReserve then
//    if not Contract.ContStorages[i].IsDefault then
    if (Contract.MainStorage<>StoreID) then
      raise EBOBError.Create('Склад недоступен для резервирования');
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
    ParamID:= Stream.ReadInt;    // вид параметра
    ParamStr:= Stream.ReadStr;   // значение параметра
    if (ParamID=ceahAnnulateInvoice) then
      ParamStr2:= Stream.ReadStr;   // значение параметра2

    AccountCode:= IntToStr(AccountID);

    prSetThLogParams(ThreadData, csWebArmEditAccountHeader, EmplID, 0, ' AccountID='+AccountCode+
      ' ParamID='+IntToStr(ParamID)+' ParamStr='+ParamStr); // логирование

    if CheckNotValidUser(EmplID, isWe, s1) then raise EBOBError.Create(s1); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя
      raise EBOBError.Create(MessText(mtkNotRightExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      sWhere:= ' where PInvCode='+AccountCode;

//------------------------------ имя проверяемого поля -------------------------
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
      if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('Не найден счет с id='+AccountCode);
      s1:= 'Счет '+GBIBS.FieldByName('PInvNumber').AsString;
//-------------------- запреты на изменение счета ------------------------------ ???
      if GetBoolGB(GBibs, 'PInvLocked') then raise EBOBError.Create(s1+' блокирован');
      if ((ParamID<>ceahAnnulateInvoice) or (ParamStr<>'F'))
        and GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s1+' аннулирован');
//      if GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s1+' аннулирован');
      if GBIBS.FieldByName('INVCCODE').AsInteger>0 then raise EBOBError.Create(s1+' недоступен');
//-------------------- запреты на изменение счета ------------------------------

      LineCount:= GBIBS.FieldByName('PINVWARELINECOUNT').AsInteger; // проверка, есть ли товары в счете    ???
      ForFirmID:= GBIBS.FieldByName('PInvRecipientCode').AsInteger;
      contID:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      kk:= contID;
      CheckFirm(ForFirmID); // проверка фирмы

//------------------- подготовка, проверка корректности значений ---------------
      case ParamID of
      ceahChangeContract: begin //------------------------------------- контракт
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVCONTRACTCODE';
          if kk=k then raise EBOBError.Create(sNot);
          if not Cache.Contracts.ItemExists(k) then
            raise EBOBError.Create(MessText(mtkNotFoundCont));
          contID:= k;
          Contract:= firm.GetContract(contID);
          if (contID<>k) then raise EBOBError.Create(MessText(mtkNotFoundCont));
          kk:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
          CheckForFirmStore(kk); // проверка соответствия склада новому контракту фирмы
//          fl:= False;
          k:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
          fl:= (k<>Cache.BonusCrncCode) and (k<>Contract.DutyCurrency); // признак смены валюты
          if fl then begin
            CrncCode:= IntToStr(Contract.DutyCurrency);
            ParamStr:= ParamStr+', PInvCrncCode='+CrncCode;
          end;
          fl:= fl and (LineCount>0);       // признак необходимости пересчета цен
        end;

      ceahChangeStorage: begin //----------------------------------------- склад
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PInvSupplyDprtCode';
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if not Cache.DprtExist(k) then raise EBOBError.Create('Не найден склад');
          CheckForFirmStore(k); // проверка склада контракта фирмы
          kk:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
                          // проверяем доступность метода отгрузки новому складу
          if (kk>0) and Cache.ShipMethods.ItemExists(kk) then begin
            with Cache.GetShipMethodsList(k) do try // список методов отгрузки по новому складу
              fl:= False;
              for i:= 0 to Count-1 do begin
                fl:= (Integer(Objects[i])=kk);
                if fl then break;
              end;
            finally Free; end;
            if not fl then raise EBOBError.Create('Метод отгрузки недоступен для склада');
          end;
        end;

      ceahChangeCurrency: begin //--------------------------------------- валюта
          k:= StrToIntDef(ParamStr, 0);
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if not Cache.CurrExists(k) or Cache.Currencies[k].Arhived then
            raise EBOBError.Create('Не найдена валюта');
          if (contID>0) then begin
            if (k<>Cache.BonusCrncCode) and (k<>Contract.DutyCurrency) then // проверять наличие бонусных товаров ???
              raise EBOBError.Create('Валюта отличается от валюты контракта');
          end;
        end;

      ceahChangeProcessed: begin //--------------------------- признак обработки
          k:= StrToIntDef(ParamStr, 0);
          if (fnIfInt(GBIBS.FieldByName(sf).AsString='T', 1, 0)=k) then raise EBOBError.Create(sNot);
          ParamStr:= fnIfStr(k=1, '"T"', '"F"');
        end;

      ceahChangeEmplComm: begin //---------- комментарий сотрудникам (м.б.пусто)
          if (GBIBS.FieldByName(sf).AsString=ParamStr) then raise EBOBError.Create(sNot);
          k:= Length(ParamStr);
          if (k>Cache.AccEmpCommLength) then raise EBOBError.Create('Слишком длинный комментарий');
        end;

      ceahChangeClientComm: begin //------------ комментарий клиенту (м.б.пусто)
          if (GBIBS.FieldByName(sf).AsString=ParamStr) then raise EBOBError.Create(sNot);
          k:= Length(ParamStr);
          if (k>Cache.AccCliCommLength) then raise EBOBError.Create('Слишком длинный комментарий');
        end;

      ceahChangeShipMethod: begin //------------ код метода отгрузки (м.б.пусто)
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVSHIPMENTMETHODCODE';
          if (k>0) then begin
            if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
            if not Cache.ShipMethods.ItemExists(k) then
              raise EBOBError.Create('Не найден метод отгрузки');
            if (GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger>0) // сброс времени отгрузки
              and Cache.GetShipMethodNotTime(k) then
              ParamStr:= ParamStr+', PINVSHIPMENTTIMECODE=null';
            if (GBIBS.FieldByName('PINVLABELCODE').AsInteger>0)        // сброс наклейки
              and Cache.GetShipMethodNotLabel(k) then
              ParamStr:= ParamStr+', PINVLABELCODE=null';
          end else ParamStr:= 'null';
        end;

      ceahChangeShipTime: begin //------------- код времени отгрузки (м.б.пусто)
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVSHIPMENTTIMECODE';
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if (k>0) then begin
            if not Cache.ShipTimes.ItemExists(k) then
              raise EBOBError.Create('Не найдено время отгрузки');
            kk:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
            if (kk>0) and Cache.GetShipMethodNotTime(kk) then
              raise EBOBError.Create('Этот метод отгрузки - без указания времени');
          end else ParamStr:= 'null';
        end;

      ceahChangeLabel: begin   //---------------------- код наклейки (м.б.пусто)
          k:= StrToIntDef(ParamStr, 0);
          sf:= 'PINVLABELCODE';
          if GBIBS.FieldByName(sf).AsInteger=k then raise EBOBError.Create(sNot);
          if (k>0) then begin
            kk:= GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger;
            if (kk>0) and Cache.GetShipMethodNotLabel(kk) then
              raise EBOBError.Create('Этот метод отгрузки - без указания наклейки');
          end else ParamStr:= 'null';
        end;

      ceahChangeShipDate: begin //-------------------- дата отгрузки (м.б.пусто)
          if (ParamStr='') then begin
            if GBIBS.FieldByName(sf).IsNull then raise EBOBError.Create(sNot);
            dd:= 0;
          end else try
            dd:= StrToDate(ParamStr);
            if GBIBS.FieldByName(sf).AsDate=dd then raise EBOBError.Create(sNot);
            if dd<Date then raise EBOBError.Create('Старая дата');  // ???
          except
            on E: EBOBError do raise EBOBError.Create(E.Message);
            on E: Exception do raise EBOBError.Create('Некорректное значение даты');
          end;
        end;

      ceahChangeDocmDate: begin //---------------------------------- дата док-та
          try
            dd:= StrToDate(ParamStr);
            if GBIBS.FieldByName(sf).AsDate=dd then raise EBOBError.Create(sNot);
            if dd<Date then raise EBOBError.Create('Старая дата');  // ???
          except
            on E: EBOBError do raise EBOBError.Create(E.Message);
            on E: Exception do raise EBOBError.Create('Некорректное значение даты');
          end;
        end;

      ceahChangeRecipient: begin //---------------------------------- получатель
          ForFirmID:= StrToIntDef(ParamStr, 0);
          // если есть товары - запоминаем бизнес-направление прежнего контракта
          CheckFirm(ForFirmID);                // проверка фирмы
          k:= GBIBS.FieldByName(sf).AsInteger; // код склада
          sf:= 'PInvRecipientCode';
          if GBIBS.FieldByName(sf).AsInteger=ForFirmID then raise EBOBError.Create(sNot);
          CheckForFirmStore(k); // проверка склада фирмы
        end;

      ceahRecalcPrices: begin   //--------------------------------- пересчет цен
          if (LineCount<1) then raise EBOBError.Create('Нет товаров');
          ParamStr:= GBIBS.FieldByName(sf).AsString;
        end;

      ceahRecalcCounts: begin   //------------------------------- пересчет факта
          if (LineCount<1) then raise EBOBError.Create('Нет товаров');
          k:= GBIBS.FieldByName(sf).AsInteger; // код склада
          if not Cache.DprtExist(k) then raise EBOBError.Create('Не найден склад');
          CheckForFirmStore(k); // проверка склада фирмы
//          ParamStr:= '';
        end;

      ceahAnnulateInvoice: begin
          if (ParamStr<>'T') and (ParamStr<>'F') then
            raise EBOBError.Create('Неверный параметр аннуляции - "'+ParamStr+'"');
          if (ParamStr2<>'T') and (ParamStr2<>'F') then
            raise EBOBError.Create('Неверный параметр аннуляции - "'+ParamStr2+'"');
          ParamStr:= '"'+ParamStr+'", PINVUSEINREPORT="'+ParamStr2+'"';
        end;

      end;
      GBIBS.Close;

//------------------------- запись изменений -----------------------------------
      fnSetTransParams(GBIBS.Transaction, tpWrite, True);  // готовимся к записи
      s1:= 'update PayInvoiceReestr set '+sf+'=';

      case ParamID of // формируем строку SQL
        ceahChangeProcessed,           //--------------------- признак обработки
        ceahChangeShipMethod,          //------------------------ метод отгрузки
        ceahChangeShipTime,            //------------------------ время отгрузки
        ceahAnnulateInvoice,           //--- аннулирование/деаннулирование счета
        ceahChangeLabel,               //-------------------------- код наклейки
        ceahChangeContract:            //------------------------------ контракт
          GBIBS.SQL.Text:= s1+ParamStr+sWhere;

        ceahChangeEmplComm,            //--------------- комментарий сотрудникам
        ceahChangeClientComm:          //------------------- комментарий клиенту
          if (ParamStr<>'') then begin
            GBIBS.SQL.Text:= s1+':comm'+sWhere;
            GBIBS.ParamByName('comm').AsString:= ParamStr;
          end else GBIBS.SQL.Text:= s1+'null'+sWhere;

        ceahChangeShipDate:            //------------------------- дата отгрузки
          if (dd>0) then begin
            GBIBS.SQL.Text:= s1+':dd'+sWhere;
            GBIBS.ParamByName('dd').AsDate:= dd;
          end else GBIBS.SQL.Text:= s1+'null'+sWhere;

        ceahChangeDocmDate: begin      //--------------------------- дата док-та
          GBIBS.SQL.Text:= s1+':dd'+sWhere;
          GBIBS.ParamByName('dd').AsDate:= dd;
        end;

        ceahChangeRecipient:           //---------------------------- получатель
          GBIBS.SQL.Text:= s1+FirmCode+', pinvcontractcode='+IntToStr(ContID)+sWhere;

        ceahChangeStorage:             //--------------------------------- склад
          GBIBS.SQL.Text:= 'execute procedure Vlad_CSS_ChangeAccDprtC('+AccountCode+', '+ParamStr+')';

        ceahChangeCurrency,            //-------------------------------- валюта
        ceahRecalcPrices:       //--------------------------------- пересчет цен
          GBIBS.SQL.Text:= 'execute procedure Vlad_CSS_RecalcAccSummC('+AccountCode+', '+ParamStr+')';

        ceahRecalcCounts: //-- пересчет факта (возвр. стар. и нов.факт для кеша)
          GBIBS.SQL.Text:= 'select rWareCode, rOldCount, rNewCount'+
                           ' from Vlad_CSS_RecalcAccFactC('+AccountCode+')';

        else raise EBOBError.Create(MessText(mtkNotValidParam));
      end; // case

      for i:= 0 to RepeatCount do with GBIBS.Transaction do try
        Application.ProcessMessages;
        GBIBS.Close;
        if not InTransaction then StartTransaction;
        GBIBS.ExecQuery;

        if ParamID=ceahRecalcCounts then begin // запоминаем разницу факта
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

        if (ParamID=ceahChangeContract) and fl then begin // пересчет цен при смене валюты
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

      if ParamID=ceahRecalcCounts then  // снимаем разницу факта с остатков в кеше
        for kk:= 0 to High(arLineWareAndQties) do with arLineWareAndQties[kk] do
          Cache.CheckWareRest(Ware.RestLinks, k, DeltaQty, True);

    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;

//--------------------------- передаем ответ -----------------------------------
    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  SetLength(arLineWareAndQties, 0);
  Stream.Position:= 0;
end;
//============================== добавление/редактирование/удаление строки счета
procedure prWebArmEditAccountLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmEditAccountLine'; // имя процедуры/функции
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
    Option:= Stream.ReadInt; // операция - constOpAdd, constOpEdit, constOpDel, constOpEditFact
    LineID:= Stream.ReadInt; // код строки
    WareID:= Stream.ReadInt; // код товара
    cliQty:= Stream.ReadDouble; // новый заказ / факт
//    oldQty:= Stream.ReadDouble; // старый факт

    cliQty:= abs(cliQty);
    AccountCode:= IntToStr(AccountID);
    FirmCode:= IntToStr(ForFirmID);

    prSetThLogParams(ThreadData, csWebArmEditAccountLine, EmplID, 0, 'ForFirmID='+FirmCode+' AccountID='+AccountCode+
      ' Option='+IntToStr(Option)+' LineID='+IntToStr(LineID)+' cliQty='+FloatToStr(cliQty)); // логирование

    if not (Option in [constOpAdd, constOpEdit, constOpDel, constOpEditFact]) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' операции');
    if (Option<>constOpAdd) and (LineID<1) then
      raise EBOBError.Create(MessText(mtkNotValidParam)+' номера строки');

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера

    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FirmExist(ForFirmID) // проверка фирмы
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
      if GBIBS.Bof and GBIBS.Eof then raise EBOBError.Create('Не найден счет с id='+AccountCode);
      s:= 'Счет '+GBIBS.FieldByName('PInvNumber').AsString;
//-------------------- запреты на изменение счета ------------------------------ ???
      if GetBoolGB(GBibs, 'PInvLocked') then raise EBOBError.Create(s+' блокирован');
      if GetBoolGB(GBibs, 'PINVANNULKEY') then raise EBOBError.Create(s+' аннулирован');
      if GBIBS.FieldByName('INVCCODE').AsInteger>0 then raise EBOBError.Create(s+' недоступен');
//-------------------- запреты на изменение счета ------------------------------
      if (Option=constOpAdd) then begin
        oldQty:= 0;
        LineID:= 0;
      end else begin
        oldQty:= GBIBS.FieldByName('PInvLnCount').AsFloat; // старый факт
        LineID:= GBIBS.FieldByName('PInvLnCode').AsInteger;
        if LineID<1 then raise EBOBError.Create(MessText(mtkNotValidParam)+' - код строки');
      end;
      dprt:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;   // склад
      GBIBS.Close;

      fnSetTransParams(GBIBS.Transaction, tpWrite, True);

      case Option of // формируем строку SQL
      constOpAdd: begin //----------------------------------------- добавить
          if cliQty<1 then raise EBOBError.Create(MessText(mtkNotValidParam)+' количества');

          GBIBS.SQL.Text:= 'select NewLineCode, WarnMess from Vlad_CSS_AddAccLineWC('+
            AccountCode+', '+IntToStr(dprt)+', '+IntToStr(WareID)+', :CLIENTQTY)';
          GBIBS.ParamByName('CLIENTQTY').AsFloat:= cliQty;
          for i:= 0 to RepeatCount do with GBIBS.Transaction do try
            Application.ProcessMessages;
            GBIBS.Close;
            if not InTransaction then StartTransaction;
            GBIBS.ExecQuery;
            if GBIBS.Bof and GBIBS.Eof then raise Exception.Create(MessText(mtkErrAddRecord));
            LineID:= GBIBS.FieldByName('NewLineCode').AsInteger; // код новой строки
            WarnMess:= GBIBS.FieldByName('WarnMess').AsString;
            oldQty:= 0; // обнуляем старый факт
            Commit;
            break;
          except
            on E: Exception do begin
              if (pos('PRS. LockCompletionCountKey~', E.Message)>0) then
                raise EBOBError.Create('Недоступно добавление строки в синхронном режиме пополнений, '+
                  'в подразделениях нет товара в количестве '+FloatToStr(RoundTo(cliQty, -3)));
              if (i>=RepeatCount) then raise Exception.Create(E.Message);
              RollbackRetaining;
              sleep(RepeatSaveInterval);
            end;
          end;
        end; // constOpAdd

      constOpEdit, constOpEditFact: begin //-------------- изменить заказ / факт
          if (Option=constOpEditFact) then iLine:= -LineID else iLine:= LineID;  // iLine<0 - корректировка факта

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

      constOpDel: begin //----------------------------------------- удалить
          GBIBS.SQL.Text:= 'delete from PayInvoiceLines where PInvLnCode='+IntToStr(LineID);
          for i:= 0 to RepeatCount do with GBIBS.Transaction do try
            Application.ProcessMessages;
            GBIBS.Close;
            if not InTransaction then StartTransaction;
            GBIBS.ExecQuery;
            if (GBIBS.RowsAffected<1) then raise Exception.Create(MessText(mtkErrDelRecord));
            LineID:= 0; // обнуляем код строки
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
      Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
                                  //-------------------------- новая сумма счета
      GBIBS.SQL.Text:= 'SELECT PInvProcessed, PInvCrncCode, PInvSupplyDprtCode, PInvSumm'+
        ' from PayInvoiceReestr where PInvCode='+AccountCode+' and PInvRecipientCode='+FirmCode;
      GBIBS.ExecQuery;
      Stream.WriteBool(GetBoolGB(GBIBS, 'PInvProcessed'));        // признак обработки
      s:= FormatFloat(cFloatFormatSumm, GBIBS.FieldByName('PInvSumm').AsFloat);
      curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;         // валюта счета
      dprt:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;   // склад
      sum:= GBIBS.FieldByName('PInvSumm').AsFloat;                // сумма счета
      GBIBS.Close;

      s:= fnGetStrSummByDoubleCurr(sum, curr); // строка с суммой в 2-х валютах
      Stream.WriteStr(s);

      Stream.WriteInt(LineID);    // код строки (constOpDel - 0)

      if LineID>0 then begin      //-------------------- новое состояниее строки
        GBIBS.SQL.Text:= 'select PInvLnOrder, PInvLnCount, PInvLnPrice'+
          ' from PayInvoiceLines where PInvLnCode='+IntToStr(LineID);
        GBIBS.ExecQuery;

        Stream.WriteInt(WareID);                                    // код товара
        Stream.WriteStr(Ware.Name);                                 // наименование товара
        Stream.WriteStr(GBIBS.FieldByName('PInvLnOrder').AsString); // заказ
        Stream.WriteStr(GBIBS.FieldByName('PInvLnCount').AsString); // факт
        Stream.WriteStr(Ware.MeasName);                             // наименование ед.изм.

        cliQty:= GBIBS.FieldByName('PInvLnCount').AsFloat;          // новый факт
        sum:= GBIBS.FieldByName('PInvLnPrice').AsFloat;             // цена
        GBIBS.Close;

        s:= fnGetStrSummByDoubleCurr(sum, curr); // строка с ценой в 2-х валютах
        Stream.WriteStr(s);

        if cliQty=1 then Stream.WriteStr(s)                         // сумма по строке
        else begin
          sum:= RoundToHalfDown(sum*cliQty);
          s:= fnGetStrSummByDoubleCurr(sum, curr); // строка с суммой в 2-х валютах
          Stream.WriteStr(s);
        end;
        Stream.WriteStr(Ware.Comment);                             // комментарий
      end else cliQty:= 0; // обнуляем новый факт для удаленной строки

      Stream.WriteStr(WarnMess); // предупреждение о пересчете по кратности и т.п.

      Cache.CheckWareRest(Ware.RestLinks, dprt, cliQty-oldQty, True); // снимаем разницу факта с остатка в кеше
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
//================================================ строка с суммой в 2-х валютах
function fnGetStrSummByDoubleCurr(sum: Double; MainCurr: Integer; AddCurr: Integer=cDefCurrency): String;
// если MainCurr <> грн, AddCurr игнорируется и 2-я валюта - грн
var k: Integer;
    curr: Single;
begin
  Result:= '';
  if not Cache.CurrExists(MainCurr) then Exit;

  Result:= FormatFloat(cFloatFormatSumm, sum)+' '+Cache.GetCurrName(MainCurr, False); // сумма в 1-й валюте

  k:= 0;
  if (MainCurr<>cUAHCurrency) then begin //----------------------- валюта -> грн
    curr:= Cache.Currencies.GetCurrRate(MainCurr);
    if fnNotZero(curr) then k:= cUAHCurrency;

  end else begin                         //----------------------- грн -> валюта
    curr:= Cache.Currencies.GetCurrRate(AddCurr); // курс валюты к грн
    if fnNotZero(curr) then begin
      curr:= 1/curr;
      k:= AddCurr;
    end;
  end;
  if (k<1) then Exit;

  sum:= sum*curr;        // + сумма в 2-й валюте
  Result:= Result+' ('+FormatFloat(cFloatFormatSumm, sum)+' '+Cache.GetCurrName(k, False)+')';
end;
//================================ описания товаров для просмотра (счета WebArm)
procedure prWebArmGetWaresDescrView(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetWaresDescrView'; // имя процедуры/функции
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
    Stream.ReadInt; // для контрактов
    sWareCodes:= Stream.ReadStr; // коды товаров

    prSetThLogParams(ThreadData, csWebArmGetWaresDescrView, EmplID, 0,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'sWareCodes='+sWareCodes);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0);  // место под кол-во товаров

    Codes:= fnSplitString(sWareCodes, ',');
    if (Length(Codes)<1) then Exit; // товаров нет - выходим

    if CheckNotValidUser(EmplID, isWe, s) then Exit; // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then Exit; // проверяем право пользователя

    if not Cache.FirmExist(ForFirmID) // проверка фирмы
      {or not Cache.CheckEmplVisFirm(EmplID, ForFirmID)} then Exit;

    ORD_IBD:= cntsOrd.GetFreeCnt;
    try
      ORD_IBS:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS_'+nmProc);
      ORD_IBS1:= fnCreateNewIBSQL(ORD_IBD, 'ORD_IBS1_'+nmProc, -1, tpRead, true);
      //----------------------------------------------------- значения критериев
      ORD_IBS.SQL.Text:= 'select WCRICODE, WCRIDESCR, WCVSVALUE'+
        ' from (select LWCVWCVSCODE from LINKWARECRIVALUES'+
        ' where LWCVWARECODE=:WareID and LWCVWRONG="F")'+
        ' left join WARECRIVALUES on WCVSCODE=LWCVWCVSCODE'+
        ' left join WARECRITERIES on WCRICODE=WCVSWCRICODE'+
        ' order by WCRIORDNUM nulls last, WCRICODE, WCVSVALUE';
      ORD_IBS.Prepare;
        //------------------------------------------- тексты к связке товар - нода
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

      j:= 0; // счетчик товаров
      for i:= 0 to High(Codes) do begin
        WareID:= StrToIntDef(Codes[i], 0);
        if not Cache.WareExist(WareID) then Continue;

        ware:= Cache.GetWare(WareID);
        if ware.IsArchive or not ware.IsWare then Continue;

        Stream.WriteInt(WareID); // Передаем код товара
        inc(j);

        sView:= '';
        with ware.GetWareAttrValuesView do try // список названий и значений атрибутов товара (TStringList)
          for ii:= 0 to Count-1 do
            sView:= sView+fnIfStr(sView='', '', '; ')+Names[ii]+': '+ // название атрибута
                    ExtractParametr(Strings[ii]);                     // значение атрибута
        finally Free; end;

        Stream.WriteStr(sView); // Передаем строку атрибутов

        sView:= ''; //--------------------------------------- значения критериев
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
          sView:= sView+fnIfStr(sView='', '', '; ')+CriName+fnIfStr(s='', '', ': '+s); // строка по 1-му критерию
        end;
        ORD_IBS.Close;

        Stream.WriteStr(sView); // Передаем строку критериев

        sView:= ''; //----------------------------- тексты к связке товар - нода
        ORD_IBS1.ParamByName('WareID').AsInteger:= WareID;
        ORD_IBS1.ExecQuery;
        while not ORD_IBS1.Eof do begin
          iNode:= ORD_IBS1.FieldByName('LWNTnodeID').AsInteger;
          sView:= sView+fnIfStr(sView='', '', #13#10)+'Узел '+ORD_IBS1.FieldByName('TRNANAME').AsString+': ';
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
          sView:= sView+fnIfStr(sView='', '', '; ')+CriName+fnIfStr(s='', '', ': '+s); // строка по 1-му типу текста
        end;
        ORD_IBS1.Close;

        Stream.WriteStr(sView); // Передаем строку текстов
      end; // for
    finally
      prFreeIBSQL(ORD_IBS);
      prFreeIBSQL(ORD_IBS1);
      cntsOrd.SetFreeCnt(ORD_IBD);
    end;
    if j>0 then begin
      Stream.Position:= sPos;
      Stream.WriteInt(j);
//      Stream.Position:= Stream.Size; // если будем еще добавлять инфо по товару
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Codes, 0);
end;
//================================ список доставок как результат поиска (WebArm)
procedure prWebarmGetDeliveries(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebarmGetDeliveries'; // имя процедуры/функции
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
                 // проверить UserID, FirmID, ForFirmID и получить систему, валюту
      prCheckUserForFirmAndGetCurr(UserID, FirmID, ForFirmID, CurrID, PriceInUah, contID);
InnerErrorPos:='2';
      CountDeliv:= Cache.DeliveriesList.Count;
    finally
      prSetThLogParams(ThreadData, csWebArmGetDeliviriesList, UserID, FirmID, 'DelivQty='+IntToStr(CountDeliv)); // логирование
    end;
    if (CountDeliv<1) then raise EBOBError.Create('Не найдены доставки');
InnerErrorPos:='3';
    ffp:= TForFirmParams.Create(FirmID, UserID, ForFirmID, CurrID, contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(ffp.currID, ffp.ForClient));
    Stream.WriteBool(False); // ShowAnalogs

    Stream.WriteInt(CountDeliv);   // Передаем доставки
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
//============================================ формирование счета на недостающие
procedure prWebArmMakeSecondAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmMakeSecondAccount'; // имя процедуры/функции
      errmess = 'Ошибка создания счета';
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
    EmplID:= Stream.ReadInt;     // код сотрудника
    AccountID:= Stream.ReadInt;  // код счета

    AccountCode:= IntToStr(AccountID);

    prSetThLogParams(ThreadData, csCreateSubAcc, EmplID, 0, 'AccountID='+AccountCode); // логирование

    if (AccountID<1) then raise EBOBError.Create('Неверный код исходного счета');
    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpWrite, True);
//------------------------- код и номер нового счета ---------------------------
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
//------------------------------- создали новый счет ---------------------------
      Stream.Clear;
      Stream.WriteInt(aeSuccess);   // знак того, что запрос обработан корректно
      Stream.WriteInt(AccountID);   // код нового счета
      Stream.WriteStr(AccountCode); // номер нового счета
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
//============================================== формирование накладной из счета
procedure prWebArmMakeInvoiceFromAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmMakeInvoiceFromAccount'; // имя процедуры/функции
      errmess = 'Ошибка формирования накладной из счета';
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
    EmplID:= Stream.ReadInt;     // код сотрудника
    AccountID:= Stream.ReadInt;  // код счета
    ForFirmID:= Stream.ReadInt;  // код к/а

    AccountCode:= IntToStr(AccountID);

    prSetThLogParams(ThreadData, csWebArmMakeInvoiceFromAccount, EmplID, 0,
      'AccountID='+AccountCode+', ForFirmID='+IntToStr(ForFirmID)); // логирование

    if (AccountID<1) then raise EBOBError.Create('Неверный код счета');
    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

//    if not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then                 // проверка фирмы
//      raise EBOBError.Create(MessText(mtkNotFirmExists));
    Cache.TestFirms(ForFirmID, True, True, False);
    if not Cache.FirmExist(ForFirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select PINVCONTRACTCODE from PayInvoiceReestr'+
                       ' where PInvCode='+AccountCode;
      GBIBS.ExecQuery;
      if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create('Не найден счет код='+AccountCode);
      i:= GBIBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      GBIBS.Close;

      contID:= i;
      Contract:= Cache.arFirmInfo[ForFirmID].GetContract(contID);
      if (contID<>i) then  raise EBOBError.Create(MessText(mtkNotFoundCont, IntToStr(i)));

      if (Contract.Status=cstClosed) then         // проверка на доступность контракта
        raise EBOBError.Create('Контракт '+Contract.Name+' недоступен');

      if Contract.SaleBlocked then // проверка доступности отгрузки        ???
        raise EBOBError.Create('Отгрузка запрещена');

      s:= FormatDateTime(cDateFormatY4, Date);
      i:= HourOf(Now);
//------------------------- код и номер накладной ------------------------------
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
//------------------------------- создали накладную ---------------------------
      Stream.Clear;
      Stream.WriteInt(aeSuccess);   // знак того, что запрос обработан корректно
      Stream.WriteInt(AccountID);   // код накладной
      Stream.WriteStr(AccountCode); // номер накладной
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
//===================================== список накладных передачи (счета WebArm)
procedure prWebArmGetTransInvoicesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetTransInvoicesList'; // имя процедуры/функции
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
    EmplID:= Stream.ReadInt;    // код сотрудника
    ddFrom:= Stream.ReadDouble; // начиная с даты док-та
    DprtFrom:= Stream.ReadInt;    // подр.отгрузки
    DprtTo:= Stream.ReadInt;    // подр.приема
    flOpened:= Stream.ReadBool;   // только открытые

    prSetThLogParams(ThreadData, csShowTransferInvoices, EmplID, 0, 'ddFrom='+DateToStr(ddFrom)+' DprtFrom='+
      IntToStr(DprtFrom)+' DprtTo='+IntToStr(DprtTo)+' flOpened='+BoolToStr(flOpened)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    dd:= IncDay(Date, -7); // ограничиваем начальную дату - не более 7 дней
    if (ddFrom<dd) then ddFrom:= dd;
                           // формируем условия по фильтрам
    s:= ' and TRINPRINTLOCK="F" and TRINBYNORMKEY="F"'; // неблокированные не по нормам

    if (DprtFrom>0) then s:= s+' and TRINSORCDPRTCODE='+IntToStr(DprtFrom);    // подр.отгрузки
    if (DprtTo>0)   then s:= s+' and TRINDESTDPRTCODE='+IntToStr(DprtTo);      // подр.отгрузки
    if flOpened     then s:= s+' and TRINEXECUTED="F"'+                        // неисполненные открытые
                               ' and (otwhcode is null and inwhcode is null)'; //
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteDouble(ddFrom); // начальная дата (могла измениться)

    sPos:= Stream.Position;
    Stream.WriteInt(0);  // место под кол-во

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
        ' where TRINSUBFIRMCODE=1 and TRINDATE>=:dd'+s; // начиная с даты док-та
      GBIBS.ParamByName('dd').AsDateTime:= dd;
      GBIBS.ExecQuery;
      j:= 0; // счетчик строк
      while not GBIBS.Eof do begin
        i:= GBIBS.FieldByName('TRINCODE').AsInteger;
        Stream.WriteInt(i);                              // код док-та
        s:= GBIBS.FieldByName('TRINNUMBER').AsString;
        Stream.WriteStr(s);                              // номер док-та
        dd:= GBIBS.FieldByName('TRINDATE').AsDateTime;
        Stream.WriteDouble(dd);                          // дата док-та
        i:= GBIBS.FieldByName('TRINSORCDPRTCODE').AsInteger;
        Stream.WriteInt(i);                              // код подр. отгрузки
        i:= GBIBS.FieldByName('TRINDESTDPRTCODE').AsInteger;
        Stream.WriteInt(i);                              // код подр. приема
        i:= GBIBS.FieldByName('TRINSHIPMENTMETHODCODE').AsInteger;
        Stream.WriteInt(i);                              // код способа отгрузки
        dd:= GBIBS.FieldByName('TRINSHIPMENTDATE').AsDateTime;
        Stream.WriteDouble(dd);                          // дата отгрузки
        i:= GBIBS.FieldByName('TRINSHIPMENTTIMECODE').AsInteger;
        Stream.WriteInt(i);                              // код времени отгрузки
        s:= GBIBS.FieldByName('TRINCOMMENTS').AsString;
        Stream.WriteStr(s);                              // комментарий
        if (GBIBS.FieldByName('TRINEXECUTED').AsString='T') then s:= 'Исполнен'
        else if (GBIBS.FieldByName('hcode').AsInteger>0) then s:= 'Обработка'
        else s:= 'Открыт';
        Stream.WriteStr(s);                              // статус
//        fl:= GBIBS.FieldByName('TRINPRINTLOCK').AsString='T';
//        Stream.WriteBool(fl); // блокировка после печати
//        fl:= GBIBS.FieldByName('TRINBYNORMKEY').AsString='T';
//        Stream.WriteBool(fl); // по нормам
//        fl:= False; // заглушка
//        Stream.WriteBool(fl); // Необходимость подтверждения
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
//=================================== просмотр накладной передачи (счета WebArm)
procedure prWebArmGetTransInvoice(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetTransInvoice'; // имя процедуры/функции
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
    EmplID:= Stream.ReadInt;    // код сотрудника
    InvID:= Stream.ReadInt;    // код накл.передачи

    InvCode:= IntToStr(InvID);
    prSetThLogParams(ThreadData, csShowTransferInvoice, EmplID, 0, 'InvID='+InvCode); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    j:= 0; // счетчик строк товаров
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
      if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create('Не найдена накладная');

      Stream.WriteInt(InvID);                          // код док-та
      s:= GBIBS.FieldByName('TRINNUMBER').AsString;
      Stream.WriteStr(s);                              // номер док-та
      dd:= GBIBS.FieldByName('TRINDATE').AsDateTime;
      Stream.WriteDouble(dd);                          // дата док-та
      i:= GBIBS.FieldByName('TRINSORCDPRTCODE').AsInteger;
      Stream.WriteInt(i);                              // код подр. отгрузки
      s:= Cache.GetDprtMainName(i);
      Stream.WriteStr(s);                              // наимен. подр. отгрузки
      i:= GBIBS.FieldByName('TRINDESTDPRTCODE').AsInteger;
      Stream.WriteInt(i);                              // код подр. приема
      s:= Cache.GetDprtMainName(i);
      Stream.WriteStr(s);                              // наимен. подр. приема
      i:= GBIBS.FieldByName('TRINSHIPMENTMETHODCODE').AsInteger;
      Stream.WriteInt(i);                              // код способа отгрузки
      with Cache.ShipMethods do if ItemExists(i) then s:= GetItemName(i) else s:= '';
      Stream.WriteStr(s);                              // наимен. способа отгрузки
      dd:= GBIBS.FieldByName('TRINSHIPMENTDATE').AsDateTime;
      Stream.WriteDouble(dd);                          // дата отгрузки
      i:= GBIBS.FieldByName('TRINSHIPMENTTIMECODE').AsInteger;
      Stream.WriteInt(i);                              // код времени отгрузки
      with Cache.ShipTimes do if ItemExists(i) then s:= GetItemName(i) else s:= '';
      Stream.WriteStr(s);                              // значение времени отгрузки
      s:= GBIBS.FieldByName('TRINCOMMENTS').AsString;
      Stream.WriteStr(s);                              // комментарий
      if (GBIBS.FieldByName('TRINEXECUTED').AsString='T') then s:= 'Исполнен'
      else if (GBIBS.FieldByName('hcode').AsInteger>0) then s:= 'Обработка'
      else s:= 'Открыт';
      Stream.WriteStr(s);                              // статус
      GBIBS.Close;

      sPos:= Stream.Position;
      Stream.WriteInt(0);  // место под кол-во

      GBIBS.SQL.Text:= 'select TrInLnWareCode, TrInLnPlanCount, TrInLnCount, TrInLnUnitCode'+
        ' from TransferInvoiceLines where TrInLnDocmCode='+InvCode;
      GBIBS.ExecQuery;
      while not GBIBS.Eof do begin
        i:= GBIBS.FieldByName('TrInLnWareCode').AsInteger;
        Stream.WriteInt(i);                              // код товара
        if Cache.WareExist(i) then s:= Cache.GetWare(i).Name else s:= '';
        Stream.WriteStr(s);                              // наимен. товара
        dd:= GBIBS.FieldByName('TrInLnPlanCount').AsFloat;
        Stream.WriteDouble(dd);                          // план
        dd:= GBIBS.FieldByName('TrInLnCount').AsFloat;
        Stream.WriteDouble(dd);                          // кол-во
        i:= GBIBS.FieldByName('TrInLnUnitCode').AsInteger;
        Stream.WriteInt(i);                              // код ед.изм.
        s:= Cache.GetMeasName(i);
        Stream.WriteStr(s);                              // наимен. ед.изм.
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
//============== добавление товаров из счета в накладную передачи (счета WebArm)
procedure prWebArmAddWaresFromAccToTransInv(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmAddWaresFromAccToTransInv'; // имя процедуры/функции
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
    EmplID:= Stream.ReadInt;     // код сотрудника
    AccID:= Stream.ReadInt;      // код счета
    sLineCodes:= Stream.ReadStr; // коды строк счета для обработки
    InvID:= Stream.ReadInt;      // код накл.передачи (<1 - создавать новую)
    if (InvID<1) then begin // новая накладная
      DprtFrom:= Stream.ReadInt;   // склад отгрузки
      DprtTo:= Stream.ReadInt;     // склад приема
      ddShip:= Stream.ReadDouble;  // дата отгрузки
      TimeID:= Stream.ReadInt;     // код времени отгрузки
      Comment:= Stream.ReadStr;    // комментарий
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
      'AccID='+AccCode+', InvID='+InvCode+', InvID='); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));
    arLineCodes:= fnSplitString(sLineCodes, ',');
    if length(arLineCodes)<1 then raise EBOBError.Create('Нет строк для обработки');

    if (InvID<1) then begin // новая накладная
      if not Cache.DprtExist(DprtFrom) then raise EBOBError.Create('Не найдено п/р отгрузки');
      if not Cache.DprtExist(DprtTo) then raise EBOBError.Create('Не найдено п/р приема');
      if (TimeID>0) and not Cache.ShipTimes.ItemExists(TimeID) then
        raise EBOBError.Create('Не найдено время отгрузки');
    end;

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpWrite, True);
      if (InvID>0) then begin //-------- проверяем статус существующей накладной
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
        if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create('Не найдена накладная передачи');
        if (GBIBS.FieldByName('TRINEXECUTED').AsString='T') then s:= 'Исполнен'
        else if (GBIBS.FieldByName('hcode').AsInteger>0) then s:= 'Обработка' else s:= '';
        InvNumber:= GBIBS.FieldByName('TRINNUMBER').AsString;
        DprtFrom:= GBIBS.FieldByName('TRINSORCDPRTCODE').AsInteger;
        DprtTo:= GBIBS.FieldByName('TRINDESTDPRTCODE').AsInteger;
        GBIBS.Close;
        if (s<>'') then raise EBOBError.Create('Накладная передачи '+InvNumber+' имеет статус '+s);
      end;

      if (InvID<1) then begin //-------------------------------- новая накладная
        GBIBS.SQL.Text:= 'insert into TRANSFERINVOICEREESTR (TRINNUMBER, TRINDATE,'+
          ' TRINHOUR, TRINSUBFIRMCODE, TRINSORCDPRTCODE, TRINDESTDPRTCODE,'+
          ' TRINSHIPMENTDATE, TRINSHIPMENTTIMECODE, TRINCOMMENTS) values '+
          '("< АВТО >", "TODAY", EXTRACT(HOUR FROM CURRENT_TIMESTAMP), 1,'+
          IntToStr(DprtFrom)+', '+IntToStr(DprtTo)+', '+
          fnIfStr(ddShip>DateNull, ':ddShip', 'null')+', '+
          fnIfStr(TimeID>0, IntToStr(TimeID), 'null')+', '+
          fnIfStr(Comment<>'', ':comm', 'null')+') returning TRINCODE, TRINNUMBER';
        if (ddShip>DateNull) then GBIBS.ParamByName('ddShip').AsDateTime:= ddShip;
        if (Comment<>'') then GBIBS.ParamByName('comm').AsString:= Comment;
        s:= 'Ошибка создания накладной передачи';
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then raise EBOBError.Create(s);
        InvID:= GBIBS.FieldByName('TRINCODE').AsInteger;
        if (InvID<1) then raise EBOBError.Create(s);
        InvCode:= IntToStr(InvID);
        InvNumber:= GBIBS.FieldByName('TRINNUMBER').AsString;
        GBIBS.Close;
      end;
                                     //---------------- пишем строки в накладную
      GBIBS.SQL.Text:= 'select rWareCode, rTransfer, rUnitCode'+
        ' from Vlad_CSS_WaresFromAccToTrInv('+AccCode+', :aAccLineCode, '+InvCode+')';
      GBIBS.Prepare;
      for i:= 0 to High(arLineCodes) do try
        GBIBS.ParamByName('aAccLineCode').AsString:= arLineCodes[i];
        GBIBS.ExecQuery;
        if (GBIBS.Bof and GBIBS.Eof) then Continue;
        ii:= GBIBS.FieldByName('rWareCode').AsInteger;                       // код товара
        if not Cache.WareExist(ii) then Continue;
        if (GBIBS.FieldByName('rTransfer').AsInteger<1) then Continue;

        s:= fnMakeAddCharStr(GBIBS.FieldByName('rTransfer').AsString, 10)+   // кол-во
            ' '+Cache.GetMeasName(GBIBS.FieldByName('rUnitCode').AsInteger); // ед.изм.
        s:= Cache.GetWare(ii).Name+cSpecDelim+s;
        lst.Add(s);                   // наимен.товара|||кол-во ед.изм.
      finally
        GBIBS.Close;
      end;
      if (lst.Count<1) then raise EBOBError.Create('Нет записанных строк');

      GBIBS.Transaction.Commit;
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(lst.Count+2);
    s:= 'Добавлены товары в накладную передачи '+InvNumber; // заголовок - 2 строки
    Stream.WriteStr(s);
    s:= '('+Cache.GetDprtMainName(DprtFrom)+' - '+Cache.GetDprtMainName(DprtTo)+')';
    Stream.WriteStr(s);
    for i:= 0 to lst.Count-1 do Stream.WriteStr(lst[i]); //------ строки товаров

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False, True);
  end;
  Stream.Position:= 0;
  SetLength(arLineCodes, 0);
  prFree(lst);
end;
//================================================== список уведомлений (WebArm)
procedure prWebArmGetNotificationsParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetNotificationsParams'; // имя процедуры/функции
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
    EmplID:= Stream.ReadInt;     // код сотрудника
    noteID:= Stream.ReadInt;     // код уведомления (<1 - все)

    prSetThLogParams(ThreadData, csWebArmGetNotificationsParams, EmplID, 0, 'noteID='+IntToStr(noteID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolNewsManage) then // проверяем право пользователя
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
        Stream.WriteInt(IBS.FieldByName('NoteCODE').AsInteger);    // код уведомления
        Stream.WriteDouble(IBS.FieldByName('NoteBegDate').AsDate); // дата начала
        Stream.WriteDouble(IBS.FieldByName('NoteEndDate').AsDate); // дата окончания
        Stream.WriteStr(IBS.FieldByName('NoteText').AsString);     // текст уведомления
//------------------------------------------------------ последняя корректировка
        EmplID:= IBS.FieldByName('NOTEUSERID').AsInteger;              // код юзера
        if Cache.EmplExist(EmplID) then s:= Cache.arEmplInfo[EmplID].EmplShortName else s:= '';
        Stream.WriteStr(s);                                            // ФИО юзера
        Stream.WriteDouble(IBS.FieldByName('NoteUpdTime').AsDateTime); // дата и время
//---------------------------------- вычисляем к-во к/а, охваченных уведомлением
        Filials.Clear;                                      // коды филиалов к/а
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteFilials').AsString) do Filials.Add(j);
        Classes.Clear;                                     // коды категорий к/а
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteClasses').AsString) do Classes.Add(j);
        Types.Clear;                                       // коды типов к/а
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteTypes').AsString) do Types.Add(j);
        Firms.Clear;                                       // коды  к/а
        for j in fnArrOfCodesFromString(IBS.FieldByName('NoteFirms').AsString) do Firms.Add(j);
        flAdd:= GetBoolGB(ibs, 'NOTEFIRMSADDFLAG'); // флаг - добавлять/исключать коды Firms
        flAuto:= GetBoolGB(ibs, 'NOTEauto');         // флаг рассылки к/а с авто-контрактами
        flMoto:= GetBoolGB(ibs, 'NOTEmoto');         // флаг рассылки к/а с мото-контрактами
        FirmCount:= 0;
        for FirmID:= 1 to High(Cache.arFirmInfo) do // проверка соответствия к/а условиям фильтрации
          if CheckFirmFilterConditions(FirmID, flAdd, flAuto, flMoto,
            Filials, Classes, Types, Firms) then inc(FirmCount);
        Stream.WriteInt(FirmCount);
//------------------------------------------------------------------------------
        Stream.WriteInt(IBS.FieldByName('rFirmCount').AsInteger); // к-во ознакомленных к/а
        Stream.WriteInt(IBS.FieldByName('rCliCount').AsInteger);  // к-во ознакомленных пользователей
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
//============================ дерево типов товаров (сортировка по наименованию)
procedure prGetWareTypesTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareTypesTree'; // имя процедуры/функции
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

//============================================ 53-stamp - переброска к/а Гроссби
procedure prGetFirmClones(pUserID: Integer; pFileName: String; ThreadData: TThreadData=nil);
const nmProc = 'prGetFirmClones'; // имя процедуры/функции
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
  lstSQL:= fnCreateStringList(False, 10); // список строк SQL для изменения логинов и признаков обработки к/а
  lstSQL1:= fnCreateStringList(False, 10); // список строк SQL для изменения архивных логинов
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
      fil:= gbIBS.Fields[0].AsInteger; // кол-во фирм для обработки
      gbIBS.Close;
      if (fil>0) then Percent:= 90/fil
      else raise EBOBError.Create('Не найдены к/а для клонирования');

      SetExecutePercent(pUserID, ThreadData, Percent);
      prMessageLOGn('к/а-источник;контракт;к/а-приемник;контракт;результат', pFileName);

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
            ss:= ss+'контракты одного к/а в СВК не клонируются';
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // логирование
            TestCssStopException;
            while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do gbIBS.Next;
            Continue;
          end;
{
          ss:= gbIBS.FieldByName('fname1').AsString+'('+gbIBS.FieldByName('firm1').AsString+');'+
               gbIBS.FieldByName('cNum1').AsString+';';
          s:= '';
          if (gbIBS.FieldByName('Firm2').AsInteger<1) then begin
            s:= 'не найден к/а-приемник';
            ss:= ss+';';
          end else ss:= ss+gbIBS.FieldByName('fname2').AsString+'('+gbIBS.FieldByName('firm2').AsString+');';
          if (gbIBS.FieldByName('Cont2').AsInteger<1) then begin
            s:= 'не найден контракт-приемник';
            ss:= ss+';';
          end else ss:= ss+gbIBS.FieldByName('cNum2').AsString+';';
          if (s<>'') then begin // если не нашли, куда переносить
            ss:= ss+s;
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // логирование
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

          s:= '';   // собираем строку с логинами и кодами клиентов
          while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do begin
            if (gbIBS.FieldByName('CliCode1').AsInteger<>gbIBS.FieldByName('CliCode2').AsInteger)
              and (gbIBS.FieldByName('login1').AsString=gbIBS.FieldByName('login2').AsString) then
              s:= s+fnIfStr(s='', '', ';')+gbIBS.FieldByName('login2').AsString+'='+gbIBS.FieldByName('CliCode2').AsString;
            TestCssStopException;
            gbIBS.Next;
          end;
          if (s='') then begin
            ss:= ss+'нет данных о сотрудниках с логинами для клонирования в СВК';
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // логирование
            TestCssStopException;
            while not gbIBS.Eof and (Cont1=gbIBS.FieldByName('Cont1').AsInteger) do gbIBS.Next;
            Continue;
          end;

          ordIBS.ParamByName('Clients').AsString:= s;
          try
            ordIBS.ExecQuery; //------------------------- клонируем к/а в db_ORD
            s:= '';
            while not ordIBS.Eof do begin
              if (ordIBS.FieldByName('rClientOld').AsInteger<0) then // аннулировано/перенесено заказов - в лог
                s:= s+' '+ordIBS.FieldByName('rArhLogin').AsString
              else if (ordIBS.FieldByName('rClientOld').AsInteger>0) then
                lstSQL.Add('update persons set prsnlogin="'+ordIBS.FieldByName('rArhLogin').AsString+
                           '" where prsncode='+ordIBS.FieldByName('rClientOld').AsString+';');
              TestCssStopException;
              ordIBS.Next;
            end;
            ordIBS.Transaction.Commit;
            ss:= ss+'клонирован в СВК';
            prMessageLOGS(nmProc+': '+ss+#13#10+s, 'import_test', False); // логирование переноса заказов
          except
            on E: Exception do begin
              with ordIBS.Transaction do if InTransaction then Rollback;
              ss:= ss+'ошибка клонирования в СВК';
              prMessageLOGS(nmProc+': '+ss+#13#10+CutEMess(E.Message), 'import');
            end;
          end;
          ordIBS.Close;
          prMessageLOGn(ss, pFileName);
        end; // while ... (Firm1=

        lstSQL1.Add(sFirm); // здесь собираем коды символьные к/а
        // отключение признака клонирования к/а в Grossbee и замена логинов на старых кодах клиентов
        lstSQL.Add('  update firms set FirmCloneSource="F" where firmcode='+sFirm+';');
        lstSQL.Add('end');
        with gbIBSw.Transaction do if not InTransaction then StartTransaction;
        gbIBSw.SQL.Clear;
        gbIBSw.SQL.AddStrings(lstSQL);
        try
          gbIBSw.ExecQuery;
          gbIBSw.Transaction.Commit;
          ss:= sf1+';;;отключен признак клонирования в Grossbee';
        except
          on E: Exception do begin
            with gbIBSw.Transaction do if InTransaction then Rollback;
            ss:= sf1+';;;!!! ошибка отключения признака клонирования в Grossbee';
            prMessageLOGS(nmProc+': '+ss+#13#10+CutEMess(E.Message), 'import');
         end;
        end;
        gbIBSw.Close;
        prMessageLOGn(ss, pFileName);
        SetExecutePercent(pUserID, ThreadData, Percent);
        CheckStopExecute(pUserID, ThreadData); // проверка остановки процесса или системы
      end; // while not gbIBS.Eof
      gbIBS.Close;
//-------------------------------------------- архивные логины клонированных к/а
      ss:= '';
      sf1:= '';
      if (lstSQL1.Count>0) then begin // ищем
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
            if (copy(s, 1, 1)<>'_') then sf1:= sf1+' "'+s+'"('+sFirm+')' // не перенесенные логины
            else lstSQL.Add('update WEBORDERCLIENTS set WOCLLOGIN="'+s+'" where WOCLCODE='+sFirm+';');
            TestCssStopException;
            gbIBSw.Next;
          end;
          gbIBSw.Transaction.Commit;
          if (lstSQL.Count>0) then ss:= ss+' найдены/заменены в Grossbee'
          else ss:= ss+' не найдены в Grossbee';
        except
          on E: Exception do begin
            with gbIBSw.Transaction do if InTransaction then Rollback;
            ss:= ss+' !!! ошибка поиска в Grossbee по к/а '+lstSQL1.DelimitedText+#13#10+CutEMess(E.Message);
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
            ordIBS.ExecQuery; //------------------------- клонируем к/а в db_ORD
            ordIBS.Transaction.Commit;
            ss:= ss+' заменены в ORD';
          except
            on E: Exception do begin
              with ordIBS.Transaction do if InTransaction then Rollback;
              ss:= ss+' !!! ошибка замены в ORD'#13#10+CutEMess(E.Message);
            end;
          end;
          ordIBS.Close;
        end;
      end; // if (lstSQL1.Count>0)
      if (ss<>'') then
        prMessageLOGS(nmProc+': ----------- архивные логины клонир.к/а '+ss, 'import_test', False); // логирование
      if (sf1<>'') then
        prMessageLOGS(nmProc+': ----------- не перенесены логины клонир.к/а в Grossbee '+sf1, 'import_test', False); // логирование
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
//                          расписания отгрузки
//******************************************************************************
// Cache -> ShipMethods - методы отгрузки, ShipTimes - времена отгрузки
// Cache -> TDprtInfo.DelayTime - время запаздывания в мин
// Grossbee ->
// FIRMDEPARTMENT - торговые точки контрактов
// CONTRACTDESTPOINT
// TRANSPORTTIMETABLESREESTR - реестр расписаний
// PAYINVOICEREESTR->PINVTRIPCODE - ссылка на TRANSPORTTIMETABLESLINES->TRTBLNCODE
// select RLineCode from GETTRTBLINECODEFROMLOCATION(:ALocationCode, :ADocmCode) -
//   код строки TRANSPORTTIMETABLESLINES по коду местонахождения и коду расписания
// select RENABLEDDATE from CHECKTRTBDISABLEDDATE(:ADATE, :ADOCMCODE) - проверка запретной даты
//******************************************************************************
//============================ список доступных времен самовывоза (Web & Webarm)
procedure prGetTimeListSelfDelivery(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetTimeListSelfDelivery'; // имя процедуры/функции
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
    FirmID:= Stream.ReadInt;    // Web- код к/а, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- неважно, Webarm- код к/а
    ContID:= Stream.ReadInt;
    aDate:= Stream.ReadDouble;
    aTime:= Stream.ReadInt;

    prSetThLogParams(ThreadData, csGetTimeListSelfDelivery, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // логирование

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
    if (Contract.Status=cstClosed) then         // проверка на доступность контракта
      raise EBOBError.Create('Контракт '+Contract.Name+' недоступен');

    flWithSVKDelay:= (FirmID<>IsWe); // для клиентов - учитывать запаздывание СВК
//    flWithSVKDelay:= False; // 06.08.2017 - запрос Чичкова

    errmess:= GetAvailableSelfGetTimesList(Contract.MainStorage, aDate, aTime, SL, flWithSVKDelay);
    if (errmess<>'') then raise EBOBError.Create(errmess);

    flNotAvailable:= (aTime<0);
    if flNotAvailable then aTime:= -aTime;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
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
//======================= список доступных дат отгрузки по складу (Web & Webarm)
procedure prGetDprtAvailableShipDates(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetDprtAvailableShipDates'; // имя процедуры/функции
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
    FirmID:= Stream.ReadInt;    // Web- код к/а, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- неважно, Webarm- код к/а
    ContID:= Stream.ReadInt;
    aDate:= Stream.ReadDouble;

    prSetThLogParams(ThreadData, csGetDprtAvailableShipDates, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)); // логирование

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
    if (Contract.Status=cstClosed) then         // проверка на доступность контракта
      raise EBOBError.Create('Контракт '+Contract.Name+' недоступен');
    iDate:= Trunc(aDate);
//    flWithSVKDelay:= (FirmID<>IsWe); // для клиентов - учитывать запаздывание СВК

//    errmess:= GetAvailableShipDatesList(Contract.MainStorage, iDate, SL, flWithSVKDelay);
    errmess:= GetAvailableShipDatesList(Contract.MainStorage, iDate, SL);
    if (errmess<>'') then raise EBOBError.Create(errmess);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
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
//=============================== список торговых точек контракта (Web & Webarm)
procedure prGetContractDestPointsList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetContractDestPointsList'; // имя процедуры/функции
var i, UserID, FirmID, sPos, ContID, ForFirmID, j, dsID: integer;
    GBdirection: Boolean;
    s: string;
    Contract: TContract;
    dest: TDestPoint;
begin
  Stream.Position:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // Web- код к/а, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- неважно, Webarm- код к/а
    ContID:= Stream.ReadInt;
    GBdirection:= Stream.ReadBool;

    prSetThLogParams(ThreadData, csGetContractDestPointsList, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)+
      #13#10'GBdirection='+fnIfStr(GBdirection, '1', '0')); // логирование

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
      if (Contract.Status=cstClosed) then         // проверка на доступность контракта
        raise EBOBError.Create('Контракт '+Contract.Name+' недоступен');
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    sPos:= Stream.Position;
    j:= 0;
    Stream.WriteInt(j); // место под кол-во строк
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
      Stream.WriteInt(j); // передаем кол-во строк
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//====================== список доступных расписаний по контракту (Web & Webarm)
procedure prGetAvailableTimeTablesList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetAvailableTimeTablesList'; // имя процедуры/функции
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
  ilst:= TIntegerList.Create; // список кодов имеющихся в счетах расписаний
  ExCount:= 0;
  SVKDelay:= 0;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;    // Web- код к/а, Webarm- IsWe
    ForFirmID:= Stream.ReadInt; // Web- неважно, Webarm- код к/а
    ContID:= Stream.ReadInt;
    AccountID:= Stream.ReadInt;  // Web- неважно, Webarm- код счета
    DestID:= Stream.ReadInt;
    pDate:= Stream.ReadDouble;

    prSetThLogParams(ThreadData, csGetAvailableTimeTablesList, UserID, FirmID, // логирование
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'ContID='+IntToStr(ContID)+
      #13#10'DestID='+IntToStr(DestID)+#13#10'pDate='+FormatDateTime(cDateTimeFormatY2S, pDate));

    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if (FirmID<>IsWe) then begin
      ForFirmID:= FirmID;
      if not Cache.FirmExist(ForFirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
    end;

    if (DestID<1) then raise EBOBError.Create('Не задана торговая точка');

    firma:= Cache.arFirmInfo[ForFirmID];
    if not firma.CheckContract(ContID) then
      raise EBOBError.Create(MessText(mtkNotFoundAvaiCont));
    Contract:= firma.GetContract(ContID);
    if (Contract.Status=cstClosed) then         // проверка на доступность контракта
      raise EBOBError.Create('Контракт '+Contract.Name+' недоступен');

    DprtID:= Contract.MainStorage;
    flWithSVKDelay:= (FirmID<>IsWe); // для клиентов - учитывать запаздывание СВК

    dprt:= Cache.arDprtInfo[DprtID];
    s:= dprt.CheckShipAvailable(pDate, 0, 0, False, False);
    if (s<>'') then raise EBOBError.Create(s);

    if flWithSVKDelay then
      SVKDelay:= Cache.GetConstItem(pcSVKShipDelayMinutes).IntValue;
                                              // границы времен отгрузки на дату
    s:= dprt.GetShipTimeLimits(pDate, TimeMin, TimeMax, SVKDelay, True);
    if (s<>'') then raise EBOBError.Create(s);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    sPos:= Stream.Position;
    Stream.WriteInt(0);      // место под кол-во строк
    Stream.WriteBool(False); // место под признак - есть расписания из счетов

    ibd:= cntsGRB.GetFreeCnt;
    try  // ищем имеющиеся в счетах к/а расписания для даты отгрузки, склада и торг.точки
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
        if (TestTime<TimeMin) or (TestTime>TimeMax) then begin // проверяем время
          cntsGRB.TestSuspendException;
          ibs.Next;
          Continue;
        end;

        Stream.WriteInt(ttID);  // код расписания
        Stream.WriteStr(s1);   // метод отгрузки
        Stream.WriteStr(s2);   // время отгрузки
        if (pDate>DateNull) then s1:= FormatDateTime(cDateTimeFormatY2N, pDate) else s1:= '';
        Stream.WriteStr(s1); // дата+время прибытия
        flEx:= (ilst.IndexOf(ttID)>-1);
        Stream.WriteBool(flEx); // признак - такое расписание есть в счетах
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
    Stream.WriteInt(i); // передаем кол-во расписаний
    if (ExCount>0) then Stream.WriteBool(True); // признак - есть расписания из счетов

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(ilst);
  Stream.Position:= 0;
end;
//=========================================== просмотр параметров отгрузки счета
procedure prGetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetAccountShipParams'; // имя процедуры/функции
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
    ForFirmID:= Stream.ReadInt; // код к/а
    AccountCode:= Stream.ReadStr;
//-------------------------- from CGI - end

    prSetThLogParams(ThreadData, csGetAccountShipParams, UserID, FirmID,
      'ForFirmID='+IntToStr(ForFirmID)+#13#10'AccountID='+AccountCode); // логирование

    if CheckNotValidUser(UserID, FirmID, err) then raise EBOBError.Create(err);
    i:= StrToIntDef(AccountCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));

    IBD:= cntsGRB.GetFreeCnt;
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'select sss.*, s.shmhname sShipMet, ss.shtiname sShipTime'+ // ищем  счет
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

    if (ShipTableID>0) then DelivType:= cDelivTimeTable // Доставка по расписанию
    else if (ShipMetID=Cache.GetConstItem(pcSelfGetShipMethodCode).IntValue) then
      DelivType:= cDelivSelfGet                         // Самовывоз
    else if (ShipMetID=Cache.GetConstItem(pcCliNowShipMethodCode).IntValue) then
      DelivType:= cDelivClientNow                       // Клиент на складе
    else DelivType:= cDelivReserve;                     // резерв

    Stream.Clear;
//-------------------------- to CGI - begin
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteInt(DelivType);   // вид доставки
    Stream.WriteInt(DestID);      // код торговой точки
    Stream.WriteStr(sDestName);   // название торговой точки
    Stream.WriteStr(sDestAdr);    // адрес торговой точки
    Stream.WriteDouble(ShipDate); // дата отгрузки
    Stream.WriteInt(ShipTableID); // код расписания
    Stream.WriteStr(sShipMet);    // название способа отгрузки
    Stream.WriteInt(ShipTimeID);  // код времени отгрузки
    Stream.WriteStr(sShipTime);   // текст времени отгрузки
    Stream.WriteStr(sArrive);     // текст даты/времени прибытия
//-------------------------- to CGI - end
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//===================================== редактирование параметров отгрузки счета
procedure prSetAccountShipParams(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prSetAccountShipParams'; // имя процедуры/функции
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
    ForFirmID:= Stream.ReadInt;   // код к/а
    AccountCode:= Stream.ReadStr; // код счета в симв.сиде
    DelivType:= Stream.ReadInt;   // вид доставки: 0 - Доставка, 1 - Резерв, 2 - Самовывоз, 3 - клиент на складе
    DestID:= Stream.ReadInt;      // код торговой точки
    ShipDate:= Stream.ReadDouble; // дата отгрузки
    ShipTableID:= Stream.ReadInt; // код расписания
    ShipTimeID:= Stream.ReadInt;  // код времени отгрузки
//-------------------------- from CGI - end
    if (ShipDate<DateNull) then ShipDate:= 0;
                                                                // логирование
    prSetThLogParams(ThreadData, csSetAccountShipParams, UserID, FirmID, 'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'AccountID='+AccountCode+#13#10'DELIVERYTYPE='+IntToStr(DelivType)+
      #13#10'DESTPOINT='+IntToStr(DestID)+#13#10'SHIPDATE='+FormatDateTime(cDateFormatY2, ShipDate)+
      #13#10'TIMETIBLE='+IntToStr(ShipTableID)+#13#10'SHIPTIMEID='+IntToStr(ShipTimeID));

    if CheckNotValidUser(UserID, FirmID, err) then raise EBOBError.Create(err);

    i:= StrToIntDef(AccountCode, 0);
    if (i<1) then raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));

    if not (DelivType in [cDelivTimeTable, cDelivReserve, cDelivSelfGet, cDelivClientNow]) then
      raise EBOBError.Create('Неизвестный вид доставки - '+IntToStr(DelivType));

    IBD:= cntsGRB.GetFreeCnt(Cache.arEmplInfo[UserID].GBLogin, cDefPassword, cDefGBrole);
    try
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'select PInvSupplyDprtCode, PINVCONTRACTCODE from PayInvoiceReestr'+ // ищем  счет
        ' where PInvCode='+AccountCode+' and PInvRecipientCode='+IntToStr(ForFirmID);
      IBS.ExecQuery;
      if IBS.Bof and IBS.Eof then
        raise EBOBError.Create(MessText(mtkNotFoundDocum, AccountCode));
      ContID:= IBS.FieldByName('PINVCONTRACTCODE').AsInteger;
      DprtID:= IBS.FieldByName('PInvSupplyDprtCode').AsInteger;
      IBS.Close;

      err:= CheckAccountShipParams(DelivType, ContID, DprtID, ShipDate, DestID, ShipTableID, ShipMetID, ShipTimeID, False);
      if (err<>'') then raise EBOBError.Create(err);
      if (DelivType=cDelivTimeTable) and (ShipTableID>0) then ShipTimeID:= 0;  // Доставка по расписанию - код времени не пишем - УиК

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
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
//-------------------------- to CGI - end
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//==============================================================================
procedure prWebArmResetPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmResetPassword'; // имя процедуры/функции
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
      ' newpass1='+pass1+' newpass2='+pass2); // дописать подробности!

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    empl:= Cache.arEmplInfo[UserId];
    if (not empl.RESETPASSWORD) then
      raise EBoBAutenticationError.Create('В Вашей учетной записи нет пометки об обязательной смене пароля.');

    if (not fnCheckOrderWebPassword(pass1)) then
      raise EBOBError.Create('Пароль не соответствует принятым соглашениям.');

    if (pass1<>pass2) then
      raise EBOBError.Create('Введенные пароли не совпадают.');

    if (pass1=empl.USERPASSFORSERVER) then
      raise EBOBError.Create('Новый пароль не должен совпадать со старым');

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
//************************************************ Меняется пароль пользователем
function fnChangePasswordWebarm(UserID: Integer; oldpass, newpass1, newpass2: string): string;
const nmProc = 'fnChangePasswordWebarm'; // имя процедуры/функции
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
//      'oldpass='+oldpass+#13#10+'newpass1='+newpass1+#13#10+'newpass2='+newpass2); // логирование
    if CheckNotValidUser(UserID, IsWe, s) then raise EBOBError.Create(s);
    if (newpass1=oldpass) then
      raise EBOBError.Create('Новый пароль не должен совпадать со старым.');
    i:= Cache.CliPasswLength;
    if not fnCheckOrderWebPassword(newpass1) then
      raise EBOBError.Create(MessText(mtkNotValidPassw, IntToStr(i)));
    if (newpass1<>newpass2) then
      raise EBOBError.Create('Новый пароль и его повтор не совпадают.');

    Empl:= Cache.arEmplInfo[UserID];
    if (newpass1=Empl.ServerLogin) then
      raise EBOBError.Create('Пароль не должен совпадать с логином.');
    if (oldpass<>Empl.USERPASSFORSERVER) then
      raise EBOBError.Create('Старый пароль указан неверно.');

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
//============= Получение списка товара по условию, Бренд, Группа, строка поиска
procedure prProductWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductWareSearch'; // имя процедуры/функции
var EmplID, idxTemplate: integer;        // код бренда/группы для отбора товара
    lstSearchWare: TStringList;  // коды найденных товаров
    Template: string;            // строка поиска
    IgnoreSpec, TypeList: byte;
    flUik, flCheckUser, flProduct: Boolean;
    ware: TWareInfo;
    empl: TEmplInfoItem;
  //----------- возвращает список товаров, отсортированных по наименованию
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
        if not flUiK then Continue; // Уик - все призы
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
  //-------------------------- поиск товара по коду бренда/группы
  procedure prSearchWareBGCode;
  var i: integer;
      fl, isBG, is0: boolean;
  begin
    is0:= (idxTemplate<1);
    isBG:= False;
    if not is0 then isBG:= Cache.WareBrands.ItemExists(idxTemplate);

    for i:= 1 to High(Cache.arWareInfo) do if Cache.WareExist(i) then begin
      ware:= Cache.GetWare(i);
      if (ware.PgrID=Cache.pgrDeliv) or ware.IsArchive then Continue; // пропускаем доставки и архивные
      if Ware.IsPrize then begin
        if not flUiK then Continue; // Уик - все призы
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
 //-------------------------- Записать список найденных товаров в поток
  procedure prSaveResultToStream;
  var i: integer;
  begin
    Stream.WriteInt(lstSearchWare.Count);
    for i:= 0 to lstSearchWare.Count-1 do begin // Запись списка в поток
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
      flCheckUser:= Boolean(Stream.ReadByte); // Проверять менеджера у товара: 0 - нет, 1 - да
      TypeList:= Stream.ReadByte;      // Тип возвращаемого списка: 0 - краткий, 1 - полный

      prSetThLogParams(ThreadData, csProductWareSearch, EmplID);

      if not Cache.EmplExist(EmplID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
      empl:= Cache.arEmplInfo[EmplID];

      flUik:= empl.UserRoleExists(rolUik);
      flProduct:= empl.UserRoleExists(rolProduct);
      if not flProduct and not flUik then
        raise EBOBError.Create(MessText(mtkNotRightExists));

      lstSearchWare:= TStringList.Create;

      if Stream.ReadByte = 1 then begin // Поиск по строке
        IgnoreSpec:= Stream.ReadByte;
        Template:= Stream.ReadStr;
        if length(Template)<constMinSearchCharQty then
          raise EBOBError.Create('Строка поиска должна быть не менее '+
            IntToStr(constMinSearchCharQty)+'-х символов.');
        TestCssStopException;
        prSearchWareNames;
      end else begin // поиск по коду бренда/группы
        TestCssStopException;
        idxTemplate:= Stream.ReadInt;
        prSearchWareBGCode;
      end;
      if (lstSearchWare.Count<1) then
        raise EBOBError.Create('По Вашему запросу "'+Template+'" товар не найден.');

      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      TestCssStopException;
      prSaveResultToStream;  // запись результата в поток
    except
      on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
      on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
    end;
  finally
    prFree(lstSearchWare);
    Stream.Position:= 0;
  end;
end;
//=================================================== Страница продукт-менджера,
//============= получение списка товара по условию, Бренд, Группа, строка поиска
procedure prProductPage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prProductPage'; // имя процедуры/функции
var UserId: integer;
    lstBrand: TStringList;  // Список брендов (0-уровень дерева)
    lstGroup: TStringList;  // Список групп бренда (1-уровень вложения дерева)
    ArLinkSources: tas;
    empl: TEmplInfoItem;
    flUiK, flProduct: Boolean;
  //--------------------- Освобождение памяти от списка брендов и групп (дерево)
  procedure prClearBrandList;
  var i: integer;  // loop local var
      list: TStringList;
  begin
    try
      for i:= 0 to lstBrand.Count-1 do
        if Assigned(lstBrand.Objects[i]) then begin
          list:= TStringList(lstBrand.Objects[i]);
          prFree(List);  // Освобождение списка групп
        end;
    except
     on E: Exception do
       fnWriteToLog(ThreadData, lgmsUserError, nmProc, '', E.Message, 'prClearBrandList');
    end;
    prFree(lstBrand);  // Освобождение списка брендов
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
//        if (Ware.PgrID = pgrDeliv) then Continue; // пропускаем доставки
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
  //-------------------------- Запись списка брендов и групп (дерево) в поток
  procedure prSaveResultToStream;
  var i, j: integer;  // loop local var
  begin
    Stream.WriteInt(lstBrand.Count);
    for i:= 0 to lstBrand.Count-1 do begin // Запись брендов в поток
      j:= StrToInt(copy(lstBrand[i], Length(lstBrand.Names[i])+2, MaxInt));
      Stream.WriteInt(j);
      Stream.WriteStr(lstBrand.Names[i]);
      if not Assigned(lstBrand.Objects[i]) then begin // правка существования списка групп
        Stream.WriteInt(0);
        Exit;
      end;
      with TStringList(lstBrand.Objects[i]) do begin // Запись групп в поток
        Stream.WriteInt(Count);
        for j:= 0 to Count-1 do begin
          Stream.WriteInt(Integer(Objects[j]));
          Stream.WriteStr(Strings[j]);
        end;
      end; // with
    end; // for
  end;
  //-------------------------- Запись массива строк в поток
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
        0: if (lstBrand.Count<1) then raise EBOBError.Create('Дерево брендов и групп пустое.');
        1: raise EBOBError.Create('Ошибка формирование дерева - Кеш заблокирован.');
      else raise EBOBError.Create('Неопределенная ошибка формирования дерева брендов и групп');
      end;

      if (lstBrand.Count<1) then raise EBOBError.Create('Дерево брендов и групп пустое.');

      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      TestCssStopException;
      prSaveResultToStream;      // Запись дерева в поток
      TestCssStopException;
      ArLinkSources:= Cache.FDCA.GetArLinkSources;
      prSaveTasToStream(ArLinkSources,  Stream); // Запись справочника источников в поток;
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
//=========== (+ Web) Фильтрованные списки значений атрибутов Grossbee по группе
procedure prGetFilteredGBGroupAttValues(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetFilteredGBGroupAttValues'; // имя процедуры/функции
var UserID, FirmID, grpID, i, ii, pCount, j, jj, ind, exCount: Integer;
    s: String;
    att: TGBattribute;
    lstAtts, lst: TList;
    attCodes, valCodes: Tai;
    ware: TWareInfo;
    link: TLink;
    linkt, linkAtt: TTwoLink;
    flAvailable: Boolean;
    arWareLinks: array of TTwoLink; // рабочий набор линков с атрибутами/значениями товара
    arResult: array of TLinks;      // фильтрованные списки линков на значения атрибутов
    arFinded: TBooleanDynArray;     // флаги наличия заданных значений
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
    grpID:= Stream.ReadInt;   // код группы атрибутов
    pCount:= Stream.ReadInt;  // кол-во атрибутов

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
    for i:= 0 to pCount-1 do begin // принимаем значения
      attCodes[i]:= Stream.ReadInt-cGBattDelta; // код атрибута
      j:= Stream.ReadInt;
      if (j>0) then begin // значение задано
        j:= j-cGBattDelta;
        Inc(exCount); // кол-во заданных значений
      end;
      valCodes[i]:= j;                          // код значения (м.б. 0)
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if (exCount<1) then begin //---------- если ничего не задано - полные списки
      Stream.WriteInt(lstAtts.Count);       // кол-во атрибутов
      for i:= 0 to lstAtts.Count-1 do begin
        att:= lstAtts[i];
        Stream.WriteInt(att.ID+cGBattDelta);   // код атрибута со сдвигом
        with att.Links.ListLinks do begin // список линков на значения атрибута
          Stream.WriteInt(Count);                              // Количество
          for ii:= 0 to Count-1 do begin
            Stream.WriteInt(GetLinkID(Items[ii])+cGBattDelta); // код значения со сдвигом
            Stream.WriteStr(GetLinkName(Items[ii]));           // само значение
          end;
        end; // with
      end; // for
      Exit;
    end;

    for i:= lstAtts.Count-1 downto 0 do begin // проверяем соответствие списков атрибутов
      att:= lstAtts[i];
      if (fnInIntArray(att.ID, attCodes)<0) then lstAtts.Delete(i);
    end;
    if (lstAtts.Count<>pCount) then
      raise EBOBError.Create('Ошибка соответствия атрибутов, обновите страницу');

    for i:= pCount-1 downto 0 do if (valCodes[i]<1) then begin // чистим незаданные значения
      prDelItemFromArray(i, attCodes);
      prDelItemFromArray(i, valCodes);
    end;
    pCount:= Length(attCodes);
    SetLength(arFinded, pCount);

    j:= lstAtts.Count;
    SetLength(arWareLinks, j);
    SetLength(arResult, j); // массив списков значений по кол-ву атрибутов
    for i:= 0 to High(arResult) do arResult[i]:= TLinks.Create;
    //---------------------------- перебираем список товаров с атрибутами группы
    with Cache.GBAttributes.GetGrp(grpID).Links.ListLinks do
      for j:= 0 to Count-1 do begin
        link:= Items[j];
        ware:= link.LinkPtr;
        for i:= 0 to High(arWareLinks) do arWareLinks[i]:= nil; // чистим рабочий набор
        for i:= 0 to High(arFinded) do arFinded[i]:= False;     // сбрасываем флаги

        for ii:= 0 to lstAtts.Count-1 do begin // рабочий набор линков с атрибутами товара
          att:= lstAtts[ii];
          jj:= att.ID;
          if ware.GBAttLinks.LinkExists(jj) then begin // проверяем фильтрующие значения
            linkt:= ware.GBAttLinks[jj];
            ind:= fnInIntArray(jj, attCodes);
            if (ind>-1) then            // флаг наличия заданного значения
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
            // значение заданного атрибута не проверяем, иначе в его списке будет 1 значение
            if (attCodes[ii]=att.ID) then Continue;
            flAvailable:= (flAvailable and arFinded[ii]);
          end;
          if not flAvailable then Continue; // не подходит - пропускаем

          if arResult[i].LinkExists(linkt.LinkTwoID) then Continue;

          linkAtt:= att.Links[linkt.LinkTwoID];
          linkAtt:= TTwoLink.Create(att.SrcID, linkt.LinkPtrTwo, linkAtt.LinkPtrTwo);
          arResult[i].AddLinkItem(linkAtt);
        end;
      end; // for j:= 0 to lstWareLinks.Count-1
    //----------------------------
    for i:= 0 to High(arResult) do arResult[i].LinkSort(AttValLinksSortCompare);

    Stream.WriteInt(lstAtts.Count);             // кол-во атрибутов
    for i:= 0 to lstAtts.Count-1 do begin
      att:= lstAtts[i];
      j:= att.ID+cGBattDelta;                   // код атрибута со сдвигом
      Stream.WriteInt(j);
      lst:= arResult[i].ListLinks; // фильтрованный список линков на значения атрибута
      j:= lst.Count;
      Stream.WriteInt(j);                       // Количество значений
      for ii:= 0 to j-1 do begin
        jj:= GetLinkID(lst[ii])+cGBattDelta;    // код значения со сдвигом
        Stream.WriteInt(jj);
        Stream.WriteStr(GetLinkName(lst[ii]));  // само значение
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
//===================================== Cписки для страницы "motul.vladislav.ua"
//====================== акции, продукты, тексты “Итоги”/“Информация покупателю”
procedure prMotulSitePage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMotulSitePage'; // имя процедуры/функции
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
//----------- прием из CGI для всех
    UserID:= Stream.ReadInt;
    ListKind:= Stream.ReadInt;  // вид списка
        //  mspAllActs    - список всех акций (вкладка “Акции”)
        //  mspPrLines    - список продуктов (вкладка “Продукты”)
        //  mspResumeInfo - заголовки и тексты “Итоги”, “Информация покупателю” (вкладка “Информация”)
        //  mspEnableActs - список незакрытых акций для привязки (вкладка “Продукты”)

    mess:= 'ListKind='+IntToStr(ListKind); // собираем строку для логирования
    spec:= IntToStr(mspResumeCode)+', '+IntToStr(mspInfoCode); // коды спец.акций
    try
      if not Cache.EmplExist(UserID) then
        raise EBOBError.Create(MessText(mtkNotEmplExist));

      empl:= Cache.arEmplInfo[UserID];
      if not empl.UserRoleExists(rolManageMotulSite) then
        raise EBOBError.Create(MessText(mtkNotRightExists));

      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, true);

      //------------ передача в CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      sPos:= Stream.Position;
      Stream.WriteInt(0); // место под кол-во

      case ListKind of
//------------------------------------------ список всех акций (вкладка “Акции”)
      mspAllActs:  begin
          mess:= mess+' (AllActs)'; // строка для логирования
          IBS.SQL.Text:= 'select MACTCODE, MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT'+
            ', iif(exists(select * from MOTULACTSPRODLINES where MAPLACTION=MACTCODE), 1, 0) as plex'+
            ', iif(exists(select * from MOTULACTSCIPHERS where MACPACTION=MACTCODE), 1, 0) as chex'+
            ' from MOTULACTACTIONS where not MACTCODE in ('+spec+')'+  // исключаем спец.акции
            ' order by MACTCODE';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ передача в CGI
            Stream.WriteInt(ibs.FieldByName('MACTCODE').AsInteger);    // код акции
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString); // заголовок акции
            Stream.WriteDouble(ibs.FieldByName('MACTFIRSTDATE').AsDateTime); // дата началя
            Stream.WriteDouble(ibs.FieldByName('MACTLASTDATE').AsDateTime);  // дата окончания
            Stream.WriteLongStr(ibs.FieldByName('MACTACTTEXT').AsString); // текст из MEMO
            Stream.WriteBool(ibs.FieldByName('plex').AsInteger=1); // признак наличия связанных продуктов
            Stream.WriteBool(ibs.FieldByName('chex').AsInteger=1); // признак наличия связанных CIPHER-ов
            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspAllActs
//-------------------- список незакрытых акций для привязки (вкладка “Продукты”)
      mspEnableActs:  begin
          mess:= mess+' (EnableActs)'; // строка для логирования
          IBS.SQL.Text:= 'select MACTCODE, MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT'+
            ' from MOTULACTACTIONS where not MACTCODE in ('+spec+')'+  // исключаем спец.акции
            '   and (MACTLASTDATE is null or MACTLASTDATE > current_timestamp)'+
            ' order by MACTCODE';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ передача в CGI
            Stream.WriteInt(ibs.FieldByName('MACTCODE').AsInteger);          // код акции
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString);       // заголовок акции
            Stream.WriteDouble(ibs.FieldByName('MACTFIRSTDATE').AsDateTime); // дата началя
            Stream.WriteDouble(ibs.FieldByName('MACTLASTDATE').AsDateTime);  // дата окончания
            Stream.WriteLongStr(ibs.FieldByName('MACTACTTEXT').AsString);    // текст из MEMO

            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspEnableActs
//---------------------------------------- список продуктов (вкладка “Продукты”)
      mspPrLines:  begin
          ms:= TMemoryStream.Create;
          mess:= mess+' (PrLines)'; // строка для логирования
          IBS.SQL.Text:= 'select MAPLCODE, MAPLNAME, MAPLPICTURE,'+
            ' MAPLACTION, MACTACTTITLE from MOTULACTSPRODLINES'+
            ' left join MOTULACTACTIONS on MACTCODE=MAPLACTION'+
            ' order by MAPLNAME';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ передача в CGI
            Stream.WriteInt(ibs.FieldByName('MAPLCODE').AsInteger); // код продукта
            Stream.WriteStr(ibs.FieldByName('MAPLNAME').AsString);  // наименование продукта
            try
              ibs.FieldByName('MAPLPICTURE').SaveToStream(ms); // картинка продукта (png)
              fsize:= ms.Size;
              Stream.WriteInt(fsize);       // размер картинки
              if (fsize>0) then begin
                ms.Position:= 0;
                Stream.CopyFrom(ms, fsize); // картинка
              end;
            finally
              ms.Clear;
            end;
            Stream.WriteInt(ibs.FieldByName('MAPLACTION').AsInteger);  // код связанной акции
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString); // заголовок связанной акции

            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspPrLines
//------------------------------------ заголовки и тексты (вкладка “Информация”)
      mspResumeInfo:  begin //---- код = mspResumeCode - “Итоги”
                            //---- код = mspInfoCode   - “Информация покупателю”
          mess:= mess+' (Resume/Info)'; // строка для логирования
          IBS.SQL.Text:= 'select MACTCODE, MACTACTTITLE, MACTACTTEXT'+
            ' from MOTULACTACTIONS where MACTCODE in ('+spec+')'+  // спец.акции
            ' order by MACTCODE';
          IBS.ExecQuery;
          while not IBS.EOF do begin
            //------------ передача в CGI
            Stream.WriteInt(ibs.FieldByName('MACTCODE').AsInteger);       // код
            Stream.WriteStr(ibs.FieldByName('MACTACTTITLE').AsString);    // заголовок
            Stream.WriteLongStr(ibs.FieldByName('MACTACTTEXT').AsString); // текст из MEMO

            inc(iCount);
            cntsORD.TestSuspendException;
            IBS.Next;
          end;
        end; // case mspResumeInfo

        else raise EBOBError.Create('Неизвестный тип списка '+IntToStr(ListKind));
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
//==================================== Операции на странице "motul.vladislav.ua"
procedure prMotulSiteManage(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prMotulSiteManage'; // имя процедуры/функции
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
//----------- прием из CGI для всех
    UserID:= Stream.ReadInt;
    OpKind:= Stream.ReadInt;  // вид операции

        //  mspAddAct    - добавить акцию      (вкладка “Акции”)
        //  mspEditAct   - редактировать акцию (вкладки “Акции” и “Информация”)
        //  mspDelAct    - удалить акцию       (вкладка “Акции”)
        //  mspAddPLine  - добавить продукт           (вкладка “Продукты”)
        //  mspEditPLine - редактировать продукт      (вкладка “Продукты”) (без рисунка)
        //  mspDelPLine  - удалить продукт            (вкладка “Продукты”)
        //  mspPictPLine - сохранить рисунок продукта (вкладка “Продукты”)

    mess:= 'OpKind='+IntToStr(OpKind); // собираем строку для логирования
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
//--------------------------------------------------------------- добавить акцию
      mspAddAct: begin
            //------------ прием из CGI
            title  := Stream.ReadStr;     // заголовок акции
            DateBeg:= Stream.ReadDouble;  // дата началя
            DateEnd:= Stream.ReadDouble;  // дата окончания
            text   := Stream.ReadLongStr; // текст для MEMO

            //------------ проверки
            flDBeg:= (DateBeg=0);
            flDEnd:= (DateEnd=0);
            mess:= mess+' (AddAct) title='+title+
              #13#10'DateBeg='+fnIfStr(flDBeg, '0', FormatDateTime('', DateBeg))+
              ' DateEnd='+fnIfStr(flDEnd, '0', FormatDateTime('', DateEnd))+
              #13#10'text='+text; // строка для логирования

            if (title='') then raise EBOBError.Create('Некорректный заголовок акции');
            if (text='')  then raise EBOBError.Create('Некорректный текст акции');
            if flDBeg then raise EBOBError.Create('Некорректная дата начала акции');
            if flDEnd then raise EBOBError.Create('Некорректная дата окончания акции');

            //----------- запись в базу
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
//---------------------------------------------------------- редактировать акцию
      mspEditAct: begin //---------- “Итоги” (act = mspResumeCode)
                        //---------- “Информация покупателю” (act = mspInfoCode)
            //------------ прием из CGI
            act    := Stream.ReadInt;     // код акции
            title  := Stream.ReadStr;     // заголовок акции
            text   := Stream.ReadLongStr; // текст для MEMO

            flSpecAct:= (act in [mspResumeCode, mspInfoCode]); // спец.акция - даты не передаются
            if not flSpecAct then begin
              DateBeg:= Stream.ReadDouble;  // дата началя
              DateEnd:= Stream.ReadDouble;  // дата окончания
            end;

            //------------ проверки
            sact:= IntToStr(act);
            flDBeg:= (DateBeg=0);
            flDEnd:= (DateEnd=0);
            case act of
              1: s:= 'EditResume'; // “Итоги”
              2: s:= 'EditInfo';   // “Информация покупателю”
              else s:= 'EditAct';  // обычная акция
            end;
            mess:= mess+' ('+s+') code='+sact+' title='+title+fnIfStr(act>2,
              #13#10'DateBeg='+fnIfStr(flDBeg, '0', FormatDateTime('', DateBeg))+
              ' DateEnd='+fnIfStr(flDEnd, '0', FormatDateTime('', DateEnd)), '')+
              #13#10'text='+text; // строка для логирования

            if (act<1)   then raise EBOBError.Create('Некорректный код акции');
            if (title='') then raise EBOBError.Create('Некорректный заголовок акции');
            if (text='')  then raise EBOBError.Create('Некорректный текст акции');
            if not flSpecAct then begin  // обычная акция
              if flDBeg then raise EBOBError.Create('Некорректная дата начала акции');
              if flDEnd then raise EBOBError.Create('Некорректная дата окончания акции');
            end;

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MACTACTTITLE, MACTFIRSTDATE, MACTLASTDATE, MACTACTTEXT'+
              ' from MOTULACTACTIONS where MACTCODE='+sact;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('Не найдена акция с кодом '+sact);
            titleOld:= IBS.FieldByName('MACTACTTITLE').AsString;
            textOld:= IBS.FieldByName('MACTACTTEXT').AsString;
            if not flSpecAct then begin // обычная акция
              DateBegOld:= IBS.FieldByName('MACTFIRSTDATE').AsDateTime;
              DateEndOld:= IBS.FieldByName('MACTLASTDATE').AsDateTime;
            end;
            IBS.Close;

            flTit:= (titleOld<>title);
            flTxt:= (textOld<>text);
            fl:= not flTit and not flTxt;
            if not flSpecAct then begin // обычная акция
              flDBeg:= (DateBegOld<>DateBeg);
              flDEnd:= (DateEndOld<>DateEnd);
              fl:= fl and not flDBeg and not flDEnd;
            end else begin         // Итоги/Инфо
              flDBeg:= False;
              flDEnd:= False;
            end;
            if fl then raise EBOBError.Create('Нет изменений');

            //----------- запись в базу
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
//---------------------------------------------------------------- удалить акцию
      mspDelAct: begin
            //------------ прием из CGI
            act:= Stream.ReadInt;         // код акции

            //------------ проверки
            sact:= IntToStr(act);
            mess:= mess+' (DelAct) code='+sact;
            if (act<1) then raise EBOBError.Create('Некорректный код акции');
            if (act<3) then raise EBOBError.Create('Запретный код акции '+sact);

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select iif(exists(select *'+
              ' from MOTULACTSPRODLINES where MAPLACTION=MACTCODE), 1, 0) as plex,'+
              ' iif(exists(select * from MOTULACTSCIPHERS'+
              '   where MACPACTION=MACTCODE), 1, 0) as chex'+
              ' from MOTULACTACTIONS where MACTCODE='+sact;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('Не найдена акция с кодом '+sact);
            if (ibs.FieldByName('plex').AsInteger=1) then
              raise EBOBError.Create('Акция связана с продуктом');
            if (ibs.FieldByName('chex').AsInteger=1) then
              raise EBOBError.Create('Акция связана с регистрацией');
            IBS.Close;

            //----------- запись в базу
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'delete from MOTULACTACTIONS where MACTCODE='+sact;
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspDelAct
//------------------------------------------------------------- добавить продукт
      mspAddPLine: begin
            //------------ прием из CGI
            title:= Stream.ReadStr;       // заголовок продукта
            act  := Stream.ReadInt;       // код связанной акции > 0 или 0 (нет акции)
            fsize:= Stream.ReadInt;       // размер картинки
            if (fsize>0) then begin
              ms:= TMemoryStream.Create;
              ms.CopyFrom(Stream, fsize); // картинка
              ms.Position:= 0;
            end;

            //------------ проверки
            sact:= IntToStr(act);
            mess:= mess+' (AddPLine) title='+title+ // строка для логирования
                   ' act='+sact+' fsize='+IntToStr(fsize);

            if (title='') then raise EBOBError.Create('Некорректное наименование продукта');
            if (fsize<1) and (act>0) then
              raise EBOBError.Create('Нельзя задать акцию продукту без рисунка');
            // картинка продукта (png) - кодированная в Base64, больше mspPictLimit Кб не сохранять
            // проверка размера рисунка - в webarm.cgi !!!
//            if (fsize>mspPictLimit*1000) then
//              raise EBOBError.Create('Размер рисунка не должен превышать '+IntToStr(mspPictLimit)+' Кб');

            spl:= AnsiUpperCase(StringReplace(title, ' ', '', [rfReplaceAll]));
            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MAPLCODE from MOTULACTSPRODLINES where MAPLcheckNAME=:nm';
            ibs.ParamByName('nm').AsString:= spl;
            IBS.ExecQuery;
            if not (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('Дубликат продукта `'+title+'`');
            IBS.Close;

            //----------- запись в базу
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
//------------------------------------------ редактировать продукт (без рисунка)
      mspEditPLine: begin
            //------------ прием из CGI
            pl   := Stream.ReadInt;       // код продукта
            title:= Stream.ReadStr;       // заголовок продукта
            act  := Stream.ReadInt;       // код связанной акции > 0 или 0 (нет акции)

            //------------ проверки
            spl:= IntToStr(pl);
            sact:= IntToStr(act);
            mess:= mess+' (EditPLine) code='+spl+' title='+title+' act='+sact;

            if (pl<1) then raise EBOBError.Create('Некорректный код продукта');
            if (title='') then raise EBOBError.Create('Некорректное наименование продукта');

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MAPLNAME, MAPLACTION, iif(MAPLPICTURE is null, 0, 1) pEx'+
                           fnIfStr(act>0, ', iif(exists(select * from MOTULACTACTIONS'+
                           ' where MACTCODE='+sact+'), 1, 0) as actex', '')+
                           ' from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('Не найден продукт с кодом '+spl);
            titleOld:= IBS.FieldByName('MAPLNAME').AsString;
            actOld:= IBS.FieldByName('MAPLACTION').AsInteger;
            fl:= (actOld<>act);
            if fl and (act>0) and (IBS.FieldByName('actex').AsInteger<1) then
              raise EBOBError.Create('Не найдена акция с кодом '+sact);
            if (IBS.FieldByName('pEx').AsInteger<1) and (act>0) then
              raise EBOBError.Create('Нельзя задать акцию продукту без рисунка');
            IBS.Close;
            flTit:= (titleOld<>title);
            if not flTit and not fl then raise EBOBError.Create('Нет изменений');

            //----------- запись в базу
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
//-------------------------------------------------------------- удалить продукт
      mspDelPLine: begin
            //------------ прием из CGI
            pl:= Stream.ReadInt;          // код продукта

            //------------ проверки
            spl:= IntToStr(pl);
            mess:= mess+' (DelPLine) code='+spl; // строка для логирования
            if (pl<1) then raise EBOBError.Create('Некорректный код продукта');

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select iif(exists(select * from MOTULACTSCIPHERS'+
                           ' where MACPPRODUCTLINE=MAPLCODE), 1, 0) as chex'+
                           ' from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('Не найден продукт с кодом '+spl);
            if (ibs.FieldByName('chex').AsInteger=1) then
              raise EBOBError.Create('Продукт связан с регистрацией');
            IBS.Close;

            //----------- запись в базу
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'delete from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspDelPLine
//--------------------------------------------------- сохранить рисунок продукта
      mspPictPLine: begin
            //------------ прием из CGI
            pl:= Stream.ReadInt;          // код продукта
            fsize:= Stream.ReadInt;       // размер картинки
            if (fsize>0) then begin
              ms:= TMemoryStream.Create;
              ms.CopyFrom(Stream, fsize); // картинка
              ms.Position:= 0;
            end;

            //------------ проверки
            spl:= IntToStr(pl);
            mess:= mess+' (PictPLine) code='+spl+' fsize='+IntToStr(fsize);

            if (pl<1) then raise EBOBError.Create('Некорректный код продукта');
            if (fsize<1) then raise EBOBError.Create('Нет рисунка');
            // картинка продукта (png) - кодированная в Base64, больше mspPictLimit Кб не сохранять
            // проверка размера рисунка - в webarm.cgi !!!
//            if (fsize>mspPictLimit*1000) then
//              raise EBOBError.Create('Размер рисунка не должен превышать '+IntToStr(mspPictLimit)+' Кб');

            with IBS.Transaction do if not InTransaction then StartTransaction;
            IBS.SQL.Text:= 'select MAPLCODE from MOTULACTSPRODLINES where MAPLCODE='+spl;
            IBS.ExecQuery;
            if (ibs.EOF and ibs.BOF) then
              raise EBOBError.Create('Не найден продукт с кодом '+spl);
            IBS.Close;

            //----------- запись в базу
            fnSetTransParams(ibs.Transaction, tpWrite, True);
            IBS.SQL.Text:= 'update MOTULACTSPRODLINES set MAPLPICTURE=:pict,'+
                           ' MAPLuser='+sUser+' where MAPLCODE='+spl;
            ibs.ParamByName('pict').LoadFromStream(ms);
            IBS.ExecQuery;
            ibs.Transaction.Commit;
          end; // mspPictPLine

        else raise EBOBError.Create('Неизвестный тип операции '+IntToStr(OpKind));
      end; // case OpKind
//------------------------------------------------------------------ ответ в CGI
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      case OpKind of
        mspAddAct  : Stream.WriteInt(act); // добавить акцию - код акции
        mspAddPLine: Stream.WriteInt(pl);  // добавить продукт - код продукта
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
