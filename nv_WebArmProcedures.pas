unit n_WebArmProcedures; // процедуры для WebArm

interface
uses Windows, Classes, SysUtils, Math, Forms, DateUtils, Contnrs, IBDatabase, IBSQL,
     n_free_functions, v_constants, v_DataTrans, v_Server_Common, n_LogThreads,
     n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common,
     n_DataCacheAddition, n_TD_functions, n_xml_functions, n_DataCacheObjects;

//                       работа с клиентами
procedure prWebArmGetRegionalFirms(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // список контрагентов регионала
procedure prWebArmGetFirmUsers(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // список юзеров контрагента
procedure prWebArmResetUserPassword(Stream: TBoBMemoryStream; ThreadData: TThreadData); // сброс пароля
procedure prWebArmSetFirmMainUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // назначить главного пользователя
procedure prUnblockWebUser(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // разблокировка клиента

//                       работа со счетами
procedure prWebArmGetFirmInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // передать реквизиты к/а
//procedure prWebArmGetFirmAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData); // передать список незакрытых счетов к/а
procedure prWebArmShowAccount(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // показать счет (если нет - создать новый)
procedure prWebArmShowFirmWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // показать остатки по товару и складам фирмы
procedure prWebArmEditAccountHeader(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // редактирование заголовка счета
procedure prWebArmEditAccountLine(Stream: TBoBMemoryStream; ThreadData: TThreadData);    // добавление/редактирование/удаление строки счета
 function fnGetStrSummByDoubleCurr(sum: Double; MainCurr: Integer): String;              // строка с суммой в 2-х валютах
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

//                    статистика по заказам и счетам
//procedure prGetWebArmSystemStatistic(Stream: TBoBMemoryStream; ThreadData: TThreadData);

//                       работа с регионами
procedure prWebArmGetRegionalZones(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // список регионов
procedure prWebArmInsertRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // добавление региона
procedure prWebArmDeleteRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // удаление региона
procedure prWebArmUpdateRegionalZone(Stream: TBoBMemoryStream; ThreadData: TThreadData); // изменение региона

//******************************************************************************
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

//                               Товары, атрибуты
procedure prGetListAttrGroupNames(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // (+ Web) Список групп атрибутов системы
procedure prGetListGroupAttrs(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // (+ Web) Список атрибутов группы
procedure prGetWareInfoView(Stream: TBoBMemoryStream; ThreadData: TThreadData);         // параметры товара для просмотра
procedure prGetCompareWaresInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // параметры товаров для сравнения

procedure prGetWareSatellites(Stream: TBoBMemoryStream; ThreadData: TThreadData);       // список сопутствующих товаров (Web & WebArm)
procedure prGetWareAnalogs(Stream: TBoBMemoryStream; ThreadData: TThreadData);          // список аналогов (Web & WebArm)
procedure prCommonWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // поиск товаров (Web & WebArm)
procedure prCommonGetRestsOfWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);   // вывод семафоров наличия товаров (Web & WebArm)
procedure prCommonGetNodeWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // список товаров по узлу (Web & WebArm)
procedure prCommonSearchWaresByAttr(Stream: TBoBMemoryStream; ThreadData: TThreadData); // поиск товаров по значениям атрибутов (Web & WebArm)
procedure prCommonGetWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // поиск товаров по оригин.номеру (Web & WebArm)
procedure prWebArmGetWaresDescrView(Stream: TBoBMemoryStream; ThreadData: TThreadData); // описания товаров для просмотра (счета WebArm)
procedure prWebarmGetDeliveries(Stream: TBoBMemoryStream; ThreadData: TThreadData);     // список доставок как результат поиска (WebArm)

procedure prGetWareTypesTree(Stream: TBoBMemoryStream; ThreadData: TThreadData);        // дерево типов товаров (сортировка по наименованию)

//                                Дерево узлов
procedure prTNAGet(Stream: TBoBMemoryStream; ThreadData: TThreadData);      // Дерево узлов
procedure prTNANodeAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // Добавить узел в дерево
procedure prTNANodeDel(Stream: TBoBMemoryStream; ThreadData: TThreadData);  // Удалить узел из дерева
procedure prTNANodeEdit(Stream: TBoBMemoryStream; ThreadData: TThreadData); // редактировать узел в дереве

//                                Двигатель
procedure prGetEngineTree(Stream: TBoBMemoryStream; ThreadData: TThreadData); // (+ Web) Дерево узлов двигателя

//******************************************************************************
//                              импорт из TDT, отчеты
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

//                               разное
procedure prSaveStrListWithIDToStream(const pLst: TStringList; Stream: TBoBMemoryStream); // Запись TStringList с ID в Objects в поток

procedure prWebArmGetNotificationsParams(Stream: TBoBMemoryStream; ThreadData: TThreadData); // список уведомлений (WebArm)

implementation
//******************************************************************************


uses n_IBCntsPool, v_Functions, t_ImportChecking;//                              импорт из TDT
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
      15, 25, 34, 39, 40: pFileExt:= '.xml';
      24:  // администрирование баз
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
             // def - пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
//          else
          pFileExt:= '.txt';
//        end;
    end;
    fname:= pFilePath+fnFormRepFileName(IntToStr(RepKind), pFileExt, constOpExport);
  end;
  if FileExists(fname) and not SysUtils.DeleteFile(fname) then
    raise EBOBError.Create(MessText(mtkNotDelPrevFile));
end;
//=================================================== параметры письма с отчетом
procedure prFormRepMailParams(var Subj, ContentType: string;
          var BodyMail: TStringList; RepKind: integer; flSet: Boolean=False);
  //--------------------------------
  function GetRepNameTD(s: string): string;
  begin
    if flSet then Result:= 'Отчет о загрузке '+s+' легк.авто из TecDoc'
    else Result:= 'Отчет о проверке '+s+' легк.авто по TecDoc';
  end;
  //--------------------------------
begin
  case RepKind of
    13   : Subj:= GetRepNameTD('производителей');
    14   : Subj:= GetRepNameTD('модельных рядов');
    15   : Subj:= GetRepNameTD('моделей');
    25  : Subj:= GetRepNameTD('произв.+м.р.+мод.');
    34    : Subj:= GetRepNameTD('узлов');
    36  : Subj:= 'Отчет об артикулах TecDoc для инфо-групп Гроссби';
    39  : Subj:= 'Замены инфо-текстов TecDoc';
    40: Subj:= 'Отчет о проверке привязок товаров к артикулам TecDoc';
    53 : Subj:= 'Отчет о клонировании к/а';
    24:  // администрирование баз
      if flSet then begin
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'set24', 0) of
//          else
          Subj:= 'Отчет об удалении моделей';
//        end;
      end else begin
//        case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
//          else
          Subj:= 'Отчет о пакетной загрузке';
//        end;
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
(*      13: begin // 13-stamp - поиск новых производителей авто из TDT
          lst:= fnGetNewAutoManufFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName); // csv
          ContentType:= CSVFileContentType;
        end;
      14: begin // 14-stamp - поиск новых мод.рядов авто из TDT
          lst:= fnGetNewAutoModelLineFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName); // csv
          ContentType:= CSVFileContentType;
        end;
      15: begin // 15-stamp - поиск новых моделей авто из TDT
          lst:= fnGetNewAutoModelFromTDT(UserID, ThreadData);
          SaveListToFile(lst, pFileName);          // xml
          ContentType:= XMLContentType;
        end;  *)
      25: begin // 25-stamp - поиск новых производителей, м.р., моделей авто из TDT
        lst:= fnGetNewAutoMfMlModFromTDT(UserID, ThreadData);
        SaveListToFile(lst, pFileName);          // xml
        ContentType:= XMLContentType;
      end;
      34: begin // 34-stamp - поиск новых узлов авто из TDT
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
      24: begin // // 24-stamp - пакетная загрузка связок, критериев, текстов, файлов и ОН товаров из TDT
          case GetIniParamInt(nmIniFileBOB, 'reports', 'get24', 0) of
            3: begin // простановка контрактов в db_ORD
                lst:= SetClientContractsToORD(UserID, ThreadData);
                SaveListToFile(lst, pFileName);          // txt
                ContentType:= FileContentType;
//                raise EBOBError.Create('отчет '+IntToStr(ReportKind)+'(3) недоступен');
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
(*      13: begin // 13-imp - загрузка / изменение производителей авто из TDT
          prTestFileExt(ExtractFileExt(pFileName), ReportKind);          // проверяем расширение файла
          lst:= fnSetNewAutoManufFromTDT(UserID, pFileName, ThreadData); // отчет для выгрузки в файл CSV
          prFormRepFileName(pFilePath, pFileName, ReportKind, True);     // формируем имя файла отчета
          fnStringsLogToFile(lst, pFileName);
          ContentType:= CSVFileContentType;
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      14: begin // 14-imp - загрузка / изменение мод.рядов авто из TDT
          prTestFileExt(ExtractFileExt(pFileName), ReportKind);              // проверяем расширение файла
          lst:= fnSetNewAutoModelLineFromTDT(UserID, pFileName, ThreadData); // отчет для выгрузки в файл CSV
          prFormRepFileName(pFilePath, pFileName, ReportKind, True);         // формируем имя файла отчета
          fnStringsLogToFile(lst, pFileName);
          ContentType:= CSVFileContentType;
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      15: begin // 15-imp - загрузка / изменение моделей авто из TDT
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewAutoModelFromTDT(UserID, pFileName, ThreadData);   // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;  *)
      25: begin // 25-imp - загрузка новых производителей, м.р., моделей авто из TDT
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewAutoMfMlModFromTDT(UserID, pFileName, ThreadData);   // обрабатываем файл и в него же пишем отчет
          ContentType:= FileContentType;                     // ???
          prFormRepMailParams(Subj, ContentType, BodyMail, ReportKind, True); // параметры письма с отчетом
        end;
      34: begin // 34-imp - загрузка  / корректировка узлов авто из Excel
          pFileName1:= pFileName;                                    // запоминаем имя исходного файла
          prFormRepFileName(pFilePath, pFileName, ReportKind, True); // формируем имя файла отчета
          CopyFile(PChar(pFileName1),  PChar(pFileName), False);     // копируем исходный файл в отчет
          if FileExists(pFileName) then DeleteFile(pFileName1);
          prSetNewTreeNodesFromTDT(UserID, pFileName, ThreadData);   // обрабатываем файл и в него же пишем отчет
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
//================================================ список контрагентов регионала
procedure prWebArmGetRegionalFirms(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetRegionalFirms'; // имя процедуры/функции
var EmplId, FirmID, i, j: integer;
    Codes: Tai;
    Template, errmess: string;
    empl: TEmplInfoItem;
    flManageSprav: Boolean;
begin
  Stream.Position:= 0;
  SetLength(Codes, 0);
  EmplId:= Stream.ReadInt;          // код регионала (0-все)
  Template:= trim(Stream.ReadStr);  // фильтр наименования контрагента
  prSetThLogParams(ThreadData, 0, EmplId, 0, 'Template='+Template); // логирование
  try
    if CheckNotValidUser(EmplId, isWe, errmess) then raise EBOBError.Create(errmess);
    empl:= Cache.arEmplInfo[EmplId];            // проверяем право пользователя
    flManageSprav:= empl.UserRoleExists(rolManageSprav);
    if not (flManageSprav or empl.UserRoleExists(rolRegional) or empl.UserRoleExists(rolUiK)) then // vc
      raise EBOBError.Create(MessText(mtkNotRightExists));

    j:= fnIfint(flManageSprav or empl.UserRoleExists(rolUiK), 0, EmplID);   // vc
    Codes:= Cache.GetRegFirmCodes(j, Template); // список кодов неархивных контрагентов
    j:= length(Codes);
    if (j<1) then raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteInt(j);
    for i:= 0 to j-1 do begin
      FirmID:= Codes[i];
      Stream.WriteInt(FirmID);
      with Cache.arFirmInfo[FirmID] do begin
        Stream.WriteStr(UPPERSHORTNAME);
        Stream.WriteStr(Name);
        Stream.WriteStr(NUMPREFIX);
      end;
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
var EmplId, FirmID, i, j, ii: integer;
    Users: Tai;
    flManageSprav: Boolean;
    firm: TFirmInfo;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  try
    EmplId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'FirmID='+IntToStr(FirmID)); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    Cache.TestFirms(FirmID, True, False, True); // проверяем частично фирму
    if not Cache.FirmExist(FirmId) then raise EBOBError.Create(MessText(mtkNotFirmExists));

    firm:= Cache.arFirmInfo[FirmId];
    empl:= Cache.arEmplInfo[EmplId];
    flManageSprav:= empl.UserRoleExists(rolManageSprav);

    if not (flManageSprav or empl.UserRoleExists(rolUiK) or // vc
      (empl.UserRoleExists(rolRegional) and firm.CheckFirmManager(emplID))) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    Cache.TestClients(firm.SUPERVISOR, True, False, True); // проверяем частично должн.лиц контрагента
                                          
    SetLength(Users, Length(firm.FirmClients)); // получаем список должн.лиц контрагента
    ii:= 0; // счетчик должн.лиц
    for i:= Low(firm.FirmClients) to High(firm.FirmClients) do begin
      j:= firm.FirmClients[i];
      if not Cache.ClientExist(j) then Continue;
      Users[ii]:= j;
      inc(ii);
    end;
    if ii<1 then raise EBOBError.Create('Сотрудники контрагента не найдены.');

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteInt(ii);        // кол-во должн.лиц
    for i:= 0 to ii-1 do begin
      j:= Users[i];
      Stream.WriteInt(j); // код
//      Stream.WriteBool(firm.SUPERVISOR=j); // признак Главного пользователя  // vc
      with Cache.arClientInfo[j] do begin
        Stream.WriteStr(Name);  // ФИО
        Stream.WriteStr(Post);  // должность
        Stream.WriteStr(Phone); // телефоны
        Stream.WriteStr(Mail); //  vc
        Stream.WriteStr(Login); // логин
//          Stream.WriteBool(Blocked); // признак блокированности // vc
        Stream.WriteByte(byte(Blocked)+2*fnIfInt(flManageSprav, 1, 0)+fnIfInt((firm.SUPERVISOR=j), 4, 0)); // признак блокированности + признак суперпупера // vc
      end;
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(Users, 0);
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
begin
  OrdIBS:= nil;
  OrdIBD:= nil;
  Stream.Position:= 0;
  try
    EmplId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    UserCode:= Stream.ReadStr;
    UserId:= StrToIntDef(UserCode, 0);
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'FirmID='+IntToStr(FirmID)+#13#10'UserId='+UserCode); // логирование

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserId];
    if (Client.Login='') then raise EBOBError.Create(MessText(mtkNotClientExist));

    empl:= Cache.arEmplInfo[EmplId];         // проверяем право пользователя
    if not (empl.UserRoleExists(rolRegional) and
      Cache.arFirmInfo[FirmId].CheckFirmManager(emplID)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

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
    newpass, UserCode, UserLogin, errmess: string;
    flNewUser: boolean;
    Client: TClientInfo;
    firma: TFirmInfo;
    Strings: TStringList;
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
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'FirmID='+IntToStr(FirmID)+
      #13#10'UserId='+UserCode+#13#10'UserLogin='+UserLogin); // логирование

    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    Client:= Cache.arClientInfo[UserId];

    if (Client.Mail='') then raise EBOBError.Create('Нельзя делать главным пользователя без email'); // vc

    flNewUser:= (Client.Login='');
    if flNewUser then begin
      if (Client.Post='') then raise EBOBError.Create(MessText(mtkNotClientExist));
      if (UserLogin='')   then raise EBOBError.Create(MessText(mtkNotSetLogin));
    end;

    firma:= Cache.arFirmInfo[FirmId];

    if not ((Cache.arEmplInfo[EmplId].UserRoleExists(rolRegional) // проверяем право пользователя  // vc
      and firma.CheckFirmManager(emplID)) or Cache.arEmplInfo[EmplId].UserRoleExists(rolUiK)) then // vc
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if flNewUser and not fnCheckOrderWebLogin(UserLogin) then
      raise EBOBError.Create(MessText(mtkNotValidLogin));

    if flNewUser and not fnNotLockingLogin(UserLogin) then // проверяем, не относится ли логин к запрещенным
      raise EBOBError.Create(MessText(mtkLockingLogin, UserLogin));
      // уникальность логина в базе проверяется при добавлении пользователя

    if flNewUser or (firma.SUPERVISOR<>UserId) then try
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpWrite, true);
      IBS.SQL.Text:= 'select rPassw,rErrText from SetFirmMainUser('+
        UserCode+', '+IntToStr(FirmID)+', :login, '+IntToStr(EmplId)+', 0)'; // vc
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
      firma.SUPERVISOR:= UserId;
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
// vc +++
      Strings:=TStringList.Create;
      Strings.Add('Здравствуйте');
      Strings.Add('Для Вас, как клиента Компании "Владислав", создана учетная запись на сайте http://order.vladislav.ua.');
      Strings.Add('Логин: '+Client.Login);
      Strings.Add('Пароль: '+Client.Password);
      Strings.Add('');
      errmess:= n_SysMailSend(Client.Mail, 'Для Вас создана учетная запись на сайте order.vladislav.ua', Strings, nil, '', '', true);
      prSaveCommonError(Stream, ThreadData, nmProc, errmess, '', True);
      if errmess<>'' then raise EBOBError.Create('Учетная запись создана успешно, но при отправке письма клиенту произошла ошибка.'
        +'  Сообщите клиенту его логин и предложите получить пароль для входа через систему восстановления пароля');
// vc ---
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteStr(newpass);

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  prFree(Strings); // vc
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
    flDirector: boolean;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  empl:= nil;
  DateStart:= 0;
  DateFinish:= 0;
  i:= 0;
  flDirector:= False;
  try
    EmplId:= Stream.ReadInt;
    try
      if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
      empl:= Cache.arEmplInfo[EmplId];
      flDirector:= empl.UserRoleExists(rolSaleDirector);

      if not (flDirector or empl.UserRoleExists(rolUiK) or empl.UserRoleExists(rolRegional) // vc
        or empl.UserRoleExists(rolSuperRegional)) then
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
      prSetThLogParams(ThreadData, 0, EmplId, 0, 'DateStart='+
        fnIfStr(DateStart>0, FormatDateTime(cDateFormatY2, DateStart), '')+
        #13#10'DateFinish='+fnIfStr(DateFinish>0, FormatDateTime(cDateFormatY2, DateFinish), '')+
        #13#10'OREGFIRMNAME LIKE='+s1+#13#10'OREGDPRTCODE='+IntToStr(i)+#13#10+s); // логирование
    end;

    if (DateStart>0) then s:= s+fnIfStr(s='', '', ' and ')+'OREGCREATETIME>=:DateStart';
    if (DateFinish>0) then s:= s+fnIfStr(s='', '', ' and ')+'OREGCREATETIME<=:DateFinish';
    if (s1<>'')  then s:= s+fnIfStr(s='','',' and ')+'OREGFIRMNAME LIKE ''%'+s1+'%''';

    if not flDirector then i:= empl.EmplDprtID;
    if (i>-1) then s:= s+fnIfStr(s='', '', ' and ')+'OREGDPRTCODE ='+IntToStr(i);

    IBD:= cntsORD.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
    IBS.SQL.Text:= 'select * from ORDERTOREGISTER '+
      ' left join REGIONALZONES on RGZNCODE=OREGREGION'+fnIfStr(s='','',' where '+s);
    if DateStart>0 then IBS.ParamByName('DateStart').AsDateTime:= Round(DateStart);
    if DateFinish>0 then IBS.ParamByName('DateFinish').AsDateTime:= Round(DateFinish);

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
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'OREGCODE='+IntToStr(OREGCODE)+#13#10'OREGCOMMENT='+OREGCOMMENT); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    empl:= Cache.arEmplInfo[EmplId];
    if not (empl.UserRoleExists(rolRegional) or empl.UserRoleExists(rolSuperRegional)) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if OREGCOMMENT='' then raise EBOBError.Create('Не указана причина аннулирования заявки.');

    IBD:= cntsORD.GetFreeCnt;
    IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
    IBS.SQL.Text:= 'SELECT OREGSTATE, OREGDPRTCODE FROM ORDERTOREGISTER WHERE OREGCODE='+IntToStr(OREGCODE);
    IBS.ExecQuery;
    if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundRegOrd));
    if IBS.FieldByName('OREGSTATE').AsInteger>0 then
      raise EBOBError.Create(MessText(mtkRegOrdAddOrAnn));
    if (empl.EmplDprtID<>IBS.FieldByName('OREGDPRTCODE').AsInteger) then
      raise EBOBError.Create(MessText(mtkRegOrdNotYourFil));
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
    UserLogin, UserCode, FirmCode, newpass, comment, errmess: String;
    flNewUser, flNewFirm: Boolean;
    empl: TEmplInfoItem;
    Client: TClientInfo; // vc
begin
  Stream.Position:= 0;
  IBS:= nil;
  IBD:= nil;
  try                                  // тут всякие проверки
    EmplId:= Stream.ReadInt;
    OREGCODE:= Stream.ReadInt;
    UserLogin:= Stream.ReadStr;
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'OREGCODE='+IntToStr(OREGCODE)+
      #13#10'UserLogin='+UserLogin+#13#10'UserID='+UserCode+#13#10'FirmID='+FirmCode); // логирование

    UserCode:= IntToStr(UserID);
    FirmCode:= IntToStr(FirmID);
    if not Cache.EmplExist(EmplId) then
      raise EBOBError.Create(MessText(mtkNotEmplExist));
    empl:= Cache.arEmplInfo[EmplId];
    if not (empl.UserRoleExists(rolRegional) or empl.UserRoleExists(rolUiK)) then // vc
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    with Cache.arFirmInfo[FirmID] do begin
      if empl.UserRoleExists(rolRegional) and not CheckFirmManager(emplID) then // проверяем право пользователя // vc
        raise EBOBError.Create(MessText(mtkNotRightExists));
      flNewFirm:= StrToIntDef(NUMPREFIX, 0)<1; // новая Web-фирма
      flNewUser:= True;
      if not flNewFirm then // если Web-фирма есть
        for i:= Low(FirmClients) to High(FirmClients) do
          if Cache.ClientExist(FirmClients[i]) and
            (Cache.arClientInfo[FirmClients[i]].Login<>'') then begin
            flNewUser:= False; // если есть хоть один Web-клиент
            break;
          end;
    end; // with Cache.arFirmInfo[FirmID]


    Client:= Cache.arClientInfo[UserId]; // vc
    if (Client.Mail='') then raise EBOBError.Create('Нельзя делать главным пользователя без email'); // vc

    flNewUser:= (Client.Login='');

    if flNewUser then begin // если новый Web-клиент
      if (Client.Post='') then raise EBOBError.Create(MessText(mtkNotClientExist)); // vc
//      if (Cache.arClientInfo[UserID].Post='') then // vc
//        raise EBOBError.Create('У клиента нет должности.'); // ??? // vc
      if (UserLogin='') then raise EBOBError.Create(MessText(mtkNotSetLogin));
    end;

    try
      IBD:= cntsORD.GetFreeCnt;
      IBS:= fnCreateNewIBSQL(IBD, 'IBS_'+nmProc, ThreadData.ID, tpRead, True);
      IBS.SQL.Text:= 'SELECT OREGSTATE, OREGDPRTCODE FROM ORDERTOREGISTER WHERE OREGCODE='+IntToStr(OREGCODE);
      IBS.ExecQuery;
      if IBS.Bof and IBS.Eof then raise EBOBError.Create(MessText(mtkNotFoundRegOrd));
      if IBS.FieldByName('OREGSTATE').AsInteger>0 then
        raise EBOBError.Create(MessText(mtkRegOrdAddOrAnn));
      if (empl.EmplDprtID<>IBS.FieldByName('OREGDPRTCODE').AsInteger) then
        raise EBOBError.Create(MessText(mtkRegOrdNotYourFil));
      IBS.Close;

      fnSetTransParams(IBS.Transaction, tpWrite); // готовимся писать

      if flNewUser then begin // если новый клиент
        if not fnCheckOrderWebLogin(UserLogin) then
          raise EBOBError.Create(MessText(mtkNotValidLogin));
        if not fnNotLockingLogin(UserLogin) then // проверяем, не относится ли логин к запрещенным
          raise EBOBError.Create(MessText(mtkLockingLogin, UserLogin));
          // уникальность логина в базе проверяется при добавлении пользователя

        with ibs.Transaction do if not InTransaction then StartTransaction;
        IBS.SQL.Text:= 'select rPassw,rErrText from SetFirmMainUser('+
          UserCode+', '+IntToStr(FirmID)+', :login, '+IntToStr(EmplId)+', 0)'; // vc
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
      end else begin
        newpass:= 'Заявка закрыта по контрагенту'; // сообщение юзеру
        comment:= newpass+' '+Cache.arFirmInfo[FirmID].Name;
      end;
      comment:= comment+' пользователем '+empl.EmplShortName;

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
    finally
      prFreeIBSQL(IBS);
      cntsGRB.SetFreeCnt(IBD);
    end;

    if flNewUser then Cache.TestClients(UserID, true, false, true); // обновляем параметры клиента и фирмы в кэше

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteBool(flNewUser); // признак нового пользователя
    Stream.WriteStr(newpass); // временный пароль или сообщение
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
    prSetThLogParams(ThreadData, 0, EmplId, 0, ''); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolSaleDirector) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpRead, True);
    ibs.SQL.Text:= 'select * from REGIONALZONES order by RGZNNAME';
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
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'email='+email+
      #13#10'ZoneName='+ZoneName+#13#10'idprt='+IntToStr(idprt)); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolSaleDirector) then
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
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'zcode='+IntToStr(zcode)); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolSaleDirector) then
      raise EBOBError.Create(MessText(mtkNotRightExists));
    if (zcode<1) then raise EBOBError.Create(MessText(mtkNotSetRegion));

    IBD:= cntsORD.GetFreeCnt;
    ibs:= fnCreateNewIBSQL(IBD, 'ibs_'+nmProc, ThreadData.ID, tpWrite, true);
    ibs.SQL.Text:= 'delete from REGIONALZONES where RGZNCODE='+IntToStr(zcode);
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
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'zcode='+IntToStr(zcode)+
      #13#10'email='+email+#13#10'ZoneName='+ZoneName+#13#10'idprt='+IntToStr(idprt)); // логирование

    if not Cache.EmplExist(EmplId) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not Cache.arEmplInfo[EmplId].UserRoleExists(rolSaleDirector) then
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
var UserID, FirmID, SysID, i: Integer;
    errmess: String;
    lst: TStringList;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    SysID:= Stream.ReadInt;  // код системы
    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'SysID='+IntToStr(SysID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    lst:= Cache.AttrGroups.GetListAttrGroups(SysID); // Список групп атрибутов (TStringList) not Free !!!
    if not Assigned(lst) or (lst.Count<1) then
      raise EBOBError.Create(MessText(mtkNotFoundData));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteInt(lst.Count);  // кол-во групп
    for i:= 0 to lst.Count-1 do begin
      Stream.WriteInt(Integer(lst.Objects[i])); // код
      Stream.WriteStr(lst[i]);                  // название
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//============================================== (+ Web) Список атрибутов группы
procedure prGetListGroupAttrs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetListGroupAttrs'; // имя процедуры/функции
var UserID, FirmID, SysID, grpID, i, ii: Integer;
    errmess: String;
    AttrGroup: TAttrGroupItem;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    grpID:= Stream.ReadInt;  // код группы атрибутов
    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'grpID='+IntToStr(grpID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if not Cache.AttrGroups.ItemExists(grpID) then raise EBOBError.Create(MessText(mtkNotFoundAttGr, IntToStr(grpID)));
    AttrGroup:= Cache.AttrGroups.GetAttrGroup(grpID); // группа атрибутов
    SysID:= AttrGroup.TypeSys;
    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    with AttrGroup.GetListGroupAttrs do try // Список атрибутов группы (TList)
      if (Count<1) then raise EBOBError.Create(MessText(mtkNotFoundData));
      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteInt(Count);       // кол-во атрибутов
      for i:= 0 to Count-1 do with TAttributeItem(Items[i]) do begin
        Stream.WriteInt(ID);        // код
        Stream.WriteStr(Name);      // название
        Stream.WriteByte(TypeAttr); // Тип
        with ListValues do begin    // значения атрибутов
          Stream.WriteInt(Count);                  // Количество
          for ii:= 0 to Count-1 do begin
            Stream.WriteInt(Integer(Objects[ii])); // код значения
            Stream.WriteStr(Strings[ii]);          // само значение
          end;
        end;
      end;
    finally Free; end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//=============================================== параметры товара для просмотра
procedure prGetWareInfoView(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareInfoView'; // имя процедуры/функции
var UserID, FirmID, WareID, i, Count1, sPos, j, ModelID, NodeID: Integer;
   s, sFilters: string;
//   txt1, txt2, DelimBr, DelimColor, TitleBegin: string;
   Files: TarWareFileOpts;
   isEngine: boolean;
   List: TStringList;
   aiWares: Tai;
//   node: TAutoTreeNode;
   Engine: TEngine;
   Model: TModelAuto;
begin
  List:= nil;
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;  // код товара
    ModelID:= Stream.ReadInt;
    NodeID:= Stream.ReadInt;
    isEngine:= Stream.ReadBool;
    sFilters:= Stream.ReadStr;

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'WareID='+IntToStr(WareID)+
      #13#10+fnIfStr(isEngine, 'EngineID=', 'ModelID=')+IntToStr(ModelID)+
      #13#10'NodeID='+IntToStr(NodeID)+#13#10'sFilters='+sFilters);

//    if CheckNotValidUser(UserID, FirmID, s) then raise EBOBError.Create(s);
    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    With Cache.GetWare(WareID) do begin
      if IsArchive then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

      Stream.Clear;
      Stream.WriteInt(aeSuccess);  // Передаем параметры товара
      Stream.WriteStr(Name);          // наименование
      Stream.WriteBool(IsSale);       // признак распродажи
      Stream.WriteBool(IsNonReturn);  // признак невозврата
      Stream.WriteBool(IsCutPrice);   // признак уценки
      Stream.WriteStr(BrandNameWWW);  // бренд для файла логотипа
      Stream.WriteStr(BrandAdrWWW);   // адрес ссылки на сайт бренда
      Stream.WriteStr(WareBrandName); // бренд
      Stream.WriteDouble(divis);      // кратность
      Stream.WriteStr(MeasName);      // ед.изм.
      Stream.WriteStr(Comment);       // описание

      with GetWareAttrValuesView do try // список названий и значений атрибутов товара (TStringList)
        Stream.WriteInt(Count);                         // кол-во атрибутов
        for i:= 0 to Count-1 do begin
          Stream.WriteStr(Names[i]);                    // название атрибута
          Stream.WriteStr(ExtractParametr(Strings[i])); // значение атрибута
        end;
      finally Free; end;

//      DelimBr:= fnCodeBracketsForWeb('</b>');
//      DelimColor:= fnCodeBracketsForWeb('<b style="color: blue;">');
//      TitleBegin:= 'Условия применимости товара ';
//      txt1:= '';

      with Cache.FDCA do try try
        if (ModelId<1) or (NodeID<1) then raise EBOBError.Create('');
        SetLength(aiWares, 1);
        aiWares[0]:= WareID;
        if IsEngine then begin         // --------------------------- двигатель
          if not Engines.ItemExists(ModelId) then
            raise EBOBError.Create('Неверно указан двигатель');

          Engine:= Engines.GetEngine(ModelId);
          if not AutoTreeNodesSys[constIsAuto].NodeExists(NodeID) then
            raise EBOBError.Create('Неверно указан узел');

          List:= Engine.GetEngNodeWareUsesView(NodeID, aiWares, sFilters);
          if (List.Count<1) then EBOBError.Create('Нет условий');
{          node:= AutoTreeNodesSys[constIsAuto][NodeID];
          if node.IsEnding then begin
            txt1:= ' к узлу '+DelimColor+node.Name+DelimBr;
            txt2:= ' двигателя ';
          end else txt2:= ' к двигателю ';
          Stream.WriteStr(TitleBegin+DelimColor+Name+DelimBr+txt1+txt2+
                          DelimColor+Engine.WebName+DelimBr);  }
//          Stream.WriteStr('');

        end else begin                    // --------------------------- модель
          if not Models.ModelExists(ModelId) then
            raise EBOBError.Create('Неверно указана модель');

          Model:= Models[ModelId];
          if not AutoTreeNodesSys[Model.TypeSys].NodeExists(NodeID) then
            raise EBOBError.Create('Неверно указан узел');

          List:= Cache.GetWaresModelNodeUsesAndTextsView(ModelID, NodeID, aiWares, sFilters);
          if (List.Count<1) then raise EBOBError.Create('Нет условий');
{          node:= AutoTreeNodesSys[Model.TypeSys][NodeID];
          if not node.IsEnding then begin
            txt1:= ' к узлу '+DelimColor+node.Name+DelimBr;
            txt2:= ' модели ';
          end else txt2:= ' к модели ';
          Stream.WriteStr(TitleBegin+DelimColor+Name+DelimBr+txt1+txt2+
                          DelimColor+Model.WebName+DelimBr);   }
//          Stream.WriteStr('');
        end;
        Stream.WriteStr(List.Text);
      except
        on E: Exception do begin
//          Stream.WriteStr('');
          Stream.WriteStr('');
        end;
      end; // with Cache.FDCA
      finally
        prFree(List);
        SetLength(aiWares, 0);
      end;

      s:= '';
      with GetWareCriValuesView do try
        if Count>0 then s:= Text;
      finally Free; end;
      Stream.WriteStr(s);

      Files:= GetWareFiles;
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
      Stream.WriteInt(j);
      Stream.Position:= Stream.Size; // если будем еще добавлять инфо по товару
    end; // With Cache.GetWare(WareID)
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(Files, 0);
end;
//============================================== параметры товаров для сравнения
procedure prGetCompareWaresInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetCompareWaresInfo'; // имя процедуры/функции
var UserID, FirmID, CurrID, WareID, agID, i, j, WareCount, contID: Integer;
    errmess: String;
    Ware: TWareInfo;
    WaresList: TStringList;
    attCodes: Tai;
    pRetail, pSelling: double;
begin
  Stream.Position:= 0;
  setLength(attCodes, 0);
  agID:= 0;
  WaresList:= nil;
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // для контрактов
    WareCount:= Stream.ReadInt;  // входное кол-во товаров

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'WareCount='+IntToStr(WareCount));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);

    if FirmID=isWe then CurrID:= cDefCurrency
    else CurrID:= Cache.arClientInfo[UserID].SearchCurrencyID; // код валюты сравнения
//    else CurrID:= Cache.arFirmInfo[FirmID].GetContract(contID).ContCurrency;


    WaresList:= fnCreateStringList(True, dupIgnore, WareCount); // список с проверкой на дубликаты кодов товаров  ???

    for i:= 0 to WareCount-1 do begin           // принимаем коды товаров
      WareID:= Stream.ReadInt;
      if Cache.WareExist(WareID) then begin     // проверка существования товара
        Ware:= Cache.GetWare(WareID);
        if not Ware.IsArchive then begin
          if agID<1 then agID:= Ware.AttrGroupID;        // определяем код группы атрибутов
          if (agID>0) and (agID=Ware.AttrGroupID) then   // потом берем только с этой группой
            WaresList.AddObject(Ware.Name, Ware); // в Object - ссылка на товар
        end;    
      end;
    end;
    if (agID<1) or (WaresList.Count<1) then raise EBOBError.Create(MessText(mtkNotParams));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(CurrID)); // наименование валюты сравнения

    with Cache.AttrGroups.GetAttrGroup(agID).GetListGroupAttrs do try // список атрибутов группы (TList)
      Stream.WriteInt(Count);         // кол-во атрибутов группы
      setLength(attCodes, Count);     // порядок кодов атрибутов
      for j:= 0 to Count-1 do with TAttributeItem(Items[j]) do begin
        attCodes[j]:= ID;             // запоминаем порядок кодов атрибутов
        Stream.WriteStr(Name);        // передаем название атрибута
      end;
    finally Free; end;

    Stream.WriteInt(WaresList.Count); // исходящее кол-во товаров
    for i:= 0 to WaresList.Count-1 do with TWareInfo(WaresList.Objects[i]) do begin // передаем параметры товара
      Stream.WriteInt(ID);            // код товара
      Stream.WriteStr(Name);          // наименование
      Stream.WriteBool(IsSale);       // признак распродажи
      Stream.WriteBool(IsNonReturn);  // признак невозврата
      Stream.WriteBool(IsCutPrice);   // признак уценки
      Stream.WriteStr(BrandNameWWW);  // бренд для файла логотипа
      Stream.WriteStr(BrandAdrWWW);   // адрес ссылки на сайт бренда
      Stream.WriteStr(WareBrandName); // бренд
      Stream.WriteDouble(divis);      // кратность
      Stream.WriteStr(MeasName);      // ед.изм.
      Stream.WriteStr(Comment);       // описание
      CalcFirmPrices(pRetail, pSelling, FirmID, CurrID, contID); // розничная и продажная цены товара для фирмы
      Stream.WriteDouble(pRetail); // цена розницы
      if FirmID<>isWe then
        Stream.WriteDouble(pSelling); // цена клиента (Web)
      with GetWareAttrValuesByCodes(AttCodes) do try      // значения атрибутов в нужном порядке (TStringList)
        for j:= 0 to Count-1 do Stream.WriteStr(Strings[j]);
      finally Free; end;
    end; // for i:= 0 to WaresList.Count-1
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  prFree(WaresList);
  setLength(attCodes, 0);
  Stream.Position:= 0;
end;

//******************************************************************************
//                                  модельный ряд
//******************************************************************************
//====================================== (+ Web) Получить список модельных рядов
procedure prGetModelLineList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetModelLineList'; // имя процедуры/функции
var UserID, FirmID, SysID, ManufID, i, sPos, iCount: Integer;
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

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'ManufID='+IntToStr(ManufID));

    if CheckNotValidManuf(ManufID, SysID, Manuf, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

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
        Stream.WriteInt(MStart);            // Месяц
        Stream.WriteInt(YEnd);              // Год окончание выпуска
        Stream.WriteInt(MEnd);              // Месяц
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

    prSetThLogParams(ThreadData, 0, UserId, 0, 'ManufID='+IntToStr(ManufID)+', MLName='+MLName);

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
    prSetThLogParams(ThreadData, 0, UserId, 0, 'ModelLineID='+IntToStr(ModelLineID));

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

    prSetThLogParams(ThreadData, 0, UserId, 0, 'ModelLineID='+IntToStr(ModelLineID)+', MLName='+MLName);

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

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'ModelLineID='+IntToStr(ModelLineID));
    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelLine(ModelLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

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
        if OnlyWithWares then begin
          s:= MarksCommaText;
          if s<>'' then s:= '('+s+')';
          if (Params.pHP>0) then s:= IntToStr(Params.pHP)+', '+s;
        end;
        if s<>'' then s:= '||'+s;
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
      flHideOnlyOneLevel, flFromBase: boolean;
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
//    if not Cache.WareLinksUnLocked then
//      raise EBOBError.Create(MessText(mtkFuncNotEnable));
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    ModelID:= Stream.ReadInt;  // код модели
    flNodesWithoutWares:= Stream.ReadBool; // признак - передавать ноды без товаров

    flHideNodesWithOneChild:= not flNodesWithoutWares; // сворачивать ноды с 1 ребенком
    flHideOnlyOneLevel:= flHideNodesWithOneChild and Cache.HideOnlyOneLevel; // сворачивать только 1 уровень
    flHideOnlySameName:= flHideNodesWithOneChild and Cache.HideOnlySameName; // сворачивать только при совпадении имен

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'ModelID='+IntToStr(ModelID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    flFromBase:= not Cache.WareLinksUnLocked; // пока кеш связок не заполнен - берем из базы
    try // список связок с видимыми нодами модели
      listNodes:= Model.GetModelNodesList(True, flFromBase);

      if not flNodesWithoutWares then // чистим ноды без товаров
        for i:= listNodes.Count-1 downto 0 do begin
          link:= listNodes[i];
          if not link.NodeHasWares then listNodes.Delete(i);
        end;
      if listNodes.Count<1 then raise EBOBError.Create(MessText(mtkNotFoundNodes));

      listParCodes:= TList.Create;
      listParCodes.Capacity:= listNodes.Count;
      for i:= 0 to listNodes.Count-1 do begin // список кодов родителей
        link:= listNodes[i];
        Node:= link.LinkPtr;
        listParCodes.Add(Pointer(Node.ParentID));
      end;

      if flHideNodesWithOneChild then  // сворачиваем ноды с 1-м ребенком
        prHideTreeNodes(listNodes, listParCodes, flHideOnlySameName, flHideOnlyOneLevel);
      if listNodes.Count<1 then raise EBOBError.Create(MessText(mtkNotFoundNodes));

      Stream.Clear;
      Stream.WriteInt(aeSuccess);  // Запись дерева модели в поток
      Stream.WriteStr(Model.WebName);  // Запись названия модели в поток
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
  mps.pYStart:= Stream.ReadInt;  // Год начала выпуска
  mps.pMStart:= Stream.ReadInt;  // Месяц начала выпуска
  mps.pYEnd  := Stream.ReadInt;  // Год окончания выпуска
  mps.pMEnd  := Stream.ReadInt;  // Месяц окончания выпуска
  try // если не все данные были записаны в Stream
    mps.pKW        := Stream.ReadInt;  // Мощность кВт
    mps.pHP        := Stream.ReadInt;  // Мощность ЛС
    mps.pCCM       := Stream.ReadInt;  // Тех. обьем куб.см.
    mps.pCylinders := Stream.ReadInt;  // Количество цилиндров
    mps.pValves    := Stream.ReadInt;  // Количество клапанов на одну камеру сгорания
    mps.pBodyID    := Stream.ReadInt;  // Код, тип кузова
    mps.pDriveID   := Stream.ReadInt;  // Код, тип привода
    mps.pEngTypeID := Stream.ReadInt;  // Код, тип двигателя
    mps.pFuelID    := Stream.ReadInt;  // Код, тип топлива
    mps.pFuelSupID := Stream.ReadInt;  // Код, система впрыска
    mps.pBrakeID   := Stream.ReadInt;  // Код, тип тормозной системы
    mps.pBrakeSysID:= Stream.ReadInt;  // Код, Тормозная система
    mps.pCatalID   := Stream.ReadInt;  // Код, Тип катализатора
    mps.pTransID   := Stream.ReadInt;  // Код, Вид коробки передач
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
    pName:= Stream.ReadStr;  // Название модели

    prSetThLogParams(ThreadData, 0, UserId, 0, ' MLineID='+IntToStr(MLineID)+' pName='+pName);
    if (pName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidModelLine(MLineID, SysID, ModelLine, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    Top        := Stream.ReadBool; // Топ
    isVis      := Stream.ReadBool; // видимость
    ReadModelParams(Stream, mps);
    try
      pOrdNum:= Stream.ReadInt;    // порядковый №
    except
      pOrdNum:= -1;
    end;
    try
      pTDcode:= Stream.ReadInt;    // Номер TecDoc (авто) / код для сайта (мото)
    except
      pTDcode:= -1;
    end;

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
    prSetThLogParams(ThreadData, 0, UserId, 0, 'ModelID='+IntToStr(ModelID)+', pName='+pName);

    if (pName='') then raise EBOBError.Create(MessText(mtkEmptyName));
    if CheckNotValidModel(ModelID, SysID, Model, errmess) then raise EBOBError.Create(errmess);
    if CheckNotValidModelManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);

    Top        := Stream.ReadBool; // Топ
    Visible    := Stream.ReadBool; // видимость
    ReadModelParams(Stream, mps);
    try
      pOrdNum:= Stream.ReadInt;    // порядковый №
    except
      pOrdNum:= -1;
    end;
    try
      pTDcode:= Stream.ReadInt;    // Номер TecDoc (авто) / код для сайта (мото)
    except
      pTDcode:= -1;
    end;

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

    prSetThLogParams(ThreadData, 0, UserId, 0, 'ModelID='+IntToStr(ModelID));
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

    prSetThLogParams(ThreadData, 0, UserId, 0, 'ModelID='+IntToStr(ModelID));
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
    prSetThLogParams(ThreadData, 0, UserId);
    if not EmplExist(UserID) then raise EBOBError.Create(MessText(mtkNotEmplExist));
    if not arEmplInfo[UserId].UserRoleExists(rolManageBrands) then
      raise EBOBError.Create(MessText(mtkNotRightExists));

    lstBrand:= BrandTDList;
    if lstBrand.Count<1 then raise EBOBError.Create('Список брендов TecDoc пуст!');

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
  //----------------------------------------      SysID:
begin
  lst:= nil;                           // 0 - получить весь список производителей
  Stream.Position:= 0;                 // 1 - производителей авто
  OnlyVisible:= False;                 // 2 - производителей мото
  try                                  // 11 - производители авто, топовые позиции вверху
    FirmID:= Stream.ReadInt;           // 12 - производители мото, топовые позиции вверху
    UserID:= Stream.ReadInt;           // 21 - производители с ориг.номерами
    SysID:= Stream.ReadInt;            // 31 - производители с двигателями
    OnlyVisible:= Stream.ReadBool;     // False - все, True - только видимые
    OnlyWithWares:= OnlyVisible;       // False - все, True - только с товарами
    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'SysID='+IntToStr(SysID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web ???

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    with Cache.FDCA.Manufacturers do case SysID of
      constIsAuto, constIsMoto:
        prSaveManufListToStream(GetSortedList(SysID), SysID);

      constIsAuto+10, constIsMoto+10:
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
    isTop   := Stream.ReadBool; // Топ производитель
    isVis   := Stream.ReadBool; // видимость
    prSetThLogParams(ThreadData, 0, UserId, 0, 'SysID='+IntToStr(SysID)+', ManufName= '+ManufName);

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
    prSetThLogParams(ThreadData, 0, UserId, 0, 'ManufID= '+IntToStr(ManufID));

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
    isTop   := Stream.ReadBool; // Топ производитель
    isVis   := Stream.ReadBool; // Доступен пользователям

    prSetThLogParams(ThreadData, 0, UserId, 0, 'ManufID= '+IntToStr(ManufID)+', ManufName='+ManufName);

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
var UserID, SysID, FirmID, i: Integer;
    errmess: String;
    Node: TAutoTreeNode;
begin
  Stream.Position:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    SysID := Stream.ReadInt;
    prSetThLogParams(ThreadData, 0, UserId, FirmID);

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
//    if (FirmID=isWe) and CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
//    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    with Cache.FDCA.AutoTreeNodesSys[SysID].NodesList do begin // Запись дерева в поток
      Stream.WriteInt(Count);
      for i:= 0 to Count-1 do begin
        Node:= TAutoTreeNode(Objects[i]);
        Stream.WriteInt(Node.ID);
        Stream.WriteInt(Node.ParentID);
        Stream.WriteStr(Node.Name);
        Stream.WriteStr(Node.NameSys);
        Stream.WriteBool(Node.Visible);
        Stream.WriteInt(Node.MainCode);
        Stream.WriteBool(Node.IsEnding);
      end;
    end;  
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;
//======================================================= Добавить узел в дерево
procedure prTNANodeAdd(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prTNANoteAdd'; // имя процедуры/функции
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
    prSetThLogParams(ThreadData, 0, UserId, 0, 'NodeName= '+NodeName+
      ', NodeNameSys= '+NodeNameSys+', ParentID= '+IntToStr(ParentID));

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

    prSetThLogParams(ThreadData, 0, UserId);

    if not CheckTypeSys(SysID) then raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));
    if CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    Nodes:= Cache.FDCA.AutoTreeNodesSys[SysID];
    errmess:= Nodes.NodeEdit(NodeID, NodeMain, Vis, UserID, NodeName, NodeNameSys);
    if errmess<>'' then raise EBOBError.Create(errmess);

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
    prSetThLogParams(ThreadData, 0, UserId);

    if CheckNotValidTNAManage(UserID, SysID, errmess) then raise EBOBError.Create(errmess);
    if not CheckTypeSys(SysID) then raise EBOBError.Create(MessText(mtkNotFoundTypeSys, IntToStr(SysID)));

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
var UserID, FirmID, EngID, SysID, i, j, spos: Integer;
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

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'EngID='+IntToStr(EngID));

    if CheckNotValidUser(UserID, FirmID, errmess) then raise EBOBError.Create(errmess);
    SysID:= constIsAuto;
    if CheckNotValidFirmSys(FirmID, SysID, errmess) then raise EBOBError.Create(errmess); // Web

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
    if listNodes.Count<1 then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    listParCodes:= TList.Create;
    listParCodes.Capacity:= listNodes.Count;
    for i:= 0 to listNodes.Count-1 do begin // список кодов родителей
      link:= listNodes[i];
      Node:= link.LinkPtr;
      listParCodes.Add(Pointer(Node.ParentID));
    end;

    if flHideNodesWithOneChild then  // сворачиваем ноды с 1-м ребенком
      prHideTreeNodes(listNodes, listParCodes, flHideOnlySameName, flHideOnlyOneLevel);
    if listNodes.Count<1 then raise EBOBError.Create(MessText(mtkNotFoundNodes));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);  // Запись дерева двигателя в поток
    Stream.WriteStr(Eng.WebName);  // Запись названия двигателя в поток
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
      if CheckNotValidUser(EmplID, FirmID, errmess) then raise EBOBError.Create(errmess);
      if not Cache.ClientExist(UserID) then raise EBOBError.Create(MessText(mtkNotClientExist));

      WebUser:= Cache.arClientInfo[UserID];
      FirmID:= WebUser.FirmID;

      if not Cache.FirmExist(FirmID) then raise EBOBError.Create(MessText(mtkNotFirmExists));

      empl:= Cache.arEmplInfo[EmplID];
      if not empl.UserRoleExists(rolManageSprav) then // только админы
        raise EBOBError.Create(MessText(mtkNotRightExists));

      if not WebUser.Blocked then raise EBOBError.Create('пользователь не блокирован');

      if not SaveClientBlockType(cbUnBlockedByEmpl, UserID, BlockTime, EmplID) then // разблокировка клиента в базе
        raise EBOBError.Create('ошибка разблокировки клиента');
                      // ключевой текст разблокировки (для GetUserSearchCount) ???
      sParam:= sParam+#13#10'WebUser '+IntToStr(UserID)+' unblocked';
    finally
      prSetThLogParams(ThreadData, 0, EmplID, 0, sParam);
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
      Body.Add('пользователя с логином <'+WebUser.Login+'> (код '+IntToStr(WebUser.ID)+')');
      Body.Add('  контрагент '+WebUser.FirmName);
      if FirmExist(FirmID) then begin
        s:= arFirmInfo[FirmID].GetFirmManagersString([fmpName, fmpShort, fmpPref]);
        if (s<>'') then Body.Add('  '+s);
      end;

      regMail:= Cache.GetConstEmails(pcEmpl_list_UnBlock, errmess, FirmID);
      if regMail='' then // в s запоминаем строку в письмо контролю
        s:= 'Сообщение о разблокировке клиента не отправлено - не найдены адреса рассылки'
      else begin
        s:= n_SysMailSend(regMail, 'Разблокировка учетной записи пользователя', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then begin // если не записалось в файл
          fnWriteToLog(ThreadData, lgmsSysError, nmProc+'(send mail to empls)', 'ошибка рассылки', s, '');
          s:= 'Ошибка отправки сообщения о разблокировке клиента на Email: '+regMail;
        end else s:= 'Сообщение о разблокировке клиента отправлено на Email: '+regMail;
      end;
                               //-------------------------- контролю (Щербакову)
      if s<>'' then Body.Add(#10+s);
      if errmess<>'' then Body.Add(#10+errmess); // сообщение о ненайденных адресах

      regMail:= Cache.GetConstEmails(pcBlockMonitoringEmpl, errmess, FirmID);
      if errmess<>'' then Body.Add(errmess);

      if regMail='' then regMail:= GetSysTypeMail(constIsAuto); // Щербакову (на всяк.случай)

      if regMail<>'' then begin
        s:= n_SysMailSend(regMail, 'Разблокировка учетной записи пользователя', Body, nil, '', '', True);
        if (s<>'') and (Pos(MessText(mtkErrMailToFile), s)>0) then
          prMessageLOGS(nmProc+'(send mail to Monitoring): '+s);
      end;

      prMessageLOGS(nmProc+': разблокировка клиента');  // пишем в лог
      for i:= 0 to Body.Count-1 do if trim(Body[i])<>'' then
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
//================================== список сопутствующих товаров (Web & WebArm)
procedure prGetWareSatellites(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareSatellites'; // имя процедуры/функции
var UserID, FirmID, WareID, currID, ForFirmID, Sys, j, arlen, contID: integer;
    wCodes: Tai;
    PriceInUah: boolean;
begin
  Sys:= 0;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'WareID='+IntToStr(WareID)+
      #13#10'ForFirmID='+IntToStr(ForFirmID)); // логирование

    if not Cache.WareExist(WareID) then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, Sys, CurrID, PriceInUah, contID);

    wCodes:= Cache.GetWare(WareID).GetSatellites(Sys);
    arlen:= Length(wCodes);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно

    Stream.WriteInt(arlen); // кол-во строк товаров
    for j:= 0 to High(wCodes) do
      prSaveShortWareInfoToStream(Stream, wCodes[j], FirmID, UserID, 0, currID, ForFirmID, 0, contID);

    PriceInUah:= ((FirmID<>IsWe) or (ForFirmID>0)) and (arlen>0) // здесь PriceInUah использ.как флаг
                 and (arlen<=Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue);
    Stream.WriteBool(PriceInUah);          // нужно ли запрашивать остатки

    // блок отправки инфы о наличии привязанных моделей +++
    prSaveWaresModelsExists(Stream, Sys, wCodes);
    // блок отправки инфы о наличии привязанных моделей ---
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
end;
//=============================================== список аналогов (Web & WebArm)
procedure prGetWareAnalogs(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prGetWareAnalogs'; // имя процедуры/функции
var i, arlen, UserId, WareID, WhatShow, FirmID, currID, ForFirmID, Sys, contID: integer;
    wCodes: Tai;
    PriceInUah: boolean;
begin
  Sys:= 0;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    WareID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;
    WhatShow:= Stream.ReadByte;

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'WareID='+IntToStr(WareID)+#13#10+
      #13#10'ForFirmID='+IntToStr(ForFirmID)+'WhatShow='+IntToStr(WhatShow)); // логирование
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, Sys, CurrID, PriceInUah, contID);

    if WhatShow=constThisIsOrNum then begin
      if not Cache.FDCA.OrigNumExist(WareID) then raise EBOBError.Create(MessText(mtkNotFoundOrNum));
      wCodes:= Cache.FDCA.arOriginalNumInfo[WareID].arAnalogs;
      if (Sys>0) then for i:= High(wCodes) downto 0 do // отсев по системе
        if not Cache.WareExist(wCodes[i]) or
          not Cache.GetWare(wCodes[i]).CheckWareTypeSys(Sys) then
          prDelItemFromArray(i, wCodes);

    end else begin
      if not Cache.WareExist(WareID) then
        raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));
      wCodes:= fnGetAllAnalogs(WareID, -1, Sys);
    end;

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    arlen:= Length(wCodes);
    Stream.WriteInt(arlen); // кол-во аналогов;
    for i:= 0 to High(wCodes) do
      prSaveShortWareInfoToStream(Stream, wCodes[i], FirmID, UserId, 0, currID, ForFirmID, 0, contID);

    PriceInUah:= ((FirmID<>IsWe) or (ForFirmID>0)) and (arlen>0) // здесь PriceInUah использ.как флаг
      and (arlen<=Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue);
    Stream.WriteBool(PriceInUah);          // нужно ли запрашивать остатки

    // блок отправки инфы о наличии привязанных моделей +++
    prSaveWaresModelsExists(Stream, Sys, wCodes);
    // блок отправки инфы о наличии привязанных моделей ---
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(wCodes, 0);
end;
//================================================= поиск товаров (Web & WebArm)
procedure prCommonWareSearch(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonWareSearch'; // имя процедуры/функции
var Template, s, InnerErrorPos, ss, sParam: string;
    UserId, FirmID, currID, ForFirmID, FirmSys, i, j, arlen, arlen1,
      CountAll, CountWares, CountON, contID: integer;
    IgnoreSpec: byte;
    ShowAnalogs, NeedGroups, NotWasGroups, PriceInUah, flAUTO, flMOTO,
      flSale, flCutPrice, flLamp, flSpecSearch: boolean;
    aiOrNums, aiWareByON, TypesI, arTotalWares: Tai;
//    TypesS: Tas;
    OrigNum: TOriginalNumInfo;
    OList, WList: TObjectList;
    WareAndAnalogs: TWareAndAnalogs;
begin
  Stream.Position:= 0;
  WList:= nil;
  SetLength(aiOrNums, 0);
  SetLength(TypesI, 0);
  SetLength(arTotalWares, 0);
  SetLength(aiWareByON, 0);
  OList:= TObjectList.Create;
  FirmSys:= 0;
  flSale:= False;
  flCutPrice:= False;
  CountON:= 0;
  try
InnerErrorPos:='0';
    UserId:= Stream.ReadInt;
    FirmId:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // для контрактов
    Template:= Stream.ReadStr;
    IgnoreSpec:= Stream.ReadByte;
    PriceInUah:= Stream.ReadBool;

    Template:= trim(Template);
    if Length(Template)<1 then raise EBOBError.Create('Не задан шаблон поиска');

          // логирование в ib_css - формат НЕ ТРОГАТЬ, обрабатывается в базе !!!
    sParam:= 'Template='+Template+#13#10+'IgnoreSpec='+IntToStr(IgnoreSpec);
    try
  //------------------------------------------------------------- спец.виды поиска
      flLamp:= (IgnoreSpec=coLampBaseIgnoreSpec);  // подбор по лампам
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
      if flLamp then  // добавляем в перечень типы товара ЛАМПА и т.п.
        s:= Cache.GetConstItem(pcWareTypeLampCodes).StrValue
      else
        s:= Stream.ReadStr; // получаем перечень типов товаров, выбранных пользователем
      if (s<>'') then for ss in fnSplitString(S, ',') do begin
        j:= StrToIntDef(ss, -1);
        if j>-1 then prAddItemToIntArray(j, TypesI);
      end;

  InnerErrorPos:='2';
                 // проверить UserID, FirmID, ForFirmID и получить систему, валюту
      prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, FirmSys, CurrID, PriceInUah, contID);
      flAUTO:= (FirmSys in [0, constIsAuto]);
      flMOTO:= (FirmSys in [0, constIsMoto]);

      NotWasGroups:= (Length(TypesI)=0); // запоминаем, передавались ли группы, т.к. массив переопределится

      WList:= SearchWaresTypesAnalogs(Template, TypesI, IgnoreSpec, -1, flAUTO, flMOTO,
                                      false, true, flSale, flCutPrice, flLamp);
      CountWares:= WList.Count;

      if NotWasGroups then begin
        for i:= 0 to High(TypesI) do prAddWareType(OList, TypesI[i]);
        SetLength(TypesI, 0);
      end;

  InnerErrorPos:='3';
      if flAUTO and not flSpecSearch then begin  // только для АВТО и обычного поиска
        aiOrNums:= Cache.FDCA.SearchWareOrigNums(Template, IgnoreSpec, True, TypesI);
        CountON:= Length(aiOrNums);
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

  InnerErrorPos:='4';
      NeedGroups:= NotWasGroups and (CountAll>Cache.GetConstItem(pcSearchCountTypeAsk).IntValue);
      if NeedGroups then for i:= 0 to length(TypesI)-1 do prAddWareType(OList, TypesI[i]);
      NeedGroups:= NeedGroups and (OList.Count>1);

      Stream.Clear;
      Stream.WriteInt(aeSuccess);
      Stream.WriteBool(NeedGroups);

      if NeedGroups then begin //------------------------------- если нужны группы
  InnerErrorPos:='5';
        OList.Sort(@CompareTypeNamesForTwoCodes);
        Stream.WriteInt(CountAll);
        Stream.WriteInt(OList.Count);
        for I:= 0 to OList.Count-1 do begin
          j:= TTwoCodes(OList[i]).ID1;
          Stream.WriteInt(j);
          Stream.WriteStr(Cache.GetWareTypeName(j));
        end;

      end else begin //----------------------------------------- если нужны товары
  InnerErrorPos:='6';
        Stream.WriteStr(Cache.GetCurrName(currID));

        ShowAnalogs:= (FirmID<>IsWe) and (CountAll<Cache.arClientInfo[UserID].MaxRowShowAnalogs);
        Stream.WriteBool(ShowAnalogs);

        Stream.WriteInt(CountWares);   // Передаем товары
        for i:= 0 to CountWares-1 do begin
  InnerErrorPos:='7-'+IntToStr(i);
          WareAndAnalogs:= TWareAndAnalogs(WList[i]);
          arlen:= Length(WareAndAnalogs.arAnalogs);
          arlen1:= Length(WareAndAnalogs.arSatells);
          prSaveShortWareInfoToStream(Stream, WareAndAnalogs.WareID, FirmId,
                                      UserId, arlen, currID, ForFirmID, arlen1, contID);
          prAddItemToIntArray(WareAndAnalogs.WareID, arTotalWares);

          if ShowAnalogs then for j:= 0 to High(WareAndAnalogs.arAnalogs) do begin
            prSaveShortWareInfoToStream(Stream, WareAndAnalogs.arAnalogs[j], FirmId,
                                        UserId, 0, currID, ForFirmID, 0, contID);
            prAddItemToIntArray(WareAndAnalogs.arAnalogs[j], arTotalWares);
          end;
        end;

        Stream.WriteInt(CountON);  // Передаем оригинальные номера
        for i:= 0 to High(aiOrNums) do begin
  InnerErrorPos:='8-'+IntToStr(i);
          OrigNum:= Cache.FDCA.arOriginalNumInfo[aiOrNums[i]];
          Stream.WriteInt(OrigNum.ID);
          Stream.WriteInt(OrigNum.MfAutoID);
          Stream.WriteStr(OrigNum.ManufName);
          Stream.WriteStr(OrigNum.OriginalNum);
          Stream.WriteStr(OrigNum.CommentWWW);
          if ShowAnalogs then begin
            SetLength(aiWareByON, 0);
            aiWareByON:= OrigNum.arAnalogs;
            Stream.WriteInt(Length(aiWareByON)); // кол-во аналогов
            for j:= 0 to High(aiWareByON) do begin
              prSaveShortWareInfoToStream(Stream, aiWareByON[j], FirmId, UserId,
                                          0, currID, ForFirmID, 0, contID);
              prAddItemToIntArray(aiWareByON[j], arTotalWares);
            end;
            SetLength(aiWareByON, 0);
          end;
        end;

        CountAll:= Length(arTotalWares);
        PriceInUah:= ((FirmID<>IsWe) or (ForFirmID>0)) and (CountAll>0) // здесь PriceInUah использ.как флаг
          and (CountAll<=Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue);
        Stream.WriteBool(PriceInUah);          // нужно ли запрашивать остатки

  InnerErrorPos:='9-1';
        // блок отправки инфы о наличии привязанных моделей +++
        prSaveWaresModelsExists(Stream, FirmSys, arTotalWares);
        // блок отправки инфы о наличии привязанных моделей ---
      end;
      sParam:= sParam+#13#10'WareQty='+IntToStr(CountWares)+#13#10'OEQty='+IntToStr(CountON);
    finally
      prSetThLogParams(ThreadData, 0, UserID, FirmID, sParam); // логирование
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do
      prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'InnerErrorPos='+InnerErrorPos, False);
  end;
  Stream.Position:= 0;
  SetLength(aiOrNums, 0);
  SetLength(aiWareByON, 0);
  SetLength(arTotalWares, 0);
  SetLength(TypesI, 0);
//  SetLength(TypesS, 0);
  prFree(OList);
  prFree(WList);
end;
//=============================== вывод семафоров наличия товаров (Web & WebArm)
procedure prCommonGetRestsOfWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetRestsOfWares'; // имя процедуры/функции
var UserId, FirmID, NodeID, ModelID, WareCode, iCount, i, j, iSem,
      ForFirmID, iPos, FirmSys, CurrID, ContID: integer;
    WareCodes: string;
    First: Tas;
    Second, StorageCodes: Tai;
    Ware: TWareInfo;
    Firm: TFirmInfo;
    Contract: TContract;
    flAdd: boolean;
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

    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'WareCodes='+WareCodes+ // логирование
     ' ModelID='+IntToStr(ModelID)+' NodeID='+IntToStr(NodeID)+' ForFirmID='+IntToStr(ForFirmID));

    if WareCodes='' then Exit;

    iCount:= 0;
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    iPos:= Stream.Position;
    Stream.WriteInt(iCount);

    if (FirmID<>IsWe) then ForFirmID:= FirmID
    else if (ForFirmID<1) then Exit; // не надо передавать при ForFirmID<1

    First:= fnSplitString(WareCodes, ',');
    if Length(First)>Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue then
      raise EBOBError.Create('Слишком много товаров для проверки наличия');

    Firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= Firm.GetContract(ContID);
    flAdd:= flClientStoragesView_add and Contract.HasAddVis;
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, FirmSys, CurrID, False, ContID);

    SetLength(Second, 0);
    for i:= 0 to High(First) do begin
      WareCode:= StrToIntDef(trim(First[i]), 0);
      if (WareCode>0) and Cache.WareExist(WareCode) then begin
        Ware:= Cache.GetWare(WareCode);
        if Ware.IsMarketWare(ForFirmID, contID) then
          prAddItemToIntArray(WareCode, Second);
      end;
    end;

    if (Length(Second)>0) then begin
      for i:= 0  to High(Contract.ContStorages) do with Contract.ContStorages[i] do
        if IsVisible or (flAdd and IsAddVis) then prAddItemToIntArray(DprtId, StorageCodes);

      for i:= 0 to High(Second) do begin
        iSem:= 0;
        OList:= Cache.GetWareRestsByStores(Second[i]);
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
    end;

    if iCount>0 then begin
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
//======================================== список товаров по узлу (Web & WebArm)
procedure prCommonGetNodeWares(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetNodeWares'; // имя процедуры/функции
var UserId, NodeId, ModelId, FirmId, Position, i, j, WareCount, aCount, sCount,
      ForFirmID, Sys, CurrID, WareID, contID: integer;
    ShowChildWares, IsEngine, flag, PriceInUAH, flWebarm, ShowAnalogs: boolean;
    aiWares, aar, aar1, arTotalWares: Tai;
    Model: TModelAuto;
    StrPos, filter, NodeName: string;
    List: TStringList;
    Engine: TEngine;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  Engine:= nil;
  Model:= nil;
  List:= nil;
  empl:= nil;
  SetLength(arTotalWares, 0);
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
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'Node='+IntToStr(NodeID)+ // логирование
      #13#10'Model='+IntToStr(ModelID)+#13#10'Filter='+(Filter)+
      #13#10'IsEngine='+fnIfStr(IsEngine, '1', '0')+#13#10'ForFirmID='+IntToStr(ForFirmID));
StrPos:='1';
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, Sys, CurrID, PriceInUah, contID);
StrPos:='2';
//    if not Cache.WareLinksUnLocked then
//      raise EBOBError.Create(MessText(mtkFuncNotEnable));

    if IsEngine then begin  //--------- двигатель
      if (Sys=0) then Sys:= constIsAuto;
      if Sys<>constIsAuto then raise EBOBError.Create(MessText(mtkNotFoundWares));
      if not Cache.FDCA.Engines.ItemExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundEngine));
      Engine:= Cache.FDCA.Engines[ModelID];

    end else begin          //--------- модель
      if not Cache.FDCA.Models.ModelExists(ModelID) then
        raise EBOBError.Create(MessText(mtkNotFoundModel));
      Model:= Cache.FDCA.Models.GetModel(ModelID);
      if Sys<>Model.TypeSys then Sys:= Model.TypeSys;
    end;

    if not Cache.FDCA.AutoTreeNodesSys[Sys].NodeExists(NodeID) then
      raise EBOBError.Create(MessText(mtkNotFoundNode));

    flWebArm:= (FirmId=IsWe);
    if flWebArm then empl:= Cache.arEmplInfo[UserId];
StrPos:='3';
    Stream.Clear;
    Stream.WriteInt(aeSuccess);

    if IsEngine then begin  //--------- двигатель
      Stream.WriteInt(31);
      Stream.WriteStr(Engine.WebName);
    // Признак того, что пользователь WebArm может удалять товар из связки 3
      flag:= flWebArm and empl.UserRoleExists(rolTNAManageAuto);
StrPos:='4-1';
      List:= Engine.GetEngNodeWaresWithUsesByFilters(NodeID, ShowChildWares, Filter);

    end else begin          //--------- модель
      Stream.WriteInt(Sys);
      Stream.WriteStr(Model.WebName);
    // Признак того, что пользователь WebArm может удалять товар из связки 3
      flag:= flWebArm and Cache.WareLinksUnLocked and Model.GetModelNodeIsSecondLink(NodeID) and
             (((Sys=constIsMoto) and empl.UserRoleExists(rolTNAManageMoto)) or
             ((Sys=constIsAuto) and empl.UserRoleExists(rolTNAManageAuto)));
StrPos:='4-2';
      List:= Cache.GetModelNodeWaresWithUsesByFilters(ModelID, NodeID, ShowChildWares, Filter);
    end;

    WareCount:= List.Count;
    if (WareCount<1) then raise EBOBError.Create(MessText(mtkNotFoundWares));
StrPos:='4-3';
    NodeName:= Cache.FDCA.AutoTreeNodesSys[Sys][NodeID].Name;

    SetLength(aiWares, WareCount);
    for i:= 0 to WareCount-1 do aiWares[i]:= integer(List.Objects[i]);

StrPos:='5';
    Stream.WriteBool(flag);
    Stream.WriteStr(NodeName);
    Stream.WriteStr(Filter);
    Stream.WriteStr(Cache.GetCurrName(CurrID));

    ShowAnalogs:= not flWebarm and (WareCount<Cache.arClientInfo[UserID].MaxRowShowAnalogs);
    Stream.WriteBool(ShowAnalogs);

    Stream.WriteInt(WareCount);
    for i:= 0 to WareCount-1 do try   // Передаем товары
      WareID:= aiWares[i];
      aar:= fnGetAllAnalogs(WareID, -1, Sys);
      aCount:= Length(aar);   // кол-во аналогов
      aar1:= Cache.GetWare(WareID).GetSatellites(Sys);
      sCount:= Length(aar1);  // кол-во сопут.товаров
      prSaveShortWareInfoToStream(Stream, WareID, FirmId, UserId, aCount, CurrID, ForFirmID, sCount, contID);
      prAddItemToIntArray(WareID, arTotalWares);

      if ShowAnalogs then for j:= 0 to High(aar) do begin
        prSaveShortWareInfoToStream(Stream, aar[j], FirmId, UserId, 0, currID, ForFirmID, 0, contID);
        prAddItemToIntArray(aar[j], arTotalWares);
      end;
    finally
      SetLength(aar, 0);
      SetLength(aar1, 0);
    end;
StrPos:='10';
//------------------------------------------------------------------------
    aCount:= 0;                   // Доп.инфо о применимости товаров к моделям
    Position:= Stream.Position;
    Stream.WriteInt(aCount);
    for i:= 0 to List.Count-1 do if (List.Strings[i]<>'') then begin
      Stream.WriteInt(Integer(List.Objects[i]));
      Stream.WriteStr(List.Strings[i]);
      Inc(aCount);
    end;
    Stream.Position:= Position;
    Stream.WriteInt(aCount);
    Stream.Position:= Stream.Size;

    PriceInUah:= (not flWebarm or (ForFirmID>0)) and (WareCount>0)  // здесь PriceInUah использ.как флаг
      and (WareCount<=Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue);
    Stream.WriteBool(PriceInUah);          // нужно ли запрашивать остатки

StrPos:='15';
    // блок отправки инфы о наличии привязанных моделей +++
    prSaveWaresModelsExists(Stream, Sys, arTotalWares);
    // блок отправки инфы о наличии привязанных моделей ---
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'StrPos='+StrPos, False);
  end;
  Stream.Position:= 0;
  SetLength(aiWares, 0);
  SetLength(arTotalWares, 0);
  prFree(List);
end;
//========================== поиск товаров по значениям атрибутов (Web & WebArm)
procedure prCommonSearchWaresByAttr(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonSearchWaresByAttr'; // имя процедуры/функции
var UserID, FirmID, pCount, i, j, ForFirmID, FirmSys, CurrID, sCount, contID: Integer;
    attCodes, valCodes, aar: Tai;
    PriceInUAH: boolean;
begin
  Stream.Position:= 0;
  currID:= 0;
  try
    FirmID:= Stream.ReadInt;
    UserID:= Stream.ReadInt;
    pCount:= Stream.ReadInt;  // кол-во атрибутов

    prSetThLogParams(ThreadData, 0, UserId, FirmID, 'pCount='+IntToStr(pCount));
    if pCount<1 then raise EBOBError.Create(MessText(mtkNotParams));

    SetLength(attCodes, pCount);
    SetLength(valCodes, pCount);
    for i:= 0 to pCount-1 do begin
      attCodes[i]:= Stream.ReadInt;
      valCodes[i]:= Stream.ReadInt;
    end;
    PriceInUAH:= Stream.ReadBool;
    ForFirmID:= Stream.ReadInt;   // new !!!
    ContID:= Stream.ReadInt; // для контрактов

               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, FirmSys, CurrID, PriceInUah, contID);

    attCodes:= Cache.SearchWaresByAttrValues(attCodes, valCodes);
    if (FirmSys>0) then for i:= High(attCodes) downto 0 do // отсев по системе
      if not Cache.GetWare(attCodes[i]).CheckWareTypeSys(FirmSys) then
        prDelItemFromArray(i, attCodes);
    j:= Length(attCodes);
    if j<1 then raise EBOBError.Create(MessText(mtkNotFoundWares));

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(currID));
    Stream.WriteBool(false); // Чисто для совместимости

    Stream.WriteInt(j); // Передаем товары
    for i:= 0 to j-1 do try
      aar:= Cache.GetWare(attCodes[i]).GetSatellites(FirmSys);
      sCount:= Length(aar);  // кол-во сопут.товаров
      prSaveShortWareInfoToStream(Stream, attCodes[i], FirmID, UserID, 0, currID, ForFirmID, sCount, contID);
    finally
      SetLength(aar, 0);
    end;

    PriceInUah:= ((FirmId<>IsWe) or (ForFirmID>0)) and (j>0)  // здесь PriceInUah использ.как флаг
      and (j<=Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue);
    Stream.WriteBool(PriceInUah);          // нужно ли запрашивать остатки

    //--------------------- блок отправки инфы о наличии привязанных моделей +++
    prSaveWaresModelsExists(Stream, FirmSys, attCodes);
    //--------------------- блок отправки инфы о наличии привязанных моделей ---
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  SetLength(attCodes, 0);
  SetLength(valCodes, 0);
  SetLength(aar, 0);
  Stream.Position:= 0;
end;
//================================ поиск товаров по оригин.номеру (Web & WebArm)
procedure prCommonGetWaresByOE(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prCommonGetWaresByOE'; // имя процедуры/функции
var UserId, FirmId, i, j, ManufID, arlen, arlen1, ForFirmID, Sys, CurrID, wareID, iCount, contID: integer;
    Manuf, OE: string;
    ErrorPos: string;
    aiWareByON, aiAnalogs, aiSatells, arTotalWares: Tai;
    PriceInUah, ShowAnalogs: boolean;
begin
  Stream.Position:= 0;
  SetLength(aiWareByON, 0);
  SetLength(arTotalWares, 0);
  try
    UserID:= Stream.ReadInt;
    FirmID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;   // new !!!
    ContID:= Stream.ReadInt; // для контрактов
    PriceInUah:= Stream.ReadBool;
    Manuf:= AnsiUpperCase(Stream.ReadStr);
    OE:= Stream.ReadStr;

ErrorPos:='00';
    prSetThLogParams(ThreadData, 0, UserId, FirmID, '');
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, Sys, CurrID, PriceInUah, contID);

ErrorPos:='05';
    if not Cache.FDCA.Manufacturers.ManufExistsByName(Manuf, ManufID) then
      raise EBOBError.Create(MessText(mtkNotFoundManuf, Manuf));
    if (Sys>0) and not Cache.FDCA.Manufacturers[ManufID].CheckIsTypeSys(Sys) then
      raise EBOBError.Create(MessText(mtkNotSysManuf, intToStr(Sys)));

ErrorPos:='10';
    i:= Cache.FDCA.SearchOriginalNum(ManufID, fnDelSpcAndSumb(OE));
    if i=-1 then raise EBOBError.Create(MessText(mtkNotFoundOrNum)+' "'+OE+'"');

    aiWareByON:= Cache.FDCA.arOriginalNumInfo[i].arAnalogs; // товары к ОН

    if (Sys>0) then for i:= High(aiWareByON) downto 0 do // отсев по системе
      if not Cache.GetWare(aiWareByON[i]).CheckWareTypeSys(Sys) then
        prDelItemFromArray(i, aiWareByON);
    iCount:= Length(aiWareByON);
    if (iCount<1) then raise EBOBError.Create(MessText(mtkNotFoundWares)+
                                             ' с оригинальным номером "'+OE+'"');
ErrorPos:='15';
    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    Stream.WriteStr(Cache.GetCurrName(CurrID));

    ShowAnalogs:= (FirmID<>IsWe) and (iCount<=Cache.arClientInfo[UserID].MaxRowShowAnalogs);
    Stream.WriteBool(ShowAnalogs);

    Stream.WriteInt(iCount); // кол-во аналогов
    for i:= 0 to High(aiWareByON) do try
      wareID:= aiWareByON[i];
      aiAnalogs:= fnGetAllAnalogs(wareID, -1, Sys);
      arlen:= Length(aiAnalogs);
      aiSatells:= Cache.GetWare(wareID).GetSatellites(Sys);
      arlen1:= Length(aiSatells); // кол-во сопут.товаров
      prSaveShortWareInfoToStream(Stream, wareID, FirmID, UserID, arlen, CurrID, ForFirmID, arlen1, contID);
      prAddItemToIntArray(wareID, arTotalWares);

      if ShowAnalogs then for j:= 0 to High(aiAnalogs) do begin
        prSaveShortWareInfoToStream(Stream, aiAnalogs[j], FirmID, UserID, 0, CurrID, ForFirmID, 0, contID);
        prAddItemToIntArray(wareID, arTotalWares);
      end;
    finally
      SetLength(aiAnalogs, 0);
      SetLength(aiSatells, 0);
    end;

    j:= length(arTotalWares);
    PriceInUah:= ((FirmId<>IsWe) or (ForFirmID>0)) and (j>0)  // здесь PriceInUah использ.как флаг
      and (j<=Cache.GetConstItem(pcOrderWareSemaforLimit).IntValue);
    Stream.WriteBool(PriceInUah);          // нужно ли запрашивать остатки

ErrorPos:='20';
    //--------------------- блок отправки инфы о наличии привязанных моделей +++
    prSaveWaresModelsExists(Stream, Sys, arTotalWares);
    //--------------------- блок отправки инфы о наличии привязанных моделей ---
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
  SetLength(aiWareByON, 0);
  SetLength(arTotalWares, 0);
end;
//======================================================= передать реквизиты к/а
procedure prWebArmGetFirmInfo(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmInfo'; // имя процедуры/функции
var EmplID, ForFirmID, LineCount, sPos, k, i, ContID: integer;
    errmess: string;
    firm: TFirmInfo;
    Contract: TContract;
begin
  Stream.Position:= 0;
  ContID:= 0;
  try
    EmplID:= Stream.ReadInt;          // код юзера
    ForFirmID:= Stream.ReadInt;          // код контрагента
//    ContID:= Stream.ReadInt; // для контрактов - функция уходит
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'FirmID='+IntToStr(ForFirmID)); // логирование

    if CheckNotValidUser(EmplID, isWe, errmess) then raise EBOBError.Create(errmess);
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
    Stream.WriteStr(Cache.GetCurrName(Contract.CredCurrency));
    Stream.WriteStr(Contract.WarnMessage);
    Stream.WriteBool(Contract.SaleBlocked);
    Stream.WriteInt(Contract.CredDelay);
    if not Contract.SaleBlocked then
      Stream.WriteInt(Contract.WhenBlocked); // если отгрузка не блокирована

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
end;
//=================================== показать остатки по товару и складам фирмы
procedure prWebArmShowFirmWareRests(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmShowFirmWareRests'; // имя процедуры/функции
var EmplID, ForFirmID, WareID, spos, LineCount, k, i, ContID: integer;
    s: string;
    Ware: TWareInfo;
    firm: TFirmInfo;
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

    prSetThLogParams(ThreadData, 0, EmplID, 0,
      'ForFirmID='+IntToStr(ForFirmID)+' WareID='+IntToStr(WareID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if not Cache.arEmplInfo[EmplID].UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FirmExist(ForFirmID) // проверка фирмы
      or not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    Ware:= Cache.GetWare(WareID, True);
    if not Assigned(Ware) or (Ware=NoWare) or Ware.IsArchive then
      raise EBOBError.Create(MessText(mtkNotFoundWare, IntToStr(WareID)));

    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    Stream.WriteStr(Ware.Name); // наименование товара

    //----------------------------------- передаем остатки по всем складам фирмы
    LineCount:= 0;       // счетчик
    sPos:= Stream.Position;
    Stream.WriteInt(0);  //  место под кол-во складов
    for i:= 0 to High(Contract.ContStorages) do with Contract.ContStorages[i] do
      if IsVisible or (flClientStoragesView_add and IsAddVis) then begin
        k:= DprtID;
        Rest:= 0;
        if Assigned(ware.RestLinks) then begin
          link:= ware.RestLinks[k];
          if Assigned(link) then Rest:= link.Qty;
        end;
        Stream.WriteStr(Cache.GetDprtMainName(k));     // наименование склада
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
{//======================================== передать список незакрытых счетов к/а
procedure prWebArmGetFirmAccountList(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetFirmAccountList'; // имя процедуры/функции
var EmplID, ForFirmID, j, sPos: integer;
    s: string;
    GBIBD: TIBDatabase;
    GBIBS: TIBSQL;
    empl: TEmplInfoItem;
begin
  Stream.Position:= 0;
  GBIBS:= nil;
  try
    EmplID:= Stream.ReadInt;          // код юзера
    ForFirmID:= Stream.ReadInt;       // код контрагента
    prSetThLogParams(ThreadData, 0, EmplId, 0, 'ForFirmID='+IntToStr(ForFirmID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then // проверка фирмы
      raise EBOBError.Create(MessText(mtkNotFirmExists));

    GBIBD:= CntsGRB.GetFreeCnt(empl.GBLogin, cDefPassword, cDefGBrole);

    Stream.Clear;
    Stream.WriteInt(aeSuccess); // знак того, что запрос обработан корректно
    sPos:= Stream.Position;
    Stream.WriteInt(0); // место под кол-во счетов
    try
      GBIBS:= fnCreateNewIBSQL(GBIBD, 'GBIBS_'+nmProc, ThreadData.ID, tpRead, True);
      GBIBS.SQL.Text:= 'select PInvCode, PInvNumber, PInvDate, PInvSumm,'+
        ' PINVPROCESSED, PInvLocked, PINVCLIENTCOMMENT, PInvCrncCode, u.uslsusername,'+
        ' PINVSHIPMENTMETHODCODE, PINVSHIPMENTDATE, PINVSHIPMENTTIMECODE'+ // отгрузка
        ' from PayInvoiceReestr'+
        ' left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' left join PROTOCOL pp on pp.ProtObjectCode=pinvcode'+
        '   and pp.ProtObjectType=55 and pp.ProtOperType=1'+ // создатель счета
        ' left join userlist u on u.UsLsUserID=pp.ProtUserID'+
        ' WHERE PInvRecipientCode='+IntToStr(ForFirmID)+' and PINVANNULKEY="F"'+
        ' and PInvDate>DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_TIMESTAMP)-30, CURRENT_TIMESTAMP)'+
        ' and (SbCnCode is null or INVCCODE is null) ORDER BY PInvNumber';
      GBIBS.ExecQuery;
      j:= 0;
      while not GBIBS.EOF do begin
        Stream.WriteBool(GetBoolGB(GBibs, 'PInvLocked'));  // признак блокировки счета
        Stream.WriteInt(GBIBS.FieldByName('PInvCode').AsInteger);
        Stream.WriteStr(FormatDateTime(cDateFormatY2, GBIBS.FieldByName('PInvDate').AsDateTime));
        Stream.WriteBool(GetBoolGB(GBibs, 'PINVPROCESSED'));
        Stream.WriteStr(GBIBS.FieldByName('PInvNumber').AsString);
        Stream.WriteStr(GBIBS.FieldByname('PINVCLIENTCOMMENT').AsString);
        Stream.WriteDouble(GBIBS.FieldByName('PInvSumm').AsFloat);
        Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('PInvCrncCode').AsInteger));
//        TestCssStopException;
        GBIBS.Next;
        Inc(j);
      end;
      GBIBS.Close;
      Stream.Position:= sPos;
      Stream.WriteInt(j); // передаем кол-во
    finally
      prFreeIBSQL(GBIBS);
      cntsGRB.SetFreeCnt(GBIBD);
    end;
  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  Stream.Position:= 0;
end;  }
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
    EmplID        := Stream.ReadInt;    // код сотрудника
    filtFromDate  := Stream.ReadDouble; // дата от, 0 - не задана
    filtToDate    := Stream.ReadDouble; // дата до, 0 - не задана
    filtCurrency  := Stream.ReadInt;    // код валюты, <1 - все
    filtStorage   := Stream.ReadInt;    // код склада, <1 - все
    filtShipMethod:= Stream.ReadInt;    // код метода отгрузки, <1 - все
    filtShipDate  := Stream.ReadDouble; // дата отгрузки, 0 - не задана
    filtShipTimeID:= Stream.ReadInt;    // код времени отгрузки, <1 - все
    filtExecuted  := Stream.ReadBool;   // исполненные: False - не показывать, True - показывать
    filtAnnulated := Stream.ReadBool;   // аннулированые: False - не показывать, True - показывать
    filtProcessed := Stream.ReadInt;    // -1 - все, 0 - необработанные, 1 - обработанные
    filtWebAccount:= Stream.ReadInt;    // -1 - все, 0 - не Web-счета, 1 - Web-счета
    filtBlocked   := Stream.ReadInt;    // -1 - все, 0 - не блокированные, 1 - блокированные
    filtForFirmID := Stream.ReadInt;    // код контрагента, <1 - все
    filtContractID:= Stream.ReadInt;    // код контракта, <1 - все

    prSetThLogParams(ThreadData, 0, EmplID, 0, 'filtForFirmID='+IntToStr(filtForFirmID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    s:= ''; // формируем строку условий фильтра
    if (filtForFirmID>0) then begin         // если задана фирма - проверка видимости
      if not Cache.FirmExist(filtForFirmID) or not Cache.CheckEmplVisFirm(EmplID, filtForFirmID) then
        raise EBOBError.Create(MessText(mtkNotFirmExists));
      s:= s+fnIfStr(s='', '', ' and ')+' PInvRecipientCode='+IntToStr(filtForFirmID);
    end;
    if (filtContractID>0) then begin
      if not Cache.Contracts.ItemExists(filtContractID) then
        raise EBOBError.Create(MessText(mtkNotFoundCont));
      s:= s+fnIfStr(s='', '', ' and ')+' PINVCONTRACTCODE='+IntToStr(filtContractID);
    end;
    if (filtStorage>0) then begin           // если задан склад - проверка видимости
      if not Cache.DprtExist(filtStorage) or not Cache.CheckEmplVisStore(EmplID, filtStorage) then
        raise EBOBError.Create(MessText(mtkNotDprtExists));
      s:= s+fnIfStr(s='', '', ' and ')+' PInvSupplyDprtCode='+IntToStr(filtStorage);
    end else s:= s+fnIfStr(s='', '', ' and ')+' not PInvSupplyDprtCode is null';

    if Cache.DocmMinDate>filtFromDate then filtFromDate:= Cache.DocmMinDate;
    if (filtFromDate>0) then               // дата от
      s:= s+fnIfStr(s='', '', ' and ')+' PInvDate>=:filtFromDate';
    if (filtToDate>0) then begin           // если задана дата до
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
    if (filtShipDate>0) then                    // если задана дата отгрузки
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
      GBIBS.SQL.Text:= 'select PInvCode, PInvNumber, PInvDate, PInvSumm,'+
        ' PINVPROCESSED, PInvLocked, PINVCLIENTCOMMENT, PInvCrncCode, u.uslsusername,'+
        ' PINVSHIPMENTMETHODCODE, PINVSHIPMENTDATE, PINVSHIPMENTTIMECODE,'+ // отгрузка
        ' PInvRecipientCode, PInvSupplyDprtCode, PINVANNULKEY, PINVCOMMENT,'+
        ' c.contnumber, c.contbeginingdate, c.CONTBUSINESSTYPECODE, PINVCONTRACTCODE, '+
        ' iif(SbCnCode is null or INVCCODE is null, "F", "T") as pExecuted'+     // ???
        ' from PayInvoiceReestr'+
        ' left join SUBCONTRACT on SbCnDocmCode=PInvCode and SbCnDocmType=99'+
        ' left join INVOICEREESTR on INVCSUBCONTRACT=SbCnCode'+
        ' left join CONTRACT c on c.contcode=PINVCONTRACTCODE'+
        ' left join PROTOCOL pp on pp.ProtObjectCode=pinvcode'+
        '   and pp.ProtObjectType=55 and pp.ProtOperType=1'+ // создатель счета
        ' left join userlist u on u.UsLsUserID=pp.ProtUserID'+
        ' WHERE '+s+' ORDER BY PInvNumber';
      if (filtFromDate>0) then GBIBS.ParamByName('filtFromDate').AsDateTime:= filtFromDate;
      if (filtToDate>0)   then GBIBS.ParamByName('filtToDate').AsDateTime  := filtToDate;
      if (filtShipDate>0) then GBIBS.ParamByName('filtShipDate').AsDateTime:= filtShipDate;
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
          flSkip:= not Cache.DprtExist(sid) or not Cache.CheckEmplVisStore(EmplID, sid);
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
          flSkip:= not FirmExist(fid) or not CheckEmplVisFirm(EmplID, fid);
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
        Stream.WriteBool(GBIBS.FieldByName('CONTBUSINESSTYPECODE').AsInteger=2); // is moto
        Stream.WriteStr(GBIBS.FieldByName('CONTNUMBER').AsString+'-'+
          FormatDateTime('yy', GBIBS.FieldByName('CONTBEGININGDATE').AsDateTime));
        Stream.WriteInt(sid);                                        // склад
        Stream.WriteDouble(GBIBS.FieldByName('PInvSumm').AsFloat);
        Stream.WriteStr(Cache.GetCurrName(GBIBS.FieldByName('PInvCrncCode').AsInteger));
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTMETHODCODE').AsInteger); // метод отгрузки
        Stream.WriteDouble(GBIBS.FieldByName('PINVSHIPMENTDATE').AsDate);       // дата отгрузки
        Stream.WriteInt(GBIBS.FieldByName('PINVSHIPMENTTIMECODE').AsInteger);   // время отгрузки
        Stream.WriteStr(GBIBS.FieldByName('uslsusername').AsString);            // создатель счета
        Stream.WriteStr(GBIBS.FieldByname('PINVCOMMENT').AsString);
        Stream.WriteStr(GBIBS.FieldByname('PINVCLIENTCOMMENT').AsString);
//        TestCssStopException;
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
    if (not Cache.FirmExist(firmID) or not Cache.CheckEmplVisFirm(EmplID, firmID)) then
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
//    ContID:= Stream.ReadInt; // для контрактов - здесь не нужен

    AccountCode:= IntToStr(AccountID);
    FirmCode:= IntToStr(ForFirmID);
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'ForFirmID='+FirmCode+' AccountID='+AccountCode); // логирование

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
//          curr:= Contract.ContCurrency;
        curr:= Contract.CredCurrency;
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
        ' p1.PINVSHIPMENTMETHODCODE, p1.PINVSHIPMENTDATE, p1.PINVSHIPMENTTIMECODE,'+ // отгрузка
        ' p1.PInvRecipientCode, p2.PInvCode AcntCode, p1.PINVLABELCODE, p1.PINVCONTRACTCODE'+
        ' from PayInvoiceReestr p1 left join PROTOCOL pp on pp.ProtObjectCode=p1.pinvcode'+
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
      Stream.WriteBool(Contract.SysID=constIsAuto);                     // Является ли автоконтрактом
      iStore:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
      Stream.WriteInt(iStore);                                          // код склада счета
      curr:= GBIBS.FieldByName('PInvCrncCode').AsInteger;
      Stream.WriteInt(curr);                                            // код валюты счета
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
      Stream.WriteStr(GBIBS.FieldByName('PINVCLIENTCOMMENT').AsString); // комментарий клиенту
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
        ' "" as FRLBCARRIER, FRLBDELIVERYTIME, FRLBCOMMENT from FIRMLABELREESTR'+   // поле FRLBCARRIER убрали
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
//          TestCssStopException;
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
    EmplID, ForFirmID, AccountID, ParamID, k, kk, i, LineCount, ContID, SysID: integer;
    AccountCode, FirmCode, s1, sWhere, ParamStr, ParamStr2, sf: string;
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
      or not Cache.CheckEmplVisFirm(EmplID, firmID) then
      raise EBOBError.Create(MessText(mtkNotFirmExists));
    if ForFirmID<>firmID then ForFirmID:= firmID;
    FirmCode:= IntToStr(ForFirmID);
    firm:= Cache.arFirmInfo[ForFirmID];
    Contract:= firm.GetContract(contID);
  end;
  //----------------------------------------- проверка склада фирмы
  procedure CheckForFirmStore(StoreID: Integer);
  var i: Integer;
  begin
    i:= Contract.GetСontStoreIndex(StoreID);
    if (i<0) then raise EBOBError.Create('Не найден склад резервирования');
    if not Contract.ContStorages[i].IsReserve then
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
  try
    EmplID:= Stream.ReadInt;
    AccountID:= Stream.ReadInt;
    ParamID:= Stream.ReadInt;    // вид параметра
    ParamStr:= Stream.ReadStr;   // значение параметра
    if (ParamID=ceahAnnulateInvoice) then
      ParamStr2:= Stream.ReadStr;   // значение параметра2

    AccountCode:= IntToStr(AccountID);
    prSetThLogParams(ThreadData, 0, EmplID, 0, ' AccountID='+AccountCode+
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
        ceahChangeContract  : sf:= 'PInvSupplyDprtCode, PINVCONTRACTCODE';
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
          // если есть товары - запоминаем бизнес-направление прежнего контракта
          if (LineCount>0) then SysID:= Contract.SysID else SysID:= 0;
          contID:= k;
          Contract:= firm.GetContract(contID);
          if (contID<>k) then raise EBOBError.Create(MessText(mtkNotFoundCont));
          if (SysID>0) and (SysID<>Contract.SysID) then
            raise EBOBError.Create('Контракт не соответствует бизнес-направлению');
          kk:= GBIBS.FieldByName('PInvSupplyDprtCode').AsInteger;
          CheckForFirmStore(kk); // проверка соответствия склада новому контракту фирмы
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
          if not Cache.CurrExists(k) or Cache.arCurrArhived[k] then
            raise EBOBError.Create('Не найдена валюта');
        end;

      ceahChangeProcessed: begin //--------------------------- признак обработки
          k:= StrToIntDef(ParamStr, 0);
          if fnIfInt(GBIBS.FieldByName(sf).AsString='T', 1, 0)=k then raise EBOBError.Create(sNot);
          ParamStr:= fnIfStr(k=1, '"T"', '"F"');
        end;

      ceahChangeEmplComm,       //---------- комментарий сотрудникам (м.б.пусто)
      ceahChangeClientComm: begin //------------ комментарий клиенту (м.б.пусто)
          if GBIBS.FieldByName(sf).AsString=ParamStr then raise EBOBError.Create(sNot);
          k:= Length(ParamStr);
          if k>cCommentLength then raise EBOBError.Create('Слишком длинный комментарий');
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
          if (LineCount>0) then SysID:= Contract.SysID else SysID:= 0;
          CheckFirm(ForFirmID);                // проверка фирмы
          if (SysID>0) and (SysID<>Contract.SysID) then begin
            k:= contID;         // ищем контракт нужного бизнес-направления
            for i:= 0 to firm.FirmContracts.Count-1 do begin
              contID:= firm.FirmContracts[i];
              if (contID=k) then Continue; // пропускаем тот, что уже был
              Contract:= firm.GetContract(contID);
              if (Contract.SysID=SysID) and not Contract.IsEnding then break;
            end;
            if (k=contID) then // если другой подходящий не нашли
              raise EBOBError.Create('Контракт не соответствует бизнес-направлению');
          end;
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
            EBOBError.Create('Неверный параметр аннуляции - "'+ParamStr+'"');
          if (ParamStr2<>'T') and (ParamStr2<>'F') then
            EBOBError.Create('Неверный параметр аннуляции - "'+ParamStr2+'"');
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
            GBIBS.Next;
          end;
          if LineCount<>Length(arLineWareAndQties) then SetLength(arLineWareAndQties, LineCount);
        end;  // if ParamID=ceahRecalcCounts

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
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'ForFirmID='+FirmCode+' AccountID='+AccountCode+
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
      or not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then
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
              RollbackRetaining;
              if (i<RepeatCount) then sleep(RepeatSaveInterval)
              else raise Exception.Create(E.Message);
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
      s:= FormatFloat('# ##0.00', GBIBS.FieldByName('PInvSumm').AsFloat);
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
function fnGetStrSummByDoubleCurr(sum: Double; MainCurr: Integer): String;
var k: Integer;
begin
  Result:= '';
  if not Cache.CurrExists(MainCurr) then Exit;

  Result:= FormatFloat('# ##0.00', sum)+' '+Cache.GetCurrName(MainCurr);

  if not (MainCurr in [1, cDefCurrency]) then Exit; // пока только грн и евро

  if MainCurr=cDefCurrency then begin
    k:= 1;
    sum:= sum*Cache.CURRENCYRATE;
  end else {if (MainCurr=1) then} begin
    k:= cDefCurrency;
    sum:= sum/Cache.CURRENCYRATE;
  end;
  Result:= Result+' ('+FormatFloat('# ##0.00', sum)+' '+Cache.GetCurrName(k)+')';
end;
//================================ описания товаров для просмотра (счета WebArm)
procedure prWebArmGetWaresDescrView(Stream: TBoBMemoryStream; ThreadData: TThreadData);
const nmProc = 'prWebArmGetWaresDescrView'; // имя процедуры/функции
var EmplID, ForFirmID, WareID, i, ii, sPos, j, SysID, iCri, iNode, contID: Integer;
    s, sView, sWareCodes, ss, CriName: string;
    Codes: Tas;
    empl: TEmplInfoItem;
    ware: TWareInfo;
    ORD_IBS, ORD_IBS1: TIBSQL;
    ORD_IBD: TIBDatabase;
    Contract: TContract;
begin
  ORD_IBS:= nil;
  ORD_IBS1:= nil;
  Stream.Position:= 0;
  SetLength(Codes, 0);
  contID:= 0;
  try
    EmplID:= Stream.ReadInt;
    ForFirmID:= Stream.ReadInt;
    ContID:= Stream.ReadInt; // для контрактов
    sWareCodes:= Stream.ReadStr; // коды товаров

    prSetThLogParams(ThreadData, 0, EmplID, 0, 'ForFirmID='+IntToStr(ForFirmID)+
      #13#10'sWareCodes='+sWareCodes);

    Stream.Clear;
    Stream.WriteInt(aeSuccess);
    sPos:= Stream.Position;
    Stream.WriteInt(0);  // место под кол-во товаров

    Codes:= fnSplitString(sWareCodes, ',');
    if Length(Codes)<1 then Exit; // товаров нет - выходим

//    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    if CheckNotValidUser(EmplID, isWe, s) then Exit; // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then Exit; // проверяем право пользователя
//      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.FirmExist(ForFirmID) // проверка фирмы
      or not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then Exit;
//      raise EBOBError.Create(MessText(mtkNotFirmExists));
    Contract:= Cache.arFirmInfo[ForFirmID].GetContract(contID);
    SysID:= Contract.SysID;

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
        ' iif(ITATEXT is null, ITTEXT, ITATEXT) text'+          // new txt
        ' from (select LWNTnodeID, LWNTinfotype, LWNTWIT'+
        '  from LinkWareNodeText where LWNTwareID=:WareID and LWNTWRONG="F")'+
        ' left join DIRINFOTYPEMODEL on DITMCODE = LWNTinfotype'+
        ' left join TREENODESAUTO on TRNACODE=LWNTnodeID'+
        ' left join WareInfoTexts on WITCODE=LWNTWIT'+
        ' left join INFOTEXTS on ITCODE=WITTEXTCODE'+           // new txt
        ' left join INFOTEXTSaltern on ITACODE=ITALTERN'+       // new txt
        ' where TRNADTSYCODE='+IntToStr(SysID)+
        ' order by LWNTnodeID, LWNTinfotype, text';
      ORD_IBS1.Prepare;

      j:= 0; // счетчик товаров
      for i:= 0 to High(Codes) do begin
        WareID:= StrToIntDef(Codes[i], 0);
        if not Cache.WareExist(WareID) then Continue;

        ware:= Cache.GetWare(WareID);
        if ware.IsArchive or not ware.IsWare or not ware.CheckWareTypeSys(SysID) then Continue;

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
//          sView:= sView+fnIfStr(sView='', '', '; ')+CriName+fnIfStr(s='', '', ': '+s); // строка по 1-му типу текста
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
    UserId, FirmID, currID, ForFirmID, FirmSys, i, CountDeliv, wareID, contID: integer;
    ShowAnalogs, PriceInUah: boolean;
    ar: Tai;
begin
  Stream.Position:= 0;
  SetLength(ar, 0);
  FirmSys:= 0;
  ForFirmID:= 0;
  contID:= 0;
  FirmId:= isWe;
  ShowAnalogs:= False;
  try
InnerErrorPos:='0';
    UserId:= Stream.ReadInt;
    PriceInUah:= Stream.ReadBool;

InnerErrorPos:='1';
               // проверить UserID, FirmID, ForFirmID и получить систему, валюту
    prCheckUserForFirmAndGetSysCurr(UserID, FirmID, ForFirmID, FirmSys, CurrID, PriceInUah, contID);
InnerErrorPos:='2';
    CountDeliv:= Cache.DeliveriesList.Count;
InnerErrorPos:='3';
    prSetThLogParams(ThreadData, 0, UserID, FirmID, 'DelivQty='+IntToStr(CountDeliv)); // логирование
InnerErrorPos:='4';
    if CountDeliv<1 then raise EBOBError.Create('Не найдены доставки');

    Stream.Clear;
    Stream.WriteInt(aeSuccess);

InnerErrorPos:='6';
    Stream.WriteStr(Cache.GetCurrName(currID));
    Stream.WriteBool(ShowAnalogs);
    Stream.WriteInt(CountDeliv);   // Передаем доставки
    for i:= 0 to CountDeliv-1 do begin
InnerErrorPos:='7-'+IntToStr(i);
      wareID:= Integer(Cache.DeliveriesList.Objects[i]);
      prSaveShortWareInfoToStream(Stream, wareID, FirmId, UserId, 0, currID, ForFirmID, 0, contID);
    end;

  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do
      prSaveCommonError(Stream, ThreadData, nmProc, E.Message, 'InnerErrorPos='+InnerErrorPos, False);
  end;
  Stream.Position:= 0;
  SetLength(ar, 0);
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
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'AccountID='+AccountCode); // логирование

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
//    ContID:= Stream.ReadInt; // для контрактов - здесь не нужен

    AccountCode:= IntToStr(AccountID);
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'AccountID='+AccountCode+
      ', ForFirmID='+IntToStr(ForFirmID)); // логирование

    if (AccountID<1) then raise EBOBError.Create('Неверный код счета');
    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
    empl:= Cache.arEmplInfo[EmplID];
    if not empl.UserRoleExists(rolOPRSK) then // проверяем право пользователя   ???
      raise EBOBError.Create(MessText(mtkNotRightExists));

    if not Cache.CheckEmplVisFirm(EmplID, ForFirmID) then                 // проверка фирмы
      raise EBOBError.Create(MessText(mtkNotFirmExists));
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
    EmplID  := Stream.ReadInt;    // код сотрудника
    ddFrom  := Stream.ReadDouble; // начиная с даты док-та
    DprtFrom:= Stream.ReadInt;    // подр.отгрузки
    DprtTo  := Stream.ReadInt;    // подр.приема
    flOpened:= Stream.ReadBool;   // только открытые

    prSetThLogParams(ThreadData, 0, EmplID, 0, 'ddFrom='+DateToStr(ddFrom)+' DprtFrom='+
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
    InvID := Stream.ReadInt;    // код накл.передачи

    InvCode:= IntToStr(InvID);
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'InvID='+InvCode); // логирование

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
    prSetThLogParams(ThreadData, 0, EmplID, 0, 'AccID='+AccCode+', InvID='+InvCode+', InvID='); // логирование

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
//    empl: TEmplInfoItem;
    IBS: TIBSQL;
    IBD: TIBDatabase;
    Filials, Classes, Types, Firms: TIntegerList;
    flAdd, flAuto, flMoto: Boolean;
begin
  IBS:= nil;
  Stream.Position:= 0;
  Filials:= TIntegerList.Create;
  Classes:= TIntegerList.Create;
  Types  := TIntegerList.Create;
  Firms  := TIntegerList.Create;
  try
    EmplID:= Stream.ReadInt;     // код сотрудника
    noteID:= Stream.ReadInt;     // код уведомления (<1 - все)

    prSetThLogParams(ThreadData, 0, EmplID, 0, 'noteID='+IntToStr(noteID)); // логирование

    if CheckNotValidUser(EmplID, isWe, s) then raise EBOBError.Create(s); // проверка юзера
//    empl:= Cache.arEmplInfo[EmplID];
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
        flAdd := GetBoolGB(ibs, 'NOTEFIRMSADDFLAG'); // флаг - добавлять/исключать коды Firms
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
        ' c.contnumber||"-"||RIGHT(cast(EXTRACT(YEAR FROM c.contbeginingdate) as varchar(4)), 2) as cNum1,'+
        ' c1.contnumber||"-"||RIGHT(cast(EXTRACT(YEAR FROM c1.contbeginingdate) as varchar(4)), 2) as cNum2,'+
        ' p.prsnlogin as login1, p.prsncode as CliCode1,'+
        ' p1.prsnlogin as login2, p1.prsncode as CliCode2 from firms f'+
        ' left join contract c on c.contsecondparty=f.firmcode'+
        ' left join contract c1 on c1.contclonecontsource=c.contcode'+
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
            gbIBS.Next;
          end;
          if (s='') then begin
            ss:= ss+'нет данных о сотрудниках с логинами для клонирования в СВК';
            prMessageLOGn(ss, pFileName);
            prMessageLOGS(nmProc+': '+ss, 'import_test', False); // логирование
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

end.
